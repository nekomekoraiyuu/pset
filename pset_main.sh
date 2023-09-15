#!/bin/bash --norc --noprofile
# -- variables
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
printout () {
case ${1} in
	-i | --info)
		echo -e "${2}" >&1
	;;
	-e | --error)
		echo -e "${2}" 1>&2
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
	# Pattern checking
	if ! grep -qoP '^[\w]+=.*' <<< "${1}";
		then
		 printout -e "${0##*/}: ${FUNCNAME[0]}: Invalid variable pattern!"
	fi
		# Uh need to remove some stuff first
		local varname=$(grep -oP '^[\w]+=' <<< "${1}")
		if grep -qo "${varname}" < "${procdir[@]:0:1}";
			then
				sed -i "s/^${varname}.*/${1}/" "${procdir[@]:0:1}" 
			else
				# To do
				echo "${1}" >> "${procdir[@]:0:1}" 
		fi
		printout -i "${0##*/}: ${FUNCNAME[0]}: Set Successfull For: '${1}'!"
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
# Parse arguments
for (( i = 0; i < $#; i += ${k:-2} ))
	do
		case "${@:i+1:i+1}" in
			"-x" | "--set")
				# Argument check
					pset_set "${@:i+2}"
				;;
		# --set arg end
			-h | --help)
			# Help command
			 echo -e "PSET HELP"
			 ;;
			* | -* | --*)
				echo -e "${0##*/}: Invalid argument: ${1}!"
			;;
			esac
	#	fi
	done
