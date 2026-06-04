from math import gcd
def forcing_profile(M: int) -> dict:
    states = [s for s in range(M) if gcd(s, M) == 1]
    return {s: next(g for g in range(1, M+1) if gcd((s+g)%M, M)==1) for s in states}