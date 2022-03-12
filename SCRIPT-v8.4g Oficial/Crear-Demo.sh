#!/bin/bash
#24/01/2021
clear
clear
msg -bar
rm -rf /etc/VPS-MX/demo-ssh 2>/dev/null
mkdir /etc/VPS-MX/demo-ssh 2>/dev/null
SCPdir="/etc/VPS-MX"
SCPusr="${SCPdir}/controlador"

declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
SCPdir="/etc/VPS-MX"
SCPfrm="${SCPdir}/herramientas" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="${SCPdir}/protocolos" && [[ ! -d ${SCPinst} ]] && exit

tmpusr () {
time="$1"
timer=$(( $time * 60 ))
timer2="'$timer's"
echo "#!/bin/bash
sleep $timer2
kill"' $(ps -u '"$2 |awk '{print"' $1'"}') 1> /dev/null 2> /dev/null
userdel --force $2
rm -rf /tmp/$2
exit" > /tmp/$2
}

tmpusr2 () {
time="$1"
timer=$(( $time * 60 ))
timer2="'$timer's"
echo "#!/bin/bash
sleep $timer2
kill=$(dropb | grep "$2" | awk '{print $2}')
kill $kill
userdel --force $2
rm -rf /tmp/$2
exit" > /tmp/$2
}
echo  -e "$(msg -tit)$(msg -bar) " 
msg -ama "        CREAR USUARIO POR TIEMPO (Minutos)"
msg -bar
echo -e "\033[1;97m Los Usuarios que cres en esta opcion se eliminaran\n automaticamete pasando el tiempo designado.\033[0m"
msg -bar

echo -e "\033[1;91m [1]-\033[1;97mNombre del usuario:\033[0;37m"; read -p " " name
if [[ -z $name ]]
then
echo "No a digitado el Nuevo Usuario"
exit
fi
if cat /etc/passwd |grep $name: |grep -vi [a-z]$name |grep -v [0-9]$name > /dev/null
then
echo -e "\033[1;31mUsuario $name ya existe\033[0m"
exit
fi
echo -e "\033[1;91m [2]-\033[1;97mContraseña para usuario $name:\033[0;37m"; read -p " " pass
echo -e "\033[1;91m [3]-\033[1;97mTiempo de Duración En Minutos:\033[0;37m"; read -p " " tmp
if [ "$tmp" = "" ]; then
tmp="30"
echo -e "\033[1;32mFue Definido 30 minutos Por Defecto!\033[0m"
msg -bar
sleep 2s
fi
useradd -M -s /bin/false $name
(echo $pass; echo $pass)|passwd $name 2>/dev/null
touch /tmp/$name
tmpusr $tmp $name
chmod 777 /tmp/$name
touch /tmp/cmd
chmod 777 /tmp/cmd
echo "nohup /tmp/$name & >/dev/null" > /tmp/cmd
/tmp/cmd 2>/dev/null 1>/dev/null
rm -rf /tmp/cmd
touch /etc/VPS-MX/demo-ssh/$name
echo "senha: $pass" >> /etc/VPS-MX/demo-ssh/$name
echo "data: ($tmp)Minutos" >> /etc/VPS-MX/demo-ssh/$name
msg -bar2
echo -e "\033[1;93m ¡¡ USUARIO TEMPORAL x MINUTOS (VPS-MX By @Kalix1) !!\033[0m"
msg -bar2
echo -e "\033[1;36m  >> IP del Servidor: \033[0m$(meu_ip) " 
echo -e "\033[1;36m  >> Usuario: \033[0m$name"
echo -e "\033[1;36m  >> Contraseña: \033[0m$pass"
echo -e "\033[1;36m  >> Minutos de Duración: \033[0m$tmp"
msg -bar2
msg -ne " Enter Para Continuar" && read enter
${SCPusr}/usercodes

