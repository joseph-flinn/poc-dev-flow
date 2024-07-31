createCommit () {
  echo "[+] Creating $1"

  echo "change $1" > src/$1.txt

  git add .
  git commit -m "change $1"
}

createReleaseBranch () {
  git switch -c release/$1
  git switch main
}

cherryPickLatestCommit () {
  latestHash=$(git log -n 1 --pretty=format:"%H")

  git switch release/$1
  git cherry-pick -x "$latestHash"
  git switch main
}

createTag () {
  git switch release/$1
  git tag $2 -m "tag for release/$1"
  git switch main
}

simulate () {
  echo "[*] Starting simulation"

  echo "[+] Creating ./src"
  mkdir src

  createCommit "A"
  createReleaseBranch "1"

  createCommit "B"
  cherryPickLatestCommit "1"
  createTag "1" "v1.0.0"

  createCommit "C"

  createCommit "D"
  createReleaseBranch "2"

  createCommit "E"

  createCommit "F"
  cherryPickLatestCommit "2"
  createTag "2" "v1.1.0"

  createCommit "G"

  createCommit "H"
  createReleaseBranch "3"

  createCommit "I"
  cherryPickLatestCommit "2"
  createTag "2" "v1.1.1"
  
  createCommit "J"
  cherryPickLatestCommit "3"
  createTag "3" "v1.2.0"

  createCommit "K"
  createCommit "L"
}


clean () {
  git switch main 
  git reset --hard origin/main
  git branch --list "release/*" | xargs git branch -D
  git tag --list "v*" | xargs git tag -d
}


help () {
  echo "sim - Simulate a development flow in a git repo"
  echo ""
  echo "Commands"
  echo "  run|r"
  echo "    Run the simulation"
  echo "  clean|c"
  echo "    Hard reset of the repo to current remote HEAD"
  echo "  print|p"
  echo "    Pretty print the branches/tags in the simulation"
  echo "  help|h"
  echo "    Print this help menu"
  echo ""
}


echo "[*] SIM Scalable RCs"
cd poc-rc-stabilization

case $1 in
  "run"|"r") simulate ;;
  "clean"|"c") clean ;;
  "print"|"p") git log --graph --oneline --all ;;
  "help"|"h") help ;;
  *) echo "[!] Unrecognized command $1" ;;
esac


echo "----------"
