#!/usr/bin/env python3
"""
applications.py — Real-world applications of Freivalds' verification theorem.

Demonstrates:
1. Streaming matrix verification (data-stream model)
2. Randomized equality testing for large objects
3. Interactive proof system for matrix products
4. Connection to error-correcting codes
"""

import numpy as np
from algorithms import FiniteFieldMatrix, freivalds_single_check, freivalds_multi_check
import time


def app_streaming_verification():
    """
    Application 1: Streaming Verification

    Scenario: A cloud server computes C = A × B for large matrices.
    The client wants to verify correctness without storing A, B, or C,
    using only O(n) memory instead of O(n²).

    The Freivalds-based streaming verifier:
    1. Picks random r before seeing any data
    2. Streams A row-by-row to compute A·(B·r) incrementally
    3. Streams C row-by-row to compute C·r incrementally
    4. Compares the two n-vectors
    """
    print("=" * 60)
    print("APPLICATION 1: Streaming Matrix Verification")
    print("=" * 60)

    q = 101  # Moderate prime for realistic demo
    n = 100  # Matrix size

    np.random.seed(42)
    A = np.random.randint(0, q, (n, n))
    B = np.random.randint(0, q, (n, n))
    C_correct = A @ B % q

    # Introduce subtle error
    C_wrong = C_correct.copy()
    C_wrong[50, 50] = (C_wrong[50, 50] + 1) % q

    print(f"\nField: GF({q}), Matrix size: {n}×{n}")
    print(f"Full verification cost: O(n³) = O({n**3:,}) operations")
    print(f"Freivalds cost: O(n²) = O({n**2:,}) operations per trial")
    print(f"Savings factor: {n}×\n")

    # Simulate streaming verification
    r = np.random.randint(0, q, n)

    # Server-side: compute B·r (could be streamed)
    Br = B @ r % q

    # Streaming: compute A·(B·r) one row at a time
    ABr_streaming = np.zeros(n, dtype=int)
    for i in range(n):
        ABr_streaming[i] = np.dot(A[i], Br) % q

    # Streaming: compute C·r one row at a time
    Cr_correct = np.zeros(n, dtype=int)
    Cr_wrong = np.zeros(n, dtype=int)
    for i in range(n):
        Cr_correct[i] = np.dot(C_correct[i], r) % q
        Cr_wrong[i] = np.dot(C_wrong[i], r) % q

    correct_match = np.array_equal(ABr_streaming, Cr_correct)
    wrong_match = np.array_equal(ABr_streaming, Cr_wrong)

    print(f"Correct product: {'ACCEPT ✓' if correct_match else 'REJECT ✗'}")
    print(f"Wrong product:   {'ACCEPT (false positive!)' if wrong_match else 'REJECT ✓'}")
    print(f"Error probability bound: 1/{q} ≈ {1/q:.4f}")


def app_equality_testing():
    """
    Application 2: Randomized Equality Testing

    The Freivalds theorem generalizes to testing equality of any
    linear combination. Given two databases D₁ and D₂ represented
    as vectors, we can test D₁ = D₂ with probability 1 - 1/q
    using a single random linear fingerprint.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Randomized Fingerprint Equality Testing")
    print("=" * 60)

    q = 1009  # Large prime
    n = 10000  # Database size

    np.random.seed(42)

    # Two "databases" — identical except at one position
    D1 = np.random.randint(0, q, n)
    D2 = D1.copy()

    # Equal case
    r = np.random.randint(0, q, n)
    fp1 = np.dot(D1, r) % q
    fp2 = np.dot(D2, r) % q
    print(f"\nField: GF({q}), Database size: {n}")
    print(f"\nEqual databases:")
    print(f"  Fingerprint 1: {fp1}")
    print(f"  Fingerprint 2: {fp2}")
    print(f"  Match: {fp1 == fp2} ✓")

    # Differ by one entry
    D2[5000] = (D2[5000] + 1) % q
    fp2 = np.dot(D2, r) % q
    print(f"\nDatabases differing at one position:")
    print(f"  Fingerprint 1: {fp1}")
    print(f"  Fingerprint 2: {fp2}")
    print(f"  Match: {fp1 == fp2}")
    print(f"  Pr[false match] ≤ 1/{q} ≈ {1/q:.6f}")

    # Multi-trial
    n_trials = 100
    false_matches = 0
    for _ in range(n_trials):
        r = np.random.randint(0, q, n)
        if np.dot(D1, r) % q == np.dot(D2, r) % q:
            false_matches += 1
    print(f"\n  Empirical (100 trials): {false_matches} false matches")
    print(f"  Expected: ≤ {100/q:.2f}")


def app_interactive_proof():
    """
    Application 3: Interactive Proof for Matrix Products

    Models an interactive proof system where:
    - Prover (powerful): claims C = A × B and sends C
    - Verifier (weak): checks using Freivalds with t trials
    - Completeness: honest prover always accepted
    - Soundness: cheating prover caught with prob ≥ 1 - q^(-t)
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Interactive Proof System")
    print("=" * 60)

    q = 7
    n = 5

    np.random.seed(42)
    A_data = np.random.randint(0, q, (n, n))
    B_data = np.random.randint(0, q, (n, n))

    A = FiniteFieldMatrix(A_data, q)
    B = FiniteFieldMatrix(B_data, q)

    # Honest prover
    C_honest = A @ B

    # Cheating prover (slightly wrong)
    C_cheat_data = C_honest.data.copy()
    C_cheat_data[2, 3] = (C_cheat_data[2, 3] + 1) % q
    C_cheat = FiniteFieldMatrix(C_cheat_data, q)

    print(f"\nField: GF({q}), Matrix size: {n}×{n}")
    print(f"\nInteraction transcript:")

    for t in [1, 3, 5, 10, 20]:
        # Test honest prover
        honest_result, _ = freivalds_multi_check(A, B, C_honest, t)
        # Test cheating prover (run multiple experiments)
        n_experiments = 1000
        cheat_accepted = sum(
            freivalds_multi_check(A, B, C_cheat, t)[0]
            for _ in range(n_experiments)
        )
        print(f"\n  t={t:2d} trials:")
        print(f"    Honest prover: {'ACCEPT' if honest_result else 'REJECT'}")
        print(f"    Cheating prover caught: {n_experiments - cheat_accepted}/{n_experiments} "
              f"({(n_experiments - cheat_accepted)/n_experiments*100:.1f}%)")
        print(f"    Theoretical: ≥ {(1 - (1/q)**t)*100:.4f}%")


def app_error_correcting_connection():
    """
    Application 4: Connection to Error-Correcting Codes

    A nonzero row w defines a parity-check equation.
    The set {r | w·r = 0} is a linear code of codimension 1.
    Freivalds' theorem says: a false claim is "detected" by
    the code with probability at least (q-1)/q.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Connection to Linear Codes")
    print("=" * 60)

    q = 5
    n = 4  # Code length

    # Parity check vector
    w = np.array([1, 1, 1, 1])  # Simple parity check

    print(f"\nField: GF({q}), Length: {n}")
    print(f"Parity check: w = {w}")

    # The code: all vectors with w·r = 0
    codewords = []
    for r_tuple in range(q ** n):
        r = np.array([(r_tuple // q**i) % q for i in range(n)])
        if np.dot(w, r) % q == 0:
            codewords.append(r)

    print(f"\nCode C = {{r | w·r = 0 mod {q}}}:")
    print(f"  |C| = {len(codewords)} = {q}^{n-1} = {q**(n-1)}")
    print(f"  Rate = {len(codewords)}/{q**n} = {len(codewords)/q**n:.4f}")

    # For each coset (w·r = b), count solutions
    print(f"\nCoset structure:")
    for b in range(q):
        coset_size = sum(1 for r_tuple in range(q ** n)
                        for r in [np.array([(r_tuple // q**i) % q for i in range(n)])]
                        if np.dot(w, r) % q == b)
        print(f"  |{{r | w·r = {b}}}| = {coset_size} = q^(n-1) = {q**(n-1)}")

    print(f"\nFreivalds' theorem as a coding statement:")
    print(f"  A 'false certificate' (nonzero syndrome) is detected by")
    print(f"  a random codeword with probability ≥ {(q-1)/q:.4f} = (q-1)/q")


if __name__ == "__main__":
    app_streaming_verification()
    app_equality_testing()
    app_interactive_proof()
    app_error_correcting_connection()


#!/usr/bin/env python3
"""
demo.py — Demonstrating Freivalds' Matrix Verification Theorem

Concrete numerical examples showing:
1. The algorithm in action (correct and incorrect products)
2. The exact counting of kernel solutions
3. Probability estimation via Monte Carlo
"""

import numpy as np
from itertools import product as cartesian_product


def freivalds_check(A, B, K, r, q):
    """Check if K.r == (A @ B).r over GF(q)."""
    AB_r = (A @ (B @ r % q) % q) % q
    K_r = (K @ r % q) % q
    return np.array_equal(AB_r % q, K_r % q)


def count_kernel_solutions(M, q):
    """Count |{r : GF(q)^p | M.r = 0 mod q}| by brute force."""
    p = M.shape[1]
    count = 0
    for r_tuple in cartesian_product(range(q), repeat=p):
        r = np.array(r_tuple)
        if np.all((M @ r) % q == 0):
            count += 1
    return count


def count_accepting_vectors(A, B, K, q):
    """Count |{r : GF(q)^p | K.r = (A*B).r mod q}| by brute force."""
    M = (K - A @ B) % q
    return count_kernel_solutions(M, q)


def demo_basic():
    """Basic demonstration of Freivalds' algorithm."""
    print("=" * 60)
    print("DEMO 1: Freivalds' Algorithm in Action")
    print("=" * 60)

    q = 5  # Work over GF(5)
    m, n, p = 3, 3, 3

    np.random.seed(42)
    A = np.random.randint(0, q, (m, n))
    B = np.random.randint(0, q, (n, p))
    K_correct = (A @ B) % q
    K_wrong = K_correct.copy()
    K_wrong[0, 0] = (K_wrong[0, 0] + 1) % q  # Introduce error

    print(f"\nField: GF({q})")
    print(f"Matrix dimensions: {m}×{n} times {n}×{p}")
    print(f"\nA =\n{A}")
    print(f"\nB =\n{B}")
    print(f"\nA*B (mod {q}) =\n{K_correct}")
    print(f"\nK (wrong, differs at [0,0]) =\n{K_wrong}")

    # Run multiple trials
    n_trials = 20
    correct_accepts = 0
    wrong_accepts = 0

    print(f"\n--- Running {n_trials} random trials ---")
    for trial in range(n_trials):
        r = np.random.randint(0, q, p)
        accept_correct = freivalds_check(A, B, K_correct, r, q)
        accept_wrong = freivalds_check(A, B, K_wrong, r, q)
        if accept_correct:
            correct_accepts += 1
        if accept_wrong:
            wrong_accepts += 1

    print(f"Correct product accepted: {correct_accepts}/{n_trials} "
          f"(expected: {n_trials}/{n_trials})")
    print(f"Wrong product accepted:   {wrong_accepts}/{n_trials} "
          f"(expected ≤ {n_trials}/{q} = {n_trials/q:.1f})")
    print(f"Theoretical bound: Pr[false accept] ≤ 1/{q} = {1/q:.4f}")


def demo_exact_counting():
    """Demonstrate the exact kernel counting theorem."""
    print("\n" + "=" * 60)
    print("DEMO 2: Exact Kernel Counting")
    print("=" * 60)

    for q in [2, 3, 5]:
        print(f"\n--- Field: GF({q}) ---")
        for p in [1, 2, 3]:
            # Create a nonzero row vector (linear functional)
            w = np.zeros(p, dtype=int)
            w[0] = 1  # simplest nonzero vector

            # Count solutions to w·r = 0 mod q
            count = 0
            for r_tuple in cartesian_product(range(q), repeat=p):
                r = np.array(r_tuple)
                if sum(w[i] * r[i] for i in range(p)) % q == 0:
                    count += 1

            expected = q ** (p - 1)
            total = q ** p
            print(f"  p={p}: |{{r | w·r = 0}}| = {count}, "
                  f"q^(p-1) = {expected}, "
                  f"ratio = {count}/{total} = {count/total:.4f}, "
                  f"1/q = {1/q:.4f}")
            assert count == expected, f"Mismatch! {count} ≠ {expected}"

        print(f"  ✓ All counts match q^(p-1) for q={q}")


def demo_matrix_kernel():
    """Demonstrate kernel counting for full matrices."""
    print("\n" + "=" * 60)
    print("DEMO 3: Matrix Kernel Counting (Freivalds Bound)")
    print("=" * 60)

    q = 3
    p = 3

    # Various nonzero matrices
    test_cases = [
        ("Rank 1 matrix", np.array([[1, 0, 0], [0, 0, 0]])),
        ("Rank 2 matrix", np.array([[1, 0, 0], [0, 1, 0]])),
        ("Full row rank", np.array([[1, 0, 0], [0, 1, 0], [0, 0, 1]])),
        ("Single nonzero row", np.array([[1, 2, 1]])),
    ]

    bound = q ** (p - 1)
    total = q ** p

    print(f"\nField: GF({q}), p = {p}")
    print(f"Bound: q^(p-1) = {bound}")
    print(f"Total vectors: q^p = {total}")

    for name, M in test_cases:
        m = M.shape[0]
        kernel_size = count_kernel_solutions(M, q)
        print(f"\n  {name} ({m}×{p}):")
        print(f"    M = {M.tolist()}")
        print(f"    |ker| = {kernel_size} ≤ {bound}? {kernel_size <= bound} ✓"
              if kernel_size <= bound else
              f"    |ker| = {kernel_size} > {bound}? FAIL!")
        print(f"    Pr[M·r = 0] = {kernel_size}/{total} = {kernel_size/total:.4f}")


def demo_monte_carlo_convergence():
    """Monte Carlo estimation of false-accept probability."""
    print("\n" + "=" * 60)
    print("DEMO 4: Monte Carlo Probability Estimation")
    print("=" * 60)

    for q in [2, 3, 5, 7]:
        m, n, p = 4, 4, 4
        np.random.seed(0)
        A = np.random.randint(0, q, (m, n))
        B = np.random.randint(0, q, (n, p))
        K = (A @ B) % q
        # Perturb K
        K[0, 0] = (K[0, 0] + 1) % q

        n_trials = 10000
        accepts = 0
        for _ in range(n_trials):
            r = np.random.randint(0, q, p)
            if freivalds_check(A, B, K, r, q):
                accepts += 1

        empirical = accepts / n_trials
        theoretical = 1.0 / q
        print(f"  q={q}: empirical Pr = {empirical:.4f}, "
              f"bound 1/q = {theoretical:.4f}, "
              f"{'✓ within bound' if empirical <= theoretical * 1.1 else '≈ near bound'}")


def demo_repeated_trials():
    """Demonstrate exponential soundness amplification."""
    print("\n" + "=" * 60)
    print("DEMO 5: Repeated-Trial Amplification")
    print("=" * 60)

    q = 2
    m, n, p = 3, 3, 3
    np.random.seed(42)
    A = np.random.randint(0, q, (m, n))
    B = np.random.randint(0, q, (n, p))
    K = (A @ B) % q
    K[0, 0] = (K[0, 0] + 1) % q  # Wrong product

    n_experiments = 50000

    print(f"\nField: GF({q}), repeating t independent trials")
    print(f"Theoretical: Pr[all t accept | wrong] ≤ (1/{q})^t = (1/2)^t\n")

    for t in [1, 2, 3, 5, 8, 10, 15, 20]:
        all_accept = 0
        for _ in range(n_experiments):
            accepted_all = True
            for _ in range(t):
                r = np.random.randint(0, q, p)
                if not freivalds_check(A, B, K, r, q):
                    accepted_all = False
                    break
            if accepted_all:
                all_accept += 1

        empirical = all_accept / n_experiments
        theoretical = (1.0 / q) ** t
        print(f"  t={t:2d}: empirical = {empirical:.6f}, "
              f"bound = {theoretical:.6f} = 2^(-{t})")


if __name__ == "__main__":
    demo_basic()
    demo_exact_counting()
    demo_matrix_kernel()
    demo_monte_carlo_convergence()
    demo_repeated_trials()


#!/usr/bin/env python3
"""
visualizations.py — Generate figures for the Freivalds verification theorem.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import product as cartesian_product
import base64
import io


def fig_to_base64(fig):
    """Convert matplotlib figure to base64 PNG data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def viz_hyperplane_gf5():
    """Visualize the hyperplane structure in GF(5)^2."""
    q = 5
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # All points in GF(5)^2
    all_points = list(cartesian_product(range(q), repeat=2))

    for idx, (w, title) in enumerate([
        (np.array([1, 0]), "w = (1, 0)"),
        (np.array([0, 1]), "w = (0, 1)"),
        (np.array([1, 1]), "w = (1, 1)"),
    ]):
        ax = axes[idx]

        # Classify points by w·r mod q
        colors = []
        for r in all_points:
            val = (w[0]*r[0] + w[1]*r[1]) % q
            colors.append(val)

        # Plot
        xs = [r[0] for r in all_points]
        ys = [r[1] for r in all_points]

        scatter = ax.scatter(xs, ys, c=colors, cmap='Set1', s=200, edgecolors='black', linewidth=1.5, vmin=0, vmax=q-1)

        # Highlight kernel (w·r = 0)
        kernel = [(r[0], r[1]) for r in all_points if (w[0]*r[0] + w[1]*r[1]) % q == 0]
        kx = [p[0] for p in kernel]
        ky = [p[1] for p in kernel]
        ax.scatter(kx, ky, facecolors='none', edgecolors='red', s=400, linewidth=3, zorder=5, label='Kernel (w·r=0)')

        ax.set_title(f'{title}\nKernel size = {len(kernel)} = {q}^(2-1)', fontsize=12)
        ax.set_xlabel('r₁', fontsize=11)
        ax.set_ylabel('r₂', fontsize=11)
        ax.set_xticks(range(q))
        ax.set_yticks(range(q))
        ax.grid(True, alpha=0.3)
        ax.legend(fontsize=9)
        ax.set_aspect('equal')

    fig.suptitle(f'Hyperplane Structure in GF({q})²: Each color = one coset of ker(w)',
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    return fig


def viz_soundness_amplification():
    """Plot soundness amplification curves for different field sizes."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    t_values = np.arange(1, 25)

    for q in [2, 3, 5, 7, 11]:
        bounds = [(1.0/q)**t for t in t_values]
        ax.semilogy(t_values, bounds, 'o-', label=f'q = {q}', markersize=5)

    ax.set_xlabel('Number of trials (t)', fontsize=13)
    ax.set_ylabel('False-accept probability bound', fontsize=13)
    ax.set_title('Soundness Amplification: Pr[false accept] ≤ (1/q)ᵗ', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3, which='both')
    ax.set_ylim(1e-16, 1)
    ax.axhline(y=2**-128, color='gray', linestyle='--', alpha=0.5, label='128-bit security')
    ax.text(20, 2**-128 * 3, '128-bit security', fontsize=9, color='gray')
    plt.tight_layout()
    return fig


def viz_kernel_size_vs_rank():
    """Show kernel size as a function of matrix rank."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    for q in [2, 3, 5]:
        p = 6  # Column dimension
        ranks = list(range(p + 1))
        kernel_sizes = [q ** (p - r) for r in ranks]
        bound = q ** (p - 1)

        ax.semilogy(ranks, kernel_sizes, 'o-', label=f'q={q}, p={p}', markersize=8)
        ax.axhline(y=bound, linestyle='--', alpha=0.4)

    ax.set_xlabel('Matrix rank', fontsize=13)
    ax.set_ylabel('Kernel size |ker(M)|', fontsize=13)
    ax.set_title('Kernel Size = q^(p − rank): Freivalds Bound is rank ≥ 1', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3, which='both')
    plt.tight_layout()
    return fig


def viz_monte_carlo_convergence():
    """Show Monte Carlo convergence to theoretical bound."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    q = 5
    m, n, p = 3, 3, 3

    np.random.seed(42)
    A = np.random.randint(0, q, (m, n))
    B = np.random.randint(0, q, (n, p))
    K = (A @ B) % q
    K[0, 0] = (K[0, 0] + 1) % q
    M = (K - A @ B) % q

    # Monte Carlo: cumulative false-accept rate
    n_total = 5000
    accepts = 0
    cumulative_rates = []
    trial_nums = []

    for trial in range(1, n_total + 1):
        r = np.random.randint(0, q, p)
        if np.all((M @ r) % q == 0):
            accepts += 1
        if trial % 10 == 0:
            cumulative_rates.append(accepts / trial)
            trial_nums.append(trial)

    ax.plot(trial_nums, cumulative_rates, '-', color='steelblue', linewidth=1.5,
            label='Empirical false-accept rate')
    ax.axhline(y=1/q, color='red', linestyle='--', linewidth=2,
               label=f'Theoretical bound 1/q = 1/{q} = {1/q:.3f}')
    ax.set_xlabel('Number of trials', fontsize=13)
    ax.set_ylabel('Cumulative false-accept rate', fontsize=13)
    ax.set_title(f'Monte Carlo Convergence (GF({q}), {m}×{p} matrix)', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    return fig


def generate_all():
    """Generate all visualizations and return as base64 dict."""
    results = {}

    fig = viz_hyperplane_gf5()
    results['hyperplane_structure'] = fig_to_base64(fig)

    fig = viz_soundness_amplification()
    results['soundness_amplification'] = fig_to_base64(fig)

    fig = viz_kernel_size_vs_rank()
    results['kernel_size_vs_rank'] = fig_to_base64(fig)

    fig = viz_monte_carlo_convergence()
    results['monte_carlo_convergence'] = fig_to_base64(fig)

    return results


if __name__ == "__main__":
    print("Generating visualizations...")

    fig = viz_hyperplane_gf5()
    fig.savefig('hyperplane_structure.png', dpi=150, bbox_inches='tight')
    print("  Saved hyperplane_structure.png")

    fig = viz_soundness_amplification()
    fig.savefig('soundness_amplification.png', dpi=150, bbox_inches='tight')
    print("  Saved soundness_amplification.png")

    fig = viz_kernel_size_vs_rank()
    fig.savefig('kernel_size_vs_rank.png', dpi=150, bbox_inches='tight')
    print("  Saved kernel_size_vs_rank.png")

    fig = viz_monte_carlo_convergence()
    fig.savefig('monte_carlo_convergence.png', dpi=150, bbox_inches='tight')
    print("  Saved monte_carlo_convergence.png")

    print("Done!")
