def consonance_automorphisms():
    from math import gcd
    S = {0,3,4,7,8,9}
    return [k for k in range(12) if gcd(k,12)==1 and all((k*c)%12 in S for c in S)]