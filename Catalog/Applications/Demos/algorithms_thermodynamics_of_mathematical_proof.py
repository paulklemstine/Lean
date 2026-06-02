#!/usr/bin/env python3
"""
Algorithms for Proof Thermodynamics

Type-hinted implementations of the core algorithms from the
Landauer Principle for Mathematical Proof framework.
"""

import math
from dataclasses import dataclass
from typing import Optional


@dataclass
class ProofConfig:
    """A proof configuration with a given cardinality."""
    cardinality: int

    def __post_init__(self) -> None:
        assert self.cardinality > 0, "Configuration must have positive cardinality"

    @property
    def entropy(self) -> float:
        """Information-theoretic entropy (natural log of cardinality)."""
        return math.log(self.cardinality)

    @property
    def descriptive_complexity(self) -> float:
        """Descriptive complexity in bits."""
        return math.log2(self.cardinality)


@dataclass
class ProofStep:
    """A proof step between two configurations."""
    source: ProofConfig
    target: ProofConfig

    def __post_init__(self) -> None:
        assert self.source.cardinality >= self.target.cardinality, \
            "Surjective map requires |source| >= |target|"

    @property
    def erasure(self) -> float:
        """Information-theoretic erasure of this step."""
        return self.source.entropy - self.target.entropy

    @property
    def is_reversible(self) -> bool:
        """Whether this step is reversible (bijective)."""
        return self.source.cardinality == self.target.cardinality

    def landauer_cost(self, kB: float, T: float) -> float:
        """Thermodynamic cost at given kB and T."""
        return kB * T * self.erasure


@dataclass
class ProofTrace:
    """A sequence of proof configurations forming a complete proof."""
    cardinalities: list[int]

    def __post_init__(self) -> None:
        assert len(self.cardinalities) >= 2, "Trace needs at least 2 configurations"
        for c in self.cardinalities:
            assert c > 0, "All cardinalities must be positive"
        for i in range(len(self.cardinalities) - 1):
            assert self.cardinalities[i] >= self.cardinalities[i + 1], \
                f"Surjectivity violated at step {i}"

    @property
    def length(self) -> int:
        """Number of steps in the trace."""
        return len(self.cardinalities) - 1

    @property
    def configs(self) -> list[ProofConfig]:
        """List of proof configurations."""
        return [ProofConfig(c) for c in self.cardinalities]

    @property
    def steps(self) -> list[ProofStep]:
        """List of proof steps."""
        return [
            ProofStep(ProofConfig(self.cardinalities[i]),
                      ProofConfig(self.cardinalities[i + 1]))
            for i in range(self.length)
        ]

    def step_erasures(self) -> list[float]:
        """Erasure at each step."""
        return [s.erasure for s in self.steps]

    def total_erasure(self) -> float:
        """Total erasure across the trace (sum of step erasures)."""
        return sum(self.step_erasures())

    def boundary_erasure(self) -> float:
        """Boundary erasure (initial entropy - final entropy)."""
        return (math.log(self.cardinalities[0]) -
                math.log(self.cardinalities[-1]))

    def verify_telescoping(self, tol: float = 1e-10) -> bool:
        """Verify the telescoping property: total = boundary."""
        return abs(self.total_erasure() - self.boundary_erasure()) < tol

    def verify_monotonicity(self) -> bool:
        """Verify entropy is monotonically non-increasing."""
        entropies = [math.log(c) for c in self.cardinalities]
        return all(entropies[i] >= entropies[i + 1]
                   for i in range(len(entropies) - 1))

    def find_bottleneck(self) -> tuple[int, float]:
        """Find the step with maximum erasure."""
        erasures = self.step_erasures()
        max_idx = max(range(len(erasures)), key=lambda i: erasures[i])
        return max_idx, erasures[max_idx]

    def average_erasure(self) -> float:
        """Average erasure per step."""
        return self.total_erasure() / self.length

    def verify_concentration(self) -> bool:
        """Verify concentration: max step erasure >= average."""
        _, max_e = self.find_bottleneck()
        return max_e >= self.average_erasure() - 1e-10

    def thermodynamic_cost(self, kB: float, T: float) -> float:
        """Total thermodynamic cost."""
        return kB * T * self.total_erasure()


@dataclass
class ErasureProfile:
    """Erasure and creation at each step of a proof."""
    erasures: list[float]
    creations: list[float]

    def __post_init__(self) -> None:
        assert len(self.erasures) == len(self.creations)
        assert all(e >= 0 for e in self.erasures)
        assert all(c >= 0 for c in self.creations)

    @property
    def length(self) -> int:
        return len(self.erasures)

    @property
    def total_erasure(self) -> float:
        return sum(self.erasures)

    @property
    def total_creation(self) -> float:
        return sum(self.creations)

    def net_cost(self, kB: float, T: float) -> float:
        return kB * T * (self.total_erasure - self.total_creation)

    def erasure_exceeds_creation(self) -> bool:
        return self.total_erasure > self.total_creation


def thermodynamic_depth(m: int, k: int) -> float:
    """Compute thermodynamic depth: log(m) - log(k)."""
    assert m >= k > 0
    return math.log(m) - math.log(k)


def exponential_collapse_cost(n: int) -> float:
    """Cost of collapsing 2^n states to 1: n * ln(2)."""
    return n * math.log(2)


def erasure_to_description_ratio(n: int) -> float:
    """Ratio of erasure cost to description complexity for 2^n → 1."""
    if n <= 1:
        return n * math.log(2)
    erasure = n * math.log(2)
    description = math.log2(n)
    return erasure / description


def optimal_even_trace(m: int, k: int, num_steps: int) -> Optional[ProofTrace]:
    """Construct a trace from m to k with roughly even erasure per step.

    Uses geometric spacing: each step reduces cardinality by factor (m/k)^(1/L).
    """
    if m < k or k <= 0 or num_steps < 1:
        return None
    ratio = (m / k) ** (1.0 / num_steps)
    cardinalities = []
    current = float(m)
    for i in range(num_steps + 1):
        cardinalities.append(max(int(round(current)), k if i == num_steps else 1))
        current /= ratio
    # Ensure monotonicity and exact endpoints
    cardinalities[0] = m
    cardinalities[-1] = k
    for i in range(1, len(cardinalities)):
        cardinalities[i] = min(cardinalities[i], cardinalities[i - 1])
        cardinalities[i] = max(cardinalities[i], k)
    try:
        return ProofTrace(cardinalities)
    except AssertionError:
        return None


if __name__ == "__main__":
    # Quick demo
    print("Thermodynamic Depth Examples:")
    for n in [4, 8, 16]:
        d = thermodynamic_depth(2**n, 1)
        print(f"  D(2^{n}, 1) = {d:.4f} = {n} × ln(2)")

    print("\nProof Trace Verification:")
    trace = ProofTrace([1024, 512, 256, 128, 64, 32, 16, 8, 4, 2, 1])
    print(f"  Telescoping: {trace.verify_telescoping()}")
    print(f"  Monotonicity: {trace.verify_monotonicity()}")
    print(f"  Concentration: {trace.verify_concentration()}")
    idx, val = trace.find_bottleneck()
    print(f"  Bottleneck at step {idx}: erasure = {val:.4f}")

    print("\nExponential Erasure Gap:")
    for n in [2, 4, 8, 16, 32]:
        r = erasure_to_description_ratio(n)
        print(f"  n={n:3d}: ratio = {r:.2f}")
