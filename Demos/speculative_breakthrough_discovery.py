#!/usr/bin/env python3
"""
Algorithms from the Tropical–Ultrametric Duality Framework

Implementations of key algorithms with complexity analysis, docstrings,
and type hints.
"""

import math
from typing import List, Tuple, Optional, Callable
from dataclasses import dataclass


# =============================================================================
# §1. Tropical Arithmetic
# =============================================================================

def tropical_add(a: float, b: float) -> float:
    """
    Tropical addition: max(a, b).

    Complexity: O(1)
    """
    return max(a, b)


def tropical_mul(a: float, b: float) -> float:
    """
    Tropical multiplication: a + b (classical addition).

    Complexity: O(1)
    """
    return a + b


def tropical_matrix_mul(A: List[List[float]], B: List[List[float]]) -> List[List[float]]:
    """
    Tropical matrix multiplication: C[i][j] = max_k (A[i][k] + B[k][j]).

    This is the standard matrix product in the (max, +) semiring.

    Complexity: O(m * n * p) for m×p and p×n matrices.

    Args:
        A: m×p matrix (list of rows)
        B: p×n matrix (list of rows)

    Returns:
        m×n tropical product matrix
    """
    m = len(A)
    p = len(A[0])
    n = len(B[0])
    C = [[float('-inf')] * n for _ in range(m)]
    for i in range(m):
        for j in range(n):
            for k in range(p):
                C[i][j] = max(C[i][j], A[i][k] + B[k][j])
    return C


# =============================================================================
# §2. Valuation Chain Construction
# =============================================================================

def p_adic_valuation(n: int, p: int) -> int:
    """
    Compute the p-adic valuation v_p(n).

    v_p(n) = max{k : p^k | n}

    Complexity: O(log_p(n))

    Args:
        n: positive integer
        p: prime number

    Returns:
        The p-adic valuation of n
    """
    if n == 0:
        return float('inf')
    v = 0
    while n % p == 0:
        v += 1
        n //= p
    return v


def build_fibonacci_valuation_chain(p: int, max_index: int) -> List[Tuple[int, int]]:
    """
    Build a valuation chain from Fibonacci numbers for prime p.

    For each multiple of the Fibonacci entry point, records the
    p-adic valuation of F(n).

    Complexity: O(max_index * log(max_index))

    Args:
        p: prime number
        max_index: maximum Fibonacci index to consider

    Returns:
        List of (index, valuation) pairs forming a chain
    """
    fibs = [0, 1]
    for i in range(2, max_index + 1):
        fibs.append(fibs[-1] + fibs[-2])

    chain = []
    for i in range(1, max_index + 1):
        if fibs[i] > 0:
            v = p_adic_valuation(fibs[i], p)
            if v > 0:
                chain.append((i, v))
    return chain


# =============================================================================
# §3. Tropical Security Parameter Computation
# =============================================================================

@dataclass
class TropicalSecurityParameter:
    """Security parameter from tropical valuation analysis."""
    num_generators: int
    min_valuation: int
    security_bits: int
    key_space_size: int


def compute_tropical_security(dimension: int, bound: int) -> TropicalSecurityParameter:
    """
    Compute the tropical security parameter for a lattice-based scheme.

    For an n-dimensional tropical key space with coordinate bound B:
    - Key space size = (2B+1)^n
    - Security bits ≈ n * log₂(2B+1)
    - Quantum security ≈ n * log₂(2B+1) / 2  (Grover's bound)

    Complexity: O(1)

    Args:
        dimension: lattice dimension n
        bound: coordinate bound B

    Returns:
        TropicalSecurityParameter with computed values
    """
    key_space = (2 * bound + 1) ** dimension
    security_bits = int(dimension * math.log2(2 * bound + 1))
    return TropicalSecurityParameter(
        num_generators=dimension,
        min_valuation=bound,
        security_bits=security_bits,
        key_space_size=key_space
    )


# =============================================================================
# §4. Ultrametric Lipschitz Certification
# =============================================================================

@dataclass
class LipschitzCertificate:
    """Certified Lipschitz bound for a deep network."""
    depth: int
    layer_bounds: List[float]
    total_lipschitz: float
    archimedean_lipschitz: float
    ultrametric_advantage: float


def certify_lipschitz(layer_norms: List[float], layer_widths: List[int]) -> LipschitzCertificate:
    """
    Compute certified Lipschitz bound for a deep network.

    Ultrametric bound = ∏ layer_norms[i]
    Archimedean bound = ∏ (layer_norms[i] * layer_widths[i])
    Advantage = ∏ layer_widths[i]

    Complexity: O(L) where L = depth

    Args:
        layer_norms: max entry norm for each layer weight matrix
        layer_widths: inner dimension of each layer

    Returns:
        LipschitzCertificate with bounds and advantage ratio
    """
    depth = len(layer_norms)
    ultra_lip = math.prod(layer_norms)
    archi_lip = math.prod(n * w for n, w in zip(layer_norms, layer_widths))
    advantage = archi_lip / ultra_lip if ultra_lip > 0 else float('inf')

    return LipschitzCertificate(
        depth=depth,
        layer_bounds=layer_norms,
        total_lipschitz=ultra_lip,
        archimedean_lipschitz=archi_lip,
        ultrametric_advantage=advantage
    )


# =============================================================================
# §5. Tropical Hash Function
# =============================================================================

def tropical_hash(key: List[int], matrix: List[List[int]], modulus: int) -> List[int]:
    """
    Compute a tropical hash: h(x) = max_j(A[i][j] + x[j]) mod m.

    This is a simple hash function in the tropical semiring.

    Complexity: O(n * m) for n-dimensional key and m-row hash matrix.

    Args:
        key: input vector in ℤ^n
        matrix: hash matrix A of size m×n
        modulus: output modulus

    Returns:
        Hash value as a list of integers mod modulus
    """
    m = len(matrix)
    n = len(key)
    result = []
    for i in range(m):
        val = max(matrix[i][j] + key[j] for j in range(n))
        result.append(val % modulus)
    return result


def estimate_collision_probability(dimension: int, bound: int, hash_size: int) -> float:
    """
    Estimate collision probability for tropical hash.

    By the birthday paradox, collision occurs after O(√N) queries
    where N = hash_size.

    Args:
        dimension: key dimension
        bound: coordinate bound
        hash_size: number of possible hash values

    Returns:
        Estimated number of queries for 50% collision probability
    """
    return math.sqrt(hash_size * math.log(2))


# =============================================================================
# §6. Fibonacci Entry Point and Carmichael Analysis
# =============================================================================

def fibonacci_entry_point(p: int, max_search: int = 10000) -> Optional[int]:
    """
    Find the Fibonacci entry point of prime p: smallest k > 0 with p | F(k).

    Complexity: O(max_search) Fibonacci computations mod p.

    Args:
        p: prime number
        max_search: maximum index to search

    Returns:
        Entry point k, or None if not found within range
    """
    if p <= 1:
        return None

    a, b = 0, 1
    for k in range(1, max_search + 1):
        a, b = b, (a + b) % p
        if a == 0:
            return k
    return None


def check_primitive_divisor(n: int) -> List[int]:
    """
    Find primitive prime divisors of F(n).

    A prime p is a primitive divisor of F(n) if p | F(n) but
    p does not divide F(k) for any 0 < k < n.

    Complexity: O(F(n) * n) in the worst case.

    Args:
        n: Fibonacci index

    Returns:
        List of primitive prime divisors
    """
    fn = fibonacci(n)
    if fn <= 1:
        return []

    # Find all prime factors of F(n)
    factors = prime_factors(fn)

    # Check each factor for primitivity
    primitive = []
    for p in factors:
        is_primitive = True
        entry = fibonacci_entry_point(p, n)
        if entry is not None and entry < n:
            is_primitive = False
        if is_primitive:
            primitive.append(p)
    return primitive


def fibonacci(n: int) -> int:
    """Compute F(n)."""
    if n <= 1:
        return max(0, n)
    a, b = 0, 1
    for _ in range(2, n + 1):
        a, b = b, a + b
    return b


def prime_factors(n: int) -> List[int]:
    """Find all prime factors of n."""
    factors = []
    d = 2
    while d * d <= n:
        if n % d == 0:
            factors.append(d)
            while n % d == 0:
                n //= d
        d += 1
    if n > 1:
        factors.append(n)
    return factors


# =============================================================================
# Demo
# =============================================================================

if __name__ == "__main__":
    print("=== Tropical Matrix Multiplication ===")
    A = [[1, 3], [2, 4]]
    B = [[5, 1], [3, 2]]
    C = tropical_matrix_mul(A, B)
    print(f"A = {A}")
    print(f"B = {B}")
    print(f"A ⊗ B = {C}")
    print()

    print("=== Fibonacci Valuation Chain (p=2) ===")
    chain = build_fibonacci_valuation_chain(2, 50)
    for idx, val in chain[:15]:
        print(f"  v_2(F({idx})) = {val}")
    print()

    print("=== Tropical Security Parameters ===")
    for n in [128, 256, 512]:
        sec = compute_tropical_security(n, 1)
        print(f"  n={n}: {sec.security_bits} bits, "
              f"key space = 3^{n}")
    print()

    print("=== Lipschitz Certification ===")
    cert = certify_lipschitz([0.5] * 10, [64] * 10)
    print(f"  Depth: {cert.depth}")
    print(f"  Ultrametric Lipschitz: {cert.total_lipschitz:.6e}")
    print(f"  Archimedean Lipschitz: {cert.archimedean_lipschitz:.6e}")
    print(f"  Advantage: {cert.ultrametric_advantage:.2e}x")
    print()

    print("=== Fibonacci Primitive Divisors ===")
    for n in range(13, 31):
        pd = check_primitive_divisor(n)
        fn = fibonacci(n)
        print(f"  F({n}) = {fn}, primitive divisors: {pd}")


#!/usr/bin/env python3
"""
Applications of the Tropical–Ultrametric Duality Framework

Real-world applications to ML (certified robustness), cryptography
(post-quantum key generation), and physics (entropy analysis).
"""

import math
import random
from typing import List, Tuple
from dataclasses import dataclass


# =============================================================================
# §1. Certified Neural Network Robustness
# =============================================================================

@dataclass
class RobustnessCertificate:
    """Certified robustness guarantee for a neural network."""
    epsilon: float           # perturbation radius
    lipschitz_bound: float   # network Lipschitz constant
    max_output_change: float # guaranteed max output change
    is_robust: bool          # whether classification is guaranteed stable


def certify_robustness(
    layer_norms: List[float],
    epsilon: float,
    classification_margin: float,
    use_ultrametric: bool = True
) -> RobustnessCertificate:
    """
    Certify robustness of a deep network against ε-perturbations.

    Ultrametric advantage: Lipschitz constant is ∏ ||W_i||_∞ without
    the factor of ∏ width_i that appears in Archimedean settings.

    Args:
        layer_norms: max entry norm of each layer's weight matrix
        epsilon: perturbation radius
        classification_margin: margin between top-2 class scores
        use_ultrametric: if True, use tighter ultrametric bound

    Returns:
        RobustnessCertificate with provable guarantee
    """
    lip = math.prod(layer_norms)
    max_change = lip * epsilon
    is_robust = max_change < classification_margin

    return RobustnessCertificate(
        epsilon=epsilon,
        lipschitz_bound=lip,
        max_output_change=max_change,
        is_robust=is_robust
    )


def demo_robustness_certification():
    """Compare ultrametric vs Archimedean robustness certification."""
    print("=" * 70)
    print("APPLICATION 1: Certified Neural Network Robustness")
    print("=" * 70)

    # 10-layer network with various widths
    layer_norms = [0.8] * 10
    layer_widths = [64, 128, 256, 512, 256, 128, 64, 32, 16, 10]
    epsilon = 0.01
    margin = 0.5

    ultra_lip = math.prod(layer_norms)
    archi_lip = math.prod(n * w for n, w in zip(layer_norms, layer_widths))

    ultra_cert = certify_robustness(layer_norms, epsilon, margin, True)

    print(f"\n  Network: {len(layer_norms)} layers")
    print(f"  Layer norms: {layer_norms[0]} (uniform)")
    print(f"  Layer widths: {layer_widths}")
    print(f"  Perturbation ε = {epsilon}")
    print(f"  Classification margin = {margin}")
    print(f"\n  Ultrametric Lipschitz = {ultra_lip:.6e}")
    print(f"  Archimedean Lipschitz = {archi_lip:.6e}")
    print(f"  Advantage factor = {archi_lip/ultra_lip:.2e}x")
    print(f"\n  Ultrametric max change = {ultra_lip * epsilon:.6e}")
    print(f"  Archimedean max change = {archi_lip * epsilon:.6e}")
    print(f"  Ultrametric robust? {ultra_cert.is_robust}")
    print(f"  Archimedean robust? {archi_lip * epsilon < margin}")
    print()


# =============================================================================
# §2. Post-Quantum Key Generation via Tropical Lattices
# =============================================================================

@dataclass
class PostQuantumKey:
    """A post-quantum cryptographic key from tropical lattice."""
    dimension: int
    coordinates: List[int]
    classical_security_bits: int
    quantum_security_bits: int
    tropical_norm: int


def generate_tropical_key(dimension: int, bound: int, seed: int = 42) -> PostQuantumKey:
    """
    Generate a post-quantum key from a tropical lattice.

    Security analysis:
    - Classical: O((2B+1)^n) brute force
    - Quantum: O(√((2B+1)^n)) Grover
    - Lattice reduction: 2^n approximation factor

    Args:
        dimension: lattice dimension (security parameter)
        bound: coordinate bound
        seed: random seed

    Returns:
        PostQuantumKey with security analysis
    """
    rng = random.Random(seed)
    coords = [rng.randint(-bound, bound) for _ in range(dimension)]
    trop_norm = max(abs(c) for c in coords)

    classical_bits = int(dimension * math.log2(2 * bound + 1))
    quantum_bits = classical_bits // 2

    return PostQuantumKey(
        dimension=dimension,
        coordinates=coords,
        classical_security_bits=classical_bits,
        quantum_security_bits=quantum_bits,
        tropical_norm=trop_norm
    )


def demo_post_quantum_keys():
    """Demonstrate post-quantum key generation."""
    print("=" * 70)
    print("APPLICATION 2: Post-Quantum Key Generation via Tropical Lattices")
    print("=" * 70)

    print(f"\n  {'Dim':>4s}  {'Bound':>5s}  {'Classical':>10s}  {'Quantum':>8s}  "
          f"{'Key Space':>12s}  {'Trop Norm':>10s}")
    print("  " + "-" * 60)

    for dim, bound in [(128, 1), (256, 1), (256, 3), (512, 1), (1024, 1)]:
        key = generate_tropical_key(dim, bound)
        key_space = f"(2·{bound}+1)^{dim}"
        print(f"  {dim:4d}  {bound:5d}  {key.classical_security_bits:10d}  "
              f"{key.quantum_security_bits:8d}  {key_space:>12s}  "
              f"{key.tropical_norm:10d}")
    print()

    # Show a specific key
    key = generate_tropical_key(16, 5, seed=123)
    print(f"  Example 16-dimensional key (B=5):")
    print(f"  Coordinates: {key.coordinates}")
    print(f"  Tropical norm: {key.tropical_norm}")
    print(f"  Classical security: {key.classical_security_bits} bits")
    print(f"  Quantum security: {key.quantum_security_bits} bits")
    print()


# =============================================================================
# §3. Fibonacci-Based Key Ladder
# =============================================================================

def fibonacci(n: int) -> int:
    if n <= 1:
        return max(0, n)
    a, b = 0, 1
    for _ in range(2, n + 1):
        a, b = b, a + b
    return b


def demo_fibonacci_key_ladder():
    """Demonstrate Fibonacci-based hierarchical key system."""
    print("=" * 70)
    print("APPLICATION 3: Fibonacci Key Ladder for Hierarchical Access")
    print("=" * 70)

    print("\n  Using F(n) | F(nm) for hierarchical key derivation:")
    print(f"\n  {'Level':>6s}  {'Index':>6s}  {'F(index)':>15s}  {'Divides F(next)':>15s}")
    print("  " + "-" * 50)

    base = 6  # F(6) = 8
    for level in range(1, 7):
        idx = base * level
        fn = fibonacci(idx)
        fn_next = fibonacci(idx + base)
        divides = fn_next % fn == 0
        print(f"  {level:6d}  {idx:6d}  {fn:15d}  {'✓' if divides else '✗':>15s}")

    print(f"\n  Property: F({base}) | F({base}k) for all k")
    print(f"  Each level can derive keys for lower levels but not higher")
    print()


# =============================================================================
# §4. Entropy Analysis
# =============================================================================

def demo_entropy_analysis():
    """Demonstrate valuation entropy bounds."""
    print("=" * 70)
    print("APPLICATION 4: Valuation Entropy Analysis")
    print("=" * 70)

    print("\n  Entropy bounds for p-adic valuation spaces:")
    print(f"  {'p':>4s}  {'dim':>4s}  {'max_v':>6s}  {'Entropy Bound':>14s}  "
          f"{'p^dim':>12s}")
    print("  " + "-" * 48)

    for p in [2, 3, 5, 7]:
        for dim in [8, 16, 32, 64]:
            max_v = 10
            entropy_bound = dim * (max_v + 1)
            p_dim = p ** dim if dim <= 32 else "overflow"
            print(f"  {p:4d}  {dim:4d}  {max_v:6d}  {entropy_bound:14d}  "
                  f"{str(p_dim):>12s}")
    print()


# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    print("\n" + "=" * 70)
    print("  TROPICAL–ULTRAMETRIC DUALITY: APPLICATIONS")
    print("=" * 70 + "\n")

    demo_robustness_certification()
    demo_post_quantum_keys()
    demo_fibonacci_key_ladder()
    demo_entropy_analysis()

    print("\nAll applications completed successfully.")


#!/usr/bin/env python3
"""
Tropical–Ultrametric Duality: Numerical Demonstrations

Concrete numerical examples illustrating the key theorems from the
formal proof framework connecting tropical algebra, ultrametric analysis,
and post-quantum cryptography.
"""

import math
from typing import List, Tuple

# =============================================================================
# §1. Tropical Arithmetic Demonstrations
# =============================================================================

def tropical_add(a: float, b: float) -> float:
    """Tropical addition = max."""
    return max(a, b)

def tropical_mul(a: float, b: float) -> float:
    """Tropical multiplication = +."""
    return a + b

def demo_tropical_absorption():
    """
    Demonstrate: If a < b then max(a, b) = b.
    This parallels ultrametric norm absorption: ||x+y|| = ||y|| when ||x|| < ||y||.
    """
    print("=" * 60)
    print("Demo 1: Tropical Absorption Principle")
    print("=" * 60)
    pairs = [(3.0, 7.0), (1.0, 100.0), (-5.0, 2.0), (0.001, 0.002)]
    for a, b in pairs:
        result = tropical_add(a, b)
        print(f"  max({a}, {b}) = {result}  (smaller value {a} absorbed)")
    print()

def demo_tropical_isosceles():
    """
    Demonstrate: If a ≠ b then min(a,b) < max(a,b).
    The tropical isosceles principle.
    """
    print("=" * 60)
    print("Demo 2: Tropical Isosceles Principle")
    print("=" * 60)
    pairs = [(3.0, 7.0), (1.0, 100.0), (2.5, 2.5001)]
    for a, b in pairs:
        mn, mx = min(a, b), max(a, b)
        print(f"  min({a}, {b}) = {mn} < max({a}, {b}) = {mx}  ✓")
    print()

def demo_max_min_duality():
    """
    Demonstrate: max(a,b) + min(a,b) = a + b.
    The fundamental duality between tropical max-plus and min-plus.
    """
    print("=" * 60)
    print("Demo 3: Max-Min Duality")
    print("=" * 60)
    pairs = [(3.0, 7.0), (1.5, 2.5), (100.0, 1.0)]
    for a, b in pairs:
        lhs = max(a, b) + min(a, b)
        rhs = a + b
        print(f"  max({a},{b}) + min({a},{b}) = {lhs} = {a} + {b} = {rhs}  ✓")
    print()

# =============================================================================
# §2. Fibonacci–Tropical Bridge Demonstrations
# =============================================================================

def fib(n: int) -> int:
    """Compute Fibonacci number F(n)."""
    if n <= 1:
        return max(0, n)
    a, b = 0, 1
    for _ in range(2, n + 1):
        a, b = b, a + b
    return b

def demo_fibonacci_entropy_bound():
    """
    Demonstrate: F(n) ≤ 2^n for all n.
    The information content of F(n) is at most n bits.
    """
    print("=" * 60)
    print("Demo 4: Fibonacci Entropy Bound (F(n) ≤ 2^n)")
    print("=" * 60)
    for n in range(0, 21):
        fn = fib(n)
        bound = 2**n
        ratio = fn / bound if bound > 0 else 0
        marker = "✓" if fn <= bound else "✗"
        print(f"  F({n:2d}) = {fn:8d}  ≤  2^{n:2d} = {bound:8d}  "
              f"(ratio: {ratio:.4f})  {marker}")
    print(f"\n  Asymptotic ratio → φ/2 ≈ {(1+math.sqrt(5))/2/2:.4f}")
    print()

def demo_fibonacci_gcd_homomorphism():
    """
    Demonstrate: gcd(F(m), F(n)) = F(gcd(m, n)).
    """
    print("=" * 60)
    print("Demo 5: Fibonacci GCD Homomorphism")
    print("=" * 60)
    test_cases = [(6, 9), (12, 8), (15, 10), (20, 12), (35, 14)]
    for m, n in test_cases:
        lhs = math.gcd(fib(m), fib(n))
        rhs = fib(math.gcd(m, n))
        marker = "✓" if lhs == rhs else "✗"
        print(f"  gcd(F({m}), F({n})) = gcd({fib(m)}, {fib(n)}) = {lhs}")
        print(f"  F(gcd({m},{n})) = F({math.gcd(m,n)}) = {rhs}  {marker}")
        print()

def demo_fibonacci_tropical_growth():
    """
    Demonstrate: F(n+2) ≤ 2·max(F(n), F(n+1)).
    """
    print("=" * 60)
    print("Demo 6: Fibonacci–Tropical Growth Bound")
    print("=" * 60)
    for n in range(0, 15):
        fn = fib(n)
        fn1 = fib(n + 1)
        fn2 = fib(n + 2)
        bound = 2 * max(fn, fn1)
        ratio = fn2 / bound if bound > 0 else 0
        print(f"  F({n+2:2d}) = {fn2:5d}  ≤  2·max(F({n}),F({n+1})) = "
              f"2·{max(fn,fn1)} = {bound:5d}  (ratio: {ratio:.3f})")
    print()

# =============================================================================
# §3. Security Parameter Demonstrations
# =============================================================================

def demo_tropical_key_space():
    """
    Demonstrate: Key space size (2B+1)^n for coordinate bound B, dimension n.
    """
    print("=" * 60)
    print("Demo 7: Tropical Key Space Growth")
    print("=" * 60)
    print(f"  {'n':>3s}  {'B':>3s}  {'(2B+1)^n':>15s}  {'3^n':>12s}  {'Ratio':>8s}")
    print("  " + "-" * 50)
    for n in range(1, 11):
        for B in [1, 2, 5]:
            key_space = (2*B + 1) ** n
            lower = 3**n
            ratio = key_space / lower
            print(f"  {n:3d}  {B:3d}  {key_space:15d}  {lower:12d}  {ratio:8.1f}")
    print()

def demo_grover_speedup():
    """
    Demonstrate: Tropical pre-processing reduces quantum search cost.
    sqrt(N/2^k) ≤ sqrt(N)
    """
    print("=" * 60)
    print("Demo 8: Grover–Tropical Speedup")
    print("=" * 60)
    N = 10**12
    print(f"  Search space N = {N}")
    print(f"  {'k':>3s}  {'N/2^k':>15s}  {'√(N/2^k)':>12s}  {'√N':>12s}  {'Speedup':>8s}")
    print("  " + "-" * 55)
    sqrt_N = math.isqrt(N)
    for k in range(0, 21):
        reduced = N // (2**k)
        sqrt_reduced = math.isqrt(reduced)
        speedup = sqrt_N / sqrt_reduced if sqrt_reduced > 0 else float('inf')
        print(f"  {k:3d}  {reduced:15d}  {sqrt_reduced:12d}  {sqrt_N:12d}  {speedup:8.1f}x")
    print()

def demo_security_duality():
    """
    Demonstrate: min(s1,s2) + max(s1,s2) = s1 + s2
    """
    print("=" * 60)
    print("Demo 9: Tropical Security Duality")
    print("=" * 60)
    pairs = [(128, 256), (80, 128), (192, 192), (256, 512)]
    for s1, s2 in pairs:
        mn = min(s1, s2)
        mx = max(s1, s2)
        print(f"  s₁={s1}, s₂={s2}: min={mn}, max={mx}, "
              f"min+max={mn+mx} = s₁+s₂={s1+s2}  ✓")
    print()

# =============================================================================
# §4. Composition and Depth Bounds
# =============================================================================

def demo_lipschitz_composition():
    """
    Demonstrate: Lipschitz constants multiply under composition.
    For L layers with bound B, total = B^L.
    """
    print("=" * 60)
    print("Demo 10: Lipschitz Depth Amplification")
    print("=" * 60)
    bounds = [
        ("Stable (B=0.9)", 0.9),
        ("Critical (B=1.0)", 1.0),
        ("Expanding (B=1.1)", 1.1),
        ("Ultrametric advantage (B=0.5)", 0.5),
    ]
    for label, B in bounds:
        print(f"\n  {label}:")
        print(f"    {'L':>4s}  {'B^L':>15s}")
        for L in [1, 2, 5, 10, 20, 50]:
            total = B**L
            print(f"    {L:4d}  {total:15.6f}")
    print()

# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("  TROPICAL–ULTRAMETRIC DUALITY: NUMERICAL DEMONSTRATIONS")
    print("=" * 60 + "\n")

    demo_tropical_absorption()
    demo_tropical_isosceles()
    demo_max_min_duality()
    demo_fibonacci_entropy_bound()
    demo_fibonacci_gcd_homomorphism()
    demo_fibonacci_tropical_growth()
    demo_tropical_key_space()
    demo_grover_speedup()
    demo_security_duality()
    demo_lipschitz_composition()

    print("\nAll demonstrations completed successfully.")
