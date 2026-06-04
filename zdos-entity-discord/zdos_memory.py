class ZDOSMemory:
    def __init__(self):
        self.last_block = None
        self.last_locks = None
        self.last_errors = []

MEM = ZDOSMemory()
