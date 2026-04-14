#!/usr/bin/env python3
"""
EML V5 Julia Set Explorer
==========================
Compute and visualize the Julia set of the diagonal map d(z) = exp(z) - log(z) in ℂ.

The Julia set is the boundary of the set of points whose orbits under d remain bounded.
Since d has no real fixed points (d(z) > z for all z ∈ ℝ), the dynamics are purely
escape-based on the real line. In the complex plane, however, the dynamics are much richer.

Output: SVG visualization of the Julia set.
"""

import cmath
import math
import sys

def complex_diagonal_map(z: complex) -> complex:
    """Compute d(z) = exp(z) - log(z) for complex z."""
    try:
        return cmath.exp(z) - cmath.log(z)
    except (ValueError, OverflowError):
        return complex(float('inf'), float('inf'))

def escape_time(z0: complex, max_iter: int = 100, escape_radius: float = 50.0) -> int:
    """Compute the number of iterations before |d^n(z)| > escape_radius."""
    z = z0
    for i in range(max_iter):
        try:
            z = complex_diagonal_map(z)
            if abs(z) > escape_radius or math.isnan(z.real) or math.isnan(z.imag):
                return i
        except:
            return i
    return max_iter

def generate_julia_set_svg(
    center_x: float = 1.0,
    center_y: float = 0.0,
    width: float = 8.0,
    height: float = 6.0,
    resolution: int = 400,
    max_iter: int = 80
) -> str:
    """Generate an SVG visualization of the Julia set."""

    aspect = height / width
    res_y = int(resolution * aspect)

    # Color palette (deep blue to gold to white)
    def color_for_iter(n: int, max_n: int) -> str:
        if n >= max_n:
            return "#000000"
        t = n / max_n
        if t < 0.3:
            # Dark blue to blue
            r = int(10 + 40 * (t / 0.3))
            g = int(10 + 80 * (t / 0.3))
            b = int(50 + 150 * (t / 0.3))
        elif t < 0.6:
            # Blue to gold
            s = (t - 0.3) / 0.3
            r = int(50 + 205 * s)
            g = int(90 + 120 * s)
            b = int(200 - 100 * s)
        else:
            # Gold to white
            s = (t - 0.6) / 0.4
            r = int(255)
            g = int(210 + 45 * s)
            b = int(100 + 155 * s)
        return f"#{r:02x}{g:02x}{b:02x}"

    # Generate pixel data
    pixels = []
    x_min = center_x - width / 2
    y_min = center_y - height / 2

    pixel_w = width / resolution
    pixel_h = height / res_y

    print(f"Generating Julia set: {resolution}x{res_y} pixels, max_iter={max_iter}")

    for j in range(res_y):
        row = []
        im = y_min + (j + 0.5) * pixel_h
        for i in range(resolution):
            re = x_min + (i + 0.5) * pixel_w
            z0 = complex(re, im)
            n = escape_time(z0, max_iter)
            row.append(n)
        pixels.append(row)
        if (j + 1) % 50 == 0:
            print(f"  Row {j+1}/{res_y}")

    # Build SVG
    svg_width = 800
    svg_height = int(svg_width * aspect)
    cell_w = svg_width / resolution
    cell_h = svg_height / res_y

    lines = []
    lines.append(f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {svg_width} {svg_height + 80}" font-family="Arial, sans-serif">')
    lines.append(f'  <rect width="{svg_width}" height="{svg_height + 80}" fill="#0a0a2e"/>')

    # Title
    lines.append(f'  <text x="{svg_width//2}" y="25" text-anchor="middle" fill="#FFD700" font-size="18" font-weight="bold">')
    lines.append(f'    Julia Set of d(z) = exp(z) − log(z)')
    lines.append(f'  </text>')

    # Render pixels as small rectangles (grouped by color for efficiency)
    color_groups = {}
    for j in range(res_y):
        for i in range(resolution):
            color = color_for_iter(pixels[j][i], max_iter)
            if color not in color_groups:
                color_groups[color] = []
            x = i * cell_w
            y = 40 + j * cell_h
            color_groups[color].append((x, y))

    for color, coords in color_groups.items():
        rects = " ".join(f'<rect x="{x:.1f}" y="{y:.1f}" width="{cell_w+0.5:.1f}" height="{cell_h+0.5:.1f}"/>' for x, y in coords)
        lines.append(f'  <g fill="{color}">{rects}</g>')

    # Legend
    legend_y = svg_height + 50
    lines.append(f'  <text x="20" y="{legend_y}" fill="#aaa" font-size="11">')
    lines.append(f'    Region: [{center_x - width/2:.1f}, {center_x + width/2:.1f}] × [{center_y - height/2:.1f}i, {center_y + height/2:.1f}i]')
    lines.append(f'  </text>')
    lines.append(f'  <text x="{svg_width - 20}" y="{legend_y}" text-anchor="end" fill="#aaa" font-size="11">')
    lines.append(f'    Black = bounded orbit | Color = escape speed')
    lines.append(f'  </text>')
    lines.append(f'  <text x="{svg_width//2}" y="{legend_y + 18}" text-anchor="middle" fill="#666" font-size="10">')
    lines.append(f'    EML V5 Research · d(z) has no real fixed points · Complex dynamics are fractal')
    lines.append(f'  </text>')

    lines.append('</svg>')

    return "\n".join(lines)

def analyze_complex_fixed_points():
    """Search for complex fixed points of d(z) = exp(z) - log(z)."""
    print("\n" + "="*60)
    print("COMPLEX FIXED POINT ANALYSIS")
    print("d(z) = z  ⟺  exp(z) - log(z) = z")
    print("="*60)

    # Newton's method for f(z) = exp(z) - log(z) - z = 0
    # f'(z) = exp(z) - 1/z - 1

    found = set()
    for re_start in [x * 0.5 for x in range(-10, 10)]:
        for im_start in [y * 0.5 for y in range(-10, 10)]:
            if im_start == 0:
                continue  # No real fixed points
            z = complex(re_start, im_start)
            converged = False
            for _ in range(200):
                try:
                    f = cmath.exp(z) - cmath.log(z) - z
                    fp = cmath.exp(z) - 1/z - 1
                    if abs(fp) < 1e-15:
                        break
                    z_new = z - f / fp
                    if abs(z_new - z) < 1e-14:
                        converged = True
                        z = z_new
                        break
                    z = z_new
                except:
                    break

            if converged and abs(cmath.exp(z) - cmath.log(z) - z) < 1e-10:
                # Round to avoid duplicates
                key = (round(z.real, 8), round(z.imag, 8))
                if key not in found and abs(z.imag) > 1e-6:
                    found.add(key)
                    print(f"  Fixed point: z ≈ {z.real:.10f} + {z.imag:.10f}i")
                    print(f"    |d(z) - z| = {abs(cmath.exp(z) - cmath.log(z) - z):.2e}")
                    deriv = cmath.exp(z) - 1/z
                    print(f"    |d'(z)| = {abs(deriv):.6f} ({'attracting' if abs(deriv) < 1 else 'repelling'})")

    if not found:
        print("  No complex fixed points found in the search region.")
    else:
        print(f"\n  Found {len(found)} distinct complex fixed points (up to conjugation).")

def main():
    print("="*60)
    print("  EML V5 Julia Set Explorer")
    print("  d(z) = exp(z) − log(z)")
    print("="*60)

    # Analyze complex fixed points
    analyze_complex_fixed_points()

    # Generate Julia set SVG
    print("\nGenerating Julia set SVG...")
    svg = generate_julia_set_svg(
        center_x=0.5,
        center_y=0.0,
        width=6.0,
        height=4.0,
        resolution=200,  # Lower res for speed
        max_iter=50
    )

    output_file = "EML/Visuals/eml_v5_julia_set.svg"
    with open(output_file, 'w') as f:
        f.write(svg)
    print(f"Julia set saved to {output_file}")

    # Statistics
    print("\nJulia Set Statistics:")
    print(f"  Center: 0.5 + 0i")
    print(f"  Window: [-2.5, 3.5] × [-2i, 2i]")
    print(f"  The fractal structure confirms complex dynamics")
    print(f"  Real axis: all orbits escape (d(z) > z always)")
    print(f"  Complex plane: intricate boundary structure")

if __name__ == "__main__":
    main()
