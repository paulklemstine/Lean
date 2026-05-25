#!/usr/bin/env python3
"""
Visualization 3: Contraction Associativity and Tensor Networks

Visualizes the associativity theorem: contract(contract(T,u),v) = contract(T, v⊗u)
by showing the error between left-associated and right-associated contraction
across random tensor instances, demonstrating the zero-error guarantee.
"""

import numpy as np
import matplotlib.pyplot as plt

np.random.seed(42)

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# ─── Panel 1: Associativity Error Distribution ───────────────────────────
ax1 = axes[0]

configs = [(1, 1, 1), (2, 1, 1), (1, 2, 1), (0, 1, 2), (1, 1, 2)]
d = 4
n_trials = 500
all_errors = {}

for a, b, c in configs:
    errors = []
    for _ in range(n_trials):
        T = np.random.randn(*(d,)*(a+b+c))
        u = np.random.randn(*(d,)*c)
        v = np.random.randn(*(d,)*b)

        # LHS: contract(contract(T, u), v)
        t_idx = ''.join(chr(ord('a')+i) for i in range(a+b+c))
        u_idx = ''.join(chr(ord('a')+i) for i in range(a+b, a+b+c))
        mid_idx = ''.join(chr(ord('a')+i) for i in range(a+b))
        sub1 = f"{t_idx},{u_idx}->{mid_idx}" if a+b > 0 else f"{t_idx},{u_idx}->"

        mid = np.einsum(sub1, T, u)

        v_idx2 = ''.join(chr(ord('a')+i) for i in range(a, a+b))
        out_idx = ''.join(chr(ord('a')+i) for i in range(a))
        sub2 = f"{mid_idx},{v_idx2}->{out_idx}" if a > 0 else f"{mid_idx},{v_idx2}->"

        lhs = np.einsum(sub2, mid, v)

        # RHS: contract(T, tensorProd(v, u))
        vu = np.tensordot(v, u, axes=0)  # shape (d,)*b × (d,)*c = (d,)*(b+c)
        vu_idx = ''.join(chr(ord('a')+i) for i in range(a, a+b+c))
        sub3 = f"{t_idx},{vu_idx}->{out_idx}" if a > 0 else f"{t_idx},{vu_idx}->"

        rhs = np.einsum(sub3, T, vu)

        errors.append(np.max(np.abs(np.atleast_1d(lhs) - np.atleast_1d(rhs))))

    label = f"({a},{b},{c})"
    all_errors[label] = errors

positions = list(range(len(configs)))
bp = ax1.boxplot([all_errors[f"({a},{b},{c})"] for a, b, c in configs],
                 positions=positions, widths=0.6, patch_artist=True)
for patch in bp['boxes']:
    patch.set_facecolor('lightblue')

ax1.set_xticks(positions)
ax1.set_xticklabels([f"({a},{b},{c})" for a, b, c in configs])
ax1.set_ylabel('Max |LHS - RHS|')
ax1.set_title('Contraction Associativity Error\n(a,b,c) order triples', fontsize=11)
ax1.set_yscale('log')
ax1.axhline(y=1e-14, color='green', linestyle='--', alpha=0.7, label='Machine epsilon')
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)

# ─── Panel 2: Tensor Network Diagram ─────────────────────────────────────
ax2 = axes[1]

# Draw a simple tensor network
ax2.set_xlim(-0.5, 4.5)
ax2.set_ylim(-1, 3)
ax2.set_aspect('equal')

# Nodes
nodes = [(1, 2, 'T\n(a+b+c)'), (0, 0.5, 'v\n(b)'), (2, 0.5, 'u\n(c)'),
         (3.5, 2, 'T\n(a+b+c)'), (3.5, 0.5, 'v⊗u\n(b+c)')]

colors = ['#4CAF50', '#2196F3', '#FF9800', '#4CAF50', '#9C27B0']

for (x, y, label), color in zip(nodes, colors):
    circle = plt.Circle((x, y), 0.35, color=color, alpha=0.7, zorder=5)
    ax2.add_patch(circle)
    ax2.text(x, y, label, ha='center', va='center', fontsize=8, fontweight='bold',
             color='white', zorder=6)

# Edges (contraction lines)
ax2.annotate('', xy=(0.3, 0.8), xytext=(0.75, 1.7),
             arrowprops=dict(arrowstyle='->', color='red', lw=2))
ax2.annotate('', xy=(1.7, 0.8), xytext=(1.25, 1.7),
             arrowprops=dict(arrowstyle='->', color='red', lw=2))

ax2.annotate('', xy=(3.5, 0.9), xytext=(3.5, 1.6),
             arrowprops=dict(arrowstyle='->', color='red', lw=2))

# Labels
ax2.text(1, -0.5, 'Left-associated', ha='center', fontsize=10, style='italic')
ax2.text(3.5, -0.5, 'Right-associated', ha='center', fontsize=10, style='italic')
ax2.text(2.25, 2.5, '=', ha='center', fontsize=24, fontweight='bold', color='red')

ax2.set_title('Contraction Associativity\nNetwork Diagram', fontsize=11)
ax2.axis('off')

# ─── Panel 3: Cost Comparison ────────────────────────────────────────────
ax3 = axes[2]

dims = range(2, 15)
costs_left = []
costs_right = []

for d_val in dims:
    # Left: contract(contract(T_{2+1+1}, u_1), v_1)
    # Step 1: d^(2+1) * d^1 = d^4 mults, Step 2: d^2 * d^1 = d^3 mults
    cost_l = d_val**4 + d_val**3

    # Right: contract(T_{2+1+1}, tensorProd(v_1, u_1))
    # TensorProd: d^2 mults, then: d^2 * d^2 = d^4 mults
    cost_r = d_val**2 + d_val**4

    costs_left.append(cost_l)
    costs_right.append(cost_r)

ax3.semilogy(list(dims), costs_left, 'b-o', markersize=4, label='Left: (T·u)·v')
ax3.semilogy(list(dims), costs_right, 'r-s', markersize=4, label='Right: T·(v⊗u)')
ax3.set_xlabel('Dimension d')
ax3.set_ylabel('Estimated FLOPs')
ax3.set_title('Contraction Cost Comparison\n(orders 2+1+1)', fontsize=11)
ax3.legend()
ax3.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_associativity.png', dpi=150, bbox_inches='tight')
print("Saved viz_associativity.png")
