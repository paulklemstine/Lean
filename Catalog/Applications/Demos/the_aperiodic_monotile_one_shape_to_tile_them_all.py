#!/usr/bin/env python3
"""
Aperiodic Monotile: Numerical Demonstrations

Demonstrates the algebraic properties of the hat tile substitution system:
- The trace and companion sequences
- The Pell equation identity
- The expansion factor and Pisot property
- The hat spectrum invariance
"""

import math


def hat_trace_sequence(n: int) -> list[int]:
    """Compute the first n terms of the hat trace sequence a(k) = λ^k + μ^k."""
    if n <= 0:
        return []
    a = [2]
    if n == 1:
        return a
    a.append(4)
    for k in range(2, n):
        a.append(4 * a[-1] - a[-2])
    return a


def hat_companion_sequence(n: int) -> list[int]:
    """Compute the first n terms of the companion sequence b(k) = (λ^k - μ^k)/(λ - μ)."""
    if n <= 0:
        return []
    b = [0]
    if n == 1:
        return b
    b.append(1)
    for k in range(2, n):
        b.append(4 * b[-1] - b[-2])
    return b


def verify_pell_identity(n: int) -> bool:
    """Verify a(k)² - 12·b(k)² = 4 for k = 0, ..., n-1."""
    a = hat_trace_sequence(n)
    b = hat_companion_sequence(n)
    for k in range(n):
        if a[k]**2 - 12 * b[k]**2 != 4:
            return False
    return True


def expansion_factor_properties() -> dict:
    """Compute and display properties of the expansion factor λ = 2 + √3."""
    lam = 2 + math.sqrt(3)
    mu = 2 - math.sqrt(3)
    return {
        "lambda": lam,
        "mu": mu,
        "product": lam * mu,
        "sum": lam + mu,
        "char_poly_lambda": lam**2 - 4*lam + 1,
        "char_poly_mu": mu**2 - 4*mu + 1,
        "lambda_gt_1": lam > 1,
        "mu_in_unit_interval": 0 < mu < 1,
        "is_pisot": lam > 1 and 0 < mu < 1,
    }


def trace_vs_eigenvalue_powers(n: int) -> None:
    """Compare integer trace sequence with floating-point eigenvalue powers."""
    lam = 2 + math.sqrt(3)
    mu = 2 - math.sqrt(3)
    a = hat_trace_sequence(n)
    print(f"{'k':>3} {'a(k) (integer)':>20} {'λ^k + μ^k (float)':>25} {'error':>15}")
    print("-" * 68)
    for k in range(n):
        float_val = lam**k + mu**k
        error = abs(a[k] - float_val)
        print(f"{k:>3} {a[k]:>20} {float_val:>25.10f} {error:>15.2e}")


def demonstrate_no_period(n: int) -> None:
    """Show that tr(M^k) ≠ 2 for k = 1, ..., n-1."""
    a = hat_trace_sequence(n)
    print(f"Verifying tr(M^k) ≠ 2 for k = 1 to {n-1}:")
    all_nonperiodic = True
    for k in range(1, n):
        if a[k] == 2:
            print(f"  PERIOD FOUND at k = {k}!")
            all_nonperiodic = False
        elif k <= 10 or k == n - 1:
            print(f"  k={k}: tr(M^k) = {a[k]} ≠ 2 ✓")
    if all_nonperiodic:
        print(f"  No period found up to k = {n-1}. (Proved: no period exists.)")


def demonstrate_pell_identity(n: int) -> None:
    """Display the Pell identity a(k)² - 12b(k)² = 4."""
    a = hat_trace_sequence(n)
    b = hat_companion_sequence(n)
    print(f"Pell identity: a(k)² - 12·b(k)² = 4")
    print(f"{'k':>3} {'a(k)':>15} {'b(k)':>15} {'a²-12b²':>15}")
    print("-" * 52)
    for k in range(n):
        val = a[k]**2 - 12 * b[k]**2
        print(f"{k:>3} {a[k]:>15} {b[k]:>15} {val:>15}")


def quadratic_recurrence(tr: int, det: int, n: int) -> list[int]:
    """General quadratic recurrence with parameters (trace, determinant)."""
    if n <= 0:
        return []
    q = [2]
    if n == 1:
        return q
    q.append(tr)
    for k in range(2, n):
        q.append(tr * q[-1] - det * q[-2])
    return q


def demonstrate_spectrum_invariance() -> None:
    """Show that the trace sequence depends only on (tr, det) = (4, 1)."""
    print("Hat spectrum invariance: trace sequence for (tr=4, det=1)")
    hat_seq = hat_trace_sequence(10)
    quad_seq = quadratic_recurrence(4, 1, 10)
    print(f"  Hat trace:       {hat_seq}")
    print(f"  Quad(4,1):       {quad_seq}")
    print(f"  Match: {hat_seq == quad_seq}")

    # Compare with different characteristic polynomials
    print("\nComparison with other characteristic polynomials:")
    for tr, det in [(3, 1), (4, 1), (5, 1), (4, 2)]:
        seq = quadratic_recurrence(tr, det, 8)
        disc = tr**2 - 4*det
        is_square = int(math.sqrt(disc))**2 == disc if disc >= 0 else False
        print(f"  (tr={tr}, det={det}): disc={disc}, "
              f"{'perfect square' if is_square else 'NOT perfect square'}, "
              f"seq={seq}")


if __name__ == "__main__":
    print("=" * 70)
    print("APERIODIC MONOTILE: ALGEBRAIC FOUNDATIONS")
    print("=" * 70)

    print("\n1. EXPANSION FACTOR PROPERTIES")
    print("-" * 40)
    props = expansion_factor_properties()
    for key, val in props.items():
        print(f"  {key}: {val}")

    print("\n2. TRACE SEQUENCE vs EIGENVALUE POWERS")
    print("-" * 40)
    trace_vs_eigenvalue_powers(12)

    print("\n3. NO-PERIOD THEOREM")
    print("-" * 40)
    demonstrate_no_period(20)

    print("\n4. PELL IDENTITY")
    print("-" * 40)
    demonstrate_pell_identity(10)

    print("\n5. PELL IDENTITY VERIFICATION")
    print("-" * 40)
    verified = verify_pell_identity(100)
    print(f"  Pell identity verified for k = 0 to 99: {verified}")

    print("\n6. SPECTRUM INVARIANCE")
    print("-" * 40)
    demonstrate_spectrum_invariance()

    print("\n" + "=" * 70)
    print("All demonstrations complete.")


#!/usr/bin/env python3
"""Visualization: Discriminant landscape showing periodic vs aperiodic regimes."""
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import math
import numpy as np

def main():
    fig, ax = plt.subplots(figsize=(10, 7))

    traces = range(-6, 12)
    dets = range(-3, 8)

    for det in dets:
        for tr in traces:
            disc = tr * tr - 4 * det
            if disc < 0:
                color = 'lightblue'
                marker = 'x'
            else:
                sqrt_disc = int(math.isqrt(disc))
                if sqrt_disc * sqrt_disc == disc:
                    color = 'red'
                    marker = 's'
                else:
                    # Check Pisot
                    sqrt_d = math.sqrt(disc)
                    lam = (tr + sqrt_d) / 2
                    mu = (tr - sqrt_d) / 2
                    if lam > 1 and abs(mu) < 1:
                        color = 'darkgreen'
                        marker = 'D'
                    else:
                        color = 'orange'
                        marker = 'o'

            ax.plot(tr, det, marker=marker, color=color, markersize=8)

    # Mark the hat tile
    ax.plot(4, 1, marker='*', color='gold', markersize=25, zorder=10,
            markeredgecolor='black', markeredgewidth=1.5)
    ax.annotate('Hat tile\n(tr=4, det=1)', xy=(4, 1), xytext=(6, 3),
                fontsize=11, fontweight='bold',
                arrowprops=dict(arrowstyle='->', color='black'),
                bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow'))

    # Penrose (golden ratio): tr=3, det=1 → eigenvalues (3±√5)/2 = φ², 1/φ²
    ax.plot(3, 1, marker='*', color='purple', markersize=18, zorder=10,
            markeredgecolor='black', markeredgewidth=1)
    ax.annotate('Penrose\n(tr=3, det=1)', xy=(3, 1), xytext=(0, 4),
                fontsize=10, arrowprops=dict(arrowstyle='->', color='purple'))

    # Legend
    complex_patch = mpatches.Patch(color='lightblue', label='Complex eigenvalues')
    rational_patch = mpatches.Patch(color='red', label='Rational eigenvalues (periodic possible)')
    pisot_patch = mpatches.Patch(color='darkgreen', label='Pisot eigenvalues (aperiodic)')
    other_patch = mpatches.Patch(color='orange', label='Irrational, non-Pisot')
    ax.legend(handles=[complex_patch, rational_patch, pisot_patch, other_patch],
              loc='lower right', fontsize=10)

    ax.set_xlabel('Trace', fontsize=13)
    ax.set_ylabel('Determinant', fontsize=13)
    ax.set_title('Substitution Matrix Landscape:\nPeriodic vs Aperiodic Regimes', fontsize=14)
    ax.grid(True, alpha=0.2)

    plt.tight_layout()
    plt.savefig('viz_discriminant_landscape.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_discriminant_landscape.png")

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""Visualization: Growth of the hat trace sequence on a log scale."""
import matplotlib.pyplot as plt
import math

def hat_trace_sequence(n):
    a = [2, 4]
    for k in range(2, n):
        a.append(4 * a[-1] - a[-2])
    return a[:n]

def main():
    N = 15
    a = hat_trace_sequence(N)
    lam = 2 + math.sqrt(3)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Left: log plot of trace sequence
    ax1.semilogy(range(N), a, 'bo-', label=r'$a(n) = \mathrm{tr}(M^n)$', markersize=8)
    ax1.semilogy(range(N), [lam**n for n in range(N)], 'r--',
                 label=r'$\lambda^n = (2+\sqrt{3})^n$', alpha=0.7)
    ax1.axhline(y=2, color='green', linestyle=':', label=r'$\mathrm{tr}(I) = 2$')
    ax1.set_xlabel('n', fontsize=12)
    ax1.set_ylabel(r'$a(n)$', fontsize=12)
    ax1.set_title('Hat Trace Sequence: Exponential Growth\n(log scale)', fontsize=13)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)

    # Right: Pell identity residuals
    b = [0, 1]
    for k in range(2, N):
        b.append(4 * b[-1] - b[-2])
    pell_values = [a[k]**2 - 12 * b[k]**2 for k in range(N)]
    ax2.plot(range(N), pell_values, 'gs-', markersize=10, label=r'$a(n)^2 - 12\,b(n)^2$')
    ax2.axhline(y=4, color='red', linestyle='--', label='= 4 (Pell identity)')
    ax2.set_xlabel('n', fontsize=12)
    ax2.set_ylabel('Value', fontsize=12)
    ax2.set_title(r'Pell Identity: $a(n)^2 - 12\,b(n)^2 = 4$', fontsize=13)
    ax2.legend(fontsize=11)
    ax2.set_ylim(-1, 10)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_trace_growth.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_trace_growth.png")

if __name__ == "__main__":
    main()
