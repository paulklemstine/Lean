#!/usr/bin/env python3
"""
Algorithms for Tropical Orbit Pseudorandom Generators
======================================================

Implements the key algorithms from the research paper:
1. Tropical matrix arithmetic (max-plus semiring)
2. Orbit generation and fiber analysis
3. Universal hashing extraction
4. Statistical distance computation
5. The full tropical orbit PRG pipeline

All algorithms include type hints, docstrings, and complexity analysis.
"""

import numpy as np
from typing import List, Tuple, Dict, Optional, Callable
from collections import Counter
from dataclasses import dataclass


# ===========================================================================
# Algorithm 1: Tropical Matrix Arithmetic
# ===========================================================================

def tropical_add(a: float, b: float) -> float:
    """Tropical addition: max(a, b).
    
    Time: O(1)
    """
    return max(a, b)


def tropical_multiply(a: float, b: float) -> float:
    """Tropical multiplication: a + b (classical addition).
    
    Time: O(1)
    """
    return a + b


def tropical_mat_mul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Tropical (max-plus) matrix multiplication.
    
    (A ⊗ B)_{ij} = max_k (A_{ik} + B_{kj})
    
    Time: O(n³)
    Space: O(n²)
    
    Args:
        A: n×n matrix
        B: n×n matrix
    Returns:
        C: n×n matrix with C_{ij} = max_k(A_{ik} + B_{kj})
    """
    n = A.shape[0]
    C = np.full((n, n), -np.inf)
    for i in range(n):
        for j in range(n):
            for k in range(n):
                C[i, j] = max(C[i, j], A[i, k] + B[k, j])
    return C


def tropical_mat_pow(G: np.ndarray, k: int) -> np.ndarray:
    """Compute G^{⊗k} under tropical multiplication.
    
    Uses repeated squaring for efficiency.
    
    Time: O(n³ · log k)
    Space: O(n²)
    
    Args:
        G: n×n seed matrix
        k: power exponent
    Returns:
        G^{⊗k}: n×n tropical power matrix
    """
    n = G.shape[0]
    if k == 0:
        I = np.full((n, n), -np.inf)
        np.fill_diagonal(I, 0.0)
        return I
    if k == 1:
        return G.copy()
    
    # Repeated squaring
    if k % 2 == 0:
        half = tropical_mat_pow(G, k // 2)
        return tropical_mat_mul(half, half)
    else:
        return tropical_mat_mul(G, tropical_mat_pow(G, k - 1))


def tropical_orbit(G: np.ndarray, T: int) -> List[np.ndarray]:
    """Compute the tropical orbit G^0, G^1, ..., G^T.
    
    Time: O(n³ · T)
    Space: O(n² · T)
    
    Args:
        G: n×n seed matrix
        T: orbit length
    Returns:
        List of T+1 matrices [G^0, G^1, ..., G^T]
    """
    n = G.shape[0]
    orbit = []
    current = np.full((n, n), -np.inf)
    np.fill_diagonal(current, 0.0)
    orbit.append(current.copy())
    
    for t in range(T):
        current = tropical_mat_mul(current, G)
        orbit.append(current.copy())
    
    return orbit


# ===========================================================================
# Algorithm 2: Universal Hash Family
# ===========================================================================

@dataclass
class UniversalHashFunction:
    """A universal hash function from the Carter-Wegman family.
    
    h(x) = (sum_i a_i * x_i + b) mod m
    
    Properties:
    - Pairwise independence: Pr[h(x) = h(y)] ≤ 1/m for x ≠ y
    - Universality: suitable for leftover hash lemma extraction
    """
    a: np.ndarray   # coefficient vector
    b: int           # offset
    m: int           # output modulus
    
    def __call__(self, state: np.ndarray) -> int:
        """Apply hash to a matrix state.
        
        Time: O(n²)
        """
        flat = state.flatten().astype(int)
        return int((np.dot(self.a.astype(int), flat) + self.b) % self.m)


def sample_universal_hash(flat_dim: int, m: int, 
                          rng: Optional[np.random.RandomState] = None) -> UniversalHashFunction:
    """Sample a random universal hash function.
    
    Time: O(flat_dim)
    
    Args:
        flat_dim: dimension of flattened input
        m: output modulus
        rng: random state for reproducibility
    Returns:
        A random universal hash function
    """
    if rng is None:
        rng = np.random.RandomState()
    a = rng.randint(0, m, size=flat_dim)
    b = rng.randint(0, m)
    return UniversalHashFunction(a=a, b=b, m=m)


# ===========================================================================
# Algorithm 3: Statistical Distance Computation
# ===========================================================================

def statistical_distance(dist1: Dict[int, float], dist2: Dict[int, float],
                        support: Optional[set] = None) -> float:
    """Compute statistical distance (total variation distance) between two distributions.
    
    SD(P, Q) = (1/2) * sum_x |P(x) - Q(x)|
    
    Time: O(|support|)
    
    Args:
        dist1, dist2: distributions as {outcome: probability} dictionaries
        support: explicit support set (optional, inferred from distributions)
    Returns:
        Statistical distance in [0, 1]
    """
    if support is None:
        support = set(dist1.keys()) | set(dist2.keys())
    
    total = sum(abs(dist1.get(x, 0.0) - dist2.get(x, 0.0)) for x in support)
    return total / 2.0


def empirical_stat_dist(samples: List[int], m: int) -> float:
    """Compute statistical distance between empirical distribution and uniform.
    
    Time: O(N + m) where N = len(samples)
    
    Args:
        samples: list of observed outcomes in {0, ..., m-1}
        m: size of output space
    Returns:
        Statistical distance from uniform
    """
    N = len(samples)
    counts = Counter(samples)
    total = 0.0
    for v in range(m):
        p_empirical = counts.get(v, 0) / N
        p_uniform = 1.0 / m
        total += abs(p_empirical - p_uniform)
    return total / 2.0


# ===========================================================================
# Algorithm 4: Prefix Fiber Analysis
# ===========================================================================

def compute_prefix_fibers(seeds: List[np.ndarray], hash_fn: UniversalHashFunction,
                          t: int, T: int) -> Dict[Tuple[int, ...], List[int]]:
    """Compute prefix fibers: group seeds by their hashed orbit prefix.
    
    For each prefix (h(G^0), ..., h(G^{t-1})), collect all seed indices
    that produce that prefix.
    
    Time: O(|seeds| · t · n³)
    Space: O(|seeds|)
    
    Args:
        seeds: list of seed matrices
        hash_fn: universal hash function
        t: prefix length
        T: maximum orbit length
    Returns:
        Dictionary mapping prefix tuples to lists of seed indices
    """
    fibers = {}
    for idx, G in enumerate(seeds):
        orbit = tropical_orbit(G, T)
        prefix = tuple(hash_fn(orbit[i]) for i in range(t))
        if prefix not in fibers:
            fibers[prefix] = []
        fibers[prefix].append(idx)
    return fibers


def analyze_conditional_entropy(seeds: List[np.ndarray], hash_fn: UniversalHashFunction,
                                T: int) -> List[Dict]:
    """Analyze conditional entropy at each orbit step.
    
    For each step t, compute:
    - Number of distinct prefixes
    - Average fiber size
    - Average number of distinct next-hash values per fiber
    - Estimated conditional extraction error
    
    Time: O(|seeds| · T · n³)
    
    Args:
        seeds: list of seed matrices
        hash_fn: universal hash function
        T: orbit length
    Returns:
        List of dictionaries with analysis results for each step
    """
    results = []
    
    # Precompute all hash streams
    all_streams = []
    for G in seeds:
        orbit = tropical_orbit(G, T)
        stream = tuple(hash_fn(orbit[t]) for t in range(T + 1))
        all_streams.append(stream)
    
    for t in range(T + 1):
        # Group by prefix
        prefix_groups = {}
        for idx, stream in enumerate(all_streams):
            prefix = stream[:t]
            if prefix not in prefix_groups:
                prefix_groups[prefix] = []
            prefix_groups[prefix].append(stream[t])
        
        # Analyze each fiber
        fiber_sizes = []
        distinct_counts = []
        extraction_errors = []
        
        for prefix, next_values in prefix_groups.items():
            fiber_sizes.append(len(next_values))
            distinct_counts.append(len(set(next_values)))
            
            # Compute per-fiber extraction error
            err = empirical_stat_dist(next_values, hash_fn.m)
            extraction_errors.append(err)
        
        results.append({
            'step': t,
            'num_prefixes': len(prefix_groups),
            'avg_fiber_size': np.mean(fiber_sizes) if fiber_sizes else 0,
            'avg_distinct_next': np.mean(distinct_counts) if distinct_counts else 0,
            'max_extraction_error': max(extraction_errors) if extraction_errors else 0,
            'avg_extraction_error': np.mean(extraction_errors) if extraction_errors else 0,
        })
    
    return results


# ===========================================================================
# Algorithm 5: Full Tropical Orbit PRG Pipeline
# ===========================================================================

@dataclass
class PRGResult:
    """Result of running the tropical orbit PRG."""
    output_stream: Tuple[int, ...]
    per_step_distances: List[float]
    joint_distance_bound: float
    theorem_bound: float
    orbit_distinct: bool


def tropical_orbit_prg(G: np.ndarray, T: int, 
                       hash_fn: UniversalHashFunction) -> Tuple[int, ...]:
    """Generate a pseudorandom stream from a tropical matrix orbit.
    
    Algorithm:
    1. Compute tropical orbit G^0, G^1, ..., G^T
    2. Apply hash to each orbit state
    3. Output the hash stream
    
    Time: O(T · n³ + T · n²) = O(T · n³)
    Space: O(T · n²)
    
    Args:
        G: n×n seed matrix
        T: orbit length (output length = T+1)
        hash_fn: universal hash function
    Returns:
        Tuple of T+1 hash values (the pseudorandom stream)
    """
    orbit = tropical_orbit(G, T)
    return tuple(hash_fn(state) for state in orbit)


def evaluate_prg_quality(seeds: List[np.ndarray], T: int,
                         hash_fn: UniversalHashFunction) -> Dict:
    """Evaluate the quality of the tropical orbit PRG.
    
    Computes:
    - Per-step statistical distances from uniform
    - Joint output analysis
    - Theorem bound verification
    - Conditional entropy analysis
    
    Time: O(|seeds| · T · n³)
    
    Args:
        seeds: list of seed matrices
        T: orbit length
        hash_fn: universal hash function
    Returns:
        Dictionary with comprehensive quality metrics
    """
    m = hash_fn.m
    
    # Generate all output streams
    streams = [tropical_orbit_prg(G, T, hash_fn) for G in seeds]
    
    # Per-step distances
    per_step = []
    for t in range(T + 1):
        step_values = [s[t] for s in streams]
        d = empirical_stat_dist(step_values, m)
        per_step.append(d)
    
    avg_eps = np.mean(per_step)
    theorem_bound = (T + 1) * avg_eps
    
    # Joint analysis
    distinct_streams = len(set(streams))
    
    # Conditional entropy
    entropy_analysis = analyze_conditional_entropy(
        seeds, hash_fn, T
    )
    
    return {
        'per_step_distances': per_step,
        'avg_epsilon': avg_eps,
        'theorem_bound': theorem_bound,
        'distinct_streams': distinct_streams,
        'total_possible': m ** (T + 1),
        'num_seeds': len(seeds),
        'entropy_analysis': entropy_analysis,
    }


# ===========================================================================
# Algorithm 6: Orbit Expansion Checker
# ===========================================================================

def check_orbit_expansion(G: np.ndarray, T: int) -> Dict:
    """Check the expansion properties of a tropical orbit.
    
    Verifies:
    - Distinctness of orbit states
    - Growth rate of entries
    - Periodicity detection
    
    Time: O(T · n³)
    
    Args:
        G: n×n seed matrix
        T: orbit length
    Returns:
        Dictionary with expansion metrics
    """
    orbit = tropical_orbit(G, T)
    
    # Check distinctness
    states = [M.tobytes() for M in orbit]
    distinct = len(set(states))
    all_distinct = (distinct == T + 1)
    
    # Entry growth rate
    max_entries = [np.max(M[np.isfinite(M)]) if np.any(np.isfinite(M)) else 0 
                   for M in orbit]
    
    # Detect periodicity
    period = None
    for p in range(1, T + 1):
        if all(states[i] == states[i + p] for i in range(T + 1 - p)):
            period = p
            break
    
    return {
        'distinct_states': distinct,
        'total_states': T + 1,
        'all_distinct': all_distinct,
        'max_entry_growth': max_entries,
        'period': period,
    }


# ===========================================================================
# Example Usage
# ===========================================================================

if __name__ == "__main__":
    print("Tropical Orbit PRG Algorithms")
    print("=" * 50)
    
    # Setup
    n, q, T, m = 2, 5, 6, 16
    rng = np.random.RandomState(42)
    
    # Sample hash function
    hash_fn = sample_universal_hash(n * n, m, rng)
    print(f"Hash: h(x) = ({hash_fn.a} · x + {hash_fn.b}) mod {hash_fn.m}")
    
    # Generate seeds
    num_seeds = 1000
    seeds = [rng.randint(0, q, size=(n, n)) for _ in range(num_seeds)]
    
    # Run PRG evaluation
    print(f"\nEvaluating PRG quality with {num_seeds} seeds, T={T}...")
    quality = evaluate_prg_quality(seeds, T, hash_fn)
    
    print(f"\nPer-step statistical distances:")
    for t, d in enumerate(quality['per_step_distances']):
        print(f"  Step {t}: {d:.4f}")
    
    print(f"\nAverage ε: {quality['avg_epsilon']:.4f}")
    print(f"Theorem bound (T+1)*ε: {quality['theorem_bound']:.4f}")
    print(f"Distinct streams: {quality['distinct_streams']}/{quality['num_seeds']}")
    
    # Conditional entropy analysis
    print(f"\nConditional Entropy Analysis:")
    for info in quality['entropy_analysis']:
        print(f"  Step {info['step']}: "
              f"{info['num_prefixes']} prefixes, "
              f"avg fiber={info['avg_fiber_size']:.1f}, "
              f"avg distinct next={info['avg_distinct_next']:.1f}, "
              f"max extraction err={info['max_extraction_error']:.4f}")
    
    # Check orbit expansion for a single seed
    G = seeds[0]
    print(f"\nOrbit expansion check for seed G_0:")
    expansion = check_orbit_expansion(G, T)
    print(f"  Distinct states: {expansion['distinct_states']}/{expansion['total_states']}")
    print(f"  All distinct: {expansion['all_distinct']}")
    print(f"  Period: {expansion['period']}")
    print(f"  Max entry growth: {[f'{x:.0f}' for x in expansion['max_entry_growth']]}")
