#!/usr/bin/env python3
"""
Applications of Closure–Entropic Gravity Duality

Demonstrates real-world applications:
1. Database functional dependency analysis
2. Knowledge graph entropy profiling
3. Feature selection via closure entropy
"""

from __future__ import annotations
from itertools import combinations
from typing import Dict, List, Tuple, Set, FrozenSet

Subset = frozenset


def powerset(s: set) -> list:
    s = list(s)
    return [frozenset(c) for r in range(len(s) + 1) for c in combinations(s, r)]


# ============================================================
# Application 1: Database Functional Dependencies
# ============================================================

class FunctionalDependencyClosure:
    """
    In relational database theory, functional dependencies define a closure
    operator on attribute sets. The closure of a set of attributes is the
    set of all attributes functionally determined by them.

    This application shows how curvature profiles detect information
    bottlenecks in database schemas.
    """

    def __init__(self, attributes: set, fds: List[Tuple[set, set]]):
        """
        Args:
            attributes: Set of attribute names.
            fds: List of (lhs, rhs) functional dependencies.
        """
        self.attributes = frozenset(attributes)
        self.fds = [(frozenset(l), frozenset(r)) for l, r in fds]

    def closure(self, s: Subset) -> Subset:
        """Compute the closure of attribute set s under functional dependencies."""
        result = set(s)
        changed = True
        while changed:
            changed = False
            for lhs, rhs in self.fds:
                if lhs <= result and not rhs <= result:
                    result |= rhs
                    changed = True
        return frozenset(result)

    def entropy(self, s: Subset) -> int:
        """Entropy = cardinality of the closure (information content)."""
        return len(self.closure(s))

    def curvature_profile(self, s: Subset, cuts: Dict[str, Subset]) -> Dict[str, int]:
        """Compute curvature profile: marginal information gain per cut."""
        base = self.entropy(s)
        return {c: self.entropy(s | side) - base for c, side in cuts.items()}

    def analyze(self):
        """Run full analysis of the database schema."""
        print("DATABASE FUNCTIONAL DEPENDENCY ANALYSIS")
        print("=" * 60)
        print(f"Attributes: {set(self.attributes)}")
        print(f"Dependencies:")
        for lhs, rhs in self.fds:
            print(f"  {set(lhs)} → {set(rhs)}")

        # Find closed sets
        closed = [s for s in powerset(set(self.attributes)) if self.closure(s) == s]
        print(f"\nClosed attribute sets ({len(closed)}):")
        for s in sorted(closed, key=lambda x: (len(x), sorted(x))):
            name = set(s) if s else '∅'
            print(f"  {str(name):>30}  (entropy = {self.entropy(s)})")

        # Define cuts as individual attributes
        cuts = {a: frozenset({a}) for a in self.attributes}

        print(f"\nCurvature profiles (marginal information per attribute):")
        header = "  " + f"{'Closed set':>30} | " + " | ".join(f"{a:>4}" for a in sorted(self.attributes))
        print(header)
        print("  " + "-" * len(header))
        for s in sorted(closed, key=lambda x: (len(x), sorted(x))):
            prof = self.curvature_profile(s, cuts)
            name = set(s) if s else '∅'
            vals = " | ".join(f"{prof[a]:>4}" for a in sorted(self.attributes))
            print(f"  {str(name):>30} | {vals}")

        # Check separation
        profiles = {}
        separated = True
        for s in closed:
            key = tuple(self.curvature_profile(s, cuts)[a] for a in sorted(self.attributes))
            if key in profiles:
                separated = False
            profiles[key] = s

        print(f"\nSeparation: {'✓ Holds' if separated else '✗ Fails — need more cuts'}")
        if separated:
            print("→ Schema geometry is fully reconstructible from entropy profiles")


# ============================================================
# Application 2: Knowledge Graph Analysis
# ============================================================

class KnowledgeGraphClosure:
    """
    In a knowledge graph, the closure of a set of concepts is the set of
    all concepts reachable by inference rules. Curvature profiles detect
    which inference pathways contribute the most new information.
    """

    def __init__(self, concepts: set, rules: List[Tuple[set, str]]):
        """
        Args:
            concepts: Set of concept names.
            rules: List of (premises, conclusion) inference rules.
        """
        self.concepts = frozenset(concepts)
        self.rules = [(frozenset(p), c) for p, c in rules]

    def closure(self, s: Subset) -> Subset:
        result = set(s)
        changed = True
        while changed:
            changed = False
            for premises, conclusion in self.rules:
                if premises <= result and conclusion not in result:
                    result.add(conclusion)
                    changed = True
        return frozenset(result)

    def entropy(self, s: Subset) -> int:
        return len(s)

    def analyze(self):
        print("\nKNOWLEDGE GRAPH CLOSURE ANALYSIS")
        print("=" * 60)
        print(f"Concepts: {set(self.concepts)}")
        print("Rules:")
        for premises, conclusion in self.rules:
            print(f"  {set(premises)} ⊢ {conclusion}")

        closed = [s for s in powerset(set(self.concepts)) if self.closure(s) == s]
        print(f"\nClosed concept sets ({len(closed)}):")
        for s in sorted(closed, key=lambda x: (len(x), sorted(x))):
            name = set(s) if s else '∅'
            print(f"  {str(name):>40}  (entropy = {self.entropy(s)})")

        # Use individual concepts as cuts
        cuts = {c: frozenset({c}) for c in self.concepts}
        base_S = {s: self.entropy(s) for s in closed}

        print(f"\nHorizon ranks (number of informative concept-cuts):")
        for s in sorted(closed, key=lambda x: (len(x), sorted(x))):
            active = [c for c in sorted(self.concepts)
                      if self.entropy(self.closure(s | frozenset({c}))) - self.entropy(s) > 0]
            name = set(s) if s else '∅'
            rank = len(active)
            print(f"  {str(name):>40}: rank={rank}, active={active}")


# ============================================================
# Application 3: Feature Selection
# ============================================================

def feature_selection_demo():
    """
    Demonstrate how closure-entropy profiles can guide feature selection
    in a simple classification setting.

    The idea: features that create large curvature profiles relative to
    the current feature set are the most informative additions.
    """
    print("\nFEATURE SELECTION VIA CLOSURE ENTROPY")
    print("=" * 60)

    # Simulate: 5 features where {f1,f2} → f3 and {f3,f4} → f5
    features = {'f1', 'f2', 'f3', 'f4', 'f5'}
    deps = [
        ({'f1', 'f2'}, {'f3'}),
        ({'f3', 'f4'}, {'f5'}),
    ]

    def closure(s):
        result = set(s)
        changed = True
        while changed:
            changed = False
            for lhs, rhs in deps:
                if frozenset(lhs) <= frozenset(result) and not frozenset(rhs) <= frozenset(result):
                    result |= rhs
                    changed = True
        return frozenset(result)

    print(f"Features: {features}")
    print(f"Dependencies: f1,f2 → f3;  f3,f4 → f5")

    # Greedy feature selection by maximum curvature
    selected = frozenset()
    remaining = set(features)

    print(f"\nGreedy selection by maximum marginal entropy:")
    for step in range(len(features)):
        if not remaining:
            break

        best_feat = None
        best_gain = -1

        for f in remaining:
            extended = closure(selected | frozenset({f}))
            gain = len(extended) - len(closure(selected))
            if gain > best_gain:
                best_gain = gain
                best_feat = f

        selected = closure(selected | frozenset({best_feat}))
        remaining.discard(best_feat)
        # Also remove any features now in the closure
        remaining -= set(selected)

        print(f"  Step {step+1}: Add {best_feat} → closure = {set(selected)}, "
              f"gain = {best_gain}, horizon_rank = {len(remaining)}")

        if selected == frozenset(features):
            print(f"\n  ✓ Full coverage achieved in {step+1} steps!")
            break


# ============================================================
# Main
# ============================================================

def main():
    # Application 1: Database schema
    db = FunctionalDependencyClosure(
        attributes={'A', 'B', 'C', 'D'},
        fds=[
            ({'A'}, {'B'}),
            ({'B', 'C'}, {'D'}),
        ]
    )
    db.analyze()

    # Application 2: Knowledge graph
    kg = KnowledgeGraphClosure(
        concepts={'rain', 'clouds', 'wet', 'umbrella', 'dry'},
        rules=[
            ({'clouds'}, 'rain'),
            ({'rain'}, 'wet'),
            ({'umbrella', 'rain'}, 'dry'),
        ]
    )
    kg.analyze()

    # Application 3: Feature selection
    feature_selection_demo()


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Closure–Entropic Gravity Duality: Demonstration

This script demonstrates the core mathematical constructions:
1. Finite closure spaces with entropy
2. Curvature profile computation
3. Separation verification
4. Horizon reconstruction
5. Profile antitonicity

Uses a concrete example on {0, 1, 2} with closure cl(s) = s ∪ {0} for s ≠ ∅.
"""

from __future__ import annotations
from itertools import chain, combinations
from typing import Callable, FrozenSet, Dict, List, Tuple, Set


# Type aliases
Element = int
Subset = frozenset


def powerset(s: set) -> list:
    """Generate all subsets of a set."""
    s = list(s)
    return [frozenset(c) for r in range(len(s) + 1) for c in combinations(s, r)]


class FiniteClosureSpace:
    """A finite closure space on a set of elements."""

    def __init__(self, elements: set, cl: Callable[[Subset], Subset]):
        self.elements = frozenset(elements)
        self._cl = cl
        self._verify_axioms()

    def cl(self, s: Subset) -> Subset:
        """Apply the closure operator."""
        return self._cl(s)

    def is_closed(self, s: Subset) -> bool:
        """Check if a set is closed."""
        return self.cl(s) == s

    def closed_sets(self) -> list:
        """Enumerate all closed sets."""
        return [s for s in powerset(self.elements) if self.is_closed(s)]

    def _verify_axioms(self):
        """Verify extensivity, monotonicity, idempotence."""
        all_subsets = powerset(self.elements)

        # Extensivity
        for s in all_subsets:
            assert s <= self.cl(s), f"Extensivity fails: {set(s)} ⊄ cl({set(s)}) = {set(self.cl(s))}"

        # Idempotence
        for s in all_subsets:
            assert self.cl(self.cl(s)) == self.cl(s), \
                f"Idempotence fails: cl(cl({set(s)})) ≠ cl({set(s)})"

        # Monotonicity
        for s in all_subsets:
            for t in all_subsets:
                if s <= t:
                    assert self.cl(s) <= self.cl(t), \
                        f"Monotonicity fails: {set(s)} ⊆ {set(t)} but cl({set(s)}) ⊄ cl({set(t)})"


class EntropicClosureSpace(FiniteClosureSpace):
    """A finite closure space with a submodular entropy functional."""

    def __init__(self, elements: set, cl: Callable, S: Callable[[Subset], int]):
        super().__init__(elements, cl)
        self.S = S
        self._verify_entropy_axioms()

    def _verify_entropy_axioms(self):
        """Verify monotonicity and submodularity on closed sets."""
        closed = self.closed_sets()

        # Monotonicity on closed sets
        for s in closed:
            for t in closed:
                if s <= t:
                    assert self.S(s) <= self.S(t), \
                        f"Entropy monotonicity fails: S({set(s)})={self.S(s)} > S({set(t)})={self.S(t)}"

        # Submodularity on closed sets
        for s in closed:
            for t in closed:
                inter = s & t
                union_cl = self.cl(s | t)
                lhs = self.S(inter) + self.S(union_cl)
                rhs = self.S(s) + self.S(t)
                assert lhs <= rhs, \
                    f"Submodularity fails: S({set(inter)})+S({set(union_cl)})={lhs} > S({set(s)})+S({set(t)})={rhs}"


class CutGeometry:
    """A family of cuts with designated sides."""

    def __init__(self, cuts: dict):
        """cuts: dict mapping cut name -> frozenset (the 'side' of the cut)"""
        self.cuts = cuts

    def cut_names(self) -> list:
        return list(self.cuts.keys())

    def cut_side(self, c) -> Subset:
        return self.cuts[c]


def curvature_profile(E: EntropicClosureSpace, G: CutGeometry, s: Subset) -> dict:
    """Compute the curvature profile K(s)(c) = S(cl(s ∪ side_c)) - S(s)."""
    profile = {}
    for c in G.cut_names():
        extended = E.cl(s | G.cut_side(c))
        profile[c] = E.S(extended) - E.S(s)
    return profile


def active_cuts(E: EntropicClosureSpace, G: CutGeometry, s: Subset) -> list:
    """Return the cuts where the curvature profile is nonzero."""
    prof = curvature_profile(E, G, s)
    return [c for c in G.cut_names() if prof[c] != 0]


def horizon_rank(E: EntropicClosureSpace, G: CutGeometry, s: Subset) -> int:
    """The discrete horizon rank: number of active cuts."""
    return len(active_cuts(E, G, s))


def verify_separation(E: EntropicClosureSpace, G: CutGeometry) -> bool:
    """Check if the cut geometry separates all distinct closed sets."""
    closed = E.closed_sets()
    profiles = {}
    for s in closed:
        prof = tuple(sorted(curvature_profile(E, G, s).items()))
        if prof in profiles:
            return False
        profiles[prof] = s
    return True


def reconstruct_from_profile(E: EntropicClosureSpace, G: CutGeometry,
                             target_profile: dict) -> Subset | None:
    """Reconstruct the closed set from a profile (if realizable)."""
    for s in E.closed_sets():
        if curvature_profile(E, G, s) == target_profile:
            return s
    return None


# ============================================================
# DEMONSTRATION
# ============================================================

def main():
    print("=" * 70)
    print("CLOSURE–ENTROPIC GRAVITY DUALITY: DEMONSTRATION")
    print("=" * 70)

    # Define the toy closure space on {0, 1, 2}
    elements = {0, 1, 2}

    def toy_cl(s: Subset) -> Subset:
        if len(s) == 0:
            return frozenset()
        return s | frozenset({0})

    def toy_S(s: Subset) -> int:
        return len(s)

    print("\n1. CONSTRUCTING THE ENTROPIC CLOSURE SPACE")
    print("-" * 50)
    print(f"   Elements: {elements}")
    print(f"   Closure:  cl(s) = s ∪ {{0}} for s ≠ ∅, cl(∅) = ∅")
    print(f"   Entropy:  S(s) = |s| (cardinality)")

    E = EntropicClosureSpace(elements, toy_cl, toy_S)
    print("   ✓ All axioms verified (extensivity, monotonicity, idempotence)")
    print("   ✓ Entropy monotonicity and submodularity verified")

    closed = E.closed_sets()
    print(f"\n   Closed sets ({len(closed)}):")
    for s in sorted(closed, key=len):
        print(f"     {str(set(s)) if s else '∅':>12}  (S = {E.S(s)})")

    # Define cut geometry
    print("\n2. CUT GEOMETRY")
    print("-" * 50)
    cuts = {
        'c₁': frozenset({1}),
        'c₂': frozenset({2}),
    }
    G = CutGeometry(cuts)
    print(f"   Cut c₁: side = {{1}}")
    print(f"   Cut c₂: side = {{2}}")

    # Compute curvature profiles
    print("\n3. CURVATURE PROFILES")
    print("-" * 50)
    print(f"   {'Closed set':>15} | {'K(c₁)':>6} | {'K(c₂)':>6} | {'Active cuts':>15} | {'Rank':>4}")
    print(f"   {'-'*15}-+-{'-'*6}-+-{'-'*6}-+-{'-'*15}-+-{'-'*4}")

    for s in sorted(closed, key=len):
        prof = curvature_profile(E, G, s)
        ac = active_cuts(E, G, s)
        hr = horizon_rank(E, G, s)
        name = set(s) if s else '∅'
        ac_str = '{' + ', '.join(ac) + '}' if ac else '∅'
        print(f"   {str(name):>15} | {prof['c₁']:>6} | {prof['c₂']:>6} | {ac_str:>15} | {hr:>4}")

    # Verify separation
    print("\n4. SEPARATION AXIOM")
    print("-" * 50)
    sep = verify_separation(E, G)
    print(f"   Separation holds: {sep}")
    if sep:
        print("   ✓ All distinct closed sets have distinct curvature profiles")
        print("   ✓ The curvature profile map is injective on closed sets")

    # Demonstrate reconstruction
    print("\n5. HORIZON RECONSTRUCTION")
    print("-" * 50)
    test_profile = {'c₁': 1, 'c₂': 0}
    reconstructed = reconstruct_from_profile(E, G, test_profile)
    print(f"   Target profile:    K(c₁)=1, K(c₂)=0")
    print(f"   Reconstructed set: {set(reconstructed) if reconstructed else 'None'}")
    print(f"   Active cuts:       {active_cuts(E, G, reconstructed)}")
    print(f"   Horizon rank:      {horizon_rank(E, G, reconstructed)}")

    # Demonstrate antitonicity
    print("\n6. PROFILE ANTITONICITY")
    print("-" * 50)
    print("   For s ⊆ t (both closed), K(t)(c) ≤ K(s)(c) for all c:")
    for s in sorted(closed, key=len):
        for t in sorted(closed, key=len):
            if s < t:  # proper subset
                ps = curvature_profile(E, G, s)
                pt = curvature_profile(E, G, t)
                ok = all(pt[c] <= ps[c] for c in G.cut_names())
                s_name = set(s) if s else '∅'
                t_name = set(t) if t else '∅'
                print(f"   {str(s_name):>12} ⊂ {str(t_name):<12}: "
                      f"K_t=({pt['c₁']},{pt['c₂']}) ≤ K_s=({ps['c₁']},{ps['c₂']})  {'✓' if ok else '✗'}")

    # Demonstrate the full duality
    print("\n7. FULL DUALITY VERIFICATION")
    print("-" * 50)
    print("   For each closed set, reconstruct from its profile:")
    all_ok = True
    for s in sorted(closed, key=len):
        prof = curvature_profile(E, G, s)
        recon = reconstruct_from_profile(E, G, prof)
        ok = (recon == s)
        all_ok = all_ok and ok
        s_name = set(s) if s else '∅'
        r_name = set(recon) if recon else '∅'
        print(f"   {str(s_name):>12} → profile → {str(r_name):<12}  {'✓' if ok else '✗'}")
    print(f"\n   Full round-trip reconstruction: {'✓ VERIFIED' if all_ok else '✗ FAILED'}")

    print("\n" + "=" * 70)
    print("DEMONSTRATION COMPLETE")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""Generate PACKAGE.json with all artifacts."""

import json
import base64
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

def read_image_as_base64(path):
    with open(path, 'rb') as f:
        data = base64.b64encode(f.read()).decode('utf-8')
    return f"data:image/png;base64,{data}"

# Read all content
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
lean_proofs = read_file('Bridges/AlgebraEMLPhysics/ClosureEntropicGravityDuality.lean')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')
viz_code = read_file('visualizations.py')

# Read visualizations as base64
viz_files = [
    ('Curvature Profile Heatmap', 'viz_profile_heatmap.png'),
    ('Discrete Horizon Rank', 'viz_horizon_rank.png'),
    ('Closure Lattice with Profiles', 'viz_closure_lattice.png'),
    ('Profile Antitonicity', 'viz_antitonicity.png'),
]

visualizations = []
for name, path in viz_files:
    if os.path.exists(path):
        visualizations.append({
            'name': name,
            'data': read_image_as_base64(path)
        })

package = {
    'title': 'Closure–Entropic Gravity Duality via Idempotent Curvature Semimodules and Certified Horizon Reconstruction',
    'domain': 'Bridges (Algebra–EML–Physics)',
    'article': article,
    'research_paper': research_paper,
    'future_directions': future_directions,
    'demos': [
        {
            'name': 'Closure–Entropic Gravity Duality Demo',
            'code': demo_code
        },
        {
            'name': 'Applications: Database, Knowledge Graph, Feature Selection',
            'code': applications_code
        }
    ],
    'algorithms': [
        {
            'name': 'Curvature Profile Computation',
            'pseudocode': '''function ComputeProfile(cl, S, cutSide, s):
    for each cut c:
        extended ← cl(s ∪ cutSide(c))
        K[c] ← S(extended) - S(s)
    return K

Complexity: O(|Cut| × T_cl)''',
            'code': algorithms_code
        },
        {
            'name': 'Horizon Reconstruction',
            'pseudocode': '''function ReconstructHorizon(closedSets, cl, S, cutSide, p):
    for each closed set s in closedSets:
        if ComputeProfile(cl, S, cutSide, s) == p:
            activeCuts ← {c : K(s)(c) ≠ 0}
            return HorizonGraph(carrier=s, horizonCuts=activeCuts)
    return NOT_REALIZABLE

Complexity: O(|closedSets| × |Cut| × T_cl)''',
            'code': algorithms_code
        },
        {
            'name': 'Separation Verification',
            'pseudocode': '''function VerifySeparation(closedSets, cl, S, cutSide):
    profiles ← {}
    for each closed set s:
        p ← ComputeProfile(cl, S, cutSide, s)
        if p in profiles:
            return False
        profiles[p] ← s
    return True

Complexity: O(|closedSets| × |Cut| × T_cl) with hashing''',
            'code': algorithms_code
        }
    ],
    'visualizations': visualizations,
    'lean_proofs': lean_proofs
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"Generated PACKAGE.json ({os.path.getsize('PACKAGE.json')} bytes)")


#!/usr/bin/env python3
"""
Visualizations for Closure–Entropic Gravity Duality

Generates:
1. Closure lattice with curvature profiles
2. Profile heatmap
3. Horizon rank diagram
4. Antitonicity demonstration
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import combinations


def powerset(s):
    s = list(s)
    return [frozenset(c) for r in range(len(s) + 1) for c in combinations(s, r)]


def setup_example():
    """Set up the toy example on {0, 1, 2}."""
    elements = {0, 1, 2}

    def cl(s):
        if len(s) == 0:
            return frozenset()
        return s | frozenset({0})

    def S(s):
        return len(s)

    cuts = {'c₁': frozenset({1}), 'c₂': frozenset({2})}

    closed = [s for s in powerset(elements) if cl(s) == s]

    profiles = {}
    for s in closed:
        prof = {}
        for c, side in cuts.items():
            extended = cl(s | side)
            prof[c] = S(extended) - S(s)
        profiles[frozenset(s)] = prof

    return elements, cl, S, cuts, closed, profiles


def set_name(s):
    if len(s) == 0:
        return '∅'
    return '{' + ','.join(str(x) for x in sorted(s)) + '}'


def fig1_profile_heatmap():
    """Generate a heatmap of curvature profiles."""
    elements, cl, S, cuts, closed, profiles = setup_example()

    closed_sorted = sorted(closed, key=lambda x: (len(x), sorted(x)))
    cut_names = sorted(cuts.keys())

    data = []
    labels = []
    for s in closed_sorted:
        row = [profiles[s][c] for c in cut_names]
        data.append(row)
        labels.append(set_name(s))

    data = np.array(data)

    fig, ax = plt.subplots(figsize=(8, 6))
    im = ax.imshow(data, cmap='YlOrRd', aspect='auto', vmin=0)

    ax.set_xticks(range(len(cut_names)))
    ax.set_xticklabels(cut_names, fontsize=14)
    ax.set_yticks(range(len(labels)))
    ax.set_yticklabels(labels, fontsize=13)

    ax.set_xlabel('Cuts', fontsize=14)
    ax.set_ylabel('Closed Sets', fontsize=14)
    ax.set_title('Curvature Profile Heatmap\nK(s)(c) = S(cl(s ∪ side_c)) − S(s)', fontsize=15)

    # Add text annotations
    for i in range(len(labels)):
        for j in range(len(cut_names)):
            ax.text(j, i, str(data[i, j]), ha='center', va='center',
                    fontsize=16, fontweight='bold',
                    color='white' if data[i, j] > 1 else 'black')

    plt.colorbar(im, ax=ax, label='Marginal Entropy Increment')
    plt.tight_layout()
    plt.savefig('viz_profile_heatmap.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Generated: viz_profile_heatmap.png")


def fig2_horizon_rank():
    """Generate a bar chart of horizon ranks."""
    elements, cl, S, cuts, closed, profiles = setup_example()

    closed_sorted = sorted(closed, key=lambda x: (len(x), sorted(x)))
    ranks = []
    labels = []
    for s in closed_sorted:
        rank = sum(1 for c in cuts if profiles[s][c] != 0)
        ranks.append(rank)
        labels.append(set_name(s))

    fig, ax = plt.subplots(figsize=(8, 5))
    colors = ['#2ecc71' if r == 0 else '#e74c3c' if r == max(ranks) else '#3498db'
              for r in ranks]
    bars = ax.bar(labels, ranks, color=colors, edgecolor='black', linewidth=1.2)

    ax.set_ylabel('Horizon Rank', fontsize=14)
    ax.set_xlabel('Closed Set', fontsize=14)
    ax.set_title('Discrete Horizon Rank\n(Number of Active Cuts)', fontsize=15)
    ax.set_ylim(0, max(ranks) + 0.5)

    for bar, rank in zip(bars, ranks):
        ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.05,
                str(rank), ha='center', va='bottom', fontsize=14, fontweight='bold')

    # Legend
    legend_elements = [
        mpatches.Patch(facecolor='#e74c3c', edgecolor='black', label='Maximum curvature'),
        mpatches.Patch(facecolor='#3498db', edgecolor='black', label='Intermediate'),
        mpatches.Patch(facecolor='#2ecc71', edgecolor='black', label='Flat (zero curvature)'),
    ]
    ax.legend(handles=legend_elements, loc='upper right', fontsize=11)

    plt.tight_layout()
    plt.savefig('viz_horizon_rank.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Generated: viz_horizon_rank.png")


def fig3_closure_lattice():
    """Generate a diagram of the closure lattice with profile annotations."""
    elements, cl, S, cuts, closed, profiles = setup_example()

    fig, ax = plt.subplots(figsize=(10, 8))

    # Position closed sets by cardinality
    levels = {}
    for s in closed:
        k = len(s)
        if k not in levels:
            levels[k] = []
        levels[k].append(s)

    positions = {}
    for k, sets in levels.items():
        n = len(sets)
        for i, s in enumerate(sorted(sets, key=sorted)):
            x = (i - (n-1)/2) * 2.5
            y = k * 2.5
            positions[s] = (x, y)

    # Draw edges (inclusion relations)
    for s in closed:
        for t in closed:
            if s < t and len(t) - len(s) == 1:
                xs, ys = positions[s]
                xt, yt = positions[t]
                ax.plot([xs, xt], [ys, yt], 'k-', linewidth=1.5, alpha=0.4, zorder=1)

    # Draw nodes
    for s in closed:
        x, y = positions[s]
        rank = sum(1 for c in cuts if profiles[s][c] != 0)
        color = '#2ecc71' if rank == 0 else '#e74c3c' if rank == 2 else '#3498db'

        circle = plt.Circle((x, y), 0.6, facecolor=color, edgecolor='black',
                           linewidth=2, zorder=2, alpha=0.9)
        ax.add_patch(circle)

        # Set name
        ax.text(x, y + 0.15, set_name(s), ha='center', va='center',
                fontsize=11, fontweight='bold', zorder=3)

        # Profile annotation
        prof_str = f"({profiles[s]['c₁']},{profiles[s]['c₂']})"
        ax.text(x, y - 0.25, prof_str, ha='center', va='center',
                fontsize=9, color='white', zorder=3)

        # Entropy
        ax.text(x + 0.8, y + 0.4, f"S={S(s)}", ha='left', va='center',
                fontsize=9, color='gray', style='italic', zorder=3)

    ax.set_xlim(-4, 4)
    ax.set_ylim(-1, 9)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Closure Lattice with Curvature Profiles\nNode color = horizon rank, (K₁,K₂) = curvature profile',
                 fontsize=14, pad=20)

    legend_elements = [
        mpatches.Patch(facecolor='#e74c3c', edgecolor='black', label='Rank 2 (max curvature)'),
        mpatches.Patch(facecolor='#3498db', edgecolor='black', label='Rank 1'),
        mpatches.Patch(facecolor='#2ecc71', edgecolor='black', label='Rank 0 (flat)'),
    ]
    ax.legend(handles=legend_elements, loc='upper left', fontsize=11)

    plt.tight_layout()
    plt.savefig('viz_closure_lattice.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Generated: viz_closure_lattice.png")


def fig4_antitonicity():
    """Demonstrate profile antitonicity: larger sets have smaller profiles."""
    elements, cl, S, cuts, closed, profiles = setup_example()

    # Find inclusion chains
    chains = []
    for s in closed:
        for t in closed:
            if s < t:
                chains.append((s, t))

    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    cut_list = sorted(cuts.keys())

    for idx, c in enumerate(cut_list):
        ax = axes[idx]

        for s in sorted(closed, key=len):
            val = profiles[s][c]
            ax.bar(set_name(s), val, color='#3498db', edgecolor='black', linewidth=1.2)

        ax.set_ylabel(f'K({c})', fontsize=13)
        ax.set_xlabel('Closed Set (ordered by ⊆)', fontsize=12)
        ax.set_title(f'Profile component {c}\n(decreasing along ⊆-chains)', fontsize=13)

        # Draw arrows showing antitonicity
        closed_sorted = sorted(closed, key=lambda x: (len(x), sorted(x)))
        for i, s in enumerate(closed_sorted):
            for j, t in enumerate(closed_sorted):
                if s < t and len(t) - len(s) == 1:
                    val_s = profiles[s][c]
                    val_t = profiles[t][c]
                    if val_s > val_t:
                        ax.annotate('', xy=(j, val_t + 0.05),
                                   xytext=(i, val_s - 0.05),
                                   arrowprops=dict(arrowstyle='->', color='red',
                                                 lw=1.5, alpha=0.5))

    plt.suptitle('Profile Antitonicity: K(t) ≤ K(s) when s ⊆ t', fontsize=15, y=1.02)
    plt.tight_layout()
    plt.savefig('viz_antitonicity.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Generated: viz_antitonicity.png")


def main():
    fig1_profile_heatmap()
    fig2_horizon_rank()
    fig3_closure_lattice()
    fig4_antitonicity()
    print("\nAll visualizations generated successfully!")


if __name__ == "__main__":
    main()
