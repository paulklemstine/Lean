#!/usr/bin/env python3
"""
Dreamtime Algebra: Aboriginal Kinship Systems as Group Theory

Demonstrates the group-theoretic structure of 4-section and 8-subsection
kinship systems, including marriage rules, descent cycles, and coset partitions.
"""

from itertools import product
from typing import List, Tuple, Dict, Set

# Type alias for group elements
Vec2 = Tuple[int, int]
Vec3 = Tuple[int, int, int]

def add_mod2_2(a: Vec2, b: Vec2) -> Vec2:
    """Addition in Z₂ × Z₂."""
    return ((a[0] + b[0]) % 2, (a[1] + b[1]) % 2)

def add_mod2_3(a: Vec3, b: Vec3) -> Vec3:
    """Addition in Z₂ × Z₂ × Z₂."""
    return ((a[0] + b[0]) % 2, (a[1] + b[1]) % 2, (a[2] + b[2]) % 2)

# ── 4-Section System (Klein Four-Group) ──

print("=" * 60)
print("THE 4-SECTION (KARIERA) KINSHIP SYSTEM")
print("=" * 60)

Z2_2 = list(product(range(2), repeat=2))
section_names = {(0, 0): "A (Banaka)", (1, 0): "B (Burung)",
                 (0, 1): "C (Karimera)", (1, 1): "D (Palyeri)"}

print("\nSections and their Z₂×Z₂ encodings:")
for elem in Z2_2:
    print(f"  {section_names[elem]:20s} = {elem}")

# Verify group axioms
print("\n── Addition Table (Z₂ × Z₂) ──")
print(f"{'':>8}", end="")
for b in Z2_2:
    print(f"{str(b):>10}", end="")
print()
for a in Z2_2:
    print(f"{str(a):>8}", end="")
    for b in Z2_2:
        print(f"{str(add_mod2_2(a, b)):>10}", end="")
    print()

# Verify elementary abelian property
print("\n── Elementary Abelian: x + x = 0 ──")
for x in Z2_2:
    print(f"  {x} + {x} = {add_mod2_2(x, x)}")

# Marriage rule: translate by m = (1, 0)
m = (1, 0)
print(f"\n── Marriage Rule (marriage element m = {m}) ──")
for g in Z2_2:
    spouse = add_mod2_2(g, m)
    print(f"  {section_names[g]:20s} marries {section_names[spouse]}")

# Descent rule: translate by d = (0, 1)
d = (0, 1)
print(f"\n── Descent Rule (descent element d = {d}) ──")
for g in Z2_2:
    child = add_mod2_2(g, d)
    print(f"  Child of {section_names[g]:20s} → {section_names[child]}")

# Grandmother theorem
print("\n── Grandmother Theorem: g + d + d = g ──")
for g in Z2_2:
    grandchild = add_mod2_2(add_mod2_2(g, d), d)
    print(f"  {section_names[g]:20s} → child: {section_names[add_mod2_2(g, d)]:20s} → grandchild: {section_names[grandchild]}")

# Coset structure
print("\n── Marriage Cosets of ⟨m⟩ = {(0,0), (1,0)} ──")
subgroup_m = {(0, 0), m}
cosets: List[Set[Vec2]] = []
assigned: Set[Vec2] = set()
for g in Z2_2:
    if g not in assigned:
        coset = {add_mod2_2(g, s) for s in subgroup_m}
        cosets.append(coset)
        assigned |= coset
for i, coset in enumerate(cosets):
    names = [section_names[c] for c in sorted(coset)]
    print(f"  Coset {i+1}: {names}")

# Cross-marriage consistency
print("\n── Cross-Generational Consistency ──")
for g in Z2_2:
    child_spouse = add_mod2_2(add_mod2_2(g, d), m)
    spouse_child = add_mod2_2(add_mod2_2(g, m), d)
    ok = "✓" if child_spouse == spouse_child else "✗"
    print(f"  {ok} (g+d)+m = {child_spouse} = (g+m)+d = {spouse_child}  [g={g}]")

# ── 8-Subsection System ──

print("\n" + "=" * 60)
print("THE 8-SUBSECTION SYSTEM")
print("=" * 60)

Z2_3 = list(product(range(2), repeat=3))
subsection_names = {
    (0, 0, 0): "Nangala",  (1, 0, 0): "Napanangka",
    (0, 1, 0): "Nakamarra", (1, 1, 0): "Napurrula",
    (0, 0, 1): "Napaltjarri", (1, 0, 1): "Napaljarri",
    (0, 1, 1): "Nampijinpa", (1, 1, 1): "Nungarrayi",
}

print("\nSubsections and their Z₂³ encodings:")
for elem in Z2_3:
    print(f"  {subsection_names[elem]:16s} = {elem}")

# Marriage in 8-system
m8 = (1, 0, 0)
d8 = (0, 1, 0)
print(f"\n── Marriage Rule (m = {m8}) ──")
for g in Z2_3:
    spouse = add_mod2_3(g, m8)
    print(f"  {subsection_names[g]:16s} marries {subsection_names[spouse]}")

# Refinement map
print("\n── Refinement: 8-subsections → 4-sections ──")
for g in Z2_3:
    refined = (g[0], g[1])
    print(f"  {subsection_names[g]:16s} {g} → {section_names[refined]:20s} {refined}")

# Count kinship systems
print("\n── Counting Kinship Systems ──")
count_4 = sum(1 for m in Z2_2 for d in Z2_2
              if m != (0, 0) and d != (0, 0) and m != d)
count_8 = sum(1 for m in Z2_3 for d in Z2_3
              if m != (0, 0, 0) and d != (0, 0, 0) and m != d)
print(f"  Kinship systems on Z₂²: {count_4}")
print(f"  Kinship systems on Z₂³: {count_8}")

# Automorphism group
print("\n── Automorphisms of Z₂ × Z₂ ──")
auts = []
nonzero = [x for x in Z2_2 if x != (0, 0)]
from itertools import permutations
for perm in permutations(nonzero):
    # Check if this permutation extends to a group automorphism
    mapping = {(0, 0): (0, 0)}
    for i, nz in enumerate(nonzero):
        mapping[nz] = perm[i]
    # Verify homomorphism
    is_aut = True
    for a in Z2_2:
        for b in Z2_2:
            if mapping.get(add_mod2_2(a, b)) != add_mod2_2(mapping[a], mapping[b]):
                is_aut = False
                break
        if not is_aut:
            break
    if is_aut:
        auts.append(mapping)

print(f"  Number of automorphisms: {len(auts)}")
for i, aut in enumerate(auts):
    print(f"  Aut {i+1}: {nonzero[0]}→{aut[nonzero[0]]}, {nonzero[1]}→{aut[nonzero[1]]}, {nonzero[2]}→{aut[nonzero[2]]}")

# Verify involution → abelian
print("\n── Involution ⇒ Abelian (Abstract Theorem) ──")
print("  If x + x = 0 for all x, then x = -x for all x.")
print("  Then a + b = -(a+b) = (-b)+(-a) = b + a.")
print("  Verified for Z₂²:")
for a in Z2_2:
    for b in Z2_2:
        ab = add_mod2_2(a, b)
        ba = add_mod2_2(b, a)
        assert ab == ba
print("  ✓ All pairs commute.")

print("\n" + "=" * 60)
print("ALL DEMONSTRATIONS COMPLETE")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Coset partition of marriage classes in Z₂ × Z₂.
Shows how different marriage elements create different partitions.
"""
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import product

def add_z2(a, b):
    return tuple((ai + bi) % 2 for ai, bi in zip(a, b))

sections = list(product(range(2), repeat=2))
names = {(0,0): "A", (1,0): "B", (0,1): "C", (1,1): "D"}
marriage_elements = [(1,0), (0,1), (1,1)]
marriage_labels = ["m = (1,0)", "m = (0,1)", "m = (1,1)"]

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

coset_colors = ["#FF6B6B", "#4ECDC4"]

for idx, (m, label) in enumerate(zip(marriage_elements, marriage_labels)):
    ax = axes[idx]
    ax.set_title(f"Marriage Cosets\n{label}", fontsize=13, fontweight='bold')

    # Compute cosets
    subgroup = {(0,0), m}
    cosets = []
    assigned = set()
    for g in sections:
        if g not in assigned:
            coset = {add_z2(g, s) for s in subgroup}
            cosets.append(sorted(coset))
            assigned |= coset

    # Draw cosets as boxes
    for ci, coset in enumerate(cosets):
        y_offset = 1.5 - ci * 1.8
        box_color = coset_colors[ci]

        rect = mpatches.FancyBboxPatch((0.1, y_offset - 0.3), 2.8, 0.8,
                                        boxstyle="round,pad=0.1",
                                        facecolor=box_color, alpha=0.3,
                                        edgecolor=box_color, linewidth=2)
        ax.add_patch(rect)

        for j, elem in enumerate(coset):
            x = 0.8 + j * 1.4
            circle = plt.Circle((x, y_offset + 0.1), 0.25,
                               color=box_color, zorder=3)
            ax.add_patch(circle)
            ax.text(x, y_offset + 0.1, f"{names[elem]}\n{elem}",
                   ha='center', va='center', fontsize=10, fontweight='bold', zorder=4)

        # Draw marriage arrow between coset members
        ax.annotate("", xy=(0.8 + 1.4, y_offset + 0.1), xytext=(0.8, y_offset + 0.1),
                    arrowprops=dict(arrowstyle="<->", color="darkred", lw=2))
        ax.text(1.5, y_offset + 0.45, "marry", ha='center', va='center',
               fontsize=9, color="darkred", fontstyle='italic')

    ax.set_xlim(-0.1, 3.1)
    ax.set_ylim(-1.0, 2.2)
    ax.set_aspect('equal')
    ax.axis('off')

plt.suptitle("Marriage Classes as Cosets of ⟨m⟩ in Z₂ × Z₂",
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig("coset_partition.png", dpi=150, bbox_inches='tight')
plt.close()
print("Saved coset_partition.png")


#!/usr/bin/env python3
"""
Visualization: Kinship system marriage and descent graphs.
"""
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import product

def add_z2(a, b):
    return tuple((ai + bi) % 2 for ai, bi in zip(a, b))

# 4-section system
fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Marriage graph
ax = axes[0]
ax.set_title("Marriage Graph\n(translate by (1,0))", fontsize=13, fontweight='bold')
sections = list(product(range(2), repeat=2))
names = {(0,0): "A", (1,0): "B", (0,1): "C", (1,1): "D"}
colors = {(0,0): "#FF6B6B", (1,0): "#4ECDC4", (0,1): "#45B7D1", (1,1): "#96CEB4"}
positions = {(0,0): (0, 1), (1,0): (1, 1), (0,1): (0, 0), (1,1): (1, 0)}

m = (1, 0)
for g in sections:
    x, y = positions[g]
    ax.add_patch(plt.Circle((x, y), 0.15, color=colors[g], zorder=3))
    ax.text(x, y, names[g], ha='center', va='center', fontsize=14, fontweight='bold', zorder=4)

for g in sections:
    spouse = add_z2(g, m)
    if g < spouse:
        x1, y1 = positions[g]
        x2, y2 = positions[spouse]
        ax.annotate("", xy=(x2, y2), xytext=(x1, y1),
                     arrowprops=dict(arrowstyle="<->", color="red", lw=2))

ax.set_xlim(-0.4, 1.4)
ax.set_ylim(-0.4, 1.4)
ax.set_aspect('equal')
ax.axis('off')

# Descent graph
ax = axes[1]
ax.set_title("Descent Graph\n(translate by (0,1))", fontsize=13, fontweight='bold')

d = (0, 1)
for g in sections:
    x, y = positions[g]
    ax.add_patch(plt.Circle((x, y), 0.15, color=colors[g], zorder=3))
    ax.text(x, y, names[g], ha='center', va='center', fontsize=14, fontweight='bold', zorder=4)

for g in sections:
    child = add_z2(g, d)
    if g < child:
        x1, y1 = positions[g]
        x2, y2 = positions[child]
        ax.annotate("", xy=(x2, y2), xytext=(x1, y1),
                     arrowprops=dict(arrowstyle="<->", color="blue", lw=2))

ax.set_xlim(-0.4, 1.4)
ax.set_ylim(-0.4, 1.4)
ax.set_aspect('equal')
ax.axis('off')

# Combined kinship graph
ax = axes[2]
ax.set_title("Full Kinship System\n(Cayley Graph of Z₂×Z₂)", fontsize=13, fontweight='bold')

for g in sections:
    x, y = positions[g]
    ax.add_patch(plt.Circle((x, y), 0.15, color=colors[g], zorder=3))
    ax.text(x, y, f"{names[g]}\n{g}", ha='center', va='center', fontsize=10, fontweight='bold', zorder=4)

for g in sections:
    spouse = add_z2(g, m)
    if g < spouse:
        x1, y1 = positions[g]
        x2, y2 = positions[spouse]
        ax.plot([x1, x2], [y1, y2], 'r-', lw=2, label='Marriage' if g == (0,0) else None)

for g in sections:
    child = add_z2(g, d)
    if g < child:
        x1, y1 = positions[g]
        x2, y2 = positions[child]
        ax.plot([x1, x2], [y1, y2], 'b--', lw=2, label='Descent' if g == (0,0) else None)

ax.legend(loc='upper right', fontsize=10)
ax.set_xlim(-0.4, 1.4)
ax.set_ylim(-0.4, 1.4)
ax.set_aspect('equal')
ax.axis('off')

plt.suptitle("Aboriginal 4-Section Kinship System as Klein Four-Group Z₂ × Z₂",
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig("kinship_graphs.png", dpi=150, bbox_inches='tight')
plt.close()
print("Saved kinship_graphs.png")
