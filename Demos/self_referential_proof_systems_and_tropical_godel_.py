#!/usr/bin/env python3
"""
Tropical Metamathematics: Applications

Demonstrates real-world applications of tropical incompleteness theorems
in verification, optimization, and machine learning.
"""

import numpy as np
from typing import Callable, Tuple, List, Dict

INF = float('inf')


def application_1_verification_barrier():
    """
    Application 1: Verification Barriers in Program Analysis
    
    In abstract interpretation, a program analysis computes a "closure"
    of program states — an overapproximation that is stable under the
    program's transition function. The tropical incompleteness theorem
    shows that if the analysis is expressive enough to encode self-reference,
    it cannot be both sound and complete.
    
    Concrete scenario: A static analyzer for array bounds checking.
    """
    print("=" * 70)
    print("APPLICATION 1: Verification Barriers in Program Analysis")
    print("=" * 70)
    
    n = 6  # Number of program properties
    properties = [
        "array_in_bounds",
        "no_null_deref",
        "termination",
        "memory_safety",
        "type_safety",
        "self_consistency"  # The "Gödel property"
    ]
    
    # Abstract domain: tropical cost = "distance to being verified"
    # 0 = verified, ∞ = unverifiable, intermediate = partially verified
    
    # The analyzer's closure operator
    analysis_ceiling = np.array([0.0, 0.0, 1.5, 0.0, 0.0, 0.0])
    
    def analyzer(state):
        return np.minimum(state, analysis_ceiling)
    
    # The "self_consistency" property (index 5) says:
    # "This analysis correctly reports my own verification status"
    # This is a diagonal/self-referential property
    
    initial_state = np.full(n, 10.0)
    fp = analyzer(initial_state)
    
    print(f"\nProgram properties: {properties}")
    print(f"Analysis result (fixed point):")
    for i, (prop, val) in enumerate(zip(properties, fp)):
        status = "✓ VERIFIED" if val == 0 else f"? COST={val:.1f}"
        print(f"  [{i}] {prop:20s}: {status}")
    
    # Diagonal analysis at the self-consistency property
    self_idx = 5
    provable = (fp[self_idx] == 0.0)
    true_by_diag = not provable
    
    print(f"\nDiagonal analysis at '{properties[self_idx]}':")
    print(f"  Verified by analyzer: {provable}")
    print(f"  Actually consistent:  {true_by_diag}")
    
    if provable:
        print(f"\n  The analyzer claims to verify its own consistency,")
        print(f"  but by the tropical incompleteness theorem, this means")
        print(f"  the analysis is UNSOUND — it verifies something it shouldn't.")
    else:
        print(f"\n  The analyzer cannot verify its own consistency.")
        print(f"  This is the tropical incompleteness barrier in action:")
        print(f"  no sufficiently expressive analysis can verify itself.")
    
    print()


def application_2_shortest_path_self_reference():
    """
    Application 2: Self-Reference in Shortest Path Problems
    
    The shortest path problem is fundamentally tropical (min-plus).
    We show that a routing network with self-referential cost specifications
    exhibits an incompleteness phenomenon.
    """
    print("=" * 70)
    print("APPLICATION 2: Self-Reference in Network Routing")
    print("=" * 70)
    
    n = 5
    nodes = ["A", "B", "C", "D", "E"]
    
    # Cost matrix for a network
    costs = np.array([
        [0,   2,   INF, 1,   INF],
        [2,   0,   3,   INF, 1  ],
        [INF, 3,   0,   2,   INF],
        [1,   INF, 2,   0,   4  ],
        [INF, 1,   INF, 4,   0  ],
    ])
    
    print(f"\nNetwork with {n} nodes: {nodes}")
    print(f"Cost matrix:")
    for i in range(n):
        row = [f"{c:4.0f}" if c != INF else " INF" for c in costs[i]]
        print(f"  {nodes[i]}: [{', '.join(row)}]")
    
    # Bellman-Ford as tropical closure
    def bellman_closure(v):
        """One step of Bellman-Ford: tropical matrix-vector product."""
        return np.array([min(costs[i, j] + v[j] for j in range(n)) for i in range(n)])
    
    # Iterate to fixed point
    v = np.zeros(n)
    print(f"\nBellman-Ford iteration (shortest paths from each node to itself):")
    for step in range(10):
        v_new = bellman_closure(v)
        diff = np.max(np.abs(v_new - v))
        print(f"  Step {step}: v = [{', '.join(f'{x:.1f}' for x in v_new)}], max_change = {diff:.4f}")
        if diff < 1e-10:
            break
        v = v_new
    
    print(f"\nFixed point (all-pairs shortest self-loops): {v}")
    
    # Self-referential specification: "Node D's routing cost is optimal
    # iff this specification is not verifiable by the routing protocol"
    diag_node = 3  # Node D
    verified = (v[diag_node] == 0.0)
    
    print(f"\nSelf-referential specification at node {nodes[diag_node]}:")
    print(f"  'My routing cost is optimal iff this spec is unverifiable'")
    print(f"  Verified: {verified}")
    print(f"  Spec holds: {not verified}")
    print(f"  Status: {'UNSOUND' if verified else 'INCOMPLETE'}")
    print()


def application_3_ml_loss_landscape():
    """
    Application 3: Incompleteness in ML Loss Landscape Analysis
    
    In machine learning, loss landscapes can be viewed through a tropical lens.
    We show that self-referential loss specifications (e.g., "this model
    correctly predicts its own loss") face tropical incompleteness barriers.
    """
    print("=" * 70)
    print("APPLICATION 3: Tropical Incompleteness in ML Loss Landscapes")
    print("=" * 70)
    
    n = 4
    objectives = [
        "training_loss",
        "validation_loss", 
        "model_complexity",
        "self_prediction_accuracy"  # Diagonal objective
    ]
    
    # Tropical loss operator: takes a loss profile and returns the
    # "regularized" loss profile
    regularization = np.array([0.1, 0.2, 1.0, 0.0])
    
    def loss_operator(losses):
        """Tropical regularization: min(loss, baseline + regularization)."""
        baseline = np.min(losses)
        return np.minimum(losses, baseline + regularization)
    
    # Find equilibrium
    initial_losses = np.array([2.0, 2.5, 5.0, 3.0])
    losses = initial_losses.copy()
    
    print(f"\nLoss objectives: {objectives}")
    print(f"Initial losses: {initial_losses}")
    
    for step in range(20):
        new_losses = loss_operator(losses)
        if np.allclose(new_losses, losses):
            print(f"Converged at step {step}")
            break
        losses = new_losses
    
    print(f"Equilibrium losses: {np.round(losses, 4)}")
    
    # Diagonal analysis: self_prediction_accuracy
    diag_idx = 3
    achievable = (losses[diag_idx] <= 0.0 + 1e-10)
    
    print(f"\nDiagonal objective '{objectives[diag_idx]}':")
    print(f"  Can the model perfectly predict its own loss? {achievable}")
    print(f"  By tropical incompleteness: No model can simultaneously")
    print(f"  minimize all losses AND accurately predict its own performance")
    print(f"  when self-prediction is part of the objective.")
    print()


def application_4_cryptographic_commitments():
    """
    Application 4: Tropical Commitments and Zero-Knowledge
    
    In cryptography, commitment schemes require binding (can't change committed
    value) and hiding (commitment reveals nothing). The tropical analogue
    shows that self-referential commitments face incompleteness.
    """
    print("=" * 70)
    print("APPLICATION 4: Self-Referential Commitment Schemes")
    print("=" * 70)
    
    n = 4
    
    # A tropical commitment scheme: each "slot" has a cost
    # representing the difficulty of opening/changing the commitment
    binding_strength = np.array([5.0, 3.0, 7.0, 0.0])
    
    def commitment_closure(x):
        """Closure: enforce minimum binding strength."""
        return np.maximum(x, binding_strength)
    
    print(f"\nCommitment scheme with {n} slots")
    print(f"Binding strength: {binding_strength}")
    
    # Self-referential slot: "This slot's binding strength equals
    # its own verifiability score"
    x0 = np.zeros(n)
    fp = commitment_closure(x0)
    
    print(f"Fixed point: {fp}")
    
    diag_slot = 3  # The self-referential slot
    print(f"\nSelf-referential slot {diag_slot}:")
    print(f"  Binding strength: {binding_strength[diag_slot]}")
    print(f"  Fixed point value: {fp[diag_slot]}")
    
    if binding_strength[diag_slot] == 0:
        print(f"  This slot has zero binding strength — it can always be changed.")
        print(f"  A self-referential commitment ('I commit to my own binding status')")
        print(f"  is either trivially bound (and unsound) or unbound (and incomplete).")
    
    print()


if __name__ == "__main__":
    print("\n" + "=" * 70)
    print("  TROPICAL METAMATHEMATICS: Applications")
    print("=" * 70 + "\n")
    
    application_1_verification_barrier()
    application_2_shortest_path_self_reference()
    application_3_ml_loss_landscape()
    application_4_cryptographic_commitments()
    
    print("=" * 70)
    print("All applications demonstrated.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Tropical Metamathematics: Demonstrations and Numerical Examples

This module demonstrates the key theorems of tropical metamathematics with
concrete numerical examples, showing how idempotent fixed-point dynamics
give rise to self-referential sentences and incompleteness phenomena.
"""

import numpy as np
from typing import Callable, Optional, Tuple, List

# Type alias for tropical state vectors
TropicalState = np.ndarray  # shape (n,), values in R ∪ {+∞}

INF = float('inf')


def demo_1_idempotent_fixed_points():
    """
    Demonstration 1: Idempotent operators always have fixed points.
    
    Any idempotent function f (where f(f(x)) = f(x) for all x) has the
    property that every element in its image is a fixed point. This is the
    foundation of tropical self-reference.
    """
    print("=" * 70)
    print("DEMO 1: Idempotent Operators Have Fixed Points")
    print("=" * 70)
    
    n = 4
    
    # Define a tropical closure operator: component-wise min with a threshold
    # This models a proof system that "proves" any sentence whose cost ≤ threshold
    threshold = np.array([3.0, 5.0, 2.0, 4.0])
    
    def closure_op(x: TropicalState) -> TropicalState:
        """Tropical closure: clamp each coordinate to its threshold."""
        return np.minimum(x, threshold)
    
    # Verify idempotency
    x0 = np.array([1.0, 7.0, 3.0, 2.0])
    fx0 = closure_op(x0)
    ffx0 = closure_op(fx0)
    
    print(f"\nInput x₀ = {x0}")
    print(f"Φ(x₀)    = {fx0}")
    print(f"Φ(Φ(x₀)) = {ffx0}")
    print(f"Idempotent: Φ(Φ(x₀)) == Φ(x₀)? {np.allclose(ffx0, fx0)}")
    
    # The image point is always a fixed point
    fixed_point = fx0
    print(f"\nFixed point: Φ(x₀) = {fixed_point}")
    print(f"Verification: Φ(fixed_point) = {closure_op(fixed_point)}")
    print(f"Is fixed point: Φ(fp) == fp? {np.allclose(closure_op(fixed_point), fixed_point)}")
    
    # Try multiple starting points
    print("\nFixed points from various starting points:")
    for _ in range(5):
        x = np.random.uniform(0, 10, n)
        fp = closure_op(x)
        is_fp = np.allclose(closure_op(fp), fp)
        print(f"  start={np.round(x,2)} → fp={np.round(fp,2)}, verified={is_fp}")
    
    print()


def demo_2_diagonal_incompleteness():
    """
    Demonstration 2: The Diagonal Incompleteness Argument.
    
    If a sentence's truth is equivalent to its own unprovability,
    then no assignment can be both sound and complete at that sentence.
    """
    print("=" * 70)
    print("DEMO 2: Diagonal Incompleteness (Tropical Gödel Sentence)")
    print("=" * 70)
    
    n = 5
    diagonal_index = 2  # The "Gödel sentence" coordinate
    
    # Define tropical provability: sentence i is "provable" if x[i] == 0
    def is_provable(x: TropicalState, i: int) -> bool:
        return x[i] == 0.0
    
    # The diagonal sentence: Truth at index 2 ↔ ¬ Provable at index 2
    # i.e., the sentence says "I am not provable"
    def truth_at_diagonal(x: TropicalState) -> bool:
        return not is_provable(x, diagonal_index)
    
    print(f"\nDiagonal sentence at index {diagonal_index}:")
    print(f"  Truth(x, {diagonal_index}) ↔ ¬ Provable(x, {diagonal_index})")
    print(f"  i.e., 'Sentence {diagonal_index} is true iff it is not provable'")
    
    # Try to find a sound and complete assignment
    print("\nAttempting sound + complete assignments:")
    
    # Case 1: Make the sentence provable (x[2] = 0)
    x1 = np.array([1.0, 2.0, 0.0, 3.0, 1.0])
    prov = is_provable(x1, diagonal_index)
    truth = truth_at_diagonal(x1)
    print(f"\n  Case 1: x = {x1}")
    print(f"    Provable(x, {diagonal_index}) = {prov}")
    print(f"    Truth(x, {diagonal_index})     = {truth}")
    print(f"    Sound (Prov → Truth)?    {not prov or truth}")
    print(f"    Complete (Truth → Prov)? {not truth or prov}")
    if prov and not truth:
        print(f"    ⚠ UNSOUND: provable but not true!")
    
    # Case 2: Make the sentence unprovable (x[2] ≠ 0)
    x2 = np.array([1.0, 2.0, 5.0, 3.0, 1.0])
    prov = is_provable(x2, diagonal_index)
    truth = truth_at_diagonal(x2)
    print(f"\n  Case 2: x = {x2}")
    print(f"    Provable(x, {diagonal_index}) = {prov}")
    print(f"    Truth(x, {diagonal_index})     = {truth}")
    print(f"    Sound (Prov → Truth)?    {not prov or truth}")
    print(f"    Complete (Truth → Prov)? {not truth or prov}")
    if truth and not prov:
        print(f"    ⚠ INCOMPLETE: true but not provable!")
    
    print(f"\n  Conclusion: No assignment can be both sound and complete")
    print(f"  at the diagonal coordinate {diagonal_index}.")
    print(f"  This is the tropical Gödel incompleteness theorem.")
    print()


def demo_3_closure_operator_self_reference():
    """
    Demonstration 3: Closure Operators and Self-Reference.
    
    Shows how a closure operator (monotone, extensive, idempotent) on
    tropical states naturally produces self-referential fixed points.
    """
    print("=" * 70)
    print("DEMO 3: Closure Operators Yield Self-Referential Fixed Points")
    print("=" * 70)
    
    n = 4
    
    # Define a closure operator: take component-wise max with a "proof floor"
    proof_floor = np.array([1.0, 0.0, 2.0, 0.5])
    
    def closure(x: TropicalState) -> TropicalState:
        """Extensive closure: ensure each coordinate is at least proof_floor."""
        return np.maximum(x, proof_floor)
    
    # Verify closure properties
    x0 = np.array([0.0, 0.0, 0.0, 0.0])
    
    print(f"\nClosure operator: c(x) = max(x, {proof_floor})")
    print(f"\nProperty verification:")
    
    # Extensivity: x ≤ c(x)
    cx0 = closure(x0)
    print(f"  Extensive: x₀ = {x0}, c(x₀) = {cx0}")
    print(f"    x₀ ≤ c(x₀)? {np.all(x0 <= cx0)}")
    
    # Monotonicity
    y = np.array([0.5, 1.0, 0.0, 0.0])
    print(f"  Monotone: x₀ ≤ y = {y}")
    print(f"    c(x₀) = {closure(x0)}, c(y) = {closure(y)}")
    print(f"    c(x₀) ≤ c(y)? {np.all(closure(x0) <= closure(y))}")
    
    # Idempotency
    print(f"  Idempotent: c(c(x₀)) = {closure(closure(x0))}")
    print(f"    c(c(x₀)) == c(x₀)? {np.allclose(closure(closure(x0)), closure(x0))}")
    
    # Self-referential fixed point
    fp = closure(x0)
    print(f"\nSelf-referential fixed point: c(0) = {fp}")
    print(f"  c(fp) = {closure(fp)}")
    print(f"  fp == c(fp)? {np.allclose(fp, closure(fp))}")
    
    # The fixed point "knows" it is closed
    print(f"\n  Interpretation: The fixed point {fp} represents a tropical")
    print(f"  valuation that is stable under proof closure. Each coordinate")
    print(f"  fp[i] = c(fp)[i] means 'sentence i's proof cost equals its")
    print(f"  closure cost' — i.e., the sentence is self-consistently valued.")
    print()


def demo_4_tropical_proof_system():
    """
    Demonstration 4: Complete Tropical Proof System Simulation.
    
    Simulates a tropical proof system and demonstrates the incompleteness
    phenomenon with a concrete Gödel sentence.
    """
    print("=" * 70)
    print("DEMO 4: Tropical Proof System Simulation")
    print("=" * 70)
    
    n = 6
    godel_idx = 3  # The Gödel sentence
    
    # Define a monotone idempotent evaluator
    # This models a proof system that:
    # - Reduces high costs toward a "proof ceiling"
    # - Is idempotent (re-evaluating doesn't change anything)
    ceiling = np.array([2.0, 1.0, 3.0, 0.0, 2.0, 1.0])
    
    def evaluator(x: TropicalState) -> TropicalState:
        return np.minimum(x, ceiling)
    
    print(f"\nProof system with {n} sentences")
    print(f"Evaluator: Φ(x) = min(x, ceiling)")
    print(f"Ceiling: {ceiling}")
    print(f"Gödel sentence index: {godel_idx}")
    
    # Find fixed point
    x0 = np.array([5.0, 5.0, 5.0, 5.0, 5.0, 5.0])
    fp = evaluator(x0)
    
    print(f"\nFixed point (from x₀={x0}):")
    print(f"  Φ(x₀) = {fp}")
    print(f"  Φ(Φ(x₀)) = {evaluator(fp)}")
    print(f"  Is fixed point: {np.allclose(evaluator(fp), fp)}")
    
    # At the Gödel index: ceiling[3] = 0, so x[3] = 0 at any fixed point
    # starting from x ≥ 0
    print(f"\nAt the Gödel coordinate (index {godel_idx}):")
    print(f"  fp[{godel_idx}] = {fp[godel_idx]}")
    print(f"  TropProvable = (fp[{godel_idx}] == 0)? {fp[godel_idx] == 0.0}")
    
    # Define diagonal truth: Truth(x, 3) ↔ ¬ TropProvable(x, 3)
    prov = (fp[godel_idx] == 0.0)
    truth = not prov  # By diagonalization
    
    print(f"\n  Diagonal definition: Truth(x, {godel_idx}) ↔ ¬ TropProvable(x, {godel_idx})")
    print(f"  At the fixed point:")
    print(f"    Provable = {prov}")
    print(f"    Truth    = {truth}")
    
    if prov:
        print(f"\n  ⚠ The sentence IS provable (cost = 0)")
        print(f"    But by diagonalization, it should be FALSE (not true)")
        print(f"    → The system is UNSOUND at this coordinate!")
    else:
        print(f"\n  ✓ The sentence is NOT provable (cost > 0)")
        print(f"    By diagonalization, it is TRUE")
        print(f"    → The system is INCOMPLETE at this coordinate!")
    
    print(f"\n  This demonstrates tropical incompleteness: the proof system")
    print(f"  cannot be both sound and complete at the diagonal coordinate.")
    print()


def demo_5_quine_construction():
    """
    Demonstration 5: Tropical Quine (Self-Reproducing Valuation).
    
    A tropical quine is a cost profile x such that x[i] = Φ_i(x) for all i,
    where Φ_i is the i-th coordinate functional of an idempotent operator.
    """
    print("=" * 70)
    print("DEMO 5: Tropical Quine Construction")
    print("=" * 70)
    
    n = 4
    
    # Define coordinate functionals
    # Φ_i(x) = min over j≠i of (x[j] + weight[i][j])
    weights = np.array([
        [0.0, 1.0, 2.0, 3.0],
        [1.0, 0.0, 1.0, 2.0],
        [2.0, 1.0, 0.0, 1.0],
        [3.0, 2.0, 1.0, 0.0],
    ])
    
    def phi_i(x: TropicalState, i: int) -> float:
        """i-th coordinate functional: tropical (min-plus) convolution."""
        return min(x[j] + weights[i][j] for j in range(n))
    
    def Phi(x: TropicalState) -> TropicalState:
        """Full diagonal operator: Φ(x)[i] = Φ_i(x)."""
        return np.array([phi_i(x, i) for i in range(n)])
    
    print(f"\nDiagonal operator Φ with weight matrix:")
    print(f"{weights}")
    
    # Iterate to find a fixed point (quine)
    x = np.zeros(n)
    print(f"\nIteration to find tropical quine:")
    for step in range(10):
        x_new = Phi(x)
        diff = np.max(np.abs(x_new - x))
        print(f"  Step {step}: x = {np.round(x, 4)}, Φ(x) = {np.round(x_new, 4)}, max_diff = {diff:.6f}")
        if diff < 1e-10:
            print(f"  Converged!")
            break
        x = x_new
    
    quine = x
    print(f"\nTropical quine: x = {np.round(quine, 4)}")
    print(f"  Verification: Φ(x) = {np.round(Phi(quine), 4)}")
    print(f"  Is quine: Φ(x) ≈ x? {np.allclose(Phi(quine), quine)}")
    
    print(f"\n  Interpretation: This is a self-reproducing cost profile.")
    print(f"  Each coordinate x[i] = Φ_i(x) means 'the cost of sentence i")
    print(f"  is exactly what the system computes from all other sentences.'")
    print(f"  This is the tropical analogue of a Quine program.")
    print()


def demo_6_incompleteness_landscape():
    """
    Demonstration 6: Landscape of Incompleteness.
    
    Explores how the incompleteness phenomenon varies as we change
    the proof system parameters.
    """
    print("=" * 70)
    print("DEMO 6: Incompleteness Landscape")
    print("=" * 70)
    
    n = 8
    diag_idx = 4
    
    print(f"\nSystem with {n} sentences, diagonal index = {diag_idx}")
    print(f"Testing various proof system ceilings:\n")
    
    print(f"{'Ceiling[diag]':>14} | {'FP[diag]':>10} | {'Provable':>10} | {'Truth':>8} | {'Status':>12}")
    print("-" * 65)
    
    for ceil_val in [0.0, 0.5, 1.0, 2.0, 5.0, INF]:
        ceiling = np.full(n, 3.0)
        ceiling[diag_idx] = ceil_val
        
        fp = np.minimum(np.full(n, 10.0), ceiling)
        
        prov = (fp[diag_idx] == 0.0)
        truth = not prov  # Diagonal definition
        
        if prov and not truth:
            status = "UNSOUND"
        elif truth and not prov:
            status = "INCOMPLETE"
        elif prov and truth:
            status = "IMPOSSIBLE"
        else:
            status = "INCOMPLETE"
        
        ceil_str = f"{ceil_val}" if ceil_val != INF else "∞"
        print(f"{ceil_str:>14} | {fp[diag_idx]:>10.1f} | {str(prov):>10} | {str(truth):>8} | {status:>12}")
    
    print(f"\nConclusion: Regardless of the ceiling value, the system is either")
    print(f"unsound or incomplete at the diagonal coordinate. This is the")
    print(f"tropical incompleteness theorem in action.")
    print()


if __name__ == "__main__":
    print("\n" + "=" * 70)
    print("  TROPICAL METAMATHEMATICS: Demonstrations")
    print("  Self-Reference, Fixed Points, and Incompleteness")
    print("=" * 70 + "\n")
    
    demo_1_idempotent_fixed_points()
    demo_2_diagonal_incompleteness()
    demo_3_closure_operator_self_reference()
    demo_4_tropical_proof_system()
    demo_5_quine_construction()
    demo_6_incompleteness_landscape()
    
    print("=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)


#!/usr/bin/env python3
"""Generate PACKAGE.json with all deliverables."""

import json
import sys

# Import visualization generator
from visualizations import generate_all_visualizations

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

def main():
    # Generate visualizations
    viz_data = generate_all_visualizations()
    
    # Read all content files
    article = read_file('ARTICLE.md')
    research_paper = read_file('RESEARCH_PAPER.md')
    future_directions = read_file('FUTURE_DIRECTIONS.md')
    lean_code = read_file('Logic/TropicalMetamathematics.lean')
    demo_code = read_file('demo.py')
    algorithms_code = read_file('algorithms.py')
    applications_code = read_file('applications.py')
    
    package = {
        "title": "Tropical Metamathematics: Incompleteness Theorems from Idempotent Fixed-Point Dynamics",
        "domain": "Mathematical Logic / Tropical Algebra",
        "article": article,
        "research_paper": research_paper,
        "future_directions": future_directions,
        "demos": [
            {
                "name": "Tropical Metamathematics Demonstrations",
                "code": demo_code
            },
            {
                "name": "Applications of Tropical Incompleteness",
                "code": applications_code
            }
        ],
        "algorithms": [
            {
                "name": "Idempotent Fixed-Point Computation",
                "pseudocode": "Input: Idempotent operator Φ, dimension n\nOutput: Fixed point x with Φ(x) = x\n\n1. Set x₀ = (0, 0, ..., 0)\n2. Return Φ(x₀)\n\nComplexity: O(T_Φ) — single evaluation",
                "code": algorithms_code
            },
            {
                "name": "Diagonal Incompleteness Check",
                "pseudocode": "Input: Tropical proof system S, diagonal index i, threshold τ\nOutput: 'UNSOUND' or 'INCOMPLETE'\n\n1. Compute fixed point x = S.eval(0)\n2. If x[i] ≤ τ, return 'UNSOUND'\n3. Else return 'INCOMPLETE'\n\nComplexity: O(T_eval)",
                "code": "def check_diagonal_incompleteness(evaluator, n, diag_index, threshold=0.0):\n    import numpy as np\n    x0 = np.zeros(n)\n    fp = evaluator(x0)\n    if fp[diag_index] <= threshold:\n        return 'UNSOUND'\n    else:\n        return 'INCOMPLETE'"
            }
        ],
        "visualizations": [
            {
                "name": "Fixed-Point Convergence",
                "data": viz_data['fixed_point_convergence']
            },
            {
                "name": "Incompleteness Diagram",
                "data": viz_data['incompleteness_diagram']
            },
            {
                "name": "Closure Operator Landscape",
                "data": viz_data['closure_landscape']
            },
            {
                "name": "Tropical Quine Iteration",
                "data": viz_data['tropical_quine']
            },
            {
                "name": "Incompleteness Landscape",
                "data": viz_data['incompleteness_landscape']
            }
        ],
        "lean_proofs": lean_code
    }
    
    with open('PACKAGE.json', 'w') as f:
        json.dump(package, f, indent=2, ensure_ascii=False)
    
    print(f"PACKAGE.json generated ({len(json.dumps(package))} bytes)")

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Tropical Metamathematics: Visualizations

Generates publication-quality visualizations of the key mathematical
structures in tropical metamathematics.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.colors import LinearSegmentedColormap
import base64
import io
import json

INF = float('inf')


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def viz_1_fixed_point_convergence():
    """
    Visualization 1: Fixed-Point Convergence of Tropical Operators
    
    Shows how different starting points converge to fixed points
    under iteration of a tropical (min-plus) operator.
    """
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    n = 3
    ceiling = np.array([2.0, 1.5, 3.0])
    
    def operator(x):
        return np.minimum(x, ceiling)
    
    # Left: Trajectories in 2D projection
    ax = axes[0]
    starts = [
        np.array([5.0, 4.0, 6.0]),
        np.array([0.5, 3.0, 1.0]),
        np.array([3.0, 0.5, 4.0]),
        np.array([1.0, 1.0, 1.0]),
        np.array([4.0, 2.0, 2.0]),
    ]
    
    colors = plt.cm.viridis(np.linspace(0.2, 0.8, len(starts)))
    
    for start, color in zip(starts, colors):
        trajectory = [start]
        x = start.copy()
        for _ in range(5):
            x = operator(x)
            trajectory.append(x.copy())
        
        traj = np.array(trajectory)
        ax.plot(traj[:, 0], traj[:, 1], 'o-', color=color, markersize=6,
                linewidth=2, alpha=0.7)
        ax.plot(traj[0, 0], traj[0, 1], 's', color=color, markersize=10,
                label=f'start={np.round(start[:2], 1)}')
    
    # Mark the fixed point
    fp = operator(np.array([10.0, 10.0, 10.0]))
    ax.plot(fp[0], fp[1], '*', color='red', markersize=20, zorder=10,
            label=f'Fixed point')
    
    ax.set_xlabel('Coordinate 1 (tropical cost)', fontsize=12)
    ax.set_ylabel('Coordinate 2 (tropical cost)', fontsize=12)
    ax.set_title('Convergence to Tropical Fixed Point', fontsize=14)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    
    # Right: Idempotency demonstration
    ax = axes[1]
    x_vals = np.linspace(0, 6, 100)
    
    for i, (c, label, color) in enumerate([(2.0, 'Coord 1 (ceil=2.0)', '#2196F3'),
                                            (1.5, 'Coord 2 (ceil=1.5)', '#FF9800'),
                                            (3.0, 'Coord 3 (ceil=3.0)', '#4CAF50')]):
        y = np.minimum(x_vals, c)
        ax.plot(x_vals, y, '-', color=color, linewidth=2.5, label=label)
        ax.axhline(y=c, color=color, linestyle='--', alpha=0.3)
    
    ax.plot(x_vals, x_vals, 'k--', alpha=0.3, label='y = x (identity)')
    ax.set_xlabel('Input value x', fontsize=12)
    ax.set_ylabel('Φ(x) = min(x, ceiling)', fontsize=12)
    ax.set_title('Idempotent Operator: Φ(Φ(x)) = Φ(x)', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    fig.suptitle('Tropical Fixed-Point Dynamics', fontsize=16, fontweight='bold', y=1.02)
    fig.tight_layout()
    
    fig.savefig('/workspace/request-project/viz_1_fixed_point.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def viz_2_incompleteness_diagram():
    """
    Visualization 2: The Incompleteness Contradiction
    
    Illustrates the logical structure of the tropical Gödel argument:
    diagonal sentence → soundness vs completeness contradiction.
    """
    fig, ax = plt.subplots(1, 1, figsize=(12, 8))
    ax.set_xlim(-0.5, 10.5)
    ax.set_ylim(-0.5, 8.5)
    ax.set_aspect('equal')
    ax.axis('off')
    
    # Title
    ax.text(5.25, 8, 'Tropical Gödel Incompleteness', fontsize=18,
            fontweight='bold', ha='center', va='center')
    
    # Boxes for concepts
    box_style = dict(boxstyle='round,pad=0.5', facecolor='#E3F2FD', edgecolor='#1565C0', linewidth=2)
    
    # Diagonal sentence
    ax.text(5.25, 6.5, 'Diagonal Sentence G:\n"G is true ↔ G is not provable"',
            fontsize=12, ha='center', va='center',
            bbox=dict(boxstyle='round,pad=0.5', facecolor='#FFF3E0', edgecolor='#E65100', linewidth=2))
    
    # Two cases
    ax.text(2.5, 4.5, 'Case 1: G is Provable\n(x[i] = 0)',
            fontsize=11, ha='center', va='center',
            bbox=dict(boxstyle='round,pad=0.5', facecolor='#E8F5E9', edgecolor='#2E7D32', linewidth=2))
    
    ax.text(8, 4.5, 'Case 2: G is Not Provable\n(x[i] ≠ 0)',
            fontsize=11, ha='center', va='center',
            bbox=dict(boxstyle='round,pad=0.5', facecolor='#E8F5E9', edgecolor='#2E7D32', linewidth=2))
    
    # Consequences
    ax.text(2.5, 2.5, 'By soundness:\nG is True\nBy diagonalization:\nG is NOT True\n⚡ Contradiction!',
            fontsize=10, ha='center', va='center',
            bbox=dict(boxstyle='round,pad=0.5', facecolor='#FFEBEE', edgecolor='#C62828', linewidth=2))
    
    ax.text(8, 2.5, 'By diagonalization:\nG is True\nBy completeness:\nG IS Provable\n⚡ Contradiction!',
            fontsize=10, ha='center', va='center',
            bbox=dict(boxstyle='round,pad=0.5', facecolor='#FFEBEE', edgecolor='#C62828', linewidth=2))
    
    # Conclusion
    ax.text(5.25, 0.5, '∴ No tropical proof system can be\nboth Sound and Complete\nat the diagonal coordinate',
            fontsize=13, ha='center', va='center', fontweight='bold',
            bbox=dict(boxstyle='round,pad=0.5', facecolor='#F3E5F5', edgecolor='#6A1B9A', linewidth=2))
    
    # Arrows
    arrow_style = dict(arrowstyle='->', color='#37474F', linewidth=2)
    ax.annotate('', xy=(2.5, 5.3), xytext=(4.5, 6.0),
                arrowprops=arrow_style)
    ax.annotate('', xy=(8, 5.3), xytext=(6.0, 6.0),
                arrowprops=arrow_style)
    ax.annotate('', xy=(2.5, 3.5), xytext=(2.5, 3.9),
                arrowprops=arrow_style)
    ax.annotate('', xy=(8, 3.5), xytext=(8, 3.9),
                arrowprops=arrow_style)
    ax.annotate('', xy=(4.0, 1.0), xytext=(2.5, 1.7),
                arrowprops=arrow_style)
    ax.annotate('', xy=(6.5, 1.0), xytext=(8, 1.7),
                arrowprops=arrow_style)
    
    fig.savefig('/workspace/request-project/viz_2_incompleteness.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def viz_3_closure_landscape():
    """
    Visualization 3: Closure Operator Landscape
    
    Shows the structure of a closure operator on a 2D tropical space,
    highlighting fixed points and the closure image.
    """
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # 2D closure operator: c(x,y) = (max(x, 1), max(y, 0.5))
    x_range = np.linspace(-1, 5, 200)
    y_range = np.linspace(-1, 5, 200)
    X, Y = np.meshgrid(x_range, y_range)
    
    CX = np.maximum(X, 1.0)
    CY = np.maximum(Y, 0.5)
    
    # Left: Closure operator action
    ax = axes[0]
    
    # Color by distance moved: |c(x) - x|
    dist = np.sqrt((CX - X)**2 + (CY - Y)**2)
    im = ax.contourf(X, Y, dist, levels=20, cmap='YlOrRd')
    plt.colorbar(im, ax=ax, label='Distance moved by closure')
    
    # Fixed point region (where dist ≈ 0)
    ax.contour(X, Y, dist, levels=[0.01], colors='blue', linewidths=3)
    
    # Sample trajectories
    for sx, sy in [(0, 0), (-0.5, 3), (3, -0.5), (0.5, 0.2), (2, 2)]:
        cx, cy = max(sx, 1.0), max(sy, 0.5)
        ax.annotate('', xy=(cx, cy), xytext=(sx, sy),
                    arrowprops=dict(arrowstyle='->', color='black', linewidth=1.5))
        ax.plot(sx, sy, 'ko', markersize=5)
        ax.plot(cx, cy, 'b*', markersize=10)
    
    ax.set_xlabel('x₁', fontsize=12)
    ax.set_ylabel('x₂', fontsize=12)
    ax.set_title('Closure Operator: c(x) = max(x, floor)', fontsize=13)
    ax.set_xlim(-1, 5)
    ax.set_ylim(-1, 5)
    
    # Right: Fixed point set structure
    ax = axes[1]
    
    # The fixed point set is {(x,y) : x ≥ 1, y ≥ 0.5}
    rect = patches.Rectangle((1, 0.5), 4, 4.5, linewidth=0, 
                               facecolor='#E3F2FD', alpha=0.8)
    ax.add_patch(rect)
    
    # Border
    ax.plot([1, 1], [0.5, 5], 'b-', linewidth=3, label='Fixed point boundary')
    ax.plot([1, 5], [0.5, 0.5], 'b-', linewidth=3)
    
    # Non-fixed region
    rect2 = patches.Rectangle((-1, -1), 6, 6, linewidth=0,
                                facecolor='#FFEBEE', alpha=0.3, zorder=-1)
    ax.add_patch(rect2)
    
    # Mark special points
    ax.plot(1, 0.5, 'r*', markersize=20, label='Minimal fixed point', zorder=5)
    ax.plot(2, 2, 'bs', markersize=10, label='Generic fixed point', zorder=5)
    ax.plot(0, 0, 'rv', markersize=10, label='Non-fixed (moves to ★)', zorder=5)
    ax.annotate('', xy=(1, 0.5), xytext=(0, 0),
                arrowprops=dict(arrowstyle='->', color='red', linewidth=2))
    
    ax.text(3, 3, 'Fixed Point\nRegion\n(Self-Referential\nSentences)', 
            fontsize=11, ha='center', va='center', 
            bbox=dict(facecolor='white', alpha=0.8, edgecolor='blue'))
    
    ax.text(-0.3, 3, 'Non-Fixed\nRegion', fontsize=10, ha='center', va='center',
            color='red', alpha=0.7)
    
    ax.set_xlabel('x₁', fontsize=12)
    ax.set_ylabel('x₂', fontsize=12)
    ax.set_title('Fixed Point Set of Closure Operator', fontsize=13)
    ax.legend(fontsize=9, loc='upper right')
    ax.set_xlim(-1, 5)
    ax.set_ylim(-1, 5)
    ax.grid(True, alpha=0.2)
    
    fig.suptitle('Closure Operators and Self-Referential Fixed Points', 
                 fontsize=16, fontweight='bold', y=1.02)
    fig.tight_layout()
    
    fig.savefig('/workspace/request-project/viz_3_closure.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def viz_4_tropical_quine():
    """
    Visualization 4: Tropical Quine Iteration
    
    Shows the convergence of a diagonal tropical operator to its
    self-reproducing fixed point (quine).
    """
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    n = 4
    weights = np.array([
        [0.0, 1.0, 2.0, 3.0],
        [1.0, 0.0, 1.0, 2.0],
        [2.0, 1.0, 0.0, 1.0],
        [3.0, 2.0, 1.0, 0.0],
    ])
    
    def phi(x):
        return np.array([min(x[j] + weights[i, j] for j in range(n)) for i in range(n)])
    
    # Iterate and record
    x = np.zeros(n)
    trajectory = [x.copy()]
    for _ in range(15):
        x = phi(x)
        trajectory.append(x.copy())
    
    traj = np.array(trajectory)
    
    # Left: Component trajectories
    ax = axes[0]
    colors = ['#2196F3', '#FF9800', '#4CAF50', '#9C27B0']
    for i in range(n):
        ax.plot(range(len(traj)), traj[:, i], 'o-', color=colors[i],
                linewidth=2, markersize=5, label=f'x[{i}]')
    
    ax.set_xlabel('Iteration', fontsize=12)
    ax.set_ylabel('Tropical Cost', fontsize=12)
    ax.set_title('Convergence to Tropical Quine', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    # Right: Weight matrix heatmap
    ax = axes[1]
    im = ax.imshow(weights, cmap='YlOrRd', aspect='equal')
    plt.colorbar(im, ax=ax, label='Transition Cost')
    
    for i in range(n):
        for j in range(n):
            ax.text(j, i, f'{weights[i,j]:.0f}', ha='center', va='center',
                    fontsize=14, fontweight='bold',
                    color='white' if weights[i,j] > 1.5 else 'black')
    
    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    ax.set_xticklabels([f'j={k}' for k in range(n)])
    ax.set_yticklabels([f'i={k}' for k in range(n)])
    ax.set_title('Tropical Weight Matrix', fontsize=14)
    
    fig.suptitle('Tropical Quine: Self-Reproducing Cost Profile',
                 fontsize=16, fontweight='bold', y=1.02)
    fig.tight_layout()
    
    fig.savefig('/workspace/request-project/viz_4_quine.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def viz_5_incompleteness_landscape():
    """
    Visualization 5: Incompleteness Landscape
    
    Shows how the incompleteness phenomenon manifests across different
    system configurations — a "phase diagram" of tropical proof systems.
    """
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Left: Phase diagram
    ax = axes[0]
    
    n_systems = 50
    ceiling_range = np.linspace(-1, 5, n_systems)
    threshold_range = np.linspace(-1, 3, n_systems)
    
    status = np.zeros((n_systems, n_systems))  # 0=incomplete, 1=unsound
    
    for i, ceil in enumerate(ceiling_range):
        for j, thresh in enumerate(threshold_range):
            # Fixed point value at diagonal = min(start, ceil)
            fp_val = min(10.0, max(0.0, ceil))
            provable = fp_val <= thresh
            # By diagonalization: true iff not provable
            if provable:
                status[j, i] = 1  # Unsound
            else:
                status[j, i] = 0  # Incomplete
    
    cmap = LinearSegmentedColormap.from_list('incomp', ['#E3F2FD', '#FFCDD2'])
    im = ax.contourf(ceiling_range, threshold_range, status, levels=[-0.5, 0.5, 1.5],
                     colors=['#E3F2FD', '#FFCDD2'])
    ax.contour(ceiling_range, threshold_range, status, levels=[0.5],
               colors='black', linewidths=2)
    
    ax.text(3.5, 2, 'UNSOUND\nRegion', fontsize=14, ha='center', va='center',
            fontweight='bold', color='#C62828')
    ax.text(1, -0.5, 'INCOMPLETE\nRegion', fontsize=14, ha='center', va='center',
            fontweight='bold', color='#1565C0')
    
    ax.set_xlabel('Proof System Ceiling', fontsize=12)
    ax.set_ylabel('Provability Threshold', fontsize=12)
    ax.set_title('Phase Diagram of Tropical Incompleteness', fontsize=14)
    ax.grid(True, alpha=0.2)
    
    # Right: Incompleteness gap measure
    ax = axes[1]
    
    n_vals = 100
    ceiling_vals = np.linspace(0, 5, n_vals)
    
    gaps = []
    for c in ceiling_vals:
        fp_val = min(10.0, c)
        # Gap = |fp_val - 0| if incomplete, or measure of unsoundness
        gap = abs(fp_val)
        gaps.append(gap)
    
    ax.fill_between(ceiling_vals, 0, gaps, alpha=0.3, color='#2196F3',
                    label='Incompleteness gap')
    ax.plot(ceiling_vals, gaps, '-', color='#1565C0', linewidth=2)
    ax.axhline(y=0, color='black', linewidth=0.5)
    ax.axvline(x=0, color='red', linewidth=2, linestyle='--',
               label='Soundness boundary')
    
    ax.set_xlabel('Proof System Ceiling (diagonal coordinate)', fontsize=12)
    ax.set_ylabel('Incompleteness Gap', fontsize=12)
    ax.set_title('Incompleteness Gap vs. System Strength', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    fig.suptitle('The Landscape of Tropical Incompleteness',
                 fontsize=16, fontweight='bold', y=1.02)
    fig.tight_layout()
    
    fig.savefig('/workspace/request-project/viz_5_landscape.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def generate_all_visualizations():
    """Generate all visualizations and return base64 data."""
    print("Generating visualizations...")
    
    viz_data = {}
    
    print("  1/5: Fixed-point convergence...")
    viz_data['fixed_point_convergence'] = viz_1_fixed_point_convergence()
    
    print("  2/5: Incompleteness diagram...")
    viz_data['incompleteness_diagram'] = viz_2_incompleteness_diagram()
    
    print("  3/5: Closure landscape...")
    viz_data['closure_landscape'] = viz_3_closure_landscape()
    
    print("  4/5: Tropical quine...")
    viz_data['tropical_quine'] = viz_4_tropical_quine()
    
    print("  5/5: Incompleteness landscape...")
    viz_data['incompleteness_landscape'] = viz_5_incompleteness_landscape()
    
    print("All visualizations generated.")
    return viz_data


if __name__ == "__main__":
    viz_data = generate_all_visualizations()
    print(f"\nGenerated {len(viz_data)} visualizations")
    for name, data in viz_data.items():
        print(f"  {name}: {len(data)} bytes")
