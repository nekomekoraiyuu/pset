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
PSETCONF="~/.config/pset"
confdirs=(
	"$PSETCONF"
	"$PSETCONF/process_configs"
	"$PSETCONF/process_configs/$CUR_PROC"
)
setdir="${confdirs[@]:2:3}"
procdir=(
"$setdir/{current_vars,current_cmds,temp_restore}"
)
# -- Functions
printout () {
case ${1} in
	-e | --error)
		echo -e "${2}"
		exit "${3:-"9"}"
	*)
		echo "${FUNCNAME[0]}: invalid argument: ${1}!"
		exit 6
esac
}
# Empty arg checking function
check_arg () {
	if [ ${1:-doesntexist} ];
		then
			if grep -qoP "${2}" <<< "${1}";
				then
					echo 0
				else
				# 2 is not match
					echo 2
			fi
		else
		# Arg empty
			echo 1
	fi
}
check_dir () {
	# Create some files if they dont exist
	for i in "${procdir[@]}"
		do
			if [ -f "$i" ];
				then
					(cd "$setdir" && touch "${i##*/}")
			fi
		done
}
pset_set () {
		# Uh need to remove some stuff first
		local varname=$(grep -op '^[\w]+=.*' <<< "${1}")
		if grep -qo "${varname}" < "${procdir[@]:0:1}";
			then
				sed -i "s/${varname}/${1}" "${procdir[@]:0:1}" 
			else
		fi
}
# check if current shell is in supported shell variables
if [ ! "${SUPPORTED_SHELLS[@]}" =~ \b$CUR_PROC\b ];
	then
		echo -e "\! Current process $CUR_PROC isn't in the supported shell list\!\nPlease make a git issue to add your shell to the supported list\~"
		exit 1
fi
# check if pset config dir exists
# if not then create a new config dir
for f in "${confdirs[@]}"
	do
		if [ ! -d "$f" ];
			then
				mkdir -p "$f"
		fi
	done
# -- MAIN
# Parse arguments
if [ "$#" -ge 1 ];
	then
		for i in "$@"
			do
				case $i in
					-x | --set)
						# Argument check
						case "$(check_arg "${2}" '^[\w]+=.*')" in
							1)
								printout -e "${0##*/}: ${1}: Argument empty\!"
							;;
							2)
								printout -e "${0##*/}: ${1}: Invalid argument\!"
							;;
						esac
						shift 1
				esac
			done
fi

