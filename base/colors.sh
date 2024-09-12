#normal=$(tput sgr0)                        # normal text
__normal=$'\e[0m'              # (works better sometimes)
__bold=$(tput bold)            # make colors bold/bright
__red="$__bold$(tput setaf 1)" # bright red text
__green=$(tput setaf 2)        # dim green text
__fawn=$(tput setaf 3)
__beige="$__fawn"           # dark yellow text
__yellow="$__bold$__fawn"   # bright yellow text
__darkblue=$(tput setaf 4)  # dim blue text
__blue="$__bold$__darkblue" # bright blue text
__purple=$(tput setaf 5)
__magenta="$__purple"               # magenta text
__pink="$__bold$__purple"           # bright magenta text
__darkcyan=$(tput setaf 6)          # dim cyan text
__cyan="$__bold$__darkcyan"         # bright cyan text
__gray=$(tput setaf 7)              # dim white text
__darkgray="$__bold"$(tput setaf 0) # bold black = dark gray text
__white="$__bold$__gray"            # bright white text

# @function to output color text and then reset back to normal
# @param: string color
# @param: string text
__color() {

	# only has one params then it's just the text
	# output then be done
	if [ -z "$2" ]; then
		echo $1
		exit
	fi

	#assign the color to a variable
	# no text then do nothing
	if [ -z "$1" ]; then exit; fi

	__p_color=__$1

	echo "${!__p_color}$2${__normal}"
}

