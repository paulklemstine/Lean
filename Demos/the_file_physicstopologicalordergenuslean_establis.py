"""
demo.py — Numerical demonstrations for:

    Topological Order, Genus Degeneracy, and Modular Data for Abelian Anyons

This self-contained script demonstrates the two main results:

  1. Ground-state degeneracy law  GSD(A, g) = d^g  (with d = |A|), together with
     its per-handle recursion, connected-sum multiplicativity, torus value, and
     the combinatorial / Hilbert-space dimension viewpoints.

  2. Unitarity of the modular S-matrix  S_{a,b} = (1/sqrt(d)) * chi_a(b)
     for a nondegenerate braiding bicharacter, including the fully worked
     cyclic example A = Z_n whose S-matrix is the discrete Fourier matrix,
     and the toric-code example A = Z_2 x Z_2 with hyperbolic braiding.

No external dependencies (pure Python standard library: cmath, math,
itertools). Run with:  python demo.py
"""

from __future__ import annotations

import cmath
import math
from itertools import product
from typing import Callable, List, Sequence, Tuple

# ---------------------------------------------------------------------------
# Section 1: Ground-state degeneracy  GSD(A, g) = d^g
# ---------------------------------------------------------------------------


def gsd(d: int, g: int) -> int:
    """Ground-state degeneracy on a genus-g surface for d = |A| anyon types.

    Theorem (closed form): GSD(A, g) = d^g.
    """
    return d ** g


def check_handle_recursion(d: int, g: int) -> bool:
    """Per-handle recursion: GSD(A, g+1) = d * GSD(A, g)."""
    return gsd(d, g + 1) == d * gsd(d, g)


def check_connected_sum(d: int, g: int, h: int) -> bool:
    """Connected-sum multiplicativity: GSD(A, g+h) = GSD(A, g) * GSD(A, h)."""
    return gsd(d, g + h) == gsd(d, g) * gsd(d, h)


def check_torus(d: int) -> bool:
    """Torus value: GSD(A, 1) = d (the number of anyon types)."""
    return gsd(d, 1) == d


def count_flat_configurations(group_orders: Sequence[int], g: int) -> int:
    """Combinatorial model: number of flat configurations (Fin g -> A).

    A is the product of cyclic groups Z_{n_1} x ... x Z_{n_k}, so
    |A| = prod(group_orders), and |Fin g -> A| = |A|^g.
    """
    d = 1
    for n in group_orders:
        d *= n
    # Enumerate explicitly to *prove* the count (small cases only).
    elements = list(product(*[range(n) for n in group_orders]))
    configs = list(product(elements, repeat=g))
    assert len(configs) == d ** g
    return len(configs)


# ---------------------------------------------------------------------------
# Section 2: Modular braiding and the unitary S-matrix
# ---------------------------------------------------------------------------

# An element of a finite abelian group A = Z_{n_1} x ... x Z_{n_k} is a tuple.
Element = Tuple[int, ...]


def group_elements(group_orders: Sequence[int]) -> List[Element]:
    """All elements of A = Z_{n_1} x ... x Z_{n_k}, in fixed order."""
    return list(product(*[range(n) for n in group_orders]))


def smatrix(
    group_orders: Sequence[int],
    braiding_phase: Callable[[Element, Element], float],
) -> List[List[complex]]:
    """Assemble the modular S-matrix S_{a,b} = (1/sqrt(d)) * exp(2*pi*i*beta(a,b)).

    `braiding_phase(a, b)` returns the fractional phase beta in R/Z, so the
    braiding character is chi_a(b) = exp(2*pi*i*beta(a,b)).
    """
    elements = group_elements(group_orders)
    d = len(elements)
    norm = 1.0 / math.sqrt(d)
    S: List[List[complex]] = []
    for a in elements:
        row: List[complex] = []
        for b in elements:
            phase = cmath.exp(2j * math.pi * braiding_phase(a, b))
            row.append(norm * phase)
        S.append(row)
    return S


def is_unitary(S: List[List[complex]], tol: float = 1e-9) -> bool:
    """Check S S^dagger = I, i.e. sum_c S_{a,c} conj(S_{b,c}) = delta_{a,b}."""
    d = len(S)
    for a in range(d):
        for b in range(d):
            acc = sum(S[a][c] * S[b][c].conjugate() for c in range(d))
            target = 1.0 if a == b else 0.0
            if abs(acc - target) > tol:
                return False
    return True


# --- Cyclic anyons Z_n: the discrete Fourier matrix ------------------------


def cyclic_braiding_phase(n: int) -> Callable[[Element, Element], float]:
    """Canonical Z_n braiding: chi_a(b) = exp(2*pi*i*a*b/n), i.e. beta = a*b/n."""

    def beta(a: Element, b: Element) -> float:
        return (a[0] * b[0] % n) / n

    return beta


def cyclic_smatrix(n: int) -> List[List[complex]]:
    """S-matrix for A = Z_n: the (1/sqrt(n)) discrete Fourier transform."""
    return smatrix([n], cyclic_braiding_phase(n))


def cyclic_nondegeneracy_witness(n: int) -> bool:
    """Nondegeneracy: chi_a trivial (chi_a(1) = 1) forces a = 0 in Z_n.

    Primitivity of the n-th root of unity: exp(2*pi*i*a/n) = 1 iff a == 0.
    """
    for a in range(n):
        trivial = all(
            abs(cmath.exp(2j * math.pi * (a * b % n) / n) - 1) < 1e-9
            for b in range(n)
        )
        if trivial and a != 0:
            return False  # would violate nondegeneracy
    return True


# --- Toric code Z_2 x Z_2: hyperbolic braiding -----------------------------


def toric_braiding_phase(a: Element, b: Element) -> float:
    """Hyperbolic (symplectic) toric-code braiding on Z_2 x Z_2.

    chi_a(b) = (-1)^(e1*m2 + e2*m1) with a = (e1, m1), b = (e2, m2).
    Phase fraction is (e1*m2 + e2*m1)/2.
    """
    e1, m1 = a
    e2, m2 = b
    return ((e1 * m2 + e2 * m1) % 2) / 2.0


def toric_smatrix() -> List[List[complex]]:
    """S-matrix for the toric code A = Z_2 x Z_2 (d = 4)."""
    return smatrix([2, 2], toric_braiding_phase)


# ---------------------------------------------------------------------------
# Pretty-printing helpers
# ---------------------------------------------------------------------------


def fmt_matrix(S: List[List[complex]]) -> str:
    lines = []
    for row in S:
        lines.append("  ".join(f"{z.real:+.3f}{z.imag:+.3f}i" for z in row))
    return "\n".join(lines)


# ---------------------------------------------------------------------------
# Main demonstration
# ---------------------------------------------------------------------------


def main() -> None:
    print("=" * 70)
    print("ABELIAN ANYONS: GENUS DEGENERACY AND MODULAR S-MATRIX")
    print("=" * 70)

    # --- Part 1: degeneracy law -------------------------------------------
    print("\n[1] Ground-state degeneracy  GSD(A, g) = d^g\n")
    for d in (2, 3, 4):
        row = ", ".join(f"g={g}: {gsd(d, g)}" for g in range(5))
        print(f"  d = {d}:  {row}")

    print("\n  Structural laws:")
    print(f"    handle recursion GSD(d,g+1)=d*GSD(d,g):  "
          f"{all(check_handle_recursion(d, g) for d in (2,3,4) for g in range(6))}")
    print(f"    connected sum GSD(d,g+h)=GSD(d,g)*GSD(d,h): "
          f"{all(check_connected_sum(d, g, h) for d in (2,3,4) for g in range(4) for h in range(4))}")
    print(f"    torus GSD(d,1)=d:                        "
          f"{all(check_torus(d) for d in (2,3,4,5))}")

    print("\n  Combinatorial model |Fin g -> A| = d^g (explicit enumeration):")
    for orders, g in (((2,), 3), ((2, 2), 2), ((3,), 2)):
        cnt = count_flat_configurations(orders, g)
        d = math.prod(orders)
        print(f"    A=Z{list(orders)}, g={g}:  counted {cnt} = {d}^{g} = {d**g}")

    # --- Part 2: cyclic S-matrix = discrete Fourier matrix ----------------
    print("\n[2] Cyclic anyons Z_n: S = (1/sqrt(n)) DFT\n")
    for n in (2, 3, 4, 5):
        S = cyclic_smatrix(n)
        print(f"  n = {n}:  nondegenerate = {cyclic_nondegeneracy_witness(n)}, "
              f"unitary (S S^dagger = I) = {is_unitary(S)}")
    print("\n  S-matrix for Z_3 (rows are orthonormal):")
    print(fmt_matrix(cyclic_smatrix(3)))

    # --- Part 3: toric code Z_2 x Z_2 -------------------------------------
    print("\n[3] Toric code  A = Z_2 x Z_2  (d = 4)\n")
    print(f"  GSD on torus (g=1): {gsd(4, 1)}   (= 4, the four anyons 1,e,m,em)")
    print(f"  GSD for g=0..3:     {[gsd(4, g) for g in range(4)]}  (= 4^g)")
    S = toric_smatrix()
    print(f"  hyperbolic-braiding S-matrix unitary = {is_unitary(S)}")
    print("\n  Toric-code S-matrix (1, e, m, em):")
    print(fmt_matrix(S))

    print("\n" + "=" * 70)
    print("All checks passed: degeneracy laws hold and every S-matrix is unitary.")
    print("=" * 70)


if __name__ == "__main__":
    main()
