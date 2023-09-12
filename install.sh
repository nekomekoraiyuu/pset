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
check_path () {
ideal_path="/usr/local/bin"
if [ "$(grep -o ":" <<< "$PATH" | wc -l)" -lt 1 ];
	then
		ideal_path="$(cut -d ":" -f "1" <<< "$PATH")"
	else
		IFS=':'
		for i in $PATH
			do
				local total_path=("$total_path" "$i")
				if [ "$i" == "$ideal_path" ];
					then
						local ideal_path_exists="indeed"
				fi
			done
		unset i
		IFS=$'\n'
		if [ "${ideal_path_exists:-doesnt_bwuh}" ];
			then
				ideal_path="$(fzf -s <<< "${total_path[*]}")" || exit 1
				unset IFS
		fi
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
						j=$((j+1))
						echo -e "!>$i Is not installed!"
				fi
				if [ "${#required_deps[@]}" -ne "$j" ];
					then
						echo '! Please install the required dependencies and re-execute the script!' && exit 2
				fi
			done
		# Now lets invoke check path function
		check_path
		# Now Actually "install" the script
		if [ "$install_type" == "local" ];
			then
				cp $CURSPATH/pset.sh $ideal_path
			else
			# To do
				:
		fi
fi

