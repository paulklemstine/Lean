"""
Numerical demonstrations for:

    A GF(2) Characterization of Bipartite Partial Duals of Orientable Hypermaps

Everything below is self-contained (standard library only) and uses arithmetic
over GF(2) = {0, 1} with 1 + 1 = 0. We illustrate three things:

  1. The parity dichotomy: a length-l hyperedge boundary cycle is 2-colorable
     (admits an all-crossing state) iff l is even  (for l >= 3).
  2. The crossing operator cross_J assembled from a symmetric interlacement
     form J, its GF(2) kernel = the all-crossing directions.
  3. The affine bijection C(phi) = phi + t between all-crossing directions and
     bipartite partial duals, and the resulting power-of-two count
     |bipartite duals| = |ker cross_J| = 2^(dim ker).

Run:  python demo.py
"""

from __future__ import annotations

from itertools import product
from typing import List, Sequence, Tuple

Vector = Tuple[int, ...]          # a GF(2) vector, entries in {0, 1}
Matrix = List[List[int]]          # a GF(2) matrix, entries in {0, 1}


# --------------------------------------------------------------------------- #
# 1. Parity dichotomy on a cycle                                              #
# --------------------------------------------------------------------------- #
def cycle_is_two_colorable(length: int) -> bool:
    """Return True iff the cycle graph C_length admits a proper 2-coloring.

    A proper 2-coloring alternates 0,1,0,1,... around the loop and must close
    up consistently; this is possible iff `length` is even. (For length < 3 the
    graph is degenerate; we return True vacuously for length <= 2.)
    """
    if length <= 2:
        return True
    return length % 2 == 0


def cycle_chromatic_number(length: int) -> int:
    """Chromatic number of C_length for length >= 3: 2 if even, 3 if odd."""
    if length < 3:
        raise ValueError("cycle needs length >= 3")
    return 2 if length % 2 == 0 else 3


def all_crossing_exists(hyperedge_lengths: Sequence[int]) -> bool:
    """Global nonemptiness: an all-crossing direction exists iff every
    hyperedge has even length."""
    return all(length % 2 == 0 for length in hyperedge_lengths)


# --------------------------------------------------------------------------- #
# 2. The GF(2) crossing operator and its kernel                              #
# --------------------------------------------------------------------------- #
def cross_apply(J: Matrix, x: Vector) -> Vector:
    """Apply the crossing operator: (cross_J x)(e) = sum_e' J[e][e'] * x[e']
    with all arithmetic mod 2."""
    n = len(J)
    return tuple(sum(J[e][ep] * x[ep] for ep in range(n)) % 2 for e in range(n))


def is_symmetric(J: Matrix) -> bool:
    """Check that the interlacement form J is symmetric over GF(2)."""
    n = len(J)
    return all(J[a][b] == J[b][a] for a in range(n) for b in range(n))


def gf2_kernel(J: Matrix) -> List[Vector]:
    """Enumerate the full GF(2) kernel {x : cross_J x = 0} by brute force.

    Returned as an explicit list of vectors. (Brute force is fine for the small
    demo instances; for large n use Gaussian elimination over GF(2).)
    """
    n = len(J)
    zero = tuple(0 for _ in range(n))
    return [x for x in product((0, 1), repeat=n) if cross_apply(J, x) == zero]


def vec_add(x: Vector, y: Vector) -> Vector:
    """Vector addition over GF(2) = symmetric difference of the indicated sets."""
    return tuple((a + b) % 2 for a, b in zip(x, y))


# --------------------------------------------------------------------------- #
# 3. Bipartite duals as a coset, and the affine bijection                    #
# --------------------------------------------------------------------------- #
def bipartite_duals(J: Matrix, t: Vector) -> List[Vector]:
    """The subsets A with cross_J A = cross_J t, i.e. the coset t + ker cross_J.

    Enumerated directly from the definition (cross_J A == cross_J t)."""
    n = len(J)
    target = cross_apply(J, t)
    return [A for A in product((0, 1), repeat=n) if cross_apply(J, A) == target]


def crossing_set_map(phi: Vector, t: Vector) -> Vector:
    """C(phi) = phi + t : all-crossing direction -> bipartite partial dual."""
    return vec_add(phi, t)


# --------------------------------------------------------------------------- #
# Demonstrations                                                              #
# --------------------------------------------------------------------------- #
def demo_parity() -> None:
    print("=" * 68)
    print("1. Parity dichotomy on hyperedge boundary cycles")
    print("=" * 68)
    for length in range(3, 9):
        chi = cycle_chromatic_number(length)
        print(f"  C_{length}: chromatic number = {chi:d}   "
              f"2-colorable (all-crossing OK)? {cycle_is_two_colorable(length)}")
    print()
    for lengths in ([4, 6, 8], [4, 5, 8], [6, 6]):
        print(f"  hyperedge lengths {lengths} -> all-crossing direction "
              f"exists? {all_crossing_exists(lengths)}")
    print()


def _report_instance(name: str, J: Matrix, t: Vector) -> None:
    assert is_symmetric(J), "interlacement form must be symmetric"
    kernel = gf2_kernel(J)                     # all-crossing directions
    duals = bipartite_duals(J, t)             # bipartite partial duals
    mapped = [crossing_set_map(phi, t) for phi in kernel]  # C(kernel)

    print(f"--- {name} ---")
    print(f"  symmetric interlacement form J = {J}")
    print(f"  reference twist t = {t}")
    print(f"  |all-crossing directions| = |ker cross_J| = {len(kernel)}")
    print(f"  |bipartite partial duals|                  = {len(duals)}")
    dim = len(kernel).bit_length() - 1
    print(f"  count is a power of two: 2^{dim} = {2 ** dim}  "
          f"(equal? {len(kernel) == 2 ** dim})")
    # The crossing-set map C(phi)=phi+t is a bijection ker -> bipartite duals.
    bijection_ok = sorted(mapped) == sorted(duals) and len(set(mapped)) == len(mapped)
    print(f"  C(phi)=phi+t maps all-crossing dirs bijectively onto "
          f"bipartite duals? {bijection_ok}")
    print(f"  equinumerous? {len(kernel) == len(duals)}")
    print()


def demo_bijection() -> None:
    print("=" * 68)
    print("2/3. Crossing operator, kernel, and the affine bijection")
    print("=" * 68)

    # A rank-deficient symmetric form: nontrivial kernel -> many duals.
    J1: Matrix = [
        [0, 1, 1],
        [1, 0, 1],
        [1, 1, 0],
    ]
    _report_instance("triangle interlacement (n=3)", J1, t=(1, 0, 0))

    # A full-rank symmetric form: trivial kernel -> unique bipartite dual.
    J2: Matrix = [
        [1, 0],
        [0, 1],
    ]
    _report_instance("identity interlacement (n=2)", J2, t=(1, 1))

    # A larger example with a 2-dimensional kernel -> 4 bipartite duals.
    J3: Matrix = [
        [0, 1, 1, 0],
        [1, 0, 0, 1],
        [1, 0, 0, 1],
        [0, 1, 1, 0],
    ]
    _report_instance("paired interlacement (n=4)", J3, t=(1, 0, 0, 0))


def main() -> None:
    demo_parity()
    demo_bijection()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
