"""
Algorithms for Semantic Entropy Theory.

Implements model counting, entropy computation, and chain-length lower bounds
for finite theories, coordinate constraint systems, and graph coloring.
"""

import math
from itertools import product
from typing import List, Tuple, Set, Dict, Optional
from dataclasses import dataclass


@dataclass
class FiniteTheory:
    """A finite theory represented by its set of models."""
    models: frozenset

    @property
    def model_count(self) -> int:
        return len(self.models)

    @property
    def semantic_entropy(self) -> float:
        """Semantic entropy H(T) = log2(|models|)."""
        if self.model_count == 0:
            return float('-inf')
        return math.log2(self.model_count)

    def strengthens(self, other: 'FiniteTheory') -> bool:
        """Check if self strengthens other (self.models ⊆ other.models)."""
        return self.models.issubset(other.models)

    def elimination_cost(self, target: 'FiniteTheory') -> int:
        """Number of models eliminated when going from self to target."""
        return len(self.models - target.models)


def coord_theory(n: int, fixed_coords: set) -> FiniteTheory:
    """
    Coordinate theory on {0,1}^n: models are bitstrings with bit=1 at all
    positions in fixed_coords.

    Args:
        n: Length of bitstrings.
        fixed_coords: Set of indices that must be 1.

    Returns:
        FiniteTheory with models = {f ∈ {0,1}^n : f(i)=1 for all i ∈ fixed_coords}

    Complexity: O(2^n) for enumeration.

    Example:
        >>> t = coord_theory(3, {0})
        >>> t.model_count
        4
        >>> t.semantic_entropy
        2.0
    """
    models = set()
    for bits in product([0, 1], repeat=n):
        if all(bits[i] == 1 for i in fixed_coords):
            models.add(bits)
    return FiniteTheory(frozenset(models))


def coord_model_count(n: int, k: int) -> int:
    """
    Exact model count for coordinate theory with k fixed coordinates.

    Returns 2^(n-k). O(1) time.

    Args:
        n: Total number of coordinates.
        k: Number of fixed coordinates.

    Returns:
        2^(n-k) if k <= n, else 0.

    Example:
        >>> coord_model_count(10, 3)
        128
    """
    if k > n:
        return 0
    return 2 ** (n - k)


def semantic_entropy(model_count: int) -> float:
    """
    Compute semantic entropy from model count.

    H = log2(model_count).

    Args:
        model_count: Number of models (must be positive).

    Returns:
        log2(model_count), or -inf if model_count is 0.

    Example:
        >>> semantic_entropy(1024)
        10.0
    """
    if model_count <= 0:
        return float('-inf')
    return math.log2(model_count)


def chain_length_lower_bound(start_count: int, end_count: int) -> float:
    """
    Lower bound on bounded-halving chain length from entropy drop.

    Any chain where each step removes at most half the models needs at least
    floor(log2(start_count / end_count)) steps.

    Args:
        start_count: Model count of the starting theory.
        end_count: Model count of the ending theory.

    Returns:
        floor(log2(start_count / end_count)), or inf if end_count is 0.

    Complexity: O(1).

    Example:
        >>> chain_length_lower_bound(1024, 32)
        5.0
    """
    if end_count <= 0:
        return float('inf')
    if start_count <= end_count:
        return 0.0
    return math.floor(math.log2(start_count / end_count))


def graph_colorings(n_vertices: int, edges: List[Tuple[int, int]], q: int) -> FiniteTheory:
    """
    Compute the coloring theory for a graph with q colors.

    Args:
        n_vertices: Number of vertices (labeled 0, ..., n_vertices-1).
        edges: List of (u, v) edges.
        q: Number of colors.

    Returns:
        FiniteTheory whose models are proper q-colorings.

    Complexity: O(q^n * |E|).

    Example:
        >>> t = graph_colorings(3, [(0,1), (1,2)], 3)
        >>> t.model_count
        12
    """
    models = set()
    for coloring in product(range(q), repeat=n_vertices):
        proper = True
        for u, v in edges:
            if coloring[u] == coloring[v]:
                proper = False
                break
        if proper:
            models.add(coloring)
    return FiniteTheory(frozenset(models))


def path_graph_edges(n: int) -> List[Tuple[int, int]]:
    """Edges of the path graph P_n on vertices 0, ..., n-1."""
    return [(i, i + 1) for i in range(n - 1)]


def path_coloring_count(n: int, q: int) -> int:
    """
    Exact number of proper q-colorings of the path P_n.

    Formula: q * (q-1)^(n-1) for n >= 1.

    Example:
        >>> path_coloring_count(4, 3)
        24
    """
    if n <= 0:
        return 0
    if n == 1:
        return q
    return q * (q - 1) ** (n - 1)


def cycle_graph_edges(n: int) -> List[Tuple[int, int]]:
    """Edges of the cycle graph C_n on vertices 0, ..., n-1."""
    edges = [(i, (i + 1) % n) for i in range(n)]
    return edges


def cycle_coloring_count(n: int, q: int) -> int:
    """
    Exact number of proper q-colorings of the cycle C_n.

    Formula: (q-1)^n + (-1)^n * (q-1) for n >= 3.

    Example:
        >>> cycle_coloring_count(4, 3)
        18
    """
    if n < 3:
        return 0
    return (q - 1) ** n + ((-1) ** n) * (q - 1)


def verify_halving_chain(chain: List[FiniteTheory]) -> bool:
    """
    Verify that a sequence of theories forms a valid bounded-halving chain.

    Checks:
    1. Monotonicity: each step's models are a subset of the previous step's.
    2. Bounded shrinkage: each step removes at most half the models.

    Args:
        chain: List of FiniteTheory objects.

    Returns:
        True if the chain is a valid bounded-halving chain.

    Example:
        >>> chain = [coord_theory(4, set(range(i))) for i in range(5)]
        >>> verify_halving_chain(chain)
        True
    """
    for i in range(len(chain) - 1):
        if not chain[i + 1].models.issubset(chain[i].models):
            return False
        if chain[i].model_count > 2 * chain[i + 1].model_count:
            return False
    return True


def random_cnf_models(n_vars: int, clauses: List[List[int]]) -> FiniteTheory:
    """
    Compute the model set for a CNF formula.

    Args:
        n_vars: Number of Boolean variables.
        clauses: List of clauses. Each clause is a list of literals,
                 where positive int i means variable i, negative means ¬variable |i|.
                 Variables are 1-indexed.

    Returns:
        FiniteTheory whose models are satisfying assignments.

    Example:
        >>> t = random_cnf_models(3, [[1, 2], [-1, 3]])
        >>> t.model_count > 0
        True
    """
    models = set()
    for assignment in product([False, True], repeat=n_vars):
        satisfies_all = True
        for clause in clauses:
            satisfies_clause = False
            for lit in clause:
                var_idx = abs(lit) - 1
                val = assignment[var_idx]
                if (lit > 0 and val) or (lit < 0 and not val):
                    satisfies_clause = True
                    break
            if not satisfies_clause:
                satisfies_all = False
                break
        if satisfies_all:
            models.add(assignment)
    return FiniteTheory(frozenset(models))


def entropy_drop_analysis(theories: List[FiniteTheory]) -> Dict:
    """
    Analyze a sequence of strengthening theories.

    Returns entropy values, drops, and chain length lower bounds.

    Args:
        theories: List of theories forming a strengthening chain.

    Returns:
        Dictionary with analysis results.
    """
    results = {
        'model_counts': [],
        'entropies': [],
        'cumulative_drops': [],
        'chain_lower_bounds': [],
        'is_valid_chain': True,
    }

    if not theories:
        return results

    base_entropy = theories[0].semantic_entropy
    base_count = theories[0].model_count

    for i, theory in enumerate(theories):
        mc = theory.model_count
        ent = theory.semantic_entropy
        drop = base_entropy - ent if ent > float('-inf') else float('inf')
        lb = chain_length_lower_bound(base_count, mc)

        results['model_counts'].append(mc)
        results['entropies'].append(ent)
        results['cumulative_drops'].append(drop)
        results['chain_lower_bounds'].append(lb)

        if i > 0:
            if not theory.models.issubset(theories[i - 1].models):
                results['is_valid_chain'] = False

    return results


if __name__ == "__main__":
    # Quick self-test
    print("=== Algorithms Self-Test ===\n")

    # Coordinate theories
    print("Coordinate theory tests:")
    for n in [4, 8]:
        for k in range(n + 1):
            t = coord_theory(n, set(range(k)))
            exact = coord_model_count(n, k)
            assert t.model_count == exact, f"Mismatch: n={n}, k={k}"
        print(f"  n={n}: all {n+1} theories verified ✓")

    # Path coloring
    print("\nPath coloring tests:")
    for n in [2, 3, 4, 5]:
        for q in [2, 3, 4]:
            t = graph_colorings(n, path_graph_edges(n), q)
            exact = path_coloring_count(n, q)
            assert t.model_count == exact, f"Mismatch: P_{n}, q={q}"
    print("  All path coloring counts verified ✓")

    # Chain verification
    print("\nChain verification:")
    chain = [coord_theory(6, set(range(k))) for k in range(7)]
    assert verify_halving_chain(chain), "Chain should be valid"
    print("  Halving chain verified ✓")

    # Entropy analysis
    analysis = entropy_drop_analysis(chain)
    print(f"  Entropy drops: {[f'{d:.1f}' for d in analysis['cumulative_drops']]}")
    print(f"  Lower bounds:  {analysis['chain_lower_bounds']}")

    print("\nAll tests passed ✓")
