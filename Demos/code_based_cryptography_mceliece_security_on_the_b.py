#!/usr/bin/env python3
"""Numerical demonstrations for McEliece metric and security bounds."""

from __future__ import annotations

from dataclasses import dataclass
from math import comb, log2
from random import Random
from typing import Iterable, Sequence

BitWord = tuple[int, ...]


def xor_words(left: Sequence[int], right: Sequence[int]) -> BitWord:
    """Return coordinatewise addition in the binary field."""
    if len(left) != len(right):
        raise ValueError("words must have equal lengths")
    return tuple(a ^ b for a, b in zip(left, right))


def hamming_weight(word: Iterable[int]) -> int:
    """Count nonzero coordinates."""
    return sum(bit != 0 for bit in word)


def hamming_distance(left: Sequence[int], right: Sequence[int]) -> int:
    """Count coordinates on which two equal-length words differ."""
    if len(left) != len(right):
        raise ValueError("words must have equal lengths")
    return sum(a != b for a, b in zip(left, right))


def additive_encrypt(codeword: Sequence[int], error: Sequence[int]) -> BitWord:
    """Encrypt a codeword by adding a binary error vector."""
    return xor_words(codeword, error)


def ind_advantage(success_probability: float) -> float:
    """Return absolute advantage over fair guessing."""
    return abs(success_probability - 0.5)


def game_hop_bound(epsilon_key: float, epsilon_decode: float) -> float:
    """Return the additive two-hop upper bound."""
    if epsilon_key < 0 or epsilon_decode < 0:
        raise ValueError("advantage bounds must be nonnegative")
    return epsilon_key + epsilon_decode


def binomial_certificate(n: int, t: int, base: int) -> bool:
    """Check the premise and conclusion of the exponential binomial bound."""
    if min(n, t, base) < 0:
        raise ValueError("arguments must be nonnegative")
    premise = (base + 1) * t <= n + 1
    return premise and base**t <= comb(n, t)


@dataclass(frozen=True)
class ErrorSpaceReport:
    length: int
    weight: int
    count: int
    bit_length: int
    log2_count: float
    certified_bits: int
    quadratic_floor_bits: int


def error_space_report(n: int, t: int, certified_bits: int = 256) -> ErrorSpaceReport:
    """Compute an exact constant-weight count and the certified quadratic floor."""
    if not 0 <= t <= n:
        raise ValueError("require 0 <= t <= n")
    count = comb(n, t)
    if count < 2**certified_bits:
        raise ValueError("the requested power-of-two certificate is false")
    return ErrorSpaceReport(
        length=n,
        weight=t,
        count=count,
        bit_length=count.bit_length(),
        log2_count=log2(count),
        certified_bits=certified_bits,
        quadratic_floor_bits=certified_bits // 2,
    )


def demonstrate_translation(seed: int = 20260725) -> None:
    rng = Random(seed)
    n = 32
    codeword = tuple(rng.randrange(2) for _ in range(n))
    positions = rng.sample(range(n), 5)
    error = tuple(int(i in positions) for i in range(n))
    ciphertext = additive_encrypt(codeword, error)
    distance = hamming_distance(ciphertext, codeword)
    weight = hamming_weight(error)
    assert distance == weight == 5
    print("1. Translation in the Hamming cube")
    print(f"   error weight = {weight}; ciphertext distance = {distance}")


def demonstrate_game_hop() -> None:
    real, random_code = 0.514, 0.506
    epsilon_key, epsilon_decode = 0.008, 0.006
    assert abs(real - random_code) <= epsilon_key + 1e-15
    assert abs(random_code - 0.5) <= epsilon_decode + 1e-15
    actual = ind_advantage(real)
    bound = game_hop_bound(epsilon_key, epsilon_decode)
    assert actual <= bound + 1e-15
    print("2. Two-hop security accounting")
    print(f"   real advantage = {actual:.3f}; additive bound = {bound:.3f}")


def demonstrate_error_space() -> None:
    report = error_space_report(6960, 119)
    assert binomial_certificate(6960, 119, 5)
    assert 2**256 <= 5**119 <= report.count
    assert (2**128 - 1) ** 2 < report.count
    print("3. Constant-weight error space")
    print(f"   C(6960,119) has {report.bit_length} binary digits")
    print(f"   log2 C(6960,119) = {report.log2_count:.3f}")
    print("   certified chain: 2^256 <= 5^119 <= C(6960,119)")
    print("   quadratic-model floor: every q < 2^128 satisfies q^2 < C(6960,119)")


def main() -> None:
    demonstrate_translation()
    demonstrate_game_hop()
    demonstrate_error_space()


if __name__ == "__main__":
    main()
