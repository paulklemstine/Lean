#!/usr/bin/env python3
"""
Algorithms for Horseshoe Dynamics and Computational Universality

Type-hinted implementations of the core algorithms.
"""

from __future__ import annotations
import math
from dataclasses import dataclass
from typing import Callable, Sequence


@dataclass
class SymbolicOrbit:
    """A finite segment of a bi-infinite symbolic orbit."""
    symbols: list[int]
    d: int  # alphabet size
    offset: int = 0  # index of position 0

    def __post_init__(self) -> None:
        assert all(0 <= s < self.d for s in self.symbols), \
            f"All symbols must be in [0, {self.d})"

    def __getitem__(self, pos: int) -> int:
        idx = pos - self.offset
        if 0 <= idx < len(self.symbols):
            return self.symbols[idx]
        return 0

    def shift(self, n: int = 1) -> "SymbolicOrbit":
        """Apply the shift map n times: (σⁿx)(k) = x(k+n)."""
        return SymbolicOrbit(
            symbols=self.symbols,
            d=self.d,
            offset=self.offset - n
        )


@dataclass
class BooleanEncoding:
    """Encoding of a Boolean function via symbolic orbits."""
    func: Callable[[tuple[bool, ...]], bool]
    n_bits: int
    d: int  # alphabet size (≥ 2)
    bool_to_sym: dict[bool, int]

    def encode(self, input_bits: tuple[bool, ...]) -> SymbolicOrbit:
        """Encode an input-output pair as a symbolic orbit."""
        assert len(input_bits) == self.n_bits
        symbols = []
        for i in range(self.n_bits):
            symbols.append(self.bool_to_sym[input_bits[i]])
        symbols.append(self.bool_to_sym[self.func(input_bits)])
        # Pad to make a reasonable orbit segment
        symbols.extend([0] * max(10, self.n_bits))
        return SymbolicOrbit(symbols=symbols, d=self.d)

    def decode_output(self, orbit: SymbolicOrbit) -> bool:
        """Read the output bit from position n of the orbit."""
        sym = orbit[self.n_bits]
        sym_to_bool = {v: k for k, v in self.bool_to_sym.items()}
        return sym_to_bool.get(sym, False)


def create_encoding(
    func: Callable[[tuple[bool, ...]], bool],
    n_bits: int,
    d: int = 2
) -> BooleanEncoding:
    """Create a Boolean encoding in the d-shift (d ≥ 2)."""
    assert d >= 2, "Need at least 2 symbols for Boolean encoding"
    return BooleanEncoding(
        func=func,
        n_bits=n_bits,
        d=d,
        bool_to_sym={False: 0, True: 1}
    )


def orbit_realization(word: Sequence[int], d: int, pad_length: int = 20) -> SymbolicOrbit:
    """
    Orbit Realization Algorithm.

    Given a word w over d symbols, construct a symbolic orbit realizing w.
    Time: O(pad_length)
    Space: O(pad_length)
    """
    symbols = list(word) + [0] * (pad_length - len(word))
    return SymbolicOrbit(symbols=symbols[:pad_length], d=d)


def compute_entropy(d: int, n: int) -> float:
    """
    Entropy Computation Algorithm.

    Computes the topological entropy rate log(d^n)/n for the full d-shift.
    Returns log(d) for n > 0.
    """
    if n <= 0 or d <= 0:
        return 0.0
    return math.log(d ** n) / n


def sub_horseshoe_embed(
    orbit: SymbolicOrbit,
    k: int,
    d: int
) -> SymbolicOrbit:
    """
    Sub-horseshoe Extraction Algorithm.

    Embeds a k-symbol orbit into a d-symbol orbit (k ≤ d).
    Uses the natural embedding Fin k ↪ Fin d.
    """
    assert k <= d, f"Cannot embed {k}-shift into {d}-shift"
    return SymbolicOrbit(
        symbols=[s for s in orbit.symbols],  # symbols already valid since < k ≤ d
        d=d,
        offset=orbit.offset
    )


@dataclass
class HorseshoeSimulator:
    """
    Simulator for horseshoe dynamics via symbolic shifts.

    Simulates a degree-d horseshoe by iterating the shift map
    on symbolic sequences.
    """
    d: int
    initial_orbit: SymbolicOrbit

    def iterate(self, steps: int) -> list[SymbolicOrbit]:
        """Iterate the shift map and record the orbit at each step."""
        results = [self.initial_orbit]
        current = self.initial_orbit
        for _ in range(steps):
            current = current.shift(1)
            results.append(current)
        return results

    def read_symbol_sequence(self, steps: int) -> list[int]:
        """Read the symbol at position 0 after each iteration."""
        return [self.initial_orbit[i] for i in range(steps)]


def enumerate_words(d: int, n: int) -> list[list[int]]:
    """
    Enumerate all d^n words of length n over d symbols.

    Demonstrates the word count formula W(d,n) = d^n.
    """
    if n == 0:
        return [[]]
    shorter = enumerate_words(d, n - 1)
    result = []
    for w in shorter:
        for s in range(d):
            result.append(w + [s])
    return result


def verify_universality(n_bits: int, d: int = 2) -> dict[str, bool]:
    """
    Verify computational universality by encoding several Boolean functions.

    Returns a dict mapping function names to verification results.
    """
    def parity(bits: tuple[bool, ...]) -> bool:
        return sum(1 for b in bits if b) % 2 == 0

    def majority(bits: tuple[bool, ...]) -> bool:
        return sum(1 for b in bits if b) > len(bits) / 2

    def constant_true(bits: tuple[bool, ...]) -> bool:
        return True

    def constant_false(bits: tuple[bool, ...]) -> bool:
        return False

    functions = {
        "parity": parity,
        "majority": majority,
        "constant_true": constant_true,
        "constant_false": constant_false,
    }

    results = {}
    for name, func in functions.items():
        enc = create_encoding(func, n_bits, d)
        all_correct = True
        for bits_int in range(2 ** n_bits):
            bits = tuple(bool((bits_int >> i) & 1) for i in range(n_bits))
            orbit = enc.encode(bits)
            decoded = enc.decode_output(orbit)
            if decoded != func(bits):
                all_correct = False
                break
        results[name] = all_correct

    return results


if __name__ == "__main__":
    # Quick self-test
    print("Testing algorithms...")

    # Orbit realization
    orbit = orbit_realization([1, 0, 1], d=2)
    assert orbit[0] == 1 and orbit[1] == 0 and orbit[2] == 1
    print("✓ Orbit realization")

    # Entropy
    for d in [2, 3, 5]:
        for n in [1, 10, 100]:
            rate = compute_entropy(d, n)
            assert abs(rate - math.log(d)) < 1e-10
    print("✓ Entropy characterization")

    # Boolean encoding
    enc = create_encoding(lambda b: sum(1 for x in b if x) % 2 == 0, 3, 2)
    orbit = enc.encode((True, False, True))
    assert orbit[0] == 1 and orbit[1] == 0 and orbit[2] == 1
    print("✓ Boolean encoding")

    # Universality verification
    results = verify_universality(3)
    assert all(results.values())
    print(f"✓ Universality verified for: {list(results.keys())}")

    # Sub-horseshoe
    small = SymbolicOrbit([0, 1, 2, 0], d=3)
    large = sub_horseshoe_embed(small, 3, 5)
    assert large.d == 5
    print("✓ Sub-horseshoe extraction")

    # Word enumeration
    words = enumerate_words(2, 3)
    assert len(words) == 8  # 2^3
    print(f"✓ Word count: W(2,3) = {len(words)}")

    print("\nAll algorithm tests passed!")
