#!/usr/bin/env python3
"""
Tropical Hardness vs Randomness: Core Algorithms

Implements the key algorithms from the tropical HVR framework:
1. Tropical matrix operations (min-plus semiring)
2. Nisan-Wigderson generator
3. Combinatorial design construction
4. Hybrid argument analysis
5. Collision-bounded prediction analysis

Each algorithm includes docstrings, type hints, complexity analysis,
and example usage.
"""

from typing import List, Tuple, Callable, Optional, Set
from dataclasses import dataclass
import math
import random
from itertools import product as cartesian_product

INF = float('inf')

# ============================================================================
# Algorithm 1: Tropical (Min-Plus) Matrix Algebra
# ============================================================================

class TropicalMatrix:
    """
    Matrix over the tropical (min-plus) semiring: (ℤ ∪ {+∞}, min, +).

    Tropical addition is min, tropical multiplication is +.
    The additive identity is +∞, the multiplicative identity is 0.

    Time complexity for n×n matrices:
    - Addition: O(n²)
    - Multiplication: O(n³)
    - k-th power: O(n³ log k)

    Space complexity: O(n²)
    """

    def __init__(self, data: List[List[float]]):
        """Initialize from 2D list. Use float('inf') for +∞."""
        self.n = len(data)
        self.data = [row[:] for row in data]

    @classmethod
    def identity(cls, n: int) -> 'TropicalMatrix':
        """Tropical identity: 0 on diagonal, +∞ elsewhere."""
        data = [[0.0 if i == j else INF for j in range(n)] for i in range(n)]
        return cls(data)

    @classmethod
    def from_graph(cls, n: int, edges: List[Tuple[int, int, float]]) -> 'TropicalMatrix':
        """
        Create adjacency matrix from weighted directed graph.
        edges: list of (from, to, weight)
        """
        data = [[INF] * n for _ in range(n)]
        for i in range(n):
            data[i][i] = 0.0
        for u, v, w in edges:
            data[u][v] = min(data[u][v], w)
        return cls(data)

    def __matmul__(self, other: 'TropicalMatrix') -> 'TropicalMatrix':
        """
        Tropical matrix multiplication.

        C[i][j] = min_k (A[i][k] + B[k][j])

        This computes shortest paths through one intermediate step.

        Time: O(n³), Space: O(n²)
        """
        assert self.n == other.n
        n = self.n
        result = [[INF] * n for _ in range(n)]
        for i in range(n):
            for j in range(n):
                for k in range(n):
                    a, b = self.data[i][k], other.data[k][j]
                    if a != INF and b != INF:
                        result[i][j] = min(result[i][j], a + b)
        return TropicalMatrix(result)

    def power(self, k: int) -> 'TropicalMatrix':
        """
        Compute A^k in the tropical semiring via repeated squaring.

        A^k[i][j] = weight of shortest path from i to j using exactly k edges.
        A^* = A^0 ⊕ A^1 ⊕ ... ⊕ A^(n-1) = all-pairs shortest paths.

        Time: O(n³ log k), Space: O(n²)
        """
        result = TropicalMatrix.identity(self.n)
        base = TropicalMatrix([row[:] for row in self.data])
        while k > 0:
            if k % 2 == 1:
                result = result @ base
            base = base @ base
            k //= 2
        return result

    def all_pairs_shortest_paths(self) -> 'TropicalMatrix':
        """
        Compute APSP = A^0 ⊕ A ⊕ A² ⊕ ... ⊕ A^(n-1).

        Uses repeated squaring: compute A^(2^k) for k = 0, ..., ⌈log n⌉
        and take the tropical sum.

        Time: O(n³ log n), Space: O(n²)
        """
        n = self.n
        result = TropicalMatrix.identity(n)
        power = TropicalMatrix([row[:] for row in self.data])
        for _ in range(math.ceil(math.log2(max(n, 2)))):
            # result = result ⊕ result @ power
            product = result @ power
            for i in range(n):
                for j in range(n):
                    result.data[i][j] = min(result.data[i][j], product.data[i][j])
            power = power @ power
        return result

    def __repr__(self) -> str:
        rows = []
        for row in self.data:
            entries = [f"{x:6.1f}" if x != INF else "   INF" for x in row]
            rows.append("[" + ", ".join(entries) + "]")
        return "[\n  " + "\n  ".join(rows) + "\n]"


# ============================================================================
# Algorithm 2: Combinatorial Design Construction
# ============================================================================

@dataclass
class CombinatorialDesign:
    """
    A (m, n, d, ℓ)-combinatorial design for the NW generator.

    - m sets S_0, ..., S_{m-1}
    - Each S_i ⊆ [d] with |S_i| = n
    - For i ≠ j: |S_i ∩ S_j| ≤ ℓ

    The design determines how seed bits are shared across generator blocks.
    Small ℓ means blocks are nearly independent, enabling the hybrid argument.
    """
    n: int          # block size
    d: int          # universe size (seed length)
    m: int          # number of sets (output length)
    ell: int        # max pairwise intersection
    sets: List[List[int]]  # the actual sets

    def overlap(self, i: int, j: int) -> int:
        """Compute |S_i ∩ S_j|."""
        return len(set(self.sets[i]) & set(self.sets[j]))

    def max_overlap(self) -> int:
        """Compute max pairwise overlap."""
        return max(
            self.overlap(i, j)
            for i in range(self.m) for j in range(i+1, self.m)
        ) if self.m > 1 else 0

    def verify(self) -> bool:
        """Verify all design properties."""
        # Check set sizes
        for S in self.sets:
            if len(S) != self.n:
                return False
            if any(x < 0 or x >= self.d for x in S):
                return False
        # Check overlap bound
        if self.max_overlap() > self.ell:
            return False
        return True


def construct_polynomial_design(n: int, q: int) -> CombinatorialDesign:
    """
    Construct a combinatorial design using polynomials over GF(q).

    For each polynomial p of degree < n over GF(q), define:
    S_p = {(a, p(a) mod q) : a ∈ GF(q)}

    This gives:
    - m = q^n sets (one per polynomial of degree < n)
    - d = q² (universe is GF(q) × GF(q))
    - |S_p| = q (evaluate at each point in GF(q))
    - |S_p ∩ S_q| ≤ n-1 (distinct degree-<n polynomials agree on ≤ n-1 points)

    Time: O(q^n · q · n) to construct all sets
    Space: O(q^n · q) to store all sets

    Args:
        n: polynomial degree bound + 1 (= block size)
        q: field size (must be prime for simplicity)

    Returns:
        CombinatorialDesign with parameters (q, q², q^n, n-1)
    """
    # Simple construction: polynomials as coefficient vectors
    all_coeffs = list(cartesian_product(range(q), repeat=n))
    m = len(all_coeffs)  # q^n

    def eval_poly(coeffs: Tuple[int, ...], x: int) -> int:
        """Evaluate polynomial with given coefficients at x mod q."""
        result = 0
        for i, c in enumerate(coeffs):
            result = (result + c * pow(x, i, q)) % q
        return result

    sets = []
    for coeffs in all_coeffs:
        S = []
        for a in range(q):
            # Map (a, p(a)) to a single index in [q²]
            b = eval_poly(coeffs, a)
            S.append(a * q + b)
        sets.append(S)

    return CombinatorialDesign(
        n=q,  # block size = q
        d=q * q,  # universe = q²
        m=m,  # q^n sets
        ell=n - 1,  # max overlap = degree bound - 1
        sets=sets
    )


# ============================================================================
# Algorithm 3: NW Generator
# ============================================================================

class NWGenerator:
    """
    The Nisan-Wigderson Pseudorandom Generator.

    Given:
    - f: {0,1}^n → {0,1} (the hard function)
    - design: combinatorial design with m sets of size n from [d]

    The generator G: {0,1}^d → {0,1}^m is defined by:
    G(seed)_i = f(seed|_{S_i})

    Security: if f is (s, δ)-hard (no circuit of size s can predict f
    with agreement > 1/2 + δ), then G ε-fools all circuits of size
    s' ≈ s/m, where ε = m · δ.

    Time: O(m · T_f) where T_f is the evaluation time of f
    Space: O(d + n + m) for seed, projected input, and output
    """

    def __init__(self, f: Callable, design: CombinatorialDesign):
        self.f = f
        self.design = design
        self.seed_length = design.d
        self.output_length = design.m

    def generate(self, seed: Tuple[int, ...]) -> Tuple[int, ...]:
        """
        Generate pseudorandom output from seed.

        Args:
            seed: d-bit string (tuple of 0/1)

        Returns:
            m-bit pseudorandom output

        Time: O(m · (n + T_f))
        """
        assert len(seed) == self.seed_length
        output = []
        for S in self.design.sets:
            projected = tuple(seed[j] for j in S)
            output.append(self.f(projected))
        return tuple(output)

    def measure_advantage(self, test: Callable, num_samples: int = 10000) -> float:
        """
        Empirically measure the advantage of a test against this generator.

        advantage = |Pr[test(G(seed))] - Pr[test(uniform)]|

        Time: O(num_samples · (m · T_f + T_test))
        """
        # Acceptance probability on generator output
        gen_accepts = 0
        for _ in range(num_samples):
            seed = tuple(random.randint(0, 1) for _ in range(self.seed_length))
            output = self.generate(seed)
            gen_accepts += test(output)

        # Acceptance probability on truly random
        rand_accepts = 0
        for _ in range(num_samples):
            output = tuple(random.randint(0, 1) for _ in range(self.output_length))
            rand_accepts += test(output)

        return abs(gen_accepts / num_samples - rand_accepts / num_samples)


# ============================================================================
# Algorithm 4: Hybrid Argument Analysis
# ============================================================================

def hybrid_analysis(
    acceptance_probs: List[float]
) -> dict:
    """
    Analyze the hybrid argument for a given sequence of acceptance probabilities.

    Input: acceptance_probs[i] = Pr[T accepts H_i]
    where H_0 = generator output, H_m = truly random.

    Returns analysis including:
    - Total advantage
    - Per-coordinate gaps
    - Maximum gap (the "bottleneck" coordinate)
    - Verification of telescope inequality

    Time: O(m), Space: O(m)
    """
    m = len(acceptance_probs) - 1
    total_advantage = abs(acceptance_probs[0] - acceptance_probs[-1])

    gaps = [abs(acceptance_probs[i] - acceptance_probs[i+1]) for i in range(m)]
    sum_gaps = sum(gaps)
    max_gap = max(gaps) if gaps else 0
    max_gap_index = gaps.index(max_gap) if gaps else -1
    avg_gap = total_advantage / m if m > 0 else 0

    return {
        "total_advantage": total_advantage,
        "gaps": gaps,
        "sum_of_gaps": sum_gaps,
        "max_gap": max_gap,
        "max_gap_coordinate": max_gap_index,
        "average_gap": avg_gap,
        "telescope_valid": total_advantage <= sum_gaps + 1e-10,
        "pigeonhole_valid": max_gap >= avg_gap - 1e-10,
    }


# ============================================================================
# Algorithm 5: Collision Analysis for Tropical Hash
# ============================================================================

def collision_analysis(
    domain_size: int,
    hash_func: Callable,
    domain_generator: Callable
) -> dict:
    """
    Analyze collision properties of a hash function.

    Returns:
    - Fiber sizes (preimage sizes for each hash value)
    - Maximum fiber size
    - Collision probability
    - Prediction advantage bound

    Time: O(domain_size · T_hash)
    Space: O(domain_size + range_size)
    """
    fibers = {}
    for i in range(domain_size):
        x = domain_generator(i)
        h = hash_func(x)
        if h not in fibers:
            fibers[h] = 0
        fibers[h] += 1

    max_fiber = max(fibers.values())
    range_size = len(fibers)

    # Collision probability: Pr[h(x) = h(y)] for random x, y
    collision_prob = sum(c * (c - 1) for c in fibers.values()) / (domain_size * (domain_size - 1)) if domain_size > 1 else 0

    # Prediction bound: any predictor based on hash agrees ≤ 1/2 + C·|range|/(2·|domain|)
    pred_bound = 0.5 + max_fiber * range_size / (2 * domain_size)

    return {
        "domain_size": domain_size,
        "range_size": range_size,
        "max_fiber_size": max_fiber,
        "collision_probability": collision_prob,
        "prediction_advantage_bound": pred_bound,
        "fibers": dict(sorted(fibers.items())),
    }


# ============================================================================
# Example usage
# ============================================================================

if __name__ == "__main__":
    print("=== Tropical Matrix Example ===")
    A = TropicalMatrix([
        [0, 3, INF, 7],
        [INF, 0, 2, INF],
        [INF, INF, 0, 1],
        [INF, INF, INF, 0]
    ])
    print("A =", A)
    print("A² =", A @ A)
    print("A⁴ =", A.power(4))

    print("\n=== Design Construction Example ===")
    design = construct_polynomial_design(n=2, q=5)
    print(f"Design: {design.m} sets of size {design.n} from [{design.d}]")
    print(f"Max overlap: {design.max_overlap()}")
    print(f"Valid: {design.verify()}")

    print("\n=== NW Generator Example ===")
    small_design = CombinatorialDesign(
        n=3, d=8, m=4, ell=1,
        sets=[[0,1,2], [2,3,4], [4,5,6], [6,7,0]]
    )
    gen = NWGenerator(lambda x: sum(x) % 2, small_design)
    seed = (1, 0, 1, 1, 0, 0, 1, 0)
    print(f"G({seed}) = {gen.generate(seed)}")

    print("\n=== Hybrid Analysis Example ===")
    result = hybrid_analysis([0.72, 0.68, 0.63, 0.59, 0.54, 0.50])
    print(f"Total advantage: {result['total_advantage']:.4f}")
    print(f"Max gap at coordinate {result['max_gap_coordinate']}: {result['max_gap']:.4f}")
    print(f"Telescope valid: {result['telescope_valid']}")
    print(f"Pigeonhole valid: {result['pigeonhole_valid']}")

    print("\n=== Collision Analysis Example ===")
    result = collision_analysis(
        domain_size=64,
        hash_func=lambda x: min(x[0], x[2]),
        domain_generator=lambda i: ((i >> 4) & 3, (i >> 2) & 3, i & 3, 0)
    )
    print(f"Domain: {result['domain_size']}, Range: {result['range_size']}")
    print(f"Max fiber: {result['max_fiber_size']}")
    print(f"Collision prob: {result['collision_probability']:.4f}")
    print(f"Prediction bound: {result['prediction_advantage_bound']:.4f}")
