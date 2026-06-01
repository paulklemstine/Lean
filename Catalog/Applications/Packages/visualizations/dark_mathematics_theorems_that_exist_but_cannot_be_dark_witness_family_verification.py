def verify_dark(witnesses, level):
    for w, wset in witnesses.items():
        if len(wset) < level: return False, f'World {w} insufficient'
    for n in set.union(*witnesses.values()):
        if all(n in wset for wset in witnesses.values()): return False, f'{n} is universal'
    return True, None