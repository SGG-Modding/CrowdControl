# Depends on StyxScribeShared

__all__ = ["Load"]

_shared = None

def _triggerEffect(eid, result):
    # handle the response here
    print(f"Python got response {result} for event with ID {eid}")

def _queueEffect(eid, effect):
    return _shared.QueueEffect(eid, effect)

def _initShared(message):
    global _shared
    root = scribe.modules.StyxScribeShared.Root
    _shared = root.CrowdControlHadesDraft
    if not _shared:
        root.CrowdControlHadesDraft = {}
        _shared = root.CrowdControlHadesDraft
    _shared.TriggerEffect = _triggerEffect

def Load():
    Scribe.AddHook(_initShared, "StyxScribeShared: Reset", __name__)
