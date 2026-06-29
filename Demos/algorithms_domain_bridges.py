#!/usr/bin/env python3
"""
algorithms.py — Algorithms for module-theoretic lattice cryptography.

Implements:
1. Kernel-invariant distribution construction
2. TVD computation and contraction verification
3. Exhaustive distinguisher enumeration
4. Compression correctness checker
5. Hybrid argument evaluator

All algorithms include complexity analysis and type hints.
"""

import numpy as np
from itertools import product
from typing import Dict, List, Tuple, Optional, Callable
from dataclasses import dataclass


# ─────────────────────────────────────────────────────────
# Data Structures
# ─────────────────────────────────────────────────────────

@dataclass
class ModuleLWEInstance:
    """A Module-LWE instance over Z/qZ.
    
    Attributes:
        n: Dimension of the module.
        q: Modulus.
        A: Public matrix (m × n) over Z/qZ.
        b: Public vector (m) over Z/qZ.
        s: Secret vector (n) over Z/qZ (None if unknown).
        e: Error vector (m) over Z/qZ (None if unknown).
    """
    n: int
    q: int
    A: np.ndarray
    b: np.ndarray
    s: Optional[np.ndarray] = None
    e: Optional[np.ndarray] = None


@dataclass 
class CompressionMap:
    """A linear compression map f: Z/qZ^n → Z/qZ^k.
    
    Attributes:
        matrix: The k × n projection matrix.
        q: Modulus.
        operator_norm: Cached operator norm ‖f‖.
    """
    matrix: np.ndarray
    q: int
    operator_norm: float = 0.0
    
    def __post_init__(self):
        self.operator_norm = np.linalg.norm(self.matrix, ord=2)
    
    def apply(self, v: np.ndarray) -> np.ndarray:
        """Apply the compression map."""
        return self.matrix @ v % self.q
    
    def kernel(self) -> List[np.ndarray]:
        """Compute the kernel of f over Z/qZ (by enumeration for small instances).
        
        Time complexity: O(q^n)
        Space complexity: O(q^n · n)
        """
        n = self.matrix.shape[1]
        ker = []
        for v_tuple in product(range(self.q), repeat=n):
            v = np.array(v_tuple)
            if np.all(self.apply(v) == 0):
                ker.append(v)
        return ker


# ─────────────────────────────────────────────────────────
# Algorithm 1: Kernel-Invariant Distribution Construction
# ─────────────────────────────────────────────────────────

def construct_kernel_invariant_distribution(
    f: CompressionMap,
    coset_weights: Dict[int, float]
) -> Dict[tuple, float]:
    """Construct a kernel-invariant distribution on Z/qZ^n.
    
    Given a linear map f and weights for each coset f^{-1}(b),
    distributes weight uniformly within each coset.
    
    Args:
        f: Linear compression map.
        coset_weights: Dictionary mapping output values to probabilities.
            Must sum to 1.
    
    Returns:
        Distribution on Z/qZ^n that is kernel-invariant for f.
    
    Time complexity: O(q^n)
    Space complexity: O(q^n)
    
    Pseudocode:
        FOR each v in (Z/qZ)^n:
            b ← f(v)
            coset_size ← |ker(f)|
            dist[v] ← coset_weights[b] / coset_size
        RETURN dist
    """
    n = f.matrix.shape[1]
    kernel_size = len(f.kernel())
    
    dist = {}
    for v_tuple in product(range(f.q), repeat=n):
        v = np.array(v_tuple)
        b = tuple(f.apply(v).tolist()) if f.apply(v).ndim > 0 else int(f.apply(v))
        weight = coset_weights.get(b, 0)
        dist[v_tuple] = weight / kernel_size if kernel_size > 0 else 0
    
    return dist


def verify_kernel_invariance(
    dist: Dict[tuple, float],
    f: CompressionMap,
    tol: float = 1e-10
) -> bool:
    """Verify that a distribution is kernel-invariant for f.
    
    Checks: for all m, k with f(k) = 0: dist(m) = dist(m + k).
    
    Time complexity: O(q^n · |ker(f)|)
    Space complexity: O(1) beyond input
    """
    ker = f.kernel()
    q = f.q
    n = f.matrix.shape[1]
    
    for m_tuple in dist:
        m = np.array(m_tuple)
        for k in ker:
            shifted = tuple((m + k) % q)
            if abs(dist.get(m_tuple, 0) - dist.get(shifted, 0)) > tol:
                return False
    return True


# ─────────────────────────────────────────────────────────
# Algorithm 2: Total Variation Distance
# ─────────────────────────────────────────────────────────

def compute_tvd(
    dist1: Dict, 
    dist2: Dict
) -> float:
    """Compute total variation distance between two distributions.
    
    TVD(P, Q) = (1/2) Σ_x |P(x) - Q(x)|
    
    Time complexity: O(|support|)
    Space complexity: O(|support|)
    """
    keys = set(dist1.keys()) | set(dist2.keys())
    return 0.5 * sum(abs(dist1.get(k, 0) - dist2.get(k, 0)) for k in keys)


def compute_pushforward(
    dist: Dict[tuple, float],
    f: Callable
) -> Dict:
    """Compute the pushforward distribution f_* dist.
    
    (f_* dist)(b) = Σ_{f(a)=b} dist(a)
    
    Time complexity: O(|support|)
    Space complexity: O(|codomain|)
    """
    push = {}
    for k, p in dist.items():
        fk = f(k)
        push[fk] = push.get(fk, 0) + p
    return push


def verify_tvd_contraction(
    dist1: Dict[tuple, float],
    dist2: Dict[tuple, float],
    f: Callable
) -> Tuple[float, float, bool]:
    """Verify TVD contraction: tvd(f_*P, f_*Q) ≤ tvd(P, Q).
    
    Returns: (tvd_before, tvd_after, contraction_holds)
    """
    tvd_before = compute_tvd(dist1, dist2)
    push1 = compute_pushforward(dist1, f)
    push2 = compute_pushforward(dist2, f)
    tvd_after = compute_tvd(push1, push2)
    return tvd_before, tvd_after, tvd_after <= tvd_before + 1e-10


# ─────────────────────────────────────────────────────────
# Algorithm 3: Exhaustive Distinguisher Enumeration
# ─────────────────────────────────────────────────────────

def best_distinguishing_advantage(
    dist_real: Dict,
    dist_uniform: Dict
) -> Tuple[float, Optional[set]]:
    """Find the best distinguishing advantage by exhaustive search.
    
    The optimal distinguisher accepts x when dist_real(x) > dist_uniform(x).
    This is the Neyman-Pearson lemma applied to hypothesis testing.
    
    Time complexity: O(|support|)  (Neyman-Pearson shortcut)
    Space complexity: O(|support|)
    
    Returns: (advantage, optimal_accept_set)
    """
    accept_set = set()
    advantage = 0.0
    
    keys = set(dist_real.keys()) | set(dist_uniform.keys())
    
    # Neyman-Pearson: accept where likelihood ratio > 1
    for k in keys:
        p = dist_real.get(k, 0)
        q = dist_uniform.get(k, 0)
        if p > q:
            accept_set.add(k)
    
    accept_real = sum(dist_real.get(k, 0) for k in accept_set)
    accept_uniform = sum(dist_uniform.get(k, 0) for k in accept_set)
    advantage = abs(accept_real - accept_uniform)
    
    return advantage, accept_set


# ─────────────────────────────────────────────────────────
# Algorithm 4: Compression Correctness Checker
# ─────────────────────────────────────────────────────────

def check_compression_correctness(
    f: CompressionMap,
    encode: Callable[[int], np.ndarray],
    decode: Callable[[np.ndarray], int],
    message: int,
    error: np.ndarray,
    delta: float
) -> Dict:
    """Certified compression correctness checker.
    
    Verifies: if ‖e‖ ≤ δ and decoder tolerates ‖f‖·δ,
    then decode(encode(m) + f(e)) = m.
    
    Args:
        f: Compression map with known operator norm.
        encode: Message encoding function.
        decode: Decoding function.
        message: Message to encode.
        error: Error vector.
        delta: Noise radius bound.
    
    Returns:
        Dictionary with verification results.
    
    Time complexity: O(n·k) for n-dim input, k-dim output.
    """
    encoded = encode(message)
    compressed_noise = f.apply(error)
    noisy_codeword = (encoded + compressed_noise) % f.q
    decoded = decode(noisy_codeword)
    
    error_norm = np.linalg.norm(error)
    compressed_noise_norm = np.linalg.norm(compressed_noise)
    
    return {
        'message': message,
        'error_norm': error_norm,
        'delta': delta,
        'noise_bound_holds': error_norm <= delta,
        'operator_norm': f.operator_norm,
        'compressed_noise_norm': compressed_noise_norm,
        'norm_bound': f.operator_norm * delta,
        'norm_bound_holds': compressed_noise_norm <= f.operator_norm * delta + 1e-10,
        'decoded_message': decoded,
        'correct': decoded == message,
    }


# ─────────────────────────────────────────────────────────
# Algorithm 5: Hybrid Argument Evaluator
# ─────────────────────────────────────────────────────────

def evaluate_hybrid_argument(
    n: int,
    q: int,
    secret: np.ndarray,
    distinguisher: Callable[[int], bool],
    num_samples: int = 10000
) -> Dict:
    """Evaluate the search-to-decision hybrid argument.
    
    Computes hybrid game probabilities and verifies the telescope bound.
    
    In hybrid game i (for i = 0, ..., n):
    - Coordinates 0..i-1 use uniform randomness
    - Coordinates i..n-1 use the true secret
    
    Time complexity: O(n · num_samples)
    Space complexity: O(n)
    
    Returns:
        Dictionary with hybrid probabilities, gaps, and bound verification.
    """
    rng = np.random.default_rng(42)
    
    hybrid_probs = []
    for i in range(n + 1):
        accept = 0
        for _ in range(num_samples):
            a = rng.integers(0, q, size=n)
            s_hybrid = secret.copy()
            s_hybrid[:i] = rng.integers(0, q, size=i)
            b = int(np.sum(a * s_hybrid) % q)
            if distinguisher(b):
                accept += 1
        hybrid_probs.append(accept / num_samples)
    
    # Compute gaps
    coord_gaps = [abs(hybrid_probs[i] - hybrid_probs[i+1]) for i in range(n)]
    total_gap = abs(hybrid_probs[0] - hybrid_probs[-1])
    sum_gaps = sum(coord_gaps)
    
    return {
        'hybrid_probs': hybrid_probs,
        'coord_gaps': coord_gaps,
        'total_gap': total_gap,
        'sum_gaps': sum_gaps,
        'telescope_holds': total_gap <= sum_gaps + 1e-10,
        'average_gap': total_gap / n if n > 0 else 0,
        'max_gap': max(coord_gaps) if coord_gaps else 0,
        'pigeonhole_holds': max(coord_gaps) >= total_gap / n - 1e-10 if n > 0 and coord_gaps else True,
    }


# ─────────────────────────────────────────────────────────
# Example Usage
# ─────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Module-Theoretic Lattice Cryptography — Algorithms")
    print("=" * 55)
    
    # Example 1: Kernel-invariant distribution
    q = 5
    n_dim = 2
    P = np.array([[1, 2]])  # f(x,y) = x + 2y mod 5
    f = CompressionMap(P, q)
    
    weights = {0: 0.3, 1: 0.2, 2: 0.15, 3: 0.15, 4: 0.2}
    dist = construct_kernel_invariant_distribution(f, weights)
    is_ki = verify_kernel_invariance(dist, f)
    print(f"\n1. Kernel-invariant distribution (q={q}, n={n_dim}):")
    print(f"   Kernel-invariant: {is_ki}")
    
    # Example 2: TVD contraction
    uniform = {v: 1.0/(q**n_dim) for v in product(range(q), repeat=n_dim)}
    func = lambda v: int((v[0] + 2*v[1]) % q)
    tvd_before, tvd_after, holds = verify_tvd_contraction(dist, uniform, func)
    print(f"\n2. TVD contraction:")
    print(f"   TVD before: {tvd_before:.6f}")
    print(f"   TVD after:  {tvd_after:.6f}")
    print(f"   Contraction holds: {holds}")
    
    # Example 3: Hybrid argument
    secret = np.array([1, 3, 2, 4])
    result = evaluate_hybrid_argument(4, 7, secret, lambda b: b % 2 == 0)
    print(f"\n3. Hybrid argument (n=4, q=7):")
    print(f"   Total gap: {result['total_gap']:.4f}")
    print(f"   Sum of gaps: {result['sum_gaps']:.4f}")
    print(f"   Telescope holds: {result['telescope_holds']}")
    print(f"   Pigeonhole holds: {result['pigeonhole_holds']}")
