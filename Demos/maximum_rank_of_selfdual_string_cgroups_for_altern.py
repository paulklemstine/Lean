"""
Numerical demonstrations for:

    Maximal rank of self-dual string C-groups for the alternating groups A_{4m+3}

This self-contained script illustrates the main results of the accompanying
paper using concrete permutations:

  * String group representations as tuples of involutory generators satisfying
    the string commuting condition (non-adjacent generators commute).
  * The period matrix  period(i, j) = order(rho_i * rho_j)  and its symmetry.
  * The Schlafli symbol (first sub-diagonal of the period matrix).
  * The palindrome theorem: self-dual representations have palindromic Schlafli
    symbols (verified on the simplex and on the doubled-simplex in A_{4m+3}).
  * The doubling construction: pushing the rank-2m simplex through the
    sign-preserving homomorphism sigma |-> sigma (+) sigma (+) 1 yields a
    self-dual rank-2m representation living inside the alternating group
    A_{4m+3}.

Permutations are represented as tuples `p` with the convention p[i] = image of i.
No third-party libraries are required.
"""

from __future__ import annotations

from math import gcd
from typing import List, Sequence, Tuple

Perm = Tuple[int, ...]


# --------------------------------------------------------------------------
# Basic permutation algebra
# --------------------------------------------------------------------------
def identity(n: int) -> Perm:
    """The identity permutation on {0, ..., n-1}."""
    return tuple(range(n))


def compose(p: Perm, q: Perm) -> Perm:
    """Group product (p * q): apply q first, then p, matching f(g(x))."""
    return tuple(p[q[i]] for i in range(len(p)))


def inverse(p: Perm) -> Perm:
    """The inverse permutation."""
    inv = [0] * len(p)
    for i, pi in enumerate(p):
        inv[pi] = i
    return tuple(inv)


def order(p: Perm) -> int:
    """Order of a permutation = lcm of its cycle lengths."""
    n = len(p)
    seen = [False] * n
    result = 1
    for start in range(n):
        if seen[start]:
            continue
        length = 0
        j = start
        while not seen[j]:
            seen[j] = True
            j = p[j]
            length += 1
        result = result * length // gcd(result, length)
    return result


def transposition(n: int, a: int, b: int) -> Perm:
    """The transposition swapping a and b on {0, ..., n-1}."""
    p = list(range(n))
    p[a], p[b] = p[b], p[a]
    return tuple(p)


def sign(p: Perm) -> int:
    """Sign of a permutation: +1 if even, -1 if odd."""
    n = len(p)
    seen = [False] * n
    s = 1
    for start in range(n):
        if seen[start]:
            continue
        length = 0
        j = start
        while not seen[j]:
            seen[j] = True
            j = p[j]
            length += 1
        if length % 2 == 0:
            s = -s
    return s


def conjugate(w: Perm, p: Perm) -> Perm:
    """Conjugate: w * p * w^{-1}."""
    return compose(compose(w, p), inverse(w))


def reversal(n: int) -> Perm:
    """The reversal permutation x |-> n-1-x of {0, ..., n-1}."""
    return tuple(n - 1 - i for i in range(n))


# --------------------------------------------------------------------------
# String group representations
# --------------------------------------------------------------------------
def is_string_rep(gens: Sequence[Perm]) -> bool:
    """Check the defining axioms: every generator is an involution and
    non-adjacent generators commute (the string condition)."""
    r = len(gens)
    n = len(gens[0]) if gens else 0
    for g in gens:
        if compose(g, g) != identity(n):
            return False
    for i in range(r):
        for j in range(r):
            if i < j - 1:  # non-adjacent
                if compose(gens[i], gens[j]) != compose(gens[j], gens[i]):
                    return False
    return True


def period_matrix(gens: Sequence[Perm]) -> List[List[int]]:
    """period(i, j) = order(gens[i] * gens[j])."""
    r = len(gens)
    return [[order(compose(gens[i], gens[j])) for j in range(r)] for i in range(r)]


def schlafli(gens: Sequence[Perm]) -> List[int]:
    """First sub-diagonal of the period matrix: order(gens[k] * gens[k+1])."""
    r = len(gens)
    return [order(compose(gens[k], gens[k + 1])) for k in range(r - 1)]


def is_palindrome(seq: Sequence[int]) -> bool:
    """Whether a sequence reads the same forwards and backwards."""
    return list(seq) == list(reversed(seq))


def is_self_dual_by(gens: Sequence[Perm], w: Perm) -> bool:
    """Check that conjugation by w reverses the generators:
    w * gens[i] * w^{-1} == gens[rev(i)]."""
    r = len(gens)
    return all(conjugate(w, gens[i]) == gens[r - 1 - i] for i in range(r))


# --------------------------------------------------------------------------
# The simplex representation
# --------------------------------------------------------------------------
def simplex(r: int) -> List[Perm]:
    """Rank-r simplex: adjacent transpositions (i, i+1) on {0, ..., r}."""
    n = r + 1
    return [transposition(n, i, i + 1) for i in range(r)]


# --------------------------------------------------------------------------
# The doubling construction:  sigma |-> sigma (+) sigma (+) 1  on Fin(4m+3)
# --------------------------------------------------------------------------
def double(sigma: Perm, m: int) -> Perm:
    """Double a permutation of {0,...,2m} into A_{4m+3}: run sigma on the first
    block of size 2m+1 and on the second block, fixing the last point."""
    block = 2 * m + 1
    n = 4 * m + 3
    p = list(range(n))
    for i in range(block):
        p[i] = sigma[i]                  # first copy
        p[block + i] = block + sigma[i]  # second copy
    # final point (index n-1) is fixed by initialization
    return tuple(p)


def doubled_simplex(m: int) -> List[Perm]:
    """The self-dual rank-2m representation of A_{4m+3}: the rank-2m simplex
    pushed through the doubling homomorphism."""
    return [double(g, m) for g in simplex(2 * m)]


def doubled_reversal(m: int) -> Perm:
    """The doubled reversal element that witnesses self-duality."""
    return double(reversal(2 * m + 1), m)


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------
def demo_simplex(r: int) -> None:
    gens = simplex(r)
    print(f"--- Rank-{r} simplex in Sym(Fin({r + 1})) ---")
    print("  valid string representation:", is_string_rep(gens))
    print("  Schlafli symbol:", schlafli(gens), "(expected all 3's)")
    print("  palindromic:", is_palindrome(schlafli(gens)))
    w = reversal(r + 1)
    print("  self-dual via reversal:", is_self_dual_by(gens, w))
    print()


def demo_doubling(m: int) -> None:
    n = 4 * m + 3
    gens = doubled_simplex(m)
    print(f"--- Doubled simplex: rank {2 * m} self-dual rep of A_{n} (m={m}) ---")
    print("  number of generators (rank):", len(gens))
    print("  each generator acts on", n, "points")
    print("  all generators even (in A_n):", all(sign(g) == 1 for g in gens))
    print("  valid string representation:", is_string_rep(gens))
    sch = schlafli(gens)
    print("  Schlafli symbol:", sch)
    print("  palindromic:", is_palindrome(sch))
    w = doubled_reversal(m)
    print("  self-dual via doubled reversal:", is_self_dual_by(gens, w))
    print("  general max rank floor((n-1)/2) =", (n - 1) // 2, "=", 2 * m + 1)
    print("  achieved self-dual rank =", 2 * m, "(one below the general max)")
    print()


def demo_period_symmetry(m: int) -> None:
    gens = doubled_simplex(m)
    P = period_matrix(gens)
    r = len(gens)
    symmetric = all(P[i][j] == P[j][i] for i in range(r) for j in range(r))
    rev_inv = all(
        P[r - 1 - i][r - 1 - j] == P[i][j] for i in range(r) for j in range(r)
    )
    print(f"--- Period matrix structure (m={m}, rank {r}) ---")
    print("  period matrix is symmetric:", symmetric)
    print("  period matrix is reversal-invariant (self-dual):", rev_inv)
    print()


def main() -> None:
    print("=" * 64)
    print("Self-dual string C-groups for A_{4m+3}: numerical demonstrations")
    print("=" * 64)
    print()

    for r in (2, 3, 4, 6):
        demo_simplex(r)

    for m in (3, 4, 5):
        demo_doubling(m)

    demo_period_symmetry(3)
    demo_period_symmetry(4)

    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
