#!/usr/bin/env python3
"""
EML Network Algorithms: Type-hinted implementations

Core algorithms for EML term construction, evaluation, complexity analysis,
and approximation.
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Callable, List, Optional, Tuple
import math


# --- EML Term Data Structure ---

@dataclass
class EMLTerm:
    """Base class for EML terms."""
    pass

@dataclass
class Const(EMLTerm):
    """Constant function: x ↦ c"""
    value: float

@dataclass
class Proj(EMLTerm):
    """Identity/projection: x ↦ x"""
    pass

@dataclass
class Exp(EMLTerm):
    """Exponential: x ↦ exp(child(x))"""
    child: EMLTerm

@dataclass
class Log(EMLTerm):
    """Logarithm: x ↦ log(child(x))"""
    child: EMLTerm

@dataclass
class Add(EMLTerm):
    """Addition: x ↦ left(x) + right(x)"""
    left: EMLTerm
    right: EMLTerm

@dataclass
class Mul(EMLTerm):
    """Multiplication: x ↦ left(x) · right(x)"""
    left: EMLTerm
    right: EMLTerm


# --- Evaluation ---

def evaluate(term: EMLTerm, x: float) -> float:
    """Evaluate an EML term at a point.

    Uses safe log (returns 0 for non-positive inputs) matching Lean's Real.log.
    """
    if isinstance(term, Const):
        return term.value
    elif isinstance(term, Proj):
        return x
    elif isinstance(term, Exp):
        return math.exp(evaluate(term.child, x))
    elif isinstance(term, Log):
        val = evaluate(term.child, x)
        return math.log(val) if val > 0 else 0.0
    elif isinstance(term, Add):
        return evaluate(term.left, x) + evaluate(term.right, x)
    elif isinstance(term, Mul):
        return evaluate(term.left, x) * evaluate(term.right, x)
    raise TypeError(f"Unknown term type: {type(term)}")


# --- Complexity Measures ---

def width(term: EMLTerm) -> int:
    """Count transcendental operations (Exp, Log)."""
    if isinstance(term, (Const, Proj)):
        return 0
    elif isinstance(term, (Exp, Log)):
        return width(term.child) + 1
    elif isinstance(term, (Add, Mul)):
        return width(term.left) + width(term.right)
    return 0

def depth(term: EMLTerm) -> int:
    """Longest path from root to leaf."""
    if isinstance(term, (Const, Proj)):
        return 0
    elif isinstance(term, (Exp, Log)):
        return depth(term.child) + 1
    elif isinstance(term, (Add, Mul)):
        return max(depth(term.left), depth(term.right)) + 1
    return 0

def size(term: EMLTerm) -> int:
    """Total number of nodes."""
    if isinstance(term, (Const, Proj)):
        return 1
    elif isinstance(term, (Exp, Log)):
        return size(term.child) + 1
    elif isinstance(term, (Add, Mul)):
        return size(term.left) + size(term.right) + 1
    return 1

def is_log_free(term: EMLTerm) -> bool:
    """Check if a term contains no Log nodes."""
    if isinstance(term, (Const, Proj)):
        return True
    elif isinstance(term, Exp):
        return is_log_free(term.child)
    elif isinstance(term, Log):
        return False
    elif isinstance(term, (Add, Mul)):
        return is_log_free(term.left) and is_log_free(term.right)
    return True


# --- Composition ---

def compose(s: EMLTerm, t: EMLTerm) -> EMLTerm:
    """Substitute t for every Proj in s: (s ∘ t)(x) = s(t(x))."""
    if isinstance(s, Const):
        return s
    elif isinstance(s, Proj):
        return t
    elif isinstance(s, Exp):
        return Exp(compose(s.child, t))
    elif isinstance(s, Log):
        return Log(compose(s.child, t))
    elif isinstance(s, Add):
        return Add(compose(s.left, t), compose(s.right, t))
    elif isinstance(s, Mul):
        return Mul(compose(s.left, t), compose(s.right, t))
    raise TypeError(f"Unknown term type: {type(s)}")


# --- Constructors ---

def power_term(n: int) -> EMLTerm:
    """Construct the EML term for x^n (width 0)."""
    if n == 0:
        return Const(1.0)
    return Mul(power_term(n - 1), Proj())

def iter_exp_term(n: int) -> EMLTerm:
    """Construct exp^[n](x) as an EML term (width = depth = n)."""
    if n == 0:
        return Proj()
    return Exp(iter_exp_term(n - 1))

def polynomial_term(coeffs: List[float]) -> EMLTerm:
    """Construct a_0 + a_1*x + a_2*x² + ... as an EML term.

    Width is always 0 (no transcendentals).
    """
    if not coeffs:
        return Const(0.0)
    result: EMLTerm = Const(coeffs[0])
    x_power: EMLTerm = Proj()
    for i, c in enumerate(coeffs[1:], 1):
        if abs(c) > 1e-15:
            term = Mul(Const(c), x_power)
            result = Add(result, term)
        if i < len(coeffs) - 1:
            x_power = Mul(x_power, Proj())
    return result

def approx_square_term() -> EMLTerm:
    """The EML term 2*(exp(x) - 1 - x) approximating x²."""
    return Mul(
        Const(2.0),
        Add(
            Exp(Proj()),
            Mul(Const(-1.0), Add(Const(1.0), Proj()))
        )
    )


# --- EML Complexity Estimation ---

def estimate_eml_complexity(
    f: Callable[[float], float],
    a: float,
    b: float,
    epsilon: float,
    max_width: int = 10,
    n_samples: int = 100
) -> Optional[int]:
    """Estimate EML complexity by brute-force search over small terms.

    Returns the minimum width of an EML term achieving epsilon-approximation,
    or None if no term found within max_width.
    """
    xs = [a + (b - a) * i / n_samples for i in range(n_samples + 1)]
    f_vals = [f(x) for x in xs]

    # Width 0: check polynomials up to degree 10
    for deg in range(11):
        term = power_term(deg)
        # Try scaling: c * x^deg
        for c_int in range(-20, 21):
            c = c_int / 10.0
            scaled = Mul(Const(c), term) if abs(c - 1.0) > 1e-10 else term
            try:
                errors = [abs(evaluate(scaled, x) - fv) for x, fv in zip(xs, f_vals)]
                if max(errors) <= epsilon:
                    return 0
            except (OverflowError, ValueError):
                continue

    # Width 1: try a * exp(b*x + c) + d*x + e
    for a_i in range(-5, 6):
        for b_i in range(-5, 6):
            for d_i in range(-5, 6):
                a_c = a_i / 5.0
                b_c = b_i / 5.0
                d_c = d_i / 5.0
                term = Add(
                    Mul(Const(a_c), Exp(Add(Mul(Const(b_c), Proj()), Const(0.0)))),
                    Mul(Const(d_c), Proj())
                )
                try:
                    errors = [abs(evaluate(term, x) - fv) for x, fv in zip(xs, f_vals)]
                    if max(errors) <= epsilon:
                        return 1
                except (OverflowError, ValueError):
                    continue

    return None


# --- Pretty Printing ---

def to_string(term: EMLTerm) -> str:
    """Convert EML term to human-readable string."""
    if isinstance(term, Const):
        return str(term.value)
    elif isinstance(term, Proj):
        return "x"
    elif isinstance(term, Exp):
        return f"exp({to_string(term.child)})"
    elif isinstance(term, Log):
        return f"log({to_string(term.child)})"
    elif isinstance(term, Add):
        return f"({to_string(term.left)} + {to_string(term.right)})"
    elif isinstance(term, Mul):
        return f"({to_string(term.left)} * {to_string(term.right)})"
    return "?"


if __name__ == "__main__":
    # Quick test
    t = approx_square_term()
    print(f"Term: {to_string(t)}")
    print(f"Width: {width(t)}, Depth: {depth(t)}, Size: {size(t)}")
    print(f"Log-free: {is_log_free(t)}")
    print(f"eval(0.5) = {evaluate(t, 0.5):.6f} (x² = {0.25:.6f})")

    # Composition test
    exp2 = compose(Exp(Proj()), Exp(Proj()))
    print(f"\nexp(exp(x)): {to_string(exp2)}")
    print(f"Width: {width(exp2)}, Depth: {depth(exp2)}")
    print(f"eval(0) = {evaluate(exp2, 0.0):.6f} (expected {math.e:.6f})")
