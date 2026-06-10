"""
Algorithms for CRT Channel Codes

Implements the core algorithms for constructing, encoding, decoding,
and analyzing prime-channel codes based on the Chinese Remainder Theorem.

Time complexity analysis:
- Encoding: O(n) per codeword (n = code length)
- Decoding: O(n · |C|) per received word (|C| = code size)
- Syndrome computation: O(n)
- Channel projection: O(n)

Space complexity: O(n · |C|) for storing the code
"""

from typing import List, Tuple, Optional, Dict
import numpy as np
from dataclasses import dataclass


def extended_gcd(a: int, b: int) -> Tuple[int, int, int]:
    """Extended Euclidean algorithm.
    
    Returns (gcd, x, y) such that a*x + b*y = gcd(a, b).
    
    Time: O(log(min(a, b)))
    Space: O(log(min(a, b))) due to recursion
    """
    if a == 0:
        return b, 0, 1
    gcd, x1, y1 = extended_gcd(b % a, a)
    return gcd, y1 - (b // a) * x1, x1


def mod_inverse(a: int, m: int) -> int:
    """Compute modular inverse of a modulo m.
    
    Requires gcd(a, m) = 1.
    Time: O(log m)
    """
    g, x, _ = extended_gcd(a % m, m)
    if g != 1:
        raise ValueError(f"No inverse: gcd({a}, {m}) = {g}")
    return x % m


@dataclass
class CRTDecomposition:
    """Represents a CRT decomposition of Z/(m₁·m₂·...·mₖ)Z.
    
    Stores the moduli and precomputed reconstruction coefficients.
    """
    moduli: List[int]
    product: int
    # Precomputed: M_i = product / m_i, and y_i = M_i^{-1} mod m_i
    partial_products: List[int]
    inverses: List[int]
    
    @classmethod
    def from_moduli(cls, moduli: List[int]) -> 'CRTDecomposition':
        """Construct CRT decomposition from a list of pairwise coprime moduli.
        
        Time: O(k · log(max(m_i))) where k = len(moduli)
        """
        product = 1
        for m in moduli:
            product *= m
        
        partial_products = [product // m for m in moduli]
        inverses = [mod_inverse(M, m) for M, m in zip(partial_products, moduli)]
        
        return cls(moduli=moduli, product=product,
                   partial_products=partial_products, inverses=inverses)
    
    def encode(self, x: int) -> List[int]:
        """Project x ∈ Z/NZ onto its channel components.
        
        Time: O(k)
        """
        return [x % m for m in self.moduli]
    
    def decode(self, components: List[int]) -> int:
        """Reconstruct x from its channel components.
        
        Time: O(k)
        """
        result = 0
        for a_i, M_i, y_i in zip(components, self.partial_products, self.inverses):
            result += a_i * M_i * y_i
        return result % self.product


@dataclass
class CRTChannelCode:
    """A channel code using CRT decomposition for per-channel error correction.
    
    The code is a subset of (Z/NZ)^n where N = m₁·m₂·...·mₖ.
    Each codeword decomposes into k independent channel codewords.
    """
    crt: CRTDecomposition
    length: int
    codewords: List[List[int]]
    
    def encode_word(self, word: List[int]) -> List[List[int]]:
        """Project a word onto all channels.
        
        Returns: List of channel projections, one per channel.
        Time: O(n · k)
        """
        return [[self.crt.encode(word[i])[ch] for i in range(self.length)]
                for ch in range(len(self.crt.moduli))]
    
    def channel_projection(self, word: List[int], channel: int) -> List[int]:
        """Project a word onto a specific channel.
        
        Time: O(n)
        """
        return [self.crt.encode(word[i])[channel] for i in range(self.length)]
    
    def syndrome(self, received: List[int], codeword: List[int], channel: int) -> List[int]:
        """Compute the syndrome on a specific channel.
        
        The syndrome is the difference of channel projections.
        Time: O(n)
        """
        m = self.crt.moduli[channel]
        proj_r = self.channel_projection(received, channel)
        proj_c = self.channel_projection(codeword, channel)
        return [(r - c) % m for r, c in zip(proj_r, proj_c)]
    
    def hamming_distance(self, a: List[int], b: List[int]) -> int:
        """Compute Hamming distance between two words.
        
        Time: O(n)
        """
        return sum(1 for x, y in zip(a, b) if x != y)
    
    def channel_hamming_distance(self, a: List[int], b: List[int], channel: int) -> int:
        """Compute Hamming distance on a specific channel.
        
        Time: O(n)
        """
        proj_a = self.channel_projection(a, channel)
        proj_b = self.channel_projection(b, channel)
        return sum(1 for x, y in zip(proj_a, proj_b) if x != y)
    
    def minimum_distance(self) -> int:
        """Compute the minimum distance of the code.
        
        Time: O(|C|² · n)
        """
        if len(self.codewords) < 2:
            return 0
        min_d = float('inf')
        for i, c1 in enumerate(self.codewords):
            for c2 in self.codewords[i+1:]:
                d = self.hamming_distance(c1, c2)
                min_d = min(min_d, d)
        return min_d
    
    def decode_nearest(self, received: List[int]) -> Optional[List[int]]:
        """Nearest-codeword decoding.
        
        Time: O(|C| · n)
        """
        best = None
        best_dist = float('inf')
        for cw in self.codewords:
            d = self.hamming_distance(received, cw)
            if d < best_dist:
                best_dist = d
                best = cw
        return best
    
    def decode_channel(self, received: List[int], error_free_channels: List[int]) -> Optional[List[int]]:
        """Channel-aware decoding: use error-free channels to narrow candidates.
        
        This implements the key insight: errors in one channel don't affect
        other channels, so error-free channels can identify the codeword.
        
        Time: O(|C| · n · k)
        """
        candidates = self.codewords
        
        # Filter by error-free channels
        for ch in error_free_channels:
            received_proj = self.channel_projection(received, ch)
            candidates = [cw for cw in candidates
                         if self.channel_projection(cw, ch) == received_proj]
        
        if not candidates:
            return None
        if len(candidates) == 1:
            return candidates[0]
        
        # Among remaining candidates, pick closest
        best = None
        best_dist = float('inf')
        for cw in candidates:
            d = self.hamming_distance(received, cw)
            if d < best_dist:
                best_dist = d
                best = cw
        return best
    
    def singleton_bound(self) -> int:
        """Compute the Singleton bound for this code.
        
        |C| ≤ q^(n - d + 1) where q = alphabet size, d = minimum distance
        """
        q = self.crt.product
        d = self.minimum_distance()
        return q ** (self.length - d + 1) if d > 0 else q ** self.length
    
    def verify_singleton_bound(self) -> bool:
        """Verify the Singleton bound holds for this code."""
        return len(self.codewords) <= self.singleton_bound()
    
    def verify_channel_nonexpansive(self, num_trials: int = 100) -> bool:
        """Verify that channel projection is non-expansive (Hamming distance).
        
        Tests: d_ch(π(w₁), π(w₂)) ≤ d(w₁, w₂) for random pairs.
        """
        for _ in range(num_trials):
            w1 = [np.random.randint(self.crt.product) for _ in range(self.length)]
            w2 = [np.random.randint(self.crt.product) for _ in range(self.length)]
            full_dist = self.hamming_distance(w1, w2)
            for ch in range(len(self.crt.moduli)):
                ch_dist = self.channel_hamming_distance(w1, w2, ch)
                if ch_dist > full_dist:
                    return False
        return True


def build_repetition_code(crt: CRTDecomposition, length: int) -> CRTChannelCode:
    """Build a repetition code over Z/NZ.
    
    Each symbol s ∈ Z/NZ maps to the codeword (s, s, ..., s).
    Minimum distance = length (for distinct symbols).
    """
    codewords = [[s] * length for s in range(crt.product)]
    return CRTChannelCode(crt=crt, length=length, codewords=codewords)


def build_parity_check_code(crt: CRTDecomposition, length: int) -> CRTChannelCode:
    """Build a single parity-check code over Z/NZ.
    
    Codewords: all words of length `length` where the sum of symbols ≡ 0 (mod N).
    Minimum distance = 2.
    """
    N = crt.product
    from itertools import product as cart_product
    
    if length <= 3 and N <= 6:  # Only for small cases
        codewords = []
        for w in cart_product(range(N), repeat=length):
            if sum(w) % N == 0:
                codewords.append(list(w))
        return CRTChannelCode(crt=crt, length=length, codewords=codewords)
    else:
        # For larger cases, just generate some codewords
        codewords = []
        for _ in range(min(100, N ** (length - 1))):
            prefix = [np.random.randint(N) for _ in range(length - 1)]
            last = (N - sum(prefix) % N) % N
            codewords.append(prefix + [last])
        # Remove duplicates
        seen = set()
        unique = []
        for cw in codewords:
            key = tuple(cw)
            if key not in seen:
                seen.add(key)
                unique.append(cw)
        return CRTChannelCode(crt=crt, length=length, codewords=unique)


# =============================================================================
# Example usage
# =============================================================================
if __name__ == "__main__":
    print("CRT Channel Code Algorithms")
    print("=" * 50)
    
    # Two-channel code over Z/6Z
    crt = CRTDecomposition.from_moduli([2, 3])
    print(f"\nCRT decomposition: Z/{crt.product}Z ≅ " + 
          " × ".join(f"Z/{m}Z" for m in crt.moduli))
    
    # Verify CRT
    for x in range(crt.product):
        components = crt.encode(x)
        reconstructed = crt.decode(components)
        assert reconstructed == x, f"CRT failed for {x}"
    print("CRT reconstruction verified ✓")
    
    # Build repetition code
    code = build_repetition_code(crt, length=4)
    print(f"\nRepetition code: {len(code.codewords)} codewords, length {code.length}")
    print(f"Minimum distance: {code.minimum_distance()}")
    print(f"Singleton bound: |C| ≤ {code.singleton_bound()}")
    print(f"Bound satisfied: {code.verify_singleton_bound()} ✓")
    print(f"Channel projection non-expansive: {code.verify_channel_nonexpansive()} ✓")
    
    # Three-channel code over Z/30Z
    crt3 = CRTDecomposition.from_moduli([2, 3, 5])
    print(f"\n3-channel CRT: Z/{crt3.product}Z ≅ " +
          " × ".join(f"Z/{m}Z" for m in crt3.moduli))
    
    for x in range(crt3.product):
        assert crt3.decode(crt3.encode(x)) == x
    print("CRT reconstruction verified ✓")
    
    # Channel-aware decoding demo
    code6 = build_repetition_code(crt, length=5)
    original = code6.codewords[3]  # symbol 3 repeated
    print(f"\nChannel-aware decoding demo:")
    print(f"  Original: {original}")
    
    # Introduce m-channel error at position 0
    received = original.copy()
    comp = crt.encode(received[0])
    comp[0] = (comp[0] + 1) % crt.moduli[0]  # flip channel 0
    received[0] = crt.decode(comp)
    print(f"  Received: {received} (1 error in 2-channel)")
    
    decoded = code6.decode_channel(received, error_free_channels=[1])
    print(f"  Decoded:  {decoded}")
    print(f"  Correct:  {decoded == original} ✓")
