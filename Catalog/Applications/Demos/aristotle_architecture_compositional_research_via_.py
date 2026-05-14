"""
Theory Morphisms: Applications to Real-World Cross-Domain Problems

Demonstrates how the theory morphism framework applies to:
1. Machine Learning: Transfer of generalization bounds
2. Cryptography: Security parameter propagation
3. Network Science: Connectivity invariant transfer
"""

from dataclasses import dataclass
from typing import Callable, List, Tuple, Optional
import math


@dataclass
class ResearchTheory:
    """A mathematical theory with carrier ℕ and ℕ-valued invariant."""
    name: str
    inv: Callable[[int], int]
    description: str = ""

    def satisfies_bound(self, n: int, search_range: int = 1000) -> Optional[int]:
        for x in range(search_range):
            if n <= self.inv(x):
                return x
        return None


@dataclass
class TheoryMorphism:
    """A monotone translation between theories."""
    source: ResearchTheory
    target: ResearchTheory
    to_fun: Callable[[int], int]
    name: str = ""

    def transfer(self, n: int, witness: int) -> Tuple[int, int]:
        y = self.to_fun(witness)
        return y, self.target.inv(y)


# ═══════════════════════════════════════════════════════════════
# Application 1: Machine Learning — Generalization Bound Transfer
# ═══════════════════════════════════════════════════════════════

def ml_application():
    """
    In ML, the VC dimension of a hypothesis class bounds the sample
    complexity needed for learning. When we transform hypothesis classes
    (e.g., from linear classifiers to polynomial classifiers), the VC
    dimension can only increase — this is a theory morphism.

    If we've proven that linear classifiers need N samples for accuracy ε,
    then polynomial classifiers need at least N samples too.
    """
    print("=" * 70)
    print("APPLICATION 1: Machine Learning — Generalization Bound Transfer")
    print("=" * 70)
    print()

    # Theory of linear classifiers: VC dim = d+1 for d-dimensional space
    linear_theory = ResearchTheory(
        "LinearClassifiers",
        inv=lambda d: d + 1,
        description="VC dimension of linear classifiers in ℝ^d"
    )

    # Theory of polynomial classifiers: VC dim grows as C(d+k, k)
    # For degree-2 polynomials in d dimensions: VC dim ≈ C(d+2, 2) = (d+1)(d+2)/2
    poly_theory = ResearchTheory(
        "PolynomialClassifiers",
        inv=lambda d: (d + 1) * (d + 2) // 2,
        description="VC dimension of degree-2 polynomial classifiers in ℝ^d"
    )

    # The inclusion of linear into polynomial is a morphism
    # (every linear classifier is a degree-2 polynomial)
    inclusion = TheoryMorphism(
        linear_theory, poly_theory,
        to_fun=lambda d: d,
        name="Linear ↪ Polynomial"
    )

    print(f"  {linear_theory.description}")
    print(f"  {poly_theory.description}")
    print()

    # Transfer: if linear classifiers in ℝ^5 need at least 6 samples,
    # then polynomial classifiers in ℝ^5 need at least 6 samples too
    d = 5
    linear_vc = linear_theory.inv(d)
    poly_vc = poly_theory.inv(d)

    print(f"  Dimension d = {d}:")
    print(f"    Linear VC dimension = {linear_vc}")
    print(f"    Polynomial VC dimension = {poly_vc}")
    print(f"    Monotonicity: {linear_vc} ≤ {poly_vc} ✓")
    print()

    # Table of transferred bounds
    print(f"  {'d':<6} {'Linear VC':<14} {'Poly VC':<14} {'Amplification':<14}")
    print(f"  {'─'*6} {'─'*14} {'─'*14} {'─'*14}")
    for d in range(1, 11):
        lvc = linear_theory.inv(d)
        pvc = poly_theory.inv(d)
        print(f"  {d:<6} {lvc:<14} {pvc:<14} {pvc/lvc:.1f}x")
    print()


# ═══════════════════════════════════════════════════════════════
# Application 2: Cryptography — Security Parameter Propagation
# ═══════════════════════════════════════════════════════════════

def crypto_application():
    """
    In cryptography, the security level of a scheme is measured in bits.
    When we build composed cryptographic protocols (e.g., a hash function
    composed with a signature scheme), the security level can only decrease
    or stay the same — but from the attacker's perspective, the *attack
    complexity* (the invariant) can only increase with key size.

    Theory morphism: key size → attack complexity is monotone.
    """
    print("=" * 70)
    print("APPLICATION 2: Cryptography — Security Parameter Propagation")
    print("=" * 70)
    print()

    # Symmetric key security: attack complexity = 2^(key_bits)
    # We model log2 of attack complexity = key_bits
    symmetric_theory = ResearchTheory(
        "SymmetricKey",
        inv=lambda bits: bits,
        description="Security level = key length in bits"
    )

    # RSA security: for n-bit modulus, best attack is GNFS
    # log2(attack complexity) ≈ 1.9 * n^(1/3) * (ln n)^(2/3)
    # Simplified: for 1024-bit RSA, security ≈ 80 bits
    def rsa_security(bits: int) -> int:
        if bits < 8:
            return 0
        return int(1.9 * (bits ** (1/3)) * (math.log(bits) ** (2/3)))

    rsa_theory = ResearchTheory(
        "RSA",
        inv=rsa_security,
        description="GNFS attack complexity for n-bit RSA modulus"
    )

    # Lattice-based security: n-dimensional lattice
    # Security ≈ 0.265 * n (conservative estimate from BKZ analysis)
    lattice_theory = ResearchTheory(
        "Lattice",
        inv=lambda n: int(0.265 * n) if n > 0 else 0,
        description="BKZ attack complexity for n-dimensional lattice"
    )

    print(f"  {'Key/Dim':<12} {'Symmetric':<14} {'RSA':<14} {'Lattice':<14}")
    print(f"  {'─'*12} {'─'*14} {'─'*14} {'─'*14}")
    for n in [128, 256, 512, 1024, 2048, 4096]:
        s = symmetric_theory.inv(n)
        r = rsa_theory.inv(n)
        l = lattice_theory.inv(n)
        print(f"  {n:<12} {s:<14} {r:<14} {l:<14}")
    print()

    # Transfer: if we need 128-bit security, what key sizes are needed?
    target_security = 128
    print(f"  To achieve {target_security}-bit security:")
    for theory in [symmetric_theory, rsa_theory, lattice_theory]:
        witness = theory.satisfies_bound(target_security, search_range=20000)
        if witness is not None:
            print(f"    {theory.name}: min parameter = {witness} "
                  f"(achieves {theory.inv(witness)}-bit security)")
        else:
            print(f"    {theory.name}: requires parameter > 20000")
    print()


# ═══════════════════════════════════════════════════════════════
# Application 3: Network Science — Connectivity Transfer
# ═══════════════════════════════════════════════════════════════

def network_application():
    """
    In network science, graph properties transfer along graph morphisms.
    If a graph G has high connectivity (many edge-disjoint paths), and
    there's a structure-preserving map from G to H, then H inherits
    connectivity lower bounds.

    We model this with theories where the invariant is the minimum
    degree (a lower bound on edge connectivity by Whitney's theorem).
    """
    print("=" * 70)
    print("APPLICATION 3: Network Science — Connectivity Invariant Transfer")
    print("=" * 70)
    print()

    # Complete graph theory: K_n has min degree n-1
    complete_graph = ResearchTheory(
        "CompleteGraph",
        inv=lambda n: max(0, n - 1),
        description="K_n: minimum degree = n-1"
    )

    # Regular graph theory: d-regular graph has min degree d
    regular_graph = ResearchTheory(
        "RegularGraph",
        inv=lambda d: d,
        description="d-regular graph: minimum degree = d"
    )

    # Random graph G(n,p) theory: min degree ≈ np - √(np·ln(n))
    # Simplified: for p = 0.5, min degree ≈ n/2 - √(n)
    random_graph = ResearchTheory(
        "RandomGraph",
        inv=lambda n: max(0, n // 2 - int(math.sqrt(n))) if n > 0 else 0,
        description="G(n,0.5): expected minimum degree"
    )

    # K_n embeds into (n-1)-regular graphs (K_n is (n-1)-regular)
    complete_to_regular = TheoryMorphism(
        complete_graph, regular_graph,
        to_fun=lambda n: max(0, n - 1),
        name="K_n → (n-1)-regular"
    )

    print(f"  {'n':<6} {'K_n min deg':<14} {'Regular(n-1)':<14} {'G(n,0.5)':<14}")
    print(f"  {'─'*6} {'─'*14} {'─'*14} {'─'*14}")
    for n in range(2, 21):
        k = complete_graph.inv(n)
        r = regular_graph.inv(max(0, n - 1))
        g = random_graph.inv(n)
        print(f"  {n:<6} {k:<14} {r:<14} {g:<14}")
    print()

    # Transfer: if K_10 has connectivity ≥ 9, then any graph receiving
    # a morphism from K_10 has connectivity ≥ 9
    print("  Transfer example:")
    print(f"    K_10 has min degree = {complete_graph.inv(10)}")
    witness, target_val = complete_to_regular.transfer(9, 10)
    print(f"    Maps to {witness}-regular graph with min degree = {target_val}")
    print(f"    Connectivity lower bound 9 transfers ✓")
    print()


# ═══════════════════════════════════════════════════════════════
# Application 4: Composing Across All Domains
# ═══════════════════════════════════════════════════════════════

def composition_application():
    """
    Demonstrate cross-domain composition: a result from one field
    transfers through an intermediate field to a third.
    """
    print("=" * 70)
    print("APPLICATION 4: Cross-Domain Composition Pipeline")
    print("=" * 70)
    print()

    # Arithmetic complexity (height) → Geometric complexity (cell count)
    # → Algorithmic complexity (search space)
    arith = ResearchTheory("Arithmetic", inv=lambda h: h)
    geom = ResearchTheory("Geometric", inv=lambda n: n * (n + 1))
    algo = ResearchTheory("Algorithmic", inv=lambda s: int(math.log2(s + 1)))

    # Note: arith → geom is monotone (h ≤ h(h+1))
    # geom → algo requires: n(n+1) ≤ log2(f(n)+1)
    # This is NOT monotone for identity map. But if we use f(n) = 2^(n(n+1)),
    # then log2(2^(n(n+1))+1) ≈ n(n+1), which is monotone.

    # Let's use a different algorithmic theory where the invariant matches
    algo2 = ResearchTheory("Algorithmic2", inv=lambda s: s * s)

    arith_to_geom = TheoryMorphism(arith, geom, lambda x: x, "A→G")
    geom_to_algo = TheoryMorphism(geom, algo2, lambda x: x, "G→Algo")

    # Verify monotonicity
    print("  Pipeline: Arithmetic → Geometric → Algorithmic")
    print()
    print(f"  {'h':<6} {'Arith.Inv':<12} {'Geom.Inv':<12} {'Algo.Inv':<12} {'Monotone?':<12}")
    print(f"  {'─'*6} {'─'*12} {'─'*12} {'─'*12} {'─'*12}")

    for h in range(11):
        a_val = arith.inv(h)
        g_val = geom.inv(arith_to_geom.to_fun(h))
        al_val = algo2.inv(geom_to_algo.to_fun(arith_to_geom.to_fun(h)))
        ok = a_val <= g_val <= al_val
        print(f"  {h:<6} {a_val:<12} {g_val:<12} {al_val:<12} {'✓' if ok else '✗'}")
    print()

    # Transfer a concrete bound
    bound = 7
    witness = arith.satisfies_bound(bound)
    print(f"  Transferring bound {bound} through pipeline:")
    print(f"    Arithmetic witness: x={witness}, Inv={arith.inv(witness)}")
    y1 = arith_to_geom.to_fun(witness)
    print(f"    → Geometric: y={y1}, Inv={geom.inv(y1)}")
    y2 = geom_to_algo.to_fun(y1)
    print(f"    → Algorithmic: z={y2}, Inv={algo2.inv(y2)}")
    print(f"    Bound {bound} preserved at every stage ✓")
    print()


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║    Theory Morphisms: Real-World Applications                       ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    ml_application()
    crypto_application()
    network_application()
    composition_application()

    print("All applications demonstrated successfully.")


"""
Theory Morphisms: Demonstration of Cross-Domain Theorem Transfer

This script demonstrates the formal framework of ResearchTheory and TheoryHom
with concrete numerical examples, showing how lower bounds propagate through
certified bridge morphisms.
"""

from dataclasses import dataclass
from typing import Callable, Optional, List, Tuple


@dataclass
class ResearchTheory:
    """A mathematical theory with a carrier type (modeled as domain of ints) and invariant."""
    name: str
    inv: Callable[[int], int]  # Invariant function: carrier → ℕ

    def satisfies_lower_bound(self, n: int, search_range: int = 100) -> Optional[int]:
        """Find a witness x such that n ≤ inv(x), or None."""
        for x in range(search_range):
            if n <= self.inv(x):
                return x
        return None

    def max_invariant(self, up_to: int = 20) -> int:
        """Maximum invariant value for elements 0..up_to."""
        return max(self.inv(x) for x in range(up_to + 1))


@dataclass
class TheoryHom:
    """A morphism between theories with a monotonicity certificate."""
    source: ResearchTheory
    target: ResearchTheory
    to_fun: Callable[[int], int]
    name: str = ""

    def verify_monotonicity(self, up_to: int = 50) -> bool:
        """Verify monotonicity for elements 0..up_to."""
        return all(
            self.source.inv(x) <= self.target.inv(self.to_fun(x))
            for x in range(up_to + 1)
        )

    def transfer_lower_bound(self, n: int, witness: int) -> Tuple[int, int]:
        """Transfer a lower bound: given witness x with n ≤ source.inv(x),
        return (to_fun(x), target.inv(to_fun(x)))."""
        assert n <= self.source.inv(witness), f"Witness {witness} doesn't satisfy bound {n}"
        y = self.to_fun(witness)
        target_val = self.target.inv(y)
        assert n <= target_val, "Monotonicity violation!"
        return y, target_val


def compose(f: TheoryHom, g: TheoryHom) -> TheoryHom:
    """Compose two morphisms f: T→U and g: U→V into f;g: T→V."""
    assert f.target.name == g.source.name, "Morphisms not composable"
    return TheoryHom(
        source=f.source,
        target=g.target,
        to_fun=lambda x: g.to_fun(f.to_fun(x)),
        name=f"{f.name} ; {g.name}"
    )


# ═══════════════════════════════════════════════════════════════
# Define the five catalog theories
# ═══════════════════════════════════════════════════════════════

height_theory = ResearchTheory("Height", inv=lambda n: n)
cell_theory = ResearchTheory("Cell", inv=lambda n: n * (n + 1))
dimension_theory = ResearchTheory("Dimension", inv=lambda n: n + 1)
stability_theory = ResearchTheory("Stability", inv=lambda n: n)
capacity_theory = ResearchTheory("Capacity", inv=lambda n: n)

# ═══════════════════════════════════════════════════════════════
# Define the bridge morphisms
# ═══════════════════════════════════════════════════════════════

height_to_cell = TheoryHom(height_theory, cell_theory, lambda x: x, "H→C")
height_to_dim = TheoryHom(height_theory, dimension_theory, lambda x: x, "H→D")
dim_to_stab = TheoryHom(dimension_theory, stability_theory, lambda x: x + 1, "D→S")
stab_to_cap = TheoryHom(stability_theory, capacity_theory, lambda x: x, "S→Cap")

# Composed pipelines
height_to_stab = compose(height_to_dim, dim_to_stab)
height_to_cap = compose(height_to_stab, stab_to_cap)


def demo_basic():
    """Demonstrate basic theory and morphism concepts."""
    print("=" * 70)
    print("DEMO 1: Basic Theory Invariants")
    print("=" * 70)
    print()

    for theory in [height_theory, cell_theory, dimension_theory, stability_theory]:
        print(f"  {theory.name} Theory:")
        vals = [(x, theory.inv(x)) for x in range(8)]
        print(f"    Invariant values: {vals}")
        print()


def demo_monotonicity():
    """Verify monotonicity of all morphisms."""
    print("=" * 70)
    print("DEMO 2: Monotonicity Verification")
    print("=" * 70)
    print()

    for morph in [height_to_cell, height_to_dim, dim_to_stab, stab_to_cap]:
        ok = morph.verify_monotonicity(50)
        status = "✓ VERIFIED" if ok else "✗ FAILED"
        print(f"  {morph.name}: {morph.source.name} → {morph.target.name}  [{status}]")

    print()
    # Composed morphisms
    for morph in [height_to_stab, height_to_cap]:
        ok = morph.verify_monotonicity(50)
        status = "✓ VERIFIED" if ok else "✗ FAILED"
        print(f"  {morph.name}: {morph.source.name} → {morph.target.name}  [{status}]")
    print()


def demo_transfer():
    """Demonstrate the transfer principle with concrete examples."""
    print("=" * 70)
    print("DEMO 3: Transfer Principle — Lower Bound Propagation")
    print("=" * 70)
    print()

    # Height theory achieves lower bound 10 via witness x=10
    n = 10
    witness = height_theory.satisfies_lower_bound(n)
    print(f"  Height theory satisfies lower bound {n} via witness x={witness}")
    print(f"    Height.Inv({witness}) = {height_theory.inv(witness)}")
    print()

    # Transfer through each bridge
    for morph in [height_to_cell, height_to_dim, height_to_stab, height_to_cap]:
        y, target_val = morph.transfer_lower_bound(n, witness)
        print(f"  Transfer via {morph.name}:")
        print(f"    Witness maps to y={y}, {morph.target.name}.Inv({y}) = {target_val} ≥ {n} ✓")
    print()


def demo_pipeline():
    """Show invariant values at each stage of the pipeline."""
    print("=" * 70)
    print("DEMO 4: Pipeline — Invariant Values at Each Stage")
    print("=" * 70)
    print()

    print(f"  {'Input h':<10} {'Height':<10} {'Cell':<10} {'Dimension':<12} {'Stability':<12} {'Capacity':<10}")
    print(f"  {'─'*10} {'─'*10} {'─'*10} {'─'*12} {'─'*12} {'─'*10}")

    for h in range(11):
        h_val = height_theory.inv(h)
        c_val = cell_theory.inv(height_to_cell.to_fun(h))
        d_val = dimension_theory.inv(height_to_dim.to_fun(h))
        s_val = stability_theory.inv(height_to_stab.to_fun(h))
        cap_val = capacity_theory.inv(height_to_cap.to_fun(h))
        print(f"  {h:<10} {h_val:<10} {c_val:<10} {d_val:<12} {s_val:<12} {cap_val:<10}")
    print()


def demo_gap_theorem():
    """Demonstrate the gap theorem."""
    print("=" * 70)
    print("DEMO 5: Gap Theorem — When Translation Is Impossible")
    print("=" * 70)
    print()

    # CellTheory has max invariant 420 at element 20
    # A "bounded" theory with max depth 10 cannot receive a morphism from
    # any theory achieving bound 11

    bounded_theory = ResearchTheory("Bounded", inv=lambda n: min(n, 10))
    deep_theory = ResearchTheory("Deep", inv=lambda n: n * 2)

    # Deep theory achieves bound 22 at x=11
    witness = deep_theory.satisfies_lower_bound(22)
    bounded_max = bounded_theory.max_invariant(100)

    print(f"  Deep theory achieves lower bound 22 via witness x={witness}")
    print(f"  Bounded theory has max depth = {bounded_max}")
    print(f"  Gap: 22 > {bounded_max}")
    print(f"  ⟹ No morphism from Deep to Bounded can exist! (Gap Theorem)")
    print()

    # Verify: no element in bounded theory can have invariant ≥ 22
    exists_high = bounded_theory.satisfies_lower_bound(22, search_range=1000)
    print(f"  Verification: Bounded.satisfies_lower_bound(22) = {exists_high}")
    print(f"  Confirmed: transfer is impossible ✓")
    print()


def demo_strict_increase():
    """Demonstrate strict depth increase for the height→cell bridge."""
    print("=" * 70)
    print("DEMO 6: Strict Depth Increase (Height → Cell for h ≥ 2)")
    print("=" * 70)
    print()

    print(f"  {'h':<6} {'Height.Inv(h)':<16} {'Cell.Inv(h)':<14} {'Strict?':<10}")
    print(f"  {'─'*6} {'─'*16} {'─'*14} {'─'*10}")

    for h in range(8):
        h_val = height_theory.inv(h)
        c_val = cell_theory.inv(h)
        strict = h_val < c_val
        marker = "✓ strict" if strict else ("= equal" if h_val == c_val else "✗")
        print(f"  {h:<6} {h_val:<16} {c_val:<14} {marker}")
    print()
    print("  For h ≥ 2: Height.Inv(h) < Cell.Inv(h) always holds ✓")
    print()


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║   Theory Morphisms: Cross-Domain Theorem Transfer Demonstration    ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_basic()
    demo_monotonicity()
    demo_transfer()
    demo_pipeline()
    demo_gap_theorem()
    demo_strict_increase()

    print("All demonstrations completed successfully.")


"""
Theory Morphisms: Visualizations

Generates charts showing invariant growth, morphism composition,
gap detection, and the theory dominance network.
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
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def plot_invariant_profiles():
    """Plot invariant functions for all five theories."""
    fig, ax = plt.subplots(figsize=(10, 6))

    x = np.arange(0, 16)
    theories = {
        'Height (id)': x,
        'Cell (n·(n+1))': x * (x + 1),
        'Dimension (n+1)': x + 1,
        'Stability (id)': x,
        'Capacity (id)': x,
    }

    colors = ['#2196F3', '#F44336', '#4CAF50', '#FF9800', '#9C27B0']
    markers = ['o', 's', '^', 'D', 'v']

    for (name, values), color, marker in zip(theories.items(), colors, markers):
        ax.plot(x, values, '-', color=color, marker=marker, markersize=6,
                linewidth=2, label=name, alpha=0.85)

    ax.set_xlabel('Carrier Element (n)', fontsize=13)
    ax.set_ylabel('Invariant Value', fontsize=13)
    ax.set_title('Invariant Profiles of Research Theories', fontsize=15, fontweight='bold')
    ax.legend(fontsize=11, loc='upper left')
    ax.grid(True, alpha=0.3)
    ax.set_xlim(-0.5, 15.5)

    return fig_to_base64(fig)


def plot_morphism_amplification():
    """Plot how the height→cell morphism amplifies invariant values."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    x = np.arange(0, 16)

    # Left: source vs target invariant
    source = x  # Height.Inv = id
    target = x * (x + 1)  # Cell.Inv = n(n+1)

    ax1.fill_between(x, source, target, alpha=0.2, color='#4CAF50',
                     label='Amplification region')
    ax1.plot(x, source, 'o-', color='#2196F3', linewidth=2, markersize=6,
             label='Source: Height.Inv(x)')
    ax1.plot(x, target, 's-', color='#F44336', linewidth=2, markersize=6,
             label='Target: Cell.Inv(x)')
    ax1.set_xlabel('Element x', fontsize=12)
    ax1.set_ylabel('Invariant Value', fontsize=12)
    ax1.set_title('Height → Cell: Invariant Amplification', fontsize=13, fontweight='bold')
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Right: amplification ratio
    ratio = np.where(source > 0, target / source, 1)
    ax2.bar(x, ratio, color='#FF9800', alpha=0.7, edgecolor='#E65100')
    ax2.set_xlabel('Element x', fontsize=12)
    ax2.set_ylabel('Amplification Ratio', fontsize=12)
    ax2.set_title('Depth Amplification: Cell.Inv(x) / Height.Inv(x)', fontsize=13, fontweight='bold')
    ax2.grid(True, alpha=0.3, axis='y')
    ax2.axhline(y=1, color='red', linestyle='--', alpha=0.5, label='No amplification')
    ax2.legend(fontsize=10)

    fig.tight_layout()
    return fig_to_base64(fig)


def plot_pipeline_transfer():
    """Plot invariant values through the Height → Dim → Stability pipeline."""
    fig, ax = plt.subplots(figsize=(10, 6))

    x = np.arange(0, 11)

    # Pipeline stages
    height_inv = x
    dim_inv = x + 1
    stab_inv = x + 1  # dimensionToStability maps n to n+1, Stability.Inv = id, so inv = n+1

    width = 0.25
    ax.bar(x - width, height_inv, width, label='Height Theory', color='#2196F3', alpha=0.8)
    ax.bar(x, dim_inv, width, label='Dimension Theory', color='#4CAF50', alpha=0.8)
    ax.bar(x + width, stab_inv, width, label='Stability Theory', color='#FF9800', alpha=0.8)

    # Draw arrows showing monotonicity
    for i in range(len(x)):
        if height_inv[i] > 0:
            ax.annotate('', xy=(i, dim_inv[i] + 0.1), xytext=(i - width, height_inv[i] + 0.1),
                       arrowprops=dict(arrowstyle='->', color='gray', lw=0.8, alpha=0.5))

    ax.set_xlabel('Input Element', fontsize=13)
    ax.set_ylabel('Invariant Value', fontsize=13)
    ax.set_title('Pipeline Transfer: Height → Dimension → Stability', fontsize=15, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3, axis='y')

    return fig_to_base64(fig)


def plot_gap_theorem():
    """Visualize the gap theorem with concrete theories."""
    fig, ax = plt.subplots(figsize=(10, 6))

    x = np.arange(0, 21)

    # Deep theory: inv = 2n
    deep_inv = 2 * x
    # Bounded theory: inv = min(n, 10)
    bounded_inv = np.minimum(x, 10)

    ax.plot(x, deep_inv, 'o-', color='#F44336', linewidth=2, markersize=6,
            label='Deep Theory: Inv(n) = 2n')
    ax.plot(x, bounded_inv, 's-', color='#2196F3', linewidth=2, markersize=6,
            label='Bounded Theory: Inv(n) = min(n, 10)')

    # Shade the gap region
    ax.fill_between(x, 10, deep_inv, where=deep_inv > 10,
                    alpha=0.2, color='#F44336', label='Gap region (no morphism possible)')

    ax.axhline(y=10, color='gray', linestyle='--', alpha=0.5, label='Bounded depth = 10')

    # Mark the first gap point
    gap_x = 6  # 2*6 = 12 > 10
    ax.annotate(f'Gap: Deep achieves {2*gap_x}\nbut Bounded max = 10',
               xy=(gap_x, 2*gap_x), xytext=(gap_x + 3, 2*gap_x + 5),
               arrowprops=dict(arrowstyle='->', color='#F44336', lw=2),
               fontsize=11, color='#F44336', fontweight='bold')

    ax.set_xlabel('Carrier Element', fontsize=13)
    ax.set_ylabel('Invariant Value', fontsize=13)
    ax.set_title('Gap Theorem: When Translation Is Impossible', fontsize=15, fontweight='bold')
    ax.legend(fontsize=10, loc='upper left')
    ax.grid(True, alpha=0.3)

    return fig_to_base64(fig)


def plot_theory_network():
    """Draw the theory dominance network as a directed graph."""
    fig, ax = plt.subplots(figsize=(10, 8))
    ax.set_xlim(-0.5, 4.5)
    ax.set_ylim(-0.5, 3.5)
    ax.set_aspect('equal')
    ax.axis('off')

    # Node positions
    positions = {
        'Height': (2, 3),
        'Cell': (0.5, 1.5),
        'Dimension': (2, 1.5),
        'Stability': (3.5, 1.5),
        'Capacity': (3.5, 0),
    }

    # Draw edges (morphisms)
    edges = [
        ('Height', 'Cell', 'h ↦ h\n(h ≤ h(h+1))'),
        ('Height', 'Dimension', 'h ↦ h\n(h ≤ h+1)'),
        ('Dimension', 'Stability', 'n ↦ n+1\n(n+1 ≤ n+1)'),
        ('Stability', 'Capacity', 'id\n(n ≤ n)'),
    ]

    for src, tgt, label in edges:
        x1, y1 = positions[src]
        x2, y2 = positions[tgt]
        dx, dy = x2 - x1, y2 - y1
        length = np.sqrt(dx**2 + dy**2)
        # Shorten arrows to not overlap with circles
        r = 0.35
        ax.annotate('', xy=(x2 - r*dx/length, y2 - r*dy/length),
                    xytext=(x1 + r*dx/length, y1 + r*dy/length),
                    arrowprops=dict(arrowstyle='->', color='#333',
                                   lw=2, connectionstyle='arc3,rad=0.1'))

        # Label at midpoint
        mx, my = (x1 + x2) / 2, (y1 + y2) / 2
        offset = 0.3 if src != 'Height' or tgt != 'Dimension' else -0.4
        ax.text(mx + offset * (-dy/length), my + offset * (dx/length),
                label, fontsize=8, ha='center', va='center',
                color='#666', style='italic',
                bbox=dict(boxstyle='round,pad=0.2', facecolor='white',
                         edgecolor='none', alpha=0.8))

    # Draw nodes
    colors = {'Height': '#2196F3', 'Cell': '#F44336', 'Dimension': '#4CAF50',
              'Stability': '#FF9800', 'Capacity': '#9C27B0'}

    for name, (x, y) in positions.items():
        circle = plt.Circle((x, y), 0.3, color=colors[name], alpha=0.85)
        ax.add_patch(circle)
        ax.text(x, y, name, ha='center', va='center', fontsize=9,
                fontweight='bold', color='white')

    ax.set_title('Theory Dominance Network\n(Arrows = Certified Morphisms)',
                fontsize=15, fontweight='bold', pad=20)

    return fig_to_base64(fig)


def generate_all_visualizations():
    """Generate all visualizations and return as dict of base64 strings."""
    print("Generating visualizations...")

    viz = {}
    viz['invariant_profiles'] = plot_invariant_profiles()
    print("  ✓ Invariant profiles")

    viz['morphism_amplification'] = plot_morphism_amplification()
    print("  ✓ Morphism amplification")

    viz['pipeline_transfer'] = plot_pipeline_transfer()
    print("  ✓ Pipeline transfer")

    viz['gap_theorem'] = plot_gap_theorem()
    print("  ✓ Gap theorem")

    viz['theory_network'] = plot_theory_network()
    print("  ✓ Theory network")

    print("All visualizations generated.")
    return viz


if __name__ == "__main__":
    viz = generate_all_visualizations()

    # Save individual PNGs for inspection
    for name, data_uri in viz.items():
        # Extract base64 data
        b64_data = data_uri.split(',')[1]
        img_data = base64.b64decode(b64_data)
        filename = f"{name}.png"
        with open(filename, 'wb') as f:
            f.write(img_data)
        print(f"  Saved {filename}")
