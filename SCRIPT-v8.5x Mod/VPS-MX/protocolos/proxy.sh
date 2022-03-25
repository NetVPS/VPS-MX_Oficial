#!/bin/bash
 clear
 
 SCPinst="/etc/VPS-MX/protocolos"
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
 BARRA="\e[0;31m=====================================================\e[0m"
 
 pid_kill () {
 	[[ -z $1 ]] && refurn 1
 	pids="$@"
 	for pid in $(echo $pids); do
 		kill -9 $pid &>/dev/null
 	done
  }
 
 det_py(){
 	pidproxy3=$(ps x | grep "lacasitamx.py" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy3 ]] && pid_kill $pidproxy3
 	echo -e "\033[1;91m  SOCKS DETENIDO"
 	rm /etc/VPS-MX/PortPD.log &>/dev/null
 	rm -rf /etc/VPS-MX/protocolos/lacasitamx.py
 	
 	}
 
 
 pytho_py(){
 clear
 echo ""
 if [[ ! -e /etc/VPS-MX/fix ]]; then
 		echo ""
 ins(){
 apt-get install python -y 
 apt-get install python-pip -y
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
 echo -e "$BARRA"
 echo -e "\033[1;31m  HTTP | PYTHON | CUSTOM\033[0m"
 echo -e "$BARRA"
 #puerto a usar para proxy python
 while true; do
 	echo -ne "\033[1;37m"
     read -p " ESCRIBE SU PUERTO: " proxycolor
 	echo -e ""
     [[ $(mportas|grep -w "$proxycolor") ]] || break
     echo -e " ESTE PUERTO YA ESTÁ EN USO"
     unset proxycolor
     done
     #puerto local
    echo -e "$BARRA" 
     while true; do
  		
          echo -ne "\033[1;36m"
          read -p " Introduzca El puerto Local (22|443|80): " PORTLOC
 		 echo ""
          if [[ ! -z $PORTLOC ]]; then
              if [[ $(echo $PORTLOC|grep [0-9]) ]]; then
                 [[ $(mportas|grep $PORTLOC|head -1) ]] && break || echo -e "ESTE PUERTO NO EXISTE"
              fi
          fi
          done
  #        
 portlocal="$(mportas|grep $PORTLOC|awk '{print $2}'|head -1)"
 echo -e "$BARRA"
 read -p " Escribe el HTTP Response? (101|200|300): " encabezad
 tput cuu1 && tput dl1
      if [[ -z $encabezad ]]; then
         encabezad="200"
         echo -e "	\e[31mResponse Default:\033[1;32m ${encabezad}"
     else
         echo -e "	\e[31mResponse Elegido:\033[1;32m ${encabezad}"
     fi
 echo -e "$BARRA"
 echo -ne " Introduzca un texto para el status en HTML:\n \033[1;37m" && read mensage
 tput cuu1 && tput dl1
      if [[ -z $mensage ]]; then
         mensage="@lacasitamx"
         echo -e "	\e[31mMensage Default: \033[1;32m${mensage} "
     else
         echo -e "	\e[31mMensage: \033[1;32m ${mensage}"
     fi
     echo -e "$BARRA"
     [[ ! -e /etc/VPS-MX/protocolos/lacasitamx.py ]] && rm -rf /etc/VPS-MX/protocolos/lacasitamx.py
 #
 	# Inicializando o Proxy
 	(
 	less << CPM > /etc/VPS-MX/protocolos/lacasitamx.py
 # -*- coding: utf-8 -*-
 import socket, threading, thread, select, signal, sys, time, getopt
 LISTENING_ADDR = '0.0.0.0'
 LISTENING_PORT = int("$proxycolor")
 PASS = ''
 BUFLEN = 4096 * 4
 TIMEOUT = 60
 DEFAULT_HOST = '127.0.0.1:$portlocal'
 msg = "HTTP/1.1 $encabezad $mensage\r\n\r\nHTTP/1.1 $encabezad !!!conexion exitosa!!!\r\n\r\n"
 RESPONSE = str(msg)
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
 
 chmod +x /etc/VPS-MX/protocolos/lacasitamx.py &>/dev/nulll
 
 screen -dmS pydic-"$proxycolor" python ${SCPinst}/lacasitamx.py "$proxycolor" "$mensage" && echo ""$proxycolor" "$mensage"" >> /etc/VPS-MX/PortPD.log
 }
 
 clear
 echo -e "$BARRA"
 msg -tit
 echo -e "$BARRA"
 pidproxy=$(ps x | grep -w  "lacasitamx.py" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy ]] && plox="\e[1;32m[ON]" || plox="\e[1;31m[OFF]"
 #
 echo -e "\e[1;33m [1] \e[1;31m > \e[1;36mHTTP | PYTHON | CUSTOM $plox\e[0m"
 echo -e "\e[1;33m [2] \e[1;31m > \e[1;31mDESINSTALAR RECURSO\e[0m"
 echo -e "\e[1;33m [0] \e[1;31m > \e[1;37mVOLVER\e[0m"
 echo -e "$BARRA"
 read -p "SELECIONE UNA OPCION : " pix
 case $pix in
 0) ;;
 1) pytho_py ;;
 2) det_py ;;
 esac
 # 