"""
Visualization: Susceptibility bounds and epsilon scaling.

Shows how the spin susceptibility and MI bounds scale with the
Lorentzian gap parameter ε, demonstrating the statistical physics bridge.

Three panels:
1. Susceptibility vs bound for different matroid sizes
2. Max pairwise MI vs ε² scaling
3. Entropy retention under deletion vs number of coordinates
"""

import numpy as np
import matplotlib.pyplot as plt
from math import log, comb
from itertools import combinations

def xlogx(x):
    return x * np.log(x) if x > 0 else 0.0

def uniform_matroid_law(n, r):
    total = comb(n, r)
    return {frozenset(s): 1.0 / total for s in combinations(range(n), r)}

def perturbed_matroid_law(n, r, eps_mult, seed=42):
    rng = np.random.RandomState(seed)
    base = uniform_matroid_law(n, r)
    total = comb(n, r)
    noisy = {s: max(w + rng.uniform(-eps_mult/total, eps_mult/total), 1e-15)
             for s, w in base.items()}
    Z = sum(noisy.values())
    return {s: w/Z for s, w in noisy.items()}

def coord_prob(law, i):
    return sum(w for s, w in law.items() if i in s)

def coord_cov(law, i, j):
    pij = sum(w for s, w in law.items() if i in s and j in s)
    return pij - coord_prob(law, i) * coord_prob(law, j)

def total_entropy(law):
    return -sum(xlogx(w) for w in law.values())

def delete_coord_entropy(law, k):
    m = {}
    for s, w in law.items():
        t = s - {k}
        m[t] = m.get(t, 0.0) + w
    return -sum(xlogx(w) for w in m.values())

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Susceptibility vs bound for different n
ax = axes[0]
colors = ['#1976D2', '#388E3C', '#F57C00', '#7B1FA2', '#C62828']
for idx, n in enumerate([4, 5, 6, 7, 8]):
    r = n // 2
    chi_vals = []
    chi_bounds = []
    eps_vals = []

    for eps_mult in np.linspace(0.01, 0.8, 15):
        law = perturbed_matroid_law(n, r, eps_mult, seed=42+idx)
        max_ratio = 0
        for i in range(n):
            for j in range(i+1, n):
                pi, pj = coord_prob(law, i), coord_prob(law, j)
                c = abs(coord_cov(law, i, j))
                if pi * pj > 0:
                    max_ratio = max(max_ratio, c / (pi * pj))
        eps = max_ratio * 1.01

        chi = sum(abs(coord_cov(law, i, j))
                  for i in range(n) for j in range(n) if i != j)
        total_p = sum(coord_prob(law, i) for i in range(n))
        bound = eps * total_p ** 2

        eps_vals.append(eps)
        chi_vals.append(chi)
        chi_bounds.append(bound)

    ax.scatter(eps_vals, chi_vals, s=20, color=colors[idx], alpha=0.7)
    ax.scatter(eps_vals, chi_bounds, s=20, marker='^', color=colors[idx],
               alpha=0.4, label=f'n={n}')

ax.set_xlabel('Effective ε')
ax.set_ylabel('Susceptibility')
ax.set_title('Susceptibility vs Bound\n(dots = actual, triangles = bound)')
ax.legend(fontsize=8)

# Panel 2: Max pairwise chi-sq vs epsilon^2
ax = axes[1]
for n, color in [(5, '#1976D2'), (7, '#388E3C')]:
    r = n // 2
    eps_sq = []
    max_chi2 = []

    for eps_mult in np.linspace(0.01, 0.5, 20):
        law = perturbed_matroid_law(n, r, eps_mult, seed=100)
        max_ratio = 0
        for i in range(n):
            for j in range(i+1, n):
                pi, pj = coord_prob(law, i), coord_prob(law, j)
                c = abs(coord_cov(law, i, j))
                if pi * pj > 0:
                    max_ratio = max(max_ratio, c / (pi * pj))
        eps = max_ratio * 1.01
        eps_sq.append(eps**2)

        mc = 0
        for i in range(n):
            for j in range(i+1, n):
                pi, pj = coord_prob(law, i), coord_prob(law, j)
                c = coord_cov(law, i, j)
                d = pi*(1-pi)*pj*(1-pj)
                if d > 0:
                    mc = max(mc, c**2/d)
        max_chi2.append(mc)

    ax.scatter(eps_sq, max_chi2, s=25, color=color, alpha=0.7, label=f'n={n}')

ax.plot([0, max(eps_sq)*1.1], [0, max(eps_sq)*1.1], 'k--', alpha=0.3,
        label='y = x (reference)')
ax.set_xlabel('ε²')
ax.set_ylabel('Max χ²(i,j)')
ax.set_title('Pairwise MI Scales as O(ε²)\n(information contraction)')
ax.legend(fontsize=8)

# Panel 3: Entropy retention under sequential deletion
ax = axes[2]
for n, color in [(5, '#1976D2'), (7, '#388E3C'), (9, '#F57C00')]:
    r = n // 2
    law = uniform_matroid_law(n, r)
    H = total_entropy(law)

    retentions = [1.0]
    lower_bounds = [1.0]
    for k in range(n):
        Hk = delete_coord_entropy(law, k)
        retentions.append(Hk / H if H > 0 else 0)
        lb = max(0, H - (k+1) * log(2)) / H if H > 0 else 0
        lower_bounds.append(lb)

    ax.plot(range(n+1), retentions[:n+1], 'o-', color=color,
            label=f'n={n}', linewidth=2, markersize=4)
    ax.plot(range(n+1), lower_bounds[:n+1], ':', color=color, alpha=0.5)

ax.set_xlabel('Coordinates deleted')
ax.set_ylabel('Entropy fraction retained')
ax.set_title('Entropy Retention Under Deletion\n(solid = actual, dotted = certified lb)')
ax.legend(fontsize=8)
ax.set_ylim(0, 1.05)

plt.suptitle('Susceptibility, MI Scaling, and Entropy Stability',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('susceptibility_scaling.png', dpi=150, bbox_inches='tight')
print("Saved susceptibility_scaling.png")
