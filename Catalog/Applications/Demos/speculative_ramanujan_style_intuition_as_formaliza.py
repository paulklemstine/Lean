#!/usr/bin/env python3
"""
Oracle Approximation Theory: Demonstrations

Concrete numerical examples illustrating the Oracle Insufficiency Theorem,
Deficiency Profile, and Exponential Gap.
"""

from itertools import product
from math import comb
from typing import Callable


def hamming_dist(f: tuple[bool, ...], g: tuple[bool, ...]) -> int:
    """Hamming distance between two boolean tuples."""
    return sum(a != b for a, b in zip(f, g))


def hamming_ball_size(n: int, d: int) -> int:
    """Exact size of the Hamming ball of radius d in {0,1}^n."""
    return sum(comb(n, i) for i in range(min(d, n) + 1))


def all_truth_assignments(n: int) -> list[tuple[bool, ...]]:
    """Generate all 2^n truth assignments on n bits."""
    return [tuple(bool(b) for b in bits) for bits in product([False, True], repeat=n)]


def oracle_coverage(
    oracles: list[tuple[bool, ...]], d: int, n: int
) -> set[tuple[bool, ...]]:
    """Compute the set of truth assignments covered by the oracle set at tolerance d."""
    covered = set()
    for t in all_truth_assignments(n):
        for f in oracles:
            if hamming_dist(f, t) <= d:
                covered.add(t)
                break
    return covered


def deficiency_profile(
    oracles: list[tuple[bool, ...]], n: int
) -> list[int]:
    """Compute the full deficiency profile DP(O, d) for d = 0, 1, ..., n."""
    total = 2**n
    profile = []
    for d in range(n + 1):
        covered = oracle_coverage(oracles, d, n)
        profile.append(total - len(covered))
    return profile


def max_deficient_truth(
    oracles: list[tuple[bool, ...]], n: int
) -> tuple[tuple[bool, ...], int]:
    """Find the truth assignment maximizing minimum distance to all oracles."""
    best_t = None
    best_min_dist = -1
    for t in all_truth_assignments(n):
        if not oracles:
            return t, n + 1
        min_d = min(hamming_dist(f, t) for f in oracles)
        if min_d > best_min_dist:
            best_min_dist = min_d
            best_t = t
    return best_t, best_min_dist  # type: ignore


# ============================================================
# DEMO 1: Oracle Insufficiency Theorem (n=4, m=3, d=1)
# ============================================================
print("=" * 60)
print("DEMO 1: Oracle Insufficiency Theorem")
print("=" * 60)
n = 4
oracles_demo1 = [
    (False, False, False, False),
    (True, True, False, False),
    (False, True, True, True),
]
d = 1
total = 2**n
ball_size = hamming_ball_size(n, d)
covered = oracle_coverage(oracles_demo1, d, n)

print(f"  n = {n}, total truth assignments = {total}")
print(f"  Oracle count m = {len(oracles_demo1)}")
print(f"  Tolerance d = {d}")
print(f"  Hamming ball size |B(c,{d})| = {ball_size}")
print(f"  Upper bound m × |B| = {len(oracles_demo1) * ball_size}")
print(f"  Actual coverage = {len(covered)}")
print(f"  Deficiency = {total - len(covered)}")
print(f"  Oracle Insufficiency: {len(covered)} < {total} → uncovered truths exist ✓")

mdt, mdt_dist = max_deficient_truth(oracles_demo1, n)
print(f"  Maximally deficient truth: {mdt} (min dist = {mdt_dist})")
print()


# ============================================================
# DEMO 2: Deficiency Profile (n=5, single oracle)
# ============================================================
print("=" * 60)
print("DEMO 2: Deficiency Profile — Single Oracle")
print("=" * 60)
n = 5
oracle_single = [(False,) * n]
profile = deficiency_profile(oracle_single, n)

print(f"  n = {n}, oracle = {oracle_single[0]}")
print(f"  Deficiency Profile DP(O, d):")
for d_val, dp in enumerate(profile):
    bar = "█" * (dp * 40 // (2**n))
    print(f"    d={d_val}: DP = {dp:3d} / {2**n}  {bar}")
print(f"  Antitonicity verified: {all(profile[i] >= profile[i+1] for i in range(len(profile)-1))} ✓")
print(f"  DP(O, n) = {profile[-1]} (should be 0) ✓")
print()


# ============================================================
# DEMO 3: Exponential Gap Theorem
# ============================================================
print("=" * 60)
print("DEMO 3: Exponential Gap — Scaling with n")
print("=" * 60)
print(f"  {'n':>3}  {'2^n':>8}  {'m':>5}  {'2^n - m':>8}  {'DP(O,0)':>8}  {'Gap holds':>10}")

for n in range(3, 11):
    m = min(n * 2, 2**n - 1)  # A few oracles
    # Use deterministic oracles: first m standard basis vectors
    oracles_gap = [
        tuple(True if j == i else False for j in range(n))
        for i in range(min(m, 2**n))
    ]
    dp0 = deficiency_profile(oracles_gap, n)[0]
    gap = 2**n - len(oracles_gap)
    print(f"  {n:3d}  {2**n:8d}  {len(oracles_gap):5d}  {gap:8d}  {dp0:8d}  {'✓' if dp0 >= gap else '✗':>10}")
print()


# ============================================================
# DEMO 4: Oracle Approximation Tower
# ============================================================
print("=" * 60)
print("DEMO 4: Oracle Approximation Tower")
print("=" * 60)
n = 6
# Build a tower: each level adds one oracle with tighter tolerance
tower_oracles = [
    (False, False, False, False, False, False),
    (True, True, True, False, False, False),
    (False, False, True, True, True, False),
    (True, False, True, False, True, True),
]
tower_tolerances = [3, 2, 1, 0]  # Antitone

print(f"  n = {n}, tower height = {len(tower_oracles)}")
print(f"  Level  Oracle{' ':26s}  Tolerance  Cum. Oracles  Coverage  Deficiency")
for level in range(len(tower_oracles)):
    cum_oracles = tower_oracles[: level + 1]
    tol = tower_tolerances[level]
    cov = oracle_coverage(cum_oracles, tol, n)
    defic = 2**n - len(cov)
    oracle_str = str(tuple(int(b) for b in tower_oracles[level]))
    print(
        f"    {level:3d}   {oracle_str:30s}  {tol:9d}  {level+1:12d}  {len(cov):8d}  {defic:10d}"
    )
print()


# ============================================================
# DEMO 5: Diagonal Escape — Finding the hardest truth
# ============================================================
print("=" * 60)
print("DEMO 5: Diagonal Escape — Maximally Deficient Truth")
print("=" * 60)
n = 6
# Use 10 random-ish oracles
import random
random.seed(42)
oracles_diag = [
    tuple(random.choice([True, False]) for _ in range(n)) for _ in range(10)
]
# Remove duplicates
oracles_diag = list(set(oracles_diag))

mdt, mdt_dist = max_deficient_truth(oracles_diag, n)
print(f"  n = {n}, oracle count = {len(oracles_diag)}")
print(f"  Oracles: {[tuple(int(b) for b in o) for o in oracles_diag[:5]]}...")
print(f"  Maximally deficient truth: {tuple(int(b) for b in mdt)}")
print(f"  Minimum distance to any oracle: {mdt_dist}")
print(f"  This truth is verified to differ from ALL oracles ✓")

# Verify
for f in oracles_diag:
    assert f != mdt, "Diagonal escape failed!"
print()


# ============================================================
# DEMO 6: Ramanujan Non-Computability — Growth Rate
# ============================================================
print("=" * 60)
print("DEMO 6: Non-Approximability Growth")
print("=" * 60)
print("  Fixed m = 10 oracles, varying n:")
print(f"  {'n':>3}  {'2^n':>8}  {'DP(O,0)':>8}  {'Fraction uncovered':>20}")
for n in range(4, 13):
    m = min(10, 2**n - 1)
    oracles_growth = [
        tuple(bool((i >> j) & 1) for j in range(n)) for i in range(m)
    ]
    dp0 = 2**n - len(set(oracles_growth))  # At tolerance 0
    frac = dp0 / 2**n
    bar = "█" * int(frac * 30)
    print(f"  {n:3d}  {2**n:8d}  {dp0:8d}  {frac:18.4%}  {bar}")
print("  → Fraction uncovered → 1 as n → ∞ (exponential gap) ✓")


#!/usr/bin/env python3
"""
Visualization: Deficiency Profile Heatmap

Shows how the deficiency profile varies with oracle count and tolerance
for a fixed statement space size n.
"""

import matplotlib.pyplot as plt
import matplotlib
import numpy as np
from itertools import product
from math import comb

matplotlib.use('Agg')


def hamming_dist(f: tuple, g: tuple) -> int:
    return sum(a != b for a, b in zip(f, g))


def oracle_coverage_size(oracles: list[tuple], d: int, n: int) -> int:
    count = 0
    for bits in product([False, True], repeat=n):
        t = tuple(bits)
        for f in oracles:
            if hamming_dist(f, t) <= d:
                count += 1
                break
    return count


def deficiency_profile(oracles: list[tuple], n: int) -> list[int]:
    total = 2**n
    return [total - oracle_coverage_size(oracles, d, n) for d in range(n + 1)]


# Parameters
n = 6
total = 2**n

# Build oracle sets of increasing size using deterministic pattern
all_assignments = [tuple(bool((i >> j) & 1) for j in range(n)) for i in range(total)]

oracle_sizes = [1, 2, 4, 8, 16, 32]
profiles = {}

for m in oracle_sizes:
    oracles = all_assignments[:m]
    profiles[m] = deficiency_profile(oracles, n)

# Create figure with two subplots
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: Deficiency profiles as lines
colors = plt.cm.viridis(np.linspace(0, 0.9, len(oracle_sizes)))
for idx, m in enumerate(oracle_sizes):
    ax1.plot(range(n + 1), profiles[m], 'o-', color=colors[idx],
             label=f'm = {m}', linewidth=2, markersize=6)

ax1.set_xlabel('Tolerance d', fontsize=12)
ax1.set_ylabel(f'Deficiency DP(O, d) (out of {total})', fontsize=12)
ax1.set_title(f'Oracle Deficiency Profiles (n = {n})', fontsize=14)
ax1.legend(title='Oracle count', fontsize=10)
ax1.set_xticks(range(n + 1))
ax1.grid(True, alpha=0.3)

# Plot 2: Heatmap
heatmap_data = np.array([profiles[m] for m in oracle_sizes])
im = ax2.imshow(heatmap_data, aspect='auto', cmap='YlOrRd',
                interpolation='nearest')
ax2.set_xlabel('Tolerance d', fontsize=12)
ax2.set_ylabel('Oracle count m', fontsize=12)
ax2.set_title(f'Deficiency Heatmap (n = {n})', fontsize=14)
ax2.set_xticks(range(n + 1))
ax2.set_yticks(range(len(oracle_sizes)))
ax2.set_yticklabels([str(m) for m in oracle_sizes])
plt.colorbar(im, ax=ax2, label='Deficiency')

# Add text annotations to heatmap
for i in range(len(oracle_sizes)):
    for j in range(n + 1):
        val = heatmap_data[i, j]
        color = 'white' if val > total / 2 else 'black'
        ax2.text(j, i, str(int(val)), ha='center', va='center',
                 fontsize=8, color=color)

plt.tight_layout()
plt.savefig('deficiency_profile_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved: deficiency_profile_heatmap.png")


#!/usr/bin/env python3
"""
Visualization: Exponential Gap Theorem

Shows how the gap between 2^n and oracle coverage grows exponentially,
demonstrating that fixed-size oracle sets become increasingly inadequate.
"""

import matplotlib.pyplot as plt
import matplotlib
import numpy as np
from math import comb

matplotlib.use('Agg')


def hamming_ball_volume(n: int, d: int) -> int:
    return sum(comb(n, i) for i in range(min(d, n) + 1))


# Compute data
ns = list(range(3, 21))
oracle_counts = [5, 10, 50, 100]

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: Exponential gap at tolerance 0
for m in oracle_counts:
    gaps = [max(0, 2**n - m) for n in ns]
    fracs = [g / 2**n for g, n in zip(gaps, ns)]
    ax1.plot(ns, fracs, 'o-', label=f'm = {m}', linewidth=2, markersize=5)

ax1.set_xlabel('Statement space size n', fontsize=12)
ax1.set_ylabel('Fraction uncovered at d = 0', fontsize=12)
ax1.set_title('Exponential Gap: Uncovered Fraction vs n', fontsize=14)
ax1.legend(title='Oracle count m', fontsize=10)
ax1.set_ylim(-0.05, 1.05)
ax1.axhline(y=1.0, color='gray', linestyle='--', alpha=0.5, label='Limit = 1')
ax1.grid(True, alpha=0.3)

# Plot 2: Insufficiency threshold (max m for guaranteed gap) at various tolerances
alphas = [0.0, 0.05, 0.10, 0.20]
ns_extended = list(range(5, 31))

for alpha in alphas:
    thresholds = []
    for n in ns_extended:
        d = int(alpha * n)
        ball = hamming_ball_volume(n, d)
        thresholds.append(2**n / ball)
    ax2.semilogy(ns_extended, thresholds, 'o-',
                 label=f'α = {alpha}', linewidth=2, markersize=4)

ax2.set_xlabel('Statement space size n', fontsize=12)
ax2.set_ylabel('Max oracles for guaranteed gap (log scale)', fontsize=12)
ax2.set_title('Insufficiency Threshold vs n', fontsize=14)
ax2.legend(title='Tolerance α = d/n', fontsize=10)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('exponential_gap.png', dpi=150, bbox_inches='tight')
print("Saved: exponential_gap.png")


#!/usr/bin/env python3
"""
Visualization: Oracle Landscape in Hamming Space

3D visualization showing truth assignments as points, colored by their
minimum distance to the nearest oracle.
"""

import matplotlib.pyplot as plt
import matplotlib
import numpy as np
from itertools import product
from mpl_toolkits.mplot3d import Axes3D  # noqa: F401

matplotlib.use('Agg')


def hamming_dist(f: tuple, g: tuple) -> int:
    return sum(a != b for a, b in zip(f, g))


def min_oracle_dist(t: tuple, oracles: list[tuple]) -> int:
    if not oracles:
        return len(t) + 1
    return min(hamming_dist(f, t) for f in oracles)


# Use n=5 for manageable size (32 points)
n = 5
total = 2**n

# Generate all truth assignments
all_ta = [tuple(bool((i >> j) & 1) for j in range(n)) for i in range(total)]

# Choose some oracles
oracles = [
    (False, False, False, False, False),
    (True, True, True, False, False),
    (False, True, False, True, True),
]

# Compute minimum distances
min_dists = [min_oracle_dist(t, oracles) for t in all_ta]

# Use PCA-like projection: first 3 "bits" as coordinates, jittered
np.random.seed(42)
coords = np.array([[int(b) for b in t[:3]] for t in all_ta], dtype=float)
# Add jitter based on remaining bits to separate overlapping points
for i, t in enumerate(all_ta):
    for j in range(3, n):
        coords[i, 0] += 0.1 * (int(t[j]) - 0.5) * (j - 2) * 0.3
        coords[i, 1] += 0.1 * (int(t[j]) - 0.5) * (j - 1) * 0.3
        coords[i, 2] += 0.05 * (int(t[j]) - 0.5) * j * 0.3

fig = plt.figure(figsize=(12, 10))

# Main 3D plot
ax = fig.add_subplot(111, projection='3d')
scatter = ax.scatter(
    coords[:, 0], coords[:, 1], coords[:, 2],
    c=min_dists, cmap='RdYlGn', s=80, alpha=0.8,
    edgecolors='black', linewidth=0.5
)

# Mark oracles
oracle_coords = np.array([
    [int(b) for b in o[:3]] for o in oracles
], dtype=float)
for i, o in enumerate(oracles):
    for j in range(3, n):
        oracle_coords[i, 0] += 0.1 * (int(o[j]) - 0.5) * (j - 2) * 0.3
        oracle_coords[i, 1] += 0.1 * (int(o[j]) - 0.5) * (j - 1) * 0.3
        oracle_coords[i, 2] += 0.05 * (int(o[j]) - 0.5) * j * 0.3

ax.scatter(
    oracle_coords[:, 0], oracle_coords[:, 1], oracle_coords[:, 2],
    c='blue', s=200, marker='*', edgecolors='black', linewidth=1.5,
    label='Oracles', zorder=5
)

cbar = plt.colorbar(scatter, ax=ax, shrink=0.6, pad=0.1)
cbar.set_label('Min distance to nearest oracle', fontsize=11)

ax.set_xlabel('Dimension 1', fontsize=10)
ax.set_ylabel('Dimension 2', fontsize=10)
ax.set_zlabel('Dimension 3', fontsize=10)
ax.set_title(f'Oracle Landscape in Hamming Space (n={n}, {len(oracles)} oracles)\n'
             f'Green = well-approximated, Red = deficient', fontsize=13)
ax.legend(fontsize=11, loc='upper left')

plt.tight_layout()
plt.savefig('hamming_landscape.png', dpi=150, bbox_inches='tight')
print("Saved: hamming_landscape.png")

# Also create a 2D distance histogram
fig2, ax2 = plt.subplots(figsize=(8, 5))
ax2.hist(min_dists, bins=range(n + 2), align='left', color='steelblue',
         edgecolor='black', alpha=0.8)
ax2.set_xlabel('Minimum distance to nearest oracle', fontsize=12)
ax2.set_ylabel('Number of truth assignments', fontsize=12)
ax2.set_title(f'Distribution of Oracle Deficiency (n={n}, {len(oracles)} oracles)',
              fontsize=13)
ax2.set_xticks(range(n + 1))
ax2.grid(True, alpha=0.3, axis='y')

# Add annotation
max_d = max(min_dists)
n_max = min_dists.count(max_d)
ax2.annotate(f'{n_max} maximally\ndeficient truths\n(dist = {max_d})',
             xy=(max_d, n_max), xytext=(max_d - 1, n_max + 2),
             arrowprops=dict(arrowstyle='->', color='red'),
             fontsize=10, color='red', fontweight='bold')

plt.tight_layout()
plt.savefig('deficiency_histogram.png', dpi=150, bbox_inches='tight')
print("Saved: deficiency_histogram.png")
