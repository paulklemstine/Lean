#!/usr/bin/env python3
"""
Aboriginal Kinship as Group Theory: Numerical Demonstrations

Demonstrates the group-theoretic structure of Australian Aboriginal
kinship systems (section and subsection systems).
"""

from itertools import product
from typing import Tuple, List, Dict


# -- Z2 x Z2 (Kariera 4-Section System) --

def z2_add(a: Tuple[int, ...], b: Tuple[int, ...]) -> Tuple[int, ...]:
    """Addition in Z_2^n."""
    return tuple((x + y) % 2 for x, y in zip(a, b))


def marriage_partner(section: Tuple[int, ...], m_offset: Tuple[int, ...]) -> Tuple[int, ...]:
    """Compute the marriage partner section."""
    return z2_add(section, m_offset)


def child_section(mother: Tuple[int, ...], d_offset: Tuple[int, ...]) -> Tuple[int, ...]:
    """Compute the child's section from the mother's section."""
    return z2_add(mother, d_offset)


def nth_descendant(section: Tuple[int, ...], d_offset: Tuple[int, ...], n: int) -> Tuple[int, ...]:
    """Compute the n-th generation descendant's section."""
    result = section
    for _ in range(n):
        result = z2_add(result, d_offset)
    return result


# Section names for the Kariera system
KARIERA_NAMES = {
    (0, 0): "Banaka",
    (1, 0): "Karimera",
    (0, 1): "Burung",
    (1, 1): "Palyeri",
}

KARIERA_MARRIAGE = (1, 0)
KARIERA_DESCENT = (0, 1)


def demo_kariera():
    """Demonstrate the Kariera 4-section system."""
    print("=" * 60)
    print("KARIERA 4-SECTION SYSTEM (Z₂ × Z₂)")
    print("=" * 60)
    print()

    m = KARIERA_MARRIAGE
    d = KARIERA_DESCENT

    print(f"Marriage offset: {m}")
    print(f"Descent offset:  {d}")
    print()

    print("Section assignments:")
    for s, name in KARIERA_NAMES.items():
        partner = marriage_partner(s, m)
        child = child_section(s, d)
        print(f"  {name} {s}:")
        print(f"    Marries: {KARIERA_NAMES[partner]} {partner}")
        print(f"    Child:   {KARIERA_NAMES[child]} {child}")
    print()

    # Verify marriage involution
    print("Marriage involution verification:")
    for s in KARIERA_NAMES:
        double = marriage_partner(marriage_partner(s, m), m)
        print(f"  partner(partner({s})) = {double} {'✓' if double == s else '✗'}")
    print()

    # Verify descent periodicity
    print("Descent periodicity (grandmother = granddaughter):")
    for s in KARIERA_NAMES:
        gd = nth_descendant(s, d, 2)
        print(f"  2nd descendant of {s} = {gd} {'✓' if gd == s else '✗'}")
    print()

    # Verify commutativity
    print("Marriage-descent commutativity:")
    for s in KARIERA_NAMES:
        path1 = child_section(marriage_partner(s, m), d)  # child of spouse
        path2 = marriage_partner(child_section(s, d), m)  # spouse of child
        print(f"  child(spouse({s})) = {path1}, spouse(child({s})) = {path2} "
              f"{'✓' if path1 == path2 else '✗'}")
    print()

    # Moiety structure
    print("Moiety structure:")
    moiety_subgroup = {(0, 0), d}
    coset = {z2_add(x, m) for x in moiety_subgroup}
    print(f"  Moiety 1 (descent subgroup): {sorted(moiety_subgroup)}")
    print(f"  Moiety 2 (marriage coset):   {sorted(coset)}")
    print(f"  Marriage crosses moieties: {m not in moiety_subgroup}")
    print()


# -- Z2 x Z2 x Z2 (Aranda 8-Subsection System) --

ARANDA_NAMES = {
    (0, 0, 0): "Panaka",
    (1, 0, 0): "Purungu",
    (0, 1, 0): "Milangka",
    (1, 1, 0): "Karimarra",
    (0, 0, 1): "Tjakamarra",
    (1, 0, 1): "Tjapanangka",
    (0, 1, 1): "Tjapaltjarri",
    (1, 1, 1): "Tjampitjinpa",
}

ARANDA_MARRIAGE = (1, 0, 0)
ARANDA_DESCENT = (0, 1, 1)


def demo_aranda():
    """Demonstrate the Aranda 8-subsection system."""
    print("=" * 60)
    print("ARANDA 8-SUBSECTION SYSTEM (Z₂ × Z₂ × Z₂)")
    print("=" * 60)
    print()

    m = ARANDA_MARRIAGE
    d = ARANDA_DESCENT

    print(f"Marriage offset: {m}")
    print(f"Descent offset:  {d}")
    print()

    print("Subsection assignments:")
    for s, name in ARANDA_NAMES.items():
        partner = marriage_partner(s, m)
        child = child_section(s, d)
        print(f"  {name:15s} {s}:")
        print(f"    Marries: {ARANDA_NAMES[partner]:15s} {partner}")
        print(f"    Child:   {ARANDA_NAMES[child]:15s} {child}")
    print()

    # Verify closure of {m, d} — should generate 4 elements, not 8
    closure = {(0, 0, 0)}
    new = {m, d}
    while new - closure:
        closure |= new
        next_new = set()
        for a in closure:
            for b in closure:
                next_new.add(z2_add(a, b))
        new = next_new
    print(f"Closure of {{m, d}}: {len(closure)} elements (not 8!)")
    print(f"  Elements: {sorted(closure)}")
    print(f"  This confirms: two generators cannot span Z₂³")
    print()


def demo_enumeration():
    """Enumerate all valid kinship systems on Z₂ × Z₂."""
    print("=" * 60)
    print("ENUMERATION OF KINSHIP SYSTEMS ON Z₂ × Z₂")
    print("=" * 60)
    print()

    elements = [(a, b) for a in range(2) for b in range(2)]
    zero = (0, 0)
    count = 0

    for m in elements:
        if m == zero:
            continue
        if z2_add(m, m) != zero:
            continue
        for d in elements:
            if d == zero or d == m:
                continue
            count += 1
            closure = {zero}
            new = {m, d}
            while new - closure:
                closure |= new
                next_new = set()
                for a in closure:
                    for b in closure:
                        next_new.add(z2_add(a, b))
                new = next_new
            complete = len(closure) == 4
            print(f"  System {count}: m={m}, d={d}, "
                  f"complete={'✓' if complete else '✗'}, "
                  f"closure size={len(closure)}")

    print(f"\nTotal valid systems: {count}")
    print()


def demo_odd_obstruction():
    """Demonstrate that odd-order groups cannot support kinship systems."""
    print("=" * 60)
    print("ODD-ORDER OBSTRUCTION")
    print("=" * 60)
    print()

    for n in [3, 5, 7]:
        found = False
        for m in range(n):
            if (2 * m) % n == 0 and m != 0:
                found = True
                break
        print(f"  Z_{n}: nonzero element of order 2 exists? {found}")
        if not found:
            print(f"    → No kinship system possible on Z_{n}")
    print()

    # Z6 = Z2 x Z3 has an element of order 2
    print("  Z₆: element 3 has order 2 (3+3=6≡0 mod 6)")
    print("    → Kinship system IS possible (e.g., m=3, d=2)")
    print()


def demo_generational_tracking():
    """Track sections through multiple generations."""
    print("=" * 60)
    print("GENERATIONAL TRACKING (Kariera)")
    print("=" * 60)
    print()

    m = KARIERA_MARRIAGE
    d = KARIERA_DESCENT
    start = (0, 0)

    print(f"Starting section: {KARIERA_NAMES[start]} {start}")
    print()

    current = start
    for gen in range(5):
        partner = marriage_partner(current, m)
        child = child_section(current, d)
        patri_child = child_section(partner, d)
        print(f"  Gen {gen}: {KARIERA_NAMES[current]:10s} "
              f"marries {KARIERA_NAMES[partner]:10s} "
              f"→ matri-child: {KARIERA_NAMES[child]:10s} "
              f"  patri-child: {KARIERA_NAMES[patri_child]:10s}")
        current = child

    print()
    print("Note: Section cycles with period 2 (grandmother = granddaughter)")
    print()


if __name__ == "__main__":
    demo_kariera()
    demo_aranda()
    demo_enumeration()
    demo_odd_obstruction()
    demo_generational_tracking()


#!/usr/bin/env python3
"""
Visualization: Aboriginal Kinship System as Group Structure

Produces a diagram showing the Kariera 4-section system with
marriage and descent connections on Z_2 x Z_2.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def z2_add(a, b):
    return tuple((x + y) % 2 for x, y in zip(a, b))


def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # --- Kariera 4-Section System ---
    ax = axes[0]
    ax.set_title("Kariera 4-Section System\n(Z₂ × Z₂)", fontsize=14, fontweight='bold')

    sections = [(0,0), (1,0), (0,1), (1,1)]
    names = {(0,0): "Banaka", (1,0): "Karimera", (0,1): "Burung", (1,1): "Palyeri"}
    colors = {(0,0): "#2196F3", (1,0): "#F44336", (0,1): "#4CAF50", (1,1): "#FF9800"}
    moiety_colors = {(0,0): "#E3F2FD", (1,0): "#FFEBEE", (0,1): "#E8F5E9", (1,1): "#FFF3E0"}

    # Position sections in a square
    positions = {(0,0): (0, 1), (1,0): (1, 1), (0,1): (0, 0), (1,1): (1, 0)}

    m_offset = (1, 0)
    d_offset = (0, 1)

    # Draw moiety backgrounds
    ax.fill([-.3, .5, .5, -.3], [-.3, -.3, 1.3, 1.3], alpha=0.1, color='blue', label='Moiety 1')
    ax.fill([.5, 1.3, 1.3, .5], [-.3, -.3, 1.3, 1.3], alpha=0.1, color='red', label='Moiety 2')

    # Draw marriage arrows (red, horizontal)
    for s in sections:
        partner = z2_add(s, m_offset)
        x1, y1 = positions[s]
        x2, y2 = positions[partner]
        if x1 < x2:
            ax.annotate('', xy=(x2-0.12, y2), xytext=(x1+0.12, y1),
                       arrowprops=dict(arrowstyle='<->', color='red', lw=2))

    # Draw descent arrows (green, vertical)
    for s in sections:
        child = z2_add(s, d_offset)
        x1, y1 = positions[s]
        x2, y2 = positions[child]
        if y1 > y2:
            ax.annotate('', xy=(x2, y2+0.12), xytext=(x1, y1-0.12),
                       arrowprops=dict(arrowstyle='->', color='green', lw=2, linestyle='--'))

    # Draw section circles
    for s in sections:
        x, y = positions[s]
        circle = plt.Circle((x, y), 0.1, color=colors[s], zorder=5)
        ax.add_patch(circle)
        ax.text(x, y, str(s), ha='center', va='center', fontsize=8, color='white',
                fontweight='bold', zorder=6)
        ax.text(x, y-0.18, names[s], ha='center', va='top', fontsize=9)

    # Legend
    marriage_line = mpatches.Patch(color='red', label='Marriage (add (1,0))')
    descent_line = mpatches.Patch(color='green', label='Descent (add (0,1))')
    ax.legend(handles=[marriage_line, descent_line], loc='upper right', fontsize=8)

    ax.set_xlim(-0.4, 1.4)
    ax.set_ylim(-0.4, 1.4)
    ax.set_aspect('equal')
    ax.axis('off')

    # --- Aranda 8-Subsection System ---
    ax2 = axes[1]
    ax2.set_title("Aranda 8-Subsection System\n(Z₂ × Z₂ × Z₂)", fontsize=14, fontweight='bold')

    subsections_3d = [(a,b,c) for a in range(2) for b in range(2) for c in range(2)]
    names_8 = {
        (0,0,0): "Pan", (1,0,0): "Pur", (0,1,0): "Mil", (1,1,0): "Kar",
        (0,0,1): "Tja", (1,0,1): "Tjp", (0,1,1): "Tjl", (1,1,1): "Tjm",
    }

    # Position as cube projection
    pos_3d = {}
    for (a, b, c) in subsections_3d:
        x = a * 1.2 + c * 0.4
        y = b * 1.2 + c * 0.4
        pos_3d[(a,b,c)] = (x, y)

    m3 = (1, 0, 0)
    d3 = (0, 1, 1)

    # Draw marriage connections (red)
    for s in subsections_3d:
        partner = z2_add(s, m3)
        x1, y1 = pos_3d[s]
        x2, y2 = pos_3d[partner]
        if s < partner:
            ax2.plot([x1, x2], [y1, y2], color='red', lw=1.5, alpha=0.6, zorder=1)

    # Draw descent connections (green, dashed)
    for s in subsections_3d:
        child = z2_add(s, d3)
        x1, y1 = pos_3d[s]
        x2, y2 = pos_3d[child]
        if s < child:
            ax2.plot([x1, x2], [y1, y2], color='green', lw=1.5, alpha=0.6,
                    linestyle='--', zorder=1)

    # Draw subsection nodes
    for s in subsections_3d:
        x, y = pos_3d[s]
        color = '#2196F3' if s[0] == 0 else '#F44336'
        circle = plt.Circle((x, y), 0.08, color=color, zorder=5)
        ax2.add_patch(circle)
        ax2.text(x, y, names_8[s], ha='center', va='center', fontsize=6,
                color='white', fontweight='bold', zorder=6)

    ax2.set_xlim(-0.3, 2.0)
    ax2.set_ylim(-0.3, 2.0)
    ax2.set_aspect('equal')
    ax2.axis('off')

    plt.tight_layout()
    plt.savefig('kinship_groups.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: kinship_groups.png")


if __name__ == "__main__":
    main()
