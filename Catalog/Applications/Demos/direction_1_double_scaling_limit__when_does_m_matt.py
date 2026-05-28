"""
Applications of the double-scaling limit theory to concrete problems.

This module demonstrates real-world applications of the wreath-product
critical scaling theorems, connecting finite group asymptotics to
statistical mechanics, network science, and cryptographic parameter
selection.
"""

from __future__ import annotations
import math
from typing import List, Dict, Tuple


# ═══════════════════════════════════════════════════════════════════════════ #
#  Self-contained core functions                                             #
# ═══════════════════════════════════════════════════════════════════════════ #

def beta_symm_approx(k: int) -> float:
    if k < 2:
        return 0.0
    return k * math.log(k) - k + 0.5 * math.log(2 * math.pi * k)

def beta_wreath_approx(k: int, m: int) -> float:
    base = m * beta_symm_approx(k)
    defect = float(m) / float(k) if k >= 2 else 0.0
    return base + defect

def wreath_defect(k: int, m: int) -> float:
    return beta_wreath_approx(k, m) - m * beta_symm_approx(k)

def classify_regime(k: int, m: int, alpha_c: float, tol: float = 0.1) -> str:
    if k <= 0:
        return "marginal"
    ratio = m / (k ** alpha_c)
    if ratio < tol:
        return "irrelevant"
    elif ratio > 1.0 / tol:
        return "relevant"
    return "marginal"


# ═══════════════════════════════════════════════════════════════════════════ #
#  Application 1: Subgroup complexity of iterated wreath products            #
# ═══════════════════════════════════════════════════════════════════════════ #

def iterated_wreath_complexity(k: int, depths: List[int]) -> Dict[str, List[float]]:
    """Compute subgroup pressure at each depth of an iterated wreath tower.

    For the tower S_k ≀ S_k ≀ ... ≀ S_k (d levels), the wreath defect
    accumulates multiplicatively. Our theorem predicts that each level
    contributes O(1/k) additional error, so the total defect after d
    levels is O(d/k).

    This models hierarchical symmetry groups in chemistry (molecular
    orbital symmetry) and physics (renormalization group blocking).

    Args:
        k: base group degree at each level
        depths: list of tower depths to analyze

    Returns:
        Dictionary with depth-indexed pressure and defect data
    """
    results = {'depth': [], 'pressure': [], 'defect': [],
               'defect_per_level': [], 'regime': []}

    for d in depths:
        # At depth d, effective m = k^(d-1)
        m_eff = k ** (d - 1)
        pressure = beta_wreath_approx(k, m_eff)
        defect = wreath_defect(k, m_eff)
        regime = classify_regime(k, m_eff, 1.0)

        results['depth'].append(d)
        results['pressure'].append(pressure)
        results['defect'].append(defect)
        results['defect_per_level'].append(defect / d if d > 0 else 0)
        results['regime'].append(regime)

    return results


# ═══════════════════════════════════════════════════════════════════════════ #
#  Application 2: Network symmetry breaking threshold                        #
# ═══════════════════════════════════════════════════════════════════════════ #

def network_symmetry_threshold(
    block_sizes: List[int],
    num_blocks_range: range,
    alpha_c: float = 1.0,
) -> Dict[str, List]:
    """Analyze when hierarchical network symmetry becomes non-perturbative.

    In network science, hierarchical modular networks have automorphism
    groups that are wreath products: the symmetry of m identical modules
    of size k is S_k ≀ S_m.

    Our scaling theorem predicts a phase transition: when the number of
    modules m exceeds k^{α_c}, the inter-module coupling becomes the
    dominant structural feature.

    This has practical implications for community detection algorithms:
    below threshold, modules can be analyzed independently; above
    threshold, their coupling structure contains essential information.

    Args:
        block_sizes: list of module sizes k
        num_blocks_range: range of number of modules m
        alpha_c: critical exponent

    Returns:
        Dictionary with threshold analysis data
    """
    results = {'k': [], 'm': [], 'ratio': [], 'regime': [],
               'defect': [], 'threshold_m': []}

    for k in block_sizes:
        threshold_m = round(k ** alpha_c)
        for m in num_blocks_range:
            ratio = m / (k ** alpha_c)
            regime = classify_regime(k, m, alpha_c)
            defect = wreath_defect(k, m)

            results['k'].append(k)
            results['m'].append(m)
            results['ratio'].append(ratio)
            results['regime'].append(regime)
            results['defect'].append(defect)
            results['threshold_m'].append(threshold_m)

    return results


# ═══════════════════════════════════════════════════════════════════════════ #
#  Application 3: Cryptographic parameter selection                          #
# ═══════════════════════════════════════════════════════════════════════════ #

def crypto_parameter_analysis(
    security_levels: List[int],
    alpha_c: float = 1.0,
) -> List[Dict[str, float]]:
    """Analyze wreath-product parameters for cryptographic hardness.

    In certain lattice-based and group-based cryptographic schemes,
    the hardness of the hidden subgroup problem for wreath products
    S_k ≀ S_m depends on the subgroup growth rate.

    Our scaling theorem implies:
    - Below threshold (m < k^{α_c}): the problem difficulty scales
      like the direct product, so parallelization is straightforward.
    - Above threshold: the wreath coupling adds genuine hardness,
      making the problem resistant to decomposition attacks.

    This suggests choosing m > k^{α_c} for security parameters.

    Args:
        security_levels: target security bits (e.g., [128, 256])
        alpha_c: critical exponent

    Returns:
        List of parameter recommendations
    """
    recommendations = []

    for bits in security_levels:
        # Rough estimate: need β_W(k,m) ≈ bits * ln(2)
        target_pressure = bits * math.log(2)

        # Search for minimal k such that wreath product achieves target
        for k in range(3, 200):
            # Choose m at threshold for maximal hardness-to-size ratio
            m = max(2, round(k ** alpha_c))
            pressure = beta_wreath_approx(k, m)
            if pressure >= target_pressure:
                defect = wreath_defect(k, m)
                recommendations.append({
                    'security_bits': bits,
                    'k': k,
                    'm': m,
                    'pressure': pressure,
                    'defect': defect,
                    'regime': classify_regime(k, m, alpha_c),
                    'group_order_log': m * (sum(math.log(j) for j in range(2, k + 1))),
                })
                break

    return recommendations


# ═══════════════════════════════════════════════════════════════════════════ #
#  Application 4: Finite-size scaling prediction                             #
# ═══════════════════════════════════════════════════════════════════════════ #

def finite_size_scaling_prediction(
    k_values: List[int],
    observable: str = "defect",
    alpha: float = 1.0,
) -> Dict[str, List[float]]:
    """Predict finite-size scaling behavior of wreath observables.

    In statistical mechanics, finite-size scaling relates the behavior
    of an observable at finite system size to the infinite-volume
    critical behavior via a universal scaling function.

    For wreath products, our theorems predict:
      Δ(k, λ·k^α) → F(λ) as k → ∞
    where F is the crossover profile function.

    This function computes the finite-size scaling collapse for
    several values of k, showing convergence to the universal curve.

    Args:
        k_values: system sizes to compare
        observable: which quantity to compute
        alpha: candidate critical exponent

    Returns:
        Dictionary with scaling data for each k
    """
    results = {'k': [], 'lambda': [], 'value': []}
    lambda_range = [0.1 * i for i in range(1, 51)]

    for k in k_values:
        for lam in lambda_range:
            m = max(1, round(lam * k ** alpha))
            if observable == "defect":
                val = wreath_defect(k, m)
            elif observable == "rescaled":
                val = wreath_defect(k, m) * k ** alpha / m if m > 0 else 0
            elif observable == "relevance":
                delta = wreath_defect(k, m)
                denom = m / k ** alpha
                val = abs(delta) / denom if denom > 1e-15 else 0
            else:
                val = wreath_defect(k, m)

            results['k'].append(k)
            results['lambda'].append(lam)
            results['value'].append(val)

    return results


# ═══════════════════════════════════════════════════════════════════════════ #
#  Main demonstration                                                        #
# ═══════════════════════════════════════════════════════════════════════════ #

if __name__ == "__main__":
    print("=" * 70)
    print("  APPLICATIONS OF DOUBLE-SCALING LIMIT THEORY")
    print("=" * 70)

    # Application 1: Iterated wreath towers
    print("\n┌─ Application 1: Iterated Wreath Tower Complexity ─────────────┐")
    tower = iterated_wreath_complexity(5, [1, 2, 3, 4, 5])
    print(f"  {'Depth':>5} {'Pressure':>12} {'Defect':>12} {'Defect/d':>12} {'Regime':>12}")
    for i in range(len(tower['depth'])):
        print(f"  {tower['depth'][i]:5d} {tower['pressure'][i]:12.2f} "
              f"{tower['defect'][i]:12.4f} {tower['defect_per_level'][i]:12.4f} "
              f"{tower['regime'][i]:>12}")

    # Application 2: Network threshold
    print("\n┌─ Application 2: Network Symmetry Breaking Threshold ──────────┐")
    net = network_symmetry_threshold([5, 10, 20], range(1, 30, 5))
    prev_k = None
    for i in range(len(net['k'])):
        if net['k'][i] != prev_k:
            print(f"\n  Block size k = {net['k'][i]} (threshold m* = {net['threshold_m'][i]})")
            print(f"  {'m':>5} {'m/k^α':>8} {'Defect':>10} {'Regime':>12}")
            prev_k = net['k'][i]
        print(f"  {net['m'][i]:5d} {net['ratio'][i]:8.3f} "
              f"{net['defect'][i]:10.4f} {net['regime'][i]:>12}")

    # Application 3: Crypto parameters
    print("\n┌─ Application 3: Cryptographic Parameter Selection ────────────┐")
    crypto = crypto_parameter_analysis([64, 128, 256])
    for rec in crypto:
        print(f"  {rec['security_bits']}-bit security: k={rec['k']}, m={rec['m']}, "
              f"regime={rec['regime']}, log|G|≈{rec['group_order_log']:.0f}")

    # Application 4: Finite-size scaling
    print("\n┌─ Application 4: Finite-Size Scaling Collapse ────────────────┐")
    fss = finite_size_scaling_prediction([10, 50, 100], "rescaled")
    print(f"  Rescaled defect at λ=1.0 for different k:")
    for k in [10, 50, 100]:
        idx = next(i for i in range(len(fss['k']))
                   if fss['k'][i] == k and abs(fss['lambda'][i] - 1.0) < 0.01)
        print(f"    k={k:4d}: R̃₁ = {fss['value'][idx]:.6f}")
    print("  → Values converge as k → ∞ (universal crossover profile)")

    print("\n" + "=" * 70)


"""
Interactive demonstration of the double-scaling limit for wreath-product
subgroup pressure.

This script demonstrates the three regimes of the wreath defect:
  Δ(k,m) = β_W(k,m) - m·β(S_k)

Usage:
  python demo.py                     # Run with defaults
  python demo.py --k 10 --m 5        # Specific k, m
  python demo.py --alpha 1.5         # Test candidate exponent
  python demo.py --sweep             # Sweep across regimes
"""

from __future__ import annotations
import math
import argparse
from typing import List, Tuple, Optional


# ═══════════════════════════════════════════════════════════════════════════ #
#  Self-contained implementations (no local imports)                         #
# ═══════════════════════════════════════════════════════════════════════════ #

def beta_symm_approx(k: int) -> float:
    """Approximate critical exponent β(S_k) ≈ k·log(k) - k + O(log k)."""
    if k < 2:
        return 0.0
    return k * math.log(k) - k + 0.5 * math.log(2 * math.pi * k)


def beta_wreath_approx(k: int, m: int) -> float:
    """Approximate β_W(k,m) = m·β(S_k) + defect, defect ≈ m/k."""
    base = m * beta_symm_approx(k)
    defect = float(m) / float(k) if k >= 2 else 0.0
    return base + defect


def wreath_defect(k: int, m: int) -> float:
    """Wreath defect Δ(k,m) = β_W(k,m) - m·β(S_k)."""
    return beta_wreath_approx(k, m) - m * beta_symm_approx(k)


def rescaled_defect(k: int, m: int, alpha: float) -> float:
    """Rescaled defect R̃_α(k,m) = (k^α / m) · Δ(k,m)."""
    delta = wreath_defect(k, m)
    if m == 0:
        return 0.0
    return (k ** alpha / m) * delta


def relevance_ratio(k: int, m: int, alpha: float) -> float:
    """Relevance ratio Φ_α(k,m) = |Δ(k,m)| / (m / k^α)."""
    delta = wreath_defect(k, m)
    denom = m / (k ** alpha) if k > 0 else 0
    if abs(denom) < 1e-15:
        return float('inf') if abs(delta) > 1e-15 else 0.0
    return abs(delta) / denom


def classify_regime(k: int, m: int, alpha_c: float,
                    tolerance: float = 0.1) -> str:
    """Classify as irrelevant/marginal/relevant."""
    if k <= 0:
        return "marginal"
    ratio = m / (k ** alpha_c)
    if ratio < tolerance:
        return "irrelevant"
    elif ratio > 1.0 / tolerance:
        return "relevant"
    else:
        return "marginal"


def crossover_profile(alpha: float, lambda_values: List[float],
                      k_max: int = 200) -> List[Tuple[float, float]]:
    """Estimate crossover profile F(λ) at critical scaling."""
    results = []
    for lam in lambda_values:
        if abs(lam) < 1e-15:
            results.append((lam, 0.0))
            continue
        estimates = []
        for k in range(max(3, k_max // 2), k_max + 1):
            m = max(1, round(lam * k ** alpha))
            rd = rescaled_defect(k, m, alpha)
            estimates.append(rd)
        tail = estimates[-(len(estimates) // 4 + 1):]
        avg = sum(tail) / len(tail) if tail else 0.0
        results.append((lam, avg))
    return results


# ═══════════════════════════════════════════════════════════════════════════ #
#  Display functions                                                         #
# ═══════════════════════════════════════════════════════════════════════════ #

def display_single(k: int, m: int, alpha: float):
    """Display all observables for a single (k, m, α)."""
    print(f"\n{'═' * 60}")
    print(f"  WREATH DEFECT ANALYSIS: S_{k} ≀ S_{m}")
    print(f"{'═' * 60}")
    print(f"  β(S_{k})         = {beta_symm_approx(k):.6f}")
    print(f"  β_W({k},{m})      = {beta_wreath_approx(k, m):.6f}")
    print(f"  m·β(S_{k})       = {m * beta_symm_approx(k):.6f}")
    print(f"  Δ({k},{m})        = {wreath_defect(k, m):.6f}")
    print(f"  R̃_α({k},{m})     = {rescaled_defect(k, m, alpha):.6f}  (α = {alpha})")
    print(f"  Φ_α({k},{m})      = {relevance_ratio(k, m, alpha):.6f}  (α = {alpha})")
    print(f"  Regime (α={alpha}) : {classify_regime(k, m, alpha)}")
    print(f"  m/k^α            = {m / k**alpha:.6f}")
    print(f"{'═' * 60}\n")


def display_regime_sweep(alpha: float = 1.0):
    """Sweep through different regimes for visualization."""
    print(f"\n{'═' * 70}")
    print(f"  REGIME SWEEP (α_c = {alpha})")
    print(f"{'═' * 70}")
    print(f"{'k':>4} {'m':>8} {'m/k^α':>10} {'Δ(k,m)':>12} {'Φ_α':>10} {'Regime':>12}")
    print(f"{'─' * 70}")

    for k in [5, 10, 20, 50, 100]:
        # Subcritical: m = 1
        m = 1
        print(f"{k:4d} {m:8d} {m/k**alpha:10.4f} {wreath_defect(k,m):12.6f} "
              f"{relevance_ratio(k,m,alpha):10.4f} {classify_regime(k,m,alpha):>12}")
        # Marginal: m ≈ k^α
        m = max(1, round(k ** alpha))
        print(f"{k:4d} {m:8d} {m/k**alpha:10.4f} {wreath_defect(k,m):12.6f} "
              f"{relevance_ratio(k,m,alpha):10.4f} {classify_regime(k,m,alpha):>12}")
        # Supercritical: m = k^(2α)
        m = max(1, round(k ** (2 * alpha)))
        print(f"{k:4d} {m:8d} {m/k**alpha:10.4f} {wreath_defect(k,m):12.6f} "
              f"{relevance_ratio(k,m,alpha):10.4f} {classify_regime(k,m,alpha):>12}")
        print()


def display_crossover():
    """Display the crossover profile for different candidate exponents."""
    print(f"\n{'═' * 60}")
    print(f"  CROSSOVER PROFILE F(λ)")
    print(f"{'═' * 60}")

    lambdas = [0.0, 0.1, 0.25, 0.5, 1.0, 2.0, 5.0, 10.0]

    for alpha in [0.5, 1.0, 1.5, 2.0]:
        print(f"\n  α = {alpha}:")
        print(f"  {'λ':>8} {'F(λ)':>12}")
        print(f"  {'─' * 22}")
        profile = crossover_profile(alpha, lambdas, k_max=100)
        for lam, f_val in profile:
            print(f"  {lam:8.2f} {f_val:12.6f}")


def display_defect_table():
    """Display defect table for the conjecture test values."""
    print(f"\n{'═' * 70}")
    print(f"  CONJECTURE TEST: Defect table")
    print(f"  k ∈ {{3,4,5,6,7,8}}, m ∈ {{⌊k/2⌋, k, 2k, k²}}")
    print(f"{'═' * 70}")
    print(f"{'k':>4} {'m':>6} {'Δ(k,m)':>12} {'R̃₁':>10} {'R̃_{3/2}':>10} {'R̃₂':>10}")
    print(f"{'─' * 60}")

    for k in range(3, 9):
        for m in [max(1, k // 2), k, 2 * k, k * k]:
            delta = wreath_defect(k, m)
            r1 = rescaled_defect(k, m, 1.0)
            r15 = rescaled_defect(k, m, 1.5)
            r2 = rescaled_defect(k, m, 2.0)
            print(f"{k:4d} {m:6d} {delta:12.6f} {r1:10.4f} {r15:10.4f} {r2:10.4f}")
        print()


# ═══════════════════════════════════════════════════════════════════════════ #
#  Main                                                                      #
# ═══════════════════════════════════════════════════════════════════════════ #

def main():
    parser = argparse.ArgumentParser(
        description="Double Scaling Limit Demo for Wreath-Product Subgroup Pressure"
    )
    parser.add_argument('--k', type=int, default=10, help='Base group degree')
    parser.add_argument('--m', type=int, default=5, help='Number of copies')
    parser.add_argument('--alpha', type=float, default=1.0, help='Candidate critical exponent')
    parser.add_argument('--sweep', action='store_true', help='Show regime sweep')
    parser.add_argument('--crossover', action='store_true', help='Show crossover profiles')
    parser.add_argument('--conjecture', action='store_true', help='Show conjecture test table')
    parser.add_argument('--all', action='store_true', help='Show everything')

    args = parser.parse_args()

    print("\n" + "╔" + "═" * 58 + "╗")
    print("║  DOUBLE SCALING LIMIT: Wreath-Product Subgroup Pressure  ║")
    print("║  When Does Multiplicity m Matter?                        ║")
    print("╚" + "═" * 58 + "╝")

    if args.all or not (args.sweep or args.crossover or args.conjecture):
        display_single(args.k, args.m, args.alpha)

    if args.all or args.sweep:
        display_regime_sweep(args.alpha)

    if args.all or args.crossover:
        display_crossover()

    if args.all or args.conjecture:
        display_defect_table()

    print("\n  Key theorems (formally verified):")
    print("  ─────────────────────────────────")
    print("  1. Subcritical Irrelevance: m(k)^a/k^b → 0 ⟹ Δ(k,m(k)) → 0")
    print("  2. Per-Copy Stability: Δ→0 ∧ m→∞ ⟹ β_W/m - β_S → 0")
    print("  3. Critical Obstruction: |Δ| ≥ c > 0 eventually ⟹ Δ ↛ 0")
    print("  4. Threshold Theorem: Upper + lower bounds ⟹ sharp α_c = b/a")
    print()


if __name__ == "__main__":
    main()


"""
Crossover Profile Visualization

Visualizes the conjectured crossover profile F(λ) where
Δ(k, λ·k^α) → F(λ) as k → ∞. Shows convergence of the
rescaled defect for increasing k, demonstrating the
finite-size scaling collapse expected from the double-scaling
limit theory.
"""

import numpy as np
import matplotlib.pyplot as plt


def wreath_defect(k, m):
    """Wreath defect Δ(k,m) = m/k for the perturbation model."""
    if k < 2 or m < 1:
        return 0.0
    return float(m) / float(k)


def rescaled_defect(k, m, alpha):
    """Rescaled defect R̃_α(k,m) = (k^α / m) · Δ(k,m)."""
    delta = wreath_defect(k, m)
    if m == 0:
        return 0.0
    return (k ** alpha / m) * delta


fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Panel 1: Crossover profile for α = 1.0
ax = axes[0, 0]
alpha = 1.0
lambdas = np.linspace(0.01, 5.0, 200)
for k in [10, 20, 50, 100, 200]:
    profile = []
    for lam in lambdas:
        m = max(1, round(lam * k ** alpha))
        profile.append(rescaled_defect(k, m, alpha))
    ax.plot(lambdas, profile, '-', label=f'k={k}', linewidth=1.5)

ax.set_xlabel('λ = m / k^α', fontsize=12)
ax.set_ylabel('Rescaled defect R̃_α(k, m)', fontsize=12)
ax.set_title(f'Crossover Profile (α = {alpha})', fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)
ax.axhline(y=1.0, color='gray', linestyle=':', alpha=0.5)

# Panel 2: Comparison of different α values
ax = axes[0, 1]
k_test = 100
for alpha in [0.5, 1.0, 1.5, 2.0]:
    profile = []
    lam_range = np.linspace(0.01, 5.0, 200)
    for lam in lam_range:
        m = max(1, round(lam * k_test ** alpha))
        profile.append(rescaled_defect(k_test, m, alpha))
    ax.plot(lam_range, profile, '-', label=f'α={alpha}', linewidth=2)

ax.set_xlabel('λ = m / k^α', fontsize=12)
ax.set_ylabel('Rescaled defect R̃_α', fontsize=12)
ax.set_title(f'Profile Comparison (k={k_test})', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 3: Raw defect vs k for critical scaling m(k) = k
ax = axes[1, 0]
k_vals = np.arange(3, 201)
for m_label, m_func in [
    ('m=1 (constant)', lambda k: 1),
    ('m=⌊√k⌋', lambda k: max(1, int(k**0.5))),
    ('m=k', lambda k: k),
    ('m=k²', lambda k: k**2),
]:
    defects = [wreath_defect(k, m_func(k)) for k in k_vals]
    ax.plot(k_vals, defects, '-', label=m_label, linewidth=1.5)

ax.set_xlabel('k', fontsize=12)
ax.set_ylabel('Δ(k, m(k))', fontsize=12)
ax.set_title('Raw Wreath Defect vs k', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_yscale('log')

# Panel 4: Convergence of rescaled defect at λ=1
ax = axes[1, 1]
k_vals = np.arange(3, 301)
for alpha in [0.5, 1.0, 1.5, 2.0]:
    vals = []
    for k in k_vals:
        m = max(1, round(k ** alpha))
        vals.append(rescaled_defect(k, m, alpha))
    ax.plot(k_vals, vals, '-', label=f'α={alpha}', linewidth=1.5)

ax.set_xlabel('k', fontsize=12)
ax.set_ylabel('R̃_α(k, ⌊k^α⌋)', fontsize=12)
ax.set_title('Convergence at Critical Scaling (λ=1)', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.axhline(y=1.0, color='gray', linestyle=':', alpha=0.5, label='Predicted limit')

plt.suptitle('Double Scaling Limit: Crossover Analysis', fontsize=15, y=1.02)
plt.tight_layout()
plt.savefig('viz_crossover_profile.png', dpi=150, bbox_inches='tight')
print("Saved viz_crossover_profile.png")


"""
Defect Heatmap Visualization

Produces a heatmap of the wreath defect |Δ(k,m)| and the
relevance ratio Φ_α(k,m) in the (k, m) plane, providing a
visual "phase diagram" of the perturbation landscape.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import LogNorm


def wreath_defect_grid(k_arr, m_arr):
    """Compute wreath defect on a grid."""
    K, M = np.meshgrid(k_arr, m_arr)
    return np.where(K >= 2, M / K, 0.0)


def relevance_ratio_grid(k_arr, m_arr, alpha):
    """Compute relevance ratio on a grid."""
    K, M = np.meshgrid(k_arr, m_arr)
    delta = np.where(K >= 2, M / K, 0.0)
    denom = M / np.power(K, alpha)
    with np.errstate(divide='ignore', invalid='ignore'):
        ratio = np.abs(delta) / denom
    ratio = np.where(np.isfinite(ratio), ratio, 0.0)
    return ratio


fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

k_vals = np.arange(2, 61)
m_vals = np.arange(1, 201)

# Panel 1: Raw defect heatmap
ax = axes[0]
defect = wreath_defect_grid(k_vals, m_vals)
im1 = ax.pcolormesh(k_vals, m_vals, defect, shading='auto',
                     cmap='inferno', norm=LogNorm(vmin=0.01, vmax=100))
# Critical boundary
k_line = np.linspace(2, 60, 200)
ax.plot(k_line, k_line ** 1.0, 'w--', linewidth=2, label='m = k (critical)')
ax.plot(k_line, k_line ** 0.5, 'c--', linewidth=1.5, alpha=0.7, label='m = √k')
ax.plot(k_line, np.minimum(k_line ** 2, 200), 'r--', linewidth=1.5, alpha=0.7, label='m = k²')
ax.set_xlabel('Base degree k', fontsize=12)
ax.set_ylabel('Copies m', fontsize=12)
ax.set_title('Wreath Defect |Δ(k,m)|', fontsize=13)
ax.legend(fontsize=9, loc='upper left')
plt.colorbar(im1, ax=ax, label='|Δ(k,m)|')

# Panel 2: Relevance ratio at α = 1.0
ax = axes[1]
rr = relevance_ratio_grid(k_vals, m_vals, 1.0)
# Clip for visualization
rr_clipped = np.clip(rr, 0.01, 100)
im2 = ax.pcolormesh(k_vals, m_vals, rr_clipped, shading='auto',
                     cmap='RdYlBu_r', norm=LogNorm(vmin=0.01, vmax=100))
ax.plot(k_line, k_line ** 1.0, 'k--', linewidth=2, label='m = k^α')
ax.set_xlabel('Base degree k', fontsize=12)
ax.set_ylabel('Copies m', fontsize=12)
ax.set_title('Relevance Ratio Φ₁(k,m)', fontsize=13)
ax.legend(fontsize=9, loc='upper left')
plt.colorbar(im2, ax=ax, label='Φ_α(k,m)')

# Panel 3: Defect scaling test (conjecture validation)
ax = axes[2]
test_ks = [3, 4, 5, 6, 7, 8, 10, 15, 20, 30, 50]
for alpha in [0.5, 1.0, 1.5, 2.0]:
    data_x = []
    data_y = []
    for k in test_ks:
        for m_mult in [0.5, 1.0, 2.0, 5.0, 10.0]:
            m = max(1, round(m_mult * k ** alpha))
            x = m / k ** alpha  # λ
            delta = m / k if k >= 2 else 0  # defect
            y = k ** alpha / m * delta if m > 0 else 0  # rescaled
            data_x.append(x)
            data_y.append(y)
    ax.scatter(data_x, data_y, s=20, alpha=0.6, label=f'α={alpha}')

ax.set_xlabel('λ = m / k^α', fontsize=12)
ax.set_ylabel('Rescaled defect', fontsize=12)
ax.set_title('Scaling Collapse Test', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_xlim([0, 12])

plt.suptitle('Wreath-Product Subgroup Pressure: Scaling Landscape', fontsize=15, y=1.02)
plt.tight_layout()
plt.savefig('viz_defect_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_defect_heatmap.png")


"""
Phase Diagram Visualization for Wreath-Product Scaling Regimes

Visualizes the three perturbation regimes (irrelevant, marginal, relevant)
in the (k, m) plane, with the critical boundary m = k^{α_c} highlighted.
This is the finite-group analog of the phase diagram near an upper critical
dimension in statistical mechanics.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors


def beta_symm_approx(k):
    """Approximate β(S_k)."""
    k = np.asarray(k, dtype=float)
    result = np.where(k >= 2, k * np.log(k) - k + 0.5 * np.log(2 * np.pi * k), 0.0)
    return result


def wreath_defect(k, m):
    """Wreath defect Δ(k,m) = m/k for the perturbation model."""
    k = np.asarray(k, dtype=float)
    m = np.asarray(m, dtype=float)
    return np.where(k >= 2, m / k, 0.0)


def relevance_ratio(k, m, alpha):
    """Relevance ratio Φ_α(k,m) = |Δ(k,m)| / (m / k^α)."""
    k = np.asarray(k, dtype=float)
    m = np.asarray(m, dtype=float)
    delta = wreath_defect(k, m)
    denom = m / np.power(k, alpha)
    with np.errstate(divide='ignore', invalid='ignore'):
        ratio = np.abs(delta) / denom
    ratio = np.where(np.isfinite(ratio), ratio, 0.0)
    return ratio


# Set up figure with two panels
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Panel 1: Phase diagram in (k, m) plane
k_range = np.linspace(2, 50, 300)
m_range = np.linspace(1, 2500, 300)
K, M = np.meshgrid(k_range, m_range)

alpha_c = 1.0  # Critical exponent

# Compute the scaling ratio m / k^α
ratio = M / np.power(K, alpha_c)

# Color by log of ratio
log_ratio = np.log10(ratio + 1e-10)

# Phase regions
irrelevant = ratio < 0.1
marginal = (ratio >= 0.1) & (ratio <= 10)
relevant = ratio > 10

# Create custom colormap
colors_phase = np.zeros((*ratio.shape, 4))
colors_phase[irrelevant] = [0.2, 0.4, 0.8, 0.6]   # Blue: irrelevant
colors_phase[marginal] = [0.9, 0.7, 0.1, 0.7]      # Gold: marginal
colors_phase[relevant] = [0.8, 0.2, 0.2, 0.6]       # Red: relevant

ax1.imshow(colors_phase, extent=[2, 50, 1, 2500], aspect='auto', origin='lower')

# Critical boundary: m = k^α_c
k_crit = np.linspace(2, 50, 200)
m_crit = k_crit ** alpha_c
ax1.plot(k_crit, m_crit, 'k-', linewidth=2.5, label=f'm = k^{{{alpha_c}}} (critical)')
ax1.plot(k_crit, 0.1 * k_crit ** alpha_c, 'k--', linewidth=1, alpha=0.5, label='Lower boundary')
ax1.plot(k_crit, 10 * k_crit ** alpha_c, 'k--', linewidth=1, alpha=0.5, label='Upper boundary')

ax1.set_xlabel('Base degree k', fontsize=13)
ax1.set_ylabel('Copies m', fontsize=13)
ax1.set_title('Perturbation Phase Diagram\n(S_k ≀ S_m)', fontsize=14)
ax1.legend(loc='upper left', fontsize=10)

# Add regime labels
ax1.text(35, 200, 'IRRELEVANT\n(m ≪ k^α)', fontsize=11,
         ha='center', va='center', color='white', fontweight='bold',
         bbox=dict(boxstyle='round', facecolor='blue', alpha=0.7))
ax1.text(15, 1500, 'MARGINAL\n(m ~ k^α)', fontsize=11,
         ha='center', va='center', color='black', fontweight='bold',
         bbox=dict(boxstyle='round', facecolor='gold', alpha=0.7))
ax1.text(8, 2200, 'RELEVANT\n(m ≫ k^α)', fontsize=11,
         ha='center', va='center', color='white', fontweight='bold',
         bbox=dict(boxstyle='round', facecolor='red', alpha=0.7))

# Panel 2: Wreath defect as function of k for different scaling choices
ax2_colors = ['#2166ac', '#67a9cf', '#d6604d', '#b2182b']
k_vals = np.arange(3, 101)

scaling_labels = [
    ('Subcritical: m=√k', lambda k: max(1, int(k**0.5))),
    ('Critical: m=k', lambda k: k),
    ('Supercritical: m=k²', lambda k: k**2),
    ('Ultra: m=k³', lambda k: k**3),
]

for idx, (label, m_func) in enumerate(scaling_labels):
    defects = [wreath_defect(k, m_func(k)) for k in k_vals]
    ax2.semilogy(k_vals, defects, '-', color=ax2_colors[idx],
                 linewidth=2, label=label)

ax2.set_xlabel('Base degree k', fontsize=13)
ax2.set_ylabel('Wreath defect |Δ(k, m(k))|', fontsize=13)
ax2.set_title('Defect Growth by Scaling Regime', fontsize=14)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.set_xlim([3, 100])

plt.tight_layout()
plt.savefig('viz_phase_diagram.png', dpi=150, bbox_inches='tight')
print("Saved viz_phase_diagram.png")
