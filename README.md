# wdiff v1.0
Watching diff output in command numbers.

	Usage: wdiff.sh [-h | --help] [options] [-wd \"wordsDelimiter\"]"
                    [--awk-filter '/RegExp/'] [-i interval]"
                    [-if intFormat] \"shell command\""
				-h, --help         Print this page.
		        -c, --clrscr       Clear screen after each test.
		        -wbo               "Was(became)" output. Difference by default.
		        -wd                Words delimiter.
		        --awk-filter       Regular expression for searching numbers.
		        -i                 Interval (1 default).
		        -if                Interval format. Could be \"s\" - seconds
		                            (default), or \"ms\" - milliseconds.

	Warning! Be careful to put the shell command with arguments in
		the double quotes, else an arguments will be skipped.

	Exit codes:
		        0                  Successfull exit.
		        1                  Error while parsing arguments.
		        2                  Exit code after display this help page.
		        3                  Error while executing target program.
		        4x                 Error while processing output files.
		   		