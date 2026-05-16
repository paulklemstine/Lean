"""
Applications of Freivalds' Theorem and Finite-Field Hyperplane Counting

This module demonstrates real-world applications of the mathematical results:
1. Verifiable outsourced computation
2. Streaming data integrity
3. Error-correcting code construction
4. Polynomial identity testing (PIT)
"""

import numpy as np
import random
from typing import List, Tuple


class VerifiableMatrixComputation:
    """
    Simulate outsourced matrix computation with Freivalds verification.

    A "server" computes A*B and the "client" verifies using O(n^2) work
    instead of O(n^3). Demonstrates the practical value of the 1/q bound.
    """

    def __init__(self, q: int = 1009):
        """Initialize with prime field size q."""
        self.q = q

    def client_verify(
        self,
        A: np.ndarray,
        B: np.ndarray,
        claimed_result: np.ndarray,
        security_parameter: int = 40
    ) -> Tuple[bool, float, int]:
        """
        Client-side verification of outsourced matrix multiplication.

        Args:
            A, B: input matrices
            claimed_result: server's claimed A*B
            security_parameter: desired bits of security (log2 of 1/error_prob)

        Returns:
            (accepted, error_bound, num_trials)
        """
        import math
        q = self.q
        # Number of trials needed: t such that q^(-t) <= 2^(-security_parameter)
        num_trials = math.ceil(security_parameter * math.log(2) / math.log(q))
        p = B.shape[1]

        for _ in range(num_trials):
            r = np.array([random.randint(0, q - 1) for _ in range(p)],
                         dtype=np.int64)
            Kr = (claimed_result @ r) % q
            Br = (B @ r) % q
            ABr = (A @ Br) % q
            if not np.array_equal(Kr, ABr):
                return False, 0.0, num_trials

        error_bound = (1 / q) ** num_trials
        return True, error_bound, num_trials

    def demo(self):
        """Run a complete outsourced computation demo."""
        print("=" * 60)
        print("APPLICATION 1: Verifiable Outsourced Computation")
        print("=" * 60)

        n = 50
        q = self.q
        A = np.random.randint(0, q, (n, n)).astype(np.int64)
        B = np.random.randint(0, q, (n, n)).astype(np.int64)

        # Honest server
        correct = (A @ B) % q
        accepted, err, trials = self.client_verify(A, B, correct, security_parameter=40)
        print(f"\nField: Z/{q}Z, Matrix size: {n}x{n}")
        print(f"Honest server result:")
        print(f"  Accepted: {accepted}")
        print(f"  Error bound: {err:.2e}")
        print(f"  Trials used: {trials}")
        print(f"  Client work: O({trials} * {n}^2) = O({trials * n * n})")
        print(f"  vs. direct verification: O({n}^3) = O({n**3})")

        # Malicious server (single entry error)
        wrong = correct.copy()
        wrong[n // 2, n // 2] = (wrong[n // 2, n // 2] + 1) % q
        accepted, err, trials = self.client_verify(A, B, wrong, security_parameter=40)
        print(f"\nMalicious server (1 entry wrong):")
        print(f"  Accepted: {accepted}")
        print(f"  Caught the error: {not accepted}")


class StreamingEqualityTest:
    """
    Test equality of data streams using random linear fingerprints.

    Two parties each have a stream of n field elements. They want to check
    equality using only O(1) communication, not O(n).
    """

    def __init__(self, q: int = 1000003):
        self.q = q

    def fingerprint(self, data: List[int]) -> int:
        """Compute random linear fingerprint: sum_i r_i * data_i mod q."""
        n = len(data)
        # Use seeded randomness so both parties use the same r
        r = [random.randint(0, self.q - 1) for _ in range(n)]
        return sum(r[i] * data[i] for i in range(n)) % self.q

    def demo(self):
        """Demonstrate streaming equality testing."""
        print("\n" + "=" * 60)
        print("APPLICATION 2: Streaming Equality Testing")
        print("=" * 60)

        q = self.q
        n = 10000

        # Two identical streams
        stream1 = [random.randint(0, q - 1) for _ in range(n)]
        stream2 = list(stream1)  # Copy

        print(f"\nField: Z/{q}Z, Stream length: {n}")
        print(f"Communication without fingerprinting: {n} field elements")
        print(f"Communication with fingerprinting: 1 field element")

        # Test identical streams
        collisions = 0
        trials = 10000
        for _ in range(trials):
            random.seed(random.randint(0, 10**9))
            f1 = self.fingerprint(stream1)
            f2 = self.fingerprint(stream2)
            if f1 != f2:
                collisions += 1  # Should never happen for equal streams

        print(f"\nEqual streams: {collisions}/{trials} false rejections (expected: 0)")

        # Test different streams (differ in one position)
        stream2_diff = list(stream1)
        stream2_diff[n // 2] = (stream2_diff[n // 2] + 1) % q

        mismatches = 0
        for _ in range(trials):
            seed = random.randint(0, 10**9)
            random.seed(seed)
            f1 = self.fingerprint(stream1)
            random.seed(seed)  # Same randomness
            f2 = self.fingerprint(stream2_diff)
            if f1 != f2:
                mismatches += 1

        print(f"Different streams: {mismatches}/{trials} detected")
        print(f"  Detection rate: {mismatches/trials:.4f}")
        print(f"  Theoretical lower bound: {1 - 1/q:.4f}")


class LinearCodeFromHyperplane:
    """
    Construct a linear code from the hyperplane counting theorem.

    The kernel of a nonzero linear functional w: F_q^p -> F_q is a
    [p, p-1, 2]_q linear code (a single parity check code).
    """

    def __init__(self, q: int, p: int, w: List[int]):
        self.q = q
        self.p = p
        self.w = np.array(w, dtype=np.int64)
        assert any(x % q != 0 for x in w), "w must be nonzero"

    def is_codeword(self, v: np.ndarray) -> bool:
        """Check if v is in the code (kernel of w)."""
        return int(np.dot(self.w, v)) % self.q == 0

    def encode(self, message: np.ndarray) -> np.ndarray:
        """
        Encode a message of length p-1 into a codeword of length p.

        Find the last coordinate so that w·codeword = 0.
        """
        assert len(message) == self.p - 1

        # Find a nonzero coordinate in w
        j = next(i for i in range(self.p) if self.w[i] % self.q != 0)

        # Place message in positions != j
        codeword = np.zeros(self.p, dtype=np.int64)
        idx = 0
        for i in range(self.p):
            if i != j:
                codeword[i] = message[idx] % self.q
                idx += 1

        # Solve for position j: w[j] * codeword[j] = -sum_{i!=j} w[i]*codeword[i]
        partial_sum = sum(self.w[i] * codeword[i] for i in range(self.p) if i != j) % self.q
        w_j_inv = pow(int(self.w[j]), self.q - 2, self.q)
        codeword[j] = ((-partial_sum) * w_j_inv) % self.q

        return codeword

    def detect_error(self, received: np.ndarray) -> bool:
        """Detect if a received word has been corrupted."""
        return not self.is_codeword(received)

    def demo(self):
        """Demonstrate linear code properties."""
        print("\n" + "=" * 60)
        print("APPLICATION 3: Linear Code from Hyperplane Counting")
        print("=" * 60)

        q, p = self.q, self.p
        print(f"\nCode parameters: [{p}, {p-1}, 2]_{q}")
        print(f"Parity check vector: w = {self.w}")
        print(f"Code size: {q}^{p-1} = {q**(p-1)} codewords")
        print(f"Ambient space: {q}^{p} = {q**p} vectors")
        print(f"Code rate: {(p-1)/p:.4f}")

        # Encode some messages
        for _ in range(3):
            msg = np.array([random.randint(0, q - 1) for _ in range(p - 1)],
                           dtype=np.int64)
            codeword = self.encode(msg)
            print(f"\n  Message:  {msg}")
            print(f"  Codeword: {codeword}")
            print(f"  w·c = {int(np.dot(self.w, codeword)) % q} (should be 0)")

            # Introduce error
            corrupted = codeword.copy()
            err_pos = random.randint(0, p - 1)
            corrupted[err_pos] = (corrupted[err_pos] + random.randint(1, q - 1)) % q
            detected = self.detect_error(corrupted)
            print(f"  Corrupted at position {err_pos}: {corrupted}")
            print(f"  Error detected: {detected}")


class PolynomialIdentityTest:
    """
    Polynomial Identity Testing (PIT) over finite fields.

    Demonstrates that Freivalds' algorithm is the degree-1 case of
    the Schwartz-Zippel identity test.
    """

    def __init__(self, q: int):
        self.q = q

    def evaluate_polynomial(
        self,
        coefficients: dict,
        point: np.ndarray
    ) -> int:
        """
        Evaluate a multivariate polynomial at a point over Z/qZ.

        Args:
            coefficients: dict mapping tuples of exponents to coefficients
                         e.g., {(1,0,0): 3, (0,1,0): 5} represents 3x + 5y
            point: evaluation point

        Returns:
            polynomial value mod q
        """
        result = 0
        for exponents, coeff in coefficients.items():
            term = coeff
            for i, exp in enumerate(exponents):
                term = (term * pow(int(point[i]), exp, self.q)) % self.q
            result = (result + term) % self.q
        return result

    def schwartz_zippel_test(
        self,
        poly: dict,
        num_vars: int,
        num_trials: int = 1
    ) -> bool:
        """
        Test if a polynomial is identically zero using Schwartz-Zippel.

        Returns True if the polynomial appears to be zero (all evaluations are 0),
        False if a nonzero evaluation is found.
        """
        for _ in range(num_trials):
            point = np.array([random.randint(0, self.q - 1)
                              for _ in range(num_vars)], dtype=np.int64)
            if self.evaluate_polynomial(poly, point) != 0:
                return False
        return True

    def demo(self):
        """Demonstrate PIT and its connection to Freivalds."""
        print("\n" + "=" * 60)
        print("APPLICATION 4: Polynomial Identity Testing (PIT)")
        print("=" * 60)

        q = self.q
        n = 3  # 3 variables

        # Zero polynomial
        zero_poly = {}
        print(f"\nField: Z/{q}Z, Variables: {n}")
        print(f"\nTest 1: Zero polynomial")
        result = self.schwartz_zippel_test(zero_poly, n, num_trials=10)
        print(f"  Identified as zero: {result} (correct: True)")

        # Nonzero linear polynomial: 2x + 3y + z
        linear_poly = {(1, 0, 0): 2, (0, 1, 0): 3, (0, 0, 1): 1}
        print(f"\nTest 2: Linear polynomial 2x + 3y + z")
        trials = 10000
        zeros = sum(
            1 for _ in range(trials)
            if self.schwartz_zippel_test(linear_poly, n, num_trials=1)
        )
        print(f"  Evaluates to zero: {zeros}/{trials}")
        print(f"  Rate: {zeros/trials:.4f} (theoretical bound: {1/q:.4f})")
        print(f"  This IS Freivalds' bound for degree-1 polynomials!")

        # Nonzero quadratic: x^2 + y^2 + z^2 - 1
        quad_poly = {
            (2, 0, 0): 1, (0, 2, 0): 1, (0, 0, 2): 1, (0, 0, 0): q - 1
        }
        print(f"\nTest 3: Quadratic polynomial x^2 + y^2 + z^2 - 1")
        zeros = sum(
            1 for _ in range(trials)
            if self.schwartz_zippel_test(quad_poly, n, num_trials=1)
        )
        print(f"  Evaluates to zero: {zeros}/{trials}")
        print(f"  Rate: {zeros/trials:.4f} (Schwartz-Zippel bound: {2/q:.4f})")


if __name__ == "__main__":
    random.seed(42)
    np.random.seed(42)

    # Run all application demos
    VerifiableMatrixComputation(q=1009).demo()
    StreamingEqualityTest(q=1009).demo()
    LinearCodeFromHyperplane(q=7, p=5, w=[1, 2, 3, 4, 5]).demo()
    PolynomialIdentityTest(q=101).demo()

    print("\n" + "=" * 60)
    print("All application demos complete.")
    print("=" * 60)


"""
Freivalds' Matrix Verification Algorithm — Interactive Demonstrations

This module demonstrates the core mathematical results of Freivalds' theorem
through concrete numerical examples over finite fields ZMod q.
"""

import numpy as np
from typing import Tuple
import random


def mod_matrix_multiply(A: np.ndarray, B: np.ndarray, q: int) -> np.ndarray:
    """Multiply matrices over Z/qZ."""
    return (A @ B) % q


def freivalds_test(A: np.ndarray, B: np.ndarray, K: np.ndarray, q: int) -> bool:
    """
    Run one Freivalds test: check K·r == A·(B·r) mod q for random r.
    Returns True if the test accepts (vectors match), False if it rejects.
    """
    p = B.shape[1]
    r = np.array([random.randint(0, q - 1) for _ in range(p)])
    lhs = (K @ r) % q
    rhs = (A @ ((B @ r) % q)) % q
    return np.array_equal(lhs, rhs)


def demo_basic_verification():
    """Demonstrate basic Freivalds verification with a simple example."""
    print("=" * 70)
    print("DEMO 1: Basic Freivalds Verification")
    print("=" * 70)

    q = 7  # Work over Z/7Z

    # Create small matrices
    A = np.array([[1, 2], [3, 4]], dtype=np.int64)
    B = np.array([[5, 6], [0, 1]], dtype=np.int64)
    correct_product = mod_matrix_multiply(A, B, q)

    print(f"\nField: Z/{q}Z")
    print(f"A = \n{A}")
    print(f"B = \n{B}")
    print(f"A*B mod {q} = \n{correct_product}")

    # Test with correct product
    print("\n--- Testing with CORRECT product ---")
    accepts = sum(freivalds_test(A, B, correct_product, q) for _ in range(1000))
    print(f"  Accepted {accepts}/1000 trials (expected: 1000/1000)")

    # Test with incorrect product (perturb one entry)
    wrong_product = correct_product.copy()
    wrong_product[0, 0] = (wrong_product[0, 0] + 1) % q
    print(f"\nWrong product (entry [0,0] perturbed):\n{wrong_product}")

    print("\n--- Testing with WRONG product ---")
    accepts = sum(freivalds_test(A, B, wrong_product, q) for _ in range(1000))
    theoretical = 1000 / q
    print(f"  Accepted {accepts}/1000 trials")
    print(f"  Theoretical upper bound: {theoretical:.1f}/1000 (= 1/{q} of trials)")
    print(f"  Empirical acceptance rate: {accepts/1000:.4f}")
    print(f"  Theoretical bound: {1/q:.4f}")


def demo_hyperplane_counting():
    """Demonstrate exact hyperplane counting over finite fields."""
    print("\n" + "=" * 70)
    print("DEMO 2: Hyperplane Counting — The Heart of the Theorem")
    print("=" * 70)

    q = 5
    p = 3  # 3-dimensional space over Z/5Z

    # Nonzero vector w
    w = np.array([1, 2, 3], dtype=np.int64)
    print(f"\nField: Z/{q}Z, Dimension: {p}")
    print(f"Linear functional: w = {w}")
    print(f"Total space size: {q}^{p} = {q**p}")
    print(f"Predicted hyperplane size: {q}^({p}-1) = {q**(p-1)}")

    # Count solutions to <w, r> = b for each b
    for b in range(q):
        count = 0
        for r0 in range(q):
            for r1 in range(q):
                for r2 in range(q):
                    r = np.array([r0, r1, r2])
                    if np.dot(w, r) % q == b:
                        count += 1
        print(f"  |{{r : <w,r> = {b} mod {q}}}| = {count}  (predicted: {q**(p-1)})")


def demo_amplification():
    """Demonstrate error probability amplification with repeated trials."""
    print("\n" + "=" * 70)
    print("DEMO 3: Amplification — Repeated Trials Crush Error Probability")
    print("=" * 70)

    q = 5
    n = 8  # 8x8 matrices

    A = np.random.randint(0, q, (n, n)).astype(np.int64)
    B = np.random.randint(0, q, (n, n)).astype(np.int64)
    K = mod_matrix_multiply(A, B, q)
    K[0, 0] = (K[0, 0] + 1) % q  # Introduce error

    num_experiments = 50000

    print(f"\nField: Z/{q}Z, Matrix dimension: {n}x{n}")
    print(f"Running {num_experiments} experiments for each trial count t...\n")
    print(f"{'Trials t':<12} {'Empirical Pr[all accept]':<28} {'Theoretical bound (1/q^t)':<25}")
    print("-" * 65)

    for t in [1, 2, 3, 5, 8]:
        false_accepts = 0
        for _ in range(num_experiments):
            all_accept = all(freivalds_test(A, B, K, q) for _ in range(t))
            if all_accept:
                false_accepts += 1
        empirical = false_accepts / num_experiments
        theoretical = (1 / q) ** t
        print(f"  {t:<10} {empirical:<28.6f} {theoretical:<25.10f}")


def demo_rank_sensitivity():
    """Demonstrate how error detection improves with higher-rank errors."""
    print("\n" + "=" * 70)
    print("DEMO 4: Rank Sensitivity — Higher Rank = Better Detection")
    print("=" * 70)

    q = 7
    n = 6
    num_trials = 50000

    A = np.random.randint(0, q, (n, n)).astype(np.int64)
    B = np.random.randint(0, q, (n, n)).astype(np.int64)
    correct = mod_matrix_multiply(A, B, q)

    print(f"\nField: Z/{q}Z, Matrix dimension: {n}x{n}")
    print(f"Running {num_trials} Freivalds tests for each error rank...\n")
    print(f"{'Error rank':<14} {'Empirical accept rate':<25} {'Theoretical bound 1/q^r':<25}")
    print("-" * 65)

    for rank in [1, 2, 3, 4]:
        # Create error matrix of specified rank
        K = correct.copy()
        # Add a rank-r perturbation
        for _ in range(rank):
            u = np.random.randint(0, q, n).astype(np.int64)
            v = np.random.randint(0, q, n).astype(np.int64)
            K = (K + np.outer(u, v)) % q

        # Make sure K != correct
        if np.array_equal(K, correct):
            K[0, 0] = (K[0, 0] + 1) % q

        accepts = sum(freivalds_test(A, B, K, q) for _ in range(num_trials))
        empirical = accepts / num_trials
        theoretical = (1 / q) ** min(rank, n)
        print(f"  {rank:<12} {empirical:<25.6f} {theoretical:<25.10f}")


def demo_solution_set_structure():
    """Show that solution sets are cosets (translates) of the kernel."""
    print("\n" + "=" * 70)
    print("DEMO 5: Coset Structure — All Fibers Have Equal Size")
    print("=" * 70)

    q = 3
    p = 4
    w = np.array([1, 0, 2, 1], dtype=np.int64)

    print(f"\nField: Z/{q}Z, Dimension: {p}")
    print(f"Linear functional: w = {w}")

    # Find kernel
    kernel = []
    fibers = {b: [] for b in range(q)}

    for r0 in range(q):
        for r1 in range(q):
            for r2 in range(q):
                for r3 in range(q):
                    r = np.array([r0, r1, r2, r3])
                    val = np.dot(w, r) % q
                    fibers[val].append(tuple(r))
                    if val == 0:
                        kernel.append(tuple(r))

    print(f"\nKernel (w·r = 0): {len(kernel)} elements")
    print(f"  First few: {kernel[:5]}...")

    for b in range(q):
        print(f"Fiber (w·r = {b}): {len(fibers[b])} elements")

    print(f"\nAll fibers have size {q**(p-1)} = {q}^({p}-1)")
    print("This confirms the coset structure: each fiber is a translate of the kernel.")


if __name__ == "__main__":
    random.seed(42)
    np.random.seed(42)

    demo_basic_verification()
    demo_hyperplane_counting()
    demo_amplification()
    demo_rank_sensitivity()
    demo_solution_set_structure()

    print("\n" + "=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)


"""
Visualizations for Freivalds' Theorem and Finite-Field Hyperplane Counting

Generates matplotlib figures showing:
1. Error probability vs field size
2. Amplification curves
3. Hyperplane structure in F_q^2
4. Kernel density comparison across ranks
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import random
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


def plot_error_probability_vs_field_size():
    """Plot the 1/q error probability bound for various field sizes."""
    fig, ax = plt.subplots(figsize=(10, 6))

    primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47,
              53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101]

    error_probs = [1/q for q in primes]

    ax.semilogy(primes, error_probs, 'bo-', markersize=6, linewidth=2,
                label='Error probability = 1/q')
    ax.fill_between(primes, error_probs, alpha=0.15, color='blue')

    ax.set_xlabel('Field size q (prime)', fontsize=14)
    ax.set_ylabel('Error probability (log scale)', fontsize=14)
    ax.set_title("Freivalds' Error Probability vs. Field Size", fontsize=16)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(bottom=0.005)

    # Annotate key points
    ax.annotate(f'q=2: 50% error', xy=(2, 0.5), xytext=(10, 0.45),
                fontsize=10, arrowprops=dict(arrowstyle='->', color='red'),
                color='red')
    ax.annotate(f'q=101: <1% error', xy=(101, 1/101), xytext=(70, 0.003),
                fontsize=10, arrowprops=dict(arrowstyle='->', color='green'),
                color='green')

    return fig_to_base64(fig)


def plot_amplification_curves():
    """Plot error probability decay with repeated trials."""
    fig, ax = plt.subplots(figsize=(10, 6))

    trials = np.arange(1, 21)
    for q, color, label in [(2, 'red', 'q = 2 (binary)'),
                             (5, 'orange', 'q = 5'),
                             (11, 'green', 'q = 11'),
                             (101, 'blue', 'q = 101')]:
        probs = [(1/q)**t for t in trials]
        ax.semilogy(trials, probs, 'o-', color=color, markersize=5,
                    linewidth=2, label=label)

    ax.set_xlabel('Number of trials t', fontsize=14)
    ax.set_ylabel('Error probability (1/q)^t', fontsize=14)
    ax.set_title('Exponential Amplification of Freivalds\' Algorithm', fontsize=16)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)
    ax.axhline(y=2**(-128), color='purple', linestyle='--', alpha=0.5)
    ax.text(15, 2**(-120), '128-bit security', fontsize=10, color='purple')

    return fig_to_base64(fig)


def plot_hyperplane_structure():
    """Visualize affine hyperplanes in F_q^2."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    q = 7
    w = np.array([1, 3])  # Linear functional

    for idx, b in enumerate([0, 1, 2]):
        ax = axes[idx]
        # Plot all points
        for x in range(q):
            for y in range(q):
                val = (w[0] * x + w[1] * y) % q
                if val == b:
                    ax.plot(x, y, 'ro', markersize=10, zorder=5)
                else:
                    ax.plot(x, y, 'k.', markersize=3, alpha=0.3)

        ax.set_title(f'Hyperplane: x + 3y ≡ {b} (mod {q})', fontsize=12)
        ax.set_xlabel('x')
        ax.set_ylabel('y')
        ax.set_xlim(-0.5, q - 0.5)
        ax.set_ylim(-0.5, q - 0.5)
        ax.set_aspect('equal')
        ax.grid(True, alpha=0.2)

        # Count and display
        count = sum(1 for x in range(q) for y in range(q)
                    if (w[0]*x + w[1]*y) % q == b)
        ax.text(0.5, -0.12, f'{count} points (= q = {q})',
                transform=ax.transAxes, ha='center', fontsize=10,
                color='red', fontweight='bold')

    fig.suptitle(f'Equal-Sized Fibers in F_{q}²: Each Hyperplane Has q = {q} Points',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()

    return fig_to_base64(fig)


def plot_kernel_density_by_rank():
    """Compare kernel sizes for matrices of different ranks."""
    fig, ax = plt.subplots(figsize=(10, 6))

    q = 5
    p = 6  # Dimension

    ranks = list(range(1, p + 1))
    kernel_sizes = [q**(p - r) for r in ranks]
    total = q**p
    densities = [k / total for k in kernel_sizes]
    bounds = [1/q for _ in ranks]  # Freivalds bound (worst case)

    bars = ax.bar(ranks, densities, color=['#e74c3c' if r == 1 else '#3498db'
                                            for r in ranks],
                  alpha=0.8, label='Actual kernel density q^{-rank}')
    ax.axhline(y=1/q, color='red', linestyle='--', linewidth=2,
               label=f'Freivalds bound = 1/q = {1/q:.2f}')

    ax.set_xlabel('Matrix rank', fontsize=14)
    ax.set_ylabel('Kernel density |ker|/|V|', fontsize=14)
    ax.set_title(f'Kernel Density vs. Matrix Rank (q={q}, p={p})', fontsize=16)
    ax.set_xticks(ranks)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3, axis='y')

    # Add values on bars
    for bar, density in zip(bars, densities):
        ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.005,
                f'{density:.4f}', ha='center', fontsize=10)

    return fig_to_base64(fig)


def plot_empirical_vs_theoretical():
    """Plot empirical rejection rates vs theoretical bounds."""
    fig, ax = plt.subplots(figsize=(10, 6))

    random.seed(42)
    np.random.seed(42)

    primes = [2, 3, 5, 7, 11, 13, 17, 23, 29, 31]
    theoretical = [1/q for q in primes]
    empirical = []

    for q in primes:
        n = 8
        A = np.random.randint(0, q, (n, n)).astype(np.int64)
        B = np.random.randint(0, q, (n, n)).astype(np.int64)
        K = (A @ B) % q
        K[0, 0] = (K[0, 0] + 1) % q

        accepts = 0
        num_trials = 20000
        for _ in range(num_trials):
            r = np.array([random.randint(0, q-1) for _ in range(n)], dtype=np.int64)
            Kr = (K @ r) % q
            ABr = (A @ ((B @ r) % q)) % q
            if np.array_equal(Kr, ABr):
                accepts += 1
        empirical.append(accepts / num_trials)

    ax.plot(primes, theoretical, 'rs-', markersize=8, linewidth=2,
            label='Theoretical bound 1/q')
    ax.plot(primes, empirical, 'bo-', markersize=8, linewidth=2,
            label='Empirical acceptance rate')

    ax.set_xlabel('Field size q', fontsize=14)
    ax.set_ylabel('Acceptance probability', fontsize=14)
    ax.set_title('Empirical vs. Theoretical Error Probability', fontsize=16)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)

    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")

    imgs = {
        'error_probability': plot_error_probability_vs_field_size(),
        'amplification': plot_amplification_curves(),
        'hyperplane_structure': plot_hyperplane_structure(),
        'kernel_density': plot_kernel_density_by_rank(),
        'empirical_vs_theoretical': plot_empirical_vs_theoretical(),
    }

    for name, data_uri in imgs.items():
        # Save as standalone files too
        img_data = base64.b64decode(data_uri.split(',')[1])
        with open(f'{name}.png', 'wb') as f:
            f.write(img_data)
        print(f"  Saved {name}.png ({len(img_data)} bytes)")

    print("All visualizations generated.")
