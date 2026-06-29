#!/usr/bin/env python3
"""
Algorithms for Recipe Substitution Spaces

Type-hinted implementations of the core algorithms from the
Homotopy Type Theory of Cooking Recipes research.
"""

import itertools
import numpy as np
from typing import Tuple, List, Set, Dict, Optional, Callable
from collections import defaultdict, deque
from math import comb


# Type aliases
Recipe = Tuple[int, ...]
FlavorProfile = np.ndarray


def hamming_distance(r1: Recipe, r2: Recipe) -> int:
    """Compute Hamming distance between two recipes.

    Time: O(n) where n = len(r1)
    """
    return sum(1 for a, b in zip(r1, r2) if a != b)


def diff_slots(r1: Recipe, r2: Recipe) -> List[int]:
    """Return the set of slots where two recipes differ.

    Time: O(n)
    """
    return [i for i, (a, b) in enumerate(zip(r1, r2)) if a != b]


def translate_recipe(recipe: Recipe, offset: Recipe, m: int) -> Recipe:
    """Translate a recipe by componentwise addition mod m.

    Implements the vertex transitivity automorphism.
    Time: O(n)
    """
    return tuple((r + o) % m for r, o in zip(recipe, offset))


def spectrum_count(n: int, m: int, k: int) -> int:
    """Number of recipes at Hamming distance exactly k from any fixed recipe.

    Returns C(n,k) * (m-1)^k.

    Pseudocode:
        SPECTRUM-COUNT(n, m, k):
            return BINOMIAL(n, k) * (m-1)^k
    """
    return comb(n, k) * (m - 1) ** k


def full_spectrum(n: int, m: int) -> List[int]:
    """Compute the full Hamming distance spectrum.

    Returns [spectrum_count(n, m, k) for k = 0, ..., n].
    Sum equals m^n by the binomial theorem.
    """
    return [spectrum_count(n, m, k) for k in range(n + 1)]


class AdditiveFlavorMap:
    """An additive flavor map: flavor = sum of per-slot contributions.

    Attributes:
        n: Number of ingredient slots
        m: Number of choices per slot
        d: Number of flavor dimensions
        contrib: contrib[i][v] is a d-dimensional vector for slot i, choice v
    """

    def __init__(self, n: int, m: int, d: int,
                 contrib: Optional[Dict[int, Dict[int, np.ndarray]]] = None):
        self.n = n
        self.m = m
        self.d = d
        if contrib is None:
            # Random initialization
            self.contrib = {
                i: {v: np.random.randn(d) for v in range(m)}
                for i in range(n)
            }
        else:
            self.contrib = contrib

    def evaluate(self, recipe: Recipe) -> FlavorProfile:
        """Evaluate the flavor map on a recipe.

        Time: O(n * d)
        """
        result = np.zeros(self.d)
        for i, v in enumerate(recipe):
            result += self.contrib[i][v]
        return result

    def slot_change_effect(self, slot: int, old_val: int, new_val: int) -> FlavorProfile:
        """Compute the flavor change from a single-slot substitution.

        By the slot independence theorem, this is:
            contrib[slot][new_val] - contrib[slot][old_val]

        Time: O(d)
        """
        return self.contrib[slot][new_val] - self.contrib[slot][old_val]


def build_substitution_graph(n: int, m: int) -> Dict[Recipe, Set[Recipe]]:
    """Build the substitution graph adjacency list.

    Time: O(n * m^n * (m-1))
    Space: O(n * (m-1) * m^n)

    Pseudocode:
        BUILD-SUBST-GRAPH(n, m):
            for each recipe r in Recipe(n, m):
                for each slot i in 0..n-1:
                    for each value v in 0..m-1, v ≠ r[i]:
                        add edge (r, update(r, i, v))
    """
    adj: Dict[Recipe, Set[Recipe]] = defaultdict(set)
    for recipe in itertools.product(range(m), repeat=n):
        for slot in range(n):
            for val in range(m):
                if val != recipe[slot]:
                    neighbor = tuple(
                        val if i == slot else recipe[i]
                        for i in range(n)
                    )
                    adj[recipe].add(neighbor)
    return dict(adj)


def find_geodesics(r1: Recipe, r2: Recipe, m: int) -> List[List[Recipe]]:
    """Enumerate all shortest paths (geodesics) between two recipes.

    By the geodesic factorization theorem, the number of shortest paths
    equals k! where k = hamming_distance(r1, r2).

    Pseudocode:
        FIND-GEODESICS(r1, r2):
            slots = diff_slots(r1, r2)
            for each permutation π of slots:
                path = [r1]
                current = r1
                for i in π:
                    current = update(current, i, r2[i])
                    path.append(current)
                yield path
    """
    slots = diff_slots(r1, r2)
    paths = []
    for perm in itertools.permutations(slots):
        path = [r1]
        current = list(r1)
        for slot in perm:
            current[slot] = r2[slot]
            path.append(tuple(current))
        paths.append(path)
    return paths


def nearest_recipe_additive(
    target_flavor: FlavorProfile,
    flavor_map: AdditiveFlavorMap
) -> Recipe:
    """Find the recipe closest to a target flavor under an additive map.

    Uses the decomposition: optimize each slot independently.

    Time: O(n * m * d)  (vs O(m^n * d) for brute force)

    Pseudocode:
        NEAREST-RECIPE-ADDITIVE(target, A):
            residual = target
            recipe = []
            # Greedy per-slot optimization
            for i in 0..n-1:
                best_val = argmin_v ||residual - contrib[i][v]||
                recipe[i] = best_val
                residual -= contrib[i][best_val]
            return recipe
    """
    n, m, d = flavor_map.n, flavor_map.m, flavor_map.d
    # For additive maps, optimize each slot independently
    # by choosing the value that minimizes the per-slot residual
    recipe = []
    for i in range(n):
        best_val = 0
        best_norm = float('inf')
        # Project target onto this slot's contribution space
        for v in range(m):
            # Simple greedy: choose value with contribution closest to
            # the per-slot share of the target
            contrib = flavor_map.contrib[i][v]
            norm = np.linalg.norm(contrib - target_flavor / n)
            if norm < best_norm:
                best_norm = norm
                best_val = v
        recipe.append(best_val)
    return tuple(recipe)


def fiber_bfs(
    start: Recipe,
    flavor_map: AdditiveFlavorMap,
    target_flavor: FlavorProfile,
    tol: float = 1e-10
) -> Set[Recipe]:
    """BFS to find all recipes in a flavor fiber connected to start.

    Time: O(|fiber| * n * m)
    """
    visited: Set[Recipe] = set()
    queue: deque = deque([start])
    visited.add(start)
    n, m = flavor_map.n, flavor_map.m

    while queue:
        current = queue.popleft()
        for slot in range(n):
            for val in range(m):
                if val != current[slot]:
                    neighbor = tuple(
                        val if i == slot else current[i]
                        for i in range(n)
                    )
                    if neighbor not in visited:
                        flavor = flavor_map.evaluate(neighbor)
                        if np.linalg.norm(flavor - target_flavor) < tol:
                            visited.add(neighbor)
                            queue.append(neighbor)
    return visited


def check_fiber_connectivity(
    n: int, m: int, d: int,
    num_trials: int = 100
) -> Tuple[int, int]:
    """Check fiber connectivity conjecture for random additive flavor maps.

    Returns (connected_fibers, total_nonempty_fibers).
    """
    connected = 0
    total = 0

    for _ in range(num_trials):
        fmap = AdditiveFlavorMap(n, m, d)
        # Group all recipes into fibers
        fibers: Dict[str, List[Recipe]] = defaultdict(list)
        for recipe in itertools.product(range(m), repeat=n):
            flavor = fmap.evaluate(recipe)
            key = str(np.round(flavor, 8))
            fibers[key].append(recipe)

        for key, recipes in fibers.items():
            if len(recipes) > 1:
                total += 1
                # Check connectivity via BFS
                target = fmap.evaluate(recipes[0])
                reachable = fiber_bfs(recipes[0], fmap, target)
                if len(reachable) == len(recipes):
                    connected += 1

    return connected, total


def count_triangles_efficient(n: int, m: int) -> int:
    """Count triangles in SubstGraph(n, m).

    For the Hamming graph, the triangle count is:
    - 0 if m < 3
    - n * C(m, 3) * m^(n-1) if m >= 3
      (choose a slot, choose 3 values at that slot, fill the rest)

    Time: O(1)
    """
    if m < 3:
        return 0
    return n * comb(m, 3) * (m ** (n - 1))


if __name__ == "__main__":
    # Quick self-test
    print("Self-testing algorithms...")

    # Test Hamming distance
    assert hamming_distance((0, 1, 2), (0, 1, 2)) == 0
    assert hamming_distance((0, 1, 2), (1, 1, 2)) == 1
    assert hamming_distance((0, 1, 2), (1, 0, 1)) == 3

    # Test spectrum
    assert sum(full_spectrum(5, 3)) == 3**5

    # Test geodesics
    paths = find_geodesics((0, 0, 0), (1, 1, 0), 2)
    assert len(paths) == 2  # 2! = 2 paths

    # Test triangle count
    assert count_triangles_efficient(3, 2) == 0
    assert count_triangles_efficient(1, 3) > 0

    print("All self-tests passed!")
