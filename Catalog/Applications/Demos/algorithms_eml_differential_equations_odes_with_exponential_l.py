"""
EML Differential Equations: Core Algorithms

Type-hinted implementations of the key algorithms from the EML ODE theory.
"""

from typing import Union, List, Tuple, Optional
import numpy as np
from dataclasses import dataclass


# ============================================================
# Algorithm 1: EML Expression Symbolic Differentiation
# ============================================================

@dataclass
class EMLConst:
    value: float

@dataclass
class EMLVar:
    pass

@dataclass
class EMLAdd:
    left: 'EMLNode'
    right: 'EMLNode'

@dataclass
class EMLMul:
    left: 'EMLNode'
    right: 'EMLNode'

@dataclass
class EMLNeg:
    child: 'EMLNode'

@dataclass
class EMLInv:
    child: 'EMLNode'

@dataclass
class EMLExp:
    child: 'EMLNode'

@dataclass
class EMLLog:
    child: 'EMLNode'

EMLNode = Union[EMLConst, EMLVar, EMLAdd, EMLMul, EMLNeg, EMLInv, EMLExp, EMLLog]


def eml_eval(node: EMLNode, x: float) -> float:
    """Evaluate an EML expression at a point x."""
    if isinstance(node, EMLConst):
        return node.value
    elif isinstance(node, EMLVar):
        return x
    elif isinstance(node, EMLAdd):
        return eml_eval(node.left, x) + eml_eval(node.right, x)
    elif isinstance(node, EMLMul):
        return eml_eval(node.left, x) * eml_eval(node.right, x)
    elif isinstance(node, EMLNeg):
        return -eml_eval(node.child, x)
    elif isinstance(node, EMLInv):
        v = eml_eval(node.child, x)
        return 1.0 / v if v != 0 else float('inf')
    elif isinstance(node, EMLExp):
        return np.exp(np.clip(eml_eval(node.child, x), -500, 500))
    elif isinstance(node, EMLLog):
        v = eml_eval(node.child, x)
        return np.log(max(v, 1e-300))
    raise TypeError(f"Unknown node type: {type(node)}")


def eml_depth(node: EMLNode) -> int:
    """Compute the EML depth (transcendental nesting level)."""
    if isinstance(node, (EMLConst, EMLVar)):
        return 0
    elif isinstance(node, (EMLAdd, EMLMul)):
        return max(eml_depth(node.left), eml_depth(node.right))
    elif isinstance(node, (EMLNeg, EMLInv)):
        return eml_depth(node.child)
    elif isinstance(node, (EMLExp, EMLLog)):
        return eml_depth(node.child) + 1
    raise TypeError(f"Unknown node type: {type(node)}")


def eml_symb_deriv(node: EMLNode) -> EMLNode:
    """
    Symbolic differentiation of an EML expression.

    Algorithm:
        INPUT: EML expression tree e
        OUTPUT: EML expression tree e' = de/dx

    Rules:
        d/dx(c)      = 0
        d/dx(x)      = 1
        d/dx(f + g)  = f' + g'
        d/dx(f * g)  = f'g + fg'
        d/dx(-f)     = -f'
        d/dx(1/f)    = -f'/(f²)
        d/dx(exp(f)) = exp(f) * f'
        d/dx(log(f)) = f'/f

    Key property: depth(e') ≤ depth(e) (Closure Theorem).
    """
    if isinstance(node, EMLConst):
        return EMLConst(0)
    elif isinstance(node, EMLVar):
        return EMLConst(1)
    elif isinstance(node, EMLAdd):
        return EMLAdd(eml_symb_deriv(node.left), eml_symb_deriv(node.right))
    elif isinstance(node, EMLMul):
        return EMLAdd(
            EMLMul(eml_symb_deriv(node.left), node.right),
            EMLMul(node.left, eml_symb_deriv(node.right))
        )
    elif isinstance(node, EMLNeg):
        return EMLNeg(eml_symb_deriv(node.child))
    elif isinstance(node, EMLInv):
        # d/dx(1/f) = -f'/(f²)
        return EMLNeg(EMLMul(
            eml_symb_deriv(node.child),
            EMLInv(EMLMul(node.child, node.child))
        ))
    elif isinstance(node, EMLExp):
        # d/dx(exp(f)) = exp(f) * f'
        return EMLMul(EMLExp(node.child), eml_symb_deriv(node.child))
    elif isinstance(node, EMLLog):
        # d/dx(log(f)) = f'/f
        return EMLMul(eml_symb_deriv(node.child), EMLInv(node.child))
    raise TypeError(f"Unknown node type: {type(node)}")


# ============================================================
# Algorithm 2: EML ODE Depth Analysis (Kovacic-style)
# ============================================================

def analyze_ode_depth(
    coeff2: EMLNode,
    coeff1: EMLNode,
    coeff0: EMLNode
) -> dict:
    """
    Analyze the depth structure of a second-order linear EML ODE.

    INPUT: Coefficients a(x), b(x), c(x) of a(x)y'' + b(x)y' + c(x)y = 0
    OUTPUT: Depth analysis including operator depth and Wronskian properties

    Algorithm (Kovacic-inspired depth analysis):
        1. Compute operator depth d = max(depth(a), depth(b), depth(c))
        2. Compute reduced form: divide by a to get y'' + p*y' + q*y = 0
        3. Analyze Wronskian depth: W' = -p*W implies W = C*exp(-∫p)
        4. If p is EML of depth d_p, the Wronskian involves antiderivatives
           of EML functions, which may increase depth
    """
    d_a = eml_depth(coeff2)
    d_b = eml_depth(coeff1)
    d_c = eml_depth(coeff0)
    operator_depth = max(d_a, d_b, d_c)

    # Compute p = b/a and q = c/a (as EML expressions)
    p_expr = EMLMul(coeff1, EMLInv(coeff2))
    q_expr = EMLMul(coeff0, EMLInv(coeff2))

    p_depth = eml_depth(p_expr)
    q_depth = eml_depth(q_expr)

    return {
        'operator_depth': operator_depth,
        'p_depth': p_depth,
        'q_depth': q_depth,
        'reduced_depth': max(p_depth, q_depth),
        'wronskian_note': (
            f"W' = -p·W, so W = C·exp(-∫p(x)dx). "
            f"Since p has depth {p_depth}, the Wronskian "
            f"involves exp of an antiderivative of a depth-{p_depth} EML function."
        )
    }


# ============================================================
# Algorithm 3: Numerical Wronskian Verification
# ============================================================

def verify_abel_identity(
    p_func: callable,
    y1: np.ndarray,
    y1p: np.ndarray,
    y2: np.ndarray,
    y2p: np.ndarray,
    xs: np.ndarray
) -> Tuple[float, float]:
    """
    Numerically verify Abel's identity W' = -p·W.

    INPUT: coefficient p(x), two solutions y₁, y₂ with derivatives
    OUTPUT: (max_error, relative_error) of W' + p·W = 0

    Algorithm:
        1. Compute W(x) = y₁·y₂' - y₂·y₁'
        2. Compute W'(x) numerically (finite differences)
        3. Compute -p(x)·W(x)
        4. Return max|W' + p·W|
    """
    W = y1 * y2p - y2 * y1p
    h = xs[1] - xs[0]
    Wprime = np.gradient(W, h)
    pW = np.array([p_func(x) for x in xs]) * W
    error = Wprime + pW
    max_error = float(np.max(np.abs(error[10:-10])))  # trim boundaries
    rel_error = max_error / (np.max(np.abs(W[10:-10])) + 1e-15)
    return max_error, rel_error


# ============================================================
# Algorithm 4: EML Expression Substitution
# ============================================================

def eml_subst(expr: EMLNode, replacement: EMLNode) -> EMLNode:
    """
    Substitute the variable in expr with replacement.

    INPUT: EML expression e, replacement expression f
    OUTPUT: e[x ↦ f], the expression with x replaced by f

    Key property: depth(e[x ↦ f]) ≤ depth(e) + depth(f)
    """
    if isinstance(expr, EMLConst):
        return expr
    elif isinstance(expr, EMLVar):
        return replacement
    elif isinstance(expr, EMLAdd):
        return EMLAdd(eml_subst(expr.left, replacement),
                      eml_subst(expr.right, replacement))
    elif isinstance(expr, EMLMul):
        return EMLMul(eml_subst(expr.left, replacement),
                      eml_subst(expr.right, replacement))
    elif isinstance(expr, EMLNeg):
        return EMLNeg(eml_subst(expr.child, replacement))
    elif isinstance(expr, EMLInv):
        return EMLInv(eml_subst(expr.child, replacement))
    elif isinstance(expr, EMLExp):
        return EMLExp(eml_subst(expr.child, replacement))
    elif isinstance(expr, EMLLog):
        return EMLLog(eml_subst(expr.child, replacement))
    raise TypeError(f"Unknown node type: {type(expr)}")


if __name__ == "__main__":
    # Quick test
    # exp(x) - log(x) is the EML function
    eml_expr = EMLAdd(EMLExp(EMLVar()), EMLNeg(EMLLog(EMLVar())))
    print(f"eml(2) = exp(2) - log(2) = {eml_eval(eml_expr, 2.0):.6f}")
    print(f"Expected: {np.exp(2) - np.log(2):.6f}")
    print(f"Depth: {eml_depth(eml_expr)}")

    d = eml_symb_deriv(eml_expr)
    print(f"Derivative depth: {eml_depth(d)}")
    print(f"Closure check: {eml_depth(d) <= eml_depth(eml_expr)}")

    # Airy equation analysis
    result = analyze_ode_depth(EMLConst(1), EMLConst(0), EMLNeg(EMLVar()))
    print(f"\nAiry equation depth analysis: {result}")
