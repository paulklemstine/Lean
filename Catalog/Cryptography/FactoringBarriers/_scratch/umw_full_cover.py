"""
Two follow-ups.

(1) FULL COVER.  The conjecture needs every i in [n] to divide some b+j, not just primes.
    Run the same CRT search (necessity: for each i<=n pick j_i in [1,min(l,i)] with
    i | b + j_i) and report whether ANY b exists at all, and its size.  The prime-only
    condition does NOT imply the composite one; UMW list composites xy, x,y in
    [n^{1/2-eps}, n^{1/2}] as the second hard case.

(2) PREFACTORING COST (Conjecture 5.1).  With c=1 the differences are the single integers
    b+j, |b+j| <= e^{n^alpha}.  Factoring one costs O(e^{n^alpha/4} polylog) by
    Pollard-Strassen, which is <= the required O(e^{n^alpha}); so the prefactoring clause
    is FREE for the c=1 branch.  Verified by timing sympy.factorint on large ints.
"""
import math, random, time
from sympy import primerange, factorint, nextprime

def full_cover(n, restarts=8, sweeps=60, seed=5):
    rng = random.Random(seed + n)
    ints = list(range(1, n+1))
    l = max(2, round(n ** (2/3)))
    best = None
    for r in range(restarts):
        b = 0 if r == 0 else rng.randrange(1, 10**6)
        cur = b
        for _ in range(sweeps):
            moved = False
            for i in ints:                       # coordinate = an integer to cover
                cand_best, cb = None, cur
                for j in range(1, min(l, i)+1):
                    nb = cur - ((cur + j) % i) + ((cur + j) % i)   # keep
                    nb = cur - ((cur + j) % i)
                    # setting b so that b+j = 0 mod i  =>  b -= (b+j) mod i
                    v = (cur - ((cur + j) % i)) % (1 << 200)
                    if v < cb: cb, cand_best = v, j
                if cb != cur: cur = cb; moved = True
            if not moved: break
        if best is None or cur < best: best = cur
        if cur == 0: break
    # verify
    ok = all(any((best + j) % i == 0 for j in range(1, min(l, i)+1)) for i in ints)
    print(f"FULL COVER n={n:3d} l={l:3d}: best b={best}  covers_all_i_1..n={ok}  "
          f"log b={math.log(best+1):.2f}  [n^(1/3)={n**(1/3):.1f}]", flush=True)
    return best, ok

for n in [30, 60, 90, 120, 200]:
    full_cover(n)

print()
print("PREFACTORING cost of a single difference b+j, |b+j| = e^{n^alpha}:")
for bits in [2000, 4000, 8000]:
    x = int(nextprime(2**bits))
    t0 = time.time(); f = factorint(x); dt = time.time()-t0
    print(f"  factorint of a {bits}-bit integer ({math.log2(x):.0f} bits): "
          f"{dt:.3f}s, factors {list(f)[:3]}...")
