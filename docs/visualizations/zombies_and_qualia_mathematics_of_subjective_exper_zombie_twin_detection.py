def find_zombie_twin(system, x):
    if not system.has_qualia(x):
        return None
    for y in system.states:
        if system.func_equiv(x, y) and not system.has_qualia(y):
            return y
    return None