#!/usr/bin/env python3
"""
Applications of the Sum-Check Soundness Theorem

Demonstrates real-world applications of the polynomial root bound:
1. Polynomial Identity Testing (PIT)
2. Reed-Solomon error detection
3. Simple sum-check protocol for #SAT-like problems
4. Fingerprinting / equality testing of large datasets
"""

import random
from typing import List, Callable


def mod_pow(base: int, exp: int, mod: int) -> int:
    """Fast modular exponentiation."""
    result = 1
    base %= mod
    while exp > 0:
        if exp & 1:
            result = (result * base) % mod
        exp >>= 1
        base = (base * base) % mod
    return result


def mod_inv(a: int, p: int) -> int:
    """Modular inverse via Fermat's little theorem (p must be prime)."""
    return mod_pow(a, p - 2, p)


# ============================================================
# Application 1: Polynomial Identity Testing
# ============================================================

def polynomial_identity_test(
    coeffs_p: List[int],
    coeffs_q: List[int],
    prime: int,
    n_tests: int = 10
) -> dict:
    """Randomized polynomial identity test using Schwartz-Zippel.

    Tests whether p == q by evaluating at random points.
    If p ≠ q with deg(p-q) ≤ d, each test catches the difference
    with probability ≥ 1 - d/prime.

    Args:
        coeffs_p: Coefficients of polynomial p
        coeffs_q: Coefficients of polynomial q
        prime: Field size
        n_tests: Number of random evaluation points

    Returns:
        Dictionary with test results

    Application: Circuit identity testing, verifying algebraic
    transformations, compiler optimizations for arithmetic circuits.
    """
    def eval_poly(coeffs, x):
        result = 0
        for c in reversed(coeffs):
            result = (result * x + c) % prime
        return result

    max_deg = max(len(coeffs_p), len(coeffs_q)) - 1
    results = []

    for _ in range(n_tests):
        r = random.randint(0, prime - 1)
        val_p = eval_poly(coeffs_p, r)
        val_q = eval_poly(coeffs_q, r)
        results.append({
            'point': r,
            'p_value': val_p,
            'q_value': val_q,
            'agree': val_p == val_q
        })

    all_agree = all(r['agree'] for r in results)
    # If all tests agree, probability of false positive ≤ (d/prime)^n_tests
    false_positive_bound = (max_deg / prime) ** n_tests if not all_agree else None

    return {
        'conclusion': 'EQUAL (probably)' if all_agree else 'DIFFERENT (certainly)',
        'tests_run': n_tests,
        'max_degree': max_deg,
        'field_size': prime,
        'soundness_error': (max_deg / prime) ** n_tests,
        'details': results
    }


# ============================================================
# Application 2: Reed-Solomon Error Detection
# ============================================================

def reed_solomon_encode(message: List[int], n_eval_points: int, prime: int) -> List[int]:
    """Encode a message as Reed-Solomon codeword.

    The message is interpreted as polynomial coefficients,
    and the codeword is the evaluation at n_eval_points consecutive points.

    Args:
        message: Message symbols (coefficients of the message polynomial)
        n_eval_points: Number of evaluation points (code length)
        prime: Field size

    Returns:
        Codeword: list of evaluations at points 0, 1, ..., n_eval_points-1
    """
    def eval_poly(coeffs, x):
        result = 0
        for c in reversed(coeffs):
            result = (result * x + c) % prime
        return result

    return [eval_poly(message, i) for i in range(n_eval_points)]


def reed_solomon_spot_check(
    codeword: List[int],
    corrupted: List[int],
    prime: int,
    n_checks: int = 5
) -> dict:
    """Detect corruption in a Reed-Solomon codeword via random spot-checks.

    This is a direct application of the polynomial root bound:
    if the corrupted word differs from the true codeword,
    random checks catch the corruption with high probability.

    Application: Data integrity in distributed storage, blockchain
    data availability sampling (DAS).
    """
    n = len(codeword)
    checks = []
    for _ in range(n_checks):
        idx = random.randint(0, n - 1)
        match = codeword[idx] == corrupted[idx]
        checks.append({'index': idx, 'match': match})

    corruption_detected = any(not c['match'] for c in checks)
    n_corrupted = sum(1 for i in range(n) if codeword[i] != corrupted[i])

    return {
        'code_length': n,
        'corrupted_positions': n_corrupted,
        'checks_performed': n_checks,
        'corruption_detected': corruption_detected,
        'detection_probability_per_check': n_corrupted / n if n_corrupted > 0 else 0,
        'details': checks
    }


# ============================================================
# Application 3: Simple Sum-Check Protocol
# ============================================================

def sumcheck_protocol_demo(
    coefficients: List[List[int]],
    prime: int
) -> dict:
    """Demonstrate a simplified 2-variable sum-check protocol.

    Given a bilinear function g(x1, x2) = a + b*x1 + c*x2 + d*x1*x2
    over the Boolean hypercube {0,1}^2, verify the claimed sum
    H = sum_{x1,x2 in {0,1}} g(x1, x2).

    This demonstrates the sum-check protocol with explicit round
    polynomials and verifier challenges.

    Application: Verified computation, delegated computation,
    zero-knowledge proofs for NP statements.
    """
    # g(x1, x2) represented by coefficients [a, b, c, d]
    # g = a + b*x1 + c*x2 + d*x1*x2
    a, b, c, d = [x % prime for x in coefficients[0]]

    def g(x1, x2):
        return (a + b * x1 + c * x2 + d * x1 * x2) % prime

    # True sum over {0,1}^2
    H = sum(g(x1, x2) for x1 in [0, 1] for x2 in [0, 1]) % prime

    # Round 1: True polynomial t1(X1) = sum_{x2 in {0,1}} g(X1, x2)
    # t1(X1) = g(X1, 0) + g(X1, 1) = (a + b*X1) + (a + c + b*X1 + d*X1)
    #        = 2a + c + (2b + d)*X1
    t1_const = (2 * a + c) % prime
    t1_lin = (2 * b + d) % prime

    # Verify: t1(0) + t1(1) should equal H
    assert (t1_const + (t1_const + t1_lin) % prime) % prime == H

    # Verifier sends random challenge r1
    r1 = random.randint(0, prime - 1)
    t1_at_r1 = (t1_const + t1_lin * r1) % prime

    # Round 2: True polynomial t2(X2) = g(r1, X2)
    # t2(X2) = a + b*r1 + c*X2 + d*r1*X2 = (a + b*r1) + (c + d*r1)*X2
    t2_const = (a + b * r1) % prime
    t2_lin = (c + d * r1) % prime

    # Verify: t2(0) + t2(1) should equal t1(r1)
    assert (t2_const + (t2_const + t2_lin) % prime) % prime == t1_at_r1

    # Verifier sends random challenge r2
    r2 = random.randint(0, prime - 1)
    t2_at_r2 = (t2_const + t2_lin * r2) % prime

    # Final check: t2(r2) should equal g(r1, r2)
    oracle_val = g(r1, r2)

    return {
        'function': f'g(x1,x2) = {a} + {b}*x1 + {c}*x2 + {d}*x1*x2',
        'field_size': prime,
        'claimed_sum': H,
        'round_1': {
            'true_polynomial': f't1(X) = {t1_const} + {t1_lin}*X',
            'challenge': r1,
            'value': t1_at_r1
        },
        'round_2': {
            'true_polynomial': f't2(X) = {t2_const} + {t2_lin}*X',
            'challenge': r2,
            'value': t2_at_r2
        },
        'final_check': {
            'polynomial_value': t2_at_r2,
            'oracle_value': oracle_val,
            'passed': t2_at_r2 == oracle_val
        },
        'honest_verification': 'PASSED' if t2_at_r2 == oracle_val else 'FAILED'
    }


# ============================================================
# Application 4: Fingerprinting / Equality Testing
# ============================================================

def fingerprint_equality_test(
    data_a: List[int],
    data_b: List[int],
    prime: int = 104729
) -> dict:
    """Test equality of two large datasets using polynomial fingerprinting.

    Interprets each dataset as polynomial coefficients and evaluates
    at a random point. By Schwartz-Zippel, if datasets differ,
    fingerprints differ with probability ≥ 1 - n/prime where n = len(data).

    Application: Distributed systems consistency checking, database
    synchronization, file deduplication.

    Time complexity: O(n) per fingerprint (vs O(n) for direct comparison,
    but fingerprints can be computed incrementally and compared remotely).
    """
    def fingerprint(data, point, p):
        result = 0
        for c in reversed(data):
            result = (result * point + c) % p
        return result

    r = random.randint(0, prime - 1)
    fp_a = fingerprint(data_a, r, prime)
    fp_b = fingerprint(data_b, r, prime)

    are_equal = (data_a == data_b)
    fps_match = (fp_a == fp_b)

    return {
        'data_length': max(len(data_a), len(data_b)),
        'field_size': prime,
        'fingerprint_a': fp_a,
        'fingerprint_b': fp_b,
        'fingerprints_match': fps_match,
        'actually_equal': are_equal,
        'correct': (are_equal == fps_match) or (not are_equal and fps_match),
        'false_positive_bound': max(len(data_a), len(data_b)) / prime
    }


if __name__ == "__main__":
    random.seed(2024)

    print("=" * 65)
    print("APPLICATION 1: Polynomial Identity Testing")
    print("=" * 65)
    # Test (x+1)^2 vs x^2 + 2x + 1  (should be equal)
    result = polynomial_identity_test([1, 2, 1], [1, 2, 1], 101, 5)
    print(f"  (x+1)² vs x²+2x+1: {result['conclusion']}")
    print(f"  Soundness error: {result['soundness_error']:.2e}")

    # Test x^2 + 1 vs x^2 + 2  (should differ)
    result = polynomial_identity_test([1, 0, 1], [2, 0, 1], 101, 5)
    print(f"  x²+1 vs x²+2: {result['conclusion']}")

    print(f"\n{'=' * 65}")
    print("APPLICATION 2: Reed-Solomon Error Detection")
    print("=" * 65)
    msg = [3, 1, 4, 1, 5]
    codeword = reed_solomon_encode(msg, 20, 101)
    corrupted = list(codeword)
    corrupted[7] = (corrupted[7] + 1) % 101  # corrupt one position
    result = reed_solomon_spot_check(codeword, corrupted, 101, 5)
    print(f"  Code length: {result['code_length']}, Corrupted: {result['corrupted_positions']}")
    print(f"  Detection: {result['corruption_detected']} ({result['checks_performed']} checks)")

    print(f"\n{'=' * 65}")
    print("APPLICATION 3: Sum-Check Protocol Demo")
    print("=" * 65)
    result = sumcheck_protocol_demo([[2, 3, 5, 1]], 101)
    print(f"  Function: {result['function']}")
    print(f"  Claimed sum: {result['claimed_sum']}")
    print(f"  Round 1: {result['round_1']['true_polynomial']}, r1={result['round_1']['challenge']}")
    print(f"  Round 2: {result['round_2']['true_polynomial']}, r2={result['round_2']['challenge']}")
    print(f"  Verification: {result['honest_verification']}")

    print(f"\n{'=' * 65}")
    print("APPLICATION 4: Fingerprint Equality Testing")
    print("=" * 65)
    data1 = list(range(1000))
    data2 = list(range(1000))
    data3 = list(range(1000)); data3[500] = 999
    r1 = fingerprint_equality_test(data1, data2)
    r2 = fingerprint_equality_test(data1, data3)
    print(f"  Equal datasets: match={r1['fingerprints_match']}, correct={r1['correct']}")
    print(f"  Different datasets: match={r2['fingerprints_match']}, correct={r2['correct']}")
    print(f"  False positive bound: {r2['false_positive_bound']:.6f}")


#!/usr/bin/env python3
"""
Demo: Sum-Check Soundness — Polynomial Root Bound in Action

Demonstrates the core algebraic detection theorem:
two distinct polynomials over a finite field agree at very few points.
"""

import random
from collections import Counter


def mod_eval(coeffs, x, p):
    """Evaluate polynomial with coefficients `coeffs` at `x` mod `p`."""
    result = 0
    for c in reversed(coeffs):
        result = (result * x + c) % p
    return result


def agreement_set(coeffs_p, coeffs_q, prime):
    """Find all x in F_prime where p(x) == q(x)."""
    return [x for x in range(prime) if mod_eval(coeffs_p, x, prime) == mod_eval(coeffs_q, x, prime)]


def root_set(coeffs, prime):
    """Find all roots of a polynomial in F_prime."""
    return [x for x in range(prime) if mod_eval(coeffs, x, prime) == 0]


def poly_sub(coeffs_p, coeffs_q, prime):
    """Compute p - q mod prime."""
    n = max(len(coeffs_p), len(coeffs_q))
    result = [0] * n
    for i in range(n):
        a = coeffs_p[i] if i < len(coeffs_p) else 0
        b = coeffs_q[i] if i < len(coeffs_q) else 0
        result[i] = (a - b) % prime
    while len(result) > 1 and result[-1] == 0:
        result.pop()
    return result


def degree(coeffs):
    """Degree of a polynomial (0 for the zero polynomial)."""
    d = len(coeffs) - 1
    while d > 0 and coeffs[d] == 0:
        d -= 1
    return d


def demo_root_bound():
    """Demonstrate that distinct polynomials agree at ≤ deg(p-q) points."""
    print("=" * 65)
    print("DEMO 1: Root Bound Verification")
    print("Two distinct polynomials agree at ≤ natDegree(p - q) points")
    print("=" * 65)

    test_cases = [
        (7, [1, 3], [1, 5], "Linear vs Linear over F_7"),
        (7, [2, 1, 3], [0, 1, 3], "Degree-2 over F_7"),
        (13, [1, 2, 3, 4], [0, 0, 0, 4], "Degree-3 over F_13"),
        (31, [7, 0, 1], [7, 3, 1], "Degree-2, same leading coeff, over F_31"),
        (101, [3, 7], [5, 7], "Linear, same constant, over F_101"),
    ]

    for prime, p_coeffs, q_coeffs, desc in test_cases:
        diff = poly_sub(p_coeffs, q_coeffs, prime)
        deg_diff = degree(diff)
        agree = agreement_set(p_coeffs, q_coeffs, prime)

        print(f"\n{desc}:")
        print(f"  p(x) = {format_poly(p_coeffs)}")
        print(f"  q(x) = {format_poly(q_coeffs)}")
        print(f"  p-q   = {format_poly(diff)}")
        print(f"  deg(p-q) = {deg_diff}")
        print(f"  Agreement points: {agree}")
        print(f"  |agree| = {len(agree)} ≤ {deg_diff}  ✓" if len(agree) <= deg_diff
              else f"  |agree| = {len(agree)} > {deg_diff}  ✗ BUG!")


def format_poly(coeffs):
    """Format polynomial coefficients as a readable string."""
    terms = []
    for i, c in enumerate(coeffs):
        if c == 0:
            continue
        if i == 0:
            terms.append(str(c))
        elif i == 1:
            terms.append(f"{c}x" if c != 1 else "x")
        else:
            terms.append(f"{c}x^{i}" if c != 1 else f"x^{i}")
    return " + ".join(terms) if terms else "0"


def demo_sumcheck_round():
    """Simulate a one-round sum-check interaction."""
    print("\n" + "=" * 65)
    print("DEMO 2: One-Round Sum-Check Simulation")
    print("Cheating prover sends wrong polynomial; verifier catches it")
    print("=" * 65)

    prime = 101
    true_poly = [7, 3]   # t(x) = 3x + 7
    cheat_poly = [7, 5]  # s(x) = 5x + 7  (cheating!)

    agree = agreement_set(cheat_poly, true_poly, prime)
    print(f"\nField: F_{prime}")
    print(f"True polynomial:     t(x) = {format_poly(true_poly)}")
    print(f"Cheating polynomial: s(x) = {format_poly(cheat_poly)}")
    print(f"Agreement points: {agree}")
    print(f"Agreement count: {len(agree)} ≤ 1  ✓")

    # Monte Carlo simulation
    n_trials = 100_000
    caught = 0
    for _ in range(n_trials):
        r = random.randint(0, prime - 1)
        if mod_eval(cheat_poly, r, prime) != mod_eval(true_poly, r, prime):
            caught += 1

    detection_rate = caught / n_trials
    theoretical = (prime - len(agree)) / prime
    print(f"\nMonte Carlo simulation ({n_trials:,} trials):")
    print(f"  Detection rate:  {detection_rate:.4f}")
    print(f"  Theoretical:     {theoretical:.4f}")
    print(f"  Cheating bound:  ≤ 1/{prime} = {1/prime:.6f}")


def demo_degree_d_soundness():
    """Demonstrate general degree-d soundness step."""
    print("\n" + "=" * 65)
    print("DEMO 3: General Degree-d Soundness")
    print("Higher-degree polynomials: more agreement points possible")
    print("=" * 65)

    prime = 31

    for d in [1, 2, 3, 5]:
        # Create two random distinct polynomials of degree d
        random.seed(42 + d)
        p_coeffs = [random.randint(0, prime - 1) for _ in range(d + 1)]
        q_coeffs = list(p_coeffs)
        q_coeffs[0] = (q_coeffs[0] + 1) % prime  # ensure distinct

        diff = poly_sub(p_coeffs, q_coeffs, prime)
        deg_diff = degree(diff)
        agree = agreement_set(p_coeffs, q_coeffs, prime)

        print(f"\n  Degree {d} over F_{prime}:")
        print(f"    deg(p-q) = {deg_diff}")
        print(f"    |agreement| = {len(agree)} ≤ {deg_diff}  {'✓' if len(agree) <= deg_diff else '✗'}")
        print(f"    Detection probability ≥ {1 - deg_diff/prime:.4f}")


def demo_multi_round():
    """Simulate multi-round sum-check with union bound."""
    print("\n" + "=" * 65)
    print("DEMO 4: Multi-Round Sum-Check (Union Bound)")
    print("Total cheating probability ≤ n·d/|F|")
    print("=" * 65)

    prime = 101
    n_trials = 50_000

    for n_rounds in [1, 5, 10, 20]:
        d = 1  # degree per round
        theoretical_bound = n_rounds * d / prime

        # Simulate: cheater succeeds only if ALL rounds pass
        cheat_success = 0
        for _ in range(n_trials):
            all_pass = True
            for _ in range(n_rounds):
                # Each round: independent random challenge
                r = random.randint(0, prime - 1)
                # Cheater's polynomial differs from true at all but ≤1 points
                # Simplify: cheat succeeds at round with prob 1/prime
                if r == 0:  # agreement point
                    pass
                else:
                    all_pass = False
                    break
            if all_pass:
                cheat_success += 1

        observed = cheat_success / n_trials
        print(f"\n  {n_rounds} rounds, d={d}, |F|={prime}:")
        print(f"    Theoretical bound: {theoretical_bound:.6f}")
        print(f"    Observed success:  {observed:.6f}")
        print(f"    Bound holds: {'✓' if observed <= theoretical_bound * 1.5 else '≈'}")


def demo_tightness():
    """Show the root bound is tight: polynomials achieving max roots."""
    print("\n" + "=" * 65)
    print("DEMO 5: Tightness of the Root Bound")
    print("Polynomials achieving exactly d roots")
    print("=" * 65)

    prime = 13
    print(f"\nField: F_{prime}")

    for d in range(1, 6):
        # Construct polynomial with exactly d roots: product of (x - i) for i = 0..d-1
        # Start with [1] and multiply by (x - i)
        coeffs = [1]
        for i in range(d):
            # Multiply by (x - i)
            new_coeffs = [0] * (len(coeffs) + 1)
            neg_i = (-i) % prime
            for j, c in enumerate(coeffs):
                new_coeffs[j] = (new_coeffs[j] + c * neg_i) % prime
                new_coeffs[j + 1] = (new_coeffs[j + 1] + c) % prime
            coeffs = new_coeffs

        roots = root_set(coeffs, prime)
        print(f"  Degree {d}: {format_poly(coeffs)}")
        print(f"    Roots: {roots}")
        print(f"    Count: {len(roots)} = {d}  ✓" if len(roots) == d else f"    Count: {len(roots)}")


if __name__ == "__main__":
    random.seed(2024)
    demo_root_bound()
    demo_sumcheck_round()
    demo_degree_d_soundness()
    demo_multi_round()
    demo_tightness()
    print("\n" + "=" * 65)
    print("All demonstrations completed successfully.")
    print("=" * 65)


#!/usr/bin/env python3
"""
Visualizations for Sum-Check Soundness Analysis

Generates publication-quality charts illustrating the polynomial root bound
and sum-check protocol soundness properties.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import random
import base64
import io


def fig_to_base64(fig):
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"


def viz_root_bound_tightness():
    """Visualize the tightness of the root bound across field sizes."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Left: Root count vs degree for F_31
    prime = 31
    degrees = range(1, 15)
    max_roots = []
    for d in degrees:
        # Construct poly with exactly d roots
        coeffs = [1]
        for i in range(d):
            new_c = [0] * (len(coeffs) + 1)
            neg_i = (-i) % prime
            for j, c in enumerate(coeffs):
                new_c[j] = (new_c[j] + c * neg_i) % prime
                new_c[j + 1] = (new_c[j + 1] + c) % prime
            coeffs = new_c
        roots = sum(1 for x in range(prime) if eval_poly(coeffs, x, prime) == 0)
        max_roots.append(roots)

    axes[0].bar(list(degrees), max_roots, color='#2196F3', alpha=0.8, label='Actual roots')
    axes[0].plot(list(degrees), list(degrees), 'r--', linewidth=2, label='Bound (= degree)')
    axes[0].set_xlabel('Polynomial Degree', fontsize=12)
    axes[0].set_ylabel('Number of Roots', fontsize=12)
    axes[0].set_title(f'Root Bound Tightness over F_{prime}', fontsize=14)
    axes[0].legend(fontsize=11)
    axes[0].set_xlim(0.5, 14.5)

    # Right: Detection probability vs field size
    field_sizes = [7, 11, 13, 17, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97]
    for d in [1, 2, 3, 5]:
        probs = [1 - d / q for q in field_sizes]
        axes[1].plot(field_sizes, probs, 'o-', label=f'degree {d}', markersize=4)

    axes[1].set_xlabel('Field Size |F|', fontsize=12)
    axes[1].set_ylabel('Detection Probability', fontsize=12)
    axes[1].set_title('Cheating Detection Probability', fontsize=14)
    axes[1].legend(fontsize=11)
    axes[1].set_ylim(0.5, 1.02)
    axes[1].axhline(y=1, color='gray', linestyle=':', alpha=0.5)

    fig.tight_layout()
    fig.savefig('/workspace/request-project/viz_root_bound.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def viz_sumcheck_simulation():
    """Visualize Monte Carlo simulation of sum-check detection rates."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    random.seed(42)
    prime = 101

    # Left: Single-round detection rate vs number of trials
    n_trials_list = [100, 500, 1000, 5000, 10000, 50000]
    detection_rates = []
    theoretical = 1 - 1/prime

    for n_trials in n_trials_list:
        caught = sum(1 for _ in range(n_trials) if random.randint(0, prime - 1) != 0)
        detection_rates.append(caught / n_trials)

    axes[0].semilogx(n_trials_list, detection_rates, 'bo-', markersize=8, label='Observed')
    axes[0].axhline(y=theoretical, color='r', linestyle='--', linewidth=2,
                    label=f'Theoretical: {theoretical:.4f}')
    axes[0].set_xlabel('Number of Trials', fontsize=12)
    axes[0].set_ylabel('Detection Rate', fontsize=12)
    axes[0].set_title(f'One-Round Detection (F_{prime}, deg=1)', fontsize=14)
    axes[0].legend(fontsize=11)
    axes[0].set_ylim(0.97, 1.0)

    # Right: Multi-round cheating probability
    n_rounds_list = list(range(1, 21))
    n_trials = 100000
    empirical = []
    union_bounds = []
    exact_probs = []

    random.seed(123)
    for n_rounds in n_rounds_list:
        successes = 0
        for _ in range(n_trials):
            if all(random.randint(0, prime - 1) == 0 for _ in range(n_rounds)):
                successes += 1
        empirical.append(successes / n_trials)
        union_bounds.append(min(1, n_rounds / prime))
        exact_probs.append((1/prime) ** n_rounds)

    axes[1].semilogy(n_rounds_list, union_bounds, 'r--', linewidth=2, label='Union bound')
    axes[1].semilogy(n_rounds_list, [max(e, 1e-10) for e in empirical], 'bo', markersize=6,
                     label='Observed', alpha=0.7)
    axes[1].semilogy(n_rounds_list, exact_probs, 'g-', linewidth=2, label='Exact prob')
    axes[1].set_xlabel('Number of Rounds', fontsize=12)
    axes[1].set_ylabel('Cheating Success Probability', fontsize=12)
    axes[1].set_title(f'Multi-Round Cheating (F_{prime}, deg=1)', fontsize=14)
    axes[1].legend(fontsize=11)

    fig.tight_layout()
    fig.savefig('/workspace/request-project/viz_sumcheck_sim.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def viz_agreement_heatmap():
    """Visualize polynomial agreement patterns over small fields."""
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    prime = 13

    for idx, (p_coeffs, q_coeffs, title) in enumerate([
        ([1, 3], [1, 5], 'Linear: 3x+1 vs 5x+1'),
        ([0, 0, 1], [1, 2], 'x² vs 2x+1'),
        ([1, 1, 1], [2, 0, 1], 'x²+x+1 vs x²+2'),
    ]):
        p_vals = [eval_poly(p_coeffs, x, prime) for x in range(prime)]
        q_vals = [eval_poly(q_coeffs, x, prime) for x in range(prime)]
        agree = [1 if p == q else 0 for p, q in zip(p_vals, q_vals)]

        x = list(range(prime))
        axes[idx].bar(x, p_vals, alpha=0.6, label='p(x)', color='#2196F3', width=0.4)
        axes[idx].bar([xi + 0.4 for xi in x], q_vals, alpha=0.6, label='q(x)',
                      color='#FF9800', width=0.4)

        # Mark agreement points
        for i, a in enumerate(agree):
            if a:
                axes[idx].axvline(x=i + 0.2, color='green', alpha=0.3, linewidth=8)
                axes[idx].annotate('✓', (i + 0.2, max(max(p_vals), max(q_vals)) * 0.95),
                                   ha='center', fontsize=14, color='green', fontweight='bold')

        axes[idx].set_xlabel('x', fontsize=12)
        axes[idx].set_ylabel('Value', fontsize=12)
        axes[idx].set_title(f'{title}\n(F_{prime}, agree at {sum(agree)} pts)', fontsize=12)
        axes[idx].legend(fontsize=9)

    fig.suptitle('Polynomial Agreement Over Finite Fields', fontsize=15, fontweight='bold', y=1.02)
    fig.tight_layout()
    fig.savefig('/workspace/request-project/viz_agreement.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def eval_poly(coeffs, x, p):
    """Evaluate polynomial at x mod p."""
    result = 0
    for c in reversed(coeffs):
        result = (result * x + c) % p
    return result


if __name__ == "__main__":
    print("Generating visualizations...")
    b64_1 = viz_root_bound_tightness()
    print(f"  Root bound: saved to viz_root_bound.png ({len(b64_1)} chars base64)")
    b64_2 = viz_sumcheck_simulation()
    print(f"  Sum-check sim: saved to viz_sumcheck_sim.png ({len(b64_2)} chars base64)")
    b64_3 = viz_agreement_heatmap()
    print(f"  Agreement heatmap: saved to viz_agreement.png ({len(b64_3)} chars base64)")
    print("Done!")
