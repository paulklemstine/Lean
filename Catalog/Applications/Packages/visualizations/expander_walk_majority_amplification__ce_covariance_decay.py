#!/usr/bin/env python3
"""
Visualization: Covariance Decay Along Expander Walks

Illustrates the core theorem: autocovariance of a mean-zero observable
decays exponentially at rate ρ^t, where ρ is the spectral contraction
parameter. Shows both theoretical bounds and empirical measurements
on the Cayley graph of S_5.

SELF-CONTAINED — does not import from local modules.
"""

import math
import numpy as np
import matplotlib.pyplot as plt
import matplotlib

matplotlib.rcParams.update({
    'font.size': 12,
    'axes.labelsize': 14,
    'axes.titlesize': 15,
    'legend.fontsize': 11,
    'figure.figsize': (12, 5),
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

# Build transition matrix
P = np.zeros((N,N))
for i,g in enumerate(S5):
    for s in GENS:
        P[i, IDX[compose(s,g)]] += 0.25

# Spectral analysis
evals = np.sort(np.linalg.eigvalsh(P))[::-1]
rho = max(abs(evals[1]), abs(evals[-1]))

# ── Compute covariance decay ────────────────────────────────────

T_MAX = 25
rng = np.random.RandomState(42)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5.5))

# Multiple random observables
colors = plt.cm.viridis(np.linspace(0.2, 0.8, 5))
for trial, c in enumerate(colors):
    g = rng.randn(N)
    g -= g.mean()
    g_l2sq = np.mean(g**2)

    covs = []
    bounds = []
    for t in range(T_MAX+1):
        Pt_g = np.linalg.matrix_power(P, t) @ g
        cov = abs(np.mean(g * Pt_g))
        covs.append(cov)
        bounds.append(rho**t * g_l2sq)

    ts = np.arange(T_MAX+1)
    ax1.semilogy(ts, covs, 'o-', color=c, markersize=4,
                 label=f'Trial {trial+1}', alpha=0.8, linewidth=1.5)

# Theoretical bound envelope
ts = np.arange(T_MAX+1)
ax1.semilogy(ts, [rho**t for t in ts], 'k--', linewidth=2.5,
             label=f'ρ^t (ρ={rho:.3f})', alpha=0.9)

ax1.set_xlabel('Walk step t')
ax1.set_ylabel('|Cov(g, T^t g)| / ‖g‖₂²')
ax1.set_title('Covariance Decay: Empirical vs Certified Bound')
ax1.legend(loc='upper right', framealpha=0.9)
ax1.set_ylim(1e-8, 2)
ax1.grid(True, alpha=0.3)
ax1.axhline(y=1, color='gray', linestyle=':', alpha=0.5)

# Panel 2: Ratio of empirical to bound
g = rng.randn(N)
g -= g.mean()
g_l2sq = np.mean(g**2)

ratios = []
for t in range(T_MAX+1):
    Pt_g = np.linalg.matrix_power(P, t) @ g
    cov = abs(np.mean(g * Pt_g))
    bound = rho**t * g_l2sq
    ratios.append(cov / bound if bound > 1e-15 else 0)

ax2.bar(ts, ratios, color='steelblue', alpha=0.7, edgecolor='navy')
ax2.axhline(y=1, color='red', linestyle='--', linewidth=2, label='Certified bound')
ax2.set_xlabel('Walk step t')
ax2.set_ylabel('Empirical / Certified bound')
ax2.set_title('Tightness of the Covariance Bound')
ax2.legend()
ax2.set_ylim(0, 1.2)
ax2.grid(True, alpha=0.3, axis='y')

plt.suptitle(f'Covariance Decay on Cay(S₅, {{σ±¹,τ±¹}}), ρ = {rho:.4f}',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_covariance_decay.png', dpi=150, bbox_inches='tight')
print("Saved viz_covariance_decay.png")
