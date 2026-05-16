#!/usr/bin/env python3
"""
Tropical Orbit PRG — Algorithm Implementations

This module implements the core algorithms from the research paper:
1. Tropical matrix arithmetic (min-plus semiring)
2. Tropical orbit PRG construction
3. Conditional extraction verification
4. Statistical distance computation
5. Prefix fiber analysis
"""

import numpy as np
from typing import List, Tuple, Dict, Optional, Callable
from itertools import product as cart_product


# ============================================================
# 1. Tropical Matrix Arithmetic
# ============================================================

def tropical_add(a: float, b: float) -> float:
    """Tropical addition: min(a, b)."""
    return min(a, b)

def tropical_mul_scalar(a: float, b: float) -> float:
    """Tropical multiplication: a + b (classical addition)."""
    if a == np.inf or b == np.inf:
        return np.inf
    return a + b

def tropical_mat_mul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """
    Tropical matrix multiplication: (A ⊗ B)_{ij} = min_k(A_{ik} + B_{kj}).
    
    This computes shortest-path weights: if A encodes i-step distances and
    B encodes j-step distances, A ⊗ B encodes (i+j)-step distances.
    
    Time complexity: O(n³) for n×n matrices.
    
    Args:
        A: n×n tropical matrix
        B: n×n tropical matrix
    
    Returns:
        n×n tropical product matrix
    """
    n = A.shape[0]
    assert A.shape == B.shape == (n, n), "Matrices must be square and same size"
    
    C = np.full((n, n), np.inf)
    for i in range(n):
        for j in range(n):
            for k in range(n):
                val = tropical_mul_scalar(A[i, k], B[k, j])
                C[i, j] = tropical_add(C[i, j], val)
    return C

def tropical_mat_pow(G: np.ndarray, k: int) -> np.ndarray:
    """
    Compute G^{⊗k} (k-th tropical power).
    
    Uses repeated squaring for efficiency when k is large.
    
    Time complexity: O(n³ · log k) for n×n matrices.
    
    Args:
        G: n×n tropical matrix
        k: power (non-negative integer)
    
    Returns:
        G^{⊗k}
    """
    n = G.shape[0]
    
    if k == 0:
        # Tropical identity: 0 on diagonal, ∞ elsewhere
        result = np.full((n, n), np.inf)
        np.fill_diagonal(result, 0.0)
        return result
    
    if k == 1:
        return G.copy()
    
    # Repeated squaring
    if k % 2 == 0:
        half = tropical_mat_pow(G, k // 2)
        return tropical_mat_mul(half, half)
    else:
        return tropical_mat_mul(tropical_mat_pow(G, k - 1), G)

def tropical_identity(n: int) -> np.ndarray:
    """Tropical identity matrix: 0 on diagonal, ∞ elsewhere."""
    I = np.full((n, n), np.inf)
    np.fill_diagonal(I, 0.0)
    return I


# ============================================================
# 2. Hash Functions for Tropical Matrices
# ============================================================

def trace_hash(M: np.ndarray, q: int) -> int:
    """
    Hash a tropical matrix using the trace (sum of diagonal).
    
    h(M) = (⌊M[0,0]⌋ + ⌊M[1,1]⌋ + ...) mod q
    
    Entries that are ∞ are treated as 0 for hashing purposes.
    """
    n = M.shape[0]
    diag_sum = sum(int(M[i, i]) for i in range(n) if np.isfinite(M[i, i]))
    return diag_sum % q

def entry_hash(M: np.ndarray, q: int, i: int = 0, j: int = 0) -> int:
    """Hash using a single matrix entry."""
    val = M[i, j]
    if not np.isfinite(val):
        return 0
    return int(val) % q

def mixed_hash(M: np.ndarray, q: int) -> int:
    """Hash using a linear combination of entries."""
    n = M.shape[0]
    total = 0
    for i in range(n):
        for j in range(n):
            if np.isfinite(M[i, j]):
                total += (i + 1) * (j + 1) * int(M[i, j])
    return total % q


# ============================================================
# 3. Tropical Orbit PRG
# ============================================================

class TropicalOrbitPRG:
    """
    Pseudorandom generator based on tropical matrix orbits.
    
    Given a seed matrix G, produces a sequence of pseudorandom values
    by hashing successive tropical powers: h(G^0), h(G^1), ..., h(G^T).
    
    The main theorem guarantees that if the conditional extraction property
    holds with error ε, the output is (T+1)·ε-close to uniform.
    """
    
    def __init__(self, hash_func: Callable = trace_hash, q: int = 8):
        """
        Initialize the PRG.
        
        Args:
            hash_func: Hash function mapping matrices to {0, ..., q-1}
            q: Output alphabet size
        """
        self.hash_func = hash_func
        self.q = q
    
    def generate(self, seed: np.ndarray, T: int) -> List[int]:
        """
        Generate a pseudorandom sequence from a seed matrix.
        
        Args:
            seed: n×n tropical matrix (the seed)
            T: number of additional outputs (total length T+1)
        
        Returns:
            List of T+1 hash values in {0, ..., q-1}
        """
        output = []
        for i in range(T + 1):
            power = tropical_mat_pow(seed, i)
            output.append(self.hash_func(power, self.q))
        return output
    
    def generate_batch(self, seeds: List[np.ndarray], T: int) -> List[List[int]]:
        """Generate sequences for multiple seeds."""
        return [self.generate(s, T) for s in seeds]


# ============================================================
# 4. Statistical Distance Computation
# ============================================================

def statistical_distance(p: np.ndarray, q_dist: np.ndarray) -> float:
    """
    Compute statistical distance (total variation distance).
    
    SD(p, q) = (1/2) · Σ_x |p(x) - q(x)|
    
    Args:
        p: probability distribution (array summing to 1)
        q_dist: probability distribution (array summing to 1)
    
    Returns:
        Statistical distance in [0, 1]
    """
    assert len(p) == len(q_dist), "Distributions must have same support size"
    return 0.5 * np.sum(np.abs(p - q_dist))

def orbit_hash_stat_dist(seeds: List[np.ndarray], 
                          prg: TropicalOrbitPRG, 
                          T: int) -> float:
    """
    Compute statistical distance between orbit hash output and uniform.
    
    Args:
        seeds: list of seed matrices
        prg: the PRG instance
        T: orbit length
    
    Returns:
        Statistical distance from uniform on {0,...,q-1}^{T+1}
    """
    N = len(seeds)
    q = prg.q
    total_outputs = q ** (T + 1)
    
    # Count occurrences of each output sequence
    counts = {}
    for s in seeds:
        seq = tuple(prg.generate(s, T))
        counts[seq] = counts.get(seq, 0) + 1
    
    # Build empirical distribution
    p_emp = np.zeros(total_outputs)
    for seq, count in counts.items():
        idx = sum(seq[i] * q**i for i in range(T + 1))
        if idx < total_outputs:
            p_emp[idx] = count / N
    
    # Uniform distribution
    p_uni = np.ones(total_outputs) / total_outputs
    
    return statistical_distance(p_emp, p_uni)


# ============================================================
# 5. Conditional Extraction Verification
# ============================================================

def verify_conditional_extraction(seeds: List[np.ndarray],
                                   prg: TropicalOrbitPRG,
                                   step: int) -> Tuple[float, Dict]:
    """
    Verify the conditional extraction property at a given step.
    
    For each possible prefix hash sequence, checks that the distribution
    of the next hash value within the prefix fiber is close to uniform.
    
    Args:
        seeds: list of seed matrices
        prg: the PRG instance
        step: the step to verify (0-indexed)
    
    Returns:
        (max_sd, details): maximum statistical distance and detailed analysis
    """
    q = prg.q
    max_sd = 0.0
    details = {
        'step': step,
        'num_prefixes': q ** step,
        'nonempty_fibers': 0,
        'fiber_sizes': [],
        'fiber_sds': []
    }
    
    for prefix in cart_product(range(q), repeat=step):
        # Find seeds matching this prefix
        fiber = []
        for s in seeds:
            matches = True
            for j in range(step):
                power = tropical_mat_pow(s, j)
                if prg.hash_func(power, q) != prefix[j]:
                    matches = False
                    break
            if matches:
                fiber.append(s)
        
        if len(fiber) == 0:
            continue
        
        details['nonempty_fibers'] += 1
        details['fiber_sizes'].append(len(fiber))
        
        # Distribution of next hash value within fiber
        counts = np.zeros(q)
        for s in fiber:
            power = tropical_mat_pow(s, step)
            b = prg.hash_func(power, q)
            counts[b] += 1
        
        p_cond = counts / len(fiber)
        p_uniform = np.ones(q) / q
        
        sd = statistical_distance(p_cond, p_uniform)
        details['fiber_sds'].append(sd)
        max_sd = max(max_sd, sd)
    
    return max_sd, details


# ============================================================
# 6. Prefix Fiber Analysis
# ============================================================

def analyze_prefix_fibers(seeds: List[np.ndarray],
                           prg: TropicalOrbitPRG,
                           max_depth: int = 3) -> Dict:
    """
    Analyze the prefix fiber structure of the orbit.
    
    Args:
        seeds: list of seed matrices
        prg: the PRG instance
        max_depth: maximum prefix depth to analyze
    
    Returns:
        Dictionary with fiber statistics at each depth
    """
    q = prg.q
    results = {}
    
    for depth in range(1, max_depth + 1):
        fiber_sizes = []
        
        for prefix in cart_product(range(q), repeat=depth):
            fiber_size = 0
            for s in seeds:
                matches = True
                for j in range(depth):
                    power = tropical_mat_pow(s, j)
                    if prg.hash_func(power, q) != prefix[j]:
                        matches = False
                        break
                if matches:
                    fiber_size += 1
            
            if fiber_size > 0:
                fiber_sizes.append(fiber_size)
        
        results[depth] = {
            'nonempty_fibers': len(fiber_sizes),
            'total_prefixes': q ** depth,
            'fiber_sizes': fiber_sizes,
            'max_fiber': max(fiber_sizes) if fiber_sizes else 0,
            'mean_fiber': np.mean(fiber_sizes) if fiber_sizes else 0,
            'expected_uniform': len(seeds) / q ** depth
        }
    
    return results


# ============================================================
# 7. Example Usage
# ============================================================

if __name__ == "__main__":
    print("Tropical Orbit PRG — Algorithm Demonstrations")
    print("=" * 60)
    
    # Setup
    np.random.seed(42)
    n = 2
    q = 4
    num_seeds = 300
    
    seeds = [np.random.randint(0, 8, size=(n, n)).astype(float) 
             for _ in range(num_seeds)]
    
    prg = TropicalOrbitPRG(hash_func=trace_hash, q=q)
    
    # 1. Generate pseudorandom sequences
    print("\n1. Pseudorandom sequence generation:")
    for idx in range(3):
        seq = prg.generate(seeds[idx], T=10)
        print(f"   Seed {idx}: {seq}")
    
    # 2. Statistical distance analysis
    print("\n2. Statistical distance from uniform:")
    for T in range(4):
        sd = orbit_hash_stat_dist(seeds, prg, T)
        print(f"   T={T}: SD = {sd:.6f}, bound = {(T+1)*0.05:.6f}")
    
    # 3. Conditional extraction verification
    print("\n3. Conditional extraction verification:")
    for step in range(3):
        eps, details = verify_conditional_extraction(seeds, prg, step)
        print(f"   Step {step}: ε = {eps:.6f}, "
              f"nonempty fibers = {details['nonempty_fibers']}")
    
    # 4. Prefix fiber analysis
    print("\n4. Prefix fiber analysis:")
    fiber_results = analyze_prefix_fibers(seeds, prg, max_depth=3)
    for depth, info in fiber_results.items():
        print(f"   Depth {depth}: max fiber = {info['max_fiber']}, "
              f"mean = {info['mean_fiber']:.1f}, "
              f"expected = {info['expected_uniform']:.1f}")
    
    print("\nAll algorithms completed successfully.")
