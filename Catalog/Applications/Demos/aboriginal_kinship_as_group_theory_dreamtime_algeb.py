#!/usr/bin/env python3
"""
Dreamtime Algebra: Aboriginal Kinship Systems as Group Theory

Interactive demonstration of kinship section systems modeled as
finite groups acting on person-sets.
"""

import itertools
from typing import List, Tuple, Dict

# ============================================================
# Section 1: The 4-Section (Kariera) System
# ============================================================

SECTIONS_4 = ["A (Banaka)", "B (Burung)", "C (Karimera)", "D (Palyeri)"]

def marriage_4(x: int) -> int:
    """Marriage permutation: swaps (0,1) and (2,3)."""
    return [1, 0, 3, 2][x]

def descent_4(x: int) -> int:
    """Descent permutation: swaps (0,2) and (1,3)."""
    return [2, 3, 0, 1][x]

def dreamtime_4(x: int) -> int:
    """Dreamtime operator T = marriage ∘ descent."""
    return marriage_4(descent_4(x))

def binary_encode_4(x: int) -> Tuple[int, int]:
    """Encode section as binary pair (moiety_bit, generation_bit)."""
    return (x % 2, x // 2)

print("=" * 60)
print("THE 4-SECTION (KARIERA) KINSHIP SYSTEM")
print("=" * 60)
print()

print("Sections and their relationships:")
print(f"{'Section':<18} {'Marries':<18} {'Child of':<18} {'Dreamtime':<18}")
print("-" * 72)
for i in range(4):
    m = marriage_4(i)
    d = descent_4(i)
    t = dreamtime_4(i)
    print(f"{SECTIONS_4[i]:<18} {SECTIONS_4[m]:<18} {SECTIONS_4[d]:<18} {SECTIONS_4[t]:<18}")

print()
print("Verification of group axioms:")
print(f"  Marriage is involution: {all(marriage_4(marriage_4(i)) == i for i in range(4))}")
print(f"  Marriage is fixed-point-free: {all(marriage_4(i) != i for i in range(4))}")
print(f"  Descent is involution: {all(descent_4(descent_4(i)) == i for i in range(4))}")
print(f"  Dreamtime is involution: {all(dreamtime_4(dreamtime_4(i)) == i for i in range(4))}")
print(f"  M and D commute: {all(marriage_4(descent_4(i)) == descent_4(marriage_4(i)) for i in range(4))}")

print()
print("Binary encoding (moiety, generation):")
for i in range(4):
    b = binary_encode_4(i)
    print(f"  {SECTIONS_4[i]:<18} → ({b[0]}, {b[1]})")

print()
print("Hamming distances to marriage partner:")
for i in range(4):
    bi = binary_encode_4(i)
    bm = binary_encode_4(marriage_4(i))
    hamming = sum(1 for a, b in zip(bi, bm) if a != b)
    print(f"  {SECTIONS_4[i]} → {SECTIONS_4[marriage_4(i)]}: Hamming distance = {hamming}")

# ============================================================
# Section 2: The Kinship Group as Z₂ × Z₂
# ============================================================

print()
print("=" * 60)
print("KINSHIP GROUP STRUCTURE")
print("=" * 60)
print()

def perm_to_tuple(f, n):
    return tuple(f(i) for i in range(n))

id_perm = tuple(range(4))
m_perm = perm_to_tuple(marriage_4, 4)
d_perm = perm_to_tuple(descent_4, 4)
md_perm = perm_to_tuple(dreamtime_4, 4)

group_elements = [id_perm, m_perm, d_perm, md_perm]
labels = ["1 (identity)", "m (marriage)", "d (descent)", "T = m·d (dreamtime)"]

print("Group elements as permutations:")
for label, perm in zip(labels, group_elements):
    print(f"  {label:<25}: {list(perm)}")

print()
print("Cayley table (product of row × column):")
print(f"{'':>10} | {'1':>10} {'m':>10} {'d':>10} {'T':>10}")
print("-" * 55)

def compose_perms(p1, p2):
    return tuple(p1[p2[i]] for i in range(len(p1)))

label_map = {id_perm: "1", m_perm: "m", d_perm: "d", md_perm: "T"}
for i, (lab_i, p_i) in enumerate(zip(["1", "m", "d", "T"], group_elements)):
    row = []
    for p_j in group_elements:
        prod = compose_perms(p_i, p_j)
        row.append(label_map[prod])
    print(f"{lab_i:>10} | {''.join(f'{r:>10}' for r in row)}")

print()
print("This is the Klein four-group Z₂ × Z₂!")
print("Isomorphism: 1↔(0,0), m↔(1,0), d↔(0,1), T↔(1,1)")

# ============================================================
# Section 3: The 8-Subsection (Aranda) System
# ============================================================

print()
print("=" * 60)
print("THE 8-SUBSECTION (ARANDA) SYSTEM")
print("=" * 60)
print()

SUBSECTIONS_8 = [
    "A₁ (Pananka)", "A₂ (Paltara)", "B₁ (Purula)", "B₂ (Kamara)",
    "C₁ (Ngala)", "C₂ (Mbitjana)", "D₁ (Bangata)", "D₂ (Knuraia)"
]

def marriage_8(x: int) -> int:
    """Flip bit 0."""
    return x ^ 1

def descent_8(x: int) -> int:
    """Flip bit 1."""
    return x ^ 2

def matri_descent_8(x: int) -> int:
    """Flip bit 2."""
    return x ^ 4

print("Subsections and their transformations:")
print(f"{'Sub':<18} {'Marriage':<18} {'Pat.Desc.':<18} {'Mat.Desc.':<18}")
print("-" * 72)
for i in range(8):
    print(f"{SUBSECTIONS_8[i]:<18} {SUBSECTIONS_8[marriage_8(i)]:<18} "
          f"{SUBSECTIONS_8[descent_8(i)]:<18} {SUBSECTIONS_8[matri_descent_8(i)]:<18}")

print()
print("Binary encoding (moiety, patriline, matriline):")
for i in range(8):
    bits = ((i >> 0) & 1, (i >> 1) & 1, (i >> 2) & 1)
    print(f"  {SUBSECTIONS_8[i]:<18} → {bits}")

# Verify group structure
print()
print("Group verification for (Z₂)³:")
generators = [marriage_8, descent_8, matri_descent_8]
gen_names = ["marriage", "descent", "matri_descent"]

# Check all generators are involutions
for name, gen in zip(gen_names, generators):
    is_invol = all(gen(gen(i)) == i for i in range(8))
    print(f"  {name} is involution: {is_invol}")

# Check pairwise commutativity
for i in range(3):
    for j in range(i+1, 3):
        commutes = all(
            generators[i](generators[j](x)) == generators[j](generators[i](x))
            for x in range(8)
        )
        print(f"  {gen_names[i]} and {gen_names[j]} commute: {commutes}")

# Count distinct group elements
group_8 = set()
for bits in itertools.product([0, 1], repeat=3):
    perm = list(range(8))
    x_list = list(range(8))
    result = []
    for x in range(8):
        y = x
        if bits[0]: y = marriage_8(y)
        if bits[1]: y = descent_8(y)
        if bits[2]: y = matri_descent_8(y)
        result.append(y)
    group_8.add(tuple(result))

print(f"\n  Distinct group elements: {len(group_8)} (expected 8 = 2³)")
print(f"  Group is (Z₂)³: {len(group_8) == 8}")

# ============================================================
# Section 4: The Regularity Property
# ============================================================

print()
print("=" * 60)
print("REGULARITY: Every non-identity element is fixed-point-free")
print("=" * 60)
print()

print("4-section system:")
non_id_ops = [
    ("marriage", marriage_4),
    ("descent", descent_4),
    ("dreamtime", dreamtime_4)
]
for name, op in non_id_ops:
    fixed_pts = [i for i in range(4) if op(i) == i]
    print(f"  {name}: fixed points = {fixed_pts} (regular: {len(fixed_pts) == 0})")

print()
print("8-subsection system:")
for bits in itertools.product([0, 1], repeat=3):
    if bits == (0, 0, 0):
        continue
    label = f"m^{bits[0]}·d^{bits[1]}·e^{bits[2]}"
    fixed = []
    for x in range(8):
        y = x
        if bits[0]: y = marriage_8(y)
        if bits[1]: y = descent_8(y)
        if bits[2]: y = matri_descent_8(y)
        if y == x:
            fixed.append(x)
    print(f"  {label}: fixed points = {fixed}")

print()
print("All non-identity elements are fixed-point-free → regular action!")
print("This proves |sections| = |group| = 2^k")

# ============================================================
# Section 5: Marriage as Coset Structure
# ============================================================

print()
print("=" * 60)
print("MARRIAGE AS COSET RESTRICTION")
print("=" * 60)
print()

print("In the 4-section system:")
print("  Moiety subgroup H = {1, d} = ⟨descent⟩")
print("  Cosets of H:")
coset_1 = {0, descent_4(0)}  # {A, C}
coset_m = {marriage_4(0), marriage_4(descent_4(0))}  # {B, D}
print(f"    H = {{{SECTIONS_4[0]}, {SECTIONS_4[descent_4(0)]}}}")
print(f"    mH = {{{SECTIONS_4[marriage_4(0)]}, {SECTIONS_4[marriage_4(descent_4(0))]}}}")
print()
print("  Marriage rule: section x marries m(x), which is in coset m·H")
print("  → Marriage = moving to the opposite coset (cross-moiety marriage)")
for i in range(4):
    in_H = i in coset_1
    partner = marriage_4(i)
    partner_in_mH = partner in coset_m
    partner_in_H = partner in coset_1
    moiety = "H" if in_H else "mH"
    partner_moiety = "mH" if in_H else "H"
    print(f"    {SECTIONS_4[i]} (in {moiety}) marries {SECTIONS_4[partner]} (in {partner_moiety})")

# ============================================================
# Section 6: The Power-of-2 Theorem
# ============================================================

print()
print("=" * 60)
print("THE POWER-OF-2 THEOREM")
print("=" * 60)
print()
print("Theorem: If k commuting involutions act faithfully on a set S,")
print("then |S| must be a multiple of 2^k.")
print()
print("Proof sketch:")
print("  1. k commuting involutions generate an abelian group G")
print("  2. Every element of G has order ≤ 2 (since generators are involutions)")
print("  3. Therefore G ≅ (Z₂)^r for some r ≤ k")
print("  4. Faithfulness ⟹ r = k, so |G| = 2^k")
print("  5. |S| = |G| when the action is regular (free + transitive)")
print()
print("Aboriginal kinship systems satisfy this because:")
print(f"  4-section: k=2 generators, |S|=4=2², ✓")
print(f"  8-subsection: k=3 generators, |S|=8=2³, ✓")

if __name__ == "__main__":
    print()
    print("=" * 60)
    print("DREAMTIME ALGEBRA — DEMONSTRATION COMPLETE")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization of Aboriginal Kinship Systems as Group Theory.
Generates Cayley graph and kinship structure diagrams.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def draw_four_section_system():
    """Draw the 4-section kinship system as a graph."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    sections = ["A\n(Banaka)", "B\n(Burung)", "C\n(Karimera)", "D\n(Palyeri)"]
    # Position sections in a square
    pos = np.array([[0, 1], [1, 1], [0, 0], [1, 0]], dtype=float)

    colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12']

    # Panel 1: Marriage edges
    ax = axes[0]
    ax.set_title("Marriage Rule\n(m: involution, fixed-point-free)", fontsize=12, fontweight='bold')
    marriage = [(0, 1), (2, 3)]
    for i, (x, y) in enumerate(pos):
        circle = plt.Circle((x, y), 0.12, color=colors[i], ec='black', lw=2, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y, sections[i], ha='center', va='center', fontsize=8, fontweight='bold', zorder=6)
    for a, b in marriage:
        ax.annotate('', xy=pos[b], xytext=pos[a],
                    arrowprops=dict(arrowstyle='<->', color='red', lw=2.5))
        mid = (pos[a] + pos[b]) / 2
        ax.text(mid[0], mid[1] + 0.08, 'm', color='red', fontsize=11, ha='center', fontweight='bold')
    ax.set_xlim(-0.3, 1.3)
    ax.set_ylim(-0.3, 1.3)
    ax.set_aspect('equal')
    ax.axis('off')

    # Panel 2: Descent edges
    ax = axes[1]
    ax.set_title("Descent Rule\n(d: involution)", fontsize=12, fontweight='bold')
    descent = [(0, 2), (1, 3)]
    for i, (x, y) in enumerate(pos):
        circle = plt.Circle((x, y), 0.12, color=colors[i], ec='black', lw=2, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y, sections[i], ha='center', va='center', fontsize=8, fontweight='bold', zorder=6)
    for a, b in descent:
        ax.annotate('', xy=pos[b], xytext=pos[a],
                    arrowprops=dict(arrowstyle='<->', color='blue', lw=2.5))
        mid = (pos[a] + pos[b]) / 2
        ax.text(mid[0] - 0.08, mid[1], 'd', color='blue', fontsize=11, ha='center', fontweight='bold')
    ax.set_xlim(-0.3, 1.3)
    ax.set_ylim(-0.3, 1.3)
    ax.set_aspect('equal')
    ax.axis('off')

    # Panel 3: Dreamtime operator
    ax = axes[2]
    ax.set_title("Dreamtime Operator T = m·d\n(involution, fixed-point-free)", fontsize=12, fontweight='bold')
    dreamtime = [(0, 3), (1, 2)]
    for i, (x, y) in enumerate(pos):
        circle = plt.Circle((x, y), 0.12, color=colors[i], ec='black', lw=2, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y, sections[i], ha='center', va='center', fontsize=8, fontweight='bold', zorder=6)
    for a, b in dreamtime:
        ax.annotate('', xy=pos[b], xytext=pos[a],
                    arrowprops=dict(arrowstyle='<->', color='purple', lw=2.5))
        mid = (pos[a] + pos[b]) / 2
        ax.text(mid[0], mid[1], 'T', color='purple', fontsize=11, ha='center', fontweight='bold')
    ax.set_xlim(-0.3, 1.3)
    ax.set_ylim(-0.3, 1.3)
    ax.set_aspect('equal')
    ax.axis('off')

    plt.suptitle("The 4-Section (Kariera) Kinship System ≅ Z₂ × Z₂", fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('kinship_4section.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: kinship_4section.png")


def draw_cayley_table():
    """Draw the Cayley table of the kinship group."""
    fig, ax = plt.subplots(1, 1, figsize=(6, 6))

    labels = ['1', 'm', 'd', 'T']
    # Cayley table for Klein four-group
    table = [
        ['1', 'm', 'd', 'T'],
        ['m', '1', 'T', 'd'],
        ['d', 'T', '1', 'm'],
        ['T', 'd', 'm', '1'],
    ]

    color_map = {'1': '#ecf0f1', 'm': '#e74c3c', 'd': '#3498db', 'T': '#9b59b6'}

    for i in range(4):
        for j in range(4):
            val = table[i][j]
            rect = plt.Rectangle((j, 3-i), 1, 1, facecolor=color_map[val],
                                  edgecolor='black', lw=1.5)
            ax.add_patch(rect)
            ax.text(j + 0.5, 3.5 - i, val, ha='center', va='center',
                    fontsize=16, fontweight='bold')

    # Row/column headers
    for i, lab in enumerate(labels):
        ax.text(i + 0.5, 4.3, lab, ha='center', va='center', fontsize=14, fontweight='bold')
        ax.text(-0.3, 3.5 - i, lab, ha='center', va='center', fontsize=14, fontweight='bold')

    ax.text(2, 5, "Cayley Table: Z₂ × Z₂ (Klein Four-Group)", ha='center', fontsize=14, fontweight='bold')
    ax.text(-0.3, 4.3, '×', ha='center', va='center', fontsize=14, fontweight='bold')

    ax.set_xlim(-0.8, 4.5)
    ax.set_ylim(-0.5, 5.3)
    ax.set_aspect('equal')
    ax.axis('off')

    plt.savefig('kinship_cayley.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: kinship_cayley.png")


def draw_binary_encoding():
    """Draw the binary encoding of sections showing Hamming distances."""
    fig, ax = plt.subplots(1, 1, figsize=(8, 8))

    # Binary hypercube for 4 sections
    sections = {
        (0, 0): "A (Banaka)",
        (1, 0): "B (Burung)",
        (0, 1): "C (Karimera)",
        (1, 1): "D (Palyeri)"
    }

    pos_map = {(0,0): (0, 0), (1,0): (2, 0), (0,1): (0, 2), (1,1): (2, 2)}
    colors = {(0,0): '#e74c3c', (1,0): '#3498db', (0,1): '#2ecc71', (1,1): '#f39c12'}

    # Draw Hamming distance 1 edges
    edges = [((0,0),(1,0)), ((0,0),(0,1)), ((1,0),(1,1)), ((0,1),(1,1))]
    for (a, b) in edges:
        pa, pb = pos_map[a], pos_map[b]
        # Determine if this is a marriage edge or descent edge
        if a[0] != b[0] and a[1] == b[1]:  # bit 0 differs = marriage
            color = 'red'
            label = 'marriage\n(Hamming dist=1)'
        else:  # bit 1 differs = descent
            color = 'blue'
            label = 'descent\n(Hamming dist=1)'
        ax.plot([pa[0], pb[0]], [pa[1], pb[1]], color=color, lw=2.5, zorder=1)

    # Draw diagonal (Dreamtime, Hamming dist 2)
    ax.plot([0, 2], [0, 2], color='purple', lw=2, ls='--', zorder=1)
    ax.plot([2, 0], [0, 2], color='purple', lw=2, ls='--', zorder=1)

    # Draw nodes
    for bits, name in sections.items():
        px, py = pos_map[bits]
        circle = plt.Circle((px, py), 0.25, color=colors[bits], ec='black', lw=2, zorder=5)
        ax.add_patch(circle)
        ax.text(px, py, f"({bits[0]},{bits[1]})", ha='center', va='center',
                fontsize=10, fontweight='bold', zorder=6)
        ax.text(px, py - 0.45, name, ha='center', va='center', fontsize=9, zorder=6)

    # Legend
    ax.plot([], [], color='red', lw=2.5, label='Marriage (flip bit 0, Hamming=1)')
    ax.plot([], [], color='blue', lw=2.5, label='Descent (flip bit 1, Hamming=1)')
    ax.plot([], [], color='purple', lw=2, ls='--', label='Dreamtime (flip both, Hamming=2)')
    ax.legend(loc='upper center', fontsize=10, framealpha=0.9)

    ax.set_title("Binary Encoding: Kinship as Error-Correcting Code\n"
                 "Each edge = 1-bit flip = Hamming distance 1",
                 fontsize=13, fontweight='bold')
    ax.set_xlim(-0.8, 2.8)
    ax.set_ylim(-0.8, 3.0)
    ax.set_aspect('equal')
    ax.axis('off')

    plt.savefig('kinship_binary.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: kinship_binary.png")


if __name__ == "__main__":
    draw_four_section_system()
    draw_cayley_table()
    draw_binary_encoding()
    print("\nAll visualizations generated.")
