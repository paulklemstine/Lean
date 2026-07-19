#!/usr/bin/env python3
"""Numerical demonstrations for finite Collatz exponential sums.

The script uses only the Python standard library. It compares direct and
parity-reduced evaluation, probes irrational frequencies approaching zero,
checks the universal triangle bound on a grid, compares odd multipliers
3, 5, and 7, and optionally writes an SVG resonance plot.
"""

from __future__ import annotations

import argparse
import cmath
import math
from pathlib import Path
from typing import Iterable, Sequence


def collatz(n: int, odd_multiplier: int = 3) -> int:
    """Return one step of the generalized odd-multiplier Collatz map."""
    if n <= 0:
        raise ValueError("n must be positive")
    return n // 2 if n % 2 == 0 else odd_multiplier * n + 1


def collatz_fourier_direct(
    cutoff: int, omega: float, odd_multiplier: int = 3
) -> complex:
    """Evaluate the finite exponential sum directly in O(cutoff) time."""
    if cutoff < 1:
        raise ValueError("cutoff must be positive")
    return sum(
        cmath.exp(2j * math.pi * omega * collatz(n, odd_multiplier) / n)
        for n in range(1, cutoff + 1)
    )


def collatz_fourier_split(
    cutoff: int, omega: float, odd_multiplier: int = 3
) -> complex:
    """Evaluate the exact even-odd decomposition using half as many loop terms."""
    if cutoff < 1:
        raise ValueError("cutoff must be positive")
    even_count = cutoff // 2
    even_block = even_count * cmath.exp(1j * math.pi * omega)
    odd_remainder = sum(
        cmath.exp(2j * math.pi * omega / n)
        for n in range(1, cutoff + 1, 2)
    )
    odd_block = cmath.exp(2j * math.pi * odd_multiplier * omega) * odd_remainder
    return even_block + odd_block


def irrational_peak_table(cutoff: int, denominators: Iterable[int]) -> list[tuple[int, float, float]]:
    """Return (m, sqrt(2)/m, magnitude) rows showing approach to the peak."""
    rows: list[tuple[int, float, float]] = []
    for m in denominators:
        if m <= 0:
            raise ValueError("denominators must be positive")
        omega = math.sqrt(2.0) / m
        rows.append((m, omega, abs(collatz_fourier_split(cutoff, omega))))
    return rows


def scan_frequencies(
    cutoff: int,
    start: float,
    stop: float,
    samples: int,
    odd_multiplier: int = 3,
) -> list[tuple[float, float]]:
    """Sample transform magnitudes on an inclusive uniform grid."""
    if samples < 2:
        raise ValueError("samples must be at least two")
    return [
        (
            start + (stop - start) * j / (samples - 1),
            abs(
                collatz_fourier_split(
                    cutoff,
                    start + (stop - start) * j / (samples - 1),
                    odd_multiplier,
                )
            ),
        )
        for j in range(samples)
    ]


def write_svg_plot(series: Sequence[tuple[float, float]], cutoff: int, path: Path) -> None:
    """Write a dependency-free SVG line plot for a sampled magnitude series."""
    if not series:
        raise ValueError("series must not be empty")
    width, height, margin = 900, 500, 60
    x_values = [point[0] for point in series]
    y_values = [point[1] for point in series]
    x_min, x_max = min(x_values), max(x_values)
    y_max = max(float(cutoff), max(y_values), 1.0)

    def sx(x: float) -> float:
        return margin + (x - x_min) * (width - 2 * margin) / (x_max - x_min)

    def sy(y: float) -> float:
        return height - margin - y * (height - 2 * margin) / y_max

    points = " ".join(f"{sx(x):.2f},{sy(y):.2f}" for x, y in series)
    svg = f"""<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">
<rect width="100%" height="100%" fill="#081526"/>
<line x1="{margin}" y1="{height-margin}" x2="{width-margin}" y2="{height-margin}" stroke="#91a4bd"/>
<line x1="{margin}" y1="{margin}" x2="{margin}" y2="{height-margin}" stroke="#91a4bd"/>
<line x1="{margin}" y1="{sy(cutoff):.2f}" x2="{width-margin}" y2="{sy(cutoff):.2f}" stroke="#ffcc66" stroke-dasharray="6 6"/>
<polyline fill="none" stroke="#5eead4" stroke-width="2.5" points="{points}"/>
<text x="{width/2}" y="30" text-anchor="middle" fill="white" font-family="sans-serif" font-size="20">Collatz exponential-sum magnitude</text>
<text x="{width/2}" y="{height-15}" text-anchor="middle" fill="#dbeafe" font-family="sans-serif">frequency ω</text>
<text x="18" y="{height/2}" fill="#dbeafe" font-family="sans-serif" transform="rotate(-90 18 {height/2})">|F_N(ω)|</text>
<text x="{width-margin-5}" y="{sy(cutoff)-8:.2f}" text-anchor="end" fill="#ffcc66" font-family="sans-serif">sharp bound N={cutoff}</text>
</svg>
"""
    path.write_text(svg, encoding="utf-8")


def run_demo(cutoff: int, plot_path: Path | None) -> None:
    """Run all numerical demonstrations and print human-readable tables."""
    print(f"Cutoff N = {cutoff}")
    zero_value = collatz_fourier_split(cutoff, 0.0)
    print(f"Zero-frequency value: {zero_value.real:.12f} + {zero_value.imag:.12f}i")
    print(f"Sharp triangle bound: |F_N(omega)| <= {cutoff}\n")

    print("Irrational probes omega = sqrt(2)/m")
    print("m          omega                 |F_N(omega)|       gap from N")
    for m, omega, magnitude in irrational_peak_table(
        cutoff, [10, 100, 1_000, 10_000, 100_000]
    ):
        print(f"{m:<10d} {omega:<21.14g} {magnitude:<20.12f} {cutoff-magnitude:.6e}")

    print("\nDirect/split identity checks")
    for omega in [0.0, math.sqrt(2.0) / 10.0, 0.37, 1.0]:
        direct = collatz_fourier_direct(cutoff, omega)
        split = collatz_fourier_split(cutoff, omega)
        print(f"omega={omega:.9f}: absolute discrepancy={abs(direct-split):.3e}")

    print("\nComparison of generalized odd branches at omega=sqrt(2)/10000")
    omega = math.sqrt(2.0) / 10_000.0
    for multiplier in (3, 5, 7):
        magnitude = abs(collatz_fourier_split(cutoff, omega, multiplier))
        print(f"{multiplier}n+1: |F_N|={magnitude:.12f}, gap from N={cutoff-magnitude:.6e}")

    grid = scan_frequencies(cutoff, -0.1, 0.1, 401)
    grid_max = max(value for _, value in grid)
    assert grid_max <= cutoff + 1e-9
    print(f"\nGrid check: maximum sampled magnitude={grid_max:.12f} <= N")

    if plot_path is not None:
        write_svg_plot(grid, cutoff, plot_path)
        print(f"Wrote SVG plot to {plot_path}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--cutoff", type=int, default=1000, help="positive cutoff N")
    parser.add_argument("--plot", type=Path, default=None, help="optional SVG output path")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    run_demo(args.cutoff, args.plot)


if __name__ == "__main__":
    main()
