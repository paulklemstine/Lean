"""
Visualization: Degeneracy Landscape

Shows for each pair of endomorphisms (r1, r2) on ℤ/mℤ whether the resulting
persistence module is degenerate, and how TPS values correlate with degeneracy.
"""

import math
import numpy as np
import matplotlib.pyplot as plt


def prime_factors(n):
    factors = set()
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors.add(d)
            n //= d
        d += 1
    if n > 1:
        factors.add(n)
    return sorted(factors)


def compose(m, endos, k, a):
    result = a % m
    for i in range(min(k, len(endos))):
        result = (endos[i] * result) % m
    return result


def is_degenerate(m, endos):
    n = len(endos)
    for a in range(m):
        c1 = compose(m, endos, 1, a)
        if c1 != 0:
            for k in range(2, n + 1):
                if compose(m, endos, k, a) == 0:
                    return False
    return True


def compute_tps(m, endos, p):
    n = len(endos)
    max_persistence = 0
    for a in range(1, m):
        pk = p
        is_pt = False
        while pk <= m * m:
            if (pk * a) % m == 0:
                is_pt = True
                break
            pk *= p
        if not is_pt:
            continue
        x = a
        steps = 0
        for i in range(n):
            x = (endos[i] * x) % m
            if x == 0:
                break
            steps = i + 1
        max_persistence = max(max_persistence, steps)
    return max_persistence


def max_tps(m, endos):
    pf = prime_factors(m)
    if not pf:
        return 0
    return max(compute_tps(m, endos, p) for p in pf)


# Create degeneracy landscape for ℤ/12ℤ
m = 12
fig, axes = plt.subplots(1, 2, figsize=(16, 7))

# Panel 1: Degeneracy map
degen_map = np.zeros((m, m))
tps_map = np.zeros((m, m))

for r1 in range(m):
    for r2 in range(m):
        endos = [r1, r2]
        degen_map[r1, r2] = 1 if is_degenerate(m, endos) else 0
        tps_map[r1, r2] = max_tps(m, endos)

ax1 = axes[0]
im1 = ax1.imshow(degen_map, cmap='RdYlGn', interpolation='nearest', origin='lower')
ax1.set_xlabel('r₂ (second endomorphism)', fontsize=12)
ax1.set_ylabel('r₁ (first endomorphism)', fontsize=12)
ax1.set_title(f'Degeneracy Landscape: ℤ/{m}ℤ\n(Green = degenerate, Red = non-degenerate)',
              fontsize=13)
plt.colorbar(im1, ax=ax1, label='Degenerate?', shrink=0.8)

ax2 = axes[1]
im2 = ax2.imshow(tps_map, cmap='viridis', interpolation='nearest', origin='lower')
ax2.set_xlabel('r₂ (second endomorphism)', fontsize=12)
ax2.set_ylabel('r₁ (first endomorphism)', fontsize=12)
ax2.set_title(f'Max TPS Landscape: ℤ/{m}ℤ\n(Darker = lower TPS)',
              fontsize=13)
plt.colorbar(im2, ax=ax2, label='max TPS(p)', shrink=0.8)

# Count statistics
total = m * m
degen_count = int(degen_map.sum())
fig.text(0.5, 0.02,
         f'ℤ/{m}ℤ: {degen_count}/{total} modules are degenerate ({100*degen_count/total:.1f}%)',
         ha='center', fontsize=12, style='italic')

plt.tight_layout(rect=[0, 0.05, 1, 1])
plt.savefig('degeneracy_landscape.png', dpi=150, bbox_inches='tight')
print("Saved degeneracy_landscape.png")
