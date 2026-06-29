#!/usr/bin/env python3
"""
Algorithms for Spectral Theory of Exchange Graphs

Implements certified methods to:
- Build exchange graphs from finite examples
- Compute shell statistics and log-concavity
- Estimate/verify conductance surrogates
- Compute Laplacian spectra
- Test the depth-conductance-spectral chain

Type hints and docstrings throughout.
"""

import numpy as np
from typing import List, Tuple, Dict, Callable, Optional


# ─────────────────────────────────────────────────────────────
# Algorithm 1: Exchange Graph Builder
# ─────────────────────────────────────────────────────────────

class ExchangeGraph:
    """A finite exchange graph with potential function.

    Attributes:
        n: number of vertices
        adj: adjacency matrix (n x n, symmetric, 0-1)
        potential: potential values at each vertex
        states: list of state objects
    """

    def __init__(self, states: list, potential: Dict, adj_fn: Callable):
        """Build exchange graph.

        Args:
            states: list of states
            potential: dict state -> float
            adj_fn: (state, state) -> bool adjacency predicate

        Time complexity: O(n^2) for n = len(states)
        Space complexity: O(n^2)
        """
        self.states = list(states)
        self.n = len(self.states)
        self.adj = np.zeros((self.n, self.n))
        self.potential = np.array([potential[s] for s in self.states])

        for i in range(self.n):
            for j in range(i + 1, self.n):
                if adj_fn(self.states[i], self.states[j]):
                    self.adj[i, j] = 1.0
                    self.adj[j, i] = 1.0

    @property
    def max_degree(self) -> float:
        """Maximum vertex degree. O(n)."""
        return float(self.adj.sum(axis=1).max())

    @property
    def degrees(self) -> np.ndarray:
        """Degree sequence. O(n)."""
        return self.adj.sum(axis=1)


# ─────────────────────────────────────────────────────────────
# Algorithm 2: Shell Decomposition
# ─────────────────────────────────────────────────────────────

def compute_shells(G: ExchangeGraph) -> Tuple[List[float], List[int]]:
    """Decompose the state space into potential shells.

    Returns:
        (shell_values, shell_counts) where shell_values[i] is the
        potential value and shell_counts[i] is the number of states
        with that potential.

    Time: O(n log n)
    Space: O(n)
    """
    unique_vals = sorted(set(G.potential.tolist()))
    counts = []
    for v in unique_vals:
        counts.append(int(np.sum(np.abs(G.potential - v) < 1e-10)))
    return unique_vals, counts


def check_log_concavity(seq: List[float]) -> Tuple[bool, List[int]]:
    """Check if a positive sequence is log-concave.

    Returns:
        (is_log_concave, violation_indices) where violation_indices
        lists positions where a[i]^2 < a[i-1]*a[i+1].

    Time: O(len(seq))
    """
    violations = []
    for i in range(1, len(seq) - 1):
        if seq[i] ** 2 < seq[i - 1] * seq[i + 1] - 1e-10:
            violations.append(i)
    return len(violations) == 0, violations


def shell_ratios(seq: List[float]) -> List[float]:
    """Compute consecutive ratios a[i+1]/a[i].

    Time: O(len(seq))
    """
    ratios = []
    for i in range(len(seq) - 1):
        if seq[i] > 0:
            ratios.append(seq[i + 1] / seq[i])
        else:
            ratios.append(float('inf'))
    return ratios


def check_ratio_monotonicity(ratios: List[float]) -> bool:
    """Check if ratios are non-increasing (log-concavity consequence).

    Time: O(len(ratios))
    """
    for i in range(len(ratios) - 1):
        if ratios[i + 1] > ratios[i] + 1e-10:
            return False
    return True


# ─────────────────────────────────────────────────────────────
# Algorithm 3: Depth Decrement Computation
# ─────────────────────────────────────────────────────────────

def compute_depth_decrement(G: ExchangeGraph) -> float:
    """Compute the empirical depth decrement δ.

    δ = min over non-optimal states x of
        max over neighbors y of (Φ(x) - Φ(y))

    Time: O(n^2) for dense graphs, O(n * max_degree) for sparse
    Space: O(1)
    """
    min_pot = G.potential.min()
    delta = float('inf')

    for i in range(G.n):
        if G.potential[i] <= min_pot + 1e-10:
            continue
        best_decrease = 0.0
        for j in range(G.n):
            if G.adj[i, j] > 0:
                decrease = G.potential[i] - G.potential[j]
                best_decrease = max(best_decrease, decrease)
        if best_decrease > 0:
            delta = min(delta, best_decrease)

    return delta if delta < float('inf') else 0.0


def catalog_depth_decrement(d: int, k: int, c: float = 1.0) -> float:
    """Catalog depth decrement: c / d^(d-k).

    Args:
        d: dimension
        k: certificate depth (0 ≤ k ≤ d)
        c: scaling constant

    Time: O(1)
    """
    if d == 0:
        return c
    return c / (d ** (d - k))


# ─────────────────────────────────────────────────────────────
# Algorithm 4: Laplacian Spectrum
# ─────────────────────────────────────────────────────────────

def compute_spectrum(G: ExchangeGraph) -> np.ndarray:
    """Compute the normalized Laplacian spectrum.

    Uses L_norm = D^{-1/2} (D - A) D^{-1/2} where D is the degree matrix.

    Time: O(n^3) via eigendecomposition
    Space: O(n^2)

    Returns sorted eigenvalues.
    """
    degrees = G.degrees
    n = G.n
    D_inv_sqrt = np.zeros(n)
    for i in range(n):
        if degrees[i] > 0:
            D_inv_sqrt[i] = 1.0 / np.sqrt(degrees[i])

    D_mat = np.diag(degrees)
    L = D_mat - G.adj
    D_inv_sqrt_mat = np.diag(D_inv_sqrt)
    L_norm = D_inv_sqrt_mat @ L @ D_inv_sqrt_mat

    eigenvalues = np.sort(np.linalg.eigvalsh(L_norm))
    return eigenvalues


def spectral_gap(G: ExchangeGraph) -> float:
    """Compute the spectral gap λ₂ (second-smallest eigenvalue of L_norm).

    Time: O(n^3)
    """
    evals = compute_spectrum(G)
    return float(evals[1]) if len(evals) > 1 else 0.0


# ─────────────────────────────────────────────────────────────
# Algorithm 5: Conductance (Cheeger Constant)
# ─────────────────────────────────────────────────────────────

def compute_conductance_exact(G: ExchangeGraph) -> float:
    """Compute exact Cheeger constant by exhaustive enumeration.

    h(G) = min_{S: 0 < vol(S) ≤ vol(V)/2} |E(S, S^c)| / vol(S)

    Time: O(2^n * n^2) — only feasible for n ≤ 20
    Space: O(n)
    """
    degrees = G.degrees
    total_vol = degrees.sum()
    best_h = float('inf')

    for mask in range(1, 2 ** G.n):
        S = [i for i in range(G.n) if mask & (1 << i)]
        vol_S = sum(degrees[i] for i in S)
        if vol_S <= 0 or vol_S > total_vol / 2:
            continue
        Sc = [i for i in range(G.n) if not (mask & (1 << i))]
        boundary = sum(G.adj[i, j] for i in S for j in Sc)
        h = boundary / vol_S
        best_h = min(best_h, h)

    return best_h if best_h < float('inf') else 0.0


def compute_conductance_approx(G: ExchangeGraph, trials: int = 5000) -> float:
    """Approximate Cheeger constant by random sampling.

    Time: O(trials * n^2)
    Space: O(n)
    """
    degrees = G.degrees
    total_vol = degrees.sum()
    best_h = float('inf')

    for _ in range(trials):
        k = np.random.randint(1, G.n)
        S = list(np.random.choice(G.n, k, replace=False))
        vol_S = sum(degrees[i] for i in S)
        if vol_S <= 0 or vol_S > total_vol / 2:
            continue
        Sc = [i for i in range(G.n) if i not in set(S)]
        boundary = sum(G.adj[i, j] for i in S for j in Sc)
        h = boundary / vol_S
        best_h = min(best_h, h)

    return best_h if best_h < float('inf') else 0.0


# ─────────────────────────────────────────────────────────────
# Algorithm 6: Spectral Lower Bound Chain
# ─────────────────────────────────────────────────────────────

def spectral_lower_bound(delta: float, D: float) -> float:
    """Compute the spectral lower bound δ²/(2D²).

    This is the Cheeger-squared bound: if conductance h ≥ δ/D,
    then λ₂ ≥ h²/2 ≥ δ²/(2D²).

    Time: O(1)
    """
    if D <= 0:
        return 0.0
    return delta ** 2 / (2 * D ** 2)


def verify_spectral_chain(G: ExchangeGraph) -> Dict:
    """Run the full spectral verification chain on an exchange graph.

    Returns a dict with all computed quantities and verification results.

    Time: O(2^n * n^2 + n^3) for exact conductance, O(n^3) otherwise
    """
    # Basic quantities
    D = G.max_degree
    delta = compute_depth_decrement(G)
    vals, counts = compute_shells(G)
    is_lc, violations = check_log_concavity(counts)
    ratios = shell_ratios(counts)
    ratio_mono = check_ratio_monotonicity(ratios)

    # Spectral
    evals = compute_spectrum(G)
    lam2 = float(evals[1]) if len(evals) > 1 else 0.0

    # Conductance (exact for small, approx for large)
    if G.n <= 18:
        h = compute_conductance_exact(G)
    else:
        h = compute_conductance_approx(G)

    # Bounds
    slb = spectral_lower_bound(delta, D)
    cheeger_bound = h ** 2 / 2

    return {
        'n': G.n,
        'max_degree': D,
        'depth_decrement': delta,
        'shell_values': vals,
        'shell_counts': counts,
        'shell_ratios': ratios,
        'log_concave': is_lc,
        'lc_violations': violations,
        'ratio_monotone': ratio_mono,
        'eigenvalues': evals.tolist(),
        'spectral_gap': lam2,
        'conductance': h,
        'spectral_lower_bound': slb,
        'cheeger_bound': cheeger_bound,
        'cheeger_verified': lam2 >= cheeger_bound - 1e-10,
        'slb_verified': lam2 >= slb - 1e-10,
        'linear_ratio': lam2 * D / delta if delta > 0 else float('inf'),
    }


# ─────────────────────────────────────────────────────────────
# Algorithm 7: Mixing Time Estimation
# ─────────────────────────────────────────────────────────────

def mixing_time_bound(spectral_gap_val: float, n: int) -> float:
    """Upper bound on mixing time: (1/λ₂) · ln(n).

    Time: O(1)
    """
    if spectral_gap_val <= 0:
        return float('inf')
    return (1.0 / spectral_gap_val) * np.log(n)


def simulate_random_walk(G: ExchangeGraph, start: int,
                         steps: int = 1000, lazy: bool = True) -> List[int]:
    """Simulate a (lazy) random walk on the exchange graph.

    At each step:
    - With prob 1/2 stay (if lazy)
    - Otherwise, move to a uniform random neighbor

    Time: O(steps * max_degree)
    """
    trajectory = [start]
    current = start
    for _ in range(steps):
        if lazy and np.random.random() < 0.5:
            trajectory.append(current)
            continue
        neighbors = np.where(G.adj[current] > 0)[0]
        if len(neighbors) == 0:
            trajectory.append(current)
            continue
        current = int(np.random.choice(neighbors))
        trajectory.append(current)
    return trajectory


# ─────────────────────────────────────────────────────────────
# Example usage
# ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    # Build a hypercube Q_4
    from itertools import product as iprod
    states = list(iprod([0, 1], repeat=4))
    potential = {s: float(sum(s)) for s in states}
    adj_fn = lambda x, y: sum(abs(x[i] - y[i]) for i in range(4)) == 1

    G = ExchangeGraph(states, potential, adj_fn)
    result = verify_spectral_chain(G)

    print("Hypercube Q_4 verification:")
    for key, val in result.items():
        if key == 'eigenvalues':
            print(f"  {key}: [{', '.join(f'{v:.4f}' for v in val[:6])}...]")
        else:
            print(f"  {key}: {val}")
