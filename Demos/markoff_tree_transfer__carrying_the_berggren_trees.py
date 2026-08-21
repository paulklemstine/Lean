#!/usr/bin/env python3
"""
Numerical demonstration of the Pythagorean/Markoff transfer results.

Everything is exact integer arithmetic; no third-party packages are required.

The script verifies, by direct computation:

  1.  The Pythagorean tree (generated from (2,1) by the three Berggren moves)
      has exactly 3^n nodes at depth n, all valid and pairwise distinct.
  2.  The Markoff tree (generated from (1,2,5) by the two ascending Vieta
      moves) has exactly 2^n nodes at depth n, all on the surface
      x^2 + y^2 + z^2 = 3xyz and pairwise distinct.
  3.  The branching obstruction: 3 distinct children cannot inject into 2 slots.
  4.  The metric obstruction: spine recursions u(n+2) = 6u(n+1) - u(n) versus
      s(n+2) = 3s(n+1) - s(n); growth rates 3 + 2*sqrt(2) and (3 + sqrt(5))/2
      squared; the two transfer matrices have traces 6 and 3.
  5.  The linearity obstruction: the 4x3 linear system forced on the last row
      of a hypothetical matrix model of the Vieta move is inconsistent.
  6.  Fibrewise linearity: over a fixed smallest coordinate x the move
      (y, z) -> (z, 3xz - y) is the SL_2(Z) matrix [[0, 1], [-1, 3x]].
  7.  The silver transfer: consecutive Pythagorean spine hypotenuses
      5, 29, 169, 985, 5741, ... are exactly the Markoff triples with
      smallest entry 2, and the golden branch is the odd-index Fibonacci
      pairs -- exactly the Markoff triples with smallest entry 1.
  8.  Arithmetic invariants: pairwise coprimality, no coordinate divisible
      by 3, at most one even coordinate.
  9.  Middle-entry rigidity and the uniqueness reduction, checked over the
      whole tree up to a chosen depth.
"""

from __future__ import annotations

from fractions import Fraction
from math import gcd, isqrt, sqrt
from typing import Dict, Iterable, List, Sequence, Set, Tuple

Pair = Tuple[int, int]
Triple = Tuple[int, int, int]


# --------------------------------------------------------------------------
# 1. The Pythagorean (Berggren) ternary tree, in the (m, n) parameter model
# --------------------------------------------------------------------------

ROOT_PAIR: Pair = (2, 1)


def berggren_A(p: Pair) -> Pair:
    """First Berggren move: (m, n) -> (2m - n, m)."""
    m, n = p
    return (2 * m - n, m)


def berggren_B(p: Pair) -> Pair:
    """Second (spine) Berggren move: (m, n) -> (2m + n, m)."""
    m, n = p
    return (2 * m + n, m)


def berggren_C(p: Pair) -> Pair:
    """Third Berggren move: (m, n) -> (m + 2n, n)."""
    m, n = p
    return (m + 2 * n, n)


BERGGREN_MOVES = (berggren_A, berggren_B, berggren_C)


def pair_to_triple(p: Pair) -> Triple:
    """(m, n) -> the primitive Pythagorean triple (m^2 - n^2, 2mn, m^2 + n^2)."""
    m, n = p
    return (m * m - n * n, 2 * m * n, m * m + n * n)


def is_valid_pair(p: Pair) -> bool:
    """m > n > 0, coprime, of opposite parity."""
    m, n = p
    return m > n > 0 and gcd(m, n) == 1 and (m - n) % 2 == 1


def berggren_level(n: int) -> List[Pair]:
    """All pairs at depth n of the Pythagorean tree."""
    level: List[Pair] = [ROOT_PAIR]
    for _ in range(n):
        level = [g(p) for p in level for g in BERGGREN_MOVES]
    return level


# --------------------------------------------------------------------------
# 2. The Markoff binary tree
# --------------------------------------------------------------------------

MARKOFF_ROOT: Triple = (1, 2, 5)


def markoff_form(t: Triple) -> int:
    """x^2 + y^2 + z^2 - 3xyz; zero exactly on the Markoff surface."""
    x, y, z = t
    return x * x + y * y + z * z - 3 * x * y * z


def is_markoff(t: Triple) -> bool:
    return markoff_form(t) == 0


def child_L(t: Triple) -> Triple:
    """Vieta move in the middle coordinate: (x, y, z) -> (x, z, 3xz - y)."""
    x, y, z = t
    return (x, z, 3 * x * z - y)


def child_R(t: Triple) -> Triple:
    """Vieta move in the first coordinate: (x, y, z) -> (y, z, 3yz - x)."""
    x, y, z = t
    return (y, z, 3 * y * z - x)


MARKOFF_MOVES = (child_L, child_R)


def markoff_parent(t: Triple) -> Triple:
    """Descent map: Vieta the top coordinate away and re-sort."""
    x, y, z = t
    w = 3 * x * y - z
    return (w, x, y) if w <= x else (x, w, y)


def markoff_level(n: int) -> List[Triple]:
    """All triples at depth n of the Markoff tree."""
    level: List[Triple] = [MARKOFF_ROOT]
    for _ in range(n):
        level = [g(t) for t in level for g in MARKOFF_MOVES]
    return level


def markoff_descend_to_root(t: Triple) -> List[Triple]:
    """Repeatedly Vieta the maximum away; returns the full descent path."""
    path = [t]
    cur = tuple(sorted(t))
    while cur != (1, 1, 1):
        x, y, z = cur
        cur = tuple(sorted((x, y, 3 * x * y - z)))
        path.append(cur)  # type: ignore[arg-type]
    return path  # type: ignore[return-value]


# --------------------------------------------------------------------------
# 3. The two spines
# --------------------------------------------------------------------------

def silver_spine(k: int) -> List[int]:
    """Pythagorean spine hypotenuses: u(0)=5, u(1)=29, u(n+2)=6u(n+1)-u(n)."""
    u = [5, 29]
    while len(u) < k:
        u.append(6 * u[-1] - u[-2])
    return u[:k]


def golden_spine(k: int) -> List[int]:
    """Markoff golden spine: s(0)=s(1)=1, s(n+2)=3s(n+1)-s(n)."""
    s = [1, 1]
    while len(s) < k:
        s.append(3 * s[-1] - s[-2])
    return s[:k]


def fib(n: int) -> int:
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def fibre_matrix(x: int) -> Tuple[Tuple[int, int], Tuple[int, int]]:
    """The SL_2(Z) matrix implementing (y, z) -> (z, 3xz - y)."""
    return ((0, 1), (-1, 3 * x))


def mat_det(m: Sequence[Sequence[int]]) -> int:
    return m[0][0] * m[1][1] - m[0][1] * m[1][0]


def mat_trace(m: Sequence[Sequence[int]]) -> int:
    return m[0][0] + m[1][1]


# --------------------------------------------------------------------------
# Section runners
# --------------------------------------------------------------------------

def banner(title: str) -> None:
    print()
    print("=" * 74)
    print(title)
    print("=" * 74)


def demo_level_counts(depth: int = 8) -> None:
    banner("1. LEVEL COUNTS: 3^n versus 2^n")
    print(f"{'n':>3} {'Pythagorean':>14} {'expected':>10} {'Markoff':>10} {'expected':>10}")
    for n in range(depth + 1):
        bl = berggren_level(n)
        ml = markoff_level(n)
        assert len(set(bl)) == len(bl) == 3 ** n, "Pythagorean level count failed"
        assert len(set(ml)) == len(ml) == 2 ** n, "Markoff level count failed"
        assert all(is_valid_pair(p) for p in bl)
        assert all(is_markoff(t) for t in ml)
        print(f"{n:>3} {len(bl):>14} {3 ** n:>10} {len(ml):>10} {2 ** n:>10}")
    print("\nAll nodes distinct, all Pythagorean pairs valid, all Markoff triples on the surface.")


def demo_branching_obstruction() -> None:
    banner("2. THE BRANCHING OBSTRUCTION: three children, two slots")
    kids = [g(ROOT_PAIR) for g in BERGGREN_MOVES]
    print("Children of the Pythagorean root (2,1):")
    for name, p in zip("ABC", kids):
        print(f"   {name}: pair {p}  ->  triple {pair_to_triple(p)}")
    assert len(set(kids)) == 3
    print("\nChildren of the Markoff root (1,2,5):")
    for name, g in zip("LR", MARKOFF_MOVES):
        print(f"   {name}: {g(MARKOFF_ROOT)}")
    print("\nExhaustive check: every assignment of the 3 Pythagorean children to")
    print("2 Markoff child-slots collapses at least two of them.")
    collisions = 0
    for bA in (0, 1):
        for bB in (0, 1):
            for bC in (0, 1):
                assignment = (bA, bB, bC)
                if len(set(assignment)) < 3:
                    collisions += 1
    assert collisions == 8, "pigeonhole check failed"
    print(f"   {collisions}/8 assignments collide -> no injective branching-compatible map.")


def demo_metric_obstruction(k: int = 8) -> None:
    banner("3. THE METRIC OBSTRUCTION: silver versus golden")
    u = silver_spine(k)
    s = golden_spine(k + 2)
    print("Pythagorean spine (iterate (m,n) -> (2m+n, m) from (2,1)):")
    p = ROOT_PAIR
    for i in range(5):
        t = pair_to_triple(p)
        print(f"   pair {p!s:>12}  triple {t!s:>22}  hypotenuse {t[2]}")
        p = berggren_B(p)
    print(f"\n   hypotenuses u = {u}")
    for n in range(len(u) - 2):
        assert u[n + 2] == 6 * u[n + 1] - u[n]
    print("   verified: u(n+2) = 6 u(n+1) - u(n)   [char. poly X^2 - 6X + 1]")

    print(f"\n   golden spine s = {s}")
    for n in range(len(s) - 2):
        assert s[n + 2] == 3 * s[n + 1] - s[n]
    for n in range(len(s) - 1):
        assert s[n + 1] == fib(2 * n + 1), "odd-index Fibonacci identification failed"
    print("   verified: s(n+2) = 3 s(n+1) - s(n)   [char. poly X^2 - 3X + 1]")
    print("   verified: s(n+1) = F(2n+1), the odd-index Fibonacci numbers")

    silver_rate = 3 + 2 * sqrt(2)
    golden_rate = ((1 + sqrt(5)) / 2) ** 2
    print(f"\n   empirical silver ratio u(n+1)/u(n) = {u[-1] / u[-2]:.10f}")
    print(f"   3 + 2*sqrt(2)                      = {silver_rate:.10f}")
    print(f"   empirical golden ratio s(n+1)/s(n) = {s[-1] / s[-2]:.10f}")
    print(f"   phi^2 = (3 + sqrt(5))/2            = {golden_rate:.10f}")

    m_silver = ((6, -1), (1, 0))
    m_golden = ((3, -1), (1, 0))
    print(f"\n   trace(silver transfer matrix) = {mat_trace(m_silver)}")
    print(f"   trace(golden transfer matrix) = {mat_trace(m_golden)}")
    assert mat_trace(m_silver) != mat_trace(m_golden)
    print("   traces differ -> the two dynamics are not conjugate over the rationals.")

    print("\n   sqrt(5) is not in Q(sqrt 2): search for rationals a, b with (a + b sqrt2)^2 = 5")
    found = None
    for den in range(1, 60):
        for na in range(-120, 121):
            for nb in range(-120, 121):
                a, b = Fraction(na, den), Fraction(nb, den)
                if a * a + 2 * b * b == 5 and 2 * a * b == 0:
                    found = (a, b)
    assert found is None
    print("   exhaustive search over denominators up to 59: no solution (as proved).")


def demo_linearity_obstruction() -> None:
    banner("4. THE LINEARITY OBSTRUCTION: no matrix model for the Vieta move")
    pts: List[Triple] = [(1, 1, 1), (1, 2, 5), (1, 5, 13), (2, 5, 29)]
    print("Four Markoff points and the value the last row must produce:")
    rows: List[Tuple[int, int, int, int]] = []
    for (x, y, z) in pts:
        assert is_markoff((x, y, z))
        rhs = 3 * x * y - z
        rows.append((x, y, z, rhs))
        print(f"   (x,y,z) = {(x, y, z)!s:>12}   alpha*{x} + beta*{y} + gamma*{z} = {rhs}")
    # Solve the first three exactly, then test the fourth.
    a1, b1, c1, d1 = rows[0]
    a2, b2, c2, d2 = rows[1]
    a3, b3, c3, d3 = rows[2]
    # Eliminate alpha using rows 1-2 and 2-3.
    e1 = (b2 - b1, c2 - c1, d2 - d1)
    e2 = (b3 - b2, c3 - c2, d3 - d2)
    det = e1[0] * e2[1] - e1[1] * e2[0]
    assert det != 0
    beta = Fraction(e1[2] * e2[1] - e1[1] * e2[2], det)
    gamma = Fraction(e1[0] * e2[2] - e1[2] * e2[0], det)
    alpha = Fraction(d1) - beta * b1 - gamma * c1
    print(f"\n   first three equations force (alpha, beta, gamma) = ({alpha}, {beta}, {gamma})")
    a4, b4, c4, d4 = rows[3]
    residual = alpha * a4 + beta * b4 + gamma * c4
    print(f"   fourth equation then requires {residual} = {d4}")
    assert residual != d4
    print("   contradiction -> the Vieta move is not induced by any rational matrix.")


def demo_fibrewise_linearity(xs: Iterable[int] = (1, 2, 5, 13, 29)) -> None:
    banner("5. FIBREWISE LINEARITY: an SL_2(Z) matrix of trace 3x on each fibre")
    print(f"{'x':>5} {'matrix':>22} {'det':>5} {'trace':>7} {'char. poly':>18} {'growth':>12}")
    for x in xs:
        m = fibre_matrix(x)
        d, tr = mat_det(m), mat_trace(m)
        assert d == 1 and tr == 3 * x
        rate = (3 * x + sqrt(9 * x * x - 4)) / 2
        poly = f"X^2 - {3 * x}X + 1"
        print(f"{x:>5} {str(m):>22} {d:>5} {tr:>7} {poly:>18} {rate:>12.6f}")
    print("\n   det = 1 always, so each fibre map lies in SL_2(Z);")
    print("   trace = 3x > 2 for x >= 1, so every fibre is hyperbolic (exponential growth).")
    print("   x = 1 gives X^2 - 3X + 1 (golden), x = 2 gives X^2 - 6X + 1 (silver).")


def demo_exact_fibres(bound: int = 10 ** 7) -> None:
    banner("6. EXACT FIBRES: the x = 1 and x = 2 branches")
    # Collect every Markoff triple with max below `bound` by tree search.
    triples: Set[Triple] = set()
    frontier = [MARKOFF_ROOT]
    triples.add((1, 1, 1))
    triples.add((1, 1, 2))
    triples.add(MARKOFF_ROOT)
    while frontier:
        nxt: List[Triple] = []
        for t in frontier:
            for g in MARKOFF_MOVES:
                c = g(t)
                if c[2] <= bound:
                    triples.add(c)
                    nxt.append(c)
        frontier = nxt

    fibre1 = sorted(t for t in triples if min(t) == 1)
    fibre2 = sorted(t for t in triples if min(t) == 2)
    s = golden_spine(20)
    u = silver_spine(12)

    print(f"Markoff triples with maximum <= {bound}: {len(triples)}")
    print("\n   fibre over x = 1 (predicted: consecutive odd-index Fibonacci pairs)")
    for t in fibre1:
        n = s.index(t[1]) if t[1] in s else None
        print(f"      {t!s:>22}   = (1, s_n, s_(n+1))")
        assert t[1] in s and t[2] in s
    print(f"      golden spine: {s[:10]}")

    print("\n   fibre over x = 2 (predicted: consecutive Pythagorean spine hypotenuses)")
    for t in fibre2:
        print(f"      {t!s:>22}   = (2, u_n, u_(n+1))")
        assert t[1] in u and t[2] in u
    print(f"      spine hypotenuses: {u[:8]}")

    # Exactness, the other direction.
    for n in range(len(u) - 1):
        assert is_markoff((2, u[n], u[n + 1])), "silver transfer failed"
    for n in range(len(s) - 1):
        assert is_markoff((1, s[n], s[n + 1])), "golden branch failed"
    print("\n   verified both directions: the two families coincide exactly.")

    max1 = {t[2] for t in fibre1}
    max2 = {t[2] for t in fibre2}
    assert max1.isdisjoint(max2)
    print(f"   maxima over x=1: {sorted(max1)}")
    print(f"   maxima over x=2: {sorted(max2)}")
    print("   the two fibres share no maximum (uniqueness holds between them).")


def demo_arithmetic_invariants(depth: int = 9) -> None:
    banner("7. ARITHMETIC INVARIANTS ALONG THE WHOLE TREE")
    checked = 0
    for n in range(depth + 1):
        for t in markoff_level(n):
            x, y, z = t
            assert gcd(x, y) == 1 and gcd(y, z) == 1 and gcd(x, z) == 1
            assert x % 3 != 0 and y % 3 != 0 and z % 3 != 0
            assert sum(1 for v in t if v % 2 == 0) <= 1
            checked += 1
    print(f"   checked {checked} nodes (depths 0..{depth}):")
    print("     * coordinates pairwise coprime            OK")
    print("     * no coordinate divisible by 3            OK")
    print("     * at most one even coordinate             OK")
    sample = markoff_level(4)[:6]
    print("\n   sample nodes at depth 4:")
    for t in sample:
        print(f"      {t!s:>34}  mod 3: {(t[0] % 3, t[1] % 3, t[2] % 3)}  parity: "
              f"{(t[0] % 2, t[1] % 2, t[2] % 2)}")


def demo_rigidity_and_uniqueness(depth: int = 11) -> None:
    banner("8. MIDDLE-ENTRY RIGIDITY AND THE UNIQUENESS REDUCTION")
    by_outer: Dict[Tuple[int, int], Set[int]] = {}
    by_max: Dict[int, Set[Triple]] = {}
    total = 0
    for n in range(depth + 1):
        for t in markoff_level(n):
            x, y, z = sorted(t)
            by_outer.setdefault((x, z), set()).add(y)
            by_max.setdefault(z, set()).add((x, y, z))
            total += 1
    bad = [k for k, v in by_outer.items() if len(v) > 1]
    assert not bad, f"middle-entry rigidity violated at {bad[:3]}"
    print(f"   {total} nodes examined, {len(by_outer)} distinct (min, max) pairs.")
    print("   middle entry uniquely determined by (min, max) in every case:  OK")
    print("   -> uniqueness of the triple is equivalent to uniqueness of the minimum.")

    clashes = [z for z, ts in by_max.items() if len(ts) > 1]
    print(f"\n   maxima occurring in more than one triple: {len(clashes)}")
    print("   (the Markoff uniqueness conjecture asserts this count is always 0;")
    print("    equivalently: distinct fibres never share a maximum)")

    print("\n   descent from a large node back to the root:")
    big = markoff_level(6)[13]
    path = markoff_descend_to_root(big)
    for t in path:
        print(f"      {t}")
    print(f"   {len(path) - 1} Vieta steps, sum strictly decreasing throughout.")


def demo_embedding(depth: int = 4) -> None:
    banner("9. THE POSITIVE TRANSFER: Markoff words embed in the Pythagorean tree")
    print("Binary Markoff words map to Pythagorean words by L -> A, R -> B.")
    print(f"{'word':>10} {'Markoff triple':>28} {'Pythagorean pair':>18} {'depth':>6}")
    words: List[str] = [""]
    for _ in range(depth):
        words += [w + c for w in words if len(w) == max(len(x) for x in words) for c in "LR"]
    seen_pairs: Set[Pair] = set()
    for w in sorted(set(words), key=lambda s: (len(s), s)):
        t: Triple = MARKOFF_ROOT
        p: Pair = ROOT_PAIR
        for ch in reversed(w):
            t = child_L(t) if ch == "L" else child_R(t)
            p = berggren_A(p) if ch == "L" else berggren_B(p)
        assert p not in seen_pairs, "embedding not injective"
        seen_pairs.add(p)
        label = w if w else "(empty)"
        print(f"{label:>10} {str(t):>28} {str(p):>18} {len(w):>6}")
    print("\n   distinct words give distinct Pythagorean pairs, at the matching depth:")
    print("   the Markoff binary tree is a free rank-2 sub-tree of the ternary tree.")


def main() -> None:
    print(__doc__)
    demo_level_counts()
    demo_branching_obstruction()
    demo_metric_obstruction()
    demo_linearity_obstruction()
    demo_fibrewise_linearity()
    demo_exact_fibres()
    demo_arithmetic_invariants()
    demo_rigidity_and_uniqueness()
    demo_embedding()
    banner("ALL CHECKS PASSED")


if __name__ == "__main__":
    main()
