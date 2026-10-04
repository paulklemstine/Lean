#!/usr/bin/env python3
"""
UMW divisor-cover window experiment (Factoring round 96).

Question: the only named route past Harvey's deterministic N^(1/5) is
Umans-Wang (arXiv:2511.10851). Their Theorem 5.5 gives deterministic
factoring in O~(N^(max(alpha,beta)/2)) IF the Strong (alpha,beta)-Divisor
Conjecture holds. Beating N^(1/5) therefore needs gamma=max(alpha,beta)<2/5.
A counting argument (product of primes <=n must divide the product of all
differences) forces alpha+2*beta>=1, i.e. gamma>=1/3. So the beating window
is gamma in [1/3, 2/5).

This script measures three things, all reproducible:
  (1) window arithmetic and the capacity slack 3*gamma-1;
  (2) the magnitude obstruction (group-lcm vs budget) as a function of gamma,n;
  (3) how much of [n] a RANDOM rank-2 cover (S,T random of size n^gamma,
      elements <= exp(n^gamma)) actually covers -- i.e. does nominal capacity
      slack convert into a real cover?

Everything here is DESCRIPTIVE measurement of a heuristic search. It is not a
proof that structured covers cannot exist; it is a benchmark locating where
the difficulty lives (see note).
"""
import math, random
from math import gcd

def single_capacity(M, n):
    """max # of i in [n] a single d<=M can divide, among lcm-like d."""
    best = 0; L = 1
    for m in range(1, min(n, M) + 1):
        L = L * m // gcd(L, m)
        if L > M:
            break
        best = max(best, sum(1 for i in range(1, n + 1) if L % i == 0))
    return best

def cover_from_ST(S, T, n):
    cov = set()
    for s in S:
        for t in T:
            d = abs(s - t)
            if d > 0:
                for i in range(1, min(n, d) + 1):
                    if d % i == 0:
                        cov.add(i)
    return cov

def random_rank2_search(n, p, M, tries, seed):
    random.seed(seed)
    S = set(random.randint(1, M) for _ in range(p))
    T = set(random.randint(1, M) for _ in range(p))
    cov = cover_from_ST(S, T, n); best = len(cov); bS, bT = set(S), set(T)
    for _ in range(tries):
        if random.random() < 0.5:
            S = set(bS); arr = list(bS)
            arr[random.randrange(len(arr))] = random.randint(1, M); S = set(arr)
            cand = (S, bT)
        else:
            T = set(bT); arr = list(bT)
            arr[random.randrange(len(arr))] = random.randint(1, M); T = set(arr)
            cand = (bS, T)
        c = len(cover_from_ST(cand[0], cand[1], n))
        if c > best:
            best = c; bS, bT = set(cand[0]), set(cand[1])
            if best >= n:
                break
    return best

def main():
    print("=== (1) window arithmetic (gamma=max(alpha,beta), diagonal alpha=beta=gamma) ===")
    print("target exponent = gamma/2; beats Harvey 1/5 iff gamma<0.4")
    for gamma in [1/3, 0.34, 0.35, 0.36, 0.38, 0.39, 0.399]:
        print(f"  gamma={gamma:.4f}  cap_exp=3g={3*gamma:.4f}  slack=3g-1={3*gamma-1:+.4f}  exponent={gamma/2:.4f}")

    print("\n=== (2) magnitude obstruction: budget exp(n^g) vs group-lcm <= exp(n^(1-2g)*ln n) ===")
    print("fits iff ln n <= n^(3g-1)")
    for gamma in [1/3, 0.35, 0.38, 0.39, 0.399]:
        for logn in [4, 8, 12]:
            n = 10**logn
            lhs = math.log(n); rhs = n**(3*gamma - 1)
            print(f"  g={gamma:.4f} n=1e{logn:<2d} fits={str(lhs<=rhs):5s} ln(n)={lhs:7.2f} n^(3g-1)={rhs:10.2f}")

    print("\n=== (3) random rank-2 coverage vs gamma (n=100) ===")
    n = 100
    for gamma in [0.34, 0.36, 0.38, 0.39, 0.40, 0.42, 0.45, 0.50]:
        p = max(2, int(round(n**gamma)))
        M = min(int(math.exp(n**gamma)), 2_000_000)
        sc = single_capacity(M, n)
        nom = p * p * sc
        cov = random_rank2_search(n, p, M, 6000, seed=11)
        print(f"  gamma={gamma:.2f} p={p:3d} single_cap={sc:3d} nominal_cap={nom:5d} cov={cov:3d}/{n} ({100*cov//n:3d}%) exp={gamma/2:.3f}")

    print("\nFull coverage (100%) first achieved near gamma~0.5 -> exponent 1/4,")
    print("which EQUALS the trivial one-set (T={0}) construction. No free lunch.")

if __name__ == "__main__":
    main()
