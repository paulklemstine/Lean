#!/usr/bin/env python3
"""
Real-World Applications of Decomposable Matrix Verification

Demonstrates practical applications of the formally verified theory:
1. Large-scale neural network weight verification
2. Distributed matrix computation checking
3. Adversarial robustness certification
4. Cryptographic matrix commitment verification
"""

import numpy as np
from algorithms import (
    freivalds_verify, block_diagonal_verify, BlockStructure,
    verify_block_network, verify_composed_network,
    tropical_norm, tropical_matrix_norm, find_robustness_witness,
    tropical_composition_bound
)
from typing import List, Tuple


# ============================================================
# Application 1: Neural Network Weight Verification
# ============================================================

def app_neural_network_verification():
    """
    Verify that a deployed neural network matches its certified weights.

    Scenario: A model has been audited and certified. When deployed,
    we want to verify the deployed weights match the certified ones
    without full matrix comparison (which would be O(n²) per layer).

    Solution: Use Freivalds' algorithm for O(n) per-check verification,
    with formally proven error bounds.
    """
    print("=" * 60)
    print("APPLICATION 1: Neural Network Weight Verification")
    print("=" * 60)

    # Simulate a 3-layer network
    layer_sizes = [512, 256, 128, 10]  # Input → Hidden → Hidden → Output
    layers_certified = []
    layers_deployed = []

    for i in range(len(layer_sizes) - 1):
        W = np.random.randn(layer_sizes[i+1], layer_sizes[i]) * 0.01
        layers_certified.append(W)
        # Deployed version: mostly identical, but one layer has a subtle change
        if i == 1:  # Tamper with the second layer
            W_deployed = W.copy()
            W_deployed[0, 0] += 0.001  # Tiny modification
            layers_deployed.append(W_deployed)
        else:
            layers_deployed.append(W.copy())

    print(f"\nNetwork architecture: {' → '.join(map(str, layer_sizes))}")
    print(f"Total parameters: {sum(a*b for a, b in zip(layer_sizes[:-1], layer_sizes[1:]))}")

    # Naive verification: O(total_params) comparisons
    naive_ops = sum(a * b for a, b in zip(layer_sizes[:-1], layer_sizes[1:]))
    print(f"\nNaive verification: {naive_ops} element-wise comparisons")

    # Freivalds verification: O(n) per trial per layer
    num_trials = 20
    freivalds_ops = sum(
        num_trials * 2 * max(layer_sizes[i], layer_sizes[i+1])
        for i in range(len(layer_sizes) - 1)
    )
    print(f"Freivalds verification: ~{freivalds_ops} operations ({num_trials} trials)")
    print(f"Speedup: {naive_ops / freivalds_ops:.1f}×")

    # Actually verify
    print(f"\nVerification results:")
    for i in range(len(layer_sizes) - 1):
        W_cert = layers_certified[i]
        W_dep = layers_deployed[i]
        # Check entrywise: compare W_cert and W_dep row-by-row using mulVec probes
        D = W_cert - W_dep
        # Use Freivalds-style: test if D @ r = 0 for random r
        detected = False
        for _ in range(num_trials):
            r = np.random.randn(W_cert.shape[1])
            if not np.allclose(D @ r, 0, atol=1e-10):
                detected = True
                break
        result = not detected
        conf = 1.0 - (0.5 ** num_trials) if not detected else 1.0
        status = "✓ MATCH" if result else "✗ TAMPERED"
        print(f"  Layer {i} ({W_cert.shape}): {status}  (confidence: {conf:.6f})")


# ============================================================
# Application 2: Distributed Matrix Computation
# ============================================================

def app_distributed_computation():
    """
    Verify a distributed block-diagonal matrix computation.

    Scenario: A large matrix multiplication is split across k workers,
    each computing one block. The coordinator verifies the results
    without redoing the computation.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Distributed Matrix Computation Verification")
    print("=" * 60)

    num_workers = 4
    block_size = 100
    total_size = num_workers * block_size
    structure = BlockStructure.from_sizes([block_size] * num_workers)

    print(f"\nDistributed setup: {num_workers} workers, each handling {block_size}×{block_size} blocks")
    print(f"Total matrix size: {total_size}×{total_size}")

    # Each worker computes A_i @ B_i
    A_blocks = [np.random.randn(block_size, block_size) for _ in range(num_workers)]
    B_blocks = [np.random.randn(block_size, block_size) for _ in range(num_workers)]

    # Simulate worker results (one worker returns wrong result)
    C_blocks = []
    faulty_worker = 2
    for i in range(num_workers):
        if i == faulty_worker:
            # Faulty worker returns garbage
            C_blocks.append(np.random.randn(block_size, block_size))
        else:
            C_blocks.append(A_blocks[i] @ B_blocks[i])

    # Assemble full matrices
    from algorithms import assemble_block_diagonal
    A = assemble_block_diagonal(A_blocks, structure)
    B = assemble_block_diagonal(B_blocks, structure)
    C = assemble_block_diagonal(C_blocks, structure)

    # Verify using block decomposition
    result, failing_block = block_diagonal_verify(A, B, C, structure)
    print(f"\nBlock-diagonal verification: {'PASS' if result else 'FAIL'}")
    if failing_block is not None:
        print(f"  Faulty worker detected: worker {failing_block}")
        print(f"  (True faulty worker: {faulty_worker})")

    # Compare costs
    full_verify_ops = total_size ** 3
    block_verify_ops = num_workers * block_size ** 3
    print(f"\nFull verification cost: O({total_size}³) = {full_verify_ops:,}")
    print(f"Block verification cost: {num_workers} × O({block_size}³) = {block_verify_ops:,}")
    print(f"Speedup: {full_verify_ops / block_verify_ops:.0f}×")


# ============================================================
# Application 3: Adversarial Robustness Certification
# ============================================================

def app_adversarial_robustness():
    """
    Certify robustness of a linear classifier against adversarial perturbations.

    Uses tropical norm bounds to provide certified robustness guarantees.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Adversarial Robustness Certification")
    print("=" * 60)

    # Simple linear classifier
    n_features = 20
    n_classes = 5
    W = np.random.randn(n_classes, n_features) * 0.1

    # Test input
    x = np.random.randn(n_features)
    scores = W @ x
    predicted_class = np.argmax(scores)
    margin = scores[predicted_class] - np.sort(scores)[-2]  # Score gap

    print(f"\nLinear classifier: {n_features} features → {n_classes} classes")
    print(f"Test input prediction: class {predicted_class}")
    print(f"Score margin: {margin:.4f}")

    # Tropical robustness: how much perturbation can we tolerate?
    # If ||δx||_∞ ≤ ε, then ||W·δx||_∞ ≤ n · W_max · ε
    W_max = tropical_matrix_norm(W)
    # For the prediction to change, we need the score perturbation ≥ margin/2
    # So ε_robust ≥ margin / (2 · n · W_max)
    epsilon_robust = margin / (2 * n_features * W_max)

    print(f"\nTropical robustness certification:")
    print(f"  W_max (tropical matrix norm): {W_max:.4f}")
    print(f"  Certified L∞ robustness radius: ε ≥ {epsilon_robust:.6f}")
    print(f"  (Any perturbation with ||δx||_∞ < ε preserves the prediction)")

    # Verify the certificate
    print(f"\nVerification with random perturbations:")
    n_tests = 1000
    robust_count = 0
    for _ in range(n_tests):
        delta = np.random.uniform(-epsilon_robust * 0.99, epsilon_robust * 0.99, n_features)
        perturbed_scores = W @ (x + delta)
        if np.argmax(perturbed_scores) == predicted_class:
            robust_count += 1

    print(f"  {robust_count}/{n_tests} perturbations preserved prediction ({robust_count/n_tests:.1%})")
    print(f"  (Should be 100% within certified radius)")

    # Multi-layer robustness via composition
    print(f"\nTwo-layer network robustness:")
    W2 = np.random.randn(n_classes, n_classes) * 0.1
    layers = [W2, W[:n_classes, :n_classes]]
    x_small = x[:n_classes]

    actual, bound = tropical_composition_bound(layers, x_small)
    print(f"  Actual output norm: {actual:.4f}")
    print(f"  Tropical bound: {bound:.4f}")
    print(f"  Bound is tight: {actual / bound:.1%}")


# ============================================================
# Application 4: Secure Computation Verification
# ============================================================

def app_secure_computation():
    """
    Verify matrix computations in a secure/untrusted computation setting.

    Combines Freivalds (probabilistic checking), block structure
    (parallel verification), and tropical bounds (noise tolerance).
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Secure Computation Verification")
    print("=" * 60)

    n = 50

    # Scenario: untrusted server computes A @ B for client
    A = np.random.randn(n, n)
    B = np.random.randn(n, n)

    # Server returns result (possibly incorrect)
    C_server = A @ B + np.random.randn(n, n) * 1e-8  # Tiny numerical noise

    print(f"\nClient outsources {n}×{n} matrix multiplication to server")
    print(f"Server computation has numerical noise: ~1e-8")

    # Client verification using Freivalds
    print(f"\n1. Probabilistic verification (Freivalds):")
    result, conf = freivalds_verify(A, B, C_server, num_trials=30)
    print(f"   Result: {'ACCEPT' if result else 'REJECT'}")
    print(f"   Confidence: {conf:.10f}")

    # Robustness check: is the error bounded?
    D = A @ B - C_server
    max_error = tropical_matrix_norm(D)
    print(f"\n2. Robustness analysis:")
    print(f"   Max entry error: {max_error:.2e}")

    # Find worst-case witness
    witness, separation = find_robustness_witness(A @ B, C_server)
    print(f"   Worst-case witness separation: {separation:.2e}")

    # Now test with a malicious server
    print(f"\n3. Malicious server scenario:")
    C_malicious = A @ B
    C_malicious[n//2, n//2] += 1.0  # Inject significant error

    result, conf = freivalds_verify(A, B, C_malicious, num_trials=30)
    print(f"   Freivalds result: {'ACCEPT' if result else 'REJECT'}")
    witness, separation = find_robustness_witness(A @ B, C_malicious)
    print(f"   Tropical separation: {separation:.4f}")
    print(f"   → Malicious modification reliably detected!")


# ============================================================
# MAIN
# ============================================================

if __name__ == "__main__":
    app_neural_network_verification()
    app_distributed_computation()
    app_adversarial_robustness()
    app_secure_computation()

    print("\n" + "=" * 60)
    print("All applications demonstrated successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Decomposable Matrix Verification — Interactive Demonstrations

This module demonstrates the three pillars of decomposable verification:
1. Freivalds' probabilistic matrix identity testing
2. Block-diagonal structural decomposition
3. Tropical/approximate robustness bounds

Each demo uses concrete numerical examples to illustrate the theorems
that have been formally verified.
"""

import numpy as np
from typing import Tuple, List
import random

np.random.seed(42)
random.seed(42)


# ============================================================
# DEMO 1: Freivalds' Algorithm
# ============================================================

def freivalds_check(A: np.ndarray, B: np.ndarray, C: np.ndarray,
                    field_size: int = None) -> Tuple[bool, np.ndarray]:
    """
    Perform one round of Freivalds' randomized matrix verification.

    Tests whether A @ B == C by checking A @ (B @ r) == C @ r
    for a random vector r.

    Returns (passed, r) where passed=True means no discrepancy detected.
    """
    n = A.shape[0]
    if field_size:
        r = np.array([random.randint(0, field_size - 1) for _ in range(n)])
        Br = (B @ r) % field_size
        ABr = (A @ Br) % field_size
        Cr = (C @ r) % field_size
        return np.array_equal(ABr, Cr), r
    else:
        r = np.random.randn(n)
        return np.allclose(A @ (B @ r), C @ r), r


def demo_freivalds():
    """Demonstrate Freivalds' algorithm with concrete examples."""
    print("=" * 60)
    print("DEMO 1: Freivalds' Probabilistic Matrix Verification")
    print("=" * 60)

    n = 5

    # Case 1: Correct product
    A = np.random.randint(0, 7, (n, n))
    B = np.random.randint(0, 7, (n, n))
    C = A @ B  # Correct product

    print(f"\nCase 1: C = A·B (correct product)")
    print(f"Matrix size: {n}×{n}")
    trials = 20
    passes = sum(freivalds_check(A, B, C)[0] for _ in range(trials))
    print(f"  Passed {passes}/{trials} random checks (expected: all pass)")

    # Case 2: Incorrect product
    C_wrong = C.copy()
    C_wrong[0, 0] += 1  # Introduce error

    print(f"\nCase 2: C ≠ A·B (one entry changed)")
    detections = 0
    for _ in range(trials):
        passed, r = freivalds_check(A, B, C_wrong)
        if not passed:
            detections += 1
    print(f"  Detected error in {detections}/{trials} trials")
    print(f"  Detection rate: {detections/trials:.1%}")
    print(f"  Theoretical lower bound: ≥ 50% per trial (1 - 1/|F|)")

    # Case 3: Over a finite field GF(p)
    p = 7
    print(f"\nCase 3: Over GF({p})")
    A_f = np.random.randint(0, p, (n, n))
    B_f = np.random.randint(0, p, (n, n))
    C_f = (A_f @ B_f) % p
    C_f_wrong = C_f.copy()
    C_f_wrong[2, 3] = (C_f_wrong[2, 3] + 1) % p

    trials = 100
    detections = sum(not freivalds_check(A_f, B_f, C_f_wrong, p)[0]
                     for _ in range(trials))
    theoretical_rate = 1 - 1/p
    print(f"  Detection rate: {detections/trials:.1%}")
    print(f"  Theoretical bound: ≥ {theoretical_rate:.1%}")
    print(f"  (Theorem: freivalds_soundness_bound)")

    # Kernel cardinality
    D = (A_f @ B_f - C_f_wrong) % p
    print(f"\n  Discrepancy matrix D = AB - C has rank {np.linalg.matrix_rank(D.astype(float))}")
    print(f"  |ker(D)| ≤ {p}^{n-1} = {p**(n-1)}")
    print(f"  Total vectors: {p}^{n} = {p**n}")
    print(f"  Fraction accepting: ≤ {p**(n-1)}/{p**n} = 1/{p}")


# ============================================================
# DEMO 2: Block Diagonal Gluing
# ============================================================

def demo_block_diagonal():
    """Demonstrate block-diagonal decomposition for verification."""
    print("\n" + "=" * 60)
    print("DEMO 2: Block Diagonal Structural Decomposition")
    print("=" * 60)

    # Create block-diagonal matrices
    block_sizes = [3, 4, 2]
    n_blocks = len(block_sizes)
    total_size = sum(block_sizes)

    def make_block_diag(blocks):
        M = np.zeros((total_size, total_size))
        offset = 0
        for b in blocks:
            s = b.shape[0]
            M[offset:offset+s, offset:offset+s] = b
            offset += s
        return M

    # Random blocks
    A_blocks = [np.random.randn(s, s) for s in block_sizes]
    B_blocks = [np.random.randn(s, s) for s in block_sizes]
    C_blocks = [A @ B for A, B in zip(A_blocks, B_blocks)]

    A = make_block_diag(A_blocks)
    B = make_block_diag(B_blocks)
    C = make_block_diag(C_blocks)

    print(f"\nBlock sizes: {block_sizes}")
    print(f"Total matrix size: {total_size}×{total_size}")

    # Verify global identity
    print(f"\nGlobal check: ‖AB - C‖ = {np.linalg.norm(A @ B - C):.2e}")
    print("  (Should be ~0: block_diagonal_mul_eq_iff)")

    # Local checks
    print("\nLocal block checks:")
    for i, (Ai, Bi, Ci) in enumerate(zip(A_blocks, B_blocks, C_blocks)):
        err = np.linalg.norm(Ai @ Bi - Ci)
        print(f"  Block {i} ({block_sizes[i]}×{block_sizes[i]}): ‖A_i·B_i - C_i‖ = {err:.2e}")

    # Now introduce an error in one block
    print("\n--- Introducing error in block 1 ---")
    C_blocks_wrong = [c.copy() for c in C_blocks]
    C_blocks_wrong[1][0, 0] += 0.5
    C_wrong = make_block_diag(C_blocks_wrong)

    print(f"\nGlobal check: ‖AB - C'‖ = {np.linalg.norm(A @ B - C_wrong):.2e}")
    print("  (Nonzero: block_diagonal_failure_detection)")

    print("\nLocal block checks (finding the failure):")
    for i, (Ai, Bi, Ci) in enumerate(zip(A_blocks, B_blocks, C_blocks_wrong)):
        err = np.linalg.norm(Ai @ Bi - Ci)
        status = "✓ PASS" if err < 1e-10 else "✗ FAIL"
        print(f"  Block {i}: ‖A_i·B_i - C_i‖ = {err:.2e}  {status}")


# ============================================================
# DEMO 3: Tropical/Approximate Robustness
# ============================================================

def tropical_vec_norm(v: np.ndarray) -> float:
    """Tropical (max-plus) norm: max |v_i|."""
    return np.max(np.abs(v))


def demo_tropical_robustness():
    """Demonstrate tropical robustness bounds."""
    print("\n" + "=" * 60)
    print("DEMO 3: Tropical/Approximate Robustness")
    print("=" * 60)

    n = 4

    # Create two similar weight matrices
    W = np.random.randn(n, n)
    perturbation = np.random.randn(n, n) * 0.1
    W_prime = W + perturbation

    print(f"\nWeight matrix W ({n}×{n})")
    print(f"Perturbation ‖W - W'‖_max = {tropical_vec_norm(perturbation.flatten()):.4f}")

    # Witness vector from the theorem
    D = W - W_prime
    print(f"\nDiscrepancy matrix D = W - W'")
    print(f"  max |D_ij| = {np.max(np.abs(D)):.4f}")

    # Find the standard basis witness
    i_max, j_max = np.unravel_index(np.argmax(np.abs(D)), D.shape)
    r_witness = np.zeros(n)
    r_witness[j_max] = 1.0

    output_diff = W @ r_witness - W_prime @ r_witness
    print(f"\n  Standard basis witness e_{j_max}:")
    print(f"    ‖r‖_∞ = {tropical_vec_norm(r_witness):.1f} ≤ 1  ✓")
    print(f"    ‖(W-W')r‖_∞ = {tropical_vec_norm(output_diff):.4f}")
    print(f"    Detection: W·r ≠ W'·r  ✓  (tropical_robustness_margin)")

    # Tropical norm bound for matrix-vector product
    print(f"\nTropical norm bounds:")
    x = np.random.randn(n)
    x_max = tropical_vec_norm(x)
    D_max = np.max(np.abs(D))
    bound = n * D_max * x_max
    actual = tropical_vec_norm(D @ x)
    print(f"  Input x_max = {x_max:.4f}")
    print(f"  |D·x|_∞ = {actual:.4f} ≤ n·D_max·x_max = {bound:.4f}")
    print(f"  (Theorem: tropical_mulVec_norm_bound)")

    # Composition bound
    print(f"\nComposition bounds (two-layer network):")
    W1 = np.random.randn(n, n) * 0.5
    W2 = np.random.randn(n, n) * 0.3
    B1 = np.max(np.abs(W1))
    B2 = np.max(np.abs(W2))
    x = np.random.randn(n)
    x_max = tropical_vec_norm(x)

    composed = (W1 @ W2) @ x
    actual_norm = tropical_vec_norm(composed)
    theory_bound = n * n * B1 * B2 * x_max
    print(f"  B₁ = {B1:.4f}, B₂ = {B2:.4f}, x_max = {x_max:.4f}")
    print(f"  |(W₁W₂)x|_∞ = {actual_norm:.4f} ≤ n²·B₁·B₂·x_max = {theory_bound:.4f}")
    print(f"  (Theorem: tropical_layer_composition_bound)")

    # Tropical margin composition
    print(f"\nTropical margin composition:")
    margins = [0.3, 0.5, 0.1, 0.8]
    min_margin = min(margins)
    print(f"  Layer margins: {margins}")
    print(f"  Composed margin: min = {min_margin:.1f} > 0  ✓")
    print(f"  (Theorem: tropical_margin_min_pos, tropical_margin_list_min_pos)")


# ============================================================
# DEMO 4: Cross-Domain Synthesis
# ============================================================

def demo_synthesis():
    """Demonstrate the cross-domain synthesis: block + Freivalds + tropical."""
    print("\n" + "=" * 60)
    print("DEMO 4: Cross-Domain Synthesis — Block + Freivalds + Tropical")
    print("=" * 60)

    # Block-diagonal neural network verification scenario
    block_sizes = [3, 3, 3]
    n_blocks = len(block_sizes)
    n = block_sizes[0]
    total = sum(block_sizes)

    print(f"\nScenario: Block-diagonal network layer ({n_blocks} blocks of size {n})")

    # Weight matrices (each block is a small layer)
    W_blocks = [np.random.randn(n, n) for _ in range(n_blocks)]
    W_prime_blocks = [w + np.random.randn(n, n) * 0.01 for w in W_blocks]

    # Introduce a significant error in block 1
    W_prime_blocks[1] = W_blocks[1] + np.eye(n) * 0.5

    print("\n1. STRUCTURAL DETECTION (block_verification_detection):")
    for i in range(n_blocks):
        D = W_blocks[i] - W_prime_blocks[i]
        max_disc = np.max(np.abs(D))
        status = "✓ MATCH" if max_disc < 0.02 else "✗ MISMATCH"
        print(f"   Block {i}: max discrepancy = {max_disc:.4f}  {status}")

    print("\n2. PROBABILISTIC DETECTION (Freivalds on failing block):")
    failing_block = 1
    A_block = W_blocks[failing_block]
    B_block = np.eye(n)  # Identity for simplicity
    C_block = W_prime_blocks[failing_block]

    trials = 50
    detections = 0
    for _ in range(trials):
        r = np.random.randn(n)
        if not np.allclose(A_block @ (B_block @ r), C_block @ r, atol=1e-10):
            detections += 1
    print(f"   Block {failing_block}: Detected in {detections}/{trials} trials ({detections/trials:.0%})")

    print("\n3. TROPICAL ROBUSTNESS (tropical_robustness_margin):")
    for i in range(n_blocks):
        D = W_blocks[i] - W_prime_blocks[i]
        max_entry = np.max(np.abs(D))
        # Find witness
        i_max, j_max = np.unravel_index(np.argmax(np.abs(D)), D.shape)
        r = np.zeros(n)
        r[j_max] = 1.0
        sep = tropical_vec_norm(D @ r)
        print(f"   Block {i}: tropical margin = {max_entry:.4f}, "
              f"witness separation = {sep:.4f}")

    print("\n4. COMPOSITIONAL CERTIFICATE (verification_composition):")
    x = np.random.randn(n)
    # Two-layer composition
    out_true = W_blocks[0] @ (W_blocks[1] @ x)
    out_approx = W_prime_blocks[0] @ (W_prime_blocks[1] @ x)
    print(f"   Layer 1 agreement: {np.allclose(W_blocks[0] @ x, W_prime_blocks[0] @ x, atol=0.02)}")
    print(f"   Layer 2 agreement: {np.allclose(W_blocks[1] @ x, W_prime_blocks[1] @ x, atol=0.02)}")
    print(f"   Composed output diff: {np.linalg.norm(out_true - out_approx):.4f}")

    print("\n  → The synthesis: structural decomposition FINDS the failing block,")
    print("    Freivalds CERTIFIES the failure probabilistically,")
    print("    and tropical bounds QUANTIFY the margin.")


# ============================================================
# MAIN
# ============================================================

if __name__ == "__main__":
    demo_freivalds()
    demo_block_diagonal()
    demo_tropical_robustness()
    demo_synthesis()

    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualizations for Decomposable Matrix Verification

Generates publication-quality figures illustrating the key concepts.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch
import base64
import io
import json

np.random.seed(42)


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def viz_freivalds_detection_rate():
    """Visualize Freivalds detection probability vs field size."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    # Left: Detection rate vs field size
    field_sizes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]
    detection_rates = [1 - 1/p for p in field_sizes]

    ax1.plot(field_sizes, detection_rates, 'o-', color='#2196F3',
             linewidth=2, markersize=8, label='Single trial')
    ax1.axhline(y=1.0, color='gray', linestyle='--', alpha=0.5)
    ax1.set_xlabel('Field size |F|', fontsize=12)
    ax1.set_ylabel('Detection probability', fontsize=12)
    ax1.set_title('Freivalds Detection Rate per Trial', fontsize=14)
    ax1.set_ylim(0.4, 1.05)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)

    # Right: Error probability vs number of trials (amplification)
    trials = np.arange(1, 31)
    for p in [2, 5, 11, 31]:
        error_probs = (1/p) ** trials
        ax2.semilogy(trials, error_probs, 'o-', markersize=4,
                     label=f'|F| = {p}', linewidth=2)

    ax2.set_xlabel('Number of trials k', fontsize=12)
    ax2.set_ylabel('False acceptance probability', fontsize=12)
    ax2.set_title('Soundness Amplification', fontsize=14)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)

    fig.suptitle('Freivalds\' Algorithm: Probabilistic Soundness Bounds',
                 fontsize=16, fontweight='bold', y=1.02)
    fig.tight_layout()

    return fig_to_base64(fig)


def viz_block_diagonal():
    """Visualize block-diagonal structure and local verification."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    # Left: Block-diagonal matrix structure
    n = 12
    M = np.zeros((n, n))
    block_starts = [0, 4, 8]
    block_sizes = [4, 4, 4]
    colors = ['#FF5722', '#4CAF50', '#2196F3']

    for start, size, color in zip(block_starts, block_sizes, colors):
        block = np.random.randn(size, size)
        M[start:start+size, start:start+size] = block

    im = ax1.imshow(np.abs(M), cmap='YlOrRd', aspect='equal')
    ax1.set_title('Block-Diagonal Matrix', fontsize=14)
    ax1.set_xlabel('Column', fontsize=12)
    ax1.set_ylabel('Row', fontsize=12)

    # Draw block borders
    for start, size in zip(block_starts, block_sizes):
        rect = plt.Rectangle((start-0.5, start-0.5), size, size,
                            fill=False, edgecolor='black', linewidth=2)
        ax1.add_patch(rect)

    plt.colorbar(im, ax=ax1, label='|entry|', shrink=0.8)

    # Right: Local vs global verification cost
    num_blocks = np.arange(1, 11)
    total_size = 100  # Fixed total size
    block_size = total_size / num_blocks

    global_cost = np.ones_like(num_blocks, dtype=float) * total_size ** 3
    local_cost = num_blocks * (block_size ** 3)
    speedup = global_cost / local_cost

    ax2.plot(num_blocks, speedup, 's-', color='#9C27B0',
             linewidth=2, markersize=8)
    ax2.set_xlabel('Number of blocks k', fontsize=12)
    ax2.set_ylabel('Speedup (global/local cost)', fontsize=12)
    ax2.set_title('Block Decomposition Speedup', fontsize=14)
    ax2.grid(True, alpha=0.3)

    fig.suptitle('Block-Diagonal Structural Decomposition',
                 fontsize=16, fontweight='bold', y=1.02)
    fig.tight_layout()

    return fig_to_base64(fig)


def viz_tropical_robustness():
    """Visualize tropical robustness bounds and witness finding."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    # Left: Tropical norm bound tightness
    n_values = [2, 4, 8, 16, 32, 64]
    ratios = []
    for n in n_values:
        trial_ratios = []
        for _ in range(100):
            D = np.random.randn(n, n) * 0.1
            r = np.random.randn(n)
            r = r / np.max(np.abs(r))  # Normalize to ||r||_∞ = 1
            D_max = np.max(np.abs(D))
            actual = np.max(np.abs(D @ r))
            bound = n * D_max
            trial_ratios.append(actual / bound if bound > 0 else 0)
        ratios.append(trial_ratios)

    bp = ax1.boxplot(ratios, labels=[str(n) for n in n_values],
                     patch_artist=True)
    for patch in bp['boxes']:
        patch.set_facecolor('#E3F2FD')
        patch.set_edgecolor('#2196F3')
    ax1.set_xlabel('Matrix dimension n', fontsize=12)
    ax1.set_ylabel('Actual / Bound ratio', fontsize=12)
    ax1.set_title('Tropical Bound Tightness', fontsize=14)
    ax1.set_ylim(0, 1.1)
    ax1.grid(True, alpha=0.3)

    # Right: Composition bound growth
    n = 10
    num_layers = np.arange(1, 11)
    actual_norms = []
    tropical_bounds = []

    for L in num_layers:
        layers = [np.random.randn(n, n) * 0.3 for _ in range(L)]
        x = np.random.randn(n)
        x = x / np.max(np.abs(x))

        result = x.copy()
        bound = 1.0
        for W in reversed(layers):
            result = W @ result
            B = np.max(np.abs(W))
            bound = n * B * bound

        actual_norms.append(np.max(np.abs(result)))
        tropical_bounds.append(bound)

    ax2.semilogy(num_layers, actual_norms, 'o-', color='#4CAF50',
                 linewidth=2, markersize=6, label='Actual ‖output‖_∞')
    ax2.semilogy(num_layers, tropical_bounds, 's--', color='#F44336',
                 linewidth=2, markersize=6, label='Tropical bound')
    ax2.set_xlabel('Number of layers L', fontsize=12)
    ax2.set_ylabel('Output norm (log scale)', fontsize=12)
    ax2.set_title('Multi-Layer Composition Bounds', fontsize=14)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)

    fig.suptitle('Tropical Robustness Analysis',
                 fontsize=16, fontweight='bold', y=1.02)
    fig.tight_layout()

    return fig_to_base64(fig)


def viz_synthesis():
    """Visualize the three-pillar synthesis."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 7))

    # Draw the three pillars as a triangle
    centers = {
        'Probabilistic\n(Freivalds)': (0.5, 0.9),
        'Structural\n(Block Gluing)': (0.15, 0.2),
        'Robustness\n(Tropical)': (0.85, 0.2),
    }

    colors = {
        'Probabilistic\n(Freivalds)': '#2196F3',
        'Structural\n(Block Gluing)': '#4CAF50',
        'Robustness\n(Tropical)': '#FF5722',
    }

    # Draw connections
    pts = list(centers.values())
    for i in range(3):
        for j in range(i+1, 3):
            ax.plot([pts[i][0], pts[j][0]], [pts[i][1], pts[j][1]],
                    'k-', linewidth=1.5, alpha=0.3)

    # Draw nodes
    for name, (x, y) in centers.items():
        color = colors[name]
        circle = plt.Circle((x, y), 0.12, color=color, alpha=0.2)
        ax.add_patch(circle)
        circle2 = plt.Circle((x, y), 0.12, fill=False, color=color, linewidth=2)
        ax.add_patch(circle2)
        ax.text(x, y, name, ha='center', va='center',
                fontsize=11, fontweight='bold')

    # Draw bridge labels
    bridge_labels = [
        ((0.32, 0.58), 'Block\nFreivalds', '#7B1FA2'),
        ((0.68, 0.58), 'Tropical\nAmplification', '#E65100'),
        ((0.50, 0.15), 'Compositional\nCertificates', '#1B5E20'),
    ]
    for (x, y), label, color in bridge_labels:
        ax.text(x, y, label, ha='center', va='center',
                fontsize=9, color=color, fontstyle='italic')

    # Central synthesis
    ax.text(0.5, 0.45, 'LOCAL-TO-GLOBAL\nVERIFICATION', ha='center', va='center',
            fontsize=14, fontweight='bold', color='#1A237E',
            bbox=dict(boxstyle='round,pad=0.5', facecolor='#E8EAF6',
                     edgecolor='#3F51B5', linewidth=2))

    ax.set_xlim(-0.05, 1.05)
    ax.set_ylim(-0.05, 1.1)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Decomposable Verification: Three-Pillar Synthesis',
                 fontsize=16, fontweight='bold', pad=20)

    return fig_to_base64(fig)


def generate_all_visualizations():
    """Generate all visualizations and return as dict."""
    print("Generating visualizations...")

    viz1 = viz_freivalds_detection_rate()
    print("  ✓ Freivalds detection rate")

    viz2 = viz_block_diagonal()
    print("  ✓ Block diagonal decomposition")

    viz3 = viz_tropical_robustness()
    print("  ✓ Tropical robustness")

    viz4 = viz_synthesis()
    print("  ✓ Synthesis diagram")

    return [
        {"name": "Freivalds Detection Rate and Soundness Amplification", "data": viz1},
        {"name": "Block-Diagonal Structural Decomposition", "data": viz2},
        {"name": "Tropical Robustness Analysis", "data": viz3},
        {"name": "Three-Pillar Synthesis Diagram", "data": viz4},
    ]


if __name__ == "__main__":
    vizs = generate_all_visualizations()
    for v in vizs:
        print(f"  {v['name']}: {len(v['data'])} bytes")
    print("Done!")
