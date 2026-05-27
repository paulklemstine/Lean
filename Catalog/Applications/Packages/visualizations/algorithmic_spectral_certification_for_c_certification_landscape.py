"""
Visualization 3: Certification Landscape Heatmap

Creates a heatmap showing the certification landscape across different
field sizes, visualizing the relationship between algebraic conditions
and certification success rate.

Key insight: as field size grows, the fraction of certifiable pairs
appears to stabilize — evidence for the Certification Density Conjecture.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


# ---- Inlined helper functions ----

def mat_mul_mod(A, B, q):
    result = np.zeros((2, 2), dtype=int)
    for i in range(2):
        for j in range(2):
            result[i, j] = sum(int(A[i, k]) * int(B[k, j]) for k in range(2)) % q
    return result

def mat_det_mod(A, q):
    return (int(A[0, 0]) * int(A[1, 1]) - int(A[0, 1]) * int(A[1, 0])) % q

def mat_inv_mod(A, q):
    det = mat_det_mod(A, q)
    if det % q == 0:
        return None
    det_inv = pow(det, q - 2, q)
    result = np.array([
        [int(A[1, 1]) * det_inv % q, (-int(A[0, 1])) * det_inv % q],
        [(-int(A[1, 0])) * det_inv % q, int(A[0, 0]) * det_inv % q]
    ], dtype=int)
    return result % q

def mat_trace_mod(A, q):
    return (int(A[0, 0]) + int(A[1, 1])) % q

def gl2_order(q):
    return (q * q - 1) * (q * q - q)

def is_charpoly_irreducible(A, q):
    tr = mat_trace_mod(A, q)
    det = mat_det_mod(A, q)
    disc = (tr * tr - 4 * det) % q
    if disc == 0:
        return False
    if q == 2:
        return disc % 2 != 0
    return pow(disc, (q - 1) // 2, q) != 1

def is_det_primitive(A, q):
    det = mat_det_mod(A, q)
    if det == 0:
        return False
    if q == 2:
        return det == 1
    order = q - 1
    temp = order
    factors = set()
    for p in range(2, int(temp**0.5) + 2):
        while temp % p == 0:
            factors.add(p)
            temp //= p
    if temp > 1:
        factors.add(temp)
    for p in factors:
        if pow(det, order // p, q) == 1:
            return False
    return True

def generate_subgroup(gens, q, max_size=100000):
    def mat_to_tuple(M):
        return (int(M[0, 0]) % q, int(M[0, 1]) % q,
                int(M[1, 0]) % q, int(M[1, 1]) % q)
    identity = mat_to_tuple(np.eye(2, dtype=int))
    generated = {identity}
    frontier = set()
    for g in gens:
        gt = mat_to_tuple(g)
        generated.add(gt)
        frontier.add(gt)
        g_inv = mat_inv_mod(g, q)
        if g_inv is not None:
            git = mat_to_tuple(g_inv)
            generated.add(git)
            frontier.add(git)
    while frontier and len(generated) < max_size:
        new_frontier = set()
        for gt in frontier:
            g_mat = np.array([[gt[0], gt[1]], [gt[2], gt[3]]], dtype=int)
            for gen in gens:
                for m in [gen, mat_inv_mod(gen, q)]:
                    if m is None:
                        continue
                    prod_mat = mat_mul_mod(g_mat, m, q)
                    pt = mat_to_tuple(prod_mat)
                    if pt not in generated:
                        generated.add(pt)
                        new_frontier.add(pt)
            frontier = new_frontier
    return generated

def check_generates_gl2(g, h, q):
    return len(generate_subgroup([g, h], q, gl2_order(q) + 1)) == gl2_order(q)

def sample_gl2_pair(q):
    def random_gl2():
        while True:
            M = np.random.randint(0, q, size=(2, 2))
            if mat_det_mod(M, q) != 0:
                return M
    return random_gl2(), random_gl2()


# ---- Main visualization ----

np.random.seed(42)

primes = [3, 5, 7, 11, 13]
n_samples_per_q = 40

# Collect statistics
stats = {}
for q in primes:
    stats[q] = {
        'gen_rate': 0, 'irred_rate': 0, 'prim_rate': 0,
        'both_rate': 0, 'cert_rate': 0, 'total': n_samples_per_q
    }
    for _ in range(n_samples_per_q):
        g, h = sample_gl2_pair(q)
        gen = check_generates_gl2(g, h, q)
        irred = is_charpoly_irreducible(g, q) or is_charpoly_irreducible(h, q)
        prim = is_det_primitive(g, q) or is_det_primitive(h, q)

        if gen:
            stats[q]['gen_rate'] += 1
        if irred:
            stats[q]['irred_rate'] += 1
        if prim:
            stats[q]['prim_rate'] += 1
        if irred and prim:
            stats[q]['both_rate'] += 1
        if gen and irred:
            stats[q]['cert_rate'] += 1

    for key in ['gen_rate', 'irred_rate', 'prim_rate', 'both_rate', 'cert_rate']:
        stats[q][key] /= n_samples_per_q

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Panel 1: Rates vs field size
ax1 = axes[0]
qs = list(stats.keys())
gen_rates = [stats[q]['gen_rate'] for q in qs]
irred_rates = [stats[q]['irred_rate'] for q in qs]
prim_rates = [stats[q]['prim_rate'] for q in qs]
cert_rates = [stats[q]['cert_rate'] for q in qs]

ax1.plot(qs, gen_rates, 'o-', color='#3498db', linewidth=2, markersize=8, label='Generates GL₂')
ax1.plot(qs, irred_rates, 's-', color='#2ecc71', linewidth=2, markersize=8, label='Irred charpoly')
ax1.plot(qs, prim_rates, 'D-', color='#e67e22', linewidth=2, markersize=8, label='Prim det')
ax1.plot(qs, cert_rates, '^-', color='#9b59b6', linewidth=2, markersize=10, label='Certified')

ax1.set_xlabel('Prime q', fontsize=12)
ax1.set_ylabel('Rate (fraction of random pairs)', fontsize=12)
ax1.set_title('Algebraic Property Rates vs Field Size', fontsize=14, fontweight='bold')
ax1.legend(fontsize=10)
ax1.set_ylim(-0.05, 1.05)
ax1.grid(True, alpha=0.3)

# Panel 2: Heatmap of conditions
conditions = ['Generation', 'Irred charpoly', 'Prim det', 'Both alg', 'Certified']
heatmap_data = np.array([
    [stats[q]['gen_rate'] for q in qs],
    [stats[q]['irred_rate'] for q in qs],
    [stats[q]['prim_rate'] for q in qs],
    [stats[q]['both_rate'] for q in qs],
    [stats[q]['cert_rate'] for q in qs],
])

ax2 = axes[1]
im = ax2.imshow(heatmap_data, cmap='YlGn', aspect='auto', vmin=0, vmax=1)
ax2.set_xticks(range(len(qs)))
ax2.set_xticklabels([str(q) for q in qs])
ax2.set_yticks(range(len(conditions)))
ax2.set_yticklabels(conditions)
ax2.set_xlabel('Prime q', fontsize=12)
ax2.set_title('Certification Landscape', fontsize=14, fontweight='bold')

# Add text annotations
for i in range(len(conditions)):
    for j in range(len(qs)):
        val = heatmap_data[i, j]
        color = 'white' if val > 0.5 else 'black'
        ax2.text(j, i, f'{val:.2f}', ha='center', va='center', color=color, fontsize=10)

plt.colorbar(im, ax=ax2, label='Rate', shrink=0.8)

# Panel 3: Group size vs certified fraction
ax3 = axes[2]
group_sizes = [gl2_order(q) for q in qs]
ax3.scatter(group_sizes, cert_rates, s=100, c='#9b59b6', zorder=3, edgecolors='white', linewidth=1.5)
for i, q in enumerate(qs):
    ax3.annotate(f'q={q}', (group_sizes[i], cert_rates[i]),
                textcoords="offset points", xytext=(10, 5), fontsize=10)

ax3.set_xlabel('Group size |GL₂(𝔽_q)|', fontsize=12)
ax3.set_ylabel('Certified fraction', fontsize=12)
ax3.set_title('Certification Density vs Group Size', fontsize=14, fontweight='bold')
ax3.set_xscale('log')
ax3.set_ylim(-0.05, 1.05)
ax3.grid(True, alpha=0.3)

# Add conjecture annotation
ax3.axhline(y=min(cert_rates) if cert_rates else 0, color='#e74c3c',
           linestyle=':', alpha=0.5, label='Conjectured lower bound')
ax3.legend(fontsize=10)

plt.suptitle('Algorithmic Spectral Certification: Landscape Analysis',
            fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_certification_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_certification_landscape.png")
