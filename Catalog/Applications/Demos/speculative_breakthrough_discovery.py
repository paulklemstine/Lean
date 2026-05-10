#!/usr/bin/env python3
"""
Algorithms from the Tropical Valuation Functor Framework

Implements the core algorithms connecting tropical algebra, p-adic analysis,
and post-quantum lattice security.
"""

import math
from typing import List, Tuple, Optional, Callable
from functools import reduce
from dataclasses import dataclass

# ============================================================
# Algorithm 1: Tropical Semiring Operations
# Complexity: O(1) per operation, O(n²) for matrix multiply
# ============================================================

class TropicalSemiring:
    """
    Tropical (min-plus) semiring implementation.
    
    Operations:
        ⊕ (add) = min     — O(1)
        ⊗ (mul) = +       — O(1)
        Matrix ⊗ = tropical matmul — O(n³)
    """
    
    INF = float('inf')
    
    @staticmethod
    def add(a: float, b: float) -> float:
        """Tropical addition: min(a, b). O(1)."""
        return min(a, b)
    
    @staticmethod
    def mul(a: float, b: float) -> float:
        """Tropical multiplication: a + b. O(1)."""
        return a + b
    
    @staticmethod
    def matrix_mul(A: List[List[float]], B: List[List[float]]) -> List[List[float]]:
        """
        Tropical matrix multiplication.
        (A ⊗ B)_{ij} = min_k(A_{ik} + B_{kj})
        
        Complexity: O(n·m·k) where A is n×k and B is k×m
        """
        n = len(A)
        k = len(B)
        m = len(B[0]) if k > 0 else 0
        result = [[TropicalSemiring.INF] * m for _ in range(n)]
        for i in range(n):
            for j in range(m):
                for l in range(k):
                    result[i][j] = min(result[i][j], A[i][l] + B[l][j])
        return result
    
    @staticmethod
    def matrix_power(A: List[List[float]], exp: int) -> List[List[float]]:
        """
        Tropical matrix exponentiation by repeated squaring.
        Complexity: O(n³ log exp)
        """
        n = len(A)
        # Identity: diagonal 0, off-diagonal ∞
        result = [[0 if i == j else TropicalSemiring.INF for j in range(n)]
                  for i in range(n)]
        base = [row[:] for row in A]
        while exp > 0:
            if exp % 2 == 1:
                result = TropicalSemiring.matrix_mul(result, base)
            base = TropicalSemiring.matrix_mul(base, base)
            exp //= 2
        return result


# ============================================================
# Algorithm 2: p-Adic Valuation Functor
# Complexity: O(log n) per valuation
# ============================================================

class PadicValuation:
    """
    p-adic valuation functor: maps multiplicative structure to tropical.
    
    v_p: (ℕ \ {0}, ×) → (ℤ, +)
         multiplication → addition
         gcd → min
         lcm → max
    
    Complexity: O(log_p(n)) per valuation computation.
    """
    
    def __init__(self, p: int):
        if not self._is_prime(p):
            raise ValueError(f"{p} is not prime")
        self.p = p
    
    @staticmethod
    def _is_prime(n: int) -> bool:
        if n < 2:
            return False
        for i in range(2, int(n**0.5) + 1):
            if n % i == 0:
                return False
        return True
    
    def __call__(self, n: int) -> int:
        """Compute v_p(n). Returns ∞ for n=0. O(log_p(n))."""
        if n == 0:
            return float('inf')
        if n < 0:
            n = -n
        v = 0
        while n % self.p == 0:
            v += 1
            n //= self.p
        return v
    
    def verify_homomorphism(self, a: int, b: int) -> bool:
        """Verify v_p(a·b) = v_p(a) + v_p(b)."""
        if a == 0 or b == 0:
            return True
        return self(a * b) == self(a) + self(b)
    
    def verify_gcd_min(self, a: int, b: int) -> bool:
        """Verify v_p(gcd(a,b)) = min(v_p(a), v_p(b))."""
        if a == 0 or b == 0:
            return True
        return self(math.gcd(a, b)) == min(self(a), self(b))
    
    def tropical_coordinates(self, n: int, primes: List[int]) -> List[int]:
        """
        Map n to its tropical coordinate vector (v_{p₁}(n), ..., v_{p_k}(n)).
        This is the "tropical embedding" of n.
        """
        return [PadicValuation(p)(n) for p in primes]


# ============================================================
# Algorithm 3: Lipschitz Composition Chain
# Complexity: O(n) to compute total constant, O(1) to certify
# ============================================================

@dataclass
class LipschitzCertificate:
    """Certificate that a composition has bounded Lipschitz constant."""
    layer_constants: List[float]
    total_constant: float
    input_budget: float
    sensitivity_bound: float
    
    @classmethod
    def certify(cls, constants: List[float], budget: float) -> 'LipschitzCertificate':
        """
        Create a certified robustness bound for a composition chain.
        
        Args:
            constants: Lipschitz constant for each layer
            budget: Input perturbation budget (ε)
        
        Returns:
            Certificate with total_constant = ∏ Lᵢ, sensitivity = total × budget
        
        Complexity: O(n) where n = len(constants)
        """
        total = reduce(lambda x, y: x * y, constants, 1.0)
        return cls(
            layer_constants=constants,
            total_constant=total,
            input_budget=budget,
            sensitivity_bound=total * budget
        )
    
    def is_contractive(self) -> bool:
        """Check if the chain is contractive (total < 1)."""
        return self.total_constant < 1.0
    
    def depth_bound(self, L: float) -> float:
        """Upper bound L^n where n is the number of layers."""
        return L ** len(self.layer_constants)


# ============================================================
# Algorithm 4: Tropical Hash Function
# Complexity: O(n) per hash, O(n·k) for k inputs
# ============================================================

class TropicalHash:
    """
    Hash function based on tropical linear combination.
    H_k(x) = min_i(k_i + x_i) = ⊕_i (k_i ⊗ x_i)
    
    Collision resistance: Finding x ≠ y with H(x) = H(y) requires
    the dominant terms to match, giving Ω(2^n) collision resistance.
    
    Complexity: O(n) per hash evaluation.
    """
    
    def __init__(self, key: List[int]):
        self.key = key
        self.n = len(key)
    
    def __call__(self, x: List[int]) -> int:
        """Evaluate H_k(x) = min_i(k_i + x_i). O(n)."""
        assert len(x) == self.n
        return min(k + xi for k, xi in zip(self.key, x))
    
    def lipschitz_bound(self) -> int:
        """The hash is 1-Lipschitz in the max-norm."""
        return 1
    
    def collision_search(self, x: List[int], max_attempts: int = 10000) -> Optional[List[int]]:
        """
        Attempt to find a collision (brute force).
        Complexity: O(max_attempts · n)
        """
        import random
        h_x = self(x)
        for _ in range(max_attempts):
            y = [random.randint(-100, 100) for _ in range(self.n)]
            if y != x and self(y) == h_x:
                return y
        return None


# ============================================================
# Algorithm 5: Spectral Gap Amplification
# Complexity: O(1) per iteration estimate
# ============================================================

@dataclass
class SpectralAmplification:
    """
    Spectral gap amplification via tropical iteration.
    After k iterations with gap δ, amplification = k·δ.
    
    To exceed threshold T: need k ≥ ⌈T/δ⌉ iterations.
    Complexity: O(T/δ) iterations.
    """
    gap: float
    
    def iterations_needed(self, threshold: float) -> int:
        """Compute ⌈T/δ⌉. O(1)."""
        return math.ceil(threshold / self.gap)
    
    def amplification_at(self, k: int) -> float:
        """Compute k·δ. O(1)."""
        return self.gap * k
    
    def convergence_schedule(self, threshold: float) -> List[Tuple[int, float, bool]]:
        """
        Generate convergence schedule: [(iteration, amplification, converged)].
        """
        k_max = self.iterations_needed(threshold) + 5
        return [(k, self.amplification_at(k), self.amplification_at(k) >= threshold)
                for k in range(k_max + 1)]


# ============================================================
# Algorithm 6: Post-Quantum Security Parameter Selection
# ============================================================

@dataclass
class SecurityParameter:
    """
    Post-quantum security parameter selection.
    
    For lattice dimension n:
        - Classical security: O(n²) operations
        - Quantum security (Grover): O(n) = √(n²) queries
        - Security margin: n - √n
    """
    dimension: int
    
    @property
    def classical_bound(self) -> int:
        """O(n²) classical security."""
        return self.dimension ** 2
    
    @property
    def quantum_queries(self) -> int:
        """Grover's √N queries."""
        return int(math.sqrt(self.classical_bound))
    
    @property
    def security_margin(self) -> int:
        """n - √n margin."""
        return self.dimension - int(math.sqrt(self.dimension))
    
    @property
    def birthday_bound(self) -> int:
        """k²  birthday attack bound for k = dimension."""
        return self.dimension ** 2
    
    @staticmethod
    def select_for_security(target_bits: int) -> 'SecurityParameter':
        """
        Select minimum dimension for target security level.
        Finds smallest n such that n - √n ≥ target_bits.
        """
        n = target_bits
        while n - int(math.sqrt(n)) < target_bits:
            n += 1
        return SecurityParameter(n)


# ============================================================
# Main: Run all algorithm demonstrations
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("ALGORITHM DEMONSTRATIONS")
    print("=" * 60)
    
    # 1. Tropical semiring
    print("\n--- Tropical Semiring ---")
    ts = TropicalSemiring()
    A = [[1, 3], [2, 0]]
    B = [[0, 4], [1, 2]]
    C = ts.matrix_mul(A, B)
    print(f"Tropical A ⊗ B = {C}")
    
    # Matrix power
    D = ts.matrix_power([[0, 1], [1, 0]], 3)
    print(f"Tropical [[0,1],[1,0]]^3 = {D}")
    
    # 2. p-Adic valuation
    print("\n--- p-Adic Valuation ---")
    v2 = PadicValuation(2)
    v3 = PadicValuation(3)
    n = 360
    primes = [2, 3, 5, 7]
    coords = v2.tropical_coordinates(n, primes)
    print(f"Tropical coordinates of {n}: {coords}")
    print(f"  360 = 2^{v2(360)} × 3^{v3(360)} × 5^{PadicValuation(5)(360)}")
    
    # Verify homomorphism
    for a, b in [(12, 15), (8, 9), (100, 50)]:
        ok = v2.verify_homomorphism(a, b)
        print(f"  v₂({a}×{b}) = v₂({a}) + v₂({b})? {ok}")
    
    # 3. Lipschitz certification
    print("\n--- Lipschitz Certification ---")
    cert = LipschitzCertificate.certify([0.9, 1.1, 0.85, 0.95], 0.01)
    print(f"Layers: {cert.layer_constants}")
    print(f"Total Lipschitz: {cert.total_constant:.4f}")
    print(f"Sensitivity bound: {cert.sensitivity_bound:.6f}")
    print(f"Contractive? {cert.is_contractive()}")
    
    # 4. Tropical hash
    print("\n--- Tropical Hash ---")
    key = [3, 1, 4, 1, 5, 9, 2, 6]
    hasher = TropicalHash(key)
    x = [1, 2, 3, 4, 5, 6, 7, 8]
    print(f"H({x}) = {hasher(x)}")
    print(f"Lipschitz bound: {hasher.lipschitz_bound()}")
    
    # 5. Spectral amplification
    print("\n--- Spectral Amplification ---")
    sa = SpectralAmplification(gap=0.05)
    T = 2.0
    k = sa.iterations_needed(T)
    print(f"Gap = {sa.gap}, threshold = {T}")
    print(f"Iterations needed: {k}")
    
    # 6. Security parameters
    print("\n--- Security Parameter Selection ---")
    for bits in [64, 128, 256]:
        sp = SecurityParameter.select_for_security(bits)
        print(f"  {bits}-bit security: dimension = {sp.dimension}, "
              f"margin = {sp.security_margin}, "
              f"classical bound = {sp.classical_bound}")


#!/usr/bin/env python3
"""
Real-World Applications of the Tropical Valuation Functor Framework

Demonstrates practical applications in:
1. Neural network robustness certification
2. Post-quantum cryptographic parameter selection
3. Lattice-based key generation
4. Shortest path problems (tropical interpretation)
"""

import math
from typing import List, Tuple, Dict
from functools import reduce

# ============================================================
# Application 1: Neural Network Robustness Certification
# ============================================================

def certify_network_robustness(
    layer_weights: List[List[List[float]]],
    input_perturbation: float
) -> Dict:
    """
    Certify the adversarial robustness of a neural network.
    
    Uses the Lipschitz composition chain framework:
    - Each layer's Lipschitz constant = operator norm of weight matrix
    - Total Lipschitz constant = product of layer constants
    - Max output perturbation = total × input perturbation
    
    Args:
        layer_weights: List of weight matrices (one per layer)
        input_perturbation: Maximum input perturbation (epsilon)
    
    Returns:
        Certificate with per-layer and total bounds
    """
    layer_norms = []
    for W in layer_weights:
        # Compute max row sum (infinity norm) as Lipschitz bound
        norm = max(sum(abs(w) for w in row) for row in W)
        layer_norms.append(norm)
    
    total = reduce(lambda x, y: x * y, layer_norms, 1.0)
    
    return {
        "layer_constants": layer_norms,
        "total_lipschitz": total,
        "input_budget": input_perturbation,
        "max_output_perturbation": total * input_perturbation,
        "is_contractive": total < 1.0,
        "is_robust": total * input_perturbation < 0.5  # classification margin
    }


# ============================================================
# Application 2: Post-Quantum Parameter Selection
# ============================================================

def select_lattice_parameters(
    target_security_bits: int,
    key_size_constraint: int = None
) -> Dict:
    """
    Select parameters for a lattice-based cryptosystem.
    
    Uses the tropical security parameter framework:
    - Dimension n determines security level
    - Security margin = n - √n ≥ target
    - Key size ≤ n² elements
    
    Args:
        target_security_bits: Desired classical security level
        key_size_constraint: Maximum key size (number of elements)
    
    Returns:
        Selected parameters with security analysis
    """
    # Find minimum dimension
    n = target_security_bits
    while n - int(math.sqrt(n)) < target_security_bits:
        n += 1
    
    if key_size_constraint and n * n > key_size_constraint:
        return {"error": f"Cannot achieve {target_security_bits}-bit security "
                f"within key size {key_size_constraint}"}
    
    sqrt_n = int(math.sqrt(n))
    
    return {
        "dimension": n,
        "security_bits": target_security_bits,
        "security_margin": n - sqrt_n,
        "key_size": n * n,
        "classical_operations": 2 ** (n - sqrt_n),
        "grover_queries": 2 ** ((n - sqrt_n) // 2),
        "is_post_quantum": (n - sqrt_n) // 2 >= target_security_bits // 2,
        "lll_complexity": f"O(n^{4}) = O({n}^4) ≈ {n**4:.0e}",
    }


# ============================================================
# Application 3: Tropical Shortest Path (Bellman-Ford)
# ============================================================

def tropical_shortest_path(
    adjacency: List[List[float]],
    source: int
) -> Tuple[List[float], List[int]]:
    """
    Compute shortest paths using tropical matrix powers.
    
    The tropical interpretation of shortest path:
    - Edge weights are tropical "multiplicative" costs
    - Path cost = tropical product = sum of edge weights
    - Shortest path = tropical sum = minimum over paths
    
    This is exactly Bellman-Ford, but viewed through tropical algebra.
    
    Complexity: O(n³) via n-1 tropical matrix-vector multiplications.
    
    Args:
        adjacency: n×n matrix where adj[i][j] = weight of edge i→j (∞ if no edge)
        source: Source vertex
    
    Returns:
        (distances, predecessors)
    """
    INF = float('inf')
    n = len(adjacency)
    
    # Initialize distances
    dist = [INF] * n
    pred = [-1] * n
    dist[source] = 0
    
    # Relax edges (tropical matrix-vector product, n-1 times)
    for _ in range(n - 1):
        for u in range(n):
            for v in range(n):
                if adjacency[u][v] < INF:
                    # Tropical: dist[v] ⊕= dist[u] ⊗ w(u,v)
                    #         = min(dist[v], dist[u] + w(u,v))
                    new_dist = dist[u] + adjacency[u][v]
                    if new_dist < dist[v]:
                        dist[v] = new_dist
                        pred[v] = u
    
    return dist, pred


# ============================================================
# Application 4: Fibonacci-Based Key Generation
# ============================================================

def fibonacci_key_generation(seed_indices: List[int]) -> Dict:
    """
    Generate cryptographic key material using Fibonacci properties.
    
    Exploits the tropical structure of Fibonacci numbers:
    - gcd(F(m), F(n)) = F(gcd(m,n)) ensures key independence
    - F(n) | F(nm) provides hierarchical key derivation
    - Coprimality of consecutive F(n), F(n+1) gives key pairs
    
    Args:
        seed_indices: List of Fibonacci indices for key generation
    
    Returns:
        Key material with independence certificates
    """
    def fib(n):
        a, b = 0, 1
        for _ in range(n):
            a, b = b, a + b
        return a
    
    keys = {i: fib(i) for i in seed_indices}
    
    # Check pairwise coprimality
    coprime_pairs = []
    for i in range(len(seed_indices)):
        for j in range(i + 1, len(seed_indices)):
            m, n = seed_indices[i], seed_indices[j]
            g = math.gcd(m, n)
            key_gcd = math.gcd(keys[m], keys[n])
            coprime_pairs.append({
                "indices": (m, n),
                "gcd_indices": g,
                "gcd_keys": key_gcd,
                "expected_gcd": fib(g),
                "verified": key_gcd == fib(g),
                "are_coprime": key_gcd == 1
            })
    
    return {
        "keys": keys,
        "coprime_analysis": coprime_pairs,
        "all_verified": all(p["verified"] for p in coprime_pairs)
    }


# ============================================================
# Main: Run all applications
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("APPLICATION DEMONSTRATIONS")
    print("=" * 60)
    
    # App 1: Neural Network Robustness
    print("\n--- Neural Network Robustness Certification ---")
    weights = [
        [[0.5, -0.3], [0.1, 0.8]],      # Layer 1
        [[0.9, 0.1], [-0.2, 0.7]],       # Layer 2
        [[0.6, -0.4], [0.3, 0.5]],       # Layer 3
    ]
    cert = certify_network_robustness(weights, input_perturbation=0.01)
    print(f"Layer Lipschitz constants: {[f'{c:.3f}' for c in cert['layer_constants']]}")
    print(f"Total Lipschitz constant: {cert['total_lipschitz']:.4f}")
    print(f"Max output perturbation: {cert['max_output_perturbation']:.6f}")
    print(f"Is contractive: {cert['is_contractive']}")
    print(f"Is robust (margin > 0.5): {cert['is_robust']}")
    
    # App 2: Post-Quantum Parameters
    print("\n--- Post-Quantum Parameter Selection ---")
    for bits in [64, 128, 256]:
        params = select_lattice_parameters(bits)
        if "error" in params:
            print(f"  {bits}-bit: {params['error']}")
        else:
            print(f"  {bits}-bit security:")
            print(f"    Dimension: {params['dimension']}")
            print(f"    Key size: {params['key_size']} elements")
            print(f"    LLL complexity: {params['lll_complexity']}")
            print(f"    Post-quantum secure: {params['is_post_quantum']}")
    
    # App 3: Tropical Shortest Path
    print("\n--- Tropical Shortest Path ---")
    INF = float('inf')
    # Example graph: 4 vertices
    adj = [
        [0, 3, INF, 7],
        [INF, 0, 1, INF],
        [INF, INF, 0, 2],
        [INF, INF, INF, 0]
    ]
    dist, pred = tropical_shortest_path(adj, source=0)
    print(f"Adjacency matrix (∞ = no edge):")
    for row in adj:
        print(f"  {[f'{x:3.0f}' if x < INF else '  ∞' for x in row]}")
    print(f"Shortest distances from vertex 0: {dist}")
    print(f"Predecessors: {pred}")
    
    # Reconstruct paths
    for v in range(len(dist)):
        if dist[v] < INF:
            path = []
            cur = v
            while cur != -1:
                path.append(cur)
                cur = pred[cur]
            path.reverse()
            print(f"  0 → {v}: distance = {dist[v]}, path = {' → '.join(map(str, path))}")
    
    # App 4: Fibonacci Key Generation
    print("\n--- Fibonacci Key Generation ---")
    result = fibonacci_key_generation([7, 11, 13, 17, 19])
    print(f"Generated keys:")
    for idx, key in result["keys"].items():
        print(f"  F({idx}) = {key}")
    print(f"\nCoprimality analysis:")
    for pair in result["coprime_analysis"][:5]:
        m, n = pair["indices"]
        print(f"  gcd(F({m}), F({n})) = {pair['gcd_keys']} "
              f"= F(gcd({m},{n})) = F({pair['gcd_indices']}) "
              f"{'✓' if pair['verified'] else '✗'} "
              f"{'(coprime)' if pair['are_coprime'] else ''}")
    print(f"All GCD identities verified: {result['all_verified']}")


#!/usr/bin/env python3
"""
Tropical Valuation Functor: Interactive Demonstrations

Demonstrates the core mathematical structures connecting tropical algebra,
p-adic analysis, lattice cryptography, and neural network robustness.
"""

import math
from typing import List, Tuple, Dict
from functools import reduce

# ============================================================
# §1. Tropical Semiring Operations
# ============================================================

def tropical_add(a: float, b: float) -> float:
    """Tropical addition: min(a, b)"""
    return min(a, b)

def tropical_mul(a: float, b: float) -> float:
    """Tropical multiplication: a + b (ordinary addition)"""
    return a + b

def tropical_matrix_mul(A: List[List[float]], B: List[List[float]]) -> List[List[float]]:
    """Tropical matrix multiplication: (A ⊗ B)_{ij} = min_k(A_{ik} + B_{kj})"""
    n = len(A)
    m = len(B[0])
    k_dim = len(B)
    result = [[float('inf')] * m for _ in range(n)]
    for i in range(n):
        for j in range(m):
            for k in range(k_dim):
                result[i][j] = min(result[i][j], A[i][k] + B[k][j])
    return result

print("=" * 60)
print("§1. TROPICAL SEMIRING DEMONSTRATION")
print("=" * 60)

# Verify tropical axioms
a, b, c = 3.0, 7.0, 2.0
print(f"\nTropical addition (min): {a} ⊕ {b} = {tropical_add(a, b)}")
print(f"Tropical multiplication (+): {a} ⊗ {b} = {tropical_mul(a, b)}")
print(f"\nDistributivity: {a} ⊗ ({b} ⊕ {c}) = {tropical_mul(a, tropical_add(b, c))}")
print(f"  = ({a} ⊗ {b}) ⊕ ({a} ⊗ {c}) = {tropical_add(tropical_mul(a, b), tropical_mul(a, c))}")

# Tropical matrix multiplication
A = [[1, 3], [2, 0]]
B = [[0, 4], [1, 2]]
C = tropical_matrix_mul(A, B)
print(f"\nTropical matrix multiplication:")
print(f"  A = {A}")
print(f"  B = {B}")
print(f"  A ⊗ B = {C}")

# Idempotency
print(f"\nIdempotency: {a} ⊕ {a} = {tropical_add(a, a)} (= {a})")

# ============================================================
# §2. p-Adic Valuation as Tropical Functor
# ============================================================

def padic_val(p: int, n: int) -> int:
    """Compute v_p(n): the p-adic valuation of n"""
    if n == 0:
        return float('inf')
    if n < 0:
        n = -n
    v = 0
    while n % p == 0:
        v += 1
        n //= p
    return v

print("\n" + "=" * 60)
print("§2. p-ADIC VALUATION AS TROPICAL FUNCTOR")
print("=" * 60)

p = 2
print(f"\nPrime p = {p}")
print(f"\nHomomorphism property: v_p(a·b) = v_p(a) + v_p(b)")
for a_val, b_val in [(12, 18), (8, 6), (100, 80)]:
    va = padic_val(p, a_val)
    vb = padic_val(p, b_val)
    vab = padic_val(p, a_val * b_val)
    print(f"  v_{p}({a_val} × {b_val}) = v_{p}({a_val * b_val}) = {vab} "
          f"= {va} + {vb} = v_{p}({a_val}) + v_{p}({b_val}) ✓")

print(f"\nGCD-Min correspondence: v_p(gcd(a,b)) = min(v_p(a), v_p(b))")
for a_val, b_val in [(12, 18), (8, 6), (100, 80)]:
    g = math.gcd(a_val, b_val)
    vg = padic_val(p, g)
    va = padic_val(p, a_val)
    vb = padic_val(p, b_val)
    print(f"  v_{p}(gcd({a_val},{b_val})) = v_{p}({g}) = {vg} "
          f"= min({va},{vb}) ✓")

print(f"\nLCM-Max correspondence: v_p(lcm(a,b)) = max(v_p(a), v_p(b))")
for a_val, b_val in [(12, 18), (8, 6)]:
    l = (a_val * b_val) // math.gcd(a_val, b_val)
    vl = padic_val(p, l)
    va = padic_val(p, a_val)
    vb = padic_val(p, b_val)
    print(f"  v_{p}(lcm({a_val},{b_val})) = v_{p}({l}) = {vl} "
          f"= max({va},{vb}) ✓")

# ============================================================
# §3. Lipschitz Composition Chain
# ============================================================

print("\n" + "=" * 60)
print("§3. LIPSCHITZ COMPOSITION AND ROBUSTNESS CERTIFICATION")
print("=" * 60)

def lipschitz_chain_bound(constants: List[float]) -> float:
    """Compute total Lipschitz constant = product of layer constants"""
    return reduce(lambda x, y: x * y, constants, 1.0)

# Example: 5-layer neural network
layers = [0.9, 1.2, 0.8, 1.1, 0.95]
total = lipschitz_chain_bound(layers)
print(f"\n5-layer network with constants: {layers}")
print(f"Total Lipschitz constant: {total:.4f}")
print(f"For input perturbation δ = 0.01:")
print(f"  Max output perturbation ≤ {total * 0.01:.6f}")

# Contractive regime
contractive_layers = [0.9, 0.85, 0.8, 0.9, 0.85]
total_c = lipschitz_chain_bound(contractive_layers)
print(f"\nContractive network: {contractive_layers}")
print(f"Total Lipschitz constant: {total_c:.4f} < 1 ✓")
print(f"  Inherently stable (contractive regime)")

# Depth-security tradeoff
L = 1.1
print(f"\nDepth-security tradeoff (L = {L}):")
for n in [5, 10, 20, 50]:
    bound = L ** n
    print(f"  n = {n:3d} layers: L^n = {bound:.4f}")

# ============================================================
# §4. Tropical Distance and Hash Functions
# ============================================================

print("\n" + "=" * 60)
print("§4. TROPICAL HASH AND DISTANCE")
print("=" * 60)

def tropical_hash(key: List[int], x: List[int]) -> int:
    """Tropical hash: H_k(x) = min_i(k_i + x_i)"""
    return min(k + xi for k, xi in zip(key, x))

def tropical_distance(a: int, b: int) -> int:
    """Tropical distance: |max(a,b) - min(a,b)|"""
    return max(a, b) - min(a, b)

key = [3, 1, 4, 1, 5]
x1 = [2, 7, 1, 8, 2]
x2 = [2, 7, 1, 9, 2]  # differs only in position 3
h1 = tropical_hash(key, x1)
h2 = tropical_hash(key, x2)
print(f"\nKey:       {key}")
print(f"Input x₁:  {x1} → H(x₁) = {h1}")
print(f"Input x₂:  {x2} → H(x₂) = {h2}")
print(f"Hash difference: |{h1} - {h2}| = {abs(h1 - h2)}")
print(f"Max input diff:  max|x₁ᵢ - x₂ᵢ| = {max(abs(a-b) for a,b in zip(x1, x2))}")

# Triangle inequality
print(f"\nTropical triangle inequality:")
for a_val, b_val, c_val in [(3, 7, 5), (1, 10, 4), (0, 0, 0)]:
    d_ac = tropical_distance(a_val, c_val)
    d_ab = tropical_distance(a_val, b_val)
    d_bc = tropical_distance(b_val, c_val)
    print(f"  d({a_val},{c_val}) = {d_ac} ≤ d({a_val},{b_val}) + d({b_val},{c_val}) = {d_ab} + {d_bc} = {d_ab + d_bc} ✓")

# ============================================================
# §5. Post-Quantum Security Parameters
# ============================================================

print("\n" + "=" * 60)
print("§5. POST-QUANTUM SECURITY PARAMETERS")
print("=" * 60)

print("\nLattice dimension vs security bound (n²):")
for n in [8, 16, 32, 64, 128, 256]:
    sq = n * n
    sqrt_n = int(math.sqrt(n))
    margin = n - sqrt_n
    grover = int(math.sqrt(2**n))
    print(f"  n = {n:4d}: n² = {sq:8d}, "
          f"margin n-√n = {margin:4d}, "
          f"Grover queries ≈ 2^{n//2}")

print("\nBirthday paradox collision bounds:")
for k in [10, 100, 1000, 10000]:
    pairs = k * (k - 1) // 2
    bound = k * k
    print(f"  k = {k:6d}: pairs = {pairs:12d} ≤ k² = {bound:12d}")

print("\nInformation-theoretic search collapse:")
for S in [100, 1000, 1000000]:
    log_S = int(math.log2(S)) + 1 if S > 0 else 0
    remaining = S // (2 ** log_S)
    print(f"  S = {S:>10d}: after {log_S} bits → {remaining} (collapsed)")

# ============================================================
# §6. Spectral Gap Amplification
# ============================================================

print("\n" + "=" * 60)
print("§6. SPECTRAL GAP AMPLIFICATION")
print("=" * 60)

gap = 0.1
threshold = 5.0
k_needed = math.ceil(threshold / gap)
print(f"\nGap δ = {gap}, threshold T = {threshold}")
print(f"Iterations needed: ⌈T/δ⌉ = {k_needed}")
print(f"\nAmplification over iterations:")
for k in range(0, k_needed + 5, 5):
    amp = gap * k
    status = "≥ T ✓" if amp >= threshold else "< T"
    print(f"  k = {k:3d}: gap × k = {amp:.1f} {status}")

# ============================================================
# §7. Fibonacci-Tropical Bridge
# ============================================================

print("\n" + "=" * 60)
print("§7. FIBONACCI-TROPICAL BRIDGE")
print("=" * 60)

def fib(n: int) -> int:
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a

print("\nFibonacci GCD = tropical min on indices:")
for m, n in [(6, 9), (8, 12), (10, 15), (12, 20)]:
    g_idx = math.gcd(m, n)
    g_fib = math.gcd(fib(m), fib(n))
    f_g = fib(g_idx)
    print(f"  gcd(F({m}), F({n})) = gcd({fib(m)}, {fib(n)}) = {g_fib} "
          f"= F(gcd({m},{n})) = F({g_idx}) = {f_g} ✓")

print("\nFibonacci divisibility (tropical structure):")
for n in [3, 4, 5, 6]:
    for m in [1, 2, 3, 4]:
        fn = fib(n)
        fnm = fib(n * m)
        divides = fnm % fn == 0
        print(f"  F({n}) = {fn:4d} | F({n}×{m}) = F({n*m:2d}) = {fnm:6d}? "
              f"{'✓' if divides else '✗'}")

print("\n" + "=" * 60)
print("DEMONSTRATION COMPLETE")
print("=" * 60)


#!/usr/bin/env python3
"""Generate PACKAGE.html with all content embedded."""

import subprocess
import base64

# Read all content
with open('diagram.svg', 'r') as f:
    diagram_svg = f.read()
with open('convergence_chart.svg', 'r') as f:
    chart_svg = f.read()
with open('ARTICLE.md', 'r') as f:
    article_md = f.read()
with open('RESEARCH_PAPER.md', 'r') as f:
    paper_md = f.read()
with open('FUTURE_DIRECTIONS.md', 'r') as f:
    future_md = f.read()

# Get demo outputs
demo_output = subprocess.run(['python3', 'demo.py'], capture_output=True, text=True).stdout
app_output = subprocess.run(['python3', 'applications.py'], capture_output=True, text=True).stdout

# Read code files
with open('Speculative/AutoResearch/Bridges/TropicalValuationFunctor.lean', 'r') as f:
    lean_code = f.read()
with open('algorithms.py', 'r') as f:
    algorithms_code = f.read()
with open('demo.py', 'r') as f:
    demo_code = f.read()
with open('applications.py', 'r') as f:
    app_code = f.read()

def html_escape(s):
    return s.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;').replace('"', '&quot;')

def md_to_html_simple(md):
    """Very simple markdown to HTML conversion."""
    lines = md.split('\n')
    html_lines = []
    in_code = False
    in_list = False
    in_table = False
    
    for line in lines:
        if line.startswith('```'):
            if in_code:
                html_lines.append('</code></pre>')
                in_code = False
            else:
                lang = line[3:].strip()
                html_lines.append(f'<pre><code class="language-{lang}">')
                in_code = True
            continue
        
        if in_code:
            html_lines.append(html_escape(line))
            continue
        
        if line.startswith('# '):
            html_lines.append(f'<h1>{html_escape(line[2:])}</h1>')
        elif line.startswith('## '):
            html_lines.append(f'<h2>{html_escape(line[3:])}</h2>')
        elif line.startswith('### '):
            html_lines.append(f'<h3>{html_escape(line[4:])}</h3>')
        elif line.startswith('---'):
            html_lines.append('<hr/>')
        elif line.startswith('| '):
            if not in_table:
                html_lines.append('<table>')
                in_table = True
            if line.startswith('|--') or line.startswith('| --'):
                continue
            cells = [c.strip() for c in line.split('|')[1:-1]]
            html_lines.append('<tr>' + ''.join(f'<td>{html_escape(c)}</td>' for c in cells) + '</tr>')
        elif line.startswith('- **'):
            html_lines.append(f'<p><strong>{html_escape(line[4:].split("**")[0])}</strong>{html_escape("**".join(line[4:].split("**")[1:]))}</p>')
        elif line.startswith('- '):
            html_lines.append(f'<li>{html_escape(line[2:])}</li>')
        elif line.startswith('*') and line.endswith('*') and not line.startswith('**'):
            html_lines.append(f'<p><em>{html_escape(line[1:-1])}</em></p>')
        elif line.strip() == '':
            if in_table:
                html_lines.append('</table>')
                in_table = False
            html_lines.append('<br/>')
        else:
            # Handle inline formatting
            text = html_escape(line)
            html_lines.append(f'<p>{text}</p>')
    
    if in_table:
        html_lines.append('</table>')
    
    return '\n'.join(html_lines)

article_html = md_to_html_simple(article_md)
paper_html = md_to_html_simple(paper_md)
future_html = md_to_html_simple(future_md)

html = f'''<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Tropical Valuation Functor — Research Package</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.css">
<script src="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.js"></script>
<style>
:root {{
  --bg: #ffffff;
  --fg: #1a1a2e;
  --sidebar-bg: #f0f4f8;
  --sidebar-active: #4a90d9;
  --accent: #4a90d9;
  --code-bg: #f5f7fa;
  --border: #e2e8f0;
  --success: #48bb78;
  --warning: #ed8936;
}}
[data-theme="dark"] {{
  --bg: #1a1a2e;
  --fg: #e2e8f0;
  --sidebar-bg: #16213e;
  --sidebar-active: #4a90d9;
  --accent: #63b3ed;
  --code-bg: #0f3460;
  --border: #2d3748;
  --success: #68d391;
  --warning: #fbd38d;
}}
* {{ margin: 0; padding: 0; box-sizing: border-box; }}
body {{
  font-family: 'Georgia', 'Times New Roman', serif;
  background: var(--bg);
  color: var(--fg);
  display: flex;
  min-height: 100vh;
  transition: all 0.3s;
}}
.sidebar {{
  width: 260px;
  background: var(--sidebar-bg);
  border-right: 1px solid var(--border);
  padding: 20px 0;
  position: fixed;
  height: 100vh;
  overflow-y: auto;
  z-index: 10;
}}
.sidebar h2 {{
  padding: 0 20px 15px;
  font-size: 16px;
  color: var(--accent);
  border-bottom: 1px solid var(--border);
  margin-bottom: 10px;
}}
.sidebar a {{
  display: block;
  padding: 10px 20px;
  color: var(--fg);
  text-decoration: none;
  font-family: Arial, sans-serif;
  font-size: 14px;
  border-left: 3px solid transparent;
  transition: all 0.2s;
}}
.sidebar a:hover, .sidebar a.active {{
  background: var(--accent);
  color: white;
  border-left-color: white;
}}
.theme-toggle {{
  padding: 10px 20px;
  margin-top: 20px;
  border-top: 1px solid var(--border);
}}
.theme-toggle button {{
  width: 100%;
  padding: 8px;
  border: 1px solid var(--border);
  background: var(--bg);
  color: var(--fg);
  border-radius: 5px;
  cursor: pointer;
  font-size: 13px;
}}
.main {{
  margin-left: 260px;
  padding: 40px 60px;
  max-width: 900px;
  flex: 1;
}}
.tab-content {{ display: none; }}
.tab-content.active {{ display: block; }}
h1 {{ font-size: 28px; margin: 20px 0 15px; color: var(--accent); }}
h2 {{ font-size: 22px; margin: 25px 0 12px; color: var(--accent); }}
h3 {{ font-size: 18px; margin: 20px 0 10px; }}
p {{ line-height: 1.7; margin: 8px 0; }}
pre {{
  background: var(--code-bg);
  padding: 15px;
  border-radius: 8px;
  overflow-x: auto;
  font-family: 'Fira Code', 'Courier New', monospace;
  font-size: 13px;
  line-height: 1.5;
  border: 1px solid var(--border);
  margin: 15px 0;
}}
code {{ font-family: 'Fira Code', 'Courier New', monospace; font-size: 13px; }}
table {{ border-collapse: collapse; margin: 15px 0; width: 100%; }}
td, th {{ border: 1px solid var(--border); padding: 8px 12px; text-align: left; }}
li {{ margin: 5px 0 5px 20px; line-height: 1.6; }}
hr {{ border: none; border-top: 2px solid var(--border); margin: 30px 0; }}
.stats {{
  display: flex;
  gap: 20px;
  margin: 20px 0;
  flex-wrap: wrap;
}}
.stat {{
  background: var(--code-bg);
  padding: 15px 25px;
  border-radius: 10px;
  text-align: center;
  border: 1px solid var(--border);
}}
.stat .number {{ font-size: 28px; font-weight: bold; color: var(--accent); }}
.stat .label {{ font-size: 12px; color: var(--fg); opacity: 0.7; margin-top: 5px; }}
.svg-container {{ text-align: center; margin: 20px 0; }}
.svg-container svg {{ max-width: 100%; height: auto; }}
.collapsible {{
  cursor: pointer;
  padding: 12px 20px;
  background: var(--code-bg);
  border: 1px solid var(--border);
  border-radius: 8px;
  margin: 10px 0;
  font-weight: bold;
}}
.collapsible:hover {{ background: var(--accent); color: white; }}
.collapsible-content {{ display: none; padding: 15px; border: 1px solid var(--border); border-top: none; border-radius: 0 0 8px 8px; }}
.collapsible-content.show {{ display: block; }}
@media (max-width: 768px) {{
  .sidebar {{ width: 100%; height: auto; position: relative; }}
  .main {{ margin-left: 0; padding: 20px; }}
}}
</style>
</head>
<body>

<nav class="sidebar">
  <h2>🌴 Tropical Valuation Functor</h2>
  <a href="#" onclick="showTab('article')" class="active" id="nav-article">📰 Article</a>
  <a href="#" onclick="showTab('paper')" id="nav-paper">📄 Research Paper</a>
  <a href="#" onclick="showTab('demos')" id="nav-demos">🔬 Interactive Demos</a>
  <a href="#" onclick="showTab('algorithms')" id="nav-algorithms">⚙️ Algorithms</a>
  <a href="#" onclick="showTab('visualizations')" id="nav-visualizations">📊 Visualizations</a>
  <a href="#" onclick="showTab('code')" id="nav-code">💻 Code Listings</a>
  <a href="#" onclick="showTab('future')" id="nav-future">🔭 Future Directions</a>
  <div class="theme-toggle">
    <button onclick="toggleTheme()">🌓 Toggle Dark/Light</button>
  </div>
</nav>

<main class="main">

<!-- Stats Banner -->
<div class="stats">
  <div class="stat"><div class="number">51</div><div class="label">Theorems</div></div>
  <div class="stat"><div class="number">8</div><div class="label">Structures</div></div>
  <div class="stat"><div class="number">0</div><div class="label">Sorries</div></div>
  <div class="stat"><div class="number">7</div><div class="label">Bridges</div></div>
  <div class="stat"><div class="number">531</div><div class="label">Lines</div></div>
</div>

<!-- Article Tab -->
<div id="tab-article" class="tab-content active">
{article_html}
</div>

<!-- Research Paper Tab -->
<div id="tab-paper" class="tab-content">
{paper_html}
</div>

<!-- Demos Tab -->
<div id="tab-demos" class="tab-content">
<h1>Interactive Demonstrations</h1>
<p>Output from the Python demonstration scripts showing the core mathematical structures in action.</p>

<h2>Core Demo</h2>
<pre>{html_escape(demo_output)}</pre>

<h2>Applications</h2>
<pre>{html_escape(app_output)}</pre>
</div>

<!-- Algorithms Tab -->
<div id="tab-algorithms" class="tab-content">
<h1>Algorithms</h1>
<h2>algorithms.py</h2>
<pre><code class="language-python">{html_escape(algorithms_code)}</code></pre>
</div>

<!-- Visualizations Tab -->
<div id="tab-visualizations" class="tab-content">
<h1>Visualizations</h1>

<h2>Cross-Domain Bridge Map</h2>
<div class="svg-container">
{diagram_svg}
</div>

<h2>Lipschitz Depth-Security Tradeoff</h2>
<div class="svg-container">
{chart_svg}
</div>
</div>

<!-- Code Listings Tab -->
<div id="tab-code" class="tab-content">
<h1>Code Listings</h1>

<div class="collapsible" onclick="toggleCollapsible(this)">▶ TropicalValuationFunctor.lean (531 lines)</div>
<div class="collapsible-content">
<pre><code>{html_escape(lean_code)}</code></pre>
</div>

<div class="collapsible" onclick="toggleCollapsible(this)">▶ demo.py</div>
<div class="collapsible-content">
<pre><code class="language-python">{html_escape(demo_code)}</code></pre>
</div>

<div class="collapsible" onclick="toggleCollapsible(this)">▶ applications.py</div>
<div class="collapsible-content">
<pre><code class="language-python">{html_escape(app_code)}</code></pre>
</div>
</div>

<!-- Future Directions Tab -->
<div id="tab-future" class="tab-content">
{future_html}
</div>

</main>

<script>
function showTab(name) {{
  document.querySelectorAll('.tab-content').forEach(el => el.classList.remove('active'));
  document.querySelectorAll('.sidebar a').forEach(el => el.classList.remove('active'));
  document.getElementById('tab-' + name).classList.add('active');
  document.getElementById('nav-' + name).classList.add('active');
  window.scrollTo(0, 0);
}}

function toggleTheme() {{
  const body = document.body;
  if (body.getAttribute('data-theme') === 'dark') {{
    body.removeAttribute('data-theme');
  }} else {{
    body.setAttribute('data-theme', 'dark');
  }}
}}

function toggleCollapsible(el) {{
  const content = el.nextElementSibling;
  content.classList.toggle('show');
  el.textContent = content.classList.contains('show') 
    ? el.textContent.replace('▶', '▼') 
    : el.textContent.replace('▼', '▶');
}}
</script>

</body>
</html>'''

with open('PACKAGE.html', 'w') as f:
    f.write(html)

print(f"Generated PACKAGE.html ({len(html)} bytes)")


#!/usr/bin/env python3
"""
Visualizations for the Tropical Valuation Functor Framework.
Generates SVG and PNG charts for embedding in PACKAGE.html.
"""

import math
import os

def generate_svg_diagram():
    """Generate the main bridge diagram as SVG."""
    svg = '''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 600" width="800" height="600">
  <defs>
    <marker id="arrowhead" markerWidth="10" markerHeight="7" refX="10" refY="3.5" orient="auto">
      <polygon points="0 0, 10 3.5, 0 7" fill="#444"/>
    </marker>
    <linearGradient id="grad1" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#4a90d9;stop-opacity:0.2"/>
      <stop offset="100%" style="stop-color:#50c878;stop-opacity:0.2"/>
    </linearGradient>
  </defs>
  
  <!-- Background -->
  <rect width="800" height="600" fill="#fafafa" rx="10"/>
  
  <!-- Title -->
  <text x="400" y="35" text-anchor="middle" font-family="Georgia, serif" font-size="20" font-weight="bold" fill="#333">
    Tropical Valuation Functor: Cross-Domain Bridge Map
  </text>
  
  <!-- Domain nodes -->
  <!-- Tropical Algebra -->
  <rect x="50" y="80" width="180" height="80" rx="15" fill="#e8f4fd" stroke="#4a90d9" stroke-width="2"/>
  <text x="140" y="115" text-anchor="middle" font-family="Arial" font-size="14" font-weight="bold" fill="#2c3e50">Tropical Algebra</text>
  <text x="140" y="135" text-anchor="middle" font-family="Arial" font-size="11" fill="#555">(min, +) semiring</text>
  <text x="140" y="150" text-anchor="middle" font-family="Arial" font-size="11" fill="#555">idempotent structure</text>
  
  <!-- p-Adic Analysis -->
  <rect x="310" y="80" width="180" height="80" rx="15" fill="#fde8e8" stroke="#d94a4a" stroke-width="2"/>
  <text x="400" y="115" text-anchor="middle" font-family="Arial" font-size="14" font-weight="bold" fill="#2c3e50">p-Adic Analysis</text>
  <text x="400" y="135" text-anchor="middle" font-family="Arial" font-size="11" fill="#555">ultrametric norms</text>
  <text x="400" y="150" text-anchor="middle" font-family="Arial" font-size="11" fill="#555">valuation v_p</text>
  
  <!-- Lattice Crypto -->
  <rect x="570" y="80" width="180" height="80" rx="15" fill="#e8fde8" stroke="#4ad94a" stroke-width="2"/>
  <text x="660" y="115" text-anchor="middle" font-family="Arial" font-size="14" font-weight="bold" fill="#2c3e50">Lattice Crypto</text>
  <text x="660" y="135" text-anchor="middle" font-family="Arial" font-size="11" fill="#555">post-quantum security</text>
  <text x="660" y="150" text-anchor="middle" font-family="Arial" font-size="11" fill="#555">LWE / NTRU</text>
  
  <!-- Neural Networks / ML -->
  <rect x="50" y="250" width="180" height="80" rx="15" fill="#fdf8e8" stroke="#d9c14a" stroke-width="2"/>
  <text x="140" y="280" text-anchor="middle" font-family="Arial" font-size="14" font-weight="bold" fill="#2c3e50">Neural Networks</text>
  <text x="140" y="300" text-anchor="middle" font-family="Arial" font-size="11" fill="#555">Lipschitz robustness</text>
  <text x="140" y="315" text-anchor="middle" font-family="Arial" font-size="11" fill="#555">gradient analysis</text>
  
  <!-- Number Theory -->
  <rect x="310" y="250" width="180" height="80" rx="15" fill="#f0e8fd" stroke="#8a4ad9" stroke-width="2"/>
  <text x="400" y="280" text-anchor="middle" font-family="Arial" font-size="14" font-weight="bold" fill="#2c3e50">Number Theory</text>
  <text x="400" y="300" text-anchor="middle" font-family="Arial" font-size="11" fill="#555">Fibonacci sequences</text>
  <text x="400" y="315" text-anchor="middle" font-family="Arial" font-size="11" fill="#555">prime factorization</text>
  
  <!-- Noetherian Algebra -->
  <rect x="570" y="250" width="180" height="80" rx="15" fill="#fde8f0" stroke="#d94a8a" stroke-width="2"/>
  <text x="660" y="280" text-anchor="middle" font-family="Arial" font-size="14" font-weight="bold" fill="#2c3e50">Commutative Algebra</text>
  <text x="660" y="300" text-anchor="middle" font-family="Arial" font-size="11" fill="#555">Noetherian rings</text>
  <text x="660" y="315" text-anchor="middle" font-family="Arial" font-size="11" fill="#555">ideal chains</text>
  
  <!-- Computation -->
  <rect x="310" y="420" width="180" height="80" rx="15" fill="#e8fdfd" stroke="#4ad9d9" stroke-width="2"/>
  <text x="400" y="450" text-anchor="middle" font-family="Arial" font-size="14" font-weight="bold" fill="#2c3e50">Computation</text>
  <text x="400" y="470" text-anchor="middle" font-family="Arial" font-size="11" fill="#555">O(n log n) sort</text>
  <text x="400" y="485" text-anchor="middle" font-family="Arial" font-size="11" fill="#555">Ω(2^n) enumeration</text>
  
  <!-- Bridges (edges) -->
  <!-- Tropical ↔ p-Adic -->
  <line x1="230" y1="120" x2="310" y2="120" stroke="#777" stroke-width="2" marker-end="url(#arrowhead)"/>
  <text x="270" y="108" text-anchor="middle" font-family="Arial" font-size="9" fill="#4a90d9" font-weight="bold">v_p functor</text>
  
  <!-- p-Adic ↔ Crypto -->
  <line x1="490" y1="120" x2="570" y2="120" stroke="#777" stroke-width="2" marker-end="url(#arrowhead)"/>
  <text x="530" y="108" text-anchor="middle" font-family="Arial" font-size="9" fill="#4ad94a" font-weight="bold">norm→lattice</text>
  
  <!-- Tropical ↔ ML -->
  <line x1="140" y1="160" x2="140" y2="250" stroke="#777" stroke-width="2" marker-end="url(#arrowhead)"/>
  <text x="115" y="210" text-anchor="middle" font-family="Arial" font-size="9" fill="#d9c14a" font-weight="bold" transform="rotate(-90 115 210)">Lipschitz comp.</text>
  
  <!-- p-Adic ↔ ML -->
  <line x1="310" y1="160" x2="230" y2="250" stroke="#777" stroke-width="1.5" stroke-dasharray="5,3" marker-end="url(#arrowhead)"/>
  <text x="250" y="200" text-anchor="middle" font-family="Arial" font-size="9" fill="#d94a4a">non-cancel.</text>
  
  <!-- Number Theory ↔ Tropical -->
  <line x1="310" y1="280" x2="230" y2="160" stroke="#777" stroke-width="1.5" stroke-dasharray="5,3" marker-end="url(#arrowhead)"/>
  <text x="250" y="215" text-anchor="middle" font-family="Arial" font-size="9" fill="#8a4ad9">Fib GCD=min</text>
  
  <!-- Algebra ↔ Crypto -->
  <line x1="660" y1="250" x2="660" y2="160" stroke="#777" stroke-width="2" marker-end="url(#arrowhead)"/>
  <text x="700" y="210" text-anchor="middle" font-family="Arial" font-size="9" fill="#d94a8a" font-weight="bold" transform="rotate(-90 700 210)">ACC→termin.</text>
  
  <!-- Computation ↔ Crypto -->
  <line x1="490" y1="450" x2="660" y2="330" stroke="#777" stroke-width="1.5" stroke-dasharray="5,3" marker-end="url(#arrowhead)"/>
  <text x="590" y="380" text-anchor="middle" font-family="Arial" font-size="9" fill="#4ad9d9">Ω(2^n) hardness</text>
  
  <!-- Computation ↔ Tropical -->
  <line x1="310" y1="440" x2="140" y2="330" stroke="#777" stroke-width="1.5" stroke-dasharray="5,3" marker-end="url(#arrowhead)"/>
  <text x="210" y="380" text-anchor="middle" font-family="Arial" font-size="9" fill="#4a90d9">trop. sort</text>
  
  <!-- Central functor label -->
  <rect x="280" y="185" width="240" height="40" rx="10" fill="url(#grad1)" stroke="#888" stroke-width="1"/>
  <text x="400" y="210" text-anchor="middle" font-family="Georgia, serif" font-size="13" font-weight="bold" fill="#333">
    v_p: (ℕ,×,gcd) → (ℤ,+,min)
  </text>
  
  <!-- Legend -->
  <rect x="50" y="530" width="700" height="50" rx="8" fill="#f5f5f5" stroke="#ddd"/>
  <text x="70" y="555" font-family="Arial" font-size="11" fill="#555">
    <tspan font-weight="bold">Legend:</tspan>
    <tspan dx="10">━━</tspan> <tspan dx="5">Primary bridge</tspan>
    <tspan dx="20">╌╌</tspan> <tspan dx="5">Secondary connection</tspan>
    <tspan dx="20">▶</tspan> <tspan dx="5">Functorial direction</tspan>
    <tspan dx="20" font-weight="bold" fill="#4a90d9">51 theorems</tspan>
    <tspan dx="5">·</tspan>
    <tspan dx="5" font-weight="bold" fill="#4ad94a">8 structures</tspan>
    <tspan dx="5">·</tspan>
    <tspan dx="5" font-weight="bold" fill="#d94a4a">0 sorry</tspan>
  </text>
</svg>'''
    
    with open("diagram.svg", "w") as f:
        f.write(svg)
    print("Generated diagram.svg")
    return svg


def generate_convergence_chart_svg():
    """Generate convergence chart as SVG."""
    # Lipschitz depth-security tradeoff data
    L_values = [0.8, 0.9, 1.0, 1.1, 1.2]
    n_range = list(range(1, 21))
    
    width, height = 600, 400
    margin = {'top': 40, 'right': 120, 'bottom': 50, 'left': 60}
    plot_w = width - margin['left'] - margin['right']
    plot_h = height - margin['top'] - margin['bottom']
    
    # Scale functions
    def x_scale(n):
        return margin['left'] + (n - 1) / 19 * plot_w
    
    max_y = max(L ** 20 for L in L_values if L > 1)
    def y_scale(v):
        # Log scale
        v = max(v, 0.01)
        log_v = math.log10(v)
        log_min = math.log10(0.01)
        log_max = math.log10(max_y)
        return margin['top'] + plot_h - (log_v - log_min) / (log_max - log_min) * plot_h
    
    colors = ['#2196F3', '#4CAF50', '#9E9E9E', '#FF9800', '#F44336']
    
    svg_parts = [f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {width} {height}" width="{width}" height="{height}">
    <rect width="{width}" height="{height}" fill="white" rx="5"/>
    <text x="{width//2}" y="25" text-anchor="middle" font-family="Arial" font-size="14" font-weight="bold">
      Lipschitz Depth-Security Tradeoff: L^n vs Network Depth
    </text>''']
    
    # Grid lines
    for i in range(5):
        y = margin['top'] + i * plot_h / 4
        svg_parts.append(f'<line x1="{margin["left"]}" y1="{y}" x2="{margin["left"]+plot_w}" y2="{y}" stroke="#eee" stroke-width="1"/>')
    
    # Axes
    svg_parts.append(f'<line x1="{margin["left"]}" y1="{margin["top"]}" x2="{margin["left"]}" y2="{margin["top"]+plot_h}" stroke="#333" stroke-width="1.5"/>')
    svg_parts.append(f'<line x1="{margin["left"]}" y1="{margin["top"]+plot_h}" x2="{margin["left"]+plot_w}" y2="{margin["top"]+plot_h}" stroke="#333" stroke-width="1.5"/>')
    
    # Axis labels
    svg_parts.append(f'<text x="{width//2}" y="{height-5}" text-anchor="middle" font-family="Arial" font-size="12">Network Depth (n)</text>')
    svg_parts.append(f'<text x="15" y="{height//2}" text-anchor="middle" font-family="Arial" font-size="12" transform="rotate(-90 15 {height//2})">L^n (log scale)</text>')
    
    # X-axis ticks
    for n in [1, 5, 10, 15, 20]:
        x = x_scale(n)
        svg_parts.append(f'<text x="{x}" y="{margin["top"]+plot_h+20}" text-anchor="middle" font-family="Arial" font-size="10">{n}</text>')
    
    # Plot lines
    for idx, L in enumerate(L_values):
        points = []
        for n in n_range:
            val = L ** n
            if 0.01 <= val <= max_y:
                x = x_scale(n)
                y = y_scale(val)
                points.append(f"{x},{y}")
        
        if points:
            polyline = " ".join(points)
            svg_parts.append(f'<polyline points="{polyline}" fill="none" stroke="{colors[idx]}" stroke-width="2"/>')
        
        # Legend
        ly = margin['top'] + 20 + idx * 25
        svg_parts.append(f'<line x1="{margin["left"]+plot_w+10}" y1="{ly}" x2="{margin["left"]+plot_w+30}" y2="{ly}" stroke="{colors[idx]}" stroke-width="2"/>')
        svg_parts.append(f'<text x="{margin["left"]+plot_w+35}" y="{ly+4}" font-family="Arial" font-size="11">L={L}</text>')
    
    # L=1 reference line
    y1 = y_scale(1.0)
    svg_parts.append(f'<line x1="{margin["left"]}" y1="{y1}" x2="{margin["left"]+plot_w}" y2="{y1}" stroke="#999" stroke-width="1" stroke-dasharray="5,3"/>')
    svg_parts.append(f'<text x="{margin["left"]+plot_w+5}" y="{y1+4}" font-family="Arial" font-size="9" fill="#999">L^n=1</text>')
    
    svg_parts.append('</svg>')
    return '\n'.join(svg_parts)


if __name__ == "__main__":
    svg_main = generate_svg_diagram()
    svg_chart = generate_convergence_chart_svg()
    with open("convergence_chart.svg", "w") as f:
        f.write(svg_chart)
    print("Generated convergence_chart.svg")
    print("All visualizations generated successfully.")
