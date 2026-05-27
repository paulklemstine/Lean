"""
Tropical Tensor Distributivity: Algorithms

Implements the core algorithms from the formalization:
- Min-plus expression normalization (tropical distributive normal form)
- Weighted digraph encoding
- Floyd-Warshall shortest paths for comparison
- Path decomposition extraction

All algorithms mirror the Lean definitions in
Pythagorean/TropicalTensorDistributivity.lean
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Optional
import math


# ============================================================
# Min-Plus Expression AST
# ============================================================

@dataclass
class MPExpr:
    """Base class for min-plus expressions."""
    pass

@dataclass
class Atom(MPExpr):
    """A variable/edge weight reference."""
    index: int

    def __repr__(self):
        return f"x{self.index}"

@dataclass
class TMin(MPExpr):
    """Tropical addition: min(left, right)."""
    left: MPExpr
    right: MPExpr

    def __repr__(self):
        return f"min({self.left}, {self.right})"

@dataclass
class TPlus(MPExpr):
    """Tropical multiplication: left + right."""
    left: MPExpr
    right: MPExpr

    def __repr__(self):
        return f"({self.left} + {self.right})"


# ============================================================
# Evaluation
# ============================================================

def eval_z(expr: MPExpr, env: dict[int, float]) -> float:
    """Evaluate a min-plus expression with given variable assignments.

    Args:
        expr: The min-plus expression to evaluate.
        env: Mapping from atom indices to integer/float values.

    Returns:
        The evaluation result.

    Example:
        >>> env = {0: 3, 1: 5, 2: 2}
        >>> eval_z(TMin(Atom(0), TPlus(Atom(1), Atom(2))), env)
        3  # min(3, 5+2) = min(3, 7) = 3
    """
    if isinstance(expr, Atom):
        return env.get(expr.index, math.inf)
    elif isinstance(expr, TMin):
        return min(eval_z(expr.left, env), eval_z(expr.right, env))
    elif isinstance(expr, TPlus):
        return eval_z(expr.left, env) + eval_z(expr.right, env)
    else:
        raise ValueError(f"Unknown expression type: {type(expr)}")


# ============================================================
# Normalization (Tropical Distributive Normal Form)
# ============================================================

def dist_plus(a: MPExpr, b: MPExpr) -> MPExpr:
    """Distribute tplus over tmin.

    Implements the tropical distributive law:
        a + min(b, c) = min(a + b, a + c)

    This is the core rewriting operation.

    Args:
        a, b: Min-plus expressions to multiply (add) tropically.

    Returns:
        The distributed result.
    """
    if isinstance(b, TMin):
        return TMin(dist_plus(a, b.left), dist_plus(a, b.right))
    elif isinstance(a, TMin):
        return TMin(dist_plus(a.left, b), dist_plus(a.right, b))
    else:
        return TPlus(a, b)


def normalize(expr: MPExpr) -> MPExpr:
    """Normalize a min-plus expression to tropical normal form.

    The TNF is a tree of TMin nodes whose leaves are "path monomials"
    (expressions containing only Atom and TPlus).

    This implements the verified normalizer from the Lean development.

    Args:
        expr: The expression to normalize.

    Returns:
        The normalized expression in TNF.

    Example:
        >>> # a + min(b, c) normalizes to min(a+b, a+c)
        >>> e = TPlus(Atom(0), TMin(Atom(1), Atom(2)))
        >>> normalize(e)
        min((x0 + x1), (x0 + x2))
    """
    if isinstance(expr, Atom):
        return expr
    elif isinstance(expr, TMin):
        return TMin(normalize(expr.left), normalize(expr.right))
    elif isinstance(expr, TPlus):
        return dist_plus(normalize(expr.left), normalize(expr.right))
    else:
        raise ValueError(f"Unknown expression type: {type(expr)}")


# ============================================================
# Path Monomial Extraction
# ============================================================

def is_path_monomial(expr: MPExpr) -> bool:
    """Check if an expression is a path monomial (no TMin nodes)."""
    if isinstance(expr, Atom):
        return True
    elif isinstance(expr, TMin):
        return False
    elif isinstance(expr, TPlus):
        return is_path_monomial(expr.left) and is_path_monomial(expr.right)
    return False


def is_tropical_nf(expr: MPExpr) -> bool:
    """Check if an expression is in tropical normal form."""
    if isinstance(expr, Atom):
        return True
    elif isinstance(expr, TMin):
        return is_tropical_nf(expr.left) and is_tropical_nf(expr.right)
    elif isinstance(expr, TPlus):
        return is_path_monomial(expr.left) and is_path_monomial(expr.right)
    return False


def extract_monomials(expr: MPExpr) -> list[MPExpr]:
    """Extract all path monomials from an expression.

    For a TNF expression, returns the list of path monomials
    (the leaves of the TMin tree).
    """
    if isinstance(expr, Atom):
        return [expr]
    elif isinstance(expr, TMin):
        return extract_monomials(expr.left) + extract_monomials(expr.right)
    elif isinstance(expr, TPlus):
        return [expr]
    return []


def atom_list(expr: MPExpr) -> list[int]:
    """Extract atom indices from a path monomial."""
    if isinstance(expr, Atom):
        return [expr.index]
    elif isinstance(expr, TPlus):
        return atom_list(expr.left) + atom_list(expr.right)
    return []


# ============================================================
# Weighted Digraph
# ============================================================

class WeightedDigraph:
    """A weighted directed graph on n vertices.

    Attributes:
        n: Number of vertices.
        weights: n×n matrix of edge weights (math.inf for no edge).
    """

    def __init__(self, n: int, weights: Optional[list[list[float]]] = None):
        self.n = n
        if weights is None:
            self.weights = [[math.inf] * n for _ in range(n)]
        else:
            self.weights = weights

    def set_edge(self, i: int, j: int, w: float):
        """Set the weight of edge i → j."""
        self.weights[i][j] = w

    def get_weight(self, i: int, j: int) -> float:
        """Get the weight of edge i → j."""
        return self.weights[i][j]


# ============================================================
# Graph Encoding
# ============================================================

def encode_edge(n: int, i: int, j: int) -> int:
    """Encode edge (i,j) as a single atom index."""
    return i * n + j


def decode_edge(n: int, idx: int) -> tuple[int, int]:
    """Decode an atom index back to an edge (i,j)."""
    return idx // n, idx % n


def graph_env(G: WeightedDigraph) -> dict[int, float]:
    """Create the environment mapping atom indices to edge weights."""
    env = {}
    for i in range(G.n):
        for j in range(G.n):
            env[encode_edge(G.n, i, j)] = G.weights[i][j]
    return env


def single_hop_expr(n: int, i: int, j: int) -> MPExpr:
    """Build a min-plus expression for the direct path i → j."""
    return Atom(encode_edge(n, i, j))


def two_hop_expr(n: int, i: int, j: int) -> MPExpr:
    """Build a min-plus expression for two-hop paths i → ? → j.

    Returns min_k(w(i,k) + w(k,j)) over all intermediate vertices k.
    """
    if n == 0:
        raise ValueError("Graph must have at least one vertex")

    result = TPlus(
        Atom(encode_edge(n, i, 0)),
        Atom(encode_edge(n, 0, j))
    )
    for k in range(1, n):
        hop = TPlus(
            Atom(encode_edge(n, i, k)),
            Atom(encode_edge(n, k, j))
        )
        result = TMin(result, hop)
    return result


def k_hop_expr(n: int, i: int, j: int, k: int) -> MPExpr:
    """Build a min-plus expression for paths of exactly k hops from i to j.

    Uses recursive composition:
    - 1 hop: single_hop_expr(n, i, j)
    - k hops: min over intermediates m of (k-1 hop i→m) + (1 hop m→j)
    """
    if k == 1:
        return single_hop_expr(n, i, j)

    if n == 0:
        raise ValueError("Graph must have at least one vertex")

    result = TPlus(
        k_hop_expr(n, i, 0, k - 1),
        single_hop_expr(n, 0, j)
    )
    for m in range(1, n):
        hop = TPlus(
            k_hop_expr(n, i, m, k - 1),
            single_hop_expr(n, m, j)
        )
        result = TMin(result, hop)
    return result


# ============================================================
# Floyd-Warshall (for comparison)
# ============================================================

def floyd_warshall(G: WeightedDigraph) -> list[list[float]]:
    """Compute all-pairs shortest paths using Floyd-Warshall.

    Args:
        G: A weighted directed graph.

    Returns:
        n×n matrix of shortest path weights.

    Time complexity: O(n³)
    Space complexity: O(n²)
    """
    n = G.n
    dist = [row[:] for row in G.weights]

    # Self-loops have zero cost
    for i in range(n):
        dist[i][i] = 0

    for k in range(n):
        for i in range(n):
            for j in range(n):
                if dist[i][k] + dist[k][j] < dist[i][j]:
                    dist[i][j] = dist[i][k] + dist[k][j]

    return dist


# ============================================================
# Distributive Potential
# ============================================================

def top_sum_count(expr: MPExpr) -> int:
    """Count the number of monomials in the fully distributed form."""
    if isinstance(expr, Atom):
        return 1
    elif isinstance(expr, TMin):
        return top_sum_count(expr.left) + top_sum_count(expr.right)
    elif isinstance(expr, TPlus):
        return top_sum_count(expr.left) * top_sum_count(expr.right)
    return 1


def dist_potential(expr: MPExpr) -> int:
    """Compute the distributive potential of an expression.

    This is the semiring-independent termination measure.
    It equals 0 if and only if the expression is in TNF.
    """
    if isinstance(expr, Atom):
        return 0
    elif isinstance(expr, TMin):
        return dist_potential(expr.left) + dist_potential(expr.right)
    elif isinstance(expr, TPlus):
        dp1 = dist_potential(expr.left)
        dp2 = dist_potential(expr.right)
        sc1 = top_sum_count(expr.left)
        sc2 = top_sum_count(expr.right)
        return dp1 * sc2 + dp2 * sc1 + (sc1 * sc2 - 1)
    return 0


if __name__ == "__main__":
    # Quick demo
    print("=== Tropical Tensor Distributivity: Algorithms ===\n")

    # Create a small graph
    G = WeightedDigraph(3)
    G.set_edge(0, 1, 3)
    G.set_edge(1, 2, 2)
    G.set_edge(0, 2, 7)

    env = graph_env(G)

    # Build and normalize a two-hop expression
    expr = two_hop_expr(3, 0, 2)
    print(f"Two-hop expression 0→?→2: {expr}")
    print(f"Evaluation: {eval_z(expr, env)}")

    nf = normalize(expr)
    print(f"Normalized: {nf}")
    print(f"Normalized evaluation: {eval_z(nf, env)}")
    print(f"Is TNF: {is_tropical_nf(nf)}")

    # Floyd-Warshall comparison
    sp = floyd_warshall(G)
    print(f"\nFloyd-Warshall shortest paths:")
    for i in range(3):
        for j in range(3):
            print(f"  {i}→{j}: {sp[i][j]}")
