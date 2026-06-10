#!/usr/bin/env python3
"""
applications.py — Real-World Applications of Permutation Network Security Bounds

Demonstrates how the theorems apply to practical cryptographic scenarios:
1. Lightweight cipher round analysis (PRESENT-style)
2. Key schedule adequacy checking
3. Diffusion quality certification
4. Side-channel-aware design constraints
"""

import math
import random
from collections import Counter
from typing import List, Tuple, Dict


# ──────────────────────────────────────────────────────────────
# Permutation primitives (self-contained)
# ──────────────────────────────────────────────────────────────

def identity(n: int) -> Tuple[int, ...]:
    return tuple(range(n))

def compose(a: Tuple[int, ...], b: Tuple[int, ...]) -> Tuple[int, ...]:
    return tuple(a[b[i]] for i in range(len(a)))

def adj_swap(n: int, j: int) -> Tuple[int, ...]:
    p = list(range(n))
    p[j], p[j + 1] = p[j + 1], p[j]
    return tuple(p)

def cyclic_shift(n: int, t: int) -> Tuple[int, ...]:
    return tuple((i + t) % n for i in range(n))

def total_displacement(perm: Tuple[int, ...]) -> int:
    return sum(abs(perm[i] - i) for i in range(len(perm)))

def random_adj_swap_layer(n: int, k: int) -> Tuple[int, ...]:
    available = list(range(n - 1))
    random.shuffle(available)
    layer = identity(n)
    used = set()
    count = 0
    for j in available:
        if j not in used and (j + 1) not in used and count < k:
            layer = compose(adj_swap(n, j), layer)
            used.update([j, j + 1])
            count += 1
    return layer

def build_network(n: int, T: int, k: int) -> Tuple[int, ...]:
    result = identity(n)
    for r in range(T):
        if r % 2 == 0:
            result = compose(random_adj_swap_layer(n, k), result)
        else:
            result = compose(cyclic_shift(n, random.randint(0, n-1)), result)
    return result


# ──────────────────────────────────────────────────────────────
# Application 1: Lightweight Cipher Round Analysis
# ──────────────────────────────────────────────────────────────

def analyze_cipher_rounds(n: int = 8, k_values: List[int] = [1, 2, 3, 4],
                          T_max: int = 30, samples: int = 20000):
    """Analyze minimum rounds needed for different swap budgets.

    Models a PRESENT-style cipher where:
    - Each round consists of an S-box layer (modeled as adj swaps)
      followed by a permutation layer (modeled as cyclic shift)
    - Security requires TV distance from uniform to drop below ε

    Returns:
        Dict mapping k -> minimum rounds for ε-security at various thresholds
    """
    print("=" * 70)
    print("APPLICATION 1: Lightweight Cipher Round Analysis")
    print("=" * 70)
    print(f"\nModeling a PRESENT-style cipher on n={n} wires")
    print(f"Each round: adjacent-swap layer (≤k swaps) + cyclic shift")
    print()

    n_factorial = math.factorial(n)
    thresholds = [0.5, 0.1, 0.01]

    results = {}
    for k in k_values:
        results[k] = {}
        print(f"k = {k} swaps per layer:")
        for T in range(1, T_max + 1):
            counts = Counter()
            for _ in range(samples):
                perm = build_network(n, T, k)
                counts[perm] += 1

            # Empirical TV
            uniform_prob = 1.0 / n_factorial
            tv = sum(abs(c/samples - uniform_prob) for c in counts.values())
            tv += (n_factorial - len(counts)) * uniform_prob
            tv /= 2.0

            for eps in thresholds:
                if eps not in results[k] and tv < eps:
                    results[k][eps] = T

            if T <= 5 or T % 5 == 0:
                print(f"  T={T:3d}: TV={tv:.4f}, support={len(counts)}/{n_factorial}")

        print(f"  Minimum rounds for ε-security:")
        for eps in thresholds:
            if eps in results[k]:
                print(f"    TV < {eps}: T ≥ {results[k][eps]}")
            else:
                print(f"    TV < {eps}: T > {T_max} (not reached)")
        print()

    return results


# ──────────────────────────────────────────────────────────────
# Application 2: Key Schedule Adequacy
# ──────────────────────────────────────────────────────────────

def check_key_schedule_adequacy(n: int = 8, key_bits_list: List[int] = [8, 16, 32, 64, 80]):
    """Check if key schedule provides enough permutation diversity.

    Theorem 2: TV ≥ 1 - |K|/n!
    So we need |K| ≈ n! for good security.

    For n=8: n! = 40320, log₂(n!) ≈ 15.3 bits
    """
    print("=" * 70)
    print("APPLICATION 2: Key Schedule Adequacy Analysis")
    print("=" * 70)

    n_factorial = math.factorial(n)
    log2_nfact = math.log2(n_factorial)

    print(f"\nn = {n}, n! = {n_factorial}, log₂(n!) = {log2_nfact:.1f} bits")
    print(f"\nKey schedule analysis (Theorem 2: TV ≥ 1 - |K|/n!):")
    print(f"{'Key bits':>10} {'|K|':>12} {'TV lower bound':>16} {'Secure?':>10}")
    print("-" * 52)

    for key_bits in key_bits_list:
        K = 2 ** key_bits
        tv_bound = max(0.0, 1.0 - K / n_factorial)
        secure = "YES" if tv_bound < 0.01 else "NO"
        print(f"{key_bits:>10} {K:>12} {tv_bound:>16.6f} {secure:>10}")

    print(f"\nConclusion: Need at least {math.ceil(log2_nfact)} key bits")
    print(f"for any possibility of ε < 0.01 security on {n}-wire network.")
    print(f"(This is a NECESSARY condition, not sufficient!)")


# ──────────────────────────────────────────────────────────────
# Application 3: Diffusion Quality Certification
# ──────────────────────────────────────────────────────────────

def certify_diffusion_quality(n: int = 8, T: int = 10, k: int = 2,
                              samples: int = 30000):
    """Certify diffusion quality using the displacement observable.

    Theorem 4: Each adjacent swap changes displacement by ≤ 2.
    So after T rounds of k swaps: displacement ≤ 2Tk from starting value.

    For identity start: displacement grows from 0 toward E_U[disp].
    If 2Tk < E_U[disp], mixing is impossible.
    """
    print("=" * 70)
    print("APPLICATION 3: Diffusion Quality Certification")
    print("=" * 70)

    import itertools
    n_factorial = math.factorial(n)

    # Compute E_U[displacement] exactly for small n
    total_disp = sum(total_displacement(p) for p in itertools.permutations(range(n)))
    uniform_mean_disp = total_disp / n_factorial

    print(f"\nn = {n}, k = {k} swaps/layer")
    print(f"E_U[displacement] = {uniform_mean_disp:.2f}")
    print(f"\nDisplacement reachability analysis (Theorem 4):")
    print(f"{'T':>5} {'Max Δ disp':>12} {'Can reach E_U?':>16} {'Empirical E[disp]':>20}")
    print("-" * 57)

    for T_val in range(1, 25):
        max_delta = 2 * T_val * k
        can_reach = "YES" if max_delta >= uniform_mean_disp else "NO"

        # Empirical
        disps = [total_displacement(build_network(n, T_val, k)) for _ in range(samples // 10)]
        emp_mean = sum(disps) / len(disps)

        print(f"{T_val:>5} {max_delta:>12} {can_reach:>16} {emp_mean:>20.2f}")

    print(f"\nMinimum rounds for displacement to REACH uniform level:")
    T_min = math.ceil(uniform_mean_disp / (2 * k))
    print(f"  T ≥ {T_min} (from 2Tk ≥ E_U[disp] = {uniform_mean_disp:.2f})")
    print(f"  This is a NECESSARY condition for mixing.")


# ──────────────────────────────────────────────────────────────
# Application 4: Side-Channel Design Constraints
# ──────────────────────────────────────────────────────────────

def analyze_side_channel_constraints(n: int = 8):
    """Analyze wire-movement cost as a side-channel proxy.

    In hardware, wire crossings cost energy proportional to displacement.
    The displacement observable captures this physical constraint.
    """
    print("=" * 70)
    print("APPLICATION 4: Side-Channel Design Constraints")
    print("=" * 70)

    import itertools
    n_factorial = math.factorial(n)

    # Displacement statistics for uniform permutations
    disps = [total_displacement(p) for p in itertools.permutations(range(n))]
    mean_disp = sum(disps) / len(disps)
    var_disp = sum((d - mean_disp)**2 for d in disps) / len(disps)
    std_disp = var_disp ** 0.5
    min_disp = min(disps)
    max_disp = max(disps)

    print(f"\nDisplacement statistics for uniform S_{n}:")
    print(f"  Mean:  {mean_disp:.2f}")
    print(f"  Std:   {std_disp:.2f}")
    print(f"  Range: [{min_disp}, {max_disp}]")

    # Cost distribution
    cost_counts = Counter(disps)
    print(f"\n  Displacement distribution (top 10):")
    for disp, count in sorted(cost_counts.items(), key=lambda x: -x[1])[:10]:
        prob = count / n_factorial
        print(f"    displacement = {disp:3d}: probability = {prob:.4f}")

    # Energy implication
    print(f"\n  Design implication:")
    print(f"  - A secure permutation network must produce outputs with")
    print(f"    mean displacement ≈ {mean_disp:.1f} (matching uniform)")
    print(f"  - Shallow networks (T ≤ {math.ceil(mean_disp / 4)}) with k=2")
    print(f"    CANNOT reach this displacement level (Theorem 4)")
    print(f"  - Low-displacement outputs are a side-channel indicator")
    print(f"    of insufficient mixing")


def main():
    random.seed(42)  # Reproducibility

    analyze_cipher_rounds(n=8, k_values=[1, 2, 3], T_max=20, samples=10000)
    print()
    check_key_schedule_adequacy(n=8)
    print()
    certify_diffusion_quality(n=8, T=10, k=2, samples=10000)
    print()
    analyze_side_channel_constraints(n=8)


if __name__ == '__main__':
    main()


#!/usr/bin/env python3
"""
demo.py — Alternating Permutation Network Security Analysis

Demonstrates the cryptographic security bounds for alternating permutation
networks on n=8 wires. Constructs networks with adjacent-swap and cyclic-shift
layers, computes empirical TV distance from uniform, observable bias,
support size, and estimated min-entropy. Compares to theoretical lower bounds.

Usage:
    python demo.py [--n N] [--max_rounds T] [--max_swaps K] [--samples S]
"""

import itertools
import math
import random
import argparse
from collections import Counter

import numpy as np
try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    HAS_MPL = True
except ImportError:
    HAS_MPL = False


def perm_compose(a, b, n):
    """Compose two permutations: (a * b)(i) = a(b(i))."""
    return tuple(a[b[i]] for i in range(n))


def identity_perm(n):
    return tuple(range(n))


def adj_swap(n, j):
    """Adjacent transposition swap(j, j+1) on {0,...,n-1}."""
    p = list(range(n))
    p[j], p[j + 1] = p[j + 1], p[j]
    return tuple(p)


def cyclic_shift(n, t):
    """Cyclic shift by t positions: i -> (i + t) mod n."""
    return tuple((i + t) % n for i in range(n))


def random_adj_swap_layer(n, k):
    """Generate a random adjacent-swap layer using at most k non-overlapping swaps."""
    available = list(range(n - 1))
    random.shuffle(available)
    swaps = []
    used = set()
    for j in available:
        if j not in used and (j + 1) not in used and len(swaps) < k:
            swaps.append(j)
            used.add(j)
            used.add(j + 1)
    layer = identity_perm(n)
    for j in swaps:
        layer = perm_compose(adj_swap(n, j), layer, n)
    return layer


def random_cyclic_layer(n):
    """Generate a random cyclic shift layer."""
    t = random.randint(0, n - 1)
    return cyclic_shift(n, t)


def build_alternating_network(n, T, k):
    """Build a T-round alternating network: even=adj_swap, odd=cyclic_shift."""
    layers = []
    for r in range(T):
        if r % 2 == 0:
            layers.append(random_adj_swap_layer(n, k))
        else:
            layers.append(random_cyclic_layer(n))
    result = identity_perm(n)
    for layer in layers:
        result = perm_compose(layer, result, n)
    return result


def total_displacement(perm):
    """Total displacement: sum_i |perm(i) - i|."""
    return sum(abs(perm[i] - i) for i in range(len(perm)))


def compute_tv_distance(counts, n_factorial, num_samples):
    """Compute empirical TV distance from uniform."""
    uniform_prob = 1.0 / n_factorial
    tv = 0.0
    for perm, count in counts.items():
        emp_prob = count / num_samples
        tv += abs(emp_prob - uniform_prob)
    # Permutations not seen
    unseen = n_factorial - len(counts)
    tv += unseen * uniform_prob
    return tv / 2.0


def compute_min_entropy(counts, num_samples):
    """Estimate min-entropy from empirical distribution."""
    max_prob = max(counts.values()) / num_samples
    if max_prob <= 0:
        return float('inf')
    return -math.log2(max_prob)


def support_size_tv_bound(K, N):
    """Theoretical TV bound from support size: 1 - K/N."""
    return max(0.0, 1.0 - K / N)


def run_experiment(n, T_max, k_values, num_samples, num_keys):
    """Run the full experiment for given parameters."""
    n_factorial = math.factorial(n)

    results = {}
    for k in k_values:
        results[k] = {
            'T': [], 'tv': [], 'support': [], 'displacement_mean': [],
            'displacement_std': [], 'min_entropy': [], 'tv_bound': []
        }
        for T in range(1, T_max + 1):
            # Sample network outputs
            counts = Counter()
            displacements = []
            for _ in range(num_samples):
                perm = build_alternating_network(n, T, k)
                counts[perm] += 1
                displacements.append(total_displacement(perm))

            tv = compute_tv_distance(counts, n_factorial, num_samples)
            supp = len(counts)
            disp_mean = np.mean(displacements)
            disp_std = np.std(displacements)
            me = compute_min_entropy(counts, num_samples)

            # Support-size TV bound
            tv_bound = support_size_tv_bound(min(num_keys, num_samples), n_factorial)

            results[k]['T'].append(T)
            results[k]['tv'].append(tv)
            results[k]['support'].append(supp)
            results[k]['displacement_mean'].append(disp_mean)
            results[k]['displacement_std'].append(disp_std)
            results[k]['min_entropy'].append(me)
            results[k]['tv_bound'].append(tv_bound)

    return results


def print_results(results, n, n_factorial):
    """Print results in tabular form."""
    max_entropy = math.log2(n_factorial)
    print(f"\n{'='*80}")
    print(f"Alternating Permutation Network Analysis (n={n}, n!={n_factorial})")
    print(f"Max entropy = log₂(n!) = {max_entropy:.2f} bits")
    print(f"{'='*80}")

    for k, data in sorted(results.items()):
        print(f"\n--- k = {k} adjacent swaps per layer ---")
        print(f"{'T':>4} {'TV dist':>10} {'Support':>10} {'Disp μ':>10} "
              f"{'Disp σ':>10} {'MinEnt':>10} {'EntGap':>10}")
        print("-" * 74)
        for i in range(len(data['T'])):
            entropy_gap = max_entropy - data['min_entropy'][i]
            print(f"{data['T'][i]:>4d} {data['tv'][i]:>10.4f} "
                  f"{data['support'][i]:>10d} {data['displacement_mean'][i]:>10.2f} "
                  f"{data['displacement_std'][i]:>10.2f} {data['min_entropy'][i]:>10.2f} "
                  f"{entropy_gap:>10.2f}")


def plot_results(results, n):
    """Generate plots of TV distance vs rounds for different k values."""
    if not HAS_MPL:
        print("matplotlib not available, skipping plots")
        return

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle(f'Alternating Permutation Network Security Analysis (n={n})',
                 fontsize=14, fontweight='bold')

    colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12', '#9b59b6']

    # Plot 1: TV distance vs rounds
    ax = axes[0, 0]
    for i, (k, data) in enumerate(sorted(results.items())):
        ax.plot(data['T'], data['tv'], 'o-', color=colors[i % len(colors)],
                label=f'k={k}', markersize=4)
    ax.set_xlabel('Rounds T')
    ax.set_ylabel('TV Distance from Uniform')
    ax.set_title('Total Variation Distance')
    ax.legend()
    ax.grid(True, alpha=0.3)
    ax.set_ylim(bottom=0)

    # Plot 2: Support size vs rounds
    ax = axes[0, 1]
    n_factorial = math.factorial(n)
    for i, (k, data) in enumerate(sorted(results.items())):
        support_frac = [s / n_factorial for s in data['support']]
        ax.plot(data['T'], support_frac, 's-', color=colors[i % len(colors)],
                label=f'k={k}', markersize=4)
    ax.set_xlabel('Rounds T')
    ax.set_ylabel('Support / n!')
    ax.set_title('Support Size (fraction of S_n)')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Plot 3: Mean displacement vs rounds
    ax = axes[1, 0]
    for i, (k, data) in enumerate(sorted(results.items())):
        ax.errorbar(data['T'], data['displacement_mean'],
                    yerr=data['displacement_std'],
                    fmt='D-', color=colors[i % len(colors)],
                    label=f'k={k}', markersize=4, capsize=3)
    # Expected displacement for uniform permutation
    expected_uniform = sum(sum(abs(perm[i] - i) for i in range(n))
                          for perm in itertools.permutations(range(n))) / n_factorial
    ax.axhline(y=expected_uniform, color='gray', linestyle='--',
               label=f'Uniform E[disp]={expected_uniform:.1f}')
    ax.set_xlabel('Rounds T')
    ax.set_ylabel('Total Displacement')
    ax.set_title('Displacement Observable')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Plot 4: Min-entropy vs rounds
    ax = axes[1, 1]
    max_entropy = math.log2(n_factorial)
    for i, (k, data) in enumerate(sorted(results.items())):
        ax.plot(data['T'], data['min_entropy'], '^-', color=colors[i % len(colors)],
                label=f'k={k}', markersize=4)
    ax.axhline(y=max_entropy, color='gray', linestyle='--',
               label=f'Max entropy={max_entropy:.1f}')
    ax.set_xlabel('Rounds T')
    ax.set_ylabel('Min-Entropy (bits)')
    ax.set_title('Min-Entropy')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('alternating_network_analysis.png', dpi=150, bbox_inches='tight')
    print("\nPlot saved to alternating_network_analysis.png")


def main():
    parser = argparse.ArgumentParser(
        description='Alternating Permutation Network Security Analysis')
    parser.add_argument('--n', type=int, default=8,
                        help='Number of wires (default: 8)')
    parser.add_argument('--max_rounds', type=int, default=20,
                        help='Maximum number of rounds (default: 20)')
    parser.add_argument('--max_swaps', type=int, nargs='+', default=[1, 2, 3],
                        help='Swaps per adjacent layer (default: 1 2 3)')
    parser.add_argument('--samples', type=int, default=50000,
                        help='Number of random samples (default: 50000)')
    parser.add_argument('--keys', type=int, default=50000,
                        help='Number of keys to sample (default: 50000)')
    args = parser.parse_args()

    print(f"Running with n={args.n}, T_max={args.max_rounds}, "
          f"k={args.max_swaps}, samples={args.samples}")

    results = run_experiment(args.n, args.max_rounds, args.max_swaps,
                             args.samples, args.keys)

    n_factorial = math.factorial(args.n)
    print_results(results, args.n, n_factorial)
    plot_results(results, args.n)


if __name__ == '__main__':
    main()


#!/usr/bin/env python3
"""
Visualization: Displacement Heatmap

Shows how the distribution of total displacement evolves with rounds T
for a fixed number of swaps k. Compares the network distribution against
the uniform distribution over S_n.

The key visual insight: shallow networks cluster near low displacement,
while uniform permutations spread across a much wider range. The
transition from concentrated to spread-out is the "mixing" process.
"""

import math
import random
import itertools
from collections import Counter

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def identity(n):
    return tuple(range(n))

def compose(a, b):
    return tuple(a[b[i]] for i in range(len(a)))

def adj_swap(n, j):
    p = list(range(n))
    p[j], p[j+1] = p[j+1], p[j]
    return tuple(p)

def cyclic_shift(n, t):
    return tuple((i + t) % n for i in range(n))

def total_displacement(perm):
    return sum(abs(perm[i] - i) for i in range(len(perm)))

def random_adj_swap_layer(n, k):
    available = list(range(n-1))
    random.shuffle(available)
    layer = identity(n)
    used = set()
    count = 0
    for j in available:
        if j not in used and (j+1) not in used and count < k:
            layer = compose(adj_swap(n, j), layer)
            used.update([j, j+1])
            count += 1
    return layer

def build_network(n, T, k):
    result = identity(n)
    for r in range(T):
        if r % 2 == 0:
            result = compose(random_adj_swap_layer(n, k), result)
        else:
            result = compose(cyclic_shift(n, random.randint(0, n-1)), result)
    return result


random.seed(42)
n = 8
k = 2
T_values = list(range(1, 21))
num_samples = 30000

# Compute uniform displacement distribution
n_factorial = math.factorial(n)
uniform_disps = Counter()
for p in itertools.permutations(range(n)):
    uniform_disps[total_displacement(p)] += 1
max_disp = max(uniform_disps.keys())
uniform_dist = {d: c / n_factorial for d, c in uniform_disps.items()}

# Build heatmap data
disp_range = list(range(0, max_disp + 1, 2))  # Displacement is always even
heatmap = np.zeros((len(T_values), len(disp_range)))

for ti, T in enumerate(T_values):
    counts = Counter()
    for _ in range(num_samples):
        d = total_displacement(build_network(n, T, k))
        counts[d] += 1
    for di, d in enumerate(disp_range):
        heatmap[ti, di] = counts.get(d, 0) / num_samples

# Uniform distribution row
uniform_row = np.array([uniform_dist.get(d, 0) for d in disp_range])

fig, axes = plt.subplots(2, 1, figsize=(14, 10), gridspec_kw={'height_ratios': [4, 1]})

# Heatmap
ax = axes[0]
im = ax.imshow(heatmap, aspect='auto', cmap='YlOrRd', origin='lower',
               extent=[disp_range[0]-1, disp_range[-1]+1, T_values[0]-0.5, T_values[-1]+0.5])
ax.set_xlabel('Total Displacement', fontsize=12)
ax.set_ylabel('Number of Rounds T', fontsize=12)
ax.set_title(f'Displacement Distribution vs Rounds (n={n}, k={k})', fontsize=14, fontweight='bold')
plt.colorbar(im, ax=ax, label='Probability')

# Mark the uniform mean displacement
uniform_mean = sum(d * p for d, p in uniform_dist.items())
ax.axvline(x=uniform_mean, color='cyan', linestyle='--', linewidth=2, alpha=0.7,
           label=f'Uniform mean = {uniform_mean:.1f}')
ax.legend(loc='upper right', fontsize=10)

# Comparison: network vs uniform for selected T values
ax2 = axes[1]
T_compare = [2, 5, 10, 20]
colors_compare = ['#e74c3c', '#f39c12', '#3498db', '#2ecc71']
ax2.bar(disp_range, uniform_row, width=1.5, alpha=0.3, color='gray', label='Uniform')
for T_val, col in zip(T_compare, colors_compare):
    if T_val in T_values:
        ti = T_values.index(T_val)
        ax2.plot(disp_range, heatmap[ti], 'o-', color=col, markersize=3,
                 label=f'T={T_val}', linewidth=1.5)
ax2.set_xlabel('Total Displacement', fontsize=12)
ax2.set_ylabel('Probability', fontsize=12)
ax2.set_title('Network Distribution vs Uniform', fontsize=12)
ax2.legend(fontsize=9, ncol=5)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('displacement_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved displacement_heatmap.png")


#!/usr/bin/env python3
"""
Visualization: Security Landscape

A 2D heatmap showing TV distance from uniform as a function of both
rounds T (y-axis) and swaps per layer k (x-axis). This reveals the
"security landscape" — the region where the network is provably insecure
vs where it approaches uniformity.

Also shows contour lines for specific security thresholds (TV = 0.5, 0.1, 0.01).
"""

import math
import random
from collections import Counter

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def identity(n):
    return tuple(range(n))

def compose(a, b):
    return tuple(a[b[i]] for i in range(len(a)))

def adj_swap(n, j):
    p = list(range(n))
    p[j], p[j+1] = p[j+1], p[j]
    return tuple(p)

def cyclic_shift(n, t):
    return tuple((i + t) % n for i in range(n))

def random_adj_swap_layer(n, k):
    available = list(range(n-1))
    random.shuffle(available)
    layer = identity(n)
    used = set()
    count = 0
    for j in available:
        if j not in used and (j+1) not in used and count < k:
            layer = compose(adj_swap(n, j), layer)
            used.update([j, j+1])
            count += 1
    return layer

def build_network(n, T, k):
    result = identity(n)
    for r in range(T):
        if r % 2 == 0:
            result = compose(random_adj_swap_layer(n, k), result)
        else:
            result = compose(cyclic_shift(n, random.randint(0, n-1)), result)
    return result

def empirical_tv(counts, n_factorial, num_samples):
    uniform_prob = 1.0 / n_factorial
    tv = sum(abs(c/num_samples - uniform_prob) for c in counts.values())
    tv += (n_factorial - len(counts)) * uniform_prob
    return tv / 2.0


random.seed(42)
n = 8
n_factorial = math.factorial(n)
k_values = list(range(1, 5))
T_values = list(range(1, 21))
num_samples = 20000

# Compute TV distance grid
tv_grid = np.zeros((len(T_values), len(k_values)))
support_grid = np.zeros((len(T_values), len(k_values)))

for ki, k in enumerate(k_values):
    for ti, T in enumerate(T_values):
        counts = Counter()
        for _ in range(num_samples):
            counts[build_network(n, T, k)] += 1
        tv_grid[ti, ki] = empirical_tv(counts, n_factorial, num_samples)
        support_grid[ti, ki] = len(counts)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7))

# Heatmap 1: TV distance
im1 = ax1.imshow(tv_grid, aspect='auto', cmap='RdYlGn_r', origin='lower',
                 extent=[k_values[0]-0.5, k_values[-1]+0.5,
                         T_values[0]-0.5, T_values[-1]+0.5],
                 vmin=0, vmax=1)
# Contour lines
cs = ax1.contour(np.arange(len(k_values)), np.arange(len(T_values)),
                 tv_grid, levels=[0.01, 0.1, 0.5],
                 colors=['white', 'lightgray', 'black'], linewidths=2)
ax1.clabel(cs, fmt={0.01: 'TV=0.01', 0.1: 'TV=0.1', 0.5: 'TV=0.5'},
           fontsize=10)
ax1.set_xticks(range(len(k_values)))
ax1.set_xticklabels(k_values)
ax1.set_yticks(range(0, len(T_values), 2))
ax1.set_yticklabels([T_values[i] for i in range(0, len(T_values), 2)])
ax1.set_xlabel('Swaps per Layer (k)', fontsize=12)
ax1.set_ylabel('Number of Rounds (T)', fontsize=12)
ax1.set_title('TV Distance from Uniform', fontsize=13, fontweight='bold')
plt.colorbar(im1, ax=ax1, label='TV Distance')

# Heatmap 2: Support size (log scale)
log_support = np.log2(support_grid + 1)
im2 = ax2.imshow(log_support, aspect='auto', cmap='viridis', origin='lower',
                 extent=[k_values[0]-0.5, k_values[-1]+0.5,
                         T_values[0]-0.5, T_values[-1]+0.5])
ax2.set_xticks(range(len(k_values)))
ax2.set_xticklabels(k_values)
ax2.set_yticks(range(0, len(T_values), 2))
ax2.set_yticklabels([T_values[i] for i in range(0, len(T_values), 2)])
ax2.set_xlabel('Swaps per Layer (k)', fontsize=12)
ax2.set_ylabel('Number of Rounds (T)', fontsize=12)
ax2.set_title(f'Support Size (log₂ scale, max = log₂({n_factorial}) = {math.log2(n_factorial):.1f})',
              fontsize=13, fontweight='bold')
cbar = plt.colorbar(im2, ax=ax2, label='log₂(support size)')
ax2.axhline(y=len(T_values)-0.5, color='white', alpha=0)  # dummy for layout

fig.suptitle(f'Security Landscape: Alternating Permutation Networks on S₈',
             fontsize=15, fontweight='bold', y=1.02)

plt.tight_layout()
plt.savefig('security_landscape.png', dpi=150, bbox_inches='tight')
print("Saved security_landscape.png")


#!/usr/bin/env python3
"""
Visualization: TV Distance Decay Curves

Visualizes how total variation distance from uniform decays as the number
of rounds T increases, for different values of k (swaps per layer).
Shows the theoretical support-size bound and the empirical decay.

This is the central experimental finding: shallow alternating permutation
networks leave a mathematically detectable scar that decays with rounds.
"""

import math
import random
from collections import Counter

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def identity(n):
    return tuple(range(n))

def compose(a, b):
    return tuple(a[b[i]] for i in range(len(a)))

def adj_swap(n, j):
    p = list(range(n))
    p[j], p[j+1] = p[j+1], p[j]
    return tuple(p)

def cyclic_shift(n, t):
    return tuple((i + t) % n for i in range(n))

def random_adj_swap_layer(n, k):
    available = list(range(n-1))
    random.shuffle(available)
    layer = identity(n)
    used = set()
    count = 0
    for j in available:
        if j not in used and (j+1) not in used and count < k:
            layer = compose(adj_swap(n, j), layer)
            used.update([j, j+1])
            count += 1
    return layer

def build_network(n, T, k):
    result = identity(n)
    for r in range(T):
        if r % 2 == 0:
            result = compose(random_adj_swap_layer(n, k), result)
        else:
            result = compose(cyclic_shift(n, random.randint(0, n-1)), result)
    return result

def empirical_tv(counts, n_factorial, num_samples):
    uniform_prob = 1.0 / n_factorial
    tv = sum(abs(c/num_samples - uniform_prob) for c in counts.values())
    tv += (n_factorial - len(counts)) * uniform_prob
    return tv / 2.0


random.seed(42)
n = 8
n_factorial = math.factorial(n)
T_max = 24
k_values = [1, 2, 3, 4]
num_samples = 40000

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

colors = {'1': '#e74c3c', '2': '#3498db', '3': '#2ecc71', '4': '#f39c12'}

for k in k_values:
    tvs = []
    supports = []
    Ts = list(range(1, T_max + 1))
    for T in Ts:
        counts = Counter()
        for _ in range(num_samples):
            counts[build_network(n, T, k)] += 1
        tvs.append(empirical_tv(counts, n_factorial, num_samples))
        supports.append(len(counts))

    c = colors[str(k)]
    ax1.plot(Ts, tvs, 'o-', color=c, label=f'k={k}', markersize=4, linewidth=1.5)

    # Support-size bound
    tv_bounds = [max(0, 1 - s/n_factorial) for s in supports]
    ax1.plot(Ts, tv_bounds, '--', color=c, alpha=0.4, linewidth=1)

    ax2.semilogy(Ts, [max(tv, 1e-4) for tv in tvs], 'o-', color=c,
                 label=f'k={k}', markersize=4, linewidth=1.5)

ax1.set_xlabel('Number of Rounds T', fontsize=12)
ax1.set_ylabel('TV Distance from Uniform', fontsize=12)
ax1.set_title('TV Distance Decay (linear scale)', fontsize=13, fontweight='bold')
ax1.legend(fontsize=11)
ax1.grid(True, alpha=0.3)
ax1.set_ylim(bottom=0, top=1.05)
ax1.axhline(y=0.5, color='gray', linestyle=':', alpha=0.5, label='TV = 0.5')

ax2.set_xlabel('Number of Rounds T', fontsize=12)
ax2.set_ylabel('TV Distance (log scale)', fontsize=12)
ax2.set_title('TV Distance Decay (log scale)', fontsize=13, fontweight='bold')
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)
ax2.axhline(y=0.5, color='gray', linestyle=':', alpha=0.5)

fig.suptitle(f'Alternating Permutation Network on S₈ (n={n}, n!={n_factorial})',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('tv_decay_curves.png', dpi=150, bbox_inches='tight')
print("Saved tv_decay_curves.png")
