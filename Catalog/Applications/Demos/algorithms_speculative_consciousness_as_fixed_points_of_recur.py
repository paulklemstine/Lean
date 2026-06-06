#!/usr/bin/env python3
"""
Algorithms for Reflective Operator Algebras

Implements the core computational procedures from the ROA framework:
1. Cantor diagonal construction
2. Kleene chain iteration
3. Diagonal tower generation
4. Fixed point detection on finite lattices
"""

from typing import Callable, List, Set, FrozenSet, Optional, TypeVar, Generic
from dataclasses import dataclass
import math

T = TypeVar('T')


@dataclass
class KleeneResult:
    """Result of Kleene chain computation."""
    chain: List[float]
    limit: float
    convergence_step: int
    is_fixed_point: bool


def cantor_diagonal(
    encoding: dict[int, dict[int, bool]],
    domain_size: int
) -> dict[int, bool]:
    """
    Construct the Cantor diagonal witness for a given encoding.
    
    Given f : {0,...,n-1} -> ({0,...,n-1} -> Bool), returns the predicate
    d(x) = ¬f(x)(x), which is guaranteed not to be in range(f).
    
    Algorithm:
        FOR each x in {0,...,n-1}:
            d(x) := NOT f(x)(x)
        RETURN d
    
    Time complexity: O(n)
    Space complexity: O(n)
    
    Args:
        encoding: Dictionary mapping i to {j: bool} representing f(i)(j)
        domain_size: Size n of the domain
    
    Returns:
        Dictionary mapping x to bool representing the diagonal witness
    """
    return {x: not encoding[x][x] for x in range(domain_size)}


def kleene_chain(
    operator: Callable[[float], float],
    bottom: float = 0.0,
    max_iterations: int = 1000,
    tolerance: float = 1e-12
) -> KleeneResult:
    """
    Compute the Kleene ascending chain F^n(⊥) and detect convergence.
    
    Algorithm:
        x_0 := ⊥
        FOR n = 1, 2, ...:
            x_n := F(x_{n-1})
            IF |x_n - x_{n-1}| < ε:
                RETURN (chain, x_n, n, F(x_n) ≈ x_n)
        RETURN (chain, x_last, max_iter, False)
    
    Time complexity: O(max_iterations)
    Space complexity: O(max_iterations) for the chain
    
    Args:
        operator: Monotone function F
        bottom: The bottom element ⊥
        max_iterations: Maximum number of iterations
        tolerance: Convergence threshold
    
    Returns:
        KleeneResult with chain, limit, and convergence info
    """
    chain = [bottom]
    x = bottom
    
    for n in range(1, max_iterations + 1):
        x_new = operator(x)
        chain.append(x_new)
        
        if abs(x_new - x) < tolerance:
            is_fp = abs(operator(x_new) - x_new) < tolerance
            return KleeneResult(chain, x_new, n, is_fp)
        
        x = x_new
    
    return KleeneResult(chain, x, max_iterations, False)


def diagonal_tower(
    base_encoding: dict[int, dict[int, bool]],
    domain_size: int,
    num_levels: int
) -> List[dict[int, bool]]:
    """
    Construct the diagonal tower: iterated diagonal witnesses.
    
    Algorithm:
        d_0 := cantor_diagonal(f)
        FOR k = 1, 2, ..., num_levels-1:
            d_k(x) := NOT d_{k-1}(x) for all x
        RETURN [d_0, d_1, ..., d_{num_levels-1}]
    
    Time complexity: O(n * num_levels)
    Space complexity: O(n * num_levels)
    
    Args:
        base_encoding: The initial encoding f
        domain_size: Size of the domain
        num_levels: Number of tower levels to compute
    
    Returns:
        List of predicates, one per level
    """
    tower = [cantor_diagonal(base_encoding, domain_size)]
    
    for _ in range(1, num_levels):
        prev = tower[-1]
        tower.append({x: not prev[x] for x in range(domain_size)})
    
    return tower


def find_fixed_points_finite_lattice(
    operator: Callable[[FrozenSet[int]], FrozenSet[int]],
    universe_size: int
) -> List[FrozenSet[int]]:
    """
    Find all fixed points of a monotone operator on P({0,...,n-1}).
    
    Algorithm:
        fixed := []
        FOR each subset S of {0,...,n-1}:
            IF F(S) = S:
                fixed.append(S)
        RETURN fixed
    
    Time complexity: O(2^n * cost(F))
    Space complexity: O(2^n)
    
    Args:
        operator: Monotone function on subsets
        universe_size: Size n of the universe
    
    Returns:
        List of fixed-point subsets
    """
    fixed_points = []
    
    for mask in range(2 ** universe_size):
        S = frozenset(i for i in range(universe_size) if mask & (1 << i))
        if operator(S) == S:
            fixed_points.append(S)
    
    return fixed_points


def reflective_depth(
    operator: Callable[[FrozenSet[int]], FrozenSet[int]],
    target: FrozenSet[int],
    universe_size: int,
    max_depth: int = 100
) -> Optional[int]:
    """
    Compute the reflective depth of a target element.
    
    The reflective depth is the smallest n such that F^n(⊥) ⊇ target.
    
    Algorithm:
        S := ∅ (= ⊥ in P(universe))
        FOR n = 0, 1, 2, ...:
            IF target ⊆ S:
                RETURN n
            S := F(S)
        RETURN None (not reachable)
    
    Args:
        operator: Monotone function on subsets
        target: The element whose depth we want
        universe_size: Size of the universe
        max_depth: Maximum iterations
    
    Returns:
        The reflective depth, or None if not reachable
    """
    S = frozenset()
    
    for n in range(max_depth + 1):
        if target <= S:
            return n
        S = operator(S)
    
    return None


def verify_self_ref_impossibility(max_n: int = 30) -> List[dict]:
    """
    Verify that n = 2^n has no solutions for small n.
    
    Args:
        max_n: Check up to this value
    
    Returns:
        List of results for each n
    """
    results = []
    for n in range(max_n + 1):
        power = 2 ** n
        results.append({
            'n': n,
            'two_to_n': power,
            'equal': n == power,
            'ratio': power / n if n > 0 else float('inf'),
            'gap': power - n
        })
    return results


if __name__ == "__main__":
    # Quick self-test
    print("Testing Cantor diagonal...")
    enc = {i: {j: (i + j) % 2 == 0 for j in range(4)} for i in range(4)}
    diag = cantor_diagonal(enc, 4)
    for i in range(4):
        assert any(enc[i][j] != diag[j] for j in range(4)), \
            f"Diagonal should differ from f({i})"
    print("  ✓ Diagonal is not in range")
    
    print("Testing Kleene chain...")
    result = kleene_chain(lambda x: (x + 1) / 2, 0.0)
    assert abs(result.limit - 1.0) < 1e-10
    assert result.is_fixed_point
    print(f"  ✓ Converged to {result.limit} in {result.convergence_step} steps")
    
    print("Testing diagonal tower...")
    tower = diagonal_tower(enc, 4, 5)
    for k in range(4):
        assert tower[k] != tower[k + 1], f"Adjacent levels should differ"
    print(f"  ✓ All {len(tower)} levels are pairwise-adjacent distinct")
    
    print("Testing finite lattice fixed points...")
    def upward_close(S: FrozenSet[int]) -> FrozenSet[int]:
        if not S:
            return frozenset({0})
        m = max(S)
        return S | frozenset({m + 1}) if m < 3 else S
    fps = find_fixed_points_finite_lattice(upward_close, 4)
    assert len(fps) > 0
    print(f"  ✓ Found {len(fps)} fixed points: {[set(fp) for fp in fps]}")
    
    print("\nAll tests passed!")
