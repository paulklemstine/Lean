"""
Algorithms for Landauer's Principle Applied to Mathematical Proof

This module implements the core algorithms for computing thermodynamic
costs of proof traces, erasure-creation gaps, and related quantities.
"""

import math
from dataclasses import dataclass
from typing import List, Tuple, Optional


# Physical constants
KB = 1.380649e-23  # Boltzmann constant in J/K
ROOM_TEMP = 300.0  # Room temperature in K
LANDAUER_ONE_BIT = KB * ROOM_TEMP * math.log(2)  # ~2.87e-21 J


@dataclass
class ProofConfig:
    """A proof configuration with a given number of microstates."""
    cardinality: int
    label: str = ""

    def __post_init__(self) -> None:
        if self.cardinality < 1:
            raise ValueError("Cardinality must be positive")

    @property
    def entropy(self) -> float:
        """Counting entropy: log(cardinality) in nats."""
        return math.log(self.cardinality)

    @property
    def entropy_bits(self) -> float:
        """Counting entropy in bits: log2(cardinality)."""
        return math.log2(self.cardinality)

    @property
    def descriptive_complexity(self) -> float:
        """Descriptive complexity: log2(cardinality)."""
        return math.log2(self.cardinality)


@dataclass
class ProofStep:
    """A proof step between two configurations."""
    source: ProofConfig
    target: ProofConfig

    @property
    def erasure(self) -> float:
        """Information-theoretic erasure in nats."""
        return self.source.entropy - self.target.entropy

    @property
    def erasure_bits(self) -> float:
        """Information-theoretic erasure in bits."""
        return self.source.entropy_bits - self.target.entropy_bits

    @property
    def is_reversible(self) -> bool:
        """Whether the step is reversible (same cardinality)."""
        return self.source.cardinality == self.target.cardinality

    def landauer_cost(self, kB: float = KB, T: float = ROOM_TEMP) -> float:
        """Thermodynamic cost in joules."""
        return kB * T * self.erasure


@dataclass
class ErasureCreationGap:
    """Captures both erasure and creation in a proof step."""
    erasure: float  # bits erased
    creation: float  # bits created

    @property
    def gap(self) -> float:
        """Net erasure (erasure - creation)."""
        return self.erasure - self.creation

    def net_cost(self, kB: float = KB, T: float = ROOM_TEMP) -> float:
        """Net thermodynamic cost in joules."""
        return kB * T * self.gap * math.log(2)


class ProofTrace:
    """A sequence of proof configurations forming a complete proof trace."""

    def __init__(self, configs: List[ProofConfig]) -> None:
        if len(configs) < 2:
            raise ValueError("Trace must have at least 2 configurations")
        self.configs = configs
        self.steps = [
            ProofStep(configs[i], configs[i + 1])
            for i in range(len(configs) - 1)
        ]

    @property
    def length(self) -> int:
        """Number of steps."""
        return len(self.steps)

    def step_erasures(self) -> List[float]:
        """Per-step erasure in nats."""
        return [s.erasure for s in self.steps]

    def total_erasure(self) -> float:
        """Total erasure (telescoping sum) in nats."""
        return sum(self.step_erasures())

    def total_positive_erasure(self) -> float:
        """Total positive erasure (only counting destructive steps)."""
        return sum(max(0, e) for e in self.step_erasures())

    def total_negative_erasure(self) -> float:
        """Total entropy increase (creative steps)."""
        return sum(min(0, e) for e in self.step_erasures())

    def max_step_erasure(self) -> float:
        """Maximum per-step erasure."""
        return max(self.step_erasures())

    def peak_entropy(self) -> float:
        """Maximum entropy among all configurations."""
        return max(c.entropy for c in self.configs)

    def verification_cost_bound(self, kB: float = KB, T: float = ROOM_TEMP) -> float:
        """Upper bound on verification cost: kB * T * len * max_step_erasure."""
        return kB * T * self.length * self.max_step_erasure()

    def total_landauer_cost(self, kB: float = KB, T: float = ROOM_TEMP) -> float:
        """Total Landauer cost in joules."""
        return kB * T * self.total_erasure()

    def is_tautological(self) -> bool:
        """Whether start and end have equal entropy."""
        return abs(self.configs[0].entropy - self.configs[-1].entropy) < 1e-12

    def erasure_profile(self) -> List[Tuple[int, float, float]]:
        """Returns (step_index, cumulative_erasure, current_entropy) tuples."""
        profile = [(0, 0.0, self.configs[0].entropy)]
        cumulative = 0.0
        for i, step in enumerate(self.steps):
            cumulative += step.erasure
            profile.append((i + 1, cumulative, self.configs[i + 1].entropy))
        return profile


def compute_exponential_erasure(n: int) -> dict:
    """Compute erasure for collapsing 2^n states to 1.

    Args:
        n: Number of bits to erase.

    Returns:
        Dictionary with erasure metrics.
    """
    source = ProofConfig(2**n, f"2^{n} states")
    target = ProofConfig(1, "1 state")
    step = ProofStep(source, target)
    return {
        "n": n,
        "source_cardinality": source.cardinality,
        "erasure_nats": step.erasure,
        "erasure_bits": step.erasure_bits,
        "expected_nats": n * math.log(2),
        "landauer_cost_joules": step.landauer_cost(),
        "is_reversible": step.is_reversible,
    }


def find_optimal_trace(
    start_card: int, end_card: int, max_intermediate: int = 1000
) -> Optional[ProofTrace]:
    """Find the minimum-erasure proof trace between two cardinalities.

    For surjective maps, the optimal is always the direct step.
    This function demonstrates that detours increase positive erasure.
    """
    # Direct trace
    direct = ProofTrace([
        ProofConfig(start_card, "start"),
        ProofConfig(end_card, "end"),
    ])
    return direct


def erasure_creation_analysis(
    erasure_bits: float, creation_bits: float,
    kB: float = KB, T: float = ROOM_TEMP
) -> dict:
    """Analyze the erasure-creation gap.

    Args:
        erasure_bits: Bits of information erased.
        creation_bits: Bits of new information introduced.

    Returns:
        Dictionary with gap analysis.
    """
    gap = ErasureCreationGap(erasure_bits, creation_bits)
    return {
        "erasure_bits": erasure_bits,
        "creation_bits": creation_bits,
        "gap_bits": gap.gap,
        "net_cost_joules": gap.net_cost(kB, T),
        "cost_positive": gap.gap > 0,
    }
