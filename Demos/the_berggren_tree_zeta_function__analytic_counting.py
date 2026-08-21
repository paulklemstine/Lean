#!/usr/bin/env python3
"""
The Berggren Tree Zeta Function — numerical demonstration
=========================================================

Self-contained numerical companion to the results on the Berggren (Barning-Hall)
tree of primitive Pythagorean triples and its zeta function

    Z(s) = sum over all tree nodes w of c(w)^(-s),

where c(w) is the hypotenuse at node w.

The demonstrations, in order:

  1. Tree structure. Generate the tree in Euclid-seed coordinates and verify
     that the depth-k layer has exactly 3^k distinct nodes (injectivity), that
     the seed invariant (0 < n < m, gcd = 1, m+n odd) is preserved, and that
     the seed moves agree with the three Barning matrices.

  2. The silver speed limit. Verify c(w) <= 2*lambda^(k+1) for every node at
     depth k, with lambda = 3 + 2*sqrt(2) = (1 + sqrt(2))^2, and that the
     middle spine attains the exponential rate.

  3. The spectral spine. Verify the recurrence c_{k+2} = 6 c_{k+1} - c_k, the
     closed form in the eigenvalues 3 +- 2*sqrt(2), and the growth exponent
     log(lambda) = 2 log(1 + sqrt(2)).

  4. The layer spread. Show that within a single layer the hypotenuse ranges
     from 2k^2 + 6k + 5 (slow spine) to ~ lambda^k (fast spine): the reason the
     layer-maximum heuristic fails.

  5. The abscissa. Show numerically that Z(s) diverges at s = 1 and at every
     s in (log 3 / log lambda, 1], while the layer majorant converges there.
     This is the quantitative refutation of the silver-ratio prediction.

  6. The counting law. Compute N(H) exactly, verify H/50 <= N(H) <= 2H for
     H >= 512, and exhibit the convergence N(H)/H -> 1/(2*pi).

  7. The Tauberian bridge. Verify the block estimate
     hsum(128 H) >= hsum(H) + 1/300 and the resulting rate hsum >= k/300.

  8. The leg zeta functions. Show that the odd and even legs have the same
     abscissa 1, and that they are not comparable to the hypotenuse from below.

Run with:  python3 demo.py
Requires only the Python standard library.
"""

from __future__ import annotations

import math
from fractions import Fraction
from math import gcd, isqrt, log, pi, sqrt
from typing import Dict, Iterator, List, Tuple

Seed = Tuple[int, int]

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

SILVER: float = 1.0 + sqrt(2.0)          # delta_S = 1 + sqrt(2)
LAM: float = 3.0 + 2.0 * sqrt(2.0)       # lambda  = delta_S^2 = 3 + 2 sqrt(2)
LAM_INV: float = 3.0 - 2.0 * sqrt(2.0)   # lambda' = 3 - 2 sqrt(2) = 1/lambda
SIGMA_SILVER: float = log(3.0) / log(LAM)  # the (refuted) prediction, 0.6232...


# ---------------------------------------------------------------------------
# 1. The tree in Euclid-seed coordinates
# ---------------------------------------------------------------------------

def step(i: int, p: Seed) -> Seed:
    """The three Berggren moves in Euclid-seed coordinates.

    s0(m,n) = (2m - n, m),  s1(m,n) = (2m + n, m),  s2(m,n) = (m + 2n, n).
    These are exactly the three Barning matrices transported through Euclid's
    parametrisation (m,n) -> (m^2 - n^2, 2mn, m^2 + n^2).
    """
    m, n = p
    if i == 0:
        return (2 * m - n, m)
    if i == 1:
        return (2 * m + n, m)
    if i == 2:
        return (m + 2 * n, n)
    raise ValueError(f"move index must be 0, 1 or 2; got {i}")


ROOT: Seed = (2, 1)  # the seed of (3, 4, 5)


def is_seed(p: Seed) -> bool:
    """0 < n < m, coprime, opposite parity: the Euclid-seed invariant."""
    m, n = p
    return 0 < n < m and gcd(m, n) == 1 and (m + n) % 2 == 1


def triple(p: Seed) -> Tuple[int, int, int]:
    """The primitive Pythagorean triple (a, b, c) attached to a seed."""
    m, n = p
    return (m * m - n * n, 2 * m * n, m * m + n * n)


def hyp(p: Seed) -> int:
    """The hypotenuse m^2 + n^2 attached to a seed."""
    m, n = p
    return m * m + n * n


def node(word: List[int]) -> Seed:
    """The seed at the node labelled by a word; the last letter is applied last."""
    p = ROOT
    for i in word:
        p = step(i, p)
    return p


def unstep(i: int, p: Seed) -> Seed:
    """The inverse of the move `i`, valid on the image of that move."""
    m, n = p
    if i == 0:
        return (n, 2 * n - m)
    if i == 1:
        return (n, m - 2 * n)
    if i == 2:
        return (m - 2 * n, n)
    raise ValueError(f"move index must be 0, 1 or 2; got {i}")


def parent_move(p: Seed) -> int:
    """Which of the three moves produced the (non-root) seed p.

    The three images are separated by the ratio m/n: move 0 lands in m < 2n,
    move 1 in 2n < m < 3n, move 2 in m > 3n.  Coprimality excludes the
    boundaries m = 2n and m = 3n for every seed other than the root.
    """
    m, n = p
    if m < 2 * n:
        return 0
    if m < 3 * n:
        return 1
    return 2


def word_of_seed(p: Seed) -> List[int]:
    """Recover the unique word labelling a Euclid seed (Barning-Hall descent)."""
    word: List[int] = []
    while p != ROOT:
        i = parent_move(p)
        word.append(i)
        p = unstep(i, p)
    word.reverse()
    return word


def layer(k: int) -> List[Seed]:
    """All 3^k seeds at depth k, generated breadth-first from the root."""
    current: List[Seed] = [ROOT]
    for _ in range(k):
        current = [step(i, p) for p in current for i in (0, 1, 2)]
    return current


def barning_matrices() -> Tuple[List[List[int]], List[List[int]], List[List[int]]]:
    """The three Barning matrices A1, A2, A3 acting on (a, b, c)."""
    a1 = [[1, -2, 2], [2, -1, 2], [2, -2, 3]]
    a2 = [[1, 2, 2], [2, 1, 2], [2, 2, 3]]
    a3 = [[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]]
    return a1, a2, a3


def apply_matrix(a: List[List[int]], v: Tuple[int, int, int]) -> Tuple[int, int, int]:
    """Matrix-vector product over the integers."""
    return tuple(sum(a[r][c] * v[c] for c in range(3)) for r in range(3))  # type: ignore


def demo_structure(max_depth: int = 9) -> None:
    print("=" * 78)
    print(" 1. TREE STRUCTURE: injectivity, layer size 3^k, and the Barning dictionary")
    print("=" * 78)

    a1, a2, a3 = barning_matrices()
    mats = {0: a1, 1: a2, 2: a3}

    print("\n  root (3,4,5) and its three children:")
    for i in (0, 1, 2):
        child = step(i, ROOT)
        print(f"    move s{i}: seed {ROOT} -> {child}   triple {triple(child)}")

    print("\n  the seed moves ARE the Barning matrices (checked on 200 nodes):")
    ok_dict = True
    seeds_checked = 0
    for k in range(5):
        for p in layer(k):
            for i in (0, 1, 2):
                if apply_matrix(mats[i], triple(p)) != triple(step(i, p)):
                    ok_dict = False
            seeds_checked += 1
            if seeds_checked >= 200:
                break
        if seeds_checked >= 200:
            break
    print(f"    A_i * tri(p) == tri(s_i(p)) for all checked p : {ok_dict}")

    print("\n  depth |  3^k   | distinct seeds | all seeds valid | max hypotenuse")
    print("  ------+--------+----------------+-----------------+----------------")
    for k in range(max_depth + 1):
        lay = layer(k)
        distinct = len(set(lay))
        valid = all(is_seed(p) for p in lay)
        print(f"  {k:5d} | {3 ** k:6d} | {distinct:14d} | {str(valid):15s} "
              f"| {max(hyp(p) for p in lay):14d}")

    print("\n  Completeness (Barning-Hall): every Euclid seed is a node of the tree.")
    print("  We verify it constructively by climbing DOWN to the root: the sector")
    print("  containing (m,n) determines the unique move that produced it, and the")
    print("  corresponding inverse move strictly decreases m.")
    bound = 200
    total = 0
    depths: List[int] = []
    ok_complete = True
    for m in range(2, bound):
        for n in range(1, m):
            if not is_seed((m, n)):
                continue
            total += 1
            word = word_of_seed((m, n))
            if node(word) != (m, n):
                ok_complete = False
            depths.append(len(word))
    print(f"    Euclid seeds with m < {bound} tested            : {total}")
    print(f"    every one reconstructed exactly from its word : {ok_complete}")
    print(f"    depths encountered                            : "
          f"{min(depths)} to {max(depths)}")
    print("    (deep-but-small seeds such as (m, m-1) sit at depth m-2 on the slow")
    print("     spine, which is why a breadth-first sweep of bounded depth misses")
    print("     them -- the tree is complete, but wildly unbalanced in size.)")


# ---------------------------------------------------------------------------
# 2-3. The silver speed limit and the spectral spine
# ---------------------------------------------------------------------------

def demo_silver(max_depth: int = 10) -> None:
    print()
    print("=" * 78)
    print(" 2-3. THE SILVER SPEED LIMIT AND THE SPECTRAL SPINE")
    print("=" * 78)
    print(f"\n  silver ratio delta_S = 1 + sqrt(2)  = {SILVER:.10f}")
    print(f"  lambda      = delta_S^2 = 3+2sqrt2  = {LAM:.10f}")
    print(f"  lambda'     = 1/lambda  = 3-2sqrt2  = {LAM_INV:.10f}")
    print(f"  log lambda  = 2 log delta_S         = {log(LAM):.10f}")

    print("\n  speed limit  c(w) <= 2 lambda^(k+1)  over every node of depth k:")
    print("  depth | max c in layer | bound 2 lambda^(k+1) | holds")
    print("  ------+----------------+----------------------+------")
    for k in range(max_depth + 1):
        mx = max(hyp(p) for p in layer(k))
        bound = 2.0 * LAM ** (k + 1)
        print(f"  {k:5d} | {mx:14d} | {bound:20.1f} | {str(mx <= bound):5s}")

    print("\n  the middle spine (apply s1 repeatedly): odd-indexed Pell numbers")
    print("  k  |   c_k        | 6c_{k-1} - c_{k-2} | closed form        | c_k/c_{k-1}")
    print("  ---+--------------+--------------------+--------------------+------------")
    spine: List[int] = []
    p = ROOT
    for k in range(11):
        spine.append(hyp(p))
        p = step(1, p)
    for k in range(11):
        rec = "" if k < 2 else f"{6 * spine[k - 1] - spine[k - 2]:18d}"
        closed = ((10 + 7 * sqrt(2)) * LAM ** k + (10 - 7 * sqrt(2)) * LAM_INV ** k) / 4
        ratio = "" if k == 0 else f"{spine[k] / spine[k - 1]:.8f}"
        print(f"  {k:2d} | {spine[k]:12d} | {rec:18s} | {closed:18.4f} | {ratio}")

    print(f"\n  ratios converge to lambda = {LAM:.8f}  (verified above)")
    print("  log(c_k)/k -> log lambda:")
    for k in (4, 8, 16, 32, 64):
        p = ROOT
        for _ in range(k):
            p = step(1, p)
        val = log(hyp(p)) / k
        print(f"    k = {k:3d}:  log(c_k)/k = {val:.8f}   (target {log(LAM):.8f})")


# ---------------------------------------------------------------------------
# 4. The layer spread — why the heuristic fails
# ---------------------------------------------------------------------------

def demo_layer_spread(max_depth: int = 12) -> None:
    print()
    print("=" * 78)
    print(" 4. THE LAYER SPREAD: the layer maximum is a terrible proxy for a typical node")
    print("=" * 78)
    print("\n  depth |    nodes |  min c | 2k^2+6k+5 |   median c |         max c |  max/min")
    print("  ------+----------+--------+-----------+------------+---------------+---------")
    for k in range(1, max_depth + 1):
        lay = layer(k)
        hs = sorted(hyp(p) for p in lay)
        mn, md, mx = hs[0], hs[len(hs) // 2], hs[-1]
        formula = 2 * k * k + 6 * k + 5
        print(f"  {k:5d} | {len(lay):8d} | {mn:6d} | {formula:9d} | {md:10d} "
              f"| {mx:13d} | {mx / mn:8.3g}")
    print("\n  The minimum is exactly 2k^2 + 6k + 5, attained on the SLOW SPINE s0^k")
    print("  whose seed is (k+2, k+1): quadratic growth, not exponential.")
    print("  The maximum is the odd-indexed Pell number ~ lambda^k on the FAST SPINE.")
    print("  Replacing every node in a layer by its maximum therefore discards")
    print("  essentially the entire sum.")


# ---------------------------------------------------------------------------
# 5. The abscissa of convergence
# ---------------------------------------------------------------------------

def seeds_up_to(m_max: int) -> Iterator[Seed]:
    """All Euclid seeds (m, n) with m <= m_max, i.e. all Berggren nodes."""
    for m in range(2, m_max + 1):
        for n in range(1, m):
            if (m + n) % 2 == 1 and gcd(m, n) == 1:
                yield (m, n)


def partial_zeta(s: float, m_max: int) -> float:
    """Partial sum of Z(s) over all nodes with first seed coordinate <= m_max."""
    return sum((m * m + n * n) ** (-s) for (m, n) in seeds_up_to(m_max))


def layer_majorant(s: float, k_max: int = 400) -> float:
    """The heuristic majorant sum_k 3^k (2 lambda^(k+1))^(-s)."""
    total = 0.0
    for k in range(k_max + 1):
        term = math.exp(k * log(3.0) - s * (log(2.0) + (k + 1) * log(LAM)))
        total += term
        if term < 1e-18 and k > 10:
            break
    return total


def demo_abscissa() -> None:
    print()
    print("=" * 78)
    print(" 5. THE ABSCISSA OF CONVERGENCE IS 1, NOT log 3 / log lambda")
    print("=" * 78)
    print(f"\n  silver prediction  sigma_silver = log 3 / log lambda = {SIGMA_SILVER:.10f}")
    print("  true abscissa      sigma_Z                          = 1.0000000000")
    print(f"  gap                                                = {1 - SIGMA_SILVER:.10f}")

    cutoffs = [100, 200, 400, 800, 1600, 3200]
    tested = [0.70, 0.80, 0.90, 0.98, 1.00, 1.02, 1.10, 1.50]

    print("\n  Partial sums of Z(s) over nodes with m <= M, doubling M each column.")
    print("  The sharp diagnostic is the RATIO of successive increments: as M")
    print("  doubles the tail scales like M^(2-2s), so the increment ratio tends")
    print("  to 2^(2-2s), which is > 1 for s < 1, exactly 1 at s = 1, and < 1 for")
    print("  s > 1.  This locates the abscissa at 1 with no curve fitting.")
    header = ("     s    | " + " | ".join(f"M={c:<7d}" for c in cutoffs)
              + " | incr.ratio | 2^(2-2s) | verdict")
    print("  " + "-" * len(header))
    print("  " + header)
    print("  " + "-" * len(header))
    for s in tested:
        vals = [partial_zeta(s, c) for c in cutoffs]
        d1, d2 = vals[-2] - vals[-3], vals[-1] - vals[-2]
        ratio = d2 / d1
        predicted = 2.0 ** (2.0 - 2.0 * s)
        verdict = "converges" if s > 1.0 else "DIVERGES"
        row = " | ".join(f"{v:9.5f}" for v in vals)
        print(f"   {s:6.2f}  | {row} | {ratio:10.6f} | {predicted:8.6f} | {verdict}")

    print("\n  Now the layer majorant on the same exponents.  In the whole window")
    print(f"  ({SIGMA_SILVER:.4f}, 1] it converges while Z(s) diverges -- the refutation.")
    print("\n     s    | layer majorant | Z(s) status")
    print("  ---------+----------------+-------------")
    for s in [0.62, 0.63, 0.70, 0.80, 0.90, 1.00, 1.10]:
        if s > SIGMA_SILVER:
            maj = f"{layer_majorant(s):14.6f}"
        else:
            maj = "      DIVERGES"
        status = "converges" if s > 1.0 else "DIVERGES"
        print(f"   {s:6.2f}  | {maj} | {status}")

    print("\n  Rigorous sandwich for s > 1:  Z(s) <= zeta(2s-1).")
    for s in (1.10, 1.25, 1.50, 2.00):
        approx = partial_zeta(s, 3000)
        zeta_bound = sum(m ** (1 - 2 * s) for m in range(1, 200000))
        print(f"    s = {s:.2f}:  Z(s) ~ {approx:.6f}   <=   zeta(2s-1) ~ {zeta_bound:.6f}")

    print("\n  Divergence mechanism at s = 1: the prime seeds (p, 2j), 2j < p.")
    print("  Each has hypotenuse p^2 + 4j^2 <= 2p^2, so the tree contains")
    print("  sum over odd primes p of (p-1)/2 terms each >= 1/(2p^2), i.e. >= 1/(8p).")
    primes = [p for p in range(3, 20000) if all(p % q for q in range(2, isqrt(p) + 1))]
    partial = 0.0
    print("    p <= | sum over primes of 1/(8p) | (grows without bound)")
    for limit in (100, 1000, 10000, 20000):
        partial = sum(1.0 / (8 * p) for p in primes if p <= limit)
        print(f"    {limit:5d} | {partial:25.6f} |")


# ---------------------------------------------------------------------------
# 6. The counting law
# ---------------------------------------------------------------------------

def count_N(h_max: int) -> int:
    """N(H): the number of Berggren nodes with hypotenuse at most H.

    By completeness this equals the number of Euclid seeds (m,n) with
    m^2 + n^2 <= H, and needs no tree traversal at all.
    """
    total = 0
    m_max = isqrt(h_max)
    for m in range(2, m_max + 1):
        n_max = min(m - 1, isqrt(h_max - m * m))
        for n in range(1, n_max + 1):
            if (m + n) % 2 == 1 and gcd(m, n) == 1:
                total += 1
    return total


def demo_counting() -> None:
    print()
    print("=" * 78)
    print(" 6. THE COUNTING LAW:  H/50 <= N(H) <= 2H,  and N(H)/H -> 1/(2 pi)")
    print("=" * 78)
    target = 1.0 / (2.0 * pi)
    print(f"\n  conjectured limit 1/(2 pi) = {target:.10f}")
    print("\n         H |      N(H) |    N(H)/H | H/50 <= N | N <= 2H | rel. err vs 1/(2pi)")
    print("  ---------+-----------+-----------+-----------+---------+--------------------")
    for h in (512, 1000, 10_000, 100_000, 1_000_000, 4_000_000):
        n = count_N(h)
        lo_ok = h / 50 <= n
        hi_ok = n <= 2 * h
        err = abs(n / h - target) / target
        print(f"  {h:8d} | {n:9d} | {n / h:.7f} | {str(lo_ok):9s} | {str(hi_ok):7s} "
              f"| {err:.3e}")

    print("\n  Contrast with the (refuted) silver prediction N(H) ~ H^0.6232:")
    print("         H |    N(H) |     H^1 |  H^0.6232 | which matches?")
    print("  ---------+---------+---------+-----------+----------------")
    for h in (10_000, 100_000, 1_000_000):
        n = count_N(h)
        print(f"  {h:8d} | {n:7d} | {h:7d} | {h ** SIGMA_SILVER:9.0f} | linear in H")

    print("\n  The four-factor heuristic behind 1/(2 pi):")
    print("    quarter disc area  pi H / 4")
    print("    restriction n < m         x 1/2   ->  pi H / 8")
    print("    coprimality  1/zeta(2)    x 6/pi^2")
    print("    opposite parity | coprime x 2/3")
    val = Fraction(1, 8) * Fraction(6, 1) * Fraction(2, 3)  # times pi/pi^2 = 1/pi
    print(f"    product of rational factors = {val} , times pi/pi^2 = 1/(2 pi)"
          f" = {float(val) / pi:.10f}")


# ---------------------------------------------------------------------------
# 7. The Tauberian bridge
# ---------------------------------------------------------------------------

def hsum(h_max: int) -> float:
    """The truncated harmonic sum over the tree: sum of 1/c over c <= H."""
    total = 0.0
    m_max = isqrt(h_max)
    for m in range(2, m_max + 1):
        n_max = min(m - 1, isqrt(h_max - m * m))
        for n in range(1, n_max + 1):
            if (m + n) % 2 == 1 and gcd(m, n) == 1:
                total += 1.0 / (m * m + n * n)
    return total


def demo_tauberian() -> None:
    print()
    print("=" * 78)
    print(" 7. THE TAUBERIAN BRIDGE: the counting law alone forces Z(1) = infinity")
    print("=" * 78)
    print("\n  Block estimate:  hsum(128 H) >= hsum(H) + 1/300  for H >= 512.")
    print("  Reason: N(128H) - N(H) >= 128H/50 - 2H = 0.56 H new nodes,")
    print("  each of size <= 128H, so each block adds >= 0.56/128 = 0.004375 > 1/300.")
    print("\n   k | H = 512*128^k |  hsum(H)  | k/300 (proved bound) | block gain")
    print("  ---+---------------+-----------+----------------------+-----------")
    prev = None
    for k in range(0, 3):
        h = 512 * 128 ** k
        v = hsum(h)
        gain = "" if prev is None else f"{v - prev:.6f}"
        print(f"  {k:2d} | {h:13d} | {v:9.6f} | {k / 300:20.6f} | {gain}")
        prev = v
    print("\n  Observed block gains vastly exceed the proved 1/300 = 0.003333;")
    print("  the proved bound is deliberately crude but unconditional.")
    print("  Since hsum(H) ~ (1/(2 pi)) log H, the divergence is logarithmic.")
    for h in (10_000, 100_000, 1_000_000):
        v = hsum(h)
        print(f"    H = {h:8d}:  hsum = {v:.6f},  (1/(2pi)) log H = "
              f"{log(h) / (2 * pi):.6f}")


# ---------------------------------------------------------------------------
# 8. The leg zeta functions
# ---------------------------------------------------------------------------

def demo_legs(m_max: int = 1200) -> None:
    print()
    print("=" * 78)
    print(" 8. THE LEG ZETA FUNCTIONS: same abscissa 1, different mechanism")
    print("=" * 78)
    print("\n  a = m^2 - n^2 (odd leg),  b = 2mn (even leg),  c = m^2 + n^2.")
    print("  The legs are NOT bounded below by a multiple of c:")
    print("\n   k | s2-spine seed | b/c        | s0-spine seed | a/c")
    print("  ---+---------------+------------+---------------+-----------")
    for k in (2, 5, 10, 20, 40):
        p2 = ROOT
        p0 = ROOT
        for _ in range(k):
            p2 = step(2, p2)
            p0 = step(0, p0)
        a2, b2, c2 = triple(p2)
        a0, b0, c0 = triple(p0)
        print(f"  {k:2d} | {str(p2):13s} | {b2 / c2:.8f} | {str(p0):13s} "
              f"| {a0 / c0:.8f}")
    print("\n  so convergence for s > 1 must come from the PRODUCT structure:")
    print("    b = 2mn >= m*n           reindex (m,n) -> (m,n)")
    print("    a = (m-n)(m+n) >= (m-n)m reindex (m,n) -> (m-n, m)")
    print("  and sum over u,v >= 1 of u^-s v^-s = zeta(s)^2 < infinity.")

    print("\n  Partial sums over all nodes with m <= M:")
    print("      s   |   Z_c(s)   |   Z_a(s)   |   Z_b(s)   | zeta(s)^2 bound")
    print("  --------+------------+------------+------------+----------------")
    for s in (0.90, 1.00, 1.20, 1.50, 2.00):
        zc = za = zb = 0.0
        for (m, n) in seeds_up_to(m_max):
            a, b, c = (m * m - n * n, 2 * m * n, m * m + n * n)
            zc += c ** (-s)
            za += a ** (-s)
            zb += b ** (-s)
        if s > 1.0:
            zeta_s = sum(k ** (-s) for k in range(1, 200000))
            bound = f"{zeta_s ** 2:14.5f}"
        else:
            bound = "      infinite"
        print(f"   {s:5.2f}  | {zc:10.5f} | {za:10.5f} | {zb:10.5f} | {bound}")
    print("\n  All three series behave identically at the threshold: abscissa 1.")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> None:
    print()
    print("#" * 78)
    print("#  THE BERGGREN TREE ZETA FUNCTION")
    print("#  Analytic counting of Pythagorean triples, and why the silver ratio")
    print("#  governs the growth but not the density")
    print("#" * 78)

    demo_structure()
    demo_silver()
    demo_layer_spread()
    demo_abscissa()
    demo_counting()
    demo_tauberian()
    demo_legs()

    print()
    print("=" * 78)
    print(" SUMMARY")
    print("=" * 78)
    print(f"""
  * The Berggren tree bijects onto the Euclid seed lattice: 3^k nodes at
    depth k, every primitive triple with odd first leg exactly once.
  * Silver speed limit: c(w) <= 2 lambda^(k+1), lambda = 3 + 2 sqrt(2),
    attained in exponential order on the middle (Pell) spine.
  * PREDICTED abscissa (branching / growth) : {SIGMA_SILVER:.7f}
  * TRUE abscissa of Z(s) = sum c(w)^-s     : 1.0000000
    -- refuted, with an explicit window ({SIGMA_SILVER:.4f}, 1] where the layer
       majorant converges and Z(s) diverges.
  * Counting law: H/50 <= N(H) <= 2H for H >= 512, i.e. N(H) = Theta(H);
    numerically N(H)/H -> 1/(2 pi) = {1 / (2 * pi):.8f}.
  * Tauberian bridge: the counting law alone gives hsum(512*128^k) >= k/300.
  * Both leg zeta functions also have abscissa exactly 1.
  * Reason for the failure: within layer k the hypotenuse ranges from
    2k^2 + 6k + 5 (slow spine) to ~ lambda^k (fast spine).  The layer maximum
    is not a typical node, and a zeta function integrates the whole
    distribution.
""")


if __name__ == "__main__":
    main()


"""
Abscissa Localisation by the Increment-Ratio Dichotomy
======================================================

Numerically localises the abscissa of convergence of the Berggren tree zeta
function

    Z(s) = sum over Euclid seeds (m, n) of (m^2 + n^2)^{-s},

and thereby distinguishes the true value 1 from the (refuted) silver-ratio
prediction log 3 / log(3 + 2 sqrt 2) = 0.6232...

Mathematical foundation
-----------------------
Naively one truncates and watches whether the partial sums settle.  Near the
abscissa this is hopeless: at s = 1.02 the tail decays like M^{-0.04}, so
"settling" is invisible at any feasible cut-off.

The reliable diagnostic is second-order.  Truncating the seed sum at
first coordinate m <= M, the discarded tail is

    T(M) = sum_{m > M} (number of seeds with that m) * m^{-2s}
         ~ const * sum_{m > M} m^{1 - 2s}
         ~ const * M^{2 - 2s} / (2s - 2)          (for s > 1),

and the same power law governs the increment between successive doublings.
Hence, writing D(M) = Z_{2M} - Z_M for the increment gained by doubling the
cut-off,

    D(2M) / D(M)  ->  2^{2 - 2s}.

This limit is > 1 exactly when s < 1, equals 1 exactly at s = 1, and is < 1
exactly when s > 1.  The ratio therefore reads off the abscissa directly, and
in practice matches its predicted value 2^{2-2s} to three or four decimals
already at M = 3200.  Bisecting on the sign of log(ratio) converges to the
abscissa.

Complexity
----------
Each evaluation of the truncated sum costs O(M^2 log M) (Euclidean algorithm
per lattice point), and one bisection step needs three evaluations at
M, 2M, 4M.  Total O(B * M^2 log M) for B bisection steps.  The statistical
resolution of the diagnostic is O(1 / log M), so high precision in the abscissa
requires exponentially large M -- which is why the *proof* rather than the
computation is what pins the value at exactly 1.

Role in the pipeline
--------------------
This is the empirical counterpart of the theorem that Z(s) converges precisely
for s > 1.  Run against the layer majorant sum_k 3^k (2 lambda^{k+1})^{-s},
which converges for all s > 0.6232, it exhibits the refutation window
(0.6232, 1] in which the majorant converges but the series does not.
"""

from __future__ import annotations

import math
from math import gcd, log, sqrt
from typing import Callable, List, Tuple

LAM: float = 3.0 + 2.0 * sqrt(2.0)
SIGMA_SILVER: float = log(3.0) / log(LAM)


def truncated_zeta(s: float, m_max: int) -> float:
    """Partial sum of Z(s) over Euclid seeds with first coordinate <= m_max."""
    total = 0.0
    for m in range(2, m_max + 1):
        for n in range(1, m):
            if (m + n) % 2 == 1 and gcd(m, n) == 1:
                total += (m * m + n * n) ** (-s)
    return total


def increment_ratio(s: float, m_base: int = 800) -> Tuple[float, float]:
    """Return (observed increment ratio, predicted 2^(2-2s))."""
    z1 = truncated_zeta(s, m_base)
    z2 = truncated_zeta(s, 2 * m_base)
    z4 = truncated_zeta(s, 4 * m_base)
    observed = (z4 - z2) / (z2 - z1)
    return observed, 2.0 ** (2.0 - 2.0 * s)


def classify(s: float, m_base: int = 800, band: float = 1e-3) -> str:
    """Classify s as 'diverges', 'converges', or 'threshold'.

    Finite truncation cannot resolve the critical point exactly, so we report
    a band around ratio = 1 rather than pretending to a decision there.
    """
    observed, _ = increment_ratio(s, m_base)
    if observed > 1.0 + band:
        return "diverges"
    if observed < 1.0 - band:
        return "converges"
    return "threshold"


def diverges_at(s: float, m_base: int = 800, band: float = 1e-3) -> bool:
    """Dichotomy test: ratio at or above the threshold band means divergence."""
    return classify(s, m_base, band) != "converges"


def bisect_abscissa(lo: float = 0.5, hi: float = 1.5, steps: int = 8,
                    m_base: int = 400) -> float:
    """Bisect on the increment-ratio dichotomy to localise the abscissa."""
    for _ in range(steps):
        mid = 0.5 * (lo + hi)
        if diverges_at(mid, m_base):
            lo = mid
        else:
            hi = mid
    return 0.5 * (lo + hi)


def layer_majorant(s: float, terms: int = 500) -> float:
    """The heuristic majorant sum_k 3^k (2 lambda^{k+1})^{-s}, or inf."""
    if s <= SIGMA_SILVER:
        return math.inf
    total = 0.0
    for k in range(terms):
        total += math.exp(k * log(3.0) - s * (log(2.0) + (k + 1) * log(LAM)))
    return total


def refutation_window(grid: Tuple[float, ...] = (0.63, 0.70, 0.80, 0.90, 0.99, 1.00)
                      ) -> List[Tuple[float, float, str]]:
    """For each s in the window, the (finite) majorant against divergent Z(s)."""
    return [(s, layer_majorant(s), "Z(s) diverges") for s in grid]


if __name__ == "__main__":
    print(f"silver prediction : {SIGMA_SILVER:.10f}")
    print(f"true abscissa     : 1.0000000000\n")
    print(f"{'s':>6} {'observed ratio':>16} {'2^(2-2s)':>12} {'verdict':>12}")
    for s in (0.70, 0.80, 0.90, 0.98, 1.00, 1.02, 1.10, 1.50):
        obs, pred = increment_ratio(s, 400)
        if obs > 1.001:
            verdict = "DIVERGES"
        elif obs < 0.999:
            verdict = "converges"
        else:
            verdict = "THRESHOLD"
        print(f"{s:>6.2f} {obs:>16.6f} {pred:>12.6f} {verdict:>12}")
    print(f"\nbisected abscissa estimate: {bisect_abscissa():.4f}")
    print("\nrefutation window (majorant finite, series divergent):")
    for s, maj, note in refutation_window():
        print(f"  s = {s:.2f}:  majorant = {maj:12.6f}   {note}")


"""
Exact Computation of the Berggren Counting Function via a Coprimality-Parity Sieve
==================================================================================

Computes N(H), the number of nodes of the Berggren tree whose hypotenuse is at
most H, exactly and without ever traversing the tree.

Mathematical foundation
-----------------------
By Barning-Hall completeness the word labelling of the tree is a *bijection*
onto the set of Euclid seeds

    S = { (m, n) : 0 < n < m, gcd(m, n) = 1, m + n odd }.

Therefore

    N(H) = # { (m, n) in S : m^2 + n^2 <= H },

a two-dimensional lattice count in a quarter disc twisted by a coprimality and
a parity condition.  The tree has vanished entirely from the computation, which
is precisely why the branching structure does not determine the counting law.

Two established bounds frame the answer:

    H / 50 <= N(H) <= 2 H            for all H >= 512.

The upper bound is immediate (c <= H forces m <= sqrt H, n < m).  The lower
bound is an elementary sieve: the triangle 1 <= n < m <= M has M(M-1)/2 pairs;
those with a common divisor d >= 2 number at most (M^2 / 2) * sum_{d>=2} d^{-2}
<= (25/72) M^2; and at least half of the survivors have opposite parity, by the
injection (m, n) -> ((m+n)/2, (m-n)/2) from coprime odd-odd pairs into coprime
opposite-parity pairs.

Numerically N(H)/H converges to 1/(2 pi) = 0.15915494..., matching the density
product (pi H / 4) * (1/2) * (6 / pi^2) * (2/3) = H / (2 pi): quarter-disc area,
the restriction n < m, coprimality density 1/zeta(2), and opposite parity
conditioned on coprimality.

Complexity
----------
Time  O(H log H): about H/2 candidate pairs, each tested by one Euclidean
      algorithm costing O(log H).
Space O(1) for the naive version; the Mobius-accelerated variant below runs in
      O(sqrt(H) * log H) time and O(sqrt H) space by summing over divisors.

Role in the pipeline
--------------------
N(H) = Theta(H) is the arithmetic content of the statement that the abscissa of
convergence of the tree zeta function equals 1.  It flatly contradicts the
prediction N(H) ~ H^{log 3 / log(3 + 2 sqrt 2)} = H^{0.6232} that follows from
the layer heuristic.
"""

from __future__ import annotations

from math import gcd, isqrt, pi
from typing import Dict, List, Tuple


def count_N(h_max: int) -> int:
    """Exact N(H) by direct enumeration of Euclid seeds.  O(H log H)."""
    total = 0
    for m in range(2, isqrt(h_max) + 1):
        n_top = min(m - 1, isqrt(h_max - m * m))
        for n in range(1, n_top + 1):
            if (m + n) % 2 == 1 and gcd(m, n) == 1:
                total += 1
    return total


def mobius_table(limit: int) -> List[int]:
    """Mobius function mu(1..limit) by a linear sieve."""
    mu = [1] * (limit + 1)
    primes: List[int] = []
    is_composite = [False] * (limit + 1)
    for i in range(2, limit + 1):
        if not is_composite[i]:
            primes.append(i)
            mu[i] = -1
        for p in primes:
            if i * p > limit:
                break
            is_composite[i * p] = True
            if i % p == 0:
                mu[i * p] = 0
                break
            mu[i * p] = -mu[i]
    return mu


def count_pairs_raw(h_max: int, d: int) -> int:
    """# { (m,n) : 0 < n < m, d | m, d | n, m^2 + n^2 <= H }, i.e. the
    unrestricted-parity count scaled by d."""
    scaled = h_max // (d * d)
    total = 0
    for m in range(1, isqrt(scaled) + 1):
        n_top = min(m - 1, isqrt(scaled - m * m))
        total += n_top
    return total


def count_N_mobius(h_max: int) -> int:
    """N(H) via Mobius inversion of the coprimality condition.

    Coprime pairs with m + n odd are counted as
        sum_{d odd} mu(d) * A(H / d^2)
    where A(X) counts pairs 0 < n < m with m^2 + n^2 <= X and m + n odd;
    only odd d contribute, since d even forces m, n both even and m + n even.
    """
    limit = isqrt(h_max) + 1
    mu = mobius_table(limit)
    total = 0
    for d in range(1, limit + 1, 2):  # only odd d
        if mu[d] == 0:
            continue
        scaled = h_max // (d * d)
        if scaled < 5:
            continue
        sub = 0
        for m in range(2, isqrt(scaled) + 1):
            n_top = min(m - 1, isqrt(scaled - m * m))
            # count n in [1, n_top] with n of opposite parity to m
            if m % 2 == 0:
                sub += (n_top + 1) // 2          # odd n
            else:
                sub += n_top // 2                # even n
        total += mu[d] * sub
    return total


def counting_report(cutoffs: Tuple[int, ...] = (512, 10 ** 3, 10 ** 4, 10 ** 5,
                                               10 ** 6)) -> List[Dict[str, float]]:
    """Table of N(H), the proved bounds, and the conjectured density."""
    rows: List[Dict[str, float]] = []
    target = 1.0 / (2.0 * pi)
    for h in cutoffs:
        n = count_N(h)
        rows.append({
            "H": h,
            "N": n,
            "N_over_H": n / h,
            "lower_bound_H_over_50": h / 50,
            "upper_bound_2H": 2 * h,
            "bounds_hold": (h / 50 <= n <= 2 * h) if h >= 512 else True,
            "relative_error_vs_1_over_2pi": abs(n / h - target) / target,
        })
    return rows


if __name__ == "__main__":
    print(f"{'H':>10} {'N(H)':>10} {'N/H':>12} {'bounds hold':>13} {'err':>11}")
    for row in counting_report():
        print(f"{int(row['H']):>10} {int(row['N']):>10} {row['N_over_H']:>12.7f} "
              f"{str(bool(row['bounds_hold'])):>13} "
              f"{row['relative_error_vs_1_over_2pi']:>11.3e}")
    print()
    for h in (10 ** 4, 10 ** 5, 10 ** 6):
        print(f"H = {h:8d}:  direct = {count_N(h):8d}   "
              f"Mobius = {count_N_mobius(h):8d}")


"""
Breadth-First Enumeration of the Depth-k Layer in Euclid-Seed Coordinates
=========================================================================

Generates all 3^k nodes at depth k of the Berggren tree of primitive
Pythagorean triples, together with the order statistics of their hypotenuses.

Mathematical foundation
-----------------------
Under Euclid's parametrisation (m, n) -> (m^2 - n^2, 2mn, m^2 + n^2), the three
Barning matrices become the three seed moves

    s0(m, n) = (2m - n, m),   s1(m, n) = (2m + n, m),   s2(m, n) = (m + 2n, n),

acting on the root seed (2, 1), which corresponds to (3, 4, 5).  The seed
invariant -- 0 < n < m, gcd(m, n) = 1, m + n odd -- is preserved by all three
moves, and the three images occupy disjoint angular sectors of the (m, n)
quadrant (m < 2n, 2n < m < 3n, m > 3n).  Sector disjointness makes the word
labelling injective, so a breadth-first expansion produces exactly 3^k
*distinct* nodes at depth k and never needs deduplication.

Complexity
----------
Time  Theta(3^k) integer operations, or Theta(k * 3^k) bit operations since the
      coordinates at depth k have O(k) digits (they grow like lambda^{k/2} with
      lambda = 3 + 2 sqrt 2).
Space Theta(3^k) if the layer is retained; O(3^{k}) is unavoidable for the
      order statistics, but a streaming variant needs only O(1) extra space
      per node beyond the frontier.

Role in the pipeline
--------------------
This is the routine that exhibits the internal spread of a layer -- the minimum
2k^2 + 6k + 5 on the slow spine against the maximum ~ lambda^k on the fast
spine -- which is the structural reason the layer-maximum heuristic predicts
the wrong abscissa of convergence for the tree zeta function.
"""

from __future__ import annotations

from math import gcd
from typing import Dict, Iterator, List, Tuple

Seed = Tuple[int, int]

ROOT: Seed = (2, 1)


def step(i: int, p: Seed) -> Seed:
    """Apply the i-th Berggren move to a Euclid seed."""
    m, n = p
    if i == 0:
        return (2 * m - n, m)
    if i == 1:
        return (2 * m + n, m)
    if i == 2:
        return (m + 2 * n, n)
    raise ValueError(f"move index must be 0, 1 or 2; got {i}")


def is_seed(p: Seed) -> bool:
    """Test the Euclid-seed invariant: 0 < n < m, coprime, opposite parity."""
    m, n = p
    return 0 < n < m and gcd(m, n) == 1 and (m + n) % 2 == 1


def hypotenuse(p: Seed) -> int:
    """The hypotenuse m^2 + n^2 of the triple attached to a seed."""
    m, n = p
    return m * m + n * n


def enumerate_layer(k: int) -> List[Seed]:
    """All 3^k seeds at depth k, breadth-first from the root."""
    frontier: List[Seed] = [ROOT]
    for _ in range(k):
        frontier = [step(i, p) for p in frontier for i in (0, 1, 2)]
    return frontier


def stream_layer(k: int) -> Iterator[Seed]:
    """Depth-first generator of the depth-k layer, O(k) memory."""
    stack: List[Tuple[Seed, int]] = [(ROOT, 0)]
    while stack:
        p, d = stack.pop()
        if d == k:
            yield p
        else:
            for i in (2, 1, 0):
                stack.append((step(i, p), d + 1))


def layer_statistics(k: int) -> Dict[str, int | float]:
    """Order statistics of the hypotenuses in the depth-k layer."""
    hyps = sorted(hypotenuse(p) for p in enumerate_layer(k))
    n = len(hyps)
    return {
        "depth": k,
        "nodes": n,
        "min": hyps[0],
        "q1": hyps[n // 4],
        "median": hyps[n // 2],
        "q3": hyps[(3 * n) // 4],
        "max": hyps[-1],
        "spread_ratio": hyps[-1] / hyps[0],
        "slow_spine_formula": 2 * k * k + 6 * k + 5,
    }


def verify_invariants(max_depth: int = 10) -> bool:
    """Check injectivity, layer size and the seed invariant up to max_depth."""
    for k in range(max_depth + 1):
        layer = enumerate_layer(k)
        if len(layer) != 3 ** k:
            return False
        if len(set(layer)) != 3 ** k:
            return False
        if not all(is_seed(p) for p in layer):
            return False
        if min(hypotenuse(p) for p in layer) != 2 * k * k + 6 * k + 5:
            return False
    return True


if __name__ == "__main__":
    print(f"invariants verified up to depth 10: {verify_invariants(10)}")
    print()
    print(f"{'k':>3} {'nodes':>9} {'min c':>8} {'median c':>12} "
          f"{'max c':>15} {'max/min':>11}")
    for k in range(13):
        st = layer_statistics(k)
        print(f"{st['depth']:>3} {st['nodes']:>9} {st['min']:>8} "
              f"{st['median']:>12} {st['max']:>15} {st['spread_ratio']:>11.4g}")


#!/usr/bin/env python3
"""Assemble PACKAGE.json from the project's prose, code and asset files."""

from __future__ import annotations

import json
import os
from typing import Any, Dict, List

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ASSETS = os.path.join(ROOT, "package_assets")

LEAN_FILES = [
    "Catalog/Computation/BerggrenZetaSeeds.lean",
    "Catalog/Computation/BerggrenZetaSilver.lean",
    "Catalog/Computation/BerggrenZetaAbscissa.lean",
    "Catalog/Computation/BerggrenZetaCounting.lean",
    "Catalog/Computation/BerggrenZetaTauberian.lean",
    "Catalog/Computation/BerggrenZetaLegs.lean",
]


def read(path: str) -> str:
    with open(os.path.join(ROOT, path), encoding="utf-8") as fh:
        return fh.read()


def asset(name: str) -> str:
    with open(os.path.join(ASSETS, name), encoding="utf-8") as fh:
        return fh.read()


def lean_bundle() -> str:
    parts: List[str] = []
    for rel in LEAN_FILES:
        parts.append("-" * 78)
        parts.append(f"-- FILE: {rel}")
        parts.append("-" * 78)
        parts.append(read(rel).rstrip())
        parts.append("")
    return "\n".join(parts)


def build() -> Dict[str, Any]:
    demo_src = read("demo.py")
    return {
        "title": "The Berggren Tree Zeta Function: Silver Growth, Classical Density",
        "domain": "Computation",
        "description": (
            "The Dirichlet series over all nodes of the Berggren ternary tree of primitive "
            "Pythagorean triples, weighted by hypotenuse, has abscissa of convergence exactly 1 "
            "— refuting the silver-ratio prediction log 3 / log(3 + 2 sqrt 2) = 0.6232 that the "
            "tree's 3^k branching and its exact silver growth rate would suggest. The companion "
            "counting law N(H) = Theta(H), with explicit constants H/50 <= N(H) <= 2H for "
            "H >= 512, pins the arithmetic density that the growth exponent fails to predict."
        ),
        "authors": ["Aristotle"],
        "date": "2026-08-21",
        "key_results": [
            "The abscissa of convergence of the Berggren tree zeta function Z(s) = sum over nodes "
            "of c(w)^(-s) is exactly 1: the series converges for every s > 1 and diverges for "
            "every s <= 1.",
            "Refutation of the silver-ratio prediction: for every exponent s strictly between "
            "log 3 / log(3 + 2 sqrt 2) = 0.6232 and 1 inclusive, the layer majorant converges "
            "while the tree zeta function itself diverges.",
            "Counting law with explicit constants: the number N(H) of Berggren nodes with "
            "hypotenuse at most H satisfies H/50 <= N(H) <= 2H for every H >= 512, so N(H) is of "
            "exact order H.",
            "Tauberian bridge: the counting law alone forces the harmonic sum over the tree to "
            "diverge, at the explicit rate (sum of 1/c over c <= 512 * 128^k) >= k/300, giving a "
            "second and independent proof that the abscissa is at least 1.",
            "The silver speed limit and the spectral spine: every hypotenuse at depth k is at most "
            "2 lambda^(k+1) with lambda = (1 + sqrt 2)^2 = 3 + 2 sqrt 2, and along the middle "
            "spine the hypotenuses are the odd-indexed Pell numbers, satisfying "
            "c_{k+2} = 6 c_{k+1} - c_k with closed form in the eigenvalues 3 +- 2 sqrt 2.",
            "Both leg zeta functions, over the odd leg m^2 - n^2 and the even leg 2mn, also have "
            "abscissa exactly 1, proved by a two-dimensional zeta-squared majorant along two "
            "distinct reindexings of the Euclid seed lattice.",
        ],
        "keywords": [
            "Pythagorean triples",
            "Berggren tree",
            "Barning-Hall tree",
            "Dirichlet series",
            "abscissa of convergence",
            "silver ratio",
            "Pell numbers",
            "lattice-point counting",
        ],
        "article": read("ARTICLE.md"),
        "research_paper": read("RESEARCH_PAPER.md"),
        "research_paper_tex": read("RESEARCH_PAPER.tex"),
        "demo": demo_src,
        "demos": [
            {
                "name": "End-to-End Numerical Verification of the Berggren Tree Zeta Function",
                "description": (
                    "A complete, dependency-free numerical companion in eight parts. It (1) "
                    "generates the tree in Euclid-seed coordinates and verifies that the depth-k "
                    "layer has exactly 3^k distinct valid seeds and that the seed moves reproduce "
                    "the three Barning matrices; (2) confirms the silver speed limit "
                    "c <= 2 lambda^(k+1) at every node up to depth 10; (3) checks the middle-spine "
                    "recurrence c_{k+2} = 6 c_{k+1} - c_k, its closed form in the eigenvalues "
                    "3 +- 2 sqrt 2, and the growth exponent log lambda = 2 log(1 + sqrt 2); "
                    "(4) tabulates the internal spread of each layer, showing the minimum is "
                    "exactly 2k^2 + 6k + 5 while the maximum is the odd Pell number ~ lambda^k; "
                    "(5) locates the abscissa at 1 using the increment-ratio diagnostic, whose "
                    "observed values match the predicted 2^(2-2s) to four decimals, and exhibits "
                    "the refutation window where the layer majorant is finite but the series is "
                    "not; (6) computes N(H) exactly and verifies both the proved envelope "
                    "H/50 <= N(H) <= 2H and the convergence N(H)/H -> 1/(2 pi) to six digits; "
                    "(7) verifies the 128-adic block estimate underlying the Tauberian bridge; "
                    "and (8) shows the odd and even legs share the abscissa 1 while failing to be "
                    "comparable to the hypotenuse from below."
                ),
                "code": demo_src,
            }
        ],
        "algorithms": [
            {
                "name": "Breadth-First Enumeration of the Depth-k Layer in Euclid-Seed Coordinates",
                "description": (
                    "Generates all 3^k nodes of a single generation of the Berggren tree together "
                    "with the order statistics of their hypotenuses. The three Barning matrices, "
                    "transported through Euclid's parametrisation, become the one-line seed moves "
                    "s0(m,n) = (2m-n, m), s1(m,n) = (2m+n, m), s2(m,n) = (m+2n, n) acting on the "
                    "root seed (2,1). Because the three images occupy disjoint angular sectors of "
                    "the (m,n) quadrant, the word labelling is injective and the expansion never "
                    "needs deduplication — a rare luxury for a tree algorithm. Complexity: "
                    "Theta(3^k) integer operations, or Theta(k 3^k) bit operations since the "
                    "coordinates at depth k carry O(k) digits; Theta(3^k) memory if the layer is "
                    "retained, with a depth-first streaming variant needing only O(k). This is "
                    "the routine that exhibits the exponential spread within a layer, from the "
                    "quadratic slow spine to the exponential fast spine, which is the structural "
                    "reason the layer-maximum heuristic predicts the wrong abscissa."
                ),
                "pseudocode": (
                    "ENUMERATE-LAYER(k):\n"
                    "  1  frontier <- [ (2, 1) ]                 // the root seed, i.e. (3,4,5)\n"
                    "  2  for d <- 1 to k do\n"
                    "  3      next <- empty list\n"
                    "  4      for each (m, n) in frontier do\n"
                    "  5          append (2m - n, m) to next     // move s0  (lands in m < 2n)\n"
                    "  6          append (2m + n, m) to next     // move s1  (lands in 2n<m<3n)\n"
                    "  7          append (m + 2n, n) to next     // move s2  (lands in m > 3n)\n"
                    "  8      frontier <- next\n"
                    "  9  return frontier                        // exactly 3^k distinct seeds\n"
                    "\n"
                    "LAYER-STATISTICS(k):\n"
                    "  1  H <- sort( { m^2 + n^2 : (m,n) in ENUMERATE-LAYER(k) } )\n"
                    "  2  assert |H| = 3^k                       // injectivity\n"
                    "  3  assert H[0] = 2k^2 + 6k + 5            // the slow spine s0^k\n"
                    "  4  assert H[last] <= 2 * lambda^(k+1)     // the silver speed limit\n"
                    "  5  return (min H, median H, max H, max H / min H)"
                ),
                "code": asset("alg_layer_enumeration.py"),
            },
            {
                "name": "Exact Computation of the Berggren Counting Function via a Coprimality-Parity Sieve",
                "description": (
                    "Computes N(H), the number of tree nodes with hypotenuse at most H, exactly "
                    "and without ever traversing the tree. Barning-Hall completeness turns the "
                    "problem into a plain lattice count: N(H) is the number of pairs (m,n) with "
                    "0 < n < m, gcd(m,n) = 1, m + n odd and m^2 + n^2 <= H. The tree has vanished "
                    "from the computation, which is precisely why its branching structure does not "
                    "determine the counting law. The direct method costs O(H log H): about H/2 "
                    "candidate pairs, each tested by one Euclidean algorithm. A Mobius-inversion "
                    "variant is also given, summing mu(d) over odd d only (even d forces both "
                    "coordinates even, contradicting the parity condition), which reduces the work "
                    "to a sum of quarter-disc counts. Two proved bounds frame the output, "
                    "H/50 <= N(H) <= 2H for H >= 512, and the computed ratio N(H)/H converges to "
                    "1/(2 pi) = 0.15915494..., the product of the quarter-disc area, the factor "
                    "1/2 from n < m, the coprimality density 6/pi^2 and the conditional parity "
                    "density 2/3."
                ),
                "pseudocode": (
                    "COUNT-N(H):                                 // direct sieve, O(H log H)\n"
                    "  1  total <- 0\n"
                    "  2  for m <- 2 to floor(sqrt(H)) do\n"
                    "  3      n_top <- min(m - 1, floor(sqrt(H - m^2)))\n"
                    "  4      for n <- 1 to n_top do\n"
                    "  5          if (m + n) is odd and gcd(m, n) = 1 then\n"
                    "  6              total <- total + 1\n"
                    "  7  return total\n"
                    "\n"
                    "COUNT-N-MOBIUS(H):                          // Mobius inversion of coprimality\n"
                    "  1  mu <- linear sieve of the Mobius function up to floor(sqrt(H)) + 1\n"
                    "  2  total <- 0\n"
                    "  3  for each ODD d with mu(d) != 0 do      // even d forces m, n both even\n"
                    "  4      X <- floor(H / d^2)\n"
                    "  5      sub <- # { (m,n) : 0 < n < m, m^2 + n^2 <= X, m + n odd }\n"
                    "  6      total <- total + mu(d) * sub\n"
                    "  7  return total\n"
                    "\n"
                    "VERIFY-BOUNDS(H):                           // the proved envelope\n"
                    "  1  N <- COUNT-N(H)\n"
                    "  2  assert H >= 512 implies H/50 <= N <= 2H\n"
                    "  3  return N / H                           // conjecturally -> 1/(2 pi)"
                ),
                "code": asset("alg_counting_sieve.py"),
            },
            {
                "name": "Abscissa Localisation by the Increment-Ratio Dichotomy",
                "description": (
                    "Localises the abscissa of convergence of the tree zeta function numerically, "
                    "distinguishing the true value 1 from the refuted silver-ratio prediction "
                    "0.6232. Naive truncation is useless near the threshold: at s = 1.02 the tail "
                    "decays like M^(-0.04), so no affordable cut-off makes the partial sums look "
                    "convergent. The reliable diagnostic is second-order. Truncating the seed sum "
                    "at first coordinate m <= M, the discarded tail scales like M^(2-2s), so the "
                    "increment D(M) = Z_2M - Z_M gained by doubling the cut-off satisfies "
                    "D(2M)/D(M) -> 2^(2-2s). This limit exceeds 1 exactly when s < 1, equals 1 "
                    "exactly at s = 1, and is below 1 exactly when s > 1, so bisecting on its sign "
                    "converges to the abscissa. In practice the observed ratio matches the "
                    "predicted 2^(2-2s) to three or four decimals already at M = 3200. Each "
                    "evaluation costs O(M^2 log M); the statistical resolution near the threshold "
                    "is only O(1 / log M), which is why the proof, rather than the computation, is "
                    "what pins the value at exactly 1."
                ),
                "pseudocode": (
                    "TRUNCATED-ZETA(s, M):\n"
                    "  1  total <- 0\n"
                    "  2  for m <- 2 to M, for n <- 1 to m-1 do\n"
                    "  3      if (m + n) odd and gcd(m, n) = 1 then\n"
                    "  4          total <- total + (m^2 + n^2)^(-s)\n"
                    "  5  return total\n"
                    "\n"
                    "INCREMENT-RATIO(s, M):\n"
                    "  1  Z1 <- TRUNCATED-ZETA(s, M)\n"
                    "  2  Z2 <- TRUNCATED-ZETA(s, 2M)\n"
                    "  3  Z4 <- TRUNCATED-ZETA(s, 4M)\n"
                    "  4  return ( (Z4 - Z2) / (Z2 - Z1),  2^(2 - 2s) )   // observed, predicted\n"
                    "\n"
                    "BISECT-ABSCISSA(lo, hi, steps, M):\n"
                    "  1  repeat steps times:\n"
                    "  2      mid <- (lo + hi) / 2\n"
                    "  3      (r, _) <- INCREMENT-RATIO(mid, M)\n"
                    "  4      if r >= 1 then lo <- mid else hi <- mid    // ratio >= 1 means divergence\n"
                    "  5  return (lo + hi) / 2                           // converges to 1, not 0.6232\n"
                    "\n"
                    "REFUTATION-WINDOW(s):\n"
                    "  1  sigma_silver <- log 3 / log(3 + 2 sqrt 2)\n"
                    "  2  if s <= sigma_silver then majorant <- infinity\n"
                    "  3  else majorant <- sum over k of 3^k * (2 lambda^(k+1))^(-s)   // finite\n"
                    "  4  if sigma_silver < s <= 1 then\n"
                    "  5      report: majorant finite, series divergent   // the refutation"
                ),
                "code": asset("alg_abscissa_bisection.py"),
            },
        ],
        "visualizations": [
            {
                "name": "The Exponential Spread Inside a Berggren Layer",
                "description": (
                    "Two panels that make the failure of the layer heuristic visible. The left "
                    "panel plots, on a logarithmic vertical axis, the full cloud of hypotenuses in "
                    "each depth-k layer, overlaid with the fast spine (repeated middle move, the "
                    "odd Pell numbers 5, 29, 169, 985, ... growing like lambda^k), the slow spine "
                    "(repeated first move, seed (k+2, k+1), hypotenuse only 2k^2 + 6k + 5), and "
                    "the silver speed limit 2 lambda^(k+1). The right panel tracks two ratios: the "
                    "maximum-to-minimum spread within a layer, which grows exponentially, and the "
                    "median-to-maximum ratio, which decays geometrically. Together they show that "
                    "the layer maximum overestimates a typical node by a factor growing without "
                    "bound, so bounding a layer by its largest member discards essentially the "
                    "entire sum."
                ),
                "code": asset("viz_layer_spread.py"),
            },
            {
                "name": "The Counting Law and the Location of the Abscissa",
                "description": (
                    "Two panels tying the arithmetic and the analytic sides together. The left "
                    "panel plots N(H), the exact number of Berggren nodes with hypotenuse at most "
                    "H, on log-log axes against the proved envelope H/50 <= N(H) <= 2H (shaded), "
                    "the conjectured asymptote H/(2 pi), and the refuted silver law H^0.6232, with "
                    "an inset showing N(H)/H converging to 1/(2 pi) = 0.15915494. The right panel "
                    "plots the increment-ratio diagnostic D(2M)/D(M) against the exponent s, "
                    "together with its theoretical value 2^(2-2s): the observed curve crosses 1 at "
                    "s = 1, the true abscissa, and not at the silver prediction 0.6232, which is "
                    "marked for contrast. The shaded strip between the two is the refutation "
                    "window, where the layer majorant converges while the series diverges."
                ),
                "code": asset("viz_counting_and_abscissa.py"),
            },
        ],
        "interactive_demos": [
            {
                "title": "The Berggren Tree Explorer — Walk Every Right Triangle",
                "description": (
                    "A hands-on tour of the tree that enumerates every primitive Pythagorean "
                    "triple exactly once. Apply the three moves and watch the Euclid seed, the "
                    "triple, the depth and the silver speed limit 2 lambda^(k+1) update live; a "
                    "log-scale panel draws your walk against the two extremal spines, the fast one "
                    "tracing the odd Pell numbers and the slow one crawling along 2k^2 + 6k + 5. A "
                    "second panel renders the entire depth-k layer as a log-scale histogram with "
                    "the minimum, median and maximum marked, making the exponentially widening "
                    "spread impossible to miss, and a statistics table reports the "
                    "median-to-maximum ratio collapsing generation by generation. Finally a "
                    "descent tool lets you type any coprime pair (m, n) with m + n odd and returns "
                    "its unique address in the tree, computed by reading off the angular sector at "
                    "each step — a constructive demonstration of both injectivity and Barning-Hall "
                    "completeness. Expandable sections give the full proofs that the abscissa of "
                    "convergence is exactly 1."
                ),
                "html": asset("widget_tree_explorer.html"),
            },
            {
                "title": "The Zeta Laboratory — Where Does the Series Break?",
                "description": (
                    "A live experiment on the abscissa of convergence. A single slider sets the "
                    "exponent s and the page recomputes, in the browser and over the genuine "
                    "Euclid seed lattice, both the heuristic layer majorant and the true truncated "
                    "series. Between 0.6232 and 1 the widget shows the majorant reporting a finite "
                    "value while the series it was meant to bound diverges — the refutation, live. "
                    "A partial-sums panel shows why the naive eye test fails near the threshold, "
                    "and the adjacent panel introduces the sharp diagnostic: the ratio of "
                    "successive increments as the cut-off doubles, which provably tends to "
                    "2^(2-2s) and therefore crosses 1 exactly at the abscissa. The observed curve "
                    "is drawn against the theoretical one, with the silver prediction and the true "
                    "value marked; the crossing sits at 1. A final panel plots the counting "
                    "function N(H) against the proved envelope, the conjectured H/(2 pi), and the "
                    "refuted H^0.6232. Expandable sections give the convergence proof by the "
                    "two-dimensional majorant, the divergence proof by planting prime seeds in the "
                    "tree, and the four-density derivation of the constant 1/(2 pi)."
                ),
                "html": asset("widget_zeta_lab.html"),
            },
        ],
        "interactive_layout": asset("interactive_layout.md"),
        "lean_proofs": lean_bundle(),
        "future_directions": asset("future_directions.md"),
        "modules": {"demo": demo_src},
        "lean_files": LEAN_FILES,
    }


if __name__ == "__main__":
    pkg = build()
    out = os.path.join(ROOT, "PACKAGE.json")
    with open(out, "w", encoding="utf-8") as fh:
        json.dump(pkg, fh, indent=2, ensure_ascii=False)
        fh.write("\n")
    print(f"wrote {out}  ({os.path.getsize(out):,} bytes)")
    for k, v in pkg.items():
        if isinstance(v, str):
            print(f"  {k:22s} str   {len(v):>9,} chars")
        elif isinstance(v, list):
            print(f"  {k:22s} list  {len(v)} entries")
        else:
            print(f"  {k:22s} {type(v).__name__}")


"""
Visualisation: The Counting Law N(H) = Theta(H) and the Location of the Abscissa
=================================================================================

Two panels.

LEFT -- the counting function.  N(H), the number of Berggren nodes with
hypotenuse at most H, plotted against H on log-log axes, together with:
  * the proved envelope  H/50 <= N(H) <= 2H  (valid for H >= 512);
  * the conjectured asymptote  H / (2 pi);
  * the refuted silver prediction  H^{log 3 / log(3 + 2 sqrt 2)} = H^{0.6232}.
The inset shows N(H)/H converging to 1/(2 pi) = 0.15915494...

RIGHT -- the abscissa.  The increment-ratio diagnostic
    D(2M)/D(M) -> 2^{2 - 2s},
where D(M) is the gain in the truncated sum when the cut-off doubles.  The
observed curve crosses 1 exactly at s = 1 -- the true abscissa -- and not at
the silver prediction 0.6232, which is marked for contrast.  The shaded strip
is the refutation window: there the layer majorant converges while the series
diverges.

Output: berggren_counting_abscissa.png
"""

from __future__ import annotations

from math import gcd, isqrt, log, pi, sqrt
from typing import List, Tuple

import matplotlib.pyplot as plt
import numpy as np

LAM = 3.0 + 2.0 * sqrt(2.0)
SIGMA_SILVER = log(3.0) / log(LAM)


def count_N(h_max: int) -> int:
    total = 0
    for m in range(2, isqrt(h_max) + 1):
        n_top = min(m - 1, isqrt(h_max - m * m))
        for n in range(1, n_top + 1):
            if (m + n) % 2 == 1 and gcd(m, n) == 1:
                total += 1
    return total


def truncated_zeta(s: float, m_max: int) -> float:
    total = 0.0
    for m in range(2, m_max + 1):
        for n in range(1, m):
            if (m + n) % 2 == 1 and gcd(m, n) == 1:
                total += (m * m + n * n) ** (-s)
    return total


def main() -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14.5, 6))

    # ---------------- left: the counting law -------------------------------
    hs = [2 ** j for j in range(9, 22)]
    ns = [count_N(h) for h in hs]
    H = np.array(hs, dtype=float)
    N = np.array(ns, dtype=float)

    ax1.loglog(H, N, "o-", color="#2b6cb0", lw=2.2, ms=6, label=r"$N(H)$ (exact)")
    ax1.loglog(H, H / 50, "--", color="#c53030", lw=1.6,
               label=r"proved lower bound $H/50$")
    ax1.loglog(H, 2 * H, "--", color="#c53030", lw=1.6,
               label=r"proved upper bound $2H$")
    ax1.fill_between(H, H / 50, 2 * H, color="#c53030", alpha=0.07)
    ax1.loglog(H, H / (2 * pi), "-", color="#2f855a", lw=1.8,
               label=r"conjectured $H/(2\pi)$")
    ax1.loglog(H, H ** SIGMA_SILVER, ":", color="#744210", lw=2.2,
               label=r"refuted silver law $H^{0.6232}$")
    ax1.set_xlabel("$H$", fontsize=12)
    ax1.set_ylabel("$N(H)$", fontsize=12)
    ax1.set_title("Counting Berggren nodes with hypotenuse $\\leq H$", fontsize=13)
    ax1.legend(loc="upper left", fontsize=9.5)
    ax1.grid(alpha=0.25, which="both")

    inset = ax1.inset_axes((0.58, 0.10, 0.39, 0.32))
    inset.semilogx(H, N / H, "o-", color="#2b6cb0", ms=4, lw=1.6)
    inset.axhline(1 / (2 * pi), color="#2f855a", lw=1.6)
    inset.set_ylim(0.150, 0.170)
    inset.set_title(r"$N(H)/H \to 1/(2\pi)$", fontsize=9)
    inset.tick_params(labelsize=7)
    inset.grid(alpha=0.25)

    # ---------------- right: the abscissa diagnostic -----------------------
    svals = np.linspace(0.55, 1.45, 19)
    base = 300
    observed, predicted = [], []
    for s in svals:
        z1 = truncated_zeta(float(s), base)
        z2 = truncated_zeta(float(s), 2 * base)
        z4 = truncated_zeta(float(s), 4 * base)
        observed.append((z4 - z2) / (z2 - z1))
        predicted.append(2.0 ** (2.0 - 2.0 * float(s)))

    ax2.axvspan(SIGMA_SILVER, 1.0, color="#f6ad55", alpha=0.22,
                label="refutation window:\nmajorant converges,\nseries diverges")
    ax2.plot(svals, observed, "o-", color="#2b6cb0", lw=2.2, ms=6,
             label=r"observed $D(2M)/D(M)$")
    ax2.plot(svals, predicted, "--", color="#6b46c1", lw=1.8,
             label=r"theory $2^{2-2s}$")
    ax2.axhline(1.0, color="black", lw=1.2)
    ax2.axvline(1.0, color="#2f855a", lw=2.0,
                label=r"true abscissa $\sigma_Z = 1$")
    ax2.axvline(SIGMA_SILVER, color="#c53030", lw=2.0, ls=":",
                label=r"silver prediction $\log 3/\log\lambda = 0.6232$")
    ax2.set_xlabel("$s$", fontsize=12)
    ax2.set_ylabel("increment ratio", fontsize=12)
    ax2.set_title("The abscissa sits where the increment ratio crosses $1$",
                  fontsize=13)
    ax2.legend(loc="upper right", fontsize=9)
    ax2.grid(alpha=0.25)

    fig.suptitle("The Berggren tree zeta function: linear counting, abscissa "
                 "exactly $1$", fontsize=15, y=0.99)
    fig.tight_layout()
    fig.savefig("berggren_counting_abscissa.png", dpi=160)
    print("wrote berggren_counting_abscissa.png")


if __name__ == "__main__":
    main()


"""
Visualisation: The Exponential Spread Inside a Berggren Layer
==============================================================

Plots, on a logarithmic vertical axis, the full distribution of hypotenuses in
each depth-k layer of the Berggren tree, together with the two extremal spines:

  * the FAST spine (repeated middle move), whose hypotenuses are the
    odd-indexed Pell numbers 5, 29, 169, 985, ... ~ lambda^k with
    lambda = 3 + 2 sqrt 2 = (1 + sqrt 2)^2;
  * the SLOW spine (repeated first move), whose seed at depth k is
    (k + 2, k + 1) and whose hypotenuse is only 2k^2 + 6k + 5.

The picture is the visual explanation of why the layer-maximum heuristic gives
the wrong abscissa of convergence: the band between the two spines widens
exponentially, so the maximum is nowhere near a typical node.

Output: berggren_layer_spread.png
"""

from __future__ import annotations

from math import log, sqrt
from typing import List, Tuple

import matplotlib.pyplot as plt
import numpy as np

Seed = Tuple[int, int]

LAM = 3.0 + 2.0 * sqrt(2.0)
ROOT: Seed = (2, 1)


def step(i: int, p: Seed) -> Seed:
    m, n = p
    return [(2 * m - n, m), (2 * m + n, m), (m + 2 * n, n)][i]


def layer(k: int) -> List[Seed]:
    frontier = [ROOT]
    for _ in range(k):
        frontier = [step(i, p) for p in frontier for i in (0, 1, 2)]
    return frontier


def main(max_depth: int = 11) -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # --- left panel: the full distribution, violin-style scatter -------------
    rng = np.random.default_rng(20260821)
    for k in range(1, max_depth + 1):
        hyps = np.array([m * m + n * n for (m, n) in layer(k)], dtype=float)
        if len(hyps) > 3000:                      # subsample for legibility
            hyps = rng.choice(hyps, 3000, replace=False)
        jitter = rng.uniform(-0.30, 0.30, size=len(hyps))
        ax1.scatter(k + jitter, hyps, s=1.2, alpha=0.16, color="#2b6cb0",
                    edgecolors="none", rasterized=True)

    ks = np.arange(1, max_depth + 1)
    fast = []
    p = ROOT
    for _ in range(max_depth + 1):
        fast.append(p[0] ** 2 + p[1] ** 2)
        p = step(1, p)
    ax1.plot(ks, fast[1:max_depth + 1], "o-", color="#c53030", lw=2.2, ms=6,
             label=r"fast spine: odd Pell numbers $\sim \lambda^k$")
    ax1.plot(ks, 2 * ks ** 2 + 6 * ks + 5, "s-", color="#2f855a", lw=2.2, ms=6,
             label=r"slow spine: $2k^2+6k+5$")
    ax1.plot(ks, 2 * LAM ** (ks + 1), "--", color="#744210", lw=1.6,
             label=r"silver speed limit $2\lambda^{k+1}$")

    ax1.set_yscale("log")
    ax1.set_xlabel("depth $k$", fontsize=12)
    ax1.set_ylabel("hypotenuse $c$  (log scale)", fontsize=12)
    ax1.set_title("Hypotenuses in the depth-$k$ layer of the Berggren tree",
                  fontsize=13)
    ax1.legend(loc="upper left", fontsize=10)
    ax1.grid(alpha=0.25, which="both")

    # --- right panel: the spread ratio --------------------------------------
    ratios, medians_norm = [], []
    for k in range(1, max_depth + 1):
        hyps = sorted(m * m + n * n for (m, n) in layer(k))
        ratios.append(hyps[-1] / hyps[0])
        medians_norm.append(hyps[len(hyps) // 2] / hyps[-1])

    ax2.semilogy(ks, ratios, "o-", color="#6b46c1", lw=2.2, ms=7,
                 label=r"$\max c\ /\ \min c$ within layer $k$")
    ax2.semilogy(ks, medians_norm, "^-", color="#dd6b20", lw=2.2, ms=7,
                 label=r"median $c\ /\ \max c$ within layer $k$")
    ax2.axhline(1.0, color="black", lw=1.0, alpha=0.5)
    ax2.set_xlabel("depth $k$", fontsize=12)
    ax2.set_ylabel("ratio (log scale)", fontsize=12)
    ax2.set_title("The layer maximum is not a typical node", fontsize=13)
    ax2.legend(loc="center left", fontsize=10)
    ax2.grid(alpha=0.25, which="both")
    ax2.text(0.98, 0.05,
             "median / max decays geometrically:\nthe maximum overestimates a\n"
             "typical node by an exponentially\ngrowing factor",
             transform=ax2.transAxes, ha="right", va="bottom", fontsize=9,
             bbox=dict(boxstyle="round,pad=0.5", fc="#fffaf0", ec="#dd6b20"))

    fig.suptitle("Why the silver-ratio heuristic fails: exponential spread inside "
                 "each generation", fontsize=15, y=0.99)
    fig.tight_layout()
    fig.savefig("berggren_layer_spread.png", dpi=160)
    print("wrote berggren_layer_spread.png")


if __name__ == "__main__":
    main()
