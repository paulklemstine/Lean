"""
Visualization: Energy Landscape and Canonical Kernels on Metric Graphs

Visualizes the Dirichlet energy landscape on a cycle graph and the
canonical kernel generators, illustrating key theorems:
  - Energy non-negativity (energy_nonneg)
  - Constants have zero energy (energy_zero_of_constant)
  - Energy pairing and effective resistance

This script is fully self-contained — all needed functions are inlined.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec


def build_cycle_laplacian(n, lengths):
    """Build the metric Laplacian for a cycle graph."""
    L = np.zeros((n, n))
    for i in range(n):
        j = (i + 1) % n
        cond = 1.0 / lengths[i]
        L[i, i] += cond
        L[j, j] += cond
        L[i, j] -= cond
        L[j, i] -= cond
    return L


def solve_kernel(L, D):
    """Solve Lf = D with mean-zero normalization."""
    n = L.shape[0]
    A = L.copy()
    b = D.copy()
    A[-1, :] = 1.0
    b[-1] = 0.0
    return np.linalg.solve(A, b)


# --- Setup ---
n = 5
lengths = [1.0, 1.5, 2.0, 1.5, 1.0]
L = build_cycle_laplacian(n, lengths)

fig = plt.figure(figsize=(16, 12))
gs = gridspec.GridSpec(2, 2, hspace=0.35, wspace=0.3)

# --- Panel 1: Energy as function of perturbation ---
ax1 = fig.add_subplot(gs[0, 0])
# Start from a kernel generator and perturb
D = np.zeros(n)
D[0] = 1.0
D[2] = -1.0
f0 = solve_kernel(L, D)

# Perturb in random direction (mean-zero)
np.random.seed(42)
direction = np.random.randn(n)
direction -= direction.mean()
direction /= np.linalg.norm(direction)

ts = np.linspace(-2, 2, 200)
energies = []
for t in ts:
    f = f0 + t * direction
    E = f @ L @ f
    energies.append(E)

ax1.plot(ts, energies, 'b-', linewidth=2)
ax1.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
ax1.axvline(x=0, color='r', linestyle='--', alpha=0.5, label='Canonical kernel')
E0 = f0 @ L @ f0
ax1.plot(0, E0, 'ro', markersize=10, zorder=5, label=f'E(f₀) = {E0:.3f}')
ax1.set_xlabel('Perturbation parameter t', fontsize=12)
ax1.set_ylabel('Dirichlet Energy E(f₀ + t·δ)', fontsize=12)
ax1.set_title('Energy Landscape (Convexity)', fontsize=14)
ax1.legend(fontsize=10)

# --- Panel 2: Kernel generators ---
ax2 = fig.add_subplot(gs[0, 1])
colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3', '#ff7f00']
x_positions = np.arange(n)

for src in range(1, n):
    D = np.zeros(n)
    D[src] = 1.0
    D[0] = -1.0
    f = solve_kernel(L, D)

    ax2.plot(x_positions, f, 'o-', color=colors[src], linewidth=2,
             markersize=8, label=f'k_{src} (source at {src})')

ax2.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
ax2.set_xlabel('Vertex', fontsize=12)
ax2.set_ylabel('Potential value', fontsize=12)
ax2.set_title('Canonical Kernel Generators', fontsize=14)
ax2.legend(fontsize=9)
ax2.set_xticks(range(n))

# --- Panel 3: Energy pairing matrix (heatmap) ---
ax3 = fig.add_subplot(gs[1, 0])
S = list(range(n))
k = len(S)
kernels = []
for idx in range(1, k):
    D = np.zeros(n)
    D[S[idx]] = 1.0
    D[S[0]] = -1.0
    f = solve_kernel(L, D)
    kernels.append(f)

Q = np.zeros((k-1, k-1))
for i in range(k-1):
    for j in range(k-1):
        Q[i, j] = kernels[i] @ L @ kernels[j]

im = ax3.imshow(Q, cmap='YlOrRd', aspect='equal')
plt.colorbar(im, ax=ax3)
ax3.set_xticks(range(k-1))
ax3.set_yticks(range(k-1))
ax3.set_xticklabels([f'k_{i+1}' for i in range(k-1)])
ax3.set_yticklabels([f'k_{i+1}' for i in range(k-1)])
ax3.set_title('Energy Pairing Matrix\n(Tropical Polarization)', fontsize=14)

# Annotate values
for i in range(k-1):
    for j in range(k-1):
        ax3.text(j, i, f'{Q[i,j]:.2f}', ha='center', va='center',
                 color='black' if Q[i,j] < Q.max()*0.7 else 'white', fontsize=10)

# --- Panel 4: Refinement convergence ---
ax4 = fig.add_subplot(gs[1, 1])
base_lengths = [1.0, 1.618, 2.236]  # 1, golden ratio, √5

levels = range(6)
eig_traces = [[] for _ in range(2)]

for level in levels:
    m = 3 * (2 ** level)
    sublengths = []
    for i in range(3):
        sub = base_lengths[i] / (2 ** level)
        sublengths.extend([sub] * (2 ** level))

    L_sub = build_cycle_laplacian(m, sublengths)
    step = 2 ** level
    S_sub = [0, step, 2 * step]

    # Compute kernel generators at support vertices
    ks = []
    for idx in range(1, 3):
        D = np.zeros(m)
        D[S_sub[idx]] = 1.0
        D[S_sub[0]] = -1.0
        f = solve_kernel(L_sub, D)
        ks.append(f)

    Q_sub = np.zeros((2, 2))
    for i in range(2):
        for j in range(2):
            Q_sub[i, j] = ks[i] @ L_sub @ ks[j]

    eigs = sorted(np.linalg.eigvalsh(Q_sub))
    for k_idx in range(2):
        eig_traces[k_idx].append(eigs[k_idx])

for k_idx in range(2):
    ax4.plot(list(levels), eig_traces[k_idx], 'o-', linewidth=2,
             markersize=8, label=f'λ_{k_idx+1}')

ax4.set_xlabel('Subdivision level', fontsize=12)
ax4.set_ylabel('Energy eigenvalue', fontsize=12)
ax4.set_title('Refinement Convergence\n(Subdivision Stability)', fontsize=14)
ax4.legend(fontsize=10)

fig.suptitle('Canonical Kernel Calculus on Metric Graphs', fontsize=16, y=0.98)
plt.savefig('viz_energy_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_energy_landscape.png")
