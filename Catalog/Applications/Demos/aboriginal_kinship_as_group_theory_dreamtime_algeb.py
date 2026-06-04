#!/usr/bin/env python3
"""
Aboriginal Kinship Systems: Numerical Demonstrations

Demonstrates the group-theoretic structure of Australian Aboriginal
kinship systems (Kariera 4-section, Aranda 8-subsection).
"""

from itertools import product


def z2_add(a: int, b: int) -> int:
    """Addition in Z/2Z."""
    return (a + b) % 2


def section_add(s: tuple[int, ...], t: tuple[int, ...]) -> tuple[int, ...]:
    """Componentwise addition in (Z/2Z)^k."""
    return tuple(z2_add(a, b) for a, b in zip(s, t))


# ============================================================
# Demo 1: Kariera 4-Section System
# ============================================================
print("=" * 60)
print("DEMO 1: Kariera 4-Section System (Z2 x Z2)")
print("=" * 60)

KARIERA_NAMES = {
    (0, 0): "Banaka",
    (1, 0): "Burung",
    (0, 1): "Karimera",
    (1, 1): "Palyeri",
}

marriage = (1, 0)
descent = (0, 1)

print("\nSection table:")
for s, name in KARIERA_NAMES.items():
    partner = section_add(s, marriage)
    child = section_add(s, descent)
    print(f"  {name:10s} {s} -> marriage partner: {KARIERA_NAMES[partner]:10s}, "
          f"child section: {KARIERA_NAMES[child]}")

# Verify group axioms
print("\nGroup axioms verification:")
sections = list(KARIERA_NAMES.keys())
identity = (0, 0)

# Closure
closed = all(section_add(a, b) in sections for a in sections for b in sections)
print(f"  Closure: {closed}")

# Identity
has_id = all(section_add(s, identity) == s for s in sections)
print(f"  Identity (0,0): {has_id}")

# Inverses (every element is its own inverse)
self_inverse = all(section_add(s, s) == identity for s in sections)
print(f"  Every element is self-inverse: {self_inverse}")

# Commutativity
commutative = all(
    section_add(a, b) == section_add(b, a)
    for a in sections for b in sections
)
print(f"  Commutative: {commutative}")

# Marriage involution
print(f"\nMarriage involution: m + m = {section_add(marriage, marriage)} = identity ✓")

# Exogamy
print(f"Marriage element (1,0) ≠ identity (0,0): {marriage != identity} ✓")

# ============================================================
# Demo 2: Aranda 8-Subsection System
# ============================================================
print("\n" + "=" * 60)
print("DEMO 2: Aranda 8-Subsection System (Z2 x Z2 x Z2)")
print("=" * 60)

ARANDA_NAMES = {
    (0, 0, 0): "A1", (1, 0, 0): "A2",
    (0, 1, 0): "B1", (1, 1, 0): "B2",
    (0, 0, 1): "C1", (1, 0, 1): "C2",
    (0, 1, 1): "D1", (1, 1, 1): "D2",
}

m3 = (1, 0, 0)  # marriage
d3 = (0, 1, 0)  # descent

print("\nSubsection table:")
for s in sorted(ARANDA_NAMES.keys()):
    name = ARANDA_NAMES[s]
    partner = section_add(s, m3)
    child = section_add(s, d3)
    print(f"  {name:3s} {s} -> marriage: {ARANDA_NAMES[partner]:3s}, "
          f"child: {ARANDA_NAMES[child]}")

# All order 2
subsections = list(ARANDA_NAMES.keys())
all_order_2 = all(section_add(s, s) == (0, 0, 0) for s in subsections)
print(f"\nAll elements have order dividing 2: {all_order_2}")
print(f"Number of subsections: {len(subsections)} = 2^3")

# ============================================================
# Demo 3: Coset Structure
# ============================================================
print("\n" + "=" * 60)
print("DEMO 3: Marriage Coset Structure")
print("=" * 60)

marriage_subgroup = [(0, 0), marriage]
print(f"\nMarriage subgroup: {marriage_subgroup}")

print("\nCoset decomposition of Kariera system:")
visited = set()
for s in sections:
    coset = frozenset(section_add(s, m) for m in marriage_subgroup)
    if coset not in visited:
        visited.add(coset)
        names = [KARIERA_NAMES[x] for x in sorted(coset)]
        print(f"  Coset: {names}")

print("\nMarriage partners are always in the SAME coset:")
for s in sections:
    p = section_add(s, marriage)
    in_same_coset = frozenset([s, p]) in visited
    print(f"  {KARIERA_NAMES[s]} <-> {KARIERA_NAMES[p]}: same coset = {in_same_coset}")

# ============================================================
# Demo 4: Hamming Distance as Kinship Distance
# ============================================================
print("\n" + "=" * 60)
print("DEMO 4: Hamming Distance = Kinship Distance")
print("=" * 60)


def hamming_weight(v: tuple[int, ...]) -> int:
    return sum(1 for x in v if x != 0)


def hamming_distance(a: tuple[int, ...], b: tuple[int, ...]) -> int:
    return hamming_weight(section_add(a, b))


print("\nKariera distance matrix:")
print(f"{'':12s}", end="")
for s in sections:
    print(f"{KARIERA_NAMES[s]:12s}", end="")
print()
for s in sections:
    print(f"{KARIERA_NAMES[s]:12s}", end="")
    for t in sections:
        d = hamming_distance(s, t)
        print(f"{d:12d}", end="")
    print()

print("\nInterpretation:")
print("  Distance 0: Same section (identity)")
print("  Distance 1: Marriage partner OR one-generation descent")
print("  Distance 2: Marriage partner's child (maximum kinship distance)")

# ============================================================
# Demo 5: Embedding Kariera -> Aranda
# ============================================================
print("\n" + "=" * 60)
print("DEMO 5: Kariera embeds in Aranda")
print("=" * 60)

print("\nEmbedding (a,b) -> (a,b,0):")
for s in sections:
    embedded = (s[0], s[1], 0)
    print(f"  {KARIERA_NAMES[s]:10s} {s} -> {ARANDA_NAMES[embedded]:3s} {embedded}")

print("\nProjection (a,b,c) -> (a,b):")
for s in sorted(ARANDA_NAMES.keys()):
    projected = (s[0], s[1])
    print(f"  {ARANDA_NAMES[s]:3s} {s} -> {KARIERA_NAMES[projected]:10s} {projected}")

print("\nKernel of projection: elements mapping to (0,0)")
kernel = [s for s in subsections if (s[0], s[1]) == (0, 0)]
for k in kernel:
    print(f"  {ARANDA_NAMES[k]} {k}")
print(f"Kernel size: {len(kernel)} = |Z2|")

# ============================================================
# Demo 6: Moiety Structure
# ============================================================
print("\n" + "=" * 60)
print("DEMO 6: Moiety Structure")
print("=" * 60)

print("\nKariera moieties (subgroups of index 2):")
# Find all subgroups of order 2
for g in sections:
    if g != identity:
        subgroup = {identity, g}
        # Check it's a subgroup (it is, since g+g=0)
        cosets = []
        remaining = set(map(tuple, sections))
        while remaining:
            rep = min(remaining)
            coset = frozenset(section_add(rep, s) for s in subgroup)
            cosets.append(sorted(coset))
            remaining -= coset
        if len(cosets) == 2:
            names = [[KARIERA_NAMES[x] for x in c] for c in cosets]
            print(f"  Generator {g}: {names[0]} | {names[1]}")

print("\nTotal: 3 moieties (matching theorem kariera_three_moieties... "
      "well, we proved index-2 subgroups exist)")

print("\n" + "=" * 60)
print("All demonstrations complete.")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Kinship Distance Heatmaps

Shows Hamming distance matrices for Kariera and Aranda systems.
"""

import matplotlib.pyplot as plt
import numpy as np


def hamming_distance(a: tuple, b: tuple) -> int:
    return sum(1 for x, y in zip(a, b) if (x + y) % 2 != 0)


def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Kariera
    kariera_codes = [(0, 0), (1, 0), (0, 1), (1, 1)]
    kariera_names = ["Banaka", "Burung", "Karimera", "Palyeri"]

    dist_k = np.array([[hamming_distance(a, b) for b in kariera_codes]
                       for a in kariera_codes])

    ax = axes[0]
    im = ax.imshow(dist_k, cmap='YlOrRd', vmin=0, vmax=3)
    ax.set_xticks(range(4))
    ax.set_yticks(range(4))
    ax.set_xticklabels(kariera_names, rotation=45, ha='right', fontsize=9)
    ax.set_yticklabels(kariera_names, fontsize=9)
    ax.set_title("Kariera Kinship Distance\n(Hamming Distance in ℤ₂²)",
                 fontsize=12, fontweight='bold')
    for i in range(4):
        for j in range(4):
            ax.text(j, i, str(dist_k[i, j]), ha='center', va='center',
                    fontsize=14, fontweight='bold',
                    color='white' if dist_k[i, j] >= 2 else 'black')

    # Aranda
    aranda_codes = [(i, j, k) for i in range(2) for j in range(2) for k in range(2)]
    aranda_labels = [f"{'ABCD'[2*c[1]+c[2]]}{c[0]+1}" for c in aranda_codes]

    dist_a = np.array([[hamming_distance(a, b) for b in aranda_codes]
                       for a in aranda_codes])

    ax = axes[1]
    im2 = ax.imshow(dist_a, cmap='YlOrRd', vmin=0, vmax=3)
    ax.set_xticks(range(8))
    ax.set_yticks(range(8))
    ax.set_xticklabels(aranda_labels, rotation=45, ha='right', fontsize=8)
    ax.set_yticklabels(aranda_labels, fontsize=8)
    ax.set_title("Aranda Kinship Distance\n(Hamming Distance in ℤ₂³)",
                 fontsize=12, fontweight='bold')
    for i in range(8):
        for j in range(8):
            ax.text(j, i, str(dist_a[i, j]), ha='center', va='center',
                    fontsize=10, fontweight='bold',
                    color='white' if dist_a[i, j] >= 2 else 'black')

    fig.colorbar(im2, ax=axes, label='Kinship Distance', shrink=0.8)
    plt.tight_layout()
    plt.savefig('hamming_distances.png', dpi=150, bbox_inches='tight')
    plt.show()
    print("Saved: hamming_distances.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Kariera Kinship System as a Graph

Shows the 4-section system with marriage edges (red) and descent edges (blue).
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # --- Kariera System ---
    ax = axes[0]
    ax.set_title("Kariera 4-Section System (ℤ₂ × ℤ₂)", fontsize=14, fontweight='bold')

    sections = {
        (0, 0): ("Banaka", 0.0, 1.0),
        (1, 0): ("Burung", 1.0, 1.0),
        (0, 1): ("Karimera", 0.0, 0.0),
        (1, 1): ("Palyeri", 1.0, 0.0),
    }

    marriage = (1, 0)
    descent = (0, 1)

    for code, (name, x, y) in sections.items():
        circle = plt.Circle((x, y), 0.12, color='#2196F3', alpha=0.8)
        ax.add_patch(circle)
        ax.text(x, y, f"{name}\n{code}", ha='center', va='center',
                fontsize=8, fontweight='bold', color='white')

    for code, (name, x, y) in sections.items():
        mp = tuple((a + b) % 2 for a, b in zip(code, marriage))
        mx, my = sections[mp][1], sections[mp][2]
        ax.annotate('', xy=(mx - 0.13 * np.sign(mx - x), my),
                    xytext=(x + 0.13 * np.sign(mx - x), y),
                    arrowprops=dict(arrowstyle='->', color='red', lw=2))

        dp = tuple((a + b) % 2 for a, b in zip(code, descent))
        dx, dy = sections[dp][1], sections[dp][2]
        offset = 0.05 if x == dx else 0
        ax.annotate('', xy=(dx + offset, dy + 0.13 * np.sign(dy - y)),
                    xytext=(x + offset, y - 0.13 * np.sign(dy - y)),
                    arrowprops=dict(arrowstyle='->', color='blue', lw=2,
                                    linestyle='dashed'))

    marriage_patch = mpatches.Patch(color='red', label='Marriage (+1,0)')
    descent_patch = mpatches.Patch(color='blue', label='Descent (+0,1)')
    ax.legend(handles=[marriage_patch, descent_patch], loc='upper right', fontsize=9)
    ax.set_xlim(-0.3, 1.3)
    ax.set_ylim(-0.3, 1.3)
    ax.set_aspect('equal')
    ax.axis('off')

    # --- Cayley Table ---
    ax = axes[1]
    ax.set_title("Cayley Table (Addition in ℤ₂ × ℤ₂)", fontsize=14, fontweight='bold')

    labels = ["(0,0)", "(1,0)", "(0,1)", "(1,1)"]
    names = ["Banaka", "Burung", "Karimera", "Palyeri"]
    codes = [(0, 0), (1, 0), (0, 1), (1, 1)]

    table_data = []
    for i, a in enumerate(codes):
        row = []
        for j, b in enumerate(codes):
            result = tuple((x + y) % 2 for x, y in zip(a, b))
            idx = codes.index(result)
            row.append(names[idx])
        table_data.append(row)

    colors = ['#E3F2FD', '#BBDEFB', '#90CAF9', '#64B5F6']
    cell_colors = []
    for row in table_data:
        cell_colors.append([colors[names.index(cell)] for cell in row])

    table = ax.table(cellText=table_data,
                     rowLabels=names,
                     colLabels=names,
                     cellColours=cell_colors,
                     loc='center',
                     cellLoc='center')
    table.auto_set_font_size(False)
    table.set_fontsize(9)
    table.scale(1.0, 1.5)
    ax.axis('off')

    plt.tight_layout()
    plt.savefig('kinship_graph.png', dpi=150, bbox_inches='tight')
    plt.show()
    print("Saved: kinship_graph.png")


if __name__ == "__main__":
    main()
