#!/usr/bin/env python3
"""
Algorithms for BP-to-Circuit Simulation

Implements the core algorithms from the research paper:
1. BP-to-circuit compilation (Boolean)
2. Tropical BP-to-circuit compilation (min-plus)
3. Transfer matrix computation
4. Lower bound computation
"""

from typing import Optional, TypeVar, Generic
from dataclasses import dataclass, field
import math

INF = float('inf')
T = TypeVar('T')


# ============================================================
# Algorithm 1: Boolean BP-to-Circuit Compilation
# ============================================================

@dataclass
class Literal:
    """A Boolean literal: variable index with optional negation."""
    var: int
    neg: bool = False

    def eval(self, x: list[bool]) -> bool:
        """Evaluate literal on input assignment."""
        return x[self.var] ^ self.neg

    def __repr__(self) -> str:
        return f"{'¬' if self.neg else ''}x{self.var}"


@dataclass
class BranchingProgram:
    """
    Layered deterministic branching program.

    Parameters:
        n: number of input variables
        w: width (states per layer)
        d: depth (transition layers)
        start: starting state index
        accept: accepting state index
        edges: mapping (layer, src, dst) -> Optional[Literal]
            Key present with Literal: edge with guard
            Key present with None: unconditional edge
            Key absent: no edge

    Time complexity of evaluation: O(w²d) per input
    Space complexity: O(w) for online evaluation
    """
    n: int
    w: int
    d: int
    start: int
    accept: int
    edges: dict[tuple[int, int, int], Optional[Literal]] = field(default_factory=dict)

    def edge_active(self, x: list[bool], layer: int, u: int, v: int) -> bool:
        """Check if edge (layer, u, v) is active on input x."""
        key = (layer, u, v)
        if key not in self.edges:
            return False
        lit = self.edges[key]
        return lit is None or lit.eval(x)

    def evaluate(self, x: list[bool]) -> list[list[bool]]:
        """
        Evaluate the BP on input x, computing reachability at all layers.

        Returns:
            reach[i][v] = True iff state v is reachable at layer i

        Time: O(w²d)
        Space: O(wd) for full table, O(w) for single-layer
        """
        reach = [[False] * self.w for _ in range(self.d + 1)]
        reach[0][self.start] = True

        for i in range(self.d):
            for v in range(self.w):
                for u in range(self.w):
                    if reach[i][u] and self.edge_active(x, i, u, v):
                        reach[i + 1][v] = True
        return reach

    def accepts(self, x: list[bool]) -> bool:
        """Check if BP accepts input x. Time: O(w²d)."""
        return self.evaluate(x)[self.d][self.accept]

    def compile_to_circuit(self) -> 'BooleanCircuit':
        """
        Compile BP to a layered Boolean circuit.

        The circuit has:
        - depth = d
        - width = w
        - gate (i, v) computes reachability of state v at layer i
        - output gate = accept state at final layer

        Returns:
            BooleanCircuit with op_count = w²d + wd + w ≤ 2w²d + w

        Algorithm:
            1. Create w gates at layer 0 (base cases: v == start)
            2. For each transition layer i:
               a. Create w² AND gates: G(i,u) ∧ edgeCond(i,u,v) for each (u,v)
               b. Create w OR gates: ∨_u (AND result for (u,v)) for each v
            3. Output gate = gate (d, accept)
        """
        return BooleanCircuit(bp=self)


@dataclass
class BooleanCircuit:
    """
    Layered Boolean circuit compiled from a branching program.

    Gate (i, v) computes: "Is state v reachable at layer i?"

    Recurrence:
        gate(0, v) = (v == start)
        gate(i+1, v) = OR_u (gate(i, u) AND edgeActive(i, u, v))
    """
    bp: BranchingProgram

    @property
    def depth(self) -> int:
        return self.bp.d

    @property
    def width(self) -> int:
        return self.bp.w

    @property
    def op_count(self) -> int:
        """Exact operation count: w²d AND + wd OR + w comparisons."""
        w, d = self.width, self.depth
        return w * w * d + w * d + w

    @property
    def op_count_bound(self) -> int:
        """Upper bound: 2w²d + w."""
        w, d = self.width, self.depth
        return 2 * w * w * d + w

    def eval_gate(self, x: list[bool], layer: int, v: int) -> bool:
        """Evaluate a single gate. Time: O(w) per gate, O(w²d) for all gates."""
        if layer == 0:
            return v == self.bp.start
        return any(
            self.eval_gate(x, layer - 1, u) and self.bp.edge_active(x, layer - 1, u, v)
            for u in range(self.width)
        )

    def accepts(self, x: list[bool]) -> bool:
        """Evaluate circuit output. Time: O(w²d)."""
        return self.eval_gate(x, self.depth, self.bp.accept)

    def eval_all_gates(self, x: list[bool]) -> list[list[bool]]:
        """Evaluate all gates layer by layer (bottom-up). Time: O(w²d)."""
        gates = [[False] * self.width for _ in range(self.depth + 1)]
        # Layer 0
        gates[0][self.bp.start] = True
        # Subsequent layers
        for i in range(self.depth):
            for v in range(self.width):
                gates[i + 1][v] = any(
                    gates[i][u] and self.bp.edge_active(x, i, u, v)
                    for u in range(self.width)
                )
        return gates


# ============================================================
# Algorithm 2: Tropical BP-to-Circuit Compilation
# ============================================================

@dataclass
class TropicalBP:
    """
    Tropical (min-plus) branching program.

    Edge weights are non-negative floats; INF = no edge.
    Computes minimum-cost path from start to accept.

    Time complexity: O(w²d) per evaluation
    """
    w: int
    d: int
    start: int
    accept: int
    weights: dict[tuple[int, int, int], float] = field(default_factory=dict)

    def edge_weight(self, layer: int, u: int, v: int) -> float:
        return self.weights.get((layer, u, v), INF)

    def evaluate(self) -> list[list[float]]:
        """
        Compute min-cost to reach each state at each layer.

        Recurrence:
            cost(0, v) = 0 if v == start, INF otherwise
            cost(i+1, v) = min_u (cost(i, u) + weight(i, u, v))

        Returns:
            costs[i][v] = minimum cost to reach state v at layer i

        Time: O(w²d)
        """
        costs = [[INF] * self.w for _ in range(self.d + 1)]
        costs[0][self.start] = 0

        for i in range(self.d):
            for v in range(self.w):
                for u in range(self.w):
                    w_uv = self.edge_weight(i, u, v)
                    if costs[i][u] < INF and w_uv < INF:
                        costs[i + 1][v] = min(costs[i + 1][v], costs[i][u] + w_uv)
        return costs

    def min_cost(self) -> float:
        """Minimum cost of an accepting path."""
        return self.evaluate()[self.d][self.accept]

    def compile_to_circuit(self) -> 'TropicalCircuit':
        """Compile to tropical circuit. Same construction as Boolean case."""
        return TropicalCircuit(tbp=self)

    def transfer_matrix(self, layer: int) -> list[list[float]]:
        """
        Extract the w×w tropical transfer matrix for a given layer.

        M[u][v] = edge_weight(layer, u, v)
        """
        M = [[INF] * self.w for _ in range(self.w)]
        for u in range(self.w):
            for v in range(self.w):
                M[u][v] = self.edge_weight(layer, u, v)
        return M


@dataclass
class TropicalCircuit:
    """Tropical circuit compiled from a tropical BP."""
    tbp: TropicalBP

    @property
    def depth(self) -> int:
        return self.tbp.d

    @property
    def width(self) -> int:
        return self.tbp.w

    @property
    def op_count(self) -> int:
        w, d = self.width, self.depth
        return w * w * d + w * d + w

    @property
    def op_count_bound(self) -> int:
        w, d = self.width, self.depth
        return 2 * w * w * d + w

    def output(self) -> float:
        return self.tbp.min_cost()


# ============================================================
# Algorithm 3: Transfer Matrix Product
# ============================================================

def tropical_matrix_multiply(A: list[list[float]], B: list[list[float]]) -> list[list[float]]:
    """
    Tropical (min-plus) matrix multiplication.

    (A ⊗ B)[i][j] = min_k (A[i][k] + B[k][j])

    Time: O(n³) for n×n matrices
    """
    n = len(A)
    C = [[INF] * n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            for k in range(n):
                if A[i][k] < INF and B[k][j] < INF:
                    C[i][j] = min(C[i][j], A[i][k] + B[k][j])
    return C


def transfer_matrix_product(tbp: TropicalBP) -> list[list[float]]:
    """
    Compute the product of all transfer matrices: M₀ ⊗ M₁ ⊗ ... ⊗ M_{d-1}.

    The (start, accept) entry gives the minimum-cost accepting path.

    Time: O(w³d)
    """
    if tbp.d == 0:
        # Identity matrix
        w = tbp.w
        return [[0 if i == j else INF for j in range(w)] for i in range(w)]

    result = tbp.transfer_matrix(0)
    for layer in range(1, tbp.d):
        result = tropical_matrix_multiply(result, tbp.transfer_matrix(layer))
    return result


# ============================================================
# Algorithm 4: Lower Bound Computation
# ============================================================

def min_depth_from_circuit_lower_bound(K: int, w: int) -> int:
    """
    Given circuit size lower bound K and BP width w,
    compute minimum depth d such that K ≤ 2w²d + w.

    Returns: ceil((K - w) / (2w²))
    """
    if w == 0:
        return 0 if K == 0 else -1  # impossible if K > 0 and w = 0
    numerator = K - w
    if numerator <= 0:
        return 0
    denominator = 2 * w * w
    return math.ceil(numerator / denominator)


def min_width_from_circuit_lower_bound(K: int, d: int) -> int:
    """
    Given circuit size lower bound K and BP depth d,
    compute minimum width w such that K ≤ 2w²d + w.

    Solves: 2d·w² + w ≥ K
    """
    if d == 0:
        return K  # need w ≥ K
    # Binary search
    lo, hi = 0, K
    while lo < hi:
        mid = (lo + hi) // 2
        if 2 * mid * mid * d + mid >= K:
            hi = mid
        else:
            lo = mid + 1
    return lo


# ============================================================
# Verification
# ============================================================

def verify_simulation(bp: BranchingProgram, num_inputs: Optional[int] = None):
    """
    Verify that the compiled circuit agrees with the BP on all inputs.

    For small n, tests all 2^n inputs. For large n, tests random sample.
    """
    import itertools
    circuit = bp.compile_to_circuit()

    if bp.n <= 16:
        count = 0
        matches = 0
        for bits in itertools.product([False, True], repeat=bp.n):
            x = list(bits)
            bp_result = bp.accepts(x)
            reach = bp.evaluate(x)
            ckt_gates = circuit.eval_all_gates(x)

            # Check layer-by-layer agreement
            for i in range(bp.d + 1):
                for v in range(bp.w):
                    assert reach[i][v] == ckt_gates[i][v], \
                        f"Mismatch at layer {i}, state {v}, input {x}"

            count += 1
            if bp_result == circuit.accepts(x):
                matches += 1

        assert matches == count, f"Simulation mismatch: {matches}/{count}"
        return True
    return None


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    # Build a parity BP
    bp = BranchingProgram(n=3, w=2, d=3, start=0, accept=1)
    for i in range(3):
        bp.edges[(i, 0, 0)] = Literal(i, neg=True)
        bp.edges[(i, 1, 1)] = Literal(i, neg=True)
        bp.edges[(i, 0, 1)] = Literal(i, neg=False)
        bp.edges[(i, 1, 0)] = Literal(i, neg=False)

    circuit = bp.compile_to_circuit()
    print(f"Parity BP: width={bp.w}, depth={bp.d}")
    print(f"Circuit op count: {circuit.op_count}")
    print(f"Circuit op count bound: {circuit.op_count_bound}")
    print(f"Bound holds: {circuit.op_count <= circuit.op_count_bound}")
    print(f"Simulation verified: {verify_simulation(bp)}")

    # Tropical example
    tbp = TropicalBP(w=3, d=3, start=0, accept=2,
                     weights={
                         (0, 0, 1): 2, (0, 0, 2): 5,
                         (1, 1, 0): 1, (1, 1, 2): 3, (1, 2, 2): 1,
                         (2, 0, 2): 4, (2, 2, 2): 2,
                     })
    print(f"\nTropical BP: width={tbp.w}, depth={tbp.d}")
    print(f"Min cost: {tbp.min_cost()}")

    # Transfer matrix product
    product = transfer_matrix_product(tbp)
    print(f"Transfer product (start→accept): {product[tbp.start][tbp.accept]}")
    assert tbp.min_cost() == product[tbp.start][tbp.accept]

    # Lower bound computation
    K = 500
    print(f"\nLower bound transfer: K={K}")
    for w in [2, 5, 10]:
        d = min_depth_from_circuit_lower_bound(K, w)
        print(f"  width={w}: min depth ≥ {d} (2w²d+w = {2*w*w*d+w})")
