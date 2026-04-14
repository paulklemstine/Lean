#!/usr/bin/env python3
"""
EML Julia Set Explorer

Computes and visualizes the Julia set of the EML diagonal map
d(z) = exp(z) - log(z) in the complex plane.

The Julia set is the boundary of the set of points whose orbits
under iteration of d remain bounded.
"""

import cmath
import math
import sys

def eml_diagonal_complex(z: complex) -> complex:
    """Complex diagonal map: d(z) = exp(z) - log(z)."""
    return cmath.exp(z) - cmath.log(z)

def compute_julia_set(
    x_min: float = -3.0, x_max: float = 3.0,
    y_min: float = -3.0, y_max: float = 3.0,
    width: int = 200, height: int = 200,
    max_iter: int = 50, escape_radius: float = 100.0
):
    """Compute escape-time Julia set for the EML diagonal map."""
    data = []
    for j in range(height):
        row = []
        y = y_max - (y_max - y_min) * j / height
        for i in range(width):
            x = x_min + (x_max - x_min) * i / width
            z = complex(x, y)
            n = 0
            try:
                for n in range(max_iter):
                    if abs(z) > escape_radius:
                        break
                    z = eml_diagonal_complex(z)
            except (OverflowError, ValueError):
                pass
            row.append(n)
        data.append(row)
    return data

def generate_svg_julia(data, width=800, height=800, max_iter=50,
                       x_min=-3.0, x_max=3.0, y_min=-3.0, y_max=3.0):
    """Generate an SVG representation of the Julia set."""
    pixel_w = width / len(data[0])
    pixel_h = height / len(data)

    svg_parts = []
    svg_parts.append(f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {width} {height}">')
    svg_parts.append(f'<rect width="{width}" height="{height}" fill="black"/>')

    # Title
    svg_parts.append(f'<text x="{width/2}" y="25" text-anchor="middle" fill="white" font-size="16" font-family="sans-serif">')
    svg_parts.append('Julia Set of d(z) = exp(z) - log(z)</text>')

    for j, row in enumerate(data):
        for i, n in enumerate(row):
            if n < max_iter - 1:
                # Escaped: color by iteration count
                t = n / max_iter
                r = int(255 * (1 - t) * t * 4)
                g = int(255 * t * t)
                b = int(255 * (1 - t) * (1 - t) * 3)
                r, g, b = min(r, 255), min(g, 255), min(b, 255)
                color = f"rgb({r},{g},{b})"
            else:
                # Didn't escape: in the Julia set
                color = "rgb(255,215,0)"  # gold for bounded orbits

            x = i * pixel_w
            y = j * pixel_h
            svg_parts.append(f'<rect x="{x:.1f}" y="{y:.1f}" width="{pixel_w+0.5:.1f}" height="{pixel_h+0.5:.1f}" fill="{color}"/>')

    # Axes
    # x-axis
    cy = height * (y_max) / (y_max - y_min)
    svg_parts.append(f'<line x1="0" y1="{cy:.1f}" x2="{width}" y2="{cy:.1f}" stroke="white" stroke-opacity="0.3"/>')
    # y-axis
    cx = width * (-x_min) / (x_max - x_min)
    svg_parts.append(f'<line x1="{cx:.1f}" y1="0" x2="{cx:.1f}" y2="{height}" stroke="white" stroke-opacity="0.3"/>')

    # Labels
    svg_parts.append(f'<text x="{width-5}" y="{cy-5:.1f}" text-anchor="end" fill="white" font-size="10" opacity="0.7">Re</text>')
    svg_parts.append(f'<text x="{cx+5:.1f}" y="15" fill="white" font-size="10" opacity="0.7">Im</text>')

    svg_parts.append('</svg>')
    return '\n'.join(svg_parts)

def orbit_analysis():
    """Analyze specific orbits of the diagonal map."""
    print("=" * 60)
    print("ORBIT ANALYSIS: d(z) = exp(z) - log(z)")
    print("=" * 60)

    test_points = [
        complex(1, 0),
        complex(0, 1),
        complex(1, 1),
        complex(-1, 0),
        complex(0.5, 0.5),
        complex(2, 0),
    ]

    for z0 in test_points:
        z = z0
        print(f"\nOrbit of z₀ = {z0}:")
        bounded = True
        for n in range(20):
            try:
                print(f"  d^{n}(z₀) = {z.real:>10.4f} + {z.imag:>10.4f}i  |z| = {abs(z):.4f}")
                z = eml_diagonal_complex(z)
                if abs(z) > 1e10:
                    print(f"  → ESCAPED at iteration {n+1}")
                    bounded = False
                    break
            except (OverflowError, ValueError):
                print(f"  → OVERFLOW at iteration {n+1}")
                bounded = False
                break
        if bounded:
            print(f"  → BOUNDED (in Julia set)")

if __name__ == "__main__":
    print("Computing Julia set of d(z) = exp(z) - log(z)...")

    # Orbit analysis
    orbit_analysis()

    # Compute Julia set data
    resolution = 100  # Lower for faster computation
    data = compute_julia_set(
        x_min=-3, x_max=3, y_min=-3, y_max=3,
        width=resolution, height=resolution,
        max_iter=30
    )

    # Generate SVG
    svg = generate_svg_julia(data, width=600, height=600, max_iter=30)

    output_path = "EML/Visuals/eml_julia_set_v2.svg"
    with open(output_path, 'w') as f:
        f.write(svg)
    print(f"\nJulia set SVG written to {output_path}")
    print(f"Resolution: {resolution}×{resolution}")
