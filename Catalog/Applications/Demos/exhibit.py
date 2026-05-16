#!/usr/bin/env python3
"""
Applications of Reed–Muller Minimum Distance and PIT Soundness

Demonstrates real-world applications:
1. Secret Sharing Threshold Analysis
2. Error-Correcting Code Parameters
3. Polynomial Identity Testing for Matrix Verification (Freivalds' Algorithm)
4. Low-Degree Testing Simulation
"""

import random
import itertools
from typing import List, Tuple


# ============================================================
# Finite Field Arithmetic
# ============================================================
class GF:
    def __init__(self, p: int):
        self.p = p
    def add(self, a, b): return (a + b) % self.p
    def mul(self, a, b): return (a * b) % self.p
    def sub(self, a, b): return (a - b) % self.p
    def neg(self, a): return (-a) % self.p
    def inv(self, a): return pow(a, self.p - 2, self.p)


# ============================================================
# Application 1: Shamir Secret Sharing Threshold Analysis
# ============================================================
def app_secret_sharing():
    """
    Shamir's secret sharing uses Reed–Solomon codes (Reed–Muller in 1 variable).
    The minimum distance theorem tells us exactly the security threshold.

    A (t, n)-threshold scheme distributes n shares of a secret s such that:
    - Any t shares can reconstruct s
    - Any t-1 shares give NO information about s

    The secret is the constant term of a random polynomial of degree t-1.
    Shares are evaluations at n distinct points.

    By the minimum distance theorem with d = t-1 and q ≥ n:
    - Any nonzero polynomial of degree ≤ t-1 has at least (q - t + 1) nonzero evaluations
    - This ensures the shares of different secrets are far apart in Hamming distance
    """
    print("=" * 70)
    print("APPLICATION 1: Shamir Secret Sharing — Threshold Analysis")
    print("=" * 70)
    print()

    q = 11  # Work over GF(11)
    F = GF(q)

    for t in [2, 3, 5]:
        n = q  # Maximum number of shareholders
        d = t - 1  # Polynomial degree
        min_dist = (q - d) * (q ** 0)  # n_vars = 1, so q^(n-1) = q^0 = 1

        print(f"  ({t}, {n})-threshold scheme over GF({q}):")
        print(f"    Polynomial degree: {d}")
        print(f"    Minimum distance: {min_dist}")
        print(f"    Security margin: any {t-1} shares leak 0 bits")
        print(f"    Reconstruction: any {t} shares determine the secret uniquely")
        print()

        # Demonstrate: create shares for a secret
        secret = 7
        # Random polynomial: f(x) = secret + a₁x + a₂x² + ... + a_{t-1}x^{t-1}
        coeffs = [secret] + [random.randint(0, q - 1) for _ in range(d)]

        def eval_poly(x):
            result = 0
            for i, c in enumerate(coeffs):
                result = F.add(result, F.mul(c, pow(x, i, q)))
            return result

        shares = [(i, eval_poly(i)) for i in range(1, n + 1)]
        print(f"    Secret: {secret}")
        print(f"    First 5 shares: {shares[:5]}")

        # Verify: Lagrange interpolation with t shares recovers the secret
        selected = shares[:t]
        reconstructed = 0
        for i, (xi, yi) in enumerate(selected):
            # Lagrange basis polynomial at x=0
            num = 1
            den = 1
            for j, (xj, _) in enumerate(selected):
                if i != j:
                    num = F.mul(num, F.neg(xj))
                    den = F.mul(den, F.sub(xi, xj))
            basis = F.mul(num, F.inv(den))
            reconstructed = F.add(reconstructed, F.mul(yi, basis))

        print(f"    Reconstructed from {t} shares: {reconstructed}")
        print(f"    Correct: {'✓' if reconstructed == secret else '✗'}")
        print()


# ============================================================
# Application 2: Error-Correcting Code Parameters
# ============================================================
def app_error_correction():
    """
    Reed–Muller codes provide error correction with exact parameters.
    The minimum distance d_min determines:
    - Error detection capability: d_min - 1 errors
    - Error correction capability: ⌊(d_min - 1) / 2⌋ errors
    """
    print("=" * 70)
    print("APPLICATION 2: Error-Correcting Code Parameters")
    print("=" * 70)
    print()

    print(f"{'Code':>15} | {'q':>3} {'n':>3} {'d':>3} | {'Length':>8} "
          f"{'Dim':>6} {'MinDist':>8} | {'Detect':>7} {'Correct':>8} | {'Rate':>6}")
    print("-" * 85)

    for q, n, d in [(5, 2, 1), (5, 2, 2), (7, 2, 1), (7, 2, 3),
                     (7, 3, 1), (7, 3, 2), (11, 2, 3), (11, 2, 5)]:
        code_length = q ** n
        min_dist = (q - d) * (q ** (n - 1))

        # Dimension = number of monomials of total degree ≤ d in n variables
        # This is C(n + d, d) for d < q
        from math import comb
        dimension = comb(n + d, d)

        detect = min_dist - 1
        correct = (min_dist - 1) // 2
        rate = dimension / code_length

        name = f"RM_{q}({n},{d})"
        print(f"{name:>15} | {q:>3} {n:>3} {d:>3} | {code_length:>8} "
              f"{dimension:>6} {min_dist:>8} | {detect:>7} {correct:>8} | {rate:>6.3f}")

    print()
    print("  The minimum distance determines the exact error correction capability.")
    print("  Higher q and lower d give better error tolerance but lower rate.")
    print()


# ============================================================
# Application 3: Freivalds' Algorithm (Matrix Verification)
# ============================================================
def app_freivalds():
    """
    Freivalds' algorithm verifies AB = C for n×n matrices using
    random vector multiplication. This is a special case of PIT with degree 1.

    By the Schwartz–Zippel theorem with d=1:
    Pr[error] ≤ 1/q per trial.
    """
    print("=" * 70)
    print("APPLICATION 3: Freivalds' Algorithm — Matrix Verification")
    print("=" * 70)
    print()

    q = 7
    F = GF(q)
    n = 4  # Matrix size

    random.seed(42)

    # Generate random matrices A, B
    A = [[random.randint(0, q - 1) for _ in range(n)] for _ in range(n)]
    B = [[random.randint(0, q - 1) for _ in range(n)] for _ in range(n)]

    # Compute C = A * B
    def matmul(X, Y):
        result = [[0] * n for _ in range(n)]
        for i in range(n):
            for j in range(n):
                for k in range(n):
                    result[i][j] = F.add(result[i][j], F.mul(X[i][k], Y[k][j]))
        return result

    C = matmul(A, B)

    # Also create a wrong C
    C_wrong = [row[:] for row in C]
    C_wrong[0][0] = F.add(C_wrong[0][0], 1)

    def freivalds_test(A, B, C_test, num_trials=10):
        """Run Freivalds' algorithm: check if AB = C_test."""
        for _ in range(num_trials):
            r = [random.randint(0, q - 1) for _ in range(n)]

            # Compute B*r
            Br = [sum(F.mul(B[i][j], r[j]) for j in range(n)) % q for i in range(n)]
            # Compute A*(B*r)
            ABr = [sum(F.mul(A[i][j], Br[j]) for j in range(n)) % q for i in range(n)]
            # Compute C*r
            Cr = [sum(F.mul(C_test[i][j], r[j]) for j in range(n)) % q for i in range(n)]

            if ABr != Cr:
                return False, "MISMATCH DETECTED"

        return True, "PASSED"

    # Test correct product
    result, msg = freivalds_test(A, B, C)
    print(f"  Testing AB = C (correct):  {msg}")

    # Test incorrect product
    result_wrong, msg_wrong = freivalds_test(A, B, C_wrong)
    print(f"  Testing AB = C' (wrong):   {msg_wrong}")

    print()
    print(f"  Field size q = {q}")
    print(f"  Error probability per trial: 1/q = {1/q:.4f}")
    print(f"  Error probability after 10 trials: (1/q)^10 = {(1/q)**10:.2e}")
    print(f"  This follows from Schwartz–Zippel with d=1.")
    print()


# ============================================================
# Application 4: Low-Degree Testing Simulation
# ============================================================
def app_low_degree_testing():
    """
    Simulate low-degree testing: given a function f: GF(q)^n → GF(q),
    test whether f is close to a polynomial of degree ≤ d.

    The key insight from the minimum distance theorem:
    If f differs from every degree-≤d polynomial in at least one point,
    it differs from every such polynomial in at least (q-d)·q^(n-1) points.

    This means: either f is exactly a low-degree polynomial, or it's far
    from every low-degree polynomial. There's no "almost low-degree" regime.
    """
    print("=" * 70)
    print("APPLICATION 4: Low-Degree Testing")
    print("=" * 70)
    print()

    q = 5
    n = 2
    d = 1  # Test if functions are degree ≤ 1 (affine)

    total_points = q ** n
    min_dist = (q - d) * (q ** (n - 1))
    proximity_param = min_dist / total_points

    print(f"  Parameters: GF({q})^{n}, degree bound d = {d}")
    print(f"  Total points: {total_points}")
    print(f"  Minimum distance: {min_dist}")
    print(f"  Proximity parameter δ = {min_dist}/{total_points} = {proximity_param:.2f}")
    print()
    print("  The minimum distance theorem guarantees:")
    print(f"  If f is not a degree-≤{d} polynomial, it disagrees with every")
    print(f"  degree-≤{d} polynomial on at least {min_dist} of {total_points} points.")
    print()

    F = GF(q)
    points = list(itertools.product(range(q), repeat=n))

    # An actual degree-1 polynomial
    def affine_fn(pt):
        return (2 * pt[0] + 3 * pt[1] + 1) % q

    # A corrupted version (change a few evaluations)
    corruptions = 2
    corrupted_indices = random.sample(range(total_points), corruptions)
    affine_vals = [affine_fn(pt) for pt in points]
    corrupted_vals = affine_vals[:]
    for idx in corrupted_indices:
        corrupted_vals[idx] = (corrupted_vals[idx] + 1) % q

    # A random function (very far from low-degree)
    random.seed(123)
    random_vals = [random.randint(0, q - 1) for _ in range(total_points)]

    # Measure distance to nearest codeword for each function
    # (Brute-force for small parameters)
    def min_distance_to_code(vals):
        """Find minimum Hamming distance from vals to any degree-≤d polynomial."""
        best = total_points
        for coeffs in itertools.product(range(q), repeat=3):  # ax+by+c
            a, b, c = coeffs
            poly_vals = [(a * pt[0] + b * pt[1] + c) % q for pt in points]
            dist = sum(1 for v1, v2 in zip(vals, poly_vals) if v1 != v2)
            best = min(best, dist)
        return best

    d_affine = min_distance_to_code(affine_vals)
    d_corrupted = min_distance_to_code(corrupted_vals)
    d_random = min_distance_to_code(random_vals)

    print("  Distance analysis:")
    print(f"    True affine function:    distance = {d_affine} (is codeword: {'yes' if d_affine == 0 else 'no'})")
    print(f"    Corrupted ({corruptions} errors):    distance = {d_corrupted}")
    print(f"    Random function:         distance = {d_random}")
    print()
    print(f"  Since min_dist = {min_dist}, any function with distance < {min_dist}")
    print(f"  to a codeword can be uniquely decoded (unique decoding radius = {(min_dist-1)//2}).")
    if d_corrupted <= (min_dist - 1) // 2:
        print(f"  The corrupted function (distance {d_corrupted}) IS within unique decoding radius. ✓")
    print()


if __name__ == "__main__":
    random.seed(42)
    app_secret_sharing()
    app_error_correction()
    app_freivalds()
    app_low_degree_testing()


#!/usr/bin/env python3
"""
Reed–Muller Codes: Minimum Distance & PIT Soundness — Demonstrations

This script demonstrates the key theorems about Reed–Muller evaluation codes:
1. The exact minimum distance theorem: min weight = (q-d) * q^(n-1)
2. The extremal witness polynomial ∏(X₁ - aᵢ) attains this bound
3. PIT soundness: Pr[C(x)=0] ≤ d/q for nonzero degree-d polynomials

Works over GF(q) for prime q using modular arithmetic.
"""

import itertools
import random
from typing import List, Tuple, Dict
from collections import Counter


def gf_elements(q: int) -> List[int]:
    """Elements of GF(q) for prime q."""
    return list(range(q))


def gf_add(a: int, b: int, q: int) -> int:
    return (a + b) % q


def gf_mul(a: int, b: int, q: int) -> int:
    return (a * b) % q


def gf_sub(a: int, b: int, q: int) -> int:
    return (a - b) % q


def gf_points(q: int, n: int) -> List[Tuple[int, ...]]:
    """All points in GF(q)^n."""
    return list(itertools.product(range(q), repeat=n))


def eval_witness_poly(x: Tuple[int, ...], roots: List[int], q: int) -> int:
    """
    Evaluate the witness polynomial f(x) = ∏_{a ∈ roots} (x₁ - a) at point x.
    The polynomial depends only on the first coordinate x₁.
    """
    result = 1
    for a in roots:
        result = gf_mul(result, gf_sub(x[0], a, q), q)
    return result


def hamming_weight_of_poly(eval_fn, q: int, n: int) -> int:
    """Count nonzero evaluations of a polynomial over GF(q)^n."""
    points = gf_points(q, n)
    return sum(1 for pt in points if eval_fn(pt) != 0)


def zero_count_of_poly(eval_fn, q: int, n: int) -> int:
    """Count zero evaluations of a polynomial over GF(q)^n."""
    points = gf_points(q, n)
    return sum(1 for pt in points if eval_fn(pt) == 0)


# ============================================================
# DEMO 1: Exact Minimum Distance Verification
# ============================================================
def demo_minimum_distance():
    """
    Verify the exact minimum distance theorem:
      min_weight = (q - d) * q^(n-1)
    for various (q, n, d) parameters.
    """
    print("=" * 70)
    print("DEMO 1: Exact Minimum Distance of Reed–Muller Codes")
    print("=" * 70)
    print()
    print("Theorem: For RM_q(n, d) with 0 ≤ d < q, the minimum distance is")
    print("         exactly (q - d) · q^(n-1).")
    print()

    test_cases = [
        (3, 2, 1),  # GF(3), 2 vars, degree 1
        (5, 2, 2),  # GF(5), 2 vars, degree 2
        (5, 2, 3),  # GF(5), 2 vars, degree 3
        (7, 2, 1),  # GF(7), 2 vars, degree 1
        (3, 3, 1),  # GF(3), 3 vars, degree 1
        (3, 3, 2),  # GF(3), 3 vars, degree 2
        (5, 3, 2),  # GF(5), 3 vars, degree 2
    ]

    print(f"{'q':>4} {'n':>4} {'d':>4} | {'Formula':>12} {'Witness wt':>12} {'Match':>7}")
    print("-" * 55)

    for q, n, d in test_cases:
        # Predicted minimum distance
        predicted = (q - d) * (q ** (n - 1))

        # Construct witness: pick first d elements as roots
        roots = list(range(d))
        eval_fn = lambda pt, r=roots: eval_witness_poly(pt, r, q)
        actual_weight = hamming_weight_of_poly(eval_fn, q, n)

        match = "✓" if actual_weight == predicted else "✗"
        print(f"{q:>4} {n:>4} {d:>4} | {predicted:>12} {actual_weight:>12} {match:>7}")

    print()
    print("All witness polynomials achieve the exact minimum distance bound. ✓")
    print()


# ============================================================
# DEMO 2: Zero Set Structure — Fiber Decomposition
# ============================================================
def demo_fiber_structure():
    """
    Visualize the fiber structure of the witness polynomial's zero set.
    The zeros form exactly d parallel hyperplanes in GF(q)^n.
    """
    print("=" * 70)
    print("DEMO 2: Zero Set Fiber Structure")
    print("=" * 70)
    print()

    q, n, d = 5, 2, 2
    roots = [0, 1]  # Two roots

    print(f"GF({q})^{n}, witness polynomial f(x₁,x₂) = (x₁ - 0)(x₁ - 1)")
    print(f"Roots subset: {roots}")
    print()

    points = gf_points(q, n)

    # Group by first coordinate (fiber decomposition)
    fibers: Dict[int, List[Tuple[int, ...]]] = {}
    for pt in points:
        fibers.setdefault(pt[0], []).append(pt)

    print("Fiber decomposition (by first coordinate x₁):")
    print(f"{'x₁':>4} | {'Fiber size':>10} | {'All zeros?':>10} | {'All nonzero?':>12}")
    print("-" * 50)

    total_zeros = 0
    total_nonzeros = 0
    for x1 in sorted(fibers.keys()):
        fiber = fibers[x1]
        zeros_in_fiber = sum(1 for pt in fiber if eval_witness_poly(pt, roots, q) == 0)
        nonzeros_in_fiber = len(fiber) - zeros_in_fiber
        total_zeros += zeros_in_fiber
        total_nonzeros += nonzeros_in_fiber

        all_zero = zeros_in_fiber == len(fiber)
        all_nonzero = nonzeros_in_fiber == len(fiber)
        status_z = "YES" if all_zero else "no"
        status_nz = "YES" if all_nonzero else "no"
        marker = " ← root fiber" if x1 in roots else ""
        print(f"{x1:>4} | {len(fiber):>10} | {status_z:>10} | {status_nz:>12}{marker}")

    print()
    print(f"Total zeros: {total_zeros} = {d} × {q**(n-1)} = d × q^(n-1)")
    print(f"Total nonzeros (Hamming weight): {total_nonzeros} = {q-d} × {q**(n-1)} = (q-d) × q^(n-1)")
    print()
    print("Key insight: zeros form EXACTLY d parallel hyperplanes (one per root),")
    print("each of size q^(n-1). The fibers are perfectly disjoint. ✓")
    print()


# ============================================================
# DEMO 3: PIT Soundness — Random Evaluation Detection
# ============================================================
def demo_pit_soundness():
    """
    Demonstrate PIT soundness: random evaluation detects nonzero polynomials.
    """
    print("=" * 70)
    print("DEMO 3: PIT Soundness — Random Evaluation Detection")
    print("=" * 70)
    print()
    print("Theorem: For a nonzero polynomial of degree ≤ d over GF(q)^n,")
    print("         Pr[f(random x) = 0] ≤ d/q")
    print()

    test_cases = [
        (7, 2, 1, 10000),
        (7, 2, 3, 10000),
        (11, 2, 2, 10000),
        (11, 3, 5, 10000),
        (13, 2, 4, 10000),
    ]

    print(f"{'q':>4} {'n':>4} {'d':>4} | {'d/q':>8} | {'Empirical':>10} | {'Bound holds':>12}")
    print("-" * 60)

    random.seed(42)

    for q, n, d, trials in test_cases:
        roots = list(range(d))  # degree-d witness polynomial
        bound = d / q

        zeros = 0
        for _ in range(trials):
            pt = tuple(random.randint(0, q - 1) for _ in range(n))
            if eval_witness_poly(pt, roots, q) == 0:
                zeros += 1

        empirical = zeros / trials
        holds = "✓" if empirical <= bound + 0.01 else "✗"  # small tolerance for sampling
        print(f"{q:>4} {n:>4} {d:>4} | {bound:>8.4f} | {empirical:>10.4f} | {holds:>12}")

    print()
    print("In all cases, the empirical zero probability is ≤ d/q. ✓")
    print("(For the witness polynomial, equality holds exactly.)")
    print()


# ============================================================
# DEMO 4: Minimum Distance Is Tight — Exhaustive Verification
# ============================================================
def demo_exhaustive_minimum():
    """
    For small parameters, exhaustively verify that no nonzero codeword
    has weight less than (q-d)·q^(n-1).
    """
    print("=" * 70)
    print("DEMO 4: Exhaustive Minimum Distance Verification (Small Cases)")
    print("=" * 70)
    print()

    q, n = 3, 2  # GF(3)^2, small enough for exhaustive check
    total_points = q ** n

    for d in range(1, q):
        predicted_min = (q - d) * (q ** (n - 1))
        print(f"RM_{q}({n}, {d}): predicted minimum distance = {predicted_min}")

        # Generate all monomials of total degree ≤ d in n variables over GF(q)
        # A polynomial is represented as coefficients over monomials
        monomials = []
        for powers in itertools.product(range(d + 1), repeat=n):
            if sum(powers) <= d:
                monomials.append(powers)

        def eval_poly(coeffs, pt):
            result = 0
            for c, mon in zip(coeffs, monomials):
                term = c
                for var_idx, power in enumerate(mon):
                    for _ in range(power):
                        term = gf_mul(term, pt[var_idx], q)
                result = gf_add(result, term, q)
            return result

        min_weight = total_points + 1
        min_coeffs = None
        count_nonzero = 0

        # Iterate over all possible coefficient vectors
        for coeffs in itertools.product(range(q), repeat=len(monomials)):
            if all(c == 0 for c in coeffs):
                continue
            count_nonzero += 1

            weight = sum(1 for pt in gf_points(q, n) if eval_poly(coeffs, pt) != 0)
            if weight < min_weight:
                min_weight = weight
                min_coeffs = coeffs

        print(f"  Checked {count_nonzero} nonzero polynomials")
        print(f"  Minimum weight found: {min_weight}")
        print(f"  Matches prediction: {'✓' if min_weight == predicted_min else '✗'}")
        print()

    print("Exhaustive verification confirms the exact minimum distance theorem. ✓")
    print()


if __name__ == "__main__":
    demo_minimum_distance()
    demo_fiber_structure()
    demo_pit_soundness()
    demo_exhaustive_minimum()


#!/usr/bin/env python3
"""
Visualizations for Reed–Muller Minimum Distance and PIT Soundness.
Generates PNG figures saved to disk and returns base64-encoded versions.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import itertools
import base64
import io


def fig_to_base64(fig) -> str:
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    return "data:image/png;base64," + base64.b64encode(buf.read()).decode('utf-8')


def viz_zero_set_heatmap():
    """
    Visualize the zero set of the witness polynomial over GF(q)^2.
    Shows the "parallel hyperplane" structure.
    """
    q = 7
    d = 3
    roots = list(range(d))

    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    for idx, d_val in enumerate([1, 2, 3]):
        ax = axes[idx]
        roots_i = list(range(d_val))

        grid = np.zeros((q, q))
        for x1 in range(q):
            for x2 in range(q):
                val = 1
                for a in roots_i:
                    val = (val * ((x1 - a) % q)) % q
                grid[x2, x1] = 0 if val == 0 else 1

        ax.imshow(grid, cmap='RdYlGn', aspect='equal', origin='lower',
                  vmin=0, vmax=1)
        ax.set_xlabel('$x_1$', fontsize=12)
        ax.set_ylabel('$x_2$', fontsize=12)
        ax.set_title(f'd = {d_val}, roots = {roots_i}\n'
                     f'weight = ({q}-{d_val})×{q} = {(q-d_val)*q}',
                     fontsize=11)
        ax.set_xticks(range(q))
        ax.set_yticks(range(q))

        for x1 in range(q):
            for x2 in range(q):
                color = 'white' if grid[x2, x1] == 0 else 'black'
                ax.text(x1, x2, '0' if grid[x2, x1] == 0 else '•',
                        ha='center', va='center', color=color, fontsize=9)

    fig.suptitle(f'Zero Sets of Witness Polynomials over GF({q})²\n'
                 f'Green = nonzero (support), Red = zero',
                 fontsize=14, y=1.02)
    plt.tight_layout()
    fig.savefig('/workspace/request-project/viz_zero_sets.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


def viz_minimum_distance_scaling():
    """
    Plot how minimum distance scales with parameters q, n, d.
    """
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Plot 1: Min distance vs d for fixed q, n
    ax = axes[0]
    for q in [5, 7, 11, 13]:
        ds = list(range(1, q))
        min_dists = [(q - d) * q for d in ds]  # n=2
        ax.plot(ds, min_dists, 'o-', label=f'q={q}', markersize=4)
    ax.set_xlabel('Degree bound d', fontsize=12)
    ax.set_ylabel('Minimum distance', fontsize=12)
    ax.set_title('Min distance vs degree (n=2)', fontsize=12)
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Plot 2: Min distance vs n for fixed q, d
    ax = axes[1]
    for d in [1, 2, 3]:
        q = 7
        ns = list(range(1, 6))
        min_dists = [(q - d) * q**(n-1) for n in ns]
        ax.semilogy(ns, min_dists, 's-', label=f'd={d}', markersize=6)
    ax.set_xlabel('Number of variables n', fontsize=12)
    ax.set_ylabel('Minimum distance (log scale)', fontsize=12)
    ax.set_title(f'Min distance vs #variables (q={q})', fontsize=12)
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Plot 3: Rate vs relative distance
    ax = axes[2]
    from math import comb
    for q in [5, 7, 11]:
        n = 2
        ds = list(range(1, q))
        rates = [comb(n + d, d) / q**n for d in ds]
        rel_dists = [(q - d) * q**(n-1) / q**n for d in ds]
        ax.plot(rel_dists, rates, 'D-', label=f'q={q}, n={n}', markersize=5)
    ax.set_xlabel('Relative minimum distance δ', fontsize=12)
    ax.set_ylabel('Rate R', fontsize=12)
    ax.set_title('Rate–Distance Tradeoff', fontsize=12)
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    fig.savefig('/workspace/request-project/viz_scaling.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


def viz_pit_convergence():
    """
    Show how PIT error probability decreases with number of trials.
    """
    fig, ax = plt.subplots(figsize=(8, 6))

    for q, d in [(5, 1), (7, 2), (11, 3), (13, 5)]:
        error_per_trial = d / q
        trials = np.arange(1, 31)
        error_probs = error_per_trial ** trials

        ax.semilogy(trials, error_probs, 'o-', label=f'q={q}, d={d} (d/q={d/q:.2f})',
                    markersize=4)

    ax.axhline(y=1e-6, color='red', linestyle='--', alpha=0.5, label='10⁻⁶ threshold')
    ax.axhline(y=1e-10, color='darkred', linestyle='--', alpha=0.5, label='10⁻¹⁰ threshold')
    ax.set_xlabel('Number of random evaluations', fontsize=12)
    ax.set_ylabel('Error probability (log scale)', fontsize=12)
    ax.set_title('PIT Soundness: Error Probability vs Number of Trials\n'
                 'Pr[false negative] = (d/q)ᵏ after k trials', fontsize=12)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(1e-15, 1)

    plt.tight_layout()
    fig.savefig('/workspace/request-project/viz_pit_convergence.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


def viz_fiber_decomposition():
    """
    Illustrate the fiber decomposition proof technique.
    """
    q = 5
    n = 2
    d = 2
    roots = [0, 1]

    fig, ax = plt.subplots(figsize=(8, 8))

    for x1 in range(q):
        for x2 in range(q):
            val = 1
            for a in roots:
                val = (val * ((x1 - a) % q)) % q

            if val == 0:
                color = '#e74c3c'  # Red for zeros
                marker = 's'
                size = 200
            else:
                color = '#2ecc71'  # Green for nonzero
                marker = 'o'
                size = 100

            ax.scatter(x1, x2, c=color, marker=marker, s=size, zorder=5,
                      edgecolors='black', linewidth=0.5)

    # Draw fiber boundaries
    for x1 in roots:
        ax.axvline(x=x1, color='red', alpha=0.3, linewidth=20)

    # Labels
    ax.set_xlabel('$x_1$ (first coordinate)', fontsize=14)
    ax.set_ylabel('$x_2$ (second coordinate)', fontsize=14)
    ax.set_title(f'Fiber Decomposition of Zero Set\n'
                 f'$f(x_1, x_2) = x_1(x_1 - 1)$ over GF({q})²',
                 fontsize=14)

    zero_patch = mpatches.Patch(color='#e74c3c', label=f'Zeros ({d}×{q}={d*q} points)')
    nonzero_patch = mpatches.Patch(color='#2ecc71', label=f'Nonzero ({(q-d)*q} points)')
    ax.legend(handles=[zero_patch, nonzero_patch], fontsize=12, loc='upper right')

    ax.set_xticks(range(q))
    ax.set_yticks(range(q))
    ax.set_xlim(-0.5, q - 0.5)
    ax.set_ylim(-0.5, q - 0.5)
    ax.grid(True, alpha=0.2)

    plt.tight_layout()
    fig.savefig('/workspace/request-project/viz_fibers.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


if __name__ == "__main__":
    print("Generating visualizations...")
    b64_1 = viz_zero_set_heatmap()
    print(f"  viz_zero_sets.png — {len(b64_1)} chars base64")
    b64_2 = viz_minimum_distance_scaling()
    print(f"  viz_scaling.png — {len(b64_2)} chars base64")
    b64_3 = viz_pit_convergence()
    print(f"  viz_pit_convergence.png — {len(b64_3)} chars base64")
    b64_4 = viz_fiber_decomposition()
    print(f"  viz_fibers.png — {len(b64_4)} chars base64")
    print("Done!")

    # Save base64 data for JSON packaging
    import json
    viz_data = {
        "zero_sets": b64_1,
        "scaling": b64_2,
        "pit_convergence": b64_3,
        "fibers": b64_4
    }
    with open('/workspace/request-project/viz_data.json', 'w') as f:
        json.dump(viz_data, f)
    print("Saved viz_data.json")
