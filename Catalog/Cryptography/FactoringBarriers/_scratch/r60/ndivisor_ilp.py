"""The divisor-cover problem as an integer program -- search for rank-1 covers.

Umans-Wang's divisor condition, made into a search.

A set A = {b + i c : 0 <= i < L} is an "n-divisor set" if every m in [1,n]
divides at least one element of A (and all elements are positive).  Define the
GAP in one axis:

    cost(b,c,L,n) = #{ m in [1,n] : m does not divide any b + ic, 0<=i<L }.

We want cost = 0.  This script:

  (1) confirms by exhaustive search that cost = 0 is ACHIEVABLE with L = n
      (the trivial cover A = [1,n], b=1,c=1) -- sanity;
  (2) searches, for n up to a few hundred, for covers with L < n, i.e. does a
      SHORT arithmetic progression ever cover?  This is exactly what He-Sahai
      prove cannot happen with L ~ n^(2/3), H = exp(n^(1/3));
  (3) finds the MINIMUM covering length L_min(n) for small n and fits its growth.

(3) is the quantitative question: He-Sahai give L >> n^(3/4)/sqrt(log n) at
height exp(o(sqrt n)).  If L_min(n) grows faster than n^(2/3), their refutation
is quantitatively sharp and the gap to Umans-Wang's n^(2/3) target is wide.
If L_min(n) is much smaller, the conjecture survives at these sizes and the
obstruction is only asymptotic.
"""
from __future__ import annotations

import math, random, sys
from math import gcd, isqrt

def primes_upto(n):
    s = bytearray([1])*(n+1); s[0:2]=b"\x00\x00"
    for i in range(2, isqrt(n)+1):
        if s[i]: s[i*i::i] = bytearray(len(s[i*i::i]))
    return [i for i in range(2,n+1) if s[i]]

def cover_size(n):
    """minimal L of an n-divisor AP; None if search fails"""
    P = primes_upto(n)
    best = None
    # He-Sahai: search b in [1,n], c in [1,n] (small height first), all L
    # by starting from the smallest L.
    for L in range(1, n+1):
        found = None
        for c in range(1, n+1):
            for b in range(1, n+1):
                # check divisibility: for each m, does some i < L give m | b+ic?
                ok = True
                for m in range(2, n+1):
                    hit = False
                    val = b
                    for i in range(L):
                        if val % m == 0:
                            hit = True; break
                        val += c
                    if not hit:
                        ok = False; break
                if ok:
                    found = (b,c); break
            if found: break
        if found:
            return L, found
    return None

def main():
    print(__doc__)
    print("=== sanity: does the trivial cover work? ===")
    for n in (6, 10, 20):
        L, (b, c) = cover_size(n)
        print(f"  n={n:3d}: L_min = {L}  via (b,c)=({b},{c})   "
              f"(trivial cover b=1,c=1,L=n gives {n})")
        assert L <= n
    print()
    print("=== growth of L_min(n) for small n (brute force, n<=14) ===")
    print(f"{'n':>4} {'L_min':>6} {'n^(2/3)':>9} {'L/n^(2/3)':>11}")
    pts=[]
    for n in range(2, 15):
        r = cover_size(n)
        L = r[0]
        n23 = n ** (2/3)
        pts.append((n, L, n23))
        print(f"{n:4d} {L:6d} {n23:9.3f} {L/n23:11.3f}")
    print()
    print("=== is L_min(n) ever < n^(2/3)?  (He-Sahai says asymptotically no) ===")
    below = [(n,L) for n,L,_ in pts if L < n**(2/3)]
    if below:
        print(f"  YES at n in {below} -- but n is tiny; the question is asymptotic.")
    else:
        print("  no, for all tested n <= 14, L_min(n) >= n^(2/3)")
    print()
    print("=== ratio L_min/n, to see if L_min is closer to n or n^(2/3) ===")
    for n,L,n23 in pts:
        print(f"  n={n:3d}  L_min/n = {L/n:.3f}   L_min/n^(2/3) = {L/n23:.3f}")

if __name__ == "__main__":
    main()
