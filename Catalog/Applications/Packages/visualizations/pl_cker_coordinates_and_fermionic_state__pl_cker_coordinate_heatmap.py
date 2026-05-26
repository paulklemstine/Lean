# Visualization: Plücker Coordinate Heatmap
# 
# This script visualizes the squared Plücker amplitudes (basis probabilities)
# for a rank-2 matroid on 5 elements, showing which 2-element subsets are
# matroid bases (nonzero amplitude) and their relative probabilities.

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations

def minor_det(A, S):
    return np.linalg.det(A[:, list(S)])

def main():
    # Rank-2 matroid on 5 elements
    A = np.array([[1, 0, 1, 2, -1],
                   [0, 1, 1, 1,  2]], dtype=float)
    r, n = A.shape
    
    # Compute all 2-subsets and their squared amplitudes
    subsets = list(combinations(range(n), r))
    labels = [f"{{{s[0]},{s[1]}}}" for s in subsets]
    amplitudes = [minor_det(A, S) for S in subsets]
    sq_amplitudes = [a**2 for a in amplitudes]
    
    gram_det = np.linalg.det(A @ A.T)
    probabilities = [a / gram_det for a in sq_amplitudes]
    
    # Create heatmap-style visualization
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))
    
    # Plot 1: Squared amplitudes as bar chart
    ax = axes[0]
    colors = ['#2ecc71' if p > 1e-10 else '#e74c3c' for p in probabilities]
    bars = ax.bar(range(len(subsets)), sq_amplitudes, color=colors, edgecolor='black', linewidth=0.5)
    ax.set_xticks(range(len(subsets)))
    ax.set_xticklabels(labels, rotation=45, ha='right', fontsize=9)
    ax.set_ylabel('|det(A_S)|²', fontsize=12)
    ax.set_title('Squared Plücker Amplitudes', fontsize=13, fontweight='bold')
    ax.set_xlabel('2-subset S', fontsize=11)
    
    # Plot 2: Probability distribution (normalized)
    ax = axes[1]
    nonzero_idx = [i for i, p in enumerate(probabilities) if p > 1e-10]
    nonzero_labels = [labels[i] for i in nonzero_idx]
    nonzero_probs = [probabilities[i] for i in nonzero_idx]
    
    wedges, texts, autotexts = ax.pie(nonzero_probs, labels=nonzero_labels,
                                       autopct='%1.1f%%', startangle=90,
                                       colors=plt.cm.Set3(np.linspace(0, 1, len(nonzero_probs))))
    ax.set_title('Slater Basis Distribution\n(Born Probabilities)', fontsize=13, fontweight='bold')
    
    # Plot 3: 5x5 projection kernel heatmap
    ax = axes[2]
    K = A.T @ np.linalg.inv(A @ A.T) @ A
    im = ax.imshow(K, cmap='RdBu_r', vmin=-1, vmax=1, aspect='equal')
    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    ax.set_xlabel('Column index', fontsize=11)
    ax.set_ylabel('Column index', fontsize=11)
    ax.set_title('Projection Kernel K\n(One-Particle Correlations)', fontsize=13, fontweight='bold')
    for i in range(n):
        for j in range(n):
            ax.text(j, i, f'{K[i,j]:.2f}', ha='center', va='center', fontsize=8,
                    color='white' if abs(K[i,j]) > 0.5 else 'black')
    plt.colorbar(im, ax=ax, shrink=0.8)
    
    plt.suptitle('Fermionic Plücker Coordinates: Rank-2 Matroid on [5]',
                 fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('viz_plucker_heatmap.png', dpi=150, bbox_inches='tight')
    print("Saved viz_plucker_heatmap.png")

if __name__ == "__main__":
    main()
