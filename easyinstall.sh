#!/bin/bash

red="\033[0;31m"
green="\033[0;32m"
cyan="\033[0;36m"
yellow="\033[0;33m"
none="\033[0m"
parent_dir=~/v2ray-tel-bot
conf=$parent_dir/config/config.yml
main_repo=https://github.com/TeleDark/v2ray-tel-bot.git
edition_repo=https://github.com/m0h4mad/v2ray-tel-bot.git

[[ $EUID -ne 0 ]] && echo -e "${red}Fatal error: ${plain} Please run this script with root privilege \n " && exit 1

if [[ -f /etc/os-release ]]; then
	source /etc/os-release
	release=$ID
elif [[ -f /usr/lib/os-release ]]; then
	source /usr/lib/os-release
	release=$ID
else
	echo "Failed to check the system OS, please contact the author!" >&2
	exit 1
fi

install_prerequisites() {
	case "$release" in
		centos|fedora)
			echo -e $red"The script does not support CentOS-based operating systems"$none;;
		*)
			apt-get update && apt-get install -y git wget python3;;
	esac
}

print_banner() {
	echo -e $cyan"          ___                              "
	echo "        /'___\`\\                            "
	echo " __  __/\\_\\ /\\ \\  _ __    __     __  __    "
	echo "/\\ \\/\\ \\/_/// /__/\\\`'__\\/'__\`\\  /\\ \\/\\ \\   "
	echo "\\ \\ \\_/ | // /_\\ \\ \\ \\//\\ \\L\\.\\_\\ \\ \\_\\ \\  "
	echo " \\ \\___/ /\\______/\\ \\_\\\\ \\__/.\\_\\\\/\`____ \\ "
	echo "  \\/__/  \\/_____/  \\/_/ \\/__/\\/_/ \`/___/> \\"
	echo "                                     /\\___/"
	echo "              Telegram Bot           \\/__/ "
	echo -e $green
	echo -e " ---# easy install script by m0h4mad #---"
}

install_python_dependencies() {
	if [[ $(python3 -c "import sys;print(sys.version_info[:2]<(3, 10))") == "True" ]]; then
		echo -e $yellow"updating python..."$none
		apt-get install -y software-properties-common && add-apt-repository -y ppa:deadsnakes/ppa && apt-get -y install python3.10 && unlink /usr/bin/python3 && ln -s /usr/bin/python3.10 /usr/bin/python3
		curl -sS https://bootstrap.pypa.io/get-pip.py | python3
		python3 -m pip install --upgrade pip && python3 -m pip install --upgrade setuptools
	fi

	pip install --ignore-installed pyYaml
	pip install -r $parent_dir/requirements.txt
}

update() {
	while true; do
		read -p "Do you wish to update to m0h4mad Edition? (bugs have been fixed) [y/n]: " choice
		case $choice in
			[Yy]*) git_url=$edition_repo && break;;
			[Nn]*) git_url=$main_repo && break;;
			*) echo -e $yellow"You have to enter y or n: "$none;;
		esac
	done
	echo -e $yellow"Updating..."$none
	cp -r $conf ~/
	cd ~/ && rm -rf $parent_dir
	git clone $git_url && cp -r ~/config.yml $conf && rm ~/config.yml
	echo -e $green"Updated Successfully."$none
	sleep 1
}

uninstall() {
	temp_file=$(mktemp)
	crontab -l > $temp_file
	lines=($(grep -nE 'v2ray-tel-bot' $temp_file | cut -d: -f1))
	if [[ ${#lines[@]} -gt 0 ]]; then
		for (( i=${#lines[@]}-1; i>=0; i-- )); do
			sed -i ${lines[$i]}"d" $temp_file
		done
		
		crontab $temp_file
	fi
	rm $temp_file
	rm -rf $parent_dir
	echo -e $green"The bot uninstalled successfully."$none
}

install() {
	echo -e $cyan"1.$green Main Source Code. (TeleDark's version)"
	echo -e $cyan"2.$green m0h4mad Edition. (bugs have been fixed, extra features)"
	echo -e $none
	while true; do
		read -p "Which one do you whish to install? (1/2): " option
		case $option in
			1) git_url=$main_repo && break;;
			2) git_url=$edition_repo && break;;
			*) echo $yellow"Please enter 1 or 2";;
		esac
	done
	echo -e $none
	cd ~/ && git clone $git_url
	(crontab -l; echo "*/3 * * * * python3 ~/v2ray-tel-bot/login.py"; echo "@reboot python3 ~/v2ray-tel-bot/bot.py"; echo "42 2 */2 * * rm -rf ~/v2ray-tel-bot/cookies.pkl") | sort -u | crontab -
}

add_first_panel() {
	echo -e $green
	read -p "Enter your bot-token: " token
	cat << EOF > $conf
telegram_token: "$token"

panels:
EOF
	add_panel
}

add_panel() {
	while true; do
		echo
		echo -e $cyan"1.$green Add New Panel."
		echo -e $cyan"2.$green Replace Current Settings."
		echo -e $cyan"3.$green Save and Exit."
		echo -e $none
		read -p "Enter your choice (1/2/3): " choice
		case $choice in
			1)
				echo -e $green
				read -p "Enter your panel address (e.g http://web.example.com:54321): " addr
				read -p "Enter your username: " user
				read -s -p "Enter your password: " pass
				echo -e $none
				cat << EOF >> $conf
  - url: $addr
    username: $user
    password: $pass

EOF
				echo "New panel added."
			;;
			2)
				clear && print_banner
				add_first_panel;;
			3) break;;
			*) echo -e $yellow"Wrong!"$none;;
		esac
	done
}

test_and_reboot() {
	if [[ -n  $(python3 $parent_dir/login.py | grep 'successfull') ]]; then
		echo -e $green"Bot seems to work just fine."$none
		just_reboot
	else
		echo -e $red"Panel informations provided by you seem to be wrong! check them again"$none
		add_first_panel
	fi
}

just_reboot() {
	echo -e $yellow"The server will reboot in 3 seconds."$none
	sleep 3
	reboot
}

main_menu() {
	echo -e $cyan"1.$green Install The Bot."
	if [[ -d $parent_dir/config ]]; then
		echo -e $green" -----------------------------------------"
		echo -e $cyan"2.$green Uninstall The Bot."
		echo -e $cyan"3.$green Update The Bot."
		echo -e $cyan"4.$green Change Panel Settings."
		echo " -----------------------------------------"
	fi
	echo -e $cyan"0.$green Exit."
	echo -e $none
	read -p "Enter your choice (numbers only): " choice
	case $choice in
		1)
			clear
			install_prerequisites
			install_python_dependencies
			clear && print_banner
			install
			clear && print_banner
			add_first_panel
			test_and_reboot
			;;
		2)
			clear
			uninstall
			just_reboot
			;;
		3)
			clear && print_banner
			update
			clear && print_banner
			add_panel
			test_and_reboot
			;;
		4)
			clear
			add_panel
			just_reboot
			;;
	esac
}

clear
print_banner
main_menu
