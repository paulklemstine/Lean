#!/usr/bin/env python3
"""
Algorithms for Mixed-Radix Product Encodings

Implements the core encoding/decoding algorithms with full generality:
fixed-base, mixed-radix, and n-ary product encodings.
"""

from typing import Sequence
import math


class MixedRadixEncoder:
    """
    Encodes and decodes tuples via mixed-radix (positional) number systems.
    
    Given radices [r_0, r_1, ..., r_{n-1}], encodes a tuple (d_0, ..., d_{n-1})
    where 0 <= d_i < r_i as:
    
        code = d_0 * (r_1 * r_2 * ... * r_{n-1})
             + d_1 * (r_2 * ... * r_{n-1})
             + ...
             + d_{n-1}
    
    This is the n-ary generalization of the binary product encoding theorem.
    """
    
    def __init__(self, radices: Sequence[int]):
        """
        Initialize with a sequence of radices.
        
        Args:
            radices: List of positive integers [r_0, r_1, ..., r_{n-1}].
        """
        if any(r < 1 for r in radices):
            raise ValueError("All radices must be >= 1")
        self.radices = list(radices)
        self.n = len(radices)
        
        # Precompute weight of each position
        self.weights = [1] * self.n
        for i in range(self.n - 2, -1, -1):
            self.weights[i] = self.weights[i + 1] * self.radices[i + 1]
        
        self.total_codes = math.prod(radices) if radices else 1
    
    def encode(self, digits: Sequence[int]) -> int:
        """
        Encode a tuple of digits into a single integer.
        
        Args:
            digits: Tuple (d_0, ..., d_{n-1}) with 0 <= d_i < r_i.
        
        Returns:
            Integer in [0, product of radices).
        """
        if len(digits) != self.n:
            raise ValueError(f"Expected {self.n} digits, got {len(digits)}")
        
        code = 0
        for i, (d, w) in enumerate(zip(digits, self.weights)):
            if not (0 <= d < self.radices[i]):
                raise ValueError(
                    f"Digit {i} = {d} out of range [0, {self.radices[i]})")
            code += d * w
        return code
    
    def decode(self, code: int) -> list[int]:
        """
        Decode an integer back into a tuple of digits.
        
        Args:
            code: Integer in [0, product of radices).
        
        Returns:
            List [d_0, ..., d_{n-1}].
        """
        if not (0 <= code < self.total_codes):
            raise ValueError(f"Code {code} out of range [0, {self.total_codes})")
        
        digits = []
        remaining = code
        for i in range(self.n):
            digits.append(remaining // self.weights[i])
            remaining %= self.weights[i]
        return digits
    
    def verify_bijection(self) -> bool:
        """Verify that encode is a bijection by exhaustive testing."""
        if self.total_codes > 10_000_000:
            raise ValueError("Too many codes for exhaustive verification")
        
        seen = set()
        for code in range(self.total_codes):
            digits = self.decode(code)
            re_encoded = self.encode(digits)
            if re_encoded != code:
                return False
            seen.add(code)
        return len(seen) == self.total_codes


class BinaryProductEncoder:
    """
    Specialized encoder for binary (base-2) product encodings.
    
    Encodes α × β → Fin(2^(k+ℓ)) via the formula:
        f(a, b) = f_α(a) * 2^ℓ + f_β(b)
    
    This is the exact algorithm formalized in the main theorem.
    """
    
    def __init__(self, k: int, ell: int):
        """
        Args:
            k: Number of bits for the first component.
            ell: Number of bits for the second component.
        """
        self.k = k
        self.ell = ell
        self.base_ell = 2 ** ell
        self.codomain_size = 2 ** (k + ell)
    
    def encode(self, a: int, b: int) -> int:
        """Encode (a, b) where a < 2^k and b < 2^ℓ."""
        assert 0 <= a < 2 ** self.k, f"a={a} out of range"
        assert 0 <= b < 2 ** self.ell, f"b={b} out of range"
        return a * self.base_ell + b
    
    def decode(self, code: int) -> tuple[int, int]:
        """Decode back to (a, b)."""
        return divmod(code, self.base_ell)
    
    def to_binary(self, code: int) -> str:
        """Show the binary representation with block structure."""
        total_bits = self.k + self.ell
        bits = format(code, f'0{total_bits}b')
        return f"{bits[:self.k]}|{bits[self.k:]}"


def demonstrate_mixed_radix():
    """Show mixed-radix encoding for various radix systems."""
    print("Mixed-Radix Encoder Demonstrations")
    print("=" * 50)
    
    # Example 1: Time encoding (hours, minutes, seconds)
    enc = MixedRadixEncoder([24, 60, 60])
    print(f"\nTime encoding (24h × 60m × 60s = {enc.total_codes} codes):")
    examples = [(0, 0, 0), (12, 30, 45), (23, 59, 59)]
    for h, m, s in examples:
        code = enc.encode([h, m, s])
        decoded = enc.decode(code)
        print(f"  {h:02d}:{m:02d}:{s:02d} -> code {code:>5} -> {decoded}")
    
    # Example 2: Date encoding (month, day)
    enc2 = MixedRadixEncoder([12, 31])
    print(f"\nMonth-Day encoding (12 × 31 = {enc2.total_codes} codes):")
    for m, d in [(0, 0), (5, 14), (11, 30)]:
        code = enc2.encode([m, d])
        decoded = enc2.decode(code)
        print(f"  month={m}, day={d} -> code {code:>3} -> {decoded}")
    
    # Example 3: Binary product
    enc3 = MixedRadixEncoder([8, 4])  # 2^3 × 2^2
    print(f"\nBinary: Fin(8) × Fin(4) -> Fin({enc3.total_codes}):")
    for a in range(8):
        for b in range(4):
            code = enc3.encode([a, b])
            assert code == a * 4 + b
    print(f"  All {enc3.total_codes} encode/decode pairs verified ✓")
    assert enc3.verify_bijection()
    print(f"  Bijection verified ✓")


def demonstrate_binary():
    """Show binary product encoding with bit-level detail."""
    print("\n\nBinary Product Encoder")
    print("=" * 50)
    
    enc = BinaryProductEncoder(k=3, ell=2)
    print(f"\nFin(2^3) × Fin(2^2) -> Fin(2^5 = {enc.codomain_size})")
    print(f"Formula: f(a,b) = a * {enc.base_ell} + b\n")
    
    print(f"{'(a,b)':<10} {'Code':>5} {'Binary (a|b)':>14}")
    print("-" * 35)
    for a in range(2**3):
        for b in range(2**2):
            code = enc.encode(a, b)
            binary = enc.to_binary(code)
            print(f"({a},{b})     {code:>5} {binary:>14}")


def complexity_analysis():
    """Analyze the computational complexity of the encoding."""
    print("\n\nComplexity Analysis")
    print("=" * 50)
    
    import time
    
    for n_components in [2, 5, 10, 20]:
        radices = [4] * n_components  # All base-4
        enc = MixedRadixEncoder(radices)
        
        # Time encoding
        digits = [2] * n_components
        start = time.perf_counter()
        for _ in range(100_000):
            enc.encode(digits)
        elapsed = time.perf_counter() - start
        
        print(f"  {n_components} components (base 4): "
              f"100k encodes in {elapsed:.3f}s, "
              f"codomain size = 4^{n_components} = {enc.total_codes}")


if __name__ == "__main__":
    demonstrate_mixed_radix()
    demonstrate_binary()
    complexity_analysis()
