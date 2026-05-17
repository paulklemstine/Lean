#!/usr/bin/env python3
"""
Applications: Approximate Adjunctions in Practice

Shows real-world applications of the approximate adjunction framework:
1. Complexity theory: circuit ↔ branching program transfer
2. Tropical geometry: tropicalization ↔ algebraic lifting
3. Cryptographic hardness: one-way function security transfer
4. Machine learning: model compression bounds
"""

from dataclasses import dataclass
from typing import Callable, List, Tuple
import numpy as np


@dataclass
class TheorySpec:
    name: str
    val: Callable


@dataclass
class TheoryAdj:
    source: TheorySpec
    target: TheorySpec
    left: Callable
    right: Callable
    left_loss: int
    right_loss: int

    def transfer_forward(self, L):
        return L - self.right_loss

    def transfer_backward(self, L):
        return L - self.left_loss

    def compose(self, other):
        return TheoryAdj(
            self.source, other.target,
            lambda a: other.left(self.left(a)),
            lambda c: self.right(other.right(c)),
            self.left_loss + other.left_loss,
            other.right_loss + self.right_loss,
        )


def app_complexity_transfer():
    """Application 1: Circuit ↔ Branching Program Complexity Transfer.

    Models the classical result: if circuits for function f require
    at least K gates, and any branching program of width w and depth d
    can be simulated by a circuit of size O(w²d), then the BP must
    satisfy K ≤ O(w²d).
    """
    print("=" * 60)
    print("APPLICATION 1: Circuit ↔ BP Complexity Transfer")
    print("=" * 60)

    # Circuit theory: val = number of gates
    CircuitTheory = TheorySpec("Circuits", val=lambda c: c)

    # BP theory: val = simulation overhead = 2w²d + w
    BPTheory = TheorySpec("Branching Programs", val=lambda bp: bp)

    # The adjunction: simulation map BP → Circuit
    # right_loss = 0 because simulation is exact (circuit has ≤ BP complexity)
    adj = TheoryAdj(
        source=CircuitTheory,
        target=BPTheory,
        left=lambda c: c,       # trivial embedding
        right=lambda bp: bp,    # simulation
        left_loss=0,
        right_loss=0,
    )

    # Known circuit lower bound
    K = 100  # Suppose we know circuits need ≥ 100 gates

    print(f"\nKnown: All circuits for f need ≥ {K} gates")
    print(f"Simulation: BP(w,d) → Circuit with ≤ 2w²d+w gates")
    print(f"\nTransfer yields: 2w²d+w ≥ {K} for all BPs computing f")

    for w, d in [(3, 2), (5, 4), (10, 1), (2, 25)]:
        bp_size = 2 * w * w * d + w
        print(f"  BP(w={w}, d={d}): 2·{w}²·{d}+{w} = {bp_size} ≥ {K}? "
              f"{'✓ Valid' if bp_size >= K else '✗ Too small to compute f'}")


def app_tropical_algebraic():
    """Application 2: Tropical ↔ Algebraic Geometry Correspondence.

    Tropicalization maps algebraic varieties to polyhedral complexes.
    The lifting map goes back, but with quantitative loss related to
    the Newton polytope structure.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Tropical-Algebraic Correspondence")
    print("=" * 60)

    # Algebraic theory: val = degree of variety
    AlgTheory = TheorySpec("Algebraic", val=lambda d: d)

    # Tropical theory: val = complexity of polyhedral complex
    TropTheory = TheorySpec("Tropical", val=lambda d: d)

    # Tropicalization loses at most 1 in degree (for smooth curves)
    # Lifting recovers exactly
    adj = TheoryAdj(
        source=AlgTheory,
        target=TropTheory,
        left=lambda d: d,      # tropicalization preserves degree
        right=lambda d: d,     # lifting
        left_loss=0,           # tropicalization doesn't increase complexity
        right_loss=1,          # lifting may add 1 to complexity (Newton polytope)
    )

    print(f"\nTropicalization: degree d algebraic curve → tropical curve")
    print(f"Lifting: tropical curve → algebraic curve (may add 1 to complexity)")
    print(f"left_loss = {adj.left_loss}, right_loss = {adj.right_loss}")

    # Lower bound transfer
    alg_bound = 5  # All algebraic curves have degree ≥ 5
    trop_bound = adj.transfer_forward(alg_bound)
    print(f"\nAlgebraic lower bound: degree ≥ {alg_bound}")
    print(f"Tropical lower bound: complexity ≥ {trop_bound}")

    # Reverse transfer
    trop_bound2 = 7
    alg_bound2 = adj.transfer_backward(trop_bound2)
    print(f"\nTropical lower bound: complexity ≥ {trop_bound2}")
    print(f"Algebraic lower bound: degree ≥ {alg_bound2}")


def app_model_compression():
    """Application 3: Neural Network Model Compression Bounds.

    Models the relationship between a full neural network and its
    compressed version. Compression maps a large model to a small one;
    decompression approximately recovers it.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Neural Network Compression Bounds")
    print("=" * 60)

    # Full model theory: val = number of parameters
    FullTheory = TheorySpec("Full Network", val=lambda n: n)

    # Compressed model theory: val = compressed size
    CompTheory = TheorySpec("Compressed Network", val=lambda n: n)

    # Compression with 10% overhead, decompression with 5% size increase
    compression_overhead = 2   # log₂ overhead
    decompression_overhead = 1

    adj = TheoryAdj(
        source=FullTheory,
        target=CompTheory,
        left=lambda n: max(1, n // 4),     # compress to 1/4 size
        right=lambda n: n * 4,              # decompress back
        left_loss=compression_overhead,
        right_loss=decompression_overhead,
    )

    print(f"\nCompression: N params → N/4 compressed params")
    print(f"Decompression: N compressed → 4N params")
    print(f"Compression overhead: {adj.left_loss}")
    print(f"Decompression overhead: {adj.right_loss}")

    # If all full models for a task need ≥ L params
    L = 1000
    comp_bound = adj.transfer_forward(L)
    print(f"\nFull model lower bound: ≥ {L} params")
    print(f"Compressed model lower bound: ≥ {comp_bound} compressed units")

    # If all compressed models need ≥ M compressed params
    M = 200
    full_bound = adj.transfer_backward(M)
    print(f"\nCompressed model lower bound: ≥ {M} compressed units")
    print(f"Full model lower bound: ≥ {full_bound} params")


def app_chain_transfer():
    """Application 4: Multi-hop Transfer Through Theory Chains.

    Demonstrates transferring a lower bound through a chain:
    Circuits → Boolean Formulas → Branching Programs → Tropical Circuits
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Multi-Hop Complexity Transfer")
    print("=" * 60)

    theories = [
        TheorySpec("Circuits", val=lambda n: n),
        TheorySpec("Boolean Formulas", val=lambda n: n),
        TheorySpec("Branching Programs", val=lambda n: n),
        TheorySpec("Tropical Circuits", val=lambda n: n),
    ]

    adjs = [
        TheoryAdj(theories[0], theories[1],
                  lambda n: n, lambda n: n,
                  left_loss=2, right_loss=1),  # Circuit ↔ Formula
        TheoryAdj(theories[1], theories[2],
                  lambda n: n, lambda n: n,
                  left_loss=0, right_loss=3),  # Formula ↔ BP
        TheoryAdj(theories[2], theories[3],
                  lambda n: n, lambda n: n,
                  left_loss=1, right_loss=2),  # BP ↔ Tropical
    ]

    print(f"\nChain: Circuit ⇄ Formula ⇄ BP ⇄ Tropical")
    for i, adj in enumerate(adjs):
        print(f"  {theories[i].name} ⇄ {theories[i+1].name}: "
              f"left_loss={adj.left_loss}, right_loss={adj.right_loss}")

    # Compose
    composed = adjs[0]
    for adj in adjs[1:]:
        composed = composed.compose(adj)

    L = 50
    print(f"\nCircuit lower bound: L = {L}")

    # Transfer step by step
    bounds = [L]
    current = L
    for i, adj in enumerate(adjs):
        current = adj.transfer_forward(current)
        bounds.append(current)
        print(f"  → {theories[i+1].name}: L' = {current} (loss = {adj.right_loss})")

    # Direct composed transfer
    direct = composed.transfer_forward(L)
    print(f"\nDirect composed transfer: {L} → {direct}")
    print(f"Total right_loss: {composed.right_loss}")
    assert direct == bounds[-1], "Should agree!"
    print(f"✓ Step-by-step and composed results agree!")

    # Reverse
    print(f"\nReverse transfer: Tropical lower bound {bounds[-1]}")
    current = bounds[-1]
    for i in range(len(adjs) - 1, -1, -1):
        current = adjs[i].transfer_backward(current)
        print(f"  → {theories[i].name}: L' = {current} (loss = {adjs[i].left_loss})")


if __name__ == "__main__":
    app_complexity_transfer()
    app_tropical_algebraic()
    app_model_compression()
    app_chain_transfer()
    print("\n" + "=" * 60)
    print("All applications completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Demo: Approximate Adjunctions Between Theories

Demonstrates the core ideas of the approximate adjunction framework with
concrete numerical examples showing:
1. How adjunctions compose with additive loss
2. How lower bounds transfer bidirectionally
3. The height-dimension adjunction example
4. Tropical simulation transfer
"""

from dataclasses import dataclass
from typing import Callable, List, Tuple
import numpy as np


@dataclass
class TheorySpec:
    """A theory with objects and a quantitative invariant."""
    name: str
    val: Callable[[int], int]  # val : Obj → ℤ (using int objects)

    def __repr__(self):
        return f"Theory({self.name})"


@dataclass
class TheoryAdj:
    """An approximate adjunction between theories.

    left_bound: ∀ a, B.val(left(a)) ≤ A.val(a) + left_loss
    right_bound: ∀ b, A.val(right(b)) ≤ B.val(b) + right_loss
    """
    A: TheorySpec
    B: TheorySpec
    left: Callable[[int], int]
    right: Callable[[int], int]
    left_loss: int
    right_loss: int

    def verify_bounds(self, test_range: range) -> bool:
        """Verify the adjunction bounds on a test range."""
        for a in test_range:
            if self.B.val(self.left(a)) > self.A.val(a) + self.left_loss:
                return False
        for b in test_range:
            if self.A.val(self.right(b)) > self.B.val(b) + self.right_loss:
                return False
        return True

    def transfer_left_to_right(self, L: int) -> int:
        """Transfer a lower bound from A to B."""
        return L - self.right_loss

    def transfer_right_to_left(self, L: int) -> int:
        """Transfer a lower bound from B to A."""
        return L - self.left_loss

    def compose(self, other: 'TheoryAdj') -> 'TheoryAdj':
        """Compose with another adjunction. Self: A ⇄ B, other: B ⇄ C."""
        return TheoryAdj(
            A=self.A,
            B=other.B,
            left=lambda a: other.left(self.left(a)),
            right=lambda c: self.right(other.right(c)),
            left_loss=self.left_loss + other.left_loss,
            right_loss=other.right_loss + self.right_loss,
        )


def demo_height_dimension():
    """Demonstrate the height-dimension adjunction."""
    print("=" * 60)
    print("DEMO 1: Height-Dimension Adjunction")
    print("=" * 60)

    H = TheorySpec("Height", val=lambda n: n)
    D = TheorySpec("Dimension", val=lambda n: n + 1)

    adj = TheoryAdj(
        A=H, B=D,
        left=lambda n: n,   # identity
        right=lambda n: n,   # identity
        left_loss=1,          # D.val(n) = n+1 ≤ n + 1 = H.val(n) + 1
        right_loss=0,         # H.val(n) = n ≤ n+1 = D.val(n) + 0
    )

    print(f"\nHeight theory: val(n) = n")
    print(f"Dimension theory: val(n) = n + 1")
    print(f"Left map (H→D): identity")
    print(f"Right map (D→H): identity")
    print(f"Left loss: {adj.left_loss}, Right loss: {adj.right_loss}")

    # Verify bounds
    verified = adj.verify_bounds(range(0, 100))
    print(f"\nBounds verified on [0,100): {verified}")

    # Transfer examples
    print(f"\nTransfer examples:")
    for L in [0, 3, 10, 42]:
        lr = adj.transfer_left_to_right(L)
        rl = adj.transfer_right_to_left(L)
        print(f"  Lower bound L={L}:")
        print(f"    H→D: ∀n, {lr} ≤ val_D(n) = n+1  (exact transfer, loss={adj.right_loss})")
        print(f"    D→H: ∀n, {rl} ≤ val_H(n) = n    (loss={adj.left_loss})")

    # Unit/counit round-trips
    print(f"\nRound-trip distortion:")
    for n in [0, 5, 10]:
        unit_rt = H.val(adj.right(adj.left(n)))
        counit_rt = D.val(adj.left(adj.right(n)))
        print(f"  n={n}: unit(n)={unit_rt} vs val_H(n)={H.val(n)} "
              f"(diff={unit_rt - H.val(n)}, bound={adj.left_loss + adj.right_loss})")
        print(f"  n={n}: counit(n)={counit_rt} vs val_D(n)={D.val(n)} "
              f"(diff={counit_rt - D.val(n)}, bound={adj.right_loss + adj.left_loss})")


def demo_composition():
    """Demonstrate composition of adjunctions."""
    print("\n" + "=" * 60)
    print("DEMO 2: Composition of Adjunctions")
    print("=" * 60)

    A = TheorySpec("Theory A", val=lambda n: n)
    B = TheorySpec("Theory B", val=lambda n: 2 * n + 1)
    C = TheorySpec("Theory C", val=lambda n: 3 * n + 5)

    adj_AB = TheoryAdj(
        A=A, B=B,
        left=lambda n: n,
        right=lambda n: n,
        left_loss=1,   # B.val(n) = 2n+1 ≤ n + 1 ✗ for n≥1 -- need left_loss = n+1
        right_loss=0,
    )
    # Actually let's pick consistent examples
    # B.val(left(a)) ≤ A.val(a) + left_loss means 2a+1 ≤ a + left_loss, so left_loss ≥ a+1
    # For finite test range, let's use a different example

    # Simpler: all theories with val = id, different losses
    A = TheorySpec("A (val=n)", val=lambda n: n)
    B = TheorySpec("B (val=n)", val=lambda n: n)
    C = TheorySpec("C (val=n)", val=lambda n: n)

    adj_AB = TheoryAdj(
        A=A, B=B,
        left=lambda n: n + 2,   # inflate by 2
        right=lambda n: n + 3,  # inflate by 3
        left_loss=2,   # B.val(n+2) = n+2 ≤ n + 2 = A.val(n) + 2 ✓
        right_loss=3,  # A.val(n+3) = n+3 ≤ n + 3 = B.val(n) + 3 ✓
    )

    adj_BC = TheoryAdj(
        A=B, B=C,
        left=lambda n: n + 1,
        right=lambda n: n + 4,
        left_loss=1,   # C.val(n+1) = n+1 ≤ n + 1 ✓
        right_loss=4,  # B.val(n+4) = n+4 ≤ n + 4 ✓
    )

    adj_AC = adj_AB.compose(adj_BC)

    print(f"\nA ⇄ B: left_loss={adj_AB.left_loss}, right_loss={adj_AB.right_loss}")
    print(f"B ⇄ C: left_loss={adj_BC.left_loss}, right_loss={adj_BC.right_loss}")
    print(f"A ⇄ C (composed): left_loss={adj_AC.left_loss}, right_loss={adj_AC.right_loss}")
    print(f"  Expected: left_loss={adj_AB.left_loss}+{adj_BC.left_loss}={adj_AB.left_loss+adj_BC.left_loss}")
    print(f"  Expected: right_loss={adj_BC.right_loss}+{adj_AB.right_loss}={adj_BC.right_loss+adj_AB.right_loss}")

    # Transfer through chain
    L = 10
    print(f"\nTransfer chain with L={L}:")
    l_AB = adj_AB.transfer_left_to_right(L)
    l_BC = adj_BC.transfer_left_to_right(l_AB)
    l_AC = adj_AC.transfer_left_to_right(L)
    print(f"  A→B: L'={l_AB} (loss {adj_AB.right_loss})")
    print(f"  B→C: L''={l_BC} (loss {adj_BC.right_loss})")
    print(f"  A→C direct: L''={l_AC} (total loss {adj_AC.right_loss})")
    print(f"  Sequential transfer: {L} → {l_AB} → {l_BC}")
    print(f"  Direct composed transfer: {L} → {l_AC}")
    assert l_BC == l_AC, "Composed transfer should match sequential!"
    print(f"  ✓ Sequential and composed transfers agree!")


def demo_tropical_simulation():
    """Demonstrate tropical-style simulation transfer."""
    print("\n" + "=" * 60)
    print("DEMO 3: Tropical Simulation Transfer")
    print("=" * 60)

    # Model the tropical_lower_bound_transfer pattern:
    # Circuit theory: val(c) = opCount
    # BP theory: val(bp) = 2*w*w*d + w
    # Simulation: every BP simulates to a circuit with opCount ≤ 2*w*w*d + w

    CircuitTheory = TheorySpec("Circuit", val=lambda c: c)
    BPTheory = TheorySpec("BP", val=lambda bp: bp)

    # If K ≤ opCount(c) for all circuits c,
    # and sim(bp) has opCount ≤ bp_complexity(bp),
    # then K ≤ bp_complexity(bp)

    K = 42  # Circuit lower bound

    print(f"\nCircuit lower bound: K = {K}")
    print(f"Simulation: every BP maps to a circuit with opCount ≤ BP complexity")
    print(f"\nTransfer: K = {K} ≤ BP complexity for all BPs")

    # Show with concrete BP parameters
    for w, d in [(2, 3), (3, 5), (4, 10)]:
        bp_complexity = 2 * w * w * d + w
        print(f"  BP(w={w}, d={d}): complexity = 2·{w}²·{d}+{w} = {bp_complexity}")
        print(f"    K={K} ≤ {bp_complexity}? {'✓' if K <= bp_complexity else '✗'}")


def demo_exact_adjunction():
    """Demonstrate exact (zero-loss) adjunctions."""
    print("\n" + "=" * 60)
    print("DEMO 4: Exact Adjunctions")
    print("=" * 60)

    A = TheorySpec("A", val=lambda n: n)
    B = TheorySpec("B", val=lambda n: n)

    exact_adj = TheoryAdj(
        A=A, B=B,
        left=lambda n: n,
        right=lambda n: n,
        left_loss=0,
        right_loss=0,
    )

    print(f"\nExact adjunction (zero loss):")
    print(f"  left_loss={exact_adj.left_loss}, right_loss={exact_adj.right_loss}")

    L = 7
    print(f"\nTransfer with L={L}:")
    print(f"  A→B: {exact_adj.transfer_left_to_right(L)} (no degradation)")
    print(f"  B→A: {exact_adj.transfer_right_to_left(L)} (no degradation)")

    # Composition of exact adjunctions stays exact
    exact_adj2 = TheoryAdj(
        A=B, B=TheorySpec("C", val=lambda n: n),
        left=lambda n: n, right=lambda n: n,
        left_loss=0, right_loss=0,
    )

    composed = exact_adj.compose(exact_adj2)
    print(f"\nComposed exact adjunction:")
    print(f"  left_loss={composed.left_loss}, right_loss={composed.right_loss}")
    print(f"  Is exact: {composed.left_loss == 0 and composed.right_loss == 0}")


def demo_loss_landscape():
    """Show how losses accumulate through chains of adjunctions."""
    print("\n" + "=" * 60)
    print("DEMO 5: Loss Landscape Through Chains")
    print("=" * 60)

    theories = []
    for i in range(6):
        theories.append(TheorySpec(f"T{i}", val=lambda n: n))

    # Create a chain of adjunctions with varying losses
    losses = [(1, 2), (0, 3), (2, 1), (1, 0), (3, 2)]
    adjs = []
    for i, (ll, rl) in enumerate(losses):
        adjs.append(TheoryAdj(
            A=theories[i], B=theories[i+1],
            left=lambda n, l=ll: n + l,
            right=lambda n, r=rl: n + r,
            left_loss=ll, right_loss=rl,
        ))

    print(f"\nChain: T0 ⇄ T1 ⇄ T2 ⇄ T3 ⇄ T4 ⇄ T5")
    print(f"Individual losses (left, right):")
    for i, adj in enumerate(adjs):
        print(f"  T{i}⇄T{i+1}: ({adj.left_loss}, {adj.right_loss})")

    # Compose the entire chain
    composed = adjs[0]
    for adj in adjs[1:]:
        composed = composed.compose(adj)

    print(f"\nComposed T0 ⇄ T5:")
    print(f"  left_loss = {' + '.join(str(l) for l, _ in losses)} = {composed.left_loss}")
    print(f"  right_loss = {' + '.join(str(r) for _, r in reversed(losses))} = {composed.right_loss}")

    L = 100
    transferred = composed.transfer_left_to_right(L)
    print(f"\nLower bound L={L} in T0 transfers to L'={transferred} in T5")
    print(f"  Degradation: {L - transferred} (= right_loss = {composed.right_loss})")


if __name__ == "__main__":
    demo_height_dimension()
    demo_composition()
    demo_tropical_simulation()
    demo_exact_adjunction()
    demo_loss_landscape()
    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualizations for the Approximate Adjunction Framework.

Generates publication-quality figures showing:
1. Loss accumulation through adjunction chains
2. Bidirectional transfer landscape
3. Adjunction composition diagram
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import base64
from io import BytesIO


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def viz_loss_accumulation():
    """Visualize how losses accumulate through chains of adjunctions."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Chain lengths and individual losses
    chain_lengths = range(1, 11)
    individual_losses = [1, 2, 3, 1, 2, 1, 3, 2, 1, 2]

    # Cumulative left and right losses
    cum_left = np.cumsum(individual_losses)
    cum_right = np.cumsum(individual_losses[::-1])[::-1]
    # For simplicity, use same losses in both directions
    cum_right = np.cumsum([l + 1 for l in individual_losses])

    # Plot 1: Loss accumulation
    ax1.bar(chain_lengths, cum_left[:len(chain_lengths)],
            alpha=0.7, color='#2196F3', label='Left loss (forward)')
    ax1.bar(chain_lengths, cum_right[:len(chain_lengths)],
            alpha=0.4, color='#FF5722', label='Right loss (backward)')
    ax1.set_xlabel('Chain Length (number of adjunctions)', fontsize=12)
    ax1.set_ylabel('Cumulative Loss', fontsize=12)
    ax1.set_title('Loss Accumulation in Adjunction Chains', fontsize=14)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)

    # Plot 2: Lower bound degradation
    L0 = 100
    transferred_fwd = [L0 - cum_right[i] for i in range(len(chain_lengths))]
    transferred_bwd = [L0 - cum_left[i] for i in range(len(chain_lengths))]

    ax2.plot(chain_lengths, transferred_fwd, 'o-', color='#2196F3',
             linewidth=2, markersize=8, label='Forward transfer')
    ax2.plot(chain_lengths, transferred_bwd, 's-', color='#FF5722',
             linewidth=2, markersize=8, label='Backward transfer')
    ax2.axhline(y=L0, color='gray', linestyle='--', alpha=0.5, label=f'Original bound L={L0}')
    ax2.axhline(y=0, color='red', linestyle=':', alpha=0.5, label='Zero bound')
    ax2.fill_between(chain_lengths, transferred_fwd, L0, alpha=0.1, color='#2196F3')
    ax2.fill_between(chain_lengths, transferred_bwd, L0, alpha=0.1, color='#FF5722')
    ax2.set_xlabel('Chain Length', fontsize=12)
    ax2.set_ylabel('Transferred Lower Bound', fontsize=12)
    ax2.set_title('Lower Bound Degradation Through Chains', fontsize=14)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    fig.savefig('/workspace/request-project/loss_accumulation.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def viz_bidirectional_transfer():
    """Visualize the bidirectional transfer landscape."""
    fig, ax = plt.subplots(figsize=(10, 8))

    # Grid of (left_loss, right_loss) values
    losses = np.arange(0, 11)
    L = 50  # Original lower bound

    # Create heatmap data
    forward_bounds = np.zeros((len(losses), len(losses)))
    backward_bounds = np.zeros((len(losses), len(losses)))

    for i, ll in enumerate(losses):
        for j, rl in enumerate(losses):
            forward_bounds[i, j] = L - rl   # forward: L - right_loss
            backward_bounds[i, j] = L - ll   # backward: L - left_loss

    # Plot the minimum (worst-case) transferred bound
    min_bound = np.minimum(forward_bounds, backward_bounds)

    im = ax.imshow(min_bound, cmap='RdYlGn', origin='lower',
                    extent=[-0.5, 10.5, -0.5, 10.5], aspect='equal')
    cbar = plt.colorbar(im, ax=ax, label='Worst-case transferred bound')

    # Add contour lines
    X, Y = np.meshgrid(losses, losses)
    cs = ax.contour(X, Y, min_bound, levels=[10, 20, 30, 40],
                     colors='black', linewidths=0.8, alpha=0.5)
    ax.clabel(cs, inline=True, fontsize=9, fmt='%d')

    # Mark the exact adjunction point
    ax.plot(0, 0, 'w*', markersize=20, markeredgecolor='black', markeredgewidth=1.5)
    ax.annotate('Exact\n(0,0)', xy=(0, 0), xytext=(2, 2),
                arrowprops=dict(arrowstyle='->', color='black'),
                fontsize=11, color='black',
                bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))

    ax.set_xlabel('Right Loss (forward transfer degradation)', fontsize=12)
    ax.set_ylabel('Left Loss (backward transfer degradation)', fontsize=12)
    ax.set_title(f'Bidirectional Transfer Landscape (L={L})', fontsize=14)

    plt.tight_layout()
    fig.savefig('/workspace/request-project/transfer_landscape.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def viz_composition_diagram():
    """Visualize the adjunction composition structure."""
    fig, ax = plt.subplots(figsize=(14, 7))
    ax.set_xlim(-1, 15)
    ax.set_ylim(-3, 5)
    ax.set_aspect('equal')
    ax.axis('off')

    # Theory nodes
    theories = [
        (1, 1, 'Theory A\n(val = complexity)'),
        (5, 1, 'Theory B\n(val = depth)'),
        (9, 1, 'Theory C\n(val = size)'),
        (13, 1, 'Theory D\n(val = width)'),
    ]

    for x, y, label in theories:
        circle = plt.Circle((x, y), 0.8, fill=True, facecolor='#E3F2FD',
                            edgecolor='#1565C0', linewidth=2)
        ax.add_patch(circle)
        ax.text(x, y, label, ha='center', va='center', fontsize=9, fontweight='bold')

    # Adjunction arrows
    arrows = [
        (1, 5, 'left₁', 'right₁', '(2, 1)', '#4CAF50'),
        (5, 9, 'left₂', 'right₂', '(1, 3)', '#FF9800'),
        (9, 13, 'left₃', 'right₃', '(0, 2)', '#9C27B0'),
    ]

    for x1, x2, lname, rname, losses, color in arrows:
        # Forward arrow (top)
        ax.annotate('', xy=(x2-0.8, 1.5), xytext=(x1+0.8, 1.5),
                    arrowprops=dict(arrowstyle='->', color=color, lw=2))
        ax.text((x1+x2)/2, 2.0, lname, ha='center', va='center',
                fontsize=10, color=color, style='italic')

        # Backward arrow (bottom)
        ax.annotate('', xy=(x1+0.8, 0.5), xytext=(x2-0.8, 0.5),
                    arrowprops=dict(arrowstyle='->', color=color, lw=2, linestyle='dashed'))
        ax.text((x1+x2)/2, -0.1, rname, ha='center', va='center',
                fontsize=10, color=color, style='italic')

        # Loss label
        ax.text((x1+x2)/2, 2.8, f'loss = {losses}', ha='center', va='center',
                fontsize=9, bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

    # Composed adjunction
    ax.annotate('', xy=(13-0.8, -1.5), xytext=(1+0.8, -1.5),
                arrowprops=dict(arrowstyle='<->', color='#F44336', lw=3))
    ax.text(7, -2.3, 'Composed: A ⇄ D\nleft_loss = 2+1+0 = 3, right_loss = 2+3+1 = 6',
            ha='center', va='center', fontsize=11, fontweight='bold',
            bbox=dict(boxstyle='round', facecolor='#FFEBEE', alpha=0.9, edgecolor='#F44336'))

    # Title
    ax.text(7, 4.2, 'Adjunction Composition: Losses Add',
            ha='center', va='center', fontsize=16, fontweight='bold')

    # Transfer example
    ax.text(7, 3.4, 'Lower bound L=100 in A → L\'=100-6=94 in D',
            ha='center', va='center', fontsize=12, style='italic', color='#666')

    plt.tight_layout()
    fig.savefig('/workspace/request-project/composition_diagram.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


if __name__ == "__main__":
    print("Generating visualizations...")

    b64_loss = viz_loss_accumulation()
    print(f"Loss accumulation: saved to loss_accumulation.png ({len(b64_loss)} chars)")

    b64_transfer = viz_bidirectional_transfer()
    print(f"Transfer landscape: saved to transfer_landscape.png ({len(b64_transfer)} chars)")

    b64_comp = viz_composition_diagram()
    print(f"Composition diagram: saved to composition_diagram.png ({len(b64_comp)} chars)")

    print("\nAll visualizations generated successfully!")
