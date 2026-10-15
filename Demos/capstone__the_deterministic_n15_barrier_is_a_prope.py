#!/usr/bin/env python3
"""
The one-fifth barrier of the baby-step/giant-step motif, and the divisibility-covering wall.

Numerical companion to the paper "Three Roads to One-Fifth".  Every function is inlined;
the script needs only the Python standard library and runs in a few seconds.

Sections
  1. The three-leg exponent  E(a,b) = max(a, b, 1/2 - a/2 - b):  floor 1/5, unique optimiser.
  2. Road I   -- slack constraints: an exponent-0 (polylog) term cannot move the optimum.
  3. Road II  -- the general three-leg optimum gamma/(1+u+w/c), the closed m-variable,
                 and delete-a-leg.
  4. Road III -- the space-time invariant 3A + 2C >= 1.
  5. Divisibility coverings: the exact counting wall 4^n <= (2n+1) M^{|S||T|}.
  6. The two constructed ends of the wall: the lcm pair and the baby-step/giant-step sets.
  7. Exploratory (not a proof): smallest k-by-k coverings for tiny k.
"""
from __future__ import annotations

from fractions import Fraction as Q
from itertools import combinations
from math import comb, gcd, log
from typing import Iterable, Sequence


# ---------------------------------------------------------------------------
# 1. The three-leg exponent
# ---------------------------------------------------------------------------

def cost_exp(a: Q, b: Q) -> Q:
    """Exponent of N in the motif's cost with r = N^a pairs and m = N^b list entries."""
    return max(a, b, Q(1, 2) - a / 2 - b)


def grid(lo: Q, hi: Q, steps: int) -> list[Q]:
    return [lo + (hi - lo) * Q(i, steps) for i in range(steps + 1)]


def section1() -> None:
    print("=" * 78)
    print("1. The three-leg exponent E(a,b) = max(a, b, 1/2 - a/2 - b)")
    print("=" * 78)
    pts = grid(Q(0), Q(1, 2), 60)
    best = min((cost_exp(a, b), a, b) for a in pts for b in pts)
    print(f"  exact grid minimum over [0,1/2]^2 (step 1/120): E = {best[0]} at (a,b) = ({best[1]}, {best[2]})")
    print(f"  E(1/5,1/5) = {cost_exp(Q(1,5), Q(1,5))};  all three legs equal 1/5 there:",
          Q(1, 5), Q(1, 5), Q(1, 2) - Q(1, 10) - Q(1, 5))
    # Certificate of the floor: 2*a + 2*b + 2*(1/2 - a/2 - b) ... use weights (2,2,4)/... :
    # (1/2)*a + 1*b + 1*(1/2 - a/2 - b) = 1/2, and weights sum 5/2, so max >= (1/2)/(5/2) = 1/5.
    print("  certificate: (1/2)*a + 1*b + 1*(1/2 - a/2 - b) = 1/2 identically, weights sum to 5/2,")
    print("               so the largest leg is at least (1/2)/(5/2) = 1/5.")
    near = [(a, b) for a in pts for b in pts if cost_exp(a, b) == Q(1, 5)]
    print(f"  grid points attaining exactly 1/5: {near}  (uniqueness)")


# ---------------------------------------------------------------------------
# 2. Road I: slack constraints
# ---------------------------------------------------------------------------

def section2() -> None:
    print("\n" + "=" * 78)
    print("2. Road I -- a slack constraint cannot move the optimum")
    print("=" * 78)
    pts = grid(Q(0), Q(1, 2), 40)
    for name, g in [("order-finding term, N-exponent 0", lambda a, b: Q(0)),
                    ("an 'M-leg' worth 1/5 - a + b at the optimum", lambda a, b: Q(1, 5) - a + b),
                    ("an active leg 1/4 (for contrast)", lambda a, b: Q(1, 4))]:
        val = min(max(cost_exp(a, b), g(a, b)) for a in pts for b in pts)
        print(f"  add {name:45s}: new optimum = {val}")
    # Two-scale (exponent, power of log N) costs compared lexicographically.
    print("  two-scale costs (exponent, log-power), compared lexicographically:")
    for k in (1, 10, 1000):
        order_term, optimum = (Q(0), k), (Q(1, 5), 0)
        print(f"    N^0 * lg^{k:<5d} N  <  N^(1/5)?  {order_term < optimum}")
    for N_bits in (512, 1024, 2048, 4096):
        print(f"    for {N_bits}-bit N the slack factor lg^0.8 N = {N_bits ** 0.8:9.1f}")


# ---------------------------------------------------------------------------
# 3. Road II: general three-leg shape, closed variable, delete a leg
# ---------------------------------------------------------------------------

def cost_gen(g: Q, u: Q, w: Q, c: Q, a: Q, b: Q) -> Q:
    return max(a, c * b, g - u * a - w * b)


def gen_opt(g: Q, u: Q, w: Q, c: Q) -> Q:
    return g / (1 + u + w / c)


def section3() -> None:
    print("\n" + "=" * 78)
    print("3. Road II -- optimum gamma/(1+u+w/c), the closed m-variable, delete-a-leg")
    print("=" * 78)
    for (g, u, w, c) in [(Q(1, 2), Q(1, 2), Q(1), Q(1)), (Q(1, 2), Q(1, 2), Q(1, 2), Q(1)),
                         (Q(1, 2), Q(1, 2), Q(3, 2), Q(1)), (Q(1, 2), Q(1, 2), Q(3), Q(2)),
                         (Q(1), Q(1), Q(1), Q(1))]:
        v = gen_opt(g, u, w, c)
        attained = cost_gen(g, u, w, c, v, v / c)
        print(f"  gamma={g}, u={u}, w={w}, c={c}:  optimum {v}  (attained value {attained})")
    print("  closed variable: with gamma = u = 1/2 the optimum is 1/(3 + 2 w/c);")
    for ratio in (Q(0), Q(1, 2), Q(1), Q(3, 2), Q(2)):
        print(f"     w/c = {str(ratio):4s} -> optimum {Q(1, 2) / (Q(3, 2) + ratio)}")
    print("     benefit <= cost (w/c <= 1) forces >= 1/5; exponent 1/6 needs exactly w/c = 3/2.")
    print("  re-split invariance: scaling (w, c, b) -> (l w, l c, b/l) changes nothing:")
    a, b = Q(1, 7), Q(2, 9)
    for l in (Q(2), Q(1, 3), Q(5)):
        print(f"     l={l}:  {cost_gen(Q(1,2),Q(1,2),l*1,l*1,a,b/l)} == {cost_gen(Q(1,2),Q(1,2),Q(1),Q(1),a,b)}")
    print("  delete-a-leg witnesses (inside 0 <= a, b <= 1/2):")
    print(f"     drop pair leg a  : max(b, residual) at (1/2,1/8) = {max(Q(1,8), Q(1,2)-Q(1,4)-Q(1,8))}")
    print(f"     drop list leg b  : max(a, residual) at (0,1/2)   = {max(Q(0), Q(1,2)-0-Q(1,2))}")
    print(f"     drop search leg  : max(a, b) at (0,0)            = {max(Q(0), Q(0))}")


# ---------------------------------------------------------------------------
# 4. Road III: the space-time invariant
# ---------------------------------------------------------------------------

def time_exp(a: Q, b: Q) -> Q:
    return max(a, Q(1, 2) - a / 2 - b)


def section4() -> None:
    print("\n" + "=" * 78)
    print("4. Road III -- space-time invariant 3A + 2C >= 1  (T^3 S^2 >= N)")
    print("=" * 78)
    pts = grid(Q(-1, 2), Q(1), 30)
    worst = min(3 * time_exp(a, b) + 2 * b for a in pts for b in pts)
    print(f"  minimum of 3A + 2C over a 31x31 grid of (a,b) in [-1/2,1]^2: {worst}")
    print("  the trade-off curve (best time for a given space exponent C = b):")
    for b in (Q(0), Q(1, 10), Q(1, 5), Q(1, 4), Q(3, 10)):
        a = (1 - 2 * b) / 3
        print(f"     C = {str(b):5s}  ->  best time A = {time_exp(a, b)}   (3A+2C = {3*time_exp(a,b)+2*b}),"
              f"  max(A,C) = {max(time_exp(a, b), b)}")


# ---------------------------------------------------------------------------
# 5-6. Divisibility coverings
# ---------------------------------------------------------------------------

def is_div_covering(n: int, S: Iterable[int], T: Iterable[int]) -> bool:
    S, T = list(S), list(T)
    return all(any((s - t) % i == 0 for s in S for t in T) for i in range(1, n + 1))


def lcm_upto(n: int) -> int:
    L = 1
    for i in range(1, n + 1):
        L = L * i // gcd(L, i)
    return L


def bsgs_sets(k: int) -> tuple[list[int], list[int]]:
    return [k * k + k * j for j in range(k)], list(range(k))


def bsgs_witness(k: int, i: int) -> tuple[int, int, int]:
    """For 1 <= i <= k^2 return (s, t, q) with s in giant steps, t in baby steps, s - t = q*i."""
    a = k * k - k + 1                  # the k^2 consecutive differences are a, a+1, ..., a+k^2-1
    q = -(-a // i)                     # ceil(a / i): first multiple of i that is >= a
    d = q * i - a                      # 0 <= d < i <= k^2
    s, t = k * k + k * (d // k), k - 1 - d % k
    assert s - t == q * i
    return s, t, q


def diff_product(S: Sequence[int], T: Sequence[int]) -> int:
    P = 1
    for s in S:
        for t in T:
            P *= s - t
    return P


def section5() -> None:
    print("\n" + "=" * 78)
    print("5. Divisibility coverings and the exact counting wall 4^n <= (2n+1) M^{|S||T|}")
    print("=" * 78)
    print("  without the guard S and T disjoint: S = T = {0} covers every [n] (0 is divisible by all).",
          is_div_covering(50, [0], [0]))
    for k in (2, 3, 5, 8):
        S, T = bsgs_sets(k)
        n = (k * k) // 2
        M = 2 * k * k
        X = abs(diff_product(S, T))
        cb = comb(2 * n, n)
        print(f"  k={k}: BSGS covers [2n]=[{2*n}]: {is_div_covering(2*n, S, T)};"
              f"  C(2n,n)={cb} divides prod|s-t|: {X % cb == 0};"
              f"  4^n={4**n} <= (2n+1)M^(k^2) : {4**n <= (2*n+1) * M**(k*k)}")
    print("  The wall at the lcm end is the classical 4^n <= (2n+1) lcm(1..2n):")
    for n in (1, 3, 5, 10, 20):
        print(f"     n={n:2d}: 4^n = {4**n:>14d}   (2n+1)*lcm(1..2n) = {(2*n+1)*lcm_upto(2*n):>22d}")


def section6() -> None:
    print("\n" + "=" * 78)
    print("6. The two constructed ends of the wall alpha + 2 beta = 1")
    print("=" * 78)
    for n in (5, 10, 20, 30):
        L = lcm_upto(n)
        print(f"  (alpha,beta)=(1,0): S={{lcm(1..{n})}}, T={{0}} covers [{n}]: {is_div_covering(n,[L],[0])};"
              f"  log M = {log(L):6.2f}  vs n = {n}")
    for k in (2, 4, 7, 12):
        S, T = bsgs_sets(k)
        ok = all(bsgs_witness(k, i)[0] in S and bsgs_witness(k, i)[1] in T for i in range(1, k * k + 1))
        print(f"  (alpha,beta)=(0,1/2): k={k:2d}, |S|=|T|={k}, covers [{k*k}]: "
              f"{is_div_covering(k*k, S, T)}, witnesses valid: {ok}, max entry {max(S)} <= 2k^2 = {2*k*k}")
    k = 4
    print(f"  sample witnesses for k={k}:", [(i,) + bsgs_witness(k, i) for i in (1, 7, 11, 16)])
    print("  zero-slack interior point: alpha = beta = 1/3 gives alpha + 2 beta =", Q(1, 3) + 2 * Q(1, 3),
          "-- no covering family is known there.")


# ---------------------------------------------------------------------------
# 7. Exploratory: smallest coverings
# ---------------------------------------------------------------------------

def min_box(k: int, n: int, limit: int = 40) -> int | None:
    """Least M such that disjoint S, T subset of [0, M], |S| = |T| = k, cover [n]. Brute force."""
    for M in range(limit):
        pts = list(range(M + 1))
        for S in combinations(pts, k):
            rest = [x for x in pts if x not in S]
            for T in combinations(rest, k):
                if (M in S or M in T) and is_div_covering(n, S, T):
                    return M
    return None


def section7() -> None:
    print("\n" + "=" * 78)
    print("7. Exploratory (brute force, not a proof): least box size M_k(n) for k x k coverings")
    print("=" * 78)
    print("  trivial lower bound: M_k(n) >= max(n, 2k-1)  (a nonzero multiple of n; 2k distinct entries)")
    for k in (1, 2):
        row = [(n, min_box(k, n, 70)) for n in range(1, k * k + 2 * k + 3)]
        print(f"  k={k}: " + ", ".join(f"n={n}:{m}" for n, m in row))
    print("  (k=1 is lcm(1..n); for k=2 the jump appears just past n = k^2 + 2k = 8.)")


if __name__ == "__main__":
    section1(); section2(); section3(); section4(); section5(); section6(); section7()
