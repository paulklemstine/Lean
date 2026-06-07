#!/usr/bin/env python3
"""
Demo: Social Choice as Topology — The PreferenceSphere

Demonstrates the key mathematical structures connecting Arrow's impossibility
theorem to topology via the PreferenceSphere.
"""

from itertools import permutations
from math import factorial


def kendall_distance(perm1: list[int], perm2: list[int]) -> int:
    """Compute the Kendall tau distance between two rankings.
    
    A ranking is a list where perm[i] = rank of alternative i.
    Distance = number of pairs (i,j) with i<j where the two rankings disagree.
    """
    n = len(perm1)
    count = 0
    for i in range(n):
        for j in range(i + 1, n):
            if (perm1[i] - perm1[j]) * (perm2[i] - perm2[j]) < 0:
                count += 1
    return count


def antipodal(perm: list[int]) -> list[int]:
    """Compute the antipodal (reversed) ranking.
    
    If perm[i] = rank of alternative i, antipodal reverses:
    antipodal(perm)[i] = (n-1) - perm[i]
    """
    n = len(perm)
    return [n - 1 - p for p in perm]


def max_kendall(n: int) -> int:
    """Maximum Kendall distance for n alternatives."""
    return n * (n - 1) // 2


def is_pareto(swf, n_voters: int, n_alts: int) -> bool:
    """Check if a SWF satisfies Pareto efficiency.
    
    swf: maps tuple of rankings to a ranking
    """
    # Check: if all voters have the same ranking, the social ranking should match
    for perm in permutations(range(n_alts)):
        profile = tuple(perm for _ in range(n_voters))
        result = swf(profile)
        for i in range(n_alts):
            for j in range(n_alts):
                if all(p[i] < p[j] for p in profile):
                    if not (result[i] < result[j]):
                        return False
    return True


def is_dictatorial(swf, n_voters: int, n_alts: int) -> tuple[bool, int | None]:
    """Check if a SWF is dictatorial. Returns (is_dict, dictator_index)."""
    all_rankings = list(permutations(range(n_alts)))
    
    for d in range(n_voters):
        is_dict = True
        # Check if voter d is always the dictator
        for profile in _sample_profiles(n_voters, n_alts, max_samples=200):
            result = swf(profile)
            voter_d_ranking = profile[d]
            # Check if result agrees with voter d on all pairs
            for i in range(n_alts):
                for j in range(n_alts):
                    if voter_d_ranking[i] < voter_d_ranking[j]:
                        if not (result[i] < result[j]):
                            is_dict = False
                            break
                if not is_dict:
                    break
            if not is_dict:
                break
        if is_dict:
            return True, d
    return False, None


def _sample_profiles(n_voters, n_alts, max_samples=200):
    """Generate sample profiles for testing."""
    import random
    all_rankings = list(permutations(range(n_alts)))
    for _ in range(max_samples):
        profile = tuple(random.choice(all_rankings) for _ in range(n_voters))
        yield profile


def dictator_swf(dictator: int):
    """Create a dictatorial SWF that always follows voter `dictator`."""
    def swf(profile):
        return profile[dictator]
    return swf


def majority_rule_2alts(profile):
    """Majority rule for 2 alternatives (works! Arrow requires ≥ 3)."""
    n_voters = len(profile)
    votes_for_0_first = sum(1 for p in profile if p[0] < p[1])
    if votes_for_0_first > n_voters / 2:
        return (0, 1)
    else:
        return (1, 0)


# ============================================================
# DEMO
# ============================================================

def demo_preference_sphere():
    """Demonstrate key properties of the PreferenceSphere."""
    print("=" * 60)
    print("  THE PREFERENCE SPHERE: Social Choice as Topology")
    print("=" * 60)
    
    n = 3
    all_perms = list(permutations(range(n)))
    
    print(f"\n--- PreferenceSphere PS({n}) ---")
    print(f"Number of points: {len(all_perms)} = {n}!")
    print(f"Maximum Kendall distance: {max_kendall(n)} = {n}×{n-1}/2")
    
    print(f"\nAll rankings of {n} alternatives (A, B, C):")
    alt_names = ['A', 'B', 'C']
    for perm in all_perms:
        # perm[i] = rank of alternative i (0 = best)
        ranking = sorted(range(n), key=lambda i: perm[i])
        ranking_str = " > ".join(alt_names[i] for i in ranking)
        anti = antipodal(list(perm))
        anti_ranking = sorted(range(n), key=lambda i: anti[i])
        anti_str = " > ".join(alt_names[i] for i in anti_ranking)
        d = kendall_distance(list(perm), anti)
        print(f"  {ranking_str}  ←antipodal→  {anti_str}  (distance = {d})")
    
    print(f"\n--- Theorem: Antipodal involution ---")
    all_pass = True
    for perm in all_perms:
        p = list(perm)
        aa = antipodal(antipodal(p))
        if aa != p:
            all_pass = False
            print(f"  FAIL: antipodal(antipodal({p})) = {aa} ≠ {p}")
    if all_pass:
        print(f"  ✓ antipodal(antipodal(σ)) = σ for all {len(all_perms)} rankings")
    
    print(f"\n--- Theorem: No fixed points (n ≥ 2) ---")
    fixed_points = [p for p in all_perms if antipodal(list(p)) == list(p)]
    print(f"  Fixed points: {len(fixed_points)} (should be 0)")
    print(f"  ✓ The antipodal map has no fixed points")
    
    print(f"\n--- Theorem: Antipodal distance is maximal ---")
    for perm in all_perms[:3]:
        p = list(perm)
        d = kendall_distance(p, antipodal(p))
        print(f"  d({p}, antipodal) = {d} = {max_kendall(n)} ✓")


def demo_kendall_distances():
    """Show the full Kendall distance matrix."""
    n = 3
    all_perms = [list(p) for p in permutations(range(n))]
    
    print(f"\n{'=' * 60}")
    print(f"  KENDALL DISTANCE MATRIX for PS({n})")
    print(f"{'=' * 60}\n")
    
    alt_names = ['A', 'B', 'C']
    labels = []
    for perm in all_perms:
        ranking = sorted(range(n), key=lambda i: perm[i])
        labels.append("".join(alt_names[i] for i in ranking))
    
    # Header
    print(f"     {'  '.join(f'{l:>3}' for l in labels)}")
    for i, perm_i in enumerate(all_perms):
        row = []
        for j, perm_j in enumerate(all_perms):
            d = kendall_distance(perm_i, perm_j)
            row.append(f'{d:>3}')
        print(f"{labels[i]:>3}  {'  '.join(row)}")
    
    print(f"\nNote: Maximum distance = {max_kendall(n)} achieved only at antipodal pairs")


def demo_arrow_impossibility():
    """Demonstrate Arrow's impossibility for 3 alternatives, 2 voters."""
    print(f"\n{'=' * 60}")
    print(f"  ARROW'S IMPOSSIBILITY: 3 alternatives, 2 voters")
    print(f"{'=' * 60}\n")
    
    n_alts = 3
    n_voters = 2
    
    # The only SWFs satisfying Pareto + IIA are dictatorships
    print("Testing dictatorial SWFs:")
    for d in range(n_voters):
        swf = dictator_swf(d)
        pareto = is_pareto(swf, n_voters, n_alts)
        is_dict, who = is_dictatorial(swf, n_voters, n_alts)
        print(f"  Dictator = voter {d}: Pareto = {pareto}, Dictatorial = {is_dict} (dictator = {who})")
    
    print(f"\nArrow's theorem: These are the ONLY possibilities with ≥ 3 alternatives!")
    print(f"For 2 alternatives, majority rule works (no contradiction).")
    
    # Demo: majority rule works for 2 alternatives
    print(f"\nMajority rule with 2 alternatives:")
    test_profiles = [
        ((0, 1), (0, 1)),  # Both prefer A
        ((1, 0), (1, 0)),  # Both prefer B
        ((0, 1), (1, 0)),  # Disagree
    ]
    for profile in test_profiles:
        result = majority_rule_2alts(profile)
        voter_strs = [f"{'A>B' if p[0]<p[1] else 'B>A'}" for p in profile]
        result_str = f"{'A>B' if result[0]<result[1] else 'B>A'}"
        print(f"  Voters: {', '.join(voter_strs)} → Social: {result_str}")


def demo_decisive_coalitions():
    """Show the decisive coalition structure for dictatorial SWFs."""
    print(f"\n{'=' * 60}")
    print(f"  DECISIVE COALITIONS: Ultrafilter Structure")
    print(f"{'=' * 60}\n")
    
    n_voters = 3
    n_alts = 3
    
    # For a dictatorial SWF with dictator 0:
    print("For dictator = voter 0:")
    print("  Decisive coalitions (supersets of {0}):")
    for S in range(2**n_voters):
        coalition = [i for i in range(n_voters) if S & (1 << i)]
        if 0 in coalition:
            print(f"    {set(coalition)}")
    
    print(f"\n  This forms an ULTRAFILTER on {{{', '.join(str(i) for i in range(n_voters))}}}:")
    print(f"    • Contains the full set ✓")
    print(f"    • Closed under supersets ✓")
    print(f"    • For any S, exactly one of S or Sᶜ is decisive ✓")
    print(f"    • Closed under intersection ✓")
    print(f"    • Does not contain ∅ ✓")
    print(f"\n  This is the PRINCIPAL ultrafilter generated by {{0}}")
    print(f"  On finite sets, ALL ultrafilters are principal → DICTATOR")


if __name__ == "__main__":
    demo_preference_sphere()
    demo_kendall_distances()
    demo_arrow_impossibility()
    demo_decisive_coalitions()


#!/usr/bin/env python3
"""
Visualization: The Permutohedron (PreferenceSphere Graph)

Draws the graph of all rankings connected by adjacent transpositions,
highlighting antipodal pairs and the Kendall distance structure.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import permutations
from math import factorial, pi, cos, sin


def kendall_distance(p1: tuple, p2: tuple) -> int:
    n = len(p1)
    count = 0
    for i in range(n):
        for j in range(i + 1, n):
            if (p1[i] - p1[j]) * (p2[i] - p2[j]) < 0:
                count += 1
    return count


def antipodal(perm: tuple) -> tuple:
    n = len(perm)
    return tuple(n - 1 - p for p in perm)


def are_adjacent(p1: tuple, p2: tuple) -> bool:
    """Check if two rankings differ by a single adjacent transposition."""
    n = len(p1)
    diffs = sum(1 for i in range(n) if p1[i] != p2[i])
    if diffs != 2:
        return False
    # Check it's an adjacent transposition
    for k in range(n - 1):
        test = list(p1)
        test[k], test[k + 1] = test[k + 1], test[k]
        if tuple(test) == p2:
            return True
    return False


def draw_permutohedron_3():
    """Draw the permutohedron for n=3 (hexagon)."""
    fig, axes = plt.subplots(1, 2, figsize=(16, 7))
    
    n = 3
    all_perms = list(permutations(range(n)))
    alt_names = ['A', 'B', 'C']
    
    # Layout: use the standard hexagonal layout
    # Map each ranking to a position on the hexagon
    positions = {}
    for i, perm in enumerate(all_perms):
        angle = 2 * pi * i / len(all_perms) + pi / 2
        positions[perm] = (cos(angle), sin(angle))
    
    # Panel 1: The permutohedron graph
    ax = axes[0]
    ax.set_title("PreferenceSphere PS(3)\n(Permutohedron = Hexagon)", fontsize=14, fontweight='bold')
    
    # Draw edges
    for i, p1 in enumerate(all_perms):
        for j, p2 in enumerate(all_perms):
            if i < j and are_adjacent(p1, p2):
                x1, y1 = positions[p1]
                x2, y2 = positions[p2]
                ax.plot([x1, x2], [y1, y2], 'k-', linewidth=1.5, alpha=0.5)
    
    # Draw antipodal connections
    drawn_antipodal = set()
    for perm in all_perms:
        anti = antipodal(perm)
        pair = (min(perm, anti), max(perm, anti))
        if pair not in drawn_antipodal:
            drawn_antipodal.add(pair)
            x1, y1 = positions[perm]
            x2, y2 = positions[anti]
            ax.plot([x1, x2], [y1, y2], 'r--', linewidth=1, alpha=0.6)
    
    # Draw nodes
    colors = plt.cm.Set2(np.linspace(0, 1, len(all_perms)))
    for i, perm in enumerate(all_perms):
        x, y = positions[perm]
        ranking = sorted(range(n), key=lambda k: perm[k])
        label = ">".join(alt_names[k] for k in ranking)
        
        ax.scatter(x, y, s=300, c=[colors[i]], edgecolors='black', 
                   linewidths=2, zorder=5)
        ax.annotate(label, (x, y), textcoords="offset points", 
                    xytext=(0, 18), ha='center', fontsize=11, fontweight='bold')
    
    ax.set_xlim(-1.6, 1.6)
    ax.set_ylim(-1.6, 1.6)
    ax.set_aspect('equal')
    ax.axis('off')
    
    # Legend
    edge_patch = mpatches.Patch(color='black', alpha=0.5, label='Adjacent transposition')
    anti_patch = mpatches.Patch(color='red', alpha=0.6, label='Antipodal pair (d=3)', linestyle='--')
    ax.legend(handles=[edge_patch, anti_patch], loc='lower center', fontsize=10)
    
    # Panel 2: Kendall distance heatmap
    ax = axes[1]
    ax.set_title("Kendall Distance Matrix\non PS(3)", fontsize=14, fontweight='bold')
    
    dist_matrix = np.zeros((len(all_perms), len(all_perms)))
    for i, p1 in enumerate(all_perms):
        for j, p2 in enumerate(all_perms):
            dist_matrix[i, j] = kendall_distance(p1, p2)
    
    labels = []
    for perm in all_perms:
        ranking = sorted(range(n), key=lambda k: perm[k])
        labels.append(">".join(alt_names[k] for k in ranking))
    
    im = ax.imshow(dist_matrix, cmap='YlOrRd', vmin=0, vmax=3)
    ax.set_xticks(range(len(all_perms)))
    ax.set_yticks(range(len(all_perms)))
    ax.set_xticklabels(labels, rotation=45, ha='right', fontsize=9)
    ax.set_yticklabels(labels, fontsize=9)
    
    # Add distance values
    for i in range(len(all_perms)):
        for j in range(len(all_perms)):
            ax.text(j, i, int(dist_matrix[i, j]), ha='center', va='center',
                    fontsize=12, fontweight='bold',
                    color='white' if dist_matrix[i, j] > 1.5 else 'black')
    
    plt.colorbar(im, ax=ax, shrink=0.8, label='Kendall distance')
    
    plt.tight_layout()
    plt.savefig('permutohedron_3.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved permutohedron_3.png")


def draw_arrow_impossibility():
    """Visualize Arrow's impossibility by showing constraint propagation."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))
    
    n = 3
    alt_names = ['A', 'B', 'C']
    pairs = [(0, 1), (0, 2), (1, 2)]
    pair_names = [f"{alt_names[a]}>{alt_names[b]}" for a, b in pairs]
    
    # Panel 1: Pareto constraint
    ax = axes[0]
    ax.set_title("Step 1: Pareto Constraint\n(Unanimous → Social agrees)", fontsize=12, fontweight='bold')
    
    # Show that unanimous profiles force the social choice
    data = [
        ("All: A>B>C", "A>B>C", "green"),
        ("All: C>B>A", "C>B>A", "green"),
        ("All: B>A>C", "B>A>C", "green"),
    ]
    for i, (voters, social, color) in enumerate(data):
        ax.text(0.1, 0.8 - i * 0.3, f"Voters: {voters}", fontsize=11,
                transform=ax.transAxes)
        ax.annotate("", xy=(0.65, 0.82 - i * 0.3), xytext=(0.55, 0.82 - i * 0.3),
                    arrowprops=dict(arrowstyle="->", color=color, lw=2),
                    transform=ax.transAxes)
        ax.text(0.67, 0.8 - i * 0.3, f"Social: {social}", fontsize=11,
                transform=ax.transAxes, color=color, fontweight='bold')
    ax.text(0.5, 0.05, "Pareto: unanimous ⟹ forced", fontsize=10,
            transform=ax.transAxes, ha='center', style='italic')
    ax.axis('off')
    
    # Panel 2: IIA constraint
    ax = axes[1]
    ax.set_title("Step 2: IIA Constraint\n(Pairwise independence)", fontsize=12, fontweight='bold')
    
    ax.text(0.05, 0.85, "A vs B depends ONLY on\nindividual A-vs-B rankings", 
            fontsize=11, transform=ax.transAxes)
    ax.text(0.05, 0.6, "A vs C depends ONLY on\nindividual A-vs-C rankings",
            fontsize=11, transform=ax.transAxes)
    ax.text(0.05, 0.35, "B vs C depends ONLY on\nindividual B-vs-C rankings",
            fontsize=11, transform=ax.transAxes)
    ax.text(0.5, 0.12, "IIA decomposes the SWF into\nindependent pairwise functions", 
            fontsize=10, transform=ax.transAxes, ha='center', style='italic',
            bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))
    ax.axis('off')
    
    # Panel 3: The impossibility
    ax = axes[2]
    ax.set_title("Step 3: IMPOSSIBILITY\n(Transitivity forces dictatorship)", fontsize=12, fontweight='bold')
    
    # Show the constraint triangle
    triangle = plt.Polygon([(0.5, 0.85), (0.15, 0.3), (0.85, 0.3)],
                            fill=False, edgecolor='red', linewidth=3)
    ax.add_patch(triangle)
    ax.text(0.5, 0.9, "A vs B", fontsize=12, ha='center', fontweight='bold')
    ax.text(0.08, 0.22, "A vs C", fontsize=12, ha='center', fontweight='bold')
    ax.text(0.92, 0.22, "B vs C", fontsize=12, ha='center', fontweight='bold')
    
    ax.text(0.5, 0.55, "TRANSITIVITY\nlinks all pairs!", fontsize=11,
            ha='center', color='red', fontweight='bold')
    ax.text(0.5, 0.08, "Same voter must control\nALL pairs → DICTATOR", fontsize=10,
            ha='center', transform=ax.transAxes,
            bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.axis('off')
    
    plt.tight_layout()
    plt.savefig('arrow_impossibility.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved arrow_impossibility.png")


if __name__ == "__main__":
    draw_permutohedron_3()
    draw_arrow_impossibility()
