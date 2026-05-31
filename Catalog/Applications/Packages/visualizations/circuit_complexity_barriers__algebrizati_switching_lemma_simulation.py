"""
Visualization: Random Restriction and Switching Lemma

Demonstrates how random restrictions reduce formula depth,
illustrating the foundation of AC⁰ lower bounds.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import random


def simulate_restriction_depth(n_vars, depth, keep_prob, n_trials=2000):
    """Simulate depth reduction under random restrictions.

    Build a complete binary AND/OR tree of given depth on n_vars variables,
    then apply random restrictions and measure resulting depth.
    """
    depths_after = []
    for _ in range(n_trials):
        # Count how many levels survive
        # At each level, both children must have free variables to maintain depth
        surviving_depth = 0
        current_leaves = 2 ** depth
        for d in range(depth):
            # Each leaf survives with probability keep_prob
            surviving = sum(1 for _ in range(current_leaves)
                          if random.random() < keep_prob)
            if surviving >= 2:
                surviving_depth += 1
                current_leaves = surviving
            else:
                break
        depths_after.append(surviving_depth)
    return depths_after


def plot_switching():
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Left: Distribution of depth after restriction
    ax1 = axes[0]
    keep_probs = [0.1, 0.3, 0.5, 0.7]
    depth = 5
    n_vars = 32

    for p in keep_probs:
        depths = simulate_restriction_depth(n_vars, depth, p, 3000)
        unique_depths = sorted(set(depths))
        counts = [depths.count(d) / len(depths) for d in unique_depths]
        ax1.bar([d + keep_probs.index(p) * 0.15 - 0.225 for d in unique_depths],
               counts, width=0.14, alpha=0.8, label=f'p={p}')

    ax1.set_xlabel('Depth After Restriction', fontsize=12)
    ax1.set_ylabel('Probability', fontsize=12)
    ax1.set_title('Depth Reduction Under Random Restrictions', fontsize=13)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3, axis='y')

    # Middle: Expected depth vs keep probability
    ax2 = axes[1]
    probs = np.linspace(0.01, 0.99, 50)
    for d in [3, 4, 5, 6]:
        expected = []
        for p in probs:
            depths = simulate_restriction_depth(32, d, p, 500)
            expected.append(np.mean(depths))
        ax2.plot(probs, expected, '-', label=f'depth={d}', linewidth=2)

    ax2.set_xlabel('Keep Probability (p)', fontsize=12)
    ax2.set_ylabel('Expected Depth After Restriction', fontsize=12)
    ax2.set_title('Expected Depth vs Keep Probability', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    # Right: Switching lemma bound vs empirical
    ax3 = axes[2]
    t = 3  # CNF width
    s_values = range(1, 7)

    for p in [0.05, 0.1, 0.15]:
        bound = [(5 * p * t) ** s for s in s_values]
        ax3.semilogy(list(s_values), bound, 'o--', label=f'(5pt)^s, p={p}',
                    markersize=5)

    ax3.axhline(y=1, color='black', linestyle='-', alpha=0.3)
    ax3.set_xlabel('Target Depth (s)', fontsize=12)
    ax3.set_ylabel('Probability Bound', fontsize=12)
    ax3.set_title('Switching Lemma Bound (width t=3)', fontsize=13)
    ax3.legend(fontsize=10)
    ax3.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_switching.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_switching.png")


if __name__ == "__main__":
    plot_switching()
