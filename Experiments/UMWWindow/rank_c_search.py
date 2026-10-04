#!/usr/bin/env python3
"""
Rank-c GAP counterexample search (round 96e): can MORE AP generators escape
the round-96b birthday obstruction?

Rationale. The obstruction was proved for RANDOM S,T of size n^g. A GAP S =
AP(d_1,L_1)+...+AP(d_c,L_c) is structured; Kneser's theorem suggests its
residues mod i are at least as SPREAD as a random |S|-set (measured: a single
coprime-step AP saturates all residues mod i>=|S|). If true, higher rank should
NOT evade the birthday law -- coverage stays ~ n^(2g-1) for g<1/2.

This is the FALSIFICATION test: build S,T each a sum of c APs (c=2,3,4,6),
|S|=|T| ~ n^g, elements <= M=exp(n^g) STRICTLY, hill-climb the generators,
and measure the best coverage as n grows in the beating window g in [1/3,2/5).

If some rank-c achieves a FULL cover that PERSISTS as n grows, the obstruction
is refuted and a beating construction may exist. We expect NOT to.
"""
import math, random
import numpy as np

def build_gap(gen, M, maxsize):
    # gen: list of (a,d,L). Build S as the sumset; reject if > M or too big.
    S = {0}
    for (a, d, L) in gen:
        add = [a + i * d for i in range(L)]
        S = {s + x for s in S for x in add}
        if len(S) > maxsize:
            return None
        if S and max(S) > M:
            return None
    return S

def cov_mask(S, T, n):
    Sa = np.fromiter(S, dtype=np.int64)
    Ta = np.fromiter(T, dtype=np.int64)
    D = np.abs(Sa[:, None] - Ta[None, :]).ravel()
    D = D[D > 0]                       # drop zero difference (non-vacuous)
    if D.size == 0:
        return 0
    idx = np.arange(2, n + 1)
    # mark i dividing some D ; chunk to bound memory
    cov = 0
    step = max(1, 4_000_000 // max(D.size, 1))
    for a in range(2, n + 1, step):
        b = min(n + 1, a + step)
        seg = idx[a - 2:b - 2]
        rem = D[None, :] % seg[:, None]
        cov += int((rem == 0).any(axis=1).sum())
    return cov

def feasible_ap(rng, L, M):
    # AP length L with max element <= M ; choose step, start to fit budget
    d = rng.randint(1, max(1, M // max(L, 1)))
    a = rng.randint(0, max(0, M - (L - 1) * d))
    return (a, d, L)

def hill_climb(n, gamma, c, M, iters, seed, maxsize):
    rng = random.Random(seed)
    target = max(2, int(round(n ** gamma)))
    # split target into c factors (roughly balanced)
    Ls = []
    rem = target
    for _ in range(c - 1):
        left = c - len(Ls)
        f = max(1, int(round(rem ** (1.0 / left))))
        f = max(1, min(f, rem))
        Ls.append(f)
        rem = max(1, rem // f)
    Ls.append(rem)
    # Allocate a PER-AP budget M//c so the SUM of the c APs stays within M.
    # (Sizing each AP to the full M made the sum always exceed M -> 100% reject.)
    Mb = max(L for L in Ls)          # ensure per-AP budget >= any single element
    Mb = max(1, M // c)
    def ev(genS, genT):
        S = build_gap(genS, M, maxsize)
        T = build_gap(genT, M, maxsize)
        if not S or not T:
            return -1
        return cov_mask(S, T, n)
    while True:
        genS = [feasible_ap(rng, L, Mb) for L in Ls]
        genT = [feasible_ap(rng, L, Mb) for L in Ls]
        best = ev(genS, genT)
        if best >= 0:
            break
    for _ in range(iters):
        gen = genS if rng.random() < 0.5 else genT
        j = rng.randrange(c)
        old = gen[j]
        gen[j] = feasible_ap(rng, Ls[j], Mb)
        nb = ev(genS, genT)
        if nb > best:
            best = nb
        elif nb < 0:
            gen[j] = old
    return best, Ls

def main():
    print("Rank-c GAP counterexample search, strict budget M=exp(n^gamma).")
    print("coverage = # of i in [2,n] dividing some nonzero difference.\n")
    for n in [800]:
        print(f"n = {n}")
        for c in [2, 3, 4, 6]:
            row = []
            for gamma in [0.36, 0.399]:
                M = int(math.exp(n ** gamma))
                best = max(hill_climb(n, gamma, c, M, 250, seed=21000 + s, maxsize=3 * n)[0]
                           for s in range(2))
                row.append(f"g={gamma:.3f}(e={gamma/2:.3f}): {best:4d}/{n-1} ({100*best//(n-1):3d}%)")
            print(f"  rank c={c}: " + "   ".join(row))
        print()

if __name__ == "__main__":
    main()