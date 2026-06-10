#!/usr/bin/env python3
"""
Chromatic Topology: Demonstrations of Pitch Class Set Theory

Demonstrates key results:
1. Hamming distance as a metric on chord space
2. Transposition and complementation isometries
3. Intervallic fingerprints
4. Hexachordal complementation theorem
"""

from itertools import combinations
from collections import Counter

# ℤ/12ℤ pitch class names
PC_NAMES = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']


def transpose(S: frozenset, t: int) -> frozenset:
    """Transpose a pitch class set by interval t in ℤ/12ℤ."""
    return frozenset((x + t) % 12 for x in S)


def invert(S: frozenset) -> frozenset:
    """Invert a pitch class set (negate mod 12)."""
    return frozenset((-x) % 12 for x in S)


def complement(S: frozenset) -> frozenset:
    """Complement of S in ℤ/12ℤ."""
    return frozenset(range(12)) - S


def hamming_dist(A: frozenset, B: frozenset) -> int:
    """Hamming distance = |symmetric difference|."""
    return len(A.symmetric_difference(B))


def interval_class(d: int) -> int:
    """Interval class: min(d mod 12, 12 - d mod 12)."""
    d = d % 12
    return min(d, 12 - d)


def interval_vector(S: frozenset) -> list:
    """Interval-class vector: counts of each IC from 1 to 6."""
    vec = [0] * 6
    for a, b in combinations(S, 2):
        ic = interval_class(b - a)
        if 1 <= ic <= 6:
            vec[ic - 1] += 1
    return vec


def intervallic_fingerprint(S: frozenset) -> Counter:
    """Directed interval multiset (the intervallic fingerprint)."""
    fp = Counter()
    for a in S:
        for b in S:
            if a != b:
                fp[(b - a) % 12] += 1
    return fp


# === DEMO 1: Hamming metric properties ===
print("=" * 60)
print("DEMO 1: Hamming Distance is a Metric")
print("=" * 60)

C_major = frozenset({0, 4, 7})    # C major triad
G_major = frozenset({7, 11, 2})   # G major triad
D_minor = frozenset({2, 5, 9})    # D minor triad

print(f"C major: {sorted(C_major)} = {{{', '.join(PC_NAMES[i] for i in sorted(C_major))}}}")
print(f"G major: {sorted(G_major)} = {{{', '.join(PC_NAMES[i] for i in sorted(G_major))}}}")
print(f"D minor: {sorted(D_minor)} = {{{', '.join(PC_NAMES[i] for i in sorted(D_minor))}}}")
print()

d_CG = hamming_dist(C_major, G_major)
d_GD = hamming_dist(G_major, D_minor)
d_CD = hamming_dist(C_major, D_minor)

print(f"d(C, G) = {d_CG}")
print(f"d(G, Dm) = {d_GD}")
print(f"d(C, Dm) = {d_CD}")
print(f"Triangle inequality: {d_CD} ≤ {d_CG} + {d_GD} = {d_CG + d_GD}? {d_CD <= d_CG + d_GD}")
print()

# === DEMO 2: Isometries ===
print("=" * 60)
print("DEMO 2: Transposition and Complementation Isometries")
print("=" * 60)

for t in [1, 5, 7]:
    d_original = hamming_dist(C_major, G_major)
    d_transposed = hamming_dist(transpose(C_major, t), transpose(G_major, t))
    print(f"T_{t}: d(C, G) = {d_original}, d(T_{t}(C), T_{t}(G)) = {d_transposed}  ✓" if d_original == d_transposed else "✗")

d_comp = hamming_dist(complement(C_major), complement(G_major))
print(f"Complement: d(C, G) = {d_CG}, d(Cᶜ, Gᶜ) = {d_comp}  {'✓' if d_CG == d_comp else '✗'}")
print()

# === DEMO 3: Intervallic Fingerprint Invariance ===
print("=" * 60)
print("DEMO 3: Intervallic Fingerprint Invariance")
print("=" * 60)

S = C_major
fp_S = intervallic_fingerprint(S)
for t in [0, 3, 7]:
    fp_T = intervallic_fingerprint(transpose(S, t))
    print(f"T_{t}(C major): fingerprint match = {fp_S == fp_T}")

fp_inv = intervallic_fingerprint(invert(S))
print(f"Inv(C major): fingerprint match = {fp_S == fp_inv}")
print(f"  (Inversion negates intervals, so fingerprints differ for asymmetric sets)")
print()

# === DEMO 4: Hexachordal Complementation Theorem ===
print("=" * 60)
print("DEMO 4: Hexachordal Complementation (Babbitt 1961)")
print("=" * 60)

# Test all possible hexachords (C(12,6) = 924)
all_hexachords = [frozenset(s) for s in combinations(range(12), 6)]
all_pass = True
for S in all_hexachords:
    iv_S = interval_vector(S)
    iv_comp = interval_vector(complement(S))
    if iv_S != iv_comp:
        print(f"FAIL: {sorted(S)} has IV {iv_S} but complement has {iv_comp}")
        all_pass = False

print(f"Tested all {len(all_hexachords)} hexachords: {'ALL PASS ✓' if all_pass else 'FAILURES FOUND ✗'}")
print()

# Show a specific example
S = frozenset({0, 1, 2, 3, 4, 5})
print(f"Example: S = {sorted(S)}")
print(f"  IV(S)  = {interval_vector(S)}")
print(f"  IV(Sᶜ) = {interval_vector(complement(S))}")
print()

# A more musically interesting hexachord
S = frozenset({0, 1, 3, 5, 6, 8})  # "all-interval hexachord"
print(f"All-interval hexachord: S = {sorted(S)}")
print(f"  IV(S)  = {interval_vector(S)}")
print(f"  IV(Sᶜ) = {interval_vector(complement(S))}")
print()

# === DEMO 5: Orbit Structure ===
print("=" * 60)
print("DEMO 5: Orbits Under Transposition")
print("=" * 60)

# Count orbits of triads
triad_orbits = {}
for root in range(12):
    major = frozenset({root, (root + 4) % 12, (root + 7) % 12})
    key = frozenset(frozenset(transpose(major, t)) for t in range(12))
    fkey = frozenset(key)
    if fkey not in triad_orbits:
        triad_orbits[fkey] = major

print(f"Number of distinct major triad orbits: {len(triad_orbits)}")
print(f"  (All major triads are in one orbit — orbit size 12)")
print()

# Find PCS with non-trivial stabilizers
print("PCS with non-trivial stabilizers (size > 1):")
for S in [frozenset(s) for s in combinations(range(12), 3)]:
    stab = [t for t in range(12) if transpose(S, t) == S]
    if len(stab) > 1:
        orbit_set = set()
        for t in range(12):
            orbit_set.add(frozenset(transpose(S, t)))
        print(f"  {sorted(S)}: stabilizer = {stab}, orbit size = {len(orbit_set)}, "
              f"|stab| × |orbit| = {len(stab) * len(orbit_set)}")
        break  # just show first example

# The augmented triad
aug = frozenset({0, 4, 8})
stab_aug = [t for t in range(12) if transpose(aug, t) == aug]
orbit_aug = set(frozenset(transpose(aug, t)) for t in range(12))
print(f"  Augmented triad {sorted(aug)}: stabilizer = {stab_aug}, orbit size = {len(orbit_aug)}")
print(f"  |stab| × |orbit| = {len(stab_aug)} × {len(orbit_aug)} = {len(stab_aug) * len(orbit_aug)} = 12 ✓")
print()

# The diminished seventh
dim7 = frozenset({0, 3, 6, 9})
stab_dim7 = [t for t in range(12) if transpose(dim7, t) == dim7]
orbit_dim7 = set(frozenset(transpose(dim7, t)) for t in range(12))
print(f"  Diminished 7th {sorted(dim7)}: stabilizer = {stab_dim7}, orbit size = {len(orbit_dim7)}")
print(f"  |stab| × |orbit| = {len(stab_dim7)} × {len(orbit_dim7)} = {len(stab_dim7) * len(orbit_dim7)} = 12 ✓")

print()
print("=" * 60)
print("All demonstrations complete.")


#!/usr/bin/env python3
"""
Visualization: Chord Space Metric Geometry

Creates a heatmap of Hamming distances between major and minor triads,
revealing the metric structure of chord space.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations

PC_NAMES = ['C', 'C#', 'D', 'Eb', 'E', 'F', 'F#', 'G', 'Ab', 'A', 'Bb', 'B']

def transpose(S, t):
    return frozenset((x + t) % 12 for x in S)

def hamming_dist(A, B):
    return len(A.symmetric_difference(B))

# Build all major and minor triads
major_template = frozenset({0, 4, 7})
minor_template = frozenset({0, 3, 7})

chords = []
labels = []
for root in range(12):
    chords.append(transpose(major_template, root))
    labels.append(f"{PC_NAMES[root]}")
for root in range(12):
    chords.append(transpose(minor_template, root))
    labels.append(f"{PC_NAMES[root]}m")

n = len(chords)
D = np.zeros((n, n), dtype=int)
for i in range(n):
    for j in range(n):
        D[i, j] = hamming_dist(chords[i], chords[j])

fig, ax = plt.subplots(figsize=(14, 12))
im = ax.imshow(D, cmap='YlOrRd_r', interpolation='nearest')
ax.set_xticks(range(n))
ax.set_yticks(range(n))
ax.set_xticklabels(labels, rotation=90, fontsize=8)
ax.set_yticklabels(labels, fontsize=8)

# Add text annotations
for i in range(n):
    for j in range(n):
        ax.text(j, i, str(D[i, j]), ha='center', va='center',
                fontsize=6, color='black' if D[i, j] > 2 else 'white')

ax.set_title('Hamming Distance Between Major & Minor Triads in ℤ/12ℤ', fontsize=14)
plt.colorbar(im, label='Hamming Distance')

# Draw separator between major and minor
ax.axhline(y=11.5, color='blue', linewidth=2)
ax.axvline(x=11.5, color='blue', linewidth=2)
ax.text(5.5, -1.5, 'Major', ha='center', fontsize=10, color='blue')
ax.text(17.5, -1.5, 'Minor', ha='center', fontsize=10, color='blue')

plt.tight_layout()
plt.savefig('chord_space_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved chord_space_heatmap.png")

# Second plot: Circle of fifths distances
fig2, ax2 = plt.subplots(figsize=(10, 10), subplot_kw={'projection': 'polar'})
fifths_order = [(7 * k) % 12 for k in range(12)]
angles = np.linspace(0, 2 * np.pi, 13)[:-1]

# Plot the circle of fifths
for i, root in enumerate(fifths_order):
    chord = transpose(major_template, root)
    ax2.plot(angles[i], 1, 'o', markersize=15, color='steelblue')
    ax2.text(angles[i], 1.15, PC_NAMES[root], ha='center', va='center',
             fontsize=10, fontweight='bold')

# Draw edges colored by Hamming distance
for i in range(12):
    for j in range(i + 1, 12):
        ci = transpose(major_template, fifths_order[i])
        cj = transpose(major_template, fifths_order[j])
        d = hamming_dist(ci, cj)
        if d <= 2:  # Only show close connections
            alpha = 1.0 - d / 6.0
            ax2.plot([angles[i], angles[j]], [1, 1],
                     color='red' if d == 2 else 'green',
                     alpha=alpha, linewidth=2)

ax2.set_title('Circle of Fifths: Close Triads (d ≤ 2)', fontsize=14, pad=20)
ax2.set_ylim(0, 1.3)
ax2.set_yticks([])

plt.tight_layout()
plt.savefig('circle_of_fifths.png', dpi=150, bbox_inches='tight')
print("Saved circle_of_fifths.png")
