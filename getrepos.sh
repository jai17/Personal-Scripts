# Not meant to be run, copy paste commands only?

# Get organization team info
# curl GET -u user:pass https://api.github.com/orgs/Organization/teams

# Get user input
echo
echo \################################################
echo \# ENTER REQUIRED INFO
echo \################################################
echo

read -p "GitHub Username: " githubUser
read -s -p "GitHub Password: " githubPass
echo

# Get organization repos
touch repos.txt

for i in {1..6}
do
    httpResponse=$(\
                    curl --write-out "%{http_code}\n" --silent --output \repos.txt
                    -u ${githubUser}:${githubPass} https://api.github.com/orgs/Organization/repos?page=$i\
                    -X GET\
                  )
    echo "HTTP Response $httpResponse"
    read
done

#teams
for i in {1..3}
do
    httpResponse=$(\
                    curl --write-out "%{http_code}\n" --silent --output \repos.txt
                    -u ${githubUser}:${githubPass} https://api.github.com/orgs/Organization/teams/Software/repos?page=$i\
                    -X GET\
                  )
    echo "HTTP Response $httpResponse"
    read
done

# https://stackoverflow.com/questions/1521462/looping-through-the-content-of-a-file-in-bash
# https://unix.stackexchange.com/questions/134437/press-space-to-continue
API_VER_ACCEPTS="application/vnd.github.hellcat-preview+json"
while read -u 10 i;
do
    httpResponse=$(\
                    curl --write-out "%{http_code}\n" --silent --output /dev/nullcurl\
                    -u ${githubUser}:${githubPass} https://api.github.com/teams/3620848/repos/Organization/$i\
                    -d "{\"permission\": \"admin\"}"\
                    -H "Accept:$API_VER_ACCEPTS"\
                    -X PUT\
                  )
    echo "HTTP Response $httpResponse"
done 10</c/Users/repos_clean.txt
