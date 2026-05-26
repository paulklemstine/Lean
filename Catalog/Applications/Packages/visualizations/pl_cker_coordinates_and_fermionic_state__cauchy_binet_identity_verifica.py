# Visualization: Cauchy-Binet Identity Verification
#
# This script visually demonstrates the Cauchy-Binet identity by comparing
# det(A D_w A^T) with the sum of weighted squared minors for many random
# matrices, showing perfect agreement.

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations

def plucker_mass_direct(A, w):
    r, n = A.shape
    total = 0.0
    for S in combinations(range(n), r):
        det_S = np.linalg.det(A[:, list(S)])
        weight_prod = np.prod([w[i] for i in S])
        total += det_S**2 * weight_prod
    return total

def gram_det(A, w):
    return np.linalg.det(A @ np.diag(w) @ A.T)

def main():
    np.random.seed(123)
    
    configs = [(2, 4), (2, 5), (2, 6), (3, 5), (3, 6)]
    n_samples = 50
    
    fig, axes = plt.subplots(1, len(configs), figsize=(20, 4))
    
    for idx, (r, n) in enumerate(configs):
        ax = axes[idx]
        
        gram_vals = []
        plucker_vals = []
        
        for _ in range(n_samples):
            A = np.random.randn(r, n)
            w = np.abs(np.random.randn(n)) + 0.1
            
            g = gram_det(A, w)
            p = plucker_mass_direct(A, w)
            gram_vals.append(g)
            plucker_vals.append(p)
        
        gram_vals = np.array(gram_vals)
        plucker_vals = np.array(plucker_vals)
        
        ax.scatter(gram_vals, plucker_vals, alpha=0.7, s=20, c='#3498db', edgecolors='#2c3e50', linewidth=0.5)
        
        # Perfect agreement line
        lim = max(max(gram_vals), max(plucker_vals)) * 1.1
        ax.plot([0, lim], [0, lim], 'r--', linewidth=1, alpha=0.8, label='y = x')
        
        # Error statistics
        max_err = np.max(np.abs(gram_vals - plucker_vals))
        
        ax.set_xlabel('det(A D_w A^T)', fontsize=10)
        ax.set_ylabel('Σ det(A_S)² ∏w_i', fontsize=10)
        ax.set_title(f'r={r}, n={n}\nmax error: {max_err:.1e}', fontsize=11)
        ax.set_aspect('equal')
        ax.legend(fontsize=8)
        ax.grid(True, alpha=0.3)
    
    plt.suptitle('Cauchy-Binet Identity: det(A D_w A^T) = Σ det(A_S)² ∏ w_i',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('viz_cauchy_binet.png', dpi=150, bbox_inches='tight')
    print("Saved viz_cauchy_binet.png")

if __name__ == "__main__":
    main()
