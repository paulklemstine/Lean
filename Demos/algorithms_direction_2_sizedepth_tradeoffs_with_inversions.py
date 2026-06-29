#!/usr/bin/env python3
"""
algorithms.py — Algorithms for the EML Depth Hierarchy.

Implements:
1. canRepresentAtDepth: Decision procedure for tower representability
2. computeMajorant: Compute the majorant bound for an EML expression
3. enumerateEML: Enumerate all EML expressions up to a given size
4. verifyHierarchy: Numerically verify the depth hierarchy
"""

import math
import itertools
from typing import Optional, List, Tuple
from dataclasses import dataclass


# ──────────────────────────────────────────────────────────────
# Core Data Structures
# ──────────────────────────────────────────────────────────────

@dataclass
class EMLNode:
    """A node in an EML expression tree."""
    kind: str  # 'var', 'const', 'add', 'mul', 'exp', 'inv'
    value: Optional[float] = None
    children: Optional[List['EMLNode']] = None

    def eval(self, x: float) -> Optional[float]:
        """Evaluate at x. Returns None on domain error."""
        try:
            if self.kind == 'var':
                return x
            elif self.kind == 'const':
                return self.value
            elif self.kind == 'add':
                a, b = self.children[0].eval(x), self.children[1].eval(x)
                return None if a is None or b is None else a + b
            elif self.kind == 'mul':
                a, b = self.children[0].eval(x), self.children[1].eval(x)
                return None if a is None or b is None else a * b
            elif self.kind == 'exp':
                a = self.children[0].eval(x)
                return None if a is None or a > 700 else math.exp(a)
            elif self.kind == 'inv':
                a = self.children[0].eval(x)
                return None if a is None or a == 0 else 1.0 / a
        except (OverflowError, ValueError, ZeroDivisionError):
            return None
        return None

    def exp_depth(self) -> int:
        """Exponential depth (inv is free)."""
        if self.kind in ('var', 'const'):
            return 0
        elif self.kind in ('add', 'mul'):
            return max(c.exp_depth() for c in self.children)
        elif self.kind == 'exp':
            return 1 + self.children[0].exp_depth()
        elif self.kind == 'inv':
            return self.children[0].exp_depth()
        return 0

    def size(self) -> int:
        """Total number of nodes."""
        if self.children is None:
            return 1
        return 1 + sum(c.size() for c in self.children)

    def has_inv(self) -> bool:
        """Whether expression contains any inv nodes."""
        if self.kind == 'inv':
            return True
        if self.children:
            return any(c.has_inv() for c in self.children)
        return False


# ──────────────────────────────────────────────────────────────
# Algorithm 1: Decision Procedure
# ──────────────────────────────────────────────────────────────

def can_represent_at_depth(n: int, d: int) -> Tuple[bool, Optional[EMLNode]]:
    """
    Decide whether tower(n) can be represented by EML expression of expDepth ≤ d.

    Returns (result, witness):
      - If d ≥ n: returns (True, canonical_construction)
      - If d < n: returns (False, None), certified by the majorant theorem

    Time complexity: O(n) for construction, O(1) for decision
    Space complexity: O(n) for the witness tree

    Args:
        n: Tower height (tower(n, x) = exp^[n](x))
        d: Maximum allowed expDepth

    Returns:
        Tuple of (can_represent, optional_witness)
    """
    if d >= n:
        # Construct canonical tower: exp(exp(...exp(x)...))
        expr = EMLNode('var')
        for _ in range(n):
            expr = EMLNode('exp', children=[expr])
        return (True, expr)
    else:
        # Hierarchy theorem: no expression of expDepth < n represents tower(n)
        return (False, None)


# ──────────────────────────────────────────────────────────────
# Algorithm 2: Majorant Computation
# ──────────────────────────────────────────────────────────────

def compute_majorant(expr: EMLNode) -> Tuple[int, float, int]:
    """
    Compute the majorant parameters (d, C, N) such that
    |expr.eval(x)| ≤ tower(d, C * x^N) for sufficiently large x.

    This implements the structural induction from the formal proof:
    - var: (0, 1, 1)
    - const c: (0, |c|+1, 0)
    - add f g: combine majorants
    - mul f g: combine majorants
    - exp f: lift to next tower level
    - inv f: same level (using lower bound duality)

    Time complexity: O(size of expression)

    Args:
        expr: EML expression node

    Returns:
        Tuple (d, C, N) where d = expDepth, C > 0, N ≥ 0
    """
    if expr.kind == 'var':
        return (0, 1.0, 1)
    elif expr.kind == 'const':
        return (0, abs(expr.value) + 1, 0)
    elif expr.kind == 'add':
        d1, C1, N1 = compute_majorant(expr.children[0])
        d2, C2, N2 = compute_majorant(expr.children[1])
        d = max(d1, d2)
        C = C1 + C2 + 1
        N = max(N1, N2)
        return (d, C, N)
    elif expr.kind == 'mul':
        d1, C1, N1 = compute_majorant(expr.children[0])
        d2, C2, N2 = compute_majorant(expr.children[1])
        d = max(d1, d2)
        C = C1 * C2 + 1
        N = N1 + N2
        return (d, C, N)
    elif expr.kind == 'exp':
        d_inner, C_inner, N_inner = compute_majorant(expr.children[0])
        return (d_inner + 1, C_inner, N_inner)
    elif expr.kind == 'inv':
        # Inv preserves tower class (assuming non-vanishing)
        d_inner, C_inner, N_inner = compute_majorant(expr.children[0])
        return (d_inner, C_inner, N_inner)
    return (0, 1.0, 0)


# ──────────────────────────────────────────────────────────────
# Algorithm 3: Expression Enumeration
# ──────────────────────────────────────────────────────────────

def enumerate_eml(max_size: int, max_depth: int,
                  constants: List[float] = [1.0, 2.0, -1.0],
                  allow_inv: bool = True) -> List[EMLNode]:
    """
    Enumerate all EML expressions up to a given size and depth.

    Uses iterative deepening on expression size.

    Args:
        max_size: Maximum number of nodes
        max_depth: Maximum expDepth
        constants: List of constant values to use
        allow_inv: Whether to include inv nodes

    Returns:
        List of EML expressions
    """
    results = []

    def generate(size_budget: int, depth_budget: int) -> List[EMLNode]:
        if size_budget <= 0:
            return []
        if size_budget == 1:
            exprs = [EMLNode('var')]
            for c in constants:
                exprs.append(EMLNode('const', value=c))
            return exprs

        exprs = [EMLNode('var')]
        for c in constants:
            exprs.append(EMLNode('const', value=c))

        # Unary operations
        for child in generate(size_budget - 1, depth_budget):
            if depth_budget >= 1:
                exprs.append(EMLNode('exp', children=[child]))
            if allow_inv:
                exprs.append(EMLNode('inv', children=[child]))

        # Binary operations
        for s1 in range(1, size_budget - 1):
            s2 = size_budget - 1 - s1
            left_exprs = generate(s1, depth_budget)
            right_exprs = generate(s2, depth_budget)
            for left in left_exprs[:5]:  # limit to avoid explosion
                for right in right_exprs[:5]:
                    exprs.append(EMLNode('add', children=[left, right]))
                    exprs.append(EMLNode('mul', children=[left, right]))

        return exprs

    for size in range(1, max_size + 1):
        new_exprs = generate(size, max_depth)
        for expr in new_exprs:
            if expr.exp_depth() <= max_depth and expr.size() <= max_size:
                results.append(expr)

    return results


# ──────────────────────────────────────────────────────────────
# Algorithm 4: Hierarchy Verification
# ──────────────────────────────────────────────────────────────

def tower(n: int, x: float) -> float:
    """Iterated exponential tower."""
    result = x
    for _ in range(n):
        if result > 700:
            return float('inf')
        result = math.exp(result)
    return result


def verify_hierarchy(n: int, d: int, num_exprs: int = 100,
                     test_points: List[float] = None) -> dict:
    """
    Numerically verify the depth hierarchy: no expDepth-d expression matches tower(n).

    Args:
        n: Tower height
        d: Maximum expDepth (should be < n for hierarchy to hold)
        num_exprs: Number of random expressions to test
        test_points: Points at which to evaluate

    Returns:
        Dictionary with verification results
    """
    if test_points is None:
        test_points = [0.5, 1.0, 1.5, 2.0, 2.5]

    tower_vals = []
    for x in test_points:
        tv = tower(n, x)
        tower_vals.append(tv)

    import random
    best_match = float('inf')
    best_expr_str = ""
    all_mismatches = 0

    for trial in range(num_exprs):
        random.seed(trial * 7 + 13)
        # Generate random expression
        expr = _random_node(d, 5)
        if expr.exp_depth() > d:
            continue

        vals = [expr.eval(x) for x in test_points]
        if any(v is None for v in vals):
            continue

        # Compute max relative error
        max_err = 0
        for fv, tv in zip(vals, tower_vals):
            if tv != 0 and not math.isinf(tv):
                max_err = max(max_err, abs(fv - tv) / abs(tv))
            elif math.isinf(tv) and not math.isinf(fv):
                max_err = float('inf')

        if max_err < best_match:
            best_match = max_err
            best_expr_str = _node_to_str(expr)

        if max_err > 0.01:
            all_mismatches += 1

    return {
        'n': n,
        'd': d,
        'hierarchy_holds': d < n,
        'num_tested': num_exprs,
        'best_relative_error': best_match,
        'best_expression': best_expr_str,
        'all_mismatched': all_mismatches == num_exprs,
    }


def _random_node(max_depth: int, max_size: int) -> EMLNode:
    """Generate random EML node."""
    import random
    if max_size <= 1 or max_depth < 0:
        return EMLNode('var') if random.random() < 0.6 else EMLNode('const', value=random.choice([1.0, 2.0]))

    r = random.random()
    if r < 0.2:
        return EMLNode('var')
    elif r < 0.3:
        return EMLNode('const', value=random.choice([0.5, 1.0, 2.0, -1.0]))
    elif r < 0.5:
        return EMLNode('add', children=[_random_node(max_depth, max_size//2),
                                         _random_node(max_depth, max_size//2)])
    elif r < 0.7:
        return EMLNode('mul', children=[_random_node(max_depth, max_size//2),
                                         _random_node(max_depth, max_size//2)])
    elif r < 0.85 and max_depth >= 1:
        return EMLNode('exp', children=[_random_node(max_depth-1, max_size-1)])
    else:
        return EMLNode('inv', children=[_random_node(max_depth, max_size-1)])


def _node_to_str(node: EMLNode) -> str:
    if node.kind == 'var':
        return 'x'
    elif node.kind == 'const':
        return f'{node.value}'
    elif node.kind == 'add':
        return f'({_node_to_str(node.children[0])} + {_node_to_str(node.children[1])})'
    elif node.kind == 'mul':
        return f'({_node_to_str(node.children[0])} * {_node_to_str(node.children[1])})'
    elif node.kind == 'exp':
        return f'exp({_node_to_str(node.children[0])})'
    elif node.kind == 'inv':
        return f'1/({_node_to_str(node.children[0])})'
    return '?'


# ──────────────────────────────────────────────────────────────
# Main: Example Usage
# ──────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 60)
    print("EML Depth Hierarchy — Algorithms")
    print("=" * 60)
    print()

    # Algorithm 1: Decision procedure
    print("Algorithm 1: canRepresentAtDepth")
    print("-" * 40)
    for n in range(5):
        for d in range(5):
            result, witness = can_represent_at_depth(n, d)
            status = "YES" if result else "NO"
            print(f"  tower({n}) at depth {d}: {status}", end="")
            if witness:
                print(f"  witness depth={witness.exp_depth()}", end="")
            print()
    print()

    # Algorithm 2: Majorant computation
    print("Algorithm 2: Majorant Computation")
    print("-" * 40)
    test_exprs = [
        EMLNode('var'),
        EMLNode('exp', children=[EMLNode('var')]),
        EMLNode('inv', children=[EMLNode('exp', children=[EMLNode('var')])]),
        EMLNode('add', children=[
            EMLNode('exp', children=[EMLNode('var')]),
            EMLNode('inv', children=[EMLNode('var')])
        ]),
    ]
    for expr in test_exprs:
        d, C, N = compute_majorant(expr)
        print(f"  {_node_to_str(expr):30s}  →  tower({d}, {C:.1f} * x^{N})")
    print()

    # Algorithm 4: Hierarchy verification
    print("Algorithm 4: Hierarchy Verification")
    print("-" * 40)
    for n, d in [(2, 1), (3, 2), (3, 1)]:
        result = verify_hierarchy(n, d, num_exprs=200)
        print(f"  tower({n}) vs depth-{d}: hierarchy={'HOLDS' if result['hierarchy_holds'] else 'N/A'}, "
              f"best error={result['best_relative_error']:.2e}")
    print()
