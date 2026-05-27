"""
Visualization: The SNF Correspondence Pipeline

This script visualizes the complete pipeline from graph to
Smith Normal Form to cokernel decomposition, showing each
step of the transformation.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from math import gcd

def graph_laplacian(adj):
    return np.diag(np.sum(adj, axis=1)) - adj

def _extended_gcd(a, b):
    if b == 0:
        return (1, 0) if a >= 0 else (-1, 0)
    old_r, r = a, b
    old_s, s = 1, 0
    old_t, t = 0, 1
    while r != 0:
        q = old_r // r
        old_r, r = r, old_r - q * r
        old_s, s = s, old_s - q * s
        old_t, t = t, old_t - q * t
    if old_r < 0:
        return -old_s, -old_t
    return old_s, old_t

def is_separated(adj, S):
    for i in range(len(S)):
        for j in range(i+1, len(S)):
            if adj[S[i],S[j]] != 0:
                return False
    return True

# Create a graph: modified path with extra connections
n = 6
adj = np.zeros((n, n), dtype=int)
edges = [(0,1), (1,2), (2,3), (3,4), (4,5), (0,2), (3,5)]
for i, j in edges:
    adj[i,j] = adj[j,i] = 1

S = [1, 4]  # Separated set

fig, axes = plt.subplots(2, 3, figsize=(18, 10))

# Step 1: Graph visualization
ax = axes[0, 0]
ax.set_xlim(-1.5, 1.5)
ax.set_ylim(-1.5, 1.5)
angles = np.linspace(0, 2*np.pi, n, endpoint=False)
pos = {i: (np.cos(a), np.sin(a)) for i, a in enumerate(angles)}

# Draw edges
for i, j in edges:
    x = [pos[i][0], pos[j][0]]
    y = [pos[i][1], pos[j][1]]
    ax.plot(x, y, 'k-', linewidth=1.5, alpha=0.5)

# Draw vertices
for i in range(n):
    color = '#FF5722' if i in S else '#2196F3'
    size = 400 if i in S else 300
    ax.scatter(*pos[i], c=color, s=size, zorder=5, edgecolors='black', linewidth=2)
    ax.annotate(f'v{i}\n(d={int(np.sum(adj[i]))})', pos[i], 
               textcoords="offset points", xytext=(0, 15),
               ha='center', fontsize=9, fontweight='bold')

ax.set_title('Step 1: Graph G\n(orange = separated set S)', 
            fontsize=12, fontweight='bold')
ax.set_aspect('equal')
ax.axis('off')

# Step 2: Full Laplacian
ax = axes[0, 1]
L = graph_laplacian(adj)
im = ax.imshow(L, cmap='RdBu_r', vmin=-2, vmax=4)
for i in range(n):
    for j in range(n):
        ax.text(j, i, str(L[i,j]), ha='center', va='center', fontsize=11,
               color='white' if abs(L[i,j]) > 1 else 'black')
# Highlight S rows/cols
for s in S:
    rect = plt.Rectangle((-0.5, s-0.5), n, 1, linewidth=2, 
                         edgecolor='#FF5722', facecolor='none', linestyle='--')
    ax.add_patch(rect)
    rect = plt.Rectangle((s-0.5, -0.5), 1, n, linewidth=2,
                         edgecolor='#FF5722', facecolor='none', linestyle='--')
    ax.add_patch(rect)
ax.set_title('Step 2: Laplacian L(G)\n(dashed = S rows/cols)', 
            fontsize=12, fontweight='bold')
ax.set_xticks(range(n))
ax.set_yticks(range(n))

# Step 3: Restricted Laplacian
ax = axes[0, 2]
idx = np.array(S)
L_S = L[np.ix_(idx, idx)]
k = len(S)

ax.imshow(L_S, cmap='RdBu_r', vmin=-2, vmax=4)
for i in range(k):
    for j in range(k):
        ax.text(j, i, str(L_S[i,j]), ha='center', va='center', fontsize=16,
               fontweight='bold', color='white' if abs(L_S[i,j]) > 1 else 'black')
ax.set_xticks(range(k))
ax.set_yticks(range(k))
ax.set_xticklabels([f'v{s}' for s in S])
ax.set_yticklabels([f'v{s}' for s in S])

is_diag = np.allclose(L_S - np.diag(np.diag(L_S)), 0)
status = "DIAGONAL ✓" if is_diag else "NOT DIAGONAL"
color = 'green' if is_diag else 'red'
ax.set_title(f'Step 3: Restricted L_S\n{status}', 
            fontsize=12, fontweight='bold', color=color)

# Step 4: Canonical generators
ax = axes[1, 0]
for idx_s, s in enumerate(S):
    gen = np.zeros(n, dtype=int)
    gen[s] = 1
    x_positions = np.arange(n) + idx_s * 0.3 - 0.15
    bars = ax.bar(x_positions, gen, width=0.25, 
                 label=f'Generator for v{s}',
                 alpha=0.8, edgecolor='black')
ax.set_xticks(range(n))
ax.set_xticklabels([f'v{i}' for i in range(n)])
ax.set_ylabel('Value')
ax.set_title('Step 4: Canonical Harmonic\nGenerators (indicators)', 
            fontsize=12, fontweight='bold')
ax.legend(fontsize=9)
ax.set_ylim(-0.2, 1.5)

# Step 5: Boundary restriction → standard basis
ax = axes[1, 1]
for idx_s, s in enumerate(S):
    restr = np.zeros(k, dtype=int)
    restr[idx_s] = 1
    x_positions = np.arange(k) + idx_s * 0.3 - 0.15
    ax.bar(x_positions, restr, width=0.25,
          label=f'e_{idx_s+1} (from v{s})',
          alpha=0.8, edgecolor='black')
ax.set_xticks(range(k))
ax.set_xticklabels([f'v{s}' for s in S])
ax.set_ylabel('Value')
ax.set_title('Step 5: Boundary Restrictions\n= Standard Basis Vectors', 
            fontsize=12, fontweight='bold')
ax.legend(fontsize=9)
ax.set_ylim(-0.2, 1.5)

# Step 6: Cokernel decomposition
ax = axes[1, 2]
degrees = [int(np.sum(adj[s])) for s in S]
det = int(np.prod(degrees))

# Draw cyclic groups as circles
theta = np.linspace(0, 2*np.pi, 100)
for idx_s, (s, d) in enumerate(zip(S, degrees)):
    cx = idx_s * 2.5
    cy = 0
    r = 0.8
    
    # Draw circle
    ax.plot(cx + r*np.cos(theta), cy + r*np.sin(theta), 'k-', linewidth=2)
    
    # Mark elements
    for elem in range(d):
        angle = 2 * np.pi * elem / d - np.pi/2
        ex = cx + r * np.cos(angle)
        ey = cy + r * np.sin(angle)
        ax.scatter(ex, ey, c='#FF5722', s=80, zorder=5, edgecolors='black')
        ax.annotate(str(elem), (ex, ey), textcoords="offset points",
                   xytext=(8, 0), fontsize=9)
    
    ax.text(cx, cy - 1.3, f'ℤ/{d}', ha='center', fontsize=14, fontweight='bold',
           color='#1565C0')
    ax.text(cx, cy + 1.2, f'v{s}\n(deg={d})', ha='center', fontsize=10)

# Add multiplication sign
if len(S) > 1:
    mid_x = (0 * 2.5 + 1 * 2.5) / 2
    ax.text(mid_x, 0, '×', ha='center', va='center', fontsize=24, fontweight='bold')

ax.set_xlim(-1.5, (len(S)-1)*2.5 + 1.5)
ax.set_ylim(-2, 2)
ax.set_title(f'Step 6: Cokernel Decomposition\n|Cok| = {det}', 
            fontsize=12, fontweight='bold')
ax.set_aspect('equal')
ax.axis('off')

plt.suptitle('The SNF Correspondence Pipeline: Graph → Laplacian → SNF → Cokernel',
            fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_snf_pipeline.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_snf_pipeline.png")
