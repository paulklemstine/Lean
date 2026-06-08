#!/usr/bin/env python3
"""
EML Differential Equations: Algorithms

Type-hinted implementations of:
1. Wronskian computation
2. Abel's identity verification
3. Riccati reduction
4. Kovacic Case 1 polynomial check
5. EML tower height computation
"""

from typing import Callable, Optional, Tuple, List
from dataclasses import dataclass
import numpy as np


# Type aliases
RealFunc = Callable[[float], float]


@dataclass
class Polynomial:
    """A polynomial represented by its coefficients [a0, a1, a2, ...].
    p(x) = a0 + a1*x + a2*x^2 + ...
    """
    coeffs: List[float]
    
    @property
    def degree(self) -> int:
        """Return the degree of the polynomial."""
        for i in range(len(self.coeffs) - 1, -1, -1):
            if abs(self.coeffs[i]) > 1e-12:
                return i
        return -1  # zero polynomial
    
    def eval(self, x: float) -> float:
        """Evaluate polynomial at x."""
        return sum(c * x**i for i, c in enumerate(self.coeffs))
    
    def derivative(self) -> 'Polynomial':
        """Return the derivative polynomial."""
        if len(self.coeffs) <= 1:
            return Polynomial([0.0])
        return Polynomial([i * c for i, c in enumerate(self.coeffs) if i > 0])
    
    def __mul__(self, other: 'Polynomial') -> 'Polynomial':
        """Multiply two polynomials."""
        n = len(self.coeffs) + len(other.coeffs) - 1
        result = [0.0] * n
        for i, a in enumerate(self.coeffs):
            for j, b in enumerate(other.coeffs):
                result[i + j] += a * b
        return Polynomial(result)
    
    def __add__(self, other: 'Polynomial') -> 'Polynomial':
        """Add two polynomials."""
        n = max(len(self.coeffs), len(other.coeffs))
        result = [0.0] * n
        for i, c in enumerate(self.coeffs):
            result[i] += c
        for i, c in enumerate(other.coeffs):
            result[i] += c
        return Polynomial(result)
    
    def __repr__(self) -> str:
        terms = []
        for i, c in enumerate(self.coeffs):
            if abs(c) < 1e-12:
                continue
            if i == 0:
                terms.append(f"{c:.4g}")
            elif i == 1:
                terms.append(f"{c:.4g}·x")
            else:
                terms.append(f"{c:.4g}·x^{i}")
        return " + ".join(terms) if terms else "0"


def wronskian(f1: RealFunc, f2: RealFunc, x: float, h: float = 1e-7) -> float:
    """Compute the Wronskian W(f1, f2)(x) = f1(x)·f2'(x) - f2(x)·f1'(x).
    
    Uses central difference for numerical derivatives.
    
    Args:
        f1: First function
        f2: Second function
        x: Point of evaluation
        h: Step size for numerical differentiation
    
    Returns:
        The Wronskian value at x
    """
    f1_val = f1(x)
    f2_val = f2(x)
    f1_deriv = (f1(x + h) - f1(x - h)) / (2 * h)
    f2_deriv = (f2(x + h) - f2(x - h)) / (2 * h)
    return f1_val * f2_deriv - f2_val * f1_deriv


def verify_abel_identity(
    f1: RealFunc, f2: RealFunc, p: RealFunc,
    x_range: Tuple[float, float], n_points: int = 100
) -> Tuple[bool, float]:
    """Verify Abel's identity: W' = -p·W for two solutions.
    
    Args:
        f1, f2: Two solutions of y'' + p·y' + q·y = 0
        p: The coefficient function
        x_range: Interval (a, b) to check
        n_points: Number of test points
    
    Returns:
        (passes, max_error): Whether the identity holds within tolerance
    """
    h = 1e-6
    xs = np.linspace(x_range[0], x_range[1], n_points)
    max_error = 0.0
    
    for x in xs:
        W = wronskian(f1, f2, x)
        W_prime = (wronskian(f1, f2, x + h) - wronskian(f1, f2, x - h)) / (2 * h)
        abel_rhs = -p(x) * W
        error = abs(W_prime - abel_rhs)
        max_error = max(max_error, error)
    
    return max_error < 1e-4, max_error


def riccati_substitution(f: RealFunc, x: float, h: float = 1e-7) -> float:
    """Compute the Riccati substitution w = f'/f.
    
    Args:
        f: A nonzero solution of y'' = r·y
        x: Point of evaluation
        h: Step size for numerical differentiation
    
    Returns:
        w(x) = f'(x)/f(x)
    """
    f_val = f(x)
    if abs(f_val) < 1e-15:
        raise ValueError(f"f({x}) ≈ 0, Riccati substitution undefined")
    f_deriv = (f(x + h) - f(x - h)) / (2 * h)
    return f_deriv / f_val


def verify_riccati(
    w: RealFunc, r: RealFunc,
    x_range: Tuple[float, float], n_points: int = 100
) -> Tuple[bool, float]:
    """Verify the Riccati equation w' + w² = r.
    
    Args:
        w: Candidate solution of the Riccati equation
        r: Right-hand side function
        x_range: Interval to check
        n_points: Number of test points
    
    Returns:
        (passes, max_error)
    """
    h = 1e-6
    xs = np.linspace(x_range[0], x_range[1], n_points)
    max_error = 0.0
    
    for x in xs:
        w_val = w(x)
        w_prime = (w(x + h) - w(x - h)) / (2 * h)
        lhs = w_prime + w_val**2
        rhs = r(x)
        error = abs(lhs - rhs)
        max_error = max(max_error, error)
    
    return max_error < 1e-4, max_error


def kovacic_case1_poly_check(r: Polynomial) -> Optional[Polynomial]:
    """Kovacic Algorithm Case 1: Check if the Riccati equation w' + w² = r(x)
    has a polynomial solution.
    
    For r(x) of degree d:
    - If d is odd, no polynomial solution exists (degree parity obstruction)
    - If d is even, the candidate has degree d/2
    
    Args:
        r: The polynomial r(x) in y'' = r(x)·y
    
    Returns:
        A polynomial solution w, or None if no polynomial solution exists
    """
    d = r.degree
    
    # Degree parity obstruction
    if d % 2 == 1:
        return None  # deg(w²) = 2·deg(w) is even, can't equal odd d
    
    # For even degree d, candidate w has degree d/2
    target_degree = d // 2
    
    # Try to solve by matching coefficients
    # w' + w² = r means we need w of degree target_degree
    # This is a system of nonlinear equations in the coefficients
    
    # For d = 0 (constant): w' + w² = c => w² = c => w = ±√c if c ≥ 0
    if d == 0:
        c = r.coeffs[0]
        if c >= 0:
            w = Polynomial([c**0.5])
            # Verify: w' + w² = 0 + c = c ✓
            return w
        return None
    
    # For d = 2: w = ax + b, w' + w² = a + a²x² + 2abx + b² = cx² + dx + e
    if d == 2:
        c2 = r.coeffs[2] if len(r.coeffs) > 2 else 0
        c1 = r.coeffs[1] if len(r.coeffs) > 1 else 0
        c0 = r.coeffs[0]
        
        # a² = c2 => a = ±√c2
        if c2 < 0:
            return None
        a = c2**0.5
        if abs(a) < 1e-12:
            return None
        
        # 2ab = c1 => b = c1/(2a)
        b = c1 / (2 * a)
        
        # a + b² = c0 => check
        if abs(a + b**2 - c0) < 1e-10:
            return Polynomial([b, a])
        
        # Try a = -√c2
        a = -(c2**0.5)
        b = c1 / (2 * a)
        if abs(a + b**2 - c0) < 1e-10:
            return Polynomial([b, a])
        
        return None
    
    # General case: system of nonlinear equations (not implemented)
    return None


@dataclass
class EMLExpr:
    """An EML expression tree.
    
    Represents expressions built from polynomials using exp and log.
    """
    kind: str  # 'const', 'var', 'exp', 'log', 'add', 'mul', 'poly'
    children: List['EMLExpr']
    value: Optional[float] = None
    
    def tower_height(self) -> int:
        """Compute the EML tower height.
        
        - Polynomials have height 0
        - exp(e) and log(e) have height h(e) + 1
        - Sum and product preserve the max height
        """
        if self.kind in ('const', 'var', 'poly'):
            return 0
        elif self.kind == 'exp':
            return self.children[0].tower_height() + 1
        elif self.kind == 'log':
            return self.children[0].tower_height() + 1
        elif self.kind in ('add', 'mul'):
            return max(c.tower_height() for c in self.children)
        return 0
    
    def eval(self, x: float) -> float:
        """Evaluate the expression at x."""
        if self.kind == 'const':
            return self.value or 0.0
        elif self.kind == 'var':
            return x
        elif self.kind == 'exp':
            return np.exp(self.children[0].eval(x))
        elif self.kind == 'log':
            val = self.children[0].eval(x)
            return np.log(abs(val)) if val != 0 else float('-inf')
        elif self.kind == 'add':
            return sum(c.eval(x) for c in self.children)
        elif self.kind == 'mul':
            result = 1.0
            for c in self.children:
                result *= c.eval(x)
            return result
        return 0.0
    
    def __repr__(self) -> str:
        if self.kind == 'const':
            return f"{self.value}"
        elif self.kind == 'var':
            return "x"
        elif self.kind == 'exp':
            return f"exp({self.children[0]})"
        elif self.kind == 'log':
            return f"log({self.children[0]})"
        elif self.kind == 'add':
            return " + ".join(str(c) for c in self.children)
        elif self.kind == 'mul':
            return " · ".join(str(c) for c in self.children)
        return "?"


def growth_order(expr: EMLExpr) -> Optional[float]:
    """Compute the growth order of an EML expression.
    
    growth_order(polynomial) = degree (a non-negative integer)
    growth_order(exp(p)) = ∞ (faster than any polynomial)
    growth_order(log(p)) = 0
    
    Returns None for ∞.
    """
    if expr.kind in ('const',):
        return 0
    elif expr.kind == 'var':
        return 1
    elif expr.kind == 'exp':
        return None  # ∞
    elif expr.kind == 'log':
        return 0
    elif expr.kind in ('add', 'mul'):
        orders = [growth_order(c) for c in expr.children]
        if any(o is None for o in orders):
            return None
        return max(o for o in orders if o is not None)
    return 0


def airy_growth_order() -> float:
    """The Airy function Bi(x) has growth order 3/2.
    
    Since 3/2 is not a natural number, Bi(x) cannot be EML.
    
    Returns:
        1.5 (the growth order of Bi(x))
    """
    return 1.5  # Bi(x) ~ exp(2x^(3/2)/3)


if __name__ == "__main__":
    # Demo: Verify Abel's identity for y'' + y = 0
    import math
    
    passes, err = verify_abel_identity(
        math.cos, math.sin, lambda x: 0.0, (0, 6*math.pi)
    )
    print(f"Abel's identity for y''+y=0: {'PASS' if passes else 'FAIL'} (err={err:.2e})")
    
    # Demo: Riccati for y'' = y, w = 1
    passes, err = verify_riccati(
        lambda x: 1.0, lambda x: 1.0, (0, 5)
    )
    print(f"Riccati w=1 for y''=y: {'PASS' if passes else 'FAIL'} (err={err:.2e})")
    
    # Demo: Kovacic Case 1 for r(x) = 1
    result = kovacic_case1_poly_check(Polynomial([1.0]))
    print(f"Kovacic Case 1 for r(x)=1: w = {result}")
    
    # Demo: Kovacic Case 1 for r(x) = x (Airy)
    result = kovacic_case1_poly_check(Polynomial([0.0, 1.0]))
    print(f"Kovacic Case 1 for r(x)=x (Airy): w = {result}")
    print("  (None confirms polynomial obstruction)")
    
    # Demo: EML tower heights
    var = EMLExpr('var', [])
    exp_x = EMLExpr('exp', [var])
    log_x = EMLExpr('log', [var])
    eml_expr = EMLExpr('add', [exp_x, EMLExpr('mul', [EMLExpr('const', [], -1), log_x])])
    exp_exp = EMLExpr('exp', [exp_x])
    
    print(f"\nTower heights:")
    print(f"  x: {var.tower_height()}")
    print(f"  exp(x): {exp_x.tower_height()}")
    print(f"  log(x): {log_x.tower_height()}")
    print(f"  exp(x) - log(x): {eml_expr.tower_height()}")
    print(f"  exp(exp(x)): {exp_exp.tower_height()}")
    print(f"\nAiry growth order: {airy_growth_order()} (not integer => not EML)")
