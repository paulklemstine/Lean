import math
def orbit_complexity(n: int) -> tuple:
    orbit = collatz_orbit(n)
    st = len(orbit) - 1
    pk = max(orbit)
    exc = pk / n if n > 0 else 0
    score = st * math.log2(exc + 1) if st > 0 else 0
    return (st, pk, exc, score)