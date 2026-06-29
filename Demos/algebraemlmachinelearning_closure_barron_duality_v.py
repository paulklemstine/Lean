#!/usr/bin/env python3
"""
Applications of Closure Barron Duality

Demonstrates real-world applications:
1. Feature importance in Boolean concept lattices
2. Knowledge graph dependency extraction
3. Interpretable concept network construction
"""

from demo import FiniteDistribLattice, powerset_lattice
from algorithms import extract_weights, reconstruct_at, certified_recovery


def feature_importance_application():
    """Application 1: Feature importance in a Boolean concept lattice.

    Consider a medical diagnosis system with 4 binary features (symptoms).
    The importance of a feature subset is the maximum individual feature
    importance among the subset — a natural sup-preserving measure.

    The Barron duality theorem says we only need to know the importance
    of individual features (join-irreducibles) to determine the importance
    of ALL feature combinations.
    """
    print("=" * 60)
    print("APPLICATION 1: Medical Feature Importance")
    print("=" * 60)

    features = ["Fever", "Cough", "Fatigue", "Headache"]
    L = powerset_lattice(len(features))

    # Individual feature importances (determined by domain experts)
    importance = {
        frozenset({0}): 8,   # Fever: high importance
        frozenset({1}): 6,   # Cough: moderate
        frozenset({2}): 3,   # Fatigue: low
        frozenset({3}): 5,   # Headache: moderate
    }

    def feature_importance(subset):
        """Max importance over individual features in the subset."""
        vals = [importance[frozenset({i})] for i in subset]
        return max(vals) if vals else 0

    # Extract canonical weights (= individual feature importances)
    weights = extract_weights(L, feature_importance)

    print(f"\nIndividual feature importances (join-irreducibles):")
    for j in L.join_irreducibles():
        idx = list(j)[0]
        print(f"  {features[idx]:>10s}: {weights[j]}")

    print(f"\nDerived importance for ALL {len(L.elements)} feature subsets:")
    for K in sorted(L.elements, key=lambda s: (len(s), sorted(s))):
        if len(K) > 0:
            names = ", ".join(features[i] for i in sorted(K))
            val = reconstruct_at(L, weights, K)
            print(f"  {names:>30s}: importance = {val}")

    print(f"\n→ {len(weights)} weights determine {len(L.elements)-1} non-trivial values")
    print(f"→ Compression ratio: {len(weights)}/{len(L.elements)-1} "
          f"= {len(weights)/(len(L.elements)-1):.0%}")


def knowledge_graph_application():
    """Application 2: Knowledge graph dependency structure.

    A knowledge graph has topics that depend on prerequisites.
    The "mastery level" of a topic set is the max mastery of
    any individual topic — a sup-preserving functional.

    The theorem shows that mastery is determined entirely by
    the atomic (prerequisite-free) topics.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Knowledge Graph Dependencies")
    print("=" * 60)

    topics = ["Algebra", "Calculus", "Statistics", "ML"]
    L = powerset_lattice(len(topics))

    mastery = {
        frozenset({0}): 9,   # Algebra: well understood
        frozenset({1}): 7,   # Calculus: moderate
        frozenset({2}): 4,   # Statistics: basic
        frozenset({3}): 6,   # ML: intermediate
    }

    def mastery_level(subset):
        vals = [mastery[frozenset({i})] for i in subset]
        return max(vals) if vals else 0

    # Certified recovery: learn from minimal queries
    f_hat, weights, certificate = certified_recovery(L, mastery_level)

    print(f"\nCertified recovery from {len(certificate)} oracle queries:")
    for j, v in certificate:
        idx = list(j)[0]
        print(f"  Query: mastery({topics[idx]}) = {v}")

    print(f"\nReconstructed mastery for composite topic sets:")
    for K in sorted(L.elements, key=lambda s: (len(s), sorted(s))):
        if len(K) >= 2:
            names = " + ".join(topics[i] for i in sorted(K))
            val = f_hat(K)
            print(f"  {names:>35s}: mastery = {val}")

    # Verify exact recovery
    all_correct = all(f_hat(K) == mastery_level(K) for K in L.elements)
    print(f"\nExact recovery verified: {all_correct}")


def concept_network_application():
    """Application 3: Interpretable concept network.

    Build a sparse concept network where hidden units correspond to
    join-irreducible elements and weights are canonical.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Sparse Concept Network")
    print("=" * 60)

    n = 5
    L = powerset_lattice(n)
    ji = L.join_irreducibles()

    # Random-ish weights on atoms
    atom_weights = {
        frozenset({0}): 3,
        frozenset({1}): 9,
        frozenset({2}): 1,
        frozenset({3}): 7,
        frozenset({4}): 5,
    }

    def f(K):
        vals = [atom_weights[frozenset({i})] for i in K]
        return max(vals) if vals else 0

    print(f"Network architecture:")
    print(f"  Input: elements of lattice P({{0,...,{n-1}}}), |L| = {len(L.elements)}")
    print(f"  Hidden units: {len(ji)} (one per join-irreducible)")
    print(f"  Aggregation: max-pooling (sup-combination)")
    print(f"\nHidden unit weights (interpretable):")
    for j in ji:
        idx = list(j)[0]
        print(f"  Unit {idx}: w = {atom_weights[j]}")

    # Network evaluation = reconstruction
    print(f"\nNetwork output on sample inputs:")
    sample_inputs = [
        frozenset({0, 1}),
        frozenset({2, 3, 4}),
        frozenset({0, 1, 2, 3, 4}),
        frozenset({1, 3}),
    ]
    for K in sample_inputs:
        output = reconstruct_at(L, atom_weights, K)
        active_units = [list(j)[0] for j in ji if L.le(j, K)]
        print(f"  Input {set(K)}: output = {output} "
              f"(active units: {active_units}, "
              f"max weight: {max(atom_weights[frozenset({i})] for i in active_units)})")

    print(f"\nKey property: every hidden unit has a clear semantic meaning")
    print(f"  (it detects the presence of a specific atomic concept)")
    print(f"  This is guaranteed by the Closure Barron Duality theorem.")


if __name__ == "__main__":
    feature_importance_application()
    knowledge_graph_application()
    concept_network_application()


#!/usr/bin/env python3
"""
Closure Barron Duality: Demonstrations and Numerical Examples

This module demonstrates the Closure Barron Duality theorem on concrete
finite distributive lattices, showing:
1. Birkhoff decomposition into join-irreducibles
2. Atomic representation of monotone sup-preserving functionals
3. Exact reconstruction from join-irreducible weights
4. Sparsity bounds
"""

from __future__ import annotations
from itertools import combinations
from typing import Dict, Set, FrozenSet, Callable, List, Tuple
import math


# ============================================================
# Core: Finite Lattice Operations
# ============================================================

class FiniteDistribLattice:
    """A finite distributive lattice represented by its elements and order."""

    def __init__(self, elements: List, le: Callable):
        """
        Args:
            elements: List of lattice elements.
            le: A function (a, b) -> bool implementing the partial order.
        """
        self.elements = list(elements)
        self.le = le
        # Bot = element below all others (le(bot, y) for all y)
        self._bot = max(self.elements, key=lambda x: sum(1 for y in self.elements if le(x, y)))

    def sup(self, a, b):
        """Binary join (least upper bound)."""
        candidates = [x for x in self.elements if self.le(a, x) and self.le(b, x)]
        # Least element among upper bounds: fewest elements below it
        return min(candidates, key=lambda x: sum(1 for y in self.elements if self.le(y, x)))

    def bot(self):
        return self._bot

    def is_sup_irred(self, j) -> bool:
        """Check if j is join-irreducible (SupIrred).
        j is SupIrred if j is not minimal and for all a, b with a ⊔ b = j,
        either a = j or b = j."""
        if j == self.bot():
            return False
        # j is NOT sup-irred if there exist a, b both strictly below j with a ⊔ b = j
        for a in self.elements:
            if a == j:
                continue
            if not self.le(a, j):
                continue
            for b in self.elements:
                if b == j:
                    continue
                if not self.le(b, j):
                    continue
                if self.sup(a, b) == j:
                    return False
        return True

    def join_irreducibles(self) -> List:
        """Return all join-irreducible elements."""
        return [j for j in self.elements if self.is_sup_irred(j)]

    def sup_irred_below(self, a) -> List:
        """Return join-irreducible elements below a."""
        return [j for j in self.join_irreducibles() if self.le(j, a)]

    def finset_sup(self, elems):
        """Sup of a collection of elements."""
        result = self.bot()
        for e in elems:
            result = self.sup(result, e)
        return result


# ============================================================
# Power-set lattice (canonical example of distributive lattice)
# ============================================================

def powerset_lattice(n: int) -> FiniteDistribLattice:
    """The power-set lattice P({0,...,n-1}), ordered by inclusion."""
    ground = list(range(n))
    elements = []
    for k in range(n + 1):
        for s in combinations(ground, k):
            elements.append(frozenset(s))
    le = lambda a, b: a.issubset(b)
    return FiniteDistribLattice(elements, le)


def divisor_lattice(n: int) -> FiniteDistribLattice:
    """The divisor lattice D(n), ordered by divisibility."""
    divs = [d for d in range(1, n + 1) if n % d == 0]
    le = lambda a, b: b % a == 0

    class DivLattice(FiniteDistribLattice):
        def sup(self, a, b):
            """LCM as join in divisor lattice."""
            return (a * b) // math.gcd(a, b)

    return DivLattice(divs, le)


# ============================================================
# Monotone sup-preserving functionals
# ============================================================

def cardinality_functional(L: FiniteDistribLattice) -> Callable:
    """f(S) = |S| for power-set lattices (monotone but NOT sup-preserving)."""
    return lambda s: len(s)


def max_element_functional(L: FiniteDistribLattice) -> Callable:
    """f(S) = max element in S (or 0 if empty). Monotone and sup-preserving for P(n)."""
    return lambda s: max(s) + 1 if s else 0


def custom_weight_functional(L: FiniteDistribLattice, weights: Dict) -> Callable:
    """Functional defined by sup of weights over join-irreducibles below K.
    This is guaranteed to be monotone and sup-preserving."""
    def f(K):
        return max((weights.get(j, 0) for j in L.sup_irred_below(K)), default=0)
    return f


# ============================================================
# Core algorithms from the theorem
# ============================================================

def extract_canonical_weights(L: FiniteDistribLattice, f: Callable) -> Dict:
    """Extract canonical weights: w(j) = f(j) for join-irreducible j."""
    return {j: f(j) for j in L.join_irreducibles()}


def reconstruct_from_weights(L: FiniteDistribLattice, weights: Dict, K) -> float:
    """Reconstruct f(K) = max{w(j) | j join-irreducible, j ≤ K}."""
    vals = [weights[j] for j in L.join_irreducibles() if L.le(j, K)]
    return max(vals) if vals else 0


def verify_birkhoff(L: FiniteDistribLattice) -> bool:
    """Verify Birkhoff decomposition: every element = sup of JI below it."""
    for a in L.elements:
        ji_below = L.sup_irred_below(a)
        reconstructed = L.finset_sup(ji_below)
        if reconstructed != a:
            return False
    return True


def verify_representation(L: FiniteDistribLattice, f: Callable) -> Tuple[bool, float]:
    """Verify the representation theorem: f(K) = max{f(j) | j ∈ JI, j ≤ K}.
    Returns (success, max_error)."""
    weights = extract_canonical_weights(L, f)
    max_error = 0.0
    for K in L.elements:
        actual = f(K)
        reconstructed = reconstruct_from_weights(L, weights, K)
        error = abs(actual - reconstructed)
        max_error = max(max_error, error)
    return (max_error == 0, max_error)


# ============================================================
# Demonstrations
# ============================================================

def demo_powerset():
    """Demonstrate on the power-set lattice P({0,1,2})."""
    print("=" * 60)
    print("DEMO 1: Power-set lattice P({0,1,2})")
    print("=" * 60)

    L = powerset_lattice(3)
    print(f"Lattice elements: {len(L.elements)}")

    ji = L.join_irreducibles()
    print(f"Join-irreducibles: {[set(j) for j in ji]}")
    print(f"  (These are the singleton sets — the 'atomic' concepts)")

    # Verify Birkhoff
    birkhoff_ok = verify_birkhoff(L)
    print(f"\nBirkhoff decomposition verified: {birkhoff_ok}")

    # Define a monotone sup-preserving functional
    weights = {frozenset({0}): 3, frozenset({1}): 7, frozenset({2}): 2}
    f = custom_weight_functional(L, weights)

    print(f"\nCanonical weights on join-irreducibles:")
    for j in ji:
        print(f"  w({set(j)}) = {weights[j]}")

    print(f"\nFunctional values (max of weights of JI below):")
    for K in sorted(L.elements, key=lambda s: (len(s), sorted(s))):
        ji_below = [set(j) for j in L.sup_irred_below(K)]
        print(f"  f({str(set(K)):>12s}) = {f(K):>3}  (JI below: {ji_below})")

    # Verify representation
    success, error = verify_representation(L, f)
    print(f"\nRepresentation theorem verified: {success} (max error: {error})")

    # Verify determination
    extracted = extract_canonical_weights(L, f)
    print(f"\nExtracted weights match original: {extracted == weights}")

    # Sparsity bound
    print(f"Support bound: |JI(L)| = {len(ji)} ≤ |L| = {len(L.elements)}")


def demo_divisor_lattice():
    """Demonstrate on the divisor lattice D(30)."""
    print("\n" + "=" * 60)
    print("DEMO 2: Divisor lattice D(30)")
    print("=" * 60)

    L = divisor_lattice(30)
    print(f"Divisors of 30: {sorted(L.elements)}")

    ji = L.join_irreducibles()
    print(f"Join-irreducibles: {sorted(ji)}")
    print(f"  (These are 2, 3, 5 — the prime divisors!)")

    birkhoff_ok = verify_birkhoff(L)
    print(f"\nBirkhoff decomposition verified: {birkhoff_ok}")

    # Define weights on primes
    weights = {2: 10, 3: 6, 5: 15}
    f = custom_weight_functional(L, weights)

    print(f"\nCanonical weights: w(2)={weights[2]}, w(3)={weights[3]}, w(5)={weights[5]}")
    print(f"\nFunctional values:")
    for d in sorted(L.elements):
        print(f"  f({d:>2}) = {f(d):>3}  (JI below: {sorted(L.sup_irred_below(d))})")

    success, error = verify_representation(L, f)
    print(f"\nRepresentation verified: {success} (error: {error})")
    print(f"Sparsity: {len(ji)} weights determine all {len(L.elements)} values")


def demo_reconstruction():
    """Demonstrate certified reconstruction from oracle queries."""
    print("\n" + "=" * 60)
    print("DEMO 3: Certified Reconstruction on P({0,1,2,3})")
    print("=" * 60)

    n = 4
    L = powerset_lattice(n)
    ji = L.join_irreducibles()

    # Secret functional (unknown to the learner)
    secret_weights = {
        frozenset({0}): 5,
        frozenset({1}): 12,
        frozenset({2}): 3,
        frozenset({3}): 8
    }
    f_secret = custom_weight_functional(L, secret_weights)

    print(f"Lattice has {len(L.elements)} elements, {len(ji)} join-irreducibles")
    print(f"\nPhase 1: Query oracle on {len(ji)} join-irreducible elements only")

    recovered_weights = {}
    for j in ji:
        val = f_secret(j)  # One oracle query
        recovered_weights[j] = val
        print(f"  Oracle({set(j)}) = {val}")

    print(f"\nPhase 2: Reconstruct functional on ALL {len(L.elements)} elements")
    all_correct = True
    for K in sorted(L.elements, key=lambda s: (len(s), sorted(s))):
        reconstructed = reconstruct_from_weights(L, recovered_weights, K)
        actual = f_secret(K)
        status = "✓" if reconstructed == actual else "✗"
        if reconstructed != actual:
            all_correct = False
        print(f"  f({str(set(K)):>20s}) = {reconstructed:>3} (actual: {actual:>3}) {status}")

    print(f"\nExact reconstruction from {len(ji)} queries: {all_correct}")
    print(f"Sample complexity: {len(ji)}/{len(L.elements)} = "
          f"{len(ji)/len(L.elements):.1%} of lattice evaluated")


def demo_sparsity_comparison():
    """Compare lattice sizes with join-irreducible counts."""
    print("\n" + "=" * 60)
    print("DEMO 4: Sparsity Across Lattice Families")
    print("=" * 60)

    print(f"{'Lattice':>20s} | {'|L|':>5s} | {'|JI|':>4s} | {'Ratio':>6s}")
    print("-" * 45)

    for n in range(2, 7):
        L = powerset_lattice(n)
        ji = L.join_irreducibles()
        ratio = len(ji) / len(L.elements)
        print(f"{'P({0,...,' + str(n-1) + '})':>20s} | {len(L.elements):>5d} | {len(ji):>4d} | {ratio:>6.1%}")

    for n in [6, 12, 30, 60]:
        L = divisor_lattice(n)
        ji = L.join_irreducibles()
        ratio = len(ji) / len(L.elements)
        print(f"{'D(' + str(n) + ')':>20s} | {len(L.elements):>5d} | {len(ji):>4d} | {ratio:>6.1%}")


if __name__ == "__main__":
    demo_powerset()
    demo_divisor_lattice()
    demo_reconstruction()
    demo_sparsity_comparison()


#!/usr/bin/env python3
"""Generate visualizations for the Closure Barron Duality theorem."""

import base64
import io

def generate_lattice_diagram():
    """Generate an SVG diagram of the power-set lattice P({0,1,2}) with join-irreducibles highlighted."""
    svg = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 350" width="400" height="350">
  <style>
    .node { stroke: #333; stroke-width: 2; }
    .ji { fill: #e74c3c; }
    .non-ji { fill: #3498db; }
    .bot { fill: #95a5a6; }
    .top { fill: #2ecc71; }
    .edge { stroke: #999; stroke-width: 1.5; fill: none; }
    .label { font-family: monospace; font-size: 12px; text-anchor: middle; fill: #333; }
    .title { font-family: sans-serif; font-size: 14px; text-anchor: middle; fill: #333; font-weight: bold; }
    .legend { font-family: sans-serif; font-size: 11px; fill: #555; }
  </style>

  <text x="200" y="20" class="title">Power-Set Lattice P({0,1,2}) with Join-Irreducibles</text>

  <!-- Edges (Hasse diagram) -->
  <!-- bot to singletons -->
  <line x1="200" y1="290" x2="100" y2="220" class="edge"/>
  <line x1="200" y1="290" x2="200" y2="220" class="edge"/>
  <line x1="200" y1="290" x2="300" y2="220" class="edge"/>
  <!-- singletons to pairs -->
  <line x1="100" y1="220" x2="100" y2="150" class="edge"/>
  <line x1="100" y1="220" x2="200" y2="150" class="edge"/>
  <line x1="200" y1="220" x2="100" y2="150" class="edge"/>
  <line x1="200" y1="220" x2="300" y2="150" class="edge"/>
  <line x1="300" y1="220" x2="200" y2="150" class="edge"/>
  <line x1="300" y1="220" x2="300" y2="150" class="edge"/>
  <!-- pairs to top -->
  <line x1="100" y1="150" x2="200" y2="80" class="edge"/>
  <line x1="200" y1="150" x2="200" y2="80" class="edge"/>
  <line x1="300" y1="150" x2="200" y2="80" class="edge"/>

  <!-- Nodes -->
  <!-- Bot: empty set -->
  <circle cx="200" cy="290" r="15" class="node bot"/>
  <text x="200" y="320" class="label">∅ (⊥)</text>

  <!-- Join-irreducibles: singletons -->
  <circle cx="100" cy="220" r="15" class="node ji"/>
  <text x="100" y="245" class="label">{0} w=3</text>
  <circle cx="200" cy="220" r="15" class="node ji"/>
  <text x="200" y="245" class="label">{1} w=7</text>
  <circle cx="300" cy="220" r="15" class="node ji"/>
  <text x="300" y="245" class="label">{2} w=2</text>

  <!-- Non-JI: pairs -->
  <circle cx="100" cy="150" r="15" class="node non-ji"/>
  <text x="100" y="135" class="label">{0,1} f=7</text>
  <circle cx="200" cy="150" r="15" class="node non-ji"/>
  <text x="200" y="135" class="label">{0,2} f=3</text>
  <circle cx="300" cy="150" r="15" class="node non-ji"/>
  <text x="300" y="135" class="label">{1,2} f=7</text>

  <!-- Top: full set -->
  <circle cx="200" cy="80" r="15" class="node top"/>
  <text x="200" y="65" class="label">{0,1,2} f=7</text>

  <!-- Legend -->
  <circle cx="30" cy="340" r="6" class="node ji"/>
  <text x="45" y="344" class="legend">Join-irreducible (atom)</text>
  <circle cx="210" cy="340" r="6" class="node non-ji"/>
  <text x="225" y="344" class="legend">Non-JI (determined by atoms)</text>
</svg>'''
    return svg


def generate_sparsity_chart():
    """Generate SVG bar chart of sparsity ratios."""
    data = [
        ("P(2)", 4, 2),
        ("P(3)", 8, 3),
        ("P(4)", 16, 4),
        ("P(5)", 32, 5),
        ("P(6)", 64, 6),
        ("D(6)", 4, 2),
        ("D(12)", 6, 3),
        ("D(30)", 8, 3),
        ("D(60)", 12, 4),
    ]

    width = 500
    height = 300
    margin = 60
    bar_width = 35
    gap = 12

    svg = f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {width} {height}" width="{width}" height="{height}">\n'
    svg += '  <style>\n'
    svg += '    .bar-total { fill: #3498db; opacity: 0.4; }\n'
    svg += '    .bar-ji { fill: #e74c3c; }\n'
    svg += '    .axis { stroke: #333; stroke-width: 1; }\n'
    svg += '    .tick { font-family: monospace; font-size: 10px; text-anchor: middle; fill: #333; }\n'
    svg += '    .ytick { font-family: monospace; font-size: 10px; text-anchor: end; fill: #333; }\n'
    svg += '    .title { font-family: sans-serif; font-size: 13px; text-anchor: middle; fill: #333; font-weight: bold; }\n'
    svg += '    .legend { font-family: sans-serif; font-size: 11px; fill: #555; }\n'
    svg += '  </style>\n'

    svg += f'  <text x="{width/2}" y="18" class="title">Sparsity: |JI(L)| vs |L| Across Lattice Families</text>\n'

    chart_height = height - margin * 2
    chart_width = width - margin * 2
    max_val = max(d[1] for d in data)

    # Y axis
    svg += f'  <line x1="{margin}" y1="{margin}" x2="{margin}" y2="{height-margin}" class="axis"/>\n'
    svg += f'  <line x1="{margin}" y1="{height-margin}" x2="{width-margin}" y2="{height-margin}" class="axis"/>\n'

    for i, tick in enumerate(range(0, max_val + 10, 10)):
        y = height - margin - (tick / max_val) * chart_height
        svg += f'  <text x="{margin-5}" y="{y+4}" class="ytick">{tick}</text>\n'

    for i, (name, total, ji) in enumerate(data):
        x = margin + 10 + i * (bar_width + gap)
        h_total = (total / max_val) * chart_height
        h_ji = (ji / max_val) * chart_height
        y_total = height - margin - h_total
        y_ji = height - margin - h_ji

        svg += f'  <rect x="{x}" y="{y_total}" width="{bar_width}" height="{h_total}" class="bar-total"/>\n'
        svg += f'  <rect x="{x}" y="{y_ji}" width="{bar_width}" height="{h_ji}" class="bar-ji"/>\n'
        svg += f'  <text x="{x + bar_width/2}" y="{height-margin+15}" class="tick">{name}</text>\n'

    # Legend
    svg += f'  <rect x="{width-150}" y="30" width="12" height="12" class="bar-total"/>\n'
    svg += f'  <text x="{width-133}" y="41" class="legend">|L| (total elements)</text>\n'
    svg += f'  <rect x="{width-150}" y="48" width="12" height="12" class="bar-ji"/>\n'
    svg += f'  <text x="{width-133}" y="59" class="legend">|JI| (atoms needed)</text>\n'

    svg += '</svg>'
    return svg


if __name__ == "__main__":
    lattice_svg = generate_lattice_diagram()
    with open("lattice_diagram.svg", "w") as f:
        f.write(lattice_svg)
    print("Generated lattice_diagram.svg")

    sparsity_svg = generate_sparsity_chart()
    with open("sparsity_chart.svg", "w") as f:
        f.write(sparsity_svg)
    print("Generated sparsity_chart.svg")
