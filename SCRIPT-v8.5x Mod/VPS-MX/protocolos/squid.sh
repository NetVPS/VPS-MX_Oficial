#!/bin/bash
 #25/01/2021
 declare -A cor=( [0]=" \033[1;37m" [1]=" \033[1;34m" [2]=" \033[1;32m" [3]=" \033[1;36m" [4]=" \033[1;31m" )
 clear
 clear
 SCPdir="/etc/VPS-MX"
 SCPfrm="${SCPdir}/herramientas" && [[ ! -d ${SCPfrm} ]] && exit
 SCPinst="${SCPdir}/protocolos"&& [[ ! -d ${SCPinst} ]] && exit
 #LISTA PORTAS
 mportas () {
 unset portas
 portas_var=$(lsof -V -i tcp -P -n | grep -v "ESTABLISHED" |grep -v "COMMAND" | grep "LISTEN")
 while read port; do
 var1=$(echo $port | awk '{print $1}') && var2=$(echo $port | awk '{print $9}' | awk -F ":" '{print $2}')
 [[ "$(echo -e $portas|grep "$var1 $var2")" ]] || portas+="$var1 $var2 \n"
 done <<< "$portas_var"
 i=1
 echo -e "$portas"
 }
 fun_ip () {
 MEU_IP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127 \.[0-9]{1,3} \.[0-9]{1,3} \.[0-9]{1,3}' | grep -o -E '[0-9]{1,3} \.[0-9]{1,3} \.[0-9]{1,3} \.[0-9]{1,3}' | head -1)
 MEU_IP2=$(wget -qO- ipv4.icanhazip.com)
 [[ "$MEU_IP" != "$MEU_IP2" ]] && IP="$MEU_IP2" || IP="$MEU_IP"
 }
 #ETHOOL SSH
 fun_eth () {
 eth=$(ifconfig | grep -v inet6 | grep -v lo | grep -v 127.0.0.1 | grep "encap:Ethernet" | awk '{print $1}')
     [[ $eth != "" ]] && {
     msg -bar
     echo -e "${cor[3]} $(fun_trans  "Aplicar el sistema para mejorar los paquetes SSH?")"
     echo -e "${cor[3]} $(fun_trans  "Opciones para usuarios avanzados")"
     msg -bar
     read -p "[S/N]: " -e -i n sshsn
     tput cuu1 && tput dl1
            [[ "$sshsn" = @(s|S|y|Y) ]] && {
            echo -e "${cor[1]} $(fun_trans "Correccion de problemas de paquetes en SSH...")"
 		   msg -bar
            echo -e " $(fun_trans "Cual es la tasa RX")"
            echo -ne "[ 1 - 999999999 ]: "; read rx
            [[ "$rx" = "" ]] && rx="999999999"
            echo -e " $(fun_trans "Cual es la tasa TX")"
            echo -ne "[ 1 - 999999999 ]: "; read tx
            [[ "$tx" = "" ]] && tx="999999999"
            apt-get install ethtool -y > /dev/null 2>&1
            ethtool -G $eth rx $rx tx $tx > /dev/null 2>&1
            msg -bar
            }
      }
 }
 fun_bar () {
 comando="$1"
  _=$(
 $comando > /dev/null 2>&1
 ) & > /dev/null
 pid=$!
 while [[ -d /proc/$pid ]]; do
 echo -ne "  \033[1;33m["
    for((i=0; i<20; i++)); do
    echo -ne " \033[1;31m##"
    sleep 0.2
    done
 echo -ne " \033[1;33m]"
 sleep 1s
 echo
 tput cuu1 && tput dl1
 done
 echo -e "  \033[1;33m[ \033[1;31m######################################## \033[1;33m] -  \033[1;32m100% \033[0m"
 sleep 1s
 }
 msg -bar3
 fun_squid  () {
   if [[ -e /etc/squid/squid.conf ]]; then
   var_squid="/etc/squid/squid.conf"
   elif [[ -e /etc/squid3/squid.conf ]]; then
   var_squid="/etc/squid3/squid.conf"
   fi
   [[ -e $var_squid ]] && {
   echo -e " \033[1;32m $(fun_trans "REMOVIENDO SQUID")"
   msg -bar
   service squid stop > /dev/null 2>&1
   apt-get remove squid3 -y &>/dev/null && echo -e "  \033[1;33m[ \033[1;31m################################# \033[1;33m] -  \033[1;32m100% \033[0m"
   msg -bar
   echo -e " \033[1;32m $(fun_trans "Procedimento Concluido")"
   msg -bar
   [[ -e $var_squid ]] && rm $var_squid
   return 0
   }
 msg -bar
 msg -tit
 msg -ama "         INSTALADOR SQUID VPS-MX"
 msg -bar
 fun_ip
 echo -ne " $(fun_trans "Confirme su ip") \033[1;91m"; read -p ": " -e -i $IP ip
 msg -bar
 echo -e " $(fun_trans " \033[1;97mAhora elige los puertos que desea en el Squid")"
 echo -e " $(fun_trans " \033[1;97mSeleccione puertos en orden secuencial, \n  \033[1;92mEjemplo: 80 8080 8799 3128")"
 msg -bar
 echo -ne " $(fun_trans "Digite losPuertos:") \033[1;32m "; read portasx
 msg -bar
 totalporta=($portasx)
 unset PORT
    for((i=0; i<${#totalporta[@]}; i++)); do
         [[ $(mportas|grep "${totalporta[$i]}") = "" ]] && {
         echo -e " \033[1;33m $(fun_trans  "Puerto Escojido:") \033[1;32m ${totalporta[$i]} OK"
         PORT+="${totalporta[$i]} \n"
         } || {
         echo -e " \033[1;33m $(fun_trans  "Puerto Escojido:") \033[1;31m ${totalporta[$i]} FAIL"
         }
    done
   [[ -z $PORT ]] && {
   echo -e " \033[1;31m $(fun_trans  "No se ha elegido ninguna puerto valido") \033[0m"
   return 1
   }
 msg -bar
 echo -e " $(fun_trans  "INSTALANDO SQUID")"
 msg -bar
 apt-get install squid3 -y &>/dev/null && echo -e "  \033[1;33m[ \033[1;31m######################################## \033[1;33m] -  \033[1;32m100% \033[0m" | pv -qL10
 
 msg -bar
 echo -e " $(fun_trans  "INICIANDO CONFIGURACION")"
 echo -e ".bookclaro.com.br/ \n.claro.com.ar/ \n.claro.com.br/ \n.claro.com.co/ \n.claro.com.ec/ \n.claro.com.gt/ \n.cloudfront.net/ \n.claro.com.ni/ \n.claro.com.pe/ \n.claro.com.sv/ \n.claro.cr/ \n.clarocurtas.com.br/ \n.claroideas.com/ \n.claroideias.com.br/ \n.claromusica.com/ \n.clarosomdechamada.com.br/ \n.clarovideo.com/ \n.facebook.net/ \n.facebook.com/ \n.netclaro.com.br/ \n.oi.com.br/ \n.oimusica.com.br/ \n.speedtest.net/ \n.tim.com.br/ \n.timanamaria.com.br/ \n.vivo.com.br/ \n.rdio.com/ \n.compute-1.amazonaws.com/ \n.portalrecarga.vivo.com.br/ \n.vivo.ddivulga.com/" > /etc/payloads
 msg -bar
 echo -e " \033[1;32m $(fun_trans  "Ahora Escoja Una Conf Para Su Proxy")"
 msg -bar
 echo -e "|1| $(fun_trans  "Basico")"
 echo -e "|2| $(fun_trans  "Avanzado") \033[1;37m"
 msg -bar
 read -p "[1/2]: " -e -i 1 proxy_opt
 tput cuu1 && tput dl1
 if [[ $proxy_opt = 1 ]]; then
 echo -e " $(fun_trans  "          INSTALANDO SQUID BASICO")"
 elif [[ $proxy_opt = 2 ]]; then
 echo -e " $(fun_trans  "          INSTALANDO SQUID AVANZADO")"
 else
 echo -e " $(fun_trans  "          INSTALANDO SQUID BASICO")"
 proxy_opt=1
 fi
 unset var_squid
 if [[ -d /etc/squid ]]; then
 var_squid="/etc/squid/squid.conf"
 elif [[ -d /etc/squid3 ]]; then
 var_squid="/etc/squid3/squid.conf"
 fi
 if [[ "$proxy_opt" = @(02|2) ]]; then
 echo -e "#ConfiguracaoSquiD
 acl url1 dstdomain -i $ip
 acl url2 dstdomain -i 127.0.0.1
 acl url3 url_regex -i '/etc/payloads'
 acl url4 url_regex -i '/etc/opendns'
 acl url5 dstdomain -i localhost
 acl accept dstdomain -i GET
 acl accept dstdomain -i POST
 acl accept dstdomain -i OPTIONS
 acl accept dstdomain -i CONNECT
 acl accept dstdomain -i PUT
 acl HEAD dstdomain -i HEAD
 acl accept dstdomain -i TRACE
 acl accept dstdomain -i OPTIONS
 acl accept dstdomain -i PATCH
 acl accept dstdomain -i PROPATCH
 acl accept dstdomain -i DELETE
 acl accept dstdomain -i REQUEST
 acl accept dstdomain -i METHOD
 acl accept dstdomain -i NETDATA
 acl accept dstdomain -i MOVE
 acl all src 0.0.0.0/0
 http_access allow url1
 http_access allow url2
 http_access allow url3
 http_access allow url4
 http_access allow url5
 http_access allow accept
 http_access allow HEAD
 http_access deny all
 
 # Request Headers Forcing
 
 request_header_access Allow allow all
 request_header_access Authorization allow all
 request_header_access WWW-Authenticate allow all
 request_header_access Proxy-Authorization allow all
 request_header_access Proxy-Authenticate allow all
 request_header_access Cache-Control allow all
 request_header_access Content-Encoding allow all
 request_header_access Content-Length allow all
 request_header_access Content-Type allow all
 request_header_access Date allow all
 request_header_access Expires allow all
 request_header_access Host allow all
 request_header_access If-Modified-Since allow all
 request_header_access Last-Modified allow all
 request_header_access Location allow all
 request_header_access Pragma allow all
 request_header_access Accept allow all
 request_header_access Accept-Charset allow all
 request_header_access Accept-Encoding allow all
 request_header_access Accept-Language allow all
 request_header_access Content-Language allow all
 request_header_access Mime-Version allow all
 request_header_access Retry-After allow all
 request_header_access Title allow all
 request_header_access Connection allow all
 request_header_access Proxy-Connection allow all
 request_header_access User-Agent allow all
 request_header_access Cookie allow all
 #request_header_access All deny all
 
 # Response Headers Spoofing
 
 #reply_header_access Via deny all
 #reply_header_access X-Cache deny all
 #reply_header_access X-Cache-Lookup deny all
 
 #portas" > $var_squid
 for pts in $(echo -e $PORT); do
 echo -e "http_port $pts" >> $var_squid
 done
 echo -e "
 #nome
 visible_hostname VPS-MX
 
 via off
 forwarded_for off
 pipeline_prefetch off" >> $var_squid
  else
 echo -e "#Configuracion SquiD
 acl localhost src 127.0.0.1/32 ::1
 acl to_localhost dst 127.0.0.0/8 0.0.0.0/32 ::1
 acl SSL_ports port 443
 acl Safe_ports port 80
 acl Safe_ports port 21
 acl Safe_ports port 443
 acl Safe_ports port 70
 acl Safe_ports port 210
 acl Safe_ports port 1025-65535
 acl Safe_ports port 280
 acl Safe_ports port 488
 acl Safe_ports port 591
 acl Safe_ports port 777
 acl CONNECT method CONNECT
 acl SSH dst $ip-$ip/255.255.255.255
 http_access allow SSH
 http_access allow manager localhost
 http_access deny manager
 http_access allow localhost
 http_access deny all
 coredump_dir /var/spool/squid
 refresh_pattern ^ftp: 1440 20% 10080
 refresh_pattern ^gopher: 1440 0% 1440
 refresh_pattern -i (/cgi-bin/| \?) 0 0% 0
 refresh_pattern . 0 20% 4320
 
 #Puertos" > $var_squid
 for pts in $(echo -e $PORT); do
 echo -e "http_port $pts" >> $var_squid
 done
 echo -e "
 #HostName
 visible_hostname VPS-MX
 
 via off
 forwarded_for off
 pipeline_prefetch off" >> $var_squid
 fi
 touch /etc/opendns
 fun_eth
 msg -bar
 echo -ne "  \033[1;31m [ ! ]  \033[1;33m$(fun_trans  "    REINICIANDO SERVICIOS")"
 squid3 -k reconfigure > /dev/null 2>&1
 squid -k reconfigure > /dev/null 2>&1
 service ssh restart > /dev/null 2>&1
 service squid3 restart > /dev/null 2>&1
 service squid restart > /dev/null 2>&1
 echo -e "  \033[1;32m[OK]"
 msg -bar
 echo -e "${cor[3]}$(fun_trans  "            SQUID CONFIGURADO")"
 msg -bar
 #UFW
 for ufww in $(mportas|awk '{print $2}'); do
 ufw allow $ufww > /dev/null 2>&1
 done
 }
 SPR &
 online_squid () {
 payload="/etc/payloads"
 msg -bar
 echo -e " \033[1;33m$(fun_trans  "            SQUID CONFIGURADO")"
 msg -bar
 echo -e "${cor[2]} [1] >${cor[3]} $(fun_trans  "Colocar Host en Squid")"
 echo -e "${cor[2]} [2] >${cor[3]} $(fun_trans  "Remover Host de Squid")"
 echo -e "${cor[2]} [3] >${cor[3]} $(fun_trans  "Desinstalar Squid")"
 echo -e "${cor[2]} [0] >${cor[3]} $(fun_trans  "Volver")"
 msg -bar
 while [[ $varpay != @(0|[1-3]) ]]; do
 read -p "[0/3]: " varpay
 tput cuu1 && tput dl1
 done
 if [[ "$varpay" = "0" ]]; then
 return 1
 elif [[ "$varpay" = "1" ]]; then
 echo -e "${cor[4]} $(fun_trans  "Hosts Actuales Dentro del Squid")"
 msg -bar
 cat $payload | awk -F "/" '{print $1,$2,$3,$4}'
 msg -bar
 while [[ $hos !=  \.* ]]; do
 echo -ne "${cor[4]}$(fun_trans  "Escriba el nuevo host"): " && read hos
 tput cuu1 && tput dl1
 [[ $hos =  \.* ]] && continue
 echo -e "${cor[4]}$(fun_trans  "Comience con") .${cor[0]}"
 sleep 2s
 tput cuu1 && tput dl1
 done
 host="$hos/"
 [[ -z $host ]] && return 1
 [[ `grep -c "^$host" $payload` -eq 1 ]] &&:echo -e "${cor[4]}$(fun_trans  "Host ya Exciste")${cor[0]}" && return 1
 echo "$host" >> $payload && grep -v "^$" $payload > /tmp/a && mv /tmp/a $payload
 echo -e "${cor[4]}$(fun_trans  "Host Agregado con Exito")"
 msg -bar
 cat $payload | awk -F "/" '{print $1,$2,$3,$4}'
 msg -bar
 if [[ ! -f "/etc/init.d/squid" ]]; then
 service squid3 reload
 service squid3 restart
 else
 /etc/init.d/squid reload
 service squid restart
 fi	
 return 0
 elif [[ "$varpay" = "2" ]]; then
 echo -e "${cor[4]} $(fun_trans  "Hosts Actuales Dentro del Squid")"
 msg -bar
 cat $payload | awk -F "/" '{print $1,$2,$3,$4}'
 msg -bar
 while [[ $hos !=  \.* ]]; do
 echo -ne "${cor[4]}$(fun_trans  "Digite un Host"): " && read hos
 tput cuu1 && tput dl1
 [[ $hos =  \.* ]] && continue
 echo -e "${cor[4]}$(fun_trans  "Comience con") ."
 sleep 2s
 tput cuu1 && tput dl1
 done
 host="$hos/"
 [[ -z $host ]] && return 1
 [[ `grep -c "^$host" $payload` -ne 1 ]] &&!echo -e "${cor[5]}$(fun_trans  "Host No Encontrado")" && return 1
 grep -v "^$host" $payload > /tmp/a && mv /tmp/a $payload
 echo -e "${cor[4]}$(fun_trans  "Host Removido Con Exito")"
 msg -bar
 cat $payload | awk -F "/" '{print $1,$2,$3,$4}'
 msg -bar
 if [[ ! -f "/etc/init.d/squid" ]]; then
 service squid3 reload
 service squid3 restart
 service squid reload
 service squid restart
 else
 /etc/init.d/squid reload
 service squid restart
 /etc/init.d/squid3 reload
 service squid3 restart
 fi	
 return 0
 elif [[ "$varpay" = "3" ]]; then
 fun_squid
 fi
 }
 if [[ -e /etc/squid/squid.conf ]]; then
 online_squid
 elif [[ -e /etc/squid3/squid.conf ]]; then
 online_squid
 else
 fun_squid
 fi 