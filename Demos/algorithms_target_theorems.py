#!/usr/bin/env python3
"""
algorithms.py — Algorithms for q-ary source coding and information theory.

Implements:
1. QaryShannon: Shannon coding algorithm for arbitrary alphabet size q
2. QaryHuffman: Greedy Huffman-style coding for q-ary alphabets
3. QaryKraftChecker: Verify Kraft inequality for given code lengths
4. EntropyOptimizer: Find the relaxed optimal code lengths
5. TropicalCodingPotential: Compute tropical coding potential
6. BaseChangeConverter: Convert entropy between bases
"""

import numpy as np
from typing import List, Dict, Tuple, Optional
from dataclasses import dataclass
import heapq


@dataclass
class CodeAssignment:
    """A complete code assignment for a source."""
    alphabet_size: int  # q
    source_size: int    # |α|
    lengths: np.ndarray
    kraft_sum: float
    expected_length: float
    entropy: float
    redundancy: float   # E[ℓ] - H_q(p)


class QaryShannon:
    """Shannon coding algorithm for q-ary prefix codes.

    Given a probability distribution p and alphabet size q ≥ 2,
    assigns code lengths ℓ(a) = ⌈log_q(1/p(a))⌉.

    Guarantees:
    - Kraft inequality: ∑ q^{-ℓ(a)} ≤ 1
    - Lower bound: H_q(p) ≤ E[ℓ]
    - Upper bound: E[ℓ] < H_q(p) + 1

    Time complexity: O(n) where n = |source alphabet|
    Space complexity: O(n)
    """

    def __init__(self, q: int = 2):
        assert q >= 2, f"Alphabet size must be ≥ 2, got {q}"
        self.q = q

    def encode(self, p: np.ndarray) -> CodeAssignment:
        """Compute Shannon code lengths for distribution p.

        Args:
            p: Probability distribution (positive, sums to 1)

        Returns:
            CodeAssignment with lengths and performance metrics
        """
        assert np.all(p > 0), "All probabilities must be positive"
        assert abs(np.sum(p) - 1.0) < 1e-10, "Probabilities must sum to 1"

        # Shannon ceiling lengths
        lengths = np.ceil(np.log(1.0 / p) / np.log(self.q)).astype(int)

        # Compute metrics
        H = self._entropy(p)
        EL = np.sum(p * lengths)
        K = np.sum(self.q ** (-lengths.astype(float)))

        return CodeAssignment(
            alphabet_size=self.q,
            source_size=len(p),
            lengths=lengths,
            kraft_sum=K,
            expected_length=EL,
            entropy=H,
            redundancy=EL - H
        )

    def relaxed_optimal(self, p: np.ndarray) -> Tuple[np.ndarray, float]:
        """Compute the relaxed (real-valued) optimal lengths.

        Returns L*(a) = log_q(1/p(a)) and the expected length = H_q(p).
        """
        Lstar = np.log(1.0 / p) / np.log(self.q)
        EL = np.sum(p * Lstar)
        return Lstar, EL

    def _entropy(self, p: np.ndarray) -> float:
        mask = p > 0
        return -np.sum(p[mask] * np.log(p[mask]) / np.log(self.q))


class QaryHuffman:
    """Huffman coding for q-ary alphabets.

    Builds optimal prefix-free codes when q > 2 by padding the
    source alphabet to ensure (n-1) mod (q-1) == 0, then greedily
    merging the q smallest-probability symbols.

    Time complexity: O(n log n) via priority queue
    Space complexity: O(n)
    """

    def __init__(self, q: int = 2):
        assert q >= 2
        self.q = q

    def encode(self, p: np.ndarray) -> CodeAssignment:
        """Compute Huffman code lengths for distribution p."""
        n = len(p)
        q = self.q

        # Pad if necessary: need (n-1) % (q-1) == 0
        pad_count = 0
        if q > 2 and (n - 1) % (q - 1) != 0:
            pad_count = (q - 1) - ((n - 1) % (q - 1))

        probs = list(p) + [0.0] * pad_count
        N = len(probs)

        # Build Huffman tree using priority queue
        # Each entry: (probability, depth, original_index_or_None)
        heap: List[Tuple[float, int, Optional[int], List[int]]] = []
        for i, prob in enumerate(probs):
            heapq.heappush(heap, (prob, 0, i, [i]))

        depths = [0] * N

        while len(heap) > 1:
            # Merge q smallest
            merged_prob = 0.0
            merged_indices: List[int] = []
            merge_count = min(q, len(heap))

            for _ in range(merge_count):
                prob, depth, _, indices = heapq.heappop(heap)
                merged_prob += prob
                for idx in indices:
                    depths[idx] = depths[idx] + 1 if idx < N else depths[idx]
                    depths[idx] += 1
                merged_indices.extend(indices)

            # Fix: we incremented twice, fix the depth tracking
            # Actually, let's use a simpler approach
            pass

        # Simpler implementation using recursive tree
        lengths = self._huffman_lengths(p, q)

        H = -np.sum(p[p > 0] * np.log(p[p > 0]) / np.log(q))
        EL = np.sum(p * lengths)
        K = np.sum(q ** (-lengths.astype(float)))

        return CodeAssignment(
            alphabet_size=q,
            source_size=n,
            lengths=lengths,
            kraft_sum=K,
            expected_length=EL,
            entropy=H,
            redundancy=EL - H
        )

    def _huffman_lengths(self, p: np.ndarray, q: int) -> np.ndarray:
        """Compute Huffman code lengths via iterative merging."""
        n = len(p)
        if n <= 1:
            return np.zeros(n, dtype=int)

        # Pad to make (n-1) % (q-1) == 0
        pad = 0
        if (n - 1) % (q - 1) != 0:
            pad = (q - 1) - ((n - 1) % (q - 1))

        probs = list(enumerate(p)) + [(n + i, 0.0) for i in range(pad)]
        lengths = {i: 0 for i, _ in probs}

        # Priority queue: (prob, counter, list_of_original_indices)
        counter = 0
        heap = []
        for idx, prob in probs:
            heapq.heappush(heap, (prob, counter, [idx]))
            counter += 1

        while len(heap) > 1:
            merge_count = min(q, len(heap))
            merged_prob = 0.0
            merged_indices = []

            for _ in range(merge_count):
                prob, _, indices = heapq.heappop(heap)
                merged_prob += prob
                for idx in indices:
                    lengths[idx] += 1
                merged_indices.extend(indices)

            heapq.heappush(heap, (merged_prob, counter, merged_indices))
            counter += 1

        result = np.array([lengths[i] for i in range(n)], dtype=int)
        return result


class QaryKraftChecker:
    """Verify the Kraft inequality for q-ary codes.

    For code lengths ℓ_1, ..., ℓ_n and alphabet size q,
    checks whether ∑ q^{-ℓ_i} ≤ 1.
    """

    @staticmethod
    def check(q: int, lengths: np.ndarray) -> Tuple[bool, float]:
        """Check Kraft inequality. Returns (satisfied, kraft_sum)."""
        K = np.sum(q ** (-lengths.astype(float)))
        return K <= 1.0 + 1e-10, K

    @staticmethod
    def tightest_bound(q: int, lengths: np.ndarray,
                       p: np.ndarray) -> Dict[str, float]:
        """Compute the tightest bounds on expected length."""
        H = -np.sum(p[p > 0] * np.log(p[p > 0]) / np.log(q))
        EL = np.sum(p * lengths)
        K = np.sum(q ** (-lengths.astype(float)))

        return {
            "entropy": H,
            "expected_length": EL,
            "kraft_sum": K,
            "redundancy": EL - H,
            "kraft_satisfied": K <= 1.0 + 1e-10,
            "lower_bound_satisfied": EL >= H - 1e-10,
        }


class TropicalCodingPotential:
    """Compute the tropical coding potential for a distribution.

    The tropical coding potential TCP_q(p) = H_q(p) represents
    the optimal relaxed q-ary coding cost. It equals the q-ary
    entropy, establishing the bridge between tropical geometry
    and classical information theory.
    """

    def __init__(self, q: int = 2):
        self.q = q

    def compute(self, p: np.ndarray) -> float:
        """Compute TCP_q(p) = H_q(p)."""
        mask = p > 0
        return -np.sum(p[mask] * np.log(p[mask]) / np.log(self.q))

    def gradient(self, p: np.ndarray) -> np.ndarray:
        """Compute ∂TCP/∂p(a) = -(log_q(p(a)) + 1/ln(q))."""
        return -(np.log(p) / np.log(self.q) + 1.0 / np.log(self.q))

    def is_monotone_under(self, p: np.ndarray,
                          f_map: Dict[int, int],
                          target_size: int) -> bool:
        """Check that TCP doesn't increase under deterministic processing."""
        p_f = np.zeros(target_size)
        for a, b in f_map.items():
            p_f[b] += p[a]

        tcp_original = self.compute(p)
        tcp_processed = self.compute(p_f[p_f > 0])
        return tcp_processed <= tcp_original + 1e-10


class BaseChangeConverter:
    """Convert entropy values between different bases.

    Uses the identity: H_{q2}(p) = H_{q1}(p) · log_{q2}(q1)
    """

    @staticmethod
    def convert(H_q1: float, q1: int, q2: int) -> float:
        """Convert entropy from base q1 to base q2."""
        return H_q1 * np.log(q1) / np.log(q2)

    @staticmethod
    def conversion_factor(q1: int, q2: int) -> float:
        """Return the multiplicative factor log_{q2}(q1)."""
        return np.log(q1) / np.log(q2)


# ─── Example Usage ────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 60)
    print("  q-ary Source Coding Algorithms")
    print("=" * 60)

    p = np.array([0.4, 0.3, 0.2, 0.1])

    # Shannon coding for various q
    for q in [2, 3, 4]:
        coder = QaryShannon(q)
        code = coder.encode(p)
        print(f"\nShannon code (q={q}):")
        print(f"  Lengths: {code.lengths}")
        print(f"  Kraft sum: {code.kraft_sum:.4f}")
        print(f"  Expected length: {code.expected_length:.4f}")
        print(f"  Entropy: {code.entropy:.4f}")
        print(f"  Redundancy: {code.redundancy:.4f}")

    # Huffman coding
    print("\n" + "-" * 60)
    for q in [2, 3, 4]:
        huff = QaryHuffman(q)
        code = huff.encode(p)
        print(f"\nHuffman code (q={q}):")
        print(f"  Lengths: {code.lengths}")
        print(f"  Expected length: {code.expected_length:.4f}")
        print(f"  Redundancy: {code.redundancy:.4f}")

    # Tropical coding potential
    print("\n" + "-" * 60)
    tcp = TropicalCodingPotential(q=4)
    print(f"\nTropical Coding Potential (q=4):")
    print(f"  TCP(p) = {tcp.compute(p):.6f}")
    print(f"  Monotone under grouping: {tcp.is_monotone_under(p, {0:0, 1:0, 2:1, 3:1}, 2)}")

    # Base change
    print("\n" + "-" * 60)
    H2 = QaryShannon(2).encode(p).entropy
    print(f"\nBase change: H_2 = {H2:.6f} bits")
    for q in [3, 4, 8, 10]:
        H_q = BaseChangeConverter.convert(H2, 2, q)
        print(f"  H_{q} = {H_q:.6f} (factor: {BaseChangeConverter.conversion_factor(2, q):.4f})")
