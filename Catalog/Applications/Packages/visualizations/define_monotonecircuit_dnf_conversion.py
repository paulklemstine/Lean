#!/usr/bin/env python3
"""
Monotone Min-Max Circuits: Core Algorithms

Implements the fundamental algorithms for monotone circuit manipulation:
1. Circuit evaluation
2. Distributive Normal Form (DNF) conversion
3. Circuit equivalence checking
4. Sensitivity analysis
5. Random circuit generation
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Optional
import random
import math


# ─── Circuit Data Type ───────────────────────────────────────────────

@dataclass(frozen=True)
class Var:
    """Input variable gate."""
    index: int

@dataclass(frozen=True)
class Const:
    """Constant gate."""
    value: float

@dataclass(frozen=True)
class And:
    """Min gate (AND)."""
    left: 'Circuit'
    right: 'Circuit'

@dataclass(frozen=True)
class Or:
    """Max gate (OR)."""
    left: 'Circuit'
    right: 'Circuit'

Circuit = Var | Const | And | Or


# ─── Algorithm 1: Evaluation ─────────────────────────────────────────

def evaluate(c: Circuit, x: list[float]) -> float:
    """
    Evaluate a monotone circuit on input assignment x.

    Complexity: O(|c|) time, O(depth(c)) stack space.

    Args:
        c: A monotone min-max circuit.
        x: Input assignment, x[i] is the value of variable i.

    Returns:
        The evaluated output value.

    Examples:
        >>> evaluate(Var(0), [3.0, 5.0])
        3.0
        >>> evaluate(And(Var(0), Var(1)), [3.0, 5.0])
        3.0
        >>> evaluate(Or(Var(0), Var(1)), [3.0, 5.0])
        5.0
    """
    match c:
        case Var(i):
            return x[i]
        case Const(v):
            return v
        case And(l, r):
            return min(evaluate(l, x), evaluate(r, x))
        case Or(l, r):
            return max(evaluate(l, x), evaluate(r, x))


# ─── Algorithm 2: DNF Conversion ─────────────────────────────────────

def _distribute_and(c1: Circuit, c2: Circuit) -> Circuit:
    """
    Distribute AND (min) over OR (max) in two sub-circuits.

    Applies the distributive law:
        min(c1, max(b, c)) = max(min(c1, b), min(c1, c))
    recursively until all ANDs are inside all ORs.
    """
    match c2:
        case Or(b, c):
            return Or(_distribute_and(c1, b), _distribute_and(c1, c))
        case _:
            match c1:
                case Or(a, b):
                    return Or(_distribute_and(a, c2), _distribute_and(b, c2))
                case _:
                    return And(c1, c2)


def to_dnf(c: Circuit) -> Circuit:
    """
    Convert a circuit to Distributive Normal Form (max-of-mins).

    The output is semantically equivalent: for all inputs x,
        evaluate(to_dnf(c), x) == evaluate(c, x)

    The output has the structure: Or(Or(..., And-term), And-term)
    where each And-term contains only variables, constants, and And gates.

    Warning: Output size can be exponential in input size.

    Complexity: O(2^depth(c)) worst case for output size.

    Examples:
        >>> c = And(Var(0), Or(Var(1), Var(2)))
        >>> dnf = to_dnf(c)
        >>> # dnf is max(min(x0, x1), min(x0, x2))
    """
    match c:
        case Var(_) | Const(_):
            return c
        case Or(l, r):
            return Or(to_dnf(l), to_dnf(r))
        case And(l, r):
            d1 = to_dnf(l)
            d2 = to_dnf(r)
            return _distribute_and(d1, d2)


# ─── Algorithm 3: Circuit Metrics ────────────────────────────────────

def size(c: Circuit) -> int:
    """Number of nodes in the circuit tree."""
    match c:
        case Var(_) | Const(_):
            return 1
        case And(l, r) | Or(l, r):
            return 1 + size(l) + size(r)


def depth(c: Circuit) -> int:
    """Depth (height) of the circuit tree."""
    match c:
        case Var(_) | Const(_):
            return 0
        case And(l, r) | Or(l, r):
            return 1 + max(depth(l), depth(r))


def num_variables(c: Circuit) -> set[int]:
    """Set of variable indices used in the circuit."""
    match c:
        case Var(i):
            return {i}
        case Const(_):
            return set()
        case And(l, r) | Or(l, r):
            return num_variables(l) | num_variables(r)


# ─── Algorithm 4: Equivalence Checking ───────────────────────────────

def circuits_equivalent(c1: Circuit, c2: Circuit, n_vars: int,
                        n_samples: int = 10000,
                        domain: tuple[float, float] = (-100, 100)) -> bool:
    """
    Probabilistically check if two circuits are semantically equivalent.

    Tests on random inputs. For exact equivalence over finite domains,
    convert both to DNF and compare structurally.

    Args:
        c1, c2: Circuits to compare.
        n_vars: Number of input variables.
        n_samples: Number of random tests.
        domain: Range for random inputs.

    Returns:
        True if equivalent on all tested inputs.
    """
    for _ in range(n_samples):
        x = [random.uniform(*domain) for _ in range(n_vars)]
        if abs(evaluate(c1, x) - evaluate(c2, x)) > 1e-10:
            return False
    return True


# ─── Algorithm 5: Sensitivity Analysis ───────────────────────────────

def sensitivity(c: Circuit, x: list[float], delta: float = 0.01) -> dict:
    """
    Analyze the sensitivity of a circuit at a given input.

    Computes how much the output changes when each input is perturbed
    by ±delta. By Theorem 3.8, the maximum sensitivity ratio is ≤ 1.

    Args:
        c: Circuit to analyze.
        x: Base input.
        delta: Perturbation size.

    Returns:
        Dictionary with per-coordinate sensitivities and max sensitivity ratio.
    """
    base = evaluate(c, x)
    sensitivities = {}

    for i in range(len(x)):
        x_plus = list(x)
        x_plus[i] += delta
        x_minus = list(x)
        x_minus[i] -= delta

        change_plus = evaluate(c, x_plus) - base
        change_minus = evaluate(c, x_minus) - base
        max_change = max(abs(change_plus), abs(change_minus))

        sensitivities[i] = {
            'change_plus': change_plus,
            'change_minus': change_minus,
            'max_abs_change': max_change,
            'sensitivity_ratio': max_change / delta if delta > 0 else 0
        }

    max_ratio = max(s['sensitivity_ratio'] for s in sensitivities.values())

    return {
        'base_output': base,
        'delta': delta,
        'per_coordinate': sensitivities,
        'max_sensitivity_ratio': max_ratio,
        'is_nonexpansive': max_ratio <= 1.0 + 1e-10
    }


# ─── Algorithm 6: Random Circuit Generation ─────────────────────────

def random_circuit(n_vars: int, max_depth: int,
                   const_prob: float = 0.1,
                   const_range: tuple[float, float] = (-10, 10),
                   rng: Optional[random.Random] = None) -> Circuit:
    """
    Generate a random monotone circuit.

    Args:
        n_vars: Number of input variables (must be > 0).
        max_depth: Maximum depth of the generated circuit.
        const_prob: Probability of a leaf being a constant vs variable.
        const_range: Range for random constants.
        rng: Random number generator (uses global if None).

    Returns:
        A random MonotoneCircuit.
    """
    if rng is None:
        rng = random.Random()

    if max_depth == 0:
        if rng.random() < const_prob:
            return Const(round(rng.uniform(*const_range), 2))
        else:
            return Var(rng.randint(0, n_vars - 1))

    # Random gate type
    if rng.random() < 0.5:
        gate = And
    else:
        gate = Or

    left = random_circuit(n_vars, max_depth - 1, const_prob, const_range, rng)
    right = random_circuit(n_vars, max_depth - 1, const_prob, const_range, rng)
    return gate(left, right)


# ─── Algorithm 7: Lipschitz Constant Estimation ─────────────────────

def estimate_lipschitz(c: Circuit, n_vars: int,
                       n_samples: int = 10000,
                       domain: tuple[float, float] = (-10, 10)) -> float:
    """
    Estimate the Lipschitz constant of a circuit empirically.

    By Theorem 3.8, this should always return a value ≤ 1.0 (up to
    floating point errors).

    Args:
        c: Circuit to analyze.
        n_vars: Number of input variables.
        n_samples: Number of random pairs to test.
        domain: Range for random inputs.

    Returns:
        Estimated Lipschitz constant (should be ≤ 1.0).
    """
    max_ratio = 0.0

    for _ in range(n_samples):
        x = [random.uniform(*domain) for _ in range(n_vars)]
        y = [random.uniform(*domain) for _ in range(n_vars)]

        input_diff = max(abs(x[i] - y[i]) for i in range(n_vars))
        output_diff = abs(evaluate(c, x) - evaluate(c, y))

        if input_diff > 1e-15:
            ratio = output_diff / input_diff
            max_ratio = max(max_ratio, ratio)

    return max_ratio


# ─── Pretty Printing ─────────────────────────────────────────────────

def circuit_str(c: Circuit) -> str:
    """Pretty-print a circuit as a string."""
    match c:
        case Var(i):
            return f"x{i}"
        case Const(v):
            return f"{v}"
        case And(l, r):
            return f"min({circuit_str(l)}, {circuit_str(r)})"
        case Or(l, r):
            return f"max({circuit_str(l)}, {circuit_str(r)})"


# ─── Example Usage ───────────────────────────────────────────────────

if __name__ == "__main__":
    print("=== Algorithms Demo ===\n")

    # Build a circuit
    c = And(Var(0), Or(Var(1), Const(3.0)))
    print(f"Circuit: {circuit_str(c)}")
    print(f"Size: {size(c)}, Depth: {depth(c)}")
    print(f"Variables: {num_variables(c)}")

    # Evaluate
    x = [5.0, 2.0]
    print(f"eval({circuit_str(c)}, {x}) = {evaluate(c, x)}")

    # DNF
    dnf = to_dnf(c)
    print(f"\nDNF: {circuit_str(dnf)}")
    print(f"DNF size: {size(dnf)}, DNF depth: {depth(dnf)}")
    print(f"Equivalent: {circuits_equivalent(c, dnf, 2)}")

    # Sensitivity
    print(f"\nSensitivity at x={x}:")
    sens = sensitivity(c, x)
    for i, s in sens['per_coordinate'].items():
        print(f"  x{i}: ratio = {s['sensitivity_ratio']:.4f}")
    print(f"  Max ratio: {sens['max_sensitivity_ratio']:.4f} (≤ 1.0: {sens['is_nonexpansive']})")

    # Lipschitz estimation
    print(f"\nEstimated Lipschitz constant: {estimate_lipschitz(c, 2):.6f}")

    # Random circuit
    rng = random.Random(42)
    rc = random_circuit(3, 4, rng=rng)
    print(f"\nRandom circuit: {circuit_str(rc)}")
    print(f"  Size: {size(rc)}, Depth: {depth(rc)}")
    print(f"  Lipschitz: {estimate_lipschitz(rc, 3):.6f}")
