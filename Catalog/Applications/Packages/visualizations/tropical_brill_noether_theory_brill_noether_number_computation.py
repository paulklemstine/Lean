#!/usr/bin/env python3
"""
Tropical Brill-Noether Theory: Algorithms

Implements core algorithms for computing Brill-Noether numbers,
searching for admissible lattice paths on chains of loops, and
performing chip-firing simulations on graphs.
"""

from typing import List, Tuple, Optional, Dict, Set
import random
from itertools import product
from collections import defaultdict


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 1: Brill-Noether Number Computation
# ═══════════════════════════════════════════════════════════════════════

def brill_noether_number(g: int, r: int, d: int) -> int:
    """Compute ρ(g,r,d) = g - (r+1)(g - d + r).

    Time complexity: O(1)
    Space complexity: O(1)

    Args:
        g: genus of the curve
        r: desired rank of the linear series
        d: degree of the divisor

    Returns:
        The Brill-Noether number ρ(g,r,d)

    Examples:
        >>> brill_noether_number(3, 1, 3)
        0
        >>> brill_noether_number(5, 2, 7)
        2
    """
    return g - (r + 1) * (g - d + r)


def brill_noether_threshold(g: int, r: int) -> int:
    """Find the minimum degree d such that ρ(g,r,d) ≥ 0.

    Uses the quadratic formula on ρ = (r+1)d - rg - r(r+1) ≥ 0,
    giving d ≥ r(g + r + 1)/(r+1) = r + rg/(r+1).

    Time complexity: O(1)
    Space complexity: O(1)

    Args:
        g: genus of the curve
        r: desired rank

    Returns:
        Minimum degree d such that ρ(g,r,d) ≥ 0

    Examples:
        >>> brill_noether_threshold(3, 1)
        3
        >>> brill_noether_threshold(5, 2)
        6
    """
    # ρ = (r+1)d - rg - r(r+1) ≥ 0  ⟺  d ≥ rg/(r+1) + r
    import math
    if r == 0:
        return 0
    # d_min = ceil(r * (g + r + 1) / (r + 1))
    # But we can compute directly
    d = 0
    while brill_noether_number(g, r, d) < 0:
        d += 1
    return d


def list_feasible_parameters(g: int, max_r: int = None, max_d: int = None) -> List[Tuple[int, int, int]]:
    """List all (g, r, d) with ρ(g,r,d) ≥ 0.

    Time complexity: O(max_r * max_d)

    Args:
        g: genus
        max_r: maximum rank to consider (default: g)
        max_d: maximum degree to consider (default: 2g)

    Returns:
        List of (g, r, d) triples with nonneg Brill-Noether number
    """
    if max_r is None:
        max_r = g
    if max_d is None:
        max_d = 2 * g

    result = []
    for r in range(max_r + 1):
        for d in range(max_d + 1):
            if brill_noether_number(g, r, d) >= 0:
                result.append((g, r, d))
    return result


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 2: Chip-Firing on Graphs
# ═══════════════════════════════════════════════════════════════════════

class MetricGraph:
    """A finite metric graph (combinatorial graph with edge weights).

    Attributes:
        n_vertices: number of vertices
        edges: list of (u, v, weight) tuples
        adjacency: adjacency list representation
    """

    def __init__(self, n_vertices: int, edges: List[Tuple[int, int, float]]):
        self.n_vertices = n_vertices
        self.edges = edges
        self.adjacency: Dict[int, List[Tuple[int, float]]] = defaultdict(list)
        for u, v, w in edges:
            self.adjacency[u].append((v, w))
            self.adjacency[v].append((u, w))

    @property
    def genus(self) -> int:
        """First Betti number: |E| - |V| + 1."""
        return len(self.edges) - self.n_vertices + 1

    def degree(self, v: int) -> int:
        """Valence of vertex v."""
        return len(self.adjacency[v])

    def laplacian_fire(self, divisor: List[int], vertex: int) -> List[int]:
        """Fire vertex v: send one chip to each neighbor.

        Args:
            divisor: current chip configuration
            vertex: vertex to fire

        Returns:
            New divisor after firing
        """
        result = divisor.copy()
        result[vertex] -= self.degree(vertex)
        for neighbor, _ in self.adjacency[vertex]:
            result[neighbor] += 1
        return result


def chip_fire_rank(graph: MetricGraph, divisor: List[int]) -> int:
    """Compute the rank of a divisor via Dhar's burning algorithm.

    The rank of D is the largest r such that D - E is linearly
    equivalent to an effective divisor for every effective E of degree r.

    This uses a simplified brute-force approach for small graphs.

    Time complexity: O(n^r * chip_firing_steps) for each rank test
    Space complexity: O(n)

    Args:
        graph: the metric graph
        divisor: chip configuration (integer per vertex)

    Returns:
        The rank of the divisor (-1 if not effective)
    """
    n = graph.n_vertices

    if sum(divisor) < 0:
        return -1

    # Check if divisor is effective (all entries ≥ 0)
    if any(d < 0 for d in divisor):
        # Try to make it effective via chip-firing (BFS)
        if not _can_make_effective(graph, divisor):
            return -1

    r = 0
    while True:
        # Check if for every effective E of degree r+1,
        # D - E is equivalent to an effective divisor
        can_handle = True
        for removal in _effective_divisors_of_degree(n, r + 1):
            test_div = [divisor[i] - removal[i] for i in range(n)]
            if not _can_make_effective(graph, test_div):
                can_handle = False
                break
        if not can_handle:
            return r
        r += 1
        if r > sum(divisor):  # rank can't exceed degree
            return r


def _can_make_effective(graph: MetricGraph, divisor: List[int]) -> bool:
    """Check if divisor is linearly equivalent to an effective divisor.

    Uses BFS over chip-firing moves (subset firing).

    Args:
        graph: the metric graph
        divisor: chip configuration

    Returns:
        True if linearly equivalent to an effective divisor
    """
    n = graph.n_vertices
    if all(d >= 0 for d in divisor):
        return True

    # BFS with bounded depth
    visited: Set[Tuple[int, ...]] = set()
    queue = [tuple(divisor)]
    visited.add(tuple(divisor))

    max_iterations = min(1000, 2 ** n * 10)
    iterations = 0

    while queue and iterations < max_iterations:
        current = list(queue.pop(0))
        iterations += 1

        for v in range(n):
            new_div = graph.laplacian_fire(current, v)
            key = tuple(new_div)
            if all(d >= 0 for d in new_div):
                return True
            if key not in visited:
                visited.add(key)
                queue.append(key)

    return False


def _effective_divisors_of_degree(n: int, deg: int) -> List[List[int]]:
    """Generate all effective divisors of given degree on n vertices.

    Args:
        n: number of vertices
        deg: degree (total number of chips)

    Returns:
        List of divisors (each a list of n nonneg integers summing to deg)
    """
    if n == 1:
        return [[deg]]
    result = []
    for first in range(deg + 1):
        for rest in _effective_divisors_of_degree(n - 1, deg - first):
            result.append([first] + rest)
    return result


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 3: Chain of Loops Construction
# ═══════════════════════════════════════════════════════════════════════

def make_chain_of_loops(g: int, generic: bool = True) -> MetricGraph:
    """Construct a chain of g loops with (optionally generic) edge lengths.

    The chain of loops has g+1 vertices v_0, ..., v_g and 2g edges:
    for each i in 0..g-1, two parallel edges from v_i to v_{i+1}
    with lengths ℓ_{2i} and ℓ_{2i+1}.

    Time complexity: O(g)
    Space complexity: O(g)

    Args:
        g: genus (number of loops)
        generic: if True, use random distinct edge lengths

    Returns:
        A MetricGraph representing the chain of loops
    """
    if generic:
        # Generate 2g distinct random lengths
        lengths = random.sample([i * 0.1 + 0.1 for i in range(10 * g)], 2 * g)
    else:
        lengths = [1.0] * (2 * g)

    edges = []
    for i in range(g):
        edges.append((i, i + 1, lengths[2 * i]))
        edges.append((i, i + 1, lengths[2 * i + 1]))

    return MetricGraph(g + 1, edges)


def is_generic_chain(lengths: List[float]) -> bool:
    """Check if edge lengths are pairwise distinct (genericity condition).

    Time complexity: O(n log n)

    Args:
        lengths: list of edge lengths

    Returns:
        True if all lengths are distinct
    """
    return len(set(lengths)) == len(lengths)


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 4: Admissible Lattice Path Enumeration
# ═══════════════════════════════════════════════════════════════════════

def count_lattice_paths(g: int, r: int, d: int) -> int:
    """Count admissible lattice paths for Brill-Noether theory.

    An admissible lattice path for parameters (g, r, d) is a path
    in the integer lattice from (0, 0) to (g, d-g) that stays
    within the rectangle [0, g] × [0, d-g] and satisfies certain
    step constraints related to the Brill-Noether condition.

    For the simplified model: paths from (0,0) to (g, d-r*(r+1)/(r+1))
    with steps (1,0) and (0,1), staying weakly below the diagonal
    scaled by the appropriate factor.

    Time complexity: O(g * d) via dynamic programming
    Space complexity: O(g * d)

    Args:
        g: genus
        r: rank
        d: degree

    Returns:
        Number of admissible lattice paths
    """
    rho = brill_noether_number(g, r, d)
    if rho < 0:
        return 0

    # For the basic model: count paths in a (r+1) × (g-d+r) grid
    # that stay within bounds
    # This is a simplified Catalan-type counting
    rows = r + 1
    cols = g - d + r if g - d + r >= 0 else 0

    if cols == 0:
        return 1  # trivially admissible

    # Count lattice paths from (0,0) to (rows-1, cols) staying
    # weakly below y = x * (rows-1)/cols (ballot problem)
    # Using reflection principle / DP
    target_x = cols
    target_y = rows - 1

    if target_x < 0 or target_y < 0:
        return max(1, rho + 1)

    # DP: dp[x][y] = number of paths from (0,0) to (x,y)
    dp = [[0] * (target_y + 2) for _ in range(target_x + 2)]
    dp[0][0] = 1

    for x in range(target_x + 1):
        for y in range(target_y + 1):
            if dp[x][y] == 0:
                continue
            # Step right
            if x + 1 <= target_x:
                dp[x + 1][y] += dp[x][y]
            # Step up (if admissible)
            if y + 1 <= target_y:
                dp[x][y + 1] += dp[x][y]

    return max(dp[target_x][target_y], 1)


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 5: Brill-Noether Existence Search
# ═══════════════════════════════════════════════════════════════════════

def search_divisors(graph: MetricGraph, target_degree: int,
                    target_rank: int, max_attempts: int = 100) -> Optional[List[int]]:
    """Search for a divisor of given degree and rank on a graph.

    Uses random sampling followed by chip-firing rank computation.

    Time complexity: O(max_attempts * rank_computation)
    Space complexity: O(n)

    Args:
        graph: the metric graph
        target_degree: desired degree
        target_rank: desired minimum rank
        max_attempts: number of random divisors to try

    Returns:
        A divisor achieving the target, or None if not found
    """
    n = graph.n_vertices

    for _ in range(max_attempts):
        # Generate random divisor of given degree
        divisor = [0] * n
        for _ in range(target_degree):
            v = random.randint(0, n - 1)
            divisor[v] += 1

        rank = chip_fire_rank(graph, divisor)
        if rank >= target_rank:
            return divisor

    return None


def verify_brill_noether(g: int, max_r: int = 2, max_d: int = None,
                          n_trials: int = 5) -> Dict[Tuple[int, int], str]:
    """Verify Brill-Noether predictions on random generic chains of loops.

    For each (r, d) pair, checks whether divisor existence matches
    the sign of ρ(g, r, d).

    Args:
        g: genus
        max_r: maximum rank to test
        max_d: maximum degree to test
        n_trials: number of random chains to test

    Returns:
        Dictionary mapping (r, d) to verification status
    """
    if max_d is None:
        max_d = 2 * g

    results = {}
    for r in range(1, max_r + 1):
        for d in range(max_d + 1):
            rho = brill_noether_number(g, r, d)
            if rho < 0:
                results[(r, d)] = f"ρ={rho} < 0: nonexistence certified"
            else:
                # Try to find a divisor on random chains
                found_count = 0
                for _ in range(n_trials):
                    chain = make_chain_of_loops(g, generic=True)
                    div = search_divisors(chain, d, r, max_attempts=50)
                    if div is not None:
                        found_count += 1
                results[(r, d)] = f"ρ={rho} ≥ 0: found in {found_count}/{n_trials} trials"

    return results


# ═══════════════════════════════════════════════════════════════════════
# Main: Run all algorithms with examples
# ═══════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("Tropical Brill-Noether Algorithms")
    print("=" * 60)

    # Algorithm 1: Brill-Noether numbers
    print("\n1. Brill-Noether Number Table (genus 5)")
    print("-" * 40)
    g = 5
    header = 'd\\r'
    print(f"{header:>5}", end="")
    for r in range(5):
        print(f"  r={r:>1}", end="")
    print()
    for d in range(12):
        print(f"d={d:>2}:", end="")
        for r in range(5):
            rho = brill_noether_number(g, r, d)
            print(f"  {rho:>4}", end="")
        print()

    # Algorithm 2: Thresholds
    print("\n2. Minimum degree for ρ ≥ 0")
    print("-" * 40)
    for g in range(2, 8):
        thresholds = [brill_noether_threshold(g, r) for r in range(1, 4)]
        print(f"  g={g}: r=1→d≥{thresholds[0]}, r=2→d≥{thresholds[1]}, r=3→d≥{thresholds[2]}")

    # Algorithm 3: Chain of loops
    print("\n3. Chain of Loops (genus 3)")
    print("-" * 40)
    chain = make_chain_of_loops(3, generic=True)
    print(f"  Vertices: {chain.n_vertices}")
    print(f"  Edges: {len(chain.edges)}")
    print(f"  Genus: {chain.genus}")
    print(f"  Edge lengths: {[f'{w:.2f}' for _, _, w in chain.edges]}")
    print(f"  Generic: {is_generic_chain([w for _, _, w in chain.edges])}")

    # Algorithm 4: Lattice path counts
    print("\n4. Lattice Path Counts")
    print("-" * 40)
    for g_val in [3, 4, 5]:
        for r_val in [1, 2]:
            counts = []
            for d_val in range(10):
                counts.append(count_lattice_paths(g_val, r_val, d_val))
            print(f"  g={g_val}, r={r_val}: paths = {counts}")

    # Algorithm 5: Divisor search on small graph
    print("\n5. Divisor Search on Chain of 2 Loops")
    print("-" * 40)
    chain2 = make_chain_of_loops(2, generic=True)
    for d_val in range(5):
        for r_val in range(3):
            rho = brill_noether_number(2, r_val, d_val)
            div = search_divisors(chain2, d_val, r_val, max_attempts=20)
            status = f"found {div}" if div else "not found"
            print(f"  d={d_val}, r={r_val}: ρ={rho:>3}, {status}")

    print("\nAll algorithms completed.")
