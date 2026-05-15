#!/usr/bin/env bash
#
# Check for official and AUR package updates and upgrade them. When run with the
# "module" argument, output the status icon and update counts in JSON format for
# Waybar
#
# Requirements:
# - checkupdates (pacman-contrib)
# - notify-send (libnotify)
# - Optional: An AUR helper
#
# Author:  Jesse Mirabel <sejjymvm@gmail.com>
# Date:    August 16, 2025
# License: MIT

FG_GREEN="\e[32m"
FG_BLUE="\e[34m"
FG_RESET="\e[39m"

FAILURE=false
PAC_UPD=0
AUR_UPD=0
FLAT_UPD=0

TIMEOUT=30
HELPERS=(aura paru pikaur trizen yay)

printf() {
	command printf "$@" >&2
}

get_helper() {
	local helper
	for helper in "${HELPERS[@]}"; do
		if command -v "$helper" > /dev/null; then
			HELPER=$helper
			break
		fi
	done
}

check_updates() {
	# Check for internet connectivity first
	if ! ping -c 1 -W 1 8.8.8.8 &> /dev/null; then
		return 0
	fi

	local pac_output pac_status
	pac_output=$(timeout $TIMEOUT checkupdates)
	pac_status=$?

	if ((pac_status != 0 && pac_status != 2)); then
		FAILURE=true
		return 1
	fi

	PAC_UPD=$(grep -c . <<< "$pac_output")

	if [[ -n $HELPER ]]; then
		local aur_output aur_status
		aur_output=$(timeout $TIMEOUT "$HELPER" -Quaq)
		aur_status=$?

		if ((${#aur_output} > 0 && aur_status != 0)); then
			FAILURE=true
			return 1
		fi
		AUR_UPD=$(grep -c . <<< "$aur_output")
	fi

	if command -v flatpak &> /dev/null; then
		local flat_output flat_status
		flat_output=$(timeout $TIMEOUT flatpak remote-ls --updates 2>/dev/null)
		flat_status=$?

		if ((${#flat_output} > 0 && flat_status != 0)); then
			FAILURE=true
			return 1
		fi
		FLAT_UPD=$(grep -c . <<< "$flat_output")
	fi
}

update_packages() {
	printf "%bUpdating pacman packages...%b\n" "$FG_BLUE" "$FG_RESET"
	sudo pacman -Syu

	if [[ -n $HELPER ]]; then
		printf "\n%bUpdating AUR packages...%b\n" "$FG_BLUE" "$FG_RESET"
		command "$HELPER" -Syu
	fi

	if command -v flatpak &> /dev/null; then
		printf "\n%bUpdating Flatpak packages...%b\n" "$FG_BLUE" "$FG_RESET"
		flatpak update
	fi

	notify-send "Update Complete" -i "package-install" -r 9986 -h string:x-canonical-private-synchronous:update

	printf "\n%bUpdate Complete!%b\n" "$FG_GREEN" "$FG_RESET"
	read -rsn 1 -p "Press any key to exit..."
}

display_module() {
	if $FAILURE; then
		command printf "{ \"text\": \"󰒑\", \"tooltip\": \"Cannot fetch updates. Right-click to retry.\", \"class\": \"error\" }\n"
		exit 0
	fi

	local total=$((PAC_UPD + AUR_UPD + FLAT_UPD))
	local tooltip="<b>Official</b>: $PAC_UPD"

	if [[ -n $HELPER ]]; then
		tooltip+="\n<b>AUR($HELPER)</b>: $AUR_UPD"
	fi

	if command -v flatpak &> /dev/null; then
		tooltip+="\n<b>Flatpak</b>: $FLAT_UPD"
	fi

	if ((total == 0)); then
		# Use a subtle icon when no updates are available, or stay hidden
		# command printf "{ \"text\": \"󰄠\", \"tooltip\": \"System is up to date\", \"class\": \"uptodate\" }\n"
		exit 1
	else
		command printf "{ \"text\": \"󰄠\", \"tooltip\": \"%s\", \"class\": \"pending\" }\n" "$tooltip"
	fi
}

main() {
	get_helper

	case $1 in
		module)
			check_updates
			display_module
			;;
		*)
			printf "%bChecking for updates...%b\n" "$FG_BLUE" "$FG_RESET"
			check_updates
			update_packages

			# update the module
			pkill -RTMIN+1 waybar
			;;
	esac
}

main "$@"
