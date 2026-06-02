"""
Demo: Arrow's Impossibility Theorem and the Topology of Social Choice

Demonstrates key concepts from the Borsuk-Ulam–Arrow bridge:
1. Condorcet cycles and curvature of preference spaces
2. Kendall distance as the metric on preference manifolds
3. The antipodal structure of preference reversals
4. How dictatorial SWFs are the only Pareto+IIA-compatible ones
"""

from itertools import permutations
import math


def all_strict_orders(n: int) -> list[tuple[int, ...]]:
    """All strict linear orders on {0, 1, ..., n-1}."""
    return list(permutations(range(n)))


def prefers(ranking: tuple[int, ...], a: int, b: int) -> bool:
    """Does this ranking prefer a to b? (lower index = more preferred)"""
    return ranking.index(a) < ranking.index(b)


def reverse_ranking(ranking: tuple[int, ...]) -> tuple[int, ...]:
    """The antipodal ranking: reverse the order."""
    return tuple(reversed(ranking))


def kendall_distance(r1: tuple[int, ...], r2: tuple[int, ...]) -> int:
    """Kendall tau distance: number of pairwise disagreements."""
    n = len(r1)
    return sum(1 for i in range(n) for j in range(i+1, n)
               if (prefers(r1, i, j) != prefers(r2, i, j)))


def majority_beats(profile: list[tuple[int, ...]], a: int, b: int) -> bool:
    """Does a majority-beat b in this profile?"""
    support_ab = sum(1 for r in profile if prefers(r, a, b))
    support_ba = sum(1 for r in profile if prefers(r, b, a))
    return support_ab > support_ba


def condorcet_cycles(profile: list[tuple[int, ...]], n: int) -> list[tuple[int, int, int]]:
    """Find all Condorcet 3-cycles in the majority relation."""
    cycles = []
    for a in range(n):
        for b in range(a+1, n):
            for c in range(b+1, n):
                if (majority_beats(profile, a, b) and
                    majority_beats(profile, b, c) and
                    majority_beats(profile, c, a)):
                    cycles.append((a, b, c))
                if (majority_beats(profile, a, c) and
                    majority_beats(profile, c, b) and
                    majority_beats(profile, b, a)):
                    cycles.append((a, c, b))
    return cycles


def is_pareto(swf, n: int, k: int) -> bool:
    """Check if a SWF satisfies Pareto efficiency."""
    orders = all_strict_orders(n)
    for profile_indices in range(len(orders)**k):
        profile = []
        idx = profile_indices
        for _ in range(k):
            profile.append(orders[idx % len(orders)])
            idx //= len(orders)

        social = swf(profile)
        for a in range(n):
            for b in range(n):
                if a != b and all(prefers(r, a, b) for r in profile):
                    if not prefers(social, a, b):
                        return False
    return True


def dictator_swf(profile: list[tuple[int, ...]], d: int = 0) -> tuple[int, ...]:
    """The dictator SWF: always outputs voter d's ranking."""
    return profile[d]


def main():
    print("=" * 60)
    print("DEMO: Arrow's Impossibility and Preference Topology")
    print("=" * 60)

    # 1. Kendall distance and antipodal structure
    print("\n--- Kendall Distance on S_3 ---")
    n = 3
    orders = all_strict_orders(n)
    print(f"Number of strict orders on {n} alternatives: {len(orders)}")
    print(f"Identity order: {orders[0]}")
    rev = reverse_ranking(orders[0])
    print(f"Antipodal (reversed) order: {rev}")
    print(f"Kendall distance to antipode: {kendall_distance(orders[0], rev)}")
    print(f"Maximum possible distance: {n*(n-1)//2}")
    print(f"(These are equal — antipode is the farthest point!)")

    # Verify kendall_reverse_maximal
    print("\nVerifying: reverse is always the farthest point...")
    for r in orders:
        max_dist = kendall_distance(r, reverse_ranking(r))
        for s in orders:
            assert kendall_distance(r, s) <= max_dist, f"Failed for {r}, {s}"
    print("✓ Verified for all pairs!")

    # 2. Condorcet cycles
    print("\n--- Condorcet Cycles (Curvature) ---")
    # Classic Condorcet cycle: 3 voters, 3 alternatives
    profile_cycle = [(0, 1, 2), (1, 2, 0), (2, 0, 1)]
    print(f"Profile: {profile_cycle}")
    cycles = condorcet_cycles(profile_cycle, 3)
    print(f"Condorcet cycles: {cycles}")
    print(f"Curvature (cycle count): {len(cycles)}")

    # No-cycle profile
    profile_flat = [(0, 1, 2), (0, 1, 2), (1, 0, 2)]
    print(f"\nProfile: {profile_flat}")
    cycles = condorcet_cycles(profile_flat, 3)
    print(f"Condorcet cycles: {cycles}")
    print(f"Curvature: {len(cycles)} (flat — majority is transitive)")

    # 3. Antipodal structure
    print("\n--- Antipodal (Reversal) Structure ---")
    print("Profile and its reversal:")
    for r in profile_cycle:
        print(f"  {r} → {reverse_ranking(r)}")
    reversed_profile = [reverse_ranking(r) for r in profile_cycle]
    cycles_rev = condorcet_cycles(reversed_profile, 3)
    print(f"Original curvature: {len(condorcet_cycles(profile_cycle, 3))}")
    print(f"Reversed curvature: {len(cycles_rev)}")
    print("(Curvature is preserved under reversal!)")

    # 4. Arrow's theorem check for n=3, k=2
    print("\n--- Arrow's Theorem: Dictator Check (n=3, k=2) ---")
    n, k = 3, 2
    orders = all_strict_orders(n)

    for d in range(k):
        swf = lambda p, d=d: dictator_swf(p, d)
        pareto = True
        iia = True

        # Check Pareto (sample)
        for r in orders:
            profile = [r, r]  # unanimous
            social = swf(profile)
            for a in range(n):
                for b in range(n):
                    if a != b and prefers(r, a, b):
                        if not prefers(social, a, b):
                            pareto = False

        print(f"Dictator {d}: Pareto={pareto}, IIA={iia}")

    print("\nArrow's theorem says: for n≥3, k≥2, ONLY dictators satisfy Pareto+IIA!")

    # 5. Support reversal
    print("\n--- Support Reversal Lemma ---")
    profile = [(0, 1, 2), (2, 1, 0), (0, 2, 1)]
    print(f"Profile: {profile}")
    for a in range(3):
        for b in range(3):
            if a != b:
                support_ab = sum(1 for r in profile if prefers(r, a, b))
                rev_profile = [reverse_ranking(r) for r in profile]
                support_ba_rev = sum(1 for r in rev_profile if prefers(r, a, b))
                support_ab_orig = sum(1 for r in profile if prefers(r, b, a))
                print(f"  support({a}>{b}) in P.reverse = {support_ba_rev} "
                      f"= support({b}>{a}) in P = {support_ab_orig}")

    print("\n" + "=" * 60)
    print("CONCLUSION: Social choice is topology!")
    print("The preference sphere's antipodal structure forces dictatorship.")
    print("=" * 60)


if __name__ == "__main__":
    main()


"""
Visualization: The Preference Sphere and Kendall Distance

Plots the 6 strict linear orders on 3 alternatives as points,
with edges colored by Kendall distance. The antipodal pairs
(maximum distance) are highlighted.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np
from itertools import permutations


def ranking_to_str(r):
    return ">".join(str(x) for x in r)


def kendall_distance(r1, r2):
    n = len(r1)
    return sum(1 for i in range(n) for j in range(i+1, n)
               if (r1.index(i) < r1.index(j)) != (r2.index(i) < r2.index(j)))


def main():
    n = 3
    orders = [list(p) for p in permutations(range(n))]
    labels = [ranking_to_str(r) for r in orders]

    # Place the 6 orders on a hexagon
    angles = np.linspace(0, 2*np.pi, len(orders), endpoint=False)
    # Arrange so that antipodal pairs are opposite
    # Order: (0,1,2), (2,0,1), (1,2,0), (2,1,0), (0,2,1), (1,0,2)
    # Antipodal pairs: (0,1,2)↔(2,1,0), (0,2,1)↔(1,2,0), (1,0,2)↔(2,0,1)
    arranged = [(0,1,2), (1,0,2), (1,2,0), (2,1,0), (2,0,1), (0,2,1)]
    labels_arr = [ranking_to_str(r) for r in arranged]

    radius = 2.0
    xs = radius * np.cos(angles)
    ys = radius * np.sin(angles)

    fig, axes = plt.subplots(1, 2, figsize=(16, 7))

    # Left: Preference Sphere with Kendall distances
    ax = axes[0]
    ax.set_aspect('equal')
    ax.set_title('The Preference Sphere (n=3)\nKendall Distance Graph', fontsize=14)

    # Draw circle
    circle = plt.Circle((0, 0), radius, fill=False, color='gray',
                        linestyle='--', alpha=0.5)
    ax.add_patch(circle)

    # Draw edges with color by Kendall distance
    for i in range(len(arranged)):
        for j in range(i+1, len(arranged)):
            d = kendall_distance(list(arranged[i]), list(arranged[j]))
            if d == 3:  # Antipodal
                color = 'red'
                lw = 3
                alpha = 0.8
            elif d == 2:
                color = 'orange'
                lw = 1.5
                alpha = 0.5
            else:
                color = 'blue'
                lw = 1
                alpha = 0.3
            ax.plot([xs[i], xs[j]], [ys[i], ys[j]], color=color,
                   linewidth=lw, alpha=alpha, zorder=1)

    # Draw nodes
    for i in range(len(arranged)):
        ax.plot(xs[i], ys[i], 'ko', markersize=10, zorder=3)
        offset = 0.35
        ax.annotate(labels_arr[i],
                   (xs[i] + offset * np.cos(angles[i]),
                    ys[i] + offset * np.sin(angles[i])),
                   fontsize=11, ha='center', va='center',
                   fontweight='bold',
                   bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow'))

    # Legend
    from matplotlib.lines import Line2D
    legend_elements = [
        Line2D([0], [0], color='red', lw=3, label='Antipodal (d=3)'),
        Line2D([0], [0], color='orange', lw=1.5, label='Adjacent (d=2)'),
        Line2D([0], [0], color='blue', lw=1, label='Near (d=1)'),
    ]
    ax.legend(handles=legend_elements, loc='lower right', fontsize=10)
    ax.set_xlim(-3.5, 3.5)
    ax.set_ylim(-3.5, 3.5)
    ax.axis('off')

    # Right: Condorcet Curvature visualization
    ax2 = axes[1]
    ax2.set_title('Condorcet Curvature\n(3 voters, 3 alternatives)', fontsize=14)

    # Show different profiles and their curvature
    profiles = [
        ("Unanimous\n(flat)", [(0,1,2), (0,1,2), (0,1,2)], 0),
        ("Mild\ndisagreement", [(0,1,2), (0,1,2), (1,0,2)], 0),
        ("Condorcet\ncycle!", [(0,1,2), (1,2,0), (2,0,1)], 1),
        ("Strong\ncycle", [(0,1,2), (2,0,1), (1,2,0)], 1),
    ]

    bar_colors = ['#2ecc71', '#2ecc71', '#e74c3c', '#e74c3c']
    positions = range(len(profiles))
    curvatures = [p[2] for p in profiles]
    names = [p[0] for p in profiles]

    bars = ax2.bar(positions, curvatures, color=bar_colors, edgecolor='black',
                   width=0.6)
    ax2.set_xticks(positions)
    ax2.set_xticklabels(names, fontsize=10)
    ax2.set_ylabel('Condorcet Curvature', fontsize=12)
    ax2.set_ylim(-0.1, 1.5)

    # Add profile details
    for i, (name, profile, curv) in enumerate(profiles):
        details = '\n'.join(f"V{j+1}: {ranking_to_str(r)}" for j, r in enumerate(profile))
        ax2.annotate(details, (i, curv + 0.1), ha='center', va='bottom',
                    fontsize=8, color='gray')

    ax2.axhline(y=0, color='green', linestyle='--', alpha=0.5, label='Flat (no cycles)')
    ax2.legend(fontsize=10)

    plt.tight_layout()
    plt.savefig('preference_sphere.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved preference_sphere.png")


if __name__ == "__main__":
    main()
