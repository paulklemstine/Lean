#!/usr/bin/env python3
"""Numerical demonstrations for Wilson's one-loop epsilon expansion.

The program uses only Python's standard library. It evaluates the two fixed
points, verifies their beta-function residuals, computes the two-loop anomalous
dimension in two equivalent ways, audits an illustrative cubic remainder, and
writes two SVG plots when run as a script.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Callable, Iterable, Sequence


@dataclass(frozen=True)
class RGPoint:
    """Computed data for one dimension value."""

    dimension: float
    epsilon: float
    gaussian: float
    wilson_fisher: float
    beta_at_gaussian: float
    beta_at_wilson_fisher: float
    eta_from_coupling: float
    eta_from_epsilon: float
    linearized_slope: float


def beta(epsilon: float, coupling: float) -> float:
    """Return the one-loop beta function -epsilon*g + 3*g^2."""
    return -epsilon * coupling + 3.0 * coupling**2


def wilson_fisher(epsilon: float) -> float:
    """Return the non-Gaussian fixed-point coupling epsilon/3."""
    return epsilon / 3.0


def eta_of_coupling(coupling: float) -> float:
    """Return the two-loop anomalous dimension g^2/6."""
    return coupling**2 / 6.0


def eta_epsilon(epsilon: float) -> float:
    """Return the fixed-point expression epsilon^2/54."""
    return epsilon**2 / 54.0


def sunset_weight_sum() -> float:
    """Sum the two equal diagram weights 1/108."""
    return sum((1.0 / 108.0, 1.0 / 108.0))


def analyze_dimension(dimension: float) -> RGPoint:
    """Compute all key truncated-flow quantities for one dimension."""
    epsilon = 4.0 - dimension
    interacting = wilson_fisher(epsilon)
    return RGPoint(
        dimension=dimension,
        epsilon=epsilon,
        gaussian=0.0,
        wilson_fisher=interacting,
        beta_at_gaussian=beta(epsilon, 0.0),
        beta_at_wilson_fisher=beta(epsilon, interacting),
        eta_from_coupling=eta_of_coupling(interacting),
        eta_from_epsilon=eta_epsilon(epsilon),
        linearized_slope=-epsilon + 6.0 * interacting,
    )


def audit_remainder_bound(
    remainder: Callable[[float], float],
    constant: float,
    delta: float,
    samples: Iterable[float],
    tolerance: float = 1e-15,
) -> list[tuple[float, float, float, bool]]:
    """Audit |r(epsilon)| <= C|epsilon|^3 on supplied interior samples.

    This is a numerical illustration, not a proof over the full interval.
    """
    if constant <= 0.0 or delta <= 0.0:
        raise ValueError("constant and delta must both be positive")
    rows: list[tuple[float, float, float, bool]] = []
    for epsilon in samples:
        if abs(epsilon) >= delta:
            raise ValueError("every sample must satisfy |epsilon| < delta")
        observed = abs(remainder(epsilon))
        bound = constant * abs(epsilon) ** 3
        rows.append((epsilon, observed, bound, observed <= bound + tolerance))
    return rows


def _polyline_svg(
    series: Sequence[tuple[str, str, Callable[[float], float]]],
    x_min: float,
    x_max: float,
    y_min: float,
    y_max: float,
    title: str,
    x_label: str,
    y_label: str,
    output: Path,
) -> None:
    """Write a dependency-free SVG line chart."""
    width, height, margin = 800, 500, 70
    plot_w, plot_h = width - 2 * margin, height - 2 * margin

    def sx(x: float) -> float:
        return margin + (x - x_min) * plot_w / (x_max - x_min)

    def sy(y: float) -> float:
        return height - margin - (y - y_min) * plot_h / (y_max - y_min)

    parts = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">',
        '<rect width="100%" height="100%" fill="#fbfaf7"/>',
        f'<text x="{width/2}" y="30" text-anchor="middle" font-family="serif" font-size="22">{title}</text>',
        f'<line x1="{margin}" y1="{sy(0)}" x2="{width-margin}" y2="{sy(0)}" stroke="#555"/>',
        f'<line x1="{sx(0)}" y1="{margin}" x2="{sx(0)}" y2="{height-margin}" stroke="#555"/>',
        f'<text x="{width/2}" y="{height-15}" text-anchor="middle" font-family="sans-serif">{x_label}</text>',
        f'<text x="18" y="{height/2}" text-anchor="middle" transform="rotate(-90 18 {height/2})" font-family="sans-serif">{y_label}</text>',
    ]
    for index, (name, color, function) in enumerate(series):
        points = []
        for step in range(241):
            x = x_min + (x_max - x_min) * step / 240.0
            points.append(f"{sx(x):.2f},{sy(function(x)):.2f}")
        parts.append(f'<polyline fill="none" stroke="{color}" stroke-width="3" points="{" ".join(points)}"/>')
        parts.append(
            f'<text x="{width-margin-170}" y="{55+22*index}" fill="{color}" '
            f'font-family="sans-serif" font-size="14">{name}</text>'
        )
    parts.append("</svg>")
    output.write_text("\n".join(parts), encoding="utf-8")


def generate_visualizations(directory: Path = Path(".")) -> tuple[Path, Path]:
    """Generate SVG plots of the beta flow and epsilon expansion."""
    directory.mkdir(parents=True, exist_ok=True)
    beta_path = directory / "beta_flow.svg"
    eta_path = directory / "eta_expansion.svg"
    epsilon = 1.0
    _polyline_svg(
        [("beta(1,g)", "#6b3fa0", lambda g: beta(epsilon, g))],
        -0.2,
        0.55,
        -0.09,
        0.4,
        "One-loop beta function at epsilon = 1",
        "coupling g",
        "beta",
        beta_path,
    )
    _polyline_svg(
        [
            ("epsilon^2 / 54", "#006d77", eta_epsilon),
            ("leading + 0.02 epsilon^3", "#e76f51", lambda e: eta_epsilon(e) + 0.02 * e**3),
        ],
        -1.0,
        1.0,
        -0.005,
        0.04,
        "Leading anomalous dimension and a cubic correction",
        "epsilon",
        "eta",
        eta_path,
    )
    return beta_path, eta_path


def main() -> None:
    """Print numerical demonstrations and generate SVG figures."""
    dimensions = (3.9, 3.5, 3.0, 4.0, 5.0)
    print("Wilson epsilon-expansion data")
    print(" d      epsilon       g_*         beta(g_*)       eta          slope")
    for dimension in dimensions:
        row = analyze_dimension(dimension)
        assert abs(row.eta_from_coupling - row.eta_from_epsilon) < 1e-14
        print(
            f"{row.dimension:4.1f}  {row.epsilon:9.5f}  "
            f"{row.wilson_fisher:10.6f}  {row.beta_at_wilson_fisher:13.3e}  "
            f"{row.eta_from_epsilon:11.8f}  {row.linearized_slope:8.4f}"
        )

    print(f"\nTwo sunset weights sum to {sunset_weight_sum():.12f}; 1/54 = {1/54:.12f}")
    print("At epsilon=3 the distinct zeros are g=0 and g=1:", beta(3.0, 0.0), beta(3.0, 1.0))
    print("At epsilon=-3 the Wilson-Fisher value is", wilson_fisher(-3.0))

    remainder = lambda epsilon: 0.2 * epsilon**3
    samples = (-0.5, -0.1, -0.01, 0.0, 0.01, 0.1, 0.5)
    audit = audit_remainder_bound(remainder, 0.2, 1.0, samples)
    print("\nCubic remainder audit: epsilon, |r|, C|epsilon|^3, passes")
    for row in audit:
        print(f"{row[0]:7.3f}  {row[1]:12.5e}  {row[2]:12.5e}  {row[3]}")
    assert all(row[3] for row in audit)

    beta_path, eta_path = generate_visualizations()
    print(f"\nWrote {beta_path} and {eta_path}")


if __name__ == "__main__":
    main()
