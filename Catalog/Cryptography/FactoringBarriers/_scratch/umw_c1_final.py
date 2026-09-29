"""
Ground truth: assert that EVERY enumerated b covers all primes.  Two carry variants are
tested; only the correct one passes.  itertools.product cross-checks on a small n.
"""
import math, itertools
from sympy import primerange

def build(n, l):
    primes = list(primerange(1, n+1))
    U = 1
    for p in primes: U *= p
    caps = [min(l, p) for p in primes]
    d = [(U//p) * pow(U//p, -1, p) * (p-1) for p in primes]
    return primes, U, caps, d

def covers(b, primes, l):
    return all(any((b+j) % p == 0 for j in range(1, min(l, p)+1)) for p in primes)

def enum_carry(n, l, mode):
    """mode 'A': b -= caps[k]*d[k]   mode 'B': b -= (caps[k]+1)*d[k]"""
    primes, U, caps, d = build(n, l)
    m = len(primes); idx = [1]*m; b = sum(d) % U
    total = 1
    for c in caps: total *= c
    best, cnt, bad = U, 0, 0
    while True:
        cnt += 1
        if not covers(b, primes, l): bad += 1
        if b < best: best = b
        k = 0
        while k < m:
            idx[k] += 1; b += d[k]
            if b >= U: b -= U
            if idx[k] <= caps[k]: break
            b = (b - (caps[k] if mode == 'A' else caps[k]+1)*d[k]) % U
            idx[k] = 1
            k += 1
        if k == m: break
    return best, cnt, total, bad

def enum_product(n, l):
    """obviously-correct reference"""
    primes, U, caps, d = build(n, l)
    best = U
    for combo in itertools.product(*[range(1, c+1) for c in caps]):
        b = 0
        for k, v in enumerate(combo): b += v * d[k]
        b %= U
        if b < best: best = b
    return best

# small-n cross check of the three methods
print("cross-check (product reference vs carry variants), n<=14:")
for n in [8, 10, 12, 14]:
    l = max(2, round(n ** (2/3)))
    ref = enum_product(n, l)
    A = enum_carry(n, l, 'A'); B = enum_carry(n, l, 'B')
    print(f"  n={n:3d} l={l:2d} product_min={ref:5d} | A: min={A[0]:5d} cnt={A[1]}/{A[2]} "
          f"noncovering={A[3]} | B: min={B[0]:5d} cnt={B[1]}/{B[2]} noncovering={B[3]}")

print()
print("VERIFIED exact minima (carry mode A, every value asserted prime-covering):")
print(f"{'n':>3} {'l':>3} {'#enum':>12} {'logU':>7} {'min b':>8} {'log minb':>9} "
      f"{'log minb/n':>11} {'verified':>8}")
for n in [16, 18, 20, 22, 24, 26, 28, 30, 32, 34, 36]:
    l = max(2, round(n ** (2/3)))
    best, cnt, total, bad = enum_carry(n, l, 'A')
    primes, U, caps, d = build(n, l)
    print(f"{n:>3} {l:>3} {cnt:>12} {math.log(U):>7.2f} {best:>8} {math.log(best):>9.2f} "
          f"{math.log(best)/n:>11.3f} {str(bad==0):>8}", flush=True)
