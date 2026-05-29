"""
Visualization: Family Separation by Persistence Profiles

Shows how the filtration cardinality profile separates binomial from
trinomial families across different primes and parameters. Directly
illustrates the formally proved family separation theorem.
"""

import numpy as np
import matplotlib.pyplot as plt


def padic_val(n, p):
    if n == 0: return 100
    n = abs(n)
    v = 0
    while n % p == 0:
        v += 1
        n //= p
    return v

def is_prime(n):
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0: return False
        i += 6
    return True

def primes_up_to(n):
    return [p for p in range(2, n + 1) if is_prime(p)]

def filtration_profile(support, coeffs, p, max_level=10):
    return [sum(1 for m in support if coeffs.get(m, 0) != 0 and padic_val(coeffs[m], p) <= t)
            for t in range(max_level + 1)]


fig, axes = plt.subplots(2, 3, figsize=(16, 10))
fig.suptitle("Arithmetic Family Separation via Persistence Profiles",
             fontsize=16, fontweight='bold')

n = 5
c = 7  # coprime to small primes

primes_to_show = [2, 3, 5]
r_values = [1, 2]

for row, r in enumerate(r_values):
    for col, p in enumerate(primes_to_show):
        ax = axes[row, col]
        max_lev = r + 5
        levels = list(range(max_lev + 1))
        
        # Binomial x^n + c
        s_bin = [(0,), (n,)]
        c_bin = {(0,): c, (n,): 1}
        prof_bin = filtration_profile(s_bin, c_bin, p, max_lev)
        
        # Trinomial x^n + p^r * x + c
        s_tri = [(0,), (1,), (n,)]
        c_tri = {(0,): c, (1,): p**r, (n,): 1}
        prof_tri = filtration_profile(s_tri, c_tri, p, max_lev)
        
        ax.step(levels, prof_bin, where='mid', linewidth=2.5, color='#2196F3',
                label=f'Binomial $x^{n}+{c}$', marker='o', markersize=6)
        ax.step(levels, prof_tri, where='mid', linewidth=2.5, color='#FF5722',
                label=f'Trinomial $x^{n}+{p}^{r}x+{c}$', marker='s', markersize=6)
        
        # Mark the separation point
        for t in levels:
            if prof_bin[t] != prof_tri[t]:
                ax.axvline(x=t, color='gold', linestyle='--', alpha=0.7, linewidth=1.5)
                ax.annotate(f'Separation\nat t={t}',
                           xy=(t, (prof_bin[t] + prof_tri[t])/2),
                           xytext=(t + 1.5, (prof_bin[t] + prof_tri[t])/2),
                           arrowprops=dict(arrowstyle='->', color='gray'),
                           fontsize=8, color='gray')
                break
        
        ax.set_xlabel("Filtration Level t", fontsize=11)
        ax.set_ylabel("Support Cardinality", fontsize=11)
        ax.set_title(f"p = {p}, r = {r}", fontsize=12, fontweight='bold')
        ax.legend(fontsize=8, loc='lower right')
        ax.set_ylim(-0.2, max(max(prof_bin), max(prof_tri)) + 0.5)
        ax.set_xlim(-0.5, max_lev + 0.5)
        ax.grid(True, alpha=0.3)
        ax.set_xticks(levels)

plt.tight_layout(rect=[0, 0.06, 1, 0.94])
fig.text(0.5, 0.01,
         "The trinomial's extra monomial (degree 1, coefficient p^r) enters the filtration at level r,\n"
         "creating a persistent jump. This is the formally proved family separation theorem.",
         ha='center', fontsize=10, style='italic')

plt.savefig("family_separation.png", dpi=150, bbox_inches='tight')
print("Saved family_separation.png")
