#!/usr/bin/env python3
"""
Applications of Computation on Pythagorean Orbit Lattices

This module demonstrates real-world applications and connections:
1. Cryptographic hash from orbit reachability
2. Pseudorandom generation via Berggren walk
3. Error-detecting codes from Pythagorean structure
4. Symbolic dynamics analysis
"""

import numpy as np
import hashlib
from typing import List, Tuple
from algorithms import (
    BerggrenGenerator, apply_generator, compute_address_triple,
    find_address, ROOT_TRIPLE, MATRICES, tree_distance
)


# ──────────────────────────────────────────────────────────────
# Application 1: Pythagorean Orbit Hash
# ──────────────────────────────────────────────────────────────

def orbit_hash(data: bytes, output_bits: int = 256) -> str:
    """A hash function based on Berggren orbit walking.

    The input bytes determine a walk through the Berggren tree.
    The final triple, combined with the walk statistics,
    produces the hash output.

    This is a proof-of-concept demonstrating how arithmetic
    orbit dynamics could define cryptographic primitives.
    NOT for production use.

    Args:
        data: Input bytes to hash
        output_bits: Desired output length in bits

    Returns:
        Hex string of the hash
    """
    gens = [BerggrenGenerator.A, BerggrenGenerator.B, BerggrenGenerator.C]

    # Initialize state
    triple = ROOT_TRIPLE.copy()
    path_length = 0
    accumulator = np.zeros(3, dtype=np.int64)

    # Walk the tree based on input data
    for byte in data:
        for bit_pos in range(8):
            # Use 2 bits to choose generator (with bias toward A for bit=0)
            idx = (byte >> bit_pos) % 3
            triple = apply_generator(gens[idx], triple)
            accumulator = (accumulator + triple) % (2**62)
            path_length += 1

    # Finalize: combine triple coordinates and accumulator
    raw = (
        triple.tobytes() +
        accumulator.tobytes() +
        path_length.to_bytes(8, 'big')
    )

    # Use SHA-256 to compress to desired output size
    h = hashlib.sha256(raw).hexdigest()
    return h[:output_bits // 4]


# ──────────────────────────────────────────────────────────────
# Application 2: Pseudorandom Number Generator
# ──────────────────────────────────────────────────────────────

class BerggrenPRNG:
    """Pseudorandom number generator based on Berggren orbit walk.

    Uses the chaotic mixing properties of iterated matrix
    multiplication to generate pseudorandom sequences.

    The key insight: the ratio a/c of successive Pythagorean
    triples along random walks exhibits good statistical properties
    due to the non-commutativity and mixing of the generators.
    """

    def __init__(self, seed: int = 42):
        self.triple = ROOT_TRIPLE.copy()
        self.gens = [BerggrenGenerator.A, BerggrenGenerator.B, BerggrenGenerator.C]
        # Initialize walk from seed
        rng = np.random.RandomState(seed)
        for _ in range(64):  # Warm up
            idx = rng.randint(0, 3)
            self.triple = apply_generator(self.gens[idx], self.triple)
        self._state = seed

    def next_float(self) -> float:
        """Generate a pseudorandom float in [0, 1)."""
        # Use simple LCG to pick generator
        self._state = (self._state * 6364136223846793005 + 1) % (2**63)
        idx = self._state % 3
        self.triple = apply_generator(self.gens[idx], self.triple)

        # Extract randomness from ratio a/c
        a, b, c = self.triple.astype(np.float64)
        # Map to [0, 1) using the fractional part of a/c * large prime
        value = (a / c * 104729) % 1.0
        return value

    def next_int(self, low: int, high: int) -> int:
        """Generate a pseudorandom integer in [low, high)."""
        return int(self.next_float() * (high - low)) + low


# ──────────────────────────────────────────────────────────────
# Application 3: Error-Detecting Codes
# ──────────────────────────────────────────────────────────────

def pythagorean_checksum(data: List[int]) -> Tuple[int, int, int]:
    """Compute a Pythagorean triple checksum for error detection.

    The data determines a walk through the Berggren tree.
    The final triple serves as a checksum: any bit flip
    in the data produces a different triple (with high probability)
    due to the tree structure (distinct children guarantee).

    Args:
        data: List of integers (e.g., byte values)

    Returns:
        A primitive Pythagorean triple (a, b, c) as checksum
    """
    gens = [BerggrenGenerator.A, BerggrenGenerator.B, BerggrenGenerator.C]
    triple = ROOT_TRIPLE.copy()

    for value in data:
        # Use value modulo 3 to pick generator
        idx = value % 3
        triple = apply_generator(gens[idx], triple)

    return tuple(triple)


def verify_checksum(data: List[int], checksum: Tuple[int, int, int]) -> bool:
    """Verify data integrity using Pythagorean checksum."""
    computed = pythagorean_checksum(data)
    return computed == checksum


# ──────────────────────────────────────────────────────────────
# Application 4: Symbolic Dynamics Analysis
# ──────────────────────────────────────────────────────────────

def orbit_entropy_estimate(depth: int = 10, num_walks: int = 1000) -> float:
    """Estimate the topological entropy of random walks on the Berggren tree.

    Performs random walks and measures the diversity of visited triples,
    providing an empirical estimate of the mixing rate.

    Args:
        depth: Length of each random walk
        num_walks: Number of independent walks

    Returns:
        Estimated entropy (bits per step)
    """
    rng = np.random.RandomState(42)
    gens = [BerggrenGenerator.A, BerggrenGenerator.B, BerggrenGenerator.C]

    # Count distinct endpoints
    endpoints = set()
    for _ in range(num_walks):
        triple = ROOT_TRIPLE.copy()
        for _ in range(depth):
            idx = rng.randint(0, 3)
            triple = apply_generator(gens[idx], triple)
        endpoints.add(tuple(triple))

    # Entropy estimate: log2(distinct endpoints) / depth
    distinct = len(endpoints)
    if distinct <= 1:
        return 0.0
    return np.log2(distinct) / depth


def orbit_correlation(depth: int = 8) -> List[float]:
    """Measure correlation between successive hypotenuses along random walks.

    Returns autocorrelation coefficients for the hypotenuse sequence.
    """
    rng = np.random.RandomState(42)
    gens = [BerggrenGenerator.A, BerggrenGenerator.B, BerggrenGenerator.C]
    num_walks = 500

    all_ratios = []
    for _ in range(num_walks):
        triple = ROOT_TRIPLE.copy()
        ratios = []
        for _ in range(depth):
            idx = rng.randint(0, 3)
            old_c = triple[2]
            triple = apply_generator(gens[idx], triple)
            ratios.append(float(triple[2]) / float(old_c))
        all_ratios.append(ratios)

    # Compute autocorrelation
    ratios_arr = np.array(all_ratios)
    mean_ratios = ratios_arr.mean(axis=0)
    centered = ratios_arr - mean_ratios

    correlations = []
    for lag in range(min(depth, 5)):
        if lag == 0:
            correlations.append(1.0)
        else:
            num = np.mean(centered[:, :-lag] * centered[:, lag:])
            den = np.std(ratios_arr) ** 2
            correlations.append(float(num / den) if den > 0 else 0)

    return correlations


# ──────────────────────────────────────────────────────────────
# Application 5: Orbit Distance as Computational Metric
# ──────────────────────────────────────────────────────────────

def computational_distance(triple1: np.ndarray, triple2: np.ndarray) -> int:
    """Compute the minimum number of Berggren steps between two triples.

    This uses the find_address function to locate each triple in the
    tree and then computes the tree distance.

    The computational distance measures how many CA steps are needed
    to propagate information between two positions in the orbit lattice.
    """
    addr1 = find_address(triple1)
    addr2 = find_address(triple2)

    if addr1 is None or addr2 is None:
        return -1  # At least one triple not in standard tree

    return tree_distance(
        [g.value for g in addr1],
        [g.value for g in addr2]
    )


# ──────────────────────────────────────────────────────────────
# Demonstrations
# ──────────────────────────────────────────────────────────────

if __name__ == '__main__':
    print("=" * 60)
    print("APPLICATION 1: Pythagorean Orbit Hash")
    print("=" * 60)
    for msg in [b"hello", b"hello!", b"Hello", b"world"]:
        h = orbit_hash(msg)
        print(f"  hash({msg!r}) = {h}")

    print(f"\n  Avalanche test (1-bit change):")
    h1 = orbit_hash(b"\x00")
    h2 = orbit_hash(b"\x01")
    diff_bits = bin(int(h1, 16) ^ int(h2, 16)).count('1')
    print(f"    hash(0x00) = {h1}")
    print(f"    hash(0x01) = {h2}")
    print(f"    Hamming distance: {diff_bits} / {len(h1)*4} bits")

    print(f"\n{'=' * 60}")
    print("APPLICATION 2: Pseudorandom Generator")
    print("=" * 60)
    prng = BerggrenPRNG(seed=12345)
    values = [prng.next_float() for _ in range(10)]
    print(f"  First 10 values: {[f'{v:.4f}' for v in values]}")
    print(f"  Mean: {np.mean(values):.4f} (expected ~0.5)")

    # Generate more and check uniformity
    prng2 = BerggrenPRNG(seed=42)
    big_sample = [prng2.next_float() for _ in range(10000)]
    hist, _ = np.histogram(big_sample, bins=10, range=(0, 1))
    print(f"  10-bin histogram (10000 samples): {list(hist)}")
    print(f"  Expected per bin: ~1000")

    print(f"\n{'=' * 60}")
    print("APPLICATION 3: Error-Detecting Codes")
    print("=" * 60)
    data = [72, 101, 108, 108, 111]  # "Hello"
    cs = pythagorean_checksum(data)
    print(f"  Data: {data}")
    print(f"  Checksum triple: {cs}")
    print(f"  Pythagorean: {cs[0]**2 + cs[1]**2 == cs[2]**2}")
    print(f"  Verify original: {verify_checksum(data, cs)}")
    data_corrupted = data.copy()
    data_corrupted[2] = 109  # Change one byte
    print(f"  Verify corrupted: {verify_checksum(data_corrupted, cs)}")

    print(f"\n{'=' * 60}")
    print("APPLICATION 4: Symbolic Dynamics")
    print("=" * 60)
    for depth in [5, 10, 15, 20]:
        ent = orbit_entropy_estimate(depth, 2000)
        print(f"  Depth {depth:2d}: entropy ≈ {ent:.3f} bits/step")

    corr = orbit_correlation(8)
    print(f"  Autocorrelation (lags 0-4): {[f'{c:.3f}' for c in corr]}")

    print(f"\n{'=' * 60}")
    print("APPLICATION 5: Computational Distance")
    print("=" * 60)
    triples = [
        (np.array([3, 4, 5]), "(3,4,5)"),
        (np.array([5, 12, 13]), "(5,12,13)"),
        (np.array([7, 24, 25]), "(7,24,25)"),
        (np.array([21, 20, 29]), "(21,20,29)"),
    ]
    for t1, n1 in triples:
        for t2, n2 in triples:
            if n1 < n2:
                d = computational_distance(t1, t2)
                print(f"  d({n1}, {n2}) = {d}")
