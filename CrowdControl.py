# Depends on StyxScribeShared, StyxScribeActive
import socket
import time
import threading
import json

__all__ = ["Load", "RequestEffect", "NotifyEffect", "Internal"]

Shared = None

effects = set()

def NotifyEffect(eid, result=None, timeRemaining=None):
    if result is None:
        result = "Success"
    if eid in effects:
        effects.remove(eid)
    print(f"CrowdControl: Responding with {result} for effect with ID {eid}")
    message = {"id":eid, "status":result}
    if timeRemaining is not None:
        message["timeRemaining"] = timeRemaining
    thread.socket.send(json.dumps(message).encode('utf-8')+b'\x00')

def RequestEffect(eid, effect):
    print(f"CrowdControl: Requesting effect {effect} with ID {eid}")
    effects.add(eid)
    sentTime = time.time() - Scribe.Modules.StyxScribeActive.Start
    return Shared.RequestEffect(eid, effect, sentTime)

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
            #print(f"CrowdControl: Attempting to connect on {self.host}:{self.port}")
            try:
                s = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
                s.connect((self.host,self.port))
                print(f"CrowdControl: Connected on {self.host}:{self.port}")
                self.socket = s
                while True:
                    message = s.recv(1042)
                    if not message:
                        continue
                    message = message.decode('utf-8').replace(u'\x00','')
                    message = json.loads(message)
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

    def onInactive():
        for e in tuple(effects):
            NotifyEffect(e,"Retry")
        effects.clear()

    Scribe.AddHook(initShared, "StyxScribeShared: Reset", __name__)
    Scribe.Modules.StyxScribeActive.OnInactive(onInactive)
