#!/usr/bin/env python3
"""
Algorithms for Decomposable Matrix Verification

Implements the core algorithms from the formal theory:
1. Freivalds' probabilistic matrix verification
2. Block-diagonal decomposition and verification
3. Tropical norm bounds and robustness certificates
4. Combined local-to-global verification pipeline

All algorithms include complexity analysis, type hints, and examples.
"""

import numpy as np
from typing import Tuple, List, Optional, Dict
from dataclasses import dataclass


# ============================================================================
# Data Structures
# ============================================================================

@dataclass
class VerificationResult:
    """Result of a matrix verification check."""
    passed: bool
    confidence: float  # probability of correctness
    method: str
    details: Dict


@dataclass
class BlockStructure:
    """A block-diagonal decomposition of a matrix."""
    blocks: List[np.ndarray]
    block_sizes: List[int]
    total_size: int

    @staticmethod
    def from_blocks(blocks: List[np.ndarray]) -> 'BlockStructure':
        sizes = [b.shape[0] for b in blocks]
        return BlockStructure(blocks=blocks, block_sizes=sizes,
                              total_size=sum(sizes))

    def to_full_matrix(self) -> np.ndarray:
        """Assemble the block diagonal matrix. O(n²) where n = total_size."""
        n = self.total_size
        M = np.zeros((n, n))
        offset = 0
        for block in self.blocks:
            s = block.shape[0]
            M[offset:offset+s, offset:offset+s] = block
            offset += s
        return M


@dataclass
class TropicalCertificate:
    """A tropical robustness certificate for a matrix computation."""
    matrix_norm_bound: float  # max|M_ij|
    input_bound: float        # max|x_i|
    output_bound: float       # guaranteed bound on max|M*x|_i
    detection_margin: float    # minimum detectable discrepancy
    dimension: int


# ============================================================================
# Algorithm 1: Freivalds' Verification
# ============================================================================

def freivalds_verify(
    A: np.ndarray,
    B: np.ndarray,
    C: np.ndarray,
    trials: int = 20,
    field_size: int = 2
) -> VerificationResult:
    """
    Freivalds' randomized matrix verification algorithm.

    Checks whether A * B = C using random vector probes.

    Algorithm:
        for t = 1 to trials:
            sample r uniformly from {0,1,...,field_size-1}^n
            if A*(B*r) ≠ C*r: return FAIL
        return PASS

    Complexity:
        Time:  O(trials * n²) — each trial is two matrix-vector products
        Space: O(n) — only stores the random vector and intermediate results

    Soundness (formally verified as freivalds_detection_probability):
        If A*B ≠ C, Pr[all trials pass] ≤ (1/field_size)^trials

    Args:
        A, B, C: n×n matrices
        trials: number of independent random trials
        field_size: size of the random vector alphabet

    Returns:
        VerificationResult with confidence level
    """
    n = A.shape[0]
    assert A.shape == B.shape == C.shape == (n, n)

    for t in range(trials):
        r = np.random.randint(0, field_size, size=n).astype(float)
        lhs = A @ (B @ r)
        rhs = C @ r
        if not np.allclose(lhs, rhs, atol=1e-10):
            return VerificationResult(
                passed=False,
                confidence=1.0,
                method="freivalds",
                details={"failing_trial": t, "discrepancy": np.max(np.abs(lhs - rhs))}
            )

    false_positive_prob = (1.0 / field_size) ** trials
    return VerificationResult(
        passed=True,
        confidence=1.0 - false_positive_prob,
        method="freivalds",
        details={"trials": trials, "field_size": field_size,
                 "false_positive_bound": false_positive_prob}
    )


# ============================================================================
# Algorithm 2: Block-Diagonal Verification
# ============================================================================

def block_diagonal_verify(
    A_blocks: List[np.ndarray],
    B_blocks: List[np.ndarray],
    C_blocks: List[np.ndarray]
) -> VerificationResult:
    """
    Block-diagonal structural verification.

    Checks blockDiag(A) * blockDiag(B) = blockDiag(C) by verifying
    each block independently: A_i * B_i = C_i for all i.

    Algorithm (formally verified as block_diagonal_mul_eq_iff):
        for i = 1 to k:
            if A_i * B_i ≠ C_i: return FAIL at block i
        return PASS

    Complexity:
        Time:  O(Σ n_i³) — k independent matrix multiplications
               Compare to O(N³) for the full N×N matrix where N = Σ n_i
        Space: O(max n_i²) — only need one block at a time

    Speedup: If blocks have equal size n/k, speedup is k² over naive.

    Args:
        A_blocks, B_blocks, C_blocks: lists of square matrices (one per block)

    Returns:
        VerificationResult with failing block index if applicable
    """
    assert len(A_blocks) == len(B_blocks) == len(C_blocks)

    failing_blocks = []
    for i, (a, b, c) in enumerate(zip(A_blocks, B_blocks, C_blocks)):
        product = a @ b
        if not np.allclose(product, c):
            failing_blocks.append(i)

    if failing_blocks:
        return VerificationResult(
            passed=False,
            confidence=1.0,
            method="block_diagonal",
            details={"failing_blocks": failing_blocks,
                     "num_blocks": len(A_blocks)}
        )
    return VerificationResult(
        passed=True,
        confidence=1.0,
        method="block_diagonal",
        details={"num_blocks": len(A_blocks),
                 "block_sizes": [a.shape[0] for a in A_blocks]}
    )


# ============================================================================
# Algorithm 3: Tropical Robustness Certificate
# ============================================================================

def tropical_certificate(
    M: np.ndarray,
    x: np.ndarray
) -> TropicalCertificate:
    """
    Compute a tropical robustness certificate for a matrix-vector product.

    Given M and x, computes bounds on M*x using the tropical (max-plus)
    norm infrastructure.

    Formally verified bound (tropical_mulVec_entrywise_bound):
        |M*x|_i ≤ n * max|M_ij| * max|x_k|  for all i

    Complexity:
        Time:  O(n²) — scan all matrix entries
        Space: O(1) — only stores scalar bounds

    Args:
        M: m×n matrix
        x: n-dimensional vector

    Returns:
        TropicalCertificate with norm bounds
    """
    n = M.shape[1]
    M_max = float(np.max(np.abs(M)))
    x_max = float(np.max(np.abs(x)))
    output_bound = n * M_max * x_max

    # Detection margin: if a perturbation δM has max entry ≥ ε,
    # then the standard basis witness detects discrepancy ≥ ε
    detection_margin = M_max if M_max > 0 else 0.0

    return TropicalCertificate(
        matrix_norm_bound=M_max,
        input_bound=x_max,
        output_bound=output_bound,
        detection_margin=detection_margin,
        dimension=n
    )


def compose_tropical_certificates(
    certs: List[TropicalCertificate]
) -> float:
    """
    Compose tropical security margins from multiple independent blocks.

    Formally verified (combined_tropical_certificate):
        If each block has positive margin, the combined margin is
        the minimum of individual margins.

    Complexity:
        Time:  O(k) where k = number of blocks
        Space: O(1)
    """
    if not certs:
        return 0.0
    return min(c.detection_margin for c in certs)


# ============================================================================
# Algorithm 4: Combined Local-to-Global Verification Pipeline
# ============================================================================

def local_to_global_verify(
    A_blocks: List[np.ndarray],
    B_blocks: List[np.ndarray],
    C_blocks: List[np.ndarray],
    freivalds_trials: int = 10,
    field_size: int = 2
) -> Dict:
    """
    Combined local-to-global verification pipeline.

    Implements the enhanced trichotomy (enhanced_trichotomy_over_reals):
    1. Structural check: verify each block independently
    2. Robustness check: find bounded-norm witness if failure detected
    3. Probabilistic check: run Freivalds on the full system

    Algorithm:
        1. For each block i: check A_i * B_i = C_i
        2. If any block fails:
           a. Identify failing blocks (structural detection)
           b. Construct witness vector (robustness detection)
           c. Run Freivalds on full system (probabilistic detection)
        3. Return combined certificate

    Complexity:
        Time:  O(Σ n_i³ + trials * N²) where N = Σ n_i
        Space: O(N²) for assembling full matrices

    Args:
        A_blocks, B_blocks, C_blocks: block matrices
        freivalds_trials: number of Freivalds trials
        field_size: Freivalds field size

    Returns:
        Dictionary with results from all three pillars
    """
    results = {}

    # Pillar 1: Structural verification
    block_result = block_diagonal_verify(A_blocks, B_blocks, C_blocks)
    results["structural"] = block_result

    # Pillar 2: Robustness — find witness if blocks differ
    if not block_result.passed:
        failing = block_result.details["failing_blocks"]
        witness_info = []
        for i in failing:
            D = A_blocks[i] @ B_blocks[i] - C_blocks[i]
            # Standard basis witness (as in formal proof)
            best_j = int(np.argmax([np.linalg.norm(D[:, j])
                                     for j in range(D.shape[1])]))
            discrepancy = float(np.linalg.norm(D[:, best_j]))
            witness_info.append({
                "block": i,
                "witness_column": best_j,
                "discrepancy_norm": discrepancy
            })
        results["robustness"] = {
            "witnesses_found": True,
            "witness_details": witness_info
        }
    else:
        results["robustness"] = {"witnesses_found": False}

    # Pillar 3: Probabilistic verification on full system
    A_struct = BlockStructure.from_blocks(A_blocks)
    B_struct = BlockStructure.from_blocks(B_blocks)
    C_struct = BlockStructure.from_blocks(C_blocks)

    A_full = A_struct.to_full_matrix()
    B_full = B_struct.to_full_matrix()
    C_full = C_struct.to_full_matrix()

    freivalds_result = freivalds_verify(A_full, B_full, C_full,
                                         freivalds_trials, field_size)
    results["probabilistic"] = freivalds_result

    # Pillar 4: Tropical certificate
    D_full = A_full @ B_full - C_full
    if not np.allclose(D_full, 0):
        x = np.ones(D_full.shape[1])
        cert = tropical_certificate(D_full, x)
        results["tropical"] = cert
    else:
        results["tropical"] = None

    return results


# ============================================================================
# Example Usage
# ============================================================================

if __name__ == "__main__":
    print("=" * 70)
    print("Decomposable Verification — Algorithm Demonstrations")
    print("=" * 70)

    # Example 1: Correct computation
    n = 50
    A = np.random.randn(n, n)
    B = np.random.randn(n, n)
    C = A @ B

    print("\n--- Example 1: Correct product ---")
    result = freivalds_verify(A, B, C)
    print(f"Freivalds: passed={result.passed}, confidence={result.confidence:.10f}")

    # Example 2: Incorrect computation
    C_wrong = C.copy()
    C_wrong[0, 0] += 0.01
    print("\n--- Example 2: Incorrect product ---")
    result = freivalds_verify(A, B, C_wrong)
    print(f"Freivalds: passed={result.passed}, details={result.details}")

    # Example 3: Block-diagonal verification
    print("\n--- Example 3: Block-diagonal verification ---")
    blocks_A = [np.random.randn(10, 10) for _ in range(5)]
    blocks_B = [np.random.randn(10, 10) for _ in range(5)]
    blocks_C = [a @ b for a, b in zip(blocks_A, blocks_B)]
    blocks_C[2][0, 0] += 1.0  # break block 2

    result = block_diagonal_verify(blocks_A, blocks_B, blocks_C)
    print(f"Block verification: passed={result.passed}")
    print(f"  Failing blocks: {result.details.get('failing_blocks', [])}")

    # Example 4: Full pipeline
    print("\n--- Example 4: Full local-to-global pipeline ---")
    results = local_to_global_verify(blocks_A, blocks_B, blocks_C)
    print(f"Structural: passed={results['structural'].passed}")
    print(f"Robustness: witnesses_found={results['robustness']['witnesses_found']}")
    print(f"Probabilistic: passed={results['probabilistic'].passed}")
    if results['tropical']:
        print(f"Tropical margin: {results['tropical'].detection_margin:.4f}")

    print("\n✓ All algorithms demonstrated successfully")
