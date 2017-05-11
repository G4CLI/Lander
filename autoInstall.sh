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
			sudo apt install $ldrPackageName > logs/ldrInstallDependencies_stdout.txt 2> logs/ldrInstallDependencies_stderr.txt
			if [[ $? > 0 ]]; then
				echo "[${red}${bold}X${normal}] Installation for packege '$ldrPackageName' failed, check file logs/ldrInstallDependencies_stderr.txt for more information."
				exit 1
			else
				echo "[${green}${bold}O${normal}] Successfully installed package '$ldrPackageName'"
			fi
		}

		# -------------------------- GCC --------------------------

		echo "[${yellow}${bold}?${normal}] Checking GCC"
		gcc --version &> /dev/null
		ldrGCC=$?
		if [[ $ldrGCC -eq 127 ]]; then
			if $ldrMode; then
				echo "[${red}${bold}X${normal}] GCC not found, do you want to install it using command 'sudo apt install gcc'? [Y/N]"
				read ldrAnswer < /dev/tty
				if [[ ${ldrAnswer,,} == "y" ]]; then
					ldrInstallPackage "gcc"
				elif [[ ${ldrAnswer,,} == "n" ]]; then
					echo "[${red}${bold}X${normal}] Stopping script, couldn't install dependencies."
					exit 1
				else
					echo "[${red}${bold}X${normal}] Invalid argument, couldn't install dependencies."
					exit 1
				fi
			elif !$ldrMode; then
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
				echo "[${red}${bold}X${normal}] libncurses5-dev not found, do you want to install it using command 'sudo apt install libncurses5-dev'? [Y/N]"
				read ldrAnswer < /dev/tty
				if [[ ${ldrAnswer,,} == "y" ]]; then
					ldrInstallPackage "libncurses5-dev"
				elif [[ ${ldrAnswer,,} == "n" ]]; then
					echo "[${red}${bold}X${normal}] Stopping script, couldn't install dependencies."
					exit 1
				else
					echo "[${red}${bold}X${normal}] Invalid argument, couldn't install dependencies."
					exit 1
				fi
			elif !$ldrMode; then
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
				echo "[${red}${bold}X${normal}] libncursesw5-dev not found, do you want to install it using command 'sudo apt install libncursesw5-dev'? [Y/N]"
				read ldrAnswer < /dev/tty
				if [[ ${ldrAnswer,,} == "y" ]]; then
					ldrInstallPackage "libncursesw5-dev"
				elif [[ ${ldrAnswer,,} == "n" ]]; then
					echo "[${red}${bold}X${normal}] Stopping script, couldn't install dependencies."
					exit 1
				else
					echo "[${red}${bold}X${normal}] Invalid argument, couldn't install dependencies."
					exit 1
				fi
			elif !$ldrMode; then
				ldrInstallPackage "libncursesw5-dev"
			else
				echo "[${red}${bold}X${normal}] Couldn't check install mode, stopping installation."
				exit 1
			fi
		fi

		# ---------------------------------------------------------

	}
fi

mkdir logs
ldrMode=true
clear
ldrInstallDependencies
rm -rf logs