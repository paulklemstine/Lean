#!/usr/bin/env python3
"""
Dreamtime Algebra: Aboriginal Kinship Systems as Group Theory
=============================================================
Demonstrates the group-theoretic structure of Australian Aboriginal
kinship systems (section and subsection systems).
"""

from itertools import product
from typing import Tuple

# Type aliases
Section = Tuple[int, ...]


def add_mod2(a: Section, b: Section) -> Section:
    """Add two elements in (Z/2Z)^n."""
    return tuple((x + y) % 2 for x, y in zip(a, b))


def neg_mod2(a: Section) -> Section:
    """Negate in (Z/2Z)^n (identity since -x = x in Z/2Z)."""
    return a  # Every element is its own inverse


def all_elements(n: int) -> list[Section]:
    """All elements of (Z/2Z)^n."""
    return list(product(range(2), repeat=n))


def kinship_spectrum(n: int) -> list[Section]:
    """All valid marriage generators in (Z/2Z)^n."""
    zero = tuple(0 for _ in range(n))
    return [g for g in all_elements(n) if g != zero]
    # In (Z/2Z)^n, every nonzero element has order 2


def marriage_map(g: Section, marry_gen: Section) -> Section:
    """Marriage map: g -> g + σ."""
    return add_mod2(g, marry_gen)


def descent_map(g: Section, descent_gen: Section) -> Section:
    """Descent map: g -> g + δ."""
    return add_mod2(g, descent_gen)


def dreamtime_op(g: Section, marry_gen: Section, descent_gen: Section) -> Section:
    """Dreamtime operator: g -> g + σ + δ."""
    return add_mod2(add_mod2(g, marry_gen), descent_gen)


# ===== KARIERA 4-SECTION SYSTEM =====
print("=" * 60)
print("THE KARIERA 4-SECTION SYSTEM (Z₂ × Z₂)")
print("=" * 60)

KARIERA_NAMES = {
    (0, 0): "Karimera",
    (1, 0): "Burung",
    (0, 1): "Palyeri",
    (1, 1): "Banaka",
}

MARRY_GEN = (1, 0)  # Marriage generator
DESCENT_GEN = (0, 1)  # Descent generator
DREAMTIME_GEN = add_mod2(MARRY_GEN, DESCENT_GEN)  # = (1, 1)

print(f"\nMarriage generator σ = {MARRY_GEN}")
print(f"Descent generator  δ = {DESCENT_GEN}")
print(f"Dreamtime element  τ = σ+δ = {DREAMTIME_GEN}")

print("\n--- Marriage Rules ---")
for g in all_elements(2):
    partner = marriage_map(g, MARRY_GEN)
    print(f"  {KARIERA_NAMES[g]:10s} marries {KARIERA_NAMES[partner]}")

print("\n--- Descent Rules (Father → Child) ---")
for g in all_elements(2):
    child = descent_map(g, DESCENT_GEN)
    print(f"  {KARIERA_NAMES[g]:10s} → child is {KARIERA_NAMES[child]}")

print("\n--- Alternating Generations ---")
for g in all_elements(2):
    child = descent_map(g, DESCENT_GEN)
    grandchild = descent_map(child, DESCENT_GEN)
    assert grandchild == g, "Alternating generations violated!"
    print(f"  {KARIERA_NAMES[g]:10s} → {KARIERA_NAMES[child]:10s} → {KARIERA_NAMES[grandchild]:10s} (back to start)")

print("\n--- Moieties ---")
seen = set()
for g in all_elements(2):
    if g not in seen:
        partner = marriage_map(g, MARRY_GEN)
        seen.add(g)
        seen.add(partner)
        print(f"  Moiety: {{{KARIERA_NAMES[g]}, {KARIERA_NAMES[partner]}}}")

print("\n--- Kinship Spectrum ---")
spectrum = kinship_spectrum(2)
print(f"  |Spec_K(Z₂²)| = {len(spectrum)} = 2² - 1")
for s in spectrum:
    print(f"    {s} → marriage rule: ", end="")
    pairs = []
    seen = set()
    for g in all_elements(2):
        if g not in seen:
            p = marriage_map(g, s)
            pairs.append(f"{KARIERA_NAMES[g]}↔{KARIERA_NAMES[p]}")
            seen.add(g)
            seen.add(p)
    print(", ".join(pairs))

# ===== ARANDA 8-SUBSECTION SYSTEM =====
print("\n" + "=" * 60)
print("THE ARANDA 8-SUBSECTION SYSTEM (Z₂ × Z₂ × Z₂)")
print("=" * 60)

ARANDA_MARRY = (1, 0, 0)
ARANDA_DESCENT = (0, 1, 0)
ARANDA_GEN3 = (0, 0, 1)  # Generational moiety

print(f"\nMarriage generator    σ = {ARANDA_MARRY}")
print(f"Descent generator     δ = {ARANDA_DESCENT}")
print(f"Generational moiety   γ = {ARANDA_GEN3}")
print(f"Number of subsections = {len(all_elements(3))}")

print("\n--- Kinship Spectrum ---")
aranda_spectrum = kinship_spectrum(3)
print(f"  |Spec_K(Z₂³)| = {len(aranda_spectrum)} = 2³ - 1")

print("\n--- Marriage Pairs ---")
seen = set()
for g in all_elements(3):
    if g not in seen:
        p = marriage_map(g, ARANDA_MARRY)
        seen.add(g)
        seen.add(p)
        print(f"  {g} ↔ {p}")

print("\n--- Dreamtime Algebra Count ---")
n_pairs = 0
for m in aranda_spectrum:
    for d in aranda_spectrum:
        if m != d:
            n_pairs += 1
print(f"  Ordered pairs of generators: {n_pairs}")
print(f"  = (2³-1)(2³-2) = 7 × 6 = {7*6}")

# ===== IMPOSSIBILITY RESULTS =====
print("\n" + "=" * 60)
print("IMPOSSIBILITY RESULTS")
print("=" * 60)

for n in [2, 3, 4, 5, 6, 7]:
    elements_order2 = []
    for g in range(n):
        if (2 * g) % n == 0 and g != 0:
            elements_order2.append(g)
    can_build = len(elements_order2) >= 2
    status = "✓ CAN build" if can_build else "✗ CANNOT build"
    print(f"  Z_{n}: elements of order 2 = {elements_order2} → {status} Dreamtime algebra")

# ===== TRIALITY =====
print("\n" + "=" * 60)
print("TRIALITY: THREE KINSHIP SYSTEMS ON Z₂ × Z₂")
print("=" * 60)

systems = [
    ("Original", MARRY_GEN, DESCENT_GEN),
    ("Dual", DESCENT_GEN, MARRY_GEN),
    ("Twist", DREAMTIME_GEN, DESCENT_GEN),
]

for name, m, d in systems:
    dt = add_mod2(m, d)
    print(f"\n  {name}: σ={m}, δ={d}, τ={dt}")
    for g in all_elements(2):
        p = marriage_map(g, m)
        print(f"    {KARIERA_NAMES[g]:10s} marries {KARIERA_NAMES[p]}")

# ===== KLEIN FOUR VERIFICATION =====
print("\n" + "=" * 60)
print("KLEIN FOUR-GROUP VERIFICATION")
print("=" * 60)

kinship_elts = [(0, 0), MARRY_GEN, DESCENT_GEN, DREAMTIME_GEN]
print("\nAddition table:")
print("     " + "  ".join(str(e) for e in kinship_elts))
for a in kinship_elts:
    row = []
    for b in kinship_elts:
        s = add_mod2(a, b)
        assert s in kinship_elts, f"Closure violated: {a} + {b} = {s}"
        row.append(str(s))
    print(f"  {a}  " + "  ".join(row))
print("\n✓ Closed under addition (Klein four-group V₄ verified)")

print("\n" + "=" * 60)
print("ALL DEMONSTRATIONS COMPLETE")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualization of Aboriginal Kinship Systems as Group Theory
============================================================
Creates plots showing the Kariera and Aranda kinship structures.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import product


def add_mod2(a, b):
    return tuple((x + y) % 2 for x, y in zip(a, b))


def make_kariera_kinship_graph():
    """Plot the Kariera kinship graph with marriage and descent edges."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    names = {(0, 0): "Karimera", (1, 0): "Burung",
             (0, 1): "Palyeri", (1, 1): "Banaka"}
    colors = {(0, 0): "#E74C3C", (1, 0): "#3498DB",
              (0, 1): "#2ECC71", (1, 1): "#F39C12"}

    positions = {(0, 0): (0, 1), (1, 0): (1, 1),
                 (0, 1): (0, 0), (1, 1): (1, 0)}

    marry_gen = (1, 0)
    descent_gen = (0, 1)
    dreamtime_gen = (1, 1)

    generators = [
        ("Marriage (σ)", marry_gen, "#E74C3C", axes[0]),
        ("Descent (δ)", descent_gen, "#3498DB", axes[1]),
        ("Dreamtime (τ)", dreamtime_gen, "#9B59B6", axes[2]),
    ]

    for title, gen, edge_color, ax in generators:
        ax.set_xlim(-0.5, 1.5)
        ax.set_ylim(-0.5, 1.5)
        ax.set_aspect('equal')
        ax.set_title(title, fontsize=14, fontweight='bold')
        ax.axis('off')

        # Draw edges
        seen = set()
        for g in product(range(2), repeat=2):
            if g not in seen:
                h = add_mod2(g, gen)
                seen.add(g)
                seen.add(h)
                x1, y1 = positions[g]
                x2, y2 = positions[h]
                ax.annotate("", xy=(x2, y2), xytext=(x1, y1),
                           arrowprops=dict(arrowstyle="<->", color=edge_color,
                                          lw=2.5))

        # Draw nodes
        for g, (x, y) in positions.items():
            circle = plt.Circle((x, y), 0.12, color=colors[g],
                              ec='black', lw=2, zorder=5)
            ax.add_patch(circle)
            ax.text(x, y - 0.22, names[g], ha='center', va='top',
                   fontsize=10, fontweight='bold')
            ax.text(x, y, str(g), ha='center', va='center',
                   fontsize=8, color='white', fontweight='bold', zorder=6)

    fig.suptitle("Kariera 4-Section System: Three Kinship Involutions",
                fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig("kariera_kinship_graph.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: kariera_kinship_graph.png")


def make_klein_four_cayley():
    """Plot the Cayley table of the Klein four-group."""
    fig, ax = plt.subplots(figsize=(6, 6))

    elements = [(0, 0), (1, 0), (0, 1), (1, 1)]
    labels = ["0", "σ", "δ", "τ"]
    colors_map = {"0": "#FFFFFF", "σ": "#E74C3C", "δ": "#3498DB", "τ": "#9B59B6"}

    n = len(elements)
    for i, a in enumerate(elements):
        for j, b in enumerate(elements):
            s = add_mod2(a, b)
            idx = elements.index(s)
            label = labels[idx]
            color = colors_map[label]
            rect = plt.Rectangle((j, n - 1 - i), 1, 1, facecolor=color,
                                edgecolor='black', lw=1.5, alpha=0.7)
            ax.add_patch(rect)
            ax.text(j + 0.5, n - 0.5 - i, label, ha='center', va='center',
                   fontsize=16, fontweight='bold')

    # Row/column headers
    for i, label in enumerate(labels):
        ax.text(i + 0.5, n + 0.3, label, ha='center', va='center',
               fontsize=14, fontweight='bold', color=colors_map[label])
        ax.text(-0.3, n - 0.5 - i, label, ha='center', va='center',
               fontsize=14, fontweight='bold', color=colors_map[label])

    ax.set_xlim(-0.6, n)
    ax.set_ylim(-0.1, n + 0.6)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title("Cayley Table: Klein Four-Group V₄\n(Kinship Elements)",
                fontsize=14, fontweight='bold')

    plt.tight_layout()
    plt.savefig("klein_four_cayley.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: klein_four_cayley.png")


def make_spectrum_bar_chart():
    """Bar chart of kinship spectrum sizes."""
    fig, ax = plt.subplots(figsize=(10, 6))

    ns = list(range(1, 7))
    spectrum_sizes = [2**n - 1 for n in ns]
    dreamtime_counts = [(2**n - 1) * (2**n - 2) for n in ns]

    x = np.arange(len(ns))
    width = 0.35

    bars1 = ax.bar(x - width/2, spectrum_sizes, width, label='Kinship Spectrum |Spec_K|',
                   color='#3498DB', edgecolor='black', alpha=0.8)
    bars2 = ax.bar(x + width/2, dreamtime_counts, width, label='Dreamtime Algebras',
                   color='#E74C3C', edgecolor='black', alpha=0.8)

    ax.set_xlabel('Dimension n (group = (Z₂)ⁿ)', fontsize=12)
    ax.set_ylabel('Count', fontsize=12)
    ax.set_title('Kinship Spectrum and Dreamtime Algebra Counts', fontsize=14, fontweight='bold')
    ax.set_xticks(x)
    ax.set_xticklabels([f'n={n}\n({2**n} sections)' for n in ns])
    ax.legend(fontsize=11)
    ax.set_yscale('log')

    # Add value labels
    for bar in bars1:
        h = bar.get_height()
        ax.text(bar.get_x() + bar.get_width()/2., h * 1.1, f'{int(h)}',
               ha='center', va='bottom', fontsize=9, fontweight='bold')
    for bar in bars2:
        h = bar.get_height()
        ax.text(bar.get_x() + bar.get_width()/2., h * 1.1, f'{int(h)}',
               ha='center', va='bottom', fontsize=9, fontweight='bold')

    plt.tight_layout()
    plt.savefig("spectrum_counts.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: spectrum_counts.png")


def make_impossibility_chart():
    """Visualize which groups admit Dreamtime algebras."""
    fig, ax = plt.subplots(figsize=(12, 4))

    groups = list(range(2, 17))
    can_build = []
    for n in groups:
        # Count elements of order dividing 2 in Z_n
        count = sum(1 for g in range(n) if (2 * g) % n == 0 and g != 0)
        can_build.append(count >= 2)

    colors_arr = ['#2ECC71' if c else '#E74C3C' for c in can_build]
    bars = ax.bar(range(len(groups)), [1]*len(groups), color=colors_arr,
                 edgecolor='black', alpha=0.8)

    ax.set_xticks(range(len(groups)))
    ax.set_xticklabels([f'Z_{n}' for n in groups], fontsize=11)
    ax.set_yticks([])
    ax.set_title('Which Cyclic Groups Admit Dreamtime Algebras?', fontsize=14, fontweight='bold')

    # Add counts
    for i, n in enumerate(groups):
        count = sum(1 for g in range(n) if (2 * g) % n == 0 and g != 0)
        ax.text(i, 0.5, f'{count}', ha='center', va='center',
               fontsize=14, fontweight='bold', color='white')
        status = "✓" if can_build[i] else "✗"
        ax.text(i, 1.1, status, ha='center', va='bottom', fontsize=14)

    ax.text(len(groups)/2, -0.3, '(Numbers show count of nontrivial elements of order 2; need ≥ 2)',
           ha='center', fontsize=10, style='italic')

    legend_elements = [mpatches.Patch(facecolor='#2ECC71', edgecolor='black', label='Admits DreamtimeAlgebra'),
                       mpatches.Patch(facecolor='#E74C3C', edgecolor='black', label='Cannot')]
    ax.legend(handles=legend_elements, loc='upper right', fontsize=10)

    plt.tight_layout()
    plt.savefig("impossibility_chart.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: impossibility_chart.png")


if __name__ == "__main__":
    make_kariera_kinship_graph()
    make_klein_four_cayley()
    make_spectrum_bar_chart()
    make_impossibility_chart()
    print("\nAll visualizations generated!")
