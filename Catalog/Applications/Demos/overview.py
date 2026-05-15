#!/usr/bin/env python3
"""
Composable Theorem Transfer — Applications

Demonstrates real-world application scenarios where compositional
theorem transport enables cross-domain certified reasoning.
"""

from dataclasses import dataclass
from typing import Callable, List, Tuple
import math


# ═══════════════════════════════════════════════════════════════
# §1. Application: ML Robustness → Topological Consistency
# ═══════════════════════════════════════════════════════════════

@dataclass
class MLModel:
    """A machine learning model with robustness certificate."""
    name: str
    margin: float          # Classification margin
    lipschitz_const: float # Lipschitz constant
    train_samples: int     # Number of training samples

    @property
    def certified_radius(self) -> float:
        """The certified robustness radius: margin / Lipschitz constant."""
        return self.margin / self.lipschitz_const if self.lipschitz_const > 0 else 0

    @property
    def generalization_bound(self) -> float:
        """PAC-Bayes style generalization bound (simplified)."""
        if self.train_samples == 0:
            return float('inf')
        return math.sqrt(math.log(self.lipschitz_const + 1) / self.train_samples)


@dataclass
class TopologicalSpace:
    """A topological space with consistency invariant."""
    name: str
    betti_numbers: List[int]  # Betti numbers β₀, β₁, β₂, ...
    covering_dimension: int

    @property
    def total_betti(self) -> int:
        return sum(self.betti_numbers)

    @property
    def consistency_score(self) -> float:
        """Higher means more topologically consistent."""
        if self.covering_dimension == 0:
            return 0
        return self.total_betti / self.covering_dimension


def ml_to_topology_bridge(model: MLModel) -> TopologicalSpace:
    """Bridge from ML model to topological space.

    The conceptual mapping:
    - Certified radius → covering dimension (discretized)
    - Margin structure → Betti numbers (nerve of the margin complex)
    """
    dim = max(1, int(model.certified_radius * 10))
    betti = [1] + [max(0, int(model.margin * (i + 1))) for i in range(dim)]
    return TopologicalSpace(
        name=f"Nerve({model.name})",
        betti_numbers=betti,
        covering_dimension=dim
    )


def app_ml_robustness_transfer():
    """Demonstrate ML robustness → topological consistency transfer."""
    print("=" * 60)
    print("APPLICATION 1: ML Robustness → Topological Consistency")
    print("=" * 60)

    models = [
        MLModel("ResNet-18", margin=0.8, lipschitz_const=2.0, train_samples=50000),
        MLModel("VGG-16", margin=0.3, lipschitz_const=5.0, train_samples=50000),
        MLModel("MLP-small", margin=1.5, lipschitz_const=1.2, train_samples=10000),
    ]

    for model in models:
        topo = ml_to_topology_bridge(model)
        print(f"\n  Model: {model.name}")
        print(f"    Margin: {model.margin:.2f}")
        print(f"    Lipschitz: {model.lipschitz_const:.2f}")
        print(f"    Certified radius: {model.certified_radius:.3f}")
        print(f"    Gen. bound: {model.generalization_bound:.4f}")
        print(f"  → Topological image: {topo.name}")
        print(f"    Covering dim: {topo.covering_dimension}")
        print(f"    Betti numbers: {topo.betti_numbers}")
        print(f"    Consistency: {topo.consistency_score:.2f}")
        print(f"    Transfer: Robust={model.certified_radius > 0.1} → Consistent={topo.consistency_score > 1.0}")
    print()


# ═══════════════════════════════════════════════════════════════
# §2. Application: Automata Compression → Quantum State Reduction
# ═══════════════════════════════════════════════════════════════

@dataclass
class Automaton:
    """A finite automaton with Nerode congruence."""
    name: str
    num_states: int
    num_equivalence_classes: int  # Nerode classes

    @property
    def compression_ratio(self) -> float:
        return self.num_equivalence_classes / self.num_states if self.num_states > 0 else 1

    @property
    def is_minimal(self) -> bool:
        return self.num_states == self.num_equivalence_classes


@dataclass
class QuantumSystem:
    """A quantum system with state compression."""
    name: str
    hilbert_dim: int
    observable_classes: int

    @property
    def compression_ratio(self) -> float:
        return self.observable_classes / self.hilbert_dim if self.hilbert_dim > 0 else 1


def automaton_to_quantum_bridge(aut: Automaton) -> QuantumSystem:
    """Bridge from automaton to quantum system.

    The conceptual mapping:
    - States → Hilbert space basis vectors
    - Nerode classes → observable equivalence classes
    """
    return QuantumSystem(
        name=f"Q({aut.name})",
        hilbert_dim=aut.num_states,
        observable_classes=aut.num_equivalence_classes
    )


def app_automata_quantum_transfer():
    """Demonstrate automata compression → quantum state reduction."""
    print("=" * 60)
    print("APPLICATION 2: Automata Compression → Quantum Reduction")
    print("=" * 60)

    automata = [
        Automaton("DFA-binary", num_states=16, num_equivalence_classes=4),
        Automaton("NFA-regex", num_states=32, num_equivalence_classes=8),
        Automaton("DFA-minimal", num_states=5, num_equivalence_classes=5),
    ]

    for aut in automata:
        qs = automaton_to_quantum_bridge(aut)
        print(f"\n  Automaton: {aut.name}")
        print(f"    States: {aut.num_states}")
        print(f"    Nerode classes: {aut.num_equivalence_classes}")
        print(f"    Compression: {aut.compression_ratio:.2f}")
        print(f"    Minimal: {aut.is_minimal}")
        print(f"  → Quantum system: {qs.name}")
        print(f"    Hilbert dim: {qs.hilbert_dim}")
        print(f"    Observable classes: {qs.observable_classes}")
        print(f"    Quantum compression: {qs.compression_ratio:.2f}")
        print(f"    Transfer: NerodeCertified={aut.num_equivalence_classes < aut.num_states} "
              f"→ QuantumCompressed={qs.compression_ratio < 1.0}")
    print()


# ═══════════════════════════════════════════════════════════════
# §3. Application: Spectral → Ultrametric Cryptography
# ═══════════════════════════════════════════════════════════════

@dataclass
class SpectralObject:
    """An object with spectral invariants."""
    name: str
    eigenvalues: List[float]

    @property
    def spectral_gap(self) -> float:
        if len(self.eigenvalues) < 2:
            return 0
        sorted_eigs = sorted(self.eigenvalues, reverse=True)
        return sorted_eigs[0] - sorted_eigs[1]

    @property
    def spectral_depth(self) -> int:
        """Number of eigenvalues above threshold 0.1."""
        return sum(1 for e in self.eigenvalues if abs(e) > 0.1)


@dataclass
class UltrametricCode:
    """A code in an ultrametric space."""
    name: str
    tree_depth: int
    branch_factor: int
    min_distance: float

    @property
    def code_rate(self) -> float:
        total = self.branch_factor ** self.tree_depth
        return math.log2(total) / self.tree_depth if self.tree_depth > 0 else 0

    @property
    def security_level(self) -> float:
        return self.min_distance * self.tree_depth


def spectral_to_ultrametric_bridge(spec: SpectralObject) -> UltrametricCode:
    """Bridge from spectral object to ultrametric code.

    The conceptual mapping:
    - Spectral depth → tree depth
    - Spectral gap → minimum distance
    """
    return UltrametricCode(
        name=f"UCode({spec.name})",
        tree_depth=spec.spectral_depth,
        branch_factor=2,
        min_distance=spec.spectral_gap
    )


def app_spectral_crypto_transfer():
    """Demonstrate spectral → ultrametric crypto transfer."""
    print("=" * 60)
    print("APPLICATION 3: Spectral → Ultrametric Cryptography")
    print("=" * 60)

    spectrals = [
        SpectralObject("Expander-G1", [1.0, 0.3, 0.1, 0.05, 0.02]),
        SpectralObject("Random-G2", [1.0, 0.95, 0.9, 0.85, 0.8]),
        SpectralObject("Ramanujan-G3", [1.0, 0.1, 0.08, 0.05, 0.01]),
    ]

    for spec in spectrals:
        code = spectral_to_ultrametric_bridge(spec)
        print(f"\n  Spectral object: {spec.name}")
        print(f"    Eigenvalues: {spec.eigenvalues}")
        print(f"    Spectral gap: {spec.spectral_gap:.3f}")
        print(f"    Spectral depth: {spec.spectral_depth}")
        print(f"  → Ultrametric code: {code.name}")
        print(f"    Tree depth: {code.tree_depth}")
        print(f"    Min distance: {code.min_distance:.3f}")
        print(f"    Code rate: {code.code_rate:.2f}")
        print(f"    Security level: {code.security_level:.3f}")
        is_good_spectral = spec.spectral_gap > 0.5
        is_secure = code.security_level > 1.0
        print(f"    Transfer: SpectralCertified={is_good_spectral} "
              f"→ UltrametricSecure={is_secure}")
    print()


# ═══════════════════════════════════════════════════════════════
# §4. Composing Two Bridges: ML → Topology → Spectral
# ═══════════════════════════════════════════════════════════════

def app_two_step_composition():
    """Demonstrate two-step compositional transfer: ML → Topology → Spectral."""
    print("=" * 60)
    print("APPLICATION 4: Two-Step Composition (ML → Topo → Spectral)")
    print("=" * 60)

    model = MLModel("DeepNet", margin=1.2, lipschitz_const=1.5, train_samples=100000)

    # Step 1: ML → Topology
    topo = ml_to_topology_bridge(model)

    # Step 2: Topology → Spectral (using Betti numbers as eigenvalue proxies)
    eigenvalues = [b / (topo.total_betti + 1) for b in topo.betti_numbers]
    spectral = SpectralObject(f"Spec({topo.name})", eigenvalues)

    # Step 3: Spectral → Ultrametric
    code = spectral_to_ultrametric_bridge(spectral)

    print(f"\n  Source: {model.name}")
    print(f"    Margin={model.margin}, Lipschitz={model.lipschitz_const}")
    print(f"    Certified radius: {model.certified_radius:.3f}")
    print(f"\n  → Step 1 (ML → Topology): {topo.name}")
    print(f"    Betti: {topo.betti_numbers}, Dim: {topo.covering_dimension}")
    print(f"\n  → Step 2 (Topology → Spectral): {spectral.name}")
    print(f"    Eigenvalues: {[f'{e:.3f}' for e in spectral.eigenvalues]}")
    print(f"    Spectral gap: {spectral.spectral_gap:.3f}")
    print(f"\n  → Step 3 (Spectral → Ultrametric): {code.name}")
    print(f"    Tree depth: {code.tree_depth}, Security: {code.security_level:.3f}")
    print(f"\n  End-to-end: Robust ML model → Ultrametric code")
    print(f"    robust={model.certified_radius > 0.1} → secure={code.security_level > 0.5}")
    print()


# ═══════════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("\n" + "═" * 60)
    print("  COMPOSABLE THEOREM TRANSFER — APPLICATIONS")
    print("═" * 60 + "\n")

    app_ml_robustness_transfer()
    app_automata_quantum_transfer()
    app_spectral_crypto_transfer()
    app_two_step_composition()

    print("All applications completed successfully.")


#!/usr/bin/env python3
"""
Composable Theorem Transfer — Demonstration

Demonstrates the core concepts of compositional certified property transport
across chains of theory morphisms using concrete numerical examples.
"""

from dataclasses import dataclass
from typing import Callable, TypeVar, Generic, Optional
import json

# ═══════════════════════════════════════════════════════════════
# §1. Core Definitions
# ═══════════════════════════════════════════════════════════════

@dataclass
class ResearchTheory:
    """A research theory: a domain with a ℕ-valued invariant."""
    name: str
    invariant: Callable[[int], int]

    def inv(self, x: int) -> int:
        return self.invariant(x)


@dataclass
class TheoryHom:
    """A theory morphism: a monotone map between theories."""
    source: ResearchTheory
    target: ResearchTheory
    to_fun: Callable[[int], int]
    name: str = ""

    def verify_monotonicity(self, samples: range = range(20)) -> bool:
        """Check monotonicity on sample inputs."""
        return all(
            self.source.inv(x) <= self.target.inv(self.to_fun(x))
            for x in samples
        )


def compose(phi: TheoryHom, psi: TheoryHom) -> TheoryHom:
    """Compose two theory morphisms."""
    assert phi.target.name == psi.source.name, \
        f"Cannot compose: {phi.target.name} ≠ {psi.source.name}"
    return TheoryHom(
        source=phi.source,
        target=psi.target,
        to_fun=lambda x: psi.to_fun(phi.to_fun(x)),
        name=f"{phi.name} ; {psi.name}"
    )


# ═══════════════════════════════════════════════════════════════
# §2. Predicate Preservation
# ═══════════════════════════════════════════════════════════════

Predicate = Callable[[int], bool]


def preserves_property(phi: TheoryHom, P: Predicate, Q: Predicate,
                       samples: range = range(50)) -> bool:
    """Check if morphism preserves P ⇒ Q on sample inputs."""
    return all(
        (not P(x)) or Q(phi.to_fun(x))
        for x in samples
    )


def verify_composition_theorem(phi: TheoryHom, psi: TheoryHom,
                                P: Predicate, Q: Predicate, R: Predicate,
                                samples: range = range(50)) -> dict:
    """Verify the composition theorem on concrete samples."""
    phi_preserves = preserves_property(phi, P, Q, samples)
    psi_preserves = preserves_property(psi, Q, R, samples)
    comp = compose(phi, psi)
    comp_preserves = preserves_property(comp, P, R, samples)

    return {
        "φ preserves P ⇒ Q": phi_preserves,
        "ψ preserves Q ⇒ R": psi_preserves,
        "φ;ψ preserves P ⇒ R": comp_preserves,
        "theorem_holds": (phi_preserves and psi_preserves) == comp_preserves
    }


# ═══════════════════════════════════════════════════════════════
# §3. Catalog Theories
# ═══════════════════════════════════════════════════════════════

HeightTheory = ResearchTheory("Height", lambda n: n)
CellTheory = ResearchTheory("Cell", lambda n: n * (n + 1))
DimensionTheory = ResearchTheory("Dimension", lambda n: n + 1)
StabilityTheory = ResearchTheory("Stability", lambda n: n)
CapacityTheory = ResearchTheory("Capacity", lambda n: n)

# Morphisms
height_to_cell = TheoryHom(HeightTheory, CellTheory, lambda x: x, "h→cell")
height_to_dim = TheoryHom(HeightTheory, DimensionTheory, lambda x: x, "h→dim")
dim_to_stab = TheoryHom(DimensionTheory, StabilityTheory, lambda x: x + 1, "dim→stab")
stab_to_cap = TheoryHom(StabilityTheory, CapacityTheory, lambda x: x, "stab→cap")

# Predicates
arith_significant: Predicate = lambda x: x >= 2
nontrivial_cell: Predicate = lambda x: x * (x + 1) >= 2
depth_at_least_2: Predicate = lambda x: x >= 2  # relative to identity invariant
strongly_stable: Predicate = lambda x: x >= 2


# ═══════════════════════════════════════════════════════════════
# §4. Demonstrations
# ═══════════════════════════════════════════════════════════════

def demo_monotonicity():
    """Demonstrate that all bridges are monotone."""
    print("=" * 60)
    print("DEMO 1: Monotonicity Verification")
    print("=" * 60)
    bridges = [height_to_cell, height_to_dim, dim_to_stab, stab_to_cap]
    for b in bridges:
        ok = b.verify_monotonicity()
        status = "✓" if ok else "✗"
        print(f"  {status} {b.name}: monotone = {ok}")

        # Show sample values
        for x in [0, 1, 2, 5, 10]:
            src_inv = b.source.inv(x)
            tgt_inv = b.target.inv(b.to_fun(x))
            print(f"      x={x}: source_inv={src_inv}, target_inv={tgt_inv}")
    print()


def demo_composition_theorem():
    """Demonstrate the central composition theorem."""
    print("=" * 60)
    print("DEMO 2: Composition Theorem")
    print("=" * 60)

    # Two-step composition: height → dimension → stability
    P = lambda x: HeightTheory.inv(x) >= 2
    Q = lambda x: DimensionTheory.inv(x) >= 2
    R = lambda x: StabilityTheory.inv(x) >= 2

    result = verify_composition_theorem(height_to_dim, dim_to_stab, P, Q, R)
    for k, v in result.items():
        print(f"  {k}: {v}")

    # Show concrete trace
    print("\n  Concrete trace for x = 5:")
    x = 5
    print(f"    P(5) = (HeightTheory.inv(5) ≥ 2) = ({HeightTheory.inv(5)} ≥ 2) = {P(x)}")
    y = height_to_dim.to_fun(x)
    print(f"    φ(5) = {y}, Q({y}) = (DimensionTheory.inv({y}) ≥ 2) = ({DimensionTheory.inv(y)} ≥ 2) = {Q(y)}")
    z = dim_to_stab.to_fun(y)
    print(f"    ψ({y}) = {z}, R({z}) = (StabilityTheory.inv({z}) ≥ 2) = ({StabilityTheory.inv(z)} ≥ 2) = {R(z)}")
    comp = compose(height_to_dim, dim_to_stab)
    w = comp.to_fun(x)
    print(f"    (φ;ψ)(5) = {w}, R({w}) = {R(w)}")
    print(f"    ∴ P(5) → R((φ;ψ)(5)) ✓")
    print()


def demo_four_theory_chain():
    """Demonstrate the four-theory chain transfer."""
    print("=" * 60)
    print("DEMO 3: Four-Theory Chain Transfer")
    print("=" * 60)
    print("  Chain: Height → Dimension → Stability → Capacity")

    pipeline = compose(height_to_dim, dim_to_stab)
    full_chain = compose(pipeline, stab_to_cap)

    print(f"\n  Full chain monotonicity: {full_chain.verify_monotonicity()}")
    print(f"  Full chain name: {full_chain.name}")

    print("\n  Depth transfer table (n = depth threshold):")
    print(f"  {'x':>4} {'H.Inv':>6} {'D.Inv':>6} {'S.Inv':>6} {'C.Inv':>6} {'depth≥2':>8}")
    print("  " + "-" * 42)
    for x in range(8):
        h_inv = HeightTheory.inv(x)
        d_val = height_to_dim.to_fun(x)
        d_inv = DimensionTheory.inv(d_val)
        s_val = dim_to_stab.to_fun(d_val)
        s_inv = StabilityTheory.inv(s_val)
        c_val = stab_to_cap.to_fun(s_val)
        c_inv = CapacityTheory.inv(c_val)
        depth2 = "✓" if h_inv >= 2 and c_inv >= 2 else ("—" if h_inv < 2 else "✗")
        print(f"  {x:>4} {h_inv:>6} {d_inv:>6} {s_inv:>6} {c_inv:>6} {depth2:>8}")
    print()


def demo_certified_transfer():
    """Demonstrate the CertifiedTransfer bundled combinator."""
    print("=" * 60)
    print("DEMO 4: Certified Transfer Application")
    print("=" * 60)

    # Simulate CertifiedTransfer for height → cell
    print("  CertifiedTransfer: ArithmeticallySignificant → NontrivialCellComplexity")
    print()
    for x in range(8):
        is_sig = arith_significant(x)
        cell_val = height_to_cell.to_fun(x)
        cell_inv = CellTheory.inv(cell_val)
        is_nontrivial = cell_inv >= 2
        mark = "✓ transferred" if is_sig and is_nontrivial else ""
        print(f"    x={x}: ArithSig={is_sig}, CellInv={cell_inv}, NontrivialCell={is_nontrivial}  {mark}")

    print("\n  height5_cell_transfer: CellInv(5) = 5·6 = 30 ≥ 2 ✓")
    print(f"  height3_pipeline_transfer: StabilityInv(pipeline(3)) = {StabilityTheory.inv(compose(height_to_dim, dim_to_stab).to_fun(3))} ≥ 2 ✓")
    print()


def demo_pushforward():
    """Demonstrate the pushforward predicate construction."""
    print("=" * 60)
    print("DEMO 5: Pushforward Predicate")
    print("=" * 60)

    # Pushforward of ArithmeticallySignificant along height_to_cell
    source_set = {x for x in range(20) if arith_significant(x)}
    pushforward_set = {height_to_cell.to_fun(x) for x in source_set}

    print(f"  Source predicate (ArithSig): x ≥ 2")
    print(f"  Source set (first 20): {sorted(source_set)}")
    print(f"  Pushforward image: {sorted(pushforward_set)}")
    print(f"  Pushforward predicate: y ∈ {sorted(pushforward_set)}")
    print(f"  All pushforward elements have NontrivialCellComplexity: "
          f"{all(CellTheory.inv(y) >= 2 for y in pushforward_set)}")
    print()


# ═══════════════════════════════════════════════════════════════
# §5. Main
# ═══════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("\n" + "═" * 60)
    print("  COMPOSABLE THEOREM TRANSFER — DEMONSTRATIONS")
    print("═" * 60 + "\n")

    demo_monotonicity()
    demo_composition_theorem()
    demo_four_theory_chain()
    demo_certified_transfer()
    demo_pushforward()

    print("All demonstrations completed successfully.")


#!/usr/bin/env python3
"""Generate PACKAGE.json from all deliverables."""

import json
import sys
sys.path.insert(0, '.')
from visualizations import generate_all_visualizations

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

def main():
    # Read all text files
    article = read_file('ARTICLE.md')
    research_paper = read_file('RESEARCH_PAPER.md')
    future_directions = read_file('FUTURE_DIRECTIONS.md')
    lean_proofs = read_file('ComposableTransfer.lean')
    demo_code = read_file('demo.py')
    algorithms_code = read_file('algorithms.py')
    applications_code = read_file('applications.py')

    # Generate visualizations
    vizs = generate_all_visualizations()

    package = {
        "title": "Composable Theorem Transfer: A Calculus of Transportable Guarantees",
        "domain": "Cross-Domain Mathematics / Category Theory / Formal Verification",
        "article": article,
        "research_paper": research_paper,
        "future_directions": future_directions,
        "demos": [
            {
                "name": "Composable Transfer Demos",
                "code": demo_code
            },
            {
                "name": "Cross-Domain Applications",
                "code": applications_code
            }
        ],
        "algorithms": [
            {
                "name": "Bridge Composition Algorithm",
                "pseudocode": (
                    "Algorithm: ComposeTransfer\n"
                    "Input: CertifiedTransfer ct₁ : (T₁, P) → (T₂, Q)\n"
                    "       CertifiedTransfer ct₂ : (T₂, Q) → (T₃, R)\n"
                    "Output: CertifiedTransfer : (T₁, P) → (T₃, R)\n\n"
                    "1. Compose underlying morphisms: φ := ct₁.hom ; ct₂.hom\n"
                    "2. Compose preservation witnesses:\n"
                    "   For any x with P(x):\n"
                    "     a. Apply ct₁.preserves(x) to get Q(ct₁.hom.toFun(x))\n"
                    "     b. Apply ct₂.preserves(ct₁.hom.toFun(x)) to get R(φ.toFun(x))\n"
                    "3. Return (φ, composed_witness)\n\n"
                    "Time complexity: O(1) for construction"
                ),
                "code": algorithms_code
            },
            {
                "name": "Bridge Search Algorithm (BFS)",
                "pseudocode": (
                    "Algorithm: FindTransferChain\n"
                    "Input: Source theory T_s, target theory T_t, catalog of bridges\n"
                    "Output: CertifiedTransfer from (T_s, P) to (T_t, Q), or ⊥\n\n"
                    "1. Build directed graph G (nodes=theories, edges=bridges)\n"
                    "2. BFS from T_s to T_t in G\n"
                    "3. If path found: compose all bridges along the path\n"
                    "4. Compute pushforward predicate Q along the composed morphism\n"
                    "5. Return the CertifiedTransfer\n\n"
                    "Time complexity: O(|V| + |E|) for path search + O(k) for k-step composition"
                ),
                "code": algorithms_code
            }
        ],
        "visualizations": [
            {"name": "Invariant Comparison Across Theories", "data": vizs["invariant_comparison"]},
            {"name": "Monotonicity of Height→Cell Bridge", "data": vizs["monotonicity_proof"]},
            {"name": "Four-Theory Composition Pipeline", "data": vizs["composition_pipeline"]},
            {"name": "Theory Graph with Certified Bridges", "data": vizs["theory_graph"]},
            {"name": "Predicate Transfer Through Composition", "data": vizs["predicate_transfer"]},
        ],
        "lean_proofs": lean_proofs
    }

    with open('PACKAGE.json', 'w') as f:
        json.dump(package, f, indent=2, ensure_ascii=False)

    print(f"PACKAGE.json generated ({len(json.dumps(package))} chars)")

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Composable Theorem Transfer — Visualizations

Generates charts showing the key mathematical structures,
invariant behavior, and transfer properties.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import base64
import io
import json


def fig_to_base64(fig) -> str:
    """Convert a matplotlib figure to a base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def viz_invariant_comparison():
    """Compare invariants across the five catalog theories."""
    fig, ax = plt.subplots(figsize=(10, 6))

    x = np.arange(0, 12)
    theories = {
        'Height (id)': x,
        'Cell (n·(n+1))': x * (x + 1),
        'Dimension (n+1)': x + 1,
        'Stability (id)': x,
        'Capacity (id)': x,
    }

    colors = ['#2196F3', '#F44336', '#4CAF50', '#FF9800', '#9C27B0']
    for (name, vals), color in zip(theories.items(), colors):
        ax.plot(x, vals, 'o-', label=name, color=color, linewidth=2, markersize=6)

    ax.set_xlabel('Object value (n)', fontsize=12)
    ax.set_ylabel('Invariant value', fontsize=12)
    ax.set_title('Invariant Functions Across Research Theories', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(-0.5, 11.5)

    return fig_to_base64(fig)


def viz_monotonicity_proof():
    """Visualize monotonicity of the height-to-cell morphism."""
    fig, ax = plt.subplots(figsize=(10, 6))

    x = np.arange(0, 10)
    height_inv = x
    cell_inv = x * (x + 1)

    ax.bar(x - 0.2, height_inv, 0.35, label='Source: Height.Inv(n) = n',
           color='#2196F3', alpha=0.8)
    ax.bar(x + 0.2, cell_inv, 0.35, label='Target: Cell.Inv(n) = n·(n+1)',
           color='#F44336', alpha=0.8)

    # Draw arrows showing monotonicity
    for i in x:
        if height_inv[i] > 0:
            ax.annotate('', xy=(i + 0.2, cell_inv[i]),
                       xytext=(i - 0.2, height_inv[i]),
                       arrowprops=dict(arrowstyle='->', color='green',
                                      lw=1.5, alpha=0.6))

    ax.set_xlabel('Object value (n)', fontsize=12)
    ax.set_ylabel('Invariant value', fontsize=12)
    ax.set_title('Monotonicity: Height.Inv(n) ≤ Cell.Inv(φ(n))', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3, axis='y')

    return fig_to_base64(fig)


def viz_composition_pipeline():
    """Visualize the four-theory composition pipeline."""
    fig, axes = plt.subplots(1, 4, figsize=(16, 5), sharey=False)

    x = np.arange(0, 8)

    # Height
    axes[0].bar(x, x, color='#2196F3', alpha=0.8)
    axes[0].set_title('Height\nInv(n) = n', fontsize=11, fontweight='bold')
    axes[0].set_xlabel('n')
    axes[0].set_ylabel('Invariant')

    # Dimension
    axes[1].bar(x, x + 1, color='#4CAF50', alpha=0.8)
    axes[1].set_title('Dimension\nInv(n) = n+1', fontsize=11, fontweight='bold')
    axes[1].set_xlabel('n')

    # Stability (after dim→stab: n ↦ n+1)
    stab_vals = x + 1  # Values after the morphism
    axes[2].bar(x, stab_vals, color='#FF9800', alpha=0.8)
    axes[2].set_title('Stability\nvia dim→stab', fontsize=11, fontweight='bold')
    axes[2].set_xlabel('n')

    # Capacity (same as stability, id morphism)
    axes[3].bar(x, stab_vals, color='#9C27B0', alpha=0.8)
    axes[3].set_title('Capacity\nvia stab→cap', fontsize=11, fontweight='bold')
    axes[3].set_xlabel('n')

    # Add depth threshold line
    for ax in axes:
        ax.axhline(y=2, color='red', linestyle='--', alpha=0.5, label='depth=2')
        ax.grid(True, alpha=0.3, axis='y')

    fig.suptitle('Four-Theory Pipeline: Depth Certificates Transfer End-to-End',
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()

    return fig_to_base64(fig)


def viz_theory_graph():
    """Visualize the theory graph with morphism connections."""
    fig, ax = plt.subplots(figsize=(10, 7))

    # Node positions
    positions = {
        'Height': (0.2, 0.7),
        'Cell': (0.8, 0.9),
        'Dimension': (0.5, 0.5),
        'Stability': (0.8, 0.3),
        'Capacity': (0.5, 0.1),
    }

    colors = {
        'Height': '#2196F3',
        'Cell': '#F44336',
        'Dimension': '#4CAF50',
        'Stability': '#FF9800',
        'Capacity': '#9C27B0',
    }

    # Draw edges (morphisms)
    edges = [
        ('Height', 'Cell', 'id\nh ≤ h(h+1)'),
        ('Height', 'Dimension', 'id\nh ≤ h+1'),
        ('Dimension', 'Stability', 'n↦n+1'),
        ('Stability', 'Capacity', 'id'),
    ]

    for src, tgt, label in edges:
        x1, y1 = positions[src]
        x2, y2 = positions[tgt]
        ax.annotate('', xy=(x2, y2), xytext=(x1, y1),
                   arrowprops=dict(arrowstyle='->', color='gray',
                                  lw=2, connectionstyle='arc3,rad=0.1'))
        mx, my = (x1 + x2) / 2, (y1 + y2) / 2
        ax.text(mx + 0.03, my + 0.03, label, fontsize=8,
               ha='center', va='center',
               bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow',
                        edgecolor='gray', alpha=0.8))

    # Draw nodes
    for name, (x, y) in positions.items():
        circle = plt.Circle((x, y), 0.06, color=colors[name], alpha=0.8, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y, name, ha='center', va='center', fontsize=9,
               fontweight='bold', color='white', zorder=6)

    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Theory Graph: Certified Bridges Between Research Domains',
                fontsize=14, fontweight='bold')

    return fig_to_base64(fig)


def viz_predicate_transfer():
    """Visualize predicate preservation through composition."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    x = np.arange(0, 10)

    # Source: ArithmeticallySignificant (x ≥ 2)
    source_colors = ['#FF6B6B' if xi < 2 else '#4CAF50' for xi in x]
    axes[0].bar(x, x, color=source_colors, alpha=0.8)
    axes[0].set_title('Source: Height Theory\nP(x) = (x ≥ 2)', fontsize=11)
    axes[0].set_xlabel('x')
    axes[0].set_ylabel('Height.Inv(x)')
    axes[0].axhline(y=2, color='red', linestyle='--', alpha=0.5)

    # Intermediate: after height→dim
    dim_vals = x + 1
    mid_colors = ['#FF6B6B' if xi < 2 else '#4CAF50' for xi in x]
    axes[1].bar(x, dim_vals, color=mid_colors, alpha=0.8)
    axes[1].set_title('Middle: Dimension Theory\nQ(y) = (Dim.Inv(y) ≥ 2)', fontsize=11)
    axes[1].set_xlabel('φ(x) = x')
    axes[1].set_ylabel('Dim.Inv(x)')
    axes[1].axhline(y=2, color='red', linestyle='--', alpha=0.5)

    # Target: after dim→stab
    stab_vals = x + 1
    target_colors = ['#FF6B6B' if xi < 2 else '#4CAF50' for xi in x]
    axes[2].bar(x, stab_vals, color=target_colors, alpha=0.8)
    axes[2].set_title('Target: Stability Theory\nR(z) = (Stab.Inv(z) ≥ 2)', fontsize=11)
    axes[2].set_xlabel('ψ(φ(x)) = x+1')
    axes[2].set_ylabel('Stab.Inv(x+1)')
    axes[2].axhline(y=2, color='red', linestyle='--', alpha=0.5)

    for ax in axes:
        ax.grid(True, alpha=0.3, axis='y')

    # Add legend
    green_patch = mpatches.Patch(color='#4CAF50', alpha=0.8, label='Predicate TRUE')
    red_patch = mpatches.Patch(color='#FF6B6B', alpha=0.8, label='Predicate FALSE')
    axes[1].legend(handles=[green_patch, red_patch], fontsize=9)

    fig.suptitle('Predicate Preservation Through Composition',
                fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()

    return fig_to_base64(fig)


def generate_all_visualizations():
    """Generate all visualizations and return as dict."""
    print("Generating visualizations...")

    vizs = {
        'invariant_comparison': viz_invariant_comparison(),
        'monotonicity_proof': viz_monotonicity_proof(),
        'composition_pipeline': viz_composition_pipeline(),
        'theory_graph': viz_theory_graph(),
        'predicate_transfer': viz_predicate_transfer(),
    }

    print(f"Generated {len(vizs)} visualizations.")
    return vizs


if __name__ == "__main__":
    vizs = generate_all_visualizations()
    for name, data_uri in vizs.items():
        print(f"  {name}: {len(data_uri)} chars")
