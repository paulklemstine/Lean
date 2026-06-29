"""
demo.py — Numerical demonstrations for:

    Intersection Forms and the Donaldson Obstruction
    (A verified algebraic core of the smooth 4D Poincaré story)

This script is fully self-contained (standard library only). It implements
integer symmetric "intersection forms" and demonstrates, by direct computation,
every result in the accompanying article and paper:

  * value(Q, v) = vᵀ G v                          (Definition: quadratic value)
  * is_even(Q)  <=>  every diagonal entry is even  (diagonal criterion)
  * change of basis:  value(Q, T v) = vᵀ (Tᵀ G T) v   (value_basisChange)
  * the standard form ⟨1⟩ⁿ is NOT even             (stdForm_not_even)
  * a positive-rank EVEN form is never standard     (even_not_stdDiagonalizable)
  * E8 is even, unimodular (det = 1), positive-definite, rank 8
  * E8 is NOT standard-diagonalizable  =>  (with Donaldson) not smoothable
  * the rank-0 sphere form is trivially unimodular / even / standard

Run:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from itertools import product
from typing import List, Sequence

# ---------------------------------------------------------------------------
# Minimal integer linear algebra (no numpy dependency)
# ---------------------------------------------------------------------------

Matrix = List[List[int]]
Vector = List[int]


def mat_vec(A: Matrix, v: Sequence[int]) -> Vector:
    """Matrix-vector product A v over the integers."""
    return [sum(A[i][j] * v[j] for j in range(len(v))) for i in range(len(A))]


def dot(u: Sequence[int], v: Sequence[int]) -> int:
    """Integer dot product u . v."""
    return sum(a * b for a, b in zip(u, v))


def transpose(A: Matrix) -> Matrix:
    """Matrix transpose Aᵀ."""
    return [[A[j][i] for j in range(len(A))] for i in range(len(A[0]))]


def mat_mul(A: Matrix, B: Matrix) -> Matrix:
    """Matrix product A B over the integers."""
    n, m, p = len(A), len(B), len(B[0])
    return [[sum(A[i][k] * B[k][j] for k in range(m)) for j in range(p)] for i in range(n)]


def identity(n: int) -> Matrix:
    """The n x n identity matrix."""
    return [[1 if i == j else 0 for j in range(n)] for i in range(n)]


def is_symmetric(G: Matrix) -> bool:
    """True iff G equals its transpose."""
    n = len(G)
    return all(G[i][j] == G[j][i] for i in range(n) for j in range(n))


def det_fraction(A: Matrix) -> int:
    """Exact determinant via fraction-based Gaussian elimination (integer result)."""
    n = len(A)
    M = [[Fraction(x) for x in row] for row in A]
    det = Fraction(1)
    for col in range(n):
        piv = next((r for r in range(col, n) if M[r][col] != 0), None)
        if piv is None:
            return 0
        if piv != col:
            M[col], M[piv] = M[piv], M[col]
            det = -det
        det *= M[col][col]
        inv = M[col][col]
        for r in range(col + 1, n):
            factor = M[r][col] / inv
            if factor != 0:
                M[r] = [M[r][k] - factor * M[col][k] for k in range(n)]
    return int(det)


# ---------------------------------------------------------------------------
# Intersection forms
# ---------------------------------------------------------------------------

class IntersectionForm:
    """A symmetric integral Gram matrix modeling the cup-product pairing on H^2."""

    def __init__(self, gram: Matrix) -> None:
        assert is_symmetric(gram), "intersection form must be symmetric"
        self.gram: Matrix = gram
        self.n: int = len(gram)

    def value(self, v: Sequence[int]) -> int:
        """Q(v) = vᵀ G v."""
        return dot(v, mat_vec(self.gram, v))

    def is_even(self) -> bool:
        """Q is even  <=>  every diagonal entry G_ii is even (diagonal criterion)."""
        return all(self.gram[i][i] % 2 == 0 for i in range(self.n))

    def is_unimodular(self) -> bool:
        """Poincaré duality: det G = ±1."""
        return abs(det_fraction(self.gram)) == 1

    def is_unimodular_certified(self, inv: Matrix) -> bool:
        """Certify unimodularity by exhibiting an integral inverse: G * inv = I."""
        return mat_mul(self.gram, inv) == identity(self.n)

    def value_basis_change(self, T: Matrix, v: Sequence[int]) -> bool:
        """Check value(Q, T v) == vᵀ (Tᵀ G T) v  (the change-of-basis identity)."""
        lhs = self.value(mat_vec(T, v))
        TtGT = mat_mul(mat_mul(transpose(T), self.gram), T)
        rhs = dot(v, mat_vec(TtGT, v))
        return lhs == rhs

    def is_positive_definite(self) -> bool:
        """Check Q(v) > 0 for all small nonzero v (heuristic via leading minors)."""
        # Sylvester's criterion: all leading principal minors are positive.
        for k in range(1, self.n + 1):
            sub = [row[:k] for row in self.gram[:k]]
            if det_fraction(sub) <= 0:
                return False
        return True


def std_form(n: int) -> IntersectionForm:
    """The standard positive-definite form ⟨1⟩ⁿ = diag(1,...,1)."""
    return IntersectionForm(identity(n))


def sphere_form() -> IntersectionForm:
    """The trivial rank-0 intersection form of S^4."""
    return IntersectionForm([])


# The E8 Cartan / Gram matrix: even, unimodular, positive-definite, rank 8.
E8_MAT: Matrix = [
    [2, -1, 0, 0, 0, 0, 0, 0],
    [-1, 2, -1, 0, 0, 0, 0, 0],
    [0, -1, 2, -1, 0, 0, 0, 0],
    [0, 0, -1, 2, -1, 0, 0, 0],
    [0, 0, 0, -1, 2, -1, 0, -1],
    [0, 0, 0, 0, -1, 2, -1, 0],
    [0, 0, 0, 0, 0, -1, 2, 0],
    [0, 0, 0, 0, -1, 0, 0, 2],
]


def e8_form() -> IntersectionForm:
    """The E8 intersection form."""
    return IntersectionForm(E8_MAT)


def integer_inverse(A: Matrix) -> Matrix:
    """Compute the (assumed integral) inverse of a unimodular integer matrix."""
    n = len(A)
    M = [[Fraction(A[i][j]) for j in range(n)] + [Fraction(1 if i == j else 0) for j in range(n)]
         for i in range(n)]
    for col in range(n):
        piv = next(r for r in range(col, n) if M[r][col] != 0)
        M[col], M[piv] = M[piv], M[col]
        pivot = M[col][col]
        M[col] = [x / pivot for x in M[col]]
        for r in range(n):
            if r != col and M[r][col] != 0:
                f = M[r][col]
                M[r] = [M[r][k] - f * M[col][k] for k in range(2 * n)]
    return [[int(M[i][j + n]) for j in range(n)] for i in range(n)]


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_value_and_diagonal() -> None:
    print("=" * 70)
    print("1. Value function and the diagonal evenness criterion")
    print("=" * 70)
    G = IntersectionForm([[2, 1], [1, 4]])
    for v in [[1, 0], [0, 1], [1, 1], [2, -1]]:
        print(f"   Q({v}) = {G.value(v)}")
    print(f"   diagonal = (2, 4) all even  ->  is_even = {G.is_even()}")
    odd = IntersectionForm([[2, 1], [1, 3]])
    print(f"   form with diagonal (2, 3): is_even = {odd.is_even()}  (3 is odd)")
    print()


def demo_change_of_basis() -> None:
    print("=" * 70)
    print("2. Change-of-basis identity:  Q(Tv) = vᵀ(Tᵀ G T)v")
    print("=" * 70)
    Q = e8_form()
    T = [[1 if i == j else (1 if (i, j) == (0, 1) else 0) for j in range(8)] for i in range(8)]
    ok = all(Q.value_basis_change(T, list(v))
             for v in product([-1, 0, 1], repeat=8) if any(v))
    print(f"   verified on all v in {{-1,0,1}}^8 (nonzero): {ok}")
    print()


def demo_std_form() -> None:
    print("=" * 70)
    print("3. The standard form ⟨1⟩ⁿ is NOT even (boundary case)")
    print("=" * 70)
    for n in [1, 2, 3]:
        S = std_form(n)
        e0 = [1] + [0] * (n - 1)
        print(f"   n={n}: Q(e0) = {S.value(e0)} (odd)  ->  is_even = {S.is_even()}")
    print()


def demo_donaldson_obstruction() -> None:
    print("=" * 70)
    print("4. Donaldson obstruction: positive-rank EVEN form is never standard")
    print("=" * 70)
    print("   If Tᵀ G T = I then Q(T e0) = e0 . I e0 = 1, which is ODD.")
    print("   An even form forbids odd values  =>  contradiction.")
    Q = e8_form()
    e0 = [1, 0, 0, 0, 0, 0, 0, 0]
    print(f"   E8 is even: {Q.is_even()};  positive rank: {Q.n > 0}")
    print(f"   => E8 is NOT standard-diagonalizable (no integral T with TᵀGT=I).")
    print(f"   (Demonstration that the standard form yields value 1 at e0: "
          f"{std_form(8).value(e0)})")
    print()


def demo_e8() -> None:
    print("=" * 70)
    print("5. The E8 form: even, unimodular, positive-definite, rank 8")
    print("=" * 70)
    Q = e8_form()
    inv = integer_inverse(E8_MAT)
    print(f"   rank                 = {Q.n}")
    print(f"   det(E8)              = {det_fraction(E8_MAT)}")
    print(f"   is_even              = {Q.is_even()}  (all diagonal entries = 2)")
    print(f"   is_unimodular        = {Q.is_unimodular()}")
    print(f"   certified by inverse = {Q.is_unimodular_certified(inv)}  (E8 * E8inv = I)")
    print(f"   positive-definite    = {Q.is_positive_definite()}")
    print(f"   minimum nonzero Q(v) over {{-1,0,1}}^8 = "
          f"{min(Q.value(list(v)) for v in product([-1,0,1], repeat=8) if any(v))}")
    print("   CONCLUSION: E8 is even & positive-rank => not standard-diagonalizable")
    print("   => (with Donaldson) E8 is NOT the form of any SMOOTH closed s.c. 4-mfd,")
    print("      yet (Freedman) it IS realized TOPOLOGICALLY. The smooth/top gap!")
    print()


def demo_sphere() -> None:
    print("=" * 70)
    print("6. The sphere form of S^4: trivial rank-0, detects nothing")
    print("=" * 70)
    S = sphere_form()
    print(f"   rank          = {S.n}")
    print(f"   value([])     = {S.value([])}  (vacuously even)")
    print(f"   is_even       = {S.is_even()}")
    print(f"   det           = {det_fraction(S.gram) if S.n else 1}  (unimodular, vacuous)")
    print("   => every homotopy 4-sphere has THIS form, so the intersection form")
    print("      cannot detect exotic smooth structures: SPC4 stays out of reach.")
    print()


def main() -> None:
    demo_value_and_diagonal()
    demo_change_of_basis()
    demo_std_form()
    demo_donaldson_obstruction()
    demo_e8()
    demo_sphere()
    print("All demonstrations completed: the algebraic core checks out numerically.")


if __name__ == "__main__":
    main()
