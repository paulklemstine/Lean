#!/usr/bin/env python3
"""
Real-World Applications of Low-Degree Testing over Finite Grids.

Demonstrates how the Grid Schwartz-Zippel theorem enables:
1. Polynomial Identity Testing (PIT)
2. Reed-Muller Error-Correcting Codes
3. Sum-Check Protocol Simulation
4. Secret Sharing via Polynomial Evaluation

All computations over Z/pZ for a prime p.
"""

import random
import itertools
from typing import List, Tuple, Dict


# =============================================================================
# Application 1: Polynomial Identity Testing (PIT)
# =============================================================================

def polynomial_identity_test():
    """
    Demonstrate Schwartz-Zippel based polynomial identity testing.
    
    Problem: Given two polynomials (possibly in different representations),
    determine if they are identical without expanding them.
    
    The Schwartz-Zippel lemma guarantees: if p ≠ q and deg(p-q) ≤ d,
    then evaluating at a random point in S^n detects the difference
    with probability ≥ 1 - d/|S|.
    """
    print("=" * 70)
    print("APPLICATION 1: Polynomial Identity Testing")
    print("=" * 70)
    print()
    
    prime = 97  # Large prime for low error probability
    
    # Test: Is (x+y)^2 = x^2 + 2xy + y^2?
    print("Test: Is (x+y)² = x² + 2xy + y²?")
    
    def poly_left(x, y):
        return ((x + y) ** 2) % prime
    
    def poly_right(x, y):
        return (x**2 + 2*x*y + y**2) % prime
    
    num_tests = 50
    all_equal = True
    for _ in range(num_tests):
        x = random.randint(0, prime - 1)
        y = random.randint(0, prime - 1)
        if poly_left(x, y) != poly_right(x, y):
            all_equal = False
            break
    
    print(f"  Result after {num_tests} random tests: "
          f"{'IDENTICAL ✓' if all_equal else 'DIFFERENT ✗'}")
    print(f"  Error probability ≤ d/|S| = 2/{prime} ≈ {2/prime:.4f}")
    print()
    
    # Test: Is (x+y)(x-y) = x^2 - y^2? (True identity)
    print("Test: Is (x+y)(x-y) = x² - y²?")
    
    def poly_left2(x, y):
        return ((x + y) * (x - y)) % prime
    
    def poly_right2(x, y):
        return (x**2 - y**2) % prime
    
    all_equal2 = True
    for _ in range(num_tests):
        x = random.randint(0, prime - 1)
        y = random.randint(0, prime - 1)
        if poly_left2(x, y) != poly_right2(x, y):
            all_equal2 = False
            break
    
    print(f"  Result after {num_tests} random tests: "
          f"{'IDENTICAL ✓' if all_equal2 else 'DIFFERENT ✗'}")
    print()
    
    # Test: Is x^3 + y^3 = (x+y)^3? (False identity, unless char 3)
    print("Test: Is x³ + y³ = (x+y)³? (should be DIFFERENT)")
    
    def poly_left3(x, y):
        return (x**3 + y**3) % prime
    
    def poly_right3(x, y):
        return ((x + y) ** 3) % prime
    
    found_diff = False
    tests_needed = 0
    for i in range(num_tests):
        x = random.randint(0, prime - 1)
        y = random.randint(0, prime - 1)
        tests_needed = i + 1
        if poly_left3(x, y) != poly_right3(x, y):
            found_diff = True
            break
    
    print(f"  Result: {'DIFFERENT ✓' if found_diff else 'IDENTICAL ✗'} "
          f"(detected in {tests_needed} test{'s' if tests_needed > 1 else ''})")
    print()


# =============================================================================
# Application 2: Reed-Muller Error-Correcting Codes
# =============================================================================

def reed_muller_coding():
    """
    Demonstrate Reed-Muller encoding and error detection/correction.
    
    A Reed-Muller code RM(d, n, q) evaluates degree-≤d polynomials over
    F_q on the grid (F_q)^n. By Theorem C, distinct codewords differ in
    at least q^n - d*q^(n-1) = q^(n-1)(q-d) positions.
    """
    print("=" * 70)
    print("APPLICATION 2: Reed-Muller Error-Correcting Codes")
    print("=" * 70)
    print()
    
    prime = 5
    S = list(range(prime))
    n = 2
    
    print(f"Field: Z/{prime}Z, Variables: {n}")
    print(f"Grid size: {prime}^{n} = {prime**n}")
    print()
    
    # Enumerate all degree-≤d monomials
    for d in range(1, prime):
        grid_size = prime ** n
        min_dist = grid_size - d * prime ** (n - 1)
        rate = count_polys(prime, n, d) / (prime ** grid_size) if grid_size < 10 else "N/A"
        
        print(f"  RM(d={d}, n={n}, q={prime}): "
              f"block_length={grid_size}, min_distance={min_dist}, "
              f"relative_distance={min_dist/grid_size:.2f}")
    
    print()
    
    # Demonstrate encoding and error detection
    d = 1  # Linear code
    
    # Message polynomial: p(x,y) = 2x + 3y + 1
    def p(pt):
        return (2 * pt[0] + 3 * pt[1] + 1) % prime
    
    codeword = [p(pt) for pt in itertools.product(S, repeat=n)]
    print(f"Message polynomial: p(x,y) = 2x + 3y + 1")
    print(f"Codeword: {codeword}")
    
    # Introduce errors
    num_errors = 2
    corrupted = list(codeword)
    error_positions = random.sample(range(len(corrupted)), num_errors)
    for pos in error_positions:
        corrupted[pos] = (corrupted[pos] + random.randint(1, prime - 1)) % prime
    
    hamming_dist = sum(1 for a, b in zip(codeword, corrupted) if a != b)
    min_distance = prime ** n - d * prime ** (n - 1)
    
    print(f"Corrupted codeword ({num_errors} errors): {corrupted}")
    print(f"Hamming distance from true codeword: {hamming_dist}")
    print(f"Minimum distance of code: {min_distance}")
    print(f"Error detection capacity: {min_distance - 1} errors")
    print(f"Unique decoding radius: {(min_distance - 1) // 2} errors")
    print()


def count_polys(q, n, d):
    """Count the number of degree-≤d monomials in n variables."""
    from math import comb
    return comb(n + d, d)


# =============================================================================
# Application 3: Sum-Check Protocol Simulation
# =============================================================================

def sum_check_protocol():
    """
    Simulate a simplified sum-check protocol.
    
    The sum-check protocol lets a prover convince a verifier of the value
    of sum_{x in {0,1}^n} p(x) for a multivariate polynomial p, using
    only n rounds of interaction.
    
    The soundness of each round relies on the Schwartz-Zippel lemma:
    a cheating prover must match a degree-d polynomial at a random point,
    which happens with probability ≤ d/|S| by our theorem.
    """
    print("=" * 70)
    print("APPLICATION 3: Sum-Check Protocol")
    print("=" * 70)
    print()
    
    prime = 11
    n = 3
    S = list(range(prime))
    
    # Polynomial: p(x1, x2, x3) = x1*x2 + x2*x3 + x1 (mod 11)
    def p(x):
        return (x[0] * x[1] + x[1] * x[2] + x[0]) % prime
    
    # Compute the true sum over {0,1}^n
    binary_grid = list(itertools.product([0, 1], repeat=n))
    true_sum = sum(p(x) for x in binary_grid) % prime
    
    print(f"Polynomial: p(x₁,x₂,x₃) = x₁x₂ + x₂x₃ + x₁")
    print(f"Field: Z/{prime}Z")
    print(f"Sum over {{0,1}}³: {true_sum}")
    print()
    
    # Simulate the protocol
    print("Sum-Check Protocol Simulation:")
    print("-" * 50)
    
    claimed_sum = true_sum  # Honest prover
    remaining_vars = list(range(n))
    fixed_values = {}
    
    for round_num in range(n):
        var = remaining_vars[0]
        remaining_vars = remaining_vars[1:]
        
        # Prover sends a univariate polynomial g(x_var) = 
        # sum_{remaining vars in {0,1}} p(fixed..., x_var, remaining...)
        def g(t):
            total = 0
            for assignment in itertools.product([0, 1], repeat=len(remaining_vars)):
                point = [0] * n
                for v, val in fixed_values.items():
                    point[v] = val
                point[var] = t
                for i, v in enumerate(remaining_vars):
                    point[v] = assignment[i]
                total = (total + p(tuple(point))) % prime
            return total
        
        # Verifier checks: g(0) + g(1) should equal claimed_sum
        check = (g(0) + g(1)) % prime
        valid = (check == claimed_sum)
        
        # Verifier picks random challenge
        r = random.choice(S)
        
        print(f"  Round {round_num + 1}: "
              f"g({0})={g(0)}, g({1})={g(1)}, "
              f"g(0)+g(1)={check} {'==' if valid else '!='} {claimed_sum} "
              f"{'✓' if valid else '✗'}, "
              f"challenge r={r}")
        
        # Update for next round
        claimed_sum = g(r)
        fixed_values[var] = r
    
    # Final check: verify p at the fully specified point
    final_point = tuple(fixed_values.get(i, 0) for i in range(n))
    final_val = p(final_point)
    final_valid = (final_val == claimed_sum)
    
    print(f"  Final: p{final_point} = {final_val} "
          f"{'==' if final_valid else '!='} {claimed_sum} "
          f"{'✓' if final_valid else '✗'}")
    print()
    print(f"Soundness: cheating probability ≤ d/|S| per round = 2/{prime} ≈ "
          f"{2/prime:.3f}")
    print(f"Total soundness error ≤ {n} × {2/prime:.3f} = {n * 2/prime:.3f}")
    print()


# =============================================================================
# Application 4: Secret Sharing (Shamir-style)
# =============================================================================

def secret_sharing():
    """
    Demonstrate Shamir's secret sharing using polynomial evaluation,
    with the Reed-Muller distance theorem guaranteeing robustness.
    
    A secret is encoded as p(0,...,0) for a random degree-d polynomial p.
    Shares are evaluations at grid points. The minimum distance bound
    guarantees that no coalition of fewer than d+1 shares can reconstruct
    the secret.
    """
    print("=" * 70)
    print("APPLICATION 4: Polynomial Secret Sharing")
    print("=" * 70)
    print()
    
    prime = 13
    n = 1  # Univariate for simplicity
    d = 3  # Threshold: need d+1 = 4 shares to reconstruct
    secret = 7
    
    print(f"Secret: {secret}")
    print(f"Field: Z/{prime}Z")
    print(f"Threshold: {d + 1} shares needed")
    print()
    
    # Generate random polynomial with p(0) = secret
    coeffs = [secret] + [random.randint(0, prime - 1) for _ in range(d)]
    
    def p(x):
        result = 0
        for i, c in enumerate(coeffs):
            result = (result + c * pow(x, i, prime)) % prime
        return result
    
    # Generate shares
    num_shares = 8
    shares = [(i, p(i)) for i in range(1, num_shares + 1)]
    
    print("Shares distributed:")
    for x, y in shares:
        print(f"  Party {x}: share = {y}")
    print()
    
    # Reconstruct with d+1 shares
    reconstruction_shares = shares[:d + 1]
    
    # Lagrange interpolation at x=0
    xs = [s[0] for s in reconstruction_shares]
    ys = [s[1] for s in reconstruction_shares]
    
    reconstructed = 0
    for i in range(len(xs)):
        numer = ys[i]
        for j in range(len(xs)):
            if i != j:
                numer = (numer * (0 - xs[j]) * pow(xs[i] - xs[j], prime - 2, prime)) % prime
        reconstructed = (reconstructed + numer) % prime
    
    print(f"Reconstructed secret from shares "
          f"{[s[0] for s in reconstruction_shares]}: {reconstructed} "
          f"{'✓' if reconstructed == secret else '✗'}")
    
    # Show that fewer shares cannot reconstruct
    partial_shares = shares[:d]
    print(f"With only {d} shares {[s[0] for s in partial_shares]}: "
          f"any value is equally likely (information-theoretic security)")
    
    # Demonstrate by showing multiple polynomials consistent with partial shares
    print(f"  Multiple consistent secrets exist:")
    count = 0
    for test_secret in range(min(prime, 5)):
        # Check if there's a degree-d polynomial through partial shares with p(0) = test_secret
        # (Always yes, by interpolation - we have d points and d+1 coefficients)
        print(f"    Secret could be {test_secret} (equally likely)")
        count += 1
        if count >= 4:
            print(f"    ... ({prime - count} more possibilities)")
            break
    print()
    
    # Connection to Reed-Muller distance
    min_dist = prime - d
    print(f"Reed-Muller minimum distance: {min_dist}")
    print(f"This means: any two degree-{d} polynomials differ at ≥ {min_dist} "
          f"evaluation points")
    print(f"Implication: corrupting < {min_dist // 2} shares still allows "
          f"unique reconstruction")
    print()


if __name__ == "__main__":
    polynomial_identity_test()
    reed_muller_coding()
    sum_check_protocol()
    secret_sharing()


#!/usr/bin/env python3
"""
Demonstration of the Finite-Grid Low-Degree Testing Theorems.

This script provides concrete numerical examples illustrating:
1. The Grid Schwartz-Zippel bound (zero count on grids)
2. Uniqueness of low-degree explanations (Theorem A)
3. Reed-Muller code distance (Theorem C)
"""

import itertools
from collections import Counter


def eval_poly(coeffs, point, prime):
    """
    Evaluate a multivariate polynomial over Z/pZ at a point.
    
    coeffs: dict mapping tuples of exponents -> coefficient
    point: tuple of field element values
    prime: the prime modulus
    """
    result = 0
    for exponents, coeff in coeffs.items():
        term = coeff
        for i, e in enumerate(exponents):
            term = (term * pow(point[i], e, prime)) % prime
        result = (result + term) % prime
    return result


def total_degree(coeffs):
    """Return the total degree of a polynomial."""
    if not coeffs:
        return 0
    return max(sum(exp) for exp in coeffs.keys())


def grid_points(S, n):
    """Generate all points in S^n."""
    return list(itertools.product(S, repeat=n))


def count_zeros(coeffs, S, n, prime):
    """Count zeros of a polynomial on the grid S^n over Z/pZ."""
    pts = grid_points(S, n)
    return sum(1 for pt in pts if eval_poly(coeffs, pt, prime) == 0)


def count_agreements(coeffs1, coeffs2, S, n, prime):
    """Count points where two polynomials agree on the grid."""
    pts = grid_points(S, n)
    return sum(1 for pt in pts
               if eval_poly(coeffs1, pt, prime) == eval_poly(coeffs2, pt, prime))


def count_disagreements(coeffs1, coeffs2, S, n, prime):
    """Count points where two polynomials disagree on the grid."""
    pts = grid_points(S, n)
    return sum(1 for pt in pts
               if eval_poly(coeffs1, pt, prime) != eval_poly(coeffs2, pt, prime))


# =============================================================================
# Demo 1: Grid Schwartz-Zippel Bound
# =============================================================================
def demo_schwartz_zippel():
    print("=" * 70)
    print("DEMO 1: Grid Schwartz-Zippel Bound")
    print("=" * 70)
    print()
    print("Theorem: A nonzero polynomial of total degree d < |S| has at most")
    print("         d * |S|^(n-1) zeros on the grid S^n.")
    print()

    prime = 7  # Work over Z/7Z
    S = list(range(prime))  # S = {0, 1, 2, 3, 4, 5, 6}
    s_card = len(S)

    examples = [
        # (n, coeffs, description)
        (1, {(2,): 1}, "p(x) = x^2, n=1, d=2"),
        (1, {(3,): 1, (1,): 2}, "p(x) = x^3 + 2x, n=1, d=3"),
        (2, {(1, 0): 1, (0, 1): 6}, "p(x,y) = x - y, n=2, d=1"),
        (2, {(1, 1): 1}, "p(x,y) = xy, n=2, d=2"),
        (2, {(2, 0): 1, (0, 2): 1, (0, 0): 6},
         "p(x,y) = x^2 + y^2 - 1, n=2, d=2"),
        (3, {(1, 0, 0): 1, (0, 1, 0): 1, (0, 0, 1): 1},
         "p(x,y,z) = x + y + z, n=3, d=1"),
    ]

    print(f"Field: Z/{prime}Z,  S = {{0, 1, ..., {prime-1}}},  |S| = {s_card}")
    print()
    print(f"{'Polynomial':<35} {'n':>2} {'d':>2} {'Zeros':>6} {'Bound':>8}")
    print("-" * 60)

    for n, coeffs, desc in examples:
        d = total_degree(coeffs)
        zeros = count_zeros(coeffs, S, n, prime)
        bound = d * s_card ** (n - 1)
        status = "✓" if zeros <= bound else "✗"
        print(f"{desc:<35} {n:>2} {d:>2} {zeros:>6} {bound:>8}  {status}")

    print()
    print("All bounds hold, as guaranteed by the Grid Schwartz-Zippel theorem.")
    print()


# =============================================================================
# Demo 2: Uniqueness from Large Agreement (Theorem A)
# =============================================================================
def demo_uniqueness():
    print("=" * 70)
    print("DEMO 2: Uniqueness from Large Agreement (Theorem A)")
    print("=" * 70)
    print()
    print("Theorem: If two polynomials of degree ≤ d < |S| agree on more than")
    print("         d * |S|^(n-1) grid points, they agree EVERYWHERE on the grid.")
    print()

    prime = 5
    S = list(range(prime))
    s_card = len(S)
    n = 2
    d = 2
    threshold = d * s_card ** (n - 1)  # 2 * 5 = 10

    # p(x,y) = x^2 + y
    p = {(2, 0): 1, (0, 1): 1}
    # q(x,y) = x^2 + y (same polynomial, different representation check)
    q = {(2, 0): 1, (0, 1): 1, (0, 0): 0}

    agreements = count_agreements(p, q, S, n, prime)
    grid_size = s_card ** n

    print(f"Field: Z/{prime}Z, S = {{0,...,{prime-1}}}, n={n}, d={d}")
    print(f"Grid size: |S|^n = {grid_size}")
    print(f"Threshold: d * |S|^(n-1) = {threshold}")
    print()
    print(f"p(x,y) = x² + y")
    print(f"q(x,y) = x² + y")
    print(f"Agreement count: {agreements} > {threshold} → polynomials agree everywhere ✓")
    print()

    # Now show two DIFFERENT polynomials
    p2 = {(2, 0): 1, (0, 1): 1}  # x^2 + y
    q2 = {(2, 0): 1, (0, 1): 1, (0, 0): 1}  # x^2 + y + 1

    agreements2 = count_agreements(p2, q2, S, n, prime)
    print(f"p(x,y) = x² + y")
    print(f"q(x,y) = x² + y + 1")
    print(f"Agreement count: {agreements2} ≤ {threshold} → polynomials CAN differ ✓")
    print(f"(They disagree at {grid_size - agreements2} points)")
    print()


# =============================================================================
# Demo 3: Reed-Muller Code Distance (Theorem C)
# =============================================================================
def demo_code_distance():
    print("=" * 70)
    print("DEMO 3: Reed-Muller Code Distance (Theorem C)")
    print("=" * 70)
    print()
    print("Theorem: Distinct polynomials of degree ≤ d < |S| disagree on at least")
    print("         |S|^n - d * |S|^(n-1) grid points.")
    print()

    prime = 7
    S = list(range(prime))
    s_card = len(S)

    experiments = [
        (1, 1, {(1,): 1}, {(1,): 2}, "x vs 2x"),
        (1, 2, {(2,): 1}, {(2,): 1, (0,): 1}, "x² vs x²+1"),
        (2, 1, {(1, 0): 1}, {(0, 1): 1}, "x vs y"),
        (2, 2, {(1, 1): 1}, {(2, 0): 1}, "xy vs x²"),
        (2, 1, {(1, 0): 1, (0, 1): 1}, {(1, 0): 2, (0, 1): 3},
         "x+y vs 2x+3y"),
    ]

    print(f"Field: Z/{prime}Z, |S| = {s_card}")
    print()
    print(f"{'Polynomials':<20} {'n':>2} {'d':>2} {'Disagree':>9} "
          f"{'Min dist':>9} {'Verified':>9}")
    print("-" * 60)

    for n, d, p, q, desc in experiments:
        disagreements = count_disagreements(p, q, S, n, prime)
        min_distance = s_card ** n - d * s_card ** (n - 1)
        verified = "✓" if disagreements >= min_distance else "✗"
        print(f"{desc:<20} {n:>2} {d:>2} {disagreements:>9} "
              f"{min_distance:>9} {verified:>9}")

    print()
    print("All distance lower bounds hold, confirming the Reed-Muller distance theorem.")
    print()


# =============================================================================
# Demo 4: Unique Decoding Illustration
# =============================================================================
def demo_unique_decoding():
    print("=" * 70)
    print("DEMO 4: Unique Decoding via Theorem B (Corrected)")
    print("=" * 70)
    print()
    print("Theorem: If two degree-≤d polynomials have combined agreement with")
    print("         a function f exceeding |S|^n + d*|S|^(n-1), they must agree")
    print("         on all grid points.")
    print()

    prime = 5
    S = list(range(prime))
    s_card = len(S)
    n = 2
    d = 1
    grid_size = s_card ** n
    threshold_combined = grid_size + d * s_card ** (n - 1)

    # True polynomial: p(x,y) = x + y (mod 5)
    p_true = {(1, 0): 1, (0, 1): 1}

    # Noisy function: agrees with p on most points
    pts = grid_points(S, n)
    noisy_f = {}
    corrupted = 0
    for pt in pts:
        val = eval_poly(p_true, pt, prime)
        # Corrupt a few points
        if pt in [(0, 0), (1, 1)]:
            noisy_f[pt] = (val + 1) % prime
            corrupted += 1
        else:
            noisy_f[pt] = val

    # Candidate 1: p(x,y) = x + y (the true one)
    p1 = {(1, 0): 1, (0, 1): 1}
    # Candidate 2: q(x,y) = x + y + 1 (wrong)
    p2 = {(1, 0): 1, (0, 1): 1, (0, 0): 1}

    agree_p1 = sum(1 for pt in pts
                   if eval_poly(p1, pt, prime) == noisy_f[pt])
    agree_p2 = sum(1 for pt in pts
                   if eval_poly(p2, pt, prime) == noisy_f[pt])

    combined = agree_p1 + agree_p2

    print(f"Field: Z/{prime}Z, n={n}, d={d}, grid size={grid_size}")
    print(f"True polynomial: p(x,y) = x + y")
    print(f"Corrupted {corrupted} out of {grid_size} grid points")
    print()
    print(f"Candidate p₁(x,y) = x + y:     agrees with f on {agree_p1} points")
    print(f"Candidate p₂(x,y) = x + y + 1: agrees with f on {agree_p2} points")
    print(f"Combined agreement: {combined}")
    print(f"Threshold (|S|^n + d*|S|^(n-1)): {threshold_combined}")
    print()

    if combined > threshold_combined:
        print(f"Combined > threshold → p₁ = p₂ on grid (unique decoding) ✓")
    else:
        print(f"Combined ≤ threshold → cannot conclude uniqueness")
        print(f"Indeed, p₁ and p₂ disagree at "
              f"{count_disagreements(p1, p2, S, n, prime)} points")
    print()


if __name__ == "__main__":
    demo_schwartz_zippel()
    demo_uniqueness()
    demo_code_distance()
    demo_unique_decoding()


#!/usr/bin/env python3
"""
Visualizations for Low-Degree Testing over Finite Grids.

Generates plots showing:
1. Zero sets of polynomials on grids
2. Reed-Muller code distance as a function of degree
3. Agreement regions and uniqueness thresholds
"""

import itertools
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def viz_zero_set():
    """Visualize zero sets of polynomials on a finite grid."""
    prime = 7
    S = list(range(prime))
    
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    polynomials = [
        (lambda x, y: (x - y) % prime, "p(x,y) = x − y\nd = 1, bound = 7"),
        (lambda x, y: (x**2 + y**2 - 1) % prime,
         "p(x,y) = x² + y² − 1\nd = 2, bound = 14"),
        (lambda x, y: (x * y) % prime, "p(x,y) = xy\nd = 2, bound = 14"),
    ]
    
    for ax, (poly, title) in zip(axes, polynomials):
        zeros_x, zeros_y = [], []
        nonzeros_x, nonzeros_y = [], []
        
        for x in S:
            for y in S:
                if poly(x, y) == 0:
                    zeros_x.append(x)
                    zeros_y.append(y)
                else:
                    nonzeros_x.append(x)
                    nonzeros_y.append(y)
        
        ax.scatter(nonzeros_x, nonzeros_y, c='lightblue', s=60, alpha=0.5,
                   edgecolors='steelblue', linewidth=0.5, label='Nonzero')
        ax.scatter(zeros_x, zeros_y, c='red', s=100, marker='x',
                   linewidth=2, label=f'Zeros ({len(zeros_x)})')
        
        ax.set_xlim(-0.5, prime - 0.5)
        ax.set_ylim(-0.5, prime - 0.5)
        ax.set_xlabel('x')
        ax.set_ylabel('y')
        ax.set_title(title, fontsize=11)
        ax.legend(fontsize=9)
        ax.set_aspect('equal')
        ax.grid(True, alpha=0.3)
    
    fig.suptitle(f'Zero Sets on the Grid (Z/{prime}Z)²',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('viz_zero_sets.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: viz_zero_sets.png")


def viz_code_distance():
    """Plot Reed-Muller minimum distance as a function of degree."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    
    # Left: absolute distance for various q
    for q in [3, 5, 7, 11]:
        n = 2
        degrees = list(range(1, q))
        distances = [q**n - d * q**(n-1) for d in degrees]
        ax1.plot(degrees, distances, 'o-', label=f'q = {q}', linewidth=2,
                 markersize=6)
    
    ax1.set_xlabel('Polynomial degree d', fontsize=12)
    ax1.set_ylabel('Minimum distance', fontsize=12)
    ax1.set_title('Reed-Muller Minimum Distance\n(n = 2 variables)', fontsize=13)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    
    # Right: relative distance = (q-d)/q for various n
    q = 7
    for n_val in [1, 2, 3, 4]:
        degrees = list(range(1, q))
        rel_distances = [(q**n_val - d * q**(n_val-1)) / q**n_val
                         for d in degrees]
        ax2.plot(degrees, rel_distances, 's-', label=f'n = {n_val}',
                 linewidth=2, markersize=6)
    
    ax2.set_xlabel('Polynomial degree d', fontsize=12)
    ax2.set_ylabel('Relative distance (1 − d/q)', fontsize=12)
    ax2.set_title(f'Relative Distance of RM Codes\n(q = {q})', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    ax2.set_ylim(0, 1)
    
    plt.tight_layout()
    plt.savefig('viz_code_distance.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: viz_code_distance.png")


def viz_agreement_threshold():
    """Visualize the agreement threshold for uniqueness."""
    prime = 7
    n = 2
    grid_size = prime ** n
    
    fig, ax = plt.subplots(figsize=(10, 7))
    
    degrees = list(range(1, prime))
    
    sz_bounds = [d * prime**(n-1) for d in degrees]
    min_distances = [grid_size - b for b in sz_bounds]
    
    x = np.arange(len(degrees))
    width = 0.35
    
    bars1 = ax.bar(x - width/2, sz_bounds, width, label='Max zeros (SZ bound)',
                   color='salmon', edgecolor='darkred', alpha=0.8)
    bars2 = ax.bar(x + width/2, min_distances, width,
                   label='Min disagreements',
                   color='steelblue', edgecolor='navy', alpha=0.8)
    
    ax.axhline(y=grid_size, color='gray', linestyle='--', linewidth=1,
               label=f'Grid size = {grid_size}')
    
    ax.set_xlabel('Polynomial degree d', fontsize=12)
    ax.set_ylabel('Number of grid points', fontsize=12)
    ax.set_title(f'Schwartz-Zippel Bound vs. Reed-Muller Distance\n'
                 f'Grid: (Z/{prime}Z)², |S|^n = {grid_size}', fontsize=13)
    ax.set_xticks(x)
    ax.set_xticklabels(degrees)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3, axis='y')
    
    # Annotate
    for i, (b, d_val) in enumerate(zip(sz_bounds, min_distances)):
        ax.text(i - width/2, b + 0.5, str(b), ha='center', va='bottom',
                fontsize=9, color='darkred')
        ax.text(i + width/2, d_val + 0.5, str(d_val), ha='center', va='bottom',
                fontsize=9, color='navy')
    
    plt.tight_layout()
    plt.savefig('viz_agreement_threshold.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: viz_agreement_threshold.png")


def viz_uniqueness_region():
    """Show the decoding regions for Reed-Muller codes."""
    fig, ax = plt.subplots(figsize=(10, 6))
    
    prime = 11
    n = 2
    grid_size = prime ** n  # 121
    
    degrees = list(range(1, prime))
    
    unique_decode_radii = []
    error_detect_radii = []
    for d in degrees:
        min_dist = grid_size - d * prime**(n-1)
        unique_decode_radii.append((min_dist - 1) // 2)
        error_detect_radii.append(min_dist - 1)
    
    ax.fill_between(degrees, 0, unique_decode_radii, alpha=0.3,
                     color='green', label='Unique decoding region')
    ax.fill_between(degrees, unique_decode_radii, error_detect_radii, alpha=0.3,
                     color='orange', label='Error detection only')
    ax.fill_between(degrees, error_detect_radii, grid_size, alpha=0.2,
                     color='red', label='Unrecoverable')
    
    ax.plot(degrees, unique_decode_radii, 'go-', linewidth=2, markersize=6,
            label=f'Unique decode radius ⌊(D-1)/2⌋')
    ax.plot(degrees, error_detect_radii, 'rs-', linewidth=2, markersize=6,
            label=f'Detection capacity D-1')
    
    ax.set_xlabel('Polynomial degree d', fontsize=12)
    ax.set_ylabel('Number of correctable/detectable errors', fontsize=12)
    ax.set_title(f'Reed-Muller Error Correction Capacity\n'
                 f'Grid: (Z/{prime}Z)², block length = {grid_size}', fontsize=13)
    ax.legend(fontsize=10, loc='upper right')
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('viz_uniqueness_region.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: viz_uniqueness_region.png")


if __name__ == "__main__":
    viz_zero_set()
    viz_code_distance()
    viz_agreement_threshold()
    viz_uniqueness_region()
    print("\nAll visualizations generated!")
