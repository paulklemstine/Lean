#!/usr/bin/env python3
"""
The Berggren-Price interlock: numerical demonstration.
=====================================================

Two classical ternary trees -- Barning-Hall-Berggren and Price -- live on the SAME
vertex set of Euclid parameters

    V = { (m, n) in Z^2 : 1 <= n < m, gcd(m, n) = 1, m + n odd },

rooted at (2, 1) (the triple (3, 4, 5)).  A node (m, n) carries the primitive triple
(m^2 - n^2, 2mn, m^2 + n^2), and the odd leg factors as (m - n)(m + n): a node IS a
factorisation.

This script demonstrates, numerically:

  1. Both generator triples preserve the node set, and the parent rules invert them.
  2. Each tree enumerates the vertex set exactly once (BFS, no duplicates).
  3. The N-node identity: for odd coprime 1 <= p < q, the Fermat pair
     ((p+q)/2, (q-p)/2) is a node with odd leg exactly N = pq.
  4. The interlock separations: determinants +-1 vs +-2, leg-swap symmetry for
     Berggren but not Price, and exactly two shared edges ((3,2) and (4,1)).
  5. Depth duality: Price depth ~ log2(m), Berggren depth ratio-driven and erratic;
     the staircase node (2^(i+2), 1) has Berggren depth 2^(i+1) - 1, Price depth i+1.
  6. The factoring verdict: tree traversal cost 3^d vs Fermat's scan length, and the
     trade-off inequality  m <= 2 * s * (2d + 3)^2.
  7. The mod-4 obstruction: no primitive hypotenuse is divisible by a prime = 3 mod 4.

Pure standard library.  Run:  python3 demo.py
"""

from __future__ import annotations

import math
import random
from itertools import product
from typing import Dict, Iterator, List, Optional, Tuple

Node = Tuple[int, int]
Word = Tuple[int, ...]

# --------------------------------------------------------------------------------------
# 1. The vertex set and the triple at a node
# --------------------------------------------------------------------------------------


def is_node(v: Node) -> bool:
    """Valid Euclid parameters: 1 <= n < m, coprime, opposite parity."""
    m, n = v
    return 1 <= n < m and math.gcd(m, n) == 1 and (m + n) % 2 == 1


def triple(v: Node) -> Tuple[int, int, int]:
    """The primitive Pythagorean triple (odd leg, even leg, hypotenuse) at a node."""
    m, n = v
    return (m * m - n * n, 2 * m * n, m * m + n * n)


def odd_leg(v: Node) -> int:
    m, n = v
    return m * m - n * n


# --------------------------------------------------------------------------------------
# 2. The six generators
# --------------------------------------------------------------------------------------


def berg(i: int, v: Node) -> Node:
    """Berggren children; matrices of determinant +1, -1, +1."""
    m, n = v
    return [(2 * m - n, m), (2 * m + n, m), (m + 2 * n, n)][i]


def price(i: int, v: Node) -> Node:
    """Price children; matrices of determinant -2, +2, +2."""
    m, n = v
    return [(2 * m, m - n), (2 * m, m + n), (m + n, 2 * n)][i]


BERG_MAT: List[List[List[int]]] = [[[2, -1], [1, 0]], [[2, 1], [1, 0]], [[1, 2], [0, 1]]]
PRICE_MAT: List[List[List[int]]] = [[[2, 0], [1, -1]], [[2, 0], [1, 1]], [[1, 1], [0, 2]]]


def det2(mat: List[List[int]]) -> int:
    return mat[0][0] * mat[1][1] - mat[0][1] * mat[1][0]


# --------------------------------------------------------------------------------------
# 3. The two parent (descent) rules
# --------------------------------------------------------------------------------------

ROOT: Node = (2, 1)


def berg_parent(v: Node) -> Optional[Tuple[int, Node]]:
    """Berggren descent: compare m with 2n and 3n (subtractive / continued fraction)."""
    m, n = v
    if v == ROOT:
        return None
    if m < 2 * n:
        return (0, (n, 2 * n - m))
    if m < 3 * n:
        return (1, (n, m - 2 * n))
    return (2, (m - 2 * n, n))


def price_parent(v: Node) -> Optional[Tuple[int, Node]]:
    """Price descent: halve m if m is even, else halve n (binary-GCD style)."""
    m, n = v
    if v == ROOT:
        return None
    if m % 2 == 0:
        k = m // 2
        return (0, (k, k - n)) if n < k else (1, (k, n - k))
    t = n // 2
    return (2, (m - t, t))


def berg_word(v: Node) -> Word:
    """The unique Berggren address of a node; the leftmost letter acts last."""
    letters: List[int] = []
    while v != ROOT:
        step = berg_parent(v)
        assert step is not None
        i, v = step
        letters.append(i)
    return tuple(letters)


def price_word(v: Node) -> Word:
    """The unique Price address of a node; the leftmost letter acts last."""
    letters: List[int] = []
    while v != ROOT:
        step = price_parent(v)
        assert step is not None
        i, v = step
        letters.append(i)
    return tuple(letters)


def apply_word(gen, w: Word, v: Node = ROOT) -> Node:
    """Apply a word; the head letter acts last, matching the address convention."""
    for i in reversed(w):
        v = gen(i, v)
    return v


# --------------------------------------------------------------------------------------
# 4. The N-node identity
# --------------------------------------------------------------------------------------


def fermat_node(p: int, q: int) -> Node:
    """The Fermat pair ((p+q)/2, (q-p)/2) of the factorisation N = p*q."""
    return ((p + q) // 2, (q - p) // 2)


def fermat_scan(n_val: int) -> Tuple[int, int, int]:
    """Fermat's method: return (m, n, steps) with m^2 - n^2 = N; steps = m - floor(sqrt N)."""
    r = math.isqrt(n_val)
    m = r if r * r == n_val else r + 1
    steps = 0
    while True:
        steps += 1
        d = m * m - n_val
        s = math.isqrt(d)
        if s * s == d:
            return (m, s, steps)
        m += 1


# --------------------------------------------------------------------------------------
# 5. Breadth-first enumeration
# --------------------------------------------------------------------------------------


def bfs_levels(gen, depth: int) -> List[List[Node]]:
    """All nodes of a tree down to a given depth, level by level."""
    levels: List[List[Node]] = [[ROOT]]
    for _ in range(depth):
        levels.append([gen(i, v) for v in levels[-1] for i in range(3)])
    return levels


# --------------------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------------------


def banner(text: str) -> None:
    print()
    print("=" * 78)
    print(text)
    print("=" * 78)


def demo_generators_and_parents(depth: int = 8) -> None:
    banner("1. Generators preserve nodes; parent rules invert them (BFS depth %d)" % depth)
    for name, gen, par in (("Berggren", berg, berg_parent), ("Price", price, price_parent)):
        levels = bfs_levels(gen, depth)
        nodes = [v for lv in levels for v in lv]
        bad_node = [v for v in nodes if not is_node(v)]
        bad_parent = 0
        for lv in levels[1:]:
            for v in lv:
                step = par(v)
                assert step is not None
                i, u = step
                if gen(i, u) != v or not is_node(u):
                    bad_parent += 1
        total = len(nodes)
        distinct = len(set(nodes))
        print(f"  {name:8s}: {total:7d} nodes generated, {distinct:7d} distinct "
              f"(3^0+...+3^{depth} = {(3 ** (depth + 1) - 1) // 2}), "
              f"invalid nodes: {len(bad_node)}, parent failures: {bad_parent}")
    print("  => both trees enumerate their vertex set exactly once, with no failures.")


def demo_n_node(trials: int = 400, bits: int = 12) -> None:
    banner("2. The N-node identity:  odd leg at the Fermat pair is EXACTLY N = p*q")
    print("     N        p     q    Fermat pair (m,n)   odd leg   even leg   hypotenuse")
    print("  " + "-" * 74)
    for (p, q) in [(3, 5), (5, 7), (7, 13), (17, 23), (101, 103), (13, 97)]:
        v = fermat_node(p, q)
        a, b, c = triple(v)
        assert is_node(v) and a == p * q
        print(f"  {p*q:6d}   {p:5d} {q:5d}      {str(v):>12s}   {a:7d}   {b:8d}   {c:10d}")

    rng = random.Random(391)
    ok = 0
    tested = 0
    for _ in range(trials):
        p = _random_prime(rng, bits)
        q = _random_prime(rng, bits)
        if p == q:
            continue
        p, q = min(p, q), max(p, q)
        v = fermat_node(p, q)
        tested += 1
        if is_node(v) and odd_leg(v) == p * q and (v[0] - v[1], v[0] + v[1]) == (p, q):
            ok += 1
    print(f"\n  Random semiprimes verified: {ok}/{tested} satisfy "
          f"m^2 - n^2 = N,  p = m - n,  q = m + n.")
    print("  The map (m,n) -> (m-n, m+n) is a bijection nodes <-> coprime odd factorisations.")


def demo_interlock() -> None:
    banner("3. The interlock: three exact separations")
    print("  Determinants:")
    print("    Berggren:", [det2(m) for m in BERG_MAT], " (all +-1: coprimality is free)")
    print("    Price:   ", [det2(m) for m in PRICE_MAT], " (all +-2: parity saves it)")
    print("    => |det| is a conjugacy invariant, so no change of coordinates")
    print("       intertwines a Berggren generator with a Price generator.")

    # Leg swap on triples.
    bergT = [
        [[1, -2, 2], [2, -1, 2], [2, -2, 3]],
        [[1, 2, 2], [2, 1, 2], [2, 2, 3]],
        [[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]],
    ]
    priceT = [
        [[2, 1, 1], [2, -2, 2], [2, -1, 3]],
        [[2, -1, 1], [2, 2, 2], [2, 1, 3]],
        [[2, 1, -1], [-2, 2, 2], [-2, 1, 3]],
    ]
    swap = [[0, 1, 0], [1, 0, 0], [0, 0, 1]]

    def mul(x, y):
        return [[sum(x[i][k] * y[k][j] for k in range(3)) for j in range(3)] for i in range(3)]

    def conj(a):
        return mul(mul(swap, a), swap)

    b_hits = sum(1 for i in range(3) if any(conj(bergT[i]) == bergT[j] for j in range(3)))
    p_hits = sum(1 for i in range(3) if any(conj(priceT[i]) == priceT[j] for j in range(3)))
    print(f"\n  Leg swap (a,b,c) -> (b,a,c) conjugation:")
    print(f"    Berggren generators mapped back into the family: {b_hits}/3 "
          "(it swaps children 0 and 2, fixes child 1)")
    print(f"    Price generators mapped back into the family:    {p_hits}/3 "
          "(every Price generator has an even first column)")

    # Shared edges.
    shared: List[Node] = []
    for lv in bfs_levels(berg, 11):
        for v in lv:
            b, p = berg_parent(v), price_parent(v)
            if b is not None and p is not None and b[1] == p[1]:
                shared.append(v)
    print(f"\n  Nodes whose Berggren parent equals their Price parent, over "
          f"{sum(len(l) for l in bfs_levels(berg, 11))} nodes scanned:")
    print(f"    {sorted(set(shared))}  -> exactly the two children of the root.")


def demo_depth_duality() -> None:
    banner("4. Depth duality: the two trees order the same vertex set incomparably")
    print("   i    node (2^(i+2), 1)    Berggren depth   Price depth   ratio")
    print("  " + "-" * 62)
    for i in range(1, 9):
        v = (2 ** (i + 2), 1)
        db, dp = len(berg_word(v)), len(price_word(v))
        assert db == 2 ** (i + 1) - 1 and dp == i + 1
        print(f"  {i:2d}    {str(v):>16s}      {db:10d}    {dp:10d}   {db/dp:8.1f}")
    print("  Berggren depth = 2^(i+1) - 1 exactly; Price depth = i + 1 exactly.")
    print("  Berggren depth is EXPONENTIAL in Price depth on this staircase family.")

    rng = random.Random(2026)
    dbs, dps = [], []
    for _ in range(120):
        p, q = _random_prime(rng, 11), _random_prime(rng, 11)
        if p == q:
            continue
        p, q = min(p, q), max(p, q)
        v = fermat_node(p, q)
        dbs.append(len(berg_word(v)))
        dps.append(len(price_word(v)))
    print(f"\n  Random 11-bit semiprimes ({len(dbs)} samples):")
    print(f"    Berggren depth: mean {_mean(dbs):8.1f}, range [{min(dbs)}, {max(dbs)}]  "
          "(ratio-driven, erratic)")
    print(f"    Price depth:    mean {_mean(dps):8.1f}, range [{min(dps)}, {max(dps)}]  "
          "(size-driven, tight)")
    print(f"    corr(d_B, d_P) = {_corr(dbs, dps):+.2f}   -> essentially independent orderings")


def demo_factoring_verdict() -> None:
    banner("5. The factoring verdict: tree traversal never beats Fermat")
    print("      N       p     q    Fermat steps   Berggren depth d_B   tree work 3^d_B")
    print("  " + "-" * 78)
    rng = random.Random(17)
    wins = 0
    trials = 0
    for _ in range(40):
        p, q = _random_prime(rng, 10), _random_prime(rng, 10)
        if p == q:
            continue
        p, q = min(p, q), max(p, q)
        n_val = p * q
        _, _, steps = fermat_scan(n_val)
        db = len(berg_word(fermat_node(p, q)))
        trials += 1
        if 3 ** db < steps:
            wins += 1
        if trials <= 8:
            print(f"  {n_val:8d}  {p:5d} {q:5d}   {steps:10d}   {db:16d}   {3**db:.3e}")
    print(f"\n  Tree traversal (3^d_B) beat Fermat's scan in {wins}/{trials} trials.")

    print("\n  The trade-off inequality  m <= 2 * s * (2 d + 3)^2  (s = Fermat scan length):")
    print("      node (m,n)      d_B     s     m      2 s (2d+3)^2   holds?")
    print("  " + "-" * 68)
    for (p, q) in [(3, 5), (5, 11), (7, 9), (13, 17), (3, 101), (11, 13)]:
        v = fermat_node(p, q)
        m, _ = v
        d = len(berg_word(v))
        _, _, s = fermat_scan(p * q)
        rhs = 2 * s * (2 * d + 3) ** 2
        print(f"  {str(v):>14s}  {d:6d}  {s:4d}  {m:5d}   {rhs:13d}   {m <= rhs}")
    print("  Small s (easy Fermat) forces large d (deep tree address): inverse coupling.")


def demo_mod4_obstruction() -> None:
    banner("6. Why the odd leg, not the hypotenuse: the mod-4 obstruction")
    nodes = {v for lv in bfs_levels(berg, 10) for v in lv}
    for n_val in (15, 21, 35, 77, 91, 65, 85):
        hits = sum(1 for (m, n) in nodes if (m * m + n * n) % n_val == 0)
        bad = [p for p in _prime_factors(n_val) if p % 4 == 3]
        note = f"has prime factor(s) {bad} = 3 mod 4" if bad else "all prime factors = 1 mod 4"
        print(f"  N = {n_val:3d}: {hits:5d} nodes with N | m^2 + n^2 out of {len(nodes)}   ({note})")
    print("\n  No primitive hypotenuse is divisible by a prime p = 3 (mod 4): -1 is a")
    print("  non-residue there, so p | m^2 + n^2 would force p | m and p | n.")
    print("  The odd-leg embedding is exact and never empty -- it is the correct one.")


# --------------------------------------------------------------------------------------
# Small helpers
# --------------------------------------------------------------------------------------


def _is_prime(k: int) -> bool:
    if k < 2:
        return False
    for p in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        if k % p == 0:
            return k == p
    d, r = k - 1, 0
    while d % 2 == 0:
        d //= 2
        r += 1
    for a in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        x = pow(a, d, k)
        if x in (1, k - 1):
            continue
        for _ in range(r - 1):
            x = x * x % k
            if x == k - 1:
                break
        else:
            return False
    return True


def _random_prime(rng: random.Random, bits: int) -> int:
    while True:
        k = rng.randrange(2 ** (bits - 1), 2 ** bits) | 1
        if _is_prime(k):
            return k


def _prime_factors(k: int) -> List[int]:
    out: List[int] = []
    d = 2
    while d * d <= k:
        while k % d == 0:
            out.append(d)
            k //= d
        d += 1
    if k > 1:
        out.append(k)
    return sorted(set(out))


def _mean(xs: List[int]) -> float:
    return sum(xs) / len(xs)


def _corr(xs: List[int], ys: List[int]) -> float:
    mx, my = _mean(xs), _mean(ys)
    num = sum((x - mx) * (y - my) for x, y in zip(xs, ys))
    dx = math.sqrt(sum((x - mx) ** 2 for x in xs))
    dy = math.sqrt(sum((y - my) ** 2 for y in ys))
    return num / (dx * dy) if dx and dy else 0.0


def main() -> None:
    print(__doc__)
    demo_generators_and_parents()
    demo_n_node()
    demo_interlock()
    demo_depth_duality()
    demo_factoring_verdict()
    demo_mod4_obstruction()
    banner("Summary")
    print("  * Every odd coprime factorisation N = pq is the node ((p+q)/2, (q-p)/2)")
    print("    of BOTH trees, with odd leg exactly N.  Factoring = finding the N-node.")
    print("  * The two descents are inequivalent: determinants +-1 vs +-2, leg-swap")
    print("    symmetric vs not, exactly two shared edges.")
    print("  * Traversal cost and Fermat cost are inversely coupled: m <= 2 s (2d+3)^2.")
    print("    The trees sort the factorisations by the ratio (p+q)/(q-p), not by pq.")


if __name__ == "__main__":
    main()
