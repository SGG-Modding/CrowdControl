# Depends on StyxScribeShared, StyxScribeActive
import socket
import time
import threading
import json

__all__ = ["Load", "RequestEffect", "NotifyEffect", "Internal"]

Shared = None
thread = None

TIMEOUT = 15
REMOTE = 208

effects = set()
timed = set()
paused = set()
last_put = 0
last_get = 0
receivers = dict()

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
        if thread.socket:
            thread.socket.send(json.dumps(message).encode('utf-8')+b'\x00')
    except ConnectionAbortedError:
        pass

def RequestEffect(eid, effect, *args):
    if args:
        print(f"CrowdControl: Requesting effect {effect}({', '.join(args)}) with ID {eid}")
    else:
        print(f"CrowdControl: Requesting effect {effect} with ID {eid}")
    if not Scribe.LuaActive and time.time() - Scribe.LastLuaInactiveTime > TIMEOUT:
        return NotifyEffect(eid,"Retry")
    effects.add(eid)
    try:
        return Shared.RequestEffect(eid, effect, *args)
    except KeyError:
        pass

def SendRemoteFunction(cid, method, *args):
    global last_put
    last_put = last_put + 1
    receivers[last_put] = cid
    cid = last_put
    
    message = {"id":cid, "type":208, "method":method}
    if args:
        message["args"] = args

    if args:
        print(f"CrowdControl: Sending remote {method}({', '.join(args)}) with ID {cid}")
    else:
        print(f"CrowdControl: Sending remote {method} with ID {cid}")
    
    try:
        if thread.socket:
            thread.socket.send(json.dumps(message).encode('utf-8')+b'\x00')
    except ConnectionAbortedError:
        pass

def ReceiveRemoteFunction(*args):
    # assume the order of reception is the order of sending
    # this is very risky...
    global last_get
    last_get = last_get + 1
    if last_get not in receivers:
        raise RuntimeError("Remote function messsages are out of sync!")
    cid = receivers[last_get]
    del receivers[last_get]
    
    if args:
        print(f"CrowdControl: Received result ({', '.join(args)}) with ID {cid}")
    else:
        print(f"CrowdControl: Received result with ID {cid}")

    try:
        return Shared.ReceiveRemoteFunction(cid, *args)
    except KeyError:
        pass

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
            do_reset = False
            try:
                s = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
                s.connect((self.host,self.port))
                print(f"CrowdControl: Connected on {self.host}:{self.port}")
                do_reset = True
                self.socket = s
                buffer = ''
                while True:
                    chunk = s.recv(1024)
                    if not chunk:
                        continue
                    buffer += chunk.decode('utf-8')
                    atoms = buffer.split(u'\x00')
                    if len(atoms) > 1:
                        buffer = atoms.pop()
                        for atom in atoms:
                            message = json.loads(atom)
                            eid = message["id"]
                            if Shared is None:
                                print(f"CrowdControl: Need to be loaded into a save to run effects!")
                                NotifyEffect(eid, "NotReady")
                                continue
                            if message.get("type",None) == REMOTE:
                                value = message.get("value",None)
                                ReceiveRemoteFunction(value)
                                continue
                            effect = message["code"]
                            duration = message.get("duration",None)
                            parameters = message.get("parameters",None)
                            if duration:
                                duration /= 1000
                            if duration and parameters:
                                RequestEffect(eid, effect, duration, *parameters)
                            elif parameters:
                                RequestEffect(eid, effect, *parameters)
                            elif duration:
                                RequestEffect(eid, effect, duration)
                            else:
                                RequestEffect(eid, effect)
            except ConnectionResetError:
                pass
            except ConnectionRefusedError:
                time.sleep(5)
                pass
            except ConnectionAbortedError:
                pass
            finally:
                if do_reset and Shared is not None:
                    Scribe.Send("CrowdControl: Reset")
                    do_reset = False
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
        Shared.SendRemoteFunction = SendRemoteFunction

    def onInactive():
        for e in tuple(e for e in timed if e not in paused):
            NotifyEffect(e,"Paused")

    def onInactiveDelayed():
        es = tuple(effects)
        effects.clear()
        for e in es:
            NotifyEffect(e,"Retry")
            Scribe.Send("CrowdControl: Cancel: " + str(e))

    def onInactive():
        for e in tuple(e for e in timed if e not in paused):
            NotifyEffect(e,"Paused")

    Scribe.AddHook(initShared, "StyxScribeShared: Reset", __name__)
    Scribe.AddOnLuaInactive(onInactive)
    Scribe.AddOnLuaInactive(onInactiveDelayed, TIMEOUT)
