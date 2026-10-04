"""Rank-1 vs rank-2 cover density at matched |A| budget.  (v2: two bugs fixed.)

v1 BUGS.
  (a) I counted the grid point (0,0), for which a*u + b*v = 0 holds for EVERY
      (a,b).  That is the vacuous cover -- the exact trap flagged in Round 49
      and formalised in He-Sahai's Remark 4.1 ("allowing zero as a witness would
      make the condition vacuous, since every positive integer divides zero").
  (b) I chose |A| ~ p, at which BOTH densities are 1.0 and the comparison is
      vacuous.

THE QUESTION.  He-Sahai killed rank-1 at (1/3,1/3) but left rank-2 alive
(Remark 4.2): his decisive step is (u+ic) - (u+jc) = (i-j)c, and a rank-two
difference has two independent coefficients.

Is that escape SUBSTANTIVE or only METHODOLOGICAL?

SETUP, matched at |A| = L = S*T total pairs.

  rank-1 (AP version):   A = { d + i c : 0 <= i < L }
      modulus m is HIT  <=>  exists i in [0,L), i != 0, with d + i c = 0 mod m
  rank-2 (two APs):      A = { d + i c1 - j c2 : 0 <= i < S, 0 <= j < T }
      modulus m is HIT  <=>  exists (i,j) != (0,0) with d + i c1 - j c2 = 0 mod m

We measure, for each modulus m <= n, the FRACTION of coefficient choices that
hit m.  If rank-2 is systematically higher at the same budget, the escape is
substantive; if they match, He-Sahai's rank-1 obstruction should transfer and
rank-2 is also false.
"""

from __future__ import annotations

import math
import random
from math import gcd


def rank1_hit_density(m: int, L: int, rng: random.Random, trials: int) -> float:
    """Fraction of (d,c) mod m for which some i in [1,L) gives d+i*c = 0."""
    hit = 0
    for _ in range(trials):
        d = rng.randrange(m)
        c = rng.randrange(m)
        ok = False
        for i in range(1, L):
            if (d + i * c) % m == 0:
                ok = True
                break
        if ok:
            hit += 1
    return hit / trials


def rank2_hit_density(m: int, S: int, T: int, rng: random.Random,
                      trials: int) -> float:
    """Fraction of (d,c1,c2) mod m for which some (i,j) != (0,0) gives
    d + i*c1 - j*c2 = 0."""
    hit = 0
    for _ in range(trials):
        d = rng.randrange(m)
        c1 = rng.randrange(m)
        c2 = rng.randrange(m)
        ok = False
        for i in range(S):
            for j in range(T):
                if i == 0 and j == 0:
                    continue
                if (d + i * c1 - j * c2) % m == 0:
                    ok = True
                    break
            if ok:
                break
        if ok:
            hit += 1
    return hit / trials


def main():
    print(__doc__)
    rng = random.Random(9900)
    TR = 400

    print("=== Per-modulus hit density at MATCHED budget |A| = L = S*T ===")
    print("Rank-1 uses L indices; rank-2 uses an S x T grid with S*T = L.")
    print()
    print(f"{'n':>6} {'beta':>6} {'L':>6} {'S':>4} {'T':>4} "
          f"{'rank1 dens':>11} {'rank2 dens':>11} {'ratio':>8}  "
          f"{'theory L/n':>12}")
    for n in (60, 120, 240):
        for beta in (0.30, 1 / 3, 0.375, 0.40):
            L = max(2, int(round(n ** (2 * beta))))
            if L >= n:
                continue
            S = max(2, int(math.isqrt(L)))
            T = L // S
            if S * T < L:            # give rank-2 the full budget
                T += 1
            ms = [m for m in range(2, n + 1) if m in _prime_powers(n)]
            if not ms:
                continue
            d1 = sum(rank1_hit_density(m, L, rng, TR) for m in ms) / len(ms)
            d2 = sum(rank2_hit_density(m, S, T, rng, TR) for m in ms) / len(ms)
            print(f"{n:6d} {beta:6.3f} {L:6d} {S:4d} {T:4d} "
                  f"{d1:11.4f} {d2:11.4f} {(d2/d1 if d1 else 0):8.3f}  "
                  f"{L/n:12.4f}")
    print()
    print("=== Structure test: how many DISTINCT residues can each form reach? ===")
    print("For fixed modulus m and budget L = S*T, count the size of the set")
    print("of residues actually attained (not the hit density).  This is what")
    print("determines whether the rank-2 difference set is really 'bigger'.")
    print()
    print(f"{'m':>6} {'L':>5} {'|A|_rank1':>11} {'|A|_rank2':>11} {'ratio':>8}")
    for m in (97, 101, 199, 211):
        for L in (9, 16, 25):
            S = int(math.isqrt(L))
            T = L // S
            if S * T < L:
                T += 1
            c = rng.randrange(m) or 1
            r1 = {(-i * c) % m for i in range(1, L)}
            acc = set()
            for _ in range(30):
                c1 = rng.randrange(m)
                c2 = rng.randrange(m)
                acc |= {(-(i * c1) + j * c2) % m
                        for i in range(S) for j in range(T)
                        if not (i == 0 and j == 0)}
            print(f"{m:6d} {L:5d} {len(r1):11d} {len(acc):11d} "
                  f"{(len(acc)/len(r1) if r1 else 0):8.3f}")
    print()
    print("=== Reading ===")
    print("If rank-1 and rank-2 hit densities MATCH at matched budget, then the")
    print("per-modulus obstruction is the same and He-Sahai's rank-1 lower bound")
    print("should transfer to rank-2: the (1/3,1/3) point would be false for")
    print("rank-2 as well, closing the Umans-Wang route entirely.")
    print()
    print("If rank-2 is systematically HIGHER, rank-2 genuinely escapes and is")
    print("the live residue, as Round 58 concluded.")
    print()
    print("STATUS: this is evidence, not a proof.  A density comparison at these")
    print("sizes does not establish an asymptotic obstruction either way.")


def _prime_powers(n):
    sieve = bytearray([1]) * (n + 1)
    sieve[0:2] = b"\x00\x00"
    for i in range(2, math.isqrt(n) + 1):
        if sieve[i]:
            sieve[i * i::i] = bytearray(len(sieve[i * i::i]))
    out = set()
    for p in range(2, n + 1):
        if sieve[p]:
            pk = p
            while pk <= n:
                out.add(pk)
                pk *= p
    return out


if __name__ == "__main__":
    main()