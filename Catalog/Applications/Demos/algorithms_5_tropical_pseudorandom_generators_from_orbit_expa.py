#!/usr/bin/env python3
"""
algorithms.py — Algorithms for Tropical Orbit PRG Theory

Implements the core algorithms from the research:
1. Tropical matrix powering (min-plus semiring)
2. Orbit hash sequence generation
3. Statistical distance computation
4. Prefix fiber analysis
5. Conditional extraction quality estimation
6. Prime-power thinning
7. Hybrid argument bound computation
"""

import numpy as np
from collections import Counter
from typing import List, Tuple, Dict, Callable, Optional
from dataclasses import dataclass

# ─────────────────────────────────────────────────────────────────────
# §1. Tropical Semiring Operations
# ─────────────────────────────────────────────────────────────────────

INF = float('inf')

def trop_add(a: float, b: float) -> float:
    """Tropical addition: min(a, b).
    
    In the min-plus tropical semiring, addition is defined as the
    minimum operation. The identity element is +∞.
    
    Time: O(1)
    """
    return min(a, b)

def trop_mul(a: float, b: float) -> float:
    """Tropical multiplication: a + b (standard addition).
    
    In the min-plus tropical semiring, multiplication is defined as
    standard addition. The identity element is 0. The absorbing
    element is +∞.
    
    Time: O(1)
    """
    if a == INF or b == INF:
        return INF
    return a + b

def trop_matmul(A: List[List[float]], B: List[List[float]]) -> List[List[float]]:
    """Tropical matrix multiplication.
    
    C[i,j] = min_k (A[i,k] + B[k,j])
    
    This is the standard matrix product in the min-plus semiring,
    used extensively in shortest-path algorithms (Floyd-Warshall),
    scheduling theory, and discrete event systems.
    
    Time: O(n³) where n is the matrix dimension.
    Space: O(n²)
    
    >>> A = [[0, 1], [2, 0]]
    >>> B = [[1, 0], [0, 1]]
    >>> trop_matmul(A, B)
    [[1, 0], [2, 1]]  # min(0+1,1+0)=1, min(0+0,1+1)=0, etc.
    """
    n = len(A)
    C = [[INF]*n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            for k in range(n):
                C[i][j] = trop_add(C[i][j], trop_mul(A[i][k], B[k][j]))
    return C

def trop_matpow(A: List[List[float]], p: int) -> List[List[float]]:
    """Compute A^p in the tropical semiring via repeated squaring.
    
    Uses binary exponentiation for efficiency. The tropical identity
    matrix has 0 on the diagonal and +∞ elsewhere.
    
    Time: O(n³ log p)
    Space: O(n²)
    
    Args:
        A: n×n tropical matrix
        p: non-negative integer exponent
    
    Returns:
        A^p in the min-plus semiring
    """
    n = len(A)
    # Tropical identity matrix
    result = [[INF]*n for _ in range(n)]
    for i in range(n):
        result[i][i] = 0
    base = [row[:] for row in A]
    while p > 0:
        if p % 2 == 1:
            result = trop_matmul(result, base)
        base = trop_matmul(base, base)
        p //= 2
    return result

# ─────────────────────────────────────────────────────────────────────
# §2. Hash / Extractor Functions
# ─────────────────────────────────────────────────────────────────────

def hash_sum_mod(M: List[List[float]], modulus: int = 8) -> int:
    """Simple additive hash: sum of finite entries mod modulus.
    
    This is a basic extractor mapping tropical matrices to a finite
    alphabet. For theoretical guarantees, one would use a
    two-universal hash family.
    
    Time: O(n²)
    """
    total = 0
    for row in M:
        for x in row:
            if x != INF:
                total += int(x)
    return total % modulus

def hash_trace_mod(M: List[List[float]], modulus: int = 8) -> int:
    """Trace hash: tropical trace (min of diagonal) mod modulus.
    
    Time: O(n)
    """
    n = len(M)
    trace_val = min(M[i][i] for i in range(n) if M[i][i] != INF)
    if trace_val == INF:
        return 0
    return int(trace_val) % modulus

def hash_weighted_mod(M: List[List[float]], modulus: int = 8, 
                       weights: Optional[List[int]] = None) -> int:
    """Weighted hash with random coefficients.
    
    h(M) = (∑ w_{ij} · M[i,j]) mod modulus
    
    Closer to a two-universal hash when weights are random.
    
    Time: O(n²)
    """
    n = len(M)
    if weights is None:
        # Default weights: position-dependent
        weights = list(range(1, n*n + 1))
    total = 0
    idx = 0
    for row in M:
        for x in row:
            if x != INF:
                total += weights[idx] * int(x)
            idx += 1
    return total % modulus

# ─────────────────────────────────────────────────────────────────────
# §3. Orbit Hash Computation
# ─────────────────────────────────────────────────────────────────────

@dataclass
class OrbitHashResult:
    """Result of orbit hash computation."""
    sequence: Tuple[int, ...]
    powers: List[Tuple[Tuple[float, ...], ...]]
    distinct_powers: int

def compute_orbit_hash(
    seed: List[List[float]], 
    T: int,
    hash_fn: Callable = hash_sum_mod,
    modulus: int = 8
) -> OrbitHashResult:
    """Compute the full orbit hash sequence for a single seed.
    
    Algorithm:
        1. Compute G^0, G^1, ..., G^T by repeated tropical multiplication
        2. Apply hash function to each power
        3. Track distinct powers for expansion analysis
    
    Time: O(T · n³) for matrix powering + O(T · n²) for hashing
    Space: O(T · n²) for storing all powers
    
    Args:
        seed: n×n tropical matrix (the "seed")
        T: orbit length (produces T+1 outputs)
        hash_fn: extractor function M → {0,...,modulus-1}
        modulus: output alphabet size
    
    Returns:
        OrbitHashResult with sequence, powers, and expansion count
    """
    powers = []
    hashes = []
    power_set = set()
    
    for i in range(T + 1):
        power = trop_matpow(seed, i)
        power_tuple = tuple(tuple(row) for row in power)
        powers.append(power_tuple)
        power_set.add(power_tuple)
        hashes.append(hash_fn(power, modulus))
    
    return OrbitHashResult(
        sequence=tuple(hashes),
        powers=powers,
        distinct_powers=len(power_set)
    )

def compute_prime_power_orbit_hash(
    seed: List[List[float]],
    T: int,
    p: int = 2,
    hash_fn: Callable = hash_sum_mod,
    modulus: int = 8
) -> OrbitHashResult:
    """Compute prime-power thinned orbit hash.
    
    Produces [h(G^(p^0)), h(G^(p^1)), ..., h(G^(p^T))].
    
    By the prime-power amplification theorem, geometric error decay
    replaces the linear (T+1)ε bound with ε₀/(1-r).
    
    Time: O(T · n³ · log(p^T)) = O(T² · n³ · log p)
    """
    powers = []
    hashes = []
    power_set = set()
    
    for j in range(T + 1):
        exp = p ** j
        power = trop_matpow(seed, exp)
        power_tuple = tuple(tuple(row) for row in power)
        powers.append(power_tuple)
        power_set.add(power_tuple)
        hashes.append(hash_fn(power, modulus))
    
    return OrbitHashResult(
        sequence=tuple(hashes),
        powers=powers,
        distinct_powers=len(power_set)
    )

# ─────────────────────────────────────────────────────────────────────
# §4. Statistical Distance Computation
# ─────────────────────────────────────────────────────────────────────

def compute_statistical_distance(
    samples: List[Tuple[int, ...]],
    alphabet_size: int,
    length: int
) -> float:
    """Compute statistical distance of empirical distribution from uniform.
    
    SD(P, U) = (1/2) ∑_x |P(x) - 1/|Ω||
    
    where Ω = {0,...,alphabet_size-1}^length.
    
    Time: O(N + |Ω|) where N = len(samples)
    
    Args:
        samples: list of output sequences (each a tuple of ints)
        alphabet_size: size of output alphabet per coordinate
        length: length of each sequence
    
    Returns:
        Statistical distance from uniform ∈ [0, 1]
    """
    counts = Counter(samples)
    total = len(samples)
    total_outcomes = alphabet_size ** length
    uniform_prob = 1.0 / total_outcomes
    
    total_var = 0.0
    for seq, count in counts.items():
        total_var += abs(count / total - uniform_prob)
    missing = total_outcomes - len(counts)
    total_var += missing * uniform_prob
    
    return total_var / 2.0

# ─────────────────────────────────────────────────────────────────────
# §5. Prefix Fiber Analysis
# ─────────────────────────────────────────────────────────────────────

@dataclass
class FiberAnalysis:
    """Analysis of prefix fiber structure at a given step."""
    step: int
    num_distinct_prefixes: int
    max_fiber_size: int
    avg_fiber_size: float
    conditional_min_entropy: float  # log₂(|S|/B) where B = max fiber

def analyze_prefix_fibers(
    seeds: List[List[List[float]]],
    T: int,
    hash_fn: Callable = hash_sum_mod,
    modulus: int = 8
) -> List[FiberAnalysis]:
    """Analyze prefix fiber structure of the orbit hash.
    
    For each step i ≤ T:
    - Compute the prefix map s ↦ (h(G^0), ..., h(G^(i-1)))
    - Find the maximum fiber size B
    - Compute conditional min-entropy lower bound log₂(|S|/B)
    
    This implements the structural analysis behind the theorem
    `conditional_minEntropy_from_fiber`.
    
    Time: O(|S| · T · n³) for matrix powering
    Space: O(|S| · T) for hash sequences
    
    Args:
        seeds: list of seed matrices
        T: maximum orbit step
        hash_fn: hash/extractor function
        modulus: output alphabet size
    
    Returns:
        List of FiberAnalysis objects, one per step
    """
    N = len(seeds)
    
    # Precompute all hash sequences
    all_hashes = []
    for s in seeds:
        hashes = []
        for i in range(T + 1):
            power = trop_matpow(s, i)
            hashes.append(hash_fn(power, modulus))
        all_hashes.append(tuple(hashes))
    
    results = []
    for i in range(T + 1):
        prefix_map: Dict[Tuple, int] = Counter()
        for hashes in all_hashes:
            prefix = hashes[:i]
            prefix_map[prefix] += 1
        
        max_fiber = max(prefix_map.values()) if prefix_map else 0
        num_prefixes = len(prefix_map)
        avg_fiber = N / num_prefixes if num_prefixes > 0 else 0
        cond_entropy = np.log2(N / max_fiber) if max_fiber > 0 else float('inf')
        
        results.append(FiberAnalysis(
            step=i,
            num_distinct_prefixes=num_prefixes,
            max_fiber_size=max_fiber,
            avg_fiber_size=avg_fiber,
            conditional_min_entropy=cond_entropy
        ))
    
    return results

# ─────────────────────────────────────────────────────────────────────
# §6. Conditional Extraction Quality
# ─────────────────────────────────────────────────────────────────────

@dataclass
class ExtractionQuality:
    """Quality metrics for conditional extraction at a given step."""
    step: int
    max_conditional_stat_dist: float
    avg_conditional_stat_dist: float
    num_fibers: int

def measure_extraction_quality(
    seeds: List[List[List[float]]],
    T: int,
    hash_fn: Callable = hash_sum_mod,
    modulus: int = 8
) -> List[ExtractionQuality]:
    """Measure conditional extraction quality at each orbit step.
    
    For each step i, measures how close the conditional distribution
    of h(G^i) given the prefix (h(G^0),...,h(G^(i-1))) is to uniform.
    
    This validates the `condExtract` hypothesis of the main theorem.
    
    Time: O(|S| · T · n³)
    
    Args:
        seeds: list of seed matrices
        T: maximum orbit step
        hash_fn: hash/extractor function
        modulus: output alphabet size
    
    Returns:
        List of ExtractionQuality objects
    """
    N = len(seeds)
    
    all_hashes = []
    for s in seeds:
        hashes = []
        for i in range(T + 1):
            power = trop_matpow(s, i)
            hashes.append(hash_fn(power, modulus))
        all_hashes.append(tuple(hashes))
    
    results = []
    for i in range(T + 1):
        prefix_groups: Dict[Tuple, List[int]] = {}
        for hashes in all_hashes:
            prefix = hashes[:i]
            if prefix not in prefix_groups:
                prefix_groups[prefix] = []
            prefix_groups[prefix].append(hashes[i])
        
        max_sd = 0.0
        avg_sd = 0.0
        for prefix, values in prefix_groups.items():
            counts = Counter(values)
            fiber_size = len(values)
            sd = 0.0
            for b in range(modulus):
                prob = counts.get(b, 0) / fiber_size
                sd += abs(prob - 1.0 / modulus)
            sd /= 2.0
            max_sd = max(max_sd, sd)
            avg_sd += sd * fiber_size / N
        
        results.append(ExtractionQuality(
            step=i,
            max_conditional_stat_dist=max_sd,
            avg_conditional_stat_dist=avg_sd,
            num_fibers=len(prefix_groups)
        ))
    
    return results

# ─────────────────────────────────────────────────────────────────────
# §7. Hybrid Argument Bound
# ─────────────────────────────────────────────────────────────────────

def hybrid_bound(
    step_errors: List[float],
    T: int
) -> float:
    """Compute the hybrid argument bound on total statistical distance.
    
    By the tropical orbit PRG theorem (tropical_orbit_prg),
    if the conditional extraction error at each step ≤ ε,
    then the total statistical distance ≤ (T+1)·ε.
    
    This function computes the tighter bound when step errors vary:
    total ≤ ∑_{i=0}^{T} ε_i.
    
    Args:
        step_errors: list of per-step extraction errors ε_0, ..., ε_T
        T: orbit length
    
    Returns:
        Upper bound on total statistical distance
    """
    return sum(step_errors[:T+1])

def geometric_bound(
    eps0: float,
    r: float,
    T: int
) -> float:
    """Compute the geometric series bound for prime-power orbits.
    
    By `prime_power_geometric_error_bound`, if step errors decay
    geometrically as ε_j ≤ ε₀·r^j with 0 ≤ r < 1, then the
    cumulative error is bounded by ε₀/(1-r).
    
    Args:
        eps0: initial error ε₀
        r: decay rate (0 ≤ r < 1)
        T: orbit length
    
    Returns:
        Upper bound ε₀/(1-r)
    """
    assert 0 <= r < 1, f"Decay rate must satisfy 0 ≤ r < 1, got {r}"
    return eps0 / (1 - r)

# ─────────────────────────────────────────────────────────────────────
# §8. Full PRG Pipeline
# ─────────────────────────────────────────────────────────────────────

@dataclass
class PRGOutput:
    """Complete output of the tropical orbit PRG analysis."""
    seed_count: int
    orbit_length: int
    alphabet_size: int
    sequences: List[Tuple[int, ...]]
    stat_distances: List[float]  # at each prefix length
    fiber_analysis: List[FiberAnalysis]
    extraction_quality: List[ExtractionQuality]
    hybrid_bound: float
    expansion_fraction: float  # fraction of seeds with full expansion

def run_tropical_prg_analysis(
    n: int = 2,
    num_seeds: int = 64,
    T: int = 5,
    modulus: int = 4,
    value_range: int = 15,
    seed: int = 42,
    hash_fn: Callable = hash_sum_mod,
    prime_power: bool = False,
    p: int = 2
) -> PRGOutput:
    """Run complete tropical orbit PRG analysis.
    
    Full pipeline:
    1. Generate seed family
    2. Compute orbit hashes
    3. Measure statistical distance at each length
    4. Analyze prefix fibers
    5. Measure extraction quality
    6. Compute theoretical bounds
    
    Time: O(num_seeds · T · n³)
    
    Args:
        n: matrix dimension
        num_seeds: size of seed family
        T: orbit length
        modulus: hash output alphabet size
        value_range: range of matrix entries
        seed: random seed for reproducibility
        hash_fn: hash/extractor function
        prime_power: use prime-power thinning
        p: prime for thinning
    
    Returns:
        PRGOutput with complete analysis
    """
    rng = np.random.default_rng(seed)
    seeds = []
    for _ in range(num_seeds):
        M = [[int(rng.integers(0, value_range+1)) for _ in range(n)] for _ in range(n)]
        seeds.append(M)
    
    # Compute orbit hashes
    if prime_power:
        orbit_results = [compute_prime_power_orbit_hash(s, T, p, hash_fn, modulus) 
                        for s in seeds]
    else:
        orbit_results = [compute_orbit_hash(s, T, hash_fn, modulus) for s in seeds]
    
    sequences = [r.sequence for r in orbit_results]
    
    # Expansion analysis
    full_expansion = sum(1 for r in orbit_results if r.distinct_powers == T + 1)
    
    # Statistical distances at each prefix length
    stat_dists = []
    for t in range(T + 1):
        truncated = [seq[:t+1] for seq in sequences]
        sd = compute_statistical_distance(truncated, modulus, t + 1)
        stat_dists.append(sd)
    
    # Fiber analysis
    fiber_analysis = analyze_prefix_fibers(seeds, T, hash_fn, modulus)
    
    # Extraction quality
    extraction = measure_extraction_quality(seeds, T, hash_fn, modulus)
    
    # Hybrid bound
    max_eps = max(e.max_conditional_stat_dist for e in extraction)
    hbound = (T + 1) * max_eps
    
    return PRGOutput(
        seed_count=num_seeds,
        orbit_length=T,
        alphabet_size=modulus,
        sequences=sequences,
        stat_distances=stat_dists,
        fiber_analysis=fiber_analysis,
        extraction_quality=extraction,
        hybrid_bound=hbound,
        expansion_fraction=full_expansion / num_seeds
    )


if __name__ == "__main__":
    # Example usage
    result = run_tropical_prg_analysis(n=2, num_seeds=128, T=6, modulus=4)
    
    print("Tropical Orbit PRG Analysis")
    print(f"  Seeds: {result.seed_count}, T: {result.orbit_length}, "
          f"|β|: {result.alphabet_size}")
    print(f"  Expansion fraction: {result.expansion_fraction:.1%}")
    print(f"\n  Statistical distances by length:")
    for t, sd in enumerate(result.stat_distances):
        print(f"    Length {t+1}: {sd:.4f}")
    print(f"\n  Hybrid bound: {result.hybrid_bound:.4f}")
    print(f"  Actual max SD: {max(result.stat_distances):.4f}")
