#!/usr/bin/env python3
"""Numerical demonstrations of factorial codes and their symmetric-group action."""

from __future__ import annotations

from itertools import permutations, product
from math import factorial, gcd, lcm
from typing import Iterable, Sequence

Permutation = tuple[int, ...]
FactorialCode = tuple[int, ...]  # increasing radices 1, 2, ..., k


def validate_permutation(p: Sequence[int]) -> None:
    """Raise ValueError unless p is a permutation of range(len(p))."""
    if sorted(p) != list(range(len(p))):
        raise ValueError("input must contain each integer from 0 to k-1 exactly once")


def validate_code(code: Sequence[int]) -> None:
    """Raise ValueError unless code[i] lies in range(i + 1)."""
    if any(d < 0 or d > i for i, d in enumerate(code)):
        raise ValueError("factorial digit code[i] must satisfy 0 <= code[i] <= i")


def encode_permutation(p: Sequence[int]) -> FactorialCode:
    """Encode a permutation as an increasing-radix Lehmer code in O(k^2) time."""
    validate_permutation(p)
    unused = list(range(len(p)))
    decreasing: list[int] = []
    for value in p:
        index = unused.index(value)
        decreasing.append(index)
        unused.pop(index)
    return tuple(reversed(decreasing))


def decode_code(code: Sequence[int]) -> Permutation:
    """Decode an increasing-radix Lehmer code in O(k^2) time."""
    validate_code(code)
    unused = list(range(len(code)))
    output: list[int] = []
    for index in reversed(code):
        output.append(unused.pop(index))
    return tuple(output)


def rank_code(code: Sequence[int]) -> int:
    """Map a length-k factorial code bijectively to an integer in [0, k!)."""
    validate_code(code)
    return sum(digit * factorial(i) for i, digit in enumerate(code))


def unrank_code(rank: int, k: int) -> FactorialCode:
    """Recover the unique length-k factorial code with the given rank."""
    if k < 0 or rank < 0 or rank >= factorial(k):
        raise ValueError("rank must satisfy 0 <= rank < k!")
    digits: list[int] = []
    remaining = rank
    for radix in range(1, k + 1):
        digits.append(remaining % radix)
        remaining //= radix
    return tuple(digits)


def compose(left: Sequence[int], right: Sequence[int]) -> Permutation:
    """Return left after right: (left * right)(i) = left[right[i]]."""
    validate_permutation(left)
    validate_permutation(right)
    if len(left) != len(right):
        raise ValueError("permutations must have equal lengths")
    return tuple(left[right[i]] for i in range(len(left)))


def inverse(p: Sequence[int]) -> Permutation:
    """Return the inverse permutation."""
    validate_permutation(p)
    result = [0] * len(p)
    for i, value in enumerate(p):
        result[value] = i
    return tuple(result)


def act(sigma: Sequence[int], code: Sequence[int]) -> FactorialCode:
    """Apply the transported left symmetric-group action to a code."""
    if len(sigma) != len(code):
        raise ValueError("permutation and code must have equal lengths")
    return encode_permutation(compose(sigma, decode_code(code)))


def transporter(source: Sequence[int], target: Sequence[int]) -> Permutation:
    """Return the unique permutation carrying source to target."""
    if len(source) != len(target):
        raise ValueError("codes must have equal lengths")
    source_perm = decode_code(source)
    target_perm = decode_code(target)
    return compose(target_perm, inverse(source_perm))


def additive_order(residues: Sequence[int], moduli: Sequence[int]) -> int:
    """Compute the additive order of a tuple in a product of cyclic groups."""
    if len(residues) != len(moduli) or any(m <= 0 for m in moduli):
        raise ValueError("residues and positive moduli must have equal lengths")
    orders = [m // gcd(r % m, m) for r, m in zip(residues, moduli)]
    return lcm(*orders)


def demonstrate_round_trips(k: int = 5) -> None:
    """Exhaustively check encoding, decoding, ranking, and counting."""
    all_perms = list(permutations(range(k)))
    codes = [encode_permutation(p) for p in all_perms]
    assert len(set(codes)) == factorial(k)
    assert all(decode_code(c) == p for p, c in zip(all_perms, codes))
    assert {rank_code(c) for c in codes} == set(range(factorial(k)))
    assert all(rank_code(unrank_code(n, k)) == n for n in range(factorial(k)))
    sample = (3, 1, 4, 0, 2) if k == 5 else all_perms[-1]
    code = encode_permutation(sample)
    print(f"Length {k}: {len(codes)} distinct codes = {k}! = {factorial(k)}")
    print(f"Example permutation {sample} -> code {code} -> rank {rank_code(code)}")


def demonstrate_torsor(k: int = 4) -> None:
    """Exhaustively check existence and uniqueness of every transporter."""
    codes = [unrank_code(n, k) for n in range(factorial(k))]
    group = list(permutations(range(k)))
    for source in codes:
        images = [act(sigma, source) for sigma in group]
        assert len(set(images)) == factorial(k)  # free and transitive at source
        for target in codes:
            sigma = transporter(source, target)
            assert act(sigma, source) == target
            assert sum(act(g, source) == target for g in group) == 1
    source, target = codes[5], codes[19]
    sigma = transporter(source, target)
    print(f"Unique transporter at length {k}: {source} --{sigma}--> {target}")


def demonstrate_crt_boundary() -> None:
    """Compare exponents at length four and exhibit the additive obstruction."""
    moduli = (2, 3, 4)
    elements = list(product(*(range(m) for m in moduli)))
    orders = [additive_order(x, moduli) for x in elements]
    product_exponent = lcm(*orders)
    cyclic_exponent = 24
    assert len(elements) == 24
    assert product_exponent == 12
    assert max(orders) == 12
    assert cyclic_exponent == 24
    print("Both additive sets have 24 elements.")
    print(f"Exponent of Z/2 x Z/3 x Z/4: {product_exponent}")
    print(f"Exponent of Z/24: {cyclic_exponent}")
    print("Different exponents rule out an additive isomorphism.")


def main() -> None:
    demonstrate_round_trips()
    print()
    demonstrate_torsor()
    print()
    demonstrate_crt_boundary()


if __name__ == "__main__":
    main()
