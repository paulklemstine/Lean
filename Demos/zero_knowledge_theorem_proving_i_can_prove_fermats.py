#!/usr/bin/env python3
"""Numerical demonstrations of a three-move homomorphism protocol.

The examples use additive cyclic groups Z/nZ and homomorphisms phi(x)=k*x mod n.
No third-party packages are required.
"""

from __future__ import annotations

from collections import Counter
from dataclasses import dataclass
from itertools import product
from random import Random
from typing import Dict, Iterable, List, Optional, Tuple


@dataclass(frozen=True, order=True)
class Transcript:
    """A commitment, Boolean challenge, and response modulo n."""

    commitment: int
    challenge: bool
    response: int


def phi(x: int, multiplier: int, modulus: int) -> int:
    """Evaluate the homomorphism x -> multiplier*x in Z/modulus Z."""
    if modulus <= 1:
        raise ValueError("modulus must be greater than one")
    return (multiplier * x) % modulus


def challenge_term(challenge: bool, value: int, modulus: int) -> int:
    """Return value for challenge one and zero for challenge zero."""
    return value % modulus if challenge else 0


def target_from_witness(witness: int, multiplier: int, modulus: int) -> int:
    """Construct the public target phi(witness)."""
    return phi(witness, multiplier, modulus)


def real_transcript(
    witness: int,
    random_tape: int,
    challenge: bool,
    multiplier: int,
    modulus: int,
) -> Transcript:
    """Generate an honest transcript."""
    commitment = phi(random_tape, multiplier, modulus)
    response = (
        random_tape + challenge_term(challenge, witness, modulus)
    ) % modulus
    return Transcript(commitment, challenge, response)


def simulated_transcript(
    target: int,
    response: int,
    challenge: bool,
    multiplier: int,
    modulus: int,
) -> Transcript:
    """Generate a transcript from public data and a freely chosen response."""
    commitment = (
        phi(response, multiplier, modulus)
        - challenge_term(challenge, target, modulus)
    ) % modulus
    return Transcript(commitment, challenge, response % modulus)


def accepts(
    transcript: Transcript,
    target: int,
    multiplier: int,
    modulus: int,
) -> bool:
    """Evaluate the verifier equation phi(z)=a+[c]y."""
    left = phi(transcript.response, multiplier, modulus)
    right = (
        transcript.commitment
        + challenge_term(transcript.challenge, target, modulus)
    ) % modulus
    return left == right


def extract_witness(
    false_transcript: Transcript,
    true_transcript: Transcript,
    target: int,
    multiplier: int,
    modulus: int,
) -> int:
    """Extract z_1-z_0 after validating a special-soundness transcript pair."""
    if false_transcript.challenge or not true_transcript.challenge:
        raise ValueError("transcripts must have challenges zero and one")
    if false_transcript.commitment != true_transcript.commitment:
        raise ValueError("transcripts must share a commitment")
    if not accepts(false_transcript, target, multiplier, modulus):
        raise ValueError("challenge-zero transcript is not accepted")
    if not accepts(true_transcript, target, multiplier, modulus):
        raise ValueError("challenge-one transcript is not accepted")
    witness = (true_transcript.response - false_transcript.response) % modulus
    if phi(witness, multiplier, modulus) != target % modulus:
        raise AssertionError("extraction identity failed")
    return witness


def transcript_distribution(
    *,
    simulated: bool,
    witness: int,
    target: int,
    challenge: bool,
    multiplier: int,
    modulus: int,
) -> Counter[Transcript]:
    """Enumerate the exact transcript multiset for real or simulated sampling."""
    if simulated:
        return Counter(
            simulated_transcript(target, z, challenge, multiplier, modulus)
            for z in range(modulus)
        )
    return Counter(
        real_transcript(witness, r, challenge, multiplier, modulus)
        for r in range(modulus)
    )


def find_witness(target: int, multiplier: int, modulus: int) -> Optional[int]:
    """Find a preimage by exhaustive search, for small educational examples."""
    return next(
        (w for w in range(modulus) if phi(w, multiplier, modulus) == target % modulus),
        None,
    )


def accepted_responses(
    commitment: int,
    challenge: bool,
    target: int,
    multiplier: int,
    modulus: int,
) -> List[int]:
    """List all accepted responses for a fixed commitment and challenge."""
    return [
        z
        for z in range(modulus)
        if accepts(Transcript(commitment, challenge, z), target, multiplier, modulus)
    ]


def demonstrate_completeness_and_extraction() -> None:
    """Show perfect completeness and extract a witness modulo 11."""
    modulus, multiplier, witness, random_tape = 11, 3, 4, 7
    target = target_from_witness(witness, multiplier, modulus)
    t0 = real_transcript(witness, random_tape, False, multiplier, modulus)
    t1 = real_transcript(witness, random_tape, True, multiplier, modulus)
    assert accepts(t0, target, multiplier, modulus)
    assert accepts(t1, target, multiplier, modulus)
    recovered = extract_witness(t0, t1, target, multiplier, modulus)
    print("Demo 1 — completeness and extraction in Z/11Z")
    print(f"  public map: phi(x)={multiplier}x mod {modulus}; target y={target}")
    print(f"  challenge 0: {t0}")
    print(f"  challenge 1: {t1}")
    print(f"  extracted witness: {recovered}\n")


def demonstrate_exact_zero_knowledge() -> None:
    """Enumerate real and simulated multisets and confirm exact equality."""
    modulus, multiplier, witness = 12, 4, 5
    target = target_from_witness(witness, multiplier, modulus)
    print("Demo 2 — exact real/simulated distribution equality in Z/12Z")
    for challenge in (False, True):
        real = transcript_distribution(
            simulated=False,
            witness=witness,
            target=target,
            challenge=challenge,
            multiplier=multiplier,
            modulus=modulus,
        )
        simulated = transcript_distribution(
            simulated=True,
            witness=witness,
            target=target,
            challenge=challenge,
            multiplier=multiplier,
            modulus=modulus,
        )
        assert real == simulated
        assert all(
            accepts(t, target, multiplier, modulus) for t in simulated.elements()
        )
        print(
            f"  challenge {int(challenge)}: {sum(real.values())} samples, "
            f"{len(real)} distinct transcripts, exact multisets equal"
        )
    print()


def demonstrate_false_statement_exclusivity() -> None:
    """Show that a target outside the image cannot answer both challenges."""
    modulus, multiplier, target = 8, 2, 1
    assert find_witness(target, multiplier, modulus) is None
    print("Demo 3 — challenge exclusivity for a false statement in Z/8Z")
    print("  map phi(x)=2x mod 8 has no preimage of target 1")
    for commitment in range(modulus):
        answers0 = accepted_responses(
            commitment, False, target, multiplier, modulus
        )
        answers1 = accepted_responses(
            commitment, True, target, multiplier, modulus
        )
        assert not (answers0 and answers1)
        covered = [c for c, answers in ((0, answers0), (1, answers1)) if answers]
        print(f"  commitment {commitment}: answerable challenges {covered}")
    print("  every commitment covers at most one challenge\n")


def demonstrate_empirical_honest_runs(seed: int = 20260717) -> None:
    """Sample honest executions as a supplementary randomized check."""
    rng = Random(seed)
    modulus, multiplier, witness = 101, 7, 19
    target = target_from_witness(witness, multiplier, modulus)
    trials = 1_000
    accepted = 0
    for _ in range(trials):
        r = rng.randrange(modulus)
        c = bool(rng.randrange(2))
        accepted += accepts(
            real_transcript(witness, r, c, multiplier, modulus),
            target,
            multiplier,
            modulus,
        )
    assert accepted == trials
    print("Supplement — sampled honest executions in Z/101Z")
    print(f"  accepted {accepted}/{trials} deterministic verifier checks")


def main() -> None:
    """Run all numerical demonstrations."""
    demonstrate_completeness_and_extraction()
    demonstrate_exact_zero_knowledge()
    demonstrate_false_statement_exclusivity()
    demonstrate_empirical_honest_runs()


if __name__ == "__main__":
    main()
