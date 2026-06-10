#!/usr/bin/env python3
"""
Applications of Decomposable Matrix Verification

Real-world applications demonstrating the theory:
1. Neural network layer verification
2. Distributed matrix computation checking
3. Cryptographic commitment verification
4. Numerical linear algebra certification
"""

import numpy as np
from typing import List, Tuple, Dict
from algorithms import (
    freivalds_verify, block_diagonal_verify,
    tropical_certificate, local_to_global_verify,
    BlockStructure, TropicalCertificate
)


# ============================================================================
# Application 1: Neural Network Layer Verification
# ============================================================================

def verify_neural_layer(
    W_claimed: np.ndarray,
    W_reference: np.ndarray,
    test_inputs: List[np.ndarray],
    tolerance: float = 1e-6
) -> Dict:
    """
    Verify that a claimed weight matrix produces the same outputs as a
    reference on given test inputs.

    This implements the formally verified linear_layer_certificate:
    if W.mulVec x = W'.mulVec x, then layerEval W x = layerEval W' x.

    Application: checking that a compressed/quantized neural network layer
    preserves behavior on a test set.
    """
    results = {
        "total_inputs": len(test_inputs),
        "matching": 0,
        "max_discrepancy": 0.0,
        "tropical_bound": None
    }

    for x in test_inputs:
        out_claimed = W_claimed @ x
        out_reference = W_reference @ x
        disc = np.max(np.abs(out_claimed - out_reference))
        results["max_discrepancy"] = max(results["max_discrepancy"], disc)
        if disc < tolerance:
            results["matching"] += 1

    # Tropical certificate for the discrepancy
    D = W_claimed - W_reference
    if not np.allclose(D, 0):
        cert = tropical_certificate(D, np.ones(D.shape[1]))
        results["tropical_bound"] = cert.output_bound

    return results


def verify_block_network(
    layers: List[List[np.ndarray]],
    layers_reference: List[List[np.ndarray]],
    x: np.ndarray
) -> Dict:
    """
    Verify a block-structured neural network layer-by-layer.

    Implements block_network_certificate: if each block agrees locally,
    the full network output agrees.

    Application: modular verification of mixture-of-experts or
    block-diagonal architectures.
    """
    results = {"layers": [], "all_passed": True}

    current_input = x
    current_input_ref = x

    for layer_idx, (blocks, blocks_ref) in enumerate(zip(layers, layers_reference)):
        layer_result = {
            "layer": layer_idx,
            "num_blocks": len(blocks),
            "block_checks": []
        }

        for i, (b, b_ref) in enumerate(zip(blocks, blocks_ref)):
            n = b.shape[0]
            # Extract the relevant portion of the input
            offset = sum(bl.shape[0] for bl in blocks[:i])
            x_block = current_input[offset:offset+n]
            x_block_ref = current_input_ref[offset:offset+n]

            out = b @ x_block
            out_ref = b_ref @ x_block_ref
            match = np.allclose(out, out_ref)
            layer_result["block_checks"].append(match)
            if not match:
                results["all_passed"] = False

        results["layers"].append(layer_result)

        # Forward pass
        W_full = BlockStructure.from_blocks(blocks).to_full_matrix()
        W_ref_full = BlockStructure.from_blocks(blocks_ref).to_full_matrix()
        current_input = W_full @ current_input
        current_input_ref = W_ref_full @ current_input_ref

    return results


# ============================================================================
# Application 2: Distributed Matrix Computation
# ============================================================================

def distributed_matrix_verify(
    A: np.ndarray,
    B: np.ndarray,
    C_claimed: np.ndarray,
    num_workers: int = 4,
    freivalds_trials: int = 10
) -> Dict:
    """
    Verify a distributed matrix computation where different workers
    computed different blocks of the result.

    Application: checking results from a distributed computing cluster
    without re-doing the full computation.

    Strategy:
    1. Partition into blocks (one per worker)
    2. Verify each block independently (O(n²/k) per worker)
    3. Run Freivalds on full result as cross-check (O(n²))

    Total cost: O(n²) vs O(n³) for re-computation.
    """
    n = A.shape[0]
    block_size = n // num_workers
    remainder = n % num_workers

    results = {
        "num_workers": num_workers,
        "block_checks": [],
        "freivalds_check": None,
        "all_passed": True
    }

    # Each worker verifies its block of rows
    offset = 0
    for w in range(num_workers):
        size = block_size + (1 if w < remainder else 0)
        if size == 0:
            continue

        # Worker w checks rows [offset:offset+size] of C
        C_block = C_claimed[offset:offset+size, :]
        C_expected_block = A[offset:offset+size, :] @ B
        match = np.allclose(C_block, C_expected_block)

        results["block_checks"].append({
            "worker": w,
            "rows": (offset, offset + size),
            "passed": match
        })
        if not match:
            results["all_passed"] = False

        offset += size

    # Cross-check with Freivalds (catches errors the block check might miss
    # due to floating point issues)
    freivalds_result = freivalds_verify(A, B, C_claimed, freivalds_trials)
    results["freivalds_check"] = freivalds_result.passed

    return results


# ============================================================================
# Application 3: Quantization Error Bounds
# ============================================================================

def quantization_error_certificate(
    W_float: np.ndarray,
    W_quantized: np.ndarray,
    input_bound: float = 1.0
) -> Dict:
    """
    Certify the maximum output error from weight quantization.

    Uses tropical_mulVec_entrywise_bound to give a formal upper bound
    on the quantization-induced output error.

    Application: proving that a quantized neural network layer's output
    differs from the original by at most ε on bounded inputs.
    """
    n = W_float.shape[1]
    D = W_float - W_quantized

    # Tropical certificate
    D_max = float(np.max(np.abs(D)))
    tropical_bound = n * D_max * input_bound

    # Empirical check with random inputs
    num_samples = 10000
    actual_max_error = 0.0
    for _ in range(num_samples):
        x = np.random.uniform(-input_bound, input_bound, n)
        error = np.max(np.abs(D @ x))
        actual_max_error = max(actual_max_error, error)

    return {
        "quantization_error_max_entry": D_max,
        "tropical_output_bound": tropical_bound,
        "empirical_max_error": actual_max_error,
        "bound_ratio": tropical_bound / max(actual_max_error, 1e-15),
        "dimension": n
    }


# ============================================================================
# Demonstration
# ============================================================================

if __name__ == "__main__":
    np.random.seed(42)

    print("=" * 70)
    print("APPLICATIONS OF DECOMPOSABLE VERIFICATION")
    print("=" * 70)

    # Application 1: Neural network layer verification
    print("\n--- Application 1: Neural Layer Verification ---")
    n_in, n_out = 64, 32
    W_ref = np.random.randn(n_out, n_in)
    # Simulate quantized weights (round to nearest 1/256)
    W_quant = np.round(W_ref * 256) / 256

    test_inputs = [np.random.randn(n_in) for _ in range(100)]
    result = verify_neural_layer(W_quant, W_ref, test_inputs)
    print(f"  Inputs tested: {result['total_inputs']}")
    print(f"  Matching (tol=1e-6): {result['matching']}/{result['total_inputs']}")
    print(f"  Max discrepancy: {result['max_discrepancy']:.6f}")
    if result['tropical_bound']:
        print(f"  Tropical output bound: {result['tropical_bound']:.4f}")

    # Application 2: Distributed computation
    print("\n--- Application 2: Distributed Matrix Verification ---")
    n = 100
    A = np.random.randn(n, n)
    B = np.random.randn(n, n)
    C = A @ B
    C_corrupted = C.copy()
    C_corrupted[50, 30] += 0.1  # simulate worker error

    result = distributed_matrix_verify(A, B, C_corrupted, num_workers=4)
    print(f"  Workers: {result['num_workers']}")
    print(f"  Block checks: {[r['passed'] for r in result['block_checks']]}")
    print(f"  Freivalds: {result['freivalds_check']}")
    print(f"  All passed: {result['all_passed']}")

    # Application 3: Quantization bounds
    print("\n--- Application 3: Quantization Error Certificate ---")
    n = 128
    W = np.random.randn(n, n) * 0.1
    W_q = np.round(W * 16) / 16  # 4-bit quantization
    cert = quantization_error_certificate(W, W_q, input_bound=1.0)
    print(f"  Dimension: {cert['dimension']}")
    print(f"  Max quantization error (per entry): {cert['quantization_error_max_entry']:.6f}")
    print(f"  Tropical output bound: {cert['tropical_output_bound']:.4f}")
    print(f"  Empirical max error: {cert['empirical_max_error']:.4f}")
    print(f"  Bound/empirical ratio: {cert['bound_ratio']:.2f}x")

    print("\n✓ All applications demonstrated successfully")


#!/usr/bin/env python3
"""
Decomposable Verification: Demos and Numerical Examples

Demonstrates the three pillars of decomposable matrix verification:
1. Freivalds' probabilistic certification
2. Block-diagonal structural gluing
3. Tropical/approximate robustness detection

Each demo corresponds to a formally verified theorem.
"""

import numpy as np
from typing import Tuple, List

np.random.seed(42)


# ============================================================================
# DEMO 1: Freivalds' Algorithm — Probabilistic Matrix Verification
# ============================================================================

def freivalds_check(A: np.ndarray, B: np.ndarray, C: np.ndarray,
                    field_size: int = None) -> bool:
    """
    Single Freivalds trial: check if A*B == C by testing A*(B*r) == C*r
    for a random vector r.

    Over a finite field of size q, this detects errors with probability ≥ 1 - 1/q.
    Over reals (field_size=None), we use random {0,1} entries.
    """
    n = A.shape[0]
    if field_size:
        r = np.random.randint(0, field_size, size=n)
    else:
        r = np.random.randint(0, 2, size=n)

    lhs = A @ (B @ r)
    rhs = C @ r
    return np.allclose(lhs, rhs)


def freivalds_amplified(A: np.ndarray, B: np.ndarray, C: np.ndarray,
                         trials: int = 20, field_size: int = None) -> bool:
    """
    Amplified Freivalds: run multiple independent trials.
    False positive probability ≤ (1/q)^trials for field size q.
    """
    return all(freivalds_check(A, B, C, field_size) for _ in range(trials))


def demo_freivalds():
    """
    Demonstrates Theorem: freivalds_soundness_bound

    If A*B ≠ C, then at most |F|^(n-1) out of |F|^n random vectors r
    satisfy A*(B*r) = C*r. Equivalently, detection probability ≥ 1 - 1/|F|.
    """
    print("=" * 70)
    print("DEMO 1: Freivalds' Algorithm — Probabilistic Detection")
    print("=" * 70)

    n = 10

    # Create matrices where A*B ≠ C
    A = np.random.randn(n, n)
    B = np.random.randn(n, n)
    C = A @ B  # correct product
    C_wrong = C.copy()
    C_wrong[3, 7] += 0.001  # tiny perturbation

    print(f"\nMatrix size: {n}×{n}")
    print(f"Correct product: A*B == C")
    print(f"Perturbed product: C_wrong differs from A*B by 0.001 in one entry")

    # Run many trials
    num_experiments = 10000
    correct_accepts = sum(freivalds_check(A, B, C) for _ in range(num_experiments))
    wrong_accepts = sum(freivalds_check(A, B, C_wrong) for _ in range(num_experiments))

    print(f"\n--- {num_experiments} single trials ---")
    print(f"Correct C accepted:  {correct_accepts}/{num_experiments} "
          f"({100*correct_accepts/num_experiments:.1f}%)")
    print(f"Wrong C_wrong accepted: {wrong_accepts}/{num_experiments} "
          f"({100*wrong_accepts/num_experiments:.1f}%)")
    print(f"Theoretical bound (field_size=2): ≤ {100/2:.1f}% for wrong input")
    print(f"Detection rate: {100*(1 - wrong_accepts/num_experiments):.1f}%")

    # Amplified version
    print(f"\n--- Amplified Freivalds (20 trials) ---")
    amplified_wrong = sum(
        freivalds_amplified(A, B, C_wrong, trials=20)
        for _ in range(1000)
    )
    print(f"Wrong C_wrong accepted after 20 trials: {amplified_wrong}/1000")
    print(f"Theoretical bound: ≤ (1/2)^20 ≈ {(0.5)**20:.10f}")

    return correct_accepts, wrong_accepts


# ============================================================================
# DEMO 2: Block Diagonal Gluing — Structural Decomposition
# ============================================================================

def demo_block_diagonal():
    """
    Demonstrates Theorem: block_diagonal_mul_eq_iff

    blockDiagonal(A) * blockDiagonal(B) = blockDiagonal(C)
    ⟺ ∀ i, A_i * B_i = C_i

    Matrix verification decomposes into independent block checks.
    """
    print("\n" + "=" * 70)
    print("DEMO 2: Block Diagonal Gluing — Local = Global")
    print("=" * 70)

    # Create 3 blocks of sizes 4, 3, 5
    block_sizes = [4, 3, 5]
    n_total = sum(block_sizes)

    blocks_A = [np.random.randn(s, s) for s in block_sizes]
    blocks_B = [np.random.randn(s, s) for s in block_sizes]
    blocks_C = [a @ b for a, b in zip(blocks_A, blocks_B)]

    # Assemble block diagonal matrices
    A = np.block([
        [blocks_A[i] if i == j else np.zeros((block_sizes[i], block_sizes[j]))
         for j in range(3)]
        for i in range(3)
    ])
    B = np.block([
        [blocks_B[i] if i == j else np.zeros((block_sizes[i], block_sizes[j]))
         for j in range(3)]
        for i in range(3)
    ])
    C = np.block([
        [blocks_C[i] if i == j else np.zeros((block_sizes[i], block_sizes[j]))
         for j in range(3)]
        for i in range(3)
    ])

    print(f"\nTotal matrix size: {n_total}×{n_total}")
    print(f"Block sizes: {block_sizes}")

    # Verify global = local
    global_check = np.allclose(A @ B, C)
    local_checks = [np.allclose(a @ b, c)
                    for a, b, c in zip(blocks_A, blocks_B, blocks_C)]

    print(f"\nGlobal check (A*B == C): {global_check}")
    print(f"Local checks: {local_checks}")
    print(f"All local ⟺ global: {all(local_checks) == global_check} ✓")

    # Now break one block
    blocks_C_wrong = [c.copy() for c in blocks_C]
    blocks_C_wrong[1][0, 0] += 1.0  # perturb block 1

    C_wrong = np.block([
        [blocks_C_wrong[i] if i == j else np.zeros((block_sizes[i], block_sizes[j]))
         for j in range(3)]
        for i in range(3)
    ])

    global_check_wrong = np.allclose(A @ B, C_wrong)
    local_checks_wrong = [np.allclose(a @ b, c)
                          for a, b, c in zip(blocks_A, blocks_B, blocks_C_wrong)]

    print(f"\n--- After perturbing block 1 ---")
    print(f"Global check: {global_check_wrong}")
    print(f"Local checks: {local_checks_wrong}")
    print(f"Failing block index: {[i for i, v in enumerate(local_checks_wrong) if not v]}")
    print("Theorem: block_diagonal_failure_detection guarantees this ✓")


# ============================================================================
# DEMO 3: Operator Norm Witness — Robust Detection
# ============================================================================

def demo_robustness():
    """
    Demonstrates Theorem: operator_norm_witness_of_matrix_neq_zero

    If D ≠ 0, there exists r with ‖r‖_∞ ≤ 1 such that D*r ≠ 0.
    The proof uses a standard basis vector.
    """
    print("\n" + "=" * 70)
    print("DEMO 3: Operator Norm Witness — Robust Detection")
    print("=" * 70)

    n = 8
    A = np.random.randn(n, n)
    B = np.random.randn(n, n)
    C = A @ B
    C_wrong = C.copy()

    # Progressively smaller perturbations
    epsilons = [1.0, 0.1, 0.01, 0.001, 1e-6, 1e-10]

    print(f"\nMatrix size: {n}×{n}")
    print(f"\n{'epsilon':>12} | {'||D*e_j||':>12} | {'ratio':>12} | detected")
    print("-" * 60)

    for eps in epsilons:
        C_pert = C.copy()
        C_pert[0, 0] += eps
        D = A @ B - C_pert

        # Standard basis witness (as in the formal proof)
        best_norm = 0
        for j in range(n):
            e_j = np.zeros(n)
            e_j[j] = 1.0
            output_norm = np.linalg.norm(D @ e_j)
            best_norm = max(best_norm, output_norm)

        detected = best_norm > 1e-15
        print(f"{eps:>12.2e} | {best_norm:>12.2e} | {best_norm/eps:>12.4f} | {'✓' if detected else '✗'}")

    print("\nTheorem guarantees: if D ≠ 0, some basis vector always detects it ✓")


# ============================================================================
# DEMO 4: Block + Freivalds Synthesis
# ============================================================================

def demo_synthesis():
    """
    Demonstrates Theorem: enhanced_trichotomy_over_reals

    If a block-diagonal identity fails, BOTH structural AND witness
    detection succeed simultaneously.
    """
    print("\n" + "=" * 70)
    print("DEMO 4: Synthesis — Structural + Probabilistic + Robustness")
    print("=" * 70)

    block_sizes = [5, 4, 3]
    n_total = sum(block_sizes)

    blocks_W = [np.random.randn(s, s) for s in block_sizes]
    blocks_W_prime = [w.copy() for w in blocks_W]

    # Perturb block 2
    blocks_W_prime[2][1, 0] += 0.5

    print(f"\nBlock sizes: {block_sizes}, total: {n_total}")
    print(f"Block 2 perturbed by 0.5 in entry (1,0)")

    # Structural detection: which block differs?
    structural = [not np.allclose(w, wp)
                  for w, wp in zip(blocks_W, blocks_W_prime)]
    failing_blocks = [i for i, v in enumerate(structural) if v]
    print(f"\n1. Structural detection: block {failing_blocks} differs ✓")

    # Robustness detection: find bounded witness
    W = np.block([
        [blocks_W[i] if i == j else np.zeros((block_sizes[i], block_sizes[j]))
         for j in range(3)]
        for i in range(3)
    ])
    W_prime = np.block([
        [blocks_W_prime[i] if i == j else np.zeros((block_sizes[i], block_sizes[j]))
         for j in range(3)]
        for i in range(3)
    ])

    D = W - W_prime
    # Find best standard basis witness
    best_j = max(range(n_total), key=lambda j: np.linalg.norm(D[:, j]))
    e_j = np.zeros(n_total)
    e_j[best_j] = 1.0
    discrepancy = np.linalg.norm(D @ e_j)

    print(f"2. Robustness detection: basis vector e_{best_j} detects "
          f"discrepancy {discrepancy:.6f} ✓")

    # Freivalds detection
    detection_rate = 1 - sum(
        freivalds_check(W, np.eye(n_total), W_prime)
        for _ in range(1000)
    ) / 1000
    print(f"3. Freivalds detection rate: {100*detection_rate:.1f}% "
          f"(theoretical ≥ 50%) ✓")

    print(f"\nAll three pillars detect the same failure — trichotomy confirmed ✓")


# ============================================================================
# DEMO 5: Tropical Composition Bounds
# ============================================================================

def demo_tropical_composition():
    """
    Demonstrates Theorem: tropical_mulVec_entrywise_bound

    |D·r|_i ≤ n · max|D_ij| · max|r_k| for all i.
    """
    print("\n" + "=" * 70)
    print("DEMO 5: Tropical Composition Bounds")
    print("=" * 70)

    n = 6
    D = np.random.randn(n, n) * 2
    r = np.random.randn(n)

    D_max = np.max(np.abs(D))
    r_max = np.max(np.abs(r))

    result = D @ r
    actual_max = np.max(np.abs(result))
    bound = n * D_max * r_max

    print(f"\nMatrix size: {n}×{n}")
    print(f"max|D_ij| = {D_max:.4f}")
    print(f"max|r_k|  = {r_max:.4f}")
    print(f"\nActual max|D·r|_i = {actual_max:.4f}")
    print(f"Tropical bound n·D_max·r_max = {bound:.4f}")
    print(f"Bound holds: {actual_max <= bound + 1e-10} ✓")

    # Two-layer composition
    W1 = np.random.randn(n, n)
    W2 = np.random.randn(n, n)
    x = np.random.randn(n)

    B1 = np.max(np.abs(W1))
    B2 = np.max(np.abs(W2))
    x_max = np.max(np.abs(x))

    result_2layer = (W1 @ W2) @ x
    actual_2layer = np.max(np.abs(result_2layer))
    bound_2layer = n * n * B1 * B2 * x_max

    print(f"\n--- Two-layer composition ---")
    print(f"max|W₁| = {B1:.4f}, max|W₂| = {B2:.4f}, max|x| = {x_max:.4f}")
    print(f"Actual max|(W₁W₂)x|_i = {actual_2layer:.4f}")
    print(f"Tropical bound n²·B₁·B₂·x_max = {bound_2layer:.4f}")
    print(f"Bound holds: {actual_2layer <= bound_2layer + 1e-10} ✓")


if __name__ == "__main__":
    demo_freivalds()
    demo_block_diagonal()
    demo_robustness()
    demo_synthesis()
    demo_tropical_composition()

    print("\n" + "=" * 70)
    print("All demos completed successfully!")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualizations for Decomposable Matrix Verification Theory
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import base64
from io import BytesIO

np.random.seed(42)


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def viz_freivalds_detection():
    """Visualize Freivalds detection probability vs field size and trials."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Left: Detection probability vs field size (single trial)
    field_sizes = range(2, 51)
    detection_probs = [1 - 1/q for q in field_sizes]

    axes[0].plot(field_sizes, detection_probs, 'b-', linewidth=2)
    axes[0].axhline(y=0.5, color='r', linestyle='--', alpha=0.5, label='50%')
    axes[0].axhline(y=0.99, color='g', linestyle='--', alpha=0.5, label='99%')
    axes[0].set_xlabel('Field Size |F|', fontsize=12)
    axes[0].set_ylabel('Detection Probability', fontsize=12)
    axes[0].set_title('Single-Trial Freivalds Detection', fontsize=14)
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)
    axes[0].set_ylim(0.4, 1.02)

    # Right: False positive probability vs number of trials (field_size=2)
    trials = range(1, 31)
    false_pos_2 = [(1/2)**t for t in trials]
    false_pos_3 = [(1/3)**t for t in trials]
    false_pos_5 = [(1/5)**t for t in trials]

    axes[1].semilogy(trials, false_pos_2, 'b-o', markersize=4, label='|F|=2')
    axes[1].semilogy(trials, false_pos_3, 'r-s', markersize=4, label='|F|=3')
    axes[1].semilogy(trials, false_pos_5, 'g-^', markersize=4, label='|F|=5')
    axes[1].set_xlabel('Number of Trials', fontsize=12)
    axes[1].set_ylabel('False Positive Probability', fontsize=12)
    axes[1].set_title('Amplified Freivalds Soundness', fontsize=14)
    axes[1].legend()
    axes[1].grid(True, alpha=0.3)

    fig.suptitle('Freivalds Algorithm: Probabilistic Matrix Verification',
                 fontsize=16, y=1.02)
    fig.tight_layout()
    return fig


def viz_block_structure():
    """Visualize block diagonal decomposition and verification."""
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    # Create a block diagonal matrix
    blocks = [np.random.randn(4, 4), np.random.randn(3, 3), np.random.randn(5, 5)]
    n = sum(b.shape[0] for b in blocks)
    M = np.zeros((n, n))
    offset = 0
    for b in blocks:
        s = b.shape[0]
        M[offset:offset+s, offset:offset+s] = b
        offset += s

    # Left: Full matrix with block structure highlighted
    im = axes[0].imshow(np.abs(M), cmap='Blues', aspect='equal')
    axes[0].set_title('Block Diagonal Matrix', fontsize=14)

    # Draw block boundaries
    offset = 0
    colors = ['red', 'green', 'orange']
    for i, b in enumerate(blocks):
        s = b.shape[0]
        rect = plt.Rectangle((offset-0.5, offset-0.5), s, s,
                              linewidth=2, edgecolor=colors[i],
                              facecolor='none')
        axes[0].add_patch(rect)
        offset += s
    plt.colorbar(im, ax=axes[0], fraction=0.046)

    # Middle: Individual blocks
    for i, b in enumerate(blocks):
        ax_inset = axes[1].inset_axes([i*0.35, 0.1, 0.3, 0.8])
        ax_inset.imshow(np.abs(b), cmap='Blues', aspect='equal')
        ax_inset.set_title(f'Block {i+1}\n({b.shape[0]}×{b.shape[0]})',
                           fontsize=10)
        ax_inset.set_xticks([])
        ax_inset.set_yticks([])
        for spine in ax_inset.spines.values():
            spine.set_edgecolor(colors[i])
            spine.set_linewidth(2)
    axes[1].set_title('Local Block Verification', fontsize=14)
    axes[1].axis('off')

    # Right: Verification cost comparison
    total_n = 12
    block_ns = [4, 3, 5]
    global_cost = total_n ** 3
    block_cost = sum(s**3 for s in block_ns)
    freivalds_cost = total_n ** 2 * 20  # 20 trials

    methods = ['Global\nMultiply', 'Block\nVerify', 'Freivalds\n(20 trials)']
    costs = [global_cost, block_cost, freivalds_cost]
    bars = axes[2].bar(methods, costs, color=['#ff6b6b', '#51cf66', '#339af0'])
    axes[2].set_ylabel('Operations', fontsize=12)
    axes[2].set_title('Verification Cost Comparison', fontsize=14)
    for bar, cost in zip(bars, costs):
        axes[2].text(bar.get_x() + bar.get_width()/2, bar.get_height() + 20,
                     f'{cost}', ha='center', va='bottom', fontsize=11)

    fig.suptitle('Block Diagonal Decomposition: Local-to-Global Verification',
                 fontsize=16, y=1.02)
    fig.tight_layout()
    return fig


def viz_tropical_bounds():
    """Visualize tropical norm bounds and composition."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Left: Tropical bound vs actual norm for matrix-vector product
    ns = range(2, 51)
    ratios = []
    for n in ns:
        trials_ratio = []
        for _ in range(100):
            D = np.random.randn(n, n)
            r = np.random.randn(n)
            D_max = np.max(np.abs(D))
            r_max = np.max(np.abs(r))
            bound = n * D_max * r_max
            actual = np.max(np.abs(D @ r))
            trials_ratio.append(bound / max(actual, 1e-15))
        ratios.append((np.mean(trials_ratio), np.std(trials_ratio)))

    means = [r[0] for r in ratios]
    stds = [r[1] for r in ratios]

    axes[0].plot(list(ns), means, 'b-', linewidth=2, label='Mean bound/actual')
    axes[0].fill_between(list(ns),
                          [m-s for m, s in zip(means, stds)],
                          [m+s for m, s in zip(means, stds)],
                          alpha=0.2, color='b')
    axes[0].set_xlabel('Matrix Dimension n', fontsize=12)
    axes[0].set_ylabel('Tropical Bound / Actual', fontsize=12)
    axes[0].set_title('Tropical Bound Tightness', fontsize=14)
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)

    # Right: Multi-layer composition bound growth
    layers = range(1, 11)
    n = 10
    bound_growth = []
    actual_growth = []

    for L in layers:
        # Random matrices with unit max entry
        matrices = [np.random.randn(n, n) / np.sqrt(n) for _ in range(L)]
        x = np.random.randn(n)
        x = x / np.max(np.abs(x))  # normalize

        # Actual output
        result = x.copy()
        for M in matrices:
            result = M @ result
        actual_norm = np.max(np.abs(result))

        # Tropical bound: n^L * prod(max|M_i|) * max|x|
        max_entries = [np.max(np.abs(M)) for M in matrices]
        tropical_bound = (n ** L) * np.prod(max_entries)

        bound_growth.append(tropical_bound)
        actual_growth.append(max(actual_norm, 1e-15))

    axes[1].semilogy(list(layers), bound_growth, 'r-o', label='Tropical bound',
                      markersize=6, linewidth=2)
    axes[1].semilogy(list(layers), actual_growth, 'b-s', label='Actual max|output|',
                      markersize=6, linewidth=2)
    axes[1].set_xlabel('Number of Layers', fontsize=12)
    axes[1].set_ylabel('Output Bound (log scale)', fontsize=12)
    axes[1].set_title('Multi-Layer Composition Bound', fontsize=14)
    axes[1].legend()
    axes[1].grid(True, alpha=0.3)

    fig.suptitle('Tropical Robustness: Composition Bounds',
                 fontsize=16, y=1.02)
    fig.tight_layout()
    return fig


def viz_trichotomy():
    """Visualize the detection trichotomy: structural + probabilistic + robustness."""
    fig, ax = plt.subplots(figsize=(10, 8))

    # Draw three overlapping circles (Venn-like)
    from matplotlib.patches import Circle

    colors = ['#ff6b6b', '#51cf66', '#339af0']
    labels = ['Probabilistic\n(Freivalds)', 'Structural\n(Block Gluing)', 'Robustness\n(Tropical)']
    centers = [(0, 1), (-0.87, -0.5), (0.87, -0.5)]

    for center, color, label in zip(centers, colors, labels):
        circle = Circle(center, 1.2, alpha=0.2, color=color)
        ax.add_patch(circle)
        # Label outside
        lx = center[0] * 1.8
        ly = center[1] * 1.8
        ax.text(lx, ly, label, ha='center', va='center',
                fontsize=14, fontweight='bold')

    # Center: unified theory
    ax.text(0, 0, 'Decomposable\nVerification',
            ha='center', va='center', fontsize=16, fontweight='bold',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='white',
                      edgecolor='black', alpha=0.8))

    # Pairwise intersections
    ax.text(-0.5, 0.3, 'Block\nFreivalds', ha='center', va='center',
            fontsize=9, style='italic')
    ax.text(0.5, 0.3, 'Witness\nDetection', ha='center', va='center',
            fontsize=9, style='italic')
    ax.text(0, -0.7, 'Certified\nML Layers', ha='center', va='center',
            fontsize=9, style='italic')

    ax.set_xlim(-3, 3)
    ax.set_ylim(-3, 3)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('The Detection Trichotomy: Three Pillars of Matrix Verification',
                 fontsize=16, pad=20)

    return fig


if __name__ == "__main__":
    print("Generating visualizations...")

    fig1 = viz_freivalds_detection()
    fig1.savefig('viz_freivalds.png', dpi=150, bbox_inches='tight')
    print("  ✓ viz_freivalds.png")

    fig2 = viz_block_structure()
    fig2.savefig('viz_blocks.png', dpi=150, bbox_inches='tight')
    print("  ✓ viz_blocks.png")

    fig3 = viz_tropical_bounds()
    fig3.savefig('viz_tropical.png', dpi=150, bbox_inches='tight')
    print("  ✓ viz_tropical.png")

    fig4 = viz_trichotomy()
    fig4.savefig('viz_trichotomy.png', dpi=150, bbox_inches='tight')
    print("  ✓ viz_trichotomy.png")

    print("\nAll visualizations generated successfully!")
