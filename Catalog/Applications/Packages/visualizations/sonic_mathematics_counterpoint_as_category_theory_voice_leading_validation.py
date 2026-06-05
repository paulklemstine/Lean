def is_transition_allowed(i: int, j: int) -> bool:
    CONS = {0,3,4,7,8,9}; IMP = {3,4,8,9}
    i,j = i%12, j%12
    return i in CONS and j in CONS and (i != j or i in IMP)