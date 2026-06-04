from math import gcd
def is_admissible(M: int, s: int, g: int) -> bool:
    return gcd(s, M) == 1 and gcd((s + g) % M, M) == 1