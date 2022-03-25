#!/bin/bash
#25/01/2021
clear
clear
msg -bar
SCPdir="/etc/VPS-MX" && [[ ! -d ${SCPdir} ]] && exit 1
SCPfrm="${SCPdir}/herramientas" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="${SCPdir}/protocolos" && [[ ! -d ${SCPinst} ]] && exit
SCPidioma="${SCPdir}/idioma" && [[ ! -e ${SCPidioma} ]] && touch ${SCPidioma}
#timedatectl set-timezone UTC
# Detect Debian users running the script with "sh" instead of bash
if readlink /proc/$$/exe | grep -q "dash"; then
	echo "Este script se utiliza con bash"
	exit
fi

if [[ "$EUID" -ne 0 ]]; then
	echo "Sorry, solo funciona como root"
	exit
fi

if [[ ! -e /dev/net/tun ]]; then
	echo "El TUN device no esta disponible
 Necesitas habilitar TUN antes de usar este script"
	exit
fi

if [[ -e /etc/debian_version ]]; then
	OS=debian
	GROUPNAME=nogroup
	RCLOCAL='/etc/rc.local'
elif [[ -e /etc/centos-release || -e /etc/redhat-release ]]; then
	OS=centos
	GROUPNAME=nobody
	RCLOCAL='/etc/rc.d/rc.local'
else
	echo "Tu sistema operativo no esta disponible para este script"
	exit
fi

agrega_dns() {
	msg -ama " Escriba el HOST DNS que desea Agregar"
	read -p " [NewDNS]: " SDNS
	cat /etc/hosts | grep -v "$SDNS" >/etc/hosts.bak && mv -f /etc/hosts.bak /etc/hosts
	if [[ -e /etc/opendns ]]; then
		cat /etc/opendns >/tmp/opnbak
		mv -f /tmp/opnbak /etc/opendns
		echo "$SDNS" >>/etc/opendns
	else
		echo "$SDNS" >/etc/opendns
	fi
	[[ -z $NEWDNS ]] && NEWDNS="$SDNS" || NEWDNS="$NEWDNS $SDNS"
	unset SDNS
}
mportas() {
	unset portas
	portas_var=$(lsof -V -i -P -n | grep -v "ESTABLISHED" | grep -v "COMMAND")
	while read port; do
		var1=$(echo $port | awk '{print $1}') && var2=$(echo $port | awk '{print $9}' | awk -F ":" '{print $2}')
		[[ "$(echo -e $portas | grep "$var1 $var2")" ]] || portas+="$var1 $var2\n"
	done <<<"$portas_var"
	i=1
	echo -e "$portas"
}
dns_fun() {
	case $1 in
	3) dns[$2]='push "dhcp-option DNS 1.0.0.1"' ;;
	4) dns[$2]='push "dhcp-option DNS 1.1.1.1"' ;;
	5) dns[$2]='push "dhcp-option DNS 9.9.9.9"' ;;
	6) dns[$2]='push "dhcp-option DNS 1.1.1.1"' ;;
	7) dns[$2]='push "dhcp-option DNS 80.67.169.40"' ;;
	8) dns[$2]='push "dhcp-option DNS 80.67.169.12"' ;;
	9) dns[$2]='push "dhcp-option DNS 84.200.69.80"' ;;
	10) dns[$2]='push "dhcp-option DNS 84.200.70.40"' ;;
	11) dns[$2]='push "dhcp-option DNS 208.67.222.222"' ;;
	12) dns[$2]='push "dhcp-option DNS 208.67.220.220"' ;;
	13) dns[$2]='push "dhcp-option DNS 8.8.8.8"' ;;
	14) dns[$2]='push "dhcp-option DNS 8.8.4.4"' ;;
	15) dns[$2]='push "dhcp-option DNS 77.88.8.8"' ;;
	16) dns[$2]='push "dhcp-option DNS 77.88.8.1"' ;;
	17) dns[$2]='push "dhcp-option DNS 176.103.130.130"' ;;
	18) dns[$2]='push "dhcp-option DNS 176.103.130.131"' ;;
	esac
}
meu_ip() {
	if [[ -e /etc/VPS-MX/MEUIPvps ]]; then
		echo "$(cat /etc/VPS-MX/MEUIPvps)"
	else
		MEU_IP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
		MEU_IP2=$(wget -qO- ipv4.icanhazip.com)
		[[ "$MEU_IP" != "$MEU_IP2" ]] && echo "$MEU_IP2" || echo "$MEU_IP"
		echo "$MEU_IP" >/etc/VPS-MX/MEUIPvps
	fi
}
IP="$(meu_ip)"

instala_ovpn2() {
	msg -bar3
	clear
	msg -bar
	msg -tit
	echo -e "\033[1;32m     INSTALADOR DE OPENVPN | VPS-MX By @Kalix1"
	msg -bar
	# OpenVPN setup and first user creation
	echo -e "\033[1;97mSe necesitan ciertos parametros para configurar OpenVPN."
	echo "Configuracion por default solo presiona ENTER."
	echo "Primero, cual es la IPv4 que quieres para OpenVPN"
	echo "Detectando..."
	msg -bar
	# Autodetect IP address and pre-fill for the user
	IP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
	read -p "IP address: " -e -i $IP IP
	# If $IP is a private IP address, the server must be behind NAT
	if echo "$IP" | grep -qE '^(10\.|172\.1[6789]\.|172\.2[0-9]\.|172\.3[01]\.|192\.168)'; then
		echo
		echo "Este servidor esta detras de una red NAT?"
		read -p "IP  Publica  / hostname: " -e PUBLICIP
	fi
	msg -bar
	msg -ama "Que protocolo necesitas para las conexiones OpenVPN?"
	msg -bar
	echo "   1) UDP (recomendada)"
	echo "   2) TCP"
	msg -bar
	read -p "Protocolo [1-2]: " -e -i 1 PROTOCOL
	case $PROTOCOL in
	1)
		PROTOCOL=udp
		;;
	2)
		PROTOCOL=tcp
		;;
	esac
	msg -bar
	msg -ama "Que puerto necesitas en OpenVPN (Default 1194)?"
	msg -bar
	read -p "Puerto: " -e -i 1194 PORT
	msg -bar
	msg -ama "Cual DNS usaras en tu VPN?"
	msg -bar
	echo "   1) Actuales en el VPS"
	echo "   2) 1.1.1.1"
	echo "   3) Google"
	echo "   4) OpenDNS"
	echo "   5) Verisign"
	msg -bar
	read -p "DNS [1-5]: " -e -i 1 DNS
	#CIPHER
	msg -bar
	msg -ama " Elija que codificacion desea para el canal de datos:"
	msg -bar
	echo "   1) AES-128-CBC"
	echo "   2) AES-192-CBC"
	echo "   3) AES-256-CBC"
	echo "   4) CAMELLIA-128-CBC"
	echo "   5) CAMELLIA-192-CBC"
	echo "   6) CAMELLIA-256-CBC"
	echo "   7) SEED-CBC"
	echo "   8) NONE"
	msg -bar
	while [[ $CIPHER != @([1-8]) ]]; do
		read -p " Cipher [1-7]: " -e -i 1 CIPHER
	done
	case $CIPHER in
	1) CIPHER="cipher AES-128-CBC" ;;
	2) CIPHER="cipher AES-192-CBC" ;;
	3) CIPHER="cipher AES-256-CBC" ;;
	4) CIPHER="cipher CAMELLIA-128-CBC" ;;
	5) CIPHER="cipher CAMELLIA-192-CBC" ;;
	6) CIPHER="cipher CAMELLIA-256-CBC" ;;
	7) CIPHER="cipher SEED-CBC" ;;
	8) CIPHER="cipher none" ;;
	esac
	msg -bar
	msg -ama " Estamos listos para configurar su servidor OpenVPN"
	msg -bar
	read -n1 -r -p "Presiona cualquier tecla para continuar..."
	if [[ "$OS" = 'debian' ]]; then
		apt-get update
		apt-get install openvpn iptables openssl ca-certificates -y
	else
		#
		yum install epel-release -y
		yum install openvpn iptables openssl ca-certificates -y
	fi
	# Get easy-rsa
	EASYRSAURL='https://github.com/OpenVPN/easy-rsa/releases/download/v3.0.8/EasyRSA-3.0.8.tgz'
	wget -O ~/easyrsa.tgz "$EASYRSAURL" 2>/dev/null || curl -Lo ~/easyrsa.tgz "$EASYRSAURL"
	tar xzf ~/easyrsa.tgz -C ~/
	mv ~/EasyRSA-3.0.8/ /etc/openvpn/
	mv /etc/openvpn/EasyRSA-3.0.8/ /etc/openvpn/easy-rsa/
	chown -R root:root /etc/openvpn/easy-rsa/
	rm -f ~/easyrsa.tgz
	cd /etc/openvpn/easy-rsa/
	#
	./easyrsa init-pki
	./easyrsa --batch build-ca nopass
	./easyrsa gen-dh
	./easyrsa build-server-full server nopass
	EASYRSA_CRL_DAYS=3650 ./easyrsa gen-crl
	#
	cp pki/ca.crt pki/private/ca.key pki/dh.pem pki/issued/server.crt pki/private/server.key pki/crl.pem /etc/openvpn
	#
	chown nobody:$GROUPNAME /etc/openvpn/crl.pem
	#
	openvpn --genkey --secret /etc/openvpn/ta.key
	#
	echo "port $PORT
 proto $PROTOCOL
 dev tun
 sndbuf 0
 rcvbuf 0
 ca ca.crt
 cert server.crt
 key server.key
 dh dh.pem
 auth SHA512
 tls-auth ta.key 0
 topology subnet
 server 10.8.0.0 255.255.255.0
 ifconfig-pool-persist ipp.txt" >/etc/openvpn/server.conf
	echo 'push "redirect-gateway def1 bypass-dhcp"' >>/etc/openvpn/server.conf
	# DNS
	case $DNS in
	1)
		#
		#
		if grep -q "127.0.0.53" "/etc/resolv.conf"; then
			RESOLVCONF='/run/systemd/resolve/resolv.conf'
		else
			RESOLVCONF='/etc/resolv.conf'
		fi
		#
		grep -v '#' $RESOLVCONF | grep 'nameserver' | grep -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | while read line; do
			echo "push \"dhcp-option DNS $line\"" >>/etc/openvpn/server.conf
		done
		;;
	2)
		echo 'push "dhcp-option DNS 1.1.1.1"' >>/etc/openvpn/server.conf
		echo 'push "dhcp-option DNS 1.0.0.1"' >>/etc/openvpn/server.conf
		;;
	3)
		echo 'push "dhcp-option DNS 8.8.8.8"' >>/etc/openvpn/server.conf
		echo 'push "dhcp-option DNS 8.8.4.4"' >>/etc/openvpn/server.conf
		;;
	4)
		echo 'push "dhcp-option DNS 208.67.222.222"' >>/etc/openvpn/server.conf
		echo 'push "dhcp-option DNS 208.67.220.220"' >>/etc/openvpn/server.conf
		;;
	5)
		echo 'push "dhcp-option DNS 64.6.64.6"' >>/etc/openvpn/server.conf
		echo 'push "dhcp-option DNS 64.6.65.6"' >>/etc/openvpn/server.conf
		;;
	esac

	echo "keepalive 10 120
 ${CIPHER}
 user nobody
 group $GROUPNAME
 persist-key
 persist-tun
 status openvpn-status.log
 verb 3
 crl-verify crl.pem" >>/etc/openvpn/server.conf
	updatedb
	PLUGIN=$(locate openvpn-plugin-auth-pam.so | head -1)
	[[ ! -z $(echo ${PLUGIN}) ]] && {
		echo "client-to-client
 client-cert-not-required
 username-as-common-name
 plugin $PLUGIN login" >>/etc/openvpn/server.conf
	}
	#
	echo 'net.ipv4.ip_forward=1' >/etc/sysctl.d/30-openvpn-forward.conf
	#
	echo 1 >/proc/sys/net/ipv4/ip_forward
	if pgrep firewalld; then
		#
		#
		#
		#
		firewall-cmd --zone=public --add-port=$PORT/$PROTOCOL
		firewall-cmd --zone=trusted --add-source=10.8.0.0/24
		firewall-cmd --permanent --zone=public --add-port=$PORT/$PROTOCOL
		firewall-cmd --permanent --zone=trusted --add-source=10.8.0.0/24
		#
		firewall-cmd --direct --add-rule ipv4 nat POSTROUTING 0 -s 10.8.0.0/24 ! -d 10.8.0.0/24 -j SNAT --to $IP
		firewall-cmd --permanent --direct --add-rule ipv4 nat POSTROUTING 0 -s 10.8.0.0/24 ! -d 10.8.0.0/24 -j SNAT --to $IP
	else
		#
		if [[ "$OS" = 'debian' && ! -e $RCLOCAL ]]; then
			echo '#!/bin/sh -e
 exit 0' >$RCLOCAL
		fi
		chmod +x $RCLOCAL
		#
		iptables -t nat -A POSTROUTING -s 10.8.0.0/24 ! -d 10.8.0.0/24 -j SNAT --to $IP
		sed -i "1 a\iptables -t nat -A POSTROUTING -s 10.8.0.0/24 ! -d 10.8.0.0/24 -j SNAT --to $IP" $RCLOCAL
		if iptables -L -n | grep -qE '^(REJECT|DROP)'; then
			#
			#
			#
			iptables -I INPUT -p $PROTOCOL --dport $PORT -j ACCEPT
			iptables -I FORWARD -s 10.8.0.0/24 -j ACCEPT
			iptables -I FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
			sed -i "1 a\iptables -I INPUT -p $PROTOCOL --dport $PORT -j ACCEPT" $RCLOCAL
			sed -i "1 a\iptables -I FORWARD -s 10.8.0.0/24 -j ACCEPT" $RCLOCAL
			sed -i "1 a\iptables -I FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT" $RCLOCAL
		fi
	fi
	#
	if sestatus 2>/dev/null | grep "Current mode" | grep -q "enforcing" && [[ "$PORT" != '1194' ]]; then
		#
		if ! hash semanage 2>/dev/null; then
			yum install policycoreutils-python -y
		fi
		semanage port -a -t openvpn_port_t -p $PROTOCOL $PORT
	fi
	#
	if [[ "$OS" = 'debian' ]]; then
		#
		if pgrep systemd-journal; then
			systemctl restart openvpn@server.service
		else
			/etc/init.d/openvpn restart
		fi
	else
		if pgrep systemd-journal; then
			systemctl restart openvpn@server.service
			systemctl enable openvpn@server.service
		else
			service openvpn restart
			chkconfig openvpn on
		fi
	fi
	#
	if [[ "$PUBLICIP" != "" ]]; then
		IP=$PUBLICIP
	fi
	#
	echo "# OVPN_ACCESS_SERVER_PROFILE=VPS-MX
 client
 dev tun
 proto $PROTOCOL
 sndbuf 0
 rcvbuf 0
 remote $IP $PORT
 resolv-retry infinite
 nobind
 persist-key
 persist-tun
 remote-cert-tls server
 auth SHA512
 ${CIPHER}
 setenv opt block-outside-dns
 key-direction 1
 verb 3
 auth-user-pass" >/etc/openvpn/client-common.txt
	msg -bar
	msg -ama " Ahora crear una SSH para generar el (.ovpn)!"
	msg -bar
	echo -e "\033[1;32m Configuracion Finalizada!"
	msg -bar

}

instala_ovpn() {
	parametros_iniciais() {
		#Verifica o Sistema
		[[ "$EUID" -ne 0 ]] && echo " Lo siento, usted necesita ejecutar esto como ROOT" && exit 1
		[[ ! -e /dev/net/tun ]] && echo " TUN no esta Disponible" && exit 1
		if [[ -e /etc/debian_version ]]; then
			OS="debian"
			VERSION_ID=$(cat /etc/os-release | grep "VERSION_ID")
			IPTABLES='/etc/iptables/iptables.rules'
			[[ ! -d /etc/iptables ]] && mkdir /etc/iptables
			[[ ! -e $IPTABLES ]] && touch $IPTABLES
			SYSCTL='/etc/sysctl.conf'
			[[ "$VERSION_ID" != 'VERSION_ID="7"' ]] && [[ "$VERSION_ID" != 'VERSION_ID="8"' ]] && [[ "$VERSION_ID" != 'VERSION_ID="9"' ]] && [[ "$VERSION_ID" != 'VERSION_ID="14.04"' ]] && [[ "$VERSION_ID" != 'VERSION_ID="16.04"' ]] && [[ "$VERSION_ID" != 'VERSION_ID="18.04"' ]] && [[ "$VERSION_ID" != 'VERSION_ID="17.10"' ]] && {
				echo " Su vercion de Debian / Ubuntu no Soportada."
				while [[ $CONTINUE != @(y|Y|s|S|n|N) ]]; do
					read -p "Continuar ? [y/n]: " -e CONTINUE
				done
				[[ "$CONTINUE" = @(n|N) ]] && exit 1
			}
		else
			msg -ama " Parece que no estas ejecutando este instalador en un sistema Debian o Ubuntu"
			msg -bar
			return 1
		fi
		#Pega Interface
		NIC=$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)

	}
	add_repo() {
		#INSTALACAO E UPDATE DO REPOSITORIO
		# Debian 7
		if [[ "$VERSION_ID" = 'VERSION_ID="7"' ]]; then
			echo "deb http://build.openvpn.net/debian/openvpn/stable wheezy main" >/etc/apt/sources.list.d/openvpn.list
			wget -q -O - https://swupdate.openvpn.net/repos/repo-public.gpg | apt-key add - >/dev/null 2>&1
		# Debian 8
		elif [[ "$VERSION_ID" = 'VERSION_ID="8"' ]]; then
			echo "deb http://build.openvpn.net/debian/openvpn/stable jessie main" >/etc/apt/sources.list.d/openvpn.list
			wget -q -O - https://swupdate.openvpn.net/repos/repo-public.gpg | apt-key add - >/dev/null 2>&1
		# Ubuntu 14.04
		elif [[ "$VERSION_ID" = 'VERSION_ID="14.04"' ]]; then
			echo "deb http://build.openvpn.net/debian/openvpn/stable trusty main" >/etc/apt/sources.list.d/openvpn.list
			wget -q -O - https://swupdate.openvpn.net/repos/repo-public.gpg | apt-key add - >/dev/null 2>&1
		# Ubuntu 16.04
		elif [[ "$VERSION_ID" = 'VERSION_ID="16.04"' ]]; then
			echo "deb http://build.openvpn.net/debian/openvpn/stable xenial main" >/etc/apt/sources.list.d/openvpn.list
			wget -q -O - https://swupdate.openvpn.net/repos/repo-public.gpg | apt-key add - >/dev/null 2>&1
		# Ubuntu 18.04
		elif [[ "$VERSION_ID" = 'VERSION_ID="18.04"' ]]; then
			apt-get remove openvpn -y >/dev/null 2>&1
			rm -rf /etc/apt/sources.list.d/openvpn.list >/dev/null 2>&1
			echo "deb http://build.openvpn.net/debian/openvpn/stable bionic main" >/etc/apt/sources.list.d/openvpn.list
			wget -q -O - https://swupdate.openvpn.net/repos/repo-public.gpg | apt-key add - >/dev/null 2>&1
		fi
	}
	coleta_variaveis() {
		echo -e "\033[1;32m     INSTALADOR DE OPENVPN | VPS-MX By @Kalix1"
		msg -bar
		msg -ne " Confirme su IP"
		read -p ": " -e -i $IP ip
		msg -bar
		msg -ama " Que puerto desea usar?"
		msg -bar
		while true; do
			read -p " Port: " -e -i 1194 PORT
			[[ $(mportas | grep -w "$PORT") ]] || break
			echo -e "\033[1;33m Este puerto esta en uso\033[0m"
			unset PORT
		done
		msg -bar
		echo -e "\033[1;31m Que protocolo desea para las conexiones OPENVPN?"
		echo -e "\033[1;31m A menos que UDP este bloqueado, no utilice TCP (es mas lento)"
		#PROTOCOLO
		while [[ $PROTOCOL != @(UDP|TCP) ]]; do
			read -p " Protocol [UDP/TCP]: " -e -i TCP PROTOCOL
		done
		[[ $PROTOCOL = "UDP" ]] && PROTOCOL=udp
		[[ $PROTOCOL = "TCP" ]] && PROTOCOL=tcp
		#DNS
		msg -bar
		msg -ama " Que DNS desea utilizar?"
		msg -bar
		echo "   1) Usar DNS de sistema "
		echo "   2) Cloudflare"
		echo "   3) Quad"
		echo "   4) FDN"
		echo "   5) DNS.WATCH"
		echo "   6) OpenDNS"
		echo "   7) Google DNS"
		echo "   8) Yandex Basic"
		echo "   9) AdGuard DNS"
		msg -bar
		while [[ $DNS != @([1-9]) ]]; do
			read -p " DNS [1-9]: " -e -i 1 DNS
		done
		#CIPHER
		msg -bar
		msg -ama " Elija que codificacion desea para el canal de datos:"
		msg -bar
		echo "   1) AES-128-CBC"
		echo "   2) AES-192-CBC"
		echo "   3) AES-256-CBC"
		echo "   4) CAMELLIA-128-CBC"
		echo "   5) CAMELLIA-192-CBC"
		echo "   6) CAMELLIA-256-CBC"
		echo "   7) SEED-CBC"
		msg -bar
		while [[ $CIPHER != @([1-7]) ]]; do
			read -p " Cipher [1-7]: " -e -i 1 CIPHER
		done
		case $CIPHER in
		1) CIPHER="cipher AES-128-CBC" ;;
		2) CIPHER="cipher AES-192-CBC" ;;
		3) CIPHER="cipher AES-256-CBC" ;;
		4) CIPHER="cipher CAMELLIA-128-CBC" ;;
		5) CIPHER="cipher CAMELLIA-192-CBC" ;;
		6) CIPHER="cipher CAMELLIA-256-CBC" ;;
		7) CIPHER="cipher SEED-CBC" ;;
		esac
		msg -bar
		msg -ama " Estamos listos para configurar su servidor OpenVPN"
		msg -bar
		read -n1 -r -p " Enter para Continuar ..."
		tput cuu1 && tput dl1
	}
	parametros_iniciais # BREVE VERIFICACAO
	coleta_variaveis    # COLETA VARIAVEIS PARA INSTALAÇÃO
	add_repo            # ATUALIZA REPOSITÓRIO OPENVPN E INSTALA OPENVPN
	# Cria Diretorio
	[[ ! -d /etc/openvpn ]] && mkdir /etc/openvpn
	# Install openvpn
	echo -ne " \033[1;31m[ ! ] apt-get update"
	apt-get update -q >/dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
	echo -ne " \033[1;31m[ ! ] apt-get install openvpn curl openssl"
	apt-get install -qy openvpn curl >/dev/null 2>&1 && apt-get install openssl ca-certificates -y >/dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
	SERVER_IP="$(meu_ip)" # IP Address
	[[ -z "${SERVER_IP}" ]] && SERVER_IP=$(ip a | awk -F"[ /]+" '/global/ && !/127.0/ {print $3; exit}')
	echo -ne " \033[1;31m[ ! ] Generating Server Config" # Gerando server.con
	(
		case $DNS in
		1)
			i=0
			grep -v '#' /etc/resolv.conf | grep 'nameserver' | grep -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | while read line; do
				dns[$i]="push \"dhcp-option DNS $line\""
			done
			[[ ! "${dns[@]}" ]] && dns[0]='push "dhcp-option DNS 8.8.8.8"' && dns[1]='push "dhcp-option DNS 8.8.4.4"'
			;;
		2) dns_fun 3 && dns_fun 4 ;;
		3) dns_fun 5 && dns_fun 6 ;;
		4) dns_fun 7 && dns_fun 8 ;;
		5) dns_fun 9 && dns_fun 10 ;;
		6) dns_fun 11 && dns_fun 12 ;;
		7) dns_fun 13 && dns_fun 14 ;;
		8) dns_fun 15 && dns_fun 16 ;;
		9) dns_fun 17 && dns_fun 18 ;;
		esac
		echo 01 >/etc/openvpn/ca.srl
		while [[ ! -e /etc/openvpn/dh.pem || -z $(cat /etc/openvpn/dh.pem) ]]; do
			openssl dhparam -out /etc/openvpn/dh.pem 2048 &>/dev/null
		done
		while [[ ! -e /etc/openvpn/ca-key.pem || -z $(cat /etc/openvpn/ca-key.pem) ]]; do
			openssl genrsa -out /etc/openvpn/ca-key.pem 2048 &>/dev/null
		done
		chmod 600 /etc/openvpn/ca-key.pem &>/dev/null
		while [[ ! -e /etc/openvpn/ca-csr.pem || -z $(cat /etc/openvpn/ca-csr.pem) ]]; do
			openssl req -new -key /etc/openvpn/ca-key.pem -out /etc/openvpn/ca-csr.pem -subj /CN=OpenVPN-CA/ &>/dev/null
		done
		while [[ ! -e /etc/openvpn/ca.pem || -z $(cat /etc/openvpn/ca.pem) ]]; do
			openssl x509 -req -in /etc/openvpn/ca-csr.pem -out /etc/openvpn/ca.pem -signkey /etc/openvpn/ca-key.pem -days 365 &>/dev/null
		done

		cat >/etc/openvpn/server.conf <<EOF
server 10.8.0.0 255.255.255.0
verb 3
duplicate-cn
key client-key.pem
ca ca.pem
cert client-cert.pem
dh dh.pem
keepalive 10 120
persist-key
persist-tun
comp-lzo
float
push "redirect-gateway def1 bypass-dhcp"
${dns[0]}
${dns[1]}

user nobody
group nogroup

${CIPHER}
proto ${PROTOCOL}
port $PORT
dev tun
status openvpn-status.log
EOF
		updatedb
		PLUGIN=$(locate openvpn-plugin-auth-pam.so | head -1)
		[[ ! -z $(echo ${PLUGIN}) ]] && {
			echo "client-to-client
 client-cert-not-required
 username-as-common-name
 plugin $PLUGIN login" >>/etc/openvpn/server.conf
		}
	) && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
	echo -ne " \033[1;31m[ ! ] Generating CA Config" # Generate CA Config
	(
		while [[ ! -e /etc/openvpn/client-key.pem || -z $(cat /etc/openvpn/client-key.pem) ]]; do
			openssl genrsa -out /etc/openvpn/client-key.pem 2048 &>/dev/null
		done
		chmod 600 /etc/openvpn/client-key.pem
		while [[ ! -e /etc/openvpn/client-csr.pem || -z $(cat /etc/openvpn/client-csr.pem) ]]; do
			openssl req -new -key /etc/openvpn/client-key.pem -out /etc/openvpn/client-csr.pem -subj /CN=OpenVPN-Client/ &>/dev/null
		done
		while [[ ! -e /etc/openvpn/client-cert.pem || -z $(cat /etc/openvpn/client-cert.pem) ]]; do
			openssl x509 -req -in /etc/openvpn/client-csr.pem -out /etc/openvpn/client-cert.pem -CA /etc/openvpn/ca.pem -CAkey /etc/openvpn/ca-key.pem -days 365 &>/dev/null
		done
	) && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
	teste_porta() {
		msg -bar
		echo -ne " \033[1;31m$(fun_trans ${id} "Verificando"):"
		sleep 1s
		[[ ! $(mportas | grep "$1") ]] && {
			echo -e "\033[1;33m [FAIL]\033[0m"
		} || {
			echo -e "\033[1;32m [Pass]\033[0m"
			return 1
		}
	}
	msg -bar
	echo -e "\033[1;33m Ahora Necesitamos un Proxy SQUID o PYTHON-OPENVPN"
	echo -e "\033[1;33m Si no existe un proxy en la puerta, un proxy Python sera abierto!"
	msg -bar
	while [[ $? != "1" ]]; do
		read -p " Confirme el Puerto(Proxy) " -e -i 80 PPROXY
		teste_porta $PPROXY
	done
	cat >/etc/openvpn/client-common.txt <<EOF
# OVPN_ACCESS_SERVER_PROFILE=VPS-MX
client
nobind
dev tun
redirect-gateway def1 bypass-dhcp
remote-random
remote ${SERVER_IP} ${PORT} ${PROTOCOL}
http-proxy ${SERVER_IP} ${PPROXY}
$CIPHER
comp-lzo yes
keepalive 10 20
float
auth-user-pass
EOF
	# Iptables
	if [[ ! -f /proc/user_beancounters ]]; then
		INTIP=$(ip a | awk -F"[ /]+" '/global/ && !/127.0/ {print $3; exit}')
		N_INT=$(ip a | awk -v sip="$INTIP" '$0 ~ sip { print $7}')
		iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o $N_INT -j MASQUERADE
		iptables -t nat -A POSTROUTING -s 10.8.0.0/24 ! -d 10.8.0.0/24 -j SNAT --to $SERVER_IP
	else
		iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -j SNAT --to-source $SERVER_IP

	fi
	iptables-save >/etc/iptables.conf
	cat >/etc/network/if-up.d/iptables <<EOF
#!/bin/sh
iptables-restore < /etc/iptables.conf
EOF
	chmod +x /etc/network/if-up.d/iptables
	# Enable net.ipv4.ip_forward
	sed -i 's|#net.ipv4.ip_forward=1|net.ipv4.ip_forward=1|' /etc/sysctl.conf
	echo 1 >/proc/sys/net/ipv4/ip_forward
	# Regras de Firewall
	if pgrep firewalld; then
		if [[ "$PROTOCOL" = 'udp' ]]; then
			firewall-cmd --zone=public --add-port=$PORT/udp
			firewall-cmd --permanent --zone=public --add-port=$PORT/udp
		elif [[ "$PROTOCOL" = 'tcp' ]]; then
			firewall-cmd --zone=public --add-port=$PORT/tcp
			firewall-cmd --permanent --zone=public --add-port=$PORT/tcp
		fi
		firewall-cmd --zone=trusted --add-source=10.8.0.0/24
		firewall-cmd --permanent --zone=trusted --add-source=10.8.0.0/24
	fi
	if iptables -L -n | grep -qE 'REJECT|DROP'; then
		if [[ "$PROTOCOL" = 'udp' ]]; then
			iptables -I INPUT -p udp --dport $PORT -j ACCEPT
		elif [[ "$PROTOCOL" = 'tcp' ]]; then
			iptables -I INPUT -p tcp --dport $PORT -j ACCEPT
		fi
		iptables -I FORWARD -s 10.8.0.0/24 -j ACCEPT
		iptables -I FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
		iptables-save >$IPTABLES
	fi
	if hash sestatus 2>/dev/null; then
		if sestatus | grep "Current mode" | grep -qs "enforcing"; then
			if [[ "$PORT" != '1194' ]]; then
				if ! hash semanage 2>/dev/null; then
					yum install policycoreutils-python -y
				fi
				if [[ "$PROTOCOL" = 'udp' ]]; then
					semanage port -a -t openvpn_port_t -p udp $PORT
				elif [[ "$PROTOCOL" = 'tcp' ]]; then
					semanage port -a -t openvpn_port_t -p tcp $PORT
				fi
			fi
		fi
	fi
	#Liberando DNS
	msg -bar
	msg -ama " Ultimo Paso, Configuraciones DNS"
	msg -bar
	while [[ $DDNS != @(n|N) ]]; do
		echo -ne "\033[1;33m"
		read -p " Agergar HOST DNS [S/N]: " -e -i n DDNS
		[[ $DDNS = @(s|S|y|Y) ]] && agrega_dns
	done
	[[ ! -z $NEWDNS ]] && {
		sed -i "/127.0.0.1[[:blank:]]\+localhost/a 127.0.0.1 $NEWDNS" /etc/hosts
		for DENESI in $(echo $NEWDNS); do
			sed -i "/remote ${SERVER_IP} ${PORT} ${PROTOCOL}/a remote ${DENESI} ${PORT} ${PROTOCOL}" /etc/openvpn/client-common.txt
		done
	}
	msg -bar
	# REINICIANDO OPENVPN
	if [[ "$OS" = 'debian' ]]; then
		if pgrep systemd-journal; then
			sed -i 's|LimitNPROC|#LimitNPROC|' /lib/systemd/system/openvpn\@.service
			sed -i 's|/etc/openvpn/server|/etc/openvpn|' /lib/systemd/system/openvpn\@.service
			sed -i 's|%i.conf|server.conf|' /lib/systemd/system/openvpn\@.service
			#systemctl daemon-reload
			(
				systemctl restart openvpn
				systemctl enable openvpn
			) >/dev/null 2>&1
		else
			/etc/init.d/openvpn restart >/dev/null 2>&1
		fi
	else
		if pgrep systemd-journal; then
			(
				systemctl restart openvpn@server.service
				systemctl enable openvpn@server.service
			) >/dev/null 2>&1
		else
			(
				service openvpn restart
				chkconfig openvpn on
			) >/dev/null 2>&1
		fi
	fi
	service squid restart &>/dev/null
	service squid3 restart &>/dev/null
	apt-get install ufw -y >/dev/null 2>&1
	for ufww in $(mportas | awk '{print $2}'); do
		ufw allow $ufww >/dev/null 2>&1
	done
	#Restart OPENVPN
	(
		killall openvpn 2>/dev/null
		systemctl stop openvpn@server.service >/dev/null 2>&1
		service openvpn stop >/dev/null 2>&1
		sleep 0.1s
		cd /etc/openvpn >/dev/null 2>&1
		screen -dmS ovpnscr openvpn --config "server.conf" >/dev/null 2>&1
	) >/dev/null 2>&1
	echo -e "\033[1;32m Openvpn configurado con EXITO!"
	msg -bar
	msg -ama " Ahora crear una SSH para generar el (.ovpn)!"
	msg -bar
	return 0
}
edit_ovpn_host() {
	msg -bar3
	msg -ama " CONFIGURACION HOST DNS OPENVPN"
	msg -bar
	while [[ $DDNS != @(n|N) ]]; do
		echo -ne "\033[1;33m"
		read -p " Agregar host [S/N]: " -e -i n DDNS
		[[ $DDNS = @(s|S|y|Y) ]] && agrega_dns
	done
	[[ ! -z $NEWDNS ]] && sed -i "/127.0.0.1[[:blank:]]\+localhost/a 127.0.0.1 $NEWDNS" /etc/hosts
	msg -bar
	msg -ama " Es Necesario el Reboot del Servidor Para"
	msg -ama " Para que las configuraciones sean efectudas"
	msg -bar
}
fun_openvpn() {
	[[ -e /etc/openvpn/server.conf ]] && {
		unset OPENBAR
		[[ $(mportas | grep -w "openvpn") ]] && OPENBAR="\033[1;32m ONLINE" || OPENBAR="\033[1;31m OFFLINE"
		msg -ama " OPENVPN YA ESTA INSTALADO"
		msg -bar
		echo -e "\033[1;32m [1] >\033[1;36m DESINSTALAR  OPENVPN"
		echo -e "\033[1;32m [2] >\033[1;36m EDITAR CONFIGURACION CLIENTE \033[1;31m(MEDIANTE NANO)"
		echo -e "\033[1;32m [3] >\033[1;36m EDITAR CONFIGURACION SERVIDOR \033[1;31m(MEDIANTE NANO)"
		echo -e "\033[1;32m [4] >\033[1;36m CAMBIAR HOST DE OPENVPN"
		echo -e "\033[1;32m [5] >\033[1;36m INICIAR O PARAR OPENVPN - $OPENBAR"
		msg -bar
		while [[ $xption != @([0|1|2|3|4|5]) ]]; do
			echo -ne "\033[1;33m $(fun_trans "Opcion"): " && read xption
			tput cuu1 && tput dl1
		done
		case $xption in
		1)
			clear
			msg -bar
			echo -ne "\033[1;97m"
			read -p "QUIERES DESINTALAR OPENVPN? [Y/N]: " -e REMOVE
			msg -bar
			if [[ "$REMOVE" = 'y' || "$REMOVE" = 'Y' ]]; then
				PORT=$(grep '^port ' /etc/openvpn/server.conf | cut -d " " -f 2)
				PROTOCOL=$(grep '^proto ' /etc/openvpn/server.conf | cut -d " " -f 2)
				if pgrep firewalld; then
					IP=$(firewall-cmd --direct --get-rules ipv4 nat POSTROUTING | grep '\-s 10.8.0.0/24 '"'"'!'"'"' -d 10.8.0.0/24 -j SNAT --to ' | cut -d " " -f 10)
					#
					firewall-cmd --zone=public --remove-port=$PORT/$PROTOCOL
					firewall-cmd --zone=trusted --remove-source=10.8.0.0/24
					firewall-cmd --permanent --zone=public --remove-port=$PORT/$PROTOCOL
					firewall-cmd --permanent --zone=trusted --remove-source=10.8.0.0/24
					firewall-cmd --direct --remove-rule ipv4 nat POSTROUTING 0 -s 10.8.0.0/24 ! -d 10.8.0.0/24 -j SNAT --to $IP
					firewall-cmd --permanent --direct --remove-rule ipv4 nat POSTROUTING 0 -s 10.8.0.0/24 ! -d 10.8.0.0/24 -j SNAT --to $IP
				else
					IP=$(grep 'iptables -t nat -A POSTROUTING -s 10.8.0.0/24 ! -d 10.8.0.0/24 -j SNAT --to ' $RCLOCAL | cut -d " " -f 14)
					iptables -t nat -D POSTROUTING -s 10.8.0.0/24 ! -d 10.8.0.0/24 -j SNAT --to $IP
					sed -i '/iptables -t nat -A POSTROUTING -s 10.8.0.0\/24 ! -d 10.8.0.0\/24 -j SNAT --to /d' $RCLOCAL
					if iptables -L -n | grep -qE '^ACCEPT'; then
						iptables -D INPUT -p $PROTOCOL --dport $PORT -j ACCEPT
						iptables -D FORWARD -s 10.8.0.0/24 -j ACCEPT
						iptables -D FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
						sed -i "/iptables -I INPUT -p $PROTOCOL --dport $PORT -j ACCEPT/d" $RCLOCAL
						sed -i "/iptables -I FORWARD -s 10.8.0.0\/24 -j ACCEPT/d" $RCLOCAL
						sed -i "/iptables -I FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT/d" $RCLOCAL
					fi
				fi
				if sestatus 2>/dev/null | grep "Current mode" | grep -q "enforcing" && [[ "$PORT" != '1194' ]]; then
					semanage port -d -t openvpn_port_t -p $PROTOCOL $PORT
				fi
				if [[ "$OS" = 'debian' ]]; then
					apt-get remove --purge -y openvpn
				else
					yum remove openvpn -y
				fi
				rm -rf /etc/openvpn
				rm -f /etc/sysctl.d/30-openvpn-forward.conf
				msg -bar
				echo "OpenVPN removido!"
				msg -bar
			else
				msg -bar
				echo "Desinstalacion abortada!"
				msg -bar
			fi
			return 0
			;;
		2)
			nano /etc/openvpn/client-common.txt
			return 0
			;;
		3)
			nano /etc/openvpn/server.conf
			return 0
			;;
		4) edit_ovpn_host ;;
		5)
			[[ $(mportas | grep -w openvpn) ]] && {
				/etc/init.d/openvpn stop >/dev/null 2>&1
				killall openvpn &>/dev/null
				systemctl stop openvpn@server.service &>/dev/null
				service openvpn stop &>/dev/null
				#ps x |grep openvpn |grep -v grep|awk '{print $1}' | while read pid; do kill -9 $pid; done
			} || {
				cd /etc/openvpn
				screen -dmS ovpnscr openvpn --config "server.conf" >/dev/null 2>&1
				cd $HOME
			}
			msg -ama " Procedimiento Hecho con Exito"
			msg -bar
			return 0
			;;
		0)
			return 0
			;;
		esac
		exit
	}
	[[ -e /etc/squid/squid.conf ]] && instala_ovpn2 && return 0
	[[ -e /etc/squid3/squid.conf ]] && instala_ovpn2 && return 0

	instala_ovpn2 || return 1
}

fun_openvpn
