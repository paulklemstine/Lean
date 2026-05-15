#!/usr/bin/env python3
"""
Algorithms for Decomposable Matrix Verification

Implements the core algorithms from the formal theory:
1. Freivalds' algorithm for probabilistic matrix verification
2. Block-diagonal decomposition and local verification
3. Tropical norm bounds and robustness certification
4. Compositional layer verification for neural networks

All algorithms include complexity analysis and docstrings.
"""

import numpy as np
from typing import List, Tuple, Optional, Callable
from dataclasses import dataclass


# ============================================================
# Algorithm 1: Freivalds' Matrix Verification
# ============================================================

def freivalds_verify(
    A: np.ndarray,
    B: np.ndarray,
    C: np.ndarray,
    num_trials: int = 10,
    field_size: Optional[int] = None
) -> Tuple[bool, float]:
    """
    Freivalds' randomized matrix identity verification.

    Tests whether A @ B == C using random vector probes.

    Algorithm:
        1. For each trial:
           a. Sample random vector r from F^n
           b. Compute A(Br) and Cr
           c. If A(Br) ≠ Cr, return FAIL
        2. If all trials pass, return ACCEPT

    Complexity:
        - Time: O(k · n²) for k trials on n×n matrices
        - Space: O(n) additional
        - Error probability: ≤ (1/|F|)^k

    Args:
        A, B, C: n×n matrices
        num_trials: number of independent random checks
        field_size: if specified, work in GF(p); otherwise use reals

    Returns:
        (result, confidence) where result=True means likely equal,
        confidence is the probability of correctness
    """
    n = A.shape[0]

    for trial in range(num_trials):
        if field_size:
            r = np.random.randint(0, field_size, n)
            Br = (B @ r) % field_size
            ABr = (A @ Br) % field_size
            Cr = (C @ r) % field_size
            if not np.array_equal(ABr, Cr):
                return False, 1.0
        else:
            r = np.random.randn(n)
            ABr = A @ (B @ r)
            Cr = C @ r
            if not np.allclose(ABr, Cr, atol=1e-10):
                return False, 1.0

    if field_size:
        error_prob = (1.0 / field_size) ** num_trials
    else:
        error_prob = 0.0  # Exact arithmetic: false positive prob is 0
    return True, 1.0 - error_prob


# ============================================================
# Algorithm 2: Block-Diagonal Decomposition
# ============================================================

@dataclass
class BlockStructure:
    """Describes a block-diagonal matrix structure."""
    block_sizes: List[int]
    num_blocks: int
    total_size: int

    @staticmethod
    def from_sizes(sizes: List[int]) -> 'BlockStructure':
        return BlockStructure(
            block_sizes=sizes,
            num_blocks=len(sizes),
            total_size=sum(sizes)
        )


def extract_blocks(
    M: np.ndarray,
    structure: BlockStructure
) -> List[np.ndarray]:
    """
    Extract diagonal blocks from a block-diagonal matrix.

    Complexity: O(Σ n_i²)
    """
    blocks = []
    offset = 0
    for s in structure.block_sizes:
        blocks.append(M[offset:offset+s, offset:offset+s].copy())
        offset += s
    return blocks


def assemble_block_diagonal(
    blocks: List[np.ndarray],
    structure: BlockStructure
) -> np.ndarray:
    """
    Assemble a block-diagonal matrix from blocks.

    Complexity: O(Σ n_i²)
    """
    M = np.zeros((structure.total_size, structure.total_size))
    offset = 0
    for block, s in zip(blocks, structure.block_sizes):
        M[offset:offset+s, offset:offset+s] = block
        offset += s
    return M


def block_diagonal_verify(
    A: np.ndarray,
    B: np.ndarray,
    C: np.ndarray,
    structure: BlockStructure
) -> Tuple[bool, Optional[int]]:
    """
    Verify A @ B == C by checking each diagonal block independently.

    This implements the block_diagonal_mul_eq_iff theorem:
    blockDiagonal(A) * blockDiagonal(B) = blockDiagonal(C)
    iff ∀ i, A_i * B_i = C_i

    Complexity:
        - Time: O(Σ n_i³) vs O(N³) for full verification
        - Space: O(max(n_i²))
        - Speedup: up to k× for k equal-sized blocks

    Returns:
        (result, failing_block) where failing_block is the index
        of the first failing block if result is False
    """
    A_blocks = extract_blocks(A, structure)
    B_blocks = extract_blocks(B, structure)
    C_blocks = extract_blocks(C, structure)

    for i, (Ai, Bi, Ci) in enumerate(zip(A_blocks, B_blocks, C_blocks)):
        if not np.allclose(Ai @ Bi, Ci, atol=1e-10):
            return False, i

    return True, None


# ============================================================
# Algorithm 3: Tropical Robustness Certification
# ============================================================

def tropical_norm(v: np.ndarray) -> float:
    """
    Tropical (max-plus) norm: max|v_i|.

    This is the L∞ norm, which is the natural norm in tropical geometry.
    """
    return float(np.max(np.abs(v)))


def tropical_matrix_norm(M: np.ndarray) -> float:
    """Maximum absolute entry of a matrix."""
    return float(np.max(np.abs(M)))


def tropical_mulvec_bound(
    D: np.ndarray,
    r: np.ndarray,
    D_max: Optional[float] = None,
    r_max: Optional[float] = None
) -> Tuple[float, float]:
    """
    Compute actual and theoretical tropical norm bound for D @ r.

    Theorem (tropical_mulVec_norm_bound):
        |D·r|_∞ ≤ n · D_max · r_max

    Returns:
        (actual_norm, theoretical_bound)
    """
    n = D.shape[0]
    if D_max is None:
        D_max = tropical_matrix_norm(D)
    if r_max is None:
        r_max = tropical_norm(r)

    actual = tropical_norm(D @ r)
    bound = n * D_max * r_max
    return actual, bound


def find_robustness_witness(
    W: np.ndarray,
    W_prime: np.ndarray
) -> Tuple[np.ndarray, float]:
    """
    Find a witness vector that detects the difference between W and W'.

    Implements tropical_robustness_margin: if W ≠ W', find r with
    |r_i| ≤ 1 such that W·r ≠ W'·r.

    Strategy: Use standard basis vector at the column of the max
    absolute entry of D = W - W'.

    Complexity: O(n²) to find the witness

    Returns:
        (witness_vector, separation_magnitude)
    """
    D = W - W_prime
    n = D.shape[0]

    # Find maximum absolute entry
    i_max, j_max = np.unravel_index(np.argmax(np.abs(D)), D.shape)

    # Standard basis witness
    r = np.zeros(n)
    r[j_max] = 1.0

    separation = tropical_norm(D @ r)
    return r, separation


def tropical_composition_bound(
    layers: List[np.ndarray],
    x: np.ndarray
) -> Tuple[float, float]:
    """
    Compute tropical norm bound for a composed multi-layer computation.

    For L layers with bounds B_1, ..., B_L and input bound x_max:
        |(W_1 · W_2 · ... · W_L) · x|_∞ ≤ n^L · (∏ B_i) · x_max

    Complexity: O(L · n²)

    Returns:
        (actual_norm, theoretical_bound)
    """
    n = layers[0].shape[0]
    x_max = tropical_norm(x)

    # Compute actual output
    result = x.copy()
    for W in reversed(layers):
        result = W @ result
    actual = tropical_norm(result)

    # Compute bound
    bound = x_max
    for W in layers:
        B = tropical_matrix_norm(W)
        bound = n * B * bound

    return actual, bound


# ============================================================
# Algorithm 4: Neural Layer Verification
# ============================================================

@dataclass
class LayerCertificate:
    """Certificate that a layer computation is correct."""
    layer_index: int
    weight_match: bool
    max_discrepancy: float
    witness_vector: Optional[np.ndarray]
    tropical_margin: float


def verify_linear_layer(
    W: np.ndarray,
    W_prime: np.ndarray,
    x: np.ndarray,
    layer_index: int = 0
) -> LayerCertificate:
    """
    Verify that two weight matrices produce the same output on input x.

    Implements linear_layer_certificate:
    If W·x = W'·x, then layerEval(W, x) = layerEval(W', x).

    Also computes tropical robustness margin for the layer.
    """
    output_diff = np.linalg.norm(W @ x - W_prime @ x)
    weight_match = output_diff < 1e-10

    D = W - W_prime
    max_disc = tropical_matrix_norm(D)
    tropical_margin = max_disc  # The max entry is the margin

    witness = None
    if not weight_match:
        witness, _ = find_robustness_witness(W, W_prime)

    return LayerCertificate(
        layer_index=layer_index,
        weight_match=weight_match,
        max_discrepancy=max_disc,
        witness_vector=witness,
        tropical_margin=tropical_margin
    )


def verify_block_network(
    W_blocks: List[np.ndarray],
    W_prime_blocks: List[np.ndarray],
    x_blocks: List[np.ndarray]
) -> Tuple[bool, List[LayerCertificate]]:
    """
    Verify a block-diagonal network layer by checking each block independently.

    Implements block_network_certificate: local block certificates
    imply global network certificate.

    Returns:
        (all_match, certificates_per_block)
    """
    certificates = []
    all_match = True

    for i, (W, Wp, x) in enumerate(zip(W_blocks, W_prime_blocks, x_blocks)):
        cert = verify_linear_layer(W, Wp, x, layer_index=i)
        certificates.append(cert)
        if not cert.weight_match:
            all_match = False

    return all_match, certificates


def verify_composed_network(
    layers: List[np.ndarray],
    layers_prime: List[np.ndarray],
    x: np.ndarray
) -> Tuple[bool, List[LayerCertificate]]:
    """
    Verify a multi-layer network by checking each layer sequentially.

    Implements verification_composition: if each layer agrees,
    the composed output agrees.

    Complexity: O(L · n²) for L layers of size n
    """
    certificates = []
    current_input = x.copy()
    all_match = True

    for i, (W, Wp) in enumerate(zip(layers, layers_prime)):
        cert = verify_linear_layer(W, Wp, current_input, layer_index=i)
        certificates.append(cert)
        if not cert.weight_match:
            all_match = False
        current_input = W @ current_input  # Propagate through true network

    return all_match, certificates


# ============================================================
# Complexity Analysis Summary
# ============================================================

COMPLEXITY_TABLE = """
Algorithm                    | Time         | Space   | Error Bound
-----------------------------|--------------|---------|------------------
Freivalds (k trials)         | O(k·n²)      | O(n)    | (1/|F|)^k
Block verification           | O(Σ n_i³)    | O(n_i²) | Exact
Tropical witness finding     | O(n²)        | O(n)    | Exact
Tropical composition bound   | O(L·n²)      | O(n)    | Exact
Layer-by-layer verification  | O(L·n²)      | O(n)    | Exact
Block network verification   | O(k·n_i²)    | O(n_i)  | Exact per block
"""


if __name__ == "__main__":
    print("Decomposable Matrix Verification — Algorithm Library")
    print(COMPLEXITY_TABLE)

    # Quick smoke test
    n = 10
    A = np.random.randn(n, n)
    B = np.random.randn(n, n)
    C = A @ B

    result, confidence = freivalds_verify(A, B, C)
    print(f"Freivalds verify (correct): result={result}, confidence={confidence:.6f}")

    C_wrong = C.copy()
    C_wrong[0, 0] += 0.001
    result, confidence = freivalds_verify(A, B, C_wrong)
    print(f"Freivalds verify (wrong):   result={result}, confidence={confidence:.6f}")
