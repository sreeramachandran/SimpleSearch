#!/usr/bin/env bash

current_git_branch() {
     git rev-parse --abbrev-ref HEAD
}

last_tag_version(){
	git describe --abbrev=0 --tags
}


hubj_deployment(){
	echo "*** Deployment On Hubj Started ***"
}


# tagging and release process

tagging_process() {

	echo "*** Tagging Process Started ***"

	if output=$(git status --porcelain) && [ -z "$output" ]; then
  		echo "***Working Directory Is clean Continuing With Process****"
  		CURRENT_BRANCH=$(current_git_branch)
		LAST_TAG=$(last_tag_version)
		echo "Last Tag Version Is " $LAST_TAG
		read -p 'Enter Your New Tag Version: ' newTagVersion
		echo "New Tag Verion Is " $newTagVersion
	else 
  		echo "***Commit Your Change Before You Create A Tag***"
  		exit 1
	fi
}



CURRENT_BRANCH=$(current_git_branch)

if echo "$CURRENT_BRANCH" | grep 'release'; then
	echo "*** Currently You Are In Release Branch ***";
else
	echo "*** Currently You Are In Other Branch Checkout To Release Branch And Contine With Process***";
	exit 1
fi

echo "***Your Current Git Branch Is ***" $CURRENT_BRANCH;


read -p "Continue Your Process With Deployment Or Tagging (D/T)?" CONTINUE

if [ "$CONTINUE" = "D" ]; then
 	hubj_deployment
else
    tagging_process
fi





#CURRENT_BRANCH= git rev-parse --abbrev-ref HEAD
