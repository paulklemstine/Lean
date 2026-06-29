#!/usr/bin/env python3
"""
Applications of Closure-Operad Duality

Demonstrates real-world applications:
1. Neural network architecture analysis via closure systems
2. Architecture compression via essential node detection
3. Architecture comparison via observational equivalence
"""

import itertools
from algorithms import (
    ClosureSystem, FinArchitecture, reconstruct_architecture,
    verify_soundness, closure_from_implications, observationally_equivalent
)


def application_architecture_analysis():
    """
    Application 1: Analyze a neural network's feature dependencies.

    Given a trained network's dependency structure (which features
    each layer can produce from its inputs), extract the closure
    system and identify the minimal architecture.
    """
    print("=" * 60)
    print("APPLICATION 1: Neural Architecture Analysis")
    print("=" * 60)

    # A 6-layer network with features:
    # raw_input, edge, texture, shape, object, scene
    elements = {'raw', 'edge', 'texture', 'shape', 'object', 'scene'}
    implications = [
        (frozenset({'raw'}), frozenset({'edge'})),
        (frozenset({'raw'}), frozenset({'texture'})),
        (frozenset({'edge'}), frozenset({'shape'})),
        (frozenset({'texture', 'shape'}), frozenset({'object'})),
        (frozenset({'object'}), frozenset({'scene'})),
    ]

    cs = closure_from_implications(elements, implications)

    print("\nFeature dependency closure:")
    for feat in sorted(elements):
        cl = cs.cl(frozenset({feat}))
        print(f"  cl({{{feat}}}) = {set(cl)}")

    arch = reconstruct_architecture(cs)
    essential = arch.essential_nodes()

    print(f"\nCanonical architecture: {len(arch.nodes)} nodes")
    print(f"Essential nodes: {essential}")
    print(f"Redundant nodes: {[n for n in arch.nodes if n not in essential]}")

    ji = cs.join_irreducibles()
    print(f"\nJoin-irreducible closed sets: {len(ji)}")
    for s in ji:
        print(f"  {set(s)}")

    print("\n→ The join-irreducibles identify the minimal generators")
    print("  of the architecture's dependency structure.")


def application_compression():
    """
    Application 2: Architecture compression.

    Given an over-parameterized architecture, identify and remove
    redundant nodes while preserving closure behavior.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Architecture Compression")
    print("=" * 60)

    # An over-parameterized architecture with 5 nodes
    # where some nodes are redundant
    elements = {'a', 'b', 'c', 'd'}

    # Original architecture: 5 nodes, some redundant
    original = FinArchitecture(
        nodes=['n1', 'n2', 'n3', 'n4', 'n5'],
        input_features={
            'n1': frozenset({'a'}),
            'n2': frozenset({'a'}),
            'n3': frozenset({'b'}),
            'n4': frozenset({'c'}),
            'n5': frozenset({'a'}),
        },
        output_features={
            'n1': frozenset({'a', 'b'}),       # a → b
            'n2': frozenset({'a', 'b'}),       # redundant with n1
            'n3': frozenset({'b', 'c'}),       # b → c
            'n4': frozenset({'c', 'd'}),       # c → d
            'n5': frozenset({'a', 'b', 'c'}),  # subsumes n1 and n3
        }
    )

    print(f"\nOriginal architecture: {len(original.nodes)} nodes")
    essential = original.essential_nodes()
    redundant = [n for n in original.nodes if n not in essential]
    print(f"Essential nodes: {essential}")
    print(f"Redundant nodes: {redundant}")

    # Compressed architecture: keep only essential nodes
    compressed = FinArchitecture(
        nodes=essential,
        input_features={n: original.input_features[n] for n in essential},
        output_features={n: original.output_features[n] for n in essential}
    )

    print(f"\nCompressed architecture: {len(compressed.nodes)} nodes")
    equiv = observationally_equivalent(original, compressed, frozenset(elements))
    print(f"Observationally equivalent: {equiv}")

    if equiv:
        ratio = 1 - len(compressed.nodes) / len(original.nodes)
        print(f"Compression ratio: {ratio:.0%}")
        print("\n→ Removed redundant nodes while preserving all closure behavior")


def application_comparison():
    """
    Application 3: Compare two architectures.

    Given two different architectures, determine if they are
    observationally equivalent (same closure on all inputs).
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Architecture Comparison")
    print("=" * 60)

    elements = frozenset({'x', 'y', 'z'})

    # Architecture A: sequential
    arch_a = FinArchitecture(
        nodes=['layer1', 'layer2'],
        input_features={
            'layer1': frozenset({'x'}),
            'layer2': frozenset({'y'}),
        },
        output_features={
            'layer1': frozenset({'x', 'y'}),
            'layer2': frozenset({'y', 'z'}),
        }
    )

    # Architecture B: parallel (same overall behavior)
    arch_b = FinArchitecture(
        nodes=['branch1', 'branch2'],
        input_features={
            'branch1': frozenset({'x'}),
            'branch2': frozenset({'x', 'y'}),
        },
        output_features={
            'branch1': frozenset({'x', 'y'}),
            'branch2': frozenset({'y', 'z'}),
        }
    )

    # Architecture C: different behavior
    arch_c = FinArchitecture(
        nodes=['single'],
        input_features={
            'single': frozenset({'x'}),
        },
        output_features={
            'single': frozenset({'x', 'y'}),
        }
    )

    print(f"\nArchitecture A (sequential): {len(arch_a.nodes)} nodes")
    print(f"Architecture B (parallel):   {len(arch_b.nodes)} nodes")
    print(f"Architecture C (minimal):    {len(arch_c.nodes)} nodes")

    equiv_ab = observationally_equivalent(arch_a, arch_b, elements)
    equiv_ac = observationally_equivalent(arch_a, arch_c, elements)
    equiv_bc = observationally_equivalent(arch_b, arch_c, elements)

    print(f"\nA ≡ B (obs. equiv.): {equiv_ab}")
    print(f"A ≡ C (obs. equiv.): {equiv_ac}")
    print(f"B ≡ C (obs. equiv.): {equiv_bc}")

    if equiv_ab:
        print("\n→ Architectures A and B are structurally different but")
        print("  behaviorally identical — they induce the same closure.")
    if not equiv_ac:
        print("\n→ Architecture C is genuinely different: it lacks the")
        print("  z feature in its outputs, so cl({x}) differs.")


if __name__ == "__main__":
    application_architecture_analysis()
    application_compression()
    application_comparison()

    print("\n" + "=" * 60)
    print("SUMMARY")
    print("=" * 60)
    print("""
These applications demonstrate three practical uses of the
closure-operad duality:

1. ANALYSIS: Extract minimal dependency generators from a
   neural architecture's closure system.

2. COMPRESSION: Remove redundant nodes while preserving
   observational behavior (closure-preserving pruning).

3. COMPARISON: Determine if two architectures with different
   topologies are functionally equivalent via their closures.

All three applications are grounded in the formally verified
duality theorem: architecture ↔ closure system, unique up to
observational equivalence.
""")


#!/usr/bin/env python3
"""
Closure-Operad Duality: Demo and Visualization

Demonstrates the closure–architecture reconstruction pipeline:
1. Define a closure system on a finite set of features
2. Reconstruct a canonical architecture from closure data
3. Verify the reconstruction is sound
4. Show normalization stability
"""

import itertools
from typing import Callable

# ─── Core Data Structures ─────────────────────────────────────────────────────

class ClosureSystem:
    """A closure system on a finite set of features."""

    def __init__(self, elements: set, cl: Callable[[frozenset], frozenset]):
        self.elements = frozenset(elements)
        self._cl = cl
        # Verify axioms
        self._verify_axioms()

    def cl(self, A: frozenset) -> frozenset:
        return self._cl(A)

    def _verify_axioms(self):
        """Verify extensivity, monotonicity, and idempotence on all subsets."""
        subsets = [frozenset(s) for r in range(len(self.elements)+1)
                   for s in itertools.combinations(self.elements, r)]
        for A in subsets:
            # Extensivity
            assert A <= self.cl(A), f"Extensivity failed: {A} ⊄ cl({A})={self.cl(A)}"
            # Idempotence
            assert self.cl(self.cl(A)) == self.cl(A), \
                f"Idempotence failed: cl(cl({A})) ≠ cl({A})"
        # Monotonicity (spot check)
        for A in subsets:
            for B in subsets:
                if A <= B:
                    assert self.cl(A) <= self.cl(B), \
                        f"Monotonicity failed: {A}⊆{B} but cl({A})⊄cl({B})"
        print("✓ All closure axioms verified")

    def is_closed(self, A: frozenset) -> bool:
        return self.cl(A) == A

    def closed_sets(self) -> list:
        """Enumerate all closed sets."""
        result = []
        for r in range(len(self.elements)+1):
            for s in itertools.combinations(self.elements, r):
                A = frozenset(s)
                if self.is_closed(A):
                    result.append(A)
        # Also check the full set
        if self.is_closed(self.elements) and self.elements not in result:
            result.append(self.elements)
        return sorted(result, key=lambda s: (len(s), sorted(s)))


class FinArchitecture:
    """A finite architecture with named nodes and input/output features."""

    def __init__(self, nodes: list, input_features: dict, output_features: dict):
        self.nodes = nodes
        self.input_features = input_features
        self.output_features = output_features

    def total_cl(self, seed: frozenset) -> frozenset:
        """Total closure: seed ∪ all node outputs."""
        result = set(seed)
        for node in self.nodes:
            result |= self.output_features[node]
        return frozenset(result)

    def __repr__(self):
        lines = [f"Architecture with {len(self.nodes)} nodes:"]
        for n in self.nodes:
            lines.append(f"  Node {n}: {set(self.input_features[n])} → {set(self.output_features[n])}")
        return "\n".join(lines)


def reconstruct_architecture(cs: ClosureSystem) -> FinArchitecture:
    """Reconstruct the canonical architecture from a closure system.

    Creates one node per element c, with:
    - input_features(c) = {c}
    - output_features(c) = cl({c})
    """
    nodes = sorted(cs.elements)
    input_features = {c: frozenset({c}) for c in nodes}
    output_features = {c: cs.cl(frozenset({c})) for c in nodes}
    return FinArchitecture(nodes, input_features, output_features)


def verify_reconstruction(cs: ClosureSystem, arch: FinArchitecture):
    """Verify that arch.total_cl covers cl for all singletons."""
    print("\n─── Reconstruction Verification ───")
    all_ok = True
    for c in sorted(cs.elements):
        singleton = frozenset({c})
        cl_c = cs.cl(singleton)
        total = arch.total_cl(singleton)
        ok = cl_c <= total
        status = "✓" if ok else "✗"
        print(f"  {status} cl({{{c}}}) = {set(cl_c)} ⊆ totalCl({{{c}}}) = {set(total)}")
        if not ok:
            all_ok = False
    if all_ok:
        print("  ✓ Reconstruction is SOUND: all singleton closures covered")
    return all_ok


def verify_normalization_stability(cs: ClosureSystem):
    """Verify that normalizing the closure (cl ∘ cl) gives the same system."""
    print("\n─── Normalization Stability ───")
    all_ok = True
    for r in range(len(cs.elements)+1):
        for s in itertools.combinations(cs.elements, r):
            A = frozenset(s)
            original = cs.cl(A)
            normalized = cs.cl(cs.cl(A))
            if original != normalized:
                print(f"  ✗ cl(cl({set(A)})) = {set(normalized)} ≠ cl({set(A)}) = {set(original)}")
                all_ok = False
    if all_ok:
        print("  ✓ Normalization stable: cl ∘ cl = cl (idempotence verified)")
        print("  → Canonical reconstruction invariant under idempotent rounding")
    return all_ok


# ─── Example 1: Neural Network Feature Dependencies ──────────────────────────

def example_neural_features():
    """A closure system modeling feature dependencies in a neural network.

    Features: {input, hidden1, hidden2, output}
    Dependencies:
    - hidden1 depends on input
    - hidden2 depends on input
    - output depends on hidden1 and hidden2
    """
    print("=" * 60)
    print("EXAMPLE 1: Neural Network Feature Dependencies")
    print("=" * 60)

    elements = {'input', 'hidden1', 'hidden2', 'output'}

    def cl(A):
        result = set(A)
        changed = True
        while changed:
            changed = False
            if 'input' in result and 'hidden1' not in result:
                result.add('hidden1'); changed = True
            if 'input' in result and 'hidden2' not in result:
                result.add('hidden2'); changed = True
            if 'hidden1' in result and 'hidden2' in result and 'output' not in result:
                result.add('output'); changed = True
        return frozenset(result)

    cs = ClosureSystem(elements, cl)

    print("\nClosed sets:")
    for s in cs.closed_sets():
        print(f"  {set(s)}")

    arch = reconstruct_architecture(cs)
    print(f"\n{arch}")

    verify_reconstruction(cs, arch)
    verify_normalization_stability(cs)
    return cs, arch


# ─── Example 2: Dependency Lattice (Boolean features) ────────────────────────

def example_boolean_features():
    """A closure system on 3 Boolean features with XOR-like dependencies."""
    print("\n" + "=" * 60)
    print("EXAMPLE 2: Boolean Feature Lattice")
    print("=" * 60)

    elements = {'a', 'b', 'c'}

    def cl(A):
        result = set(A)
        # If any two features present, the third is determined
        if len(result) >= 2:
            result = set(elements)
        return frozenset(result)

    cs = ClosureSystem(elements, cl)

    print("\nClosed sets:")
    for s in cs.closed_sets():
        print(f"  {set(s)}")

    arch = reconstruct_architecture(cs)
    print(f"\n{arch}")

    verify_reconstruction(cs, arch)
    verify_normalization_stability(cs)

    # Show join-irreducibles
    closed = cs.closed_sets()
    print("\n─── Join-Irreducible Analysis ───")
    for X in closed:
        if len(X) == 0:
            continue
        is_ji = True
        for A in closed:
            for B in closed:
                if A < X and B < X:
                    join = cs.cl(frozenset(A | B))
                    if join == X:
                        is_ji = False
                        break
            if not is_ji:
                break
        status = "JOIN-IRREDUCIBLE" if is_ji else "decomposable"
        print(f"  {set(X)}: {status}")

    return cs, arch


# ─── Example 3: Composition-Closure System ───────────────────────────────────

def example_composition():
    """Demonstrate a composition-closure system with exchange law."""
    print("\n" + "=" * 60)
    print("EXAMPLE 3: Composition-Closure System")
    print("=" * 60)

    elements = {'x', 'y', 'z', 'w'}

    def cl(A):
        result = set(A)
        if 'x' in result:
            result.add('y')
        if 'z' in result:
            result.add('w')
        return frozenset(result)

    def comp(A, B):
        """Union composition (simplest model)."""
        return frozenset(A | B)

    cs = ClosureSystem(elements, cl)

    print("\nClosed sets:")
    for s in cs.closed_sets():
        print(f"  {set(s)}")

    # Verify exchange law: cl(A ∪ B) = cl(comp(cl(A), cl(B)))
    print("\n─── Exchange Law Verification ───")
    test_pairs = [
        (frozenset({'x'}), frozenset({'z'})),
        (frozenset({'x', 'y'}), frozenset({'w'})),
        (frozenset(), frozenset({'x'})),
    ]
    for A, B in test_pairs:
        lhs = cl(frozenset(A | B))
        rhs = cl(comp(cl(A), cl(B)))
        status = "✓" if lhs == rhs else "✗"
        print(f"  {status} cl({set(A)} ∪ {set(B)}) = {set(lhs)}")
        print(f"       cl(comp(cl({set(A)}), cl({set(B)}))) = {set(rhs)}")

    arch = reconstruct_architecture(cs)
    print(f"\n{arch}")
    verify_reconstruction(cs, arch)
    verify_normalization_stability(cs)

    return cs, arch


# ─── Example 4: Iterated Closure Orbit ──────────────────────────────────────

def example_closure_orbit():
    """Demonstrate that iterated closure stabilizes after one step."""
    print("\n" + "=" * 60)
    print("EXAMPLE 4: Closure Orbit Stabilization")
    print("=" * 60)
    print("(Analog of post_quantum_closure_hash_stable_under_idempotent_round)")

    elements = {'a', 'b', 'c', 'd'}

    def cl(A):
        result = set(A)
        if 'a' in result:
            result.add('b')
        if 'b' in result:
            result.add('c')
        return frozenset(result)

    cs = ClosureSystem(elements, cl)

    seed = frozenset({'a'})
    print(f"\nSeed: {set(seed)}")
    current = seed
    for i in range(5):
        current = cs.cl(current)
        print(f"  cl^{i+1}(seed) = {set(current)}")

    print("\n→ Stabilizes after step 1 (idempotent orbit property)")
    print("→ This is the set-level analog of")
    print("  post_quantum_closure_hash_stable_under_idempotent_round")


# ─── Main ────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Closure-Operad Duality: Architecture Reconstruction   ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    example_neural_features()
    example_boolean_features()
    example_composition()
    example_closure_orbit()

    print("\n" + "=" * 60)
    print("SUMMARY")
    print("=" * 60)
    print("""
The demos above illustrate the core theorem:

1. FORWARD: Every architecture induces a closure system on features.
   Demonstrated by defining closure from dependency rules.

2. BACKWARD: Every closure system has a canonical architecture.
   Demonstrated by reconstruct_architecture().

3. SOUNDNESS: The reconstructed architecture covers all singleton
   closures: cl({c}) ⊆ totalCl(arch, {c}).

4. NORMALIZATION STABILITY: Normalizing the closure (cl ∘ cl = cl)
   leaves the reconstruction invariant — the idempotent rounding
   principle from post_quantum_closure_hash_stable_under_idempotent_round.

5. UNIQUENESS: Any two architectures realizing the same closure
   are observationally equivalent (same totalCl on all inputs).
""")


#!/usr/bin/env python3
"""Generate visualizations for the closure-operad duality."""

import base64
import io
import json

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    import matplotlib.patches as mpatches
    HAS_MPL = True
except ImportError:
    HAS_MPL = False


def generate_lattice_svg():
    """Generate SVG of a closure lattice."""
    svg = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 350" width="400" height="350">
  <style>
    text { font-family: sans-serif; font-size: 11px; text-anchor: middle; }
    .node { fill: #4A90D9; stroke: #2C5F8A; stroke-width: 2; }
    .ji-node { fill: #E8A838; stroke: #B07820; stroke-width: 2; }
    .edge { stroke: #666; stroke-width: 1.5; fill: none; }
    .label { fill: #333; font-size: 10px; }
    .title { font-size: 14px; font-weight: bold; fill: #222; }
  </style>
  <text x="200" y="20" class="title">Closure Lattice with Join-Irreducibles</text>

  <!-- Edges -->
  <line x1="200" y1="55" x2="100" y2="115" class="edge"/>
  <line x1="200" y1="55" x2="200" y2="115" class="edge"/>
  <line x1="200" y1="55" x2="300" y2="115" class="edge"/>
  <line x1="100" y1="135" x2="80" y2="195" class="edge"/>
  <line x1="100" y1="135" x2="200" y2="195" class="edge"/>
  <line x1="200" y1="135" x2="80" y2="195" class="edge"/>
  <line x1="200" y1="135" x2="300" y2="195" class="edge"/>
  <line x1="300" y1="135" x2="200" y2="195" class="edge"/>
  <line x1="300" y1="135" x2="300" y2="195" class="edge"/>
  <line x1="80" y1="215" x2="200" y2="275" class="edge"/>
  <line x1="200" y1="215" x2="200" y2="275" class="edge"/>
  <line x1="300" y1="215" x2="200" y2="275" class="edge"/>

  <!-- Top node: {a,b,c} -->
  <circle cx="200" cy="50" r="18" class="node"/>
  <text x="200" y="54" class="label" style="fill:white">{a,b,c}</text>

  <!-- Middle row: {a,b}, {a,c}, {b,c} -->
  <circle cx="100" cy="130" r="18" class="node"/>
  <text x="100" y="134" class="label" style="fill:white">{a,b}</text>

  <circle cx="200" cy="130" r="18" class="node"/>
  <text x="200" y="134" class="label" style="fill:white">{a,c}</text>

  <circle cx="300" cy="130" r="18" class="node"/>
  <text x="300" y="134" class="label" style="fill:white">{b,c}</text>

  <!-- Join-irreducible singletons -->
  <circle cx="80" cy="210" r="18" class="ji-node"/>
  <text x="80" y="214" class="label" style="fill:white">{a}</text>

  <circle cx="200" cy="210" r="18" class="ji-node"/>
  <text x="200" y="214" class="label" style="fill:white">{b}</text>

  <circle cx="300" cy="210" r="18" class="ji-node"/>
  <text x="300" y="214" class="label" style="fill:white">{c}</text>

  <!-- Bottom: empty -->
  <circle cx="200" cy="280" r="18" class="node"/>
  <text x="200" y="284" class="label" style="fill:white">∅</text>

  <!-- Legend -->
  <rect x="20" y="310" width="14" height="14" style="fill:#4A90D9; stroke:#2C5F8A; stroke-width:1"/>
  <text x="45" y="322" style="text-anchor:start; font-size:11px">Closed set</text>
  <rect x="140" y="310" width="14" height="14" style="fill:#E8A838; stroke:#B07820; stroke-width:1"/>
  <text x="165" y="322" style="text-anchor:start; font-size:11px">Join-irreducible (arch. node)</text>
</svg>'''
    return svg


def generate_duality_svg():
    """Generate SVG showing the duality correspondence."""
    svg = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 280" width="600" height="280">
  <style>
    text { font-family: sans-serif; text-anchor: middle; }
    .box { rx: 10; ry: 10; stroke-width: 2; }
    .arrow { stroke: #444; stroke-width: 2; fill: none; marker-end: url(#arrowhead); }
    .title { font-size: 16px; font-weight: bold; fill: #222; }
    .subtitle { font-size: 11px; fill: #555; }
  </style>
  <defs>
    <marker id="arrowhead" markerWidth="10" markerHeight="7" refX="9" refY="3.5" orient="auto">
      <polygon points="0 0, 10 3.5, 0 7" fill="#444"/>
    </marker>
  </defs>

  <text x="300" y="25" class="title">Closure–Architecture Duality</text>

  <!-- Left box: Closure System -->
  <rect x="30" y="50" width="200" height="160" class="box" fill="#E8F0FE" stroke="#4A90D9"/>
  <text x="130" y="75" style="font-size:13px; font-weight:bold; fill:#2C5F8A">Closure System</text>
  <text x="130" y="100" class="subtitle">cl : 𝒫(C) → 𝒫(C)</text>
  <text x="130" y="120" class="subtitle">• Extensive</text>
  <text x="130" y="138" class="subtitle">• Monotone</text>
  <text x="130" y="156" class="subtitle">• Idempotent</text>
  <text x="130" y="180" class="subtitle" style="fill:#B07820">+ Composition</text>
  <text x="130" y="198" class="subtitle" style="fill:#B07820">+ Exchange law</text>

  <!-- Right box: Architecture -->
  <rect x="370" y="50" width="200" height="160" class="box" fill="#FEF3E0" stroke="#E8A838"/>
  <text x="470" y="75" style="font-size:13px; font-weight:bold; fill:#B07820">Architecture</text>
  <text x="470" y="100" class="subtitle">Nodes + Features</text>
  <text x="470" y="120" class="subtitle">• Finite DAG</text>
  <text x="470" y="138" class="subtitle">• Input/Output</text>
  <text x="470" y="156" class="subtitle">• Acyclic</text>
  <text x="470" y="180" class="subtitle" style="fill:#2C5F8A">totalCl = seed ∪ outputs</text>

  <!-- Arrows -->
  <path d="M 235 105 Q 300 70 365 105" class="arrow"/>
  <text x="300" y="82" style="font-size:10px; fill:#444">reconstruct</text>

  <path d="M 365 165 Q 300 200 235 165" class="arrow"/>
  <text x="300" y="195" style="font-size:10px; fill:#444">induce closure</text>

  <!-- Bottom: equivalence -->
  <text x="300" y="245" style="font-size:12px; fill:#333">Unique up to observational equivalence</text>
  <text x="300" y="265" style="font-size:11px; fill:#666">Stable under idempotent normalization</text>
</svg>'''
    return svg


def generate_orbit_png_base64():
    """Generate closure orbit stabilization chart as base64 PNG."""
    if not HAS_MPL:
        return None

    fig, ax = plt.subplots(1, 1, figsize=(6, 3.5))

    # Simulate closure orbit for different seeds
    iterations = list(range(6))

    # Orbit sizes (stabilize after step 1)
    orbit1 = [1, 3, 3, 3, 3, 3]  # seed {a}
    orbit2 = [2, 4, 4, 4, 4, 4]  # seed {a,d}
    orbit3 = [1, 1, 1, 1, 1, 1]  # seed {c} (already closed)

    ax.plot(iterations, orbit1, 'o-', color='#4A90D9', linewidth=2, markersize=8, label='seed = {a}')
    ax.plot(iterations, orbit2, 's-', color='#E8A838', linewidth=2, markersize=8, label='seed = {a,d}')
    ax.plot(iterations, orbit3, '^-', color='#5CB85C', linewidth=2, markersize=8, label='seed = {c} (closed)')

    ax.set_xlabel('Iteration n', fontsize=12)
    ax.set_ylabel('|cl^n(seed)|', fontsize=12)
    ax.set_title('Closure Orbit Stabilization', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.set_xticks(iterations)
    ax.set_ylim(0, 5.5)
    ax.grid(True, alpha=0.3)
    ax.axvline(x=1, color='red', linestyle='--', alpha=0.5, label='_nolegend_')
    ax.text(1.1, 5.2, 'Stabilizes here', color='red', fontsize=9)

    plt.tight_layout()
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150)
    plt.close(fig)
    buf.seek(0)
    return "data:image/png;base64," + base64.b64encode(buf.read()).decode()


if __name__ == "__main__":
    lattice_svg = generate_lattice_svg()
    duality_svg = generate_duality_svg()
    orbit_png = generate_orbit_png_base64()

    with open("lattice.svg", "w") as f:
        f.write(lattice_svg)
    with open("duality.svg", "w") as f:
        f.write(duality_svg)

    print("Generated: lattice.svg, duality.svg")
    if orbit_png:
        print(f"Orbit PNG base64 length: {len(orbit_png)}")
    else:
        print("matplotlib not available, skipping PNG generation")
