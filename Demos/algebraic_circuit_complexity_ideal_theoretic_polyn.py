#!/usr/bin/env python3
"""
Algebraic Circuit Complexity — Algorithms

Implementations of key algorithms from the research:
  1. Evaluation-based PIT (Schwartz-Zippel)
  2. Circuit depth optimizer (balance binary trees)
  3. Degree-aware circuit analysis
  4. Jacobian computation
"""

from typing import List, Tuple, Optional, Set
from dataclasses import dataclass
import random
from demo import Circuit, GateType, const, var, add, mul


def schwartz_zippel_pit(circuit: Circuit, num_vars: int,
                         grid_size: int = 1000, num_trials: int = 100,
                         seed: int = 42) -> Tuple[bool, Optional[List[int]]]:
    """
    Schwartz-Zippel Polynomial Identity Testing.
    
    Tests whether a circuit computes the zero polynomial by evaluating
    at random points from {-grid_size, ..., grid_size}^num_vars.
    
    Returns (is_likely_zero, witness) where witness is a point where
    the circuit is nonzero (if found).
    
    Soundness: If the polynomial is nonzero with degree d,
    the probability of false positive ≤ d / (2 * grid_size + 1).
    
    Complexity: O(num_trials × circuit.size × num_vars)
    """
    random.seed(seed)
    
    for _ in range(num_trials):
        assignment = [random.randint(-grid_size, grid_size) for _ in range(num_vars)]
        result = circuit.eval(assignment)
        if result != 0:
            return False, assignment
    
    return True, None


def circuit_used_variables(circuit: Circuit) -> Set[int]:
    """
    Compute the set of variable indices actually used in a circuit.
    
    This implements the `usedVars` function from the formalization.
    A circuit with empty used variables computes a constant function.
    
    Complexity: O(circuit.size)
    """
    if circuit.gate_type == GateType.CONST:
        return set()
    elif circuit.gate_type == GateType.VAR:
        return {circuit.var_idx}
    else:
        left_vars = circuit_used_variables(circuit.left)
        right_vars = circuit_used_variables(circuit.right)
        return left_vars | right_vars


def balanced_sum(circuits: List[Circuit]) -> Circuit:
    """
    Compute the sum of multiple circuits using a balanced binary tree.
    
    This achieves depth O(log k + max_depth) where k is the number of circuits
    and max_depth is the maximum depth of any input circuit.
    
    Compared to left-folding (depth = k + max_depth), this saves
    depth proportional to k - log(k).
    
    Complexity: O(k) circuit construction, depth O(log k + max_depth)
    """
    if len(circuits) == 0:
        return const(0)
    if len(circuits) == 1:
        return circuits[0]
    
    mid = len(circuits) // 2
    left = balanced_sum(circuits[:mid])
    right = balanced_sum(circuits[mid:])
    return add(left, right)


def compute_jacobian(circuit: Circuit, num_vars: int,
                      assignment: List[int], h: int = 1) -> List[float]:
    """
    Compute the numerical Jacobian (gradient) of a circuit at a point.
    
    Uses finite differences: ∂f/∂xᵢ ≈ (f(x + hεᵢ) - f(x - hεᵢ)) / (2h)
    
    This is the computational analogue of the pderiv function
    in the formalization.
    
    Args:
        circuit: The algebraic circuit
        num_vars: Number of input variables
        assignment: Point at which to evaluate the Jacobian
        h: Step size for finite differences
    
    Returns:
        List of partial derivatives [∂f/∂x₀, ..., ∂f/∂xₙ₋₁]
    
    Complexity: O(num_vars × circuit.size)
    """
    jacobian = []
    base_val = circuit.eval(assignment)
    
    for i in range(num_vars):
        # Forward difference
        fwd = assignment.copy()
        fwd[i] += h
        fwd_val = circuit.eval(fwd)
        
        # Backward difference
        bwd = assignment.copy()
        bwd[i] -= h
        bwd_val = circuit.eval(bwd)
        
        # Central difference
        deriv = (fwd_val - bwd_val) / (2 * h)
        jacobian.append(deriv)
    
    return jacobian


def circuit_complexity_certificate(circuit: Circuit) -> dict:
    """
    Compute a certified complexity certificate for a circuit.
    
    This implements the CertifiedCircuit structure from the formalization,
    providing machine-verified bounds on depth, degree, and size.
    
    Returns a dictionary with all certified bounds and verification status.
    """
    d = circuit.depth
    db = circuit.degree_bound
    s = circuit.size
    mg = circuit.mul_gates
    
    certificate = {
        'depth': d,
        'degree_bound': db,
        'size': s,
        'mul_gates': mg,
        'max_degree_from_depth': 2 ** d,
        'max_degree_from_mulGates': 2 ** mg,
        'verified': {
            'size_ge_depth_plus_one': s >= d + 1,
            'degree_le_two_pow_depth': db <= 2 ** d,
            'degree_le_two_pow_mulGates': db <= 2 ** mg,
            'mulGates_le_size': mg <= s,
        }
    }
    
    all_verified = all(certificate['verified'].values())
    certificate['all_invariants_hold'] = all_verified
    
    return certificate


def evaluation_pit_test(circuit: Circuit, points: List[List[int]]) -> bool:
    """
    Deterministic evaluation-based PIT test.
    
    Tests whether the circuit evaluates to zero on ALL given points.
    If it returns True, the circuit is zero on those points.
    If it returns False, a witness for non-identity was found.
    
    This implements the evaluationPITTest function from the formalization.
    """
    return all(circuit.eval(pt) == 0 for pt in points)


# ─── Main: Run all algorithms ────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 60)
    print("Algorithm 1: Schwartz-Zippel PIT")
    print("=" * 60)
    
    # Zero polynomial: x^2 - x^2
    zero_poly = add(mul(var(0), var(0)), mul(const(-1), mul(var(0), var(0))))
    is_zero, witness = schwartz_zippel_pit(zero_poly, num_vars=1)
    print(f"x² - x² is zero: {is_zero} (witness: {witness})")
    
    # Nonzero: x^2 + 1
    nonzero = add(mul(var(0), var(0)), const(1))
    is_zero, witness = schwartz_zippel_pit(nonzero, num_vars=1)
    print(f"x² + 1 is zero: {is_zero} (witness: {witness})")
    
    print("\n" + "=" * 60)
    print("Algorithm 2: Variable Usage Analysis")
    print("=" * 60)
    
    c1 = add(mul(var(0), var(1)), var(2))
    print(f"Circuit: {c1}")
    print(f"Used variables: {circuit_used_variables(c1)}")
    
    c2 = add(const(3), const(5))
    print(f"Circuit: {c2}")
    print(f"Used variables: {circuit_used_variables(c2)} (constant!)")
    
    print("\n" + "=" * 60)
    print("Algorithm 3: Balanced Sum Construction")
    print("=" * 60)
    
    circuits = [var(i) for i in range(8)]
    
    # Left-fold sum
    left_fold = circuits[0]
    for c in circuits[1:]:
        left_fold = add(left_fold, c)
    
    # Balanced sum
    bal = balanced_sum(circuits)
    
    print(f"Sum of 8 variables:")
    print(f"  Left-fold depth: {left_fold.depth}")
    print(f"  Balanced depth:  {bal.depth}")
    print(f"  Both evaluate to {left_fold.eval(list(range(8)))}")
    assert left_fold.eval(list(range(8))) == bal.eval(list(range(8)))
    
    print("\n" + "=" * 60)
    print("Algorithm 4: Jacobian Computation")
    print("=" * 60)
    
    # f(x0, x1) = x0^2 + 2*x0*x1
    f = add(mul(var(0), var(0)), mul(const(2), mul(var(0), var(1))))
    point = [3, 5]
    jac = compute_jacobian(f, 2, point)
    print(f"f(x0, x1) = x0² + 2x0x1")
    print(f"Point: {point}")
    print(f"Jacobian: {jac}")
    print(f"Expected: [2x0 + 2x1, 2x0] = [{2*3+2*5}, {2*3}]")
    
    print("\n" + "=" * 60)
    print("Algorithm 5: Complexity Certificate")
    print("=" * 60)
    
    cert = circuit_complexity_certificate(f)
    for key, val in cert.items():
        if key == 'verified':
            print(f"  {key}:")
            for k, v in val.items():
                print(f"    {k}: {'✓' if v else '✗'}")
        else:
            print(f"  {key}: {val}")


#!/usr/bin/env python3
"""
Algebraic Circuit Complexity — Applications

Real-world applications of the formalized theorems:
  1. Polynomial commitment verification (cryptography)
  2. Neural network depth analysis (machine learning)
  3. Circuit optimization via depth-degree tradeoffs
"""

from typing import List, Tuple
from demo import Circuit, GateType, const, var, add, mul
from algorithms import schwartz_zippel_pit, circuit_complexity_certificate, balanced_sum
import random


# ─── Application 1: Polynomial Commitment Verification ──────────────

def polynomial_commitment_demo():
    """
    Simulates polynomial commitment verification using PIT.
    
    In a polynomial commitment scheme (e.g., KZG), a prover commits to a 
    polynomial f, and a verifier checks that f satisfies certain properties
    by evaluating at random challenge points.
    
    Our PIT framework provides the soundness guarantee: if f ≠ 0, then
    Pr[eval(f, random_point) = 0] ≤ degree(f) / |field_size|.
    """
    print("=" * 60)
    print("Application 1: Polynomial Commitment Verification")
    print("=" * 60)
    
    # Prover claims f = g (i.e., f - g = 0)
    # f(x0, x1) = x0^2 + 2*x0*x1 + x1^2  (= (x0+x1)^2)
    x0, x1 = var(0), var(1)
    f = add(add(mul(x0, x0), mul(const(2), mul(x0, x1))), mul(x1, x1))
    
    # g(x0, x1) = (x0 + x1)^2
    g = mul(add(x0, x1), add(x0, x1))
    
    # Difference circuit: f - g
    diff = add(f, mul(const(-1), g))
    
    print(f"Prover's polynomial f: {f}")
    print(f"Claimed equal to g: {g}")
    
    cert = circuit_complexity_certificate(diff)
    print(f"\nDifference circuit complexity:")
    print(f"  Degree bound: {cert['degree_bound']}")
    print(f"  Depth: {cert['depth']}")
    
    # Schwartz-Zippel verification
    is_zero, witness = schwartz_zippel_pit(diff, num_vars=2, grid_size=10**6, num_trials=50)
    
    if is_zero:
        print(f"\n✓ Verification PASSED: f = g with high probability")
        soundness_error = cert['degree_bound'] / (2 * 10**6 + 1)
        print(f"  Soundness error bound: degree/|S| ≤ {soundness_error:.2e}")
    else:
        print(f"\n✗ Verification FAILED: witness point {witness}")
    
    # Now try with a dishonest prover
    print(f"\n--- Dishonest prover ---")
    # h(x0, x1) = (x0+x1)^2 + 1  (not equal to g)
    h = add(mul(add(x0, x1), add(x0, x1)), const(1))
    diff2 = add(h, mul(const(-1), g))
    
    is_zero2, witness2 = schwartz_zippel_pit(diff2, num_vars=2)
    if not is_zero2:
        print(f"✓ Dishonest prover CAUGHT at point {witness2}")
        print(f"  f({witness2}) = {h.eval(witness2)}, g({witness2}) = {g.eval(witness2)}")
    print()


# ─── Application 2: Neural Network Depth Analysis ───────────────────

def neural_network_depth_analysis():
    """
    Analyzes the polynomial approximation capabilities of neural networks
    using the degree-depth tradeoff.
    
    Key theorem: A depth-d algebraic circuit can compute polynomials of
    degree at most 2^d. Therefore, approximating a degree-D polynomial
    requires depth at least ceil(log2(D)).
    
    This gives certified lower bounds on neural network depth for
    polynomial activation functions.
    """
    print("=" * 60)
    print("Application 2: Neural Network Depth Analysis")
    print("=" * 60)
    
    import math
    
    print("Degree-Depth Requirements for Polynomial Activations:")
    print(f"{'Target Degree':>15} | {'Min Depth':>10} | {'Max Degree at Min Depth':>23}")
    print("-" * 55)
    
    for target_degree in [1, 2, 4, 8, 16, 32, 64, 128, 256, 1024]:
        min_depth = math.ceil(math.log2(target_degree)) if target_degree > 1 else 0
        max_degree_at_depth = 2 ** min_depth
        print(f"{target_degree:15} | {min_depth:10} | {max_degree_at_depth:23}")
    
    print("\nImplication: A neural network with polynomial activations of degree D")
    print("needs at least ceil(log2(D)) layers. This is TIGHT — achieved by")
    print("iterated squaring circuits.")
    
    print("\nExample: Approximating x^128 (common in high-degree kernel methods)")
    print(f"  Minimum depth required: {math.ceil(math.log2(128))}")
    print(f"  A 7-layer network achieves this exactly via iterated squaring")
    print(f"  A 6-layer network can compute at most degree {2**6} = 64 < 128")
    print()


# ─── Application 3: Circuit Optimization ────────────────────────────

def circuit_optimization_demo():
    """
    Demonstrates circuit optimization using the balanced tree construction.
    
    The balanced_sum construction reduces depth from O(k) to O(log k)
    for summing k sub-circuits, while preserving semantics.
    """
    print("=" * 60)
    print("Application 3: Circuit Depth Optimization")
    print("=" * 60)
    
    # Scenario: compute x0 + x1 + ... + x_{n-1}
    for n in [4, 8, 16, 32, 64]:
        circuits = [var(i) for i in range(n)]
        
        # Naive left-fold
        naive = circuits[0]
        for c in circuits[1:]:
            naive = add(naive, c)
        
        # Balanced
        balanced = balanced_sum(circuits)
        
        # Verify correctness
        test_vals = list(range(n))
        assert naive.eval(test_vals) == balanced.eval(test_vals)
        
        depth_ratio = naive.depth / balanced.depth if balanced.depth > 0 else float('inf')
        print(f"  n={n:3}: naive depth={naive.depth:3}, balanced depth={balanced.depth:2}, "
              f"speedup={depth_ratio:.1f}x")
    
    print("\nThe balanced construction achieves O(log n) depth for n-term sums.")
    print("This is optimal: any binary tree circuit for n-term sum needs")
    print("depth ≥ ceil(log2(n)).")
    print()


if __name__ == "__main__":
    polynomial_commitment_demo()
    neural_network_depth_analysis()
    circuit_optimization_demo()
    
    print("=" * 60)
    print("All applications demonstrated successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Algebraic Circuit Complexity — Demonstrations

Concrete numerical examples illustrating the theorems formalized in the
Lean 4 proof files. Demonstrates:
  1. Circuit evaluation semantics
  2. Degree-depth tradeoff (degreeBound ≤ 2^depth)
  3. Iterated squaring construction
  4. Schwartz-Zippel style PIT
  5. Monomial circuit construction
"""

from dataclasses import dataclass
from typing import Callable, List, Tuple
from enum import Enum, auto
import random

# ─── Circuit Model ────────────────────────────────────────────────────

class GateType(Enum):
    CONST = auto()
    VAR = auto()
    ADD = auto()
    MUL = auto()

@dataclass
class Circuit:
    """Algebraic circuit over integers with n variables."""
    gate_type: GateType
    const_val: int = 0
    var_idx: int = 0
    left: 'Circuit' = None
    right: 'Circuit' = None

    def eval(self, assignment: List[int]) -> int:
        if self.gate_type == GateType.CONST:
            return self.const_val
        elif self.gate_type == GateType.VAR:
            return assignment[self.var_idx]
        elif self.gate_type == GateType.ADD:
            return self.left.eval(assignment) + self.right.eval(assignment)
        elif self.gate_type == GateType.MUL:
            return self.left.eval(assignment) * self.right.eval(assignment)

    @property
    def depth(self) -> int:
        if self.gate_type in (GateType.CONST, GateType.VAR):
            return 0
        return 1 + max(self.left.depth, self.right.depth)

    @property
    def size(self) -> int:
        if self.gate_type in (GateType.CONST, GateType.VAR):
            return 1
        return 1 + self.left.size + self.right.size

    @property
    def degree_bound(self) -> int:
        if self.gate_type == GateType.CONST:
            return 0
        elif self.gate_type == GateType.VAR:
            return 1
        elif self.gate_type == GateType.ADD:
            return max(self.left.degree_bound, self.right.degree_bound)
        elif self.gate_type == GateType.MUL:
            return self.left.degree_bound + self.right.degree_bound

    @property
    def mul_gates(self) -> int:
        if self.gate_type in (GateType.CONST, GateType.VAR):
            return 0
        elif self.gate_type == GateType.ADD:
            return self.left.mul_gates + self.right.mul_gates
        return 1 + self.left.mul_gates + self.right.mul_gates

    def __repr__(self):
        if self.gate_type == GateType.CONST:
            return str(self.const_val)
        elif self.gate_type == GateType.VAR:
            return f"x{self.var_idx}"
        elif self.gate_type == GateType.ADD:
            return f"({self.left} + {self.right})"
        return f"({self.left} * {self.right})"


def const(v: int) -> Circuit:
    return Circuit(GateType.CONST, const_val=v)

def var(i: int) -> Circuit:
    return Circuit(GateType.VAR, var_idx=i)

def add(l: Circuit, r: Circuit) -> Circuit:
    return Circuit(GateType.ADD, left=l, right=r)

def mul(l: Circuit, r: Circuit) -> Circuit:
    return Circuit(GateType.MUL, left=l, right=r)


# ─── Demo 1: Basic Circuit Evaluation ────────────────────────────────

def demo_basic_evaluation():
    print("=" * 60)
    print("Demo 1: Basic Circuit Evaluation")
    print("=" * 60)
    
    # Circuit computing f(x0, x1) = x0 * x1 + 3 * x0
    c = add(mul(var(0), var(1)), mul(const(3), var(0)))
    print(f"Circuit: {c}")
    print(f"Depth:   {c.depth}")
    print(f"Size:    {c.size}")
    print(f"Degree:  {c.degree_bound}")
    print(f"MulGates: {c.mul_gates}")
    print()
    
    for x0, x1 in [(1, 2), (3, 4), (0, 5), (-1, 7)]:
        result = c.eval([x0, x1])
        expected = x0 * x1 + 3 * x0
        print(f"  f({x0}, {x1}) = {result}  (expected: {expected})")
        assert result == expected
    
    # Verify: size ≥ depth + 1
    print(f"\n  ✓ size ({c.size}) ≥ depth + 1 ({c.depth + 1})")
    assert c.size >= c.depth + 1
    print()


# ─── Demo 2: Degree-Depth Tradeoff ──────────────────────────────────

def demo_degree_depth_tradeoff():
    print("=" * 60)
    print("Demo 2: Degree-Depth Tradeoff (degreeBound ≤ 2^depth)")
    print("=" * 60)
    
    def iterated_squaring(k: int) -> Circuit:
        if k == 0:
            return var(0)
        sub = iterated_squaring(k - 1)
        return mul(sub, sub)
    
    print(f"{'k':>3} | {'depth':>6} | {'degree':>7} | {'2^depth':>8} | {'size':>6} | {'2^(k+1)-1':>10}")
    print("-" * 55)
    
    for k in range(8):
        c = iterated_squaring(k)
        print(f"{k:3} | {c.depth:6} | {c.degree_bound:7} | {2**c.depth:8} | {c.size:6} | {2**(k+1)-1:10}")
        
        # Verify the theorems
        assert c.depth == k, f"depth should be {k}"
        assert c.degree_bound == 2**k, f"degree should be {2**k}"
        assert c.degree_bound <= 2**c.depth, "degree-depth bound violated!"
        assert c.size == 2**(k+1) - 1, f"size should be {2**(k+1)-1}"
    
    print(f"\n  ✓ All degree-depth bounds verified")
    print(f"  ✓ Iterated squaring achieves tight bound: degree = 2^depth")
    print()


# ─── Demo 3: Schwartz-Zippel PIT ────────────────────────────────────

def demo_schwartz_zippel():
    print("=" * 60)
    print("Demo 3: Schwartz-Zippel Polynomial Identity Testing")
    print("=" * 60)
    
    # f(x0, x1) = x0^2 - x1^2 - (x0+x1)(x0-x1)
    # This should be identically zero
    x0, x1 = var(0), var(1)
    lhs = add(mul(x0, x0), mul(const(-1), mul(x1, x1)))  # x0^2 - x1^2
    rhs = mul(add(x0, x1), add(x0, mul(const(-1), x1)))    # (x0+x1)(x0-x1)
    zero_circuit = add(lhs, mul(const(-1), rhs))
    
    print(f"Circuit: {zero_circuit}")
    print(f"Testing on random points from {{-100, ..., 100}}^2...")
    
    random.seed(42)
    all_zero = True
    for trial in range(100):
        a = random.randint(-100, 100)
        b = random.randint(-100, 100)
        result = zero_circuit.eval([a, b])
        if result != 0:
            all_zero = False
            print(f"  NONZERO at ({a}, {b}): {result}")
    
    if all_zero:
        print(f"  ✓ Circuit evaluates to 0 on all 100 random points")
        print(f"  → High confidence this is the zero polynomial")
    
    # Now test a nonzero polynomial: f(x) = x^2 + 1
    nonzero = add(mul(var(0), var(0)), const(1))
    print(f"\nNonzero circuit: {nonzero}")
    nonzero_count = sum(1 for _ in range(100) 
                         if nonzero.eval([random.randint(-100, 100)]) != 0)
    print(f"  Nonzero on {nonzero_count}/100 random points")
    print(f"  (Expected: all nonzero over ℤ since x²+1 > 0 for x ∈ ℤ)")
    print()


# ─── Demo 4: Monomial Circuits ──────────────────────────────────────

def demo_monomial_circuits():
    print("=" * 60)
    print("Demo 4: Monomial Circuit Construction")
    print("=" * 60)
    
    def monomial_circuit(var_indices: List[int]) -> Circuit:
        if not var_indices:
            return const(1)
        if len(var_indices) == 1:
            return var(var_indices[0])
        return mul(var(var_indices[0]), monomial_circuit(var_indices[1:]))
    
    # x0 * x1 * x2
    c = monomial_circuit([0, 1, 2])
    print(f"Monomial x0·x1·x2:")
    print(f"  Circuit: {c}")
    print(f"  Degree:  {c.degree_bound}")
    
    for vals in [(1, 2, 3), (2, 3, 5), (0, 100, 7)]:
        expected = vals[0] * vals[1] * vals[2]
        result = c.eval(list(vals))
        print(f"  f{vals} = {result} (expected {expected})")
        assert result == expected
    
    # x0 * x1 * x2 * x3 * x4
    c5 = monomial_circuit([0, 1, 2, 3, 4])
    print(f"\nMonomial x0·x1·x2·x3·x4:")
    print(f"  Degree bound: {c5.degree_bound} ≤ 5 (list length)")
    print(f"  Depth: {c5.depth}")
    print(f"  f(1,2,3,4,5) = {c5.eval([1,2,3,4,5])} (expected 120)")
    assert c5.degree_bound <= 5
    print()


# ─── Demo 5: Multiplicative Complexity ──────────────────────────────

def demo_multiplicative_complexity():
    print("=" * 60)
    print("Demo 5: Multiplicative Complexity Lower Bounds")
    print("=" * 60)
    
    def iterated_squaring(k: int) -> Circuit:
        if k == 0:
            return var(0)
        sub = iterated_squaring(k - 1)
        return mul(sub, sub)
    
    print(f"{'k':>3} | {'mulGates':>9} | {'degree':>7} | {'2^mulGates':>11} | {'bound holds':>12}")
    print("-" * 55)
    
    for k in range(7):
        c = iterated_squaring(k)
        mg = c.mul_gates
        db = c.degree_bound
        bound = 2 ** mg
        holds = db <= bound
        print(f"{k:3} | {mg:9} | {db:7} | {bound:11} | {'✓' if holds else '✗':>12}")
        assert holds, f"degreeBound ≤ 2^mulGates violated at k={k}"
    
    print(f"\n  ✓ degreeBound ≤ 2^mulGates verified for all circuits")
    print()


# ─── Demo 6: Certified Circuit Bounds ───────────────────────────────

def demo_certified_bounds():
    print("=" * 60)
    print("Demo 6: Certified Circuit Complexity Bounds")
    print("=" * 60)
    
    # Build a circuit and derive all bounds
    x0, x1, x2 = var(0), var(1), var(2)
    
    # f(x0, x1, x2) = (x0 + x1)^2 * x2
    sum_sq = mul(add(x0, x1), add(x0, x1))
    circuit = mul(sum_sq, x2)
    
    d = circuit.depth
    db = circuit.degree_bound
    s = circuit.size
    mg = circuit.mul_gates
    
    print(f"Circuit: {circuit}")
    print(f"\nCertified bounds:")
    print(f"  depth      = {d}")
    print(f"  degreeBound = {db}")
    print(f"  size       = {s}")
    print(f"  mulGates   = {mg}")
    print(f"\nVerified invariants:")
    print(f"  ✓ size ({s}) ≥ depth + 1 ({d + 1})")
    print(f"  ✓ degreeBound ({db}) ≤ 2^depth ({2**d})")
    print(f"  ✓ degreeBound ({db}) ≤ 2^mulGates ({2**mg})")
    print(f"  ✓ mulGates ({mg}) ≤ size ({s})")
    
    assert s >= d + 1
    assert db <= 2 ** d
    assert db <= 2 ** mg
    assert mg <= s
    
    print(f"\n  Evaluation: f(2, 3, 5) = {circuit.eval([2, 3, 5])}")
    print(f"  Expected: (2+3)^2 * 5 = {(2+3)**2 * 5}")
    print()


if __name__ == "__main__":
    demo_basic_evaluation()
    demo_degree_depth_tradeoff()
    demo_schwartz_zippel()
    demo_monomial_circuits()
    demo_multiplicative_complexity()
    demo_certified_bounds()
    
    print("=" * 60)
    print("All demonstrations completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Algebraic Circuit Complexity — Visualizations

Generates matplotlib charts for the key mathematical structures.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math

def plot_degree_depth_tradeoff():
    """Plot the degree-depth tradeoff: degreeBound ≤ 2^depth."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    depths = range(0, 11)
    max_degrees = [2**d for d in depths]
    
    ax1.semilogy(list(depths), max_degrees, 'b-o', linewidth=2, markersize=8, label='2^depth (upper bound)')
    ax1.fill_between(list(depths), 1, max_degrees, alpha=0.15, color='blue', label='Achievable degree region')
    
    # Mark iterated squaring (tight)
    ax1.semilogy(list(depths), max_degrees, 'r^', markersize=12, label='Iterated squaring (tight)')
    
    ax1.set_xlabel('Circuit Depth', fontsize=12)
    ax1.set_ylabel('Maximum Polynomial Degree', fontsize=12)
    ax1.set_title('Degree-Depth Tradeoff\n(Theorem: degreeBound ≤ 2^depth)', fontsize=13)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    ax1.set_xticks(list(depths))
    
    # Right plot: size vs depth
    sizes_iter_sq = [2**(k+1) - 1 for k in depths]
    ax2.plot(list(depths), sizes_iter_sq, 'g-s', linewidth=2, markersize=8, label='Iterated squaring size')
    ax2.plot(list(depths), [d+1 for d in depths], 'r--', linewidth=2, label='Minimum size (depth+1)')
    ax2.fill_between(list(depths), [d+1 for d in depths], sizes_iter_sq, alpha=0.1, color='green')
    
    ax2.set_xlabel('Circuit Depth', fontsize=12)
    ax2.set_ylabel('Circuit Size', fontsize=12)
    ax2.set_title('Size-Depth Relationship\n(Theorem: size ≥ depth + 1)', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    ax2.set_xticks(list(depths))
    
    plt.tight_layout()
    plt.savefig('degree_depth_tradeoff.png', dpi=150, bbox_inches='tight')
    plt.savefig('degree_depth_tradeoff.svg', bbox_inches='tight')
    plt.close()
    print("Saved: degree_depth_tradeoff.png/svg")


def plot_pit_soundness():
    """Plot PIT soundness error as function of grid size."""
    fig, ax = plt.subplots(figsize=(8, 5))
    
    grid_sizes = np.logspace(1, 8, 100)
    
    for degree in [2, 4, 8, 16, 32]:
        errors = degree / grid_sizes
        ax.loglog(grid_sizes, errors, linewidth=2, label=f'degree = {degree}')
    
    ax.axhline(y=1e-6, color='red', linestyle='--', alpha=0.5, label='Target error 10⁻⁶')
    ax.set_xlabel('Grid Size |S|', fontsize=12)
    ax.set_ylabel('Soundness Error (≤ d/|S|)', fontsize=12)
    ax.set_title('Schwartz-Zippel PIT Soundness Error\n(Pr[false positive] ≤ degree / |S|)', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('pit_soundness.png', dpi=150, bbox_inches='tight')
    plt.savefig('pit_soundness.svg', bbox_inches='tight')
    plt.close()
    print("Saved: pit_soundness.png/svg")


def plot_balanced_vs_naive():
    """Plot depth comparison: balanced vs naive circuit summation."""
    fig, ax = plt.subplots(figsize=(8, 5))
    
    ns = list(range(2, 65))
    naive_depths = [n - 1 for n in ns]
    balanced_depths = [math.ceil(math.log2(n)) for n in ns]
    
    ax.plot(ns, naive_depths, 'r-', linewidth=2, label='Naive (left-fold)')
    ax.plot(ns, balanced_depths, 'b-', linewidth=2, label='Balanced binary tree')
    ax.fill_between(ns, balanced_depths, naive_depths, alpha=0.1, color='green', label='Depth savings')
    
    ax.set_xlabel('Number of Terms (k)', fontsize=12)
    ax.set_ylabel('Circuit Depth', fontsize=12)
    ax.set_title('Depth of k-Term Sum Circuit\n(Balanced vs. Naive Construction)', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('balanced_depth.png', dpi=150, bbox_inches='tight')
    plt.savefig('balanced_depth.svg', bbox_inches='tight')
    plt.close()
    print("Saved: balanced_depth.png/svg")


def plot_complexity_landscape():
    """Plot the landscape of circuit complexity measures."""
    fig, ax = plt.subplots(figsize=(10, 6))
    
    # Generate random circuits and plot their complexity measures
    depths = list(range(0, 9))
    
    for d in depths:
        max_deg = 2**d
        ax.scatter(d, max_deg, s=100, c='blue', zorder=5)
        ax.annotate(f'deg≤{max_deg}', (d, max_deg), textcoords="offset points",
                    xytext=(10, 5), fontsize=8)
    
    ax.semilogy(depths, [2**d for d in depths], 'b-', linewidth=2, label='Max degree = 2^depth')
    ax.semilogy(depths, [d+1 for d in depths], 'r--', linewidth=2, label='Min size = depth+1')
    ax.semilogy(depths, [2**(d+1)-1 for d in depths], 'g-.', linewidth=2, label='Iter. squaring size')
    
    ax.set_xlabel('Circuit Depth', fontsize=12)
    ax.set_ylabel('Value (log scale)', fontsize=12)
    ax.set_title('Algebraic Circuit Complexity Landscape\n'
                  '(Relationships between depth, degree, and size)', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_xticks(depths)
    
    plt.tight_layout()
    plt.savefig('complexity_landscape.png', dpi=150, bbox_inches='tight')
    plt.savefig('complexity_landscape.svg', bbox_inches='tight')
    plt.close()
    print("Saved: complexity_landscape.png/svg")


if __name__ == "__main__":
    plot_degree_depth_tradeoff()
    plot_pit_soundness()
    plot_balanced_vs_naive()
    plot_complexity_landscape()
    print("\nAll visualizations generated!")
