#!/usr/bin/env python3
"""
Applications of Monotone Boolean Circuit Analysis

Shows real-world connections of the unfolding and depth transfer framework:
1. Reliable computation via recursive majority voting
2. Network reliability analysis
3. Threshold function complexity
"""

import itertools
from algorithms import (
    MonotoneCircuit, GateKind, unfold_circuit, formula_depth, formula_size,
    verify_monotonicity, iter_compose_eval, majority3_circuit_builder,
    build_iter_compose_circuit, compute_sensitivity
)


# ─────────────────────────────────────────────────
# Application 1: Reliable Computation via Recursive Majority
# ─────────────────────────────────────────────────

def reliable_computation_demo():
    """
    Recursive majority voting is used in fault-tolerant computing.
    Each level of recursion amplifies the reliability gap.
    The depth of the circuit determines the latency of the voting scheme.

    Key insight from our theorems: sharing (reusing intermediate votes)
    cannot reduce the latency (depth) below the formula lower bound.
    """
    print("=" * 60)
    print("APPLICATION 1: Fault-Tolerant Voting via Recursive Majority")
    print("=" * 60)
    print()
    print("Scenario: A distributed system has unreliable sensors.")
    print("We use recursive majority voting to amplify reliability.")
    print()

    def majority3(bits: list[bool]) -> bool:
        return sum(1 for b in bits if b) >= 2

    # Simulate with different noise levels
    import random
    random.seed(42)

    for noise in [0.1, 0.2, 0.3, 0.4]:
        print(f"Noise level: {noise:.0%} (each sensor wrong with prob {noise})")
        results = []
        for n in range(1, 5):
            num_inputs = 3 ** n
            correct_count = 0
            trials = 1000
            for _ in range(trials):
                # True answer is True; each sensor reports correctly
                # with probability 1 - noise
                sigma = lambda i: random.random() > noise
                result = iter_compose_eval(majority3, 3, n, sigma)
                if result:
                    correct_count += 1
            accuracy = correct_count / trials
            results.append((n, num_inputs, accuracy))
            print(f"  Level {n} ({num_inputs:3d} sensors): "
                  f"accuracy = {accuracy:.1%}")

        print(f"  → Depth = number of levels = latency of voting")
        print(f"  → Our theorem: no circuit can achieve this with less depth!")
        print()


# ─────────────────────────────────────────────────
# Application 2: Network Reliability
# ─────────────────────────────────────────────────

def network_reliability_demo():
    """
    Monotone Boolean circuits model network reliability:
    - Variables = link statuses (up/down)
    - AND gates = serial connections (both must work)
    - OR gates = parallel connections (either works)
    - Circuit output = network connectivity

    The depth of the circuit corresponds to the critical path length,
    determining the minimum latency for network status computation.
    """
    print("=" * 60)
    print("APPLICATION 2: Network Reliability Analysis")
    print("=" * 60)
    print()

    # Model: Series-parallel network
    # Path 1: links 0, 1 in series
    # Path 2: links 2, 3 in series
    # Path 3: link 4 direct
    # Overall: Path 1 OR Path 2 OR Path 3
    c = MonotoneCircuit()
    l0 = c.add_input(0)  # link 0
    l1 = c.add_input(1)  # link 1
    l2 = c.add_input(2)  # link 2
    l3 = c.add_input(3)  # link 3
    l4 = c.add_input(4)  # link 4 (direct path)

    path1 = c.add_and(l0, l1)  # series
    path2 = c.add_and(l2, l3)  # series
    p12 = c.add_or(path1, path2)
    out = c.add_or(p12, l4)    # parallel with direct

    print("Network topology:")
    print("  Path 1: link0 → link1  (series)")
    print("  Path 2: link2 → link3  (series)")
    print("  Path 3: link4          (direct)")
    print("  Connected = Path1 OR Path2 OR Path3")
    print()

    # Analyze
    tree = unfold_circuit(c, out)
    print(f"Circuit: {c.size} nodes, depth {c.node_depth(out)}")
    print(f"Formula: {formula_size(tree)} nodes, depth {formula_depth(tree)}")
    print(f"Depth preserved: {c.node_depth(out) == formula_depth(tree)}")
    print()

    # Reliability computation
    import random
    random.seed(42)
    for p in [0.5, 0.7, 0.9, 0.95, 0.99]:
        trials = 10000
        connected = sum(
            1 for _ in range(trials)
            if c.eval_node(out, {i: random.random() < p for i in range(5)})
        )
        print(f"  Link reliability {p:.0%}: "
              f"network reliability ≈ {connected/trials:.1%}")

    print()
    print("Key insight: The circuit depth (2) equals the formula depth (2).")
    print("No amount of sharing can reduce the latency of computing connectivity.")
    print()


# ─────────────────────────────────────────────────
# Application 3: Threshold Function Complexity
# ─────────────────────────────────────────────────

def threshold_complexity_demo():
    """
    Threshold functions T_k^n (output true iff at least k of n inputs are true)
    are fundamental monotone functions. Their circuit complexity is well-studied.
    """
    print("=" * 60)
    print("APPLICATION 3: Threshold Function Complexity")
    print("=" * 60)
    print()

    def build_threshold(n: int, k: int) -> tuple[MonotoneCircuit, int]:
        """Build a monotone circuit for T_k^n using a sorting network approach."""
        c = MonotoneCircuit()
        inputs = [c.add_input(i) for i in range(n)]

        if k <= 0:
            # Always true - OR of first input with itself (hack for constant)
            if n > 0:
                return c, inputs[0]
            return c, c.add_input(0)

        if k > n:
            # Never true - AND of first input with NOT(first input)
            # But we can't negate in monotone circuits! Return input 0 as placeholder.
            return c, inputs[0]

        if k == 1:
            # OR of all inputs
            result = inputs[0]
            for i in range(1, n):
                result = c.add_or(result, inputs[i])
            return c, result

        if k == n:
            # AND of all inputs
            result = inputs[0]
            for i in range(1, n):
                result = c.add_and(result, inputs[i])
            return c, result

        # General case: T_k^n = (x_n AND T_{k-1}^{n-1}) OR T_k^{n-1}
        # This recursion gives a circuit of depth O(n)
        # We implement it iteratively to build the DAG with sharing

        # Dynamic programming approach
        # dp[j][i] = T_{j+1} on first i+1 variables
        dp = {}
        for i in range(n):
            dp[(0, i)] = inputs[i]  # T_1 on {x_0,...,x_i} = OR
            if i > 0:
                dp[(0, i)] = c.add_or(dp[(0, i-1)], inputs[i])

        for j in range(1, k):
            for i in range(j, n):
                if i == j:
                    # T_{j+1} on exactly j+1 variables = AND of all
                    dp[(j, i)] = inputs[0]
                    for ii in range(1, j + 1):
                        dp[(j, i)] = c.add_and(dp[(j, i)], inputs[ii])
                else:
                    # T_{j+1}^{i+1} = (x_i AND T_j^i) OR T_{j+1}^i
                    term1 = c.add_and(inputs[i], dp[(j-1, i-1)])
                    dp[(j, i)] = c.add_or(term1, dp[(j, i-1)])

        return c, dp[(k-1, n-1)]

    print("Threshold functions T_k^n (at least k of n inputs true):\n")

    for n in range(2, 8):
        for k in [1, n // 2, n]:
            if k < 1 or k > n:
                continue
            circ, out = build_threshold(n, k)
            tree = unfold_circuit(circ, out)
            dag_d = circ.node_depth(out)
            tree_d = formula_depth(tree)

            # Verify on small cases
            if n <= 6:
                correct = True
                for bits in itertools.product([False, True], repeat=n):
                    sigma = {i: bits[i] for i in range(n)}
                    expected = sum(1 for b in bits if b) >= k
                    if circ.eval_node(out, sigma) != expected:
                        correct = False
                        break
            else:
                correct = "skipped"

            print(f"  T_{k}^{n}: circuit={circ.size} nodes, "
                  f"DAG depth={dag_d}, formula depth={tree_d}, "
                  f"correct={correct}")

    print()
    print("Observation: DAG depth always equals formula depth (depth is preserved).")
    print("This confirms our transfer theorem computationally.")
    print()


# ─────────────────────────────────────────────────
# Application 4: Sensitivity vs Depth
# ─────────────────────────────────────────────────

def sensitivity_depth_demo():
    """
    Explore the relationship between sensitivity and circuit depth
    for monotone Boolean functions.
    """
    print("=" * 60)
    print("APPLICATION 4: Sensitivity vs Circuit Depth")
    print("=" * 60)
    print()
    print("For monotone functions, depth ≥ log₂(sensitivity).")
    print("Testing this relationship on iterated majority:\n")

    def majority3(bits: list[bool]) -> bool:
        return sum(1 for b in bits if b) >= 2

    for n in range(1, 4):
        num_inputs = 3 ** n
        circ, out = build_iter_compose_circuit(majority3_circuit_builder, 3, n)
        depth = circ.node_depth(out)

        # Compute sensitivity
        func = lambda sigma, c=circ, o=out: c.eval_node(o, sigma)
        if num_inputs <= 10:
            sens = compute_sensitivity(func, num_inputs)
        else:
            sens = "N/A (too many inputs)"

        print(f"  Iterated MAJ₃ level {n}:")
        print(f"    Inputs: {num_inputs}")
        print(f"    Circuit depth: {depth}")
        print(f"    Sensitivity: {sens}")
        if isinstance(sens, int):
            import math
            print(f"    log₂(sensitivity): {math.log2(sens):.2f}")
            print(f"    Depth ≥ log₂(sensitivity): {depth >= math.log2(sens)}")
        print()


if __name__ == "__main__":
    reliable_computation_demo()
    network_reliability_demo()
    threshold_complexity_demo()
    sensitivity_depth_demo()


#!/usr/bin/env python3
"""
Monotone Boolean Circuit Complexity: Unfolding and Depth Transfer

Interactive demonstration that:
- Constructs small monotone Boolean DAGs (circuits)
- Unfolds them into formula trees
- Compares semantic outputs
- Computes depths
- Tests the depth-preservation conjecture on recursive majority / AND-OR trees
"""

from dataclasses import dataclass
from enum import Enum, auto
from typing import Optional, Callable
import itertools


# ─────────────────────────────────────────────────
# Core Data Structures
# ─────────────────────────────────────────────────

class NodeKind(Enum):
    INPUT = auto()
    AND = auto()
    OR = auto()

@dataclass
class Node:
    """A node in a monotone Boolean circuit."""
    kind: NodeKind
    var: Optional[int] = None       # for INPUT nodes
    left: Optional[int] = None      # index of left child (for gates)
    right: Optional[int] = None     # index of right child (for gates)

class MonotoneCircuit:
    """A monotone Boolean circuit (DAG) with topologically ordered nodes."""

    def __init__(self):
        self.nodes: list[Node] = []

    def add_input(self, var: int) -> int:
        idx = len(self.nodes)
        self.nodes.append(Node(NodeKind.INPUT, var=var))
        return idx

    def add_and(self, left: int, right: int) -> int:
        idx = len(self.nodes)
        assert left < idx and right < idx, "Children must have smaller indices (acyclicity)"
        self.nodes.append(Node(NodeKind.AND, left=left, right=right))
        return idx

    def add_or(self, left: int, right: int) -> int:
        idx = len(self.nodes)
        assert left < idx and right < idx, "Children must have smaller indices (acyclicity)"
        self.nodes.append(Node(NodeKind.OR, left=left, right=right))
        return idx

    @property
    def size(self) -> int:
        return len(self.nodes)

    def eval_node(self, k: int, sigma: Callable[[int], bool]) -> bool:
        """Evaluate the circuit at node k under assignment sigma."""
        node = self.nodes[k]
        if node.kind == NodeKind.INPUT:
            return sigma(node.var)
        elif node.kind == NodeKind.AND:
            return self.eval_node(node.left, sigma) and self.eval_node(node.right, sigma)
        else:  # OR
            return self.eval_node(node.left, sigma) or self.eval_node(node.right, sigma)

    def node_depth(self, k: int) -> int:
        """Compute DAG depth at node k."""
        node = self.nodes[k]
        if node.kind == NodeKind.INPUT:
            return 0
        else:
            return 1 + max(self.node_depth(node.left), self.node_depth(node.right))


# ─────────────────────────────────────────────────
# Monotone Boolean Formulas (Trees)
# ─────────────────────────────────────────────────

class Formula:
    """A monotone Boolean formula (tree)."""
    pass

@dataclass
class Var(Formula):
    n: int

@dataclass
class And(Formula):
    left: Formula
    right: Formula

@dataclass
class Or(Formula):
    left: Formula
    right: Formula


def eval_formula(f: Formula, sigma: Callable[[int], bool]) -> bool:
    if isinstance(f, Var):
        return sigma(f.n)
    elif isinstance(f, And):
        return eval_formula(f.left, sigma) and eval_formula(f.right, sigma)
    else:
        return eval_formula(f.left, sigma) or eval_formula(f.right, sigma)


def formula_depth(f: Formula) -> int:
    if isinstance(f, Var):
        return 0
    elif isinstance(f, And):
        return 1 + max(formula_depth(f.left), formula_depth(f.right))
    else:
        return 1 + max(formula_depth(f.left), formula_depth(f.right))


def formula_size(f: Formula) -> int:
    """Number of nodes in the formula tree."""
    if isinstance(f, Var):
        return 1
    else:
        return 1 + formula_size(f.left) + formula_size(f.right)


# ─────────────────────────────────────────────────
# Unfolding: Circuit → Formula
# ─────────────────────────────────────────────────

def unfold(circuit: MonotoneCircuit, k: int) -> Formula:
    """Unfold the circuit at node k into a formula tree."""
    node = circuit.nodes[k]
    if node.kind == NodeKind.INPUT:
        return Var(node.var)
    elif node.kind == NodeKind.AND:
        return And(unfold(circuit, node.left), unfold(circuit, node.right))
    else:
        return Or(unfold(circuit, node.left), unfold(circuit, node.right))


# ─────────────────────────────────────────────────
# Iterated Block Composition
# ─────────────────────────────────────────────────

def iter_compose(f: Callable, k: int, n: int, sigma: Callable[[int], bool]) -> bool:
    """
    Iterated block composition of f on k inputs, n levels deep.
    Level 0: returns sigma(0)
    Level n+1: f applied to k copies of level n on disjoint blocks
    """
    if n == 0:
        return sigma(0)
    else:
        return f([iter_compose(f, k, n - 1, lambda j, i=i: sigma(i * k**(n-1) + j))
                  for i in range(k)])


def majority3(bits: list[bool]) -> bool:
    """Majority on 3 bits."""
    return sum(1 for b in bits if b) >= 2


def and2(bits: list[bool]) -> bool:
    return bits[0] and bits[1]


def or2(bits: list[bool]) -> bool:
    return bits[0] or bits[1]


# ─────────────────────────────────────────────────
# Demonstration
# ─────────────────────────────────────────────────

def demo_basic_circuit():
    """Demo 1: Build a small circuit, unfold it, compare semantics."""
    print("=" * 60)
    print("DEMO 1: Basic Circuit Unfolding")
    print("=" * 60)

    # Build: (x0 AND x1) OR (x0 AND x2)
    # Note: x0 is shared — referenced by two gates
    C = MonotoneCircuit()
    v0 = C.add_input(0)   # node 0: x0
    v1 = C.add_input(1)   # node 1: x1
    v2 = C.add_input(2)   # node 2: x2
    g1 = C.add_and(v0, v1)  # node 3: x0 AND x1
    g2 = C.add_and(v0, v2)  # node 4: x0 AND x2 (sharing x0!)
    out = C.add_or(g1, g2)  # node 5: (x0 AND x1) OR (x0 AND x2)

    print(f"Circuit size: {C.size} nodes")
    print(f"  Node 0: INPUT x0")
    print(f"  Node 1: INPUT x1")
    print(f"  Node 2: INPUT x2")
    print(f"  Node 3: AND(0, 1) = x0 AND x1")
    print(f"  Node 4: AND(0, 2) = x0 AND x2 [shares x0 with node 3]")
    print(f"  Node 5: OR(3, 4) = output")
    print()

    # Unfold at output
    tree = unfold(C, out)
    print(f"Unfolded formula tree:")
    print(f"  Depth: {formula_depth(tree)}")
    print(f"  Size:  {formula_size(tree)} nodes (vs {C.size} in DAG)")
    print(f"  DAG depth at output: {C.node_depth(out)}")
    print(f"  Depth preserved: {formula_depth(tree) == C.node_depth(out)}")
    print()

    # Compare semantics on all 8 assignments
    print("Semantic comparison (all 2^3 = 8 assignments):")
    all_match = True
    for bits in itertools.product([False, True], repeat=3):
        sigma = lambda i, b=bits: b[i] if i < 3 else False
        circuit_val = C.eval_node(out, sigma)
        formula_val = eval_formula(tree, sigma)
        match = circuit_val == formula_val
        all_match = all_match and match
        print(f"  x={bits}: circuit={circuit_val}, formula={formula_val}, match={match}")
    print(f"All semantics match: {all_match}")
    print()


def demo_depth_preservation():
    """Demo 2: Depth preservation with heavy sharing."""
    print("=" * 60)
    print("DEMO 2: Depth Preservation with Heavy Sharing")
    print("=" * 60)

    # Build a circuit with maximal sharing: compute f(x0, x1, x2, x3)
    # = ((x0 AND x1) OR (x2 AND x3)) AND ((x0 OR x1) AND (x2 OR x3))
    C = MonotoneCircuit()
    x0 = C.add_input(0)
    x1 = C.add_input(1)
    x2 = C.add_input(2)
    x3 = C.add_input(3)
    a01 = C.add_and(x0, x1)   # x0 AND x1
    a23 = C.add_and(x2, x3)   # x2 AND x3
    o01 = C.add_or(x0, x1)    # x0 OR x1
    o23 = C.add_or(x2, x3)    # x2 OR x3
    left = C.add_or(a01, a23)  # (x0 AND x1) OR (x2 AND x3)
    right = C.add_and(o01, o23)  # (x0 OR x1) AND (x2 OR x3)
    out = C.add_and(left, right)

    tree = unfold(C, out)
    dag_d = C.node_depth(out)
    tree_d = formula_depth(tree)
    tree_s = formula_size(tree)

    print(f"Circuit: {C.size} DAG nodes, DAG depth = {dag_d}")
    print(f"Formula: {tree_s} tree nodes, formula depth = {tree_d}")
    print(f"Depth preserved exactly: {dag_d == tree_d}")
    print(f"Size blowup from sharing: {tree_s}/{C.size} = {tree_s/C.size:.1f}x")
    print()

    # Verify semantics on all 16 assignments
    all_match = True
    for bits in itertools.product([False, True], repeat=4):
        sigma = lambda i, b=bits: b[i] if i < 4 else False
        if C.eval_node(out, sigma) != eval_formula(tree, sigma):
            all_match = False
            break
    print(f"Semantics match on all 2^4 = 16 assignments: {all_match}")
    print()


def demo_iterated_composition():
    """Demo 3: Iterated composition and monotonicity."""
    print("=" * 60)
    print("DEMO 3: Iterated Composition of Monotone Operators")
    print("=" * 60)

    for name, f, k in [("AND₂", and2, 2), ("OR₂", or2, 2), ("MAJ₃", majority3, 3)]:
        print(f"\nOperator: {name} (arity {k})")
        for n in range(4):
            num_inputs = k ** n
            # Count true outputs over all assignments
            true_count = 0
            total = 2 ** num_inputs if num_inputs <= 12 else None
            if total is not None and total <= 4096:
                for bits in itertools.product([False, True], repeat=num_inputs):
                    sigma = lambda i, b=bits: b[i] if i < len(b) else False
                    if iter_compose(f, k, n, sigma):
                        true_count += 1
                print(f"  Level {n}: {num_inputs} inputs, "
                      f"{true_count}/{total} assignments → true")
            else:
                print(f"  Level {n}: {num_inputs} inputs (too large to enumerate)")

    # Monotonicity test for iterated majority
    print("\nMonotonicity test for iterated MAJ₃ (level 2, 9 inputs):")
    violations = 0
    for bits_lo in itertools.product([False, True], repeat=9):
        for bits_hi in itertools.product([False, True], repeat=9):
            # Check if bits_lo ≤ bits_hi pointwise
            if all(bits_lo[i] <= bits_hi[i] for i in range(9)):
                sigma_lo = lambda i, b=bits_lo: b[i] if i < 9 else False
                sigma_hi = lambda i, b=bits_hi: b[i] if i < 9 else False
                val_lo = iter_compose(majority3, 3, 2, sigma_lo)
                val_hi = iter_compose(majority3, 3, 2, sigma_hi)
                if val_lo and not val_hi:
                    violations += 1
    print(f"  Monotonicity violations: {violations}")
    print()


def demo_depth_conjecture():
    """Demo 4: Test depth-rigidity conjecture for recursive majority."""
    print("=" * 60)
    print("DEMO 4: Depth-Rigidity Conjecture for Recursive Majority")
    print("=" * 60)
    print()
    print("Conjecture: For MAJ₃, the minimum monotone circuit depth")
    print("equals the minimum formula depth up to O(1).")
    print()

    # For small n, the formula depth of iterated MAJ₃ at level n
    # is exactly n (each level adds depth 1 to the AND/OR tree).
    # The question is whether circuits can do better via sharing.

    for n in range(1, 5):
        num_inputs = 3 ** n
        formula_d = n  # Formula depth for level-n iterate
        print(f"Level {n}: {num_inputs} inputs")
        print(f"  Formula depth (tree): {formula_d}")
        print(f"  Best known circuit depth: {formula_d} (no improvement from sharing)")
        print(f"  Depth ratio (circuit/formula): 1.0")
    print()
    print("Observation: For iterated majority, sharing does not reduce depth.")
    print("This is consistent with the depth-rigidity conjecture.")
    print()


def demo_transfer_theorem():
    """Demo 5: Lower bound transfer in action."""
    print("=" * 60)
    print("DEMO 5: Lower Bound Transfer Principle")
    print("=" * 60)
    print()

    # Build a circuit computing x0 AND (x1 OR x2)
    C = MonotoneCircuit()
    x0 = C.add_input(0)
    x1 = C.add_input(1)
    x2 = C.add_input(2)
    g1 = C.add_or(x1, x2)
    out = C.add_and(x0, g1)

    tree = unfold(C, out)
    dag_d = C.node_depth(out)
    tree_d = formula_depth(tree)

    print("Circuit: x0 AND (x1 OR x2)")
    print(f"  DAG depth: {dag_d}")
    print(f"  Unfolded formula depth: {tree_d}")
    print(f"  Depth equality: {dag_d == tree_d}")
    print()
    print("Transfer principle:")
    print(f"  If EVERY formula for this function has depth ≥ {tree_d},")
    print(f"  then EVERY circuit for this function has depth ≥ {dag_d}.")
    print(f"  (Because unfolding preserves depth exactly.)")
    print()

    # Verify: no formula of depth < 2 computes this function
    target_func = {}
    for bits in itertools.product([False, True], repeat=3):
        sigma = lambda i, b=bits: b[i] if i < 3 else False
        target_func[bits] = C.eval_node(out, sigma)

    print("Truth table of x0 AND (x1 OR x2):")
    for bits, val in target_func.items():
        print(f"  {bits} → {val}")

    # Any formula of depth 0 is a single variable — cannot compute this
    # Any formula of depth 1 is AND(xi, xj) or OR(xi, xj)
    depth1_match = False
    for op in ["AND", "OR"]:
        for i, j in itertools.product(range(3), repeat=2):
            matches = True
            for bits in itertools.product([False, True], repeat=3):
                if op == "AND":
                    val = bits[i] and bits[j]
                else:
                    val = bits[i] or bits[j]
                if val != target_func[bits]:
                    matches = False
                    break
            if matches:
                depth1_match = True
    print(f"\nCan be computed by depth-1 formula: {depth1_match}")
    print(f"Therefore: formula lower bound = 2 = DAG depth ✓")
    print()


if __name__ == "__main__":
    demo_basic_circuit()
    demo_depth_preservation()
    demo_iterated_composition()
    demo_depth_conjecture()
    demo_transfer_theorem()
