#!/usr/bin/env python3
"""
Algorithms for Monotone Boolean Circuit Analysis

Implements:
1. Circuit construction and evaluation
2. DAG-to-formula unfolding
3. Depth analysis (DAG depth and formula depth)
4. Exhaustive search for shallow monotone circuits
5. Monotonicity verification
"""

from dataclasses import dataclass, field
from enum import Enum, auto
from typing import Optional, Callable, Iterator
import itertools


# ─────────────────────────────────────────────────
# 1. Circuit Construction and Evaluation
# ─────────────────────────────────────────────────

class GateKind(Enum):
    INPUT = auto()
    AND = auto()
    OR = auto()

@dataclass
class CircuitNode:
    """A node in a monotone Boolean circuit."""
    kind: GateKind
    var: Optional[int] = None
    left: Optional[int] = None
    right: Optional[int] = None


class MonotoneCircuit:
    """
    A monotone Boolean circuit (DAG) with topologically ordered vertices.

    Vertices are numbered 0, 1, ..., size-1.
    Gate children must have strictly smaller indices (acyclicity invariant).

    Time complexity:
      - add_input, add_and, add_or: O(1)
      - eval_node: O(size) worst case (memoized: O(size))
      - node_depth: O(size) worst case
    Space complexity: O(size)
    """

    def __init__(self):
        self.nodes: list[CircuitNode] = []

    def add_input(self, var: int) -> int:
        """Add an input node for variable `var`. Returns node index."""
        idx = len(self.nodes)
        self.nodes.append(CircuitNode(GateKind.INPUT, var=var))
        return idx

    def add_and(self, left: int, right: int) -> int:
        """Add an AND gate. Returns node index."""
        idx = len(self.nodes)
        assert 0 <= left < idx and 0 <= right < idx
        self.nodes.append(CircuitNode(GateKind.AND, left=left, right=right))
        return idx

    def add_or(self, left: int, right: int) -> int:
        """Add an OR gate. Returns node index."""
        idx = len(self.nodes)
        assert 0 <= left < idx and 0 <= right < idx
        self.nodes.append(CircuitNode(GateKind.OR, left=left, right=right))
        return idx

    @property
    def size(self) -> int:
        return len(self.nodes)

    def eval_node(self, k: int, sigma: dict[int, bool]) -> bool:
        """
        Evaluate node k under assignment sigma (dict mapping var -> bool).
        Uses memoization for efficiency.

        Time: O(size), Space: O(size)
        """
        memo: dict[int, bool] = {}

        def go(i: int) -> bool:
            if i in memo:
                return memo[i]
            node = self.nodes[i]
            if node.kind == GateKind.INPUT:
                result = sigma.get(node.var, False)
            elif node.kind == GateKind.AND:
                result = go(node.left) and go(node.right)
            else:
                result = go(node.left) or go(node.right)
            memo[i] = result
            return result

        return go(k)

    def node_depth(self, k: int) -> int:
        """
        Compute DAG depth at node k (longest dependency chain).

        Time: O(size), Space: O(size)
        """
        memo: dict[int, int] = {}

        def go(i: int) -> int:
            if i in memo:
                return memo[i]
            node = self.nodes[i]
            if node.kind == GateKind.INPUT:
                result = 0
            else:
                result = 1 + max(go(node.left), go(node.right))
            memo[i] = result
            return result

        return go(k)

    def all_depths(self) -> list[int]:
        """Compute depth at every node. Time: O(size)."""
        return [self.node_depth(i) for i in range(self.size)]

    def verify_acyclicity(self) -> bool:
        """Verify the topological ordering invariant."""
        for i, node in enumerate(self.nodes):
            if node.kind != GateKind.INPUT:
                if node.left >= i or node.right >= i:
                    return False
        return True

    def truth_table(self, output: int, num_vars: int) -> dict[tuple[bool, ...], bool]:
        """Compute the complete truth table for the output node."""
        table = {}
        for bits in itertools.product([False, True], repeat=num_vars):
            sigma = {i: bits[i] for i in range(num_vars)}
            table[bits] = self.eval_node(output, sigma)
        return table


# ─────────────────────────────────────────────────
# 2. Formula (Tree) Representation
# ─────────────────────────────────────────────────

class Formula:
    """Base class for monotone Boolean formulas."""
    pass

@dataclass
class VarF(Formula):
    n: int

@dataclass
class AndF(Formula):
    left: Formula
    right: Formula

@dataclass
class OrF(Formula):
    left: Formula
    right: Formula


def eval_formula(f: Formula, sigma: dict[int, bool]) -> bool:
    """Evaluate a formula under assignment sigma."""
    if isinstance(f, VarF):
        return sigma.get(f.n, False)
    elif isinstance(f, AndF):
        return eval_formula(f.left, sigma) and eval_formula(f.right, sigma)
    else:
        return eval_formula(f.left, sigma) or eval_formula(f.right, sigma)


def formula_depth(f: Formula) -> int:
    """Compute the depth of a formula (longest root-to-leaf path)."""
    if isinstance(f, VarF):
        return 0
    else:
        return 1 + max(formula_depth(f.left), formula_depth(f.right))


def formula_size(f: Formula) -> int:
    """Count nodes in the formula tree."""
    if isinstance(f, VarF):
        return 1
    else:
        return 1 + formula_size(f.left) + formula_size(f.right)


def formula_vars(f: Formula) -> set[int]:
    """Collect all variable indices in the formula."""
    if isinstance(f, VarF):
        return {f.n}
    else:
        return formula_vars(f.left) | formula_vars(f.right)


# ─────────────────────────────────────────────────
# 3. DAG-to-Formula Unfolding
# ─────────────────────────────────────────────────

def unfold_circuit(circuit: MonotoneCircuit, k: int) -> Formula:
    """
    Unfold the circuit DAG at node k into a formula tree.

    This duplicates shared subcircuits along every root-to-leaf path.
    Depth is preserved exactly; size may increase exponentially.

    Time: O(formula_size) which can be exponential in circuit size.
    Space: O(formula_size)
    """
    node = circuit.nodes[k]
    if node.kind == GateKind.INPUT:
        return VarF(node.var)
    elif node.kind == GateKind.AND:
        return AndF(unfold_circuit(circuit, node.left),
                    unfold_circuit(circuit, node.right))
    else:
        return OrF(unfold_circuit(circuit, node.left),
                   unfold_circuit(circuit, node.right))


def verify_unfolding(circuit: MonotoneCircuit, output: int, num_vars: int) -> bool:
    """
    Verify that unfolding preserves semantics on all 2^num_vars assignments.

    Time: O(2^num_vars * size)
    """
    tree = unfold_circuit(circuit, output)
    for bits in itertools.product([False, True], repeat=num_vars):
        sigma = {i: bits[i] for i in range(num_vars)}
        sigma_func = lambda i, s=sigma: s.get(i, False)
        if circuit.eval_node(output, sigma) != eval_formula(tree, sigma):
            return False
    return True


# ─────────────────────────────────────────────────
# 4. Exhaustive Search for Shallow Circuits
# ─────────────────────────────────────────────────

def search_circuit(target_table: dict[tuple[bool, ...], bool],
                   num_vars: int,
                   max_depth: int,
                   max_gates: int = 20) -> Optional[MonotoneCircuit]:
    """
    Search for a monotone circuit computing the target function
    within the given depth and size bounds.

    Uses iterative deepening: tries circuits with 0, 1, 2, ... gates
    up to max_gates, and checks if any computes the target within max_depth.

    Time: O(max_gates^3 * 2^num_vars) roughly
    Returns: MonotoneCircuit if found, None otherwise
    """
    # Start with just input nodes
    for num_gates in range(max_gates + 1):
        for config in _enumerate_circuits(num_vars, num_gates):
            circuit, output = config
            if circuit.node_depth(output) <= max_depth:
                # Check if it computes the target
                matches = True
                for bits, expected in target_table.items():
                    sigma = {i: bits[i] for i in range(num_vars)}
                    if circuit.eval_node(output, sigma) != expected:
                        matches = False
                        break
                if matches:
                    return circuit
    return None


def _enumerate_circuits(num_vars: int, num_gates: int) -> Iterator:
    """
    Enumerate all monotone circuits with given number of variables and gates.
    Yields (circuit, output_index) tuples.
    """
    if num_gates == 0:
        for v in range(num_vars):
            c = MonotoneCircuit()
            idx = c.add_input(v)
            yield (c, idx)
        return

    # Build circuits incrementally
    # Base: num_vars input nodes
    # Then add num_gates gates, each choosing kind (AND/OR) and two earlier nodes
    total_nodes = num_vars + num_gates

    for gate_configs in itertools.product(
        *[list(itertools.product([GateKind.AND, GateKind.OR],
                                  range(num_vars + i),
                                  range(num_vars + i)))
          for i in range(num_gates)]
    ):
        c = MonotoneCircuit()
        for v in range(num_vars):
            c.add_input(v)

        valid = True
        for kind, left, right in gate_configs:
            try:
                if kind == GateKind.AND:
                    c.add_and(left, right)
                else:
                    c.add_or(left, right)
            except AssertionError:
                valid = False
                break

        if valid:
            # Output is the last node
            yield (c, total_nodes - 1)


# ─────────────────────────────────────────────────
# 5. Monotonicity Verification
# ─────────────────────────────────────────────────

def verify_monotonicity(func: Callable[[dict[int, bool]], bool],
                        num_vars: int) -> bool:
    """
    Verify that a Boolean function is monotone by exhaustive check.

    A function is monotone if: whenever sigma ≤ tau pointwise,
    func(sigma) ≤ func(tau).

    Time: O(3^num_vars) — for each variable, check 0→0, 0→1, 1→1
    """
    for bits_lo in itertools.product([False, True], repeat=num_vars):
        for bits_hi in itertools.product([False, True], repeat=num_vars):
            if all(bits_lo[i] <= bits_hi[i] for i in range(num_vars)):
                sigma_lo = {i: bits_lo[i] for i in range(num_vars)}
                sigma_hi = {i: bits_hi[i] for i in range(num_vars)}
                if func(sigma_lo) and not func(sigma_hi):
                    return False
    return True


def compute_sensitivity(func: Callable[[dict[int, bool]], bool],
                        num_vars: int) -> int:
    """
    Compute the sensitivity of a Boolean function:
    max over inputs x of the number of coordinates i such that
    flipping x_i changes f(x).

    Time: O(num_vars * 2^num_vars)
    """
    max_sens = 0
    for bits in itertools.product([False, True], repeat=num_vars):
        sigma = {i: bits[i] for i in range(num_vars)}
        base_val = func(sigma)
        sens = 0
        for i in range(num_vars):
            flipped = dict(sigma)
            flipped[i] = not flipped[i]
            if func(flipped) != base_val:
                sens += 1
        max_sens = max(max_sens, sens)
    return max_sens


# ─────────────────────────────────────────────────
# 6. Iterated Block Composition
# ─────────────────────────────────────────────────

def iter_compose_eval(f: Callable[[list[bool]], bool],
                      k: int, n: int,
                      sigma: Callable[[int], bool]) -> bool:
    """
    Evaluate the n-fold block composition of f (arity k).

    Level 0: sigma(0)
    Level n+1: f applied to k blocks of level-n evaluations

    Time: O(k^n)
    """
    if n == 0:
        return sigma(0)
    return f([iter_compose_eval(f, k, n - 1,
              lambda j, i=i: sigma(i * k**(n-1) + j))
              for i in range(k)])


def build_iter_compose_circuit(f_circuit_builder: Callable,
                               k: int, n: int) -> tuple[MonotoneCircuit, int]:
    """
    Build a circuit for the n-fold block composition of f.

    f_circuit_builder(circuit, inputs) -> output_idx
    adds a copy of f's circuit to the given circuit with the given inputs.

    Returns (circuit, output_node).
    """
    c = MonotoneCircuit()
    num_inputs = k ** n
    inputs = [c.add_input(i) for i in range(num_inputs)]

    def build_level(level: int, base: int) -> int:
        if level == 0:
            return inputs[base]
        block_size = k ** (level - 1)
        children = [build_level(level - 1, base + i * block_size)
                    for i in range(k)]
        return f_circuit_builder(c, children)

    output = build_level(n, 0)
    return c, output


def majority3_circuit_builder(c: MonotoneCircuit, inputs: list[int]) -> int:
    """Build MAJ₃ circuit: (x∧y) ∨ (x∧z) ∨ (y∧z)."""
    assert len(inputs) == 3
    x, y, z = inputs
    xy = c.add_and(x, y)
    xz = c.add_and(x, z)
    yz = c.add_and(y, z)
    xy_or_xz = c.add_or(xy, xz)
    return c.add_or(xy_or_xz, yz)


def and2_circuit_builder(c: MonotoneCircuit, inputs: list[int]) -> int:
    assert len(inputs) == 2
    return c.add_and(inputs[0], inputs[1])


def or2_circuit_builder(c: MonotoneCircuit, inputs: list[int]) -> int:
    assert len(inputs) == 2
    return c.add_or(inputs[0], inputs[1])


# ─────────────────────────────────────────────────
# Example Usage
# ─────────────────────────────────────────────────

if __name__ == "__main__":
    print("=== Algorithm Examples ===\n")

    # 1. Build and analyze a circuit
    c = MonotoneCircuit()
    x0 = c.add_input(0)
    x1 = c.add_input(1)
    x2 = c.add_input(2)
    g = c.add_and(x0, x1)
    out = c.add_or(g, x2)
    print(f"Circuit: (x0 AND x1) OR x2")
    print(f"  Size: {c.size}, Depth: {c.node_depth(out)}")
    print(f"  Acyclic: {c.verify_acyclicity()}")

    # 2. Unfold and verify
    tree = unfold_circuit(c, out)
    print(f"  Formula depth: {formula_depth(tree)}, size: {formula_size(tree)}")
    print(f"  Unfolding verified: {verify_unfolding(c, out, 3)}")

    # 3. Monotonicity check
    func = lambda sigma: c.eval_node(out, sigma)
    print(f"  Monotone: {verify_monotonicity(func, 3)}")
    print(f"  Sensitivity: {compute_sensitivity(func, 3)}")

    # 4. Iterated majority
    print("\n--- Iterated MAJ₃ circuits ---")
    for n in range(1, 4):
        circ, output = build_iter_compose_circuit(majority3_circuit_builder, 3, n)
        d = circ.node_depth(output)
        print(f"  Level {n}: {circ.size} nodes, depth {d}, "
              f"inputs: {3**n}")
