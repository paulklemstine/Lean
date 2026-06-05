"""
Demo: Arrow's Impossibility and the Topology of Social Choice

Demonstrates key concepts from the formalization:
1. Condorcet paradox (majority cycling)
2. Decisive coalition detection
3. Antipodal obstruction (sign change)
4. Majority rule on 2 alternatives
"""

from itertools import permutations
from typing import List, Tuple, Dict


def pairwise_majority(profiles: List[List[int]], a: int, b: int) -> int:
    """Count voters preferring a to b (a appears before b in ranking)."""
    count = 0
    for ranking in profiles:
        if ranking.index(a) < ranking.index(b):
            count += 1
    return count


def social_sign(profiles: List[List[int]], a: int, b: int) -> int:
    """Social sign: +1 if majority prefers a>b, -1 if b>a, 0 if tie."""
    n = len(profiles)
    count_ab = pairwise_majority(profiles, a, b)
    if count_ab > n / 2:
        return 1
    elif count_ab < n / 2:
        return -1
    return 0


def reverse_profile(profile: List[int]) -> List[int]:
    """Antipodal profile: reverse all preferences."""
    return list(reversed(profile))


def demo_condorcet_paradox():
    """Demonstrate the Condorcet paradox with 3 voters, 3 alternatives."""
    print("=" * 60)
    print("CONDORCET PARADOX")
    print("=" * 60)

    # Three voters with cyclic preferences
    profiles = [
        [0, 1, 2],  # Voter 0: A > B > C
        [1, 2, 0],  # Voter 1: B > C > A
        [2, 0, 1],  # Voter 2: C > A > B
    ]

    names = {0: "A", 1: "B", 2: "C"}
    print("\nVoter preferences:")
    for i, p in enumerate(profiles):
        print(f"  Voter {i}: {' > '.join(names[x] for x in p)}")

    print("\nPairwise majority results:")
    for a, b in [(0, 1), (1, 2), (2, 0)]:
        count = pairwise_majority(profiles, a, b)
        winner = names[a] if count > len(profiles) / 2 else names[b]
        print(f"  {names[a]} vs {names[b]}: {count}-{len(profiles)-count} → {winner} wins")

    print("\n→ Majority cycle: A > B > C > A (intransitive!)")
    print("→ This is why Arrow requires ≥3 alternatives for impossibility.\n")


def demo_antipodal_obstruction():
    """Demonstrate the sign change between a profile and its antipodal."""
    print("=" * 60)
    print("ANTIPODAL PARETO OBSTRUCTION (Borsuk-Ulam Analog)")
    print("=" * 60)

    # Unanimous profile
    profiles = [
        [0, 1, 2],  # A > B > C
        [0, 1, 2],  # A > B > C
        [0, 1, 2],  # A > B > C
    ]

    # Antipodal profile (all reversed)
    antipodal = [reverse_profile(p) for p in profiles]

    names = {0: "A", 1: "B", 2: "C"}
    print("\nOriginal profile (unanimous A > B > C):")
    for i, p in enumerate(profiles):
        print(f"  Voter {i}: {' > '.join(names[x] for x in p)}")

    print("\nAntipodal profile (unanimous C > B > A):")
    for i, p in enumerate(antipodal):
        print(f"  Voter {i}: {' > '.join(names[x] for x in p)}")

    print("\nSocial signs (majority rule):")
    for a, b in [(0, 1), (1, 2), (0, 2)]:
        s_orig = social_sign(profiles, a, b)
        s_anti = social_sign(antipodal, a, b)
        print(f"  ({names[a]},{names[b]}): original={s_orig:+d}, "
              f"antipodal={s_anti:+d}, changed={'YES' if s_orig != s_anti else 'NO'}")

    print("\n→ The social sign MUST flip between profile and antipodal (Pareto).")
    print("→ This is the discrete Borsuk-Ulam theorem for social choice.\n")


def demo_decisive_coalitions():
    """Show how decisive coalitions work with a dictator SWF."""
    print("=" * 60)
    print("DECISIVE COALITIONS AND DICTATORSHIP")
    print("=" * 60)

    n_voters = 3

    # Dictator SWF: voter 0 is dictator
    def dictator_swf(profiles):
        return profiles[0]

    print(f"\nSWF: Dictator (voter 0 always wins)")
    print(f"Testing decisive coalitions for 3 voters:")

    # Test all non-empty subsets
    from itertools import combinations
    for size in range(1, n_voters + 1):
        for coalition in combinations(range(n_voters), size):
            coalition_set = set(coalition)
            is_decisive = True

            # Test: coalition prefers A>B, others prefer B>A
            profiles_test = []
            for v in range(n_voters):
                if v in coalition_set:
                    profiles_test.append([0, 1, 2])  # A > B > C
                else:
                    profiles_test.append([1, 0, 2])  # B > A > C

            result = dictator_swf(profiles_test)
            if result.index(0) > result.index(1):  # society prefers B>A
                is_decisive = False

            status = "DECISIVE" if is_decisive else "not decisive"
            contains_dictator = 0 in coalition_set
            print(f"  Coalition {coalition}: {status} "
                  f"({'contains dictator' if contains_dictator else 'no dictator'})")

    print("\n→ Only coalitions containing the dictator (voter 0) are decisive.")
    print("→ {0} is the unique minimal decisive coalition.\n")


def demo_majority_two_alternatives():
    """Show majority rule works for 2 alternatives."""
    print("=" * 60)
    print("MAJORITY RULE ON 2 ALTERNATIVES")
    print("=" * 60)

    n_voters = 5
    alternatives = ["A", "B"]

    print(f"\n{n_voters} voters, 2 alternatives: majority rule")
    print("Testing Pareto efficiency:")

    # Unanimous: all prefer A>B
    profiles = [[0, 1]] * n_voters
    count = pairwise_majority(profiles, 0, 1)
    print(f"  All prefer A>B: majority count = {count}/{n_voters} → A wins ✓")

    # Non-unanimous: 3 prefer A>B, 2 prefer B>A
    profiles = [[0, 1]] * 3 + [[1, 0]] * 2
    count = pairwise_majority(profiles, 0, 1)
    print(f"  3 prefer A>B, 2 prefer B>A: count = {count}/{n_voters} → A wins")

    print("\nTesting non-dictatorship:")
    # For each voter, show they can be outvoted
    for d in range(n_voters):
        profiles = []
        for v in range(n_voters):
            if v == d:
                profiles.append([0, 1])  # d prefers A>B
            else:
                profiles.append([1, 0])  # others prefer B>A
        count = pairwise_majority(profiles, 0, 1)
        outcome = "A" if count > n_voters / 2 else "B"
        print(f"  Voter {d} vs all others: count={count}/{n_voters} → {outcome} wins "
              f"({'dictator' if outcome == 'A' else 'outvoted'})")

    print("\n→ No voter is a dictator. Majority rule satisfies Pareto + non-dictatorship.")
    print("→ Arrow's impossibility does NOT apply to 2 alternatives.\n")


def demo_dimension_counting():
    """Show the dimension counting argument."""
    print("=" * 60)
    print("DIMENSION COUNTING: WHY 3 ALTERNATIVES BREAKS EVERYTHING")
    print("=" * 60)

    print("\n  k alternatives → k(k-1)/2 pairwise constraints, k-1 degrees of freedom")
    print()
    for k in range(2, 8):
        constraints = k * (k - 1) // 2
        freedom = k - 1
        ratio = constraints / freedom if freedom > 0 else float('inf')
        status = "BALANCED" if constraints == freedom else \
                 "OVER-CONSTRAINED → IMPOSSIBILITY" if constraints > freedom else "UNDER"
        print(f"  k={k}: constraints={constraints}, freedom={freedom}, "
              f"ratio={ratio:.1f} → {status}")

    print("\n→ At k=3, the system becomes over-constrained.")
    print("→ This is the Borsuk-Ulam threshold: sphere dimension ≥ 2.\n")


if __name__ == "__main__":
    demo_condorcet_paradox()
    demo_antipodal_obstruction()
    demo_decisive_coalitions()
    demo_majority_two_alternatives()
    demo_dimension_counting()


"""
Visualization: Arrow's Impossibility and the Preference Sphere

Generates plots showing:
1. The preference sphere with antipodal structure
2. Social sign changes under Pareto
3. Dimension counting
"""

import matplotlib.pyplot as plt
import numpy as np
from mpl_toolkits.mplot3d import Axes3D


def plot_dimension_counting():
    """Plot the dimension counting argument for Arrow's impossibility."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    k_values = np.arange(2, 12)
    constraints = k_values * (k_values - 1) // 2
    freedom = k_values - 1

    ax.bar(k_values - 0.2, constraints, 0.35, label='Pairwise constraints k(k-1)/2',
           color='#e74c3c', alpha=0.8)
    ax.bar(k_values + 0.2, freedom, 0.35, label='Degrees of freedom k-1',
           color='#3498db', alpha=0.8)

    ax.axvline(x=2.5, color='green', linestyle='--', linewidth=2,
               label='Arrow boundary (k=3)')
    ax.fill_betweenx([0, max(constraints) * 1.1], 2.5, 11.5,
                      color='red', alpha=0.05)
    ax.fill_betweenx([0, max(constraints) * 1.1], 1.5, 2.5,
                      color='green', alpha=0.05)

    ax.set_xlabel('Number of alternatives (k)', fontsize=14)
    ax.set_ylabel('Count', fontsize=14)
    ax.set_title("Arrow's Impossibility: Dimension Counting\n"
                  "Over-constrained for k ≥ 3 (Borsuk-Ulam threshold)", fontsize=16)
    ax.legend(fontsize=12)
    ax.set_xticks(k_values)

    for k, c, f in zip(k_values, constraints, freedom):
        if c > f:
            ax.annotate(f'{c}/{f}', (k, c + 1), ha='center', fontsize=9, color='red')

    plt.tight_layout()
    plt.savefig('dimension_counting.png', dpi=150)
    plt.close()
    print("Saved dimension_counting.png")


def plot_sign_change():
    """Plot the social sign change between profile and antipodal."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: unanimous profile → social sign = +1
    ax1 = axes[0]
    pairs = ['(A,B)', '(B,C)', '(A,C)']
    signs_original = [1, 1, 1]
    colors = ['#27ae60' if s > 0 else '#e74c3c' for s in signs_original]
    ax1.barh(pairs, signs_original, color=colors, edgecolor='black', linewidth=2)
    ax1.set_xlim(-1.5, 1.5)
    ax1.set_title('Unanimous: A > B > C\nSocial signs', fontsize=14)
    ax1.axvline(x=0, color='black', linewidth=0.5)
    for i, s in enumerate(signs_original):
        ax1.text(s + 0.1 * np.sign(s), i, f'{s:+d}', va='center', fontsize=16, fontweight='bold')

    # Right: antipodal profile → social sign = -1
    ax2 = axes[1]
    signs_antipodal = [-1, -1, -1]
    colors = ['#27ae60' if s > 0 else '#e74c3c' for s in signs_antipodal]
    ax2.barh(pairs, signs_antipodal, color=colors, edgecolor='black', linewidth=2)
    ax2.set_xlim(-1.5, 1.5)
    ax2.set_title('Antipodal: C > B > A\nSocial signs (FLIPPED)', fontsize=14)
    ax2.axvline(x=0, color='black', linewidth=0.5)
    for i, s in enumerate(signs_antipodal):
        ax2.text(s + 0.1 * np.sign(s), i, f'{s:+d}', va='center', fontsize=16, fontweight='bold')

    fig.suptitle("Sign Change Theorem (Discrete Borsuk-Ulam)\n"
                 "Social sign MUST flip between profile and antipodal", fontsize=16, y=1.02)
    plt.tight_layout()
    plt.savefig('sign_change.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved sign_change.png")


def plot_preference_sphere():
    """Plot the preference sphere for 3 alternatives."""
    fig = plt.figure(figsize=(10, 10))
    ax = fig.add_subplot(111, projection='3d')

    # Draw sphere
    u = np.linspace(0, 2 * np.pi, 50)
    v = np.linspace(0, np.pi, 50)
    x = np.outer(np.cos(u), np.sin(v))
    y = np.outer(np.sin(u), np.sin(v))
    z = np.outer(np.ones(np.size(u)), np.cos(v))
    ax.plot_surface(x, y, z, alpha=0.1, color='lightblue')

    # Mark the 6 strict linear orders as points on the sphere
    orders = {
        'A>B>C': (0.8, 0.5, 0.3),
        'A>C>B': (0.6, -0.4, 0.7),
        'B>A>C': (-0.2, 0.8, 0.5),
        'B>C>A': (-0.7, 0.3, -0.6),
        'C>A>B': (-0.5, -0.7, 0.5),
        'C>B>A': (-0.8, -0.5, -0.3),
    }

    # Normalize to unit sphere
    for name, (px, py, pz) in orders.items():
        norm = np.sqrt(px**2 + py**2 + pz**2)
        px, py, pz = px/norm, py/norm, pz/norm
        orders[name] = (px, py, pz)

    # Draw points
    for name, (px, py, pz) in orders.items():
        ax.scatter([px], [py], [pz], s=100, zorder=5)
        ax.text(px*1.15, py*1.15, pz*1.15, name, fontsize=9, ha='center')

    # Draw antipodal pairs
    antipodal_pairs = [
        ('A>B>C', 'C>B>A'),
        ('A>C>B', 'B>C>A'),
        ('B>A>C', 'C>A>B'),
    ]
    for o1, o2 in antipodal_pairs:
        p1 = orders[o1]
        p2 = orders[o2]
        ax.plot([p1[0], p2[0]], [p1[1], p2[1]], [p1[2], p2[2]],
                'r--', linewidth=1.5, alpha=0.6)

    ax.set_title('Preference Sphere S² for 3 Alternatives\n'
                 'Antipodal pairs connected by dashed lines', fontsize=14)
    ax.set_xlabel('x')
    ax.set_ylabel('y')
    ax.set_zlabel('z')

    plt.tight_layout()
    plt.savefig('preference_sphere.png', dpi=150)
    plt.close()
    print("Saved preference_sphere.png")


if __name__ == "__main__":
    plot_dimension_counting()
    plot_sign_change()
    plot_preference_sphere()
