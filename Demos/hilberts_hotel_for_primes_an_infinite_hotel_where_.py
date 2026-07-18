#!/usr/bin/env python3
"""Numerical demonstrations for dense asymptotic invisibility.

The examples construct finite-prefix extensions, enumerate Lehmer-coded
permutations, and compare prime-ratio profiles.  Only the Python standard
library is required.
"""

from __future__ import annotations

from itertools import permutations
from math import factorial
from random import Random
from typing import Iterable, Sequence


def primes_up_to_count(count: int) -> list[int]:
    """Return the first ``count`` primes using incremental trial division."""
    if count < 0:
        raise ValueError("count must be nonnegative")
    primes: list[int] = []
    candidate = 2
    while len(primes) < count:
        is_prime = True
        for prime in primes:
            if prime * prime > candidate:
                break
            if candidate % prime == 0:
                is_prime = False
                break
        if is_prime:
            primes.append(candidate)
        candidate = 3 if candidate == 2 else candidate + 2
    return primes


def complete_prefix(prefix: Sequence[int]) -> list[int]:
    """Complete distinct prescribed images to a finite permutation.

    The returned list ``tau`` represents a permutation of ``range(len(tau))``.
    It begins with ``prefix``.  Extending it by ``tau[n] = n`` beyond the list
    gives the eventually fixed infinite permutation in the theorem.
    """
    if any(value < 0 for value in prefix):
        raise ValueError("targets must be nonnegative")
    if len(set(prefix)) != len(prefix):
        raise ValueError("prescribed targets must be distinct")
    k = len(prefix)
    maximum = max(prefix, default=-1)
    size = max(k, maximum + 1)
    used = set(prefix)
    unused_targets = [value for value in range(size) if value not in used]
    tau = list(prefix) + unused_targets
    assert sorted(tau) == list(range(size))
    return tau


def extend_identity(finite_permutation: Sequence[int], length: int) -> list[int]:
    """Extend a finite permutation by the identity up to ``length``."""
    size = len(finite_permutation)
    if sorted(finite_permutation) != list(range(size)):
        raise ValueError("input must be a permutation of its index range")
    if length < size:
        raise ValueError("length must cover the finite permutation")
    return list(finite_permutation) + list(range(size, length))


def ratio_profile(values: Sequence[float], permutation: Sequence[int]) -> list[float]:
    """Compute ``values[permutation[n]] / values[n]``."""
    if len(values) != len(permutation):
        raise ValueError("values and permutation must have equal lengths")
    if any(index < 0 or index >= len(values) for index in permutation):
        raise ValueError("permutation index is outside the value range")
    if any(value == 0 for value in values):
        raise ZeroDivisionError("ratio profile requires nonzero denominators")
    return [values[permutation[n]] / values[n] for n in range(len(values))]


def lehmer_decode(code: Sequence[int]) -> list[int]:
    """Decode a Lehmer code with digit bound ``0 <= code[i] < k-i``."""
    available = list(range(len(code)))
    result: list[int] = []
    for digit in code:
        if digit < 0 or digit >= len(available):
            raise ValueError("invalid Lehmer digit")
        result.append(available.pop(digit))
    return result


def lehmer_encode(permutation: Sequence[int]) -> list[int]:
    """Encode a finite permutation as its Lehmer code."""
    if sorted(permutation) != list(range(len(permutation))):
        raise ValueError("input must be a permutation")
    available = list(range(len(permutation)))
    code: list[int] = []
    for value in permutation:
        position = available.index(value)
        code.append(position)
        available.pop(position)
    return code


def random_prefix_experiment(seed: int = 20260718, trials: int = 10) -> None:
    """Show that arbitrary random finite prefixes admit ratio-one extensions."""
    rng = Random(seed)
    primes = primes_up_to_count(40)
    print("\nRandom finite-prefix completions")
    print("trial  prefix             support bound  tail ratios")
    for trial in range(trials):
        pool = list(range(12))
        rng.shuffle(pool)
        prefix = pool[:5]
        finite = complete_prefix(prefix)
        extended = extend_identity(finite, len(primes))
        ratios = ratio_profile([float(p) for p in primes], extended)
        tail = ratios[len(finite):]
        assert all(value == 1.0 for value in tail)
        print(f"{trial + 1:>5}  {str(prefix):<18} {len(finite):>13}  {tail[:4]}")


def factorial_family_demo(k: int = 6) -> None:
    """Enumerate finite permutations and verify the factorial count."""
    decoded: set[tuple[int, ...]] = set()
    for permutation in permutations(range(k)):
        code = lehmer_encode(permutation)
        recovered = tuple(lehmer_decode(code))
        assert recovered == permutation
        decoded.add(recovered)
    expected = factorial(k)
    assert len(decoded) == expected
    print(f"\nLehmer family for k={k}: {len(decoded)} distinct extensions = {k}! = {expected}")


def print_profile(label: str, values: Sequence[int], permutation: Sequence[int]) -> None:
    """Print a compact exact-index ratio table."""
    ratios = ratio_profile([float(value) for value in values], permutation)
    print(f"\n{label}")
    print(" n   a[n]  tau[n]  a[tau[n]]/a[n]")
    for n, ratio in enumerate(ratios):
        print(f"{n:2d}  {values[n]:5d}  {permutation[n]:6d}  {ratio:17.8f}")


def main() -> None:
    """Run all demonstrations."""
    primes = primes_up_to_count(15)
    finite = complete_prefix([3, 0, 4])
    extended = extend_identity(finite, len(primes))
    print("Finite-prefix extension:", finite)
    print("Identity-extended permutation:", extended)
    print_profile("Prime-hotel ratio profile", primes, extended)
    assert all(ratio == 1.0 for ratio in ratio_profile(primes, extended)[len(finite):])

    factorial_family_demo(6)
    random_prefix_experiment()

    print("\nConclusion: every displayed finite disturbance is followed by ratios exactly equal to 1.")


if __name__ == "__main__":
    main()
