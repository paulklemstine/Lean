#!/usr/bin/env python3
"""
Cyclotomic Knot Spectra — Numerical Demonstrations

Demonstrates the key results:
1. Alexander polynomial computation for T(2,n) torus knots
2. Fundamental identity verification: (X+1) · A_n(X) = X^n + 1
3. Cyclotomic bridge: A_p = Φ_{2p} for odd primes
4. Euler totient identity: φ(2n) = φ(n) for odd n
5. Spectral classification of palindromic polynomials
6. Evaluation identity: A_n(-1) = n
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


def alexander_poly_coeffs(n: int) -> list[int]:
    """Compute coefficients of Alexander polynomial A_n(X) = Σ (-X)^i for i=0..n-1."""
    return [(-1)**i for i in range(n)]


def cyclotomic_poly_coeffs(n: int) -> list[int]:
    """Compute coefficients of the n-th cyclotomic polynomial Φ_n(X) over ℤ.
    Uses the recursive formula: Φ_n(X) = (X^n - 1) / ∏_{d|n, d<n} Φ_d(X).
    """
    # Start with polynomial X^n - 1 as coefficient list
    xn_minus_1 = [-1] + [0] * (n - 1) + [1]

    # Divide by Φ_d for each proper divisor d of n
    for d in range(1, n):
        if n % d == 0:
            phi_d = cyclotomic_poly_coeffs(d)
            xn_minus_1 = poly_div(xn_minus_1, phi_d)

    return xn_minus_1


def poly_div(dividend: list[int], divisor: list[int]) -> list[int]:
    """Polynomial long division over ℤ (exact division assumed)."""
    out = list(dividend)
    normalizer = divisor[-1]
    for i in range(len(out) - 1, len(divisor) - 2, -1):
        coeff = out[i] // normalizer
        if coeff != 0:
            for j in range(len(divisor) - 1):
                out[i - (len(divisor) - 1 - j)] -= divisor[j] * coeff
        out[i] = coeff
    # Remove leading zeros
    result = out[len(divisor) - 1:]
    return result


def poly_mul(a: list[int], b: list[int]) -> list[int]:
    """Multiply two polynomials represented as coefficient lists."""
    result = [0] * (len(a) + len(b) - 1)
    for i, ai in enumerate(a):
        for j, bj in enumerate(b):
            result[i + j] += ai * bj
    return result


def poly_eval(coeffs: list[int], x: complex) -> complex:
    """Evaluate polynomial at point x."""
    return sum(c * x**i for i, c in enumerate(coeffs))


def is_palindromic(coeffs: list[int]) -> bool:
    """Check if polynomial coefficients are palindromic."""
    n = len(coeffs)
    return all(coeffs[i] == coeffs[n - 1 - i] for i in range(n // 2))


def spectral_classify(b: int) -> str:
    """Classify quadratic palindrome X² - bX + 1 as crystalline or metallic."""
    return "crystalline" if b**2 < 4 else "metallic"


def mahler_measure(coeffs: list[int], num_points: int = 10000) -> float:
    """Compute Mahler measure M(f) = exp(∫₀¹ log|f(e^{2πit})| dt) numerically."""
    t = np.linspace(0, 1, num_points, endpoint=False)
    z = np.exp(2j * np.pi * t)
    values = np.array([poly_eval(coeffs, zi) for zi in z])
    log_abs = np.log(np.maximum(np.abs(values), 1e-300))
    return np.exp(np.mean(log_abs))


def demo_fundamental_identity():
    """Verify (X+1) · A_n(X) = X^n + 1 for several odd n."""
    print("=" * 60)
    print("DEMO 1: Fundamental Identity (X+1)·A_n(X) = X^n + 1")
    print("=" * 60)
    for n in [3, 5, 7, 9, 11, 13]:
        alex = alexander_poly_coeffs(n)
        product = poly_mul(alex, [1, 1])  # multiply by (X + 1)
        # X^n + 1 has coeffs [1, 0, 0, ..., 0, 1]
        expected = [1] + [0] * (n - 1) + [1]
        match = product == expected
        print(f"  n={n:2d}: A_{n}(X) = {alex}")
        print(f"         (X+1)·A_{n} = {product}")
        print(f"         X^{n}+1     = {expected}")
        print(f"         Match: {'✓' if match else '✗'}")
        print()


def demo_cyclotomic_bridge():
    """Verify A_p = Φ_{2p} for odd primes."""
    print("=" * 60)
    print("DEMO 2: Cyclotomic Bridge A_p = Φ_{2p}")
    print("=" * 60)
    primes = [3, 5, 7, 11, 13]
    for p in primes:
        alex = alexander_poly_coeffs(p)
        cyclo = cyclotomic_poly_coeffs(2 * p)
        match = alex == cyclo
        print(f"  p={p:2d}: A_{p}(X)   = {alex}")
        print(f"        Φ_{2*p:2d}(X) = {cyclo}")
        print(f"        Match: {'✓' if match else '✗'}")
        print()


def demo_totient_identity():
    """Verify φ(2n) = φ(n) for odd n."""
    print("=" * 60)
    print("DEMO 3: Totient Identity φ(2n) = φ(n) for odd n")
    print("=" * 60)
    for n in [1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21]:
        phi_n = euler_totient(n)
        phi_2n = euler_totient(2 * n)
        match = phi_n == phi_2n
        print(f"  n={n:2d}: φ({n:2d})={phi_n:2d}, φ({2*n:2d})={phi_2n:2d}  {'✓' if match else '✗'}")
    print()


def demo_palindromicity():
    """Verify palindromic property of Alexander polynomials."""
    print("=" * 60)
    print("DEMO 4: Palindromicity of Alexander Polynomials")
    print("=" * 60)
    for n in [3, 5, 7, 9, 11]:
        coeffs = alexander_poly_coeffs(n)
        pal = is_palindromic(coeffs)
        print(f"  n={n:2d}: A_{n}(X) coefficients = {coeffs}")
        print(f"        Palindromic: {'✓' if pal else '✗'}")
    print()


def demo_spectral_dichotomy():
    """Demonstrate spectral classification of quadratic palindromes."""
    print("=" * 60)
    print("DEMO 5: Spectral Dichotomy for X² - bX + 1")
    print("=" * 60)
    for b in range(-5, 6):
        cls = spectral_classify(b)
        disc = b**2 - 4
        roots = [(b + disc**0.5) / 2, (b - disc**0.5) / 2] if disc >= 0 else None
        if roots:
            root_str = f"  roots: {roots[0]:.4f}, {roots[1]:.4f}"
        else:
            # Complex roots on unit circle
            re = b / 2
            im = (-disc)**0.5 / 2
            root_str = f"  roots: {re:.4f}±{im:.4f}i (|z|=1)"
        print(f"  b={b:3d}: disc={disc:3d}, class={cls:12s}{root_str}")
    print()


def demo_evaluation():
    """Verify A_n(-1) = n."""
    print("=" * 60)
    print("DEMO 6: Evaluation Identity A_n(-1) = n")
    print("=" * 60)
    for n in [1, 3, 5, 7, 9, 11, 13, 15]:
        coeffs = alexander_poly_coeffs(n)
        val = int(poly_eval(coeffs, -1).real)
        match = val == n
        print(f"  n={n:2d}: A_{n}(-1) = {val}  {'✓' if match else '✗'}")
    print()


def demo_mahler_measure():
    """Compute Mahler measure for Alexander polynomials (should be 1 for torus knots)."""
    print("=" * 60)
    print("DEMO 7: Mahler Measure (Spectral Rigidity)")
    print("=" * 60)
    print("  For torus knots, A_p = Φ_{2p} implies M(A_p) = 1 exactly.")
    print()
    for n in [3, 5, 7, 11, 13, 17, 19]:
        coeffs = alexander_poly_coeffs(n)
        mm = mahler_measure(coeffs)
        print(f"  n={n:2d}: M(A_{n}) ≈ {mm:.6f}  (expected: 1.000000)")
    print()


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║      CYCLOTOMIC KNOT SPECTRA — NUMERICAL DEMOS         ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    demo_fundamental_identity()
    demo_cyclotomic_bridge()
    demo_totient_identity()
    demo_palindromicity()
    demo_spectral_dichotomy()
    demo_evaluation()
    demo_mahler_measure()

    print("All demonstrations complete.")


#!/usr/bin/env python3
"""
Cyclotomic Knot Spectra — Visualization

Generates plots showing:
1. Root geometry of Alexander/cyclotomic polynomials on the unit circle
2. Spectral dichotomy phase diagram
3. Euler totient and OAM channel counts
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Circle


def alexander_poly_coeffs(n):
    """Coefficients of Alexander polynomial A_n(X)."""
    return [(-1)**i for i in range(n)]


def poly_roots(coeffs):
    """Compute roots of polynomial from coefficient list."""
    return np.roots(list(reversed(coeffs)))


def euler_totient(n):
    """Euler's totient function."""
    if n <= 0:
        return 0
    result = n
    p, temp = 2, n
    while p * p <= temp:
        if temp % p == 0:
            while temp % p == 0:
                temp //= p
            result -= result // p
        p += 1
    if temp > 1:
        result -= result // temp
    return result


def plot_roots_on_unit_circle():
    """Plot roots of Alexander polynomials on the unit circle."""
    fig, axes = plt.subplots(2, 3, figsize=(14, 9))
    primes = [3, 5, 7, 11, 13, 17]

    for ax, p in zip(axes.flat, primes):
        coeffs = alexander_poly_coeffs(p)
        roots = poly_roots(coeffs)

        # Draw unit circle
        theta = np.linspace(0, 2 * np.pi, 300)
        ax.plot(np.cos(theta), np.sin(theta), 'k-', alpha=0.3, linewidth=1)
        ax.axhline(0, color='gray', alpha=0.2, linewidth=0.5)
        ax.axvline(0, color='gray', alpha=0.2, linewidth=0.5)

        # Plot roots
        ax.scatter(roots.real, roots.imag, c='crimson', s=80, zorder=5,
                   edgecolors='black', linewidth=0.5)

        # Mark primitive 2p-th roots of unity
        for k in range(1, 2 * p):
            from math import gcd as mgcd
            if mgcd(k, 2 * p) == 1:
                angle = 2 * np.pi * k / (2 * p)
                ax.plot(np.cos(angle), np.sin(angle), 'b+', markersize=6,
                        alpha=0.4, markeredgewidth=1)

        ax.set_xlim(-1.5, 1.5)
        ax.set_ylim(-1.5, 1.5)
        ax.set_aspect('equal')
        ax.set_title(f'T(2,{p}): A_{p} = Φ_{{{2*p}}}', fontsize=12)
        ax.grid(True, alpha=0.15)

    fig.suptitle('Roots of Alexander Polynomials on the Unit Circle\n'
                 '(Red: polynomial roots, Blue +: primitive 2p-th roots of unity)',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('roots_unit_circle.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: roots_unit_circle.png")


def plot_spectral_dichotomy():
    """Plot the spectral phase diagram for quadratic palindromes."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left: discriminant landscape
    b_values = np.linspace(-5, 5, 500)
    disc = b_values**2 - 4

    ax1.fill_between(b_values, disc, where=(disc < 0), alpha=0.3, color='royalblue',
                     label='Crystalline (unit circle)')
    ax1.fill_between(b_values, disc, where=(disc >= 0), alpha=0.3, color='goldenrod',
                     label='Metallic (real roots)')
    ax1.plot(b_values, disc, 'k-', linewidth=2)
    ax1.axhline(0, color='red', linestyle='--', linewidth=1, alpha=0.7)

    # Mark integer points
    for b in range(-5, 6):
        d = b**2 - 4
        color = 'royalblue' if d < 0 else 'goldenrod'
        ax1.plot(b, d, 'o', color=color, markersize=8, markeredgecolor='black',
                 markeredgewidth=1, zorder=5)

    ax1.set_xlabel('b (middle coefficient)', fontsize=12)
    ax1.set_ylabel('Discriminant b² − 4', fontsize=12)
    ax1.set_title('Spectral Dichotomy: X² − bX + 1', fontsize=13, fontweight='bold')
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.2)

    # Right: root trajectories
    for b in np.linspace(-4, 4, 17):
        disc = b**2 - 4
        if disc < 0:
            re = b / 2
            im = np.sqrt(-disc) / 2
            ax2.plot(re, im, 'o', color='royalblue', markersize=6, alpha=0.7)
            ax2.plot(re, -im, 'o', color='royalblue', markersize=6, alpha=0.7)
        else:
            r1 = (b + np.sqrt(disc)) / 2
            r2 = (b - np.sqrt(disc)) / 2
            ax2.plot(r1, 0, 'o', color='goldenrod', markersize=6, alpha=0.7)
            ax2.plot(r2, 0, 'o', color='goldenrod', markersize=6, alpha=0.7)

    theta = np.linspace(0, 2 * np.pi, 300)
    ax2.plot(np.cos(theta), np.sin(theta), 'k-', alpha=0.3, linewidth=1)
    ax2.set_xlim(-3, 3)
    ax2.set_ylim(-1.5, 1.5)
    ax2.set_aspect('equal')
    ax2.set_xlabel('Re(z)', fontsize=12)
    ax2.set_ylabel('Im(z)', fontsize=12)
    ax2.set_title('Root Trajectories as b varies', fontsize=13, fontweight='bold')
    ax2.grid(True, alpha=0.2)

    plt.tight_layout()
    plt.savefig('spectral_dichotomy.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: spectral_dichotomy.png")


def plot_totient_channels():
    """Plot Euler totient and OAM channel counts."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left: φ(n) vs φ(2n) for odd n
    odd_n = list(range(1, 50, 2))
    phi_n = [euler_totient(n) for n in odd_n]
    phi_2n = [euler_totient(2 * n) for n in odd_n]

    ax1.scatter(phi_n, phi_2n, c='crimson', s=50, zorder=5, edgecolors='black',
                linewidth=0.5)
    max_val = max(max(phi_n), max(phi_2n))
    ax1.plot([0, max_val], [0, max_val], 'k--', alpha=0.5, label='y = x')
    ax1.set_xlabel('φ(n)', fontsize=12)
    ax1.set_ylabel('φ(2n)', fontsize=12)
    ax1.set_title('Totient Identity: φ(2n) = φ(n) for odd n', fontsize=13,
                   fontweight='bold')
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.2)

    # Right: Channel count as function of n
    all_n = list(range(1, 60))
    channels = [euler_totient(n) for n in all_n]
    colors = ['royalblue' if n % 2 == 1 else 'lightcoral' for n in all_n]

    ax2.bar(all_n, channels, color=colors, edgecolor='gray', linewidth=0.3)
    ax2.set_xlabel('Knot parameter n', fontsize=12)
    ax2.set_ylabel('OAM channels φ(n)', fontsize=12)
    ax2.set_title('OAM Channel Count by Knot Parameter\n'
                   '(Blue: odd n, Red: even n)', fontsize=13, fontweight='bold')
    ax2.grid(True, alpha=0.2, axis='y')

    plt.tight_layout()
    plt.savefig('totient_channels.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: totient_channels.png")


if __name__ == "__main__":
    print("Generating Cyclotomic Knot Spectra Visualizations...")
    plot_roots_on_unit_circle()
    plot_spectral_dichotomy()
    plot_totient_channels()
    print("All visualizations generated.")
