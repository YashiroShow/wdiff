#!/bin/sh

usage() {
	echo ""
	echo "Watching diff output in command numbers."
	echo ""
	echo "\e[1;31mUsage\e[0m: watchdiff.sh [-h | --help] [options] [-wd \"wordsDelimiter\"]"
	echo "                    [--awk-filter '/RegExp/'] [-i interval]"
	echo "                    [-if intFormat] \"shell command\""
	echo ""
	echo "        \e[1;32m-h\e[0m, \e[1;32m--help\e[0m         Print this page."
	echo "        \e[1;32m-c\e[0m, \e[1;32m--clrscr\e[0m       Clear screen after each test."
	echo "        \e[1;32m-wbo\e[0m               \"\e[1;32mWas\e[0m(\e[1;36mbecame\e[0m)\" output. Difference by default."
	echo "        \e[1;32m-wd\e[0m                Words delimiter."
	echo "        \e[1;32m--awk-filter\e[0m       Regular expression for searching numbers."
	echo "        \e[1;32m-i\e[0m                 Interval (1 default)."
	echo "        \e[1;32m-if\e[0m                Interval format. Could be \"s\" - seconds"
	echo "                            (default), or \"ms\" - milliseconds."
	echo ""
	echo "     \e[1;33mWarning\e[0m! Be careful to put the shell command with arguments in"
	echo "      the double quotes, else an arguments will be skipped."
	echo ""
	echo "\e[1;31mExit codes\e[0m:"
	echo "        \e[1;36m0\e[0m                  Successfull exit."
	echo "        \e[1;36m1\e[0m                  Error while parsing arguments."
	echo "        \e[1;36m2\e[0m                  Exit code after display this help page."
	echo "        \e[1;36m3\e[0m                  Error while executing target program."
	echo "        \e[1;36m4x\e[0m                 Error while processing output files."
	echo ""
}

usehelp() {
	echo "Use \"-h\" or \"--help\" to print a help page."
}

# Returns i-index word from an i-index string from file.
# Usage: getWordFromFile "/Path/To/File" StringIndex WordIndex
getWordFromFile() {
	StrIndex=0
	while read LINE
	do
		# Indexing necessary string.
		if [ $StrIndex -ne $2 ]
		then
			StrIndex=$(($StrIndex + 1))
			continue
		fi

		WordIndex=0
		WORDS=$(echo "$LINE" | tr $wd "\n")lt
		for WORD in $WORDS
		do
			if [ $WordIndex -ne $3 ]
			then
				# Indexing necessary word.
				WordIndex=$(($WordIndex + 1))
			else
				break
			fi
		done

		if [ $WordIndex -lt $3 ]
		then
			echo "\e[1;31mError\e[0m! Not enough words in a string."
			exit 4
		fi

		break
	done < "$1"

	if [ $StrIndex -ne $2 ]
	then
		echo "\e[1;31mError\e[0m! Not enough strings in a file."
		exit 4
	fi

	echo "$WORD"
}

# Returns count of i-index string from a file.
# Usage: getWordCount "/Path/To/Count" StringIndex
getWordCount() {
	StrIndex=0
	while read LINE
	do
		if [ $StrIndex -ne $2 ]
		then
			StrIndex=$(($StrIndex + 1))
			continue
		fi

		Res=0
		WORDS=$(echo "$LINE" | tr $wd "\n")
		for Word in $WORDS
		do
			Res=$(($Res + 1))
		done
		break
	done < "$1"

	if [ $StrIndex -lt $2 ]
	then
		echo "\e[1;31mError\e[0m! Not enough strings in a file."
		exit 4
	fi

	echo $Res
}

if [ "$#" -eq 0 ]
then
	usehelp
	exit 2
fi

clrscr=0
wbo=0
int=1
intf="s"
wd=" []:\t"
awk_filter='/^([0-9]+)([.,]?)([0-9]*)$/'

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
	elif [ "$1" = "-c" ]
	then
		clrscr=1
	elif [ "$1" = "--clrscr" ]
	then
		slrscr=1
	elif [ "$1" = "-wbo" ]
	then
		wbo=1
	elif [ "$1" = "-wd" ]
	then
		wd=$2
		shift
	elif [ "$1" = "--awk-filter" ]
	then
		awk_filter=$2
		shift
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
		echo "   \e[1;31mError\e[0m: unknown parameter - \e[1;4;33m${1}\e[0m!"
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
	$1 > "/tmp/wdiff.pout1"
	if [ $? -ne 0 ]
	then
		echo "\e[1;31mError\e[0m! Target program had been crashed."
		exit 3
	fi
	sleep ${int}s
	if [ $clrscr -eq 1 ]
	then
		clear
	fi
	$1 > "/tmp/wdiff.pout2"
	if [ $? -ne 0 ]
	then
		echo "\e[1;31mError\e[0m! Target program had been crashed."
		exit 3
	fi
	
	# Handling output...
	
	StrCount1=$(wc -l < "/tmp/wdiff.pout1")
	StrCount2=$(wc -l < "/tmp/wdiff.pout2")
	if [ $StrCount1 -ne $StrCount2 ]
	then
		echo "\e[1;31mError\e[0m! Previous programs' output differs from current one."
		exit 40
	fi

	while [ $StrCount1 -ne 0 ]
	do
		WordCount1=$(getWordCount "/tmp/wdiff.pout1" $(($StrCount2 - $StrCount1)))
		if [ $? -eq 4 ]
		then
			echo "$WordCount1"
			exit 42
		fi

		WordCount2=$(getWordCount "/tmp/wdiff.pout2" $(($StrCount2 - $StrCount1)))
		if [ $? -eq 4 ]
		then
			echo "$WordCount2"
			exit 43
		fi

		if [ $WordCount1 -ne $WordCount2 ]
		then
			echo "\e[1;31mError\e[0m! Previous programs' output differs from current one."
			exit 41
		fi

		while [ $WordCount1 -ne 0 ]
		do
			Word1=$(getWordFromFile "/tmp/wdiff.pout1" $(($StrCount2 - $StrCount1)) $(($WordCount2 - $WordCount1)))
			if [ $? -eq 4 ]
			then
				echo "$Word1"
				exit 44
			fi

			Word2=$(getWordFromFile "/tmp/wdiff.pout2" $(($StrCount2 - $StrCount1)) $(($WordCount2 - $WordCount1)))
			if [ $? -eq 4 ]
			then
				echo "$Word2"
				exit 45
			fi

			AWK=$(echo "$Word1" | awk $awk_filter)
			if [ "$AWK" = "" ]
			then
				printf "%s " "$Word1"
			else
				if [ "$Word1" != "$Word2" ]
				then
					if [ $wbo -eq 1 ]
					then
						printf "\e[1;32m%s\e[0m(\e[1;36m%s\e[0m) " "$Word2" "$Word1"
					else
						diff=$(echo "$Word2 - $Word1" | bc -l)
						printf "\e[1;32m%s\e[0m " "$diff"
					fi
				fi
			fi

			WordCount1=$(($WordCount1 - 1))
		done

		printf "\n"

		StrCount1=$(($StrCount1 - 1))
	done
done
