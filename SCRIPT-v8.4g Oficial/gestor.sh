# !/bin/bash
# 27/01/2021
clear
clear
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
SCPdir="/etc/VPS-MX" && [[ ! -d ${SCPdir} ]] && exit 1
SCPusr="${SCPdir}/controlador" && [[ ! -d ${SCPusr} ]] && mkdir ${SCPusr}
SCPfrm="${SCPdir}/herramientas" && [[ ! -d ${SCPfrm} ]] && mkdir ${SCPfrm}
SCPinst="${SCPdir}/protocolos" && [[ ! -d ${SCPfrm} ]] && mkdir ${SCPfrm}

fun_bar () {
comando="$1"
 _=$(
$comando > /dev/null 2>&1
) & > /dev/null
pid=$!
while [[ -d /proc/$pid ]]; do
echo -ne " \033[1;33m["
   for((i=0; i<10; i++)); do
   echo -ne "\033[1;31m##"
   sleep 0.2
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

update_pak () {
echo -ne " \033[1;31m[ ! ] apt-get update"
apt-get update -y > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] apt-get upgrade"
apt-get upgrade -y > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
msg -bar
return
}

reiniciar_ser () {
echo -ne " \033[1;31m[ ! ] Services stunnel4 restart"
service stunnel4 restart > /dev/null 2>&1
[[ -e /etc/init.d/stunnel4 ]] && /etc/init.d/stunnel4 restart > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] Services squid restart"
service squid restart > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] Services squid3 restart"
service squid3 restart > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] Services apache2 restart"
service apache2 restart > /dev/null 2>&1
[[ -e /etc/init.d/apache2 ]] && /etc/init.d/apache2 restart > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] Services openvpn restart"
service openvpn restart > /dev/null 2>&1
[[ -e /etc/init.d/openvpn ]] && /etc/init.d/openvpn restart > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] Services dropbear restart"
service dropbear restart > /dev/null 2>&1
[[ -e /etc/init.d/dropbear ]] && /etc/init.d/dropbear restart > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] Services ssh restart"
service ssh restart > /dev/null 2>&1
[[ -e /etc/init.d/ssh ]] && /etc/init.d/ssh restart > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] Services fail2ban restart"
( 
[[ -e /etc/init.d/ssh ]] && /etc/init.d/ssh restart
fail2ban-client -x stop && fail2ban-client -x start
) > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
msg -bar
return
}

reiniciar_vps () {
echo -ne " \033[1;31m[ ! ] Sudo Reboot"
sleep 3s
echo -e "\033[1;32m [OK]"
(
sudo reboot
) > /dev/null 2>&1
msg -bar
return
}

host_name () {
unset name
while [[ ${name} = "" ]]; do
echo -ne "\033[1;37m $(fun_trans "Nuevo nombre del host"): " && read name
tput cuu1 && tput dl1
done
hostnamectl set-hostname $name 
if [ $(hostnamectl status | head -1  | awk '{print $3}') = "${name}" ]; then 
echo -e "\033[1;33m $(fun_trans "Host alterado corretamente")!, $(fun_trans "reiniciar VPS")"
else
echo -e "\033[1;33m $(fun_trans "Host no modificado")!"
fi
msg -bar
return
}

cambiopass () {
echo -e "${cor[3]} $(fun_trans "Esta herramienta cambia la contraseña de su servidor vps")"
echo -e "${cor[3]} $(fun_trans "Esta contraseña es utilizada como usuario") root"
msg -bar
echo -ne " $(fun_trans "Desea Seguir?") [S/N]: "; read x
[[ $x = @(n|N) ]] && msg -bar && return
msg -bar
#Inicia Procedimentos
echo -e "${cor[0]} $(fun_trans "Escriba su nueva contraseña")"
msg -bar
read  -p " Nuevo passwd: " pass
(echo $pass; echo $pass)|passwd 2>/dev/null
sleep 1s
msg -bar
echo -e "${cor[3]} $(fun_trans "Contraseña cambiada con exito!")"
echo -e "${cor[2]} $(fun_trans "Su contraseña ahora es"): ${cor[4]}$pass"
msg -bar
return
}

rootpass () {
clear
msg -bar
echo -e "${cor[3]}  Esta herramienta cambia a usuario root las VPS de "
echo -e "${cor[3]}             GoogleCloud y Amazon"
msg -bar
echo -ne " Desea Seguir? [S/N]: "; read x
[[ $x = @(n|N) ]] && msg -bar && return
msg -bar
#Inicia Procedimentos
echo -e "                 Aplicando Configuraciones"
fun_bar "service ssh restart"
#Parametros Aplicados
sed -i "s;PermitRootLogin prohibit-password;PermitRootLogin yes;g" /etc/ssh/sshd_config
sed -i "s;PermitRootLogin without-password;PermitRootLogin yes;g" /etc/ssh/sshd_config
sed -i "s;PasswordAuthentication no;PasswordAuthentication yes;g" /etc/ssh/sshd_config
msg -bar
echo -e "Escriba su contraseña root actual o cambiela"
msg -bar
read  -p " Nuevo passwd: " pass
(echo $pass; echo $pass)|passwd 2>/dev/null
sleep 1s
msg -bar
echo -e "${cor[3]} Configuraciones aplicadas con exito!"
echo -e "${cor[2]} Su contraseña ahora es: ${cor[4]}$pass"
service ssh restart > /dev/null 2>&1
msg -bar
return
}


pamcrack () {
echo -e "${cor[3]} $(fun_trans "Liberar passwd para VURTL")"
msg -bar
echo -ne " $(fun_trans "Desea Seguir?") [S/N]: "; read x
[[ $x = @(n|N) ]] && msg -bar && return
echo -e ""
fun_bar "service ssh restart"
sed -i 's/.*pam_cracklib.so.*/password sufficient pam_unix.so sha512 shadow nullok try_first_pass #use_authtok/' /etc/pam.d/common-password
fun_bar "service ssh restart"
echo -e ""
echo -e " \033[1;31m[ ! ]\033[1;33m $(fun_trans "Configuraciones VURTL aplicadas")"
msg -bar
return
}

timemx () {
rm -rf /etc/localtime
ln -s /usr/share/zoneinfo/America/Merida /etc/localtime
echo -e " FECHA LOCAL MX APLICADA!"
}

timearg () {
rm -rf /etc/localtime
ln -sf /usr/share/zoneinfo/America/Argentina/Buenos_Aires /etc/localtime
echo -e " FECHA LOCAL ARG APLICADA!"
}


gestor_fun () {
clear
msg -bar
msg -tit
echo -e " ${cor[3]}             AJUSTES INTERNOS DEL VPS  "
msg -bar
while true; do
echo -e "${cor[4]} [1] > \033[1;36mACTULIZAR VPS"
echo -e "${cor[4]} [2] > \033[1;36mREINICIAR SERVICIOS"
echo -e "${cor[4]} [3] > \033[1;36mREINICIAR VPS"
echo -e "${cor[4]} [4] > \033[1;36mCAMBIAR HOSTNAME VPS"
echo -e "${cor[4]} [5] > \033[1;36mCAMBIAR CONTRASEÑA ROOT"
echo -e "${cor[4]} [6] > \033[1;36mCAMBIAR HORA LOCAL MX"
echo -e "${cor[4]} [7] > \033[1;36mCAMBIAR HORA LOCAL ARG"
echo -e "${cor[2]} [8] > \033[1;100mAGREGAR ROOT a GoogleCloud y Amazon \033[0;37m"
echo -e "$(msg -bar)\n${cor[4]} [0] > \e[97m\033[1;41m VOLVER \033[1;37m"
while [[ ${opx} != @(0|[1-9]) ]]; do
msg -bar
echo -ne " Seleccione una Opcion: \033[1;37m" && read opx
tput cuu1 && tput dl1
done
case $opx in
	0)
	return;;
	1)
	update_pak
	break;;
	2)
	reiniciar_ser
	break;;
	3)
	reiniciar_vps
	break;;
	4)
	host_name
	break;;
	5)
	cambiopass
	break;;
	6)
	timemx
	break;;
	7)
	timearg
	break;;
	8)
	rootpass
	break;;
esac
done
}
gestor_fun