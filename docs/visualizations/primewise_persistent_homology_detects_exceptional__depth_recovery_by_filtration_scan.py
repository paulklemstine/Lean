def depthRecoveryAux(f, fuel, start):
    if fuel == 0:
        return start
    if f(start) > 0:
        return start
    return depthRecoveryAux(f, fuel - 1, start + 1)