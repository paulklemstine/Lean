"""
Visualization: Leaf Rigidity and Pendant-Tree Pruning

Illustrates the metric leaf rigidity theorem: harmonic functions on pendant
edges must be constant. Shows how attaching longer pendant trees does not
change the canonical kernel data on the cycle core.

This script is fully self-contained.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec


def build_lollipop_laplacian(n_cycle, cycle_len, stick_len):
    """Build Laplacian for a lollipop graph (cycle + pendant stick)."""
    n = n_cycle + 1
    L = np.zeros((n, n))
    edge_len = cycle_len / n_cycle
    # Cycle edges
    for i in range(n_cycle):
        j = (i + 1) % n_cycle
        cond = 1.0 / edge_len
        L[i, i] += cond
        L[j, j] += cond
        L[i, j] -= cond
        L[j, i] -= cond
    # Pendant stick: vertex n_cycle attached to vertex 0
    cond_stick = 1.0 / stick_len
    L[0, 0] += cond_stick
    L[n_cycle, n_cycle] += cond_stick
    L[0, n_cycle] -= cond_stick
    L[n_cycle, 0] -= cond_stick
    return L, n


def build_tree_laplacian(n_cycle, cycle_len, tree_lengths):
    """Build Laplacian for cycle + multi-node pendant tree."""
    n_tree = len(tree_lengths)
    n = n_cycle + n_tree
    L = np.zeros((n, n))
    edge_len = cycle_len / n_cycle
    for i in range(n_cycle):
        j = (i + 1) % n_cycle
        cond = 1.0 / edge_len
        L[i, i] += cond
        L[j, j] += cond
        L[i, j] -= cond
        L[j, i] -= cond
    # Tree: chain from vertex 0 through n_cycle, n_cycle+1, ...
    prev = 0
    for k, tl in enumerate(tree_lengths):
        cur = n_cycle + k
        cond = 1.0 / tl
        L[prev, prev] += cond
        L[cur, cur] += cond
        L[prev, cur] -= cond
        L[cur, prev] -= cond
        prev = cur
    return L, n


def solve_kernel(L, D):
    n = L.shape[0]
    A = L.copy()
    b = D.copy()
    A[-1, :] = 1.0
    b[-1] = 0.0
    return np.linalg.solve(A, b)


fig = plt.figure(figsize=(16, 10))
gs = gridspec.GridSpec(2, 2, hspace=0.4, wspace=0.3)

# --- Panel 1: Harmonic function on lollipop (showing leaf constancy) ---
ax1 = fig.add_subplot(gs[0, 0])

n_cycle = 6
cycle_len = 6.0
stick_len = 3.0
L, n = build_lollipop_laplacian(n_cycle, cycle_len, stick_len)

# Source at vertex 1, sink at vertex 4
D = np.zeros(n)
D[1] = 1.0
D[4] = -1.0
f = solve_kernel(L, D)

# Plot vertex positions on a circle + stick
angles = np.linspace(0, 2*np.pi, n_cycle, endpoint=False)
x_pos = np.cos(angles)
y_pos = np.sin(angles)
# Stick extends from vertex 0
x_pos = np.append(x_pos, x_pos[0] + 0.5)
y_pos = np.append(y_pos, y_pos[0] + 0.5)

scatter = ax1.scatter(x_pos, y_pos, c=f, cmap='RdBu_r', s=200,
                       edgecolors='black', linewidths=1.5, zorder=5,
                       vmin=-max(abs(f)), vmax=max(abs(f)))
plt.colorbar(scatter, ax=ax1, label='Potential f(v)')

# Draw edges
for i in range(n_cycle):
    j = (i + 1) % n_cycle
    ax1.plot([x_pos[i], x_pos[j]], [y_pos[i], y_pos[j]], 'k-', linewidth=1)
ax1.plot([x_pos[0], x_pos[n_cycle]], [y_pos[0], y_pos[n_cycle]], 'k--', linewidth=2)

# Label vertices
for i in range(n):
    label = f'{i}' + (' (leaf)' if i == n_cycle else '')
    ax1.annotate(label, (x_pos[i], y_pos[i]), textcoords="offset points",
                xytext=(10, 5), fontsize=9)

# Highlight leaf rigidity
ax1.annotate(f'f({n_cycle}) = {f[n_cycle]:.4f}\nf(0) = {f[0]:.4f}\n→ Equal!',
            xy=(x_pos[n_cycle], y_pos[n_cycle]),
            xytext=(x_pos[n_cycle]+0.3, y_pos[n_cycle]+0.5),
            fontsize=10, color='red',
            arrowprops=dict(arrowstyle='->', color='red'))

ax1.set_title('Leaf Rigidity: f(leaf) = f(neighbor)', fontsize=13)
ax1.set_aspect('equal')
ax1.grid(True, alpha=0.3)

# --- Panel 2: Potential profile showing constancy on pendant ---
ax2 = fig.add_subplot(gs[0, 1])

# Build a longer tree: cycle + chain of 5 pendant vertices
tree_lengths = [1.0, 1.0, 1.0, 1.0, 1.0]
L_tree, n_tree = build_tree_laplacian(n_cycle, cycle_len, tree_lengths)
D_tree = np.zeros(n_tree)
D_tree[1] = 1.0
D_tree[4] = -1.0
f_tree = solve_kernel(L_tree, D_tree)

# Plot the potential along the tree path
tree_path = list(range(n_cycle)) + list(range(n_cycle, n_tree))
labels = [f'cycle {i}' for i in range(n_cycle)] + [f'tree {i-n_cycle}' for i in range(n_cycle, n_tree)]

ax2.bar(range(n_tree), f_tree, color=['steelblue']*n_cycle + ['coral']*len(tree_lengths),
        edgecolor='black', linewidth=0.5)
ax2.axhline(y=f_tree[0], color='red', linestyle='--', alpha=0.7,
            label=f'f(attachment) = {f_tree[0]:.4f}')
ax2.set_xticks(range(n_tree))
ax2.set_xticklabels([str(i) for i in range(n_tree)], rotation=45)
ax2.set_xlabel('Vertex index', fontsize=12)
ax2.set_ylabel('Potential f(v)', fontsize=12)
ax2.set_title('Potential Profile: Constant on Tree', fontsize=13)
ax2.legend(fontsize=10)

# --- Panel 3: Core Jacobian invariance under tree attachment ---
ax3 = fig.add_subplot(gs[1, 0])

stick_lengths = np.linspace(0.1, 50, 100)
eig1_vals = []
eig2_vals = []

for sl in stick_lengths:
    L_lol, n_lol = build_lollipop_laplacian(4, 4.0, sl)
    # Kernel generators on core
    S = [0, 1, 2, 3]
    ks = []
    for idx in range(1, 4):
        D = np.zeros(n_lol)
        D[S[idx]] = 1.0
        D[S[0]] = -1.0
        ks.append(solve_kernel(L_lol, D))
    Q = np.zeros((3, 3))
    for i in range(3):
        for j in range(3):
            Q[i,j] = ks[i] @ L_lol @ ks[j]
    eigs = sorted(np.linalg.eigvalsh(Q))
    eig1_vals.append(eigs[0])
    eig2_vals.append(eigs[1])

ax3.plot(stick_lengths, eig1_vals, 'b-', linewidth=2, label='λ₁')
ax3.plot(stick_lengths, eig2_vals, 'r-', linewidth=2, label='λ₂')
ax3.set_xlabel('Pendant stick length', fontsize=12)
ax3.set_ylabel('Energy eigenvalue', fontsize=12)
ax3.set_title('Core Jacobian: Invariant Under\nPendant Attachment', fontsize=13)
ax3.legend(fontsize=11)
ax3.grid(True, alpha=0.3)

# --- Panel 4: Laplacian structure ---
ax4 = fig.add_subplot(gs[1, 1])

L_show, _ = build_lollipop_laplacian(5, 5.0, 2.0)
im = ax4.imshow(L_show, cmap='RdBu_r', aspect='equal',
                vmin=-max(abs(L_show.flatten())),
                vmax=max(abs(L_show.flatten())))
plt.colorbar(im, ax=ax4)
ax4.set_title('Metric Laplacian Matrix\n(Row-Sum-Zero, Symmetric)', fontsize=13)
ax4.set_xlabel('Column (vertex j)', fontsize=11)
ax4.set_ylabel('Row (vertex i)', fontsize=11)

for i in range(L_show.shape[0]):
    for j in range(L_show.shape[1]):
        val = L_show[i, j]
        if abs(val) > 0.01:
            ax4.text(j, i, f'{val:.1f}', ha='center', va='center',
                     fontsize=8, color='white' if abs(val) > 0.8 else 'black')

fig.suptitle('Pendant-Edge Rigidity and Metric Graph Harmonic Theory', fontsize=15, y=0.98)
plt.savefig('viz_leaf_rigidity.png', dpi=150, bbox_inches='tight')
print("Saved viz_leaf_rigidity.png")
