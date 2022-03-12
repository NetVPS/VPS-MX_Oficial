#!/bin/bash
SCPdir="/etc/VPS-MX" && [[ ! -d ${SCPdir} ]] && exit 1
SCPdir2="${SCPdir}/herramientas"
SCPusr="${SCPdir}/controlador"
MyPID="${SCPusr}/pid-vps-mx"
MyTIME="${SCPusr}/time-vps-mx"
USRdatabase="${SCPdir}/VPS-MXuser"

VERY="$(ps aux|grep "${SCPusr}/usercodes verificar"| grep -v grep)"
[[ -e ${MyPID} ]] && source ${MyPID} || touch ${MyPID}
[[ -e ${MyTIME} ]] && source ${MyTIME} || touch ${MyTIME}
[[ ! -e ${USRdatabase} ]] && touch ${USRdatabase}
sort ${USRdatabase} | uniq > ${USRdatabase}tmp
mv -f ${USRdatabase}tmp ${USRdatabase}

unlockall3 () {
for user in $(cat /etc/passwd |awk -F : '$3 > 900 {print $1}' |grep -v "rick" |grep -vi "nobody")
do
userpid=$(ps -u $user |awk {'print $1'})

usermod -U $user &>/dev/null
done
}
mostrar_usuarios () {
for u in `awk -F : '$3 > 900 { print $1 }' /etc/passwd | grep -v "nobody" |grep -vi polkitd |grep -vi system-`; do
echo "$u"
done
}
rm_user () {
#nome
userdel --force "$1" &>/dev/null || return 1
[[ -e ${USRdatabase} ]] && {
   newbase=$(cat ${USRdatabase}|grep -w -v "$1")
   for value in `echo ${newbase}`; do
   echo $value >> ${USRdatabase}
   done
   }
}
rm_vencidos () {
DataVPS=$(date +%s)
while read user; do
DataUser=$(chage -l "${user}" |grep -i co|awk -F ":" '{print $2}')
usr=$user
 while [[ ${#usr} -lt 20 ]]; do
 usr=$usr" "
 done
[[ "$DataUser" = " never" ]] && {
   echo -e "${yellow}$usr $never"
   continue
   }
DataSEC=$(date +%s --date="$DataUser")
if [[ "$DataSEC" -lt "$DataVPS" ]]; then
echo -ne "${yellow}$usr $expired"
rm_user "$user" && echo -e "($removido)"
else
echo -e "${yellow}$usr $valid"
fi
done <<< "$(mostrar_usuarios)"
rm -rf /etc/VPS-MX/VPS-MX-userlock
rm -rf /etc/VPS-MX/controlador/Limiter.log
}
unlockall3 &>/dev/null
rm_vencidos &>/dev/null
exit
