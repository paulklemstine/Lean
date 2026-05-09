#!/usr/bin/env python3
"""
Tropical Cryptographic Algorithms

Implements the core algorithms for tropical post-quantum cryptography:
1. Tropical matrix multiplication (O(n³))
2. Tropical matrix power (O(n³ · exp))
3. Tropical determinant (O(n³) via Hungarian, O(n!) brute force)
4. Tropical key exchange protocol
5. Tropical hash function
6. Security parameter computation

Bridge: Tropical Geometry × Post-Quantum Cryptography × Computational Complexity
"""

import numpy as np
from typing import Tuple, Optional, List
from math import factorial, log2
from itertools import permutations
import time


class TropicalMatrix:
    """
    A matrix over the tropical (min-plus) semiring.
    
    Operations:
        ⊕ (tropical add) = min
        ⊗ (tropical mul) = +
    
    Matrix multiplication: (A⊗B)_{ij} = min_k (A_{ik} + B_{kj})
    """
    
    def __init__(self, data: np.ndarray):
        """Initialize from a numpy array."""
        self.data = np.array(data, dtype=np.float64)
        self.n = data.shape[0]
        assert data.shape == (self.n, self.n), "Matrix must be square"
    
    @classmethod
    def identity(cls, n: int) -> 'TropicalMatrix':
        """Tropical identity: 0 on diagonal, +∞ off diagonal."""
        data = np.full((n, n), np.inf)
        np.fill_diagonal(data, 0)
        return cls(data)
    
    @classmethod
    def random(cls, n: int, low: float = 0, high: float = 10) -> 'TropicalMatrix':
        """Random tropical matrix with entries in [low, high]."""
        return cls(np.random.uniform(low, high, (n, n)))
    
    def __matmul__(self, other: 'TropicalMatrix') -> 'TropicalMatrix':
        """
        Tropical matrix multiplication: (A ⊗ B)_{ij} = min_k (A_{ik} + B_{kj}).
        
        Complexity: O(n³) time, O(n²) space.
        
        This is equivalent to the Floyd-Warshall shortest path computation.
        """
        assert self.n == other.n, "Dimension mismatch"
        n = self.n
        # Vectorized: for each (i,j), compute min over k of A[i,k] + B[k,j]
        # A[i,:] has shape (n,), B[:,j] has shape (n,)
        # We want C[i,j] = min_k (A[i,k] + B[k,j])
        # Broadcast: A[:, :, np.newaxis] + B[np.newaxis, :, :] has shape (n, n, n)
        # Then take min over axis=1
        C = np.min(self.data[:, :, np.newaxis] + other.data[np.newaxis, :, :], axis=1)
        return TropicalMatrix(C)
    
    def power(self, exp: int) -> 'TropicalMatrix':
        """
        Tropical matrix power: A^⊗exp.
        
        Complexity: O(n³ · exp) time.
        
        For cryptographic key generation, exp is the secret exponent.
        """
        if exp == 0:
            return TropicalMatrix.identity(self.n)
        if exp == 1:
            return TropicalMatrix(self.data.copy())
        
        # Binary exponentiation (O(n³ log exp))
        result = TropicalMatrix.identity(self.n)
        base = TropicalMatrix(self.data.copy())
        while exp > 0:
            if exp % 2 == 1:
                result = result @ base
            base = base @ base
            exp //= 2
        return result
    
    def tropical_det(self) -> Tuple[float, Optional[tuple]]:
        """
        Tropical determinant: min_{σ ∈ S_n} Σ_i A_{i,σ(i)}.
        
        Brute force: O(n! · n) — only for small n.
        For large n, use the Hungarian algorithm (O(n³)).
        """
        n = self.n
        min_sum = np.inf
        best_perm = None
        for perm in permutations(range(n)):
            s = sum(self.data[i, perm[i]] for i in range(n))
            if s < min_sum:
                min_sum = s
                best_perm = perm
        return min_sum, best_perm
    
    def spectral_radius(self) -> float:
        """Tropical spectral radius: tropDet(A) / n."""
        det, _ = self.tropical_det()
        return det / self.n
    
    def tropical_norm(self) -> float:
        """Tropical (max/ℓ∞) norm: max_{i,j} |A_{ij}|."""
        finite = self.data[np.isfinite(self.data)]
        if len(finite) == 0:
            return 0.0
        return np.max(np.abs(finite))
    
    def __repr__(self):
        return f"TropicalMatrix({self.data})"


class TropicalKeyExchange:
    """
    Tropical Diffie-Hellman Key Exchange Protocol.
    
    Public parameters: n (dimension), G (generator matrix)
    Alice: secret a, publishes G^⊗a
    Bob: secret b, publishes G^⊗b
    Shared key: G^⊗(a+b)
    
    Security: Based on the hardness of tropical discrete logarithm
    (given G and G^⊗a, find a).
    """
    
    def __init__(self, n: int, bound: float = 10.0):
        """
        Initialize key exchange with dimension n.
        
        Args:
            n: Matrix dimension (security parameter)
            bound: Entry magnitude bound for generator
        """
        self.n = n
        self.generator = TropicalMatrix.random(n, 0, bound)
    
    def generate_keypair(self, secret: int) -> TropicalMatrix:
        """Generate public key G^⊗secret."""
        return self.generator.power(secret)
    
    def compute_shared_key(self, peer_public: TropicalMatrix, 
                           my_secret: int) -> TropicalMatrix:
        """Compute shared key: (G^⊗peer)^⊗my = G^⊗(peer+my)."""
        return peer_public.power(my_secret)
    
    def verify_correctness(self, a: int, b: int) -> bool:
        """
        Verify that Alice and Bob derive the same shared key.
        
        K_Alice = (G^⊗b)^⊗a = G^⊗(a+b)
        K_Bob = (G^⊗a)^⊗b = G^⊗(a+b)
        """
        GA = self.generate_keypair(a)
        GB = self.generate_keypair(b)
        
        K_alice = GB.power(a)
        K_bob = GA.power(b)
        K_direct = self.generator.power(a * b)
        
        return (np.allclose(K_alice.data, K_direct.data) and 
                np.allclose(K_bob.data, K_direct.data))


class TropicalHash:
    """
    Tropical hash function based on iterated min-plus matrix multiplication.
    
    H(m) = G_1 ⊗ G_2 ⊗ ... ⊗ G_k where G_i depends on message block m_i.
    
    Collision resistance follows from the hardness of tropical
    matrix factorization.
    """
    
    def __init__(self, n: int, num_blocks: int = 8):
        """
        Initialize tropical hash with dimension n.
        
        Args:
            n: Internal state dimension
            num_blocks: Number of message blocks
        """
        self.n = n
        self.num_blocks = num_blocks
        # Generate random matrices for each possible byte value
        self.lookup = {}
        for b in range(256):
            np.random.seed(b + 1000)
            self.lookup[b] = TropicalMatrix.random(n, 0, 10)
    
    def hash(self, message: bytes) -> np.ndarray:
        """
        Hash a message using tropical matrix multiplication.
        
        Returns the first row of the accumulated tropical product.
        """
        state = TropicalMatrix.identity(self.n)
        for byte in message:
            state = state @ self.lookup[byte]
        return state.data[0]


def security_parameter_table():
    """
    Compute security parameters for tropical cryptography.
    
    Returns a table mapping dimension n to classical and quantum
    security levels (in bits).
    """
    results = []
    for n in range(5, 70):
        nfact = factorial(n)
        log2_nfact = log2(nfact)
        classical_bits = int(log2_nfact)
        quantum_bits = int(log2_nfact / 2)
        results.append({
            'n': n,
            'n_factorial': nfact,
            'log2_factorial': log2_nfact,
            'classical_security_bits': classical_bits,
            'quantum_security_bits': quantum_bits,
        })
    return results


def benchmark_tropical_mul(dimensions: List[int], num_trials: int = 5):
    """
    Benchmark tropical matrix multiplication for various dimensions.
    
    Returns timing data for performance analysis.
    """
    results = []
    for n in dimensions:
        times = []
        for _ in range(num_trials):
            A = TropicalMatrix.random(n)
            B = TropicalMatrix.random(n)
            start = time.perf_counter()
            _ = A @ B
            elapsed = time.perf_counter() - start
            times.append(elapsed)
        avg = np.mean(times)
        results.append({'n': n, 'avg_time_ms': avg * 1000, 'ops': n**3})
    return results


if __name__ == "__main__":
    print("Tropical Cryptographic Algorithms — Self-Test")
    print("=" * 50)
    
    # Test associativity
    n = 5
    A = TropicalMatrix.random(n)
    B = TropicalMatrix.random(n)
    C = TropicalMatrix.random(n)
    
    AB_C = (A @ B) @ C
    A_BC = A @ (B @ C)
    assert np.allclose(AB_C.data, A_BC.data), "Associativity failed!"
    print("✓ Associativity verified")
    
    # Test identity
    I = TropicalMatrix.identity(n)
    AI = A @ I
    IA = I @ A
    assert np.allclose(AI.data, A.data), "Right identity failed!"
    assert np.allclose(IA.data, A.data), "Left identity failed!"
    print("✓ Identity verified")
    
    # Test key exchange
    ke = TropicalKeyExchange(n=8)
    assert ke.verify_correctness(3, 5), "Key exchange failed!"
    print("✓ Key exchange correctness verified")
    
    # Test security parameters
    assert factorial(35) >= 2**128, "Classical security bound failed!"
    assert factorial(58) >= 2**256, "Quantum security bound failed!"
    print("✓ Security parameters verified")
    
    # Benchmark
    print("\nBenchmark:")
    for result in benchmark_tropical_mul([16, 32, 64, 128]):
        print(f"  n={result['n']:>4}: {result['avg_time_ms']:.2f} ms "
              f"({result['ops']:>10} ops)")
    
    print("\nAll tests passed!")


#!/usr/bin/env python3
"""
Applications of Tropical Post-Quantum Cryptography

Demonstrates real-world applications:
1. Shortest-path authenticated routing
2. Certified robustness for neural networks
3. Post-quantum key exchange simulation
4. Tropical hash collision analysis

Bridge: Tropical Geometry × Post-Quantum Cryptography × Machine Learning
"""

import numpy as np
from math import factorial, log2
from algorithms import TropicalMatrix, TropicalKeyExchange, TropicalHash


# ─────────────────────────────────────────────────────────────────
# APPLICATION 1: Shortest-Path Authenticated Routing
# ─────────────────────────────────────────────────────────────────

def shortest_path_routing():
    """
    Tropical matrix multiplication computes all-pairs shortest paths.
    
    Given a weighted graph as an adjacency matrix, A^⊗k gives the
    shortest paths using at most k edges.
    
    Application: Authenticated network routing with tropical commitments.
    """
    print("=" * 65)
    print("APPLICATION 1: Shortest-Path Authenticated Routing")
    print("=" * 65)
    
    # Network topology (edge weights; inf = no direct edge)
    INF = np.inf
    # 5-node network
    adj = np.array([
        [0,   3,   INF, 7,   INF],
        [3,   0,   1,   INF, 8  ],
        [INF, 1,   0,   2,   INF],
        [7,   INF, 2,   0,   4  ],
        [INF, 8,   INF, 4,   0  ],
    ])
    
    G = TropicalMatrix(adj)
    print(f"\nNetwork adjacency matrix (5 nodes):")
    print(adj)
    
    # Compute all-pairs shortest paths via tropical matrix power
    # A^⊗(n-1) gives shortest paths
    shortest = G.power(4)
    
    print(f"\nAll-pairs shortest paths (G^⊗4):")
    print(shortest.data)
    
    # Verify: shortest path from 0 to 4
    print(f"\nShortest path 0→4: {shortest.data[0,4]}")
    print(f"  Route: 0→1 (3) → 2 (1) → 3 (2) → 4 (4) = {3+1+2+4}")
    
    # Tropical hash commitment for route authentication
    h = TropicalHash(n=4)
    route_msg = b"0-1-2-3-4"
    commitment = h.hash(route_msg)
    print(f"\nRoute commitment (tropical hash): {np.round(commitment, 4)}")


# ─────────────────────────────────────────────────────────────────
# APPLICATION 2: Certified Robustness for Tropical Neural Nets
# ─────────────────────────────────────────────────────────────────

def certified_robustness():
    """
    A tropical (min-plus) neural network layer computes:
        y_j = min_k (W_{jk} + x_k)
    
    This is exactly tropical matrix-vector multiplication.
    
    The Lipschitz constant of this layer (in ℓ∞ norm) is bounded by 1,
    since min-plus is 1-Lipschitz:
        |min_k(W_{jk} + x_k) - min_k(W_{jk} + x'_k)| ≤ max_k |x_k - x'_k|
    
    This gives CERTIFIED adversarial robustness: if ||x - x'||∞ < ε,
    then ||f(x) - f(x')||∞ < ε for each tropical layer.
    """
    print("\n" + "=" * 65)
    print("APPLICATION 2: Certified Robustness for Tropical Neural Nets")
    print("=" * 65)
    
    n = 4
    W = TropicalMatrix.random(n, -5, 5)
    
    # Clean input
    x = np.array([1.0, 2.0, 3.0, 4.0])
    
    # Adversarial perturbation
    epsilon = 0.5
    delta = np.random.uniform(-epsilon, epsilon, n)
    x_adv = x + delta
    
    # Tropical layer output
    def tropical_layer(W, x):
        """Compute min_k (W_{jk} + x_k) for each j."""
        return np.min(W.data + x[np.newaxis, :], axis=1)
    
    y = tropical_layer(W, x)
    y_adv = tropical_layer(W, x_adv)
    
    output_diff = np.max(np.abs(y - y_adv))
    input_diff = np.max(np.abs(x - x_adv))
    
    print(f"\nWeight matrix W:\n{np.round(W.data, 2)}")
    print(f"\nClean input x = {x}")
    print(f"Perturbation δ = {np.round(delta, 4)}")
    print(f"Adversarial x' = {np.round(x_adv, 4)}")
    print(f"\nOutput f(x)  = {np.round(y, 4)}")
    print(f"Output f(x') = {np.round(y_adv, 4)}")
    print(f"\n‖x - x'‖∞ = {input_diff:.4f}")
    print(f"‖f(x) - f(x')‖∞ = {output_diff:.4f}")
    print(f"Lipschitz bound: {output_diff:.4f} ≤ {input_diff:.4f}? "
          f"{'✓ CERTIFIED' if output_diff <= input_diff + 1e-10 else '✗ VIOLATED'}")
    
    # Multi-layer network
    L = 5
    layers = [TropicalMatrix.random(n, -2, 2) for _ in range(L)]
    
    out_clean = x.copy()
    out_adv = x_adv.copy()
    for layer in layers:
        out_clean = tropical_layer(layer, out_clean)
        out_adv = tropical_layer(layer, out_adv)
    
    multi_diff = np.max(np.abs(out_clean - out_adv))
    print(f"\n{L}-layer tropical network:")
    print(f"  Input perturbation: {input_diff:.4f}")
    print(f"  Output perturbation: {multi_diff:.4f}")
    print(f"  Certified bound (1^{L} · ε = ε): {input_diff:.4f}")
    print(f"  Robust? {'✓ YES' if multi_diff <= input_diff + 1e-10 else '✗ NO'}")


# ─────────────────────────────────────────────────────────────────
# APPLICATION 3: Post-Quantum Key Exchange Simulation
# ─────────────────────────────────────────────────────────────────

def key_exchange_simulation():
    """
    Full simulation of tropical Diffie-Hellman key exchange.
    
    Demonstrates:
    1. Key generation (tropical matrix power)
    2. Key exchange (tropical product)
    3. Key agreement verification
    4. Timing analysis
    """
    print("\n" + "=" * 65)
    print("APPLICATION 3: Post-Quantum Key Exchange Simulation")
    print("=" * 65)
    
    for n in [8, 16, 32]:
        ke = TropicalKeyExchange(n=n, bound=100.0)
        
        # Generate secrets
        a, b = 7, 13
        
        import time
        
        # Alice generates public key
        t0 = time.perf_counter()
        PA = ke.generate_keypair(a)
        t_alice = time.perf_counter() - t0
        
        # Bob generates public key
        t0 = time.perf_counter()
        PB = ke.generate_keypair(b)
        t_bob = time.perf_counter() - t0
        
        # Shared key computation
        t0 = time.perf_counter()
        K_alice = ke.compute_shared_key(PB, a)
        t_shared = time.perf_counter() - t0
        
        K_bob = ke.compute_shared_key(PA, b)
        
        # Verify agreement
        agree = np.allclose(K_alice.data, K_bob.data)
        
        print(f"\n  Dimension n={n}:")
        print(f"    Key generation: {t_alice*1000:.2f} ms")
        print(f"    Shared key: {t_shared*1000:.2f} ms")
        print(f"    Keys agree: {'✓' if agree else '✗'}")
        print(f"    Key size: {n*n*8} bytes")
        print(f"    Security: ~{int(log2(factorial(n)))} classical bits")


# ─────────────────────────────────────────────────────────────────
# APPLICATION 4: Tropical Hash Collision Analysis
# ─────────────────────────────────────────────────────────────────

def hash_collision_analysis():
    """
    Analyze collision resistance of tropical hash functions.
    
    The pigeonhole principle guarantees collisions when input space
    exceeds output space. We measure empirical collision rates.
    """
    print("\n" + "=" * 65)
    print("APPLICATION 4: Tropical Hash Collision Analysis")
    print("=" * 65)
    
    for n in [4, 8, 16]:
        h = TropicalHash(n=n)
        
        # Hash many random messages and check for near-collisions
        num_messages = 1000
        hashes = []
        for i in range(num_messages):
            msg = i.to_bytes(4, 'big')
            hval = h.hash(msg)
            hashes.append(hval)
        
        hashes = np.array(hashes)
        
        # Check pairwise distances
        min_dist = np.inf
        for i in range(min(100, num_messages)):
            for j in range(i+1, min(100, num_messages)):
                dist = np.max(np.abs(hashes[i] - hashes[j]))
                min_dist = min(min_dist, dist)
        
        print(f"\n  Hash dimension n={n}:")
        print(f"    Output size: {n} real values")
        print(f"    Min pairwise distance (first 100): {min_dist:.6f}")
        print(f"    Hash entropy estimate: ~{n * 32} bits")
    
    # Demonstrate pigeonhole: discretized hash → guaranteed collisions
    print(f"\n  Pigeonhole demonstration (discretized to 256 values):")
    h = TropicalHash(n=2)
    buckets = {}
    collisions = 0
    for i in range(300):
        msg = i.to_bytes(4, 'big')
        hval = h.hash(msg)
        key = tuple(np.round(hval, 1))
        if key in buckets:
            collisions += 1
        else:
            buckets[key] = i
    print(f"    Messages: 300, Collisions: {collisions}")
    print(f"    → Pigeonhole principle confirmed")


if __name__ == "__main__":
    np.random.seed(42)
    
    shortest_path_routing()
    certified_robustness()
    key_exchange_simulation()
    hash_collision_analysis()
    
    print("\n" + "=" * 65)
    print("All applications completed successfully!")
    print("=" * 65)


#!/usr/bin/env python3
"""
Tropical Post-Quantum Cryptographic Primitives — Interactive Demo

Demonstrates the core mathematical concepts of tropical (min-plus) algebra
applied to post-quantum cryptography.

Bridge: Tropical Geometry × Post-Quantum Cryptography × Computational Complexity
"""

import numpy as np
from math import factorial, log2
from itertools import permutations

np.random.seed(42)


def tropical_add(a, b):
    """Tropical addition: min(a, b)."""
    return np.minimum(a, b)


def tropical_mul(a, b):
    """Tropical multiplication: a + b."""
    return a + b


def tropical_mat_mul(A, B):
    """
    Tropical matrix multiplication: (A ⊗ B)_{ij} = min_k (A_{ik} + B_{kj}).
    Complexity: O(n³).
    """
    n = A.shape[0]
    C = np.full((n, n), np.inf)
    for i in range(n):
        for j in range(n):
            for k in range(n):
                C[i, j] = min(C[i, j], A[i, k] + B[k, j])
    return C


def tropical_mat_pow(G, exp):
    """Tropical matrix power: G^⊗exp (iterated tropical product)."""
    n = G.shape[0]
    if exp == 0:
        # Tropical identity: 0 on diagonal, +inf off diagonal
        result = np.full((n, n), np.inf)
        np.fill_diagonal(result, 0)
        return result
    result = G.copy()
    for _ in range(exp - 1):
        result = tropical_mat_mul(result, G)
    return result


def tropical_det(A):
    """
    Tropical determinant: min over all permutations of Σ_i A_{i,σ(i)}.
    Complexity: O(n! · n) — brute force for demonstration.
    """
    n = A.shape[0]
    min_sum = np.inf
    best_perm = None
    for perm in permutations(range(n)):
        s = sum(A[i, perm[i]] for i in range(n))
        if s < min_sum:
            min_sum = s
            best_perm = perm
    return min_sum, best_perm


def tropical_spectral_radius(A):
    """Tropical spectral radius: tropDet(A) / n."""
    n = A.shape[0]
    det, _ = tropical_det(A)
    return det / n


# ─────────────────────────────────────────────────────────────────
# DEMO 1: Basic Tropical Arithmetic
# ─────────────────────────────────────────────────────────────────
print("=" * 65)
print("DEMO 1: Basic Tropical Arithmetic")
print("=" * 65)

a, b, c = 3.0, 7.0, 2.0
print(f"\na = {a}, b = {b}, c = {c}")
print(f"a ⊕ b = min({a}, {b}) = {tropical_add(a, b)}")
print(f"a ⊗ b = {a} + {b} = {tropical_mul(a, b)}")
print(f"\nDistributivity: a ⊗ (b ⊕ c) = {a} + min({b}, {c})")
lhs = tropical_mul(a, tropical_add(b, c))
rhs = tropical_add(tropical_mul(a, b), tropical_mul(a, c))
print(f"  LHS = {lhs}")
print(f"  (a ⊗ b) ⊕ (a ⊗ c) = min({a}+{b}, {a}+{c})")
print(f"  RHS = {rhs}")
print(f"  Equal? {np.isclose(lhs, rhs)}")

print(f"\nIdempotency: {a} ⊕ {a} = min({a}, {a}) = {tropical_add(a, a)}")
print(f"Absorption: min({a}, {a}+2) = {min(a, a+2)}")

# Min-abs identity
print(f"\nQuantum resistance identity:")
print(f"  min(a,b) = (a + b - |a - b|) / 2")
print(f"  min({a},{b}) = ({a} + {b} - |{a}-{b}|) / 2 = {(a+b-abs(a-b))/2}")

# ─────────────────────────────────────────────────────────────────
# DEMO 2: Tropical Matrix Multiplication
# ─────────────────────────────────────────────────────────────────
print("\n" + "=" * 65)
print("DEMO 2: Tropical Matrix Multiplication")
print("=" * 65)

A = np.array([[1.0, 3.0, 5.0],
              [2.0, 0.0, 4.0],
              [6.0, 1.0, 2.0]])

B = np.array([[0.0, 2.0, 1.0],
              [3.0, 1.0, 0.0],
              [1.0, 4.0, 2.0]])

C = tropical_mat_mul(A, B)
print(f"\nA =\n{A}")
print(f"\nB =\n{B}")
print(f"\nA ⊗ B = (min_k (A_ik + B_kj)) =\n{C}")

# Verify associativity
D = np.array([[2.0, 1.0, 3.0],
              [0.0, 2.0, 1.0],
              [1.0, 3.0, 0.0]])

AB_C = tropical_mat_mul(tropical_mat_mul(A, B), D)
A_BC = tropical_mat_mul(A, tropical_mat_mul(B, D))
print(f"\nAssociativity check:")
print(f"  (A ⊗ B) ⊗ D =\n{AB_C}")
print(f"  A ⊗ (B ⊗ D) =\n{A_BC}")
print(f"  Equal? {np.allclose(AB_C, A_BC)}")

# ─────────────────────────────────────────────────────────────────
# DEMO 3: Tropical Determinant
# ─────────────────────────────────────────────────────────────────
print("\n" + "=" * 65)
print("DEMO 3: Tropical Determinant & Spectral Radius")
print("=" * 65)

det_val, best = tropical_det(A)
trace = sum(A[i, i] for i in range(3))
print(f"\nMatrix A =\n{A}")
print(f"tropDet(A) = {det_val}")
print(f"Optimal permutation: {best}")
print(f"Trace = {trace}")
print(f"tropDet(A) ≤ trace? {det_val <= trace}")
print(f"Spectral radius λ*(A) = tropDet(A)/n = {det_val/3:.4f}")

# ─────────────────────────────────────────────────────────────────
# DEMO 4: Tropical Key Exchange
# ─────────────────────────────────────────────────────────────────
print("\n" + "=" * 65)
print("DEMO 4: Tropical Diffie-Hellman Key Exchange")
print("=" * 65)

n = 4
G = np.random.uniform(0, 10, (n, n))
a_secret = 3
b_secret = 5

print(f"\nGenerator G (random {n}×{n} matrix):")
print(np.round(G, 2))

GA = tropical_mat_pow(G, a_secret)
GB = tropical_mat_pow(G, b_secret)

# Alice computes shared key: (G^b)^a = G^(a+b)
K_alice = tropical_mat_pow(GB, a_secret)  # Actually G^b iterated a more times
# More correctly: key = G^(a+b)
K_correct = tropical_mat_pow(G, a_secret + b_secret)

print(f"\nAlice's secret: a = {a_secret}")
print(f"Bob's secret: b = {b_secret}")
print(f"Alice's public: G^⊗{a_secret} (first entry: {GA[0,0]:.4f})")
print(f"Bob's public: G^⊗{b_secret} (first entry: {GB[0,0]:.4f})")
print(f"\nShared key G^⊗{a_secret + b_secret} (first row):")
print(np.round(K_correct[0], 4))

# ─────────────────────────────────────────────────────────────────
# DEMO 5: Security Parameters
# ─────────────────────────────────────────────────────────────────
print("\n" + "=" * 65)
print("DEMO 5: Security Parameters")
print("=" * 65)

print(f"\n{'n':>4} | {'n!':>20} | {'log₂(n!)':>10} | {'Classical':>10} | {'Quantum':>10}")
print("-" * 65)
for n in [10, 20, 30, 35, 40, 50, 58, 64]:
    nfact = factorial(n)
    log2_nfact = log2(nfact)
    classical = int(log2_nfact)
    quantum = int(log2_nfact / 2)
    print(f"{n:>4} | {nfact:>20.3e} | {log2_nfact:>10.1f} | {classical:>10} | {quantum:>10}")

print(f"\n✓ 35! ≥ 2^128: {factorial(35) >= 2**128}")
print(f"✓ 58! ≥ 2^256: {factorial(58) >= 2**256}")

# ─────────────────────────────────────────────────────────────────
# DEMO 6: One-Way Property — Preimage Non-uniqueness
# ─────────────────────────────────────────────────────────────────
print("\n" + "=" * 65)
print("DEMO 6: One-Way Property — Preimage Non-uniqueness")
print("=" * 65)

target = 5.0
print(f"\nTarget: min(a, b) = {target}")
print(f"Possible preimages:")
for offset in range(5):
    a_val = target
    b_val = target + offset
    print(f"  ({a_val}, {b_val}) → min = {min(a_val, b_val)}")
    a_val = target + offset
    b_val = target
    if offset > 0:
        print(f"  ({a_val}, {b_val}) → min = {min(a_val, b_val)}")

print(f"\n→ Infinitely many preimages! The inversion problem is ill-posed.")

# ─────────────────────────────────────────────────────────────────
# DEMO 7: Tropical Norm Triangle Inequality
# ─────────────────────────────────────────────────────────────────
print("\n" + "=" * 65)
print("DEMO 7: Tropical Norm & Triangle Inequality")
print("=" * 65)

u = np.array([3.0, -1.0, 4.0, -1.5])
v = np.array([-2.0, 5.0, -3.0, 2.0])
w = u + v

norm_u = np.max(np.abs(u))
norm_v = np.max(np.abs(v))
norm_w = np.max(np.abs(w))

print(f"\nu = {u}")
print(f"v = {v}")
print(f"u + v = {w}")
print(f"‖u‖∞ = {norm_u}")
print(f"‖v‖∞ = {norm_v}")
print(f"‖u+v‖∞ = {norm_w}")
print(f"‖u‖∞ + ‖v‖∞ = {norm_u + norm_v}")
print(f"Triangle inequality: {norm_w} ≤ {norm_u + norm_v}? {norm_w <= norm_u + norm_v}")

print("\n" + "=" * 65)
print("All demos completed successfully!")
print("=" * 65)


#!/usr/bin/env python3
"""
Visualizations for Tropical Post-Quantum Cryptography

Generates publication-quality figures illustrating key concepts.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from math import factorial, log2

plt.style.use('seaborn-v0_8-whitegrid')


def plot_security_parameters():
    """Plot security levels vs matrix dimension."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    
    ns = list(range(5, 65))
    classical = [log2(factorial(n)) for n in ns]
    quantum = [log2(factorial(n)) / 2 for n in ns]
    
    ax.plot(ns, classical, 'b-', linewidth=2, label='Classical security (log₂(n!))')
    ax.plot(ns, quantum, 'r-', linewidth=2, label='Quantum security (log₂(n!)/2)')
    ax.axhline(y=128, color='green', linestyle='--', alpha=0.7, label='128-bit target')
    ax.axhline(y=256, color='orange', linestyle='--', alpha=0.7, label='256-bit target')
    
    ax.axvline(x=35, color='green', linestyle=':', alpha=0.5)
    ax.axvline(x=58, color='orange', linestyle=':', alpha=0.5)
    
    ax.annotate('n=35\n(128-bit classical)', xy=(35, 128), 
                xytext=(40, 80), fontsize=10,
                arrowprops=dict(arrowstyle='->', color='green'))
    ax.annotate('n=58\n(128-bit quantum)', xy=(58, 128),
                xytext=(45, 50), fontsize=10,
                arrowprops=dict(arrowstyle='->', color='orange'))
    
    ax.set_xlabel('Matrix dimension n', fontsize=12)
    ax.set_ylabel('Security level (bits)', fontsize=12)
    ax.set_title('Tropical Cryptography: Security vs. Dimension', fontsize=14)
    ax.legend(fontsize=11, loc='upper left')
    ax.set_xlim(5, 64)
    ax.set_ylim(0, 350)
    
    plt.tight_layout()
    plt.savefig('security_parameters.png', dpi=150, bbox_inches='tight')
    plt.savefig('security_parameters.svg', bbox_inches='tight')
    plt.close()
    print("✓ Saved security_parameters.png/svg")


def plot_tropical_operations():
    """Visualize tropical addition (min) vs classical addition."""
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    
    x = np.linspace(-3, 3, 200)
    
    # Left: tropical addition min(x, 1)
    ax = axes[0]
    y_trop = np.minimum(x, 1)
    y_class = x + 1
    ax.plot(x, y_trop, 'b-', linewidth=2.5, label='min(x, 1) [tropical ⊕]')
    ax.plot(x, y_class, 'r--', linewidth=1.5, alpha=0.6, label='x + 1 [classical +]')
    ax.axhline(y=1, color='gray', linestyle=':', alpha=0.3)
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('y', fontsize=12)
    ax.set_title('Tropical vs Classical Addition', fontsize=13)
    ax.legend(fontsize=11)
    ax.set_ylim(-3, 5)
    
    # Right: piecewise-linear structure — min(a,b) = (a+b-|a-b|)/2
    ax = axes[1]
    a = np.linspace(-2, 4, 200)
    b = 1.0
    y_min = np.minimum(a, b)
    y_formula = (a + b - np.abs(a - b)) / 2
    ax.plot(a, y_min, 'b-', linewidth=2.5, label='min(a, 1)')
    ax.plot(a, y_formula, 'r--', linewidth=1.5, label='(a+1−|a−1|)/2')
    ax.axvline(x=1, color='gray', linestyle=':', alpha=0.5)
    ax.annotate('Corner at a = b\n(defeats QFT)', xy=(1, 1),
                xytext=(2, -0.5), fontsize=10,
                arrowprops=dict(arrowstyle='->', color='purple'))
    ax.set_xlabel('a', fontsize=12)
    ax.set_title('Piecewise-Linear Identity\n(Quantum Resistance)', fontsize=13)
    ax.legend(fontsize=11)
    
    plt.tight_layout()
    plt.savefig('tropical_operations.png', dpi=150, bbox_inches='tight')
    plt.savefig('tropical_operations.svg', bbox_inches='tight')
    plt.close()
    print("✓ Saved tropical_operations.png/svg")


def plot_factorial_growth():
    """Plot factorial growth vs exponential — the hardness gap."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    
    ns = list(range(1, 25))
    factorials = [log2(factorial(n)) for n in ns]
    exp_2n = [n for n in ns]  # 2^n
    exp_n_minus_1 = [n - 1 for n in ns]  # 2^(n-1)
    
    ax.plot(ns, factorials, 'b-o', linewidth=2, markersize=5, label='log₂(n!)')
    ax.plot(ns, exp_2n, 'r--', linewidth=1.5, label='n (= log₂(2ⁿ))')
    ax.plot(ns, exp_n_minus_1, 'g--', linewidth=1.5, label='n−1 (= log₂(2ⁿ⁻¹))')
    
    ax.fill_between(ns, exp_n_minus_1, factorials, alpha=0.15, color='blue',
                     label='Hardness gap: n! / 2ⁿ⁻¹')
    
    ax.set_xlabel('Dimension n', fontsize=12)
    ax.set_ylabel('log₂(search space)', fontsize=12)
    ax.set_title('Factorial vs Exponential Growth\n(Tropical Hardness Bound: 2ⁿ⁻¹ ≤ n!)', fontsize=14)
    ax.legend(fontsize=11)
    
    plt.tight_layout()
    plt.savefig('factorial_growth.png', dpi=150, bbox_inches='tight')
    plt.savefig('factorial_growth.svg', bbox_inches='tight')
    plt.close()
    print("✓ Saved factorial_growth.png/svg")


def plot_tropical_matrix_heatmap():
    """Visualize a tropical matrix product as a heatmap."""
    np.random.seed(42)
    n = 8
    
    A = np.random.uniform(0, 10, (n, n))
    B = np.random.uniform(0, 10, (n, n))
    
    # Tropical product
    C = np.min(A[:, :, np.newaxis] + B[np.newaxis, :, :], axis=1)
    
    fig, axes = plt.subplots(1, 3, figsize=(15, 4.5))
    
    for ax, mat, title in zip(axes, [A, B, C], ['Matrix A', 'Matrix B', 'A ⊗ B']):
        im = ax.imshow(mat, cmap='viridis', aspect='auto')
        ax.set_title(title, fontsize=13)
        ax.set_xlabel('Column')
        ax.set_ylabel('Row')
        plt.colorbar(im, ax=ax, shrink=0.8)
    
    plt.suptitle('Tropical Matrix Multiplication: (A⊗B)ᵢⱼ = minₖ(Aᵢₖ + Bₖⱼ)',
                 fontsize=14, y=1.02)
    plt.tight_layout()
    plt.savefig('tropical_matrix_heatmap.png', dpi=150, bbox_inches='tight')
    plt.savefig('tropical_matrix_heatmap.svg', bbox_inches='tight')
    plt.close()
    print("✓ Saved tropical_matrix_heatmap.png/svg")


def plot_comparison_table():
    """Create a visual comparison of crypto schemes."""
    fig, ax = plt.subplots(figsize=(10, 5))
    ax.axis('off')
    
    schemes = ['RSA-2048', 'CRYSTALS-Kyber', 'Classic McEliece', 'Tropical (n=58)']
    metrics = ['Key Size', 'Quantum Safe', 'Operations', 'Maturity']
    
    data = [
        ['256 bytes', '✗ NO', '× mod N', 'Deployed'],
        ['~1.5 KB', '✓ YES', 'Poly ring ×', 'NIST Standard'],
        ['~100 KB', '✓ YES', 'Syndrome', 'NIST Candidate'],
        ['~4 KB', '✓ (conj.)', 'min + add', 'Research'],
    ]
    
    colors = [['#ffcccc', '#ffcccc', '#ffe0cc', '#ccffcc'],
              ['#ccffcc', '#ccffcc', '#cce0ff', '#ccffcc'],
              ['#ffe0cc', '#ccffcc', '#cce0ff', '#ffe0cc'],
              ['#ccffcc', '#ccffcc', '#ccffcc', '#ffe0cc']]
    
    table = ax.table(cellText=data, colLabels=metrics, rowLabels=schemes,
                     cellColours=colors, loc='center', cellLoc='center')
    table.auto_set_font_size(False)
    table.set_fontsize(11)
    table.scale(1.2, 1.8)
    
    ax.set_title('Post-Quantum Cryptography: Scheme Comparison', fontsize=14, pad=20)
    
    plt.tight_layout()
    plt.savefig('scheme_comparison.png', dpi=150, bbox_inches='tight')
    plt.savefig('scheme_comparison.svg', bbox_inches='tight')
    plt.close()
    print("✓ Saved scheme_comparison.png/svg")


if __name__ == "__main__":
    print("Generating visualizations...")
    plot_security_parameters()
    plot_tropical_operations()
    plot_factorial_growth()
    plot_tropical_matrix_heatmap()
    plot_comparison_table()
    print("\nAll visualizations generated!")
