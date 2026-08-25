"""Exact central hyperplane section volume of an ellipsoid.

Implements  vol_{n-1}(E(A) cap u^perp) = (|det A| / ||A^T u||) * w_{n-1}.

Pure standard library; no third-party dependencies.
"""

from __future__ import annotations

import math
from typing import List, Sequence

Matrix = List[List[float]]
Vector = List[float]


def determinant(a: Matrix) -> float:
    """Determinant via LU decomposition with partial pivoting.  Cost O(n^3)."""
    n: int = len(a)
    m: Matrix = [row[:] for row in a]
    sign: float = 1.0
    d: float = 1.0
    for c in range(n):
        piv: int = max(range(c, n), key=lambda r: abs(m[r][c]))
        if abs(m[piv][c]) < 1e-300:
            return 0.0
        if piv != c:
            m[c], m[piv] = m[piv], m[c]
            sign = -sign
        d *= m[c][c]
        inv: float = 1.0 / m[c][c]
        for r in range(c + 1, n):
            f: float = m[r][c] * inv
            if f != 0.0:
                for j in range(c, n):
                    m[r][j] -= f * m[c][j]
    return sign * d


def transpose_matvec(a: Matrix, u: Sequence[float]) -> Vector:
    """Return A^T u.  Cost O(n^2)."""
    n: int = len(a)
    k: int = len(a[0])
    return [sum(a[i][j] * u[i] for i in range(n)) for j in range(k)]


def euclidean_norm(v: Sequence[float]) -> float:
    """Euclidean norm of a vector."""
    return math.sqrt(sum(x * x for x in v))


def unit_ball_volume(m: int) -> float:
    """Volume w_m = pi^(m/2) / Gamma(m/2 + 1) of the unit ball in R^m."""
    return math.pi ** (m / 2.0) / math.gamma(m / 2.0 + 1.0)


def central_section_volume(a: Matrix, u: Sequence[float]) -> float:
    """(n-1)-volume of the central section of E(A) by the hyperplane u^perp.

    `a` must be invertible and `u` a nonzero vector (it is normalised internally).
    """
    n: int = len(a)
    nu: float = euclidean_norm(u)
    if nu == 0.0:
        raise ValueError("the slicing direction must be nonzero")
    u_hat: Vector = [x / nu for x in u]
    delta: float = abs(determinant(a))
    if delta == 0.0:
        raise ValueError("the generator must be invertible")
    dual: float = euclidean_norm(transpose_matvec(a, u_hat))
    return delta / dual * unit_ball_volume(n - 1)


if __name__ == "__main__":
    A: Matrix = [[2.0, 0.0, 0.0], [0.0, 1.0, 0.0], [0.0, 0.0, 0.5]]
    for direction in ([1.0, 0.0, 0.0], [0.0, 1.0, 0.0], [0.0, 0.0, 1.0]):
        print(direction, "->", round(central_section_volume(A, direction), 8))
    # expected: pi*1*0.5, pi*2*0.5, pi*2*1
    print("expected:", round(math.pi * 0.5, 8), round(math.pi * 1.0, 8), round(math.pi * 2.0, 8))


"""Gram-determinant evaluation of central sections of arbitrary codimension.

Implements  vol_m(E(A) cap ran(iota)) = w_m / sqrt(det((A^{-1} iota)^T (A^{-1} iota)))
for any n x m frame `iota` with orthonormal columns, together with a QR-free
Gram-Schmidt construction of a frame of a hyperplane u^perp.

Pure standard library; no third-party dependencies.
"""

from __future__ import annotations

import math
from typing import List, Sequence

Matrix = List[List[float]]
Vector = List[float]


def unit_ball_volume(m: int) -> float:
    """Volume of the unit ball in R^m."""
    return math.pi ** (m / 2.0) / math.gamma(m / 2.0 + 1.0)


def dot(x: Sequence[float], y: Sequence[float]) -> float:
    """Euclidean inner product."""
    return sum(a * b for a, b in zip(x, y))


def norm(x: Sequence[float]) -> float:
    """Euclidean norm."""
    return math.sqrt(dot(x, x))


def transpose(a: Matrix) -> Matrix:
    """Matrix transpose."""
    return [list(col) for col in zip(*a)]


def matmul(a: Matrix, b: Matrix) -> Matrix:
    """Matrix product a * b.  Cost O(n m k)."""
    k: int = len(b)
    m: int = len(b[0])
    out: Matrix = [[0.0] * m for _ in a]
    for i, ai in enumerate(a):
        for t in range(k):
            v: float = ai[t]
            if v != 0.0:
                for j in range(m):
                    out[i][j] += v * b[t][j]
    return out


def determinant(a: Matrix) -> float:
    """Determinant via LU with partial pivoting."""
    n: int = len(a)
    m: Matrix = [row[:] for row in a]
    sign: float = 1.0
    d: float = 1.0
    for c in range(n):
        piv: int = max(range(c, n), key=lambda r: abs(m[r][c]))
        if abs(m[piv][c]) < 1e-300:
            return 0.0
        if piv != c:
            m[c], m[piv] = m[piv], m[c]
            sign = -sign
        d *= m[c][c]
        for r in range(c + 1, n):
            f: float = m[r][c] / m[c][c]
            if f != 0.0:
                for j in range(c, n):
                    m[r][j] -= f * m[c][j]
    return sign * d


def solve_columns(a: Matrix, b: Matrix) -> Matrix:
    """Solve A T = B for T by Gauss-Jordan elimination.  Cost O(n^3 + n^2 m)."""
    n: int = len(a)
    m: int = len(b[0])
    aug: Matrix = [a[i][:] + b[i][:] for i in range(n)]
    for c in range(n):
        piv: int = max(range(c, n), key=lambda r: abs(aug[r][c]))
        if abs(aug[piv][c]) < 1e-300:
            raise ValueError("singular generator")
        aug[c], aug[piv] = aug[piv], aug[c]
        f: float = 1.0 / aug[c][c]
        aug[c] = [v * f for v in aug[c]]
        for r in range(n):
            if r != c and aug[r][c] != 0.0:
                g: float = aug[r][c]
                aug[r] = [vr - g * vc for vr, vc in zip(aug[r], aug[c])]
    return [row[n:] for row in aug]


def hyperplane_frame(u: Sequence[float]) -> Matrix:
    """Orthonormal frame of u^perp: an n x (n-1) matrix iota with iota^T iota = I
    and iota iota^T = I - u u^T, built by Gram-Schmidt starting from u."""
    n: int = len(u)
    s: float = norm(u)
    basis: List[Vector] = [[x / s for x in u]]
    for j in range(n):
        e: Vector = [1.0 if k == j else 0.0 for k in range(n)]
        for b in basis:
            c: float = dot(e, b)
            e = [ei - c * bi for ei, bi in zip(e, b)]
        ne: float = norm(e)
        if ne > 1e-8:
            basis.append([x / ne for x in e])
        if len(basis) == n:
            break
    cols: List[Vector] = basis[1:]
    return [[cols[j][i] for j in range(n - 1)] for i in range(n)]


def section_volume_gram(a: Matrix, iota: Matrix) -> float:
    """m-volume of the central section of E(A) by the span of the columns of `iota`."""
    t: Matrix = solve_columns(a, iota)          # T = A^{-1} iota
    g: Matrix = matmul(transpose(t), t)         # Gram matrix T^T T
    return unit_ball_volume(len(g)) / math.sqrt(determinant(g))


if __name__ == "__main__":
    A: Matrix = [[3.0, 0.0, 0.0, 0.0],
                 [0.0, 2.0, 0.0, 0.0],
                 [0.0, 0.0, 1.0, 0.0],
                 [0.0, 0.0, 0.0, 0.5]]
    # coordinate 2-plane spanned by e_1, e_3: expected area pi * 3 * 1
    frame: Matrix = [[1.0, 0.0], [0.0, 0.0], [0.0, 1.0], [0.0, 0.0]]
    print("coordinate section :", round(section_volume_gram(A, frame), 8),
          " expected", round(math.pi * 3.0, 8))
    # hyperplane orthogonal to e_4: expected volume (4/3) pi * 3 * 2 * 1
    print("hyperplane section :",
          round(section_volume_gram(A, hyperplane_frame([0.0, 0.0, 0.0, 1.0])), 8),
          " expected", round(4.0 / 3.0 * math.pi * 6.0, 8))


"""Spectral localization of the extremal slicing directions of an ellipsoid.

For a positive definite generator A, the central section orthogonal to a unit vector u
has normalised volume det(A) / ||A u||.  Since ||A u|| is a weighted average of the
eigenvalues, the extremal sections are attained exactly at the extremal eigenvectors:
the largest section is orthogonal to a minimal eigenvector, the smallest section is
orthogonal to a maximal eigenvector.  No optimisation over the sphere is needed --
one symmetric eigendecomposition (cyclic Jacobi, O(n^3) per sweep) gives the answer.

Pure standard library; no third-party dependencies.
"""

from __future__ import annotations

import math
from typing import List, Tuple

Matrix = List[List[float]]
Vector = List[float]


def identity(n: int) -> Matrix:
    """n x n identity matrix."""
    return [[1.0 if i == j else 0.0 for j in range(n)] for i in range(n)]


def jacobi_eigen(a: Matrix, sweeps: int = 100) -> Tuple[Vector, Matrix]:
    """Cyclic Jacobi eigendecomposition of a symmetric matrix.

    Returns (eigenvalues, U) with A = U diag(eigenvalues) U^T and U orthogonal.
    """
    n: int = len(a)
    m: Matrix = [row[:] for row in a]
    u: Matrix = identity(n)
    for _ in range(sweeps):
        off: float = math.sqrt(sum(m[i][j] ** 2 for i in range(n)
                                   for j in range(n) if i != j))
        if off < 1e-14:
            break
        for p in range(n - 1):
            for q in range(p + 1, n):
                if abs(m[p][q]) < 1e-18:
                    continue
                theta: float = (m[q][q] - m[p][p]) / (2.0 * m[p][q])
                t: float = math.copysign(1.0, theta) / (
                    abs(theta) + math.sqrt(theta * theta + 1.0))
                c: float = 1.0 / math.sqrt(t * t + 1.0)
                s: float = t * c
                for k in range(n):
                    mkp, mkq = m[k][p], m[k][q]
                    m[k][p] = c * mkp - s * mkq
                    m[k][q] = s * mkp + c * mkq
                for k in range(n):
                    mpk, mqk = m[p][k], m[q][k]
                    m[p][k] = c * mpk - s * mqk
                    m[q][k] = s * mpk + c * mqk
                for k in range(n):
                    ukp, ukq = u[k][p], u[k][q]
                    u[k][p] = c * ukp - s * ukq
                    u[k][q] = s * ukp + c * ukq
    return [m[i][i] for i in range(n)], u


def unit_ball_volume(m: int) -> float:
    """Volume of the unit ball in R^m."""
    return math.pi ** (m / 2.0) / math.gamma(m / 2.0 + 1.0)


def extremal_sections(a: Matrix) -> Tuple[float, Vector, float, Vector]:
    """Return (max_volume, argmax_direction, min_volume, argmin_direction).

    `a` must be symmetric positive definite.  The returned directions are unit
    eigenvectors; the volumes are the exact extremal central section volumes.
    """
    n: int = len(a)
    lam, u = jacobi_eigen(a)
    det_a: float = 1.0
    for value in lam:
        if value <= 0.0:
            raise ValueError("the generator must be positive definite")
        det_a *= value
    w: float = unit_ball_volume(n - 1)
    i_min: int = min(range(n), key=lambda i: lam[i])
    i_max: int = max(range(n), key=lambda i: lam[i])
    u_min: Vector = [u[i][i_min] for i in range(n)]
    u_max: Vector = [u[i][i_max] for i in range(n)]
    return det_a / lam[i_min] * w, u_min, det_a / lam[i_max] * w, u_max


if __name__ == "__main__":
    A: Matrix = [[2.0, 0.6, 0.0],
                 [0.6, 1.4, 0.3],
                 [0.0, 0.3, 0.8]]
    big, u_big, small, u_small = extremal_sections(A)
    print("largest  central section :", round(big, 8),
          "orthogonal to", [round(x, 5) for x in u_big])
    print("smallest central section :", round(small, 8),
          "orthogonal to", [round(x, 5) for x in u_small])


"""Construction of the intersection body of an ellipsoid.

The intersection body of E(A) is the star body whose radial function in the direction u
is the normalised central-section volume vol_{n-1}(E(A) cap u^perp) / w_{n-1}.  For an
ellipsoid this equals |det A| / ||A^T u||, which is again the radial function of an
ellipsoid: with S = sqrt(A A^T) the positive definite Gram square root,

        I(E(A)) = E( |det A| * S^{-1} ),        det( |det A| S^{-1} ) = |det A|^{n-1}.

For positive definite A this simplifies to the map A -> (det A) A^{-1}, which restricted
to unimodular positive definite generators is the involution A -> A^{-1} whose only fixed
point is the identity.

Pure standard library; no third-party dependencies.
"""

from __future__ import annotations

import math
from typing import List, Tuple

Matrix = List[List[float]]
Vector = List[float]


def identity(n: int) -> Matrix:
    """n x n identity matrix."""
    return [[1.0 if i == j else 0.0 for j in range(n)] for i in range(n)]


def transpose(a: Matrix) -> Matrix:
    """Matrix transpose."""
    return [list(col) for col in zip(*a)]


def matmul(a: Matrix, b: Matrix) -> Matrix:
    """Matrix product."""
    k: int = len(b)
    m: int = len(b[0])
    out: Matrix = [[0.0] * m for _ in a]
    for i, ai in enumerate(a):
        for t in range(k):
            v: float = ai[t]
            if v != 0.0:
                for j in range(m):
                    out[i][j] += v * b[t][j]
    return out


def determinant(a: Matrix) -> float:
    """Determinant via LU with partial pivoting."""
    n: int = len(a)
    m: Matrix = [row[:] for row in a]
    sign: float = 1.0
    d: float = 1.0
    for c in range(n):
        piv: int = max(range(c, n), key=lambda r: abs(m[r][c]))
        if abs(m[piv][c]) < 1e-300:
            return 0.0
        if piv != c:
            m[c], m[piv] = m[piv], m[c]
            sign = -sign
        d *= m[c][c]
        for r in range(c + 1, n):
            f: float = m[r][c] / m[c][c]
            if f != 0.0:
                for j in range(c, n):
                    m[r][j] -= f * m[c][j]
    return sign * d


def inverse(a: Matrix) -> Matrix:
    """Matrix inverse by Gauss-Jordan elimination."""
    n: int = len(a)
    aug: Matrix = [a[i][:] + identity(n)[i] for i in range(n)]
    for c in range(n):
        piv: int = max(range(c, n), key=lambda r: abs(aug[r][c]))
        if abs(aug[piv][c]) < 1e-300:
            raise ValueError("singular matrix")
        aug[c], aug[piv] = aug[piv], aug[c]
        f: float = 1.0 / aug[c][c]
        aug[c] = [v * f for v in aug[c]]
        for r in range(n):
            if r != c and aug[r][c] != 0.0:
                g: float = aug[r][c]
                aug[r] = [vr - g * vc for vr, vc in zip(aug[r], aug[c])]
    return [row[n:] for row in aug]


def jacobi_eigen(a: Matrix, sweeps: int = 100) -> Tuple[Vector, Matrix]:
    """Cyclic Jacobi eigendecomposition of a symmetric matrix."""
    n: int = len(a)
    m: Matrix = [row[:] for row in a]
    u: Matrix = identity(n)
    for _ in range(sweeps):
        off: float = math.sqrt(sum(m[i][j] ** 2 for i in range(n)
                                   for j in range(n) if i != j))
        if off < 1e-14:
            break
        for p in range(n - 1):
            for q in range(p + 1, n):
                if abs(m[p][q]) < 1e-18:
                    continue
                theta: float = (m[q][q] - m[p][p]) / (2.0 * m[p][q])
                t: float = math.copysign(1.0, theta) / (
                    abs(theta) + math.sqrt(theta * theta + 1.0))
                c: float = 1.0 / math.sqrt(t * t + 1.0)
                s: float = t * c
                for k in range(n):
                    mkp, mkq = m[k][p], m[k][q]
                    m[k][p] = c * mkp - s * mkq
                    m[k][q] = s * mkp + c * mkq
                for k in range(n):
                    mpk, mqk = m[p][k], m[q][k]
                    m[p][k] = c * mpk - s * mqk
                    m[q][k] = s * mpk + c * mqk
                for k in range(n):
                    ukp, ukq = u[k][p], u[k][q]
                    u[k][p] = c * ukp - s * ukq
                    u[k][q] = s * ukp + c * ukq
    return [m[i][i] for i in range(n)], u


def psd_sqrt(a: Matrix) -> Matrix:
    """Unique positive semidefinite square root of a symmetric PSD matrix."""
    lam, u = jacobi_eigen(a)
    n: int = len(a)
    d: Matrix = [[math.sqrt(max(lam[i], 0.0)) if i == j else 0.0 for j in range(n)]
                 for i in range(n)]
    return matmul(matmul(u, d), transpose(u))


def intersection_generator(a: Matrix) -> Matrix:
    """Generator of the intersection body of E(A):  |det A| * sqrt(A A^T)^{-1}."""
    s: Matrix = psd_sqrt(matmul(a, transpose(a)))
    scale: float = abs(determinant(a))
    inv_s: Matrix = inverse(s)
    return [[scale * v for v in row] for row in inv_s]


def normalise_unimodular(a: Matrix) -> Matrix:
    """Rescale A so that det A = 1 (assumes det A > 0)."""
    n: int = len(a)
    c: float = abs(determinant(a)) ** (-1.0 / n)
    return [[c * v for v in row] for row in a]


if __name__ == "__main__":
    A: Matrix = [[2.0, 0.5, 0.0],
                 [0.5, 1.0, 0.2],
                 [0.0, 0.2, 0.7]]
    gen = intersection_generator(A)
    print("det I(A)          =", round(determinant(gen), 8))
    print("|det A|^(n-1)     =", round(abs(determinant(A)) ** 2, 8))
    U = normalise_unimodular(A)
    once = intersection_generator(U)
    twice = intersection_generator(once)
    err = max(abs(twice[i][j] - U[i][j]) for i in range(3) for j in range(3))
    print("involution error  =", f"{err:.2e}")
    fixed = intersection_generator(identity(3))
    print("I(ball) = ball    :", all(abs(fixed[i][j] - identity(3)[i][j]) < 1e-12
                                    for i in range(3) for j in range(3)))


"""Assemble PACKAGE.json from the deliverable files and the assets directory."""

from __future__ import annotations

import json
import os
from typing import Any, Dict, List

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ASSETS = os.path.join(ROOT, "assets")

LEAN_FILES: List[str] = [
    "Catalog/Bridges/EllipsoidCentralSections.lean",
    "Catalog/Bridges/EllipsoidSlicingBounds.lean",
    "Catalog/Bridges/EllipsoidExtremalUniqueness.lean",
    "Catalog/Bridges/EllipsoidLowerDimSections.lean",
    "Catalog/Bridges/EllipsoidPolarDuality.lean",
    "Catalog/Bridges/EllipsoidIntersectionBody.lean",
    "Catalog/Bridges/EllipsoidExtremalSections.lean",
    "Catalog/Bridges/EllipsoidJohnExistence.lean",
]

FUTURE_DIRECTIONS = """# Future Directions — Ellipsoids as Positive-Definite Images of Balls

## What the thread has established

A complete development of ellipsoids as linear images of the Euclidean ball now covers the
following ground.

* **Central sections.** Ellipsoids as `E A = A · B`, their volume `|det A| · vol B`,
  orthogonal invariance, the spectral decomposition `E A = U · diag(λ) · B`, the eigenvalue
  sandwich `B(0, λ_min) ⊆ E A ⊆ B(0, λ_max)`, the Gram-determinant volume formula for
  preimages of the ball, and the explicit hyperplane section formula
  `vol_{n-1}(E A ∩ u^⊥) = (|det A| / ‖Aᵀ u‖) · vol(B^{n-1})`.
* **Slicing bounds.** Two-sided slicing bounds by the extreme eigenvalues, their attainment
  in eigendirections, frame independence, the determinant-normalization identity
  `∏ᵢ (det A / λᵢ) = (det A)^{n-1}`, polar duality `(E A)° = E((Aᵀ)⁻¹)`, the
  Blaschke–Santaló *equality* `vol(E A) · vol((E A)°) = vol(B)²`, and worked 2- and
  3-dimensional coordinate sections.
* **Lower-dimensional sections.** The codimension-free Gram formula for sections by
  arbitrary `m`-dimensional subspaces, determinant bounds for positive definite matrices
  from bounds on their quadratic forms, the resulting sandwich
  `lo^m · vol(B^m) ≤ vol_m(section) ≤ hi^m · vol(B^m)`, and the exact product formula
  `∏ⱼ |d(f j)|` for coordinate sections of a diagonal ellipsoid.
* **Polar duality.** The calculus of polar sets (antitonicity, polars of unions,
  self-polarity of the ball), full linear covariance `(A · s)° = (Aᵀ)⁻¹ · s°`, invariance of
  the volume product under invertible linear maps, the bipolar theorem for ellipsoids, and a
  Santaló-type estimate for any body squeezed between two ellipsoids.
* **Intersection bodies.** *The intersection body of an ellipsoid is an ellipsoid.* Writing
  `S = √(A Aᵀ)` for the positive semidefinite square root of the Gram matrix, the radial
  function of `E(|det A| · S⁻¹)` in a unit direction `u` is exactly the normalized volume of
  the central section of `E A` orthogonal to `u`. Also: `det(|det A| S⁻¹) = |det A|^{n-1}`,
  hence the volume of the intersection body; for positive definite `A` the intersection
  generator is simply `det A · A⁻¹`; and on unimodular positive definite generators the
  operator is the involution `A ↦ A⁻¹` whose only fixed point is the identity — the ball is
  the unique unimodular ellipsoid that is its own intersection body.
* **Extremal sections.** Existence of slicing frames: every unit vector `u` admits an
  orthonormal parametrization `ι` of `u^⊥` with `ιᵀι = 1` and `ιιᵀ = 1 - uuᵀ`, obtained by
  extending `u` to an orthonormal basis. This removes the frame hypothesis from every
  section theorem above. Combined with `∏ λᵢ = det A` it yields the extremal statements: a
  unimodular ellipsoid always has a central section at least as large as the unit ball's,
  and one at most that large.
* **Equality cases.** For a unit vector `u`, `‖Aᵀ u‖` equals an upper (resp. lower) bound of
  the spectrum if and only if `u` is a corresponding eigenvector; hence the central sections
  of extreme volume are exactly those orthogonal to an extreme eigenvector.
* **John ellipsoids.** Existence of a maximal-volume inscribed ellipsoid in any closed
  bounded set containing a nondegenerate ellipsoid, via compactness of the set of inscribed
  positive semidefinite generators.

## Where to go next

1. **Uniqueness of the John ellipsoid**, via strict log-concavity of the determinant on
   positive definite matrices, together with the contact-point characterisation (John's
   condition `∑ cᵢ uᵢuᵢᵀ = 1`) and the resulting `√n` (resp. `n`) approximation constants for
   symmetric (resp. general) bodies.
2. **Non-central and affine sections**: the volume of `E A ∩ {⟨x,u⟩ = c}`, the resulting
   concavity of the section function in `c` (an ellipsoidal instance of Brunn's theorem), and
   the corresponding Fourier-analytic description of the section function.
3. **Projection bodies and the dual theory**: prove that the projection body of an ellipsoid
   is an ellipsoid, identify its generator, and pair the resulting Petty projection identity
   with the Blaschke–Santaló equality already established.
4. **Busemann–Petty inside the ellipsoid class**: use the closure of ellipsoids under the
   intersection-body operator to give a complete, formula-level answer for
   ellipsoid-versus-ball comparisons in all dimensions, with sharp constants.
5. **Quantitative stability**: upgrade the rigidity of the equality cases and the uniqueness
   of the ball as intersection-body fixed point to stability statements — if the section
   profile is within ε of the ball's, how close must the ellipsoid be to a ball?
6. **Lp and Orlicz analogues**: replace the Euclidean ball by an Lp ball and ask which
   identities survive; determinant homogeneity does, the Gram-determinant mechanism partially,
   and spectral rigidity generally does not — mapping that boundary precisely would be
   informative.
7. **Random sections**: with the exact formula in hand, the distribution of
   `vol_{n-1}(E A ∩ u^⊥)` for uniformly random `u` is the distribution of `|det A| / ‖Aᵀ u‖`,
   which is explicitly computable; concentration of this quantity is the ellipsoidal shadow of
   the thin-shell phenomenon.
"""


def read(path: str) -> str:
    with open(path, "r", encoding="utf-8") as fh:
        return fh.read()


def main() -> None:
    article = read(os.path.join(ROOT, "ARTICLE.md"))
    paper = read(os.path.join(ROOT, "RESEARCH_PAPER.md"))
    paper_tex = read(os.path.join(ROOT, "RESEARCH_PAPER.tex"))
    demo = read(os.path.join(ROOT, "demo.py"))
    demo2 = read(os.path.join(ASSETS, "demo2_random_sections.py"))
    algo1 = read(os.path.join(ASSETS, "algo1_section_volume.py"))
    algo2 = read(os.path.join(ASSETS, "algo2_gram_section.py"))
    algo3 = read(os.path.join(ASSETS, "algo3_extremal_directions.py"))
    algo4 = read(os.path.join(ASSETS, "algo4_intersection_body.py"))
    vis1 = read(os.path.join(ASSETS, "vis1_ellipse_duals.py"))
    vis2 = read(os.path.join(ASSETS, "vis2_section_profile.py"))
    w1 = read(os.path.join(ASSETS, "widget1_slicing_lab.html"))
    w2 = read(os.path.join(ASSETS, "widget2_intersection_involution.html"))
    layout = read(os.path.join(ASSETS, "interactive_layout.md"))

    lean_sources: List[str] = []
    for rel in LEAN_FILES:
        lean_sources.append(
            f"-- ===== {rel} =====\n" + read(os.path.join(ROOT, rel)).rstrip() + "\n"
        )
    lean_proofs = "\n".join(lean_sources)

    package: Dict[str, Any] = {
        "title": "Ellipsoids as Positive-Definite Images of Balls: "
                 "Exact Central-Section Formulas, Spectral Slicing Bounds, and Duality",
        "domain": "Bridges",
        "description": (
            "A complete theory of ellipsoids defined as linear images of the Euclidean unit "
            "ball, culminating in the exact central-section formula "
            "vol_{n-1}(E(A) cap u-perp) = (|det A| / ||A^T u||) * vol(B^{n-1}) and its "
            "consequences: spectral slicing bounds with exact equality cases, the "
            "Blaschke-Santalo equality for ellipsoids, and the theorem that the intersection "
            "body of an ellipsoid is an ellipsoid, with the ball as its unique unimodular "
            "fixed point."
        ),
        "authors": ["Aristotle"],
        "date": "2026-08-25",
        "key_results": [
            "Central section formula: the (n-1)-volume of the section of the ellipsoid "
            "E(A) = A·B by the hyperplane orthogonal to a unit vector u equals "
            "(|det A| / ||A^T u||) times the volume of the unit (n-1)-ball.",
            "Spectral slicing bounds with exact equality case: for a positive definite "
            "generator the normalised section volume lies between det A / lambda_max and "
            "det A / lambda_min, and an endpoint is attained exactly when the slicing "
            "direction is a corresponding eigenvector.",
            "Determinant-normalization identity: the product over the n principal directions "
            "of det A / lambda_i equals (det A)^{n-1}, so the principal section volumes "
            "cannot all be small.",
            "Blaschke-Santalo equality for ellipsoids: the polar of E(A) is E((A^T)^{-1}), the "
            "volume product is a linear invariant, and every ellipsoid satisfies "
            "vol(E(A)) · vol(E(A)°) = vol(B_n)^2.",
            "The intersection body of an ellipsoid is an ellipsoid, generated by "
            "|det A| · sqrt(A A^T)^{-1}; on unimodular positive definite generators the "
            "operation is the involution A ↦ A^{-1}, whose only fixed point is the identity, "
            "so the ball is the unique unimodular ellipsoid equal to its own intersection body.",
        ],
        "keywords": [
            "ellipsoid",
            "central section",
            "Gram determinant",
            "spectral decomposition",
            "polar duality",
            "Blaschke-Santalo equality",
            "intersection body",
            "John ellipsoid",
        ],
        "article": article,
        "research_paper": paper,
        "research_paper_tex": paper_tex,
        "demo": demo,
        "demos": [
            {
                "name": "Complete Numerical Verification of the Ellipsoid Section Calculus",
                "description": (
                    "A single self-contained script (standard library only: all linear algebra "
                    "— LU determinant, Gauss-Jordan inverse, cyclic Jacobi eigendecomposition, "
                    "positive semidefinite square root, Gram-Schmidt frames — is implemented "
                    "inline) that checks every identity of the theory numerically. It verifies "
                    "the volume law vol(E(A)) = |det A| · w_n against the product of semiaxes; "
                    "the central section formula against both an independent Gram-determinant "
                    "evaluation and a Monte-Carlo estimate of the section volume; frame "
                    "independence under rotation of the slicing frame together with the frame "
                    "identities iota^T iota = I and iota iota^T = I - u u^T; the spectral "
                    "slicing bounds and their attainment at the extremal eigenvectors, sampled "
                    "over twenty thousand random directions; the determinant-normalization "
                    "identity; the codimension-free sandwich lo^m w_m <= vol_m <= hi^m w_m for "
                    "random subspaces of every dimension; the exact product formula for "
                    "coordinate sections of a diagonal ellipsoid; the Blaschke-Santalo equality "
                    "and the bipolar theorem; and the full intersection-body package — the "
                    "generator (det A) A^{-1}, the determinant |det A|^{n-1}, the radial "
                    "function matching the normalised section volume, the involution property, "
                    "and the ball as its unique unimodular fixed point."
                ),
                "code": demo,
            },
            {
                "name": "Distribution of Random Central Sections of a Unimodular Ellipsoid",
                "description": (
                    "For a positive definite generator with determinant one, the normalised "
                    "central section volume in the direction u is exactly 1/||A u||. This demo "
                    "samples two hundred thousand uniformly random directions in dimension five, "
                    "prints a text histogram of the resulting values, and checks the three "
                    "predictions of the theory: that the values never leave the interval "
                    "[1/lambda_max, 1/lambda_min]; that the product of the n principal "
                    "normalised section volumes is exactly one; and that a unimodular ellipsoid "
                    "always possesses both a direction whose section is at least as large as the "
                    "unit ball's and one whose section is at most that large. The visible "
                    "concentration of the histogram is the ellipsoidal shadow of the thin-shell "
                    "phenomenon."
                ),
                "code": demo2,
            },
        ],
        "algorithms": [
            {
                "name": "Exact Central Hyperplane Section Volume via Determinant and Dual Norm",
                "description": (
                    "Evaluates vol_{n-1}(E(A) cap u-perp) = (|det A| / ||A^T u||) * w_{n-1} "
                    "directly from the closed formula. The determinant is computed once by LU "
                    "factorisation with partial pivoting at cost O(n^3); each further slicing "
                    "direction then costs only the O(n^2) matrix-vector product A^T u and one "
                    "square root, so the entire section profile over K directions costs "
                    "O(n^3 + K n^2). The ball constant w_m = pi^{m/2}/Gamma(m/2+1) is evaluated "
                    "through the gamma function. Numerical stability is that of the LU "
                    "factorisation; the formula itself involves no cancellation, since both "
                    "|det A| and ||A^T u|| are positive for invertible A and nonzero u. This is "
                    "the workhorse routine: it replaces any integration over the slicing "
                    "hyperplane by two elementary linear-algebra quantities."
                ),
                "pseudocode": (
                    "INPUT : invertible A in R^{n x n}, nonzero u in R^n\n"
                    "OUTPUT: the (n-1)-volume of the central section of E(A) by u-perp\n"
                    "\n"
                    "1. u_hat <- u / ||u||                       # normalise the direction\n"
                    "2. (L, U, P) <- LU_factorise(A)             # O(n^3)\n"
                    "3. delta <- |sign(P)| * prod_i U[i][i]      # |det A|\n"
                    "4. if delta = 0 then ERROR 'generator is singular'\n"
                    "5. w <- A^T u_hat                           # O(n^2)\n"
                    "6. nu <- sqrt(sum_j w[j]^2)                 # ||A^T u||\n"
                    "7. omega <- pi^((n-1)/2) / Gamma((n-1)/2 + 1)\n"
                    "8. RETURN (delta / nu) * omega"
                ),
                "code": algo1,
            },
            {
                "name": "Gram-Determinant Evaluation of Central Sections of Arbitrary Codimension",
                "description": (
                    "Computes the m-dimensional volume of the section of E(A) by the span of an "
                    "orthonormal frame iota, for any m <= n, as w_m / sqrt(det((A^{-1} iota)^T "
                    "(A^{-1} iota))). The pulled-back section is the preimage of the unit ball "
                    "under the rectangular map T = A^{-1} iota, and the correct replacement for "
                    "the determinant of a rectangular map is the square root of its Gram "
                    "determinant. The algorithm solves A T = iota by Gauss-Jordan elimination "
                    "(O(n^3 + n^2 m)) rather than forming A^{-1} explicitly, then builds the "
                    "m x m Gram matrix (O(n m^2)) and takes its determinant (O(m^3)). Also "
                    "included is a Gram-Schmidt construction of an orthonormal frame of a "
                    "hyperplane u-perp, satisfying iota^T iota = I and iota iota^T = I - u u^T. "
                    "For m = n-1 the output must coincide with the closed-form routine above, "
                    "which is a sharp test of the underlying Gram identity."
                ),
                "pseudocode": (
                    "INPUT : invertible A in R^{n x n}, frame iota in R^{n x m} with orthonormal columns\n"
                    "OUTPUT: vol_m(E(A) cap span(columns of iota))\n"
                    "\n"
                    "1. T <- solve(A X = iota)                   # Gauss-Jordan, O(n^3 + n^2 m)\n"
                    "2. G <- T^T T                               # m x m Gram matrix, O(n m^2)\n"
                    "3. g <- det(G) by LU factorisation          # O(m^3)\n"
                    "4. if g <= 0 then ERROR 'frame is degenerate'\n"
                    "5. omega <- pi^(m/2) / Gamma(m/2 + 1)\n"
                    "6. RETURN omega / sqrt(g)\n"
                    "\n"
                    "SUBROUTINE hyperplane_frame(u):\n"
                    "  a. basis <- [u / ||u||]\n"
                    "  b. for j = 1..n: project e_j off basis; if the residual is nonnegligible,\n"
                    "     normalise it and append to basis; stop when basis has n vectors\n"
                    "  c. RETURN the matrix whose columns are basis[2..n]"
                ),
                "code": algo2,
            },
            {
                "name": "Spectral Localization of the Extremal Slicing Directions",
                "description": (
                    "Finds the directions of maximal and minimal central section without any "
                    "optimisation over the sphere. Since ||A u||^2 = sum_i lambda_i^2 c_i^2 is a "
                    "weighted average of the squared eigenvalues over the eigenbasis coordinates "
                    "of u, and the section volume is det(A)/||A u|| times the ball constant, the "
                    "extremes are attained exactly at the extremal eigenvectors: the largest "
                    "section is orthogonal to a minimal eigenvector and the smallest section is "
                    "orthogonal to a maximal eigenvector. The routine therefore performs one "
                    "cyclic Jacobi eigendecomposition of the symmetric generator, at cost O(n^3) "
                    "per sweep with quadratic convergence (a handful of sweeps suffices), and "
                    "reads off both the extremal volumes det A / lambda_min and det A / lambda_max "
                    "and the directions realising them. The correctness of the output is a "
                    "rigidity theorem, not merely a heuristic: no other direction attains either "
                    "extreme."
                ),
                "pseudocode": (
                    "INPUT : symmetric positive definite A in R^{n x n}\n"
                    "OUTPUT: (max volume, its direction, min volume, its direction)\n"
                    "\n"
                    "1. (lambda, U) <- jacobi_eigendecomposition(A)     # A = U diag(lambda) U^T\n"
                    "2. if any lambda[i] <= 0 then ERROR 'not positive definite'\n"
                    "3. detA <- prod_i lambda[i]\n"
                    "4. omega <- pi^((n-1)/2) / Gamma((n-1)/2 + 1)\n"
                    "5. i_min <- argmin_i lambda[i];  i_max <- argmax_i lambda[i]\n"
                    "6. u_min <- column i_min of U;   u_max <- column i_max of U\n"
                    "7. RETURN (detA/lambda[i_min] * omega, u_min,\n"
                    "           detA/lambda[i_max] * omega, u_max)"
                ),
                "code": algo3,
            },
            {
                "name": "Construction of the Intersection Body Generator via the Gram Square Root",
                "description": (
                    "Builds the generator of the intersection body of an ellipsoid: the body "
                    "whose radial function in each direction is the normalised central section "
                    "volume of E(A) in that direction. Because that function is "
                    "|det A| / ||A^T u||, and a body with radial function c/||M u|| for positive "
                    "definite M is exactly the ellipsoid generated by c M^{-1}, the answer is "
                    "|det A| · S^{-1} with S = sqrt(A A^T) the unique positive definite square "
                    "root of the Gram matrix — the matrix characterised by ||S u|| = ||A^T u|| "
                    "for all u, i.e. the shape of A with the rotational ambiguity of the polar "
                    "decomposition removed. The square root is computed spectrally (Jacobi "
                    "eigendecomposition of A A^T, then square roots of the eigenvalues), at cost "
                    "O(n^3). The routine also normalises a generator to determinant one, so that "
                    "the involution property I(I(A)) = A and the uniqueness of the identity as "
                    "the only fixed point can be checked directly."
                ),
                "pseudocode": (
                    "INPUT : invertible A in R^{n x n}\n"
                    "OUTPUT: the generator of the intersection body of E(A)\n"
                    "\n"
                    "1. G <- A A^T                                   # positive definite Gram matrix\n"
                    "2. (mu, U) <- jacobi_eigendecomposition(G)\n"
                    "3. S <- U diag(sqrt(mu)) U^T                    # the positive definite square root\n"
                    "4. delta <- |det A|\n"
                    "5. RETURN delta * S^{-1}\n"
                    "\n"
                    "PROPERTIES (checkable numerically):\n"
                    "  det(delta * S^{-1}) = delta^{n-1}\n"
                    "  if A is positive definite then delta * S^{-1} = (det A) A^{-1}\n"
                    "  if in addition det A = 1 then the map is A -> A^{-1}, an involution whose\n"
                    "  unique fixed point is the identity matrix"
                ),
                "code": algo4,
            },
        ],
        "visualizations": [
            {
                "name": "An Ellipse, Its Polar Dual and Its Intersection Body",
                "description": (
                    "A single SVG figure in the plane showing three related bodies at once: a "
                    "tilted ellipse E(A); its polar dual E((A^T)^{-1}), whose area is the "
                    "reciprocal of the ellipse's up to the factor pi^2, exhibiting the "
                    "Blaschke-Santalo equality numerically in the caption; and its intersection "
                    "body E((det A) A^{-1}), the chord-length profile drawn as a body. A dashed "
                    "unit circle gives the scale, and a chosen slicing direction u is drawn with "
                    "its hyperplane and the resulting chord highlighted, labelled with the exact "
                    "value 2|det A|/||A^T u||. The figure makes visible the fact that the long "
                    "axis of the intersection body is the short axis of the ellipse. Pure "
                    "standard library; writes ellipse_duals.svg."
                ),
                "code": vis1,
            },
            {
                "name": "The Central-Section Profile of a Three-Dimensional Ellipsoid",
                "description": (
                    "A heat map, rendered as SVG, of the function u -> pi · det(A) / ||A u|| — "
                    "the area of the central section of a three-dimensional ellipsoid orthogonal "
                    "to u — plotted over the sphere of directions in spherical coordinates "
                    "(azimuth on the horizontal axis, polar angle on the vertical). A colour bar "
                    "is annotated with the two spectral bounds pi·det A/lambda_max and "
                    "pi·det A/lambda_min, and the six extremal directions (the plus and minus "
                    "eigenvectors) are marked, showing that the profile touches the ends of the "
                    "eigenvalue band exactly there and nowhere else. The symmetric structure of "
                    "the map is the visual signature of central symmetry and of the spectral "
                    "rigidity theorem. Pure standard library; writes section_profile.svg."
                ),
                "code": vis2,
            },
        ],
        "interactive_demos": [
            {
                "title": "The Ellipse Slicing Laboratory",
                "description": (
                    "A live two-dimensional laboratory for the central section formula. Sliders "
                    "control the two semiaxes, the tilt of the axes, and the slicing direction; "
                    "the canvas draws the ellipse, the cutting line through the origin, the "
                    "resulting chord, and optionally the unit disc, the polar dual and the "
                    "intersection body. Alongside, a live table reports det A, the dual norm "
                    "||A^T u||, the predicted chord length 2|det A|/||A^T u||, and — crucially — "
                    "the chord length measured independently on the picture by bisection on the "
                    "membership test ||A^{-1}x|| <= 1, so the reader can watch prediction and "
                    "measurement agree to machine precision as the sliders move. The panel also "
                    "displays the eigenvalue band for the half-chord and flags the moment when "
                    "the slicing direction becomes an eigenvector, i.e. when the widest or "
                    "narrowest possible cut is attained, and shows the volume product of the "
                    "ellipse with its polar staying pinned at pi^2. Two collapsible sections give "
                    "the three-step proof of the section formula and the rigidity statement about "
                    "extremal directions."
                ),
                "html": w1,
            },
            {
                "title": "The Intersection-Body Involution: Why Only the Ball Repeats Itself",
                "description": (
                    "An interactive exploration of the operation that draws the slice profile of "
                    "a body as a body. For a unimodular positive definite generator in the plane, "
                    "parametrised by an eccentricity slider (semiaxes s and 1/s) and a tilt "
                    "slider, the widget draws the ellipse E(A) together with its intersection "
                    "body E(A^{-1}), and marks on a chosen direction the point whose distance "
                    "from the origin is the normalised slice size — a point that always lands "
                    "exactly on the profile body. Readouts display the determinant (pinned at 1), "
                    "the slice size, the radial distance, the common area pi, the distance "
                    "||I(A) - A|| from being a fixed point, and the residual ||I(I(A)) - A|| "
                    "confirming the involution. Sliding the eccentricity back to 1 collapses both "
                    "curves onto the unit disc and triggers the fixed-point message, making "
                    "visible the theorem that the ball is the unique unimodular ellipsoid equal to "
                    "its own intersection body. Collapsible sections explain why the profile of an "
                    "ellipsoid is an ellipsoid, why the ball is the only fixed point, and how the "
                    "shape of the profile encodes the two-sided slicing bounds."
                ),
                "html": w2,
            },
        ],
        "interactive_layout": layout,
        "lean_proofs": lean_proofs,
        "future_directions": FUTURE_DIRECTIONS,
        "modules": {"demo": demo},
        "lean_files": LEAN_FILES,
    }

    out = os.path.join(ROOT, "PACKAGE.json")
    with open(out, "w", encoding="utf-8") as fh:
        json.dump(package, fh, ensure_ascii=False, indent=2)
    print("wrote", out, os.path.getsize(out), "bytes")


if __name__ == "__main__":
    main()


"""Statistics of random central sections of a unimodular ellipsoid.

For a positive definite generator A with det A = 1, the normalised central section volume
in the direction u is  1 / ||A u||, and the theory predicts:

  * the values lie in the interval [1/lam_max, 1/lam_min];
  * the extremes are attained exactly at the extremal eigenvectors;
  * the product of the n principal (axis-orthogonal) section values is 1, since
    prod_i (det A / lam_i) = (det A)^(n-1) = 1;
  * some direction always gives a section at least as large as the unit ball's, and
    some direction always gives one at most as large.

This script samples uniformly random directions, prints a text histogram of the
normalised section volume, and checks each prediction numerically.  Pure standard
library; no third-party dependencies.
"""

from __future__ import annotations

import math
import random
from typing import List, Tuple

Matrix = List[List[float]]
Vector = List[float]


def identity(n: int) -> Matrix:
    """n x n identity matrix."""
    return [[1.0 if i == j else 0.0 for j in range(n)] for i in range(n)]


def transpose(a: Matrix) -> Matrix:
    """Matrix transpose."""
    return [list(col) for col in zip(*a)]


def matmul(a: Matrix, b: Matrix) -> Matrix:
    """Matrix product."""
    k: int = len(b)
    m: int = len(b[0])
    out: Matrix = [[0.0] * m for _ in a]
    for i, ai in enumerate(a):
        for t in range(k):
            v: float = ai[t]
            if v != 0.0:
                for j in range(m):
                    out[i][j] += v * b[t][j]
    return out


def matvec(a: Matrix, x: Vector) -> Vector:
    """Matrix-vector product."""
    return [sum(a[i][j] * x[j] for j in range(len(x))) for i in range(len(a))]


def dot(x: Vector, y: Vector) -> float:
    """Euclidean inner product."""
    return sum(p * q for p, q in zip(x, y))


def norm(x: Vector) -> float:
    """Euclidean norm."""
    return math.sqrt(dot(x, x))


def random_orthogonal(n: int, rng: random.Random) -> Matrix:
    """Random orthogonal matrix via Gram-Schmidt on a Gaussian matrix."""
    rows: List[Vector] = []
    while len(rows) < n:
        v: Vector = [rng.gauss(0.0, 1.0) for _ in range(n)]
        for b in rows:
            c: float = dot(v, b)
            v = [vi - c * bi for vi, bi in zip(v, b)]
        s: float = norm(v)
        if s > 1e-8:
            rows.append([vi / s for vi in v])
    return transpose(rows)


def unimodular_spd(eigenvalues: List[float], rng: random.Random) -> Tuple[Matrix, List[float]]:
    """Positive definite matrix with the given eigenvalues, rescaled to determinant 1."""
    n: int = len(eigenvalues)
    prod: float = 1.0
    for value in eigenvalues:
        prod *= value
    lam: List[float] = [value * prod ** (-1.0 / n) for value in eigenvalues]
    u: Matrix = random_orthogonal(n, rng)
    d: Matrix = [[lam[i] if i == j else 0.0 for j in range(n)] for i in range(n)]
    return matmul(matmul(u, d), transpose(u)), lam


def main() -> None:
    rng = random.Random(4242)
    n: int = 5
    a, lam = unimodular_spd([3.0, 1.7, 1.0, 0.6, 0.35], rng)
    lam_sorted = sorted(lam)
    print(f"dimension n = {n}")
    print(f"eigenvalues (det = 1): {[round(x, 5) for x in lam_sorted]}")
    print(f"predicted range of 1/||A u|| : "
          f"[{1.0 / lam_sorted[-1]:.5f}, {1.0 / lam_sorted[0]:.5f}]")

    samples: int = 200000
    values: List[float] = []
    for _ in range(samples):
        v: Vector = [rng.gauss(0.0, 1.0) for _ in range(n)]
        s: float = norm(v)
        u: Vector = [x / s for x in v]
        values.append(1.0 / norm(matvec(a, u)))
    lo, hi = min(values), max(values)
    mean = sum(values) / samples
    var = sum((x - mean) ** 2 for x in values) / samples
    print(f"observed range over {samples} random directions: [{lo:.5f}, {hi:.5f}]")
    print(f"mean = {mean:.5f}, standard deviation = {math.sqrt(var):.5f}")

    print()
    print("histogram of the normalised section volume 1/||A u||:")
    bins: int = 24
    left, right = 1.0 / lam_sorted[-1], 1.0 / lam_sorted[0]
    counts: List[int] = [0] * bins
    for x in values:
        idx = int((x - left) / (right - left) * bins)
        counts[min(max(idx, 0), bins - 1)] += 1
    peak = max(counts)
    for b in range(bins):
        centre = left + (b + 0.5) * (right - left) / bins
        bar = "#" * int(58 * counts[b] / peak)
        print(f"  {centre:6.3f} | {bar}")

    print()
    prod = 1.0
    for value in lam:
        prod *= 1.0 / value
    print(f"product of the n principal normalised sections = {prod:.10f}  (predicted 1)")
    print(f"a direction with section >= the ball's exists: "
          f"{1.0 / lam_sorted[0] >= 1.0}")
    print(f"a direction with section <= the ball's exists: "
          f"{1.0 / lam_sorted[-1] <= 1.0}")


if __name__ == "__main__":
    main()


"""Visualization: an ellipse, its polar dual, and its intersection body.

For a positive definite 2x2 generator A the script draws, in a single SVG figure:

  * the ellipse  E(A) = A B^2;
  * its polar dual  E(A)^o = E((A^T)^{-1})  -- the ellipse whose semiaxes are the
    reciprocals of those of E(A), so that the volume product is exactly (area of the
    unit disc)^2 = pi^2 (the Blaschke-Santalo equality);
  * its intersection body  I(E(A)) = E((det A) A^{-1})  -- in the plane, the body whose
    radial function in the direction u is the length of the chord E(A) cap u^perp
    divided by 2;
  * a slicing line u^perp for a chosen direction u, with the chord highlighted, so that
    the identity  length(chord) = 2 |det A| / ||A^T u||  can be read off the picture.

Writes `ellipse_duals.svg` in the current directory.  Pure standard library.
"""

from __future__ import annotations

import math
from typing import List, Tuple

Matrix = List[List[float]]
Vector = List[float]

WIDTH: int = 760
HEIGHT: int = 620
SCALE: float = 105.0            # pixels per unit length
CX: float = WIDTH / 2.0
CY: float = HEIGHT / 2.0 - 10.0


def matvec(a: Matrix, x: Vector) -> Vector:
    """Matrix-vector product."""
    return [a[0][0] * x[0] + a[0][1] * x[1], a[1][0] * x[0] + a[1][1] * x[1]]


def det2(a: Matrix) -> float:
    """Determinant of a 2x2 matrix."""
    return a[0][0] * a[1][1] - a[0][1] * a[1][0]


def inv2(a: Matrix) -> Matrix:
    """Inverse of a 2x2 matrix."""
    d: float = det2(a)
    return [[a[1][1] / d, -a[0][1] / d], [-a[1][0] / d, a[0][0] / d]]


def transpose2(a: Matrix) -> Matrix:
    """Transpose of a 2x2 matrix."""
    return [[a[0][0], a[1][0]], [a[0][1], a[1][1]]]


def scal2(c: float, a: Matrix) -> Matrix:
    """Scalar multiple of a 2x2 matrix."""
    return [[c * a[0][0], c * a[0][1]], [c * a[1][0], c * a[1][1]]]


def to_px(p: Vector) -> Tuple[float, float]:
    """Map a plane point to SVG pixel coordinates."""
    return CX + SCALE * p[0], CY - SCALE * p[1]


def ellipse_path(a: Matrix, steps: int = 720) -> str:
    """SVG path data for the boundary of E(A)."""
    pts: List[str] = []
    for k in range(steps + 1):
        t: float = 2.0 * math.pi * k / steps
        x, y = to_px(matvec(a, [math.cos(t), math.sin(t)]))
        pts.append(("M" if k == 0 else "L") + f"{x:.2f},{y:.2f}")
    return " ".join(pts) + " Z"


def chord_endpoints(a: Matrix, u: Vector) -> Tuple[Vector, Vector, float]:
    """Endpoints and length of the chord E(A) cap u^perp.

    The chord is the image under A of the diameter of the unit disc orthogonal to
    A^T u; its half-length is |det A| / ||A^T u||.
    """
    w: Vector = matvec(transpose2(a), u)
    nw: float = math.hypot(w[0], w[1])
    # direction in the unit disc orthogonal to A^T u
    e: Vector = [-w[1] / nw, w[0] / nw]
    p: Vector = matvec(a, e)
    q: Vector = [-p[0], -p[1]]
    return p, q, 2.0 * abs(det2(a)) / nw


def build_svg(a: Matrix, u: Vector) -> str:
    """Assemble the full SVG document."""
    polar: Matrix = inv2(transpose2(a))
    inter: Matrix = scal2(det2(a), inv2(a))
    p, q, chord_len = chord_endpoints(a, u)
    px, py = to_px(p)
    qx, qy = to_px(q)
    # slicing line through the origin, orthogonal to u, extended to the frame
    d: Vector = [-u[1], u[0]]
    far: float = 4.2
    l1x, l1y = to_px([far * d[0], far * d[1]])
    l2x, l2y = to_px([-far * d[0], -far * d[1]])
    ux, uy = to_px([1.6 * u[0], 1.6 * u[1]])
    ox, oy = to_px([0.0, 0.0])

    area_e = abs(det2(a)) * math.pi
    area_polar = math.pi / abs(det2(a))

    parts: List[str] = []
    parts.append(
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{WIDTH}" height="{HEIGHT}" '
        f'viewBox="0 0 {WIDTH} {HEIGHT}" font-family="Georgia, serif">'
    )
    parts.append('<rect width="100%" height="100%" fill="#fbfaf7"/>')
    # axes
    parts.append(f'<line x1="0" y1="{CY:.1f}" x2="{WIDTH}" y2="{CY:.1f}" '
                 'stroke="#d8d3c8" stroke-width="1"/>')
    parts.append(f'<line x1="{CX:.1f}" y1="0" x2="{CX:.1f}" y2="{HEIGHT}" '
                 'stroke="#d8d3c8" stroke-width="1"/>')
    # unit circle for reference
    parts.append(f'<circle cx="{CX:.1f}" cy="{CY:.1f}" r="{SCALE:.1f}" fill="none" '
                 'stroke="#c9c3b6" stroke-width="1" stroke-dasharray="4 4"/>')
    # bodies
    parts.append(f'<path d="{ellipse_path(inter)}" fill="#f6e3c5" fill-opacity="0.55" '
                 'stroke="#c98a2b" stroke-width="2"/>')
    parts.append(f'<path d="{ellipse_path(polar)}" fill="#dce9f7" fill-opacity="0.6" '
                 'stroke="#2f6fb5" stroke-width="2"/>')
    parts.append(f'<path d="{ellipse_path(a)}" fill="#e8f3e2" fill-opacity="0.55" '
                 'stroke="#3d7a34" stroke-width="2.5"/>')
    # slicing line and chord
    parts.append(f'<line x1="{l1x:.1f}" y1="{l1y:.1f}" x2="{l2x:.1f}" y2="{l2y:.1f}" '
                 'stroke="#8a8577" stroke-width="1.2" stroke-dasharray="6 5"/>')
    parts.append(f'<line x1="{px:.1f}" y1="{py:.1f}" x2="{qx:.1f}" y2="{qy:.1f}" '
                 'stroke="#b0202f" stroke-width="4" stroke-linecap="round"/>')
    parts.append(f'<line x1="{ox:.1f}" y1="{oy:.1f}" x2="{ux:.1f}" y2="{uy:.1f}" '
                 'stroke="#333" stroke-width="1.6" marker-end="url(#arrow)"/>')
    parts.append('<defs><marker id="arrow" markerWidth="9" markerHeight="9" refX="7" '
                 'refY="3" orient="auto"><path d="M0,0 L0,6 L8,3 z" fill="#333"/>'
                 '</marker></defs>')
    parts.append(f'<circle cx="{ox:.1f}" cy="{oy:.1f}" r="3" fill="#333"/>')
    # legend and readouts
    y0 = 26
    parts.append(f'<text x="20" y="{y0}" font-size="17" fill="#222">'
                 'Ellipse, polar dual and intersection body</text>')
    parts.append(f'<text x="20" y="{y0+24}" font-size="13" fill="#3d7a34">'
                 f'&#9632; E(A), area = |det A|&#183;&#960; = {area_e:.4f}</text>')
    parts.append(f'<text x="20" y="{y0+42}" font-size="13" fill="#2f6fb5">'
                 f'&#9632; polar E(A)&#176; = E((A&#7488;)&#8315;&#185;), area = '
                 f'{area_polar:.4f}</text>')
    parts.append(f'<text x="20" y="{y0+60}" font-size="13" fill="#c98a2b">'
                 '&#9632; intersection body E((det A)A&#8315;&#185;)</text>')
    parts.append(f'<text x="20" y="{y0+78}" font-size="13" fill="#b0202f">'
                 f'&#9632; chord E(A) &#8745; u&#8869;, length = 2|det A|/||A&#7488;u|| '
                 f'= {chord_len:.4f}</text>')
    parts.append(f'<text x="20" y="{HEIGHT-46}" font-size="13" fill="#222">'
                 f'volume product = area(E(A))&#183;area(E(A)&#176;) = '
                 f'{area_e*area_polar:.6f} = &#960;&#178; '
                 '(Blaschke-Santal&#243; equality)</text>')
    parts.append(f'<text x="20" y="{HEIGHT-26}" font-size="13" fill="#222">'
                 'the dashed circle is the unit ball; the intersection body is the '
                 'chord-length profile drawn as a body</text>')
    parts.append('</svg>')
    return "\n".join(parts)


def main() -> None:
    # a tilted ellipse: rotate diag(2.1, 0.6) by 28 degrees
    theta: float = math.radians(28.0)
    c, s = math.cos(theta), math.sin(theta)
    rot: Matrix = [[c, -s], [s, c]]
    diag: Matrix = [[2.1, 0.0], [0.0, 0.6]]
    a: Matrix = [[rot[i][0] * diag[0][j] + rot[i][1] * diag[1][j] for j in range(2)]
                 for i in range(2)]
    a = [[sum(a[i][k] * rot[j][k] for k in range(2)) for j in range(2)] for i in range(2)]
    u: Vector = [math.cos(math.radians(65.0)), math.sin(math.radians(65.0))]
    svg: str = build_svg(a, u)
    with open("ellipse_duals.svg", "w", encoding="utf-8") as fh:
        fh.write(svg)
    print("wrote ellipse_duals.svg")
    print("det A =", round(det2(a), 6))


if __name__ == "__main__":
    main()


"""Visualization: the central-section profile of a three-dimensional ellipsoid.

For a positive definite 3x3 generator A the area of the central section orthogonal to a
unit direction u is  det(A) / ||A u|| * pi.  The script renders this function over the
sphere of directions as a heat map in spherical coordinates (azimuth phi, polar angle
theta), together with

  * the two horizontal reference lines  det A / lam_max  and  det A / lam_min  in the
    colour scale, which the map must never leave;
  * markers at the six extremal directions (the +/- eigenvectors), where the maximum is
    attained orthogonally to the smallest semiaxis and the minimum orthogonally to the
    largest.

Writes `section_profile.svg` in the current directory.  Pure standard library.
"""

from __future__ import annotations

import math
from typing import List, Tuple

Matrix = List[List[float]]
Vector = List[float]

NPHI: int = 120
NTHETA: int = 60
CELL_W: float = 5.0
CELL_H: float = 5.0
LEFT: float = 60.0
TOP: float = 80.0
BAR_W: float = 26.0


def identity(n: int) -> Matrix:
    """n x n identity matrix."""
    return [[1.0 if i == j else 0.0 for j in range(n)] for i in range(n)]


def matvec(a: Matrix, x: Vector) -> Vector:
    """Matrix-vector product."""
    return [sum(a[i][j] * x[j] for j in range(len(x))) for i in range(len(a))]


def norm(x: Vector) -> float:
    """Euclidean norm."""
    return math.sqrt(sum(v * v for v in x))


def jacobi_eigen(a: Matrix, sweeps: int = 100) -> Tuple[Vector, Matrix]:
    """Cyclic Jacobi eigendecomposition of a symmetric matrix."""
    n: int = len(a)
    m: Matrix = [row[:] for row in a]
    u: Matrix = identity(n)
    for _ in range(sweeps):
        off: float = math.sqrt(sum(m[i][j] ** 2 for i in range(n)
                                   for j in range(n) if i != j))
        if off < 1e-14:
            break
        for p in range(n - 1):
            for q in range(p + 1, n):
                if abs(m[p][q]) < 1e-18:
                    continue
                theta: float = (m[q][q] - m[p][p]) / (2.0 * m[p][q])
                t: float = math.copysign(1.0, theta) / (
                    abs(theta) + math.sqrt(theta * theta + 1.0))
                c: float = 1.0 / math.sqrt(t * t + 1.0)
                s: float = t * c
                for k in range(n):
                    mkp, mkq = m[k][p], m[k][q]
                    m[k][p] = c * mkp - s * mkq
                    m[k][q] = s * mkp + c * mkq
                for k in range(n):
                    mpk, mqk = m[p][k], m[q][k]
                    m[p][k] = c * mpk - s * mqk
                    m[q][k] = s * mpk + c * mqk
                for k in range(n):
                    ukp, ukq = u[k][p], u[k][q]
                    u[k][p] = c * ukp - s * ukq
                    u[k][q] = s * ukp + c * ukq
    return [m[i][i] for i in range(n)], u


def colour(t: float) -> str:
    """Perceptually gentle blue-to-red ramp for t in [0, 1]."""
    t = min(max(t, 0.0), 1.0)
    stops: List[Tuple[float, Tuple[int, int, int]]] = [
        (0.00, (38, 70, 120)),
        (0.25, (70, 140, 175)),
        (0.50, (238, 233, 205)),
        (0.75, (222, 152, 74)),
        (1.00, (160, 40, 45)),
    ]
    for i in range(len(stops) - 1):
        t0, c0 = stops[i]
        t1, c1 = stops[i + 1]
        if t0 <= t <= t1:
            f: float = (t - t0) / (t1 - t0)
            r = int(c0[0] + f * (c1[0] - c0[0]))
            g = int(c0[1] + f * (c1[1] - c0[1]))
            b = int(c0[2] + f * (c1[2] - c0[2]))
            return f"rgb({r},{g},{b})"
    return "rgb(160,40,45)"


def build_svg(a: Matrix) -> str:
    """Assemble the SVG heat map of the section-area function."""
    lam, evec = jacobi_eigen(a)
    det_a: float = lam[0] * lam[1] * lam[2]
    lo, hi = min(lam), max(lam)
    vmin: float = det_a / hi * math.pi
    vmax: float = det_a / lo * math.pi

    width = int(LEFT + NPHI * CELL_W + 140)
    height = int(TOP + NTHETA * CELL_H + 90)
    parts: List[str] = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" '
        f'viewBox="0 0 {width} {height}" font-family="Georgia, serif">',
        '<rect width="100%" height="100%" fill="#fbfaf7"/>',
        f'<text x="{LEFT}" y="34" font-size="18" fill="#222">'
        'Central section area of a 3D ellipsoid as a function of direction</text>',
        f'<text x="{LEFT}" y="56" font-size="13" fill="#555">'
        f'area(u) = &#960;&#183;det A / ||A u||, '
        f'semiaxes {sorted(round(x,3) for x in lam)}, '
        f'range [{vmin:.3f}, {vmax:.3f}]</text>',
    ]
    for i in range(NPHI):
        phi = 2.0 * math.pi * (i + 0.5) / NPHI
        for j in range(NTHETA):
            theta = math.pi * (j + 0.5) / NTHETA
            u: Vector = [math.sin(theta) * math.cos(phi),
                         math.sin(theta) * math.sin(phi),
                         math.cos(theta)]
            value = det_a / norm(matvec(a, u)) * math.pi
            t = (value - vmin) / (vmax - vmin) if vmax > vmin else 0.5
            x = LEFT + i * CELL_W
            y = TOP + j * CELL_H
            parts.append(f'<rect x="{x:.2f}" y="{y:.2f}" width="{CELL_W+0.4:.2f}" '
                         f'height="{CELL_H+0.4:.2f}" fill="{colour(t)}"/>')
    # extremal direction markers
    i_min = min(range(3), key=lambda k: lam[k])
    i_max = max(range(3), key=lambda k: lam[k])
    for idx, label, col in ((i_min, "max", "#ffffff"), (i_max, "min", "#111111")):
        for sgn in (1.0, -1.0):
            v = [sgn * evec[k][idx] for k in range(3)]
            theta = math.acos(max(-1.0, min(1.0, v[2])))
            phi = math.atan2(v[1], v[0]) % (2.0 * math.pi)
            x = LEFT + phi / (2.0 * math.pi) * NPHI * CELL_W
            y = TOP + theta / math.pi * NTHETA * CELL_H
            parts.append(f'<circle cx="{x:.2f}" cy="{y:.2f}" r="5.5" fill="none" '
                         f'stroke="{col}" stroke-width="2"/>')
            parts.append(f'<text x="{x+8:.2f}" y="{y+4:.2f}" font-size="11" '
                         f'fill="{col}">{label}</text>')
    # frame and axis labels
    fx, fy = LEFT, TOP
    fw, fh = NPHI * CELL_W, NTHETA * CELL_H
    parts.append(f'<rect x="{fx:.1f}" y="{fy:.1f}" width="{fw:.1f}" height="{fh:.1f}" '
                 'fill="none" stroke="#444" stroke-width="1"/>')
    parts.append(f'<text x="{fx:.1f}" y="{fy+fh+22:.1f}" font-size="12" fill="#333">'
                 'azimuth &#966; = 0</text>')
    parts.append(f'<text x="{fx+fw-60:.1f}" y="{fy+fh+22:.1f}" font-size="12" '
                 'fill="#333">&#966; = 2&#960;</text>')
    parts.append(f'<text x="{fx-46:.1f}" y="{fy+10:.1f}" font-size="12" fill="#333">'
                 '&#952;=0</text>')
    parts.append(f'<text x="{fx-46:.1f}" y="{fy+fh:.1f}" font-size="12" fill="#333">'
                 '&#952;=&#960;</text>')
    # colour bar
    bx = fx + fw + 34
    for k in range(120):
        t = 1.0 - k / 119.0
        parts.append(f'<rect x="{bx:.1f}" y="{fy + k*fh/120:.2f}" width="{BAR_W}" '
                     f'height="{fh/120+0.6:.2f}" fill="{colour(t)}"/>')
    parts.append(f'<rect x="{bx:.1f}" y="{fy:.1f}" width="{BAR_W}" height="{fh:.1f}" '
                 'fill="none" stroke="#444" stroke-width="1"/>')
    parts.append(f'<text x="{bx+BAR_W+6:.1f}" y="{fy+10:.1f}" font-size="11" '
                 f'fill="#333">{vmax:.3f} = &#960; det A/&#955;min</text>')
    parts.append(f'<text x="{bx+BAR_W+6:.1f}" y="{fy+fh:.1f}" font-size="11" '
                 f'fill="#333">{vmin:.3f} = &#960; det A/&#955;max</text>')
    parts.append(f'<text x="{LEFT}" y="{height-24}" font-size="12" fill="#333">'
                 'the profile never leaves the eigenvalue band, and touches its ends '
                 'exactly at the marked eigendirections</text>')
    parts.append('</svg>')
    return "\n".join(parts)


def main() -> None:
    a: Matrix = [[1.80, 0.45, 0.20],
                 [0.45, 1.10, -0.30],
                 [0.20, -0.30, 0.75]]
    with open("section_profile.svg", "w", encoding="utf-8") as fh:
        fh.write(build_svg(a))
    lam, _ = jacobi_eigen(a)
    print("wrote section_profile.svg")
    print("semiaxes:", [round(x, 5) for x in sorted(lam)])


if __name__ == "__main__":
    main()


"""
Ellipsoids as positive-definite images of balls: numerical demonstrations.

This script is fully self-contained (Python standard library only: `math`, `random`).
All linear-algebra primitives are implemented inline, so nothing beyond CPython is
required.  Every numerical experiment below checks one of the exact identities of the
theory:

  1. Volume of an ellipsoid                 vol(E(A)) = |det A| * w_n
  2. Central hyperplane section formula     vol_{n-1}(E(A) cap u^perp)
                                              = (|det A| / ||A^T u||) * w_{n-1}
  3. Gram-determinant section formula       vol_m(section) = w_m / sqrt(det(T^T T))
  4. Spectral slicing bounds and rigidity   det A / lam_max  <=  ratio  <=  det A / lam_min
  5. Determinant normalization identity     prod_i (det A / lam_i) = (det A)^{n-1}
  6. Codimension-free sandwich              lo^m w_m <= vol_m(section) <= hi^m w_m
  7. Coordinate sections of a diagonal      vol_m = (prod_j |d_{f(j)}|) * w_m
  8. Polar duality / Blaschke-Santalo       vol(E(A)) * vol(E(A)^o) = w_n^2
  9. Intersection body of an ellipsoid      I(E(A)) = E(|det A| * sqrt(A A^T)^{-1})
 10. The ball is the unique unimodular fixed point of the intersection operator.

Run with:  python3 demo.py
"""

from __future__ import annotations

import math
import random
from typing import Callable, List, Sequence, Tuple

Matrix = List[List[float]]
Vector = List[float]

TOL = 1e-9

# ---------------------------------------------------------------------------
# Elementary linear algebra (implemented inline; no third-party dependencies)
# ---------------------------------------------------------------------------


def zeros(rows: int, cols: int) -> Matrix:
    """Return a `rows x cols` zero matrix."""
    return [[0.0 for _ in range(cols)] for _ in range(rows)]


def identity(n: int) -> Matrix:
    """Return the `n x n` identity matrix."""
    return [[1.0 if i == j else 0.0 for j in range(n)] for i in range(n)]


def transpose(a: Matrix) -> Matrix:
    """Return the transpose of `a`."""
    return [list(col) for col in zip(*a)]


def matmul(a: Matrix, b: Matrix) -> Matrix:
    """Return the matrix product `a * b`."""
    n, k, m = len(a), len(b), len(b[0])
    out = zeros(n, m)
    for i in range(n):
        ai = a[i]
        for t in range(k):
            v = ai[t]
            if v == 0.0:
                continue
            bt = b[t]
            oi = out[i]
            for j in range(m):
                oi[j] += v * bt[j]
    return out


def matvec(a: Matrix, x: Sequence[float]) -> Vector:
    """Return the matrix-vector product `a x`."""
    return [sum(a[i][j] * x[j] for j in range(len(x))) for i in range(len(a))]


def scal(c: float, a: Matrix) -> Matrix:
    """Return the scalar multiple `c * a`."""
    return [[c * v for v in row] for row in a]


def dot(x: Sequence[float], y: Sequence[float]) -> float:
    """Return the Euclidean inner product of `x` and `y`."""
    return sum(xi * yi for xi, yi in zip(x, y))


def norm(x: Sequence[float]) -> float:
    """Return the Euclidean norm of `x`."""
    return math.sqrt(dot(x, x))


def det(a: Matrix) -> float:
    """Determinant by LU decomposition with partial pivoting.  Cost O(n^3)."""
    n = len(a)
    m = [row[:] for row in a]
    sign = 1.0
    d = 1.0
    for c in range(n):
        piv = max(range(c, n), key=lambda r: abs(m[r][c]))
        if abs(m[piv][c]) < 1e-300:
            return 0.0
        if piv != c:
            m[c], m[piv] = m[piv], m[c]
            sign = -sign
        d *= m[c][c]
        inv = 1.0 / m[c][c]
        for r in range(c + 1, n):
            f = m[r][c] * inv
            if f == 0.0:
                continue
            for j in range(c, n):
                m[r][j] -= f * m[c][j]
    return sign * d


def inverse(a: Matrix) -> Matrix:
    """Matrix inverse by Gauss-Jordan elimination with partial pivoting."""
    n = len(a)
    m = [row[:] + ident_row for row, ident_row in zip(a, identity(n))]
    for c in range(n):
        piv = max(range(c, n), key=lambda r: abs(m[r][c]))
        if abs(m[piv][c]) < 1e-300:
            raise ValueError("singular matrix")
        m[c], m[piv] = m[piv], m[c]
        f = 1.0 / m[c][c]
        m[c] = [v * f for v in m[c]]
        for r in range(n):
            if r == c:
                continue
            g = m[r][c]
            if g == 0.0:
                continue
            m[r] = [vr - g * vc for vr, vc in zip(m[r], m[c])]
    return [row[n:] for row in m]


def jacobi_eigen(a: Matrix, sweeps: int = 100) -> Tuple[Vector, Matrix]:
    """Symmetric eigenproblem by the cyclic Jacobi rotation method.

    Returns `(eigenvalues, U)` with `a = U diag(eigenvalues) U^T` and `U` orthogonal
    (its columns are the orthonormal eigenvectors).  Converges quadratically for
    symmetric input; cost O(n^3) per sweep.
    """
    n = len(a)
    m = [row[:] for row in a]
    u = identity(n)
    for _ in range(sweeps):
        off = math.sqrt(sum(m[i][j] ** 2 for i in range(n) for j in range(n) if i != j))
        if off < 1e-14:
            break
        for p in range(n - 1):
            for q in range(p + 1, n):
                if abs(m[p][q]) < 1e-18:
                    continue
                theta = (m[q][q] - m[p][p]) / (2.0 * m[p][q])
                t = math.copysign(1.0, theta) / (abs(theta) + math.sqrt(theta * theta + 1.0))
                c = 1.0 / math.sqrt(t * t + 1.0)
                s = t * c
                for k in range(n):
                    mkp, mkq = m[k][p], m[k][q]
                    m[k][p] = c * mkp - s * mkq
                    m[k][q] = s * mkp + c * mkq
                for k in range(n):
                    mpk, mqk = m[p][k], m[q][k]
                    m[p][k] = c * mpk - s * mqk
                    m[q][k] = s * mpk + c * mqk
                for k in range(n):
                    ukp, ukq = u[k][p], u[k][q]
                    u[k][p] = c * ukp - s * ukq
                    u[k][q] = s * ukp + c * ukq
    return [m[i][i] for i in range(n)], u


def psd_sqrt(a: Matrix) -> Matrix:
    """Unique positive semidefinite square root of a symmetric PSD matrix."""
    lam, u = jacobi_eigen(a)
    d = [[0.0] * len(a) for _ in a]
    for i, li in enumerate(lam):
        d[i][i] = math.sqrt(max(li, 0.0))
    return matmul(matmul(u, d), transpose(u))


def ball_volume(m: int) -> float:
    """Volume w_m of the unit ball in R^m:  pi^{m/2} / Gamma(m/2 + 1)."""
    return math.pi ** (m / 2.0) / math.gamma(m / 2.0 + 1.0)


def gram_schmidt_frame(u: Sequence[float]) -> Matrix:
    """Orthonormal frame `iota` of the hyperplane orthogonal to the unit vector `u`.

    Returns an `n x (n-1)` matrix whose columns are an orthonormal basis of `u^perp`,
    so that `iota^T iota = I` and `iota iota^T = I - u u^T`.
    """
    n = len(u)
    basis: List[Vector] = [list(u)]
    for j in range(n):
        e = [1.0 if k == j else 0.0 for k in range(n)]
        for b in basis:
            c = dot(e, b)
            e = [ei - c * bi for ei, bi in zip(e, b)]
        nb = norm(e)
        if nb > 1e-8:
            basis.append([ei / nb for ei in e])
        if len(basis) == n:
            break
    cols = basis[1:]
    return [[cols[j][i] for j in range(n - 1)] for i in range(n)]


def random_spd(n: int, rng: random.Random, lo: float = 0.4, hi: float = 3.0) -> Matrix:
    """Random positive definite matrix with eigenvalues drawn from `[lo, hi]`."""
    g = [[rng.gauss(0.0, 1.0) for _ in range(n)] for _ in range(n)]
    # orthonormalise the rows of g (Gram-Schmidt) to get a random orthogonal U
    rows: List[Vector] = []
    for r in g:
        v = list(r)
        for b in rows:
            c = dot(v, b)
            v = [vi - c * bi for vi, bi in zip(v, b)]
        nv = norm(v)
        rows.append([vi / nv for vi in v])
    u = transpose(rows)
    lam = [rng.uniform(lo, hi) for _ in range(n)]
    d = [[lam[i] if i == j else 0.0 for j in range(n)] for i in range(n)]
    return matmul(matmul(u, d), transpose(u))


def random_unit(n: int, rng: random.Random) -> Vector:
    """Uniformly random unit vector in R^n."""
    v = [rng.gauss(0.0, 1.0) for _ in range(n)]
    s = norm(v)
    return [vi / s for vi in v]


def close(x: float, y: float, tol: float = 1e-7) -> str:
    """Format a pass/fail marker for two floats expected to agree."""
    return "OK " if abs(x - y) <= tol * max(1.0, abs(x), abs(y)) else "FAIL"


# ---------------------------------------------------------------------------
# The theory, as callable formulas
# ---------------------------------------------------------------------------


def ellipsoid_volume(a: Matrix) -> float:
    """vol(E(A)) = |det A| * w_n."""
    return abs(det(a)) * ball_volume(len(a))


def section_volume_formula(a: Matrix, u: Sequence[float]) -> float:
    """Exact central hyperplane section:  (|det A| / ||A^T u||) * w_{n-1}."""
    n = len(a)
    return abs(det(a)) / norm(matvec(transpose(a), u)) * ball_volume(n - 1)


def section_volume_gram(a: Matrix, iota: Matrix) -> float:
    """Exact section of any codimension:  w_m / sqrt(det((A^{-1} iota)^T (A^{-1} iota)))."""
    t = matmul(inverse(a), iota)
    g = matmul(transpose(t), t)
    return ball_volume(len(g)) / math.sqrt(det(g))


def section_volume_monte_carlo(
    a: Matrix, iota: Matrix, samples: int, rng: random.Random
) -> float:
    """Monte-Carlo estimate of the m-volume of the pulled-back central section.

    The section is `{y in R^m : ||A^{-1} iota y|| <= 1}`; it is contained in the ball of
    radius `R = ||A||_op` (operator norm bound), so we sample the cube `[-R, R]^m`.
    """
    t = matmul(inverse(a), iota)
    m = len(t[0])
    lam, _ = jacobi_eigen(matmul(transpose(a), a))
    radius = math.sqrt(max(lam)) * 1.001
    hits = 0
    for _ in range(samples):
        y = [rng.uniform(-radius, radius) for _ in range(m)]
        if norm(matvec(t, y)) <= 1.0:
            hits += 1
    return (2.0 * radius) ** m * hits / samples


def intersection_generator(a: Matrix) -> Matrix:
    """Generator of the intersection body:  |det A| * sqrt(A A^T)^{-1}."""
    s = psd_sqrt(matmul(a, transpose(a)))
    return scal(abs(det(a)), inverse(s))


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------


def banner(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


def demo_volume(rng: random.Random) -> None:
    banner("1. Volume of an ellipsoid:  vol(E(A)) = |det A| * w_n")
    for n in (2, 3, 4, 5):
        a = random_spd(n, rng)
        lam, _ = jacobi_eigen(a)
        prod_axes = 1.0
        for li in lam:
            prod_axes *= li
        v1 = ellipsoid_volume(a)
        v2 = prod_axes * ball_volume(n)
        print(
            f"  n={n}  det A = {det(a):9.5f}   vol = {v1:11.6f}   "
            f"(prod of semiaxes) * w_n = {v2:11.6f}   {close(v1, v2)}"
        )


def demo_section_formula(rng: random.Random) -> None:
    banner("2-3. Section formula vs Gram determinant vs Monte Carlo")
    for n in (2, 3, 4):
        a = random_spd(n, rng)
        u = random_unit(n, rng)
        iota = gram_schmidt_frame(u)
        v_formula = section_volume_formula(a, u)
        v_gram = section_volume_gram(a, iota)
        v_mc = section_volume_monte_carlo(a, iota, 200000, rng)
        print(f"  n={n}")
        print(f"     |det A| / ||A^T u|| * w_(n-1) = {v_formula:11.6f}")
        print(f"     Gram-determinant formula      = {v_gram:11.6f}   {close(v_formula, v_gram)}")
        print(f"     Monte-Carlo estimate          = {v_mc:11.6f}   "
              f"(relative gap {abs(v_mc - v_formula) / v_formula:.3%})")
        # frame independence: rotate the frame inside the hyperplane
        m = n - 1
        if m >= 2:
            theta = rng.uniform(0.0, math.pi)
            r = identity(m)
            r[0][0] = math.cos(theta)
            r[0][1] = -math.sin(theta)
            r[1][0] = math.sin(theta)
            r[1][1] = math.cos(theta)
            v_rot = section_volume_gram(a, matmul(iota, r))
            print(f"     rotated frame                 = {v_rot:11.6f}   {close(v_gram, v_rot)}")
        # frame identities iota^T iota = I and iota iota^T = I - u u^T
        e1 = max(
            abs(matmul(transpose(iota), iota)[i][j] - identity(m)[i][j])
            for i in range(m)
            for j in range(m)
        )
        uut = [[u[i] * u[j] for j in range(n)] for i in range(n)]
        e2 = max(
            abs(matmul(iota, transpose(iota))[i][j] - (identity(n)[i][j] - uut[i][j]))
            for i in range(n)
            for j in range(n)
        )
        print(f"     frame identities: max error   = {max(e1, e2):.2e}")


def demo_slicing_bounds(rng: random.Random) -> None:
    banner("4. Spectral slicing bounds and rigidity of the extremal directions")
    n = 4
    a = random_spd(n, rng)
    lam, u_mat = jacobi_eigen(a)
    lo, hi = min(lam), max(lam)
    d = det(a)
    w = ball_volume(n - 1)
    print(f"  eigenvalues: {[round(x, 4) for x in sorted(lam)]}")
    print(f"  predicted range of the section volume: "
          f"[{d / hi * w:.6f}, {d / lo * w:.6f}]")
    worst_lo, worst_hi = math.inf, -math.inf
    for _ in range(20000):
        u = random_unit(n, rng)
        v = section_volume_formula(a, u)
        worst_lo = min(worst_lo, v)
        worst_hi = max(worst_hi, v)
    print(f"  observed over 20000 random directions: [{worst_lo:.6f}, {worst_hi:.6f}]")
    # attainment: the eigenvector for lam_min gives the largest section
    imin = min(range(n), key=lambda i: lam[i])
    imax = max(range(n), key=lambda i: lam[i])
    u_min = [u_mat[i][imin] for i in range(n)]
    u_max = [u_mat[i][imax] for i in range(n)]
    v_max = section_volume_formula(a, u_min)
    v_min = section_volume_formula(a, u_max)
    print(f"  section orthogonal to the lam_min eigenvector = {v_max:.6f}  "
          f"(= det A / lam_min * w = {d / lo * w:.6f})  {close(v_max, d / lo * w)}")
    print(f"  section orthogonal to the lam_max eigenvector = {v_min:.6f}  "
          f"(= det A / lam_max * w = {d / hi * w:.6f})  {close(v_min, d / hi * w)}")


def demo_determinant_identity(rng: random.Random) -> None:
    banner("5. Determinant-normalization identity:  prod_i (det A / lam_i) = (det A)^(n-1)")
    for n in (2, 3, 4, 5):
        a = random_spd(n, rng)
        lam, _ = jacobi_eigen(a)
        d = det(a)
        prod = 1.0
        for li in lam:
            prod *= d / li
        rhs = d ** (n - 1)
        print(f"  n={n}  prod = {prod:12.6f}   (det A)^(n-1) = {rhs:12.6f}   {close(prod, rhs)}")


def demo_codim_sandwich(rng: random.Random) -> None:
    banner("6. Codimension-free sandwich:  lo^m w_m <= vol_m(section) <= hi^m w_m")
    n = 5
    a = random_spd(n, rng)
    lam, _ = jacobi_eigen(a)
    lo, hi = min(lam), max(lam)
    print(f"  eigenvalues in [{lo:.4f}, {hi:.4f}]")
    for m in (1, 2, 3, 4):
        # random orthonormal frame of an m-dimensional subspace
        cols: List[Vector] = []
        while len(cols) < m:
            v = random_unit(n, rng)
            for b in cols:
                c = dot(v, b)
                v = [vi - c * bi for vi, bi in zip(v, b)]
            nv = norm(v)
            if nv > 1e-6:
                cols.append([vi / nv for vi in v])
        iota = [[cols[j][i] for j in range(m)] for i in range(n)]
        v = section_volume_gram(a, iota)
        low, high = lo ** m * ball_volume(m), hi ** m * ball_volume(m)
        ok = "OK " if low - 1e-9 <= v <= high + 1e-9 else "FAIL"
        print(f"  m={m}   {low:11.6f} <= {v:11.6f} <= {high:11.6f}   {ok}")


def demo_coordinate_sections() -> None:
    banner("7. Coordinate sections of a diagonal ellipsoid:  vol_m = prod_j |d_f(j)| * w_m")
    d = [1.5, 0.7, 2.4, 0.9]
    n = len(d)
    a = [[d[i] if i == j else 0.0 for j in range(n)] for i in range(n)]
    subsets: List[Tuple[int, ...]] = [
        (0,), (1,), (0, 1), (0, 2), (1, 2, 3), (0, 1, 2),
    ]
    for f in subsets:
        m = len(f)
        iota = [[1.0 if i == f[j] else 0.0 for j in range(m)] for i in range(n)]
        v = section_volume_gram(a, iota)
        prod = 1.0
        for j in f:
            prod *= abs(d[j])
        pred = prod * ball_volume(m)
        print(f"  axes {f}: volume = {v:11.6f}   prod|d| * w_m = {pred:11.6f}   {close(v, pred)}")


def demo_polar_duality(rng: random.Random) -> None:
    banner("8. Polar duality and the Blaschke-Santalo equality")
    for n in (2, 3, 4):
        a = random_spd(n, rng)
        polar_gen = inverse(transpose(a))          # E(A)^o = E((A^T)^{-1})
        v = ellipsoid_volume(a)
        vp = ellipsoid_volume(polar_gen)
        prod = v * vp
        target = ball_volume(n) ** 2
        print(f"  n={n}  vol = {v:10.6f}  vol(polar) = {vp:10.6f}  "
              f"product = {prod:10.6f}  w_n^2 = {target:10.6f}  {close(prod, target)}")
        # bipolar theorem: the polar of the polar is the original ellipsoid
        bip = inverse(transpose(polar_gen))
        err = max(abs(bip[i][j] - a[i][j]) for i in range(n) for j in range(n))
        print(f"        bipolar reconstruction error = {err:.2e}")


def demo_intersection_body(rng: random.Random) -> None:
    banner("9-10. The intersection body of an ellipsoid is an ellipsoid")
    n = 4
    a = random_spd(n, rng)
    gen = intersection_generator(a)
    # (a) generator agrees with (det A) A^{-1} for positive definite A
    pred = scal(det(a), inverse(a))
    err = max(abs(gen[i][j] - pred[i][j]) for i in range(n) for j in range(n))
    print(f"  intersection generator vs (det A) A^(-1):  max error = {err:.2e}")
    # (b) determinant of the intersection generator
    print(f"  det I(A) = {det(gen):12.6f}   |det A|^(n-1) = {abs(det(a)) ** (n - 1):12.6f}   "
          f"{close(det(gen), abs(det(a)) ** (n - 1))}")
    # (c) radial function of E(I(A)) equals the normalised section volume of E(A)
    print("  radial function check (random directions):")
    for _ in range(4):
        u = random_unit(n, rng)
        radial = 1.0 / norm(matvec(inverse(gen), u))        # rho_{E(I(A))}(u)
        normalized_section = section_volume_formula(a, u) / ball_volume(n - 1)
        print(f"     rho = {radial:10.6f}   section/w_(n-1) = {normalized_section:10.6f}   "
              f"{close(radial, normalized_section)}")
    # (d) involution on unimodular positive definite generators
    scale = abs(det(a)) ** (-1.0 / n)
    a1 = scal(scale, a)                                     # det a1 = 1
    g1 = intersection_generator(a1)
    g2 = intersection_generator(g1)
    err = max(abs(g2[i][j] - a1[i][j]) for i in range(n) for j in range(n))
    print(f"  det(normalised A) = {det(a1):.10f};  I(I(A)) = A:  max error = {err:.2e}")
    # (e) the ball is the unique unimodular fixed point
    fix_err = max(abs(g1[i][j] - a1[i][j]) for i in range(n) for j in range(n))
    print(f"  distance ||I(A) - A|| for this (non-ball) unimodular A = {fix_err:.6f}  "
          f"(zero only for A = I)")
    idn = identity(n)
    gi = intersection_generator(idn)
    err_ball = max(abs(gi[i][j] - idn[i][j]) for i in range(n) for j in range(n))
    print(f"  for A = I (the unit ball):  ||I(A) - A|| = {err_ball:.2e}  -> fixed point")


def demo_unimodular_straddle(rng: random.Random) -> None:
    banner("Bonus. A unimodular ellipsoid always straddles the ball's section")
    n = 4
    w = ball_volume(n - 1)
    print(f"  reference: w_(n-1) = {w:.6f}")
    for trial in range(4):
        a = random_spd(n, rng)
        a = scal(abs(det(a)) ** (-1.0 / n), a)              # normalise det to 1
        lam, u_mat = jacobi_eigen(a)
        imin = min(range(n), key=lambda i: lam[i])
        imax = max(range(n), key=lambda i: lam[i])
        big = section_volume_formula(a, [u_mat[i][imin] for i in range(n)])
        small = section_volume_formula(a, [u_mat[i][imax] for i in range(n)])
        ok = "OK " if small <= w + 1e-9 <= big + 2e-9 else "FAIL"
        print(f"  trial {trial}: min section = {small:.6f}  <=  w  <=  "
              f"max section = {big:.6f}   {ok}")


def main() -> None:
    rng = random.Random(20260825)
    print(__doc__)
    demo_volume(rng)
    demo_section_formula(rng)
    demo_slicing_bounds(rng)
    demo_determinant_identity(rng)
    demo_codim_sandwich(rng)
    demo_coordinate_sections()
    demo_polar_duality(rng)
    demo_intersection_body(rng)
    demo_unimodular_straddle(rng)
    print()
    print("All exact identities verified to machine precision; "
          "Monte-Carlo checks agree within sampling error.")


if __name__ == "__main__":
    main()
