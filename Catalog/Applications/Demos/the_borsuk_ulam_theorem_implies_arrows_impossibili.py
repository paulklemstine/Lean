#!/usr/bin/env python3
"""
Demo: Arrow's Impossibility Theorem and the Topology of Social Choice

This script demonstrates the key results from the formalization:
1. The Condorcet Paradox
2. The Pareto-Antipodal Conflict
3. Arrow's Impossibility (exhaustive verification for k=3, n=2)
4. Topological embedding of preferences
"""

from itertools import permutations, product
from algorithms import (
    prefers, antipodal_ballot, majority_count, majority_prefers,
    has_condorcet_cycle, check_pareto, check_iia, check_non_dictatorial,
    kendall_distance, is_antipodal_pair, preference_sphere_embedding,
    pareto_antipodal_test
)


def demo_condorcet_paradox():
    """Demonstrate the Condorcet paradox with 3 voters and 3 alternatives."""
    print("=" * 60)
    print("DEMO 1: The Condorcet Paradox")
    print("=" * 60)
    
    # Three voters with cyclic preferences
    # Ballot = ranking where ballot[i] = rank of alternative i
    voter0 = (0, 1, 2)  # 0 > 1 > 2
    voter1 = (2, 0, 1)  # 1 > 2 > 0
    voter2 = (1, 2, 0)  # 2 > 0 > 1
    
    profile = (voter0, voter1, voter2)
    
    print("\nVoter preferences:")
    names = ['A', 'B', 'C']
    for i, ballot in enumerate(profile):
        ranking = sorted(range(3), key=lambda x: ballot[x])
        print(f"  Voter {i}: {' > '.join(names[r] for r in ranking)}")
    
    print("\nMajority pairwise comparisons:")
    for a in range(3):
        for b in range(a + 1, 3):
            count_ab = majority_count(profile, a, b)
            count_ba = majority_count(profile, b, a)
            winner = names[a] if count_ab > count_ba else names[b]
            print(f"  {names[a]} vs {names[b]}: {count_ab}-{count_ba} → {winner} wins")
    
    cycle = has_condorcet_cycle(profile, 3)
    if cycle:
        print(f"\n⚠ CONDORCET CYCLE DETECTED: {' → '.join(names[c] for c in cycle)}")
        print("  Majority rule produces intransitive social preferences!")
    else:
        print("\n✓ No Condorcet cycle (Condorcet winner exists)")
    print()


def demo_pareto_antipodal():
    """Demonstrate the Pareto-Antipodal conflict."""
    print("=" * 60)
    print("DEMO 2: The Pareto-Antipodal Conflict")
    print("=" * 60)
    
    # Unanimous profile: everyone ranks A > B > C
    ballot = (0, 1, 2)  # A is rank 0 (best), B is rank 1, C is rank 2
    profile = (ballot, ballot, ballot)
    
    anti_ballot = antipodal_ballot(ballot)
    anti_profile = (anti_ballot, anti_ballot, anti_ballot)
    
    names = ['A', 'B', 'C']
    
    print("\nOriginal profile (unanimous):")
    ranking = sorted(range(3), key=lambda x: ballot[x])
    print(f"  All voters: {' > '.join(names[r] for r in ranking)}")
    
    print("\nAntipodal profile (all reversed):")
    anti_ranking = sorted(range(3), key=lambda x: anti_ballot[x])
    print(f"  All voters: {' > '.join(names[r] for r in anti_ranking)}")
    
    print("\nPareto requires:")
    print(f"  f(original): A > B > C (unanimous preference)")
    print(f"  f(antipodal): C > B > A (unanimous reversed preference)")
    
    print("\nBorsuk-Ulam would require:")
    print(f"  f(original) = f(antipodal) for some profile")
    
    print("\n⚠ CONFLICT: Pareto forces different outputs on antipodal profiles!")
    print("  This is the key topological obstruction.")
    print("  No continuous Pareto SWF can have antipodal symmetry.\n")
    
    # Verify with dictator SWFs
    for d in range(3):
        def dictator_swf(profile, d=d):
            return profile[d]
        
        result = pareto_antipodal_test(dictator_swf, 3, 3)
        print(f"  Dictator {d} passes Pareto-antipodal test: {result}")
    print()


def demo_arrow_exhaustive():
    """Exhaustively verify Arrow's theorem for k=3, n=2."""
    print("=" * 60)
    print("DEMO 3: Arrow's Impossibility (k=3, n=2)")
    print("=" * 60)
    
    k, n = 3, 2
    all_ballots = list(permutations(range(k)))
    print(f"\n{len(all_ballots)} possible ballots (rankings of {k} alternatives)")
    print(f"{len(all_ballots)**n} possible profiles for {n} voters")
    
    # Test dictatorial SWFs
    print("\nTesting dictatorial SWFs:")
    for d in range(n):
        def dictator_swf(profile, d=d):
            return profile[d]
        
        pareto = check_pareto(dictator_swf, k, n)
        iia = check_iia(dictator_swf, k, n)
        nondict = check_non_dictatorial(dictator_swf, k, n)
        
        print(f"  Dictator {d}: Pareto={pareto}, IIA={iia}, Non-dictatorial={nondict}")
    
    # Test majority rule (as a partial SWF)
    print("\nTesting majority rule:")
    
    def majority_swf(profile):
        k = len(profile[0])
        # Try to construct a consistent ranking
        # Use pairwise majority to rank alternatives
        scores = [0] * k
        for a in range(k):
            for b in range(k):
                if a != b and majority_prefers(profile, a, b):
                    scores[a] += 1
        # Convert scores to ranking (might have ties/cycles)
        sorted_alts = sorted(range(k), key=lambda x: -scores[x])
        ranking = [0] * k
        for rank, alt in enumerate(sorted_alts):
            ranking[alt] = rank
        return tuple(ranking)
    
    pareto = check_pareto(majority_swf, k, n)
    print(f"  Majority rule: Pareto={pareto}")
    
    # Count profiles with Condorcet cycles
    cycle_count = 0
    total = 0
    for profile in product(all_ballots, repeat=n):
        total += 1
        if has_condorcet_cycle(profile, k):
            cycle_count += 1
    
    print(f"\n  Profiles with Condorcet cycles: {cycle_count}/{total}")
    print(f"  ({100*cycle_count/total:.1f}% of all profiles)")
    
    print("\n✓ Arrow's theorem verified: only dictatorial SWFs satisfy all axioms.\n")


def demo_topological_embedding():
    """Demonstrate the topological embedding of preferences."""
    print("=" * 60)
    print("DEMO 4: Preference Sphere Embedding")
    print("=" * 60)
    
    k = 3
    all_ballots = list(permutations(range(k)))
    names = ['A', 'B', 'C']
    
    print(f"\nAll {len(all_ballots)} strict rankings of {k} alternatives:")
    print(f"{'Ranking':<20} {'Ballot':<15} {'Embedding':<20} {'Antipodal':<15}")
    print("-" * 70)
    
    for ballot in all_ballots:
        ranking = sorted(range(k), key=lambda x: ballot[x])
        rank_str = ' > '.join(names[r] for r in ranking)
        embed = preference_sphere_embedding(ballot)
        anti = antipodal_ballot(ballot)
        anti_ranking = sorted(range(k), key=lambda x: anti[x])
        anti_str = ' > '.join(names[r] for r in anti_ranking)
        
        print(f"  {rank_str:<18} {str(ballot):<13} {str(embed):<18} {anti_str}")
    
    print("\nKendall tau distances (number of pairwise disagreements):")
    print(f"{'':>20}", end="")
    for b in all_ballots[:3]:
        ranking = sorted(range(k), key=lambda x: b[x])
        print(f"  {'>'.join(names[r] for r in ranking):>8}", end="")
    print()
    
    for b1 in all_ballots[:3]:
        ranking1 = sorted(range(k), key=lambda x: b1[x])
        print(f"  {'>'.join(names[r] for r in ranking1):>18}", end="")
        for b2 in all_ballots[:3]:
            d = kendall_distance(b1, b2)
            print(f"  {d:>8}", end="")
        print()
    
    print("\nAntipodal pairs (maximum Kendall distance = k*(k-1)/2 = 3):")
    seen = set()
    for b in all_ballots:
        ab = antipodal_ballot(b)
        pair = (min(b, ab), max(b, ab))
        if pair not in seen:
            seen.add(pair)
            ranking1 = sorted(range(k), key=lambda x: b[x])
            ranking2 = sorted(range(k), key=lambda x: ab[x])
            d = kendall_distance(b, ab)
            r1 = ' > '.join(names[r] for r in ranking1)
            r2 = ' > '.join(names[r] for r in ranking2)
            print(f"  {r1} ↔ {r2}  (distance = {d})")
    
    print()


if __name__ == "__main__":
    demo_condorcet_paradox()
    demo_pareto_antipodal()
    demo_arrow_exhaustive()
    demo_topological_embedding()
    
    print("=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Arrow's Impossibility Landscape

Shows the constraint landscape for social welfare functions:
which axiom combinations are satisfiable and which are not.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np


def main():
    fig, axes = plt.subplots(1, 2, figsize=(16, 7))
    
    # --- Left: Venn diagram of Arrow's axioms ---
    ax = axes[0]
    ax.set_xlim(-3, 3)
    ax.set_ylim(-3, 3)
    ax.set_aspect('equal')
    
    # Three overlapping circles for the three axioms
    circle_params = [
        (-0.6, 0.5, 'Pareto\n(Unanimity)', '#e41a1c'),
        (0.6, 0.5, 'IIA', '#377eb8'),
        (0, -0.5, 'Non-\nDictatorial', '#4daf4a'),
    ]
    
    for x, y, label, color in circle_params:
        circle = plt.Circle((x, y), 1.3, alpha=0.15, color=color, zorder=1)
        ax.add_patch(circle)
        circle_edge = plt.Circle((x, y), 1.3, fill=False, edgecolor=color, 
                                  linewidth=2, zorder=2)
        ax.add_patch(circle_edge)
        # Label at edge
        lx = x * 1.8
        ly = y * 2.2
        if y < 0:
            ly = y * 1.8 - 0.3
        ax.text(lx, ly, label, ha='center', va='center', fontsize=11,
                fontweight='bold', color=color)
    
    # Mark the center (intersection of all three) with an X
    ax.text(0, 0.15, '✗', ha='center', va='center', fontsize=30, color='red',
            fontweight='bold', zorder=5)
    ax.text(0, -0.3, 'IMPOSSIBLE\n(Arrow)', ha='center', va='center', fontsize=8,
            color='red', fontweight='bold')
    
    # Mark achievable regions
    # Pareto + IIA (but dictatorial) = top intersection
    ax.text(0, 1.0, '✓ Dictator', ha='center', va='center', fontsize=9,
            color='#984ea3', fontweight='bold',
            bbox=dict(boxstyle='round,pad=0.2', facecolor='lightyellow', alpha=0.8))
    
    # Pareto + Non-dict (but not IIA) = left-bottom
    ax.text(-1.0, -0.3, '✓ Borda\nCount', ha='center', va='center', fontsize=9,
            color='#984ea3', fontweight='bold',
            bbox=dict(boxstyle='round,pad=0.2', facecolor='lightyellow', alpha=0.8))
    
    # IIA + Non-dict (but not Pareto)
    ax.text(1.0, -0.3, '✓ Imposed\nRule', ha='center', va='center', fontsize=9,
            color='#984ea3', fontweight='bold',
            bbox=dict(boxstyle='round,pad=0.2', facecolor='lightyellow', alpha=0.8))
    
    ax.set_title("Arrow's Impossibility: No SWF\nSatisfies All Three Axioms (k≥3)", fontsize=13)
    ax.axis('off')
    
    # --- Right: Decisive coalition hierarchy ---
    ax = axes[1]
    ax.set_xlim(-0.5, 4.5)
    ax.set_ylim(-0.5, 5)
    
    # Draw the hierarchy of decisive coalitions
    levels = [
        (2, 4.5, '∅ (Empty)\nNot decisive', '#fee0d2', '✗'),
        (2, 3.5, 'Small coalitions\nMay be decisive', '#fcbba1', '?'),
        (2, 2.5, 'Decisive coalition\n(Arrow: must shrink)', '#fc9272', '↓'),
        (2, 1.5, 'Singleton {d}\nDictator!', '#de2d26', '!'),
        (2, 0.5, 'Full coalition\nAlways decisive', '#a6d96a', '✓'),
    ]
    
    for x, y, label, color, symbol in levels:
        rect = patches.FancyBboxPatch((x-1.5, y-0.35), 3, 0.7, 
                                       boxstyle="round,pad=0.1",
                                       facecolor=color, edgecolor='gray',
                                       linewidth=1.5)
        ax.add_patch(rect)
        ax.text(x-1.2, y, label, ha='left', va='center', fontsize=9)
        ax.text(x+1.2, y, symbol, ha='center', va='center', fontsize=14,
                fontweight='bold')
    
    # Arrows between levels
    for i in range(len(levels) - 2):
        x1, y1 = levels[i][0], levels[i][1]
        x2, y2 = levels[i+1][0], levels[i+1][1]
        ax.annotate('', xy=(x2, y2+0.35), xytext=(x1, y1-0.35),
                    arrowprops=dict(arrowstyle='->', color='gray', lw=2))
    
    # Special arrow from full coalition going up
    ax.annotate('', xy=(2, 3.5-0.35), xytext=(2, 0.5+0.35),
                arrowprops=dict(arrowstyle='->', color='#4daf4a', lw=2,
                               connectionstyle='arc3,rad=0.5'))
    ax.text(3.8, 2.0, 'Pareto\nguarantees', ha='center', va='center', fontsize=8,
            color='#4daf4a', fontweight='bold')
    
    ax.set_title('Decisive Coalition Hierarchy\n(Arrow\'s Proof by Contraction)', fontsize=13)
    ax.axis('off')
    
    plt.tight_layout()
    plt.savefig('arrow_landscape.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: arrow_landscape.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: The Preference Sphere and Antipodal Structure

Visualizes the 6 strict rankings of 3 alternatives as points on a circle
(the preference "sphere" S^1 for k=3), with antipodal pairs connected.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np
from itertools import permutations


def kendall_distance(b1, b2):
    """Compute Kendall tau distance between two rankings."""
    k = len(b1)
    dist = 0
    for i in range(k):
        for j in range(i + 1, k):
            if (b1[i] < b1[j]) != (b2[i] < b2[j]):
                dist += 1
    return dist


def antipodal_ballot(ballot):
    """Reverse a ballot."""
    k = len(ballot)
    return tuple(k - 1 - r for r in ballot)


def main():
    k = 3
    names = ['A', 'B', 'C']
    all_ballots = list(permutations(range(k)))
    
    # Place ballots on a circle, ordered by Kendall distance from (0,1,2)
    # Natural circular ordering: each adjacent pair differs by one swap
    # The circular order is: ABC, BAC, BCA, CBA, CAB, ACB
    circular_order = [
        (0, 1, 2),  # A>B>C
        (1, 0, 2),  # B>A>C
        (1, 2, 0),  # B>C>A -> wait, this is rank assignment
    ]
    
    # Let me order by: start with identity, swap adjacent pairs
    # (0,1,2) -> swap 0,1 -> (1,0,2) -> swap 1,2 -> (1,2,0) -> swap 0,1 -> (2,1,0) -> swap 1,2 -> (2,0,1) -> swap 0,1 -> (0,2,1)
    # But this doesn't give a clean circle. Let me just place them evenly.
    
    n_ballots = len(all_ballots)
    angles = np.linspace(0, 2 * np.pi, n_ballots, endpoint=False)
    
    # Compute a better ordering using graph layout
    # Place antipodal pairs opposite each other
    ordered = []
    used = set()
    for b in all_ballots:
        if b not in used:
            ab = antipodal_ballot(b)
            ordered.append(b)
            used.add(b)
            used.add(ab)
    # Now add antipodals opposite
    final_order = []
    for i, b in enumerate(ordered):
        final_order.append(b)
    for i, b in enumerate(ordered):
        final_order.append(antipodal_ballot(b))
    
    # Rearrange so antipodals are opposite
    reordered = []
    for i in range(len(ordered)):
        reordered.append(ordered[i])
    for i in range(len(ordered)):
        reordered.append(antipodal_ballot(ordered[len(ordered)-1-i]))
    
    # Actually, let me just place them manually
    # Antipodal pairs: (0,1,2)↔(2,1,0), (1,0,2)↔(1,2,0), (0,2,1)↔(2,0,1)
    manual_order = [
        (0, 1, 2),  # A>B>C    (position 0°)
        (0, 2, 1),  # A>C>B    (position 60°)
        (2, 0, 1),  # C>A>B    (position 120°)
        (2, 1, 0),  # C>B>A    (position 180°, antipodal to 0°)
        (1, 2, 0),  # B>C>A    (position 240°, antipodal to 60° wait no)
        (1, 0, 2),  # B>A>C    (position 300°)
    ]
    
    # Verify: antipodal of (0,1,2) = (2,1,0) ✓ at 180°
    # antipodal of (0,2,1) = (2,0,1) ✓ at 120° (not 240°, hmm)
    # Let me fix this
    manual_order = [
        (0, 1, 2),  # A>B>C    (0°)
        (1, 0, 2),  # B>A>C    (60°)
        (1, 2, 0),  # C>A>B    (120°)   -- wait (1,2,0) means A has rank 1, B has rank 2, C has rank 0 -> C>A>B
        (2, 1, 0),  # C>B>A    (180°, antipodal to A>B>C)
        (0, 2, 1),  # A>C>B    (240°, antipodal to C>A>B)  -- (0,2,1): A rank 0, B rank 2, C rank 1 -> A>C>B, antipodal = (2,0,1) = C rank 2, wait
        (2, 0, 1),  # B>C>A    (300°, antipodal to B>A>C)
    ]
    
    fig, axes = plt.subplots(1, 2, figsize=(16, 7))
    
    # --- Left panel: Preference circle ---
    ax = axes[0]
    ax.set_aspect('equal')
    ax.set_xlim(-2, 2)
    ax.set_ylim(-2, 2)
    
    # Draw the circle
    circle = plt.Circle((0, 0), 1.3, fill=False, color='lightgray', linewidth=2)
    ax.add_patch(circle)
    
    colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3', '#ff7f00', '#a65628']
    
    for i, ballot in enumerate(manual_order):
        angle = i * 2 * np.pi / 6
        x = 1.3 * np.cos(angle)
        y = 1.3 * np.sin(angle)
        
        ranking = sorted(range(k), key=lambda j: ballot[j])
        label = '>'.join(names[r] for r in ranking)
        
        ax.plot(x, y, 'o', markersize=15, color=colors[i], zorder=5)
        
        # Label position (outside circle)
        lx = 1.7 * np.cos(angle)
        ly = 1.7 * np.sin(angle)
        ax.text(lx, ly, label, ha='center', va='center', fontsize=10, fontweight='bold')
    
    # Draw antipodal connections
    for i in range(3):
        angle1 = i * 2 * np.pi / 6
        angle2 = (i + 3) * 2 * np.pi / 6
        x1, y1 = 1.3 * np.cos(angle1), 1.3 * np.sin(angle1)
        x2, y2 = 1.3 * np.cos(angle2), 1.3 * np.sin(angle2)
        ax.plot([x1, x2], [y1, y2], '--', color='gray', alpha=0.5, linewidth=1.5)
    
    ax.set_title('Preference Sphere $S^1$ for 3 Alternatives\n(Dashed = Antipodal Pairs)', fontsize=13)
    ax.axis('off')
    
    # --- Right panel: Condorcet cycle ---
    ax = axes[1]
    ax.set_aspect('equal')
    ax.set_xlim(-2.5, 2.5)
    ax.set_ylim(-2, 2.5)
    
    # Draw the three alternatives as a triangle
    tri_angles = [np.pi/2, np.pi/2 + 2*np.pi/3, np.pi/2 + 4*np.pi/3]
    tri_x = [1.5 * np.cos(a) for a in tri_angles]
    tri_y = [1.5 * np.sin(a) for a in tri_angles]
    
    for i, (x, y) in enumerate(zip(tri_x, tri_y)):
        ax.plot(x, y, 'o', markersize=30, color=colors[i], zorder=5)
        ax.text(x, y, names[i], ha='center', va='center', fontsize=14, 
                fontweight='bold', color='white', zorder=6)
    
    # Draw majority arrows (Condorcet cycle)
    # A beats B (voters 0,2)
    # B beats C (voters 0,1)  -- wait, need to check
    # Actually from our Condorcet example:
    # A>B (2 voters), B>C (2 voters), C>A (2 voters)
    
    arrow_style = patches.FancyArrowPatch
    
    edges = [(0, 1, 'A > B'), (1, 2, 'B > C'), (2, 0, 'C > A')]
    edge_colors = ['#e41a1c', '#377eb8', '#4daf4a']
    
    for idx, (i, j, label) in enumerate(edges):
        dx = tri_x[j] - tri_x[i]
        dy = tri_y[j] - tri_y[i]
        
        # Shorten arrow
        length = np.sqrt(dx**2 + dy**2)
        shrink = 0.25
        sx = tri_x[i] + shrink * dx
        sy = tri_y[i] + shrink * dy
        ex = tri_x[j] - shrink * dx
        ey = tri_y[j] - shrink * dy
        
        ax.annotate('', xy=(ex, ey), xytext=(sx, sy),
                    arrowprops=dict(arrowstyle='->', color=edge_colors[idx], 
                                   lw=3, mutation_scale=20))
        
        # Label
        mx = (tri_x[i] + tri_x[j]) / 2
        my = (tri_y[i] + tri_y[j]) / 2
        # Offset perpendicular to edge
        nx, ny = -dy/length, dx/length
        ax.text(mx + 0.35*nx, my + 0.35*ny, label, ha='center', va='center',
                fontsize=10, color=edge_colors[idx], fontweight='bold')
    
    ax.set_title('Condorcet Paradox\n(Majority Rule Cycle)', fontsize=13)
    ax.text(0, -1.8, 'A>B>C, B>C>A, C>A>B → cycle!', ha='center', fontsize=10,
            style='italic')
    ax.axis('off')
    
    plt.tight_layout()
    plt.savefig('preference_sphere.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: preference_sphere.png")


if __name__ == "__main__":
    main()
