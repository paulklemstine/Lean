#!/usr/bin/env python3
"""
Applications of Argumentation Topology
========================================

Real-world applications of the formal theory:
1. Policy debate analysis
2. Legal reasoning framework
3. Scientific hypothesis evaluation
"""

from itertools import combinations
from collections import defaultdict
from typing import Set, FrozenSet, List, Tuple, Dict


class ArgFramework:
    """Argumentation framework AF = (A, R)."""
    def __init__(self, arguments: Set[str], attacks: Set[Tuple[str, str]]):
        self.arguments = frozenset(arguments)
        self.attacks = frozenset(attacks)
        self._attackers: Dict[str, Set[str]] = defaultdict(set)
        for a, b in attacks:
            self._attackers[b].add(a)

    def attackers_of(self, a: str) -> Set[str]:
        return self._attackers.get(a, set())

    def is_conflict_free(self, S: FrozenSet[str]) -> bool:
        for a, b in self.attacks:
            if a in S and b in S:
                return False
        return True

    def is_acceptable(self, S: FrozenSet[str], a: str) -> bool:
        for b in self.attackers_of(a):
            if not any(c in S for c in self.attackers_of(b)):
                return False
        return True

    def is_admissible(self, S: FrozenSet[str]) -> bool:
        if not self.is_conflict_free(S):
            return False
        return all(self.is_acceptable(S, a) for a in S)

    def preferred_extensions(self) -> List[FrozenSet[str]]:
        args = sorted(self.arguments)
        admissible = []
        for r in range(len(args) + 1):
            for sub in combinations(args, r):
                S = frozenset(sub)
                if self.is_admissible(S):
                    admissible.append(S)
        return [S for S in admissible if not any(S < T for T in admissible)]

    def grounded_extension(self) -> FrozenSet[str]:
        S = frozenset()
        for _ in range(len(self.arguments) + 1):
            S_new = frozenset(a for a in self.arguments if self.is_acceptable(S, a))
            if S_new == S:
                return S
            S = S_new
        return S

    def euler_characteristic(self) -> int:
        chi = 0
        args = sorted(self.arguments)
        for r in range(1, len(args) + 1):
            for sub in combinations(args, r):
                if self.is_conflict_free(frozenset(sub)):
                    chi += (-1) ** (r - 1)
        return chi


# ═══════════════════════════════════════════════════════════════
# Application 1: Policy Debate Analysis
# ═══════════════════════════════════════════════════════════════

def policy_debate():
    """Analyze a climate policy debate using argumentation topology."""
    print("=" * 60)
    print("APPLICATION 1: Climate Policy Debate")
    print("=" * 60)

    # Arguments in the debate
    args = {
        "carbon_tax",      # Implement carbon tax
        "econ_harm",       # Carbon tax harms economy
        "green_jobs",      # Green transition creates jobs
        "nuclear",         # Nuclear power is the solution
        "renewables",      # Renewables are sufficient
        "baseload",        # Need baseload power (attacks renewables-only)
        "safety_risk",     # Nuclear has safety risks
    }

    # Attack relation
    attacks = {
        ("econ_harm", "carbon_tax"),     # Economic harm undermines carbon tax
        ("green_jobs", "econ_harm"),     # Green jobs counter economic harm
        ("nuclear", "renewables"),       # Nuclear vs renewables-only
        ("renewables", "nuclear"),       # Renewables vs nuclear
        ("baseload", "renewables"),      # Baseload need attacks renewables
        ("safety_risk", "nuclear"),      # Safety risk attacks nuclear
        ("carbon_tax", "baseload"),      # Carbon tax makes renewables viable
    }

    AF = ArgFramework(arguments=args, attacks=attacks)

    pref = AF.preferred_extensions()
    grd = AF.grounded_extension()
    chi = AF.euler_characteristic()

    print(f"\nArguments ({len(args)}):")
    for a in sorted(args):
        print(f"  • {a}")

    print(f"\nAttack relations ({len(attacks)}):")
    for a, b in sorted(attacks):
        print(f"  {a} → {b}")

    print(f"\nPreferred extensions ({len(pref)}):")
    for i, S in enumerate(pref, 1):
        print(f"  Position {i}: {set(S)}")

    print(f"\nGrounded extension (universally accepted):")
    print(f"  {set(grd)}")

    print(f"\nEuler characteristic χ(K(AF)): {chi}")
    print(f"  (measures topological complexity of the debate)")
    print()


# ═══════════════════════════════════════════════════════════════
# Application 2: Legal Reasoning
# ═══════════════════════════════════════════════════════════════

def legal_reasoning():
    """Model a legal argument using argumentation frameworks."""
    print("=" * 60)
    print("APPLICATION 2: Legal Reasoning")
    print("=" * 60)

    args = {
        "guilty",          # Defendant is guilty
        "alibi",           # Defendant has alibi
        "witness",         # Witness saw defendant at scene
        "unreliable",      # Witness is unreliable
        "motive",          # Defendant has motive
        "no_evidence",     # No physical evidence
    }

    attacks = {
        ("alibi", "guilty"),         # Alibi defeats guilt
        ("witness", "alibi"),        # Witness contradicts alibi
        ("unreliable", "witness"),   # Unreliability defeats witness
        ("no_evidence", "guilty"),   # No evidence defeats guilt
        ("motive", "no_evidence"),   # Motive counters lack of evidence
    }

    AF = ArgFramework(arguments=args, attacks=attacks)

    pref = AF.preferred_extensions()
    grd = AF.grounded_extension()

    print(f"\nPreferred extensions (coherent legal positions):")
    for i, S in enumerate(pref, 1):
        verdict = "GUILTY" if "guilty" in S else "NOT GUILTY"
        print(f"  Position {i} [{verdict}]: {set(S)}")

    print(f"\nGrounded extension (minimum defensible position):")
    print(f"  {set(grd)}")
    print()


# ═══════════════════════════════════════════════════════════════
# Application 3: Scientific Hypothesis Evaluation
# ═══════════════════════════════════════════════════════════════

def scientific_hypotheses():
    """Evaluate competing scientific hypotheses."""
    print("=" * 60)
    print("APPLICATION 3: Scientific Hypothesis Evaluation")
    print("=" * 60)

    args = {
        "dark_matter",     # Dark matter particles exist
        "mond",            # Modified gravity (MOND)
        "galaxy_curves",   # Galaxy rotation curves need explanation
        "bullet_cluster",  # Bullet cluster evidence
        "no_detection",    # No direct DM detection
        "dm_predicts",     # DM predicts large-scale structure
    }

    attacks = {
        ("mond", "dark_matter"),      # MOND vs DM
        ("dark_matter", "mond"),      # DM vs MOND
        ("bullet_cluster", "mond"),   # Bullet cluster defeats MOND
        ("no_detection", "dark_matter"),  # No detection weakens DM
        ("dm_predicts", "no_detection"), # Predictions counter no-detection
    }

    AF = ArgFramework(arguments=args, attacks=attacks)

    pref = AF.preferred_extensions()
    grd = AF.grounded_extension()
    chi = AF.euler_characteristic()

    print(f"\nPreferred extensions (coherent scientific positions):")
    for i, S in enumerate(pref, 1):
        label = "Dark Matter" if "dark_matter" in S else "MOND" if "mond" in S else "Mixed"
        print(f"  Position {i} [{label}]: {set(S)}")

    print(f"\nGrounded extension: {set(grd)}")
    print(f"Euler characteristic: {chi}")

    # Interpret
    if len(pref) > 1:
        print(f"\n→ The debate has {len(pref)} incompatible coherent positions")
        print(f"  (topological 'holes' in the argument structure)")
    print()


if __name__ == "__main__":
    policy_debate()
    legal_reasoning()
    scientific_hypotheses()


#!/usr/bin/env python3
"""
Demo: The Topology of Argumentation
====================================
Demonstrates argumentation frameworks, conflict-free sets, admissible sets,
preferred extensions, and the argumentation complex.
"""

from itertools import combinations


class ArgFramework:
    """Dung's argumentation framework AF = (A, R)."""

    def __init__(self, arguments: set, attacks: set):
        self.arguments = arguments
        self.attacks = attacks  # set of (a, b) meaning a attacks b

    def is_conflict_free(self, S: frozenset) -> bool:
        """Check if S is conflict-free (no internal attacks)."""
        for a in S:
            for b in S:
                if (a, b) in self.attacks:
                    return False
        return True

    def is_acceptable(self, S: frozenset, a) -> bool:
        """Check if argument a is acceptable w.r.t. S."""
        for b in self.arguments:
            if (b, a) in self.attacks:
                # b attacks a; need some c in S that attacks b
                if not any((c, b) in self.attacks for c in S):
                    return False
        return True

    def is_admissible(self, S: frozenset) -> bool:
        """Check if S is admissible (conflict-free + self-defending)."""
        if not self.is_conflict_free(S):
            return False
        return all(self.is_acceptable(S, a) for a in S)

    def char_func(self, S: frozenset) -> frozenset:
        """Characteristic function F(S) = {a | a is acceptable w.r.t. S}."""
        return frozenset(a for a in self.arguments if self.is_acceptable(S, a))

    def preferred_extensions(self) -> list:
        """Find all preferred (maximal admissible) extensions."""
        admissible_sets = []
        for r in range(len(self.arguments) + 1):
            for subset in combinations(self.arguments, r):
                S = frozenset(subset)
                if self.is_admissible(S):
                    admissible_sets.append(S)

        # Filter to maximal
        preferred = []
        for S in admissible_sets:
            if not any(S < T for T in admissible_sets):
                preferred.append(S)
        return preferred

    def grounded_extension(self) -> frozenset:
        """Compute grounded extension (least fixed point of F)."""
        S = frozenset()
        while True:
            S_new = self.char_func(S)
            if S_new == S:
                return S
            S = S_new

    def conflict_free_sets(self) -> list:
        """All conflict-free sets (the argumentation complex)."""
        result = []
        for r in range(len(self.arguments) + 1):
            for subset in combinations(self.arguments, r):
                S = frozenset(subset)
                if self.is_conflict_free(S):
                    result.append(S)
        return result

    def euler_characteristic(self) -> int:
        """Euler characteristic of the argumentation complex."""
        cf_sets = self.conflict_free_sets()
        chi = 0
        for S in cf_sets:
            if len(S) > 0:  # exclude empty set from simplex count
                chi += (-1) ** (len(S) - 1)
        return chi


def demo_basic():
    """Demo 1: Basic argumentation framework."""
    print("=" * 60)
    print("DEMO 1: Basic Argumentation Framework")
    print("=" * 60)

    # Three-argument framework: a attacks b, b attacks c
    AF = ArgFramework(
        arguments={'a', 'b', 'c'},
        attacks={('a', 'b'), ('b', 'c')}
    )

    print(f"Arguments: {AF.arguments}")
    print(f"Attacks: {AF.attacks}")
    print()

    # Conflict-free sets
    cf = AF.conflict_free_sets()
    print(f"Conflict-free sets ({len(cf)} total):")
    for S in sorted(cf, key=lambda s: (len(s), sorted(s))):
        print(f"  {set(S) if S else '{}'}")

    print()
    # Preferred extensions
    pref = AF.preferred_extensions()
    print(f"Preferred extensions ({len(pref)}):")
    for S in pref:
        print(f"  {set(S)}")

    # Grounded extension
    grd = AF.grounded_extension()
    print(f"Grounded extension: {set(grd)}")

    # Euler characteristic
    chi = AF.euler_characteristic()
    print(f"Euler characteristic χ(K(AF)): {chi}")
    print()


def demo_cycle():
    """Demo 2: Odd cycle — circular argumentation."""
    print("=" * 60)
    print("DEMO 2: Odd Cycle (Circular Argument)")
    print("=" * 60)

    # 3-cycle: a→b→c→a
    AF = ArgFramework(
        arguments={'a', 'b', 'c'},
        attacks={('a', 'b'), ('b', 'c'), ('c', 'a')}
    )

    print(f"Arguments: {AF.arguments}")
    print(f"Attacks (cycle): a→b→c→a")
    print()

    cf = AF.conflict_free_sets()
    print(f"Conflict-free sets ({len(cf)}):")
    for S in sorted(cf, key=lambda s: (len(s), sorted(s))):
        print(f"  {set(S) if S else '{}'}")

    pref = AF.preferred_extensions()
    print(f"\nPreferred extensions ({len(pref)}):")
    for S in pref:
        print(f"  {set(S)}")

    grd = AF.grounded_extension()
    print(f"Grounded extension: {set(grd)}")

    chi = AF.euler_characteristic()
    print(f"Euler characteristic χ: {chi}")
    print()


def demo_complete():
    """Demo 3: Complete attack graph."""
    print("=" * 60)
    print("DEMO 3: Complete Attack Graph (Everyone Attacks Everyone)")
    print("=" * 60)

    n = 4
    args = set(range(1, n + 1))
    attacks = {(a, b) for a in args for b in args if a != b}

    AF = ArgFramework(arguments=args, attacks=attacks)

    cf = AF.conflict_free_sets()
    print(f"|A| = {n}, complete attacks")
    print(f"Conflict-free sets ({len(cf)}):")
    for S in sorted(cf, key=lambda s: (len(s), sorted(s))):
        print(f"  {set(S) if S else '{}'}")

    # Verify: max size is 1 (our theorem!)
    max_size = max(len(S) for S in cf)
    print(f"\nMax conflict-free set size: {max_size} (theorem: ≤ 1) ✓")

    pref = AF.preferred_extensions()
    print(f"Preferred extensions ({len(pref)}): {[set(S) for S in pref]}")
    print()


def demo_no_attacks():
    """Demo 4: No attacks — unique preferred extension."""
    print("=" * 60)
    print("DEMO 4: No Attacks (Peaceful Debate)")
    print("=" * 60)

    args = {'p', 'q', 'r', 's'}
    AF = ArgFramework(arguments=args, attacks=set())

    print(f"Arguments: {args}, Attacks: ∅")
    pref = AF.preferred_extensions()
    print(f"Preferred extensions: {[set(S) for S in pref]}")
    print(f"Unique preferred = full set? {pref[0] == frozenset(args)} ✓")

    cf = AF.conflict_free_sets()
    print(f"All {len(cf)} subsets are conflict-free (2^{len(args)} = {2**len(args)}) ✓")

    chi = AF.euler_characteristic()
    print(f"Euler characteristic: {chi}")
    print()


def demo_euler_test():
    """Demo 5: Systematic Euler characteristic test."""
    print("=" * 60)
    print("DEMO 5: Euler Characteristic Survey")
    print("=" * 60)
    print()

    import random
    random.seed(42)

    print(f"{'|A|':>4} {'|R|':>4} {'|CF|':>6} {'χ':>4} {'|Pref|':>6} {'|Grd|':>5}")
    print("-" * 40)

    for trial in range(15):
        n = random.randint(2, 5)
        args = set(range(n))
        # Random attacks with probability 0.3
        attacks = set()
        for a in args:
            for b in args:
                if a != b and random.random() < 0.3:
                    attacks.add((a, b))

        AF = ArgFramework(arguments=args, attacks=attacks)
        cf = AF.conflict_free_sets()
        chi = AF.euler_characteristic()
        pref = AF.preferred_extensions()
        grd = AF.grounded_extension()

        print(f"{n:>4} {len(attacks):>4} {len(cf):>6} {chi:>4} {len(pref):>6} {len(grd):>5}")

    print()


if __name__ == "__main__":
    demo_basic()
    demo_cycle()
    demo_complete()
    demo_no_attacks()
    demo_euler_test()


"""
Visualization: The Argumentation Complex
==========================================
Visualizes the simplicial complex of conflict-free sets for several
argumentation frameworks, showing how the topological structure captures
the "shape" of a debate.

Uses matplotlib to create a comparison of attack graphs alongside their
argumentation complexes, rendered as set diagrams.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import combinations
from collections import defaultdict


class ArgFramework:
    def __init__(self, arguments, attacks):
        self.arguments = frozenset(arguments)
        self.attacks = frozenset(attacks)

    def is_conflict_free(self, S):
        for a, b in self.attacks:
            if a in S and b in S:
                return False
        return True

    def conflict_free_sets(self):
        args = sorted(self.arguments, key=str)
        result = [frozenset()]
        for r in range(1, len(args) + 1):
            for sub in combinations(args, r):
                S = frozenset(sub)
                if self.is_conflict_free(S):
                    result.append(S)
        return result

    def euler_char(self):
        chi = 0
        for S in self.conflict_free_sets():
            if len(S) > 0:
                chi += (-1) ** (len(S) - 1)
        return chi


def draw_attack_graph(ax, args, attacks, title, positions):
    """Draw the attack graph with arrows."""
    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(-1.5, 1.5)
    ax.set_aspect('equal')
    ax.set_title(title, fontsize=12, fontweight='bold')
    ax.axis('off')

    # Draw attacks as arrows
    for a, b in attacks:
        xa, ya = positions[a]
        xb, yb = positions[b]
        dx, dy = xb - xa, yb - ya
        dist = np.sqrt(dx**2 + dy**2)
        if dist > 0:
            # Shorten arrow
            shrink = 0.25
            ax.annotate("", xy=(xb - shrink * dx / dist, yb - shrink * dy / dist),
                        xytext=(xa + shrink * dx / dist, ya + shrink * dy / dist),
                        arrowprops=dict(arrowstyle="->", color="red",
                                       lw=1.5, connectionstyle="arc3,rad=0.1"))

    # Draw nodes
    for arg in args:
        x, y = positions[arg]
        circle = plt.Circle((x, y), 0.2, color='#4ECDC4', ec='#2C3E50', lw=2, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y, str(arg), ha='center', va='center', fontsize=10,
                fontweight='bold', zorder=6)


def draw_complex_bars(ax, af, title):
    """Draw a bar chart of the f-vector (face counts by dimension)."""
    cf = af.conflict_free_sets()
    max_dim = max((len(S) for S in cf), default=0)
    f_vec = [0] * (max_dim + 1)
    for S in cf:
        f_vec[len(S)] += 1

    dims = list(range(len(f_vec)))
    colors = ['#2C3E50', '#E74C3C', '#3498DB', '#2ECC71', '#9B59B6']

    bars = ax.bar(dims, f_vec, color=[colors[i % len(colors)] for i in dims],
                  edgecolor='white', linewidth=1.5)
    ax.set_xlabel('Dimension k', fontsize=10)
    ax.set_ylabel('Face count f_k', fontsize=10)
    ax.set_title(f'{title}\nχ = {af.euler_char()}', fontsize=11, fontweight='bold')
    ax.set_xticks(dims)
    ax.set_xticklabels([f'{d}' for d in dims])

    # Add value labels
    for bar, val in zip(bars, f_vec):
        if val > 0:
            ax.text(bar.get_x() + bar.get_width() / 2, bar.get_height() + 0.3,
                    str(val), ha='center', va='bottom', fontsize=9, fontweight='bold')


# Create figure with 3 examples
fig, axes = plt.subplots(2, 3, figsize=(14, 9))
fig.suptitle('The Argumentation Complex: Topology of Debates',
             fontsize=16, fontweight='bold', y=0.98)

# Example 1: Linear chain a→b→c
args1 = ['a', 'b', 'c']
attacks1 = [('a', 'b'), ('b', 'c')]
pos1 = {'a': (-1, 0), 'b': (0, 0), 'c': (1, 0)}
AF1 = ArgFramework(args1, attacks1)

draw_attack_graph(axes[0, 0], args1, attacks1, 'Linear: a→b→c', pos1)
draw_complex_bars(axes[1, 0], AF1, 'Linear Complex')

# Example 2: 3-cycle a→b→c→a
args2 = ['a', 'b', 'c']
attacks2 = [('a', 'b'), ('b', 'c'), ('c', 'a')]
pos2 = {'a': (0, 1), 'b': (-0.87, -0.5), 'c': (0.87, -0.5)}
AF2 = ArgFramework(args2, attacks2)

draw_attack_graph(axes[0, 1], args2, attacks2, 'Cycle: a→b→c→a', pos2)
draw_complex_bars(axes[1, 1], AF2, 'Cycle Complex')

# Example 3: Complete graph K4
args3 = [1, 2, 3, 4]
attacks3 = [(a, b) for a in args3 for b in args3 if a != b]
angle = np.pi / 4
pos3 = {i: (np.cos(angle + i * np.pi / 2), np.sin(angle + i * np.pi / 2)) for i in args3}
AF3 = ArgFramework(args3, attacks3)

draw_attack_graph(axes[0, 2], args3, attacks3, 'Complete: K₄', pos3)
draw_complex_bars(axes[1, 2], AF3, 'Complete Complex')

plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('argumentation_complex.png', dpi=150, bbox_inches='tight')
print("Saved: argumentation_complex.png")


"""
Visualization: Euler Characteristic Survey
=============================================
Computes the Euler characteristic of the argumentation complex for
many random frameworks and visualizes the distribution, testing the
conjecture that χ relates to the semantic properties of the framework.
"""

import matplotlib.pyplot as plt
import numpy as np
import random
from itertools import combinations
from collections import defaultdict


class ArgFramework:
    def __init__(self, arguments, attacks):
        self.arguments = frozenset(arguments)
        self.attacks = frozenset(attacks)
        self._attackers = defaultdict(set)
        for a, b in attacks:
            self._attackers[b].add(a)

    def attackers_of(self, a):
        return self._attackers.get(a, set())

    def is_conflict_free(self, S):
        for a, b in self.attacks:
            if a in S and b in S:
                return False
        return True

    def is_acceptable(self, S, a):
        for b in self.attackers_of(a):
            if not any(c in S for c in self.attackers_of(b)):
                return False
        return True

    def is_admissible(self, S):
        if not self.is_conflict_free(S):
            return False
        return all(self.is_acceptable(S, a) for a in S)

    def preferred_extensions(self):
        args = sorted(self.arguments)
        admissible = []
        for r in range(len(args) + 1):
            for sub in combinations(args, r):
                S = frozenset(sub)
                if self.is_admissible(S):
                    admissible.append(S)
        return [S for S in admissible if not any(S < T for T in admissible)]

    def grounded_extension(self):
        S = frozenset()
        for _ in range(len(self.arguments) + 1):
            S_new = frozenset(a for a in self.arguments
                              if self.is_acceptable(S, a))
            if S_new == S:
                return S
            S = S_new
        return S

    def euler_characteristic(self):
        chi = 0
        args = sorted(self.arguments)
        for r in range(1, len(args) + 1):
            for sub in combinations(args, r):
                if self.is_conflict_free(frozenset(sub)):
                    chi += (-1) ** (r - 1)
        return chi


# Generate random frameworks and compute properties
random.seed(42)
n_samples = 200
data = []

for _ in range(n_samples):
    n = random.randint(3, 6)
    args = set(range(n))
    p = random.uniform(0.0, 0.6)
    attacks = set()
    for a in args:
        for b in args:
            if a != b and random.random() < p:
                attacks.add((a, b))

    AF = ArgFramework(arguments=args, attacks=attacks)
    chi = AF.euler_characteristic()
    pref = AF.preferred_extensions()
    grd = AF.grounded_extension()

    data.append({
        'n': n,
        'r': len(attacks),
        'chi': chi,
        'n_pref': len(pref),
        'grd_size': len(grd),
        'density': len(attacks) / (n * (n - 1)) if n > 1 else 0
    })

# Create visualization
fig, axes = plt.subplots(2, 2, figsize=(12, 10))
fig.suptitle('Euler Characteristic of Argumentation Complexes\n(Survey of 200 Random Frameworks)',
             fontsize=14, fontweight='bold')

# Plot 1: χ vs attack density
ax1 = axes[0, 0]
densities = [d['density'] for d in data]
chis = [d['chi'] for d in data]
colors_by_n = {3: '#E74C3C', 4: '#3498DB', 5: '#2ECC71', 6: '#9B59B6'}
for d in data:
    ax1.scatter(d['density'], d['chi'], c=colors_by_n.get(d['n'], 'gray'),
                s=30, alpha=0.6, edgecolors='none')
ax1.set_xlabel('Attack Density |R|/(|A|·(|A|-1))', fontsize=10)
ax1.set_ylabel('Euler Characteristic χ', fontsize=10)
ax1.set_title('χ vs Attack Density', fontsize=11)
ax1.axhline(y=1, color='red', linestyle='--', alpha=0.5, label='χ=1 (full simplex)')
ax1.legend(fontsize=8)

# Plot 2: χ vs number of preferred extensions
ax2 = axes[0, 1]
n_prefs = [d['n_pref'] for d in data]
ax2.scatter(n_prefs, chis, c='#3498DB', s=30, alpha=0.5, edgecolors='none')
ax2.set_xlabel('Number of Preferred Extensions', fontsize=10)
ax2.set_ylabel('Euler Characteristic χ', fontsize=10)
ax2.set_title('χ vs |Preferred Extensions|', fontsize=11)

# Plot 3: Distribution of χ
ax3 = axes[1, 0]
chi_values = [d['chi'] for d in data]
bins = range(min(chi_values) - 1, max(chi_values) + 2)
ax3.hist(chi_values, bins=bins, color='#2ECC71', edgecolor='white', linewidth=1.5, align='left')
ax3.set_xlabel('Euler Characteristic χ', fontsize=10)
ax3.set_ylabel('Frequency', fontsize=10)
ax3.set_title('Distribution of χ', fontsize=11)
ax3.axvline(x=1, color='red', linestyle='--', alpha=0.7, label='χ=1')
ax3.legend(fontsize=8)

# Plot 4: |Preferred| vs |Grounded|
ax4 = axes[1, 1]
grd_sizes = [d['grd_size'] for d in data]
sc = ax4.scatter(grd_sizes, n_prefs, c=chis, cmap='RdYlBu', s=40,
                 alpha=0.7, edgecolors='gray', linewidth=0.5)
ax4.set_xlabel('Grounded Extension Size |GE|', fontsize=10)
ax4.set_ylabel('Number of Preferred Extensions', fontsize=10)
ax4.set_title('Semantic vs Topological Structure', fontsize=11)
plt.colorbar(sc, ax=ax4, label='χ')

plt.tight_layout(rect=[0, 0, 1, 0.93])
plt.savefig('euler_survey.png', dpi=150, bbox_inches='tight')
print("Saved: euler_survey.png")


"""
Visualization: The Fundamental Lemma in Action
=================================================
Shows how admissible sets grow step-by-step via the Fundamental Lemma:
starting from ∅, we iteratively add acceptable arguments to build
a preferred extension.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import combinations
from collections import defaultdict


class ArgFramework:
    def __init__(self, arguments, attacks):
        self.arguments = frozenset(arguments)
        self.attacks = frozenset(attacks)
        self._attackers = defaultdict(set)
        self._targets = defaultdict(set)
        for a, b in attacks:
            self._attackers[b].add(a)
            self._targets[a].add(b)

    def attackers_of(self, a):
        return self._attackers.get(a, set())

    def is_conflict_free(self, S):
        for a, b in self.attacks:
            if a in S and b in S:
                return False
        return True

    def is_acceptable(self, S, a):
        for b in self.attackers_of(a):
            if not any(c in S for c in self.attackers_of(b)):
                return False
        return True

    def is_admissible(self, S):
        if not self.is_conflict_free(S):
            return False
        return all(self.is_acceptable(S, a) for a in S)


def build_preferred_steps(af):
    """Build a preferred extension step by step, recording each addition."""
    S = set()
    steps = [frozenset(S)]
    reasons = ["Start: ∅ is admissible"]

    args_ordered = sorted(af.arguments, key=str)
    changed = True
    while changed:
        changed = False
        for a in args_ordered:
            if a in S:
                continue
            S_with_a = frozenset(S | {a})
            if af.is_conflict_free(S_with_a) and af.is_acceptable(frozenset(S), a):
                S.add(a)
                steps.append(frozenset(S))

                # Build reason
                attackers = af.attackers_of(a)
                if not attackers:
                    reason = f"Add '{a}': no attackers (trivially acceptable)"
                else:
                    defenders = []
                    for b in attackers:
                        for c in S:
                            if c in af.attackers_of(b):
                                defenders.append(f"'{c}' defends against '{b}'")
                    reason = f"Add '{a}': {'; '.join(defenders) if defenders else 'acceptable'}"
                reasons.append(reason)
                changed = True
                break

    return steps, reasons


# Framework: a debate about AI safety
args = ['safe_ai', 'risk', 'alignment', 'pause', 'accelerate', 'regulation']
attacks = [
    ('risk', 'safe_ai'),       # Risk claims AI isn't safe
    ('alignment', 'risk'),      # Alignment research counters risk
    ('pause', 'accelerate'),    # Pause vs accelerate
    ('accelerate', 'pause'),    # Accelerate vs pause
    ('regulation', 'risk'),     # Regulation addresses risk
    ('risk', 'accelerate'),     # Risk argues against acceleration
]

AF = ArgFramework(set(args), set(attacks))
steps, reasons = build_preferred_steps(AF)

# Layout
n_steps = len(steps)
fig, axes = plt.subplots(1, n_steps, figsize=(4 * n_steps, 5))
if n_steps == 1:
    axes = [axes]

fig.suptitle('The Fundamental Lemma: Building a Preferred Extension Step by Step',
             fontsize=14, fontweight='bold', y=1.02)

# Argument positions (circular layout)
n_args = len(args)
positions = {}
for i, a in enumerate(sorted(args)):
    angle = 2 * np.pi * i / n_args - np.pi / 2
    positions[a] = (np.cos(angle), np.sin(angle))

for step_idx, (step, reason) in enumerate(zip(steps, reasons)):
    ax = axes[step_idx]
    ax.set_xlim(-1.8, 1.8)
    ax.set_ylim(-1.8, 1.8)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title(f'Step {step_idx}', fontsize=11, fontweight='bold')

    # Draw attacks
    for a, b in attacks:
        xa, ya = positions[a]
        xb, yb = positions[b]
        dx, dy = xb - xa, yb - ya
        dist = np.sqrt(dx**2 + dy**2)
        if dist > 0:
            shrink = 0.22
            ax.annotate("", xy=(xb - shrink * dx / dist, yb - shrink * dy / dist),
                        xytext=(xa + shrink * dx / dist, ya + shrink * dy / dist),
                        arrowprops=dict(arrowstyle="->", color="#BDC3C7",
                                       lw=1, connectionstyle="arc3,rad=0.15"))

    # Draw arguments
    for a in sorted(args):
        x, y = positions[a]
        if a in step:
            color = '#2ECC71'  # In admissible set
            ec = '#27AE60'
        else:
            # Check if acceptable w.r.t. current step
            S = frozenset(step)
            S_with_a = frozenset(step | {a})
            if AF.is_conflict_free(S_with_a) and AF.is_acceptable(S, a):
                color = '#F39C12'  # Acceptable (could be added)
                ec = '#E67E22'
            else:
                color = '#ECF0F1'  # Not yet acceptable
                ec = '#BDC3C7'

        circle = plt.Circle((x, y), 0.18, color=color, ec=ec, lw=2, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y, a[:4], ha='center', va='center', fontsize=7,
                fontweight='bold', zorder=6)

    # Add reason text
    ax.text(0, -1.6, reason, ha='center', va='top', fontsize=7,
            style='italic', wrap=True,
            bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow',
                      edgecolor='gray', alpha=0.8))

# Legend
legend_elements = [
    mpatches.Patch(facecolor='#2ECC71', edgecolor='#27AE60', label='In admissible set'),
    mpatches.Patch(facecolor='#F39C12', edgecolor='#E67E22', label='Acceptable (can add)'),
    mpatches.Patch(facecolor='#ECF0F1', edgecolor='#BDC3C7', label='Not yet acceptable'),
]
fig.legend(handles=legend_elements, loc='lower center', ncol=3, fontsize=9,
           bbox_to_anchor=(0.5, -0.02))

plt.tight_layout(rect=[0, 0.05, 1, 0.95])
plt.savefig('fundamental_lemma.png', dpi=150, bbox_inches='tight')
print("Saved: fundamental_lemma.png")
