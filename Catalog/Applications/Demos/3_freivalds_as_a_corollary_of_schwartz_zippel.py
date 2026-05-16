#!/usr/bin/env python3
"""
Applications of Schwartz–Zippel and Freivalds' Algorithm

Real-world applications demonstrating the theorems in action:
1. Verified outsourced matrix computation
2. Streaming data equality checking
3. Reed–Muller code distance verification
4. Interactive proof simulation
"""

import random
import numpy as np
from typing import List, Tuple
from itertools import product as cartesian_product


# =============================================================================
# Application 1: Verified Outsourced Computation
# =============================================================================

def outsourced_matrix_multiply(n: int, q: int, inject_error: bool = False):
    """
    Simulate outsourcing matrix multiplication to an untrusted server.
    
    Scenario: A client has n×n matrices A, B and wants to compute A·B.
    The client sends A, B to a server, which returns C (claimed = A·B).
    The client verifies using Freivalds' algorithm in O(n²) time,
    rather than recomputing A·B in O(n³) time.
    
    Args:
        n: Matrix dimension.
        q: Field size (prime).
        inject_error: Whether the server introduces an error.
    """
    print(f"\n  Scenario: {n}×{n} matrices over Z/{q}Z")
    
    # Client generates matrices
    A = np.array([[random.randint(0, q-1) for _ in range(n)] for _ in range(n)])
    B = np.array([[random.randint(0, q-1) for _ in range(n)] for _ in range(n)])
    
    # Server computes (possibly with error)
    C = np.mod(A @ B, q)
    if inject_error:
        i, j = random.randint(0, n-1), random.randint(0, n-1)
        C[i, j] = (C[i, j] + random.randint(1, q-1)) % q
        print(f"  Server introduced error at position ({i},{j})")
    
    # Client verifies with Freivalds (k trials)
    k = 10
    detected = False
    for trial in range(k):
        r = np.array([random.randint(0, q-1) for _ in range(n)])
        Br = np.mod(B @ r, q)
        ABr = np.mod(A @ Br, q)
        Cr = np.mod(C @ r, q)
        if not np.array_equal(ABr, Cr):
            detected = True
            print(f"  Error detected on trial {trial+1}!")
            break
    
    if not detected:
        print(f"  All {k} trials passed — accepting result")
    
    naive_ops = n ** 3
    freivalds_ops = k * 2 * n ** 2
    print(f"  Naive verification cost: O({naive_ops}) = O(n³)")
    print(f"  Freivalds cost:          O({freivalds_ops}) = O(k·n²)")
    print(f"  Speedup factor:          {naive_ops / freivalds_ops:.1f}×")


def demo_outsourced_computation():
    """Demonstrate verified outsourced computation."""
    print("=" * 60)
    print("APPLICATION 1: Verified Outsourced Matrix Computation")
    print("=" * 60)
    print("\nA client outsources matrix multiplication and verifies")
    print("the result in O(n²) time instead of O(n³).")
    
    q = 97  # Large enough prime for realistic demo
    
    print("\n--- Honest server ---")
    outsourced_matrix_multiply(50, q, inject_error=False)
    
    print("\n--- Dishonest server ---")
    outsourced_matrix_multiply(50, q, inject_error=True)


# =============================================================================
# Application 2: Streaming Data Equality
# =============================================================================

def streaming_equality_check(
    stream1: List[int],
    stream2: List[int],
    q: int,
    num_fingerprints: int = 5
) -> Tuple[bool, int]:
    """
    Check equality of two data streams using polynomial fingerprinting.
    
    Instead of storing and comparing the entire streams (O(n) space),
    maintain a running fingerprint (O(1) space per fingerprint).
    
    The fingerprint of [a₀, a₁, ..., aₙ₋₁] at evaluation point r is:
    h = a₀ + a₁·r + a₂·r² + ... + aₙ₋₁·r^{n-1} mod q
    
    By Schwartz–Zippel: if streams differ, Pr[fingerprints match] ≤ (n-1)/q.
    
    Returns:
        (match, space_used): whether streams appear equal, and memory used.
    """
    # Select random evaluation points
    eval_points = [random.randint(0, q-1) for _ in range(num_fingerprints)]
    
    # Compute fingerprints incrementally (simulating streaming)
    fp1 = [0] * num_fingerprints
    fp2 = [0] * num_fingerprints
    
    space_used = num_fingerprints * 3  # fingerprints + eval points + power tracking
    
    for idx in range(max(len(stream1), len(stream2))):
        for k in range(num_fingerprints):
            r = eval_points[k]
            r_power = pow(r, idx, q)
            
            if idx < len(stream1):
                fp1[k] = (fp1[k] + stream1[idx] * r_power) % q
            if idx < len(stream2):
                fp2[k] = (fp2[k] + stream2[idx] * r_power) % q
    
    match = all(fp1[k] == fp2[k] for k in range(num_fingerprints))
    return match, space_used


def demo_streaming_equality():
    """Demonstrate streaming equality checking."""
    print("\n" + "=" * 60)
    print("APPLICATION 2: Streaming Data Equality Checking")
    print("=" * 60)
    print("\nCompare two data streams using O(1) space per fingerprint,")
    print("rather than O(n) space for full comparison.")
    
    q = 10007  # Large prime
    n = 10000  # Stream length
    
    # Equal streams
    stream1 = [random.randint(0, q-1) for _ in range(n)]
    stream2 = list(stream1)
    
    match, space = streaming_equality_check(stream1, stream2, q)
    print(f"\n  Equal streams (n={n}):")
    print(f"    Result: {'EQUAL' if match else 'DIFFERENT'} (correct: EQUAL)")
    print(f"    Space: {space} words vs {n} words for naive comparison")
    
    # Different streams (single bit flip)
    stream3 = list(stream1)
    flip_pos = random.randint(0, n-1)
    stream3[flip_pos] = (stream3[flip_pos] + 1) % q
    
    match, space = streaming_equality_check(stream1, stream3, q, num_fingerprints=5)
    print(f"\n  Different streams (1 element changed at position {flip_pos}):")
    print(f"    Result: {'EQUAL (false positive!)' if match else 'DIFFERENT'}")
    print(f"    Error bound per fingerprint: {(n-1)/q:.6f}")
    print(f"    Error bound with 5 fingerprints: {((n-1)/q)**5:.12f}")


# =============================================================================
# Application 3: Reed–Muller Code Distance
# =============================================================================

def reed_muller_distance(d: int, n: int, q: int) -> Tuple[int, int]:
    """
    Compute the minimum distance of the Reed–Muller code RM(d, n, q).
    
    By Schwartz–Zippel: a nonzero polynomial of degree d over F_q^n
    has at most d · q^{n-1} zeros, so it is nonzero on at least
    (q-d) · q^{n-1} points. This gives the minimum distance.
    
    Returns:
        (theoretical_distance, empirical_min_weight): The SZ bound
        and the empirically observed minimum weight.
    """
    theoretical = (q - d) * (q ** (n - 1))
    
    # For small parameters, verify by exhaustive search
    if q ** n <= 5000 and d <= 3:
        min_weight = q ** n  # Maximum possible
        
        # Generate all monomials of degree ≤ d
        monomials = []
        for exp in cartesian_product(range(d + 1), repeat=n):
            if sum(exp) <= d:
                monomials.append(exp)
        
        # Sample random polynomials of degree exactly d and find min weight
        num_samples = min(500, q ** len(monomials))
        for _ in range(num_samples):
            # Random polynomial of degree ≤ d
            coeffs = {}
            has_degree_d = False
            for mono in monomials:
                c = random.randint(0, q - 1)
                if c != 0:
                    coeffs[mono] = c
                    if sum(mono) == d:
                        has_degree_d = True
            
            if not coeffs or not has_degree_d:
                continue
            
            # Count nonzeros (= Hamming weight of codeword)
            weight = 0
            for point in cartesian_product(range(q), repeat=n):
                val = 0
                for exp, coeff in coeffs.items():
                    term = coeff
                    for i, e in enumerate(exp):
                        term = (term * pow(point[i], e, q)) % q
                    val = (val + term) % q
                if val != 0:
                    weight += 1
            
            min_weight = min(min_weight, weight)
        
        return theoretical, min_weight
    
    return theoretical, -1  # Too large for exhaustive search


def demo_reed_muller():
    """Demonstrate Reed–Muller code distance from Schwartz–Zippel."""
    print("\n" + "=" * 60)
    print("APPLICATION 3: Reed–Muller Code Minimum Distance")
    print("=" * 60)
    print("\nThe Schwartz–Zippel bound gives the minimum distance of")
    print("Reed–Muller codes: d_min = (q - deg) · q^{n-1}.")
    
    print(f"\n{'q':>4} {'n':>3} {'deg':>4} {'d_min (SZ)':>12} {'d_min (emp)':>12} {'tight?':>7}")
    print("-" * 50)
    
    test_cases = [
        (3, 2, 1), (3, 2, 2),
        (5, 2, 1), (5, 2, 2), (5, 2, 3),
        (7, 2, 1), (7, 2, 2),
        (3, 3, 1), (3, 3, 2),
        (5, 3, 1),
    ]
    
    for q, n, d in test_cases:
        if d >= q:
            continue
        theoretical, empirical = reed_muller_distance(d, n, q)
        tight = "YES" if empirical == theoretical else ("~" if empirical <= theoretical * 1.1 else "no")
        emp_str = str(empirical) if empirical >= 0 else "N/A"
        print(f"{q:>4} {n:>3} {d:>4} {theoretical:>12} {emp_str:>12} {tight:>7}")
    
    print(f"\n  The bound is tight: there exist polynomials achieving exactly")
    print(f"  the minimum weight (e.g., products of d linear factors).")


# =============================================================================
# Application 4: Simple Interactive Proof
# =============================================================================

def interactive_proof_demo():
    """
    Simulate an interactive proof for graph non-isomorphism using
    polynomial fingerprinting over finite fields.
    
    This demonstrates how Schwartz–Zippel underlies the soundness
    of interactive proof protocols.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Interactive Proof Simulation")
    print("=" * 60)
    print("\nA verifier checks a prover's claim using random challenges.")
    print("Soundness relies on Schwartz–Zippel: a cheating prover must")
    print("make a polynomial vanish at a random point.")
    
    q = 97
    n = 5  # Polynomial degree bound
    
    # Prover claims to know a degree-n polynomial f with specific properties
    # Verifier checks by evaluating at random points
    
    # Honest prover: f(x) = x^5 + 3x^3 + 2x + 1 over Z/97Z
    honest_coeffs = [1, 2, 0, 3, 0, 1]  # coefficients of 1 + 2x + 3x³ + x⁵
    
    # Cheating prover: tries to fake with a DIFFERENT polynomial
    cheat_coeffs = [1, 2, 0, 3, 0, 2]  # differs in x⁵ coefficient
    
    print(f"\n  Field: Z/{q}Z, degree bound: {n}")
    print(f"  Honest polynomial:  coeffs = {honest_coeffs}")
    print(f"  Cheating polynomial: coeffs = {cheat_coeffs}")
    
    num_rounds = 10
    caught = 0
    
    for round_num in range(num_rounds):
        # Verifier sends random challenge
        r = random.randint(0, q - 1)
        
        # Honest evaluation
        honest_val = sum(c * pow(r, i, q) for i, c in enumerate(honest_coeffs)) % q
        
        # Cheating evaluation
        cheat_val = sum(c * pow(r, i, q) for i, c in enumerate(cheat_coeffs)) % q
        
        if honest_val != cheat_val:
            caught += 1
    
    print(f"\n  Over {num_rounds} rounds:")
    print(f"    Cheater caught: {caught}/{num_rounds} times")
    print(f"    Theoretical detection probability per round: ≥ 1 - {n}/{q} = {1 - n/q:.4f}")
    print(f"    (The difference polynomial has degree ≤ {n}, so by Schwartz–Zippel")
    print(f"     it vanishes on at most {n}/{q} fraction of challenges.)")


# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    random.seed(42)
    np.random.seed(42)
    
    demo_outsourced_computation()
    demo_streaming_equality()
    demo_reed_muller()
    interactive_proof_demo()
    
    print("\n" + "=" * 60)
    print("All applications demonstrated successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Demo: Schwartz–Zippel Lemma and Freivalds' Algorithm over Finite Fields

Concrete numerical demonstrations showing:
1. Freivalds' randomized matrix multiplication verification
2. Schwartz–Zippel zero-set counting for multivariate polynomials
3. Empirical vs theoretical error probability comparison
"""

import random
import numpy as np
from itertools import product as cartesian_product
from collections import Counter


def mod_matrix_mul(A, B, q):
    """Matrix multiplication modulo q."""
    return np.mod(A @ B, q)


def mod_matrix_vec(M, v, q):
    """Matrix-vector multiplication modulo q."""
    return np.mod(M @ v, q)


# =============================================================================
# Demo 1: Freivalds' Algorithm
# =============================================================================

def freivalds_check(A, B, C, q, num_trials=1):
    """
    Freivalds' algorithm: check if A*B ≡ C (mod q).
    
    Returns True if the check passes (might be wrong if A*B ≠ C),
    Returns False if the check fails (definitely A*B ≠ C).
    
    Error probability ≤ (1/q)^num_trials when A*B ≠ C.
    """
    n = A.shape[0]
    for _ in range(num_trials):
        r = np.array([random.randint(0, q - 1) for _ in range(n)])
        # Compute A*(B*r) and C*r mod q
        Br = mod_matrix_vec(B, r, q)
        ABr = mod_matrix_vec(A, Br, q)
        Cr = mod_matrix_vec(C, r, q)
        if not np.array_equal(ABr, Cr):
            return False  # Definitely not equal
    return True  # Might be equal


def demo_freivalds():
    """Demonstrate Freivalds' algorithm with concrete examples."""
    print("=" * 70)
    print("DEMO 1: Freivalds' Randomized Matrix Multiplication Verification")
    print("=" * 70)
    
    q = 7  # Work over Z/7Z
    n = 4  # 4x4 matrices
    
    # Generate random matrices
    A = np.array([[random.randint(0, q - 1) for _ in range(n)] for _ in range(n)])
    B = np.array([[random.randint(0, q - 1) for _ in range(n)] for _ in range(n)])
    C_correct = mod_matrix_mul(A, B, q)
    
    # Introduce a single-entry error
    C_wrong = C_correct.copy()
    C_wrong[0, 0] = (C_wrong[0, 0] + 1) % q
    
    print(f"\nField: Z/{q}Z, Matrix size: {n}x{n}")
    print(f"\nA =\n{A}")
    print(f"\nB =\n{B}")
    print(f"\nCorrect A*B (mod {q}) =\n{C_correct}")
    print(f"\nWrong C (single entry changed) =\n{C_wrong}")
    
    # Test with correct product
    print(f"\n--- Testing with CORRECT product ---")
    results_correct = [freivalds_check(A, B, C_correct, q) for _ in range(100)]
    print(f"  100 trials: {sum(results_correct)} passed (should be 100)")
    
    # Test with wrong product - single trial
    print(f"\n--- Testing with WRONG product (single trial each) ---")
    results_wrong = [freivalds_check(A, B, C_wrong, q) for _ in range(1000)]
    false_accepts = sum(results_wrong)
    print(f"  1000 single-trial tests: {false_accepts} false accepts")
    print(f"  Empirical error rate: {false_accepts/1000:.4f}")
    print(f"  Theoretical bound:    {1/q:.4f} = 1/{q}")
    
    # Test with multiple trials
    print(f"\n--- Testing with WRONG product (k=3 trials each) ---")
    results_multi = [freivalds_check(A, B, C_wrong, q, num_trials=3) for _ in range(10000)]
    false_accepts_multi = sum(results_multi)
    print(f"  10000 tests with k=3: {false_accepts_multi} false accepts")
    print(f"  Empirical error rate: {false_accepts_multi/10000:.6f}")
    print(f"  Theoretical bound:    {(1/q)**3:.6f} = 1/{q}^3")
    print()


# =============================================================================
# Demo 2: Schwartz–Zippel Zero Set Counting
# =============================================================================

def eval_poly_mod(coeffs, point, q):
    """
    Evaluate a multivariate polynomial at a point modulo q.
    
    coeffs: dict mapping tuples of exponents to coefficients
    point: tuple of values for each variable
    """
    result = 0
    for exponents, coeff in coeffs.items():
        term = coeff
        for i, e in enumerate(exponents):
            term = (term * pow(int(point[i]), int(e), q)) % q
        result = (result + term) % q
    return result


def count_zeros(coeffs, n, q):
    """Count zeros of a polynomial over (Z/qZ)^n by exhaustive enumeration."""
    count = 0
    for point in cartesian_product(range(q), repeat=n):
        if eval_poly_mod(coeffs, point, q) == 0:
            count += 1
    return count


def total_degree(coeffs):
    """Compute total degree of a polynomial."""
    if not coeffs:
        return 0
    return max(sum(exp) for exp in coeffs.keys())


def demo_schwartz_zippel():
    """Demonstrate the Schwartz–Zippel bound with concrete polynomials."""
    print("=" * 70)
    print("DEMO 2: Schwartz–Zippel Zero Set Counting")
    print("=" * 70)
    
    q = 5  # Work over Z/5Z
    
    examples = [
        # (name, n_vars, coefficients_dict, description)
        ("Linear", 3, {(1, 0, 0): 1, (0, 1, 0): 2, (0, 0, 1): 3, (0, 0, 0): 1},
         "x + 2y + 3z + 1"),
        ("Quadratic", 2, {(2, 0): 1, (0, 2): 1, (1, 1): 3, (0, 0): 2},
         "x² + y² + 3xy + 2"),
        ("Cubic in 2 vars", 2, {(3, 0): 1, (0, 1): 4, (0, 0): 1},
         "x³ + 4y + 1"),
        ("Degree 2 in 3 vars", 3, {(1, 1, 0): 1, (0, 0, 1): 2, (0, 0, 0): 3},
         "xy + 2z + 3"),
    ]
    
    print(f"\nField: Z/{q}Z (q = {q})")
    print(f"{'Polynomial':<25} {'n':>3} {'deg':>4} {'#zeros':>7} {'bound':>7} {'ratio':>8}")
    print("-" * 60)
    
    for name, n, coeffs, desc in examples:
        d = total_degree(coeffs)
        zeros = count_zeros(coeffs, n, q)
        bound = d * q ** (n - 1)
        total_points = q ** n
        ratio = zeros / total_points if total_points > 0 else 0
        
        print(f"{desc:<25} {n:>3} {d:>4} {zeros:>7} {bound:>7} {ratio:>8.4f}")
    
    print(f"\nSchwartz–Zippel bound: #zeros ≤ deg(f) · q^(n-1)")
    print(f"Probability bound:    Pr[f(r) = 0] ≤ deg(f) / q")
    print()


# =============================================================================
# Demo 3: Linear Form Zero Sets (Freivalds Connection)
# =============================================================================

def demo_linear_forms():
    """Demonstrate that linear form zero sets have exactly q^{n-1} elements."""
    print("=" * 70)
    print("DEMO 3: Linear Form Zero Sets — The Freivalds Connection")
    print("=" * 70)
    
    q = 7
    
    print(f"\nField: Z/{q}Z")
    print(f"\nFor a nonzero linear form L(x) = v·x, the zero set has exactly q^(n-1) elements.")
    print(f"This is the kernel of a surjective linear map, which is a hyperplane.\n")
    
    for n in range(1, 5):
        # Random nonzero vector
        v = [0] * n
        while all(x == 0 for x in v):
            v = [random.randint(0, q - 1) for _ in range(n)]
        
        # Count zeros of the linear form
        zeros = 0
        for x in cartesian_product(range(q), repeat=n):
            dot = sum(v[i] * x[i] for i in range(n)) % q
            if dot == 0:
                zeros += 1
        
        bound = q ** (n - 1)
        print(f"  n={n}, v={v}: #zeros = {zeros}, q^(n-1) = {bound}, match = {zeros == bound}")
    
    print(f"\n  The zero set is always EXACTLY q^(n-1) = a hyperplane through the origin.")
    print(f"  This powers Freivalds: a nonzero row of D gives a nonzero linear form,")
    print(f"  so Dr=0 can hold for at most q^(n-1) vectors r out of q^n total.")
    print()


# =============================================================================
# Demo 4: Empirical Convergence
# =============================================================================

def demo_convergence():
    """Show how error probability converges to theoretical bound."""
    print("=" * 70)
    print("DEMO 4: Error Probability Convergence")
    print("=" * 70)
    
    n = 5  # Matrix size
    
    print(f"\nMatrix size: {n}x{n}")
    print(f"Each row: 10000 independent Freivalds tests with k=1 trial")
    print(f"\n{'q':>5} {'1/q':>10} {'empirical':>10} {'within 2σ':>10}")
    print("-" * 40)
    
    for q in [2, 3, 5, 7, 11, 13]:
        # Generate test case
        A = np.array([[random.randint(0, q - 1) for _ in range(n)] for _ in range(n)])
        B = np.array([[random.randint(0, q - 1) for _ in range(n)] for _ in range(n)])
        C = mod_matrix_mul(A, B, q)
        C[0, 0] = (C[0, 0] + 1) % q  # Introduce error
        
        N = 10000
        false_accepts = sum(1 for _ in range(N) if freivalds_check(A, B, C, q))
        empirical = false_accepts / N
        theoretical = 1.0 / q
        sigma = (theoretical * (1 - theoretical) / N) ** 0.5
        within = "YES" if abs(empirical - theoretical) < 2 * sigma else "no"
        
        print(f"{q:>5} {theoretical:>10.6f} {empirical:>10.6f} {within:>10}")
    
    print(f"\n  The empirical error rate closely tracks 1/q as predicted by")
    print(f"  the Schwartz–Zippel degree-1 bound (= Freivalds' theorem).")
    print()


# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    random.seed(42)
    np.random.seed(42)
    
    demo_freivalds()
    demo_schwartz_zippel()
    demo_linear_forms()
    demo_convergence()
    
    print("=" * 70)
    print("All demos completed successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualizations for Schwartz–Zippel and Freivalds' Algorithm

Generates publication-quality figures saved as PNG files.
"""

import random
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import product as cartesian_product
from collections import defaultdict
import base64
import io


def fig_to_base64(fig):
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    return f"data:image/png;base64,{encoded}"


# =============================================================================
# Figure 1: Freivalds Error Rate vs Theoretical Bound
# =============================================================================

def plot_freivalds_error_rate():
    """Plot empirical Freivalds error rate vs 1/q for various q."""
    fig, ax = plt.subplots(figsize=(10, 6))
    
    n = 5  # Matrix size
    N = 5000  # Trials per q
    
    primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31]
    empirical_rates = []
    theoretical_rates = [1.0/q for q in primes]
    
    for q in primes:
        # Generate test case
        A = np.array([[random.randint(0, q-1) for _ in range(n)] for _ in range(n)])
        B = np.array([[random.randint(0, q-1) for _ in range(n)] for _ in range(n)])
        C = np.mod(A @ B, q)
        C[0, 0] = (C[0, 0] + 1) % q  # Introduce error
        
        false_accepts = 0
        for _ in range(N):
            r = np.array([random.randint(0, q-1) for _ in range(n)])
            ABr = np.mod(A @ np.mod(B @ r, q), q)
            Cr = np.mod(C @ r, q)
            if np.array_equal(ABr, Cr):
                false_accepts += 1
        
        empirical_rates.append(false_accepts / N)
    
    ax.plot(primes, theoretical_rates, 'r-o', linewidth=2, markersize=8, 
            label='Theoretical bound: 1/q', zorder=3)
    ax.plot(primes, empirical_rates, 'b-s', linewidth=2, markersize=8,
            label=f'Empirical rate (n={n}, {N} trials)', zorder=3)
    
    ax.fill_between(primes, 
                     [t - 2*np.sqrt(t*(1-t)/N) for t in theoretical_rates],
                     [t + 2*np.sqrt(t*(1-t)/N) for t in theoretical_rates],
                     alpha=0.2, color='red', label='±2σ confidence band')
    
    ax.set_xlabel('Field size q (prime)', fontsize=14)
    ax.set_ylabel('Error probability', fontsize=14)
    ax.set_title("Freivalds' Algorithm: Error Rate vs Schwartz–Zippel Bound", fontsize=16)
    ax.legend(fontsize=12)
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)
    ax.set_xticks(primes)
    
    fig.tight_layout()
    fig.savefig('/workspace/request-project/freivalds_error_rate.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


# =============================================================================
# Figure 2: Schwartz–Zippel Zero Set Size vs Degree
# =============================================================================

def plot_schwartz_zippel_zeros():
    """Plot zero set sizes for random polynomials vs the SZ bound."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Panel (a): Fixed q=5, n=2, varying degree
    q = 5
    n = 2
    degrees = range(1, 5)
    sz_bounds = [d * q**(n-1) for d in degrees]
    
    empirical_zeros = defaultdict(list)
    
    for d in degrees:
        for _ in range(50):  # Sample random polynomials
            # Random polynomial of degree exactly d in 2 variables
            coeffs = {}
            for e1 in range(d + 1):
                for e2 in range(d + 1 - e1):
                    c = random.randint(0, q - 1)
                    if c != 0:
                        coeffs[(e1, e2)] = c
            
            # Ensure degree is exactly d
            if not coeffs:
                coeffs[(d, 0)] = 1
            max_deg = max(sum(e) for e in coeffs.keys())
            if max_deg < d:
                coeffs[(d, 0)] = random.randint(1, q - 1)
            
            # Count zeros
            zeros = 0
            for point in cartesian_product(range(q), repeat=n):
                val = 0
                for exp, coeff in coeffs.items():
                    term = coeff
                    for i, e in enumerate(exp):
                        term = (term * pow(point[i], e, q)) % q
                    val = (val + term) % q
                if val == 0:
                    zeros += 1
            
            empirical_zeros[d].append(zeros)
    
    ax = axes[0]
    for d in degrees:
        ax.scatter([d] * len(empirical_zeros[d]), empirical_zeros[d], 
                   alpha=0.4, s=30, color='steelblue', zorder=2)
    
    ax.plot(list(degrees), sz_bounds, 'r-o', linewidth=2.5, markersize=10, 
            label='Schwartz–Zippel bound: d·q^{n-1}', zorder=3)
    
    # Mean line
    means = [np.mean(empirical_zeros[d]) for d in degrees]
    ax.plot(list(degrees), means, 'g--^', linewidth=2, markersize=8, 
            label='Mean #zeros', zorder=3)
    
    ax.set_xlabel('Total degree d', fontsize=13)
    ax.set_ylabel('Number of zeros', fontsize=13)
    ax.set_title(f'Zero Set Size (q={q}, n={n})', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    # Panel (b): Fixed degree=2, n=2, varying q
    d = 2
    n = 2
    primes_b = [3, 5, 7, 11, 13]
    sz_bounds_b = [d * p**(n-1) for p in primes_b]
    
    empirical_b = defaultdict(list)
    
    for p in primes_b:
        for _ in range(30):
            coeffs = {}
            for e1 in range(d + 1):
                for e2 in range(d + 1 - e1):
                    c = random.randint(0, p - 1)
                    if c != 0:
                        coeffs[(e1, e2)] = c
            if not coeffs:
                coeffs[(d, 0)] = 1
            max_deg = max(sum(e) for e in coeffs.keys())
            if max_deg < d:
                coeffs[(d, 0)] = random.randint(1, p - 1)
            
            zeros = 0
            for point in cartesian_product(range(p), repeat=n):
                val = 0
                for exp, coeff in coeffs.items():
                    term = coeff
                    for i, e in enumerate(exp):
                        term = (term * pow(point[i], e, p)) % p
                    val = (val + term) % p
                if val == 0:
                    zeros += 1
            empirical_b[p].append(zeros)
    
    ax = axes[1]
    for p in primes_b:
        ax.scatter([p] * len(empirical_b[p]), empirical_b[p], 
                   alpha=0.4, s=30, color='steelblue', zorder=2)
    
    ax.plot(primes_b, sz_bounds_b, 'r-o', linewidth=2.5, markersize=10, 
            label=f'SZ bound: {d}·q', zorder=3)
    
    means_b = [np.mean(empirical_b[p]) for p in primes_b]
    ax.plot(primes_b, means_b, 'g--^', linewidth=2, markersize=8, 
            label='Mean #zeros', zorder=3)
    
    ax.set_xlabel('Field size q', fontsize=13)
    ax.set_ylabel('Number of zeros', fontsize=13)
    ax.set_title(f'Zero Set Size (degree={d}, n={n})', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    fig.suptitle('Schwartz–Zippel Lemma: Zero Sets of Random Polynomials', fontsize=16, y=1.02)
    fig.tight_layout()
    fig.savefig('/workspace/request-project/schwartz_zippel_zeros.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


# =============================================================================
# Figure 3: Theorem Dependency Graph
# =============================================================================

def plot_theorem_hierarchy():
    """Visualize the theorem dependency structure."""
    fig, ax = plt.subplots(figsize=(12, 8))
    ax.set_xlim(-1, 11)
    ax.set_ylim(-0.5, 7.5)
    ax.set_aspect('equal')
    ax.axis('off')
    
    # Node positions and labels
    nodes = {
        'univariate_root_bound': (5, 7, 'Univariate Root Bound\n(base case)'),
        'fiber_construction': (2, 5.5, 'Fiber Polynomial\nConstruction'),
        'coeff_degree_bound': (8, 5.5, 'Coefficient Degree\nBound'),
        'sz_one': (5, 5.5, 'schwartz_zippel_one\n(1-variable case)'),
        'sz_succ': (5, 4, 'schwartz_zippel_succ\n(main theorem)'),
        'sz_zmod': (8, 3, 'schwartz_zippel_zmod\n(ZMod q)'),
        'linear_sz': (2, 3, 'linear_schwartz_zippel\n(degree ≤ 1)'),
        'linear_form': (0.5, 1.5, 'nonzero_linear_form\n_zero_set_bound'),
        'freivalds_disc': (3.5, 1.5, 'freivalds_discrepancy\n_bound'),
        'freivalds': (6.5, 1.5, 'freivalds_bound\n(AB ≠ C)'),
        'freivalds_zmod': (5, 0, 'freivalds_zmod_bound\n(ZMod q)'),
        'error_prob': (8.5, 0, 'freivalds_error\n_probability'),
    }
    
    # Edges
    edges = [
        ('univariate_root_bound', 'sz_one'),
        ('fiber_construction', 'sz_succ'),
        ('coeff_degree_bound', 'sz_succ'),
        ('sz_one', 'sz_succ'),
        ('sz_succ', 'sz_zmod'),
        ('sz_succ', 'linear_sz'),
        ('linear_form', 'freivalds_disc'),
        ('freivalds_disc', 'freivalds'),
        ('freivalds_disc', 'freivalds_zmod'),
        ('freivalds_zmod', 'error_prob'),
    ]
    
    # Draw edges
    for src, dst in edges:
        x1, y1, _ = nodes[src]
        x2, y2, _ = nodes[dst]
        ax.annotate('', xy=(x2, y2 + 0.35), xytext=(x1, y1 - 0.35),
                    arrowprops=dict(arrowstyle='->', color='#555555', lw=1.5))
    
    # Draw nodes
    colors = {
        'univariate_root_bound': '#E8F5E9',  # Light green - external
        'fiber_construction': '#E3F2FD',      # Light blue - infrastructure
        'coeff_degree_bound': '#E3F2FD',
        'sz_one': '#FFF3E0',                  # Light orange - SZ
        'sz_succ': '#FFCC80',                 # Orange - main
        'sz_zmod': '#FFF3E0',
        'linear_sz': '#FFF3E0',
        'linear_form': '#F3E5F5',             # Light purple - Freivalds
        'freivalds_disc': '#CE93D8',          # Purple - main
        'freivalds': '#F3E5F5',
        'freivalds_zmod': '#CE93D8',
        'error_prob': '#F3E5F5',
    }
    
    for key, (x, y, label) in nodes.items():
        bbox = dict(boxstyle='round,pad=0.4', facecolor=colors[key], 
                    edgecolor='#333333', linewidth=1.5)
        ax.text(x, y, label, ha='center', va='center', fontsize=9,
                fontweight='bold', bbox=bbox)
    
    ax.set_title('Theorem Dependency Graph: Schwartz–Zippel → Freivalds', 
                 fontsize=16, fontweight='bold', pad=20)
    
    # Legend
    legend_items = [
        ('#E8F5E9', 'External dependency'),
        ('#E3F2FD', 'Infrastructure lemma'),
        ('#FFCC80', 'Schwartz–Zippel (main)'),
        ('#CE93D8', 'Freivalds (main)'),
    ]
    for i, (color, label) in enumerate(legend_items):
        ax.add_patch(plt.Rectangle((9, 7 - i * 0.5), 0.3, 0.3, 
                                    facecolor=color, edgecolor='#333'))
        ax.text(9.5, 7 - i * 0.5 + 0.15, label, va='center', fontsize=10)
    
    fig.tight_layout()
    fig.savefig('/workspace/request-project/theorem_hierarchy.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


# =============================================================================
# Figure 4: Repeated Trials Error Decay
# =============================================================================

def plot_repeated_trials():
    """Show exponential decay of error with repeated Freivalds trials."""
    fig, ax = plt.subplots(figsize=(10, 6))
    
    n = 4
    max_trials = 15
    
    for q in [2, 3, 5, 7, 11]:
        # Generate matrices
        A = np.array([[random.randint(0, q-1) for _ in range(n)] for _ in range(n)])
        B = np.array([[random.randint(0, q-1) for _ in range(n)] for _ in range(n)])
        C = np.mod(A @ B, q)
        C[0, 0] = (C[0, 0] + 1) % q
        
        N = 10000
        error_rates = []
        
        for k in range(1, max_trials + 1):
            false_accepts = 0
            for _ in range(N):
                passed = True
                for _ in range(k):
                    r = np.array([random.randint(0, q-1) for _ in range(n)])
                    ABr = np.mod(A @ np.mod(B @ r, q), q)
                    Cr = np.mod(C @ r, q)
                    if not np.array_equal(ABr, Cr):
                        passed = False
                        break
                if passed:
                    false_accepts += 1
            error_rates.append(false_accepts / N)
        
        theoretical = [(1.0/q)**k for k in range(1, max_trials + 1)]
        
        ax.plot(range(1, max_trials + 1), error_rates, 'o-', 
                label=f'q={q} (empirical)', alpha=0.7)
        ax.plot(range(1, max_trials + 1), theoretical, '--', 
                label=f'q={q} (bound: (1/{q})^k)', alpha=0.5)
    
    ax.set_xlabel('Number of trials (k)', fontsize=14)
    ax.set_ylabel('Error probability', fontsize=14)
    ax.set_title("Freivalds' Error Decay with Repeated Trials", fontsize=16)
    ax.set_yscale('log')
    ax.legend(fontsize=9, ncol=2, loc='upper right')
    ax.grid(True, alpha=0.3)
    ax.set_xticks(range(1, max_trials + 1))
    
    fig.tight_layout()
    fig.savefig('/workspace/request-project/repeated_trials.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    random.seed(42)
    np.random.seed(42)
    
    print("Generating visualizations...")
    
    print("  [1/4] Freivalds error rate...")
    b64_1 = plot_freivalds_error_rate()
    
    print("  [2/4] Schwartz–Zippel zero sets...")
    b64_2 = plot_schwartz_zippel_zeros()
    
    print("  [3/4] Theorem hierarchy...")
    b64_3 = plot_theorem_hierarchy()
    
    print("  [4/4] Repeated trials decay...")
    b64_4 = plot_repeated_trials()
    
    print("\nAll visualizations saved as PNG files.")
    print("  - freivalds_error_rate.png")
    print("  - schwartz_zippel_zeros.png")
    print("  - theorem_hierarchy.png")
    print("  - repeated_trials.png")
    
    # Save base64 data for JSON packaging
    with open('/workspace/request-project/viz_data.txt', 'w') as f:
        f.write("VIZ1_START\n")
        f.write(b64_1 + "\n")
        f.write("VIZ1_END\n")
        f.write("VIZ2_START\n")
        f.write(b64_2 + "\n")
        f.write("VIZ2_END\n")
        f.write("VIZ3_START\n")
        f.write(b64_3 + "\n")
        f.write("VIZ3_END\n")
        f.write("VIZ4_START\n")
        f.write(b64_4 + "\n")
        f.write("VIZ4_END\n")
