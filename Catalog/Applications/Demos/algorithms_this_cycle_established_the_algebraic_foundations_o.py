"""
Tropical Recipe Complexity Theory — Core Algorithms

Type-hinted implementations of the algebraic operations and analysis
tools for recipe scheduling in the max-plus (tropical) semiring.
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import List, Tuple, Optional
import math


@dataclass(frozen=True)
class RecipeStep:
    """A computational task with creation and verification times.

    Invariant: verify_time <= create_time (verification is never harder).
    """
    create_time: int
    verify_time: int

    def __post_init__(self) -> None:
        if self.verify_time > self.create_time:
            raise ValueError(
                f"Verification time ({self.verify_time}) must not exceed "
                f"creation time ({self.create_time})"
            )

    @property
    def gap(self) -> int:
        """The creation-verification gap: create_time - verify_time."""
        return self.create_time - self.verify_time

    @property
    def gap_ratio(self) -> float:
        """The gap ratio: create_time / verify_time.

        Returns infinity if verify_time is 0.
        """
        if self.verify_time == 0:
            return float('inf') if self.create_time > 0 else 1.0
        return self.create_time / self.verify_time

    def seq(self, other: RecipeStep) -> RecipeStep:
        """Sequential composition: do self, then other."""
        return RecipeStep(
            create_time=self.create_time + other.create_time,
            verify_time=self.verify_time + other.verify_time,
        )

    def par(self, other: RecipeStep) -> RecipeStep:
        """Parallel composition: do self and other simultaneously.

        Uses tropical addition (max) for both creation and verification.
        """
        return RecipeStep(
            create_time=max(self.create_time, other.create_time),
            verify_time=max(self.verify_time, other.verify_time),
        )

    def iterate(self, n: int) -> RecipeStep:
        """n-fold sequential iteration."""
        if n < 0:
            raise ValueError("Cannot iterate a negative number of times")
        if n == 0:
            return RecipeStep(create_time=0, verify_time=0)
        result = RecipeStep(create_time=0, verify_time=0)
        for _ in range(n):
            result = result.seq(self)
        return result


@dataclass
class TropicalScheduleVector:
    """A collection of task durations for parallel scheduling."""
    durations: List[int]

    def __post_init__(self) -> None:
        if not self.durations:
            raise ValueError("Schedule vector must have at least one duration")

    @property
    def critical_path(self) -> int:
        """The critical path: maximum duration (tropical sum)."""
        return max(self.durations)

    @property
    def seq_total(self) -> int:
        """The sequential total: sum of all durations."""
        return sum(self.durations)

    @property
    def n(self) -> int:
        """Number of tasks."""
        return len(self.durations)

    @property
    def average_duration(self) -> float:
        """Average task duration."""
        return self.seq_total / self.n

    @property
    def parallelism_speedup(self) -> float:
        """Speedup from parallelism: seq_total / critical_path."""
        if self.critical_path == 0:
            return 1.0
        return self.seq_total / self.critical_path


@dataclass
class Pipeline:
    """A pipeline of processing stages."""
    stage_times: List[int]

    def __post_init__(self) -> None:
        if not self.stage_times:
            raise ValueError("Pipeline must have at least one stage")
        if any(t <= 0 for t in self.stage_times):
            raise ValueError("All stage times must be positive")

    @property
    def bottleneck(self) -> int:
        """The bottleneck: maximum stage time (tropical spectral radius)."""
        return max(self.stage_times)

    @property
    def latency(self) -> int:
        """The latency: total time for one item through all stages."""
        return sum(self.stage_times)

    def throughput_time(self, k: int) -> int:
        """Total time for k items through the pipeline.

        Uses the formula: latency + (k-1) * bottleneck.
        """
        if k <= 0:
            return 0
        return self.latency + (k - 1) * self.bottleneck

    def steady_state_throughput(self) -> float:
        """Steady-state throughput: 1 / bottleneck items per time unit."""
        return 1.0 / self.bottleneck


def classify_gap(
    family: List[Tuple[int, int]],
    threshold: float = 0.1,
) -> str:
    """Classify the gap growth of a recipe family.

    Args:
        family: List of (create_time, verify_time) pairs indexed by size.
        threshold: Relative variation threshold for classification.

    Returns:
        One of 'TRIVIAL', 'LINEAR', 'SUPERLINEAR'.
    """
    if len(family) < 3:
        raise ValueError("Need at least 3 data points for classification")

    gaps = [c - v for c, v in family]

    # Check trivial: gap is bounded
    gap_range = max(gaps) - min(gaps)
    if gap_range <= threshold * max(max(gaps), 1):
        return 'TRIVIAL'

    # Check linear: gap/n is approximately constant
    ratios = []
    for i, g in enumerate(gaps):
        n = i + 1
        ratios.append(g / n)

    ratio_range = max(ratios) - min(ratios)
    mean_ratio = sum(ratios) / len(ratios)
    if mean_ratio > 0 and ratio_range / mean_ratio < threshold:
        return 'LINEAR'

    return 'SUPERLINEAR'


def tropical_matrix_multiply(
    A: List[List[int]],
    B: List[List[int]],
) -> List[List[int]]:
    """Max-plus matrix multiplication.

    C[i][j] = max_k (A[i][k] + B[k][j])

    Uses -infinity (represented as None → -10**18) for the tropical zero.
    """
    NEG_INF = -10**18
    n = len(A)
    m = len(B[0]) if B else 0
    p = len(B)

    C = [[NEG_INF] * m for _ in range(n)]
    for i in range(n):
        for j in range(m):
            for k in range(p):
                val = A[i][k] + B[k][j]
                if val > C[i][j]:
                    C[i][j] = val
    return C


def tropical_matrix_power(
    M: List[List[int]],
    power: int,
) -> List[List[int]]:
    """Compute M^power in the max-plus semiring."""
    n = len(M)
    NEG_INF = -10**18

    # Identity matrix in max-plus: 0 on diagonal, -inf elsewhere
    result = [[NEG_INF] * n for _ in range(n)]
    for i in range(n):
        result[i][i] = 0

    base = [row[:] for row in M]
    while power > 0:
        if power % 2 == 1:
            result = tropical_matrix_multiply(result, base)
        base = tropical_matrix_multiply(base, base)
        power //= 2
    return result


def tropical_spectral_radius(M: List[List[int]]) -> float:
    """Compute the tropical spectral radius (maximum cycle mean).

    For an n×n matrix M, the tropical spectral radius is:
        max over all cycles c of (sum of edge weights in c) / (length of c)

    Uses the Karp algorithm: O(n^3).
    """
    n = len(M)
    NEG_INF = -10**18

    # Compute shortest paths (actually longest in max-plus)
    # D[k][i] = max weight path from node 0 to node i using exactly k edges
    D = [[NEG_INF] * n for _ in range(n + 1)]
    D[0][0] = 0  # Start from node 0

    for k in range(1, n + 1):
        for j in range(n):
            for i in range(n):
                if D[k-1][i] > NEG_INF and M[i][j] > NEG_INF:
                    val = D[k-1][i] + M[i][j]
                    if val > D[k][j]:
                        D[k][j] = val

    # Karp's formula for maximum cycle mean
    max_mean = NEG_INF
    for j in range(n):
        if D[n][j] <= NEG_INF:
            continue
        min_ratio = float('inf')
        for k in range(n):
            if D[k][j] <= NEG_INF:
                continue
            ratio = (D[n][j] - D[k][j]) / (n - k)
            if ratio < min_ratio:
                min_ratio = ratio
        if min_ratio < float('inf') and min_ratio > max_mean:
            max_mean = min_ratio

    return float(max_mean) if max_mean > NEG_INF else float('-inf')


def verify_gap_additivity(r: RecipeStep, s: RecipeStep) -> bool:
    """Verify Theorem 3.1: gap(r.seq(s)) == gap(r) + gap(s)."""
    composed = r.seq(s)
    return composed.gap == r.gap + s.gap


def verify_gap_subadditivity(r: RecipeStep, s: RecipeStep) -> bool:
    """Verify Theorem 3.2: gap(r.par(s)) <= max(gap(r), gap(s))."""
    composed = r.par(s)
    return composed.gap <= max(r.gap, s.gap)


def verify_gap_iteration(r: RecipeStep, n: int) -> bool:
    """Verify Theorem 3.3: gap(r.iterate(n)) == n * gap(r)."""
    iterated = r.iterate(n)
    return iterated.gap == n * r.gap


def verify_tropical_distributive(
    r: RecipeStep, s: RecipeStep, t: RecipeStep
) -> bool:
    """Verify Theorem 5.1: seq distributes over par."""
    lhs = r.seq(s.par(t))
    rhs = r.seq(s).par(r.seq(t))
    return (lhs.create_time == rhs.create_time and
            lhs.verify_time == rhs.verify_time)


def verify_critical_path_bounds(durations: List[int]) -> bool:
    """Verify Theorems 4.1-4.2: avg ≤ critical_path ≤ seq_total."""
    v = TropicalScheduleVector(durations)
    cp = v.critical_path
    st = v.seq_total
    n = v.n
    return cp <= st and n * cp >= st
