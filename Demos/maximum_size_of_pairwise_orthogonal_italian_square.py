"""Numerical demonstrations for Mutually Orthogonal Italian (Latin) Squares.

This self-contained script illustrates the main results:

  * Every mutually orthogonal family of Italian squares of order n has at
    most n - 1 members (the upper bound, theorem `card_le_card_sub_one`).
  * Over a finite field of order n the affine squares S_a(i, j) = a*i + j
    for the n - 1 nonzero slopes a attain the bound (theorems
    `affineSquare_orthogonal`, `exists_mols_card_eq_card_sub_one`,
    `maximum_mols_eq_card_sub_one`, `exists_mols_prime_power`).
  * A mutually orthogonal family is the same data as an orthogonal array
    of strength 2, index 1 (`oaOfMols`, `isOA_oaOfMols`).

For prime orders the field is Z/nZ; for prime-power orders we build the
field GF(p^k) from scratch via polynomial arithmetic modulo an irreducible
polynomial over GF(p). No third-party libraries are required.
"""

from __future__ import annotations

from itertools import combinations
from typing import Callable, List, Sequence, Tuple

Square = List[List[int]]  # square[i][j] is the symbol in row i, column j


# --------------------------------------------------------------------------
# Validation primitives
# --------------------------------------------------------------------------
def is_latin_square(square: Square, n: int) -> bool:
    """Return True iff `square` is an Italian (Latin) square of order n:
    every row and every column is a permutation of {0, ..., n-1}."""
    target = set(range(n))
    if len(square) != n or any(len(row) != n for row in square):
        return False
    for i in range(n):
        if set(square[i]) != target:
            return False
        if {square[r][i] for r in range(n)} != target:
            return False
    return True


def are_orthogonal(a: Square, b: Square, n: int) -> bool:
    """Return True iff a and b are orthogonal: the superposition map
    (i, j) -> (a[i][j], b[i][j]) hits every ordered pair exactly once."""
    seen: set[Tuple[int, int]] = set()
    for i in range(n):
        for j in range(n):
            pair = (a[i][j], b[i][j])
            if pair in seen:
                return False
            seen.add(pair)
    return len(seen) == n * n


def is_mutually_orthogonal(family: Sequence[Square], n: int) -> bool:
    """Return True iff every square is Latin and every pair is orthogonal."""
    if not all(is_latin_square(sq, n) for sq in family):
        return False
    return all(are_orthogonal(family[s], family[t], n)
               for s, t in combinations(range(len(family)), 2))


# --------------------------------------------------------------------------
# Finite field GF(p^k) via polynomials over GF(p) modulo an irreducible poly
# --------------------------------------------------------------------------
def gf_prime(p: int) -> Tuple[List[int],
                              Callable[[int, int], int],
                              Callable[[int, int], int]]:
    """Field Z/pZ for prime p: (elements, add, mul)."""
    elems = list(range(p))
    return elems, (lambda x, y: (x + y) % p), (lambda x, y: (x * y) % p)


def _poly_mod(poly: Tuple[int, ...], modulus: Tuple[int, ...],
              p: int) -> Tuple[int, ...]:
    """Reduce a polynomial (low-degree-first coeffs) modulo `modulus` over GF(p)."""
    coeffs = list(poly)
    deg_m = len(modulus) - 1
    while len(coeffs) - 1 >= deg_m and any(c % p for c in coeffs):
        d = len(coeffs) - 1
        lead = coeffs[d] % p
        if lead:
            for i, mc in enumerate(modulus):
                coeffs[d - deg_m + i] = (coeffs[d - deg_m + i] - lead * mc) % p
        coeffs.pop()
    while len(coeffs) > 1 and coeffs[-1] % p == 0:
        coeffs.pop()
    return tuple(c % p for c in coeffs)


def gf_prime_power(p: int, k: int, modulus: Tuple[int, ...]
                   ) -> Tuple[List[int],
                              Callable[[int, int], int],
                              Callable[[int, int], int]]:
    """Field GF(p^k) = GF(p)[x]/(modulus), elements encoded as base-p integers.

    `modulus` is an irreducible polynomial of degree k over GF(p), given
    low-degree-first. Elements are integers 0..p^k-1 whose base-p digits are
    the polynomial coefficients."""
    n = p ** k

    def to_poly(e: int) -> Tuple[int, ...]:
        digits = []
        for _ in range(k):
            digits.append(e % p)
            e //= p
        return tuple(digits)

    def to_int(poly: Tuple[int, ...]) -> int:
        return sum((c % p) * (p ** i) for i, c in enumerate(poly))

    def add(x: int, y: int) -> int:
        px, py = to_poly(x), to_poly(y)
        return to_int(tuple((px[i] + py[i]) % p for i in range(k)))

    def mul(x: int, y: int) -> int:
        px, py = to_poly(x), to_poly(y)
        prod = [0] * (2 * k)
        for i in range(k):
            for j in range(k):
                prod[i + j] = (prod[i + j] + px[i] * py[j]) % p
        reduced = _poly_mod(tuple(prod), modulus, p)
        reduced = reduced + (0,) * (k - len(reduced))
        return to_int(reduced[:k])

    return list(range(n)), add, mul


# --------------------------------------------------------------------------
# The affine construction S_a(i, j) = a*i + j
# --------------------------------------------------------------------------
def affine_square(a: int, elems: List[int],
                  add: Callable[[int, int], int],
                  mul: Callable[[int, int], int]) -> Square:
    """Build the affine square S_a(i, j) = a*i + j over the given field."""
    n = len(elems)
    return [[add(mul(a, i), j) for j in range(n)] for i in range(n)]


def affine_mols_family(elems: List[int],
                       add: Callable[[int, int], int],
                       mul: Callable[[int, int], int]) -> List[Square]:
    """The full family {S_a : a != 0}, of size n - 1."""
    return [affine_square(a, elems, add, mul) for a in elems if a != 0]


# --------------------------------------------------------------------------
# Orthogonal array from a family (oaOfMols) and its verification
# --------------------------------------------------------------------------
def oa_of_mols(family: Sequence[Square], n: int) -> List[List[int]]:
    """Orthogonal array OA(n, k+2): one run per cell, columns = [row, col, S_t...]."""
    runs: List[List[int]] = []
    for i in range(n):
        for j in range(n):
            runs.append([i, j] + [sq[i][j] for sq in family])
    return runs


def is_orthogonal_array(runs: Sequence[Sequence[int]], n: int) -> bool:
    """Strength-2 index-1 check: every pair of columns realizes every pair once."""
    m = len(runs[0])
    for c, d in combinations(range(m), 2):
        seen: set[Tuple[int, int]] = set()
        for run in runs:
            pair = (run[c], run[d])
            if pair in seen:
                return False
            seen.add(pair)
        if len(seen) != n * n:
            return False
    return True


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------
def demo_prime_order(p: int) -> None:
    print(f"=== Prime order n = {p}  (field Z/{p}Z) ===")
    elems, add, mul = gf_prime(p)
    family = affine_mols_family(elems, add, mul)
    print(f"  Constructed {len(family)} affine squares (bound n-1 = {p - 1}).")
    print(f"  All squares Latin & mutually orthogonal: "
          f"{is_mutually_orthogonal(family, p)}")
    runs = oa_of_mols(family, p)
    print(f"  Equivalent orthogonal array OA({p}, {len(runs[0])}) valid: "
          f"{is_orthogonal_array(runs, p)}")
    print()


def demo_prime_power(p: int, k: int, modulus: Tuple[int, ...]) -> None:
    n = p ** k
    print(f"=== Prime-power order n = {p}^{k} = {n}  (field GF({p}^{k})) ===")
    elems, add, mul = gf_prime_power(p, k, modulus)
    family = affine_mols_family(elems, add, mul)
    print(f"  Constructed {len(family)} affine squares (bound n-1 = {n - 1}).")
    print(f"  All squares Latin & mutually orthogonal: "
          f"{is_mutually_orthogonal(family, n)}")
    runs = oa_of_mols(family, n)
    print(f"  Equivalent orthogonal array OA({n}, {len(runs[0])}) valid: "
          f"{is_orthogonal_array(runs, n)}")
    print()


def demo_print_graeco_latin(p: int) -> None:
    """Show a Graeco-Latin square: superimpose two orthogonal squares."""
    print(f"=== A Graeco-Latin square of order {p} (two orthogonal squares) ===")
    elems, add, mul = gf_prime(p)
    family = affine_mols_family(elems, add, mul)
    a, b = family[0], family[1]
    for i in range(p):
        print("  " + "  ".join(f"({a[i][j]},{b[i][j]})" for j in range(p)))
    print(f"  Each of the {p * p} ordered pairs appears exactly once: "
          f"{are_orthogonal(a, b, p)}")
    print()


if __name__ == "__main__":
    # Prime orders: bound n-1 attained.
    for prime in (2, 3, 5, 7):
        demo_prime_order(prime)

    # Prime-power order 4 = 2^2, with irreducible x^2 + x + 1 over GF(2).
    # Coeffs low-first: 1 + 1*x + 1*x^2  ->  (1, 1, 1).
    demo_prime_power(2, 2, (1, 1, 1))

    # Prime-power order 9 = 3^2, with irreducible x^2 + 1 over GF(3).
    # Coeffs low-first: 1 + 0*x + 1*x^2  ->  (1, 0, 1).
    demo_prime_power(3, 2, (1, 0, 1))

    # A concrete Graeco-Latin square of order 5.
    demo_print_graeco_latin(5)

    print("All demonstrations completed: the maximum family size equals n - 1.")


"""Visualization: a complete set of n-1 mutually orthogonal Italian squares.

Renders the affine squares S_a(i, j) = a*i + j over Z/nZ (n prime) as a row
of colored grids, and a superimposed Graeco-Latin square for the first two,
illustrating that every ordered pair of symbols occurs exactly once.

Requires matplotlib. Run:  python visualize.py
"""

from __future__ import annotations

from typing import List

import matplotlib.pyplot as plt
import numpy as np

Square = List[List[int]]


def affine_square(a: int, n: int) -> Square:
    """S_a(i, j) = (a*i + j) mod n over Z/nZ."""
    return [[(a * i + j) % n for j in range(n)] for i in range(n)]


def plot_mols(n: int = 5) -> None:
    slopes = [a for a in range(n) if a != 0]            # n - 1 nonzero slopes
    squares = [affine_square(a, n) for a in slopes]

    fig, axes = plt.subplots(1, len(squares) + 1,
                             figsize=(3 * (len(squares) + 1), 3))

    for ax, a, sq in zip(axes[:-1], slopes, squares):
        ax.imshow(np.array(sq), cmap="viridis")
        for i in range(n):
            for j in range(n):
                ax.text(j, i, str(sq[i][j]), ha="center", va="center",
                        color="white", fontsize=10)
        ax.set_title(f"$S_{a}(i,j)={a}i+j$")
        ax.set_xticks([]); ax.set_yticks([])

    # Superposition of the first two squares: a Graeco-Latin square.
    a0, a1 = squares[0], squares[1]
    ax = axes[-1]
    combo = np.array([[a0[i][j] * n + a1[i][j] for j in range(n)]
                      for i in range(n)])
    ax.imshow(combo, cmap="twilight")
    for i in range(n):
        for j in range(n):
            ax.text(j, i, f"{a0[i][j]},{a1[i][j]}", ha="center", va="center",
                    color="white", fontsize=8)
    ax.set_title("Superposition: all pairs once")
    ax.set_xticks([]); ax.set_yticks([])

    fig.suptitle(f"A complete set of {n - 1} mutually orthogonal "
                 f"Italian squares of order {n}", fontsize=13)
    fig.tight_layout()
    fig.savefig("mols_visualization.png", dpi=150)
    print("Saved mols_visualization.png")


if __name__ == "__main__":
    plot_mols(5)
