"""
GROUND TRUTH (itertools.product, obviously correct, every b verified to cover all primes).
Exact minimum b such that every prime p<=n divides some b+j, 1<=j<=min(l,p), l = n^{2/3}.
Compare against (i) the RIGOROUS floor  b >= U^{1/l} - l  (U = prod_{p<=n} p is squarefree and
U | prod_{j<=l}(b+j) <= (b+l)^l) and (ii) the CONJECTURE TARGET b <= exp(n^alpha), alpha=1/3.
"""
import math, itertools
from sympy import primerange

print(f"{'n':>3} {'l':>3} {'#enum':>10} {'logU':>7} {'log floor':>10} {'log target':>11} "
      f"{'log minb':>9} {'min b':>8} {'minb/target':>11} {'verified':>8}")
for n in [8, 10, 12, 14, 16, 18, 20, 22]:
    l = max(2, round(n ** (2/3)))
    primes = list(primerange(1, n+1))
    U = 1
    for p in primes: U *= p
    d = [(U//p) * pow(U//p, -1, p) * (p-1) for p in primes]
    caps = [min(l, p) for p in primes]
    best, tot = U, 0
    for combo in itertools.product(*[range(1, c+1) for c in caps]):
        b = 0
        for k, v in enumerate(combo): b += v * d[k]
        b %= U; tot += 1
        if b < best: best = b
    ok = all(any((best+j) % p == 0 for j in range(1, min(l,p)+1)) for p in primes)
    floor = math.log(U)/l
    tgt = n ** (1/3)
    print(f"{n:>3} {l:>3} {tot:>10} {math.log(U):>7.2f} {floor:>10.2f} {tgt:>11.2f} "
          f"{math.log(best):>9.2f} {best:>8} {math.exp(math.log(best)-tgt):>11.1f} {str(ok):>8}",
          flush=True)
print()
print("Read: the rigorous floor log b >= log(U)/l = n/l = n^{1/3} EQUALS the conjecture")
print("target log b <= n^{1/3} at (alpha,beta)=(1/3,1/3).  Zero slack: c=1 is all-or-nothing.")
print("Measured exact minima sit within a factor exp(1..2.5) of that razor edge at n<=22,")
print("i.e. the c=1 branch is NOT refuted at small n, and is exactly as tight as predicted.")
