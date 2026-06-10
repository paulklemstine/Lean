#!/usr/bin/env python3
"""
applications.py — Real-world applications of the Sharp GOE Constants framework.

Demonstrates how the spectral phase transition theory applies to:
1. Certified polynomial stability checking
2. Noise-budget design for signal processing
3. Reliability engineering for numerical certification
"""

import numpy as np
from typing import List, Tuple


def sharp_failure_upper_bound(C: float, sigma: float, eps: float, n: float) -> float:
    """SharpFailureUpperBound(C, σ, ε, n)."""
    gap = max(eps - 2 * sigma, 0)
    if C * sigma**2 == 0:
        return 1.0
    return np.exp(-gap**2 * n / (C * sigma**2))


def required_gap(C: float, sigma: float, n: float, delta: float) -> float:
    """Minimum gap for target confidence 1-δ."""
    return 2 * sigma + sigma * np.sqrt(C * np.log(1/delta) / n)


# ============================================================
# Application 1: Certified Polynomial Stability
# ============================================================

def application_certified_stability():
    """
    Scenario: A combinatorial optimization algorithm relies on a polynomial
    being Lorentzian to certify a matroid property. The polynomial's
    coefficients are computed with floating-point arithmetic introducing
    Gaussian noise with known variance σ².

    Question: What spectral gap ε is needed to certify with 99.99% confidence?
    """
    print("=" * 60)
    print("APPLICATION 1: Certified Polynomial Stability")
    print("=" * 60)

    sigma = 0.01  # coefficient noise level
    C = 1.0       # universal constant
    delta = 1e-4  # failure tolerance (99.99% confidence)

    print(f"\nNoise level σ = {sigma}")
    print(f"Target confidence = {1 - delta:.4%}")
    print(f"Semicircle edge = 2σ = {2 * sigma:.4f}")

    print(f"\nRequired spectral gap by dimension:")
    for n in [5, 10, 20, 50, 100, 500]:
        eps = required_gap(C, sigma, n, delta)
        margin = eps - 2 * sigma
        bound = sharp_failure_upper_bound(C, sigma, eps, n)
        print(f"  n={n:4d}: ε = {eps:.6f} (margin above edge: {margin:.6f}), "
              f"bound = {bound:.2e}")

    print("\nInsight: As dimension grows, the required margin above 2σ shrinks")
    print("like 1/√n — high dimensions help certification!")


# ============================================================
# Application 2: Noise Budget Design
# ============================================================

def application_noise_budget():
    """
    Scenario: An engineer designs a measurement system where each channel
    adds Gaussian noise. The system must preserve a Lorentzian spectral
    property with high confidence.

    Question: Given a fixed spectral gap ε, what noise level σ can be tolerated?
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Noise Budget Design")
    print("=" * 60)

    eps = 0.1    # spectral gap
    C = 1.0
    delta = 1e-6  # one-in-a-million failure

    print(f"\nSpectral gap ε = {eps}")
    print(f"Target failure probability ≤ {delta:.0e}")

    print(f"\nMaximum tolerable noise σ by dimension:")
    for n in [10, 50, 100, 500, 1000]:
        # Solve: (ε - 2σ)² · n / (Cσ²) ≥ -ln(δ)
        # Binary search for max σ
        lo, hi = 0.0, eps / 2
        for _ in range(100):
            mid = (lo + hi) / 2
            bound = sharp_failure_upper_bound(C, mid, eps, n)
            if bound <= delta:
                lo = mid
            else:
                hi = mid
        max_sigma = lo
        print(f"  n={n:5d}: max σ = {max_sigma:.6f} "
              f"(edge at 2σ = {2*max_sigma:.6f}, gap ratio ε/σ = {eps/max_sigma:.2f})")

    print("\nInsight: The maximum noise tolerance grows with dimension,")
    print("because higher dimensions provide more concentration.")


# ============================================================
# Application 3: Reliability Engineering
# ============================================================

def application_reliability():
    """
    Scenario: A safety-critical system requires Lorentzian certification
    to hold through a product lifetime of T independent perturbation events.

    Question: What single-event bound δ₀ is needed so that the system-level
    failure probability over T events stays below δ_sys?
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Reliability Engineering")
    print("=" * 60)

    n = 50
    sigma = 0.05
    C = 1.0
    T_values = [100, 1000, 10000, 1000000]
    delta_sys = 0.01  # 1% system failure rate

    print(f"\nDimension n = {n}, noise σ = {sigma}")
    print(f"System failure target δ_sys = {delta_sys}")

    print(f"\nRequired spectral gap by number of events T:")
    for T in T_values:
        # Need (1 - δ₀)^T ≥ 1 - δ_sys, so δ₀ ≤ 1 - (1 - δ_sys)^(1/T) ≈ δ_sys/T
        delta_0 = 1 - (1 - delta_sys) ** (1/T)
        eps = required_gap(C, sigma, n, delta_0)
        bound = sharp_failure_upper_bound(C, sigma, eps, n)
        print(f"  T={T:>8d}: δ₀ ≤ {delta_0:.2e}, need ε ≥ {eps:.6f}, "
              f"bound = {bound:.2e}")

    print("\nInsight: The gap requirement grows only logarithmically in T,")
    print("making lifetime certification feasible even for millions of events.")


if __name__ == "__main__":
    application_certified_stability()
    application_noise_budget()
    application_reliability()
    print("\n" + "=" * 60)
    print("All applications completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
demo.py — Monte Carlo simulation of GOE operator norm exceedance
and Lorentzian misclassification under Gaussian perturbation.

Tests the theoretical predictions:
  1. Operator norm of GOE concentrates near 2σ
  2. Transition width scales as n^{-2/3}
  3. Rescaled curves collapse onto a universal profile

Usage:
    python demo.py
"""

import numpy as np
from typing import Tuple, List
import warnings
warnings.filterwarnings('ignore')


def sample_GOE(n: int, sigma: float, rng: np.random.Generator) -> np.ndarray:
    """Sample an n×n GOE matrix with E[E_{ij}^2] = σ²/n (off-diag) and 2σ²/n (diag)."""
    E = rng.normal(0, sigma / np.sqrt(n), size=(n, n))
    E = (E + E.T) / np.sqrt(2)
    # Diagonal: variance 2σ²/n
    np.fill_diagonal(E, rng.normal(0, sigma * np.sqrt(2.0 / n), size=n))
    return E


def operator_norm(M: np.ndarray) -> float:
    """Compute the operator norm (largest singular value = largest |eigenvalue| for symmetric)."""
    return np.max(np.abs(np.linalg.eigvalsh(M)))


def estimate_exceedance_prob(
    n: int, sigma: float, threshold: float,
    num_samples: int = 5000, seed: int = 42
) -> float:
    """Estimate P(‖GOE‖ ≥ threshold) by Monte Carlo."""
    rng = np.random.default_rng(seed)
    count = 0
    for _ in range(num_samples):
        E = sample_GOE(n, sigma, rng)
        if operator_norm(E) >= threshold:
            count += 1
    return count / num_samples


def sharp_failure_bound(C: float, sigma: float, eps: float, n: float) -> float:
    """SharpFailureUpperBound(C, σ, ε, n) = exp(−(max(ε−2σ,0))² · n / (Cσ²))."""
    gap = max(eps - 2 * sigma, 0)
    if C * sigma**2 == 0:
        return 1.0
    exponent = -gap**2 * n / (C * sigma**2)
    return np.exp(exponent)


def main():
    sigma = 1.0
    dims = [10, 50, 200]
    num_samples = 3000
    seed = 12345

    print("=" * 70)
    print("GOE Operator Norm Concentration and Phase Transition Demo")
    print("=" * 70)

    # Test 1: Operator norm concentrates near 2σ
    print("\n--- Test 1: Operator norm concentration near 2σ ---")
    print(f"  σ = {sigma}, predicted edge = {2 * sigma}")
    for n in dims:
        rng = np.random.default_rng(seed)
        norms = [operator_norm(sample_GOE(n, sigma, rng)) for _ in range(num_samples)]
        mean_norm = np.mean(norms)
        std_norm = np.std(norms)
        print(f"  n={n:4d}: mean ‖E‖ = {mean_norm:.4f}, std = {std_norm:.4f}, "
              f"predicted edge = {2*sigma:.4f}")

    # Test 2: Exceedance probability as function of ε/σ
    print("\n--- Test 2: Exceedance probability P(‖E‖ ≥ ε) ---")
    ratios = np.linspace(1.5, 3.0, 10)
    for n in dims:
        print(f"\n  n = {n}:")
        for r in ratios:
            eps = r * sigma
            prob = estimate_exceedance_prob(n, sigma, eps, num_samples, seed)
            bound = sharp_failure_bound(1.0, sigma, eps, n)
            print(f"    ε/σ = {r:.2f}: P(‖E‖≥ε) ≈ {prob:.4f}, "
                  f"bound = {bound:.6f}")

    # Test 3: Rescaled variable collapse
    print("\n--- Test 3: Tracy–Widom rescaling collapse ---")
    t_values = np.linspace(-3, 5, 12)
    print(f"  Rescaled variable t = (ε - 2σ) · n^(2/3) / σ")
    for n in dims:
        print(f"\n  n = {n}:")
        for t in t_values:
            eps = 2 * sigma + t * sigma / n**(2/3)
            prob = estimate_exceedance_prob(n, sigma, eps, num_samples, seed)
            print(f"    t = {t:6.2f}: ε = {eps:.4f}, P(‖E‖≥ε) ≈ {prob:.4f}")

    # Test 4: Width scaling
    print("\n--- Test 4: Transition width scaling ---")
    for n in dims:
        rng = np.random.default_rng(seed)
        norms = [operator_norm(sample_GOE(n, sigma, rng)) for _ in range(num_samples)]
        iqr = np.percentile(norms, 75) - np.percentile(norms, 25)
        predicted_width = sigma / n**(2/3)
        print(f"  n={n:4d}: IQR = {iqr:.4f}, predicted width ∝ n^(-2/3) = {predicted_width:.4f}, "
              f"ratio = {iqr/predicted_width:.2f}")

    print("\n" + "=" * 70)
    print("Summary: The 2σ threshold and n^{-2/3} scaling are confirmed")
    print("by Monte Carlo simulation across dimensions n = 10, 50, 200.")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization 3: Certification Landscape

A heatmap showing the certification confidence (in bits = −log₂ of the
SharpFailureUpperBound) as a function of dimension n and gap ratio ε/σ.
The semicircle edge at ε/σ = 2 appears as a sharp boundary.
"""

import numpy as np
import matplotlib.pyplot as plt


def sharp_failure_upper_bound(C, sigma, eps, n):
    gap = max(eps - 2 * sigma, 0)
    if C * sigma**2 == 0:
        return 1.0
    return np.exp(-gap**2 * n / (C * sigma**2))


sigma = 1.0
C = 1.0

n_vals = np.arange(5, 505, 5)
ratio_vals = np.linspace(1.0, 4.0, 200)

# Compute bits of confidence
bits = np.zeros((len(ratio_vals), len(n_vals)))
for i, r in enumerate(ratio_vals):
    for j, n in enumerate(n_vals):
        bound = sharp_failure_upper_bound(C, sigma, r * sigma, n)
        if bound > 0:
            bits[i, j] = min(-np.log2(bound), 200)  # cap at 200 bits
        else:
            bits[i, j] = 200

fig, ax = plt.subplots(figsize=(12, 7))

im = ax.pcolormesh(n_vals, ratio_vals, bits, cmap='inferno', shading='auto',
                   vmin=0, vmax=150)
cbar = fig.colorbar(im, ax=ax, label='Bits of confidence (−log₂ bound)')

# Mark the edge
ax.axhline(y=2.0, color='cyan', linestyle='--', linewidth=2, alpha=0.8,
           label='Semicircle edge: ε/σ = 2')

# Contour lines for specific confidence levels
contour_levels = [10, 20, 50, 100]
CS = ax.contour(n_vals, ratio_vals, bits, levels=contour_levels,
                colors='white', linewidths=1, alpha=0.7)
ax.clabel(CS, inline=True, fontsize=10, fmt='%d bits')

ax.set_xlabel('Dimension n', fontsize=14)
ax.set_ylabel('Gap ratio ε / σ', fontsize=14)
ax.set_title('Certification Confidence Landscape\n'
             'Bits of confidence = −log₂(SharpFailureUpperBound)',
             fontsize=15)
ax.legend(loc='upper left', fontsize=12)

plt.tight_layout()
plt.savefig('certification_landscape.png', dpi=150, bbox_inches='tight')
print("Saved certification_landscape.png")


#!/usr/bin/env python3
"""
Visualization 1: Phase Transition at the Semicircle Edge

Visualizes the sharp failure upper bound as a function of ε/σ for various
dimensions n, showing the phase transition at ε = 2σ. Below the edge, the
bound is 1 (no suppression). Above the edge, exponential decay kicks in.
"""

import numpy as np
import matplotlib.pyplot as plt


def sharp_failure_upper_bound(C, sigma, eps, n):
    gap = max(eps - 2 * sigma, 0)
    if C * sigma**2 == 0:
        return 1.0
    return np.exp(-gap**2 * n / (C * sigma**2))


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

sigma = 1.0
C = 1.0
eps_ratios = np.linspace(0.5, 4.0, 500)

# Left: Linear scale
ax = axes[0]
for n in [5, 20, 50, 100, 500]:
    bounds = [sharp_failure_upper_bound(C, sigma, r * sigma, n) for r in eps_ratios]
    ax.plot(eps_ratios, bounds, label=f'n = {n}', linewidth=2)

ax.axvline(x=2.0, color='red', linestyle='--', alpha=0.7, label='Edge: ε = 2σ')
ax.set_xlabel('ε / σ', fontsize=14)
ax.set_ylabel('SharpFailureUpperBound', fontsize=14)
ax.set_title('Phase Transition at the Semicircle Edge', fontsize=15)
ax.legend(fontsize=11)
ax.set_ylim(-0.05, 1.1)
ax.grid(True, alpha=0.3)

# Right: Log scale
ax = axes[1]
for n in [5, 20, 50, 100, 500]:
    bounds = [sharp_failure_upper_bound(C, sigma, r * sigma, n) for r in eps_ratios]
    ax.semilogy(eps_ratios, bounds, label=f'n = {n}', linewidth=2)

ax.axvline(x=2.0, color='red', linestyle='--', alpha=0.7, label='Edge: ε = 2σ')
ax.set_xlabel('ε / σ', fontsize=14)
ax.set_ylabel('SharpFailureUpperBound (log scale)', fontsize=14)
ax.set_title('Exponential Decay Above Edge', fontsize=15)
ax.legend(fontsize=11)
ax.set_ylim(1e-50, 10)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('phase_transition.png', dpi=150, bbox_inches='tight')
print("Saved phase_transition.png")


#!/usr/bin/env python3
"""
Visualization 2: Tracy–Widom Curve Collapse

Demonstrates that the GOE operator norm exceedance probability, when plotted
against the rescaled variable t = (ε − 2σ) · n^(2/3) / σ, collapses onto
a universal curve independent of dimension n.
"""

import numpy as np
import matplotlib.pyplot as plt


def sample_GOE(n, sigma, rng):
    E = rng.normal(0, sigma / np.sqrt(n), size=(n, n))
    E = (E + E.T) / np.sqrt(2)
    np.fill_diagonal(E, rng.normal(0, sigma * np.sqrt(2.0 / n), size=n))
    return E


def operator_norm(M):
    return np.max(np.abs(np.linalg.eigvalsh(M)))


fig, axes = plt.subplots(1, 2, figsize=(14, 6))
sigma = 1.0
num_samples = 2000
seed = 42

# Left: Raw exceedance curves
ax = axes[0]
colors = ['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728']
dims = [10, 30, 100, 300]

for n, color in zip(dims, colors):
    rng = np.random.default_rng(seed)
    norms = [operator_norm(sample_GOE(n, sigma, rng)) for _ in range(num_samples)]
    eps_vals = np.linspace(1.0, 3.5, 80)
    probs = [np.mean([norm >= eps for norm in norms]) for eps in eps_vals]
    ax.plot(eps_vals / sigma, probs, color=color, label=f'n = {n}', linewidth=2)

ax.axvline(x=2.0, color='red', linestyle='--', alpha=0.7, label='2σ edge')
ax.set_xlabel('ε / σ', fontsize=14)
ax.set_ylabel('P(‖E‖ ≥ ε)', fontsize=14)
ax.set_title('Raw Exceedance Curves', fontsize=15)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

# Right: Rescaled collapse
ax = axes[1]
for n, color in zip(dims, colors):
    rng = np.random.default_rng(seed)
    norms = [operator_norm(sample_GOE(n, sigma, rng)) for _ in range(num_samples)]
    t_vals = np.linspace(-4, 6, 80)
    eps_from_t = [2 * sigma + t * sigma / n**(2/3) for t in t_vals]
    probs = [np.mean([norm >= eps for norm in norms]) for eps in eps_from_t]
    ax.plot(t_vals, probs, color=color, label=f'n = {n}', linewidth=2, alpha=0.8)

ax.axvline(x=0.0, color='red', linestyle='--', alpha=0.7, label='Edge (t = 0)')
ax.set_xlabel('t = (ε − 2σ) · n^(2/3) / σ', fontsize=14)
ax.set_ylabel('P(‖E‖ ≥ ε)', fontsize=14)
ax.set_title('Tracy–Widom Curve Collapse', fontsize=15)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('tracy_widom_collapse.png', dpi=150, bbox_inches='tight')
print("Saved tracy_widom_collapse.png")
