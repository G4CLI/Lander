#!/bin/bash

distro=$(cat /etc/*-release | sed -n -e '/^ID=/p')

ncolors=$(tput colors)

if test -n "$ncolors" && test $ncolors -ge 8; then # https://unix.stackexchange.com/questions/9957/how-to-check-if-bash-can-print-colors
	bold="$(tput bold)"
	normal="$(tput sgr0)"
	red="$(tput setaf 1)"
	green="$(tput setaf 2)"
	yellow="$(tput setaf 3)"
else
	bold=""
	normal=""
	red=""
	green=""
	yellow=""
fi

if [[ $distro == *"debian" || $distro == *"ubuntu" || $distro == *"mint" ]]; then
	function ldrInstallDependencies(){
		function ldrInstallPackage(){
			ldrPackageName=$1
			sudo apt -y install $ldrPackageName > ldrLogs/ldrInstallDependencies_stdout.txt 2> ldrLogs/ldrInstallDependencies_stderr.txt
			if [[ $? > 0 ]]; then
				echo "[${red}${bold}X${normal}] Installation for packege '$ldrPackageName' failed, check file ldrLogs/ldrInstallDependencies_stderr.txt for more information."
				exit 1
			else
				echo "[${green}${bold}O${normal}] Successfully installed package '$ldrPackageName'"
			fi
		}

		# ------------------------- MAKE --------------------------

		echo "[${yellow}${bold}?${normal}] Checking GNU Make"
		make --version &> /dev/null
		ldrMAKE=$?
		if [[ $ldrMAKE -eq 127 ]]; then
			if $ldrMode; then
				echo "[${red}${bold}X${normal}] GNU Make not found, do you want to install it using command 'sudo apt -y install make'? [Y/N]"
				read ldrAnswer < /dev/tty
				if [[ ${ldrAnswer,,} == "y" ]]; then
					echo "[${green}${bold}O${normal}] Installing package 'make', please wait, this may take some time."
					ldrInstallPackage "make"
				elif [[ ${ldrAnswer,,} == "n" ]]; then
					echo "[${red}${bold}X${normal}] Stopping script, couldn't install dependencies."
					exit 1
				else
					echo "[${red}${bold}X${normal}] Invalid argument, couldn't install dependencies."
					exit 1
				fi
			elif !$ldrMode; then
				echo "[${green}${bold}O${normal}] Installing package 'make', please wait, this may take some time."
				ldrInstallPackage "make"
			else
				echo "[${red}${bold}X${normal}] Couldn't check install mode, stopping installation."
				exit 1
			fi
		elif [[ $ldrMAKE -eq 0 ]]; then
			echo "[${green}${bold}O${normal}] Package 'make' is already installed!"
		else
			echo "[${red}${bold}X${normal}] Couldn't check dependency 'make', stopping installation."
			exit 1
		fi

		# ---------------------------------------------------------

		# -------------------------- GIT --------------------------

		echo "[${yellow}${bold}?${normal}] Checking GIT"
		git --version &> /dev/null
		ldrGIT=$?
		if [[ $ldrGIT -eq 127 ]]; then
			if $ldrMode; then
				echo "[${red}${bold}X${normal}] GIT not found, do you want to install it using command 'sudo apt -y install git'? [Y/N]"
				read ldrAnswer < /dev/tty
				if [[ ${ldrAnswer,,} == "y" ]]; then
					echo "[${green}${bold}O${normal}] Installing package 'git', please wait, this may take some time."
					ldrInstallPackage "git"
				elif [[ ${ldrAnswer,,} == "n" ]]; then
					echo "[${red}${bold}X${normal}] Stopping script, couldn't install dependencies."
					exit 1
				else
					echo "[${red}${bold}X${normal}] Invalid argument, couldn't install dependencies."
					exit 1
				fi
			elif !$ldrMode; then
				echo "[${green}${bold}O${normal}] Installing package 'git', please wait, this may take some time."
				ldrInstallPackage "git"
			else
				echo "[${red}${bold}X${normal}] Couldn't check install mode, stopping installation."
				exit 1
			fi
		elif [[ $ldrGIT -eq 0 ]]; then
			echo "[${green}${bold}O${normal}] Package 'git' is already installed!"
		else
			echo "[${red}${bold}X${normal}] Couldn't check dependency 'git', stopping installation."
			exit 1
		fi

		# ---------------------------------------------------------

		# -------------------------- GCC --------------------------

		echo "[${yellow}${bold}?${normal}] Checking GCC"
		gcc --version &> /dev/null
		ldrGCC=$?
		if [[ $ldrGCC -eq 127 ]]; then
			if $ldrMode; then
				echo "[${red}${bold}X${normal}] GCC not found, do you want to install it using command 'sudo apt -y install gcc'? [Y/N]"
				read ldrAnswer < /dev/tty
				if [[ ${ldrAnswer,,} == "y" ]]; then
					echo "[${green}${bold}O${normal}] Installing package 'gcc', please wait, this may take some time."
					ldrInstallPackage "gcc"
				elif [[ ${ldrAnswer,,} == "n" ]]; then
					echo "[${red}${bold}X${normal}] Stopping script, couldn't install dependencies."
					exit 1
				else
					echo "[${red}${bold}X${normal}] Invalid argument, couldn't install dependencies."
					exit 1
				fi
			elif !$ldrMode; then
				echo "[${green}${bold}O${normal}] Installing package 'gcc', please wait, this may take some time."
				ldrInstallPackage "gcc"
			else
				echo "[${red}${bold}X${normal}] Couldn't check install mode, stopping installation."
				exit 1
			fi
		elif [[ $ldrGCC -eq 0 ]]; then
			echo "[${green}${bold}O${normal}] Package 'gcc' is already installed!"
		else
			echo "[${red}${bold}X${normal}] Couldn't check dependency 'gcc', stopping installation."
			exit 1
		fi

		# ---------------------------------------------------------


		echo "[${green}${bold}O${normal}] Updating locate database, sudo needed. [CTRL+C to skip]"
		sudo updatedb


		# -------------------- libncurses5-dev --------------------

		echo "[${yellow}${bold}?${normal}] Checking libncurses5-dev"
		if [[ $(locate libncurses5-dev) ]]; then
			echo "[${green}${bold}O${normal}] Package 'libncurses5-dev' is already installed!"
		else
			if $ldrMode; then
				echo "[${red}${bold}X${normal}] libncurses5-dev not found, do you want to install it using command 'sudo apt -y install libncurses5-dev'? [Y/N]"
				read ldrAnswer < /dev/tty
				if [[ ${ldrAnswer,,} == "y" ]]; then
					echo "[${green}${bold}O${normal}] Installing package 'libncurses5-dev', please wait, this may take some time."
					ldrInstallPackage "libncurses5-dev"
				elif [[ ${ldrAnswer,,} == "n" ]]; then
					echo "[${red}${bold}X${normal}] Stopping script, couldn't install dependencies."
					exit 1
				else
					echo "[${red}${bold}X${normal}] Invalid argument, couldn't install dependencies."
					exit 1
				fi
			elif !$ldrMode; then
				echo "[${green}${bold}O${normal}] Installing package 'libncurses5-dev', please wait, this may take some time."
				ldrInstallPackage "libncurses5-dev"
			else
				echo "[${red}${bold}X${normal}] Couldn't check install mode, stopping installation."
				exit 1
			fi
		fi

		# ---------------------------------------------------------

		# ------------------- libncursesw5-dev --------------------

		echo "[${yellow}${bold}?${normal}] Checking libncursesw5-dev"
		if [[ $(locate libncursesw5-dev) ]]; then
			echo "[${green}${bold}O${normal}] Package 'libncursesw5-dev' is already installed!"
		else
			if $ldrMode; then
				echo "[${red}${bold}X${normal}] libncursesw5-dev not found, do you want to install it using command 'sudo apt -y install libncursesw5-dev'? [Y/N]"
				read ldrAnswer < /dev/tty
				if [[ ${ldrAnswer,,} == "y" ]]; then
					echo "[${green}${bold}O${normal}] Installing package 'libncursesw5-dev', please wait, this may take some time."
					ldrInstallPackage "libncursesw5-dev"
				elif [[ ${ldrAnswer,,} == "n" ]]; then
					echo "[${red}${bold}X${normal}] Stopping script, couldn't install dependencies."
					exit 1
				else
					echo "[${red}${bold}X${normal}] Invalid argument, couldn't install dependencies."
					exit 1
				fi
			elif !$ldrMode; then
				echo "[${green}${bold}O${normal}] Installing package 'libncursesw5-dev', please wait, this may take some time."
				ldrInstallPackage "libncursesw5-dev"
			else
				echo "[${red}${bold}X${normal}] Couldn't check install mode, stopping installation."
				exit 1
			fi
		fi

		# ---------------------------------------------------------

	}
fi

function ldrDlCompSauce(){
	if [[ ! $(ls | grep lander) ]]; then
		echo "[${green}${bold}O${normal}] Downloading source with git, please wait."
		git clone https://github.com/Capuno/Lander.git lander &> /dev/null
		if [[ $? -eq 1 ]]; then
			echo "[${red}${bold}X${normal}] Couldn't get source with git, stopping installation."
			exit 1
		fi
		cd lander
		echo "[${green}${bold}O${normal}] Compiling source with GCC, please wait."
		make &> /dev/null
		if [[ $? -eq 1 ]]; then
			echo "[${red}${bold}X${normal}] Couldn't compile source, stopping installation."
		fi
	else
		echo -e "[${red}${bold}X${normal}] There is a folder named 'lander' in the current directory\n    please move it, delete it or change directory."
	fi
}

mkdir ldrLogs
ldrMode=true

clear

echo -e "  _                     _           
 | |                   | |          
 | |     __ _ _ __   __| | ___ _ __   *
 | |    / _\` | '_ \ / _\` |/ _ \ '__|
 | |___| (_| | | | | (_| |  __/ |   
 |______\__,_|_| |_|\__,_|\___|_|    /A\\"


echo -e "\n=========== ${bold}DEPENDENCIES${normal} ==========="

ldrInstallDependencies

echo -e "\n========= ${bold}DL+COMPILE SAUCE${normal} ========="

ldrDlCompSauce

echo -e "\n====================================\n"

echo -e "[${green}${bold}O${normal}] Lander is ready to be played!\n    type './lander-game' inside $(pwd) to start!"

rm -rf ldrLogs

exit 0