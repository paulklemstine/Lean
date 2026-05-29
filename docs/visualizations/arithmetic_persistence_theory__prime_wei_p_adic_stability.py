"""
Visualization: p-adic Stability Theorem

Illustrates the stability theorem: when coefficients are perturbed by 
multiples of p^k, the filtration profiles agree up to level k-1.
This is the arithmetic analog of the stability theorem in persistent homology.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


def padic_val(n, p):
    if n == 0: return 100
    n = abs(n)
    v = 0
    while n % p == 0:
        v += 1
        n //= p
    return v

def filtration_profile(support, coeffs, p, max_level=10):
    return [sum(1 for m in support if coeffs.get(m, 0) != 0 and padic_val(coeffs[m], p) <= t)
            for t in range(max_level + 1)]


fig, axes = plt.subplots(1, 3, figsize=(18, 6))
fig.suptitle("p-adic Stability: Perturbation Resilience of Filtration Profiles",
             fontsize=15, fontweight='bold')

p = 3
base_coeffs = {(0,): 5, (1,): 7, (2,): 11, (3,): 2, (4,): 1}
support = list(base_coeffs.keys())
max_lev = 8

colors_pert = ['#4CAF50', '#FF9800', '#9C27B0', '#00BCD4', '#795548']

for idx, k in enumerate([2, 3, 4]):
    ax = axes[idx]
    levels = list(range(max_lev + 1))
    
    base_prof = filtration_profile(support, base_coeffs, p, max_lev)
    ax.step(levels, base_prof, where='mid', linewidth=3, color='#2196F3',
            label='Original', marker='o', markersize=8, zorder=5)
    
    # Multiple perturbations
    for j, mult in enumerate([1, 2, 5, -1, 3]):
        perturbed = {m: c + mult * p**k for m, c in base_coeffs.items()}
        pert_prof = filtration_profile(support, perturbed, p, max_lev)
        ax.step(levels, pert_prof, where='mid', linewidth=1.5,
                color=colors_pert[j], alpha=0.7,
                label=f'+ {mult}·{p}^{k}', marker='.', markersize=5)
    
    # Shade the stability region
    ax.axvspan(-0.5, k - 0.5, alpha=0.15, color='green')
    ax.text(max(0, k/2 - 0.5), max(base_prof) + 0.3,
            f"Guaranteed\nagreement\n(levels 0–{k-1})",
            ha='center', fontsize=9, color='green', fontweight='bold')
    
    # Mark boundary
    ax.axvline(x=k - 0.5, color='red', linestyle=':', linewidth=2, alpha=0.7)
    
    ax.set_xlabel("Filtration Level t", fontsize=11)
    ax.set_ylabel("Support Cardinality", fontsize=11)
    ax.set_title(f"Perturbation by multiples of p^{k} = {p}^{k} = {p**k}",
                 fontsize=11, fontweight='bold')
    ax.legend(fontsize=8, loc='lower right')
    ax.grid(True, alpha=0.3)
    ax.set_xticks(levels)
    ax.set_ylim(-0.3, max(base_prof) + 1.2)

plt.tight_layout(rect=[0, 0.08, 1, 0.92])
fig.text(0.5, 0.01,
         "The stability theorem proves that if coefficients agree mod p^(t+1), "
         "filtration profiles match up to level t.\n"
         "Green regions show the guaranteed agreement zone. "
         "Beyond this, profiles may diverge.",
         ha='center', fontsize=10, style='italic')

plt.savefig("stability_theorem.png", dpi=150, bbox_inches='tight')
print("Saved stability_theorem.png")
