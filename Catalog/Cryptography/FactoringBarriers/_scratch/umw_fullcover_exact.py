"""
FULL COVER, done exactly.  Every achievable b (for covering all PRIMES) is enumerated;
each is then tested for covering ALL i in [n].  The full-cover set is a SUBSET of the
prime-achievable set (an integer b is determined mod U by its residues mod p), so this is
a complete search for the c=1 full cover at these n.

Also: the number of prime-achievable residues is exactly prod_p min(l,p) ~ e^{(2/3)n},
so density = e^{-n/3} and the INDEPENDENCE heuristic puts the first one at e^{n/3}, which
already MISSES the required e^{n^{1/3}} by a factor e^{n/3 - n^{1/3}} -- the c=1 branch is
predicted dead before any computation.  The full-cover density is smaller still.
"""
import math
from sympy import primerange

for n in [12, 14, 16, 18, 20, 22, 24, 26, 28]:
    primes = list(primerange(1, n+1))
    U = 1
    for p in primes: U *= p
    l = max(2, round(n ** (2/3)))
    caps = [min(l, p) for p in primes]
    d = [(U//p) * pow(U//p, -1, p) * (p-1) for p in primes]   # j*d = -j (mod p)
    total = 1
    for c in caps: total *= c
    m = len(primes)
    idx = [1]*m; b = 0
    for k in range(m): b += d[k]
    b %= U
    best_pri, best_full, cnt = b, None, 0
    while True:
        cnt += 1
        if b < best_pri: best_pri = b
        if best_full is None and all(any((b+j) % i == 0 for j in range(1, min(l,i)+1))
                                     for i in range(1, n+1)):
            best_full = b
        k = 0
        while k < m:
            idx[k] += 1; b += d[k]
            if b >= U: b -= U
            if idx[k] <= caps[k]: break
            b = (b - caps[k]*d[k]) % U
            k += 1
        if k == m: break
        if best_full is not None and best_full == 0: break
    lu = U.bit_length()*math.log(2)
    print(f"n={n:3d} l={l:2d} #achievable={total:9.0f} (enumerated {cnt:9.0f}) |U|=e^{lu:6.1f} | "
          f"min b (primes) = e^{math.log(best_pri):6.2f}  ratio/U={math.exp(math.log(best_pri)-lu):.3f} | "
          f"FULL cover min b = {('e^'+str(round(math.log(best_full),2))) if best_full else 'NONE up to enumeration'}"
          f"  [target e^(n/3)=e^{n/3:.1f}, floor e^(n^(1/3))=e^{n**(1/3):.1f}]", flush=True)
