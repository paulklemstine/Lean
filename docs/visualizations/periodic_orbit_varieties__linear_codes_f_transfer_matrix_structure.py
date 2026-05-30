"""
Visualization: Transfer Matrix Structure

Shows the 4×4 transfer matrices for selected ECA rules, revealing how
the fixed-point constraints are encoded as a directed graph structure.
Also shows the exponential growth/decay of fixed point counts.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def local_rule(r, left, center, right):
    idx = 4 * left + 2 * center + right
    return (r >> idx) & 1


def build_transfer_matrix(r):
    T = [[0]*4 for _ in range(4)]
    for si in range(2):
        for sj in range(2):
            row = 2 * si + sj
            for sk in range(2):
                col = 2 * sj + sk
                if local_rule(r, si, sj, sk) == sj:
                    T[row][col] = 1
    return T


def mat_mul_int(A, B, size):
    C = [[0]*size for _ in range(size)]
    for i in range(size):
        for j in range(size):
            for l in range(size):
                C[i][j] += A[i][l] * B[l][j]
    return C


def mat_pow_int(M, size, exp):
    result = [[1 if i == j else 0 for j in range(size)] for i in range(size)]
    base = [row[:] for row in M]
    while exp > 0:
        if exp & 1:
            result = mat_mul_int(result, base, size)
        base = mat_mul_int(base, base, size)
        exp >>= 1
    return result


def count_fixed_transfer(r, n):
    T = build_transfer_matrix(r)
    Tn = mat_pow_int(T, 4, n)
    return sum(Tn[i][i] for i in range(4))


rules = [0, 30, 90, 110, 150, 204]
state_labels = ['00', '01', '10', '11']

fig, axes = plt.subplots(2, 3, figsize=(15, 10))
fig.suptitle("Transfer Matrices and Fixed Point Growth\nfor Selected ECA Rules",
             fontsize=14, fontweight='bold')

for idx, r in enumerate(rules):
    row, col = idx // 3, idx % 3
    ax = axes[row][col]

    T = build_transfer_matrix(r)
    T_arr = np.array(T)

    im = ax.imshow(T_arr, cmap='Blues', vmin=0, vmax=1)
    ax.set_title(f"Rule {r}", fontsize=12, fontweight='bold')
    ax.set_xticks(range(4))
    ax.set_xticklabels(state_labels, fontsize=9)
    ax.set_yticks(range(4))
    ax.set_yticklabels(state_labels, fontsize=9)
    ax.set_xlabel("(sⱼ, sₖ)")
    ax.set_ylabel("(sᵢ, sⱼ)")

    for i in range(4):
        for j in range(4):
            color = 'white' if T_arr[i, j] > 0.5 else 'black'
            ax.text(j, i, str(T_arr[i, j]), ha='center', va='center',
                    fontsize=14, fontweight='bold', color=color)

    # Inset: fixed point count growth
    ns_inset = list(range(1, 51))
    counts = [count_fixed_transfer(r, n) for n in ns_inset]
    ax_inset = ax.inset_axes([0.55, 0.55, 0.4, 0.4])
    ax_inset.semilogy(ns_inset, [max(c, 0.5) for c in counts], 'r-', linewidth=1.5)
    ax_inset.set_xlabel('n', fontsize=7)
    ax_inset.set_ylabel('|Fix|', fontsize=7)
    ax_inset.tick_params(labelsize=6)
    ax_inset.set_title('|Fix| vs n', fontsize=7)
    ax_inset.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig("transfer_matrices.png", dpi=150, bbox_inches='tight')
print("Saved transfer_matrices.png")
