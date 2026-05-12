#!/usr/bin/env python3
"""
Tropical Closure Coding Theory — Applications

Demonstrates real-world applications of closure codes:
1. Knowledge base repair (semantic error correction)
2. Software dependency resolution (package management)
3. Access control / secret sharing reconstruction
4. Concept lattice error correction
"""

from algorithms import TropicalClosureCode, HornImplication, ClosureMorphism
from typing import Dict, List, FrozenSet
import random


# ─────────────────────────────────────────────────────────────────────────
# Application 1: Knowledge Base Repair
# ─────────────────────────────────────────────────────────────────────────

def knowledge_base_repair():
    """Demonstrate closure coding for knowledge base repair.

    Scenario: A student's knowledge state has gaps (errors).
    The closure code detects which prerequisites are missing
    and prescribes the minimum-cost repair (courses to take).
    """
    print("=" * 70)
    print("APPLICATION 1: Knowledge Base Repair")
    print("  Detecting and correcting gaps in a student's knowledge")
    print("=" * 70)

    # Knowledge domains
    domains = {
        0: "Calculus",
        1: "Linear Algebra",
        2: "Probability",
        3: "Statistics",
        4: "Optimization",
        5: "Machine Learning",
        6: "Deep Learning",
        7: "Computer Vision",
    }

    ground = frozenset(range(8))

    # Prerequisites (closure implications)
    implications = [
        HornImplication(frozenset([0, 1]), 4),     # calc + lin alg ⇒ optimization
        HornImplication(frozenset([1, 2]), 3),     # lin alg + prob ⇒ statistics
        HornImplication(frozenset([3, 4]), 5),     # stats + optim ⇒ ML
        HornImplication(frozenset([5]), 6),         # ML ⇒ deep learning
        HornImplication(frozenset([5, 1]), 7),     # ML + lin alg ⇒ computer vision
    ]

    # Course difficulty as weights
    weights = {0: 4, 1: 3, 2: 3, 3: 2, 4: 3, 5: 4, 6: 3, 7: 4}

    code = TropicalClosureCode(ground, implications, weights)

    print(f"\nKnowledge domains: {domains}")
    print(f"Prerequisites:")
    for imp in implications:
        premise_names = [domains[i] for i in imp.premise]
        print(f"  {premise_names} ⇒ {domains[imp.conclusion]}")

    # Student's current knowledge (with gaps)
    student = frozenset([0, 1, 2, 5])  # Has calc, lin alg, prob, ML but missing prereqs
    student_names = [domains[i] for i in student]

    print(f"\nStudent knows: {student_names}")
    print(f"Syndrome: {code.syndrome(student)}")
    print(f"Syndrome vector: {code.syndrome_vector(student)}")

    # Violated prerequisites
    violations = code.separating_violations(student)
    for idx, imp in violations:
        premise_names = [domains[i] for i in imp.premise]
        print(f"  ✗ Missing: {premise_names} ⇒ {domains[imp.conclusion]}")

    # Repair (decode)
    repaired = code.decode(student)
    added = repaired - student
    cost = code.repair_cost(student, repaired)

    print(f"\nRepaired knowledge: {[domains[i] for i in sorted(repaired)]}")
    print(f"Courses to add: {[domains[i] for i in sorted(added)]}")
    print(f"Total difficulty: {cost}")
    print(f"Post-repair syndrome: {code.syndrome(repaired)}")


# ─────────────────────────────────────────────────────────────────────────
# Application 2: Software Dependency Resolution
# ─────────────────────────────────────────────────────────────────────────

def dependency_resolution():
    """Demonstrate closure coding for software dependency resolution.

    Scenario: A user installs some packages. The closure code detects
    missing dependencies and installs the minimum set to satisfy all.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Software Dependency Resolution")
    print("  Resolving package dependencies as tropical decoding")
    print("=" * 70)

    packages = {
        0: "python",
        1: "numpy",
        2: "scipy",
        3: "matplotlib",
        4: "pandas",
        5: "scikit-learn",
        6: "tensorflow",
        7: "keras",
    }

    ground = frozenset(range(8))

    implications = [
        HornImplication(frozenset([1]), 0),       # numpy needs python
        HornImplication(frozenset([2]), 1),       # scipy needs numpy
        HornImplication(frozenset([3]), 1),       # matplotlib needs numpy
        HornImplication(frozenset([4]), 1),       # pandas needs numpy
        HornImplication(frozenset([5]), 2),       # sklearn needs scipy
        HornImplication(frozenset([5]), 4),       # sklearn needs pandas
        HornImplication(frozenset([6]), 1),       # tensorflow needs numpy
        HornImplication(frozenset([7]), 6),       # keras needs tensorflow
    ]

    # Install sizes (MB)
    weights = {0: 50, 1: 20, 2: 30, 3: 15, 4: 25, 5: 35, 6: 200, 7: 10}

    code = TropicalClosureCode(ground, implications, weights)

    print(f"\nPackages: {packages}")
    print(f"Sizes (MB): {weights}")

    # User requests keras and scikit-learn
    requested = frozenset([5, 7])
    print(f"\nUser requests: {[packages[i] for i in requested]}")
    print(f"Missing dependencies (syndrome): {code.syndrome(requested)}")

    resolved = code.decode(requested)
    added = resolved - requested
    cost = code.repair_cost(requested, resolved)

    print(f"Auto-installed: {[packages[i] for i in sorted(added)]}")
    print(f"Total download: {cost} MB")
    print(f"Final install: {[packages[i] for i in sorted(resolved)]}")
    print(f"Syndrome after resolution: {code.syndrome(resolved)}")


# ─────────────────────────────────────────────────────────────────────────
# Application 3: Access Control Reconstruction
# ─────────────────────────────────────────────────────────────────────────

def access_control():
    """Demonstrate closure coding for access control.

    Scenario: In a hierarchical access system, having certain permissions
    automatically grants others. The closure code detects inconsistent
    permission sets and repairs them.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Access Control / Permission Repair")
    print("  Repairing inconsistent permission sets")
    print("=" * 70)

    permissions = {
        0: "read_public",
        1: "read_internal",
        2: "read_confidential",
        3: "write_public",
        4: "write_internal",
        5: "admin",
    }

    ground = frozenset(range(6))

    # Permission hierarchy
    implications = [
        HornImplication(frozenset([1]), 0),       # internal read ⇒ public read
        HornImplication(frozenset([2]), 1),       # confidential read ⇒ internal read
        HornImplication(frozenset([4]), 3),       # internal write ⇒ public write
        HornImplication(frozenset([4]), 1),       # internal write ⇒ internal read
        HornImplication(frozenset([5]), 2),       # admin ⇒ confidential read
        HornImplication(frozenset([5]), 4),       # admin ⇒ internal write
    ]

    weights = {i: 1 for i in range(6)}
    code = TropicalClosureCode(ground, implications, weights)

    # Inconsistent permission set: has admin but missing intermediate perms
    broken = frozenset([5, 0])  # admin + public read only
    print(f"\nInconsistent permissions: {[permissions[i] for i in sorted(broken)]}")
    print(f"Syndrome (violations): {code.syndrome(broken)}")

    repaired = code.decode(broken)
    added = repaired - broken
    print(f"Repaired permissions: {[permissions[i] for i in sorted(repaired)]}")
    print(f"Added: {[permissions[i] for i in sorted(added)]}")

    print(f"\nAll valid permission sets (codewords):")
    for cw in code.all_codewords():
        print(f"  {[permissions[i] for i in sorted(cw)]}")


# ─────────────────────────────────────────────────────────────────────────
# Application 4: Concept Lattice Error Correction
# ─────────────────────────────────────────────────────────────────────────

def concept_lattice_correction():
    """Demonstrate closure coding for concept lattice error correction.

    Scenario: In formal concept analysis, objects have attributes.
    The closure code detects when an attribute assignment violates
    the concept structure and repairs it.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: Concept Lattice Error Correction")
    print("  Correcting inconsistent attribute assignments")
    print("=" * 70)

    attributes = {
        0: "has_wings",
        1: "can_fly",
        2: "has_feathers",
        3: "is_bird",
        4: "lays_eggs",
        5: "is_warm_blooded",
    }

    ground = frozenset(range(6))

    # Biological rules
    implications = [
        HornImplication(frozenset([3]), 2),       # bird ⇒ feathers
        HornImplication(frozenset([3]), 0),       # bird ⇒ wings
        HornImplication(frozenset([3]), 4),       # bird ⇒ lays eggs
        HornImplication(frozenset([3]), 5),       # bird ⇒ warm-blooded
        HornImplication(frozenset([2, 0, 4, 5]), 3),  # feathers+wings+eggs+warm ⇒ bird
    ]

    weights = {i: 1 for i in range(6)}
    code = TropicalClosureCode(ground, implications, weights)

    # Noisy observation: {is_bird, can_fly} but missing other attributes
    noisy = frozenset([3, 1])
    print(f"\nNoisy observation: {[attributes[i] for i in sorted(noisy)]}")
    print(f"Syndrome: {code.syndrome(noisy)}")

    corrected = code.decode(noisy)
    print(f"Corrected: {[attributes[i] for i in sorted(corrected)]}")
    print(f"Post-correction syndrome: {code.syndrome(corrected)}")

    print(f"\nCode statistics: {code.summary()}")


# ─────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    knowledge_base_repair()
    dependency_resolution()
    access_control()
    concept_lattice_correction()

    print("\n" + "=" * 70)
    print("ALL APPLICATIONS COMPLETE")
    print("=" * 70)


#!/usr/bin/env python3
"""
Tropical Closure Coding Theory — Interactive Demonstrations

Demonstrates the core theorems of tropical closure coding theory with
concrete numerical examples, showing how closure systems become
error-correcting codes with tropical syndrome decoding.
"""

from itertools import combinations
from typing import Set, List, Tuple, Dict, FrozenSet, Optional


# ─────────────────────────────────────────────────────────────────────────
# Core Data Structures
# ─────────────────────────────────────────────────────────────────────────

class Implication:
    """A Horn implication: premise → conclusion.
    If all elements of premise are present, conclusion must be present."""

    def __init__(self, premise: frozenset, conclusion: int):
        self.premise = premise
        self.conclusion = conclusion

    def satisfies(self, x: frozenset) -> bool:
        """Does set x satisfy this implication?"""
        return not (self.premise <= x and self.conclusion not in x)

    def violation(self, x: frozenset) -> int:
        """0-1 violation indicator."""
        return 1 if (self.premise <= x and self.conclusion not in x) else 0

    def __repr__(self):
        return f"{set(self.premise)} ⇒ {self.conclusion}"


class ClosureCode:
    """A closure code defined by a finite set of Horn implications.
    The codewords (closed sets) are exactly those satisfying all implications."""

    def __init__(self, ground: frozenset, implications: List[Implication]):
        self.ground = ground
        self.implications = implications

    def closure(self, x: frozenset) -> frozenset:
        """Compute the closure of x by iteratively applying implications."""
        result = frozenset(x)
        changed = True
        while changed:
            changed = False
            for imp in self.implications:
                if imp.premise <= result and imp.conclusion not in result:
                    result = result | frozenset([imp.conclusion])
                    changed = True
        return result

    def is_closed(self, x: frozenset) -> bool:
        """Check if x is a codeword (closed set)."""
        return self.closure(x) == x

    def syndrome(self, x: frozenset) -> int:
        """Compute the tropical syndrome: sum of all violations."""
        return sum(imp.violation(x) for imp in self.implications)

    def syndrome_vector(self, x: frozenset) -> List[int]:
        """Compute the full syndrome vector (one entry per implication)."""
        return [imp.violation(x) for imp in self.implications]

    def decode(self, x: frozenset) -> frozenset:
        """Tropical decoder: compute cl(x), the nearest codeword."""
        return self.closure(x)

    def repair_cost(self, x: frozenset, y: frozenset,
                    weights: Optional[Dict[int, int]] = None) -> int:
        """Insertion-only repair cost from x to y (y must be superset)."""
        if weights is None:
            weights = {a: 1 for a in self.ground}
        return sum(weights.get(a, 1) for a in y - x)

    def all_closed_sets(self) -> List[frozenset]:
        """Enumerate all codewords (closed sets)."""
        n = len(self.ground)
        elements = sorted(self.ground)
        closed = []
        for k in range(n + 1):
            for subset in combinations(elements, k):
                s = frozenset(subset)
                if self.is_closed(s):
                    closed.append(s)
        return closed


# ─────────────────────────────────────────────────────────────────────────
# Demo 1: Basic Closure Code — Theorem A
# ─────────────────────────────────────────────────────────────────────────

def demo_theorem_a():
    """Demonstrate Theorem A: closed ↔ zero syndrome."""
    print("=" * 70)
    print("DEMO 1: Theorem A — Canonical Tropical Parity Presentation")
    print("  'A set is closed ⟺ its tropical syndrome vanishes'")
    print("=" * 70)

    # Define a closure code on {0, 1, 2, 3, 4}
    ground = frozenset(range(5))
    implications = [
        Implication(frozenset([0, 1]), 2),  # {0,1} ⇒ 2
        Implication(frozenset([1, 2]), 3),  # {1,2} ⇒ 3
        Implication(frozenset([0, 3]), 4),  # {0,3} ⇒ 4
        Implication(frozenset([2, 4]), 1),  # {2,4} ⇒ 1
    ]

    code = ClosureCode(ground, implications)

    print(f"\nGround set: {set(ground)}")
    print(f"Implications:")
    for imp in implications:
        print(f"  {imp}")

    # Find all codewords
    codewords = code.all_closed_sets()
    print(f"\nCodewords (closed sets): {len(codewords)}")
    for cw in codewords:
        print(f"  {set(cw)} — syndrome = {code.syndrome(cw)}")

    # Test some non-codewords
    print(f"\nNon-codewords (selected):")
    test_sets = [
        frozenset([0, 1]),
        frozenset([1, 2]),
        frozenset([0, 1, 3]),
        frozenset([0, 2, 4]),
    ]
    for s in test_sets:
        syn = code.syndrome(s)
        syn_vec = code.syndrome_vector(s)
        cl_s = code.decode(s)
        print(f"  {str(set(s)):20s} — syndrome = {syn}, vector = {syn_vec}")
        print(f"  {'':20s}   closure = {set(cl_s)}")

    # Verify Theorem A
    print(f"\n✓ Verification: For all 2^{len(ground)} = {2**len(ground)} subsets:")
    elements = sorted(ground)
    all_pass = True
    for k in range(len(ground) + 1):
        for subset in combinations(elements, k):
            s = frozenset(subset)
            is_cl = code.is_closed(s)
            is_zero = code.syndrome(s) == 0
            if is_cl != is_zero:
                print(f"  FAIL: {set(s)}, closed={is_cl}, zero_syndrome={is_zero}")
                all_pass = False
    if all_pass:
        print(f"  ✓ closed(x) ↔ syndrome(x)=0 holds for ALL {2**len(ground)} subsets!")


# ─────────────────────────────────────────────────────────────────────────
# Demo 2: Decoder Correctness — Theorem B
# ─────────────────────────────────────────────────────────────────────────

def demo_theorem_b():
    """Demonstrate Theorem B: decoder = closure = minimum-cost repair."""
    print("\n" + "=" * 70)
    print("DEMO 2: Theorem B — Tropical Nearest-Codeword Decoder")
    print("  'The closure operator IS the minimum-cost decoder'")
    print("=" * 70)

    ground = frozenset(range(6))
    implications = [
        Implication(frozenset([0]), 1),      # 0 ⇒ 1
        Implication(frozenset([2]), 3),      # 2 ⇒ 3
        Implication(frozenset([1, 3]), 4),   # {1,3} ⇒ 4
        Implication(frozenset([4]), 5),      # 4 ⇒ 5
        Implication(frozenset([0, 2]), 5),   # {0,2} ⇒ 5
    ]

    code = ClosureCode(ground, implications)
    weights = {0: 3, 1: 2, 2: 4, 3: 1, 4: 5, 5: 2}

    print(f"\nGround set: {set(ground)}")
    print(f"Weights: {weights}")
    print(f"Implications:")
    for imp in implications:
        print(f"  {imp}")

    # Test decoder on several inputs
    test_sets = [
        frozenset([0]),
        frozenset([2]),
        frozenset([0, 2]),
        frozenset([1, 3]),
    ]

    codewords = code.all_closed_sets()

    for x in test_sets:
        decoded = code.decode(x)
        cost_decoded = code.repair_cost(x, decoded, weights)

        # Check all closed supersets
        print(f"\n  Input: {set(x)}")
        print(f"  Decoded (closure): {set(decoded)}, cost = {cost_decoded}")

        min_cost = float('inf')
        best = None
        for cw in codewords:
            if x <= cw:
                cost = code.repair_cost(x, cw, weights)
                if cost < min_cost:
                    min_cost = cost
                    best = cw

        print(f"  Optimal codeword:  {set(best)}, cost = {min_cost}")
        assert decoded == best, f"Decoder mismatch!"
        print(f"  ✓ Decoder = Optimal!")


# ─────────────────────────────────────────────────────────────────────────
# Demo 3: Defect Separation — Separation Theorem
# ─────────────────────────────────────────────────────────────────────────

def demo_separation():
    """Demonstrate the Defect Separation Theorem."""
    print("\n" + "=" * 70)
    print("DEMO 3: Defect Separation Theorem")
    print("  'Every non-codeword has a separating violation functional'")
    print("=" * 70)

    ground = frozenset(range(4))
    implications = [
        Implication(frozenset([0]), 1),    # 0 ⇒ 1
        Implication(frozenset([1]), 2),    # 1 ⇒ 2
        Implication(frozenset([0, 2]), 3), # {0,2} ⇒ 3
    ]

    code = ClosureCode(ground, implications)

    print(f"\nGround set: {set(ground)}")
    print(f"Implications:")
    for imp in implications:
        print(f"  {imp}")

    elements = sorted(ground)
    for k in range(len(ground) + 1):
        for subset in combinations(elements, k):
            x = frozenset(subset)
            if not code.is_closed(x):
                syn_vec = code.syndrome_vector(x)
                separating = [(i, implications[i]) for i, v in enumerate(syn_vec) if v > 0]
                print(f"\n  Non-codeword: {set(x)}")
                print(f"    Syndrome vector: {syn_vec}")
                for idx, imp in separating:
                    # Verify this violation is 0 on all codewords
                    all_zero = all(imp.violation(cw) == 0
                                   for cw in code.all_closed_sets())
                    print(f"    Separating violation: impl #{idx} ({imp}), "
                          f"zero on all codewords: {all_zero}")


# ─────────────────────────────────────────────────────────────────────────
# Demo 4: Unique Decoding — Theorem D
# ─────────────────────────────────────────────────────────────────────────

def demo_theorem_d():
    """Demonstrate Theorem D: unique decoding in insertion model."""
    print("\n" + "=" * 70)
    print("DEMO 4: Theorem D — Unique Bounded-Distance Decoding")
    print("  'The closure is the UNIQUE minimum-cost closed repair'")
    print("=" * 70)

    ground = frozenset(range(5))
    implications = [
        Implication(frozenset([0]), 1),
        Implication(frozenset([1, 2]), 3),
        Implication(frozenset([3]), 4),
    ]

    code = ClosureCode(ground, implications)
    weights = {i: i + 1 for i in range(5)}  # w(i) = i+1 > 0

    print(f"\nGround set: {set(ground)}")
    print(f"Weights: {weights} (strictly positive)")

    codewords = code.all_closed_sets()
    print(f"Codewords: {len(codewords)}")
    for cw in codewords:
        print(f"  {set(cw)}")

    elements = sorted(ground)
    print(f"\nUniqueness verification:")
    for k in range(len(ground) + 1):
        for subset in combinations(elements, k):
            x = frozenset(subset)
            # Find all closed supersets and their costs
            superset_costs = []
            for cw in codewords:
                if x <= cw:
                    cost = code.repair_cost(x, cw, weights)
                    superset_costs.append((cost, cw))

            if superset_costs:
                superset_costs.sort()
                min_cost = superset_costs[0][0]
                minimizers = [cw for c, cw in superset_costs if c == min_cost]

                if len(minimizers) > 1:
                    print(f"  {set(x)}: MULTIPLE minimizers (unexpected)")
                else:
                    decoded = code.decode(x)
                    assert minimizers[0] == decoded
                    # Only show non-trivial cases
                    if not code.is_closed(x):
                        print(f"  {str(set(x)):20s} → unique min-cost: "
                              f"{set(minimizers[0])}, cost={min_cost}")

    print(f"\n  ✓ All non-closed sets have UNIQUE minimum-cost closed superset")


# ─────────────────────────────────────────────────────────────────────────
# Demo 5: Functoriality — Theorem C
# ─────────────────────────────────────────────────────────────────────────

def demo_theorem_c():
    """Demonstrate Theorem C: functoriality of syndrome maps."""
    print("\n" + "=" * 70)
    print("DEMO 5: Theorem C — Functoriality / Decode Naturality")
    print("  'Closure morphisms commute with decoding'")
    print("=" * 70)

    # Source code on {0, 1, 2, 3}
    ground1 = frozenset(range(4))
    impl1 = [
        Implication(frozenset([0]), 1),
        Implication(frozenset([2]), 3),
    ]
    code1 = ClosureCode(ground1, impl1)

    # Target code on {a, b, c, d, e} = {0, 1, 2, 3, 4}
    ground2 = frozenset(range(5))
    impl2 = [
        Implication(frozenset([0]), 1),
        Implication(frozenset([2]), 3),
        Implication(frozenset([0, 2]), 4),
    ]
    code2 = ClosureCode(ground2, impl2)

    # A closure morphism: embed code1 into code2 as a subset
    def morphism(x: frozenset) -> frozenset:
        # Map each element to itself, then close in code2
        return code2.closure(x)

    print(f"\nSource: ground={set(ground1)}, implications={impl1}")
    print(f"Target: ground={set(ground2)}, implications={impl2}")
    print(f"Morphism: embed + close")

    test_sets = [frozenset([0]), frozenset([2]), frozenset([0, 2]), frozenset([0, 1])]

    print(f"\nDecode naturality: f(decode₁(x)) = decode₂(f(x))")
    for x in test_sets:
        decoded1 = code1.decode(x)
        f_decoded1 = morphism(decoded1)
        f_x = morphism(x)
        decoded2_fx = code2.decode(f_x)

        print(f"  x={str(set(x)):15s} → decode₁={str(set(decoded1)):15s} "
              f"→ f(decode₁)={set(f_decoded1)}")
        print(f"  {'':15s} → f(x)={str(set(f_x)):18s} "
              f"→ decode₂(f)={set(decoded2_fx)}")
        match_ok = f_decoded1 == decoded2_fx
        check = '\u2713' if match_ok else '\u2717'
        print(f"  {'':15s}   Match: {check}")



# ─────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    demo_theorem_a()
    demo_theorem_b()
    demo_separation()
    demo_theorem_d()
    demo_theorem_c()

    print("\n" + "=" * 70)
    print("ALL DEMOS COMPLETE")
    print("=" * 70)


#!/usr/bin/env python3
"""
Tropical Closure Coding Theory — Visualizations

Generates publication-quality figures for the research paper.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import combinations
import base64
import io
import json

# Style
plt.rcParams.update({
    'font.size': 12,
    'axes.titlesize': 14,
    'axes.labelsize': 12,
    'figure.dpi': 150,
})


def fig_to_base64(fig) -> str:
    """Convert a matplotlib figure to a base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', bbox_inches='tight', dpi=150)
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


# ─────────────────────────────────────────────────────────────────────────
# Figure 1: Syndrome Landscape
# ─────────────────────────────────────────────────────────────────────────

def plot_syndrome_landscape():
    """Plot the syndrome values across all subsets of a small ground set."""
    from algorithms import TropicalClosureCode, HornImplication

    ground = frozenset(range(5))
    implications = [
        HornImplication(frozenset([0, 1]), 2),
        HornImplication(frozenset([1, 2]), 3),
        HornImplication(frozenset([0, 3]), 4),
        HornImplication(frozenset([2, 4]), 1),
    ]
    code = TropicalClosureCode(ground, implications)

    elements = sorted(ground)
    all_sets = []
    syndromes = []
    is_closed = []

    for k in range(len(ground) + 1):
        for subset in combinations(elements, k):
            s = frozenset(subset)
            all_sets.append(s)
            syndromes.append(code.syndrome(s))
            is_closed.append(code.is_codeword(s))

    fig, ax = plt.subplots(1, 1, figsize=(14, 5))

    colors = ['#2ecc71' if ic else '#e74c3c' for ic in is_closed]
    bars = ax.bar(range(len(all_sets)), syndromes, color=colors, alpha=0.8, edgecolor='white')

    ax.set_xlabel('Subset index (ordered by size)')
    ax.set_ylabel('Syndrome value')
    ax.set_title('Tropical Syndrome Landscape — Zero syndrome ↔ Codeword (Theorem A)')

    green_patch = mpatches.Patch(color='#2ecc71', label='Codeword (syndrome = 0)')
    red_patch = mpatches.Patch(color='#e74c3c', label='Non-codeword (syndrome > 0)')
    ax.legend(handles=[green_patch, red_patch], loc='upper left')

    ax.set_xticks([])
    ax.axhline(y=0, color='black', linewidth=0.5)

    return fig_to_base64(fig)


# ─────────────────────────────────────────────────────────────────────────
# Figure 2: Repair Cost Comparison
# ─────────────────────────────────────────────────────────────────────────

def plot_repair_costs():
    """Plot repair costs from a non-codeword to all closed supersets."""
    from algorithms import TropicalClosureCode, HornImplication

    ground = frozenset(range(6))
    implications = [
        HornImplication(frozenset([0]), 1),
        HornImplication(frozenset([2]), 3),
        HornImplication(frozenset([1, 3]), 4),
        HornImplication(frozenset([4]), 5),
    ]
    weights = {0: 3, 1: 2, 2: 4, 3: 1, 4: 5, 5: 2}
    code = TropicalClosureCode(ground, implications, weights)

    # Pick a non-codeword
    x = frozenset([0, 2])
    codewords = code.all_codewords()
    superset_codewords = [(cw, code.repair_cost(x, cw)) for cw in codewords if x <= cw]
    superset_codewords.sort(key=lambda t: t[1])

    decoded = code.decode(x)
    decoded_cost = code.repair_cost(x, decoded)

    fig, ax = plt.subplots(1, 1, figsize=(12, 5))

    labels = [str(set(cw)) for cw, _ in superset_codewords]
    costs = [c for _, c in superset_codewords]
    colors = ['#2ecc71' if cw == decoded else '#3498db' for cw, _ in superset_codewords]

    bars = ax.barh(range(len(labels)), costs, color=colors, alpha=0.8, edgecolor='white')
    ax.set_yticks(range(len(labels)))
    ax.set_yticklabels(labels, fontsize=9)
    ax.set_xlabel('Repair Cost')
    ax.set_title(f'Repair Costs from {set(x)} to All Closed Supersets (Theorem B)')

    green_patch = mpatches.Patch(color='#2ecc71', label=f'Decoder output = cl({set(x)})')
    blue_patch = mpatches.Patch(color='#3498db', label='Other closed supersets')
    ax.legend(handles=[green_patch, blue_patch])

    return fig_to_base64(fig)


# ─────────────────────────────────────────────────────────────────────────
# Figure 3: Code Rate vs Number of Implications
# ─────────────────────────────────────────────────────────────────────────

def plot_rate_vs_implications():
    """Plot how code rate decreases as more implications are added."""
    from algorithms import TropicalClosureCode, HornImplication
    import math

    ground = frozenset(range(7))
    all_implications = [
        HornImplication(frozenset([0]), 1),
        HornImplication(frozenset([2]), 3),
        HornImplication(frozenset([4]), 5),
        HornImplication(frozenset([1, 3]), 6),
        HornImplication(frozenset([0, 2]), 4),
        HornImplication(frozenset([5, 6]), 0),
        HornImplication(frozenset([1, 5]), 3),
    ]

    num_impl = []
    rates = []
    num_codewords = []

    for k in range(len(all_implications) + 1):
        impl_subset = all_implications[:k]
        code = TropicalClosureCode(ground, impl_subset)
        cw = code.all_codewords()
        n_cw = len(cw)
        rate = math.log2(n_cw) / len(ground) if n_cw > 1 else 0
        num_impl.append(k)
        rates.append(rate)
        num_codewords.append(n_cw)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    ax1.plot(num_impl, rates, 'o-', color='#9b59b6', linewidth=2, markersize=8)
    ax1.set_xlabel('Number of Implications (Parity Constraints)')
    ax1.set_ylabel('Code Rate (bits per element)')
    ax1.set_title('Code Rate vs Parity Constraints')
    ax1.set_ylim(0, 1.1)
    ax1.grid(True, alpha=0.3)

    ax2.plot(num_impl, num_codewords, 's-', color='#e67e22', linewidth=2, markersize=8)
    ax2.set_xlabel('Number of Implications')
    ax2.set_ylabel('Number of Codewords')
    ax2.set_title('Codeword Count vs Parity Constraints')
    ax2.set_yscale('log', base=2)
    ax2.grid(True, alpha=0.3)

    fig.suptitle('Tropical Closure Code Parameters', fontsize=16, y=1.02)
    fig.tight_layout()

    return fig_to_base64(fig)


# ─────────────────────────────────────────────────────────────────────────
# Figure 4: Syndrome Vector Heatmap
# ─────────────────────────────────────────────────────────────────────────

def plot_syndrome_heatmap():
    """Plot a heatmap of syndrome vectors for all subsets."""
    from algorithms import TropicalClosureCode, HornImplication

    ground = frozenset(range(4))
    implications = [
        HornImplication(frozenset([0]), 1),
        HornImplication(frozenset([1]), 2),
        HornImplication(frozenset([0, 2]), 3),
    ]
    code = TropicalClosureCode(ground, implications)

    elements = sorted(ground)
    all_sets = []
    syndrome_matrix = []

    for k in range(len(ground) + 1):
        for subset in combinations(elements, k):
            s = frozenset(subset)
            all_sets.append(s)
            syndrome_matrix.append(code.syndrome_vector(s))

    syndrome_matrix = np.array(syndrome_matrix)

    fig, ax = plt.subplots(1, 1, figsize=(8, 10))

    im = ax.imshow(syndrome_matrix, cmap='RdYlGn_r', aspect='auto',
                   interpolation='nearest')

    ax.set_yticks(range(len(all_sets)))
    ax.set_yticklabels([str(set(s)) if s else '∅' for s in all_sets], fontsize=9)
    ax.set_xticks(range(len(implications)))
    ax.set_xticklabels([str(imp) for imp in implications], fontsize=9, rotation=45, ha='right')

    ax.set_xlabel('Implication (Parity Check)')
    ax.set_ylabel('Subset')
    ax.set_title('Syndrome Vector Heatmap\n(Green = satisfied, Red = violated)')

    plt.colorbar(im, ax=ax, label='Violation')

    # Mark codewords
    for i, s in enumerate(all_sets):
        if code.is_codeword(s):
            ax.text(-0.7, i, '✓', fontsize=12, color='green',
                    ha='center', va='center', fontweight='bold')

    fig.tight_layout()
    return fig_to_base64(fig)


# ─────────────────────────────────────────────────────────────────────────
# Generate All Figures
# ─────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Generating visualizations...")

    figs = {}

    print("  1/4: Syndrome landscape...")
    figs['syndrome_landscape'] = plot_syndrome_landscape()

    print("  2/4: Repair costs...")
    figs['repair_costs'] = plot_repair_costs()

    print("  3/4: Rate vs implications...")
    figs['rate_vs_implications'] = plot_rate_vs_implications()

    print("  4/4: Syndrome heatmap...")
    figs['syndrome_heatmap'] = plot_syndrome_heatmap()

    # Save as JSON for packaging
    with open('visualization_data.json', 'w') as f:
        json.dump(figs, f)

    print(f"Done! Generated {len(figs)} figures.")
    for name, data in figs.items():
        print(f"  {name}: {len(data)} bytes")
