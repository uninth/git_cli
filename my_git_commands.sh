#!/bin/sh
#
# $Header$
#

################################################################################
# Main
################################################################################

echo=/bin/echo
case ${N}$C in
	"") if $echo "\c" | grep c >/dev/null 2>&1; then
		N='-n'
	else
		C='\c'
	fi ;;
esac

token="unknown"

if [ -f  ~/.token ]; then
	token=`cat ~/.token`
fi

if [ -n "${TOKEN}" ]; then
	token="${TOKEN}"
fi

if [ $token = "unknown" ]; then

	cat <<-EOF

	Sorry, but a git token (gitlab specific?) is required.
	First, create a token on
	http://gitlab.ssi.i2.dk -> profile settings -> access tokens
	and save it, either to ~/.token or the ENV \${TOKEN}

	This is *not secure* but convenient and required.

	So, either do

		export TOKEN="your token"
 	or
		echo "your token" > ~/.token

EOF
	exit 0

fi

#
# Process arguments
#
DO=INIT

while getopts hiu opt
do
case $opt in
	i)	DO=INIT
	;;
	u)	DO=UPDATE
	;;
	*)	echo
		echo "	usage: $0 [-u] dir comment";
		echo "  will try and add 1 to any git tag or set git tag to 1.0-1 first time"
		exit
	;;
esac
done
shift `expr $OPTIND - 1`

case `git --version | awk '{ print $3}'` in
	1.9.*|2.7.*)	
		ADD='git add . '
		PUSH='git push -u origin master'
		echo "git version `git --version` ok"
	;;
	1.5.2*)
		ADD='git add . '
		PUSH='git push origin master'
		echo "git version `git --version` ok"

	;;
	*)	ADD='git add . '
		PUSH='git push -u origin master'
		echo "unknown git version: `git --version`, trying anyway"
	;;
esac

if [ -d $1 ]; then
	PROJECT=`basename $1`
	shift
	case $* in
		"")	COMMENT="added/moved some files"
		;;
		*)	COMMENT="$*"
		;;
	esac
	case $DO in
		"INIT")
			repo=$PROJECT

			test -z $repo && echo "Repo name required." 1>&2 && exit 1

			curl -H "Content-Type:application/json" http://gitlab.ssi.i2.dk/api/v3/projects?private_token=$token -d "{ \"name\": \"$repo\" }"

			cd $PROJECT
			set -x
			git init
			git remote add origin git@gitlab:uninth/${PROJECT}.git
			${ADD}
			git commit -m 'initial commit'
			${PUSH}
			git push origin 1.0-1
		;;
		"UPDATE")
			cd $PROJECT
			VERSION=`git tag 2>/dev/null | sort -n -t'-' -k2,2 | tail -1`
			MAJOR="1"
			MINOR="0"
			PATCH="1"

			case $VERSION in
				"")	echo "No version found"
					VERSION="${MAJOR}.${MINOR}-${PATCH}"
					git tag ${VERSION}
				;;

				*)	echo "Found version: VERSION = ${VERSION}"
					MAJOR=`echo ${VERSION} | awk -F'.' '$1 ~ /^[0-9]+$/ { print $1 }'`
					MINOR=`echo ${VERSION} | sed 's/^.*\.//; s/-.*//' | awk '$1 ~ /^[0-9]+$/ { print $1 }'`
					PATCH=`echo ${VERSION} | awk -F'-' '$NF ~ /^[0-9]+$/ { print $NF }'`
					NEXTP=`echo ${PATCH:=0} +1 | bc`
					echo "current version: ${VERSION}: MAJOR=${MAJOR:="1"} MINOR=${MINOR:="0"} PATCH=${PATCH:="1"}"
					echo "assuming patch update from ${PATCH} to ${NEXTP}"
					VERSION="${MAJOR}.${MINOR}-${NEXTP}"
				;;
			esac

			echo new version: $VERSION
			git tag ${VERSION}
			git push origin ${VERSION}
			${ADD}
			git commit -m "${COMMENT}"
			${PUSH}
		;;
	esac
else
	echo usage "$0 [-u] NEW-git-project-directory"
	exit
fi
