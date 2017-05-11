#!/bin/bash

distro=$(cat /etc/*-release | sed -n -e '/^ID=/p')

if [[ $distro == *"debian" || $distro == *"ubuntu" || $distro == *"mint" ]]; then
	function ldrInstallDependencies(){
		function ldrInstallPackage(){
			ldrPackageName=$1
			sudo apt install $ldrPackageName > logs/ldrInstallDependencies_stdout.txt 2> logs/ldrInstallDependencies_stderr.txt
			if [[ $? > 0 ]]; then
				echo "[X] Installation for packege '$ldrPackageName' failed, check file logs/ldrInstallDependencies_stderr.txt for more information."
				exit 1
			else
				echo "[O] Successfully installed package '$ldrPackageName'"
			fi
		}

		# -------------------------- GCC --------------------------

		echo "[?] Checking GCC"
		if command g++ 2>/dev/null; then
			if $ldrMode; then
				echo "[X] GCC not found, do you want to install it using command 'sudo apt install g++'? [Y/N]"
				read ldrAnswer
				if [[ ${ldrAnswer,,} == "y" ]]; then
					ldrInstallPackage "g++"
				elif [[ ${ldrAnswer,,} == "n" ]]; then
					echo "[X] Stopping script, couldn't install dependencies."
					exit 1
				else
					echo "[X] Invalid argument, couldn't install dependencies."
					exit 1
				fi
			elif !$ldrMode; then
				ldrInstallPackage "g++"
			else
				echo "[X] Couldn't check install mode, stopping installation."
				exit 1
			fi
		elif ! command g++ 2> /dev/null; then
			echo "[O] Package 'g++' is already installed!"
		else
			echo "[X] Couldn't check dependency 'g++', stopping installation."
			exit 1
		fi

		# ---------------------------------------------------------


		echo "[O] Updating locate database, sudo needed."
		sudo updatedb


		# -------------------- libncurses5-dev --------------------

		echo "[?] Checking libncurses5-dev"
		if [[ $(locate libncurses5-dev) ]]; then
			echo "[O] Package 'libncurses5-dev' is already installed!"
		else
			if $ldrMode; then
				echo "[X] libncurses5-dev not found, do you want to install it using command 'sudo apt install libncurses5-dev'? [Y/N]"
				read ldrAnswer
				if [[ ${ldrAnswer,,} == "y" ]]; then
					ldrInstallPackage "libncurses5-dev"
				elif [[ ${ldrAnswer,,} == "n" ]]; then
					echo "[X] Stopping script, couldn't install dependencies."
					exit 1
				else
					echo "[X] Invalid argument, couldn't install dependencies."
					exit 1
				fi
			elif !$ldrMode; then
				ldrInstallPackage "libncurses5-dev"
			else
				echo "[X] Couldn't check install mode, stopping installation."
				exit 1
			fi
		fi

		# ---------------------------------------------------------

		# ------------------- libncursesw5-dev --------------------

		echo "[?] Checking libncursesw5-dev"
		if [[ $(locate libncursesw5-dev) ]]; then
			echo "[O] Package 'libncursesw5-dev' is already installed!"
		else
			if $ldrMode; then
				echo "[X] libncursesw5-dev not found, do you want to install it using command 'sudo apt install libncursesw5-dev'? [Y/N]"
				read ldrAnswer
				if [[ ${ldrAnswer,,} == "y" ]]; then
					ldrInstallPackage "libncursesw5-dev"
				elif [[ ${ldrAnswer,,} == "n" ]]; then
					echo "[X] Stopping script, couldn't install dependencies."
					exit 1
				else
					echo "[X] Invalid argument, couldn't install dependencies."
					exit 1
				fi
			elif !$ldrMode; then
				ldrInstallPackage "libncursesw5-dev"
			else
				echo "[X] Couldn't check install mode, stopping installation."
				exit 1
			fi
		fi

		# ---------------------------------------------------------

	}
fi

ldrMode=true
ldrInstallDependencies
