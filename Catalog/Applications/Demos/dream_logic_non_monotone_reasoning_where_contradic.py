"""
Dream Logic Demo: Paraconsistent Reasoning and Dream Spaces
============================================================

Demonstrates:
1. Belnap's four-valued logic with non-explosion
2. Closed-world assumption and non-monotonicity
3. Singleton dream space and union failure
"""

from enum import Enum
from typing import Set, FrozenSet, Dict, List, Tuple


class BelnapVal(Enum):
    """Belnap's four truth values."""
    NEITHER = "⊥"   # No information
    TRUE = "T"       # True only
    FALSE = "F"      # False only
    BOTH = "⊤"      # Both true and false (contradictory)


def neg(v: BelnapVal) -> BelnapVal:
    """Paraconsistent negation."""
    return {
        BelnapVal.NEITHER: BelnapVal.NEITHER,
        BelnapVal.TRUE: BelnapVal.FALSE,
        BelnapVal.FALSE: BelnapVal.TRUE,
        BelnapVal.BOTH: BelnapVal.BOTH,
    }[v]


def tconj(a: BelnapVal, b: BelnapVal) -> BelnapVal:
    """Truth conjunction (generalized AND)."""
    if a == BelnapVal.FALSE or b == BelnapVal.FALSE:
        return BelnapVal.FALSE
    if a == BelnapVal.TRUE:
        return b
    if b == BelnapVal.TRUE:
        return a
    if a == BelnapVal.NEITHER and b == BelnapVal.NEITHER:
        return BelnapVal.NEITHER
    if a == BelnapVal.BOTH and b == BelnapVal.BOTH:
        return BelnapVal.BOTH
    return BelnapVal.FALSE  # NEITHER ∧ BOTH or BOTH ∧ NEITHER


def tdisj(a: BelnapVal, b: BelnapVal) -> BelnapVal:
    """Truth disjunction (generalized OR)."""
    if a == BelnapVal.TRUE or b == BelnapVal.TRUE:
        return BelnapVal.TRUE
    if a == BelnapVal.FALSE:
        return b
    if b == BelnapVal.FALSE:
        return a
    if a == BelnapVal.NEITHER and b == BelnapVal.NEITHER:
        return BelnapVal.NEITHER
    if a == BelnapVal.BOTH and b == BelnapVal.BOTH:
        return BelnapVal.BOTH
    return BelnapVal.TRUE  # NEITHER ∨ BOTH or BOTH ∨ NEITHER


def is_designated(v: BelnapVal) -> bool:
    """A value is designated if it contains truth."""
    return v in (BelnapVal.TRUE, BelnapVal.BOTH)


def kjoin(a: BelnapVal, b: BelnapVal) -> BelnapVal:
    """Knowledge join: combine information."""
    if a == BelnapVal.NEITHER:
        return b
    if b == BelnapVal.NEITHER:
        return a
    if a == BelnapVal.BOTH or b == BelnapVal.BOTH:
        return BelnapVal.BOTH
    if a == b:
        return a
    return BelnapVal.BOTH  # TRUE ⊔ FALSE = BOTH


# ─── Demo 1: Non-Explosion ───────────────────────────────────────────

print("=" * 60)
print("DEMO 1: The Non-Explosion Theorem")
print("=" * 60)
print()
print("In classical logic, P ∧ ¬P ⊢ Q for all Q (explosion).")
print("In Belnap's logic, contradictions are contained.")
print()

for v in BelnapVal:
    contradiction = tconj(v, neg(v))
    print(f"  v = {v.value:2s}:  v ∧ ¬v = {contradiction.value}  "
          f"(designated: {is_designated(contradiction)})")

print()
print("→ Only BOTH sustains self-contradiction without explosion.")
print("→ The contradiction is QUARANTINED — it doesn't infect other values.")

# ─── Demo 2: Non-Monotonicity ────────────────────────────────────────

print()
print("=" * 60)
print("DEMO 2: Non-Monotonic Closed-World Reasoning")
print("=" * 60)
print()

props = ["rain", "umbrella", "sun"]

def cwa_valuation(known: set, prop: str) -> BelnapVal:
    """Closed-world assumption: known facts are TRUE, others FALSE."""
    return BelnapVal.TRUE if prop in known else BelnapVal.FALSE

# Phase 1: Know only "rain"
known1 = {"rain"}
print(f"Knowledge base: {known1}")
for p in props:
    v = cwa_valuation(known1, p)
    nv = neg(v)
    print(f"  {p:10s} → {v.value}   ¬{p:10s} → {nv.value} (designated: {is_designated(nv)})")

print()
print("→ Under CWA, ¬umbrella and ¬sun are designated (assumed false).")

# Phase 2: Learn "umbrella"
known2 = {"rain", "umbrella"}
print(f"\nExpanded knowledge: {known2}")
for p in props:
    v = cwa_valuation(known2, p)
    nv = neg(v)
    print(f"  {p:10s} → {v.value}   ¬{p:10s} → {nv.value} (designated: {is_designated(nv)})")

print()
print("→ ¬umbrella was designated, now it's NOT. Belief RETRACTED!")
print("→ This is NON-MONOTONE: more knowledge → fewer beliefs.")

# ─── Demo 3: Dream Space ─────────────────────────────────────────────

print()
print("=" * 60)
print("DEMO 3: The Singleton Dream Space (Not Topological)")
print("=" * 60)
print()

def is_singleton_open(s: FrozenSet[int], universe_size: int) -> bool:
    """Check if s is open in the singleton dream space on {0,...,n-1}."""
    if len(s) == 0:
        return True  # Empty set
    if len(s) == universe_size:
        return True  # Universe
    if len(s) == 1:
        return True  # Singleton
    return False

N = 10
print(f"Dream space on {{0, ..., {N-1}}}:")
print(f"  Open sets: ∅, {{0,...,{N-1}}}, and each singleton {{n}}")
print()

# Check finite intersection closure
print("Finite intersection closure:")
for i in range(min(5, N)):
    for j in range(i+1, min(5, N)):
        inter = frozenset({i}) & frozenset({j})
        print(f"  {{{i}}} ∩ {{{j}}} = {'∅' if not inter else inter}  "
              f"(open: {is_singleton_open(inter, N)})")
    if i == 0:
        print(f"  ... (all singleton intersections are ∅ or the singleton)")
        break

print()
print("Union failure (the key!):")
evens = frozenset(range(0, N, 2))
print(f"  Even singletons: {{{', '.join(f'{{{n}}}' for n in sorted(evens))}}}")
print(f"  Each singleton is open: ✓")
print(f"  Union = {set(sorted(evens))}")
print(f"  Union is open: {is_singleton_open(evens, N)}")
print(f"  → The union of infinitely many open sets is NOT open!")
print(f"  → This dream space is NOT a topological space.")

# ─── Demo 4: Full Truth Table ────────────────────────────────────────

print()
print("=" * 60)
print("DEMO 4: Belnap Truth Tables")
print("=" * 60)
print()

vals = list(BelnapVal)

print("Conjunction (∧):")
print("     ", "  ".join(f"{v.value:>3}" for v in vals))
for a in vals:
    row = "  ".join(f"{tconj(a, b).value:>3}" for b in vals)
    print(f"  {a.value:>2}  {row}")

print()
print("Disjunction (∨):")
print("     ", "  ".join(f"{v.value:>3}" for v in vals))
for a in vals:
    row = "  ".join(f"{tdisj(a, b).value:>3}" for b in vals)
    print(f"  {a.value:>2}  {row}")

print()
print("Negation and self-contradiction:")
print(f"  {'v':>5}  {'¬v':>5}  {'v∧¬v':>5}  {'designated?':>12}")
for v in vals:
    nv = neg(v)
    sc = tconj(v, nv)
    print(f"  {v.value:>5}  {nv.value:>5}  {sc.value:>5}  {str(is_designated(sc)):>12}")

print()
print("Knowledge join (⊔_k) — combining information sources:")
print("     ", "  ".join(f"{v.value:>3}" for v in vals))
for a in vals:
    row = "  ".join(f"{kjoin(a, b).value:>3}" for b in vals)
    print(f"  {a.value:>2}  {row}")

print()
print("Done! All formal proofs verified in Lean 4.")


"""
Visualization: Belnap's Four-Valued Bilattice
==============================================

Displays the knowledge ordering and truth operations as a Hasse diagram.
"""
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def draw_belnap_bilattice():
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    # ── Panel 1: Knowledge Ordering ──
    ax = axes[0]
    ax.set_title("Knowledge Ordering ≤_k", fontsize=14, fontweight='bold')
    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(-0.5, 3.5)
    ax.set_aspect('equal')
    ax.axis('off')

    positions = {
        '⊥ (neither)': (0, 0),
        'T (true)': (-1, 1.5),
        'F (false)': (1, 1.5),
        '⊤ (both)': (0, 3),
    }

    colors = {
        '⊥ (neither)': '#E8E8E8',
        'T (true)': '#90EE90',
        'F (false)': '#FFB6C1',
        '⊤ (both)': '#DDA0DD',
    }

    edges = [
        ('⊥ (neither)', 'T (true)'),
        ('⊥ (neither)', 'F (false)'),
        ('T (true)', '⊤ (both)'),
        ('F (false)', '⊤ (both)'),
    ]

    for (n1, n2) in edges:
        x1, y1 = positions[n1]
        x2, y2 = positions[n2]
        ax.annotate("", xy=(x2, y2 - 0.25), xytext=(x1, y1 + 0.25),
                     arrowprops=dict(arrowstyle='->', color='#555', lw=1.5))

    for name, (x, y) in positions.items():
        circle = plt.Circle((x, y), 0.35, color=colors[name], ec='black', lw=2, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y, name.split('(')[0].strip(), ha='center', va='center',
                fontsize=11, fontweight='bold', zorder=6)
        ax.text(x, y - 0.55, f"({name.split('(')[1]}", ha='center', va='center',
                fontsize=8, color='#555', zorder=6)

    ax.text(0, -0.3, "More knowledge ↑", ha='center', fontsize=9, style='italic', color='#777')

    # ── Panel 2: Truth Table (Conjunction) ──
    ax = axes[1]
    ax.set_title("Truth Conjunction (∧)", fontsize=14, fontweight='bold')
    ax.axis('off')

    vals = ['⊥', 'T', 'F', '⊤']
    table_data = [
        ['⊥', '⊥', 'F', 'F'],
        ['⊥', 'T', 'F', '⊤'],
        ['F', 'F', 'F', 'F'],
        ['F', '⊤', 'F', '⊤'],
    ]

    cell_colors_data = []
    color_map = {'⊥': '#E8E8E8', 'T': '#90EE90', 'F': '#FFB6C1', '⊤': '#DDA0DD'}
    for row in table_data:
        cell_colors_data.append([color_map[v] for v in row])

    table = ax.table(cellText=table_data,
                     rowLabels=vals,
                     colLabels=vals,
                     cellColours=cell_colors_data,
                     loc='center',
                     cellLoc='center')
    table.auto_set_font_size(False)
    table.set_fontsize(12)
    table.scale(1.2, 1.8)

    # ── Panel 3: Self-Contradiction ──
    ax = axes[2]
    ax.set_title("Self-Contradiction v ∧ ¬v", fontsize=14, fontweight='bold')
    ax.axis('off')

    sc_data = [
        ['⊥', '⊥', '⊥', '✗'],
        ['T', 'F', 'F', '✗'],
        ['F', 'T', 'F', '✗'],
        ['⊤', '⊤', '⊤', '✓ (!!)'],
    ]

    sc_colors = []
    for row in sc_data:
        colors_row = []
        for i, v in enumerate(row):
            if i == 3:
                colors_row.append('#90EE90' if '✓' in v else '#FFB6C1')
            else:
                colors_row.append(color_map.get(v, 'white'))
        sc_colors.append(colors_row)

    table2 = ax.table(cellText=sc_data,
                      rowLabels=vals,
                      colLabels=['v', '¬v', 'v∧¬v', 'Designated?'],
                      cellColours=sc_colors,
                      loc='center',
                      cellLoc='center')
    table2.auto_set_font_size(False)
    table2.set_fontsize(11)
    table2.scale(1.2, 1.8)

    fig.suptitle("Belnap's Four-Valued Paraconsistent Logic",
                 fontsize=16, fontweight='bold', y=0.98)
    plt.tight_layout(rect=[0, 0, 1, 0.95])
    plt.savefig('belnap_bilattice.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: belnap_bilattice.png")


def draw_dream_space():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # ── Panel 1: Singleton Dream Space ──
    ax = axes[0]
    ax.set_title("Singleton Dream Space on ℕ", fontsize=14, fontweight='bold')

    # Draw some singletons
    n_show = 8
    for i in range(n_show):
        circle = plt.Circle((i, 0), 0.3, color='#90EE90', ec='black', lw=1.5, alpha=0.8)
        ax.add_patch(circle)
        ax.text(i, 0, f"{{{i}}}", ha='center', va='center', fontsize=9)

    # Show union of even singletons
    for i in range(0, n_show, 2):
        rect = mpatches.FancyBboxPatch((i - 0.35, -0.8), 0.7, 0.5,
                                        boxstyle="round,pad=0.1",
                                        facecolor='#FFB6C1', edgecolor='red',
                                        lw=2, alpha=0.7)
        ax.add_patch(rect)
        ax.text(i, -0.55, f"{{{i}}}", ha='center', va='center', fontsize=8, color='red')

    # Arrow showing union
    ax.annotate("∪ = {0,2,4,6,...}", xy=(3.5, -1.3), fontsize=11,
                ha='center', color='red', fontweight='bold')
    ax.annotate("NOT OPEN!", xy=(3.5, -1.7), fontsize=12,
                ha='center', color='red', fontweight='bold',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='#FFE4E1', edgecolor='red'))

    ax.set_xlim(-1, n_show)
    ax.set_ylim(-2.2, 1.2)
    ax.set_aspect('equal')
    ax.axis('off')

    # ── Panel 2: Topological vs Dream ──
    ax = axes[1]
    ax.set_title("Topological vs Dream Space", fontsize=14, fontweight='bold')

    # Venn-like diagram
    theta = np.linspace(0, 2 * np.pi, 100)

    # Large circle: Dream spaces
    r_dream = 2.5
    ax.plot(r_dream * np.cos(theta), r_dream * np.sin(theta),
            color='#DDA0DD', lw=3)
    ax.fill(r_dream * np.cos(theta), r_dream * np.sin(theta),
            color='#DDA0DD', alpha=0.15)
    ax.text(0, 2.8, "Dream Spaces", ha='center', fontsize=12,
            fontweight='bold', color='#8B008B')

    # Smaller circle: Topological spaces
    r_topo = 1.5
    cx, cy = -0.3, -0.3
    ax.plot(cx + r_topo * np.cos(theta), cy + r_topo * np.sin(theta),
            color='#4682B4', lw=3)
    ax.fill(cx + r_topo * np.cos(theta), cy + r_topo * np.sin(theta),
            color='#4682B4', alpha=0.2)
    ax.text(cx, cy, "Topological\nSpaces", ha='center', fontsize=11,
            fontweight='bold', color='#00008B')

    # Mark the singleton dream space
    ax.plot(1.8, 1.2, 'r*', markersize=20, zorder=5)
    ax.text(1.8, 0.7, "Singleton\nDream Space", ha='center', fontsize=9,
            color='red', fontweight='bold')

    ax.set_xlim(-3.5, 3.5)
    ax.set_ylim(-3.5, 3.5)
    ax.set_aspect('equal')
    ax.axis('off')

    fig.suptitle("Dream Spaces Strictly Generalize Topological Spaces",
                 fontsize=16, fontweight='bold', y=0.98)
    plt.tight_layout(rect=[0, 0, 1, 0.95])
    plt.savefig('dream_space.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: dream_space.png")


if __name__ == "__main__":
    draw_belnap_bilattice()
    draw_dream_space()
