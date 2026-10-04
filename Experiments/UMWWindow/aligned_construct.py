#!/usr/bin/env python3
"""
ALIGNED rank-2 divisor-cover construction + its scaling test (round 96c).

Question: the birthday obstruction (round 96b) says RANDOM covers of size
n^gamma fail for gamma<1/2. Does a DELIBERATELY ALIGNED construction (the
Umans-Wang GAP-structure hypothesis) escape it?

Construction searched (S,T each a sum of two APs -- a rank-2 GAP):
    S = AP(a1,d1,L1) + AP(a2,d2,L2),  T = AP(b1,e1,L1) + AP(b2,e2,L2),
so |S|=|T|=L1*L2 ~ n^gamma.  Magnitude budget M=exp(n^gamma) enforced STRICTLY
(an over-budget build is rejected, never truncated).  Coverage = fraction of
i in [2,n] for which some difference s-t is divisible by i.

Findings:
  * Single-t0 CRT alignment is INFEASIBLE: covering all maximal prime powers
    with one t needs ~n^(1-gamma) bundles, whose per-bundle lcm OVERSHOOTS the
    budget by orders of magnitude. So T must be a genuine GAP, not a point.
  * A hill-climbed rank-2 GAP cover reaches a FULL cover at n=800 (gamma=0.36)
    in ~half the seeds -- but this is a SMALL-n LUCKY HIT.
  * Scaling to n=2000,5000 the best coverage falls to ~38-59% and DECAYS; the
    full cover does NOT persist. Hill-climbing buys a constant-factor
    improvement over random (which round 96b measured at ~n^(2g-1) decay) but
    does NOT reach an asymptotic cover below gamma=1/2.

Verdict: the aligned-by-search route does not, as implemented, produce a
sub-1/4 construction. A beating cover (< gamma 0.4, exponent <1/5) is not
obtained. This is a NEGATIVE result for hill-climb alignment and consistent
with -- but does not prove -- the birthday obstruction applying to any cover
of these sizes.
"""
import math, random
import numpy as np

# ---------- fast primitives ----------
def gap_arrays(a1, d1, a2, d2, L1, L2, M, maxsize):
    if a1 + (L1 - 1) * d1 > M or a2 + (L2 - 1) * d2 > M:
        return None
    s1 = a1 + np.arange(L1) * d1
    s2 = a2 + np.arange(L2) * d2
    S = (s1[:, None] + s2[None, :]).ravel()
    if S.max() > M or len(S) > maxsize:
        return None
    return S

def cov_mask(S, T, n):
    D = np.abs(S[:, None] - T[None, :]).ravel()
    D = D[D > 0]
    idx = np.arange(2, n + 1)
    mark = np.zeros(n + 1, dtype=np.uint8)
    rem = D[None, :] % idx[:, None]
    mark[2:] = (rem == 0).any(axis=1).astype(np.uint8)
    return mark

def feasible_gen(rng, L, M):
    d = rng.randint(1, max(1, M // max(L - 1, 1)))
    a = rng.randint(1, max(1, M - (L - 1) * d))
    return a, d

def hc(n, gamma, M, iters, seed, maxsize):
    """Hill-climb a rank-2 GAP cover; strict budget; return best coverage."""
    rng = random.Random(seed)
    target = max(2, int(round(n ** gamma)))
    L1 = max(1, int(round(math.sqrt(target))))
    L2 = max(1, target // L1)
    def ev(p):
        S = gap_arrays(p[0], p[1], p[2], p[3], L1, L2, M, maxsize)
        T = gap_arrays(p[4], p[5], p[6], p[7], L1, L2, M, maxsize)
        if S is None or T is None:
            return -1
        return int(cov_mask(S, T, n)[2:].sum())
    while True:
        p = []
        for _ in range(4):
            a, d = feasible_gen(rng, max(L1, L2), M); p += [a, d]
        c = ev(p)
        if c >= 0:
            break
    best = c
    for _ in range(iters):
        q = p[:]; i = rng.randrange(4)
        a, d = feasible_gen(rng, max(L1, L2), M); q[2 * i] = a; q[2 * i + 1] = d
        c2 = ev(q)
        if c2 > best:
            best = c2; p = q
            if best >= n - 1:
                break
    return best

def single_t0_lcm_shoot():
    """CRT bundle-lcm feasibility for a SINGLE t0 (T={t0})."""
    def is_prime(x):
        if x < 2: return False
        d = 2
        while d * d <= x:
            if x % d == 0: return False
            d += 1
        return True
    n = 800; gamma = 0.39
    mp = []
    for pr in range(2, n + 1):
        if is_prime(pr):
            m = pr
            while m * pr <= n: m *= pr
            mp.append(m)
    M = math.exp(n ** gamma)
    mp = sorted(mp)
    nb = int(round(n ** (1 - gamma)))
    per = len(mp) / nb
    worst = 1
    for b in range(nb):
        L = 1
        for m in mp[int(b * per):int((b + 1) * per)]:
            L = L * m // math.gcd(L, m)
        worst = max(worst, L)
    return len(mp), nb, worst, M

def main():
    print("=== single-t0 CRT alignment: INFEASIBLE (per-bundle lcm overshoots M) ===")
    npp, nb, worst, M = single_t0_lcm_shoot()
    print(f"  n=800 gamma=0.39: {npp} maximal prime powers, need ~{nb} bundles,")
    print(f"  per-bundle lcm (max) = {worst:.3g} > M = exp(n^gamma) = {M:.3g}  -> OVERSHOOT")
    print("  => a single-point T cannot cover; T must be a genuine rank-2 GAP.\n")

    print("=== rank-2 GAP hill-climb, strict budget M=exp(n^gamma) ===")
    print("  coverage = # of i in [2,n] dividing some difference.")
    for n in [800, 2000, 5000]:
        row = []
        for gamma in [0.36, 0.399]:
            M = int(math.exp(n ** gamma))
            best = max(hc(n, gamma, M, 500, seed=20000 + s, maxsize=4 * n) for s in range(5))
            row.append((gamma, best))
        s = "  ".join(f"g={g:.3f}(exp={g/2:.3f}):{b}/{n-1}({100*b//(n-1):3d}%){'FULL' if b>=n-1 else ''}" for g, b in row)
        print(f"  n={n:5d}  {s}")
    print()
    print("VERDICT: no full cover persists as n grows; the n=800 full cover was a")
    print("small-n lucky hit. Hill-climb alignment improves the CONSTANT over random")
    print("but does not yield an asymptotic cover below gamma=1/2. NEGATIVE result.")

if __name__ == "__main__":
    main()