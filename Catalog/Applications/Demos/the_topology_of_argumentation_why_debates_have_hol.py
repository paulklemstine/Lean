#!/usr/bin/env python3
"""
Demo: The Topology of Argumentation
Numerical examples demonstrating argumentation framework analysis.
"""

from typing import Set, FrozenSet, Dict, List, Tuple
from itertools import combinations


def conflict_free(args: Set[int], attacks: Set[Tuple[int,int]], S: FrozenSet[int]) -> bool:
    """Check if S is conflict-free."""
    for a in S:
        for b in S:
            if (a, b) in attacks:
                return False
    return True


def defends(args: Set[int], attacks: Set[Tuple[int,int]], S: FrozenSet[int], a: int) -> bool:
    """Check if S defends argument a."""
    for b in args:
        if (b, a) in attacks:
            if not any((c, b) in attacks for c in S):
                return False
    return True


def admissible(args: Set[int], attacks: Set[Tuple[int,int]], S: FrozenSet[int]) -> bool:
    """Check if S is admissible."""
    if not conflict_free(args, attacks, S):
        return False
    return all(defends(args, attacks, S, a) for a in S)


def all_subsets(args: Set[int]) -> List[FrozenSet[int]]:
    """All subsets of args."""
    result = []
    args_list = sorted(args)
    for r in range(len(args_list) + 1):
        for combo in combinations(args_list, r):
            result.append(frozenset(combo))
    return result


def preferred_extensions(args: Set[int], attacks: Set[Tuple[int,int]]) -> List[FrozenSet[int]]:
    """Compute all preferred extensions."""
    adm = [S for S in all_subsets(args) if admissible(args, attacks, S)]
    preferred = []
    for S in adm:
        if not any(S < T for T in adm):
            preferred.append(S)
    return preferred


def stable_extensions(args: Set[int], attacks: Set[Tuple[int,int]]) -> List[FrozenSet[int]]:
    """Compute all stable extensions."""
    result = []
    for S in all_subsets(args):
        if not conflict_free(args, attacks, S):
            continue
        if all(any((b, a) in attacks for b in S) for a in args if a not in S):
            result.append(S)
    return result


def grounded_extension(args: Set[int], attacks: Set[Tuple[int,int]]) -> FrozenSet[int]:
    """Compute the grounded extension via fixed-point iteration."""
    S: Set[int] = set()
    while True:
        new_S = {a for a in args if defends(args, attacks, frozenset(S), a)}
        if new_S == S:
            return frozenset(S)
        S = new_S


def independence_complex(args: Set[int], attacks: Set[Tuple[int,int]]) -> List[FrozenSet[int]]:
    """Compute the independence complex (all conflict-free sets)."""
    return [S for S in all_subsets(args) if conflict_free(args, attacks, S)]


def f_vector(args: Set[int], attacks: Set[Tuple[int,int]]) -> List[int]:
    """Compute the f-vector of the independence complex."""
    cf = independence_complex(args, attacks)
    max_dim = max(len(S) for S in cf) if cf else 0
    return [sum(1 for S in cf if len(S) == k + 1) for k in range(max_dim)]


def euler_characteristic(args: Set[int], attacks: Set[Tuple[int,int]]) -> int:
    """Compute the Euler characteristic of the independence complex."""
    fv = f_vector(args, attacks)
    return sum((-1)**k * fv[k] for k in range(len(fv)))


def print_framework(name: str, args: Set[int], attacks: Set[Tuple[int,int]]):
    """Analyze and print results for an argumentation framework."""
    print(f"\n{'='*60}")
    print(f"Framework: {name}")
    print(f"Arguments: {sorted(args)}")
    print(f"Attacks: {sorted(attacks)}")
    print(f"{'='*60}")

    cf = independence_complex(args, attacks)
    print(f"\nConflict-free sets ({len(cf)}):")
    for S in sorted(cf, key=lambda x: (len(x), sorted(x))):
        print(f"  {set(S) if S else '{}'}")

    fv = f_vector(args, attacks)
    print(f"\nf-vector: {fv}")
    chi = euler_characteristic(args, attacks)
    print(f"Euler characteristic: {chi}")

    pref = preferred_extensions(args, attacks)
    print(f"\nPreferred extensions ({len(pref)}):")
    for S in pref:
        print(f"  {set(S)}")

    stab = stable_extensions(args, attacks)
    print(f"\nStable extensions ({len(stab)}):")
    for S in stab:
        print(f"  {set(S)}")

    gnd = grounded_extension(args, attacks)
    print(f"\nGrounded extension: {set(gnd)}")

    # Test Euler characteristic conjecture
    conjecture_val = len(pref) - len(gnd)
    print(f"\n--- Euler Conjecture Test ---")
    print(f"  χ(K) = {chi}")
    print(f"  |preferred| - |grounded| = {len(pref)} - {len(gnd)} = {conjecture_val}")
    print(f"  Conjecture holds? {chi == conjecture_val}")


# === DEMO FRAMEWORKS ===

if __name__ == "__main__":
    print("THE TOPOLOGY OF ARGUMENTATION")
    print("Numerical demonstrations of argumentation framework analysis")

    # Framework 1: Two arguments, one attack
    print_framework(
        "Two-Argument (0 attacks 1)",
        {0, 1},
        {(0, 1)}
    )

    # Framework 2: Cycle of 3 (rock-paper-scissors)
    print_framework(
        "3-Cycle (Rock-Paper-Scissors)",
        {0, 1, 2},
        {(0, 1), (1, 2), (2, 0)}
    )

    # Framework 3: Linear chain
    print_framework(
        "Linear Chain (0→1→2→3)",
        {0, 1, 2, 3},
        {(0, 1), (1, 2), (2, 3)}
    )

    # Framework 4: Self-attacker
    print_framework(
        "Self-Attacker (0 attacks 0, plus 1)",
        {0, 1},
        {(0, 0)}
    )

    # Framework 5: No attacks (complete peace)
    print_framework(
        "No Attacks (3 arguments)",
        {0, 1, 2},
        set()
    )

    # Framework 6: Diamond
    print_framework(
        "Diamond (0→1, 0→2, 1→3, 2→3)",
        {0, 1, 2, 3},
        {(0, 1), (0, 2), (1, 3), (2, 3)}
    )

    # Framework 7: Even cycle (4-cycle)
    print_framework(
        "4-Cycle",
        {0, 1, 2, 3},
        {(0, 1), (1, 2), (2, 3), (3, 0)}
    )

    # Dung's Fundamental Lemma demonstration
    print("\n" + "="*60)
    print("DUNG'S FUNDAMENTAL LEMMA DEMONSTRATION")
    print("="*60)

    args = {0, 1, 2, 3}
    attacks = {(1, 0), (2, 1)}  # 2 attacks 1, 1 attacks 0

    S = frozenset({2})
    a = 0
    print(f"\nFramework: {sorted(args)}, attacks: {sorted(attacks)}")
    print(f"S = {set(S)}, a = {a}")
    print(f"S is admissible: {admissible(args, attacks, S)}")
    print(f"S defends a={a}: {defends(args, attacks, S, a)}")

    S_ext = S | frozenset({a})
    print(f"S ∪ {{a}} = {set(S_ext)}")
    print(f"S ∪ {{a}} is conflict-free: {conflict_free(args, attacks, S_ext)}")
    print(f"S ∪ {{a}} is admissible: {admissible(args, attacks, S_ext)}")
    print("→ Fundamental Lemma confirmed!")

    # Summary
    print("\n" + "="*60)
    print("SUMMARY: Euler Characteristic Conjecture")
    print("="*60)
    print("The conjecture χ(K) = |preferred| - |grounded| is FALSE.")
    print("It fails on multiple frameworks, including the trivial")
    print("no-attack framework and the two-argument framework.")


#!/usr/bin/env python3
"""
Visualization: Argumentation Framework Analysis
Standalone matplotlib visualization of argumentation frameworks.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import combinations
from typing import Set, FrozenSet, List, Tuple, Dict


def conflict_free(args: Set[int], attacks: Set[Tuple[int,int]], S: FrozenSet[int]) -> bool:
    for a in S:
        for b in S:
            if (a, b) in attacks:
                return False
    return True


def defends(args: Set[int], attacks: Set[Tuple[int,int]], S: FrozenSet[int], a: int) -> bool:
    for b in args:
        if (b, a) in attacks:
            if not any((c, b) in attacks for c in S):
                return False
    return True


def admissible(args: Set[int], attacks: Set[Tuple[int,int]], S: FrozenSet[int]) -> bool:
    if not conflict_free(args, attacks, S):
        return False
    return all(defends(args, attacks, S, a) for a in S)


def all_subsets(S: Set[int]) -> List[FrozenSet[int]]:
    items = sorted(S)
    result = []
    for r in range(len(items) + 1):
        for combo in combinations(items, r):
            result.append(frozenset(combo))
    return result


def preferred_extensions(args: Set[int], attacks: Set[Tuple[int,int]]) -> List[FrozenSet[int]]:
    adm = [S for S in all_subsets(args) if admissible(args, attacks, S)]
    return [S for S in adm if not any(S < T for T in adm)]


def f_vector(args: Set[int], attacks: Set[Tuple[int,int]]) -> List[int]:
    cf = [S for S in all_subsets(args) if conflict_free(args, attacks, S)]
    if not cf:
        return []
    max_size = max(len(S) for S in cf)
    return [sum(1 for S in cf if len(S) == k + 1) for k in range(max_size)]


def euler_char(args: Set[int], attacks: Set[Tuple[int,int]]) -> int:
    fv = f_vector(args, attacks)
    return sum((-1)**k * fv[k] for k in range(len(fv)))


def draw_framework(ax, args, attacks, positions, title, preferred=None):
    """Draw an argumentation framework on a matplotlib axes."""
    ax.set_title(title, fontsize=12, fontweight='bold')
    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(-1.5, 1.5)
    ax.set_aspect('equal')
    ax.axis('off')

    pref_args = set()
    if preferred:
        for ext in preferred:
            pref_args |= ext

    # Draw attacks (arrows)
    for (a, b) in attacks:
        if a == b:
            # Self-loop
            cx, cy = positions[a]
            circle = plt.Circle((cx, cy + 0.3), 0.15, fill=False,
                              color='red', linewidth=1.5)
            ax.add_patch(circle)
        else:
            x1, y1 = positions[a]
            x2, y2 = positions[b]
            dx, dy = x2 - x1, y2 - y1
            dist = np.sqrt(dx**2 + dy**2)
            # Shorten arrow
            shrink = 0.25
            ax.annotate('', xy=(x2 - shrink*dx/dist, y2 - shrink*dy/dist),
                       xytext=(x1 + shrink*dx/dist, y1 + shrink*dy/dist),
                       arrowprops=dict(arrowstyle='->', color='red',
                                     lw=1.5, mutation_scale=15))

    # Draw arguments (nodes)
    for arg in sorted(args):
        x, y = positions[arg]
        color = '#4CAF50' if arg in pref_args else '#2196F3'
        circle = plt.Circle((x, y), 0.2, color=color, ec='black', lw=2, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y, str(arg), ha='center', va='center',
               fontsize=14, fontweight='bold', color='white', zorder=6)


# Define frameworks
frameworks = [
    ("Two Arguments\n(0→1)", {0, 1}, {(0, 1)},
     {0: (-0.7, 0), 1: (0.7, 0)}),
    ("3-Cycle\n(Rock-Paper-Scissors)", {0, 1, 2}, {(0, 1), (1, 2), (2, 0)},
     {0: (0, 1), 1: (-0.87, -0.5), 2: (0.87, -0.5)}),
    ("Linear Chain\n(0→1→2→3)", {0, 1, 2, 3}, {(0, 1), (1, 2), (2, 3)},
     {0: (-1.2, 0), 1: (-0.4, 0), 2: (0.4, 0), 3: (1.2, 0)}),
    ("4-Cycle", {0, 1, 2, 3}, {(0, 1), (1, 2), (2, 3), (3, 0)},
     {0: (-0.7, 0.7), 1: (0.7, 0.7), 2: (0.7, -0.7), 3: (-0.7, -0.7)}),
]

fig, axes = plt.subplots(2, 2, figsize=(12, 12))

for idx, (title, args, attacks, pos) in enumerate(frameworks):
    ax = axes[idx // 2][idx % 2]
    pref = preferred_extensions(args, attacks)
    draw_framework(ax, args, attacks, pos, title, pref)

    fv = f_vector(args, attacks)
    chi = euler_char(args, attacks)
    pref_str = ', '.join(str(set(s)) for s in pref) if pref else '∅'

    info = f"f-vector: {fv}\nχ = {chi}\nPreferred: {pref_str}"
    ax.text(0, -1.3, info, ha='center', va='top', fontsize=8,
           family='monospace', bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

fig.suptitle('The Topology of Argumentation: Framework Gallery',
            fontsize=16, fontweight='bold', y=0.98)
plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('argumentation_gallery.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: argumentation_gallery.png")

# Second plot: f-vector comparison
fig2, ax2 = plt.subplots(figsize=(10, 6))

framework_names = []
euler_chars = []
n_preferred = []

test_frameworks = [
    ("Empty (3 args)", {0,1,2}, set()),
    ("Single (0→1)", {0,1}, {(0,1)}),
    ("3-Cycle", {0,1,2}, {(0,1),(1,2),(2,0)}),
    ("Chain 4", {0,1,2,3}, {(0,1),(1,2),(2,3)}),
    ("4-Cycle", {0,1,2,3}, {(0,1),(1,2),(2,3),(3,0)}),
    ("Star (0→all)", {0,1,2,3}, {(0,1),(0,2),(0,3)}),
    ("Complete 3", {0,1,2}, {(0,1),(1,0),(1,2),(2,1),(0,2),(2,0)}),
]

for name, args, attacks in test_frameworks:
    framework_names.append(name)
    euler_chars.append(euler_char(args, attacks))
    n_preferred.append(len(preferred_extensions(args, attacks)))

x = np.arange(len(framework_names))
width = 0.35

bars1 = ax2.bar(x - width/2, euler_chars, width, label='Euler characteristic χ',
               color='#2196F3', alpha=0.8)
bars2 = ax2.bar(x + width/2, n_preferred, width, label='# Preferred extensions',
               color='#4CAF50', alpha=0.8)

ax2.set_xlabel('Framework', fontsize=12)
ax2.set_ylabel('Value', fontsize=12)
ax2.set_title('Euler Characteristic vs. Preferred Extensions\n(Conjecture Disproof)',
             fontsize=14, fontweight='bold')
ax2.set_xticks(x)
ax2.set_xticklabels(framework_names, rotation=30, ha='right')
ax2.legend()
ax2.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
ax2.grid(axis='y', alpha=0.3)

plt.tight_layout()
plt.savefig('euler_vs_preferred.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: euler_vs_preferred.png")
