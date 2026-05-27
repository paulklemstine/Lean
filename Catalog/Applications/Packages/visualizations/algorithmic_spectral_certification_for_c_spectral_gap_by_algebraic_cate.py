"""
Visualization 1: Spectral Gap Certification Landscape

Visualizes the relationship between algebraic fingerprints (charpoly
irreducibility, determinant primitivity) and spectral gap for random
generator pairs in GL₂(𝔽_q). Shows that algebraically certified pairs
(markers) consistently achieve large spectral gaps.

This is the core visual argument for the theory: local algebraic
properties predict global spectral expansion.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


# ---- Inlined helper functions (self-contained) ----

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
    det_inv = pow(det, q - 2, q) if det % q != 0 else None
    if det_inv is None:
        return None
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
    euler = pow(disc, (q - 1) // 2, q)
    return euler != 1

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

def enumerate_gl2(q):
    elements = []
    for a in range(q):
        for b in range(q):
            for c in range(q):
                for d in range(q):
                    if (a * d - b * c) % q != 0:
                        elements.append(np.array([[a, b], [c, d]], dtype=int))
    return elements

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
    target_size = gl2_order(q)
    subgroup = generate_subgroup([g, h], q, max_size=target_size + 1)
    return len(subgroup) == target_size

def compute_true_spectral_gap(g, h, q):
    elements = enumerate_gl2(q)
    n = len(elements)
    def mat_to_tuple(M):
        return (int(M[0, 0]) % q, int(M[0, 1]) % q,
                int(M[1, 0]) % q, int(M[1, 1]) % q)
    elem_index = {mat_to_tuple(e): i for i, e in enumerate(elements)}
    gens = [g, mat_inv_mod(g, q), h, mat_inv_mod(h, q)]
    gens = [x for x in gens if x is not None]
    gen_tuples = set(mat_to_tuple(s) for s in gens)
    degree = len(gen_tuples)
    adj = np.zeros((n, n))
    for i, x in enumerate(elements):
        for s in gens:
            y = mat_mul_mod(x, s, q)
            j = elem_index.get(mat_to_tuple(y))
            if j is not None:
                adj[i, j] = 1.0
    adj_norm = adj / degree if degree > 0 else adj
    eigenvalues = np.linalg.eigvalsh(adj_norm)
    eigenvalues = sorted(eigenvalues, reverse=True)
    if len(eigenvalues) < 2:
        return 0.0
    second_largest = max(abs(eigenvalues[1]), abs(eigenvalues[-1]))
    return 1.0 - second_largest

def sample_gl2_pair(q):
    def random_gl2():
        while True:
            M = np.random.randint(0, q, size=(2, 2))
            if mat_det_mod(M, q) != 0:
                return M
    return random_gl2(), random_gl2()


# ---- Main visualization ----

np.random.seed(42)
q = 5
n_samples = 60

gaps = []
irred_flags = []
prim_flags = []
gen_flags = []

for _ in range(n_samples):
    g, h = sample_gl2_pair(q)
    generates = check_generates_gl2(g, h, q)
    if not generates:
        continue

    gap = compute_true_spectral_gap(g, h, q)
    irred = is_charpoly_irreducible(g, q) or is_charpoly_irreducible(h, q)
    prim = is_det_primitive(g, q) or is_det_primitive(h, q)

    gaps.append(gap)
    irred_flags.append(irred)
    prim_flags.append(prim)
    gen_flags.append(generates)

gaps = np.array(gaps)
irred_flags = np.array(irred_flags)
prim_flags = np.array(prim_flags)

# Classify into four categories
cat_both = irred_flags & prim_flags
cat_irred_only = irred_flags & ~prim_flags
cat_prim_only = ~irred_flags & prim_flags
cat_neither = ~irred_flags & ~prim_flags

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Left: Scatter plot of spectral gaps by algebraic category
categories = [
    (cat_both, 'Both irred + prim', '#2ecc71', 's', 80),
    (cat_irred_only, 'Irred only', '#3498db', '^', 70),
    (cat_prim_only, 'Prim only', '#e67e22', 'D', 70),
    (cat_neither, 'Neither', '#e74c3c', 'o', 50),
]

x_offset = 0
for mask, label, color, marker, size in categories:
    if mask.any():
        n_cat = mask.sum()
        x_vals = np.arange(n_cat) + x_offset
        ax1.scatter(x_vals, gaps[mask], c=color, marker=marker,
                   s=size, label=f'{label} (n={n_cat})', alpha=0.8, edgecolors='white', linewidth=0.5)
        x_offset += n_cat + 2

ax1.axhline(y=np.median(gaps[cat_both]) if cat_both.any() else 0,
           color='#2ecc71', linestyle='--', alpha=0.5, label='Median (both)')
ax1.set_xlabel('Generator pair index', fontsize=12)
ax1.set_ylabel('True spectral gap', fontsize=12)
ax1.set_title(f'Spectral Gap by Algebraic Category (q={q})', fontsize=14, fontweight='bold')
ax1.legend(fontsize=9, loc='lower right')
ax1.set_ylim(-0.05, 1.05)
ax1.grid(True, alpha=0.3)

# Right: Histogram comparison
bins = np.linspace(0, 1, 20)
if cat_both.any():
    ax2.hist(gaps[cat_both], bins=bins, alpha=0.7, color='#2ecc71',
             label='Certified (irred+prim)', density=True, edgecolor='white')
if cat_neither.any():
    ax2.hist(gaps[cat_neither], bins=bins, alpha=0.5, color='#e74c3c',
             label='Uncertified', density=True, edgecolor='white')
ax2.set_xlabel('Spectral gap', fontsize=12)
ax2.set_ylabel('Density', fontsize=12)
ax2.set_title('Gap Distribution: Certified vs Uncertified', fontsize=14, fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_spectral_gap.png', dpi=150, bbox_inches='tight')
print("Saved viz_spectral_gap.png")
