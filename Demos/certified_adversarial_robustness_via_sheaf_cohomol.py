#!/usr/bin/env python3
"""Numerical demonstrations for cohomology, vulnerability, and robustness.

The examples illustrate three exact mathematical facts:
1. every edge cochain c is the coboundary of the section (0, c);
2. the threshold score t -> t has the adversarial witness r/2 at every r > 0;
3. an affine score is L-infinity certified whenever ||w||_1 * r < margin.

Only the Python standard library is required.
"""

from __future__ import annotations

from dataclasses import dataclass
from math import inf
from typing import Callable, Iterable, Sequence

Vector = tuple[float, ...]


def decision(score: Callable[[Vector], float], x: Vector) -> bool:
    """Return True exactly when the score is strictly positive."""
    return score(x) > 0.0


def linf_distance(x: Sequence[float], y: Sequence[float]) -> float:
    """Compute the L-infinity distance between equally sized vectors."""
    if len(x) != len(y):
        raise ValueError("vectors must have equal dimensions")
    return max((abs(a - b) for a, b in zip(x, y)), default=0.0)


def edge_coboundary(section: tuple[float, float]) -> float:
    """Compute delta(a,b) = b-a for the oriented one-edge complex."""
    a, b = section
    return b - a


def section_for_cochain(c: float) -> tuple[float, float]:
    """Return the explicit preimage (0,c) proving coboundary surjectivity."""
    return (0.0, c)


def threshold_witness(radius: float) -> float:
    """Return r/2, an adversarial point for f(t)=t at zero."""
    if radius <= 0.0:
        raise ValueError("radius must be positive")
    return radius / 2.0


@dataclass(frozen=True)
class AffineCertificate:
    """Certificate data for an affine score in the L-infinity threat model."""

    score_at_x: float
    lipschitz_linf: float
    radius_supremum: float

    def certifies(self, radius: float) -> bool:
        """Check the strict sufficient inequality for a proposed radius."""
        return radius >= 0.0 and self.lipschitz_linf * radius < self.score_at_x


def affine_score(weights: Sequence[float], bias: float, x: Sequence[float]) -> float:
    """Evaluate b + w dot x."""
    if len(weights) != len(x):
        raise ValueError("weights and input must have equal dimensions")
    return bias + sum(w * xi for w, xi in zip(weights, x))


def affine_positive_certificate(
    weights: Sequence[float], bias: float, x: Sequence[float]
) -> AffineCertificate | None:
    """Compute the exact positive-class margin/Lipschitz radius threshold.

    Returns None when the center is not in the positive class. If the score is
    positive and all weights vanish, radius_supremum is infinity. Otherwise,
    every strict radius below score_at_x / sum(abs(w_i)) is certified.
    """
    score_x = affine_score(weights, bias, x)
    if score_x <= 0.0:
        return None
    lipschitz = sum(abs(w) for w in weights)
    radius_supremum = inf if lipschitz == 0.0 else score_x / lipschitz
    return AffineCertificate(score_x, lipschitz, radius_supremum)


def box_corners(center: Sequence[float], radius: float) -> Iterable[Vector]:
    """Generate corners of a closed L-infinity box without dependencies."""
    if radius < 0.0:
        raise ValueError("radius must be nonnegative")
    corners: list[Vector] = [tuple()]
    for coordinate in center:
        corners = [
            prefix + (coordinate + sign * radius,)
            for prefix in corners
            for sign in (-1.0, 1.0)
        ]
    return corners


def run_demo() -> None:
    """Print reproducible demonstrations of all key results."""
    print("1. Surjectivity of the one-edge coboundary")
    for c in (-3.5, 0.0, 2.25, 10.0):
        section = section_for_cochain(c)
        print(f"   c={c:8g}, section={section}, delta(section)={edge_coboundary(section):8g}")

    print("\n2. Threshold vulnerability at every tested positive scale")
    for radius in (1.0, 0.1, 1e-6):
        witness = threshold_witness(radius)
        inside = abs(witness) < radius
        center_label = 0.0 > 0.0
        witness_label = witness > 0.0
        print(
            f"   r={radius:g}, y=r/2={witness:g}, |y|<r={inside}, "
            f"label flip={center_label != witness_label}"
        )

    print("\n3. Margin-Lipschitz certificate for an affine score")
    weights = (0.4, -0.7)
    bias = 1.2
    center = (0.0, 0.0)
    certificate = affine_positive_certificate(weights, bias, center)
    assert certificate is not None
    print(
        f"   score at center={certificate.score_at_x:g}, "
        f"L=||w||_1={certificate.lipschitz_linf:g}, "
        f"radius threshold={certificate.radius_supremum:.8f}"
    )
    for radius in (0.5, 1.0, 1.1):
        sufficient = certificate.certifies(radius)
        corner_scores = [affine_score(weights, bias, p) for p in box_corners(center, radius)]
        print(
            f"   r={radius:g}: L*r<m is {sufficient}; "
            f"minimum corner score={min(corner_scores):.6f}"
        )

    print("\nFinite tests illustrate the formulas; the associated theorems quantify over every point.")


if __name__ == "__main__":
    run_demo()
