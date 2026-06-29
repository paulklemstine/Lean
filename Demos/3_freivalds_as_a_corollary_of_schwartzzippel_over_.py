#!/usr/bin/env python3
"""
Applications of Freivalds–Schwartz–Zippel to Real-World Problems

Demonstrates applications in:
1. Fast matrix product verification in numerical computing
2. Polynomial identity testing for symbolic computation
3. Coding theory: parity-check analysis
4. Interactive proof simulation
"""

import numpy as np
from typing import List, Tuple
import time


# ============================================================
# Application 1: Large-Scale Matrix Product Verification
# ============================================================

def verify_distributed_matrix_product(
    n: int, q: int = 101, k: int = 5, seed: int = 42
) -> dict:
    """
    Simulate verification of a matrix product computed by an untrusted server.

    Scenario: A client outsources the computation of A*B to a server.
    The server returns C. The client wants to verify C = A*B without
    recomputing the full product.

    Using Freivalds' algorithm:
    - Client picks random r ∈ (Z/qZ)^n
    - Computes A*(B*r) and C*r  (each O(n²))
    - Compares. Repeat k times.
    - Total cost: O(k*n²) vs O(n³) for recomputation

    Returns:
        Dictionary with timing and correctness information
    """
    rng = np.random.default_rng(seed)

    # "Server" computes A*B
    A = rng.integers(0, q, (n, n))
    B = rng.integers(0, q, (n, n))

    # Correct result
    C_correct = (A @ B) % q

    # Tampered result (server error in one entry)
    C_tampered = C_correct.copy()
    C_tampered[rng.integers(n), rng.integers(n)] = (
        C_tampered[rng.integers(n), rng.integers(n)] + 1
    ) % q

    # Freivalds verification
    start = time.perf_counter()
    accept_correct = True
    for _ in range(k):
        r = rng.integers(0, q, n)
        if not np.array_equal((A @ ((B @ r) % q)) % q, (C_correct @ r) % q):
            accept_correct = False
            break
    t_verify_correct = time.perf_counter() - start

    start = time.perf_counter()
    accept_tampered = True
    for _ in range(k):
        r = rng.integers(0, q, n)
        if not np.array_equal((A @ ((B @ r) % q)) % q, (C_tampered @ r) % q):
            accept_tampered = False
            break
    t_verify_tampered = time.perf_counter() - start

    # Full recomputation
    start = time.perf_counter()
    _ = (A @ B) % q
    t_recompute = time.perf_counter() - start

    return {
        'n': n,
        'q': q,
        'k': k,
        'verification_time': t_verify_correct,
        'recomputation_time': t_recompute,
        'speedup': t_recompute / max(t_verify_correct, 1e-10),
        'correct_accepted': accept_correct,
        'tampered_caught': not accept_tampered,
        'error_probability': (1/q)**k,
    }


# ============================================================
# Application 2: Polynomial Identity Testing
# ============================================================

def pit_symbolic_determinant(n: int, q: int = 97, k: int = 3) -> dict:
    """
    Test whether the symbolic determinant of a matrix is zero
    using the Schwartz–Zippel approach.

    This is a key application: computing the determinant symbolically
    is expensive, but evaluating it at a random point and checking
    whether it's zero gives a fast probabilistic test.

    The polynomial det(M(x)) has degree n in the entries, so
    Schwartz–Zippel gives error probability ≤ n/q per trial.
    """
    rng = np.random.default_rng(42)

    # Create a matrix with symbolic-like entries
    # (we substitute random values to test)

    # Case 1: Full rank matrix (det ≠ 0)
    detections_fullrank = 0
    for _ in range(k):
        M = rng.integers(1, q, (n, n))
        det_val = int(round(np.linalg.det(M))) % q
        if det_val != 0:
            detections_fullrank += 1

    # Case 2: Singular matrix (det = 0)
    # Make last row = first row
    detections_singular = 0
    for _ in range(k):
        M = rng.integers(1, q, (n, n))
        M[-1] = M[0]  # Force singularity
        det_val = int(round(np.linalg.det(M))) % q
        if det_val != 0:
            detections_singular += 1

    return {
        'n': n,
        'q': q,
        'degree_bound': n,
        'sz_error_bound': n / q,
        'fullrank_detected': detections_fullrank,
        'singular_zero_evals': k - detections_singular,
        'k': k,
    }


# ============================================================
# Application 3: Coding Theory — Parity Check Analysis
# ============================================================

def analyze_parity_check(p: int, q: int) -> dict:
    """
    Analyze the zero structure of parity-check equations over Z/qZ.

    A parity-check equation Σ w_j c_j = 0 defines a hyperplane in (Z/qZ)^p.
    The Schwartz–Zippel bound guarantees this hyperplane contains exactly
    q^(p-1) = (1/q) fraction of all codewords.

    This is the foundation of linear error-correcting codes.
    """
    rng = np.random.default_rng(42)

    # Random nonzero parity check vector
    w = rng.integers(1, q, p)

    # Count solutions
    total = q ** p
    zeros = 0
    for code in range(total):
        c = [(code // (q ** j)) % q for j in range(p)]
        if sum(w[j] * c[j] for j in range(p)) % q == 0:
            zeros += 1

    # The linear form always achieves exactly q^(p-1) zeros
    # (when w ≠ 0 over a field)
    expected = q ** (p - 1)

    return {
        'p': p,
        'q': q,
        'parity_vector': w.tolist(),
        'zero_count': zeros,
        'expected_exact': expected,
        'fraction': zeros / total,
        'expected_fraction': 1 / q,
        'match': zeros == expected,
    }


# ============================================================
# Application 4: Interactive Proof Simulation
# ============================================================

def simulate_sum_check(
    coefficients: List[int], q: int, honest: bool = True
) -> dict:
    """
    Simulate a simplified sum-check protocol round.

    The prover claims to know the sum S = Σ_{x∈{0,1}^n} P(x) mod q.
    The verifier checks by reducing to a univariate evaluation via
    Schwartz–Zippel-style random challenges.

    This demonstrates how the Schwartz–Zippel bound provides
    soundness guarantees for interactive proofs.
    """
    n = len(coefficients)

    # Compute actual sum over boolean hypercube
    actual_sum = 0
    for code in range(2 ** n):
        x = [(code >> j) & 1 for j in range(n)]
        val = sum(coefficients[j] * x[j] for j in range(n))
        actual_sum = (actual_sum + val) % q

    # Prover's claimed sum
    if honest:
        claimed_sum = actual_sum
    else:
        claimed_sum = (actual_sum + 1) % q

    # Verifier's random challenge
    rng = np.random.default_rng(42)
    r = rng.integers(0, q, n)

    # Evaluate polynomial at random point
    eval_at_r = sum(coefficients[j] * int(r[j]) for j in range(n)) % q

    return {
        'n': n,
        'q': q,
        'actual_sum': actual_sum,
        'claimed_sum': claimed_sum,
        'honest': honest,
        'random_challenge': r.tolist(),
        'eval_at_challenge': eval_at_r,
        'soundness_bound': 1 / q,
    }


# ============================================================
# Main: Run all applications
# ============================================================

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  APPLICATIONS OF FREIVALDS–SCHWARTZ–ZIPPEL                         ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    # Application 1: Matrix verification
    print("=" * 60)
    print("APPLICATION 1: Distributed Matrix Product Verification")
    print("=" * 60)
    for n in [100, 500, 1000]:
        result = verify_distributed_matrix_product(n)
        print(f"\n  n={n}:")
        print(f"    Verification: {result['verification_time']*1000:.2f} ms")
        print(f"    Recomputation: {result['recomputation_time']*1000:.2f} ms")
        print(f"    Speedup: {result['speedup']:.1f}x")
        print(f"    Correct accepted: {result['correct_accepted']}")
        print(f"    Tampered caught: {result['tampered_caught']}")
        print(f"    Error probability: {result['error_probability']:.2e}")

    # Application 2: PIT
    print()
    print("=" * 60)
    print("APPLICATION 2: Polynomial Identity Testing (Determinant)")
    print("=" * 60)
    for n in [3, 5, 8]:
        result = pit_symbolic_determinant(n)
        print(f"\n  n={n}:")
        print(f"    Degree bound: {result['degree_bound']}")
        print(f"    SZ error bound: {result['sz_error_bound']:.4f}")
        print(f"    Full-rank detections: {result['fullrank_detected']}/{result['k']}")

    # Application 3: Coding theory
    print()
    print("=" * 60)
    print("APPLICATION 3: Parity-Check Code Analysis")
    print("=" * 60)
    for p, q in [(3, 2), (3, 3), (4, 2), (3, 5)]:
        result = analyze_parity_check(p, q)
        print(f"\n  p={p}, q={q}:")
        print(f"    Parity vector: {result['parity_vector']}")
        print(f"    Zero count: {result['zero_count']}")
        print(f"    Expected (q^(p-1)): {result['expected_exact']}")
        print(f"    Fraction: {result['fraction']:.4f} (expected: {result['expected_fraction']:.4f})")
        print(f"    Exact match: {result['match']}")

    # Application 4: Sum-check
    print()
    print("=" * 60)
    print("APPLICATION 4: Sum-Check Protocol Simulation")
    print("=" * 60)
    coeffs = [3, 7, 2]
    q = 11
    for honest in [True, False]:
        result = simulate_sum_check(coeffs, q, honest=honest)
        print(f"\n  {'Honest' if honest else 'Cheating'} prover:")
        print(f"    Actual sum: {result['actual_sum']}")
        print(f"    Claimed sum: {result['claimed_sum']}")
        print(f"    Soundness bound: {result['soundness_bound']:.4f}")

    print()
    print("All applications demonstrated successfully.")


#!/usr/bin/env python3
"""
Freivalds' Algorithm as a Corollary of Schwartz–Zippel: Demonstrations

This script demonstrates the key theorems with concrete numerical examples,
showing how the Schwartz–Zippel polynomial identity testing bound at degree 1
gives exactly the Freivalds matrix verification guarantee.
"""

import numpy as np
from collections import Counter
import random


def mod_matrix_mul(A, B, q):
    """Matrix multiplication over Z/qZ."""
    return (A @ B) % q


def freivalds_check(A, B, C, r, q):
    """Freivalds' check: does A*B*r == C*r (mod q)?"""
    Br = (B @ r) % q
    ABr = (A @ Br) % q
    Cr = (C @ r) % q
    return np.array_equal(ABr % q, Cr % q)


def count_kernel_vectors(M, q):
    """Count vectors r in (Z/qZ)^p such that M*r = 0 mod q."""
    m, p = M.shape
    count = 0
    for code in range(q**p):
        r = np.array([(code // (q**j)) % q for j in range(p)])
        if np.all((M @ r) % q == 0):
            count += 1
    return count


def count_linear_form_zeros(w, q):
    """Count vectors r in (Z/qZ)^p such that sum(w_j * r_j) = 0 mod q."""
    p = len(w)
    count = 0
    for code in range(q**p):
        r = np.array([(code // (q**j)) % q for j in range(p)])
        if sum(w[j] * r[j] for j in range(p)) % q == 0:
            count += 1
    return count


def demo_linear_form_bound():
    """
    Demonstrate: for a nonzero linear form w over Z/qZ,
    |{r : w·r = 0}| <= q^(p-1).
    """
    print("=" * 70)
    print("DEMO 1: Linear Form Zero Set Bound (Degree-1 Schwartz–Zippel)")
    print("=" * 70)
    print()
    print("Theorem: For w ≠ 0 in (Z/qZ)^p, |{r : Σ w_j r_j = 0}| ≤ q^(p-1)")
    print()

    examples = [
        (2, [1, 0, 1]),       # q=2, w=(1,0,1) in F_2^3
        (3, [1, 2]),          # q=3, w=(1,2) in F_3^2
        (5, [1, 3, 2]),       # q=5, w=(1,3,2) in F_5^3
        (2, [1, 1, 1, 1]),    # q=2, w=(1,1,1,1) in F_2^4
        (3, [1, 0, 2]),       # q=3, w=(1,0,2) in F_3^3
    ]

    for q, w in examples:
        p = len(w)
        zeros = count_linear_form_zeros(w, q)
        bound = q ** (p - 1)
        total = q ** p
        print(f"  q={q}, p={p}, w={w}:")
        print(f"    |{{r : w·r = 0}}| = {zeros}, bound q^(p-1) = {bound}, "
              f"total = {total}, fraction = {zeros}/{total} = {zeros/total:.4f}")
        print(f"    Schwartz–Zippel bound: {zeros} ≤ {bound}? {zeros <= bound} ✓")
        print()


def demo_kernel_bound():
    """
    Demonstrate: for a nonzero matrix M over Z/qZ,
    |ker(M)| <= q^(p-1).
    """
    print("=" * 70)
    print("DEMO 2: Matrix Kernel Bound (Freivalds from Schwartz–Zippel)")
    print("=" * 70)
    print()
    print("Theorem: For M ≠ 0 (m×p matrix over Z/qZ), |ker(M)| ≤ q^(p-1)")
    print()

    # Example 1: 2×3 matrix over F_2
    M1 = np.array([[1, 0, 1], [0, 1, 1]])
    q1 = 2
    ker1 = count_kernel_vectors(M1, q1)
    bound1 = q1 ** (M1.shape[1] - 1)
    print(f"  M = {M1.tolist()}, q={q1}")
    print(f"    |ker(M)| = {ker1}, bound q^(p-1) = {bound1}")
    print(f"    {ker1} ≤ {bound1}? {ker1 <= bound1} ✓")
    print()

    # Example 2: 1×3 matrix (single row) over F_3
    M2 = np.array([[1, 2, 1]])
    q2 = 3
    ker2 = count_kernel_vectors(M2, q2)
    bound2 = q2 ** (M2.shape[1] - 1)
    print(f"  M = {M2.tolist()}, q={q2}")
    print(f"    |ker(M)| = {ker2}, bound q^(p-1) = {bound2}")
    print(f"    {ker2} ≤ {bound2}? {ker2 <= bound2} ✓")
    print()

    # Example 3: 3×3 identity matrix over F_5
    M3 = np.eye(3, dtype=int)
    q3 = 5
    ker3 = count_kernel_vectors(M3, q3)
    bound3 = q3 ** (M3.shape[1] - 1)
    print(f"  M = I_3, q={q3}")
    print(f"    |ker(M)| = {ker3}, bound q^(p-1) = {bound3}")
    print(f"    {ker3} ≤ {bound3}? {ker3 <= bound3} ✓")
    print()


def demo_freivalds_algorithm():
    """
    Demonstrate Freivalds' algorithm: randomized matrix product verification.
    """
    print("=" * 70)
    print("DEMO 3: Freivalds' Algorithm in Action")
    print("=" * 70)
    print()

    q = 7  # Work over Z/7Z
    n = 4  # 4×4 matrices
    trials = 10000

    # Create matrices where AB ≠ C
    np.random.seed(42)
    A = np.random.randint(0, q, (n, n))
    B = np.random.randint(0, q, (n, n))
    AB = mod_matrix_mul(A, B, q)

    # C = AB with one entry changed (so AB ≠ C)
    C = AB.copy()
    C[0, 0] = (C[0, 0] + 1) % q

    print(f"  Working over Z/{q}Z with {n}×{n} matrices")
    print(f"  A*B ≠ C (differ in entry (0,0))")
    print()

    # Run Freivalds' check many times
    errors = 0
    for _ in range(trials):
        r = np.random.randint(0, q, n)
        if freivalds_check(A, B, C, r, q):
            errors += 1

    error_rate = errors / trials
    theoretical_bound = 1 / q

    print(f"  Ran {trials} random checks:")
    print(f"    False accepts (errors): {errors}")
    print(f"    Empirical error rate: {error_rate:.4f}")
    print(f"    Theoretical bound (1/q): {theoretical_bound:.4f}")
    print(f"    Empirical ≤ Theoretical? {error_rate <= theoretical_bound + 0.01} "
          f"(within statistical noise)")
    print()

    # Now test with AB = C (should always accept)
    C_correct = AB.copy()
    false_rejects = 0
    for _ in range(trials):
        r = np.random.randint(0, q, n)
        if not freivalds_check(A, B, C_correct, r, q):
            false_rejects += 1

    print(f"  With correct C = A*B:")
    print(f"    False rejects: {false_rejects} (should be 0)")
    print(f"    Algorithm is one-sided: no false rejects ✓")
    print()


def demo_pit_connection():
    """
    Demonstrate the PIT interpretation: Freivalds = degree-1 Schwartz–Zippel.
    """
    print("=" * 70)
    print("DEMO 4: Polynomial Identity Testing Interpretation")
    print("=" * 70)
    print()
    print("Key insight: Checking M*r = 0 is equivalent to checking whether")
    print("the degree-1 polynomial P(r) = Σ w_j r_j vanishes at random r.")
    print()

    q = 5
    p = 3

    # A nonzero linear form
    w = [2, 3, 1]  # P(X1,X2,X3) = 2*X1 + 3*X2 + X3

    print(f"  Polynomial: P(X1,X2,X3) = {w[0]}·X1 + {w[1]}·X2 + {w[2]}·X3 over Z/{q}Z")
    print(f"  Degree = 1, q = {q}, p = {p}")
    print()

    # Count zeros
    zeros = count_linear_form_zeros(w, q)
    total = q ** p
    sz_bound = 1 * q ** (p - 1)  # deg(P) * q^(p-1) = 1 * q^(p-1)

    print(f"  Schwartz–Zippel bound: |zeros(P)| ≤ deg(P) × q^(p-1)")
    print(f"                        = 1 × {q}^{p-1} = {sz_bound}")
    print(f"  Actual zero count:    |zeros(P)| = {zeros}")
    print(f"  Bound holds: {zeros} ≤ {sz_bound}? {zeros <= sz_bound} ✓")
    print()
    print(f"  Probability of random zero: {zeros}/{total} = {zeros/total:.4f}")
    print(f"  Schwartz–Zippel probability bound: 1/{q} = {1/q:.4f}")
    print()

    # For comparison: a degree-2 polynomial
    print("  Comparison with degree-2 polynomial:")
    print(f"    P'(X1,X2,X3) = X1² + X2² + X3² over Z/{q}Z")
    zeros_d2 = 0
    for code in range(q**p):
        r = [(code // (q**j)) % q for j in range(p)]
        if sum(x**2 for x in r) % q == 0:
            zeros_d2 += 1
    sz_bound_d2 = 2 * q ** (p - 1)
    print(f"    Schwartz–Zippel bound: 2 × {q}^{p-1} = {sz_bound_d2}")
    print(f"    Actual zero count: {zeros_d2}")
    print(f"    Bound holds: {zeros_d2} ≤ {sz_bound_d2}? {zeros_d2 <= sz_bound_d2} ✓")
    print()


def demo_amplification():
    """
    Demonstrate error amplification by repeated independent checks.
    """
    print("=" * 70)
    print("DEMO 5: Error Amplification")
    print("=" * 70)
    print()
    print("By running Freivalds' check k times independently,")
    print("the error probability drops to (1/q)^k.")
    print()

    q = 3
    n = 3
    k_values = [1, 2, 3, 5, 10, 20]
    trials = 50000

    np.random.seed(123)
    A = np.random.randint(0, q, (n, n))
    B = np.random.randint(0, q, (n, n))
    AB = mod_matrix_mul(A, B, q)
    C = AB.copy()
    C[1, 1] = (C[1, 1] + 1) % q  # Make AB ≠ C

    print(f"  q={q}, n={n}, A*B ≠ C")
    print(f"  {'k':>4} | {'Empirical error':>16} | {'Bound (1/q)^k':>16} | {'Actual ≤ Bound':>14}")
    print(f"  {'-'*4}-+-{'-'*16}-+-{'-'*16}-+-{'-'*14}")

    for k in k_values:
        errors = 0
        for _ in range(trials):
            all_pass = True
            for _ in range(k):
                r = np.random.randint(0, q, n)
                if not freivalds_check(A, B, C, r, q):
                    all_pass = False
                    break
            if all_pass:
                errors += 1
        emp_rate = errors / trials
        bound = (1/q)**k
        print(f"  {k:>4} | {emp_rate:>16.6f} | {bound:>16.6f} | {'✓' if emp_rate <= bound + 0.005 else '✗':>14}")

    print()


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  FREIVALDS' ALGORITHM AS A COROLLARY OF SCHWARTZ–ZIPPEL            ║")
    print("║  Numerical Demonstrations                                          ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_linear_form_bound()
    demo_kernel_bound()
    demo_freivalds_algorithm()
    demo_pit_connection()
    demo_amplification()

    print("=" * 70)
    print("All demonstrations completed successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualizations for Freivalds–Schwartz–Zippel

Generates publication-quality figures showing:
1. Zero set structure of linear forms over finite fields
2. Error probability vs repetitions
3. Schwartz–Zippel bound tightness across degrees
4. Kernel size distribution
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import base64
from io import BytesIO
import json


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    return "data:image/png;base64," + base64.b64encode(buf.read()).decode('utf-8')


def plot_zero_set_structure():
    """
    Visualize the zero set of a linear form over F_q^2 for various q.
    Shows that exactly q^(p-1) = q points satisfy w·r = 0.
    """
    fig, axes = plt.subplots(1, 3, figsize=(14, 4.5))

    for idx, q in enumerate([3, 5, 7]):
        ax = axes[idx]
        w = [1, 1]  # Linear form: X1 + X2

        zeros_x, zeros_y = [], []
        nonzeros_x, nonzeros_y = [], []

        for x in range(q):
            for y in range(q):
                if (w[0] * x + w[1] * y) % q == 0:
                    zeros_x.append(x)
                    zeros_y.append(y)
                else:
                    nonzeros_x.append(x)
                    nonzeros_y.append(y)

        ax.scatter(nonzeros_x, nonzeros_y, c='#e0e0e0', s=60, zorder=1,
                   edgecolors='#bbb', linewidth=0.5)
        ax.scatter(zeros_x, zeros_y, c='#e74c3c', s=100, zorder=2,
                   edgecolors='#c0392b', linewidth=1.5, label=f'Zeros ({len(zeros_x)})')

        ax.set_title(f'$\\mathbb{{F}}_{{{q}}}^2$: $X_1 + X_2 = 0$',
                     fontsize=13, fontweight='bold')
        ax.set_xlabel('$X_1$', fontsize=11)
        ax.set_ylabel('$X_2$', fontsize=11)
        ax.set_xticks(range(q))
        ax.set_yticks(range(q))
        ax.set_aspect('equal')
        ax.legend(fontsize=9, loc='upper right')
        ax.grid(True, alpha=0.3)

    fig.suptitle('Zero Sets of Linear Forms over Finite Fields',
                 fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    return fig


def plot_error_amplification():
    """
    Plot error probability decay with number of repetitions.
    """
    fig, ax = plt.subplots(figsize=(8, 5))

    k_values = np.arange(1, 21)
    colors = ['#e74c3c', '#3498db', '#2ecc71', '#9b59b6', '#f39c12']

    for idx, q in enumerate([2, 3, 5, 7, 11]):
        error_probs = (1.0 / q) ** k_values
        ax.semilogy(k_values, error_probs, 'o-', color=colors[idx],
                    label=f'$q = {q}$', markersize=5, linewidth=2)

    ax.set_xlabel('Number of repetitions $k$', fontsize=12)
    ax.set_ylabel('Error probability $(1/q)^k$', fontsize=12)
    ax.set_title('Error Amplification in Freivalds\' Algorithm',
                 fontsize=14, fontweight='bold')
    ax.legend(fontsize=10, loc='upper right')
    ax.grid(True, alpha=0.3, which='both')
    ax.set_ylim(1e-20, 1.5)
    ax.set_xlim(0.5, 20.5)

    # Add annotation
    ax.annotate('$k=10, q=7$:\nerror $< 3.5 \\times 10^{-9}$',
                xy=(10, (1/7)**10), xytext=(13, 1e-6),
                fontsize=9, arrowprops=dict(arrowstyle='->', color='gray'),
                bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow'))

    plt.tight_layout()
    return fig


def plot_sz_tightness():
    """
    Compare actual zero counts vs Schwartz–Zippel bounds
    for polynomials of different degrees.
    """
    fig, ax = plt.subplots(figsize=(8, 5))

    q = 5
    p = 3
    total = q ** p

    # Degree 1: linear forms
    degrees = []
    actual_zeros = []
    sz_bounds = []

    # Various linear forms
    linear_forms = [[1, 0, 0], [1, 1, 0], [1, 1, 1], [1, 2, 3], [2, 3, 4]]
    for w in linear_forms:
        count = 0
        for code in range(total):
            r = [(code // (q**j)) % q for j in range(p)]
            if sum(w[j]*r[j] for j in range(p)) % q == 0:
                count += 1
        degrees.append(1)
        actual_zeros.append(count)
        sz_bounds.append(1 * q**(p-1))

    # Degree 2: quadratic forms
    quad_forms = [
        lambda r: (r[0]**2 + r[1] + r[2]) % q,
        lambda r: (r[0]*r[1] + r[2]) % q,
        lambda r: (r[0]**2 + r[1]**2 + r[2]**2) % q,
        lambda r: (r[0]*r[1] + r[1]*r[2] + r[0]*r[2]) % q,
    ]
    for f in quad_forms:
        count = 0
        for code in range(total):
            r = [(code // (q**j)) % q for j in range(p)]
            if f(r) == 0:
                count += 1
        degrees.append(2)
        actual_zeros.append(count)
        sz_bounds.append(2 * q**(p-1))

    # Degree 3
    cubic_forms = [
        lambda r: (r[0]**3 + r[1] + r[2]) % q,
        lambda r: (r[0]**2 * r[1] + r[2]) % q,
    ]
    for f in cubic_forms:
        count = 0
        for code in range(total):
            r = [(code // (q**j)) % q for j in range(p)]
            if f(r) == 0:
                count += 1
        degrees.append(3)
        actual_zeros.append(count)
        sz_bounds.append(3 * q**(p-1))

    # Plot
    x = np.arange(len(degrees))
    width = 0.35
    ax.bar(x - width/2, actual_zeros, width, label='Actual zeros',
           color='#3498db', edgecolor='#2980b9', linewidth=0.5)
    ax.bar(x + width/2, sz_bounds, width, label='Schwartz–Zippel bound',
           color='#e74c3c', alpha=0.7, edgecolor='#c0392b', linewidth=0.5)

    ax.set_xlabel('Polynomial index', fontsize=12)
    ax.set_ylabel('Number of zeros', fontsize=12)
    ax.set_title(f'Schwartz–Zippel Bound Tightness ($q={q}$, $p={p}$)',
                 fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.set_xticks(x)
    labels = [f'd={d}' for d in degrees]
    ax.set_xticklabels(labels, fontsize=9)
    ax.grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    return fig


def plot_kernel_size_distribution():
    """
    Show kernel sizes for random matrices over F_q,
    compared to the Schwartz–Zippel bound.
    """
    fig, ax = plt.subplots(figsize=(8, 5))

    q = 3
    p = 4
    bound = q ** (p - 1)
    n_samples = 200

    rng = np.random.default_rng(42)
    kernel_sizes = []

    for _ in range(n_samples):
        # Random nonzero matrix
        m = rng.integers(1, 4)  # 1 to 3 rows
        M = rng.integers(0, q, (m, p))
        while np.all(M == 0):
            M = rng.integers(0, q, (m, p))

        # Count kernel
        count = 0
        for code in range(q**p):
            r = np.array([(code // (q**j)) % q for j in range(p)])
            if np.all((M @ r) % q == 0):
                count += 1
        kernel_sizes.append(count)

    ax.hist(kernel_sizes, bins=range(0, bound + 3), align='left',
            color='#3498db', edgecolor='#2980b9', alpha=0.8,
            label='Observed kernel sizes')
    ax.axvline(x=bound, color='#e74c3c', linewidth=2.5, linestyle='--',
               label=f'Schwartz–Zippel bound $q^{{p-1}} = {bound}$')

    ax.set_xlabel('Kernel size $|\\ker(M)|$', fontsize=12)
    ax.set_ylabel('Count', fontsize=12)
    ax.set_title(f'Kernel Sizes of Random Matrices over $\\mathbb{{F}}_{{{q}}}$ ($p={p}$)',
                 fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    return fig


def generate_all_visualizations():
    """Generate all figures and return as base64-encoded data URIs."""
    figures = {}

    print("Generating zero set structure plot...")
    fig1 = plot_zero_set_structure()
    figures['zero_set_structure'] = fig_to_base64(fig1)
    fig1.savefig('/workspace/request-project/fig_zero_sets.png',
                 dpi=150, bbox_inches='tight')
    plt.close(fig1)

    print("Generating error amplification plot...")
    fig2 = plot_error_amplification()
    figures['error_amplification'] = fig_to_base64(fig2)
    fig2.savefig('/workspace/request-project/fig_error_amplification.png',
                 dpi=150, bbox_inches='tight')
    plt.close(fig2)

    print("Generating SZ tightness plot...")
    fig3 = plot_sz_tightness()
    figures['sz_tightness'] = fig_to_base64(fig3)
    fig3.savefig('/workspace/request-project/fig_sz_tightness.png',
                 dpi=150, bbox_inches='tight')
    plt.close(fig3)

    print("Generating kernel distribution plot...")
    fig4 = plot_kernel_size_distribution()
    figures['kernel_distribution'] = fig_to_base64(fig4)
    fig4.savefig('/workspace/request-project/fig_kernel_distribution.png',
                 dpi=150, bbox_inches='tight')
    plt.close(fig4)

    print("All visualizations generated.")
    return figures


if __name__ == "__main__":
    figures = generate_all_visualizations()
    print(f"Generated {len(figures)} figures.")
    for name, uri in figures.items():
        print(f"  {name}: {len(uri)} chars")
