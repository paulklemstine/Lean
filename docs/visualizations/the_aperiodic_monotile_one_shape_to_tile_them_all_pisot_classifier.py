import math
def is_pisot(tr: int, det: int) -> bool:
    disc = tr*tr - 4*det
    if disc < 0: return False
    sd = math.sqrt(disc)
    return (tr + sd)/2 > 1 and abs((tr - sd)/2) < 1