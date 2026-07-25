"""Numerical demonstrations of affine rerandomization and LWE error bounds."""
from __future__ import annotations

from collections import Counter
from math import sqrt
from typing import Iterable, Sequence


def affine_permutation(p: int, a: int, b: int) -> list[int]:
    """Return the values a*x+b modulo prime p, rejecting noninvertible a."""
    if p <= 1 or a % p == 0:
        raise ValueError("p must exceed 1 and a must be nonzero modulo p")
    values = [(a * x + b) % p for x in range(p)]
    if len(set(values)) != p:
        raise ValueError("parameters do not define a permutation; use prime p")
    return values


def accumulated_noise(errors: Iterable[float], bound: float) -> tuple[float, float]:
    """Return absolute accumulated noise and its deterministic m*bound ceiling."""
    values = list(errors)
    if bound < 0 or any(abs(e) > bound + 1e-12 for e in values):
        raise ValueError("every error must have magnitude at most bound")
    return abs(sum(values)), len(values) * bound


def decode_bit(value: float, q: float) -> int:
    """Decode to the nearer of 0 and q/2 on the circle modulo q."""
    if q <= 0:
        raise ValueError("q must be positive")
    y = value % q
    circular_zero_distance = min(y, q - y)
    one_distance = abs(y - q / 2.0)
    return 0 if circular_zero_distance < one_distance else 1


def encode_noisy_bit(bit: int, q: float, error: float) -> float:
    """Encode bit at 0 or q/2 and add error smaller than q/4."""
    if bit not in (0, 1) or q <= 0 or abs(error) >= q / 4.0:
        raise ValueError("require a bit, q > 0, and |error| < q/4")
    return bit * (q / 2.0) + error


def post_switch_error(lwe_error: float, rounding_errors: Sequence[float]) -> float:
    """Compute the signed combined error after modulus switching."""
    return lwe_error + sum(rounding_errors)


def best_coordinate(total_gap: float, gaps: Sequence[float]) -> tuple[int, float, float]:
    """Return a maximal gap and the guaranteed total_gap/n threshold."""
    if not gaps or total_gap > sum(gaps) + 1e-12:
        raise ValueError("need nonempty gaps whose sum dominates the total gap")
    index = max(range(len(gaps)), key=gaps.__getitem__)
    return index, gaps[index], total_gap / len(gaps)


def amplified_success_probability(p: float, k: int) -> float:
    """Probability of at least one success in k independent trials."""
    if not 0.0 <= p <= 1.0 or k <= 0:
        raise ValueError("require 0 <= p <= 1 and k > 0")
    return 1.0 - (1.0 - p) ** k


def run_demo() -> None:
    p, a, b = 17, 5, 8
    image = affine_permutation(p, a, b)
    print("Affine permutation over Z/17Z:", image)
    print("Every residue appears once:", Counter(image) == Counter(range(p)))

    q = 128.0
    for bit, error in [(0, 19.0), (1, -23.0)]:
        received = encode_noisy_bit(bit, q, error)
        print(f"bit={bit}, error={error:+.1f}, received={received:.1f}, decoded={decode_bit(received, q)}")

    errors = [1.5, -2.0, 0.75, 2.25, -1.0]
    actual, ceiling = accumulated_noise(errors, 2.25)
    print(f"Accumulated magnitude {actual:.2f} <= deterministic ceiling {ceiling:.2f}")

    lwe_error = 4.0
    rounding = [0.5, -0.25, 0.75, 0.1]
    combined = post_switch_error(lwe_error, rounding)
    budget = abs(lwe_error) + len(rounding) * 0.75
    print(f"Post-switch error {combined:.2f}; budget {budget:.2f}; q/4={q/4:.2f}")

    gaps = [0.01, 0.025, 0.04, 0.015]
    index, gap, threshold = best_coordinate(0.08, gaps)
    print(f"Coordinate {index} has gap {gap:.3f} >= guaranteed {threshold:.3f}")

    p_success, repetitions = 0.18, 8
    boosted = amplified_success_probability(p_success, repetitions)
    print(f"Success amplification: {p_success:.3f} -> {boosted:.3f} after {repetitions} trials")

    n, modulus = 256, 4096.0
    alpha_min = 2.0 * sqrt(n) / modulus
    print(f"Tradeoff threshold alpha >= {alpha_min:.6f}; alpha*q >= {2*sqrt(n):.1f}")


if __name__ == "__main__":
    run_demo()
