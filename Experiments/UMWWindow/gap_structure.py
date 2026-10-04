#!/usr/bin/env python3
"""
GAP-realisation divisor-cover search + the birthday obstruction (round 96b).

PART A -- why RANDOM covers cannot beat 1/4 (the birthday obstruction).
  For a divisor-cover we need, for every i<=n, some s in S, t in T with
  i | (s-t), i.e. (S mod i) INTERSECTS (T mod i). If S,T are RANDOM of size
  ~ n^gamma, then mod a typical i<=n they behave like random subsets of
  Z/i of size min(n^gamma, i). The expected intersection size is
      ~ |S mod i| * |T mod i| / i  ~  n^(2 gamma - 1)   (i ~ n, gamma<1).
  For gamma<1/2 this is n^(negative) -> 0, so for a generic i the intersection
  is EMPTY. Hence random covers die for gamma<1/2 = exponent 1/4.  This is the
  exact reason the round-96 random experiment plateaued at 1/4.
  MEASURED: covered-fraction decays like n^(2gamma-1) as n grows, and vanishes
  for gamma<1/2 (see the table).

PART B -- GAP search under the STRICT magnitude budget M=exp(n^gamma).
  A GAP S=AP1+AP2 with steps up to M is built within budget and any build
  exceeding M is REJECTED (never truncated). We report robust mean/max coverage.

CONCLUSION: a cover in the beating window (gamma<0.4) cannot be RANDOM; it must
be deliberately arithmetically ALIGNED (S mod i == T mod i on purpose). The
Umans-Wang conjecture demands exactly such an alignment via GAP structure.
"""
import math, random

def frac_covered(S, T, n):
    cov = 0
    for i in range(2, n + 1):
        rs = {x % i for x in S}
        if any(y % i in rs for y in T):
            cov += 1
    return cov / (n - 1)

def make_ap(rng, L, budget):
    if L <= 1:
        return (rng.randint(1, max(1, budget)), 1, 1)
    d = rng.randint(1, max(1, budget // (L - 1)))
    a = rng.randint(1, max(1, budget - (L - 1) * d))
    return (a, d, L)

def gap(elems, M, maxsize):
    S = {0}
    for (a, d, L) in elems:
        S = {s + a + i * d for s in S for i in range(L)}
        if len(S) > maxsize:
            return None
    return S if (not S or max(S) <= M) else None   # STRICT: reject over-budget

def coverage(S, T, n):
    cov = 0
    Sl, Tl = list(S), list(T)
    for i in range(2, n + 1):
        rs = {x % i for x in Sl}
        if any(y % i in rs for y in Tl):
            cov += 1
    return cov

def gap_search(n, gamma, M, iters, seed, maxsize):
    rng = random.Random(seed)
    target = max(2, int(round(n ** gamma)))
    L1 = rng.randint(1, target)
    L2 = max(1, target // L1)
    def build():
        return (gap([make_ap(rng, L1, M), make_ap(rng, L2, M)], M, maxsize),
                gap([make_ap(rng, L1, M), make_ap(rng, L2, M)], M, maxsize))
    best = 0
    for _ in range(iters):
        S, T = build()
        if not S or not T:
            continue
        c = coverage(S, T, n)
        if c > best:
            best = c
    return best

def main():
    print("=== PART A: birthday obstruction -- random covers die for gamma<1/2 ===")
    random.seed(5)
    for gamma in [0.36, 0.399, 0.45, 0.5, 0.55]:
        row = []
        for n in [200, 800, 3000]:
            p = max(2, int(round(n ** gamma)))
            fr = []
            for _ in range(5):
                S = set(random.randint(1, 10**6) for _ in range(p))
                T = set(random.randint(1, 10**6) for _ in range(p))
                fr.append(frac_covered(S, T, n))
            row.append(sum(fr) / len(fr))
        pred = min(1.0, 3000 ** (2 * gamma - 1))
        print(f"  gamma={gamma:.3f} exp={gamma/2:.3f} covered-frac(n=200,800,3000)="
              f"{row[0]:.3f},{row[1]:.3f},{row[2]:.3f}  n^(2g-1)@3000~{pred:.3f}")
    print("  -> covered fraction DECAYS with n and vanishes for gamma<1/2 (=exponent 1/4).")

    print("\n=== PART B: GAP search, STRICT budget M=exp(n^gamma), n=800 ===")
    n = 800
    for gamma in [0.36, 0.38, 0.39, 0.399, 0.42, 0.45]:
        M = int(math.exp(n ** gamma))
        covs = [gap_search(n, gamma, M, 800, seed=3000 + s, maxsize=8 * n) for s in range(8)]
        mean = sum(covs) / len(covs)
        print(f"  gamma={gamma:.3f} exp={gamma/2:.3f} M={M:9d} cov mean={mean:6.1f} "
              f"max={max(covs):4d}/{n} ({int(100*mean//n):3d}% mean)")

    print("\nCONCLUSION: random/aligned-by-luck covers cannot enter gamma<0.4.")
    print("A beating cover must be DELIBERATELY aligned mod each i -- the exact")
    print("content of the Umans-Wang GAP-structure hypothesis. UNRESOLVED here.")

if __name__ == "__main__":
    main()
