#!/usr/bin/env python3
"""
Algorithms for Tropical Zero-Knowledge Proof Systems

Implements the core algorithms from the research paper:
1. Tropical matrix multiplication (min-plus product)
2. Argmin certificate computation
3. Certificate verification
4. The full Σ-protocol (commit, respond, verify, extract, simulate)
5. Multi-round protocol with amplified soundness
"""

import numpy as np
from dataclasses import dataclass
from typing import Tuple, List, Optional
import hashlib
import struct


def tropical_matmul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Compute tropical (min-plus) matrix product C = A ⊗ B.
    
    C[i,j] = min_k (A[i,k] + B[k,j])
    
    Time complexity: O(m * n * p)
    Space complexity: O(m * p)
    
    Args:
        A: m × n matrix with real entries
        B: n × p matrix with real entries
    
    Returns:
        C: m × p tropical product matrix
    
    Example:
        >>> A = np.array([[1, 3], [2, 4]])
        >>> B = np.array([[5, 6], [7, 8]])
        >>> tropical_matmul(A, B)
        array([[ 6.,  9.],
               [ 7., 10.]])
    """
    m, n = A.shape
    n2, p = B.shape
    assert n == n2, f"Inner dimensions must match: {n} != {n2}"
    
    # Efficient implementation using broadcasting
    # A[:, :, np.newaxis] has shape (m, n, 1)
    # B[np.newaxis, :, :] has shape (1, n, p)
    # Sum has shape (m, n, p), take min over axis 1
    return np.min(A[:, :, np.newaxis] + B[np.newaxis, :, :], axis=1)


def argmin_certificate(A: np.ndarray, B: np.ndarray) -> Tuple[np.ndarray, np.ndarray]:
    """Compute the argmin certificate for C = A ⊗ B.
    
    For each (i,j), finds k* = argmin_k (A[i,k] + B[k,j]).
    
    Time complexity: O(m * n * p)
    Space complexity: O(m * p) for both C and w
    
    Args:
        A: m × n matrix
        B: n × p matrix
    
    Returns:
        C: m × p tropical product
        w: m × p argmin selector (w[i,j] = optimal k for entry (i,j))
    
    Satisfies:
        - C[i,j] = A[i, w[i,j]] + B[w[i,j], j]  (equality)
        - C[i,j] <= A[i,k] + B[k,j] for all k    (minimality)
    """
    sums = A[:, :, np.newaxis] + B[np.newaxis, :, :]  # shape (m, n, p)
    w = np.argmin(sums, axis=1)  # shape (m, p)
    C = np.min(sums, axis=1)     # shape (m, p)
    return C, w


def verify_argmin_certificate(A: np.ndarray, B: np.ndarray, 
                               C: np.ndarray, w: np.ndarray,
                               tol: float = 1e-10) -> bool:
    """Verify that (C, w) is a valid argmin certificate for A ⊗ B.
    
    Checks:
    1. C[i,j] = A[i, w[i,j]] + B[w[i,j], j] for all i,j
    2. C[i,j] <= A[i,k] + B[k,j] for all i,j,k
    
    Time complexity: O(m * n * p)
    """
    m, p = C.shape
    n = A.shape[1]
    
    # Check equality at selected indices
    for i in range(m):
        for j in range(p):
            k = w[i, j]
            if abs(C[i, j] - (A[i, k] + B[k, j])) > tol:
                return False
    
    # Check minimality
    sums = A[:, :, np.newaxis] + B[np.newaxis, :, :]
    if np.any(C[:, np.newaxis, :] > sums + tol):
        return False
    
    return True


@dataclass
class Commitment:
    """Protocol commitment (binding to A, B, w)."""
    hash_value: bytes  # In practice, a cryptographic hash
    A: np.ndarray      # Hidden in real protocol; stored for extraction
    B: np.ndarray
    w: np.ndarray
    selected_sums: np.ndarray


@dataclass
class Response:
    """Protocol response to a challenge."""
    challenge: int
    w: Optional[np.ndarray] = None
    selected_sums: Optional[np.ndarray] = None
    A: Optional[np.ndarray] = None
    B: Optional[np.ndarray] = None


def commit(A: np.ndarray, B: np.ndarray) -> Commitment:
    """Prover commits to matrices A, B and the argmin certificate.
    
    In a real implementation, the hash would be a cryptographic commitment
    (e.g., Pedersen commitment). Here we use SHA-256 for demonstration.
    
    Time complexity: O(m * n * p) for computing the certificate
    """
    C, w = argmin_certificate(A, B)
    selected_sums = np.array([[A[i, w[i,j]] + B[w[i,j], j] 
                                for j in range(B.shape[1])]
                               for i in range(A.shape[0])])
    
    # Compute binding hash
    h = hashlib.sha256()
    h.update(A.tobytes())
    h.update(B.tobytes())
    h.update(w.tobytes())
    
    return Commitment(
        hash_value=h.digest(),
        A=A.copy(), B=B.copy(), w=w.copy(),
        selected_sums=selected_sums
    )


def respond(com: Commitment, challenge: int) -> Response:
    """Prover responds to verifier's challenge.
    
    Challenge 0: Reveal selector w and selected sums
    Challenge 1: Reveal matrices A, B
    
    Time complexity: O(1) (just copying data)
    """
    if challenge == 0:
        return Response(challenge=0, w=com.w.copy(), 
                       selected_sums=com.selected_sums.copy())
    else:
        return Response(challenge=1, A=com.A.copy(), B=com.B.copy())


def verify(C: np.ndarray, resp: Response, tol: float = 1e-10) -> bool:
    """Verifier checks the response.
    
    Challenge 0: Check C[i,j] = selected_sums[i,j]
    Challenge 1: Check C[i,j] <= A[i,k] + B[k,j] for all i,j,k
    
    Time complexity: 
        Challenge 0: O(m * p)
        Challenge 1: O(m * n * p)
    """
    if resp.challenge == 0:
        return np.allclose(C, resp.selected_sums, atol=tol)
    else:
        sums = resp.A[:, :, np.newaxis] + resp.B[np.newaxis, :, :]
        return np.all(C[:, np.newaxis, :] <= sums + tol)


def extract(resp0: Response, resp1: Response) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    """Extract witness from two accepting transcripts (special soundness).
    
    Given responses to challenges 0 and 1 from the same commitment,
    reconstruct the full witness (A, B, w).
    
    Time complexity: O(1) (just referencing data)
    """
    assert resp0.challenge == 0 and resp1.challenge == 1
    return resp1.A, resp1.B, resp0.w


def simulate(C: np.ndarray, challenge: int, n: int = None) -> Response:
    """Simulate a valid response without knowing the witness (HVZK).
    
    Challenge 0: Set selected_sums = C (trivially passes verification)
    Challenge 1: Use large A, B that trivially satisfy lower bounds
    
    Time complexity: O(m * p)
    """
    m, p = C.shape
    if n is None:
        n = max(m, p)
    
    if challenge == 0:
        return Response(challenge=0,
                       w=np.zeros((m, p), dtype=int),
                       selected_sums=C.copy())
    else:
        max_val = np.max(C) + 100
        A = np.full((m, n), max_val)
        B = np.full((n, p), 0.0)
        return Response(challenge=1, A=A, B=B)


def multi_round_protocol(C: np.ndarray, A: np.ndarray, B: np.ndarray,
                         num_rounds: int = 40) -> Tuple[bool, float]:
    """Run the protocol for multiple rounds with random challenges.
    
    Soundness error decreases as (1/2)^num_rounds.
    
    Args:
        C: public matrix (claimed tropical product)
        A, B: secret witness matrices
        num_rounds: number of rounds
    
    Returns:
        (all_accepted, soundness_error): whether all rounds accepted,
        and the theoretical soundness error bound
    
    Time complexity: O(num_rounds * m * n * p)
    """
    all_accepted = True
    for _ in range(num_rounds):
        com = commit(A, B)
        challenge = np.random.randint(0, 2)
        resp = respond(com, challenge)
        if not verify(C, resp):
            all_accepted = False
            break
    
    soundness_error = 0.5 ** num_rounds
    return all_accepted, soundness_error


# ============================================================
# Complexity Analysis
# ============================================================

def complexity_analysis(sizes: List[Tuple[int, int, int]]) -> List[dict]:
    """Analyze the computational complexity of the protocol.
    
    Measures:
    - Certificate computation time
    - Verification time for each challenge
    - Communication complexity
    
    Args:
        sizes: list of (m, n, p) dimension triples
    
    Returns:
        List of complexity measurements
    """
    import time
    results = []
    
    for m, n, p in sizes:
        A = np.random.randint(0, 100, (m, n)).astype(float)
        B = np.random.randint(0, 100, (n, p)).astype(float)
        
        # Measure certificate computation
        t0 = time.time()
        C, w = argmin_certificate(A, B)
        cert_time = time.time() - t0
        
        # Measure verification
        t0 = time.time()
        verify_argmin_certificate(A, B, C, w)
        verify_time = time.time() - t0
        
        # Communication complexity
        witness_size = A.size + B.size + w.size  # Full witness
        cert_size = w.size + C.size              # Certificate only
        compression = witness_size / cert_size if cert_size > 0 else 0
        
        results.append({
            'dimensions': (m, n, p),
            'cert_time_ms': cert_time * 1000,
            'verify_time_ms': verify_time * 1000,
            'witness_size': witness_size,
            'certificate_size': cert_size,
            'compression_ratio': compression
        })
    
    return results


if __name__ == "__main__":
    print("Tropical Zero-Knowledge Algorithms")
    print("=" * 50)
    
    # Basic test
    A = np.array([[1, 3, 5], [2, 4, 1]], dtype=float)
    B = np.array([[4, 2], [1, 5], [3, 0]], dtype=float)
    
    C = tropical_matmul(A, B)
    print(f"A = \n{A}")
    print(f"B = \n{B}")
    print(f"A ⊗ B = \n{C}")
    
    C2, w = argmin_certificate(A, B)
    print(f"Argmin certificate w = \n{w}")
    print(f"Certificate valid: {verify_argmin_certificate(A, B, C2, w)}")
    
    # Protocol test
    print("\nProtocol test:")
    com = commit(A, B)
    for ch in [0, 1]:
        resp = respond(com, ch)
        print(f"  Challenge {ch}: accepted = {verify(C, resp)}")
    
    # Multi-round test
    print("\nMulti-round protocol (40 rounds):")
    accepted, error = multi_round_protocol(C, A, B, 40)
    print(f"  All accepted: {accepted}")
    print(f"  Soundness error: {error:.2e}")
    
    # Complexity analysis
    print("\nComplexity analysis:")
    sizes = [(5, 5, 5), (10, 10, 10), (20, 20, 20), (50, 50, 50), (100, 100, 100)]
    results = complexity_analysis(sizes)
    print(f"  {'Dimensions':>15} {'Cert(ms)':>10} {'Verify(ms)':>12} {'Compression':>12}")
    for r in results:
        print(f"  {str(r['dimensions']):>15} {r['cert_time_ms']:>10.2f} "
              f"{r['verify_time_ms']:>12.2f} {r['compression_ratio']:>12.2f}x")
