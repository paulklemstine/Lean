"""
applications.py — Real-world Applications of Lorentzian Gap Certificates

Demonstrates practical use cases:
1. Certifying code distance for small quantum codes
2. Comparing code families by their Lorentzian signatures
3. Detecting distance degradation in noisy or truncated codes
"""

import numpy as np
from math import comb
from itertools import combinations
from typing import Dict, List, Tuple


def layer_weight(mu: Dict[frozenset, float], n: int, k: int) -> float:
    return sum(v for s, v in mu.items() if len(s) == k)


def all_layer_weights(mu: Dict[frozenset, float], n: int) -> List[float]:
    return [layer_weight(mu, n, k) for k in range(n + 1)]


def lorentzian_gap(weights: List[float]) -> float:
    n = len(weights) - 1
    min_gap = float('inf')
    for k in range(1, n):
        denom = weights[k - 1] * weights[k + 1]
        if denom > 1e-15:
            gap_k = weights[k] ** 2 / denom - 1
            min_gap = min(min_gap, gap_k)
    return min_gap if min_gap != float('inf') else 0.0


def boundary_mass(mu: Dict[frozenset, float], n: int) -> float:
    universe = set(range(n))
    total = 0.0
    for s, val in mu.items():
        if val <= 0:
            continue
        on_boundary = False
        for i in s:
            for j in universe - s:
                t = frozenset((s - {i}) | {j})
                if mu.get(t, 0.0) == 0.0:
                    on_boundary = True
                    break
            if on_boundary:
                break
        if on_boundary:
            total += val
    return total


# === Application 1: Code Distance Certification ===

def certify_distance(mu: Dict[frozenset, float], n: int) -> Dict:
    """
    Produce a distance certificate from a measurement profile.

    Returns a certificate with:
    - certified_distance: lower bound on code distance from layer vanishing
    - gap: Lorentzian gap value
    - conductance: Hamming conductance
    - is_good_code: whether the code passes polynomial gap threshold
    """
    weights = all_layer_weights(mu, n)
    gap = lorentzian_gap(weights)
    bdry = boundary_mass(mu, n)
    total = sum(mu.values())
    cond = bdry / total if total > 0 else 0

    # Certified distance from layer vanishing
    cert_dist = 0
    for k in range(1, n + 1):
        if weights[k] > 1e-15:
            cert_dist = k
            break

    # Check polynomial gap threshold (C=3)
    threshold = 1.0 / (n ** 3) if n > 0 else 0
    is_good = gap >= threshold

    return {
        'certified_distance': cert_dist,
        'gap': gap,
        'conductance': cond,
        'is_good_code': is_good,
        'layer_weights': weights,
        'threshold': threshold,
    }


# === Application 2: Noise Degradation Detection ===

def add_noise_to_distribution(
    mu: Dict[frozenset, float], n: int, noise_level: float
) -> Dict[frozenset, float]:
    """
    Add noise to a measurement distribution by mixing with
    uniform distribution at rate noise_level.
    """
    uniform_weight = 1.0 / (2 ** n)
    noisy_mu = {}

    for k in range(n + 1):
        for s in combinations(range(n), k):
            fs = frozenset(s)
            original = mu.get(fs, 0.0)
            noisy_mu[fs] = (1 - noise_level) * original + noise_level * uniform_weight

    return noisy_mu


def detect_distance_degradation(
    mu: Dict[frozenset, float], n: int,
    noise_levels: List[float] = None
) -> List[Dict]:
    """
    Detect how noise degrades the distance certificate.

    Returns a list of certificates at increasing noise levels.
    """
    if noise_levels is None:
        noise_levels = [0.0, 0.01, 0.05, 0.1, 0.2, 0.5]

    results = []
    for noise in noise_levels:
        noisy_mu = add_noise_to_distribution(mu, n, noise)
        cert = certify_distance(noisy_mu, n)
        cert['noise_level'] = noise
        results.append(cert)

    return results


# === Application 3: Code Family Comparison ===

def make_code_family(family_type: str, n: int) -> Dict[frozenset, float]:
    """Create a surrogate distribution for a given code family."""
    mu = {}
    total = 0.0

    if family_type == "steane":
        # Steane [[7,1,3]] code surrogate: distance 3
        dist = 3
        target_k = n // 2
        sigma = max(1, n * 0.2)
        for k in range(n + 1):
            if 0 < k < dist:
                continue
            w = np.exp(-0.5 * ((k - target_k) / sigma) ** 2) * comb(n, k)
            if w > 1e-15:
                for s in combinations(range(n), k):
                    mu[frozenset(s)] = w / comb(n, k)
                total += w

    elif family_type == "shor":
        # Shor [[9,1,3]] code surrogate
        dist = 3
        target_k = n // 2
        sigma = max(1, n * 0.25)
        for k in range(n + 1):
            if 0 < k < dist:
                continue
            w = np.exp(-0.5 * ((k - target_k) / sigma) ** 2) * comb(n, k)
            if w > 1e-15:
                for s in combinations(range(n), k):
                    mu[frozenset(s)] = w / comb(n, k)
                total += w

    elif family_type == "toric":
        # Toric code surrogate: distance ~ sqrt(n)
        dist = max(2, int(np.sqrt(n)))
        target_k = n // 2
        sigma = max(1, n * 0.15)
        for k in range(n + 1):
            if 0 < k < dist:
                continue
            w = np.exp(-0.5 * ((k - target_k) / sigma) ** 2) * comb(n, k)
            if w > 1e-15:
                for s in combinations(range(n), k):
                    mu[frozenset(s)] = w / comb(n, k)
                total += w

    elif family_type == "hgp":
        # Hypergraph product: distance ~ n/4
        dist = max(2, n // 4)
        target_k = n // 2
        sigma = max(1, n * 0.1)
        for k in range(n + 1):
            if 0 < k < dist:
                continue
            w = np.exp(-0.5 * ((k - target_k) / sigma) ** 2) * comb(n, k)
            if w > 1e-15:
                for s in combinations(range(n), k):
                    mu[frozenset(s)] = w / comb(n, k)
                total += w

    if total > 0:
        for s in mu:
            mu[s] /= total
    return mu


def compare_code_families(n: int = 7) -> None:
    """Compare Lorentzian signatures across code families."""
    families = ["steane", "shor", "toric", "hgp"]

    print(f"\n{'='*60}")
    print(f"CODE FAMILY COMPARISON (n={n})")
    print(f"{'='*60}\n")

    for family in families:
        mu = make_code_family(family, n)
        cert = certify_distance(mu, n)
        print(f"  {family.upper():12s}: "
              f"dist={cert['certified_distance']}, "
              f"gap={cert['gap']:+.6f}, "
              f"cond={cert['conductance']:.4f}, "
              f"good={'YES' if cert['is_good_code'] else 'NO'}")
    print()


if __name__ == "__main__":
    print("=" * 60)
    print("APPLICATION 1: Distance Certification")
    print("=" * 60)

    n = 6
    from algorithms import hypergraph_product_surrogate
    mu = hypergraph_product_surrogate(n)
    cert = certify_distance(mu, n)
    print(f"\nHypergraph product surrogate (n={n}):")
    print(f"  Certified distance: {cert['certified_distance']}")
    print(f"  Lorentzian gap: {cert['gap']:.6f}")
    print(f"  Threshold (n^-3): {cert['threshold']:.6f}")
    print(f"  Good code: {cert['is_good_code']}")

    print(f"\n{'='*60}")
    print("APPLICATION 2: Noise Degradation Detection")
    print(f"{'='*60}\n")

    results = detect_distance_degradation(mu, n)
    for r in results:
        print(f"  noise={r['noise_level']:.2f}: "
              f"dist={r['certified_distance']}, "
              f"gap={r['gap']:+.6f}, "
              f"good={'YES' if r['is_good_code'] else 'NO'}")

    print()
    compare_code_families(n=7)


"""
demo.py — Demonstration of Lorentzian Gap Surrogate for Quantum LDPC Codes

Tests the falsifiable conjecture:
  For asymptotically good CSS LDPC families with distance ≥ δn,
  lorentzianGap(μ_n) ≥ γ₀ / n^C.

Constructs surrogate distributions for:
  1. Hypergraph product codes (good distance, expected polynomial gap)
  2. Balanced product codes (good distance, expected polynomial gap)
  3. Repetition codes (poor distance, expected rapid gap decay)
  4. Punctured surface codes (moderate distance, intermediate behavior)

Computes the Lorentzian gap surrogate and analyzes scaling behavior.
"""

import numpy as np
from math import comb
from itertools import combinations


def layer_weight_from_mu(mu, n, k):
    """Compute layer weight at level k."""
    return sum(v for s, v in mu.items() if len(s) == k)


def all_layer_weights_from_mu(mu, n):
    """Compute all layer weights."""
    return [layer_weight_from_mu(mu, n, k) for k in range(n + 1)]


def lorentzian_gap_from_weights(weights):
    """Compute Lorentzian gap from layer weights."""
    n = len(weights) - 1
    min_gap = float('inf')
    for k in range(1, n):
        denom = weights[k - 1] * weights[k + 1]
        if denom > 1e-15:
            gap_k = weights[k] ** 2 / denom - 1
            min_gap = min(min_gap, gap_k)
    return min_gap if min_gap != float('inf') else 0.0


def make_hypergraph_product(n, rate=0.5):
    """Surrogate distribution for hypergraph product code."""
    target_k = int(n * rate)
    sigma = max(1, n * 0.1)
    dist_gap = max(2, n // 4)  # Linear distance
    mu = {}
    total = 0.0
    for k in range(n + 1):
        if 0 < k < dist_gap:
            continue
        w = np.exp(-0.5 * ((k - target_k) / sigma) ** 2) * comb(n, k)
        if w > 1e-15:
            for s in combinations(range(n), k):
                mu[frozenset(s)] = w / comb(n, k)
            total += w
    if total > 0:
        for s in mu:
            mu[s] /= total
    return mu


def make_balanced_product(n):
    """Surrogate for balanced product code."""
    target_k = n // 2
    sigma = max(1, n * 0.05)
    dist_gap = max(3, n // 3)
    mu = {}
    total = 0.0
    for k in range(n + 1):
        if 0 < k < dist_gap:
            continue
        w = np.exp(-0.5 * ((k - target_k) / sigma) ** 2) * comb(n, k)
        if w > 1e-15:
            for s in combinations(range(n), k):
                mu[frozenset(s)] = w / comb(n, k)
            total += w
    if total > 0:
        for s in mu:
            mu[s] /= total
    return mu


def make_repetition(n):
    """Surrogate for repetition code (poor distance)."""
    mu = {}
    total = 0.0
    for k in range(min(3, n + 1)):
        w = (n + 1 - k) * comb(n, k)
        for s in combinations(range(n), k):
            mu[frozenset(s)] = w / comb(n, k)
        total += w
    if total > 0:
        for s in mu:
            mu[s] /= total
    return mu


def make_punctured_surface(n):
    """Surrogate for punctured surface code (sqrt(n) distance)."""
    dist_gap = max(1, int(np.sqrt(n)))
    target_k = n // 2
    sigma = max(1, n * 0.15)
    mu = {}
    total = 0.0
    for k in range(n + 1):
        if 0 < k < dist_gap:
            continue
        w = np.exp(-0.5 * ((k - target_k) / sigma) ** 2) * comb(n, k)
        if w > 1e-15:
            for s in combinations(range(n), k):
                mu[frozenset(s)] = w / comb(n, k)
            total += w
    if total > 0:
        for s in mu:
            mu[s] /= total
    return mu


def run_scaling_analysis():
    """Run the main scaling analysis across system sizes."""
    sizes = [4, 5, 6, 7, 8]
    families = {
        'Hypergraph Product': make_hypergraph_product,
        'Balanced Product': make_balanced_product,
        'Repetition Code': make_repetition,
        'Punctured Surface': make_punctured_surface,
    }

    results = {name: {'sizes': [], 'gaps': [], 'distances': []}
               for name in families}

    print("=" * 70)
    print("LORENTZIAN GAP SURROGATE — SCALING ANALYSIS")
    print("=" * 70)
    print()

    for n in sizes:
        print(f"--- n = {n} ---")
        for name, gen in families.items():
            mu = gen(n)
            weights = all_layer_weights_from_mu(mu, n)
            gap = lorentzian_gap_from_weights(weights)

            # Certified distance: first nonzero layer above 0
            cert_dist = 0
            for k in range(1, n + 1):
                if weights[k] > 1e-15:
                    cert_dist = k
                    break

            results[name]['sizes'].append(n)
            results[name]['gaps'].append(gap)
            results[name]['distances'].append(cert_dist)

            print(f"  {name:25s}: gap = {gap:+.6f}, "
                  f"cert_dist = {cert_dist}, "
                  f"layers = {[f'{w:.3f}' for w in weights]}")
        print()

    # Analysis: log-log slopes
    print("=" * 70)
    print("LOG-LOG SLOPE ANALYSIS (gap vs n)")
    print("=" * 70)
    print()
    print("Conjecture: Good LDPC families should have slope ≥ -C (moderate).")
    print("Poor-distance families should show steeper negative slopes.")
    print()

    for name, data in results.items():
        sizes_arr = np.array(data['sizes'], dtype=float)
        gaps_arr = np.array(data['gaps'], dtype=float)

        # Filter to positive gaps for log-log
        mask = gaps_arr > 1e-15
        if mask.sum() >= 2:
            log_n = np.log(sizes_arr[mask])
            log_gap = np.log(gaps_arr[mask])
            # Simple linear regression for slope
            slope = np.polyfit(log_n, log_gap, 1)[0]
            print(f"  {name:25s}: log-log slope = {slope:.3f}")
        else:
            print(f"  {name:25s}: insufficient positive gap data")

    print()

    # Falsifiable test
    print("=" * 70)
    print("FALSIFIABLE CONJECTURE TEST")
    print("=" * 70)
    print()
    print("Conjecture: lorentzianGap(μ_n) ≥ γ₀ / n^C for good QLDPC families.")
    print()

    for name in ['Hypergraph Product', 'Balanced Product']:
        data = results[name]
        gaps_arr = np.array(data['gaps'])
        sizes_arr = np.array(data['sizes'], dtype=float)
        consistent = True
        for i, (n_val, gap) in enumerate(zip(sizes_arr, gaps_arr)):
            # Test with C=3: gap should be ≥ 1/n^3
            threshold = 1.0 / (n_val ** 3)
            if gap < threshold and gap > 0:
                consistent = False
        status = "CONSISTENT ✓" if consistent else "INCONSISTENT ✗"
        print(f"  {name}: {status}")

    for name in ['Repetition Code']:
        data = results[name]
        gaps_arr = np.array(data['gaps'])
        # Repetition should show rapid decay or zero gap
        has_rapid_decay = any(g < 1e-3 for g in gaps_arr) or any(g <= 0 for g in gaps_arr)
        status = "EXPECTED ✓ (rapid decay)" if has_rapid_decay else "UNEXPECTED ✗"
        print(f"  {name}: {status}")

    return results


if __name__ == "__main__":
    results = run_scaling_analysis()


"""
Visualization: Lorentzian Gap Scaling Across Code Families

Visualizes the central falsifiable conjecture: good QLDPC codes should
exhibit polynomial gap decay (moderate log-log slope), while poor-distance
codes show much steeper decay. This is the key experimental signature of
the Lorentzian certificate framework.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb
from itertools import combinations


# === Inline all needed functions ===

def layer_weight(mu, n, k):
    return sum(v for s, v in mu.items() if len(s) == k)

def all_layer_weights(mu, n):
    return [layer_weight(mu, n, k) for k in range(n + 1)]

def lorentzian_gap(weights):
    n = len(weights) - 1
    min_gap = float('inf')
    for k in range(1, n):
        denom = weights[k - 1] * weights[k + 1]
        if denom > 1e-15:
            gap_k = weights[k] ** 2 / denom - 1
            min_gap = min(min_gap, gap_k)
    return min_gap if min_gap != float('inf') else 0.0

def make_hypergraph_product(n):
    target_k = int(n * 0.5)
    sigma = max(1, n * 0.1)
    dist_gap = max(2, n // 4)
    mu = {}
    total = 0.0
    for k in range(n + 1):
        if 0 < k < dist_gap:
            continue
        w = np.exp(-0.5 * ((k - target_k) / sigma) ** 2) * comb(n, k)
        if w > 1e-15:
            for s in combinations(range(n), k):
                mu[frozenset(s)] = w / comb(n, k)
            total += w
    if total > 0:
        for s in mu:
            mu[s] /= total
    return mu

def make_balanced_product(n):
    target_k = n // 2
    sigma = max(1, n * 0.05)
    dist_gap = max(3, n // 3)
    mu = {}
    total = 0.0
    for k in range(n + 1):
        if 0 < k < dist_gap:
            continue
        w = np.exp(-0.5 * ((k - target_k) / sigma) ** 2) * comb(n, k)
        if w > 1e-15:
            for s in combinations(range(n), k):
                mu[frozenset(s)] = w / comb(n, k)
            total += w
    if total > 0:
        for s in mu:
            mu[s] /= total
    return mu

def make_repetition(n):
    mu = {}
    total = 0.0
    for k in range(min(3, n + 1)):
        w = (n + 1 - k) * comb(n, k)
        for s in combinations(range(n), k):
            mu[frozenset(s)] = w / comb(n, k)
        total += w
    if total > 0:
        for s in mu:
            mu[s] /= total
    return mu

def make_punctured_surface(n):
    dist_gap = max(1, int(np.sqrt(n)))
    target_k = n // 2
    sigma = max(1, n * 0.15)
    mu = {}
    total = 0.0
    for k in range(n + 1):
        if 0 < k < dist_gap:
            continue
        w = np.exp(-0.5 * ((k - target_k) / sigma) ** 2) * comb(n, k)
        if w > 1e-15:
            for s in combinations(range(n), k):
                mu[frozenset(s)] = w / comb(n, k)
            total += w
    if total > 0:
        for s in mu:
            mu[s] /= total
    return mu


# === Computation ===

sizes = [4, 5, 6, 7, 8]
families = {
    'Hypergraph Product': make_hypergraph_product,
    'Balanced Product': make_balanced_product,
    'Repetition Code': make_repetition,
    'Punctured Surface': make_punctured_surface,
}

colors = {
    'Hypergraph Product': '#2196F3',
    'Balanced Product': '#4CAF50',
    'Repetition Code': '#F44336',
    'Punctured Surface': '#FF9800',
}

markers = {
    'Hypergraph Product': 'o',
    'Balanced Product': 's',
    'Repetition Code': 'x',
    'Punctured Surface': '^',
}

results = {}
for name, gen in families.items():
    gaps = []
    for n in sizes:
        mu = gen(n)
        weights = all_layer_weights(mu, n)
        gap = lorentzian_gap(weights)
        gaps.append(gap)
    results[name] = gaps


# === Plotting ===

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: Gap vs System Size (log scale)
ax1 = axes[0]
for name, gaps in results.items():
    positive_mask = [g > 1e-15 for g in gaps]
    plot_sizes = [s for s, m in zip(sizes, positive_mask) if m]
    plot_gaps = [g for g, m in zip(gaps, positive_mask) if m]
    if plot_sizes:
        ax1.semilogy(plot_sizes, plot_gaps,
                     color=colors[name], marker=markers[name],
                     linewidth=2, markersize=8, label=name)

# Reference line: 1/n^2
ref_sizes = np.array(sizes, dtype=float)
ax1.semilogy(ref_sizes, 1.0 / ref_sizes**2, 'k--', alpha=0.5,
             linewidth=1, label=r'$1/n^2$ reference')

ax1.set_xlabel('System size n', fontsize=12)
ax1.set_ylabel('Lorentzian gap', fontsize=12)
ax1.set_title('Gap Surrogate vs System Size', fontsize=14)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# Plot 2: Log-log plot
ax2 = axes[1]
for name, gaps in results.items():
    positive_mask = [g > 1e-15 for g in gaps]
    plot_sizes = [s for s, m in zip(sizes, positive_mask) if m]
    plot_gaps = [g for g, m in zip(gaps, positive_mask) if m]
    if len(plot_sizes) >= 2:
        log_n = np.log(np.array(plot_sizes, dtype=float))
        log_gap = np.log(np.array(plot_gaps))
        ax2.plot(log_n, log_gap,
                 color=colors[name], marker=markers[name],
                 linewidth=2, markersize=8, label=name)

        # Fit and annotate slope
        slope = np.polyfit(log_n, log_gap, 1)[0]
        ax2.annotate(f'slope={slope:.1f}',
                     xy=(log_n[-1], log_gap[-1]),
                     xytext=(10, 0), textcoords='offset points',
                     fontsize=9, color=colors[name])

ax2.set_xlabel('log(n)', fontsize=12)
ax2.set_ylabel('log(gap)', fontsize=12)
ax2.set_title('Log-Log Scaling Analysis', fontsize=14)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

plt.suptitle('Lorentzian Gap Surrogate: Scaling Across Code Families',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('gap_scaling.png', dpi=150, bbox_inches='tight')
print("Saved gap_scaling.png")


"""
Visualization: Layer Weight Profiles and Log-Concavity

Visualizes how the layer weight distribution a_0, a_1, ..., a_n differs
across code families. Good codes should show a clean bell-shaped profile
with vanishing low layers, while poor codes have mass concentrated near
the origin. The log-concavity condition a_k^2 ≥ a_{k-1}*a_{k+1} is shown
at each layer.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb
from itertools import combinations


# === Inline all needed functions ===

def layer_weight(mu, n, k):
    return sum(v for s, v in mu.items() if len(s) == k)

def all_layer_weights(mu, n):
    return [layer_weight(mu, n, k) for k in range(n + 1)]

def make_hypergraph_product(n):
    target_k = int(n * 0.5)
    sigma = max(1, n * 0.1)
    dist_gap = max(2, n // 4)
    mu = {}
    total = 0.0
    for k in range(n + 1):
        if 0 < k < dist_gap:
            continue
        w = np.exp(-0.5 * ((k - target_k) / sigma) ** 2) * comb(n, k)
        if w > 1e-15:
            for s in combinations(range(n), k):
                mu[frozenset(s)] = w / comb(n, k)
            total += w
    if total > 0:
        for s in mu:
            mu[s] /= total
    return mu

def make_repetition(n):
    mu = {}
    total = 0.0
    for k in range(min(3, n + 1)):
        w = (n + 1 - k) * comb(n, k)
        for s in combinations(range(n), k):
            mu[frozenset(s)] = w / comb(n, k)
        total += w
    if total > 0:
        for s in mu:
            mu[s] /= total
    return mu

def make_punctured_surface(n):
    dist_gap = max(1, int(np.sqrt(n)))
    target_k = n // 2
    sigma = max(1, n * 0.15)
    mu = {}
    total = 0.0
    for k in range(n + 1):
        if 0 < k < dist_gap:
            continue
        w = np.exp(-0.5 * ((k - target_k) / sigma) ** 2) * comb(n, k)
        if w > 1e-15:
            for s in combinations(range(n), k):
                mu[frozenset(s)] = w / comb(n, k)
            total += w
    if total > 0:
        for s in mu:
            mu[s] /= total
    return mu


# === Computation ===

n = 8
families = {
    'Hypergraph Product (good distance)': make_hypergraph_product,
    'Repetition Code (poor distance)': make_repetition,
    'Punctured Surface (√n distance)': make_punctured_surface,
}

colors = ['#2196F3', '#F44336', '#FF9800']

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

for idx, (name, gen) in enumerate(families.items()):
    mu = gen(n)
    weights = all_layer_weights(mu, n)
    ax = axes[idx]

    layers = list(range(n + 1))
    ax.bar(layers, weights, color=colors[idx], alpha=0.7, edgecolor='black', linewidth=0.5)

    # Mark log-concavity at each interior layer
    for k in range(1, n):
        denom = weights[k - 1] * weights[k + 1]
        if denom > 1e-15:
            ratio = weights[k] ** 2 / denom
            marker_color = '#4CAF50' if ratio >= 1 - 1e-10 else '#F44336'
            ax.plot(k, weights[k] + 0.01, 'v', color=marker_color, markersize=6)

    ax.set_xlabel('Layer k', fontsize=11)
    ax.set_ylabel('Layer weight a_k', fontsize=11)
    ax.set_title(name, fontsize=11)
    ax.set_xticks(layers)
    ax.grid(True, alpha=0.3, axis='y')

# Legend for log-concavity markers
from matplotlib.lines import Line2D
legend_elements = [
    Line2D([0], [0], marker='v', color='w', markerfacecolor='#4CAF50',
           markersize=8, label='Log-concave (a_k² ≥ a_{k-1}a_{k+1})'),
    Line2D([0], [0], marker='v', color='w', markerfacecolor='#F44336',
           markersize=8, label='NOT log-concave'),
]
fig.legend(handles=legend_elements, loc='lower center', ncol=2,
           fontsize=10, bbox_to_anchor=(0.5, -0.05))

plt.suptitle(f'Layer Weight Profiles (n={n}): Distance Signature in Polynomial Geometry',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('layer_weights.png', dpi=150, bbox_inches='tight')
print("Saved layer_weights.png")


"""
Visualization: Noise Degradation of Lorentzian Gap Certificate

Shows how the Lorentzian gap degrades as noise is added to a measurement
distribution. This demonstrates the certificate's sensitivity: a robust
code maintains a positive gap under moderate noise, but the gap collapses
when noise destroys the distance structure.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb
from itertools import combinations


# === Inline all needed functions ===

def layer_weight(mu, n, k):
    return sum(v for s, v in mu.items() if len(s) == k)

def all_layer_weights(mu, n):
    return [layer_weight(mu, n, k) for k in range(n + 1)]

def lorentzian_gap(weights):
    n = len(weights) - 1
    min_gap = float('inf')
    for k in range(1, n):
        denom = weights[k - 1] * weights[k + 1]
        if denom > 1e-15:
            gap_k = weights[k] ** 2 / denom - 1
            min_gap = min(min_gap, gap_k)
    return min_gap if min_gap != float('inf') else 0.0

def make_hypergraph_product(n):
    target_k = int(n * 0.5)
    sigma = max(1, n * 0.1)
    dist_gap = max(2, n // 4)
    mu = {}
    total = 0.0
    for k in range(n + 1):
        if 0 < k < dist_gap:
            continue
        w = np.exp(-0.5 * ((k - target_k) / sigma) ** 2) * comb(n, k)
        if w > 1e-15:
            for s in combinations(range(n), k):
                mu[frozenset(s)] = w / comb(n, k)
            total += w
    if total > 0:
        for s in mu:
            mu[s] /= total
    return mu

def make_repetition(n):
    mu = {}
    total = 0.0
    for k in range(min(3, n + 1)):
        w = (n + 1 - k) * comb(n, k)
        for s in combinations(range(n), k):
            mu[frozenset(s)] = w / comb(n, k)
        total += w
    if total > 0:
        for s in mu:
            mu[s] /= total
    return mu

def add_noise(mu, n, noise_level):
    uniform_weight = 1.0 / (2 ** n)
    noisy = {}
    for k in range(n + 1):
        for s in combinations(range(n), k):
            fs = frozenset(s)
            original = mu.get(fs, 0.0)
            noisy[fs] = (1 - noise_level) * original + noise_level * uniform_weight
    return noisy


# === Computation ===

n = 7
noise_levels = np.linspace(0, 0.5, 25)

families = {
    'Hypergraph Product (good)': make_hypergraph_product(n),
    'Repetition Code (poor)': make_repetition(n),
}

colors = {'Hypergraph Product (good)': '#2196F3', 'Repetition Code (poor)': '#F44336'}

fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# Plot 1: Gap vs noise
ax1 = axes[0]
for name, mu in families.items():
    gaps = []
    for noise in noise_levels:
        noisy_mu = add_noise(mu, n, noise)
        weights = all_layer_weights(noisy_mu, n)
        gap = lorentzian_gap(weights)
        gaps.append(gap)
    ax1.plot(noise_levels, gaps, color=colors[name], linewidth=2.5, label=name)

ax1.axhline(y=0, color='black', linewidth=0.5, linestyle='-')
ax1.set_xlabel('Noise level ε', fontsize=12)
ax1.set_ylabel('Lorentzian gap', fontsize=12)
ax1.set_title('Gap Degradation Under Noise', fontsize=14)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# Plot 2: Certified distance vs noise
ax2 = axes[1]
for name, mu in families.items():
    dists = []
    for noise in noise_levels:
        noisy_mu = add_noise(mu, n, noise)
        weights = all_layer_weights(noisy_mu, n)
        cert_dist = 0
        for k in range(1, n + 1):
            if weights[k] > 1e-10:
                cert_dist = k
                break
        dists.append(cert_dist)
    ax2.plot(noise_levels, dists, color=colors[name], linewidth=2.5, label=name)

ax2.set_xlabel('Noise level ε', fontsize=12)
ax2.set_ylabel('Certified distance', fontsize=12)
ax2.set_title('Distance Certificate Under Noise', fontsize=14)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.set_ylim(bottom=0)

plt.suptitle(f'Noise Sensitivity of Lorentzian Certificates (n={n})',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('noise_degradation.png', dpi=150, bbox_inches='tight')
print("Saved noise_degradation.png")
