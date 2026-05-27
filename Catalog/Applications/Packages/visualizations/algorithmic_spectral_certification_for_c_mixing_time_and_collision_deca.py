"""
Visualization 2: Mixing Time and Collision Probability Decay

Visualizes how the random walk on a Cayley graph converges to the
uniform distribution, showing exponential decay of collision probability
and its connection to the spectral gap.

The key insight: certified spectral gap predicts the rate of convergence.
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

def gl2_order(q):
    return (q * q - 1) * (q * q - q)

def short_word_distribution(g, h, q, radius):
    def mat_to_tuple(M):
        return (int(M[0, 0]) % q, int(M[0, 1]) % q,
                int(M[1, 0]) % q, int(M[1, 1]) % q)
    gens = [g, mat_inv_mod(g, q), h, mat_inv_mod(h, q)]
    gens = [x for x in gens if x is not None]
    current_dist = {mat_to_tuple(np.eye(2, dtype=int)): 1}
    for _ in range(radius):
        next_dist = {}
        for elem_t, count in current_dist.items():
            elem = np.array([[elem_t[0], elem_t[1]], [elem_t[2], elem_t[3]]], dtype=int)
            for s in gens:
                prod = mat_mul_mod(elem, s, q)
                pt = mat_to_tuple(prod)
                next_dist[pt] = next_dist.get(pt, 0) + count
        current_dist = next_dist
    return current_dist

def collision_probability(dist):
    total = sum(dist.values())
    if total == 0:
        return 1.0
    return sum((c / total) ** 2 for c in dist.values())

def enumerate_gl2(q):
    elements = []
    for a in range(q):
        for b in range(q):
            for c in range(q):
                for d in range(q):
                    if (a * d - b * c) % q != 0:
                        elements.append(np.array([[a, b], [c, d]], dtype=int))
    return elements

def compute_true_spectral_gap(g, h, q):
    elements = enumerate_gl2(q)
    n = len(elements)
    def mat_to_tuple(M):
        return (int(M[0, 0]) % q, int(M[0, 1]) % q,
                int(M[1, 0]) % q, int(M[1, 1]) % q)
    elem_index = {mat_to_tuple(e): i for i, e in enumerate(elements)}
    gens = [g, mat_inv_mod(g, q), h, mat_inv_mod(h, q)]
    gens = [x for x in gens if x is not None]
    degree = len(set(mat_to_tuple(s) for s in gens))
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
    return 1.0 - max(abs(eigenvalues[1]), abs(eigenvalues[-1]))


# ---- Main visualization ----

np.random.seed(42)
q = 5
n = gl2_order(q)

# Find a generating pair
g = np.array([[0, 1], [4, 2]], dtype=int)
h = np.array([[2, 1], [1, 3]], dtype=int)

fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# Panel 1: Collision probability decay
radii = list(range(1, 10))
collision_probs = []
for L in radii:
    dist = short_word_distribution(g, h, q, L)
    cp = collision_probability(dist)
    collision_probs.append(cp)

uniform_cp = 1.0 / n
gap = compute_true_spectral_gap(g, h, q)

ax1 = axes[0]
ax1.semilogy(radii, collision_probs, 'o-', color='#2ecc71', linewidth=2,
            markersize=8, label='Measured collision prob', zorder=3)
ax1.axhline(y=uniform_cp, color='gray', linestyle='--', alpha=0.7,
           label=f'Uniform: 1/|G| = {uniform_cp:.2e}')

# Theoretical decay: (1-gap)^(2L) * n
if gap > 0:
    theory_decay = [n * (1 - gap) ** (2 * L) * uniform_cp for L in radii]
    ax1.semilogy(radii, theory_decay, 's--', color='#e74c3c', alpha=0.6,
                markersize=6, label=f'Theory: (1-gap)^{{2L}}/|G|, gap={gap:.3f}')

ax1.set_xlabel('Word radius L', fontsize=12)
ax1.set_ylabel('Collision probability', fontsize=12)
ax1.set_title('Collision Probability Decay', fontsize=14, fontweight='bold')
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)

# Panel 2: Support growth
support_sizes = []
for L in radii:
    dist = short_word_distribution(g, h, q, L)
    support_sizes.append(len(dist))

ax2 = axes[1]
ax2.plot(radii, [s / n for s in support_sizes], 'D-', color='#3498db',
        linewidth=2, markersize=8, label='Support fraction')
ax2.axhline(y=1.0, color='gray', linestyle='--', alpha=0.7, label='Full group')
ax2.fill_between(radii, 0, [s / n for s in support_sizes], alpha=0.1, color='#3498db')
ax2.set_xlabel('Word radius L', fontsize=12)
ax2.set_ylabel('Fraction of group covered', fontsize=12)
ax2.set_title('Support Growth of Word Distribution', fontsize=14, fontweight='bold')
ax2.set_ylim(-0.05, 1.1)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# Panel 3: L² distance to uniform
l2_distances = []
for L in radii:
    dist = short_word_distribution(g, h, q, L)
    total = sum(dist.values())
    l2_sq = sum(((c / total) - uniform_cp) ** 2 for c in dist.values())
    # Add contribution from elements not in support
    l2_sq += (n - len(dist)) * uniform_cp ** 2
    l2_distances.append(np.sqrt(l2_sq))

ax3 = axes[2]
ax3.semilogy(radii, l2_distances, 'o-', color='#9b59b6', linewidth=2,
            markersize=8, label='L² distance to uniform')

if gap > 0:
    theory_l2 = [l2_distances[0] * (1 - gap) ** L for L in radii]
    ax3.semilogy(radii, theory_l2, 's--', color='#e67e22', alpha=0.6,
                markersize=6, label=f'Predicted: (1-gap)^L, gap={gap:.3f}')

ax3.set_xlabel('Word radius L', fontsize=12)
ax3.set_ylabel('L² distance', fontsize=12)
ax3.set_title('L² Convergence to Uniform', fontsize=14, fontweight='bold')
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)

plt.suptitle(f'Random Walk Mixing on Cay(GL₂(𝔽_{q}), {{g,g⁻¹,h,h⁻¹}})',
            fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_mixing.png', dpi=150, bbox_inches='tight')
print("Saved viz_mixing.png")
