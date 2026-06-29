#!/usr/bin/env python3
"""
Algorithms for Ultrametric Proof-Code Duality

Implements the core algorithms from the research paper:
1. Observer distance computation
2. Canonical observer construction from ultrametric
3. Congruence-class decoder
4. Nested partition system construction
5. Ultrametric verification
"""

from itertools import combinations
from typing import List, Tuple, Set, Optional, Dict


def obs_dist(observers: List[List[int]], levels: List[int],
             x: int, y: int) -> int:
    """
    Compute observer-induced distance between points x and y.

    The observer distance is the maximum level of any observer
    that distinguishes x from y. Returns 0 if all observers agree.

    Time complexity: O(|observers|)
    Space complexity: O(1)

    Args:
        observers: List of observer functions (each maps point index to value)
        levels: Level assignment for each observer
        x, y: Point indices

    Returns:
        ℕ-valued ultrametric distance
    """
    max_lvl = 0
    found = False
    for obs, lvl in zip(observers, levels):
        if obs[x] != obs[y]:
            found = True
            max_lvl = max(max_lvl, lvl)
    return max_lvl if found else 0


def sep_level(observers: List[List[int]], levels: List[int],
              x: int, y: int) -> int:
    """
    Compute separation level (minimum distinguishing observer level).

    This is the p-adic valuation analogue: lower values mean
    "more separated" (distinguished at coarser resolution).

    Time complexity: O(|observers|)

    Args:
        observers, levels: Observer family with levels
        x, y: Point indices

    Returns:
        Minimum level of a distinguishing observer, or -1 if none
    """
    min_lvl = float('inf')
    for obs, lvl in zip(observers, levels):
        if obs[x] != obs[y]:
            min_lvl = min(min_lvl, lvl)
    return min_lvl if min_lvl != float('inf') else -1


def kernel_at_level(observers: List[List[int]], levels: List[int],
                    k: int, x: int, y: int) -> bool:
    """
    Check if x and y are in the same kernel class at level k.

    Two points are kernel-equivalent at level k if all observers
    with level ≤ k assign them the same value.

    Time complexity: O(|observers|)
    """
    for obs, lvl in zip(observers, levels):
        if lvl <= k and obs[x] != obs[y]:
            return False
    return True


def closed_ball(observers: List[List[int]], levels: List[int],
                k: int, center: int, n: int) -> Set[int]:
    """
    Compute the closed ball of radius k centered at 'center'.

    By the duality theorem, this equals the kernel class at level k.

    Time complexity: O(|observers| * n)
    """
    return {y for y in range(n)
            if kernel_at_level(observers, levels, k, center, y)}


def canonical_observers(d: List[List[int]], n: int) -> Tuple[List[List[int]], List[int]]:
    """
    Construct the canonical observer family from a distance matrix.

    Observer i maps point p to d(i, p). All levels are set to 0
    (flat assignment). This separates all distinct points since
    O_x(x) = d(x,x) = 0 ≠ d(x,y) = O_x(y) for x ≠ y.

    Time complexity: O(n²) for construction
    Space complexity: O(n²) for the observer family
    """
    observers = [d[i][:] for i in range(n)]
    levels = [0] * n
    return observers, levels


def verify_ultrametric(d: List[List[int]], n: int) -> Tuple[bool, Optional[Tuple[int, int, int]]]:
    """
    Verify that a distance matrix satisfies all ultrametric axioms.

    Checks: d(x,x)=0, symmetry, positive definiteness,
    and the strong triangle inequality d(x,z) ≤ max(d(x,y), d(y,z)).

    Time complexity: O(n³)

    Returns:
        (True, None) if valid, (False, counterexample_triple) if not
    """
    for x in range(n):
        if d[x][x] != 0:
            return False, (x, x, x)
    for x in range(n):
        for y in range(n):
            if d[x][y] != d[y][x]:
                return False, (x, y, -1)
    for x in range(n):
        for y in range(n):
            if d[x][y] == 0 and x != y:
                return False, (x, y, -1)
    for x in range(n):
        for y in range(n):
            for z in range(n):
                if d[x][z] > max(d[x][y], d[y][z]):
                    return False, (x, y, z)
    return True, None


def build_nested_partition(d: List[List[int]], n: int) -> Dict[int, List[List[int]]]:
    """
    Build the canonical nested partition system from an ultrametric.

    At each level k, points x and y are in the same class iff d(x,y) ≤ k.

    Time complexity: O(n² * max_d)

    Returns:
        Dictionary mapping level k to list of equivalence classes
    """
    max_d = max(d[i][j] for i in range(n) for j in range(n))
    partitions = {}

    for k in range(max_d + 1):
        classes = []
        visited = set()
        for x in range(n):
            if x not in visited:
                cls = [y for y in range(n) if d[x][y] <= k]
                classes.append(cls)
                visited.update(cls)
        partitions[k] = classes

    return partitions


def congruence_decode(observers: List[List[int]], levels: List[int],
                      k: int, received: Dict[int, int], n: int) -> Set[int]:
    """
    Congruence-class decoder: find all points consistent with received values.

    Given partial observations (observer index -> observed value), find
    the set of points that match all observations at level ≤ k.

    This is equivalent to nearest-ball decoding by the duality theorem.

    Time complexity: O(|observers| * n)

    Args:
        observers, levels: Observer family
        k: Decoding level
        received: Dictionary {observer_index: observed_value}
        n: Number of points

    Returns:
        Set of consistent point indices
    """
    candidates = set(range(n))
    for i, (obs, lvl) in enumerate(zip(observers, levels)):
        if lvl <= k and i in received:
            candidates = {p for p in candidates if obs[p] == received[i]}
    return candidates


def minimal_observer_basis(d: List[List[int]], n: int) -> Tuple[List[List[int]], List[int]]:
    """
    Construct a minimal observer basis for the given ultrametric.

    Uses one observer per non-trivial split in the dendrogram.
    Each internal node of the cluster tree contributes one observer
    that distinguishes its children.

    Time complexity: O(n² log n)

    Returns:
        (observers, levels) with minimal number of observers
    """
    # Find all distinct distance values (= merge heights)
    dist_values = sorted(set(d[i][j] for i in range(n) for j in range(n) if i != j))

    observers = []
    levels_out = []

    for dv in dist_values:
        # At this merge height, find the clusters at level dv-1
        # and the clusters at level dv
        clusters_below = []
        visited = set()
        for x in range(n):
            if x not in visited:
                cls = [y for y in range(n) if d[x][y] < dv]
                clusters_below.append(frozenset(cls))
                visited.update(cls)

        clusters_at = []
        visited = set()
        for x in range(n):
            if x not in visited:
                cls = [y for y in range(n) if d[x][y] <= dv]
                clusters_at.append(frozenset(cls))
                visited.update(cls)

        # For each cluster at level dv that merges multiple sub-clusters,
        # create an observer that labels each sub-cluster
        for cluster in clusters_at:
            sub_clusters = [c for c in clusters_below if c.issubset(cluster)]
            if len(sub_clusters) > 1:
                obs = [0] * n
                for label, sc in enumerate(sub_clusters):
                    for p in sc:
                        obs[p] = label
                observers.append(obs)
                levels_out.append(dv)

    return observers, levels_out


# ============================================================
# Self-test
# ============================================================
if __name__ == "__main__":
    # Test on binary tree
    d4 = [[0,1,2,2],[1,0,2,2],[2,2,0,1],[2,2,1,0]]
    ok, _ = verify_ultrametric(d4, 4)
    assert ok, "Binary tree should be ultrametric"

    obs, lvl = minimal_observer_basis(d4, 4)
    print("Minimal observer basis for 4-point binary tree:")
    for i, (o, l) in enumerate(zip(obs, lvl)):
        print(f"  Observer {i} (level {l}): {o}")

    # Verify separation
    for x, y in combinations(range(4), 2):
        sep = any(o[x] != o[y] for o in obs)
        assert sep, f"Points {x},{y} not separated!"
    print("All pairs separated ✓")

    # Test NPS
    nps = build_nested_partition(d4, 4)
    print("\nNested partition system:")
    for k, classes in sorted(nps.items()):
        print(f"  Level {k}: {classes}")

    # Test congruence decoder
    print("\nCongruence decoding test:")
    decoded = congruence_decode(obs, lvl, 1, {0: 0}, 4)
    print(f"  Received obs[0]=0 at level 1: candidates = {sorted(decoded)}")

    print("\nAll self-tests passed ✓")
