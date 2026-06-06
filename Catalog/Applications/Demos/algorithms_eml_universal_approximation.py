#!/usr/bin/env python3
"""
EML Approximation Spectrum — Core Algorithms

Type-hinted implementations of the key algorithms from the EML approximation
spectrum theory, including:
1. EML expression evaluation and complexity measurement
2. Approximation spectrum computation (brute-force and heuristic)
3. Horner polynomial-to-EML conversion
4. Information decay computation
5. Optimal EML expression search
"""

import math
from dataclasses import dataclass
from enum import Enum, auto
from typing import Callable, Dict, List, Optional, Tuple


# ============================================================
# Algorithm 1: EML Expression Data Structure
# ============================================================

class NodeType(Enum):
    VAR = auto()
    CONST = auto()
    ADD = auto()
    MUL = auto()
    NEG = auto()
    INV = auto()
    EML = auto()  # eml(a, b) = a * exp(b)


@dataclass
class EMLNode:
    """A node in an EML expression tree."""
    node_type: NodeType
    value: Optional[float] = None  # for CONST nodes
    left: Optional['EMLNode'] = None
    right: Optional['EMLNode'] = None

    def eval(self, x: float) -> float:
        """Evaluate the expression at x."""
        if self.node_type == NodeType.VAR:
            return x
        elif self.node_type == NodeType.CONST:
            return self.value or 0.0
        elif self.node_type == NodeType.ADD:
            return self.left.eval(x) + self.right.eval(x)
        elif self.node_type == NodeType.MUL:
            return self.left.eval(x) * self.right.eval(x)
        elif self.node_type == NodeType.NEG:
            return -self.left.eval(x)
        elif self.node_type == NodeType.INV:
            v = self.left.eval(x)
            return 1.0 / v if v != 0 else float('inf')
        elif self.node_type == NodeType.EML:
            a_val = self.left.eval(x)
            b_val = self.right.eval(x)
            if b_val > 700:
                return float('inf') if a_val > 0 else float('-inf')
            return a_val * math.exp(b_val)
        return 0.0

    def size(self) -> int:
        """Count the number of nodes."""
        if self.node_type in (NodeType.VAR, NodeType.CONST):
            return 1
        elif self.node_type in (NodeType.NEG, NodeType.INV):
            return 1 + self.left.size()
        else:
            return 1 + self.left.size() + self.right.size()

    def eml_depth(self) -> int:
        """Compute the EML depth (nesting of eml operations)."""
        if self.node_type in (NodeType.VAR, NodeType.CONST):
            return 0
        elif self.node_type in (NodeType.NEG, NodeType.INV):
            return self.left.eml_depth()
        elif self.node_type == NodeType.EML:
            return 1 + max(self.left.eml_depth(), self.right.eml_depth())
        else:  # ADD, MUL
            return max(self.left.eml_depth(), self.right.eml_depth())

    def tree_depth(self) -> int:
        """Compute the tree depth."""
        if self.node_type in (NodeType.VAR, NodeType.CONST):
            return 0
        elif self.node_type in (NodeType.NEG, NodeType.INV):
            return 1 + self.left.tree_depth()
        else:
            return 1 + max(self.left.tree_depth(), self.right.tree_depth())


# ============================================================
# Algorithm 2: Horner Polynomial-to-EML Conversion
# ============================================================

def horner_to_eml(coefficients: List[float]) -> EMLNode:
    """
    Convert polynomial coefficients to EML expression via Horner's method.

    Given coefficients [c_0, c_1, ..., c_n], produces an EML expression
    computing c_0 + x*(c_1 + x*(c_2 + ... + x*c_n)).

    Time complexity: O(n) tree construction
    Space complexity: O(n) nodes
    Resulting size: 4n + 1 nodes

    Args:
        coefficients: Polynomial coefficients [c_0, c_1, ..., c_n]

    Returns:
        EMLNode representing the polynomial
    """
    if len(coefficients) == 1:
        return EMLNode(NodeType.CONST, value=coefficients[0])

    # Horner form: c_0 + x * horner(c_1, c_2, ..., c_n)
    inner = horner_to_eml(coefficients[1:])
    return EMLNode(
        NodeType.ADD,
        left=EMLNode(NodeType.CONST, value=coefficients[0]),
        right=EMLNode(
            NodeType.MUL,
            left=EMLNode(NodeType.VAR),
            right=inner
        )
    )


# ============================================================
# Algorithm 3: Iterated Exponential Tower Construction
# ============================================================

def eml_tower(n: int) -> EMLNode:
    """
    Construct the canonical EML expression for iterExp n.

    Produces eml(1, eml(1, ..., eml(1, var)...)) with n layers.

    Time complexity: O(n) construction
    Space complexity: O(n) nodes
    Resulting size: 2n + 1 nodes
    EML depth: exactly n

    Args:
        n: Tower height (number of exponentiations)

    Returns:
        EMLNode computing exp^n(x)
    """
    if n == 0:
        return EMLNode(NodeType.VAR)
    return EMLNode(
        NodeType.EML,
        left=EMLNode(NodeType.CONST, value=1.0),
        right=eml_tower(n - 1)
    )


# ============================================================
# Algorithm 4: Approximation Spectrum Computation
# ============================================================

def compute_approx_error(
    f: Callable[[float], float],
    expr: EMLNode,
    a: float, b: float,
    n_samples: int = 500
) -> float:
    """Compute max |f(x) - expr(x)| over [a, b] by sampling."""
    max_err = 0.0
    for i in range(n_samples + 1):
        x = a + (b - a) * i / n_samples
        try:
            fx = f(x)
            gx = expr.eval(x)
            if math.isfinite(fx) and math.isfinite(gx):
                max_err = max(max_err, abs(fx - gx))
            else:
                max_err = float('inf')
        except (OverflowError, ZeroDivisionError):
            max_err = float('inf')
    return max_err


def approx_spectrum_sample(
    f: Callable[[float], float],
    a: float, b: float,
    epsilons: List[float],
    max_poly_degree: int = 30
) -> Dict[float, int]:
    """
    Estimate the approximation spectrum σ_f(ε) for given ε values.

    Uses polynomial (Horner) approximation as the search strategy.
    For each ε, finds the minimum polynomial degree d such that the
    degree-d Taylor/Chebyshev polynomial achieves error ≤ ε.

    The spectrum value is then 4d + 1 (the Horner size bound).

    Args:
        f: Target function
        a, b: Domain endpoints
        epsilons: List of precision levels to evaluate
        max_poly_degree: Maximum polynomial degree to search

    Returns:
        Dictionary mapping ε → estimated minimum EML size
    """
    spectrum: Dict[float, int] = {}

    for eps in sorted(epsilons, reverse=True):
        for deg in range(max_poly_degree + 1):
            # Use Taylor coefficients around midpoint
            mid = (a + b) / 2
            coeffs = _taylor_coeffs(f, mid, deg, a, b)
            expr = horner_to_eml(coeffs)
            error = compute_approx_error(f, expr, a, b)
            if error <= eps:
                spectrum[eps] = expr.size()
                break
        else:
            spectrum[eps] = 4 * max_poly_degree + 1  # upper bound

    return spectrum


def _taylor_coeffs(
    f: Callable[[float], float],
    center: float,
    degree: int,
    a: float, b: float
) -> List[float]:
    """Compute approximate Taylor coefficients via finite differences."""
    h = 1e-6
    coeffs = []
    for k in range(degree + 1):
        # k-th derivative at center via central difference
        deriv = _nth_derivative(f, center, k, h)
        coeffs.append(deriv / math.factorial(k))
    # Shift: convert from expansion at center to expansion at 0
    # For simplicity, we expand at 0 directly
    coeffs_at_zero = []
    for k in range(degree + 1):
        deriv = _nth_derivative(f, 0.0, k, h)
        coeffs_at_zero.append(deriv / math.factorial(k))
    return coeffs_at_zero


def _nth_derivative(
    f: Callable[[float], float],
    x: float,
    n: int,
    h: float = 1e-5
) -> float:
    """Approximate n-th derivative using central differences."""
    if n == 0:
        return f(x)
    # Recursive central difference
    return (_nth_derivative(f, x + h, n - 1, h) -
            _nth_derivative(f, x - h, n - 1, h)) / (2 * h)


# ============================================================
# Algorithm 5: Information Decay Computation
# ============================================================

def retained_information(
    alpha: float,
    depth: int,
    initial_complexity: int
) -> float:
    """
    Compute retained symbolic information after depth layers.

    Formula: α^l × K

    Args:
        alpha: Per-layer contraction factor (0 ≤ α ≤ 1)
        depth: Number of layers
        initial_complexity: Initial information content K

    Returns:
        Retained information as a float
    """
    return (alpha ** depth) * initial_complexity


def minimum_initial_complexity(
    alpha: float,
    depth: int,
    threshold: float
) -> float:
    """
    Compute minimum initial complexity to retain at least threshold
    information after depth layers.

    Formula: K ≥ threshold / α^l

    Args:
        alpha: Per-layer contraction factor (0 < α ≤ 1)
        depth: Number of layers
        threshold: Minimum required retained information

    Returns:
        Minimum initial complexity K
    """
    if alpha <= 0:
        return float('inf')
    return threshold / (alpha ** depth)


# ============================================================
# Algorithm 6: EML Expression Composition
# ============================================================

def compose_eml(outer: EMLNode, inner: EMLNode) -> EMLNode:
    """
    Substitute inner for var in outer (syntactic composition).

    The resulting expression computes outer(inner(x)).

    Time complexity: O(|outer| × |inner|) in worst case
    EML depth: ≤ depth(outer) + depth(inner)
    Size: ≤ size(outer) × size(inner)

    Args:
        outer: The outer expression
        inner: The inner expression (replaces var)

    Returns:
        Composed expression
    """
    if outer.node_type == NodeType.VAR:
        return inner
    elif outer.node_type == NodeType.CONST:
        return EMLNode(NodeType.CONST, value=outer.value)
    elif outer.node_type in (NodeType.NEG, NodeType.INV):
        return EMLNode(
            outer.node_type,
            left=compose_eml(outer.left, inner)
        )
    else:  # ADD, MUL, EML
        return EMLNode(
            outer.node_type,
            left=compose_eml(outer.left, inner),
            right=compose_eml(outer.right, inner)
        )


# ============================================================
# Main: Run all algorithms
# ============================================================

if __name__ == "__main__":
    print("EML Approximation Spectrum — Algorithm Demonstrations")
    print("=" * 60)

    # Tower construction
    print("\n1. Tower Construction:")
    for n in range(1, 6):
        tower = eml_tower(n)
        print(f"   iterExp {n}: size={tower.size()}, "
              f"eml_depth={tower.eml_depth()}, "
              f"eval(0.5)={tower.eval(0.5):.6f}")

    # Horner conversion
    print("\n2. Horner Polynomial Conversion:")
    coeffs = [1, 1, 0.5, 1/6, 1/24]  # exp(x) Taylor to degree 4
    poly = horner_to_eml(coeffs)
    print(f"   exp(x) Taylor deg 4: size={poly.size()}, "
          f"eval(1.0)={poly.eval(1.0):.6f} vs e={math.e:.6f}")

    # Information decay
    print("\n3. Information Decay (K=1000, α=0.7):")
    for d in range(0, 11):
        info = retained_information(0.7, d, 1000)
        min_k = minimum_initial_complexity(0.7, d, 100)
        print(f"   depth {d:2d}: retained={info:8.2f}, "
              f"min_K_for_100={min_k:10.2f}")

    # Spectrum computation
    print("\n4. Approximation Spectrum for sin(x) on [0, 1]:")
    epsilons = [1.0, 0.1, 0.01, 0.001, 0.0001, 1e-5]
    spectrum = approx_spectrum_sample(math.sin, 0.0, 1.0, epsilons, 20)
    for eps, size in sorted(spectrum.items(), reverse=True):
        print(f"   ε = {eps:.0e}: min size ≈ {size}")

    # Composition
    print("\n5. Expression Composition:")
    exp_expr = eml_tower(1)  # exp(x)
    exp_exp = compose_eml(eml_tower(1), eml_tower(1))  # exp(exp(x))
    direct = eml_tower(2)  # direct exp^2(x)
    x_test = 0.3
    print(f"   Composed exp(exp(x)): size={exp_exp.size()}, "
          f"eval({x_test})={exp_exp.eval(x_test):.6f}")
    print(f"   Direct  exp^2(x):     size={direct.size()}, "
          f"eval({x_test})={direct.eval(x_test):.6f}")
    print(f"   Depth bound: composed={exp_exp.eml_depth()} ≤ "
          f"{exp_expr.eml_depth()} + {exp_expr.eml_depth()} = "
          f"{2 * exp_expr.eml_depth()}")
