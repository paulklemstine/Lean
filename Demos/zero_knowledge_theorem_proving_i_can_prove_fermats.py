#!/usr/bin/env python3
"""Numerical demonstrations of an affine zero-knowledge protocol.

The examples use the homomorphism L(x) = a*x modulo q.  They illustrate
perfect completeness, exact fixed-challenge simulation, witness independence,
and extraction from two accepting transcripts with a shared commitment.
"""

from __future__ import annotations

from collections import Counter
from dataclasses import dataclass
import random
from typing import Iterable, TypeAlias

Transcript: TypeAlias = tuple[int, int, int]


@dataclass(frozen=True)
class CyclicProtocol:
    """Affine preimage protocol over the additive group of integers modulo q."""

    q: int
    a: int

    def __post_init__(self) -> None:
        if self.q < 2:
            raise ValueError("q must be at least 2")

    def image(self, x: int) -> int:
        return (self.a * x) % self.q

    def statement(self, witness: int) -> int:
        return self.image(witness)

    def transcript(self, witness: int, mask: int, challenge: int) -> Transcript:
        _require_bit(challenge)
        y = self.statement(witness)
        commitment = self.image(mask)
        response = (mask + challenge * witness) % self.q
        result = (commitment, challenge, response)
        assert self.verify(y, result)
        return result

    def simulate(self, y: int, response: int, challenge: int) -> Transcript:
        _require_bit(challenge)
        commitment = (self.image(response) - challenge * y) % self.q
        result = (commitment, challenge, response % self.q)
        assert self.verify(y, result)
        return result

    def verify(self, y: int, transcript: Transcript) -> bool:
        commitment, challenge, response = transcript
        if challenge not in (0, 1):
            return False
        return self.image(response) == (commitment + challenge * y) % self.q

    def extract(self, first: Transcript, second: Transcript) -> int:
        t0, e0, z0 = first
        t1, e1, z1 = second
        if (e0, e1) != (0, 1):
            raise ValueError("transcripts must be ordered by challenges 0 and 1")
        if t0 != t1:
            raise ValueError("extraction requires a shared commitment")
        return (z1 - z0) % self.q

    def real_distribution(self, witness: int, challenge: int) -> Counter[Transcript]:
        return Counter(self.transcript(witness, r, challenge) for r in range(self.q))

    def simulated_distribution(self, y: int, challenge: int) -> Counter[Transcript]:
        return Counter(self.simulate(y, z, challenge) for z in range(self.q))

    def witnesses(self, y: int) -> list[int]:
        return [w for w in range(self.q) if self.image(w) == y % self.q]


def _require_bit(challenge: int) -> None:
    if challenge not in (0, 1):
        raise ValueError("challenge must be 0 or 1")


def demonstrate_exact_simulation(protocol: CyclicProtocol, witness: int) -> None:
    """Exhaustively compare real and simulated transcript multiplicities."""
    y = protocol.statement(witness)
    print(f"Public statement: y = {y} modulo {protocol.q}")
    for challenge in (0, 1):
        real = protocol.real_distribution(witness, challenge)
        simulated = protocol.simulated_distribution(y, challenge)
        print(
            f"challenge {challenge}: {len(real)} transcripts; "
            f"real == simulated is {real == simulated}"
        )
        assert real == simulated


def demonstrate_witness_independence(protocol: CyclicProtocol, y: int) -> None:
    """Check that all witnesses in one fiber induce identical distributions."""
    witnesses = protocol.witnesses(y)
    if not witnesses:
        raise ValueError("the selected statement has no witness")
    print(f"Witnesses for y = {y}: {witnesses}")
    for challenge in (0, 1):
        reference = protocol.real_distribution(witnesses[0], challenge)
        assert all(
            protocol.real_distribution(witness, challenge) == reference
            for witness in witnesses
        )
        print(f"challenge {challenge}: all witness distributions agree")


def demonstrate_extraction(protocol: CyclicProtocol, witness: int, mask: int) -> None:
    """Generate opposite accepting answers and recover a valid witness."""
    y = protocol.statement(witness)
    zero = protocol.transcript(witness, mask, 0)
    one = protocol.transcript(witness, mask, 1)
    recovered = protocol.extract(zero, one)
    print(f"challenge-0 transcript: {zero}")
    print(f"challenge-1 transcript: {one}")
    print(f"extracted witness: {recovered}")
    assert protocol.image(recovered) == y


def estimate_challenge_guessing(repetitions: int, trials: int, seed: int = 7) -> float:
    """Estimate success when a prover preselects one answerable bit per round."""
    if repetitions < 0 or trials <= 0:
        raise ValueError("repetitions must be nonnegative and trials positive")
    rng = random.Random(seed)
    successes = 0
    prepared = [0] * repetitions
    for _ in range(trials):
        challenges = [rng.randrange(2) for _ in range(repetitions)]
        successes += int(challenges == prepared)
    return successes / trials


def main() -> None:
    protocol = CyclicProtocol(q=12, a=4)
    witness = 5
    y = protocol.statement(witness)

    print("=== Exact fixed-challenge simulation ===")
    demonstrate_exact_simulation(protocol, witness)

    print("\n=== Witness independence ===")
    demonstrate_witness_independence(protocol, y)

    print("\n=== Special-soundness extraction ===")
    demonstrate_extraction(protocol, witness, mask=7)

    print("\n=== Repeated challenge guessing (illustrative model) ===")
    for repetitions in (1, 2, 4, 8):
        empirical = estimate_challenge_guessing(repetitions, trials=200_000)
        theoretical = 2.0 ** (-repetitions)
        print(
            f"k={repetitions:2d}: empirical={empirical:.5f}, "
            f"theoretical={theoretical:.5f}"
        )


if __name__ == "__main__":
    main()
