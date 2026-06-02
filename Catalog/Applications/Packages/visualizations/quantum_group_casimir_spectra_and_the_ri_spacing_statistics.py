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
