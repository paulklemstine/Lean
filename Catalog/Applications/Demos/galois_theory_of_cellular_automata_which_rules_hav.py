#!/usr/bin/env python3
"""
Demo: Reversible Elementary Cellular Automata
=============================================
Enumerates all 256 elementary CA rules, identifies the 6 reversible ones,
demonstrates reversibility/non-reversibility with concrete examples,
and visualizes the group structure.
"""

import itertools
from typing import Callable, Dict, List, Optional, Tuple


def rule_function(rule_number: int) -> Callable[[bool, bool, bool], bool]:
    """Convert a Wolfram rule number (0-255) to a local rule function."""
    def f(a: bool, b: bool, c: bool) -> bool:
        index = (int(a) << 2) | (int(b) << 1) | int(c)
        return bool((rule_number >> index) & 1)
    return f


def global_map(f: Callable[[bool, bool, bool], bool],
               config: List[bool]) -> List[bool]:
    """Apply a CA rule to a cyclic configuration."""
    n = len(config)
    return [f(config[(i - 1) % n], config[i], config[(i + 1) % n])
            for i in range(n)]


def is_injective_on_size(rule_number: int, n: int) -> bool:
    """Check if a rule's global map is injective on configurations of size n."""
    f = rule_function(rule_number)
    seen = set()
    for bits in itertools.product([False, True], repeat=n):
        config = list(bits)
        result = tuple(global_map(f, config))
        if result in seen:
            return False
        seen.add(result)
    return True


def is_reversible(rule_number: int, max_n: int = 8) -> bool:
    """Test reversibility for configuration sizes 1 through max_n."""
    return all(is_injective_on_size(rule_number, n) for n in range(1, max_n + 1))


def find_collision(rule_number: int, max_n: int = 8) -> Optional[Tuple[int, List[bool], List[bool]]]:
    """Find a collision (two configs mapping to same output) for a non-reversible rule."""
    f = rule_function(rule_number)
    for n in range(1, max_n + 1):
        seen: Dict[tuple, List[bool]] = {}
        for bits in itertools.product([False, True], repeat=n):
            config = list(bits)
            result = tuple(global_map(f, config))
            if result in seen:
                return (n, seen[result], config)
            seen[result] = config
    return None


def dependency_analysis(rule_number: int) -> Dict[str, bool]:
    """Analyze which inputs a rule depends on."""
    f = rule_function(rule_number)
    depends_left = any(
        f(False, b, c) != f(True, b, c)
        for b in [False, True] for c in [False, True]
    )
    depends_center = any(
        f(a, False, c) != f(a, True, c)
        for a in [False, True] for c in [False, True]
    )
    depends_right = any(
        f(a, b, False) != f(a, b, True)
        for a in [False, True] for b in [False, True]
    )
    return {
        "left": depends_left,
        "center": depends_center,
        "right": depends_right,
        "count": sum([depends_left, depends_center, depends_right])
    }


def main():
    print("=" * 70)
    print("REVERSIBLE ELEMENTARY CELLULAR AUTOMATA")
    print("=" * 70)

    # Find all reversible rules
    reversible_rules = []
    for r in range(256):
        if is_reversible(r):
            reversible_rules.append(r)

    print(f"\nReversible rules (out of 256): {reversible_rules}")
    print(f"Count: {len(reversible_rules)}")

    # Analyze each reversible rule
    print("\n" + "-" * 70)
    print("DEPENDENCY ANALYSIS OF REVERSIBLE RULES")
    print("-" * 70)
    for r in reversible_rules:
        deps = dependency_analysis(r)
        dep_str = []
        if deps["left"]: dep_str.append("left")
        if deps["center"]: dep_str.append("center")
        if deps["right"]: dep_str.append("right")
        print(f"  Rule {r:3d}: depends on {', '.join(dep_str) if dep_str else 'nothing'} "
              f"(count: {deps['count']})")

    # Demonstrate reversibility
    print("\n" + "-" * 70)
    print("REVERSIBILITY DEMONSTRATION (n=5)")
    print("-" * 70)
    test_config = [True, False, True, True, False]
    for r in reversible_rules:
        f = rule_function(r)
        output = global_map(f, test_config)
        print(f"  Rule {r:3d}: {test_config} -> {output}")

    # Show XOR collision
    print("\n" + "-" * 70)
    print("XOR RULE (90) NON-REVERSIBILITY")
    print("-" * 70)
    collision = find_collision(90)
    if collision:
        n, c1, c2 = collision
        f = rule_function(90)
        r1 = global_map(f, c1)
        r2 = global_map(f, c2)
        print(f"  Collision found at n={n}:")
        print(f"    Config 1: {c1} -> {r1}")
        print(f"    Config 2: {c2} -> {r2}")
        print(f"    Both map to the same output!")

    # Verify group properties
    print("\n" + "-" * 70)
    print("GROUP STRUCTURE VERIFICATION")
    print("-" * 70)

    f170 = rule_function(170)  # right shift (left projection of neighbor)
    f240 = rule_function(240)  # left shift (right projection of neighbor)
    f51 = rule_function(51)    # complement

    test = [True, False, True, True, False, False, True, False]

    # Shift left then shift right = identity
    shifted = global_map(f170, test)
    restored = global_map(f240, shifted)
    print(f"  Left-shift ∘ Right-shift = id: {restored == test}")

    # Complement is involution
    complemented = global_map(f51, test)
    double_comp = global_map(f51, complemented)
    print(f"  Complement ∘ Complement = id: {double_comp == test}")

    # Shift and complement commute
    sc = global_map(f51, global_map(f170, test))
    cs = global_map(f170, global_map(f51, test))
    print(f"  Shift and Complement commute: {sc == cs}")

    # Statistics on non-reversible rules
    print("\n" + "-" * 70)
    print("NON-REVERSIBILITY STATISTICS")
    print("-" * 70)
    first_failure = {}
    for r in range(256):
        if r in reversible_rules:
            continue
        for n in range(1, 13):
            if not is_injective_on_size(r, n):
                first_failure[r] = n
                break

    from collections import Counter
    failure_dist = Counter(first_failure.values())
    print("  First failure at configuration size:")
    for size in sorted(failure_dist.keys()):
        print(f"    n={size}: {failure_dist[size]} rules")

    # Dependency count distribution
    print("\n" + "-" * 70)
    print("DEPENDENCY COUNT DISTRIBUTION")
    print("-" * 70)
    dep_counts = Counter()
    for r in range(256):
        deps = dependency_analysis(r)
        dep_counts[deps["count"]] += 1

    for count in sorted(dep_counts.keys()):
        rev_in_class = sum(1 for r in reversible_rules
                          if dependency_analysis(r)["count"] == count)
        print(f"  {count} dependencies: {dep_counts[count]} rules "
              f"({rev_in_class} reversible)")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Reversible vs Non-Reversible Elementary CA Spacetime Diagrams
============================================================================
Generates spacetime diagrams comparing reversible and non-reversible rules,
plus a dependency analysis chart.
"""

import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import numpy as np
from typing import List, Callable


def rule_function(rule_number: int) -> Callable[[bool, bool, bool], bool]:
    """Convert Wolfram rule number to local rule function."""
    def f(a: bool, b: bool, c: bool) -> bool:
        index = (int(a) << 2) | (int(b) << 1) | int(c)
        return bool((rule_number >> index) & 1)
    return f


def evolve_ca(rule_number: int, initial: List[bool], steps: int) -> np.ndarray:
    """Evolve a CA for given number of steps, returning spacetime diagram."""
    f = rule_function(rule_number)
    n = len(initial)
    diagram = np.zeros((steps + 1, n), dtype=int)
    config = list(initial)
    diagram[0] = [int(x) for x in config]

    for t in range(1, steps + 1):
        new_config = [f(config[(i-1) % n], config[i], config[(i+1) % n])
                      for i in range(n)]
        diagram[t] = [int(x) for x in new_config]
        config = new_config

    return diagram


def create_spacetime_comparison():
    """Create side-by-side spacetime diagrams of reversible vs non-reversible rules."""
    n = 51
    steps = 40
    initial = [False] * n
    initial[n // 2] = True  # Single seed in center

    rules = [
        (204, "Rule 204 (Identity)", True),
        (170, "Rule 170 (Left Shift)", True),
        (51, "Rule 51 (Complement)", True),
        (90, "Rule 90 (XOR)", False),
        (110, "Rule 110 (Universal)", False),
        (30, "Rule 30 (Chaos)", False),
    ]

    fig, axes = plt.subplots(2, 3, figsize=(15, 8))
    cmap = mcolors.ListedColormap(['white', 'black'])

    for idx, (rule_num, title, is_rev) in enumerate(rules):
        ax = axes[idx // 3][idx % 3]
        diagram = evolve_ca(rule_num, initial, steps)
        ax.imshow(diagram, cmap=cmap, interpolation='nearest', aspect='auto')
        color = 'green' if is_rev else 'red'
        ax.set_title(f'{title}\n{"✓ Reversible" if is_rev else "✗ Non-reversible"}',
                     fontsize=10, color=color, fontweight='bold')
        ax.set_xlabel('Cell Position')
        ax.set_ylabel('Time Step')

    plt.suptitle('Elementary CA Spacetime Diagrams:\nReversible (top) vs Non-Reversible (bottom)',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('spacetime_comparison.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: spacetime_comparison.png")


def create_dependency_chart():
    """Create a chart showing dependency patterns of all 256 rules."""
    dep_data = {'none': [], 'left_only': [], 'center_only': [], 'right_only': [],
                'left_center': [], 'left_right': [], 'center_right': [], 'all_three': []}

    for r in range(256):
        f = rule_function(r)
        dl = any(f(False, b, c) != f(True, b, c)
                 for b in [False, True] for c in [False, True])
        dc = any(f(a, False, c) != f(a, True, c)
                 for a in [False, True] for c in [False, True])
        dr = any(f(a, b, False) != f(a, b, True)
                 for a in [False, True] for b in [False, True])

        key = {
            (False, False, False): 'none',
            (True, False, False): 'left_only',
            (False, True, False): 'center_only',
            (False, False, True): 'right_only',
            (True, True, False): 'left_center',
            (True, False, True): 'left_right',
            (False, True, True): 'center_right',
            (True, True, True): 'all_three',
        }[(dl, dc, dr)]
        dep_data[key].append(r)

    categories = ['None', 'Left\nonly', 'Center\nonly', 'Right\nonly',
                  'Left+\nCenter', 'Left+\nRight', 'Center+\nRight', 'All\nThree']
    keys = list(dep_data.keys())
    counts = [len(dep_data[k]) for k in keys]
    reversible = [15, 51, 85, 170, 204, 240]
    rev_counts = [sum(1 for r in dep_data[k] if r in reversible) for k in keys]

    fig, ax = plt.subplots(figsize=(10, 6))
    x = np.arange(len(categories))
    width = 0.35

    bars1 = ax.bar(x - width/2, counts, width, label='Total rules', color='steelblue', alpha=0.7)
    bars2 = ax.bar(x + width/2, rev_counts, width, label='Reversible rules', color='green', alpha=0.7)

    ax.set_xlabel('Dependency Pattern', fontsize=12)
    ax.set_ylabel('Number of Rules', fontsize=12)
    ax.set_title('Elementary CA Rules by Input Dependency Pattern', fontsize=14, fontweight='bold')
    ax.set_xticks(x)
    ax.set_xticklabels(categories, fontsize=9)
    ax.legend()

    for bar, count in zip(bars1, counts):
        if count > 0:
            ax.text(bar.get_x() + bar.get_width()/2., bar.get_height() + 1,
                    str(count), ha='center', va='bottom', fontsize=8)
    for bar, count in zip(bars2, rev_counts):
        if count > 0:
            ax.text(bar.get_x() + bar.get_width()/2., bar.get_height() + 0.5,
                    str(count), ha='center', va='bottom', fontsize=8, color='green')

    plt.tight_layout()
    plt.savefig('dependency_chart.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: dependency_chart.png")


def create_information_loss_chart():
    """Chart showing information loss (image size) for various rules."""
    test_rules = [90, 110, 30, 150, 60, 102, 204, 170]
    max_n = 14

    fig, ax = plt.subplots(figsize=(10, 6))

    for rule_num in test_rules:
        f = rule_function(rule_num)
        ns = list(range(1, max_n + 1))
        image_fractions = []
        for n in ns:
            seen = set()
            for bits in __import__('itertools').product([False, True], repeat=n):
                config = list(bits)
                result = [f(config[(i-1) % n], config[i], config[(i+1) % n])
                          for i in range(n)]
                seen.add(tuple(result))
            image_fractions.append(len(seen) / (2**n))

        is_rev = rule_num in [15, 51, 85, 170, 204, 240]
        style = '-' if is_rev else '--'
        marker = 'o' if is_rev else 's'
        ax.plot(ns, image_fractions, style, marker=marker, markersize=4,
                label=f'Rule {rule_num}' + (' ✓' if is_rev else ''))

    ax.set_xlabel('Configuration Size n', fontsize=12)
    ax.set_ylabel('|Image| / 2^n (fraction preserved)', fontsize=12)
    ax.set_title('Information Preservation by Rule\n(1.0 = reversible, <1.0 = information loss)',
                 fontsize=14, fontweight='bold')
    ax.legend(loc='center right', fontsize=9)
    ax.set_ylim(-0.05, 1.15)
    ax.axhline(y=1.0, color='green', linestyle=':', alpha=0.5, label='Perfect preservation')
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('information_loss.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: information_loss.png")


if __name__ == "__main__":
    create_spacetime_comparison()
    create_dependency_chart()
    create_information_loss_chart()
