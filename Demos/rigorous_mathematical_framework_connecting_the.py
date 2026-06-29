#!/usr/bin/env python3
"""
Tropical Rhythm Algebra — Numerical Demonstrations

Demonstrates the key theorems from the formal Lean 4 proofs:
1. Weight invariance under cyclic shift
2. Complement weight formula
3. Inclusion-exclusion for rhythm weights
4. Palindrome sublattice properties
5. Pythagorean onset ratios
"""

from typing import List, Tuple
from fractions import Fraction


def rhythm_from_onsets(n: int, onsets: List[int]) -> List[bool]:
    """Create a rhythm of period n with given onset positions."""
    return [i in onsets for i in range(n)]


def weight(r: List[bool]) -> int:
    """Onset count (Hamming weight) of a rhythm."""
    return sum(1 for b in r if b)


def cyclic_shift(r: List[bool], k: int) -> List[bool]:
    """Rotate rhythm by k positions."""
    n = len(r)
    return [r[(i + k) % n] for i in range(n)]


def reverse_rhythm(r: List[bool]) -> List[bool]:
    """Time-reversal of a rhythm."""
    n = len(r)
    return [r[(n - 1 - i) % n] for i in range(n)]


def complement(r: List[bool]) -> List[bool]:
    """Complement: swap onsets and rests."""
    return [not b for b in r]


def union(r: List[bool], s: List[bool]) -> List[bool]:
    """Pointwise OR (tropical max)."""
    return [a or b for a, b in zip(r, s)]


def intersect(r: List[bool], s: List[bool]) -> List[bool]:
    """Pointwise AND (tropical min)."""
    return [a and b for a, b in zip(r, s)]


def is_palindrome(r: List[bool]) -> bool:
    """Check if rhythm is palindromic."""
    n = len(r)
    return all(r[i] == r[(n - 1 - i) % n] for i in range(n))


def onset_ratio(r: List[bool], s: List[bool]) -> Fraction:
    """Onset ratio between two rhythms."""
    return Fraction(weight(r), weight(s))


def display_rhythm(r: List[bool], name: str = "") -> str:
    """Visual representation of a rhythm."""
    pattern = "".join("●" if b else "○" for b in r)
    prefix = f"{name}: " if name else ""
    return f"{prefix}[{pattern}] (weight={weight(r)}, density={weight(r)}/{len(r)})"


# ============================================================
# Demo 1: Weight Invariance Under Cyclic Shift
# ============================================================
print("=" * 60)
print("DEMO 1: Weight Invariance Under Cyclic Shift")
print("=" * 60)

r = rhythm_from_onsets(8, [0, 2, 4, 5])  # Bossa nova-like
print(f"\nOriginal: {display_rhythm(r)}")
for k in range(8):
    shifted = cyclic_shift(r, k)
    print(f"  Shift {k}: {display_rhythm(shifted)}")
    assert weight(shifted) == weight(r), "Weight invariance violated!"
print("✓ Weight is invariant under all cyclic shifts")


# ============================================================
# Demo 2: Complement Weight Formula
# ============================================================
print(f"\n{'=' * 60}")
print("DEMO 2: Complement Weight Formula: w(r) + w(¬r) = n")
print("=" * 60)

for n in [5, 8, 12]:
    for onsets in [[0, 1, 2], [0, 2, 4], list(range(n))]:
        onsets_clipped = [o for o in onsets if o < n]
        r = rhythm_from_onsets(n, onsets_clipped)
        c = complement(r)
        print(f"\n  r = {display_rhythm(r)}")
        print(f"  ¬r = {display_rhythm(c)}")
        print(f"  w(r) + w(¬r) = {weight(r)} + {weight(c)} = {weight(r) + weight(c)} = {n}")
        assert weight(r) + weight(c) == n

print("\n✓ Complement weight formula verified for all examples")


# ============================================================
# Demo 3: Inclusion-Exclusion
# ============================================================
print(f"\n{'=' * 60}")
print("DEMO 3: Inclusion-Exclusion: w(r∪s) + w(r∩s) = w(r) + w(s)")
print("=" * 60)

r = rhythm_from_onsets(8, [0, 1, 3, 5])
s = rhythm_from_onsets(8, [1, 2, 5, 6, 7])
u = union(r, s)
i = intersect(r, s)

print(f"\n  r   = {display_rhythm(r, 'r')}")
print(f"  s   = {display_rhythm(s, 's')}")
print(f"  r∪s = {display_rhythm(u, 'r∪s')}")
print(f"  r∩s = {display_rhythm(i, 'r∩s')}")
print(f"\n  w(r∪s) + w(r∩s) = {weight(u)} + {weight(i)} = {weight(u) + weight(i)}")
print(f"  w(r) + w(s)     = {weight(r)} + {weight(s)} = {weight(r) + weight(s)}")
assert weight(u) + weight(i) == weight(r) + weight(s)
print("✓ Inclusion-exclusion verified")


# ============================================================
# Demo 4: Palindrome Sublattice
# ============================================================
print(f"\n{'=' * 60}")
print("DEMO 4: Palindrome Sublattice")
print("=" * 60)

# Palindromic rhythms of period 7
p1 = rhythm_from_onsets(7, [0, 1, 5, 6])  # ●●○○○●● → palindrome
p2 = rhythm_from_onsets(7, [0, 3, 6])     # ●○○●○○● → palindrome

print(f"\n  p1 = {display_rhythm(p1)} palindrome={is_palindrome(p1)}")
print(f"  p2 = {display_rhythm(p2)} palindrome={is_palindrome(p2)}")

u_p = union(p1, p2)
i_p = intersect(p1, p2)
c_p = complement(p1)

print(f"  p1∪p2 = {display_rhythm(u_p)} palindrome={is_palindrome(u_p)}")
print(f"  p1∩p2 = {display_rhythm(i_p)} palindrome={is_palindrome(i_p)}")
print(f"  ¬p1   = {display_rhythm(c_p)} palindrome={is_palindrome(c_p)}")

assert is_palindrome(p1) and is_palindrome(p2)
assert is_palindrome(u_p), "Union of palindromes should be palindrome"
assert is_palindrome(i_p), "Intersection of palindromes should be palindrome"
assert is_palindrome(c_p), "Complement of palindrome should be palindrome"
print("✓ Palindromic rhythms form a sublattice (closed under ∪, ∩, ¬)")


# ============================================================
# Demo 5: Pythagorean Onset Ratios
# ============================================================
print(f"\n{'=' * 60}")
print("DEMO 5: Pythagorean Onset Ratios")
print("=" * 60)

# 12-beat rhythms from (3,4,5) decomposition
r4 = rhythm_from_onsets(12, [0, 1, 2, 3])     # 4 onsets
r3 = rhythm_from_onsets(12, [0, 1, 2])         # 3 onsets
r5 = rhythm_from_onsets(12, [0, 1, 2, 3, 4])   # 5 onsets

print(f"\n  r4 = {display_rhythm(r4)} (4 onsets)")
print(f"  r3 = {display_rhythm(r3)} (3 onsets)")
print(f"  r5 = {display_rhythm(r5)} (5 onsets)")

ratio_43 = onset_ratio(r4, r3)
ratio_54 = onset_ratio(r5, r4)
ratio_53 = onset_ratio(r5, r3)

print(f"\n  Onset ratio 4:3 = {ratio_43} → Perfect Fourth")
print(f"  Onset ratio 5:4 = {ratio_54} → Major Third")
print(f"  Onset ratio 5:3 = {ratio_53} → Major Sixth")

assert ratio_43 == Fraction(4, 3), "Should be perfect fourth"
assert ratio_54 == Fraction(5, 4), "Should be major third"
assert ratio_53 == Fraction(5, 3), "Should be major sixth"
print("✓ Pythagorean triple (3,4,5) yields consonant musical intervals")


# ============================================================
# Demo 6: Shift Distributes Over Lattice Operations
# ============================================================
print(f"\n{'=' * 60}")
print("DEMO 6: Shift as Boolean Algebra Automorphism")
print("=" * 60)

r = rhythm_from_onsets(8, [0, 2, 5])
s = rhythm_from_onsets(8, [1, 3, 5, 7])
k = 3

# Shift distributes over union
lhs_u = cyclic_shift(union(r, s), k)
rhs_u = union(cyclic_shift(r, k), cyclic_shift(s, k))
assert lhs_u == rhs_u
print(f"\n  σ_{k}(r ∪ s) = σ_{k}(r) ∪ σ_{k}(s) ✓")

# Shift distributes over intersection
lhs_i = cyclic_shift(intersect(r, s), k)
rhs_i = intersect(cyclic_shift(r, k), cyclic_shift(s, k))
assert lhs_i == rhs_i
print(f"  σ_{k}(r ∩ s) = σ_{k}(r) ∩ σ_{k}(s) ✓")

# Shift commutes with complement
lhs_c = cyclic_shift(complement(r), k)
rhs_c = complement(cyclic_shift(r, k))
assert lhs_c == rhs_c
print(f"  σ_{k}(¬r) = ¬σ_{k}(r) ✓")

print("✓ Cyclic shift is a Boolean algebra automorphism")


# ============================================================
# Demo 7: Orbit Weight Constancy
# ============================================================
print(f"\n{'=' * 60}")
print("DEMO 7: Orbit Weight Constancy Under Arbitrary Shift Sequences")
print("=" * 60)

r = rhythm_from_onsets(12, [0, 3, 6, 9])  # Uniform 4-beat
shifts = [3, 7, 2, 11, 5, 1]
current = r[:]
print(f"\n  Start: {display_rhythm(current)}")
for k in shifts:
    current = cyclic_shift(current, k)
    print(f"  After shift {k:2d}: {display_rhythm(current)}")
    assert weight(current) == weight(r)
print(f"✓ Weight remains {weight(r)} through all {len(shifts)} shifts")

print(f"\n{'=' * 60}")
print("ALL DEMONSTRATIONS PASSED ✓")
print("=" * 60)


#!/usr/bin/env python3
"""
Tropical Rhythm Algebra — Visualization

Produces circular rhythm diagrams, weight distribution plots, and
lattice structure visualizations.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from typing import List, Set, Tuple, Dict
from itertools import product
from fractions import Fraction
import math


def rhythm_from_onsets(n: int, onsets: Set[int]) -> List[bool]:
    return [i in onsets for i in range(n)]


def weight(r: List[bool]) -> int:
    return sum(1 for b in r if b)


def cyclic_shift(r: List[bool], k: int) -> List[bool]:
    n = len(r)
    return [r[(i + k) % n] for i in range(n)]


def shift_orbit(r: List[bool]) -> Set[Tuple[bool, ...]]:
    n = len(r)
    orbit = set()
    for k in range(n):
        orbit.add(tuple(cyclic_shift(r, k)))
    return orbit


def euler_phi(n: int) -> int:
    result = n
    p = 2
    temp = n
    while p * p <= temp:
        if temp % p == 0:
            while temp % p == 0:
                temp //= p
            result -= result // p
        p += 1
    if temp > 1:
        result -= result // temp
    return result


def burnside_count(n: int) -> int:
    total = 0
    for d in range(1, n + 1):
        if n % d == 0:
            total += euler_phi(n // d) * (2 ** d)
    return total // n


def count_by_weight(n: int) -> Dict[int, int]:
    seen = set()
    counts = {}
    for bits in product([False, True], repeat=n):
        if bits not in seen:
            r = list(bits)
            orbit = shift_orbit(r)
            seen.update(orbit)
            w = weight(r)
            counts[w] = counts.get(w, 0) + 1
    return counts


def draw_circular_rhythm(ax, r: List[bool], title: str = "", color_on='#E74C3C', color_off='#ECF0F1'):
    """Draw a rhythm as a circular pattern (clock diagram)."""
    n = len(r)
    angles = [2 * np.pi * i / n - np.pi / 2 for i in range(n)]

    # Draw circle
    theta = np.linspace(0, 2 * np.pi, 100)
    ax.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=0.5, alpha=0.3)

    # Draw beats
    for i, (angle, beat) in enumerate(zip(angles, r)):
        x, y = np.cos(angle), np.sin(angle)
        color = color_on if beat else color_off
        edge = '#2C3E50' if beat else '#BDC3C7'
        size = 300 if beat else 150
        ax.scatter(x, y, s=size, c=color, edgecolors=edge, linewidths=1.5, zorder=5)
        # Label
        lx, ly = 1.25 * np.cos(angle), 1.25 * np.sin(angle)
        ax.text(lx, ly, str(i), ha='center', va='center', fontsize=8, color='#7F8C8D')

    ax.set_xlim(-1.6, 1.6)
    ax.set_ylim(-1.6, 1.6)
    ax.set_aspect('equal')
    ax.set_title(title, fontsize=11, fontweight='bold')
    ax.axis('off')


# ============================================================
# Figure 1: Rhythms and Their Symmetries
# ============================================================
fig, axes = plt.subplots(2, 3, figsize=(14, 9))
fig.suptitle('Tropical Rhythm Algebra: Rhythms and Symmetries', fontsize=14, fontweight='bold')

# Original rhythm (tresillo)
r = rhythm_from_onsets(8, {0, 3, 5})
draw_circular_rhythm(axes[0, 0], r, 'Original (Tresillo)\nweight=3')

# Shifted rhythm
r_shift = cyclic_shift(r, 2)
draw_circular_rhythm(axes[0, 1], r_shift, 'Shift by 2\nweight=3')

# Reversed rhythm
r_rev = [r[(8 - 1 - i) % 8] for i in range(8)]
draw_circular_rhythm(axes[0, 2], r_rev, 'Time Reversal\nweight=3')

# Complement
r_comp = [not b for b in r]
draw_circular_rhythm(axes[1, 0], r_comp, 'Complement\nweight=5')

# Union with another rhythm
s = rhythm_from_onsets(8, {1, 3, 6})
r_union = [a or b for a, b in zip(r, s)]
draw_circular_rhythm(axes[1, 1], r_union, 'Union (r ∪ s)\nweight=' + str(weight(r_union)))

# Intersection
r_inter = [a and b for a, b in zip(r, s)]
draw_circular_rhythm(axes[1, 2], r_inter, 'Intersection (r ∩ s)\nweight=' + str(weight(r_inter)))

plt.tight_layout()
plt.savefig('rhythm_symmetries.png', dpi=150, bbox_inches='tight')
plt.close()
print("✓ Saved rhythm_symmetries.png")


# ============================================================
# Figure 2: Weight Distribution (Necklace Counting)
# ============================================================
fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# Left: Weight distribution for n=12
n = 12
dist = count_by_weight(n)
weights = list(range(n + 1))
counts = [dist.get(w, 0) for w in weights]

colors = ['#3498DB' if w <= n // 2 else '#E74C3C' for w in weights]
axes[0].bar(weights, counts, color=colors, edgecolor='white', linewidth=0.5)
axes[0].set_xlabel('Weight (onset count)', fontsize=12)
axes[0].set_ylabel('Distinct rhythms (up to rotation)', fontsize=12)
axes[0].set_title(f'Rhythm Distribution by Weight (n={n})', fontsize=13, fontweight='bold')
axes[0].set_xticks(weights)

# Annotate symmetry
for w in weights:
    if counts[w] > 0:
        axes[0].text(w, counts[w] + 0.3, str(counts[w]), ha='center', fontsize=8)

# Right: Burnside counts for various n
ns = list(range(1, 16))
burnside_counts = [burnside_count(n) for n in ns]

axes[1].bar(ns, burnside_counts, color='#2ECC71', edgecolor='white', linewidth=0.5)
axes[1].set_xlabel('Period n', fontsize=12)
axes[1].set_ylabel('Distinct rhythms (necklaces)', fontsize=12)
axes[1].set_title('Burnside Necklace Counts', fontsize=13, fontweight='bold')
axes[1].set_xticks(ns)

for n_val, count in zip(ns, burnside_counts):
    if count < 500:
        axes[1].text(n_val, count + 5, str(count), ha='center', fontsize=7)

plt.tight_layout()
plt.savefig('weight_distribution.png', dpi=150, bbox_inches='tight')
plt.close()
print("✓ Saved weight_distribution.png")


# ============================================================
# Figure 3: Inclusion-Exclusion Visualization
# ============================================================
fig, ax = plt.subplots(figsize=(10, 4))

n = 12
r = rhythm_from_onsets(n, {0, 2, 4, 6, 8})
s = rhythm_from_onsets(n, {1, 3, 5, 7, 9, 11})

# Plot as horizontal bar chart showing overlap
positions = list(range(n))
y_offset = 0.3

for i in positions:
    # Rhythm r
    color_r = '#3498DB' if r[i] else '#ECF0F1'
    ax.barh(2, 0.8, left=i, color=color_r, edgecolor='white', linewidth=0.5)

    # Rhythm s
    color_s = '#E74C3C' if s[i] else '#ECF0F1'
    ax.barh(1, 0.8, left=i, color=color_s, edgecolor='white', linewidth=0.5)

    # Union
    color_u = '#9B59B6' if (r[i] or s[i]) else '#ECF0F1'
    ax.barh(0, 0.8, left=i, color=color_u, edgecolor='white', linewidth=0.5)

    # Position labels
    ax.text(i + 0.4, -0.7, str(i), ha='center', va='center', fontsize=8)

wr, ws = weight(r), weight(s)
wu = weight([a or b for a, b in zip(r, s)])
wi = weight([a and b for a, b in zip(r, s)])

ax.set_yticks([0, 1, 2])
ax.set_yticklabels([
    f'r ∪ s  (w={wu})',
    f's      (w={ws})',
    f'r      (w={wr})',
], fontsize=11)
ax.set_title(f'Inclusion-Exclusion: w(r∪s) + w(r∩s) = w(r) + w(s)  →  {wu} + {wi} = {wr} + {ws}',
             fontsize=12, fontweight='bold')
ax.set_xlim(-0.5, n + 0.5)
ax.set_ylim(-1.2, 3)
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)
ax.spines['bottom'].set_visible(False)

plt.tight_layout()
plt.savefig('inclusion_exclusion.png', dpi=150, bbox_inches='tight')
plt.close()
print("✓ Saved inclusion_exclusion.png")

print("\nAll visualizations generated successfully.")
