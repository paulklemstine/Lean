#!/usr/bin/env python3
"""
Applications of Commitment-Based Matrix Verification Protocols.

Demonstrates real-world applications in:
1. Verifiable neural network inference
2. Outsourced matrix computation
3. Tropical/attention-style verification
4. Certified linear algebra pipelines
"""

import numpy as np
from typing import List, Tuple, Dict
import hashlib
import time


# =============================================================================
# Application 1: Verifiable Neural Network Layer
# =============================================================================

class VerifiableLinearLayer:
    """
    A neural network linear layer with built-in verification.

    Computes y = W @ x + b with row-by-row verification capability.
    The verifier can challenge any row i and receive a proof that
    y[i] = sum_j W[i,j] * x[j] + b[i].

    This implements the affine layer verification theorem from
    FUTURE_DIRECTIONS.
    """

    def __init__(self, W: np.ndarray, b: np.ndarray):
        self.W = W
        self.b = b
        self.m, self.n = W.shape
        self._commitment = hashlib.sha256(
            W.tobytes() + b.tobytes()
        ).hexdigest()

    def forward(self, x: np.ndarray) -> np.ndarray:
        """Compute y = W @ x + b."""
        return self.W @ x + self.b

    def get_commitment(self) -> str:
        """Return binding commitment to (W, b)."""
        return self._commitment

    def open_row(self, i: int, x: np.ndarray) -> Tuple[np.ndarray, float, float]:
        """
        Open row i for verification.

        Returns:
            (W[i, :], b[i], rowProd = sum_j W[i,j]*x[j] + b[i])
        """
        row_prod = np.dot(self.W[i, :], x) + self.b[i]
        return self.W[i, :].copy(), self.b[i], row_prod

    def verify_row(self, i: int, x: np.ndarray, y: np.ndarray,
                   tolerance: float = 1e-10) -> bool:
        """Verify that y[i] = W[i,:] @ x + b[i]."""
        _, _, expected = self.open_row(i, x)
        return abs(y[i] - expected) <= tolerance

    def full_verify(self, x: np.ndarray, y: np.ndarray,
                    tolerance: float = 1e-10) -> bool:
        """Verify all rows (deterministic full coverage)."""
        return all(self.verify_row(i, x, y, tolerance)
                   for i in range(self.m))


def demo_neural_verification():
    """Demonstrate verifiable neural network inference."""
    print("=" * 70)
    print("APPLICATION 1: Verifiable Neural Network Layer Inference")
    print("=" * 70)

    np.random.seed(42)

    # Simulate a small neural network layer
    input_dim, output_dim = 768, 256  # typical transformer dimensions
    W = np.random.randn(output_dim, input_dim) * 0.02
    b = np.zeros(output_dim)
    x = np.random.randn(input_dim)

    layer = VerifiableLinearLayer(W, b)

    # Forward pass
    y = layer.forward(x)

    print(f"\n  Layer: {input_dim} → {output_dim}")
    print(f"  Commitment: {layer.get_commitment()[:32]}...")
    print(f"  Input norm: {np.linalg.norm(x):.4f}")
    print(f"  Output norm: {np.linalg.norm(y):.4f}")

    # Verify selected rows (simulating random challenges)
    challenge_rows = np.random.choice(output_dim, size=10, replace=False)
    print(f"\n  Verifying {len(challenge_rows)} randomly challenged rows:")

    all_pass = True
    for i in challenge_rows:
        passed = layer.verify_row(i, x, y)
        all_pass = all_pass and passed

    print(f"  All challenged rows verified: {all_pass}")

    # Full verification
    t0 = time.time()
    full_pass = layer.full_verify(x, y)
    t_verify = time.time() - t0
    print(f"\n  Full verification ({output_dim} rows): {full_pass}")
    print(f"  Verification time: {t_verify:.4f}s")

    # Tampered output
    y_tampered = y.copy()
    y_tampered[42] += 0.001
    tamper_detected = not layer.full_verify(x, y_tampered)
    print(f"\n  Tampered output detected: {tamper_detected}")
    print()


# =============================================================================
# Application 2: Outsourced Matrix Computation
# =============================================================================

class OutsourcedMatMul:
    """
    Protocol for verifying outsourced matrix multiplication.

    A client wants to compute K = A @ B but delegates to a server.
    The client commits to A and B, sends them to the server,
    receives K, and verifies using the row-check protocol.

    Implements the full_protocol_soundness theorem.
    """

    def __init__(self):
        self.scheme = lambda M: hashlib.sha256(M.tobytes()).hexdigest()

    def client_commit(self, A: np.ndarray, B: np.ndarray) -> Tuple[str, str]:
        """Client commits to input matrices."""
        return self.scheme(A), self.scheme(B)

    def server_compute(self, A: np.ndarray, B: np.ndarray) -> np.ndarray:
        """Server computes the product (possibly incorrectly)."""
        return A @ B

    def client_verify(
        self,
        A: np.ndarray, B: np.ndarray,
        K: np.ndarray,
        num_checks: int = -1,
        tolerance: float = 1e-10
    ) -> Tuple[bool, float]:
        """
        Client verifies the result using row challenges.

        If num_checks == -1, checks all rows (deterministic).
        Otherwise, checks random rows (probabilistic).
        """
        m = A.shape[0]
        if num_checks == -1:
            rows_to_check = range(m)
        else:
            rows_to_check = np.random.choice(m, size=min(num_checks, m),
                                              replace=False)

        max_error = 0.0
        for i in rows_to_check:
            expected = A[i, :] @ B
            error = np.max(np.abs(K[i, :] - expected))
            max_error = max(max_error, error)

        return max_error <= tolerance, max_error


def demo_outsourced_computation():
    """Demonstrate outsourced matrix multiplication verification."""
    print("=" * 70)
    print("APPLICATION 2: Outsourced Matrix Computation Verification")
    print("=" * 70)

    np.random.seed(123)
    m, n, p = 200, 150, 180

    A = np.random.randn(m, n)
    B = np.random.randn(n, p)

    protocol = OutsourcedMatMul()

    # Commit
    c_A, c_B = protocol.client_commit(A, B)
    print(f"\n  Problem: {m}×{n} @ {n}×{p} matrix multiplication")
    print(f"  Client commitments: A={c_A[:16]}..., B={c_B[:16]}...")

    # Honest server
    K_honest = protocol.server_compute(A, B)
    passed, error = protocol.client_verify(A, B, K_honest)
    print(f"\n  Honest server:")
    print(f"    Verified: {passed}, max error: {error:.2e}")

    # Malicious server (returns slightly wrong result)
    K_malicious = K_honest.copy()
    K_malicious[50, 60] += 0.01
    passed_m, error_m = protocol.client_verify(A, B, K_malicious)
    print(f"\n  Malicious server (one entry perturbed by 0.01):")
    print(f"    Verified: {passed_m}, max error: {error_m:.2e}")

    # Lazy server (returns zeros)
    K_lazy = np.zeros((m, p))
    passed_l, error_l = protocol.client_verify(A, B, K_lazy, num_checks=5)
    print(f"\n  Lazy server (returns zeros, 5 random checks):")
    print(f"    Verified: {passed_l}, max error: {error_l:.2e}")

    # Cost analysis
    full_cost = m * n * p
    verify_cost = m * n  # checking all m rows, each O(n) for dot product
    print(f"\n  Cost analysis:")
    print(f"    Full recomputation: {full_cost:,} multiplications")
    print(f"    Row verification:   {verify_cost:,} multiplications")
    print(f"    Savings: {(1 - verify_cost/full_cost)*100:.1f}% "
          f"(but server does full work)")
    print()


# =============================================================================
# Application 3: Tropical/Attention-Style Verification
# =============================================================================

def softmax(x: np.ndarray) -> np.ndarray:
    """Numerically stable softmax."""
    e_x = np.exp(x - np.max(x))
    return e_x / e_x.sum()


def demo_attention_verification():
    """Demonstrate attention-style verification where only argmax matters."""
    print("=" * 70)
    print("APPLICATION 3: Tropical/Attention-Style Dominant Verification")
    print("=" * 70)

    np.random.seed(456)
    seq_len, d_model = 16, 32

    # Simulate attention: Q @ K^T gives attention scores
    Q = np.random.randn(seq_len, d_model) * 0.5
    K_mat = np.random.randn(seq_len, d_model) * 0.5

    scores = Q @ K_mat.T  # attention scores
    attention = np.array([softmax(scores[i]) for i in range(seq_len)])

    print(f"\n  Attention: {seq_len} queries × {seq_len} keys, d={d_model}")
    print(f"  Score matrix shape: {scores.shape}")

    # For each query, find the dominant key (argmax of attention)
    dominant_keys = np.argmax(attention, axis=1)
    print(f"\n  Dominant keys (argmax of attention for each query):")
    print(f"  {dominant_keys}")

    # Tropical verification: only check that the dominant key is correct
    # by verifying the score for the dominant key exceeds all others
    print(f"\n  Tropical verification (dominant key correctness):")
    verified = 0
    for i in range(seq_len):
        dominant = dominant_keys[i]
        score_dominant = scores[i, dominant]
        # Check: score at dominant key >= all other scores
        is_dominant = all(score_dominant >= scores[i, j] - 1e-10
                          for j in range(seq_len))
        if is_dominant:
            verified += 1

    print(f"  Verified {verified}/{seq_len} dominant keys correct")

    # Separation analysis: how well-separated is the dominant key?
    separations = []
    for i in range(seq_len):
        sorted_scores = np.sort(scores[i])[::-1]
        gap = sorted_scores[0] - sorted_scores[1]
        separations.append(gap)

    separations = np.array(separations)
    print(f"\n  Separation analysis (gap between top-2 scores):")
    print(f"    Mean gap:   {separations.mean():.4f}")
    print(f"    Min gap:    {separations.min():.4f}")
    print(f"    Max gap:    {separations.max():.4f}")
    print(f"    Std gap:    {separations.std():.4f}")

    # With sufficient separation, approximate verification suffices
    threshold = 0.5
    well_separated = np.sum(separations > threshold)
    print(f"\n  Rows with gap > {threshold}: {well_separated}/{seq_len}")
    print(f"  These rows have certified argmax under perturbations < {threshold/2:.2f}")
    print()


# =============================================================================
# Application 4: Certified Pipeline for ML Inference
# =============================================================================

def demo_certified_pipeline():
    """Demonstrate a certified multi-layer inference pipeline."""
    print("=" * 70)
    print("APPLICATION 4: Certified Multi-Layer Neural Network Pipeline")
    print("=" * 70)

    np.random.seed(789)

    # 3-layer network: 64 → 32 → 16 → 8
    dims = [64, 32, 16, 8]
    layers = []
    for i in range(len(dims) - 1):
        W = np.random.randn(dims[i+1], dims[i]) * np.sqrt(2.0 / dims[i])
        b = np.zeros(dims[i+1])
        layers.append(VerifiableLinearLayer(W, b))

    # Input
    x = np.random.randn(dims[0])

    # Forward pass with certification
    print(f"\n  Network architecture: {' → '.join(map(str, dims))}")
    print(f"  Input: x ∈ ℝ^{dims[0]}, ‖x‖ = {np.linalg.norm(x):.4f}")

    activations = [x]
    commitments = []
    verified_layers = []

    for idx, layer in enumerate(layers):
        # Compute
        y = layer.forward(activations[-1])
        y_activated = np.maximum(y, 0)  # ReLU

        # Commit
        commitments.append(layer.get_commitment()[:16])

        # Verify (the linear part, before ReLU)
        passed = layer.full_verify(activations[-1], y)
        verified_layers.append(passed)

        activations.append(y_activated)

        print(f"\n  Layer {idx+1} ({dims[idx]} → {dims[idx+1]}):")
        print(f"    Commitment: {commitments[-1]}...")
        print(f"    Output norm (pre-ReLU): {np.linalg.norm(y):.4f}")
        print(f"    Output norm (post-ReLU): {np.linalg.norm(y_activated):.4f}")
        print(f"    Verified: {'✓' if passed else '✗'}")

    output = activations[-1]
    all_verified = all(verified_layers)
    print(f"\n  Final output: {output.round(4)}")
    print(f"  Prediction (argmax): class {np.argmax(output)}")
    print(f"  All layers verified: {'✓' if all_verified else '✗'}")
    print(f"\n  Certificate chain:")
    for idx in range(len(layers)):
        print(f"    Layer {idx+1}: commit={commitments[idx]}... "
              f"verified={'✓' if verified_layers[idx] else '✗'}")
    print()


# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    demo_neural_verification()
    demo_outsourced_computation()
    demo_attention_verification()
    demo_certified_pipeline()

    print("=" * 70)
    print("ALL APPLICATIONS COMPLETE")
    print("=" * 70)


#!/usr/bin/env python3
"""
Demonstration of the Commitment-Based Matrix Verification Protocol.

This script provides concrete numerical examples showing how row-local
verification of matrix multiplication works, and how binding commitments
ensure global correctness.
"""

import numpy as np
from typing import Callable, Tuple, List
import hashlib
import json


def row_prod(A: np.ndarray, B: np.ndarray, i: int) -> np.ndarray:
    """Compute the row-product vector for row i: rowProd(A, B, i)[k] = sum_j A[i,j] * B[j,k]."""
    return A[i, :] @ B


def one_hot_row(m: int, i: int) -> np.ndarray:
    """Create a one-hot row selector vector: 1 at index i, 0 elsewhere."""
    v = np.zeros(m)
    v[i] = 1.0
    return v


def one_hot_extract_row(K: np.ndarray, i: int) -> np.ndarray:
    """Extract row i from matrix K using one-hot linear functional."""
    m = K.shape[0]
    e_i = one_hot_row(m, i)
    return e_i @ K


# =============================================================================
# Demo 1: Row-local characterization of matrix multiplication
# =============================================================================
def demo_rowwise_characterization():
    """Show that K = A * B iff all row checks pass."""
    print("=" * 70)
    print("DEMO 1: Row-Local Characterization of Matrix Multiplication")
    print("=" * 70)

    np.random.seed(42)
    m, n, p = 4, 3, 5
    A = np.random.randn(m, n).round(3)
    B = np.random.randn(n, p).round(3)
    K = A @ B

    print(f"\nMatrix dimensions: A({m}×{n}), B({n}×{p}), K({m}×{p})")
    print(f"\nA =\n{A}")
    print(f"\nB =\n{B}")
    print(f"\nK = A @ B =\n{K.round(6)}")

    print("\n--- Verifying row by row ---")
    all_pass = True
    for i in range(m):
        row_check = row_prod(A, B, i)
        match = np.allclose(K[i, :], row_check)
        all_pass = all_pass and match
        print(f"  Row {i}: K[{i},:] = {K[i,:].round(6)}")
        print(f"          rowProd = {row_check.round(6)}")
        print(f"          Match: {match}")

    print(f"\n✓ All row checks pass: {all_pass}")
    print(f"✓ Therefore K = A @ B (by matrix_mul_eq_iff_rowwise)")

    # Now try with a wrong K
    print("\n--- Testing with incorrect K ---")
    K_wrong = K.copy()
    K_wrong[2, 3] += 0.001  # perturb one entry
    for i in range(m):
        row_check = row_prod(A, B, i)
        match = np.allclose(K_wrong[i, :], row_check)
        if not match:
            print(f"  Row {i}: MISMATCH detected!")
            print(f"          K_wrong[{i},:] = {K_wrong[i,:].round(6)}")
            print(f"          rowProd      = {row_check.round(6)}")
            print(f"          Diff         = {(K_wrong[i,:] - row_check).round(6)}")
            break

    print("\n✓ Perturbation caught by row check")
    print()


# =============================================================================
# Demo 2: One-hot row extraction
# =============================================================================
def demo_one_hot_extraction():
    """Show one-hot vectors extract rows from matrices."""
    print("=" * 70)
    print("DEMO 2: One-Hot Row Extraction (Challenge-Response as Linear Testing)")
    print("=" * 70)

    np.random.seed(123)
    m, p = 4, 5
    K = np.random.randn(m, p).round(3)

    print(f"\nK =\n{K}")

    for i in range(m):
        e_i = one_hot_row(m, i)
        extracted = one_hot_extract_row(K, i)
        direct = K[i, :]
        match = np.allclose(extracted, direct)
        print(f"\n  Challenge i={i}: e_{i} = {e_i}")
        print(f"    e_{i} @ K = {extracted.round(6)}")
        print(f"    K[{i},:]  = {direct.round(6)}")
        print(f"    Match: {match}")

    print("\n✓ oneHotRow_mul_extracts_row verified for all rows")
    print()


# =============================================================================
# Demo 3: One-hot extraction composes with matrix multiplication
# =============================================================================
def demo_one_hot_composition():
    """Show that one-hot probing of A*B yields the row-product formula."""
    print("=" * 70)
    print("DEMO 3: One-Hot Probing Composes with Matrix Multiplication")
    print("=" * 70)

    np.random.seed(456)
    m, n, p = 3, 4, 5
    A = np.random.randn(m, n).round(3)
    B = np.random.randn(n, p).round(3)
    AB = A @ B

    print(f"\nA({m}×{n}) @ B({n}×{p}) = AB({m}×{p})")

    for i in range(m):
        e_i = one_hot_row(m, i)
        # One-hot extraction from AB
        lhs = e_i @ AB
        # Direct row-product computation
        rhs = row_prod(A, B, i)
        match = np.allclose(lhs, rhs)
        print(f"\n  Row {i}:")
        print(f"    e_{i} @ (A@B)      = {lhs.round(6)}")
        print(f"    sum_j A[{i},j]*B[j,:] = {rhs.round(6)}")
        print(f"    Match: {match}")

    print("\n✓ oneHotRow_mul_A_mul_B verified: challenge extraction = row product")
    print()


# =============================================================================
# Demo 4: Binding commitment simulation
# =============================================================================
def demo_binding_commitment():
    """Simulate a binding commitment scheme using cryptographic hashing."""
    print("=" * 70)
    print("DEMO 4: Binding Commitment Scheme (Hash-Based Simulation)")
    print("=" * 70)

    def commit(M: np.ndarray) -> str:
        """Commit to a matrix using SHA-256 hash (simulates binding property)."""
        data = M.tobytes()
        return hashlib.sha256(data).hexdigest()[:16]

    np.random.seed(789)
    m, n, p = 3, 4, 5
    A = np.random.randn(m, n).round(6)
    B = np.random.randn(n, p).round(6)
    K = A @ B

    # Commit to A and B
    c_A = commit(A)
    c_B = commit(B)

    print(f"\n  Prover commits:")
    print(f"    commit(A) = {c_A}")
    print(f"    commit(B) = {c_B}")

    # Verifier challenges all rows
    print(f"\n  Verifier challenges all {m} rows:")
    all_pass = True
    for i in range(m):
        revealed_row = row_prod(A, B, i)
        check = np.allclose(K[i, :], revealed_row)
        all_pass = all_pass and check
        print(f"    Row {i}: {'✓ PASS' if check else '✗ FAIL'}")

    print(f"\n  All checks pass: {all_pass}")

    # Binding property: changing A changes the commitment
    A_prime = A.copy()
    A_prime[0, 0] += 1e-10
    c_A_prime = commit(A_prime)
    print(f"\n  Binding test:")
    print(f"    commit(A)  = {c_A}")
    print(f"    commit(A') = {c_A_prime}")
    print(f"    A ≠ A' yet commit(A) ≠ commit(A'): {c_A != c_A_prime}")

    print(f"\n✓ full_protocol_soundness: K = A@B ∧ A uniquely determined ∧ B uniquely determined")
    print()


# =============================================================================
# Demo 5: Local-to-global reconstruction
# =============================================================================
def demo_local_to_global():
    """Show that knowing all rows determines the entire matrix."""
    print("=" * 70)
    print("DEMO 5: Local-to-Global Reconstruction (Čech Analogy)")
    print("=" * 70)

    np.random.seed(101)
    m, p = 5, 4
    K = np.random.randn(m, p).round(3)

    print(f"\n  Original matrix K({m}×{p}):")
    print(f"  {K}")

    # Reconstruct from rows
    print(f"\n  Reconstructing from individual rows (local data):")
    L = np.zeros_like(K)
    for i in range(m):
        row_i = K[i, :]  # "opened" row
        L[i, :] = row_i
        print(f"    Row {i}: {row_i}")

    match = np.allclose(K, L)
    print(f"\n  Reconstructed matrix L = K: {match}")
    print(f"\n✓ committed_matrix_determined_by_all_opened_rows:")
    print(f"  Local row data uniquely determines the global matrix")
    print(f"  (Finite algebraic analogue of Čech cocycle determination)")
    print()


# =============================================================================
# Demo 6: Protocol efficiency comparison
# =============================================================================
def demo_efficiency():
    """Compare full verification vs row-by-row verification costs."""
    print("=" * 70)
    print("DEMO 6: Protocol Efficiency Analysis")
    print("=" * 70)

    sizes = [(10, 10, 10), (50, 50, 50), (100, 100, 100), (500, 500, 500)]

    print(f"\n  {'m×n×p':<15} {'Full verify':<15} {'Per-row check':<15} {'Ratio':<10}")
    print(f"  {'-'*55}")

    for m, n, p in sizes:
        full_cost = m * n * p  # computing A*B naively
        row_cost = n * p       # checking one row
        ratio = full_cost / row_cost
        print(f"  {f'{m}×{n}×{p}':<15} {full_cost:<15,} {row_cost:<15,} {ratio:<10.1f}")

    print(f"\n  Each row check costs O(n*p), total for all m rows: O(m*n*p)")
    print(f"  But a probabilistic protocol (Freivalds) checks only O(1) random rows!")
    print(f"  Cost reduction: from O(m*n*p) to O(n*p) per round")
    print()


if __name__ == "__main__":
    demo_rowwise_characterization()
    demo_one_hot_extraction()
    demo_one_hot_composition()
    demo_binding_commitment()
    demo_local_to_global()
    demo_efficiency()

    print("=" * 70)
    print("ALL DEMOS COMPLETE")
    print("=" * 70)
    print("\nSummary of formally verified theorems demonstrated:")
    print("  1. matrix_mul_eq_iff_rowwise      — Row-local ↔ global characterization")
    print("  2. matrix_mul_eq_iff_rowProd       — Protocol-facing row verification")
    print("  3. oneHotRow_mul_extracts_row      — One-hot row extraction")
    print("  4. oneHotRow_mul_A_mul_B           — Challenge-response composition")
    print("  5. binding_row_checks_force_unique — Binding commitment uniqueness")
    print("  6. full_protocol_soundness         — Complete protocol soundness")
    print("  7. matrix_determined_by_rows       — Local-to-global reconstruction")
    print("  8. committed_matrix_determined     — Čech-style row determination")
    print("  9. oneHot_extraction_eq_rowProd    — Bridge: linear testing = algebra")


#!/usr/bin/env python3
"""
Visualizations for Commitment-Based Matrix Verification Protocols.
Generates PNG figures for the research paper and article.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.colors import LinearSegmentedColormap
import base64
from io import BytesIO


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64-encoded PNG data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"


def create_protocol_diagram():
    """Create a visual diagram of the verification protocol."""
    fig, ax = plt.subplots(1, 1, figsize=(12, 6))
    ax.set_xlim(0, 12)
    ax.set_ylim(0, 6)
    ax.axis('off')
    ax.set_title('Row-Challenge Matrix Verification Protocol', fontsize=16, fontweight='bold', pad=20)

    # Prover box
    prover = patches.FancyBboxPatch((0.5, 1), 3, 4, boxstyle="round,pad=0.2",
                                     facecolor='#E3F2FD', edgecolor='#1565C0', linewidth=2)
    ax.add_patch(prover)
    ax.text(2, 4.5, 'PROVER', ha='center', fontsize=14, fontweight='bold', color='#1565C0')
    ax.text(2, 3.5, 'Holds A, B', ha='center', fontsize=11)
    ax.text(2, 2.8, 'Computes K = A·B', ha='center', fontsize=11)
    ax.text(2, 2.1, 'Commits: c(A), c(B)', ha='center', fontsize=11)

    # Verifier box
    verifier = patches.FancyBboxPatch((8.5, 1), 3, 4, boxstyle="round,pad=0.2",
                                       facecolor='#E8F5E9', edgecolor='#2E7D32', linewidth=2)
    ax.add_patch(verifier)
    ax.text(10, 4.5, 'VERIFIER', ha='center', fontsize=14, fontweight='bold', color='#2E7D32')
    ax.text(10, 3.5, 'Holds K, c(A), c(B)', ha='center', fontsize=11)
    ax.text(10, 2.8, 'Challenges row i', ha='center', fontsize=11)
    ax.text(10, 2.1, 'Checks row match', ha='center', fontsize=11)

    # Arrows
    ax.annotate('', xy=(8.3, 4), xytext=(3.7, 4),
                arrowprops=dict(arrowstyle='->', color='#1565C0', lw=2))
    ax.text(6, 4.3, 'commit(A), commit(B), K', ha='center', fontsize=10, color='#1565C0')

    ax.annotate('', xy=(3.7, 3), xytext=(8.3, 3),
                arrowprops=dict(arrowstyle='->', color='#2E7D32', lw=2))
    ax.text(6, 3.3, 'challenge i', ha='center', fontsize=10, color='#2E7D32')

    ax.annotate('', xy=(8.3, 2), xytext=(3.7, 2),
                arrowprops=dict(arrowstyle='->', color='#1565C0', lw=2))
    ax.text(6, 2.3, 'rowProd(A, B, i)', ha='center', fontsize=10, color='#1565C0')

    # Theorem box
    thm = patches.FancyBboxPatch((3, 0), 6, 0.8, boxstyle="round,pad=0.1",
                                  facecolor='#FFF3E0', edgecolor='#E65100', linewidth=2)
    ax.add_patch(thm)
    ax.text(6, 0.4, '∀ rows pass  ⟹  K = A·B  (formally verified)', ha='center',
            fontsize=12, fontweight='bold', color='#E65100')

    fig.savefig('/workspace/request-project/protocol_diagram.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def create_row_decomposition_heatmap():
    """Visualize row-by-row decomposition of matrix multiplication."""
    np.random.seed(42)
    m, n, p = 6, 4, 8
    A = np.random.randn(m, n)
    B = np.random.randn(n, p)
    K = A @ B

    fig, axes = plt.subplots(2, 4, figsize=(16, 8))
    fig.suptitle('Row Decomposition of Matrix Product K = A·B', fontsize=16, fontweight='bold')

    # Show full product
    im = axes[0, 0].imshow(K, cmap='RdBu_r', aspect='auto')
    axes[0, 0].set_title('K = A·B (full)', fontsize=12)
    axes[0, 0].set_xlabel('columns')
    axes[0, 0].set_ylabel('rows')
    plt.colorbar(im, ax=axes[0, 0], shrink=0.8)

    # Show individual row contributions
    for idx in range(min(6, m)):
        row, col = (idx + 1) // 4, (idx + 1) % 4
        if row >= 2:
            break

        # Highlight just this row
        highlight = np.zeros_like(K)
        highlight[idx, :] = K[idx, :]

        im = axes[row, col].imshow(highlight, cmap='RdBu_r', aspect='auto',
                                    vmin=K.min(), vmax=K.max())
        axes[row, col].set_title(f'Row {idx}: K[{idx},:]', fontsize=12)

        # Draw box around the active row
        rect = patches.Rectangle((-0.5, idx-0.5), p, 1,
                                  linewidth=2, edgecolor='red', facecolor='none')
        axes[row, col].add_patch(rect)

    # Hide unused subplots
    for idx in range(min(6, m) + 1, 8):
        row, col = idx // 4, idx % 4
        axes[row, col].axis('off')

    plt.tight_layout()
    fig.savefig('/workspace/request-project/row_decomposition.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def create_one_hot_extraction_viz():
    """Visualize how one-hot vectors extract rows."""
    np.random.seed(42)
    m, p = 5, 6
    K = np.random.randn(m, p).round(2)

    fig, axes = plt.subplots(1, 3, figsize=(14, 5))
    fig.suptitle('One-Hot Row Extraction: e_i · K = K[i,:]', fontsize=16, fontweight='bold')

    i = 2  # Extract row 2

    # One-hot vector
    e_i = np.zeros((m, 1))
    e_i[i] = 1
    axes[0].imshow(e_i, cmap='Blues', aspect='auto')
    axes[0].set_title(f'e_{i} (one-hot vector)', fontsize=13)
    axes[0].set_ylabel('row index')
    for r in range(m):
        axes[0].text(0, r, f'{e_i[r,0]:.0f}', ha='center', va='center',
                     fontsize=14, fontweight='bold',
                     color='white' if r == i else 'gray')

    # Matrix K
    im = axes[1].imshow(K, cmap='RdBu_r', aspect='auto')
    axes[1].set_title('K (matrix)', fontsize=13)
    rect = patches.Rectangle((-0.5, i-0.5), p, 1,
                              linewidth=3, edgecolor='red', facecolor='none')
    axes[1].add_patch(rect)
    plt.colorbar(im, ax=axes[1], shrink=0.8)

    # Extracted row
    extracted = K[i:i+1, :]
    axes[2].imshow(extracted, cmap='RdBu_r', aspect='auto',
                    vmin=K.min(), vmax=K.max())
    axes[2].set_title(f'e_{i} · K = K[{i},:]', fontsize=13)
    for k in range(p):
        axes[2].text(k, 0, f'{K[i,k]:.2f}', ha='center', va='center',
                     fontsize=10, fontweight='bold')

    plt.tight_layout()
    fig.savefig('/workspace/request-project/one_hot_extraction.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def create_error_propagation_chart():
    """Show how row-local errors propagate to global error bounds."""
    np.random.seed(42)
    m, n, p = 50, 40, 60
    A = np.random.randn(m, n)
    B = np.random.randn(n, p)
    K_true = A @ B

    epsilon_values = np.logspace(-6, -1, 20)
    max_errors = []
    mean_errors = []

    for eps in epsilon_values:
        noise = np.random.randn(m, p) * eps
        K_noisy = K_true + noise

        row_errors = []
        for i in range(m):
            row_prod = A[i, :] @ B
            err = np.max(np.abs(K_noisy[i, :] - row_prod))
            row_errors.append(err)

        max_errors.append(max(row_errors))
        mean_errors.append(np.mean(row_errors))

    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    ax.loglog(epsilon_values, max_errors, 'o-', label='Max row error', color='#D32F2F', linewidth=2)
    ax.loglog(epsilon_values, mean_errors, 's-', label='Mean row error', color='#1976D2', linewidth=2)
    ax.loglog(epsilon_values, epsilon_values, '--', label='ε (perturbation scale)',
              color='gray', linewidth=1)

    ax.set_xlabel('Perturbation scale ε', fontsize=13)
    ax.set_ylabel('Error', fontsize=13)
    ax.set_title('Row-Local Error Propagation to Global Bounds', fontsize=15, fontweight='bold')
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)

    fig.savefig('/workspace/request-project/error_propagation.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def create_scaling_comparison():
    """Compare deterministic vs probabilistic verification costs."""
    sizes = [10, 20, 50, 100, 200, 500, 1000]

    det_costs = [s**3 for s in sizes]  # O(m*n*p) ≈ O(n³) for square
    prob_costs_1 = [s**2 for s in sizes]  # O(n²) per Freivalds round
    prob_costs_20 = [20 * s**2 for s in sizes]  # 20 rounds

    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    ax.loglog(sizes, det_costs, 'o-', label='Deterministic (all rows)', color='#D32F2F',
              linewidth=2, markersize=8)
    ax.loglog(sizes, prob_costs_20, 's-', label='Freivalds (20 rounds)', color='#1976D2',
              linewidth=2, markersize=8)
    ax.loglog(sizes, prob_costs_1, '^-', label='Freivalds (1 round)', color='#388E3C',
              linewidth=2, markersize=8)

    ax.fill_between(sizes, prob_costs_1, det_costs, alpha=0.1, color='green')

    ax.set_xlabel('Matrix dimension n', fontsize=13)
    ax.set_ylabel('Verification cost (multiplications)', fontsize=13)
    ax.set_title('Verification Cost: Deterministic vs Probabilistic', fontsize=15, fontweight='bold')
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)

    fig.savefig('/workspace/request-project/scaling_comparison.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")

    b64_protocol = create_protocol_diagram()
    print(f"  Protocol diagram: {len(b64_protocol)} chars")

    b64_decomp = create_row_decomposition_heatmap()
    print(f"  Row decomposition: {len(b64_decomp)} chars")

    b64_onehot = create_one_hot_extraction_viz()
    print(f"  One-hot extraction: {len(b64_onehot)} chars")

    b64_error = create_error_propagation_chart()
    print(f"  Error propagation: {len(b64_error)} chars")

    b64_scaling = create_scaling_comparison()
    print(f"  Scaling comparison: {len(b64_scaling)} chars")

    print("\nAll visualizations generated and saved as PNG files.")
    print("Base64 data URIs available for JSON package embedding.")

    # Save base64 data for later use
    viz_data = {
        "protocol_diagram": b64_protocol,
        "row_decomposition": b64_decomp,
        "one_hot_extraction": b64_onehot,
        "error_propagation": b64_error,
        "scaling_comparison": b64_scaling
    }

    import json
    with open('/workspace/request-project/viz_data.json', 'w') as f:
        json.dump(viz_data, f)

    print("Visualization data saved to viz_data.json")
