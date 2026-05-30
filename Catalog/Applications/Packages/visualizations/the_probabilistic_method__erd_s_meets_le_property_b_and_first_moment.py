"""
Visualization: Property B and the First Moment Method

Illustrates how the first moment method works for hypergraph 2-coloring:
- Shows the threshold 2^{k-1} for Property B
- Demonstrates the probability of finding a good coloring via random search
- Compares theoretical bounds with empirical success rates
"""

import math
import random
import matplotlib.pyplot as plt
import numpy as np

def property_b_empirical(n, k, num_edges, num_trials=1000):
    """Empirically estimate the probability of Property B.
    
    Generate random k-uniform hypergraphs with num_edges edges
    on n vertices, and check how often a random 2-coloring works.
    """
    successes = 0
    for _ in range(num_trials):
        # Generate random hypergraph
        vertices = list(range(n))
        edges = []
        for _ in range(num_edges):
            edge = tuple(sorted(random.sample(vertices, k)))
            edges.append(edge)
        
        # Try random 2-coloring
        coloring = [random.randint(0, 1) for _ in range(n)]
        proper = True
        for edge in edges:
            colors = {coloring[v] for v in edge}
            if len(colors) == 1:
                proper = False
                break
        if proper:
            successes += 1
    
    return successes / num_trials

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Plot 1: Property B threshold
k_values = range(2, 13)
thresholds = [2 ** (k - 1) for k in k_values]

axes[0].semilogy(list(k_values), thresholds, 'bo-', linewidth=2, markersize=8)
axes[0].fill_between(list(k_values), [0.5] * len(thresholds), thresholds, alpha=0.2, color='green',
                     label='Property B guaranteed')
axes[0].fill_between(list(k_values), thresholds, [t * 10 for t in thresholds], alpha=0.2, color='red',
                     label='No guarantee')
axes[0].set_xlabel('k (uniformity)', fontsize=13)
axes[0].set_ylabel('Number of edges', fontsize=13)
axes[0].set_title('Property B Threshold: 2^{k-1}', fontsize=14)
axes[0].legend(fontsize=11)
axes[0].grid(True, alpha=0.3)

# Plot 2: Success probability vs number of edges
n = 20
for k, color in [(3, '#e74c3c'), (4, '#3498db'), (5, '#2ecc71')]:
    threshold = 2 ** (k - 1)
    edge_counts = list(range(1, min(4 * threshold, 50)))
    probs = []
    for m in edge_counts:
        # Theoretical: prob of one coloring being good ≈ (1 - 2/2^k)^m
        p_good = (1 - 2 / 2**k) ** m
        probs.append(p_good)
    
    axes[1].plot(edge_counts, probs, '-', color=color, linewidth=2, label=f'k={k}')
    axes[1].axvline(x=threshold, color=color, linestyle=':', alpha=0.5)

axes[1].axhline(y=0, color='black', linewidth=0.5)
axes[1].set_xlabel('Number of edges', fontsize=13)
axes[1].set_ylabel('P(random coloring is proper)', fontsize=13)
axes[1].set_title('Success Probability vs Edge Count', fontsize=14)
axes[1].legend(fontsize=11)
axes[1].grid(True, alpha=0.3)
axes[1].set_ylim(-0.05, 1.05)

# Plot 3: First moment method illustration
# Show how expected bad events vs threshold determines existence
n_vals = np.linspace(0.1, 3, 100)
expected_bad = n_vals  # E[X]
prob_exists = np.where(expected_bad < 1, 1 - expected_bad, 0)

axes[2].fill_between(n_vals, 0, prob_exists, alpha=0.3, color='green', label='Good outcome guaranteed')
axes[2].plot(n_vals, expected_bad, 'r-', linewidth=2, label='E[bad events]')
axes[2].plot(n_vals, prob_exists, 'g-', linewidth=2, label='P(good outcome) lower bound')
axes[2].axvline(x=1, color='black', linestyle='--', alpha=0.5, label='Threshold E[X]=1')
axes[2].axhline(y=0, color='black', linewidth=0.5)

axes[2].set_xlabel('E[number of bad events]', fontsize=13)
axes[2].set_ylabel('Probability', fontsize=13)
axes[2].set_title('First Moment Method', fontsize=14)
axes[2].legend(fontsize=10)
axes[2].grid(True, alpha=0.3)
axes[2].set_xlim(0, 3)
axes[2].set_ylim(-0.1, 2.5)

plt.tight_layout()
plt.savefig('property_b.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved property_b.png")
