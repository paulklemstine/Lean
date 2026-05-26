"""
Visualization: Spectral Gap Uniformity Across Primes (Conjecture Test)

This script tests the conjecture that the second-moment spectral radius
of certified SL₂(GF(q)) generators is uniformly bounded away from 1
across all odd primes q. The heatmap shows eigenvalue-like ratios
across walk steps and primes.

CRITICAL: Fully self-contained — no local imports.
"""

import numpy as np
import matplotlib.pyplot as plt


# ─── Inline infrastructure ──────────────────────────────────────────

def mat_mul_mod(A, B, q):
    return (A @ B) % q

def mat_inv_mod(A, q):
    a, b, c, d = int(A[0,0]), int(A[0,1]), int(A[1,0]), int(A[1,1])
    det = (a*d - b*c) % q
    det_inv = pow(det, q-2, q)
    return np.array([[d*det_inv%q, (-b*det_inv)%q],
                     [(-c*det_inv)%q, a*det_inv%q]], dtype=int) % q

def charpoly_is_irreducible(A, q):
    tr = int((A[0,0]+A[1,1])%q)
    det = int((A[0,0]*A[1,1]-A[0,1]*A[1,0])%q)
    disc = (tr*tr - 4*det) % q
    if disc == 0: return False
    if q == 2: return True
    return pow(disc, (q-1)//2, q) != 1

def find_certified_pair(q):
    irred = []
    all_sl2 = []
    for a in range(q):
        for b in range(q):
            for c in range(q):
                for d in range(q):
                    mat = np.array([[a,b],[c,d]], dtype=int)
                    if (a*d-b*c)%q == 1:
                        all_sl2.append(mat)
                        if charpoly_is_irreducible(mat, q):
                            irred.append(mat)
    def check_gen(s, t):
        target = q*(q*q-1)
        gens = [s, mat_inv_mod(s,q), t, mat_inv_mod(t,q)]
        seen = set()
        frontier = [np.eye(2, dtype=int)]
        seen.add(tuple(frontier[0].flatten()))
        while frontier:
            nf = []
            for g in frontier:
                for gen in gens:
                    p = mat_mul_mod(g, gen, q)
                    k = tuple((p%q).flatten())
                    if k not in seen:
                        seen.add(k)
                        nf.append(p)
                        if len(seen) == target: return True
            frontier = nf
        return len(seen) == target
    lim = min(len(irred), 30)
    for s in irred[:lim]:
        for t in irred[:lim]:
            if not np.array_equal(s,t) and check_gen(s,t):
                return s, t
    ol = min(len(all_sl2), 40)
    for s in irred[:lim]:
        for t in all_sl2[:ol]:
            if not np.array_equal(s,t) and check_gen(s,t):
                return s, t
    return None, None

def cayley_walk(s, t, q, k):
    gens = [s, mat_inv_mod(s,q), t, mat_inv_mod(t,q)]
    identity = tuple(np.eye(2, dtype=int).flatten())
    dist = {identity: 1.0}
    for _ in range(k):
        nd = {}
        for elem, prob in dist.items():
            em = np.array(elem, dtype=int).reshape(2,2)
            for gen in gens:
                p = mat_mul_mod(gen, em, q)
                kk = tuple((p%q).flatten())
                nd[kk] = nd.get(kk, 0.0) + prob/len(gens)
        dist = nd
    return dist

def deviation_energy(dist, group_size):
    u = 1.0/group_size
    return sum((p-u)**2 for p in dist.values()) + (group_size - len(dist)) * u**2


# ─── Main visualization ────────────────────────────────────────────

primes = [3, 5, 7]
max_steps = 15

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

all_bounds = {}

for idx, q in enumerate(primes):
    ax = axes[idx]
    group_size = q * (q*q - 1)
    s, t = find_certified_pair(q)

    if s is None:
        ax.text(0.5, 0.5, f'No pair found\nfor q={q}',
                ha='center', va='center', transform=ax.transAxes, fontsize=14)
        continue

    # Compute distribution at each step
    energies = []
    distributions = []
    for k in range(max_steps + 1):
        dist = cayley_walk(s, t, q, k)
        e = deviation_energy(dist, group_size)
        energies.append(e)
        distributions.append(dist)

    # Create heatmap of distribution convergence
    # Show probabilities of top-20 group elements across steps
    all_keys = set()
    for d in distributions:
        all_keys.update(d.keys())
    sorted_keys = sorted(all_keys)[:min(30, group_size)]

    heatmap_data = np.zeros((len(sorted_keys), len(distributions)))
    uniform = 1.0 / group_size
    for j, dist in enumerate(distributions):
        for i, key in enumerate(sorted_keys):
            heatmap_data[i, j] = dist.get(key, 0.0)

    im = ax.imshow(heatmap_data, aspect='auto', cmap='viridis',
                   interpolation='nearest')
    ax.axhline(y=-0.5, color='white', linewidth=0.5)
    ax.set_xlabel('Walk step k', fontsize=12)
    ax.set_ylabel('Group element index', fontsize=12)
    ax.set_title(f'SL₂(GF({q})), |G|={group_size}\nDistribution convergence',
                 fontsize=12)
    plt.colorbar(im, ax=ax, label='Probability', shrink=0.8)

    # Estimate spectral bound
    ratios = []
    for k in range(2, len(energies)):
        if energies[k-1] > 1e-14:
            ratios.append(np.sqrt(max(energies[k]/energies[k-1], 0)))
    if ratios:
        all_bounds[q] = np.median(ratios)

plt.suptitle('Distribution Convergence on Cayley Graphs of SL₂(GF(q))\n'
             'Columns show how the walk distribution converges to uniform',
             fontsize=14, y=1.02)
plt.tight_layout()
plt.savefig('spectral_gap_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved spectral_gap_heatmap.png")

# Print conjecture test results
print("\nConjecture test: Uniform spectral bound")
for q, lb in sorted(all_bounds.items()):
    print(f"  q={q}: λ ≈ {lb:.6f}, gap = {1-lb:.6f}")
if all_bounds:
    print(f"  Max λ = {max(all_bounds.values()):.6f}")
