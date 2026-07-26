#!/usr/bin/env python3
"""Numerical demonstrations for private theorem-certification bounds.

The program uses only Python's standard library. It illustrates exact geometric
soundness, repetition requirements, coordinate leakage, and perfect additive
masking over finite cyclic groups.
"""

from __future__ import annotations

from collections import Counter
from fractions import Fraction
from math import ceil, log
from typing import Dict, Iterable, List, Sequence, Tuple


def acceptance_probability(accepting: int, challenges: int, rounds: int) -> Fraction:
    """Return the exact probability (accepting/challenges)**rounds."""
    if challenges <= 0:
        raise ValueError("challenges must be positive")
    if not 0 <= accepting <= challenges:
        raise ValueError("accepting must lie between 0 and challenges")
    if rounds < 0:
        raise ValueError("rounds must be nonnegative")
    return Fraction(accepting, challenges) ** rounds


def single_bad_failure(challenges: int, rounds: int) -> Fraction:
    """Exact escape probability when precisely one challenge detects cheating."""
    if challenges < 1:
        raise ValueError("challenges must be positive")
    return acceptance_probability(challenges - 1, challenges, rounds)


def minimum_rounds(accepting_fraction: float, target_error: float) -> int:
    """Least k with accepting_fraction**k <= target_error."""
    if not 0.0 <= accepting_fraction <= 1.0:
        raise ValueError("accepting_fraction must be in [0, 1]")
    if not 0.0 < target_error < 1.0:
        raise ValueError("target_error must be in (0, 1)")
    if accepting_fraction == 0.0:
        return 1
    if accepting_fraction == 1.0:
        raise ValueError("error cannot decrease when the accepting fraction is one")
    estimate = max(0, ceil(log(target_error) / log(accepting_fraction)))
    # Correct possible floating-point boundary rounding.
    while estimate > 0 and accepting_fraction ** (estimate - 1) <= target_error:
        estimate -= 1
    while accepting_fraction ** estimate > target_error:
        estimate += 1
    return estimate


def transcript_distribution(witness: Sequence[int]) -> Counter[Tuple[int, int]]:
    """Count transcripts (challenge index, opened value) under uniform challenge."""
    if not witness:
        raise ValueError("witness must contain at least one coordinate")
    return Counter((index, value) for index, value in enumerate(witness))


def additive_commitment_histogram(secret: int, modulus: int) -> Counter[int]:
    """Count C=(secret+mask) mod modulus over all uniformly enumerated masks."""
    if modulus <= 0:
        raise ValueError("modulus must be positive")
    return Counter((secret + mask) % modulus for mask in range(modulus))


def verify_perfect_hiding(modulus: int) -> bool:
    """Exhaustively compare additive-masking histograms for every secret."""
    if modulus <= 0:
        raise ValueError("modulus must be positive")
    reference = additive_commitment_histogram(0, modulus)
    return all(additive_commitment_histogram(s, modulus) == reference
               for s in range(modulus))


def soundness_table(challenge_sizes: Iterable[int], rounds: Iterable[int]) -> List[str]:
    """Format a table of exact and decimal single-defect escape probabilities."""
    lines = ["n   k   exact failure       decimal       binary benchmark"]
    for n in challenge_sizes:
        for k in rounds:
            probability = single_bad_failure(n, k)
            binary = Fraction(1, 2) ** k
            lines.append(
                f"{n:<3} {k:<3} {str(probability):<19} "
                f"{float(probability):<13.8f} {float(binary):.8f}"
            )
    return lines


def main() -> None:
    print("EXACT SOUNDNESS AMPLIFICATION")
    print("\n".join(soundness_table((4, 10, 100), (1, 5, 10))))

    print("\nNO FIXED-REPETITION HALF-BOUND")
    for k in range(0, 9):
        n = 2 * k + 2
        p = single_bad_failure(n, k)
        print(f"k={k:2d}, n={n:2d}, failure={float(p):.8f}, above 1/2={p > Fraction(1, 2)}")

    print("\nROUNDS NEEDED FOR ERROR AT MOST 2^-40")
    target = 2.0 ** -40
    for n in (4, 10, 100, 1000):
        p = (n - 1) / n
        print(f"n={n:4d}: {minimum_rounds(p, target):6d} rounds")

    print("\nRAW OPENING LEAKAGE")
    zero_view = transcript_distribution((0,))
    one_view = transcript_distribution((1,))
    print(f"witness (0,) transcripts: {dict(zero_view)}")
    print(f"witness (1,) transcripts: {dict(one_view)}")
    print(f"identical distributions: {zero_view == one_view}")

    print("\nPERFECT ADDITIVE HIDING MODULO 7")
    for secret in range(3):
        histogram: Dict[int, int] = dict(sorted(additive_commitment_histogram(secret, 7).items()))
        print(f"secret={secret}: {histogram}")
    print(f"all seven secret distributions identical: {verify_perfect_hiding(7)}")


if __name__ == "__main__":
    main()
