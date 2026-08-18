"""
Power-sum rigidity for bounded multisets, and the exact sharpness of the window 0 <= k <= N.

This self-contained script demonstrates, with exact integer / rational arithmetic:

  1. Rigidity:      multisets with elements in {0,...,N} are determined by p_0,...,p_N.
  2. Sharpness:     the binomial parity pair E_N (multiplicity C(N,j) at even j) and
                    O_N (multiplicity C(N,j) at odd j) agree on p_0,...,p_{N-1}.
  3. Exact gap:     p_N(E_N) - p_N(O_N) = (-1)^N * N!.
  4. Classification: any near miss has multiplicity difference lambda * ((-1)^j C(N,j)).
  5. Quantisation:  N! divides the top-index gap; |gap| >= N! for distinct multisets.
  6. Size floor:    a near miss at level N >= 1 has at least 2^(N-1) elements; E_N attains it.
  7. Zero index:    {0} and {} agree on every p_k with k >= 1.
  8. Positive support: with elements in {1,...,N} the window 1 <= k <= N is rigid.
  9. Reconstruction: recover multiplicities from p_0,...,p_N by solving the Vandermonde system.
 10. Exhaustive search reproducing the computational-evidence table.

Run:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from itertools import combinations, product
from math import comb, factorial
from typing import Dict, Iterable, List, Sequence, Tuple

Counts = Tuple[int, ...]  # multiplicity vector (c_0, ..., c_N)


# --------------------------------------------------------------------------------------
# Core definitions
# --------------------------------------------------------------------------------------


def power_sum(counts: Sequence[int], k: int) -> int:
    """p_k = sum_j c_j * j^k for the multiset with multiplicity c_j at j (0^0 = 1)."""
    return sum(c * (j**k) for j, c in enumerate(counts))


def power_sums(counts: Sequence[int], kmax: int) -> List[int]:
    """The vector (p_0, ..., p_kmax)."""
    return [power_sum(counts, k) for k in range(kmax + 1)]


def as_multiset(counts: Sequence[int]) -> List[int]:
    """Expand a multiplicity vector into a sorted list of elements."""
    out: List[int] = []
    for j, c in enumerate(counts):
        out.extend([j] * c)
    return out


def cardinality(counts: Sequence[int]) -> int:
    return sum(counts)


def even_part(n: int) -> Counts:
    """E_N: multiplicity C(N,j) at every even j <= N."""
    return tuple(comb(n, j) if j % 2 == 0 else 0 for j in range(n + 1))


def odd_part(n: int) -> Counts:
    """O_N: multiplicity C(N,j) at every odd j <= N."""
    return tuple(0 if j % 2 == 0 else comb(n, j) for j in range(n + 1))


def alternating_vector(n: int) -> List[int]:
    """The kernel vector v_j = (-1)^j C(N,j)."""
    return [(-1) ** j * comb(n, j) for j in range(n + 1)]


def alternating_table_entry(n: int, k: int) -> int:
    """A(N,k) = sum_j (-1)^j C(N,j) j^k."""
    return sum((-1) ** j * comb(n, j) * (j**k) for j in range(n + 1))


# --------------------------------------------------------------------------------------
# Reconstruction: solve the Vandermonde system  sum_j c_j j^k = p_k,  0 <= k <= N
# --------------------------------------------------------------------------------------


def solve_vandermonde(nodes: Sequence[int], rhs: Sequence[Fraction]) -> List[Fraction]:
    """Exact Gaussian elimination for the transposed Vandermonde system V c = rhs,
    where V[k][j] = nodes[j] ** k. Cost O(n^3) with exact rational arithmetic."""
    n = len(nodes)
    mat: List[List[Fraction]] = [
        [Fraction(nodes[j] ** k) for j in range(n)] + [Fraction(rhs[k])] for k in range(n)
    ]
    for col in range(n):
        pivot = next(r for r in range(col, n) if mat[r][col] != 0)
        mat[col], mat[pivot] = mat[pivot], mat[col]
        pv = mat[col][col]
        mat[col] = [x / pv for x in mat[col]]
        for r in range(n):
            if r != col and mat[r][col] != 0:
                f = mat[r][col]
                mat[r] = [a - f * b for a, b in zip(mat[r], mat[col])]
    return [mat[k][n] for k in range(n)]


def reconstruct(n: int, sums: Sequence[int]) -> List[int]:
    """Recover the multiplicity vector of a multiset bounded by N from (p_0, ..., p_N)."""
    sol = solve_vandermonde(list(range(n + 1)), [Fraction(s) for s in sums])
    if any(x.denominator != 1 or x < 0 for x in sol):
        raise ValueError("input is not the power-sum vector of a multiset bounded by N")
    return [int(x) for x in sol]


# --------------------------------------------------------------------------------------
# Exhaustive search over multiplicity vectors
# --------------------------------------------------------------------------------------


def all_counts(n: int, mmax: int) -> Iterable[Counts]:
    """All multiplicity vectors on {0,...,N} with entries at most M."""
    return product(range(mmax + 1), repeat=n + 1)


def search_near_misses(n: int, mmax: int) -> Tuple[int, int, Tuple[Counts, Counts] | None]:
    """Count unordered pairs of distinct multisets bounded by N with multiplicities <= M
    agreeing on all p_k with k <= N, and those agreeing on all p_k with k <= N-1.
    Also return the first near miss found (lexicographic order)."""
    table: Dict[Counts, List[int]] = {c: power_sums(c, n) for c in all_counts(n, mmax)}
    full = 0
    trunc = 0
    witness: Tuple[Counts, Counts] | None = None
    for a, b in combinations(sorted(table), 2):
        pa, pb = table[a], table[b]
        if pa[:n] == pb[:n]:
            trunc += 1
            if witness is None:
                witness = (a, b)
            if pa == pb:
                full += 1
    return full, trunc, witness


# --------------------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------------------


def demo_motivating_example() -> None:
    print("=" * 78)
    print("1. The motivating example: {0,2} versus {1,1}")
    print("=" * 78)
    s = (1, 0, 1)  # one 0, one 2
    t = (0, 2, 0)  # two 1s
    for k in range(3):
        print(f"   p_{k}({as_multiset(s)}) = {power_sum(s, k):3d}    "
              f"p_{k}({as_multiset(t)}) = {power_sum(t, k):3d}")
    print(f"   gap at k = 2: {power_sum(s, 2) - power_sum(t, 2)}  =  (-1)^2 * 2! = {factorial(2)}")
    print()


def demo_binomial_pair(nmax: int = 7) -> None:
    print("=" * 78)
    print("2-3. Binomial parity pair: agreement below the top index, exact gap (-1)^N N!")
    print("=" * 78)
    print(f"   {'N':>2} {'E_N':>28} {'O_N':>28} {'gap':>10} {'(-1)^N N!':>12}")
    for n in range(1, nmax + 1):
        e, o = even_part(n), odd_part(n)
        assert all(power_sum(e, k) == power_sum(o, k) for k in range(n)), "agreement below top"
        gap = power_sum(e, n) - power_sum(o, n)
        expected = (-1) ** n * factorial(n)
        assert gap == expected
        se = str(as_multiset(e)) if n <= 4 else f"<{cardinality(e)} elts>"
        so = str(as_multiset(o)) if n <= 4 else f"<{cardinality(o)} elts>"
        print(f"   {n:>2} {se:>28} {so:>28} {gap:>10} {expected:>12}")
    print()


def demo_alternating_table(nmax: int = 8) -> None:
    print("=" * 78)
    print("4. The alternating table A(N,k) = sum_j (-1)^j C(N,j) j^k is lower triangular")
    print("=" * 78)
    header = "   N\\k " + "".join(f"{k:>8}" for k in range(nmax + 1))
    print(header)
    for n in range(nmax + 1):
        row = "".join(f"{alternating_table_entry(n, k):>8}" for k in range(n + 1))
        print(f"   {n:>3} " + row)
    diag = [alternating_table_entry(n, n) for n in range(nmax + 1)]
    print(f"   diagonal: {diag}   (= (-1)^N N!)")
    print()


def demo_classification_and_quantisation(n: int = 4, lam: int = 3) -> None:
    print("=" * 78)
    print("5. Classification and quantisation of near misses")
    print("=" * 78)
    v = alternating_vector(n)
    base = [5] * (n + 1)  # a common padding, added to both sides
    s = tuple(base[j] + max(lam * v[j], 0) for j in range(n + 1))
    t = tuple(base[j] + max(-lam * v[j], 0) for j in range(n + 1))
    assert all(power_sum(s, k) == power_sum(t, k) for k in range(n)), "near miss"
    diff = [s[j] - t[j] for j in range(n + 1)]
    recovered_lambda = s[0] - t[0]
    print(f"   N = {n}, kernel vector v_j = (-1)^j C(N,j) = {v}")
    print(f"   multiplicity difference c(s) - c(t) = {diff}")
    print(f"   lambda recovered from the j = 0 coordinate: {recovered_lambda}")
    assert diff == [recovered_lambda * vj for vj in v]
    gap = power_sum(s, n) - power_sum(t, n)
    print(f"   top-index gap = {gap} = lambda * (-1)^N * N! = "
          f"{recovered_lambda * (-1) ** n * factorial(n)}")
    assert gap % factorial(n) == 0 and abs(gap) >= factorial(n)
    print(f"   N! = {factorial(n)} divides the gap, and |gap| >= N!   (quantisation)")
    print()


def demo_size_floor(nmax: int = 8) -> None:
    print("=" * 78)
    print("6. Size floor: a near miss at level N has at least 2^(N-1) elements")
    print("=" * 78)
    print(f"   {'N':>2} {'|E_N|':>10} {'2^(N-1)':>10} {'|O_N|':>10}")
    for n in range(1, nmax + 1):
        e, o = even_part(n), odd_part(n)
        assert cardinality(e) == 2 ** (n - 1) == cardinality(o)
        print(f"   {n:>2} {cardinality(e):>10} {2 ** (n - 1):>10} {cardinality(o):>10}")
    print()


def demo_zero_index_and_positive_support(n: int = 4) -> None:
    print("=" * 78)
    print("7-8. The index k = 0 exists only to see the value 0")
    print("=" * 78)
    singleton_zero = (1,) + (0,) * n
    empty = (0,) * (n + 1)
    print(f"   p_k({{0}}) = p_k({{}}) for k = 1..{n}: "
          f"{[ (power_sum(singleton_zero, k), power_sum(empty, k)) for k in range(1, n + 1) ]}")
    print(f"   but p_0 differs: {power_sum(singleton_zero, 0)} vs {power_sum(empty, 0)}")
    e_pos = (0,) + even_part(n)[1:]  # E_N with the value 0 deleted
    o = odd_part(n)
    agree = all(power_sum(e_pos, k) == power_sum(o, k) for k in range(1, n))
    print(f"   positive-support witness at N = {n}: agree for 1 <= k < N ? {agree}; "
          f"gap at k = N is {power_sum(e_pos, n) - power_sum(o, n)}")
    print()


def demo_reconstruction(n: int = 5) -> None:
    print("=" * 78)
    print("9. Reconstruction of a multiset from its first N+1 power sums")
    print("=" * 78)
    secret = (3, 0, 12, 1, 6, 4)  # multiplicities on {0,...,5}
    sums = power_sums(secret, n)
    print(f"   hidden multiplicities : {list(secret)}   (cardinality {cardinality(secret)})")
    print(f"   observed power sums   : {sums}")
    rec = reconstruct(n, sums)
    print(f"   reconstructed         : {rec}")
    assert rec == list(secret)
    print("   exact match -- rigidity in action")
    # One power sum short: the ambiguity is exactly a multiple of the kernel vector.
    v = alternating_vector(n)
    twin = tuple(secret[j] - v[j] for j in range(n + 1))
    if all(c >= 0 for c in twin):
        assert all(power_sum(secret, k) == power_sum(twin, k) for k in range(n))
        print(f"   dropping p_{n}: the multiset {list(twin)} is indistinguishable, "
              f"gap {power_sum(secret, n) - power_sum(twin, n)} = {factorial(n)} * "
              f"{(power_sum(secret, n) - power_sum(twin, n)) // factorial(n)}")
    print()


def demo_exhaustive_table() -> None:
    print("=" * 78)
    print("10. Exhaustive search over multiplicity vectors (computational evidence)")
    print("=" * 78)
    print(f"   {'N':>2} {'M':>2} {'agree k<=N':>11} {'agree k<=N-1':>13}  first witness")
    for n, mmax in [(1, 2), (2, 1), (2, 2), (2, 3), (3, 2), (3, 3)]:
        full, trunc, witness = search_near_misses(n, mmax)
        if witness is None:
            desc = f"(none; needs multiplicity {max(comb(n, j) for j in range(n + 1))})"
        else:
            desc = f"{as_multiset(witness[0])} vs {as_multiset(witness[1])}"
        print(f"   {n:>2} {mmax:>2} {full:>11} {trunc:>13}  {desc}")
    print("   the 'agree k<=N' column is identically zero: this is rigidity")
    print()


def main() -> None:
    demo_motivating_example()
    demo_binomial_pair()
    demo_alternating_table()
    demo_classification_and_quantisation()
    demo_size_floor()
    demo_zero_index_and_positive_support()
    demo_reconstruction()
    demo_exhaustive_table()
    print("All assertions passed.")


if __name__ == "__main__":
    main()
