"""Numerical demonstrations for:

    The opposite-semicube Helly property characterizes harmonic-evenness
    in Cartesian products of partial cubes.

A partial cube is represented in the *coordinate model*: a vertex is a tuple of
booleans (its coordinates / Theta-classes), and a partial cube is a list of such
tuples (the image of an isometric embedding into a hypercube).

Key notions implemented here:
  * semicube(V, i, b)       - vertices of V whose i-th coordinate equals b
  * is_balanced(V, i)       - the two opposite semicubes of cut i have equal size
  * is_harmonic_even(V)     - every cut is balanced
  * has_osh(V)              - opposite-semicube Helly property: every cut admits a
                              bijection between its two opposite semicubes
  * cartesian_product(P, R) - the box product on the disjoint union of coordinates

The central facts demonstrated:
  Theorem 3.1: has_osh(V) == is_harmonic_even(V)   (matchability == balance)
  Theorem 4.3: is_harmonic_even(P box R) == (is_harmonic_even(P) and is_harmonic_even(R))
  Theorem 4.4: main characterization, obtained by combining the two.
"""

from __future__ import annotations

from itertools import product
from typing import Dict, List, Optional, Tuple

Vertex = Tuple[bool, ...]
PartialCube = List[Vertex]


# --------------------------------------------------------------------------- #
# Basic partial-cube constructions in the coordinate model
# --------------------------------------------------------------------------- #
def hypercube(n: int) -> PartialCube:
    """Q_n: all 2**n binary vectors of length n."""
    return [tuple(bits) for bits in product([False, True], repeat=n)]


def path(n: int) -> PartialCube:
    """P_n on n vertices: the staircase embedding into Q_{n-1}.

    Vertex j (0 <= j < n) has its first j coordinates True, the rest False.
    Consecutive vertices differ in exactly one coordinate.
    """
    return [tuple(k < j for k in range(n - 1)) for j in range(n)]


def even_cycle(k: int) -> PartialCube:
    """C_{2k}: standard isometric embedding into Q_k.

    Vertex j (0 <= j < 2k) has coordinate i True iff i < j <= i + k (mod 2k),
    so each coordinate flips exactly twice (antipodally) and carries exactly k
    True's around the cycle.
    """
    m = 2 * k
    verts: PartialCube = []
    for j in range(m):
        bits = []
        for i in range(k):
            # coordinate i is True on the arc (i, i+k]  (indices mod 2k)
            offset = (j - i) % m
            bits.append(1 <= offset <= k)
        verts.append(tuple(bits))
    return verts


# --------------------------------------------------------------------------- #
# Semicubes, balance, harmonic-evenness, and the Helly property
# --------------------------------------------------------------------------- #
def semicube(V: PartialCube, i: int, b: bool) -> PartialCube:
    """Vertices of V whose i-th coordinate equals b."""
    return [v for v in V if v[i] == b]


def num_coords(V: PartialCube) -> int:
    return len(V[0]) if V else 0


def is_balanced(V: PartialCube, i: int) -> bool:
    """Cut i is balanced iff its two opposite semicubes are equinumerous."""
    return len(semicube(V, i, True)) == len(semicube(V, i, False))


def is_harmonic_even(V: PartialCube) -> bool:
    """Every cut of V is balanced."""
    return all(is_balanced(V, i) for i in range(num_coords(V)))


def cut_matching(V: PartialCube, i: int) -> Optional[Dict[Vertex, Vertex]]:
    """A bijection between the two opposite semicubes of cut i, if one exists.

    For finite sets a bijection exists iff the sizes are equal; when so, we
    return the explicit index-order pairing (a witness for the Helly property).
    """
    left = semicube(V, i, True)
    right = semicube(V, i, False)
    if len(left) != len(right):
        return None
    return dict(zip(left, right))


def has_osh(V: PartialCube) -> bool:
    """Opposite-semicube Helly property: every cut admits a matching."""
    return all(cut_matching(V, i) is not None for i in range(num_coords(V)))


# --------------------------------------------------------------------------- #
# Cartesian (box) product on the disjoint union of coordinate sets
# --------------------------------------------------------------------------- #
def cartesian_product(P: PartialCube, R: PartialCube) -> PartialCube:
    """P box R: vertices are elim(a, b) = a-coords followed by b-coords."""
    return [a + b for a in P for b in R]


# --------------------------------------------------------------------------- #
# Reporting helpers
# --------------------------------------------------------------------------- #
def cut_profile(V: PartialCube) -> List[Tuple[int, int]]:
    """For each cut, the (#True, #False) semicube sizes."""
    return [
        (len(semicube(V, i, True)), len(semicube(V, i, False)))
        for i in range(num_coords(V))
    ]


def describe(name: str, V: PartialCube) -> None:
    prof = cut_profile(V)
    print(f"{name}: {len(V)} vertices, {num_coords(V)} cuts")
    print(f"    cut (True,False) sizes : {prof}")
    print(f"    harmonic-even          : {is_harmonic_even(V)}")
    print(f"    opposite-semicube Helly: {has_osh(V)}")
    assert is_harmonic_even(V) == has_osh(V), "Theorem 3.1 violated!"


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_basic_shapes() -> None:
    print("=" * 70)
    print("Basic partial cubes: balance vs. matchability (Theorem 3.1)")
    print("=" * 70)
    describe("Q_3 (hypercube)", hypercube(3))
    describe("C_6 (even cycle)", even_cycle(3))
    describe("P_4 (path)", path(4))
    describe("P_2 = Q_1 (edge)", path(2))
    print()


def demo_multiplicativity() -> None:
    print("=" * 70)
    print("Multiplicativity of balance under products (Theorems 4.3 & 4.4)")
    print("=" * 70)
    factors = {
        "Q_2": hypercube(2),
        "C_6": even_cycle(3),
        "P_4": path(4),
    }
    for na, A in factors.items():
        for nb, B in factors.items():
            prod = cartesian_product(A, B)
            he_prod = is_harmonic_even(prod)
            he_both = is_harmonic_even(A) and is_harmonic_even(B)
            osh_prod = has_osh(prod)
            print(f"{na} box {nb}: {len(prod)} vertices")
            print(f"    harmonic-even(product)      = {he_prod}")
            print(f"    harmonic-even(A) and (B)    = {he_both}")
            print(f"    opposite-semicube Helly     = {osh_prod}")
            # Theorem 4.3 and Theorem 4.4:
            assert he_prod == he_both, "Theorem 4.3 violated!"
            assert osh_prod == he_both, "Theorem 4.4 violated!"
    print("    All product identities verified.\n")


def demo_cancellation() -> None:
    print("=" * 70)
    print("The cancellation step of Theorem 4.3 made explicit")
    print("=" * 70)
    P, R = path(4), hypercube(2)
    prod = cartesian_product(P, R)
    print(f"|R| = |Q_2| = {len(R)}")
    for i in range(num_coords(P)):
        pt, pf = len(semicube(P, i, True)), len(semicube(P, i, False))
        # coordinate i of P sits at index i of the product
        qt = len(semicube(prod, i, True))
        qf = len(semicube(prod, i, False))
        print(
            f"  P-cut {i}: ({pt},{pf})  ->  product ({qt},{qf})  "
            f"=  ({pt}*{len(R)},{pf}*{len(R)});  divide by {len(R)} -> ({qt // len(R)},{qf // len(R)})"
        )
        assert (qt, qf) == (pt * len(R), pf * len(R))
    print("    Product-cut sizes are factor-cut sizes times |R|.\n")


def main() -> None:
    demo_basic_shapes()
    demo_multiplicativity()
    demo_cancellation()
    print("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
