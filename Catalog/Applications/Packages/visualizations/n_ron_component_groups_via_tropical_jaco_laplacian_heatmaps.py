#!/usr/bin/env python3
"""
Visualization 1: Laplacian Heatmaps and Component Group Structure

Visualizes graph Laplacians, their reduced forms, and the resulting
component group invariant factors for several classical graphs.
Shows the relationship between matrix structure and arithmetic invariants.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def smith_normal_form_factors(A):
    """Compute SNF invariant factors of an integer matrix."""
    M = A.copy().astype(int)
    m, n = M.shape
    r = min(m, n)
    for k in range(r):
        found = False
        for i in range(k, m):
            for j in range(k, n):
                if M[i][j] != 0:
                    M[[k, i]] = M[[i, k]]
                    M[:, [k, j]] = M[:, [j, k]]
                    found = True
                    break
            if found: break
        if not found: break
        if M[k][k] < 0: M[k] = -M[k]
        changed = True
        while changed:
            changed = False
            for i in range(k+1, m):
                if M[i][k] != 0:
                    q = M[i][k] // M[k][k]
                    M[i] -= q * M[k]
                    if M[i][k] != 0 and abs(M[i][k]) < abs(M[k][k]):
                        M[[k,i]] = M[[i,k]]
                        if M[k][k] < 0: M[k] = -M[k]
                        changed = True
            for j in range(k+1, n):
                if M[k][j] != 0:
                    q = M[k][j] // M[k][k]
                    M[:, j] -= q * M[:, k]
                    if M[k][j] != 0 and abs(M[k][j]) < abs(M[k][k]):
                        M[:, [k,j]] = M[:, [j,k]]
                        if M[k][k] < 0: M[k] = -M[k]
                        changed = True
            for i in range(k+1, m):
                for j in range(k+1, n):
                    if M[k][k] != 0 and M[i][j] % M[k][k] != 0:
                        M[i] += M[k]
                        changed = True
                        break
                if changed: break
    return [abs(M[i][i]) for i in range(r) if M[i][i] != 0]

# Define test graphs
graphs = {
    'K₃ (Triangle)': np.array([[2,-1,-1],[-1,2,-1],[-1,-1,2]]),
    'K₄ (Complete)': np.array([[3,-1,-1,-1],[-1,3,-1,-1],[-1,-1,3,-1],[-1,-1,-1,3]]),
    'C₅ (Cycle)': np.array([[2,-1,0,0,-1],[-1,2,-1,0,0],[0,-1,2,-1,0],[0,0,-1,2,-1],[-1,0,0,-1,2]]),
    'Banana(3)': np.array([[3,-3],[-3,3]]),
}

fig, axes = plt.subplots(2, 4, figsize=(18, 9))
fig.suptitle('Graph Laplacians → Component Groups via Tropical Jacobians',
             fontsize=16, fontweight='bold', y=0.98)

for idx, (name, L) in enumerate(graphs.items()):
    n = L.shape[0]
    L_red = L[1:, 1:]
    det_val = int(round(np.linalg.det(L_red)))
    factors = smith_normal_form_factors(L_red)
    nontrivial = [d for d in factors if d > 1]
    
    # Full Laplacian heatmap
    ax1 = axes[0, idx]
    im1 = ax1.imshow(L, cmap='RdBu_r', interpolation='nearest', 
                      vmin=-max(abs(L.min()), L.max()), 
                      vmax=max(abs(L.min()), L.max()))
    ax1.set_title(f'{name}\nFull Laplacian', fontsize=11)
    for i in range(n):
        for j in range(n):
            ax1.text(j, i, str(L[i,j]), ha='center', va='center', fontsize=10,
                    color='white' if abs(L[i,j]) > max(abs(L.min()), L.max())*0.6 else 'black')
    ax1.set_xticks(range(n))
    ax1.set_yticks(range(n))
    
    # Reduced Laplacian heatmap
    ax2 = axes[1, idx]
    im2 = ax2.imshow(L_red, cmap='RdBu_r', interpolation='nearest',
                      vmin=-max(abs(L_red.min()), L_red.max()),
                      vmax=max(abs(L_red.min()), L_red.max()))
    
    group_str = ' × '.join(f'ℤ/{d}ℤ' for d in nontrivial) if nontrivial else '0'
    ax2.set_title(f'Reduced L (v₀=0)\ndet = {abs(det_val)}, Φ_J ≅ {group_str}', fontsize=10)
    for i in range(n-1):
        for j in range(n-1):
            ax2.text(j, i, str(L_red[i,j]), ha='center', va='center', fontsize=10,
                    color='white' if abs(L_red[i,j]) > max(abs(L_red.min()), L_red.max())*0.6 else 'black')
    ax2.set_xticks(range(n-1))
    ax2.set_yticks(range(n-1))

plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('visualize_laplacian.png', dpi=150, bbox_inches='tight')
print("Saved: visualize_laplacian.png")
