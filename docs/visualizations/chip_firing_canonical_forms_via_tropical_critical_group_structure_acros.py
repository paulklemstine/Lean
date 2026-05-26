#!/usr/bin/env python3
"""
Visualization: Critical Group Structure Across Graph Families

Shows how the critical group structure varies across different
graph families, illustrating the relationship between graph
topology and algebraic invariants.

Visualizes:
1. Critical group orders for cycle and complete graphs
2. Invariant factor decomposition heatmap
3. Spanning tree count = critical group order (Kirchhoff's theorem)
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def graph_laplacian(adj):
    return np.diag(adj.sum(axis=1).astype(int)) - adj.astype(int)


def smith_normal_form_diag(M):
    M = np.array(M, dtype=np.int64).copy()
    rows, cols = M.shape
    min_dim = min(rows, cols)
    for k in range(min_dim):
        if np.all(M[k:, k:] == 0):
            break
        for _ in range(2000):
            nonzero = np.argwhere(M[k:, k:] != 0)
            if len(nonzero) == 0:
                break
            abs_vals = [abs(int(M[k+r, k+c])) for r, c in nonzero]
            min_idx = np.argmin(abs_vals)
            r, c = nonzero[min_idx]
            r, c = int(r+k), int(c+k)
            if r != k: M[[k, r]] = M[[r, k]]
            if c != k: M[:, [k, c]] = M[:, [c, k]]
            if M[k,k] < 0: M[k] = -M[k]
            if M[k,k] == 0: break
            changed = False
            for i in range(k+1, rows):
                if M[i,k] != 0:
                    q = int(M[i,k]) // int(M[k,k])
                    M[i] -= q * M[k]
                    if M[i,k] != 0: changed = True
            for j in range(k+1, cols):
                if M[k,j] != 0:
                    q = int(M[k,j]) // int(M[k,k])
                    M[:,j] -= q * M[:,k]
                    if M[k,j] != 0: changed = True
            if not changed:
                ok = True
                for i in range(k+1, rows):
                    for j in range(k+1, cols):
                        if M[k,k] != 0 and M[i,j] % M[k,k] != 0:
                            M[i] += M[k]; ok = False; break
                    if not ok: break
                if ok: break
    return [abs(int(M[k,k])) for k in range(min_dim) if M[k,k] != 0]


def critical_group_info(adj):
    L = graph_laplacian(adj)
    n = adj.shape[0]
    S = list(range(1, n))
    L_S = L[np.ix_(S, S)]
    snf = smith_normal_form_diag(L_S)
    nontrivial = [f for f in snf if f > 1]
    order = int(np.prod(nontrivial)) if nontrivial else 1
    return snf, nontrivial, order


fig, axes = plt.subplots(2, 2, figsize=(14, 11))
fig.suptitle('Critical Group Structure Across Graph Families', fontsize=16, fontweight='bold')

# Panel 1: Orders comparison
ax1 = axes[0, 0]
ns = list(range(3, 10))
cycle_orders = []
complete_orders = []
for n in ns:
    # Cycle C_n
    A = np.zeros((n, n), dtype=int)
    for i in range(n):
        A[i, (i+1)%n] = 1; A[(i+1)%n, i] = 1
    _, _, order = critical_group_info(A)
    cycle_orders.append(order)
    
    # Complete K_n
    A = np.ones((n, n), dtype=int) - np.eye(n, dtype=int)
    _, _, order = critical_group_info(A)
    complete_orders.append(order)

ax1.semilogy(ns, cycle_orders, 'bo-', label='Cycle $C_n$ (order = n)', markersize=8, linewidth=2)
ax1.semilogy(ns, complete_orders, 'rs-', label='Complete $K_n$ (order = $n^{n-2}$)', markersize=8, linewidth=2)
ax1.semilogy(ns, [n for n in ns], 'b--', alpha=0.3, label='y = n')
ax1.semilogy(ns, [n**(n-2) for n in ns], 'r--', alpha=0.3, label='y = $n^{n-2}$')
ax1.set_xlabel('Number of vertices n', fontsize=12)
ax1.set_ylabel('Critical group order (log scale)', fontsize=12)
ax1.set_title('Critical Group Orders')
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)

# Panel 2: Number of invariant factors
ax2 = axes[0, 1]
cycle_nf = []
complete_nf = []
for n in ns:
    A = np.zeros((n, n), dtype=int)
    for i in range(n):
        A[i, (i+1)%n] = 1; A[(i+1)%n, i] = 1
    _, nf, _ = critical_group_info(A)
    cycle_nf.append(len(nf))
    
    A = np.ones((n, n), dtype=int) - np.eye(n, dtype=int)
    _, nf, _ = critical_group_info(A)
    complete_nf.append(len(nf))

genus_cycle = [1 for _ in ns]  # C_n has genus 1
genus_complete = [n*(n-1)//2 - n + 1 for n in ns]  # K_n has genus (n choose 2) - n + 1

ax2.bar(np.array(ns) - 0.2, cycle_nf, 0.35, label='Cycle $C_n$', color='#3498db', alpha=0.8)
ax2.bar(np.array(ns) + 0.2, complete_nf, 0.35, label='Complete $K_n$', color='#e74c3c', alpha=0.8)
ax2.plot(ns, [n-1 for n in ns], 'k--', alpha=0.5, label='n - 1 (max possible)')
ax2.set_xlabel('Number of vertices n', fontsize=12)
ax2.set_ylabel('Number of invariant factors > 1', fontsize=12)
ax2.set_title('Torsion Rank')
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3, axis='y')

# Panel 3: Invariant factor decomposition for K_n
ax3 = axes[1, 0]
n_range = range(3, 8)
max_factors = 5
data = np.zeros((len(list(n_range)), max_factors))
labels = []
for idx, n in enumerate(n_range):
    A = np.ones((n, n), dtype=int) - np.eye(n, dtype=int)
    _, nf, _ = critical_group_info(A)
    labels.append(f'$K_{n}$')
    for j, f in enumerate(nf[:max_factors]):
        data[idx, j] = f

im = ax3.imshow(data, cmap='YlOrRd', aspect='auto', interpolation='nearest')
ax3.set_xticks(range(max_factors))
ax3.set_xticklabels([f'$d_{j+1}$' for j in range(max_factors)])
ax3.set_yticks(range(len(labels)))
ax3.set_yticklabels(labels, fontsize=12)
ax3.set_title('Invariant Factors of $K_n$')
plt.colorbar(im, ax=ax3, shrink=0.8)
for i in range(data.shape[0]):
    for j in range(data.shape[1]):
        if data[i, j] > 0:
            ax3.text(j, i, str(int(data[i, j])), ha='center', va='center',
                    fontsize=10, fontweight='bold',
                    color='white' if data[i,j] > max(data.flatten())*0.6 else 'black')

# Panel 4: Kirchhoff's theorem verification
ax4 = axes[1, 1]
# Count spanning trees by det(L_S) and compare with critical group order
tree_counts = []
cg_orders = []
graph_labels = []

test_graphs = {
    '$C_3$': lambda: (lambda A: A)(np.array([[0,1,1],[1,0,1],[1,1,0]])),
    '$C_4$': lambda: (lambda n: (lambda A: A)(np.eye(n, dtype=int) * 0 + np.diag(np.ones(n-1, dtype=int), 1) + np.diag(np.ones(n-1, dtype=int), -1) + np.array([[0]*( n-1)+[1]] + [[0]*n]*(n-2) + [[1]+[0]*(n-1)], dtype=int)))(4),
    '$K_4$': lambda: np.ones((4,4), dtype=int) - np.eye(4, dtype=int),
    '$K_5$': lambda: np.ones((5,5), dtype=int) - np.eye(5, dtype=int),
    '$P_4$': lambda: np.array([[0,1,0,0],[1,0,1,0],[0,1,0,1],[0,0,1,0]]),
}

for name, gen in test_graphs.items():
    A = gen()
    L = graph_laplacian(A)
    n = A.shape[0]
    S = list(range(1, n))
    L_S = L[np.ix_(S, S)]
    det = abs(int(round(np.linalg.det(L_S.astype(float)))))
    _, _, order = critical_group_info(A)
    tree_counts.append(det)
    cg_orders.append(order)
    graph_labels.append(name)

x = np.arange(len(graph_labels))
ax4.bar(x - 0.15, tree_counts, 0.3, label='det($L_S$) = # spanning trees', color='#2ecc71', alpha=0.8)
ax4.bar(x + 0.15, cg_orders, 0.3, label='Critical group order', color='#9b59b6', alpha=0.8)
ax4.set_xticks(x)
ax4.set_xticklabels(graph_labels, fontsize=11)
ax4.set_ylabel('Count / Order', fontsize=12)
ax4.set_title("Kirchhoff's Theorem: det($L_S$) = |Crit(G)|")
ax4.legend(fontsize=9)
ax4.grid(True, alpha=0.3, axis='y')

# Add match indicators
for i in range(len(tree_counts)):
    match = "✓" if tree_counts[i] == cg_orders[i] else "✗"
    ax4.text(i, max(tree_counts[i], cg_orders[i]) + 1, match, 
            ha='center', fontsize=14, color='green' if match == "✓" else 'red')

plt.tight_layout()
plt.savefig('viz_critical_groups.png', dpi=150, bbox_inches='tight')
print("Saved viz_critical_groups.png")
