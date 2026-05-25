"""
Algorithms for computing transversal numbers of hypergraphs.

Implements:
- Fractional transversal number τ* via linear programming
- Integer transversal number τ via integer linear programming
- Edge-sensitivity computation (1-Lipschitz verification)
- Random hypergraph generation (Erdős–Rényi k-uniform model)

All algorithms include type hints, docstrings, and example usage.
"""

import numpy as np
from itertools import combinations
from typing import List, Set, Tuple, Optional
from scipy.optimize import linprog

try:
    from scipy.optimize import milp, LinearConstraint, Bounds
    HAS_MILP = True
except ImportError:
    HAS_MILP = False


class Hypergraph:
    """A finite hypergraph on vertex set {0, 1, ..., n-1}.

    Attributes:
        n: Number of vertices
        edges: List of edges, each edge is a frozenset of vertex indices
    """

    def __init__(self, n: int, edges: List[frozenset]):
        self.n = n
        self.edges = list(set(edges))  # deduplicate

    def add_edge(self, e: frozenset) -> 'Hypergraph':
        """Return a new hypergraph with edge e added."""
        new_edges = list(set(self.edges + [e]))
        return Hypergraph(self.n, new_edges)

    def is_k_uniform(self) -> Optional[int]:
        """Return k if the hypergraph is k-uniform, else None."""
        if not self.edges:
            return None
        k = len(self.edges[0])
        if all(len(e) == k for e in self.edges):
            return k
        return None

    def __repr__(self) -> str:
        return f"Hypergraph(n={self.n}, |E|={len(self.edges)})"


def random_k_uniform_hypergraph(n: int, k: int, p: float,
                                 rng: Optional[np.random.Generator] = None) -> Hypergraph:
    """Generate a random k-uniform hypergraph H_k(n, p).

    Each k-subset of {0, ..., n-1} is included independently with probability p.

    Args:
        n: Number of vertices
        k: Uniformity parameter (edge size)
        p: Edge inclusion probability
        rng: Random number generator (optional)

    Returns:
        A random k-uniform hypergraph

    Example:
        >>> rng = np.random.default_rng(42)
        >>> H = random_k_uniform_hypergraph(10, 3, 0.3, rng)
        >>> print(H)
        Hypergraph(n=10, |E|=...)
    """
    if rng is None:
        rng = np.random.default_rng()

    edges = []
    for combo in combinations(range(n), k):
        if rng.random() < p:
            edges.append(frozenset(combo))
    return Hypergraph(n, edges)


def sparse_random_hypergraph(n: int, k: int, c: float,
                              rng: Optional[np.random.Generator] = None) -> Hypergraph:
    """Generate a sparse random k-uniform hypergraph with p = c / n^{k-1}.

    Args:
        n: Number of vertices
        k: Uniformity parameter
        c: Sparsity constant (c > 0)
        rng: Random number generator

    Returns:
        A random k-uniform hypergraph in the sparse regime
    """
    p = c / (n ** (k - 1))
    p = min(p, 1.0)
    return random_k_uniform_hypergraph(n, k, p, rng)


def fractional_transversal_number(H: Hypergraph) -> float:
    """Compute the fractional transversal number τ*(H) via linear programming.

    Solves: minimize Σ x(v) subject to Σ_{v∈e} x(v) ≥ 1 for all e, x ≥ 0.

    Args:
        H: A hypergraph

    Returns:
        The fractional transversal number τ*(H)

    Example:
        >>> H = Hypergraph(4, [frozenset({0,1}), frozenset({1,2}), frozenset({2,3})])
        >>> tau_star = fractional_transversal_number(H)
        >>> print(f"τ* = {tau_star:.4f}")
        τ* = 1.5000
    """
    n = H.n
    m = len(H.edges)

    if m == 0:
        return 0.0

    # Objective: minimize Σ x(v)
    c = np.ones(n)

    # Constraints: Σ_{v∈e} x(v) ≥ 1 for each edge e
    # linprog uses A_ub x <= b_ub, so we negate: -Σ_{v∈e} x(v) <= -1
    A_ub = np.zeros((m, n))
    for i, edge in enumerate(H.edges):
        for v in edge:
            A_ub[i, v] = -1.0
    b_ub = -np.ones(m)

    # Bounds: x(v) >= 0
    bounds = [(0, None)] * n

    result = linprog(c, A_ub=A_ub, b_ub=b_ub, bounds=bounds, method='highs')

    if result.success:
        return result.fun
    else:
        raise ValueError(f"LP solver failed: {result.message}")


def integer_transversal_number(H: Hypergraph) -> int:
    """Compute the integer transversal number τ(H).

    Uses MILP if available, otherwise brute-force search.

    Args:
        H: A hypergraph

    Returns:
        The integer transversal number τ(H)

    Example:
        >>> H = Hypergraph(4, [frozenset({0,1}), frozenset({1,2}), frozenset({2,3})])
        >>> tau = integer_transversal_number(H)
        >>> print(f"τ = {tau}")
        τ = 2
    """
    n = H.n
    m = len(H.edges)

    if m == 0:
        return 0

    if HAS_MILP and n > 15:
        return _integer_transversal_milp(H)
    else:
        return _integer_transversal_brute(H)


def _integer_transversal_milp(H: Hypergraph) -> int:
    """Compute τ(H) via mixed-integer linear programming."""
    n = H.n
    m = len(H.edges)

    c = np.ones(n)

    A = np.zeros((m, n))
    for i, edge in enumerate(H.edges):
        for v in edge:
            A[i, v] = 1.0

    constraints = LinearConstraint(A, lb=1.0)
    integrality = np.ones(n)  # all variables are integer
    bounds = Bounds(lb=0, ub=1)

    from scipy.optimize import milp
    result = milp(c, constraints=constraints, integrality=integrality, bounds=bounds)

    if result.success:
        return int(round(result.fun))
    else:
        raise ValueError(f"MILP solver failed: {result.message}")


def _integer_transversal_brute(H: Hypergraph) -> int:
    """Compute τ(H) by brute-force enumeration of vertex subsets."""
    n = H.n
    for size in range(n + 1):
        for subset in combinations(range(n), size):
            s = set(subset)
            if all(s & set(e) for e in H.edges):
                return size
    return n


def edge_sensitivity(H: Hypergraph, e: frozenset) -> float:
    """Compute τ*(H ∪ {e}) - τ*(H), verifying the 1-Lipschitz bound.

    Args:
        H: A hypergraph
        e: An edge to add

    Returns:
        The change in τ* when adding edge e

    Example:
        >>> H = Hypergraph(5, [frozenset({0,1,2})])
        >>> delta = edge_sensitivity(H, frozenset({2,3,4}))
        >>> assert 0 <= delta <= 1, "1-Lipschitz violated!"
    """
    tau_before = fractional_transversal_number(H)
    tau_after = fractional_transversal_number(H.add_edge(e))
    delta = tau_after - tau_before
    assert -1e-8 <= delta <= 1 + 1e-8, \
        f"1-Lipschitz bound violated: Δτ* = {delta}"
    return delta


def variance_estimator(samples: List[float]) -> float:
    """Compute the sample variance of a list of values.

    Args:
        samples: List of numerical values

    Returns:
        Sample variance (using Bessel's correction)
    """
    arr = np.array(samples)
    return float(np.var(arr, ddof=1))


def concentration_experiment(n: int, k: int, c: float, num_samples: int = 1000,
                              seed: int = 42) -> dict:
    """Run a concentration experiment: sample random hypergraphs and compute variances.

    Args:
        n: Number of vertices
        k: Uniformity parameter
        c: Sparsity constant (p = c/n^{k-1})
        num_samples: Number of random samples
        seed: Random seed

    Returns:
        Dictionary with keys: 'n', 'k', 'c', 'tau_star_mean', 'tau_star_var',
        'tau_mean', 'tau_var', 'var_ratio', 'samples_tau_star', 'samples_tau'
    """
    rng = np.random.default_rng(seed)
    tau_stars = []
    taus = []

    for _ in range(num_samples):
        H = sparse_random_hypergraph(n, k, c, rng)
        tau_stars.append(fractional_transversal_number(H))
        if n <= 25:
            taus.append(integer_transversal_number(H))

    result = {
        'n': n,
        'k': k,
        'c': c,
        'num_samples': num_samples,
        'tau_star_mean': float(np.mean(tau_stars)),
        'tau_star_var': variance_estimator(tau_stars),
        'samples_tau_star': tau_stars,
    }

    if taus:
        result['tau_mean'] = float(np.mean(taus))
        result['tau_var'] = variance_estimator(taus)
        result['var_ratio'] = result['tau_var'] / max(result['tau_star_var'], 1e-10)
        result['samples_tau'] = taus

    return result


if __name__ == "__main__":
    print("=== Algorithms for Hypergraph Transversal Numbers ===\n")

    # Example 1: Simple hypergraph
    H = Hypergraph(5, [frozenset({0,1,2}), frozenset({2,3,4}), frozenset({0,3})])
    print(f"H = {H}")
    print(f"τ*(H) = {fractional_transversal_number(H):.4f}")
    print(f"τ(H)  = {integer_transversal_number(H)}")
    print()

    # Example 2: Edge sensitivity
    e_new = frozenset({1,4})
    delta = edge_sensitivity(H, e_new)
    print(f"Adding edge {set(e_new)}: Δτ* = {delta:.4f}")
    print(f"1-Lipschitz bound satisfied: {abs(delta) <= 1 + 1e-8}")
    print()

    # Example 3: Random hypergraph
    rng = np.random.default_rng(42)
    H_rand = sparse_random_hypergraph(20, 3, 2.0, rng)
    print(f"Random H_3(20, 2/n²) = {H_rand}")
    print(f"τ*(H) = {fractional_transversal_number(H_rand):.4f}")
    print(f"τ(H)  = {integer_transversal_number(H_rand)}")
    print()

    # Example 4: Small concentration experiment
    print("Running small concentration experiment (n=15, 100 samples)...")
    result = concentration_experiment(15, 3, 2.0, num_samples=100, seed=42)
    print(f"  E[τ*] = {result['tau_star_mean']:.3f}")
    print(f"  Var(τ*) = {result['tau_star_var']:.3f}")
    if 'tau_mean' in result:
        print(f"  E[τ]  = {result['tau_mean']:.3f}")
        print(f"  Var(τ) = {result['tau_var']:.3f}")
        print(f"  Var(τ)/Var(τ*) = {result['var_ratio']:.3f}")
