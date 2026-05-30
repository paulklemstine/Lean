"""
Algorithms for Culinary Homotopy Theory
========================================

Implements core algorithms for computing substitution graphs,
Hamming distances, fiber decompositions, and path-finding in
recipe space.
"""

import numpy as np
from collections import defaultdict, deque
from itertools import product
from typing import List, Tuple, Dict, Optional, Set


def hamming_distance(r1: np.ndarray, r2: np.ndarray) -> int:
    """
    Compute the Hamming distance between two recipes.

    Time complexity: O(n) where n = number of slots.
    Space complexity: O(1).

    >>> hamming_distance(np.array([0,1,2]), np.array([0,1,0]))
    1
    """
    return int(np.sum(r1 != r2))


def generate_recipe_space(n: int, m: int) -> np.ndarray:
    """
    Generate all recipes in the space Recipe(n, m) = (Fin m)^n.

    Time complexity: O(m^n * n).
    Space complexity: O(m^n * n).

    >>> len(generate_recipe_space(3, 2))
    8
    """
    return np.array(list(product(range(m), repeat=n)))


def substitution_neighbors(recipe: np.ndarray, m: int) -> List[np.ndarray]:
    """
    Find all neighbors of a recipe in the substitution graph.
    A neighbor differs in exactly one ingredient slot.

    Time complexity: O(n * m).
    Space complexity: O(n * (m-1)).

    Returns n*(m-1) neighbors.

    >>> len(substitution_neighbors(np.array([0,0,0]), 3))
    6
    """
    n = len(recipe)
    neighbors = []
    for i in range(n):
        for v in range(m):
            if v != recipe[i]:
                nbr = recipe.copy()
                nbr[i] = v
                neighbors.append(nbr)
    return neighbors


def hamming_ball(center: np.ndarray, radius: int, m: int) -> List[np.ndarray]:
    """
    Compute the Hamming ball of given radius around a center recipe.

    Uses BFS in the substitution graph, stopping at the given radius.

    Time complexity: O(sum_{k=0}^{r} C(n,k) * (m-1)^k * n * m).
    Space complexity: O(sum_{k=0}^{r} C(n,k) * (m-1)^k).
    """
    n = len(center)
    visited = {tuple(center)}
    current_layer = [center]
    all_in_ball = [center.copy()]

    for _ in range(radius):
        next_layer = []
        for recipe in current_layer:
            for nbr in substitution_neighbors(recipe, m):
                key = tuple(nbr)
                if key not in visited:
                    visited.add(key)
                    next_layer.append(nbr)
                    all_in_ball.append(nbr)
        current_layer = next_layer

    return all_in_ball


def shortest_substitution_path(
    r1: np.ndarray, r2: np.ndarray
) -> List[np.ndarray]:
    """
    Find the shortest substitution path from r1 to r2.

    The shortest path has length = hamming_distance(r1, r2),
    obtained by fixing one differing slot at each step.

    Time complexity: O(n).
    Space complexity: O(n^2).

    >>> path = shortest_substitution_path(np.array([0,0,0]), np.array([1,1,1]))
    >>> len(path)
    4
    """
    path = [r1.copy()]
    current = r1.copy()
    diff_positions = np.where(r1 != r2)[0]

    for pos in diff_positions:
        current = current.copy()
        current[pos] = r2[pos]
        path.append(current)

    return path


def fiber_decomposition(
    recipes: np.ndarray,
    flavor_fn,
    tolerance: float = 1e-8
) -> Dict[tuple, List[np.ndarray]]:
    """
    Decompose the recipe space into fibers of a flavor map.

    Time complexity: O(N * T_flavor) where N = number of recipes
    and T_flavor = cost of evaluating the flavor function.
    Space complexity: O(N).

    >>> recipes = generate_recipe_space(2, 2)
    >>> fibers = fiber_decomposition(recipes, lambda r: np.array([float(sum(r))]))
    >>> len(fibers)
    3
    """
    fibers = defaultdict(list)
    for r in recipes:
        fp = flavor_fn(r)
        key = tuple(np.round(fp / tolerance) * tolerance)
        fibers[key].append(r)
    return dict(fibers)


def substitution_graph_adjacency(n: int, m: int) -> Dict[tuple, List[tuple]]:
    """
    Build the full adjacency list of the substitution graph H(n,m).

    Time complexity: O(m^n * n * m).
    Space complexity: O(m^n * n * m).
    """
    recipes = generate_recipe_space(n, m)
    adj = defaultdict(list)
    for r in recipes:
        key = tuple(r)
        for nbr in substitution_neighbors(r, m):
            adj[key].append(tuple(nbr))
    return dict(adj)


def connected_components_in_fiber(
    fiber: List[np.ndarray], m: int
) -> List[List[np.ndarray]]:
    """
    Find connected components of a fiber under the substitution graph.

    Two recipes in the fiber are connected if there is a path between
    them that stays entirely within the fiber, using only single-ingredient
    substitutions.

    Time complexity: O(|fiber|^2 * n).
    Space complexity: O(|fiber|).
    """
    if not fiber:
        return []

    fiber_set = {tuple(r) for r in fiber}
    visited: Set[tuple] = set()
    components = []

    for r in fiber:
        key = tuple(r)
        if key in visited:
            continue
        # BFS from r
        component = []
        queue = deque([r])
        visited.add(key)
        while queue:
            current = queue.popleft()
            component.append(current)
            for nbr in substitution_neighbors(current, m):
                nbr_key = tuple(nbr)
                if nbr_key in fiber_set and nbr_key not in visited:
                    visited.add(nbr_key)
                    queue.append(nbr)
        components.append(component)

    return components


def lipschitz_constant(
    recipes: np.ndarray, flavor_fn
) -> float:
    """
    Compute the exact Lipschitz constant of a flavor map on the recipe space.

    K = max_{r1 != r2} ||F(r1) - F(r2)|| / hamming_distance(r1, r2)

    Time complexity: O(N^2 * (n + d)) where N = |recipes|.
    Space complexity: O(1) beyond input.
    """
    max_ratio = 0.0
    for i in range(len(recipes)):
        for j in range(i + 1, len(recipes)):
            hd = hamming_distance(recipes[i], recipes[j])
            if hd > 0:
                fd = np.linalg.norm(flavor_fn(recipes[i]) - flavor_fn(recipes[j]))
                ratio = fd / hd
                max_ratio = max(max_ratio, ratio)
    return max_ratio


def verify_triangle_inequality(n: int, m: int, num_samples: int = 1000) -> bool:
    """
    Verify the Hamming triangle inequality by random sampling.

    Returns True if no violations found.
    """
    recipes = generate_recipe_space(n, m)
    N = len(recipes)
    for _ in range(num_samples):
        idx = np.random.choice(N, 3, replace=True)
        r1, r2, r3 = recipes[idx[0]], recipes[idx[1]], recipes[idx[2]]
        d13 = hamming_distance(r1, r3)
        d12 = hamming_distance(r1, r2)
        d23 = hamming_distance(r2, r3)
        if d13 > d12 + d23:
            return False
    return True


# --- Example usage ---
if __name__ == "__main__":
    print("=== Algorithms Demo ===")

    # Recipe space
    n, m = 3, 2
    recipes = generate_recipe_space(n, m)
    print(f"Recipe space ({n},{m}): {len(recipes)} recipes")

    # Shortest path
    r1 = np.array([0, 0, 0])
    r2 = np.array([1, 1, 1])
    path = shortest_substitution_path(r1, r2)
    print(f"Shortest path {r1} -> {r2}: {[r.tolist() for r in path]}")

    # Hamming ball
    ball = hamming_ball(r1, 1, m)
    print(f"Hamming ball B({r1}, 1): {len(ball)} recipes")

    # Fiber decomposition
    W = np.array([[1.0, 0.5, -0.3]])
    fibers = fiber_decomposition(recipes, lambda r: W @ r.astype(float))
    print(f"Fibers under linear map: {len(fibers)} profiles")

    # Triangle inequality
    ok = verify_triangle_inequality(3, 3, 5000)
    print(f"Triangle inequality verified: {ok}")
