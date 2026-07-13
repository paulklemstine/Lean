"""
demo.py — Numerical demonstrations of the quaternionic Hopf-witness identities.

This self-contained script illustrates how a single algebraic device — the
Hermitian inner product of two unit vectors in the quaternionic plane H^2 —
detects, bounds, and *reconstructs* the fibres of the quaternionic Hopf
fibration S^7 -> S^4.

For unit vectors a = (q, r) and b = (q', r') in H^2 (meaning
|q|^2 + |r|^2 = 1 and |q'|^2 + |r'|^2 = 1), define the *witness*

        lambda = <a, b> = conj(q) * q' + conj(r) * r'.

The script verifies, on random rational/real quaternion data:

  1. The unconditional algebraic identity behind everything (normSq_identity).
  2. The squared-distance identity  |q' - q*lambda|^2 + |r' - r*lambda|^2
        = 1 - |lambda|^2  on the unit sphere.
  3. The Cauchy-Schwarz bound  |lambda| <= 1.
  4. Forward direction: if b = a * mu (right multiplication) then lambda = mu.
  5. Reconstruction: if |lambda| = 1 then q' = q*lambda and r' = r*lambda.
  6. The torsor / fibre correspondence: right-multiplication by unit
     quaternions and the witness are mutually inverse on the fibre.

Everything is implemented from scratch; no third-party libraries are required.
"""

from __future__ import annotations

import math
import random
from dataclasses import dataclass


@dataclass(frozen=True)
class Quaternion:
    """A real quaternion w + x i + y j + z k."""

    w: float
    x: float
    y: float
    z: float

    def __add__(self, other: "Quaternion") -> "Quaternion":
        return Quaternion(self.w + other.w, self.x + other.x,
                          self.y + other.y, self.z + other.z)

    def __sub__(self, other: "Quaternion") -> "Quaternion":
        return Quaternion(self.w - other.w, self.x - other.x,
                          self.y - other.y, self.z - other.z)

    def __mul__(self, other: "Quaternion") -> "Quaternion":
        a, b, c, d = self.w, self.x, self.y, self.z
        e, f, g, h = other.w, other.x, other.y, other.z
        # Hamilton product.
        return Quaternion(
            a * e - b * f - c * g - d * h,
            a * f + b * e + c * h - d * g,
            a * g - b * h + c * e + d * f,
            a * h + b * g - c * f + d * e,
        )

    def conj(self) -> "Quaternion":
        """Quaternionic conjugate (the 'star' antihomomorphism)."""
        return Quaternion(self.w, -self.x, -self.y, -self.z)

    def norm_sq(self) -> float:
        """Squared norm |q|^2 = w^2 + x^2 + y^2 + z^2."""
        return self.w ** 2 + self.x ** 2 + self.y ** 2 + self.z ** 2

    def norm(self) -> float:
        return math.sqrt(self.norm_sq())


def witness(q: Quaternion, r: Quaternion,
            qp: Quaternion, rp: Quaternion) -> Quaternion:
    """The Hermitian inner-product witness lambda = conj(q)q' + conj(r)r'."""
    return q.conj() * qp + r.conj() * rp


def random_quaternion(scale: float = 1.0) -> Quaternion:
    return Quaternion(*(random.uniform(-scale, scale) for _ in range(4)))


def random_unit_quaternion() -> Quaternion:
    while True:
        cand = random_quaternion()
        n = cand.norm()
        if n > 1e-9:
            return Quaternion(cand.w / n, cand.x / n, cand.y / n, cand.z / n)


def random_unit_vector() -> tuple[Quaternion, Quaternion]:
    """A random unit vector (q, r) in H^2 with |q|^2 + |r|^2 = 1."""
    while True:
        q = random_quaternion()
        r = random_quaternion()
        n = math.sqrt(q.norm_sq() + r.norm_sq())
        if n > 1e-9:
            scale = 1.0 / n
            sq = Quaternion(q.w * scale, q.x * scale, q.y * scale, q.z * scale)
            sr = Quaternion(r.w * scale, r.x * scale, r.y * scale, r.z * scale)
            return sq, sr


def demo_unconditional_identity(trials: int = 5) -> None:
    """normSq_identity: an unconditional polynomial identity on all of H^2."""
    print("=" * 70)
    print("1. Unconditional algebraic identity (no unit-norm assumption)")
    print("=" * 70)
    for _ in range(trials):
        q, r = random_quaternion(), random_quaternion()
        qp, rp = random_quaternion(), random_quaternion()
        lam = witness(q, r, qp, rp)
        lhs = (qp - q * lam).norm_sq() + (rp - r * lam).norm_sq()
        rhs = ((qp.norm_sq() + rp.norm_sq())
               - 2 * lam.norm_sq()
               + (q.norm_sq() + r.norm_sq()) * lam.norm_sq())
        print(f"  LHS = {lhs:12.6f}   RHS = {rhs:12.6f}   diff = {abs(lhs - rhs):.2e}")


def demo_distance_identity(trials: int = 5) -> None:
    """dist_sq_eq: |q' - q lam|^2 + |r' - r lam|^2 = 1 - |lam|^2 on the sphere."""
    print("=" * 70)
    print("2. Squared-distance identity on the unit sphere")
    print("=" * 70)
    for _ in range(trials):
        q, r = random_unit_vector()
        qp, rp = random_unit_vector()
        lam = witness(q, r, qp, rp)
        lhs = (qp - q * lam).norm_sq() + (rp - r * lam).norm_sq()
        rhs = 1.0 - lam.norm_sq()
        print(f"  defect = {lhs:12.6f}   1 - |lam|^2 = {rhs:12.6f}   "
              f"diff = {abs(lhs - rhs):.2e}")


def demo_cauchy_schwarz(trials: int = 5) -> None:
    """abs_witness_le_one: |lambda| <= 1 for unit vectors."""
    print("=" * 70)
    print("3. Cauchy-Schwarz bound  |lambda| <= 1")
    print("=" * 70)
    for _ in range(trials):
        q, r = random_unit_vector()
        qp, rp = random_unit_vector()
        lam = witness(q, r, qp, rp)
        print(f"  |lambda| = {lam.norm():.6f}   (<= 1 : {lam.norm() <= 1 + 1e-9})")


def demo_forward(trials: int = 5) -> None:
    """witness_of_proportional: if (q',r') = (q,r)*mu then lambda = mu."""
    print("=" * 70)
    print("4. Forward direction: right multiplication -> witness recovers mu")
    print("=" * 70)
    for _ in range(trials):
        q, r = random_unit_vector()
        mu = random_unit_quaternion()
        qp, rp = q * mu, r * mu
        lam = witness(q, r, qp, rp)
        err = (lam - mu).norm()
        print(f"  |lambda - mu| = {err:.2e}   (should be 0)")


def demo_reconstruction(trials: int = 5) -> None:
    """reconstruct_fibre: |lambda| = 1  =>  q' = q lam, r' = r lam."""
    print("=" * 70)
    print("5. Reconstruction: |lambda| = 1 recovers the second point exactly")
    print("=" * 70)
    for _ in range(trials):
        q, r = random_unit_vector()
        mu = random_unit_quaternion()          # forces |lambda| = 1
        qp, rp = q * mu, r * mu
        lam = witness(q, r, qp, rp)
        e1 = (qp - q * lam).norm()
        e2 = (rp - r * lam).norm()
        print(f"  |lam| = {lam.norm():.4f}   |q' - q lam| = {e1:.2e}   "
              f"|r' - r lam| = {e2:.2e}")


def demo_torsor(trials: int = 3) -> None:
    """fibre_correspondence: mutually-inverse maps between S^3 and the fibre."""
    print("=" * 70)
    print("6. Torsor structure: the fibre through a is a right S^3-torsor")
    print("=" * 70)
    q, r = random_unit_vector()
    for _ in range(trials):
        mu = random_unit_quaternion()
        qp, rp = q * mu, r * mu
        on_sphere = qp.norm_sq() + rp.norm_sq()
        recovered = witness(q, r, qp, rp)
        print(f"  |a*mu|^2 = {on_sphere:.6f} (=1)   "
              f"witness(a, a*mu) - mu = {(recovered - mu).norm():.2e}")


def main() -> None:
    random.seed(2024)
    print("\nQUATERNIONIC HOPF-WITNESS NUMERICAL DEMONSTRATIONS\n")
    demo_unconditional_identity()
    demo_distance_identity()
    demo_cauchy_schwarz()
    demo_forward()
    demo_reconstruction()
    demo_torsor()
    print("\nAll demonstrations complete.\n")


if __name__ == "__main__":
    main()
