#!/bin/bash
# PSET : INIT
set -x
# ----- MISC
CURSPATH="$(realpath $0)" && CURSPATH="$(dirname "$CURSPATH")"
CLR_RESET='\e[0m'
CLR_BOLD='\e[1m'
# ----- VARS
temp_current_shell_proc=$(ps -o comm= $PPID)
# this array defines compatible shells
compatible_shell=(
	"bash"
)
# Required dependencies
required_deps=(
	"fzf"
	"git"
)
# ----- FUNCTIONS
# 
parse_arg () {
	:
}
# A function to check if installing from cloned git repo or Online
check_inst () {
	if [ "$(git -C "$CURSPATH" rev-parse 2>/dev/null; echo "$?")" -eq 0 ];
		then
			# 0 for local git repo install
			echo "0" && return
		else
			# 1 for online git repo
			echo "1" && return
	fi
}
# ------ MAIN
# Relaunch script with required args
if [ ! "${1}" == "--relaunch-args" ];
	then
		echo "> Launching with required args"
		env -i bash --norc --noprofile -- ${0} --relaunch-args "$temp_current_shell_proc" ${@:1}
	else
		# current shell process
		current_shell_proc=${2}
		# Exclude the arguments
		set -- ${@:2}
		# Print header
		echo -e "${CLR_BOLD}-- PSET::INSTALL --${CLR_RESET}"
		echo -e ">Current Shell Process: ${CLR_BOLD}$current_shell_proc${CLR_RESET}"
		# Check if current shell process is in shell compat array
		if [ ! "$(grep -Po "\b${current_shell_proc}\b" <<< "${compatible_shell[@]}")" ];
			then
				echo -e ">Current Shell ${current_shell_proc} isn't in the shell script compatibility list!\n>Please make a github issue to add your current shell to the list!"
				exit 1
		fi
		# Check installation type
		if [ "$(check_inst)" == "0" ];
			then
				echo -e ">Installing from local git repo at: ${CURSPATH}"
				install_type="local"
			else
				echo -e ">Installing script from online git repo"
				install_type="online"
		fi
		# Check for dependencies
		for i in ${required_deps[@]}
			do
				if [ ! "$(command -v "$i")" ];
					then
						echo -e "!>$i Is not installed!"
						exit 2
				fi
			done
		# Now Actually "install" the script
		if [ "$install_type" == "local" ];
			then
				cp $CURSPATH/pset.sh /bin/pset
			else
			# To do
				:
		fi
fi

