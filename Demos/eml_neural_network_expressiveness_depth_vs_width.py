#!/usr/bin/env python3
"""Numerical exploration of a smooth inverse-square quadratic approximant.

The script uses only Python's standard library.  It evaluates

    Q_w(x) = 2 / h**2 * (exp(h*x) - 1 - h*x),  h = 1 / w**2,

with cancellation-aware series formulas, compares sampled errors with the
uniform certificate 4/(9*w**2), reports derivative errors, and optionally
writes an SVG visualization.
"""

from __future__ import annotations

import argparse
import math
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, Sequence


@dataclass(frozen=True)
class WidthReport:
    """Sampled diagnostics for one positive width index."""

    width: int
    max_value_error: float
    maximizing_x: float
    certified_bound: float
    inverse_linear_benchmark: float
    max_derivative_error: float
    scaled_value_error: float


def _second_exponential_remainder(z: float) -> float:
    """Return exp(z) - 1 - z accurately for the small nonnegative z used here."""
    if abs(z) >= 1.0e-4:
        return math.expm1(z) - z
    # Direct subtraction from expm1 eventually loses the z**2 signal.
    term = 0.5 * z * z
    total = term
    k = 2
    while k < 80:
        k += 1
        term *= z / k
        updated = total + term
        if updated == total:
            break
        total = updated
    return total


def quadratic_approximant(width: int, x: float) -> float:
    """Evaluate the width-indexed smooth approximant Q_w(x)."""
    if width < 1:
        raise ValueError("width must be a positive integer")
    h = 1.0 / (width * width)
    z = h * x
    return 2.0 * _second_exponential_remainder(z) / (h * h)


def quadratic_approximant_derivative(width: int, x: float) -> float:
    """Evaluate Q_w'(x) = 2 expm1(h*x) / h stably."""
    if width < 1:
        raise ValueError("width must be a positive integer")
    h = 1.0 / (width * width)
    return 2.0 * math.expm1(h * x) / h


def certified_bound(width: int) -> float:
    """Return the proved uniform value-error certificate 4/(9 w^2)."""
    if width < 1:
        raise ValueError("width must be a positive integer")
    return 4.0 / (9.0 * width * width)


def inverse_linear_benchmark(width: int) -> float:
    """Return the matched inverse-linear comparison value 4/(9 w)."""
    if width < 1:
        raise ValueError("width must be a positive integer")
    return 4.0 / (9.0 * width)


def sample_report(width: int, samples: int = 4001) -> WidthReport:
    """Sample value and derivative errors on an equally spaced grid in [0, 1]."""
    if samples < 2:
        raise ValueError("samples must be at least 2")
    max_value_error = -1.0
    maximizing_x = 0.0
    max_derivative_error = -1.0
    for index in range(samples):
        x = index / (samples - 1)
        value_error = abs(quadratic_approximant(width, x) - x * x)
        derivative_error = abs(quadratic_approximant_derivative(width, x) - 2.0 * x)
        if value_error > max_value_error:
            max_value_error = value_error
            maximizing_x = x
        max_derivative_error = max(max_derivative_error, derivative_error)
    return WidthReport(
        width=width,
        max_value_error=max_value_error,
        maximizing_x=maximizing_x,
        certified_bound=certified_bound(width),
        inverse_linear_benchmark=inverse_linear_benchmark(width),
        max_derivative_error=max_derivative_error,
        scaled_value_error=width * width * max_value_error,
    )


def print_reports(widths: Iterable[int], samples: int) -> None:
    """Print a compact table of sampled diagnostics."""
    header = (
        " width | sampled max error | at x   | certificate  | inverse-linear | "
        "w^2*error | max slope error"
    )
    print(header)
    print("-" * len(header))
    for width in widths:
        report = sample_report(width, samples)
        print(
            f"{report.width:6d} | {report.max_value_error:17.10e} | "
            f"{report.maximizing_x:6.3f} | {report.certified_bound:12.5e} | "
            f"{report.inverse_linear_benchmark:14.5e} | "
            f"{report.scaled_value_error:9.6f} | "
            f"{report.max_derivative_error:15.8e}"
        )
        # This assertion checks the sampled implementation against the certificate.
        assert report.max_value_error <= report.certified_bound * (1.0 + 1.0e-10)


def write_svg(widths: Sequence[int], output: Path, points: int = 401) -> None:
    """Write a dependency-free SVG showing curves and absolute-error profiles."""
    if not widths:
        raise ValueError("at least one width is required")
    colors = ["#0ea5e9", "#8b5cf6", "#f97316", "#10b981", "#e11d48"]
    canvas_w, canvas_h = 1000, 640
    left, right, top, bottom = 75, 35, 55, 65
    plot_w = canvas_w - left - right
    panel_h = 220

    def px(x: float) -> float:
        return left + x * plot_w

    def py_curve(y: float) -> float:
        return top + panel_h * (1.05 - y) / 1.05

    max_bound = max(certified_bound(w) for w in widths)
    error_top = top + panel_h + 90

    def py_error(error: float) -> float:
        return error_top + panel_h * (1.0 - error / max_bound)

    def polyline(coords: list[tuple[float, float]], color: str, width: float = 2.2) -> str:
        points_text = " ".join(f"{x:.2f},{y:.2f}" for x, y in coords)
        return f'<polyline points="{points_text}" fill="none" stroke="{color}" stroke-width="{width}"/>'

    xs = [i / (points - 1) for i in range(points)]
    elements = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{canvas_w}" height="{canvas_h}" viewBox="0 0 {canvas_w} {canvas_h}">',
        '<rect width="100%" height="100%" fill="#f8fafc"/>',
        '<style>text{font-family:system-ui,sans-serif;fill:#0f172a}.small{font-size:13px}.title{font-size:22px;font-weight:700}</style>',
        '<text x="75" y="32" class="title">Smooth quadratic approximation and certified errors</text>',
        f'<line x1="{left}" y1="{py_curve(0)}" x2="{canvas_w-right}" y2="{py_curve(0)}" stroke="#94a3b8"/>',
        f'<line x1="{left}" y1="{top}" x2="{left}" y2="{top+panel_h}" stroke="#94a3b8"/>',
        '<text x="16" y="72" class="small">value</text>',
    ]
    target = [(px(x), py_curve(x * x)) for x in xs]
    elements.append(polyline(target, "#0f172a", 3.0))
    legend_y = 64
    elements.append(f'<text x="{canvas_w-210}" y="{legend_y}" class="small">target x²</text>')
    for idx, width in enumerate(widths):
        color = colors[idx % len(colors)]
        curve = [(px(x), py_curve(quadratic_approximant(width, x))) for x in xs]
        elements.append(polyline(curve, color))
        legend_y += 20
        elements.append(f'<text x="{canvas_w-210}" y="{legend_y}" class="small" fill="{color}">Q, w={width}</text>')

    elements.extend([
        f'<line x1="{left}" y1="{error_top+panel_h}" x2="{canvas_w-right}" y2="{error_top+panel_h}" stroke="#94a3b8"/>',
        f'<line x1="{left}" y1="{error_top}" x2="{left}" y2="{error_top+panel_h}" stroke="#94a3b8"/>',
        f'<text x="16" y="{error_top+15}" class="small">absolute</text>',
        f'<text x="16" y="{error_top+31}" class="small">error</text>',
    ])
    for idx, width in enumerate(widths):
        color = colors[idx % len(colors)]
        errors = [(px(x), py_error(abs(quadratic_approximant(width, x) - x * x))) for x in xs]
        elements.append(polyline(errors, color))
        bound_y = py_error(certified_bound(width))
        elements.append(
            f'<line x1="{left}" y1="{bound_y:.2f}" x2="{canvas_w-right}" y2="{bound_y:.2f}" '
            f'stroke="{color}" stroke-width="1" stroke-dasharray="6 5" opacity="0.65"/>'
        )
    elements.extend([
        f'<text x="{canvas_w/2-15}" y="{canvas_h-20}" class="small">x</text>',
        f'<text x="{left}" y="{canvas_h-20}" class="small">0</text>',
        f'<text x="{canvas_w-right-8}" y="{canvas_h-20}" class="small">1</text>',
        '</svg>',
    ])
    output.write_text("\n".join(elements), encoding="utf-8")


def parse_widths(raw: str) -> list[int]:
    """Parse a comma-separated list of positive widths."""
    widths = [int(item.strip()) for item in raw.split(",") if item.strip()]
    if not widths or any(width < 1 for width in widths):
        raise argparse.ArgumentTypeError("widths must be positive comma-separated integers")
    return widths


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--widths", type=parse_widths, default=[1, 2, 4, 8, 16, 32])
    parser.add_argument("--samples", type=int, default=4001)
    parser.add_argument("--svg", type=Path, default=None, help="optional SVG output path")
    args = parser.parse_args()
    print_reports(args.widths, args.samples)
    if args.svg is not None:
        write_svg(args.widths[:5], args.svg)
        print(f"\nWrote visualization to {args.svg}")


if __name__ == "__main__":
    main()
