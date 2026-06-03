#!/usr/bin/env python3
"""
Mandelbrot Number Theory: Quadratic Recurrence and Primality — Demo

Demonstrates the connection between Mandelbrot iteration z_{n+1} = z_n^2 + c
and number theory, including orbit periodicity, Mandelbrot polynomials, and
dynatomic degree computation.
"""

from typing import Optional


def mandelbrot_iter(c: complex, n: int) -> complex:
    """Compute the n-th iterate of 0 under z -> z^2 + c."""
    z = 0
    for _ in range(n):
        z = z**2 + c
    return z


def mandelbrot_iter_mod(c: int, n: int, m: int) -> int:
    """Compute the n-th iterate of 0 under z -> z^2 + c modulo m."""
    z = 0
    for _ in range(n):
        z = (z * z + c) % m
    return z


def mandelbrot_orbit_period(c: int, m: int) -> Optional[int]:
    """
    Find the minimal period of the orbit of 0 under z -> z^2 + c mod m.
    Returns None if no return to 0 within m^2 steps.
    """
    z = 0
    for step in range(1, m * m + 1):
        z = (z * z + c) % m
        if z == 0:
            return step
    return None


def mandelbrot_orbit_signature(c: int, primes: list[int]) -> dict[int, Optional[int]]:
    """Compute the Mandelbrot orbit signature of c at each given prime."""
    return {p: mandelbrot_orbit_period(c, p) for p in primes}


def mandelbrot_poly_coeffs(n: int) -> list[int]:
    """
    Compute the coefficients of the n-th Mandelbrot polynomial P_n(c).
    P_0 = 0, P_{n+1} = P_n^2 + c (polynomial in c).
    Returns list of coefficients [a_0, a_1, ..., a_d] for a_0 + a_1*c + ... + a_d*c^d.
    """
    if n == 0:
        return [0]
    # Start with P_1 = c = [0, 1]
    p = [0, 1]
    for _ in range(n - 1):
        # Square the polynomial
        deg = len(p) - 1
        new_deg = 2 * deg
        sq = [0] * (new_deg + 1)
        for i in range(len(p)):
            for j in range(len(p)):
                sq[i + j] += p[i] * p[j]
        # Add X (which is [0, 1])
        if len(sq) < 2:
            sq.extend([0] * (2 - len(sq)))
        sq[1] += 1
        p = sq
    return p


def moebius(n: int) -> int:
    """Compute the Möbius function μ(n)."""
    if n == 1:
        return 1
    factors = []
    d = 2
    temp = n
    while d * d <= temp:
        if temp % d == 0:
            factors.append(d)
            temp //= d
            if temp % d == 0:
                return 0  # Squared factor
        d += 1
    if temp > 1:
        factors.append(temp)
    return (-1) ** len(factors)


def divisors(n: int) -> list[int]:
    """Return all divisors of n."""
    divs = []
    for d in range(1, n + 1):
        if n % d == 0:
            divs.append(d)
    return divs


def dynat_degree(n: int) -> int:
    """
    Compute the dynatomic degree at period n:
    Σ_{d|n} μ(n/d) · 2^{d-1}
    """
    return sum(moebius(n // d) * (2 ** (d - 1)) for d in divisors(n))


def count_exact_period(n: int, p: int) -> int:
    """Count elements c in Z/pZ with exact Mandelbrot orbit period n."""
    count = 0
    for c in range(p):
        period = mandelbrot_orbit_period(c, p)
        if period == n:
            count += 1
    return count


# ============================================================
# DEMONSTRATIONS
# ============================================================

if __name__ == "__main__":
    print("=" * 70)
    print("MANDELBROT NUMBER THEORY: QUADRATIC RECURRENCE AND PRIMALITY")
    print("=" * 70)

    # Demo 1: Orbit periodicity
    print("\n--- Demo 1: Orbit Shift Theorem ---")
    print("For c = -1 (period 2): orbit returns to 0 every 2 steps")
    for k in range(8):
        val = mandelbrot_iter(-1, k)
        print(f"  f^{k}(0) = {val.real:.0f}")

    # Demo 2: Period characterization
    print("\n--- Demo 2: Period Classification ---")
    print("Period 1 (c = 0):", [mandelbrot_iter(0, k) for k in range(5)])
    print("Period 2 (c = -1):", [mandelbrot_iter(-1, k) for k in range(5)])

    # Demo 3: Mandelbrot polynomials
    print("\n--- Demo 3: Mandelbrot Polynomials ---")
    for n in range(1, 6):
        coeffs = mandelbrot_poly_coeffs(n)
        degree = len(coeffs) - 1
        expected_deg = 2 ** (n - 1)
        print(f"  P_{n}: degree = {degree} (expected 2^{n-1} = {expected_deg}), "
              f"coeffs = {coeffs}")

    # Demo 4: Dynatomic degrees
    print("\n--- Demo 4: Dynatomic Degrees ---")
    for n in range(1, 9):
        dd = dynat_degree(n)
        print(f"  dynatDegree({n}) = {dd}")

    # Demo 5: Orbit signatures
    print("\n--- Demo 5: Mandelbrot Orbit Signatures ---")
    primes = [2, 3, 5, 7, 11, 13, 17, 19, 23]
    for c_val in [0, -1, 1, -2, 3]:
        sig = mandelbrot_orbit_signature(c_val, primes)
        print(f"  c = {c_val:3d}: signature = {sig}")

    # Demo 6: Conjecture verification — exact period counts vs dynatomic degree
    print("\n--- Demo 6: Conjecture Test — Period Counts vs Dynatomic Degree ---")
    print("  For each period n, count c ∈ F_p with exact period n:")
    test_primes = [29, 31, 37, 41, 43]
    for n in range(1, 6):
        dd = dynat_degree(n)
        print(f"  Period {n} (dynatDegree = {dd}):")
        for p in test_primes:
            count = count_exact_period(n, p)
            match_str = "✓" if count == dd else "✗"
            print(f"    p={p}: count={count} {match_str}")

    # Demo 7: Prime factorization of P_n values
    print("\n--- Demo 7: Prime Factors of Mandelbrot Iterates ---")
    print("  P_n(1) for n = 1..7:")
    for n in range(1, 8):
        val = int(mandelbrot_iter(1, n).real)
        print(f"    P_{n}(1) = {val}")

    print("\n" + "=" * 70)
    print("All demonstrations complete.")


#!/usr/bin/env python3
"""
Visualization: Mandelbrot Orbit Periods over Finite Fields

For each prime p, colors the elements of Z/pZ by their Mandelbrot orbit period.
Reveals the number-theoretic structure hidden in the Mandelbrot iteration.
"""

import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import numpy as np


def mandelbrot_orbit_period(c: int, p: int) -> int:
    """Find minimal period of orbit of 0 under z -> z^2 + c mod p, or 0."""
    z = 0
    for step in range(1, p * p + 1):
        z = (z * z + c) % p
        if z == 0:
            return step
    return 0


def moebius(n: int) -> int:
    if n == 1:
        return 1
    factors = []
    d = 2
    temp = n
    while d * d <= temp:
        if temp % d == 0:
            factors.append(d)
            temp //= d
            if temp % d == 0:
                return 0
        d += 1
    if temp > 1:
        factors.append(temp)
    return (-1) ** len(factors)


def divisors(n: int) -> list:
    return [d for d in range(1, n + 1) if n % d == 0]


def dynat_degree(n: int) -> int:
    return sum(moebius(n // d) * (2 ** (d - 1)) for d in divisors(n))


def main():
    primes = [7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]

    fig, axes = plt.subplots(3, 4, figsize=(16, 10))
    fig.suptitle("Mandelbrot Orbit Periods over Finite Fields $\\mathbb{F}_p$",
                 fontsize=16, fontweight='bold')

    cmap = plt.cm.Set3
    max_period = 12

    for idx, p in enumerate(primes):
        ax = axes[idx // 4][idx % 4]

        periods = [mandelbrot_orbit_period(c, p) for c in range(p)]

        colors_list = [cmap(per / max_period) if per > 0 else (0.2, 0.2, 0.2, 1)
                       for per in periods]

        bars = ax.bar(range(p), [1] * p, color=colors_list, width=1.0, edgecolor='none')
        ax.set_title(f"$p = {p}$", fontsize=11)
        ax.set_xlim(-0.5, p - 0.5)
        ax.set_ylim(0, 1.2)
        ax.set_yticks([])
        ax.set_xlabel("$c$", fontsize=9)

        # Annotate period counts
        from collections import Counter
        period_counts = Counter(periods)
        summary = ", ".join(f"{per}:{cnt}" for per, cnt in sorted(period_counts.items()) if per > 0)
        ax.text(p / 2, 1.05, summary, ha='center', fontsize=6, color='gray')

    plt.tight_layout()
    plt.savefig("mandelbrot_periods_finite_fields.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: mandelbrot_periods_finite_fields.png")

    # Second figure: dynatomic degree vs actual counts
    fig2, ax2 = plt.subplots(figsize=(10, 6))
    test_primes_large = [53, 59, 61, 67, 71]
    periods_to_test = range(1, 8)

    for p in test_primes_large:
        counts = []
        for n in periods_to_test:
            count = sum(1 for c in range(p) if mandelbrot_orbit_period(c, p) == n)
            counts.append(count)
        ax2.plot(list(periods_to_test), counts, 'o-', label=f'$p={p}$', alpha=0.7)

    dd_values = [dynat_degree(n) for n in periods_to_test]
    ax2.plot(list(periods_to_test), dd_values, 'k--', linewidth=2,
             label='dynatDegree (predicted)', marker='s', markersize=8)

    ax2.set_xlabel("Period $n$", fontsize=12)
    ax2.set_ylabel("Count of $c \\in \\mathbb{F}_p$ with exact period $n$", fontsize=12)
    ax2.set_title("Dynatomic Degree Conjecture: Predicted vs Actual Counts", fontsize=14)
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig("dynatomic_degree_conjecture.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: dynatomic_degree_conjecture.png")


if __name__ == "__main__":
    main()
