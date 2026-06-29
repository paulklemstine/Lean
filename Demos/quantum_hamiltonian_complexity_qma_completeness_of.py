"""
demo.py — Numerical demonstrations for:

    "The Energy Algebra of Local Hamiltonians:
     Quadratic Forms, Certified Lower Bounds, Frustration, and the Promise Gap"

This self-contained script illustrates, with concrete complex matrices, every
mathematical result of the package:

  1. The Rayleigh quadratic form  qform(H, x) = <x, H x>  and its additivity.
  2. Reality of Hermitian expectation values (the imaginary part vanishes).
  3. The certificate calculus of energy lower bounds (additive composition).
  4. Consistency of the promise gap (a YES witness cannot coexist with a NO floor).
  5. The minimal frustration witness: two single-qubit terms with individual
     ground energy 0 that share no common zero-energy state, so the global
     ground energy strictly exceeds the additive floor  (= (2 - sqrt 2) / 2).

Only the Python standard library is used (cmath / math), so it runs anywhere.
All linear algebra is inlined with explicit type hints.
"""

from __future__ import annotations

import cmath
import math
from typing import List, Sequence, Tuple

Complex = complex
Vector = List[Complex]
Matrix = List[List[Complex]]


# --------------------------------------------------------------------------- #
# Basic complex linear algebra (inlined)
# --------------------------------------------------------------------------- #
def conj_vec(x: Sequence[Complex]) -> Vector:
    """Entrywise complex conjugate (the `star` of a vector)."""
    return [v.conjugate() for v in x]


def dot(v: Sequence[Complex], w: Sequence[Complex]) -> Complex:
    """Bilinear dot product  sum_i v_i * w_i  (no conjugation here)."""
    return sum((a * b for a, b in zip(v, w)), 0j)


def mat_vec(h: Matrix, x: Sequence[Complex]) -> Vector:
    """Matrix-vector product (H x)_i = sum_j H_ij x_j."""
    return [sum((h[i][j] * x[j] for j in range(len(x))), 0j) for i in range(len(h))]


def mat_add(a: Matrix, b: Matrix) -> Matrix:
    """Entrywise sum of two matrices of equal shape."""
    return [[a[i][j] + b[i][j] for j in range(len(a[i]))] for i in range(len(a))]


def conj_transpose(a: Matrix) -> Matrix:
    """Hermitian conjugate (conjugate transpose) of a square matrix."""
    n = len(a)
    return [[a[j][i].conjugate() for j in range(n)] for i in range(n)]


def is_hermitian(a: Matrix, tol: float = 1e-12) -> bool:
    """True iff A equals its conjugate transpose within tolerance."""
    ah = conj_transpose(a)
    return all(abs(a[i][j] - ah[i][j]) < tol
               for i in range(len(a)) for j in range(len(a)))


# --------------------------------------------------------------------------- #
# The energy functional and norms (Definitions 3.1, 5.1)
# --------------------------------------------------------------------------- #
def qform(h: Matrix, x: Sequence[Complex]) -> Complex:
    """Rayleigh quadratic form  qform(H, x) = <x, H x> = conj(x) . (H x)."""
    return dot(conj_vec(x), mat_vec(h, x))


def norm_sq(x: Sequence[Complex]) -> float:
    """Squared norm  ||x||^2 = Re(conj(x) . x) = sum_i |x_i|^2."""
    return dot(conj_vec(x), x).real


def energy(h: Matrix, x: Sequence[Complex]) -> float:
    """Real part of the Rayleigh form: the physical energy of state x."""
    return qform(h, x).real


# --------------------------------------------------------------------------- #
# Pauli operators and the frustration terms (Section 7)
# --------------------------------------------------------------------------- #
I2: Matrix = [[1 + 0j, 0 + 0j], [0 + 0j, 1 + 0j]]
Z: Matrix = [[1 + 0j, 0 + 0j], [0 + 0j, -1 + 0j]]
X: Matrix = [[0 + 0j, 1 + 0j], [1 + 0j, 0 + 0j]]


def scale(a: Matrix, c: Complex) -> Matrix:
    """Scalar multiple of a matrix."""
    return [[c * a[i][j] for j in range(len(a[i]))] for i in range(len(a))]


def half_I_minus(p: Matrix) -> Matrix:
    """The projector-like term (I - P) / 2."""
    return scale(mat_add(I2, scale(p, -1)), 0.5 + 0j)


H_Z: Matrix = half_I_minus(Z)   # (I - Z)/2 = diag(0, 1)
H_X: Matrix = half_I_minus(X)   # (I - X)/2 = [[1/2, -1/2], [-1/2, 1/2]]


# --------------------------------------------------------------------------- #
# 2x2 Hermitian eigenvalues (closed form) — for ground-energy comparison
# --------------------------------------------------------------------------- #
def eig2_hermitian(a: Matrix) -> Tuple[float, float]:
    """Return (lambda_min, lambda_max) of a 2x2 Hermitian matrix in closed form."""
    a00, a11 = a[0][0].real, a[1][1].real
    off = a[0][1]
    tr = a00 + a11
    det = a00 * a11 - (off * off.conjugate()).real
    disc = math.sqrt(max(tr * tr / 4 - det, 0.0))
    return tr / 2 - disc, tr / 2 + disc


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_additivity() -> None:
    """Theorem 3.2: qform(H1 + H2, x) = qform(H1, x) + qform(H2, x)."""
    print("=" * 70)
    print("1. ADDITIVITY OF THE ENERGY FUNCTIONAL (Theorem 3.2)")
    print("=" * 70)
    x: Vector = [0.6 + 0.2j, -0.3 + 0.5j]
    lhs = qform(mat_add(H_Z, H_X), x)
    rhs = qform(H_Z, x) + qform(H_X, x)
    print(f"  state x            = {x}")
    print(f"  qform(H_Z + H_X,x) = {lhs:.6f}")
    print(f"  qform(H_Z,x)+...   = {rhs:.6f}")
    print(f"  match              = {abs(lhs - rhs) < 1e-12}\n")


def demo_reality() -> None:
    """Theorem 4.2: Hermitian Rayleigh forms are real."""
    print("=" * 70)
    print("2. REALITY OF HERMITIAN EXPECTATION VALUES (Theorem 4.2)")
    print("=" * 70)
    for name, h in (("H_Z", H_Z), ("H_X", H_X), ("H_Z+H_X", mat_add(H_Z, H_X))):
        x: Vector = [0.7 - 0.4j, 0.1 + 0.9j]
        val = qform(h, x)
        print(f"  {name:8s} Hermitian={is_hermitian(h)}  "
              f"qform={val:.6f}  Im={val.imag:+.2e}")
    # A NON-Hermitian operator gives a genuinely complex energy:
    non_herm: Matrix = [[0j, 1j], [0j, 0j]]
    xv: Vector = [1 + 0j, 1 + 0j]
    print(f"  non-Herm           Hermitian={is_hermitian(non_herm)}  "
          f"qform={qform(non_herm, xv):.6f}  (imag part nonzero)\n")


def energy_lb(h: Matrix, lam: float, samples: int = 4000) -> bool:
    """Monte-Carlo check of EnergyLB(H, lam): lam*||x||^2 <= Re qform(H, x)."""
    import random
    rng = random.Random(2025)
    for _ in range(samples):
        x: Vector = [complex(rng.gauss(0, 1), rng.gauss(0, 1)) for _ in range(len(h))]
        if lam * norm_sq(x) > energy(h, x) + 1e-9:
            return False
    return True


def demo_certificates() -> None:
    """Theorems 5.5 / 5.7: additive composition of energy lower bounds."""
    print("=" * 70)
    print("3. CERTIFICATE CALCULUS OF ENERGY LOWER BOUNDS (Theorems 5.5, 5.7)")
    print("=" * 70)
    print(f"  EnergyLB(H_Z, 0)         = {energy_lb(H_Z, 0.0)}")
    print(f"  EnergyLB(H_X, 0)         = {energy_lb(H_X, 0.0)}")
    print(f"  => additive floor for H_Z+H_X = 0 + 0 = 0")
    print(f"  EnergyLB(H_Z+H_X, 0)     = {energy_lb(mat_add(H_Z, H_X), 0.0)}")
    print("  (the additive floor 0 is SOUND but, as we will see, not tight)\n")


def demo_promise_gap() -> None:
    """Theorem 6.3: a YES witness cannot coexist with a NO floor when a < b."""
    print("=" * 70)
    print("4. PROMISE-GAP CONSISTENCY (Theorem 6.3)")
    print("=" * 70)
    a, b = 0.10, 0.40
    h = mat_add(H_Z, H_X)
    lam_min, _ = eig2_hermitian(h)
    print(f"  thresholds a = {a}, b = {b}  (a < b)")
    print(f"  ground energy lambda_min(H_Z+H_X) = {lam_min:.6f}")
    yes = lam_min <= a
    no = energy_lb(h, b)
    print(f"  YES instance (lambda_min <= a)? {yes}")
    print(f"  NO  instance (EnergyLB(H,b))?   {no}")
    print(f"  simultaneously YES and NO?      {yes and no}  (must be False)\n")


def demo_frustration() -> None:
    """Theorem 7.2 / Cor 7.3: no common ground state; strict super-additivity."""
    print("=" * 70)
    print("5. FRUSTRATION & STRICT SUPER-ADDITIVITY (Theorem 7.2, Cor 7.3)")
    print("=" * 70)
    ket0: Vector = [1 + 0j, 0 + 0j]                       # ground state of H_Z
    ket_plus: Vector = [1 / math.sqrt(2) + 0j, 1 / math.sqrt(2) + 0j]  # of H_X
    print(f"  qform(H_Z, |0>)  = {qform(H_Z, ket0).real:.6f}  (individual min = 0)")
    print(f"  qform(H_X, |+>)  = {qform(H_X, ket_plus).real:.6f}  (individual min = 0)")
    print(f"  qform(H_X, |0>)  = {qform(H_X, ket0).real:.6f}  (|0> NOT a ground state of H_X)")
    print(f"  qform(H_Z, |+>)  = {qform(H_Z, ket_plus).real:.6f}  (|+> NOT a ground state of H_Z)")
    lam_min, lam_max = eig2_hermitian(mat_add(H_Z, H_X))
    exact = (2 - math.sqrt(2)) / 2
    print(f"  additive floor        = 0 + 0 = 0")
    print(f"  true ground energy    = {lam_min:.6f}")
    print(f"  exact (2 - sqrt2)/2   = {exact:.6f}")
    print(f"  frustration energy    = {lam_min - 0.0:.6f}  > 0  (super-additive!)")
    print(f"  match closed form     = {abs(lam_min - exact) < 1e-9}\n")


def main() -> None:
    print("\nLOCAL HAMILTONIAN ENERGY ALGEBRA — NUMERICAL DEMONSTRATIONS\n")
    demo_additivity()
    demo_reality()
    demo_certificates()
    demo_promise_gap()
    demo_frustration()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
