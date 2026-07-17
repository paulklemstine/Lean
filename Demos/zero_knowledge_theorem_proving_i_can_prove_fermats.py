#!/usr/bin/env python3
"""Numerical demonstrations of affine privacy and witness extraction.

The examples use cyclic additive groups.  Run with Python 3.10 or later;
no third-party packages are required.
"""

from __future__ import annotations

from collections import Counter
from dataclasses import dataclass
from typing import Iterable


@dataclass(frozen=True, order=True)
class Transcript:
    """A transcript (commitment, challenge, response) in cyclic groups."""

    commitment: int
    challenge: int
    response: int


@dataclass(frozen=True)
class CyclicStatement:
    """The homomorphism L(x) = multiplier*x (mod target_modulus)."""

    source_modulus: int
    target_modulus: int
    multiplier: int
    target: int

    def __post_init__(self) -> None:
        if self.source_modulus <= 0 or self.target_modulus <= 0:
            raise ValueError("Moduli must be positive")
        # This formula descends from Z/source_modulus to Z/target_modulus
        # exactly when target_modulus divides multiplier*source_modulus.
        if (self.multiplier * self.source_modulus) % self.target_modulus != 0:
            raise ValueError("The multiplier does not define a homomorphism")

    def hom(self, x: int) -> int:
        return (self.multiplier * (x % self.source_modulus)) % self.target_modulus

    def is_witness(self, witness: int) -> bool:
        return self.hom(witness) == self.target % self.target_modulus


def real_transcript(statement: CyclicStatement, witness: int, random_tape: int,
                    challenge: int) -> Transcript:
    """Construct an honest transcript."""
    _check_bit(challenge)
    if not statement.is_witness(witness):
        raise ValueError("The supplied value is not a witness")
    r = random_tape % statement.source_modulus
    response = (r + challenge * witness) % statement.source_modulus
    return Transcript(statement.hom(r), challenge, response)


def simulated_transcript(statement: CyclicStatement, response: int,
                         challenge: int) -> Transcript:
    """Construct a witness-free accepting transcript."""
    _check_bit(challenge)
    z = response % statement.source_modulus
    commitment = (statement.hom(z) - challenge * statement.target) % statement.target_modulus
    return Transcript(commitment, challenge, z)


def accepts(statement: CyclicStatement, transcript: Transcript) -> bool:
    """Evaluate L(z) = a + c*y in the target cyclic group."""
    if transcript.challenge not in (0, 1):
        return False
    right = (transcript.commitment + transcript.challenge * statement.target) % statement.target_modulus
    return statement.hom(transcript.response) == right


def transcript_multiset(statement: CyclicStatement, witness: int,
                        challenge: int, simulated: bool = False) -> Counter[Transcript]:
    """Enumerate the exact real or simulated transcript multiset."""
    values: Iterable[Transcript]
    if simulated:
        values = (simulated_transcript(statement, z, challenge)
                  for z in range(statement.source_modulus))
    else:
        values = (real_transcript(statement, witness, r, challenge)
                  for r in range(statement.source_modulus))
    return Counter(values)


def extract_witness(statement: CyclicStatement, false_transcript: Transcript,
                    true_transcript: Transcript) -> int:
    """Extract z_1-z_0 after checking common commitment and acceptance."""
    if false_transcript.challenge != 0 or true_transcript.challenge != 1:
        raise ValueError("Transcripts must answer challenges 0 and 1")
    if false_transcript.commitment != true_transcript.commitment:
        raise ValueError("Transcripts must have the same commitment")
    if not accepts(statement, false_transcript) or not accepts(statement, true_transcript):
        raise ValueError("Both transcripts must be accepting")
    witness = (true_transcript.response - false_transcript.response) % statement.source_modulus
    if not statement.is_witness(witness):
        raise AssertionError("Extraction invariant failed")
    return witness


def _check_bit(challenge: int) -> None:
    if challenge not in (0, 1):
        raise ValueError("Challenge must be 0 or 1")


def demonstrate_prime_cycle() -> None:
    """Show simulation and extraction in Z/11Z with L(x)=3x."""
    statement = CyclicStatement(11, 11, 3, 7)
    witness, random_tape = 6, 4
    t0 = real_transcript(statement, witness, random_tape, 0)
    t1 = real_transcript(statement, witness, random_tape, 1)
    print("Example 1: Z/11Z, L(x)=3x, y=7")
    print(f"  challenge 0 transcript: {t0}; accepts={accepts(statement, t0)}")
    print(f"  challenge 1 transcript: {t1}; accepts={accepts(statement, t1)}")
    print(f"  extracted witness: {extract_witness(statement, t0, t1)}")
    for challenge in (0, 1):
        real = transcript_multiset(statement, witness, challenge)
        simulated = transcript_multiset(statement, witness, challenge, simulated=True)
        print(f"  c={challenge}: real multiset equals simulated multiset: {real == simulated}")


def demonstrate_witness_independence() -> None:
    """Compare two witnesses when L: Z/12Z -> Z/6Z is reduction."""
    statement = CyclicStatement(12, 6, 1, 2)
    first, second = 2, 8
    print("\nExample 2: Z/12Z -> Z/6Z, y=2")
    print(f"  witnesses {first} and {second} are valid: "
          f"{statement.is_witness(first)} and {statement.is_witness(second)}")
    for challenge in (0, 1):
        view_first = transcript_multiset(statement, first, challenge)
        view_second = transcript_multiset(statement, second, challenge)
        print(f"  c={challenge}: witness views exactly equal: {view_first == view_second}")


def demonstrate_all_small_instances() -> None:
    """Audit all valid witnesses for a small noninjective homomorphism."""
    statement = CyclicStatement(15, 5, 2, 4)
    witnesses = [w for w in range(statement.source_modulus) if statement.is_witness(w)]
    print("\nExample 3: exhaustive audit for L(x)=2x from Z/15Z to Z/5Z")
    print(f"  witnesses of y=4: {witnesses}")
    for challenge in (0, 1):
        views = [transcript_multiset(statement, w, challenge) for w in witnesses]
        simulator = transcript_multiset(statement, witnesses[0], challenge, simulated=True)
        assert all(view == simulator for view in views)
        print(f"  c={challenge}: all {len(witnesses)} witness views equal the simulator")
    checked = 0
    for r in range(statement.source_modulus):
        for w in witnesses:
            t0 = real_transcript(statement, w, r, 0)
            t1 = real_transcript(statement, w, r, 1)
            assert statement.is_witness(extract_witness(statement, t0, t1))
            checked += 1
    print(f"  extraction succeeded for all {checked} correlated transcript pairs")


def main() -> None:
    demonstrate_prime_cycle()
    demonstrate_witness_independence()
    demonstrate_all_small_instances()


if __name__ == "__main__":
    main()
