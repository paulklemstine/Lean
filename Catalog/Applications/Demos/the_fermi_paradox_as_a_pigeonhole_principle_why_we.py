"""
Applications of the Fermi Paradox Pigeonhole Analysis

Real-world applications:
1. SETI search strategy optimization
2. Drake parameter sensitivity analysis  
3. Civilization detection probability curves
4. Great Filter location estimation
"""

import math
from typing import Optional


def seti_search_strategy(
    total_planets: int = 10**10,
    per_planet_prob: float = 1e-11,
    survey_budget: int = 10000,
) -> dict:
    """
    Optimize SETI search strategy using the pigeonhole framework.
    
    Given a budget of `survey_budget` planets to survey, compute:
    - Expected detections
    - Probability of at least one detection
    - Number of planets needed for 50% detection probability
    - Number of planets needed for 95% detection probability
    
    Uses the Bayesian silence theorem: after m null observations,
    the upper bound on p is approximately 1/m.
    """
    expected_detections = survey_budget * per_planet_prob
    prob_at_least_one = 1 - (1 - per_planet_prob) ** survey_budget
    
    # Poisson approximation for prob
    prob_poisson = 1 - math.exp(-expected_detections)
    
    # Planets needed for target detection probability
    def planets_for_prob(target: float) -> int:
        if per_planet_prob <= 0:
            return float('inf')
        return math.ceil(math.log(1 - target) / math.log(1 - per_planet_prob))
    
    planets_50 = planets_for_prob(0.5)
    planets_95 = planets_for_prob(0.95)
    
    # After null result, Bayesian bound
    bayesian_bound = 1.0 / survey_budget if survey_budget > 0 else 1.0
    
    return {
        "survey_budget": survey_budget,
        "per_planet_prob": per_planet_prob,
        "expected_detections": expected_detections,
        "prob_at_least_one": prob_at_least_one,
        "prob_at_least_one_poisson": prob_poisson,
        "planets_for_50pct": planets_50,
        "planets_for_95pct": planets_95,
        "bayesian_upper_bound_after_null": bayesian_bound,
    }


def drake_sensitivity(
    base_params: dict[str, float],
    param_name: str,
    multipliers: list[float],
) -> list[dict]:
    """
    Sensitivity analysis: how does changing one Drake factor
    affect the expected number of civilizations?
    
    Demonstrates the tropical bottleneck: the most sensitive
    parameter is the one with the largest partial derivative
    in log-space (= the tropical bottleneck).
    """
    base_product = 1.0
    for v in base_params.values():
        base_product *= v
    
    results = []
    for mult in multipliers:
        modified = dict(base_params)
        modified[param_name] = base_params[param_name] * mult
        new_product = 1.0
        for v in modified.values():
            new_product *= v
        
        results.append({
            "multiplier": mult,
            "original_value": base_params[param_name],
            "modified_value": modified[param_name],
            "original_E": base_product,
            "modified_E": new_product,
            "ratio": new_product / base_product if base_product > 0 else float('inf'),
        })
    
    return results


def great_filter_location(
    observed_prob: float,
    factor_names: list[str],
    factor_estimates: list[tuple[float, float]],  # (lower, upper) bounds
) -> dict:
    """
    Estimate where the Great Filter is located.
    
    Given bounds on each Drake factor and the observed overall probability,
    determine which factor(s) must be most extreme to explain the observation.
    
    This uses the tropical amplification theorem: if the total filter
    strength is S, and there are k factors each at least c, then S ≥ kc.
    The factor that deviates most from the geometric mean is the bottleneck.
    """
    k = len(factor_names)
    total_log = -math.log(observed_prob) if observed_prob > 0 else float('inf')
    
    # Geometric mean filter strength per factor
    mean_strength = total_log / k if k > 0 else 0
    
    results = []
    for i, (name, (lo, hi)) in enumerate(zip(factor_names, factor_estimates)):
        # Filter strength range for this factor
        strength_lo = -math.log(hi) if hi > 0 else float('inf')
        strength_hi = -math.log(lo) if lo > 0 else float('inf')
        
        # How much above the mean could this factor be?
        excess = max(0, strength_hi - mean_strength)
        
        results.append({
            "name": name,
            "prob_range": (lo, hi),
            "strength_range": (strength_lo, strength_hi),
            "mean_strength": mean_strength,
            "max_excess": excess,
            "could_be_bottleneck": strength_hi > mean_strength,
        })
    
    # Sort by max excess (most likely bottleneck first)
    results.sort(key=lambda x: x["max_excess"], reverse=True)
    
    return {
        "total_filter_strength": total_log,
        "num_factors": k,
        "mean_strength_per_factor": mean_strength,
        "factor_analysis": results,
        "most_likely_bottleneck": results[0]["name"] if results else None,
    }


def civilization_detection_curve(
    per_planet_prob: float,
    max_planets: int = 10**12,
    num_points: int = 50,
) -> list[dict]:
    """
    Generate the detection probability curve:
    P(at least one detection | surveyed m planets) vs m.
    
    This illustrates the transition from "almost certainly alone"
    to "almost certainly not alone" as the survey grows.
    """
    points = []
    for i in range(num_points + 1):
        # Logarithmic spacing
        if i == 0:
            m = 1
        else:
            m = int(10 ** (math.log10(max_planets) * i / num_points))
        
        expected = m * per_planet_prob
        prob_detect = 1 - math.exp(-expected)  # Poisson approx
        
        points.append({
            "planets_surveyed": m,
            "expected_civilizations": expected,
            "prob_at_least_one": prob_detect,
            "surprise_bits": -math.log2(per_planet_prob) if per_planet_prob > 0 else float('inf'),
        })
    
    return points


if __name__ == "__main__":
    print("=== SETI Search Strategy ===")
    result = seti_search_strategy()
    print(f"Budget: {result['survey_budget']:,} planets")
    print(f"Expected detections: {result['expected_detections']:.2e}")
    print(f"P(detection): {result['prob_at_least_one']:.2e}")
    print(f"Need {result['planets_for_50pct']:.2e} planets for 50% chance")
    print(f"Need {result['planets_for_95pct']:.2e} planets for 95% chance")
    
    print("\n=== Drake Sensitivity ===")
    base = {
        "f_l": 0.1,
        "f_i": 1e-4,
        "f_c": 1e-6,
        "n_planets": 1e10,
    }
    for param in ["f_l", "f_i", "f_c"]:
        results = drake_sensitivity(base, param, [0.1, 1, 10, 100])
        print(f"\n  Varying {param}:")
        for r in results:
            print(f"    ×{r['multiplier']:>5.1f}: E={r['modified_E']:.2e} (ratio {r['ratio']:.1f})")
    
    print("\n=== Great Filter Location ===")
    location = great_filter_location(
        observed_prob=1e-11,
        factor_names=["Abiogenesis", "Multicellularity", "Intelligence", "Technology", "Survival"],
        factor_estimates=[
            (1e-4, 0.5),    # Abiogenesis: very uncertain
            (1e-2, 0.9),    # Multicellularity: moderate
            (1e-3, 0.1),    # Intelligence: uncertain
            (1e-2, 0.5),    # Technology: moderate
            (1e-4, 0.1),    # Survival: uncertain
        ]
    )
    print(f"Total filter strength: {location['total_filter_strength']:.1f} nats")
    print(f"Most likely bottleneck: {location['most_likely_bottleneck']}")
    for f in location["factor_analysis"]:
        indicator = " ← BOTTLENECK" if f["name"] == location["most_likely_bottleneck"] else ""
        print(f"  {f['name']:20s}: strength range [{f['strength_range'][0]:.1f}, {f['strength_range'][1]:.1f}]{indicator}")


"""
Demo: The Fermi Paradox as a Pigeonhole Principle

Demonstrates the key theorems with concrete numerical examples:
1. Reverse Pigeonhole: most planets are empty
2. Drake equation with conservative estimates
3. Great Filter Dichotomy
4. Tropical bottleneck analysis
5. Information-theoretic surprise of finding ET
"""

import math
import random


def drake_expected_civilizations(num_planets: int, per_planet_prob: float) -> float:
    """Compute expected number of civilizations: E[N] = n * p."""
    return num_planets * per_planet_prob


def reverse_pigeonhole_demo(k: int, n: int) -> int:
    """
    Demonstrate the reverse pigeonhole principle.
    If k civilizations are distributed among n planets (k < n),
    at least n - k planets are empty.
    
    Returns the actual number of empty planets for a random assignment.
    """
    assert k < n, f"Need k={k} < n={n}"
    # Random assignment of k civilizations to n planets
    assignment = [random.randint(0, n-1) for _ in range(k)]
    occupied = len(set(assignment))
    empty = n - occupied
    guaranteed_empty = n - k
    print(f"  {k} civilizations, {n} planets")
    print(f"  Guaranteed empty (by theorem): ≥ {guaranteed_empty}")
    print(f"  Actual empty (random trial):    {empty}")
    assert empty >= guaranteed_empty, "Theorem violated!"
    return empty


def great_filter_dichotomy(num_planets: int, per_planet_prob: float) -> str:
    """
    Classify whether we're in the 'strong filter' or 'weak filter' regime.
    Threshold: p = 1/n.
    """
    threshold = 1.0 / num_planets
    expected = drake_expected_civilizations(num_planets, per_planet_prob)
    if per_planet_prob < threshold:
        return f"STRONG FILTER: p={per_planet_prob:.2e} < 1/n={threshold:.2e}, E[N]={expected:.4f} < 1"
    else:
        return f"WEAK FILTER: p={per_planet_prob:.2e} ≥ 1/n={threshold:.2e}, E[N]={expected:.4f} ≥ 1"


def tropical_bottleneck(factors: list[float]) -> dict:
    """
    Analyze the Drake equation through tropical geometry.
    Each factor's negative log gives the 'filter strength'.
    The bottleneck is the maximum (= hardest step).
    """
    log_factors = [-math.log10(f) for f in factors]
    bottleneck = max(log_factors)
    total = sum(log_factors)
    bottleneck_idx = log_factors.index(bottleneck)
    return {
        "factors": factors,
        "log_strengths": log_factors,
        "bottleneck_index": bottleneck_idx,
        "bottleneck_strength": bottleneck,
        "total_strength": total,
        "bottleneck_dominance": bottleneck / total if total > 0 else 0
    }


def civilization_surprise(per_planet_prob: float) -> float:
    """
    Information content (surprise) of finding a civilization,
    measured in bits: -log₂(p).
    """
    return -math.log2(per_planet_prob)


def silence_upper_bound(planets_checked: int) -> float:
    """
    If we've checked m planets and found zero civilizations,
    the Bayesian upper bound on per-planet probability is 1/m.
    """
    return 1.0 / planets_checked


def great_filter_threshold_test(k: int, min_factor: float = 1e-3) -> dict:
    """
    Test the Great Filter Threshold conjecture:
    Can k factors all ≥ min_factor have product < 10^{-10}?
    
    For k ≤ 3: NO (product ≥ 10^{-9} > 10^{-10})
    For k ≥ 4: YES (product can be ≤ 10^{-12} < 10^{-10})
    """
    product = min_factor ** k
    threshold = 1e-10
    return {
        "k": k,
        "min_factor": min_factor,
        "product_at_minimum": product,
        "threshold": threshold,
        "conjecture_holds": product >= threshold,
        "explanation": f"({min_factor})^{k} = {product:.2e} {'≥' if product >= threshold else '<'} {threshold:.2e}"
    }


def main():
    print("=" * 70)
    print("THE FERMI PARADOX AS A PIGEONHOLE PRINCIPLE")
    print("=" * 70)
    
    # Demo 1: Reverse Pigeonhole
    print("\n--- Demo 1: Reverse Pigeonhole ---")
    print("If k civilizations occupy n planets, at least n-k are empty.\n")
    random.seed(42)
    for k, n in [(1, 100), (5, 1000), (10, 10000)]:
        reverse_pigeonhole_demo(k, n)
        print()
    
    # Demo 2: Drake Equation with Conservative Estimates
    print("--- Demo 2: Drake Equation (Conservative) ---")
    params = [
        ("Ultra-conservative", 10**10, 1e-11),
        ("Conservative", 10**10, 1e-10),
        ("Moderate", 10**10, 1e-9),
        ("Optimistic", 10**10, 1e-8),
    ]
    for name, n, p in params:
        E = drake_expected_civilizations(n, p)
        print(f"  {name:20s}: n={n:.0e}, p={p:.0e}, E[N]={E:.4f}")
    print()
    
    # Demo 3: Great Filter Dichotomy
    print("--- Demo 3: Great Filter Dichotomy ---")
    for n, p in [(10**10, 1e-11), (10**10, 1e-10), (10**10, 1e-9)]:
        print(f"  {great_filter_dichotomy(n, p)}")
    print()
    
    # Demo 4: Tropical Bottleneck Analysis
    print("--- Demo 4: Tropical Bottleneck Analysis ---")
    # Typical Drake factors: f_l, f_i, f_c
    factors = [0.1, 1e-4, 1e-6]  # life, intelligence, communication
    result = tropical_bottleneck(factors)
    print(f"  Factors: {factors}")
    print(f"  Log-strengths: {[f'{x:.1f}' for x in result['log_strengths']]}")
    print(f"  Bottleneck: factor {result['bottleneck_index']} (strength {result['bottleneck_strength']:.1f})")
    print(f"  Total strength: {result['total_strength']:.1f}")
    print(f"  Bottleneck dominance: {result['bottleneck_dominance']:.1%}")
    print()
    
    # Demo 5: Information Surprise
    print("--- Demo 5: Civilization Surprise (Information Theory) ---")
    for p in [1e-5, 1e-10, 1e-15, 1e-20]:
        bits = civilization_surprise(p)
        print(f"  p={p:.0e}: surprise = {bits:.1f} bits")
    print()
    
    # Demo 6: Silence Upper Bound
    print("--- Demo 6: Bayesian Silence Bound ---")
    for m in [100, 1000, 10**6, 10**9]:
        bound = silence_upper_bound(m)
        print(f"  Checked {m:>12,d} planets → p ≤ {bound:.2e}")
    print()
    
    # Demo 7: Great Filter Threshold Test
    print("--- Demo 7: Great Filter Threshold Conjecture ---")
    print("  Can k factors all ≥ 10^{-3} have product < 10^{-10}?")
    for k in [2, 3, 4, 5]:
        result = great_filter_threshold_test(k)
        status = "HOLDS ✓" if result["conjecture_holds"] else "FAILS ✗"
        print(f"  k={k}: {result['explanation']}  [{status}]")
    print()
    print("  Conclusion: The conjecture holds for k ≤ 3 but fails for k ≥ 4.")
    print("  This means: with 4+ independent filter steps, no single step")
    print("  need be catastrophically unlikely — moderate rarity suffices.")


if __name__ == "__main__":
    main()


"""
Visualization: Civilization Detection Probability Curve

Shows the probability of detecting at least one civilization as a
function of the number of planets surveyed, for different per-planet
probabilities. Illustrates the "transition zone" from silence to contact.
"""

import numpy as np
import matplotlib.pyplot as plt

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: Detection probability vs planets surveyed
probabilities = [1e-8, 1e-9, 1e-10, 1e-11, 1e-12]
colors = ['#F44336', '#FF9800', '#4CAF50', '#2196F3', '#9C27B0']

m_values = np.logspace(0, 14, 500)

for p, color in zip(probabilities, colors):
    # P(at least one) = 1 - e^{-m*p}
    expected = m_values * p
    prob_detect = 1 - np.exp(-expected)
    ax1.semilogx(m_values, prob_detect, color=color, linewidth=2.5,
                 label=f'p = {p:.0e}')

ax1.axhline(y=0.5, color='gray', linestyle='--', alpha=0.5, linewidth=1)
ax1.axhline(y=0.95, color='gray', linestyle=':', alpha=0.5, linewidth=1)
ax1.text(2, 0.52, '50%', fontsize=10, color='gray')
ax1.text(2, 0.97, '95%', fontsize=10, color='gray')

# Mark current survey capability (~10^4 stars)
ax1.axvline(x=1e4, color='black', linestyle='--', alpha=0.3)
ax1.text(1.5e4, 0.05, 'Current\nSETI', fontsize=9, rotation=0)

ax1.set_xlabel('Number of Planets Surveyed', fontsize=13)
ax1.set_ylabel('P(at least one detection)', fontsize=13)
ax1.set_title('Detection Probability Curve', fontsize=14, fontweight='bold')
ax1.legend(fontsize=10, loc='center left')
ax1.set_ylim(-0.02, 1.02)
ax1.set_xlim(1, 1e14)
ax1.grid(True, alpha=0.3)

# Right panel: Bayesian upper bound after null result
planets_checked = np.logspace(1, 12, 200)
upper_bound = 1.0 / planets_checked
upper_bound_95 = -np.log(0.05) / planets_checked

ax2.loglog(planets_checked, upper_bound, 'b-', linewidth=2.5, label='MLE bound (1/m)')
ax2.loglog(planets_checked, upper_bound_95, 'r--', linewidth=2.5, label='95% Bayesian bound')

# Reference lines
for p, label in [(1e-8, 'Optimistic'), (1e-10, 'Moderate'), (1e-12, 'Conservative')]:
    ax2.axhline(y=p, color='gray', linestyle=':', alpha=0.4)
    ax2.text(2e12, p*1.3, label, fontsize=9, color='gray', ha='right')

ax2.set_xlabel('Planets Checked (null result)', fontsize=13)
ax2.set_ylabel('Upper Bound on p', fontsize=13)
ax2.set_title('Bayesian Silence Theorem\n"How rare must life be?"', fontsize=14, fontweight='bold')
ax2.legend(fontsize=11)
ax2.set_xlim(10, 1e12)
ax2.set_ylim(1e-14, 1)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_detection_curve.png', dpi=150, bbox_inches='tight')
print("Saved viz_detection_curve.png")


"""
Visualization: Drake Equation Expected Civilizations Heatmap

Shows how the expected number of civilizations E[N] = n × p varies
across different combinations of number of habitable planets (n)
and per-planet probability (p). The critical threshold E[N] = 1
divides the "alone" region from the "not alone" region.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as colors

# Parameter ranges (log scale)
log_n = np.linspace(8, 12, 200)  # 10^8 to 10^12 planets
log_p = np.linspace(-14, -6, 200)  # 10^-14 to 10^-6 probability

N, P = np.meshgrid(log_n, log_p)
log_E = N + P  # log10(E) = log10(n) + log10(p)

fig, ax = plt.subplots(1, 1, figsize=(10, 8))

# Heatmap
im = ax.pcolormesh(
    log_n, log_p, log_E,
    cmap='RdYlBu_r',
    shading='auto',
    vmin=-6, vmax=6
)

# Critical line: E[N] = 1 (log E = 0)
ax.contour(N, P, log_E, levels=[0], colors='white', linewidths=3, linestyles='--')
ax.contour(N, P, log_E, levels=[0], colors='black', linewidths=1.5, linestyles='--')

# Annotate regions
ax.text(9, -8, 'E[N] > 1\n"Not Alone"', fontsize=16, fontweight='bold',
        color='white', ha='center', va='center',
        bbox=dict(boxstyle='round,pad=0.3', facecolor='red', alpha=0.7))
ax.text(11, -13, 'E[N] < 1\n"Alone"', fontsize=16, fontweight='bold',
        color='black', ha='center', va='center',
        bbox=dict(boxstyle='round,pad=0.3', facecolor='lightblue', alpha=0.7))

# Mark conservative estimate
ax.plot(10, -11, 'w*', markersize=20, markeredgecolor='black', markeredgewidth=1.5)
ax.annotate('Conservative\nEstimate', xy=(10, -11), xytext=(10.5, -10),
            fontsize=11, fontweight='bold',
            arrowprops=dict(arrowstyle='->', color='black', lw=2),
            bbox=dict(boxstyle='round', facecolor='yellow', alpha=0.8))

# Labels
ax.set_xlabel('log₁₀(Number of Habitable Planets)', fontsize=14)
ax.set_ylabel('log₁₀(Per-Planet Probability)', fontsize=14)
ax.set_title('The Great Filter Dichotomy\nExpected Civilizations = n × p', fontsize=16, fontweight='bold')

cbar = fig.colorbar(im, ax=ax, label='log₁₀(Expected Civilizations)')
cbar.ax.axhline(y=0, color='black', linewidth=2, linestyle='--')
cbar.ax.text(0.5, 0, 'E=1', transform=cbar.ax.transAxes, fontsize=10,
             ha='center', va='bottom', fontweight='bold')

plt.tight_layout()
plt.savefig('viz_drake_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_drake_heatmap.png")


"""
Visualization: Tropical Bottleneck Analysis

Shows the Drake equation factors in tropical (log) space, identifying
the bottleneck factor. In tropical geometry, multiplication becomes
addition and the dominant factor (maximum in log space) is the
"Great Filter" bottleneck.
"""

import numpy as np
import matplotlib.pyplot as plt

# Drake factor scenarios
scenarios = {
    "Optimistic": {
        "Abiogenesis": 0.5,
        "Complex Life": 0.1,
        "Intelligence": 0.01,
        "Technology": 0.1,
        "Survival": 0.5,
    },
    "Moderate": {
        "Abiogenesis": 0.1,
        "Complex Life": 0.01,
        "Intelligence": 1e-3,
        "Technology": 0.01,
        "Survival": 0.1,
    },
    "Conservative": {
        "Abiogenesis": 0.01,
        "Complex Life": 1e-3,
        "Intelligence": 1e-5,
        "Technology": 1e-3,
        "Survival": 0.01,
    },
    "Pessimistic": {
        "Abiogenesis": 1e-3,
        "Complex Life": 1e-4,
        "Intelligence": 1e-7,
        "Technology": 1e-4,
        "Survival": 1e-3,
    },
}

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
axes = axes.flatten()

bar_colors = ['#2196F3', '#4CAF50', '#FF9800', '#F44336', '#9C27B0']

for idx, (scenario_name, factors) in enumerate(scenarios.items()):
    ax = axes[idx]
    names = list(factors.keys())
    probs = list(factors.values())
    strengths = [-np.log10(p) for p in probs]
    total = sum(strengths)
    bottleneck_idx = np.argmax(strengths)
    
    colors_list = [bar_colors[i] if i != bottleneck_idx else '#FF0000' for i in range(len(names))]
    
    bars = ax.barh(names, strengths, color=colors_list, edgecolor='black', linewidth=0.5)
    
    # Mark bottleneck
    ax.barh(names[bottleneck_idx], strengths[bottleneck_idx],
            color='#FF0000', edgecolor='black', linewidth=2, hatch='///')
    
    # Add value labels
    for i, (s, p) in enumerate(zip(strengths, probs)):
        ax.text(s + 0.1, i, f'{s:.1f} ({p:.0e})', va='center', fontsize=9)
    
    # Total line
    ax.axvline(x=total/len(names), color='gray', linestyle='--', alpha=0.5)
    
    ax.set_xlabel('Filter Strength (-log₁₀ p)', fontsize=11)
    ax.set_title(f'{scenario_name}\nTotal: {total:.1f} | Bottleneck: {names[bottleneck_idx]}',
                 fontsize=12, fontweight='bold')
    ax.set_xlim(0, max(strengths) * 1.5)

fig.suptitle('Tropical Bottleneck Analysis of the Great Filter\n'
             'Red hatched bar = dominant filter (tropical maximum)',
             fontsize=14, fontweight='bold', y=1.02)

plt.tight_layout()
plt.savefig('viz_tropical_bottleneck.png', dpi=150, bbox_inches='tight')
print("Saved viz_tropical_bottleneck.png")
