#!/usr/bin/env python3
"""
Real-World Applications of Freivalds' Matrix Product Verification

Demonstrates how the theoretical guarantees of Freivalds' algorithm
apply to practical computational scenarios.
"""

import numpy as np
import time
from typing import Tuple


# ============================================================
# Application 1: Verifying GPU/Cloud Matrix Multiplication
# ============================================================
def verify_untrusted_computation(n: int = 200, q: int = 1000003) -> dict:
    """
    Simulate verifying a matrix product computed by an untrusted server.
    
    Scenario: You outsource A*B computation to a cloud server. The server
    returns C. You want to verify C = A*B without redoing the full O(n³) work.
    
    Args:
        n: Matrix dimension.
        q: Prime modulus (larger = lower error probability).
        
    Returns:
        Dictionary with timing and verification results.
    """
    np.random.seed(42)
    
    # Your matrices (the "client" has these)
    A = np.random.randint(0, q, size=(n, n))
    B = np.random.randint(0, q, size=(n, n))
    
    # Server computes the product (possibly incorrectly)
    start = time.time()
    C_server = (A @ B) % q  # Simulate correct computation
    server_time = time.time() - start
    
    # Client verification: Freivalds' check (3 rounds)
    start = time.time()
    all_pass = True
    for round_num in range(3):
        r = np.random.randint(0, q, size=n)
        Br = (B @ r) % q
        ABr = (A @ Br) % q
        Cr = (C_server @ r) % q
        if not np.array_equal(ABr, Cr):
            all_pass = False
            break
    verify_time = time.time() - start
    
    return {
        'matrix_size': n,
        'server_computation_time': server_time,
        'verification_time': verify_time,
        'speedup': server_time / max(verify_time, 1e-10),
        'accepted': all_pass,
        'error_bound': (1/q) ** 3,
    }


# ============================================================
# Application 2: Checking Neural Network Layer Computations
# ============================================================
def verify_neural_network_layer(input_dim: int = 100, output_dim: int = 50,
                                 batch_size: int = 32) -> dict:
    """
    Verify a neural network's linear layer computation.
    
    A linear layer computes Y = W @ X + b. If we focus on the matrix
    multiplication part (Y = W @ X), Freivalds' algorithm can verify
    this without recomputing the full product.
    
    This is relevant for:
    - Verifying inference on untrusted hardware
    - Checking for hardware bit-flip errors in safety-critical systems
    - Auditing ML-as-a-service providers
    
    Note: We work modulo a prime for exact arithmetic. In practice,
    floating-point versions exist with different error analyses.
    """
    q = 104729  # Large prime for low error probability
    np.random.seed(42)
    
    # Weight matrix and input batch
    W = np.random.randint(0, q, size=(output_dim, input_dim))
    X = np.random.randint(0, q, size=(input_dim, batch_size))
    
    # Correct output
    Y_correct = (W @ X) % q
    
    # Simulated corrupted output (single bit flip)
    Y_corrupt = Y_correct.copy()
    Y_corrupt[0, 0] = (Y_corrupt[0, 0] + 1) % q
    
    # Verify both
    results = {}
    for label, Y in [("correct", Y_correct), ("corrupted", Y_corrupt)]:
        r = np.random.randint(0, q, size=batch_size)
        Xr = (X @ r) % q
        WXr = (W @ Xr) % q
        Yr = (Y @ r) % q
        accepted = np.array_equal(WXr, Yr)
        results[label] = accepted
    
    return {
        'weight_shape': (output_dim, input_dim),
        'input_shape': (input_dim, batch_size),
        'correct_accepted': results['correct'],
        'corrupted_rejected': not results['corrupted'],
        'prime_modulus': q,
        'error_bound_per_round': 1 / q,
    }


# ============================================================
# Application 3: Streaming/Online Matrix Verification
# ============================================================
def streaming_product_monitor(n: int = 50, num_products: int = 100,
                               error_rate: float = 0.05) -> dict:
    """
    Monitor a stream of matrix products for computational errors.
    
    Scenario: A system continuously produces matrix products. Some
    fraction are incorrect (due to hardware faults, cosmic rays, etc.).
    Use Freivalds' check as an online monitor.
    
    Args:
        n: Matrix dimension.
        num_products: Number of products to verify.
        error_rate: Fraction of products that are incorrect.
    """
    q = 101
    np.random.seed(42)
    
    detected_errors = 0
    missed_errors = 0
    true_correct = 0
    false_alarms = 0
    
    for i in range(num_products):
        A = np.random.randint(0, q, size=(n, n))
        B = np.random.randint(0, q, size=(n, n))
        C = (A @ B) % q
        
        # Introduce error with probability error_rate
        is_correct = np.random.random() > error_rate
        if not is_correct:
            C[np.random.randint(n), np.random.randint(n)] = (
                C[np.random.randint(n), np.random.randint(n)] + 1
            ) % q
        
        # Run Freivalds check (3 rounds)
        accepted = True
        for _ in range(3):
            r = np.random.randint(0, q, size=n)
            Br = (B @ r) % q
            ABr = (A @ Br) % q
            Cr = (C @ r) % q
            if not np.array_equal(ABr, Cr):
                accepted = False
                break
        
        if is_correct and accepted:
            true_correct += 1
        elif is_correct and not accepted:
            false_alarms += 1  # Should never happen
        elif not is_correct and not accepted:
            detected_errors += 1
        else:  # not is_correct and accepted
            missed_errors += 1
    
    return {
        'total_products': num_products,
        'error_rate': error_rate,
        'true_correct': true_correct,
        'detected_errors': detected_errors,
        'missed_errors': missed_errors,
        'false_alarms': false_alarms,
        'detection_rate': detected_errors / max(detected_errors + missed_errors, 1),
        'theoretical_detection_rate': 1 - (1/q)**3,
    }


# ============================================================
# Application 4: Cryptographic Commitment Verification
# ============================================================
def matrix_commitment_scheme(n: int = 10, q: int = 101) -> dict:
    """
    Demonstrate a simple matrix-based commitment scheme verified by Freivalds.
    
    Alice commits to matrices A, B. Later she reveals A, B, and claims C = A*B.
    Bob can verify the claim efficiently using Freivalds' check.
    
    This models the verification step in matrix-based cryptographic protocols.
    """
    np.random.seed(42)
    
    # Alice's matrices
    A = np.random.randint(0, q, size=(n, n))
    B = np.random.randint(0, q, size=(n, n))
    C_honest = (A @ B) % q
    
    # Dishonest Alice tries to cheat
    C_cheat = np.random.randint(0, q, size=(n, n))
    
    # Bob verifies (5 rounds for high confidence)
    def bob_verify(A, B, C, rounds=5):
        for _ in range(rounds):
            r = np.random.randint(0, q, size=n)
            Br = (B @ r) % q
            ABr = (A @ Br) % q
            Cr = (C @ r) % q
            if not np.array_equal(ABr, Cr):
                return False
        return True
    
    return {
        'honest_accepted': bob_verify(A, B, C_honest),
        'cheat_rejected': not bob_verify(A, B, C_cheat),
        'rounds': 5,
        'error_bound': (1/q) ** 5,
        'security_bits': -5 * np.log2(1/q),
    }


# ============================================================
# Main: Run all applications
# ============================================================
if __name__ == "__main__":
    print("=" * 65)
    print("Real-World Applications of Freivalds' Algorithm")
    print("=" * 65)
    
    # Application 1
    print("\n--- Application 1: Cloud Computation Verification ---")
    result = verify_untrusted_computation(n=200)
    print(f"Matrix size: {result['matrix_size']}×{result['matrix_size']}")
    print(f"Server computation time: {result['server_computation_time']:.4f}s")
    print(f"Verification time (3 rounds): {result['verification_time']:.4f}s")
    print(f"Speedup: {result['speedup']:.1f}×")
    print(f"Accepted: {result['accepted']}")
    print(f"Error bound: {result['error_bound']:.2e}")
    
    # Application 2
    print("\n--- Application 2: Neural Network Layer Verification ---")
    result = verify_neural_network_layer()
    print(f"Weight matrix: {result['weight_shape']}")
    print(f"Input batch: {result['input_shape']}")
    print(f"Correct computation accepted: {result['correct_accepted']}")
    print(f"Corrupted computation rejected: {result['corrupted_rejected']}")
    print(f"Error bound per round: {result['error_bound_per_round']:.2e}")
    
    # Application 3
    print("\n--- Application 3: Streaming Product Monitor ---")
    result = streaming_product_monitor()
    print(f"Total products monitored: {result['total_products']}")
    print(f"True error rate: {result['error_rate']}")
    print(f"Errors detected: {result['detected_errors']}")
    print(f"Errors missed: {result['missed_errors']}")
    print(f"False alarms: {result['false_alarms']}")
    print(f"Detection rate: {result['detection_rate']:.4f}")
    print(f"Theoretical detection rate: {result['theoretical_detection_rate']:.4f}")
    
    # Application 4
    print("\n--- Application 4: Cryptographic Commitment Verification ---")
    result = matrix_commitment_scheme()
    print(f"Honest Alice accepted: {result['honest_accepted']}")
    print(f"Cheating Alice rejected: {result['cheat_rejected']}")
    print(f"Verification rounds: {result['rounds']}")
    print(f"Security bits: {result['security_bits']:.1f}")
    print(f"Error bound: {result['error_bound']:.2e}")
    
    print("\n" + "=" * 65)
    print("All applications demonstrated successfully!")
    print("=" * 65)


#!/usr/bin/env python3
"""
Freivalds' Algorithm: Interactive Demonstrations

Demonstrates the key theorems with concrete numerical examples,
showing how randomized matrix product verification works in practice.
"""

import numpy as np
from typing import Tuple

def mod_matrix_mul(A: np.ndarray, B: np.ndarray, q: int) -> np.ndarray:
    """Multiply two matrices modulo q."""
    return (A @ B) % q

def freivalds_check(A: np.ndarray, B: np.ndarray, C: np.ndarray, q: int, r: np.ndarray) -> bool:
    """
    Perform one round of Freivalds' check: verify if (A*B)*r == C*r mod q.
    Returns True if the check passes (accept), False if it fails (reject).
    """
    # Compute B*r first (cheaper: n^2 instead of n^3)
    Br = (B @ r) % q
    ABr = (A @ Br) % q
    Cr = (C @ r) % q
    return np.array_equal(ABr, Cr)

def freivalds_repeated(A: np.ndarray, B: np.ndarray, C: np.ndarray, q: int, t: int) -> bool:
    """
    Perform t independent rounds of Freivalds' check.
    Returns True only if ALL rounds pass.
    """
    n = A.shape[0]
    for _ in range(t):
        r = np.random.randint(0, q, size=n)
        if not freivalds_check(A, B, C, q, r):
            return False
    return True

def count_false_accepts(A: np.ndarray, B: np.ndarray, C: np.ndarray, q: int) -> Tuple[int, int]:
    """
    Exhaustively count the number of vectors r for which (A*B)*r == C*r mod q.
    Returns (false_accept_count, total_count).
    Only feasible for small n and q.
    """
    n = A.shape[0]
    total = q ** n
    false_accepts = 0
    
    # Enumerate all vectors in F_q^n
    for idx in range(total):
        r = np.zeros(n, dtype=int)
        temp = idx
        for i in range(n):
            r[i] = temp % q
            temp //= q
        if freivalds_check(A, B, C, q, r):
            false_accepts += 1
    
    return false_accepts, total

# ============================================================
# Demo 1: Basic Freivalds check with correct product
# ============================================================
print("=" * 60)
print("DEMO 1: Freivalds check on a CORRECT product")
print("=" * 60)

q = 7  # Working modulo 7
n = 3

np.random.seed(42)
A = np.random.randint(0, q, size=(n, n))
B = np.random.randint(0, q, size=(n, n))
C = mod_matrix_mul(A, B, q)  # C = A*B (correct)

print(f"\nField: F_{q}")
print(f"Matrix size: {n}x{n}")
print(f"\nA =\n{A}")
print(f"\nB =\n{B}")
print(f"\nC = A*B =\n{C}")

# Run 10 independent checks
print("\nRunning 10 independent Freivalds checks on correct product:")
for i in range(10):
    r = np.random.randint(0, q, size=n)
    result = freivalds_check(A, B, C, q, r)
    print(f"  Round {i+1}: r = {r}, accept = {result}")

print("\nAll checks pass (as guaranteed for correct products).")

# ============================================================
# Demo 2: Freivalds check on INCORRECT product
# ============================================================
print("\n" + "=" * 60)
print("DEMO 2: Freivalds check on an INCORRECT product")
print("=" * 60)

# Introduce a single-entry error
C_wrong = C.copy()
C_wrong[0, 0] = (C_wrong[0, 0] + 1) % q

print(f"\nC_wrong (one entry changed) =\n{C_wrong}")
print(f"A*B ≠ C_wrong: {not np.array_equal(mod_matrix_mul(A, B, q), C_wrong)}")

# Run checks
print("\nRunning 20 independent Freivalds checks on incorrect product:")
accepts = 0
for i in range(20):
    r = np.random.randint(0, q, size=n)
    result = freivalds_check(A, B, C_wrong, q, r)
    if result:
        accepts += 1
    print(f"  Round {i+1}: r = {r}, accept = {result}")

print(f"\nFalse accepts: {accepts}/20")
print(f"Theoretical bound: ≤ 1/q = 1/{q} ≈ {1/q:.4f}")
print(f"Observed rate: {accepts/20:.4f}")

# ============================================================
# Demo 3: Exhaustive counting (small case)
# ============================================================
print("\n" + "=" * 60)
print("DEMO 3: Exhaustive verification of the counting bound")
print("=" * 60)

q = 5
n = 2

np.random.seed(123)
A = np.random.randint(0, q, size=(n, n))
B = np.random.randint(0, q, size=(n, n))
C = mod_matrix_mul(A, B, q)

# Wrong product
C_wrong = C.copy()
C_wrong[0, 0] = (C_wrong[0, 0] + 1) % q

print(f"\nField: F_{q}, dimension: {n}")
print(f"Total vectors: q^n = {q}^{n} = {q**n}")
print(f"Bound: q^(n-1) = {q}^{n-1} = {q**(n-1)}")

false_accepts, total = count_false_accepts(A, B, C_wrong, q)

print(f"\nExhaustive count of false accepts: {false_accepts}")
print(f"Total vectors: {total}")
print(f"Theoretical upper bound: {q**(n-1)}")
print(f"Bound holds: {false_accepts <= q**(n-1)}")
print(f"False accept probability: {false_accepts}/{total} = {false_accepts/total:.4f}")
print(f"Theoretical bound: 1/{q} = {1/q:.4f}")

# ============================================================
# Demo 4: Effect of field size on error probability
# ============================================================
print("\n" + "=" * 60)
print("DEMO 4: How field size affects error probability")
print("=" * 60)

n = 3
primes = [2, 3, 5, 7, 11, 13]
num_trials = 10000

print(f"\nMatrix size: {n}x{n}")
print(f"Trials per prime: {num_trials}")
print(f"\n{'Prime q':>8} {'1/q':>10} {'Observed':>10} {'Bound holds':>12}")
print("-" * 44)

for q in primes:
    np.random.seed(42)
    A = np.random.randint(0, q, size=(n, n))
    B = np.random.randint(0, q, size=(n, n))
    C = mod_matrix_mul(A, B, q)
    C_wrong = C.copy()
    C_wrong[0, 0] = (C_wrong[0, 0] + 1) % q
    
    accepts = sum(
        freivalds_check(A, B, C_wrong, q, np.random.randint(0, q, size=n))
        for _ in range(num_trials)
    )
    observed = accepts / num_trials
    bound = 1 / q
    
    print(f"{q:>8} {bound:>10.4f} {observed:>10.4f} {str(observed <= bound + 0.02):>12}")

# ============================================================
# Demo 5: Amplification by repetition
# ============================================================
print("\n" + "=" * 60)
print("DEMO 5: Error probability drops exponentially with repetition")
print("=" * 60)

q = 3
n = 4
max_reps = 8
num_trials = 50000

np.random.seed(42)
A = np.random.randint(0, q, size=(n, n))
B = np.random.randint(0, q, size=(n, n))
C = mod_matrix_mul(A, B, q)
C_wrong = C.copy()
C_wrong[1, 1] = (C_wrong[1, 1] + 1) % q

print(f"\nField: F_{q}, Matrix size: {n}x{n}")
print(f"Trials: {num_trials}")
print(f"\n{'Reps t':>8} {'Bound (1/q)^t':>15} {'Observed':>10}")
print("-" * 36)

for t in range(1, max_reps + 1):
    accepts = sum(
        freivalds_repeated(A, B, C_wrong, q, t)
        for _ in range(num_trials)
    )
    observed = accepts / num_trials
    bound = (1/q) ** t
    print(f"{t:>8} {bound:>15.6f} {observed:>10.6f}")

# ============================================================
# Demo 6: Kernel structure visualization
# ============================================================
print("\n" + "=" * 60)
print("DEMO 6: Kernel structure of the disagreement matrix")
print("=" * 60)

q = 5
n = 3

# Create a rank-1 disagreement matrix (worst case)
D = np.zeros((n, n), dtype=int)
D[0, :] = [1, 2, 3]  # Only first row is nonzero

print(f"\nDisagreement matrix D (rank 1) =\n{D}")
print(f"Kernel dimension should be n-1 = {n-1}")
print(f"Expected kernel size: q^(n-1) = {q**(n-1)}")

# Count kernel vectors
kernel_vectors = []
for idx in range(q**n):
    r = np.zeros(n, dtype=int)
    temp = idx
    for i in range(n):
        r[i] = temp % q
        temp //= q
    if np.array_equal((D @ r) % q, np.zeros(n, dtype=int)):
        kernel_vectors.append(r.copy())

print(f"Actual kernel size: {len(kernel_vectors)}")
print(f"Bound is tight: {len(kernel_vectors) == q**(n-1)}")
print(f"\nKernel vectors (first 10):")
for v in kernel_vectors[:10]:
    print(f"  {v}  (check: D·v = {(D @ v) % q})")

print(f"\n... and {max(0, len(kernel_vectors)-10)} more.")

print("\n" + "=" * 60)
print("All demos completed successfully!")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualizations for Freivalds' Algorithm

Generates publication-quality figures illustrating the key mathematical
concepts and empirical behavior of the algorithm.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import base64
import io
import json


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64-encoded PNG data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight', 
                facecolor='white', edgecolor='none')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def plot_error_vs_field_size():
    """Plot false accept probability vs field size q."""
    fig, ax = plt.subplots(figsize=(8, 5))
    
    primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]
    theoretical = [1/q for q in primes]
    
    # Empirical measurement
    n = 4
    num_trials = 20000
    empirical = []
    
    for q in primes:
        np.random.seed(42)
        A = np.random.randint(0, q, size=(n, n))
        B = np.random.randint(0, q, size=(n, n))
        C = (A @ B) % q
        C_wrong = C.copy()
        C_wrong[0, 0] = (C_wrong[0, 0] + 1) % q
        
        accepts = 0
        for _ in range(num_trials):
            r = np.random.randint(0, q, size=n)
            Br = (B @ r) % q
            ABr = (A @ Br) % q
            Cr = (C_wrong @ r) % q
            if np.array_equal(ABr, Cr):
                accepts += 1
        empirical.append(accepts / num_trials)
    
    ax.plot(primes, theoretical, 'b-o', linewidth=2, markersize=8, 
            label='Theoretical bound: 1/q', zorder=3)
    ax.plot(primes, empirical, 'r--s', linewidth=1.5, markersize=6, 
            label='Empirical false accept rate', zorder=3)
    
    ax.set_xlabel('Field size q (prime)', fontsize=13)
    ax.set_ylabel('False accept probability', fontsize=13)
    ax.set_title('Freivalds\' Error Probability vs. Field Size', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.set_ylim(bottom=0)
    ax.grid(True, alpha=0.3)
    
    return fig_to_base64(fig)


def plot_amplification():
    """Plot error probability decay with repeated checks."""
    fig, ax = plt.subplots(figsize=(8, 5))
    
    q_values = [2, 3, 5, 7, 11]
    max_t = 15
    ts = range(1, max_t + 1)
    
    colors = plt.cm.viridis(np.linspace(0.1, 0.9, len(q_values)))
    
    for q, color in zip(q_values, colors):
        probs = [(1/q)**t for t in ts]
        ax.semilogy(list(ts), probs, '-o', color=color, linewidth=2, markersize=5,
                    label=f'q = {q}')
    
    ax.set_xlabel('Number of rounds t', fontsize=13)
    ax.set_ylabel('False accept probability (log scale)', fontsize=13)
    ax.set_title('Exponential Error Decay with Repetition', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11, title='Field size')
    ax.grid(True, alpha=0.3, which='both')
    ax.set_xlim(0.5, max_t + 0.5)
    
    return fig_to_base64(fig)


def plot_kernel_heatmap():
    """Visualize kernel structure for a small example."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 4.5))
    
    q = 5
    n = 2
    
    # Three disagreement matrices with different ranks
    matrices = [
        (np.array([[1, 0], [0, 0]]), "Rank 1 (worst case)"),
        (np.array([[1, 0], [0, 1]]), "Rank 2 (identity)"),
        (np.array([[1, 2], [3, 1]]), "Rank 2 (generic)"),
    ]
    
    for ax, (D, title) in zip(axes, matrices):
        # Create heatmap of ||D*r|| for all r in F_q^2
        grid = np.zeros((q, q))
        for x in range(q):
            for y in range(q):
                r = np.array([x, y])
                result = (D @ r) % q
                grid[y, x] = 0 if np.all(result == 0) else 1
        
        im = ax.imshow(grid, cmap='RdYlGn_r', origin='lower', 
                       extent=[-0.5, q-0.5, -0.5, q-0.5])
        ax.set_xlabel('r₁', fontsize=11)
        ax.set_ylabel('r₂', fontsize=11)
        ax.set_title(f'{title}\nKernel size: {int((grid == 0).sum())}', fontsize=11)
        ax.set_xticks(range(q))
        ax.set_yticks(range(q))
        
        # Mark kernel vectors
        for x in range(q):
            for y in range(q):
                if grid[y, x] == 0:
                    ax.plot(x, y, 'ko', markersize=8, markerfacecolor='lime')
    
    fig.suptitle(f'Kernel Structure in F_{q}² (green = kernel)', 
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    
    return fig_to_base64(fig)


def plot_speedup_comparison():
    """Plot O(n³) vs O(n²) computational cost comparison."""
    fig, ax = plt.subplots(figsize=(8, 5))
    
    ns = np.arange(10, 1001, 10)
    direct_cost = ns ** 3
    freivalds_cost = 2 * ns ** 2  # Two matrix-vector multiplications
    freivalds_3round = 6 * ns ** 2  # Three rounds
    
    ax.loglog(ns, direct_cost, 'b-', linewidth=2.5, label='Direct: O(n³)')
    ax.loglog(ns, freivalds_cost, 'r-', linewidth=2.5, label='Freivalds (1 round): O(n²)')
    ax.loglog(ns, freivalds_3round, 'r--', linewidth=1.5, label='Freivalds (3 rounds): O(n²)')
    
    ax.fill_between(ns, freivalds_cost, direct_cost, alpha=0.15, color='green')
    ax.annotate('Savings from\nrandomization', xy=(200, 200**2.5), fontsize=12,
                ha='center', color='green', fontweight='bold')
    
    ax.set_xlabel('Matrix dimension n', fontsize=13)
    ax.set_ylabel('Number of operations', fontsize=13)
    ax.set_title('Verification Cost: Direct vs. Freivalds', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3, which='both')
    
    return fig_to_base64(fig)


def plot_codimension_illustration():
    """Illustrate the codimension-one phenomenon."""
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    
    # Left: 2D illustration (line in a plane)
    ax = axes[0]
    q = 7
    
    # All points in F_7^2
    all_x, all_y = [], []
    ker_x, ker_y = [], []
    
    # Linear form: 2x + 3y = 0 mod 7
    for x in range(q):
        for y in range(q):
            all_x.append(x)
            all_y.append(y)
            if (2*x + 3*y) % q == 0:
                ker_x.append(x)
                ker_y.append(y)
    
    ax.scatter(all_x, all_y, c='lightblue', s=40, zorder=2, label=f'All of F_{q}² ({q**2} pts)')
    ax.scatter(ker_x, ker_y, c='red', s=80, zorder=3, marker='D', 
               label=f'Kernel ({len(ker_x)} pts)')
    
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('y', fontsize=12)
    ax.set_title(f'Kernel of 2x+3y over F_{q}\n'
                 f'{len(ker_x)}/{q**2} = {len(ker_x)/q**2:.3f} ≤ 1/{q} = {1/q:.3f}',
                 fontsize=11)
    ax.legend(fontsize=9, loc='upper right')
    ax.set_xlim(-0.5, q-0.5)
    ax.set_ylim(-0.5, q-0.5)
    ax.grid(True, alpha=0.2)
    
    # Right: Bar chart of kernel fraction for different dimensions
    ax = axes[1]
    dims = [2, 3, 4, 5]
    q = 3
    
    fractions = []
    bounds = []
    for n in dims:
        # Count kernel of a nonzero linear form
        total = q ** n
        ker_size = q ** (n - 1)  # Exact for a single nonzero linear form
        fractions.append(ker_size / total)
        bounds.append(1 / q)
    
    x_pos = np.arange(len(dims))
    bars = ax.bar(x_pos, fractions, 0.5, color='steelblue', alpha=0.8, 
                  label='Kernel fraction = q^(n-1)/q^n')
    ax.axhline(y=1/q, color='red', linestyle='--', linewidth=2, label=f'Bound: 1/q = 1/{q}')
    
    ax.set_xlabel('Dimension n', fontsize=12)
    ax.set_ylabel('Kernel fraction', fontsize=12)
    ax.set_title(f'Kernel Fraction is Always 1/q\n(for rank-1 matrix over F_{q})', fontsize=11)
    ax.set_xticks(x_pos)
    ax.set_xticklabels([f'n={d}' for d in dims])
    ax.legend(fontsize=9)
    ax.set_ylim(0, 0.5)
    
    fig.suptitle('The Codimension-One Phenomenon', fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")
    
    viz_data = {}
    
    print("  1/5: Error vs field size...")
    viz_data['error_vs_field_size'] = plot_error_vs_field_size()
    
    print("  2/5: Amplification...")
    viz_data['amplification'] = plot_amplification()
    
    print("  3/5: Kernel heatmap...")
    viz_data['kernel_heatmap'] = plot_kernel_heatmap()
    
    print("  4/5: Speedup comparison...")
    viz_data['speedup'] = plot_speedup_comparison()
    
    print("  5/5: Codimension illustration...")
    viz_data['codimension'] = plot_codimension_illustration()
    
    # Save base64 data for use in PACKAGE.json
    with open('viz_data.json', 'w') as f:
        json.dump(viz_data, f)
    
    print("All visualizations generated and saved to viz_data.json")
