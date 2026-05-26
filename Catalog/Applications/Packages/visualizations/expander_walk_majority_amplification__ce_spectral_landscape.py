#!/usr/bin/env python3
"""
Visualization: Spectral Landscape of the S_5 Cayley Graph

Shows the eigenvalue distribution of the transition matrix and
illustrates how the spectral gap controls amplification quality.
Includes a heatmap of the transition matrix structure.

SELF-CONTAINED — does not import from local modules.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib

matplotlib.rcParams.update({
    'font.size': 12,
    'axes.labelsize': 14,
    'axes.titlesize': 15,
    'legend.fontsize': 11,
})

# ── Build S_5 Cayley graph ──────────────────────────────────────

def compose(p, q):
    return tuple(p[q[i]] for i in range(len(p)))

def inverse(p):
    inv = [0]*len(p)
    for i,v in enumerate(p): inv[v] = i
    return tuple(inv)

IDENTITY = (0,1,2,3,4)
SIGMA = (1,2,3,4,0)
TAU = (1,0,2,3,4)
GENS = [SIGMA, inverse(SIGMA), TAU, inverse(TAU)]

elements = {IDENTITY}
frontier = [IDENTITY]
while frontier:
    nxt = []
    for g in frontier:
        for s in GENS:
            h = compose(s, g)
            if h not in elements:
                elements.add(h)
                nxt.append(h)
    frontier = nxt
S5 = sorted(elements)
IDX = {p:i for i,p in enumerate(S5)}
N = len(S5)

P = np.zeros((N,N))
for i,g in enumerate(S5):
    for s in GENS:
        P[i, IDX[compose(s,g)]] += 0.25

evals = np.sort(np.linalg.eigvalsh(P))[::-1]
rho = max(abs(evals[1]), abs(evals[-1]))

# ── Figure ──────────────────────────────────────────────────────

fig = plt.figure(figsize=(16, 5.5))

# Panel 1: Eigenvalue distribution
ax1 = fig.add_subplot(131)
ax1.stem(range(len(evals)), evals, linefmt='steelblue', markerfmt='o',
         basefmt='gray', label='Eigenvalues')
ax1.axhline(y=rho, color='red', linestyle='--', linewidth=1.5,
            label=f'ρ = {rho:.4f}')
ax1.axhline(y=-rho, color='red', linestyle='--', linewidth=1.5)
ax1.axhline(y=1, color='green', linestyle=':', linewidth=1.5,
            label='λ₁ = 1')
ax1.fill_between(range(len(evals)), -rho, rho, alpha=0.1, color='red')
ax1.set_xlabel('Eigenvalue index')
ax1.set_ylabel('Eigenvalue')
ax1.set_title('Spectrum of Transition Matrix')
ax1.legend(loc='lower left', framealpha=0.9)
ax1.grid(True, alpha=0.3)

# Panel 2: Spectral gap vs amplification constant
ax2 = fig.add_subplot(132)
gaps = np.linspace(0.01, 0.99, 200)
rhos = 1 - gaps
C_vals = (1 + rhos) / (1 - rhos)

ax2.semilogy(gaps, C_vals, 'b-', linewidth=2.5)
# Mark our graph's gap
our_gap = 1 - rho
our_C = (1 + rho) / (1 - rho)
ax2.plot(our_gap, our_C, 'r*', markersize=15, zorder=5,
         label=f'S₅ graph: gap={our_gap:.3f}, C={our_C:.1f}')

# Annotate
ax2.annotate(f'C(ρ) = {our_C:.1f}',
             xy=(our_gap, our_C),
             xytext=(our_gap + 0.15, our_C * 2),
             arrowprops=dict(arrowstyle='->', color='red', lw=2),
             fontsize=12, color='red', fontweight='bold')

ax2.set_xlabel('Spectral gap (1 - ρ)')
ax2.set_ylabel('Spectral constant C(ρ)')
ax2.set_title('Gap → Amplification Quality')
ax2.legend(loc='upper right', framealpha=0.9)
ax2.grid(True, alpha=0.3)
ax2.set_xlim(0, 1)

# Panel 3: Eigenvalue histogram
ax3 = fig.add_subplot(133)
ax3.hist(evals, bins=30, color='steelblue', alpha=0.7, edgecolor='navy',
         density=True)
ax3.axvline(x=rho, color='red', linestyle='--', linewidth=2,
            label=f'ρ = {rho:.4f}')
ax3.axvline(x=-rho, color='red', linestyle='--', linewidth=2)
ax3.axvline(x=1, color='green', linestyle='--', linewidth=2,
            label='λ₁ = 1')
ax3.set_xlabel('Eigenvalue')
ax3.set_ylabel('Density')
ax3.set_title('Eigenvalue Distribution')
ax3.legend(loc='upper left', framealpha=0.9)
ax3.grid(True, alpha=0.3)

plt.suptitle(f'Spectral Landscape of Cay(S₅, {{σ±¹,τ±¹}}), |S₅| = {N}',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_spectral_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_spectral_landscape.png")
