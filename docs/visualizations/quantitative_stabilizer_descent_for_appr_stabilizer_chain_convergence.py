"""
Visualization: Stabilizer Chain Convergence

Shows the convergence behavior of stabilizer chains for various
initial sets. Compares how quickly the chain stabilizes (reaches
a fixed point) depending on the initial set's structure.

This visualizes the descent engine: each step of the stabilizer
map reduces dimension until a fixed point (algebraic core) is reached.
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

def stabilizer_chain_data(A, p, max_steps=8):
    chain = []
    current = A.copy()
    for step in range(max_steps + 1):
        chain.append({
            'step': step, 'size': len(current),
            'nlc': nlc(current, p), 'doubling': doubling_const(current, p),
        })
        stab = additive_stabilizer(current, p)
        if stab == current:
            break
        current = stab
    return chain

# ─── Build data ───────────────────────────────────────────────────────────────

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

p = 509
colors = plt.cm.viridis(np.linspace(0, 0.9, 10))

# Panel 1: Stabilizer chains for intervals of various widths
legends1 = []
for i, w in enumerate([3, 5, 8, 12, 20, 30, 50, 80]):
    if w >= (p - 1) // 2:
        continue
    A = centered_interval(p, w)
    dc = doubling_const(A, p)
    if dc > 3:
        continue

    chain = stabilizer_chain_data(A, p, max_steps=6)
    steps = [c['step'] for c in chain]
    sizes = [c['size'] for c in chain]

    ax1.plot(steps, sizes, 'o-', color=colors[i % len(colors)],
             markersize=6, linewidth=2, alpha=0.8)
    legends1.append(f'w={w} (K={dc:.2f})')

ax1.set_xlabel('Stabilizer iteration', fontsize=12)
ax1.set_ylabel('|Stab^k(A)|', fontsize=12)
ax1.set_title(f'Stabilizer Chain: Set Sizes (Z/{p}Z)', fontsize=13, fontweight='bold')
ax1.legend(legends1, fontsize=8, loc='upper left')
ax1.set_yscale('log')
ax1.grid(True, alpha=0.2)

# Panel 2: Ratios |Stab(A)| / |A| for many widths
widths = list(range(2, min(100, (p-1)//2)))
ratios = []
dcs = []

for w in widths:
    A = centered_interval(p, w)
    dc = doubling_const(A, p)
    if dc > 3:
        continue
    stab = additive_stabilizer(A, p)
    ratio = len(stab) / len(A)
    ratios.append(ratio)
    dcs.append(dc)

ax2.scatter(dcs, ratios, c='steelblue', s=15, alpha=0.6, edgecolors='none')
ax2.axhline(y=1, color='red', linestyle='--', alpha=0.5, label='Stab(A) = A')
ax2.set_xlabel('Doubling constant K', fontsize=12)
ax2.set_ylabel('|Stab(A)| / |A|', fontsize=12)
ax2.set_title(f'Stabilizer-to-Set Ratio (Z/{p}Z)', fontsize=13, fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.2)

plt.suptitle('Stabilizer Chain Convergence Analysis',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('stabilizer_chain_convergence.png', dpi=150, bbox_inches='tight')
print("Saved: stabilizer_chain_convergence.png")
