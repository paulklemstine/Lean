"""
Cryptographic Hardness Hierarchy: Algorithms and Data Structures

Implements the mathematical structures formalized in the Lean proofs:
- SecurityProfile for tracking reduction chain degradation
- Hybrid argument advantage computation
- GGM tree evaluation
- Lossy function collision analysis
- Fiber partition computation
"""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import Callable, TypeVar, Generic, Optional
import math
from functools import reduce

T = TypeVar('T')


@dataclass
class CryptoLevel:
    """A level in the cryptographic hardness hierarchy."""
    name: str
    rank: int

    OWF: 'CryptoLevel' = None  # type: ignore
    PRG: 'CryptoLevel' = None  # type: ignore
    PRF: 'CryptoLevel' = None  # type: ignore
    ENC: 'CryptoLevel' = None  # type: ignore

    def implies(self, other: 'CryptoLevel') -> bool:
        """Does this level imply the other? (Higher rank implies lower.)"""
        return self.rank >= other.rank

    def __le__(self, other: 'CryptoLevel') -> bool:
        return self.implies(other)

    def __repr__(self) -> str:
        return self.name


# Initialize class-level constants after class definition
CryptoLevel.OWF = CryptoLevel("OWF", 0)
CryptoLevel.PRG = CryptoLevel("PRG", 1)
CryptoLevel.PRF = CryptoLevel("PRF", 2)
CryptoLevel.ENC = CryptoLevel("ENC", 3)

HIERARCHY = [CryptoLevel.OWF, CryptoLevel.PRG, CryptoLevel.PRF, CryptoLevel.ENC]


@dataclass
class SecurityProfile:
    """Tracks security degradation through a chain of cryptographic reductions.

    Corresponds to the Lean SecurityProfile structure.

    Attributes:
        levels: Names of each level
        security_at_level: Security parameter (bits) at each level
        degradation: Degradation factor at each transition
    """
    levels: list[str]
    security_at_level: list[float]
    degradation: list[float]

    def __post_init__(self) -> None:
        assert len(self.security_at_level) == len(self.levels)
        assert len(self.degradation) == len(self.levels) - 1
        assert all(s > 0 for s in self.security_at_level)
        assert all(d >= 1.0 for d in self.degradation)

    @property
    def depth(self) -> int:
        return len(self.levels) - 1

    def total_degradation(self) -> float:
        """Product of all degradation factors."""
        return reduce(lambda x, y: x * y, self.degradation, 1.0)

    def total_degradation_log2(self) -> float:
        """Log2 of total degradation (useful for bit-security)."""
        return sum(math.log2(d) for d in self.degradation)

    def end_to_end_bound(self) -> float:
        """Security at level 0 ≤ total_degradation × security at top.
        Returns the upper bound on security at level 0."""
        return self.total_degradation() * self.security_at_level[-1]

    def verify_chain(self) -> bool:
        """Check that the chain condition holds."""
        for i in range(self.depth):
            if self.security_at_level[i] > self.degradation[i] * self.security_at_level[i + 1]:
                return False
        return True

    @staticmethod
    def from_target(target_bits: int, degradation: list[float]) -> 'SecurityProfile':
        """Compute security at each level given target encryption security."""
        depth = len(degradation)
        levels = [f"Level {i}" for i in range(depth + 1)]
        security = [0.0] * (depth + 1)
        security[-1] = float(target_bits)
        for i in range(depth - 1, -1, -1):
            security[i] = degradation[i] * security[i + 1]
        return SecurityProfile(levels=levels, security_at_level=security,
                               degradation=degradation)


@dataclass
class HybridSequence:
    """A sequence of hybrid experiments with per-step advantages.

    Corresponds to the Lean HybridSequence structure.
    """
    step_advantages: list[float]

    def __post_init__(self) -> None:
        assert all(a >= 0 for a in self.step_advantages)

    @property
    def num_steps(self) -> int:
        return len(self.step_advantages)

    def total_advantage(self) -> float:
        """Sum of all step advantages."""
        return sum(self.step_advantages)

    def triangle_bound(self) -> float:
        """Upper bound: num_steps × max step advantage."""
        if not self.step_advantages:
            return 0.0
        return self.num_steps * max(self.step_advantages)

    def tightness_ratio(self) -> float:
        """Ratio of actual advantage to triangle bound."""
        bound = self.triangle_bound()
        if bound == 0:
            return 1.0
        return self.total_advantage() / bound


@dataclass
class CryptoReduction:
    """A cryptographic reduction with loss factor and runtime overhead."""
    name: str
    loss_factor: float
    runtime_overhead: int

    def __post_init__(self) -> None:
        assert self.loss_factor > 0

    def compose(self, other: 'CryptoReduction') -> 'CryptoReduction':
        """Compose two reductions: loss factors multiply."""
        return CryptoReduction(
            name=f"{self.name} ∘ {other.name}",
            loss_factor=self.loss_factor * other.loss_factor,
            runtime_overhead=self.runtime_overhead + other.runtime_overhead
        )


def ggm_evaluate(g: Callable[[T], tuple[T, T]], seed: T, path: list[bool]) -> T:
    """Evaluate GGM tree at a given path.

    Args:
        g: Length-doubling PRG (maps seed to left/right pair)
        seed: Initial seed
        path: Binary path (list of bools, root to leaf)

    Returns:
        Value at the leaf specified by the path
    """
    node = seed
    for bit in path:
        left, right = g(node)
        node = right if bit else left
    return node


def compute_fibers(f: Callable[[int], int], domain_size: int) -> dict[int, list[int]]:
    """Compute all fibers (preimage sets) of a function.

    Args:
        f: Function from {0, ..., domain_size-1} to codomain
        domain_size: Size of domain

    Returns:
        Dictionary mapping each output value to its list of preimages
    """
    fibers: dict[int, list[int]] = {}
    for x in range(domain_size):
        y = f(x)
        if y not in fibers:
            fibers[y] = []
        fibers[y].append(x)
    return fibers


def collision_free_count(f: Callable[[int], int], domain_size: int,
                          codomain_size: int) -> int:
    """Count outputs with exactly one preimage.

    Corresponds to the Lean collisionFreeOutputs definition.
    """
    fibers = compute_fibers(f, domain_size)
    return sum(1 for y in range(codomain_size)
               if y in fibers and len(fibers[y]) == 1)


def lossy_collision_check(f: Callable[[int], int], domain_size: int,
                           image_bound: int) -> Optional[tuple[int, int]]:
    """Find a collision if image size < domain size.

    Returns a pair (x1, x2) with x1 ≠ x2 and f(x1) = f(x2), or None.
    """
    seen: dict[int, int] = {}
    for x in range(domain_size):
        y = f(x)
        if y in seen:
            return (seen[y], x)
        seen[y] = x
    return None


def amplification_failure_prob(p: float, k: int) -> float:
    """Compute (1-p)^k: failure probability after k repetitions."""
    return (1 - p) ** k


def security_parameter_for_target(
    target_security_bits: int,
    degradation_chain: list[float]
) -> float:
    """Compute required OWF security for a target encryption security level.

    Uses the SecurityProfile end-to-end bound:
    owf_security ≥ total_degradation × target_security

    Returns required OWF security in bits.
    """
    total_deg = reduce(lambda x, y: x * y, degradation_chain, 1.0)
    return math.log2(total_deg) + target_security_bits
