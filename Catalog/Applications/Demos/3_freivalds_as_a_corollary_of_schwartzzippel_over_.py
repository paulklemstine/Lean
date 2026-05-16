#!/usr/bin/env python3
"""
Applications of the Freivalds–Schwartz–Zippel Connection

Demonstrates real-world applications of the theorems:
1. Fast matrix product verification
2. Polynomial identity testing for algebraic circuits
3. Error-correcting code parity checks
4. Simple interactive proof simulation
"""

import numpy as np
import random
from typing import List, Callable


# ============================================================
# Application 1: Fast Matrix Product Verification
# ============================================================

def verify_matrix_product_fast(
    A: np.ndarray, B: np.ndarray, C: np.ndarray,
    q: int, confidence: float = 0.999
) -> dict:
    """
    Verify A*B = C with specified confidence using Freivalds' algorithm.
    
    Automatically determines the number of repetitions needed
    to achieve the desired confidence level.
    
    Args:
        A, B, C: Matrices over F_q
        q: Prime field size
        confidence: Desired confidence (e.g., 0.999 = 99.9%)
    
    Returns:
        Dictionary with verdict, repetitions used, and error bound
    """
    import math
    
    # Compute required repetitions: (1/q)^k ≤ 1 - confidence
    if confidence >= 1.0:
        k = 100  # practical upper limit
    else:
        k = max(1, int(math.ceil(math.log(1 - confidence) / math.log(1 / q))))
    
    m, n = A.shape
    _, p = B.shape
    
    all_pass = True
    for _ in range(k):
        r = np.array([random.randint(0, q - 1) for _ in range(p)])
        
        # Compute B*r, then A*(B*r), then C*r
        Br = np.array([sum(int(B[i][j]) * int(r[j]) for j in range(p)) % q for i in range(n)])
        ABr = np.array([sum(int(A[i][j]) * int(Br[j]) for j in range(n)) % q for i in range(m)])
        Cr = np.array([sum(int(C[i][j]) * int(r[j]) for j in range(p)) % q for i in range(m)])
        
        if not np.array_equal(ABr, Cr):
            all_pass = False
            break
    
    return {
        "verdict": "EQUAL" if all_pass else "NOT EQUAL",
        "repetitions": k,
        "error_bound": (1 / q) ** k,
        "confidence": 1 - (1 / q) ** k
    }


# ============================================================
# Application 2: Polynomial Identity Testing (PIT)
# ============================================================

def polynomial_identity_test(
    eval_f: Callable, eval_g: Callable,
    num_vars: int, q: int,
    degree_bound: int, repetitions: int = 10
) -> dict:
    """
    Test whether two polynomial functions are identical over F_q.
    
    Uses the Schwartz–Zippel lemma: if f ≠ g and deg(f-g) ≤ d,
    then Pr[f(r) = g(r)] ≤ d/q for random r.
    
    Args:
        eval_f, eval_g: Functions evaluating the polynomials
        num_vars: Number of variables
        q: Prime field size
        degree_bound: Upper bound on degree of f - g
        repetitions: Number of random tests
    
    Returns:
        Dictionary with verdict and analysis
    """
    disagreements = 0
    
    for _ in range(repetitions):
        point = [random.randint(0, q - 1) for _ in range(num_vars)]
        if eval_f(point) % q != eval_g(point) % q:
            disagreements += 1
    
    error_prob = (degree_bound / q) ** repetitions if disagreements == 0 else 0.0
    
    return {
        "verdict": "DIFFERENT" if disagreements > 0 else "LIKELY IDENTICAL",
        "disagreements": disagreements,
        "tests": repetitions,
        "error_bound": error_prob
    }


# ============================================================
# Application 3: Parity Check Codes
# ============================================================

def parity_check_analysis(H: np.ndarray, q: int) -> dict:
    """
    Analyze a parity-check matrix for a linear code over F_q.
    
    Each row of H defines a parity-check equation. The number of
    codewords (vectors in the kernel of H) is bounded by the
    Freivalds/Schwartz–Zippel theorem.
    
    Args:
        H: r × n parity-check matrix over F_q
        q: Prime field size
    
    Returns:
        Analysis dictionary
    """
    from itertools import product as cartesian
    
    r, n = H.shape
    
    # Count codewords (kernel of H)
    codewords = 0
    for v in cartesian(range(q), repeat=n):
        v_arr = np.array(v)
        syndrome = np.array([
            sum(int(H[i][j]) * int(v_arr[j]) for j in range(n)) % q
            for i in range(r)
        ])
        if all(s == 0 for s in syndrome):
            codewords += 1
    
    # Per-row analysis
    row_analyses = []
    for i in range(r):
        row = H[i]
        is_nonzero = any(int(row[j]) % q != 0 for j in range(n))
        if is_nonzero:
            # Count solutions to this single parity check
            solutions = 0
            for v in cartesian(range(q), repeat=n):
                dot = sum(int(row[j]) * int(v[j]) for j in range(n)) % q
                if dot == 0:
                    solutions += 1
            row_analyses.append({
                "row": i,
                "coefficients": row.tolist(),
                "solutions": solutions,
                "fraction": solutions / q**n,
                "predicted_fraction": 1/q
            })
    
    return {
        "check_matrix_size": f"{r} × {n}",
        "field_size": q,
        "total_words": q**n,
        "codewords": codewords,
        "code_rate": codewords / q**n,
        "freivalds_bound": q**(n-1),
        "per_row_analysis": row_analyses
    }


# ============================================================
# Application 4: Simple Interactive Proof Simulation
# ============================================================

def simulate_sumcheck_round(
    claimed_sum: int,
    evaluator: Callable,
    q: int,
    num_vars: int
) -> dict:
    """
    Simulate one round of a Sumcheck-like protocol.
    
    The prover claims that ∑_{x ∈ F_q^n} f(x) = S.
    The verifier picks a random challenge and checks consistency.
    
    This is a simplified illustration of how Schwartz–Zippel
    underlies interactive proof soundness.
    
    Args:
        claimed_sum: The prover's claimed sum
        evaluator: Function that evaluates f
        q: Prime field size
        num_vars: Number of variables
    
    Returns:
        Verification result
    """
    from itertools import product as cartesian
    
    # Compute actual sum
    actual_sum = 0
    for x in cartesian(range(q), repeat=num_vars):
        actual_sum = (actual_sum + evaluator(list(x))) % q
    
    # Verifier checks by random evaluation
    challenge = [random.randint(0, q - 1) for _ in range(num_vars)]
    eval_at_challenge = evaluator(challenge) % q
    
    return {
        "claimed_sum": claimed_sum,
        "actual_sum": actual_sum,
        "claim_correct": claimed_sum % q == actual_sum,
        "challenge_point": challenge,
        "evaluation": eval_at_challenge,
        "note": "Full Sumcheck protocol would use multiple rounds with univariate reductions"
    }


# ============================================================
# Demonstrations
# ============================================================

def demo_fast_verification():
    """Demo: Fast matrix product verification."""
    print("=" * 60)
    print("APPLICATION 1: Fast Matrix Product Verification")
    print("=" * 60)
    
    q = 101  # Large prime for practical use
    n = 5
    
    np.random.seed(42)
    A = np.random.randint(0, q, (n, n))
    B = np.random.randint(0, q, (n, n))
    
    # Correct product
    C = np.zeros((n, n), dtype=int)
    for i in range(n):
        for j in range(n):
            C[i][j] = sum(int(A[i][k]) * int(B[k][j]) for k in range(n)) % q
    
    result = verify_matrix_product_fast(A, B, C, q, confidence=0.999)
    print(f"\nCorrect product test:")
    print(f"  Verdict: {result['verdict']}")
    print(f"  Repetitions: {result['repetitions']}")
    print(f"  Error bound: {result['error_bound']:.2e}")
    
    # Wrong product
    C_bad = C.copy()
    C_bad[0][0] = (C_bad[0][0] + 1) % q
    result = verify_matrix_product_fast(A, B, C_bad, q, confidence=0.999)
    print(f"\nWrong product test:")
    print(f"  Verdict: {result['verdict']}")
    print()


def demo_pit():
    """Demo: Polynomial identity testing."""
    print("=" * 60)
    print("APPLICATION 2: Polynomial Identity Testing")
    print("=" * 60)
    
    q = 97
    
    # Two representations of the same polynomial: (x+y)^2 vs x^2 + 2xy + y^2
    f = lambda pt: (pt[0] + pt[1]) ** 2 % q
    g = lambda pt: (pt[0]**2 + 2*pt[0]*pt[1] + pt[1]**2) % q
    
    result = polynomial_identity_test(f, g, 2, q, degree_bound=2)
    print(f"\n(x+y)² vs x² + 2xy + y²:")
    print(f"  Verdict: {result['verdict']}")
    print(f"  Disagreements: {result['disagreements']}/{result['tests']}")
    
    # Two different polynomials
    h = lambda pt: (pt[0]**2 + pt[1]**2) % q
    result = polynomial_identity_test(f, h, 2, q, degree_bound=2)
    print(f"\n(x+y)² vs x² + y²:")
    print(f"  Verdict: {result['verdict']}")
    print(f"  Disagreements: {result['disagreements']}/{result['tests']}")
    print()


def demo_coding_theory():
    """Demo: Parity-check code analysis."""
    print("=" * 60)
    print("APPLICATION 3: Parity-Check Code Analysis")
    print("=" * 60)
    
    q = 3
    # Simple [4, 2] code over F_3 with 2 parity checks
    H = np.array([
        [1, 1, 1, 0],
        [0, 1, 0, 1]
    ])
    
    result = parity_check_analysis(H, q)
    print(f"\nParity-check matrix H ({result['check_matrix_size']}) over F_{q}:")
    print(f"  H = {H.tolist()}")
    print(f"  Total words: {result['total_words']}")
    print(f"  Codewords: {result['codewords']}")
    print(f"  Code rate: {result['code_rate']:.4f}")
    print(f"  Freivalds bound (per row): {result['freivalds_bound']}")
    print()
    
    print("  Per-row analysis:")
    for row_info in result['per_row_analysis']:
        print(f"    Row {row_info['row']}: {row_info['coefficients']}")
        print(f"      Solutions: {row_info['solutions']}")
        print(f"      Fraction: {row_info['fraction']:.4f} (predicted: {row_info['predicted_fraction']:.4f})")
    print()
    print("  Each nonzero parity check accepts exactly 1/q of all words.")
    print()


if __name__ == "__main__":
    demo_fast_verification()
    demo_pit()
    demo_coding_theory()


#!/usr/bin/env python3
"""
Demonstration of Freivalds' Algorithm as a Degree-1 Schwartz–Zippel Instance

This script provides concrete numerical demonstrations of the key theorems:
1. Zero counts for linear forms over finite fields
2. Freivalds' matrix verification algorithm
3. Amplification via repeated testing
"""

import numpy as np
from itertools import product
import random


def mod_field(q: int):
    """Create basic finite field arithmetic modulo prime q."""
    class Fq:
        def __init__(self, val):
            self.val = val % q
        def __add__(self, other): return Fq(self.val + other.val)
        def __sub__(self, other): return Fq(self.val - other.val)
        def __mul__(self, other): return Fq(self.val * other.val)
        def __eq__(self, other): return self.val == other.val
        def __hash__(self): return hash(self.val)
        def __repr__(self): return str(self.val)
        def inv(self):
            if self.val == 0: raise ZeroDivisionError
            return Fq(pow(self.val, q - 2, q))
    return Fq


def count_linear_form_zeros(w: list, q: int) -> int:
    """
    Count the number of vectors r in F_q^p such that sum(w_j * r_j) = 0.
    
    Args:
        w: Coefficient vector (list of integers mod q)
        q: Prime field size
    
    Returns:
        Number of zero vectors
    """
    p = len(w)
    count = 0
    for r in product(range(q), repeat=p):
        dot = sum(w[j] * r[j] for j in range(p)) % q
        if dot == 0:
            count += 1
    return count


def demo_zero_counts():
    """Demonstrate that nonzero linear forms have exactly q^(p-1) zeros."""
    print("=" * 60)
    print("DEMO 1: Zero Counts for Linear Forms over Finite Fields")
    print("=" * 60)
    print()
    print("For a nonzero vector w in F_q^p, we count solutions to")
    print("  w_1*r_1 + w_2*r_2 + ... + w_p*r_p = 0  (mod q)")
    print()
    print(f"{'q':>3} {'p':>3} {'w':>15} {'q^p':>8} {'q^(p-1)':>8} {'Zeros':>8} {'Match?':>8}")
    print("-" * 60)
    
    test_cases = [
        (2, 3, [1, 0, 1]),
        (2, 3, [1, 1, 1]),
        (3, 3, [1, 2, 1]),
        (3, 2, [2, 1]),
        (5, 2, [3, 4]),
        (5, 3, [1, 2, 3]),
        (7, 2, [3, 5]),
        (7, 3, [1, 1, 1]),
    ]
    
    for q, p, w in test_cases:
        total = q ** p
        predicted = q ** (p - 1)
        observed = count_linear_form_zeros(w, q)
        match = "✓" if observed == predicted else "✗"
        print(f"{q:>3} {p:>3} {str(w):>15} {total:>8} {predicted:>8} {observed:>8} {match:>8}")
    
    print()
    print("All counts match q^(p-1) exactly — the hyperplane counting theorem.")
    print()


def matrix_mul_mod(A, B, q):
    """Matrix multiplication mod q."""
    m, n = A.shape
    _, p = B.shape
    C = np.zeros((m, p), dtype=int)
    for i in range(m):
        for j in range(p):
            C[i][j] = sum(int(A[i][k]) * int(B[k][j]) for k in range(n)) % q
    return C


def mat_vec_mod(M, v, q):
    """Matrix-vector multiplication mod q."""
    m, p = M.shape
    result = np.zeros(m, dtype=int)
    for i in range(m):
        result[i] = sum(int(M[i][j]) * int(v[j]) for j in range(p)) % q
    return result


def freivalds_test(A, B, C, q):
    """
    Run one iteration of Freivalds' test.
    
    Returns True if the test accepts (A*B might equal C),
    False if the test rejects (A*B definitely != C).
    """
    p = B.shape[1]
    r = np.array([random.randint(0, q - 1) for _ in range(p)])
    Br = mat_vec_mod(B, r, q)
    ABr = mat_vec_mod(A, Br, q)
    Cr = mat_vec_mod(C, r, q)
    return np.array_equal(ABr, Cr)


def demo_freivalds():
    """Demonstrate Freivalds' algorithm with concrete matrices."""
    print("=" * 60)
    print("DEMO 2: Freivalds' Matrix Verification Algorithm")
    print("=" * 60)
    print()
    
    q = 5
    n = 4
    trials = 10000
    
    # Create random matrices
    np.random.seed(42)
    A = np.random.randint(0, q, (n, n))
    B = np.random.randint(0, q, (n, n))
    C_correct = matrix_mul_mod(A, B, q)
    
    # Perturb C to create an incorrect claim
    C_wrong = C_correct.copy()
    C_wrong[0][0] = (C_wrong[0][0] + 1) % q
    
    print(f"Field: F_{q}")
    print(f"Matrix size: {n} × {n}")
    print(f"Trials: {trials}")
    print()
    
    # Test with correct product
    accepts_correct = sum(freivalds_test(A, B, C_correct, q) for _ in range(trials))
    print(f"Correct product (AB = C):")
    print(f"  Accepts: {accepts_correct}/{trials} (expected: {trials}/{trials})")
    print()
    
    # Test with wrong product
    accepts_wrong = sum(freivalds_test(A, B, C_wrong, q) for _ in range(trials))
    rate = accepts_wrong / trials
    print(f"Wrong product (AB ≠ C):")
    print(f"  False accepts: {accepts_wrong}/{trials}")
    print(f"  Observed rate: {rate:.4f}")
    print(f"  Predicted (1/q): {1/q:.4f}")
    print()


def demo_amplification():
    """Demonstrate error probability amplification."""
    print("=" * 60)
    print("DEMO 3: Amplification via Repeated Testing")
    print("=" * 60)
    print()
    
    q = 2
    n = 3
    outer_trials = 10000
    
    np.random.seed(123)
    A = np.random.randint(0, q, (n, n))
    B = np.random.randint(0, q, (n, n))
    C_correct = matrix_mul_mod(A, B, q)
    C_wrong = C_correct.copy()
    C_wrong[0][0] = (C_wrong[0][0] + 1) % q
    
    print(f"Field: F_{q}, Matrix size: {n}×{n}, Outer trials: {outer_trials}")
    print()
    print(f"{'k':>4} {'Predicted':>12} {'Observed':>12}")
    print("-" * 32)
    
    for k in [1, 2, 3, 5, 10, 15, 20]:
        false_accepts = 0
        for _ in range(outer_trials):
            # Run k independent tests
            all_accept = all(freivalds_test(A, B, C_wrong, q) for _ in range(k))
            if all_accept:
                false_accepts += 1
        observed = false_accepts / outer_trials
        predicted = (1 / q) ** k
        print(f"{k:>4} {predicted:>12.6f} {observed:>12.6f}")
    
    print()
    print("Error drops exponentially with repetitions — the power of amplification.")
    print()


def demo_polynomial_interpretation():
    """Demonstrate the polynomial identity testing interpretation."""
    print("=" * 60)
    print("DEMO 4: Polynomial Identity Testing Interpretation")
    print("=" * 60)
    print()
    
    q = 5
    p = 3
    
    # A nonzero linear polynomial P(x1, x2, x3) = 2*x1 + 3*x2 + 1*x3 over F_5
    w = [2, 3, 1]
    
    print(f"Polynomial: P(x1,x2,x3) = {w[0]}*x1 + {w[1]}*x2 + {w[2]}*x3 over F_{q}")
    print(f"Total degree: 1")
    print()
    
    # Count zeros
    zeros = []
    for r in product(range(q), repeat=p):
        val = sum(w[j] * r[j] for j in range(p)) % q
        if val == 0:
            zeros.append(r)
    
    print(f"Total evaluation points: {q**p}")
    print(f"Zeros found: {len(zeros)}")
    print(f"Schwartz–Zippel bound (deg * q^(p-1)): {1 * q**(p-1)}")
    print(f"Fraction of zeros: {len(zeros)}/{q**p} = {len(zeros)/q**p:.4f}")
    print(f"Predicted fraction (deg/q): {1/q:.4f}")
    print()
    
    # Show some zeros
    print("First 10 zeros:")
    for r in zeros[:10]:
        check = sum(w[j] * r[j] for j in range(p)) % q
        print(f"  P{r} = {check}")
    print()
    print("This is EXACTLY Freivalds' bound: the error polynomial has degree 1,")
    print("so at most 1/q of random inputs are zeros.")


if __name__ == "__main__":
    demo_zero_counts()
    demo_freivalds()
    demo_amplification()
    demo_polynomial_interpretation()


#!/usr/bin/env python3
"""
Visualizations for Freivalds–Schwartz–Zippel Connection

Generates publication-quality figures illustrating the key concepts.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import product as cartesian
import base64
import io


def fig_to_base64(fig) -> str:
    """Convert a matplotlib figure to a base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def plot_hyperplane_zero_set():
    """Visualize the zero set of a linear form over a small finite field."""
    q = 5
    w = [2, 3]  # Linear form: 2*x + 3*y over F_5
    
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Left: All points, colored by evaluation
    ax = axes[0]
    for x in range(q):
        for y in range(q):
            val = (w[0] * x + w[1] * y) % q
            color = plt.cm.viridis(val / (q - 1))
            ax.scatter(x, y, c=[color], s=200, edgecolors='black', linewidths=0.5, zorder=5)
            ax.annotate(str(val), (x, y), ha='center', va='center', fontsize=8, fontweight='bold', color='white')
    
    ax.set_xlim(-0.5, q - 0.5)
    ax.set_ylim(-0.5, q - 0.5)
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('y', fontsize=12)
    ax.set_title(f'Evaluation of P(x,y) = {w[0]}x + {w[1]}y over F_{q}', fontsize=13)
    ax.set_xticks(range(q))
    ax.set_yticks(range(q))
    ax.grid(True, alpha=0.3)
    ax.set_aspect('equal')
    
    # Right: Zero set highlighted
    ax = axes[1]
    zeros_x, zeros_y = [], []
    nonzeros_x, nonzeros_y = [], []
    for x in range(q):
        for y in range(q):
            val = (w[0] * x + w[1] * y) % q
            if val == 0:
                zeros_x.append(x)
                zeros_y.append(y)
            else:
                nonzeros_x.append(x)
                nonzeros_y.append(y)
    
    ax.scatter(nonzeros_x, nonzeros_y, c='lightgray', s=150, edgecolors='gray', linewidths=0.5, zorder=4, label=f'P ≠ 0 ({len(nonzeros_x)} points)')
    ax.scatter(zeros_x, zeros_y, c='red', s=250, edgecolors='darkred', linewidths=1.5, zorder=5, marker='*', label=f'P = 0 ({len(zeros_x)} points)')
    
    ax.set_xlim(-0.5, q - 0.5)
    ax.set_ylim(-0.5, q - 0.5)
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('y', fontsize=12)
    ax.set_title(f'Zero Set: {len(zeros_x)}/{q**2} = q^(p-1) = {q}^1 = {q}', fontsize=13)
    ax.set_xticks(range(q))
    ax.set_yticks(range(q))
    ax.grid(True, alpha=0.3)
    ax.set_aspect('equal')
    ax.legend(fontsize=10, loc='upper right')
    
    fig.suptitle('Linear Form Zero Set Over a Finite Field', fontsize=15, fontweight='bold', y=1.02)
    fig.tight_layout()
    
    fig.savefig('viz_hyperplane.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def plot_amplification_curve():
    """Plot the exponential decay of error probability with repetitions."""
    fig, ax = plt.subplots(figsize=(10, 6))
    
    primes = [2, 3, 5, 7, 11]
    colors = plt.cm.tab10(np.linspace(0, 0.5, len(primes)))
    
    k_values = np.arange(1, 21)
    
    for q, color in zip(primes, colors):
        error_probs = [(1/q)**k for k in k_values]
        ax.semilogy(k_values, error_probs, 'o-', color=color, label=f'q = {q}', 
                    markersize=5, linewidth=2)
    
    ax.set_xlabel('Number of repetitions (k)', fontsize=13)
    ax.set_ylabel('Error probability upper bound', fontsize=13)
    ax.set_title('Freivalds Error Amplification: Pr[false accept] ≤ (1/q)^k', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11, title='Field size q')
    ax.grid(True, alpha=0.3, which='both')
    ax.set_xticks(k_values)
    ax.set_ylim(1e-20, 1)
    
    fig.tight_layout()
    fig.savefig('viz_amplification.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def plot_kernel_sizes():
    """Compare actual kernel sizes with the q^(p-1) bound."""
    fig, ax = plt.subplots(figsize=(10, 6))
    
    import random as rnd
    rnd.seed(42)
    
    q = 3
    results = []
    
    for p in range(1, 6):
        bound = q ** (p - 1)
        
        # Generate several random nonzero matrices and compute kernel sizes
        kernel_sizes = []
        for _ in range(min(20, q**(2*p))):
            # Random matrix with 2 rows
            m = 2
            M = np.array([[rnd.randint(0, q-1) for _ in range(p)] for _ in range(m)])
            
            # Check nonzero
            if all(M[i][j] % q == 0 for i in range(m) for j in range(p)):
                continue
            
            # Count kernel
            ker_size = 0
            for r in cartesian(range(q), repeat=p):
                r_arr = np.array(r)
                result = np.array([sum(int(M[i][j]) * int(r_arr[j]) for j in range(p)) % q for i in range(m)])
                if all(result[i] == 0 for i in range(m)):
                    ker_size += 1
            kernel_sizes.append(ker_size)
        
        if kernel_sizes:
            results.append((p, bound, kernel_sizes))
    
    x_positions = []
    for p, bound, ksizes in results:
        x_pos = [p + (rnd.random() - 0.5) * 0.3 for _ in ksizes]
        x_positions.append(x_pos)
        ax.scatter(x_pos, ksizes, c='steelblue', alpha=0.6, s=40, zorder=5)
    
    ps = [r[0] for r in results]
    bounds = [r[1] for r in results]
    ax.plot(ps, bounds, 'r--', linewidth=2, label=f'Bound: q^(p-1) = {q}^(p-1)', zorder=10)
    ax.scatter(ps, bounds, c='red', s=100, zorder=10, marker='D')
    
    ax.set_xlabel('Number of columns (p)', fontsize=13)
    ax.set_ylabel('Kernel size', fontsize=13)
    ax.set_title(f'Kernel Sizes vs Freivalds Bound (q = {q}, m = 2)', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.set_xticks(ps)
    ax.grid(True, alpha=0.3)
    
    fig.tight_layout()
    fig.savefig('viz_kernel_sizes.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def plot_degree_vs_zeros():
    """Show how polynomial degree controls the zero fraction."""
    fig, ax = plt.subplots(figsize=(10, 6))
    
    q = 7
    p = 2  # Two variables for tractability
    
    degrees = []
    zero_fractions = []
    sz_bounds = []
    
    # Degree 1: linear
    w = [1, 3]
    zeros_d1 = sum(1 for x, y in cartesian(range(q), repeat=2) if (w[0]*x + w[1]*y) % q == 0)
    degrees.append(1)
    zero_fractions.append(zeros_d1 / q**2)
    sz_bounds.append(1 / q)
    
    # Degree 2: quadratic
    zeros_d2 = sum(1 for x, y in cartesian(range(q), repeat=2) if (x**2 + 2*x*y + 3*y**2) % q == 0)
    degrees.append(2)
    zero_fractions.append(zeros_d2 / q**2)
    sz_bounds.append(2 / q)
    
    # Degree 3
    zeros_d3 = sum(1 for x, y in cartesian(range(q), repeat=2) if (x**3 + x*y**2 + y**3) % q == 0)
    degrees.append(3)
    zero_fractions.append(zeros_d3 / q**2)
    sz_bounds.append(3 / q)
    
    # Degree 4
    zeros_d4 = sum(1 for x, y in cartesian(range(q), repeat=2) if (x**4 + x**2*y**2 + y**4 + x) % q == 0)
    degrees.append(4)
    zero_fractions.append(zeros_d4 / q**2)
    sz_bounds.append(4 / q)
    
    # Degree 5
    zeros_d5 = sum(1 for x, y in cartesian(range(q), repeat=2) if (x**5 + y**5 + x*y) % q == 0)
    degrees.append(5)
    zero_fractions.append(zeros_d5 / q**2)
    sz_bounds.append(5 / q)
    
    bar_width = 0.35
    x = np.arange(len(degrees))
    
    ax.bar(x - bar_width/2, zero_fractions, bar_width, label='Actual zero fraction', color='steelblue', edgecolor='navy')
    ax.bar(x + bar_width/2, sz_bounds, bar_width, label='Schwartz–Zippel bound (d/q)', color='tomato', edgecolor='darkred', alpha=0.7)
    
    ax.set_xlabel('Polynomial degree (d)', fontsize=13)
    ax.set_ylabel('Fraction of zeros', fontsize=13)
    ax.set_title(f'Degree Controls Zero Density (F_{q}, {p} variables)', fontsize=14, fontweight='bold')
    ax.set_xticks(x)
    ax.set_xticklabels(degrees)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3, axis='y')
    
    fig.tight_layout()
    fig.savefig('viz_degree_vs_zeros.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


if __name__ == "__main__":
    print("Generating visualizations...")
    
    b64_hyperplane = plot_hyperplane_zero_set()
    print("  ✓ Hyperplane zero set")
    
    b64_amplification = plot_amplification_curve()
    print("  ✓ Amplification curve")
    
    b64_kernel = plot_kernel_sizes()
    print("  ✓ Kernel sizes")
    
    b64_degree = plot_degree_vs_zeros()
    print("  ✓ Degree vs zeros")
    
    print("\nAll visualizations saved as PNG files.")
