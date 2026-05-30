#!/usr/bin/env python3
"""
Applications of Tropical Neural Network Theory

Real-world applications demonstrating the mathematical results:
1. Network architecture selection using region bounds
2. Decision boundary complexity analysis
3. Generalization prediction from tropical structure
4. Network compression via tropical degree reduction
"""

import numpy as np
from typing import List, Tuple
from math import comb, log2


def architecture_advisor(input_dim: int, target_complexity: int,
                          max_params: int) -> dict:
    """
    Recommend network architecture based on tropical region bounds.

    Given a target number of decision boundary regions and parameter budget,
    find the optimal (depth, width) configuration.

    The key insight from the trinity theorem:
    - regions ≤ (w+1)^L (product bound)
    - parameters = input_dim * w + (L-1) * w^2 + w (for uniform width)

    Time: O(max_L * max_w)

    Args:
        input_dim: Input dimensionality
        target_complexity: Desired number of linear regions
        max_params: Maximum parameter budget

    Returns:
        Dictionary with recommended architecture and analysis
    """
    best = None
    results = []

    for L in range(1, 20):
        for w in range(1, 100):
            regions = (w + 1) ** L
            # Parameter count for uniform-width network
            params = input_dim * w + (L - 1) * w * w + w
            if params > max_params:
                break
            if regions >= target_complexity:
                efficiency = regions / params
                entry = {
                    'depth': L,
                    'width': w,
                    'regions': regions,
                    'params': params,
                    'efficiency': efficiency,
                    'tropical_degree': w ** L,
                    'vc_bound': int(w * L * log2(w + 1)) if w > 0 else 0,
                }
                results.append(entry)
                if best is None or params < best['params']:
                    best = entry

    return {
        'recommendation': best,
        'alternatives': sorted(results, key=lambda x: x['efficiency'], reverse=True)[:5]
    }


def analyze_decision_boundary(network_fn, x_range: Tuple[float, float] = (-5, 5),
                                n_points: int = 10000) -> dict:
    """
    Analyze the decision boundary of a trained 1D classifier.

    Measures:
    - Number of zero crossings (tropical Betti number β₀)
    - Number of linear regions
    - Effective tropical degree
    - Boundary curvature profile

    Time: O(n_points)

    Args:
        network_fn: Function mapping float -> float
        x_range: Range to analyze
        n_points: Resolution for analysis

    Returns:
        Dictionary with boundary analysis
    """
    xs = np.linspace(x_range[0], x_range[1], n_points)
    ys = np.array([network_fn(x) for x in xs])

    # Count zero crossings
    signs = np.sign(ys)
    sign_changes = np.sum(np.abs(np.diff(signs)) > 0)
    zero_crossings = int(sign_changes)

    # Count linear regions (slope changes)
    slopes = np.diff(ys) / np.diff(xs)
    slope_changes = np.sum(np.abs(np.diff(slopes)) > 1e-6)
    linear_regions = int(slope_changes + 1)

    # Estimate tropical degree (max number of distinct slopes)
    unique_slopes = len(set(np.round(slopes, 4)))

    return {
        'zero_crossings': zero_crossings,
        'betti_0': zero_crossings,  # β₀ = number of connected components of boundary
        'linear_regions': linear_regions,
        'tropical_degree_estimate': unique_slopes,
        'max_value': float(np.max(ys)),
        'min_value': float(np.min(ys)),
        'total_variation': float(np.sum(np.abs(np.diff(ys)))),
    }


def predict_generalization(depth: int, widths: List[int],
                            n_train: int) -> dict:
    """
    Predict generalization gap using tropical structure.

    Uses the Rademacher complexity bound:
    R_n ≤ Π(wᵢ) / √n

    And VC-based bound:
    error ≤ √(VC * log(n/VC) / n)

    Time: O(L) where L = depth

    Args:
        depth: Network depth
        widths: Layer widths
        n_train: Number of training samples

    Returns:
        Dictionary with generalization predictions
    """
    # Product of widths
    prod_widths = 1
    for w in widths:
        prod_widths *= w

    # Product region bound
    prod_regions = 1
    for w in widths:
        prod_regions *= (w + 1)

    # Total neurons
    total_neurons = sum(widths)

    # Rademacher complexity estimate
    rademacher = prod_widths / np.sqrt(n_train)

    # VC dimension estimate
    vc_dim = total_neurons  # Simple bound: VC ≤ total neurons

    # VC-based generalization bound
    if vc_dim < n_train:
        vc_bound = np.sqrt(vc_dim * np.log(n_train / vc_dim) / n_train)
    else:
        vc_bound = 1.0

    # Tropical degree
    tropical_degree = 1
    for w in widths:
        tropical_degree *= w

    return {
        'depth': depth,
        'widths': widths,
        'total_neurons': total_neurons,
        'total_params': sum(w1 * w2 for w1, w2 in zip([1] + widths, widths + [1])),
        'product_region_bound': prod_regions,
        'activation_bound': 2 ** total_neurons,
        'tropical_degree': tropical_degree,
        'vc_dimension_bound': vc_dim,
        'rademacher_complexity': rademacher,
        'vc_generalization_bound': vc_bound,
        'n_train': n_train,
        'overfit_risk': 'HIGH' if vc_dim > n_train / 10 else 'MEDIUM' if vc_dim > n_train / 100 else 'LOW',
    }


def compress_network_tropical(net_regions: int, target_regions: int) -> dict:
    """
    Recommend compression strategy based on tropical degree theory.

    If a network has more regions than needed (overparameterized),
    we can reduce depth or width to match the target complexity.

    Time: O(max_L * max_w)

    Args:
        net_regions: Current number of linear regions
        target_regions: Desired number of regions

    Returns:
        Compression recommendations
    """
    candidates = []
    for L in range(1, 15):
        for w in range(1, 50):
            regions = (w + 1) ** L
            if regions >= target_regions:
                params_proxy = L * w  # Simplified parameter proxy
                candidates.append({
                    'depth': L,
                    'width': w,
                    'regions': regions,
                    'params_proxy': params_proxy,
                    'compression_ratio': net_regions / regions,
                })
                break  # Found minimum width for this depth

    # Find most efficient
    candidates.sort(key=lambda x: x['params_proxy'])

    return {
        'original_regions': net_regions,
        'target_regions': target_regions,
        'recommended': candidates[0] if candidates else None,
        'all_options': candidates[:5],
    }


# =============================================================================
# Example Usage
# =============================================================================

if __name__ == "__main__":
    print("=" * 60)
    print("Application 1: Architecture Advisor")
    print("=" * 60)
    result = architecture_advisor(input_dim=10, target_complexity=1000, max_params=5000)
    rec = result['recommendation']
    if rec:
        print(f"  Recommended: depth={rec['depth']}, width={rec['width']}")
        print(f"  Regions: {rec['regions']}, Params: {rec['params']}")
        print(f"  Tropical degree: {rec['tropical_degree']}")
        print(f"  VC bound: {rec['vc_bound']}")
        print(f"  Efficiency (regions/param): {rec['efficiency']:.2f}")
    print("\n  Top 3 alternatives:")
    for alt in result['alternatives'][:3]:
        print(f"    L={alt['depth']}, w={alt['width']}: "
              f"regions={alt['regions']}, params={alt['params']}, "
              f"efficiency={alt['efficiency']:.2f}")

    print("\n" + "=" * 60)
    print("Application 2: Decision Boundary Analysis")
    print("=" * 60)

    # Simple network function
    def example_net(x):
        return (max(x - 1, 0) - 2 * max(-x - 0.5, 0) + max(0.5 * x + 1, 0)
                - 0.3 * max(x + 2, 0) - 0.5)

    analysis = analyze_decision_boundary(example_net)
    for key, val in analysis.items():
        print(f"  {key}: {val}")

    print("\n" + "=" * 60)
    print("Application 3: Generalization Prediction")
    print("=" * 60)
    for n_train in [100, 1000, 10000]:
        pred = predict_generalization(3, [10, 10, 10], n_train)
        print(f"  n={n_train:6d}: VC={pred['vc_dimension_bound']}, "
              f"bound={pred['vc_generalization_bound']:.4f}, "
              f"risk={pred['overfit_risk']}")

    print("\n" + "=" * 60)
    print("Application 4: Network Compression")
    print("=" * 60)
    comp = compress_network_tropical(net_regions=100000, target_regions=1000)
    print(f"  Original regions: {comp['original_regions']}")
    print(f"  Target regions: {comp['target_regions']}")
    if comp['recommended']:
        rec = comp['recommended']
        print(f"  Recommended: depth={rec['depth']}, width={rec['width']}")
        print(f"  Compression ratio: {rec['compression_ratio']:.1f}x")


#!/usr/bin/env python3
"""
Demo: Algebraic Geometry of Neural Network Decision Boundaries

Demonstrates the key theorems connecting ReLU networks to tropical geometry:
1. ReLU as tropical addition
2. Linear region counting and bounds
3. Depth-width tradeoff
4. Decision boundary structure

Usage:
    python demo.py
"""

import numpy as np
from typing import List, Tuple

# =============================================================================
# Section 1: Tropical Arithmetic
# =============================================================================

def trop_add(a: float, b: float) -> float:
    """Tropical addition: max(a, b)"""
    return max(a, b)

def trop_mul(a: float, b: float) -> float:
    """Tropical multiplication: a + b"""
    return a + b

def relu(x: float) -> float:
    """ReLU activation: max(x, 0)"""
    return max(x, 0.0)

print("=" * 60)
print("DEMO 1: ReLU as Tropical Addition")
print("=" * 60)
for x in [-3, -1, 0, 1, 3]:
    r = relu(x)
    t = trop_add(x, 0)
    print(f"  relu({x:3}) = {r:.1f}  |  trop_add({x:3}, 0) = {t:.1f}  |  Equal: {r == t}")

print("\nTropical distributivity: a ⊙ (b ⊕ c) = (a ⊙ b) ⊕ (a ⊙ c)")
for a, b, c in [(1, 2, 3), (-1, 5, -2), (0, 0, 0)]:
    lhs = trop_mul(a, trop_add(b, c))
    rhs = trop_add(trop_mul(a, b), trop_mul(a, c))
    print(f"  a={a}, b={b}, c={c}: LHS={lhs:.1f}, RHS={rhs:.1f}, Equal: {lhs == rhs}")

# =============================================================================
# Section 2: Single-Layer Network Region Counting
# =============================================================================

def count_linear_regions_1d(slopes: List[float], intercepts: List[float],
                             weights: List[float], bias: float,
                             x_range: Tuple[float, float] = (-10, 10),
                             n_points: int = 100000) -> int:
    """Count linear regions of a 1D single-layer ReLU network by detecting slope changes."""
    xs = np.linspace(x_range[0], x_range[1], n_points)
    # Evaluate network
    ys = np.zeros_like(xs)
    for s, b_i, w in zip(slopes, intercepts, weights):
        ys += w * np.maximum(s * xs + b_i, 0)
    ys += bias

    # Count slope changes
    diffs = np.diff(ys) / np.diff(xs)
    slope_changes = np.sum(np.abs(np.diff(diffs)) > 1e-6)
    return int(slope_changes + 1)

print("\n" + "=" * 60)
print("DEMO 2: Linear Region Counting")
print("=" * 60)
for w in [1, 2, 3, 5, 10]:
    np.random.seed(42)
    slopes = np.random.randn(w).tolist()
    intercepts = np.random.randn(w).tolist()
    weights = np.random.randn(w).tolist()
    regions = count_linear_regions_1d(slopes, intercepts, weights, 0.0)
    print(f"  w={w:2d} neurons: {regions:3d} regions (bound: {w+1:3d})")

# =============================================================================
# Section 3: Depth-Width Tradeoff
# =============================================================================

print("\n" + "=" * 60)
print("DEMO 3: Depth-Width Tradeoff: (w+1)^L vs L*w+1")
print("=" * 60)
print(f"  {'w':>3} {'L':>3} {'(w+1)^L':>12} {'L*w+1':>8} {'2*L*w':>8} {'Ratio':>8}")
print("  " + "-" * 48)
for w in [2, 3, 5, 10]:
    for L in [1, 2, 3, 5, 10]:
        deep = (w + 1) ** L
        shallow = L * w + 1
        linear = 2 * L * w
        ratio = deep / shallow if shallow > 0 else float('inf')
        marker = " ***" if (L >= 2 and w >= 2 and deep > linear) else ""
        print(f"  {w:3d} {L:3d} {deep:12d} {shallow:8d} {linear:8d} {ratio:8.1f}{marker}")

# =============================================================================
# Section 4: Product Bound vs Activation Bound
# =============================================================================

print("\n" + "=" * 60)
print("DEMO 4: Product Bound Π(wᵢ+1) vs Activation Bound 2^(Σwᵢ)")
print("=" * 60)
architectures = [
    [2, 2, 2],
    [3, 3],
    [5, 5, 5],
    [10, 10],
    [3, 4, 5],
]
for widths in architectures:
    product_bound = 1
    for w in widths:
        product_bound *= (w + 1)
    total = sum(widths)
    activation_bound = 2 ** total
    ratio = product_bound / activation_bound
    print(f"  widths={widths}: Π(wᵢ+1)={product_bound:>8}, 2^(Σwᵢ)={activation_bound:>8}, "
          f"ratio={ratio:.4f}")

# =============================================================================
# Section 5: Region-Degree-VC Trinity
# =============================================================================

print("\n" + "=" * 60)
print("DEMO 5: Region-Degree-VC Trinity")
print("=" * 60)
print(f"  {'w':>3} {'L':>3} {'degree w^L':>12} {'regions (w+1)^L':>16} {'activations 2^(wL)':>20}")
print("  " + "-" * 60)
for w, L in [(2, 3), (3, 2), (5, 3), (10, 2), (3, 5)]:
    degree = w ** L
    regions = (w + 1) ** L
    activations = 2 ** (w * L)
    print(f"  {w:3d} {L:3d} {degree:12d} {regions:16d} {activations:20d}")
    assert degree <= regions <= activations, "Trinity violated!"

print("\n  ✓ Trinity holds: degree ≤ regions ≤ activations for all cases")

# =============================================================================
# Section 6: Tropical Regularity Conjecture Test
# =============================================================================

print("\n" + "=" * 60)
print("DEMO 6: Tropical Regularity Conjecture Test")
print("=" * 60)

def test_regularity(w: int, n_trials: int = 10000) -> float:
    """Test what fraction of random networks achieve maximum regions."""
    max_achieved = 0
    for _ in range(n_trials):
        slopes = np.random.randn(w)
        intercepts = np.random.randn(w)
        # Breakpoints: -intercept/slope (for non-zero slopes)
        breakpoints = set()
        for s, b in zip(slopes, intercepts):
            if abs(s) > 1e-10:
                breakpoints.add(round(-b / s, 10))
        if len(breakpoints) == w:
            max_achieved += 1
    return max_achieved / n_trials

for w in [3, 5, 10, 20]:
    frac = test_regularity(w, n_trials=5000)
    status = "SUPPORTS" if frac > 0.9 else "REFUTES"
    print(f"  w={w:3d}: {frac*100:.1f}% achieve max regions  [{status} conjecture]")

# =============================================================================
# Section 7: Sauer-Shelah Bound Verification
# =============================================================================

print("\n" + "=" * 60)
print("DEMO 7: Sauer-Shelah Weak Bound: Σ C(n,i) ≤ (n+1)^d")
print("=" * 60)
from math import comb

for n, d in [(5, 2), (10, 3), (20, 5), (50, 10)]:
    if d <= n:
        partial_sum = sum(comb(n, i) for i in range(d + 1))
        bound = (n + 1) ** d
        ratio = partial_sum / bound
        print(f"  n={n:3d}, d={d:2d}: Σ C(n,i)={partial_sum:>12}, (n+1)^d={bound:>12}, ratio={ratio:.6f}")

print("\n✓ All demos completed successfully.")


#!/usr/bin/env python3
"""
Visualization 3: Tropical Regularity Conjecture Test

Tests and visualizes the conjecture that generic ReLU networks achieve
the maximum number of linear regions with probability approaching 1.

Also shows the Euler characteristic / Betti number perspective on
decision boundary complexity.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec

fig = plt.figure(figsize=(16, 10))
gs = gridspec.GridSpec(2, 2, hspace=0.4, wspace=0.3)

# --- Panel 1: Regularity conjecture test ---
ax1 = fig.add_subplot(gs[0, 0])

widths_test = [2, 3, 5, 8, 10, 15, 20]
n_trials = 5000
fractions = []

for w in widths_test:
    max_count = 0
    for _ in range(n_trials):
        slopes = np.random.randn(w)
        intercepts = np.random.randn(w)
        breakpoints = set()
        for s, b in zip(slopes, intercepts):
            if abs(s) > 1e-10:
                breakpoints.add(round(-b / s, 10))
        if len(breakpoints) == w:
            max_count += 1
    frac = max_count / n_trials
    fractions.append(frac)

ax1.bar(range(len(widths_test)), [f * 100 for f in fractions],
        color=['#2a9d8f' if f > 0.9 else '#e76f51' for f in fractions],
        edgecolor='#264653', linewidth=1.5)
ax1.axhline(90, color='red', linewidth=2, linestyle='--', alpha=0.7,
            label='Falsification threshold (90%)')
ax1.axhline(99, color='green', linewidth=1.5, linestyle=':', alpha=0.7,
            label='Prediction (>99%)')
ax1.set_xticks(range(len(widths_test)))
ax1.set_xticklabels([str(w) for w in widths_test])
ax1.set_xlabel('Network width w', fontsize=12)
ax1.set_ylabel('% achieving max regions', fontsize=12)
ax1.set_title('Tropical Regularity Conjecture Test\n(5000 trials per width)', fontsize=13, fontweight='bold')
ax1.legend(fontsize=10)
ax1.set_ylim(0, 105)

# --- Panel 2: Distribution of region counts ---
ax2 = fig.add_subplot(gs[0, 1])

w = 5
n_trials_hist = 10000
region_counts = []

for _ in range(n_trials_hist):
    slopes = np.random.randn(w) * 2
    intercepts = np.random.randn(w)
    weights = np.random.randn(w)

    x_fine = np.linspace(-10, 10, 50000)
    y = np.zeros_like(x_fine)
    for s, b, wt in zip(slopes, intercepts, weights):
        y += wt * np.maximum(s * x_fine + b, 0)

    dy = np.diff(y) / np.diff(x_fine)
    changes = np.sum(np.abs(np.diff(dy)) > 1e-4) + 1
    region_counts.append(min(changes, w + 2))

ax2.hist(region_counts, bins=range(1, w + 4), align='left',
         color='#457b9d', edgecolor='#1d3557', linewidth=1.5, alpha=0.8)
ax2.axvline(w + 1, color='red', linewidth=2, linestyle='--',
            label=f'Theoretical max = {w+1}')
ax2.set_xlabel('Number of linear regions', fontsize=12)
ax2.set_ylabel('Count', fontsize=12)
ax2.set_title(f'Region Count Distribution (w={w})\n{n_trials_hist} random networks', fontsize=13, fontweight='bold')
ax2.legend(fontsize=10)

# --- Panel 3: Betti numbers (zero crossings) vs depth ---
ax3 = fig.add_subplot(gs[1, 0])

depths = [1, 2, 3, 4, 5]
w_fixed = 3
n_samples = 500
zero_crossings_by_depth = []

for depth in depths:
    crossings = []
    for _ in range(n_samples):
        x_fine = np.linspace(-5, 5, 5000)
        y = x_fine.copy()

        for layer in range(depth):
            np.random.seed(None)
            new_y = np.zeros_like(x_fine)
            for neuron in range(w_fixed):
                a = np.random.randn()
                b = np.random.randn()
                w_out = np.random.randn()
                new_y += w_out * np.maximum(a * y + b, 0)
            y = new_y + np.random.randn() * 0.1

        sign_changes = np.sum(np.abs(np.diff(np.sign(y))) > 0)
        crossings.append(sign_changes)

    zero_crossings_by_depth.append(crossings)

bp = ax3.boxplot(zero_crossings_by_depth, positions=depths, widths=0.6,
                 patch_artist=True)
for patch, d in zip(bp['boxes'], depths):
    color_val = d / max(depths)
    patch.set_facecolor(plt.cm.YlOrRd(0.3 + 0.5 * color_val))
    patch.set_edgecolor('#264653')

theoretical_max = [(w_fixed + 1) ** d for d in depths]
ax3.plot(depths, theoretical_max, 'rs--', markersize=8, linewidth=2,
         label='Theoretical max: (w+1)^L')
ax3.set_xlabel('Network depth L', fontsize=12)
ax3.set_ylabel('Zero crossings (β₀)', fontsize=12)
ax3.set_title(f'Tropical Betti Number β₀ vs Depth\n(w={w_fixed}, {n_samples} samples)', fontsize=13, fontweight='bold')
ax3.legend(fontsize=10)
ax3.set_yscale('symlog', linthresh=1)

# --- Panel 4: Depth advantage visualization ---
ax4 = fig.add_subplot(gs[1, 1])

# For fixed total neurons, compare different depth/width splits
total_neurons_values = [6, 12, 20]
colors_main = ['#264653', '#2a9d8f', '#e76f51']

for idx, N in enumerate(total_neurons_values):
    splits = []
    regions_list = []
    labels_list = []
    for L in range(1, N + 1):
        if N % L == 0:
            w = N // L
            if w >= 1:
                regions = (w + 1) ** L
                splits.append(L)
                regions_list.append(regions)
                labels_list.append(f'L={L},w={w}')

    ax4.semilogy(splits, regions_list, 'o-', color=colors_main[idx],
                 linewidth=2, markersize=7, label=f'N={N} neurons')

ax4.set_xlabel('Depth L (width = N/L)', fontsize=12)
ax4.set_ylabel('Max regions (w+1)^L', fontsize=12)
ax4.set_title('Same Total Neurons, Different Splits\nDepth wins exponentially', fontsize=13, fontweight='bold')
ax4.legend(fontsize=10)
ax4.grid(True, alpha=0.3)

fig.suptitle('Tropical Regularity and the Power of Depth',
             fontsize=16, fontweight='bold', y=1.01)
plt.savefig('viz_regularity.png', dpi=150, bbox_inches='tight')
print("Saved viz_regularity.png")


#!/usr/bin/env python3
"""
Visualization 2: Region-Degree-VC Trinity

Shows the fundamental three-way relationship between:
- Tropical degree (algebraic complexity)
- Linear regions (geometric complexity)
- VC dimension bound (learning-theoretic complexity)

The Trinity Theorem: w^L ≤ (w+1)^L ≤ 2^(wL)
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec

fig = plt.figure(figsize=(16, 10))
gs = gridspec.GridSpec(2, 3, hspace=0.4, wspace=0.35)

# --- Panel 1: Trinity for fixed w, varying L ---
ax1 = fig.add_subplot(gs[0, 0])
w = 3
Ls = np.arange(1, 9)
degree = [w**L for L in Ls]
regions = [(w+1)**L for L in Ls]
activations = [2**(w*L) for L in Ls]

ax1.semilogy(Ls, degree, 'o-', color='#264653', linewidth=2, markersize=7, label=f'Degree: {w}^L')
ax1.semilogy(Ls, regions, 's-', color='#2a9d8f', linewidth=2, markersize=7, label=f'Regions: {w+1}^L')
ax1.semilogy(Ls, activations, '^-', color='#e76f51', linewidth=2, markersize=7, label=f'Activations: 2^({w}L)')

ax1.fill_between(Ls, degree, regions, alpha=0.1, color='#2a9d8f')
ax1.fill_between(Ls, regions, activations, alpha=0.1, color='#e76f51')

ax1.set_xlabel('Depth L', fontsize=11)
ax1.set_ylabel('Complexity', fontsize=11)
ax1.set_title(f'Trinity (w={w})\nw^L ≤ (w+1)^L ≤ 2^(wL)', fontsize=13, fontweight='bold')
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)

# --- Panel 2: Trinity for fixed L, varying w ---
ax2 = fig.add_subplot(gs[0, 1])
L = 3
ws = np.arange(1, 12)
degree = [w**L for w in ws]
regions = [(w+1)**L for w in ws]
activations = [2**(w*L) for w in ws]

ax2.semilogy(ws, degree, 'o-', color='#264653', linewidth=2, markersize=7, label=f'Degree: w^{L}')
ax2.semilogy(ws, regions, 's-', color='#2a9d8f', linewidth=2, markersize=7, label=f'Regions: (w+1)^{L}')
ax2.semilogy(ws, activations, '^-', color='#e76f51', linewidth=2, markersize=7, label=f'Activations: 2^({L}w)')

ax2.fill_between(ws, degree, regions, alpha=0.1, color='#2a9d8f')
ax2.fill_between(ws, regions, activations, alpha=0.1, color='#e76f51')

ax2.set_xlabel('Width w', fontsize=11)
ax2.set_ylabel('Complexity', fontsize=11)
ax2.set_title(f'Trinity (L={L})\nDegree ≤ Regions ≤ Activations', fontsize=13, fontweight='bold')
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

# --- Panel 3: Depth advantage heatmap ---
ax3 = fig.add_subplot(gs[0, 2])
ws_range = np.arange(1, 11)
Ls_range = np.arange(1, 11)
W, L_grid = np.meshgrid(ws_range, Ls_range)
# Ratio: (w+1)^L / (L*w+1)
ratio = np.zeros_like(W, dtype=float)
for i in range(len(Ls_range)):
    for j in range(len(ws_range)):
        w_val = ws_range[j]
        L_val = Ls_range[i]
        ratio[i, j] = np.log10((w_val + 1) ** L_val / max(L_val * w_val + 1, 1))

im = ax3.imshow(ratio, origin='lower', aspect='auto', cmap='YlOrRd',
                extent=[0.5, 10.5, 0.5, 10.5])
ax3.set_xlabel('Width w', fontsize=11)
ax3.set_ylabel('Depth L', fontsize=11)
ax3.set_title('log₁₀(Depth Advantage)\n(w+1)^L / (L·w+1)', fontsize=13, fontweight='bold')
plt.colorbar(im, ax=ax3, label='log₁₀ ratio')

# --- Panel 4: Sauer-Shelah bound ---
ax4 = fig.add_subplot(gs[1, 0])
from math import comb

for d in [2, 3, 5, 8]:
    ns = np.arange(d, 25)
    partial_sums = [sum(comb(n, i) for i in range(d + 1)) for n in ns]
    bounds = [(n + 1) ** d for n in ns]
    ratios = [ps / b for ps, b in zip(partial_sums, bounds)]
    ax4.plot(ns, ratios, 'o-', markersize=4, linewidth=2, label=f'd={d}')

ax4.set_xlabel('n (set size)', fontsize=11)
ax4.set_ylabel('Ratio: Σ C(n,i) / (n+1)^d', fontsize=11)
ax4.set_title('Sauer-Shelah Tightness\nRatio ≤ 1 (proven)', fontsize=13, fontweight='bold')
ax4.legend(fontsize=9)
ax4.axhline(1, color='red', linewidth=1, linestyle='--', alpha=0.7, label='Upper bound')
ax4.grid(True, alpha=0.3)
ax4.set_ylim(0, 1.1)

# --- Panel 5: Product bound vs activation bound ---
ax5 = fig.add_subplot(gs[1, 1])
total_neurons_range = range(3, 25)
for L in [2, 3, 5]:
    product_bounds = []
    activation_bounds = []
    neurons_list = []
    for N in total_neurons_range:
        if N % L == 0:
            w = N // L
            pb = (w + 1) ** L
            ab = 2 ** N
            product_bounds.append(pb)
            activation_bounds.append(ab)
            neurons_list.append(N)
    if neurons_list:
        ratios = [pb/ab for pb, ab in zip(product_bounds, activation_bounds)]
        ax5.plot(neurons_list, ratios, 'o-', markersize=5, linewidth=2, label=f'L={L}')

ax5.set_xlabel('Total neurons N', fontsize=11)
ax5.set_ylabel('Π(wᵢ+1) / 2^N', fontsize=11)
ax5.set_title('Product bound / Activation bound\nProduct bound is tighter', fontsize=13, fontweight='bold')
ax5.legend(fontsize=9)
ax5.grid(True, alpha=0.3)
ax5.set_yscale('log')

# --- Panel 6: Parameter efficiency ---
ax6 = fig.add_subplot(gs[1, 2])
param_budgets = [10, 20, 50, 100, 200]
for budget in param_budgets:
    depths = []
    regions_per_param = []
    for L in range(1, 15):
        w = max(1, budget // L)
        if L * w <= budget:
            regions = (w + 1) ** L
            depths.append(L)
            regions_per_param.append(regions / budget)
    if depths:
        ax6.semilogy(depths, regions_per_param, 'o-', markersize=5, linewidth=2,
                     label=f'Budget={budget}')

ax6.set_xlabel('Depth L', fontsize=11)
ax6.set_ylabel('Regions per parameter', fontsize=11)
ax6.set_title('Parameter Efficiency\nDeeper = more efficient', fontsize=13, fontweight='bold')
ax6.legend(fontsize=9)
ax6.grid(True, alpha=0.3)

fig.suptitle('The Region-Degree-VC Trinity of Neural Networks',
             fontsize=16, fontweight='bold', y=1.01)
plt.savefig('viz_trinity.png', dpi=150, bbox_inches='tight')
print("Saved viz_trinity.png")


#!/usr/bin/env python3
"""
Visualization 1: ReLU as Tropical Addition and Decision Boundary Structure

Shows how ReLU(x) = max(x, 0) is the fundamental tropical operation,
and how composing ReLU neurons creates piecewise linear decision boundaries
with increasing complexity.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec

fig = plt.figure(figsize=(16, 12))
gs = gridspec.GridSpec(2, 2, hspace=0.35, wspace=0.3)

# --- Panel 1: ReLU = Tropical Addition ---
ax1 = fig.add_subplot(gs[0, 0])
x = np.linspace(-3, 3, 500)
relu_vals = np.maximum(x, 0)
ax1.plot(x, x, '--', color='#888', alpha=0.5, label='y = x')
ax1.axhline(0, color='#888', alpha=0.5, linestyle='--')
ax1.plot(x, relu_vals, color='#e63946', linewidth=3, label='ReLU(x) = max(x, 0)')
ax1.fill_between(x, relu_vals, alpha=0.1, color='#e63946')
ax1.axvline(0, color='#457b9d', linewidth=2, linestyle=':', alpha=0.8, label='Tropical root at x=0')
ax1.set_xlabel('x', fontsize=12)
ax1.set_ylabel('y', fontsize=12)
ax1.set_title('ReLU = Tropical Addition\nmax(x, 0) = x ⊕ 0', fontsize=14, fontweight='bold')
ax1.legend(fontsize=10)
ax1.set_xlim(-3, 3)
ax1.set_ylim(-1, 3)

# --- Panel 2: Single-Layer Network with Increasing Width ---
ax2 = fig.add_subplot(gs[0, 1])
x = np.linspace(-3, 3, 1000)

widths = [1, 2, 3, 5]
colors = ['#264653', '#2a9d8f', '#e9c46a', '#e76f51']

for idx, w in enumerate(widths):
    np.random.seed(42 + idx)
    slopes = np.random.randn(w) * 2
    intercepts = np.random.randn(w)
    weights = np.random.randn(w)
    y = np.zeros_like(x) + 0.5
    for s, b, wt in zip(slopes, intercepts, weights):
        y += wt * np.maximum(s * x + b, 0)
    ax2.plot(x, y, color=colors[idx], linewidth=2, label=f'w={w} ({w+1} regions max)')

ax2.axhline(0, color='gray', linewidth=1, linestyle='--', alpha=0.5)
ax2.set_xlabel('x', fontsize=12)
ax2.set_ylabel('f(x)', fontsize=12)
ax2.set_title('Single-Layer Networks\nMore neurons → more linear regions', fontsize=14, fontweight='bold')
ax2.legend(fontsize=10)
ax2.set_ylim(-5, 8)

# --- Panel 3: Depth-Width Tradeoff ---
ax3 = fig.add_subplot(gs[1, 0])
Ls = np.arange(1, 8)
for w in [2, 3, 5]:
    deep = [(w + 1) ** L for L in Ls]
    shallow = [L * w + 1 for L in Ls]
    ax3.semilogy(Ls, deep, 'o-', linewidth=2, markersize=6, label=f'(w+1)^L, w={w}')
    ax3.semilogy(Ls, shallow, 's--', linewidth=1.5, markersize=5, alpha=0.6,
                 label=f'L·w+1, w={w}')

ax3.set_xlabel('Depth L', fontsize=12)
ax3.set_ylabel('Max linear regions', fontsize=12)
ax3.set_title('Depth-Width Tradeoff\n(w+1)^L ≥ L·w + 1 (Theorem)', fontsize=14, fontweight='bold')
ax3.legend(fontsize=9, ncol=2)
ax3.grid(True, alpha=0.3)

# --- Panel 4: Decision Boundary of Multi-Neuron Network ---
ax4 = fig.add_subplot(gs[1, 1])
x = np.linspace(-4, 4, 2000)

# Network with 5 neurons
np.random.seed(123)
y = -0.3
for _ in range(5):
    a = np.random.randn() * 1.5
    b = np.random.randn() * 2
    w = np.random.randn()
    y = y + w * np.maximum(a * x + b, 0)

ax4.fill_between(x, y, 0, where=(y > 0), alpha=0.2, color='#2a9d8f', label='f(x) > 0 (class +)')
ax4.fill_between(x, y, 0, where=(y <= 0), alpha=0.2, color='#e76f51', label='f(x) ≤ 0 (class −)')
ax4.plot(x, y, color='#1d3557', linewidth=2)
ax4.axhline(0, color='gray', linewidth=1, linestyle='--')

# Mark decision boundary points
sign_changes = np.where(np.diff(np.sign(y)))[0]
for idx in sign_changes:
    # Linear interpolation for exact crossing
    x0 = x[idx] - y[idx] * (x[idx+1] - x[idx]) / (y[idx+1] - y[idx])
    ax4.plot(x0, 0, 'ko', markersize=10, zorder=5)
    ax4.annotate(f'x≈{x0:.2f}', (x0, 0), textcoords="offset points",
                xytext=(0, 15), ha='center', fontsize=9, fontweight='bold')

ax4.set_xlabel('x', fontsize=12)
ax4.set_ylabel('f(x)', fontsize=12)
ax4.set_title(f'Decision Boundary ({len(sign_changes)} zero crossings)\nβ₀ = tropical Betti number', fontsize=14, fontweight='bold')
ax4.legend(fontsize=10, loc='upper left')
ax4.set_ylim(min(y) - 1, max(y) + 1)

fig.suptitle('Algebraic Geometry of Neural Network Decision Boundaries',
             fontsize=16, fontweight='bold', y=1.02)
plt.savefig('viz_tropical_relu.png', dpi=150, bbox_inches='tight')
print("Saved viz_tropical_relu.png")
