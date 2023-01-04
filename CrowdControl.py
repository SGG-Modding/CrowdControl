# Depends on StyxScribeShared
import socket
import time
import threading
import json

__all__ = ["Load", "RequestEffect", "NotifyEffect", "Internal"]
Internal = {}

Shared = None

def NotifyEffect(eid, result=None):
    if result is None:
        result = "Success"
    print(f"CrowdControl: Responding with {result} for effect with ID {eid}")
    thread.socket.send(json.dumps({"id":eid, "status":result}).encode('utf-8')+b'\x00')

def RequestEffect(eid, effect):
    print(f"CrowdControl: Requesting effect {effect} with ID {eid}")
    return Shared.RequestEffect(eid, effect)

thread = None
class AppSocketThread(threading.Thread):
    #repurposed from:
    # - https://stackoverflow.com/questions/27284358/connect-to-socket-on-localhost
    # - https://stackoverflow.com/questions/51677868/parse-json-message-from-socket-using-python
    host = "127.0.0.1"
    port = 58430
    socket = None

    def __init__(self, name='cc-app-socket-thread'):
        global thread
        super(self.__class__, self).__init__(name=name)
        thread = self
        self.start()

    def run(self):
        print("CrowdControl: Socket Thread Running!")
        while True:
            print(f"CrowdControl: Attempting to connect on {self.host}:{self.port}")
            try:
                s = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
                s.connect((self.host,self.port))
                print(f"CrowdControl: Connected on {self.host}:{self.port}")
                self.socket = s
                while True:
                    message = s.recv(1042)
                    if not message:
                        continue
                    message = message.decode('utf-8')
                    message = json.loads(message[:-1])
                    eid = message["id"]
                    if Shared is None:
                        print(f"CrowdControl: Need to be loaded into a save to run effects!")
                        NotifyEffect(eid, "NotReady")
                        continue
                    effect = message["code"]
                    RequestEffect(eid, effect)
            except ConnectionResetError:
                time.sleep(15)
                continue
            except ConnectionRefusedError:
                time.sleep(5)
                continue

def Load():
    #start the app socket thread
    Scribe.AddOnRun(AppSocketThread, __name__)

    def initShared(message):
        global Shared
        root = scribe.modules.StyxScribeShared.Root
        Shared = root.CrowdControl
        if not Shared:
            root.CrowdControl = {}
            Shared = root.CrowdControl
        Shared.NotifyEffect = NotifyEffect

    Internal["initShared"] = initShared

    Scribe.AddHook(initShared, "StyxScribeShared: Reset", __name__)
