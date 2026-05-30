"""
Chromatic Capacity Theory: Core Algorithms

Implements the mathematical algorithms underlying chromatic capacity theory,
including chromatic polynomial computation, capacity calculation, and
tropical chromatic analysis.
"""

from math import log, factorial, comb
from typing import List, Dict, Set, Tuple, Optional
from dataclasses import dataclass


@dataclass
class EmotionalGraph:
    """A weighted graph modeling a social network with relationship strengths.
    
    Attributes:
        vertices: List of vertex labels
        edges: Set of (u, v) pairs representing edges
        weights: Dictionary mapping (u, v) to edge weight
    """
    vertices: List[str]
    edges: Set[Tuple[str, str]]
    weights: Dict[Tuple[str, str], float]
    
    def degree(self, v: str) -> int:
        """Return the degree of vertex v."""
        return sum(1 for u in self.vertices if (v, u) in self.edges or (u, v) in self.edges)
    
    def max_degree(self) -> int:
        """Return the maximum degree Delta(G)."""
        return max(self.degree(v) for v in self.vertices) if self.vertices else 0
    
    def neighbors(self, v: str) -> List[str]:
        """Return neighbors of vertex v."""
        return [u for u in self.vertices 
                if (v, u) in self.edges or (u, v) in self.edges]
    
    def total_weight(self) -> float:
        """Return the total edge weight."""
        return sum(self.weights.values())
    
    @classmethod
    def complete_graph(cls, n: int) -> 'EmotionalGraph':
        """Create K_n with unit weights."""
        vertices = [f"v{i}" for i in range(n)]
        edges = set()
        weights = {}
        for i in range(n):
            for j in range(i + 1, n):
                e = (vertices[i], vertices[j])
                edges.add(e)
                weights[e] = 1.0
        return cls(vertices, edges, weights)


def desc_factorial(k: int, n: int) -> int:
    """Compute k^{(n)} = k(k-1)...(k-n+1).
    
    Time complexity: O(n)
    Space complexity: O(1)
    
    >>> desc_factorial(5, 3)
    60
    >>> desc_factorial(10, 4)
    5040
    """
    result = 1
    for i in range(n):
        result *= (k - i)
    return result


def chromatic_poly_complete(n: int, k: int) -> int:
    """Compute P(K_n, k) = k^{(n)}, the chromatic polynomial of K_n.
    
    This counts the number of proper k-colorings of the complete graph K_n.
    Equivalent to the number of injective functions from n vertices to k colors.
    
    Time complexity: O(n)
    Space complexity: O(1)
    
    Args:
        n: Number of vertices
        k: Number of available colors
        
    Returns:
        Number of proper k-colorings
        
    >>> chromatic_poly_complete(3, 4)
    24
    >>> chromatic_poly_complete(5, 3)
    0
    """
    return desc_factorial(k, n)


def chromatic_capacity(n: int, k: int) -> float:
    """Compute C(K_n, k) = ln(k^{(n)}) / n.
    
    The chromatic capacity measures the information content per vertex
    in a coloring-based communication channel over K_n.
    
    Time complexity: O(n)
    Space complexity: O(1)
    
    Args:
        n: Number of vertices (> 0)
        k: Number of colors (>= n for non-trivial capacity)
        
    Returns:
        Chromatic capacity in nats (natural log units)
    """
    if n == 0:
        return 0.0
    df = desc_factorial(k, n)
    if df <= 0:
        return float('-inf')
    return log(df) / n


def tropical_chromatic_val(n: int, k: int) -> int:
    """Compute the tropical chromatic value T(n, k) = k - n + 1.
    
    In the tropical semiring (R ∪ {∞}, min, +), multiplication becomes
    addition and the product k(k-1)...(k-n+1) tropicalizes to
    min(k, k-1, ..., k-n+1) = k - n + 1.
    
    The sign of T(n,k) determines colorability:
    - T > 0: K_n is k-colorable
    - T = 0: threshold (k = n-1 colors, not enough)
    - T < 0: K_n is not k-colorable
    
    Time complexity: O(1)
    """
    if n == 0:
        return 0
    return k - n + 1


def greedy_coloring(graph: EmotionalGraph, num_colors: int) -> Optional[Dict[str, int]]:
    """Greedy graph coloring algorithm.
    
    Assigns colors 0, 1, ..., num_colors-1 to vertices such that
    adjacent vertices receive different colors.
    
    Time complexity: O(|V| * Δ) where Δ is the maximum degree
    Space complexity: O(|V|)
    
    Args:
        graph: The graph to color
        num_colors: Number of available colors
        
    Returns:
        A proper coloring dict, or None if greedy fails
    """
    coloring: Dict[str, int] = {}
    
    for v in graph.vertices:
        # Find colors used by neighbors
        used_colors: Set[int] = set()
        for u in graph.neighbors(v):
            if u in coloring:
                used_colors.add(coloring[u])
        
        # Assign smallest available color
        for c in range(num_colors):
            if c not in used_colors:
                coloring[v] = c
                break
        else:
            return None  # No color available
    
    return coloring


def weighted_diversity(graph: EmotionalGraph, coloring: Dict[str, int]) -> float:
    """Compute the weighted diversity of a coloring.
    
    For a proper coloring, this equals the total edge weight.
    For an improper coloring, monochromatic edges contribute 0.
    
    Time complexity: O(|E|)
    
    Args:
        graph: The emotional graph
        coloring: Color assignment for each vertex
        
    Returns:
        Sum of weights on edges between differently-colored vertices
    """
    diversity = 0.0
    for (u, v), w in graph.weights.items():
        if coloring.get(u) != coloring.get(v):
            diversity += w
    return diversity


def verify_factorial_divisibility(k: int, n: int) -> Tuple[int, int, bool]:
    """Verify that n! divides k^{(n)}.
    
    Returns (k^{(n)}, n!, divides_flag).
    """
    df = desc_factorial(k, n)
    fn = factorial(n)
    return df, fn, df % fn == 0


def verify_deficit_bound(k: int, n: int) -> Tuple[int, int, bool]:
    """Verify the deficit bound: k^n - k^{(n)} <= C(n,2) * k^{n-1}.
    
    Returns (deficit, bound, satisfies_flag).
    """
    pow_val = k ** n
    desc_val = desc_factorial(k, n)
    deficit = pow_val - desc_val
    bound = comb(n, 2) * (k ** (n - 1)) if n >= 1 else 0
    return deficit, bound, deficit <= bound


# Example usage
if __name__ == "__main__":
    print("=== Chromatic Polynomial of K_5 ===")
    for k in range(1, 11):
        p = chromatic_poly_complete(5, k)
        print(f"  P(K_5, {k:2d}) = {p:>8,}")
    
    print("\n=== Chromatic Capacity ===")
    for n in [2, 3, 5, 10]:
        cap = chromatic_capacity(n, 100)
        print(f"  C(K_{n:2d}, 100) = {cap:.4f} nats")
    
    print("\n=== Greedy Coloring ===")
    G = EmotionalGraph.complete_graph(4)
    coloring = greedy_coloring(G, 4)
    if coloring:
        print(f"  K_4 colored with 4 colors: {coloring}")
        div = weighted_diversity(G, coloring)
        print(f"  Weighted diversity: {div}")
    
    print("\n=== Factorial Divisibility ===")
    for n in [3, 4, 5]:
        for k in [n, n+1, 10]:
            df, fn, ok = verify_factorial_divisibility(k, n)
            print(f"  {fn}! | {k}^({n}) = {df}: {'✓' if ok else '✗'}")
