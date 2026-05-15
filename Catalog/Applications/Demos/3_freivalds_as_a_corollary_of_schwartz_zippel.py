#!/usr/bin/env python3
"""
Real-world applications of the Schwartz-Zippel lemma and Freivalds' algorithm.

Demonstrates applications in:
1. Cryptographic polynomial commitments
2. Verifiable computation / proof systems
3. Polynomial hashing for string matching
4. Reed-Solomon error detection
"""

import numpy as np
from typing import List, Tuple
import hashlib


class PolynomialFingerprint:
    """Polynomial fingerprinting for equality testing.
    
    Application: Two parties each hold a large dataset (represented as a 
    polynomial). They can verify equality by exchanging O(1) field elements
    instead of the full dataset, with error ≤ d/q.
    
    This is a direct application of Schwartz-Zippel:
    if f ≠ g, then f - g is nonzero of degree ≤ d, so
    Pr[f(r) = g(r)] ≤ d/q for random r.
    """
    
    def __init__(self, q: int = 2**61 - 1):
        """Initialize with a large prime modulus."""
        self.q = q  # Mersenne prime 2^61 - 1
    
    def fingerprint(self, data: List[int], point: int) -> int:
        """Compute polynomial fingerprint of data at a given point.
        
        Interprets data as coefficients of a polynomial and evaluates at point.
        Uses Horner's method for efficiency.
        """
        result = 0
        for coeff in reversed(data):
            result = (result * point + coeff) % self.q
        return result
    
    def test_equality(self, data1: List[int], data2: List[int], trials: int = 3) -> bool:
        """Test if two datasets are equal using polynomial fingerprints.
        
        Error probability ≤ (max(len(data1), len(data2)) / q)^trials.
        """
        import random
        for _ in range(trials):
            r = random.randint(0, self.q - 1)
            if self.fingerprint(data1, r) != self.fingerprint(data2, r):
                return False
        return True


class MatrixVerifier:
    """Verified matrix computation using Freivalds' algorithm.
    
    Application: In verifiable computation, a prover claims to have computed
    A·B = C. The verifier can check this claim in O(n²) time instead of O(n³),
    with cryptographic certainty.
    
    This is used in:
    - Interactive proof systems (IP = PSPACE)
    - Verifiable outsourced computation
    - Zero-knowledge proofs involving linear algebra
    """
    
    def __init__(self, q: int = 2**61 - 1):
        self.q = q
    
    def verify_product(self, A: np.ndarray, B: np.ndarray, C: np.ndarray,
                       trials: int = 40) -> Tuple[bool, float]:
        """Verify A·B = C with Freivalds' algorithm.
        
        Returns (result, error_bound).
        """
        n = A.shape[0]
        for _ in range(trials):
            r = np.random.randint(0, min(self.q, 2**31), n)
            Br = np.array([(sum(int(B[i,j]) * int(r[j]) for j in range(n))) % self.q 
                          for i in range(n)])
            ABr = np.array([(sum(int(A[i,j]) * int(Br[j]) for j in range(n))) % self.q 
                           for i in range(n)])
            Cr = np.array([(sum(int(C[i,j]) * int(r[j]) for j in range(n))) % self.q 
                          for i in range(n)])
            if not np.array_equal(ABr, Cr):
                return False, 0.0
        return True, (1 / self.q) ** trials


class ReedSolomonChecker:
    """Reed-Solomon codeword validation via Schwartz-Zippel.
    
    Application: A Reed-Solomon code of dimension k over F_q encodes 
    messages as evaluations of degree-(k-1) polynomials. The minimum
    distance is q - k + 1 (by Schwartz-Zippel: a nonzero polynomial
    of degree ≤ k-1 has at most k-1 zeros, so any two codewords 
    differ in at least q - k + 1 positions).
    
    This gives efficient error detection: evaluate the interpolating
    polynomial at a random point and check consistency.
    """
    
    def __init__(self, q: int, k: int):
        """
        Args:
            q: field size (prime)
            k: dimension (message length)
        """
        self.q = q
        self.k = k
        self.eval_points = list(range(q))
    
    def encode(self, message: List[int]) -> List[int]:
        """Encode a message as a Reed-Solomon codeword.
        
        Message coefficients define a polynomial; evaluate at all field points.
        """
        assert len(message) == self.k
        codeword = []
        for x in self.eval_points:
            val = 0
            for i, c in enumerate(message):
                val = (val + c * pow(x, i, self.q)) % self.q
            codeword.append(val)
        return codeword
    
    def minimum_distance(self) -> int:
        """Minimum distance of the code, guaranteed by Schwartz-Zippel."""
        return self.q - self.k + 1
    
    def check_codeword(self, word: List[int], trials: int = 5) -> bool:
        """Check if a received word is a valid codeword.
        
        Interpolates the polynomial from k points and checks 
        consistency at random other points. Error ≤ ((k-1)/q)^trials.
        """
        import random
        
        # Use first k points to interpolate
        if len(word) < self.k:
            return False
        
        # Lagrange interpolation at random test point
        for _ in range(trials):
            test_idx = random.randint(self.k, len(word) - 1)
            test_x = self.eval_points[test_idx]
            
            # Evaluate interpolating polynomial at test_x
            val = 0
            for i in range(self.k):
                xi = self.eval_points[i]
                li = 1
                for j in range(self.k):
                    if j != i:
                        xj = self.eval_points[j]
                        li = (li * (test_x - xj) * pow(xi - xj, self.q - 2, self.q)) % self.q
                val = (val + word[i] * li) % self.q
            
            if val != word[test_idx]:
                return False
        return True


def demo_fingerprinting():
    """Demonstrate polynomial fingerprinting."""
    print("=" * 60)
    print("Application 1: Polynomial Fingerprinting")
    print("=" * 60)
    print()
    
    fp = PolynomialFingerprint()
    
    # Two identical large datasets
    n = 100000
    data1 = list(range(n))
    data2 = list(range(n))
    
    print(f"Dataset size: {n} elements")
    print(f"Equal datasets: {fp.test_equality(data1, data2)}")
    
    # Corrupt one element
    data2[50000] = data2[50000] + 1
    print(f"After corruption: {fp.test_equality(data1, data2)}")
    print(f"Error bound: {n / fp.q:.2e}")
    print()


def demo_verifiable_computation():
    """Demonstrate verifiable matrix computation."""
    print("=" * 60)
    print("Application 2: Verifiable Matrix Computation")
    print("=" * 60)
    print()
    
    q = 101
    n = 50
    verifier = MatrixVerifier(q=q)
    
    A = np.random.randint(0, q, (n, n))
    B = np.random.randint(0, q, (n, n))
    C = np.zeros((n, n), dtype=int)
    for i in range(n):
        for j in range(n):
            C[i, j] = sum(int(A[i,k]) * int(B[k,j]) for k in range(n)) % q
    
    result, bound = verifier.verify_product(A, B, C, trials=20)
    print(f"Correct product verified: {result}")
    print(f"Error bound: {bound:.2e}")
    
    # Corrupt
    C[0, 0] = (C[0, 0] + 1) % q
    result, bound = verifier.verify_product(A, B, C, trials=20)
    print(f"Corrupted product detected: {not result}")
    print()


def demo_reed_solomon():
    """Demonstrate Reed-Solomon error detection."""
    print("=" * 60)
    print("Application 3: Reed-Solomon Error Detection")
    print("=" * 60)
    print()
    
    q = 31  # Small prime for demonstration
    k = 5   # Message length
    
    rs = ReedSolomonChecker(q, k)
    print(f"Reed-Solomon [{q}, {k}] code over F_{q}")
    print(f"Minimum distance (via Schwartz-Zippel): {rs.minimum_distance()}")
    print(f"Can correct up to {(rs.minimum_distance() - 1) // 2} errors")
    print()
    
    # Encode a message
    message = [3, 1, 4, 1, 5]
    codeword = rs.encode(message)
    print(f"Message: {message}")
    print(f"Codeword: {codeword}")
    print(f"Valid codeword: {rs.check_codeword(codeword)}")
    
    # Corrupt the codeword
    corrupted = codeword.copy()
    corrupted[10] = (corrupted[10] + 1) % q
    print(f"After corruption at position 10: {rs.check_codeword(corrupted)}")
    print()


if __name__ == "__main__":
    np.random.seed(42)
    demo_fingerprinting()
    print()
    demo_verifiable_computation()
    print()
    demo_reed_solomon()


#!/usr/bin/env python3
"""
Demonstration of the Schwartz-Zippel Lemma and Freivalds' Algorithm.

This script provides concrete numerical examples showing:
1. The Schwartz-Zippel bound in action for multivariate polynomials
2. Freivalds' randomized matrix multiplication verification
3. The connection between polynomial identity testing and matrix verification
"""

import random
import numpy as np
from typing import List, Tuple, Dict
from itertools import product


def eval_poly_mod(coefficients: Dict[Tuple[int, ...], int], point: Tuple[int, ...], q: int) -> int:
    """Evaluate a multivariate polynomial at a point over Z/qZ.
    
    Args:
        coefficients: dict mapping exponent tuples to coefficients
        point: tuple of values for each variable
        q: prime modulus
    
    Returns:
        Evaluation mod q
    """
    result = 0
    for exponents, coeff in coefficients.items():
        term = coeff
        for i, exp in enumerate(exponents):
            term = (term * pow(point[i], exp, q)) % q
        result = (result + term) % q
    return result


def count_zeros(coefficients: Dict[Tuple[int, ...], int], n_vars: int, q: int) -> int:
    """Count the number of zeros of a polynomial over (Z/qZ)^n."""
    count = 0
    for point in product(range(q), repeat=n_vars):
        if eval_poly_mod(coefficients, point, q) == 0:
            count += 1
    return count


def schwartz_zippel_bound(total_degree: int, q: int, n_vars: int) -> int:
    """Compute the Schwartz-Zippel upper bound on zeros."""
    return total_degree * q ** (n_vars - 1)


def demo_schwartz_zippel():
    """Demonstrate the Schwartz-Zippel bound with concrete examples."""
    print("=" * 70)
    print("SCHWARTZ-ZIPPEL LEMMA DEMONSTRATION")
    print("=" * 70)
    print()
    print("Theorem: A nonzero polynomial f of total degree d over a finite")
    print("field F_q in n variables has at most d * q^(n-1) zeros.")
    print()
    
    # Example 1: Linear polynomial in 2 variables over F_5
    # f(x,y) = 2x + 3y + 1
    print("-" * 50)
    print("Example 1: f(x,y) = 2x + 3y + 1 over F_5")
    print("-" * 50)
    q = 5
    coeffs = {(1, 0): 2, (0, 1): 3, (0, 0): 1}
    n_vars = 2
    total_deg = 1
    
    zeros = count_zeros(coeffs, n_vars, q)
    bound = schwartz_zippel_bound(total_deg, q, n_vars)
    
    print(f"  Total degree: {total_deg}")
    print(f"  Field size: {q}")
    print(f"  Variables: {n_vars}")
    print(f"  Actual zeros: {zeros}")
    print(f"  S-Z bound:    {bound}")
    print(f"  Bound tight?  {zeros <= bound} (zeros ≤ bound)")
    print()
    
    # Example 2: Quadratic polynomial in 3 variables over F_7
    # f(x,y,z) = x^2 + y*z + x + 2
    print("-" * 50)
    print("Example 2: f(x,y,z) = x² + yz + x + 2 over F_7")
    print("-" * 50)
    q = 7
    coeffs = {(2, 0, 0): 1, (0, 1, 1): 1, (1, 0, 0): 1, (0, 0, 0): 2}
    n_vars = 3
    total_deg = 2
    
    zeros = count_zeros(coeffs, n_vars, q)
    bound = schwartz_zippel_bound(total_deg, q, n_vars)
    
    print(f"  Total degree: {total_deg}")
    print(f"  Field size: {q}")
    print(f"  Variables: {n_vars}")
    print(f"  Actual zeros: {zeros}")
    print(f"  S-Z bound:    {bound}")
    print(f"  Bound tight?  {zeros <= bound} (zeros ≤ bound)")
    print()
    
    # Example 3: Product of linears (tight example)
    # f(x,y) = x * y over F_p (zeros = 2p-1, bound = 2*(p-1)+1 ... let's check)
    print("-" * 50)
    print("Example 3: f(x,y) = x·y over F_11 (near-tight)")
    print("-" * 50)
    q = 11
    coeffs = {(1, 1): 1}
    n_vars = 2
    total_deg = 2
    
    zeros = count_zeros(coeffs, n_vars, q)
    bound = schwartz_zippel_bound(total_deg, q, n_vars)
    
    print(f"  Total degree: {total_deg}")
    print(f"  Field size: {q}")
    print(f"  Variables: {n_vars}")
    print(f"  Actual zeros: {zeros} (= 2·{q} - 1 = {2*q - 1})")
    print(f"  S-Z bound:    {bound}")
    print(f"  Bound tight?  {zeros <= bound} (zeros ≤ bound)")
    print(f"  Ratio actual/bound: {zeros/bound:.3f}")
    print()
    
    # Example 4: Sweep over field sizes
    print("-" * 50)
    print("Example 4: Zero fraction vs 1/q for degree-1 polynomial")
    print("-" * 50)
    print(f"  {'q':>5} | {'zeros':>8} | {'q^(n-1)':>10} | {'fraction':>10} | {'1/q':>10}")
    print(f"  {'-'*5}-+-{'-'*8}-+-{'-'*10}-+-{'-'*10}-+-{'-'*10}")
    
    for q in [2, 3, 5, 7, 11, 13]:
        # f(x,y,z) = x + 2y + 3z + 1 over F_q
        coeffs = {(1, 0, 0): 1, (0, 1, 0): 2, (0, 0, 1): 3, (0, 0, 0): 1}
        n_vars = 3
        total_deg = 1
        zeros = count_zeros(coeffs, n_vars, q)
        bound = q ** (n_vars - 1)
        total = q ** n_vars
        print(f"  {q:>5} | {zeros:>8} | {bound:>10} | {zeros/total:>10.6f} | {1/q:>10.6f}")
    print()


def freivalds_demo():
    """Demonstrate Freivalds' algorithm for matrix multiplication verification."""
    print("=" * 70)
    print("FREIVALDS' ALGORITHM DEMONSTRATION")
    print("=" * 70)
    print()
    print("Algorithm: To verify A·B = C, pick random r ∈ F_q^n,")
    print("check if (A·B)·r = C·r. Error prob ≤ 1/q per trial.")
    print()
    
    random.seed(42)
    np.random.seed(42)
    
    q = 7  # Work over F_7
    n = 4  # 4×4 matrices
    
    # Generate random matrices
    A = np.random.randint(0, q, (n, n))
    B = np.random.randint(0, q, (n, n))
    C_correct = (A @ B) % q
    
    # Create an incorrect C (flip one entry)
    C_wrong = C_correct.copy()
    C_wrong[0, 0] = (C_wrong[0, 0] + 1) % q
    
    print(f"Working over F_{q}, with {n}×{n} matrices")
    print()
    
    # Test with correct C
    print("-" * 50)
    print("Test 1: A·B = C (correct product)")
    print("-" * 50)
    n_trials = 1000
    false_reject = 0
    for _ in range(n_trials):
        r = np.random.randint(0, q, n)
        lhs = (A @ B @ r) % q
        rhs = (C_correct @ r) % q
        if not np.array_equal(lhs % q, rhs % q):
            false_reject += 1
    print(f"  {n_trials} trials: {false_reject} false rejections (should be 0)")
    print()
    
    # Test with incorrect C
    print("-" * 50)
    print("Test 2: A·B ≠ C (incorrect product)")
    print("-" * 50)
    n_trials = 10000
    missed = 0
    for _ in range(n_trials):
        r = np.random.randint(0, q, n)
        lhs = (A @ B @ r) % q
        rhs = (C_wrong @ r) % q
        if np.array_equal(lhs % q, rhs % q):
            missed += 1
    
    empirical_error = missed / n_trials
    theoretical_bound = 1 / q
    print(f"  {n_trials} trials: {missed} false accepts")
    print(f"  Empirical error rate: {empirical_error:.4f}")
    print(f"  Theoretical bound:   {theoretical_bound:.4f} (= 1/{q})")
    print(f"  Bound respected:     {empirical_error <= theoretical_bound + 0.01}")
    print()
    
    # Exact counting over small field
    print("-" * 50)
    print("Test 3: Exact zero count for D = A·B - C over F_3")
    print("-" * 50)
    q_small = 3
    n_small = 3
    
    A_s = np.random.randint(0, q_small, (n_small, n_small))
    B_s = np.random.randint(0, q_small, (n_small, n_small))
    C_s = (A_s @ B_s) % q_small
    C_s[0, 0] = (C_s[0, 0] + 1) % q_small  # Make incorrect
    D = (A_s @ B_s - C_s) % q_small
    
    zero_count = 0
    total = q_small ** n_small
    for r in product(range(q_small), repeat=n_small):
        r_vec = np.array(r)
        result = (D @ r_vec) % q_small
        if np.all(result == 0):
            zero_count += 1
    
    bound = q_small ** (n_small - 1)
    print(f"  D = A·B - C (mod {q_small}), D ≠ 0")
    print(f"  Vectors r with D·r = 0: {zero_count}")
    print(f"  Total vectors:          {total}")
    print(f"  Bound q^(n-1):          {bound}")
    print(f"  Fraction:               {zero_count/total:.4f}")
    print(f"  1/q:                    {1/q_small:.4f}")
    print(f"  Bound respected:        {zero_count <= bound}")
    print()
    
    # Repeated trials
    print("-" * 50)
    print("Test 4: k independent trials reduce error to (1/q)^k")
    print("-" * 50)
    q = 7
    n = 5
    A = np.random.randint(0, q, (n, n))
    B = np.random.randint(0, q, (n, n))
    C = (A @ B) % q
    C[1, 2] = (C[1, 2] + 1) % q  # Corrupt
    
    n_experiments = 10000
    for k in [1, 2, 3, 5, 10]:
        all_pass = 0
        for _ in range(n_experiments):
            passed = True
            for _ in range(k):
                r = np.random.randint(0, q, n)
                if not np.array_equal((A @ B @ r) % q, (C @ r) % q):
                    passed = False
                    break
            if passed:
                all_pass += 1
        empirical = all_pass / n_experiments
        theoretical = (1/q) ** k
        print(f"  k={k:>2}: empirical={empirical:.6f}, bound=(1/{q})^{k}={theoretical:.6f}")
    print()


def pit_connection_demo():
    """Show the PIT interpretation of Freivalds."""
    print("=" * 70)
    print("POLYNOMIAL IDENTITY TESTING CONNECTION")
    print("=" * 70)
    print()
    print("Key insight: For matrices D = A·B - C, the condition D·r = 0")
    print("is equivalent to n linear polynomials vanishing simultaneously.")
    print("Each row of D defines a degree-1 polynomial in the r variables.")
    print()
    
    q = 5
    n = 3
    
    print(f"Example: 3×3 matrix D over F_{q}")
    D = np.array([[1, 2, 3], [0, 4, 1], [2, 0, 3]])
    print(f"  D = {D.tolist()}")
    print()
    
    print("  Row polynomials (degree-1 in r₀, r₁, r₂):")
    for i in range(n):
        terms = []
        for j in range(n):
            if D[i, j] != 0:
                terms.append(f"{D[i,j]}·r_{j}")
        print(f"    p_{i}(r) = {' + '.join(terms)}")
    print()
    
    print("  D·r = 0 iff all row polynomials vanish simultaneously.")
    print("  Each is degree 1, so by Schwartz-Zippel (degree-1 case),")
    print(f"  each vanishes on ≤ {q}^{n-1} = {q**(n-1)} of {q}^{n} = {q**n} vectors.")
    print("  Since row 0 is nonzero, the system vanishes on ≤ q^(n-1) vectors.")
    print()
    
    # Count actual zeros
    zero_count = 0
    for r in product(range(q), repeat=n):
        r_vec = np.array(r)
        if np.all((D @ r_vec) % q == 0):
            zero_count += 1
    print(f"  Actual zeros of D·r = 0: {zero_count}")
    print(f"  Bound q^(n-1) = {q**(n-1)}")
    print(f"  Freivalds error ≤ {zero_count}/{q**n} = {zero_count/q**n:.4f} ≤ 1/{q} = {1/q:.4f}")


if __name__ == "__main__":
    demo_schwartz_zippel()
    print()
    freivalds_demo()
    print()
    pit_connection_demo()


#!/usr/bin/env python3
"""
Visualizations for the Schwartz-Zippel / Freivalds formalization.
Generates PNG figures for the research paper and web package.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import product
import base64
from io import BytesIO


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def plot_zero_set_2d():
    """Plot the zero set of a polynomial over a finite field."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    q = 11
    
    # f(x,y) = x + 2y + 1 (degree 1)
    ax = axes[0]
    zeros_x, zeros_y = [], []
    nonzeros_x, nonzeros_y = [], []
    for x in range(q):
        for y in range(q):
            if (x + 2*y + 1) % q == 0:
                zeros_x.append(x)
                zeros_y.append(y)
            else:
                nonzeros_x.append(x)
                nonzeros_y.append(y)
    ax.scatter(nonzeros_x, nonzeros_y, c='lightblue', s=20, alpha=0.5, label='Nonzero')
    ax.scatter(zeros_x, zeros_y, c='red', s=40, zorder=5, label=f'Zeros ({len(zeros_x)})')
    ax.set_title(f'x + 2y + 1 over F₁₁\nDeg=1, Zeros={len(zeros_x)}, Bound={1*q**(2-1)}')
    ax.set_xlabel('x')
    ax.set_ylabel('y')
    ax.legend(fontsize=8)
    ax.set_aspect('equal')
    
    # f(x,y) = x*y (degree 2)
    ax = axes[1]
    zeros_x, zeros_y = [], []
    nonzeros_x, nonzeros_y = [], []
    for x in range(q):
        for y in range(q):
            if (x * y) % q == 0:
                zeros_x.append(x)
                zeros_y.append(y)
            else:
                nonzeros_x.append(x)
                nonzeros_y.append(y)
    ax.scatter(nonzeros_x, nonzeros_y, c='lightblue', s=20, alpha=0.5, label='Nonzero')
    ax.scatter(zeros_x, zeros_y, c='red', s=40, zorder=5, label=f'Zeros ({len(zeros_x)})')
    ax.set_title(f'x·y over F₁₁\nDeg=2, Zeros={len(zeros_x)}, Bound={2*q**(2-1)}')
    ax.set_xlabel('x')
    ax.set_ylabel('y')
    ax.legend(fontsize=8)
    ax.set_aspect('equal')
    
    # f(x,y) = x^2 + y^2 - 1 (degree 2)
    ax = axes[2]
    zeros_x, zeros_y = [], []
    nonzeros_x, nonzeros_y = [], []
    for x in range(q):
        for y in range(q):
            if (x*x + y*y - 1) % q == 0:
                zeros_x.append(x)
                zeros_y.append(y)
            else:
                nonzeros_x.append(x)
                nonzeros_y.append(y)
    ax.scatter(nonzeros_x, nonzeros_y, c='lightblue', s=20, alpha=0.5, label='Nonzero')
    ax.scatter(zeros_x, zeros_y, c='red', s=40, zorder=5, label=f'Zeros ({len(zeros_x)})')
    ax.set_title(f'x² + y² - 1 over F₁₁\nDeg=2, Zeros={len(zeros_x)}, Bound={2*q**(2-1)}')
    ax.set_xlabel('x')
    ax.set_ylabel('y')
    ax.legend(fontsize=8)
    ax.set_aspect('equal')
    
    fig.suptitle('Zero Sets of Polynomials over Finite Fields', fontsize=14, fontweight='bold')
    plt.tight_layout()
    fig.savefig('viz_zero_sets.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def plot_freivalds_error():
    """Plot Freivalds error probability decay with repeated trials."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    
    trials = np.arange(1, 31)
    
    for q in [2, 3, 5, 7, 11, 101]:
        errors = (1/q) ** trials
        ax.semilogy(trials, errors, 'o-', markersize=4, label=f'q={q}')
    
    ax.set_xlabel('Number of Independent Trials (k)', fontsize=12)
    ax.set_ylabel('Error Probability Upper Bound', fontsize=12)
    ax.set_title("Freivalds' Algorithm: Error Decay with Repeated Trials\n"
                 "Error ≤ (1/q)^k", fontsize=14, fontweight='bold')
    ax.legend(title='Field size q')
    ax.grid(True, alpha=0.3)
    ax.set_ylim(1e-30, 1.5)
    
    # Add annotation
    ax.annotate('Even q=2 gives 2⁻³⁰ ≈ 10⁻⁹\nafter 30 trials',
                xy=(30, 2**(-30)), xytext=(22, 1e-6),
                arrowprops=dict(arrowstyle='->', color='gray'),
                fontsize=10, ha='center')
    
    plt.tight_layout()
    fig.savefig('viz_freivalds_error.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def plot_sz_bound_tightness():
    """Plot how tight the Schwartz-Zippel bound is for various polynomials."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Panel 1: Fixed degree, varying field size
    ax = axes[0]
    primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31]
    
    for deg in [1, 2, 3]:
        ratios = []
        for q in primes:
            # Count zeros of x^deg + y - 1 over F_q^2
            zeros = 0
            for x in range(q):
                for y in range(q):
                    if (pow(x, deg, q) + y - 1) % q == 0:
                        zeros += 1
            bound = deg * q
            ratios.append(zeros / bound if bound > 0 else 0)
        ax.plot(primes, ratios, 'o-', label=f'deg={deg}')
    
    ax.set_xlabel('Field size q', fontsize=12)
    ax.set_ylabel('Actual zeros / S-Z bound', fontsize=12)
    ax.set_title('Tightness: f(x,y) = xᵈ + y - 1', fontsize=12)
    ax.legend()
    ax.set_ylim(0, 1.1)
    ax.axhline(y=1, color='gray', linestyle='--', alpha=0.5)
    ax.grid(True, alpha=0.3)
    
    # Panel 2: Product of linear forms (near-tight examples)
    ax = axes[1]
    primes2 = [3, 5, 7, 11, 13, 17, 19, 23]
    
    for num_factors in [1, 2, 3]:
        ratios = []
        for q in primes2:
            zeros = 0
            for x, y in product(range(q), repeat=2):
                val = 1
                for k in range(num_factors):
                    val = (val * (x + (k+1)*y)) % q
                if val == 0:
                    zeros += 1
            bound = num_factors * q
            ratios.append(zeros / bound if bound > 0 else 0)
        ax.plot(primes2, ratios, 's-', label=f'{num_factors} linear factor(s)')
    
    ax.set_xlabel('Field size q', fontsize=12)
    ax.set_ylabel('Actual zeros / S-Z bound', fontsize=12)
    ax.set_title('Tightness: Products of Linear Forms', fontsize=12)
    ax.legend()
    ax.set_ylim(0, 1.1)
    ax.axhline(y=1, color='gray', linestyle='--', alpha=0.5)
    ax.grid(True, alpha=0.3)
    
    fig.suptitle('Schwartz-Zippel Bound Tightness Analysis', fontsize=14, fontweight='bold')
    plt.tight_layout()
    fig.savefig('viz_sz_tightness.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def plot_theorem_dependency():
    """Create a diagram showing the theorem dependency structure."""
    fig, ax = plt.subplots(1, 1, figsize=(12, 8))
    ax.set_xlim(0, 12)
    ax.set_ylim(0, 10)
    ax.axis('off')
    
    # Define boxes
    boxes = {
        'root_bound': (6, 9, 'Univariate Root Bound\n(Polynomial.card_roots\')', '#E8F5E9'),
        'fiber_eval': (2, 7, 'Fiber Evaluation\n(eval_fiberPoly)', '#E3F2FD'),
        'fiber_deg': (6, 7, 'Fiber Degree Bound\n(natDegree_fiberPoly_le)', '#E3F2FD'),
        'sz_one': (10, 7, 'Base Case\n(schwartz_zippel_one)', '#FFF3E0'),
        'sz_succ': (6, 5, 'SCHWARTZ-ZIPPEL\n(schwartz_zippel_succ)', '#FFEBEE'),
        'linear_form': (2, 3.5, 'Linear Form Bound\n(nonzero_linear_form_\nzero_set_bound)', '#F3E5F5'),
        'freivalds_disc': (6, 3, 'Freivalds Discrepancy\n(freivalds_discrepancy_bound)', '#FCE4EC'),
        'freivalds': (10, 3, 'Freivalds Bound\n(freivalds_bound)', '#FCE4EC'),
        'sz_zmod': (6, 1.5, 'S-Z over ZMod q\n(schwartz_zippel_zmod)', '#FFF9C4'),
        'prob': (2, 1.5, 'Error Probability\n(freivalds_error_probability)', '#FFF9C4'),
    }
    
    for key, (x, y, text, color) in boxes.items():
        w, h = 2.8, 1.2
        rect = plt.Rectangle((x - w/2, y - h/2), w, h, 
                             facecolor=color, edgecolor='black', linewidth=1.5,
                             zorder=2, transform=ax.transData)
        ax.add_patch(rect)
        fontsize = 7 if '\n' in text and text.count('\n') > 1 else 8
        ax.text(x, y, text, ha='center', va='center', fontsize=fontsize,
               fontweight='bold' if key in ['sz_succ', 'freivalds_disc'] else 'normal',
               zorder=3)
    
    # Draw arrows
    arrows = [
        ('root_bound', 'sz_one'),
        ('fiber_eval', 'sz_succ'),
        ('fiber_deg', 'sz_succ'),
        ('sz_one', 'sz_succ'),
        ('sz_succ', 'sz_zmod'),
        ('linear_form', 'freivalds_disc'),
        ('freivalds_disc', 'freivalds'),
        ('freivalds_disc', 'prob'),
    ]
    
    for src, dst in arrows:
        sx, sy = boxes[src][0], boxes[src][1]
        dx, dy = boxes[dst][0], boxes[dst][1]
        ax.annotate('', xy=(dx, dy + 0.6), xytext=(sx, sy - 0.6),
                    arrowprops=dict(arrowstyle='->', color='gray', lw=1.5),
                    zorder=1)
    
    ax.set_title('Theorem Dependency Graph\nSchwartz-Zippel → Freivalds Pipeline', 
                fontsize=14, fontweight='bold')
    
    plt.tight_layout()
    fig.savefig('viz_theorem_deps.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


if __name__ == "__main__":
    print("Generating visualizations...")
    
    b64_zeros = plot_zero_set_2d()
    print(f"  viz_zero_sets.png generated ({len(b64_zeros)} chars)")
    
    b64_error = plot_freivalds_error()
    print(f"  viz_freivalds_error.png generated ({len(b64_error)} chars)")
    
    b64_tight = plot_sz_bound_tightness()
    print(f"  viz_sz_tightness.png generated ({len(b64_tight)} chars)")
    
    b64_deps = plot_theorem_dependency()
    print(f"  viz_theorem_deps.png generated ({len(b64_deps)} chars)")
    
    print("Done!")
