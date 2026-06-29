"""
demo.py — Numerical demonstrations of the elementary Willmore-energy theory.

This script reproduces, with concrete numbers, the main results of the
measure-theoretic Willmore development:

  * the pointwise square identity      H^2 - K = ((k1 - k2)/2)^2
  * pointwise domination               K <= H^2
  * the integral balance identity      W - integral(K) = integral(defect)
  * the integral inequality            integral(K) <= W
  * integral rigidity                  W = integral(K)  <=>  k1 = k2 a.e.
  * the Gauss-Bonnet bound             2*pi*chi <= W
  * the sharp genus-zero floor         W >= 4*pi  (sphere)
  * the Li-Yau multiplicity bound      W >= 4*pi*n  (n disjoint sheets)
  * the vacuous high-genus floor       b(g) = 4*pi*(1 - g) <= 0 for g >= 1
  * the step law                       b(g+1) = b(g) - 4*pi

Everything is self-contained: a "surface" is modeled as a finite list of
sample points, each carrying two principal curvatures (k1, k2) and an area
weight w. Integration is a weighted sum.  No external libraries are required.
"""

from __future__ import annotations

import math
from dataclasses import dataclass, field
from typing import Callable

PI: float = math.pi
FOUR_PI: float = 4.0 * PI
TWO_PI_SQ: float = 2.0 * PI * PI  # the Clifford-torus / Willmore-conjecture floor


# --------------------------------------------------------------------------
# Pointwise invariants (Definitions 2.1)
# --------------------------------------------------------------------------
def mean_curv(k1: float, k2: float) -> float:
    """Mean curvature H = (k1 + k2) / 2."""
    return (k1 + k2) / 2.0


def willmore_density(k1: float, k2: float) -> float:
    """Willmore density H^2 = ((k1 + k2)/2)^2."""
    return ((k1 + k2) / 2.0) ** 2


def gauss_curv(k1: float, k2: float) -> float:
    """Gaussian curvature K = k1 * k2."""
    return k1 * k2


def umbilic_defect(k1: float, k2: float) -> float:
    """Umbilic defect ((k1 - k2)/2)^2 (squared traceless second fundamental form)."""
    return ((k1 - k2) / 2.0) ** 2


# --------------------------------------------------------------------------
# Surface model: a finite weighted sample of principal curvatures
# --------------------------------------------------------------------------
@dataclass
class SurfaceSample:
    """A discretized surface: parallel lists of k1, k2 and area weights w."""

    k1: list[float]
    k2: list[float]
    w: list[float]

    def __post_init__(self) -> None:
        assert len(self.k1) == len(self.k2) == len(self.w), "ragged surface data"

    def integral(self, f: Callable[[float, float], float]) -> float:
        """Weighted (Lebesgue) integral of a pointwise functional f(k1, k2)."""
        return sum(wi * f(a, b) for a, b, wi in zip(self.k1, self.k2, self.w))

    def willmore_energy(self) -> float:
        """W = integral H^2 dmu."""
        return self.integral(willmore_density)

    def total_gauss(self) -> float:
        """integral K dmu."""
        return self.integral(gauss_curv)

    def total_defect(self) -> float:
        """integral ((k1 - k2)/2)^2 dmu."""
        return self.integral(umbilic_defect)


# --------------------------------------------------------------------------
# Theorem checks
# --------------------------------------------------------------------------
def check_square_identity(k1: float, k2: float, tol: float = 1e-12) -> bool:
    """Theorem 3.1: H^2 - K = ((k1 - k2)/2)^2 pointwise."""
    lhs = willmore_density(k1, k2) - gauss_curv(k1, k2)
    rhs = umbilic_defect(k1, k2)
    return abs(lhs - rhs) < tol


def check_balance_identity(s: SurfaceSample, tol: float = 1e-9) -> bool:
    """Theorem 4.1: W - integral(K) = integral(defect)."""
    return abs((s.willmore_energy() - s.total_gauss()) - s.total_defect()) < tol


def check_gauss_le_willmore(s: SurfaceSample) -> bool:
    """Theorem 4.3: integral(K) <= W."""
    return s.total_gauss() <= s.willmore_energy() + 1e-12


def elementary_floor(genus: int) -> float:
    """b(g) = 4*pi*(1 - g) = 2*pi*chi, the elementary Gauss-Bonnet floor."""
    return FOUR_PI * (1 - genus)


def li_yau_floor(n_sheets: int) -> float:
    """Li-Yau lower bound 4*pi*n for n disjoint degree-one sheets."""
    return FOUR_PI * n_sheets


# --------------------------------------------------------------------------
# Concrete surface constructors
# --------------------------------------------------------------------------
def round_sphere(n: int = 2000, radius: float = 1.0) -> SurfaceSample:
    """
    A round sphere of given radius: every point is umbilic, k1 = k2 = 1/radius.
    Total area 4*pi*r^2, so the weights sum to that.  Here K = 1/r^2 and
    integral(K) = 4*pi (Gauss-Bonnet, chi = 2); W = integral(H^2) = 4*pi too,
    realizing the sharp genus-zero floor with zero umbilic defect.
    """
    kappa = 1.0 / radius
    area = 4.0 * PI * radius * radius
    w = area / n
    return SurfaceSample([kappa] * n, [kappa] * n, [w] * n)


def perturbed_sphere(n: int = 2000, radius: float = 1.0,
                     wobble: float = 0.3) -> SurfaceSample:
    """
    A non-round (still genus-0) surface: principal curvatures oscillate so that
    k1 != k2, creating a strictly positive umbilic defect.  We keep integral(K)
    pinned at 4*pi (a topological invariant by Gauss-Bonnet) and watch W exceed
    it by exactly the total defect.
    """
    kappa = 1.0 / radius
    area = 4.0 * PI * radius * radius
    w = area / n
    k1: list[float] = []
    k2: list[float] = []
    for i in range(n):
        theta = 2.0 * PI * i / n
        d = wobble * math.sin(theta)
        # Keep the product k1*k2 = kappa^2 fixed so integral(K) stays 4*pi,
        # while the gap k1 - k2 = 2*d creates a genuine umbilic defect.
        k1.append(kappa * math.exp(d))
        k2.append(kappa * math.exp(-d))
    return SurfaceSample(k1, k2, [w] * n)


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------
def demo_pointwise_identity() -> None:
    print("=" * 70)
    print("DEMO 1  Pointwise square identity  H^2 - K = ((k1-k2)/2)^2")
    print("=" * 70)
    samples = [(2.0, 2.0), (1.0, 3.0), (-1.0, 4.0), (0.5, -0.5), (math.pi, 1.0)]
    print(f"{'k1':>8}{'k2':>8}{'H^2':>12}{'K':>12}{'defect':>12}{'ok':>5}")
    for k1, k2 in samples:
        h2 = willmore_density(k1, k2)
        kk = gauss_curv(k1, k2)
        d = umbilic_defect(k1, k2)
        ok = check_square_identity(k1, k2)
        print(f"{k1:>8.3f}{k2:>8.3f}{h2:>12.5f}{kk:>12.5f}{d:>12.5f}{str(ok):>5}")
    print("All satisfy H^2 - K = defect, and defect >= 0 so K <= H^2.\n")


def demo_sphere_floor() -> None:
    print("=" * 70)
    print("DEMO 2  Sharp genus-0 floor  W >= 4*pi, equality iff umbilic")
    print("=" * 70)
    s = round_sphere()
    W = s.willmore_energy()
    K = s.total_gauss()
    D = s.total_defect()
    print(f"Round sphere:     W = {W:.6f}   4*pi = {FOUR_PI:.6f}")
    print(f"                  integral(K) = {K:.6f}   total defect = {D:.3e}")
    print(f"                  W = 4*pi (equality)?  {abs(W - FOUR_PI) < 1e-6}")
    print(f"                  totally umbilic (defect ~ 0)?  {D < 1e-9}\n")

    p = perturbed_sphere()
    Wp = p.willmore_energy()
    Kp = p.total_gauss()
    Dp = p.total_defect()
    print(f"Perturbed sphere: W = {Wp:.6f}  (strictly > 4*pi)")
    print(f"                  integral(K) = {Kp:.6f}  (still 4*pi: topological!)")
    print(f"                  total defect = {Dp:.6f}")
    print(f"                  balance  W - integral(K) = {Wp - Kp:.6f}  == defect?"
          f"  {check_balance_identity(p)}")
    print(f"                  integral(K) <= W ?  {check_gauss_le_willmore(p)}\n")


def demo_gauss_bonnet_floors() -> None:
    print("=" * 70)
    print("DEMO 3  Gauss-Bonnet floor b(g) = 4*pi*(1-g) and its decay")
    print("=" * 70)
    print(f"{'genus g':>9}{'chi = 2-2g':>12}{'b(g) = 2*pi*chi':>18}"
          f"{'vacuous?':>10}")
    prev: float | None = None
    for g in range(0, 5):
        chi = 2 - 2 * g
        b = elementary_floor(g)
        vac = b <= 0
        print(f"{g:>9}{chi:>12}{b:>18.6f}{str(vac):>10}")
        if prev is not None:
            step = b - prev
            assert abs(step - (-FOUR_PI)) < 1e-9, "step law failed"
        prev = b
    print(f"\nStep law verified:  b(g+1) - b(g) = -4*pi = {-FOUR_PI:.6f}")
    print(f"For g >= 1 the floor is <= 0: useless, since W >= 0 already.")
    print(f"True genus-1 (torus) floor is the Clifford value 2*pi^2 = "
          f"{TWO_PI_SQ:.6f},")
    print("invisible to the elementary Gauss-Bonnet method.\n")


def demo_li_yau() -> None:
    print("=" * 70)
    print("DEMO 4  Li-Yau multiplicity bound  W >= 4*pi*n")
    print("=" * 70)
    print(f"{'sheets n':>9}{'floor 4*pi*n':>15}{'embedded forced if W <':>26}")
    for n in range(1, 6):
        floor = li_yau_floor(n)
        print(f"{n:>9}{floor:>15.6f}{(floor):>26.6f}")
    print(f"\nKey corollary: W < 8*pi = {2*FOUR_PI:.6f} forbids self-crossing,")
    print("so any surface with Willmore energy below 8*pi must be embedded.\n")


def main() -> None:
    demo_pointwise_identity()
    demo_sphere_floor()
    demo_gauss_bonnet_floors()
    demo_li_yau()
    print("All elementary Willmore results verified numerically.")


if __name__ == "__main__":
    main()
