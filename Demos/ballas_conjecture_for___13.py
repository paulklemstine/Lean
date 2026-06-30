"""Numerical demonstrations for the absolute square-tensor bound on equiangular lines.

This module is fully self-contained (standard library only) and illustrates the
mathematics of the absolute bound

    N <= d^2

for any system of N unit vectors in R^d that is equiangular with common angle
parameter alpha (|<v_i, v_j>| = alpha for all i != j, with 0 <= alpha < 1).

The key constructions reproduced here:

  * tensor_square(v):     the lift v |-> v (x) v into R^{d^2}, with
                          <u(x)u, v(x)v> = <u, v>^2.
  * gram_matrix(W):       the matrix of pairwise inner products.
  * quad_form(H, x):      the quadratic form x^T H x, which for a constant-pattern
                          matrix equals (1-c) sum x_i^2 + c (sum x_i)^2.
  * smallest_eigenvalue:  a dependency-free symmetric-eigenvalue estimate used to
                          confirm positive definiteness of the lifted Gram matrix.

Run `python demo.py` to see the demonstrations.
"""

from __future__ import annotations

import math
import random
from typing import List, Sequence, Tuple

Vector = List[float]
Matrix = List[List[float]]


# --------------------------------------------------------------------------- #
# Basic linear algebra (standard library only)
# --------------------------------------------------------------------------- #
def dot(u: Sequence[float], v: Sequence[float]) -> float:
    """Standard inner product <u, v> = sum_a u_a v_a."""
    return sum(a * b for a, b in zip(u, v))


def norm(v: Sequence[float]) -> float:
    """Euclidean norm ||v|| = sqrt(<v, v>)."""
    return math.sqrt(dot(v, v))


def normalize(v: Sequence[float]) -> Vector:
    """Return the unit vector in the direction of v."""
    n = norm(v)
    if n == 0.0:
        raise ValueError("cannot normalize the zero vector")
    return [x / n for x in v]


def tensor_square(v: Sequence[float]) -> Vector:
    """The tensor square v (x) v in R^{d^2}: all products v_a * v_b.

    Satisfies the fundamental identity <tensor_square(u), tensor_square(v)> = <u, v>^2.
    """
    return [v[a] * v[b] for a in range(len(v)) for b in range(len(v))]


def gram_matrix(vectors: Sequence[Sequence[float]]) -> Matrix:
    """The Gram matrix G_ij = <w_i, w_j>."""
    return [[dot(w_i, w_j) for w_j in vectors] for w_i in vectors]


def quad_form(matrix: Matrix, x: Sequence[float]) -> float:
    """Evaluate the quadratic form sum_{i,j} x_i H_ij x_j."""
    return sum(
        x[i] * matrix[i][j] * x[j]
        for i in range(len(x))
        for j in range(len(x))
    )


def constant_pattern_quad_form(c: float, x: Sequence[float]) -> float:
    """Closed form (1-c) sum x_i^2 + c (sum x_i)^2 for a constant-pattern matrix."""
    s2 = sum(xi * xi for xi in x)
    s = sum(x)
    return (1.0 - c) * s2 + c * s * s


def smallest_eigenvalue(matrix: Matrix, iters: int = 2000) -> float:
    """Estimate the smallest eigenvalue of a symmetric matrix via shifted power
    iteration. Returns lambda_min; a positive value certifies positive definiteness.
    """
    n = len(matrix)
    # Largest eigenvalue via power iteration.
    x = [random.gauss(0.0, 1.0) for _ in range(n)]
    x = normalize(x)
    lam_max = 0.0
    for _ in range(iters):
        y = [dot(matrix[i], x) for i in range(n)]
        ny = norm(y)
        if ny == 0.0:
            break
        x = [yi / ny for yi in y]
        lam_max = dot(x, [dot(matrix[i], x) for i in range(n)])
    # Shifted matrix M' = lam_max * I - M, whose largest eigenvalue is
    # lam_max - lam_min; recover lam_min.
    shifted = [[(lam_max if i == j else 0.0) - matrix[i][j] for j in range(n)]
               for i in range(n)]
    z = [random.gauss(0.0, 1.0) for _ in range(n)]
    z = normalize(z)
    mu = 0.0
    for _ in range(iters):
        y = [dot(shifted[i], z) for i in range(n)]
        ny = norm(y)
        if ny == 0.0:
            break
        z = [yi / ny for yi in y]
        mu = dot(z, [dot(shifted[i], z) for i in range(n)])
    return lam_max - mu


# --------------------------------------------------------------------------- #
# Equiangular-system utilities
# --------------------------------------------------------------------------- #
def is_equiangular(vectors: Sequence[Sequence[float]], alpha: float,
                   tol: float = 1e-9) -> bool:
    """Check unit norm and |<v_i, v_j>| = alpha for all i != j."""
    for v in vectors:
        if abs(norm(v) - 1.0) > tol:
            return False
    n = len(vectors)
    for i in range(n):
        for j in range(i + 1, n):
            if abs(abs(dot(vectors[i], vectors[j])) - alpha) > tol:
                return False
    return True


def lifted_gram_spectrum(alpha: float, n: int) -> Tuple[float, float]:
    """Theoretical spectrum of the constant-pattern lifted Gram matrix
    (1 - alpha^2) I + alpha^2 J of size n:
      lambda_min = 1 - alpha^2   (multiplicity n - 1)
      lambda_max = 1 + (n-1) alpha^2 (multiplicity 1).
    """
    c = alpha * alpha
    return (1.0 - c, 1.0 + (n - 1) * c)


# --------------------------------------------------------------------------- #
# Concrete equiangular configurations
# --------------------------------------------------------------------------- #
def icosahedron_lines() -> List[Vector]:
    """Six equiangular lines in R^3 (icosahedron diagonals), alpha = 1/sqrt(5)."""
    phi = (1.0 + math.sqrt(5.0)) / 2.0
    raw = [
        (0.0, 1.0, phi), (0.0, 1.0, -phi),
        (1.0, phi, 0.0), (1.0, -phi, 0.0),
        (phi, 0.0, 1.0), (phi, 0.0, -1.0),
    ]
    return [normalize(v) for v in raw]


def tetrahedron_lines() -> List[Vector]:
    """Four equiangular lines in R^3 through tetrahedron vertices, alpha = 1/3."""
    raw = [
        (1.0, 1.0, 1.0), (1.0, -1.0, -1.0),
        (-1.0, 1.0, -1.0), (-1.0, -1.0, 1.0),
    ]
    return [normalize(v) for v in raw]


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_tensor_identity() -> None:
    print("=" * 70)
    print("DEMO 1: tensor-square identity  <u(x)u, v(x)v> = <u, v>^2")
    print("=" * 70)
    random.seed(0)
    for _ in range(3):
        d = random.randint(2, 5)
        u = normalize([random.gauss(0, 1) for _ in range(d)])
        v = normalize([random.gauss(0, 1) for _ in range(d)])
        lhs = dot(tensor_square(u), tensor_square(v))
        rhs = dot(u, v) ** 2
        print(f"  d={d}: <u(x)u,v(x)v>={lhs:+.10f}  <u,v>^2={rhs:+.10f}  "
              f"diff={abs(lhs - rhs):.2e}")
    print()


def demo_constant_pattern() -> None:
    print("=" * 70)
    print("DEMO 2: lifted Gram matrix is constant-pattern and positive definite")
    print("=" * 70)
    for name, vectors, alpha in [
        ("tetrahedron (alpha=1/3)", tetrahedron_lines(), 1.0 / 3.0),
        ("icosahedron (alpha=1/sqrt5)", icosahedron_lines(), 1.0 / math.sqrt(5.0)),
    ]:
        lifted = [tensor_square(v) for v in vectors]
        H = gram_matrix(lifted)
        n = len(vectors)
        diag_ok = all(abs(H[i][i] - 1.0) < 1e-9 for i in range(n))
        off_ok = all(abs(H[i][j] - alpha ** 2) < 1e-9
                     for i in range(n) for j in range(n) if i != j)
        lmin_theory, lmax_theory = lifted_gram_spectrum(alpha, n)
        lmin_num = smallest_eigenvalue(H)
        print(f"  {name}:")
        print(f"    diagonal == 1 : {diag_ok}")
        print(f"    off-diag == a^2={alpha**2:.6f} : {off_ok}")
        print(f"    lambda_min theory={lmin_theory:.6f}  numeric={lmin_num:.6f}")
        print(f"    lambda_max theory={lmax_theory:.6f}")
        print(f"    positive definite (lambda_min>0): {lmin_num > 1e-6}")
    print()


def demo_quad_form_identity() -> None:
    print("=" * 70)
    print("DEMO 3: quadratic-form identity for constant-pattern matrices")
    print("        x^T H x = (1-c) sum x_i^2 + c (sum x_i)^2")
    print("=" * 70)
    random.seed(1)
    c = (1.0 / 3.0) ** 2
    n = 5
    H = [[1.0 if i == j else c for j in range(n)] for i in range(n)]
    for _ in range(3):
        x = [random.gauss(0, 1) for _ in range(n)]
        direct = quad_form(H, x)
        closed = constant_pattern_quad_form(c, x)
        print(f"  direct={direct:+.8f}  closed-form={closed:+.8f}  "
              f"diff={abs(direct - closed):.2e}")
    print()


def demo_bound_check() -> None:
    print("=" * 70)
    print("DEMO 4: the bound N <= d^2 on concrete configurations")
    print("=" * 70)
    for name, vectors, alpha, d in [
        ("tetrahedron", tetrahedron_lines(), 1.0 / 3.0, 3),
        ("icosahedron", icosahedron_lines(), 1.0 / math.sqrt(5.0), 3),
    ]:
        n = len(vectors)
        eq = is_equiangular(vectors, alpha)
        print(f"  {name}: N={n}, d={d}, d^2={d*d}, equiangular={eq}, "
              f"N<=d^2: {n <= d * d}")
    print()


def demo_balla_third() -> None:
    print("=" * 70)
    print("DEMO 5: Balla's conjecture for alpha = 1/3 vs the absolute bound")
    print("        N_{1/3}(d) <= max(28, 2(d-1))    [conjectured, sharp]")
    print("        N_{1/3}(d) <= d^2                [proved, unconditional]")
    print("=" * 70)
    print(f"  {'d':>4} | {'absolute d^2':>12} | {'Balla max(28,2(d-1))':>22}")
    print("  " + "-" * 46)
    for d in [2, 3, 4, 5, 6, 7, 10, 15, 28, 50]:
        absolute = d * d
        balla = max(28, 2 * (d - 1))
        print(f"  {d:>4} | {absolute:>12} | {balla:>22}")
    print()


def main() -> None:
    demo_tensor_identity()
    demo_constant_pattern()
    demo_quad_form_identity()
    demo_bound_check()
    demo_balla_third()


if __name__ == "__main__":
    main()
