#!/bin/bash
 #by @rufu99
 ADM_inst="/etc/VPS-MX/Slow/install" && [[ ! -d ${ADM_inst} ]] && exit
 ADM_slow="/etc/VPS-MX/Slow/Key" && [[ ! -d ${ADM_slow} ]] && exit
 info(){
 	clear
 	nodata(){
 		msg -bar
 		msg -ama "!SIN INFORMACION SLOWDNS!"
 		exit 0
 	}
 
 	if [[ -e  ${ADM_slow}/domain_ns ]]; then
 		ns=$(cat ${ADM_slow}/domain_ns)
 		if [[ -z "$ns" ]]; then
 			nodata
 			exit 0
 		fi
 	else
 		nodata
 		exit 0
 	fi
 
 	if [[ -e ${ADM_slow}/server.pub ]]; then
 		key=$(cat ${ADM_slow}/server.pub)
 		if [[ -z "$key" ]]; then
 			nodata
 			exit 0
 		fi
 	else
 		nodata
 		exit 0
 	fi
 
 	msg -bar
 	msg -ama "DATOS DE SU CONECCION SLOWDNS"
 	msg -bar
 	msg -ama "Su NS (Nameserver): $(cat ${ADM_slow}/domain_ns)"
 	msg -bar
 	msg -ama "Su Llave: $(cat ${ADM_slow}/server.pub)"
 	
 	exit 0
 }
 
 drop_port(){
     local portasVAR=$(lsof -V -i tcp -P -n | grep -v "ESTABLISHED" |grep -v "COMMAND" | grep "LISTEN")
     local NOREPEAT
     local reQ
     local Port
     unset DPB
     while read port; do
         reQ=$(echo ${port}|awk '{print $1}')
         Port=$(echo {$port} | awk '{print $9}' | awk -F ":" '{print $2}')
         [[ $(echo -e $NOREPEAT|grep -w "$Port") ]] && continue
         NOREPEAT+="$Port\n"
 
         case ${reQ} in
         	sshd|dropbear|stunnel4|stunnel|python|python3)DPB+=" $reQ:$Port";;
             *)continue;;
         esac
     done <<< "${portasVAR}"
  }
 
 ini_slow(){
 	msg -bra "INSTALADOR SLOWDNS"
 	drop_port
 	n=1
     for i in $DPB; do
         proto=$(echo $i|awk -F ":" '{print $1}')
         proto2=$(printf '%-12s' "$proto")
         port=$(echo $i|awk -F ":" '{print $2}')
         echo -e " $(msg -verd "[$n]") $(msg -verm2 ">") $(msg -ama "$proto2")$(msg -azu "$port")"
         drop[$n]=$port
         num_opc="$n"
         let n++ 
     done
     msg -bar
     opc=$(selection_fun $num_opc)
     echo "${drop[$opc]}" > ${ADM_slow}/puerto
     PORT=$(cat ${ADM_slow}/puerto)
     msg -bra "INSTALADOR SLOWDNS"
     echo -e " $(msg -ama "Puerto de coneccion atraves de SlowDNS:") $(msg -verd "$PORT")"
     msg -bar
 
     unset NS
     while [[ -z $NS ]]; do
     	msg -ama " Tu dominio NS: "
     	read NS
     	tput cuu1 && tput dl1
     done
     echo "$NS" > ${ADM_slow}/domain_ns
     echo -e " $(msg -ama "Tu dominio NS:") $(msg -verd "$NS")"
     msg -bar
 
     if [[ ! -e ${ADM_inst}/dns-server ]]; then
     	msg -ama " Descargando binario...."
     	if wget -O ${ADM_inst}/dns-server https://raw.githubusercontent.com/NetVPS/VPS-MX_Oficial/master/LINKS-LIBRERIAS/dns-server &>/dev/null ; then
     		chmod +x ${ADM_inst}/dns-server
     		msg -verd "[OK]"
     	else
     		msg -verm "[fail]"
     		msg -bar
     		msg -ama "No se pudo descargar el binario"
     		msg -verm "Instalacion canselada"
     		
     		exit 0
     	fi
     	msg -bar
     fi
 
     [[ -e "${ADM_slow}/server.pub" ]] && pub=$(cat ${ADM_slow}/server.pub)
 
     if [[ ! -z "$pub" ]]; then
     	msg -ama " Usar clave existente [S/N]: "
     	read ex_key
 
     	case $ex_key in
     		s|S|y|Y) tput cuu1 && tput dl1
     			 echo -e " $(msg -ama "Tu clave:") $(msg -verd "$(cat ${ADM_slow}/server.pub)")";;
     		n|N) tput cuu1 && tput dl1
     			 rm -rf ${ADM_slow}/server.key
     			 rm -rf ${ADM_slow}/server.pub
     			 ${ADM_inst}/dns-server -gen-key -privkey-file ${ADM_slow}/server.key -pubkey-file ${ADM_slow}/server.pub &>/dev/null
     			 echo -e " $(msg -ama "Tu clave:") $(msg -verd "$(cat ${ADM_slow}/server.pub)")";;
     		*);;
     	esac
     else
     	rm -rf ${ADM_slow}/server.key
     	rm -rf ${ADM_slow}/server.pub
     	${ADM_inst}/dns-server -gen-key -privkey-file ${ADM_slow}/server.key -pubkey-file ${ADM_slow}/server.pub &>/dev/null
     	echo -e " $(msg -ama "Tu clave:") $(msg -verd "$(cat ${ADM_slow}/server.pub)")"
     fi
     msg -bar
     msg -ama "    Iniciando SlowDNS...."
 
     iptables -I INPUT -p udp --dport 5300 -j ACCEPT
     iptables -t nat -I PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 5300
 
     if screen -dmS slowdns ${ADM_inst}/dns-server -udp :5300 -privkey-file ${ADM_slow}/server.key $NS 127.0.0.1:$PORT ; then
     	msg -verd "Con exito!!!"
     else
     	msg -verm "Con fallo!!!"
     fi
     exit 0
 }
 
 reset_slow(){
 	clear
 	msg -bar
 	msg -ama "    Reiniciando SlowDNS...."
 	screen -ls | grep slowdns | cut -d. -f1 | awk '{print $1}' | xargs kill
 	NS=$(cat ${ADM_slow}/domain_ns)
 	PORT=$(cat ${ADM_slow}/puerto)
 	if screen -dmS slowdns /etc/slowdns/dns-server -udp :5300 -privkey-file /root/server.key $NS 127.0.0.1:$PORT ;then
 		msg -verd "Con exito!!!"
 	else
 		msg -verm "Con fallo!!!"
 	fi
 	exit 0
 }
 stop_slow(){
 	clear
 	msg -bar
 	msg -ama "    Deteniendo SlowDNS...."
 	if screen -ls | grep slowdns | cut -d. -f1 | awk '{print $1}' | xargs kill ; then
 		msg -verd "Con exito!!!"
 	else
 		msg -verm "Con fallo!!!"
 	fi
 	exit 0
 }
 
 while :
 do
 	clear
 	msg -bar
 	msg -ama "INSTALADOR SLOWDNS"
 	msg -bar
 	menu_func "Ver Informacion\n$(msg -bar3)" "$(msg -verd "Iniciar SlowDNS")" "$(msg -ama "Reiniciar SlowDNS")" "$(msg -verm2 "Detener SlowDNS")" 
 	msg -bar
 	opcion=$(selection_fun 5)
 
 	case $opcion in
 		1)info;;
 		2)ini_slow;;
 		3)reset_slow;;
 		4)stop_slow;;
 		0)exit;;
 	esac
 done
  