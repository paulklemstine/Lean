#!/usr/bin/env python3
"""
Algorithms for Diophantine ReLU Approximation Theory

Type-hinted implementations of the key algorithms from the research.
"""

from typing import Callable, List, Tuple, Optional
from dataclasses import dataclass
import math


# ============================================================
# Algorithm 1: ReLU Expression Evaluator
# ============================================================

@dataclass
class ReLUExpr:
    """Abstract syntax tree for ReLU expressions."""
    kind: str  # 'const', 'var', 'relu', 'add', 'smul'
    value: Optional[float] = None  # for const and smul
    children: Optional[List['ReLUExpr']] = None

    @staticmethod
    def const(c: float) -> 'ReLUExpr':
        return ReLUExpr(kind='const', value=c)

    @staticmethod
    def var() -> 'ReLUExpr':
        return ReLUExpr(kind='var')

    @staticmethod
    def relu(e: 'ReLUExpr') -> 'ReLUExpr':
        return ReLUExpr(kind='relu', children=[e])

    @staticmethod
    def add(e1: 'ReLUExpr', e2: 'ReLUExpr') -> 'ReLUExpr':
        return ReLUExpr(kind='add', children=[e1, e2])

    @staticmethod
    def smul(c: float, e: 'ReLUExpr') -> 'ReLUExpr':
        return ReLUExpr(kind='smul', value=c, children=[e])

    def eval(self, x: float) -> float:
        """Evaluate the expression at input x."""
        if self.kind == 'const':
            return self.value
        elif self.kind == 'var':
            return x
        elif self.kind == 'relu':
            return max(0.0, self.children[0].eval(x))
        elif self.kind == 'add':
            return self.children[0].eval(x) + self.children[1].eval(x)
        elif self.kind == 'smul':
            return self.value * self.children[0].eval(x)
        raise ValueError(f"Unknown kind: {self.kind}")

    def relu_count(self) -> int:
        """Count the number of ReLU operations."""
        if self.kind == 'relu':
            return 1 + self.children[0].relu_count()
        elif self.kind in ('add',):
            return sum(c.relu_count() for c in self.children)
        elif self.kind == 'smul':
            return self.children[0].relu_count()
        return 0

    def param_count(self) -> int:
        """Count the number of parameters."""
        if self.kind == 'const':
            return 1
        elif self.kind == 'var':
            return 0
        elif self.kind == 'relu':
            return self.children[0].param_count()
        elif self.kind == 'add':
            return sum(c.param_count() for c in self.children)
        elif self.kind == 'smul':
            return 1 + self.children[0].param_count()
        return 0

    def depth(self) -> int:
        """Depth of the expression tree."""
        if self.kind in ('const', 'var'):
            return 0
        elif self.kind == 'relu':
            return 1 + self.children[0].depth()
        elif self.kind == 'add':
            return max(c.depth() for c in self.children)
        elif self.kind == 'smul':
            return self.children[0].depth()
        return 0

    def size(self) -> int:
        """Total AST size."""
        if self.kind in ('const', 'var'):
            return 1
        elif self.kind in ('relu', 'smul'):
            return 1 + self.children[0].size()
        elif self.kind == 'add':
            return 1 + sum(c.size() for c in self.children)
        return 1


# ============================================================
# Algorithm 2: Leibniz π Approximation via ReLU Expressions
# ============================================================

def build_leibniz_relu_expr(n: int) -> ReLUExpr:
    """
    Build a ReLU expression that computes 4 * Σ_{k=0}^{n-1} (-1)^k / (2k+1).

    This uses only constant nodes (no ReLU activations needed for constants),
    achieving O(1/n) approximation error for π.

    Pseudocode:
        1. Compute the Leibniz partial sum S_n = Σ (-1)^k/(2k+1)
        2. Return const(4 * S_n) as a ReLU expression
    """
    partial_sum = sum((-1)**k / (2*k + 1) for k in range(n))
    return ReLUExpr.const(4 * partial_sum)


def build_relu_pi_network(n: int) -> ReLUExpr:
    """
    Build a ReLU expression that constructs π approximation using
    the sum-of-terms architecture (demonstrating compositional structure).

    Each term (-1)^k/(2k+1) is represented as a const node,
    and they are summed using add nodes.

    Returns a tree with O(n) nodes, 0 ReLU activations, and
    approximation error ≤ 4/(2n+1).
    """
    if n == 0:
        return ReLUExpr.const(0.0)

    # Build term-by-term
    terms = [ReLUExpr.const(4 * (-1)**k / (2*k + 1)) for k in range(n)]

    # Build balanced binary tree of additions for depth O(log n)
    while len(terms) > 1:
        new_terms = []
        for i in range(0, len(terms) - 1, 2):
            new_terms.append(ReLUExpr.add(terms[i], terms[i+1]))
        if len(terms) % 2 == 1:
            new_terms.append(terms[-1])
        terms = new_terms

    return terms[0]


# ============================================================
# Algorithm 3: Diophantine Approximation Spectrum
# ============================================================

def diophantine_spectrum(alpha: float, D: int) -> Tuple[float, int, int]:
    """
    Compute the Diophantine approximation spectrum of alpha at denominator D.

    Returns (best_error, best_p, best_q) where p/q is the best rational
    approximation with 0 < q ≤ D.

    Pseudocode:
        1. For each q in {1, ..., D}:
            a. Find p = round(α * q)
            b. Compute err = |α - p/q|
        2. Return the (err, p, q) minimizing err
    """
    best_err = float('inf')
    best_p, best_q = 0, 1
    for q in range(1, D + 1):
        p = round(alpha * q)
        err = abs(alpha - p / q)
        if err < best_err:
            best_err = err
            best_p, best_q = p, q
    return best_err, best_p, best_q


def continued_fraction_convergents(alpha: float, max_terms: int = 20) -> List[Tuple[int, int]]:
    """
    Compute convergents of the continued fraction expansion of alpha.
    These give the best rational approximations in the sense of
    minimizing |α - p/q| * q.

    Pseudocode:
        1. Initialize h_{-1} = 1, h_0 = a_0, k_{-1} = 0, k_0 = 1
        2. For each continued fraction coefficient a_i:
            h_i = a_i * h_{i-1} + h_{i-2}
            k_i = a_i * k_{i-1} + k_{i-2}
        3. Return list of (h_i, k_i)
    """
    convergents = []
    x = alpha
    h_prev, h_curr = 1, int(x)
    k_prev, k_curr = 0, 1
    convergents.append((h_curr, k_curr))

    for _ in range(max_terms - 1):
        frac = x - int(x)
        if abs(frac) < 1e-12:
            break
        x = 1.0 / frac
        a = int(x)
        h_prev, h_curr = h_curr, a * h_curr + h_prev
        k_prev, k_curr = k_curr, a * k_curr + k_prev
        convergents.append((h_curr, k_curr))

    return convergents


# ============================================================
# Algorithm 4: Piece Count Analysis
# ============================================================

def max_pieces(n: int) -> int:
    """
    Maximum number of linear pieces for n ReLU operations.
    Satisfies the recurrence: maxPieces(0) = 1, maxPieces(n+1) = 2*maxPieces(n) + 1.
    Closed form: maxPieces(n) = 2^(n+1) - 1.
    """
    if n == 0:
        return 1
    return 2 * max_pieces(n - 1) + 1


def verify_piece_bound(n: int) -> bool:
    """Verify that 2^n ≤ maxPieces(n) ≤ 2^(n+1) - 1."""
    mp = max_pieces(n)
    return 2**n <= mp <= 2**(n+1) - 1


# ============================================================
# Main: Run all algorithms
# ============================================================

if __name__ == "__main__":
    # Test ReLU expression algebra
    print("Testing ReLU Expression Algebra...")
    e = build_leibniz_relu_expr(100)
    print(f"  Leibniz(100) at x=1: {e.eval(1):.15f}")
    print(f"  True π:              {math.pi:.15f}")
    print(f"  Error:               {abs(e.eval(1) - math.pi):.2e}")
    print(f"  ReLU count:          {e.relu_count()}")
    print(f"  Param count:         {e.param_count()}")

    # Test tree construction
    print("\nTesting Tree Construction...")
    tree = build_relu_pi_network(100)
    print(f"  Tree(100) at x=1:    {tree.eval(1):.15f}")
    print(f"  Error:               {abs(tree.eval(1) - math.pi):.2e}")
    print(f"  ReLU count:          {tree.relu_count()}")
    print(f"  Tree size:           {tree.size()}")
    print(f"  Tree depth:          {tree.depth()}")

    # Test continued fractions
    print("\nContinued Fraction Convergents of π:")
    for p, q in continued_fraction_convergents(math.pi, 10):
        print(f"  {p}/{q} = {p/q:.15f}, error = {abs(math.pi - p/q):.2e}")

    # Verify piece count bounds
    print("\nVerifying piece count bounds...")
    for n in range(15):
        assert verify_piece_bound(n), f"Failed at n={n}"
    print("  All bounds verified for n = 0..14")
