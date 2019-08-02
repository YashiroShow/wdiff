#!/bin/sh

usage() {
	echo "Watching diff output in command numbers."
	echo "Usage: watchdiff.sh [options] [-i int] [-if format] \"shell command\""
	echo "        -i              interval (1 default)."
	echo "        -if             interval format. Could be \"s\" - seconds"
	echo "                         (default), or \"ms\" - milliseconds."
	echo "        -r              do not use thousands separator."
	echo "        -h, --help      print this page."
}

usehelp() {
	echo "Use \"-h\" or \"--help\" to print a help page."
}

if [ "$#" -eq 0 ]
then
	usage
	exit 2
fi

int=1
intf="s"
thsep=","

if [ "$1" = "-h" ]
then
	usage
	exit 2
elif [ "$1" = "--help" ]
then
	usage
	exit 2
fi

while [ "$#" -ne 1 ]
do
	if [ "$1" = "-h" ]
	then
		usage
		exit 2
	elif [ "$1" = "--help" ]
	then
		usage
		exit 2
	elif [ "$1" = "-r" ]
	then
		thsep=""
	elif [ "$1" = "-i" ]
	then
		if [ $2 -gt 0 ]
		then
			int=$2
			shift
		else
			echo "   \e[1;31mError\e[0m: interval must be greater than zero!"
			usehelp
			exit 1
		fi
	elif [ "$1" = "-if" ]
	then
		case $2 in
			"s") intf=$2																;;
			"ms") intf=$2																;;
			*) echo "   \e[1;31mError\e[0m: wrong interval format!"; usehelp; exit 1	;;
		esac
		shift
	else
		echo "   \e[1;31mError\e[0m: unknown parameter - \e[1;4;32m${1}\e[0m!"
		usehelp
		exit 1
	fi
	
	shift
done

if [ "$intf" = "ms" ]
then
	int=0$(echo "$int / 1000" | bc -l)
fi

while true
do
	$1 > /tmp/wdiff1.poutput
	sleep ${int}s
	$1 > /tmp/wdiff2.poutput
	
	# Handling info...
	
done

