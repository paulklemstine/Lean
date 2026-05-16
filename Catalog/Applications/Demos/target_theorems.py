#!/usr/bin/env python3
"""
applications.py — Real-world applications of q-ary source coding theory.

Applications:
1. DNA data storage optimization (q=4)
2. Ternary computing code design (q=3)
3. Flash memory multi-level coding (q=4,8,16)
4. Comparison of coding efficiency across technologies
"""

import numpy as np
from math import log, ceil
from typing import List, Dict


def qary_entropy(p: List[float], q: int) -> float:
    """Compute H_q(p) = -∑ p(a) log_q(p(a))."""
    return -sum(pi * log(pi, q) for pi in p if pi > 0)


def shannon_lengths(p: List[float], q: int) -> List[int]:
    """Shannon ceiling code lengths."""
    return [ceil(log(1/pi, q)) for pi in p if pi > 0]


def expected_length(p: List[float], lengths: List[int]) -> float:
    return sum(pi * l for pi, l in zip(p, lengths))


# ============================================================
# Application 1: DNA Data Storage
# ============================================================
def dna_storage_analysis():
    """
    DNA storage uses the 4-letter alphabet {A, C, G, T}.

    The q-ary coding theorem with q=4 directly gives optimal
    encoding bounds for DNA data storage systems.
    """
    print("=" * 65)
    print("APPLICATION 1: DNA Data Storage (q = 4)")
    print("=" * 65)

    # Various source distributions
    scenarios = {
        "Uniform binary data": [0.25, 0.25, 0.25, 0.25],
        "English text (4 groups)": [0.40, 0.30, 0.20, 0.10],
        "Image data (skewed)": [0.60, 0.20, 0.15, 0.05],
        "Genomic reference": [0.29, 0.21, 0.21, 0.29],  # GC content ~42%
    }

    for name, p in scenarios.items():
        H2 = qary_entropy(p, 2)
        H4 = qary_entropy(p, 4)
        lengths_bin = shannon_lengths(p, 2)
        lengths_dna = shannon_lengths(p, 4)
        E_bin = expected_length(p, lengths_bin)
        E_dna = expected_length(p, lengths_dna)

        print(f"\n  {name}:")
        print(f"    Distribution: p = {p}")
        print(f"    Binary entropy:  H_2(p) = {H2:.4f} bits")
        print(f"    DNA entropy:     H_4(p) = {H4:.4f} nucleotides")
        print(f"    Binary code:     E[ℓ] = {E_bin:.4f} bits/symbol")
        print(f"    DNA code:        E[ℓ] = {E_dna:.4f} nt/symbol")
        print(f"    Storage density: {H2 / H4:.2f} bits/nucleotide")
        print(f"    Theoretical max: {log(4, 2):.2f} bits/nucleotide")
        print(f"    Efficiency:      {(H2/H4)/log(4,2)*100:.1f}%")


# ============================================================
# Application 2: Ternary Computing
# ============================================================
def ternary_computing_analysis():
    """
    Ternary logic uses 3 voltage levels {-1, 0, +1} or {0, 1, 2}.

    The q-ary coding theorem with q=3 provides bounds for
    ternary processors and balanced ternary arithmetic.
    """
    print("\n\n" + "=" * 65)
    print("APPLICATION 2: Ternary Computing (q = 3)")
    print("=" * 65)

    # Instruction frequency distributions
    scenarios = {
        "ALU operations": [0.45, 0.35, 0.20],
        "Memory access patterns": [0.50, 0.30, 0.20],
        "Branch predictions": [1/3, 1/3, 1/3],
    }

    for name, p in scenarios.items():
        H2 = qary_entropy(p, 2)
        H3 = qary_entropy(p, 3)
        lengths_bin = shannon_lengths(p, 2)
        lengths_ter = shannon_lengths(p, 3)
        E_bin = expected_length(p, lengths_bin)
        E_ter = expected_length(p, lengths_ter)

        print(f"\n  {name}:")
        print(f"    Distribution: p = {p}")
        print(f"    Binary:  H_2 = {H2:.4f} bits, E[ℓ] = {E_bin:.4f}")
        print(f"    Ternary: H_3 = {H3:.4f} trits, E[ℓ] = {E_ter:.4f}")
        print(f"    Info density: {H2/H3:.3f} bits/trit (max {log(3,2):.3f})")


# ============================================================
# Application 3: Flash Memory Multi-Level Cells
# ============================================================
def flash_memory_analysis():
    """
    Flash memory technologies:
    - SLC: Single-level cell (q=2, 1 bit/cell)
    - MLC: Multi-level cell (q=4, 2 bits/cell)
    - TLC: Triple-level cell (q=8, 3 bits/cell)
    - QLC: Quad-level cell (q=16, 4 bits/cell)

    The q-ary coding theorem gives optimal encoding for each technology.
    """
    print("\n\n" + "=" * 65)
    print("APPLICATION 3: Flash Memory Multi-Level Coding")
    print("=" * 65)

    # Typical data distribution (file system metadata)
    np.random.seed(42)
    p = list(np.random.dirichlet(np.ones(16)))
    p = sorted(p, reverse=True)

    flash_types = {
        "SLC (1 bit/cell)": 2,
        "MLC (2 bits/cell)": 4,
        "TLC (3 bits/cell)": 8,
        "QLC (4 bits/cell)": 16,
    }

    print(f"\n  Source: 16-symbol distribution")
    print(f"  p = [{', '.join(f'{pi:.3f}' for pi in p[:8])}...]")

    for name, q in flash_types.items():
        H = qary_entropy(p, q)
        lengths = shannon_lengths(p, q)
        E = expected_length(p, lengths)
        redundancy = E - H
        efficiency = H / E * 100

        print(f"\n  {name} (q={q}):")
        print(f"    H_{q}(p) = {H:.4f} symbols/source_symbol")
        print(f"    E[ℓ] = {E:.4f}")
        print(f"    Redundancy: {redundancy:.4f} (< 1 guaranteed)")
        print(f"    Efficiency: {efficiency:.1f}%")
        print(f"    Effective bits/cell: {log(q, 2) * efficiency / 100:.2f}")


# ============================================================
# Application 4: Cross-Technology Comparison
# ============================================================
def cross_technology_comparison():
    """Compare coding efficiency across all technologies."""
    print("\n\n" + "=" * 65)
    print("APPLICATION 4: Cross-Technology Comparison")
    print("=" * 65)

    # Use a realistic 8-symbol source
    p = [0.30, 0.20, 0.15, 0.12, 0.10, 0.07, 0.04, 0.02]

    print(f"\n  Source: p = {p}")
    print(f"\n  {'Technology':<25} {'q':>3} {'H_q':>8} {'E[ℓ]':>8} {'R':>8} {'η':>7}")
    print("  " + "-" * 61)

    technologies = [
        ("Binary", 2),
        ("Ternary", 3),
        ("DNA/MLC", 4),
        ("Quinary", 5),
        ("TLC Flash", 8),
        ("QLC Flash", 16),
    ]

    for name, q in technologies:
        H = qary_entropy(p, q)
        lengths = shannon_lengths(p, q)
        E = expected_length(p, lengths)
        R = E - H
        eta = H / E * 100

        print(f"  {name:<25} {q:>3d} {H:>8.4f} {E:>8.4f} {R:>8.4f} {eta:>6.1f}%")

    print("\n  Key insight: Redundancy R < 1 is ALWAYS guaranteed")
    print("  by the q-ary Shannon coding theorem, regardless of q.")


if __name__ == "__main__":
    dna_storage_analysis()
    ternary_computing_analysis()
    flash_memory_analysis()
    cross_technology_comparison()
    print("\n\nAll applications completed successfully!")


#!/usr/bin/env python3
"""
demo.py — Concrete numerical demonstrations of q-ary source coding theorems.

Demonstrates:
1. q-ary entropy computation for various distributions and bases
2. Kraft inequality verification for Shannon ceiling lengths
3. Shannon code bounds (lower and upper)
4. Relaxed optimizer attaining entropy exactly
5. Comparison across DNA (q=4), ternary (q=3), and binary (q=2)
"""

import numpy as np
from math import log, ceil, log2

def qary_entropy(p, q):
    """Compute H_q(p) = -sum p(a) * log_q(p(a))."""
    return -sum(pi * log(pi, q) for pi in p if pi > 0)

def shannon_lengths(p, q):
    """Compute Shannon ceiling lengths: ceil(log_q(1/p(a)))."""
    return [ceil(log(1/pi, q)) for pi in p if pi > 0]

def kraft_sum(lengths, q):
    """Compute Kraft sum: sum q^(-ell(a))."""
    return sum(q**(-l) for l in lengths)

def expected_length(p, lengths):
    """Compute expected code length E[ell] = sum p(a) * ell(a)."""
    return sum(pi * l for pi, l in zip(p, lengths))

def relaxed_optimal_lengths(p, q):
    """Compute optimal real-valued lengths L*(a) = log_q(1/p(a))."""
    return [log(1/pi, q) for pi in p if pi > 0]


# ============================================================
# Demo 1: Basic q-ary entropy for a simple distribution
# ============================================================
print("=" * 70)
print("DEMO 1: q-ary Entropy for p = (1/2, 1/4, 1/8, 1/8)")
print("=" * 70)

p = [0.5, 0.25, 0.125, 0.125]

for q in [2, 3, 4, 8, 10]:
    H = qary_entropy(p, q)
    print(f"  H_{q}(p) = {H:.6f}")

print(f"\n  Note: H_2(p) = {qary_entropy(p, 2):.4f} bits (Shannon entropy)")
print(f"        H_4(p) = {qary_entropy(p, 4):.4f} quats (DNA alphabet)")

# ============================================================
# Demo 2: Kraft inequality verification
# ============================================================
print("\n" + "=" * 70)
print("DEMO 2: Kraft Inequality for Shannon Ceiling Lengths")
print("=" * 70)

for q in [2, 3, 4]:
    lengths = shannon_lengths(p, q)
    K = kraft_sum(lengths, q)
    print(f"\n  Base q = {q}:")
    print(f"    Shannon lengths: {lengths}")
    print(f"    Kraft sum = {K:.6f} ≤ 1 ✓" if K <= 1 else f"    Kraft sum = {K:.6f} > 1 ✗")

# ============================================================
# Demo 3: Shannon code bounds
# ============================================================
print("\n" + "=" * 70)
print("DEMO 3: Shannon Code Bounds: H_q(p) ≤ E[ℓ] < H_q(p) + 1")
print("=" * 70)

for q in [2, 3, 4]:
    H = qary_entropy(p, q)
    lengths = shannon_lengths(p, q)
    E = expected_length(p, lengths)
    print(f"\n  Base q = {q}:")
    print(f"    H_{q}(p)     = {H:.6f}")
    print(f"    E[ℓ]         = {E:.6f}")
    print(f"    H_{q}(p) + 1 = {H + 1:.6f}")
    print(f"    Gap: E[ℓ] - H_{q}(p) = {E - H:.6f}")
    assert H <= E + 1e-10, "Lower bound violated!"
    assert E < H + 1 + 1e-10, "Upper bound violated!"
    print(f"    ✓ Bounds satisfied")

# ============================================================
# Demo 4: Relaxed optimizer
# ============================================================
print("\n" + "=" * 70)
print("DEMO 4: Relaxed Optimizer L*(a) = log_q(1/p(a))")
print("=" * 70)

for q in [2, 3, 4]:
    H = qary_entropy(p, q)
    Lstar = relaxed_optimal_lengths(p, q)
    E_star = expected_length(p, Lstar)
    K_star = kraft_sum(Lstar, q)
    print(f"\n  Base q = {q}:")
    print(f"    L* = [{', '.join(f'{l:.4f}' for l in Lstar)}]")
    print(f"    E[L*]      = {E_star:.6f}")
    print(f"    H_{q}(p)    = {H:.6f}")
    print(f"    |E[L*] - H| = {abs(E_star - H):.2e}")
    print(f"    Kraft sum   = {K_star:.6f}")
    print(f"    ✓ Optimizer achieves entropy exactly (up to floating point)")

# ============================================================
# Demo 5: DNA storage application (q = 4)
# ============================================================
print("\n" + "=" * 70)
print("DEMO 5: DNA Storage Application (q = 4, alphabet = {A, C, G, T})")
print("=" * 70)

# English letter frequencies (simplified to 4 groups)
p_dna = [0.40, 0.30, 0.20, 0.10]
print(f"\n  Source distribution: p = {p_dna}")

for q in [2, 4]:
    H = qary_entropy(p_dna, q)
    lengths = shannon_lengths(p_dna, q)
    E = expected_length(p_dna, lengths)
    print(f"\n  Base q = {q}:")
    print(f"    H_{q}(p) = {H:.4f} {'bits' if q == 2 else 'quats'}")
    print(f"    Shannon lengths: {lengths}")
    print(f"    Expected length: {E:.4f}")
    print(f"    Coding efficiency: {H/E*100:.1f}%")

# ============================================================
# Demo 6: Uniform distribution (maximum entropy)
# ============================================================
print("\n" + "=" * 70)
print("DEMO 6: Uniform Distribution (Maximum Entropy)")
print("=" * 70)

for n in [2, 4, 8, 16]:
    p_uniform = [1/n] * n
    for q in [2, 4]:
        H = qary_entropy(p_uniform, q)
        print(f"  n = {n:2d}, q = {q}: H_{q}(Uniform) = {H:.4f} = log_{q}({n}) = {log(n, q):.4f}")

# ============================================================
# Demo 7: Comparison of coding overhead across bases
# ============================================================
print("\n" + "=" * 70)
print("DEMO 7: Coding Overhead (E[ℓ] - H_q) Across Bases")
print("=" * 70)

# Random distribution
np.random.seed(42)
p_random = np.random.dirichlet(np.ones(8))
p_random = list(p_random)

print(f"\n  Random source over 8 symbols:")
print(f"  p = [{', '.join(f'{pi:.4f}' for pi in p_random)}]")

for q in [2, 3, 4, 5, 8]:
    H = qary_entropy(p_random, q)
    lengths = shannon_lengths(p_random, q)
    E = expected_length(p_random, lengths)
    overhead = E - H
    print(f"  q = {q}: H = {H:.4f}, E[ℓ] = {E:.4f}, overhead = {overhead:.4f}")

print("\n  Key insight: overhead is always < 1 (Shannon upper bound)")
print("  Larger q reduces overhead since ceiling rounding is relative to log_q")

print("\n" + "=" * 70)
print("All demos completed successfully!")
print("=" * 70)


#!/usr/bin/env python3
"""
visualizations.py — Generate publication-quality charts for q-ary source coding.

Generates:
1. Entropy vs base q for various distributions
2. Shannon bounds visualization
3. Coding efficiency comparison
4. Kraft inequality diagram
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from math import log, ceil
import base64
from io import BytesIO


def qary_entropy(p, q):
    return -sum(pi * log(pi, q) for pi in p if pi > 0)

def shannon_lengths(p, q):
    return [ceil(log(1/pi, q)) for pi in p if pi > 0]

def expected_length(p, lengths):
    return sum(pi * l for pi, l in zip(p, lengths))


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def plot_entropy_vs_base():
    """Plot q-ary entropy as a function of base q."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    distributions = {
        r'p = (1/2, 1/4, 1/8, 1/8)': [0.5, 0.25, 0.125, 0.125],
        r'p = (0.4, 0.3, 0.2, 0.1)': [0.4, 0.3, 0.2, 0.1],
        r'p = (0.9, 0.05, 0.03, 0.02)': [0.9, 0.05, 0.03, 0.02],
        r'p = Uniform(4)': [0.25, 0.25, 0.25, 0.25],
    }

    q_values = np.arange(2, 17)
    colors = ['#2196F3', '#FF5722', '#4CAF50', '#9C27B0']

    for (name, p), color in zip(distributions.items(), colors):
        entropies = [qary_entropy(p, q) for q in q_values]
        ax.plot(q_values, entropies, 'o-', label=name, color=color,
                markersize=6, linewidth=2)

    ax.set_xlabel('Code alphabet size q', fontsize=14)
    ax.set_ylabel('q-ary entropy H_q(p)', fontsize=14)
    ax.set_title('q-ary Entropy vs Code Alphabet Size', fontsize=16, fontweight='bold')
    ax.legend(fontsize=11, loc='upper right')
    ax.grid(True, alpha=0.3)
    ax.set_xticks(q_values)

    return fig_to_base64(fig)


def plot_shannon_bounds():
    """Visualize Shannon lower and upper bounds on expected length."""
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    p = [0.4, 0.3, 0.2, 0.1]

    for idx, q in enumerate([2, 4, 8]):
        ax = axes[idx]
        H = qary_entropy(p, q)
        lengths = shannon_lengths(p, q)
        E = expected_length(p, lengths)
        Lstar = [log(1/pi, q) for pi in p]
        E_star = sum(pi * l for pi, l in zip(p, Lstar))

        # Bar chart
        x = np.arange(len(p))
        width = 0.3
        ax.bar(x - width, Lstar, width, label=r'$L^*(a) = \log_q(1/p(a))$',
               color='#2196F3', alpha=0.8)
        ax.bar(x, lengths, width, label=r'$\lceil L^*(a) \rceil$',
               color='#FF5722', alpha=0.8)

        ax.set_xlabel('Symbol a', fontsize=12)
        ax.set_ylabel('Code length', fontsize=12)
        ax.set_title(f'q = {q}: H = {H:.3f}, E[ℓ] = {E:.3f}', fontsize=13)
        ax.set_xticks(x)
        ax.set_xticklabels([f'a{i+1}' for i in range(len(p))])
        ax.legend(fontsize=9)
        ax.grid(True, alpha=0.3, axis='y')

    fig.suptitle('Shannon Code Lengths: Optimal vs Ceiling',
                 fontsize=16, fontweight='bold', y=1.02)
    fig.tight_layout()

    return fig_to_base64(fig)


def plot_coding_efficiency():
    """Compare coding efficiency across bases and distributions."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    np.random.seed(42)
    n_trials = 50
    q_values = range(2, 13)

    # Generate random distributions
    efficiencies = {q: [] for q in q_values}
    redundancies = {q: [] for q in q_values}

    for _ in range(n_trials):
        p = list(np.random.dirichlet(np.ones(8)))
        for q in q_values:
            H = qary_entropy(p, q)
            lengths = shannon_lengths(p, q)
            E = expected_length(p, lengths)
            redundancies[q].append(E - H)

    # Box plot of redundancies
    data = [redundancies[q] for q in q_values]
    bp = ax.boxplot(data, positions=list(q_values), widths=0.6,
                    patch_artist=True)

    colors = plt.cm.viridis(np.linspace(0.2, 0.8, len(q_values)))
    for patch, color in zip(bp['boxes'], colors):
        patch.set_facecolor(color)
        patch.set_alpha(0.7)

    ax.axhline(y=1.0, color='red', linestyle='--', linewidth=2,
               label='Upper bound (R < 1)')
    ax.axhline(y=0.0, color='green', linestyle='--', linewidth=1,
               label='Lower bound (R ≥ 0)')

    ax.set_xlabel('Code alphabet size q', fontsize=14)
    ax.set_ylabel('Redundancy R = E[ℓ] - H_q(p)', fontsize=14)
    ax.set_title('Coding Redundancy vs Alphabet Size\n(50 random 8-symbol distributions)',
                 fontsize=14, fontweight='bold')
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)

    return fig_to_base64(fig)


def plot_kraft_diagram():
    """Visualize the Kraft inequality as a stacked bar chart."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    p = [0.5, 0.25, 0.125, 0.125]
    symbols = ['a₁', 'a₂', 'a₃', 'a₄']

    for idx, q in enumerate([2, 3, 4]):
        ax = axes[idx]
        lengths = shannon_lengths(p, q)
        kraft_weights = [q**(-l) for l in lengths]
        K = sum(kraft_weights)

        # Stacked bar
        bottom = 0
        colors = ['#2196F3', '#FF5722', '#4CAF50', '#FFC107']
        for i, (w, s) in enumerate(zip(kraft_weights, symbols)):
            ax.bar(0, w, bottom=bottom, color=colors[i], label=f'{s}: q^(-{lengths[i]}) = {w:.4f}',
                   width=0.5, edgecolor='white', linewidth=1)
            bottom += w

        # Add the "1" line
        ax.axhline(y=1.0, color='red', linestyle='--', linewidth=2)
        ax.text(0.35, 1.02, 'Kraft bound = 1', color='red', fontsize=10)

        # Shade unused capacity
        if K < 1:
            ax.bar(0, 1-K, bottom=K, color='gray', alpha=0.2, width=0.5,
                   label=f'Slack: {1-K:.4f}')

        ax.set_xlim(-0.5, 1)
        ax.set_ylim(0, 1.15)
        ax.set_title(f'q = {q}: Kraft sum = {K:.4f}', fontsize=13)
        ax.set_ylabel('Cumulative Kraft weight', fontsize=11)
        ax.legend(fontsize=9, loc='upper right')
        ax.set_xticks([])
        ax.grid(True, alpha=0.3, axis='y')

    fig.suptitle('Kraft Inequality Visualization: ∑ q^{-ℓ(a)} ≤ 1',
                 fontsize=16, fontweight='bold', y=1.02)
    fig.tight_layout()

    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")

    img1 = plot_entropy_vs_base()
    print(f"  Entropy vs base: {len(img1)} chars")

    img2 = plot_shannon_bounds()
    print(f"  Shannon bounds: {len(img2)} chars")

    img3 = plot_coding_efficiency()
    print(f"  Coding efficiency: {len(img3)} chars")

    img4 = plot_kraft_diagram()
    print(f"  Kraft diagram: {len(img4)} chars")

    # Save as standalone HTML for inspection
    html = f"""<html><body>
    <h1>q-ary Source Coding Visualizations</h1>
    <h2>1. Entropy vs Base</h2><img src="{img1}">
    <h2>2. Shannon Bounds</h2><img src="{img2}">
    <h2>3. Coding Efficiency</h2><img src="{img3}">
    <h2>4. Kraft Inequality</h2><img src="{img4}">
    </body></html>"""

    with open("visualizations.html", "w") as f:
        f.write(html)

    print("\nAll visualizations generated successfully!")
    print("Open visualizations.html to view.")
