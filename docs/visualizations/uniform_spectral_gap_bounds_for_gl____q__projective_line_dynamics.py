#!/usr/bin/env python3
"""
Visualization: Singer-Like Projective Dynamics on ℙ¹(𝔽_q)

Illustrates our Theorem 2: Singer-like elements fix no point on the
projective line. Shows the permutation action as a directed graph,
demonstrating the fixed-point-free orbit structure that drives expansion.

The key mathematical point: irreducible characteristic polynomial ⟹
no eigenvalue in the base field ⟹ no fixed projective point ⟹
mixing on the projective line ⟹ spectral expansion.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from itertools import product


def mod_inverse(a, p):
    return pow(a % p, p - 2, p) % p

def mat_det(A, q):
    return int((A[0, 0] * A[1, 1] - A[0, 1] * A[1, 0]) % q)

def charpoly_irreducible(A, q):
    tr = int((A[0, 0] + A[1, 1]) % q)
    det = mat_det(A, q)
    for x in range(q):
        if (x * x - tr * x + det) % q == 0:
            return False
    return True

def is_singer_like(A, q):
    return mat_det(A, q) != 0 and charpoly_irreducible(A, q)

def projective_action(M, point, q):
    a, b = point
    na = (M[0,0]*a + M[0,1]*b) % q
    nb = (M[1,0]*a + M[1,1]*b) % q
    if na != 0:
        return (1, (nb * mod_inverse(na, q)) % q)
    return (0, 1)


def find_singer(q):
    for a, b, c, d in product(range(q), repeat=4):
        M = np.array([[a, b], [c, d]])
        if is_singer_like(M, q):
            return M
    return None


def find_non_singer(q):
    """Find a non-Singer-like invertible matrix (has eigenvalue in 𝔽_q)."""
    for a, b, c, d in product(range(q), repeat=4):
        M = np.array([[a, b], [c, d]])
        det = mat_det(M, q)
        if det != 0 and not charpoly_irreducible(M, q):
            return M
    return None


fig, axes = plt.subplots(2, 3, figsize=(16, 11))

for col, q in enumerate([5, 7, 11]):
    points = [(1, b) for b in range(q)] + [(0, 1)]
    n = len(points)
    
    # Layout on a circle
    angles = np.linspace(0, 2*np.pi, n, endpoint=False)
    x_pos = np.cos(angles)
    y_pos = np.sin(angles)
    
    labels = []
    for p in points:
        if p[0] == 0:
            labels.append('∞')
        else:
            labels.append(str(p[1]))
    
    # Top row: Singer-like (no fixed points)
    singer = find_singer(q)
    ax = axes[0, col]
    
    if singer is not None:
        ax.set_xlim(-1.6, 1.6)
        ax.set_ylim(-1.6, 1.6)
        ax.set_aspect('equal')
        
        # Draw arrows for the permutation
        fixed_count = 0
        for i, p in enumerate(points):
            img = projective_action(singer, p, q)
            j = points.index(img)
            if i == j:
                fixed_count += 1
            
            # Draw arrow
            dx = x_pos[j] - x_pos[i]
            dy = y_pos[j] - y_pos[i]
            length = np.sqrt(dx**2 + dy**2)
            if length > 0.01:
                ax.annotate('', xy=(x_pos[j]*0.88, y_pos[j]*0.88),
                           xytext=(x_pos[i]*0.88, y_pos[i]*0.88),
                           arrowprops=dict(arrowstyle='->', color='blue',
                                         lw=1.5, alpha=0.6))
        
        # Draw points
        for i in range(n):
            ax.plot(x_pos[i], y_pos[i], 'o', color='royalblue', markersize=12, zorder=5)
            ax.text(x_pos[i]*1.2, y_pos[i]*1.2, labels[i], ha='center', va='center',
                   fontsize=10, fontweight='bold')
        
        tr = int((singer[0,0] + singer[1,1]) % q)
        det = mat_det(singer, q)
        ax.set_title(f'Singer-like on ℙ¹(𝔽_{q})\nχ(X) = X² - {tr}X + {det}\n'
                    f'Fixed points: {fixed_count} ✓', fontsize=11)
    ax.axis('off')
    
    # Bottom row: Non-Singer (has fixed points)
    non_singer = find_non_singer(q)
    ax = axes[1, col]
    
    if non_singer is not None:
        ax.set_xlim(-1.6, 1.6)
        ax.set_ylim(-1.6, 1.6)
        ax.set_aspect('equal')
        
        fixed_count = 0
        fixed_indices = []
        for i, p in enumerate(points):
            img = projective_action(non_singer, p, q)
            j = points.index(img)
            if i == j:
                fixed_count += 1
                fixed_indices.append(i)
            
            dx = x_pos[j] - x_pos[i]
            dy = y_pos[j] - y_pos[i]
            length = np.sqrt(dx**2 + dy**2)
            if length > 0.01:
                ax.annotate('', xy=(x_pos[j]*0.88, y_pos[j]*0.88),
                           xytext=(x_pos[i]*0.88, y_pos[i]*0.88),
                           arrowprops=dict(arrowstyle='->', color='red',
                                         lw=1.5, alpha=0.6))
        
        for i in range(n):
            color = 'red' if i in fixed_indices else 'salmon'
            size = 14 if i in fixed_indices else 12
            ax.plot(x_pos[i], y_pos[i], 'o', color=color, markersize=size, zorder=5)
            ax.text(x_pos[i]*1.2, y_pos[i]*1.2, labels[i], ha='center', va='center',
                   fontsize=10, fontweight='bold')
        
        tr = int((non_singer[0,0] + non_singer[1,1]) % q)
        det = mat_det(non_singer, q)
        ax.set_title(f'Non-Singer on ℙ¹(𝔽_{q})\nχ(X) = X² - {tr}X + {det}\n'
                    f'Fixed points: {fixed_count} (has eigenvalue)', fontsize=11)
    ax.axis('off')

# Add legend
singer_patch = mpatches.Patch(color='royalblue', label='Singer-like: 0 fixed points (Theorem 2)')
non_singer_patch = mpatches.Patch(color='red', label='Non-Singer: has fixed points (has eigenvalue in 𝔽_q)')
fig.legend(handles=[singer_patch, non_singer_patch], loc='lower center', 
          ncol=2, fontsize=12, bbox_to_anchor=(0.5, -0.02))

plt.suptitle('Projective Line Dynamics: Singer vs Non-Singer Elements',
            fontsize=16, fontweight='bold')
plt.tight_layout(rect=[0, 0.03, 1, 0.95])
plt.savefig('projective_dynamics.png', dpi=150, bbox_inches='tight')
print("Saved projective_dynamics.png")
