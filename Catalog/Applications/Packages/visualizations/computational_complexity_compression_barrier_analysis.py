#!/usr/bin/env python3
"""
Algorithms for Finite Description Complexity

Implements the core computational procedures from the formalized theory:
- Description complexity computation
- Incompressible element detection
- Collision finding
- Compression barrier analysis
"""

from typing import TypeVar, Callable, Optional, List, Tuple, Set, Dict
from dataclasses import dataclass
import math

T = TypeVar('T')


@dataclass
class DescriptionComplexity:
    """Result of computing description complexity for an element."""
    element: object
    complexity: Optional[int]  # None if incompressible
    witness_index: Optional[int]  # The code achieving the complexity


def compute_desc_complexity(encoder: List[T], x: T) -> DescriptionComplexity:
    """
    Compute the description complexity of x relative to encoder E.

    The description complexity is the least index i such that E[i] = x.
    Returns None if x is not in the range of E.

    Time complexity: O(N) where N = len(encoder)
    Space complexity: O(1)

    Args:
        encoder: List representing E : Fin N → α
        x: Element to find complexity of

    Returns:
        DescriptionComplexity with the minimum index and complexity value

    Example:
        >>> E = [3, 1, 4, 1, 5, 9, 2, 6]
        >>> compute_desc_complexity(E, 4)
        DescriptionComplexity(element=4, complexity=2, witness_index=2)
        >>> compute_desc_complexity(E, 7)
        DescriptionComplexity(element=7, complexity=None, witness_index=None)
    """
    for i, val in enumerate(encoder):
        if val == x:
            return DescriptionComplexity(element=x, complexity=i, witness_index=i)
    return DescriptionComplexity(element=x, complexity=None, witness_index=None)


def count_reachable_outputs(encoder: List[T], k: int) -> Set[T]:
    """
    Compute the set of outputs reachable by codes of index ≤ k.

    Implements the Finset computation:
      (Finset.univ.filter (fun i => i.val ≤ k)).image E

    Time complexity: O(min(k+1, N))
    Space complexity: O(min(k+1, N))

    Args:
        encoder: List representing E : Fin N → α
        k: Maximum code index

    Returns:
        Set of distinct outputs produced by codes 0, 1, ..., min(k, N-1)

    Example:
        >>> E = [3, 1, 4, 1, 5]
        >>> count_reachable_outputs(E, 2)
        {3, 1, 4}
    """
    return set(encoder[i] for i in range(min(k + 1, len(encoder))))


def find_incompressible_elements(
    encoder: List[T],
    universe: Set[T],
    k: int
) -> List[T]:
    """
    Find all elements in universe with description complexity > k.

    Implements the constructive content of exists_not_encoded_by_small_index:
    returns all x ∈ universe such that ¬∃ i ≤ k, E[i] = x.

    Time complexity: O(|universe| + min(k+1, N))
    Space complexity: O(min(k+1, N) + |result|)

    Args:
        encoder: List representing E : Fin N → α
        universe: Set S of elements to check
        k: Maximum allowable complexity

    Returns:
        List of elements not reachable by any code of index ≤ k

    Example:
        >>> E = [3, 1, 4, 1, 5]
        >>> find_incompressible_elements(E, {0,1,2,3,4,5,6}, 2)
        [0, 2, 5, 6]  # (order may vary)
    """
    reachable = count_reachable_outputs(encoder, k)
    return [x for x in universe if x not in reachable]


def find_collisions(encoder: List[T], k: int) -> List[Tuple[int, int, T]]:
    """
    Find all pairs of distinct indices i < j ≤ k with E[i] = E[j].

    Implements the constructive content of exists_collision_of_card_lt_codes.

    Time complexity: O(min(k+1, N)²) worst case, O(min(k+1, N)) expected with hashing
    Space complexity: O(min(k+1, N))

    Args:
        encoder: List representing E : Fin N → α
        k: Maximum code index

    Returns:
        List of (i, j, value) triples where i < j ≤ k and E[i] = E[j] = value

    Example:
        >>> E = [3, 1, 4, 1, 5, 3]
        >>> find_collisions(E, 5)
        [(0, 5, 3), (1, 3, 1)]
    """
    seen: Dict[T, int] = {}
    collisions = []
    for i in range(min(k + 1, len(encoder))):
        val = encoder[i]
        if val in seen:
            collisions.append((seen[val], i, val))
        else:
            seen[val] = i
    return collisions


def compression_barrier_analysis(
    encoder: List[T],
    universe: Set[T]
) -> Dict[str, object]:
    """
    Complete compression barrier analysis for an encoder.

    For each depth budget k, computes:
    - Number of reachable outputs
    - Number of incompressible elements
    - Number of collisions
    - Whether the counting bound is tight

    Time complexity: O(N × |universe|)
    Space complexity: O(N + |universe|)

    Args:
        encoder: List representing E : Fin N → α
        universe: Complete set of objects to analyze

    Returns:
        Dictionary with analysis results for each depth level

    Example:
        >>> E = [0, 1, 0, 2, 3, 1]
        >>> analysis = compression_barrier_analysis(E, set(range(10)))
    """
    N = len(encoder)
    results = {
        'N': N,
        'universe_size': len(universe),
        'levels': []
    }

    for k in range(N):
        reachable = count_reachable_outputs(encoder, k)
        incompressible = [x for x in universe if x not in reachable]
        collisions = find_collisions(encoder, k)

        level_data = {
            'k': k,
            'budget': k + 1,
            'reachable_count': len(reachable),
            'bound_tight': len(reachable) == k + 1,
            'incompressible_count': len(incompressible),
            'collision_count': len(collisions),
            'coverage_fraction': len(reachable) / len(universe) if universe else 0,
        }
        results['levels'].append(level_data)

    return results


def binary_complexity_spectrum(n: int) -> Dict[int, Dict[str, int]]:
    """
    Compute the Kolmogorov-style complexity spectrum for binary strings.

    For each complexity level k = 0, ..., n, reports:
    - Number of strings describable at that level: 2^(k+1) - 1
    - Number of incompressible strings: 2^n - (2^(k+1) - 1)

    This implements the binary-code version of the counting bound.

    Args:
        n: Length of binary strings

    Returns:
        Dictionary mapping complexity level to statistics

    Example:
        >>> spectrum = binary_complexity_spectrum(8)
        >>> spectrum[3]
        {'describable': 15, 'incompressible': 241, 'total': 256}
    """
    total = 2**n
    spectrum = {}

    for k in range(n + 1):
        describable = min(2**(k + 1) - 1, total)
        spectrum[k] = {
            'describable': describable,
            'incompressible': total - describable,
            'total': total,
            'describable_fraction': describable / total,
        }

    return spectrum


# ─── Example Usage ───────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=== Description Complexity Computation ===")
    E = [3, 1, 4, 1, 5, 9, 2, 6, 5, 3]
    for x in [1, 4, 7, 9]:
        result = compute_desc_complexity(E, x)
        if result.complexity is not None:
            print(f"  C_E({x}) = {result.complexity} (E[{result.witness_index}] = {x})")
        else:
            print(f"  C_E({x}) = ∞ (incompressible)")

    print()
    print("=== Compression Barrier Analysis ===")
    E = [0, 2, 1, 3, 0, 4, 2, 5]
    universe = set(range(10))
    analysis = compression_barrier_analysis(E, universe)
    print(f"Encoder of size {analysis['N']} into universe of size {analysis['universe_size']}")
    for level in analysis['levels']:
        print(f"  k={level['k']}: {level['reachable_count']}/{level['budget']} reachable "
              f"(bound {'tight' if level['bound_tight'] else 'slack'}), "
              f"{level['incompressible_count']} incompressible, "
              f"{level['collision_count']} collisions")

    print()
    print("=== Binary Complexity Spectrum (n=8) ===")
    spectrum = binary_complexity_spectrum(8)
    for k, data in spectrum.items():
        print(f"  k={k}: {data['describable']:4d}/{data['total']} describable "
              f"({data['describable_fraction']*100:.1f}%), "
              f"{data['incompressible']} incompressible")
