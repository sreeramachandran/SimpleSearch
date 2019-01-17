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

	CURRENT_BRANCH=$(current_git_branch)

if [[ "$CURRENT_BRANCH" != "master" ]]; then
  echo 'Aborting script';
  exit 1;
fi

echo 'Do stuff';


}


# tagging and release process

tagging_process() {

	echo "*** Tagging Process Started ***"

	if output=$(git status --porcelain) && [ -z "$output" ];then
  		echo "***Working Directory Is clean Continuing With Process****"

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
    			echo "Tagged with $NEW_TAG_VERSION (Ignoring fatal:cannot describe - this means commit is untaggedz) "
    			git tag $NEW_TAG_VERSION
    			git push --tags
			else
    			echo "Already a tag on this commit"
			fi

		else
    		echo "*** Tagging Process Aborted ***"
    		exit 1
 		fi

		#read -p 'Enter Your New Tag Version: ' newTagVersion
		#echo "New Tag Verion Is " $newTagVersion
	else 
  		echo "***Commit Your Change Before You Create A Tag***"
  		exit 1
	fi
}



CURRENT_BRANCH=$(current_git_branch)

if echo "$CURRENT_BRANCH" | grep 'release'; then
	echo "*** Currently You Are In Release Branch ***";
	echo "***Your Current Git Branch Is ***" $CURRENT_BRANCH;
	read -p "Continue Your Process With Deployment Or Tagging (D/T)?" CONTINUE
	if [ "$CONTINUE" = "D" ]; then
		create_new_release_branch
	else
		tagging_process
	fi
else
	echo "*** Currently You Are In Other Branch Checkout To Release Branch And Contine With Process***";
	exit 1
fi