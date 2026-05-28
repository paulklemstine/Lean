"""
Visualization: Covering number heatmap for S₃.

Shows the covering number C(A·A) vs the theoretical bound C²·K
for all (A, H) pairs in S₃, revealing where non-abelian obstructions appear.

Uses matplotlib to produce a static heatmap.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import permutations

# ── S₃ group operations ──

def s3_mul(a, b):
    return tuple(a[b[i]] for i in range(3))

def s3_inv(a):
    r = [0]*3
    for i, v in enumerate(a):
        r[v] = i
    return tuple(r)

S3 = list(permutations(range(3)))
e = (0, 1, 2)

def greedy_cover(A, H):
    uncovered = set(A)
    count = 0
    while uncovered:
        a = next(iter(uncovered))
        best = set()
        for h in H:
            t = s3_mul(a, s3_inv(h))
            coset = {s3_mul(t, h2) for h2 in H}
            cov = uncovered & coset
            if len(cov) > len(best):
                best = cov
        uncovered -= best
        count += 1
    return count

def doubling_K(H):
    HH = {s3_mul(a, b) for a in H for b in H}
    return greedy_cover(HH, H)

# ── Find all symmetric subsets containing identity ──

def is_symmetric(H):
    return all(s3_inv(h) in H for h in H)

subsets = []
for mask in range(1, 2**6):
    H = set()
    for i in range(6):
        if mask & (1 << i):
            H.add(S3[i])
    if e in H and is_symmetric(H) and 1 < len(H) < 6:
        subsets.append(frozenset(H))

# Remove duplicates
subsets = list(set(subsets))

# ── Compute covering data ──

data = []
for H_frozen in subsets:
    H = set(H_frozen)
    K = doubling_K(H)
    
    # Test various A subsets
    for g in S3:
        A = {s3_mul(g, h) for h in H}
        C = greedy_cover(A, H)
        AA = {s3_mul(a, b) for a in A for b in A}
        C_AA = greedy_cover(AA, H)
        
        bound_C2K = C**2 * K
        ratio = C_AA / max(bound_C2K, 1)
        
        data.append({
            'H_size': len(H), 'K': K, 'C': C,
            'C_AA': C_AA, 'bound': bound_C2K, 'ratio': ratio
        })

# ── Create heatmap ──

fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# Plot 1: C(A·A) vs bound
ax = axes[0]
H_sizes = sorted(set(d['H_size'] for d in data))
K_vals = sorted(set(d['K'] for d in data))

grid = np.zeros((len(H_sizes), len(K_vals)))
counts = np.zeros((len(H_sizes), len(K_vals)))

for d in data:
    i = H_sizes.index(d['H_size'])
    j = K_vals.index(d['K'])
    grid[i, j] += d['ratio']
    counts[i, j] += 1

grid = np.where(counts > 0, grid / counts, np.nan)

im = ax.imshow(grid, cmap='RdYlGn_r', aspect='auto', vmin=0, vmax=2)
ax.set_xticks(range(len(K_vals)))
ax.set_xticklabels(K_vals)
ax.set_yticks(range(len(H_sizes)))
ax.set_yticklabels(H_sizes)
ax.set_xlabel('Approximate subgroup constant K')
ax.set_ylabel('|H|')
ax.set_title('Average C(A·A) / C²K ratio in S₃')
plt.colorbar(im, ax=ax, label='Ratio (>1 = violation)')

# Plot 2: Violation frequency
ax = axes[1]
violations = [d for d in data if d['C_AA'] > d['bound']]
non_violations = [d for d in data if d['C_AA'] <= d['bound']]

C_vals = [d['C'] for d in data]
C_AA_vals = [d['C_AA'] for d in data]
colors = ['red' if d['C_AA'] > d['bound'] else 'green' for d in data]

ax.scatter(C_vals, C_AA_vals, c=colors, alpha=0.6, s=50)
max_c = max(C_vals) + 1
ax.plot([0, max_c], [0, max_c**2], 'k--', alpha=0.3, label='C(A·A) = C²')
ax.set_xlabel('C (covering number of A)')
ax.set_ylabel('C(A·A) (covering number of A·A)')
ax.set_title(f'Covering Growth in S₃\n({len(violations)} violations / {len(data)} tests)')
ax.legend()

plt.tight_layout()
plt.savefig('covering_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved covering_heatmap.png")
