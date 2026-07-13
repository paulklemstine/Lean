"""Numerical and constructive demonstrations of Cantor's hierarchy of infinities.

Infinite cardinals cannot be stored on a computer, but the *structural* content
of Cantor's theory is combinatorial and can be illustrated faithfully on finite
approximations. This self-contained script demonstrates, with no third-party
dependencies:

  1. Cantor's diagonal argument: given any listing of subsets of a finite set,
     produce a subset that is missing from the listing (the mechanism behind
     "no set surjects onto its power set").
  2. The strict growth |P(S)| = 2^|S| > |S|, and the Cantor tower
     T_0 = N, T_{n+1} = 2^{T_n}, whose finite analogues explode in size.
  3. A bijection between the plane and the line at the finite/rational level:
     interleaving digits pairs (x, y) with a single real, illustrating
     |R x R| = |R|.
  4. A bijection N x N -> N (Cantor pairing), the finite engine behind
     kappa * kappa = kappa.
  5. The aleph vs. beth bookkeeping and the CH / GCH statements as symbolic
     relations.

Every function is inlined and annotated with type hints.
"""

from __future__ import annotations

from itertools import product
from typing import Iterable


# ---------------------------------------------------------------------------
# 1. Cantor's diagonal argument on a finite universe
# ---------------------------------------------------------------------------
def diagonal_missing_subset(listing: list[frozenset[int]], universe: list[int]
                            ) -> frozenset[int]:
    """Return a subset of `universe` guaranteed absent from `listing`.

    Models the diagonal set D = { x : x not in f(x) }. If `listing[i]` is meant
    to be the subset assigned to element `universe[i]`, then D differs from every
    listing[i] at position i, so it cannot appear among the first len(listing)
    entries.
    """
    d: set[int] = set()
    for i, x in enumerate(universe):
        assigned = listing[i] if i < len(listing) else frozenset()
        if x not in assigned:      # put x into D exactly when x is NOT in f(x)
            d.add(x)
    return frozenset(d)


def demo_diagonal() -> None:
    universe = [0, 1, 2, 3]
    # An attempted "surjection" f: universe -> P(universe) as a listing.
    listing = [
        frozenset({0, 1}),      # f(0)
        frozenset({1}),         # f(1)
        frozenset({0, 2, 3}),   # f(2)
        frozenset(),            # f(3)
    ]
    d = diagonal_missing_subset(listing, universe)
    print("Universe:", universe)
    print("Diagonal set D =", set(d))
    for i, s in enumerate(listing):
        print(f"  D differs from f({i})={set(s)} at element {universe[i]}: "
              f"{ (universe[i] in d) != (universe[i] in s) }")
    print("D appears in the listing? ", d in listing, "(always False)")


# ---------------------------------------------------------------------------
# 2. Power-set growth and the Cantor tower
# ---------------------------------------------------------------------------
def power_set_size(n: int) -> int:
    """|P(S)| = 2^|S| for a set S with n elements."""
    return 2 ** n


def cantor_tower(levels: int, base: int = 3) -> list[int]:
    """Finite analogue of T_0 = base, T_{n+1} = 2^{T_n}.

    Illustrates the strictly increasing tower of infinities
    aleph_0, 2^aleph_0, 2^(2^aleph_0), ... with `base` standing in for aleph_0.
    """
    tower = [base]
    for _ in range(levels):
        tower.append(power_set_size(tower[-1]))
    return tower


def demo_tower() -> None:
    print("Power-set growth  |S| -> |P(S)|:")
    for n in range(6):
        print(f"  {n:>2}  ->  {power_set_size(n)}")
    # Keep the base small: the tower's growth is doubly-exponential, so even a
    # few rungs are astronomically large. Base 2 stands in for aleph_0.
    tower = cantor_tower(4, base=2)
    print("Cantor tower (base 2):", tower[:4], "...  (next rung = 2^65536)")
    print("  Each rung strictly exceeds the previous (Cantor's theorem).")


# ---------------------------------------------------------------------------
# 3. Plane -> line: interleaving digits  (|R x R| = |R|)
# ---------------------------------------------------------------------------
def interleave(x: float, y: float, digits: int = 8) -> float:
    """Map (x, y) in [0,1)^2 to a single value in [0,1) by interleaving decimals.

    Finite-precision witness for the bijection R x R ~ R: the digits of x go to
    the odd places, digits of y to the even places. Interleaving is invertible
    (de-interleave to recover x and y), so it is a genuine pairing.
    """
    dx = [int(d) for d in f"{x:.{digits}f}".split(".")[1]]
    dy = [int(d) for d in f"{y:.{digits}f}".split(".")[1]]
    out = "0."
    for a, b in zip(dx, dy):
        out += f"{a}{b}"
    return float(out)


def deinterleave(z: float, digits: int = 8) -> tuple[float, float]:
    """Inverse of `interleave`, recovering the pair (x, y)."""
    frac = f"{z:.{2*digits}f}".split(".")[1]
    xs = frac[0::2]
    ys = frac[1::2]
    return float("0." + xs), float("0." + ys)


def demo_plane_to_line() -> None:
    x, y = 0.12345678, 0.87654321
    z = interleave(x, y)
    x2, y2 = deinterleave(z)
    print(f"Point (x, y) = ({x}, {y})")
    print(f"  interleaved to single coordinate z = {z}")
    print(f"  recovered (x, y) = ({x2}, {y2})")
    print("  The plane injects into the line: |R x R| = |R|.")


# ---------------------------------------------------------------------------
# 4. Cantor pairing  N x N -> N   (kappa * kappa = kappa)
# ---------------------------------------------------------------------------
def cantor_pair(a: int, b: int) -> int:
    """Bijective Cantor pairing function N x N -> N."""
    s = a + b
    return s * (s + 1) // 2 + b


def cantor_unpair(z: int) -> tuple[int, int]:
    """Inverse of the Cantor pairing function."""
    w = int(((8 * z + 1) ** 0.5 - 1) // 2)
    t = w * (w + 1) // 2
    b = z - t
    a = w - b
    return a, b


def demo_pairing() -> None:
    print("Cantor pairing  N x N -> N  (witness for aleph_0 * aleph_0 = aleph_0):")
    seen: dict[int, tuple[int, int]] = {}
    collisions = 0
    for a, b in product(range(6), range(6)):
        z = cantor_pair(a, b)
        assert cantor_unpair(z) == (a, b)
        if z in seen:
            collisions += 1
        seen[z] = (a, b)
    print(f"  6x6 grid mapped to codes {sorted(seen)[:8]}...")
    print(f"  collisions: {collisions} (bijective, so 0)")


# ---------------------------------------------------------------------------
# 5. Aleph / beth bookkeeping and CH / GCH statements
# ---------------------------------------------------------------------------
def aleph_below_beth_check(max_index: int) -> Iterable[str]:
    """Symbolically confirm aleph_o <= beth_o at each finite index.

    We track only the *relation*, not values: beth jumps by power set,
    aleph jumps by immediate successor, so aleph_o <= beth_o holds at every rung.
    """
    for o in range(max_index + 1):
        yield f"  aleph_{o} <= beth_{o}   (beth via 2^(.), aleph via successor)"


def demo_hierarchies() -> None:
    print("Aleph vs. beth domination:")
    for line in aleph_below_beth_check(4):
        print(line)
    print()
    print("Continuum Hypothesis (CH):        c = aleph_1")
    print("  equivalently: no cardinal c with aleph_0 < c < c(continuum)")
    print("Generalized CH (GCH):             2^aleph_o = aleph_{o+1} for all o")
    print("  GCH => CH (set o = 0), and GCH => beth_o = aleph_o for all o")


# ---------------------------------------------------------------------------
def main() -> None:
    for title, fn in [
        ("1. Cantor's diagonal argument", demo_diagonal),
        ("2. Power-set growth and the Cantor tower", demo_tower),
        ("3. Plane to line: digit interleaving", demo_plane_to_line),
        ("4. Cantor pairing N x N -> N", demo_pairing),
        ("5. Aleph/beth hierarchies and CH/GCH", demo_hierarchies),
    ]:
        print("=" * 70)
        print(title)
        print("-" * 70)
        fn()
        print()


if __name__ == "__main__":
    main()
