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
