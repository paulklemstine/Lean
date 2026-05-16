#!/usr/bin/env python3
"""
algorithms.py — Algorithms for q-ary source coding theory.

Implements:
1. QaryEncoder: Shannon-style q-ary code construction
2. QaryHuffman: Optimal q-ary prefix code via generalized Huffman
3. KraftValidator: Validates prefix code feasibility
4. EntropyAnalyzer: Computes and compares entropy measures across bases
"""

import numpy as np
from math import log, ceil, floor
from typing import List, Tuple, Dict, Optional
from collections import defaultdict
import heapq


class QaryEncoder:
    """
    Shannon-style q-ary source encoder.

    Given a probability distribution p over alphabet symbols and a code
    alphabet size q >= 2, constructs the Shannon code with ceiling lengths
    ℓ(a) = ⌈log_q(1/p(a))⌉.

    Attributes:
        q: Code alphabet size (≥ 2)
        probs: Probability distribution
        lengths: Shannon ceiling code lengths
        entropy: q-ary entropy H_q(p)

    Time complexity: O(n) for n source symbols
    Space complexity: O(n)
    """

    def __init__(self, probs: List[float], q: int = 2):
        """
        Initialize the encoder.

        Args:
            probs: Probability distribution (must sum to 1, all positive)
            q: Code alphabet size (default 2 for binary)

        Raises:
            ValueError: If q < 2 or probs invalid
        """
        if q < 2:
            raise ValueError(f"Alphabet size q must be >= 2, got {q}")
        if abs(sum(probs) - 1.0) > 1e-10:
            raise ValueError(f"Probabilities must sum to 1, got {sum(probs)}")
        if any(p <= 0 for p in probs):
            raise ValueError("All probabilities must be positive")

        self.q = q
        self.probs = list(probs)
        self.n = len(probs)
        self.lengths = self._compute_lengths()
        self.entropy = self._compute_entropy()

    def _compute_lengths(self) -> List[int]:
        """Compute Shannon ceiling lengths ℓ(a) = ⌈log_q(1/p(a))⌉."""
        return [ceil(log(1/p, self.q)) for p in self.probs]

    def _compute_entropy(self) -> float:
        """Compute q-ary entropy H_q(p) = -∑ p(a) log_q(p(a))."""
        return -sum(p * log(p, self.q) for p in self.probs)

    def kraft_sum(self) -> float:
        """Compute Kraft sum ∑ q^{-ℓ(a)}. Must be ≤ 1 for prefix codes."""
        return sum(self.q ** (-l) for l in self.lengths)

    def expected_length(self) -> float:
        """Compute expected code length E[ℓ] = ∑ p(a) ℓ(a)."""
        return sum(p * l for p, l in zip(self.probs, self.lengths))

    def coding_efficiency(self) -> float:
        """Compute coding efficiency η = H_q(p) / E[ℓ]."""
        E = self.expected_length()
        return self.entropy / E if E > 0 else 0.0

    def redundancy(self) -> float:
        """Compute redundancy R = E[ℓ] - H_q(p). Always in [0, 1)."""
        return self.expected_length() - self.entropy

    def relaxed_optimal_lengths(self) -> List[float]:
        """Compute optimal real-valued lengths L*(a) = log_q(1/p(a))."""
        return [log(1/p, self.q) for p in self.probs]

    def verify_bounds(self) -> Dict[str, bool]:
        """Verify all Shannon coding theorem bounds."""
        H = self.entropy
        E = self.expected_length()
        K = self.kraft_sum()
        return {
            "kraft_inequality": K <= 1.0 + 1e-10,
            "lower_bound": H <= E + 1e-10,
            "upper_bound": E < H + 1.0 + 1e-10,
            "all_satisfied": K <= 1.0 + 1e-10 and H <= E + 1e-10 and E < H + 1.0 + 1e-10
        }

    def summary(self) -> str:
        """Return a formatted summary of the code."""
        lines = [f"q-ary Shannon Code (q = {self.q})",
                 f"  Source symbols: {self.n}",
                 f"  Entropy H_{self.q}(p) = {self.entropy:.6f}",
                 f"  Shannon lengths: {self.lengths}",
                 f"  Expected length: {self.expected_length():.6f}",
                 f"  Kraft sum: {self.kraft_sum():.6f}",
                 f"  Efficiency: {self.coding_efficiency()*100:.2f}%",
                 f"  Redundancy: {self.redundancy():.6f}"]
        return "\n".join(lines)


class QaryHuffman:
    """
    Generalized q-ary Huffman code construction.

    Builds an optimal prefix-free code over a q-ary alphabet.
    For q > 2, may need to add dummy zero-probability symbols
    so that (n-1) mod (q-1) == 0.

    Time complexity: O(n log n) for n source symbols
    Space complexity: O(n)
    """

    def __init__(self, probs: List[float], q: int = 2):
        if q < 2:
            raise ValueError(f"q must be >= 2, got {q}")
        self.q = q
        self.probs = list(probs)
        self.n = len(probs)
        self.lengths = self._build_huffman()

    def _build_huffman(self) -> List[int]:
        """Build Huffman tree and extract code lengths."""
        n = self.n
        q = self.q

        # Pad with zero-probability symbols if needed
        padded = list(self.probs)
        while (len(padded) - 1) % (q - 1) != 0:
            padded.append(0.0)

        # Build tree using priority queue
        # Each entry: (probability, id, depth_info)
        counter = 0
        heap = []
        depths = {}
        for i, p in enumerate(padded):
            heapq.heappush(heap, (p, counter, [i]))
            depths[i] = 0
            counter += 1

        while len(heap) > 1:
            # Merge q smallest
            children = []
            total_prob = 0.0
            all_leaves = []
            for _ in range(min(q, len(heap))):
                prob, _, leaves = heapq.heappop(heap)
                total_prob += prob
                all_leaves.extend(leaves)

            # Increase depth of all leaves by 1
            for leaf in all_leaves:
                depths[leaf] += 1

            heapq.heappush(heap, (total_prob, counter, all_leaves))
            counter += 1

        # Extract lengths for original symbols only
        return [depths[i] for i in range(n)]

    def expected_length(self) -> float:
        return sum(p * l for p, l in zip(self.probs, self.lengths))

    def kraft_sum(self) -> float:
        return sum(self.q ** (-l) for l in self.lengths)


class KraftValidator:
    """
    Validates whether a set of code lengths can form a q-ary prefix code.

    The Kraft inequality states that lengths ℓ₁, ..., ℓₙ can be realized
    as a q-ary prefix code if and only if ∑ q^{-ℓᵢ} ≤ 1.

    Time complexity: O(n)
    """

    @staticmethod
    def validate(lengths: List[int], q: int) -> Tuple[bool, float]:
        """
        Check if lengths satisfy the q-ary Kraft inequality.

        Returns:
            (is_valid, kraft_sum)
        """
        K = sum(q ** (-l) for l in lengths)
        return K <= 1.0 + 1e-10, K

    @staticmethod
    def find_feasible_lengths(probs: List[float], q: int) -> List[int]:
        """Find the shortest feasible lengths satisfying Kraft."""
        return [ceil(log(1/p, q)) for p in probs if p > 0]


class EntropyAnalyzer:
    """
    Analyze and compare entropy measures across different bases.

    Provides tools for computing q-ary entropy, comparing coding
    efficiency across bases, and finding optimal base for a given source.

    Time complexity: O(n × |bases|)
    """

    def __init__(self, probs: List[float]):
        self.probs = list(probs)
        self.n = len(probs)

    def entropy(self, q: int) -> float:
        """Compute H_q(p)."""
        return -sum(p * log(p, q) for p in self.probs if p > 0)

    def compare_bases(self, bases: List[int] = None) -> Dict[int, Dict]:
        """Compare coding performance across multiple bases."""
        if bases is None:
            bases = [2, 3, 4, 8]

        results = {}
        for q in bases:
            enc = QaryEncoder(self.probs, q)
            results[q] = {
                "entropy": enc.entropy,
                "expected_length": enc.expected_length(),
                "efficiency": enc.coding_efficiency(),
                "redundancy": enc.redundancy(),
                "kraft_sum": enc.kraft_sum(),
            }
        return results

    def optimal_base(self, max_q: int = 16) -> int:
        """Find the base q that minimizes coding redundancy."""
        best_q, best_redundancy = 2, float('inf')
        for q in range(2, max_q + 1):
            enc = QaryEncoder(self.probs, q)
            r = enc.redundancy()
            if r < best_redundancy:
                best_redundancy = r
                best_q = q
        return best_q

    def base_conversion_factor(self, q1: int, q2: int) -> float:
        """Compute H_{q1}(p) / H_{q2}(p) = log(q2) / log(q1)."""
        return log(q2) / log(q1)

    def print_comparison_table(self, bases: List[int] = None):
        """Print a formatted comparison table."""
        results = self.compare_bases(bases)
        print(f"{'Base q':>8} {'H_q(p)':>10} {'E[ℓ]':>10} {'η':>8} {'R':>8} {'Kraft':>8}")
        print("-" * 58)
        for q, r in sorted(results.items()):
            print(f"{q:>8d} {r['entropy']:>10.4f} {r['expected_length']:>10.4f} "
                  f"{r['efficiency']*100:>7.1f}% {r['redundancy']:>8.4f} {r['kraft_sum']:>8.4f}")


# ============================================================
# Example usage
# ============================================================
if __name__ == "__main__":
    print("=" * 60)
    print("Q-ARY SOURCE CODING ALGORITHMS")
    print("=" * 60)

    # Example 1: Shannon encoder
    p = [0.5, 0.25, 0.125, 0.125]
    print("\n--- Shannon Encoder ---")
    for q in [2, 3, 4]:
        enc = QaryEncoder(p, q)
        print(f"\n{enc.summary()}")
        bounds = enc.verify_bounds()
        print(f"  Bounds check: {'✓ All passed' if bounds['all_satisfied'] else '✗ FAILED'}")

    # Example 2: Huffman comparison
    print("\n\n--- Huffman vs Shannon ---")
    for q in [2, 3, 4]:
        shannon = QaryEncoder(p, q)
        huffman = QaryHuffman(p, q)
        print(f"\n  q = {q}:")
        print(f"    Shannon lengths: {shannon.lengths}, E[ℓ] = {shannon.expected_length():.4f}")
        print(f"    Huffman lengths: {huffman.lengths}, E[ℓ] = {huffman.expected_length():.4f}")
        print(f"    Huffman improvement: {shannon.expected_length() - huffman.expected_length():.4f}")

    # Example 3: Entropy analyzer
    print("\n\n--- Entropy Analysis ---")
    analyzer = EntropyAnalyzer(p)
    analyzer.print_comparison_table([2, 3, 4, 8, 16])
    print(f"\n  Optimal base (min redundancy): q = {analyzer.optimal_base()}")

    # Example 4: DNA storage
    print("\n\n--- DNA Storage (q=4) ---")
    p_dna = [0.3, 0.25, 0.25, 0.2]  # Non-uniform nucleotide distribution
    enc_dna = QaryEncoder(p_dna, 4)
    enc_bin = QaryEncoder(p_dna, 2)
    print(f"  Binary encoding: E[ℓ] = {enc_bin.expected_length():.4f} bits/symbol")
    print(f"  DNA encoding:    E[ℓ] = {enc_dna.expected_length():.4f} quats/symbol")
    print(f"  Storage ratio: {enc_bin.expected_length() / enc_dna.expected_length():.2f}x")

    print("\n\nAll algorithms completed successfully!")
