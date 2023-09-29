#!/bin/bash --norc --noprofile
# Enable extglob
shopt -s extglob
# -- variables
### Color Variables please
CRESET='\e[0m'
CGREEN='\e[92m'
CYELLOW='\e[93m'
CYANN='\e[96m'
CRED='\e[91m'
###
# we need a ifs backup!
IFSBAK="${IFS}"
# IFS is a newline indeed
IFS=$'\n'
CUR_PROC=$(ps -o comm= $PPID)
SUPPORTED_SHELLS=(
"bash"
)
PSETCONF="$HOME/.config/pset"
confdirs=(
	"$PSETCONF"
	"$PSETCONF/process_configs"
	"$PSETCONF/process_configs/$CUR_PROC"
)
setdir="${confdirs[@]:2:3}"
procdir=(
$setdir/{current_vars,current_cmds,temp_restore}
)
# -- Functions
#HELP!!!!!!!!
pset_help () {
	echo -e "PSET HELP (TODO)"
}
printout () {
case ${1} in
	-i | --info)
		echo -e "${CYANN}${2}${CRESET}" >&1
	;;
	-e | --error)
		echo -e "${CYELLOW}${2}${CRESET}" 1>&2
		exit "${3:-"3"}"
		;;
	*)
		echo "${FUNCNAME[0]}: invalid argument: ${1}!" 1>&2
		exit 6
		;;
esac
}
# Empty arg checking function
check_dir () {
	# check if pset config dir exists
	# if not then create a new config dir
	for f in "${confdirs[@]}"
		do
			if [ ! -d "$f" ];
				then
					mkdir -p "$f"
			fi
		done
		# Create some files if they dont exist
	for i in "${procdir[@]}"
		do
			if [ ! -f "$i" ];
				then
					(cd "$setdir" && touch "${i##*/}")
			fi
		done
}
pset_set () {
	# Check if arg empty
		if [ -z "${1}" ];
			then
				printout -e "${0##*/}: ${FUNCNAME[0]}: Argument empty!"
		fi
		if grep -qoP '(^|\s+)--include-quote($|\s+)' <<< "${EXTRA_ARGS[@]}";
			then
				local quoteincluded='"'
		fi
	# Pattern checking
	if ! grep -qoP '^[\w]+=.*' <<< "${1}";
		then
		 printout -e "${0##*/}: ${FUNCNAME[0]}: Invalid variable pattern: ${1}!"
	fi
		# Uh need to remove some stuff first
		local varname=$(grep -oP '^[\w]+=' <<< "${1}")
		local delimname=$(grep -oP '(?<=\w=).*' <<< "${1}")
		if grep -qoP "${varname}" < "${procdir[@]:0:1}";
			then
				sed -i "s/^${varname}.*/${varname}${quoteincluded:-}${delimname}${quoteincluded:-}/" "${procdir[@]:0:1}" 
			else
				# To do
				echo "${varname}${quoteincluded:-}${delimname}${quoteincluded:-}" >> "${procdir[@]:0:1}" 
		fi
		printout -i "${0##*/}: ${FUNCNAME[0]}: Set Successful For: '${1}'!"
}
# check if current shell is in supported shell variables
if [[ ! "${SUPPORTED_SHELLS[@]}" =~ (^| )${CUR_PROC}($| ) ]];
	then
		echo -e ">! Current process $CUR_PROC isn't in the supported shell list!\nPlease make a git issue to add your shell to the supported list~"
		exit 1
fi
# Now check if files exist
check_dir
# -- MAIN
# Print Help Message If No args were specified
if ! (( $# ));
	then
		pset_help
fi
# Parse arguments
for (( i = 0; i < $#; i += ${k:-2} ))
	do
		case "${@:i+1:i+1}" in
			-x?(q) | --set)
				# Argument check
					if grep -qoP "q" <<< "${@:i+1:i+1}";
						then
							EXTRA_ARGS+="--include-quote"
					fi
					pset_set "${@:i+2}"
				;;
		# --set arg end
			-h | --help)
			# Help command
			 pset_help
			 ;;
			* | -* | --*)
				echo -e "${0##*/}: Invalid argument: ${1}!"
			;;
			esac
	#	fi
	done
