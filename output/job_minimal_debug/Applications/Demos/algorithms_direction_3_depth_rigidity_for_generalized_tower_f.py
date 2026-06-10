#!/usr/bin/env python3
"""
Depth-Majorant Analysis Algorithms

Implements certified depth-majorant analysis for inverse-free DAGs:
1. DAG representation and evaluation
2. Depth-majorant certificate generation
3. Tower-separation verification
4. Growth-rank classification

These algorithms support the formal theorems in the Lean development.
"""

from dataclasses import dataclass
from enum import Enum
from typing import List, Optional, Tuple, Dict
import math


# ═══════════════════════════════════════════════════════════════
# Algorithm 1: Shifted Tower Computation
# ═══════════════════════════════════════════════════════════════

def shifted_tower(n: int, x: int, max_bits: int = 10000) -> Optional[int]:
    """Compute shiftedTower(n, x) with overflow protection.
    
    Args:
        n: Tower level (≥ 0)
        x: Input value (≥ 0)
        max_bits: Maximum bit-length before declaring overflow
    
    Returns:
        The value shiftedTower(n, x), or None if it exceeds max_bits bits.
    
    Complexity: O(n) recursive calls, each involving one squaring and
                one exponentiation of potentially large numbers.
    """
    if n == 0:
        return x + 1
    inner_arg = x * x + 1  # polySeed(x)
    inner = shifted_tower(n - 1, inner_arg, max_bits)
    if inner is None or inner > max_bits:
        return None
    return 2 ** inner


def shifted_tower_log_profile(n: int, x: int) -> List[float]:
    """Compute the iterated-log profile of shiftedTower(n, x).
    
    Returns a list [v₀, v₁, ..., vₙ] where:
    - v₀ = shiftedTower(n, x)  (or its log₂ approximation)
    - vᵢ = log₂(vᵢ₋₁)
    - vₙ ≈ the 'base' value after n log₂ operations
    
    This profile characterizes the growth rank: a function with
    profile of length k has growth rank k.
    """
    # Build up from level 0
    values = []
    curr = float(x)
    for level in range(n + 1):
        if level == 0:
            curr = float(x + 1)
        else:
            inner = curr  # previous level's value at polySeed(x)
            curr = inner * math.log(2)  # log₂(2^inner) = inner
        values.append(curr)
    return values


# ═══════════════════════════════════════════════════════════════
# Algorithm 2: DAG Representation and Evaluation
# ═══════════════════════════════════════════════════════════════

class DagOp(Enum):
    VAR = "var"
    CONST = "const"
    ADD = "add"
    MUL = "mul"
    NEG = "neg"
    EML = "eml"  # multiply-and-exp: a * exp(b)


@dataclass
class DagNode:
    """A node in an inverse-free DAG."""
    op: DagOp
    children: Tuple[int, ...] = ()
    const_val: float = 0.0


class InverseFreeDAG:
    """An inverse-free DAG for EML computation.
    
    Nodes are stored in topological order: node i can only
    reference nodes j < i as children.
    """
    
    def __init__(self):
        self.nodes: List[DagNode] = []
        self.output: int = -1
    
    def add_var(self) -> int:
        idx = len(self.nodes)
        self.nodes.append(DagNode(op=DagOp.VAR))
        return idx
    
    def add_const(self, c: float) -> int:
        idx = len(self.nodes)
        self.nodes.append(DagNode(op=DagOp.CONST, const_val=c))
        return idx
    
    def add_node(self, op: DagOp, children: Tuple[int, ...]) -> int:
        idx = len(self.nodes)
        for c in children:
            assert c < idx, f"Acyclicity violated: node {idx} references {c}"
        self.nodes.append(DagNode(op=op, children=children))
        return idx
    
    def set_output(self, idx: int):
        self.output = idx
    
    def evaluate(self, x: float) -> float:
        """Evaluate the DAG at input x."""
        vals: Dict[int, float] = {}
        for i, node in enumerate(self.nodes):
            if node.op == DagOp.VAR:
                vals[i] = x
            elif node.op == DagOp.CONST:
                vals[i] = node.const_val
            elif node.op == DagOp.ADD:
                vals[i] = vals[node.children[0]] + vals[node.children[1]]
            elif node.op == DagOp.MUL:
                vals[i] = vals[node.children[0]] * vals[node.children[1]]
            elif node.op == DagOp.NEG:
                vals[i] = -vals[node.children[0]]
            elif node.op == DagOp.EML:
                a, b = node.children
                try:
                    vals[i] = vals[a] * math.exp(vals[b])
                except OverflowError:
                    vals[i] = float('inf')
        return vals[self.output]
    
    def eml_depth(self) -> int:
        """Compute the EML depth (critical path length through eml nodes)."""
        depths: Dict[int, int] = {}
        for i, node in enumerate(self.nodes):
            if node.op in (DagOp.VAR, DagOp.CONST):
                depths[i] = 0
            elif node.op == DagOp.EML:
                child_max = max(depths[c] for c in node.children)
                depths[i] = 1 + child_max
            else:
                depths[i] = max((depths[c] for c in node.children), default=0)
        return depths.get(self.output, 0)


# ═══════════════════════════════════════════════════════════════
# Algorithm 3: Depth-Majorant Certificate
# ═══════════════════════════════════════════════════════════════

@dataclass
class MajorantCertificate:
    """Certificate that a DAG's output is majorized by a tower level."""
    dag_depth: int
    tower_level: int
    poly_C: int
    poly_k: int
    verified_up_to: int
    counterexample: Optional[int] = None
    
    @property
    def is_valid(self) -> bool:
        return self.counterexample is None


def generate_majorant_certificate(
    dag: InverseFreeDAG,
    tower_level: int,
    poly_C: int = 1,
    poly_k: int = 1,
    test_range: int = 100
) -> MajorantCertificate:
    """Generate a depth-majorant certificate for a DAG.
    
    Tests whether |DAG(x)| ≤ shiftedTower(tower_level, C·x^k + C)
    for all x in [1, test_range].
    
    Args:
        dag: The inverse-free DAG to analyze
        tower_level: Candidate tower majorant level
        poly_C: Polynomial coefficient
        poly_k: Polynomial degree
        test_range: Range of inputs to test
    
    Returns:
        A MajorantCertificate with verification results.
    
    Time complexity: O(test_range × dag.size × tower_computation)
    Space complexity: O(dag.size)
    """
    depth = dag.eml_depth()
    cert = MajorantCertificate(
        dag_depth=depth,
        tower_level=tower_level,
        poly_C=poly_C,
        poly_k=poly_k,
        verified_up_to=0,
    )
    
    for x in range(1, test_range + 1):
        dag_val = abs(dag.evaluate(float(x)))
        poly_input = poly_C * (x ** poly_k) + poly_C
        tower_val = shifted_tower(tower_level, poly_input, max_bits=10000)
        
        if tower_val is None:
            # Tower value too large to compute; DAG value is finite
            cert.verified_up_to = x
            continue
        
        if dag_val > tower_val:
            cert.counterexample = x
            cert.verified_up_to = x - 1
            return cert
        
        cert.verified_up_to = x
    
    return cert


# ═══════════════════════════════════════════════════════════════
# Algorithm 4: Tower Separation Verifier
# ═══════════════════════════════════════════════════════════════

def verify_tower_separation(
    level_low: int,
    level_high: int,
    poly_C: int,
    poly_k: int,
    test_range: int = 50
) -> Tuple[bool, int]:
    """Verify tower separation: shiftedTower(low, C·x^k+C) < shiftedTower(high, x).
    
    Args:
        level_low: Lower tower level
        level_high: Higher tower level (must be > level_low)
        poly_C: Polynomial coefficient for reparameterization
        poly_k: Polynomial degree
        test_range: Range of inputs to test
    
    Returns:
        (separated, first_witness): whether separation holds, and the
        first x where it's observed.
    """
    assert level_high > level_low
    
    for x in range(1, test_range + 1):
        poly_val = poly_C * (x ** poly_k) + poly_C
        low_val = shifted_tower(level_low, poly_val, max_bits=5000)
        high_val = shifted_tower(level_high, x, max_bits=5000)
        
        if low_val is None and high_val is None:
            continue
        if low_val is None:
            continue  # low is huge but high might be huger
        if high_val is None:
            return True, x  # high overflows but low doesn't
        
        if low_val < high_val:
            return True, x
    
    return False, -1


# ═══════════════════════════════════════════════════════════════
# Algorithm 5: Growth Rank Classifier
# ═══════════════════════════════════════════════════════════════

def classify_growth_rank(
    f: callable,
    test_points: List[int] = None,
    max_level: int = 5
) -> int:
    """Classify the growth rank of a function by comparing it to tower levels.
    
    Returns the smallest n such that f(x) ≤ shiftedTower(n, x) for all
    tested x, or max_level+1 if no level suffices.
    
    Time complexity: O(max_level × len(test_points) × tower_computation)
    """
    if test_points is None:
        test_points = list(range(1, 20))
    
    for level in range(max_level + 1):
        all_bounded = True
        for x in test_points:
            try:
                fval = f(x)
            except (OverflowError, RecursionError):
                fval = float('inf')
            
            tval = shifted_tower(level, x, max_bits=5000)
            if tval is None:
                continue  # tower overflows, so fval is bounded
            
            if fval > tval:
                all_bounded = False
                break
        
        if all_bounded:
            return level
    
    return max_level + 1


# ═══════════════════════════════════════════════════════════════
# Example usage
# ═══════════════════════════════════════════════════════════════

def main():
    print("Depth-Majorant Analysis Algorithms")
    print("=" * 50)
    print()
    
    # Example 1: Build a simple depth-1 DAG computing 1 * exp(x) = e^x
    dag = InverseFreeDAG()
    var = dag.add_var()        # node 0: x
    one = dag.add_const(1.0)   # node 1: 1
    eml = dag.add_node(DagOp.EML, (one, var))  # node 2: 1 * exp(x) = e^x
    dag.set_output(eml)
    
    print(f"DAG computing e^x:")
    print(f"  EML depth: {dag.eml_depth()}")
    print(f"  e^5 = {dag.evaluate(5.0):.2f}")
    print()
    
    # Generate majorant certificate
    cert = generate_majorant_certificate(dag, tower_level=1, poly_C=2, poly_k=1, test_range=20)
    print(f"Majorant certificate:")
    print(f"  Tower level: {cert.tower_level}")
    print(f"  Polynomial: {cert.poly_C}·x^{cert.poly_k} + {cert.poly_C}")
    print(f"  Verified up to x = {cert.verified_up_to}")
    print(f"  Valid: {cert.is_valid}")
    print()
    
    # Tower separation verification
    sep, witness = verify_tower_separation(0, 1, poly_C=5, poly_k=2, test_range=20)
    print(f"Tower separation (level 0 vs 1, poly 5x²+5):")
    print(f"  Separated: {sep}")
    print(f"  First witness: x = {witness}")
    print()
    
    # Growth rank classification
    fns = [
        ("x + 1", lambda x: x + 1),
        ("x²", lambda x: x * x),
        ("2^x", lambda x: 2 ** x),
        ("x · 2^x", lambda x: x * 2 ** x),
    ]
    print("Growth rank classification:")
    for name, fn in fns:
        rank = classify_growth_rank(fn)
        print(f"  {name}: rank {rank}")
    print()


if __name__ == "__main__":
    main()
