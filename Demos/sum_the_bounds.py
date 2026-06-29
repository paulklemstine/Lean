#!/usr/bin/env python3
"""
Applications of the Extensive Complexity Accumulation framework.

Demonstrates how the summation bound theorems apply to:
1. Information theory (block coding length)
2. Neural network certification
3. Topological persistence
4. Symbolic decomposition
5. Error-correcting codes
"""

import random
import math

random.seed(42)


def application_block_coding():
    """
    Application 1: Block Coding in Information Theory

    A source emits symbols from an alphabet of size k with given probabilities.
    Each symbol is encoded with a prefix-free code. Shannon's theorem bounds
    the expected code length per symbol by H + 1 where H is the entropy.

    The extensivity theorem gives: T symbols cost at most T * (H + 1) bits total.
    """
    print("=" * 60)
    print("APPLICATION 1: Block Coding Length Budget")
    print("=" * 60)

    # Source with 4 symbols
    probs = [0.5, 0.25, 0.125, 0.125]
    entropy = -sum(p * math.log2(p) for p in probs)
    C = math.ceil(entropy) + 1  # Per-symbol bound (Shannon + 1)

    print(f"  Source entropy H = {entropy:.4f} bits")
    print(f"  Per-symbol code length bound C = {C} bits")

    for T in [10, 100, 1000, 10000]:
        # Simulate actual code lengths (between ceil(H) and C)
        actual_lengths = [random.randint(1, C) for _ in range(T)]
        total = sum(actual_lengths)
        bound = T * C
        print(f"  T={T:>6}: actual total = {total:>7}, bound T*C = {bound:>7}, "
              f"ratio = {total/bound:.3f}")

    print()


def application_neural_certification():
    """
    Application 2: Neural Network Layer-wise Certification

    A neural network with L layers, where each layer's verification
    certificate has bounded complexity. Total certification cost
    is at most L * C_max.
    """
    print("=" * 60)
    print("APPLICATION 2: Neural Network Certification Budget")
    print("=" * 60)

    for L, C_max in [(10, 50), (50, 100), (100, 200), (500, 150)]:
        # Each layer's actual certificate complexity
        cert_costs = [random.randint(10, C_max) for _ in range(L)]
        total = sum(cert_costs)
        bound = L * C_max
        print(f"  L={L:>4} layers, C_max={C_max:>4}: "
              f"total cert cost = {total:>7}, bound = {bound:>7}, "
              f"ratio = {total/bound:.3f}")

    print()


def application_persistence():
    """
    Application 3: Total Persistence in Topological Data Analysis

    A persistence diagram has n features, each with lifetime ≤ max_life.
    Total persistence ≤ n * max_life.
    """
    print("=" * 60)
    print("APPLICATION 3: Topological Persistence Budget")
    print("=" * 60)

    for n, max_life in [(20, 1.0), (100, 0.5), (500, 2.0), (1000, 0.1)]:
        lifetimes = [random.uniform(0, max_life) for _ in range(n)]
        total_persistence = sum(lifetimes)
        bound = n * max_life
        print(f"  n={n:>5} features, max_life={max_life:.1f}: "
              f"total persistence = {total_persistence:>8.2f}, "
              f"bound = {bound:>8.2f}, ratio = {total_persistence/bound:.3f}")

    print()


def application_symbolic_decomposition():
    """
    Application 4: Symbolic Decomposition Pipeline

    An expression is decomposed through T stages. Each stage's
    decomposition has bounded length. Total symbolic cost is linear.
    """
    print("=" * 60)
    print("APPLICATION 4: Symbolic Decomposition Cost")
    print("=" * 60)

    for T, C in [(5, 10), (10, 20), (20, 15), (50, 8)]:
        # Monotonically bounded decomposition lengths (inspired by Ritt)
        stage_costs = [random.randint(1, C) for _ in range(T)]
        total = sum(stage_costs)
        bound = T * C
        print(f"  T={T:>3} stages, max cost={C:>3}: "
              f"total cost = {total:>5}, bound = {bound:>5}, "
              f"ratio = {total/bound:.3f}")

    print()


def application_golay_transmission():
    """
    Application 5: Golay Code Transmission

    Transmitting T blocks of Golay-encoded data (24 symbols per block).
    Total transmission length is exactly T * 24.
    """
    print("=" * 60)
    print("APPLICATION 5: Golay Code Transmission Length")
    print("=" * 60)

    GOLAY_BLOCK_LENGTH = 24  # = 2 * 12, from golay_code_length

    for T in [1, 10, 100, 1000, 10000]:
        total = T * GOLAY_BLOCK_LENGTH
        print(f"  T={T:>6} blocks: total length = {total:>7} "
              f"(= {T} × {GOLAY_BLOCK_LENGTH})")

    print()


def application_cross_domain_summary():
    """
    Summary: Cross-domain complexity accumulation.
    """
    print("=" * 60)
    print("SUMMARY: Cross-Domain Complexity Accumulation")
    print("=" * 60)

    domains = [
        ("Information Theory", "per-symbol code length", "total encoding bits"),
        ("Neural Certification", "per-layer cert complexity", "total verification cost"),
        ("Topological Persistence", "per-feature lifetime", "total persistence mass"),
        ("Symbolic Algebra", "per-stage decomposition length", "total symbolic cost"),
        ("Error-Correcting Codes", "per-block code length", "total transmission length"),
    ]

    print()
    print("  All domains share the same mathematical structure:")
    print("  ∀ t < T, ℓ(t) ≤ C  ⟹  ∑_{t<T} ℓ(t) ≤ T × C")
    print()

    for domain, local_quantity, global_quantity in domains:
        print(f"  {domain:.<30s} {local_quantity:.<30s} → {global_quantity}")

    print()
    print("  This is the EXTENSIVITY PRINCIPLE:")
    print("  Bounded local complexity implies linear global complexity.")
    print()


if __name__ == "__main__":
    application_block_coding()
    application_neural_certification()
    application_persistence()
    application_symbolic_decomposition()
    application_golay_transmission()
    application_cross_domain_summary()


#!/usr/bin/env python3
"""
Demonstration of the Extensive Complexity Accumulation theorems.

This script provides concrete numerical examples verifying the summation
bounds formalized in Bridges/SumBounds.lean.
"""

import random
import math

random.seed(42)


def demo_uniform_bound():
    """Demonstrate: if ℓ(t) ≤ C for all t < T, then ∑ ℓ(t) ≤ T * C."""
    print("=" * 60)
    print("DEMO 1: Uniform Horizon Bound (ℕ version)")
    print("=" * 60)

    cases = [
        (10, 5),
        (100, 8),
        (1000, 3),
        (50, 24),  # Golay-inspired
    ]

    for T, C in cases:
        lengths = [random.randint(0, C) for _ in range(T)]
        total = sum(lengths)
        bound = T * C
        ratio = total / bound if bound > 0 else 0
        print(f"  T={T:>5}, C={C:>3}: ∑ℓ = {total:>6}, T*C = {bound:>6}, "
              f"ratio = {ratio:.3f}, bound holds: {total <= bound}")

    print()


def demo_golay_blocks():
    """Demonstrate: T Golay blocks have total length exactly T * 24."""
    print("=" * 60)
    print("DEMO 2: Golay Code Block Length")
    print("=" * 60)

    for T in [1, 5, 10, 100, 1000]:
        total = sum(24 for _ in range(T))
        expected = T * 24
        print(f"  T={T:>5}: ∑24 = {total:>6}, T*24 = {expected:>6}, "
              f"exact: {total == expected}")

    print()


def demo_pointwise_comparison():
    """Demonstrate: if f(a) ≤ g(a) pointwise, then ∑f ≤ ∑g."""
    print("=" * 60)
    print("DEMO 3: Pointwise Comparison Principle")
    print("=" * 60)

    T = 20
    g = [random.randint(5, 15) for _ in range(T)]
    f = [random.randint(0, gi) for gi in g]

    sum_f = sum(f)
    sum_g = sum(g)
    print(f"  T = {T}")
    print(f"  f = {f}")
    print(f"  g = {g}")
    print(f"  ∑f = {sum_f}, ∑g = {sum_g}, ∑f ≤ ∑g: {sum_f <= sum_g}")

    print()


def demo_bridge_theorem():
    """Demonstrate: ℓ(t) ≤ b(t) ≤ C implies ∑ℓ ≤ T*C."""
    print("=" * 60)
    print("DEMO 4: Bridge Theorem (Composing Bound Generators)")
    print("=" * 60)

    T = 30
    C = 10

    # b(t) is the theoretical per-step bound (from some catalog theorem)
    b = [random.randint(3, C) for _ in range(T)]
    # ℓ(t) is the actual length, bounded by b(t)
    ell = [random.randint(0, bi) for bi in b]

    sum_ell = sum(ell)
    sum_b = sum(b)
    bound = T * C

    print(f"  T = {T}, C = {C}")
    print(f"  ∑ℓ = {sum_ell}, ∑b = {sum_b}, T*C = {bound}")
    print(f"  ℓ(t) ≤ b(t) for all t: {all(l <= bi for l, bi in zip(ell, b))}")
    print(f"  b(t) ≤ C for all t:    {all(bi <= C for bi in b)}")
    print(f"  ∑ℓ ≤ T*C:              {sum_ell <= bound}")

    print()


def demo_real_valued():
    """Demonstrate: real-valued version with expected lengths."""
    print("=" * 60)
    print("DEMO 5: Real-Valued Horizon Bound")
    print("=" * 60)

    T = 50
    C = 3.7  # e.g., entropy bound from tropical coding

    lengths = [random.uniform(0, C) for _ in range(T)]
    total = sum(lengths)
    bound = T * C

    print(f"  T = {T}, C = {C:.2f}")
    print(f"  ∑ℓ = {total:.4f}")
    print(f"  T*C = {bound:.4f}")
    print(f"  ratio = {total/bound:.4f}")
    print(f"  bound holds: {total <= bound}")

    print()


def demo_tightness():
    """Analyze tightness of the bound across many random instances."""
    print("=" * 60)
    print("DEMO 6: Tightness Analysis")
    print("=" * 60)

    T = 100
    C = 10
    n_trials = 10000

    ratios = []
    for _ in range(n_trials):
        lengths = [random.randint(0, C) for _ in range(T)]
        ratio = sum(lengths) / (T * C)
        ratios.append(ratio)

    avg_ratio = sum(ratios) / len(ratios)
    min_ratio = min(ratios)
    max_ratio = max(ratios)

    print(f"  T = {T}, C = {C}, trials = {n_trials}")
    print(f"  Average ratio ∑ℓ/(T*C): {avg_ratio:.4f} (expected ≈ 0.5)")
    print(f"  Min ratio: {min_ratio:.4f}")
    print(f"  Max ratio: {max_ratio:.4f}")
    print(f"  All bounds hold: {all(r <= 1.0 for r in ratios)}")

    print()


if __name__ == "__main__":
    demo_uniform_bound()
    demo_golay_blocks()
    demo_pointwise_comparison()
    demo_bridge_theorem()
    demo_real_valued()
    demo_tightness()

    print("All demonstrations completed successfully.")


#!/usr/bin/env python3
"""Generate PACKAGE.json with all artifacts."""

import json
import sys
sys.path.insert(0, '.')

from visualizations import generate_all

# Read files
def read_file(path):
    with open(path, 'r') as f:
        return f.read()

article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
lean_proofs = read_file('Bridges/SumBounds.lean')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')

# Generate visualizations
viz_data = generate_all()

package = {
    "title": "Extensive Complexity Accumulation: Summation Bounds for Certified Length",
    "domain": "Cross-Domain Mathematics (Information Theory, Neural Certification, Topology, Algebra, Coding Theory)",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Summation Bound Demonstrations",
            "code": demo_code
        },
        {
            "name": "Cross-Domain Applications",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Uniform Sum Bound",
            "pseudocode": "INPUT: lengths[0..T-1], bound C\nVERIFY: for each t, lengths[t] <= C\nCOMPUTE: total = sum(lengths)\nOUTPUT: total <= T * C",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {
            "name": "Horizon Bound: Actual Sum vs T×C",
            "data": viz_data.get("horizon_bound", "")
        },
        {
            "name": "Tightness Distribution",
            "data": viz_data.get("tightness_distribution", "")
        },
        {
            "name": "Cross-Domain Extensivity",
            "data": viz_data.get("cross_domain", "")
        },
        {
            "name": "Bridge Theorem Visualization",
            "data": viz_data.get("bridge_theorem", "")
        }
    ],
    "lean_proofs": lean_proofs
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print("PACKAGE.json generated successfully.")


#!/usr/bin/env python3
"""
Visualizations for the Extensive Complexity Accumulation framework.

Generates matplotlib figures saved as PNG files.
"""

import random
import math
import base64
import io

random.seed(42)

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    import matplotlib.patches as mpatches
    HAS_MPL = True
except ImportError:
    HAS_MPL = False


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"


def viz_horizon_bound():
    """Visualize the horizon bound: actual sum vs T*C."""
    if not HAS_MPL:
        return None

    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    C = 8
    Ts = list(range(1, 51))
    bounds = [T * C for T in Ts]

    # Multiple random trials
    for trial in range(5):
        totals = []
        for T in Ts:
            lengths = [random.randint(0, C) for _ in range(T)]
            totals.append(sum(lengths))
        ax.plot(Ts, totals, alpha=0.5, linewidth=1, color='steelblue')

    ax.plot(Ts, bounds, 'r-', linewidth=2.5, label=f'Bound: T × C = T × {C}')
    ax.fill_between(Ts, 0, bounds, alpha=0.1, color='red')

    ax.set_xlabel('Horizon T', fontsize=13)
    ax.set_ylabel('Total Length', fontsize=13)
    ax.set_title('Horizon Bound: ∑ℓ(t) ≤ T × C', fontsize=15)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)

    return fig_to_base64(fig)


def viz_tightness_distribution():
    """Visualize distribution of tightness ratios."""
    if not HAS_MPL:
        return None

    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    T = 100
    C = 10
    n_trials = 5000

    ratios = []
    for _ in range(n_trials):
        lengths = [random.randint(0, C) for _ in range(T)]
        ratios.append(sum(lengths) / (T * C))

    ax.hist(ratios, bins=50, color='steelblue', edgecolor='white', alpha=0.8, density=True)
    ax.axvline(x=0.5, color='red', linewidth=2, linestyle='--', label='Expected ratio = 0.5')
    ax.axvline(x=1.0, color='darkred', linewidth=2, label='Bound (ratio = 1.0)')

    ax.set_xlabel('Tightness Ratio ∑ℓ / (T×C)', fontsize=13)
    ax.set_ylabel('Density', fontsize=13)
    ax.set_title(f'Tightness Distribution (T={T}, C={C}, {n_trials} trials)', fontsize=15)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)

    return fig_to_base64(fig)


def viz_cross_domain():
    """Visualize cross-domain complexity accumulation."""
    if not HAS_MPL:
        return None

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    domains = [
        ("Information Theory", "Symbol index", "Code length"),
        ("Neural Certification", "Layer index", "Certificate size"),
        ("Persistence", "Feature index", "Lifetime"),
        ("Golay Coding", "Block index", "Block length"),
    ]

    Cs = [5, 100, 2.0, 24]
    Ts = [30, 20, 40, 25]

    for ax, (name, xlabel, ylabel), C, T in zip(axes.flat, domains, Cs, Ts):
        if name == "Golay Coding":
            values = [C] * T
        else:
            values = [random.uniform(0.2 * C, C) for _ in range(T)]

        indices = list(range(T))
        ax.bar(indices, values, color='steelblue', alpha=0.7, label='Actual')
        ax.axhline(y=C, color='red', linewidth=2, linestyle='--', label=f'Bound C={C}')
        ax.set_xlabel(xlabel, fontsize=11)
        ax.set_ylabel(ylabel, fontsize=11)
        ax.set_title(name, fontsize=13, fontweight='bold')
        ax.legend(fontsize=9)
        ax.grid(True, alpha=0.3)

    fig.suptitle('Extensivity Principle Across Domains', fontsize=16, fontweight='bold')
    plt.tight_layout()

    return fig_to_base64(fig)


def viz_bridge_theorem():
    """Visualize the bridge theorem: ℓ ≤ b ≤ C."""
    if not HAS_MPL:
        return None

    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    T = 25
    C = 10

    b = [random.randint(4, C) for _ in range(T)]
    ell = [random.randint(0, bi) for bi in b]

    indices = list(range(T))
    width = 0.35

    bars1 = ax.bar([i - width/2 for i in indices], ell, width,
                   color='steelblue', alpha=0.8, label='ℓ(t) — actual length')
    bars2 = ax.bar([i + width/2 for i in indices], b, width,
                   color='orange', alpha=0.6, label='b(t) — intermediate bound')
    ax.axhline(y=C, color='red', linewidth=2.5, linestyle='--',
               label=f'C = {C} — uniform bound')

    ax.set_xlabel('Time step t', fontsize=13)
    ax.set_ylabel('Length / Bound', fontsize=13)
    ax.set_title('Bridge Theorem: ℓ(t) ≤ b(t) ≤ C ⟹ ∑ℓ ≤ T×C', fontsize=15)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    return fig_to_base64(fig)


def generate_all():
    """Generate all visualizations and return as dict."""
    results = {}

    viz_funcs = [
        ("horizon_bound", viz_horizon_bound),
        ("tightness_distribution", viz_tightness_distribution),
        ("cross_domain", viz_cross_domain),
        ("bridge_theorem", viz_bridge_theorem),
    ]

    for name, func in viz_funcs:
        data = func()
        if data:
            results[name] = data
            print(f"Generated: {name}")
        else:
            print(f"Skipped (no matplotlib): {name}")

    return results


if __name__ == "__main__":
    results = generate_all()
    print(f"\nGenerated {len(results)} visualizations.")
