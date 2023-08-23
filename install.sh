#!/bin/bash
# PSET : INIT
# ----- MISC
CLR_RESET='\e[0m'
CLR_BOLD='\e[1m'
# ----- VARS
temp_current_shell_proc=$(ps -o comm= $PPID)
# this array defines compatible shells
compatible_shell=(
	"bash"
)
# ----- FUNCTIONS
# 
parse_arg () {
	:
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
fi

