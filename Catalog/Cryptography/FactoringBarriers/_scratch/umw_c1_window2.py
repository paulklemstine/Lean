"""
CORRECTED.  b achievable (c=1)  <=>  for every prime p<=n there is j in [1, min(l,p)]
with p | b + j, i.e.  b = -j_p (mod p) with j_p chosen freely in [1, min(l,p)].
CRT => number of achievable residues mod U is  N(n,l) = prod_p min(l,p) = l^{pi(n)-pi(l)} * prod_{p<=l} p.
Equivalently Lemma 6.2: pick the factorization, b = -W mod U, W = i mod U_i  => b = -i mod U_i.
EXHAUSTIVE search for the true minimum b.  Target: b <= exp(n/3) (alpha=beta=1/3, the
CRITICAL value alpha = 1-2beta that UMW Sec.6 explicitly says they cannot rule out).
"""
import math, time, random
from sympy import primerange

def crt_deltas(primes, U):
    d = []
    for p in primes:
        t = U // p
        d.append(t * pow(t, -1, p) * (p - 1))   # so that j*d ≡ -j (mod p)
    return d

def run(n, budget=2.5e7):
    primes = list(primerange(1, n+1))
    U = 1
    for p in primes: U *= p
    l = max(2, round(n ** (2/3)))
    m = len(primes)
    caps = [min(l, p) for p in primes]           # j_p in [1, caps]
    total = 1
    for c in caps: total *= c
    d = crt_deltas(primes, U)
    best, best_j, cnt = U, None, 0
    t0 = time.time()
    if total <= budget:
        mode = "EXHAUSTIVE"
        idx = [1]*m
        b = 0
        for k in range(m): b += d[k]
        b %= U
        if b < best: best, best_j = b, list(idx)
        while True:
            k = 0
            while k < m:
                idx[k] += 1
                b += d[k]
                if b >= U: b -= U
                if idx[k] <= caps[k]: break
                b = (b - caps[k]*d[k]) % U
                k += 1
            if k == m: break
            cnt += 1
            if b < best: best, best_j = b, list(idx)
        cnt = total
    else:
        mode = "RANDOM(3e6)"
        rng = random.Random(11+n)
        for _ in range(3_000_000):
            idx = [rng.randint(1, c) for c in caps]
            b = 0
            for k in range(m): b += idx[k]*d[k]
            b %= U
            if b < best: best, best_j = b, list(idx)
    theta = U.bit_length()*math.log(2)
    dens = math.log(U) - math.log(total)
    lb = math.log(best) if best > 0 else 0.0
    valid = all(any((best+j) % p == 0 for j in range(1, min(l,p)+1)) for p in primes)
    hit = best <= math.exp(n/3)
    print(f"n={n:3d} l={l:2d} pi={m:2d} |U|=e^{theta:6.1f} #achievable={total:.2e} "
          f"[log(U/#)={dens:7.2f} vs n/3={n/3:6.2f}] {mode:13s} "
          f"min b = e^{lb:8.2f}  {'HIT ' if hit else 'MISS'} valid={valid}  ({time.time()-t0:.1f}s)",
          flush=True)
    return best

for n in [12, 14, 16, 18, 20, 21, 22, 24, 26, 28, 30, 32, 36, 40]:
    run(n)
