"""
Visualization: Prime Channel Decomposition of Persistence Modules

Shows how localization at different primes decomposes the global torsion
profile into independent prime channels, acting as a "spectral filter"
for persistence data.

WHAT THIS VISUALIZES:
A persistence module with mixed torsion is decomposed into its prime channels
via localization. The top panel shows the global torsion profile, and the
lower panels show the isolated p-primary channel after localization at each prime.
This demonstrates that the global signal is the superposition of independent
prime-frequency channels.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


# --- Inline all needed functions ---
def prime_factors(n):
    factors = []
    d = 2
    while d * d <= abs(n):
        while n % d == 0:
            factors.append(d)
            n //= d
        d += 1
    if abs(n) > 1:
        factors.append(abs(n))
    return factors

def distinct_prime_factors(n):
    return set(prime_factors(n))

def p_part(n, p):
    result = 1
    while n % p == 0:
        result *= p
        n //= p
    return result


class FGAbGroup:
    def __init__(self, free_rank, torsion_coeffs=None):
        self.free_rank = free_rank
        self.torsion_coeffs = sorted([c for c in (torsion_coeffs or []) if c >= 2])

    def has_p_torsion(self, p):
        return any(c % p == 0 for c in self.torsion_coeffs)

    def prime_support(self):
        primes = set()
        for c in self.torsion_coeffs:
            primes |= distinct_prime_factors(c)
        return primes

    def localize_at(self, p):
        new_torsion = [pk for c in self.torsion_coeffs if (pk := p_part(c, p)) > 1]
        return FGAbGroup(self.free_rank, new_torsion)

    def torsion_rank(self):
        return len(self.torsion_coeffs)


class PersistenceModule:
    def __init__(self, groups):
        self.groups = groups

    def localize_at(self, p):
        return PersistenceModule([g.localize_at(p) for g in self.groups])

    def torsion_profile(self):
        return [g.torsion_rank() for g in self.groups]

    def prime_support(self):
        s = set()
        for g in self.groups:
            s |= g.prime_support()
        return s


# --- Build example module ---
length = 15
groups = [FGAbGroup(1, [])]
current_torsion = []

# Schedule: different primes appear at different times
schedule = {
    2: [2, 5, 8, 11],
    3: [4, 7, 10],
    5: [6, 12],
    7: [9],
}

for i in range(1, length):
    new_tors = list(current_torsion)
    for p, levels in schedule.items():
        if i in levels:
            new_tors.append(p)
    current_torsion = new_tors
    groups.append(FGAbGroup(1, list(current_torsion)))

F = PersistenceModule(groups)
primes = sorted(F.prime_support())
colors = {2: '#e74c3c', 3: '#3498db', 5: '#2ecc71', 7: '#9b59b6'}
prime_names = {2: 'p = 2', 3: 'p = 3', 5: 'p = 5', 7: 'p = 7'}

# --- Create figure ---
fig, axes = plt.subplots(len(primes) + 1, 1, figsize=(12, 10),
                          sharex=True, gridspec_kw={'hspace': 0.3})

x = np.arange(length)

# Top panel: global torsion profile
ax = axes[0]
profile = F.torsion_profile()
ax.bar(x, profile, color='#2c3e50', alpha=0.8, edgecolor='white', linewidth=0.5)
ax.set_ylabel('Torsion\nRank', fontsize=10)
ax.set_title('Prime Channel Decomposition of a Persistence Module\n'
             'Global torsion signal vs. individual prime channels after localization',
             fontsize=13, fontweight='bold', pad=10)
ax.text(0.02, 0.85, 'Global (all primes)',
        transform=ax.transAxes, fontsize=11, fontweight='bold',
        bbox=dict(boxstyle='round', facecolor='#2c3e50', alpha=0.15))
ax.set_ylim(0, max(profile) + 1)
ax.grid(axis='y', alpha=0.3)

# Lower panels: each prime channel
for idx, p in enumerate(primes):
    ax = axes[idx + 1]
    L = F.localize_at(p)
    lp = L.torsion_profile()
    color = colors.get(p, '#95a5a6')

    ax.bar(x, lp, color=color, alpha=0.75, edgecolor='white', linewidth=0.5)
    ax.set_ylabel('Torsion\nRank', fontsize=10)

    # Mark birth index
    birth = next((i for i, v in enumerate(lp) if v > 0), None)
    if birth is not None:
        ax.annotate(f'Birth at {birth}', xy=(birth, lp[birth]),
                    xytext=(birth + 1.5, lp[birth] + 0.3),
                    arrowprops=dict(arrowstyle='->', color=color, lw=1.5),
                    fontsize=9, color=color, fontweight='bold')

    ax.text(0.02, 0.78, f'Localized at {prime_names[p]}',
            transform=ax.transAxes, fontsize=11, fontweight='bold',
            bbox=dict(boxstyle='round', facecolor=color, alpha=0.15))
    ax.set_ylim(0, max(max(lp) + 1, 2))
    ax.grid(axis='y', alpha=0.3)

axes[-1].set_xlabel('Filtration Index', fontsize=12)
axes[-1].set_xticks(x)

# Add annotation
fig.text(0.5, 0.01,
         'Localization at p isolates the p-primary torsion channel: '
         'only p-power torsion survives, all other primes vanish.',
         ha='center', fontsize=10, style='italic', color='#555555')

plt.tight_layout(rect=[0, 0.03, 1, 1])
plt.savefig('viz_prime_channels.png', dpi=150, bbox_inches='tight',
            facecolor='white', edgecolor='none')
print("Saved viz_prime_channels.png")
