"""
Algorithms for Self-Avoiding Walk Enumeration and Tropical Analysis

This module implements:
1. SAW enumeration via backtracking on lattice graphs
2. Growth rate (connective constant) estimation
3. Tropical power series evaluation
4. Fekete-Tropical bridge computation

Type-hinted for clarity and correctness.
"""

from typing import List, Tuple, Set, Dict, Optional, Callable
import math


# ============================================================
# 1. Self-Avoiding Walk Enumeration
# ============================================================

def enumerate_saws_2d(n: int, lattice: str = "square") -> int:
    """
    Count self-avoiding walks of length n on a 2D lattice starting from the origin.

    Args:
        n: Walk length
        lattice: One of "square", "hexagonal", "triangular"

    Returns:
        Number of SAWs of length n
    """
    if lattice == "square":
        directions = [(1, 0), (-1, 0), (0, 1), (0, -1)]
    elif lattice == "hexagonal":
        # Hexagonal lattice: 3 neighbors at each vertex (bipartite)
        # Using axial coordinates for hex grid
        directions_even = [(1, 0), (-1, 0), (0, 1)]
        directions_odd = [(1, 0), (-1, 0), (0, -1)]
        return _count_saws_hex(n, directions_even, directions_odd)
    elif lattice == "triangular":
        directions = [(1, 0), (-1, 0), (0, 1), (0, -1), (1, 1), (-1, -1)]
    else:
        raise ValueError(f"Unknown lattice: {lattice}")

    return _count_saws_backtrack(n, directions)


def _count_saws_backtrack(n: int, directions: List[Tuple[int, int]]) -> int:
    """Backtracking SAW counter for regular lattices."""
    if n == 0:
        return 1

    count = 0
    visited: Set[Tuple[int, int]] = {(0, 0)}

    def backtrack(x: int, y: int, steps: int) -> None:
        nonlocal count
        if steps == n:
            count += 1
            return
        for dx, dy in directions:
            nx, ny = x + dx, y + dy
            if (nx, ny) not in visited:
                visited.add((nx, ny))
                backtrack(nx, ny, steps + 1)
                visited.remove((nx, ny))

    backtrack(0, 0, 0)
    return count


def _count_saws_hex(n: int, dirs_even: List[Tuple[int, int]],
                     dirs_odd: List[Tuple[int, int]]) -> int:
    """SAW counter for hexagonal lattice with parity-dependent neighbors."""
    if n == 0:
        return 1

    count = 0
    visited: Set[Tuple[int, int]] = {(0, 0)}

    def backtrack(x: int, y: int, steps: int) -> None:
        nonlocal count
        if steps == n:
            count += 1
            return
        dirs = dirs_even if (x + y) % 2 == 0 else dirs_odd
        for dx, dy in dirs:
            nx, ny = x + dx, y + dy
            if (nx, ny) not in visited:
                visited.add((nx, ny))
                backtrack(nx, ny, steps + 1)
                visited.remove((nx, ny))

    backtrack(0, 0, 0)
    return count


# ============================================================
# 2. Growth Rate Estimation
# ============================================================

def estimate_growth_rate(counts: List[int]) -> float:
    """
    Estimate the connective constant from SAW counts c(1), c(2), ..., c(N).

    Uses the infimum characterization: μ = inf_{n≥1} c(n)^{1/n}.
    This provides an upper bound that converges to μ as N → ∞.

    Args:
        counts: List of SAW counts [c(1), c(2), ..., c(N)]

    Returns:
        Estimated growth rate (upper bound)
    """
    if not counts:
        return float('inf')

    rates = []
    for i, c in enumerate(counts, start=1):
        if c > 0:
            rates.append(c ** (1.0 / i))

    return min(rates) if rates else float('inf')


def growth_rate_sequence(counts: List[int]) -> List[float]:
    """
    Compute the sequence c(n)^{1/n} for visualization.

    Args:
        counts: SAW counts [c(1), c(2), ..., c(N)]

    Returns:
        List of nth-root values
    """
    return [c ** (1.0 / (i + 1)) for i, c in enumerate(counts) if c > 0]


# ============================================================
# 3. Tropical Power Series
# ============================================================

class TropicalPowerSeries:
    """A tropical power series with real coefficients."""

    def __init__(self, coeffs: List[float]):
        self.coeffs = coeffs

    def trop_eval(self, x: float) -> float:
        """
        Evaluate the tropical power series at x:
        result = min_n (c_n + n*x)
        """
        return min(c + n * x for n, c in enumerate(self.coeffs))

    def trop_eval_argmin(self, x: float) -> Tuple[float, int]:
        """Return both the minimum value and the achieving index."""
        values = [(c + n * x, n) for n, c in enumerate(self.coeffs)]
        return min(values, key=lambda t: t[0])

    @classmethod
    def from_submultiplicative(cls, counts: List[float]) -> 'TropicalPowerSeries':
        """
        Create the tropical power series associated to a submultiplicative sequence.
        Coefficients are t_n = -log(a(n)).
        """
        coeffs = [-math.log(c) if c > 0 else float('inf') for c in counts]
        return cls(coeffs)


def tropical_growth_rate(series: TropicalPowerSeries) -> float:
    """
    Estimate the tropical growth rate as lim sup_{n→∞} -c_n/n.
    """
    rates = []
    for n, c in enumerate(series.coeffs):
        if n > 0 and math.isfinite(c):
            rates.append(-c / n)
    return max(rates) if rates else 0.0


# ============================================================
# 4. Fekete-Tropical Bridge
# ============================================================

def verify_fekete_bridge(counts: List[float], growth_rate: float) -> List[float]:
    """
    Verify the Fekete-Tropical Bridge inequality:
    -log(a(n)) + n * log(μ) ≤ 0 for all n ≥ 1.

    Returns the values of -log(a(n)) + n*log(μ) for each n.
    All values should be ≤ 0.
    """
    if growth_rate <= 0:
        raise ValueError("Growth rate must be positive")

    log_mu = math.log(growth_rate)
    bridge_values = []
    for n in range(1, len(counts)):
        if counts[n] > 0:
            val = -math.log(counts[n]) + n * log_mu
            bridge_values.append(val)
        else:
            bridge_values.append(float('-inf'))

    return bridge_values


# ============================================================
# 5. Nienhuis Constant
# ============================================================

def nienhuis_constant() -> float:
    """The Nienhuis constant √(2 + √2)."""
    return math.sqrt(2 + math.sqrt(2))


def verify_nienhuis_polynomial(x: float) -> float:
    """Evaluate x⁴ - 4x² + 2 at x. Should be ≈ 0 for x = Nienhuis constant."""
    return x**4 - 4*x**2 + 2


def is_submultiplicative(counts: List[float]) -> bool:
    """
    Check if a sequence satisfies the submultiplicativity condition:
    a(m+n) ≤ a(m) * a(n) for all m, n with m+n < len(counts).
    """
    n = len(counts)
    for m in range(n):
        for k in range(n - m):
            if counts[m + k] > counts[m] * counts[k] + 1e-10:
                return False
    return True


if __name__ == "__main__":
    # Quick demonstration
    N = 12
    print(f"SAW counts on square lattice (n=0..{N}):")
    counts = [enumerate_saws_2d(n, "square") for n in range(N + 1)]
    print(f"  counts = {counts}")
    print(f"  submultiplicative: {is_submultiplicative([float(c) for c in counts])}")

    mu = estimate_growth_rate(counts[1:])
    print(f"  estimated μ = {mu:.6f}")

    print(f"\nNienhuis constant = {nienhuis_constant():.10f}")
    print(f"  x⁴ - 4x² + 2 = {verify_nienhuis_polynomial(nienhuis_constant()):.2e}")

    bridge = verify_fekete_bridge([float(c) for c in counts], mu)
    print(f"\nFekete-Tropical Bridge values (should be ≤ 0):")
    for i, v in enumerate(bridge, start=1):
        print(f"  n={i}: {v:.6f}")
