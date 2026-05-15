#!/usr/bin/env python3
"""
Applications of Freivalds' Finite-Field Verification Theorem

Demonstrates real-world applications:
1. Cryptographic verification of delegated computation
2. Streaming data integrity checking
3. Polynomial identity testing (PIT)
4. Error-correcting code verification
"""

import random
import numpy as np
from typing import List, Tuple


# ==============================================================================
# Application 1: Delegated Computation Verification
# ==============================================================================

def delegated_computation_demo():
    """
    Scenario: A client delegates matrix multiplication to an untrusted server.
    The client wants to verify the result without recomputing the product.
    
    Using Freivalds' check:
    - Server computes K = A·B (or claims to)  
    - Client checks with random vectors: O(n²) per check vs O(n³) recomputation
    - Soundness: false acceptance ≤ (1/q)^t for t checks
    """
    print("=" * 60)
    print("APPLICATION 1: Delegated Computation Verification")
    print("=" * 60)
    print()
    
    q = 101  # Moderate prime
    n = 50   # Matrix size
    t = 20   # Number of checks
    
    # Client's matrices
    A = np.array([[random.randint(0, q-1) for _ in range(n)] for _ in range(n)])
    B = np.array([[random.randint(0, q-1) for _ in range(n)] for _ in range(n)])
    
    # Honest server: computes correctly
    K_honest = (A @ B) % q
    
    # Malicious server: returns slightly wrong answer
    K_malicious = K_honest.copy()
    K_malicious[random.randint(0, n-1), random.randint(0, n-1)] = (
        K_malicious[0, 0] + 1
    ) % q
    
    # Client verification
    def verify(K, num_checks):
        for _ in range(num_checks):
            r = np.array([random.randint(0, q-1) for _ in range(n)])
            Kr = (K @ r) % q
            Br = (B @ r) % q
            ABr = (A @ Br) % q
            if not np.array_equal(Kr, ABr):
                return False
        return True
    
    honest_result = verify(K_honest, t)
    malicious_result = verify(K_malicious, t)
    
    print(f"  Matrix size: {n}×{n} over Z/{q}Z")
    print(f"  Number of checks: {t}")
    print(f"  Honest server accepted: {honest_result}")
    print(f"  Malicious server accepted: {malicious_result}")
    print(f"  False acceptance bound: (1/{q})^{t} = {(1/q)**t:.2e}")
    print(f"  Verification cost: O(n²·t) = O({n*n*t})")
    print(f"  Recomputation cost: O(n³) = O({n**3})")
    print(f"  Speedup factor: {n**3 / (n*n*t):.1f}x")
    print()


# ==============================================================================
# Application 2: Polynomial Identity Testing (PIT)
# ==============================================================================

def pit_demo():
    """
    Freivalds' theorem is the degree-1 case of Schwartz-Zippel.
    
    For a degree-d polynomial p(x₁,...,xₙ) over Z/qZ:
    - If p ≡ 0, then p(r) = 0 for all r
    - If p ≢ 0, then Pr[p(r) = 0] ≤ d/q for uniform random r
    
    Freivalds corresponds to d=1: each entry of (K-AB)·r is a degree-1 polynomial.
    """
    print("=" * 60)
    print("APPLICATION 2: Polynomial Identity Testing (Degree 1)")
    print("=" * 60)
    print()
    
    q = 7
    p_dim = 5
    
    # A nonzero linear polynomial: f(x₁,...,x₅) = 2x₁ + 3x₃ + x₅
    coeffs = np.array([2, 0, 3, 0, 1])
    
    # Count zeros of f over (Z/7Z)^5
    total = q ** p_dim
    zeros = 0
    for code in range(total):
        r = []
        val = code
        for j in range(p_dim):
            r.append(val % q)
            val //= q
        if sum(coeffs[j] * r[j] for j in range(p_dim)) % q == 0:
            zeros += 1
    
    print(f"  Linear form: f(x) = {' + '.join(f'{c}·x_{i}' for i, c in enumerate(coeffs) if c != 0)}")
    print(f"  Field: Z/{q}Z, dimension: {p_dim}")
    print(f"  Total points: {total}")
    print(f"  Zero set size: {zeros}")
    print(f"  Zero fraction: {zeros/total:.4f}")
    print(f"  Theoretical bound (1/q): {1/q:.4f}")
    print(f"  Theoretical exact (q^(p-1)/q^p): {q**(p_dim-1)/total:.4f}")
    print()
    
    # Degree-2 comparison (Schwartz-Zippel extension)
    print("  Comparison with degree-2 (Schwartz-Zippel):")
    # f(x₁, x₂) = x₁·x₂ over Z/qZ
    zeros_2 = 0
    total_2 = q * q
    for x1 in range(q):
        for x2 in range(q):
            if (x1 * x2) % q == 0:
                zeros_2 += 1
    print(f"  f(x₁,x₂) = x₁·x₂ over Z/{q}Z:")
    print(f"    Zeros: {zeros_2}/{total_2} = {zeros_2/total_2:.4f}")
    print(f"    Schwartz-Zippel bound (d/q = 2/{q}): {2/q:.4f}")
    print()


# ==============================================================================
# Application 3: Error-Correcting Code Verification
# ==============================================================================

def coding_theory_demo():
    """
    The hyperplane counting theorem connects to coding theory:
    - A nonzero codeword in a linear code has Hamming weight ≥ 1
    - A parity check equation w·r = 0 defines a code of codimension 1
    - The number of codewords is exactly q^(p-1)
    
    This is the basis for syndrome decoding and error detection.
    """
    print("=" * 60)
    print("APPLICATION 3: Coding Theory / Parity Checks")
    print("=" * 60)
    print()
    
    q = 2  # Binary field
    p = 8  # Code length
    
    # Parity check matrix (single row = repetition code check)
    H = np.array([[1, 1, 1, 1, 1, 1, 1, 1]])  # All-ones parity check
    
    # Count codewords (kernel of H)
    codewords = 0
    for code in range(q ** p):
        r = []
        val = code
        for j in range(p):
            r.append(val % q)
            val //= q
        if sum(r) % q == 0:
            codewords += 1
    
    print(f"  Code: Single parity check code over GF({q})")
    print(f"  Length: {p}")
    print(f"  Parity check: H = {H[0]}")
    print(f"  Codewords (|ker H|): {codewords}")
    print(f"  Expected (q^(p-1)): {q**(p-1)}")
    print(f"  Rate: {codewords}/{q**p} = {codewords/q**p:.4f}")
    print()
    
    # Multi-row parity check
    H2 = np.array([
        [1, 1, 0, 1, 0, 0, 0, 0],
        [0, 1, 1, 0, 1, 0, 0, 0],
        [0, 0, 1, 1, 0, 1, 0, 0],
    ])
    
    codewords2 = 0
    for code in range(q ** p):
        r = np.zeros(p, dtype=int)
        val = code
        for j in range(p):
            r[j] = val % q
            val //= q
        if np.all((H2 @ r) % q == 0):
            codewords2 += 1
    
    print(f"  Multi-row parity check (3 rows):")
    print(f"  Codewords: {codewords2}")
    print(f"  Upper bound (q^(p-1)): {q**(p-1)} (from single-row bound)")
    print(f"  Tighter bound (q^(p-rank)): {q**(p-3)} (from rank-nullity)")
    print()


# ==============================================================================
# Application 4: Randomized Linear Fingerprinting
# ==============================================================================

def fingerprinting_demo():
    """
    Freivalds' check is a special case of randomized linear fingerprinting.
    
    To check if two large datasets are equal:
    1. Represent them as vectors/matrices
    2. Compute random linear fingerprints
    3. Compare fingerprints instead of full data
    
    Error probability ≤ 1/q per fingerprint.
    """
    print("=" * 60)
    print("APPLICATION 4: Randomized Linear Fingerprinting")
    print("=" * 60)
    print()
    
    q = 1000003  # Large prime
    n = 1000     # Data size
    
    # Two "large" datasets
    data_A = [random.randint(0, q-1) for _ in range(n)]
    data_B = list(data_A)  # Same data
    data_C = list(data_A)
    data_C[random.randint(0, n-1)] = (data_C[0] + 1) % q  # One bit different
    
    num_checks = 5
    
    def fingerprint_check(d1, d2, num_checks):
        """Check equality via random linear fingerprints."""
        for _ in range(num_checks):
            r = [random.randint(0, q-1) for _ in range(n)]
            fp1 = sum(d1[i] * r[i] for i in range(n)) % q
            fp2 = sum(d2[i] * r[i] for i in range(n)) % q
            if fp1 != fp2:
                return False, "DIFFERENT"
        return True, "SAME (probably)"
    
    result_same, msg_same = fingerprint_check(data_A, data_B, num_checks)
    result_diff, msg_diff = fingerprint_check(data_A, data_C, num_checks)
    
    print(f"  Data size: {n} elements over Z/{q}Z")
    print(f"  Fingerprint checks: {num_checks}")
    print()
    print(f"  Equal datasets:    {msg_same}")
    print(f"  Different datasets: {msg_diff}")
    print(f"  Error bound: (1/{q})^{num_checks} = {(1/q)**num_checks:.2e}")
    print(f"  Communication: {num_checks} field elements vs {n} (full comparison)")
    print(f"  Compression ratio: {n / num_checks:.0f}x")
    print()


if __name__ == "__main__":
    random.seed(42)
    
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  APPLICATIONS OF FREIVALDS' VERIFICATION THEOREM       ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()
    
    delegated_computation_demo()
    pit_demo()
    coding_theory_demo()
    fingerprinting_demo()
    
    print("All application demos complete.")


#!/usr/bin/env python3
"""
Freivalds' Algorithm: Randomized Matrix Verification over Finite Fields

Demonstrates the key theorems:
1. Freivalds' algorithm detects incorrect matrix products with high probability
2. The failure probability is exactly controlled by the field size: ≤ 1/q
3. Repeated trials amplify confidence exponentially
"""

import random
import numpy as np
from typing import Tuple, List


def mod_matrix_mul(A: np.ndarray, B: np.ndarray, q: int) -> np.ndarray:
    """Matrix multiplication over Z/qZ."""
    return (A @ B) % q


def freivalds_check(A: np.ndarray, B: np.ndarray, K: np.ndarray,
                     q: int, r: np.ndarray) -> bool:
    """
    Single Freivalds check: returns True if K*r == (A*B)*r mod q.
    
    If K == A*B, always returns True.
    If K != A*B, returns True with probability <= 1/q.
    """
    Kr = (K @ r) % q
    ABr = (A @ ((B @ r) % q)) % q
    return np.array_equal(Kr % q, ABr % q)


def freivalds_repeated(A: np.ndarray, B: np.ndarray, K: np.ndarray,
                        q: int, t: int) -> bool:
    """
    Repeated Freivalds check with t independent trials.
    
    If K == A*B, always returns True.
    If K != A*B, returns True with probability <= 1/q^t.
    """
    p = B.shape[1]
    for _ in range(t):
        r = np.array([random.randint(0, q - 1) for _ in range(p)])
        if not freivalds_check(A, B, K, q, r):
            return False
    return True


def count_kernel_vectors(M: np.ndarray, q: int) -> int:
    """
    Count the number of vectors r in (Z/qZ)^p such that M*r = 0 mod q.
    Brute force - only for small dimensions!
    """
    p = M.shape[1]
    count = 0
    # Enumerate all vectors in (Z/qZ)^p
    for code in range(q ** p):
        r = np.zeros(p, dtype=int)
        val = code
        for j in range(p):
            r[j] = val % q
            val //= q
        if np.all((M @ r) % q == 0):
            count += 1
    return count


def count_dotproduct_solutions(w: np.ndarray, b: int, q: int) -> int:
    """
    Count solutions to dot(w, r) = b mod q.
    Brute force for verification.
    """
    p = len(w)
    count = 0
    for code in range(q ** p):
        r = np.zeros(p, dtype=int)
        val = code
        for j in range(p):
            r[j] = val % q
            val //= q
        if np.dot(w, r) % q == b % q:
            count += 1
    return count


def demo_hyperplane_counting():
    """
    Demonstrate that a nonzero linear equation over Z/qZ 
    has exactly q^(p-1) solutions.
    """
    print("=" * 60)
    print("DEMO 1: Hyperplane Counting (Core Structural Lemma)")
    print("=" * 60)
    print()
    
    for q in [2, 3, 5, 7]:
        for p in [1, 2, 3, 4]:
            if q ** p > 10000:
                continue
            # Random nonzero vector
            w = np.zeros(p, dtype=int)
            while np.all(w == 0):
                w = np.array([random.randint(0, q - 1) for _ in range(p)])
            
            for b in [0, 1]:
                count = count_dotproduct_solutions(w, b, q)
                expected = q ** (p - 1)
                status = "✓" if count == expected else "✗"
                print(f"  q={q}, p={p}, w={w}, b={b}: "
                      f"solutions={count}, expected=q^(p-1)={expected} {status}")
    print()


def demo_kernel_bound():
    """
    Demonstrate that |ker(M.mulVec)| ≤ q^(p-1) for nonzero M.
    """
    print("=" * 60)
    print("DEMO 2: Kernel Cardinality Bound")
    print("=" * 60)
    print()
    
    for q in [2, 3, 5]:
        for m in [1, 2, 3]:
            for p in [1, 2, 3]:
                if q ** p > 1000:
                    continue
                # Random nonzero matrix
                M = np.zeros((m, p), dtype=int)
                while np.all(M == 0):
                    M = np.array([[random.randint(0, q - 1) for _ in range(p)]
                                   for _ in range(m)])
                
                ker_size = count_kernel_vectors(M, q)
                bound = q ** (p - 1)
                status = "✓" if ker_size <= bound else "✗"
                print(f"  q={q}, m={m}, p={p}: "
                      f"|ker|={ker_size}, bound=q^(p-1)={bound} {status}")
    print()


def demo_freivalds_probability():
    """
    Empirically verify the 1/q failure probability bound.
    """
    print("=" * 60)
    print("DEMO 3: Freivalds' Failure Probability")
    print("=" * 60)
    print()
    
    num_trials = 10000
    
    for q in [2, 3, 5, 7, 11]:
        m, n, p = 4, 4, 4
        
        # Generate random matrices
        A = np.array([[random.randint(0, q - 1) for _ in range(n)] for _ in range(m)])
        B = np.array([[random.randint(0, q - 1) for _ in range(p)] for _ in range(n)])
        
        # Correct product
        AB = mod_matrix_mul(A, B, q)
        
        # Incorrect claim: perturb one entry
        K = AB.copy()
        K[0, 0] = (K[0, 0] + 1) % q
        
        # Run Freivalds
        false_accepts = 0
        for _ in range(num_trials):
            r = np.array([random.randint(0, q - 1) for _ in range(p)])
            if freivalds_check(A, B, K, q, r):
                false_accepts += 1
        
        empirical_prob = false_accepts / num_trials
        theoretical_bound = 1.0 / q
        status = "✓" if empirical_prob <= theoretical_bound + 0.02 else "~"
        
        print(f"  q={q}: empirical false-accept rate = {empirical_prob:.4f}, "
              f"theoretical bound 1/q = {theoretical_bound:.4f} {status}")
    print()


def demo_amplification():
    """
    Demonstrate exponential confidence amplification with repeated trials.
    """
    print("=" * 60)
    print("DEMO 4: Soundness Amplification (Repeated Trials)")
    print("=" * 60)
    print()
    
    q = 2  # Binary field for clearest amplification
    m, n, p = 5, 5, 5
    num_experiments = 50000
    
    A = np.array([[random.randint(0, q - 1) for _ in range(n)] for _ in range(m)])
    B = np.array([[random.randint(0, q - 1) for _ in range(p)] for _ in range(n)])
    AB = mod_matrix_mul(A, B, q)
    K = AB.copy()
    K[0, 0] = (K[0, 0] + 1) % q  # Wrong answer
    
    print(f"  Field: Z/{q}Z, matrix size: {m}×{p}")
    print(f"  Running {num_experiments} experiments per trial count")
    print()
    
    for t in [1, 2, 3, 5, 8, 10, 15, 20]:
        false_accepts = sum(
            1 for _ in range(num_experiments)
            if freivalds_repeated(A, B, K, q, t)
        )
        empirical = false_accepts / num_experiments
        theoretical = (1.0 / q) ** t
        print(f"  t={t:2d} trials: empirical={empirical:.6f}, "
              f"bound=(1/{q})^{t}={theoretical:.10f}")
    print()


def demo_correct_always_accepts():
    """
    Verify that correct products always pass Freivalds' check.
    """
    print("=" * 60)
    print("DEMO 5: Completeness (Correct Products Always Accepted)")
    print("=" * 60)
    print()
    
    for q in [2, 3, 5]:
        m, n, p = 3, 4, 3
        A = np.array([[random.randint(0, q - 1) for _ in range(n)] for _ in range(m)])
        B = np.array([[random.randint(0, q - 1) for _ in range(p)] for _ in range(n)])
        K = mod_matrix_mul(A, B, q)  # Correct product
        
        all_pass = True
        for _ in range(10000):
            r = np.array([random.randint(0, q - 1) for _ in range(p)])
            if not freivalds_check(A, B, K, q, r):
                all_pass = False
                break
        
        status = "✓ (all 10000 checks passed)" if all_pass else "✗ (false reject!)"
        print(f"  q={q}: {status}")
    print()


if __name__ == "__main__":
    random.seed(42)
    
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  FREIVALDS' ALGORITHM: FINITE-FIELD VERIFICATION       ║")
    print("║  Demonstrating the Hyperplane Counting Engine           ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()
    
    demo_hyperplane_counting()
    demo_kernel_bound()
    demo_freivalds_probability()
    demo_amplification()
    demo_correct_always_accepts()
    
    print("All demonstrations complete.")


#!/usr/bin/env python3
"""
Visualizations for Freivalds' Finite-Field Verification Theorem

Generates publication-quality figures showing:
1. Hyperplane counting structure
2. Failure probability vs field size
3. Amplification curves
4. Kernel density comparison
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import random
import base64
import io


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"


def plot_hyperplane_structure():
    """
    Visualize the hyperplane structure in (Z/qZ)^2.
    Shows how solutions to a linear equation form a hyperplane.
    """
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    for idx, q in enumerate([3, 5, 7]):
        ax = axes[idx]
        
        # All points
        all_x = []
        all_y = []
        for x in range(q):
            for y in range(q):
                all_x.append(x)
                all_y.append(y)
        
        ax.scatter(all_x, all_y, c='lightblue', s=100, zorder=1, 
                   label=f'All {q}² = {q*q} points', alpha=0.5)
        
        # Solution set: 2x + 3y = 0 mod q
        sol_x = []
        sol_y = []
        for x in range(q):
            for y in range(q):
                if (2 * x + 3 * y) % q == 0:
                    sol_x.append(x)
                    sol_y.append(y)
        
        ax.scatter(sol_x, sol_y, c='red', s=150, zorder=2,
                   label=f'2x+3y≡0: {len(sol_x)} = {q}¹ points', marker='o')
        
        ax.set_xlim(-0.5, q - 0.5)
        ax.set_ylim(-0.5, q - 0.5)
        ax.set_xlabel('x', fontsize=12)
        ax.set_ylabel('y', fontsize=12)
        ax.set_title(f'Hyperplane in (ℤ/{q}ℤ)²', fontsize=13)
        ax.legend(fontsize=9, loc='upper right')
        ax.set_aspect('equal')
        ax.grid(True, alpha=0.3)
    
    fig.suptitle('Hyperplane Counting: Solutions to 2x + 3y ≡ 0 (mod q)', 
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    fig.savefig('/workspace/request-project/fig_hyperplane.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def plot_failure_probability():
    """
    Plot failure probability 1/q as a function of field size.
    """
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    
    primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47,
              53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101, 127, 251, 509, 1021]
    
    probs = [1.0 / p for p in primes]
    
    ax.semilogy(primes, probs, 'bo-', markersize=6, linewidth=1.5, label='Pr[false accept] ≤ 1/q')
    
    # Highlight specific primes
    for p_val, label_text in [(2, 'GF(2): 50%'), (7, 'GF(7): 14.3%'), 
                               (101, 'GF(101): ~1%'), (1021, 'GF(1021): ~0.1%')]:
        ax.annotate(label_text, xy=(p_val, 1/p_val), 
                    xytext=(p_val * 1.3, 1/p_val * 2),
                    arrowprops=dict(arrowstyle='->', color='gray'),
                    fontsize=9)
    
    ax.set_xlabel('Field Size q (prime)', fontsize=12)
    ax.set_ylabel('Failure Probability', fontsize=12)
    ax.set_title("Freivalds' Soundness: Failure Probability vs Field Size", fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3, which='both')
    ax.set_ylim(1e-4, 1)
    
    plt.tight_layout()
    fig.savefig('/workspace/request-project/fig_failure_prob.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def plot_amplification():
    """
    Plot soundness amplification: (1/q)^t for different q and t.
    """
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    
    t_values = np.arange(1, 31)
    
    for q in [2, 3, 5, 7, 11, 101]:
        probs = [(1.0 / q) ** t for t in t_values]
        ax.semilogy(t_values, probs, 'o-', markersize=4, linewidth=1.5, 
                    label=f'q={q}: (1/{q})^t')
    
    # Reference lines
    ax.axhline(y=1e-6, color='gray', linestyle='--', alpha=0.5, label='1 in a million')
    ax.axhline(y=1e-15, color='gray', linestyle=':', alpha=0.5, label='1 in a quadrillion')
    
    ax.set_xlabel('Number of Trials t', fontsize=12)
    ax.set_ylabel('False Acceptance Probability', fontsize=12)
    ax.set_title('Exponential Soundness Amplification', fontsize=14)
    ax.legend(fontsize=9, loc='upper right')
    ax.grid(True, alpha=0.3, which='both')
    ax.set_ylim(1e-30, 1)
    
    plt.tight_layout()
    fig.savefig('/workspace/request-project/fig_amplification.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def plot_kernel_density():
    """
    Plot kernel size vs the q^(p-1) bound for various matrices.
    """
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    random.seed(42)
    
    # Left: Fixed q, varying rank
    ax = axes[0]
    q = 3
    p = 4
    
    ranks = []
    kernel_sizes = []
    
    for trial in range(100):
        m = random.randint(1, 4)
        M = np.array([[random.randint(0, q-1) for _ in range(p)] for _ in range(m)])
        if np.all(M == 0):
            continue
        
        # Count kernel
        ker_size = 0
        for code in range(q ** p):
            r = np.zeros(p, dtype=int)
            val = code
            for j in range(p):
                r[j] = val % q
                val //= q
            if np.all((M @ r) % q == 0):
                ker_size += 1
        
        kernel_sizes.append(ker_size)
        ranks.append(m)
    
    ax.scatter(range(len(kernel_sizes)), kernel_sizes, c='blue', s=30, alpha=0.7, 
               label='|ker(M)|')
    ax.axhline(y=q**(p-1), color='red', linewidth=2, linestyle='--',
               label=f'Bound: q^(p-1) = {q**(p-1)}')
    ax.set_xlabel('Matrix Index', fontsize=12)
    ax.set_ylabel('Kernel Size', fontsize=12)
    ax.set_title(f'Kernel Sizes (q={q}, p={p})', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    # Right: Distribution of kernel sizes
    ax = axes[1]
    q = 5
    p = 3
    
    kernel_dist = {}
    for trial in range(200):
        m = random.randint(1, 3)
        M = np.array([[random.randint(0, q-1) for _ in range(p)] for _ in range(m)])
        if np.all(M == 0):
            continue
        
        ker_size = 0
        for code in range(q ** p):
            r = np.zeros(p, dtype=int)
            val = code
            for j in range(p):
                r[j] = val % q
                val //= q
            if np.all((M @ r) % q == 0):
                ker_size += 1
        
        kernel_dist[ker_size] = kernel_dist.get(ker_size, 0) + 1
    
    sizes = sorted(kernel_dist.keys())
    counts = [kernel_dist[s] for s in sizes]
    colors = ['green' if s <= q**(p-1) else 'red' for s in sizes]
    
    ax.bar(sizes, counts, color=colors, alpha=0.7, edgecolor='black')
    ax.axvline(x=q**(p-1), color='red', linewidth=2, linestyle='--',
               label=f'Bound: q^(p-1) = {q**(p-1)}')
    ax.set_xlabel('Kernel Size', fontsize=12)
    ax.set_ylabel('Frequency', fontsize=12)
    ax.set_title(f'Distribution of Kernel Sizes (q={q}, p={p})', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    fig.suptitle('Kernel Density: All Nonzero Matrices Have |ker| ≤ q^(p-1)', 
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    fig.savefig('/workspace/request-project/fig_kernel_density.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def plot_verification_cost():
    """
    Compare verification cost vs recomputation cost.
    """
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    
    n_values = np.arange(10, 1001, 10)
    t = 20  # Number of checks for high confidence
    
    recompute_cost = n_values ** 3  # O(n³)
    verify_cost = n_values ** 2 * t  # O(n²·t)
    
    ax.loglog(n_values, recompute_cost, 'r-', linewidth=2, label='Recomputation: O(n³)')
    ax.loglog(n_values, verify_cost, 'b-', linewidth=2, label=f'Freivalds ({t} checks): O(n²·{t})')
    
    ax.fill_between(n_values, verify_cost, recompute_cost, alpha=0.1, color='green')
    
    # Speedup annotation
    n_mid = 500
    speedup = n_mid / t
    ax.annotate(f'{speedup:.0f}× speedup at n={n_mid}', 
                xy=(n_mid, n_mid**2 * t),
                xytext=(n_mid * 0.3, n_mid**2 * t * 10),
                arrowprops=dict(arrowstyle='->', color='gray'),
                fontsize=11, fontweight='bold')
    
    ax.set_xlabel('Matrix Size n', fontsize=12)
    ax.set_ylabel('Operations', fontsize=12)
    ax.set_title('Verification vs Recomputation Cost', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3, which='both')
    
    plt.tight_layout()
    fig.savefig('/workspace/request-project/fig_cost.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")
    
    b64_hyperplane = plot_hyperplane_structure()
    print("  ✓ Hyperplane structure")
    
    b64_failure = plot_failure_probability()
    print("  ✓ Failure probability")
    
    b64_amp = plot_amplification()
    print("  ✓ Amplification curves")
    
    b64_kernel = plot_kernel_density()
    print("  ✓ Kernel density")
    
    b64_cost = plot_verification_cost()
    print("  ✓ Verification cost comparison")
    
    print("\nAll visualizations saved.")
    
    # Save base64 data for JSON package
    import json
    viz_data = {
        "hyperplane": b64_hyperplane,
        "failure_prob": b64_failure,
        "amplification": b64_amp,
        "kernel_density": b64_kernel,
        "cost": b64_cost,
    }
    with open('/workspace/request-project/viz_data.json', 'w') as f:
        json.dump(viz_data, f)
    print("Base64 data saved to viz_data.json")
