#!/usr/bin/env python3
"""
Demo: The Topology of Argumentation
Computes conflict-free complexes, admissible sets, and preferred extensions
for several example argumentation frameworks.
"""

from itertools import combinations
from typing import Set, FrozenSet, List, Tuple, Dict


def is_conflict_free(S: FrozenSet[int], attacks: Set[Tuple[int, int]]) -> bool:
    """Check if S is conflict-free: no argument in S attacks another in S."""
    for a in S:
        for b in S:
            if (a, b) in attacks:
                return False
    return True


def defends(S: FrozenSet[int], a: int, attacks: Set[Tuple[int, int]]) -> bool:
    """Check if S defends argument a."""
    for b, target in attacks:
        if target == a:
            # b attacks a; check if some c in S attacks b
            if not any((c, b) in attacks for c in S):
                return False
    return True


def is_admissible(S: FrozenSet[int], attacks: Set[Tuple[int, int]]) -> bool:
    """Check if S is admissible: conflict-free and self-defending."""
    if not is_conflict_free(S, attacks):
        return False
    return all(defends(S, a, attacks) for a in S)


def all_subsets(args: Set[int]) -> List[FrozenSet[int]]:
    """Generate all subsets of args."""
    result = []
    args_list = sorted(args)
    for r in range(len(args_list) + 1):
        for combo in combinations(args_list, r):
            result.append(frozenset(combo))
    return result


def conflict_free_complex(args: Set[int], attacks: Set[Tuple[int, int]]) -> List[FrozenSet[int]]:
    """Compute the conflict-free complex (all conflict-free sets)."""
    return [S for S in all_subsets(args) if is_conflict_free(S, attacks)]


def preferred_extensions(args: Set[int], attacks: Set[Tuple[int, int]]) -> List[FrozenSet[int]]:
    """Compute preferred extensions (maximal admissible sets)."""
    admissible_sets = [S for S in all_subsets(args) if is_admissible(S, attacks)]
    # Keep only maximal ones
    preferred = []
    for S in admissible_sets:
        if not any(S < T for T in admissible_sets):
            preferred.append(S)
    return preferred


def euler_characteristic(complex: List[FrozenSet[int]]) -> int:
    """Compute Euler characteristic from face counts by dimension."""
    if not complex:
        return 0
    max_dim = max(len(f) for f in complex) - 1
    chi = 0
    for d in range(-1, max_dim + 1):
        count = sum(1 for f in complex if len(f) == d + 1)
        chi += (-1) ** d * count
    return chi


def grounded_extension(args: Set[int], attacks: Set[Tuple[int, int]]) -> FrozenSet[int]:
    """Compute grounded extension via least fixed point of the characteristic function."""
    S: Set[int] = set()
    changed = True
    while changed:
        changed = False
        for a in args:
            if a not in S and defends(frozenset(S), a, attacks):
                S.add(a)
                changed = True
    return frozenset(S)


def print_framework(name: str, args: Set[int], attacks: Set[Tuple[int, int]]):
    """Print analysis of an argumentation framework."""
    print(f"\n{'='*60}")
    print(f"Framework: {name}")
    print(f"Arguments: {sorted(args)}")
    print(f"Attacks: {sorted(attacks)}")

    cf = conflict_free_complex(args, attacks)
    print(f"\nConflict-free complex ({len(cf)} faces):")
    for dim in range(-1, max((len(f) - 1 for f in cf), default=-1) + 1):
        faces_at_dim = [f for f in cf if len(f) == dim + 1]
        if faces_at_dim:
            print(f"  dim {dim}: {[set(f) for f in faces_at_dim]}")

    chi = euler_characteristic(cf)
    print(f"\nEuler characteristic χ = {chi}")

    pref = preferred_extensions(args, attacks)
    print(f"\nPreferred extensions ({len(pref)}):")
    for p in pref:
        print(f"  {set(p)}")

    gr = grounded_extension(args, attacks)
    print(f"\nGrounded extension: {set(gr)} (size {len(gr)})")

    conjectured = len(pref) - len(gr)
    print(f"\nConjecture test: χ = {chi}, |pref| - |grounded| = {len(pref)} - {len(gr)} = {conjectured}")
    if chi == conjectured:
        print("  ✓ Conjecture holds for this framework")
    else:
        print("  ✗ CONJECTURE FAILS! (as we proved formally)")

    # Direction invariance check
    reversed_attacks = {(b, a) for a, b in attacks}
    cf_rev = conflict_free_complex(args, reversed_attacks)
    print(f"\nDirection invariance: reversed complex has {len(cf_rev)} faces", end="")
    if len(cf_rev) == len(cf):
        print(" ✓ (same count, as proved)")
    else:
        print(" ✗ (BUG — should always match)")


if __name__ == "__main__":
    print("THE TOPOLOGY OF ARGUMENTATION")
    print("Demonstrating formally verified properties")

    # Example 1: Trivial framework (counterexample to Euler conjecture)
    print_framework("Trivial (Fin 1, no attacks)",
                    {0}, set())

    # Example 2: Mutual attack
    print_framework("Mutual attack (a ↔ b)",
                    {0, 1}, {(0, 1), (1, 0)})

    # Example 3: Linear chain a → b → c
    print_framework("Linear chain (a→b→c)",
                    {0, 1, 2}, {(0, 1), (1, 2)})

    # Example 4: Odd cycle a → b → c → a
    print_framework("Odd cycle (a→b→c→a)",
                    {0, 1, 2}, {(0, 1), (1, 2), (2, 0)})

    # Example 5: Self-attack
    print_framework("Self-attack (a attacks itself)",
                    {0, 1}, {(0, 0)})

    # Example 6: Nixon diamond
    print_framework("Nixon diamond (a↔b, c→a, c→b)",
                    {0, 1, 2}, {(0, 1), (1, 0), (2, 0), (2, 1)})

    # Example 7: Larger framework
    print_framework("Pentagon (5-cycle)",
                    {0, 1, 2, 3, 4},
                    {(0, 1), (1, 2), (2, 3), (3, 4), (4, 0)})

    # Summary
    print(f"\n{'='*60}")
    print("SUMMARY OF FORMALLY VERIFIED RESULTS:")
    print("1. Conflict-free sets form a simplicial complex (subset-closed)")
    print("2. Self-attacking arguments are excluded from all admissible sets")
    print("3. The Euler characteristic conjecture is FALSE")
    print("4. The conflict-free complex is direction-invariant")
    print("5. Defense is monotone: larger sets defend more arguments")
    print("6. Isolated vertices make the complex a cone")
    print("7. Admissible sets grow by inserting defended, compatible arguments")


#!/usr/bin/env python3
"""
Visualization: The conflict-free complex of argumentation frameworks.
Produces a Hasse diagram of the face lattice.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from itertools import combinations
from typing import Set, FrozenSet, List, Tuple, Dict
from collections import defaultdict
import numpy as np


def conflict_free_sets(args, attacks):
    attack_set = set(attacks)
    result = []
    args_list = sorted(args)
    for r in range(len(args_list) + 1):
        for combo in combinations(args_list, r):
            S = frozenset(combo)
            conflict = False
            for a in S:
                for b in S:
                    if (a, b) in attack_set:
                        conflict = True
                        break
                if conflict:
                    break
            if not conflict:
                result.append(S)
    return result


def admissible_check(S, attacks, attacked_by):
    attack_set = set(attacks)
    for a in S:
        for b in attacked_by.get(a, set()):
            if not any((c, b) in attack_set for c in S):
                return False
    return True


def preferred_exts(args, attacks):
    attacked_by = defaultdict(set)
    for a, b in attacks:
        attacked_by[b].add(a)
    attack_set = set(attacks)
    cf = conflict_free_sets(args, attacks)
    adm = [S for S in cf if admissible_check(S, attacks, attacked_by)]
    return [S for S in adm if not any(S < T for T in adm)]


def plot_framework(ax, name, args, attacks):
    cf = conflict_free_sets(args, attacks)
    pref = preferred_exts(args, attacks)

    # Group by dimension
    by_dim = defaultdict(list)
    for f in cf:
        by_dim[len(f)].append(f)

    max_dim = max(by_dim.keys())

    # Position faces
    positions = {}
    for dim, faces in sorted(by_dim.items()):
        n = len(faces)
        for i, face in enumerate(faces):
            x = (i - (n - 1) / 2) * 1.5
            y = dim * 1.5
            positions[face] = (x, y)

    # Draw edges (face relations)
    for f1 in cf:
        for f2 in cf:
            if len(f2) == len(f1) + 1 and f1 < f2:
                x1, y1 = positions[f1]
                x2, y2 = positions[f2]
                ax.plot([x1, x2], [y1, y2], 'k-', alpha=0.3, linewidth=0.8)

    # Draw faces
    for face in cf:
        x, y = positions[face]
        is_pref = face in pref
        is_admissible = admissible_check(face, attacks,
            {b: {a for a2, b2 in attacks if b2 == b for a in [a2]} for _, b in attacks})

        color = '#2ecc71' if is_pref else ('#3498db' if is_admissible else '#ecf0f1')
        edge_color = '#27ae60' if is_pref else ('#2980b9' if is_admissible else '#bdc3c7')

        label = '∅' if not face else '{' + ','.join(str(x) for x in sorted(face)) + '}'

        ax.plot(x, y, 'o', markersize=20, color=color,
                markeredgecolor=edge_color, markeredgewidth=2, zorder=5)
        ax.text(x, y, label, ha='center', va='center', fontsize=7,
                fontweight='bold' if is_pref else 'normal', zorder=6)

    # Compute Euler characteristic
    chi = sum((-1) ** (len(f) - 1) for f in cf)

    ax.set_title(f'{name}\n|faces|={len(cf)}, χ={chi}, |pref|={len(pref)}',
                 fontsize=10, fontweight='bold')
    ax.set_xlim(-max(3, max_dim * 2), max(3, max_dim * 2))
    ax.set_ylim(-0.5, max_dim * 1.5 + 0.5)
    ax.axis('off')


def main():
    fig, axes = plt.subplots(2, 3, figsize=(18, 12))
    fig.suptitle('The Topology of Argumentation:\nConflict-Free Complexes as Hasse Diagrams',
                 fontsize=16, fontweight='bold')

    frameworks = [
        ("Trivial (1 arg)", {0}, set()),
        ("Mutual attack", {0, 1}, {(0, 1), (1, 0)}),
        ("Chain a→b→c", {0, 1, 2}, {(0, 1), (1, 2)}),
        ("3-cycle", {0, 1, 2}, {(0, 1), (1, 2), (2, 0)}),
        ("Self-attack", {0, 1}, {(0, 0)}),
        ("Nixon diamond", {0, 1, 2}, {(0, 1), (1, 0), (2, 0), (2, 1)}),
    ]

    for ax, (name, args, attacks) in zip(axes.flat, frameworks):
        plot_framework(ax, name, args, attacks)

    # Legend
    legend_elements = [
        mpatches.Patch(color='#2ecc71', label='Preferred extension'),
        mpatches.Patch(color='#3498db', label='Admissible (not preferred)'),
        mpatches.Patch(color='#ecf0f1', label='Conflict-free only'),
    ]
    fig.legend(handles=legend_elements, loc='lower center', ncol=3, fontsize=12)

    plt.tight_layout(rect=[0, 0.05, 1, 0.93])
    plt.savefig('argumentation_complex.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved argumentation_complex.png")


if __name__ == "__main__":
    main()
