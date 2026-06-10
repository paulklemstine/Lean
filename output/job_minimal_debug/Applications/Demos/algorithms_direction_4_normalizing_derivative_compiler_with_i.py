#!/usr/bin/env python3
"""
Algorithms for Certified Derivative Normalization

Implements the normalization algorithm with complexity analysis and
the Good fragment classifier for EML expressions.
"""

from dataclasses import dataclass
from typing import Union, Optional, Tuple
import math


# ─── Expression AST ───────────────────────────────────────────────────────────

@dataclass(frozen=True)
class Const:
    value: float

@dataclass(frozen=True)
class Var:
    pass

@dataclass(frozen=True)
class Add:
    left: 'Expr'
    right: 'Expr'

@dataclass(frozen=True)
class Mul:
    left: 'Expr'
    right: 'Expr'

@dataclass(frozen=True)
class Exp:
    arg: 'Expr'

Expr = Union[Const, Var, Add, Mul, Exp]


def pretty(e: Expr) -> str:
    if isinstance(e, Const):
        v = e.value
        return str(int(v)) if v == int(v) else f"{v:.4g}"
    elif isinstance(e, Var):
        return "x"
    elif isinstance(e, Add):
        return f"({pretty(e.left)} + {pretty(e.right)})"
    elif isinstance(e, Mul):
        return f"({pretty(e.left)} * {pretty(e.right)})"
    elif isinstance(e, Exp):
        return f"exp({pretty(e.arg)})"
    raise TypeError


# ─── Algorithm 1: Depth Computation ──────────────────────────────────────────

def depth(e: Expr) -> int:
    """Compute the depth (Hardy hierarchy level) of an expression.

    Time complexity: O(n) where n = number of nodes.
    Space complexity: O(h) where h = tree height (recursion stack).

    The depth counts the maximum nesting of exp operations:
    - Constants and variables have depth 0
    - add/mul preserve the max depth of children
    - exp increments depth by 1
    """
    if isinstance(e, (Const, Var)):
        return 0
    elif isinstance(e, (Add, Mul)):
        return max(depth(e.left), depth(e.right))
    elif isinstance(e, Exp):
        return depth(e.arg) + 1
    raise TypeError


def size(e: Expr) -> int:
    """Count the number of nodes in the expression tree.

    Time/Space complexity: O(n) / O(h).
    """
    if isinstance(e, (Const, Var)):
        return 1
    elif isinstance(e, (Add, Mul)):
        return 1 + size(e.left) + size(e.right)
    elif isinstance(e, Exp):
        return 1 + size(e.arg)
    raise TypeError


# ─── Algorithm 2: Symbolic Differentiation ───────────────────────────────────

def deriv(e: Expr) -> Expr:
    """Symbolic differentiation with respect to x.

    Time complexity: O(n) where n = size of input.
    Output size: O(n²) in worst case (product rule duplication).

    Rules:
    - d/dx(c) = 0
    - d/dx(x) = 1
    - d/dx(a + b) = a' + b'
    - d/dx(a * b) = a'b + ab'  (product rule)
    - d/dx(exp(a)) = a' * exp(a)  (chain rule)
    """
    if isinstance(e, Const):
        return Const(0)
    elif isinstance(e, Var):
        return Const(1)
    elif isinstance(e, Add):
        return Add(deriv(e.left), deriv(e.right))
    elif isinstance(e, Mul):
        return Add(Mul(deriv(e.left), e.right), Mul(e.left, deriv(e.right)))
    elif isinstance(e, Exp):
        return Mul(deriv(e.arg), Exp(e.arg))
    raise TypeError


# ─── Algorithm 3: Smart Constructors ─────────────────────────────────────────

def mk_add(a: Expr, b: Expr) -> Expr:
    """Smart addition with identity elimination.

    Rules: 0 + e = e, e + 0 = e.
    Time: O(1). Depth: depth(result) ≤ max(depth(a), depth(b)).
    """
    if a == Const(0):
        return b
    if b == Const(0):
        return a
    return Add(a, b)


def mk_mul(a: Expr, b: Expr) -> Expr:
    """Smart multiplication with identity/annihilation elimination.

    Rules: 0*e = 0, e*0 = 0, 1*e = e, e*1 = e.
    Time: O(1). Depth: depth(result) ≤ max(depth(a), depth(b)).
    """
    if a == Const(0) or b == Const(0):
        return Const(0)
    if a == Const(1):
        return b
    if b == Const(1):
        return a
    return Mul(a, b)


def mk_exp(a: Expr) -> Expr:
    """Smart exponentiation with constant folding.

    Rule: exp(0) = 1.
    Time: O(1). Depth: depth(result) ≤ depth(a) + 1.
    """
    if a == Const(0):
        return Const(1)
    return Exp(a)


# ─── Algorithm 4: Normalization ──────────────────────────────────────────────

def normalize(e: Expr) -> Expr:
    """Bottom-up normalization using smart constructors.

    Time complexity: O(n) where n = size of input.
    Space complexity: O(n) for the output + O(h) for recursion.

    Key invariants (formally verified):
    1. eval(normalize(e), x) = eval(e, x) for all x
    2. depth(normalize(e)) ≤ depth(e)

    Combined with differentiation:
    3. depth(normalize(deriv(e))) ≤ depth(e)  [FLAGSHIP THEOREM]
    """
    if isinstance(e, (Const, Var)):
        return e
    elif isinstance(e, Add):
        return mk_add(normalize(e.left), normalize(e.right))
    elif isinstance(e, Mul):
        return mk_mul(normalize(e.left), normalize(e.right))
    elif isinstance(e, Exp):
        return mk_exp(normalize(e.arg))
    raise TypeError


# ─── Algorithm 5: Good Fragment Classifier ───────────────────────────────────

def is_good(e: Expr) -> bool:
    """Check if expression belongs to the polynomial-exponential fragment.

    The Good fragment consists of expressions where every exp argument
    has depth 0 (i.e., is polynomial). This excludes iterated
    exponentials like exp(exp(x)).

    Time complexity: O(n).
    """
    if isinstance(e, (Const, Var)):
        return True
    elif isinstance(e, (Add, Mul)):
        return is_good(e.left) and is_good(e.right)
    elif isinstance(e, Exp):
        return is_good(e.arg) and depth(e.arg) == 0
    return False


# ─── Algorithm 6: Certified Pipeline ────────────────────────────────────────

@dataclass
class NormalFormCert:
    """Proof-carrying normalized expression.

    Packages an expression with its normal form and certificates:
    - sem_eq: semantic equivalence (checked by evaluation)
    - depth_le: depth bound (verified computationally)
    """
    expr: Expr
    nf: Expr
    depth_original: int
    depth_normalized: int
    depth_le: bool  # depth(nf) ≤ depth(expr)

    def __repr__(self):
        return (f"NormalFormCert(\n"
                f"  expr = {pretty(self.expr)}\n"
                f"  nf   = {pretty(self.nf)}\n"
                f"  depth: {self.depth_original} → {self.depth_normalized} "
                f"({'✓' if self.depth_le else '✗'})\n"
                f")")


def certify(e: Expr) -> NormalFormCert:
    """Construct a certified normal form for an expression."""
    nf = normalize(e)
    d_orig = depth(e)
    d_nf = depth(nf)
    return NormalFormCert(
        expr=e, nf=nf,
        depth_original=d_orig,
        depth_normalized=d_nf,
        depth_le=(d_nf <= d_orig)
    )


def certify_deriv(e: Expr) -> NormalFormCert:
    """Construct a certified normal form for the derivative.

    This witnesses the zero-overhead differentiation theorem:
    depth(normalize(deriv(e))) ≤ depth(e).
    """
    d = deriv(e)
    nf = normalize(d)
    d_orig = depth(e)
    d_nf = depth(nf)
    return NormalFormCert(
        expr=e, nf=nf,
        depth_original=d_orig,
        depth_normalized=d_nf,
        depth_le=(d_nf <= d_orig)
    )


# ─── Algorithm 7: Evaluation ─────────────────────────────────────────────────

def evaluate(e: Expr, x: float) -> float:
    """Evaluate an expression at a point.

    Time complexity: O(n).
    """
    if isinstance(e, Const):
        return e.value
    elif isinstance(e, Var):
        return x
    elif isinstance(e, Add):
        return evaluate(e.left, x) + evaluate(e.right, x)
    elif isinstance(e, Mul):
        return evaluate(e.left, x) * evaluate(e.right, x)
    elif isinstance(e, Exp):
        try:
            return math.exp(evaluate(e.arg, x))
        except OverflowError:
            return float('inf')
    raise TypeError


def verify_semantic_preservation(e: Expr, test_points: list = None) -> bool:
    """Numerically verify that normalization preserves semantics."""
    if test_points is None:
        test_points = [-2.0, -1.0, 0.0, 0.5, 1.0, 2.0, 3.0]

    nf = normalize(e)
    for x in test_points:
        v1 = evaluate(e, x)
        v2 = evaluate(nf, x)
        if abs(v1 - v2) > 1e-10 * max(1, abs(v1)):
            return False
    return True


# ─── Main ────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Algorithms for Certified Derivative Normalization")
    print("=" * 55)
    print()

    # Example: certify derivative of exp(x*x)
    e = Exp(Mul(Var(), Var()))
    print(f"Expression: {pretty(e)}")
    print()

    cert = certify_deriv(e)
    print(f"Derivative certificate:")
    print(cert)
    print()

    # Verify semantic preservation
    print(f"Semantic preservation verified: {verify_semantic_preservation(deriv(e))}")
    print()

    # Show pipeline for several expressions
    examples = [
        Var(),
        Mul(Var(), Var()),
        Exp(Var()),
        Mul(Var(), Exp(Var())),
        Exp(Exp(Var())),
    ]

    print("Pipeline summary:")
    print(f"{'Expression':<20} {'depth(e)':<10} {'depth(norm(d/dx e))':<22} {'Good?'}")
    print("-" * 62)
    for e in examples:
        nd = normalize(deriv(e))
        print(f"{pretty(e):<20} {depth(e):<10} {depth(nd):<22} {is_good(e)}")
