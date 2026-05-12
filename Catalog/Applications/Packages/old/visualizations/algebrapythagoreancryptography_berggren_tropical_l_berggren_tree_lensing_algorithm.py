#!/usr/bin/env python3
"""
Berggren Tropical Lensing — Algorithms

Complete implementations of the core algorithms from the research paper,
with docstrings, type hints, and example usage.
"""

from math import gcd, log2
from typing import Optional
from dataclasses import dataclass


# ─────────────────────────────────────────────────────────────
# Data Types
# ─────────────────────────────────────────────────────────────

@dataclass(frozen=True)
class Triple:
    """A Pythagorean triple (a, b, c)."""
    a: int
    b: int
    c: int

    def is_pythagorean(self) -> bool:
        return self.a**2 + self.b**2 == self.c**2

    def __str__(self) -> str:
        return f"({self.a}, {self.b}, {self.c})"


@dataclass
class LensResult:
    """Result of a lensing computation."""
    value: float          # Lensing value (inf if no compatible node found)
    path: list[str]       # Sequence of generators
    endpoint: Triple      # Terminal triple
    divisor: Optional[int]  # Extracted divisor (if compatible)
    depth: int            # Depth at which solution was found


ROOT = Triple(3, 4, 5)
INF = float('inf')


# ─────────────────────────────────────────────────────────────
# Berggren Generators
# ─────────────────────────────────────────────────────────────

def apply_gen(name: str, t: Triple) -> Triple:
    """Apply a Berggren generator (A, B, or C) to a triple.

    The three Berggren matrices are:
      A = [1,-2,2; 2,-1,2; 2,-2,3]
      B = [1,2,2; 2,1,2; 2,2,3]
      C = [-1,2,2; -2,1,2; -2,2,3]

    Args:
        name: Generator name ('A', 'B', or 'C')
        t: Input Pythagorean triple

    Returns:
        New Pythagorean triple

    Example:
        >>> apply_gen('A', Triple(3, 4, 5))
        Triple(a=5, b=12, c=13)
    """
    a, b, c = t.a, t.b, t.c
    if name == 'A':
        return Triple(a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)
    elif name == 'B':
        return Triple(a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)
    elif name == 'C':
        return Triple(-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)
    else:
        raise ValueError(f"Unknown generator: {name}")


# ─────────────────────────────────────────────────────────────
# Compatibility and Divisor Extraction
# ─────────────────────────────────────────────────────────────

def is_compatible(n: int, t: Triple) -> bool:
    """Check if triple t is compatible with target integer n.

    A triple is compatible if one of its leg coordinates is a
    nontrivial divisor of n (strictly between 1 and n).

    Args:
        n: Target integer
        t: Pythagorean triple

    Returns:
        True if compatible

    Example:
        >>> is_compatible(15, Triple(3, 4, 5))
        True  # because 3 | 15 and 1 < 3 < 15
    """
    return ((1 < abs(t.a) < n and n % abs(t.a) == 0) or
            (1 < abs(t.b) < n and n % abs(t.b) == 0))


def extract_divisor(n: int, t: Triple) -> Optional[int]:
    """Extract a nontrivial divisor of n from a compatible triple.

    Uses GCD-based extraction: picks gcd(n, |a|) if nontrivial,
    otherwise gcd(n, |b|).

    Args:
        n: Target integer
        t: Compatible Pythagorean triple

    Returns:
        A divisor d of n with 1 < d < n, or None

    Example:
        >>> extract_divisor(65, Triple(5, 12, 13))
        5
    """
    g1 = gcd(n, abs(t.a))
    if 1 < g1 < n:
        return g1
    g2 = gcd(n, abs(t.b))
    if 1 < g2 < n:
        return g2
    return None


# ─────────────────────────────────────────────────────────────
# Core Algorithm: Berggren Tropical Lensing
# ─────────────────────────────────────────────────────────────

def berggren_lens(n: int, max_depth: int, root: Triple = ROOT) -> LensResult:
    """Find the cheapest path to a compatible Berggren node.

    Implements backward tropical propagation (dynamic programming)
    on the Berggren tree with hypotenuse-difference weights.

    Time complexity: O(3^max_depth)
    Space complexity: O(max_depth) (depth-first)

    Args:
        n: Target integer to find divisors of
        max_depth: Maximum search depth in the tree
        root: Starting triple (default: (3,4,5))

    Returns:
        LensResult with optimal path, endpoint, and extracted divisor

    Example:
        >>> result = berggren_lens(65, 3)
        >>> result.divisor
        5
        >>> result.path
        ['A']
    """
    def _search(t: Triple, depth: int) -> tuple[float, list[str], Triple]:
        if is_compatible(n, t):
            return (0, [], t)
        if depth == 0:
            return (INF, [], t)

        best_cost = INF
        best_path: list[str] = []
        best_endpoint = t

        for name in ['A', 'B', 'C']:
            child = apply_gen(name, t)
            w = abs(child.c - t.c)  # hypotenuse difference weight
            child_cost, child_path, child_endpoint = _search(child, depth - 1)
            total = w + child_cost
            if total < best_cost:
                best_cost = total
                best_path = [name] + child_path
                best_endpoint = child_endpoint

        return (best_cost, best_path, best_endpoint)

    cost, path, endpoint = _search(root, max_depth)
    divisor = extract_divisor(n, endpoint) if cost < INF else None
    return LensResult(
        value=cost,
        path=path,
        endpoint=endpoint,
        divisor=divisor,
        depth=len(path)
    )


def convergence_depth(n: int, max_depth: int = 10) -> int:
    """Find the depth at which the lensing value converges.

    Returns the smallest d such that lens_value(d) = lens_value(d+1),
    or max_depth if no convergence.

    Args:
        n: Target integer
        max_depth: Maximum depth to search

    Returns:
        Convergence depth
    """
    prev = INF
    for d in range(max_depth + 1):
        result = berggren_lens(n, d)
        if result.value == prev and result.value < INF:
            return d - 1
        if result.value < INF and d == 0:
            return 0
        prev = result.value
    return max_depth


# ─────────────────────────────────────────────────────────────
# Bellman Equation Verification
# ─────────────────────────────────────────────────────────────

def verify_bellman(n: int, depth: int, t: Triple) -> bool:
    """Verify the Bellman equation at a given node.

    Checks that:
      L(t) = min(penalty(t), min_g(L(g(t)) + w(t, g(t))))

    Args:
        n: Target integer
        depth: Search depth
        t: Node to verify

    Returns:
        True if the Bellman equation holds
    """
    if depth == 0:
        return True  # Base case is definitional

    result = berggren_lens(n, depth, t)
    penalty = 0 if is_compatible(n, t) else INF

    child_costs = []
    for name in ['A', 'B', 'C']:
        child = apply_gen(name, t)
        w = abs(child.c - t.c)
        child_result = berggren_lens(n, depth - 1, child)
        child_costs.append(w + child_result.value)

    bellman_value = min(penalty, min(child_costs))
    return abs(result.value - bellman_value) < 0.01


# ─────────────────────────────────────────────────────────────
# Example Usage
# ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Berggren Tropical Lensing — Algorithm Examples\n")

    # Example 1: Factor 1001 = 7 × 11 × 13
    result = berggren_lens(1001, 5)
    print(f"Factor 1001:")
    print(f"  Path: {' → '.join(result.path) or '(root)'}")
    print(f"  Endpoint: {result.endpoint}")
    print(f"  Cost: {result.value}")
    print(f"  Divisor: {result.divisor}")
    if result.divisor:
        print(f"  Check: {result.divisor} × {1001 // result.divisor} = {1001}")
    print()

    # Example 2: Convergence analysis
    print("Convergence depths:")
    for n in [15, 65, 77, 100, 1001]:
        cd = convergence_depth(n, 6)
        print(f"  n = {n:>5}: converges at depth {cd}")
    print()

    # Example 3: Bellman verification
    print("Bellman equation verification:")
    for depth in range(1, 5):
        ok = verify_bellman(65, depth, ROOT)
        print(f"  depth {depth}, root: {'✓' if ok else '✗'}")
