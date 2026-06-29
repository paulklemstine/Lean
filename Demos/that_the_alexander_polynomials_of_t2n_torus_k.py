#!/usr/bin/env python3
"""
Cyclotomic Knot Spectra: Numerical Demonstrations

Demonstrates the key results:
1. Alexander polynomials of T(2,n) torus knots
2. The fundamental identity (X+1)·A_n(X) = X^n + 1
3. Cyclotomic bridge: A_p = Φ_{2p} for prime p
4. Spectral dichotomy classification
5. OAM channel counting via Euler's totient
"""

import numpy as np
from math import gcd
from functools import reduce


def euler_totient(n: int) -> int:
    """Compute Euler's totient function φ(n)."""
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


def alexander_t2n(n: int) -> list[int]:
    """
    Compute the Alexander polynomial A_n(X) of T(2,n) as a coefficient list.
    A_n(X) = Σ_{i=0}^{n-1} (-1)^i X^i
    Returns [a_0, a_1, ..., a_{n-1}].
    """
    return [(-1)**i for i in range(n)]


def poly_multiply(p: list[int], q: list[int]) -> list[int]:
    """Multiply two polynomials represented as coefficient lists."""
    if not p or not q:
        return []
    result = [0] * (len(p) + len(q) - 1)
    for i, a in enumerate(p):
        for j, b in enumerate(q):
            result[i + j] += a * b
    return result


def poly_eval(coeffs: list[int], x: complex) -> complex:
    """Evaluate polynomial at x using Horner's method."""
    result = complex(0)
    for c in reversed(coeffs):
        result = result * x + c
    return result


def cyclotomic_poly(n: int) -> list[int]:
    """
    Compute the n-th cyclotomic polynomial Φ_n(X) using the Möbius function.
    Returns integer coefficient list.
    """
    if n == 1:
        return [-1, 1]  # X - 1

    # Start with X^n - 1
    xn_minus_1 = [-1] + [0] * (n - 1) + [1]

    # Divide by Φ_d for each proper divisor d of n
    divisors = [d for d in range(1, n) if n % d == 0]

    result = xn_minus_1[:]
    for d in sorted(divisors):
        phi_d = cyclotomic_poly(d)
        # Polynomial division
        result = poly_divide(result, phi_d)

    return result


def poly_divide(dividend: list[int], divisor: list[int]) -> list[int]:
    """Exact polynomial division (assumes divisor divides dividend)."""
    # Remove trailing zeros
    while len(dividend) > 1 and dividend[-1] == 0:
        dividend = dividend[:-1]
    while len(divisor) > 1 and divisor[-1] == 0:
        divisor = divisor[:-1]

    if len(dividend) < len(divisor):
        return [0]

    quotient = [0] * (len(dividend) - len(divisor) + 1)
    remainder = dividend[:]

    for i in range(len(quotient) - 1, -1, -1):
        quotient[i] = remainder[i + len(divisor) - 1] // divisor[-1]
        for j in range(len(divisor)):
            remainder[i + j] -= quotient[i] * divisor[j]

    return quotient


def palindromic_discriminant(b: int) -> int:
    """Discriminant of palindromic quadratic X^2 + bX + 1."""
    return b * b - 4


def spectral_type(b: int) -> str:
    """Classify the spectral type of a palindromic quadratic."""
    d = palindromic_discriminant(b)
    if d < 0:
        return "crystalline"
    elif d > 0:
        return "metallic"
    else:
        return "degenerate"


def knot_determinant(n: int) -> int:
    """Compute the knot determinant |A_n(-1)| for T(2,n)."""
    coeffs = alexander_t2n(n)
    val = int(round(poly_eval(coeffs, -1).real))
    return abs(val)


def demo_fundamental_identity():
    """Demonstrate (X+1) · A_n(X) = X^n + 1 for odd n."""
    print("=" * 60)
    print("FUNDAMENTAL IDENTITY: (X+1) · A_n(X) = X^n + 1")
    print("=" * 60)

    for n in [3, 5, 7, 9, 11, 13, 15]:
        a_n = alexander_t2n(n)
        x_plus_1 = [1, 1]  # 1 + X
        product = poly_multiply(x_plus_1, a_n)

        # X^n + 1
        xn_plus_1 = [1] + [0] * (n - 1) + [1]

        match = product == xn_plus_1
        print(f"  n={n:2d}: A_n = {a_n}")
        print(f"         (X+1)·A_n = {product}")
        print(f"         X^{n}+1   = {xn_plus_1}")
        print(f"         Match: {match}")
        print()


def demo_cyclotomic_bridge():
    """Demonstrate A_p = Φ_{2p} for prime p."""
    print("=" * 60)
    print("CYCLOTOMIC BRIDGE: A_p = Φ_{2p} for prime p")
    print("=" * 60)

    primes = [3, 5, 7, 11, 13]
    for p in primes:
        a_p = alexander_t2n(p)
        phi_2p = cyclotomic_poly(2 * p)

        match = a_p == phi_2p
        print(f"  p={p:2d}: A_p    = {a_p}")
        print(f"         Φ_{2*p:<3d}  = {phi_2p}")
        print(f"         Match: {match}")
        print()


def demo_spectral_dichotomy():
    """Demonstrate the spectral classification."""
    print("=" * 60)
    print("SPECTRAL DICHOTOMY: Crystalline vs Metallic")
    print("=" * 60)

    cases = [
        ("Trefoil T(2,3)", -1),
        ("Zero coeff", 0),
        ("b = 1", 1),
        ("b = -2 (degenerate)", -2),
        ("b = 2 (degenerate)", 2),
        ("Figure-eight", -3),
        ("b = 3", 3),
        ("b = -5", -5),
    ]

    for name, b in cases:
        d = palindromic_discriminant(b)
        st = spectral_type(b)
        print(f"  {name:25s}: b={b:3d}, Δ={d:3d}, type={st}")

    print()


def demo_oam_channels():
    """Demonstrate OAM channel counting via Euler's totient."""
    print("=" * 60)
    print("OAM CHANNEL COUNT: φ(2n) = φ(n) for odd n")
    print("=" * 60)

    for n in [3, 5, 7, 9, 11, 13, 15, 17, 19, 21]:
        phi_2n = euler_totient(2 * n)
        phi_n = euler_totient(n)
        print(f"  n={n:2d}: φ(2·{n:2d}) = {phi_2n:2d}, φ({n:2d}) = {phi_n:2d}, "
              f"equal: {phi_2n == phi_n}")

    print()


def demo_knot_determinants():
    """Demonstrate |A_n(-1)| = n."""
    print("=" * 60)
    print("KNOT DETERMINANT: |A_n(-1)| = n")
    print("=" * 60)

    for n in range(1, 20):
        det = knot_determinant(n)
        print(f"  n={n:2d}: |A_n(-1)| = {det:2d}, equals n: {det == n}")

    print()


def demo_roots():
    """Visualize root distribution of Alexander polynomials."""
    print("=" * 60)
    print("ROOT GEOMETRY: Crystalline vs Metallic Spectra")
    print("=" * 60)

    # Trefoil: X^2 - X + 1 (crystalline)
    disc_trefoil = palindromic_discriminant(-1)
    roots_trefoil = [
        (1 + 1j * np.sqrt(-disc_trefoil)) / 2,
        (1 - 1j * np.sqrt(-disc_trefoil)) / 2,
    ]
    print(f"\n  Trefoil (b=-1, Δ={disc_trefoil}):")
    for r in roots_trefoil:
        print(f"    root = {r:.6f}, |root| = {abs(r):.6f}")

    # Figure-eight: X^2 - 3X + 1 (metallic)
    disc_fe = palindromic_discriminant(-3)
    roots_fe = [
        (3 + np.sqrt(disc_fe)) / 2,
        (3 - np.sqrt(disc_fe)) / 2,
    ]
    print(f"\n  Figure-eight (b=-3, Δ={disc_fe}):")
    for r in roots_fe:
        print(f"    root = {r:.6f}, |root| = {abs(r):.6f}")

    # Cinquefoil T(2,5): roots of X^4 - X^3 + X^2 - X + 1
    coeffs_5 = alexander_t2n(5)
    np_coeffs = np.array(coeffs_5, dtype=float)
    roots_5 = np.roots(np_coeffs[::-1])
    print(f"\n  Cinquefoil T(2,5):")
    for r in sorted(roots_5, key=lambda z: np.angle(z)):
        print(f"    root = {r:.6f}, |root| = {abs(r):.6f}")

    print()


def demo_degree_genus():
    """Demonstrate degree and Seifert genus."""
    print("=" * 60)
    print("DEGREE AND SEIFERT GENUS")
    print("=" * 60)

    for n in [3, 5, 7, 9, 11, 13, 15]:
        degree = n - 1
        genus = degree // 2
        channels = euler_totient(n)
        print(f"  T(2,{n:2d}): degree={degree:2d}, genus={genus}, "
              f"channels={channels}")

    print()


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║     CYCLOTOMIC KNOT SPECTRA: Numerical Demonstrations   ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    demo_fundamental_identity()
    demo_cyclotomic_bridge()
    demo_spectral_dichotomy()
    demo_oam_channels()
    demo_knot_determinants()
    demo_roots()
    demo_degree_genus()

    print("All demonstrations complete.")


#!/usr/bin/env python3
"""
Visualization: OAM Channel Count via Euler's Totient

Shows how the number of independent OAM channels in T(2,n)
knotted beams scales with n, following φ(n).
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def euler_totient(n: int) -> int:
    """Compute Euler's totient function φ(n)."""
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


def is_prime(n: int) -> bool:
    """Check if n is prime."""
    if n < 2:
        return False
    for i in range(2, int(n**0.5) + 1):
        if n % i == 0:
            return False
    return True


def main():
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    fig.suptitle('OAM Channel Count for T(2,n) Torus Knots',
                 fontsize=16, fontweight='bold')

    # Odd n values from 3 to 49
    n_values = list(range(3, 50, 2))
    channels = [euler_totient(n) for n in n_values]
    primes = [is_prime(n) for n in n_values]

    # Panel 1: Channel count vs n
    prime_n = [n for n, p in zip(n_values, primes) if p]
    prime_ch = [c for c, p in zip(channels, primes) if p]
    composite_n = [n for n, p in zip(n_values, primes) if not p]
    composite_ch = [c for c, p in zip(channels, primes) if not p]

    ax1.bar(prime_n, prime_ch, color='#3498db', alpha=0.8,
            label='Prime n (channels = n-1)', width=1.5)
    ax1.bar(composite_n, composite_ch, color='#e74c3c', alpha=0.8,
            label='Composite n (channels = φ(n))', width=1.5)

    # Reference line n-1
    ax1.plot(n_values, [n-1 for n in n_values], 'k--', alpha=0.3,
             label='n-1 (upper bound)')

    ax1.set_xlabel('n (parameter of T(2,n))', fontsize=12)
    ax1.set_ylabel('Number of OAM channels φ(n)', fontsize=12)
    ax1.set_title('Channel Count: Prime vs Composite', fontsize=13)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Panel 2: Efficiency ratio φ(n)/n
    efficiency = [euler_totient(n)/n for n in n_values]
    colors = ['#3498db' if is_prime(n) else '#e74c3c' for n in n_values]

    ax2.scatter(n_values, efficiency, c=colors, s=60, zorder=5,
                edgecolors='black', linewidths=0.5)

    # Add labels for notable points
    notable = {3: 'Trefoil', 5: 'Cinquefoil', 7: 'T(2,7)',
               15: 'T(2,15)', 21: 'T(2,21)'}
    for n, name in notable.items():
        if n in n_values:
            eff = euler_totient(n) / n
            ax2.annotate(name, (n, eff), textcoords="offset points",
                         xytext=(5, 8), fontsize=9)

    ax2.set_xlabel('n (parameter of T(2,n))', fontsize=12)
    ax2.set_ylabel('Channel efficiency φ(n)/n', fontsize=12)
    ax2.set_title('Channel Efficiency Ratio', fontsize=13)
    ax2.set_ylim(0, 1.05)
    ax2.grid(True, alpha=0.3)

    # Add text annotation
    ax2.text(0.95, 0.95, 'Blue = prime n\nRed = composite n',
             transform=ax2.transAxes, fontsize=10, va='top', ha='right',
             bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

    plt.tight_layout()
    plt.savefig('oam_channels.png', dpi=150, bbox_inches='tight')
    print("Saved oam_channels.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Spectral Dichotomy — Crystalline vs Metallic

Shows how the palindromic discriminant b² - 4 controls whether
roots lie on the unit circle (crystalline) or on the real line (metallic).
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def main():
    fig, (ax1, ax2, ax3) = plt.subplots(1, 3, figsize=(18, 6))
    fig.suptitle('Spectral Dichotomy: Crystalline vs Metallic Spectra',
                 fontsize=16, fontweight='bold')

    # Panel 1: Discriminant as a function of b
    b_range = np.linspace(-5, 5, 200)
    disc = b_range**2 - 4

    ax1.fill_between(b_range, disc, 0, where=(disc < 0),
                     color='#3498db', alpha=0.3, label='Crystalline (Δ<0)')
    ax1.fill_between(b_range, disc, 0, where=(disc > 0),
                     color='#e74c3c', alpha=0.3, label='Metallic (Δ>0)')
    ax1.plot(b_range, disc, 'k-', linewidth=2)
    ax1.axhline(y=0, color='k', linewidth=0.5, linestyle='--')

    # Mark specific knots
    knot_b = {'Trefoil\n(b=-1)': -1, 'Fig-8\n(b=-3)': -3}
    for name, b in knot_b.items():
        d = b**2 - 4
        color = '#3498db' if d < 0 else '#e74c3c'
        ax1.scatter([b], [d], c=color, s=100, zorder=5, edgecolors='black')
        ax1.annotate(name, (b, d), textcoords="offset points",
                     xytext=(0, 15), ha='center', fontsize=9)

    ax1.set_xlabel('Middle coefficient b', fontsize=12)
    ax1.set_ylabel('Discriminant Δ = b² - 4', fontsize=12)
    ax1.set_title('Palindromic Discriminant', fontsize=13)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Panel 2: Crystalline example (trefoil, b=-1)
    theta = np.linspace(0, 2*np.pi, 200)
    ax2.plot(np.cos(theta), np.sin(theta), 'k-', alpha=0.3, linewidth=1)
    ax2.axhline(y=0, color='k', alpha=0.2, linewidth=0.5)
    ax2.axvline(x=0, color='k', alpha=0.2, linewidth=0.5)

    # Roots of X^2 - X + 1: (1 ± i√3)/2
    r1 = complex(0.5, np.sqrt(3)/2)
    r2 = complex(0.5, -np.sqrt(3)/2)
    ax2.scatter([r1.real, r2.real], [r1.imag, r2.imag],
                c='#3498db', s=120, zorder=5, edgecolors='black', linewidths=1.5)
    ax2.annotate(f'e^{{iπ/3}}', (r1.real, r1.imag), textcoords="offset points",
                 xytext=(10, 5), fontsize=11, color='#3498db')
    ax2.annotate(f'e^{{-iπ/3}}', (r2.real, r2.imag), textcoords="offset points",
                 xytext=(10, -15), fontsize=11, color='#3498db')

    ax2.set_xlim(-1.5, 1.5)
    ax2.set_ylim(-1.5, 1.5)
    ax2.set_aspect('equal')
    ax2.set_title('Crystalline: Trefoil (b=-1)\nRoots on |z|=1', fontsize=13)
    ax2.grid(True, alpha=0.2)

    # Panel 3: Metallic example (figure-eight, b=-3)
    ax3.plot(np.cos(theta), np.sin(theta), 'k-', alpha=0.3, linewidth=1)
    ax3.axhline(y=0, color='k', alpha=0.2, linewidth=0.5)
    ax3.axvline(x=0, color='k', alpha=0.2, linewidth=0.5)

    # Roots of X^2 - 3X + 1: (3 ± √5)/2
    phi = (3 + np.sqrt(5)) / 2  # ≈ 2.618
    phi_inv = (3 - np.sqrt(5)) / 2  # ≈ 0.382
    ax3.scatter([phi, phi_inv], [0, 0],
                c='#e74c3c', s=120, zorder=5, edgecolors='black', linewidths=1.5)
    ax3.annotate(f'φ² ≈ {phi:.3f}', (phi, 0), textcoords="offset points",
                 xytext=(5, 15), fontsize=11, color='#e74c3c')
    ax3.annotate(f'1/φ² ≈ {phi_inv:.3f}', (phi_inv, 0), textcoords="offset points",
                 xytext=(-15, 15), fontsize=11, color='#e74c3c')

    ax3.set_xlim(-0.5, 3.0)
    ax3.set_ylim(-1.5, 1.5)
    ax3.set_aspect('equal')
    ax3.set_title('Metallic: Figure-Eight (b=-3)\nReal roots (golden ratio)', fontsize=13)
    ax3.grid(True, alpha=0.2)

    plt.tight_layout()
    plt.savefig('spectral_dichotomy.png', dpi=150, bbox_inches='tight')
    print("Saved spectral_dichotomy.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Root Geometry of Alexander Polynomials

Plots the roots of Alexander polynomials for various T(2,n) torus knots
on the complex plane, showing the crystalline (unit circle) structure.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import Circle


def alexander_coefficients(n: int) -> list[int]:
    """Coefficient list of A_n(X) = Σ (-1)^i X^i."""
    return [(-1)**i for i in range(n)]


def compute_roots(n: int) -> np.ndarray:
    """Compute roots of A_n(X) using numpy."""
    coeffs = alexander_coefficients(n)
    # numpy.roots expects coefficients in descending order
    return np.roots(coeffs[::-1])


def main():
    fig, axes = plt.subplots(2, 3, figsize=(15, 10))
    fig.suptitle('Roots of Alexander Polynomials for T(2,n) Torus Knots',
                 fontsize=16, fontweight='bold')

    knots = [3, 5, 7, 9, 11, 13]
    colors = ['#e74c3c', '#3498db', '#2ecc71', '#9b59b6', '#f39c12', '#1abc9c']

    for idx, (n, color) in enumerate(zip(knots, colors)):
        ax = axes[idx // 3][idx % 3]

        # Unit circle
        theta = np.linspace(0, 2*np.pi, 200)
        ax.plot(np.cos(theta), np.sin(theta), 'k-', alpha=0.3, linewidth=1)
        ax.axhline(y=0, color='k', alpha=0.2, linewidth=0.5)
        ax.axvline(x=0, color='k', alpha=0.2, linewidth=0.5)

        # Compute and plot roots
        roots = compute_roots(n)
        ax.scatter(roots.real, roots.imag, c=color, s=80, zorder=5,
                   edgecolors='black', linewidths=0.5)

        # Annotate root moduli
        moduli = np.abs(roots)
        on_circle = np.all(np.abs(moduli - 1.0) < 1e-10)

        ax.set_title(f'T(2,{n}): {"All on |z|=1" if on_circle else "Mixed"}',
                     fontsize=12)
        ax.set_xlim(-1.5, 1.5)
        ax.set_ylim(-1.5, 1.5)
        ax.set_aspect('equal')
        ax.grid(True, alpha=0.2)

        # Add degree and channel count
        channels = euler_totient_simple(n)
        ax.text(0.05, 0.95, f'deg={n-1}, φ(n)={channels}',
                transform=ax.transAxes, fontsize=9, va='top',
                bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

    plt.tight_layout()
    plt.savefig('root_geometry.png', dpi=150, bbox_inches='tight')
    print("Saved root_geometry.png")


def euler_totient_simple(n: int) -> int:
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


if __name__ == "__main__":
    main()
