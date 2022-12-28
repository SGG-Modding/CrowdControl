# Depends on StyxScribeShared

__all__ = ["Load", "RequestEffect", "NotifyEffect"]
Internal = {}

Shared = None

def NotifyEffect(eid, result):
    # handle the response here
    print(f"Python got response {result} for event with ID {eid}")

def RequestEffect(eid, effect):
    return Shared.RequestEffect(eid, effect)

def Load():

    def initShared(message):
        global Shared
        root = scribe.modules.StyxScribeShared.Root
        Shared = root.CrowdControlHadesDraft
        if not Shared:
            root.CrowdControlHadesDraft = {}
            Shared = root.CrowdControlHadesDraft
        Shared.NotifyEffect = NotifyEffect

    Internal["initShared"] = initShared

    Scribe.AddHook(initShared, "StyxScribeShared: Reset", __name__)
