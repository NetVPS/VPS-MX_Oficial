#!/bin/bash
 
 #25/01/2021 by @Kalix1
 clear
 clear
 SCPdir="/etc/VPS-MX"
 SCPfrm="${SCPdir}/herramientas" && [[ ! -d ${SCPfrm} ]] && exit
 SCPinst="${SCPdir}/protocolos"&& [[ ! -d ${SCPinst} ]] && exit
 
 declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
 [[ $(dpkg --get-selections|grep -w "python"|head -1) ]] || apt-get install python -y &>/dev/null
 [[ $(dpkg --get-selections|grep -w "python-pip"|head -1) ]] || apt-get install python pip -y &>/dev/null
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
 meu_ip () {
 MEU_IP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
 MEU_IP2=$(wget -qO- ipv4.icanhazip.com)
 [[ "$MEU_IP" != "$MEU_IP2" ]] && echo "$MEU_IP2" || echo "$MEU_IP"
 }
 IP=$(wget -qO- ipv4.icanhazip.com)
 tcpbypass_fun () {
 [[ -e $HOME/socks ]] && rm -rf $HOME/socks > /dev/null 2>&1
 [[ -d $HOME/socks ]] && rm -rf $HOME/socks > /dev/null 2>&1
 cd $HOME && mkdir socks > /dev/null 2>&1
 cd socks
 patch="https://raw.githubusercontent.com/NetVPS/VPS-MX_Oficial/master/LINKS-LIBRERIAS/backsocz.zip"
 arq="backsocz"
 wget $patch -o /dev/null
 unzip $arq > /dev/null 2>&1
 mv -f ./ssh /etc/ssh/sshd_config && service ssh restart 1> /dev/null 2>/dev/null
 mv -f sckt$(python3 --version|awk '{print $2}'|cut -d'.' -f1,2) /usr/sbin/sckt
 mv -f scktcheck /bin/scktcheck
 chmod +x /bin/scktcheck
 chmod +x  /usr/sbin/sckt
 rm -rf $HOME/socks
 cd $HOME
 msg="$2"
 [[ $msg = "" ]] && msg="@vpsmod"
 portxz="$1"
 [[ $portxz = "" ]] && portxz="8080"
 screen -dmS sokz scktcheck "$portxz" "$msg" > /dev/null 2>&1
 }
 gettunel_fun () {
 echo "master=NetVPS" > ${SCPinst}/pwd.pwd
 while read service; do
 [[ -z $service ]] && break
 echo "127.0.0.1:$(echo $service|cut -d' ' -f2)=$(echo $service|cut -d' ' -f1)" >> ${SCPinst}/pwd.pwd
 done <<< "$(mportas)"
 screen -dmS getpy python ${SCPinst}/PGet.py -b "0.0.0.0:$1" -p "${SCPinst}/pwd.pwd"
  [[ "$(ps x | grep "PGet.py" | grep -v "grep" | awk -F "pts" '{print $1}')" ]] && {
  echo -e "$(fun_trans  "Gettunel Iniciado con Sucesso")"
  msg -bar
  echo -ne "$(fun_trans  "Su contraseña Gettunel es"):"
  echo -e "\033[1;32m NetVPS"
  msg -bar
  } || echo -e "$(fun_trans  "Gettunel no fue iniciado")"
  msg -bar
 }
 
 PythonDic_fun () {
 if [[ ! -e /etc/VPS-MX/fix ]]; then
 		echo ""
 ins(){
 apt-get install python -y 
 apt-get install python pip -y
 }
 ins &>/dev/null && echo -e "INSTALANDO FIX" | pv -qL 40
 sleep 1.s
 [[ ! -e /etc/VPS-MX/fix ]] && touch /etc/VPS-MX/fix
 else
 echo ""
 fi
 clear
 echo ""
 echo ""
 msg -tit
 msg -bar
 echo -e "\033[1;31m  SOCKS DIRECTO-PY | CUSTOM\033[0m"
 while true; do
 msg -bar
 	echo -ne "\033[1;37m"
     read -p " ESCRIBE SU PUERTO: " porta_socket
 	echo -e ""
     [[ $(mportas|grep -w "$porta_socket") ]] || break
     echo -e " ESTE PUERTO YA ESTÁ EN USO"
     unset porta_socket
     done
     msg -bar
 echo -e "\033[1;97m Digite Un Puerto Local 22|443|80\033[1;37m" 
 msg -bar
  while true; do		
          echo -ne "\033[1;36m"
          read -p " Digite Un Puerto SSH/DROPBEAR activo: " PORTLOC
 		 echo -e ""
          if [[ ! -z $PORTLOC ]]; then
              if [[ $(echo $PORTLOC|grep [0-9]) ]]; then
                 [[ $(mportas|grep $PORTLOC|head -1) ]] && break || echo -e "ESTE PUERTO NO EXISTE"
              fi
          fi
          done
  #        
 puertoantla="$(mportas|grep $PORTLOC|awk '{print $2}'|head -1)"
 msg -bar
  echo -ne " Escribe El HTTP Response? 101|200|300: \033[1;37m" && read cabezado
  tput cuu1 && tput dl1
      if [[ -z $cabezado ]]; then
         cabezado="200"
         echo -e "	\e[31mResponse Default:\033[1;32m ${cabezado}"
     else
         echo -e "	\e[31mResponse Elegido:\033[1;32m ${cabezado}"
     fi
 msg -bar
 echo -e "$(fun_trans  "Introdusca su Mini-Banner")"
 	msg -bar
 	echo -ne " Introduzca el texto de estado plano o en HTML:\n \033[1;37m" && read texto_soket
    tput cuu1 && tput dl1
      if [[ -z $texto_soket ]]; then
         texto_soket="@lacasitamx"
         echo -e "	\e[31mMensage Default: \033[1;32m${texto_soket} "
     else
         echo -e "	\e[31mMensage: \033[1;32m ${texto_soket}"
     fi
  msg -bar
 (
 less << CPM > /etc/VPS-MX/protocolos/PDirect.py
 import socket, threading, thread, select, signal, sys, time, getopt
 
 # Listen
 LISTENING_ADDR = '0.0.0.0'
 LISTENING_PORT = int("$porta_socket")
 PASS = ''
 
 # CONST
 BUFLEN = 4096 * 4
 TIMEOUT = 60
 DEFAULT_HOST = '127.0.0.1:$puertoantla'
 RESPONSE = 'HTTP/1.1 $cabezado <strong>$texto_soket</strong>\r\n\r\nHTTP/1.1 $cabezado Conexion Exitosa\r\n\r\n'
 
 class Server(threading.Thread):
     def __init__(self, host, port):
         threading.Thread.__init__(self)
         self.running = False
         self.host = host
         self.port = port
         self.threads = []
         self.threadsLock = threading.Lock()
         self.logLock = threading.Lock()
     def run(self):
         self.soc = socket.socket(socket.AF_INET)
         self.soc.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
         self.soc.settimeout(2)
         self.soc.bind((self.host, self.port))
         self.soc.listen(0)
         self.running = True
         try:
             while self.running:
                 try:
                     c, addr = self.soc.accept()
                     c.setblocking(1)
                 except socket.timeout:
                     continue
                 conn = ConnectionHandler(c, self, addr)
                 conn.start()
                 self.addConn(conn)
         finally:
             self.running = False
             self.soc.close()
     def printLog(self, log):
         self.logLock.acquire()
         print log
         self.logLock.release()
     def addConn(self, conn):
         try:
             self.threadsLock.acquire()
             if self.running:
                 self.threads.append(conn)
         finally:
             self.threadsLock.release()
     def removeConn(self, conn):
         try:
             self.threadsLock.acquire()
             self.threads.remove(conn)
         finally:
             self.threadsLock.release()
     def close(self):
         try:
             self.running = False
             self.threadsLock.acquire()
             threads = list(self.threads)
             for c in threads:
                 c.close()
         finally:
             self.threadsLock.release()
 class ConnectionHandler(threading.Thread):
     def __init__(self, socClient, server, addr):
         threading.Thread.__init__(self)
         self.clientClosed = False
         self.targetClosed = True
         self.client = socClient
         self.client_buffer = ''
         self.server = server
         self.log = 'Connection: ' + str(addr)
     def close(self):
         try:
             if not self.clientClosed:
                 self.client.shutdown(socket.SHUT_RDWR)
                 self.client.close()
         except:
             pass
         finally:
             self.clientClosed = True
         try:
             if not self.targetClosed:
                 self.target.shutdown(socket.SHUT_RDWR)
                 self.target.close()
         except:
             pass
         finally:
             self.targetClosed = True
     def run(self):
         try:
             self.client_buffer = self.client.recv(BUFLEN)
             hostPort = self.findHeader(self.client_buffer, 'X-Real-Host')
             if hostPort == '':
                 hostPort = DEFAULT_HOST
             split = self.findHeader(self.client_buffer, 'X-Split')
             if split != '':
                 self.client.recv(BUFLEN)
             if hostPort != '':
                 passwd = self.findHeader(self.client_buffer, 'X-Pass')
 				
                 if len(PASS) != 0 and passwd == PASS:
                     self.method_CONNECT(hostPort)
                 elif len(PASS) != 0 and passwd != PASS:
                     self.client.send('HTTP/1.1 400 WrongPass!\r\n\r\n')
                 elif hostPort.startswith('127.0.0.1') or hostPort.startswith('localhost'):
                     self.method_CONNECT(hostPort)
                 else:
                     self.client.send('HTTP/1.1 403 Forbidden!\r\n\r\n')
             else:
                 print '- No X-Real-Host!'
                 self.client.send('HTTP/1.1 400 NoXRealHost!\r\n\r\n')
         except Exception as e:
             self.log += ' - error: ' + e.strerror
             self.server.printLog(self.log)
 	    pass
         finally:
             self.close()
             self.server.removeConn(self)
     def findHeader(self, head, header):
         aux = head.find(header + ': ')
         if aux == -1:
             return ''
         aux = head.find(':', aux)
         head = head[aux+2:]
         aux = head.find('\r\n')
         if aux == -1:
             return ''
         return head[:aux];
     def connect_target(self, host):
         i = host.find(':')
         if i != -1:
             port = int(host[i+1:])
             host = host[:i]
         else:
             if self.method=='CONNECT':
             	
                 port = 443
             else:
                 port = 80
                 port = 8080
                 port = 8799
                 port = 3128
         (soc_family, soc_type, proto, _, address) = socket.getaddrinfo(host, port)[0]
         self.target = socket.socket(soc_family, soc_type, proto)
         self.targetClosed = False
         self.target.connect(address)
     def method_CONNECT(self, path):
         self.log += ' - CONNECT ' + path
         self.connect_target(path)
         self.client.sendall(RESPONSE)
         self.client_buffer = ''
         self.server.printLog(self.log)
         self.doCONNECT()
     def doCONNECT(self):
         socs = [self.client, self.target]
         count = 0
         error = False
         while True:
             count += 1
             (recv, _, err) = select.select(socs, [], socs, 3)
             if err:
                 error = True
             if recv:
                 for in_ in recv:
 		    try:
                         data = in_.recv(BUFLEN)
                         if data:
 			    if in_ is self.target:
 				self.client.send(data)
                             else:
                                 while data:
                                     byte = self.target.send(data)
                                     data = data[byte:]
                             count = 0
 			else:
 			    break
 		    except:
                         error = True
                         break
             if count == TIMEOUT:
                 error = True
             if error:
                 break
 def main(host=LISTENING_ADDR, port=LISTENING_PORT):
     print "\n:-------PythonProxy-------:\n"
     print "Listening addr: " + LISTENING_ADDR
     print "Listening port: " + str(LISTENING_PORT) + "\n"
     print ":-------------------------:\n"
     server = Server(LISTENING_ADDR, LISTENING_PORT)
     server.start()
     while True:
         try:
             time.sleep(2)
         except KeyboardInterrupt:
             print 'Stopping...'
             server.close()
             break
 if __name__ == '__main__':
     main()
CPM
 ) > $HOME/proxy.log &
 
 chmod +x /etc/VPS-MX/protocolos/PDirect.py
 
 #screen -dmS pydic-"$porta_socket" python ${SCPinst}/PDirect.py "$porta_socket" "$texto_soket" && echo ""$porta_socket" "$texto_soket"" >> /etc/VPS-MX/PortPD.log
 
 	[[ -z $porta_socket ]] && conf="$porta_socket "
     [[ -z $texto_soket ]] && conf+="$texto_soket"
     
 echo -e "[Unit]
 Description=PDirect Service
 After=network.target
 StartLimitIntervalSec=0
 
 [Service]
 Type=simple
 User=root
 WorkingDirectory=/root
 ExecStart=/usr/bin/python ${SCPinst}/PDirect.py $conf
 Restart=always
 RestartSec=3s
 
 [Install]
 WantedBy=multi-user.target" > /etc/systemd/system/python.$porta_socket.service
 
     systemctl enable python.$porta_socket &>/dev/null
     systemctl start python.$porta_socket &>/dev/null
     systemctl restart python.$porta_socket &>/dev/null
     echo "$porta_socket" >/etc/VPS-MX/py.log
     echo ""$porta_socket" "$texto_soket"" >> /etc/VPS-MX/PortPD.log
     
 }
 
 
 
 
 pid_kill () {
 [[ -z $1 ]] && refurn 1
 pids="$@"
 for pid in $(echo $pids); do
 kill -9 $pid &>/dev/null
 done
 }
 selecionador(){
 clear
 echo ""
 echo ""
 echo ""
 	while true; do
 	msg -bar
 	echo -ne "\033[1;37m"
     read -p " ESCRIBE SU PUERTO: " porta_socket
 	echo -e ""
     [[ $(mportas|grep -w "$porta_socket") ]] || break
     echo -e " ESTE PUERTO YA ESTÁ EN USO"
     unset porta_socket
     done
 	echo -e "$(fun_trans  "Introdusca su Mini-Banner")"
 	msg -bar
 	echo -ne "Introduzca el texto de estado plano o en HTML:\n \033[1;37m" && read texto_soket
     msg -bar
 }
 remove_fun () {
 echo -e "Parando Socks Python"
 msg -bar
 pidproxy=$(ps x | grep "PPub.py" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy ]] && pid_kill $pidproxy
 pidproxy2=$(ps x | grep "PPriv.py" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy2 ]] && pid_kill $pidproxy2
 pidproxy3=$(ps x | grep "PDirect.py" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy3 ]] && pid_kill $pidproxy3
 pidproxy4=$(ps x | grep "POpen.py" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy4 ]] && pid_kill $pidproxy4
 pidproxy5=$(ps x | grep "PGet.py" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy5 ]] && pid_kill $pidproxy5
 pidproxy6=$(ps x | grep "scktcheck" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy6 ]] && pid_kill $pidproxy6
 pidproxy7=$(ps x | grep "python.py" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy7 ]] && pid_kill $pidproxy7
 pidproxy8=$(ps x | grep "lacasitamx.py" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy8 ]] && pid_kill $pidproxy8
 echo -e "\033[1;91mSocks DETENIDOS"
 msg -bar
 rm -rf /etc/VPS-MX/PortPD.log
 echo "" > /etc/VPS-MX/PortPD.log
 py=$(cat /etc/VPS-MX/py.log|cut -d'|' -f1)
 			systemctl stop python.${py} &>/dev/null
             systemctl disable python.${py} &>/dev/null
             rm /etc/systemd/system/python.${py}.service &>/dev/null
 exit 0
 }
 iniciarsocks () {
 pidproxy=$(ps x | grep -w "PPub.py" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy ]] && P1="\033[1;32m[ON]" || P1="\e[37m[\033[1;31mOFF\e[37m]"
 pidproxy2=$(ps x | grep -w  "PPriv.py" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy2 ]] && P2="\033[1;32m[ON]" || P2="\e[37m[\033[1;31mOFF\e[37m]"
 pidproxy3=$(ps x | grep -w  "PDirect.py" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy3 ]] && P3="\033[1;32m[ON]" || P3="\e[37m[\033[1;31mOFF\e[37m]"
 pidproxy4=$(ps x | grep -w  "POpen.py" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy4 ]] && P4="\033[1;32m[ON]" || P4="\e[37m[\033[1;31mOFF\e[37m]"
 pidproxy5=$(ps x | grep "PGet.py" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy5 ]] && P5="\033[1;32m[ON]" || P5="\e[37m[\033[1;31mOFF\e[37m]"
 pidproxy6=$(ps x | grep "scktcheck" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy6 ]] && P6="\033[1;32m[ON]" || P6="\e[37m[\033[1;31mOFF\e[37m]"
 msg -bar 
 msg -tit
 echo -e "   	\e[91m\e[43mINSTALADOR DE PROXY'S\e[0m "
 msg -bar
 echo -e " \e[1;93m[\e[92m1\e[93m] \e[97m$(msg -verm2 "➛ ")\033[1;97mProxy Python SIMPLE      $P1"
 echo -e " \e[1;93m[\e[92m2\e[93m] \e[97m$(msg -verm2 "➛ ")\033[1;97mProxy Python SEGURO      $P2"
 echo -e " \e[1;93m[\e[92m3\e[93m] \e[97m$(msg -verm2 "➛ ")\033[1;97mProxy Python DIRECTO     $P3"
 echo -e " \e[1;93m[\e[92m4\e[93m] \e[97m$(msg -verm2 "➛ ")\033[1;97mProxy Python OPENVPN     $P4"
 echo -e " \e[1;93m[\e[92m5\e[93m] \e[97m$(msg -verm2 "➛ ")\033[1;97mProxy Python GETTUNEL    $P5"
 echo -e " \e[1;93m[\e[92m6\e[93m] \e[97m$(msg -verm2 "➛ ")\033[1;97mProxy Python TCP BYPASS  $P6"
 echo -e " \e[1;93m[\e[92m7\e[93m] \e[97m$(msg -verm2 "➛ ")\033[1;97mDETENER SERVICIO PYTHON"
 msg -bar
 echo -e " \e[1;93m[\e[92m0\e[93m] \e[97m$(msg -verm2 "➛ ") \e[97m\033[1;41m VOLVER \033[1;37m"
 msg -bar
 IP=(meu_ip)
 while [[ -z $portproxy || $portproxy != @(0|[1-7]) ]]; do
 echo -ne " Digite Una Opcion: \033[1;37m" && read portproxy
 tput cuu1 && tput dl1
 done
  case $portproxy in
  	1)
  	selecionador
 	screen -dmS screen python ${SCPinst}/PPub.py "$porta_socket" "$texto_soket";;
     2)
     selecionador
 	screen -dmS screen python3 ${SCPinst}/PPriv.py "$porta_socket" "$texto_soket" "$IP";;
     3)PythonDic_fun;;
     4)
     selecionador
 	screen -dmS screen python ${SCPinst}/POpen.py "$porta_socket" "$texto_soket";;
     5)
     selecionador
 	gettunel_fun "$porta_socket";;
     6)
     selecionador
 	tcpbypass_fun "$porta_socket" "$texto_soket";;
     7)remove_fun;;
     0)return;;
      esac
 echo -e "\033[1;92m$(fun_trans "Procedimiento COMPLETO")"
 msg -bar
 }
 iniciarsocks
  