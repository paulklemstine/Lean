#!/usr/bin/env python3
"""
Visualization: Collision probability heatmap for random Beurling systems.

Shows how collision probability varies with the number of generators
and the upper bound N.
"""

import math
import random

def random_beurling_generators(n, seed=42):
    rng = random.Random(seed)
    gens = []
    for k in range(2, n + 1):
        prob = 1.0 / max(math.log(k), 0.01)
        if rng.random() < min(prob, 1.0):
            gens.append(k)
    return gens

def is_product_free(generators):
    gen_set = set(generators)
    for a in generators:
        for b in generators:
            if a * b in gen_set:
                return False
    return True

def main():
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
        import numpy as np
    except ImportError:
        print("matplotlib/numpy not available, skipping visualization")
        return

    # Compute collision probability for different N values
    N_values = [20, 40, 60, 80, 100, 150, 200, 300, 500]
    trials = 200
    
    collision_probs = []
    avg_gen_counts = []
    
    for N in N_values:
        collisions = 0
        gen_counts = []
        for seed in range(trials):
            gens = random_beurling_generators(N, seed=seed)
            gen_counts.append(len(gens))
            if not is_product_free(gens):
                collisions += 1
        collision_probs.append(collisions / trials)
        avg_gen_counts.append(sum(gen_counts) / len(gen_counts))
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    
    # Plot 1: Collision probability vs N
    ax1.plot(N_values, collision_probs, 'ro-', linewidth=2, markersize=8)
    ax1.axhline(y=1.0, color='gray', linestyle='--', alpha=0.5)
    ax1.set_xlabel('Upper bound N', fontsize=12)
    ax1.set_ylabel('P(collision exists)', fontsize=12)
    ax1.set_title('Collision Probability for Random Beurling Systems', fontsize=14)
    ax1.set_ylim(-0.05, 1.05)
    ax1.grid(True, alpha=0.3)
    
    # Plot 2: Generator count comparison
    expected_primes = [N / math.log(N) if N > 1 else 0 for N in N_values]
    
    ax2.plot(N_values, avg_gen_counts, 'bo-', label='Random generators (avg)', 
             linewidth=2, markersize=8)
    ax2.plot(N_values, expected_primes, 'g--', label='n/log(n) (PNT)', 
             linewidth=2)
    ax2.set_xlabel('Upper bound N', fontsize=12)
    ax2.set_ylabel('Count', fontsize=12)
    ax2.set_title('Generator Density: Random vs PNT Prediction', fontsize=14)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('collision_heatmap.png', dpi=150, bbox_inches='tight')
    print("Saved collision_heatmap.png")

if __name__ == "__main__":
    main()
