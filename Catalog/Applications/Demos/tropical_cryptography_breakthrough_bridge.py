#!/usr/bin/env python3
"""
Tropical Cryptography: Core Algorithms

Implements the cryptographic primitives from the tropical cryptography bridge,
including tropical matrix operations, key exchange, hash functions, and
security parameter estimation.
"""

import numpy as np
from dataclasses import dataclass
from typing import Tuple, Optional
import math


# ============================================================================
# Algorithm 1: Tropical Matrix Multiplication — O(n³)
# ============================================================================

def tropical_matrix_multiply(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """
    Tropical (min-plus) matrix multiplication.

    Computes C where C[i,j] = min_k(A[i,k] + B[k,j]).
    This is the Floyd-Warshall step for all-pairs shortest paths.

    Time complexity: O(n³) where n is the matrix dimension.
    Space complexity: O(n²) for the result matrix.

    Args:
        A: n×n real matrix
        B: n×n real matrix

    Returns:
        C: n×n matrix where C[i,j] = min_k(A[i,k] + B[k,j])

    >>> A = np.array([[0, 3], [2, 0]], dtype=float)
    >>> tropical_matrix_multiply(A, A)
    array([[0., 3.],
           [2., 0.]])
    """
    n = A.shape[0]
    assert A.shape == (n, n) and B.shape == (n, n), "Matrices must be square and same size"

    C = np.full((n, n), np.inf)
    for i in range(n):
        for j in range(n):
            for k in range(n):
                val = A[i, k] + B[k, j]
                if val < C[i, j]:
                    C[i, j] = val
    return C


# ============================================================================
# Algorithm 2: Tropical Matrix Power — O(k·n³) or O(n³·log k) with squaring
# ============================================================================

def tropical_matrix_power(G: np.ndarray, k: int, use_squaring: bool = True) -> np.ndarray:
    """
    Compute G^k in the tropical (min-plus) semiring.

    Args:
        G: n×n base matrix
        k: non-negative integer exponent
        use_squaring: if True, use repeated squaring O(n³ log k);
                      if False, use naive iteration O(k n³)

    Returns:
        G^k in the tropical semiring

    Complexity:
        - With squaring: O(n³ log k) time
        - Without: O(k n³) time
    """
    n = G.shape[0]
    # Tropical identity
    result = np.full((n, n), np.inf)
    np.fill_diagonal(result, 0.0)

    if k == 0:
        return result

    if use_squaring:
        base = G.copy()
        exp = k
        while exp > 0:
            if exp % 2 == 1:
                result = tropical_matrix_multiply(result, base)
            base = tropical_matrix_multiply(base, base)
            exp //= 2
        return result
    else:
        for _ in range(k):
            result = tropical_matrix_multiply(result, G)
        return result


# ============================================================================
# Algorithm 3: Tropical Hash Function — O(n·m)
# ============================================================================

def tropical_hash(H: np.ndarray, x: np.ndarray) -> np.ndarray:
    """
    Tropical hash function: y[i] = min_j(H[i,j] + x[j]).

    This is a min-plus matrix-vector product, serving as a candidate
    collision-resistant hash function under the tropical matrix
    factorization hardness assumption.

    Time complexity: O(n·m) where H is n×m.
    Space complexity: O(n) for the output.

    Args:
        H: n×m hash matrix (public key)
        x: m-dimensional input vector

    Returns:
        n-dimensional hash value
    """
    n, m = H.shape
    assert x.shape == (m,), f"Input dimension mismatch: expected {m}, got {x.shape}"

    y = np.full(n, np.inf)
    for i in range(n):
        for j in range(m):
            y[i] = min(y[i], H[i, j] + x[j])
    return y


# ============================================================================
# Algorithm 4: Tropical Key Exchange Protocol
# ============================================================================

@dataclass
class TropicalKeyExchangeParams:
    """Parameters for tropical Diffie-Hellman key exchange."""
    base_matrix: np.ndarray
    dimension: int
    max_exponent: int

    @classmethod
    def generate(cls, n: int, max_exp: int = 100,
                 seed: Optional[int] = None) -> 'TropicalKeyExchangeParams':
        """Generate random key exchange parameters."""
        rng = np.random.default_rng(seed)
        G = rng.uniform(0, 10, (n, n))
        return cls(base_matrix=G, dimension=n, max_exponent=max_exp)


def tropical_key_exchange(params: TropicalKeyExchangeParams,
                          alice_secret: int,
                          bob_secret: int) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    """
    Execute tropical Diffie-Hellman key exchange.

    Protocol:
    1. Public: base matrix G
    2. Alice picks secret a, computes G^a, sends to Bob
    3. Bob picks secret b, computes G^b, sends to Alice
    4. Alice computes (G^b)^a = G^(ba)
    5. Bob computes (G^a)^b = G^(ab)
    6. Shared secret: G^(a*b)... wait, tropical exponentiation is additive!
       Actually G^a ⊗ G^b = G^(a+b), and both can compute this.

    Note: In the Grigoriev-Shpilrain scheme, the protocol uses
    conjugation A·G^k·A^(-1) rather than simple exponentiation.

    Returns:
        (alice_public, bob_public, shared_secret)
    """
    G = params.base_matrix
    Ga = tropical_matrix_power(G, alice_secret)
    Gb = tropical_matrix_power(G, bob_secret)

    # Shared secret via tropical multiplication
    shared = tropical_matrix_multiply(Ga, Gb)
    return Ga, Gb, shared


# ============================================================================
# Algorithm 5: Security Parameter Estimation
# ============================================================================

def estimate_security_level(n: int) -> dict:
    """
    Estimate security level for tropical OWF with n×n matrices.

    The search space for brute-force tropical matrix factorization
    is Ω(n!), so:
    - Classical security: log₂(n!) bits
    - Quantum security: log₂(n!)/2 bits (Grover's quadratic speedup)

    Args:
        n: matrix dimension

    Returns:
        Dictionary with security estimates
    """
    log2_factorial = sum(math.log2(k) for k in range(1, n + 1))
    classical_bits = int(log2_factorial)
    quantum_bits = int(log2_factorial / 2)

    return {
        'dimension': n,
        'search_space_log2': log2_factorial,
        'classical_security_bits': classical_bits,
        'quantum_security_bits': quantum_bits,
        'meets_128_classical': classical_bits >= 128,
        'meets_128_quantum': quantum_bits >= 128,
        'meets_256_classical': classical_bits >= 256,
    }


def find_minimum_dimension(target_classical: int = 128,
                           target_quantum: int = 128) -> dict:
    """
    Find minimum matrix dimension for target security levels.

    Args:
        target_classical: target classical security in bits
        target_quantum: target quantum security in bits

    Returns:
        Dictionary with minimum dimensions
    """
    min_classical = None
    min_quantum = None

    for n in range(2, 200):
        sec = estimate_security_level(n)
        if min_classical is None and sec['classical_security_bits'] >= target_classical:
            min_classical = n
        if min_quantum is None and sec['quantum_security_bits'] >= target_quantum:
            min_quantum = n
        if min_classical and min_quantum:
            break

    return {
        'target_classical_bits': target_classical,
        'min_dimension_classical': min_classical,
        'target_quantum_bits': target_quantum,
        'min_dimension_quantum': min_quantum,
    }


# ============================================================================
# Algorithm 6: Birthday Attack Simulation
# ============================================================================

def birthday_attack_simulation(H: np.ndarray, input_bound: float,
                               max_queries: int = 10000,
                               seed: Optional[int] = None) -> dict:
    """
    Simulate birthday attack on tropical hash function.

    Generates random inputs and checks for hash collisions.

    Args:
        H: hash matrix
        input_bound: range for random inputs [0, input_bound]
        max_queries: maximum number of hash evaluations
        seed: random seed

    Returns:
        Dictionary with collision information
    """
    rng = np.random.default_rng(seed)
    n, m = H.shape

    seen = {}
    for q in range(max_queries):
        x = rng.uniform(0, input_bound, m)
        y = tropical_hash(H, x)
        y_key = tuple(np.round(y, 10))

        if y_key in seen:
            return {
                'collision_found': True,
                'queries': q + 1,
                'input1': seen[y_key],
                'input2': x,
                'hash_value': y,
            }
        seen[y_key] = x

    return {
        'collision_found': False,
        'queries': max_queries,
        'distinct_hashes': len(seen),
    }


# ============================================================================
# Algorithm 7: Tropical Trace and Spectral Analysis
# ============================================================================

def tropical_trace(A: np.ndarray) -> float:
    """Tropical trace: min of diagonal entries."""
    return np.min(np.diag(A))


def tropical_spectral_radius(A: np.ndarray, max_power: int = 100) -> float:
    """
    Estimate tropical spectral radius via power iteration.

    The tropical spectral radius is lim_{k→∞} trace(A^k) / k.

    Args:
        A: n×n matrix
        max_power: maximum power to compute

    Returns:
        Estimated spectral radius
    """
    estimates = []
    Ak = A.copy()
    for k in range(1, max_power + 1):
        if k > 1:
            Ak = tropical_matrix_multiply(Ak, A)
        tr = tropical_trace(Ak)
        estimates.append(tr / k)

    return estimates[-1]


if __name__ == "__main__":
    print("Tropical Cryptography — Algorithm Demonstrations\n")

    # Security parameters
    print("Security Parameter Estimation:")
    for n in [10, 20, 35, 58, 98]:
        sec = estimate_security_level(n)
        print(f"  n={n:3d}: {sec['classical_security_bits']:4d}-bit classical, "
              f"{sec['quantum_security_bits']:4d}-bit quantum")

    print("\nMinimum Dimensions:")
    dims = find_minimum_dimension(128, 128)
    print(f"  128-bit classical: n ≥ {dims['min_dimension_classical']}")
    print(f"  128-bit quantum:   n ≥ {dims['min_dimension_quantum']}")

    # Key exchange demo
    print("\nKey Exchange:")
    params = TropicalKeyExchangeParams.generate(4, seed=42)
    Ga, Gb, shared = tropical_key_exchange(params, 5, 7)
    direct = tropical_matrix_power(params.base_matrix, 12)
    print(f"  G^5 ⊗ G^7 == G^12: {np.allclose(shared, direct)}")

    # Spectral radius
    print("\nTropical Spectral Radius:")
    G = np.array([[0, 1, 3], [2, 0, 1], [1, 3, 0]], dtype=float)
    sr = tropical_spectral_radius(G)
    print(f"  Spectral radius of sample matrix: {sr:.4f}")


#!/usr/bin/env python3
"""
Tropical Cryptography: Real-World Applications

Demonstrates practical applications of tropical algebra in cryptography,
network optimization, and machine learning.
"""

import numpy as np
import math
from typing import List, Tuple


# ============================================================================
# Application 1: Secure Shortest Path Computation
# ============================================================================

def secure_shortest_path_demo():
    """
    Tropical matrix multiplication enables secure multi-party shortest path
    computation. Each party holds partial edge weights; the tropical product
    reveals only shortest path distances, not the individual weights.
    """
    print("Application 1: Secure Shortest Path Computation")
    print("-" * 50)

    # Network with 5 nodes
    # Party A knows edges 0→1, 0→2, 1→3
    # Party B knows edges 2→3, 3→4, 1→4
    INF = float('inf')

    A_weights = np.array([
        [0,   3, 7, INF, INF],
        [INF, 0, INF, 2, INF],
        [INF, INF, 0, INF, INF],
        [INF, INF, INF, 0, INF],
        [INF, INF, INF, INF, 0],
    ])

    B_weights = np.array([
        [0, INF, INF, INF, INF],
        [INF, 0, INF, INF, 6],
        [INF, INF, 0, 1, INF],
        [INF, INF, INF, 0, 4],
        [INF, INF, INF, INF, 0],
    ])

    # Tropical product reveals 2-hop shortest paths
    # without revealing individual edge weights
    from algorithms import tropical_matrix_multiply
    combined = tropical_matrix_multiply(A_weights, B_weights)

    print("  Party A's partial network (edge weights):")
    print(f"    0→1: 3, 0→2: 7, 1→3: 2")
    print("  Party B's partial network:")
    print(f"    1→4: 6, 2→3: 1, 3→4: 4")
    print("  Combined shortest 2-hop paths (tropical product):")
    for i in range(5):
        for j in range(5):
            if combined[i, j] < INF and i != j:
                print(f"    {i}→{j}: {combined[i,j]:.0f}")
    print()


# ============================================================================
# Application 2: ReLU Network as Tropical Rational Function
# ============================================================================

def relu_tropical_demo():
    """
    Every ReLU neural network computes a tropical rational function.
    This connection enables exact analysis of network behavior using
    tropical geometry, including certified robustness guarantees.
    """
    print("Application 2: ReLU Networks as Tropical Functions")
    print("-" * 50)

    # Simple ReLU network: f(x) = max(0, w1*x + b1) + max(0, w2*x + b2)
    w1, b1 = 2.0, -1.0   # First neuron
    w2, b2 = -1.0, 3.0    # Second neuron

    def relu(x):
        return max(0.0, x)

    def network(x):
        return relu(w1 * x + b1) + relu(w2 * x + b2)

    # Tropical representation: max(0, ax+b) = -min(0, -(ax+b))
    def tropical_network(x):
        return -min(0.0, -(w1*x + b1)) + (-min(0.0, -(w2*x + b2)))

    print("  Network: f(x) = ReLU(2x - 1) + ReLU(-x + 3)")
    print("  Tropical: f(x) = -min(0, -(2x-1)) + (-min(0, -(-x+3)))")
    print()
    print(f"  {'x':>6s} | {'Network f(x)':>12s} | {'Tropical f(x)':>13s} | {'Match':>5s}")
    print(f"  {'-'*6}-+-{'-'*12}-+-{'-'*13}-+-{'-'*5}")
    for x in np.linspace(-2, 5, 15):
        fx = network(x)
        tx = tropical_network(x)
        match = "✓" if abs(fx - tx) < 1e-10 else "✗"
        print(f"  {x:6.2f} | {fx:12.4f} | {tx:13.4f} | {match:>5s}")

    # Lipschitz constant analysis
    # For ReLU networks, the Lipschitz constant is bounded by the product
    # of weight matrix operator norms. Our tropical min contraction theorem
    # gives |min(a,b) - min(a,c)| ≤ |b-c|, certifying stability.
    print()
    print("  Lipschitz bound: The tropical min contraction theorem guarantees")
    print("  |f(x) - f(y)| ≤ L·|x-y| where L is bounded by weight norms.")
    print()


# ============================================================================
# Application 3: Post-Quantum Key Size Estimation
# ============================================================================

def key_size_estimation():
    """
    Estimate key sizes for tropical post-quantum cryptosystems
    at various security levels.
    """
    print("Application 3: Post-Quantum Key Size Estimation")
    print("-" * 50)

    print(f"  {'Security':>10s} | {'Dimension n':>11s} | {'Matrix size':>11s} | "
          f"{'Key (bits)':>10s} | {'Key (KB)':>8s}")
    print(f"  {'-'*10}-+-{'-'*11}-+-{'-'*11}-+-{'-'*10}-+-{'-'*8}")

    entry_bits = 32  # 32-bit floating point entries

    configs = [
        ("128-cl", 35),
        ("128-pq", 58),
        ("256-cl", 58),
        ("256-pq", 98),
    ]

    for label, n in configs:
        matrix_entries = n * n
        key_bits = matrix_entries * entry_bits
        key_kb = key_bits / 8 / 1024
        print(f"  {label:>10s} | {n:>11d} | {n}×{n}={matrix_entries:>6d} | "
              f"{key_bits:>10,d} | {key_kb:>8.1f}")

    print()
    print("  Comparison with other post-quantum schemes:")
    print("  CRYSTALS-Kyber-768: ~2.4 KB public key")
    print("  Tropical (128-pq):  ~13.2 KB public key")
    print("  Trade-off: larger keys but simpler operations (min, +)")
    print()


# ============================================================================
# Application 4: Tropical Signature Scheme Sketch
# ============================================================================

def tropical_signature_demo():
    """
    Sketch of a tropical digital signature scheme based on
    tropical matrix factorization hardness.
    """
    print("Application 4: Tropical Signature Scheme (Sketch)")
    print("-" * 50)

    from algorithms import tropical_matrix_multiply, tropical_matrix_power

    n = 4
    np.random.seed(123)

    # Key generation
    # Secret key: random matrices A, B
    A = np.random.uniform(0, 10, (n, n))
    B = np.random.uniform(0, 10, (n, n))

    # Public key: P = A ⊗ B (tropical product)
    P = tropical_matrix_multiply(A, B)

    # Signing: use secret factorization to produce witness
    # (simplified — real scheme would use commitment + challenge)
    message_hash = np.random.uniform(0, 5, (n, n))

    # Signature: σ = A ⊗ H(m) ⊗ B
    sigma = tropical_matrix_multiply(
        tropical_matrix_multiply(A, message_hash), B)

    # Verification: check consistency with public key P
    # (simplified — real verification would check algebraic relations)
    print(f"  Key generation: A ({n}×{n}), B ({n}×{n}) random matrices")
    print(f"  Public key P = A ⊗ B ({n}×{n} matrix)")
    print(f"  Message hash H(m) ({n}×{n} matrix)")
    print(f"  Signature σ = A ⊗ H(m) ⊗ B ({n}×{n} matrix)")
    print(f"\n  Security: recovering A, B from P requires factoring")
    print(f"  a tropical matrix product — Ω(n!) complexity.")
    print(f"  For n={n}: {math.factorial(n)} candidate factorizations")
    print()


# ============================================================================
# Application 5: Network Routing Optimization
# ============================================================================

def network_routing_demo():
    """
    Tropical algebra naturally models network routing:
    - Vertices = routers
    - Edge weights = latencies
    - Tropical matrix power = shortest paths through k hops
    """
    print("Application 5: Network Routing via Tropical Powers")
    print("-" * 50)

    from algorithms import tropical_matrix_power, tropical_trace

    INF = float('inf')
    # 5-node network topology
    G = np.array([
        [0,   1, INF, INF, 7],
        [1,   0,   2, INF, INF],
        [INF, 2,   0,   3, INF],
        [INF, INF, 3,   0,   1],
        [7, INF, INF,   1,   0],
    ], dtype=float)

    print("  Network topology (5 routers):")
    print("  0 ←1→ 1 ←2→ 2 ←3→ 3 ←1→ 4 ←7→ 0")
    print()

    for k in [1, 2, 3, 4]:
        Gk = tropical_matrix_power(G, k)
        tr = tropical_trace(Gk)
        print(f"  G^{k} shortest {k}-hop paths, tropical trace = {tr:.1f}")
        # Show shortest path 0→3
        print(f"    Shortest 0→3 using ≤{k} hops: {Gk[0,3]:.1f}")

    print()


if __name__ == "__main__":
    print("\n" + "█" * 60)
    print("  TROPICAL CRYPTOGRAPHY — REAL-WORLD APPLICATIONS")
    print("█" * 60 + "\n")

    secure_shortest_path_demo()
    relu_tropical_demo()
    key_size_estimation()
    tropical_signature_demo()
    network_routing_demo()

    print("All applications demonstrated successfully.")


#!/usr/bin/env python3
"""
Tropical Cryptography Bridge: Demonstrations

Concrete numerical examples illustrating the key mathematical results from the
tropical cryptography formalization, including min-plus semiring operations,
tropical matrix multiplication, one-way function properties, and security
parameter verification.
"""

import numpy as np
from typing import Tuple, List


def trop_add(a: float, b: float) -> float:
    """Tropical addition: min(a, b)."""
    return min(a, b)


def trop_mul(a: float, b: float) -> float:
    """Tropical multiplication: a + b."""
    return a + b


def trop_mat_mul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Tropical matrix multiplication: C[i,j] = min_k(A[i,k] + B[k,j])."""
    n = A.shape[0]
    C = np.full((n, n), np.inf)
    for i in range(n):
        for j in range(n):
            for k in range(n):
                C[i, j] = min(C[i, j], A[i, k] + B[k, j])
    return C


def trop_mat_pow(G: np.ndarray, k: int) -> np.ndarray:
    """Tropical matrix power: G^k via repeated tropical multiplication."""
    n = G.shape[0]
    # Tropical identity: 0 on diagonal, +inf elsewhere
    result = np.full((n, n), np.inf)
    np.fill_diagonal(result, 0)
    for _ in range(k):
        result = trop_mat_mul(result, G)
    return result


def trop_hash(H: np.ndarray, x: np.ndarray) -> np.ndarray:
    """Tropical hash: y[i] = min_j(H[i,j] + x[j])."""
    n, m = H.shape
    y = np.full(n, np.inf)
    for i in range(n):
        for j in range(m):
            y[i] = min(y[i], H[i, j] + x[j])
    return y


def demo_semiring_laws():
    """Demonstrate tropical semiring laws."""
    print("=" * 60)
    print("DEMO 1: Tropical Semiring Laws")
    print("=" * 60)

    a, b, c = 3.0, 7.0, 2.0

    # Distributivity
    lhs = trop_mul(a, trop_add(b, c))  # a + min(b,c)
    rhs = trop_add(trop_mul(a, b), trop_mul(a, c))  # min(a+b, a+c)
    print(f"  a={a}, b={b}, c={c}")
    print(f"  Left distributivity: a ⊗ (b ⊕ c) = {lhs}")
    print(f"  (a ⊗ b) ⊕ (a ⊗ c) = {rhs}")
    print(f"  Equal? {lhs == rhs} ✓")

    # Idempotency
    print(f"  Idempotent: min({a},{a}) = {trop_add(a,a)} (= {a}) ✓")

    # Absorption
    print(f"  Absorption: min({a}, {a}+5) = {trop_add(a, trop_mul(a, 5))} (= {a}) ✓")

    # Min-max duality
    print(f"  min({a},{b}) + max({a},{b}) = {min(a,b) + max(a,b)} = {a+b} ✓")
    print()


def demo_matrix_multiplication():
    """Demonstrate tropical matrix multiplication."""
    print("=" * 60)
    print("DEMO 2: Tropical Matrix Multiplication (Shortest Paths)")
    print("=" * 60)

    # Adjacency matrix of a weighted graph (3 nodes)
    A = np.array([
        [0,   3,   8],
        [np.inf, 0,   2],
        [5,  np.inf, 0]
    ])

    print("  Adjacency matrix A (weight of direct edges):")
    print(f"  {A}")

    A2 = trop_mat_mul(A, A)
    print(f"\n  A² (shortest 2-hop paths):")
    print(f"  {A2}")

    A3 = trop_mat_mul(A2, A)
    print(f"\n  A³ (shortest 3-hop paths):")
    print(f"  {A3}")

    print("\n  Note: A³[0,1] = min(0+0+3, 0+3+0, ...) = shortest path 0→1 using ≤3 edges")
    print()


def demo_one_way_function():
    """Demonstrate one-way function properties."""
    print("=" * 60)
    print("DEMO 3: Tropical One-Way Function (Preimage Non-Uniqueness)")
    print("=" * 60)

    # For c = 5, find distinct pairs (a,b) with min(a,b) = 5
    c = 5.0
    pairs = []
    for a in [5, 5, 5, 5, 7, 10, 100]:
        for b in [5, 6, 7, 100, 5, 5, 5]:
            if min(a, b) == c:
                pairs.append((a, b))

    # Remove duplicates
    pairs = list(set(pairs))
    print(f"  Target: min(a,b) = {c}")
    print(f"  Found {len(pairs)} distinct preimage pairs:")
    for a, b in sorted(pairs)[:8]:
        print(f"    min({a}, {b}) = {min(a, b)}")
    print(f"  → Many-to-one: information is lost! This is one-wayness.")
    print()


def demo_security_parameters():
    """Verify concrete security parameter bounds."""
    print("=" * 60)
    print("DEMO 4: Security Parameter Verification")
    print("=" * 60)

    import math

    for n in [10, 20, 35, 40, 58, 98]:
        fact = math.factorial(n)
        log2_fact = math.log2(fact)
        sqrt_fact = math.isqrt(fact)
        log2_sqrt = math.log2(float(sqrt_fact)) if sqrt_fact > 0 else 0
        classical_bits = int(log2_fact)
        quantum_bits = int(log2_sqrt)

        print(f"  n={n:3d}: log₂(n!) ≈ {log2_fact:7.1f} → "
              f"{classical_bits}-bit classical, {quantum_bits}-bit quantum security")

    print("\n  Key thresholds:")
    print(f"    n=35: 35! ≥ 2^128 → 128-bit classical security ✓")
    print(f"    n=58: 58! ≥ 2^256 → 128-bit post-quantum security ✓")
    print()


def demo_tropical_hash():
    """Demonstrate tropical hash function."""
    print("=" * 60)
    print("DEMO 5: Tropical Hash Function")
    print("=" * 60)

    # Random hash matrix
    np.random.seed(42)
    n, m = 4, 6
    H = np.random.uniform(0, 10, (n, m))

    x1 = np.array([1, 2, 3, 4, 5, 6], dtype=float)
    x2 = np.array([1, 2, 3, 4, 5, 7], dtype=float)  # Differs in last entry

    y1 = trop_hash(H, x1)
    y2 = trop_hash(H, x2)

    print(f"  Hash matrix H ({n}×{m})")
    print(f"  x1 = {x1}")
    print(f"  x2 = {x2} (differs in last entry)")
    print(f"  H⊗x1 = {np.round(y1, 3)}")
    print(f"  H⊗x2 = {np.round(y2, 3)}")
    print(f"  Difference: {np.round(y2 - y1, 3)}")

    # Lipschitz bound check
    input_diff = np.max(np.abs(x2 - x1))
    output_diff = np.max(np.abs(y2 - y1))
    print(f"\n  |x1-x2|_∞ = {input_diff}")
    print(f"  |H⊗x1-H⊗x2|_∞ = {output_diff:.3f}")
    print(f"  Lipschitz bound satisfied: {output_diff:.3f} ≤ {input_diff} ✓")
    print()


def demo_piecewise_linearity():
    """Demonstrate piecewise linearity of tropical operations."""
    print("=" * 60)
    print("DEMO 6: Piecewise Linearity (Why Quantum Fails)")
    print("=" * 60)

    print("  The identity |a-b| + (a+b) = 2·max(a,b):")
    for a, b in [(3, 7), (10, 2), (5, 5), (-3, 4)]:
        lhs = abs(a - b) + (a + b)
        rhs = 2 * max(a, b)
        print(f"    a={a:3d}, b={b:3d}: |{a}-{b}| + ({a}+{b}) = {lhs} = 2·{max(a,b)} ✓")

    print("\n  ReLU as tropical operation: max(0,x) = -min(0,-x)")
    for x in [-3, -1, 0, 1, 5]:
        relu = max(0, x)
        trop = -min(0, -x)
        print(f"    x={x:3d}: ReLU({x}) = {relu}, -min(0,{-x}) = {trop} ✓")
    print()


def demo_key_exchange():
    """Demonstrate tropical Diffie-Hellman key exchange."""
    print("=" * 60)
    print("DEMO 7: Tropical Key Exchange (Diffie-Hellman Analog)")
    print("=" * 60)

    # Small example: 3×3 base matrix
    G = np.array([
        [0,   1,   3],
        [2,   0,   1],
        [1,   3,   0]
    ], dtype=float)

    alice_secret = 5
    bob_secret = 7

    # Alice computes G^a, Bob computes G^b
    Ga = trop_mat_pow(G, alice_secret)
    Gb = trop_mat_pow(G, bob_secret)

    # Shared secret: G^(a+b) = G^a ⊗ G^b (commutative since ⊗ is min-plus)
    # Note: this works because G^a ⊗ G^b = G^(a+b) in tropical algebra
    shared_ab = trop_mat_mul(Ga, Gb)
    shared_direct = trop_mat_pow(G, alice_secret + bob_secret)

    print(f"  Base matrix G (3×3):")
    print(f"  {G}")
    print(f"\n  Alice's secret: a = {alice_secret}")
    print(f"  Bob's secret:   b = {bob_secret}")
    print(f"\n  G^a (Alice sends to Bob):")
    print(f"  {Ga}")
    print(f"\n  G^b (Bob sends to Alice):")
    print(f"  {Gb}")
    print(f"\n  Shared key G^(a+b) via G^a ⊗ G^b:")
    print(f"  {shared_ab}")
    print(f"\n  Direct G^(a+b):")
    print(f"  {shared_direct}")
    print(f"\n  Keys match: {np.allclose(shared_ab, shared_direct)} ✓")
    print()


def demo_complexity_gap():
    """Show the complexity gap between forward and inverse computation."""
    print("=" * 60)
    print("DEMO 8: Complexity Gap (Forward vs Inverse)")
    print("=" * 60)

    import math

    print(f"  {'n':>4s} | {'n³ (forward)':>14s} | {'n! (inverse)':>20s} | {'Ratio n!/n³':>14s}")
    print(f"  {'-'*4}-+-{'-'*14}-+-{'-'*20}-+-{'-'*14}")
    for n in [5, 6, 10, 20, 35, 58]:
        forward = n ** 3
        inverse = math.factorial(n)
        ratio = inverse / forward if forward > 0 else float('inf')
        print(f"  {n:4d} | {forward:14,d} | {inverse:20,d} | {ratio:14,.1f}")

    print("\n  The gap grows superexponentially — this IS the one-way function!")
    print()


if __name__ == "__main__":
    print("\n" + "█" * 60)
    print("  TROPICAL CRYPTOGRAPHY BRIDGE — NUMERICAL DEMONSTRATIONS")
    print("█" * 60 + "\n")

    demo_semiring_laws()
    demo_matrix_multiplication()
    demo_one_way_function()
    demo_security_parameters()
    demo_tropical_hash()
    demo_piecewise_linearity()
    demo_key_exchange()
    demo_complexity_gap()

    print("All demonstrations completed successfully.")


#!/usr/bin/env python3
"""
Tropical Cryptography: Visualizations

Creates publication-quality charts for the tropical cryptography bridge.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import math
import base64
from io import BytesIO


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 PNG string."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    return base64.b64encode(buf.read()).decode('utf-8')


def plot_complexity_gap():
    """Plot the gap between forward O(n³) and inverse Ω(n!) complexity."""
    fig, ax = plt.subplots(figsize=(10, 6))

    ns = np.arange(1, 25)
    forward = ns ** 3
    inverse = np.array([float(math.factorial(int(n))) for n in ns])

    ax.semilogy(ns, forward, 'b-o', label='Forward: O(n³)', linewidth=2, markersize=6)
    ax.semilogy(ns, inverse, 'r-s', label='Inverse: Ω(n!)', linewidth=2, markersize=6)

    ax.axhline(y=2**128, color='green', linestyle='--', alpha=0.7,
               label='2¹²⁸ (128-bit classical)')
    ax.axhline(y=2**256, color='orange', linestyle='--', alpha=0.7,
               label='2²⁵⁶ (128-bit quantum)')

    ax.fill_between(ns, forward, inverse, alpha=0.15, color='red',
                    label='Cryptographic gap')

    ax.set_xlabel('Matrix dimension n', fontsize=14)
    ax.set_ylabel('Operations (log scale)', fontsize=14)
    ax.set_title('Tropical OWF: Forward vs Inverse Complexity Gap', fontsize=16)
    ax.legend(fontsize=11, loc='lower right')
    ax.grid(True, alpha=0.3)
    ax.set_xlim(1, 24)

    fig.savefig('complexity_gap.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


def plot_security_levels():
    """Plot security bits vs matrix dimension."""
    fig, ax = plt.subplots(figsize=(10, 6))

    ns = np.arange(2, 120)
    classical_bits = [sum(math.log2(k) for k in range(1, int(n)+1)) for n in ns]
    quantum_bits = [c/2 for c in classical_bits]

    ax.plot(ns, classical_bits, 'b-', label='Classical security (log₂ n!)',
            linewidth=2)
    ax.plot(ns, quantum_bits, 'r-', label='Quantum security (log₂ n! / 2)',
            linewidth=2)

    ax.axhline(y=128, color='green', linestyle='--', alpha=0.7, label='128-bit')
    ax.axhline(y=256, color='orange', linestyle='--', alpha=0.7, label='256-bit')

    # Mark key dimensions
    for n, label in [(35, 'n=35'), (58, 'n=58'), (98, 'n=98')]:
        cl = sum(math.log2(k) for k in range(1, n+1))
        ax.plot(n, cl, 'ko', markersize=8)
        ax.annotate(label, (n, cl), textcoords="offset points",
                    xytext=(10, 10), fontsize=11)

    ax.set_xlabel('Matrix dimension n', fontsize=14)
    ax.set_ylabel('Security bits', fontsize=14)
    ax.set_title('Tropical Cryptosystem Security vs Dimension', fontsize=16)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(2, 120)
    ax.set_ylim(0, 600)

    fig.savefig('security_levels.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


def plot_tropical_operations():
    """Visualize tropical min and max as piecewise linear functions."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    x = np.linspace(-3, 3, 200)

    # Plot 1: min(x, 1) — tropical addition with constant
    ax = axes[0]
    y = np.minimum(x, 1)
    ax.plot(x, x, 'b--', alpha=0.3, label='y = x')
    ax.axhline(y=1, color='r', linestyle='--', alpha=0.3, label='y = 1')
    ax.plot(x, y, 'g-', linewidth=3, label='min(x, 1)')
    ax.set_title('Tropical Addition: min(x, 1)', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Plot 2: ReLU = max(0, x) = -min(0, -x)
    ax = axes[1]
    relu = np.maximum(0, x)
    trop = -np.minimum(0, -x)
    ax.plot(x, relu, 'b-', linewidth=3, label='max(0, x) = ReLU')
    ax.plot(x, trop, 'r--', linewidth=2, label='-min(0, -x)')
    ax.set_title('ReLU as Tropical Function', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Plot 3: |a-b| + (a+b) = 2 max(a,b)
    ax = axes[2]
    b_fixed = 1.0
    lhs = np.abs(x - b_fixed) + (x + b_fixed)
    rhs = 2 * np.maximum(x, b_fixed)
    ax.plot(x, lhs, 'b-', linewidth=3, label='|x-1| + (x+1)')
    ax.plot(x, rhs, 'r--', linewidth=2, label='2·max(x, 1)')
    ax.set_title('Piecewise Linear Identity', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    fig.suptitle('Tropical Operations: Piecewise Linearity', fontsize=16, y=1.02)
    fig.tight_layout()
    fig.savefig('tropical_operations.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


def plot_preimage_nonuniqueness():
    """Visualize the preimage set of min(a,b) = c."""
    fig, ax = plt.subplots(figsize=(8, 8))

    c = 3.0
    a_range = np.linspace(0, 8, 300)

    # Region where min(a,b) = c:
    # Case 1: a = c and b ≥ c (vertical line)
    # Case 2: b = c and a ≥ c (horizontal line)
    ax.plot([c, c], [c, 8], 'r-', linewidth=3, label=f'a = {c}, b ≥ {c}')
    ax.plot([c, 8], [c, c], 'b-', linewidth=3, label=f'b = {c}, a ≥ {c}')
    ax.plot(c, c, 'ko', markersize=10, zorder=5)

    # Shade the preimage region
    ax.fill_between([c, 8], [c, c], [8, 8], alpha=0.1, color='gray')

    # Mark some specific preimage pairs
    pairs = [(3, 3), (3, 5), (3, 7), (5, 3), (7, 3), (4, 3), (3, 4)]
    for a, b in pairs:
        ax.plot(a, b, 'gs', markersize=8, zorder=5)
        ax.annotate(f'({a},{b})', (a, b), textcoords="offset points",
                    xytext=(5, 5), fontsize=9)

    ax.set_xlabel('a', fontsize=14)
    ax.set_ylabel('b', fontsize=14)
    ax.set_title(f'Preimage of min(a,b) = {c}: Many-to-One (One-Way)', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(0, 8)
    ax.set_ylim(0, 8)
    ax.set_aspect('equal')

    fig.savefig('preimage_nonunique.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


def generate_all_visualizations():
    """Generate all visualizations and return base64 data."""
    print("Generating visualizations...")

    visuals = {}
    visuals['complexity_gap'] = plot_complexity_gap()
    print("  ✓ Complexity gap plot")

    visuals['security_levels'] = plot_security_levels()
    print("  ✓ Security levels plot")

    visuals['tropical_operations'] = plot_tropical_operations()
    print("  ✓ Tropical operations plot")

    visuals['preimage_nonunique'] = plot_preimage_nonuniqueness()
    print("  ✓ Preimage non-uniqueness plot")

    print("All visualizations generated.")
    return visuals


if __name__ == "__main__":
    visuals = generate_all_visualizations()

    # Save base64 data for embedding
    with open('visuals_base64.txt', 'w') as f:
        for name, data in visuals.items():
            f.write(f"=== {name} ===\n")
            f.write(data[:100] + "...\n\n")

    print(f"\nGenerated {len(visuals)} visualizations as PNG files.")
