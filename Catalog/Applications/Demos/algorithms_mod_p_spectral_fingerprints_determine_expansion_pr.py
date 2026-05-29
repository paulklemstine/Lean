#!/usr/bin/env python3
"""
Algorithms for Computing Mod-p Spectral Fingerprints

This module implements the core algorithms for the arithmetic spectral
fingerprint framework:

1. ModPFingerprint: efficient mod-p trace computation
2. PrimeFingerprintComputer: full fingerprint computation pipeline
3. SpectralGapEstimator: spectral gap estimation from fingerprint data
4. FingerprintComparator: pseudometric on fingerprints

Complexity:
- mod_p_trace_pow: O(n^3 log k) for n×n matrix, k-th power
- compute_fingerprint: O(π(P) * m * n^3 log m) where P = prime bound, m = degree bound
- fingerprint_distance: O(|fingerprint|) = O(π(P) * m)
"""

import numpy as np
from typing import Dict, List, Tuple, Optional, NamedTuple
from dataclasses import dataclass, field
import math


def sieve_primes(bound: int) -> List[int]:
    """Sieve of Eratosthenes.
    
    Args:
        bound: Upper bound for primes.
    
    Returns:
        List of all primes up to bound.
    
    Complexity: O(n log log n) time, O(n) space.
    
    Example:
        >>> sieve_primes(20)
        [2, 3, 5, 7, 11, 13, 17, 19]
    """
    if bound < 2:
        return []
    is_prime = [True] * (bound + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(bound**0.5) + 1):
        if is_prime[i]:
            for j in range(i * i, bound + 1, i):
                is_prime[j] = False
    return [i for i in range(bound + 1) if is_prime[i]]


def mod_p_matrix_pow(A: np.ndarray, k: int, p: int) -> np.ndarray:
    """Compute A^k mod p using repeated squaring.
    
    Args:
        A: Square integer matrix.
        k: Non-negative exponent.
        p: Prime modulus.
    
    Returns:
        A^k mod p as integer matrix.
    
    Complexity: O(n^3 log k) where n = matrix dimension.
    
    Example:
        >>> A = np.array([[1, 1], [0, 1]])
        >>> mod_p_matrix_pow(A, 3, 5)
        array([[1, 3],
               [0, 1]])
    """
    n = A.shape[0]
    result = np.eye(n, dtype=int)
    base = A.copy() % p
    exp = k
    while exp > 0:
        if exp & 1:
            result = result @ base % p
        base = base @ base % p
        exp >>= 1
    return result % p


def mod_p_trace_pow(A: np.ndarray, p: int, k: int) -> int:
    """Compute tr(A^k) mod p.
    
    Args:
        A: Square integer matrix.
        p: Prime modulus.
        k: Non-negative exponent.
    
    Returns:
        Integer in [0, p) equal to tr(A^k) mod p.
    
    Complexity: O(n^3 log k).
    """
    return int(np.trace(mod_p_matrix_pow(A, k, p))) % p


def exact_trace_pow(A: np.ndarray, k: int) -> int:
    """Compute tr(A^k) exactly using Python arbitrary-precision integers.
    
    Args:
        A: Square integer matrix.
        k: Non-negative exponent.
    
    Returns:
        Exact integer value of tr(A^k).
    
    Complexity: O(n^3 log k) with big integer arithmetic.
    """
    n = A.shape[0]
    M = np.eye(n, dtype=object)
    base = A.astype(object)
    exp = k
    while exp > 0:
        if exp & 1:
            M = M @ base
        base = base @ base
        exp >>= 1
    return int(np.trace(M))


@dataclass
class PrimeFingerprint:
    """A prime spectral fingerprint of an integer matrix.
    
    Stores the mod-p traces tr(A^k) mod p for all primes p ≤ prime_bound
    and all 1 ≤ k ≤ degree_bound.
    
    Attributes:
        matrix_size: Dimension of the matrix.
        prime_bound: Upper bound on primes used.
        degree_bound: Maximum power computed.
        data: Dict mapping (prime, power) to trace residue.
        primes: List of primes used.
    """
    matrix_size: int
    prime_bound: int
    degree_bound: int
    data: Dict[Tuple[int, int], int] = field(default_factory=dict)
    primes: List[int] = field(default_factory=list)
    
    @classmethod
    def compute(cls, A: np.ndarray, prime_bound: int, degree_bound: int) -> 'PrimeFingerprint':
        """Compute the prime fingerprint of matrix A.
        
        Args:
            A: Square integer matrix.
            prime_bound: Compute for all primes p ≤ prime_bound.
            degree_bound: Compute traces of A^1, ..., A^degree_bound.
        
        Returns:
            PrimeFingerprint instance.
        
        Complexity: O(π(prime_bound) * degree_bound * n^3 * log(degree_bound))
        """
        n = A.shape[0]
        primes = sieve_primes(prime_bound)
        data = {}
        for p in primes:
            for k in range(1, degree_bound + 1):
                data[(p, k)] = mod_p_trace_pow(A, p, k)
        return cls(
            matrix_size=n,
            prime_bound=prime_bound,
            degree_bound=degree_bound,
            data=data,
            primes=primes,
        )
    
    def vector(self) -> np.ndarray:
        """Return fingerprint as a flat vector for ML/comparison."""
        keys = sorted(self.data.keys())
        return np.array([self.data[k] for k in keys])
    
    def summary(self) -> str:
        """Human-readable summary."""
        lines = [f"PrimeFingerprint(n={self.matrix_size}, P≤{self.prime_bound}, deg≤{self.degree_bound})"]
        for p in self.primes[:5]:
            traces = [str(self.data.get((p, k), '?')) for k in range(1, min(6, self.degree_bound + 1))]
            lines.append(f"  mod {p}: [{', '.join(traces)}]")
        if len(self.primes) > 5:
            lines.append(f"  ... ({len(self.primes)} primes total)")
        return '\n'.join(lines)


def fingerprint_hamming_distance(fp1: PrimeFingerprint, fp2: PrimeFingerprint) -> float:
    """Normalized Hamming distance between two fingerprints.
    
    Args:
        fp1, fp2: PrimeFingerprints to compare.
    
    Returns:
        Float in [0, 1]: fraction of (p, k) pairs where traces differ.
    
    Complexity: O(|fingerprint|).
    """
    keys = set(fp1.data.keys()) & set(fp2.data.keys())
    if not keys:
        return 1.0
    mismatches = sum(1 for k in keys if fp1.data[k] != fp2.data[k])
    return mismatches / len(keys)


def fingerprint_l2_distance(fp1: PrimeFingerprint, fp2: PrimeFingerprint) -> float:
    """L2 distance between fingerprint vectors.
    
    For same-size fingerprints, compute the Euclidean distance
    between their vectorized forms (normalized by dimension).
    
    Complexity: O(|fingerprint|).
    """
    keys = sorted(set(fp1.data.keys()) & set(fp2.data.keys()))
    if not keys:
        return float('inf')
    diffs = [(fp1.data[k] - fp2.data[k]) for k in keys]
    return math.sqrt(sum(d * d for d in diffs) / len(keys))


def spectral_gap_from_eigenvalues(eigenvalues: np.ndarray, tol: float = 1e-10) -> float:
    """Extract spectral gap (smallest positive eigenvalue) from eigenvalue array.
    
    Args:
        eigenvalues: Array of real eigenvalues.
        tol: Threshold for considering an eigenvalue as zero.
    
    Returns:
        Smallest eigenvalue exceeding tol, or 0 if none exists.
    """
    positive = sorted(ev for ev in eigenvalues if ev > tol)
    return positive[0] if positive else 0.0


def verify_trace_transfer_theorem(A: np.ndarray, B: np.ndarray,
                                   prime_bound: int, degree_bound: int) -> Dict:
    """Verify the trace transfer theorem computationally.
    
    For each power k, checks whether mod-p agreement (for primes exceeding
    |tr(A^k) - tr(B^k)|) correctly implies integer trace equality.
    
    Returns:
        Dict with verification results per power.
    """
    primes = sieve_primes(prime_bound)
    results = {}
    
    for k in range(1, degree_bound + 1):
        tr_A = exact_trace_pow(A, k)
        tr_B = exact_trace_pow(B, k)
        diff = abs(tr_A - tr_B)
        
        # For each prime p, check mod-p agreement
        mod_agree = {}
        for p in primes:
            mod_agree[p] = (mod_p_trace_pow(A, p, k) == mod_p_trace_pow(B, p, k))
        
        # Confirming primes: those where mod-p agrees AND p > |diff|
        confirming = [p for p in primes if mod_agree[p] and p > diff]
        
        results[k] = {
            'tr_A': tr_A,
            'tr_B': tr_B,
            'equal': tr_A == tr_B,
            'diff': diff,
            'mod_agree': mod_agree,
            'confirming_primes': confirming,
            'theorem_applies': len(confirming) > 0 or diff == 0,
        }
    
    return results


def estimate_spectral_gap_from_fingerprint(fp: PrimeFingerprint, n: int) -> float:
    """Heuristic spectral gap estimate from fingerprint data.
    
    Uses the trace ratio tr(A^2)/tr(A) as a crude spectral moment estimator.
    For a Laplacian with eigenvalues λ_0 ≤ λ_1 ≤ ... ≤ λ_{n-1}:
      tr(L) = Σ λ_i
      tr(L^2) = Σ λ_i^2
    
    The spectral gap λ_1 can be bounded below using moment inequalities.
    
    This is a heuristic; the formal theorems give rigorous bounds under
    explicit hypotheses.
    """
    # Get traces for the largest prime (most informative)
    if not fp.primes:
        return 0.0
    p = max(fp.primes)
    
    tr1 = fp.data.get((p, 1), 0)
    tr2 = fp.data.get((p, 2), 0)
    
    if tr1 == 0:
        return 0.0
    
    # Rough heuristic: spectral gap ~ tr1/n - sqrt(tr2/n - (tr1/n)^2)
    avg = tr1 / n
    variance = max(0, tr2 / n - avg * avg)
    return max(0, avg - math.sqrt(variance))


# Example usage
if __name__ == "__main__":
    print("=== Algorithm Demonstrations ===\n")
    
    # 1. Compute fingerprint of a cycle graph
    n = 8
    L = np.zeros((n, n), dtype=int)
    for i in range(n):
        L[i, i] = 2
        L[i, (i + 1) % n] = -1
        L[(i + 1) % n, i] = -1
    
    fp = PrimeFingerprint.compute(L, prime_bound=13, degree_bound=6)
    print("Cycle C_8 Laplacian fingerprint:")
    print(fp.summary())
    
    # 2. Compare with complete graph
    K = n * np.eye(n, dtype=int) - np.ones((n, n), dtype=int)
    fp_K = PrimeFingerprint.compute(K, prime_bound=13, degree_bound=6)
    print(f"\nComplete K_8 Laplacian fingerprint:")
    print(fp_K.summary())
    
    dist = fingerprint_hamming_distance(fp, fp_K)
    print(f"\nHamming distance: {dist:.4f}")
    
    # 3. Verify trace transfer
    print("\nTrace Transfer Verification (C_8 vs K_8):")
    results = verify_trace_transfer_theorem(L, K, prime_bound=50, degree_bound=4)
    for k, r in results.items():
        print(f"  k={k}: tr(A^k)={r['tr_A']}, tr(B^k)={r['tr_B']}, "
              f"equal={r['equal']}, confirming_primes={r['confirming_primes'][:3]}")
    
    # 4. Spectral gap comparison
    eigs = np.linalg.eigvalsh(L.astype(float))
    gap = spectral_gap_from_eigenvalues(eigs)
    est = estimate_spectral_gap_from_fingerprint(fp, n)
    print(f"\nTrue spectral gap: {gap:.6f}")
    print(f"Fingerprint estimate: {est:.6f}")
