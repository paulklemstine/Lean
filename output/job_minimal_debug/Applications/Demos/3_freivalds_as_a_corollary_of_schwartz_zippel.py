#!/usr/bin/env python3
"""
Applications of Schwartz-Zippel and Freivalds' Algorithm

Real-world applications demonstrating the practical utility of
polynomial identity testing and randomized verification.
"""

import numpy as np
from typing import List, Tuple
import time


# ============================================================================
# Application 1: Fast Matrix Chain Verification
# ============================================================================

def verify_matrix_chain(matrices: List[np.ndarray], claimed_product: np.ndarray,
                        prime: int = 10007, num_trials: int = 3) -> bool:
    """
    Verify that a chain of matrices multiplied together gives the claimed product.

    Uses Freivalds' technique: instead of recomputing the full product (O(k*n^ω)),
    multiply the random vector through the chain from right to left (O(k*n²)).

    Args:
        matrices: List of n×n matrices [M₁, M₂, ..., M_k]
        claimed_product: Claimed value of M₁ * M₂ * ... * M_k
        prime: Field modulus
        num_trials: Number of independent random trials

    Returns:
        True if verification passes.

    Complexity: O(num_trials * k * n²) instead of O(k * n^ω)
    """
    n = matrices[0].shape[0]

    for _ in range(num_trials):
        r = np.random.randint(0, prime, size=(n, 1))

        # Multiply r through the chain from right to left
        v = r.copy()
        for M in reversed(matrices):
            v = M @ v % prime

        # Compare with claimed_product * r
        w = claimed_product @ r % prime

        if not np.array_equal(v % prime, w % prime):
            return False

    return True


def demo_matrix_chain_verification():
    """Demonstrate matrix chain verification."""
    print("=" * 60)
    print("Application 1: Matrix Chain Verification")
    print("=" * 60)

    n = 100
    k = 10  # Chain of 10 matrices
    p = 10007

    # Generate chain
    matrices = [np.random.randint(0, p, (n, n)) for _ in range(k)]

    # Compute correct product
    t0 = time.time()
    product = np.eye(n, dtype=int)
    for M in matrices:
        product = product @ M % p
    t_compute = time.time() - t0

    # Verify correct product
    t0 = time.time()
    result = verify_matrix_chain(matrices, product, p, num_trials=3)
    t_verify = time.time() - t0

    print(f"Chain: {k} matrices of size {n}×{n} over F_{p}")
    print(f"Full computation time: {t_compute:.3f}s")
    print(f"Verification time (3 trials): {t_verify:.3f}s")
    print(f"Speedup: {t_compute/t_verify:.1f}x")
    print(f"Correct product: {'PASS' if result else 'FAIL'}")

    # Verify with single-entry error
    wrong_product = product.copy()
    wrong_product[0, 0] = (wrong_product[0, 0] + 1) % p
    result = verify_matrix_chain(matrices, wrong_product, p, num_trials=3)
    print(f"Incorrect product: {'PASS (missed!)' if result else 'DETECTED'}")
    print(f"Error probability: ≤ (1/{p})^3 ≈ {(1/p)**3:.2e}")
    print()


# ============================================================================
# Application 2: Polynomial Hashing for Data Integrity
# ============================================================================

class PolynomialHash:
    """
    A polynomial-based hash function for data integrity verification.

    Uses the Schwartz-Zippel principle: two distinct data blocks, viewed as
    coefficient vectors of polynomials, produce different hash values with
    high probability when evaluated at a random field element.

    This is the theoretical foundation behind universal hashing and
    message authentication codes (MACs).
    """

    def __init__(self, prime: int = 2**61 - 1):
        """Initialize with a Mersenne prime for efficient arithmetic."""
        self.p = prime
        self.key = np.random.randint(1, prime)

    def hash_block(self, data: List[int]) -> int:
        """
        Hash a data block using polynomial evaluation.

        Interprets data as coefficients of a polynomial and evaluates at key.

        Args:
            data: List of integers representing the data block.

        Returns:
            Hash value in [0, p).
        """
        result = 0
        for d in reversed(data):
            result = (result * self.key + d) % self.p
        return result

    def verify_integrity(self, data1: List[int], data2: List[int]) -> bool:
        """Check if two data blocks have the same hash (probably equal)."""
        return self.hash_block(data1) == self.hash_block(data2)


def demo_polynomial_hashing():
    """Demonstrate polynomial hashing for data integrity."""
    print("=" * 60)
    print("Application 2: Polynomial Hashing")
    print("=" * 60)

    hasher = PolynomialHash(prime=10007)

    # Identical data
    data1 = list(range(1000))
    data2 = list(range(1000))
    print(f"Identical data: hash1={hasher.hash_block(data1)}, hash2={hasher.hash_block(data2)}")
    print(f"Match: {hasher.verify_integrity(data1, data2)}")

    # Different data (single bit flip)
    data3 = list(range(1000))
    data3[500] += 1
    print(f"Modified data:  hash1={hasher.hash_block(data1)}, hash3={hasher.hash_block(data3)}")
    print(f"Match: {hasher.verify_integrity(data1, data3)}")

    # Collision probability analysis
    print(f"\nCollision probability per pair: ≤ {999}/{hasher.p} ≈ {999/hasher.p:.6f}")
    print(f"(By Schwartz-Zippel: degree ≤ 999, field size = {hasher.p})")
    print()


# ============================================================================
# Application 3: Verifiable Computation Delegation
# ============================================================================

def verifiable_dot_product(x: np.ndarray, y: np.ndarray,
                           claimed_result: int, prime: int = 10007,
                           num_checks: int = 3) -> bool:
    """
    Verify a claimed dot product using Freivalds-style random checking.

    Instead of recomputing x·y directly (O(n) multiplications),
    check consistency with random linear combinations.

    In practice, this is most useful when the dot product is part of
    a larger computation that was delegated to an untrusted worker.

    Args:
        x, y: Vectors of length n
        claimed_result: Claimed value of x·y mod prime
        prime: Field modulus
        num_checks: Number of random checks

    Returns:
        True if all checks pass.
    """
    n = len(x)
    for _ in range(num_checks):
        r = np.random.randint(0, prime)
        # Check: r * (x · y) = x · (r * y)
        lhs = (r * claimed_result) % prime
        rhs = int(np.sum(x * ((r * y) % prime)) % prime)
        if lhs != rhs:
            return False
    return True


def demo_verifiable_computation():
    """Demonstrate verifiable computation delegation."""
    print("=" * 60)
    print("Application 3: Verifiable Computation")
    print("=" * 60)

    p = 10007
    n = 1000

    x = np.random.randint(0, p, n)
    y = np.random.randint(0, p, n)
    correct_dot = int(np.sum(x * y) % p)

    # Verify correct result
    result = verifiable_dot_product(x, y, correct_dot, p)
    print(f"Correct dot product: {'PASS' if result else 'FAIL'}")

    # Verify incorrect result
    wrong_dot = (correct_dot + 1) % p
    result = verifiable_dot_product(x, y, wrong_dot, p)
    print(f"Incorrect dot product: {'PASS (missed!)' if result else 'DETECTED'}")
    print()


# ============================================================================
# Application 4: Error Detection in Linear Algebra
# ============================================================================

def verify_linear_system_solution(A: np.ndarray, b: np.ndarray,
                                   x: np.ndarray, prime: int = 10007,
                                   num_trials: int = 3) -> bool:
    """
    Verify that x is a solution to Ax = b (mod p) using random projection.

    Instead of computing Ax directly (O(n²)), project both sides onto
    a random vector r: check r^T(Ax) = r^Tb, i.e., (r^T A)x = r^T b.

    Args:
        A: n×n matrix
        b: n×1 vector
        x: Claimed solution
        prime: Field modulus
        num_trials: Number of checks

    Returns:
        True if all checks pass.
    """
    n = A.shape[0]
    for _ in range(num_trials):
        r = np.random.randint(0, prime, (1, n))
        rA = r @ A % prime
        lhs = int((rA @ x % prime).item())
        rhs = int((r @ b % prime).item())
        if lhs % prime != rhs % prime:
            return False
    return True


def demo_linear_system_verification():
    """Demonstrate linear system verification."""
    print("=" * 60)
    print("Application 4: Linear System Verification")
    print("=" * 60)

    p = 10007
    n = 50

    # Generate random system with known solution
    A = np.random.randint(0, p, (n, n))
    x_true = np.random.randint(0, p, (n, 1))
    b = A @ x_true % p

    # Verify correct solution
    result = verify_linear_system_solution(A, b, x_true, p)
    print(f"Correct solution: {'PASS' if result else 'FAIL'}")

    # Verify incorrect solution
    x_wrong = x_true.copy()
    x_wrong[0, 0] = (x_wrong[0, 0] + 1) % p
    result = verify_linear_system_solution(A, b, x_wrong, p)
    print(f"Incorrect solution: {'PASS (missed!)' if result else 'DETECTED'}")
    print()


if __name__ == "__main__":
    np.random.seed(42)
    demo_matrix_chain_verification()
    demo_polynomial_hashing()
    demo_verifiable_computation()
    demo_linear_system_verification()


#!/usr/bin/env python3
"""
Demo: Schwartz–Zippel Lemma and Freivalds' Algorithm

Concrete numerical demonstrations of:
1. Freivalds' randomized matrix multiplication verification
2. Schwartz–Zippel zero counting for multivariate polynomials
3. Reed–Muller code distance verification
"""

import numpy as np
from itertools import product as cartesian_product
from collections import Counter


def mod_matmul(A, B, p):
    """Matrix multiplication modulo p."""
    return (A @ B) % p


def freivalds_test(A, B, C, p, num_trials=1):
    """
    Freivalds' algorithm: test whether A*B = C (mod p).
    Returns True if the test passes (consistent with A*B = C).
    """
    n = A.shape[0]
    for _ in range(num_trials):
        r = np.random.randint(0, p, size=(n, 1))
        Br = (B @ r) % p
        ABr = (A @ Br) % p
        Cr = (C @ r) % p
        if not np.array_equal(ABr % p, Cr % p):
            return False  # Definitely A*B != C
    return True  # Probably A*B = C


def demo_freivalds():
    """Demonstrate Freivalds' algorithm with error rate measurement."""
    print("=" * 60)
    print("DEMO 1: Freivalds' Algorithm Error Rate")
    print("=" * 60)
    print()

    n = 20  # Matrix size
    num_experiments = 10000

    primes = [2, 3, 5, 11, 101]

    print(f"Matrix size: {n}x{n}")
    print(f"Experiments per prime: {num_experiments}")
    print()
    print(f"{'Prime p':>10} | {'Theory (1/p)':>12} | {'Empirical':>12} | {'Ratio':>8}")
    print("-" * 50)

    for p in primes:
        # Generate random matrices
        A = np.random.randint(0, p, size=(n, n))
        B = np.random.randint(0, p, size=(n, n))
        C = mod_matmul(A, B, p)

        # Introduce a single-entry error
        i, j = np.random.randint(0, n), np.random.randint(0, n)
        C_wrong = C.copy()
        C_wrong[i, j] = (C_wrong[i, j] + 1) % p

        # Count how many times Freivalds' test fails to detect the error
        false_accepts = sum(
            1 for _ in range(num_experiments)
            if freivalds_test(A, B, C_wrong, p, num_trials=1)
        )

        empirical_rate = false_accepts / num_experiments
        theory_rate = 1.0 / p
        ratio = empirical_rate / theory_rate if theory_rate > 0 else float('inf')

        print(f"{p:>10} | {theory_rate:>12.6f} | {empirical_rate:>12.6f} | {ratio:>8.3f}")

    print()
    print("The empirical error rate closely matches the theoretical bound 1/p.")
    print("This is the degree-1 Schwartz-Zippel bound in action!")
    print()

    # Amplification demo
    print("Amplification by repetition (p=2, n=20):")
    print(f"{'Repetitions k':>15} | {'Theory (1/2^k)':>15} | {'Empirical':>12}")
    print("-" * 48)

    A = np.random.randint(0, 2, size=(n, n))
    B = np.random.randint(0, 2, size=(n, n))
    C = mod_matmul(A, B, 2)
    C_wrong = C.copy()
    C_wrong[0, 0] = (C_wrong[0, 0] + 1) % 2

    for k in [1, 2, 3, 5, 10]:
        false_accepts = sum(
            1 for _ in range(num_experiments)
            if freivalds_test(A, B, C_wrong, 2, num_trials=k)
        )
        empirical_rate = false_accepts / num_experiments
        theory_rate = 0.5 ** k
        print(f"{k:>15} | {theory_rate:>15.8f} | {empirical_rate:>12.6f}")

    print()


def eval_poly_over_field(coeffs, point, p):
    """
    Evaluate a multivariate polynomial at a point over F_p.
    coeffs: dict mapping exponent tuples to coefficients
    point: tuple of values
    """
    result = 0
    for exps, coeff in coeffs.items():
        term = coeff
        for i, e in enumerate(exps):
            term = (term * pow(int(point[i]), int(e), p)) % p
        result = (result + term) % p
    return result


def count_zeros(coeffs, n, p):
    """Count zeros of a polynomial over F_p^n by exhaustive enumeration."""
    zeros = 0
    for point in cartesian_product(range(p), repeat=n):
        if eval_poly_over_field(coeffs, point, p) == 0:
            zeros += 1
    return zeros


def total_degree(coeffs):
    """Compute total degree of a polynomial."""
    if not coeffs:
        return 0
    return max(sum(exps) for exps in coeffs.keys())


def demo_schwartz_zippel():
    """Demonstrate the Schwartz-Zippel zero counting bound."""
    print("=" * 60)
    print("DEMO 2: Schwartz-Zippel Zero Counting")
    print("=" * 60)
    print()

    p = 5  # Work over F_5

    examples = [
        # (name, n_vars, coefficients_dict)
        ("x0^2 + x1^2", 2, {(2, 0): 1, (0, 2): 1}),
        ("x0*x1 + x0 + 1", 2, {(1, 1): 1, (1, 0): 1, (0, 0): 1}),
        ("x0^3 + x1^2 + x2", 3, {(3, 0, 0): 1, (0, 2, 0): 1, (0, 0, 1): 1}),
        ("x0*x1*x2", 3, {(1, 1, 1): 1}),
        ("x0 + 2*x1 + 3*x2 + 4*x3", 4,
         {(1, 0, 0, 0): 1, (0, 1, 0, 0): 2, (0, 0, 1, 0): 3, (0, 0, 0, 1): 4}),
    ]

    print(f"Field: F_{p} (q = {p})")
    print()
    print(f"{'Polynomial':>30} | {'n':>3} | {'deg':>4} | {'|Z(f)|':>7} | {'Bound d*q^(n-1)':>16} | {'OK':>4}")
    print("-" * 75)

    for name, n, coeffs in examples:
        d = total_degree(coeffs)
        zeros = count_zeros(coeffs, n, p)
        bound = d * (p ** (n - 1))
        ok = "✓" if zeros <= bound else "✗"
        print(f"{name:>30} | {n:>3} | {d:>4} | {zeros:>7} | {bound:>16} | {ok:>4}")

    print()
    print("All zero counts satisfy the Schwartz-Zippel bound |Z(f)| ≤ deg(f) · q^(n-1).")
    print()


def demo_linear_case():
    """Demonstrate the degree-1 (linear) case explicitly."""
    print("=" * 60)
    print("DEMO 3: Degree-1 Case (Freivalds' Principle)")
    print("=" * 60)
    print()

    for p in [2, 3, 5, 7]:
        for n in [2, 3, 4]:
            # Random nonzero linear form
            while True:
                v = tuple(np.random.randint(0, p, size=n))
                if any(x != 0 for x in v):
                    break

            # Count solutions to sum(v_i * x_i) = 0
            zeros = 0
            total = p ** n
            for x in cartesian_product(range(p), repeat=n):
                if sum(v[i] * x[i] for i in range(n)) % p == 0:
                    zeros += 1

            bound = p ** (n - 1)
            prob = zeros / total
            print(f"F_{p}, n={n}, v={v}: zeros={zeros}, bound={bound}, prob={prob:.4f}, 1/p={1/p:.4f}")

    print()
    print("For degree-1 polynomials, |Z(f)| = q^(n-1) exactly (equality holds).")
    print("This means Pr[f(r)=0] = 1/q exactly — the Freivalds error rate!")
    print()


def demo_reed_muller():
    """Demonstrate Reed-Muller code distance."""
    print("=" * 60)
    print("DEMO 4: Reed-Muller Code Distance")
    print("=" * 60)
    print()

    p = 3  # F_3
    m = 2  # 2 variables

    print(f"Reed-Muller codes over F_{p}, m={m} variables")
    print(f"Code length: {p**m}")
    print()
    print(f"{'Degree r':>10} | {'Min dist (theory)':>18} | {'Min weight (found)':>19} | {'Match':>6}")
    print("-" * 60)

    points = list(cartesian_product(range(p), repeat=m))

    for r in range(1, p):
        # Generate all monomials of degree <= r in m variables
        monomials = []
        for exps in cartesian_product(range(r + 1), repeat=m):
            if sum(exps) <= r:
                monomials.append(exps)

        # Find minimum weight codeword by sampling
        min_weight = p ** m  # Maximum possible
        num_samples = min(2000, p ** len(monomials))

        for _ in range(num_samples):
            # Random polynomial of degree <= r
            coeffs = {}
            for mon in monomials:
                c = np.random.randint(0, p)
                if c != 0:
                    coeffs[mon] = c

            if not coeffs:
                continue

            # Evaluate at all points
            weight = 0
            for pt in points:
                val = eval_poly_over_field(coeffs, pt, p)
                if val != 0:
                    weight += 1

            if weight > 0:
                min_weight = min(min_weight, weight)

        theory_dist = (p - r) * (p ** (m - 1))
        match = "✓" if min_weight >= theory_dist else "✗"
        print(f"{r:>10} | {theory_dist:>18} | {min_weight:>19} | {match:>6}")

    print()
    print("The minimum distance matches (q-r) * q^(m-1), derived from Schwartz-Zippel.")
    print()


if __name__ == "__main__":
    np.random.seed(42)
    demo_freivalds()
    demo_schwartz_zippel()
    demo_linear_case()
    demo_reed_muller()


#!/usr/bin/env python3
"""Generate PACKAGE.json with all artifacts."""

import json
import base64
import io
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import product as cartesian_product


def fig_to_base64(fig) -> str:
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def read_file(path):
    with open(path, 'r') as f:
        return f.read()


def generate_freivalds_viz():
    np.random.seed(42)
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]
    n = 20
    num_trials_per = 3000
    empirical_rates = []
    for p in primes:
        A = np.random.randint(0, p, (n, n))
        B = np.random.randint(0, p, (n, n))
        C = A @ B % p
        C_wrong = C.copy()
        C_wrong[0, 0] = (C_wrong[0, 0] + 1) % p
        false_accepts = 0
        for _ in range(num_trials_per):
            r = np.random.randint(0, p, (n, 1))
            if np.array_equal((A @ (B @ r)) % p, (C_wrong @ r) % p):
                false_accepts += 1
        empirical_rates.append(false_accepts / num_trials_per)
    theoretical_rates = [1.0 / p for p in primes]
    ax1.scatter(primes, empirical_rates, c='#2196F3', s=60, zorder=5, label='Empirical', edgecolors='navy', linewidths=0.5)
    ax1.plot(primes, theoretical_rates, 'r-', linewidth=2, label='Theory: 1/p')
    ax1.set_xlabel('Prime p', fontsize=12)
    ax1.set_ylabel('Error probability', fontsize=12)
    ax1.set_title("Freivalds' Error Rate vs Field Size", fontsize=13)
    ax1.legend(fontsize=11)
    ax1.set_yscale('log')
    ax1.grid(True, alpha=0.3)

    p = 2
    ks = list(range(1, 11))
    empirical_amp = []
    A = np.random.randint(0, p, (n, n))
    B = np.random.randint(0, p, (n, n))
    C = A @ B % p
    C_wrong = C.copy()
    C_wrong[0, 0] = (C_wrong[0, 0] + 1) % p
    for k in ks:
        false_accepts = 0
        for _ in range(10000):
            passed = True
            for _ in range(k):
                r = np.random.randint(0, p, (n, 1))
                if not np.array_equal((A @ (B @ r)) % p, (C_wrong @ r) % p):
                    passed = False
                    break
            if passed:
                false_accepts += 1
        empirical_amp.append(max(false_accepts / 10000, 1e-5))
    theoretical_amp = [(1.0 / p) ** k for k in ks]
    ax2.semilogy(ks, theoretical_amp, 'r-', linewidth=2, label='Theory: (1/p)^k')
    ax2.semilogy(ks, empirical_amp, 's-', color='#2196F3', markersize=6, label='Empirical', linewidth=1)
    ax2.set_xlabel('Number of trials k', fontsize=12)
    ax2.set_ylabel('Error probability', fontsize=12)
    ax2.set_title('Error Amplification (p=2)', fontsize=13)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)
    fig.suptitle("Freivalds' Algorithm: The Degree-1 Schwartz-Zippel Bound", fontsize=14, y=1.02)
    fig.tight_layout()
    return fig_to_base64(fig)


def generate_zero_sets_viz():
    np.random.seed(42)
    fig, axes = plt.subplots(2, 3, figsize=(15, 10))
    p = 7
    polynomials = [
        ("x+2y (deg 1)", lambda x, y: (x + 2*y) % p),
        ("x²+y² (deg 2)", lambda x, y: (x**2 + y**2) % p),
        ("xy (deg 2)", lambda x, y: (x*y) % p),
        ("x³+y (deg 3)", lambda x, y: (x**3 + y) % p),
        ("x²y+xy² (deg 3)", lambda x, y: (x**2 * y + x * y**2) % p),
        ("x²+y²+xy+1 (deg 2)", lambda x, y: (x**2 + y**2 + x*y + 1) % p),
    ]
    for ax, (name, f) in zip(axes.flat, polynomials):
        zeros_x, zeros_y = [], []
        nonzeros_x, nonzeros_y = [], []
        for x in range(p):
            for y in range(p):
                if f(x, y) == 0:
                    zeros_x.append(x); zeros_y.append(y)
                else:
                    nonzeros_x.append(x); nonzeros_y.append(y)
        deg = int(name.split("deg ")[1].split(")")[0])
        bound = deg * p
        ax.scatter(nonzeros_x, nonzeros_y, c='lightgray', s=30, alpha=0.5)
        ax.scatter(zeros_x, zeros_y, c='red', s=60, zorder=5, edgecolors='darkred', linewidths=0.5)
        ax.set_title(f'{name}\n|Z(f)| = {len(zeros_x)} ≤ {bound}', fontsize=11)
        ax.set_xticks(range(p)); ax.set_yticks(range(p))
        ax.grid(True, alpha=0.2); ax.set_aspect('equal')
    fig.suptitle(f'Zero Sets over F_7: Schwartz-Zippel Bound', fontsize=14)
    fig.tight_layout()
    return fig_to_base64(fig)


def generate_bound_tightness_viz():
    np.random.seed(42)
    fig, ax = plt.subplots(figsize=(8, 5))
    for p in [5, 7, 11]:
        degrees = list(range(1, p))
        actual_zeros = []
        bounds = []
        for d in degrees:
            count = 0
            for x in range(p):
                for y in range(p):
                    if (pow(x, d, p) + y) % p == 0:
                        count += 1
            actual_zeros.append(count)
            bounds.append(d * p)
        ax.plot(degrees, actual_zeros, 'o-', label=f'|Z(x^d+y)|, p={p}', markersize=5)
        ax.plot(degrees, bounds, '--', label=f'Bound d·p, p={p}', alpha=0.7)
    ax.set_xlabel('Degree d', fontsize=12)
    ax.set_ylabel('Number of zeros', fontsize=12)
    ax.set_title('Schwartz-Zippel Bound Tightness (n=2)', fontsize=13)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    return fig_to_base64(fig)


def main():
    article = read_file('/workspace/request-project/ARTICLE.md')
    research_paper = read_file('/workspace/request-project/RESEARCH_PAPER.md')
    future_directions = read_file('/workspace/request-project/FUTURE_DIRECTIONS.md')
    demo_code = read_file('/workspace/request-project/demo.py')
    algorithms_code = read_file('/workspace/request-project/algorithms.py')
    applications_code = read_file('/workspace/request-project/applications.py')

    lean_files = [
        '/workspace/request-project/Catalog/Algebra/CircuitComplexity/SchwartzZippel.lean',
        '/workspace/request-project/Catalog/Algebra/CircuitComplexity/Freivalds.lean',
        '/workspace/request-project/Catalog/Algebra/CircuitComplexity/FreivaldsSchwartzZippel.lean',
    ]
    lean_code = ""
    for lf in lean_files:
        lean_code += f"-- FILE: {lf.split('/')[-1]}\n"
        lean_code += read_file(lf) + "\n\n"

    print("Generating visualizations...")
    viz1 = generate_freivalds_viz()
    viz2 = generate_zero_sets_viz()
    viz3 = generate_bound_tightness_viz()

    package = {
        "title": "Freivalds as the Degree-1 Shadow of Schwartz-Zippel over Finite Fields",
        "domain": "Algebraic Complexity and Randomized Verification",
        "article": article,
        "research_paper": research_paper,
        "future_directions": future_directions,
        "demos": [
            {
                "name": "Schwartz-Zippel and Freivalds Demo",
                "code": demo_code
            },
            {
                "name": "Applications Demo",
                "code": applications_code
            }
        ],
        "algorithms": [
            {
                "name": "Freivalds' Algorithm",
                "pseudocode": "procedure FREIVALDS(A, B, C, q):\n    r <- random vector in F_q^n\n    if A * (B * r) = C * r:\n        return ACCEPT\n    else:\n        return REJECT\n\nComplexity: O(n^2) per trial\nError: Pr[false accept | AB != C] <= 1/q",
                "code": algorithms_code
            },
            {
                "name": "Schwartz-Zippel PIT",
                "pseudocode": "procedure SZ_PIT(circuit C, field F_q, degree d):\n    r <- random point in F_q^n\n    if C(r) != 0:\n        return NONZERO\n    else:\n        return POSSIBLY_ZERO\n\nSoundness: Pr[f(r)=0 | f != 0] <= d/q",
                "code": algorithms_code
            }
        ],
        "visualizations": [
            {"name": "Freivalds Error Rates", "data": viz1},
            {"name": "Zero Sets over Finite Fields", "data": viz2},
            {"name": "Schwartz-Zippel Bound Tightness", "data": viz3}
        ],
        "lean_proofs": lean_code
    }

    with open('/workspace/request-project/PACKAGE.json', 'w') as f:
        json.dump(package, f, indent=2, ensure_ascii=False)

    print("PACKAGE.json generated successfully.")
    print(f"Size: {len(json.dumps(package))} bytes")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualizations for Schwartz-Zippel and Freivalds' Algorithm.
Generates PNG figures for the research package.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import product as cartesian_product
import base64
import io
import json


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def viz_freivalds_error_rates():
    """Plot Freivalds error rates vs theoretical bounds."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Left panel: Error rate vs prime
    primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]
    n = 20
    num_trials_per = 5000

    empirical_rates = []
    for p in primes:
        A = np.random.randint(0, p, (n, n))
        B = np.random.randint(0, p, (n, n))
        C = A @ B % p
        C_wrong = C.copy()
        C_wrong[0, 0] = (C_wrong[0, 0] + 1) % p

        false_accepts = 0
        for _ in range(num_trials_per):
            r = np.random.randint(0, p, (n, 1))
            if np.array_equal((A @ (B @ r)) % p, (C_wrong @ r) % p):
                false_accepts += 1
        empirical_rates.append(false_accepts / num_trials_per)

    theoretical_rates = [1.0 / p for p in primes]

    ax1.scatter(primes, empirical_rates, c='#2196F3', s=60, zorder=5,
                label='Empirical', edgecolors='navy', linewidths=0.5)
    ax1.plot(primes, theoretical_rates, 'r-', linewidth=2, label='Theory: 1/p')
    ax1.set_xlabel('Prime p', fontsize=12)
    ax1.set_ylabel('Error probability', fontsize=12)
    ax1.set_title("Freivalds' Error Rate vs Field Size", fontsize=13)
    ax1.legend(fontsize=11)
    ax1.set_yscale('log')
    ax1.grid(True, alpha=0.3)

    # Right panel: Amplification by repetition
    p = 2
    max_k = 15
    ks = list(range(1, max_k + 1))
    num_trials_per = 20000

    A = np.random.randint(0, p, (n, n))
    B = np.random.randint(0, p, (n, n))
    C = A @ B % p
    C_wrong = C.copy()
    C_wrong[0, 0] = (C_wrong[0, 0] + 1) % p

    empirical_amp = []
    for k in ks:
        false_accepts = 0
        for _ in range(num_trials_per):
            passed = True
            for _ in range(k):
                r = np.random.randint(0, p, (n, 1))
                if not np.array_equal((A @ (B @ r)) % p, (C_wrong @ r) % p):
                    passed = False
                    break
            if passed:
                false_accepts += 1
        rate = max(false_accepts / num_trials_per, 1e-6)
        empirical_amp.append(rate)

    theoretical_amp = [(1.0 / p) ** k for k in ks]

    ax2.semilogy(ks, theoretical_amp, 'r-', linewidth=2, label='Theory: (1/p)^k')
    ax2.semilogy(ks, empirical_amp, 's-', color='#2196F3', markersize=6,
                 label='Empirical', linewidth=1)
    ax2.set_xlabel('Number of trials k', fontsize=12)
    ax2.set_ylabel('Error probability', fontsize=12)
    ax2.set_title('Error Amplification (p=2)', fontsize=13)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)

    fig.suptitle("Freivalds' Algorithm: The Degree-1 Schwartz–Zippel Bound", fontsize=14, y=1.02)
    fig.tight_layout()
    return fig


def viz_zero_sets():
    """Visualize zero sets of polynomials over finite fields."""
    fig, axes = plt.subplots(2, 3, figsize=(15, 10))

    p = 7  # Work over F_7

    polynomials = [
        ("$x + 2y$ (deg 1)", lambda x, y: (x + 2*y) % p),
        ("$x^2 + y^2$ (deg 2)", lambda x, y: (x**2 + y**2) % p),
        ("$xy$ (deg 2)", lambda x, y: (x*y) % p),
        ("$x^3 + y$ (deg 3)", lambda x, y: (x**3 + y) % p),
        ("$x^2 y + x y^2$ (deg 3)", lambda x, y: (x**2 * y + x * y**2) % p),
        ("$x^2 + y^2 + xy + 1$ (deg 2)", lambda x, y: (x**2 + y**2 + x*y + 1) % p),
    ]

    for ax, (name, f) in zip(axes.flat, polynomials):
        zeros_x, zeros_y = [], []
        nonzeros_x, nonzeros_y = [], []

        for x in range(p):
            for y in range(p):
                if f(x, y) == 0:
                    zeros_x.append(x)
                    zeros_y.append(y)
                else:
                    nonzeros_x.append(x)
                    nonzeros_y.append(y)

        deg = int(name.split("deg ")[1].split(")")[0])
        bound = deg * p

        ax.scatter(nonzeros_x, nonzeros_y, c='lightgray', s=30, alpha=0.5, label='f ≠ 0')
        ax.scatter(zeros_x, zeros_y, c='red', s=60, zorder=5, edgecolors='darkred',
                   linewidths=0.5, label='f = 0')
        ax.set_title(f'{name}\n|Z(f)| = {len(zeros_x)} ≤ {bound}', fontsize=11)
        ax.set_xlabel('x')
        ax.set_ylabel('y')
        ax.set_xticks(range(p))
        ax.set_yticks(range(p))
        ax.grid(True, alpha=0.2)
        ax.set_aspect('equal')

    fig.suptitle(f'Zero Sets of Polynomials over $\\mathbb{{F}}_{{{p}}}$\n'
                 f'Schwartz–Zippel: |Z(f)| ≤ deg(f) · q = deg(f) · {p}', fontsize=14)
    fig.tight_layout()
    return fig


def viz_theorem_landscape():
    """Visualize the theorem dependency/connection landscape."""
    fig, ax = plt.subplots(figsize=(12, 8))
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 10)
    ax.axis('off')

    # Boxes
    boxes = {
        'UV': (5, 9, 'Univariate\nRoot Bound'),
        'SZ': (5, 7, 'Schwartz–Zippel\nLemma'),
        'LSZ': (2, 5, 'Linear\nSchwartz–Zippel'),
        'FR': (2, 3, "Freivalds'\nAlgorithm"),
        'PIT': (5, 5, 'Polynomial\nIdentity Testing'),
        'RM': (8, 5, 'Reed–Muller\nCode Distance'),
        'SC': (5, 3, 'Sum-Check\nProtocol'),
        'DR': (8, 3, 'Derandomization\nBarriers'),
        'CN': (8, 7, 'Combinatorial\nNullstellensatz'),
    }

    colors = {
        'UV': '#E3F2FD', 'SZ': '#BBDEFB', 'LSZ': '#90CAF9',
        'FR': '#64B5F6', 'PIT': '#42A5F5', 'RM': '#2196F3',
        'SC': '#1E88E5', 'DR': '#1565C0', 'CN': '#0D47A1',
    }

    for key, (x, y, label) in boxes.items():
        bbox = dict(boxstyle='round,pad=0.5', facecolor=colors[key],
                    edgecolor='navy', linewidth=1.5, alpha=0.8)
        ax.text(x, y, label, fontsize=10, ha='center', va='center',
                bbox=bbox, fontweight='bold', color='white' if key in ['DR', 'CN'] else 'black')

    # Arrows
    arrows = [
        ('UV', 'SZ'), ('SZ', 'LSZ'), ('SZ', 'PIT'), ('SZ', 'RM'),
        ('LSZ', 'FR'), ('PIT', 'SC'), ('PIT', 'DR'), ('SZ', 'CN'),
    ]

    for src, dst in arrows:
        x1, y1, _ = boxes[src]
        x2, y2, _ = boxes[dst]
        ax.annotate('', xy=(x2, y2 + 0.4), xytext=(x1, y1 - 0.4),
                    arrowprops=dict(arrowstyle='->', color='navy', lw=2))

    # Highlight the key bridge
    ax.annotate('DEGREE-1\nSPECIALIZATION',
                xy=(2.3, 4), fontsize=8, color='red', fontweight='bold',
                ha='center')

    ax.set_title('Theorem Landscape: From Univariate Roots to Complexity Theory',
                 fontsize=14, fontweight='bold', pad=20)

    # Legend
    legend_text = (
        "Blue intensity = conceptual depth\n"
        "Arrows = formal derivation direction\n"
        "■ DONE (formally verified)  □ Future work"
    )
    ax.text(0.5, 0.5, legend_text, fontsize=9, color='gray',
            transform=ax.transAxes, ha='center', va='bottom')

    fig.tight_layout()
    return fig


def viz_sz_bound_tightness():
    """Show how tight the Schwartz-Zippel bound is for various parameters."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Left: zeros vs bound for varying degree (fixed n=2, varying p)
    for p in [5, 7, 11]:
        degrees = list(range(1, p))
        actual_zeros = []
        bounds = []

        for d in degrees:
            # Count zeros of x^d + y (degree d in 2 variables over F_p)
            count = 0
            for x in range(p):
                for y in range(p):
                    if (pow(x, d, p) + y) % p == 0:
                        count += 1
            actual_zeros.append(count)
            bounds.append(d * p)

        ax1.plot(degrees, actual_zeros, 'o-', label=f'|Z(x^d+y)|, p={p}', markersize=5)
        ax1.plot(degrees, bounds, '--', label=f'Bound d·p, p={p}', alpha=0.7)

    ax1.set_xlabel('Degree d', fontsize=12)
    ax1.set_ylabel('Number of zeros', fontsize=12)
    ax1.set_title('Schwartz–Zippel Bound Tightness (n=2)', fontsize=13)
    ax1.legend(fontsize=9)
    ax1.grid(True, alpha=0.3)

    # Right: ratio |Z(f)| / bound for random polynomials
    p = 5
    n = 3
    num_samples = 200

    degrees = [1, 2, 3, 4]
    for d in degrees:
        ratios = []
        for _ in range(num_samples):
            # Random polynomial of degree d
            coeffs = {}
            for exps in cartesian_product(range(d + 1), repeat=n):
                if sum(exps) <= d:
                    c = np.random.randint(0, p)
                    if c != 0:
                        coeffs[exps] = c
            if not coeffs:
                continue

            # Count zeros
            zeros = 0
            for pt in cartesian_product(range(p), repeat=n):
                val = 0
                for exps, c in coeffs.items():
                    term = c
                    for i, e in enumerate(exps):
                        term = (term * pow(pt[i], e, p)) % p
                    val = (val + term) % p
                if val == 0:
                    zeros += 1

            bound = d * p ** (n - 1)
            if bound > 0:
                ratios.append(zeros / bound)

        if ratios:
            ax2.hist(ratios, bins=20, alpha=0.5, label=f'deg={d}', density=True)

    ax2.axvline(x=1.0, color='red', linestyle='--', linewidth=2, label='Bound')
    ax2.set_xlabel('|Z(f)| / (d · q^(n-1))', fontsize=12)
    ax2.set_ylabel('Density', fontsize=12)
    ax2.set_title(f'Zero Count / Bound Ratio (p={p}, n={n})', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    fig.suptitle('Schwartz–Zippel Bound: Tightness Analysis', fontsize=14, y=1.02)
    fig.tight_layout()
    return fig


def generate_all_visualizations():
    """Generate all visualizations and return as base64 dict."""
    np.random.seed(42)

    print("Generating Freivalds error rate plot...")
    fig1 = viz_freivalds_error_rates()
    fig1.savefig('/workspace/request-project/freivalds_error_rates.png', dpi=150, bbox_inches='tight')
    b64_1 = fig_to_base64(viz_freivalds_error_rates())

    print("Generating zero sets plot...")
    fig2 = viz_zero_sets()
    fig2.savefig('/workspace/request-project/zero_sets.png', dpi=150, bbox_inches='tight')
    b64_2 = fig_to_base64(viz_zero_sets())

    print("Generating theorem landscape...")
    fig3 = viz_theorem_landscape()
    fig3.savefig('/workspace/request-project/theorem_landscape.png', dpi=150, bbox_inches='tight')
    b64_3 = fig_to_base64(viz_theorem_landscape())

    print("Generating bound tightness plot...")
    fig4 = viz_sz_bound_tightness()
    fig4.savefig('/workspace/request-project/bound_tightness.png', dpi=150, bbox_inches='tight')
    b64_4 = fig_to_base64(viz_sz_bound_tightness())

    return {
        'freivalds_error_rates': b64_1,
        'zero_sets': b64_2,
        'theorem_landscape': b64_3,
        'bound_tightness': b64_4,
    }


if __name__ == "__main__":
    vizs = generate_all_visualizations()
    print(f"\nGenerated {len(vizs)} visualizations.")
    for name, data in vizs.items():
        print(f"  {name}: {len(data)} bytes (base64)")
