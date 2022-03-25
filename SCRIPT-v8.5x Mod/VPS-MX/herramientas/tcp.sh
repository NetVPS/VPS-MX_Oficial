#!/bin/bash
clear
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

sh_ver="2.0"
amarillo="\e[33m" && bla="\e[1;37m" && final="\e[0m"
Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[Informacion]${Font_color_suffix}"
Error="${Red_font_prefix}[Error]${Font_color_suffix}"
Tip="${Green_font_prefix}[Atencion]${Font_color_suffix}"

remove_all() {
	sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
	echo -e "\e[1;31m ACELERADOR BBR DESINSTALADA\e[0m"
}

startbbr() {
	remove_all
	echo "net.core.default_qdisc=fq" >>/etc/sysctl.conf
	echo "net.ipv4.tcp_congestion_control=bbr" >>/etc/sysctl.conf
	sysctl -p
	echo -e "${Info}¡BBR comenzó con éxito!"
	msg -bar
}

#Habilitar BBRplus
startbbrplus() {
	remove_all
	echo "net.core.default_qdisc=fq" >>/etc/sysctl.conf
	echo "net.ipv4.tcp_congestion_control=bbrplus" >>/etc/sysctl.conf
	sysctl -p
	echo -e "${Info}BBRplus comenzó con éxito!！"
	msg -bar
}

# Menú de inicio
start_menu() {
	clear
	msg -bar
	msg -tit
	echo -e " TCP Aceleración (BBR/Plus) ${Red_font_prefix}By @lacasitamx${Font_color_suffix}
 $(msg -bar)
  ${Green_font_prefix}[ 1 ]${Font_color_suffix} Acelerar VPS Con BBR ${amarillo}(recomendado)${final}
  ${Green_font_prefix}[ 2 ]${Font_color_suffix} Acelerar VPS Con BBRplus
  ${Green_font_prefix}[ 3 ]${Font_color_suffix} Detener Acelerador VPS
  ${Green_font_prefix}[ 0 ]${Font_color_suffix} Salir del script" && msg -bar

	run_status=$(grep "net.ipv4.tcp_congestion_control" /etc/sysctl.conf | awk -F "=" '{print $2}')
	if [[ ${run_status} ]]; then
		echo -e " Estado actual: ${Green_font_prefix}Instalado\n${Font_color_suffix} ${_font_prefix}BBR Comenzó exitosamente${Font_color_suffix} Kernel Acelerado, ${amarillo}${run_status}${Font_color_suffix}"
	else
		echo -e " Estado actual: ${Green_font_prefix}No instalado\n${Font_color_suffix} Kernel Acelerado: ${Red_font_prefix}Por favor,instale el Acelerador primero.${Font_color_suffix}"
	fi
	msg -bar
	read -p "$(echo -e "\e[31m► ${bla}Selecione Una Opcion [0-3]:${amarillo}") " num
	case "$num" in
	0) ;;
	1) startbbr ;;
	2) startbbrplus ;;
	3) remove_all ;;
	*)
		clear
		echo -e "${Error}:Por favor ingrese el número correcto [0-3]"
		sleep 1s
		start_menu
		;;
	esac
}

check_sys() {
	if [[ -f /etc/redhat-release ]]; then
		release="centos"
	elif cat /etc/issue | grep -q -E -i "debian"; then
		release="debian"
	elif cat /etc/issue | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
	elif cat /proc/version | grep -q -E -i "debian"; then
		release="debian"
	elif cat /proc/version | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
	fi
}

#Verifique la versión de Linux
check_version() {
	if [[ -s /etc/redhat-release ]]; then
		version=$(grep -oE "[0-9.]+" /etc/redhat-release | cut -d . -f 1)
	else
		version=$(grep -oE "[0-9.]+" /etc/issue | cut -d . -f 1)
	fi
	bit=$(uname -m)
	if [[ ${bit} = "x86_64" ]]; then
		bit="x64"
	else
		bit="x32"
	fi
}
check_sys
check_version
[[ ${release} != "debian" ]] && [[ ${release} != "ubuntu" ]] && [[ ${release} != "centos" ]] && echo -e "${Error} Este script no es compatible con el sistema actual. ${release} !" && exit 1
start_menu
