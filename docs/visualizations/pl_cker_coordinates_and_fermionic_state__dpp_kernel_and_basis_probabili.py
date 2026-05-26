# Visualization: DPP Kernel and Basis Probabilities
#
# This script visualizes the determinantal point process structure of a
# rank-3 matroid on 6 elements, showing how the projection kernel K
# determines all basis probabilities via det(K_S).

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations

def main():
    np.random.seed(7)
    
    # Rank-3 matroid on 6 elements
    A = np.array([[1, 0, 0, 1, 1, 2],
                   [0, 1, 0, 1, -1, 1],
                   [0, 0, 1, 0, 1, -1]], dtype=float)
    r, n = A.shape
    
    # Compute key objects
    gram = A @ A.T
    gram_det_val = np.linalg.det(gram)
    K = A.T @ np.linalg.inv(gram) @ A
    
    # Compute all 3-subsets
    subsets = list(combinations(range(n), r))
    
    slater_probs = []
    dpp_probs = []
    labels = []
    
    for S in subsets:
        idx = list(S)
        det_S = np.linalg.det(A[:, idx])
        slater_p = det_S**2 / gram_det_val
        dpp_p = np.linalg.det(K[np.ix_(idx, idx)])
        slater_probs.append(slater_p)
        dpp_probs.append(dpp_p)
        labels.append(f"{{{S[0]},{S[1]},{S[2]}}}")
    
    fig, axes = plt.subplots(2, 2, figsize=(14, 11))
    
    # Plot 1: K heatmap
    ax = axes[0, 0]
    im = ax.imshow(K, cmap='coolwarm', vmin=-0.8, vmax=0.8)
    ax.set_title('Projection Kernel K = Aᵀ(AAᵀ)⁻¹A', fontsize=12, fontweight='bold')
    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    for i in range(n):
        for j in range(n):
            ax.text(j, i, f'{K[i,j]:.2f}', ha='center', va='center', fontsize=9,
                    color='white' if abs(K[i,j]) > 0.4 else 'black')
    plt.colorbar(im, ax=ax, shrink=0.8)
    
    # Plot 2: Eigenvalues of K
    ax = axes[0, 1]
    eigs = np.sort(np.linalg.eigvalsh(K))[::-1]
    ax.bar(range(n), eigs, color=['#2ecc71' if e > 0.5 else '#bdc3c7' for e in eigs],
           edgecolor='black', linewidth=0.5)
    ax.set_xticks(range(n))
    ax.set_xlabel('Eigenvalue index', fontsize=11)
    ax.set_ylabel('Eigenvalue', fontsize=11)
    ax.set_title(f'Eigenvalues of K\n(rank = {r}, trace = {np.trace(K):.1f})', fontsize=12, fontweight='bold')
    ax.axhline(y=0.5, color='red', linestyle='--', alpha=0.5)
    ax.set_ylim(-0.1, 1.2)
    
    # Plot 3: Comparison of Slater vs DPP probabilities
    ax = axes[1, 0]
    x = np.arange(len(subsets))
    width = 0.35
    bars1 = ax.bar(x - width/2, slater_probs, width, label='det(A_S)²/det(AAᵀ)',
                   color='#3498db', alpha=0.8, edgecolor='black', linewidth=0.5)
    bars2 = ax.bar(x + width/2, dpp_probs, width, label='det(K_S)',
                   color='#e74c3c', alpha=0.8, edgecolor='black', linewidth=0.5)
    ax.set_xticks(x)
    ax.set_xticklabels(labels, rotation=45, ha='right', fontsize=8)
    ax.set_ylabel('Probability', fontsize=11)
    ax.set_title('Slater vs DPP Probabilities', fontsize=12, fontweight='bold')
    ax.legend(fontsize=9)
    
    # Plot 4: Scatter plot (should be on y=x line)
    ax = axes[1, 1]
    ax.scatter(slater_probs, dpp_probs, c='#9b59b6', s=50, edgecolors='black',
               linewidth=0.5, zorder=5)
    max_val = max(max(slater_probs), max(dpp_probs)) * 1.1
    ax.plot([0, max_val], [0, max_val], 'k--', linewidth=1, alpha=0.5, label='Perfect agreement')
    ax.set_xlabel('Slater: det(A_S)²/det(AAᵀ)', fontsize=11)
    ax.set_ylabel('DPP: det(K_S)', fontsize=11)
    ax.set_title('DPP Identity Verification', fontsize=12, fontweight='bold')
    ax.set_aspect('equal')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    
    max_err = max(abs(s - d) for s, d in zip(slater_probs, dpp_probs))
    ax.text(0.05, 0.95, f'Max error: {max_err:.1e}', transform=ax.transAxes,
            fontsize=10, verticalalignment='top',
            bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))
    
    plt.suptitle('Determinantal Point Process Structure of a Rank-3 Matroid on [6]',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('viz_dpp_kernel.png', dpi=150, bbox_inches='tight')
    print("Saved viz_dpp_kernel.png")

if __name__ == "__main__":
    main()
