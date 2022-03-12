#!/bin/bash
#27/01/2021
clear
clear
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
SCPdir="/etc/VPS-MX" && [[ ! -d ${SCPdir} ]] && exit 1
SCPusr="${SCPdir}/controlador" && [[ ! -d ${SCPusr} ]] && mkdir ${SCPusr}
SCPfrm="${SCPdir}/herramientas" && [[ ! -d ${SCPfrm} ]] && mkdir ${SCPfrm}
SCPinst="${SCPdir}/protocolos" && [[ ! -d ${SCPfrm} ]] && mkdir ${SCPfrm}
fun_bar () {
comando[0]="$1"
comando[1]="$2"
 (
[[ -e $HOME/fim ]] && rm $HOME/fim
${comando[0]} -y > /dev/null 2>&1
${comando[1]} -y > /dev/null 2>&1
touch $HOME/fim
 ) > /dev/null 2>&1 &
echo -ne "\033[1;33m ["
while true; do
   for((i=0; i<18; i++)); do
   echo -ne "\033[1;31m##"
   sleep 0.1s
   done
   [[ -e $HOME/fim ]] && rm $HOME/fim && break
   echo -e "\033[1;33m]"
   sleep 1s
   tput cuu1
   tput dl1
   echo -ne "\033[1;33m ["
done
echo -e "\033[1;33m]\033[1;31m -\033[1;32m 100%\033[1;37m"
}

#PREENXE A VARIAVEL $IP
meu_ip () {
MEU_IP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
MEU_IP2=$(wget -qO- ipv4.icanhazip.com)
[[ "$MEU_IP" != "$MEU_IP2" ]] && IP="$MEU_IP2" || IP="$MEU_IP"
}

squidpass () {
tmp_arq="/tmp/arq-tmp"
if [ -d "/etc/squid" ]; then
pwd="/etc/squid/passwd"
config_="/etc/squid/squid.conf"
service_="squid"
squid_="0"
elif [ -d "/etc/squid3" ]; then
pwd="/etc/squid3/passwd"
config_="/etc/squid3/squid.conf"
service_="squid3"
squid_="1"
fi
[[ ! -e $config_ ]] && 
msg -bar && 
echo -e " \033[1;36m Proxy Squid no Instalado no puede proseguir" && 
msg -bar && 
return 0
if [ -e $pwd ]; then 
echo -e "${cor[3]} Desea Desactivar Autentificasion del Proxy Squid"
read -p " [S/N]: " -e -i n sshsn
[[ "$sshsn" = @(s|S|y|Y) ]] && {
msg -bar
echo -e " \033[1;36mDesintalando Dependencias:"
rm -rf /usr/bin/squid_log1
fun_bar 'apt-get remove apache2-utils'
msg -bar
cat $config_ | grep -v '#Password' > $tmp_arq
mv -f $tmp_arq $config_ 
cat $config_ | grep -v '^auth_param.*passwd*$' > $tmp_arq
mv -f $tmp_arq $config_ 
cat $config_ | grep -v '^auth_param.*proxy*$' > $tmp_arq
mv -f $tmp_arq $config_ 
cat $config_ | grep -v '^acl.*REQUIRED*$' > $tmp_arq
mv -f $tmp_arq $config_ 
cat $config_ | grep -v '^http_access.*authenticated*$' > $tmp_arq
mv -f $tmp_arq $config_ 
cat $config_ | grep -v '^http_access.*all*$' > $tmp_arq
mv -f $tmp_arq $config_ 
echo -e "
http_access allow all" >> "$config_"
rm -f $pwd
service $service_ restart  > /dev/null 2>&1 &
echo -e " \033[1;31m Desautentificasion de Proxy Squid Desactivado"
msg -bar
} 
else
echo -e "${cor[3]} "Habilitar Autenfificasion de Proxy Squid?""
read -p " [S/N]: " -e -i n sshsn
[[ "$sshsn" = @(s|S|y|Y) ]] && {
msg -bar
echo -e " \033[1;36mInstalando Dependencias:"
echo "Archivo SQUID PASS" > /usr/bin/squid_log1
fun_bar 'apt-get install apache2-utils'
msg -bar
read -e -p " Tu nombre de usuario deseado: " usrn
[[ $usrn = "" ]] && 
msg -bar && 
echo -e " \033[1;31mEl usuario no puede ser nulo" && 
msg -bar && 
return 0
htpasswd -c $pwd $usrn
succes_=$(grep -c "$usrn" $pwd)
if [ "$succes_" = "0" ]; then
rm -f $pwd
msg -bar
echo -e " \033[1;31m Error al generar la contraseña, no se inició la autenticación de Squid"
msg -bar
return 0
elif [[ "$succes_" = "1" ]]; then
cat $config_ | grep -v '^http_access.*all*$' > $tmp_arq
mv -f $tmp_arq $config_ 
if [ "$squid_" = "0" ]; then
echo -e "#Password
auth_param basic program /usr/lib/squid/basic_ncsa_auth /etc/squid/passwd
auth_param basic realm proxy
acl authenticated proxy_auth REQUIRED
http_access allow authenticated
http_access deny all" >> "$config_"
service squid restart  > /dev/null 2>&1 &
update-rc.d squid defaults > /dev/null 2>&1 &
elif [ "$squid_" = "1" ]; then
echo -e "#Password
auth_param basic program /usr/lib/squid3/basic_ncsa_auth /etc/squid3/passwd
auth_param basic realm proxy
acl authenticated proxy_auth REQUIRED
http_access allow authenticated
http_access deny all" >> "$config_"
service squid3 restart > /dev/null 2>&1 &
update-rc.d squid3 defaults > /dev/null 2>&1 &
fi
msg -bar
service squid restart > /dev/null 2>&1
echo -e " \033[1;32m PROTECCION DE PROXY INICIADA"
msg -bar
fi
}
fi 
}
msg -bar
msg -tit
msg -ama "            AUTENTIFICAR PROXY SQUID "
msg -bar
unset squid_log1
[[ -e /usr/bin/squid_log1 ]] && squid_log1="\033[1;32m$(source trans -b pt:${id} "ACTIVO")"
echo -e "${cor[2]} [1] > ${cor[3]}AUTENTIFICAR O DESAUTENTIFICAR PROXY $squid_log1"
echo -e "${cor[2]} [0] > ${cor[4]}VOLVER"
msg -bar
echo -ne "\033[1;37mEscoja una Opcion: "
read optons
case $optons in
0)
msg -bar
exit
;;
1)
msg -bar
squidpass
;;
esac
#REINICIANDO VPS-MX (SQUID)
[[ "$1" = "1" ]] && squidpass
####_Eliminar_Tmps_####
[[ -e $_tmp ]] && rm $_tmp
[[ -e $_tmp2 ]] && rm $_tmp2
[[ -e $_tmp3 ]] && rm $_tmp3
[[ -e $_tmp4 ]] && rm $_tmp4