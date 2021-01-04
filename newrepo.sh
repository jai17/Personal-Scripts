organization="orgName"

# Error handling
# Cleanup on error
OnError()
{
  case $1 in
  2)  # Failed on Topic or Team setting
    echo
    echo "!!!!!!!!!!!!!!!!!!!!ERROR!!!!!!!!!!!!!!!!!!!!!!!"
    echo "! REMOVING CREATED REPO FROM GITHUB"
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo
    httpResponse=$(\
                    curl --write-out "%{http_code}\n" --silent --output /dev/nullcurl\
                    -H "Authorization: token ${OAuthToken}" https://api.github.com/repos/$organization/$repoName\
                    -X DELETE\
                  )
    if [ "$httpResponse" != "204" ]; then # HTTP response code
		echo "Failed to delete $repoName on GitHub"
		echo "HTTP Response $httpResponse"
    fi
    ;&
  1)  # On GitHub repo create fail
    echo
    echo "!!!!!!!!!!!!!!!!!!!!ERROR!!!!!!!!!!!!!!!!!!!!!!!"
    echo "! REMOVING TEMPLATE REPO FROM LOCAL DIRECTORY"
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo
    cd ..
    rm -r -f $templateRepoclear
    exec bash
	exit 1
    ;;
  esac
}

arr_teams=()
arr_teams_access=()

function addTeam()
{
	local -n _array1=$2
	
	if [ $1 = "Electrical" ]; then
		_array1+=("2211978")
	elif [ $1 = "LibKicad" ]; then
		_array1+=("2633419")
	elif [ $1 = "PCBKicad" ]; then
		_array1+=("2633310")
	elif [ $1 = "Software" ]; then
		_array1+=("2122419")
	elif [ $1 = "Employees" ]; then
		_array1+=("3620849")
	else
	echo
		echo "INVALID TEAM ENTRY: $1. CHOOSE FROM LIST:"
		echo "[Electrical/LibKicad/PCBKicad/Software/Employees]"
		helpFunction
	fi
}

function addAccess()
{
	local -n _array1=$2
	
	if [ $1 = "Write" ]; then
		_array1+=("push")
	elif [ $1 = "Read" ]; then
		_array1+=("pull")
	else
		echo "INVALID TEAM ACCESS ENTRY: $1. CHOOSE FROM LIST:"
		echo "[Read/Write]"
		helpFunction
	fi
}

helpFunction()
{
	echo ""
	echo "Usage: $0 "
	echo "Usage: $0 -h"
	printf "Usage: $0 -t templateRepo -n repoName -d repoDescription -p project \n\t\t  -e team1 -a access1 -e team2 -a access2\n"
	printf "Usage: $0 -t templateRepo -n repoName -d repoDescription -p project \n\t\t  -e team1 -a access1 -b develop\n"
	echo
	echo -e "\t-h Help Menu"
	echo -e "\t-t Template Repository Name"
	echo -e "\t-n New repository name"
	echo -e "\t-d Description of new repository"
	echo -e "\t-e Team name [Electrical/LibKicad/PCBKicad/Software/Employees]"
	echo -e "\t-a Team access type [Read/Write]"
	echo -e "\t-p Repository Topic"
	echo -e "\t-b Optional Default Branch [master/develop] . Default is master"
	echo ""
	exec bash
	exit 1
}

if [[ -n "$1" ]]; then

	while getopts 'ht:n:d:e:a:p:b:' opt
	do
		case "$opt" in
			h ) paramH="true"
				helpFunction ;;
			t ) templateRepo="$OPTARG"
				;;
			n ) repoName="$OPTARG" 
				;;
			d ) repoDesc="$OPTARG" 
				;;
			e ) addTeam $OPTARG arr_teams
				;;
			a ) addAccess $OPTARG arr_teams_access
				;;
			p ) repoTopic="$OPTARG"
				;;
			b ) defaultBranch="$OPTARG"
				if [ "${defaultBranch}" != "master" ] && [ "${defaultBranch}" != "develop" ]; then
					echo "INVALID DEFAULT BRANCH. CHOOSE FROM LIST:"
					echo "[master/develop]"
					helpFunction
				fi
				;;
			? ) helpFunction ;;
		esac
	done

else
	manual="true"
fi

# Move one directory out of script location to create new repo, otherwise created in directory of script
# cd ..

if [ -z "$manual" ]
then 
	if [ -z "$templateRepo" ] || [ -z "$repoName" ] || [ -z "$repoDesc" ] || [ -z "$repoTopic" ] || [ -z "$arr_teams" ] || [ -z "$arr_teams_access" ]
	then
		echo "Some or all of the required paramters are empty";
		helpFunction
	fi
fi

# Default team, topic and access
defaultTeam="Software"
defaultTopic="project"
defaultAccess="Write"

if [ -z "$defaultBranch" ]; then
	defaultBranch="master"
fi
	
if [ ! -z "$manual" ]
then

	#Get name of the template repository to clone, or use default
	
	templateRepo=""
	echo "Enter desired template repository or choose no template"
	PS3='Select an option and press Enter: '
	templateOptions=("PRJ20999_TestRepo" "AutoGitRepo" "XNET_LIB" "NO TEMPLATE" "CUSTOM")
	select opt in "${templateOptions[@]}"
	do
		case $opt in
			"PRJ20999_TestRepo")
			templateRepo="PRJ20999_TestRepo"
			break
			;;
			"AutoGitRepo")
			templateRepo="AutoGitRepo"
			break
			;;
			"XNET_LIB")
			templateRepo="XNET_LIB"
			break
			;;
			"NO TEMPLATE")
			templateRepo=""
			break
			;;
			"CUSTOM")
			read -p "Name of Desired Template Repository: " templateRepo
			templateRepo=${templateRepo}
			break
			;;
			*) echo "invalid option";;
		esac
	done

	# Get the new repo name and description

	repoName=""
	repoDesc=""
	while true
	do
		read -p "New Repo Name (PRJ#####_ShortDesc): " repoName
		if [[ -n  "$repoName" ]]; then
			read -p "Repo Description: " repoDesc
			echo
			echo "Repository Name: $repoName"
			echo "Repository Description: $repoDesc"
			echo
			read -p "Confirm Repo Details (y)es or (n)o: " confirm
			if [ "$confirm" = "y" ]; then
				break;
			fi
		else
			echo "Repository name cannot be empty, enter valid repository name"
		fi
	done


	# Call to get the team ids if needed for reference
	# curl -X GET -u ${githubUser}:${githubPass} https://api.github.com/orgs/$organization/teams| grep -w id

	# Can technically get the ID programmatically from calling https://api.github.com/orgs/$organization/teams
	# See https://developer.github.com/v3/teams/ for more details

	# Enable case insensitive matching
	shopt -s nocasematch

	# Loop to get desired teams to add to repository
	githubTeamID=0
	#declare -a arr_teams
	#declare -a arr_teams_access
	team_setting_default="preset"
	access_type=""

	read -p "Default team options or create custom [preset/custom] (default: ${team_setting_default}): " team_setting

	if [ "${team_setting:-${team_setting_default}}" = "preset" ]; then
		arr_teams+=("2211978")
		arr_teams+=("2122419")
		arr_teams+=("3620849")
		arr_teams_access=("push" "push" "pull")
	else
		while true
		do
			read -p "Enter new team (y)es or (n)o: " newTeam
			if [ "$newTeam" != "y" ]; then
				break;
			else
				echo
				read -p "Team [Electrical/LibKicad/PCBKicad/Software/Employees](default ${defaultTeam}): " githubTeam
			fi
			if [ "${githubTeam:-${defaultTeam}}" = "Electrical" ]; then
				githubTeamID=2211978
			elif [ "${githubTeam:-${defaultTeam}}" = "LibKicad" ]; then
				githubTeamID=2633419
			elif [ "${githubTeam:-${defaultTeam}}" = "PCBKicad" ]; then
				githubTeamID=2633310
			elif [ "${githubTeam:-${defaultTeam}}" = "Software" ]; then
				githubTeamID=2122419
			elif [ "${githubTeam:-${defaultTeam}}" = "Employees" ]; then
				githubTeamID=3620849
			else
				echo "INVALID TEAM ENTRY, CHOOSE FROM LIST"
				echo
				continue
			fi
			
			read -p "Team Access Type [Read/Write](default: Write): " accessType
			
			if [ "${accessType:-${defaultAccess}}" = "Write" ]; then
				access_type="push"
			elif [ "${accessType:-${defaultAccess}}" = "Read" ]; then
				access_type="pull"
			else
				echo "INVALID TEAM ACCESS TYPE, CHOOSE FROM LIST"
				echo
				continue
			fi
			
			arr_teams+=("$githubTeamID")
			arr_teams_access+=("$access_type")
			
		done
	fi

	# Disable case insensitive matching
	shopt -u nocasematch

	read -p "Set Topic [project/library](default ${defaultTopic}): " repoTopic
	
	#Get the default branch to set
	
	echo "Enter desired default branch"
	PS3='Select an option and press Enter: '
	branchOptions=("master" "develop")
	select opt in "${branchOptions[@]}"
	do
		case $opt in
			"master")
			defaultBranch="master"
			break
			;;
			"develop")
			defaultBranch="develop"
			break
			;;
			*) echo "invalid option";;
		esac
	done
	
fi

if [ ! -z "${templateRepo}" ]; then

	# 1. Clone the template repo
	echo
	echo \################################################
	echo \# CLONING TEMPLATE REPO $templateRepo
	echo \################################################
	echo

	git clone git@github.com:$organization/$templateRepo.git

	if [ ! -d "${templateRepo}" ]; then
		echo
		echo "!!!!!!!!!!!!!!!!!!!!ERROR!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		echo "! Failed to clone repository $templateRepo from GitHub "
		echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		echo 
		exec bash
		exit 1
	fi

	cd $templateRepo

fi
#Based on https://gist.github.com/robwierzbowski/5430952

# Current directory address
currentDir=${PWD##*/}

# Get user github token if available, else prompt user for token

OAuthToken=$(git config --global user.pac)

if [ -z "${OAuthToken}" ]; then
	echo
	echo \################################################
	echo \# ENTER REQUIRED INFO
	echo \################################################
	echo
	read -s -p "GitHub Personal Access token: " OAuthToken
fi

echo

if [ -z "${templateRepo}" ]; then
	mkdir $repoName
	cd $repoName
	currentDir=${PWD##*/}
fi

# Create a new repository on ArxtronTech
# Default private, has_issues, has_downloads, has_wiki
echo
echo \################################################
echo \# CREATING REPO ON GITHUB
echo \################################################
echo
httpResponse=$(\
                curl --write-out "%{http_code}\n" --silent --output /dev/nullcurl\
                -H "Authorization: token ${OAuthToken}" https://api.github.com/orgs/$organization/repos\
                -d "{\"name\": \"${repoName}\",\
                \"description\": \"${repoDesc}\",\
                \"private\": true,\
                \"has_issues\": true,\
                \"has_downloads\": true,\
                \"has_wiki\": true";\
              )
if [ "$httpResponse" != "201" ]; then # HTTP response code
  echo "Failed to create repository $repoName on GitHub"
  echo "HTTP Response $httpResponse"
  OnError 1
  return 0
else
  echo "OK"
fi

# Add topic of repo
echo
echo \################################################
echo \# ADDING TOPIC TO GITHUB REPO
echo \################################################
echo
API_VER_ACCEPTS="application/vnd.github.mercy-preview+json"
httpResponse=$(\
                curl --write-out "%{http_code}\n" --silent --output /dev/nullcurl\
                -H "Authorization: token ${OAuthToken}" https://api.github.com/repos/$organization/$repoName/topics\
                -d "{\"names\": [\"${repoTopic:-${defaultTopic}}\"]}"\
                -H "Accept:$API_VER_ACCEPTS"\
                -X PUT\
              )

if [ "$httpResponse" != "200" ]; then # HTTP response code
  echo "Failed to add topics to $repoName on GitHub"
  echo "HTTP Response $httpResponse"
  OnError 2
  return 0
else
  echo "OK"
fi

# Add team
# Default permission = push (write access) and pull (read access) for employees
echo
echo \################################################
echo \# ADDING TEAM TO GITHUB REPO
echo \################################################
echo
API_VER_ACCEPTS="application/vnd.github.hellcat-preview+json"

for ((i=0;i<${#arr_teams[@]};++i))
do
	
	httpResponse=$(\
					curl --write-out "%{http_code}\n" --silent --output /dev/nullcurl\
					-H "Authorization: token ${OAuthToken}" https://api.github.com/teams/${arr_teams[i]}/repos/$organization/$repoName\
					-d "{\"permission\": \"${arr_teams_access[i]}\"}"\
					-H "Accept:$API_VER_ACCEPTS"\
					-X PUT\
				  )
	if [ "$httpResponse" != "204" ]; then # HTTP response code
	  echo "Failed to add team $githubTeam to $repoName on GitHub"
	  echo "HTTP Response $httpResponse"
	  OnError 2
	  return 0
	else
	  echo "OK"
	fi
done

echo
echo \################################################
echo \# LOCAL REPO PREP
echo \################################################
echo

# Remove old git folder
#( find . -type d -name ".git" \
#  && find . -name ".gitignore" \
#  && find . -name ".gitmodules" ) | xargs rm -rf
rm .git -rf

# Create a new git repo
git init

# Stage cloned files to the new repo
git add .
# Make the initial commit
date=$(date '+%Y-%m-%d')

if [ ! -z "${templateRepo}" ] && [ -d "../${templateRepo}" ]; then
	git commit -m "Initial Commit cloned from $templateRepo on $date"
else
	git commit --allow-empty -m "Initial Commit"
fi

# Add the new origin
git remote add origin git@github.com:$organization/$repoName.git
# Checkout a develop branch
git checkout -b develop
# Push repo to GitHub
git push -u --all origin

httpResponse=$(\
					curl --write-out "%{http_code}\n" --silent --output /dev/nullcurl\
					-H "Authorization: token ${OAuthToken}" https://api.github.com/repos/$organization/$repoName\
					-d "{\"default_branch\": \"${defaultBranch}\"}"\
					-H "Accept:$API_VER_ACCEPTS"\
					-X PATCH\
				  )
	if [ "$httpResponse" != "200" ]; then # HTTP response code
	  echo "Failed to set default branch"
	  echo "HTTP Response $httpResponse"
	  OnError 2
	  return 0
	else
	  echo "OK"
	fi

cd ..
mv $currentDir $repoName
cd $repoName
echo
echo \################################################
echo \# SCRIPT FINISHED SUCCESSFULLY
echo \# SET TO WORK ON DEVELOP BRANCH
echo \################################################
echo 
exec bash
sleep 4