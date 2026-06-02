#!/usr/bin/env python3
"""
Demo: The Topology of Argumentation — Independence Complex Construction

Demonstrates the key mathematical concepts:
1. Constructing argumentation frameworks
2. Computing conflict-free sets (independence complex)
3. Computing preferred/grounded extensions
4. Computing Euler characteristic
5. Verifying the counterexample to the Euler characteristic conjecture
"""

from itertools import combinations
from typing import Set, FrozenSet, List, Tuple, Dict


def conflict_free(args: Set[int], attacks: Set[Tuple[int, int]], subset: FrozenSet[int]) -> bool:
    """Check if a subset is conflict-free (no internal attacks)."""
    for a in subset:
        for b in subset:
            if (a, b) in attacks:
                return False
    return True


def all_conflict_free_sets(args: Set[int], attacks: Set[Tuple[int, int]]) -> List[FrozenSet[int]]:
    """Compute all conflict-free subsets (the independence complex)."""
    result = []
    for k in range(len(args) + 1):
        for subset in combinations(args, k):
            fs = frozenset(subset)
            if conflict_free(args, attacks, fs):
                result.append(fs)
    return result


def defends(args: Set[int], attacks: Set[Tuple[int, int]],
            S: FrozenSet[int], a: int) -> bool:
    """Check if set S defends argument a."""
    for b in args:
        if (b, a) in attacks:
            # Need some c in S that attacks b
            if not any((c, b) in attacks for c in S):
                return False
    return True


def admissible(args: Set[int], attacks: Set[Tuple[int, int]], S: FrozenSet[int]) -> bool:
    """Check if S is admissible (conflict-free + self-defending)."""
    if not conflict_free(args, attacks, S):
        return False
    for a in S:
        if not defends(args, attacks, S, a):
            return False
    return True


def preferred_extensions(args: Set[int], attacks: Set[Tuple[int, int]]) -> List[FrozenSet[int]]:
    """Compute all preferred extensions (maximal admissible sets)."""
    adm_sets = [fs for fs in all_conflict_free_sets(args, attacks)
                if admissible(args, attacks, fs)]
    # Keep only maximal
    preferred = []
    for S in adm_sets:
        if not any(S < T for T in adm_sets):
            preferred.append(S)
    return preferred


def grounded_extension(args: Set[int], attacks: Set[Tuple[int, int]]) -> FrozenSet[int]:
    """Compute the grounded extension via fixed-point iteration."""
    G = frozenset()
    while True:
        G_new = frozenset(a for a in args if defends(args, attacks, G, a))
        if G_new == G:
            return G
        G = G_new


def f_vector(cf_sets: List[FrozenSet[int]], max_dim: int) -> List[int]:
    """Compute the f-vector: f_k = number of faces with k+1 elements."""
    return [sum(1 for S in cf_sets if len(S) == k + 1) for k in range(max_dim)]


def euler_characteristic(fv: List[int]) -> int:
    """Compute Euler characteristic from f-vector."""
    return sum((-1)**k * fv[k] for k in range(len(fv)))


def print_framework(name: str, args: Set[int], attacks: Set[Tuple[int, int]]):
    """Analyze and print details of an argumentation framework."""
    print(f"\n{'='*60}")
    print(f"Framework: {name}")
    print(f"Arguments: {sorted(args)}")
    print(f"Attacks: {sorted(attacks)}")

    cf_sets = all_conflict_free_sets(args, attacks)
    print(f"\nConflict-free sets ({len(cf_sets)} total):")
    for S in cf_sets:
        print(f"  {set(S) if S else '{}'}")

    pref = preferred_extensions(args, attacks)
    print(f"\nPreferred extensions ({len(pref)}):")
    for S in pref:
        print(f"  {set(S)}")

    ground = grounded_extension(args, attacks)
    print(f"\nGrounded extension: {set(ground)} (size {len(ground)})")

    fv = f_vector(cf_sets, len(args))
    print(f"\nf-vector: {fv}")

    chi = euler_characteristic(fv)
    print(f"Euler characteristic: χ = {chi}")

    conjecture_value = len(pref) - len(ground)
    print(f"\nConjecture prediction: |pref| - |grounded| = {len(pref)} - {len(ground)} = {conjecture_value}")
    print(f"Actual χ = {chi}")
    if chi == conjecture_value:
        print("✓ Conjecture holds for this framework")
    else:
        print(f"✗ CONJECTURE FAILS: {chi} ≠ {conjecture_value}")


if __name__ == "__main__":
    print("=" * 60)
    print("THE TOPOLOGY OF ARGUMENTATION")
    print("Independence Complex Analysis")
    print("=" * 60)

    # Example 1: The counterexample (two arguments, one attack)
    print_framework(
        "Two-argument counterexample",
        {0, 1},
        {(0, 1)}
    )

    # Example 2: Triangle of mutual attacks
    print_framework(
        "Triangle of attacks (a→b→c→a)",
        {0, 1, 2},
        {(0, 1), (1, 2), (2, 0)}
    )

    # Example 3: Two independent debates
    print_framework(
        "Two independent debates",
        {0, 1, 2, 3},
        {(0, 1), (2, 3)}
    )

    # Example 4: Star attack (one central argument attacks all)
    print_framework(
        "Star attack (0 attacks all)",
        {0, 1, 2, 3},
        {(0, 1), (0, 2), (0, 3)}
    )

    # Example 5: Complete mutual attack (everyone attacks everyone)
    print_framework(
        "Complete mutual attack",
        {0, 1, 2},
        {(0, 1), (1, 0), (0, 2), (2, 0), (1, 2), (2, 1)}
    )

    # Example 6: Even cycle (4 arguments)
    print_framework(
        "4-cycle",
        {0, 1, 2, 3},
        {(0, 1), (1, 2), (2, 3), (3, 0)}
    )

    # Summary: test the conjecture on many random frameworks
    print(f"\n{'='*60}")
    print("CONJECTURE TEST: Checking 100 random frameworks")
    print("=" * 60)

    import random
    random.seed(42)

    holds = 0
    fails = 0
    for trial in range(100):
        n = random.randint(2, 6)
        args = set(range(n))
        attacks = set()
        for a in args:
            for b in args:
                if a != b and random.random() < 0.3:
                    attacks.add((a, b))

        cf_sets = all_conflict_free_sets(args, attacks)
        pref = preferred_extensions(args, attacks)
        ground = grounded_extension(args, attacks)
        fv = f_vector(cf_sets, n)
        chi = euler_characteristic(fv)
        conjecture_value = len(pref) - len(ground)

        if chi == conjecture_value:
            holds += 1
        else:
            fails += 1

    print(f"Conjecture holds: {holds}/100")
    print(f"Conjecture fails: {fails}/100")
    print(f"\nConclusion: The Euler characteristic conjecture is {'VALID' if fails == 0 else 'FALSE'}")
    print(f"(Failed in {fails}% of random frameworks)")


#!/usr/bin/env python3
"""
Visualization: Independence Complex of Argumentation Frameworks

Generates matplotlib visualizations of argumentation frameworks and their
independence complexes, including f-vectors and Euler characteristics.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import combinations
from typing import Set, FrozenSet, List, Tuple, Dict
import math


def is_conflict_free(attacks: Set[Tuple[int, int]], subset: FrozenSet[int]) -> bool:
    for a in subset:
        for b in subset:
            if (a, b) in attacks:
                return False
    return True


def all_conflict_free_sets(args: Set[int], attacks: Set[Tuple[int, int]]) -> List[FrozenSet[int]]:
    result = []
    for k in range(len(args) + 1):
        for subset in combinations(sorted(args), k):
            fs = frozenset(subset)
            if is_conflict_free(attacks, fs):
                result.append(fs)
    return result


def defends(args: Set[int], attacks: Set[Tuple[int, int]], S: FrozenSet[int], a: int) -> bool:
    for b in args:
        if (b, a) in attacks:
            if not any((c, b) in attacks for c in S):
                return False
    return True


def is_admissible(args: Set[int], attacks: Set[Tuple[int, int]], S: FrozenSet[int]) -> bool:
    if not is_conflict_free(attacks, S):
        return False
    return all(defends(args, attacks, S, a) for a in S)


def preferred_extensions(args: Set[int], attacks: Set[Tuple[int, int]]) -> List[FrozenSet[int]]:
    cf = all_conflict_free_sets(args, attacks)
    adm = [S for S in cf if is_admissible(args, attacks, S)]
    return [S for S in adm if not any(S < T for T in adm)]


def grounded_extension(args: Set[int], attacks: Set[Tuple[int, int]]) -> FrozenSet[int]:
    G = frozenset()
    for _ in range(len(args) + 1):
        G_new = frozenset(a for a in args if defends(args, attacks, G, a))
        if G_new == G:
            return G
        G = G_new
    return G


def f_vector(cf_sets: List[FrozenSet[int]], max_dim: int) -> List[int]:
    return [sum(1 for S in cf_sets if len(S) == k + 1) for k in range(max_dim)]


def euler_char(fv: List[int]) -> int:
    return sum((-1)**k * fv[k] for k in range(len(fv)))


def plot_framework_analysis(ax_graph, ax_complex, ax_fvec,
                             name: str, args: Set[int],
                             attacks: Set[Tuple[int, int]]):
    """Plot a complete analysis of one framework across three axes."""
    n = len(args)
    args_list = sorted(args)

    # Positions for arguments in a circle
    angles = [2 * math.pi * i / n for i in range(n)]
    pos = {a: (math.cos(angles[i]), math.sin(angles[i]))
           for i, a in enumerate(args_list)}

    # Plot 1: Attack graph
    ax_graph.set_xlim(-1.5, 1.5)
    ax_graph.set_ylim(-1.5, 1.5)
    ax_graph.set_aspect('equal')
    ax_graph.set_title(f'{name}\nAttack Graph', fontsize=10, fontweight='bold')

    # Draw attacks as arrows
    for (a, b) in attacks:
        dx = pos[b][0] - pos[a][0]
        dy = pos[b][1] - pos[a][1]
        length = math.sqrt(dx**2 + dy**2)
        if length > 0:
            # Shorten arrow to not overlap with nodes
            shrink = 0.15
            ax_graph.annotate('', xy=(pos[b][0] - shrink*dx/length,
                                       pos[b][1] - shrink*dy/length),
                             xytext=(pos[a][0] + shrink*dx/length,
                                      pos[a][1] + shrink*dy/length),
                             arrowprops=dict(arrowstyle='->', color='red',
                                            lw=1.5, mutation_scale=15))

    # Draw argument nodes
    for a in args_list:
        circle = plt.Circle(pos[a], 0.12, color='steelblue', zorder=5)
        ax_graph.add_patch(circle)
        ax_graph.text(pos[a][0], pos[a][1], str(a), ha='center', va='center',
                     fontsize=10, fontweight='bold', color='white', zorder=6)

    ax_graph.axis('off')

    # Compute analysis
    cf_sets = all_conflict_free_sets(args, attacks)
    pref = preferred_extensions(args, attacks)
    ground = grounded_extension(args, attacks)
    fv = f_vector(cf_sets, n)
    chi = euler_char(fv)

    # Plot 2: Independence complex summary
    ax_complex.axis('off')
    ax_complex.set_title('Independence Complex', fontsize=10, fontweight='bold')

    text_lines = [
        f'Conflict-free sets: {len(cf_sets)}',
        f'Preferred ext: {len(pref)}',
        f'Grounded ext size: {len(ground)}',
        f'',
        f'f-vector: {fv}',
        f'Euler char χ = {chi}',
        f'',
        f'Conjecture: {len(pref)}-{len(ground)} = {len(pref)-len(ground)}',
        f'{"✓ HOLDS" if chi == len(pref)-len(ground) else "✗ FAILS (χ="+str(chi)+")"}'
    ]

    for i, line in enumerate(text_lines):
        color = 'green' if '✓' in line else ('red' if '✗' in line else 'black')
        ax_complex.text(0.1, 0.9 - i * 0.1, line, fontsize=9,
                       transform=ax_complex.transAxes, color=color,
                       fontfamily='monospace')

    # Plot 3: f-vector bar chart
    if fv:
        colors = ['steelblue' if k % 2 == 0 else 'coral' for k in range(len(fv))]
        bars = ax_fvec.bar(range(len(fv)), fv, color=colors, edgecolor='black', linewidth=0.5)
        ax_fvec.set_xlabel('Dimension k', fontsize=9)
        ax_fvec.set_ylabel('f_k', fontsize=9)
        ax_fvec.set_title(f'f-vector (χ = {chi})', fontsize=10, fontweight='bold')
        ax_fvec.set_xticks(range(len(fv)))

        # Add value labels
        for bar, val in zip(bars, fv):
            if val > 0:
                ax_fvec.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.1,
                           str(val), ha='center', va='bottom', fontsize=8)


def main():
    frameworks = [
        ("Counterexample\n(0→1)", {0, 1}, {(0, 1)}),
        ("Triangle\n(0→1→2→0)", {0, 1, 2}, {(0, 1), (1, 2), (2, 0)}),
        ("Two debates\n(0→1, 2→3)", {0, 1, 2, 3}, {(0, 1), (2, 3)}),
        ("Star\n(0→1,2,3)", {0, 1, 2, 3}, {(0, 1), (0, 2), (0, 3)}),
        ("Mutual\n(all attack all)", {0, 1, 2},
         {(0,1),(1,0),(0,2),(2,0),(1,2),(2,1)}),
        ("4-cycle\n(0→1→2→3→0)", {0, 1, 2, 3}, {(0,1),(1,2),(2,3),(3,0)}),
    ]

    fig, axes = plt.subplots(len(frameworks), 3, figsize=(14, 4*len(frameworks)))

    for i, (name, args, attacks) in enumerate(frameworks):
        plot_framework_analysis(axes[i, 0], axes[i, 1], axes[i, 2],
                               name, args, attacks)

    plt.suptitle('The Topology of Argumentation: Independence Complex Analysis',
                fontsize=14, fontweight='bold', y=1.01)
    plt.tight_layout()
    plt.savefig('argumentation_topology.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: argumentation_topology.png")

    # === Conjecture failure rate plot ===
    import random
    random.seed(42)

    results = {'n': [], 'holds': [], 'fails': []}
    for n in range(2, 8):
        h, f = 0, 0
        for _ in range(200):
            args = set(range(n))
            attacks = set()
            for a in args:
                for b in args:
                    if a != b and random.random() < 0.3:
                        attacks.add((a, b))
            cf = all_conflict_free_sets(args, attacks)
            pref = preferred_extensions(args, attacks)
            ground = grounded_extension(args, attacks)
            fv = f_vector(cf, n)
            chi = euler_char(fv)
            if chi == len(pref) - len(ground):
                h += 1
            else:
                f += 1
        results['n'].append(n)
        results['holds'].append(h)
        results['fails'].append(f)

    fig2, ax = plt.subplots(figsize=(8, 5))
    x = np.array(results['n'])
    holds = np.array(results['holds'])
    fails = np.array(results['fails'])

    ax.bar(x - 0.2, holds, 0.4, label='Conjecture holds', color='steelblue')
    ax.bar(x + 0.2, fails, 0.4, label='Conjecture fails', color='coral')
    ax.set_xlabel('Number of arguments |A|', fontsize=12)
    ax.set_ylabel('Count (out of 200 trials)', fontsize=12)
    ax.set_title('Euler Characteristic Conjecture: Failure Rate by Framework Size',
                fontsize=13, fontweight='bold')
    ax.legend(fontsize=11)
    ax.set_xticks(x)

    plt.tight_layout()
    plt.savefig('conjecture_failure_rate.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: conjecture_failure_rate.png")


if __name__ == "__main__":
    main()
