#!/usr/bin/env python3
"""
Tropical Monotone Circuits — Algorithms
=========================================

Complete implementations of the algorithms from the research paper,
with docstrings, type hints, and example usage.
"""

from dataclasses import dataclass, field
from typing import List, Optional, Tuple, Set, Dict
import numpy as np
from itertools import product as iterproduct


# ─────────────────────────────────────────────────
# Core Types
# ─────────────────────────────────────────────────

class TropCircuit:
    """Abstract base for tropical monotone circuit nodes."""
    pass

@dataclass
class Var(TropCircuit):
    """Input variable x_i."""
    index: int

@dataclass
class Const(TropCircuit):
    """Real constant c."""
    value: float

@dataclass
class Add(TropCircuit):
    """Addition gate: left + right."""
    left: TropCircuit
    right: TropCircuit

@dataclass
class Min(TropCircuit):
    """Minimum gate: min(left, right)."""
    left: TropCircuit
    right: TropCircuit


@dataclass
class AffineForm:
    """
    Tropical affine form: const + Σᵢ coeff[i] * xᵢ

    Represents one "linear piece" of a piecewise-linear function.

    Attributes:
        coeff: Natural number coefficients (one per variable).
        const: Real constant term.
    """
    coeff: List[int]
    const: float

    def eval(self, x: List[float]) -> float:
        """Evaluate the affine form at input x."""
        return self.const + sum(c * xi for c, xi in zip(self.coeff, x))

    def __repr__(self) -> str:
        terms = []
        if self.const != 0:
            terms.append(f"{self.const:.2f}")
        for i, c in enumerate(self.coeff):
            if c == 1:
                terms.append(f"x{i}")
            elif c > 1:
                terms.append(f"{c}·x{i}")
        return " + ".join(terms) if terms else "0.00"


# ─────────────────────────────────────────────────
# Algorithm 1: Circuit Evaluation
# ─────────────────────────────────────────────────

def evaluate(circuit: TropCircuit, x: List[float]) -> float:
    """
    Evaluate a tropical monotone circuit at input x.

    Time complexity: O(size(circuit))
    Space complexity: O(depth(circuit)) stack space

    Args:
        circuit: A tropical monotone circuit.
        x: Input values, one per variable.

    Returns:
        The real-valued output of the circuit.

    Example:
        >>> c = Min(Add(Var(0), Var(1)), Const(5.0))
        >>> evaluate(c, [2.0, 3.0])
        5.0
    """
    if isinstance(circuit, Var):
        return x[circuit.index]
    elif isinstance(circuit, Const):
        return circuit.value
    elif isinstance(circuit, Add):
        return evaluate(circuit.left, x) + evaluate(circuit.right, x)
    elif isinstance(circuit, Min):
        return min(evaluate(circuit.left, x), evaluate(circuit.right, x))
    raise TypeError(f"Unknown circuit node: {type(circuit)}")


# ─────────────────────────────────────────────────
# Algorithm 2: Circuit Metrics
# ─────────────────────────────────────────────────

def circuit_size(circuit: TropCircuit) -> int:
    """
    Count the number of nodes in the circuit.

    Time complexity: O(size)

    Example:
        >>> circuit_size(Add(Var(0), Const(1.0)))
        3
    """
    if isinstance(circuit, (Var, Const)):
        return 1
    elif isinstance(circuit, (Add, Min)):
        return 1 + circuit_size(circuit.left) + circuit_size(circuit.right)
    raise TypeError


def circuit_depth(circuit: TropCircuit) -> int:
    """
    Compute the depth (longest root-to-leaf path) of the circuit.

    Time complexity: O(size)

    Example:
        >>> circuit_depth(Add(Var(0), Const(1.0)))
        1
    """
    if isinstance(circuit, (Var, Const)):
        return 0
    elif isinstance(circuit, (Add, Min)):
        return 1 + max(circuit_depth(circuit.left), circuit_depth(circuit.right))
    raise TypeError


# ─────────────────────────────────────────────────
# Algorithm 3: Normal Form Extraction
# ─────────────────────────────────────────────────

def extract_normal_forms(circuit: TropCircuit, n_vars: int) -> List[AffineForm]:
    """
    Extract the normal-form affine family from a tropical circuit.

    The circuit evaluates to the minimum of these affine forms:
        eval(C, x) = min{a.eval(x) | a ∈ extract_normal_forms(C)}

    Time complexity: O(|NF|) where |NF| can be up to 2^size(C)
    Space complexity: O(|NF| · n_vars)

    Args:
        circuit: A tropical monotone circuit.
        n_vars: Number of input variables.

    Returns:
        List of AffineForm objects.

    Example:
        >>> nf = extract_normal_forms(Min(Var(0), Var(1)), 2)
        >>> len(nf)
        2
    """
    if isinstance(circuit, Var):
        coeff = [0] * n_vars
        coeff[circuit.index] = 1
        return [AffineForm(coeff, 0.0)]

    elif isinstance(circuit, Const):
        return [AffineForm([0] * n_vars, circuit.value)]

    elif isinstance(circuit, Min):
        # Union of normal forms
        return (extract_normal_forms(circuit.left, n_vars) +
                extract_normal_forms(circuit.right, n_vars))

    elif isinstance(circuit, Add):
        # Pairwise sum (tropical convolution)
        nf_left = extract_normal_forms(circuit.left, n_vars)
        nf_right = extract_normal_forms(circuit.right, n_vars)
        result = []
        for a in nf_left:
            for b in nf_right:
                new_coeff = [ac + bc for ac, bc in zip(a.coeff, b.coeff)]
                result.append(AffineForm(new_coeff, a.const + b.const))
        return result

    raise TypeError


def verify_normal_form(circuit: TropCircuit, n_vars: int,
                        x: List[float]) -> Tuple[float, float, bool]:
    """
    Verify the normal form theorem for a specific input.

    Returns:
        Tuple of (circuit_eval, nf_min, match_bool)

    Example:
        >>> c = Min(Add(Var(0), Var(1)), Const(5.0))
        >>> verify_normal_form(c, 2, [2.0, 3.0])
        (5.0, 5.0, True)
    """
    nf = extract_normal_forms(circuit, n_vars)
    circuit_val = evaluate(circuit, x)
    nf_min = min(af.eval(x) for af in nf)
    return circuit_val, nf_min, abs(circuit_val - nf_min) < 1e-10


# ─────────────────────────────────────────────────
# Algorithm 4: Boolean Formula Translation
# ─────────────────────────────────────────────────

class BoolFormula:
    """Boolean monotone formula."""
    pass

@dataclass
class BVar(BoolFormula):
    index: int

@dataclass
class BTop(BoolFormula):
    pass

@dataclass
class BBot(BoolFormula):
    pass

@dataclass
class BAnd(BoolFormula):
    left: BoolFormula
    right: BoolFormula

@dataclass
class BOr(BoolFormula):
    left: BoolFormula
    right: BoolFormula


def bool_eval(formula: BoolFormula, sigma: List[bool]) -> bool:
    """Evaluate a Boolean monotone formula."""
    if isinstance(formula, BVar):
        return sigma[formula.index]
    elif isinstance(formula, BTop):
        return True
    elif isinstance(formula, BBot):
        return False
    elif isinstance(formula, BAnd):
        return bool_eval(formula.left, sigma) and bool_eval(formula.right, sigma)
    elif isinstance(formula, BOr):
        return bool_eval(formula.left, sigma) or bool_eval(formula.right, sigma)
    raise TypeError


def translate_to_tropical(formula: BoolFormula) -> TropCircuit:
    """
    Translate a Boolean monotone formula into a tropical circuit.

    Translation rules:
        var(i)       → var(i)
        top          → const(0)
        bot          → const(1)
        and(φ₁, φ₂)  → add(translate(φ₁), translate(φ₂))
        or(φ₁, φ₂)   → min(translate(φ₁), translate(φ₂))

    The translation preserves formula size exactly.

    Time complexity: O(size(formula))

    Example:
        >>> c = translate_to_tropical(BOr(BVar(0), BVar(1)))
        >>> isinstance(c, Min)
        True
    """
    if isinstance(formula, BVar):
        return Var(formula.index)
    elif isinstance(formula, BTop):
        return Const(0.0)
    elif isinstance(formula, BBot):
        return Const(1.0)
    elif isinstance(formula, BAnd):
        return Add(translate_to_tropical(formula.left),
                   translate_to_tropical(formula.right))
    elif isinstance(formula, BOr):
        return Min(translate_to_tropical(formula.left),
                   translate_to_tropical(formula.right))
    raise TypeError


def encode_bool(b: bool) -> float:
    """Encode a Boolean value for tropical computation: true→0, false→1."""
    return 0.0 if b else 1.0


def decode_bool(r: float) -> bool:
    """Decode a tropical value to Boolean: r ≤ 0 → true."""
    return r <= 0.0


def verify_boolean_embedding(formula: BoolFormula, n_vars: int) -> bool:
    """
    Exhaustively verify the Boolean embedding theorem for a formula.

    Tests all 2^n_vars input assignments.

    Returns:
        True if all assignments match.
    """
    circuit = translate_to_tropical(formula)
    for bits in iterproduct([False, True], repeat=n_vars):
        sigma = list(bits)
        bool_result = bool_eval(formula, sigma)
        encoded = [encode_bool(b) for b in sigma]
        trop_result = evaluate(circuit, encoded)
        decoded = decode_bool(trop_result)
        if decoded != bool_result:
            return False
    return True


# ─────────────────────────────────────────────────
# Algorithm 5: Min-Max Duality
# ─────────────────────────────────────────────────

class MaxTropCircuit:
    """Max-plus tropical circuit."""
    pass

@dataclass
class MaxVar(MaxTropCircuit):
    index: int

@dataclass
class MaxConst(MaxTropCircuit):
    value: float

@dataclass
class MaxAdd(MaxTropCircuit):
    left: MaxTropCircuit
    right: MaxTropCircuit

@dataclass
class MaxMax(MaxTropCircuit):
    left: MaxTropCircuit
    right: MaxTropCircuit


def max_evaluate(circuit: MaxTropCircuit, x: List[float]) -> float:
    """Evaluate a max-plus tropical circuit."""
    if isinstance(circuit, MaxVar):
        return x[circuit.index]
    elif isinstance(circuit, MaxConst):
        return circuit.value
    elif isinstance(circuit, MaxAdd):
        return max_evaluate(circuit.left, x) + max_evaluate(circuit.right, x)
    elif isinstance(circuit, MaxMax):
        return max(max_evaluate(circuit.left, x), max_evaluate(circuit.right, x))
    raise TypeError


def compute_dual(circuit: TropCircuit) -> MaxTropCircuit:
    """
    Compute the syntactic dual of a min-plus circuit.

    Transform rules:
        var(i)       → var(i)
        const(c)     → const(-c)
        add(C₁, C₂)  → add(dual(C₁), dual(C₂))
        min(C₁, C₂)  → max(dual(C₁), dual(C₂))

    Time complexity: O(size(circuit))

    Example:
        >>> d = compute_dual(Min(Var(0), Const(3.0)))
        >>> isinstance(d, MaxMax)
        True
    """
    if isinstance(circuit, Var):
        return MaxVar(circuit.index)
    elif isinstance(circuit, Const):
        return MaxConst(-circuit.value)
    elif isinstance(circuit, Add):
        return MaxAdd(compute_dual(circuit.left), compute_dual(circuit.right))
    elif isinstance(circuit, Min):
        return MaxMax(compute_dual(circuit.left), compute_dual(circuit.right))
    raise TypeError


def verify_duality(circuit: TropCircuit, x: List[float]) -> Tuple[float, float, bool]:
    """
    Verify the duality theorem for a specific input.

    Checks: eval(C, x) = -eval_max(dual(C), -x)

    Returns:
        Tuple of (eval_minplus, neg_eval_maxplus, match_bool)
    """
    dual_circuit = compute_dual(circuit)
    neg_x = [-xi for xi in x]
    lhs = evaluate(circuit, x)
    rhs = -max_evaluate(dual_circuit, neg_x)
    return lhs, rhs, abs(lhs - rhs) < 1e-10


# ─────────────────────────────────────────────────
# Algorithm 6: Random Circuit Generation
# ─────────────────────────────────────────────────

def random_circuit(n_vars: int, max_depth: int, rng: np.random.Generator) -> TropCircuit:
    """
    Generate a random tropical monotone circuit.

    Args:
        n_vars: Number of input variables.
        max_depth: Maximum depth of the circuit.
        rng: NumPy random generator.

    Returns:
        A random TropCircuit.
    """
    if max_depth == 0 or rng.random() < 0.3:
        # Leaf node
        if rng.random() < 0.7:
            return Var(int(rng.integers(0, n_vars)))
        else:
            return Const(float(rng.standard_normal()))
    else:
        left = random_circuit(n_vars, max_depth - 1, rng)
        right = random_circuit(n_vars, max_depth - 1, rng)
        if rng.random() < 0.5:
            return Add(left, right)
        else:
            return Min(left, right)


# ─────────────────────────────────────────────────
# Example Usage
# ─────────────────────────────────────────────────

if __name__ == "__main__":
    print("Tropical Monotone Circuits — Algorithm Examples")
    print("=" * 50)

    # Build a circuit: min(x0 + x1, x2 + 3)
    c = Min(Add(Var(0), Var(1)), Add(Var(2), Const(3.0)))
    x = [1.0, 2.0, 0.5]

    print(f"\nCircuit: min(x0 + x1, x2 + 3)")
    print(f"Input: x = {x}")
    print(f"Evaluation: {evaluate(c, x)}")
    print(f"Size: {circuit_size(c)}")
    print(f"Depth: {circuit_depth(c)}")

    # Normal forms
    nf = extract_normal_forms(c, 3)
    print(f"\nNormal forms ({len(nf)} pieces):")
    for af in nf:
        print(f"  {af}  →  eval = {af.eval(x):.2f}")

    # Duality
    lhs, rhs, ok = verify_duality(c, x)
    print(f"\nDuality: eval(C,x) = {lhs:.2f}, -eval_max(D,-x) = {rhs:.2f}, match = {ok}")

    # Boolean embedding
    phi = BAnd(BOr(BVar(0), BVar(1)), BOr(BVar(1), BVar(2)))
    ok = verify_boolean_embedding(phi, 3)
    print(f"\nBoolean embedding (x0∨x1)∧(x1∨x2): all assignments match = {ok}")

    # Random circuit stress test
    rng = np.random.default_rng(42)
    n_tests = 1000
    nf_ok = 0
    dual_ok = 0
    for _ in range(n_tests):
        rc = random_circuit(3, 3, rng)
        rx = rng.standard_normal(3).tolist()
        _, _, m = verify_normal_form(rc, 3, rx)
        nf_ok += m
        _, _, m = verify_duality(rc, rx)
        dual_ok += m

    print(f"\nRandom stress test ({n_tests} circuits):")
    print(f"  Normal form matches: {nf_ok}/{n_tests}")
    print(f"  Duality matches:     {dual_ok}/{n_tests}")
