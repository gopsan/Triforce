#!/bin/bash
configfile=$1
if [ $# -eq 0 ]
then
configfile="config.conf"
fi
source $configfile
function option_picked() {
    COLOR='\033[01;31m' # bold red
    RESET='\033[00;00m' # normal white
    MESSAGE=${@:-"${RESET}Error: No message passed"}
    echo -e "${COLOR}${MESSAGE}${RESET}"
}
function view_about() {

read;
clear;
}
function view_help() {

read;
clear;
}
function log() {
get_date;
echo $1 >> "$settings_logdir/ScanLog-$dt.txt"
}
function get_date() {
dt=$(date '+%d-%m-%Y-%H-%M-%S');
}
function find_php() {
find . -name "*.php*" | while read file; do
path=$(realpath $file)
ProcessFile $path
done
}
function ProcessFile() {
while read -r pattern 
do
tmp=$(cat $1 | grep $pattern);
if [ tmp != "" ]; then
if [ $settings_quarantine == 1]; then
cp $1 $settings_quarantinedir
rm $1
fi
if [ $settings_delete == 1]; then
mv $1 /dev/null
fi
break
fi
done < "$settings_path/patterns.txt"
}
function set_config() {
echo "" > $configfile
echo -e "settings_delete=$1\nsettings_quarantine=$2\nsettings_dailyscan=$3\nsettings_logdir=$4\nsettings_quarantinedir=$5\nsettings_path=~/" > $configfile
source $configfile
}
function sub_config(){
    NORMAL=`echo "\033[m"`
    MENU=`echo "\033[36m"` #Blue
    NUMBER=`echo "\033[33m"` #yellow
    FGRED=`echo "\033[41m"`
    RED_TEXT=`echo "\033[31m"`
    ENTER_LINE=`echo "\033[33m"`
    echo -e "${MENU}*********************************************${NORMAL}"
    echo -e "${MENU}**${NUMBER} 1)${MENU} Delete Files? [$1] ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 2)${MENU} Quarantine Files? [$2] ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 3)${MENU} Run Daily Scan? [$3] ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 4)${MENU} Set ScanLog Dir [$4] ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 5)${MENU} Set Quarantine Location? [$5] ${NORMAL}"
    echo -e "${MENU}*********************************************${NORMAL}"
    echo -e "${ENTER_LINE}Please enter a menu option and enter or ${RED_TEXT}enter to exit. ${NORMAL}"
    read sub1
  while [ sub1 != '' ]
  do
    if [[ $sub1 = "" ]]; then
      clear;
	printmenu;	
    else
	option_picked "Configuration";
      case $sub1 in
      1) clear;
	case $1 in 
		1) 	set_config 0 $settings_quarantine $settings_dailyscan $settings_logdir $settings_quarantinedir;
			sub_config 0 $2 $3 $4 $5;
		;;
		0) 	set_config 1 $settings_quarantine $settings_dailyscan $settings_logdir $settings_quarantinedir;
			sub_config 1 $2 $3 $4 $5;
		;;
		esac
	;;
      2) clear;
                case $2 in
                1) set_config $settings_delete 0 $settings_dailyscan $settings_logdir $settings_quarantinedir;
                        sub_config $1 0 $3 $4 $5;
                ;;
                0) set_config $settings_delete 1 $settings_dailyscan $settings_logdir $settings_quarantinedir;
                        sub_config $1 1 $3 $4 $5;
            ;;
          esac
      ;;
      3) clear;
                case $3 in
                1) set_config $settings_delete $settings_quarantine 0 $settings_logdir $settings_quarantinedir;
                        sub_config $1 $2 0 $4 $5;
                ;;
                0) set_config $settings_delete $settings_quarantine 1 $settings_logdir $settings_quarantinedir;
                        sub_config $1 $2 1 $4 $5;
            ;;
          esac
      ;;

      x)clear;
	sub1='';
	printmenu;
      ;;

      \n)clear;
	sub1='';
	printmenu;
      ;;
      esac
    fi
  done
}
function scan_dir() {
cd $1
find_php;
}
function printmenu {
    NORMAL=`echo "\033[m"`
    MENU=`echo "\033[36m"` #Blue
    NUMBER=`echo "\033[33m"` #yellow
    FGRED=`echo "\033[41m"`
    RED_TEXT=`echo "\033[31m"`
    ENTER_LINE=`echo "\033[33m"`
    echo -e "${MENU}*********************************************${NORMAL}"
    echo -e "${MENU}**${NUMBER} 1)${MENU} Configure ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 2)${MENU} Scan Directory ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 3)${MENU} Scan Everything ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 4)${MENU} View Quarantine ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 5)${MENU} Help ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 6)${MENU} About ${NORMAL}"
    echo -e "${MENU}*********************************************${NORMAL}"
    echo -e "${ENTER_LINE}Please enter a menu option and enter or ${RED_TEXT}enter to exit.${NORMAL}"
read opt
}
while [ opt != '' ]; do
printmenu
case $opt in
      1) clear;
      option_picked "Configuration";
      sub_config $settings_delete $settings_quarantine $settings_dailyscan $settings_logdir $settings_quarantinedir;
      ;;

      2) clear;
      option_picked "Scan Directory";
	echo "Directory to scan: "
	read dir
      scan_dir $dir;
      ;;

      3) clear;
      option_picked "Scan Everything";
      scan_dir "/";
      ;;

      4) clear;
      option_picked "View Quarantine";
      view_quarantine;
      ;;
      5) clear;
      option_picked "Help Page"
      view_help;
      ;;
      6) clear;
      option_picked "About Page"
      view_about;
      ;;

      x) exit;
      ;;

      \n) exit;
      ;;
   esac
done
done
