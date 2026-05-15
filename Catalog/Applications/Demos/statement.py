#!/usr/bin/env python3
"""
Applications of Freivalds' Theorem and Hyperplane Counting

Demonstrates real-world applications:
1. Verifiable outsourced matrix computation
2. Polynomial identity testing (degree-1 case)
3. Linear code distance verification
4. Communication-efficient equality testing
"""

import numpy as np
import random
from typing import List, Tuple


class GFq:
    """Arithmetic over GF(q) for prime q."""
    def __init__(self, q: int):
        self.q = q
    
    def matvec(self, M: np.ndarray, v: np.ndarray) -> np.ndarray:
        return (M @ v) % self.q
    
    def matmul(self, A: np.ndarray, B: np.ndarray) -> np.ndarray:
        return (A @ B) % self.q
    
    def random_vector(self, n: int) -> np.ndarray:
        return np.array([random.randint(0, self.q - 1) for _ in range(n)])


# ============================================================
# Application 1: Verifiable Outsourced Computation
# ============================================================
def demo_outsourced_computation():
    """
    Scenario: A client outsources matrix multiplication to an untrusted server.
    The client verifies the result using Freivalds' algorithm.
    
    Cost comparison:
    - Client verification: O(n^2) operations
    - Direct computation: O(n^3) operations
    - Savings: O(n) factor
    """
    print("=" * 60)
    print("APPLICATION 1: Verifiable Outsourced Matrix Computation")
    print("=" * 60)
    print()
    
    q = 1000000007  # Large prime
    n = 100
    gf = GFq(q)
    
    # Client has matrices A, B
    A = np.random.randint(0, 1000, (n, n))
    B = np.random.randint(0, 1000, (n, n))
    
    # Server computes (possibly incorrectly)
    K_honest = gf.matmul(A, B)
    K_cheating = K_honest.copy()
    # Cheating server modifies a few entries
    for _ in range(5):
        i, j = random.randint(0, n-1), random.randint(0, n-1)
        K_cheating[i, j] = (K_cheating[i, j] + random.randint(1, q-1)) % q
    
    # Client verification (5 rounds, error <= (1/q)^5 ≈ 10^{-45})
    num_rounds = 5
    
    print(f"Matrix size: {n}x{n} over GF({q})")
    print(f"Verification rounds: {num_rounds}")
    print(f"Error bound: (1/{q})^{num_rounds} ≈ 10^{-9*num_rounds}")
    print()
    
    # Verify honest server
    honest_detected = False
    for _ in range(num_rounds):
        r = gf.random_vector(n)
        if not np.array_equal(gf.matvec(K_honest, r), gf.matvec(A, gf.matvec(B, r))):
            honest_detected = True
            break
    print(f"Honest server detected as cheating: {honest_detected} (should be False)")
    
    # Verify cheating server
    cheating_detected = False
    for _ in range(num_rounds):
        r = gf.random_vector(n)
        if not np.array_equal(gf.matvec(K_cheating, r), gf.matvec(A, gf.matvec(B, r))):
            cheating_detected = True
            break
    print(f"Cheating server detected: {cheating_detected} (should be True)")
    print()


# ============================================================
# Application 2: Polynomial Identity Testing (Linear Case)
# ============================================================
def demo_polynomial_identity_testing():
    """
    Freivalds' theorem is the degree-1 case of PIT.
    
    Given a linear polynomial f(x_1, ..., x_p) = sum(a_i * x_i),
    test whether f is identically zero by evaluating at a random point.
    
    Pr[f(r) = 0 | f != 0] <= 1/q
    """
    print("=" * 60)
    print("APPLICATION 2: Polynomial Identity Testing (Degree 1)")
    print("=" * 60)
    print()
    
    q = 101
    p = 10
    num_trials = 100000
    
    # Case 1: Zero polynomial
    coeffs_zero = np.zeros(p, dtype=int)
    zero_evals = 0
    for _ in range(num_trials):
        r = np.array([random.randint(0, q-1) for _ in range(p)])
        if sum(coeffs_zero[i] * r[i] for i in range(p)) % q == 0:
            zero_evals += 1
    print(f"Zero polynomial: fraction evaluating to 0 = {zero_evals/num_trials:.4f} (should be 1.0)")
    
    # Case 2: Nonzero polynomial
    coeffs_nonzero = np.array([random.randint(1, q-1)] + 
                               [random.randint(0, q-1) for _ in range(p-1)])
    zero_evals = 0
    for _ in range(num_trials):
        r = np.array([random.randint(0, q-1) for _ in range(p)])
        if sum(coeffs_nonzero[i] * r[i] for i in range(p)) % q == 0:
            zero_evals += 1
    
    print(f"Nonzero polynomial: fraction evaluating to 0 = {zero_evals/num_trials:.4f} (should be ≈ {1/q:.4f})")
    print(f"Theoretical bound: 1/{q} = {1/q:.4f}")
    print()


# ============================================================
# Application 3: Communication-Efficient Equality Testing
# ============================================================
def demo_equality_testing():
    """
    Two parties, Alice and Bob, each hold a vector in GF(q)^n.
    They want to check equality using minimal communication.
    
    Protocol (based on Freivalds/fingerprinting):
    1. Shared random seed -> random vector w in GF(q)^p
    2. Alice sends <w, a> (one field element)
    3. Bob checks <w, b> = Alice's value
    
    Communication: O(log q) bits
    Error: <= 1/q
    """
    print("=" * 60)
    print("APPLICATION 3: Communication-Efficient Equality Testing")
    print("=" * 60)
    print()
    
    q = 1000000007
    n = 10000  # Large vectors
    num_trials = 50000
    
    # Case 1: Equal vectors
    a = np.array([random.randint(0, q-1) for _ in range(n)])
    b = a.copy()
    
    false_rejections = 0
    for _ in range(num_trials):
        w = np.array([random.randint(0, q-1) for _ in range(n)])
        fingerprint_a = int(np.sum(a.astype(np.int64) * w.astype(np.int64))) % q
        fingerprint_b = int(np.sum(b.astype(np.int64) * w.astype(np.int64))) % q
        if fingerprint_a != fingerprint_b:
            false_rejections += 1
    
    print(f"Equal vectors (n={n}):")
    print(f"  False rejection rate: {false_rejections/num_trials:.6f} (should be 0)")
    
    # Case 2: Vectors differing in one coordinate
    b_diff = a.copy()
    b_diff[0] = (b_diff[0] + 1) % q
    
    false_accepts = 0
    for _ in range(num_trials):
        w = np.array([random.randint(0, q-1) for _ in range(n)])
        fingerprint_a = int(np.sum(a.astype(np.int64) * w.astype(np.int64))) % q
        fingerprint_b = int(np.sum(b_diff.astype(np.int64) * w.astype(np.int64))) % q
        if fingerprint_a == fingerprint_b:
            false_accepts += 1
    
    print(f"Different vectors (1 coordinate differs):")
    print(f"  False accept rate: {false_accepts/num_trials:.6f} (should be ≈ {1/q:.9f})")
    print(f"  Communication: {len(bin(q))-2} bits per check (vs {n * (len(bin(q))-2)} bits to send full vector)")
    print()


# ============================================================
# Application 4: Error Detection in Linear Codes
# ============================================================
def demo_linear_code_error_detection():
    """
    A single parity-check code over GF(q):
    Codewords are {r in GF(q)^p : <w, r> = 0} for a nonzero w.
    
    Code rate: (p-1)/p
    Minimum distance: 2 (can detect any single-symbol error)
    Fraction of valid codewords: 1/q (= hyperplane density)
    """
    print("=" * 60)
    print("APPLICATION 4: Error Detection via Linear Codes")
    print("=" * 60)
    print()
    
    q = 7
    p = 6
    
    # Random parity-check vector
    w = np.array([random.randint(1, q-1)] + [random.randint(0, q-1) for _ in range(p-1)])
    
    print(f"Single parity-check code over GF({q}), length {p}")
    print(f"Parity-check vector: w = {w.tolist()}")
    print(f"Code rate: {p-1}/{p} = {(p-1)/p:.3f}")
    print(f"Codeword density: 1/{q} = {1/q:.4f}")
    print()
    
    # Count codewords
    codeword_count = 0
    total = q ** p
    for code in range(total):
        r = []
        val = code
        for _ in range(p):
            r.append(val % q)
            val //= q
        if sum(w[i] * r[i] for i in range(p)) % q == 0:
            codeword_count += 1
    
    print(f"Total vectors: {total}")
    print(f"Codewords: {codeword_count}")
    print(f"Expected (q^(p-1)): {q**(p-1)}")
    print(f"Density: {codeword_count/total:.4f} (expected: {1/q:.4f})")
    print()
    
    # Error detection demonstration
    print("Error detection test:")
    codeword = np.array([random.randint(0, q-1) for _ in range(p-1)] + [0])
    # Solve for last coordinate to make it a codeword
    partial_sum = sum(w[i] * codeword[i] for i in range(p-1)) % q
    codeword[p-1] = (q - partial_sum * pow(w[p-1], q-2, q)) % q
    
    syndrome = sum(w[i] * codeword[i] for i in range(p)) % q
    print(f"  Valid codeword: {codeword.tolist()}, syndrome = {syndrome}")
    
    # Introduce error
    error_pos = 2
    corrupted = codeword.copy()
    corrupted[error_pos] = (corrupted[error_pos] + 1) % q
    syndrome_err = sum(w[i] * corrupted[i] for i in range(p)) % q
    print(f"  Corrupted:      {corrupted.tolist()}, syndrome = {syndrome_err} ({'detected!' if syndrome_err != 0 else 'missed!'})")
    print()


if __name__ == "__main__":
    random.seed(42)
    np.random.seed(42)
    
    demo_outsourced_computation()
    demo_polynomial_identity_testing()
    demo_equality_testing()
    demo_linear_code_error_detection()


#!/usr/bin/env python3
"""
Freivalds' Matrix Verification Algorithm: Demonstrations and Experiments

This script demonstrates the key theorems formalized in the project:
1. Exact hyperplane counting over finite fields
2. Freivalds' algorithm for matrix product verification
3. Soundness amplification through repeated trials
"""

import random
import numpy as np
from typing import List, Tuple


def mod_matrix_mul(A: np.ndarray, B: np.ndarray, q: int) -> np.ndarray:
    """Multiply matrices over GF(q)."""
    return (A @ B) % q


def mod_matvec(M: np.ndarray, v: np.ndarray, q: int) -> np.ndarray:
    """Matrix-vector product over GF(q)."""
    return (M @ v) % q


def freivalds_check(A: np.ndarray, B: np.ndarray, K: np.ndarray, q: int) -> bool:
    """
    Freivalds' randomized matrix product verification.
    
    Returns True if K passes the check (K might equal A*B).
    Returns False if K definitely does not equal A*B.
    
    Error probability: at most 1/q when K != A*B.
    """
    p = K.shape[1]
    r = np.array([random.randint(0, q - 1) for _ in range(p)])
    lhs = mod_matvec(K, r, q)
    rhs = mod_matvec(A, mod_matvec(B, r, q), q)
    return np.array_equal(lhs, rhs)


def count_hyperplane_solutions(w: np.ndarray, b: int, q: int) -> int:
    """
    Count solutions to dot(w, r) = b over GF(q) by exhaustive enumeration.
    
    For small p and q, this verifies the theorem:
    |{r : GF(q)^p | <w, r> = b}| = q^(p-1) when w != 0.
    """
    p = len(w)
    count = 0
    # Enumerate all vectors in GF(q)^p
    for code in range(q ** p):
        r = []
        val = code
        for _ in range(p):
            r.append(val % q)
            val //= q
        if sum(w[i] * r[i] for i in range(p)) % q == b:
            count += 1
    return count


def count_kernel_solutions(M: np.ndarray, q: int) -> int:
    """
    Count solutions to M*r = 0 over GF(q) by exhaustive enumeration.
    """
    m, p = M.shape
    count = 0
    for code in range(q ** p):
        r = []
        val = code
        for _ in range(p):
            r.append(val % q)
            val //= q
        r = np.array(r)
        if np.all(mod_matvec(M, r, q) == 0):
            count += 1
    return count


# ============================================================
# Demo 1: Exact Hyperplane Counting
# ============================================================
def demo_hyperplane_counting():
    """Verify that |{r | <w,r> = b}| = q^(p-1) for nonzero w."""
    print("=" * 60)
    print("DEMO 1: Exact Hyperplane Counting over Finite Fields")
    print("=" * 60)
    print()
    print("Theorem: For nonzero w in GF(q)^p and any b in GF(q),")
    print("  |{r in GF(q)^p : <w, r> = b}| = q^(p-1)")
    print()
    
    test_cases = [
        (2, 3), (2, 4), (3, 3), (5, 3), (7, 2), (3, 4)
    ]
    
    print(f"{'q':>4} {'p':>4} {'w':>15} {'b':>4} {'count':>8} {'q^(p-1)':>8} {'match':>6}")
    print("-" * 55)
    
    all_pass = True
    for q, p in test_cases:
        # Random nonzero vector
        w = np.array([random.randint(0, q - 1) for _ in range(p)])
        while np.all(w == 0):
            w = np.array([random.randint(0, q - 1) for _ in range(p)])
        
        for b in [0, 1]:
            count = count_hyperplane_solutions(w, b, q)
            expected = q ** (p - 1)
            match = count == expected
            all_pass = all_pass and match
            print(f"{q:4d} {p:4d} {str(w.tolist()):>15} {b:4d} {count:8d} {expected:8d} {'✓' if match else '✗':>6}")
    
    print()
    print(f"All tests passed: {'YES' if all_pass else 'NO'}")
    print()


# ============================================================
# Demo 2: Kernel Counting for Matrices
# ============================================================
def demo_kernel_counting():
    """Verify that |{r | M*r = 0}| <= q^(p-1) for nonzero M."""
    print("=" * 60)
    print("DEMO 2: Kernel Counting for Nonzero Matrices")
    print("=" * 60)
    print()
    print("Theorem: For nonzero M in GF(q)^{m x p},")
    print("  |{r in GF(q)^p : M*r = 0}| <= q^(p-1)")
    print()
    
    test_cases = [
        (2, 2, 3), (2, 3, 3), (3, 2, 3), (5, 2, 2), (2, 3, 4)
    ]
    
    print(f"{'q':>4} {'m':>4} {'p':>4} {'rank(M)':>8} {'|ker|':>8} {'q^(p-1)':>8} {'q^(p-rank)':>10} {'<=bound':>8}")
    print("-" * 60)
    
    for q, m, p in test_cases:
        # Random nonzero matrix
        M = np.array([[random.randint(0, q - 1) for _ in range(p)] for _ in range(m)])
        while np.all(M == 0):
            M = np.array([[random.randint(0, q - 1) for _ in range(p)] for _ in range(m)])
        
        ker_size = count_kernel_solutions(M, q)
        bound = q ** (p - 1)
        
        # Estimate rank over GF(q) (crude: use numpy rank as approximation)
        # For exact rank we'd need proper GF(q) linear algebra
        est_rank = min(m, p)  # upper bound
        
        print(f"{q:4d} {m:4d} {p:4d} {'≤'+str(est_rank):>8} {ker_size:8d} {bound:8d} {'':>10} {'✓' if ker_size <= bound else '✗':>8}")
    
    print()


# ============================================================
# Demo 3: Freivalds' Algorithm Error Rate
# ============================================================
def demo_freivalds_error_rate():
    """Measure empirical error rate of Freivalds' algorithm."""
    print("=" * 60)
    print("DEMO 3: Freivalds' Algorithm - Error Rate vs Field Size")
    print("=" * 60)
    print()
    print("Setup: Random 5x5 matrices A, B over GF(q).")
    print("K = A*B with one entry perturbed (so K != A*B).")
    print("Measure false acceptance rate over 50,000 trials.")
    print()
    
    primes = [2, 3, 5, 7, 11, 13, 17, 23, 31, 101]
    n = 5
    num_trials = 50000
    
    print(f"{'q':>6} {'1/q':>10} {'empirical':>10} {'ratio':>8}")
    print("-" * 38)
    
    for q in primes:
        # Generate random matrices
        A = np.array([[random.randint(0, q - 1) for _ in range(n)] for _ in range(n)])
        B = np.array([[random.randint(0, q - 1) for _ in range(n)] for _ in range(n)])
        K = mod_matrix_mul(A, B, q)
        
        # Perturb one entry
        K[0, 0] = (K[0, 0] + 1) % q
        
        # Run trials
        false_accepts = sum(1 for _ in range(num_trials) if freivalds_check(A, B, K, q))
        empirical_rate = false_accepts / num_trials
        theoretical = 1.0 / q
        ratio = empirical_rate / theoretical if theoretical > 0 else float('inf')
        
        print(f"{q:6d} {theoretical:10.6f} {empirical_rate:10.6f} {ratio:8.4f}")
    
    print()
    print("Ratio ≈ 1.0 confirms the theoretical bound is tight.")
    print()


# ============================================================
# Demo 4: Soundness Amplification
# ============================================================
def demo_amplification():
    """Demonstrate exponential error reduction through repeated trials."""
    print("=" * 60)
    print("DEMO 4: Soundness Amplification via Repeated Trials")
    print("=" * 60)
    print()
    print("Setup: GF(2), random 8x8 matrices, K != A*B.")
    print("Run t independent Freivalds checks.")
    print("A false claim passes ALL t checks with prob <= (1/2)^t.")
    print()
    
    q = 2
    n = 8
    num_experiments = 200000
    
    A = np.array([[random.randint(0, q - 1) for _ in range(n)] for _ in range(n)])
    B = np.array([[random.randint(0, q - 1) for _ in range(n)] for _ in range(n)])
    K = mod_matrix_mul(A, B, q)
    K[0, 0] = (K[0, 0] + 1) % q
    
    print(f"{'trials t':>10} {'2^(-t)':>12} {'empirical':>12} {'ratio':>8}")
    print("-" * 45)
    
    for t in [1, 2, 3, 5, 8, 10, 15, 20]:
        false_accepts = 0
        for _ in range(num_experiments):
            if all(freivalds_check(A, B, K, q) for _ in range(t)):
                false_accepts += 1
        
        empirical_rate = false_accepts / num_experiments
        theoretical = 2.0 ** (-t)
        ratio = empirical_rate / theoretical if theoretical > 0 and empirical_rate > 0 else 0
        
        print(f"{t:10d} {theoretical:12.8f} {empirical_rate:12.8f} {ratio:8.4f}")
    
    print()
    print("The error drops exponentially — each trial halves the risk.")
    print()


# ============================================================
# Demo 5: Verification Speed Comparison
# ============================================================
def demo_speed_comparison():
    """Compare direct multiplication vs Freivalds verification speed."""
    import time
    
    print("=" * 60)
    print("DEMO 5: Speed - Direct Multiplication vs Freivalds Check")
    print("=" * 60)
    print()
    
    q = 1000000007  # Large prime
    
    print(f"{'n':>6} {'mult (ms)':>12} {'check (ms)':>12} {'speedup':>10}")
    print("-" * 45)
    
    for n in [50, 100, 200, 500, 1000]:
        A = np.random.randint(0, min(q, 10000), (n, n))
        B = np.random.randint(0, min(q, 10000), (n, n))
        
        # Direct multiplication
        t0 = time.perf_counter()
        K = (A @ B) % q
        t_mult = (time.perf_counter() - t0) * 1000
        
        # Freivalds check (5 rounds)
        r = np.random.randint(0, min(q, 10000), n)
        t0 = time.perf_counter()
        for _ in range(5):
            r = np.random.randint(0, min(q, 10000), n)
            lhs = (K @ r) % q
            rhs = (A @ ((B @ r) % q)) % q
        t_check = (time.perf_counter() - t0) * 1000
        
        speedup = t_mult / t_check if t_check > 0 else float('inf')
        print(f"{n:6d} {t_mult:12.2f} {t_check:12.2f} {speedup:10.1f}x")
    
    print()
    print("Freivalds check is O(n²) vs O(n³) for multiplication → increasing speedup.")
    print()


if __name__ == "__main__":
    random.seed(42)
    np.random.seed(42)
    
    demo_hyperplane_counting()
    demo_kernel_counting()
    demo_freivalds_error_rate()
    demo_amplification()
    demo_speed_comparison()


#!/usr/bin/env python3
"""Generate visualizations for the Freivalds theorem project."""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import random
import base64
import io
import json

random.seed(42)
np.random.seed(42)


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def viz_error_rate_vs_field_size() -> str:
    """Plot empirical vs theoretical error rate as a function of field size."""
    primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]
    n = 5
    num_trials = 20000
    
    empirical_rates = []
    theoretical_rates = [1.0/q for q in primes]
    
    for q in primes:
        A = np.array([[random.randint(0, q-1) for _ in range(n)] for _ in range(n)])
        B = np.array([[random.randint(0, q-1) for _ in range(n)] for _ in range(n)])
        K = (A @ B) % q
        K[0, 0] = (K[0, 0] + 1) % q
        
        false_accepts = 0
        for _ in range(num_trials):
            r = np.array([random.randint(0, q-1) for _ in range(n)])
            lhs = (K @ r) % q
            rhs = (A @ ((B @ r) % q)) % q
            if np.array_equal(lhs, rhs):
                false_accepts += 1
        empirical_rates.append(false_accepts / num_trials)
    
    fig, ax = plt.subplots(figsize=(10, 6))
    ax.plot(primes, theoretical_rates, 'b-o', label='Theoretical bound (1/q)', linewidth=2, markersize=8)
    ax.plot(primes, empirical_rates, 'r--s', label='Empirical rate', linewidth=2, markersize=6)
    ax.set_xlabel('Field size q (prime)', fontsize=14)
    ax.set_ylabel('False acceptance probability', fontsize=14)
    ax.set_title("Freivalds' Error Rate vs. Field Size", fontsize=16)
    ax.legend(fontsize=12)
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)
    ax.tick_params(labelsize=12)
    
    return fig_to_base64(fig)


def viz_amplification() -> str:
    """Plot error probability decay with number of trials."""
    q = 2
    n = 8
    max_t = 16
    num_experiments = 100000
    
    A = np.array([[random.randint(0, q-1) for _ in range(n)] for _ in range(n)])
    B = np.array([[random.randint(0, q-1) for _ in range(n)] for _ in range(n)])
    K = (A @ B) % q
    K[0, 0] = (K[0, 0] + 1) % q
    
    ts = list(range(1, max_t + 1))
    theoretical = [2**(-t) for t in ts]
    empirical = []
    
    for t in ts:
        count = 0
        for _ in range(num_experiments):
            passed = True
            for _ in range(t):
                r = np.array([random.randint(0, q-1) for _ in range(n)])
                lhs = (K @ r) % q
                rhs = (A @ ((B @ r) % q)) % q
                if not np.array_equal(lhs, rhs):
                    passed = False
                    break
            if passed:
                count += 1
        empirical.append(max(count / num_experiments, 1e-7))
    
    fig, ax = plt.subplots(figsize=(10, 6))
    ax.semilogy(ts, theoretical, 'b-o', label='Theoretical: (1/2)^t', linewidth=2, markersize=8)
    ax.semilogy(ts, empirical, 'r--s', label='Empirical', linewidth=2, markersize=6)
    ax.set_xlabel('Number of independent trials (t)', fontsize=14)
    ax.set_ylabel('False acceptance probability', fontsize=14)
    ax.set_title('Soundness Amplification: Error Decays Exponentially', fontsize=16)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)
    ax.tick_params(labelsize=12)
    
    return fig_to_base64(fig)


def viz_hyperplane_structure() -> str:
    """Visualize hyperplane structure in GF(q)^2."""
    q = 7
    
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))
    
    # All points in GF(7)^2
    all_x = list(range(q))
    all_y = list(range(q))
    
    configs = [
        ([1, 0], 0, "x₁ = 0"),
        ([1, 1], 0, "x₁ + x₂ = 0"),
        ([2, 3], 1, "2x₁ + 3x₂ = 1"),
    ]
    
    for idx, (w, b, title) in enumerate(configs):
        ax = axes[idx]
        
        # Plot all points
        for x in all_x:
            for y in all_y:
                if (w[0]*x + w[1]*y) % q == b:
                    ax.plot(x, y, 'ro', markersize=12, zorder=5)
                else:
                    ax.plot(x, y, 'b.', markersize=6, alpha=0.3)
        
        # Count solutions
        count = sum(1 for x in all_x for y in all_y if (w[0]*x + w[1]*y) % q == b)
        
        ax.set_title(f'{title} mod {q}\n({count} solutions = {q}^{{2-1}})', fontsize=13)
        ax.set_xlabel('x₁', fontsize=12)
        ax.set_ylabel('x₂', fontsize=12)
        ax.set_xticks(range(q))
        ax.set_yticks(range(q))
        ax.grid(True, alpha=0.2)
        ax.set_aspect('equal')
    
    fig.suptitle(f'Hyperplanes in GF({q})²: Red = solutions, Blue = non-solutions', fontsize=15, y=1.02)
    fig.tight_layout()
    
    return fig_to_base64(fig)


def viz_speed_comparison() -> str:
    """Plot verification speedup vs matrix size."""
    import time
    
    q = 1000000007
    sizes = [10, 20, 50, 100, 200, 500]
    mult_times = []
    check_times = []
    
    for n in sizes:
        A = np.random.randint(0, 1000, (n, n))
        B = np.random.randint(0, 1000, (n, n))
        
        t0 = time.perf_counter()
        for _ in range(3):
            K = (A @ B) % q
        t_mult = (time.perf_counter() - t0) / 3
        
        r = np.random.randint(0, 1000, n)
        t0 = time.perf_counter()
        for _ in range(3):
            lhs = (K @ r) % q
            rhs = (A @ ((B @ r) % q)) % q
        t_check = (time.perf_counter() - t0) / 3
        
        mult_times.append(t_mult * 1000)
        check_times.append(t_check * 1000)
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    ax1.loglog(sizes, mult_times, 'b-o', label='Direct multiplication O(n³)', linewidth=2, markersize=8)
    ax1.loglog(sizes, check_times, 'r-s', label='Freivalds check O(n²)', linewidth=2, markersize=8)
    ax1.set_xlabel('Matrix size n', fontsize=14)
    ax1.set_ylabel('Time (ms)', fontsize=14)
    ax1.set_title('Computation Time', fontsize=15)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)
    
    speedups = [m/c if c > 0 else 1 for m, c in zip(mult_times, check_times)]
    ax2.plot(sizes, speedups, 'g-D', linewidth=2, markersize=8)
    ax2.set_xlabel('Matrix size n', fontsize=14)
    ax2.set_ylabel('Speedup factor', fontsize=14)
    ax2.set_title('Verification Speedup', fontsize=15)
    ax2.grid(True, alpha=0.3)
    
    fig.suptitle("Freivalds vs. Direct: Verification is Asymptotically Faster", fontsize=16, y=1.02)
    fig.tight_layout()
    
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")
    
    viz_data = {}
    
    print("  1/4: Error rate vs field size...")
    viz_data["error_rate"] = viz_error_rate_vs_field_size()
    
    print("  2/4: Amplification...")
    viz_data["amplification"] = viz_amplification()
    
    print("  3/4: Hyperplane structure...")
    viz_data["hyperplane"] = viz_hyperplane_structure()
    
    print("  4/4: Speed comparison...")
    viz_data["speed"] = viz_speed_comparison()
    
    # Save for use in PACKAGE.json
    with open("viz_data.json", "w") as f:
        json.dump(viz_data, f)
    
    print("Done! Saved to viz_data.json")
