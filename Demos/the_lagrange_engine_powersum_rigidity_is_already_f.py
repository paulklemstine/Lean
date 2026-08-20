"""
Invisible weight vectors of a truncated power-sum window: numerical demonstrations.

A weight vector e = (e_0, ..., e_N) on the nodes {0, 1, ..., N} has moments

    m_k(e) = sum_{j=0}^{N} e_j * j^k          (with 0^0 = 1),

and is *invisible to the window K* when m_k(e) = 0 for every k < K.

This script demonstrates, by exact integer/rational computation:

  1. the shifted alternating binomial stencils b^(K,i) are invisible, with first
     visible moment m_K = K! independent of the shift;
  2. the structure theorem: every invisible vector is an INTEGER combination of the
     N + 1 - K stencils, recovered by a division-free descent;
  3. the dimension count dim = N + 1 - K, checked against exact linear algebra;
  4. the polynomial criterion: invisibility <=> (X - 1)^K divides sum_j e_j X^j;
  5. the near-miss (Prouhet-Tarry-Escott) dictionary and the mod-2^K congruence on
     alternating counts;
  6. minimal-support rigidity: e_i * prod_{j != i} (i - j) = m_K(e), sign alternation;
  7. the l1 theory: lower bounds K+1, K+2, K+3 (odd K), parity, and the refutation of
     the conjecture l1 >= 2^K via shift differences and convolution.

Self-contained: standard library only.
"""

from __future__ import annotations

from fractions import Fraction
from itertools import product
from math import comb, factorial
from typing import Dict, List, Sequence, Tuple

Vector = List[int]

# ----------------------------------------------------------------------------------
# Moments
# ----------------------------------------------------------------------------------


def moment(e: Sequence[int], k: int) -> int:
    """m_k(e) = sum_j e_j * j^k, with the convention 0^0 = 1."""
    total = 0
    for j, ej in enumerate(e):
        total += ej * (1 if (j == 0 and k == 0) else j**k)
    return total


def moments(e: Sequence[int], upto: int) -> List[int]:
    """The list [m_0(e), ..., m_upto(e)]."""
    return [moment(e, k) for k in range(upto + 1)]


def is_invisible(e: Sequence[int], K: int) -> bool:
    """True iff m_k(e) = 0 for all k < K."""
    return all(moment(e, k) == 0 for k in range(K))


def l1(e: Sequence[int]) -> int:
    """The total absolute weight sum_j |e_j|."""
    return sum(abs(x) for x in e)


def support(e: Sequence[int]) -> List[int]:
    """The list of nodes carrying a nonzero weight."""
    return [j for j, x in enumerate(e) if x != 0]


# ----------------------------------------------------------------------------------
# The shifted alternating binomial stencils
# ----------------------------------------------------------------------------------


def bin_weight(K: int, i: int, N: int) -> Vector:
    """b^(K,i) as a vector of length N+1: entry (-1)^(K-d) * C(K,d) at node i+d."""
    e = [0] * (N + 1)
    for d in range(K + 1):
        if i + d <= N:
            e[i + d] = (-1) ** (K - d) * comb(K, d)
    return e


def basis(N: int, K: int) -> List[Vector]:
    """The N + 1 - K admissible stencils b^(K,0), ..., b^(K,N-K)."""
    return [bin_weight(K, i, N) for i in range(max(0, N + 1 - K))]


# ----------------------------------------------------------------------------------
# The structure theorem: division-free descent
# ----------------------------------------------------------------------------------


def decompose(e: Sequence[int], N: int, K: int) -> List[int]:
    """
    Write an invisible vector as an integer combination of the stencils.

    Descent from the top node: only b^(K,N-K) reaches node N, and its entry there is 1,
    so the coefficient is forced to be e_N.  Subtract and recurse.  No division occurs,
    which is exactly why integral vectors get integral coefficients.
    """
    work = list(e) + [0] * (N + 1 - len(e))
    coeffs = [0] * max(0, N + 1 - K)
    for i in range(len(coeffs) - 1, -1, -1):
        c = work[i + K]
        coeffs[i] = c
        if c:
            stencil = bin_weight(K, i, N)
            work = [a - c * b for a, b in zip(work, stencil)]
    if any(work):
        raise ValueError("vector was not invisible to the window")
    return coeffs


def combine(coeffs: Sequence[int], N: int, K: int) -> Vector:
    """Rebuild sum_i c_i * b^(K,i)."""
    out = [0] * (N + 1)
    for i, c in enumerate(coeffs):
        for j, b in enumerate(bin_weight(K, i, N)):
            out[j] += c * b
    return out


# ----------------------------------------------------------------------------------
# Exact rational rank, for the dimension check
# ----------------------------------------------------------------------------------


def rank(rows: List[List[Fraction]]) -> int:
    """Rank of an exact rational matrix by Gaussian elimination."""
    mat = [row[:] for row in rows]
    r = 0
    ncols = len(mat[0]) if mat else 0
    for c in range(ncols):
        pivot = next((i for i in range(r, len(mat)) if mat[i][c] != 0), None)
        if pivot is None:
            continue
        mat[r], mat[pivot] = mat[pivot], mat[r]
        pv = mat[r][c]
        mat[r] = [x / pv for x in mat[r]]
        for i in range(len(mat)):
            if i != r and mat[i][c] != 0:
                f = mat[i][c]
                mat[i] = [a - f * b for a, b in zip(mat[i], mat[r])]
        r += 1
    return r


def invisible_dimension(N: int, K: int) -> int:
    """dim of {e in Q^(N+1) : m_k(e) = 0 for k < K}, computed as (N+1) - rank."""
    if K == 0:
        return N + 1
    rows = [
        [Fraction(1 if (j == 0 and k == 0) else j**k) for j in range(N + 1)]
        for k in range(K)
    ]
    return (N + 1) - rank(rows)


# ----------------------------------------------------------------------------------
# Polynomials (dense integer coefficient lists) for the divisibility criterion
# ----------------------------------------------------------------------------------


def poly_mul(a: Sequence[int], b: Sequence[int]) -> List[int]:
    out = [0] * (len(a) + len(b) - 1)
    for i, x in enumerate(a):
        for j, y in enumerate(b):
            out[i + j] += x * y
    return out


def x_minus_one_pow(K: int) -> List[int]:
    """(X - 1)^K as a coefficient list."""
    out = [1]
    for _ in range(K):
        out = poly_mul(out, [-1, 1])
    return out


def divides_x_minus_one_pow(e: Sequence[int], K: int) -> bool:
    """True iff (X - 1)^K divides sum_j e_j X^j over the integers."""
    rem = list(e)
    div = x_minus_one_pow(K)  # monic of degree K
    for deg in range(len(rem) - 1, K - 1, -1):
        c = rem[deg]
        if c:
            for t, d in enumerate(div):
                rem[deg - K + t] -= c * d
    return not any(rem)


# ----------------------------------------------------------------------------------
# Near-miss dictionary
# ----------------------------------------------------------------------------------


def to_multisets(e: Sequence[int]) -> Tuple[List[int], List[int]]:
    """Split an integer weight vector into the two multisets of a near miss."""
    S: List[int] = []
    T: List[int] = []
    for j, x in enumerate(e):
        if x > 0:
            S.extend([j] * x)
        elif x < 0:
            T.extend([j] * (-x))
    return S, T


def power_sum(S: Sequence[int], k: int) -> int:
    return sum(1 if (x == 0 and k == 0) else x**k for x in S)


def alternating_count(S: Sequence[int]) -> int:
    return sum((-1) ** x for x in S)


# ----------------------------------------------------------------------------------
# Cheap constructions: shift difference and convolution
# ----------------------------------------------------------------------------------


def shift_diff(e: Sequence[int]) -> Vector:
    """(delta e)_j = e_{j-1} - e_j : widens the window by 1, at most doubles l1."""
    padded = [0] + list(e)
    ext = list(e) + [0]
    return [a - b for a, b in zip(padded, ext)]


def convolve(w: Sequence[int], e: Sequence[int]) -> Vector:
    """Convolution: windows add, l1 norms multiply."""
    out = [0] * (len(w) + len(e) - 1)
    for a, wa in enumerate(w):
        if wa:
            for i, ei in enumerate(e):
                out[a + i] += wa * ei
    return out


PTE3: Vector = [-1, 2, 0, -2, 1]  # window 3, l1 = 6, the near miss {1,1,4} vs {0,3,3}


# ----------------------------------------------------------------------------------
# Exhaustive minimal-l1 search over small windows
# ----------------------------------------------------------------------------------


def min_l1_bruteforce(K: int, N: int, bound: int = 3) -> Tuple[int, Vector]:
    """
    Exhaustive search for the cheapest nonzero invisible vector on {0..N} with entries
    in [-bound, bound].  Exponential in N; used only for tiny cases.
    """
    best: Tuple[int, Vector] = (10**9, [])
    for e in product(range(-bound, bound + 1), repeat=N + 1):
        if any(e) and is_invisible(e, K):
            c = l1(e)
            if c < best[0]:
                best = (c, list(e))
    return best


# ----------------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------------


def demo_stencils() -> None:
    print("=" * 78)
    print("1. The stencils b^(K,i) are invisible, with first visible moment K!")
    print("=" * 78)
    for K, N in [(2, 3), (3, 5), (4, 6)]:
        for i in range(N + 1 - K):
            b = bin_weight(K, i, N)
            lows = [moment(b, k) for k in range(K)]
            top = moment(b, K)
            assert all(x == 0 for x in lows)
            assert top == factorial(K)
            print(
                f"  K={K} N={N} i={i}: b = {b}"
                f"  moments<K = {lows}  m_K = {top} = {K}! ,  l1 = {l1(b)} = 2^{K}"
            )
        print()


def demo_structure() -> None:
    print("=" * 78)
    print("2. Structure theorem: integer decomposition by division-free descent")
    print("=" * 78)
    samples: List[Tuple[Vector, int, int]] = [
        (PTE3, 4, 3),
        ([0, 1, -2, 1], 3, 2),
        ([1, -1, -3, 5, -2], 4, 2),
        (convolve(PTE3, PTE3), 8, 6),
    ]
    for e, N, K in samples:
        assert is_invisible(e, K), e
        c = decompose(e, N, K)
        assert combine(c, N, K) == list(e) + [0] * (N + 1 - len(e))
        assert all(isinstance(x, int) for x in c)
        print(f"  N={N} K={K}: e = {e}")
        print(f"      integer coefficients over the {len(c)} stencils: {c}")
        print(f"      (X-1)^{K} divides the generating polynomial: "
              f"{divides_x_minus_one_pow(e, K)}")
    print()


def demo_dimension() -> None:
    print("=" * 78)
    print("3. Dimension of the invisible space equals N + 1 - K")
    print("=" * 78)
    print("     N \\ K " + "".join(f"{K:>6}" for K in range(0, 7)))
    for N in range(0, 7):
        row = []
        for K in range(0, 7):
            d = invisible_dimension(N, K)
            assert d == max(0, N + 1 - K), (N, K, d)
            row.append(d)
        print(f"     N={N}   " + "".join(f"{d:>6}" for d in row))
    print("     (each extra measurement removes exactly one degree of freedom)\n")


def demo_near_miss() -> None:
    print("=" * 78)
    print("4. The near-miss (Prouhet-Tarry-Escott) dictionary")
    print("=" * 78)
    for e, K in [([0, 1, -2, 1], 2), (PTE3, 3), (bin_weight(4, 0, 4), 4)]:
        S, T = to_multisets(e)
        eq = [(power_sum(S, k), power_sum(T, k)) for k in range(K)]
        assert all(a == b for a, b in eq)
        gap = power_sum(S, K) - power_sum(T, K)
        cong = (alternating_count(S) - alternating_count(T)) % (2**K)
        assert cong == 0
        print(f"  window K={K}:  {S}  vs  {T}")
        print(f"      equal power sums p_0..p_{K-1}: {[a for a, _ in eq]}")
        print(f"      first divergence p_{K}: {power_sum(S, K)} vs {power_sum(T, K)}"
              f"  (difference {gap})")
        print(f"      alternating counts agree mod 2^{K} = {2**K}: "
              f"{alternating_count(S)} vs {alternating_count(T)}")
    print()


def demo_rigidity() -> None:
    print("=" * 78)
    print("5. Minimal-support rigidity: invisible vectors on K+1 nodes are divided")
    print("   differences, with alternating signs and no zero entries")
    print("=" * 78)
    cases: List[Tuple[Vector, int]] = [
        (bin_weight(3, 0, 3), 3),                  # consecutive nodes
        ([2, 0, -3, 0, 0, 0, 1], 2),               # nodes 0, 2, 6
    ]
    for e, K in cases:
        assert is_invisible(e, K)
        S = support(e)
        assert len(S) == K + 1
        mK = moment(e, K)
        print(f"  K={K}: e = {e}, support {S}, m_K = {mK}")
        for i in S:
            prod = 1
            for j in S:
                if j != i:
                    prod *= i - j
            assert e[i] * prod == mK
            sign = (-1) ** sum(1 for j in S if j > i)
            print(f"      node {i}: e_i * prod(i-j) = {e[i]} * {prod} = {e[i]*prod}"
                  f"   normalised sign {sign * (1 if e[i] > 0 else -1)}")
    print()


def demo_l1_bounds() -> None:
    print("=" * 78)
    print("6. l1 lower bounds: >= K+1, always even, >= K+2 for K>=2, >= K+3 for odd K")
    print("=" * 78)
    for K, N in [(1, 3), (2, 4), (3, 5)]:
        best, e = min_l1_bruteforce(K, N, bound=3)
        floor_ = K + 1
        if K >= 2:
            floor_ = K + 2
        if K >= 3 and K % 2 == 1:
            floor_ = K + 3
        assert best % 2 == 0 and best >= floor_
        print(f"  K={K}, nodes 0..{N}: cheapest invisible vector {e} has l1 = {best}"
              f"   (proved floor {floor_}, conjectured optimum 2K = {2*K})")
    print()


def demo_cheap_constructions() -> None:
    print("=" * 78)
    print("7. Cheap invisibility: the conjecture l1 >= 2^K is FALSE for every K >= 3")
    print("=" * 78)
    print("  (a) shift differences: window +1, l1 at most doubled")
    e: Vector = PTE3
    K = 3
    print(f"      K={K}: l1 = {l1(e)}  vs  2^{K} = {2**K}   -> conjecture already fails")
    for _ in range(5):
        e = shift_diff(e)
        K += 1
        assert is_invisible(e, K) and moment(e, K) != 0
        print(f"      K={K}: l1 = {l1(e):>6}  vs  2^{K} = {2**K:>6}"
              f"   ratio {l1(e)/2**K:.4f}")
    print()
    print("  (b) convolution: windows add, l1 norms multiply -> base 6^(1/3) ~ 1.817")
    conv: Vector = [1]
    for n in range(1, 6):
        conv = convolve(conv, PTE3)
        K = 3 * n
        assert is_invisible(conv, K) and moment(conv, K) != 0
        assert l1(conv) <= 6**n
        print(f"      n={n}: window K={K:>3}, l1 = {l1(conv):>7} <= 6^{n} = {6**n:>7}"
              f",  2^K = {2**K:>10},  ratio {l1(conv)/2**K:.6f}")
    print("      the ratio decays like (3/4)^n : the failure is exponential\n")


def demo_convolution_top_moment() -> None:
    print("=" * 78)
    print("8. Leibniz rule for the first visible moment of a convolution")
    print("=" * 78)
    w = bin_weight(2, 0, 2)          # window 2, m_2 = 2
    e = PTE3                         # window 3, m_3 = 12
    c = convolve(w, e)
    Ke, Kw = 3, 2
    lhs = moment(c, Ke + Kw)
    rhs = comb(Ke + Kw, Ke) * moment(e, Ke) * moment(w, Kw)
    assert is_invisible(c, Ke + Kw) and lhs == rhs
    print(f"  w = {w} (window {Kw}, m_{Kw} = {moment(w, Kw)})")
    print(f"  e = {e} (window {Ke}, m_{Ke} = {moment(e, Ke)})")
    print(f"  w*e = {c}: invisible to window {Ke+Kw},")
    print(f"      m_{Ke+Kw}(w*e) = {lhs} = C({Ke+Kw},{Ke}) * "
          f"{moment(e, Ke)} * {moment(w, Kw)} = {rhs}")
    print(f"      l1(w*e) = {l1(c)} <= l1(w)*l1(e) = {l1(w)*l1(e)}\n")


def main() -> None:
    demo_stencils()
    demo_structure()
    demo_dimension()
    demo_near_miss()
    demo_rigidity()
    demo_l1_bounds()
    demo_cheap_constructions()
    demo_convolution_top_moment()
    print("All assertions passed.")


if __name__ == "__main__":
    main()
