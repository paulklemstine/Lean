#!/usr/bin/env python3
"""
applications.py — Applications of the double-scaling limit theory
to concrete group families and statistical mechanics models.

Demonstrates:
1. Subgroup pressure estimation for wreath products S_k ≀ S_m
2. Universality class identification
3. Phase diagram computation
4. Random matrix crossover analogy
"""

import numpy as np
from typing import List, Tuple


# --- Application 1: Subgroup Pressure for Small Groups ---

def log_factorial(n: int) -> float:
    """Compute log(n!) using Stirling's approximation for large n."""
    if n <= 1:
        return 0.0
    if n <= 20:
        result = 0.0
        for i in range(2, n + 1):
            result += np.log(i)
        return result
    return n * np.log(n) - n + 0.5 * np.log(2 * np.pi * n)


def subgroup_count_Sn(n: int) -> int:
    """Known subgroup counts for small symmetric groups.
    Source: OEIS A005432."""
    counts = {
        1: 1, 2: 2, 3: 6, 4: 30, 5: 156,
        6: 1455, 7: 11300, 8: 151221
    }
    return counts.get(n, -1)


def beta_symm_empirical(k: int) -> float:
    """Empirical β(S_k) = log(number of subgroups of S_k)."""
    count = subgroup_count_Sn(k)
    if count > 0:
        return np.log(count)
    return log_factorial(k)  # Fallback


def beta_wreath_estimate(k: int, m: int) -> float:
    """Estimate β_W(k,m) for S_k ≀ S_m.

    Uses the decomposition: β_W = m·β(S_k) + defect
    where defect ≈ C·m/k from perturbation theory.
    """
    base = m * beta_symm_empirical(k)
    # Model defect from orbit-counting: each of m copies contributes
    # approximately log(k)/k additional subgroups from the wreath action
    defect = m * np.log(k) / k if k > 0 else 0
    return base + defect


def compute_phase_diagram(
    k_range: List[int],
    m_range: List[int],
    C: float = 1.0,
    a: int = 1,
    b: int = 1
) -> List[Tuple[int, int, str, float]]:
    """Compute the phase diagram (k, m) → regime classification.

    Returns list of (k, m, regime, defect) tuples.
    """
    results = []
    for k in k_range:
        for m in m_range:
            if k == 0:
                continue
            ratio = (m ** a) / (k ** b)
            if ratio < 0.1:
                regime = "IRRELEVANT"
            elif ratio < 10:
                regime = "MARGINAL"
            else:
                regime = "RELEVANT"

            defect = C * (m ** a) / (k ** b)
            results.append((k, m, regime, defect))
    return results


# --- Application 2: Universality Class Identification ---

def test_universality(k_values: List[int], m_func, label: str = ""):
    """Test whether a family m(k) yields universal per-copy pressure.

    Computes β_W(k,m(k))/m(k) and checks convergence to β(S_k).
    """
    print(f"\nUniversality test: {label}")
    print(f"  {'k':>5} {'m(k)':>8} {'β_W/m':>12} {'β(S_k)':>12} "
          f"{'ratio':>10} {'Δ/m':>12}")

    for k in k_values:
        m = m_func(k)
        if m == 0:
            continue
        bw = beta_wreath_estimate(k, m)
        bs = beta_symm_empirical(k)
        per_copy = bw / m
        defect_per_copy = per_copy - bs

        print(f"  {k:5d} {m:8d} {per_copy:12.4f} {bs:12.4f} "
              f"{per_copy/bs if bs > 0 else 0:10.6f} "
              f"{defect_per_copy:12.6f}")


# --- Application 3: Statistical Mechanics Analogy ---

def finite_size_scaling(
    k_values: List[int],
    m_func,
    alpha: float,
    C: float = 1.0,
    a: int = 1,
    b: int = 1
) -> List[Tuple[int, float, float, float]]:
    """Compute finite-size scaling observables.

    Analogous to finite-size scaling in statistical mechanics:
    the wreath defect plays the role of the finite-size correction
    to the free energy, and the critical exponent α_c determines
    the scaling dimension of the perturbation.

    Returns (k, m/k^α, Δ(k,m), k^α·Δ/m) tuples.
    """
    results = []
    for k in k_values:
        m = m_func(k)
        if m == 0 or k == 0:
            continue
        defect = C * (m ** a) / (k ** b)
        lambda_val = m / (k ** alpha)
        rescaled = (k ** alpha) * defect / m
        results.append((k, lambda_val, defect, rescaled))
    return results


if __name__ == "__main__":
    print("=" * 70)
    print("  Applications of Double-Scaling Limit Theory")
    print("=" * 70)

    # App 1: Phase diagram
    print("\n--- APPLICATION 1: Phase Diagram ---")
    k_range = [3, 5, 8, 10, 20, 50]
    m_range = [1, 2, 5, 10, 20, 50, 100]
    diagram = compute_phase_diagram(k_range, m_range)
    print(f"\n{'k':>5} {'m':>5} {'Regime':>12} {'Defect':>10}")
    for k, m, reg, d in diagram:
        if k in [5, 10, 50]:
            print(f"{k:5d} {m:5d} {reg:>12} {d:10.4f}")

    # App 2: Universality tests
    print("\n--- APPLICATION 2: Universality Class Tests ---")
    k_vals = [3, 4, 5, 6, 7, 8]

    test_universality(k_vals, lambda k: 1,
                      "Constant m=1 (subcritical)")
    test_universality(k_vals, lambda k: k,
                      "Linear m=k (critical)")
    test_universality(k_vals, lambda k: k*k,
                      "Quadratic m=k² (supercritical)")

    # App 3: Finite-size scaling
    print("\n\n--- APPLICATION 3: Finite-Size Scaling ---")
    k_vals_large = [10, 20, 50, 100, 200, 500]
    results = finite_size_scaling(
        k_vals_large,
        lambda k: max(1, int(np.sqrt(k))),
        alpha=0.5
    )
    print(f"\n{'k':>5} {'m/k^α':>10} {'Δ(k,m)':>12} {'k^α·Δ/m':>12}")
    for k, lam, d, rd in results:
        print(f"{k:5d} {lam:10.4f} {d:12.6f} {rd:12.6f}")


#!/usr/bin/env python3
"""
demo.py — Interactive demonstration of the double-scaling limit
for wreath-product subgroup pressure.

Computes the wreath defect Δ(k,m) = β_W(k,m) - m·β(S_k) and rescaled
quantities, visualizing the crossover between irrelevant and relevant
perturbation regimes.

Uses a model polynomial envelope |Δ(k,m)| ≤ C·m^a/k^b to illustrate
the critical scaling threshold α_c = b/a.
"""

import numpy as np


def beta_symm_model(k: int) -> float:
    """Model symmetric group pressure β(S_k) ≈ k·log(k) - k + 0.5·log(2πk).
    Based on Stirling's approximation to log(k!)."""
    if k <= 0:
        return 0.0
    return k * np.log(k) - k + 0.5 * np.log(2 * np.pi * k)


def beta_wreath_model(k: int, m: int, C: float = 1.0,
                       a: int = 1, b: int = 1) -> float:
    """Model wreath product pressure β_W(k,m) = m·β(S_k) + C·m^a/k^b.
    The second term is the imprimitive defect."""
    base = m * beta_symm_model(k)
    if k > 0:
        defect = C * (m ** a) / (k ** b)
    else:
        defect = 0.0
    return base + defect


def wreath_defect(k: int, m: int, C: float = 1.0,
                   a: int = 1, b: int = 1) -> float:
    """Compute Δ(k,m) = β_W(k,m) - m·β(S_k)."""
    return beta_wreath_model(k, m, C, a, b) - m * beta_symm_model(k)


def rescaled_defect(k: int, m: int, alpha: float,
                     C: float = 1.0, a: int = 1, b: int = 1) -> float:
    """Compute k^α · Δ(k,m) / m."""
    d = wreath_defect(k, m, C, a, b)
    if m == 0:
        return 0.0
    return (k ** alpha) * d / m


def classify_regime(m_scaled: float, threshold: float = 0.1) -> str:
    """Classify perturbation regime based on m^a/k^b ratio."""
    if m_scaled < threshold:
        return "IRRELEVANT"
    elif m_scaled < 1.0 / threshold:
        return "MARGINAL"
    else:
        return "RELEVANT"


def demo_scaling_law(k_values=None, alpha_candidates=None,
                      C=1.0, a=1, b=1):
    """Demonstrate the scaling law Δ(k,m(k)) → 0 for subcritical m(k).

    For each candidate exponent α, we set m(k) = floor(k^α) and compute
    the defect and rescaled defect.
    """
    if k_values is None:
        k_values = [3, 4, 5, 6, 7, 8, 10, 15, 20, 50, 100]
    if alpha_candidates is None:
        alpha_candidates = [0.5, 1.0, 1.5, 2.0]

    critical_exponent = b / a
    print(f"Model parameters: C={C}, a={a}, b={b}")
    print(f"Critical exponent α_c = b/a = {critical_exponent}")
    print("=" * 70)

    for alpha in alpha_candidates:
        regime = ("SUBCRITICAL" if alpha < critical_exponent
                  else "CRITICAL" if alpha == critical_exponent
                  else "SUPERCRITICAL")
        print(f"\nα = {alpha} ({regime})")
        print(f"  m(k) = floor(k^{alpha})")
        print(f"  {'k':>5} {'m(k)':>8} {'Δ(k,m)':>12} {'k^α·Δ/m':>12} "
              f"{'m^a/k^b':>12} {'Regime':>12}")
        print(f"  {'-'*5} {'-'*8} {'-'*12} {'-'*12} {'-'*12} {'-'*12}")

        for k in k_values:
            m = max(1, int(k ** alpha))
            d = wreath_defect(k, m, C, a, b)
            rd = rescaled_defect(k, m, alpha, C, a, b)
            scaling_ratio = (m ** a) / (k ** b)
            reg = classify_regime(scaling_ratio)
            print(f"  {k:5d} {m:8d} {d:12.6f} {rd:12.6f} "
                  f"{scaling_ratio:12.6f} {reg:>12}")


def demo_crossover_profile(k=100, m_values=None, alpha=1.0,
                            C=1.0, a=1, b=1):
    """Show the crossover profile F(λ) by varying m at fixed k."""
    if m_values is None:
        m_values = list(range(1, 201, 5))

    print(f"\nCrossover profile at k={k}, α={alpha}")
    print(f"  {'m':>5} {'λ=m/k^α':>10} {'Δ(k,m)':>12} "
          f"{'k^α·Δ/m':>12} {'Regime':>12}")
    print(f"  {'-'*5} {'-'*10} {'-'*12} {'-'*12} {'-'*12}")

    for m in m_values:
        lam = m / (k ** alpha)
        d = wreath_defect(k, m, C, a, b)
        rd = rescaled_defect(k, m, alpha, C, a, b)
        reg = classify_regime((m ** a) / (k ** b))
        print(f"  {m:5d} {lam:10.4f} {d:12.6f} {rd:12.6f} {reg:>12}")


if __name__ == "__main__":
    print("=" * 70)
    print("  DOUBLE SCALING LIMIT: When Does m Matter?")
    print("  Wreath-Product Subgroup Pressure Asymptotics")
    print("=" * 70)

    # Demo 1: Scaling law with different exponents
    print("\n--- DEMO 1: Scaling Law ---")
    demo_scaling_law(C=1.0, a=1, b=1)

    # Demo 2: Higher-order defect envelope
    print("\n\n--- DEMO 2: Quadratic Defect (a=2, b=1) ---")
    demo_scaling_law(C=0.5, a=2, b=1)

    # Demo 3: Crossover profile
    print("\n\n--- DEMO 3: Crossover Profile ---")
    demo_crossover_profile(k=100, alpha=1.0, C=1.0, a=1, b=1)


#!/usr/bin/env python3
"""
Visualization: Defect Decay Along Subcritical Sequences

Shows the wreath defect Δ(k, m(k)) tending to zero for different
subcritical sequences m(k) = floor(k^α) with α < α_c, while growing
or persisting for α ≥ α_c.

This directly illustrates the subcritical irrelevance theorem:
if m(k)^a / k^b → 0, then Δ(k, m(k)) → 0.
"""

import numpy as np
import matplotlib.pyplot as plt


def wreath_defect_model(k, m, C=1.0, a=1, b=1):
    """Model defect: Δ(k,m) = C · m^a / k^b."""
    if k == 0:
        return 0.0
    return C * (m ** a) / (k ** b)


# Parameters
C = 1.0
a_exp = 1
b_exp = 1
alpha_c = b_exp / a_exp

k_range = np.arange(3, 501)
alpha_values = [0.3, 0.5, 0.7, 0.9, 1.0, 1.2, 1.5, 2.0]

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Raw defect Δ(k, m(k))
ax1 = axes[0]
for alpha in alpha_values:
    m_vals = np.maximum(1, np.floor(k_range ** alpha).astype(int))
    defects = np.array([wreath_defect_model(int(k), int(m), C, a_exp, b_exp)
                        for k, m in zip(k_range, m_vals)])
    style = '-' if alpha < alpha_c else ('--' if alpha == alpha_c else ':')
    lw = 2.5 if abs(alpha - alpha_c) < 0.05 else 1.5
    ax1.plot(k_range, defects, style, linewidth=lw,
             label=f'α={alpha}')

ax1.set_xlabel('k', fontsize=12)
ax1.set_ylabel('$\\Delta(k, m(k))$', fontsize=12)
ax1.set_title('Wreath Defect Along $m(k) = k^{\\alpha}$', fontsize=12)
ax1.legend(fontsize=8, ncol=2)
ax1.set_yscale('log')
ax1.grid(True, alpha=0.3)

# Panel 2: Subcritical ratio m^a / k^b
ax2 = axes[1]
for alpha in alpha_values:
    m_vals = np.maximum(1, np.floor(k_range ** alpha).astype(int))
    ratios = (m_vals.astype(float) ** a_exp) / (k_range.astype(float) ** b_exp)
    style = '-' if alpha < alpha_c else ('--' if alpha == alpha_c else ':')
    lw = 2.5 if abs(alpha - alpha_c) < 0.05 else 1.5
    ax2.plot(k_range, ratios, style, linewidth=lw,
             label=f'α={alpha}')

ax2.set_xlabel('k', fontsize=12)
ax2.set_ylabel('$m(k)^a / k^b$', fontsize=12)
ax2.set_title('Subcritical Ratio (→0 iff subcritical)', fontsize=12)
ax2.legend(fontsize=8, ncol=2)
ax2.set_yscale('log')
ax2.axhline(y=1, color='red', linestyle='-', linewidth=1, alpha=0.5)
ax2.grid(True, alpha=0.3)

# Panel 3: Per-copy pressure deviation
ax3 = axes[2]
for alpha in alpha_values:
    m_vals = np.maximum(1, np.floor(k_range ** alpha).astype(int))
    # Per-copy deviation = Δ(k,m)/m
    deviations = np.array([
        wreath_defect_model(int(k), int(m), C, a_exp, b_exp) / max(1, m)
        for k, m in zip(k_range, m_vals)
    ])
    style = '-' if alpha < alpha_c else ('--' if alpha == alpha_c else ':')
    lw = 2.5 if abs(alpha - alpha_c) < 0.05 else 1.5
    ax3.plot(k_range, deviations, style, linewidth=lw,
             label=f'α={alpha}')

ax3.set_xlabel('k', fontsize=12)
ax3.set_ylabel('$\\Delta(k,m(k)) / m(k)$', fontsize=12)
ax3.set_title('Per-Copy Pressure Deviation', fontsize=12)
ax3.legend(fontsize=8, ncol=2)
ax3.set_yscale('log')
ax3.grid(True, alpha=0.3)

plt.suptitle(
    f'Defect Decay: Critical Exponent $\\alpha_c = {alpha_c}$\n'
    f'(solid: subcritical, dashed: critical, dotted: supercritical)',
    fontsize=14, fontweight='bold'
)
plt.tight_layout()
plt.savefig('defect_decay.png', dpi=150, bbox_inches='tight')
print("Saved defect_decay.png")


#!/usr/bin/env python3
"""
Visualization: Phase Diagram for Wreath-Product Perturbation Regimes

Visualizes the (k, m) plane colored by perturbation regime:
- IRRELEVANT (blue): m^a/k^b ≪ 1, wreath effects vanish
- MARGINAL (yellow): m^a/k^b ~ 1, crossover region
- RELEVANT (red): m^a/k^b ≫ 1, new universality class

The critical curve m = k^(b/a) separates regimes.
This is the finite-group analog of a renormalization-group phase diagram.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors

# Parameters
C = 1.0
a = 1
b = 1
alpha_c = b / a  # Critical exponent

# Create grid
k_vals = np.arange(2, 101)
m_vals = np.arange(1, 201)
K, M = np.meshgrid(k_vals, m_vals)

# Compute scaling ratio
ratio = (M.astype(float) ** a) / (K.astype(float) ** b)
log_ratio = np.log10(ratio + 1e-10)

# Create figure
fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: Continuous heatmap
ax1 = axes[0]
im = ax1.pcolormesh(K, M, log_ratio, cmap='RdYlBu_r',
                     vmin=-2, vmax=2, shading='auto')
# Critical curve m = k^(b/a)
k_curve = np.linspace(2, 100, 200)
m_curve = k_curve ** alpha_c
ax1.plot(k_curve, m_curve, 'k-', linewidth=2.5,
         label=f'Critical: $m = k^{{{alpha_c}}}$')
ax1.plot(k_curve, 0.1 * m_curve, 'k--', linewidth=1,
         alpha=0.5, label='Subcritical boundary')
ax1.plot(k_curve, 10 * m_curve, 'k--', linewidth=1,
         alpha=0.5, label='Supercritical boundary')
ax1.set_xlabel('Group rank k', fontsize=12)
ax1.set_ylabel('Multiplicity m', fontsize=12)
ax1.set_title(f'Scaling Ratio $\\log_{{10}}(m^{a}/k^{b})$', fontsize=13)
ax1.legend(loc='upper left', fontsize=9)
plt.colorbar(im, ax=ax1, label='$\\log_{10}(m^a/k^b)$')

# Right panel: Discrete regime classification
ax2 = axes[1]
regime_map = np.zeros_like(ratio)
regime_map[ratio < 0.1] = 0    # Irrelevant
regime_map[(ratio >= 0.1) & (ratio <= 10)] = 1  # Marginal
regime_map[ratio > 10] = 2     # Relevant

cmap = mcolors.ListedColormap(['#3498db', '#f1c40f', '#e74c3c'])
bounds = [-0.5, 0.5, 1.5, 2.5]
norm = mcolors.BoundaryNorm(bounds, cmap.N)
im2 = ax2.pcolormesh(K, M, regime_map, cmap=cmap, norm=norm,
                      shading='auto')
ax2.plot(k_curve, m_curve, 'k-', linewidth=2.5,
         label=f'$\\alpha_c = {alpha_c}$')
ax2.set_xlabel('Group rank k', fontsize=12)
ax2.set_ylabel('Multiplicity m', fontsize=12)
ax2.set_title('Perturbation Regime Classification', fontsize=13)
cbar2 = plt.colorbar(im2, ax=ax2, ticks=[0, 1, 2])
cbar2.ax.set_yticklabels(['Irrelevant', 'Marginal', 'Relevant'])
ax2.legend(loc='upper left', fontsize=10)

plt.suptitle('Double-Scaling Phase Diagram: $S_k \\wr S_m$',
             fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig('phase_diagram.png', dpi=150, bbox_inches='tight')
print("Saved phase_diagram.png")


#!/usr/bin/env python3
"""
Visualization: Scaling Collapse of the Wreath Defect

Tests the crossover profile conjecture by plotting the rescaled defect
R_α(k,m) = k^α · Δ(k,m) / m against the scaling variable λ = m/k^α
for multiple values of k.

If the conjecture holds, curves for different k should collapse onto
a universal profile F(λ) when α equals the critical exponent.
This is the finite-group analog of data collapse in critical phenomena.
"""

import numpy as np
import matplotlib.pyplot as plt

# Model parameters
C = 1.0
a_exp = 1
b_exp = 1
alpha_c = b_exp / a_exp


def wreath_defect_model(k, m, C=1.0, a=1, b=1):
    """Model defect: Δ(k,m) = C · m^a / k^b."""
    if k == 0:
        return 0.0
    return C * (m ** a) / (k ** b)


def rescaled_defect(k, m, alpha, C=1.0, a=1, b=1):
    """Rescaled defect: R_α = k^α · Δ / m."""
    if m == 0 or k == 0:
        return 0.0
    d = wreath_defect_model(k, m, C, a, b)
    return (k ** alpha) * d / m


# Create figure with subplots for different candidate exponents
fig, axes = plt.subplots(2, 2, figsize=(12, 10))
alpha_candidates = [0.5, 1.0, 1.5, 2.0]
k_values = [10, 20, 50, 100, 200]
colors = plt.cm.viridis(np.linspace(0.1, 0.9, len(k_values)))

for idx, alpha in enumerate(alpha_candidates):
    ax = axes[idx // 2][idx % 2]

    for i, k in enumerate(k_values):
        # Generate m values
        m_max = min(int(5 * k ** alpha) + 1, 10000)
        m_vals = np.arange(1, m_max + 1)

        # Compute scaling variable and rescaled defect
        lambdas = m_vals / (k ** alpha)
        R_vals = np.array([rescaled_defect(k, m, alpha, C, a_exp, b_exp)
                           for m in m_vals])

        ax.plot(lambdas, R_vals, '-', color=colors[i],
                linewidth=1.5, alpha=0.8, label=f'k={k}')

    # Theoretical prediction for this model
    lam_theory = np.linspace(0.01, 5, 200)
    if abs(alpha - alpha_c) < 0.01:
        # At critical exponent: F(λ) = C (constant)
        ax.axhline(y=C, color='red', linestyle='--',
                   linewidth=2, label=f'F(λ) = C = {C}')
        collapse_quality = "PERFECT COLLAPSE"
    elif alpha < alpha_c:
        collapse_quality = "Curves diverge (subcritical α)"
    else:
        collapse_quality = "Curves shrink (supercritical α)"

    ax.set_xlabel('$\\lambda = m/k^{\\alpha}$', fontsize=11)
    ax.set_ylabel('$R_{\\alpha}(k,m) = k^{\\alpha} \\Delta / m$',
                  fontsize=11)
    ax.set_title(f'$\\alpha = {alpha}$ — {collapse_quality}',
                 fontsize=11)
    ax.legend(fontsize=8, loc='best')
    ax.set_xlim(0, 5)
    ax.grid(True, alpha=0.3)

plt.suptitle(
    'Scaling Collapse Test for Wreath Defect\n'
    f'Model: $|\\Delta(k,m)| = C \\cdot m^{a_exp}/k^{b_exp}$, '
    f'$\\alpha_c = {alpha_c}$',
    fontsize=14, fontweight='bold'
)
plt.tight_layout()
plt.savefig('scaling_collapse.png', dpi=150, bbox_inches='tight')
print("Saved scaling_collapse.png")
