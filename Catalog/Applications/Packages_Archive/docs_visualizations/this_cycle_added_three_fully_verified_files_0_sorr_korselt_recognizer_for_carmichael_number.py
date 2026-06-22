from typing import Dict

def is_prime(n: int) -> bool:
    if n < 2: return False
    d = 2
    while d*d <= n:
        if n % d == 0: return False
        d += 1
    return True

def factorize(n: int) -> Dict[int, int]:
    f: Dict[int, int] = {}; m, d = n, 2
    while d*d <= m:
        while m % d == 0: f[d] = f.get(d,0)+1; m//=d
        d += 1
    if m > 1: f[m] = f.get(m,0)+1
    return f

def is_carmichael(n: int) -> bool:
    if n < 3 or is_prime(n): return False
    f = factorize(n)
    if any(e > 1 for e in f.values()): return False  # squarefree
    return all((n-1) % (p-1) == 0 for p in f)        # Korselt clauses
