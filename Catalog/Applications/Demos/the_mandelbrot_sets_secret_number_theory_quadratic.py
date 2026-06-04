#!/usr/bin/env python3
"""
Demo: Mandelbrot Set Number Theory
===================================
Demonstrates the connection between Mandelbrot set bulb periods,
Farey mediant structure, and number-theoretic orbit counting.
"""

import math
from fractions import Fraction


def quad_iter(c: complex, z: complex, n: int) -> complex:
    """Iterate z -> z^2 + c, n times."""
    for _ in range(n):
        z = z * z + c
    return z


def mandelbrot_iter(c: complex, n: int) -> complex:
    """Mandelbrot iteration starting from 0."""
    return quad_iter(c, 0, n)


def orbit_multiplier(c: complex, z: complex, n: int) -> complex:
    """Compute the orbit multiplier 2^n * prod(z_k for k < n)."""
    product = 1.0 + 0j
    current = z
    for _ in range(n):
        product *= current
        current = current * current + c
    return (2 ** n) * product


def find_period(c: complex, max_period: int = 100, tol: float = 1e-10) -> int:
    """Find the period of the critical orbit for parameter c."""
    z = 0 + 0j
    for n in range(1, max_period + 1):
        z = z * z + c
        if abs(z) < tol:
            return n
    return -1  # not periodic


def dynatomic_point_count(n: int) -> int:
    """Compute the dynatomic point count using Möbius inversion:
    Psi(n) = sum_{d|n} mu(n/d) * 2^d"""
    from sympy import mobius, divisors
    return sum(mobius(n // d) * (2 ** d) for d in divisors(n))


def farey_mediant(p1: int, q1: int, p2: int, q2: int) -> tuple:
    """Farey mediant of p1/q1 and p2/q2."""
    return (p1 + p2, q1 + q2)


def fibonacci_periods(n_terms: int = 10) -> list:
    """Generate Fibonacci periods via iterated Farey mediation."""
    fibs = [1, 1]
    for i in range(n_terms):
        fibs.append(fibs[-1] + fibs[-2])
    return fibs


def bulb_center(p: int, q: int) -> complex:
    """Approximate center of the p/q bulb of the Mandelbrot set.
    The center is a root of the dynatomic polynomial."""
    # Use the formula: center ≈ (1 - (2*pi*p/q)^2/4) / 2 * e^{2*pi*i*p/q}
    # This is a first-order approximation for small bulbs
    theta = 2 * math.pi * p / q
    # For the main cardioid parametrization: c = e^{it}/2 - e^{2it}/4
    r = 1 / (2 * q)  # approximate radius
    return complex(math.cos(theta), math.sin(theta)) * r


def main():
    print("=" * 60)
    print("  MANDELBROT SET NUMBER THEORY DEMO")
    print("=" * 60)

    # 1. Verify fixed points and period-2 points
    print("\n--- Fixed Points (Period 1) ---")
    print("For c = 0: z = 0 is a superattracting fixed point")
    print(f"  quad_iter(0, 0, 1) = {quad_iter(0, 0, 1)}")
    print(f"  Multiplier = {orbit_multiplier(0, 0, 1)}")

    print("\n--- Period-2 Cycle ---")
    c_period2 = -1.0 + 0j  # center of period-2 bulb
    z = mandelbrot_iter(c_period2, 1)
    print(f"  c = {c_period2}")
    print(f"  z_1 = {z}")
    print(f"  z_2 = {quad_iter(c_period2, z, 1)}")
    print(f"  Period check: quad_iter(c, z, 2) - z = {quad_iter(c_period2, z, 2) - z}")
    print(f"  Multiplier = {orbit_multiplier(c_period2, z, 2)}")

    # 2. Dynatomic point counts
    print("\n--- Dynatomic Point Counts (Psi(n) = primitive period-n points) ---")
    try:
        for n in range(1, 13):
            psi = dynatomic_point_count(n)
            orbits = psi // n if n > 0 else 0
            print(f"  Psi({n:2d}) = {psi:6d}  ({orbits} orbits)")
    except ImportError:
        # Fallback without sympy
        print("  (sympy not available for Möbius function)")
        # Manual computation for small values
        manual = {1: 2, 2: 2, 3: 6, 4: 12, 5: 30, 6: 54}
        for n, psi in manual.items():
            print(f"  Psi({n}) = {psi}  ({psi // n} orbits)")

    # 3. Fermat's little theorem connection
    print("\n--- Fermat's Little Theorem: p | 2^p - 2 ---")
    primes = [2, 3, 5, 7, 11, 13, 17, 19]
    for p in primes:
        val = 2**p - 2
        print(f"  p={p:2d}: 2^p - 2 = {val:6d}, "
              f"(2^p - 2)/p = {val // p:5d} orbits, "
              f"divisible: {val % p == 0}")

    # 4. Fibonacci-Farey connection
    print("\n--- Fibonacci Numbers from Farey Mediation ---")
    fibs = fibonacci_periods(12)
    print(f"  Fibonacci sequence: {fibs}")
    print("  Verifying Farey mediant property:")
    for i in range(len(fibs) - 3):
        result = farey_mediant(fibs[i], fibs[i+1], fibs[i+1], fibs[i+2])
        print(f"    mediant({fibs[i]}/{fibs[i+1]}, {fibs[i+1]}/{fibs[i+2]}).denom "
              f"= {result[1]} = fib({i+3}) = {fibs[i+3]}")

    # 5. Escape criterion verification
    print("\n--- Escape Criterion: |z_n| > 2 implies escape ---")
    c_escape = 1.0 + 0j  # outside Mandelbrot set
    print(f"  c = {c_escape}")
    z = 0 + 0j
    for n in range(8):
        z = z * z + c_escape
        print(f"    n={n+1}: z = {z:.6f}, |z| = {abs(z):.6f}")
        if abs(z) > 100:
            print("    (orbit escaping...)")
            break

    # 6. Superattracting centers
    print("\n--- Superattracting Centers (multiplier = 0) ---")
    centers = {
        "Period 1 (c=0)": (0 + 0j, 1),
        "Period 2 (c=-1)": (-1 + 0j, 2),
        "Period 3": (-1.7549 + 0j, 3),
        "Period 4": (-1.3107 + 0j, 4),
    }
    for name, (c, q) in centers.items():
        z = 0 + 0j
        for _ in range(q):
            z = z * z + c
        mult = orbit_multiplier(c, 0 + 0j, q)
        print(f"  {name}: c = {c:.4f}, "
              f"|mandelbrot_iter(c, {q})| = {abs(z):.2e}, "
              f"|multiplier| = {abs(mult):.2e}")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Farey-Fibonacci Structure in Mandelbrot Bulbs
=============================================================
"""
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches


def fibonacci(n):
    fibs = [0, 1]
    for _ in range(n):
        fibs.append(fibs[-1] + fibs[-2])
    return fibs


def farey_mediant(p1, q1, p2, q2):
    return (p1 + p2, q1 + q2)


def mobius(n):
    if n == 1: return 1
    d, factors = 2, []
    temp = n
    while d * d <= temp:
        if temp % d == 0:
            exp = 0
            while temp % d == 0:
                exp += 1
                temp //= d
            if exp > 1: return 0
            factors.append(d)
        d += 1
    if temp > 1: factors.append(temp)
    return (-1)**len(factors)


def dynatomic(n):
    divs = [d for d in range(1, n+1) if n % d == 0]
    return sum(mobius(n // d) * (2**d) for d in divs)


def main():
    fig, axes = plt.subplots(1, 2, figsize=(16, 7))

    # Left: Farey tree showing Fibonacci emergence
    ax = axes[0]
    ax.set_xlim(-0.1, 1.1)
    ax.set_ylim(-0.5, 5.5)
    ax.set_title("Farey Tree → Fibonacci Periods\nin Mandelbrot Antenna", fontsize=14)
    ax.set_ylabel("Depth", fontsize=12)

    # Draw Farey tree levels
    def draw_farey_level(fracs, depth, ax):
        new_fracs = []
        for i in range(len(fracs) - 1):
            p1, q1 = fracs[i]
            p2, q2 = fracs[i + 1]
            med = farey_mediant(p1, q1, p2, q2)
            new_fracs.append(fracs[i])
            new_fracs.append(med)
            # Draw lines
            x1 = p1 / q1
            x2 = p2 / q2
            xm = med[0] / med[1]
            ax.plot([x1, xm], [depth - 1, depth], 'b-', alpha=0.3, lw=0.8)
            ax.plot([x2, xm], [depth - 1, depth], 'b-', alpha=0.3, lw=0.8)
            # Mark mediant
            is_fib = med[1] in fibonacci(15)
            color = 'red' if is_fib else 'steelblue'
            size = 10 if is_fib else 7
            ax.plot(xm, depth, 'o', color=color, markersize=size, zorder=5)
            ax.annotate(f"{med[0]}/{med[1]}", (xm, depth),
                       textcoords="offset points", xytext=(0, 8),
                       fontsize=7, ha='center', color=color)
        new_fracs.append(fracs[-1])
        return new_fracs

    fracs = [(0, 1), (1, 1)]
    for f in fracs:
        x = f[0] / f[1] if f[1] > 0 else 0
        ax.plot(x, 0, 'ko', markersize=8, zorder=5)
        ax.annotate(f"{f[0]}/{f[1]}", (x, 0), textcoords="offset points",
                   xytext=(0, 8), fontsize=8, ha='center')

    for depth in range(1, 6):
        fracs = draw_farey_level(fracs, depth, ax)

    # Highlight Fibonacci path
    fib = fibonacci(10)
    fib_fracs = [(fib[i], fib[i+1]) for i in range(1, 8)]
    for p, q in fib_fracs:
        if q > 0:
            x = p / q
            ax.plot(x, -0.3, '*', color='gold', markersize=15, zorder=10)

    ax.axhline(y=-0.15, color='gray', linestyle='--', alpha=0.3)
    ax.text(0.5, -0.4, "★ = Fibonacci fraction (golden ratio path)",
           ha='center', fontsize=9, color='goldenrod')

    # Right: Dynatomic degree growth
    ax = axes[1]
    periods = list(range(1, 21))
    psi = [dynatomic(n) for n in periods]
    two_n = [2**n for n in periods]

    ax.semilogy(periods, psi, 'ro-', label=r'$\Psi(n)$ (dynatomic)', markersize=6)
    ax.semilogy(periods, two_n, 'b--', label=r'$2^n$ (total periodic)', alpha=0.5)
    ax.semilogy(periods, [p / n for p, n in zip(psi, periods)], 'g^-',
               label=r'$\Psi(n)/n$ (orbits)', markersize=5)

    # Mark primes
    primes = [p for p in periods if p > 1 and all(p % d != 0 for d in range(2, p))]
    for p in primes:
        ax.axvline(x=p, color='red', alpha=0.1, lw=8)

    ax.set_xlabel("Period n", fontsize=12)
    ax.set_ylabel("Count (log scale)", fontsize=12)
    ax.set_title("Dynatomic Point Count Growth\n(shaded = prime periods)", fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_xticks(periods)

    plt.tight_layout()
    plt.savefig("farey_fibonacci_structure.png", dpi=150, bbox_inches='tight')
    print("Saved farey_fibonacci_structure.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Mandelbrot Set with Bulb Period Labels
=====================================================
"""
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors


def escape_time(c, max_iter=200):
    z = 0 + 0j
    for n in range(max_iter):
        z = z * z + c
        if abs(z) > 2:
            return n
    return max_iter


def compute_mandelbrot(xmin, xmax, ymin, ymax, width, height, max_iter=200):
    x = np.linspace(xmin, xmax, width)
    y = np.linspace(ymin, ymax, height)
    img = np.zeros((height, width))
    for j in range(height):
        for i in range(width):
            c = complex(x[i], y[j])
            img[j, i] = escape_time(c, max_iter)
    return img


def main():
    fig, axes = plt.subplots(1, 2, figsize=(16, 7))

    # Left: Full Mandelbrot set
    ax = axes[0]
    img = compute_mandelbrot(-2.2, 0.8, -1.2, 1.2, 600, 480, 100)
    ax.imshow(img, extent=[-2.2, 0.8, -1.2, 1.2], cmap='hot', origin='lower')
    ax.set_title("Mandelbrot Set with Bulb Periods", fontsize=14)
    ax.set_xlabel("Re(c)")
    ax.set_ylabel("Im(c)")

    # Label key bulbs
    bulbs = [
        (0.0, 0.0, "1", 14),
        (-1.0, 0.0, "2", 12),
        (-0.125, 0.744, "3", 10),
        (-0.125, -0.744, "3", 10),
        (0.282, 0.533, "4", 9),
        (0.282, -0.533, "4", 9),
        (-1.755, 0.0, "3", 10),
        (0.379, 0.337, "5", 8),
        (-0.156, 1.032, "5", 8),
    ]
    for x, y, label, size in bulbs:
        ax.annotate(label, (x, y), fontsize=size, color='cyan', fontweight='bold',
                   ha='center', va='center')

    # Right: Dynatomic point counts
    ax = axes[1]
    periods = list(range(1, 16))
    psi_values = []
    orbit_counts = []
    for n in periods:
        # Möbius inversion
        divs = [d for d in range(1, n+1) if n % d == 0]
        def mobius(k):
            if k == 1: return 1
            d = 2
            factors = []
            temp = k
            while d * d <= temp:
                if temp % d == 0:
                    exp = 0
                    while temp % d == 0:
                        exp += 1
                        temp //= d
                    if exp > 1: return 0
                    factors.append(d)
                d += 1
            if temp > 1: factors.append(temp)
            return (-1)**len(factors)
        psi = sum(mobius(n // d) * (2**d) for d in divs)
        psi_values.append(psi)
        orbit_counts.append(psi // n)

    colors = ['red' if all(n % p != 0 for p in range(2, n)) and n > 1
              else 'steelblue' for n in periods]
    ax.bar(periods, orbit_counts, color=colors, edgecolor='black', alpha=0.8)
    ax.set_xlabel("Period n", fontsize=12)
    ax.set_ylabel("Number of Primitive Orbits", fontsize=12)
    ax.set_title("Primitive Orbit Count by Period\n(red = prime period)", fontsize=14)
    ax.set_xticks(periods)

    # Add Ψ(n)/n formula annotation
    ax.annotate(r"$\frac{\Psi(n)}{n} = \frac{1}{n}\sum_{d|n} \mu(n/d) \cdot 2^d$",
               xy=(0.5, 0.92), xycoords='axes fraction', fontsize=11,
               ha='center', bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

    plt.tight_layout()
    plt.savefig("mandelbrot_number_theory.png", dpi=150, bbox_inches='tight')
    print("Saved mandelbrot_number_theory.png")


if __name__ == "__main__":
    main()
