#!/usr/bin/env python3
"""Numerical illustrations of self-dual crossing functions.

The odd-majority event is a finite Bernoulli model whose probability C_n obeys
C_n(1-p) = 1-C_n(p).  This script prints paired values, checks the centered
antisymmetry residual, locates the fair parameter by bisection, and optionally
writes a dependency-free SVG visualization.
"""

from __future__ import annotations

from math import comb
from pathlib import Path
from typing import Iterable


def majority_crossing_probability(n: int, p: float) -> float:
    """Return the probability of a strict majority among n odd Bernoulli trials."""
    if n <= 0 or n % 2 == 0:
        raise ValueError("n must be a positive odd integer")
    if not 0.0 <= p <= 1.0:
        raise ValueError("p must lie in [0, 1]")
    threshold = n // 2 + 1
    return sum(comb(n, k) * p**k * (1.0 - p) ** (n - k)
               for k in range(threshold, n + 1))


def self_duality_residual(n: int, p: float) -> float:
    """Return C_n(p) + C_n(1-p) - 1, which is exactly zero algebraically."""
    return (majority_crossing_probability(n, p)
            + majority_crossing_probability(n, 1.0 - p) - 1.0)


def fair_parameter_bisection(n: int, tolerance: float = 1e-12) -> float:
    """Numerically solve C_n(p)=1/2 for the strictly increasing majority model."""
    if tolerance <= 0.0:
        raise ValueError("tolerance must be positive")
    low, high = 0.0, 1.0
    while high - low > tolerance:
        mid = (low + high) / 2.0
        if majority_crossing_probability(n, mid) < 0.5:
            low = mid
        else:
            high = mid
    return (low + high) / 2.0


def make_svg(ns: Iterable[int] = (1, 3, 5, 11), samples: int = 201) -> str:
    """Create an SVG of self-dual odd-majority curves without third-party packages."""
    width, height, margin = 760, 480, 55
    colors = ("#2563eb", "#7c3aed", "#db2777", "#ea580c")
    ns_tuple = tuple(ns)
    def xy(p: float, value: float) -> tuple[float, float]:
        return (margin + p * (width - 2 * margin),
                height - margin - value * (height - 2 * margin))
    pieces = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">',
        '<rect width="100%" height="100%" fill="#fafafa"/>',
        f'<line x1="{margin}" y1="{height-margin}" x2="{width-margin}" y2="{height-margin}" stroke="#111827"/>',
        f'<line x1="{margin}" y1="{margin}" x2="{margin}" y2="{height-margin}" stroke="#111827"/>',
    ]
    xmid, ymid = xy(0.5, 0.5)
    pieces += [
        f'<line x1="{xmid}" y1="{margin}" x2="{xmid}" y2="{height-margin}" stroke="#94a3b8" stroke-dasharray="5 5"/>',
        f'<line x1="{margin}" y1="{ymid}" x2="{width-margin}" y2="{ymid}" stroke="#94a3b8" stroke-dasharray="5 5"/>',
        f'<circle cx="{xmid}" cy="{ymid}" r="5" fill="#111827"/>',
        f'<text x="{xmid+8}" y="{ymid-8}" font-family="sans-serif" font-size="13">(1/2, 1/2)</text>',
        f'<text x="{width/2}" y="{height-12}" text-anchor="middle" font-family="sans-serif">parameter p</text>',
        f'<text x="18" y="{height/2}" text-anchor="middle" transform="rotate(-90 18 {height/2})" font-family="sans-serif">crossing probability</text>',
    ]
    for index, n in enumerate(ns_tuple):
        points = []
        for i in range(samples):
            p = i / (samples - 1)
            x, y = xy(p, majority_crossing_probability(n, p))
            points.append(f"{x:.2f},{y:.2f}")
        color = colors[index % len(colors)]
        pieces.append(f'<polyline points="{" ".join(points)}" fill="none" stroke="{color}" stroke-width="2.5"/>')
        pieces.append(f'<text x="{width-145}" y="{30+20*index}" fill="{color}" font-family="sans-serif" font-size="14">n = {n}</text>')
    pieces.append('</svg>')
    return "\n".join(pieces)


def main() -> None:
    """Print numerical checks and write self_duality_curves.svg."""
    ns = (1, 3, 5, 11, 21)
    parameters = (0.1, 0.25, 0.4, 0.5, 0.6, 0.75, 0.9)
    print("Odd-majority crossing probabilities")
    print("n   p       C_n(p)         C_n(1-p)       residual")
    for n in ns:
        for p in parameters:
            value = majority_crossing_probability(n, p)
            dual = majority_crossing_probability(n, 1.0 - p)
            residual = value + dual - 1.0
            print(f"{n:2d}  {p:0.2f}   {value:0.10f}   {dual:0.10f}   {residual:+.2e}")
        root = fair_parameter_bisection(n)
        print(f"     fair parameter by bisection: {root:.12f}\n")
    output = Path("self_duality_curves.svg")
    output.write_text(make_svg(), encoding="utf-8")
    print(f"Wrote {output}")


if __name__ == "__main__":
    main()
