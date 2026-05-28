"""
Visualization: Prime Birth Spectrum Heatmap

Shows the complete primewise birth spectrum for a collection of persistence
modules, displayed as a heatmap. Each row is a module, each column is a prime,
and the color indicates the birth index.

WHAT THIS VISUALIZES:
A heatmap showing when torsion at each prime first appears across a collection
of random persistence modules. This reveals the arithmetic structure of
persistence data: some modules have early 2-torsion but late 3-torsion,
others show simultaneous births, and some primes are entirely absent.
The visualization demonstrates that the global torsion birth (rightmost column)
is always the minimum of the primewise births, confirming the decomposition theorem.
"""

import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import numpy as np
import random


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

    def has_global_torsion(self):
        return len(self.torsion_coeffs) > 0

    def prime_support(self):
        primes = set()
        for c in self.torsion_coeffs:
            primes |= distinct_prime_factors(c)
        return primes


class PersistenceModule:
    def __init__(self, groups):
        self.groups = groups

    def p_torsion_birth(self, p):
        for i, g in enumerate(self.groups):
            if g.has_p_torsion(p):
                return i
        return None

    def global_torsion_birth(self):
        for i, g in enumerate(self.groups):
            if g.has_global_torsion():
                return i
        return None

    def prime_support(self):
        s = set()
        for g in self.groups:
            s |= g.prime_support()
        return s


def random_persistence_module(length=12, primes=None):
    if primes is None:
        primes = [2, 3, 5, 7]
    groups = []
    current_torsion = []
    free_rank = random.randint(0, 2)
    for _ in range(length):
        if random.random() < 0.3:
            p = random.choice(primes)
            k = random.randint(1, 2)
            current_torsion.append(p ** k)
        groups.append(FGAbGroup(free_rank, list(current_torsion)))
    return PersistenceModule(groups)


# --- Generate data ---
random.seed(42)
n_modules = 25
length = 12
primes = [2, 3, 5, 7]
modules = [random_persistence_module(length=length, primes=primes)
           for _ in range(n_modules)]

# Build the data matrix
# Columns: p=2, p=3, p=5, p=7, Global
col_labels = [f'p = {p}' for p in primes] + ['Global']
n_cols = len(col_labels)

data = np.full((n_modules, n_cols), np.nan)

for i, F in enumerate(modules):
    for j, p in enumerate(primes):
        b = F.p_torsion_birth(p)
        if b is not None:
            data[i, j] = b
    gb = F.global_torsion_birth()
    if gb is not None:
        data[i, -1] = gb

# Sort by global birth index
sort_idx = np.argsort(np.where(np.isnan(data[:, -1]), 999, data[:, -1]))
data = data[sort_idx]

# --- Plot ---
fig, ax = plt.subplots(figsize=(10, 10))

# Custom colormap: white for NaN, blues for birth indices
cmap = plt.cm.YlOrRd_r.copy()
cmap.set_bad(color='#f5f5f5')

# Create masked array
masked_data = np.ma.masked_invalid(data)

im = ax.imshow(masked_data, cmap=cmap, aspect='auto',
               vmin=0, vmax=length - 1, interpolation='nearest')

# Add text annotations
for i in range(n_modules):
    for j in range(n_cols):
        if not np.isnan(data[i, j]):
            val = int(data[i, j])
            text_color = 'white' if val > length * 0.6 else 'black'
            ax.text(j, i, str(val), ha='center', va='center',
                    fontsize=9, fontweight='bold', color=text_color)
        else:
            ax.text(j, i, '—', ha='center', va='center',
                    fontsize=9, color='#cccccc')

# Formatting
ax.set_xticks(range(n_cols))
ax.set_xticklabels(col_labels, fontsize=11, fontweight='bold')
ax.set_yticks(range(n_modules))
ax.set_yticklabels([f'Module {i+1}' for i in range(n_modules)], fontsize=9)

# Add vertical line before "Global" column
ax.axvline(x=n_cols - 1.5, color='#2c3e50', linewidth=2, linestyle='--')

ax.set_title('Prime Birth Spectrum: Torsion Birth Index by Prime Channel\n'
             'Each cell shows when torsion at that prime first appears in the filtration',
             fontsize=13, fontweight='bold', pad=15)

# Colorbar
cbar = plt.colorbar(im, ax=ax, shrink=0.6, pad=0.02)
cbar.set_label('Birth Index (filtration level)', fontsize=10)

# Add annotation
ax.text(0.5, -0.06,
        'Global birth = min of primewise births (decomposition theorem). '
        '"—" = prime torsion never appears.',
        transform=ax.transAxes, ha='center', fontsize=10,
        style='italic', color='#555555')

plt.tight_layout()
plt.savefig('viz_birth_spectrum.png', dpi=150, bbox_inches='tight',
            facecolor='white', edgecolor='none')
print("Saved viz_birth_spectrum.png")
