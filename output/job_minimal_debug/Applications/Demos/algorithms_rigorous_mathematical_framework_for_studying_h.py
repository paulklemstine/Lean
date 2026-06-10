"""
Proof Refinement Systems — Core Algorithms

Type-hinted implementations of the mathematical framework.
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import TypeVar, Generic, Callable, Optional
from abc import ABC, abstractmethod

T = TypeVar('T')


@dataclass
class RefinementChain(Generic[T]):
    """A finite chain of refinements: each element refines its predecessor."""
    elements: list[T]
    complexities: list[int]

    @property
    def length(self) -> int:
        return len(self.elements) - 1

    def verify_strictly_decreasing(self) -> bool:
        """Verify that complexity strictly decreases along the chain."""
        return all(
            self.complexities[i + 1] < self.complexities[i]
            for i in range(self.length)
        )

    def verify_chain_length_bound(self) -> bool:
        """Verify Theorem 3.3: length ≤ initial complexity."""
        return self.length <= self.complexities[0]


class ProofRefinementSystem(ABC, Generic[T]):
    """Abstract proof refinement system."""

    @abstractmethod
    def complexity(self, proof: T) -> int:
        """Measure the complexity of a proof."""
        ...

    @abstractmethod
    def is_minimal(self, proof: T) -> bool:
        """Check if a proof is minimal (no further refinement possible)."""
        ...


class ProofOptimizer(Generic[T]):
    """A proof optimizer: maps proofs to proofs of ≤ complexity."""

    def __init__(
        self,
        system: ProofRefinementSystem[T],
        optimize_fn: Callable[[T], T],
    ):
        self.system = system
        self._optimize = optimize_fn

    def optimize(self, proof: T) -> T:
        """Apply the optimizer once."""
        result = self._optimize(proof)
        assert self.system.complexity(result) <= self.system.complexity(proof), \
            "Optimizer violated complexity-nonincreasing property!"
        return result

    def orbit(self, proof: T, n: int) -> T:
        """Compute orbit(proof, n) = optimize^n(proof)."""
        current = proof
        for _ in range(n):
            current = self.optimize(current)
        return current

    def complexity_sequence(self, proof: T, max_steps: int) -> list[int]:
        """Compute [c(p), c(O(p)), c(O²(p)), ...]."""
        seq: list[int] = []
        current = proof
        for _ in range(max_steps + 1):
            seq.append(self.system.complexity(current))
            current = self.optimize(current)
        return seq

    def find_complexity_fixed_point(
        self, proof: T, max_steps: int = 10000
    ) -> tuple[int, T]:
        """
        Find the first N where c(O(orbit(p,N))) = c(orbit(p,N)).

        By the Fixed-Point Theorem (Theorem 3.6), such N always exists
        for any optimizer on any proof refinement system.

        Returns (N, orbit(p, N)).
        """
        current = proof
        for n in range(max_steps):
            next_proof = self.optimize(current)
            if self.system.complexity(next_proof) == self.system.complexity(current):
                return n, current
            current = next_proof
        raise RuntimeError(
            f"Fixed point not found in {max_steps} steps "
            f"(should not happen by Theorem 3.6)"
        )


class StrictProofOptimizer(ProofOptimizer[T]):
    """
    A strict optimizer: strictly decreases complexity on non-minimal proofs.

    By Theorem 3.7, reaches a minimal proof in ≤ complexity(p) steps.
    """

    def find_minimal(self, proof: T) -> tuple[int, T]:
        """
        Find a minimal proof reachable from the given proof.

        Returns (steps, minimal_proof) where steps ≤ complexity(proof).
        """
        max_steps = self.system.complexity(proof)
        current = proof
        for n in range(max_steps + 1):
            if self.system.is_minimal(current):
                return n, current
            current = self.optimize(current)
        # By Theorem 3.7, we must have reached a minimal proof
        assert self.system.is_minimal(current), \
            "Strict optimizer failed to reach minimal proof within bound!"
        return max_steps, current


def gap_aware_optimize(
    optimizer: StrictProofOptimizer[T],
    proof: T,
    min_gap: int,
) -> tuple[int, T]:
    """
    Algorithm 2: Gap-Aware Optimization.

    When the minimum complexity gap per step is known,
    we can predict the maximum number of iterations.

    By Theorem 3.8: steps ≤ ⌊complexity(proof) / min_gap⌋.

    Args:
        optimizer: A strict proof optimizer
        proof: Starting proof
        min_gap: Minimum complexity decrease per step (≥ 1)

    Returns:
        (steps, minimal_proof)
    """
    assert min_gap >= 1, "Minimum gap must be ≥ 1"
    max_steps = optimizer.system.complexity(proof) // min_gap
    current = proof
    for i in range(max_steps + 1):
        if optimizer.system.is_minimal(current):
            return i, current
        current = optimizer.optimize(current)
    return max_steps, current


def compose_optimizers(
    opt1: ProofOptimizer[T],
    opt2: ProofOptimizer[T],
) -> ProofOptimizer[T]:
    """
    Compose two optimizers: apply opt2 then opt1.

    By Theorem 3.11, the composition is a valid optimizer
    (never increases complexity).
    """
    def composed_fn(proof: T) -> T:
        intermediate = opt2.optimize(proof)
        return opt1.optimize(intermediate)

    return ProofOptimizer(opt1.system, composed_fn)


# --- Concrete Example: Integer List Simplification ---

class IntListSystem(ProofRefinementSystem[tuple[int, ...]]):
    """
    Concrete refinement system where proofs are tuples of integers
    and complexity is the sum of absolute values.
    """

    def complexity(self, proof: tuple[int, ...]) -> int:
        return sum(abs(x) for x in proof)

    def is_minimal(self, proof: tuple[int, ...]) -> bool:
        return all(x == 0 for x in proof)


def make_shrink_optimizer(
    system: IntListSystem,
    step_size: int = 1,
) -> StrictProofOptimizer[tuple[int, ...]]:
    """Create a strict optimizer that moves each element toward 0."""

    def optimize(proof: tuple[int, ...]) -> tuple[int, ...]:
        return tuple(
            max(0, x - step_size) if x > 0
            else min(0, x + step_size) if x < 0
            else 0
            for x in proof
        )

    return StrictProofOptimizer(system, optimize)


if __name__ == "__main__":
    # Demo: verify theorems computationally
    system = IntListSystem()
    optimizer = make_shrink_optimizer(system, step_size=1)

    proof = (10, -5, 3, -8, 7)
    print(f"Proof: {proof}")
    print(f"Complexity: {system.complexity(proof)}")

    # Find fixed point (Theorem 3.6)
    n, fp = optimizer.find_complexity_fixed_point(proof)
    print(f"Complexity fixed point at step {n}: {fp}")

    # Find minimal proof (Theorem 3.7)
    steps, minimal = optimizer.find_minimal(proof)
    print(f"Minimal proof in {steps} steps: {minimal}")
    print(f"Bound: steps ≤ complexity = {system.complexity(proof)}")
    assert steps <= system.complexity(proof)

    # Gap-aware optimization (Theorem 3.8)
    fast_opt = make_shrink_optimizer(system, step_size=3)
    steps_gap, minimal_gap = gap_aware_optimize(fast_opt, proof, min_gap=3)
    print(f"\nWith gap=3: minimal in {steps_gap} steps")
    print(f"Gap bound: ⌊{system.complexity(proof)}/3⌋ = "
          f"{system.complexity(proof) // 3}")

    # Compose optimizers (Theorem 3.11)
    composed = compose_optimizers(optimizer, fast_opt)
    n2, fp2 = composed.find_complexity_fixed_point(proof)
    print(f"\nComposed optimizer fixed point at step {n2}")
