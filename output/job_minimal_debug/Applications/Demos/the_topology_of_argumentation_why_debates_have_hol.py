#!/usr/bin/env python3
"""
Demo: The Topology of Argumentation
====================================
Demonstrates the argumentation complex construction, defense filtration,
and key properties for several example frameworks.
"""

from itertools import combinations
from collections import defaultdict

class ArgFramework:
    """An argumentation framework AF = (A, R)."""
    
    def __init__(self, arguments, attacks):
        """
        arguments: list of argument names
        attacks: list of (a, b) pairs meaning a attacks b
        """
        self.arguments = list(arguments)
        self.attacks = set(attacks)
        self._attack_dict = defaultdict(set)
        for a, b in attacks:
            self._attack_dict[b].add(a)
    
    def attackers(self, arg):
        """Return the set of arguments that attack arg."""
        return self._attack_dict[arg]
    
    def is_conflict_free(self, S):
        """Check if S is conflict-free."""
        S = set(S)
        for a in S:
            for b in S:
                if (a, b) in self.attacks:
                    return False
        return True
    
    def defends(self, S, a):
        """Check if S defends argument a."""
        S = set(S)
        for b in self.attackers(a):
            if not any((c, b) in self.attacks for c in S):
                return False
        return True
    
    def is_admissible(self, S):
        """Check if S is admissible."""
        S = set(S)
        if not self.is_conflict_free(S):
            return False
        return all(self.defends(S, a) for a in S)
    
    def is_preferred(self, S):
        """Check if S is a preferred extension (maximal admissible)."""
        S = set(S)
        if not self.is_admissible(S):
            return False
        for a in self.arguments:
            if a not in S:
                if self.is_admissible(S | {a}):
                    return False
        return True
    
    def is_stable(self, S):
        """Check if S is a stable extension."""
        S = set(S)
        if not self.is_conflict_free(S):
            return False
        for a in self.arguments:
            if a not in S:
                if not any((b, a) in self.attacks for b in S):
                    return False
        return True
    
    def all_conflict_free(self):
        """Return all conflict-free sets (faces of the argumentation complex)."""
        result = [frozenset()]
        for k in range(1, len(self.arguments) + 1):
            for combo in combinations(self.arguments, k):
                if self.is_conflict_free(combo):
                    result.append(frozenset(combo))
        return result
    
    def preferred_extensions(self):
        """Return all preferred extensions."""
        return [S for S in self.all_conflict_free() if self.is_preferred(S)]
    
    def stable_extensions(self):
        """Return all stable extensions."""
        return [S for S in self.all_conflict_free() if self.is_stable(S)]
    
    def defense_filtration(self, max_steps=None):
        """Compute the defense filtration F_0 ⊆ F_1 ⊆ ... until stabilization."""
        if max_steps is None:
            max_steps = len(self.arguments) + 1
        
        levels = [set()]  # F_0 = ∅
        for k in range(1, max_steps + 1):
            prev = levels[-1]
            next_level = set()
            for a in self.arguments:
                # a is defended by prev if every attacker has a counter-attacker in prev
                if self.defends(prev, a):
                    next_level.add(a)
            levels.append(next_level)
            if next_level == prev:
                break
        return levels
    
    def grounded_extension(self):
        """Compute the grounded extension (limit of defense filtration)."""
        levels = self.defense_filtration()
        return levels[-1]
    
    def f_vector(self):
        """Compute the f-vector of the argumentation complex.
        f[k] = number of faces of dimension k (-1 indexed: f[-1] = 1 for empty set).
        """
        cf = self.all_conflict_free()
        fvec = defaultdict(int)
        for S in cf:
            fvec[len(S) - 1] += 1
        return dict(sorted(fvec.items()))
    
    def euler_characteristic(self):
        """Compute the Euler characteristic of the argumentation complex."""
        fvec = self.f_vector()
        return sum((-1)**k * v for k, v in fvec.items())


def print_framework_analysis(name, af):
    """Run full analysis on an argumentation framework."""
    print(f"\n{'='*60}")
    print(f"Framework: {name}")
    print(f"Arguments: {af.arguments}")
    print(f"Attacks: {af.attacks}")
    print(f"{'='*60}")
    
    # Conflict-free sets
    cf = af.all_conflict_free()
    print(f"\nConflict-free sets ({len(cf)} total):")
    for S in sorted(cf, key=lambda s: (len(s), str(s))):
        print(f"  {set(S) if S else '{}'}")
    
    # f-vector
    fvec = af.f_vector()
    print(f"\nf-vector: {fvec}")
    print(f"Euler characteristic: {af.euler_characteristic()}")
    
    # Preferred extensions
    pref = af.preferred_extensions()
    print(f"\nPreferred extensions ({len(pref)}):")
    for S in pref:
        print(f"  {set(S)}")
    
    # Stable extensions
    stab = af.stable_extensions()
    print(f"\nStable extensions ({len(stab)}):")
    for S in stab:
        print(f"  {set(S)}")
    
    # Defense filtration
    levels = af.defense_filtration()
    print(f"\nDefense filtration:")
    for i, level in enumerate(levels):
        print(f"  F_{i} = {level if level else '{}'}")
    
    grounded = af.grounded_extension()
    print(f"\nGrounded extension: {grounded if grounded else '{}'}")
    
    # Verify: stable → preferred
    for S in stab:
        assert af.is_preferred(S), f"VIOLATION: {S} is stable but not preferred!"
    print("\n✓ Verified: every stable extension is preferred")
    
    # Verify: grounded ⊆ every preferred
    for S in pref:
        assert grounded <= S, f"VIOLATION: grounded not in preferred {S}!"
    print("✓ Verified: grounded extension ⊆ every preferred extension")
    
    # Defense depth analysis
    print(f"\nDefense depth analysis:")
    for a in af.arguments:
        depth = None
        for i, level in enumerate(levels):
            if a in level:
                depth = i
                break
        if depth is not None:
            print(f"  {a}: depth {depth}")
        else:
            print(f"  {a}: not in grounded extension")


# ============================================================
# Example 1: Simple chain A → B → C
# ============================================================
af1 = ArgFramework(
    ['A', 'B', 'C'],
    [('A', 'B'), ('B', 'C')]
)
print_framework_analysis("Chain: A → B → C", af1)

# ============================================================
# Example 2: Odd cycle (3-cycle) — classic source of H₁
# ============================================================
af2 = ArgFramework(
    ['A', 'B', 'C'],
    [('A', 'B'), ('B', 'C'), ('C', 'A')]
)
print_framework_analysis("3-Cycle: A → B → C → A", af2)

# ============================================================
# Example 3: Even cycle (4-cycle) — has two preferred extensions
# ============================================================
af3 = ArgFramework(
    ['A', 'B', 'C', 'D'],
    [('A', 'B'), ('B', 'C'), ('C', 'D'), ('D', 'A')]
)
print_framework_analysis("4-Cycle: A → B → C → D → A", af3)

# ============================================================
# Example 4: Self-attacker
# ============================================================
af4 = ArgFramework(
    ['A', 'B', 'C'],
    [('A', 'A'), ('B', 'C')]
)
print_framework_analysis("Self-attacker: A→A, B→C", af4)

# ============================================================
# Example 5: Symmetric framework (undirected conflict graph)
# ============================================================
af5 = ArgFramework(
    ['A', 'B', 'C', 'D'],
    [('A', 'B'), ('B', 'A'), ('C', 'D'), ('D', 'C')]
)
print_framework_analysis("Symmetric: A↔B, C↔D", af5)

# ============================================================
# Example 6: Diamond with defender
# ============================================================
af6 = ArgFramework(
    ['A', 'B', 'C', 'D', 'E'],
    [('A', 'B'), ('A', 'C'), ('B', 'D'), ('C', 'D'), ('D', 'E')]
)
print_framework_analysis("Diamond: A→{B,C}→D→E", af6)

# ============================================================
# Summary statistics
# ============================================================
print("\n" + "="*60)
print("SUMMARY OF EULER CHARACTERISTICS")
print("="*60)
examples = [
    ("Chain A→B→C", af1),
    ("3-Cycle", af2),
    ("4-Cycle", af3),
    ("Self-attacker", af4),
    ("Symmetric A↔B, C↔D", af5),
    ("Diamond", af6),
]
for name, af in examples:
    pref = af.preferred_extensions()
    grounded = af.grounded_extension()
    chi = af.euler_characteristic()
    print(f"  {name:30s}  χ = {chi:5.1f}  |pref| = {len(pref)}  |grounded| = {len(grounded)}")

print("\nNote: The Euler characteristic χ(K(AF)) encodes topological invariants")
print("of the argumentation structure. Differences between χ, |pref|, and")
print("|grounded| reveal the 'shape' of the debate.")


#!/usr/bin/env python3
"""
Visualization: Argumentation Complex Explorer
==============================================
Generates visualizations of argumentation frameworks and their complexes.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import combinations
from collections import defaultdict
import json


def compute_conflict_free(arguments, attacks):
    """Compute all conflict-free sets."""
    result = [frozenset()]
    attacks_set = set(attacks)
    for k in range(1, len(arguments) + 1):
        for combo in combinations(arguments, k):
            S = set(combo)
            ok = True
            for a in S:
                for b in S:
                    if (a, b) in attacks_set:
                        ok = False
                        break
                if not ok:
                    break
            if ok:
                result.append(frozenset(combo))
    return result


def compute_defense_filtration(arguments, attacks):
    """Compute defense filtration."""
    attacks_set = set(attacks)
    attack_dict = defaultdict(set)
    for a, b in attacks:
        attack_dict[b].add(a)

    levels = [set()]
    for _ in range(len(arguments) + 1):
        prev = levels[-1]
        next_level = set()
        for a in arguments:
            if all(any((c, b) in attacks_set for c in prev) for b in attack_dict[a]):
                next_level.add(a)
        levels.append(next_level)
        if next_level == prev:
            break
    return levels


def plot_argumentation_framework(arguments, attacks, title="Argumentation Framework", filename="af_graph.png"):
    """Plot the attack graph."""
    n = len(arguments)
    angles = np.linspace(0, 2*np.pi, n, endpoint=False)
    positions = {arg: (np.cos(a), np.sin(a)) for arg, a in zip(arguments, angles)}

    fig, ax = plt.subplots(1, 1, figsize=(8, 8))
    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(-1.5, 1.5)
    ax.set_aspect('equal')
    ax.set_title(title, fontsize=16, fontweight='bold')
    ax.axis('off')

    # Draw attacks
    for a, b in attacks:
        x1, y1 = positions[a]
        x2, y2 = positions[b]
        dx, dy = x2 - x1, y2 - y1
        length = np.sqrt(dx**2 + dy**2)
        if length > 0:
            shrink = 0.15
            ax.annotate("", xy=(x2 - shrink*dx/length, y2 - shrink*dy/length),
                        xytext=(x1 + shrink*dx/length, y1 + shrink*dy/length),
                        arrowprops=dict(arrowstyle="->", color="red", lw=2))

    # Draw arguments
    for arg, (x, y) in positions.items():
        circle = plt.Circle((x, y), 0.12, color='steelblue', ec='navy', lw=2, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y, arg, ha='center', va='center', fontsize=14,
                fontweight='bold', color='white', zorder=6)

    fig.tight_layout()
    fig.savefig(filename, dpi=150, bbox_inches='tight')
    plt.close(fig)
    print(f"Saved: {filename}")


def plot_f_vector_comparison(frameworks, filename="f_vectors.png"):
    """Plot f-vectors for multiple frameworks."""
    fig, axes = plt.subplots(2, 3, figsize=(15, 10))
    axes = axes.flatten()

    for idx, (name, args, atks) in enumerate(frameworks):
        if idx >= 6:
            break
        cf = compute_conflict_free(args, atks)
        fvec = defaultdict(int)
        for S in cf:
            fvec[len(S) - 1] += 1
        fvec = dict(sorted(fvec.items()))

        ax = axes[idx]
        dims = list(fvec.keys())
        counts = list(fvec.values())
        colors = ['#2ecc71' if d % 2 == 0 else '#e74c3c' for d in dims]
        ax.bar([str(d) for d in dims], counts, color=colors, edgecolor='black')
        ax.set_xlabel('Dimension', fontsize=11)
        ax.set_ylabel('Count', fontsize=11)
        ax.set_title(name, fontsize=12, fontweight='bold')

        chi = sum((-1)**k * v for k, v in fvec.items())
        ax.text(0.95, 0.95, f'χ = {chi:.0f}', transform=ax.transAxes,
                ha='right', va='top', fontsize=13,
                bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

    fig.suptitle('f-Vectors of Argumentation Complexes', fontsize=16, fontweight='bold')
    fig.tight_layout()
    fig.savefig(filename, dpi=150, bbox_inches='tight')
    plt.close(fig)
    print(f"Saved: {filename}")


def plot_defense_filtration(arguments, attacks, title, filename="defense_filtration.png"):
    """Visualize the defense filtration levels."""
    levels = compute_defense_filtration(arguments, attacks)

    fig, ax = plt.subplots(figsize=(10, 6))
    n_levels = len(levels)

    for i, level in enumerate(levels):
        y = n_levels - i - 1
        for j, arg in enumerate(arguments):
            color = '#2ecc71' if arg in level else '#e0e0e0'
            rect = mpatches.FancyBboxPatch((j * 1.5, y * 1.2), 1.0, 0.8,
                                            boxstyle="round,pad=0.1",
                                            facecolor=color, edgecolor='black')
            ax.add_patch(rect)
            ax.text(j * 1.5 + 0.5, y * 1.2 + 0.4, arg,
                    ha='center', va='center', fontsize=12, fontweight='bold')

        ax.text(-1.0, y * 1.2 + 0.4, f'F_{i}', ha='right', va='center',
                fontsize=14, fontweight='bold', color='navy')

    ax.set_xlim(-1.5, len(arguments) * 1.5 + 0.5)
    ax.set_ylim(-0.5, n_levels * 1.2 + 0.5)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title(f'Defense Filtration: {title}', fontsize=14, fontweight='bold')

    fig.tight_layout()
    fig.savefig(filename, dpi=150, bbox_inches='tight')
    plt.close(fig)
    print(f"Saved: {filename}")


if __name__ == "__main__":
    frameworks = [
        ("Chain A→B→C", ['A', 'B', 'C'], [('A', 'B'), ('B', 'C')]),
        ("3-Cycle", ['A', 'B', 'C'], [('A', 'B'), ('B', 'C'), ('C', 'A')]),
        ("4-Cycle", ['A', 'B', 'C', 'D'], [('A', 'B'), ('B', 'C'), ('C', 'D'), ('D', 'A')]),
        ("Self-attacker", ['A', 'B', 'C'], [('A', 'A'), ('B', 'C')]),
        ("Symmetric", ['A', 'B', 'C', 'D'], [('A', 'B'), ('B', 'A'), ('C', 'D'), ('D', 'C')]),
        ("Diamond", ['A', 'B', 'C', 'D', 'E'], [('A', 'B'), ('A', 'C'), ('B', 'D'), ('C', 'D'), ('D', 'E')]),
    ]

    # Plot individual framework
    for name, args, atks in frameworks[:3]:
        safe_name = name.replace(" ", "_").replace("→", "to").replace("↔", "bidi")
        plot_argumentation_framework(args, atks, name, f"{safe_name}.png")

    # f-vector comparison
    plot_f_vector_comparison(frameworks)

    # Defense filtration
    plot_defense_filtration(['A', 'B', 'C', 'D', 'E'],
                           [('A', 'B'), ('A', 'C'), ('B', 'D'), ('C', 'D'), ('D', 'E')],
                           "Diamond Framework")

    print("\nAll visualizations generated successfully!")
