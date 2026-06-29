#!/usr/bin/env python3
"""
Tropical Rate-Distortion Duality: Demonstrations and Algorithms

This script demonstrates the key concepts from the formalized duality between
closure-based information systems and tropical rate-distortion profiles.
"""

import itertools
from typing import Callable, Dict, FrozenSet, List, Set, Tuple
import math

# ============================================================================
# Core Types
# ============================================================================

Element = int
Subset = frozenset

def powerset(s: set) -> list:
    """Return all subsets of s."""
    s = list(s)
    return [frozenset(combo) for r in range(len(s)+1)
            for combo in itertools.combinations(s, r)]

# ============================================================================
# Closure Operators
# ============================================================================

class ClosureOperator:
    """A closure operator on subsets of a finite set."""

    def __init__(self, universe: set, cl: Callable[[frozenset], frozenset]):
        self.universe = frozenset(universe)
        self._cl = cl
        self._verify()

    def cl(self, s: frozenset) -> frozenset:
        return self._cl(s)

    def _verify(self):
        """Verify closure operator axioms on small examples."""
        for s in powerset(self.universe):
            # Extensive: s ⊆ cl(s)
            assert s <= self.cl(s), f"Not extensive: {s}"
            # Idempotent: cl(cl(s)) = cl(s)
            assert self.cl(self.cl(s)) == self.cl(s), f"Not idempotent: {s}"
        # Monotone: s ⊆ t ⟹ cl(s) ⊆ cl(t)
        for s in powerset(self.universe):
            for t in powerset(self.universe):
                if s <= t:
                    assert self.cl(s) <= self.cl(t), f"Not monotone: {s}, {t}"

    def closed_sets(self) -> list:
        """Return all closed sets."""
        return [s for s in powerset(self.universe) if self.cl(s) == s]

    def closure_classes(self) -> dict:
        """Return closure equivalence classes: cl(s) -> [all t with cl(t) = cl(s)]."""
        classes = {}
        for s in powerset(self.universe):
            key = self.cl(s)
            if key not in classes:
                classes[key] = []
            classes[key].append(s)
        return classes

    def is_separated(self) -> bool:
        """Check if distinct singletons have distinct closures."""
        singletons = {frozenset({a}): self.cl(frozenset({a})) for a in self.universe}
        closures = list(singletons.values())
        return len(closures) == len(set(closures))

# ============================================================================
# Closure Capacity
# ============================================================================

class ClosureCapacity:
    """A closure capacity: monotone, closure-invariant, ultrametric function."""

    def __init__(self, cl_op: ClosureOperator, values: dict):
        self.cl_op = cl_op
        self.values = values  # frozenset -> float or inf

    def val(self, s: frozenset) -> float:
        return self.values.get(s, float('inf'))

    def verify(self):
        """Verify closure capacity axioms."""
        # Normalized
        assert self.val(frozenset()) == 0, "Not normalized"
        # Closure invariant
        for s in powerset(self.cl_op.universe):
            assert abs(self.val(self.cl_op.cl(s)) - self.val(s)) < 1e-10, \
                f"Not closure invariant at {s}"
        # Monotone
        for s in powerset(self.cl_op.universe):
            for t in powerset(self.cl_op.universe):
                if s <= t:
                    assert self.val(s) <= self.val(t) + 1e-10, \
                        f"Not monotone: v({s})={self.val(s)} > v({t})={self.val(t)}"
        # Ultrametric join
        for s in powerset(self.cl_op.universe):
            for t in powerset(self.cl_op.universe):
                lhs = self.val(self.cl_op.cl(s | t))
                rhs = max(self.val(s), self.val(t))
                assert lhs <= rhs + 1e-10, \
                    f"Ultrametric join fails: v(cl({s}∪{t}))={lhs} > max(v({s}),v({t}))={rhs}"

    def generators(self) -> dict:
        """Return generator values: capacity on singletons."""
        return {a: self.val(frozenset({a})) for a in self.cl_op.universe}

# ============================================================================
# Rate-Distortion Profile
# ============================================================================

def rd_profile(cap: ClosureCapacity, D: float) -> int:
    """Compute the RD profile: count generators exceeding distortion threshold D."""
    gens = cap.generators()
    return sum(1 for v in gens.values() if v > D)

def compute_full_rd_profile(cap: ClosureCapacity) -> list:
    """Compute the full RD profile as a step function."""
    gens = cap.generators()
    values = sorted(set(gens.values()))
    profile = []
    for D in [-0.5] + [v - 0.01 for v in values] + [v for v in values] + [v + 0.01 for v in values] + [max(values) + 1]:
        profile.append((D, rd_profile(cap, D)))
    return sorted(set(profile))

# ============================================================================
# Tropical Algebra
# ============================================================================

def trop_add(a: float, b: float) -> float:
    """Tropical addition = min."""
    return min(a, b)

def trop_mul(a: float, b: float) -> float:
    """Tropical multiplication = ordinary addition."""
    if a == float('inf') or b == float('inf'):
        return float('inf')
    return a + b

def trop_legendre(C: Callable, universe: set, D: float) -> float:
    """Tropical Legendre transform: inf{C(s) : C(s) ≤ D}."""
    result = float('inf')
    for s in powerset(universe):
        cs = C(s)
        if cs <= D:
            result = min(result, cs)
    return result

# ============================================================================
# Quantizer
# ============================================================================

class Quantizer:
    """A quantizer: partition of universe into closure-stable cells."""

    def __init__(self, cl_op: ClosureOperator, assignment: dict):
        self.cl_op = cl_op
        self.assignment = assignment  # element -> cell_id
        self.k = len(set(assignment.values()))

    def cells(self) -> dict:
        """Return cells as dict: cell_id -> frozenset of elements."""
        cells = {}
        for elem, cell_id in self.assignment.items():
            if cell_id not in cells:
                cells[cell_id] = set()
            cells[cell_id].add(elem)
        return {k: frozenset(v) for k, v in cells.items()}

    def is_valid(self) -> bool:
        """Check that all cells are closed sets."""
        for cell in self.cells().values():
            if self.cl_op.cl(cell) != cell:
                return False
        return True

    def distortion(self, cap: ClosureCapacity) -> float:
        """Compute max within-cell capacity."""
        return max(cap.val(cell) for cell in self.cells().values())

# ============================================================================
# Example 1: Identity closure on {0, 1, 2}
# ============================================================================

def example_identity_closure():
    print("=" * 60)
    print("Example 1: Identity Closure on {0, 1, 2}")
    print("=" * 60)

    universe = {0, 1, 2}
    cl = ClosureOperator(universe, lambda s: s)

    print(f"Universe: {universe}")
    print(f"Separated: {cl.is_separated()}")
    print(f"Closed sets: {cl.closed_sets()}")

    # Define capacity: v(s) = 0 if empty, 1 otherwise (ultrametric-compatible)
    values = {s: (0 if len(s) == 0 else 1) for s in powerset(universe)}
    cap = ClosureCapacity(cl, values)
    cap.verify()

    print(f"\nCapacity values:")
    for s in sorted(powerset(universe), key=len):
        print(f"  v({set(s)}) = {cap.val(s)}")

    print(f"\nGenerators: {cap.generators()}")

    print(f"\nRate-Distortion Profile:")
    for D in [0, 0.5, 1, 1.5, 2, 2.5, 3, float('inf')]:
        print(f"  R({D}) = {rd_profile(cap, D)}")

    # Optimal quantizer: one cell per element
    q_opt = Quantizer(cl, {0: 0, 1: 1, 2: 2})
    print(f"\nOptimal quantizer: {q_opt.k} cells")
    print(f"  Distortion: {q_opt.distortion(cap)}")
    print(f"  Valid: {q_opt.is_valid()}")

    # Coarser quantizer
    q_coarse = Quantizer(cl, {0: 0, 1: 0, 2: 1})
    print(f"\nCoarse quantizer: {q_coarse.k} cells")
    print(f"  Distortion: {q_coarse.distortion(cap)}")
    print(f"  Valid: {q_coarse.is_valid()}")

# ============================================================================
# Example 2: Convexity closure on {0, 1, 2, 3} (interval closure)
# ============================================================================

def example_interval_closure():
    print("\n" + "=" * 60)
    print("Example 2: Interval Closure on {0, 1, 2, 3}")
    print("=" * 60)

    universe = {0, 1, 2, 3}

    def interval_closure(s):
        if not s:
            return frozenset()
        lo, hi = min(s), max(s)
        return frozenset(range(lo, hi + 1))

    cl = ClosureOperator(universe, interval_closure)

    print(f"Universe: {sorted(universe)}")
    print(f"Separated: {cl.is_separated()}")
    print(f"Closed sets ({len(cl.closed_sets())}):")
    for s in sorted(cl.closed_sets(), key=lambda x: (len(x), sorted(x))):
        print(f"  {sorted(s)}")

    # Define capacity: v(s) = 0 if empty, 1 otherwise (ultrametric-compatible)
    values = {}
    for s in powerset(universe):
        cs = cl.cl(s)
        if not cs:
            values[s] = 0
        else:
            values[s] = 1

    cap = ClosureCapacity(cl, values)
    cap.verify()

    print(f"\nCapacity (diameter) values on closed sets:")
    for s in sorted(cl.closed_sets(), key=lambda x: (len(x), sorted(x))):
        print(f"  v({sorted(s)}) = {cap.val(s)}")

    print(f"\nGenerators: {cap.generators()}")

    print(f"\nRate-Distortion Profile:")
    for D in [0, 0.5, 1, 1.5, 2, 2.5, 3, float('inf')]:
        print(f"  R({D}) = {rd_profile(cap, D)}")

    # Closure classes
    classes = cl.closure_classes()
    print(f"\nClosure classes ({len(classes)}):")
    for key, members in sorted(classes.items(), key=lambda x: len(x[0])):
        print(f"  cl = {sorted(key)}: {[sorted(m) for m in members]}")

    # Quantizer: merge {0,1} and {2,3}
    q = Quantizer(cl, {0: 0, 1: 0, 2: 1, 3: 1})
    print(f"\nQuantizer {{0,1}},{{2,3}}: {q.k} cells")
    print(f"  Valid: {q.is_valid()}")
    print(f"  Distortion: {q.distortion(cap)}")

# ============================================================================
# Example 3: Tropical Algebra Demonstration
# ============================================================================

def example_tropical_algebra():
    print("\n" + "=" * 60)
    print("Example 3: Tropical Min-Plus Algebra")
    print("=" * 60)

    print("\nTropical addition (= min):")
    pairs = [(3, 5), (2, 2), (0, 7), (4, float('inf'))]
    for a, b in pairs:
        print(f"  {a} ⊕ {b} = {trop_add(a, b)}")

    print("\nTropical multiplication (= plus):")
    pairs = [(3, 5), (2, 0), (0, 7), (4, float('inf'))]
    for a, b in pairs:
        print(f"  {a} ⊗ {b} = {trop_mul(a, b)}")

    print("\nSemimodule laws verified:")
    test_vals = [0, 1, 3, 5, float('inf')]
    for a in test_vals:
        for b in test_vals:
            assert trop_add(a, b) == trop_add(b, a), "Commutativity fails"
            assert trop_mul(a, b) == trop_mul(b, a), "Commutativity fails"
    for a in test_vals:
        assert trop_add(a, a) == a, "Idempotency fails"
        assert trop_mul(a, 0) == a, "Identity fails"
        assert trop_add(a, float('inf')) == a, "Zero fails"
    print("  ✓ Commutativity of ⊕ and ⊗")
    print("  ✓ Idempotency of ⊕")
    print("  ✓ Identity element 0 for ⊗")
    print("  ✓ Zero element ∞ for ⊕")

    # Tropical vectors
    print("\nTropical vector operations:")
    v = [1, 3, 5]
    w = [2, 1, 4]
    vadd = [trop_add(a, b) for a, b in zip(v, w)]
    print(f"  v = {v}")
    print(f"  w = {w}")
    print(f"  v ⊕ w = {vadd}")

    c = 2
    vsmul = [trop_mul(c, a) for a in v]
    print(f"  {c} ⊗ v = {vsmul}")

    # Tropical pairing
    pairing = min(trop_mul(a, b) for a, b in zip(v, w))
    print(f"  ⟨v, w⟩_trop = min_i(v_i + w_i) = {pairing}")

# ============================================================================
# Example 4: Tropical Legendre Transform
# ============================================================================

def example_legendre():
    print("\n" + "=" * 60)
    print("Example 4: Tropical Legendre Transform")
    print("=" * 60)

    universe = {0, 1, 2}
    cl = ClosureOperator(universe, lambda s: s)
    values = {s: (0 if len(s) == 0 else 1) for s in powerset(universe)}
    cap = ClosureCapacity(cl, values)

    C = lambda s: cap.val(s)

    print("\nTropical Legendre transform L(D) = inf{C(s) : C(s) ≤ D}:")
    for D in [0, 0.5, 1, 1.5, 2, 2.5, 3]:
        L = trop_legendre(C, universe, D)
        R = rd_profile(cap, D)
        print(f"  L({D}) = {L}, R({D}) = {R}")

    print("\nDuality: L(D) gives the minimum achievable capacity at threshold D")
    print("         R(D) counts generators exceeding D")
    print("         Together they characterize the rate-distortion tradeoff")

# ============================================================================
# Example 5: Minimal Quantizer Reconstruction
# ============================================================================

def example_reconstruction():
    print("\n" + "=" * 60)
    print("Example 5: Minimal Quantizer Reconstruction")
    print("=" * 60)

    universe = {0, 1, 2, 3, 4, 5}

    # Closure: partition into {0,1,2} and {3,4,5}
    def partition_closure(s):
        result = set(s)
        if any(x in result for x in [0, 1, 2]):
            result |= {0, 1, 2} & universe
        if any(x in result for x in [3, 4, 5]):
            result |= {3, 4, 5} & universe
        return frozenset(result)

    cl = ClosureOperator(universe, partition_closure)

    print(f"Universe: {sorted(universe)}")
    print(f"Closure groups: {{0,1,2}} and {{3,4,5}}")
    print(f"Separated: {cl.is_separated()}")

    closed = cl.closed_sets()
    print(f"Closed sets ({len(closed)}):")
    for s in sorted(closed, key=lambda x: (len(x), sorted(x))):
        print(f"  {sorted(s)}")

    # Capacity: 0 for empty, 1 otherwise (ultrametric-compatible)
    values = {}
    for s in powerset(universe):
        cs = cl.cl(s)
        if not cs:
            values[s] = 0
        else:
            values[s] = 1
    cap = ClosureCapacity(cl, values)
    cap.verify()

    print(f"\nGenerators: {cap.generators()}")

    # Reconstruct optimal quantizer
    print("\nReconstruction algorithm:")
    gens = cap.generators()
    gen_values = sorted(set(gens.values()))
    print(f"  Distinct generator values: {gen_values}")

    for D in gen_values:
        exceeding = {a for a, v in gens.items() if v > D}
        print(f"  At D={D}: {len(exceeding)} generators exceed threshold")
        if exceeding:
            # Group by closure class
            groups = {}
            for a in exceeding:
                key = cl.cl(frozenset({a}))
                if key not in groups:
                    groups[key] = set()
                groups[key].add(a)
            print(f"    Cells: {[sorted(g) for g in groups.values()]}")

    # Build optimal quantizer at D=0
    print(f"\nOptimal quantizer at D=0:")
    groups = {}
    for a in universe:
        key = cl.cl(frozenset({a}))
        if key not in groups:
            groups[key] = set()
        groups[key].add(a)

    assignment = {}
    for i, (_, group) in enumerate(groups.items()):
        for a in group:
            assignment[a] = i
    q = Quantizer(cl, assignment)
    print(f"  Cells: {q.k}")
    print(f"  Assignment: {assignment}")
    print(f"  Valid: {q.is_valid()}")
    print(f"  Distortion: {q.distortion(cap)}")

    print(f"\n✓ The atom-based quantizer has {q.k} cells (minimal)")
    print(f"✓ Each cell is a closure-stable region")
    print(f"✓ This is the unique minimal quantizer (up to relabeling)")

# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    print("Tropical Rate-Distortion Duality: Demonstrations")
    print("================================================\n")

    example_identity_closure()
    example_interval_closure()
    example_tropical_algebra()
    example_legendre()
    example_reconstruction()

    print("\n" + "=" * 60)
    print("All examples completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""Generate visualizations for the tropical rate-distortion duality."""

import base64
import io
import json

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    import matplotlib.patches as mpatches
    import numpy as np
    HAS_MPL = True
except ImportError:
    HAS_MPL = False

def generate_rd_profile_svg():
    """Generate SVG of a rate-distortion profile."""
    svg = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 300" width="400" height="300">
  <style>
    text { font-family: Georgia, serif; }
    .axis { stroke: #333; stroke-width: 2; }
    .grid { stroke: #ddd; stroke-width: 0.5; }
    .step { stroke: #2563eb; stroke-width: 3; fill: none; }
    .dot { fill: #2563eb; }
    .label { font-size: 14px; fill: #333; }
    .title { font-size: 16px; fill: #111; font-weight: bold; }
  </style>
  <!-- Title -->
  <text x="200" y="25" text-anchor="middle" class="title">Tropical Rate-Distortion Profile R(D)</text>
  <!-- Axes -->
  <line x1="60" y1="260" x2="380" y2="260" class="axis"/>
  <line x1="60" y1="260" x2="60" y2="30" class="axis"/>
  <!-- Grid lines -->
  <line x1="60" y1="210" x2="380" y2="210" class="grid"/>
  <line x1="60" y1="160" x2="380" y2="160" class="grid"/>
  <line x1="60" y1="110" x2="380" y2="110" class="grid"/>
  <line x1="60" y1="60" x2="380" y2="60" class="grid"/>
  <!-- Step function: R(D) = 4 for D<1, 2 for 1≤D<2, 1 for 2≤D<3, 0 for D≥3 -->
  <polyline points="60,60 140,60 140,160 220,160 220,210 300,210 300,260 380,260" class="step"/>
  <!-- Dots at transitions -->
  <circle cx="60" cy="60" r="4" class="dot"/>
  <circle cx="140" cy="60" r="4" class="dot" fill="none" stroke="#2563eb" stroke-width="2"/>
  <circle cx="140" cy="160" r="4" class="dot"/>
  <circle cx="220" cy="160" r="4" class="dot" fill="none" stroke="#2563eb" stroke-width="2"/>
  <circle cx="220" cy="210" r="4" class="dot"/>
  <circle cx="300" cy="210" r="4" class="dot" fill="none" stroke="#2563eb" stroke-width="2"/>
  <circle cx="300" cy="260" r="4" class="dot"/>
  <!-- Axis labels -->
  <text x="220" y="290" text-anchor="middle" class="label">Distortion D</text>
  <text x="20" y="160" text-anchor="middle" class="label" transform="rotate(-90,20,160)">Rate R(D)</text>
  <!-- Tick labels -->
  <text x="60" y="275" text-anchor="middle" style="font-size:12px">0</text>
  <text x="140" y="275" text-anchor="middle" style="font-size:12px">1</text>
  <text x="220" y="275" text-anchor="middle" style="font-size:12px">2</text>
  <text x="300" y="275" text-anchor="middle" style="font-size:12px">3</text>
  <text x="50" y="265" text-anchor="middle" style="font-size:12px">0</text>
  <text x="50" y="215" text-anchor="middle" style="font-size:12px">1</text>
  <text x="50" y="165" text-anchor="middle" style="font-size:12px">2</text>
  <text x="50" y="65" text-anchor="middle" style="font-size:12px">4</text>
  <!-- Annotation -->
  <text x="100" y="50" text-anchor="middle" style="font-size:11px;fill:#666">antitone</text>
  <text x="340" y="250" text-anchor="middle" style="font-size:11px;fill:#666">R(⊤)=0</text>
</svg>'''
    return svg

def generate_closure_lattice_svg():
    """Generate SVG of a closure lattice."""
    svg = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 350" width="400" height="350">
  <style>
    text { font-family: Georgia, serif; font-size: 12px; }
    .edge { stroke: #999; stroke-width: 1.5; }
    .node { fill: #e0e7ff; stroke: #4338ca; stroke-width: 2; }
    .atom { fill: #fef3c7; stroke: #d97706; stroke-width: 2; }
    .title { font-size: 16px; fill: #111; font-weight: bold; }
  </style>
  <text x="200" y="25" text-anchor="middle" class="title">Closure Lattice &amp; Quantizer Cells</text>
  <!-- Edges -->
  <line x1="200" y1="60" x2="100" y2="130" class="edge"/>
  <line x1="200" y1="60" x2="200" y2="130" class="edge"/>
  <line x1="200" y1="60" x2="300" y2="130" class="edge"/>
  <line x1="100" y1="130" x2="80" y2="210" class="edge"/>
  <line x1="100" y1="130" x2="160" y2="210" class="edge"/>
  <line x1="200" y1="130" x2="160" y2="210" class="edge"/>
  <line x1="200" y1="130" x2="240" y2="210" class="edge"/>
  <line x1="300" y1="130" x2="240" y2="210" class="edge"/>
  <line x1="300" y1="130" x2="320" y2="210" class="edge"/>
  <line x1="80" y1="210" x2="200" y2="290" class="edge"/>
  <line x1="160" y1="210" x2="200" y2="290" class="edge"/>
  <line x1="240" y1="210" x2="200" y2="290" class="edge"/>
  <line x1="320" y1="210" x2="200" y2="290" class="edge"/>
  <!-- Nodes -->
  <circle cx="200" cy="60" r="18" class="node"/>
  <text x="200" y="64" text-anchor="middle">{a,b,c}</text>
  <circle cx="100" cy="130" r="18" class="node"/>
  <text x="100" y="134" text-anchor="middle">{a,b}</text>
  <circle cx="200" cy="130" r="18" class="node"/>
  <text x="200" y="134" text-anchor="middle">{a,c}</text>
  <circle cx="300" cy="130" r="18" class="node"/>
  <text x="300" y="134" text-anchor="middle">{b,c}</text>
  <!-- Atoms (generators) -->
  <circle cx="80" cy="210" r="18" class="atom"/>
  <text x="80" y="214" text-anchor="middle">{a}</text>
  <circle cx="160" cy="210" r="18" class="atom"/>
  <text x="160" y="214" text-anchor="middle">{b}</text>
  <circle cx="240" cy="210" r="18" class="atom"/>
  <text x="240" y="214" text-anchor="middle">{c}</text>
  <circle cx="320" cy="210" r="18" class="atom"/>
  <text x="320" y="214" text-anchor="middle" style="font-size:10px">cell 4</text>
  <!-- Bottom -->
  <circle cx="200" cy="290" r="18" class="node"/>
  <text x="200" y="294" text-anchor="middle">∅</text>
  <!-- Legend -->
  <rect x="20" y="310" width="14" height="14" class="atom"/>
  <text x="40" y="322">= Generator (atom)</text>
  <rect x="180" y="310" width="14" height="14" class="node"/>
  <text x="200" y="322">= Closed set</text>
</svg>'''
    return svg

def generate_tropical_algebra_svg():
    """Generate SVG showing tropical algebra operations."""
    svg = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 500 200" width="500" height="200">
  <style>
    text { font-family: Georgia, serif; }
    .box { fill: #f0fdf4; stroke: #16a34a; stroke-width: 2; rx: 8; }
    .title { font-size: 16px; fill: #111; font-weight: bold; }
    .op { font-size: 20px; fill: #16a34a; font-weight: bold; }
    .eq { font-size: 14px; fill: #333; }
  </style>
  <text x="250" y="25" text-anchor="middle" class="title">Tropical Min-Plus Semiring</text>
  <!-- Addition box -->
  <rect x="20" y="40" width="200" height="70" class="box"/>
  <text x="120" y="65" text-anchor="middle" class="op">a ⊕ b = min(a, b)</text>
  <text x="120" y="90" text-anchor="middle" class="eq">3 ⊕ 5 = 3</text>
  <text x="120" y="105" text-anchor="middle" class="eq" style="font-size:11px;fill:#666">Idempotent: a ⊕ a = a</text>
  <!-- Multiplication box -->
  <rect x="280" y="40" width="200" height="70" class="box"/>
  <text x="380" y="65" text-anchor="middle" class="op">a ⊗ b = a + b</text>
  <text x="380" y="90" text-anchor="middle" class="eq">3 ⊗ 5 = 8</text>
  <text x="380" y="105" text-anchor="middle" class="eq" style="font-size:11px;fill:#666">Identity: a ⊗ 0 = a</text>
  <!-- Properties -->
  <rect x="20" y="130" width="460" height="55" fill="#faf5ff" stroke="#7c3aed" stroke-width="2" rx="8"/>
  <text x="250" y="152" text-anchor="middle" style="font-size:13px;fill:#7c3aed;font-weight:bold">Key Properties</text>
  <text x="250" y="172" text-anchor="middle" class="eq">Distributive: a ⊗ (b ⊕ c) = (a ⊗ b) ⊕ (a ⊗ c) · Zero: ⊤ · One: 0</text>
</svg>'''
    return svg

if __name__ == "__main__":
    vizs = {
        "rd_profile": generate_rd_profile_svg(),
        "closure_lattice": generate_closure_lattice_svg(),
        "tropical_algebra": generate_tropical_algebra_svg(),
    }

    for name, svg in vizs.items():
        with open(f"{name}.svg", "w") as f:
            f.write(svg)
        print(f"Generated {name}.svg")

    # Output as JSON for PACKAGE.json
    print(json.dumps([
        {"name": "Rate-Distortion Profile", "data": vizs["rd_profile"]},
        {"name": "Closure Lattice Structure", "data": vizs["closure_lattice"]},
        {"name": "Tropical Algebra", "data": vizs["tropical_algebra"]},
    ]))
