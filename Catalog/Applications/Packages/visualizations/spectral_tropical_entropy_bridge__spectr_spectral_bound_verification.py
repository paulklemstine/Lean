"""
Visualization 2: Spectral Bound Verification

Shows the relationship between spectral radius lambda_1, average degree,
and the entropy lower bound for random graphs. Verifies that the bound
H(G) >= log(|V| * d_bar / Delta) holds universally, and tests the stronger
spectral conjecture H(G) >= log(|V| * lambda_1 / Delta).
"""

import math
import random
import numpy as np
import matplotlib.pyplot as plt


def degree_entropy(degrees):
    vol = sum(degrees)
    if vol == 0:
        return 0.0
    H = 0.0
    for d in degrees:
        if d > 0:
            p = d / vol
            H -= p * math.log(p)
    return H


def generate_erdos_renyi(n, p):
    adj = np.zeros((n, n))
    for i in range(n):
        for j in range(i + 1, n):
            if random.random() < p:
                adj[i][j] = adj[j][i] = 1
    return adj


random.seed(42)
np.random.seed(42)

n = 30
num_per_p = 80
p_values = np.linspace(0.05, 0.95, 19)

data = {pv: {'H': [], 'bound_avg': [], 'bound_spec': [], 'lambda1': [], 'd_bar': []}
        for pv in p_values}

for pv in p_values:
    for _ in range(num_per_p):
        adj = generate_erdos_renyi(n, pv)
        degrees = [int(np.sum(adj[i])) for i in range(n)]
        vol = sum(degrees)
        if vol == 0:
            continue
        delta = max(degrees)
        d_bar = vol / n
        H = degree_entropy(degrees)
        lam1 = float(np.max(np.linalg.eigvalsh(adj)))

        if delta > 0 and d_bar > 0:
            bound_avg = math.log(n * d_bar / delta)
            bound_spec = math.log(n * lam1 / delta) if lam1 > 0 else float('-inf')
        else:
            continue

        data[pv]['H'].append(H)
        data[pv]['bound_avg'].append(bound_avg)
        data[pv]['bound_spec'].append(bound_spec)
        data[pv]['lambda1'].append(lam1)
        data[pv]['d_bar'].append(d_bar)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Plot 1: Entropy vs avg/max bound
ax1 = axes[0, 0]
all_H = []
all_bound_avg = []
colors_p = []
for pv in p_values:
    for H, ba in zip(data[pv]['H'], data[pv]['bound_avg']):
        all_H.append(H)
        all_bound_avg.append(ba)
        colors_p.append(pv)

sc1 = ax1.scatter(all_bound_avg, all_H, c=colors_p, cmap='viridis', s=15, alpha=0.6)
lo, hi = min(all_bound_avg + all_H), max(all_bound_avg + all_H)
ax1.plot([lo, hi], [lo, hi], 'r--', alpha=0.5, label='y = x (tight)')
ax1.set_xlabel('Lower bound: log(|V|·d̄/Δ)')
ax1.set_ylabel('Actual entropy H(G)')
ax1.set_title('Theorem A: H(G) ≥ log(|V|·d̄/Δ)')
ax1.legend()
ax1.grid(True, alpha=0.3)
plt.colorbar(sc1, ax=ax1, label='Edge probability p')

# Plot 2: Entropy margin distribution
ax2 = axes[0, 1]
margins_by_p = {}
for pv in p_values:
    margins = [H - ba for H, ba in zip(data[pv]['H'], data[pv]['bound_avg'])]
    if margins:
        margins_by_p[pv] = margins

selected_p = [0.1, 0.3, 0.5, 0.7, 0.9]
colors = ['#F44336', '#FF9800', '#4CAF50', '#2196F3', '#9C27B0']
for i, sp in enumerate(selected_p):
    closest_p = min(p_values, key=lambda x: abs(x - sp))
    if closest_p in margins_by_p:
        ax2.hist(margins_by_p[closest_p], bins=15, alpha=0.5,
                 label=f'p={sp:.1f}', color=colors[i])
ax2.axvline(x=0, color='red', linestyle='--', alpha=0.5, label='Bound = H')
ax2.set_xlabel('Margin: H(G) - bound')
ax2.set_ylabel('Count')
ax2.set_title('Distribution of Entropy Margins')
ax2.legend(fontsize=8)
ax2.grid(True, alpha=0.3)

# Plot 3: Spectral radius vs average degree
ax3 = axes[1, 0]
all_lam = []
all_dbar = []
all_colors = []
for pv in p_values:
    for l, d in zip(data[pv]['lambda1'], data[pv]['d_bar']):
        all_lam.append(l)
        all_dbar.append(d)
        all_colors.append(pv)
sc3 = ax3.scatter(all_dbar, all_lam, c=all_colors, cmap='viridis', s=15, alpha=0.6)
lo, hi = 0, max(max(all_lam), max(all_dbar))
ax3.plot([0, hi], [0, hi], 'r--', alpha=0.5, label='λ₁ = d̄')
ax3.set_xlabel('Average degree d̄')
ax3.set_ylabel('Spectral radius λ₁')
ax3.set_title('λ₁ ≥ d̄ (Collatz–Sinogowitz)')
ax3.legend()
ax3.grid(True, alpha=0.3)
plt.colorbar(sc3, ax=ax3, label='Edge probability p')

# Plot 4: Strong conjecture margin
ax4 = axes[1, 1]
all_spec_margins = []
all_colors_spec = []
for pv in p_values:
    for H, bs in zip(data[pv]['H'], data[pv]['bound_spec']):
        if bs > float('-inf'):
            all_spec_margins.append(H - bs)
            all_colors_spec.append(pv)
sc4 = ax4.scatter(all_colors_spec, all_spec_margins, c=all_colors_spec,
                  cmap='viridis', s=15, alpha=0.6)
ax4.axhline(y=0, color='red', linestyle='--', alpha=0.5)
ax4.set_xlabel('Edge probability p')
ax4.set_ylabel('H(G) - log(|V|·λ₁/Δ)')
ax4.set_title('Strong Conjecture: H(G) ≥ log(|V|·λ₁/Δ)')
ax4.grid(True, alpha=0.3)
violations = sum(1 for m in all_spec_margins if m < -1e-10)
ax4.text(0.5, 0.95, f'Violations: {violations}/{len(all_spec_margins)}',
         transform=ax4.transAxes, ha='center', va='top',
         fontsize=11, color='green' if violations == 0 else 'red',
         bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))

plt.suptitle(f'Spectral-Tropical Entropy Bounds — G(n={n}, p) Random Graphs',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_spectral_bound.png', dpi=150, bbox_inches='tight')
print("Saved: viz_spectral_bound.png")
