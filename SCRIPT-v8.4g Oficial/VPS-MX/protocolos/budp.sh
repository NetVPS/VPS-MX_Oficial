#!/bin/bash
#25/01/2021
clear
clear
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
SCPdir="/etc/VPS-MX"
SCPfrm="${SCPdir}/herramientas" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="${SCPdir}/protocolos"&& [[ ! -d ${SCPinst} ]] && exit
BadVPN () {
pid_badvpn=$(ps x | grep badvpn | grep -v grep | awk '{print $1}')
if [ "$pid_badvpn" = "" ]; then
msg -bar 
msg -tit
    msg -ama "            ACTIVADOR DE BADVPN (UDP 7300)"
    msg -bar 
    if [[ ! -e /bin/badvpn-udpgw ]]; then
    wget -O /bin/badvpn-udpgw https://raw.githubusercontent.com/NetVPS/VPS-MX_Oficial/master/LINKS-LIBRERIAS/badvpn-udpgw &>/dev/null
    chmod 777 /bin/badvpn-udpgw
    fi
    screen -dmS badvpn2 /bin/badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 1000 --max-connections-for-client 10 
    [[ "$(ps x | grep badvpn | grep -v grep | awk '{print $1}')" ]] && msg -verd "                  ACTIVADO CON EXITO" || msg -ama "                 Fallo"
	msg -bar
else
    msg -bar 
	msg -tit
    msg -ama "          DESACTIVADOR DE BADVPN (UDP 7300)"
    msg -bar
    kill -9 $(ps x | grep badvpn | grep -v grep | awk '{print $1'}) > /dev/null 2>&1
    killall badvpn-udpgw > /dev/null 2>&1
    [[ ! "$(ps x | grep badvpn | grep -v grep | awk '{print $1}')" ]] && msg -ne "                DESACTIVADO CON EXITO \n"
    unset pid_badvpn
	msg -bar
    fi
unset pid_badvpn
}

BadVPN