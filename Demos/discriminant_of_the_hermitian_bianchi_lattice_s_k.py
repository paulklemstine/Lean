"""
Numerical demonstration of the discriminant identity for the Hermitian Bianchi
lattice S_K = Herm_2(O_K).

For a squarefree integer d < 0, with K = Q(sqrt(d)) and ring of integers
O_K = Z[omega], we form the rank-four lattice of Hermitian 2x2 matrices over O_K
with the quadratic form q(A) = 2 det(A). Choosing the basis of the two diagonal
Hermitian matrix units together with the off-diagonal generators 1 and omega,
the Gram matrix of the polarising bilinear form is block-diagonal:

    [  0   1   0    0  ]
    [  1   0   0    0  ]
    [  0   0  -2   -T  ]
    [  0   0  -T  -2M  ]

where T = Tr(omega) and M = N(omega). This script verifies, for many d, that

    det Gram(S_K) = T^2 - 4M = D_K  (the fundamental discriminant of K),

i.e. d if d == 1 (mod 4), and 4d otherwise.

Mirrors the Lean theorems:
    qform_eq_two_hermDet, gramMatrix_eq, det_gramMatrix,
    discriminantInvariant, detGram_eq_fundamentalDisc, discriminant_S_K.

Pure Python, no third-party dependencies.
"""

from __future__ import annotations

from fractions import Fraction
from typing import List


# ---------------------------------------------------------------------------
# Number-field invariants (mirror omegaTrace, omegaNorm, fundamentalDisc)
# ---------------------------------------------------------------------------

def is_squarefree(n: int) -> bool:
    """Return True iff |n| is squarefree (no repeated prime factor)."""
    m = abs(n)
    if m == 0:
        return False
    k = 2
    while k * k <= m:
        if m % (k * k) == 0:
            return False
        k += 1
    return True


def omega_trace(d: int) -> int:
    """T = Tr(omega): 1 if d == 1 (mod 4) else 0."""
    return 1 if d % 4 == 1 else 0


def omega_norm(d: int) -> int:
    """M = N(omega): (1 - d)/4 if d == 1 (mod 4) else -d."""
    if d % 4 == 1:
        assert (1 - d) % 4 == 0, "integrality of (1-d)/4 fails"
        return (1 - d) // 4
    return -d


def fundamental_disc(d: int) -> int:
    """D_K: d if d == 1 (mod 4) else 4d."""
    return d if d % 4 == 1 else 4 * d


# ---------------------------------------------------------------------------
# The lattice quadratic form and Gram matrix (mirror qform, bil, gramMatrix)
# ---------------------------------------------------------------------------

def qform(t: int, m: int, v: List[int]) -> int:
    """q(a,c,x,y) = 2ac - 2x^2 - 2T xy - 2M y^2 (v = [a, c, x, y])."""
    a, c, x, y = v
    return 2 * (a * c) - 2 * x ** 2 - 2 * t * (x * y) - 2 * m * y ** 2


def herm_det(t: int, m: int, a: int, c: int, x: int, y: int) -> int:
    """det of the Hermitian matrix = ac - (x^2 + T xy + M y^2)."""
    return a * c - (x ** 2 + t * x * y + m * y ** 2)


def gram_matrix(t: int, m: int) -> List[List[int]]:
    """The 4x4 Gram matrix of the polarising bilinear form."""
    return [
        [0, 1, 0, 0],
        [1, 0, 0, 0],
        [0, 0, -2, -t],
        [0, 0, -t, -2 * m],
    ]


def det4(matrix: List[List[int]]) -> int:
    """Exact integer determinant of a 4x4 matrix via Fraction Gaussian elim."""
    n = len(matrix)
    a = [[Fraction(x) for x in row] for row in matrix]
    det = Fraction(1)
    for col in range(n):
        piv = next((r for r in range(col, n) if a[r][col] != 0), None)
        if piv is None:
            return 0
        if piv != col:
            a[col], a[piv] = a[piv], a[col]
            det = -det
        det *= a[col][col]
        inv = a[col][col]
        for r in range(col + 1, n):
            factor = a[r][col] / inv
            for k in range(col, n):
                a[r][k] -= factor * a[col][k]
    assert det.denominator == 1
    return int(det)


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_table(d_values: List[int]) -> None:
    print("Discriminant identity:  det Gram(S_K) = T^2 - 4M = D_K\n")
    header = f"{'d':>5} {'d%4':>4} {'T':>3} {'M':>6} {'detGram':>8} " \
             f"{'T^2-4M':>8} {'D_K':>6}  {'OK':>3}"
    print(header)
    print("-" * len(header))
    for d in d_values:
        if not (d < 0 and is_squarefree(d)):
            continue
        t, m = omega_trace(d), omega_norm(d)
        dg = det4(gram_matrix(t, m))
        alg = t ** 2 - 4 * m
        dk = fundamental_disc(d)
        ok = (dg == alg == dk)
        print(f"{d:>5} {d % 4:>4} {t:>3} {m:>6} {dg:>8} {alg:>8} {dk:>6} "
              f"{'yes' if ok else 'NO':>4}")
        assert ok, f"identity failed for d={d}"


def demo_qform_eq_two_det(d: int) -> None:
    """Check q(a,c,x,y) = 2 det for random-ish sample coordinates."""
    t, m = omega_trace(d), omega_norm(d)
    print(f"\nq = 2*det check for d = {d} (T={t}, M={m}):")
    for (a, c, x, y) in [(1, 0, 0, 0), (0, 1, 0, 0), (1, 1, 1, 0),
                         (2, 3, -1, 2), (-1, 4, 3, -2)]:
        lhs = qform(t, m, [a, c, x, y])
        rhs = 2 * herm_det(t, m, a, c, x, y)
        print(f"  (a,c,x,y)=({a:>2},{c:>2},{x:>2},{y:>2})  "
              f"q={lhs:>5}  2det={rhs:>5}  {'ok' if lhs == rhs else 'NO'}")
        assert lhs == rhs


def main() -> None:
    d_values = [-1, -2, -3, -5, -6, -7, -10, -11, -13, -14, -15,
                -17, -19, -21, -22, -23, -26, -29, -30, -31, -1003]
    demo_table(d_values)
    demo_qform_eq_two_det(-3)
    demo_qform_eq_two_det(-1)
    print("\nAll checks passed: det Gram(S_K) = D_K for every tested field.")


if __name__ == "__main__":
    main()
