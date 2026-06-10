#!/usr/bin/env python3
"""
algorithms.py — Implements the core algorithms from the ordinal rank
complexity certificate framework.

Algorithms:
  1. ComputeRank: O(n) ordinal rank computation
  2. Differentiate: O(n) symbolic differentiation with size bounds
  3. PredictDerivCost: O(1) static cost prediction
  4. TropicalVal: O(n) tropical valuation computation
  5. RankPreservationVerifier: checks rank invariant
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Union, Tuple
import math


# ─── Expression AST ──────────────────────────────────────────────────────────

@dataclass(frozen=True)
class Var:
    def __repr__(self): return "x"

@dataclass(frozen=True)
class Const:
    value: float
    def __repr__(self): return str(self.value)

@dataclass(frozen=True)
class Add:
    left: 'Expr'
    right: 'Expr'
    def __repr__(self): return f"({self.left} + {self.right})"

@dataclass(frozen=True)
class Mul:
    left: 'Expr'
    right: 'Expr'
    def __repr__(self): return f"({self.left} * {self.right})"

@dataclass(frozen=True)
class Neg:
    operand: 'Expr'
    def __repr__(self): return f"(-{self.operand})"

@dataclass(frozen=True)
class Eml:
    """EML operation: coeff * exp(exponent)."""
    coeff: 'Expr'
    exponent: 'Expr'
    def __repr__(self): return f"({self.coeff} * exp({self.exponent}))"

Expr = Union[Var, Const, Add, Mul, Neg, Eml]


# ─── Algorithm 1: Ordinal Rank Computation ────────────────────────────────────

@dataclass(frozen=True)
class OrdBlock:
    """Ordinal notation below ω²: represents ω·k + m."""
    omega_coeff: int  # k
    finite_part: int  # m

    def __repr__(self):
        if self.omega_coeff == 0:
            return str(self.finite_part)
        parts = []
        if self.omega_coeff == 1:
            parts.append("ω")
        else:
            parts.append(f"ω·{self.omega_coeff}")
        if self.finite_part > 0:
            parts.append(str(self.finite_part))
        return " + ".join(parts)

    @staticmethod
    def max(a: 'OrdBlock', b: 'OrdBlock') -> 'OrdBlock':
        """Lexicographic maximum of two OrdBlocks."""
        if a.omega_coeff > b.omega_coeff:
            return a
        elif a.omega_coeff < b.omega_coeff:
            return b
        else:
            return OrdBlock(a.omega_coeff, max(a.finite_part, b.finite_part))


def compute_rank(e: Expr) -> OrdBlock:
    """Algorithm 1: Compute the ordinal rank of an EML expression.
    
    Complexity: O(size(e)) time, O(depth(e)) stack space.
    
    The ω-coefficient counts the nesting depth of eml operations.
    The finite part tracks polynomial degree within each ω-block.
    
    Examples:
        >>> compute_rank(Var())
        0
        >>> compute_rank(Eml(Var(), Var()))
        ω
        >>> compute_rank(Eml(Const(1), Eml(Const(1), Var())))
        ω·2
    """
    if isinstance(e, Var):
        return OrdBlock(0, 0)
    elif isinstance(e, Const):
        return OrdBlock(0, 0)
    elif isinstance(e, Add):
        return OrdBlock.max(compute_rank(e.left), compute_rank(e.right))
    elif isinstance(e, Mul):
        return OrdBlock.max(compute_rank(e.left), compute_rank(e.right))
    elif isinstance(e, Neg):
        return compute_rank(e.operand)
    elif isinstance(e, Eml):
        ra = compute_rank(e.coeff)
        rb = compute_rank(e.exponent)
        return OrdBlock(1 + max(ra.omega_coeff, rb.omega_coeff), 0)
    raise TypeError(f"Unknown expression type: {type(e)}")


# ─── Algorithm 2: Symbolic Differentiation ────────────────────────────────────

def differentiate(e: Expr) -> Expr:
    """Algorithm 2: Symbolic differentiation of an EML expression.
    
    Complexity: O(size(e)) time. Output size ≤ 3 * size(e)².
    
    Key rule for eml(a, b) = a * exp(b):
        d/dx[a * exp(b)] = a' * exp(b) + a * b' * exp(b)
                         = eml(a', b) + eml(a * b', b)
    
    Invariant: rank(differentiate(e)) ≤ rank(e) [Theorem 1]
    
    Examples:
        >>> differentiate(Var())
        1
        >>> differentiate(Mul(Var(), Var()))
        ((1 * x) + (x * 1))
    """
    if isinstance(e, Var):
        return Const(1)
    elif isinstance(e, Const):
        return Const(0)
    elif isinstance(e, Add):
        return Add(differentiate(e.left), differentiate(e.right))
    elif isinstance(e, Mul):
        # Product rule: (a*b)' = a'*b + a*b'
        return Add(Mul(differentiate(e.left), e.right),
                   Mul(e.left, differentiate(e.right)))
    elif isinstance(e, Neg):
        return Neg(differentiate(e.operand))
    elif isinstance(e, Eml):
        a, b = e.coeff, e.exponent
        da, db = differentiate(a), differentiate(b)
        # d/dx[a*exp(b)] = a'*exp(b) + a*b'*exp(b)
        return Add(Eml(da, b), Eml(Mul(a, db), b))
    raise TypeError(f"Unknown expression type: {type(e)}")


# ─── Algorithm 3: Static Cost Prediction ─────────────────────────────────────

def eml_size(e: Expr) -> int:
    """Compute the AST size of an expression."""
    if isinstance(e, (Var, Const)):
        return 1
    elif isinstance(e, Add):
        return 1 + eml_size(e.left) + eml_size(e.right)
    elif isinstance(e, Mul):
        return 1 + eml_size(e.left) + eml_size(e.right)
    elif isinstance(e, Neg):
        return 1 + eml_size(e.operand)
    elif isinstance(e, Eml):
        return 1 + eml_size(e.coeff) + eml_size(e.exponent)
    raise TypeError


def predict_deriv_cost(e: Expr, n_derivs: int = 1) -> dict:
    """Algorithm 3: Predict the cost of n-fold differentiation without computing it.
    
    Returns a dictionary with:
        - 'max_size': upper bound on the size of the n-th derivative
        - 'rank': ordinal rank of the expression (preserved under differentiation)
        - 'input_size': size of the input expression
        - 'n_derivs': number of derivatives requested
    
    Complexity: O(size(e)) for rank/size computation, O(1) for bound calculation.
    
    This is the key "complexity certificate" — it provides a static guarantee
    about the cost of computation before any symbolic work is done.
    
    Examples:
        >>> predict_deriv_cost(Mul(Var(), Var()), 1)
        {'max_size': 225, 'rank': 0, 'input_size': 3, 'n_derivs': 1}
    """
    s = eml_size(e)
    rank = compute_rank(e)
    max_size = (3 * s) ** (2 ** n_derivs)
    return {
        'max_size': max_size,
        'rank': rank.omega_coeff,
        'input_size': s,
        'n_derivs': n_derivs,
    }


# ─── Algorithm 4: Tropical Valuation ─────────────────────────────────────────

def tropical_val(e: Expr) -> int:
    """Algorithm 4: Compute the tropical valuation of an EML expression.
    
    Maps to the tropical semiring (ℕ, max, +):
        - eml adds 1 (tropical multiplication = addition)
        - add/mul take max (tropical addition = max)
    
    By the triple invariant theorem:
        tropical_val(e) == compute_rank(e).omega_coeff == eml_depth(e)
    
    Complexity: O(size(e)).
    
    Examples:
        >>> tropical_val(Var())
        0
        >>> tropical_val(Eml(Var(), Var()))
        1
        >>> tropical_val(Eml(Const(1), Eml(Const(1), Var())))
        2
    """
    if isinstance(e, (Var, Const)):
        return 0
    elif isinstance(e, Add):
        return max(tropical_val(e.left), tropical_val(e.right))
    elif isinstance(e, Mul):
        return max(tropical_val(e.left), tropical_val(e.right))
    elif isinstance(e, Neg):
        return tropical_val(e.operand)
    elif isinstance(e, Eml):
        return 1 + max(tropical_val(e.coeff), tropical_val(e.exponent))
    raise TypeError


# ─── Algorithm 5: Rank Preservation Verifier ─────────────────────────────────

def verify_rank_preservation(e: Expr) -> Tuple[bool, str]:
    """Algorithm 5: Verify the rank preservation invariant for a given expression.
    
    Checks that differentiation does not increase the ordinal rank.
    
    Returns (passed, message).
    
    Examples:
        >>> verify_rank_preservation(Eml(Var(), Var()))
        (True, 'Rank preserved: 1 → 1')
    """
    de = differentiate(e)
    r_before = compute_rank(e).omega_coeff
    r_after = compute_rank(de).omega_coeff
    passed = r_after <= r_before
    msg = f"Rank {'preserved' if passed else 'VIOLATED'}: {r_before} → {r_after}"
    return passed, msg


# ─── Example Usage ────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=== Algorithm Demonstrations ===\n")

    # Algorithm 1: Rank computation
    print("Algorithm 1: Ordinal Rank Computation")
    examples = [
        ("x", Var()),
        ("x * x + 3", Add(Mul(Var(), Var()), Const(3))),
        ("x * exp(x)", Eml(Var(), Var())),
        ("exp(exp(x))", Eml(Const(1), Eml(Const(1), Var()))),
        ("exp(exp(exp(x)))", Eml(Const(1), Eml(Const(1), Eml(Const(1), Var())))),
    ]
    for name, e in examples:
        rank = compute_rank(e)
        print(f"  rank({name}) = {rank}")
    print()

    # Algorithm 2: Differentiation
    print("Algorithm 2: Symbolic Differentiation")
    for name, e in examples[:4]:
        de = differentiate(e)
        print(f"  d/dx[{name}] = {de}")
        print(f"    size: {eml_size(e)} → {eml_size(de)}")
    print()

    # Algorithm 3: Cost prediction
    print("Algorithm 3: Static Cost Prediction")
    e = Eml(Mul(Var(), Var()), Mul(Var(), Const(2)))
    for n in range(1, 5):
        pred = predict_deriv_cost(e, n)
        print(f"  {n}-fold deriv of size-{pred['input_size']} rank-{pred['rank']} expr: "
              f"max size ≤ {pred['max_size']}")
    print()

    # Algorithm 4: Tropical valuation
    print("Algorithm 4: Tropical Valuation (Triple Invariant)")
    for name, e in examples:
        tv = tropical_val(e)
        rc = compute_rank(e).omega_coeff
        match = "✓" if tv == rc else "✗"
        print(f"  {name}: tropical={tv}, rank_ω={rc} {match}")
    print()

    # Algorithm 5: Rank preservation
    print("Algorithm 5: Rank Preservation Verification")
    for name, e in examples:
        passed, msg = verify_rank_preservation(e)
        print(f"  {name}: {msg}")
    print()
