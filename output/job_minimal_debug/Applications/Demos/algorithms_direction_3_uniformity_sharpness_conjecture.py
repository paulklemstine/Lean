#!/usr/bin/env python3
"""
Algorithms for Uniformity Sharpness Theory

Implements the core algorithms from the research paper:
1. Transition window computation
2. Sunflower detection
3. Overlap matrix computation and spectral analysis
4. Independence number (packing) computation
5. Normalized window width computation

All algorithms include docstrings, type hints, and example usage.

Usage:
    python algorithms.py
"""

import random
import math
from itertools import combinations
from typing import List, Set, Tuple, Optional, FrozenSet, Dict
from collections import defaultdict


# ============================================================
# Core Data Structures
# ============================================================

class ObstructionSystem:
    """
    An obstruction system (V, O) over a finite ground set V.

    Attributes:
        ground: The ground set V.
        obstructions: List of obstruction sets, each a nonempty subset of V.
    """

    def __init__(self, ground: Set[int], obstructions: List[Set[int]]):
        self.ground = frozenset(ground)
        self.obstructions = [frozenset(o) for o in obstructions]
        self._validate()

    def _validate(self) -> None:
        """Validate that all obstructions are nonempty subsets of ground."""
        for o in self.obstructions:
            if len(o) == 0:
                raise ValueError("Obstructions must be nonempty")
            if not o <= self.ground:
                raise ValueError(f"Obstruction {o} is not a subset of ground set")

    def is_satisfiable(self, S: Set[int]) -> bool:
        """
        Check if retained set S is satisfiable.

        A set S is satisfiable iff no obstruction is fully contained in S.

        Args:
            S: A subset of the ground set.

        Returns:
            True if S is satisfiable.

        Example:
            >>> sys = ObstructionSystem({1,2,3,4}, [{1,2,3}])
            >>> sys.is_satisfiable({1, 2})
            True
            >>> sys.is_satisfiable({1, 2, 3})
            False
        """
        S_frozen = frozenset(S)
        return all(not o <= S_frozen for o in self.obstructions)

    def uniformity(self) -> Optional[int]:
        """
        Return d if the system is d-uniform, else None.

        A system is d-uniform if every obstruction has exactly d elements.

        Returns:
            The uniformity parameter d, or None if not uniform.
        """
        if not self.obstructions:
            return None
        sizes = set(len(o) for o in self.obstructions)
        return sizes.pop() if len(sizes) == 1 else None

    @property
    def n(self) -> int:
        """Size of the ground set."""
        return len(self.ground)

    @property
    def m(self) -> int:
        """Number of obstructions."""
        return len(self.obstructions)


# ============================================================
# Algorithm 1: Transition Window Computation
# ============================================================

def compute_transition_window(sys: ObstructionSystem) -> Tuple[int, int]:
    """
    Compute the transition window [k1, k2] for an obstruction system.

    k1 = largest k such that ALL k-subsets of ground are satisfiable.
    k2 = smallest k such that ALL k-subsets of ground are unsatisfiable.

    Time complexity: O(2^n * m) where n = |ground|, m = |obstructions|.

    Args:
        sys: An obstruction system.

    Returns:
        Tuple (k1, k2) defining the transition window.

    Example:
        >>> sys = ObstructionSystem({1,2,3,4,5}, [{1,2,3}, {3,4,5}])
        >>> compute_transition_window(sys)
        (2, 5)
    """
    n = sys.n
    elements = sorted(sys.ground)

    # Find k1: largest k where all k-subsets are satisfiable
    k1 = 0
    for k in range(1, n + 1):
        all_sat = True
        for S in combinations(elements, k):
            if not sys.is_satisfiable(set(S)):
                all_sat = False
                break
        if all_sat:
            k1 = k
        else:
            break

    # Find k2: smallest k where all k-subsets are unsatisfiable
    k2 = n + 1  # sentinel
    for k in range(n, -1, -1):
        all_unsat = True
        for S in combinations(elements, k):
            if sys.is_satisfiable(set(S)):
                all_unsat = False
                break
        if all_unsat:
            k2 = k
        else:
            break

    return k1, k2


def normalized_window_width(sys: ObstructionSystem) -> float:
    """
    Compute the normalized transition window width.

    The normalized width is (k2 - k1) / sqrt(m), where m is the number
    of obstructions. This normalization enables fair comparison across
    system sizes.

    Args:
        sys: An obstruction system with at least one obstruction.

    Returns:
        The normalized window width.
    """
    k1, k2 = compute_transition_window(sys)
    width = k2 - k1
    if sys.m == 0:
        return float('inf')
    return width / math.sqrt(sys.m)


# ============================================================
# Algorithm 2: Sunflower Detection
# ============================================================

def find_sunflower(
    obstructions: List[FrozenSet[int]],
    min_size: int = 3
) -> Optional[Tuple[List[FrozenSet[int]], FrozenSet[int]]]:
    """
    Find a sunflower of size >= min_size in the obstruction family.

    A sunflower is a subfamily where all pairwise intersections are equal
    (the kernel).

    Algorithm: For each possible kernel (intersection of each pair),
    greedily build the largest sunflower with that kernel.

    Time complexity: O(m^2 * d * m) where m = |obstructions|, d = max size.

    Args:
        obstructions: List of obstruction sets.
        min_size: Minimum sunflower size to find.

    Returns:
        Tuple (sunflower_members, kernel) if found, else None.

    Example:
        >>> obs = [frozenset({1,2,3}), frozenset({1,2,4}), frozenset({1,2,5})]
        >>> result = find_sunflower(obs, min_size=3)
        >>> result is not None
        True
    """
    if len(obstructions) < min_size:
        return None

    # Collect candidate kernels from all pairwise intersections
    candidates: Set[FrozenSet[int]] = set()
    candidates.add(frozenset())  # empty kernel

    for i in range(len(obstructions)):
        for j in range(i + 1, len(obstructions)):
            candidates.add(obstructions[i] & obstructions[j])

    best_sunflower: Optional[Tuple[List[FrozenSet[int]], FrozenSet[int]]] = None
    best_size = 0

    for kernel in candidates:
        # Find all obstructions containing this kernel
        containing = [o for o in obstructions if kernel <= o]

        # Greedily build sunflower: add obstructions whose petal
        # doesn't overlap with any existing petal
        sunflower = []
        used_petals: Set[int] = set()

        for o in containing:
            petal = o - kernel
            if not (petal & used_petals):
                sunflower.append(o)
                used_petals |= petal

        if len(sunflower) >= min_size and len(sunflower) > best_size:
            # Verify it's actually a sunflower
            is_valid = True
            for a in range(len(sunflower)):
                for b in range(a + 1, len(sunflower)):
                    if sunflower[a] & sunflower[b] != kernel:
                        is_valid = False
                        break
                if not is_valid:
                    break

            if is_valid:
                best_sunflower = (sunflower, kernel)
                best_size = len(sunflower)

    return best_sunflower


# ============================================================
# Algorithm 3: Overlap Matrix Computation
# ============================================================

def compute_overlap_matrix(sys: ObstructionSystem) -> List[List[int]]:
    """
    Compute the uniform overlap matrix M[i][j] = |o_i ∩ o_j|.

    Time complexity: O(m^2 * d) where m = |obstructions|, d = max size.

    Args:
        sys: An obstruction system.

    Returns:
        The m × m overlap matrix as a list of lists.

    Example:
        >>> sys = ObstructionSystem({1,2,3,4}, [{1,2,3}, {2,3,4}])
        >>> M = compute_overlap_matrix(sys)
        >>> M[0][1]  # |{1,2,3} ∩ {2,3,4}| = 2
        2
    """
    m = sys.m
    obs = sys.obstructions
    M = [[0] * m for _ in range(m)]
    for i in range(m):
        for j in range(m):
            M[i][j] = len(obs[i] & obs[j])
    return M


def overlap_matrix_stats(M: List[List[int]]) -> Dict[str, float]:
    """
    Compute statistics of the overlap matrix.

    Returns trace, max off-diagonal, average off-diagonal, and
    Frobenius norm.
    """
    m = len(M)
    if m == 0:
        return {"trace": 0, "max_offdiag": 0, "avg_offdiag": 0, "frobenius": 0}

    trace = sum(M[i][i] for i in range(m))
    offdiag = [M[i][j] for i in range(m) for j in range(m) if i != j]
    max_offdiag = max(offdiag) if offdiag else 0
    avg_offdiag = sum(offdiag) / len(offdiag) if offdiag else 0
    frobenius = math.sqrt(sum(M[i][j] ** 2 for i in range(m) for j in range(m)))

    return {
        "trace": trace,
        "max_offdiag": max_offdiag,
        "avg_offdiag": avg_offdiag,
        "frobenius": frobenius
    }


# ============================================================
# Algorithm 4: Independence Number (Greedy Packing)
# ============================================================

def compute_independence_number(
    sys: ObstructionSystem,
    restarts: int = 1000
) -> Tuple[int, List[FrozenSet[int]]]:
    """
    Compute a lower bound on the obstruction independence number.

    Uses randomized greedy algorithm with multiple restarts.

    Time complexity: O(restarts * m^2) per restart.

    Args:
        sys: An obstruction system.
        restarts: Number of random restarts.

    Returns:
        Tuple (lower_bound, best_packing).

    Example:
        >>> sys = ObstructionSystem({1,2,3,4,5,6},
        ...     [{1,2}, {3,4}, {5,6}, {1,3}])
        >>> nu, packing = compute_independence_number(sys)
        >>> nu >= 2
        True
    """
    best_packing: List[FrozenSet[int]] = []
    obs = list(sys.obstructions)

    for _ in range(restarts):
        random.shuffle(obs)
        packing = []
        used: Set[int] = set()
        for o in obs:
            if not (o & used):
                packing.append(o)
                used |= o
        if len(packing) > len(best_packing):
            best_packing = list(packing)

    return len(best_packing), best_packing


# ============================================================
# Algorithm 5: Hamming Distance Computation
# ============================================================

def obstruction_hamming_distance(
    o1: FrozenSet[int],
    o2: FrozenSet[int]
) -> int:
    """
    Compute the Hamming distance between two obstructions.

    Viewing obstructions as characteristic vectors, the Hamming distance
    is |o1 △ o2| = |o1| + |o2| - 2|o1 ∩ o2|.

    Args:
        o1, o2: Obstruction sets.

    Returns:
        The Hamming distance.

    Example:
        >>> obstruction_hamming_distance(frozenset({1,2,3}), frozenset({2,3,4}))
        2
    """
    return len(o1) + len(o2) - 2 * len(o1 & o2)


# ============================================================
# Algorithm 6: Uniformity Gap Ratio
# ============================================================

def uniformity_gap_ratio(d: int) -> float:
    """
    Compute the conjectured uniformity gap ratio √(d/(d-1)).

    For d ≥ 2, this is > 1, meaning d-uniform systems should have
    sharper transitions than non-uniform systems.

    Args:
        d: The uniformity parameter (must be ≥ 2).

    Returns:
        The gap ratio.

    Example:
        >>> uniformity_gap_ratio(3)  # √(3/2) ≈ 1.2247
        1.2247448713915890...
    """
    if d < 2:
        raise ValueError("d must be at least 2")
    return math.sqrt(d / (d - 1))


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    print("Uniformity Sharpness Algorithms — Example Usage")
    print("=" * 55)

    # Create a 3-uniform system
    ground = set(range(1, 11))
    obstructions = [
        {1, 2, 3}, {2, 4, 6}, {3, 5, 7}, {1, 4, 7},
        {2, 5, 8}, {3, 6, 9}, {7, 8, 9}, {1, 5, 9}
    ]
    sys = ObstructionSystem(ground, obstructions)

    print(f"\nSystem: n={sys.n}, m={sys.m}, d={sys.uniformity()}")

    # Transition window
    k1, k2 = compute_transition_window(sys)
    print(f"Transition window: [{k1}, {k2}], width = {k2 - k1}")

    # Normalized width
    nw = normalized_window_width(sys)
    print(f"Normalized window width: {nw:.4f}")

    # Overlap matrix
    M = compute_overlap_matrix(sys)
    stats = overlap_matrix_stats(M)
    print(f"Overlap matrix stats: {stats}")

    # Independence number
    nu, packing = compute_independence_number(sys)
    print(f"Independence number ≥ {nu}")
    for p in packing:
        print(f"  Packing member: {sorted(p)}")

    # Sunflower detection
    result = find_sunflower(sys.obstructions, min_size=2)
    if result:
        sf, kernel = result
        print(f"Sunflower found: kernel={sorted(kernel)}, size={len(sf)}")
        for o in sf:
            print(f"  Member: {sorted(o)}")
    else:
        print("No sunflower found")

    # Hamming distances
    print("\nHamming distances between first 4 obstructions:")
    for i in range(min(4, sys.m)):
        for j in range(i + 1, min(4, sys.m)):
            d_h = obstruction_hamming_distance(
                sys.obstructions[i], sys.obstructions[j])
            print(f"  d_H(o{i+1}, o{j+1}) = {d_h}")

    # Gap ratio
    for d in [2, 3, 4, 5, 10]:
        print(f"  Gap ratio for d={d}: {uniformity_gap_ratio(d):.4f}")
