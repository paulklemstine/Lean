#!/usr/bin/env python3
"""
Algorithms for Gate-Level Quantum Circuit Synthesis from Matroid Certificates

Implements:
1. Certificate tree construction for uniform matroids
2. Certificate-to-circuit conversion with controlled rotations
3. Classical simulation of the synthesized circuit
4. Total variation distance computation
"""

import math
from dataclasses import dataclass, field
from typing import List, Tuple, Optional, Dict, Set, FrozenSet
from itertools import combinations


# ============================================================
# Data Structures
# ============================================================

@dataclass
class CertTreeNode:
    """Node in a certificate tree."""
    is_leaf: bool
    element: Optional[int] = None   # branch element
    edges: Optional[FrozenSet[int]] = None  # leaf edges
    weight: float = 1.0
    delete: Optional['CertTreeNode'] = None
    contract: Optional['CertTreeNode'] = None

    @staticmethod
    def leaf(edges: Set[int], weight: float = 1.0) -> 'CertTreeNode':
        return CertTreeNode(is_leaf=True, edges=frozenset(edges), weight=weight)

    @staticmethod
    def branch(element: int, delete: 'CertTreeNode', contract: 'CertTreeNode',
               weight: float = 1.0) -> 'CertTreeNode':
        return CertTreeNode(is_leaf=False, element=element,
                          delete=delete, contract=contract, weight=weight)


@dataclass
class QuantumGate:
    """Controlled-Ry rotation gate."""
    target: int
    controls: List[int]
    control_values: List[int]  # 0 or 1 for each control
    angle: float

    def __repr__(self):
        if not self.controls:
            return f"Ry(q{self.target}, θ={self.angle:.6f})"
        ctrl = ", ".join(f"q{c}={'|1⟩' if v else '|0⟩'}"
                        for c, v in zip(self.controls, self.control_values))
        return f"CRy(q{self.target}, θ={self.angle:.6f} | {ctrl})"


@dataclass
class SynthesizedCircuit:
    """Complete quantum circuit from certificate synthesis."""
    gates: List[QuantumGate]
    num_qubits: int
    num_data_qubits: int
    num_ancilla: int
    depth: int

    @property
    def gate_count(self) -> int:
        return len(self.gates)


# ============================================================
# Algorithm 1: Uniform Matroid Certificate Construction
# ============================================================

def build_uniform_matroid_cert(n: int, r: int, weights: Optional[List[float]] = None) -> CertTreeNode:
    """
    Build a certificate tree for the uniform matroid U(r,n).

    The uniform matroid U(r,n) has ground set [n] and all r-element subsets
    as bases. We construct the certificate tree by deletion/contraction
    on elements 0, 1, ..., n-1 in order.

    For element e:
    - Deletion (M \\ e): U(r, n-1) on remaining elements
    - Contraction (M / e): U(r-1, n-1) on remaining elements

    Time: O(n)  Space: O(n)

    Args:
        n: Ground set size
        r: Rank
        weights: Optional element weights (default: all 1.0)

    Returns:
        Certificate tree root
    """
    if weights is None:
        weights = [1.0] * n

    elements = list(range(n))

    def _build(elts: List[int], rank: int) -> CertTreeNode:
        if rank == 0:
            # Only basis is empty set, weight = 1
            return CertTreeNode.leaf(set(), weight=1.0)
        if rank == len(elts):
            # Only basis is the full set
            w = 1.0
            for e in elts:
                w *= weights[e]
            return CertTreeNode.leaf(set(elts), weight=w)
        if rank > len(elts) or rank < 0:
            # No bases exist
            return CertTreeNode.leaf(set(), weight=0.0)

        e = elts[0]
        rest = elts[1:]

        delete_tree = _build(rest, rank)       # M \ e: rank stays, n decreases
        contract_tree = _build(rest, rank - 1)  # M / e: rank decreases too

        return CertTreeNode.branch(e, delete_tree, contract_tree, weight=weights[e])

    return _build(elements, r)


# ============================================================
# Algorithm 2: Partition Function and Circuit Conversion
# ============================================================

def partition_function(t: CertTreeNode) -> float:
    """
    Compute the matroid partition function Z(t) correctly, accounting
    for element weights at contraction nodes.

    Z(leaf) = leaf.weight
    Z(branch e) = Z(delete) + w(e) * Z(contract)

    This gives Z(M) = Σ_{B basis} ∏_{i∈B} w_i.

    Time: O(|t|) where |t| is tree size
    """
    if t.is_leaf:
        return t.weight
    return partition_function(t.delete) + t.weight * partition_function(t.contract)


def compute_branch_angle(z_del: float, z_con: float) -> float:
    """
    Compute the rotation angle for a branch node.

    θ = 2 · arctan(√(z_del / z_con))

    This angle ensures:
    - cos²(θ/2) = z_con / (z_del + z_con)  [contraction probability]
    - sin²(θ/2) = z_del / (z_del + z_con)  [deletion probability]

    Time: O(1)
    """
    if z_con <= 0:
        return math.pi  # all weight on deletion
    if z_del <= 0:
        return 0.0      # all weight on contraction
    return 2.0 * math.atan(math.sqrt(z_del / z_con))


def cert_to_circuit(t: CertTreeNode) -> SynthesizedCircuit:
    """
    Convert a certificate tree to a quantum circuit.

    Each branch node maps to one controlled-Ry gate. The controls
    encode the path from root to the current node (which previous
    elements were deleted vs contracted).

    Time: O(|t|)  Space: O(depth(t)) for gate descriptions

    Args:
        t: Certificate tree root

    Returns:
        SynthesizedCircuit with gate list and resource counts
    """
    gates = []
    max_qubit = [0]

    def _convert(node: CertTreeNode, qubit_idx: int, controls: List[int],
                 control_values: List[int]):
        if node.is_leaf:
            return

        z_del = partition_function(node.delete)
        z_con = node.weight * partition_function(node.contract)
        angle = compute_branch_angle(z_del, z_con)

        gate = QuantumGate(
            target=qubit_idx,
            controls=list(controls),
            control_values=list(control_values),
            angle=angle
        )
        gates.append(gate)
        max_qubit[0] = max(max_qubit[0], qubit_idx)

        # Deletion branch: qubit in |1⟩
        _convert(node.delete, qubit_idx + 1,
                controls + [qubit_idx], control_values + [1])

        # Contraction branch: qubit in |0⟩
        _convert(node.contract, qubit_idx + 1,
                controls + [qubit_idx], control_values + [0])

    _convert(t, 0, [], [])

    n_qubits = max_qubit[0] + 1 if gates else 0
    depth = _tree_depth(t)

    return SynthesizedCircuit(
        gates=gates,
        num_qubits=n_qubits,
        num_data_qubits=depth,
        num_ancilla=max(0, n_qubits - depth),
        depth=depth
    )


def _tree_depth(t: CertTreeNode) -> int:
    if t.is_leaf:
        return 0
    return 1 + max(_tree_depth(t.delete), _tree_depth(t.contract))


# ============================================================
# Algorithm 3: Classical Circuit Simulation
# ============================================================

def simulate_circuit(t: CertTreeNode) -> Dict[FrozenSet[int], float]:
    """
    Classically simulate the quantum circuit to get output probabilities.

    Instead of full state-vector simulation, we trace the amplitudes
    through the tree structure directly.

    Time: O(|t|)  Space: O(leaves(t))

    Returns:
        Dict mapping basis sets to probabilities
    """
    result = {}

    def _simulate(node: CertTreeNode, amplitude: float, selected: Set[int]):
        if node.is_leaf:
            # Include both contracted elements and remaining leaf elements
            basis = frozenset(selected | (set(node.edges) if node.edges else set()))
            result[basis] = result.get(basis, 0.0) + amplitude ** 2
            return

        z_del = partition_function(node.delete)
        z_con = node.weight * partition_function(node.contract)
        z_total = z_del + z_con

        if z_total <= 0:
            return

        # Deletion: element not selected
        a_del = amplitude * math.sqrt(z_del / z_total)
        _simulate(node.delete, a_del, selected)

        # Contraction: element selected
        a_con = amplitude * math.sqrt(z_con / z_total)
        _simulate(node.contract, a_con, selected | {node.element})

    _simulate(t, 1.0, set())
    return result


def exact_basis_distribution(n: int, r: int, weights: List[float]) -> Dict[FrozenSet[int], float]:
    """
    Compute the exact weighted basis distribution for U(r,n).

    P(B) = (∏_{i∈B} w_i) / Z  where Z = Σ_B ∏_{i∈B} w_i

    Time: O(C(n,r) * r)
    """
    elements = list(range(n))
    dist = {}
    z_total = 0.0

    for basis in combinations(elements, r):
        w = 1.0
        for i in basis:
            w *= weights[i]
        basis_set = frozenset(basis)
        dist[basis_set] = w
        z_total += w

    # Normalize
    for b in dist:
        dist[b] /= z_total

    return dist


def total_variation_distance(p: Dict, q: Dict) -> float:
    """
    Compute total variation distance TV(p, q) = 0.5 * Σ|p(x) - q(x)|.

    Time: O(|support(p) ∪ support(q)|)
    """
    all_keys = set(p.keys()) | set(q.keys())
    return 0.5 * sum(abs(p.get(k, 0.0) - q.get(k, 0.0)) for k in all_keys)


# ============================================================
# Algorithm 4: Depth and Gate Count Analysis
# ============================================================

def analyze_circuit_resources(t: CertTreeNode) -> Dict:
    """
    Analyze resource requirements of the synthesized circuit.

    Returns dict with depth, gate_count, leaf_count, branch_count,
    and verification of structural identities.
    """
    def _branch_count(node):
        if node.is_leaf: return 0
        return 1 + _branch_count(node.delete) + _branch_count(node.contract)

    def _leaf_count(node):
        if node.is_leaf: return 1
        return _leaf_count(node.delete) + _leaf_count(node.contract)

    bc = _branch_count(t)
    lc = _leaf_count(t)
    d = _tree_depth(t)
    circuit = cert_to_circuit(t)

    return {
        'depth': d,
        'branch_count': bc,
        'leaf_count': lc,
        'gate_count': circuit.gate_count,
        'num_qubits': circuit.num_qubits,
        'identity_holds': lc == bc + 1,
        'depth_bound_holds': d <= bc,
        'exp_bound_holds': bc < 2 ** (d + 1),
    }


# ============================================================
# Main: Run all algorithms on example matroids
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("  Quantum Circuit Synthesis Algorithms")
    print("=" * 60)

    # Test for small uniform matroids
    test_cases = [
        (4, 2, "U(2,4)"),
        (5, 2, "U(2,5)"),
        (5, 3, "U(3,5)"),
        (6, 3, "U(3,6)"),
        (6, 2, "U(2,6)"),
        (8, 4, "U(4,8)"),
    ]

    for n, r, name in test_cases:
        weights = [1.0 + 0.1 * i for i in range(n)]
        cert = build_uniform_matroid_cert(n, r, weights)

        # Simulate circuit
        circuit_dist = simulate_circuit(cert)
        exact_dist = exact_basis_distribution(n, r, weights)
        tvd = total_variation_distance(circuit_dist, exact_dist)

        # Analyze resources
        resources = analyze_circuit_resources(cert)

        print(f"\n{name} (n={n}, r={r}):")
        print(f"  Depth:        {resources['depth']}")
        print(f"  Gate count:   {resources['gate_count']}")
        print(f"  Leaf count:   {resources['leaf_count']}")
        print(f"  Branch count: {resources['branch_count']}")
        print(f"  Structural identity (lc = bc+1): {resources['identity_holds']}")
        print(f"  Depth bound (d ≤ bc):            {resources['depth_bound_holds']}")
        print(f"  Exponential bound (bc < 2^(d+1)):{resources['exp_bound_holds']}")
        print(f"  TV distance from exact:          {tvd:.2e}")
        print(f"  Matches exact to 10⁻¹⁰?          {tvd < 1e-10}")
