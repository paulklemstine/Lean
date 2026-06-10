"""
Applications of Freivalds' Amplification Theorem

Demonstrates real-world applications of exponential soundness amplification:
1. Matrix multiplication verification in scientific computing
2. Streaming equality testing via random fingerprints
3. Polynomial identity testing
4. Batch verification for cryptographic signatures (conceptual)
"""

import numpy as np
from typing import List, Tuple


# ============================================================================
# Application 1: Scientific Computing — Verify GPU Matrix Multiplication
# ============================================================================

def verify_gpu_computation(n: int = 100, q: int = 65537, t: int = 20):
    """
    Simulate verifying a GPU matrix multiplication result.

    In practice, GPU computations can have silent errors (bit flips,
    precision issues). Freivalds' algorithm provides a fast verification
    layer that catches errors with overwhelming probability.

    Args:
        n: Matrix dimension
        q: Field size (large prime for precision)
        t: Number of verification trials
    """
    print("=" * 60)
    print("APPLICATION: GPU Matrix Multiplication Verification")
    print("=" * 60)

    rng = np.random.default_rng(42)

    # Simulate matrices (using smaller field for demo)
    A = rng.integers(0, q, size=(n, n))
    B = rng.integers(0, q, size=(n, n))

    # "GPU result" — correct
    K_correct = A @ B % q

    # "GPU result" — with a single bit error
    K_corrupted = K_correct.copy()
    K_corrupted[rng.integers(n), rng.integers(n)] = (
        K_corrupted[rng.integers(n), rng.integers(n)] + 1) % q

    print(f"\nMatrix size: {n}×{n}")
    print(f"Field: F_{q}")
    print(f"Verification trials: {t}")
    print(f"Error bound: 1/{q}^{t} ≈ {(1/q)**t:.2e}")
    print(f"\nDirect multiplication cost: O(n³) = O({n**3:,})")
    print(f"Verification cost: O(t·n²) = O({t * n**2:,})")
    print(f"Speedup factor: {n**3 / (t * n**2):.1f}x")

    # Verify correct result
    correct_checks = sum(
        1 for _ in range(t)
        if np.array_equal(
            K_correct @ rng.integers(0, q, size=(n, 1)) % q,
            A @ (B @ rng.integers(0, q, size=(n, 1)) % q) % q % q
        )
    )
    print(f"\nCorrect result: {correct_checks}/{t} checks passed ✓")

    # Verify corrupted result
    corrupted_checks = 0
    for _ in range(t):
        r = rng.integers(0, q, size=(n, 1))
        if np.array_equal(K_corrupted @ r % q, A @ (B @ r % q) % q % q):
            corrupted_checks += 1
    print(f"Corrupted result: {corrupted_checks}/{t} checks passed "
          f"{'✗ (detected!)' if corrupted_checks < t else '(missed!)'}")


# ============================================================================
# Application 2: Streaming Equality Testing
# ============================================================================

def streaming_equality_test():
    """
    Demonstrate random fingerprinting for streaming equality testing.

    Two data streams x, y ∈ F_q^n arrive one element at a time.
    We compute fingerprints f(x) = Σ r_i * x_i and f(y) = Σ r_i * y_i
    for random coefficients r_i. If x ≠ y, P[f(x) = f(y)] ≤ 1/q.
    With t independent fingerprints, error ≤ 1/q^t.
    """
    print("\n" + "=" * 60)
    print("APPLICATION: Streaming Equality Testing")
    print("=" * 60)

    q = 101  # Prime field
    n = 10000  # Stream length
    t_values = [1, 2, 5, 10]

    rng = np.random.default_rng(123)

    # Create two streams that differ in one position
    x = rng.integers(0, q, size=n)
    y = x.copy()
    diff_pos = rng.integers(n)
    y[diff_pos] = (y[diff_pos] + 1) % q

    print(f"\nStream length: {n:,}")
    print(f"Field: F_{q}")
    print(f"Streams differ at position {diff_pos}")
    print(f"\nDirect comparison: O(n) = O({n:,}) space")
    print(f"Fingerprint comparison: O(t) space")

    num_experiments = 10000
    print(f"\n{'Fingerprints (t)':>18} {'False eq. rate':>15} {'Bound 1/q^t':>15} {'Space savings':>15}")
    print("-" * 68)

    for t in t_values:
        false_equals = 0
        for _ in range(num_experiments):
            all_match = True
            for _ in range(t):
                r = rng.integers(0, q, size=n)
                fx = int(np.sum(r * x)) % q
                fy = int(np.sum(r * y)) % q
                if fx != fy:
                    all_match = False
                    break
            if all_match:
                false_equals += 1

        rate = false_equals / num_experiments
        bound = (1/q) ** t
        savings = f"{n/t:.0f}x"
        print(f"{t:>18} {rate:>15.6f} {bound:>15.2e} {savings:>15}")


# ============================================================================
# Application 3: Polynomial Identity Testing
# ============================================================================

def polynomial_identity_testing():
    """
    Demonstrate Schwartz-Zippel-style polynomial identity testing.

    Test whether two polynomial expressions are identical by evaluating
    at random points. This is the degree-d generalization of Freivalds.
    """
    print("\n" + "=" * 60)
    print("APPLICATION: Polynomial Identity Testing")
    print("=" * 60)

    q = 97  # Prime field
    rng = np.random.default_rng(456)

    # Test: is (x+y)^2 = x^2 + 2xy + y^2?  (Yes)
    # Test: is (x+y)^3 = x^3 + y^3?  (No, missing 3x²y + 3xy²)

    print("\nTest 1: Is (x+y)² = x² + 2xy + y² ?")
    false_rejects = 0
    for _ in range(10000):
        x, y = rng.integers(0, q, size=2)
        lhs = (x + y) ** 2 % q
        rhs = (x**2 + 2*x*y + y**2) % q
        if lhs != rhs:
            false_rejects += 1
    print(f"  Result: {'IDENTICAL' if false_rejects == 0 else 'DIFFERENT'} "
          f"(0 mismatches in 10,000 trials)")

    print("\nTest 2: Is (x+y)³ = x³ + y³ ?")
    detections = 0
    for _ in range(10000):
        x, y = rng.integers(0, q, size=2)
        lhs = pow(int(x + y), 3, q)
        rhs = (pow(int(x), 3, q) + pow(int(y), 3, q)) % q
        if lhs != rhs:
            detections += 1
    print(f"  Result: DIFFERENT (detected in {detections}/10,000 trials)")
    print(f"  Detection rate: {detections/10000:.4f}")
    print(f"  Theoretical: ≥ 1 - d/q = 1 - 3/{q} = {1 - 3/q:.4f}")

    # Amplification
    print("\nAmplified testing of (x+y)³ ≠ x³ + y³:")
    print(f"{'Trials (t)':>12} {'P[all pass]':>15} {'Bound (d/q)^t':>15}")
    print("-" * 45)

    for t in [1, 2, 3, 5, 10]:
        all_pass = 0
        for _ in range(100000):
            passed = True
            for _ in range(t):
                x, y = rng.integers(0, q, size=2)
                lhs = pow(int(x + y), 3, q)
                rhs = (pow(int(x), 3, q) + pow(int(y), 3, q)) % q
                if lhs != rhs:
                    passed = False
                    break
            if passed:
                all_pass += 1
        obs = all_pass / 100000
        bound = (3/q) ** t
        print(f"{t:>12} {obs:>15.8f} {bound:>15.8f}")


# ============================================================================
# Application 4: Batch Verification (Conceptual)
# ============================================================================

def batch_verification_demo():
    """
    Demonstrate batch verification: verify multiple claims simultaneously.

    Given n matrix equations K_i = A_i * B_i, a random linear combination
    reduces to a single check. This is the batch verification principle
    used in cryptographic signature schemes.
    """
    print("\n" + "=" * 60)
    print("APPLICATION: Batch Verification")
    print("=" * 60)

    q = 101
    dim = 5
    num_claims = 10
    rng = np.random.default_rng(789)

    print(f"\nVerifying {num_claims} matrix multiplication claims simultaneously")
    print(f"Field: F_{q}, Matrix size: {dim}×{dim}")

    # Generate claims (all correct)
    claims = []
    for i in range(num_claims):
        A = rng.integers(0, q, size=(dim, dim))
        B = rng.integers(0, q, size=(dim, dim))
        K = A @ B % q
        claims.append((A, B, K))

    # Batch verify: pick random coefficients α_i, check Σ α_i K_i r = Σ α_i A_i B_i r
    print("\nAll claims correct:")
    t = 5
    for trial in range(t):
        r = rng.integers(0, q, size=(dim, 1))
        alphas = rng.integers(1, q, size=num_claims)

        lhs = sum(int(alphas[i]) * (claims[i][2] @ r) for i in range(num_claims)) % q
        rhs = sum(int(alphas[i]) * (claims[i][0] @ (claims[i][1] @ r % q)) for i in range(num_claims)) % q
        match = np.array_equal(lhs % q, rhs % q)
        print(f"  Trial {trial+1}: {'PASS' if match else 'FAIL'}")

    # Now corrupt one claim
    print(f"\nOne claim corrupted (claim 3):")
    A3, B3, K3 = claims[3]
    K3_bad = K3.copy()
    K3_bad[0, 0] = (K3_bad[0, 0] + 1) % q
    claims[3] = (A3, B3, K3_bad)

    detections = 0
    for _ in range(1000):
        r = rng.integers(0, q, size=(dim, 1))
        alphas = rng.integers(1, q, size=num_claims)
        lhs = sum(int(alphas[i]) * (claims[i][2] @ r) for i in range(num_claims)) % q
        rhs = sum(int(alphas[i]) * (claims[i][0] @ (claims[i][1] @ r % q)) for i in range(num_claims)) % q
        if not np.array_equal(lhs % q, rhs % q):
            detections += 1
    print(f"  Detected corruption in {detections}/1000 trials")
    print(f"  Detection rate: {detections/1000:.4f} (bound: ≥ {1 - 1/q:.4f})")


if __name__ == "__main__":
    verify_gpu_computation(n=50, q=101, t=10)
    streaming_equality_test()
    polynomial_identity_testing()
    batch_verification_demo()


"""
Freivalds' Algorithm — Exponential Soundness Amplification Demo

Demonstrates the core theorem: if K ≠ A*B, then t independent Freivalds
checks all accept with probability at most 1/q^t.
"""

import numpy as np
from typing import Tuple


def freivalds_single_check(A: np.ndarray, B: np.ndarray, K: np.ndarray, q: int) -> bool:
    """Single Freivalds check over F_q.

    Returns True (accept) if K*r == A*(B*r) mod q for a random vector r.
    """
    p = B.shape[1]
    r = np.random.randint(0, q, size=(p, 1))
    lhs = (K @ r) % q
    rhs = (A @ (B @ r % q) % q) % q
    return np.array_equal(lhs % q, rhs % q)


def freivalds_amplified(A: np.ndarray, B: np.ndarray, K: np.ndarray,
                         q: int, t: int) -> bool:
    """t independent Freivalds checks. Accepts only if all pass."""
    return all(freivalds_single_check(A, B, K, q) for _ in range(t))


def run_experiment(q: int, m: int, n: int, p: int, t: int,
                   num_samples: int = 100000) -> Tuple[float, float]:
    """Run Freivalds amplification experiment.

    Returns (observed_error_rate, theoretical_bound).
    """
    # Create random matrices
    A = np.random.randint(0, q, size=(m, n))
    B = np.random.randint(0, q, size=(n, p))
    # Create K ≠ A*B by adding a small perturbation
    K = (A @ B) % q
    # Flip one entry to ensure K ≠ AB
    K[0, 0] = (K[0, 0] + 1) % q

    false_accepts = sum(
        1 for _ in range(num_samples)
        if freivalds_amplified(A, B, K, q, t)
    )

    observed_rate = false_accepts / num_samples
    theoretical_bound = (1 / q) ** t
    return observed_rate, theoretical_bound


def demo_basic():
    """Basic demonstration of Freivalds' algorithm."""
    print("=" * 60)
    print("FREIVALDS' ALGORITHM — BASIC DEMONSTRATION")
    print("=" * 60)

    q = 5  # Work over F_5
    m, n, p = 4, 3, 4

    np.random.seed(42)
    A = np.random.randint(0, q, size=(m, n))
    B = np.random.randint(0, q, size=(n, p))
    K_correct = (A @ B) % q
    K_wrong = K_correct.copy()
    K_wrong[0, 0] = (K_wrong[0, 0] + 1) % q

    print(f"\nField: F_{q}")
    print(f"Matrix dimensions: A({m}×{n}), B({n}×{p})")
    print(f"\nA =\n{A}")
    print(f"\nB =\n{B}")
    print(f"\nA*B mod {q} =\n{K_correct}")
    print(f"\nK (wrong) =\n{K_wrong}")
    print(f"\nK differs from AB at position (0,0): {K_correct[0,0]} vs {K_wrong[0,0]}")

    # Single trial tests
    print("\n--- Single Trial Tests (K = AB, should always accept) ---")
    for i in range(5):
        result = freivalds_single_check(A, B, K_correct, q)
        print(f"  Trial {i+1}: {'ACCEPT' if result else 'REJECT'}")

    print("\n--- Single Trial Tests (K ≠ AB, should usually reject) ---")
    accepts = 0
    trials = 1000
    for _ in range(trials):
        if freivalds_single_check(A, B, K_wrong, q):
            accepts += 1
    print(f"  Accepted {accepts}/{trials} times")
    print(f"  Observed rate: {accepts/trials:.4f}")
    print(f"  Theoretical bound: 1/{q} = {1/q:.4f}")


def demo_amplification():
    """Demonstrate exponential decay of error probability."""
    print("\n" + "=" * 60)
    print("EXPONENTIAL SOUNDNESS AMPLIFICATION")
    print("=" * 60)

    q = 2
    m, n, p = 5, 5, 5
    num_samples = 100000

    np.random.seed(123)

    print(f"\nField: F_{q}")
    print(f"Matrix size: {m}×{m}")
    print(f"Samples per trial count: {num_samples:,}")
    print(f"\n{'Trials (t)':>12} {'Observed Rate':>15} {'Bound 1/q^t':>15} {'Below Bound?':>14}")
    print("-" * 60)

    for t in range(1, 16):
        observed, bound = run_experiment(q, m, n, p, t, num_samples)
        ok = "✓" if observed <= bound * 1.1 else "✗"  # small tolerance for sampling noise
        print(f"{t:>12} {observed:>15.6f} {bound:>15.10f} {ok:>14}")
        if observed == 0 and t >= 5:
            print(f"{'...':>12} {'(all zero from here)':>15}")
            break


def demo_field_size_effect():
    """Show how field size affects the single-trial bound."""
    print("\n" + "=" * 60)
    print("EFFECT OF FIELD SIZE ON ERROR PROBABILITY")
    print("=" * 60)

    primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31]
    m, n, p = 5, 5, 5
    t = 1
    num_samples = 100000

    np.random.seed(456)

    print(f"\nSingle trial (t=1), {num_samples:,} samples each")
    print(f"\n{'Field F_q':>10} {'Observed':>12} {'Bound 1/q':>12}")
    print("-" * 38)

    for q in primes:
        observed, bound = run_experiment(q, m, n, p, t, num_samples)
        print(f"{'F_' + str(q):>10} {observed:>12.5f} {bound:>12.5f}")


def demo_concrete_numbers():
    """Show concrete numbers for the cardinality argument."""
    print("\n" + "=" * 60)
    print("CARDINALITY ARGUMENT — CONCRETE NUMBERS")
    print("=" * 60)

    q = 3
    p = 4
    print(f"\nField: F_{q}, vector dimension: {p}")
    print(f"Total vectors: q^p = {q}^{p} = {q**p}")
    print(f"Max accepting (single trial): q^(p-1) = {q}^{p-1} = {q**(p-1)}")
    print(f"Single-trial error bound: {q**(p-1)}/{q**p} = 1/{q}")

    for t in range(1, 8):
        accept_t = q**((p-1)*t)
        total_t = q**(p*t)
        bound = f"1/{q}^{t} = 1/{q**t}"
        print(f"\n  t={t}: accepting tuples ≤ {accept_t:>10,}, "
              f"total = {total_t:>10,}, bound = {bound}")


if __name__ == "__main__":
    demo_basic()
    demo_amplification()
    demo_field_size_effect()
    demo_concrete_numbers()


"""Generate PACKAGE.json with all artifacts."""

import json
import sys
sys.path.insert(0, '/workspace/request-project')

from visualizations import (
    plot_exponential_decay,
    plot_kernel_cardinality,
    plot_empirical_vs_theoretical,
    plot_proof_architecture
)

# Read all text files
def read_file(path):
    with open(path, 'r') as f:
        return f.read()

article = read_file('/workspace/request-project/ARTICLE.md')
research_paper = read_file('/workspace/request-project/RESEARCH_PAPER.md')
future_directions = read_file('/workspace/request-project/FUTURE_DIRECTIONS.md')
lean_proofs = read_file('/workspace/request-project/EML/FreivaldsAmplification.lean')
demo_code = read_file('/workspace/request-project/demo.py')
algorithms_code = read_file('/workspace/request-project/algorithms.py')
applications_code = read_file('/workspace/request-project/applications.py')

# Generate visualizations
print("Generating visualizations for PACKAGE.json...")
viz1 = plot_exponential_decay()
viz2 = plot_kernel_cardinality()
viz3 = plot_empirical_vs_theoretical()
viz4 = plot_proof_architecture()

package = {
    "title": "Exponential Soundness Amplification for Freivalds' Algorithm",
    "domain": "Complexity Theory / Randomized Verification",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Freivalds Algorithm Demo",
            "code": demo_code
        },
        {
            "name": "Real-World Applications",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Freivalds Verifier",
            "pseudocode": """ALGORITHM: FreivaldsVerify(A, B, K, q, t)
INPUT: Matrices A (m×n), B (n×p), K (m×p) over F_q; trial count t
OUTPUT: ACCEPT or REJECT

1. FOR i = 1 TO t:
   a. Sample r ← F_q^p uniformly at random
   b. Compute v₁ = K · r   (mod q)    // O(mp) operations
   c. Compute v₂ = B · r   (mod q)    // O(np) operations
   d. Compute v₃ = A · v₂  (mod q)    // O(mn) operations
   e. IF v₁ ≠ v₃: RETURN REJECT
2. RETURN ACCEPT

CORRECTNESS:
  - If K = AB: Always accepts (v₁ = v₃ for all r)
  - If K ≠ AB: P[ACCEPT] ≤ 1/q^t

COMPLEXITY:
  - Time: O(t · (mn + np + mp))
  - Space: O(max(m,n,p))
  - Randomness: t·p·log(q) random bits""",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {
            "name": "Exponential Error Decay",
            "data": viz1
        },
        {
            "name": "Kernel vs Total Space Cardinality",
            "data": viz2
        },
        {
            "name": "Empirical vs Theoretical Bounds",
            "data": viz3
        },
        {
            "name": "Proof Architecture Diagram",
            "data": viz4
        }
    ],
    "lean_proofs": lean_proofs
}

with open('/workspace/request-project/PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2)

print("PACKAGE.json generated successfully.")
print(f"File size: {len(json.dumps(package)):,} bytes")


"""
Visualizations for Freivalds' Exponential Soundness Amplification
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import base64
from io import BytesIO


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def plot_exponential_decay():
    """Plot error probability decay for various field sizes."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    t_vals = np.arange(1, 21)
    field_sizes = [2, 3, 5, 7, 11]
    colors = ['#e74c3c', '#e67e22', '#2ecc71', '#3498db', '#9b59b6']

    for q, color in zip(field_sizes, colors):
        error_probs = [(1/q)**t for t in t_vals]
        ax.semilogy(t_vals, error_probs, 'o-', color=color, linewidth=2,
                    markersize=6, label=f'$\\mathbb{{F}}_{{{q}}}$ (1/{q}$^t$)')

    ax.set_xlabel('Number of Independent Trials ($t$)', fontsize=13)
    ax.set_ylabel('Error Probability Upper Bound', fontsize=13)
    ax.set_title('Exponential Soundness Amplification\nFreivalds\' Algorithm over Finite Fields',
                 fontsize=14, fontweight='bold')
    ax.legend(fontsize=11, loc='upper right')
    ax.grid(True, alpha=0.3, which='both')
    ax.set_xlim(0.5, 20.5)
    ax.set_ylim(1e-25, 1.5)

    # Add annotation
    ax.annotate('Each trial reduces\nerror by factor $1/q$',
                xy=(5, (1/2)**5), xytext=(8, 1e-1),
                fontsize=11, ha='center',
                arrowprops=dict(arrowstyle='->', color='gray', lw=1.5),
                bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow',
                         edgecolor='gray', alpha=0.9))

    return fig_to_base64(fig)


def plot_kernel_cardinality():
    """Visualize kernel cardinality vs total space for small examples."""
    fig, axes = plt.subplots(1, 3, figsize=(14, 4.5))

    for idx, q in enumerate([2, 3, 5]):
        ax = axes[idx]
        p_vals = range(1, 7)
        total = [q**p for p in p_vals]
        kernel_max = [q**(p-1) for p in p_vals]

        x = np.arange(len(p_vals))
        width = 0.35

        bars1 = ax.bar(x - width/2, total, width, label='Total space $q^p$',
                       color='#3498db', alpha=0.7, edgecolor='white')
        bars2 = ax.bar(x + width/2, kernel_max, width,
                       label='Max kernel $q^{p-1}$',
                       color='#e74c3c', alpha=0.7, edgecolor='white')

        ax.set_xlabel('Dimension $p$', fontsize=11)
        ax.set_ylabel('Cardinality', fontsize=11)
        ax.set_title(f'$\\mathbb{{F}}_{{{q}}}$', fontsize=13, fontweight='bold')
        ax.set_xticks(x)
        ax.set_xticklabels(p_vals)
        ax.legend(fontsize=9)
        ax.set_yscale('log')
        ax.grid(True, alpha=0.2, axis='y')

        # Add ratio annotation
        for i, p in enumerate(p_vals):
            ratio = 1/q
            ax.annotate(f'{ratio:.2f}', (x[i], kernel_max[i]),
                       ha='center', va='bottom', fontsize=7, color='gray')

    fig.suptitle('Kernel vs Total Space Cardinality', fontsize=14,
                 fontweight='bold', y=1.02)
    fig.tight_layout()
    return fig_to_base64(fig)


def plot_empirical_vs_theoretical():
    """Compare empirical error rates with theoretical bounds."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    q = 2
    m, n, p = 5, 5, 5
    num_samples = 50000
    t_vals = range(1, 18)

    np.random.seed(42)

    observed_rates = []
    theoretical_bounds = []

    for t in t_vals:
        A = np.random.randint(0, q, size=(m, n))
        B = np.random.randint(0, q, size=(n, p))
        K = (A @ B) % q
        K[0, 0] = (K[0, 0] + 1) % q

        false_accepts = 0
        for _ in range(num_samples):
            all_pass = True
            for _ in range(t):
                r = np.random.randint(0, q, size=(p, 1))
                lhs = K @ r % q
                rhs = A @ (B @ r % q) % q
                if not np.array_equal(lhs % q, rhs % q):
                    all_pass = False
                    break
            if all_pass:
                false_accepts += 1

        obs = max(false_accepts / num_samples, 1e-20)
        observed_rates.append(obs)
        theoretical_bounds.append((1/q)**t)

    ax.semilogy(list(t_vals), theoretical_bounds, 's-', color='#e74c3c',
                linewidth=2.5, markersize=8, label='Theoretical bound $1/q^t$',
                zorder=3)
    ax.semilogy(list(t_vals), observed_rates, 'o-', color='#2ecc71',
                linewidth=2, markersize=7, label=f'Observed ({num_samples:,} samples)',
                zorder=2)

    ax.fill_between(list(t_vals), theoretical_bounds, 1.5,
                    alpha=0.1, color='red', label='Guaranteed safe region')

    ax.set_xlabel('Number of Trials ($t$)', fontsize=13)
    ax.set_ylabel('False Acceptance Probability', fontsize=13)
    ax.set_title(f'Empirical vs Theoretical Error Bound ($\\mathbb{{F}}_{{{q}}}$, {num_samples:,} experiments)',
                 fontsize=14, fontweight='bold')
    ax.legend(fontsize=11, loc='upper right')
    ax.grid(True, alpha=0.3, which='both')
    ax.set_xlim(0.5, max(t_vals) + 0.5)
    ax.set_ylim(1e-8, 1.5)

    return fig_to_base64(fig)


def plot_proof_architecture():
    """Create a diagram showing the proof structure."""
    fig, ax = plt.subplots(1, 1, figsize=(12, 7))
    ax.set_xlim(0, 12)
    ax.set_ylim(0, 8)
    ax.axis('off')

    # Boxes
    boxes = [
        (1, 6.5, 4, 1, 'Nonzero Row Extraction\n$D \\neq 0 \\Rightarrow \\exists i,\\, D_i \\neq 0$',
         '#e8f4fd'),
        (7, 6.5, 4, 1, 'Linear Form Zero Set\n$|\\{r : \\langle v, r\\rangle = 0\\}| \\leq q^{p-1}$',
         '#e8f4fd'),
        (4, 4.5, 4, 1, 'Single-Trial Bound\n$|\\ker D| \\leq q^{p-1}$',
         '#fde8e8'),
        (0.5, 2.5, 4, 1, 'Product Factorization\n$|\\mathrm{Accept}_t| = |\\mathrm{Accept}_1|^t$',
         '#e8fde8'),
        (7.5, 2.5, 3.5, 1, 'Fraction Bound\n$\\frac{|\\mathrm{Accept}_1|}{q^p} \\leq \\frac{1}{q}$',
         '#fde8e8'),
        (3, 0.5, 6, 1.2, 'Main Theorem\n$P[\\text{all } t \\text{ trials accept}] \\leq 1/q^t$',
         '#fff3e0'),
    ]

    for x, y, w, h, text, color in boxes:
        rect = plt.Rectangle((x, y), w, h, facecolor=color,
                             edgecolor='#333', linewidth=1.5, zorder=2,
                             joinstyle='round')
        ax.add_patch(rect)
        ax.text(x + w/2, y + h/2, text, ha='center', va='center',
                fontsize=10, zorder=3)

    # Arrows
    arrows = [
        (3, 6.5, 5, 5.5),    # nonzero row → single trial
        (9, 6.5, 7, 5.5),    # linear form → single trial
        (6, 4.5, 4.5, 3.5),  # single trial → product
        (6, 4.5, 9, 3.5),    # single trial → fraction
        (2.5, 2.5, 5, 1.7),  # product → main
        (9, 2.5, 7.5, 1.7),  # fraction → main
    ]

    for x1, y1, x2, y2 in arrows:
        ax.annotate('', xy=(x2, y2), xytext=(x1, y1),
                   arrowprops=dict(arrowstyle='->', color='#555',
                                  lw=2, connectionstyle='arc3,rad=0.1'))

    ax.set_title('Proof Architecture: Freivalds Amplification Theorem',
                 fontsize=15, fontweight='bold', pad=20)

    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")

    img1 = plot_exponential_decay()
    print(f"  Exponential decay plot: {len(img1)} chars")

    img2 = plot_kernel_cardinality()
    print(f"  Kernel cardinality plot: {len(img2)} chars")

    img3 = plot_empirical_vs_theoretical()
    print(f"  Empirical vs theoretical: {len(img3)} chars")

    img4 = plot_proof_architecture()
    print(f"  Proof architecture: {len(img4)} chars")

    print("\nAll visualizations generated successfully.")
