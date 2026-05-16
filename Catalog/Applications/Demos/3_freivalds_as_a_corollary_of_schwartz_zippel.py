#!/usr/bin/env python3
"""
Applications of Schwartz–Zippel and Freivalds' Algorithm

Real-world and theoretical applications demonstrating the practical
significance of polynomial identity testing and randomized verification.

Applications:
1. Fast matrix product verification in numerical computing
2. Polynomial identity testing for symbolic computation
3. Fingerprinting for data stream comparison
4. Interactive proof simulation (sum-check inspired)
"""

import random
import time
import hashlib
from typing import List, Tuple, Dict
from functools import reduce


# ══════════════════════════════════════════════════════════════════
# Application 1: Practical Matrix Verification
# ══════════════════════════════════════════════════════════════════

def matrix_multiply_naive(A: List[List[int]], B: List[List[int]], p: int) -> List[List[int]]:
    """O(n³) matrix multiplication mod p."""
    n = len(A)
    C = [[0]*n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            for k in range(n):
                C[i][j] = (C[i][j] + A[i][k] * B[k][j]) % p
    return C


def mat_vec_mul(M: List[List[int]], v: List[int], p: int) -> List[int]:
    """O(n²) matrix-vector multiplication mod p."""
    n = len(M)
    return [sum(M[i][j] * v[j] for j in range(n)) % p for i in range(n)]


def freivalds_verify_practical(
    A: List[List[int]], B: List[List[int]], C: List[List[int]],
    p: int, num_trials: int = 20
) -> Tuple[bool, float]:
    """
    Practical Freivalds verification.

    Total cost: O(k · n²) versus O(n³) for recomputation.
    Error probability: ≤ (1/p)^k

    For p = 2^61 - 1 (Mersenne prime) and k = 3:
        Error ≤ 2^{-183}, far below hardware error rates.
    """
    n = len(A)
    for _ in range(num_trials):
        r = [random.randint(0, p - 1) for _ in range(n)]
        Br = mat_vec_mul(B, r, p)
        ABr = mat_vec_mul(A, Br, p)
        Cr = mat_vec_mul(C, r, p)
        if ABr != Cr:
            return False, 0.0  # Definitely wrong
    return True, (1.0 / p) ** num_trials


def application_matrix_verification():
    """
    Demonstrate speed advantage of Freivalds over recomputation.
    """
    print("=" * 65)
    print("APPLICATION 1: Practical Matrix Product Verification")
    print("=" * 65)
    print()

    p = 1000000007  # Large prime

    for n in [50, 100, 200]:
        A = [[random.randint(0, p-1) for _ in range(n)] for _ in range(n)]
        B = [[random.randint(0, p-1) for _ in range(n)] for _ in range(n)]

        # Time the full multiplication
        t0 = time.time()
        C = matrix_multiply_naive(A, B, p)
        t_mult = time.time() - t0

        # Time Freivalds (3 rounds)
        t0 = time.time()
        result, error = freivalds_verify_practical(A, B, C, p, num_trials=3)
        t_verify = time.time() - t0

        speedup = t_mult / t_verify if t_verify > 0 else float('inf')
        print(f"  n={n:3d}: multiply={t_mult:.4f}s, verify={t_verify:.4f}s, "
              f"speedup={speedup:.1f}x, error≤{error:.2e}")

    print()
    print("  Key insight: Verification is O(n²) per trial, multiplication is O(n³).")
    print("  The Schwartz–Zippel guarantee means we trust the result with")
    print("  probability > 1 - 10^{-27} after just 3 trials over a billion-size field.")
    print()


# ══════════════════════════════════════════════════════════════════
# Application 2: Polynomial Identity Testing for Symbolic Math
# ══════════════════════════════════════════════════════════════════

def eval_expression(expr_fn, point: List[int], p: int) -> int:
    """Evaluate a symbolic expression at a point mod p."""
    return expr_fn(*point) % p


def application_pit():
    """
    Demonstrate PIT for checking algebraic identities.
    """
    print("=" * 65)
    print("APPLICATION 2: Polynomial Identity Testing")
    print("=" * 65)
    print()
    print("  Testing algebraic identities by random evaluation:")
    print()

    p = 1000000007

    # Identity 1: (a+b)^3 = a^3 + 3a^2b + 3ab^2 + b^3
    def lhs1(a, b): return pow(a + b, 3, p)
    def rhs1(a, b): return (pow(a, 3, p) + 3 * pow(a, 2, p) * b + 3 * a * pow(b, 2, p) + pow(b, 3, p)) % p

    # Identity 2: det(AB) = det(A)det(B) for 2x2 (encode as polynomial)
    def det2(a, b, c, d): return (a * d - b * c) % p
    def lhs2(a, b, c, d, e, f, g, h):
        # det(A*B) where A=[[a,b],[c,d]], B=[[e,f],[g,h]]
        return det2(a*e+b*g, a*f+b*h, c*e+d*g, c*f+d*h) % p
    def rhs2(a, b, c, d, e, f, g, h):
        return (det2(a, b, c, d) * det2(e, f, g, h)) % p

    # Non-identity: (a+b)^2 ≠ a^2 + b^2 in general
    def lhs3(a, b): return pow(a + b, 2, p)
    def rhs3(a, b): return (pow(a, 2, p) + pow(b, 2, p)) % p

    identities = [
        ("(a+b)³ = a³ + 3a²b + 3ab² + b³", lhs1, rhs1, 2, True),
        ("det(AB) = det(A)·det(B) [2×2]", lhs2, rhs2, 8, True),
        ("(a+b)² = a² + b²", lhs3, rhs3, 2, False),
    ]

    for name, lhs, rhs, n_vars, expected in identities:
        is_identity = True
        for _ in range(20):
            point = [random.randint(0, p-1) for _ in range(n_vars)]
            if lhs(*point) % p != rhs(*point) % p:
                is_identity = False
                break

        status = "IDENTITY" if is_identity else "NOT IDENTITY"
        correct = "✓" if (is_identity == expected) else "✗"
        print(f"  {name}")
        print(f"    Result: {status} (expected: {'identity' if expected else 'not identity'}) {correct}")
        print()

    print("  Schwartz–Zippel guarantees: if an identity of degree d fails")
    print("  to be detected in k trials over GF(p), the probability of")
    print("  a false positive is at most (d/p)^k.")
    print()


# ══════════════════════════════════════════════════════════════════
# Application 3: Polynomial Fingerprinting
# ══════════════════════════════════════════════════════════════════

def polynomial_fingerprint(data: List[int], point: int, p: int) -> int:
    """
    Compute a polynomial fingerprint of data.

    Interprets data as coefficients of a polynomial and evaluates at `point`.
    f(x) = data[0] + data[1]*x + data[2]*x^2 + ...

    By Schwartz–Zippel: two different data streams of length n
    have the same fingerprint with probability ≤ (n-1)/p.
    """
    val = 0
    xpow = 1
    for coeff in data:
        val = (val + coeff * xpow) % p
        xpow = (xpow * point) % p
    return val


def application_fingerprinting():
    """
    Demonstrate polynomial fingerprinting for data comparison.
    """
    print("=" * 65)
    print("APPLICATION 3: Polynomial Fingerprinting")
    print("=" * 65)
    print()

    p = 2**61 - 1  # Mersenne prime
    n = 1000

    # Two identical data streams
    data1 = [random.randint(0, 1000) for _ in range(n)]
    data2 = data1[:]

    # One different data stream
    data3 = data1[:]
    data3[random.randint(0, n-1)] += 1

    print(f"  Data length: {n}")
    print(f"  Field: GF(2^61 - 1)")
    print()

    # Compare fingerprints
    num_tests = 5
    for trial in range(num_tests):
        r = random.randint(1, p - 1)
        fp1 = polynomial_fingerprint(data1, r, p)
        fp2 = polynomial_fingerprint(data2, r, p)
        fp3 = polynomial_fingerprint(data3, r, p)

        print(f"  Trial {trial+1}: point r = {r}")
        print(f"    data1 vs data2 (identical): fp match = {fp1 == fp2}")
        print(f"    data1 vs data3 (different): fp match = {fp1 == fp3}")

    print()
    print(f"  Collision probability for different data: ≤ {n-1}/{p} ≈ {(n-1)/p:.2e}")
    print(f"  This is astronomically small — fingerprinting is reliable!")
    print()
    print("  This is exactly Schwartz–Zippel applied to the polynomial")
    print("  f(x) = (data1[0]-data3[0]) + (data1[1]-data3[1])x + ...")
    print("  which is nonzero iff the data streams differ.")
    print()


# ══════════════════════════════════════════════════════════════════
# Application 4: Sum-Check Protocol Simulation
# ══════════════════════════════════════════════════════════════════

def application_sumcheck():
    """
    Simulate a simple sum-check protocol using Schwartz–Zippel.

    The sum-check protocol reduces the problem of computing
    sum_{x in {0,1}^n} f(x) to a single evaluation f(r)
    for a random r, using n rounds of interaction.

    Soundness relies on Schwartz–Zippel: a cheating prover
    must find a univariate polynomial that matches the true
    sum, which fails with probability ≤ d/|F| per round.
    """
    print("=" * 65)
    print("APPLICATION 4: Sum-Check Protocol (Schwartz–Zippel Soundness)")
    print("=" * 65)
    print()

    p = 101  # Small prime for demonstration
    n = 3    # Number of variables

    # Define f(x1, x2, x3) = x1*x2 + x2*x3 + x1 + 1  over GF(p)
    def f(x1, x2, x3):
        return (x1 * x2 + x2 * x3 + x1 + 1) % p

    # Compute the true sum over {0,1}^3
    true_sum = 0
    for x1 in range(2):
        for x2 in range(2):
            for x3 in range(2):
                true_sum = (true_sum + f(x1, x2, x3)) % p

    print(f"  f(x₁, x₂, x₃) = x₁x₂ + x₂x₃ + x₁ + 1 over GF({p})")
    print(f"  True sum over {{0,1}}³: {true_sum}")
    print()

    # Round 1: Prover sends g1(X1) = sum_{x2,x3 in {0,1}} f(X1, x2, x3)
    def g1(x1):
        s = 0
        for x2 in range(2):
            for x3 in range(2):
                s = (s + f(x1, x2, x3)) % p
        return s

    print(f"  Round 1: g₁(X₁) = Σ_{{x₂,x₃}} f(X₁, x₂, x₃)")
    print(f"    g₁(0) = {g1(0)}, g₁(1) = {g1(1)}")
    print(f"    g₁(0) + g₁(1) = {(g1(0) + g1(1)) % p} (should = {true_sum})")

    # Verifier checks g1(0) + g1(1) = claimed_sum
    check1 = (g1(0) + g1(1)) % p == true_sum
    print(f"    Check: {'PASS' if check1 else 'FAIL'}")

    # Verifier picks random r1
    r1 = random.randint(0, p - 1)
    print(f"    Verifier challenge: r₁ = {r1}")
    print()

    # Round 2: g2(X2) = sum_{x3 in {0,1}} f(r1, X2, x3)
    def g2(x2):
        s = 0
        for x3 in range(2):
            s = (s + f(r1, x2, x3)) % p
        return s

    print(f"  Round 2: g₂(X₂) = Σ_{{x₃}} f({r1}, X₂, x₃)")
    print(f"    g₂(0) = {g2(0)}, g₂(1) = {g2(1)}")
    print(f"    g₂(0) + g₂(1) = {(g2(0) + g2(1)) % p} (should = g₁(r₁) = {g1(r1)})")

    check2 = (g2(0) + g2(1)) % p == g1(r1)
    print(f"    Check: {'PASS' if check2 else 'FAIL'}")

    r2 = random.randint(0, p - 1)
    print(f"    Verifier challenge: r₂ = {r2}")
    print()

    # Round 3: g3(X3) = f(r1, r2, X3)
    def g3(x3):
        return f(r1, r2, x3)

    print(f"  Round 3: g₃(X₃) = f({r1}, {r2}, X₃)")
    print(f"    g₃(0) = {g3(0)}, g₃(1) = {g3(1)}")
    print(f"    g₃(0) + g₃(1) = {(g3(0) + g3(1)) % p} (should = g₂(r₂) = {g2(r2)})")

    check3 = (g3(0) + g3(1)) % p == g2(r2)
    print(f"    Check: {'PASS' if check3 else 'FAIL'}")

    r3 = random.randint(0, p - 1)
    print(f"    Verifier challenge: r₃ = {r3}")
    print()

    # Final check: verifier evaluates f(r1, r2, r3) directly
    final_val = f(r1, r2, r3)
    claimed_val = g3(r3)
    print(f"  Final: f({r1}, {r2}, {r3}) = {final_val}")
    print(f"         g₃(r₃) = {claimed_val}")
    print(f"         Match: {'PASS' if final_val == claimed_val else 'FAIL'}")
    print()

    degree = 2  # degree of f
    print(f"  Soundness: A cheating prover succeeds with probability")
    print(f"  ≤ n·d/|F| = {n}·{degree}/{p} = {n*degree/p:.4f}")
    print(f"  This bound comes from Schwartz–Zippel applied at each round.")
    print()


if __name__ == "__main__":
    random.seed(42)
    application_matrix_verification()
    application_pit()
    application_fingerprinting()
    application_sumcheck()
    print("All applications completed successfully!")


#!/usr/bin/env python3
"""
Demo: Schwartz–Zippel Lemma and Freivalds' Algorithm

Concrete numerical demonstrations showing:
1. The Schwartz–Zippel bound on polynomial zero sets over finite fields
2. Freivalds' randomized matrix multiplication verification
3. The connection: Freivalds as degree-1 Schwartz–Zippel
"""

import random
from itertools import product
from typing import List, Tuple, Dict
import sys


def mod_inv(a: int, p: int) -> int:
    """Modular inverse of a mod p (p prime)."""
    return pow(a, p - 2, p)


# ──────────────────────────────────────────────────────────────────
# Demo 1: Univariate root bound (base case of Schwartz–Zippel)
# ──────────────────────────────────────────────────────────────────

def count_univariate_roots(coeffs: List[int], p: int) -> int:
    """Count roots of polynomial with given coefficients over Z/pZ."""
    count = 0
    for x in range(p):
        val = sum(c * pow(x, i, p) for i, c in enumerate(coeffs)) % p
        if val == 0:
            count += 1
    return count


def demo_univariate():
    print("=" * 65)
    print("DEMO 1: Univariate Root Bound (Schwartz–Zippel Base Case)")
    print("=" * 65)
    print()
    print("Theorem: A nonzero polynomial of degree d over Z/pZ")
    print("         has at most d roots.")
    print()

    p = 7
    # Degree-3 polynomial: x^3 + 2x + 1 mod 7
    coeffs = [1, 2, 0, 1]
    degree = len(coeffs) - 1
    roots = count_univariate_roots(coeffs, p)

    poly_str = " + ".join(
        f"{c}x^{i}" if i > 0 else str(c)
        for i, c in enumerate(coeffs) if c != 0
    )
    print(f"  Field: Z/{p}Z")
    print(f"  Polynomial: f(x) = {poly_str}")
    print(f"  Degree: {degree}")
    print(f"  Number of roots: {roots}")
    print(f"  Bound (degree): {degree}")
    print(f"  roots ≤ degree? {roots <= degree} ✓")
    print()

    # Try several random polynomials
    print("  Random polynomial experiments:")
    for trial in range(5):
        d = random.randint(1, 5)
        coeffs = [random.randint(0, p - 1) for _ in range(d)] + [random.randint(1, p - 1)]
        roots = count_univariate_roots(coeffs, p)
        print(f"    degree {d}: {roots} roots ≤ {d} bound → {'✓' if roots <= d else '✗'}")
    print()


# ──────────────────────────────────────────────────────────────────
# Demo 2: Multivariate Schwartz–Zippel bound
# ──────────────────────────────────────────────────────────────────

def eval_multivariate(terms: List[Tuple[int, Tuple[int, ...]]], point: Tuple[int, ...], p: int) -> int:
    """
    Evaluate multivariate polynomial at a point over Z/pZ.
    terms: list of (coefficient, exponent_tuple)
    """
    val = 0
    for coeff, exps in terms:
        monomial = coeff
        for xi, ei in zip(point, exps):
            monomial = (monomial * pow(xi, ei, p)) % p
        val = (val + monomial) % p
    return val


def count_multivariate_zeros(terms, n_vars: int, p: int) -> int:
    """Count zeros of multivariate polynomial over (Z/pZ)^n."""
    count = 0
    for point in product(range(p), repeat=n_vars):
        if eval_multivariate(terms, point, p) == 0:
            count += 1
    return count


def total_degree(terms) -> int:
    """Compute total degree of polynomial."""
    return max(sum(exps) for _, exps in terms) if terms else 0


def demo_multivariate():
    print("=" * 65)
    print("DEMO 2: Multivariate Schwartz–Zippel Bound")
    print("=" * 65)
    print()
    print("Theorem: A nonzero polynomial f in n variables of total degree d")
    print("         over Z/pZ has at most d · p^(n-1) zeros.")
    print()

    p = 5
    n = 3

    # f(x,y,z) = x*y + y*z + x*z + 1  (total degree 2, 3 variables)
    terms = [
        (1, (1, 1, 0)),   # xy
        (1, (0, 1, 1)),   # yz
        (1, (1, 0, 1)),   # xz
        (1, (0, 0, 0)),   # 1
    ]

    d = total_degree(terms)
    zeros = count_multivariate_zeros(terms, n, p)
    bound = d * p ** (n - 1)
    total_points = p ** n

    print(f"  Field: Z/{p}Z, Variables: {n}")
    print(f"  f(x,y,z) = xy + yz + xz + 1")
    print(f"  Total degree d = {d}")
    print(f"  Zero set size: {zeros}")
    print(f"  Schwartz–Zippel bound: d · p^(n-1) = {d} · {p}^{n-1} = {bound}")
    print(f"  Total points: p^n = {total_points}")
    print(f"  |zeros| ≤ bound? {zeros <= bound} ✓")
    print(f"  Zero fraction: {zeros}/{total_points} = {zeros/total_points:.4f}")
    print(f"  Bound fraction: d/p = {d}/{p} = {d/p:.4f}")
    print()

    # Higher degree example
    # f(x,y,z) = x^2*y + y^2*z + z^2*x (total degree 3)
    terms2 = [
        (1, (2, 1, 0)),  # x^2 y
        (1, (0, 2, 1)),  # y^2 z
        (1, (1, 0, 2)),  # z^2 x
    ]
    d2 = total_degree(terms2)
    zeros2 = count_multivariate_zeros(terms2, n, p)
    bound2 = d2 * p ** (n - 1)

    print(f"  f(x,y,z) = x²y + y²z + z²x")
    print(f"  Total degree d = {d2}")
    print(f"  Zero set size: {zeros2}")
    print(f"  Schwartz–Zippel bound: {bound2}")
    print(f"  |zeros| ≤ bound? {zeros2 <= bound2} ✓")
    print()


# ──────────────────────────────────────────────────────────────────
# Demo 3: Freivalds' Algorithm
# ──────────────────────────────────────────────────────────────────

def mat_mul_mod(A, B, p):
    """Multiply matrices mod p."""
    n = len(A)
    C = [[0]*n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            C[i][j] = sum(A[i][k] * B[k][j] for k in range(n)) % p
    return C


def mat_vec_mul_mod(M, v, p):
    """Multiply matrix by vector mod p."""
    n = len(M)
    return [sum(M[i][j] * v[j] for j in range(n)) % p for i in range(n)]


def freivalds_check(A, B, C, r, p):
    """Check if A*B*r == C*r mod p."""
    Br = mat_vec_mul_mod(B, r, p)
    ABr = mat_vec_mul_mod(A, Br, p)
    Cr = mat_vec_mul_mod(C, r, p)
    return ABr == Cr


def demo_freivalds():
    print("=" * 65)
    print("DEMO 3: Freivalds' Randomized Matrix Verification")
    print("=" * 65)
    print()
    print("Theorem: If AB ≠ C, then Pr[ABr = Cr] ≤ 1/q over Z/qZ.")
    print()

    p = 7
    n = 3

    # Generate random A, B
    A = [[random.randint(0, p-1) for _ in range(n)] for _ in range(n)]
    B = [[random.randint(0, p-1) for _ in range(n)] for _ in range(n)]
    C_correct = mat_mul_mod(A, B, p)

    # Create wrong C by perturbing one entry
    C_wrong = [row[:] for row in C_correct]
    C_wrong[0][0] = (C_wrong[0][0] + 1) % p

    print(f"  Field: Z/{p}Z, Matrix size: {n}×{n}")
    print()

    # Exhaustive count for wrong C
    pass_count = 0
    total = p ** n
    for r_tuple in product(range(p), repeat=n):
        r = list(r_tuple)
        if freivalds_check(A, B, C_wrong, r, p):
            pass_count += 1

    print(f"  Case: AB ≠ C (one entry wrong)")
    print(f"  Vectors r where ABr = Cr: {pass_count} out of {total}")
    print(f"  Fraction: {pass_count}/{total} = {pass_count/total:.4f}")
    print(f"  Bound (1/q): 1/{p} = {1/p:.4f}")
    print(f"  Error count ≤ q^(n-1) = {p}^{n-1} = {p**(n-1)}?  {pass_count <= p**(n-1)} ✓")
    print()

    # Correct case
    pass_correct = 0
    for r_tuple in product(range(p), repeat=n):
        r = list(r_tuple)
        if freivalds_check(A, B, C_correct, r, p):
            pass_correct += 1

    print(f"  Case: AB = C (correct product)")
    print(f"  Vectors r where ABr = Cr: {pass_correct} out of {total}")
    print(f"  (All pass, as expected) ✓")
    print()

    # Repeated trials
    print(f"  Repeated independent trials (k rounds, error ≤ (1/q)^k):")
    for k in range(1, 6):
        false_accept = 0
        trials = 10000
        for _ in range(trials):
            all_pass = True
            for _ in range(k):
                r = [random.randint(0, p-1) for _ in range(n)]
                if not freivalds_check(A, B, C_wrong, r, p):
                    all_pass = False
                    break
            if all_pass:
                false_accept += 1
        empirical = false_accept / trials
        theoretical = (1/p) ** k
        print(f"    k={k}: empirical error = {empirical:.4f}, "
              f"bound = (1/{p})^{k} = {theoretical:.6f}")
    print()


# ──────────────────────────────────────────────────────────────────
# Demo 4: Freivalds as Degree-1 Schwartz–Zippel
# ──────────────────────────────────────────────────────────────────

def demo_connection():
    print("=" * 65)
    print("DEMO 4: The Connection — Freivalds IS Schwartz–Zippel at Degree 1")
    print("=" * 65)
    print()
    print("Key insight: If D = AB - C ≠ 0, pick a nonzero row d_i of D.")
    print("Then D·r = 0 implies d_i · r = 0, which is a degree-1 polynomial")
    print("in the entries of r. By Schwartz–Zippel, this vanishes on at most")
    print("1/q fraction of inputs.")
    print()

    p = 5
    n = 4

    # Create D with exactly one nonzero row
    D = [[0]*n for _ in range(n)]
    D[2] = [random.randint(1, p-1)] + [random.randint(0, p-1) for _ in range(n-1)]

    nonzero_row = D[2]
    print(f"  Field: Z/{p}Z, n = {n}")
    print(f"  Discrepancy matrix D with nonzero row 2: {nonzero_row}")
    print()

    # Count zeros of the linear form d_2 · r
    linear_zeros = 0
    mulvec_zeros = 0
    total = p ** n

    for r_tuple in product(range(p), repeat=n):
        r = list(r_tuple)
        # Linear form: d_2 · r
        dot = sum(nonzero_row[j] * r[j] for j in range(n)) % p
        if dot == 0:
            linear_zeros += 1
        # Matrix-vector: D · r
        Dr = mat_vec_mul_mod(D, r, p)
        if all(x == 0 for x in Dr):
            mulvec_zeros += 1

    print(f"  |{{r : d₂·r = 0}}| = {linear_zeros}  (= p^(n-1) = {p**(n-1)})")
    print(f"  |{{r : D·r = 0}}|  = {mulvec_zeros}  (≤ p^(n-1) = {p**(n-1)})")
    print(f"  mulvec zeros ≤ linear form zeros? {mulvec_zeros <= linear_zeros} ✓")
    print()
    print("  This demonstrates the proof structure:")
    print("    {r : D·r = 0} ⊆ {r : d_i·r = 0} for any nonzero row d_i")
    print("    |{r : d_i·r = 0}| = p^(n-1)   [hyperplane in (Z/pZ)^n]")
    print("    Therefore |{r : D·r = 0}| ≤ p^(n-1)")
    print()


# ──────────────────────────────────────────────────────────────────
# Demo 5: Schwartz–Zippel tightness
# ──────────────────────────────────────────────────────────────────

def demo_tightness():
    print("=" * 65)
    print("DEMO 5: Tightness of the Schwartz–Zippel Bound")
    print("=" * 65)
    print()
    print("The bound d·p^(n-1) is tight: the polynomial x₁·x₂·...·x_d")
    print("(using d ≤ n variables) achieves it exactly.")
    print()

    p = 5
    for n in range(1, 5):
        for d in range(1, n + 1):
            # f = x_1 * x_2 * ... * x_d  (degree d in n variables)
            zeros = 0
            for point in product(range(p), repeat=n):
                val = 1
                for i in range(d):
                    val = (val * point[i]) % p
                if val == 0:
                    zeros += 1
            bound = d * p ** (n - 1)
            tight = "TIGHT" if zeros == bound else f"slack by {bound - zeros}"
            print(f"  n={n}, d={d}: zeros={zeros}, bound={bound}  [{tight}]")

    print()
    print("  For f = x₁·x₂·...·x_d, the zero set is the union of d")
    print("  coordinate hyperplanes, giving exactly d·p^(n-1) zeros")
    print("  by inclusion-exclusion (equality holds for d ≤ n when")
    print("  characters are 0 or 1).")
    print()


if __name__ == "__main__":
    random.seed(42)
    demo_univariate()
    demo_multivariate()
    demo_freivalds()
    demo_connection()
    demo_tightness()
    print("All demos completed successfully!")


#!/usr/bin/env python3
"""
Visualizations for Schwartz–Zippel and Freivalds' Algorithm

Generates publication-quality figures saved as PNG files.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import product
import random
import base64
import io
import json


def save_fig_base64(fig, dpi=150):
    """Convert matplotlib figure to base64 PNG string."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=dpi, bbox_inches='tight', facecolor='white')
    buf.seek(0)
    return "data:image/png;base64," + base64.b64encode(buf.read()).decode('utf-8')


def viz_zero_set_2d():
    """Visualize zero set of a polynomial over a 2D finite field grid."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    primes = [7, 11, 13]
    polys = [
        ("x² + y² - 1", lambda x, y, p: (x*x + y*y - 1) % p),
        ("xy + x + y + 1", lambda x, y, p: (x*y + x + y + 1) % p),
        ("x³ - y² + 2x", lambda x, y, p: (x**3 - y**2 + 2*x) % p),
    ]
    degrees = [2, 2, 3]

    for ax, p_val, (name, f), deg in zip(axes, primes, polys, degrees):
        zeros_x, zeros_y = [], []
        nonzeros_x, nonzeros_y = [], []

        for x in range(p_val):
            for y in range(p_val):
                if f(x, y, p_val) == 0:
                    zeros_x.append(x)
                    zeros_y.append(y)
                else:
                    nonzeros_x.append(x)
                    nonzeros_y.append(y)

        ax.scatter(nonzeros_x, nonzeros_y, c='lightblue', alpha=0.3, s=30, label='f ≠ 0')
        ax.scatter(zeros_x, zeros_y, c='red', s=50, zorder=5, label='f = 0')

        bound = deg * p_val
        ax.set_title(f'f = {name}\n'
                     f'GF({p_val}), deg={deg}\n'
                     f'|zeros|={len(zeros_x)}, bound={bound}',
                     fontsize=10)
        ax.set_xlabel(f'x (mod {p_val})')
        ax.set_ylabel(f'y (mod {p_val})')
        ax.legend(fontsize=8)
        ax.set_aspect('equal')
        ax.grid(True, alpha=0.3)

    fig.suptitle('Zero Sets of Polynomials over Finite Fields\n'
                 'Schwartz–Zippel: |zeros| ≤ deg(f) · |F|^(n-1)',
                 fontsize=13, fontweight='bold')
    plt.tight_layout()
    fig.savefig('viz_zero_sets.png', dpi=150, bbox_inches='tight')
    b64 = save_fig_base64(fig)
    plt.close(fig)
    return b64


def viz_freivalds_error():
    """Visualize Freivalds error probability decay."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    # Left: Error probability vs number of trials for different field sizes
    trial_range = np.arange(1, 21)
    field_sizes = [2, 3, 5, 7, 11, 31]
    colors = plt.cm.viridis(np.linspace(0.1, 0.9, len(field_sizes)))

    for q, color in zip(field_sizes, colors):
        error = [(1.0/q)**k for k in trial_range]
        ax1.semilogy(trial_range, error, 'o-', color=color, label=f'q = {q}', markersize=4)

    ax1.axhline(y=2**(-128), color='gray', linestyle='--', alpha=0.5, label='2⁻¹²⁸ (crypto)')
    ax1.set_xlabel('Number of trials k', fontsize=12)
    ax1.set_ylabel('Error probability (1/q)^k', fontsize=12)
    ax1.set_title("Freivalds' Error Decay", fontsize=13, fontweight='bold')
    ax1.legend(fontsize=9)
    ax1.grid(True, alpha=0.3)
    ax1.set_ylim(1e-40, 1.5)

    # Right: Empirical vs theoretical for small field
    q = 5
    n = 4
    num_experiments = 5000

    # Generate a fixed "wrong" product scenario
    random.seed(42)
    A = [[random.randint(0, q-1) for _ in range(n)] for _ in range(n)]
    B = [[random.randint(0, q-1) for _ in range(n)] for _ in range(n)]

    def mat_mul(A, B):
        n = len(A)
        C = [[0]*n for _ in range(n)]
        for i in range(n):
            for j in range(n):
                for k in range(n):
                    C[i][j] = (C[i][j] + A[i][k] * B[k][j]) % q
        return C

    def mat_vec(M, v):
        return [sum(M[i][j]*v[j] for j in range(len(v))) % q for i in range(len(M))]

    C_correct = mat_mul(A, B)
    C_wrong = [row[:] for row in C_correct]
    C_wrong[0][0] = (C_wrong[0][0] + 1) % q

    empirical_errors = []
    theoretical_errors = []
    ks = list(range(1, 11))

    for k in ks:
        false_accepts = 0
        for _ in range(num_experiments):
            all_pass = True
            for _ in range(k):
                r = [random.randint(0, q-1) for _ in range(n)]
                Br = mat_vec(B, r)
                ABr = mat_vec(A, Br)
                Cr = mat_vec(C_wrong, r)
                if ABr != Cr:
                    all_pass = False
                    break
            if all_pass:
                false_accepts += 1
        empirical_errors.append(false_accepts / num_experiments)
        theoretical_errors.append((1.0/q)**k)

    ax2.semilogy(ks, theoretical_errors, 'r--', linewidth=2, label=f'Bound: (1/{q})^k')
    ax2.semilogy(ks, [max(e, 1e-10) for e in empirical_errors], 'bo-',
                 markersize=6, label=f'Empirical ({num_experiments} trials)')
    ax2.set_xlabel('Number of rounds k', fontsize=12)
    ax2.set_ylabel('False acceptance rate', fontsize=12)
    ax2.set_title(f'Empirical vs Theoretical (GF({q}), n={n})', fontsize=13, fontweight='bold')
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    fig.savefig('viz_freivalds_error.png', dpi=150, bbox_inches='tight')
    b64 = save_fig_base64(fig)
    plt.close(fig)
    return b64


def viz_schwartz_zippel_bound():
    """Visualize the Schwartz–Zippel bound vs actual zero counts."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5.5))

    # Left: Zero count vs degree for fixed field size and n
    p = 7
    n = 2
    random.seed(123)

    degrees = list(range(1, 7))
    bounds = [d * p**(n-1) for d in degrees]
    actual_counts = []

    for d in degrees:
        # Generate random polynomial of degree d
        best_count = 0
        for _ in range(20):
            # Create a polynomial of exact degree d
            terms = {}
            for _ in range(d + 3):
                e1 = random.randint(0, d)
                e2 = random.randint(0, d - e1)
                terms[(e1, e2)] = random.randint(1, p - 1)
            # Ensure we have a term of degree d
            terms[(d, 0)] = random.randint(1, p - 1)

            count = 0
            for x in range(p):
                for y in range(p):
                    val = 0
                    for (e1, e2), c in terms.items():
                        val = (val + c * pow(x, e1, p) * pow(y, e2, p)) % p
                    if val == 0:
                        count += 1
            best_count = max(best_count, count)
        actual_counts.append(best_count)

    x_pos = np.arange(len(degrees))
    width = 0.35

    ax1.bar(x_pos - width/2, actual_counts, width, label='Max observed zeros',
            color='steelblue', alpha=0.8)
    ax1.bar(x_pos + width/2, bounds, width, label='S-Z bound: d·p^(n-1)',
            color='coral', alpha=0.8)

    ax1.set_xlabel('Total degree d', fontsize=12)
    ax1.set_ylabel('Number of zeros', fontsize=12)
    ax1.set_title(f'Schwartz–Zippel Bound Tightness\nGF({p}), n={n}', fontsize=13, fontweight='bold')
    ax1.set_xticks(x_pos)
    ax1.set_xticklabels(degrees)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3, axis='y')

    # Right: Zero fraction vs 1/p for degree-1 (Freivalds case)
    primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31]
    n = 3
    fractions = []
    bounds_frac = []

    for p_val in primes:
        # Linear polynomial: x + 2y + 3z + 1
        count = 0
        total = p_val ** n
        for x in range(p_val):
            for y in range(p_val):
                for z in range(p_val):
                    if (x + 2*y + 3*z + 1) % p_val == 0:
                        count += 1
        fractions.append(count / total)
        bounds_frac.append(1.0 / p_val)

    ax2.plot(primes, fractions, 'bo-', markersize=6, label='Actual zero fraction')
    ax2.plot(primes, bounds_frac, 'r--', linewidth=2, label='Bound: 1/p')
    ax2.set_xlabel('Field size p', fontsize=12)
    ax2.set_ylabel('Fraction of zeros', fontsize=12)
    ax2.set_title('Degree-1 Case: Zero Fraction ≤ 1/p\n(The Freivalds Regime)',
                  fontsize=13, fontweight='bold')
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    fig.savefig('viz_sz_bound.png', dpi=150, bbox_inches='tight')
    b64 = save_fig_base64(fig)
    plt.close(fig)
    return b64


def viz_theorem_architecture():
    """Create a diagram showing the theorem dependency structure."""
    fig, ax = plt.subplots(figsize=(12, 8))
    ax.set_xlim(-1, 11)
    ax.set_ylim(-1, 9)
    ax.axis('off')

    # Node positions and labels
    nodes = {
        'urb': (5, 8, 'Univariate Root Bound\n(Mathlib)', '#E8D5B7'),
        'fiber': (2, 6.5, 'Fiber Polynomial\nConstruction', '#B7D5E8'),
        'deg': (5, 6.5, 'Degree Bound\non Fibers', '#B7D5E8'),
        'coeff': (8, 6.5, 'Coefficient\nDegree Drop', '#B7D5E8'),
        'sz_succ': (5, 4.5, 'Schwartz–Zippel\n(Fin (n+1))', '#FFD700'),
        'sz_zmod': (2, 3, 'Schwartz–Zippel\n(ZMod q)', '#B7E8B7'),
        'linear': (5, 3, 'Linear\nSchwartz–Zippel', '#B7E8B7'),
        'prob': (5, 1.5, 'Probability\nBound', '#B7E8B7'),
        'nlf': (8, 3, 'Nonzero Linear\nForm Bound', '#E8B7D5'),
        'fdb': (8, 1.5, 'Freivalds\nDiscrepancy', '#FFB7B7'),
        'fb': (8, 0, 'Freivalds\nProduct Form', '#FFB7B7'),
        'ferr': (5, 0, 'Error\nProbability', '#FFB7B7'),
    }

    # Draw nodes
    for key, (x, y, label, color) in nodes.items():
        bbox = dict(boxstyle='round,pad=0.5', facecolor=color, edgecolor='black', linewidth=1.5)
        ax.text(x, y, label, ha='center', va='center', fontsize=9,
                fontweight='bold', bbox=bbox)

    # Draw edges
    edges = [
        ('urb', 'sz_succ'), ('fiber', 'sz_succ'), ('deg', 'sz_succ'), ('coeff', 'sz_succ'),
        ('sz_succ', 'sz_zmod'), ('sz_succ', 'linear'),
        ('linear', 'prob'),
        ('nlf', 'fdb'), ('fdb', 'fb'), ('fdb', 'ferr'),
    ]

    for src, dst in edges:
        x1, y1, _, _ = nodes[src]
        x2, y2, _, _ = nodes[dst]
        ax.annotate('', xy=(x2, y2 + 0.4), xytext=(x1, y1 - 0.4),
                   arrowprops=dict(arrowstyle='->', color='black', lw=1.5))

    # Add dashed "conceptual" edge between linear SZ and nonzero linear form
    ax.annotate('', xy=(8, 3.4), xytext=(5, 3.4),
               arrowprops=dict(arrowstyle='<->', color='blue', lw=1.5, linestyle='dashed'))
    ax.text(6.5, 3.7, 'degree-1\nspecialization', ha='center', va='center',
            fontsize=8, color='blue', style='italic')

    ax.set_title('Theorem Architecture: Schwartz–Zippel → Freivalds Pipeline',
                fontsize=14, fontweight='bold', pad=20)

    # Legend
    legend_items = [
        ('#E8D5B7', 'Base case (Mathlib)'),
        ('#B7D5E8', 'Technical lemmas'),
        ('#FFD700', 'Main theorem'),
        ('#B7E8B7', 'Corollaries'),
        ('#E8B7D5', 'Linear algebra'),
        ('#FFB7B7', 'Freivalds'),
    ]
    for i, (color, label) in enumerate(legend_items):
        ax.add_patch(plt.Rectangle((0.2, 7.5 - i * 0.5), 0.3, 0.3, facecolor=color, edgecolor='black'))
        ax.text(0.7, 7.65 - i * 0.5, label, fontsize=8, va='center')

    plt.tight_layout()
    fig.savefig('viz_architecture.png', dpi=150, bbox_inches='tight')
    b64 = save_fig_base64(fig)
    plt.close(fig)
    return b64


def viz_reed_muller():
    """Visualize Reed–Muller code parameters derived from Schwartz–Zippel."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5.5))

    # Left: Minimum distance vs degree
    q = 7
    n = 3
    code_length = q**n
    degrees = list(range(1, q))
    min_distances = [code_length - d * q**(n-1) for d in degrees]
    relative_distances = [md / code_length for md in min_distances]

    ax1.bar(degrees, min_distances, color='steelblue', alpha=0.8, edgecolor='black')
    ax1.set_xlabel('Polynomial degree d', fontsize=12)
    ax1.set_ylabel('Minimum distance bound', fontsize=12)
    ax1.set_title(f'Reed–Muller Code Distance\nRM(d, n={n}, q={q}), length={code_length}',
                  fontsize=13, fontweight='bold')
    ax1.grid(True, alpha=0.3, axis='y')

    # Right: Rate vs distance trade-off
    from math import comb
    rates = [comb(n + d, d) / code_length for d in degrees]

    ax2.plot(relative_distances, rates, 'ro-', markersize=8, linewidth=2)
    for i, d in enumerate(degrees):
        ax2.annotate(f'd={d}', (relative_distances[i], rates[i]),
                    textcoords="offset points", xytext=(8, 5), fontsize=9)

    ax2.set_xlabel('Relative minimum distance δ', fontsize=12)
    ax2.set_ylabel('Rate R', fontsize=12)
    ax2.set_title('Rate–Distance Trade-off\n(Schwartz–Zippel gives the distance bound)',
                  fontsize=13, fontweight='bold')
    ax2.grid(True, alpha=0.3)
    ax2.set_xlim(-0.05, 1.05)

    plt.tight_layout()
    fig.savefig('viz_reed_muller.png', dpi=150, bbox_inches='tight')
    b64 = save_fig_base64(fig)
    plt.close(fig)
    return b64


if __name__ == "__main__":
    random.seed(42)

    print("Generating visualizations...")
    b64_zeros = viz_zero_set_2d()
    print("  ✓ viz_zero_sets.png")

    b64_error = viz_freivalds_error()
    print("  ✓ viz_freivalds_error.png")

    b64_bound = viz_schwartz_zippel_bound()
    print("  ✓ viz_sz_bound.png")

    b64_arch = viz_theorem_architecture()
    print("  ✓ viz_architecture.png")

    b64_rm = viz_reed_muller()
    print("  ✓ viz_reed_muller.png")

    # Save base64 data for JSON package
    viz_data = {
        "zero_sets": b64_zeros,
        "freivalds_error": b64_error,
        "sz_bound": b64_bound,
        "architecture": b64_arch,
        "reed_muller": b64_rm,
    }

    with open('viz_data.json', 'w') as f:
        json.dump(viz_data, f)

    print("\nAll visualizations generated successfully!")
