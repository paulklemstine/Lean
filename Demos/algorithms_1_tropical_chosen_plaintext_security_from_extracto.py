#!/usr/bin/env python3
"""
Algorithms for Tropical CPA Security
=====================================

Implements the core algorithms from the research paper:
1. Tropical matrix multiplication (max-plus algebra)
2. Tropical orbit source generation
3. Universal hash extraction for tropical sources
4. Statistical distance computation
5. CPA advantage estimation
6. Security parameter computation pipeline
"""

import numpy as np
from dataclasses import dataclass
from typing import List, Tuple, Optional


# ─── Core Data Structures ────────────────────────────────────────

@dataclass
class ProbDist:
    """A probability distribution on a finite set {0, ..., n-1}."""
    pmf: np.ndarray

    def __post_init__(self):
        assert np.all(self.pmf >= -1e-12), "PMF must be nonneg"
        self.pmf = np.maximum(self.pmf, 0)
        total = self.pmf.sum()
        if abs(total - 1.0) > 1e-8:
            self.pmf = self.pmf / total

    @staticmethod
    def uniform(n: int) -> 'ProbDist':
        return ProbDist(np.ones(n) / n)

    @staticmethod
    def map(f: callable, p: 'ProbDist', output_size: int) -> 'ProbDist':
        """Pushforward distribution through f."""
        q = np.zeros(output_size)
        for x, px in enumerate(p.pmf):
            q[f(x)] += px
        return ProbDist(q)

    def stat_dist(self, other: 'ProbDist') -> float:
        """Statistical distance (total variation)."""
        return 0.5 * np.sum(np.abs(self.pmf - other.pmf))


@dataclass
class CpaAdversary:
    """A CPA adversary with bounded distinguisher."""
    distinguisher: np.ndarray  # K → [-1, 1]
    query_bound: int

    def __post_init__(self):
        assert np.all(np.abs(self.distinguisher) <= 1.0 + 1e-10)


@dataclass
class SecurityParams:
    """Security parameters for a tropical CPA scheme."""
    key_size: int
    stat_dist_bound: float
    cpa_advantage_bound: float
    query_bound: int
    security_bits: float


# ─── Algorithm 1: Tropical Matrix Operations ─────────────────────

def tropical_add(a: float, b: float) -> float:
    """Tropical addition: max(a, b).

    Time: O(1), Space: O(1)
    """
    return max(a, b)


def tropical_mult(a: float, b: float) -> float:
    """Tropical multiplication: a + b (classical addition).

    Time: O(1), Space: O(1)
    """
    return a + b


def tropical_matrix_mult(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Tropical (max-plus) matrix multiplication.

    C[i,j] = max_k (A[i,k] + B[k,j])

    Time: O(n²m) where A is n×p and B is p×m
    Space: O(nm)
    """
    n, p = A.shape
    _, m = B.shape
    C = np.full((n, m), -np.inf)
    for i in range(n):
        for j in range(m):
            for k in range(p):
                val = A[i, k] + B[k, j]
                if val > C[i, j]:
                    C[i, j] = val
    return C


def tropical_matrix_power(A: np.ndarray, t: int) -> np.ndarray:
    """Compute A^t in the tropical semiring via repeated squaring.

    Time: O(n³ log t)
    Space: O(n²)
    """
    n = A.shape[0]
    result = np.full((n, n), -np.inf)
    np.fill_diagonal(result, 0)  # tropical identity

    base = A.copy()
    while t > 0:
        if t % 2 == 1:
            result = tropical_matrix_mult(result, base)
        base = tropical_matrix_mult(base, base)
        t //= 2
    return result


# ─── Algorithm 2: Tropical Orbit Source ───────────────────────────

def tropical_orbit_sample(generators: List[np.ndarray],
                          steps: int) -> np.ndarray:
    """Sample from a tropical orbit source.

    Randomly composes generators in the tropical semiring.

    Time: O(steps × n³)
    Space: O(n²)

    Args:
        generators: List of n×n tropical matrices
        steps: Number of random compositions

    Returns:
        Final tropical matrix state
    """
    n = generators[0].shape[0]
    state = np.full((n, n), -np.inf)
    np.fill_diagonal(state, 0)

    for _ in range(steps):
        idx = np.random.randint(len(generators))
        state = tropical_matrix_mult(state, generators[idx])

    return state


# ─── Algorithm 3: Universal Hash Extraction ──────────────────────

def universal_hash_extract(matrix: np.ndarray, seed: np.ndarray,
                            key_size: int) -> int:
    """Extract a key using a universal hash family.

    Uses a seeded linear hash: h_s(x) = (s · x) mod key_size
    where x is the vector of finite matrix entries.

    Time: O(n²)
    Space: O(n²)

    Args:
        matrix: Input tropical matrix
        seed: Random seed vector (same length as finite entries)
        key_size: Size of key space

    Returns:
        Extracted key in {0, ..., key_size - 1}
    """
    flat = matrix.flatten()
    finite_mask = np.isfinite(flat)
    finite_entries = flat[finite_mask]

    if len(finite_entries) == 0:
        return 0

    # Truncate or pad seed
    s = seed[:len(finite_entries)] if len(seed) >= len(finite_entries) else \
        np.pad(seed, (0, len(finite_entries) - len(seed)))

    # Linear hash
    hash_val = int(np.round(np.abs(np.dot(s, finite_entries)))) % key_size
    return hash_val


# ─── Algorithm 4: CPA Advantage Computation ──────────────────────

def compute_cpa_advantage(real_dist: ProbDist, ideal_dist: ProbDist,
                          adversary: CpaAdversary) -> float:
    """Compute the CPA advantage of an adversary.

    Adv = |E_{k~D}[A(k)] - E_{k~U}[A(k)]|

    Time: O(|K|)
    Space: O(1)
    """
    real_exp = np.sum(real_dist.pmf * adversary.distinguisher)
    ideal_exp = np.sum(ideal_dist.pmf * adversary.distinguisher)
    return abs(real_exp - ideal_exp)


def compute_worst_case_advantage(real_dist: ProbDist,
                                  ideal_dist: ProbDist) -> float:
    """Compute the worst-case CPA advantage over all bounded adversaries.

    This equals the L1 distance = 2 × statDist.

    Time: O(|K|)
    Space: O(|K|)
    """
    return np.sum(np.abs(real_dist.pmf - ideal_dist.pmf))


# ─── Algorithm 5: Security Parameter Pipeline ────────────────────

def compute_security_params(generators: List[np.ndarray],
                             steps: int,
                             key_size: int,
                             query_bound: int,
                             num_samples: int = 10000) -> SecurityParams:
    """Full security parameter computation pipeline.

    1. Sample tropical orbit source
    2. Extract keys
    3. Estimate statistical distance
    4. Compute CPA bound

    Time: O(num_samples × steps × n³ + num_samples × n²)
    Space: O(num_samples + key_size)

    Args:
        generators: Tropical matrix generators
        steps: Orbit length
        key_size: Key space size
        query_bound: Maximum adversary queries
        num_samples: Monte Carlo samples

    Returns:
        SecurityParams with computed bounds
    """
    dim = generators[0].shape[0]

    # Sample key distribution
    seed = np.random.randn(dim * dim)
    key_counts = np.zeros(key_size)

    for _ in range(num_samples):
        matrix = tropical_orbit_sample(generators, steps)
        key = universal_hash_extract(matrix, seed, key_size)
        key_counts[key] += 1

    real_dist = ProbDist(key_counts / key_counts.sum())
    ideal_dist = ProbDist.uniform(key_size)

    sd = real_dist.stat_dist(ideal_dist)
    cpa_bound = max(2, query_bound) * sd

    security_bits = -np.log2(cpa_bound) if cpa_bound > 0 else float('inf')

    return SecurityParams(
        key_size=key_size,
        stat_dist_bound=sd,
        cpa_advantage_bound=cpa_bound,
        query_bound=query_bound,
        security_bits=security_bits
    )


# ─── Algorithm 6: Hybrid Argument Simulation ─────────────────────

def hybrid_argument_simulation(real_dist: ProbDist, ideal_dist: ProbDist,
                                num_hybrids: int) -> List[float]:
    """Simulate the hybrid argument for multi-query CPA.

    Creates num_hybrids intermediate distributions and measures
    the per-step statistical distance.

    Time: O(num_hybrids × |K|)
    Space: O(num_hybrids × |K|)

    Returns:
        List of per-hybrid statistical distances
    """
    distances = []
    for i in range(num_hybrids + 1):
        t = i / num_hybrids
        hybrid = ProbDist((1 - t) * real_dist.pmf + t * ideal_dist.pmf)
        if i > 0:
            prev = ProbDist((1 - (i-1)/num_hybrids) * real_dist.pmf +
                           ((i-1)/num_hybrids) * ideal_dist.pmf)
            distances.append(hybrid.stat_dist(prev))

    return distances


# ─── Example Usage ────────────────────────────────────────────────

if __name__ == "__main__":
    np.random.seed(42)

    print("Tropical CPA Security — Algorithm Demonstrations")
    print("=" * 55)

    # Setup
    dim = 3
    generators = [np.random.randn(dim, dim) * 2 for _ in range(3)]

    # Algorithm 1: Tropical matrix operations
    print("\n[Algorithm 1] Tropical Matrix Multiplication")
    A = generators[0]
    B = generators[1]
    C = tropical_matrix_mult(A, B)
    print(f"  A[0,0]={A[0,0]:.3f}, B[0,0]={B[0,0]:.3f}")
    print(f"  (A⊗B)[0,0] = max_k(A[0,k]+B[k,0]) = {C[0,0]:.3f}")

    # Algorithm 5: Full pipeline
    print("\n[Algorithm 5] Security Parameter Pipeline")
    for steps in [5, 10, 20, 50]:
        params = compute_security_params(generators, steps, 16, 10, 3000)
        print(f"  steps={steps:3d}: SD={params.stat_dist_bound:.4f}, "
              f"CPA≤{params.cpa_advantage_bound:.4f}, "
              f"security≈{params.security_bits:.1f} bits")

    # Algorithm 6: Hybrid argument
    print("\n[Algorithm 6] Hybrid Argument Simulation")
    p = ProbDist(np.random.dirichlet(np.ones(16) * 3))
    u = ProbDist.uniform(16)
    distances = hybrid_argument_simulation(p, u, 10)
    total = sum(distances)
    print(f"  Total SD: {p.stat_dist(u):.6f}")
    print(f"  Sum of hybrid steps: {total:.6f}")
    print(f"  Per-step average: {total/len(distances):.6f}")
