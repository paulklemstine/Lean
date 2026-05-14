#!/usr/bin/env python3
"""
Algorithms for Finite Garden-of-Eden Analysis

Implements the key computational procedures derived from the theorems:
1. Orbit computation and stabilization detection
2. Garden-of-Eden state extraction
3. Eventual image computation
4. Image-cardinality entropy tracking
5. Fixed-point enumeration
"""

from typing import Callable, TypeVar, Set, FrozenSet, List, Tuple, Optional, Dict
from collections import defaultdict
import itertools

T = TypeVar('T')


def compute_orbit(f: Callable[[T], T], x: T, max_steps: int) -> Tuple[List[T], int]:
    """
    Compute the orbit of x under f until stabilization.

    Returns:
        (orbit, stabilization_step) where orbit[stabilization_step] is a fixed point.

    Time complexity: O(max_steps · cost(f))
    Space complexity: O(max_steps)

    By the Finite Garden-of-Eden Descent Principle, if f is monotone descending
    on a finite poset P, stabilization occurs within |P| steps.
    """
    orbit = [x]
    for step in range(1, max_steps + 1):
        next_val = f(orbit[-1])
        orbit.append(next_val)
        if next_val == orbit[-2]:
            return orbit, step - 1  # stabilized: orbit[step-1] is fixed
    return orbit, max_steps


def find_garden_of_eden_states(
    f: Callable[[T], T],
    state_space: List[T]
) -> List[T]:
    """
    Find all Garden-of-Eden states — elements with no preimage under f.

    Algorithm: Compute image of f, return complement.

    Time complexity: O(|state_space| · cost(f))
    Space complexity: O(|state_space|)

    Pseudocode:
        image ← {f(x) : x ∈ state_space}
        return [y ∈ state_space : y ∉ image]
    """
    # Use a set of indices for hashability
    image_indices: Set[int] = set()
    for x in state_space:
        fx = f(x)
        for i, s in enumerate(state_space):
            if s == fx:
                image_indices.add(i)
                break

    return [state_space[i] for i in range(len(state_space)) if i not in image_indices]


def compute_eventual_image(
    f: Callable[[T], T],
    state_space: List[T],
    n_steps: Optional[int] = None
) -> Set[int]:
    """
    Compute the eventual image of f — the range of f^[N] for N = |state_space|.

    By the Eventual Image theorem, this equals the set of fixed points
    when f is monotone descending.

    Time complexity: O(|state_space|² · cost(f))
    Space complexity: O(|state_space|)

    Pseudocode:
        current_image ← state_space
        for step in 1..N:
            current_image ← {f(x) : x ∈ current_image}
            if current_image unchanged: break
        return current_image
    """
    if n_steps is None:
        n_steps = len(state_space)

    # Track as set of indices
    current_indices = set(range(len(state_space)))

    for _ in range(n_steps):
        next_indices: Set[int] = set()
        for i in current_indices:
            fx = f(state_space[i])
            for j, s in enumerate(state_space):
                if s == fx:
                    next_indices.add(j)
                    break
        if next_indices == current_indices:
            break
        current_indices = next_indices

    return current_indices


def compute_entropy_sequence(
    f: Callable[[T], T],
    state_space: List[T],
    max_steps: Optional[int] = None
) -> List[int]:
    """
    Compute the image-cardinality entropy sequence:
        H_n = |range(f^[n])| for n = 0, 1, 2, ...

    This sequence is monotonically non-increasing and stabilizes.

    Time complexity: O(|state_space|² · max_steps)
    Space complexity: O(|state_space|)

    Returns: List of H_n values until stabilization.
    """
    if max_steps is None:
        max_steps = len(state_space)

    # Start with full state space
    current_set = list(range(len(state_space)))
    entropy = [len(current_set)]

    for _ in range(max_steps):
        next_set_indices: Set[int] = set()
        for i in current_set:
            fx = f(state_space[i])
            for j, s in enumerate(state_space):
                if s == fx:
                    next_set_indices.add(j)
                    break
        next_set = sorted(next_set_indices)
        entropy.append(len(next_set))
        if len(next_set) == len(current_set):
            break
        current_set = next_set

    return entropy


def find_fixed_points(
    f: Callable[[T], T],
    state_space: List[T]
) -> List[T]:
    """
    Enumerate all fixed points of f.

    Time complexity: O(|state_space| · cost(f))
    """
    return [x for x in state_space if f(x) == x]


def check_surjectivity(
    f: Callable[[T], T],
    state_space: List[T]
) -> Tuple[bool, Optional[T]]:
    """
    Check if f is surjective on state_space.
    If not, return a Garden-of-Eden witness.

    Time complexity: O(|state_space| · cost(f))
    """
    image = {id(f(x)): f(x) for x in state_space}
    image_set = set()
    for x in state_space:
        image_set.add(state_space.index(f(x)) if f(x) in state_space else -1)

    goe = find_garden_of_eden_states(f, state_space)
    if goe:
        return False, goe[0]
    return True, None


def check_injectivity(
    f: Callable[[T], T],
    state_space: List[T]
) -> Tuple[bool, Optional[Tuple[T, T]]]:
    """
    Check if f is injective on state_space.
    If not, return a collision pair.

    Time complexity: O(|state_space| · cost(f))
    """
    seen: Dict[int, T] = {}  # index of f(x) -> x
    for x in state_space:
        fx = f(x)
        fx_idx = state_space.index(fx) if fx in state_space else -1
        if fx_idx in seen:
            return False, (seen[fx_idx], x)
        seen[fx_idx] = x
    return True, None


def moore_myhill_check(
    f: Callable[[T], T],
    state_space: List[T]
) -> dict:
    """
    Verify the finite Moore-Myhill property:
    On finite types, surjective ↔ injective.

    Returns a diagnostic dictionary.
    """
    is_surj, goe_witness = check_surjectivity(f, state_space)
    is_inj, collision = check_injectivity(f, state_space)

    return {
        'surjective': is_surj,
        'injective': is_inj,
        'moore_myhill_holds': is_surj == is_inj,
        'garden_of_eden_witness': goe_witness,
        'collision_pair': collision,
        'image_size': len(set(state_space.index(f(x)) for x in state_space)),
        'domain_size': len(state_space),
    }


# =============================================================================
# Configuration space utilities
# =============================================================================

def binary_configurations(n_cells: int) -> List[Tuple[int, ...]]:
    """Generate all binary configurations on n cells."""
    return list(itertools.product([0, 1], repeat=n_cells))


def finite_configurations(n_cells: int, alphabet_size: int) -> List[Tuple[int, ...]]:
    """Generate all configurations on n cells with given alphabet."""
    return list(itertools.product(range(alphabet_size), repeat=n_cells))


# =============================================================================
# Example usage
# =============================================================================

if __name__ == "__main__":
    print("=" * 60)
    print("Algorithm Demonstrations")
    print("=" * 60)

    # Example: threshold dynamics on {0,1}^3
    configs = binary_configurations(3)
    print(f"\nBinary configurations on 3 cells: {len(configs)} states")

    def threshold_rule(c: Tuple[int, ...]) -> Tuple[int, ...]:
        """Each cell becomes 1 iff majority of neighbors are 1."""
        n = len(c)
        return tuple(
            1 if sum(c[max(0,i-1):min(n,i+2)]) >= 2 else 0
            for i in range(n)
        )

    # Garden-of-Eden analysis
    goe = find_garden_of_eden_states(threshold_rule, configs)
    print(f"Garden-of-Eden states under threshold rule: {len(goe)}")
    for g in goe[:5]:
        print(f"  {g}")

    # Entropy sequence
    entropy = compute_entropy_sequence(threshold_rule, configs)
    print(f"\nEntropy sequence: {entropy}")

    # Fixed points
    fixed = find_fixed_points(threshold_rule, configs)
    print(f"Fixed points: {len(fixed)}")
    for fp in fixed:
        print(f"  {fp}")

    # Moore-Myhill check
    mm = moore_myhill_check(threshold_rule, configs)
    print(f"\nMoore-Myhill check: {mm}")
