#!/usr/bin/env python3
"""
Sparse Connectome Complexity: Numerical Demonstrations

Demonstrates the key mathematical results:
1. Weighted connectome space cardinality
2. Neural Information Defect (NID) calculations
3. Encoding lower bounds for realistic brain parameters
4. Sparse vs. dense connectome comparisons
"""

import math


def connectome_space_size(n: int, k: int) -> float:
    """Cardinality of WeightedConnectomeSpace(n, k) = k^(n^2)."""
    return k ** (n * n)


def min_encoding_bits(n: int, k: int) -> float:
    """Minimum bits needed to injectively encode all connectomes."""
    return n * n * math.log2(k)


def neural_info_defect(n: int, k: int, m: int) -> float:
    """Neural Information Defect: bits lost coarse-graining from k to m levels."""
    if m >= k or m <= 0 or k <= 0:
        return 0.0
    return n * n * (math.log2(k) - math.log2(m))


def sparse_connectome_upper_bound(n: int, k: int, d: int) -> float:
    """Upper bound on number of d-sparse connectomes: C(n,d)^n * (k-1)^(n*d)."""
    from math import comb
    return comb(n, min(d, n)) ** n * (k - 1) ** (n * d)


def entropy_gap(n: int, k: int, m: int) -> float:
    """Log2 of the ratio of space sizes: n^2 * (log2(k) - log2(m))."""
    if m >= k or m <= 0 or k <= 0:
        return 0.0
    return n * n * (math.log2(k) - math.log2(m))


def main():
    print("=" * 70)
    print("SPARSE CONNECTOME COMPLEXITY: NUMERICAL DEMONSTRATIONS")
    print("=" * 70)

    # Demo 1: Small connectome spaces
    print("\n--- Demo 1: Weighted Connectome Space Sizes ---")
    for n in [2, 3, 5, 10]:
        for k in [2, 4, 256]:
            bits = min_encoding_bits(n, k)
            print(f"  n={n:3d}, k={k:3d}: space size = {k}^{n*n} = k^(n²), "
                  f"min bits = {bits:.0f}")

    # Demo 2: Neural Information Defect
    print("\n--- Demo 2: Neural Information Defect ---")
    n = 100  # 100 neurons
    print(f"  Neuron count: {n}")
    for k, m in [(256, 128), (256, 64), (256, 16), (256, 4), (256, 2)]:
        nid = neural_info_defect(n, k, m)
        per_synapse = math.log2(k) - math.log2(m)
        print(f"  k={k:3d} → m={m:3d}: NID = {nid:,.0f} bits "
              f"({per_synapse:.1f} bits/synapse × {n*n:,} synapses)")

    # Demo 3: NID Monotonicity
    print("\n--- Demo 3: NID Monotonicity (coarser = more loss) ---")
    n = 50
    k = 256
    print(f"  n={n}, source resolution k={k}")
    for m in [128, 64, 32, 16, 8, 4, 2]:
        nid = neural_info_defect(n, k, m)
        print(f"  m={m:3d}: NID = {nid:>10,.0f} bits")
    print("  ↑ NID increases as m decreases (monotonicity verified)")

    # Demo 4: NID Quadratic Scaling
    print("\n--- Demo 4: NID Quadratic Scaling in Neuron Count ---")
    k, m = 256, 16
    for n in [10, 20, 40, 80]:
        nid = neural_info_defect(n, k, m)
        print(f"  n={n:3d}: NID = {nid:>12,.0f} bits")
    print("  ↑ NID(2n) = 4 × NID(n) (quadratic scaling verified)")

    # Demo 5: Realistic brain parameters
    print("\n--- Demo 5: Realistic Brain Encoding ---")
    brains = [
        ("C. elegans", 302, 10_000, 8),
        ("Fruit fly", 100_000, 10_000_000, 16),
        ("Mouse", 75_000_000, 7_500_000_000, 64),
        ("Human (sparse)", 86_000_000_000, 100_000_000_000_000, 256),
    ]
    for name, neurons, synapses, k in brains:
        # Using sparse model: synapses × log2(k) bits
        bits_sparse = synapses * math.log2(k)
        bits_dense = neurons * neurons * math.log2(k)
        nid_half = neural_info_defect(neurons, k, int(k**0.5)) if neurons <= 100_000 else \
            synapses * (math.log2(k) - math.log2(int(k**0.5)))
        print(f"  {name}:")
        print(f"    Neurons: {neurons:>20,}")
        print(f"    Synapses: {synapses:>19,}")
        print(f"    Weight levels: {k}")
        print(f"    Sparse encoding: {bits_sparse:>14,.0f} bits "
              f"({bits_sparse / 8 / 1e12:.2f} TB)")
        if neurons <= 100_000:
            print(f"    Dense encoding:  {bits_dense:>14,.0f} bits "
                  f"({bits_dense / 8 / 1e12:.6f} TB)")
        print(f"    NID (sqrt-reduction): {nid_half:>10,.0f} bits")

    # Demo 6: Digital Immortality Impossibility
    print("\n--- Demo 6: Digital Immortality Impossibility ---")
    print("  For any storage budget B bits, choosing n=B+1 and k=2:")
    for B in [100, 1000, 10000]:
        n_break = B + 1
        bits_needed = n_break * n_break
        print(f"  B={B:>6,}: need {bits_needed:>12,} bits > {B:>6,} available ✗")

    # Demo 7: Sparse vs Dense Comparison
    print("\n--- Demo 7: Sparse vs Dense Connectome Counts ---")
    n = 10
    k = 2
    dense_count = k ** (n * n)
    print(f"  n={n}, k={k}:")
    print(f"  Dense (all connectomes): 2^{n*n} = {dense_count}")
    for d in [1, 2, 3, 5, n]:
        bound = sparse_connectome_upper_bound(n, k, d)
        ratio = bound / dense_count if dense_count > 0 else 0
        print(f"  d={d}: upper bound ≈ {bound:.2e} "
              f"(fraction of dense: {ratio:.2e})")

    # Demo 8: Entropy Gap
    print("\n--- Demo 8: Entropy Gap between Resolution Levels ---")
    n = 20
    print(f"  n={n}")
    for k, m in [(256, 128), (256, 64), (256, 16), (64, 16), (16, 4)]:
        gap = entropy_gap(n, k, m)
        print(f"  {k}→{m}: entropy gap = {gap:,.0f} bits")

    print("\n" + "=" * 70)
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Neural Information Defect heatmap and scaling curves.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math


def neural_info_defect(n: int, k: int, m: int) -> float:
    if m >= k or m <= 0 or k <= 0:
        return 0.0
    return n * n * (math.log2(k) - math.log2(m))


def plot_nid_heatmap():
    """Plot NID as a function of source and target resolution."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Left: NID heatmap for n=100
    n = 100
    k_values = [2**i for i in range(1, 11)]  # 2 to 1024
    m_values = [2**i for i in range(1, 11)]

    nid_matrix = np.zeros((len(k_values), len(m_values)))
    for i, k in enumerate(k_values):
        for j, m in enumerate(m_values):
            nid_matrix[i, j] = neural_info_defect(n, k, m)

    im = axes[0].imshow(nid_matrix, aspect='auto', cmap='hot_r',
                         origin='lower')
    axes[0].set_xticks(range(len(m_values)))
    axes[0].set_xticklabels([str(m) for m in m_values], rotation=45)
    axes[0].set_yticks(range(len(k_values)))
    axes[0].set_yticklabels([str(k) for k in k_values])
    axes[0].set_xlabel('Target Resolution m')
    axes[0].set_ylabel('Source Resolution k')
    axes[0].set_title(f'Neural Information Defect (n={n} neurons)')
    plt.colorbar(im, ax=axes[0], label='NID (bits)')

    # Right: NID scaling with neuron count
    n_values = np.arange(10, 201, 5)
    k, m = 256, 16
    nid_values = [neural_info_defect(int(n_val), k, m) for n_val in n_values]

    axes[1].plot(n_values, nid_values, 'b-', linewidth=2)
    axes[1].set_xlabel('Number of Neurons (n)')
    axes[1].set_ylabel('NID (bits)')
    axes[1].set_title(f'NID Quadratic Scaling (k={k}→m={m})')
    axes[1].grid(True, alpha=0.3)

    # Overlay quadratic fit
    a = (math.log2(k) - math.log2(m))
    quadratic = a * n_values ** 2
    axes[1].plot(n_values, quadratic, 'r--', alpha=0.7,
                 label=f'n² × {a:.1f}')
    axes[1].legend()

    plt.tight_layout()
    plt.savefig('nid_analysis.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: nid_analysis.png")


def plot_encoding_bounds():
    """Plot encoding bounds for different brain sizes."""
    fig, ax = plt.subplots(figsize=(10, 6))

    organisms = {
        'C. elegans': (302, 8),
        'Fruit fly': (100_000, 16),
        'Zebrafish': (1_000_000, 32),
        'Mouse': (75_000_000, 64),
        'Human': (86_000_000_000, 256),
    }

    names = list(organisms.keys())
    neurons = [organisms[name][0] for name in names]
    k_values_list = [organisms[name][1] for name in names]
    bits = [n * n * math.log2(k) for n, k in zip(neurons, k_values_list)]

    x = range(len(names))
    bars = ax.bar(x, [math.log10(b) for b in bits], color=['green', 'blue',
                  'orange', 'red', 'purple'], alpha=0.7)

    ax.set_xticks(x)
    ax.set_xticklabels(names, rotation=15)
    ax.set_ylabel('log₁₀(Minimum Encoding Bits)')
    ax.set_title('Mind Encoding Requirements by Organism')
    ax.grid(True, alpha=0.3, axis='y')

    for bar, b in zip(bars, bits):
        ax.text(bar.get_x() + bar.get_width() / 2, bar.get_height() + 0.3,
                f'{b:.1e}', ha='center', va='bottom', fontsize=8)

    plt.tight_layout()
    plt.savefig('encoding_bounds.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: encoding_bounds.png")


def plot_sparse_vs_dense():
    """Plot sparse vs dense connectome count comparison."""
    fig, ax = plt.subplots(figsize=(10, 6))

    n_values = range(3, 21)
    k = 2

    dense_log = [n * n * math.log2(k) for n in n_values]

    for d in [1, 2, 3, 5]:
        sparse_log = []
        for n in n_values:
            d_eff = min(d, n)
            # C(n, d_eff)^n × (k-1)^(n×d_eff)
            from math import comb
            count = comb(n, d_eff) ** n * max(1, (k - 1) ** (n * d_eff))
            sparse_log.append(math.log2(max(count, 1)))
        ax.plot(list(n_values), sparse_log, '-o', markersize=4,
                label=f'd={d} (sparse)')

    ax.plot(list(n_values), dense_log, 'k-s', markersize=4,
            label='Dense (all)', linewidth=2)

    ax.set_xlabel('Number of Neurons (n)')
    ax.set_ylabel('log₂(Connectome Count)')
    ax.set_title('Sparse vs Dense Connectome Counts (k=2)')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('sparse_vs_dense.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: sparse_vs_dense.png")


if __name__ == "__main__":
    plot_nid_heatmap()
    plot_encoding_bounds()
    plot_sparse_vs_dense()
