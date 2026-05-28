"""
Visualization: Stabilizer Descent Dimension Drops

Visualizes the normalized log-cardinality (pseudofinite dimension) of
stabilizer chains across different primes and set sizes. Shows how
the dimension drops or stabilizes as we iterate the stabilizer map.

This illustrates the core mathematical phenomenon: approximate subgroups
have stabilizers whose dimension is controlled by the doubling constant.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

# ─── Self-contained functions ─────────────────────────────────────────────────

def sumset(A, B, p):
    return {(a + b) % p for a in A for b in B}

def additive_stabilizer(A, p):
    AA = sumset(A, A, p)
    return {g for g in range(p) if all((g + a) % p in AA for a in A)}

def nlc(A, p):
    if not A: return 0.0
    return math.log(len(A)) / math.log(p)

def doubling_const(A, p):
    if not A: return float('inf')
    return len(sumset(A, A, p)) / len(A)

def centered_interval(p, w):
    return {i % p for i in range(-w, w + 1)}

def stabilizer_chain(A, p, max_steps=8):
    chain = []
    current = A.copy()
    for step in range(max_steps + 1):
        chain.append({
            'step': step, 'size': len(current),
            'nlc': nlc(current, p), 'doubling': doubling_const(current, p),
        })
        stab = additive_stabilizer(current, p)
        if stab == current or len(stab) == 0:
            break
        current = stab
    return chain

# ─── Figure 1: Dimension drops across primes ─────────────────────────────────

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

primes = [101, 509, 1009]

for idx, p in enumerate(primes):
    ax = axes[idx]
    widths = []
    for exp in np.linspace(0.2, 0.8, 12):
        w = max(2, int(p ** exp))
        if w < (p - 1) // 2:
            widths.append(w)

    for w in widths[:8]:
        A = centered_interval(p, w)
        dc = doubling_const(A, p)
        if dc > 3:
            continue

        chain = stabilizer_chain(A, p, max_steps=5)
        steps = [c['step'] for c in chain]
        nlcs = [c['nlc'] for c in chain]

        ax.plot(steps, nlcs, 'o-', markersize=4, alpha=0.7,
                label=f'w={w}, K={dc:.2f}')

    ax.set_xlabel('Stabilizer iteration k', fontsize=11)
    ax.set_ylabel('nlc(Stab^k(A))', fontsize=11)
    ax.set_title(f'Z/{p}Z', fontsize=13, fontweight='bold')
    ax.set_ylim(-0.05, 1.1)
    ax.axhline(y=0, color='gray', linestyle='--', alpha=0.3)
    ax.axhline(y=1, color='gray', linestyle='--', alpha=0.3)
    ax.legend(fontsize=7, loc='upper right')
    ax.grid(True, alpha=0.2)

plt.suptitle('Stabilizer Descent: Dimension vs. Iteration Step',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('stabilizer_descent_dimensions.png', dpi=150, bbox_inches='tight')
print("Saved: stabilizer_descent_dimensions.png")

# ─── Figure 2: Doubling constant vs dimension drop heatmap ───────────────────

fig2, ax2 = plt.subplots(figsize=(8, 6))

p = 1009
K_vals = []
nlc_vals = []
drop_vals = []

for w in range(2, min(200, (p-1)//2)):
    A = centered_interval(p, w)
    dc = doubling_const(A, p)
    if dc > 5:
        continue
    stab = additive_stabilizer(A, p)
    nlc_A = nlc(A, p)
    nlc_S = nlc(stab, p)
    drop = nlc_A - nlc_S

    K_vals.append(dc)
    nlc_vals.append(nlc_A)
    drop_vals.append(drop)

scatter = ax2.scatter(nlc_vals, K_vals, c=drop_vals, cmap='RdYlBu_r',
                       s=20, alpha=0.7, edgecolors='none')
cbar = plt.colorbar(scatter, ax=ax2)
cbar.set_label('Dimension drop: nlc(A) - nlc(Stab(A))', fontsize=11)

ax2.set_xlabel('Normalized log-cardinality nlc(A)', fontsize=12)
ax2.set_ylabel('Doubling constant K', fontsize=12)
ax2.set_title(f'Dimension Drop Landscape in Z/{p}Z', fontsize=14, fontweight='bold')
ax2.grid(True, alpha=0.2)

plt.tight_layout()
plt.savefig('dimension_drop_landscape.png', dpi=150, bbox_inches='tight')
print("Saved: dimension_drop_landscape.png")
