"""
demo.py — The Berggren-Lorentz Monoid: Discrete Lorentz Symmetry of
Pythagorean Triples.

Numerical demonstrations of the machine-verified results:

  * The Lorentz form Q(a,b,c) = a^2 + b^2 - c^2 and the light-cone
    correspondence (Q = 0  <=>  Pythagorean).
  * The three Berggren generators A, B, C as integer Lorentz transformations
    in O(2,1; Z): M^T Q_L M = Q_L, with det(A,B,C) = (+1,-1,+1) and
    tr(A,B,C) = (3,5,3).
  * The child maps, the Berggren tree, and exact orbit values.
  * The sharp B-branch growth law  hyp(B-child) > 5 * hyp(parent).
  * The twin-leg (consecutive-leg) subfamily along the B-branch.
  * Spectral invariants, inverses, the relation C = -(A . Q_L), Q_L^2 = I.
  * Entrywise (|.| <= 3) and row-sum (<= 7) Lipschitz bounds.
  * Euclid's parametrization (m^2-n^2, 2mn, m^2+n^2).

Pure standard library, fully self-contained, type-hinted.
"""

from __future__ import annotations

from typing import List, Tuple

Triple = Tuple[int, int, int]
Matrix = List[List[int]]

# --------------------------------------------------------------------------
# Core data: generators and metric (Definitions 2.4, 2.5)
# --------------------------------------------------------------------------

A: Matrix = [[1, -2, 2], [2, -1, 2], [2, -2, 3]]
B: Matrix = [[1, 2, 2], [2, 1, 2], [2, 2, 3]]
C: Matrix = [[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]]
Q_L: Matrix = [[1, 0, 0], [0, 1, 0], [0, 0, -1]]

INV_A: Matrix = [[1, 2, -2], [-2, -1, 2], [-2, -2, 3]]
INV_B: Matrix = [[1, 2, -2], [2, 1, -2], [-2, -2, 3]]
INV_C: Matrix = [[-1, -2, 2], [2, 1, -2], [-2, -2, 3]]

SEED: Triple = (3, 4, 5)


# --------------------------------------------------------------------------
# Linear-algebra helpers (exact integer arithmetic)
# --------------------------------------------------------------------------

def matmul(M: Matrix, N: Matrix) -> Matrix:
    """Exact integer 3x3 matrix product."""
    return [[sum(M[i][k] * N[k][j] for k in range(3)) for j in range(3)]
            for i in range(3)]


def transpose(M: Matrix) -> Matrix:
    return [[M[j][i] for j in range(3)] for i in range(3)]


def matvec(M: Matrix, v: Triple) -> Triple:
    r = [sum(M[i][k] * v[k] for k in range(3)) for i in range(3)]
    return (r[0], r[1], r[2])


def trace(M: Matrix) -> int:
    return M[0][0] + M[1][1] + M[2][2]


def det3(M: Matrix) -> int:
    return (M[0][0] * (M[1][1] * M[2][2] - M[1][2] * M[2][1])
            - M[0][1] * (M[1][0] * M[2][2] - M[1][2] * M[2][0])
            + M[0][2] * (M[1][0] * M[2][1] - M[1][1] * M[2][0]))


def scalar(s: int, M: Matrix) -> Matrix:
    return [[s * M[i][j] for j in range(3)] for i in range(3)]


def identity() -> Matrix:
    return [[1 if i == j else 0 for j in range(3)] for i in range(3)]


def sub(M: Matrix, N: Matrix) -> Matrix:
    return [[M[i][j] - N[i][j] for j in range(3)] for i in range(3)]


# --------------------------------------------------------------------------
# Mathematical objects (Definitions 2.1, 2.3, 2.6, 2.11, 2.12)
# --------------------------------------------------------------------------

def lorentz_Q(t: Triple) -> int:
    """Q(a,b,c) = a^2 + b^2 - c^2."""
    a, b, c = t
    return a * a + b * b - c * c


def is_pythag(t: Triple) -> bool:
    a, b, c = t
    return a * a + b * b == c * c


def child_A(t: Triple) -> Triple:
    a, b, c = t
    return (a - 2 * b + 2 * c, 2 * a - b + 2 * c, 2 * a - 2 * b + 3 * c)


def child_B(t: Triple) -> Triple:
    a, b, c = t
    return (a + 2 * b + 2 * c, 2 * a + b + 2 * c, 2 * a + 2 * b + 3 * c)


def child_C(t: Triple) -> Triple:
    a, b, c = t
    return (-a + 2 * b + 2 * c, -2 * a + b + 2 * c, -2 * a + 2 * b + 3 * c)


def parametric_triple(m: int, n: int) -> Triple:
    """Euclid: (m^2 - n^2, 2mn, m^2 + n^2)."""
    return (m * m - n * n, 2 * m * n, m * m + n * n)


def is_twin_leg(t: Triple) -> bool:
    a, b, c = t
    return is_pythag(t) and abs(a - b) == 1


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------

def demo_light_cone() -> None:
    print("=" * 70)
    print("1.  Light-cone correspondence:  Q = 0  <=>  Pythagorean")
    print("=" * 70)
    for t in [(3, 4, 5), (5, 12, 13), (6, 7, 10), (8, 15, 17)]:
        print(f"  Q{t} = {lorentz_Q(t):>4}   pythag? {is_pythag(t)}")
    assert all(lorentz_Q(t) == 0 for t in [(3, 4, 5), (5, 12, 13)])
    assert lorentz_Q((6, 7, 10)) != 0 and not is_pythag((6, 7, 10))
    print()


def demo_lorentz_group() -> None:
    print("=" * 70)
    print("2.  Generators lie in O(2,1; Z):  M^T Q_L M = Q_L")
    print("=" * 70)
    for name, M, exp_det, exp_tr in [("A", A, 1, 3), ("B", B, -1, 5),
                                     ("C", C, 1, 3)]:
        preserved = matmul(matmul(transpose(M), Q_L), M) == Q_L
        print(f"  {name}: preserves Q_L? {preserved}   "
              f"det = {det3(M):>2} (exp {exp_det})   "
              f"tr = {trace(M)} (exp {exp_tr})")
        assert preserved and det3(M) == exp_det and trace(M) == exp_tr
    print()


def demo_tree() -> None:
    print("=" * 70)
    print("3.  Berggren tree: children of the seed (3,4,5)")
    print("=" * 70)
    print(f"  childA(3,4,5) = {child_A(SEED)}   pythag? {is_pythag(child_A(SEED))}")
    print(f"  childB(3,4,5) = {child_B(SEED)}   pythag? {is_pythag(child_B(SEED))}")
    print(f"  childC(3,4,5) = {child_C(SEED)}   pythag? {is_pythag(child_C(SEED))}")
    assert child_A(SEED) == (5, 12, 13)
    assert child_B(SEED) == (21, 20, 29)
    assert child_C(SEED) == (15, 8, 17)
    # child maps preserve Q identically (not only on the cone)
    off_cone = (6, 7, 10)
    assert lorentz_Q(child_A(off_cone)) == lorentz_Q(off_cone)
    print("  child maps preserve Q identically (checked off-cone too): OK")
    # matrix action agrees with coordinate formulas
    assert matvec(A, SEED) == child_A(SEED)
    print("  matrix action matvec(A, seed) == childA(seed): OK")
    print()


def demo_b_branch() -> None:
    print("=" * 70)
    print("4.  B-branch orbit and the growth law  hyp(B-child) > 5*hyp")
    print("=" * 70)
    t: Triple = SEED
    hyps: List[int] = [t[2]]
    for _ in range(5):
        t = child_B(t)
        hyps.append(t[2])
    print(f"  hypotenuse sequence: {hyps}")
    for i in range(len(hyps) - 1):
        ratio = hyps[i + 1] / hyps[i]
        assert hyps[i + 1] > 5 * hyps[i]
        print(f"    {hyps[i]:>6} -> {hyps[i+1]:>6}   ratio = {ratio:.4f} (> 5)")
    print("  asymptotic factor approaches 3 + 2*sqrt(2) ~= 5.8284")
    print()


def demo_twin_legs() -> None:
    print("=" * 70)
    print("5.  Twin-leg (consecutive-leg) family = the B-orbit")
    print("=" * 70)
    t: Triple = SEED
    for _ in range(4):
        a, b, c = t
        print(f"  {(a, b, c)}   |a-b| = {abs(a-b)}   twin-leg? {is_twin_leg(t)}")
        assert is_twin_leg(t)
        t = child_B(t)
    print()


def demo_spectral() -> None:
    print("=" * 70)
    print("6.  Spectral / algebraic invariants")
    print("=" * 70)
    print(f"  tr(AB) = {trace(matmul(A, B))}, tr(AC) = {trace(matmul(A, C))}, "
          f"tr(BC) = {trace(matmul(B, C))}   (tr(AB)=tr(BC) symmetry)")
    assert trace(matmul(A, B)) == 17 == trace(matmul(B, C))
    assert trace(matmul(A, C)) == 15
    # eigenvalue 1 structure
    for name, M in [("A", A), ("B", B), ("C", C)]:
        d = det3(sub(identity(), M))
        print(f"  det(I - {name}) = {d:>3}   "
              f"({'1 is an eigenvalue' if d == 0 else '1 is NOT an eigenvalue'})")
    assert det3(sub(identity(), A)) == 0 and det3(sub(identity(), B)) == -8
    # C = -(A . Q_L)
    assert C == scalar(-1, matmul(A, Q_L))
    print("  generator reduction  C = -(A . Q_L): OK")
    # A^{-1} C = -Q_L
    assert matmul(INV_A, C) == scalar(-1, Q_L)
    print("  A^{-1} . C = -Q_L: OK")
    # metric involution
    assert matmul(Q_L, Q_L) == identity()
    print("  metric involution  Q_L^2 = I: OK")
    # inverses
    assert matmul(A, INV_A) == identity()
    assert matmul(B, INV_B) == identity()
    assert matmul(C, INV_C) == identity()
    print("  A A^{-1} = B B^{-1} = C C^{-1} = I: OK")
    # non-commutativity
    assert matmul(A, B) != matmul(B, A)
    print("  non-commutativity  AB != BA: OK")
    print()


def demo_lipschitz() -> None:
    print("=" * 70)
    print("7.  Entrywise and row-sum (Lipschitz) bounds")
    print("=" * 70)
    for name, M in [("A", A), ("B", B), ("C", C)]:
        max_entry = max(abs(M[i][j]) for i in range(3) for j in range(3))
        max_row = max(sum(abs(M[i][j]) for j in range(3)) for i in range(3))
        print(f"  {name}: max|entry| = {max_entry} (<= 3)   "
              f"max row-sum = {max_row} (<= 7)")
        assert max_entry <= 3 and max_row <= 7
    print("  => composition of n generators is 7^n-Lipschitz in the inf-norm")
    print()


def demo_euclid() -> None:
    print("=" * 70)
    print("8.  Euclid parametrization  (m^2-n^2, 2mn, m^2+n^2)")
    print("=" * 70)
    for (m, n) in [(2, 1), (3, 2), (4, 1), (5, 2)]:
        t = parametric_triple(m, n)
        print(f"  P({m},{n}) = {t}   pythag? {is_pythag(t)}   Q = {lorentz_Q(t)}")
        assert is_pythag(t) and lorentz_Q(t) == 0
    assert parametric_triple(2, 1) == (3, 4, 5)
    print()


def main() -> None:
    demo_light_cone()
    demo_lorentz_group()
    demo_tree()
    demo_b_branch()
    demo_twin_legs()
    demo_spectral()
    demo_lipschitz()
    demo_euclid()
    print("All demonstrations passed and match the machine-verified results.")


if __name__ == "__main__":
    main()
