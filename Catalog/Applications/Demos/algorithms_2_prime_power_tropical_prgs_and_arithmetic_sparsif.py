#!/usr/bin/env python3
"""
Algorithms for Prime-Power Tropical PRGs and Arithmetic Sparsification.

Implements the core algorithms from the research paper:
1. GeometricErrorAccumulator — tracks cumulative error with uniform bound
2. PrimePowerOrbitSampler — samples tropical orbits at prime-power indices
3. DecorrelationAnalyzer — analyzes fiber decorrelation decay
4. PRGQualityComparator — compares dense vs prime-power orbit quality
"""

from dataclasses import dataclass
from typing import Callable, List, Optional, Tuple
import numpy as np


@dataclass
class GeometricDecayParams:
    """Parameters for a geometrically decaying error sequence.

    Attributes:
        eps0: Initial error bound (eps0 >= 0)
        r: Contraction rate (0 <= r < 1)
    """
    eps0: float
    r: float

    def __post_init__(self):
        assert self.eps0 >= 0, f"eps0 must be non-negative, got {self.eps0}"
        assert 0 <= self.r < 1, f"r must be in [0, 1), got {self.r}"

    @property
    def uniform_bound(self) -> float:
        """The uniform cumulative error bound eps0 / (1 - r)."""
        return self.eps0 / (1 - self.r)

    def stage_bound(self, j: int) -> float:
        """Bound on error at stage j: eps0 * r^j."""
        return self.eps0 * self.r ** j

    def partial_sum_bound(self, T: int) -> float:
        """Exact partial sum bound: eps0 * (1 - r^(T+1)) / (1 - r)."""
        return self.eps0 * (1 - self.r ** (T + 1)) / (1 - self.r)


class GeometricErrorAccumulator:
    """Tracks cumulative extraction error with a uniform bound guarantee.

    Implements the prime_power_geometric_error_bound theorem:
    if err(j+1) <= r * err(j) and err(0) <= eps0,
    then sum_{j=0}^T err(j) <= eps0 / (1 - r) for all T.

    Time complexity: O(1) per step, O(T) total
    Space complexity: O(1) (streaming)
    """

    def __init__(self, params: GeometricDecayParams):
        self.params = params
        self._cumulative = 0.0
        self._current_bound = params.eps0
        self._step = 0

    def add_error(self, err: float) -> Tuple[float, float]:
        """Add one stage error and return (cumulative, uniform_bound).

        Args:
            err: The error at this stage. Must satisfy err <= current_bound.

        Returns:
            Tuple of (cumulative_error, uniform_bound).

        Raises:
            ValueError: If err exceeds the geometric bound.
        """
        bound = self.params.stage_bound(self._step)
        if err > bound + 1e-10:
            raise ValueError(
                f"Error {err} at step {self._step} exceeds bound {bound}"
            )
        self._cumulative += err
        self._step += 1
        return self._cumulative, self.params.uniform_bound

    @property
    def cumulative_error(self) -> float:
        return self._cumulative

    @property
    def remaining_budget(self) -> float:
        """How much error budget remains: uniform_bound - cumulative."""
        return self.params.uniform_bound - self._cumulative


class PrimePowerOrbitSampler:
    """Samples a dynamical orbit at prime-power indices.

    Given a map G and initial state x0, produces the sequence:
        x0, G^p(x0), G^{p^2}(x0), ..., G^{p^T}(x0)

    This implements the arithmetic sparsification strategy that
    achieves uniform-in-T error bounds.

    Time complexity: O(p^T) per full orbit computation
    Space complexity: O(T) for storing samples
    """

    def __init__(self, G: Callable, p: int):
        """
        Args:
            G: The dynamical map (state -> state)
            p: Prime base for power indices
        """
        self.G = G
        self.p = p
        assert self._is_prime(p), f"{p} is not prime"

    @staticmethod
    def _is_prime(n: int) -> bool:
        if n < 2:
            return False
        for i in range(2, int(n**0.5) + 1):
            if n % i == 0:
                return False
        return True

    def sample_orbit(self, x0, T: int) -> list:
        """Sample orbit at prime-power indices p^0, p^1, ..., p^T.

        Args:
            x0: Initial state
            T: Maximum exponent

        Returns:
            List of states [G^{p^0}(x0), G^{p^1}(x0), ..., G^{p^T}(x0)]
        """
        samples = []
        state = x0
        # Apply G once to get G^1(x0) = G^{p^0}(x0)
        state = self.G(x0)
        samples.append(state)

        current_power = 1  # Currently at G^1
        for j in range(1, T + 1):
            target = self.p ** j
            # Apply G enough times to reach G^{p^j}
            for _ in range(target - current_power):
                state = self.G(state)
            current_power = target
            samples.append(state)

        return samples

    def sample_orbit_efficient(self, x0, T: int) -> list:
        """Efficiently sample using repeated squaring principle.

        For each step j -> j+1, apply G^{p^j * (p-1)} times
        (since p^{j+1} = p * p^j, we need p-1 more applications of G^{p^j}).

        This is still O(p^T) but organized by stages.
        """
        samples = []
        state = x0

        # Stage 0: apply G once
        state = self.G(state)
        samples.append(state)

        for j in range(1, T + 1):
            # Need to go from G^{p^{j-1}} to G^{p^j}
            # That's (p-1) * p^{j-1} additional applications
            additional = (self.p - 1) * (self.p ** (j - 1))
            for _ in range(additional):
                state = self.G(state)
            samples.append(state)

        return samples


class DecorrelationAnalyzer:
    """Analyzes fiber decorrelation decay along prime-power indices.

    Implements the prime_power_fiber_decorrelation_row_bound theorem:
    for any fixed i, sum_j C(p^i, p^j) <= C0 * (2/(1-rho) - 1).
    """

    def __init__(self, C: Callable[[int, int], float], p: int):
        """
        Args:
            C: Collision/overlap statistic C(n, m) -> R
            p: Prime base
        """
        self.C = C
        self.p = p

    def row_sum(self, i: int, T: int) -> float:
        """Compute sum_j C(p^i, p^j) for j = 0, ..., T."""
        return sum(
            self.C(self.p**i, self.p**j) for j in range(T + 1)
        )

    def estimate_decay_rate(self, max_gap: int = 20) -> Tuple[float, float]:
        """Estimate C0 and rho from the collision statistic.

        Returns:
            (C0, rho) estimated from C(1, p^k) for k = 0, ..., max_gap
        """
        values = [self.C(1, self.p**k) for k in range(max_gap + 1)]
        C0 = values[0]
        if C0 <= 0:
            return 0.0, 0.0

        # Estimate rho from consecutive ratios
        ratios = []
        for k in range(1, len(values)):
            if values[k - 1] > 1e-15:
                ratios.append(values[k] / values[k - 1])

        if ratios:
            rho = np.median(ratios)
            return C0, max(0.0, min(rho, 0.9999))
        return C0, 0.0

    def verify_row_bound(self, C0: float, rho: float,
                         i: int, T: int) -> Tuple[float, float, bool]:
        """Verify the row bound for given parameters.

        Returns:
            (row_sum, bound, is_satisfied)
        """
        rs = self.row_sum(i, T)
        bound = C0 * (2 / (1 - rho) - 1)
        return rs, bound, rs <= bound + 1e-10


class PRGQualityComparator:
    """Compares prime-power vs dense orbit PRG quality.

    Implements prime_power_beats_dense_orbit:
    eps0/(1-r) < (T+1)*eps0 when T+1 > 1/(1-r).
    """

    def __init__(self, params: GeometricDecayParams):
        self.params = params

    @property
    def crossover_T(self) -> float:
        """The threshold T above which prime-power wins: 1/(1-r) - 1."""
        return 1 / (1 - self.params.r) - 1

    def dense_bound(self, T: int) -> float:
        """Dense orbit bound: (T+1) * eps0."""
        return (T + 1) * self.params.eps0

    def prime_power_bound(self) -> float:
        """Prime-power bound: eps0 / (1-r)."""
        return self.params.uniform_bound

    def improvement_ratio(self, T: int) -> float:
        """Ratio of dense/prime-power bounds (> 1 means PP is better)."""
        pp = self.prime_power_bound()
        if pp <= 0:
            return float('inf')
        return self.dense_bound(T) / pp

    def generate_comparison_table(self, T_values: List[int]) -> list:
        """Generate a comparison table for multiple T values."""
        results = []
        for T in T_values:
            results.append({
                'T': T,
                'dense_bound': self.dense_bound(T),
                'pp_bound': self.prime_power_bound(),
                'ratio': self.improvement_ratio(T),
                'pp_wins': self.prime_power_bound() < self.dense_bound(T)
            })
        return results


def tropical_max_plus_map(weights: np.ndarray):
    """Create a tropical (max-plus) linear map.

    In tropical algebra, multiplication becomes addition and
    addition becomes max. A tropical linear map is:
        G(x)_i = max_j (weights_{i,j} + x_j)

    Args:
        weights: Weight matrix for the tropical map

    Returns:
        A function implementing the tropical map
    """
    def G(x: np.ndarray) -> np.ndarray:
        n = len(x)
        result = np.zeros(n)
        for i in range(n):
            result[i] = max(weights[i, j] + x[j] for j in range(n))
        return result
    return G


def demo_tropical_prg():
    """Complete demonstration of a tropical max-plus PRG."""
    print("=" * 60)
    print("TROPICAL MAX-PLUS PRG DEMONSTRATION")
    print("=" * 60)

    # Create a 4x4 tropical map with contractive properties
    np.random.seed(42)
    n = 4
    weights = np.random.uniform(-1, 1, (n, n))

    G = tropical_max_plus_map(weights)
    p = 2

    sampler = PrimePowerOrbitSampler(G, p)

    # Initial state
    x0 = np.zeros(n)

    # Sample at prime powers
    T = 6
    orbit = sampler.sample_orbit_efficient(x0, T)

    print(f"\n  Map dimension: {n}x{n}")
    print(f"  Prime: p = {p}")
    print(f"  Orbit length: T = {T}")
    print(f"\n  {'Stage j':<10} {'p^j':<10} {'State (truncated)'}")
    print(f"  {'-'*50}")
    for j, state in enumerate(orbit):
        state_str = np.array2string(state, precision=3, suppress_small=True)
        print(f"  {j:<10} {p**j:<10} {state_str}")

    # Demonstrate error tracking
    params = GeometricDecayParams(eps0=0.1, r=0.5)
    acc = GeometricErrorAccumulator(params)

    print(f"\n  Error tracking (eps0={params.eps0}, r={params.r}):")
    print(f"  {'Step':<8} {'Error':<15} {'Cumulative':<15} {'Budget Left':<15}")
    print(f"  {'-'*53}")
    for j in range(T + 1):
        err = params.stage_bound(j)  # Simulated error
        cum, bound = acc.add_error(err)
        print(f"  {j:<8} {err:<15.8f} {cum:<15.8f} {acc.remaining_budget:<15.8f}")

    print(f"\n  Uniform bound: {params.uniform_bound:.6f}")
    print(f"  Final cumulative: {acc.cumulative_error:.6f}")
    print()


if __name__ == "__main__":
    demo_tropical_prg()

    # Quick comparison demo
    params = GeometricDecayParams(eps0=0.01, r=0.8)
    comparator = PRGQualityComparator(params)
    print(f"Crossover T: {comparator.crossover_T:.1f}")
    table = comparator.generate_comparison_table([1, 5, 10, 20, 50, 100])
    for row in table:
        print(f"  T={row['T']:<4} dense={row['dense_bound']:.4f}  "
              f"pp={row['pp_bound']:.4f}  "
              f"ratio={row['ratio']:.2f}x  "
              f"{'PP WINS' if row['pp_wins'] else ''}")
