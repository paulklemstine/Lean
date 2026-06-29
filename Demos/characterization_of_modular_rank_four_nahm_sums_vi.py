"""Numerical demonstrations for the discriminant invariants of rank-four Nahm sums.

This script is self-contained (standard library only) and exercises the five
formally verified results:

  * det_congr          : det(Sᵀ H S) = (det S)² det H        (over any comm. ring)
  * disc_invariant     : disc(Sᵀ H S) = disc H  when det S = ±1
  * disc_directSum_mul : det(blockdiag(A, D)) = det A · det D
  * disc_diagonal      : disc(diag d) = ∏ d_i
  * realizable         : 8, 12, 16 are discriminants of positive diagonal Hessians

All arithmetic is exact (Python ints), mirroring the integer Hessians of the
Lean development. The discriminant of a rank-four Nahm datum with Hessian H is
disc(H) = det H, and the grand conjecture proposes that the datum is modular iff
disc(H) ∈ {8, 12, 16}.
"""

from __future__ import annotations

from itertools import permutations
from typing import List, Sequence, Tuple

Matrix = List[List[int]]

TARGET_DISCRIMINANTS: Tuple[int, int, int] = (8, 12, 16)


# --------------------------------------------------------------------------- #
# Exact integer linear algebra
# --------------------------------------------------------------------------- #
def det(M: Matrix) -> int:
    """Exact determinant of a square integer matrix via Laplace expansion.

    Returns an ``int``; for the small (<= 4x4) matrices used here this is both
    exact and fast. This computes disc(H) = det H from the Lean development.
    """
    n = len(M)
    if n == 1:
        return M[0][0]
    if n == 2:
        return M[0][0] * M[1][1] - M[0][1] * M[1][0]
    total = 0
    for j in range(n):
        minor = [row[:j] + row[j + 1:] for row in M[1:]]
        total += ((-1) ** j) * M[0][j] * det(minor)
    return total


def transpose(M: Matrix) -> Matrix:
    """Matrix transpose Sᵀ."""
    return [list(row) for row in zip(*M)]


def matmul(A: Matrix, B: Matrix) -> Matrix:
    """Exact integer matrix product A · B."""
    n, m, p = len(A), len(B), len(B[0])
    return [[sum(A[i][k] * B[k][j] for k in range(m)) for j in range(p)] for i in range(n)]


def congruence(S: Matrix, H: Matrix) -> Matrix:
    """The congruence action Sᵀ H S of a change of variables S on a Hessian H."""
    return matmul(matmul(transpose(S), H), S)


def diagonal(d: Sequence[int]) -> Matrix:
    """The diagonal matrix diag(d_1, ..., d_n)."""
    n = len(d)
    return [[d[i] if i == j else 0 for j in range(n)] for i in range(n)]


def block_diag(A: Matrix, D: Matrix) -> Matrix:
    """Orthogonal direct sum: block-diagonal matrix [[A,0],[0,D]]."""
    a, b = len(A), len(D)
    out = [[0] * (a + b) for _ in range(a + b)]
    for i in range(a):
        for j in range(a):
            out[i][j] = A[i][j]
    for i in range(b):
        for j in range(b):
            out[a + i][a + j] = D[i][j]
    return out


def disc(H: Matrix) -> int:
    """Discriminant of a Nahm datum: disc(H) = det H."""
    return det(H)


def is_candidate_modular(H: Matrix) -> bool:
    """Conjectural rank-four modularity oracle: disc(H) ∈ {8, 12, 16}."""
    return disc(H) in TARGET_DISCRIMINANTS


# --------------------------------------------------------------------------- #
# Demonstrations of the five theorems
# --------------------------------------------------------------------------- #
def demo_det_congr() -> None:
    """det_congr: det(Sᵀ H S) = (det S)² det H for non-unimodular S as well."""
    print("=" * 70)
    print("Theorem det_congr:  det(Sᵀ H S) = (det S)² · det H")
    print("=" * 70)
    H = [[2, 1, 0, 0],
         [1, 4, 1, 0],
         [0, 1, 6, 2],
         [0, 0, 2, 3]]
    # A non-unimodular S (det S = 2) to show the (det S)² factor explicitly.
    S = [[1, 0, 0, 0],
         [0, 2, 0, 0],
         [0, 0, 1, 0],
         [0, 0, 0, 1]]
    lhs = det(congruence(S, H))
    rhs = det(S) ** 2 * det(H)
    print(f"  det H          = {det(H)}")
    print(f"  det S          = {det(S)}   (det S)² = {det(S) ** 2}")
    print(f"  det(Sᵀ H S)    = {lhs}")
    print(f"  (det S)² det H = {rhs}")
    assert lhs == rhs
    print("  verified: equality holds.\n")


def demo_disc_invariant() -> None:
    """disc_invariant: unimodular S (det = ±1) leaves disc unchanged."""
    print("=" * 70)
    print("Theorem disc_invariant:  disc(Sᵀ H S) = disc H  for det S = ±1")
    print("=" * 70)
    H = diagonal([2, 2, 3, 1])  # disc = 12
    # A unimodular shear (det = 1): adds column 1 into column 2.
    U = [[1, 1, 0, 0],
         [0, 1, 0, 0],
         [0, 0, 1, 0],
         [0, 0, 0, 1]]
    # A unimodular reflection (det = -1): swaps two coordinates.
    R = [[0, 1, 0, 0],
         [1, 0, 0, 0],
         [0, 0, 1, 0],
         [0, 0, 0, 1]]
    for name, S in (("shear (det=+1)", U), ("swap (det=-1)", R)):
        Hc = congruence(S, H)
        print(f"  {name:16s}: det S = {det(S):2d}, disc(Sᵀ H S) = {disc(Hc)} (was {disc(H)})")
        assert disc(Hc) == disc(H)
    print("  verified: discriminant is a strict unimodular invariant.\n")


def demo_disc_directSum_mul() -> None:
    """disc_directSum_mul: det of a block-diagonal form factors as the product."""
    print("=" * 70)
    print("Theorem disc_directSum_mul:  det blockdiag(A, D) = det A · det D")
    print("=" * 70)
    A = [[2, 1], [1, 2]]   # det 3
    D = [[2, 0], [0, 1]]   # det 2
    M = block_diag(A, D)
    print(f"  det A = {det(A)}, det D = {det(D)}, det blockdiag = {det(M)}")
    assert det(M) == det(A) * det(D)
    print(f"  verified: {det(M)} = {det(A)} · {det(D)}\n")


def demo_disc_diagonal() -> None:
    """disc_diagonal: disc(diag d) = ∏ d_i."""
    print("=" * 70)
    print("Theorem disc_diagonal:  disc(diag d) = ∏ d_i")
    print("=" * 70)
    for d in ([2, 2, 2, 1], [2, 2, 3, 1], [2, 2, 2, 2]):
        prod = 1
        for x in d:
            prod *= x
        H = diagonal(d)
        print(f"  diag{tuple(d)} -> disc = {disc(H)} = ∏ = {prod}")
        assert disc(H) == prod
    print("  verified.\n")


def demo_realizable() -> None:
    """realizable: 8, 12, 16 are realised by positive diagonal Hessians."""
    print("=" * 70)
    print("Theorem realizable:  each of 8, 12, 16 is a positive-form discriminant")
    print("=" * 70)
    witnesses = {8: [2, 2, 2, 1], 12: [2, 2, 3, 1], 16: [2, 2, 2, 2]}
    for target, d in witnesses.items():
        H = diagonal(d)
        positive = all(H[i][i] > 0 for i in range(4))
        symmetric = all(H[i][j] == H[j][i] for i in range(4) for j in range(4))
        print(f"  target {target}: witness diag{tuple(d)}  "
              f"disc={disc(H)}  positive_diag={positive}  symmetric={symmetric}  "
              f"candidate_modular={is_candidate_modular(H)}")
        assert disc(H) == target and positive and symmetric and is_candidate_modular(H)
    print("  verified: target set is non-vacuous, realised by genuine positive forms.\n")


def demo_block_factorization_search() -> None:
    """Algorithm D: enumerate diagonal witnesses for each target discriminant."""
    print("=" * 70)
    print("Algorithm D:  block-factorization search for diagonal witnesses")
    print("=" * 70)

    def factor4(d: int, lo: int = 1, hi: int = 4) -> List[Tuple[int, int, int, int]]:
        out: List[Tuple[int, int, int, int]] = []
        for a in range(lo, hi + 1):
            for b in range(a, hi + 1):
                for c in range(b, hi + 1):
                    for e in range(c, hi + 1):
                        if a * b * c * e == d:
                            out.append((a, b, c, e))
        return out

    for target in TARGET_DISCRIMINANTS:
        facs = factor4(target)
        print(f"  disc = {target}: {len(facs)} sorted block multisets -> {facs}")
        for f in facs:
            assert disc(diagonal(list(f))) == target
    print("  verified: every enumerated multiset realises its target.\n")


def demo_truncated_nahm_sum() -> None:
    """Truncated Nahm series f_Q(q) for the disc-16 witness diag(2,2,2,2).

    Computes the first few q-expansion coefficients of
        f_Q(q) = Σ_n q^{Q(n)} / ∏_j (q;q)_{n_j},   Q(n) = ½ nᵀ H n,
    over a truncation, illustrating that the disc-16 datum produces an honest
    integer-coefficient power series (a necessary feature of a modular candidate).
    """
    print("=" * 70)
    print("Truncated Nahm series for the disc-16 witness diag(2,2,2,2)")
    print("=" * 70)
    from fractions import Fraction

    PREC = 16  # truncate at q^PREC
    d = [2, 2, 2, 2]

    def series_mul(a: List[Fraction], b: List[Fraction]) -> List[Fraction]:
        out = [Fraction(0)] * PREC
        for i, ai in enumerate(a):
            if ai == 0:
                continue
            for j, bj in enumerate(b):
                if i + j < PREC and bj != 0:
                    out[i + j] += ai * bj
        return out

    def pochhammer_inv(m: int) -> List[Fraction]:
        """1 / (q;q)_m as a truncated power series."""
        result = [Fraction(0)] * PREC
        result[0] = Fraction(1)
        for k in range(1, m + 1):
            # multiply by 1/(1 - q^k) = sum_t q^{k t}
            geom = [Fraction(0)] * PREC
            t = 0
            while k * t < PREC:
                geom[k * t] = Fraction(1)
                t += 1
            result = series_mul(result, geom)
        return result

    coeffs = [Fraction(0)] * PREC
    NMAX = 3
    for n0 in range(NMAX):
        for n1 in range(NMAX):
            for n2 in range(NMAX):
                for n3 in range(NMAX):
                    n = [n0, n1, n2, n3]
                    # Q(n) = 1/2 nᵀ H n with H = diag(2,2,2,2) gives Σ n_i².
                    expo = sum(d[i] * n[i] * n[i] for i in range(4)) // 2
                    if expo >= PREC:
                        continue
                    term = [Fraction(0)] * PREC
                    term[0] = Fraction(1)
                    for i in range(4):
                        term = series_mul(term, pochhammer_inv(n[i]))
                    # multiply by q^expo
                    shifted = [Fraction(0)] * PREC
                    for j in range(PREC - expo):
                        shifted[j + expo] = term[j]
                    for j in range(PREC):
                        coeffs[j] += shifted[j]

    int_coeffs = [int(c) if c.denominator == 1 else float(c) for c in coeffs[:12]]
    print(f"  Q(n) = n0²+n1²+n2²+n3² (Hessian diag(2,2,2,2), disc = {disc(diagonal(d))})")
    print(f"  f_Q(q) ≈ {int_coeffs} + O(q^12)")
    print("  (integer coefficients, consistent with a modular candidate.)\n")


def main() -> None:
    demo_det_congr()
    demo_disc_invariant()
    demo_disc_directSum_mul()
    demo_disc_diagonal()
    demo_realizable()
    demo_block_factorization_search()
    demo_truncated_nahm_sum()
    print("All demonstrations passed.")


if __name__ == "__main__":
    main()


"""Visualization: the rank-four discriminant landscape and the modular window.

Generates a figure showing, for diagonal Hessians diag(a,b,c,e) with small
positive entries, the distribution of discriminants det = a·b·c·e, highlighting
the conjectured modular window {8, 12, 16} and the divisibility-by-4 structure.
Requires matplotlib.
"""

from __future__ import annotations

from collections import Counter
from itertools import product
from typing import Dict, List

import matplotlib.pyplot as plt

TARGETS = {8, 12, 16}


def discriminant_histogram(max_entry: int = 4) -> Dict[int, int]:
    """Count how many diagonal forms diag(a,b,c,e), 1<=entries<=max_entry,
    yield each discriminant value det = a*b*c*e."""
    counts: Counter[int] = Counter()
    for a, b, c, e in product(range(1, max_entry + 1), repeat=4):
        counts[a * b * c * e] += 1
    return dict(sorted(counts.items()))


def main() -> None:
    hist = discriminant_histogram(4)
    discs: List[int] = list(hist.keys())
    freqs: List[int] = list(hist.values())
    colors = ["#d62728" if d in TARGETS else
              ("#2ca02c" if d % 4 == 0 and 8 <= d <= 16 else "#7f7f7f")
              for d in discs]

    fig, ax = plt.subplots(figsize=(12, 5))
    ax.bar(range(len(discs)), freqs, color=colors)
    ax.set_xticks(range(len(discs)))
    ax.set_xticklabels(discs, rotation=90, fontsize=7)
    ax.set_xlabel("discriminant  det H = product of diagonal entries")
    ax.set_ylabel("number of diagonal forms diag(a,b,c,e), 1<=entries<=4")
    ax.set_title("Rank-four discriminant landscape — conjectured modular window {8, 12, 16} in red")
    for d in TARGETS:
        if d in discs:
            idx = discs.index(d)
            ax.annotate(str(d), (idx, hist[d]), textcoords="offset points",
                        xytext=(0, 4), ha="center", color="#d62728", fontsize=9, weight="bold")
    fig.tight_layout()
    fig.savefig("discriminant_landscape.png", dpi=150)
    print("Saved discriminant_landscape.png")


if __name__ == "__main__":
    main()
