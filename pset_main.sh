#!/bin/bash --norc --noprofile
# -- variables
# we need a ifs backup!
IFSBAK="${IFS}"
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
# -- Functions
:
pset_set () {
:
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
				mkdir -p "-f"
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
						# place holder func here
						shift 1
				esac
			done
fi

