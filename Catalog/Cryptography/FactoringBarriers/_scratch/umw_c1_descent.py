"""
Large-n probe.  Exhaustive is impossible, so use multi-start COORDINATE DESCENT on the
CRT objective  b(j) = sum_p j_p*d_p mod U,  j_p in [1, min(l,p)],  minimizing b.
Reference points:  trivial b = U-1 (log b = theta(n) ~ n);
                  density heuristic  log b ~ theta(n)/l ~ n^{1/3};
                  rigorous lower bound log b >= theta(n)/l.
If descent reaches b ~ e^{n^{1/3}} the c=1 construction is alive; if it stalls at
b ~ U^{c} with c near 1 the CRT-achievable set has no small elements and c=1 is dead.
"""
import math, random, time
from sympy import primerange

def descend(n, restarts=6, sweeps=40, seed=3):
    rng = random.Random(seed + n)
    primes = list(primerange(1, n+1))
    U = 1
    for p in primes: U *= p
    l = max(2, round(n ** (2/3)))
    caps = [min(l, p) for p in primes]
    d = [ (U//p) * pow(U//p, -1, p) * (p-1) for p in primes ]   # j*d = -j (mod p)
    lu = math.log(U); t0 = time.time()
    def val(j):
        b = 0
        for k in range(len(primes)): b += j[k]*d[k]
        return b % U
    best = U - 1
    order = list(range(len(primes)))
    for r in range(restarts):
        j = [1]*len(primes) if r == 0 else [rng.randint(1,c) for c in caps]
        cur = val(j)
        for _ in range(sweeps):
            rng.shuffle(order); moved = False
            for k in order:
                bj, bc = j[k], cur
                for v in range(1, caps[k]+1):
                    if v == j[k]: continue
                    cand = (cur - j[k]*d[k] + v*d[k]) % U
                    if cand < bc: bc, bj = cand, v
                if bj != j[k]: j[k] = bj; cur = bc; moved = True
            if not moved: break
        if cur < best: best = cur
    lb = math.log(best)
    ok = all(any((best+x) % p == 0 for x in range(1, min(l,p)+1)) for p in primes)
    print(f"n={n:5d} l={l:4d} pi={len(primes):4d} logU={lu:8.1f} | "
          f"log min b={lb:8.2f}  minb/U={math.exp(lb-lu):.4f}  "
          f"log minb/n={lb/n:.3f}  [rigorous floor logU/l={lu/l:7.2f}]  "
          f"[n^(1/3)={n**(1/3):6.1f}]  valid={ok}  ({time.time()-t0:.1f}s)", flush=True)
    return lb, lu, n

for n in [50, 100, 200, 400, 800, 1600, 3200]:
    descend(n)
