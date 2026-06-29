#!/usr/bin/env python3
"""
Demonstration of the Fractal Dimension of Proof Search theory.

Computes search dimensions, difficulty ratios, and information rates
for various proof search scenarios, illustrating the main theoretical results.
"""

import math
from algorithms import (
    search_dimension,
    difficulty_ratio,
    information_rate,
    proof_complexity_landscape,
    composed_search_dimension,
    box_counting_dimension,
    universality_test,
    phase_diagram,
)


def demo_basic_dimensions():
    """Demonstrate search dimension computation for key cases."""
    print("=" * 60)
    print("SEARCH DIMENSION EXAMPLES")
    print("=" * 60)
    
    cases = [
        (10, 1, "Deterministic proof (unique path)"),
        (10, 2, "Very sparse search"),
        (10, 5, "Half branches survive"),
        (10, 8, "Most branches survive"),
        (10, 10, "Trivial theorem (all paths work)"),
        (2, 1, "Binary tree, one path"),
        (2, 2, "Binary tree, all paths"),
        (100, 10, "Wide tree, 10% survival"),
        (100, 50, "Wide tree, 50% survival"),
    ]
    
    print(f"\n{'Description':<40} {'b':>4} {'k':>4} {'D':>8} {'Phase':>12}")
    print("-" * 72)
    
    for b, k, desc in cases:
        D = search_dimension(b, k)
        if D == 0:
            phase = "deterministic"
        elif D == 1:
            phase = "trivial"
        elif D < 0.3:
            phase = "hard"
        elif D < 0.7:
            phase = "moderate"
        else:
            phase = "easy"
        print(f"{desc:<40} {b:>4} {k:>4} {D:>8.4f} {phase:>12}")


def demo_difficulty_ratios():
    """Show how difficulty grows exponentially with depth."""
    print("\n" + "=" * 60)
    print("DIFFICULTY RATIO VS DEPTH")
    print("=" * 60)
    
    b, k = 10, 3  # D ≈ 0.477
    D = search_dimension(b, k)
    print(f"\nBranching factor b={b}, survival k={k}, dimension D={D:.4f}")
    print(f"Expected candidates per proof: (b/k)^d = ({b}/{k})^d\n")
    
    print(f"{'Depth d':>8} {'Total paths':>15} {'Successful':>15} {'Difficulty':>15}")
    print("-" * 55)
    
    for d in [1, 2, 3, 5, 10, 20]:
        total = b ** d
        successful = k ** d
        diff = difficulty_ratio(b, k, d)
        print(f"{d:>8} {total:>15,} {successful:>15,} {diff:>15,.1f}")


def demo_information_theory():
    """Demonstrate the information-theoretic interpretation."""
    print("\n" + "=" * 60)
    print("INFORMATION RATE PER PROOF STEP")
    print("=" * 60)
    
    b = 10
    print(f"\nBranching factor b={b}")
    print(f"Full entropy per step: log₂({b}) = {math.log2(b):.4f} bits\n")
    
    print(f"{'k':>4} {'D':>8} {'Info rate':>12} {'Fraction':>10}")
    print("-" * 38)
    
    for k in range(1, b + 1):
        D = search_dimension(b, k)
        rate = information_rate(b, k)
        frac = rate / math.log2(b) if math.log2(b) > 0 else 0
        print(f"{k:>4} {D:>8.4f} {rate:>10.4f} b {frac:>9.1%}")


def demo_composition():
    """Demonstrate how proof difficulty composes."""
    print("\n" + "=" * 60)
    print("COMPOSITION OF PROOF SEARCHES")
    print("=" * 60)
    
    scenarios = [
        ((10, 3, 5, 10, 7, 3), "Hard lemma + easy application"),
        ((10, 8, 3, 10, 2, 10), "Easy setup + hard core"),
        ((10, 5, 5, 10, 5, 5), "Two moderate steps"),
        ((2, 1, 10, 2, 2, 10), "Deterministic + trivial"),
    ]
    
    for (b1, k1, d1, b2, k2, d2), desc in scenarios:
        D1 = search_dimension(b1, k1)
        D2 = search_dimension(b2, k2)
        D_comp = composed_search_dimension(b1, k1, d1, b2, k2, d2)
        total_space = b1**d1 * b2**d2
        successful = k1**d1 * k2**d2
        
        print(f"\n{desc}:")
        print(f"  Step 1: b={b1}, k={k1}, d={d1}, D₁={D1:.4f}")
        print(f"  Step 2: b={b2}, k={k2}, d={d2}, D₂={D2:.4f}")
        print(f"  Composed: D={D_comp:.4f}")
        print(f"  Total search space: {total_space:,.0f}")
        print(f"  Successful paths:   {successful:,.0f}")
        print(f"  Difficulty ratio:   {total_space/successful:,.1f}")


def demo_phase_transition():
    """Demonstrate the phase transition."""
    print("\n" + "=" * 60)
    print("PHASE TRANSITION DIAGRAM (b=20)")
    print("=" * 60)
    
    b = 20
    diagram = phase_diagram(b)
    
    print(f"\n{'k':>4} {'D':>8} {'Phase':>15} {'Visual':>25}")
    print("-" * 55)
    
    for k, D, phase in diagram:
        bar_len = int(D * 20)
        bar = "█" * bar_len + "░" * (20 - bar_len)
        print(f"{k:>4} {D:>8.4f} {phase:>15} {bar}")


def demo_universality():
    """Test the universality conjecture with synthetic data."""
    print("\n" + "=" * 60)
    print("UNIVERSALITY CONJECTURE TEST (Synthetic Data)")
    print("=" * 60)
    
    # Generate synthetic data with D = 1 - 2/n + noise
    import random
    random.seed(42)
    
    c_true = 2.0
    statement_lengths = [n for n in range(5, 105, 5)]
    dimensions = [1 - c_true / n + random.gauss(0, 0.03) for n in statement_lengths]
    dimensions = [max(0, min(1, d)) for d in dimensions]
    
    c_est, r2, resid = universality_test(statement_lengths, dimensions)
    
    print(f"\nTrue c = {c_true:.4f}")
    print(f"Estimated c = {c_est:.4f}")
    print(f"R² = {r2:.4f}")
    print(f"Residual std = {resid:.4f}")
    
    print(f"\nPrediction: (1 - D) * n should be ≈ {c_true:.1f}")
    print(f"\n{'n':>6} {'D_obs':>8} {'D_pred':>8} {'(1-D)*n':>10}")
    print("-" * 35)
    for n, d in list(zip(statement_lengths, dimensions))[:10]:
        d_pred = 1 - c_est / n
        product = (1 - d) * n
        print(f"{n:>6} {d:>8.4f} {d_pred:>8.4f} {product:>10.4f}")


def demo_box_counting():
    """Demonstrate box-counting dimension estimation."""
    print("\n" + "=" * 60)
    print("BOX-COUNTING DIMENSION ESTIMATION")
    print("=" * 60)
    
    b, k = 10, 4
    true_D = search_dimension(b, k)
    
    depths = list(range(1, 8))
    successful = [k ** d for d in depths]
    total = [b ** d for d in depths]
    
    estimated_D = box_counting_dimension(successful, total)
    
    print(f"\nb={b}, k={k}")
    print(f"True dimension: {true_D:.6f}")
    print(f"Estimated dimension: {estimated_D:.6f}")
    print(f"Error: {abs(estimated_D - true_D):.6f}")
    
    print(f"\n{'Depth':>6} {'Successful':>15} {'Total':>15} {'log ratio':>12}")
    print("-" * 50)
    for d, s, t in zip(depths, successful, total):
        ratio = math.log(s) / math.log(t) if t > 1 else 0
        print(f"{d:>6} {s:>15,} {t:>15,} {ratio:>12.6f}")


if __name__ == "__main__":
    demo_basic_dimensions()
    demo_difficulty_ratios()
    demo_information_theory()
    demo_composition()
    demo_phase_transition()
    demo_universality()
    demo_box_counting()
    
    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Fractal Structure of Proof Search Trees

Renders proof search trees with successful paths highlighted,
showing how the fractal dimension manifests visually.
"""

import math
import random
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def generate_tree(b: int, k: int, d: int, seed: int = 42) -> dict:
    """Generate a selective branching tree.
    
    Returns a dict mapping (level, index) to (is_successful, children_indices).
    """
    rng = random.Random(seed)
    tree = {}
    
    # Root is always successful
    tree[(0, 0)] = {'success': True, 'children': []}
    
    for level in range(d):
        nodes_at_level = [(l, i) for (l, i) in tree if l == level and tree[(l, i)]['success']]
        
        for node_key in nodes_at_level:
            # Generate b children, mark k as successful
            children = list(range(b))
            successful_children = set(rng.sample(children, min(k, b)))
            
            child_keys = []
            base_idx = node_key[1] * b
            for c in children:
                child_key = (level + 1, base_idx + c)
                tree[child_key] = {
                    'success': c in successful_children,
                    'children': []
                }
                child_keys.append(child_key)
            
            tree[node_key]['children'] = child_keys
    
    return tree


def draw_tree(ax, b: int, k: int, d: int, title: str):
    """Draw a tree visualization on the given axes."""
    tree = generate_tree(b, k, d)
    
    # Compute positions
    positions = {}
    for level in range(d + 1):
        nodes = sorted([(l, i) for (l, i) in tree if l == level], key=lambda x: x[1])
        n = len(nodes)
        for idx, node in enumerate(nodes):
            x = (idx + 0.5) / max(n, 1)
            y = 1 - level / max(d, 1)
            positions[node] = (x, y)
    
    # Draw edges
    for node_key, node_data in tree.items():
        if node_key in positions:
            x1, y1 = positions[node_key]
            for child_key in node_data['children']:
                if child_key in positions:
                    x2, y2 = positions[child_key]
                    color = 'green' if tree[child_key]['success'] else 'lightgray'
                    alpha = 0.8 if tree[child_key]['success'] else 0.3
                    linewidth = 1.5 if tree[child_key]['success'] else 0.5
                    ax.plot([x1, x2], [y1, y2], color=color, alpha=alpha,
                            linewidth=linewidth)
    
    # Draw nodes
    for node_key in positions:
        x, y = positions[node_key]
        color = 'darkgreen' if tree[node_key]['success'] else 'lightgray'
        size = 15 if tree[node_key]['success'] else 5
        ax.plot(x, y, 'o', color=color, markersize=size / (node_key[0] + 1),
                alpha=0.8)
    
    D = math.log(k) / math.log(b) if b > 1 else 1
    ax.set_title(f'{title}\nb={b}, k={k}, D={D:.3f}', fontsize=11)
    ax.set_xlim(-0.05, 1.05)
    ax.set_ylim(-0.05, 1.05)
    ax.axis('off')


def main():
    fig, axes = plt.subplots(2, 3, figsize=(15, 10))
    
    # Different dimension regimes
    configs = [
        (3, 1, 4, "D=0: Deterministic"),
        (4, 2, 3, "D≈0.5: Moderate"),
        (3, 3, 4, "D=1: Trivial"),
        (5, 1, 3, "D=0: Narrow search"),
        (5, 3, 3, "D≈0.68: Wide search"),
        (4, 3, 3, "D≈0.79: Nearly trivial"),
    ]
    
    for idx, (b, k, d, title) in enumerate(configs):
        row, col = divmod(idx, 3)
        draw_tree(axes[row][col], b, k, d, title)
    
    fig.suptitle('Fractal Structure of Proof Search Trees\n'
                 'Green = successful paths, Gray = dead ends',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('fractal_trees.png', dpi=150, bbox_inches='tight')
    print("Saved fractal_trees.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Phase Transition in Proof Search Dimension

Shows how the search dimension D = log(k)/log(b) varies with the
survival fraction k/b, revealing the three phases of proof difficulty.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def search_dimension(b: int, k: int) -> float:
    if k <= 0 or b <= 1:
        return 0.0
    return math.log(k) / math.log(b)


def main():
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    # Plot 1: Dimension vs survival fraction for different b
    ax1 = axes[0]
    for b in [2, 5, 10, 20, 100]:
        ks = list(range(1, b + 1))
        fracs = [k / b for k in ks]
        dims = [search_dimension(b, k) for k in ks]
        ax1.plot(fracs, dims, 'o-' if b <= 10 else '-', label=f'b={b}', 
                 markersize=3, alpha=0.8)
    
    ax1.set_xlabel('Survival fraction k/b', fontsize=12)
    ax1.set_ylabel('Search dimension D', fontsize=12)
    ax1.set_title('Search Dimension vs Survival Fraction', fontsize=13)
    ax1.legend(fontsize=9)
    ax1.set_xlim(0, 1.05)
    ax1.set_ylim(-0.05, 1.05)
    ax1.axhline(y=1, color='gray', linestyle='--', alpha=0.5)
    ax1.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
    
    # Shade the three phases
    ax1.axhspan(0.8, 1.05, alpha=0.1, color='green', label='_trivial')
    ax1.axhspan(-0.05, 0.2, alpha=0.1, color='red', label='_hard')
    ax1.text(0.9, 0.95, 'Trivial', fontsize=9, ha='center', color='green')
    ax1.text(0.1, 0.05, 'Hard', fontsize=9, ha='center', color='red')
    
    # Plot 2: Difficulty ratio vs depth for different dimensions
    ax2 = axes[1]
    b = 10
    depths = np.arange(1, 16)
    for k in [1, 2, 3, 5, 7, 9]:
        D = search_dimension(b, k)
        difficulties = [(b / k) ** d for d in depths]
        ax2.semilogy(depths, difficulties, 'o-', markersize=4,
                     label=f'k={k}, D={D:.2f}')
    
    ax2.set_xlabel('Proof depth d', fontsize=12)
    ax2.set_ylabel('Difficulty ratio (b/k)^d', fontsize=12)
    ax2.set_title('Difficulty Growth with Depth (b=10)', fontsize=13)
    ax2.legend(fontsize=8)
    ax2.grid(True, alpha=0.3)
    
    # Plot 3: Information rate vs dimension
    ax3 = axes[2]
    b = 10
    ks = list(range(1, b + 1))
    dims = [search_dimension(b, k) for k in ks]
    info_rates = [math.log2(b) * (1 - D) for D in dims]
    landscape_5 = [5 * (1 - D) for D in dims]
    landscape_10 = [10 * (1 - D) for D in dims]
    
    ax3.plot(dims, info_rates, 'bo-', markersize=6, label='Info rate (bits/step)')
    ax3.plot(dims, landscape_5, 'rs--', markersize=4, label='Landscape d=5')
    ax3.plot(dims, landscape_10, 'g^--', markersize=4, label='Landscape d=10')
    
    ax3.set_xlabel('Search dimension D', fontsize=12)
    ax3.set_ylabel('Value', fontsize=12)
    ax3.set_title('Information Rate & Complexity Landscape', fontsize=13)
    ax3.legend(fontsize=9)
    ax3.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('phase_transition.png', dpi=150, bbox_inches='tight')
    print("Saved phase_transition.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Universality Conjecture Test

Generates synthetic data following D(T) = 1 - c/n and visualizes
the fit, showing the universality conjecture prediction.
"""

import math
import random
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def search_dimension(b: int, k: int) -> float:
    if k <= 0 or b <= 1:
        return 0.0
    return math.log(k) / math.log(b)


def universality_test(statement_lengths, estimated_dimensions):
    products = [(1 - d) * n for n, d in zip(statement_lengths, estimated_dimensions)
                if n > 0]
    c_estimate = sum(products) / len(products) if products else 0
    mean_d = sum(estimated_dimensions) / len(estimated_dimensions)
    ss_tot = sum((d - mean_d) ** 2 for d in estimated_dimensions)
    ss_res = sum((d - (1 - c_estimate / n)) ** 2 
                 for n, d in zip(statement_lengths, estimated_dimensions) if n > 0)
    r_squared = 1 - ss_res / ss_tot if ss_tot > 0 else 0.0
    return c_estimate, r_squared


def main():
    random.seed(42)
    
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))
    
    # Generate synthetic data
    c_true = 2.5
    n_values = list(range(3, 101))
    D_values = [max(0, min(1, 1 - c_true / n + random.gauss(0, 0.05))) 
                for n in n_values]
    
    c_est, r2 = universality_test(n_values, D_values)
    
    # Plot 1: D vs n with fit
    ax1 = axes[0][0]
    ax1.scatter(n_values, D_values, alpha=0.5, s=20, color='blue', label='Data')
    n_smooth = np.linspace(3, 100, 200)
    D_fit = [1 - c_est / n for n in n_smooth]
    ax1.plot(n_smooth, D_fit, 'r-', linewidth=2, 
             label=f'Fit: D = 1 - {c_est:.2f}/n')
    D_true = [1 - c_true / n for n in n_smooth]
    ax1.plot(n_smooth, D_true, 'g--', linewidth=1, alpha=0.7,
             label=f'True: D = 1 - {c_true:.2f}/n')
    ax1.set_xlabel('Statement length n', fontsize=12)
    ax1.set_ylabel('Search dimension D', fontsize=12)
    ax1.set_title(f'Universality Conjecture (R²={r2:.4f})', fontsize=13)
    ax1.legend(fontsize=10)
    ax1.set_ylim(-0.1, 1.1)
    ax1.grid(True, alpha=0.3)
    
    # Plot 2: (1-D)*n should be constant
    ax2 = axes[0][1]
    products = [(1 - d) * n for n, d in zip(n_values, D_values)]
    ax2.scatter(n_values, products, alpha=0.5, s=20, color='purple')
    ax2.axhline(y=c_est, color='red', linewidth=2, 
                label=f'Mean = {c_est:.2f}')
    ax2.axhline(y=c_true, color='green', linestyle='--', linewidth=1,
                label=f'True c = {c_true:.2f}')
    ax2.set_xlabel('Statement length n', fontsize=12)
    ax2.set_ylabel('(1 - D) × n', fontsize=12)
    ax2.set_title('Universality Product (should be constant)', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    
    # Plot 3: Difficulty vs statement length
    ax3 = axes[1][0]
    b = 10
    d_proof = 20  # fixed proof depth
    for c_val, color, label in [(1.0, 'blue', 'c=1'), (2.5, 'red', 'c=2.5'), 
                                  (5.0, 'green', 'c=5')]:
        n_range = np.linspace(5, 100, 100)
        difficulties = [b ** (d_proof * c_val / n) for n in n_range]
        ax3.semilogy(n_range, difficulties, color=color, linewidth=2, label=label)
    
    ax3.set_xlabel('Statement length n', fontsize=12)
    ax3.set_ylabel('Search difficulty b^{d(1-D)}', fontsize=12)
    ax3.set_title('Difficulty vs Statement Length (b=10, d=20)', fontsize=13)
    ax3.legend(fontsize=10)
    ax3.grid(True, alpha=0.3)
    
    # Plot 4: Histogram of dimensions
    ax4 = axes[1][1]
    ax4.hist(D_values, bins=20, color='steelblue', alpha=0.7, edgecolor='black')
    ax4.axvline(x=np.mean(D_values), color='red', linewidth=2, 
                label=f'Mean D = {np.mean(D_values):.3f}')
    ax4.set_xlabel('Search dimension D', fontsize=12)
    ax4.set_ylabel('Count', fontsize=12)
    ax4.set_title('Distribution of Search Dimensions', fontsize=13)
    ax4.legend(fontsize=10)
    
    plt.suptitle('Fractal Dimension of Proof Search: Universality Analysis',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('universality_test.png', dpi=150, bbox_inches='tight')
    print("Saved universality_test.png")


if __name__ == "__main__":
    main()
