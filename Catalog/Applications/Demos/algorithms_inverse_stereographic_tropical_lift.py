#!/usr/bin/env python3
"""
Tropical Stereographic Projection — Core Algorithms

Type-hinted implementations of the tropical max-plus algebra
and tropical Möbius transformation framework.
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Tuple


@dataclass(frozen=True)
class TropMat:
    """A tropical 2×2 matrix [[a, b], [c, d]] over the max-plus semiring."""
    a: float
    b: float
    c: float
    d: float

    def mul(self, other: TropMat) -> TropMat:
        """Tropical (max-plus) matrix multiplication."""
        return TropMat(
            a=max(self.a + other.a, self.b + other.c),
            b=max(self.a + other.b, self.b + other.d),
            c=max(self.c + other.a, self.d + other.c),
            d=max(self.c + other.b, self.d + other.d),
        )

    def act_hom(self, p: Tuple[float, float]) -> Tuple[float, float]:
        """Homogeneous action on tropical projective coordinates (x, y)."""
        x, y = p
        return (max(self.a + x, self.b + y), max(self.c + x, self.d + y))

    def eval(self, t: float) -> float:
        """Affine evaluation: φ_M(t) = max(a+t, b) - max(c+t, d)."""
        return max(self.a + t, self.b) - max(self.c + t, self.d)

    @property
    def trop_det(self) -> float:
        """Tropical determinant: max(a+d, b+c)."""
        return max(self.a + self.d, self.b + self.c)

    @property
    def is_nondeg(self) -> bool:
        """Whether the matrix is non-degenerate (tropical det has unique max)."""
        return self.a + self.d != self.b + self.c

    @property
    def left_break(self) -> float:
        """Left breakpoint of the piecewise-linear evaluation."""
        return min(self.b - self.a, self.d - self.c)

    @property
    def right_break(self) -> float:
        """Right breakpoint of the piecewise-linear evaluation."""
        return max(self.b - self.a, self.d - self.c)

    @property
    def trop_width(self) -> float:
        """Tropical width: length of the active (non-constant) interval."""
        return self.right_break - self.left_break

    def asymptotic_left(self) -> float:
        """Value as t → -∞: b - d."""
        return self.b - self.d

    def asymptotic_right(self) -> float:
        """Value as t → +∞: a - c."""
        return self.a - self.c

    @staticmethod
    def stereo(p: float) -> TropMat:
        """Tropical stereographic projection from pole p."""
        return TropMat(a=0.0, b=0.0, c=0.0, d=p)

    @staticmethod
    def stereo_anti(p: float) -> TropMat:
        """Antipodal stereographic projection."""
        return TropMat(a=p, b=0.0, c=0.0, d=0.0)

    @staticmethod
    def identity_approx(neg_inf: float = -1e15) -> TropMat:
        """Approximate tropical identity (off-diagonal entries ≈ -∞)."""
        return TropMat(a=0.0, b=neg_inf, c=neg_inf, d=0.0)


def verify_representation_theorem(M: TropMat, N: TropMat,
                                   p: Tuple[float, float],
                                   tol: float = 1e-10) -> bool:
    """Verify: actHom(M⊗N, p) = actHom(M, actHom(N, p))."""
    lhs = M.mul(N).act_hom(p)
    rhs = M.act_hom(N.act_hom(p))
    return abs(lhs[0] - rhs[0]) < tol and abs(lhs[1] - rhs[1]) < tol


def verify_boundedness(M: TropMat, t: float, tol: float = 1e-10) -> bool:
    """Verify: min(a-c, b-d) ≤ eval(t) ≤ max(a-c, b-d)."""
    val = M.eval(t)
    lo = min(M.a - M.c, M.b - M.d)
    hi = max(M.a - M.c, M.b - M.d)
    return lo - tol <= val <= hi + tol


def verify_det_supermultiplicativity(M: TropMat, N: TropMat,
                                      tol: float = 1e-10) -> bool:
    """Verify: det(M) + det(N) ≤ det(M⊗N)."""
    return M.trop_det + N.trop_det <= M.mul(N).trop_det + tol


def tropical_stereo_chart(p: float, n_points: int = 100) -> list[Tuple[float, float]]:
    """Compute the tropical stereographic chart φ_p on a grid of points.
    Returns list of (t, φ_p(t)) pairs."""
    M = TropMat.stereo(p)
    lo = M.left_break - 2.0
    hi = M.right_break + 2.0
    ts = [lo + (hi - lo) * i / (n_points - 1) for i in range(n_points)]
    return [(t, M.eval(t)) for t in ts]


if __name__ == "__main__":
    # Quick self-test
    M = TropMat(1.0, 2.0, 0.0, 3.0)
    N = TropMat(2.0, 0.0, 1.0, 1.0)

    for x, y in [(1.0, 0.0), (0.0, 1.0), (-1.0, 2.0)]:
        assert verify_representation_theorem(M, N, (x, y)), \
            f"Representation theorem failed for p=({x},{y})"

    import numpy as np
    for t in np.linspace(-10, 10, 100):
        assert verify_boundedness(M, t), f"Boundedness failed at t={t}"

    assert verify_det_supermultiplicativity(M, N), "Det super-multiplicativity failed"

    S = TropMat.stereo(3.0)
    assert abs(S.trop_width - 3.0) < 1e-10, f"Stereo width failed: {S.trop_width}"

    print("All self-tests passed!")
