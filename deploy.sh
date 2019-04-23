#!/bin/bash

current_git_branch() {
     git rev-parse --abbrev-ref HEAD
}

last_tag_version(){
	git describe --abbrev=0 --tags
}


hubj_release(){
	echo "*** Release On Hubj Started Opening URLS***"
	xdg-open https://console.cloud.google.com/storage/browser/gateway_builds
	exit 1
}


#creating new release branch

create_new_release_branch(){
	
	echo "*** Creating New Release Branch ****"
	read -p 'Enter New Release Branch Name: ' newreleasebranchname
	git checkout -b $newreleasebranchname master
	check_release_branch
	read -p "Continue Your Process With Tagging (y/n)?" CONTINUE
	if [ "$CONTINUE" = "y" ]; then
		new_branch_tagging_process
	else
		echo "*** Exit Process ****";
	fi
}


check_release_branch(){
	if [ `git branch --list $NEW_BRANCH_NAME` ]; then
      echo "WARN: Branch $branch_name already exists."
      exit 1
    fi
}

pull_master(){
	git pull origin master
}

pull_current_git_branch(){
	git pull origin CURRENT_BRANCH
}

check_previous_tag_version_on_origin(){
	LAST_TAG_VERSION=$(last_tag_version)
	echo "Last Tag Is >>> " $LAST_TAG_VERSION
	var=$(git ls-remote --tags origin | grep "$LAST_TAG_VERSION")
	echo "Number is" $var
	if [ -z "$var" ]
	then
      echo "\$var is empty"
	else
      echo "\$var is NOT empty"
	fi

}

# tagging and release process

new_branch_tagging_process() {

	echo "INFO : New release branch tagging process started"

		read -p "INFO :Continue Your Process With Creating New Release Version Tag (Y/N)?" CONTINUE

		if [ "$CONTINUE" = "Y" ]; then
			read -p 'Enter New Release Release Branch Tag Name: ' newreleasebranchtagname
			echo $newreleasebranchtagname
			git tag $newreleasebranchtagname
			git push --tags

		else
    		echo "INFO: new release branch tagging process aborted"
    		exit 1
 		fi

}

# tagging and release process

tagging_process() {

	echo "INFO: tagging process started"

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

		read -p "INFO: Continue Your Process With Creating Tag (Y/N)?" CONTINUE

		if [ "$CONTINUE" = "Y" ]; then
			#get current hash and see if it already has a tag
			GIT_COMMIT=`git rev-parse HEAD`
			NEEDS_TAG=`git describe --contains $GIT_COMMIT`

			#only tag if no tag already (would be better if the git describe command above could have a silent option)
			if [ -z "$NEEDS_TAG" ]; then
    			echo "Tagged with $NEW_TAG_VERSION (Ignoring fatal:cannot describe - this means commit is untagged) "
    			git tag $NEW_TAG_VERSION
    			git push origin $NEW_TAG_VERSION
			else
    			echo "WARN: already a tag on this commit"
			fi

		else
    		echo "INFO: tagging process aborted"
    		exit 1
 		fi

}

CURRENT_BRANCH=$(current_git_branch)

if echo "$CURRENT_BRANCH" | grep 'release'; then

	echo "WARN: currently you are in release branch ->" $CURRENT_BRANCH;
	#If current release branch has any uncommit changes process is exit.
	if output=$(git status --porcelain) && [ -z "$output" ];then
  		echo "INFO: working directory is clean continuing with process"
  	else 
  		echo "WARN: commit and push your changes before creating tag"
  		exit 1
	fi

	#Alert to pull changes from master for creating new tag/release 
	zenity --info --text="ALERT: make sure your release branch and master or in sink!" --title="ALERT:!"
	read -p "INFO: pull current branch for tagging (Y/N)" CONTINUE
	if [ "$CONTINUE" = "Y" ]; then
		pull_current_git_branch
	fi
	echo "INFO: your current branch is upto date with master"
	echo "INFO: checking previous tag is pushed or not"
	check_previous_tag_version_on_origin
	read -p "INFO: continue your process with release or tagging (R/T)?" CONTINUE
	if [ "$CONTINUE" = "R" ]; then
		hubj_release
	elif [ "$CONTINUE" = "T" ];then
		tagging_process
	else
		echo "INFO: process aborted";
	fi
elif echo "$CURRENT_BRANCH" | grep 'master'; then
	echo "INFO: current branch is :" $CURRENT_BRANCH
	echo "INFO: pulling master code....."
	pull_master
	read -p "INFO: continue your process by creating new release branch (y/n)?" CONTINUE
	if [ "$CONTINUE" = "y" ]; then
		create_new_release_branch
	else
		echo "INFO: aborted release branch setup"
		exit 1
	fi
	
else
	echo "INFO: your branch is different from release and master";
	exit 1
fi


