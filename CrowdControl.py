# Depends on StyxScribeShared, StyxScribeActive
import socket
import time
import threading
import json

__all__ = ["Load", "RequestEffect", "NotifyEffect", "Internal"]

Shared = None

effects = set()
timed = set()
paused = set()

def NotifyEffect(eid, status=None, timeRemaining=None):
    if status is None:
        status = "Success"
    if eid in effects:
        effects.remove(eid)
            
    message = {"id":eid, "status":status}
    
    if timeRemaining is None:
        print(f"CrowdControl: Responding with {status} for effect with ID {eid}")
    else:
        print(f"CrowdControl: Responding with {status} with {timeRemaining} seconds remaining for effect with ID {eid}")
        if eid not in timed:
            timed.add(eid)
        message["timeRemaining"] = timeRemaining
        
    if status == "Finished":
        if eid in timed:
            timed.remove(eid)
        if eid in paused:
            paused.remove(eid)
    elif status == "Paused":
        if eid not in timed:
            timed.add(eid)
        if eid not in paused:
            paused.add(eid)
    try:
        thread.socket.send(json.dumps(message).encode('utf-8')+b'\x00')
    except ConnectionAbortedError:
        pass

def RequestEffect(eid, effect, *args):
    print(f"CrowdControl: Requesting effect {effect} with ID {eid}")
    if not Scribe.LuaActive:
        return NotifyEffect(eid,"Retry")
    effects.add(eid)
    try:
        return Shared.RequestEffect(eid, effect, *args)
    except KeyError:
        pass

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
            except ConnectionAbortedError:
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
        es = tuple(effects)
        effects.clear()
        for e in es:
            NotifyEffect(e,"Retry")
            Scribe.Send("CrowdControl: Cancel: " + str(e))
        for e in tuple(e for e in timed if e not in paused):
            NotifyEffect(e,"Paused")

    Scribe.AddHook(initShared, "StyxScribeShared: Reset", __name__)
    Scribe.AddOnLuaInactive(onInactive)
