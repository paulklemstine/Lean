"""
Tropical Dreams: The Field with One Element Meets Tropical Geometry
==================================================================

Numerical demonstration of the Vertex-Euler Correspondence.

For a product of standard simplices  P = Delta^{n_1} x ... x Delta^{n_k}, the
base change to Z is the toric variety  X_P = P^{n_1} x ... x P^{n_k}  (a product
of complex projective spaces). This script verifies, for many tuples
(n_1, ..., n_k):

    chi(X_P)  =  prod_j (n_j + 1)  =  #vertices(P)  =  #F_1-points(P),

together with the two structural mechanisms behind the identity:

    * odd Betti numbers of X_P vanish  (so the alternating sum stops alternating),
    * chi(X_P) = total Betti number B(X_P)  (sign-free counting),
    * the Poincare polynomial P_{X_P}(t) is palindromic  (Poincare duality /
      symmetry of the h-vector).

Pure standard library; run with:  python demo.py
"""

from __future__ import annotations

from itertools import product as iproduct
from typing import List, Tuple


# --------------------------------------------------------------------------- #
#  F_1 / tropical side: polytopes and vertex counts                           #
# --------------------------------------------------------------------------- #

def simplex_vertex_count(n: int) -> int:
    """Number of vertices (F_1-points) of the standard n-simplex: n + 1."""
    return n + 1


def product_vertex_count(dims: Tuple[int, ...]) -> int:
    """#vertices of a product of simplices = product of vertex counts."""
    total = 1
    for n in dims:
        total *= simplex_vertex_count(n)
    return total


# --------------------------------------------------------------------------- #
#  Classical side: Betti numbers, Poincare polynomials, Euler characteristic  #
# --------------------------------------------------------------------------- #

def projective_space_poincare(n: int) -> List[int]:
    """
    Poincare polynomial coefficients of P^n as a list [b_0, b_1, ..., b_{2n}]:
    b_{2i} = 1 for 0 <= i <= n, all odd Betti numbers 0.
    So the list is [1, 0, 1, 0, ..., 1] of length 2n + 1.
    """
    coeffs = [0] * (2 * n + 1)
    for i in range(n + 1):
        coeffs[2 * i] = 1
    return coeffs


def polynomial_product(a: List[int], b: List[int]) -> List[int]:
    """Cauchy product (convolution) of two coefficient lists."""
    result = [0] * (len(a) + len(b) - 1)
    for i, ai in enumerate(a):
        if ai == 0:
            continue
        for j, bj in enumerate(b):
            result[i + j] += ai * bj
    return result


def product_poincare(dims: Tuple[int, ...]) -> List[int]:
    """Poincare polynomial of the product of projective spaces P^{n_j}."""
    coeffs: List[int] = [1]  # Poincare polynomial of a point
    for n in dims:
        coeffs = polynomial_product(coeffs, projective_space_poincare(n))
    return coeffs


def euler_characteristic(coeffs: List[int]) -> int:
    """chi = sum_i (-1)^i b_i  =  Poincare polynomial evaluated at t = -1."""
    return sum((-1) ** i * b for i, b in enumerate(coeffs))


def total_betti(coeffs: List[int]) -> int:
    """B = sum_i b_i  =  Poincare polynomial evaluated at t = +1."""
    return sum(coeffs)


def odd_cohomology_vanishes(coeffs: List[int]) -> bool:
    return all(coeffs[i] == 0 for i in range(1, len(coeffs), 2))


def is_palindromic(coeffs: List[int]) -> bool:
    return coeffs == coeffs[::-1]


# --------------------------------------------------------------------------- #
#  The correspondence check                                                    #
# --------------------------------------------------------------------------- #

def check_correspondence(dims: Tuple[int, ...]) -> dict:
    """Compute both sides of the Vertex-Euler Correspondence for one tuple."""
    vertices = product_vertex_count(dims)
    coeffs = product_poincare(dims)
    chi = euler_characteristic(coeffs)
    betti = total_betti(coeffs)
    return {
        "dims": dims,
        "vertices": vertices,
        "euler_characteristic": chi,
        "total_betti": betti,
        "poincare": coeffs,
        "odd_vanishes": odd_cohomology_vanishes(coeffs),
        "palindromic": is_palindromic(coeffs),
        "match": vertices == chi == betti,
    }


def format_poincare(coeffs: List[int]) -> str:
    terms = []
    for i, b in enumerate(coeffs):
        if b == 0:
            continue
        if i == 0:
            terms.append(f"{b}")
        elif i == 1:
            terms.append(f"{b}t")
        else:
            terms.append(f"{b}t^{i}")
    return " + ".join(terms) if terms else "0"


def main() -> None:
    print("=" * 74)
    print(" Vertex-Euler Correspondence:  chi(X_P) = #vertices(P) = #F_1-points")
    print("=" * 74)

    # Enumerate products of up to 3 projective spaces of dimension 1..4.
    all_ok = True
    header = f"{'dims':<16}{'#verts':>8}{'chi':>6}{'B':>6}{'odd=0':>8}{'palin':>8}{'ok':>5}"
    print(header)
    print("-" * len(header))

    ranges = []
    for k in (1, 2, 3):
        for dims in iproduct(range(1, 5), repeat=k):
            if dims == tuple(sorted(dims, reverse=True)):  # avoid permutations
                ranges.append(dims)

    for dims in ranges:
        r = check_correspondence(dims)
        all_ok &= r["match"] and r["odd_vanishes"] and r["palindromic"]
        print(f"{str(dims):<16}{r['vertices']:>8}{r['euler_characteristic']:>6}"
              f"{r['total_betti']:>6}{str(r['odd_vanishes']):>8}"
              f"{str(r['palindromic']):>8}{str(r['match']):>5}")

    print("-" * len(header))
    print(f"ALL CHECKS PASSED: {all_ok}")

    print()
    print("Worked example:  P^2 x P^1  (prism  Delta^2 x Delta^1)")
    r = check_correspondence((2, 1))
    print(f"  Poincare polynomial P_X(t) = {format_poincare(r['poincare'])}")
    print(f"  #vertices            = {r['vertices']}  (= 3 * 2)")
    print(f"  Euler characteristic = {r['euler_characteristic']}")
    print(f"  total Betti number   = {r['total_betti']}")
    print(f"  odd cohomology zero  = {r['odd_vanishes']}")

    print()
    print("Base case sanity:  chi(P^n) = n + 1 = #vertices(Delta^n)")
    for n in range(0, 6):
        c = product_poincare((n,))
        print(f"  P^{n}:  chi = {euler_characteristic(c):>2}, "
              f"vertices(Delta^{n}) = {simplex_vertex_count(n):>2}")


if __name__ == "__main__":
    main()
