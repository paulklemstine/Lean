#!/usr/bin/env python3
"""
Algorithms for Fermi Paradox Analysis via the Pigeonhole Principle.

Provides type-hinted implementations of the Drake Filter Model,
Great Filter detection, temporal overlap analysis, and filter
sensitivity computation.
"""

from dataclasses import dataclass
from typing import List, Tuple, Optional
import math


@dataclass
class DrakeFilterModel:
    """A parametric model of the Drake equation as a chain of filters.

    Attributes:
        filters: List of filter probabilities, each in (0, 1].
        base_count: Number of candidate sites (e.g., habitable planets).
    """
    filters: List[float]
    base_count: float

    def __post_init__(self) -> None:
        assert self.base_count > 0, "Base count must be positive"
        for i, f in enumerate(self.filters):
            assert 0 < f <= 1, f"Filter {i} = {f} not in (0, 1]"

    @property
    def n_filters(self) -> int:
        """Number of filters in the model."""
        return len(self.filters)

    def expected_civilizations(self) -> float:
        """Compute the expected number of civilizations: base × ∏ filters."""
        product = 1.0
        for f in self.filters:
            product *= f
        return self.base_count * product

    def filter_product(self) -> float:
        """Compute the product of all filters."""
        product = 1.0
        for f in self.filters:
            product *= f
        return product

    def great_filter_index(self) -> int:
        """Return the index of the smallest (most restrictive) filter."""
        return min(range(self.n_filters), key=lambda i: self.filters[i])

    def great_filter_bound(self) -> float:
        """Upper bound on the smallest filter: product^(1/n)."""
        p = self.filter_product()
        if p <= 0 or self.n_filters == 0:
            return 0.0
        return p ** (1.0 / self.n_filters)


def great_filter_theorem(
    filters: List[float],
    threshold: float
) -> Tuple[bool, Optional[int]]:
    """Verify the Great Filter Theorem: if ∏ filters < threshold^n,
    find an index i where filters[i] < threshold.

    Args:
        filters: List of positive real factors.
        threshold: The per-filter threshold c.

    Returns:
        (exists, index): Whether a filter below threshold exists, and its index.
    """
    n = len(filters)
    product = 1.0
    for f in filters:
        product *= f

    if product >= threshold ** n:
        return (False, None)

    # The theorem guarantees existence; find the witness
    for i, f in enumerate(filters):
        if f < threshold:
            return (True, i)

    # Should never reach here if product < threshold^n
    raise AssertionError("Great Filter Theorem violated — this cannot happen")


def temporal_pigeonhole(
    n_civilizations: int,
    n_epochs: int,
    assignments: Optional[List[int]] = None
) -> Tuple[bool, Optional[int]]:
    """Apply the temporal pigeonhole principle.

    If n_civilizations < n_epochs, find an empty epoch.

    Args:
        n_civilizations: Number of civilizations (pigeons).
        n_epochs: Number of time epochs (holes).
        assignments: Optional list mapping civilization i to epoch.

    Returns:
        (has_empty, epoch): Whether an empty epoch exists, and one such epoch.
    """
    if n_civilizations >= n_epochs:
        return (False, None)

    if assignments is None:
        # Without specific assignments, the theorem guarantees existence
        # Return the first epoch past the civilization count
        return (True, n_civilizations)

    occupied = set(assignments)
    for t in range(n_epochs):
        if t not in occupied:
            return (True, t)

    return (False, None)


def contact_window_analysis(
    T: int,
    starts: List[int],
    L: int
) -> Tuple[bool, Optional[int], float]:
    """Analyze contact window sparsity.

    Given N civilizations each occupying L consecutive time slots
    starting at positions in `starts`, find uncovered time slots.

    Args:
        T: Total number of time slots.
        starts: Starting time of each civilization.
        L: Duration of each civilization (in slots).

    Returns:
        (has_gap, gap_slot, coverage_fraction):
            Whether a gap exists, an example gap slot, and the total coverage fraction.
    """
    N = len(starts)

    # Count covered slots
    covered = set()
    for s in starts:
        for t in range(s, min(s + L, T)):
            covered.add(t)

    coverage = len(covered) / T if T > 0 else 0.0

    # Find a gap
    for t in range(T):
        if t not in covered:
            return (True, t, coverage)

    return (False, None, coverage)


def filter_sensitivity_analysis(
    model: DrakeFilterModel
) -> List[Tuple[int, float, float]]:
    """Compute the sensitivity of E[civilizations] to each filter.

    Returns a list of (index, filter_value, elasticity) tuples,
    sorted by elasticity (highest first).

    The elasticity of E w.r.t. filter i is ∂log(E)/∂log(f_i) = 1
    for a pure product model. However, the *variance contribution*
    (proportional to 1/f_i² for uncertain filters) varies.
    """
    results = []
    E = model.expected_civilizations()

    for i, f in enumerate(model.filters):
        # Elasticity is always 1 for a product model
        elasticity = 1.0
        # Variance contribution proxy: smaller filters contribute more variance
        variance_proxy = 1.0 / (f * f) if f > 0 else float('inf')
        results.append((i, f, variance_proxy))

    # Sort by variance contribution (descending)
    results.sort(key=lambda x: -x[2])
    return results


def exponential_decay_table(
    base_count: float,
    filter_prob: float,
    max_filters: int = 20
) -> List[Tuple[int, float, bool]]:
    """Generate a table showing exponential decay of expected civilizations.

    Args:
        base_count: Number of candidate sites.
        filter_prob: Per-filter probability.
        max_filters: Maximum number of filters to compute.

    Returns:
        List of (n_filters, expected_count, is_alone) tuples.
    """
    results = []
    for n in range(1, max_filters + 1):
        E = base_count * (filter_prob ** n)
        results.append((n, E, E < 1.0))
    return results


def drake_monte_carlo(
    base_count: float,
    filter_ranges: List[Tuple[float, float]],
    n_samples: int = 100000,
    seed: int = 42
) -> dict:
    """Monte Carlo analysis of the Drake equation with uncertain parameters.

    Args:
        base_count: Fixed base count.
        filter_ranges: List of (low, high) ranges for each filter (uniform dist).
        n_samples: Number of Monte Carlo samples.
        seed: Random seed.

    Returns:
        Dictionary with statistics about the distribution of E[civilizations].
    """
    import random
    rng = random.Random(seed)

    log_E_values = []
    E_values = []
    min_filter_per_sample = []

    for _ in range(n_samples):
        filters = [rng.uniform(lo, hi) for lo, hi in filter_ranges]
        log_prod = sum(math.log(f) for f in filters)
        log_E = math.log(base_count) + log_prod
        E = math.exp(log_E)

        log_E_values.append(log_E)
        E_values.append(E)
        min_filter_per_sample.append(min(filters))

    E_values.sort()
    n = len(E_values)

    return {
        "mean_E": sum(E_values) / n,
        "median_E": E_values[n // 2],
        "p5_E": E_values[int(0.05 * n)],
        "p95_E": E_values[int(0.95 * n)],
        "prob_alone": sum(1 for e in E_values if e < 1) / n,
        "mean_min_filter": sum(min_filter_per_sample) / n,
        "mean_log_E": sum(log_E_values) / n,
    }


if __name__ == "__main__":
    # Example usage
    print("=== Drake Filter Model Example ===")
    model = DrakeFilterModel(
        filters=[0.5, 0.1, 0.01, 0.01, 0.01, 0.01],
        base_count=1.5e10  # habitable planets * star formation
    )
    print(f"Expected civilizations: {model.expected_civilizations():.3e}")
    print(f"Great Filter index: {model.great_filter_index()}")
    print(f"Great Filter bound: {model.great_filter_bound():.6f}")

    # Great Filter Theorem
    exists, idx = great_filter_theorem(model.filters, 0.05)
    print(f"\nGreat Filter Theorem (threshold=0.05): exists={exists}, index={idx}")

    # Temporal Pigeonhole
    has_empty, epoch = temporal_pigeonhole(10, 13000)
    print(f"\nTemporal Pigeonhole (10 civs, 13000 epochs): empty={has_empty}, epoch={epoch}")

    # Monte Carlo
    print("\n=== Monte Carlo Analysis ===")
    results = drake_monte_carlo(
        base_count=1e10,
        filter_ranges=[(0.001, 1.0)] * 7,
        n_samples=100000
    )
    for k, v in results.items():
        print(f"  {k}: {v:.6f}")
