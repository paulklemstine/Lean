#!/usr/bin/env python3
"""
Applications of Streaming Matrix Product Verification

Demonstrates real-world applications in:
1. Delegated computation (cloud verification)
2. Cryptographic commitment checking
3. Database integrity verification
4. Machine learning weight verification
"""

import numpy as np
import time
from typing import Tuple


def is_prime(n: int) -> bool:
    if n < 2:
        return False
    for i in range(2, int(n**0.5) + 1):
        if n % i == 0:
            return False
    return True


class DelegatedComputationVerifier:
    """
    Application 1: Delegated Computation

    Scenario: A client outsources matrix multiplication to an untrusted server.
    The client wants to verify the result without redoing the computation.

    Protocol:
        1. Client sends A, B to server
        2. Server returns K (claimed A*B)
        3. Client runs streaming verification with random r
        4. If state ≠ 0, reject; otherwise accept with error ≤ 1/q

    The client's verification cost is O(mn + np + mp) ≪ O(mnp) of multiplication.
    """

    def __init__(self, q: int = 104729):
        """Initialize with a prime field size."""
        self.q = q

    def client_verify(self, A: np.ndarray, B: np.ndarray,
                      K: np.ndarray, rounds: int = 3) -> Tuple[bool, float]:
        """
        Client-side verification of server's claimed product K = A*B.

        Returns (accept, error_bound).
        """
        m, n = A.shape
        _, p = B.shape

        for _ in range(rounds):
            r = np.random.randint(0, self.q, p)
            br = (B @ r) % self.q
            abr = (A @ br) % self.q
            kr = (K @ r) % self.q
            if not np.all((abr - kr) % self.q == 0):
                return False, 0.0

        return True, (1.0 / self.q) ** rounds

    def demo(self):
        print("=" * 60)
        print("APPLICATION 1: Delegated Computation Verification")
        print("=" * 60)

        sizes = [50, 100, 200]
        for n in sizes:
            A = np.random.randint(0, self.q, (n, n))
            B = np.random.randint(0, self.q, (n, n))
            K_correct = (A @ B) % self.q

            # Time the full multiplication
            t0 = time.time()
            _ = (A @ B) % self.q
            mul_time = time.time() - t0

            # Time the verification
            t0 = time.time()
            accept, bound = self.client_verify(A, B, K_correct, rounds=3)
            ver_time = time.time() - t0

            speedup = mul_time / ver_time if ver_time > 0 else float('inf')
            print(f"\n  n={n}: mul={mul_time*1000:.1f}ms, verify={ver_time*1000:.1f}ms, "
                  f"speedup={speedup:.1f}x, accept={accept}")

        # Test with corrupted result
        n = 100
        A = np.random.randint(0, self.q, (n, n))
        B = np.random.randint(0, self.q, (n, n))
        K_bad = (A @ B + np.eye(n, dtype=int)) % self.q
        accept, bound = self.client_verify(A, B, K_bad, rounds=3)
        print(f"\n  Corrupted result (n={n}): accept={accept}, error_bound={bound:.2e}")


class DatabaseIntegrityChecker:
    """
    Application 2: Database Join Verification

    Scenario: Verify that a database join result is correct by modeling
    the join as a matrix product and using streaming verification.

    A record-attribute matrix R (records × attributes) joined with a
    transformation matrix T gives result J = R * T. Verify J without
    recomputing the full join.
    """

    def __init__(self, q: int = 104729):
        self.q = q

    def verify_join(self, R: np.ndarray, T: np.ndarray,
                    J: np.ndarray) -> Tuple[bool, float]:
        """Verify J = R * T mod q."""
        _, p = T.shape
        r = np.random.randint(0, self.q, p)
        tr = (T @ r) % self.q
        rtr = (R @ tr) % self.q
        jr = (J @ r) % self.q
        return bool(np.all((rtr - jr) % self.q == 0)), 1.0 / self.q

    def demo(self):
        print("\n" + "=" * 60)
        print("APPLICATION 2: Database Join Verification")
        print("=" * 60)

        # Simulate: 1000 records, 50 attributes, 20 output columns
        records, attrs, outputs = 1000, 50, 20
        R = np.random.randint(0, 100, (records, attrs)) % self.q
        T = np.random.randint(0, 100, (attrs, outputs)) % self.q
        J = (R @ T) % self.q

        accept, bound = self.verify_join(R, T, J)
        print(f"\n  Correct join ({records} records, {attrs} attrs → {outputs} outputs):")
        print(f"    accept={accept}, error_bound={bound:.6f}")

        # Corrupt one entry
        J_bad = J.copy()
        J_bad[42, 7] = (J_bad[42, 7] + 1) % self.q
        
        # Run multiple times to show detection
        detections = sum(1 for _ in range(100)
                        if not self.verify_join(R, T, J_bad)[0])
        print(f"\n  Corrupted join (1 entry changed):")
        print(f"    Detection rate over 100 trials: {detections}%")
        print(f"    Expected: ≥ {100*(1 - 1/self.q):.1f}%")


class MLWeightVerifier:
    """
    Application 3: Neural Network Weight Verification

    Scenario: Verify that a neural network layer computes Y = W * X + bias
    correctly, where W is the weight matrix and X is the input batch.

    This is relevant for:
    - Verifiable AI inference
    - Federated learning integrity checks
    - Model serving verification
    """

    def __init__(self, q: int = 104729):
        self.q = q

    def verify_linear_layer(self, W: np.ndarray, X: np.ndarray,
                            Y: np.ndarray) -> bool:
        """Verify Y = W * X mod q (ignoring bias for simplicity)."""
        _, p = X.shape
        r = np.random.randint(0, self.q, p)
        xr = (X @ r) % self.q
        wxr = (W @ xr) % self.q
        yr = (Y @ r) % self.q
        return bool(np.all((wxr - yr) % self.q == 0))

    def demo(self):
        print("\n" + "=" * 60)
        print("APPLICATION 3: ML Weight Verification")
        print("=" * 60)

        # Simulate a neural network layer
        hidden, input_dim, batch = 256, 512, 64
        W = np.random.randint(0, self.q, (hidden, input_dim))
        X = np.random.randint(0, self.q, (input_dim, batch))
        Y = (W @ X) % self.q

        print(f"\n  Layer: {hidden}×{input_dim} weights, batch={batch}")

        # Correct computation
        t0 = time.time()
        verified = self.verify_linear_layer(W, X, Y)
        ver_time = time.time() - t0
        print(f"  Correct output: verified={verified} ({ver_time*1000:.2f}ms)")

        # Tampered weights (adversarial modification)
        W_tampered = W.copy()
        W_tampered[0, 0] = (W_tampered[0, 0] + 1) % self.q
        Y_tampered = (W_tampered @ X) % self.q

        detections = sum(1 for _ in range(100)
                        if not self.verify_linear_layer(W, X, Y_tampered))
        print(f"  Tampered weights: detected {detections}/100 times")


class StreamFingerprint:
    """
    Application 4: Stream Fingerprinting

    Use the same algebraic machinery for streaming equality testing:
    given two streams of data, determine if they are equal using
    sublinear space.

    The fingerprint of a sequence (a_0, ..., a_{n-1}) at challenge r is:
        F(r) = Σ a_i · r^i mod q

    Two sequences are equal iff their fingerprints agree for all r.
    By Schwartz-Zippel, disagreement is detected with probability ≥ 1 - (n-1)/q.
    """

    def __init__(self, q: int = 104729):
        self.q = q
        self.r = np.random.randint(1, q)
        self.fingerprint = 0
        self.power = 1
        self.count = 0

    def ingest(self, value: int):
        """Process one element from the stream."""
        self.fingerprint = (self.fingerprint + value * self.power) % self.q
        self.power = (self.power * self.r) % self.q
        self.count += 1

    def get_fingerprint(self) -> int:
        return self.fingerprint

    @staticmethod
    def demo():
        print("\n" + "=" * 60)
        print("APPLICATION 4: Stream Fingerprinting")
        print("=" * 60)

        q = 104729

        # Two equal streams
        stream1 = list(range(1000))
        stream2 = list(range(1000))

        f1 = StreamFingerprint(q)
        f2 = StreamFingerprint(q)
        f2.r = f1.r  # Same challenge

        for v in stream1:
            f1.ingest(v)
        for v in stream2:
            f2.ingest(v)

        print(f"\n  Equal streams (length 1000):")
        print(f"    Fingerprints match: {f1.get_fingerprint() == f2.get_fingerprint()}")
        print(f"    Memory per stream: 3 field elements (vs 1000 data elements)")

        # Two different streams
        stream3 = list(range(1000))
        stream3[500] = 999  # Change one element

        matches = 0
        trials = 1000
        for _ in range(trials):
            f1 = StreamFingerprint(q)
            f3 = StreamFingerprint(q)
            f3.r = f1.r
            for v in stream1:
                f1.ingest(v)
            for v in stream3:
                f3.ingest(v)
            if f1.get_fingerprint() == f3.get_fingerprint():
                matches += 1

        print(f"\n  Different streams (1 element changed):")
        print(f"    False matches over {trials} trials: {matches}")
        print(f"    Collision rate: {matches/trials:.4f}")
        print(f"    Bound: ≤ (n-1)/q = {999/q:.6f}")


if __name__ == "__main__":
    np.random.seed(42)

    DelegatedComputationVerifier().demo()
    DatabaseIntegrityChecker().demo()
    MLWeightVerifier().demo()
    StreamFingerprint.demo()

    print("\n" + "=" * 60)
    print("All applications demonstrated successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Streaming Matrix Product Verification: Concrete Demonstrations

Demonstrates Freivalds' algorithm and the streaming verification protocol
over finite fields GF(q) with concrete numerical examples.
"""

import random
import numpy as np
from typing import Tuple, List


def mod_matrix_mul(A: np.ndarray, B: np.ndarray, q: int) -> np.ndarray:
    """Matrix multiplication over GF(q)."""
    return (A @ B) % q


def mod_matvec(M: np.ndarray, v: np.ndarray, q: int) -> np.ndarray:
    """Matrix-vector product over GF(q)."""
    return (M @ v) % q


class StreamingVerifier:
    """
    Streaming verifier for matrix product K =? A * B over GF(q).

    State: (r, br, state) where
      r     = random challenge vector (p elements)
      br    = B * r mod q            (n elements)
      state = A * br - K * r mod q   (m elements)

    Memory: O(m + n + p) field elements (sublinear in matrix entries).
    """

    def __init__(self, q: int, r: np.ndarray):
        self.q = q
        self.r = r % q
        self.br = None
        self.state = None

    def process_B(self, B: np.ndarray):
        """Phase 1: Compute br = B * r mod q."""
        self.br = mod_matvec(B, self.r, self.q)

    def process_A_and_K(self, A: np.ndarray, K: np.ndarray):
        """Phase 2: Compute state = A * br - K * r mod q."""
        a_br = mod_matvec(A, self.br, self.q)
        k_r = mod_matvec(K, self.r, self.q)
        self.state = (a_br - k_r) % self.q

    def accepts(self) -> bool:
        """Accept iff state == 0."""
        return np.all(self.state == 0)


def demo_basic_verification():
    """Demo 1: Basic matrix product verification."""
    print("=" * 60)
    print("DEMO 1: Basic Streaming Matrix Product Verification")
    print("=" * 60)

    q = 7  # Prime field GF(7)
    m, n, p = 3, 4, 3

    # Random matrices over GF(7)
    np.random.seed(42)
    A = np.random.randint(0, q, (m, n))
    B = np.random.randint(0, q, (n, p))
    K_correct = mod_matrix_mul(A, B, q)

    print(f"\nField: GF({q})")
    print(f"Dimensions: A is {m}×{n}, B is {n}×{p}")
    print(f"\nA =\n{A}")
    print(f"\nB =\n{B}")
    print(f"\nA*B mod {q} =\n{K_correct}")

    # Test with correct product
    print("\n--- Testing K = A*B (should always accept) ---")
    for trial in range(5):
        r = np.random.randint(0, q, p)
        V = StreamingVerifier(q, r)
        V.process_B(B)
        V.process_A_and_K(A, K_correct)
        print(f"  Trial {trial+1}: r = {r}, state = {V.state}, accept = {V.accepts()}")

    # Test with incorrect product
    K_wrong = K_correct.copy()
    K_wrong[0, 0] = (K_wrong[0, 0] + 1) % q  # Flip one entry
    print(f"\n--- Testing K ≠ A*B (should reject with prob ≥ {1-1/q:.3f}) ---")
    print(f"K_wrong =\n{K_wrong}")
    accepts = 0
    trials = 1000
    for _ in range(trials):
        r = np.random.randint(0, q, p)
        V = StreamingVerifier(q, r)
        V.process_B(B)
        V.process_A_and_K(A, K_wrong)
        if V.accepts():
            accepts += 1

    print(f"\n  Over {trials} random trials:")
    print(f"  Accepted: {accepts} ({accepts/trials:.4f})")
    print(f"  Theoretical bound: ≤ 1/{q} = {1/q:.4f}")


def demo_soundness_exhaustive():
    """Demo 2: Exhaustively verify the soundness bound."""
    print("\n" + "=" * 60)
    print("DEMO 2: Exhaustive Soundness Verification")
    print("=" * 60)

    q = 5  # Small prime for exhaustive enumeration
    m, n, p = 2, 2, 2

    np.random.seed(123)
    A = np.array([[1, 2], [3, 4]])
    B = np.array([[2, 1], [0, 3]])
    K_correct = mod_matrix_mul(A, B, q)
    K_wrong = (K_correct + np.array([[1, 0], [0, 0]])) % q

    print(f"\nField: GF({q}), dimensions: {m}×{n} · {n}×{p}")
    print(f"A*B mod {q} = {K_correct.tolist()}")
    print(f"K_wrong     = {K_wrong.tolist()}")

    # Enumerate all q^p challenge vectors
    total = q ** p
    accept_count = 0
    accepting_vectors = []

    for r0 in range(q):
        for r1 in range(q):
            r = np.array([r0, r1])
            V = StreamingVerifier(q, r)
            V.process_B(B)
            V.process_A_and_K(A, K_wrong)
            if V.accepts():
                accept_count += 1
                accepting_vectors.append(r.tolist())

    print(f"\nTotal challenges: {total}")
    print(f"Accepting challenges: {accept_count}")
    print(f"Bound q^(p-1) = {q**(p-1)}")
    print(f"Accepting vectors: {accepting_vectors}")
    print(f"Ratio: {accept_count}/{total} = {accept_count/total:.4f} ≤ 1/{q} = {1/q:.4f}")
    assert accept_count <= q ** (p - 1), "Soundness bound violated!"
    print("✓ Soundness bound verified exhaustively!")


def demo_memory_scaling():
    """Demo 3: Memory usage comparison."""
    print("\n" + "=" * 60)
    print("DEMO 3: Memory Scaling Analysis")
    print("=" * 60)

    q = 101  # Larger prime
    print(f"\nField: GF({q})")
    print(f"\n{'m':>6} {'n':>6} {'p':>6} | {'Naive':>12} | {'Streaming':>12} | {'Ratio':>8}")
    print("-" * 60)

    for size in [10, 50, 100, 500, 1000]:
        m = n = p = size
        naive_memory = m * n + n * p + m * p  # Store all three matrices
        streaming_memory = p + n + m  # r + br + state
        ratio = naive_memory / streaming_memory
        print(f"{m:>6} {n:>6} {p:>6} | {naive_memory:>12,} | {streaming_memory:>12,} | {ratio:>7.1f}x")


def demo_repetition_amplification():
    """Demo 4: Error reduction through independent repetitions."""
    print("\n" + "=" * 60)
    print("DEMO 4: Repetition Amplification")
    print("=" * 60)

    q = 7
    m, n, p = 3, 3, 3

    np.random.seed(99)
    A = np.random.randint(0, q, (m, n))
    B = np.random.randint(0, q, (n, p))
    K_correct = mod_matrix_mul(A, B, q)
    K_wrong = (K_correct + np.eye(m, p, dtype=int)) % q

    print(f"\nField: GF({q}), repeating verification k times")
    print(f"Single-round error bound: 1/{q} ≈ {1/q:.4f}")

    trials = 10000
    for k in [1, 2, 3, 5, 10]:
        false_accepts = 0
        for _ in range(trials):
            all_accept = True
            for _ in range(k):
                r = np.random.randint(0, q, p)
                V = StreamingVerifier(q, r)
                V.process_B(B)
                V.process_A_and_K(A, K_wrong)
                if not V.accepts():
                    all_accept = False
                    break
            if all_accept:
                false_accepts += 1

        empirical = false_accepts / trials
        theoretical = (1 / q) ** k
        print(f"  k={k:>2}: empirical={empirical:.6f}, bound=(1/{q})^{k}={theoretical:.6f}")


def demo_kernel_structure():
    """Demo 5: Visualize the kernel (accepting set) structure."""
    print("\n" + "=" * 60)
    print("DEMO 5: Kernel Structure of Acceptance Set")
    print("=" * 60)

    q = 5
    p = 3

    # A nonzero linear functional v
    v = np.array([1, 2, 3])
    print(f"\nField: GF({q}), dimension: {p}")
    print(f"Linear functional v = {v.tolist()}")
    print(f"Kernel = {{r : v·r ≡ 0 (mod {q})}}")

    kernel = []
    for r0 in range(q):
        for r1 in range(q):
            for r2 in range(q):
                r = np.array([r0, r1, r2])
                if np.dot(v, r) % q == 0:
                    kernel.append(r.tolist())

    print(f"\nKernel size: {len(kernel)}")
    print(f"Expected (q^(p-1)): {q**(p-1)}")
    print(f"Total space (q^p): {q**p}")
    print(f"\nFirst 10 kernel vectors:")
    for vec in kernel[:10]:
        print(f"  {vec}  (dot product = {sum(a*b for a,b in zip(v,vec)) % q})")

    assert len(kernel) == q ** (p - 1), "Kernel size mismatch!"
    print(f"\n✓ Kernel has exactly q^(p-1) = {q**(p-1)} elements (hyperplane)")


if __name__ == "__main__":
    demo_basic_verification()
    demo_soundness_exhaustive()
    demo_memory_scaling()
    demo_repetition_amplification()
    demo_kernel_structure()
    print("\n" + "=" * 60)
    print("All demonstrations completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualizations for Streaming Matrix Product Verification.
Generates PNG figures saved to disk and returns base64 encodings.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import base64
import io


def fig_to_base64(fig) -> str:
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"


def viz_kernel_hyperplane():
    """Visualize the kernel (hyperplane) of a linear functional over GF(q)."""
    q = 7
    v = np.array([1, 3])  # Linear functional

    fig, ax = plt.subplots(1, 1, figsize=(7, 7))

    # All points in GF(q)^2
    all_x, all_y = [], []
    ker_x, ker_y = [], []
    for x in range(q):
        for y in range(q):
            all_x.append(x)
            all_y.append(y)
            if (v[0]*x + v[1]*y) % q == 0:
                ker_x.append(x)
                ker_y.append(y)

    ax.scatter(all_x, all_y, c='lightblue', s=80, zorder=1, label=f'All of GF({q})²')
    ax.scatter(ker_x, ker_y, c='red', s=120, zorder=2, marker='s',
               label=f'Kernel: v·r ≡ 0 (mod {q})')

    ax.set_xlabel('r₁', fontsize=14)
    ax.set_ylabel('r₂', fontsize=14)
    ax.set_title(f'Hyperplane Structure in GF({q})²\nv = ({v[0]}, {v[1]}), '
                 f'kernel size = {len(ker_x)} = {q}^(2-1)', fontsize=14)
    ax.legend(fontsize=11)
    ax.set_xticks(range(q))
    ax.set_yticks(range(q))
    ax.grid(True, alpha=0.3)
    ax.set_aspect('equal')

    fig.savefig('viz_hyperplane.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def viz_soundness_scaling():
    """Visualize how soundness error decreases with field size and repetitions."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left: error vs field size
    primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47,
              53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101]
    errors = [1.0/p for p in primes]

    ax1.semilogy(primes, errors, 'bo-', markersize=5)
    ax1.set_xlabel('Prime field size q', fontsize=13)
    ax1.set_ylabel('Error probability bound (1/q)', fontsize=13)
    ax1.set_title('Soundness Error vs Field Size', fontsize=14)
    ax1.grid(True, alpha=0.3)
    ax1.axhline(y=1e-2, color='r', linestyle='--', alpha=0.5, label='1% error')
    ax1.legend(fontsize=11)

    # Right: error vs repetitions for different q
    rounds = range(1, 21)
    for q_val, color, marker in [(2, 'red', 'o'), (7, 'blue', 's'), (101, 'green', '^'), (1009, 'purple', 'D')]:
        errs = [(1.0/q_val)**k for k in rounds]
        ax2.semilogy(rounds, errs, marker=marker, linestyle='-', markersize=4,
                     label=f'q = {q_val}', color=color)

    ax2.set_xlabel('Number of repetitions k', fontsize=13)
    ax2.set_ylabel('Error probability bound (1/q)^k', fontsize=13)
    ax2.set_title('Error Amplification via Repetition', fontsize=14)
    ax2.grid(True, alpha=0.3)
    ax2.legend(fontsize=11)
    ax2.axhline(y=2**-128, color='gray', linestyle=':', alpha=0.5)
    ax2.annotate('2⁻¹²⁸ (cryptographic)', xy=(15, 2**-128),
                fontsize=9, color='gray')

    fig.tight_layout()
    fig.savefig('viz_soundness.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def viz_memory_comparison():
    """Visualize memory usage: naive vs streaming."""
    fig, ax = plt.subplots(figsize=(10, 6))

    sizes = np.array([10, 50, 100, 500, 1000, 5000, 10000])

    naive = 3 * sizes**2  # Three n×n matrices
    streaming = 3 * sizes  # r + br + state

    ax.loglog(sizes, naive, 'rs-', markersize=8, label='Naive: O(n²)', linewidth=2)
    ax.loglog(sizes, streaming, 'bo-', markersize=8, label='Streaming: O(n)', linewidth=2)

    ax.fill_between(sizes, streaming, naive, alpha=0.15, color='green')
    ax.set_xlabel('Matrix dimension n', fontsize=14)
    ax.set_ylabel('Memory (field elements)', fontsize=14)
    ax.set_title('Memory Usage: Streaming vs Naive Verification', fontsize=15)
    ax.legend(fontsize=13)
    ax.grid(True, alpha=0.3)

    # Add ratio annotations
    for s in [100, 1000, 10000]:
        idx = np.where(sizes == s)[0][0]
        ratio = naive[idx] / streaming[idx]
        ax.annotate(f'{ratio:.0f}× savings', xy=(s, streaming[idx]),
                   xytext=(s*1.5, streaming[idx]*0.3),
                   fontsize=10, arrowprops=dict(arrowstyle='->', color='green'),
                   color='green')

    fig.savefig('viz_memory.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def viz_acceptance_distribution():
    """Visualize acceptance rates for correct vs incorrect products."""
    q = 7
    m, n, p = 3, 3, 3
    np.random.seed(42)

    A = np.random.randint(0, q, (m, n))
    B = np.random.randint(0, q, (n, p))
    K_correct = (A @ B) % q
    K_wrong = (K_correct + np.eye(m, p, dtype=int)) % q

    trials = 5000
    correct_accepts = []
    wrong_accepts = []

    for _ in range(trials):
        r = np.random.randint(0, q, p)
        br = (B @ r) % q
        # Correct product
        state_c = (A @ br - K_correct @ r) % q
        correct_accepts.append(1 if np.all(state_c == 0) else 0)
        # Wrong product
        state_w = (A @ br - K_wrong @ r) % q
        wrong_accepts.append(1 if np.all(state_w == 0) else 0)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    # Running acceptance rate
    window = 100
    correct_running = np.convolve(correct_accepts, np.ones(window)/window, mode='valid')
    wrong_running = np.convolve(wrong_accepts, np.ones(window)/window, mode='valid')

    ax1.plot(correct_running, 'g-', alpha=0.8, label='K = A·B (correct)')
    ax1.plot(wrong_running, 'r-', alpha=0.8, label='K ≠ A·B (wrong)')
    ax1.axhline(y=1.0, color='g', linestyle='--', alpha=0.3)
    ax1.axhline(y=1/q, color='r', linestyle='--', alpha=0.3, label=f'Bound: 1/{q}')
    ax1.set_xlabel('Trial', fontsize=13)
    ax1.set_ylabel('Running acceptance rate', fontsize=13)
    ax1.set_title('Acceptance Rate Over Time', fontsize=14)
    ax1.legend(fontsize=11)
    ax1.set_ylim(-0.05, 1.1)
    ax1.grid(True, alpha=0.3)

    # Histogram of multi-round results
    rounds_list = [1, 2, 3, 5, 10]
    wrong_probs = []
    for k in rounds_list:
        accepts = 0
        for _ in range(trials):
            all_ok = True
            for _ in range(k):
                r = np.random.randint(0, q, p)
                br = (B @ r) % q
                state = (A @ br - K_wrong @ r) % q
                if not np.all(state == 0):
                    all_ok = False
                    break
            if all_ok:
                accepts += 1
        wrong_probs.append(accepts / trials)

    theoretical = [(1/q)**k for k in rounds_list]

    x = np.arange(len(rounds_list))
    width = 0.35
    ax2.bar(x - width/2, wrong_probs, width, label='Empirical', color='salmon')
    ax2.bar(x + width/2, theoretical, width, label='Bound (1/q)^k', color='lightblue')
    ax2.set_xlabel('Number of rounds k', fontsize=13)
    ax2.set_ylabel('False acceptance probability', fontsize=13)
    ax2.set_title('Error Amplification', fontsize=14)
    ax2.set_xticks(x)
    ax2.set_xticklabels(rounds_list)
    ax2.legend(fontsize=11)
    ax2.set_yscale('log')
    ax2.grid(True, alpha=0.3, axis='y')

    fig.tight_layout()
    fig.savefig('viz_acceptance.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")
    b64_hyper = viz_kernel_hyperplane()
    print(f"  Hyperplane: {len(b64_hyper)} chars")
    b64_sound = viz_soundness_scaling()
    print(f"  Soundness: {len(b64_sound)} chars")
    b64_mem = viz_memory_comparison()
    print(f"  Memory: {len(b64_mem)} chars")
    b64_accept = viz_acceptance_distribution()
    print(f"  Acceptance: {len(b64_accept)} chars")
    print("Done! Saved: viz_hyperplane.png, viz_soundness.png, viz_memory.png, viz_acceptance.png")
