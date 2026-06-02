#!/usr/bin/env python3
"""
Demo: Independence Complex of Argumentation Frameworks

Demonstrates the key concepts and theorems from the formalization:
1. Computing conflict-free sets
2. Computing admissible, complete, stable, and grounded extensions
3. The Euler characteristic counterexample
4. Exponential growth of conflict-free subsets
"""

from itertools import combinations
from typing import Dict, List, Set, Tuple, FrozenSet


def compute_conflict_free(args: Set[int], attacks: Set[Tuple[int, int]]) -> List[FrozenSet[int]]:
    """Compute all conflict-free sets of an argumentation framework."""
    cf_sets = []
    n = len(args)
    args_list = sorted(args)
    
    for size in range(n + 1):
        for subset in combinations(args_list, size):
            s = frozenset(subset)
            is_cf = True
            for a in s:
                for b in s:
                    if (a, b) in attacks:
                        is_cf = False
                        break
                if not is_cf:
                    break
            if is_cf:
                cf_sets.append(s)
    return cf_sets


def defended_by(x: int, s: FrozenSet[int], args: Set[int], 
                attacks: Set[Tuple[int, int]]) -> bool:
    """Check if argument x is defended by set s."""
    for b in args:
        if (b, x) in attacks:
            # Need some c in s attacking b
            found = False
            for c in s:
                if (c, b) in attacks:
                    found = True
                    break
            if not found:
                return False
    return True


def is_admissible(s: FrozenSet[int], args: Set[int], 
                  attacks: Set[Tuple[int, int]]) -> bool:
    """Check if s is admissible."""
    # Check conflict-free
    for a in s:
        for b in s:
            if (a, b) in attacks:
                return False
    # Check self-defense
    for a in s:
        if not defended_by(a, s, args, attacks):
            return False
    return True


def is_complete(s: FrozenSet[int], args: Set[int], 
                attacks: Set[Tuple[int, int]]) -> bool:
    """Check if s is a complete extension."""
    if not is_admissible(s, args, attacks):
        return False
    for x in args:
        if x not in s and defended_by(x, s, args, attacks):
            return False
    return True


def is_stable(s: FrozenSet[int], args: Set[int], 
              attacks: Set[Tuple[int, int]]) -> bool:
    """Check if s is a stable extension."""
    # Check conflict-free
    for a in s:
        for b in s:
            if (a, b) in attacks:
                return False
    # Check every non-member is attacked
    for x in args:
        if x not in s:
            attacked = False
            for a in s:
                if (a, x) in attacks:
                    attacked = True
                    break
            if not attacked:
                return False
    return True


def grounded_extension(args: Set[int], 
                       attacks: Set[Tuple[int, int]]) -> FrozenSet[int]:
    """Compute the grounded extension by iterating the defense operator."""
    g: FrozenSet[int] = frozenset()
    while True:
        new_g = frozenset(x for x in args if defended_by(x, g, args, attacks))
        if new_g == g:
            return g
        g = new_g


def euler_characteristic(cf_sets: List[FrozenSet[int]]) -> int:
    """Compute the Euler characteristic of the independence complex."""
    max_dim = max((len(s) for s in cf_sets), default=0)
    chi = 0
    for dim in range(max_dim + 1):
        count = sum(1 for s in cf_sets if len(s) == dim)
        chi += (-1)**dim * count
    return chi


def f_vector(cf_sets: List[FrozenSet[int]]) -> Dict[int, int]:
    """Compute the f-vector: f_i = number of i-dimensional faces."""
    result: Dict[int, int] = {}
    for s in cf_sets:
        dim = len(s)  # dimension = size (we count ∅ as dim 0)
        result[dim] = result.get(dim, 0) + 1
    return result


# ================================================================
# DEMO 1: Euler Characteristic Counterexample
# ================================================================
print("=" * 60)
print("DEMO 1: Euler Characteristic Counterexample")
print("=" * 60)
print()

args1 = {0, 1, 2}
attacks1 = {(0, 1), (1, 2)}

print(f"Framework: arguments = {args1}")
print(f"Attacks: 0 → 1, 1 → 2")
print()

cf1 = compute_conflict_free(args1, attacks1)
print(f"Conflict-free sets ({len(cf1)}):")
for s in cf1:
    print(f"  {set(s) if s else '∅'}")

fv1 = f_vector(cf1)
print(f"\nf-vector: {fv1}")
chi1 = euler_characteristic(cf1)
print(f"Euler characteristic χ = {chi1}")

# Extensions
adm1 = [s for s in cf1 if is_admissible(s, args1, attacks1)]
comp1 = [s for s in cf1 if is_complete(s, args1, attacks1)]
stab1 = [s for s in cf1 if is_stable(s, args1, attacks1)]
pref1 = [s for s in adm1 if not any(s < t for t in adm1)]  # maximal admissible
gr1 = grounded_extension(args1, attacks1)

print(f"\nAdmissible sets: {[set(s) if s else '∅' for s in adm1]}")
print(f"Complete extensions: {[set(s) if s else '∅' for s in comp1]}")
print(f"Stable extensions: {[set(s) if s else '∅' for s in stab1]}")
print(f"Preferred extensions: {[set(s) if s else '∅' for s in pref1]}")
print(f"Grounded extension: {set(gr1) if gr1 else '∅'}")

print(f"\n|preferred| - |grounded extensions| = {len(pref1)} - 1 = {len(pref1) - 1}")
print(f"χ = {chi1}")
print(f"DISPROVED: χ ≠ |preferred| - |grounded| ({chi1} ≠ {len(pref1) - 1})")

# ================================================================
# DEMO 2: Exponential Growth
# ================================================================
print("\n" + "=" * 60)
print("DEMO 2: Exponential Growth")
print("=" * 60)
print()

for k in range(1, 7):
    # k independent arguments (no attacks)
    args_k = set(range(k))
    attacks_k: Set[Tuple[int, int]] = set()
    cf_k = compute_conflict_free(args_k, attacks_k)
    print(f"k = {k}: independent set of size {k} has {len(cf_k)} "
          f"conflict-free subsets (expected 2^{k} = {2**k})")

# ================================================================
# DEMO 3: Defense Iteration (Grounded Extension Computation)
# ================================================================
print("\n" + "=" * 60)
print("DEMO 3: Defense Iteration for Grounded Extension")
print("=" * 60)
print()

# More complex framework
args3 = {0, 1, 2, 3, 4}
attacks3 = {(0, 1), (1, 0), (1, 2), (2, 3), (3, 4), (4, 2)}
print(f"Framework: arguments = {args3}")
print(f"Attacks: {attacks3}")

g = frozenset()
step = 0
print(f"\nStep {step}: G = {set(g) if g else '∅'}")
while True:
    new_g = frozenset(x for x in args3 if defended_by(x, g, args3, attacks3))
    step += 1
    print(f"Step {step}: G = {set(new_g) if new_g else '∅'}")
    if new_g == g:
        break
    g = new_g

print(f"\nGrounded extension: {set(g) if g else '∅'}")
print(f"Stabilized after {step} steps")

cf3 = compute_conflict_free(args3, attacks3)
comp3 = [s for s in cf3 if is_complete(s, args3, attacks3)]
stab3 = [s for s in cf3 if is_stable(s, args3, attacks3)]
print(f"\nComplete extensions: {[set(s) if s else '∅' for s in comp3]}")
print(f"Stable extensions: {[set(s) if s else '∅' for s in stab3]}")

# ================================================================
# DEMO 4: Framework with No Stable Extension
# ================================================================
print("\n" + "=" * 60)
print("DEMO 4: Framework with No Stable Extension")
print("=" * 60)
print()

# Odd cycle: 0→1, 1→2, 2→0
args4 = {0, 1, 2}
attacks4 = {(0, 1), (1, 2), (2, 0)}
print(f"Framework (odd cycle): {attacks4}")

cf4 = compute_conflict_free(args4, attacks4)
stab4 = [s for s in cf4 if is_stable(s, args4, attacks4)]
pref4 = [s for s in cf4 if is_admissible(s, args4, attacks4) and 
         not any(s < t and is_admissible(t, args4, attacks4) for t in cf4)]
gr4 = grounded_extension(args4, attacks4)

print(f"Conflict-free sets: {[set(s) if s else '∅' for s in cf4]}")
print(f"Stable extensions: {stab4 if stab4 else 'NONE'}")
print(f"Preferred extensions: {[set(s) if s else '∅' for s in pref4]}")
print(f"Grounded extension: {set(gr4) if gr4 else '∅'}")
chi4 = euler_characteristic(cf4)
print(f"Euler characteristic: {chi4}")


if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Extension Hierarchy of Argumentation Frameworks

Shows the containment relationships between different extension semantics
across multiple example frameworks.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from itertools import combinations


def compute_conflict_free(args, attacks):
    result = [frozenset()]
    for a in sorted(args):
        new_sets = []
        for s in result:
            c = s | {a}
            if all((x, y) not in attacks for x in c for y in c):
                new_sets.append(c)
        result.extend(new_sets)
    return result


def is_defended(x, s, args, attacks):
    for b in args:
        if (b, x) in attacks:
            if not any((c, b) in attacks for c in s):
                return False
    return True


def classify_sets(args, attacks):
    cf = compute_conflict_free(args, attacks)
    adm = [s for s in cf if all(is_defended(a, s, args, attacks) for a in s)]
    comp = [s for s in adm if all(x in s for x in args if is_defended(x, s, args, attacks))]
    stab = [s for s in cf if all(any((a, x) in attacks for a in s) for x in args if x not in s)]
    pref = [s for s in adm if not any(s < t for t in adm)]
    
    # Grounded
    g = frozenset()
    for _ in range(len(args) + 1):
        ng = frozenset(x for x in args if is_defended(x, g, args, attacks))
        if ng == g:
            break
        g = ng
    
    return {
        'cf': len(cf), 'adm': len(adm), 'comp': len(comp),
        'stab': len(stab), 'pref': len(pref), 'grounded': set(g) if g else '∅'
    }


def main():
    frameworks = [
        ("Linear: 0→1→2", {0, 1, 2}, {(0, 1), (1, 2)}),
        ("Even cycle: 0→1→2→3→0", {0, 1, 2, 3}, {(0, 1), (1, 2), (2, 3), (3, 0)}),
        ("Odd cycle: 0→1→2→0", {0, 1, 2}, {(0, 1), (1, 2), (2, 0)}),
        ("Mutual: 0↔1, 2↔3", {0, 1, 2, 3}, {(0, 1), (1, 0), (2, 3), (3, 2)}),
        ("Star: 0→{1,2,3}", {0, 1, 2, 3}, {(0, 1), (0, 2), (0, 3)}),
        ("Self-attack: 0→0", {0, 1}, {(0, 0)}),
    ]
    
    fig, ax = plt.subplots(figsize=(12, 8))
    ax.set_title("Extension Hierarchy Across Frameworks", fontsize=14, fontweight='bold')
    
    headers = ["Framework", "|CF|", "|Adm|", "|Comp|", "|Stab|", "|Pref|", "Grounded"]
    
    # Table data
    table_data = []
    for name, args, attacks in frameworks:
        stats = classify_sets(args, attacks)
        table_data.append([
            name,
            str(stats['cf']),
            str(stats['adm']),
            str(stats['comp']),
            str(stats['stab']),
            str(stats['pref']),
            str(stats['grounded']),
        ])
    
    # Create table
    table = ax.table(
        cellText=table_data,
        colLabels=headers,
        loc='center',
        cellLoc='center',
    )
    
    table.auto_set_font_size(False)
    table.set_fontsize(10)
    table.scale(1, 2)
    
    # Style header
    for j in range(len(headers)):
        cell = table[0, j]
        cell.set_facecolor('#1976D2')
        cell.set_text_props(color='white', fontweight='bold')
    
    # Color rows
    row_colors = ['#E3F2FD', '#FFFFFF']
    for i in range(len(table_data)):
        for j in range(len(headers)):
            cell = table[i + 1, j]
            cell.set_facecolor(row_colors[i % 2])
    
    # Make first column left-aligned
    for i in range(len(table_data) + 1):
        cell = table[i, 0]
        cell._loc = 'left'
    
    ax.axis('off')
    
    # Add hierarchy diagram below
    ax.text(0.5, 0.02, 
            "Hierarchy: Stable ⊆ Complete ⊆ Admissible ⊆ Conflict-Free   |   "
            "Preferred = Maximal Admissible   |   Grounded = Least Complete",
            ha='center', fontsize=9, style='italic', color='#666',
            transform=ax.transAxes)
    
    plt.tight_layout()
    plt.savefig('extension_hierarchy.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: extension_hierarchy.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Independence Complex of Argumentation Frameworks

Generates a visualization of the attack graph and its independence complex
(Hasse diagram of the face lattice) for the Euler characteristic counterexample.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import combinations


def compute_conflict_free(args, attacks):
    """Compute all conflict-free sets."""
    result = [frozenset()]
    args_sorted = sorted(args)
    for a in args_sorted:
        new_sets = []
        for s in result:
            candidate = s | {a}
            is_cf = True
            for x in candidate:
                for y in candidate:
                    if (x, y) in attacks:
                        is_cf = False
                        break
                if not is_cf:
                    break
            if is_cf:
                new_sets.append(candidate)
        result.extend(new_sets)
    return result


def main():
    # Framework: 0→1, 1→2
    args = {0, 1, 2}
    attacks = {(0, 1), (1, 2)}
    
    cf_sets = compute_conflict_free(args, attacks)
    
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # --- Left: Attack Graph ---
    ax1 = axes[0]
    ax1.set_title("Attack Graph: AF = ({0,1,2}, {0→1, 1→2})", fontsize=12, fontweight='bold')
    
    # Position arguments in a line
    positions = {0: (0.2, 0.5), 1: (0.5, 0.5), 2: (0.8, 0.5)}
    
    # Draw arguments
    for arg, (x, y) in positions.items():
        circle = plt.Circle((x, y), 0.06, color='#4CAF50', ec='black', linewidth=2, zorder=5)
        ax1.add_patch(circle)
        ax1.text(x, y, str(arg), ha='center', va='center', fontsize=14, fontweight='bold', zorder=6)
    
    # Draw attacks
    for (a, b) in attacks:
        x1, y1 = positions[a]
        x2, y2 = positions[b]
        dx = x2 - x1
        dy = y2 - y1
        length = np.sqrt(dx**2 + dy**2)
        # Shorten arrow to not overlap circles
        shrink = 0.07 / length
        ax1.annotate("", xy=(x2 - dx*shrink, y2 - dy*shrink), 
                     xytext=(x1 + dx*shrink, y1 + dy*shrink),
                     arrowprops=dict(arrowstyle='->', color='red', lw=2.5))
    
    ax1.set_xlim(0, 1)
    ax1.set_ylim(0, 1)
    ax1.set_aspect('equal')
    ax1.axis('off')
    
    # Labels
    ax1.text(0.5, 0.15, f"Conflict-free sets: {len(cf_sets)}", 
             ha='center', fontsize=11)
    ax1.text(0.5, 0.08, "∅, {0}, {1}, {2}, {0,2}", 
             ha='center', fontsize=10, style='italic')
    
    # --- Right: Independence Complex (Hasse Diagram) ---
    ax2 = axes[1]
    ax2.set_title("Independence Complex (Face Lattice)", fontsize=12, fontweight='bold')
    
    # Organize by dimension
    by_dim = {}
    for s in cf_sets:
        d = len(s)
        by_dim.setdefault(d, []).append(s)
    
    # Position nodes in Hasse diagram
    node_pos = {}
    colors = {0: '#E3F2FD', 1: '#BBDEFB', 2: '#90CAF9'}
    
    for dim, sets in sorted(by_dim.items()):
        n = len(sets)
        for i, s in enumerate(sorted(sets, key=lambda x: tuple(sorted(x)))):
            x = (i + 0.5) / n
            y = 0.15 + dim * 0.35
            node_pos[s] = (x, y)
    
    # Draw edges (inclusion relations)
    for s1 in cf_sets:
        for s2 in cf_sets:
            if len(s2) == len(s1) + 1 and s1 < s2:
                x1, y1 = node_pos[s1]
                x2, y2 = node_pos[s2]
                ax2.plot([x1, x2], [y1, y2], 'k-', alpha=0.3, linewidth=1.5)
    
    # Draw nodes
    for s, (x, y) in node_pos.items():
        dim = len(s)
        color = colors.get(dim, '#E0E0E0')
        box = mpatches.FancyBboxPatch((x-0.08, y-0.04), 0.16, 0.08,
                                       boxstyle="round,pad=0.02",
                                       facecolor=color, edgecolor='black', linewidth=1.5)
        ax2.add_patch(box)
        label = "∅" if not s else "{" + ",".join(map(str, sorted(s))) + "}"
        ax2.text(x, y, label, ha='center', va='center', fontsize=9, fontweight='bold')
    
    # Dimension labels
    for dim in by_dim:
        ax2.text(-0.05, 0.15 + dim * 0.35, f"dim {dim}", 
                ha='center', va='center', fontsize=9, color='gray')
    
    # Euler characteristic annotation
    f_vec = {d: len(sets) for d, sets in by_dim.items()}
    chi = sum((-1)**d * c for d, c in f_vec.items())
    ax2.text(0.5, 0.95, f"f-vector: ({', '.join(str(f_vec.get(d, 0)) for d in range(max(f_vec)+1))})", 
             ha='center', fontsize=10, transform=ax2.transAxes)
    ax2.text(0.5, 0.88, f"χ = {' + '.join(f'({-1 if d%2 else 1}){f_vec.get(d,0)}' for d in range(max(f_vec)+1))} = {chi}", 
             ha='center', fontsize=10, color='#D32F2F', fontweight='bold', transform=ax2.transAxes)
    
    ax2.set_xlim(-0.15, 1.15)
    ax2.set_ylim(0, 1)
    ax2.axis('off')
    
    plt.tight_layout()
    plt.savefig('independence_complex.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: independence_complex.png")


if __name__ == "__main__":
    main()
