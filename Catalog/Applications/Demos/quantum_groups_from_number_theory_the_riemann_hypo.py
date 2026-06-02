#!/usr/bin/env python3
"""
Quantum Group Casimir Spectrum — Numerical Demonstrations

Demonstrates the key results from the q-Casimir spectral theory:
1. q-integer properties and classical limits
2. q-Casimir spectrum computation and verification
3. Spectral gap recurrence verification
4. Multiplication formula verification
5. Spectral statistics comparison with GUE
"""

import math
from algorithms import (
    q_integer, q_casimir, q_casimir_spectrum, spectral_gaps,
    spectral_gaps_from_formula, verify_multiplication_formula,
    verify_gap_recurrence, nearest_neighbor_spacing, gue_wigner_surmise,
    symmetric_q_integer, symmetric_q_casimir
)


def demo_q_integers():
    """Demonstrate q-integer properties."""
    print("=" * 60)
    print("DEMO 1: q-Integer Properties")
    print("=" * 60)

    # Classical limit: q=1
    print("\n--- Classical limit (q=1): [n]_1 = n ---")
    for n in range(1, 8):
        val = q_integer(1.0, n)
        print(f"  [{n}]_1 = {val:.4f}  (expected: {n})")

    # q=2 case
    print("\n--- q=2: [n]_2 = 2^n - 1 ---")
    for n in range(1, 8):
        val = q_integer(2.0, n)
        expected = 2**n - 1
        print(f"  [{n}]_2 = {val:.4f}  (expected: {expected})")

    # Recurrence verification: [n+1]_q = 1 + q*[n]_q
    print("\n--- Recurrence: [n+1]_q = 1 + q*[n]_q (q=1.5) ---")
    q = 1.5
    for n in range(6):
        lhs = q_integer(q, n + 1)
        rhs = 1.0 + q * q_integer(q, n)
        print(f"  [{n+1}]_q = {lhs:.6f},  1 + q*[{n}]_q = {rhs:.6f},  match: {abs(lhs-rhs) < 1e-10}")


def demo_casimir_spectrum():
    """Demonstrate q-Casimir spectrum."""
    print("\n" + "=" * 60)
    print("DEMO 2: q-Casimir Spectrum")
    print("=" * 60)

    # Classical spectrum: n(n+1)
    print("\n--- Classical Casimir (q=1): lambda_n = n(n+1) ---")
    spectrum = q_casimir_spectrum(1.0, 8)
    for n, lam in enumerate(spectrum):
        expected = n * (n + 1)
        print(f"  lambda_{n} = {lam:.4f}  (expected: {expected})")

    # q=2 spectrum
    print("\n--- q=2 Casimir spectrum ---")
    spectrum = q_casimir_spectrum(2.0, 8)
    for n, lam in enumerate(spectrum):
        print(f"  lambda_{n} = {lam:.4f}")

    # Strict monotonicity
    print("\n--- Monotonicity check (q=2) ---")
    for i in range(len(spectrum) - 1):
        print(f"  lambda_{i} = {spectrum[i]:.2f} < lambda_{i+1} = {spectrum[i+1]:.2f}: {spectrum[i] < spectrum[i+1]}")


def demo_spectral_gaps():
    """Demonstrate spectral gap properties."""
    print("\n" + "=" * 60)
    print("DEMO 3: Spectral Gap Recurrence")
    print("=" * 60)

    q = 2.0
    N = 8

    # Two methods should agree
    gaps1 = spectral_gaps(q, N)
    gaps2 = spectral_gaps_from_formula(q, N)
    print(f"\n--- Spectral gaps (q={q}): recurrence vs formula ---")
    for n in range(N):
        print(f"  Delta_{n}: recurrence={gaps1[n]:.6f}, formula={gaps2[n]:.6f}, match={abs(gaps1[n]-gaps2[n]) < 1e-8}")

    # Verify recurrence: Delta_{n+1} = q^2 * Delta_n + q^{n+1} * (1+q)
    print(f"\n--- Gap recurrence verification (q={q}) ---")
    for n in range(6):
        lhs, rhs, err = verify_gap_recurrence(q, n)
        print(f"  n={n}: Delta_{n+1}={lhs:.6f}, q^2*Delta_{n}+q^{{n+1}}*(1+q)={rhs:.6f}, rel_err={err:.2e}")

    # Exponential growth
    print(f"\n--- Lyapunov exponent estimation (q={q}) ---")
    gaps = spectral_gaps(q, 20)
    for n in [5, 10, 15, 19]:
        lyap = math.log(gaps[n]) / n if gaps[n] > 0 else 0
        print(f"  n={n}: (1/n)*log(Delta_n) = {lyap:.6f}, 2*log(q) = {2*math.log(q):.6f}")


def demo_multiplication_formula():
    """Verify the multiplication formula [nm]_q = [n]_q * [m]_{q^n}."""
    print("\n" + "=" * 60)
    print("DEMO 4: Multiplication Formula [nm]_q = [n]_q * [m]_{q^n}")
    print("=" * 60)

    q = 1.5
    test_cases = [(2, 3), (3, 4), (5, 7), (2, 10), (4, 6)]
    for n, m in test_cases:
        lhs, rhs, err = verify_multiplication_formula(q, n, m)
        print(f"  [{n}*{m}]_q = {lhs:.8f}, [{n}]_q * [{m}]_{{q^{n}}} = {rhs:.8f}, rel_err = {err:.2e}")


def demo_symmetric_q_integers():
    """Demonstrate symmetric q-integers with Riemann zero parameter."""
    print("\n" + "=" * 60)
    print("DEMO 5: Symmetric q-Integers (Unit Circle)")
    print("=" * 60)

    gamma1 = 14.134725  # First Riemann zero
    alpha = gamma1 / (2 * math.pi)

    print(f"\n--- alpha = gamma_1/(2*pi) = {alpha:.6f} ---")
    print(f"--- Symmetric q-integers [n]_q^sym = sin(n*pi*alpha)/sin(pi*alpha) ---")
    for n in range(1, 12):
        val = symmetric_q_integer(alpha, n)
        print(f"  [{n}]_q^sym = {val:.6f}")

    print(f"\n--- Symmetric q-Casimir eigenvalues ---")
    casimirs = []
    for n in range(1, 20):
        lam = symmetric_q_casimir(alpha, n)
        casimirs.append(lam)
        if n <= 10:
            print(f"  lambda_{n}^sym = {lam:.6f}")

    # Spacing statistics
    sorted_pos = sorted([abs(c) for c in casimirs if abs(c) > 0.01])
    if len(sorted_pos) > 3:
        spacings = nearest_neighbor_spacing(sorted_pos)
        mean_s = sum(spacings) / len(spacings)
        var_s = sum((s - mean_s)**2 for s in spacings) / len(spacings)
        print(f"\n--- Spacing statistics (|lambda|) ---")
        print(f"  Mean normalized spacing: {mean_s:.4f} (expected ~1.0)")
        print(f"  Variance: {var_s:.4f}")
        print(f"  GUE prediction for variance: ~0.286")
        print(f"  Poisson prediction for variance: ~1.0")


def demo_spectral_zeta():
    """Demonstrate spectral zeta function."""
    print("\n" + "=" * 60)
    print("DEMO 6: Spectral Zeta Function")
    print("=" * 60)

    # At q=1, zeta_C(s) = sum 1/(n(n+1))^s
    # For s=1: sum 1/(n(n+1)) = sum (1/n - 1/(n+1)) = 1 (telescoping)
    print("\n--- Spectral zeta at q=1 ---")
    for s in [1.0, 2.0, 3.0]:
        spectrum = q_casimir_spectrum(1.0, 1001)
        zeta_val = sum(lam**(-s) for lam in spectrum[1:] if lam > 0)
        if s == 1.0:
            exact = 1.0  # telescoping sum
            print(f"  zeta_C({s}, 1000) = {zeta_val:.8f}  (exact limit: {exact})")
        else:
            print(f"  zeta_C({s}, 1000) = {zeta_val:.8f}")

    # At q=2
    print("\n--- Spectral zeta at q=2 ---")
    for s in [1.0, 2.0, 3.0]:
        spectrum = q_casimir_spectrum(2.0, 101)
        zeta_val = sum(lam**(-s) for lam in spectrum[1:] if lam > 0)
        print(f"  zeta_C({s}, 100) = {zeta_val:.10f}")


if __name__ == "__main__":
    demo_q_integers()
    demo_casimir_spectrum()
    demo_spectral_gaps()
    demo_multiplication_formula()
    demo_symmetric_q_integers()
    demo_spectral_zeta()
    print("\n" + "=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: q-Integer Multiplication Formula Verification

Demonstrates the identity [nm]_q = [n]_q * [m]_{q^n} visually,
showing how this multiplicative structure mirrors the Euler product.
"""

import math


def q_integer(q, n):
    if n == 0:
        return 0.0
    if abs(q - 1.0) < 1e-15:
        return float(n)
    return (q**n - 1.0) / (q - 1.0)


def main():
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
        import numpy as np
    except ImportError:
        print("matplotlib/numpy not available")
        return

    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    # Panel 1: [nm]_q vs [n]_q * [m]_{q^n} for various n, m
    ax = axes[0]
    q = 1.5
    pairs = [(n, m) for n in range(1, 8) for m in range(1, 8)]
    lhs_vals = [q_integer(q, n * m) for n, m in pairs]
    rhs_vals = [q_integer(q, n) * q_integer(q**n, m) for n, m in pairs]
    ax.scatter(lhs_vals, rhs_vals, c='#E91E63', alpha=0.6, s=30)
    max_val = max(max(lhs_vals), max(rhs_vals))
    ax.plot([0, max_val], [0, max_val], 'k--', linewidth=1, alpha=0.5)
    ax.set_xlabel('[nm]_q')
    ax.set_ylabel('[n]_q · [m]_{q^n}')
    ax.set_title(f'Multiplication Formula (q={q})')
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)

    # Panel 2: Relative error as function of q
    ax = axes[1]
    q_range = [1.0 + 0.1 * i for i in range(1, 30)]
    n, m = 5, 7
    errors = []
    for q in q_range:
        lhs = q_integer(q, n * m)
        rhs = q_integer(q, n) * q_integer(q**n, m)
        err = abs(lhs - rhs) / max(abs(lhs), 1e-15)
        errors.append(err)
    ax.semilogy(q_range, [max(e, 1e-16) for e in errors], 'o-', color='#2196F3', markersize=3)
    ax.set_xlabel('q')
    ax.set_ylabel('Relative error')
    ax.set_title(f'[{n}·{m}]_q = [{n}]_q·[{m}]_{{q^{n}}} verification')
    ax.axhline(y=1e-12, color='gray', linestyle='--', alpha=0.5, label='machine epsilon')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Panel 3: q-integer as function of q for fixed n
    ax = axes[2]
    q_range = np.linspace(0.1, 3.0, 200)
    for n in [2, 3, 5, 7]:
        vals = [q_integer(q, n) for q in q_range]
        ax.plot(q_range, vals, linewidth=2, label=f'[{n}]_q')
    ax.axvline(x=1.0, color='gray', linestyle='--', alpha=0.5)
    ax.set_xlabel('q')
    ax.set_ylabel('[n]_q')
    ax.set_title('q-Integers as functions of q')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.suptitle('q-Integer Multiplicative Structure', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('multiplication_formula.png', dpi=150, bbox_inches='tight')
    print("Saved multiplication_formula.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Nearest-Neighbor Spacing Distribution of q-Casimir Spectrum

Compares the spacing distribution of q-Casimir eigenvalues to the GUE
Wigner surmise and Poisson distribution.
"""

import math


def q_integer(q, n):
    if n == 0:
        return 0.0
    if abs(q - 1.0) < 1e-15:
        return float(n)
    return (q**n - 1.0) / (q - 1.0)


def q_casimir_spectrum(q, N):
    spectrum = []
    q_int_prev = 0.0
    q_int_curr = 1.0
    for n in range(N):
        spectrum.append(q_int_prev * q_int_curr)
        q_int_prev = q_int_curr
        q_int_curr = 1.0 + q * q_int_curr
    return spectrum


def symmetric_q_casimir_spectrum(alpha, N):
    denom = math.sin(math.pi * alpha)
    if abs(denom) < 1e-15:
        return [float(n * (n + 1)) for n in range(N)]
    spectrum = []
    for n in range(N):
        qn = math.sin(n * math.pi * alpha) / denom
        qn1 = math.sin((n + 1) * math.pi * alpha) / denom
        spectrum.append(qn * qn1)
    return spectrum


def normalized_spacings(eigenvalues):
    N = len(eigenvalues)
    spacings = [eigenvalues[i+1] - eigenvalues[i] for i in range(N-1)]
    mean_s = sum(spacings) / len(spacings) if spacings else 1.0
    return [s / mean_s for s in spacings]


def gue_wigner(s):
    return (32.0 / math.pi**2) * s**2 * math.exp(-4.0 * s**2 / math.pi)


def poisson_dist(s):
    return math.exp(-s)


def main():
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
    except ImportError:
        print("matplotlib not available")
        return

    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    # Panel 1: q=1.05 (near classical, should be Poisson-like)
    q = 1.05
    N = 500
    spectrum = q_casimir_spectrum(q, N)
    spacings = normalized_spacings(spectrum[1:])  # skip lambda_0 = 0

    ax = axes[0]
    ax.hist(spacings, bins=40, density=True, alpha=0.7, color='#2196F3', label='q-Casimir spacings')
    s_vals = [i * 0.05 for i in range(80)]
    ax.plot(s_vals, [poisson_dist(s) for s in s_vals], 'r-', linewidth=2, label='Poisson')
    ax.plot(s_vals, [gue_wigner(s) for s in s_vals], 'g--', linewidth=2, label='GUE Wigner')
    ax.set_xlabel('Normalized spacing s')
    ax.set_ylabel('P(s)')
    ax.set_title(f'q = {q} (near classical)')
    ax.legend()
    ax.set_xlim(0, 4)

    # Panel 2: q=2.0 (strongly deformed)
    q = 2.0
    spectrum = q_casimir_spectrum(q, N)
    # Use log transform to unwind exponential growth
    log_spectrum = [math.log(lam) for lam in spectrum[1:] if lam > 0]
    spacings = normalized_spacings(log_spectrum)

    ax = axes[1]
    ax.hist(spacings, bins=40, density=True, alpha=0.7, color='#FF9800', label='log(λ_n) spacings')
    ax.plot(s_vals, [poisson_dist(s) for s in s_vals], 'r-', linewidth=2, label='Poisson')
    ax.plot(s_vals, [gue_wigner(s) for s in s_vals], 'g--', linewidth=2, label='GUE Wigner')
    ax.set_xlabel('Normalized spacing s')
    ax.set_ylabel('P(s)')
    ax.set_title(f'q = {q} (log-transformed)')
    ax.legend()
    ax.set_xlim(0, 4)

    # Panel 3: Symmetric q-integer with Riemann zero
    gamma1 = 14.134725
    alpha = gamma1 / (2 * math.pi)
    spectrum = symmetric_q_casimir_spectrum(alpha, 200)
    # Take absolute values and sort
    abs_spectrum = sorted([abs(s) for s in spectrum if abs(s) > 0.01])
    if len(abs_spectrum) > 10:
        spacings = normalized_spacings(abs_spectrum)
        ax = axes[2]
        ax.hist(spacings, bins=30, density=True, alpha=0.7, color='#4CAF50',
                label='|λ_n^sym| spacings')
        ax.plot(s_vals, [poisson_dist(s) for s in s_vals], 'r-', linewidth=2, label='Poisson')
        ax.plot(s_vals, [gue_wigner(s) for s in s_vals], 'g--', linewidth=2, label='GUE Wigner')
        ax.set_xlabel('Normalized spacing s')
        ax.set_ylabel('P(s)')
        ax.set_title(f'Symmetric q-Casimir (γ₁ ≈ 14.13)')
        ax.legend()
        ax.set_xlim(0, 4)

    plt.suptitle('Spacing Statistics: q-Casimir Spectrum vs. Random Matrix Predictions',
                 fontsize=13, fontweight='bold')
    plt.tight_layout()
    plt.savefig('spacing_analysis.png', dpi=150, bbox_inches='tight')
    print("Saved spacing_analysis.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: q-Casimir Spectrum for Various q Values

Plots the q-Casimir eigenvalues lambda_n = [n]_q * [n+1]_q as a function of n
for several values of q, showing the transition from polynomial growth (q=1)
to exponential growth (q>1).
"""

import math


def q_integer(q, n):
    if n == 0:
        return 0.0
    if abs(q - 1.0) < 1e-15:
        return float(n)
    return (q**n - 1.0) / (q - 1.0)


def q_casimir(q, n):
    return q_integer(q, n) * q_integer(q, n + 1)


def spectral_gap(q, n):
    return q_casimir(q, n + 1) - q_casimir(q, n)


def main():
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
    except ImportError:
        print("matplotlib not available, skipping visualization")
        return

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    q_values = [1.0, 1.2, 1.5, 2.0]
    colors = ['#2196F3', '#FF9800', '#4CAF50', '#E91E63']
    N = 15

    # Plot 1: Casimir eigenvalues
    ax = axes[0, 0]
    for q, color in zip(q_values, colors):
        ns = list(range(N))
        lambdas = [q_casimir(q, n) for n in ns]
        ax.plot(ns, lambdas, 'o-', color=color, label=f'q = {q}', markersize=4)
    ax.set_xlabel('n (representation label)')
    ax.set_ylabel('λ_n (Casimir eigenvalue)')
    ax.set_title('q-Casimir Eigenvalues')
    ax.legend()
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)

    # Plot 2: Spectral gaps
    ax = axes[0, 1]
    for q, color in zip(q_values, colors):
        ns = list(range(N - 1))
        gaps = [spectral_gap(q, n) for n in ns]
        ax.plot(ns, gaps, 's-', color=color, label=f'q = {q}', markersize=4)
    ax.set_xlabel('n')
    ax.set_ylabel('Δ_n (spectral gap)')
    ax.set_title('Spectral Gaps Δ_n = λ_{n+1} - λ_n')
    ax.legend()
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)

    # Plot 3: q-integers
    ax = axes[1, 0]
    for q, color in zip(q_values, colors):
        ns = list(range(1, N + 1))
        qints = [q_integer(q, n) for n in ns]
        ax.plot(ns, qints, '^-', color=color, label=f'q = {q}', markersize=4)
    ax.set_xlabel('n')
    ax.set_ylabel('[n]_q')
    ax.set_title('q-Integers [n]_q')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Plot 4: Gap ratios (Lyapunov exponent convergence)
    ax = axes[1, 1]
    N_lyap = 30
    for q, color in zip([1.2, 1.5, 2.0, 3.0], colors):
        ns = list(range(2, N_lyap))
        gaps = [spectral_gap(q, n) for n in range(N_lyap)]
        ratios = [math.log(gaps[n]) / n for n in ns if gaps[n] > 0]
        expected = 2 * math.log(q)
        ax.plot(ns[:len(ratios)], ratios, '-', color=color,
                label=f'q={q}, 2ln(q)={expected:.3f}', linewidth=1.5)
        ax.axhline(y=expected, color=color, linestyle='--', alpha=0.5)
    ax.set_xlabel('n')
    ax.set_ylabel('(1/n) · ln(Δ_n)')
    ax.set_title('Lyapunov Exponent Convergence')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    plt.suptitle('Quantum Group Casimir Spectrum Analysis', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('spectrum_analysis.png', dpi=150, bbox_inches='tight')
    print("Saved spectrum_analysis.png")


if __name__ == "__main__":
    main()
