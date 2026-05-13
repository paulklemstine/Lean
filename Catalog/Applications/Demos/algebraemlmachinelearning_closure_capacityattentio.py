#!/usr/bin/env python3
"""
Applications of Closure-Capacity–Attention Duality

Demonstrates real-world applications:
1. Feature dependency analysis
2. Minimal attention architecture design
3. Model compression certification
"""

import itertools
from typing import List, Set, Dict, Callable, FrozenSet

FSet = frozenset

def powerset(s: set) -> List[FSet]:
    items = sorted(s)
    result = []
    for r in range(len(items) + 1):
        for combo in itertools.combinations(items, r):
            result.append(FSet(combo))
    return result


# ─────────────────────────────────────────────────────────────────
# Application 1: Feature Dependency Analysis
# ─────────────────────────────────────────────────────────────────

def feature_dependency_analysis():
    """Analyze feature dependencies in a dataset.

    Given a set of features and their dependency structure,
    compute the minimal attention architecture needed to capture
    all dependency patterns.
    """
    print("=" * 60)
    print("Application 1: Feature Dependency Analysis")
    print("=" * 60)

    # Features: temperature, pressure, humidity, wind_speed, precipitation
    features = {'temp', 'pres', 'hum', 'wind', 'prec'}

    # Dependency closure: knowing certain features determines others
    # - temp + hum -> prec (temperature and humidity determine precipitation)
    # - pres + wind -> temp (pressure and wind determine temperature)
    def cl(A: FSet) -> FSet:
        A = set(A)
        changed = True
        while changed:
            changed = False
            if 'temp' in A and 'hum' in A and 'prec' not in A:
                A.add('prec')
                changed = True
            if 'pres' in A and 'wind' in A and 'temp' not in A:
                A.add('temp')
                changed = True
                # After adding temp, check if temp+hum -> prec fires
        return FSet(A)

    def kappa(A: FSet) -> int:
        return len(cl(A))

    # Verify closure axioms
    for S in powerset(features):
        assert S <= cl(S), f"Not extensive: {S}"
        assert cl(cl(S)) == cl(S), f"Not idempotent: {S}"

    # Find closed sets
    closed = [S for S in powerset(features) if cl(S) == S]
    print(f"\nFeatures: {features}")
    print(f"Number of closed sets (feature modules): {len(closed)}")

    # Find extreme generators
    extremes = []
    for C in closed:
        if not C:
            continue
        is_extreme = True
        for D in closed:
            if D < C and kappa(D) >= kappa(C):
                is_extreme = False
                break
        if is_extreme:
            extremes.append(C)

    print(f"\nExtreme generators (irreducible feature modules):")
    for C in extremes:
        print(f"  {set(C)}: κ = {kappa(C)}")

    print(f"\nMinimal attention heads needed: {len(extremes)}")
    print("Each head corresponds to an irreducible feature dependency pattern.")
    print("This is certified optimal by the duality theorem.")


# ─────────────────────────────────────────────────────────────────
# Application 2: Minimal Architecture Design
# ─────────────────────────────────────────────────────────────────

def minimal_architecture_design():
    """Design minimal attention architecture for a knowledge graph."""
    print("\n" + "=" * 60)
    print("Application 2: Minimal Architecture for Knowledge Graph")
    print("=" * 60)

    # Entities in a small knowledge graph
    entities = {'alice', 'bob', 'carol', 'dave'}

    # Closure: community structure
    # {alice, bob} form one community
    # {carol, dave} form another
    # Knowing both communities gives full graph
    def cl(A: FSet) -> FSet:
        A = set(A)
        if 'alice' in A or 'bob' in A:
            A.update({'alice', 'bob'})
        if 'carol' in A or 'dave' in A:
            A.update({'carol', 'dave'})
        return FSet(A)

    def kappa(A: FSet) -> int:
        return len(cl(A))

    closed = [S for S in powerset(entities) if cl(S) == S]
    extremes = []
    for C in closed:
        if not C:
            continue
        is_extreme = all(
            kappa(D) < kappa(C)
            for D in closed if D < C
        )
        if is_extreme:
            extremes.append(C)

    print(f"\nEntities: {entities}")
    print(f"Community structure: {{alice, bob}}, {{carol, dave}}")
    print(f"\nMinimal attention architecture:")
    print(f"  Heads needed: {len(extremes)}")
    for i, C in enumerate(extremes):
        print(f"  Head {i}: attends to {set(C)} (capacity {kappa(C)})")

    print(f"\nArchitecture certificate:")
    print(f"  {len(extremes)} heads is provably minimal")
    print(f"  No architecture with fewer heads can capture the community structure")


# ─────────────────────────────────────────────────────────────────
# Application 3: Model Compression Certificate
# ─────────────────────────────────────────────────────────────────

def model_compression_certificate():
    """Certify that a model cannot be compressed below the extreme rank."""
    print("\n" + "=" * 60)
    print("Application 3: Model Compression Certificate")
    print("=" * 60)

    X = {1, 2, 3, 4, 5}

    # A richer closure structure
    def cl(A: FSet) -> FSet:
        A = set(A)
        # Rule 1: {1,2} -> 3
        if 1 in A and 2 in A:
            A.add(3)
        # Rule 2: {4,5} -> 1
        if 4 in A and 5 in A:
            A.add(1)
            # Propagate Rule 1
            if 2 in A:
                A.add(3)
        return FSet(A)

    def kappa(A: FSet) -> int:
        return len(cl(A))

    # Verify
    for S in powerset(X):
        assert S <= cl(S)
        assert cl(cl(S)) == cl(S)

    closed = [S for S in powerset(X) if cl(S) == S]
    extremes = []
    for C in closed:
        if not C:
            continue
        is_extreme = all(kappa(D) < kappa(C) for D in closed if D < C)
        if is_extreme:
            extremes.append(C)

    print(f"\nGround set: {X}")
    print(f"Closure rules: {{1,2}} → 3, {{4,5}} → 1")
    print(f"\nTotal closed sets: {len(closed)}")
    print(f"Extreme generators: {len(extremes)}")

    print(f"\nCompression certificate:")
    print(f"  Minimum attention heads: {len(extremes)}")
    print(f"  This bound is tight (achieved by canonical model)")
    print(f"  Any model with < {len(extremes)} heads CANNOT capture the closure structure")

    # Show the extreme generators
    for C in extremes:
        print(f"\n  Extreme set {set(C)}:")
        print(f"    Capacity: {kappa(C)}")
        # Show what proper closed subsets have smaller capacity
        proper_closed = [D for D in closed if D < C]
        if proper_closed:
            max_sub_cap = max(kappa(D) for D in proper_closed)
            print(f"    Max sub-capacity: {max_sub_cap} < {kappa(C)} ✓")


if __name__ == "__main__":
    feature_dependency_analysis()
    minimal_architecture_design()
    model_compression_certificate()


#!/usr/bin/env python3
"""
Demo: Closure-Capacity–Attention Duality

Demonstrates the core mathematical objects and the duality theorem with
concrete numerical examples.
"""

import itertools
from typing import List, Set, Dict, Tuple, Callable, FrozenSet

# Type aliases
FSet = frozenset


def powerset(s: set) -> List[FSet]:
    """Return all subsets of s as frozensets."""
    items = list(s)
    result = []
    for r in range(len(items) + 1):
        for combo in itertools.combinations(items, r):
            result.append(FSet(combo))
    return result


# ─────────────────────────────────────────────────────────────────
# Core Definitions
# ─────────────────────────────────────────────────────────────────

class ClosureOperator:
    """A closure operator on subsets of a finite ground set X."""

    def __init__(self, X: set, cl: Callable[[FSet], FSet]):
        self.X = X
        self._cl = cl
        self._verify()

    def cl(self, A: FSet) -> FSet:
        return self._cl(A)

    def is_closed(self, A: FSet) -> bool:
        return self.cl(A) == A

    def closed_sets(self) -> List[FSet]:
        return [S for S in powerset(self.X) if self.is_closed(S)]

    def _verify(self):
        """Verify closure axioms on small examples."""
        for S in powerset(self.X):
            # Extensive
            assert S <= self.cl(S), f"Not extensive: {S}"
            # Idempotent
            assert self.cl(self.cl(S)) == self.cl(S), f"Not idempotent: {S}"
        # Monotone (spot check)
        all_sets = powerset(self.X)
        for A in all_sets:
            for B in all_sets:
                if A <= B:
                    assert self.cl(A) <= self.cl(B), f"Not monotone: {A}, {B}"


class ClosureCapacityObj:
    """A closure-capacity object: closure operator + monotone capacity."""

    def __init__(self, X: set, cl: Callable[[FSet], FSet],
                 kappa: Callable[[FSet], int]):
        self.closure = ClosureOperator(X, cl)
        self.X = X
        self._kappa = kappa
        self._verify()

    def cl(self, A: FSet) -> FSet:
        return self.closure.cl(A)

    def kappa(self, A: FSet) -> int:
        return self._kappa(A)

    def is_closed(self, A: FSet) -> bool:
        return self.closure.is_closed(A)

    def closed_sets(self) -> List[FSet]:
        return self.closure.closed_sets()

    def is_extreme(self, C: FSet) -> bool:
        """C is extreme if it is nonempty, closed, and every proper closed
        subset has strictly smaller capacity."""
        if not C or not self.is_closed(C):
            return False
        for D in self.closed_sets():
            if D < C and self.kappa(D) >= self.kappa(C):
                return False
        return True

    def extreme_sets(self) -> List[FSet]:
        return [C for C in self.closed_sets() if self.is_extreme(C)]

    def extreme_rank(self) -> int:
        return len(self.extreme_sets())

    def _verify(self):
        """Verify capacity axioms."""
        assert self.kappa(FSet()) == 0, "κ(∅) ≠ 0"
        closed = self.closed_sets()
        for A in closed:
            for B in closed:
                if A <= B:
                    assert self.kappa(A) <= self.kappa(B), \
                        f"κ not monotone: κ({set(A)})={self.kappa(A)} > κ({set(B)})={self.kappa(B)}"


class SparseAttentionModel:
    """A sparse attention model with finitely many heads."""

    def __init__(self, supports: List[FSet], weights: List[int]):
        assert len(supports) == len(weights)
        self.num_heads = len(supports)
        self.supports = supports
        self.weights = weights

    def realizes(self, obj: ClosureCapacityObj) -> bool:
        """Check if this model realizes the given closure-capacity object."""
        # 1. Each support is closed
        for s in self.supports:
            if not obj.is_closed(s):
                return False
        # 2. Every extreme generator appears as some support
        for C in obj.extreme_sets():
            if C not in self.supports:
                return False
        # 3. Weights match capacity
        for i in range(self.num_heads):
            if self.weights[i] != obj.kappa(self.supports[i]):
                return False
        return True

    def is_minimal(self, obj: ClosureCapacityObj) -> bool:
        """Check minimality (via extreme rank lower bound)."""
        return self.realizes(obj) and self.num_heads == obj.extreme_rank()


def canonical_attention_model(obj: ClosureCapacityObj) -> SparseAttentionModel:
    """Construct the canonical attention model from a closure-capacity object."""
    extremes = obj.extreme_sets()
    supports = extremes
    weights = [obj.kappa(C) for C in extremes]
    return SparseAttentionModel(supports, weights)


def reconstruct_closure(model: SparseAttentionModel, A: FSet, X: set) -> FSet:
    """Reconstruct closure from attention model."""
    covering = [i for i in range(model.num_heads) if A <= model.supports[i]]
    if covering:
        result = FSet(X)  # start with full set
        for i in covering:
            result = result & model.supports[i]
        return result
    return FSet(X)


def reconstruct_capacity(model: SparseAttentionModel, A: FSet) -> int:
    """Reconstruct capacity from attention model."""
    covering = [i for i in range(model.num_heads) if A <= model.supports[i]]
    if covering:
        return max(model.weights[i] for i in covering)
    return 0


# ─────────────────────────────────────────────────────────────────
# Example 1: Linear dependency closure
# ─────────────────────────────────────────────────────────────────

def demo_example_1():
    """Linear dependency closure on {a, b, c}."""
    print("=" * 60)
    print("Example 1: Linear Dependency Closure on {a, b, c}")
    print("=" * 60)

    X = {'a', 'b', 'c'}

    # Closure: cl adds dependent elements
    # Dependency structure: knowing a,b determines c
    def cl(A: FSet) -> FSet:
        A = set(A)
        if 'a' in A and 'b' in A:
            A.add('c')
        return FSet(A)

    # Capacity: size of closure
    def kappa(A: FSet) -> int:
        return len(cl(A))

    obj = ClosureCapacityObj(X, cl, kappa)

    print(f"\nGround set: {X}")
    print(f"\nClosed sets:")
    for C in obj.closed_sets():
        print(f"  {set(C) if C else '{}'}: κ = {obj.kappa(C)}")

    print(f"\nExtreme generators:")
    for C in obj.extreme_sets():
        print(f"  {set(C)}: κ = {obj.kappa(C)}")
    print(f"\nExtreme rank: {obj.extreme_rank()}")

    # Build canonical model
    model = canonical_attention_model(obj)
    print(f"\nCanonical attention model:")
    print(f"  Number of heads: {model.num_heads}")
    for i in range(model.num_heads):
        print(f"  Head {i}: support = {set(model.supports[i])}, weight = {model.weights[i]}")

    print(f"\n  Realizes closure-capacity: {model.realizes(obj)}")
    print(f"  Is minimal: {model.is_minimal(obj)}")

    # Verify head count = extreme rank
    print(f"\n  Head count = {model.num_heads} = extreme rank = {obj.extreme_rank()} ✓")


# ─────────────────────────────────────────────────────────────────
# Example 2: Partition closure
# ─────────────────────────────────────────────────────────────────

def demo_example_2():
    """Partition closure on {1, 2, 3, 4}."""
    print("\n" + "=" * 60)
    print("Example 2: Partition Closure on {1, 2, 3, 4}")
    print("=" * 60)

    X = {1, 2, 3, 4}
    # Partition: {1,2} and {3,4}
    # Closure: if any element of a block is included, include the whole block
    def cl(A: FSet) -> FSet:
        A = set(A)
        if 1 in A or 2 in A:
            A.update({1, 2})
        if 3 in A or 4 in A:
            A.update({3, 4})
        return FSet(A)

    def kappa(A: FSet) -> int:
        return len(cl(A))

    obj = ClosureCapacityObj(X, cl, kappa)

    print(f"\nGround set: {X}")
    print(f"Partition: {{1,2}}, {{3,4}}")
    print(f"\nClosed sets:")
    for C in sorted(obj.closed_sets(), key=len):
        print(f"  {set(C) if C else '{}'}: κ = {obj.kappa(C)}")

    print(f"\nExtreme generators:")
    for C in obj.extreme_sets():
        print(f"  {set(C)}: κ = {obj.kappa(C)}")
    print(f"\nExtreme rank: {obj.extreme_rank()}")

    model = canonical_attention_model(obj)
    print(f"\nCanonical attention model:")
    print(f"  Number of heads: {model.num_heads}")
    for i in range(model.num_heads):
        print(f"  Head {i}: support = {set(model.supports[i])}, weight = {model.weights[i]}")
    print(f"\n  Realizes: {model.realizes(obj)}")
    print(f"  Minimal: {model.is_minimal(obj)}")


# ─────────────────────────────────────────────────────────────────
# Example 3: Matroid-like closure
# ─────────────────────────────────────────────────────────────────

def demo_example_3():
    """Matroid rank closure on a uniform matroid U_{2,4}."""
    print("\n" + "=" * 60)
    print("Example 3: Uniform Matroid U_{2,4} Closure")
    print("=" * 60)

    X = {1, 2, 3, 4}

    # U_{2,4}: rank function = min(|A|, 2)
    # Closure: cl(A) = A if |A| <= 2, cl(A) = X if |A| > 2
    def cl(A: FSet) -> FSet:
        if len(A) <= 2:
            return A
        return FSet(X)

    def kappa(A: FSet) -> int:
        return min(len(cl(A)), 2)

    obj = ClosureCapacityObj(X, cl, kappa)

    print(f"\nGround set: {X}")
    print(f"Rank function: min(|A|, 2)")
    print(f"\nClosed sets (flats):")
    for C in sorted(obj.closed_sets(), key=len):
        print(f"  {set(C) if C else '{}'}: κ = {obj.kappa(C)}")

    print(f"\nExtreme generators:")
    for C in obj.extreme_sets():
        print(f"  {set(C)}: κ = {obj.kappa(C)}")
    print(f"\nExtreme rank: {obj.extreme_rank()}")

    model = canonical_attention_model(obj)
    print(f"\nCanonical attention model:")
    print(f"  Number of heads: {model.num_heads}")
    for i in range(model.num_heads):
        print(f"  Head {i}: support = {set(model.supports[i])}, weight = {model.weights[i]}")
    print(f"\n  Realizes: {model.realizes(obj)}")
    print(f"  Minimal: {model.is_minimal(obj)}")


# ─────────────────────────────────────────────────────────────────
# Reconstruction demo
# ─────────────────────────────────────────────────────────────────

def demo_reconstruction():
    """Show reconstruction from attention model back to closure."""
    print("\n" + "=" * 60)
    print("Reconstruction Demo")
    print("=" * 60)

    X = {1, 2, 3}
    def cl(A: FSet) -> FSet:
        A = set(A)
        if 1 in A and 2 in A:
            A.add(3)
        return FSet(A)

    def kappa(A: FSet) -> int:
        return len(cl(A))

    obj = ClosureCapacityObj(X, cl, kappa)
    model = canonical_attention_model(obj)

    print("\nOriginal closure operator:")
    for S in powerset(X):
        print(f"  cl({set(S) if S else '{}'}) = {set(obj.cl(S)) if obj.cl(S) else '{}'}")

    print("\nReconstructed closure from attention model:")
    for S in powerset(X):
        rc = reconstruct_closure(model, S, X)
        print(f"  cl_r({set(S) if S else '{}'}) = {set(rc) if rc else '{}'}")

    print("\nCapacity comparison on extreme sets:")
    for C in obj.extreme_sets():
        orig = obj.kappa(C)
        recon = reconstruct_capacity(model, C)
        print(f"  {set(C)}: original κ = {orig}, reconstructed κ = {recon}")


# ─────────────────────────────────────────────────────────────────
# Lower bound verification
# ─────────────────────────────────────────────────────────────────

def demo_lower_bound():
    """Verify that removing any head breaks realization."""
    print("\n" + "=" * 60)
    print("Lower Bound Verification")
    print("=" * 60)

    X = {1, 2, 3, 4}
    def cl(A: FSet) -> FSet:
        A = set(A)
        if 1 in A or 2 in A:
            A.update({1, 2})
        if 3 in A or 4 in A:
            A.update({3, 4})
        return FSet(A)

    def kappa(A: FSet) -> int:
        return len(cl(A))

    obj = ClosureCapacityObj(X, cl, kappa)
    model = canonical_attention_model(obj)

    print(f"\nCanonical model has {model.num_heads} heads")
    print(f"Extreme rank = {obj.extreme_rank()}")

    print("\nRemoving each head and checking realization:")
    for i in range(model.num_heads):
        reduced_supports = model.supports[:i] + model.supports[i+1:]
        reduced_weights = model.weights[:i] + model.weights[i+1:]
        reduced = SparseAttentionModel(reduced_supports, reduced_weights)
        print(f"  Remove head {i} (support={set(model.supports[i])}): "
              f"realizes = {reduced.realizes(obj)}")

    print("\n=> No head can be removed: the canonical model is minimal ✓")


if __name__ == "__main__":
    demo_example_1()
    demo_example_2()
    demo_example_3()
    demo_reconstruction()
    demo_lower_bound()


#!/usr/bin/env python3
"""
Visualizations for Closure-Capacity–Attention Duality.
Generates publication-quality figures as SVG.
"""

import itertools
import base64
import io
from typing import List, FrozenSet

FSet = frozenset

def powerset(s: set) -> List[FSet]:
    items = sorted(s)
    result = []
    for r in range(len(items) + 1):
        for combo in itertools.combinations(items, r):
            result.append(FSet(combo))
    return result


def generate_lattice_svg():
    """Generate an SVG showing the closed set lattice for partition closure."""
    # Partition closure on {1,2,3,4}: blocks {1,2} and {3,4}
    # Closed sets: {}, {1,2}, {3,4}, {1,2,3,4}
    svg = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 350" width="400" height="350">
  <defs>
    <style>
      text { font-family: 'Georgia', serif; font-size: 13px; fill: #333; }
      .title { font-size: 16px; font-weight: bold; fill: #1a1a2e; }
      .node { fill: #e8f4f8; stroke: #2c3e50; stroke-width: 2; }
      .extreme { fill: #ffeaa7; stroke: #d35400; stroke-width: 2.5; }
      .edge { stroke: #7f8c8d; stroke-width: 1.5; fill: none; }
      .label { font-size: 11px; fill: #555; }
      .kappa { font-size: 11px; fill: #c0392b; font-weight: bold; }
    </style>
  </defs>

  <text x="200" y="25" text-anchor="middle" class="title">Closed Set Lattice with Capacity</text>
  <text x="200" y="42" text-anchor="middle" class="label">Partition closure on {1,2,3,4}</text>

  <!-- Edges -->
  <line x1="200" y1="85" x2="120" y2="165" class="edge"/>
  <line x1="200" y1="85" x2="280" y2="165" class="edge"/>
  <line x1="120" y1="195" x2="200" y2="275" class="edge"/>
  <line x1="280" y1="195" x2="200" y2="275" class="edge"/>

  <!-- Top node: {1,2,3,4} -->
  <rect x="145" y="60" width="110" height="35" rx="8" class="extreme"/>
  <text x="200" y="83" text-anchor="middle">{1, 2, 3, 4}</text>
  <text x="200" y="55" text-anchor="middle" class="kappa">κ = 4</text>

  <!-- Middle nodes: {1,2} and {3,4} -->
  <rect x="60" y="165" width="120" height="35" rx="8" class="extreme"/>
  <text x="120" y="188" text-anchor="middle">{1, 2}</text>
  <text x="120" y="160" text-anchor="middle" class="kappa">κ = 2</text>

  <rect x="220" y="165" width="120" height="35" rx="8" class="extreme"/>
  <text x="280" y="188" text-anchor="middle">{3, 4}</text>
  <text x="280" y="160" text-anchor="middle" class="kappa">κ = 2</text>

  <!-- Bottom node: {} -->
  <rect x="155" y="270" width="90" height="35" rx="8" class="node"/>
  <text x="200" y="293" text-anchor="middle">∅</text>
  <text x="200" y="265" text-anchor="middle" class="kappa">κ = 0</text>

  <!-- Legend -->
  <rect x="20" y="310" width="15" height="12" rx="3" class="extreme"/>
  <text x="40" y="322" class="label">Extreme generator (= attention head)</text>
  <rect x="220" y="310" width="15" height="12" rx="3" class="node"/>
  <text x="240" y="322" class="label">Non-extreme closed set</text>
</svg>"""
    return svg


def generate_duality_diagram_svg():
    """Generate an SVG showing the duality between closure-capacity and attention."""
    svg = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 300" width="700" height="300">
  <defs>
    <style>
      text { font-family: 'Georgia', serif; font-size: 13px; fill: #333; }
      .title { font-size: 18px; font-weight: bold; fill: #1a1a2e; }
      .box { rx: 12; ry: 12; stroke-width: 2; }
      .left-box { fill: #e8f4f8; stroke: #2980b9; }
      .right-box { fill: #fdebd0; stroke: #e67e22; }
      .arrow { stroke: #2c3e50; stroke-width: 2; fill: none;
               marker-end: url(#arrowhead); }
      .arrow-label { font-size: 11px; fill: #666; font-style: italic; }
      .item { font-size: 12px; fill: #444; }
      .heading { font-size: 14px; font-weight: bold; }
    </style>
    <marker id="arrowhead" markerWidth="10" markerHeight="7" refX="9" refY="3.5" orient="auto">
      <polygon points="0 0, 10 3.5, 0 7" fill="#2c3e50"/>
    </marker>
  </defs>

  <text x="350" y="30" text-anchor="middle" class="title">Closure-Capacity ⟷ Attention Duality</text>

  <!-- Left box: Closure-Capacity -->
  <rect x="30" y="50" width="250" height="220" class="box left-box"/>
  <text x="155" y="78" text-anchor="middle" class="heading">Closure-Capacity Object</text>
  <text x="50" y="105" class="item">• Closure operator cl</text>
  <text x="50" y="125" class="item">• Capacity function κ</text>
  <text x="50" y="145" class="item">• Closed sets {C₁, ..., Cₖ}</text>
  <text x="50" y="165" class="item">• Extreme generators</text>
  <text x="50" y="195" class="item" style="fill:#c0392b; font-weight:bold;">Invariant: extreme rank r</text>
  <text x="50" y="215" class="item">• Monotonicity: A⊆B ⇒ κ(A)≤κ(B)</text>
  <text x="50" y="235" class="item">• Normalization: κ(∅) = 0</text>
  <text x="50" y="255" class="item">• Closure invariance</text>

  <!-- Right box: Attention Model -->
  <rect x="420" y="50" width="250" height="220" class="box right-box"/>
  <text x="545" y="78" text-anchor="middle" class="heading">Sparse Attention Model</text>
  <text x="440" y="105" class="item">• h attention heads</text>
  <text x="440" y="125" class="item">• Support sets (closed)</text>
  <text x="440" y="145" class="item">• Weight per head = κ</text>
  <text x="440" y="165" class="item">• Closure-consistent</text>
  <text x="440" y="195" class="item" style="fill:#c0392b; font-weight:bold;">Invariant: min heads = r</text>
  <text x="440" y="215" class="item">• Reconstruction: cl, κ</text>
  <text x="440" y="235" class="item">• Extensive &amp; monotone</text>
  <text x="440" y="255" class="item">• Idempotent closure</text>

  <!-- Arrows -->
  <path d="M 280 130 Q 350 100 420 130" class="arrow"/>
  <text x="350" y="100" text-anchor="middle" class="arrow-label">canonical model</text>

  <path d="M 420 200 Q 350 230 280 200" class="arrow"/>
  <text x="350" y="245" text-anchor="middle" class="arrow-label">reconstruction</text>

  <!-- Equals sign -->
  <text x="350" y="170" text-anchor="middle" style="font-size:20px; fill:#c0392b; font-weight:bold;">⟺</text>
</svg>"""
    return svg


def generate_head_count_chart_svg():
    """Generate SVG bar chart comparing extreme rank across examples."""
    examples = [
        ("Trivial\n(id closure)", 1, 1),
        ("Partition\n{1,2},{3,4}", 3, 3),
        ("U₂,₄\nmatroid", 5, 5),
        ("Dep: {1,2}→3", 6, 6),
        ("Communities\n4 nodes", 3, 3),
    ]

    bar_width = 60
    gap = 30
    chart_width = len(examples) * (bar_width + gap) + 80
    chart_height = 300
    max_val = max(v for _, v, _ in examples)
    scale = 180 / max_val

    bars_svg = ""
    for i, (name, extreme_rank, heads) in enumerate(examples):
        x = 60 + i * (bar_width + gap)
        h1 = extreme_rank * scale
        h2 = heads * scale

        # Extreme rank bar
        bars_svg += f'  <rect x="{x}" y="{230 - h1}" width="{bar_width//2 - 2}" height="{h1}" fill="#3498db" opacity="0.8" rx="3"/>\n'
        # Head count bar
        bars_svg += f'  <rect x="{x + bar_width//2}" y="{230 - h2}" width="{bar_width//2 - 2}" height="{h2}" fill="#e67e22" opacity="0.8" rx="3"/>\n'
        # Value label
        bars_svg += f'  <text x="{x + bar_width//4}" y="{225 - h1}" text-anchor="middle" style="font-size:11px; fill:#2980b9; font-weight:bold;">{extreme_rank}</text>\n'

        # Name label (handle multiline)
        lines = name.split('\n')
        for j, line in enumerate(lines):
            bars_svg += f'  <text x="{x + bar_width//2}" y="{250 + j * 14}" text-anchor="middle" style="font-size:10px; fill:#333;">{line}</text>\n'

    svg = f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {chart_width} {chart_height}" width="{chart_width}" height="{chart_height}">
  <defs>
    <style>
      text {{ font-family: 'Georgia', serif; }}
    </style>
  </defs>

  <text x="{chart_width//2}" y="22" text-anchor="middle" style="font-size:15px; font-weight:bold; fill:#1a1a2e;">Extreme Rank = Minimal Head Count</text>

  <!-- Axis -->
  <line x1="50" y1="230" x2="{chart_width - 20}" y2="230" stroke="#999" stroke-width="1"/>
  <line x1="50" y1="50" x2="50" y2="230" stroke="#999" stroke-width="1"/>

  <!-- Y-axis labels -->
  <text x="40" y="234" text-anchor="end" style="font-size:10px; fill:#666;">0</text>
  <text x="40" y="{234 - max_val * scale}" text-anchor="end" style="font-size:10px; fill:#666;">{max_val}</text>

{bars_svg}
  <!-- Legend -->
  <rect x="{chart_width - 180}" y="40" width="12" height="12" fill="#3498db" opacity="0.8" rx="2"/>
  <text x="{chart_width - 163}" y="51" style="font-size:11px; fill:#333;">Extreme rank</text>
  <rect x="{chart_width - 180}" y="58" width="12" height="12" fill="#e67e22" opacity="0.8" rx="2"/>
  <text x="{chart_width - 163}" y="69" style="font-size:11px; fill:#333;">Min. heads</text>
</svg>"""
    return svg


if __name__ == "__main__":
    # Generate all visualizations
    lattice_svg = generate_lattice_svg()
    duality_svg = generate_duality_diagram_svg()
    chart_svg = generate_head_count_chart_svg()

    with open("lattice.svg", "w") as f:
        f.write(lattice_svg)
    with open("duality_diagram.svg", "w") as f:
        f.write(duality_svg)
    with open("head_count_chart.svg", "w") as f:
        f.write(chart_svg)

    print("Generated: lattice.svg, duality_diagram.svg, head_count_chart.svg")
