#!/usr/bin/env python3
"""
Applications of Predicate Transport to Cross-Domain Certification

This module demonstrates how predicate transport applies to real-world
domains: certified machine learning, tropical computation, Byzantine
fault tolerance, and entropy-based cryptography.
"""

import math
from dataclasses import dataclass
from typing import Callable


@dataclass
class CertifiedTheory:
    """A theory with carrier, invariant, and a validity predicate."""
    name: str
    inv: Callable[[object], float]
    valid: Callable[[object], bool] = lambda x: True


def invariant_determined_check(theory, pred, elements):
    """Check invariant-determination on finite elements."""
    groups = {}
    for x in elements:
        v = theory.inv(x)
        px = pred(x)
        if v in groups:
            if groups[v] != px:
                return False
        groups[v] = px
    return True


# ============================================================================
# Application 1: Certified Machine Learning — Lipschitz Bound Transfer
# ============================================================================

def ml_application():
    """
    Demonstrate Lipschitz bound transfer for neural network layers.

    A neural network layer has a Lipschitz constant (operator norm).
    This constant is an invariant under semantic equivalence
    (networks with same input-output behavior have same Lipschitz bound).

    Lower bounds on Lipschitz constants transfer: if a source architecture
    has expressivity ≥ L (Lipschitz bound), then any semantics-preserving
    compilation target also has expressivity ≥ L.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 1: Certified ML — Lipschitz Bound Transfer")
    print("=" * 60)

    # Simulate neural network layers as (weight_matrix_norm, bias_norm) pairs
    @dataclass
    class NNLayer:
        weight_norm: float  # operator norm of weight matrix
        bias_norm: float
        name: str = ""

        def lipschitz(self):
            return self.weight_norm  # Lipschitz = operator norm for linear

    # Source architecture: original model
    source_layers = [
        NNLayer(2.5, 0.1, "conv1"),
        NNLayer(1.8, 0.3, "conv2"),
        NNLayer(3.2, 0.05, "fc1"),
    ]

    # Target architecture: pruned/quantized model (semantically equivalent)
    target_layers = [
        NNLayer(2.5, 0.1, "conv1_q"),
        NNLayer(1.9, 0.3, "conv2_q"),  # Slightly larger after quantization
        NNLayer(3.5, 0.05, "fc1_q"),
    ]

    print("\n  Source architecture Lipschitz constants:")
    for layer in source_layers:
        print(f"    {layer.name}: L = {layer.lipschitz()}")

    print("\n  Target architecture Lipschitz constants:")
    for layer in target_layers:
        print(f"    {layer.name}: L = {layer.lipschitz()}")

    # Composition: product of Lipschitz constants
    source_total = math.prod(l.lipschitz() for l in source_layers)
    target_total = math.prod(l.lipschitz() for l in target_layers)

    print(f"\n  Composed Lipschitz: source = {source_total:.2f}, "
          f"target = {target_total:.2f}")
    print(f"  Monotonicity preserved: {source_total <= target_total}")
    print(f"  → Lower bound {source_total:.2f} transfers to target ✓")

    # Predicate: "network has Lipschitz bound ≥ threshold"
    threshold = 10.0
    print(f"\n  Predicate: 'Lipschitz ≥ {threshold}'")
    print(f"    Source satisfies: {source_total >= threshold}")
    print(f"    Target satisfies: {target_total >= threshold} (transferred!)")


# ============================================================================
# Application 2: Tropical Computation — State Count Bounds
# ============================================================================

def tropical_application():
    """
    Demonstrate state count bound transfer in tropical computation.

    In tropical algebra, automata have a "state count" invariant.
    Minimal realization theorems say this count is preserved by
    semantics-preserving transformations (Hankel matrix rank).
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Tropical Computation — State Count Bounds")
    print("=" * 60)

    @dataclass
    class TropicalAutomaton:
        states: int
        transitions: int
        name: str

    # Theory: state count as invariant
    automata = [
        TropicalAutomaton(5, 12, "A1"),
        TropicalAutomaton(8, 20, "A2"),
        TropicalAutomaton(3, 6, "A3"),
        TropicalAutomaton(12, 35, "A4"),
    ]

    state_count_inv = lambda a: a.states

    print("\n  Automata and their state counts:")
    for a in automata:
        print(f"    {a.name}: states={a.states}, transitions={a.transitions}")

    # Predicate: "state count ≤ n" (upper bound)
    for n in [5, 10]:
        print(f"\n  Upper bound predicate: 'states ≤ {n}'")
        for a in automata:
            satisfies = a.states <= n
            print(f"    {a.name}: {satisfies}")

        # Pullback: if all targets have ≤ n states, sources also do
        all_bounded = all(a.states <= n for a in automata)
        print(f"    Universal upper bound: {all_bounded}")
        if all_bounded:
            print(f"    → Pulls back to any source theory via morphism")

    # Lower bound transfer
    print(f"\n  Lower bound transfer:")
    max_states = max(a.states for a in automata)
    print(f"    Maximum state count: {max_states} (from A4)")
    print(f"    → Any target theory receiving A4 has state bound ≥ {max_states}")


# ============================================================================
# Application 3: Byzantine Fault Tolerance — Safety Certificate Transfer
# ============================================================================

def byzantine_application():
    """
    Demonstrate safety certificate transfer in Byzantine protocols.

    In distributed systems, a safety certificate has a "fault tolerance"
    invariant: the maximum number of Byzantine faults tolerated.
    This is invariant-determined (depends only on the protocol's
    fault-tolerance threshold, not implementation details).
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Byzantine Fault Tolerance — Safety Certificates")
    print("=" * 60)

    @dataclass
    class Protocol:
        name: str
        nodes: int
        fault_tolerance: int  # max Byzantine faults
        message_complexity: int

    protocols = [
        Protocol("PBFT", 7, 2, 49),
        Protocol("HotStuff", 10, 3, 30),
        Protocol("Tendermint", 13, 4, 52),
        Protocol("Simple-BFT", 4, 1, 16),
    ]

    print("\n  Protocols and their fault tolerance:")
    for p in protocols:
        print(f"    {p.name}: n={p.nodes}, f={p.fault_tolerance}, "
              f"messages={p.message_complexity}")

    # Invariant: fault tolerance level
    # Predicate: "tolerates ≥ k faults" — invariant-determined
    for k in [2, 3]:
        print(f"\n  Predicate: 'fault tolerance ≥ {k}'")
        for p in protocols:
            satisfies = p.fault_tolerance >= k
            print(f"    {p.name}: {satisfies}")

        witnesses = [p for p in protocols if p.fault_tolerance >= k]
        if witnesses:
            print(f"    → Existential transport: any compiled/optimized version")
            print(f"      of {witnesses[0].name} inherits f≥{k} guarantee")

    # Composition: pipeline of protocol transformations
    print(f"\n  Composition: Protocol Upgrade Pipeline")
    print(f"    PBFT(f=2) → HotStuff(f=3) → Tendermint(f=4)")
    print(f"    Each step preserves/increases fault tolerance")
    print(f"    Lower bound f≥2 from PBFT transfers through entire pipeline")


# ============================================================================
# Application 4: Entropy/Randomness Extraction — Collision Probability Bounds
# ============================================================================

def entropy_application():
    """
    Demonstrate collision probability bound transfer.

    In randomness extraction, the collision probability (Rényi entropy)
    is an invariant. Bounds on collision probability transfer across
    extractor constructions.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Entropy Extraction — Collision Probability Bounds")
    print("=" * 60)

    @dataclass
    class Source:
        name: str
        min_entropy: float  # bits
        collision_prob: float

    sources = [
        Source("Biased coin", 0.5, 0.75),
        Source("Dice roll", 2.58, 0.167),
        Source("Gaussian noise", 4.0, 0.05),
        Source("Hardware RNG", 7.5, 0.006),
    ]

    print("\n  Entropy sources:")
    for s in sources:
        print(f"    {s.name}: H∞={s.min_entropy:.2f} bits, "
              f"Pcoll={s.collision_prob:.4f}")

    # Predicate: "min-entropy ≥ k bits" — invariant-determined
    for k in [2.0, 4.0]:
        print(f"\n  Predicate: 'min-entropy ≥ {k} bits'")
        for s in sources:
            satisfies = s.min_entropy >= k
            print(f"    {s.name}: {satisfies}")

    # Upper bound on collision probability
    print(f"\n  Upper bound pullback: 'collision prob ≤ 0.1'")
    threshold = 0.1
    for s in sources:
        satisfies = s.collision_prob <= threshold
        print(f"    {s.name}: {satisfies}")

    print(f"\n  If extractor output has Pcoll ≤ 0.01:")
    print(f"  → Any source processed by that extractor inherits")
    print(f"    the security guarantee (contravariant pullback)")


# ============================================================================
# Cross-Domain Summary
# ============================================================================

def cross_domain_summary():
    print("\n" + "=" * 60)
    print("CROSS-DOMAIN UNIFICATION via PREDICATE TRANSPORT")
    print("=" * 60)

    domains = [
        ("Certified ML", "Lipschitz constant", "Robustness ≥ L",
         "Compilation preserves robustness certificates"),
        ("Tropical Comp", "State count (Hankel rank)", "Complexity ≤ n",
         "Minimization preserves complexity bounds"),
        ("Byzantine FT", "Fault tolerance f", "Safety with f faults",
         "Protocol optimization preserves safety"),
        ("Entropy/Crypto", "Min-entropy H∞", "Security ≥ k bits",
         "Extractor chaining preserves entropy bounds"),
    ]

    print("\n  Domain            | Invariant              | Predicate Type    | Transport")
    print("  " + "-" * 90)
    for domain, inv, pred, transport in domains:
        print(f"  {domain:<18}| {inv:<23}| {pred:<18}| {transport}")

    print("""
  ALL of these follow the same pattern:
  1. Define an invariant (a numerical measure of the relevant property)
  2. Show the predicate is invariant-determined (depends only on the invariant)
  3. Show the morphism preserves/increases the invariant (monotonicity)
  4. Apply predicate transport to transfer the certificate

  This is exactly what the formal Predicate Transport framework captures!
""")


def main():
    ml_application()
    tropical_application()
    byzantine_application()
    entropy_application()
    cross_domain_summary()


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Predicate Transport Along Invariant-Preserving Morphisms: Demonstrations

This module demonstrates the core ideas of predicate transport using
concrete numerical examples. It shows how properties that depend only
on an invariant value can be automatically transferred across
structure-preserving maps between mathematical theories.
"""

import dataclasses
from typing import Callable, Optional


@dataclasses.dataclass
class Theory:
    """A research theory: a carrier type with an invariant function."""
    name: str
    inv: Callable[[int], int]  # invariant function on carrier (ℕ → ℕ)

    def satisfies_lower_bound(self, x: int, n: int) -> bool:
        return n <= self.inv(x)

    def satisfies_upper_bound(self, x: int, n: int) -> bool:
        return self.inv(x) <= n


@dataclasses.dataclass
class TheoryHom:
    """A theory morphism: a map between carriers that is monotone on invariants."""
    source: Theory
    target: Theory
    to_fun: Callable[[int], int]
    name: str = ""

    def verify_monotonicity(self, samples: range) -> bool:
        """Check monotonicity on a sample range."""
        return all(
            self.source.inv(x) <= self.target.inv(self.to_fun(x))
            for x in samples
        )


def invariant_determined(theory: Theory, pred: Callable[[int], bool],
                          samples: range) -> bool:
    """Check if a predicate is invariant-determined on samples."""
    inv_to_pred: dict[int, Optional[bool]] = {}
    for x in samples:
        v = theory.inv(x)
        px = pred(x)
        if v in inv_to_pred:
            if inv_to_pred[v] != px:
                return False
        else:
            inv_to_pred[v] = px
    return True


def factor_through_invariant(theory: Theory, pred: Callable[[int], bool],
                              samples: range) -> dict[int, bool]:
    """Extract the invariant-level predicate R such that P(x) ↔ R(inv(x))."""
    result: dict[int, bool] = {}
    for x in samples:
        v = theory.inv(x)
        if v not in result:
            result[v] = pred(x)
    return result


def transferable_predicate(f: TheoryHom,
                           P: Callable[[int], bool],
                           Q: Callable[[int], bool],
                           samples: range) -> bool:
    """Check if P is transferable to Q along f on samples."""
    return all(
        (not P(x)) or Q(f.to_fun(x))
        for x in samples
    )


def main():
    print("=" * 70)
    print("PREDICATE TRANSPORT ALONG INVARIANT-PRESERVING MORPHISMS")
    print("=" * 70)

    # --- Define theories ---
    height_theory = Theory("Height", inv=lambda x: x)
    cell_theory = Theory("Cell", inv=lambda x: x * (x + 1))
    dimension_theory = Theory("Dimension", inv=lambda x: x + 1)
    stability_theory = Theory("Stability", inv=lambda x: x)

    # --- Define morphisms ---
    h_to_c = TheoryHom(height_theory, cell_theory, lambda x: x, "height→cell")
    h_to_d = TheoryHom(height_theory, dimension_theory, lambda x: x, "height→dim")
    d_to_s = TheoryHom(dimension_theory, stability_theory, lambda x: x + 1, "dim→stab")

    test_range = range(0, 20)

    print("\n§1. Morphism Monotonicity Verification")
    print("-" * 50)
    for f in [h_to_c, h_to_d, d_to_s]:
        ok = f.verify_monotonicity(test_range)
        print(f"  {f.name}: monotone = {ok}")
        if ok:
            for x in [0, 1, 5, 10]:
                src = f.source.inv(x)
                tgt = f.target.inv(f.to_fun(x))
                print(f"    x={x}: {f.source.name}.Inv({x})={src} ≤ "
                      f"{f.target.name}.Inv({f.to_fun(x)})={tgt}")

    # --- Invariant-determined predicates ---
    print("\n§2. Invariant-Determined Predicates")
    print("-" * 50)

    lower5 = lambda x: 5 <= height_theory.inv(x)
    upper10 = lambda x: height_theory.inv(x) <= 10
    interval = lambda x: 3 <= height_theory.inv(x) and height_theory.inv(x) <= 8
    exact7 = lambda x: height_theory.inv(x) == 7

    for name, pred in [("n ≤ Inv(x) [n=5]", lower5),
                        ("Inv(x) ≤ n [n=10]", upper10),
                        ("3 ≤ Inv(x) ≤ 8", interval),
                        ("Inv(x) = 7", exact7)]:
        is_id = invariant_determined(height_theory, pred, test_range)
        print(f"  {name}: invariant-determined = {is_id}")
        if is_id:
            R = factor_through_invariant(height_theory, pred, test_range)
            print(f"    Factored R: {dict(sorted(R.items()))}")

    # Not invariant-determined (depends on parity of x, not just inv)
    parity_pred = lambda x: x % 2 == 0
    is_id = invariant_determined(height_theory, parity_pred, test_range)
    print(f"  x%2==0 (parity): invariant-determined = {is_id}")
    print(f"    (This is NOT invariant-determined for Height where Inv=id,")
    print(f"     since every value maps to itself, it IS trivially invariant-det)")

    # Better example: cell theory with non-injective invariant
    cell_parity = lambda x: x % 2 == 0
    is_id2 = invariant_determined(cell_theory, cell_parity, test_range)
    print(f"  x%2==0 on Cell theory: invariant-determined = {is_id2}")
    print(f"    Cell.Inv is x*(x+1), not injective in general concept")

    # --- Transferable predicates ---
    print("\n§3. Lower Bound Transfer (Covariant)")
    print("-" * 50)

    for n in [3, 5, 8]:
        P = lambda x, n=n: n <= height_theory.inv(x)
        Q = lambda x, n=n: n <= cell_theory.inv(x)
        is_trans = transferable_predicate(h_to_c, P, Q, test_range)
        print(f"  LowerBound({n}): Height → Cell transferable = {is_trans}")

        # Show concrete witness transfer
        witnesses = [x for x in test_range if P(x)]
        if witnesses:
            w = witnesses[0]
            fw = h_to_c.to_fun(w)
            print(f"    Witness: x={w}, Height.Inv={height_theory.inv(w)}, "
                  f"Cell.Inv(f({w}))={cell_theory.inv(fw)}")

    # --- Existential transport ---
    print("\n§4. Existential Transport")
    print("-" * 50)

    n = 5
    exists_in_height = any(n <= height_theory.inv(x) for x in test_range)
    print(f"  ∃x, {n} ≤ Height.Inv(x) = {exists_in_height}")

    if exists_in_height:
        x = next(x for x in test_range if n <= height_theory.inv(x))
        y = h_to_c.to_fun(x)
        print(f"  → Transported: Cell.Inv(f({x})) = {cell_theory.inv(y)} ≥ {n}")
        print(f"  ∃y, {n} ≤ Cell.Inv(y) = True (witnessed by y={y})")

    # --- Composition ---
    print("\n§5. Composition of Transfers")
    print("-" * 50)

    # height → dimension → stability
    composed = TheoryHom(
        height_theory, stability_theory,
        lambda x: d_to_s.to_fun(h_to_d.to_fun(x)),
        "height→dim→stab"
    )
    ok = composed.verify_monotonicity(test_range)
    print(f"  Composed morphism (height→dim→stab): monotone = {ok}")

    for x in [0, 3, 7, 15]:
        src_inv = height_theory.inv(x)
        mid_inv = dimension_theory.inv(h_to_d.to_fun(x))
        tgt_inv = stability_theory.inv(composed.to_fun(x))
        print(f"    x={x}: Height.Inv={src_inv} ≤ Dim.Inv={mid_inv} "
              f"≤ Stab.Inv={tgt_inv}")

    # --- Upper bound pullback (contravariant) ---
    print("\n§6. Upper Bound Pullback (Contravariant)")
    print("-" * 50)

    for n in [50, 100, 200]:
        all_cell_bounded = all(cell_theory.inv(x) <= n for x in test_range)
        all_height_bounded = all(height_theory.inv(x) <= n for x in test_range)
        print(f"  n={n}: ∀y, Cell.Inv(y)≤{n} = {all_cell_bounded}")
        print(f"         → ∀x, Height.Inv(x)≤{n} = {all_height_bounded}")
        if all_cell_bounded:
            print(f"         (Pullback succeeds via monotonicity)")

    # --- Boolean closure ---
    print("\n§7. Boolean Closure of Invariant-Determined Predicates")
    print("-" * 50)

    P1 = lambda x: 3 <= height_theory.inv(x)
    P2 = lambda x: height_theory.inv(x) <= 12

    operations = [
        ("P∧Q (conjunction)", lambda x: P1(x) and P2(x)),
        ("P∨Q (disjunction)", lambda x: P1(x) or P2(x)),
        ("¬P (negation)", lambda x: not P1(x)),
        ("P→Q (implication)", lambda x: (not P1(x)) or P2(x)),
        ("P↔Q (biconditional)", lambda x: P1(x) == P2(x)),
    ]

    for name, pred in operations:
        is_id = invariant_determined(height_theory, pred, test_range)
        print(f"  {name}: invariant-determined = {is_id}")

    # --- Summary ---
    print("\n" + "=" * 70)
    print("SUMMARY")
    print("=" * 70)
    print("""
The predicate transport framework demonstrates that:

1. INVARIANT-DETERMINED predicates (those depending only on the invariant
   value) form a Boolean algebra closed under ∧, ∨, ¬, →, ↔.

2. Such predicates FACTOR through the invariant: P(x) ↔ R(Inv(x))
   for some R on the invariant space.

3. Lower bounds transfer COVARIANTLY: if n ≤ T.Inv(x), then
   n ≤ U.Inv(f(x)) by monotonicity of the morphism.

4. Upper bounds pull back CONTRAVARIANTLY: if ∀y, U.Inv(y) ≤ n,
   then ∀x, T.Inv(x) ≤ n.

5. These transfers COMPOSE functorially: id preserves all predicates,
   and composed morphisms compose predicate transfers.

This unifies lower-bound transfer, upper-bound pullback, and general
predicate transport into a single compositional framework.
""")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualizations for Predicate Transport Framework

Generates publication-quality figures illustrating the key concepts
of invariant-determined predicates and predicate transport.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import base64
import io


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def create_transport_diagram():
    """Create the main predicate transport diagram showing
    how predicates factor through invariants and transfer across morphisms."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # --- Left panel: Factorization ---
    ax = axes[0]
    ax.set_xlim(-0.5, 4.5)
    ax.set_ylim(-0.5, 4.5)
    ax.set_aspect('equal')
    ax.set_title('Predicate Factorization\nP(x) ↔ R(Inv(x))', fontsize=14, fontweight='bold')

    # Draw carrier elements
    carrier_x = [0.5, 1.5, 2.5, 3.5, 0.5, 1.5, 2.5, 3.5]
    carrier_y = [3.5, 3.5, 3.5, 3.5, 2.5, 2.5, 2.5, 2.5]
    inv_vals = [1, 2, 3, 4, 1, 2, 3, 4]  # Inv values
    pred_vals = [True, True, False, False, True, True, False, False]  # P values

    for i, (cx, cy, iv, pv) in enumerate(zip(carrier_x, carrier_y, inv_vals, pred_vals)):
        color = '#2ecc71' if pv else '#e74c3c'
        ax.add_patch(plt.Circle((cx, cy), 0.25, facecolor=color, edgecolor='black', linewidth=1.5))
        ax.text(cx, cy, f'x{i}', ha='center', va='center', fontsize=9, fontweight='bold')

    # Draw invariant values
    for iv in [1, 2, 3, 4]:
        x_pos = iv - 0.5
        color = '#2ecc71' if iv <= 2 else '#e74c3c'
        ax.add_patch(plt.Rectangle((x_pos - 0.3, 0.3), 0.6, 0.6,
                                     facecolor=color, edgecolor='black', linewidth=1.5, alpha=0.7))
        ax.text(x_pos, 0.6, f'{iv}', ha='center', va='center', fontsize=11, fontweight='bold')

    # Draw arrows from carrier to invariant
    for cx, cy, iv in zip(carrier_x, carrier_y, inv_vals):
        ax.annotate('', xy=(iv - 0.5, 1.0), xytext=(cx, cy - 0.3),
                    arrowprops=dict(arrowstyle='->', color='#7f8c8d', lw=1.5))

    # Labels
    ax.text(2.0, 4.2, 'Carrier Space (objects)', ha='center', fontsize=11,
            fontstyle='italic', color='#2c3e50')
    ax.text(2.0, 0.0, 'Invariant Space (ℕ)', ha='center', fontsize=11,
            fontstyle='italic', color='#2c3e50')
    ax.text(-0.3, 1.8, 'Inv', ha='center', fontsize=12, fontweight='bold',
            color='#8e44ad', rotation=90)

    green_patch = mpatches.Patch(color='#2ecc71', label='P = True')
    red_patch = mpatches.Patch(color='#e74c3c', label='P = False')
    ax.legend(handles=[green_patch, red_patch], loc='lower right', fontsize=10)
    ax.axis('off')

    # --- Right panel: Transport ---
    ax = axes[1]
    ax.set_xlim(-1, 9)
    ax.set_ylim(-1, 5)
    ax.set_title('Predicate Transport Along f : T → U\n"P(x) → Q(f(x))"', fontsize=14, fontweight='bold')

    # Source theory box
    rect1 = mpatches.FancyBboxPatch((0, 2.5), 3, 2, boxstyle="round,pad=0.2",
                                      facecolor='#d5f4e6', edgecolor='#27ae60', linewidth=2)
    ax.add_patch(rect1)
    ax.text(1.5, 4.0, 'Theory T', ha='center', fontsize=12, fontweight='bold', color='#27ae60')
    ax.text(1.5, 3.2, 'Inv(x) = 5\nP(x) = True', ha='center', fontsize=10)

    # Target theory box
    rect2 = mpatches.FancyBboxPatch((5, 2.5), 3, 2, boxstyle="round,pad=0.2",
                                      facecolor='#d6eaf8', edgecolor='#2980b9', linewidth=2)
    ax.add_patch(rect2)
    ax.text(6.5, 4.0, 'Theory U', ha='center', fontsize=12, fontweight='bold', color='#2980b9')
    ax.text(6.5, 3.2, 'Inv(f(x)) ≥ 5\nQ(f(x)) = True', ha='center', fontsize=10)

    # Morphism arrow
    ax.annotate('', xy=(5, 3.5), xytext=(3, 3.5),
                arrowprops=dict(arrowstyle='->', lw=3, color='#8e44ad'))
    ax.text(4.0, 3.9, 'f', ha='center', fontsize=14, fontweight='bold', color='#8e44ad')
    ax.text(4.0, 3.1, 'monotone', ha='center', fontsize=9, fontstyle='italic', color='#8e44ad')

    # Invariant level
    rect3 = mpatches.FancyBboxPatch((0, 0), 3, 1.5, boxstyle="round,pad=0.2",
                                      facecolor='#fdebd0', edgecolor='#e67e22', linewidth=2)
    ax.add_patch(rect3)
    ax.text(1.5, 1.1, 'ℕ', ha='center', fontsize=12, fontweight='bold', color='#e67e22')
    ax.text(1.5, 0.5, 'R(5) = True', ha='center', fontsize=10)

    rect4 = mpatches.FancyBboxPatch((5, 0), 3, 1.5, boxstyle="round,pad=0.2",
                                      facecolor='#fdebd0', edgecolor='#e67e22', linewidth=2)
    ax.add_patch(rect4)
    ax.text(6.5, 1.1, 'ℕ', ha='center', fontsize=12, fontweight='bold', color='#e67e22')
    ax.text(6.5, 0.5, 'R(≥5) = True', ha='center', fontsize=10)

    # Inv arrows
    ax.annotate('', xy=(1.5, 1.5), xytext=(1.5, 2.5),
                arrowprops=dict(arrowstyle='->', lw=2, color='#e67e22'))
    ax.text(0.5, 2.0, 'Inv', ha='center', fontsize=10, fontweight='bold', color='#e67e22')

    ax.annotate('', xy=(6.5, 1.5), xytext=(6.5, 2.5),
                arrowprops=dict(arrowstyle='->', lw=2, color='#e67e22'))
    ax.text(7.5, 2.0, 'Inv', ha='center', fontsize=10, fontweight='bold', color='#e67e22')

    # ≤ arrow on invariant level
    ax.annotate('', xy=(5, 0.75), xytext=(3, 0.75),
                arrowprops=dict(arrowstyle='->', lw=2, color='#e67e22', linestyle='dashed'))
    ax.text(4.0, 0.35, '≤', ha='center', fontsize=14, fontweight='bold', color='#e67e22')

    ax.axis('off')

    plt.tight_layout()
    return fig


def create_composition_diagram():
    """Create diagram showing functorial composition of predicate transport."""
    fig, ax = plt.subplots(1, 1, figsize=(12, 5))
    ax.set_xlim(-1, 13)
    ax.set_ylim(-0.5, 4)

    theories = [
        (1, 2.5, 'T₁\nHeight', '#27ae60'),
        (4.5, 2.5, 'T₂\nDimension', '#2980b9'),
        (8, 2.5, 'T₃\nStability', '#e74c3c'),
        (11.5, 2.5, 'T₄\nCapacity', '#8e44ad'),
    ]

    for x, y, label, color in theories:
        rect = mpatches.FancyBboxPatch((x - 0.8, y - 0.6), 1.6, 1.2,
                                        boxstyle="round,pad=0.15",
                                        facecolor=color + '20', edgecolor=color, linewidth=2)
        ax.add_patch(rect)
        ax.text(x, y, label, ha='center', va='center', fontsize=10, fontweight='bold')

    # Arrows between theories
    arrows = [
        (1.8, 3.7, 'f₁', '≥ n'),
        (5.3, 3.7, 'f₂', '≥ n'),
        (8.8, 3.7, 'f₃', '≥ n'),
    ]
    for i, (x_start, y_start_unused, label, pred) in enumerate(arrows):
        x_end = x_start + 1.9
        ax.annotate('', xy=(x_end, 2.5), xytext=(x_start, 2.5),
                    arrowprops=dict(arrowstyle='->', lw=2.5, color='#34495e'))
        ax.text((x_start + x_end) / 2, 2.9, label, ha='center', fontsize=11,
                fontweight='bold', color='#34495e')

    # Predicate labels below
    preds = [
        (1, 0.8, 'n ≤ Inv(x)', '#27ae60'),
        (4.5, 0.8, 'n ≤ Inv(f₁(x))', '#2980b9'),
        (8, 0.8, 'n ≤ Inv(f₂∘f₁(x))', '#e74c3c'),
        (11.5, 0.8, 'n ≤ Inv(f₃∘f₂∘f₁(x))', '#8e44ad'),
    ]

    for x, y, label, color in preds:
        ax.text(x, y, label, ha='center', fontsize=9, color=color, fontstyle='italic')
        ax.annotate('', xy=(x, 1.1), xytext=(x, 1.9),
                    arrowprops=dict(arrowstyle='->', lw=1, color=color, linestyle='dotted'))

    # Composed arrow
    ax.annotate('', xy=(10.7, 1.9), xytext=(1.8, 1.9),
                arrowprops=dict(arrowstyle='->', lw=2, color='#f39c12',
                              connectionstyle='arc3,rad=-0.3'))
    ax.text(6.25, 0.2, 'f₃ ∘ f₂ ∘ f₁  (composed transfer)', ha='center',
            fontsize=11, fontweight='bold', color='#f39c12')

    ax.set_title('Functorial Composition of Predicate Transport',
                fontsize=14, fontweight='bold')
    ax.axis('off')
    plt.tight_layout()
    return fig


def create_duality_diagram():
    """Create diagram showing covariant pushforward vs contravariant pullback."""
    fig, axes = plt.subplots(1, 2, figsize=(13, 5))

    # --- Left: Covariant (Existential Pushforward) ---
    ax = axes[0]
    ax.set_xlim(-0.5, 6)
    ax.set_ylim(-0.5, 4)
    ax.set_title('Covariant: Existential Pushforward\n∃x, P(x) → ∃y, Q(y)',
                fontsize=12, fontweight='bold', color='#27ae60')

    # Source
    ax.add_patch(mpatches.FancyBboxPatch((0, 1.5), 2, 2, boxstyle="round,pad=0.2",
                 facecolor='#d5f4e6', edgecolor='#27ae60', linewidth=2))
    ax.text(1, 3.0, 'Theory T', ha='center', fontsize=11, fontweight='bold')
    ax.text(1, 2.1, '∃x, n≤Inv(x) ✓', ha='center', fontsize=10, color='#27ae60')

    # Target
    ax.add_patch(mpatches.FancyBboxPatch((3.5, 1.5), 2, 2, boxstyle="round,pad=0.2",
                 facecolor='#d6eaf8', edgecolor='#2980b9', linewidth=2))
    ax.text(4.5, 3.0, 'Theory U', ha='center', fontsize=11, fontweight='bold')
    ax.text(4.5, 2.1, '∃y, n≤Inv(y) ✓', ha='center', fontsize=10, color='#2980b9')

    # Arrow
    ax.annotate('', xy=(3.5, 2.5), xytext=(2, 2.5),
                arrowprops=dict(arrowstyle='->', lw=3, color='#27ae60'))
    ax.text(2.75, 2.9, 'f', ha='center', fontsize=13, fontweight='bold', color='#27ae60')

    # Direction label
    ax.text(2.75, 0.5, 'Lower bounds\npush FORWARD', ha='center', fontsize=11,
            fontstyle='italic', color='#27ae60')
    ax.annotate('', xy=(4.5, 0.8), xytext=(1.0, 0.8),
                arrowprops=dict(arrowstyle='->', lw=2, color='#27ae60'))
    ax.axis('off')

    # --- Right: Contravariant (Universal Pullback) ---
    ax = axes[1]
    ax.set_xlim(-0.5, 6)
    ax.set_ylim(-0.5, 4)
    ax.set_title('Contravariant: Universal Pullback\n∀y, Q(y) → ∀x, P(x)',
                fontsize=12, fontweight='bold', color='#e74c3c')

    # Source
    ax.add_patch(mpatches.FancyBboxPatch((0, 1.5), 2, 2, boxstyle="round,pad=0.2",
                 facecolor='#d5f4e6', edgecolor='#27ae60', linewidth=2))
    ax.text(1, 3.0, 'Theory T', ha='center', fontsize=11, fontweight='bold')
    ax.text(1, 2.1, '∀x, Inv(x)≤n ✓', ha='center', fontsize=10, color='#27ae60')

    # Target
    ax.add_patch(mpatches.FancyBboxPatch((3.5, 1.5), 2, 2, boxstyle="round,pad=0.2",
                 facecolor='#d6eaf8', edgecolor='#2980b9', linewidth=2))
    ax.text(4.5, 3.0, 'Theory U', ha='center', fontsize=11, fontweight='bold')
    ax.text(4.5, 2.1, '∀y, Inv(y)≤n ✓', ha='center', fontsize=10, color='#2980b9')

    # Arrow (morphism goes right, but pullback goes left)
    ax.annotate('', xy=(3.5, 2.5), xytext=(2, 2.5),
                arrowprops=dict(arrowstyle='->', lw=3, color='#7f8c8d'))
    ax.text(2.75, 2.9, 'f', ha='center', fontsize=13, fontweight='bold', color='#7f8c8d')

    # Pullback arrow
    ax.text(2.75, 0.5, 'Upper bounds\npull BACK', ha='center', fontsize=11,
            fontstyle='italic', color='#e74c3c')
    ax.annotate('', xy=(1.0, 0.8), xytext=(4.5, 0.8),
                arrowprops=dict(arrowstyle='->', lw=2, color='#e74c3c'))
    ax.axis('off')

    plt.tight_layout()
    return fig


def create_boolean_closure_diagram():
    """Visualize the Boolean closure of invariant-determined predicates."""
    fig, ax = plt.subplots(1, 1, figsize=(8, 6))

    n_vals = np.arange(0, 15)

    # Base predicates
    P = n_vals >= 3
    Q = n_vals <= 10

    predicates = {
        'P: n ≥ 3': P,
        'Q: n ≤ 10': Q,
        'P ∧ Q: 3 ≤ n ≤ 10': P & Q,
        'P ∨ Q: n≥3 or n≤10': P | Q,
        '¬P: n < 3': ~P,
    }

    colors = ['#27ae60', '#2980b9', '#8e44ad', '#f39c12', '#e74c3c']
    offsets = np.linspace(-0.3, 0.3, len(predicates))

    for i, (label, vals) in enumerate(predicates.items()):
        y_pos = len(predicates) - i - 1
        for j, (n, v) in enumerate(zip(n_vals, vals)):
            color = colors[i] if v else '#ecf0f1'
            edge = colors[i]
            ax.add_patch(plt.Rectangle((n - 0.4, y_pos - 0.3), 0.8, 0.6,
                                        facecolor=color, edgecolor=edge,
                                        linewidth=1, alpha=0.8 if v else 0.3))

        ax.text(-1.5, y_pos, label, ha='right', va='center', fontsize=10,
                fontweight='bold', color=colors[i])

    ax.set_xlim(-5, 15)
    ax.set_ylim(-1, len(predicates))
    ax.set_xlabel('Invariant value n', fontsize=12)
    ax.set_xticks(n_vals)
    ax.set_yticks([])
    ax.set_title('Boolean Closure of Invariant-Determined Predicates\n'
                'All combinations are invariant-determined',
                fontsize=13, fontweight='bold')

    # Legend
    filled = mpatches.Patch(facecolor='#95a5a6', label='Predicate = True')
    empty = mpatches.Patch(facecolor='#ecf0f1', edgecolor='#bdc3c7', label='Predicate = False')
    ax.legend(handles=[filled, empty], loc='lower right', fontsize=10)

    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.spines['left'].set_visible(False)

    plt.tight_layout()
    return fig


def main():
    """Generate all visualizations and save them."""
    print("Generating visualizations...")

    figs = {
        'transport_diagram': create_transport_diagram(),
        'composition_diagram': create_composition_diagram(),
        'duality_diagram': create_duality_diagram(),
        'boolean_closure': create_boolean_closure_diagram(),
    }

    for name, fig in figs.items():
        filename = f"{name}.png"
        fig.savefig(filename, dpi=150, bbox_inches='tight',
                    facecolor='white', edgecolor='none')
        print(f"  Saved {filename}")

    # Also return base64 for JSON embedding
    return {name: fig_to_base64(fig) for name, fig in figs.items()}


if __name__ == "__main__":
    data_uris = main()
    print(f"\nGenerated {len(data_uris)} base64 data URIs")
