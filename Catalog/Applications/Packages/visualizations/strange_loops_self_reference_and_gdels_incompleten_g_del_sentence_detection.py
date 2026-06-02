def detect_goedel(system):
    for s in range(system.n):
        if s not in system.provable and system.neg(s) not in system.provable:
            return s
    return None