#!/usr/bin/env python3
"""
Mandelbrot-Möbius Bridge: Numerical Demonstrations

Demonstrates the key results connecting quadratic iteration z ↦ z² + c
to number theory via Möbius inversion and necklace counting.
"""

import math
from typing import List, Tuple, Optional


def mandelbrot_seq(c: float, n: int) -> List[float]:
    """Compute the first n+1 terms of the Mandelbrot sequence at parameter c."""
    seq = [0.0]
    z = 0.0
    for _ in range(n):
        z = z**2 + c
        seq.append(z)
    return seq


def mandelbrot_poly_coeffs(n: int) -> List[int]:
    """Compute coefficients of the n-th Mandelbrot polynomial Φ_n(c) over ℤ.
    Returns list where index i is the coefficient of c^i."""
    if n == 0:
        return [0]
    # Start with Φ_1 = c = [0, 1]
    poly = [0, 1]
    for _ in range(n - 1):
        # Square the polynomial
        deg = len(poly) - 1
        sq = [0] * (2 * deg + 1)
        for i in range(len(poly)):
            for j in range(len(poly)):
                sq[i + j] += poly[i] * poly[j]
        # Add X (add 1 to coefficient of c^1)
        if len(sq) < 2:
            sq.extend([0] * (2 - len(sq)))
        sq[1] += 1
        poly = sq
    return poly


def euler_totient(n: int) -> int:
    """Euler's totient function φ(n)."""
    result = n
    p = 2
    temp = n
    while p * p <= temp:
        if temp % p == 0:
            while temp % p == 0:
                temp //= p
            result -= result // p
        p += 1
    if temp > 1:
        result -= result // temp
    return result


def mobius(n: int) -> int:
    """Möbius function μ(n)."""
    if n == 1:
        return 1
    count = 0
    temp = n
    p = 2
    while p * p <= temp:
        if temp % p == 0:
            count += 1
            temp //= p
            if temp % p == 0:
                return 0  # p² divides n
        p += 1
    if temp > 1:
        count += 1
    return (-1) ** count


def divisors(n: int) -> List[int]:
    """Return all positive divisors of n."""
    divs = []
    for d in range(1, int(n**0.5) + 1):
        if n % d == 0:
            divs.append(d)
            if d != n // d:
                divs.append(n // d)
    return sorted(divs)


def necklace_count(n: int) -> int:
    """Number of binary necklaces of length n = (1/n) Σ_{d|n} φ(d) · 2^{n/d}."""
    total = sum(euler_totient(d) * (2 ** (n // d)) for d in divisors(n))
    return total // n


def lyndon_count(n: int) -> int:
    """Number of binary Lyndon words (primitive necklaces) of length n.
    = (1/n) Σ_{d|n} μ(n/d) · 2^d."""
    total = sum(mobius(n // d) * (2 ** d) for d in divisors(n))
    return total // n


def burnside_verify(n: int) -> Tuple[int, int]:
    """Verify Burnside necklace identity: Σ 2^gcd(n,k) = Σ φ(d)·2^{n/d}.
    Returns (LHS, RHS)."""
    lhs = sum(2 ** math.gcd(n, k) for k in range(n))
    rhs = sum(euler_totient(d) * (2 ** (n // d)) for d in divisors(n))
    return lhs, rhs


def fixed_point_analysis(c: float) -> dict:
    """Analyze fixed points of z ↦ z² + c.

    Fixed points satisfy z² - z + c = 0.
    Discriminant = 1 - 4c.
    """
    disc = 1 - 4 * c
    result = {"c": c, "discriminant": disc, "fixed_points": []}
    if disc >= 0:
        z1 = (1 + math.sqrt(disc)) / 2
        z2 = (1 - math.sqrt(disc)) / 2
        result["fixed_points"] = [z1, z2]
    return result


def period2_analysis(c: float) -> dict:
    """Analyze period-2 orbits of z ↦ z² + c.

    Period-2 points satisfy z² + z + (c + 1) = 0.
    Discriminant = -3 - 4c.
    Non-fixed period-2 exists iff 4c + 3 < 0 (i.e., c < -3/4).
    """
    disc = -3 - 4 * c
    result = {"c": c, "discriminant": disc, "period2_points": [],
              "exists": 4 * c + 3 < 0}
    if disc > 0:
        z1 = (-1 + math.sqrt(disc)) / 2
        z2 = (-1 - math.sqrt(disc)) / 2
        result["period2_points"] = [z1, z2]
    return result


def escape_time(c: float, max_iter: int = 100, radius: float = 2.0) -> Optional[int]:
    """Compute escape time for the Mandelbrot iteration at c.
    Returns None if orbit stays bounded within max_iter iterations."""
    z = 0.0
    for n in range(1, max_iter + 1):
        z = z**2 + c
        if abs(z) > radius:
            return n
    return None


# ═══════════════════════════════════════════════════════
# DEMONSTRATIONS
# ═══════════════════════════════════════════════════════

def demo_mandelbrot_polynomials():
    """Demonstrate the Mandelbrot polynomial structure."""
    print("=" * 60)
    print("DEMO 1: Mandelbrot Polynomials Φ_n(c)")
    print("=" * 60)
    for n in range(1, 6):
        coeffs = mandelbrot_poly_coeffs(n)
        degree = len(coeffs) - 1
        while degree > 0 and coeffs[degree] == 0:
            degree -= 1
        terms = []
        for i in range(degree, -1, -1):
            if coeffs[i] != 0:
                if i == 0:
                    terms.append(f"{coeffs[i]}")
                elif i == 1:
                    terms.append(f"{coeffs[i]}c" if coeffs[i] != 1 else "c")
                else:
                    terms.append(f"{coeffs[i]}c^{i}" if coeffs[i] != 1 else f"c^{i}")
        poly_str = " + ".join(terms) if terms else "0"
        print(f"  Φ_{n}(c) = {poly_str}")
        print(f"    degree = {degree}, expected 2^{n-1} = {2**(n-1)}  ✓" if degree == 2**(n-1) else f"    MISMATCH!")
        print(f"    leading coeff = {coeffs[degree]} (monic ✓)" if coeffs[degree] == 1 else f"    NOT MONIC!")
    print()


def demo_bifurcation():
    """Demonstrate the period-1 and period-2 bifurcation analysis."""
    print("=" * 60)
    print("DEMO 2: Bifurcation Analysis")
    print("=" * 60)

    print("\n  Fixed point analysis (z² - z + c = 0):")
    for c in [0.25, 0.0, -0.5, -0.75, -1.0, -2.0]:
        fp = fixed_point_analysis(c)
        pts = [f"{z:.4f}" for z in fp["fixed_points"]]
        status = "✓" if fp["discriminant"] >= 0 else "✗"
        print(f"    c = {c:6.2f}: disc = {fp['discriminant']:6.2f}, "
              f"fixed points: {pts if pts else 'none'} {status}")

    print("\n  Period-2 analysis (z² + z + c + 1 = 0):")
    for c in [-0.5, -0.75, -1.0, -1.25, -1.5, -2.0]:
        p2 = period2_analysis(c)
        pts = [f"{z:.4f}" for z in p2["period2_points"]]
        status = "✓" if p2["exists"] else "✗ (boundary or none)"
        print(f"    c = {c:6.2f}: disc = {p2['discriminant']:6.2f}, "
              f"period-2: {pts if pts else 'none'} {status}")
    print()


def demo_burnside_necklace():
    """Demonstrate the Burnside necklace identity."""
    print("=" * 60)
    print("DEMO 3: Burnside Necklace Identity")
    print("  Σ 2^gcd(n,k) = Σ φ(d)·2^{n/d}")
    print("=" * 60)
    for n in range(1, 13):
        lhs, rhs = burnside_verify(n)
        necklaces = necklace_count(n)
        lyndon = lyndon_count(n)
        status = "✓" if lhs == rhs else "✗"
        print(f"  n={n:2d}: Burnside sum = {lhs:6d} = {rhs:6d} {status}, "
              f"necklaces = {necklaces:4d}, Lyndon words = {lyndon:4d}")
    print()


def demo_mobius_orbit_counting():
    """Demonstrate primitive orbit counting via Möbius inversion."""
    print("=" * 60)
    print("DEMO 4: Möbius Orbit Counting for Doubling Map θ → 2θ")
    print("=" * 60)
    for n in range(1, 16):
        total_periodic = 2**n - 1  # |Fix(f^n)| for doubling map
        primitive = sum(mobius(n // d) * (2**d - 1) for d in divisors(n))
        check = sum(
            sum(mobius(n // d) * (2**d - 1) for d in divisors(k))
            for k in divisors(n)
        )
        print(f"  n={n:2d}: |Fix(f^n)| = {total_periodic:6d}, "
              f"primitive = {primitive:5d}, "
              f"orbits = {primitive // n if primitive % n == 0 else 'ERR':>4}")
    print()


def demo_special_parameters():
    """Demonstrate special parameter values of the Mandelbrot set."""
    print("=" * 60)
    print("DEMO 5: Special Parameter Values")
    print("=" * 60)

    # c = 0: center of cardioid
    seq = mandelbrot_seq(0.0, 10)
    print(f"  c = 0 (cardioid center): {seq[:6]}... (all zeros ✓)")

    # c = -1: center of period-2 bulb
    seq = mandelbrot_seq(-1.0, 10)
    print(f"  c = -1 (period-2 center): {seq[:8]}... (period 2 ✓)")

    # c = -2: tip of Mandelbrot set
    seq = mandelbrot_seq(-2.0, 6)
    print(f"  c = -2 (tip): {seq[:6]}... (z_2 = {seq[2]} ✓)")

    # c = 3: outside, escape
    esc = escape_time(3.0)
    print(f"  c = 3 (outside): escapes at step {esc}")

    # c = -1.755: near period-3 window
    seq = mandelbrot_seq(-1.755, 20)
    print(f"  c = -1.755 (near period-3): {[round(z, 3) for z in seq[:8]]}...")
    print()


def demo_escape_growth():
    """Demonstrate super-exponential escape growth for c > 2."""
    print("=" * 60)
    print("DEMO 6: Escape Growth for c > 2")
    print("=" * 60)
    for c in [2.1, 3.0, 5.0, 10.0]:
        seq = mandelbrot_seq(c, 8)
        print(f"  c = {c}:")
        for n in range(1, min(8, len(seq))):
            ratio = seq[n] / seq[n-1] if seq[n-1] != 0 and n > 1 else float('inf')
            print(f"    z_{n} = {seq[n]:.6e}, z_{n}/z_{n-1} = {ratio:.2f}")
        print()


if __name__ == "__main__":
    demo_mandelbrot_polynomials()
    demo_bifurcation()
    demo_burnside_necklace()
    demo_mobius_orbit_counting()
    demo_special_parameters()
    demo_escape_growth()


#!/usr/bin/env python3
"""Visualization: Mandelbrot Set with Period Coloring

Renders the Mandelbrot set on the real line, coloring by detected period
to reveal the number-theoretic structure of bulbs.
"""
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import numpy as np


def mandelbrot_period(c_real, c_imag, max_iter=200, max_period=30):
    """Detect period of attracting cycle, or return 0 if escapes."""
    z_real, z_imag = 0.0, 0.0
    # Transient
    for _ in range(max_iter):
        zr2 = z_real * z_real
        zi2 = z_imag * z_imag
        if zr2 + zi2 > 4:
            return -1  # escapes
        z_imag = 2 * z_real * z_imag + c_imag
        z_real = zr2 - zi2 + c_real

    # Record orbit for period detection
    orbit_r = [z_real]
    orbit_i = [z_imag]
    for _ in range(max_period):
        zr2 = z_real * z_real
        zi2 = z_imag * z_imag
        if zr2 + zi2 > 4:
            return -1
        z_imag = 2 * z_real * z_imag + c_imag
        z_real = zr2 - zi2 + c_real
        orbit_r.append(z_real)
        orbit_i.append(z_imag)

    for d in range(1, max_period + 1):
        dr = orbit_r[-1] - orbit_r[-1 - d]
        di = orbit_i[-1] - orbit_i[-1 - d]
        if dr * dr + di * di < 1e-12:
            return d
    return 0


def main():
    # Create figure with two panels
    fig, axes = plt.subplots(2, 1, figsize=(14, 10))

    # Panel 1: Mandelbrot set with period coloring
    nx, ny = 800, 600
    x = np.linspace(-2.2, 0.8, nx)
    y = np.linspace(-1.2, 1.2, ny)
    periods = np.zeros((ny, nx))

    for i in range(ny):
        for j in range(nx):
            periods[i, j] = mandelbrot_period(x[j], y[i])

    cmap = plt.cm.tab20
    norm = mcolors.BoundaryNorm(boundaries=range(-1, 22), ncolors=cmap.N)

    ax = axes[0]
    im = ax.imshow(periods, extent=[-2.2, 0.8, -1.2, 1.2],
                   cmap=cmap, norm=norm, aspect='auto', origin='lower')
    ax.set_title('Mandelbrot Set: Period of Attracting Cycle', fontsize=14)
    ax.set_xlabel('Re(c)')
    ax.set_ylabel('Im(c)')

    # Mark special parameters
    special = {
        (0, 0): 'c=0\nperiod 1',
        (-1, 0): 'c=-1\nperiod 2',
        (-0.75, 0): 'c=-3/4\nbifurcation',
        (0.25, 0): 'c=1/4\ncusp',
        (-2, 0): 'c=-2\ntip'
    }
    for (cx, cy), label in special.items():
        ax.plot(cx, cy, 'ko', markersize=4)
        ax.annotate(label, (cx, cy), textcoords="offset points",
                    xytext=(0, 10), ha='center', fontsize=7,
                    color='white', fontweight='bold')

    cbar = fig.colorbar(im, ax=ax, ticks=range(0, 21))
    cbar.set_label('Period')

    # Panel 2: Real-axis bifurcation diagram
    ax2 = axes[1]
    c_values = np.linspace(-2, 0.25, 2000)
    for c in c_values:
        z = 0.0
        # Transient
        for _ in range(200):
            z = z * z + c
            if abs(z) > 10:
                break
        else:
            # Plot attractor
            zs = []
            for _ in range(100):
                z = z * z + c
                if abs(z) > 10:
                    break
                zs.append(z)
            if zs:
                ax2.plot([c] * len(zs), zs, ',', color='black', markersize=0.1)

    ax2.axvline(x=-0.75, color='red', linestyle='--', alpha=0.5, label='c = -3/4 (period-2 bifurcation)')
    ax2.axvline(x=0.25, color='blue', linestyle='--', alpha=0.5, label='c = 1/4 (cusp)')
    ax2.set_title('Bifurcation Diagram: Period-Doubling Cascade', fontsize=14)
    ax2.set_xlabel('c')
    ax2.set_ylabel('Attractor values')
    ax2.legend(fontsize=8)
    ax2.set_xlim(-2, 0.25)
    ax2.set_ylim(-2, 2)

    plt.tight_layout()
    plt.savefig('mandelbrot_periods.png', dpi=150, bbox_inches='tight')
    plt.show()
    print("Saved mandelbrot_periods.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""Visualization: Necklace Counting and Möbius Inversion

Visualizes the triple correspondence:
  Doubling map orbits ↔ Binary necklaces ↔ Irreducible polynomials over F₂
"""
import matplotlib.pyplot as plt
import numpy as np
import math


def euler_totient(n):
    result = n
    p = 2
    temp = n
    while p * p <= temp:
        if temp % p == 0:
            while temp % p == 0:
                temp //= p
            result -= result // p
        p += 1
    if temp > 1:
        result -= result // temp
    return result


def mobius(n):
    if n == 1:
        return 1
    count = 0
    temp = n
    p = 2
    while p * p <= temp:
        if temp % p == 0:
            count += 1
            temp //= p
            if temp % p == 0:
                return 0
        p += 1
    if temp > 1:
        count += 1
    return (-1) ** count


def divisors(n):
    divs = []
    for d in range(1, int(math.isqrt(n)) + 1):
        if n % d == 0:
            divs.append(d)
            if d != n // d:
                divs.append(n // d)
    return sorted(divs)


def necklace_count(n):
    return sum(euler_totient(d) * (2 ** (n // d)) for d in divisors(n)) // n


def lyndon_count(n):
    return sum(mobius(n // d) * (2 ** d) for d in divisors(n)) // n


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    # Panel 1: Necklace and Lyndon word counts
    ax = axes[0, 0]
    ns = list(range(1, 21))
    necklaces = [necklace_count(n) for n in ns]
    lyndon = [lyndon_count(n) for n in ns]
    total = [2**n for n in ns]

    ax.semilogy(ns, total, 'k-o', label='Total strings 2^n', markersize=4)
    ax.semilogy(ns, necklaces, 'b-s', label='Necklaces N(2,n)', markersize=4)
    ax.semilogy(ns, lyndon, 'r-^', label='Lyndon words L(2,n)', markersize=4)
    ax.set_xlabel('n')
    ax.set_ylabel('Count (log scale)')
    ax.set_title('Binary String Counting')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Panel 2: Ratio L(n)/N(n) — shows which n have many primitive necklaces
    ax = axes[0, 1]
    ratios = [lyndon[i] / necklaces[i] if necklaces[i] > 0 else 0 for i in range(len(ns))]
    colors = ['red' if all(n % p != 0 for p in [2, 3, 5, 7, 11, 13, 17, 19] if p < n)
              and n > 1 else 'blue' for n in ns]
    # Actually check primality properly
    def is_prime(n):
        if n < 2:
            return False
        for p in range(2, int(n**0.5) + 1):
            if n % p == 0:
                return False
        return True

    colors = ['red' if is_prime(n) else 'steelblue' for n in ns]
    ax.bar(ns, ratios, color=colors, alpha=0.7, edgecolor='black', linewidth=0.5)
    ax.set_xlabel('n')
    ax.set_ylabel('L(2,n) / N(2,n)')
    ax.set_title('Primitive Fraction (red = prime n)')
    ax.grid(True, alpha=0.3, axis='y')

    # Panel 3: Burnside identity verification — visual decomposition
    ax = axes[1, 0]
    n_test = 12
    contributions = []
    divs = divisors(n_test)
    for d in divs:
        contributions.append(euler_totient(d) * (2 ** (n_test // d)))

    ax.bar(range(len(divs)), contributions, tick_label=[str(d) for d in divs],
           color='teal', alpha=0.7, edgecolor='black')
    ax.set_xlabel(f'Divisor d of {n_test}')
    ax.set_ylabel(f'φ(d) · 2^({n_test}/d)')
    ax.set_title(f'Burnside Decomposition for n={n_test}')
    ax.grid(True, alpha=0.3, axis='y')

    total_sum = sum(contributions)
    ax.text(0.95, 0.95, f'Sum = {total_sum}\nNecklaces = {total_sum // n_test}',
            transform=ax.transAxes, ha='right', va='top',
            bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

    # Panel 4: Möbius function values for small n
    ax = axes[1, 1]
    mu_ns = list(range(1, 31))
    mu_vals = [mobius(n) for n in mu_ns]
    bar_colors = ['green' if v == 1 else 'red' if v == -1 else 'gray' for v in mu_vals]
    ax.bar(mu_ns, mu_vals, color=bar_colors, alpha=0.7, edgecolor='black', linewidth=0.5)
    ax.set_xlabel('n')
    ax.set_ylabel('μ(n)')
    ax.set_title('Möbius Function: The Engine of Orbit Counting')
    ax.set_ylim(-1.5, 1.5)
    ax.grid(True, alpha=0.3, axis='y')
    ax.axhline(y=0, color='black', linewidth=0.5)

    # Legend for Möbius
    from matplotlib.patches import Patch
    legend_elements = [
        Patch(facecolor='green', alpha=0.7, label='μ(n) = +1 (even # primes)'),
        Patch(facecolor='red', alpha=0.7, label='μ(n) = -1 (odd # primes)'),
        Patch(facecolor='gray', alpha=0.7, label='μ(n) = 0 (has p² factor)'),
    ]
    ax.legend(handles=legend_elements, fontsize=8)

    plt.tight_layout()
    plt.savefig('necklace_mobius.png', dpi=150, bbox_inches='tight')
    plt.show()
    print("Saved necklace_mobius.png")


if __name__ == "__main__":
    main()
