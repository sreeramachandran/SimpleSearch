#!/bin/bash

current_git_branch() {
     git rev-parse --abbrev-ref HEAD
}

last_tag_version(){
	git describe --abbrev=0 --tags
}


hubj_deployment(){
	echo "*** Deployment On Hubj Started ***"
	exit 1
}


#creating new release branch

create_new_release_branch(){
	echo "*** Creating New Release Branch ***"
	LATEST_RELEASE_BRANCHES=( $(git branch --sort=-committerdate | grep "release") )
	#replace . with space so can split into an array
	VERSION_BITS_BRANCHES=(${LATEST_RELEASE_BRANCHES//./ })

	#get number of parts and increase last one by 1
	VNUM1=${VERSION_BITS_BRANCHES[0]}
	VNUM2=${VERSION_BITS_BRANCHES[1]}
	VNUM2=$((VNUM2+1))

	echo "*** Latest Release Version Branch From Git Is ***" $LATEST_RELEASE_BRANCHES

	NEW_BRANCH_NAME="$VNUM1.$VNUM2" 
	echo "***Suggested New Version Is " $NEW_BRANCH_NAME
	check_release_branch
	read -p "Continue Your Process With Creating Branch (Y/N)?" CONTINUE
	if [ "$CONTINUE" = "Y" ]; then
		git checkout -b $NEW_BRANCH_NAME master
		echo "***Branch Created ***"
	else
    	echo "*** Branching Process Aborted ***"
    	exit 1
 		fi

	#NEW_BRANCH_NAME2="$VNUM1_$VNUM2"
	#echo "*** Suggested New Release Branch ***" $NEW_BRANCH_NAME
	
}
check_release_branch(){
	if [ `git branch --list $NEW_BRANCH_NAME` ]
then
   echo "Branch name $branch_name already exists."
   
   exit 1
fi
}

# tagging and release process master master master

tagging_process() {

	echo "*** Tagging Process Started ***"

		LAST_TAG_VERSION=$(last_tag_version)
		
		echo "Last Tag Version " $LAST_TAG_VERSION
		#replace . with space so can split into an array
		VERSION_BITS=(${LAST_TAG_VERSION//./ })

		#get number parts and increase last one by 1
		VNUM1=${VERSION_BITS[0]}
		VNUM2=${VERSION_BITS[1]}
		VNUM3=${VERSION_BITS[2]}
		VNUM4=${VERSION_BITS[3]}
		VNUM4=$((VNUM4+1))
		#create new tag
		NEW_TAG_VERSION="$VNUM1.$VNUM2.$VNUM3.$VNUM4"

		echo "Updating Tag Version $LAST_TAG_VERSION to $NEW_TAG_VERSION"

		read -p "Continue Your Process With Creating Tag (Y/N)?" CONTINUE

		if [ "$CONTINUE" = "Y" ]; then
			#get current hash and see if it already has a tag
			GIT_COMMIT=`git rev-parse HEAD`
			NEEDS_TAG=`git describe --contains $GIT_COMMIT`

			#only tag if no tag already (would be better if the git describe command above could have a silent option)
			if [ -z "$NEEDS_TAG" ]; then
    			echo "Tagged with $NEW_TAG_VERSION (Ignoring fatal:cannot describe - this means commit is untagged) "
    			git tag $NEW_TAG_VERSION
    			git push --tags
			else
    			echo "Already a tag on this commit"
			fi

		else
    		echo "*** Tagging Process Aborted ***"
    		exit 1
 		fi

}

CURRENT_BRANCH=$(current_git_branch)

if echo "$CURRENT_BRANCH" | grep 'release'; then
	echo "*** Currently You Are In Release Branch ***";
	echo "***Your Current Git Branch Is ***" $CURRENT_BRANCH;
	#if current release branch has any uncommit changes process is exit.
	if output=$(git status --porcelain) && [ -z "$output" ];then
  		echo "***Working Directory Is clean Continuing With Process****"
  	else 
  		echo "***Commit Your Change Before You Create A Tag***"
  		exit 1
	fi
	zenity --info --text="Make Sure Your Release Branch And Master Or In Sink!" --title="Info!"
	read -p "Continue Your Process With Deployment Or Tagging (D/T)?" CONTINUE
	if [ "$CONTINUE" = "D" ]; then
		hubj_deployment
	elif [ "$CONTINUE" = "T" ];then
		tagging_process
	else
		echo "*** Exit Process ***";
	fi
elif echo "$CURRENT_BRANCH" | grep 'master'; then
	echo "***Currently You Are In master Branch Continue With New Release Process ***"
	read -p "Continue Your Process With New Release Branch (y/n)?" CONTINUE
	if [ "$CONTINUE" = "y" ]; then
		create_new_release_branch
	else
		echo "*** Aborted New Release Branch ***"
		exit 1
	fi
	
else
	echo "*** Currently You Are In Other Branch Checkout To Release Branch And Contine With Process***";
	exit 1
fi


