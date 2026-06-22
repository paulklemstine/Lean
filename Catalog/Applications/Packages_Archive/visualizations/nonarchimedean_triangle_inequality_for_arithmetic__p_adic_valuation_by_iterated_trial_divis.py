from fractions import Fraction

def padic_val_int(p: int, n: int) -> float:
    if n == 0:
        return float('inf')
    n, k = abs(n), 0
    while n % p == 0:
        n //= p
        k += 1
    return k

def padic_val_rat(p: int, x: Fraction) -> float:
    if x == 0:
        return float('inf')
    return padic_val_int(p, x.numerator) - padic_val_int(p, x.denominator)
