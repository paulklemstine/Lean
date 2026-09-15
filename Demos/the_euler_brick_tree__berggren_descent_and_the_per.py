"""
The Euler Brick Tree — numerical demonstrations
===============================================

An *Euler brick* is a rectangular box with integer edges (x, y, z) whose three
face diagonals are also integers:

        x^2 + y^2 = p^2,   x^2 + z^2 = q^2,   y^2 + z^2 = r^2.

A *perfect cuboid* is an Euler brick whose space diagonal is an integer too:

        x^2 + y^2 + z^2 = s^2.

Whether a perfect cuboid exists is an open problem going back to Euler's era.

This script demonstrates, numerically, the results of the accompanying paper:

  1.  The Saunderson generator  (u, v, w) |-> (u(4v^2 - w^2), v(4u^2 - w^2), 4uvw)
      turns any Pythagorean triple u^2 + v^2 = w^2 into an Euler brick, with
      closed-form face diagonals  w^3,  u(w^2+4v^2),  v(w^2+4u^2).

  2.  The Berggren tree: the three unimodular generators A, B, C applied to the
      seed (3, 4, 5) produce every primitive Pythagorean triple with odd first
      leg exactly once, so level n has exactly 3^n nodes.  Transporting through
      the Saunderson generator gives a ternary tree of Euler bricks rooted at
      (117, 44, 240).

  3.  Exact reduction: the brick over a node (a, b, c) is a perfect cuboid
      if and only if the quartic  c^4 + 16 a^2 b^2  is a perfect square.
      Equivalently (using a^2 + b^2 = c^2) if and only if
      a^4 + 18 a^2 b^2 + b^4 is a perfect square.

  4.  Descent: every Euler brick is a positive integer multiple of a primitive
      one; a primitive Euler brick has exactly one odd edge, the other two
      divisible by 4, and 720 always divides the product of its edges.

  5.  The mod 7 obstruction: if a = b (mod 7) and 7 does not divide a, then the
      quartic is 6 a^4 (mod 7), a quadratic nonresidue, so the brick over that
      node is provably not a perfect cuboid.  Iterating the second generator
      preserves this condition, giving an infinite obstructed branch.

  6.  Sharpness: from *every* residue state one of the four words
      epsilon, A, AA, AB reaches a node where the mod 7 certificate fails.
      Hence no mod-7-certified binary subtree exists.

Run:  python3 demo.py
"""

from __future__ import annotations

from itertools import product
from math import isqrt
from typing import Dict, Iterable, List, Set, Tuple

Triple = Tuple[int, int, int]

# --------------------------------------------------------------------------
# Basic arithmetic helpers
# --------------------------------------------------------------------------


def is_square(n: int) -> bool:
    """Return True when the integer n is a perfect square (n >= 0)."""
    if n < 0:
        return False
    r = isqrt(n)
    return r * r == n


def is_pythagorean(t: Triple) -> bool:
    """Return True when a^2 + b^2 = c^2."""
    a, b, c = t
    return a * a + b * b == c * c


def gcd3(x: int, y: int, z: int) -> int:
    """Greatest common divisor of three integers."""
    from math import gcd

    return gcd(gcd(abs(x), abs(y)), abs(z))


# --------------------------------------------------------------------------
# 1.  The Saunderson brick generator
# --------------------------------------------------------------------------


def brick(t: Triple) -> Triple:
    """The Euler brick attached to a Pythagorean triple (u, v, w)."""
    u, v, w = t
    return (u * (4 * v * v - w * w), v * (4 * u * u - w * w), 4 * u * v * w)


def face_diagonals(t: Triple) -> Triple:
    """Closed-form face diagonals (|w^3|, |u|(w^2+4v^2), |v|(w^2+4u^2))."""
    u, v, w = t
    return (abs(w) ** 3, abs(u) * (w * w + 4 * v * v), abs(v) * (w * w + 4 * u * u))


def is_euler_brick(x: int, y: int, z: int) -> bool:
    """Check the three face-diagonal conditions directly."""
    return (
        is_square(x * x + y * y)
        and is_square(x * x + z * z)
        and is_square(y * y + z * z)
    )


def is_perfect_cuboid(x: int, y: int, z: int) -> bool:
    """Euler brick plus integral space diagonal."""
    return is_euler_brick(x, y, z) and is_square(x * x + y * y + z * z)


def quartic(t: Triple) -> int:
    """The quartic c^4 + 16 a^2 b^2 controlling the space diagonal."""
    a, b, c = t
    return c**4 + 16 * a * a * b * b


# --------------------------------------------------------------------------
# 2.  The Berggren tree
# --------------------------------------------------------------------------


def berg_A(t: Triple) -> Triple:
    a, b, c = t
    return (a - 2 * b + 2 * c, 2 * a - b + 2 * c, 2 * a - 2 * b + 3 * c)


def berg_B(t: Triple) -> Triple:
    a, b, c = t
    return (a + 2 * b + 2 * c, 2 * a + b + 2 * c, 2 * a + 2 * b + 3 * c)


def berg_C(t: Triple) -> Triple:
    a, b, c = t
    return (-a + 2 * b + 2 * c, -2 * a + b + 2 * c, -2 * a + 2 * b + 3 * c)


GENERATORS = (berg_A, berg_B, berg_C)
SEED: Triple = (3, 4, 5)


def level(n: int) -> List[Triple]:
    """All nodes at depth exactly n of the Berggren tree (3^n of them)."""
    nodes: List[Triple] = [SEED]
    for _ in range(n):
        nodes = [g(t) for t in nodes for g in GENERATORS]
    return nodes


def nodes_up_to(depth: int) -> List[Triple]:
    """All nodes of depth <= depth, breadth first."""
    out: List[Triple] = []
    for n in range(depth + 1):
        out.extend(level(n))
    return out


def berggren_parent(t: Triple) -> Triple:
    """The unique Berggren parent of a node other than the seed (3, 4, 5)."""
    a, b, c = t
    candidates = [
        (a + 2 * b - 2 * c, -2 * a - b + 2 * c, -2 * a - 2 * b + 3 * c),
        (a + 2 * b - 2 * c, 2 * a + b - 2 * c, -2 * a - 2 * b + 3 * c),
        (-a - 2 * b + 2 * c, 2 * a + b - 2 * c, -2 * a - 2 * b + 3 * c),
    ]
    for cand in candidates:
        if all(v > 0 for v in cand) and is_pythagorean(cand) and cand[2] < c:
            return cand
    raise ValueError(f"{t} has no positive Berggren parent (is it the seed?)")


def descend_to_seed(t: Triple) -> List[Triple]:
    """The descent path of a node down to the seed (3, 4, 5)."""
    path = [t]
    while path[-1] != SEED:
        path.append(berggren_parent(path[-1]))
    return path


# --------------------------------------------------------------------------
# 5/6.  The mod 7 certificate
# --------------------------------------------------------------------------

SQUARES_MOD_7: Set[int] = {(s * s) % 7 for s in range(7)}


def mod7_refutes(t: Triple) -> bool:
    """True when c^4 + 16 a^2 b^2 is a quadratic nonresidue modulo 7."""
    a, b, c = t
    return (c**4 + 16 * a * a * b * b) % 7 not in SQUARES_MOD_7


def escape_word(state: Triple) -> str:
    """Shortest of the words eps, A, AA, AB escaping the mod 7 certificate."""
    words = {"eps": (), "A": (berg_A,), "AA": (berg_A, berg_A), "AB": (berg_A, berg_B)}
    for name, word in words.items():
        s = state
        for g in word:
            s = g(s)
        if not mod7_refutes(s):
            return name
    return "NONE"


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------


def demo_generator() -> None:
    print("=" * 74)
    print("1.  The Saunderson generator turns Pythagorean triples into bricks")
    print("=" * 74)
    for t in [(3, 4, 5)] + level(1):
        x, y, z = brick(t)
        p, q, r = face_diagonals(t)
        assert is_euler_brick(x, y, z)
        assert abs(x) ** 2 + abs(y) ** 2 == p * p
        assert abs(x) ** 2 + abs(z) ** 2 == q * q
        assert abs(y) ** 2 + abs(z) ** 2 == r * r
        print(
            f"  triple {str(t):>16} -> brick "
            f"({abs(x)}, {abs(y)}, {abs(z)})   face diagonals ({p}, {q}, {r})"
        )
    print("\n  Root brick: triple (3,4,5) -> (117, 44, 240), the classical")
    print("  smallest Euler brick; its first face diagonal is 5^3 = 125.\n")


def demo_growth() -> None:
    print("=" * 74)
    print("2.  Exact 3^n growth, unique parents, distinct bricks")
    print("=" * 74)
    for n in range(6):
        nodes = level(n)
        bricks = {tuple(sorted(map(abs, brick(t)))) for t in nodes}
        assert len(set(nodes)) == 3**n, "nodes must be distinct"
        assert len(bricks) == 3**n, "bricks must be distinct"
        print(f"  level {n}: {len(set(nodes)):>4} distinct nodes, "
              f"{len(bricks):>4} distinct bricks   (3^{n} = {3**n})")
    print("\n  Unique-parent check (descent of a deep node to the seed):")
    deep = level(5)[137]
    path = descend_to_seed(deep)
    print("   ", " -> ".join(str(t) for t in path))
    print()


def demo_reduction() -> None:
    print("=" * 74)
    print("3.  Exact reduction: perfect cuboid  <=>  c^4 + 16 a^2 b^2 a square")
    print("=" * 74)
    print("  node                 quartic        between consecutive squares")
    for t in nodes_up_to(2):
        Q = quartic(t)
        k = isqrt(Q)
        assert not is_square(Q)
        x, y, z = brick(t)
        # space diagonal squared factors as c^2 * Q
        assert x * x + y * y + z * z == t[2] ** 2 * Q
        print(f"  {str(t):>16} {Q:>16}   {k}^2 < Q < {k+1}^2")
    a, b, c = (3, 4, 5)
    print(f"\n  Check of the equivalent form a^4 + 18a^2b^2 + b^4 for (3,4,5): "
          f"{a**4 + 18*a*a*b*b + b**4} = {quartic((a,b,c))}")
    print()


def demo_descent_and_720() -> None:
    print("=" * 74)
    print("4.  Descent to primitive bricks, the one-odd-edge law and 720 | xyz")
    print("=" * 74)
    for t in nodes_up_to(1):
        x, y, z = (abs(v) for v in brick(t))
        g = gcd3(x, y, z)
        xp, yp, zp = x // g, y // g, z // g
        assert is_euler_brick(xp, yp, zp) and gcd3(xp, yp, zp) == 1
        odd = [e for e in (xp, yp, zp) if e % 2 == 1]
        even = [e for e in (xp, yp, zp) if e % 2 == 0]
        assert len(odd) == 1 and all(e % 4 == 0 for e in even)
        assert (xp * yp * zp) % 720 == 0
        print(
            f"  brick ({x}, {y}, {z}) = {g} * ({xp}, {yp}, {zp});"
            f"  odd edge {odd[0]};  xyz/720 = {xp*yp*zp // 720}"
        )
    print()


def demo_mod7_branch() -> None:
    print("=" * 74)
    print("5.  The infinite obstructed branch through (15, 8, 17)")
    print("=" * 74)
    t: Triple = (15, 8, 17)
    for n in range(8):
        a, b, c = t
        assert (a - b) % 7 == 0 and a % 7 != 0
        assert mod7_refutes(t)
        assert quartic(t) % 7 == (6 * a**4) % 7
        print(
            f"  n = {n}:  node {str(t):>24}   a-b = {a-b:>8} "
            f"(= 0 mod 7)   quartic = {quartic(t) % 7} mod 7 (nonresidue)"
        )
        t = berg_B(t)
    print("\n  The quadratic residues mod 7 are", sorted(SQUARES_MOD_7),
          "-- 3, 5, 6 are nonresidues.\n")

    print("  The explicit family m = 14j + 4, node (m^2-1, 2m, m^2+1):")
    for j in range(5):
        m = 14 * j + 4
        node = (m * m - 1, 2 * m, m * m + 1)
        assert is_pythagorean(node) and mod7_refutes(node)
        print(f"    j = {j}: m = {m:>3}, node {str(node):>22}, "
              f"third brick edge = {abs(brick(node)[2])}")
    print()


def demo_sharpness() -> None:
    print("=" * 74)
    print("6.  Sharpness: no mod-7-certified binary subtree")
    print("=" * 74)
    failures = 0
    counts: Dict[str, int] = {}
    for s in product(range(7), repeat=3):
        w = escape_word((s[0], s[1], s[2]))
        counts[w] = counts.get(w, 0) + 1
        if w == "NONE":
            failures += 1
    print(f"  residue states checked: {7**3};  states with no escape: {failures}")
    print("  escaping word used:", dict(sorted(counts.items())))
    print("\n  Local picture at the node (15, 8, 17):")
    for name, g in (("A", berg_A), ("B", berg_B), ("C", berg_C)):
        child = g((15, 8, 17))
        verdict = "certified" if mod7_refutes(child) else "escapes"
        print(f"    child {name}: {str(child):>16}  ->  {verdict}")
    print()


def demo_bounded_search() -> None:
    print("=" * 74)
    print("7.  Bounded search: no perfect cuboid in the first levels")
    print("=" * 74)
    for depth in range(0, 8):
        nodes = nodes_up_to(depth)
        bad = [t for t in nodes if is_square(quartic(t))]
        certified = sum(1 for t in nodes if mod7_refutes(t))
        print(
            f"  depth <= {depth}: {len(nodes):>5} nodes, perfect cuboids found: "
            f"{len(bad)};  mod 7 certified: {certified:>5} "
            f"({100.0*certified/len(nodes):5.1f} %)"
        )
    print("\n  (Levels 0-3 comprise the 40 nodes verified case by case in the")
    print("   bounded-search theorem; every quartic there is trapped strictly")
    print("   between two consecutive squares.)\n")


def main() -> None:
    demo_generator()
    demo_growth()
    demo_reduction()
    demo_descent_and_720()
    demo_mod7_branch()
    demo_sharpness()
    demo_bounded_search()
    print("All assertions passed.")


if __name__ == "__main__":
    main()
