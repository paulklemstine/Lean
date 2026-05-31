def lattice_count(R: float) -> int:
    import math
    cosh_R = math.cosh(R)
    bound = int(math.ceil(math.sqrt(2*cosh_R))) + 2
    count = 0
    for a in range(-bound, bound+1):
        for d in range(-bound, bound+1):
            for b in range(-bound, bound+1):
                bc = a*d - 1
                if b == 0:
                    if bc == 0 and (a*d - 0) == 1:
                        if (a**2 + d**2) / 2.0 <= cosh_R:
                            count += 1
                    continue
                if bc % b != 0: continue
                c = bc // b
                if (a**2+b**2+c**2+d**2)/2.0 <= cosh_R:
                    count += 1
    return count