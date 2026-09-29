"""
EXACT characterisation, no block bookkeeping needed.

Lemma 6.2 says: A = {b + i*c} covers all primes <= n  <=>  there is a factorization
U=U_1..U_l with c*W + b = 0 (mod U), W = sum_i i*V_i, V_i = (U/U_i)T_i, V_i = 1 (mod U_i).
Taking c=1, b = (-W) mod U gives  b = -i (mod U_i) for the i-th block, hence

   b is ACHIEVABLE  <=>  for every prime p <= n:  p | b + j  for some j in [1, l]
   <=>  b mod p  in  {0, p-1, ..., p-l}          (i.e. -b mod p in [1,l], p in [1,l])

i.e. b <= exp(n^alpha) with c=1 means: the interval (b, b+l] contains a multiple of
EVERY prime p <= n.  This is EXACTLY the open case UMW names (Sec.6 p.19):
   "we cannot rule out the possibility that the Arithmetic Progression Version may
    hold with b <= exp(O(n^{1-2beta})) and c = 1!"
At alpha=beta=1/3 that is b <= exp(n/3) -- the CRITICAL value, since alpha >= 1-2beta.

Number of achievable b mod U is exactly l^{pi(n)} (CRT, independent j_p in [1,l]).
So the DENSITY-HEURISTIC first solution is  U / l^{pi(n)} = e^{theta(n)}/e^{2n/3} = e^{n/3}.
The experiment asks whether equidistribution actually holds in this ultra-sparse regime.
"""
import math, time
from sympy import primerange

def solve(n, exhaustive_limit=2.5e7):
    primes = list(primerange(1, n+1))
    U = 1
    for p in primes: U *= p
    l = max(2, round(n ** (2/3)))
    m = len(primes)
    total = l ** m
    # CRT deltas: b = sum_j j_k * d_k mod U, d_k = (U/p_k) * inv(U/p_k mod p_k)
    d = []
    for p in primes:
        t = U // p
        d.append(t * pow(t, -1, p))
    best, best_j = U, None
    t0 = time.time()
    if total <= exhaustive_limit:
        # flat mixed-radix enumeration with incremental CRT
        idx = [1] * m
        b = 0
        for k in range(m):
            b += d[k]          # j_k = 1
        if b >= U: b -= U
        if b < best: best, best_j = b, list(idx)
        while True:
            k = 0
            while k < m:
                idx[k] += 1
                b += d[k]
                if b >= U: b -= U
                if idx[k] <= l: break
                b -= l * d[k]                      # wrap around
                if b < 0:
                    b += (l // U + 1) * U
                    b %= U
                k += 1
            if k == m: break
            if b < best: best, best_j = b, list(idx)
        mode = "EXHAUSTIVE"
    else:
        import random
        rng = random.Random(7 + n)
        mode = "RANDOM(2e6)"
        for _ in range(2_000_000):
            idx = [rng.randint(1, l) for _ in range(m)]
            b = 0
            for k in range(m): b += idx[k] * d[k]
            b %= U
            if b < best: best, best_j = b, list(idx)
    theta = U.bit_length() * math.log(2)
    dens = U / total
    target = math.exp(n/3)
    ok = all(any((best + j) % p == 0 for j in range(1, l+1)) for p in primes)
    print(f"n={n:3d} l={l:2d} pi={m:2d} |U|=e^{theta:6.1f} #achievable={total:.2e} "
          f"[U/#=e^{math.log(dens) if dens>0 else 0:6.2f}] target e^(n/3)={math.log(target):6.2f} | "
          f"{mode:14s} min b = e^{math.log(best) if best>0 else 0:7.2f}  "
          f"{'HIT' if best<=target else 'MISS'}  valid={ok}  ({time.time()-t0:.1f}s)", flush=True)
    return best, target

for n in [14, 16, 18, 20, 21, 22, 24, 26, 28, 30, 32]:
    solve(n)
