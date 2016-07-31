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

if [ -d $1 ]; then
	PROJECT=`basename $1`
	case $DO in
		"INIT")
			cd $PROJECT
			git init
			git remote add origin git@gitlab:uninth/${PROJECT}.git
			git add -A .
			git commit -m 'initial commit'
			git push -u origin master
		;;
		"UPDATE")
			cd $PROJECT
			git add -A . *
			git commit -m 'added/moved some files'
			git push -u origin master
		;;
	esac
else
	echo usage "$0 [-u] NEW-git-project-directory"
	exit
fi
