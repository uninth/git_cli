#!/bin/sh
#
# $Header$
#
#--------------------------------------------------------------------------------------#
# TODO
#
#--------------------------------------------------------------------------------------#

# Create a token with expire date on gitlab.ssi.i2.dk -- write it here

token=xxxxxxxxxxxxxxxxxxxx		# should be replaced with e.g a file and `cat ~/.token`

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

#
# Process arguments
#
DO=INIT

while getopts ui opt
do
case $opt in
	i)	DO=INIT
	;;
	u)	DO=UPDATE
	;;
	*)	echo "usage: $0 [-u] dir"; exit
	;;
esac
done
shift `expr $OPTIND - 1`

if [ "$DO" = "INIT" ]; then
	repo=$1

	test -z $repo && echo "Repo name required." 1>&2 && exit 1

	curl -H "Content-Type:application/json" http://gitlab.ssi.i2.dk/api/v3/projects?private_token=$token -d "{ \"name\": \"$repo\" }"

fi

case `git --version | awk '{ print $3}'` in
	1.9.*)	
		ADD='git add -A . *'
		PUSH='git push -u origin master'
	;;
	1.5.2*)
		ADD='git add . *'
		PUSH='git push origin master'

	;;
	*)	echo "unknown git version: `git --version`"; exit
	;;
esac

if [ -d $1 ]; then
	PROJECT=`basename $1`
	case $DO in
		"INIT")
			cd $PROJECT
			git init
			git remote add origin git@gitlab:uninth/${PROJECT}.git
			${ADD}
			git commit -m 'initial commit'
			${PUSH}
		;;
		"UPDATE")
			cd $PROJECT
			${ADD}
			git commit -m 'added/moved some files'
			${PUSH}
		;;
	esac
else
	echo usage "$0 [-u] NEW-git-project-directory"
	exit
fi
