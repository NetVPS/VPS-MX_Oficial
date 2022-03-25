#!/bin/bash
clear
clear
declare -A cor=([0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m")
SCPdir="/etc/VPS-MX"
SCPfrm="${SCPdir}/herramientas" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="${SCPdir}/protocolos" && [[ ! -d ${SCPinst} ]] && exit

mportas() {
	unset portas
	portas_var=$(lsof -V -i tcp -P -n | grep -v "ESTABLISHED" | grep -v "COMMAND" | grep "LISTEN")
	while read port; do
		var1=$(echo $port | awk '{print $1}') && var2=$(echo $port | awk '{print $9}' | awk -F ":" '{print $2}')
		[[ "$(echo -e $portas | grep "$var1 $var2")" ]] || portas+="$var1 $var2\n"
	done <<<"$portas_var"
	i=1
	echo -e "$portas"
}

activado() {
	msg -bar
	#puerto local
	[[ "$(ps x | grep badvpn | grep -v grep | awk '{print $1}')" ]] && msg -verd "                  ACTIVADO CON EXITO" || msg -ama "                 Falló"
	msg -bar
}
BadVPN() {
	pid_badvpn=$(ps x | grep badvpn | grep -v grep | awk '{print $1}')
	#if [ "$pid_badvpn" = "" ]; then
	if [[ ! -e /bin/badvpn-udpgw ]]; then
		wget -O /bin/badvpn-udpgw https://raw.githubusercontent.com/NetVPS/VPS-MX_Oficial/master/LINKS-LIBRERIAS/badvpn-udpgw &>/dev/null
		chmod 777 /bin/badvpn-udpgw
	fi
	#fix rclocal
	msg -bar
	msg -tit
	msg -ama "  \e[1;43m\e[91mACTIVADOR DE BADVPN (7100-7200-7300-Multi Port)\e[0m"
	msg -bar
	echo -e "$(msg -verd "[1]")$(msg -verm2 "➛ ")$(msg -azu "ACTIVAR BADVPN 7300")"
	echo -e "$(msg -verd "[2]")$(msg -verm2 "➛ ")$(msg -azu "AGREGAR +PORT BADVPN ")"
	echo -e "$(msg -verd "[3]")$(msg -verm2 "➛ ")$(msg -azu "DETENER SERVICIO BADVPN")"

	msg -bar
	read -p "Digite una opción (default 1): " -e -i 1 portasx
	tput cuu1 && tput dl1
	if [[ ${portasx} = 1 ]]; then
		screen -dmS badvpn2 /bin/badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 1000 --max-connections-for-client 10
		echo -e "#!/bin/sh -e" >/etc/rc.local
		echo -e "exit 0" >>/etc/rc.local
		echo -e "#!/bin/bash" >>/etc/rc.local
		echo -e "screen -dmS udpvpn /bin/badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 1000 --max-connections-for-client 10" >>/etc/rc.local
		echo -e "exit 0" >>/etc/rc.local
		chmod +x /etc/rc.local &>/dev/null
		systemctl enable rc-local.service &>/dev/null
		systemctl start rc-local.service &>/dev/null
		systemctl restart rc-local.service &>/dev/null
		activado
	elif [[ ${portasx} = 2 ]]; then

		read -p " Digite El Puerto Para Badvpn: " ud
		screen -dmS badvpn2 /bin/badvpn-udpgw --listen-addr 127.0.0.1:$ud --max-clients 1000 --max-connections-for-client 10
		echo -e "#!/bin/sh -e" >/etc/rc.local
		echo -e "exit 0" >>/etc/rc.local
		echo -e "#!/bin/bash" >>/etc/rc.local
		echo -e "screen -dmS udpvpn /bin/badvpn-udpgw --listen-addr 127.0.0.1:$ud --max-clients 1000 --max-connections-for-client 10" >>/etc/rc.local
		echo -e "exit 0" >>/etc/rc.local
		chmod +x /etc/rc.local &>/dev/null
		systemctl enable rc-local.service &>/dev/null
		systemctl start rc-local.service &>/dev/null
		systemctl restart rc-local.service &>/dev/null
		activado
	elif [[ ${portasx} = 3 ]]; then

		msg -bar
		msg -tit
		msg -ama "          DESACTIVADOR DE BADVPN (UDP)"
		msg -bar
		kill -9 $(ps x | grep badvpn | grep -v grep | awk '{print $1'}) >/dev/null 2>&1
		killall badvpn-udpgw >/dev/null 2>&1
		rm -rf /bin/badvpn-udpgw
		echo -e "#!/bin/sh -e " >/etc/rc.local
		echo "exit 0" >>/etc/rc.local
		[[ ! "$(ps x | grep badvpn | grep -v grep | awk '{print $1}')" ]] && msg -ne "                DESACTIVADO CON EXITO \n"
		unset pid_badvpn
		msg -bar
	elif [[ ${portasx} = 0 ]]; then
		msg -verm "	SALIENDO"
		exit
	fi

	unset pid_badvpn
}

BadVPN
