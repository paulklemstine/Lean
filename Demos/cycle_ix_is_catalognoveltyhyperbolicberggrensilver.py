"""
Numerical demonstration of the metric growth theory of the Berggren tree
of primitive Pythagorean triples.

Everything is self-contained: no imports beyond the standard library.

Setting
-------
A *seed* is a pair (m, n) of integers with m > n > 0, gcd(m, n) = 1 and
m, n of opposite parity.  It encodes the primitive Pythagorean triple

        a = m^2 - n^2,   b = 2mn,   c = m^2 + n^2.

The Berggren tree is rooted at the seed (2, 1)  (the triple (3, 4, 5)) and
each node has three children given by

        B1(m, n) = (2m - n, m)
        B2(m, n) = (2m + n, m)      <-- the only expanding move
        B3(m, n) = (m + 2n, n)

Each node is placed in the hyperbolic upper half-plane at z(m,n) = (n+i)/m,
and the hyperbolic distance to the base point i satisfies the WINDOW LEMMA

        log m  <=  d(i, z(m,n))  <=  log m + log 2,

with  cosh d = (m^2 + n^2 + 1) / (2m)  exactly.

The results demonstrated below:

  1.  Window lemma, verified numerically over the whole tree to depth 8.
  2.  The silver potential  Phi(m,n) = m + (sqrt2 - 1) n  satisfies
      Phi(B2 v) = (1+sqrt2) Phi(v) exactly, and Phi(B1 v), Phi(B3 v) are
      strictly smaller than (1+sqrt2) Phi(v), with slack >= sqrt2.
  3.  max Phi over depth k equals (1+sqrt2)^(k+1), attained uniquely on the
      Pell spine; every other node is below by at least sqrt2.
  4.  max m / (1+sqrt2)^(k+1) -> (2+sqrt2)/4 = 0.8535534..., NOT 1/sqrt2.
  5.  Two paths with identical middle-move frequency 1/2 have different
      rates:  (1/2) log(2+sqrt5) = 0.7218...  vs  (1/2) log(2+sqrt3) = 0.6585...
  6.  The two-parameter family (B2^a B3^b)^oo, a odd, has exact rate
      log sigma(a,b)/(a+b), sigma the dominant root of x^2 = T x + 1 with
      T = P_{a+1} + 2 b P_a + P_{a-1};  these rates are dense in
      [0, log(1+sqrt2)].
  7.  Depth versus hypotenuse:  a node with hypotenuse >= N has depth at
      least (log N - log 2)/(2 log(1+sqrt2)) - 1, and the Pell spine meets
      that bound up to an additive constant.
"""

from __future__ import annotations

import math
from itertools import product
from typing import Dict, Iterator, List, Tuple

Seed = Tuple[int, int]

SQRT2: float = math.sqrt(2.0)
SILVER: float = 1.0 + SQRT2                 # lambda = 1 + sqrt(2)
LOG_SILVER: float = math.log(SILVER)        # 0.8813735870...


# --------------------------------------------------------------------------
# 1.  The tree
# --------------------------------------------------------------------------

def b1(v: Seed) -> Seed:
    """First Berggren move (parabolic, fixed slope 1)."""
    m, n = v
    return (2 * m - n, m)


def b2(v: Seed) -> Seed:
    """Middle Berggren move (hyperbolic, attracting slope 1 + sqrt 2)."""
    m, n = v
    return (2 * m + n, m)


def b3(v: Seed) -> Seed:
    """Third Berggren move (parabolic at infinity)."""
    m, n = v
    return (m + 2 * n, n)


MOVES: Dict[str, "object"] = {"B1": b1, "B2": b2, "B3": b3}
ROOT: Seed = (2, 1)


def triple(v: Seed) -> Tuple[int, int, int]:
    """The primitive Pythagorean triple encoded by a seed."""
    m, n = v
    return (m * m - n * n, 2 * m * n, m * m + n * n)


def hypot(v: Seed) -> int:
    m, n = v
    return m * m + n * n


def run(word: str) -> Seed:
    """Apply a whitespace-separated word of moves to the root."""
    v = ROOT
    for letter in word.split():
        v = MOVES[letter](v)  # type: ignore[operator]
    return v


def nodes_at_depth(k: int) -> Iterator[Tuple[Tuple[str, ...], Seed]]:
    """All 3^k nodes at depth k, with their addresses."""
    for word in product(("B1", "B2", "B3"), repeat=k):
        v = ROOT
        for letter in word:
            v = MOVES[letter](v)  # type: ignore[operator]
        yield word, v


# --------------------------------------------------------------------------
# 2.  Hyperbolic geometry
# --------------------------------------------------------------------------

def hyperbolic_distance(v: Seed) -> float:
    """d(i, z(m,n)) with z(m,n) = (n + i)/m."""
    m, n = v
    return math.acosh((m * m + n * n + 1.0) / (2.0 * m))


def window_defect(v: Seed) -> Tuple[float, float]:
    """(d - log m, log m + log 2 - d); both must be >= 0."""
    m, _ = v
    d = hyperbolic_distance(v)
    return (d - math.log(m), math.log(m) + math.log(2.0) - d)


def pot(v: Seed) -> float:
    """The silver potential Phi(m,n) = m + (sqrt2 - 1) n."""
    m, n = v
    return m + (SQRT2 - 1.0) * n


# --------------------------------------------------------------------------
# 3.  Pell numbers, spine, and the exact rates
# --------------------------------------------------------------------------

def pell(k: int) -> int:
    """P_0 = 0, P_1 = 1, P_{k+2} = 2 P_{k+1} + P_k."""
    a, b = 0, 1
    for _ in range(k):
        a, b = b, 2 * b + a
    return a


def pell_prev(a: int) -> int:
    """P_{a-1} with the convention P_{-1} = 1."""
    return 1 if a == 0 else pell(a - 1)


def spine(k: int) -> Seed:
    """Depth-k node of the pure-B2 (Pell) spine: (P_{k+2}, P_{k+1})."""
    return (pell(k + 2), pell(k + 1))


def trace_G(a: int, b: int) -> int:
    """T(a,b) = P_{a+1} + 2 b P_a + P_{a-1} = trace of M^a R^b."""
    return pell(a + 1) + 2 * b * pell(a) + pell_prev(a)


def sigma_G(a: int, b: int) -> float:
    """Dominant root of x^2 = T x + 1 (valid for odd a, where det = -1)."""
    t = float(trace_G(a, b))
    return (t + math.sqrt(t * t + 4.0)) / 2.0


def log_sigma_G(a: int, b: int) -> float:
    """
    log sigma(a,b), computed without overflow for very large traces:
        sigma = T (1 + sqrt(1 + 4/T^2)) / 2,
    so log sigma = log T + log((1 + sqrt(1 + 4/T^2))/2).
    """
    t = trace_G(a, b)
    log_t = math.log(t)                      # exact for arbitrary-size ints
    inv_sq = math.exp(-2.0 * log_t)          # 1/T^2, safely underflowing to 0
    return log_t + math.log((1.0 + math.sqrt(1.0 + 4.0 * inv_sq)) / 2.0)


def rate_G(a: int, b: int) -> float:
    """Exact metric growth rate of the path (B2^a B3^b)^oo, a odd."""
    return log_sigma_G(a, b) / (a + b)


def periodic_rate(period: List[str]) -> float:
    """
    Exact rate of an arbitrary periodic path, from its period matrix.

    The moves act on the column (m, n) by
        B1 = [[2,-1],[1,0]], B2 = [[2,1],[1,0]], B3 = [[1,2],[0,1]].
    The rate is log(dominant eigenvalue) / period length.
    """
    mats = {
        "B1": (2, -1, 1, 0),
        "B2": (2, 1, 1, 0),
        "B3": (1, 2, 0, 1),
    }
    p, q, r, s = 1, 0, 0, 1
    for letter in reversed(period):          # leftmost letter applied first
        a_, b_, c_, d_ = mats[letter]
        p, q, r, s = (p * a_ + q * c_, p * b_ + q * d_,
                      r * a_ + s * c_, r * b_ + s * d_)
    tr = p + s
    det = p * s - q * r
    lam = (tr + math.sqrt(tr * tr - 4.0 * det)) / 2.0
    return math.log(lam) / len(period)


# --------------------------------------------------------------------------
# 4.  Demonstrations
# --------------------------------------------------------------------------

def demo_tree_and_window(max_depth: int = 8) -> None:
    print("=" * 74)
    print("1.  THE TREE, AND THE WINDOW LEMMA   log m <= d <= log m + log 2")
    print("=" * 74)
    print(f"root seed {ROOT} -> triple {triple(ROOT)}")
    for name, mv in (("B1", b1), ("B2", b2), ("B3", b3)):
        child = mv(ROOT)
        print(f"  {name}(2,1) = {child}  -> triple {triple(child)}")

    worst_low, worst_high, count = math.inf, math.inf, 0
    for k in range(max_depth + 1):
        for _, v in nodes_at_depth(k):
            lo, hi = window_defect(v)
            worst_low, worst_high = min(worst_low, lo), min(worst_high, hi)
            count += 1
    print(f"\nchecked all {count} nodes of depth <= {max_depth}")
    print(f"  min (d - log m)             = {worst_low:.10f}   (must be >= 0)")
    print(f"  min (log m + log 2 - d)     = {worst_high:.10f}   (must be >= 0)")
    print("  => hyperbolic distance IS log m, to within log 2 = 0.6931472")


def demo_potential() -> None:
    print()
    print("=" * 74)
    print("2.  THE SILVER POTENTIAL  Phi(m,n) = m + (sqrt2 - 1) n")
    print("=" * 74)
    print("     seed        Phi(B1 v)/Phi(v)  Phi(B2 v)/Phi(v)  Phi(B3 v)/Phi(v)")
    for v in [(2, 1), (5, 2), (3, 2), (8, 3), (12, 5), (7, 4)]:
        r1 = pot(b1(v)) / pot(v)
        r2 = pot(b2(v)) / pot(v)
        r3 = pot(b3(v)) / pot(v)
        print(f"  {str(v):>10}      {r1:.9f}       {r2:.9f}       {r3:.9f}")
    print(f"\n  1 + sqrt2 = {SILVER:.9f}: the middle column is EXACT, always.")
    print("  Slack of the other two moves (must be >= sqrt2 = 1.4142136):")
    for v in [(2, 1), (5, 2), (3, 2), (12, 5)]:
        s1 = SILVER * pot(v) - pot(b1(v))
        s3 = SILVER * pot(v) - pot(b3(v))
        print(f"    seed {str(v):>8}:  B1 slack = {s1:8.5f}   B3 slack = {s3:8.5f}")


def demo_extremality(max_depth: int = 9) -> None:
    print()
    print("=" * 74)
    print("3-4.  EXTREMAL STRUCTURE:  max Phi = (1+sqrt2)^(k+1), UNIQUELY on")
    print("      the Pell spine;  max m / (1+sqrt2)^(k+1) -> (2+sqrt2)/4")
    print("=" * 74)
    print("  k   max Phi        (1+sqrt2)^(k+1)   runner-up gap   max m   m/lam^(k+1)")
    for k in range(max_depth + 1):
        vals = sorted(((pot(v), v) for _, v in nodes_at_depth(k)), reverse=True)
        best, best_v = vals[0]
        second = vals[1][0] if len(vals) > 1 else float("nan")
        bound = SILVER ** (k + 1)
        ratio = best_v[0] / bound
        assert best_v == spine(k), "maximiser must be the Pell node"
        gap = "        n/a" if k == 0 else f"{best - second:11.6f}"
        print(f"  {k}  {best:14.6f} {bound:16.6f}    {gap}"
              f" {best_v[0]:7d}   {ratio:.7f}")
    print(f"\n  limit constant (2+sqrt2)/4 = {(2 + SQRT2) / 4:.7f}")
    print(f"  naive guess     1/sqrt2    = {1 / SQRT2:.7f}   <-- refuted")
    print(f"  runner-up gap tends to sqrt2 = {SQRT2:.7f} (times lam^0), as proved")


def demo_frequency_failure(periods: int = 14) -> None:
    print()
    print("=" * 74)
    print("5.  MIDDLE-MOVE FREQUENCY DOES NOT DETERMINE THE RATE")
    print("=" * 74)
    pa, pb = ["B2", "B3"], ["B2", "B2", "B3", "B3"]
    exact_a = 0.5 * math.log(2 + math.sqrt(5.0))
    exact_b = 0.5 * math.log(2 + math.sqrt(3.0))
    print("  path A = (B2 B3)^oo         middle frequency 1/2")
    print("  path B = (B2 B2 B3 B3)^oo   middle frequency 1/2")
    print("\n   j    d_A/|w|      d_B/|w|      (exact A)    (exact B)")
    for j in range(1, periods + 1):
        wa = " ".join(pa * j)
        wb = " ".join(pb * j)
        va, vb = run(wa), run(wb)
        ra = hyperbolic_distance(va) / (2 * j)
        rb = hyperbolic_distance(vb) / (4 * j)
        print(f"  {j:2d}   {ra:.8f}   {rb:.8f}   {exact_a:.8f}   {exact_b:.8f}")
    print(f"\n  exact rate A = (1/2) log(2+sqrt5) = {exact_a:.8f}")
    print(f"  exact rate B = (1/2) log(2+sqrt3) = {exact_b:.8f}")
    print(f"  separation                        = {exact_a - exact_b:.8f}")
    print(f"  from period matrices:  A -> {periodic_rate(pa):.8f}"
          f"   B -> {periodic_rate(pb):.8f}")
    print("  Same letter statistics, different speeds: ARRANGEMENT matters.")


def demo_spectrum() -> None:
    print()
    print("=" * 74)
    print("6.  THE TWO-PARAMETER FAMILY  (B2^a B3^b)^oo  AND DENSITY")
    print("=" * 74)
    print(f"  top of the spectrum: log(1+sqrt2) = {LOG_SILVER:.8f}")
    print("\n   a   b     T(a,b)        sigma(a,b)        rate = log sigma/(a+b)")
    for a in (1, 3, 5):
        for b in (0, 1, 2, 4, 8, 16):
            print(f"  {a:2d}  {b:2d}  {trace_G(a, b):10d}  {sigma_G(a, b):16.6f}"
                  f"        {rate_G(a, b):.8f}")
    print("\n  a odd, b = 0 gives sigma = (1+sqrt2)^a and rate exactly log(1+sqrt2):")
    for a in (1, 3, 5, 7, 9):
        print(f"    a = {a}:  sigma = {sigma_G(a, 0):18.6f}"
              f"   (1+sqrt2)^a = {SILVER ** a:18.6f}"
              f"   rate = {rate_G(a, 0):.10f}")

    print("\n  Density: approximating prescribed targets to within eps = 1e-3")
    for target in (0.0, 0.2, 0.44, 0.6584789, 0.7218176, 0.85, LOG_SILVER):
        a, b, r = approximate_rate(target, 1e-3)
        print(f"    target {target:.7f}  ->  a = {a:3d}, b = {b:4d},"
              f"  rate = {r:.7f},  error = {abs(r - target):.2e}")


def approximate_rate(target: float, eps: float,
                     max_a: int = 121, max_b: int = 1200
                     ) -> Tuple[int, int, float]:
    """
    Find odd a and b >= 0 with |rate_G(a,b) - target| as small as possible.

    The theoretical construction takes a > 3 log 3 / eps and then performs a
    discrete intermediate-value descent in b: the rates start at log(1+sqrt2)
    for b = 0, decrease to 0 as b -> oo, and consecutive rates differ by at
    most 3 log 3 / (a + b + 1), which is < eps once a is large.  That bound is
    very pessimistic, so in practice a modest search over odd a and over b --
    stopping the b-loop as soon as the rate drops below the target, since the
    rates are decreasing in b -- already achieves far better accuracy.
    """
    best: Tuple[int, int, float] = (1, 0, rate_G(1, 0))
    for a in range(1, max_a + 1, 2):
        for b in range(0, max_b + 1):
            r = rate_G(a, b)
            if abs(r - target) < abs(best[2] - target):
                best = (a, b, r)
            if r < target:
                break
            if r < eps and target < eps:
                break
        if abs(best[2] - target) < eps * 1e-3:
            break
    return best


def demo_depth_vs_hypotenuse() -> None:
    print()
    print("=" * 74)
    print("7.  DEPTH VERSUS HYPOTENUSE, AND THE COST OF A COLLISION")
    print("=" * 74)
    print("  Pell spine: depth k, hypotenuse c_k, and the lower bound")
    print("  (log c - log 2)/(2 log(1+sqrt2)) - 1  that no node can beat.\n")
    print("   k        seed              hypotenuse c      lower bound on depth")
    for k in range(0, 13):
        v = spine(k)
        c = hypot(v)
        lb = (math.log(c) - math.log(2.0)) / (2 * LOG_SILVER) - 1
        print(f"  {k:2d}  {str(v):>16}  {c:18d}        {lb:8.4f}")
    print("\n  So hypotenuse N first appears at depth log N/(2 log(1+sqrt2)) + O(1).")

    print("\n  Collisions: two seeds with the same hypotenuse must be deep.")
    for target in (65, 325, 1105, 5525):
        reps = [(m, n) for m in range(1, int(math.isqrt(target)) + 1)
                for n in range(1, m)
                if m * m + n * n == target and math.gcd(m, n) == 1
                and (m - n) % 2 == 1]
        bound = (math.log(target) - math.log(2.0)) / LOG_SILVER - 2
        depths = [depth_of(v) for v in reps]
        pair_min = min(depths[i] + depths[j]
                       for i in range(len(depths))
                       for j in range(i + 1, len(depths)))
        print(f"    N = {target:6d}: seeds {reps},")
        print(f"                 depths {depths}, smallest pair sum"
              f" {pair_min} >= {bound:.3f}")


def depth_of(v: Seed) -> int:
    """
    Depth of a seed, by Berggren descent.

    Exactly one of the three inverse moves
        B1^-1(m,n) = (n, 2n - m),  B2^-1(m,n) = (n, m - 2n),
        B3^-1(m,n) = (m - 2n, n)
    lands on a seed, so the descent is deterministic and terminates at (2,1)
    after (depth) steps; the running time is O(log hypotenuse).

    The trichotomy is governed by the slope x = m/n:
        x > 3      -> the last move was B3,
        2 < x < 3  -> the last move was B2,
        1 < x < 2  -> the last move was B1.
    """
    m, n = v
    k = 0
    while (m, n) != ROOT:
        if m > 3 * n:
            m, n = m - 2 * n, n                 # undo B3
        elif m > 2 * n:
            m, n = n, m - 2 * n                 # undo B2
        else:
            m, n = n, 2 * n - m                 # undo B1
        k += 1
        if m <= 0 or n <= 0 or n >= m:
            raise ValueError("not a valid seed")
    return k


def main() -> None:
    demo_tree_and_window()
    demo_potential()
    demo_extremality()
    demo_frequency_failure()
    demo_spectrum()
    demo_depth_vs_hypotenuse()
    print()
    print("=" * 74)
    print("SUMMARY:  the metric growth exponent of the Berggren tree is exactly")
    print(f"          log(1 + sqrt 2) = {LOG_SILVER:.10f},")
    print("          attained uniquely by the Pell spine, and the closure of the")
    print("          set of realised rates is exactly [0, log(1 + sqrt 2)].")
    print("=" * 74)


if __name__ == "__main__":
    main()
