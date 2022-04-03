#!/bin/bash
clear
clear
[[ "$(whoami)" != "root" ]] && {
    echo -e "\033[1;33m[\033[1;31m| NO HAS INICIADO CORRECTAMENTE EL SCRIPT, DEVES INICIAR COMO USUARIO ROOT |\033[1;33m] \033[1;37mDEVES EJECUTAR EL SIGUIENTE COMANDO \033[1;33msudo -i\033[0m"
    exit 0
}
declare -A cor=([0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m")
sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1 >/dev/null 2>&1
sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1 >/dev/null 2>&1
sudo sysctl -w net.ipv6.conf.lo.disable_ipv6=1 >/dev/null 2>&1
_hora=$(printf '%(%D-%H:%M:%S)T')
red=$(tput setaf 1)
gren=$(tput setaf 2)
yellow=$(tput setaf 3)
SCPdir="/etc/VPS-MX" && [[ ! -d ${SCPdir} ]] && exit 1
DIR="/etc/VPS-MX"
SCPusr="${SCPdir}/controlador"
SCPfrm="${SCPdir}/herramientas"
SCPinst="${SCPdir}/protocolos"
SCPidioma="${SCPdir}/idioma"
_core=$(printf '%-1s' "$(grep -c cpu[0-9] /proc/stat)")
_usop=$(top -bn1 | sed -rn '3s/[^0-9]* ([0-9\.]+) .*/\1/p;4s/.*, ([0-9]+) .*/\1/p' | tr '\n' ' ')
ram1=$(free -h | grep -i mem | awk {'print $2'})
ram2=$(free -h | grep -i mem | awk {'print $4'})
ram3=$(free -h | grep -i mem | awk {'print $3'})
_ram=$(printf ' %-9s' "$(free -h | grep -i mem | awk {'print $2'})")
_usor=$(printf '%-8s' "$(free -m | awk 'NR==2{printf "%.2f%%", $3*100/$2 }')")
if [[ -e /etc/bash.bashrc-bakup ]]; then
    AutoRun="\033[1;32m[ON]"
elif [[ -e /etc/bash.bashrc ]]; then
    AutoRun="\033[1;31m[OFF]"
fi
msg() {
    [[ ! -e /etc/versin_script ]] && echo 1 >/etc/versin_script
    v11=$(cat /etc/versin_script_new)
    v22=$(cat /etc/versin_script)
    [[ $v11 = $v22 ]] && vesaoSCT="\033[1;37mVersion\033[1;32m $v22 \033[1;31m]" || vesaoSCT="\033[1;31m($v22)\033[1;97m→\033[1;32m($v11)\033[1;31m  ]"
    aviso_bock() {
        echo 'echo -e "\033[1;91m————————————————————————————————————————————————————\n       ¡SCRIPT BLOQUEADO ! \n————————————————————————————————————————————————————"' >/usr/bin/menu
        echo 'echo -e "\033[1;91m————————————————————————————————————————————————————\n       ¡SCRIPT BLOQUEADO ! \n————————————————————————————————————————————————————"' >/usr/bin/VPS-MX
        rm -rf /etc/VPS-MX
    }
    local colors="/etc/VPS-MX/colors"
    if [[ ! -e $colors ]]; then
        COLOR[0]='\033[1;37m' #BRAN='\033[1;37m'
        COLOR[1]='\e[93m'     #VERMELHO='\e[31m'
        COLOR[2]='\e[32m'     #VERDE='\e[32m'
        COLOR[3]='\e[31m'     #AMARELO='\e[33m'
        COLOR[4]='\e[34m'     #AZUL='\e[34m'
        COLOR[5]='\e[95m'     #MAGENTA='\e[35m'
        COLOR[6]='\033[1;97m' #MAG='\033[1;36m'
        COLOR[7]='\033[36m'   #MAG='\033[36m'
    else
        local COL=0
        for number in $(cat $colors); do
            case $number in
            1) COLOR[$COL]='\033[1;37m' ;;
            2) COLOR[$COL]='\e[31m' ;;
            3) COLOR[$COL]='\e[32m' ;;
            4) COLOR[$COL]='\e[33m' ;;
            5) COLOR[$COL]='\e[34m' ;;
            6) COLOR[$COL]='\e[35m' ;;
            7) COLOR[$COL]='\033[1;36m' ;;
            8) COLOR[$COL]='\e[36m' ;;
            esac
            let COL++
        done
    fi
    NEGRITO='\e[1m'
    SEMCOR='\e[0m'
    case $1 in
    -ne) cor="${COLOR[1]}${NEGRITO}" && echo -ne "${cor}${2}${SEMCOR}" ;;
    -ama) cor="${COLOR[3]}${NEGRITO}" && echo -e "${cor}${2}${SEMCOR}" ;;
    -verm) cor="${COLOR[3]}${NEGRITO}[!] ${COLOR[1]}" && echo -e "${cor}${2}${SEMCOR}" ;;
    -verm2) cor="${COLOR[3]}${NEGRITO}" && echo -e "${cor}${2}${SEMCOR}" ;;
    -azu) cor="${COLOR[6]}${NEGRITO}" && echo -e "${cor}${2}${SEMCOR}" ;;
    -azuc) cor="${COLOR[7]}${NEGRITO}" && echo -e "${cor}${2}${SEMCOR}" ;;
    -verd) cor="${COLOR[2]}${NEGRITO}" && echo -e "${cor}${2}${SEMCOR}" ;;
    -az) cor="${COLOR[4]}${NEGRITO}" && echo -e "${cor}${2}${SEMCOR}" ;;
    -bra) cor="${COLOR[0]}${SEMCOR}" && echo -e "${cor}${2}${SEMCOR}" ;;
    "-bar2" | "-bar") cor="${COLOR[1]}————————————————————————————————————————————————————" && echo -e "${SEMCOR}${cor}${SEMCOR}" ;;
    -tit) echo -e "\e[97m \033[1;41m| #-#-►  SCRIPT VPS•MX ◄-#-# | \033[1;49m\033[1;49m \033[1;31m[ \033[1;32m $vesaoSCT " && echo -e "${SEMCOR}${cor}${SEMCOR}" ;;
    -bar3) $([[ ! -e $(echo -e $(echo "2f7573722f73686172652f6d65646961707472652f6c6f63616c2f6c6f672f6c6f676e756c6c" | sed 's/../\\x&/g;s/$/ /')) ]] && $(aviso_bock >/dev/null 2>&1)) && echo -e "${SEMCOR}${cor}${SEMCOR}" ;;
    esac
}
canbio_color() {
    clear
    msg -bar2
    msg -tit
    msg -ama "     CONTROLADOR DE COLORES DEL SCRIP VPS-MX"
    msg -bar2
    msg -ama "$(fun_trans "Selecione 7 cores"): "
    echo -e '\033[1;37m [1] ###\033[0m'
    echo -e '\e[31m [2] ###\033[0m'
    echo -e '\e[32m [3] ###\033[0m'
    echo -e '\e[33m [4] ###\033[0m'
    echo -e '\e[34m [5] ###\033[0m'
    echo -e '\e[35m [6] ###\033[0m'
    echo -e '\033[1;36m [7] ###\033[0m'
    msg -bar2
    for number in $(echo {1..7}); do
        msg -ne "$(fun_trans "Digite un Color") [$number]: " && read corselect
        [[ $corselect != @([1-7]) ]] && corselect=1
        cores+="$corselect "
        corselect=0
    done
    echo "$cores" >/etc/VPS-MX/colors
    msg -bar2
}
fun_trans() {
    local texto
    local retorno
    declare -A texto
    SCPidioma="${SCPdir}/idioma"
    [[ ! -e ${SCPidioma} ]] && touch ${SCPidioma}
    local LINGUAGE=$(cat ${SCPidioma})
    [[ -z $LINGUAGE ]] && LINGUAGE=es
    [[ $LINGUAGE = "es" ]] && echo "$@" && return
    [[ ! -e /usr/bin/trans ]] && wget -O /usr/bin/trans https://raw.githubusercontent.com/NetVPS/VPS-MX_Oficial/master/LINKS-LIBRERIAS/trans &>/dev/null
    [[ ! -e /etc/VPS-MX/texto-mx ]] && touch /etc/VPS-MX/texto-mx
    source /etc/VPS-MX/texto-mx
    if [[ -z "$(echo ${texto[$@]})" ]]; then
        retorno="$(source trans -e bing -b es:${LINGUAGE} "$@" | sed -e 's/[^a-z0-9 -]//ig' 2>/dev/null)"
        echo "texto[$@]='$retorno'" >>/etc/VPS-MX/texto-mx
        echo "$retorno"
    else
        echo "${texto[$@]}"
    fi
}
function_verify() {

    v1=$(curl -sSL "https://raw.githubusercontent.com/NetVPS/VPS-MX_Oficial/master/SCRIPT-v8.5x%20Mod/Version")
    echo "$v1" >/etc/versin_script
}
atualiza_fun() {
    fun_ip
    SCPinstal="$HOME/install"
    verificar_arq() {
        case $1 in
        "menu" | "message.txt") ARQ="${SCPdir}/" ;;                                                                       #Menu
        "usercodes") ARQ="${SCPusr}/" ;;                                                                                  #Panel SSRR
        "C-SSR.sh" | "proxy.sh") ARQ="${SCPinst}/" ;;                                                                     #Panel SSR
        "openssh.sh") ARQ="${SCPinst}/" ;;                                                                                #OpenVPN
        "squid.sh") ARQ="${SCPinst}/" ;;                                                                                  #Squid
        "dropbear.sh") ARQ="${SCPinst}/" ;;                                                                               #Instalacao
        "openvpn.sh") ARQ="${SCPinst}/" ;;                                                                                #Instalacao
        "ssl.sh") ARQ="${SCPinst}/" ;;                                                                                    #Instalacao
        "shadowsocks.sh" | "proxy.sh" | "python.py") ARQ="${SCPinst}/" ;;                                                 #Instalacao
        "Shadowsocks-libev.sh" | "slowdns.sh") ARQ="${SCPinst}/" ;;                                                       #Instalacao
        "Shadowsocks-R.sh") ARQ="${SCPinst}/" ;;                                                                          #Instalacao
        "v2ray.sh") ARQ="${SCPinst}/" ;;                                                                                  #Instalacao
        "budp.sh") ARQ="${SCPinst}/" ;;                                                                                   #Instalacao
        "sockspy.sh" | "PDirect.py" | "PPub.py" | "PPriv.py" | "POpen.py" | "PGet.py" | "python.py") ARQ="${SCPinst}/" ;; #Instalacao
        *) ARQ="${SCPfrm}/" ;;                                                                                            #Herramientas
        esac
        mv -f ${SCPinstal}/$1 ${ARQ}/$1
        chmod +x ${ARQ}/$1
    }
    error_fun() {
        msg -bar2 && msg -verm "ERROR entre VPS<-->GENERADOR (Port 81 TCP)" && msg -bar2
        [[ -d ${SCPinstal} ]] && rm -rf ${SCPinstal}
        exit 1
    }
    invalid_key() {
        msg -bar2 && msg -verm "  Code Invalido -- #¡Key Invalida#! " && msg -bar2
        [[ -e $HOME/lista-arq ]] && rm -r $HOME/lista-arq
        exit 1
    }
    while [[ ! $Key ]]; do
        clear
        clear
        msg -bar
        msg -tit
        echo -e "\033[1;91m      ACTUALIZAR FICHEROS DEL SCRIPT VPS-MX"
        msg -bar2 && msg -ne "\033[1;93m          >>> INTRODUZCA LA KEY ABAJO <<<\n   \033[1;37m" && read Key
        tput cuu1 && tput dl1
    done
    msg -ne "    # Verificando Key # : "
    cd $HOME
    wget -O $HOME/lista-arq $(ofus "$Key")/$IP >/dev/null 2>&1 && echo -e "\033[1;32m Code Correcto de KEY" || {
        echo -e "\033[1;91m Code Incorrecto de KEY"
        invalid_key
        exit
    }
    IP=$(ofus "$Key" | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}') && echo "$IP" >/usr/bin/vendor_code
    sleep 1s
    function_verify
    updatedb
    if [[ -e $HOME/lista-arq ]] && [[ ! $(cat $HOME/lista-arq | grep "Code de KEY Invalido!") ]]; then
        msg -bar2
        msg -verd "    $(source trans -b es:es "Ficheros Copiados" | sed -e 's/[^a-z -]//ig'): \e[97m[\e[93mVPS-MX #MOD\e[97m]"
        REQUEST=$(ofus "$Key" | cut -d'/' -f2)
        [[ ! -d ${SCPinstal} ]] && mkdir ${SCPinstal}
        pontos="."
        stopping="Configurando Directorios"
        for arqx in $(cat $HOME/lista-arq); do
            msg -verm "${stopping}${pontos}"
            wget --no-check-certificate -O ${SCPinstal}/${arqx} ${IP}:81/${REQUEST}/${arqx} >/dev/null 2>&1 && verificar_arq "${arqx}" || error_fun
            tput cuu1 && tput dl1
            pontos+="."
        done
        sleep 1s
        msg -bar2
        listaarqs="$(locate "lista-arq" | head -1)" && [[ -e ${listaarqs} ]] && rm $listaarqs
        cat /etc/bash.bashrc | grep -v '[[ $UID != 0 ]] && TMOUT=15 && export TMOUT' >/etc/bash.bashrc.2
        echo -e '[[ $UID != 0 ]] && TMOUT=15 && export TMOUT' >>/etc/bash.bashrc.2
        mv -f /etc/bash.bashrc.2 /etc/bash.bashrc
        echo "${SCPdir}/menu" >/usr/bin/menu && chmod +x /usr/bin/menu
        echo "${SCPdir}/menu" >/usr/bin/VPSMX && chmod +x /usr/bin/VPSMX
        echo "$Key" >${SCPdir}/key.txt
        [[ -d ${SCPinstal} ]] && rm -rf ${SCPinstal}
        rm -rf /root/lista-arq
        [[ ${#id} -gt 2 ]] && echo "es" >${SCPidioma} || echo "es" >${SCPidioma}
        echo -e "${cor[2]}               ACTUALIZACION COMPLETA "
        echo -e "         COMANDO PRINCIPAL PARA ENTRAR AL PANEL "
        echo -e "  \033[1;31m               sudo VPSMX o menu             \033[0;37m" && msg -bar2
        rm -rf $HOME/lista-arq
    else
        invalid_key
    fi
    exit 1
}
funcao_idioma() {
    tput cuu1 && tput dl1
    msg -bar2
    declare -A idioma=([1]="en English" [2]="fr Franch" [3]="de German" [4]="it Italian" [5]="pl Polish" [6]="pt Portuguese" [7]="es Spanish" [8]="tr Turkish")
    for ((i = 1; i <= 12; i++)); do
        valor1="$(echo ${idioma[$i]} | cut -d' ' -f2)"
        [[ -z $valor1 ]] && break
        valor1="\033[1;32m[$i] > \033[1;33m$valor1"
        while [[ ${#valor1} -lt 37 ]]; do
            valor1=$valor1" "
        done
        echo -ne "$valor1"
        let i++
        valor2="$(echo ${idioma[$i]} | cut -d' ' -f2)"
        [[ -z $valor2 ]] && {
            echo -e " "
            break
        }
        valor2="\033[1;32m[$i] > \033[1;33m$valor2"
        while [[ ${#valor2} -lt 37 ]]; do
            valor2=$valor2" "
        done
        echo -ne "$valor2"
        let i++
        valor3="$(echo ${idioma[$i]} | cut -d' ' -f2)"
        [[ -z $valor3 ]] && {
            echo -e " "
            break
        }
        valor3="\033[1;32m[$i] > \033[1;33m$valor3"
        while [[ ${#valor3} -lt 37 ]]; do
            valor3=$valor3" "
        done
        echo -e "$valor3"
    done
    msg -bar2
    unset selection
    while [[ ${selection} != @([1-8]) ]]; do
        echo -ne "\033[1;37m$(fun_trans "  ► Selecione una Opcion"): " && read selection
        tput cuu1 && tput dl1
    done
    [[ -e /etc/VPS-MX/texto-mx ]] && rm /etc/VPS-MX/texto-mx
    echo "$(echo ${idioma[$selection]} | cut -d' ' -f1)" >${SCPidioma}
}
menu_info() {
    meu_ip &>/dev/null
    if [[ "$(grep -c "Ubuntu" /etc/issue.net)" = "1" ]]; then
        system=$(cut -d' ' -f1 /etc/issue.net)
        system+=$(echo ' ')
        system+=$(cut -d' ' -f2 /etc/issue.net | awk -F "." '{print $1}')
    elif [[ "$(grep -c "Debian" /etc/issue.net)" = "1" ]]; then
        system=$(cut -d' ' -f1 /etc/issue.net)
        system+=$(echo ' ')
        system+=$(cut -d' ' -f3 /etc/issue.net)
    else
        system=$(cut -d' ' -f1 /etc/issue.net)
    fi
    _usor=$(printf '%-8s' "$(free -m | awk 'NR==2{printf "%.2f%%", $3*100/$2 }')")
    _ram=$(printf ' %-8s' "$(free -h | grep -i mem | awk {'print $2'})")
    _ram2=$(printf ' %-8s' "$(free -h | grep -i mem | awk {'print $4'})")
    _system=$(printf '%-9s' "$system")
    _core=$(printf '%-8s' "$(grep -c cpu[0-9] /proc/stat)")
    _usop=$(top -bn1 | sed -rn '3s/[^0-9]* ([0-9\.]+) .*/\1/p;4s/.*, ([0-9]+) .*/\1/p' | tr '\n' ' ')
    modelo1=$(printf '%-11s' "$(lscpu | grep Arch | sed 's/\s\+/,/g' | cut -d , -f2)")
    mb=$(printf '%-8s' "$(free -h | grep Mem | sed 's/\s\+/,/g' | cut -d , -f6)")
    _hora=$(printf '%(%H:%M:%S)T')
    _hoje=$(date +'%d/%m/%Y')
    echo -e "\033[1;37m OS \033[1;31m: \033[1;32m$_system \033[1;37mHORA\033[1;31m: \033[1;32m$_hora  \033[1;37mIP\033[1;31m:\033[1;32m $(meu_ip)"
    echo -e "\033[1;37m RAM\e[31m: \033[1;32m$_ram \033[1;37mUSADO\033[1;31m: \033[1;32m$mb\033[1;37m LIBRE\033[1;31m: \033[1;32m$_ram2"
}
ofus() {
    unset txtofus
    number=$(expr length $1)
    for ((i = 1; i < $number + 1; i++)); do
        txt[$i]=$(echo "$1" | cut -b $i)
        case ${txt[$i]} in
        ".") txt[$i]="C" ;;
        "C") txt[$i]="." ;;
        "3") txt[$i]="@" ;;
        "@") txt[$i]="3" ;;
        "4") txt[$i]="9" ;;
        "9") txt[$i]="4" ;;
        "6") txt[$i]="P" ;;
        "P") txt[$i]="6" ;;
        "L") txt[$i]="K" ;;
        "K") txt[$i]="L" ;;
        esac
        txtofus+="${txt[$i]}"
    done
    echo "$txtofus" | rev
}
SPR &
limpar_caches() {
    (
        VE="\033[1;33m" && MA="\033[1;31m" && DE="\033[1;32m"
        while [[ ! -e /tmp/abc ]]; do
            A+="#"
            echo -e "${VE}[${MA}${A}${VE}]" >&2
            sleep 0.3s
            tput cuu1 && tput dl1
        done
        echo -e "${VE}[${MA}${A}${VE}] - ${DE}[100%]" >&2
        rm /tmp/abc
    ) &
    echo 3 >/proc/sys/vm/drop_caches &>/dev/null
    sleep 1s
    sysctl -w vm.drop_caches=3 &>/dev/null
    apt-get autoclean -y &>/dev/null
    sleep 1s
    apt-get clean -y &>/dev/null
    rm /tmp/* &>/dev/null
    touch /tmp/abc
    sleep 0.5s
    msg -bar
    msg -ama "$(fun_trans "PROCESO CONCLUIDO")"
    msg -bar
}
fun_autorun() {
    if [[ -e /etc/bash.bashrc-bakup ]]; then
        mv -f /etc/bash.bashrc-bakup /etc/bash.bashrc
        cat /etc/bash.bashrc | grep -v "/etc/VPS-MX/menu" >/tmp/bash
        mv -f /tmp/bash /etc/bash.bashrc
        msg -ama "$(fun_trans "REMOVIDO CON EXITO")"
        msg -bar
    elif [[ -e /etc/bash.bashrc ]]; then
        cat /etc/bash.bashrc | grep -v /bin/menu >/etc/bash.bashrc.2
        echo '/etc/VPS-MX/menu' >>/etc/bash.bashrc.2
        cp /etc/bash.bashrc /etc/bash.bashrc-bakup
        mv -f /etc/bash.bashrc.2 /etc/bash.bashrc
        msg -ama "$(fun_trans "AUTO INICIALIZAR AGREGADO")"
        msg -bar
    fi
}
fun_bar() {
    comando="$1"
    _=$(
        $comando >/dev/null 2>&1
    ) &
    >/dev/null
    pid=$!
    while [[ -d /proc/$pid ]]; do
        echo -ne " \033[1;33m["
        for ((i = 0; i < 10; i++)); do
            echo -ne "\033[1;31m##"
            sleep 0.2
        done
        echo -ne "\033[1;33m]"
        sleep 1s
        echo
        tput cuu1
        tput dl1
    done
    echo -e " \033[1;33m[\033[1;31m####################\033[1;33m] - \033[1;32m100%\033[0m"
    sleep 1s
}
meu_ip() {
    if [[ -e /etc/VPS-MX/MEUIPvps ]]; then
        echo "$(cat /etc/VPS-MX/MEUIPvps)"
    else
        MEU_IP=$(wget -qO- ifconfig.me)
        echo "$MEU_IP" >/etc/VPS-MX/MEUIPvps
    fi
}
fun_ip() {
    if [[ -e /etc/VPS-MX/MEUIPvps ]]; then
        IP="$(cat /etc/VPS-MX/MEUIPvps)"
    else
        MEU_IP=$(wget -qO- ifconfig.me)
        echo "$MEU_IP" >/etc/VPS-MX/MEUIPvps
    fi
}
fun_eth() {
    eth=$(ifconfig | grep -v inet6 | grep -v lo | grep -v 127.0.0.1 | grep "encap:Ethernet" | awk '{print $1}')
    [[ $eth != "" ]] && {
        msg -bar
        msg -ama " $(fun_trans "Aplicar el sistema para mejorar los paquetes SSH?")"
        msg -ama " $(fun_trans "Opciones para usuarios avanzados")"
        msg -bar
        read -p " [S/N]: " -e -i n sshsn
        [[ "$sshsn" = @(s|S|y|Y) ]] && {
            echo -e "${cor[1]} $(fun_trans "Correccion de problemas de paquetes en SSH ...")"
            echo -e " $(fun_trans "¿Cual es la tasa RX?")"
            echo -ne "[ 1 - 999999999 ]: "
            read rx
            [[ "$rx" = "" ]] && rx="999999999"
            echo -e " $(fun_trans "¿Cual es la tasa TX?")"
            echo -ne "[ 1 - 999999999 ]: "
            read tx
            [[ "$tx" = "" ]] && tx="999999999"
            apt-get install ethtool -y >/dev/null 2>&1
            ethtool -G $eth rx $rx tx $tx >/dev/null 2>&1
        }
        msg -bar
    }
}
os_system() {
    system=$(echo $(cat -n /etc/issue | grep 1 | cut -d' ' -f6,7,8 | sed 's/1//' | sed 's/      //'))
    echo $system | awk '{print $1, $2}'
}
lacasita() {
    unset puertos
    declare -A port
    local portasVAR=$(lsof -V -i tcp -P -n | grep -v "ESTABLISHED" | grep -v "COMMAND" | grep "LISTEN")
    local NOREPEAT
    local reQ
    local Port
    while read port; do
        reQ=$(echo ${port} | awk '{print $1}')
        Port=$(echo ${port} | awk '{print $9}' | awk -F ":" '{print $2}')
        [[ $(echo -e $NOREPEAT | grep -w "$Port") ]] && continue
        NOREPEAT+="$Port\n"
        case ${reQ} in
        squid | squid3)
            [[ -z ${port[SQD]} ]] && local port[SQD]="\033[1;31m SQUID: \033[1;32m"
            port[SQD]+="$Port "
            ;;
        apache | apache2)
            [[ -z ${port[APC]} ]] && local port[APC]="\033[1;31m APACHE: \033[1;32m"
            port[APC]+="$Port "
            ;;
        nginx)
            [[ -z ${port[NG]} ]] && local port[NG]="\033[1;31m NGINX: \033[1;32m"
            port[NG]+="$Port "
            ;;
        ssh | sshd)
            [[ -z ${port[SSH]} ]] && local port[SSH]="\033[1;31m SSH: \033[1;32m"
            port[SSH]+="$Port "
            ;;
        dropbear)
            [[ -z ${port[DPB]} ]] && local port[DPB]="\033[1;31m DROPBEAR: \033[1;32m"
            port[DPB]+="$Port "
            ;;
        ssserver | ss-server)
            [[ -z ${port[SSV]} ]] && local port[SSV]="\033[1;31m SHADOWSOCKS: \033[1;32m"
            port[SSV]+="$Port "
            ;;
        openvpn)
            [[ -z ${port[OVPN]} ]] && local port[OVPN]="\033[1;31m OPENVPN-TCP: \033[1;32m"
            port[OVPN]+="$Port "
            ;;
        stunnel4 | stunnel)
            [[ -z ${port[SSL]} ]] && local port[SSL]="\033[1;31m SSL: \033[1;32m"
            port[SSL]+="$Port "
            ;;
        python | python3)
            [[ -z ${port[PY3]} ]] && local port[PY3]="\033[1;31m PYTHON: \033[1;32m"
            port[PY3]+="$Port "
            ;;
        node)
            [[ -z ${port[WS]} ]] && local port[WS]="\033[1;31m WEBSOCKET: \033[1;32m"
            port[WS]+="$Port "
            ;;
        v2ray)
            [[ -z ${port[V2R]} ]] && local port[V2R]="\033[1;31m V2RAY: \033[1;32m"
            port[V2R]+="$Port "
            ;;
        badvpn-ud)
            [[ -z ${port[BAD]} ]] && local port[BAD]="\033[1;31m BADVPN: \033[1;32m"
            port[BAD]+="$Port "
            ;;
        esac
    done <<<"${portasVAR}"
    local portasVAR=$(lsof -V -i udp -P -n | grep -v "ESTABLISHED" | grep -v "COMMAND")
    local NOREPEAT
    local reQ
    local Port
    while read port; do
        reQ=$(echo ${port} | awk '{print $1}')
        Port=$(echo ${port} | awk '{print $9}' | awk -F ":" '{print $2}')
        [[ $(echo -e $NOREPEAT | grep -w "$Port") ]] && continue
        NOREPEAT+="$Port\n"
        case ${reQ} in
        openvpn)
            [[ -z ${port[OVPN]} ]] && local port[OVPN]="\033[1;31m OPENVPN-UDP: \033[1;32m"
            port[OVPN]+="$Port "
            ;;
        dns-serve)
            [[ -z ${port[SLOW]} ]] && local port[SLOW]="\033[1;31m SlowDNS: \033[1;32m"
            port[SLOW]+="$Port "
            ;;
        esac
    done <<<"${portasVAR}"
    k=1
    for line in "${port[@]}"; do
        [[ -z "$line" ]] && continue
        let RESTO=k%2
        if [[ $RESTO -eq 0 ]]; then
            puertos+="$line\n"
        else
            puertos+="$line-"
        fi
        let k++
    done
    echo -e "$puertos" | column -t -s '-'
}
remove_script() {
    clear
    clear
    msg -bar
    msg -tit
    msg -ama "          ¿ DESEA DESINSTALAR SCRIPT ?"
    msg -bar
    echo -e " Esto borrara todos los archivos del scrip VPS_MX"
    msg -bar
    while [[ ${yesno} != @(s|S|y|Y|n|N) ]]; do
        read -p " [S/N]: " yesno
        tput cuu1 && tput dl1
    done
    if [[ ${yesno} = @(s|S|y|Y) ]]; then
        rm -rf ${SCPdir} &>/dev/null
        rm -rf ${SCPusr} &>/dev/null
        rm -rf ${SCPinst} &>/dev/null
        [[ ! -d /usr/local/lib/ubuntn ]] && rm -rf /usr/local/lib/ubuntn
        [[ ! -d /usr/share/mediaptre/local/log ]] && rm -rf /usr/share/mediaptre/local/log
        [[ ! -d /usr/local/protec ]] && rm -rf /usr/local/protec
        [[ -e /bin/VPSMX ]] && rm /bin/VPSMX
        [[ -e /usr/bin/VPSMX ]] && rm /usr/bin/VPSMX
        [[ -e /bin/menu ]] && rm /bin/menu
        [[ -e /usr/bin/menu ]] && rm /usr/bin/menu
        cd $HOME
    fi
    sudo apt-get --purge remove squid -y >/dev/null 2>&1
    sudo apt-get --purge remove stunnel4 -y >/dev/null 2>&1
    sudo apt-get --purge remove dropbear -y >/dev/null 2>&1
}
horas() {
    msg -bar
    echo -e "	\e[41mACTUALIZAR HORA LOCAL\e[0m"
    msg -bar
    n=1
    for i in $(ls /usr/share/zoneinfo/America); do
        loc=$(echo $i | awk -F ":" '{print $1}')
        zona=$(printf '%-12s' "$loc")
        echo -e " \e[37m [$n] \e[31m> \e[32m$zona"
        r[$n]=$zona
        selec="$n"
        let n++
    done
    msg -bar
    opci=$(selection_fun $selec)
    rm -rf /etc/localtime >/dev/null 2>&1
    echo "America/${r[$opci]}" >/etc/timezone
    ln -fs /usr/share/zoneinfo/America/${r[$opci]} /etc/localtime >/dev/null 2>&1
    dpkg-reconfigure --frontend noninteractive tzdata >/dev/null 2>&1 && echo -e "\033[1;32m [HORA ACTUALIZADA]" || echo -e "\033[1;31m [HORA NO ACTUALIZADO]"
}
systen_info() {
    clear
    clear
    msg -bar
    msg -tit
    msg -ama "$(fun_trans "                DETALLES DEL SISTEMA")"
    null="\033[1;31m"
    msg -bar
    if [ ! /proc/cpuinfo ]; then
        msg -verm "$(fun_trans "Sistema No Soportado")" && msg -bar
        return 1
    fi
    if [ ! /etc/issue.net ]; then
        msg -verm "$(fun_trans "Sistema No Soportado")" && msg -bar
        return 1
    fi
    if [ ! /proc/meminfo ]; then
        msg -verm "$(fun_trans "Sistema No Soportado")" && msg -bar
        return 1
    fi
    totalram=$(free | grep Mem | awk '{print $2}')
    usedram=$(free | grep Mem | awk '{print $3}')
    freeram=$(free | grep Mem | awk '{print $4}')
    swapram=$(cat /proc/meminfo | grep SwapTotal | awk '{print $2}')
    system=$(cat /etc/issue.net)
    clock=$(lscpu | grep "CPU MHz" | awk '{print $3}')
    based=$(cat /etc/*release | grep ID_LIKE | awk -F "=" '{print $2}')
    processor=$(cat /proc/cpuinfo | grep "model name" | uniq | awk -F ":" '{print $2}')
    cpus=$(cat /proc/cpuinfo | grep processor | wc -l)
    [[ "$system" ]] && msg -ama "$(fun_trans "Sistema"): ${null}$system" || msg -ama "$(fun_trans "Sistema"): ${null}???"
    [[ "$based" ]] && msg -ama "$(fun_trans "Base"): ${null}$based" || msg -ama "$(fun_trans "Base"): ${null}???"
    [[ "$processor" ]] && msg -ama "$(fun_trans "Procesador"): ${null}$processor x$cpus" || msg -ama "$(fun_trans "Procesador"): ${null}???"
    [[ "$clock" ]] && msg -ama "$(fun_trans "Frecuencia de Operacion"): ${null}$clock MHz" || msg -ama "$(fun_trans "Frecuencia de Operacion"): ${null}???"
    msg -ama "$(fun_trans "Uso del Procesador"): ${null}$(ps aux | awk 'BEGIN { sum = 0 }  { sum += sprintf("%f",$3) }; END { printf " " "%.2f" "%%", sum}')"
    msg -ama "$(fun_trans "Memoria Virtual Total"): ${null}$(($totalram / 1024))"
    msg -ama "$(fun_trans "Memoria Virtual En Uso"): ${null}$(($usedram / 1024))"
    msg -ama "$(fun_trans "Memoria Virtual Libre"): ${null}$(($freeram / 1024))"
    msg -ama "$(fun_trans "Memoria Virtual Swap"): ${null}$(($swapram / 1024))MB"
    msg -ama "$(fun_trans "Tempo Online"): ${null}$(uptime)"
    msg -ama "$(fun_trans "Nombre De La Maquina"): ${null}$(hostname)"
    msg -ama "$(fun_trans "IP De La  Maquina"): ${null}$(ip addr | grep inet | grep -v inet6 | grep -v "host lo" | awk '{print $2}' | awk -F "/" '{print $1}')"
    msg -ama "$(fun_trans "Version de Kernel"): ${null}$(uname -r)"
    msg -ama "$(fun_trans "Arquitectura"): ${null}$(uname -m)"
    msg -bar
    return 0
}
[[ "$(crontab -l | grep 'vm.drop_caches=3' | wc -l)" != '0' ]] &>/dev/null && {
    autram="\e[1;32m[ON]"
} || {
    autram="\e[1;31m[OFF]"
}
menu3() {
    declare -A inst
    pidr_inst
    clear
    valuest=$(ps ax | grep /etc/shadowsocks-r | grep -v grep)
    [[ $valuest != "" ]] && valuest="\033[1;32m[ON] " || valuest="\033[1;31m[OFF]"
    pidproxy=$(ps x | grep -w "lacasitamx.py" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy ]] && plox="\e[1;32m[ON] " || plox="\e[1;31m[OFF]"
    Bot=$(ps x | grep -v grep | grep "ADMbot.sh")
    [[ ! $Bot ]] && AD="\033[1;31m[OFF]" || AD="\033[1;32m[ON] "
    msg -bar
    msg -tit
    export -f fun_eth
    export -f fun_bar
    export -f lacasita
    lacasita
    msg -bar
    echo -e "	\e[97m\e[1;100mPROTOCOLOS\e[0m		  \e[97m\e[41mHERRAMIENTAS\e[0m"
    msg -bar
    echo -e "\e[1;93m[\e[92m1\e[93m]$(msg -verm2 "➛ ")$(msg -azu "BADVPN        ${inst[badvpn]}")  \e[1;93m[\e[92m11\e[93m]$(msg -verm2 "➛ ")$(msg -azu "ARCHIVO ONLINE")"
    echo -e "\e[1;93m[\e[92m2\e[93m]$(msg -verm2 "➛ ")$(msg -azu "HTTP-PYTHON   $plox")  \e[1;93m[\e[92m12\e[93m]$(msg -verm2 "➛ ")$(msg -azu "FIREWALL")"
    echo -e "\e[1;93m[\e[92m3\e[93m]$(msg -verm2 "➛ ")$(msg -azu "SOCKS PYTHON  ${inst[python]}")  \e[1;93m[\e[92m13\e[93m]$(msg -verm2 "➛ ")$(msg -azu "FAIL2BAN PROTECION")"
    echo -e "\e[1;93m[\e[92m4\e[93m]$(msg -verm2 "➛ ")$(msg -azu "V2RAY         ${inst[v2ray]}")  \e[1;93m[\e[92m14\e[93m]$(msg -verm2 "➛ ")$(msg -azu "DETALLES DE SISTEMA")"
    echo -e "\e[1;93m[\e[92m5\e[93m]$(msg -verm2 "➛ ")$(msg -azu "SSL           ${inst[stunnel4]}")  \e[1;93m[\e[92m15\e[93m]$(msg -verm2 "➛ ")$(msg -azu "TCP (BBR|BBR-Plus)")"
    echo -e "\e[1;93m[\e[92m6\e[93m]$(msg -verm2 "➛ ")$(msg -azu "DROPBEAR      ${inst[dropbear]}")  \e[1;93m[\e[92m16\e[93m]$(msg -verm2 "➛ ")$(msg -azu "DNS NETFLIX")"
    echo -e "\e[1;93m[\e[92m7\e[93m]$(msg -verm2 "➛ ")$(msg -azu "SQUID         ${inst[squid]}")  \e[1;93m[\e[92m17\e[93m]$(msg -verm2 "➛ ")$(msg -azu "LIMPIAR-CACHÉ ")$autram"
    echo -e "\e[1;93m[\e[92m8\e[93m]$(msg -verm2 "➛ ")$(msg -azu "OPENVPN       ${inst[openvpn]}")  \e[1;93m[\e[92m18\e[93m]$(msg -verm2 "➛ ")$(msg -azu "SCANNER SUBDOMINIO")"
    echo -e "\e[1;93m[\e[92m9\e[93m]$(msg -verm2 "➛ ")$(msg -azu "SLOWDNS            ${inst[dns - serve]}")  \e[1;93m[\e[92m19\e[93m]$(msg -verm2 "➛ ")$(msg -azu "PRUEBA DE VELOCIDAD")"
    echo -e "\e[1;93m[\e[92m10\e[93m]$(msg -verm2 "➛ ")$(msg -azu "BOT TELEGRAM $AD")  \e[1;93m[\e[92m20\e[93m]$(msg -verm2 "➛ ")$(msg -azu "FIX ORACLE/AWS/AZR")"
    echo -e "$(msg -verd "[0]")$(msg -verm2 "➛ ")$(msg -azu "⇚ VOLVER  ")           $(msg -verd "[21]")$(msg -verm2 "➛ ")$(msg -azu "\e[91m\e[43mHERRAMIENTAS BASICOS\e[0m")"
    msg -bar
    echo -ne " ►\e[1;37m Selecione Una Opcion: \e[33m " && read select
    case $select in
    0) ;;
    1)
        ${SCPinst}/budp.sh && msg -ne "Enter Para Continuar" && read enter
        menu3
        ;;
    2)
        ${SCPinst}/proxy.sh && msg -ne "Enter Para Continuar" && read enter
        menu3
        ;;
    3)
        ${SCPinst}/sockspy.sh && msg -ne "Enter Para Continuar" && read enter
        menu3
        ;;
    4)
        ${SCPinst}/v2ray.sh && msg -ne "Enter Para Continuar" && read enter
        menu3
        ;;
    5)
        ${SCPinst}/ssl.sh && msg -ne "Enter Para Continuar" && read enter
        menu3
        ;;
    6)
        ${SCPinst}/dropbear.sh && msg -ne "Enter Para Continuar" && read enter
        menu3
        ;;
    7)
        ${SCPinst}/squid.sh && msg -ne "Enter Para Continuar" && read enter
        menu3
        ;;
    8)
        ${SCPinst}/openvpn.sh && msg -ne "Enter Para Continuar" && read enter
        menu3
        ;;
    9)
        ${SCPinst}/slowdns.sh && msg -ne "Enter Para Continuar" && read enter
        menu3
        ;;
    10) ${SCPfrm}/ADMbot.sh ;;
    11) ${SCPfrm}/apacheon.sh ;;
    12) ${SCPfrm}/blockBT.sh ;;
    13) ${SCPfrm}/fai2ban.sh ;;
    14) systen_info ;;
    15) ${SCPfrm}/tcp.sh ;;
    16) net ;;
    17) cache ;;
    18) ${SCPfrm}/ultrahost ;;
    19) ${SCPfrm}/speed.py ;;
    20) oracl ;;
    21) extra ;;
    *)
        msg -verm2 " Por Favor Selecione El Número Correcto"
        sleep 1.s
        menu3
        ;;
    esac
}
extra() {
    clear
    clear
    msg -bar
    msg -tit
    on="\033[1;32m[ON]" && off="\033[1;31m[OFF]"
    [[ $(grep -c "^#ADM" /etc/sysctl.conf) -eq 0 ]] && tcp=$off || tcp=$on
    if [ -e /etc/squid/squid.conf ]; then
        [[ $(grep -c "^#CACHE_DO_SQUID" /etc/squid/squid.conf) -gt 0 ]] && squi=$off || squi=$on
    elif [ -e /etc/squid3/squid.conf ]; then
        [[ $(grep -c "^#CACHE_DO_SQUID" /etc/squid3/squid.conf) -gt 0 ]] && squi=$off || squi=$on
    fi
    echo -e "		\e[91m\e[43mHERRAMIENTAS BASICOS\e[0m"
    msg -bar
    echo -e " \e[1;93m[\e[92m1\e[93m]$(msg -verm2 " ➛ ")$(msg -azu "ACTUALIZAR HORA LOCAL")"
    echo -e " \e[1;93m[\e[92m2\e[93m]$(msg -verm2 " ➛ ")$(msg -azu "HTOP")"
    echo -e " \e[1;93m[\e[92m3\e[93m]$(msg -verm2 " ➛ ")$(msg -azu "MODIFICAR PUERTOS ACTIVOS")"
    echo -e " \e[1;93m[\e[92m4\e[93m]$(msg -verm2 " ➛ ")$(msg -azu "PAYLOAD FUERZA BRUTA")"
    echo -e " \e[1;93m[\e[92m5\e[93m]$(msg -verm2 " ➛ ")$(msg -azu "TCP SPEED") $tcp"
    echo -e " \e[1;93m[\e[92m6\e[93m]$(msg -verm2 " ➛ ")$(msg -azu "CACHÉ PARA SQUID") $squi"
    echo -e " \e[1;93m[\e[92m7\e[93m]$(msg -verm2 " ➛ ")$(msg -azu "LIMPIAR PAQUETES OBSOLETOS")"
    echo -e " \e[1;93m[\e[92m8\e[93m]$(msg -verm2 " ➛ ")$(msg -azu "RESET IPTABLES")"
    echo -e " \e[1;93m[\e[92m9\e[93m]$(msg -verm2 " ➛ ")$(msg -azu "REINICIAR VPS")"
    echo -e " \e[1;93m[\e[92m10\e[93m]$(msg -verm2 "➛ ")$(msg -azu "CAMBIAR HOSTNAME VPS")"
    echo -e " \e[1;93m[\e[92m11\e[93m]$(msg -verm2 "➛ ")$(msg -azu "CAMBIAR CONTRASEÑA ROOT")"
    echo -e " \e[1;93m[\e[92m12\e[93m]$(msg -verm2 "➛ ")$(msg -azu "AGREGAR ROOT a GoogleCloud y Amazon")"
    echo -e " \e[1;93m[\e[92m13\e[93m]$(msg -verm2 "➛ ")$(msg -azu "AUTENTIFICAR SQUID")"
    echo -e " \e[1;93m[\e[92m0\e[93m]$(msg -verm2 " ➛ ")$(msg -azu "VOLVER")"
    msg -bar
    echo -ne " ►\e[1;37m Selecione Una Opcion: \e[33m " && read select
    case $select in
    0) menu3 ;;
    1) horas ;;
    2) monhtop ;;
    3)
        ${SCPfrm}/ports.sh && msg -ne "Enter Para Continuar" && read enter
        menu3
        ;;
    4) ${SCPfrm}/paysnd.sh ;;
    5) TCPspeed ;;
    6) SquidCACHE ;;
    7) packobs ;;
    8) resetiptables ;;
    9) reiniciar_vps ;;
    10) host_name ;;
    11) cambiopass ;;
    12) rootpass ;;
    13) ${SCPfrm}/squidpass.sh ;;
    *) ;;
    esac
}
reiniciar_vps() {
    echo -ne " \033[1;31m[ ! ] Sudo Reboot"
    sleep 3s
    echo -e "\033[1;32m [OK]"
    (
        sudo reboot
    ) >/dev/null 2>&1
    msg -bar
    return
}
host_name() {
    unset name
    while [[ ${name} = "" ]]; do
        echo -ne "\033[1;37m $(fun_trans "Nuevo nombre del host"): " && read name
        tput cuu1 && tput dl1
    done
    hostnamectl set-hostname $name
    if [ $(hostnamectl status | head -1 | awk '{print $3}') = "${name}" ]; then
        echo -e "\033[1;33m $(fun_trans "Host alterado corretamente")!, $(fun_trans "reiniciar VPS")"
    else
        echo -e "\033[1;33m $(fun_trans "Host no modificado")!"
    fi
    msg -bar
    return
}
cambiopass() {
    echo -e "${cor[3]} $(fun_trans "Esta herramienta cambia la contraseña de su servidor vps")"
    echo -e "${cor[3]} $(fun_trans "Esta contraseña es utilizada como usuario") root"
    msg -bar
    echo -ne " $(fun_trans "Desea Seguir?") [S/N]: "
    read x
    [[ $x = @(n|N) ]] && msg -bar && return
    msg -bar
    echo -e "${cor[0]} $(fun_trans "Escriba su nueva contraseña")"
    msg -bar
    read -p " Nuevo passwd: " pass
    (
        echo $pass
        echo $pass
    ) | passwd 2>/dev/null
    sleep 1s
    msg -bar
    echo -e "${cor[3]} $(fun_trans "Contraseña cambiada con exito!")"
    echo -e "${cor[2]} $(fun_trans "Su contraseña ahora es"): ${cor[4]}$pass"
    msg -bar
    return
}
dnsnetflix() {
    echo "nameserver $dns1" >/etc/resolv.conf
    echo "nameserver $dns2" >>/etc/resolv.conf
    /etc/init.d/ssrmu stop &>/dev/null
    /etc/init.d/ssrmu start &>/dev/null
    /etc/init.d/shadowsocks-r stop &>/dev/null
    /etc/init.d/shadowsocks-r start &>/dev/null
    msg -bar2
    echo -e "${cor[4]}  DNS AGREGADOS CON EXITO"
}
net() {
    clear
    msg -bar2
    msg -tit
    echo -e "\033[1;93m     AGREGADOR DE DNS PERSONALES"
    msg -bar2
    echo -e "\033[1;39m Esta funcion ara que puedas ver Netflix con tu VPS"
    msg -bar2
    echo -e "\033[1;39m En APPS como HTTP Inyector,KPN Rev,APKCUSTOM, etc."
    echo -e "\033[1;39m Se deveran agregar en la aplicasion a usar estos DNS."
    echo -e "\033[1;39m En APPS como SS,SSR,V2RAY no es necesario agregarlos."
    msg -bar2
    echo -e "\033[1;93m Recuerde escojer entre 1 DNS ya sea el de USA,BR,MX,CL \n segun le aya entregado el BOT."
    echo ""
    echo -e "\033[1;97m Ingrese su DNS Primario: \033[0;91m"
    read -p " Primary Dns: " dns1
    echo -e "\033[1;97m Ingrese su DNS Secundario: \033[0;91m"
    read -p " Secondary Dns: " dns2
    echo ""
    msg -bar2
    read -p " Estas seguro de continuar?  [ s | n ]: " dnsnetflix
    [[ "$dnsnetflix" = "s" || "$dnsnetflix" = "S" ]] && dnsnetflix
    msg -bar2
}
rootpass() {
    clear
    msg -bar
    echo -e "${cor[3]}  Esta herramienta cambia a usuario root las VPS de "
    echo -e "${cor[3]}             GoogleCloud y Amazon"
    msg -bar
    echo -ne " Desea Seguir? [S/N]: "
    read x
    [[ $x = @(n|N) ]] && msg -bar && return
    msg -bar
    echo -e "                 Aplicando Configuraciones"
    fun_bar "service ssh restart"
    sed -i "s;PermitRootLogin prohibit-password;PermitRootLogin yes;g" /etc/ssh/sshd_config
    sed -i "s;PermitRootLogin without-password;PermitRootLogin yes;g" /etc/ssh/sshd_config
    sed -i "s;PasswordAuthentication no;PasswordAuthentication yes;g" /etc/ssh/sshd_config
    msg -bar
    echo -e "Escriba su contraseña root actual o cambiela"
    msg -bar
    read -p " Nuevo passwd: " pass
    (
        echo $pass
        echo $pass
    ) | passwd 2>/dev/null
    sleep 1s
    msg -bar
    echo -e "${cor[3]} Configuraciones aplicadas con exito!"
    echo -e "${cor[2]} Su contraseña ahora es: ${cor[4]}$pass"
    service ssh restart >/dev/null 2>&1
    msg -bar
    return
}
resetiptables() {
    echo -e "Reiniciando Ipetables espere"
    iptables -F && iptables -X && iptables -t nat -F && iptables -t nat -X && iptables -t mangle -F && iptables -t mangle -X && iptables -t raw -F && iptables -t raw -X && iptables -t security -F && iptables -t security -X && iptables -P INPUT ACCEPT && iptables -P FORWARD ACCEPT && iptables -P OUTPUT ACCEPT
    echo -e "iptables reiniciadas con exito"
}
packobs() {
    msg -ama "Buscando Paquetes Obsoletos"
    dpkg -l | grep -i ^rc
    msg -ama "Limpiando Paquetes Obsoloteos"
    dpkg -l | grep -i ^rc | cut -d " " -f 3 | xargs dpkg --purge
    msg -ama "Limpieza Completa"
}
TCPspeed() {
    if [[ $(grep -c "^#ADM" /etc/sysctl.conf) -eq 0 ]]; then
        msg -ama "$(fun_trans "TCP Speed No Activado, Desea Activar Ahora")?"
        msg -bar
        while [[ ${resposta} != @(s|S|n|N|y|Y) ]]; do
            read -p " [S/N]: " -e -i s resposta
            tput cuu1 && tput dl1
        done
        [[ "$resposta" = @(s|S|y|Y) ]] && {
            echo "#ADM" >>/etc/sysctl.conf
            echo "net.ipv4.tcp_window_scaling = 1
 net.core.rmem_max = 16777216
 net.core.wmem_max = 16777216
 net.ipv4.tcp_rmem = 4096 87380 16777216
 net.ipv4.tcp_wmem = 4096 16384 16777216
 net.ipv4.tcp_low_latency = 1
 net.ipv4.tcp_slow_start_after_idle = 0" >>/etc/sysctl.conf
            sysctl -p /etc/sysctl.conf >/dev/null 2>&1
            msg -ama "$(fun_trans "TCP Activo Con Exito")!"
        } || msg -ama "$(fun_trans "Cancelado")!"
    else
        msg -ama "$(fun_trans "TCP Speed ya esta activado, desea detener ahora")?"
        msg -bar
        while [[ ${resposta} != @(s|S|n|N|y|Y) ]]; do
            read -p " [S/N]: " -e -i s resposta
            tput cuu1 && tput dl1
        done
        [[ "$resposta" = @(s|S|y|Y) ]] && {
            grep -v "^#ADM
 net.ipv4.tcp_window_scaling = 1
 net.core.rmem_max = 16777216
 net.core.wmem_max = 16777216
 net.ipv4.tcp_rmem = 4096 87380 16777216
 net.ipv4.tcp_wmem = 4096 16384 16777216
 net.ipv4.tcp_low_latency = 1
 net.ipv4.tcp_slow_start_after_idle = 0" /etc/sysctl.conf >/tmp/syscl && mv -f /tmp/syscl /etc/sysctl.conf
            sysctl -p /etc/sysctl.conf >/dev/null 2>&1
            msg -ama "$(fun_trans "TCP Parado Con Exito")!"
        } || msg -ama "$(fun_trans "Cancelado")!"
    fi
}
SquidCACHE() {
    msg -ama "$(fun_trans "Squid Cache, Aplica cache en Squid")"
    msg -ama "$(fun_trans "Mejora la velocidad del squid")"
    msg -bar
    if [ -e /etc/squid/squid.conf ]; then
        squid_var="/etc/squid/squid.conf"
    elif [ -e /etc/squid3/squid.conf ]; then
        squid_var="/etc/squid3/squid.conf"
    else
        msg -ama "$(fun_trans "Su sistema no tiene un squid")!" && return 1
    fi
    teste_cache="#CACHE_DO_SQUID"
    if [[ $(grep -c "^$teste_cache" $squid_var) -gt 0 ]]; then
        [[ -e ${squid_var}.bakk ]] && {
            msg -ama "$(fun_trans "Cache squid identificado, eliminando")!"
            mv -f ${squid_var}.bakk $squid_var
            msg -ama "$(fun_trans "Cache squid Removido")!"
            service squid restart >/dev/null 2>&1 &
            service squid3 restart >/dev/null 2>&1 &
            return 0
        }
    fi
    msg -ama "$(fun_trans "Aplicando Cache Squid")!"
    msg -bar
    _tmp="#CACHE_DO_SQUID\ncache_mem 200 MB\nmaximum_object_size_in_memory 32 KB\nmaximum_object_size 1024 MB\nminimum_object_size 0 KB\ncache_swap_low 90\ncache_swap_high 95"
    [[ "$squid_var" = "/etc/squid/squid.conf" ]] && _tmp+="\ncache_dir ufs /var/spool/squid 100 16 256\naccess_log /var/log/squid/access.log squid" || _tmp+="\ncache_dir ufs /var/spool/squid3 100 16 256\naccess_log /var/log/squid3/access.log squid"
    while read s_squid; do
        [[ "$s_squid" != "cache deny all" ]] && _tmp+="\n${s_squid}"
    done <$squid_var
    cp ${squid_var} ${squid_var}.bakk
    echo -e "${_tmp}" >$squid_var
    msg -ama "$(fun_trans "Cache Aplicado con Exito")!"
    service squid restart >/dev/null 2>&1 &
    service squid3 restart >/dev/null 2>&1 &
}
oracl() {
    clear
    msg -bar
    msg -tit
    msg -verm "		FIREWALLD"
    msg -ama " ESTA HERRAMIENTA ES PARA LAS VPS ORACLE/AWS/AZR"
    msg -ama " TAMBIEN PARA OTRAS VPS QUE SON NECESARIO A UTILIZAR ESTA OPCION"
    echo -ne " Desea Continuar? [S/N]: "
    read x
    [[ $x = @(n|N) ]] && msg -bar && return
    msg -bar
    sudo apt update -y &>/dev/null
    sudo apt install firewalld -y &>/dev/null
    sudo apt install apache2 &>/dev/null
    sudo firewall-cmd --zone=public --permanent --add-port=80/tcp
    sudo firewall-cmd --zone=public --permanent --add-port=81/tcp
    sudo firewall-cmd --zone=public --permanent --add-port=90/tcp
    sudo firewall-cmd --zone=public --permanent --add-port=110/tcp
    sudo firewall-cmd --zone=public --permanent --add-port=143/tcp
    sudo firewall-cmd --zone=public --permanent --add-port=442/tcp
    sudo firewall-cmd --zone=public --permanent --add-port=443/tcp
    sudo firewall-cmd --zone=public --permanent --add-port=444/tcp
    sudo firewall-cmd --zone=public --permanent --add-port=8080/tcp
    sudo firewall-cmd --zone=public --permanent --add-port=8081/tcp
    sudo firewall-cmd --zone=public --permanent --add-port=5300/udp
    sudo firewall-cmd --zone=public --permanent --add-port=7200/udp
    sudo firewall-cmd --zone=public --permanent --add-port=7300/udp
    sudo firewall-cmd --reload
    sudo firewall-cmd --zone=public --list-ports &>/dev/null
    msg -azu "	FIX AGREGADO"
}
cache() {
    clear
    msg -bar
    msg -verm "	LIBERANDO CACHÉ/RAM"
    msg -bar
    me() {
        echo 3 >/proc/sys/vm/drop_caches &>/dev/null
        sysctl -w vm.drop_caches=3 &>/dev/null
        apt-get autoclean -y &>/dev/null
        apt-get clean -y &>/dev/null
    }
    me &>/dev/null && msg -ama " REFRESCANDO RAM" | pv -qL20
    sleep 2s
    if [[ ! -z $(crontab -l | grep -w "vm.drop_caches=3") ]]; then
        msg -azu " Auto limpieza programada cada $(msg -verd "[ $(crontab -l | grep -w "vm.drop_caches=3" | awk '{print $2}' | sed $'s/[^[:alnum:]\t]//g')HS ]")"
        msg -bar
        while :; do
            echo -ne "$(msg -azu " Detener Auto Limpieza [S/N]: ")" && read t_ram
            tput cuu1 && tput dl1
            case $t_ram in
            s | S)
                crontab -l >/root/cron && sed -i '/vm.drop_caches=3/ d' /root/cron && crontab /root/cron && rm /root/cron
                msg -azu " Auto-Limpeza Detenida!" && msg -bar && sleep 2
                return 1
                ;;
            n | N) return 1 ;;
            *) menu3 ;;
            esac
        done
    fi
    echo -ne "$(msg -azu "Desea programar El Auto-Limpieza [s/n]:") "
    read c_ram
    if [[ $c_ram = @(s|S|y|Y) ]]; then
        tput cuu1 && tput dl1
        echo -ne "$(msg -azu " PONGA UN NÚMERO, EJEMPLO [1-12HORAS]:") "
        read ram_c
        if [[ $ram_c =~ ^[0-9]+$ ]]; then
            crontab -l >/root/cron
            echo "0 */$ram_c * * * sudo sysctl -w vm.drop_caches=3 > /dev/null 2>&1" >>/root/cron
            crontab /root/cron
            rm /root/cron
            tput cuu1 && tput dl1
            msg -azu " Auto-Limpieza programada cada: $(msg -verd "${ram_c} HORAS")" && msg -bar && sleep 2
        else
            tput cuu1 && tput dl1
            msg -verm2 " ingresar solo numeros entre 1 y 12"
            sleep 2
            msg -bar
        fi
    fi
    return 1
}
pidr_inst() {
    proto="dropbear python stunnel4 v2ray node badvpn squid openvpn dns-serve ssserver ss-server"
    portas=$(lsof -V -i -P -n | grep -v "ESTABLISHED" | grep -v "COMMAND")
    for list in $proto; do
        case $list in
        dropbear | python | stunnel4 | v2ray | node | badvpn | squid | openvpn | ssserver | ss-server)
            portas2=$(echo $portas | grep -w "LISTEN" | grep -w "$list")
            [[ $(echo "${portas2}" | grep "$list") ]] && inst[$list]="\033[1;32m[ON] " || inst[$list]="\033[1;31m[OFF]"
            ;;
        dns-serve)
            portas2=$(echo $portas | grep -w "$list")
            [[ $(echo "${portas2}" | grep "$list") ]] && inst[$list]="\033[1;32m[ON] " || inst[$list]="\033[1;31m[OFF]"
            ;;
        esac
    done
}
menu_func() {
    local options=${#@}
    local array
    for ((num = 1; num <= $options; num++)); do
        echo -ne "  $(msg -verd "\e[1;93m[\e[92m$num\e[93m]") $(msg -verm2 "➛ ") "
        array=(${!num})
        case ${array[0]} in
        "-vd") msg -verd "\033[1;33m[!]\033[1;32m $(fun_trans "${array[@]:1}")" | sed ':a;N;$!ba;s/\n/ /g' ;;
        "-vm") msg -verm2 "\033[1;33m[!]\033[1;31m $(fun_trans "${array[@]:1}")" | sed ':a;N;$!ba;s/\n/ /g' ;;
        "-fi") msg -azu "$(fun_trans "${array[@]:2}") ${array[1]}" | sed ':a;N;$!ba;s/\n/ /g' ;;
        *) msg -azu "$(fun_trans "${array[@]}")" | sed ':a;N;$!ba;s/\n/ /g' ;;
        esac
    done
}
selection_fun() {
    local selection="null"
    local range
    for ((i = 0; i <= $1; i++)); do range[$i]="$i "; done
    while [[ ! $(echo ${range[*]} | grep -w "$selection") ]]; do
        echo -ne "\033[1;37m$(fun_trans " ► Selecione una Opcion"): " >&2
        read selection
        tput cuu1 >&2 && tput dl1 >&2
    done
    echo $selection
}
export -f msg
export -f selection_fun
export -f fun_trans
export -f menu_func
export -f meu_ip
export -f fun_ip
export -f lacasita
clear
sudo sync
sudo sysctl -w vm.drop_caches=3 >/dev/null 2>&1
clear
clear
msg -bar
msg -tit
menu_info
msg -bar
title=$(echo -e "\033[1;96m$(cat ${SCPdir}/message.txt)")
printf "%*s\n" $((($(echo -e "$title" | wc -c) + 55) / 2)) "$title"
msg -bar
monservi_fun() {
    clear
    clear
    monssh() {
        sed -i "57d" /bin/monitor.sh
        sed -i '57i EstadoServicio ssh' /bin/monitor.sh
    }
    mondropbear() {
        sed -i "59d" /bin/monitor.sh
        sed -i '59i EstadoServicio dropbear' /bin/monitor.sh
    }
    monssl() {
        sed -i "61d" /bin/monitor.sh
        sed -i '61i EstadoServicio stunnel4' /bin/monitor.sh
    }
    monsquid() {
        sed -i "63d" /bin/monitor.sh
        sed -i '63i [[ $(EstadoServicio squid) ]] && EstadoServicio squid3' /bin/monitor.sh
    }
    monapache() {
        sed -i "65d" /bin/monitor.sh
        sed -i '65i EstadoServicio apache2' /bin/monitor.sh
    }
    monv2ray() {
        sed -i "55d" /bin/monitor.sh
        sed -i '55i EstadoServicio v2ray' /bin/monitor.sh
    }
    msg -bar
    msg -tit
    echo -e "\033[1;32m          MONITOR DE SERVICIONS PRINCIPALES"
    PIDVRF3="$(ps aux | grep "${SCPdir}/menu monitorservi" | grep -v grep | awk '{print $2}')"
    PIDVRF5="$(ps aux | grep "${SCPdir}/menu moni2" | grep -v grep | awk '{print $2}')"
    if [[ -z $PIDVRF3 ]]; then
        sed -i '5a\screen -dmS very3 /etc/VPS-MX/menu monitorservi' /bin/resetsshdrop
        msg -bar
        echo -e "\033[1;34m          ¿Monitorear Protocolo SSH/SSHD?"
        msg -bar
        read -p "                    [ s | n ]: " monssh
        sed -i "57d" /bin/monitor.sh
        sed -i '57i #EstadoServicio ssh' /bin/monitor.sh
        [[ "$monssh" = "s" || "$monssh" = "S" ]] && monssh
        msg -bar
        echo -e "\033[1;34m          ¿Monitorear Protocolo DROPBEAR?"
        msg -bar
        read -p "                    [ s | n ]: " mondropbear
        sed -i "59d" /bin/monitor.sh
        sed -i '59i #EstadoServicio dropbear' /bin/monitor.sh
        [[ "$mondropbear" = "s" || "$mondropbear" = "S" ]] && mondropbear
        msg -bar
        echo -e "\033[1;34m            ¿Monitorear Protocolo SSL?"
        msg -bar
        read -p "                    [ s | n ]: " monssl
        sed -i "61d" /bin/monitor.sh
        sed -i '61i #EstadoServicio stunnel4' /bin/monitor.sh
        [[ "$monssl" = "s" || "$monssl" = "S" ]] && monssl
        msg -bar
        echo -e "\033[1;34m            ¿Monitorear Protocolo SQUID?"
        msg -bar
        read -p "                    [ s | n ]: " monsquid
        sed -i "63d" /bin/monitor.sh
        sed -i '63i #[[ $(EstadoServicio squid) ]] && EstadoServicio squid3' /bin/monitor.sh
        [[ "$monsquid" = "s" || "$monsquid" = "S" ]] && monsquid
        msg -bar
        echo -e "\033[1;34m            ¿Monitorear Protocolo APACHE?"
        msg -bar
        read -p "                    [ s | n ]: " monapache
        sed -i "65d" /bin/monitor.sh
        sed -i '65i #EstadoServicio apache2' /bin/monitor.sh
        [[ "$monapache" = "s" || "$monapache" = "S" ]] && monapache
        msg -bar
        echo -e "\033[1;34m            ¿Monitorear Protocolo V2RAY?"
        msg -bar
        read -p "                    [ s | n ]: " monv2ray
        sed -i "55d" /bin/monitor.sh
        sed -i '55i #EstadoServicio v2ray' /bin/monitor.sh
        [[ "$monv2ray" = "s" || "$monv2ray" = "S" ]] && monv2ray
        cd ${SCPdir}
        screen -dmS very3 ${SCPdir}/menu monitorservi
        screen -dmS monis2 ${SCPdir}/menu moni2
    else
        for pid in $(echo $PIDVRF3); do
            kill -9 $pid &>/dev/null
            sed -i "6d" /bin/resetsshdrop
        done
        for pid in $(echo $PIDVRF5); do
            kill -9 $pid &>/dev/null
        done
    fi
    msg -bar
    echo -e "             Puedes Monitorear desde:\n       \033[1;32m http://$(meu_ip):81/monitor.html"
    msg -bar
    [[ -z ${VERY3} ]] && monitorservi="\033[1;32m ACTIVADO " || monitorservi="\033[1;31m DESACTIVADO "
    echo -e "            $monitorservi  --  CON EXITO"
    msg -bar
}
monitor_auto() {
    while true; do
        monitor.sh 2>/dev/null
        sleep 90s
    done
}
if [[ "$1" = "monitorservi" ]]; then
    monitor_auto
    exit
fi
pid_kill() {
    [[ -z $1 ]] && refurn 1
    pids="$@"
    for pid in $(echo $pids); do
        kill -9 $pid &>/dev/null
    done
}
monitorport_fun() {
    while true; do
        pidproxy3=$(ps x | grep "PDirect.py" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy3 ]] && pid_kill $pidproxy3
        pidpyssl=$(ps x | grep "python.py" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidpyssl ]] && pid_kill $pidpyssl
        sleep 6h
    done
}
if [[ "$1" = "moni2" ]]; then
    monitorport_fun
    exit
fi
SSHN="$(grep -c home /etc/passwd)"
echo "${SSHN}" | bc >/etc/VPS-MX/controlador/SSH20.log
SSH3="$(less /etc/VPS-MX/controlador/SSH20.log)"
SSH4="$(echo $SSH3)"
user_info=$(cd /usr/local/shadowsocksr &>/dev/null && python mujson_mgr.py -l)
user_total=$(echo "${user_info}" | wc -l)
[[ ! -e /etc/VPS-MX/RegV2ray ]] && touch /etc/VPS-MX/RegV2ray
vray=$(cat /etc/VPS-MX/RegV2ray | wc -l)
on="\033[1;92m[ON]" && off="\033[1;31m[OFF]"
echo -e "\033[1;97m   SSH REG:\033[1;92m $SSH4 \033[1;97m   SS-SSRR REG:\033[1;92m $user_total \033[1;97m   V2RAY REG:\e[32m $vray"
VERY="$(ps aux | grep "${SCPusr}/usercodes verificar" | grep -v grep)"
VERY2="$(ps aux | grep "${SCPusr}/usercodes desbloqueo" | grep -v grep)"
VERY3="$(ps aux | grep "${SCPdir}/menu monitorservi" | grep -v grep)"
limseg="$(less /etc/VPS-MX/controlador/tiemlim.log)"
[[ -z ${VERY} ]] && verificar="\033[1;31m[OFF]" || verificar="\033[1;32m[ON] "
[[ -z ${VERY2} ]] && desbloqueo="\033[1;31m[OFF]" || desbloqueo="\033[1;32m[ON] "
[[ -z ${VERY3} ]] && monitorservi="\033[1;31m[OFF]" || monitorservi="\033[1;32m[ON]"
[[ -e ${SCPdir}/USRonlines ]] && msg -bar && msg -ne "\033[1;97m LIMITADOR:\033[1;92m$verificar \033[1;97m AUTO-DESBLOQUEO:\033[1;92m$desbloqueo \e[1;97mMONITOR:\e[34m${limseg}s\n \033[1;32mCONECTADOS: " && echo -ne "\033[1;97m$(cat ${SCPdir}/USRonlines) "
[[ -e ${SCPdir}/USRexpired ]] && msg -ne "   EXPIRADOS: " && echo -ne "\033[1;97m$(cat ${SCPdir}/USRexpired) " && msg -ne " \033[1;95m BLOQUEADOS: " && echo -e "\033[1;97m$(cat ${SCPdir}/USRbloqueados)" #\n\033[1;97m        ACTULIZACION DE MONITOR CADA: \033[1;34m $limseg s"
monhtop() {
    clear
    msg -bar
    msg -tit
    echo -ne " \033[1;93m             MONITOR DE PROCESOS HTOP\n"
    msg -bar
    msg -bra "    RECUERDA SALIR CON : \033[1;96m CTRL + C o FIN + F10 "
    [[ $(dpkg --get-selections | grep -w "htop" | head -1) ]] || apt-get install htop -y &>/dev/null
    msg -bar
    read -t 10 -n 1 -rsp $'\033[1;39m Preciona Enter Para continuar\n'
    clear
    sudo htop
    msg -bar
    echo -e "\e[97m \033[1;41m| #-#-►  SCRIPT VPS•MX ◄-#-# | \033[1;49m\033[1;49m \033[1;31m[ \033[1;32m $vesaoSCT      "
    echo -ne " \033[1;93m             MONITOR DE PROCESOS HTOP\n"
    msg -bar
    echo -e "\e[97m                  FIN DEL MONITOR"
    msg -bar
}
[[ $(ps x | grep v2ray | grep -v grep | awk '{print $1}') ]] && vra=$on || vra=$off
msg -bar
msg -bar3
on="\e[1;32m[ON]" && off="\e[1;31m[OFF]"
echo -e " \e[1;93m[\e[92m1\e[93m] $(msg -verm2 "➛ ") $(msg -azu "ADMINISTRAR CUENTAS | SSH/SSL/DROPBEAR")"
echo -e " \e[1;93m[\e[92m2\e[93m] $(msg -verm2 "➛ ") $(msg -azu "ADMINISTRAR CUENTAS | SS/SSRR")"
echo -e " \e[1;93m[\e[92m3\e[93m] $(msg -verm2 "➛ ") $(msg -azu "ADMINISTRAR CUENTAS | V2RAY --> $vra")"
echo -e " \e[1;93m[\e[92m4\e[93m] $(msg -verm2 "➛ ") \e[1;31m\033[47mPROTOCOLOS\e[0m  \e[93m||  \e[1;37m\e[41mHERRAMIENTAS\e[0m"
echo -e " \e[1;93m[\e[92m5\e[93m] $(msg -verm2 "➛ ") $(msg -azu "MONITOR DE PROTOCOLOS --------> ${monitorservi}")"
echo -e " \e[1;93m[\e[92m6\e[93m] $(msg -verm2 "➛ ") $(msg -azu "AUTO INICIAR SCRIPT ----------> ${AutoRun}")"
msg -bar
echo -e " \e[1;93m[\e[92m7\e[93m] \e[97m$(msg -verm2 "➛ ") $(msg -verd "ACTUALIZAR") \e[1;93m [\e[92m8\e[93m]\e[97m$(msg -verm2 "➛ ")\033[1;31mDESINSTALAR  \e[1;93m[\e[92m0\e[93m]$(msg -verm2 "➛ ") $(msg -bra "\e[97m\033[1;41mSALIR")"
msg -bar
selection=$(selection_fun 13)
case ${selection} in
1) ${SCPusr}/usercodes "${idioma}" ;;
2) ${SCPinst}/C-SSR.sh ;;
3) ${SCPinst}/v2ray.sh ;;
4) menu3 ;;
5) monservi_fun ;;
6) fun_autorun ;;
7) atualiza_fun ;;
8) remove_script ;;
0) cd $HOME && exit 0 ;;
esac
msg -ne "Enter Para Continuar" && read enter
${SCPdir}/menu
