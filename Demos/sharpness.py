"""
Moment collisions on a bounded alphabet: numerical demonstrations.
==================================================================

This self-contained script illustrates every quantitative statement of the
accompanying paper "Sharpness of the Finite Moment Problem".

Setting.  Fix an integer N >= 1 (the *alphabet bound*).  A weight system is a
vector w = (w_0, ..., w_N) of reals; its power sums (moments) are

        S_k(w) = sum_{i=0}^{N} w_i * i^k ,       k = 0, 1, 2, ...

A *data set* (multiset) of naturals bounded by N is the special case in which
w_i is a non-negative integer, the multiplicity of the letter i.

The demonstrations below cover:

  1. Rigidity: the moments of orders k <= N determine w  (Vandermonde solve).
  2. Sharpness: the even/odd binomial halves agree up to order N-1.
  3. The structure theorem: every kernel vector is a multiple of
     i |-> (-1)^i * C(N, i).
  4. The exact gap  S_N(w) - S_N(v) = (w_0 - v_0) * (-1)^N * N!,
     the total variation |w_0 - v_0| * 2^N, and the extremal separation
     N! / 2^(N-1) for probability distributions.
  5. The invariant m(N, K), the least size of a collision of agreement order
     K over the alphabet {0, ..., N}, computed by exhaustive search, and its
     sandwich  K < m(N, K) <= 2^K.
  6. The narrow ideal Prouhet-Tarry-Escott witnesses realising the floor
     m(N, K) = K + 1 for K = 1, 2, 3, 4, 5.
  7. The Prouhet-Thue-Morse doubling construction.
  8. Stability constants (the l1 norms of Lagrange coefficient vectors).

Only the standard library is used.
"""

from __future__ import annotations

from fractions import Fraction
from itertools import combinations_with_replacement
from math import comb, factorial
from typing import Dict, Iterable, List, Sequence, Tuple


# ----------------------------------------------------------------------
# 1. Basic quantities
# ----------------------------------------------------------------------


def power_sum(data: Sequence[int], k: int) -> int:
    """The k-th power sum sum_{x in data} x^k of a multiset of naturals."""
    return sum(x ** k for x in data)


def weighted_power_sum(weights: Sequence[Fraction], k: int) -> Fraction:
    """S_k(w) = sum_i w_i * i^k for a weight vector indexed by 0, 1, ..., N."""
    return sum(w * Fraction(i) ** k for i, w in enumerate(weights))


def agree_up_to(s: Sequence[int], t: Sequence[int], K: int) -> bool:
    """Do the two data sets have identical power sums of all orders k <= K?"""
    return all(power_sum(s, k) == power_sum(t, k) for k in range(K + 1))


# ----------------------------------------------------------------------
# 2. Rigidity: solving the Vandermonde system
# ----------------------------------------------------------------------


def solve_vandermonde(moments: Sequence[Fraction], N: int) -> List[Fraction]:
    """Recover the weights w_0, ..., w_N from the moments S_0, ..., S_N.

    Exact rational Gaussian elimination on the Vandermonde matrix V[k][i] = i^k,
    which is invertible because the nodes 0, 1, ..., N are pairwise distinct.
    Complexity O(N^3).
    """
    n = N + 1
    aug: List[List[Fraction]] = [
        [Fraction(i) ** k for i in range(n)] + [Fraction(moments[k])] for k in range(n)
    ]
    for col in range(n):
        pivot = next(r for r in range(col, n) if aug[r][col] != 0)
        aug[col], aug[pivot] = aug[pivot], aug[col]
        piv = aug[col][col]
        aug[col] = [x / piv for x in aug[col]]
        for r in range(n):
            if r != col and aug[r][col] != 0:
                factor = aug[r][col]
                aug[r] = [a - factor * b for a, b in zip(aug[r], aug[col])]
    return [aug[r][n] for r in range(n)]


# ----------------------------------------------------------------------
# 3. The even/odd binomial halves
# ----------------------------------------------------------------------


def binomial_halves(N: int) -> Tuple[List[Fraction], List[Fraction]]:
    """The two probability distributions on {0, ..., N} that agree in all
    moments of order < N: the even and the odd half of C(N, i) / 2^(N-1)."""
    denom = Fraction(2 ** (N - 1))
    even = [Fraction(comb(N, i)) / denom if i % 2 == 0 else Fraction(0) for i in range(N + 1)]
    odd = [Fraction(0) if i % 2 == 0 else Fraction(comb(N, i)) / denom for i in range(N + 1)]
    return even, odd


def binomial_half_multisets(N: int) -> Tuple[List[int], List[int]]:
    """The same construction as integer data sets: letter i repeated C(N, i)
    times, split by the parity of i.  Each side has 2^(N-1) elements."""
    even = [i for i in range(N + 1) if i % 2 == 0 for _ in range(comb(N, i))]
    odd = [i for i in range(N + 1) if i % 2 == 1 for _ in range(comb(N, i))]
    return even, odd


def alternating_vector(N: int) -> List[int]:
    """The kernel vector i |-> (-1)^i C(N, i)."""
    return [(-1) ** i * comb(N, i) for i in range(N + 1)]


# ----------------------------------------------------------------------
# 4. Exhaustive computation of the invariant m(N, K)
# ----------------------------------------------------------------------


def collisions_of_size(N: int, K: int, n: int) -> List[Tuple[Tuple[int, ...], Tuple[int, ...]]]:
    """All disjoint collisions with n elements per side: pairs of distinct
    multisets s != t of size n, entries in {0, ..., N}, sharing no element,
    with equal power sums of every order k <= K.

    A minimal collision can always be taken disjoint (deleting the common part
    preserves all power-sum differences), so restricting to disjoint pairs is
    lossless for computing m(N, K).  The signature of a multiset is the tuple
    (S_0, ..., S_K); bucketing by signature makes the search
    O(C(N+n, n) * K) instead of quadratic in the number of multisets.
    """
    buckets: Dict[Tuple[int, ...], List[Tuple[int, ...]]] = {}
    for combo in combinations_with_replacement(range(N + 1), n):
        sig = tuple(power_sum(combo, k) for k in range(K + 1))
        buckets.setdefault(sig, []).append(combo)
    out: List[Tuple[Tuple[int, ...], Tuple[int, ...]]] = []
    for group in buckets.values():
        for s, t in combinations_with_replacement(group, 2):
            if s != t and not (set(s) & set(t)):
                out.append((s, t))
    return out


def min_collision_card(N: int, K: int, cap: int = 9) -> int:
    """m(N, K): the least size of a collision of agreement order K over the
    alphabet {0, ..., N}.  Returns 0 when no collision exists (the rigid
    regime N <= K), and -1 if none is found up to the search cap."""
    if N <= K:
        return 0
    for n in range(K + 1, cap + 1):
        if collisions_of_size(N, K, n):
            return n
    return -1


def minimal_alphabet_for_ideal(K: int, cap: int = 20) -> int:
    """d(K): the least alphabet bound D such that an *ideal* collision --
    agreement order K with only K + 1 elements per side -- fits inside
    {0, ..., D}."""
    for D in range(K + 1, cap + 1):
        if collisions_of_size(D, K, K + 1):
            return D
    return -1


# ----------------------------------------------------------------------
# 5. The Prouhet-Thue-Morse doubling construction
# ----------------------------------------------------------------------


def prouhet_pair(K: int) -> Tuple[List[int], List[int]]:
    """The Prouhet pair of degree K: the naturals below 2^(K+1) split by the
    parity of their binary digit sum.  Each side has 2^K elements and the two
    sides have equal power sums of every order k <= K."""
    s: List[int] = [0]
    t: List[int] = [1]
    for j in range(K):
        shift = 2 ** (j + 1)
        s, t = s + [y + shift for y in t], t + [y + shift for y in s]
    return sorted(s), sorted(t)


# ----------------------------------------------------------------------
# 6. Stability constants
# ----------------------------------------------------------------------


def lagrange_coefficients(N: int, j: int) -> List[Fraction]:
    """Coefficient vector of the j-th Lagrange basis polynomial for the nodes
    0, 1, ..., N, computed by repeated polynomial multiplication."""
    poly: List[Fraction] = [Fraction(1)]
    denom = Fraction(1)
    for i in range(N + 1):
        if i == j:
            continue
        poly = [Fraction(0)] + poly  # multiply by X
        for d in range(len(poly) - 1):
            poly[d] -= Fraction(i) * poly[d + 1]
        denom *= Fraction(j - i)
    return [c / denom for c in poly]


def stability_constant(N: int, j: int) -> Fraction:
    """The l1 norm of the coefficient vector of the j-th Lagrange basis
    polynomial: the factor by which a moment error of size eps can be
    amplified in the reconstructed weight w_j."""
    return sum(abs(c) for c in lagrange_coefficients(N, j))


# ----------------------------------------------------------------------
# 7. Demonstrations
# ----------------------------------------------------------------------

IDEAL_WITNESSES: Dict[int, Tuple[List[int], List[int]]] = {
    1: ([0, 2], [1, 1]),
    2: ([0, 3, 3], [1, 1, 4]),
    3: ([1, 1, 6, 6], [0, 3, 4, 7]),
    4: ([0, 4, 8, 16, 17], [1, 2, 10, 14, 18]),
    5: ([0, 3, 5, 11, 13, 16], [1, 1, 8, 8, 15, 15]),
}

INTERMEDIATE_WITNESSES: List[Tuple[int, List[int], List[int]]] = [
    (3, [1, 1, 1, 4, 4, 4], [0, 2, 2, 3, 3, 5]),
    (4, [1, 1, 1, 5, 6, 6, 8], [0, 2, 2, 3, 7, 7, 7]),
]


def banner(text: str) -> None:
    print("\n" + "=" * 74)
    print(text)
    print("=" * 74)


def demo_rigidity(N: int = 6) -> None:
    banner(f"1. Rigidity: N = {N}, the moments of orders 0..{N} recover the weights")
    weights = [Fraction(i * i + 1, 7) for i in range(N + 1)]
    moments = [weighted_power_sum(weights, k) for k in range(N + 1)]
    recovered = solve_vandermonde(moments, N)
    print("  weights   :", [str(w) for w in weights])
    print("  moments   :", [str(m) for m in moments])
    print("  recovered :", [str(w) for w in recovered])
    print("  exact match:", recovered == weights)


def demo_sharpness(N: int = 5) -> None:
    banner(f"2. Sharpness: the binomial halves on {{0,...,{N}}} agree below order {N}")
    even, odd = binomial_halves(N)
    print("  even half :", [str(w) for w in even])
    print("  odd  half :", [str(w) for w in odd])
    for k in range(N + 1):
        a, b = weighted_power_sum(even, k), weighted_power_sum(odd, k)
        tag = "agree" if a == b else "DIFFER"
        print(f"    k = {k}:  S_k(even) = {str(a):>12}   S_k(odd) = {str(b):>12}   {tag}")
    gap = weighted_power_sum(even, N) - weighted_power_sum(odd, N)
    predicted = Fraction((-1) ** N * factorial(N), 2 ** (N - 1))
    print(f"  gap at order {N}: {gap}   predicted (-1)^N N!/2^(N-1) = {predicted}")
    print("  extremal separation attained:", gap == predicted)


def demo_structure(N: int = 5) -> None:
    banner(f"3. Structure of the kernel at N = {N}")
    even, odd = binomial_halves(N)
    diff = [a - b for a, b in zip(even, odd)]
    alt = alternating_vector(N)
    c = diff[0] / Fraction(alt[0])
    print("  difference w - v :", [str(d) for d in diff])
    print("  (-1)^i C(N,i)    :", alt)
    print(f"  ratio c = w_0 - v_0 = {c}")
    print("  difference = c * alternating vector:",
          all(d == c * Fraction(a) for d, a in zip(diff, alt)))
    tv = sum(abs(d) for d in diff)
    print(f"  total variation = {tv},  |c| * 2^N = {abs(c) * 2 ** N}")


def demo_alternating_identity(N: int = 5) -> None:
    banner(f"4. The alternating identity at N = {N}")
    alt = alternating_vector(N)
    for k in range(N + 1):
        val = sum(a * i ** k for i, a in enumerate(alt))
        expect = 0 if k < N else (-1) ** N * factorial(N)
        print(f"    sum_i (-1)^i C({N},i) i^{k} = {val:>10}   (predicted {expect})")


def demo_invariant(max_N: int = 7, max_K: int = 3) -> None:
    banner("5. The invariant m(N, K) by exhaustive search, with the sandwich K < m <= 2^K")
    header = "  N \\ K " + "".join(f"{K:>6}" for K in range(1, max_K + 1))
    print(header)
    for N in range(1, max_N + 1):
        row = f"  {N:>5} "
        for K in range(1, max_K + 1):
            row += f"{min_collision_card(N, K):>6}"
        print(row)
    print("  (0 marks the rigid regime N <= K, where no collision exists at all.)")
    print("  ceilings 2^K :", {K: 2 ** K for K in range(1, max_K + 1)})


def demo_ideal_witnesses() -> None:
    banner("6. Ideal witnesses: agreement order K with only K + 1 elements per side")
    for K, (s, t) in IDEAL_WITNESSES.items():
        ok = agree_up_to(s, t, K)
        split = power_sum(s, K + 1) != power_sum(t, K + 1)
        D = max(max(s), max(t))
        print(f"  K = {K}: {s} vs {t}   diameter {D}")
        print(f"      power sums k <= {K}: {[power_sum(s, k) for k in range(K + 1)]}"
              f"  (equal: {ok})")
        print(f"      order {K + 1}: {power_sum(s, K + 1)} vs {power_sum(t, K + 1)}"
              f"  (separated: {split})")
    print("\n  intermediate witnesses (below the ceiling 2^K, above the floor K + 1):")
    for K, s, t in INTERMEDIATE_WITNESSES:
        D = max(max(s), max(t))
        print(f"  K = {K}: {s} vs {t}  size {len(s)} < {2 ** K} = 2^K, diameter {D},"
              f" valid: {agree_up_to(s, t, K) and power_sum(s, K + 1) != power_sum(t, K + 1)}")


def demo_minimal_alphabets(max_K: int = 4) -> None:
    banner("7. Minimal alphabets d(K) carrying an ideal collision (exhaustive)")
    for K in range(1, max_K + 1):
        d = minimal_alphabet_for_ideal(K)
        print(f"  d({K}) = {d}")
    print("  (Larger degrees require a wider search; the known values continue"
          " d(5) = 16 < 18 = d(4), so d is not monotone.)")


def demo_prouhet(max_K: int = 4) -> None:
    banner("8. The Prouhet-Thue-Morse doubling construction")
    for K in range(0, max_K + 1):
        s, t = prouhet_pair(K)
        ok = agree_up_to(s, t, K)
        print(f"  K = {K}: |s| = {len(s)} = 2^{K}, alphabet < {2 ** (K + 1)}")
        print(f"      s = {s}")
        print(f"      t = {t}")
        print(f"      agree up to order {K}: {ok};  separated at order {K + 1}:"
              f" {power_sum(s, K + 1) != power_sum(t, K + 1)}")


def demo_stability(max_N: int = 6) -> None:
    banner("9. Stability constants: worst-case amplification of a moment error")
    for N in range(1, max_N + 1):
        consts = [stability_constant(N, j) for j in range(N + 1)]
        worst = max(consts)
        print(f"  N = {N}: max_j Lambda_(N,j) = {worst}"
              f"   (~ {float(worst):.3g}),  N!/2^(N-1) = {Fraction(factorial(N), 2 ** (N - 1))}")


def main() -> None:
    demo_rigidity()
    demo_sharpness()
    demo_structure()
    demo_alternating_identity()
    demo_invariant()
    demo_ideal_witnesses()
    demo_minimal_alphabets()
    demo_prouhet()
    demo_stability()
    print("\nAll demonstrations complete.")


if __name__ == "__main__":
    main()
