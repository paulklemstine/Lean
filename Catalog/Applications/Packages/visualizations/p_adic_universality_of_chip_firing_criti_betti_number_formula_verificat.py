"""
Visualization: Betti Number Formula Verification

Verifies the theorem b₁(G̃) + (n-1) = n · b₁(G) for graph lifts across
multiple base graphs and sheet counts. Shows perfect agreement between
computed and predicted Betti numbers.
"""

import numpy as np
import matplotlib.pyplot as plt
import random


# ============================================================
# Self-contained algorithms
# ============================================================

def rand_lift(edges, nv, ns):
    volt = {}
    for u,v in edges:
        p = list(range(ns)); random.shuffle(p); volt[(u,v)]=p
        inv=[0]*ns
        for i,j in enumerate(p): inv[j]=i
        volt[(v,u)]=inv
    le=set(); ln=nv*ns
    for u,v in edges:
        for i in range(ns):
            j=volt[(u,v)][i]
            e=(min(u*ns+i,v*ns+j),max(u*ns+i,v*ns+j))
            le.add(e)
    return list(le), ln

def connected(edges, nv):
    if nv==0: return True
    adj={i:[] for i in range(nv)}
    for u,v in edges: adj[u].append(v); adj[v].append(u)
    vis=set([0]); q=[0]
    while q:
        nd=q.pop(0)
        for nb in adj[nd]:
            if nb not in vis: vis.add(nb); q.append(nb)
    return len(vis)==nv

def betti(edges, nv):
    return len(edges) - nv + 1


# ============================================================
# Graph constructors
# ============================================================

def K(n):
    return [(i,j) for i in range(n) for j in range(i+1,n)], n

def cycle(n):
    return [(i,(i+1)%n) for i in range(n)], n

def prism():
    return [(0,1),(1,2),(2,0),(3,4),(4,5),(5,3),(0,3),(1,4),(2,5)], 6

def petersen():
    outer = [(i,(i+1)%5) for i in range(5)]
    inner = [(5+i,5+(i+2)%5) for i in range(5)]
    spokes = [(i,5+i) for i in range(5)]
    return outer+inner+spokes, 10


# ============================================================
# Run experiments
# ============================================================

random.seed(42)

graphs = {
    'K₃ (b₁=1)': K(3),
    'K₄ (b₁=3)': K(4),
    'K₅ (b₁=6)': K(5),
    'C₅ (b₁=1)': cycle(5),
    'Prism (b₁=3)': prism(),
    'Petersen (b₁=6)': petersen(),
}

sheet_counts = [2, 3, 4, 5, 6, 7]

fig, axes = plt.subplots(2, 3, figsize=(15, 9))
axes = axes.flatten()

for idx, (name, (edges, nv)) in enumerate(graphs.items()):
    ax = axes[idx]
    b1_base = betti(edges, nv)

    computed_b1 = []
    predicted_b1 = []
    ns_values = []

    for ns in sheet_counts:
        # Try a few times to get a connected lift
        for _ in range(50):
            le, ln = rand_lift(edges, nv, ns)
            if connected(le, ln):
                b1_lift = betti(le, ln)
                pred = ns * b1_base - (ns - 1)
                computed_b1.append(b1_lift)
                predicted_b1.append(pred)
                ns_values.append(ns)
                break

    ax.plot(ns_values, predicted_b1, 'r-o', label='Predicted: n·b₁-(n-1)',
            markersize=8, linewidth=2, zorder=5)
    ax.plot(ns_values, computed_b1, 'bx', label='Computed b₁(G̃)',
            markersize=12, markeredgewidth=3, zorder=10)

    ax.set_xlabel('Number of sheets (n)', fontsize=11)
    ax.set_ylabel('b₁(G̃)', fontsize=11)
    ax.set_title(name, fontsize=13, fontweight='bold')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Check if all match
    match = all(c == p for c, p in zip(computed_b1, predicted_b1))
    status = "✓ All match" if match else "✗ Mismatch!"
    ax.annotate(status, xy=(0.05, 0.92), xycoords='axes fraction',
                fontsize=10, fontweight='bold',
                color='green' if match else 'red',
                bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))

fig.suptitle('Betti Number Formula Verification: b₁(G̃) = n·b₁(G) − (n−1)',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_betti_formula.png', dpi=150, bbox_inches='tight')
print("Saved viz_betti_formula.png")
