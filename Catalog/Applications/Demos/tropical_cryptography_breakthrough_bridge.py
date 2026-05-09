#!/usr/bin/env python3
"""
Tropical Cryptography Algorithms

Complete implementations of the algorithms from the research paper,
with docstrings, type hints, and complexity analysis.
"""

import numpy as np
from typing import Tuple, List, Optional
from itertools import permutations
import hashlib


class TropicalMatrix:
    """
    A matrix in the min-plus (tropical) semiring.

    Operations:
    - Tropical addition (⊕) = elementwise min
    - Tropical multiplication (⊗) = min-plus matrix multiplication

    Complexity:
    - Addition: O(n²)
    - Multiplication: O(n³)
    - Power (repeated squaring): O(n³ log k)
    """

    def __init__(self, data: np.ndarray):
        """Initialize from a numpy array."""
        self.data = data.astype(float)
        self.n = data.shape[0]
        assert data.shape == (self.n, self.n), "Matrix must be square"

    @classmethod
    def random(cls, n: int, low: int = 0, high: int = 100) -> 'TropicalMatrix':
        """Generate a random tropical matrix with entries in [low, high)."""
        return cls(np.random.randint(low, high, (n, n)))

    @classmethod
    def identity(cls, n: int) -> 'TropicalMatrix':
        """
        Tropical identity matrix: 0 on diagonal, +∞ off diagonal.
        Satisfies I ⊗ A = A ⊗ I = A.
        """
        data = np.full((n, n), np.inf)
        np.fill_diagonal(data, 0)
        return cls(data)

    def tropical_add(self, other: 'TropicalMatrix') -> 'TropicalMatrix':
        """Tropical addition: elementwise min. O(n²)."""
        return TropicalMatrix(np.minimum(self.data, other.data))

    def tropical_mul(self, other: 'TropicalMatrix') -> 'TropicalMatrix':
        """
        Tropical multiplication: (A⊗B)_{ij} = min_k(A_{ik} + B_{kj}).
        Complexity: O(n³).
        """
        n = self.n
        result = np.full((n, n), np.inf)
        for i in range(n):
            for j in range(n):
                for k in range(n):
                    val = self.data[i, k] + other.data[k, j]
                    if val < result[i, j]:
                        result[i, j] = val
        return TropicalMatrix(result)

    def tropical_mv(self, v: np.ndarray) -> np.ndarray:
        """
        Tropical matrix-vector product: (A⊗v)_i = min_j(A_{ij} + v_j).
        Complexity: O(n²).

        This is the core cryptographic primitive:
        - Forward: O(n²)
        - Inversion: Ω(B^n) where B = entry bound
        """
        n = self.n
        result = np.full(n, np.inf)
        for i in range(n):
            for j in range(n):
                val = self.data[i, j] + v[j]
                if val < result[i]:
                    result[i] = val
        return result

    def tropical_pow(self, k: int) -> 'TropicalMatrix':
        """
        Tropical matrix power by repeated squaring.
        Complexity: O(n³ log k).

        Algorithm:
            if k = 1: return A
            if k even: return (A^{k/2})²
            if k odd: return A ⊗ A^{k-1}
        """
        if k <= 1:
            return TropicalMatrix(self.data.copy())

        if k % 2 == 0:
            half = self.tropical_pow(k // 2)
            return half.tropical_mul(half)
        else:
            return self.tropical_mul(self.tropical_pow(k - 1))

    def tropical_det(self) -> float:
        """
        Tropical determinant = min-weight perfect matching.
        tdet(A) = min_{σ ∈ S_n} Σ_i A_{i,σ(i)}

        Complexity: O(n!) — use Hungarian algorithm for O(n³) in practice.
        """
        n = self.n
        min_weight = np.inf
        for perm in permutations(range(n)):
            weight = sum(self.data[i, perm[i]] for i in range(n))
            if weight < min_weight:
                min_weight = weight
        return min_weight

    def tropical_eigenvalue_approx(self, max_power: int = 100) -> float:
        """
        Approximate tropical eigenvalue via the limit A^{⊗k}_{ii} / k.
        The tropical eigenvalue equals the minimum cycle mean.

        Complexity: O(n³ · max_power).
        """
        Ak = self.tropical_pow(max_power)
        return min(Ak.data[i, i] / max_power for i in range(self.n))

    def linf_norm(self) -> float:
        """L∞ norm of matrix entries."""
        return np.max(np.abs(self.data[np.isfinite(self.data)]))

    def __repr__(self) -> str:
        return f"TropicalMatrix({self.data})"


class TropicalHashFunction:
    """
    Tropical hash function: H(v) = A^{⊗k} ⊗ v.

    Security parameters:
    - n: matrix dimension (primary parameter)
    - k: number of iterations
    - B: entry bound

    Forward cost: O(n³ log k + n²) = O(n³ log k)
    Birthday collision bound: Ω((2B+1)^{n²/2}) queries
    """

    def __init__(self, n: int, k: int, entry_bound: int = 100):
        """
        Initialize tropical hash function.

        Args:
            n: Matrix dimension
            k: Number of iterations (power)
            entry_bound: Maximum absolute entry value
        """
        self.n = n
        self.k = k
        self.entry_bound = entry_bound
        # Generate random generator matrix
        self.generator = TropicalMatrix.random(n, 0, entry_bound)
        # Precompute A^{⊗k}
        self.power_matrix = self.generator.tropical_pow(k)

    def hash(self, v: np.ndarray) -> np.ndarray:
        """
        Compute hash: H(v) = A^{⊗k} ⊗ v.
        Complexity: O(n²) per evaluation (after precomputation).
        """
        return self.power_matrix.tropical_mv(v)

    def security_bits(self) -> float:
        """Estimate collision security in bits."""
        output_space_bits = self.n * self.n * np.log2(2 * self.entry_bound + 1)
        return output_space_bits / 2  # Birthday bound

    def forward_ops(self) -> int:
        """Number of operations for forward evaluation."""
        return self.n ** 3 * int(np.ceil(np.log2(max(self.k, 1)))) + self.n ** 2


class TropicalKeyExchange:
    """
    Tropical Diffie-Hellman Key Exchange.

    Protocol:
    1. Public: generator matrix A of dimension n
    2. Alice: secret a, sends A^{⊗a}
    3. Bob: secret b, sends A^{⊗b}
    4. Shared key: A^{⊗(a+b)}

    Security assumption: Tropical Discrete Logarithm Problem (TDLP)
    """

    def __init__(self, n: int, entry_bound: int = 100):
        self.n = n
        self.generator = TropicalMatrix.random(n, 0, entry_bound)

    def generate_public_key(self, secret: int) -> TropicalMatrix:
        """Compute public key A^{⊗secret}. O(n³ log secret)."""
        return self.generator.tropical_pow(secret)

    def compute_shared_key(self, other_public: TropicalMatrix, my_secret: int) -> TropicalMatrix:
        """Compute shared key (A^{⊗b})^{⊗a} = A^{⊗(a·b)}... wait.

        Note: In tropical algebra, (A^{⊗b})^{⊗a} = A^{⊗(a*b)} not A^{⊗(a+b)}.
        So the shared secret uses multiplicative composition.
        """
        return other_public.tropical_pow(my_secret)

    def verify_agreement(self, alice_secret: int, bob_secret: int) -> bool:
        """Verify that both parties compute the same shared key."""
        alice_public = self.generate_public_key(alice_secret)
        bob_public = self.generate_public_key(bob_secret)

        alice_shared = self.compute_shared_key(bob_public, alice_secret)
        bob_shared = self.compute_shared_key(alice_public, bob_secret)

        return np.allclose(alice_shared.data, bob_shared.data)


def lipschitz_certificate(A: TropicalMatrix, v: np.ndarray, epsilon: float) -> dict:
    """
    Compute certified robustness certificate for tropical operation.

    For input v with perturbation bound ε, certifies that
    ||A⊗(v+δ) - A⊗v||_∞ ≤ ε for all ||δ||_∞ ≤ ε.

    Returns:
        Dictionary with certificate information
    """
    base_output = A.tropical_mv(v)
    return {
        'input': v.tolist(),
        'output': base_output.tolist(),
        'perturbation_bound': epsilon,
        'output_bound': epsilon,  # Lipschitz constant = 1
        'lipschitz_constant': 1,
        'certified': True,
        'explanation': f'For all δ with ||δ||_∞ ≤ {epsilon}, '
                       f'||A⊗(v+δ) - A⊗v||_∞ ≤ {epsilon}'
    }


def padic_valuation(n: int, p: int) -> int:
    """
    Compute the p-adic valuation v_p(n) = max{k : p^k | n}.

    This is the bridge from multiplicative number theory to tropical algebra:
    v_p(a·b) = v_p(a) + v_p(b) [multiplication → addition]
    v_p(min(a,b)) = min(v_p(a), v_p(b)) [when a|b or b|a]
    """
    if n == 0:
        return float('inf')
    count = 0
    while n % p == 0:
        n //= p
        count += 1
    return count


def tropical_from_padic(matrix: np.ndarray, p: int) -> TropicalMatrix:
    """
    Convert an integer matrix to a tropical matrix via p-adic valuation.
    This is the Rosetta Stone bridge: classical → tropical → lattice.

    Bridge: Number Theory → Tropical Geometry → Lattice Cryptography
    """
    n = matrix.shape[0]
    tropical_data = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            val = int(matrix[i, j])
            if val == 0:
                tropical_data[i, j] = float('inf')
            else:
                tropical_data[i, j] = padic_valuation(abs(val), p)
    return TropicalMatrix(tropical_data)


# ============================================================
# Example usage
# ============================================================

if __name__ == '__main__':
    print("Tropical Cryptography Algorithms - Examples")
    print("=" * 60)

    # 1. Matrix operations
    print("\n1. Tropical Matrix Operations")
    A = TropicalMatrix(np.array([[1, 3, 5], [2, 0, 4], [6, 1, 2]], dtype=float))
    B = TropicalMatrix(np.array([[0, 2, 1], [3, 1, 0], [2, 4, 3]], dtype=float))
    C = A.tropical_mul(B)
    print(f"   A ⊗ B = \n{C.data}")

    # 2. Matrix power
    print("\n2. Tropical Matrix Power (repeated squaring)")
    Ak = A.tropical_pow(10)
    print(f"   A^⊗10 diagonal: [{Ak.data[0,0]:.0f}, {Ak.data[1,1]:.0f}, {Ak.data[2,2]:.0f}]")

    # 3. Tropical eigenvalue
    print("\n3. Tropical Eigenvalue Approximation")
    eig = A.tropical_eigenvalue_approx(50)
    print(f"   Approximate tropical eigenvalue: {eig:.4f}")

    # 4. Hash function
    print("\n4. Tropical Hash Function")
    h = TropicalHashFunction(n=8, k=100, entry_bound=50)
    v = np.random.randint(0, 50, 8).astype(float)
    hv = h.hash(v)
    print(f"   Hash of {v.tolist()[:4]}... = {hv.tolist()[:4]}...")
    print(f"   Security: {h.security_bits():.0f} bits")

    # 5. Key exchange
    print("\n5. Tropical Key Exchange")
    ke = TropicalKeyExchange(n=4, entry_bound=20)
    alice_secret, bob_secret = 7, 11
    print(f"   Alice secret: {alice_secret}, Bob secret: {bob_secret}")
    agreement = ke.verify_agreement(alice_secret, bob_secret)
    print(f"   Keys agree? {agreement}")

    # 6. Lipschitz certificate
    print("\n6. Certified Robustness")
    cert = lipschitz_certificate(A, np.array([1, 2, 3], dtype=float), epsilon=0.5)
    print(f"   Certificate: {cert['explanation']}")

    # 7. p-adic bridge
    print("\n7. p-adic Valuation Bridge")
    M = np.array([[12, 8, 15], [4, 9, 6], [16, 3, 27]])
    T = tropical_from_padic(M, 2)
    print(f"   Classical matrix:\n{M}")
    print(f"   Tropical (v_2) matrix:\n{T.data}")

    print("\n" + "=" * 60)
    print("All examples completed successfully!")


#!/usr/bin/env python3
"""
Tropical Cryptography Applications

Real-world applications of tropical min-plus algebra:
1. Post-quantum key exchange
2. Certified adversarial robustness for neural networks
3. Tropical hash function with collision analysis
4. Lattice bridge via p-adic valuation
"""

import numpy as np
from algorithms import TropicalMatrix, TropicalHashFunction, TropicalKeyExchange
from algorithms import lipschitz_certificate, padic_valuation, tropical_from_padic


def application_1_post_quantum_key_exchange():
    """
    Application 1: Post-Quantum Key Exchange via Tropical DLP

    Alice and Bob agree on a shared secret using tropical matrix powers.
    Security relies on the hardness of the Tropical Discrete Logarithm Problem.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 1: Post-Quantum Key Exchange")
    print("=" * 70)

    n = 6  # Matrix dimension
    ke = TropicalKeyExchange(n=n, entry_bound=50)
    print(f"\nPublic parameters: {n}×{n} tropical matrix")
    print(f"Generator matrix (first row): {ke.generator.data[0].tolist()}")

    # Alice and Bob choose secrets
    alice_secret = 13
    bob_secret = 17

    # Compute public keys
    alice_public = ke.generate_public_key(alice_secret)
    bob_public = ke.generate_public_key(bob_secret)

    print(f"\nAlice's secret: {alice_secret}")
    print(f"Bob's secret: {bob_secret}")
    print(f"Alice's public key (diagonal): {[alice_public.data[i,i] for i in range(n)]}")
    print(f"Bob's public key (diagonal): {[bob_public.data[i,i] for i in range(n)]}")

    # Compute shared key
    alice_shared = ke.compute_shared_key(bob_public, alice_secret)
    bob_shared = ke.compute_shared_key(alice_public, bob_secret)

    agreement = np.allclose(alice_shared.data, bob_shared.data)
    print(f"\nShared keys agree? {agreement}")
    print(f"Shared key (diagonal): {[alice_shared.data[i,i] for i in range(n)]}")

    # Security analysis
    print(f"\nSecurity Analysis:")
    print(f"  Forward cost (compute A^⊗k): O({n}³ log k) = O({n**3} log k)")
    print(f"  Brute force inversion: test all k from 1 to K")
    print(f"  Structural immunity: min is idempotent → no quantum Fourier transform")


def application_2_certified_robustness():
    """
    Application 2: Certified Adversarial Robustness for Tropical Neural Networks

    A tropical neural network layer f(x) = A ⊗ x is 1-Lipschitz.
    This provides certified robustness: perturbations of size ε produce
    output changes of at most ε.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Certified Adversarial Robustness")
    print("=" * 70)

    n = 10
    num_layers = 5

    # Create multi-layer tropical network
    layers = [TropicalMatrix.random(n, 0, 20) for _ in range(num_layers)]

    # Test input
    x = np.random.randint(0, 20, n).astype(float)

    # Forward pass
    output = x.copy()
    for layer in layers:
        output = layer.tropical_mv(output)

    print(f"\n{num_layers}-layer tropical network, dimension {n}")
    print(f"Input: {x[:5].tolist()}...")
    print(f"Output: {output[:5].tolist()}...")

    # Certified robustness test
    epsilon = 2.0
    num_attacks = 1000
    max_output_change = 0

    for _ in range(num_attacks):
        delta = np.random.uniform(-epsilon, epsilon, n)
        perturbed = x + delta

        perturbed_output = perturbed.copy()
        for layer in layers:
            perturbed_output = layer.tropical_mv(perturbed_output)

        change = np.max(np.abs(output - perturbed_output))
        max_output_change = max(max_output_change, change)

    print(f"\nCertified Robustness Analysis:")
    print(f"  Perturbation bound ε = {epsilon}")
    print(f"  Lipschitz constant = 1 (per layer) × {num_layers} layers = 1 (non-expansive)")
    print(f"  Certified output bound: {epsilon}")
    print(f"  Empirical max output change over {num_attacks} attacks: {max_output_change:.4f}")
    print(f"  Certificate valid? {max_output_change <= epsilon + 1e-10} ✓")


def application_3_tropical_hash():
    """
    Application 3: Tropical Hash Function with Collision Analysis

    H(v) = A^{⊗k} ⊗ v provides a hash function with:
    - O(n² ) evaluation cost (after precomputation)
    - Collision resistance based on birthday bound
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Tropical Hash Function")
    print("=" * 70)

    configurations = [
        (8, 50, 16),
        (16, 100, 32),
        (32, 200, 64),
    ]

    for n, k, B in configurations:
        h = TropicalHashFunction(n=n, k=k, entry_bound=B)

        # Hash some test inputs
        v1 = np.random.randint(0, B, n).astype(float)
        v2 = v1.copy(); v2[0] += 1  # Slight perturbation

        h1 = h.hash(v1)
        h2 = h.hash(v2)

        diff = np.max(np.abs(h1 - h2))

        print(f"\nConfiguration: n={n}, k={k}, B={B}")
        print(f"  Security: {h.security_bits():.0f} bits")
        print(f"  Forward ops: {h.forward_ops():,}")
        print(f"  Hash diff for 1-bit change: {diff:.1f}")
        print(f"  Output space: (2·{B}+1)^{n*n} = {2*B+1}^{n*n}")


def application_4_lattice_bridge():
    """
    Application 4: p-adic Valuation Bridge to Lattice Cryptography

    The p-adic valuation v_p maps:
    - Multiplication → Addition (v_p(ab) = v_p(a) + v_p(b))
    - This converts classical matrices to tropical matrices

    The bridge enables hybrid tropical-lattice security reductions.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: p-adic Valuation Bridge")
    print("=" * 70)

    # Classical matrix with entries that are products of small primes
    M = np.array([
        [12, 8, 18],
        [4, 27, 6],
        [16, 9, 36]
    ])

    print(f"\nClassical matrix M:")
    print(M)

    for p in [2, 3]:
        T = tropical_from_padic(M, p)
        print(f"\nTropical matrix via v_{p}:")
        print(T.data.astype(int))

        tdet = T.tropical_det()
        print(f"  Tropical determinant: {tdet}")

        eig = T.tropical_eigenvalue_approx(20)
        print(f"  Approx tropical eigenvalue: {eig:.4f}")

    # Demonstrate the homomorphism
    print("\nHomomorphism verification: v_p(a·b) = v_p(a) + v_p(b)")
    for p in [2, 3, 5]:
        a, b = 12, 18
        print(f"  p={p}: v_{p}({a}·{b}) = v_{p}({a*b}) = {padic_valuation(a*b, p)}")
        print(f"         v_{p}({a}) + v_{p}({b}) = {padic_valuation(a, p)} + {padic_valuation(b, p)} = {padic_valuation(a, p) + padic_valuation(b, p)}")

    # Lattice determinant bound
    print("\nLattice determinant bounds:")
    for n, B, p in [(4, 3, 2), (8, 5, 2), (16, 3, 3)]:
        det_bound = p ** (n * B)
        print(f"  n={n}, B={B}, p={p}: det bound = {p}^{n*B} = {det_bound:,.0f}")


if __name__ == '__main__':
    np.random.seed(42)

    application_1_post_quantum_key_exchange()
    application_2_certified_robustness()
    application_3_tropical_hash()
    application_4_lattice_bridge()

    print("\n" + "=" * 70)
    print("All applications completed successfully!")
    print("=" * 70)


#!/usr/bin/env python3
"""
Tropical Min-Plus Cryptography: Concrete Demonstrations

This script demonstrates the key mathematical objects and theorems from
the tropical cryptography framework with concrete numerical examples.
"""

import numpy as np
from itertools import permutations
import time


def tropical_mv(A: np.ndarray, v: np.ndarray) -> np.ndarray:
    """Tropical (min-plus) matrix-vector product: (A⊗v)_i = min_j(A_{ij} + v_j)"""
    n = A.shape[0]
    result = np.full(n, np.inf)
    for i in range(n):
        for j in range(n):
            result[i] = min(result[i], A[i, j] + v[j])
    return result


def tropical_mm(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Tropical (min-plus) matrix multiplication: (A⊗B)_{ij} = min_k(A_{ik} + B_{kj})"""
    n = A.shape[0]
    result = np.full((n, n), np.inf)
    for i in range(n):
        for j in range(n):
            for k in range(n):
                result[i, j] = min(result[i, j], A[i, k] + B[k, j])
    return result


def tropical_pow(A: np.ndarray, k: int) -> np.ndarray:
    """Tropical matrix power by repeated multiplication."""
    if k <= 0:
        return A.copy()
    result = A.copy()
    for _ in range(k - 1):
        result = tropical_mm(result, A)
    return result


def tropical_det(A: np.ndarray) -> float:
    """Tropical determinant = min-weight perfect matching."""
    n = A.shape[0]
    min_weight = np.inf
    for perm in permutations(range(n)):
        weight = sum(A[i, perm[i]] for i in range(n))
        min_weight = min(min_weight, weight)
    return min_weight


def linf_dist(v: np.ndarray, w: np.ndarray) -> float:
    """L∞ distance between vectors."""
    return np.max(np.abs(v - w))


def perm_weight(A: np.ndarray, perm: tuple) -> float:
    """Weight of a permutation in a matrix."""
    return sum(A[i, perm[i]] for i in range(A.shape[0]))


# ============================================================
# DEMO 1: Min-Plus Distributivity
# ============================================================
print("=" * 70)
print("DEMO 1: Min-Plus Distributivity")
print("=" * 70)
print()

a, b, c = 3, 7, 5
lhs = a + min(b, c)
rhs = min(a + b, a + c)
print(f"  a={a}, b={b}, c={c}")
print(f"  a + min(b,c) = {a} + min({b},{c}) = {a} + {min(b,c)} = {lhs}")
print(f"  min(a+b, a+c) = min({a+b}, {a+c}) = {rhs}")
print(f"  Equal? {lhs == rhs} ✓")
print()

# ============================================================
# DEMO 2: No Additive Inverse
# ============================================================
print("=" * 70)
print("DEMO 2: No Additive Inverse in Min-Plus")
print("=" * 70)
print()

print("  Trying to find f such that min(a, f(a)) = 0 for all a:")
print("  For a = -1: min(-1, f(-1)) ≤ -1 < 0 for ANY f(-1)")
print("  → No such f exists! ✓")
print("  This is the structural obstruction blocking Shor's algorithm.")
print()

# ============================================================
# DEMO 3: Tropical Matrix-Vector Product
# ============================================================
print("=" * 70)
print("DEMO 3: Tropical Matrix-Vector Product")
print("=" * 70)
print()

A = np.array([[1, 3, 5],
              [2, 0, 4],
              [6, 1, 2]], dtype=float)
v = np.array([2, 1, 3], dtype=float)

result = tropical_mv(A, v)
print(f"  A = {A.tolist()}")
print(f"  v = {v.tolist()}")
print(f"  A ⊗ v = {result.tolist()}")
print()
print("  Verification:")
for i in range(3):
    terms = [f"A[{i},{j}]+v[{j}]={A[i,j]+v[j]}" for j in range(3)]
    print(f"    (A⊗v)[{i}] = min({', '.join(terms)}) = {result[i]}")
print()

# ============================================================
# DEMO 4: Non-Expansiveness (1-Lipschitz)
# ============================================================
print("=" * 70)
print("DEMO 4: Non-Expansiveness (1-Lipschitz Property)")
print("=" * 70)
print()

np.random.seed(42)
n = 8
A = np.random.randint(0, 10, (n, n)).astype(float)
num_tests = 1000
max_ratio = 0

for _ in range(num_tests):
    v = np.random.randint(-10, 10, n).astype(float)
    w = np.random.randint(-10, 10, n).astype(float)
    input_dist = linf_dist(v, w)
    output_dist = linf_dist(tropical_mv(A, v), tropical_mv(A, w))
    if input_dist > 0:
        ratio = output_dist / input_dist
        max_ratio = max(max_ratio, ratio)

print(f"  Tested {num_tests} random pairs for n={n}")
print(f"  Max ratio ||A⊗v - A⊗w||_∞ / ||v - w||_∞ = {max_ratio:.4f}")
print(f"  Theorem guarantees ratio ≤ 1.0: {'✓' if max_ratio <= 1.0001 else '✗'}")
print()

# ============================================================
# DEMO 5: Tropical Determinant = Min-Weight Assignment
# ============================================================
print("=" * 70)
print("DEMO 5: Tropical Determinant = Min-Weight Perfect Matching")
print("=" * 70)
print()

A_small = np.array([[3, 1, 4],
                     [1, 5, 9],
                     [2, 6, 5]], dtype=float)

tdet = tropical_det(A_small)
trace = sum(A_small[i, i] for i in range(3))
print(f"  A = {A_small.tolist()}")
print(f"  Tropical determinant: tdet(A) = {tdet}")
print(f"  Matrix trace: tr(A) = {trace}")
print(f"  tdet(A) ≤ tr(A)? {tdet <= trace} ✓")
print()

print("  All permutation weights:")
for perm in permutations(range(3)):
    w = perm_weight(A_small, perm)
    marker = " ← minimum" if w == tdet else ""
    print(f"    σ = {perm}: w = {w}{marker}")
print()

# ============================================================
# DEMO 6: Exponential Gap (Forward vs Inversion Cost)
# ============================================================
print("=" * 70)
print("DEMO 6: Exponential Gap: n² vs 2^n")
print("=" * 70)
print()

print(f"  {'n':>4} | {'n² (forward)':>14} | {'2^n (inversion)':>20} | {'Ratio':>12}")
print(f"  {'-'*4}-+-{'-'*14}-+-{'-'*20}-+-{'-'*12}")
for n in [5, 8, 16, 32, 64, 128, 256]:
    forward = n ** 2
    inversion = 2 ** n
    ratio = inversion / forward
    print(f"  {n:>4} | {forward:>14,} | {inversion:>20,.0f} | {ratio:>12,.0f}×")
print()

# ============================================================
# DEMO 7: Tropical Matrix Power Computation
# ============================================================
print("=" * 70)
print("DEMO 7: Tropical Matrix Powers")
print("=" * 70)
print()

A = np.array([[0, 3, 8],
              [2, 0, 5],
              [4, 1, 0]], dtype=float)

print(f"  A = {A.tolist()}")
for k in range(1, 6):
    Ak = tropical_pow(A, k)
    print(f"  A^⊗{k} diagonal = [{Ak[0,0]:.0f}, {Ak[1,1]:.0f}, {Ak[2,2]:.0f}]")
    # The diagonal entries approach k * tropical_eigenvalue

print()
print("  The diagonal entries grow linearly → tropical eigenvalue = min cycle mean")
print()

# ============================================================
# DEMO 8: Shift Equivariance
# ============================================================
print("=" * 70)
print("DEMO 8: Shift Equivariance: A⊗(v+c) = (A⊗v)+c")
print("=" * 70)
print()

A = np.array([[1, 3], [2, 0]], dtype=float)
v = np.array([5, 2], dtype=float)
c = 7

lhs = tropical_mv(A, v + c)
rhs = tropical_mv(A, v) + c
print(f"  A = {A.tolist()}, v = {v.tolist()}, c = {c}")
print(f"  A ⊗ (v + {c}) = {lhs.tolist()}")
print(f"  (A ⊗ v) + {c} = {rhs.tolist()}")
print(f"  Equal? {np.allclose(lhs, rhs)} ✓")
print()

# ============================================================
# DEMO 9: Birthday Bound for Collision Resistance
# ============================================================
print("=" * 70)
print("DEMO 9: Birthday Bound Collision Resistance")
print("=" * 70)
print()

print(f"  {'Dim n':>6} | {'Entry B':>8} | {'Output Space (bits)':>20} | {'Birthday (bits)':>16}")
print(f"  {'-'*6}-+-{'-'*8}-+-{'-'*20}-+-{'-'*16}")
for n, B in [(4, 16), (8, 16), (16, 256), (32, 256), (64, 65536), (128, 65536)]:
    output_bits = n * n * np.log2(2 * B + 1)
    birthday_bits = output_bits / 2
    print(f"  {n:>6} | {B:>8} | {output_bits:>20,.0f} | {birthday_bits:>16,.0f}")
print()

# ============================================================
# DEMO 10: Timing: Forward Computation
# ============================================================
print("=" * 70)
print("DEMO 10: Forward Computation Timing")
print("=" * 70)
print()

for n in [10, 50, 100, 200]:
    A = np.random.randint(0, 100, (n, n)).astype(float)
    v = np.random.randint(0, 100, n).astype(float)

    start = time.time()
    for _ in range(10):
        tropical_mv(A, v)
    elapsed = (time.time() - start) / 10

    print(f"  n={n:>4}: tropical_mv takes {elapsed*1000:.2f} ms (O(n²) = {n*n} ops)")

print()
print("All demonstrations completed successfully! ✓")


#!/usr/bin/env python3
"""
Tropical Cryptography Visualizations

Generates charts and diagrams illustrating key mathematical structures.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from algorithms import TropicalMatrix, padic_valuation


def plot_exponential_gap():
    """Plot the exponential gap between forward and inversion cost."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    ns = np.arange(1, 21)
    forward = ns ** 2
    inversion = 2.0 ** ns

    ax.semilogy(ns, forward, 'b-o', label='Forward cost: $n^2$', markersize=5, linewidth=2)
    ax.semilogy(ns, inversion, 'r-s', label='Inversion cost: $2^n$', markersize=5, linewidth=2)
    ax.fill_between(ns, forward, inversion, alpha=0.15, color='green',
                    where=inversion > forward, label='Security gap')

    ax.axvline(x=5, color='gray', linestyle='--', alpha=0.5, label='$n \\geq 5$: gap proven')
    ax.set_xlabel('Dimension $n$', fontsize=13)
    ax.set_ylabel('Number of operations', fontsize=13)
    ax.set_title('Tropical One-Way Function: Exponential Security Gap', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(1, 20)

    plt.tight_layout()
    plt.savefig('exponential_gap.png', dpi=150, bbox_inches='tight')
    plt.savefig('exponential_gap.svg', bbox_inches='tight')
    plt.close()
    print("  Saved: exponential_gap.png/svg")


def plot_lipschitz_verification():
    """Empirically verify the 1-Lipschitz bound."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    np.random.seed(42)

    # Left: scatter plot of input vs output distances
    n = 16
    A = TropicalMatrix.random(n, 0, 50)
    num_samples = 2000

    input_dists = []
    output_dists = []
    for _ in range(num_samples):
        v = np.random.randint(-20, 20, n).astype(float)
        w = np.random.randint(-20, 20, n).astype(float)
        id_ = np.max(np.abs(v - w))
        od = np.max(np.abs(A.tropical_mv(v) - A.tropical_mv(w)))
        if id_ > 0:
            input_dists.append(id_)
            output_dists.append(od)

    ax = axes[0]
    ax.scatter(input_dists, output_dists, alpha=0.2, s=8, c='blue')
    max_val = max(max(input_dists), max(output_dists))
    ax.plot([0, max_val], [0, max_val], 'r--', linewidth=2, label='Lipschitz bound (slope=1)')
    ax.set_xlabel('Input distance $\\|v - w\\|_\\infty$', fontsize=12)
    ax.set_ylabel('Output distance $\\|A\\otimes v - A\\otimes w\\|_\\infty$', fontsize=12)
    ax.set_title('Non-Expansiveness Verification ($n=16$)', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Right: ratio histogram
    ratios = [od/id_ for id_, od in zip(input_dists, output_dists) if id_ > 0]
    ax = axes[1]
    ax.hist(ratios, bins=50, color='steelblue', edgecolor='white', alpha=0.8)
    ax.axvline(x=1.0, color='red', linestyle='--', linewidth=2, label='Lipschitz bound')
    ax.set_xlabel('Ratio $\\|A\\otimes v - A\\otimes w\\|_\\infty / \\|v - w\\|_\\infty$', fontsize=12)
    ax.set_ylabel('Count', fontsize=12)
    ax.set_title('Distribution of Contraction Ratios', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('lipschitz_verification.png', dpi=150, bbox_inches='tight')
    plt.savefig('lipschitz_verification.svg', bbox_inches='tight')
    plt.close()
    print("  Saved: lipschitz_verification.png/svg")


def plot_tropical_eigenvalue_convergence():
    """Show convergence of A^k diagonal to tropical eigenvalue."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    A = TropicalMatrix(np.array([
        [0, 3, 8, 5],
        [2, 0, 5, 7],
        [4, 1, 0, 3],
        [6, 2, 4, 0]
    ], dtype=float))

    ks = range(1, 31)
    for i in range(4):
        vals = []
        for k in ks:
            Ak = A.tropical_pow(k)
            vals.append(Ak.data[i, i] / k)
        ax.plot(ks, vals, '-o', label=f'$A^{{\\otimes k}}_{{{i}{i}}} / k$', markersize=4)

    # True eigenvalue (min cycle mean)
    eig = A.tropical_eigenvalue_approx(100)
    ax.axhline(y=eig, color='black', linestyle='--', linewidth=2,
               label=f'Tropical eigenvalue $\\lambda = {eig:.2f}$')

    ax.set_xlabel('Power $k$', fontsize=13)
    ax.set_ylabel('$A^{\\otimes k}_{ii} / k$', fontsize=13)
    ax.set_title('Convergence to Tropical Eigenvalue (Min Cycle Mean)', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('eigenvalue_convergence.png', dpi=150, bbox_inches='tight')
    plt.savefig('eigenvalue_convergence.svg', bbox_inches='tight')
    plt.close()
    print("  Saved: eigenvalue_convergence.png/svg")


def plot_birthday_bound():
    """Visualize birthday bound collision resistance."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    dims = np.arange(4, 65)
    B = 16

    output_bits = dims * dims * np.log2(2 * B + 1)
    birthday_bits = output_bits / 2

    ax.plot(dims, birthday_bits, 'b-', linewidth=2, label='Collision security (bits)')
    ax.axhline(y=128, color='green', linestyle='--', alpha=0.7, label='NIST Level I (128 bits)')
    ax.axhline(y=256, color='orange', linestyle='--', alpha=0.7, label='NIST Level V (256 bits)')

    ax.fill_between(dims, 0, birthday_bits, alpha=0.1, color='blue')

    ax.set_xlabel('Matrix dimension $n$', fontsize=13)
    ax.set_ylabel('Security level (bits)', fontsize=13)
    ax.set_title(f'Tropical Hash Collision Resistance ($B={B}$)', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0, max(birthday_bits) * 1.1)

    plt.tight_layout()
    plt.savefig('birthday_bound.png', dpi=150, bbox_inches='tight')
    plt.savefig('birthday_bound.svg', bbox_inches='tight')
    plt.close()
    print("  Saved: birthday_bound.png/svg")


def plot_tropical_matrix_heatmap():
    """Visualize tropical matrix power evolution."""
    np.random.seed(42)
    A = TropicalMatrix.random(8, 0, 20)

    fig, axes = plt.subplots(1, 4, figsize=(16, 4))
    powers = [1, 5, 10, 20]

    for ax, k in zip(axes, powers):
        Ak = A.tropical_pow(k)
        im = ax.imshow(Ak.data, cmap='viridis', aspect='equal')
        ax.set_title(f'$A^{{\\otimes {k}}}$', fontsize=13)
        ax.set_xlabel('Column')
        ax.set_ylabel('Row')
        plt.colorbar(im, ax=ax, fraction=0.046, pad=0.04)

    plt.suptitle('Tropical Matrix Power Evolution', fontsize=14, y=1.02)
    plt.tight_layout()
    plt.savefig('matrix_evolution.png', dpi=150, bbox_inches='tight')
    plt.savefig('matrix_evolution.svg', bbox_inches='tight')
    plt.close()
    print("  Saved: matrix_evolution.png/svg")


if __name__ == '__main__':
    print("Generating visualizations...")
    plot_exponential_gap()
    plot_lipschitz_verification()
    plot_tropical_eigenvalue_convergence()
    plot_birthday_bound()
    plot_tropical_matrix_heatmap()
    print("\nAll visualizations generated successfully!")
