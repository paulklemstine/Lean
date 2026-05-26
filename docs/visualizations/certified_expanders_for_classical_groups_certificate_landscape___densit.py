"""
Visualization 3: Certificate Landscape — Density and Gap Distribution

This script visualizes the "landscape" of certified generator pairs
in GL₂(GF(p)), showing:
- The density of regular toral elements (irreducible charpoly)
- The spectral gap distribution across certified pairs
- How certificate density scales with field size

This illustrates the key prediction of the certified expander program:
certificates are dense enough to find algorithmically, and the gaps
they produce are uniformly bounded away from zero.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product as iterproduct


# === Inline helper functions ===

def mat_mul_gfp(A, B, p):
    return np.mod(A.astype(int) @ B.astype(int), p).astype(int)

def mat_det_gfp(M, p):
    n = M.shape[0]
    if n == 2: return (int(M[0,0])*int(M[1,1]) - int(M[0,1])*int(M[1,0])) % p
    return 0

def mat_inv_gfp(M, p):
    det = mat_det_gfp(M, p)
    if det == 0: return None
    det_inv = pow(det, p-2, p)
    if M.shape[0] == 2:
        return np.array([[M[1,1]*det_inv % p, (p - M[0,1])*det_inv % p],
                         [(p - M[1,0])*det_inv % p, M[0,0]*det_inv % p]], dtype=int)
    return None

def charpoly_2x2(M, p):
    """Returns [c0, c1, 1] for charpoly x² - tr·x + det."""
    tr = (int(M[0,0]) + int(M[1,1])) % p
    det = mat_det_gfp(M, p)
    return [det, (p - tr) % p, 1]

def is_irreducible_degree2(coeffs, p):
    """Check if x² + bx + c is irreducible over GF(p) by checking for roots."""
    c0, c1 = coeffs[0], coeffs[1]
    for x in range(p):
        val = (x*x + c1*x + c0) % p
        if val == 0:
            return False
    return True


# === Main computation ===

primes = [3, 5, 7, 11, 13]
densities = []
gl2_orders = []

for p in primes:
    total = 0
    regular_toral = 0
    for a, b, c, d in iterproduct(range(p), repeat=4):
        det = (a*d - b*c) % p
        if det == 0: continue
        total += 1
        M = np.array([[a,b],[c,d]], dtype=int)
        cp = charpoly_2x2(M, p)
        if is_irreducible_degree2(cp, p):
            regular_toral += 1
    densities.append(regular_toral / total)
    gl2_orders.append(total)

# Theoretical prediction: density ≈ 1/2 for GL₂
# (fraction of monic degree-2 polynomials over GF(p) that are irreducible is (p²-p)/2p² ≈ 1/2)
theoretical = [(p**2 - p) / (2 * p**2) for p in primes]

# === Visualization ===

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Plot 1: Certificate density vs prime
ax1 = axes[0]
x_pos = np.arange(len(primes))
bars = ax1.bar(x_pos - 0.15, densities, 0.3, label='Measured density', color='#2196F3', alpha=0.8)
bars2 = ax1.bar(x_pos + 0.15, theoretical, 0.3, label='Theoretical (p²−p)/2p²', color='#FF9800', alpha=0.8)
ax1.set_xticks(x_pos)
ax1.set_xticklabels([f'p={p}' for p in primes], fontsize=11)
ax1.set_ylabel('Fraction of GL₂(GF(p))', fontsize=12)
ax1.set_title('Regular Toral Density', fontsize=13, fontweight='bold')
ax1.legend(fontsize=10)
ax1.set_ylim(0, 0.7)
ax1.grid(True, alpha=0.2)

# Add value labels
for bar, val in zip(bars, densities):
    ax1.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.01,
             f'{val:.3f}', ha='center', va='bottom', fontsize=9)

# Plot 2: Spectral gap distribution for GL₂(GF(3))
ax2 = axes[1]
p = 3
# Compute gaps for multiple certified pairs
gaps = []
all_gl2 = []
for a, b, c, d in iterproduct(range(p), repeat=4):
    det = (a*d - b*c) % p
    if det != 0:
        all_gl2.append(np.array([[a,b],[c,d]], dtype=int))

# Find regular toral elements
regular = [M for M in all_gl2 if is_irreducible_degree2(charpoly_2x2(M, p), p)]

# For a sample of certified pairs, compute spectral gaps
np.random.seed(42)
sample_size = min(20, len(regular))
sampled_s = [regular[i] for i in np.random.choice(len(regular), sample_size, replace=False)]

for s in sampled_s:
    # Pick a few t values
    for _ in range(3):
        t = all_gl2[np.random.randint(len(all_gl2))]
        if np.array_equal(s, t): continue

        # Quick generation check
        identity = np.eye(2, dtype=int)
        def key(M): return tuple(M.flatten() % p)
        seen = {key(identity)}
        queue = [identity.copy()]
        elements = [identity.copy()]
        gens = [s % p, t % p]
        for g in [s, t]:
            gi = mat_inv_gfp(g, p)
            if gi is not None: gens.append(gi % p)

        idx = 0
        while idx < len(queue) and len(elements) < 200:
            cur = queue[idx]; idx += 1
            for gen in gens:
                prod = mat_mul_gfp(cur, gen, p)
                k = key(prod)
                if k not in seen:
                    seen.add(k)
                    queue.append(prod.copy())
                    elements.append(prod.copy())

        if len(elements) < len(all_gl2):
            continue  # Doesn't generate

        # Build adjacency and compute gap
        n = len(elements)
        idx_map = {key(e): i for i, e in enumerate(elements)}
        adj = np.zeros((n, n), dtype=int)
        for i, elem in enumerate(elements):
            for gen in gens:
                prod = mat_mul_gfp(elem, gen, p)
                k = key(prod)
                if k in idx_map: adj[i, idx_map[k]] = 1

        eigs = np.sort(np.real(np.linalg.eigvalsh(adj)))[::-1]
        d = eigs[0]
        if d > 0:
            lambda2 = max(abs(eigs[1]), abs(eigs[-1]))
            gap = 1 - lambda2/d
            gaps.append(gap)

if gaps:
    ax2.hist(gaps, bins=15, color='#4CAF50', edgecolor='black', alpha=0.8)
    ax2.axvline(x=np.mean(gaps), color='red', linewidth=2, linestyle='--',
                label=f'Mean = {np.mean(gaps):.4f}')
    ax2.set_xlabel('Normalized spectral gap', fontsize=12)
    ax2.set_ylabel('Count', fontsize=12)
    ax2.set_title(f'Gap Distribution for GL₂(GF(3))\n({len(gaps)} certified pairs)',
                  fontsize=13, fontweight='bold')
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.2)

# Plot 3: Group order vs spectral gap (scaling)
ax3 = axes[2]
scaling_data = []
for p in [3, 5, 7]:
    s_mat = np.array([[0,1],[p-1,0]], dtype=int)
    t_mat = np.array([[1,1],[0,1]], dtype=int)

    identity = np.eye(2, dtype=int)
    def key(M): return tuple(M.flatten() % p)
    seen = {key(identity)}
    queue = [identity.copy()]
    elements = [identity.copy()]
    gens = [s_mat % p, t_mat % p]
    for g in [s_mat, t_mat]:
        gi = mat_inv_gfp(g, p)
        if gi is not None: gens.append(gi % p)

    idx = 0
    while idx < len(queue):
        cur = queue[idx]; idx += 1
        for gen in gens:
            prod = mat_mul_gfp(cur, gen, p)
            k = key(prod)
            if k not in seen:
                seen.add(k)
                queue.append(prod.copy())
                elements.append(prod.copy())

    n = len(elements)
    idx_map = {key(e): i for i, e in enumerate(elements)}
    adj = np.zeros((n, n), dtype=int)
    for i, elem in enumerate(elements):
        for gen in gens:
            prod = mat_mul_gfp(elem, gen, p)
            k = key(prod)
            if k in idx_map: adj[i, idx_map[k]] = 1

    eigs = np.sort(np.real(np.linalg.eigvalsh(adj)))[::-1]
    d = eigs[0]
    if d > 0:
        lambda2 = max(abs(eigs[1]), abs(eigs[-1]))
        gap = 1 - lambda2/d
        scaling_data.append((n, gap, p))

if scaling_data:
    orders = [d[0] for d in scaling_data]
    gap_vals = [d[1] for d in scaling_data]
    labels = [f'p={d[2]}' for d in scaling_data]

    ax3.scatter(orders, gap_vals, s=120, c='#E91E63', zorder=5, edgecolor='black')
    ax3.plot(orders, gap_vals, '--', color='#E91E63', alpha=0.5)
    for i, label in enumerate(labels):
        ax3.annotate(label, (orders[i], gap_vals[i]), textcoords="offset points",
                    xytext=(10, 5), fontsize=11)

    ax3.set_xlabel('Group order |G|', fontsize=12)
    ax3.set_ylabel('Normalized spectral gap', fontsize=12)
    ax3.set_title('Gap Scaling with Group Size', fontsize=13, fontweight='bold')
    ax3.set_xscale('log')
    ax3.grid(True, alpha=0.2)
    ax3.set_ylim(0, max(gap_vals) * 1.3)

plt.suptitle('Certificate Landscape for Certified Expanders',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_certificate_landscape.png', dpi=150, bbox_inches='tight')
print("Saved: viz_certificate_landscape.png")
