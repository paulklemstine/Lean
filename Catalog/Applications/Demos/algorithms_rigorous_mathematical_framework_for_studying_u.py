"""
Tropical Lyapunov Theory: Core Algorithms

Type-hinted implementations of the key algorithms from the Lyapunov
discrete dynamical system framework.
"""

from typing import Callable, Dict, List, Optional, Set, Tuple
import numpy as np


class LyapunovDDS:
    """A discrete dynamical system on a finite set with a Lyapunov potential.

    The system consists of:
    - A finite state space (integers 0..n-1)
    - A step function: state -> state
    - A potential function: state -> float (non-negative, non-increasing under step)
    """

    def __init__(self, n: int, step: Callable[[int], int], potential: Callable[[int], float]):
        self.n = n
        self.step = step
        self.potential = potential
        # Validate
        for x in range(n):
            assert potential(x) >= 0, f"Potential must be non-negative at {x}"
            assert potential(step(x)) <= potential(x) + 1e-12, \
                f"Potential must be non-increasing: V({x})={potential(x)}, V(step({x}))={potential(step(x))}"

    def iterate(self, x: int, n: int) -> int:
        """Iterate the dynamics n times starting from x."""
        for _ in range(n):
            x = self.step(x)
        return x

    def is_fixed(self, x: int) -> bool:
        """Check if x is a fixed point."""
        return self.step(x) == x

    def is_strictly_decreasing(self) -> bool:
        """Check if the system is strictly decreasing."""
        for x in range(self.n):
            if not self.is_fixed(x):
                if self.potential(self.step(x)) >= self.potential(x) - 1e-12:
                    return False
        return True

    def orbit(self, x: int) -> List[int]:
        """Compute the orbit of x until it reaches a fixed point."""
        path = [x]
        while not self.is_fixed(path[-1]):
            path.append(self.step(path[-1]))
            if len(path) > self.n + 1:
                raise ValueError("Orbit exceeded state space size (not strictly decreasing?)")
        return path

    def compute_basins(self) -> Dict[int, Set[int]]:
        """Compute the basin decomposition.

        Returns a dict mapping each fixed point to its basin of attraction.

        Algorithm: For each state, follow the orbit to its fixed point.
        Time complexity: O(n^2) worst case.
        """
        basins: Dict[int, Set[int]] = {}
        fixed_point_of: Dict[int, int] = {}

        for x in range(self.n):
            orb = self.orbit(x)
            fp = orb[-1]
            fixed_point_of[x] = fp
            if fp not in basins:
                basins[fp] = set()
            basins[fp].add(x)

        return basins

    def potential_gap(self) -> Optional[float]:
        """Compute the minimum potential gap delta among non-fixed points.

        Returns None if all points are fixed.
        """
        min_gap = float('inf')
        found_nonfixed = False
        for x in range(self.n):
            if not self.is_fixed(x):
                gap = self.potential(x) - self.potential(self.step(x))
                min_gap = min(min_gap, gap)
                found_nonfixed = True
        return min_gap if found_nonfixed else None

    def max_orbit_length(self) -> int:
        """Compute the maximum orbit length over all starting states."""
        return max(len(self.orbit(x)) - 1 for x in range(self.n))

    def convergence_rate_bound(self) -> Optional[float]:
        """Compute the convergence rate bound V_max / delta.

        Returns None if all points are fixed.
        """
        delta = self.potential_gap()
        if delta is None or delta <= 0:
            return None
        v_max = max(self.potential(x) for x in range(self.n))
        return v_max / delta


def tropical_gradient_flow(W: np.ndarray) -> LyapunovDDS:
    """Construct a LyapunovDDS from a tropical (max-plus) weight matrix.

    Each node moves to the neighbor with minimum depth, where depth is
    defined as the negative of the max incoming weight.

    Args:
        W: n x n weight matrix (non-negative entries)

    Returns:
        A LyapunovDDS where:
        - step(i) = argmin_{j : W[i,j] > 0, depth[j] < depth[i]} depth[j], or i if no such j
        - potential(i) = depth[i] = -max_j W[j, i] (shifted to be non-negative)
    """
    n = W.shape[0]

    # Depth: negative of max incoming weight (tropical "level")
    raw_depth = np.array([-np.max(W[:, i]) for i in range(n)])
    # Shift to be non-negative
    depth = raw_depth - np.min(raw_depth)

    def step(i: int) -> int:
        best_j = i
        best_depth = depth[i]
        for j in range(n):
            if W[i, j] > 0 and depth[j] < best_depth:
                best_j = j
                best_depth = depth[j]
        return best_j

    def potential(i: int) -> float:
        return float(depth[i])

    return LyapunovDDS(n, step, potential)


def compute_max_cycle_mean(W: np.ndarray) -> float:
    """Compute the maximum cycle mean (tropical eigenvalue) of a weight matrix.

    Uses Karp's algorithm: lambda(W) = max_i min_{0<=k<n} (d_n(i) - d_k(i)) / (n - k)
    where d_k(i) is the max weight of any walk of length k ending at i.

    Args:
        W: n x n weight matrix

    Returns:
        The maximum cycle mean lambda(W)
    """
    n = W.shape[0]

    # d[k][i] = max weight of any walk of length k ending at i
    d = np.full((n + 1, n), -np.inf)
    # Length 0: just sitting at node i, weight 0
    for i in range(n):
        d[0][i] = 0.0

    for k in range(1, n + 1):
        for i in range(n):
            for j in range(n):
                if d[k - 1][j] > -np.inf:
                    d[k][i] = max(d[k][i], d[k - 1][j] + W[j, i])

    # Karp's formula
    lambda_max = -np.inf
    for i in range(n):
        if d[n][i] > -np.inf:
            min_ratio = np.inf
            for k in range(n):
                if d[k][i] > -np.inf:
                    ratio = (d[n][i] - d[k][i]) / (n - k)
                    min_ratio = min(min_ratio, ratio)
            lambda_max = max(lambda_max, min_ratio)

    return lambda_max


def verify_conjecture_spectral_gap(n: int, num_trials: int = 100) -> Tuple[bool, List[dict]]:
    """Test the spectral gap conjecture: delta >= lambda(W) / n.

    Generates random weight matrices and checks whether the minimum
    potential gap in the induced tropical gradient flow is at least
    lambda(W) / n.

    Returns:
        (all_passed, results) where results is a list of dicts with
        details for each trial.
    """
    results = []
    all_passed = True

    for trial in range(num_trials):
        # Random non-negative weight matrix
        W = np.random.exponential(1.0, (n, n))
        np.fill_diagonal(W, 0)  # No self-loops

        flow = tropical_gradient_flow(W)
        delta = flow.potential_gap()
        lam = compute_max_cycle_mean(W)

        if delta is not None and lam > 0:
            ratio = delta * n / lam
            passed = ratio >= 1.0 - 1e-6
            if not passed:
                all_passed = False
        else:
            ratio = None
            passed = True  # Vacuously true

        results.append({
            'trial': trial,
            'n': n,
            'lambda': lam,
            'delta': delta,
            'ratio': ratio,
            'passed': passed,
        })

    return all_passed, results


if __name__ == "__main__":
    # Quick demonstration
    print("=== Tropical Lyapunov Theory: Algorithm Demo ===\n")

    # Example 1: Simple chain flow
    print("Example 1: Chain flow on 5 states")
    print("States: 0 -> 1 -> 2 -> 3 -> 4 (fixed)")
    print("Potential: [4, 3, 2, 1, 0]")

    chain = LyapunovDDS(
        n=5,
        step=lambda x: min(x + 1, 4),
        potential=lambda x: float(4 - x),
    )

    print(f"Strictly decreasing: {chain.is_strictly_decreasing()}")
    print(f"Basins: {chain.compute_basins()}")
    print(f"Max orbit length: {chain.max_orbit_length()}")
    print(f"Potential gap: {chain.potential_gap()}")
    print(f"Convergence rate bound: {chain.convergence_rate_bound()}")
    print()

    # Example 2: Binary tree flow
    print("Example 2: Binary tree flow (two basins)")
    print("States: 0,1 -> 2 (fixed);  3,4 -> 5 (fixed);  6 -> 2")

    def tree_step(x: int) -> int:
        mapping = {0: 2, 1: 2, 2: 2, 3: 5, 4: 5, 5: 5, 6: 2}
        return mapping[x]

    tree_potential = {0: 3.0, 1: 2.0, 2: 0.0, 3: 4.0, 4: 1.0, 5: 0.0, 6: 5.0}

    tree = LyapunovDDS(
        n=7,
        step=tree_step,
        potential=lambda x: tree_potential[x],
    )

    print(f"Strictly decreasing: {tree.is_strictly_decreasing()}")
    print(f"Basins: {tree.compute_basins()}")
    print(f"Max orbit length: {tree.max_orbit_length()}")
    print(f"Potential gap: {tree.potential_gap()}")
    print()

    # Example 3: Tropical gradient flow
    print("Example 3: Tropical gradient flow from weight matrix")
    W = np.array([
        [0, 3, 1, 0],
        [0, 0, 2, 4],
        [5, 0, 0, 1],
        [0, 0, 0, 0],
    ], dtype=float)
    print(f"W = \n{W}")

    flow = tropical_gradient_flow(W)
    print(f"Potentials: {[flow.potential(i) for i in range(4)]}")
    print(f"Steps: {[flow.step(i) for i in range(4)]}")
    print(f"Basins: {flow.compute_basins()}")

    lam = compute_max_cycle_mean(W)
    print(f"Max cycle mean λ(W) = {lam:.4f}")
    print()

    # Example 4: Spectral gap conjecture test
    print("Example 4: Testing spectral gap conjecture (n=5, 50 trials)")
    passed, results = verify_conjecture_spectral_gap(5, 50)
    valid = [r for r in results if r['ratio'] is not None]
    if valid:
        ratios = [r['ratio'] for r in valid]
        print(f"  Min ratio δ·n/λ = {min(ratios):.4f}")
        print(f"  Max ratio δ·n/λ = {max(ratios):.4f}")
        print(f"  All passed: {passed}")
    else:
        print("  No valid trials (all fixed points)")
