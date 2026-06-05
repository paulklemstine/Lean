#!/usr/bin/env python3
"""
EML Universal Approximation: Core Algorithms

Type-hinted implementations of the key algorithms from the EML density
and depth hierarchy theory.
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Callable, List, Optional, Tuple
from enum import Enum
import math


# ============================================================
# Algorithm 1: EML Tree Evaluation
# ============================================================

class EMLNodeType(Enum):
    VAR = "var"
    LIT = "lit"
    ADD = "add"
    MUL = "mul"
    NEG = "neg"
    EML = "eml"


@dataclass
class EMLTree:
    """An EML expression tree.
    
    Nodes are either:
    - var: the input variable
    - lit(c): a real constant c
    - add(left, right): sum
    - mul(left, right): product
    - neg(child): negation
    - eml(left, right): eml(a, b) = exp(a) - log(b)
    """
    node_type: EMLNodeType
    value: Optional[float] = None  # for LIT nodes
    left: Optional[EMLTree] = None
    right: Optional[EMLTree] = None

    def eval(self, x: float) -> float:
        """Evaluate the EML tree at input x."""
        if self.node_type == EMLNodeType.VAR:
            return x
        elif self.node_type == EMLNodeType.LIT:
            return self.value
        elif self.node_type == EMLNodeType.ADD:
            return self.left.eval(x) + self.right.eval(x)
        elif self.node_type == EMLNodeType.MUL:
            return self.left.eval(x) * self.right.eval(x)
        elif self.node_type == EMLNodeType.NEG:
            return -self.left.eval(x)
        elif self.node_type == EMLNodeType.EML:
            a = self.left.eval(x)
            b = self.right.eval(x)
            return math.exp(a) - math.log(b)
        raise ValueError(f"Unknown node type: {self.node_type}")

    def depth(self) -> int:
        """Compute the depth of the tree (max eml nesting)."""
        if self.node_type in (EMLNodeType.VAR, EMLNodeType.LIT):
            return 0
        elif self.node_type in (EMLNodeType.ADD, EMLNodeType.MUL):
            return max(self.left.depth(), self.right.depth())
        elif self.node_type == EMLNodeType.NEG:
            return self.left.depth()
        elif self.node_type == EMLNodeType.EML:
            return max(self.left.depth(), self.right.depth()) + 1
        return 0

    def size(self) -> int:
        """Compute the size (node count) of the tree."""
        if self.node_type in (EMLNodeType.VAR, EMLNodeType.LIT):
            return 1
        elif self.node_type == EMLNodeType.NEG:
            return 1 + self.left.size()
        else:
            return 1 + self.left.size() + self.right.size()

    def subst(self, inner: EMLTree) -> EMLTree:
        """Substitute `inner` for every var in this tree."""
        if self.node_type == EMLNodeType.VAR:
            return inner
        elif self.node_type == EMLNodeType.LIT:
            return self
        elif self.node_type == EMLNodeType.NEG:
            return EMLTree(EMLNodeType.NEG, left=self.left.subst(inner))
        else:
            return EMLTree(self.node_type, self.value,
                         self.left.subst(inner) if self.left else None,
                         self.right.subst(inner) if self.right else None)


# Convenience constructors
def var() -> EMLTree:
    return EMLTree(EMLNodeType.VAR)

def lit(c: float) -> EMLTree:
    return EMLTree(EMLNodeType.LIT, value=c)

def add(a: EMLTree, b: EMLTree) -> EMLTree:
    return EMLTree(EMLNodeType.ADD, left=a, right=b)

def mul(a: EMLTree, b: EMLTree) -> EMLTree:
    return EMLTree(EMLNodeType.MUL, left=a, right=b)

def neg(a: EMLTree) -> EMLTree:
    return EMLTree(EMLNodeType.NEG, left=a)

def eml_node(a: EMLTree, b: EMLTree) -> EMLTree:
    return EMLTree(EMLNodeType.EML, left=a, right=b)


# ============================================================
# Algorithm 2: Polynomial to EML Tree
# ============================================================

def polynomial_to_eml(coeffs: List[float]) -> EMLTree:
    """Convert polynomial coefficients [a0, a1, ..., an] to an EML tree.
    
    Represents a0 + a1*x + a2*x^2 + ... + an*x^n as a depth-0 EML tree.
    
    Pseudocode:
        result = lit(0)
        x_power = var()  # x^0 = 1 initially, but we handle specially
        for i, coeff in enumerate(coeffs):
            term = mul(lit(coeff), x_power_i)
            result = add(result, term)
        return result
    """
    if not coeffs:
        return lit(0.0)
    
    # Build x^i incrementally
    result: Optional[EMLTree] = None
    
    for i, c in enumerate(coeffs):
        if abs(c) < 1e-15:
            continue
        # Build x^i
        if i == 0:
            term = lit(c)
        else:
            x_power = var()
            for _ in range(i - 1):
                x_power = mul(x_power, var())
            term = mul(lit(c), x_power)
        
        if result is None:
            result = term
        else:
            result = add(result, term)
    
    return result if result is not None else lit(0.0)


# ============================================================
# Algorithm 3: Iterated Exponential EML Tree
# ============================================================

def iter_exp_tree(n: int) -> EMLTree:
    """Build the EML tree for iterExp(n, x) = exp^n(x).
    
    iterExp(0, x) = x              (tree: var)
    iterExp(n+1, x) = exp(iterExp(n, x))  (tree: eml_node(iterExp_n, lit(1)))
    
    The tree has depth n and size 2n+1.
    
    Pseudocode:
        tree = var()
        for i in range(n):
            tree = eml_node(tree, lit(1))  # exp(tree) - log(1) = exp(tree)
        return tree
    """
    tree = var()
    for _ in range(n):
        tree = eml_node(tree, lit(1.0))
    return tree


# ============================================================
# Algorithm 4: EML Approximation Spectrum Estimator
# ============================================================

def estimate_spectrum(
    f: Callable[[float], float],
    a: float,
    b: float,
    epsilon: float,
    max_degree: int = 200,
    num_eval_points: int = 500
) -> Tuple[int, List[float]]:
    """Estimate the EML Approximation Spectrum Ψ_f(ε).
    
    Returns the minimum polynomial degree (and hence tree size ≈ 2*degree+1)
    needed to approximate f on [a,b] to within epsilon.
    
    Uses Chebyshev interpolation for near-optimal polynomial approximation.
    
    Pseudocode:
        for degree = 1 to max_degree:
            nodes = chebyshev_nodes(degree+1, a, b)
            p = lagrange_interpolant(f, nodes)
            error = max_{x in [a,b]} |f(x) - p(x)|
            if error < epsilon:
                return 2*degree + 1, coefficients
        return -1 (not achievable within max_degree)
    """
    import numpy as np
    
    x_eval = np.linspace(a, b, num_eval_points)
    f_eval = np.array([f(xi) for xi in x_eval])
    
    for degree in range(1, max_degree + 1):
        # Chebyshev nodes
        k = np.arange(1, degree + 2)
        nodes = 0.5 * (a + b) + 0.5 * (b - a) * np.cos((2 * k - 1) * np.pi / (2 * (degree + 1)))
        values = np.array([f(xi) for xi in nodes])
        
        # Lagrange interpolation
        p_eval = np.zeros(num_eval_points)
        for i in range(len(nodes)):
            term = values[i] * np.ones(num_eval_points)
            for j in range(len(nodes)):
                if i != j:
                    term *= (x_eval - nodes[j]) / (nodes[i] - nodes[j])
            p_eval += term
        
        max_error = np.max(np.abs(f_eval - p_eval))
        if max_error < epsilon:
            return 2 * degree + 1, list(values)
    
    return -1, []


# ============================================================
# Algorithm 5: Depth Composition Bound Verifier
# ============================================================

def verify_depth_composition(
    outer: EMLTree,
    inner: EMLTree,
    test_points: List[float]
) -> Tuple[bool, int, int, int]:
    """Verify the depth composition bound: depth(outer.subst(inner)) ≤ depth(outer) + depth(inner).
    
    Also verifies the substitution-evaluation identity:
    (outer.subst(inner)).eval(x) = outer.eval(inner.eval(x))
    
    Returns:
        (composition_correct, composed_depth, outer_depth, inner_depth)
    """
    composed = outer.subst(inner)
    d_out = outer.depth()
    d_in = inner.depth()
    d_comp = composed.depth()
    
    depth_bound_holds = d_comp <= d_out + d_in
    
    eval_matches = True
    for x in test_points:
        try:
            v1 = composed.eval(x)
            v2 = outer.eval(inner.eval(x))
            if abs(v1 - v2) > 1e-10:
                eval_matches = False
        except (ValueError, OverflowError):
            pass  # skip ill-defined points
    
    return depth_bound_holds and eval_matches, d_comp, d_out, d_in


# ============================================================
# Main demo
# ============================================================

if __name__ == "__main__":
    print("EML Algorithms Demo")
    print("=" * 50)
    
    # Demo 1: Build and evaluate EML trees
    print("\n1. EML Tree for exp(x):")
    exp_tree = eml_node(var(), lit(1.0))
    print(f"   depth = {exp_tree.depth()}, size = {exp_tree.size()}")
    for x in [0.0, 0.5, 1.0, 2.0]:
        print(f"   eval({x}) = {exp_tree.eval(x):.6f} vs exp({x}) = {math.exp(x):.6f}")
    
    # Demo 2: Iterated exponential
    print("\n2. Iterated exponential trees:")
    for n in range(4):
        tree = iter_exp_tree(n)
        print(f"   iterExp({n}): depth={tree.depth()}, size={tree.size()}, eval(1.0)={tree.eval(1.0):.6f}")
    
    # Demo 3: Depth composition
    print("\n3. Depth composition verification:")
    t1 = eml_node(var(), lit(1.0))  # exp(x), depth 1
    t2 = eml_node(var(), lit(1.0))  # exp(x), depth 1
    ok, d_comp, d_out, d_in = verify_depth_composition(t1, t2, [0.0, 0.5, 1.0])
    print(f"   exp(exp(x)): composed depth={d_comp}, bound={d_out}+{d_in}={d_out+d_in}, valid={ok}")
    
    # Demo 4: Polynomial to EML
    print("\n4. Polynomial to EML tree (1 + 2x + 3x²):")
    p_tree = polynomial_to_eml([1.0, 2.0, 3.0])
    print(f"   depth = {p_tree.depth()}, size = {p_tree.size()}")
    for x in [0.0, 0.5, 1.0]:
        expected = 1.0 + 2.0 * x + 3.0 * x ** 2
        print(f"   eval({x}) = {p_tree.eval(x):.6f} vs expected = {expected:.6f}")
    
    # Demo 5: Spectrum estimation
    print("\n5. Approximation spectrum for sin(2πx):")
    import numpy as np
    f = lambda x: np.sin(2 * np.pi * x)
    for eps in [1e-2, 1e-4, 1e-6, 1e-8]:
        size, _ = estimate_spectrum(f, 0.0, 1.0, eps)
        print(f"   ε = {eps:.0e}: Ψ = {size}")
