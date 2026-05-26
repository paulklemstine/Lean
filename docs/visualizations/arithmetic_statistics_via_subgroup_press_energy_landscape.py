"""
Visualization: Energy Landscape of Compositions

Shows the parabolic index weight w_q(c) for all compositions of n,
colored by the number of parts, demonstrating the quadratic energy bounds.
"""
import math
import matplotlib.pyplot as plt
import numpy as np

def q_int(q, k):
    return sum(q**i for i in range(k)) if k > 0 else 0

def q_factorial(q, k):
    r = 1
    for i in range(1, k+1): r *= q_int(q, i)
    return r

def q_multinomial(q, c):
    if len(c) <= 1: return 1
    n = sum(c)
    r = q_factorial(q, n)
    for ci in c: r //= q_factorial(q, ci)
    return r

def cross_term(c):
    t, s = 0, sum(c)
    for ci in c: s -= ci; t += ci * s
    return t

def compositions(n):
    if n == 0: return [[]]
    result = []
    for k in range(1, n+1):
        for rest in compositions(n-k):
            result.append([k] + rest)
    return result

fig, axes = plt.subplots(1, 2, figsize=(14, 6))
q = 2

# Left: Energy vs cross-term for different n
ax = axes[0]
for n in [4, 5, 6, 7]:
    comps = compositions(n)
    cts = [cross_term(c) for c in comps]
    ws = [math.log(q_multinomial(q, c)) for c in comps]
    ax.scatter(cts, ws, s=20, alpha=0.6, label=f'n={n}')

# Plot bounds
ct_range = np.linspace(0, 15, 100)
ax.plot(ct_range, ct_range * math.log(q), 'k-', linewidth=2, label='Lower: ct·log q')
ax.fill_between(ct_range, ct_range * math.log(q),
                ct_range * math.log(q) + 8 * math.log(q),
                alpha=0.1, color='gray', label='Upper gap: n·log q')

ax.set_xlabel('Cross-term Σᵢ<ⱼ nᵢnⱼ', fontsize=13)
ax.set_ylabel('Weight w_q(c) = log[n; c]_q', fontsize=13)
ax.set_title('Energy vs Cross-Term (q=2)', fontsize=14)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Right: Histogram of energies for n=7
ax = axes[1]
n = 7
comps = compositions(n)
ws = [math.log(q_multinomial(q, c)) for c in comps]
parts = [len(c) for c in comps]

for k in sorted(set(parts)):
    w_k = [w for w, p in zip(ws, parts) if p == k]
    ax.hist(w_k, bins=15, alpha=0.6, label=f'{k} parts')

ax.set_xlabel('Weight w_q(c)', fontsize=13)
ax.set_ylabel('Count', fontsize=13)
ax.set_title(f'Energy Distribution (n={n}, q={q})', fontsize=14)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('energy_landscape.png', dpi=150, bbox_inches='tight')
print("Saved energy_landscape.png")
