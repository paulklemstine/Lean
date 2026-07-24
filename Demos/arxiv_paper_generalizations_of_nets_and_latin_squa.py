"""Numerical demonstrations for the theory of mutually orthogonal Latin squares
(MOLS), the sharp bound ``k <= n - 1``, the corner-tag proof mechanism, and the
sharpness constructions.

All functions are self-contained and use only the Python standard library.

The mathematical objects:

* A **Latin square** of order ``n`` is an ``n x n`` array over the alphabet
  ``{0, ..., n-1}`` in which every symbol appears exactly once in each row and
  exactly once in each column.
* Two Latin squares ``L`` and ``M`` are **orthogonal** if the ``n^2`` ordered
  pairs ``(L[i][j], M[i][j])`` are all distinct.
* A set of **mutually orthogonal Latin squares** (MOLS) is a family that is
  pairwise orthogonal.  The central theorem: for ``n >= 2`` such a family has at
  most ``n - 1`` members, and the bound is attained whenever ``n`` is prime.
"""

from __future__ import annotations

from itertools import combinations
from typing import List, Tuple

Square = List[List[int]]


# --------------------------------------------------------------------------- #
# Basic predicates
# --------------------------------------------------------------------------- #
def is_latin(square: Square, n: int) -> bool:
    """Return True iff ``square`` is a Latin square of order ``n``."""
    symbols = set(range(n))
    for i in range(n):
        if set(square[i]) != symbols:  # row is a permutation
            return False
    for j in range(n):
        if {square[i][j] for i in range(n)} != symbols:  # column is a permutation
            return False
    return True


def is_orthogonal(a: Square, b: Square, n: int) -> bool:
    """Return True iff Latin squares ``a`` and ``b`` are orthogonal."""
    pairs = {(a[i][j], b[i][j]) for i in range(n) for j in range(n)}
    return len(pairs) == n * n


def is_mols(family: List[Square], n: int) -> bool:
    """Return True iff every member is Latin and every pair is orthogonal."""
    if not all(is_latin(sq, n) for sq in family):
        return False
    return all(is_orthogonal(a, b, n) for a, b in combinations(family, 2))


# --------------------------------------------------------------------------- #
# Constructions
# --------------------------------------------------------------------------- #
def cyclic_latin(n: int) -> Square:
    """The addition table L[i][j] = (i + j) mod n -- a Latin square in every order."""
    return [[(i + j) % n for j in range(n)] for i in range(n)]


def affine_square(n: int, slope: int) -> Square:
    """The affine table L[i][j] = (slope * i + j) mod n."""
    return [[(slope * i + j) % n for j in range(n)] for i in range(n)]


def complete_mols_prime(n: int) -> List[Square]:
    """A complete set of n-1 MOLS of prime order ``n`` from the affine slopes 1..n-1.

    Warning: this construction is only guaranteed to yield MOLS when ``n`` is a
    prime (so that Z/nZ is a field and every nonzero slope is invertible).
    """
    return [affine_square(n, a) for a in range(1, n)]


# --------------------------------------------------------------------------- #
# The corner-tag proof mechanism, made computational
# --------------------------------------------------------------------------- #
def corner_tag(square: Square) -> int:
    """The corner tag of a Latin square: the column of the first row whose symbol
    equals the (row 1, column 0) corner entry.

    This is the injective invariant at the heart of the ``k <= n - 1`` bound.
    """
    corner_symbol = square[1][0]
    first_row = square[0]
    return first_row.index(corner_symbol)


def demonstrate_corner_tag_bound(family: List[Square], n: int) -> Tuple[List[int], bool, bool]:
    """Compute the corner tags of a MOLS family and verify the two proof lemmas.

    Returns (tags, all_nonzero, all_distinct).  The theorem guarantees the tags
    are distinct nonzero columns, so ``len(family) <= n - 1``.
    """
    tags = [corner_tag(sq) for sq in family]
    all_nonzero = all(t != 0 for t in tags)
    all_distinct = len(set(tags)) == len(tags)
    return tags, all_nonzero, all_distinct


# --------------------------------------------------------------------------- #
# Driver
# --------------------------------------------------------------------------- #
def _print_square(name: str, square: Square) -> None:
    print(f"  {name}:")
    for row in square:
        print("    " + " ".join(str(x) for x in row))


def main() -> None:
    print("=" * 68)
    print("Mutually Orthogonal Latin Squares: the sharp bound k <= n - 1")
    print("=" * 68)

    # 1. Existence: the cyclic Latin square in several orders.
    print("\n[1] Cyclic Latin squares L[i][j] = (i + j) mod n exist in every order:")
    for n in range(1, 6):
        sq = cyclic_latin(n)
        print(f"    order {n}: is_latin = {is_latin(sq, n)}")

    # 2. Sharpness at order 3: the explicit complete pair.
    print("\n[2] Sharpness at order 3 -- an explicit complete pair of MOLS:")
    A = affine_square(3, 1)
    B = affine_square(3, 2)
    _print_square("A (slope 1)", A)
    _print_square("B (slope 2)", B)
    print(f"    A is Latin: {is_latin(A, 3)}   B is Latin: {is_latin(B, 3)}")
    print(f"    A orthogonal to B: {is_orthogonal(A, B, 3)}")
    print(f"    {{A, B}} is a MOLS family of size 2 = 3 - 1 (the maximum).")

    # 3. Complete MOLS for prime orders, checked against the bound.
    print("\n[3] Complete MOLS of prime order n attain the bound n - 1:")
    for n in (2, 3, 5, 7):
        fam = complete_mols_prime(n)
        ok = is_mols(fam, n)
        print(f"    n = {n}: built {len(fam)} squares (bound n-1 = {n - 1}); "
              f"is_mols = {ok}")

    # 4. The corner-tag mechanism: distinct nonzero tags certify the bound.
    print("\n[4] The corner-tag proof, computationally, for the order-5 family:")
    fam5 = complete_mols_prime(5)
    tags, all_nonzero, all_distinct = demonstrate_corner_tag_bound(fam5, 5)
    print(f"    corner tags: {tags}")
    print(f"    all nonzero (Lemma: avoid column 0): {all_nonzero}")
    print(f"    all distinct (Lemma: injectivity):   {all_distinct}")
    print(f"    => at most n - 1 = 4 squares, and we have {len(fam5)}.")

    # 5. A non-prime cautionary note: slope construction can fail (n = 4).
    print("\n[5] The naive affine slope construction is NOT valid for composite n:")
    fam4 = complete_mols_prime(4)  # slopes 1,2,3 over Z/4Z (not a field)
    print(f"    n = 4 via Z/4Z slopes: is_mols = {is_mols(fam4, 4)} "
          f"(slope 2 is a zero divisor, so square 2 is not even Latin).")
    print(f"    (A genuine complete triple of MOLS of order 4 exists via GF(4).)")

    print("\nAll demonstrations complete.")


if __name__ == "__main__":
    main()
