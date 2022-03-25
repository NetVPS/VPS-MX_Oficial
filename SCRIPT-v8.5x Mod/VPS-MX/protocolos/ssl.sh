#!/bin/bash 
 #25/01/2021 by @Kalix1
 clear
 clear
 SCPdir="/etc/VPS-MX"
 SCPfrm="${SCPdir}/herramientas" && [[ ! -d ${SCPfrm} ]] && exit
 SCPinst="${SCPdir}/protocolos"&& [[ ! -d ${SCPinst} ]] && exit
 declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" [5]="\e[1;36m" )
 
 mportas () {
 unset portas
 portas_var=$(lsof -V -i tcp -P -n | grep -v "ESTABLISHED" |grep -v "COMMAND" | grep "LISTEN")
 while read port; do
 var1=$(echo $port | awk '{print $1}') && var2=$(echo $port | awk '{print $9}' | awk -F ":" '{print $2}')
 [[ "$(echo -e $portas|grep "$var1 $var2")" ]] || portas+="$var1 $var2\n"
 done <<< "$portas_var"
 i=1
 echo -e "$portas"
 }
 
 fun_bar () {
 comando="$1"
  _=$(
 $comando > /dev/null 2>&1
 ) & > /dev/null
 pid=$!
 while [[ -d /proc/$pid ]]; do
 echo -ne " \033[1;33m["
    for((i=0; i<20; i++)); do
    echo -ne "\033[1;31m##"
    sleep 0.5
    done
 echo -ne "\033[1;33m]"
 sleep 1s
 echo
 tput cuu1
 tput dl1
 done
 echo -e " \033[1;33m[\033[1;31m########################################\033[1;33m] - \033[1;32m100%\033[0m"
 sleep 1s
 }
 
 ssl_stunel () {
 [[ $(mportas|grep stunnel4|head -1) ]] && {
 echo -e "\033[1;33m $(fun_trans  "Deteniendo Stunnel")"
 msg -bar
 service stunnel4 stop > /dev/null 2>&1
 rm -rf /etc/stunnel/stunnel.conf
 apt-get purge stunnel4 -y &>/dev/null && echo -e "\e[31m DETENIENDO SERVICIO SSL" | pv -qL10
 apt-get purge stunnel4 &>/dev/null
 apt-get remove stunnel4 &>/dev/null
 rm -rf /etc/stunnel/certificado.zip private.key certificate.crt ca_bundle.crt &>/dev/null
 msg -bar
 echo -e "\033[1;33m $(fun_trans  "Detenido Con Exito!")"
 msg -bar
 return 0
 }
 clear
 msg -bar
 echo -e "\033[1;33m $(fun_trans  "Seleccione una puerta de redirección interna.")"
 echo -e "\033[1;33m $(fun_trans  "Un puerto SSH/DROPBEAR/SQUID/OPENVPN/PYTHON")"
 msg -bar
          while true; do
          echo -ne "\033[1;37m"
          read -p " Puerto Local: " redir
 		 echo ""
          if [[ ! -z $redir ]]; then
              if [[ $(echo $redir|grep [0-9]) ]]; then
                 [[ $(mportas|grep $redir|head -1) ]] && break || echo -e "\033[1;31m $(fun_trans  "Puerto Invalido")"
              fi
          fi
          done
 msg -bar
 DPORT="$(mportas|grep $redir|awk '{print $2}'|head -1)"
 echo -e "\033[1;33m $(fun_trans  "Ahora Que Puerto sera SSL")"
 msg -bar
     while true; do
 	echo -ne "\033[1;37m"
     read -p " Puerto SSL: " SSLPORT
 	echo ""
     [[ $(mportas|grep -w "$SSLPORT") ]] || break
     echo -e "\033[1;33m $(fun_trans  "Esta puerta está en uso")"
     unset SSLPORT
     done
 msg -bar
 echo -e "\033[1;33m $(fun_trans  "Instalando SSL")"
 msg -bar
 fun_bar "apt-get install stunnel4 -y"
 apt-get install stunnel4 -y > /dev/null 2>&1
 echo -e "client = no\n[SSL]\ncert = /etc/stunnel/stunnel.pem\naccept = ${SSLPORT}\nconnect = 127.0.0.1:${DPORT}" > /etc/stunnel/stunnel.conf
 ####Coreccion2.0##### 
 openssl genrsa -out stunnel.key 2048 > /dev/null 2>&1
 
 (echo "mx" ; echo "mx" ; echo "Speed" ; echo "@conectedmx_bot" ; echo "@conectedmx" ; echo "@lacasitamx" ; echo "@conectedmx_vip" )|openssl req -new -key stunnel.key -x509 -days 1000 -out stunnel.crt > /dev/null 2>&1
 
 cat stunnel.crt stunnel.key > stunnel.pem 
 
 mv stunnel.pem /etc/stunnel/
 ######-------
 sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
 service stunnel4 restart > /dev/null 2>&1
 msg -bar
 echo -e "\033[1;33m $(fun_trans  "INSTALADO CON EXITO")"
 msg -bar
 rm -rf /etc/ger-frm/stunnel.crt > /dev/null 2>&1
 rm -rf /etc/ger-frm/stunnel.key > /dev/null 2>&1
 rm -rf /root/stunnel.crt > /dev/null 2>&1
 rm -rf /root/stunnel.key > /dev/null 2>&1
 return 0
 }
 SPR &
 ssl_stunel_2 () {
 echo -e "\033[1;32m $(fun_trans  "             AGREGAR MAS PUERTOS SSL")"
 msg -bar
 echo -e "\033[1;33m $(fun_trans  "Seleccione una puerta de redirección interna.")"
 echo -e "\033[1;33m $(fun_trans  "Un puerto SSH/DROPBEAR/SQUID/OPENVPN/SSL")"
 msg -bar
          while true; do
          echo -ne "\033[1;37m"
          read -p " Puerto-Local: " portx
 		 echo ""
          if [[ ! -z $portx ]]; then
              if [[ $(echo $portx|grep [0-9]) ]]; then
                 [[ $(mportas|grep $portx|head -1) ]] && break || echo -e "\033[1;31m $(fun_trans  "Puerto Invalido")"
              fi
          fi
          done
 msg -bar
 DPORT="$(mportas|grep $portx|awk '{print $2}'|head -1)"
 echo -e "\033[1;33m $(fun_trans  "Ahora Que Puerto sera SSL")"
 msg -bar
     while true; do
 	echo -ne "\033[1;37m"
     read -p " Listen-SSL: " SSLPORT
 	echo ""
     [[ $(mportas|grep -w "$SSLPORT") ]] || break
     echo -e "\033[1;33m $(fun_trans  "Esta puerta está en uso")"
     unset SSLPORT
     done
 msg -bar
 echo -e "\033[1;33m $(fun_trans  "Instalando SSL")"
 msg -bar
 fun_bar "apt-get install stunnel4 -y"
 echo -e "client = no\n[SSL+]\ncert = /etc/stunnel/stunnel.pem\naccept = ${SSLPORT}\nconnect = 127.0.0.1:${DPORT}" >> /etc/stunnel/stunnel.conf
 ######-------
 sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
 service stunnel4 restart > /dev/null 2>&1
 msg -bar
 echo -e "${cor[4]}            INSTALADO CON EXITO"
 msg -bar
 rm -rf /etc/ger-frm/stunnel.crt > /dev/null 2>&1
 rm -rf /etc/ger-frm/stunnel.key > /dev/null 2>&1
 rm -rf /root/stunnel.crt > /dev/null 2>&1
 rm -rf /root/stunnel.key > /dev/null 2>&1
 return 0
 }
 sslpython(){
 msg -bar
 echo -e "\033[1;37mSe Requiere tener el puerto 80 y el 443 libres"
 echo -ne " Desea Continuar? [S/N]: "; read seg
 [[ $seg = @(n|N) ]] && msg -bar && return
 clear
 install_python(){ 
  apt-get install python -y &>/dev/null && echo -e "\033[1;97m Activando Python Directo ►80\n" | pv -qL 10
  
  sleep 3  
  screen -dmS pydic-80 python ${SCPinst}/python.py 80 "VPS-MX" && echo "80 VPS-MX" >> /etc/VPS-MX/PySSL.log
  msg -bar
  } 
  
  install_ssl(){  
  apt-get install stunnel4 -y &>/dev/null && echo -e "\033[1;97m Activando Servicios SSL ►443\n" | pv -qL 12
  
  apt-get install stunnel4 -y > /dev/null 2>&1 
  echo -e "client = no\n[SSL]\ncert = /etc/stunnel/stunnel.pem\naccept = 443\nconnect = 127.0.0.1:80" > /etc/stunnel/stunnel.conf 
  openssl genrsa -out stunnel.key 2048 > /dev/null 2>&1 
  (echo mx; echo @lacasitamx; echo Full; echo speed; echo internet; echo @conectedmx; echo @conectedmx_bot)|openssl req -new -key stunnel.key -x509 -days 1095 -out stunnel.crt > /dev/null 2>&1
  cat stunnel.crt stunnel.key > stunnel.pem   
  mv stunnel.pem /etc/stunnel/ 
  ######------- 
  sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4 
  service stunnel4 restart > /dev/null 2>&1  
  rm -rf /root/stunnel.crt > /dev/null 2>&1 
  rm -rf /root/stunnel.key > /dev/null 2>&1 
  } 
 install_python 
 install_ssl 
 msg -bar
 echo -e "${cor[4]}               INSTALACION COMPLETA"
 msg -bar
 }
 unistall(){
 clear
 msg -bar
 msg -ama "DETENIENDO SERVICIOS SSL Y PYTHON"
 msg -bar
 service stunnel4 stop > /dev/null 2>&1
 apt-get purge stunnel4 -y &>/dev/null
 apt-get purge stunnel -y &>/dev/null
 kill -9 $(ps aux |grep -v grep |grep -w "python.py"|grep dmS|awk '{print $2}') &>/dev/null
 rm /etc/VPS-MX/PySSL.log &>/dev/null
 rm -rf /etc/stunnel/certificado.zip private.key certificate.crt ca_bundle.crt &>/dev/null
 clear
 msg -bar
 msg -verd "LOS SERVICIOS SE HAN DETENIDO"
 msg -bar
 }
 
 #
 certif(){
 msg -bar
 msg -tit
 echo -e "\e[1;37m ACONTINUACION ES TENER LISTO EL LINK DEL CERTIFICADO.zip\n VERIFICADO EN ZEROSSL, DESCARGALO Y SUBELO\n EN TU GITHUB O DROPBOX"
 echo -ne " Desea Continuar? [S/N]: "; read seg
 [[ $seg = @(n|N) ]] && msg -bar && return
 clear
 ####Cerrificado ssl/tls#####
 msg -bar
 echo -e "\e[1;33m👇 LINK DEL CERTIFICADO.zip 👇           \n     \e[0m"
 echo -ne "\e[1;36m LINK\e[37m: \e[34m"
 #extraer certificado.zip
 read linkd
 wget -O /etc/stunnel/certificado.zip $linkd &>/dev/null
 cd /etc/stunnel/
 unzip certificado.zip &>/dev/null
 cat private.key certificate.crt ca_bundle.crt > stunnel.pem
 rm -rf certificado.zip
 sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
 service stunnel restart > /dev/null 2>&1
 service stunnel4 restart &>/dev/null
 msg -bar
 echo -e "${cor[4]} CERTIFICADO INSTALADO CON EXITO \e[0m" 
 msg -bar
 }
 
 certificadom(){
 if [ -f /etc/stunnel/stunnel.conf ]; then
 insapa2(){
 for pid in $(pgrep python);do
 kill $pid
 done
 for pid in $(pgrep apache2);do
 kill $pid
 done
 service dropbear stop
 apt install apache2 -y
 echo "Listen 80
 
 <IfModule ssl_module>
         Listen 443
 </IfModule>
 
 <IfModule mod_gnutls.c>
         Listen 443
 </IfModule> " > /etc/apache2/ports.conf
 service apache2 restart
 }
 clear
 msg -bar
 insapa2 &>/dev/null && echo -e " \e[1;33mAGREGANDO RECURSOS " | pv -qL 10
 msg -bar
 echo -e "\e[1;37m Verificar dominio \e[0m"
 msg -bar
 read -p " LLAVE: " keyy
 msg -bar
 read -p " DATOS: " dat2w
 mkdir -p /var/www/html/.well-known/pki-validation/
 datfr1=$(echo "$dat2w"|awk '{print $1}')
 datfr2=$(echo "$dat2w"|awk '{print $2}')
 datfr3=$(echo "$dat2w"|awk '{print $3}')
 echo -ne "${datfr1}\n${datfr2}\n${datfr3}" >/var/www/html/.well-known/pki-validation/$keyy.txt
 msg -bar
 echo -e "\e[1;37m VERIFIQUE EN LA PÁGINA ZEROSSL \e[0m"
 msg -bar
 read -p " ENTER PARA CONTINUAR"
 clear
 msg -bar
 echo -e "\e[1;33m👇 LINK DEL CERTIFICADO 👇       \n     \e[0m"
 echo -e "\e[1;36m LINK\e[37m: \e[34m"
 read link
 incertis(){
 wget $link -O /etc/stunnel/certificado.zip
 cd /etc/stunnel/
 unzip certificado.zip 
 cat private.key certificate.crt ca_bundle.crt > stunnel.pem
 service stunnel restart &>/dev/null
 service stunnel4 restart &>/dev/null
 }
 incertis &>/dev/null && echo -e " \e[1;33mEXTRAYENDO CERTIFICADO " | pv -qL 10
 msg -bar
 echo -e "${cor[4]} CERTIFICADO INSTALADO \e[0m" 
 msg -bar
 
 for pid in $(pgrep apache2);do
 kill $pid
 done
 apt install apache2 -y &>/dev/null
 echo "Listen 81
 
 <IfModule ssl_module>
         Listen 443
 </IfModule>
 
 <IfModule mod_gnutls.c>
         Listen 443
 </IfModule> " > /etc/apache2/ports.conf
 service apache2 restart &>/dev/null
 service dropbear start &>/dev/null
 service dropbear restart &>/dev/null
 for port in $(cat /etc/VPS-MX/PortPD.log| grep -v "nobody" |cut -d' ' -f1)
 do
 PIDVRF3="$(ps aux|grep pydic-"$port" |grep -v grep|awk '{print $2}')"
 if [[ -z $PIDVRF3 ]]; then
 screen -dmS pydic-"$port" python /etc/VPS-MX/protocolos/python.py "$port"
 else
 for pid in $(echo $PIDVRF3); do
 echo ""
 done
 fi
 done
 else
 msg -bar
 echo -e "${cor[3]} SSL/TLS NO INSTALADO \e[0m"
 msg -bar
 fi
 }
 certifica2(){
 if [ -f /etc/stunnel/stunnel.conf ]; then
 insapa2(){
 for pid in $(pgrep python);do
 kill $pid
 done
 for pid in $(pgrep apache2);do
 kill $pid
 done
 service dropbear stop
 apt install apache2 -y
 echo "Listen 80
 
 <IfModule ssl_module>
         Listen 443
 </IfModule>
 
 <IfModule mod_gnutls.c>
         Listen 443
 </IfModule> " > /etc/apache2/ports.conf
 service apache2 restart
 }
 clear
 msg -bar
 insapa2 &>/dev/null && echo -e " \e[1;33mAGREGANDO RECURSOS " | pv -qL 10
 msg -bar
 echo -e "\e[1;37m Verificar dominio \e[0m"
 msg -bar
 read -p " LLAVE: " archi
 msg -bar
 echo -e "\e[1;37m COPIA LOS DATOS DEL ARCHIVO\n\e[1;33m$archi.txt\nLINEA1,LINEA2,LINEA3, SE TE PEDIRA POR PARTES \e[0m"
 read -p " LINEA 1: " dat1w
 read -p " LINEA 2: " dat2w
 read -p " LINEA 3: " dat3w
 mkdir -p /var/www/html/.well-known/pki-validation/
 dat1=$(echo "$dat1w"|awk '{print $1}')
 dat2=$(echo "$dat2w"|awk '{print $1}')
 dat3=$(echo "$dat3w"|awk '{print $1}')
 echo -ne "${dat1}\n${dat2}\n${dat3}" >/var/www/html/.well-known/pki-validation/$archi.txt
 msg -bar
 echo -e "\e[1;37m AHORA VERIFIQUE EN LA PÁGINA ZEROSSL \e[0m"
 msg -bar
 read -p " ENTER PARA CONTINUAR"
 clear
 msg -bar
 echo -e "\e[1;33m👇 LINK DEL CERTIFICADO 👇       \n     \e[0m"
 echo -e "\e[1;36m LINK\e[37m: \e[34m"
 read link
 incertis(){
 wget $link -O /etc/stunnel/certificado.zip
 cd /etc/stunnel/
 unzip certificado.zip 
 cat private.key certificate.crt ca_bundle.crt > stunnel.pem
 service stunnel restart &>/dev/null
 service stunnel4 restart &>/dev/null
 }
 incertis &>/dev/null && echo -e " \e[1;33mEXTRAYENDO CERTIFICADO " | pv -qL 10
 msg -bar
 echo -e "${cor[4]} CERTIFICADO INSTALADO \e[0m" 
 msg -bar
 
 for pid in $(pgrep apache2);do
 kill $pid
 done
 apt install apache2 -y &>/dev/null
 echo "Listen 81
 
 <IfModule ssl_module>
         Listen 443
 </IfModule>
 
 <IfModule mod_gnutls.c>
         Listen 443
 </IfModule> " > /etc/apache2/ports.conf
 service apache2 restart &>/dev/null
 service dropbear start &>/dev/null
 service dropbear restart &>/dev/null
 for port in $(cat /etc/VPS-MX/PortPD.log| grep -v "nobody" |cut -d' ' -f1)
 do
 PIDVRF3="$(ps aux|grep pydic-"$port" |grep -v grep|awk '{print $2}')"
 if [[ -z $PIDVRF3 ]]; then
 screen -dmS pydic-"$port" python /etc/VPS-MX/protocolos/python.py "$port"
 else
 for pid in $(echo $PIDVRF3); do
 echo ""
 done
 fi
 done
 else
 msg -bar
 echo -e "${cor[3]} SSL/TLS NO INSTALADO \e[0m"
 msg -bar
 fi
 }
 #
 
 clear
 if netstat -tnlp |grep 'stunnel4' &>/dev/null || netstat -tnlp |grep 'stunnel' &>/dev/null; then
 stunel="\e[32m[ ON ]"
 else
 stunel="\e[31m[ OFF ]"
 fi
 msg -bar
 msg -bar3
 msg -tit
 echo -e "       \e[91m\e[43mINSTALADOR MULTI SSL\e[0m "
 msg -bar
 echo -e "$(msg -verd "[1]")$(msg -verm2 "➛ ")$(msg -azu "INICIAR || DETENER SSL") $stunel"
 echo -e "$(msg -verd "[2]")$(msg -verm2 "➛ ")$(msg -azu "AGREGAR + PUERTOS SSL")"
 msg -bar
 echo -e "$(msg -verd "[3]")$(msg -verm2 "➛ ")$(msg -azu "SSL+Python Auto-Config 80➮443    ")"
 echo -e "$(msg -verd "[4]")$(msg -verm2 "➛ ")$(msg -azu "\e[1;31mDETENER SERVICIO SSL+Python")"
 msg -bar
 echo -e "$(msg -verd "[5]")$(msg -verm2 "➛ ")$(msg -azu "CERTIFICADO SSL/TLS")"
 msg -bar
 echo -ne "\033[1;37mSelecione Una Opcion [0/5]: "
 read opcao
 case $opcao in
 1)
 msg -bar
 ssl_stunel
 ;;
 2)
 msg -bar
 ssl_stunel_2
 sleep 3
 exit
 ;;
 3)
 sslpython
 exit
 ;;
 4) unistall ;;
 5)
 clear
 msg -bar
 echo -e "	\e[91m\e[43mCERTIFICADO SSL/TLS\e[0m"
 msg -bar
 echo -e "$(msg -verd "[1]")$(msg -verm2 "➛ ")$(msg -azu "CERTIFICADO ZIP DIRECTO \e[31m(\e[32mEstricto\e[31m)")"
 echo -e "$(msg -verd "[2]")$(msg -verm2 "➛ ")$(msg -azu "CERTIFICADO MANUAL ZEROSSL \e[31m(\e[32mAvanzado\e[31m)")"
 echo -e "$(msg -verd "[3]")$(msg -verm2 "➛ ")$(msg -azu "CERTIFICADO MANUAL ZEROSSL \e[31m(\e[32mPrincipiantes\e[31m)")"
 msg -bar
 echo -ne "\033[1;37mSelecione Una Opcion [0/4]: "
 read opc
 case $opc in
 1)
 certif
 exit
 ;;
 2)
 certificadom
 exit
 ;;
 3)
 certifica2
 exit
 ;;
 esac
 ;;
 esac 