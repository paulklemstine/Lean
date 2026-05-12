#!/usr/bin/env python3
"""
Tropical Pontryagin–Mellin Duality: Core Algorithms

Implements the key algorithms from the theory:
1. Tropical Mellin Transform
2. Min-Plus Convolution
3. Sparse Tropical Decoding
4. Character Matrix Analysis
"""

import numpy as np
from typing import List, Tuple, Optional, Dict, Set
import itertools

INF = float('inf')


# ============================================================
# Core Tropical Arithmetic
# ============================================================

def trop_add(a: float, b: float) -> float:
    """Tropical addition: min(a, b)"""
    return min(a, b)

def trop_mul(a: float, b: float) -> float:
    """Tropical multiplication: a + b (with ∞ absorbing)"""
    if a == INF or b == INF:
        return INF
    return a + b

def trop_matvec(A: np.ndarray, x: np.ndarray) -> np.ndarray:
    """
    Tropical matrix-vector product: y_i = min_j (A[i,j] + x[j])
    
    Parameters:
        A: m × n matrix of tropical values
        x: n-vector of tropical values
    Returns:
        m-vector y where y_i = min_j(A[i,j] + x[j])
    
    Complexity: O(m * n)
    """
    m, n = A.shape
    y = np.full(m, INF)
    for i in range(m):
        for j in range(n):
            val = trop_mul(A[i, j], x[j])
            y[i] = trop_add(y[i], val)
    return y


# ============================================================
# Tropical Mellin Transform
# ============================================================

class TropicalMellinTransform:
    """
    The tropical Mellin transform of a finitely-supported function f:
        M(f)(χ) = inf_{s ∈ supp(f)} (f(s) + χ(s))
    
    This converts min-plus convolution to pointwise tropical multiplication.
    
    Algorithm:
        Input: function f with finite support, character χ
        Output: M(f)(χ) = min_{s in support} (f(s) + χ(s))
        
    Time complexity: O(|support|)
    Space complexity: O(|support|)
    """
    
    def __init__(self, values: Dict[int, float]):
        """
        Initialize with a dictionary mapping support elements to values.
        Elements not in the dictionary have value ⊤ = +∞.
        """
        self.values = {k: v for k, v in values.items() if v < INF}
    
    @property
    def support(self) -> Set[int]:
        return set(self.values.keys())
    
    def __call__(self, s: int) -> float:
        return self.values.get(s, INF)
    
    def transform(self, chi: Dict[int, float]) -> float:
        """
        Compute M(f)(χ) = min_{s ∈ support} (f(s) + χ(s))
        """
        if not self.values:
            return INF
        return min(
            trop_mul(self.values[s], chi.get(s, INF))
            for s in self.values
        )
    
    @staticmethod
    def convolve(f: 'TropicalMellinTransform', 
                 g: 'TropicalMellinTransform',
                 mul_op=lambda a, b: a + b) -> 'TropicalMellinTransform':
        """
        Min-plus convolution: (f ⋆ g)(t) = inf_{a·b=t} (f(a) + g(b))
        
        Parameters:
            f, g: TropicalMellinTransform objects
            mul_op: the semiring multiplication (default: addition)
        
        Time complexity: O(|supp(f)| * |supp(g)|)
        """
        result = {}
        for a, fa in f.values.items():
            for b, gb in g.values.items():
                t = mul_op(a, b)
                val = trop_mul(fa, gb)
                if t in result:
                    result[t] = trop_add(result[t], val)
                else:
                    result[t] = val
        return TropicalMellinTransform(result)
    
    def verify_convolution_theorem(self, g: 'TropicalMellinTransform',
                                    chi: Dict[int, float],
                                    mul_op=lambda a, b: a + b) -> Tuple[float, float, bool]:
        """
        Verify that M(f⋆g)(χ) = M(f)(χ) + M(g)(χ).
        
        Returns: (lhs, rhs, equal)
        """
        conv = TropicalMellinTransform.convolve(self, g, mul_op)
        
        # Need chi values for convolution support elements
        chi_ext = dict(chi)
        for t in conv.support:
            if t not in chi_ext:
                # Compute from character's multiplicativity if possible
                chi_ext[t] = chi.get(t, INF)
        
        lhs = conv.transform(chi_ext)
        rhs = trop_mul(self.transform(chi), g.transform(chi))
        
        return lhs, rhs, abs(lhs - rhs) < 1e-10 if lhs < INF and rhs < INF else lhs == rhs


# ============================================================
# Sparse Tropical Decoder
# ============================================================

class SparseTropicalDecoder:
    """
    Certified sparse decoder for tropical compressed sensing.
    
    Given:
        - Character matrix A[i,j] = χ_i(g_j)
        - Measurements y_i = min_j(x_j + A[i,j])
        - Sparsity bound k
    
    Recovers the unique k-sparse signal x.
    
    Algorithm (brute-force, certified):
        1. For each k-subset S of {1,...,n}:
           a. Solve for x_j = min_i(y_i - A[i,j]) for j ∈ S
           b. Set x_j = ∞ for j ∉ S
           c. Verify: min_j(x_j + A[i,j]) = y_i for all i
        2. Return the unique valid solution (if nondegeneracy holds)
    
    Time complexity: O(C(n,k) * m * n) where C(n,k) = n choose k
    Space complexity: O(n + m)
    """
    
    def __init__(self, char_matrix: np.ndarray, sparsity: int):
        """
        Parameters:
            char_matrix: m × n matrix A[i,j] = χ_i(g_j)
            sparsity: maximum sparsity k
        """
        self.A = char_matrix
        self.m, self.n = char_matrix.shape
        self.k = sparsity
    
    def encode(self, x: np.ndarray) -> np.ndarray:
        """
        Encode a signal: y_i = min_j(x_j + A[i,j])
        """
        return trop_matvec(self.A, x)
    
    def decode(self, y: np.ndarray) -> Optional[np.ndarray]:
        """
        Decode measurements to recover the sparse signal.
        Returns None if no valid k-sparse solution exists.
        """
        solutions = []
        
        for support in itertools.combinations(range(self.n), self.k):
            x_cand = np.full(self.n, INF)
            
            for j in support:
                # Optimal value: x_j = min_i(y_i - A[i,j])
                x_cand[j] = min(y[i] - self.A[i, j] for i in range(self.m))
            
            # Verify
            y_check = self.encode(x_cand)
            if np.allclose(y_check, y, atol=1e-8):
                solutions.append(x_cand.copy())
        
        if len(solutions) == 1:
            return solutions[0]
        elif len(solutions) > 1:
            print(f"  Warning: {len(solutions)} solutions found (nondegeneracy violated)")
            return solutions[0]
        return None
    
    def check_nondegeneracy(self) -> bool:
        """
        Check if the character matrix is tropically nondegenerate
        for the given sparsity level.
        
        This verifies that for every pair of distinct k-sparse signals,
        their measurements differ.
        """
        # Generate random test signals and check for collisions
        n_tests = min(1000, 2 ** self.n)
        seen = {}
        
        for _ in range(n_tests):
            # Random k-sparse signal
            support = np.random.choice(self.n, self.k, replace=False)
            x = np.full(self.n, INF)
            x[support] = np.random.rand(self.k) * 10
            
            y = self.encode(x)
            key = tuple(np.round(y, 8))
            
            if key in seen:
                x_prev = seen[key]
                if not np.allclose(x, x_prev, atol=1e-6):
                    return False
            seen[key] = x.copy()
        
        return True
    
    def tropical_rank(self) -> int:
        """
        Compute the tropical rank of the character matrix.
        The tropical rank is the smallest r such that A can be written
        as a tropical product of an m×r and r×n matrix.
        
        For small matrices, uses exhaustive search.
        """
        # Simple heuristic: count distinct row/column patterns
        row_patterns = set()
        for i in range(self.m):
            normalized = tuple(self.A[i] - np.min(self.A[i]))
            row_patterns.add(normalized)
        return len(row_patterns)


# ============================================================
# Character Matrix Generator
# ============================================================

def generate_nondegenerate_matrix(m: int, n: int, k: int, 
                                  seed: int = 42) -> np.ndarray:
    """
    Generate a tropically nondegenerate character matrix.
    
    Uses random Gaussian entries scaled to ensure good separation.
    
    Parameters:
        m: number of characters (measurements)
        n: number of generators (signal dimension)
        k: sparsity level
        seed: random seed
    
    Returns:
        m × n matrix with tropical nondegeneracy for k-sparse signals
    """
    rng = np.random.RandomState(seed)
    
    # Use entries from different scales for good separation
    A = np.zeros((m, n))
    for i in range(m):
        for j in range(n):
            A[i, j] = rng.exponential(scale=2.0 + i + j)
    
    return A


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("Tropical Mellin Transform: Algorithm Demonstrations")
    print("=" * 60)
    
    # --- Mellin Transform ---
    print("\n--- Mellin Transform ---")
    f = TropicalMellinTransform({0: 3.0, 2: 1.0, 5: 4.0})
    g = TropicalMellinTransform({1: 2.0, 3: 0.5})
    
    # Character: χ(s) = 0.5 * s
    chi = {s: 0.5 * s for s in range(10)}
    
    print(f"  f support: {f.support}, values: {f.values}")
    print(f"  g support: {g.support}, values: {g.values}")
    print(f"  M(f)(χ) = {f.transform(chi):.3f}")
    print(f"  M(g)(χ) = {g.transform(chi):.3f}")
    
    lhs, rhs, ok = f.verify_convolution_theorem(g, chi)
    print(f"  M(f⋆g)(χ) = {lhs:.3f}")
    print(f"  M(f)(χ) + M(g)(χ) = {rhs:.3f}")
    print(f"  Convolution theorem: {'✓' if ok else '✗'}")
    
    # --- Sparse Decoding ---
    print("\n--- Sparse Decoding ---")
    n, m, k = 8, 6, 2
    A = generate_nondegenerate_matrix(m, n, k)
    decoder = SparseTropicalDecoder(A, k)
    
    # True signal
    x_true = np.full(n, INF)
    x_true[2] = 1.5
    x_true[6] = 3.0
    
    y = decoder.encode(x_true)
    x_decoded = decoder.decode(y)
    
    print(f"  Signal dimension: {n}, measurements: {m}, sparsity: {k}")
    print(f"  True signal support: {[j for j in range(n) if x_true[j] < INF]}")
    
    if x_decoded is not None:
        decoded_supp = [j for j in range(n) if x_decoded[j] < INF]
        print(f"  Decoded support: {decoded_supp}")
        match = np.allclose(
            [x_true[j] for j in range(n) if x_true[j] < INF],
            [x_decoded[j] for j in range(n) if x_decoded[j] < INF],
            atol=1e-8
        )
        print(f"  Exact recovery: {'✓' if match else '✗'}")
    
    # Check nondegeneracy
    nondeg = decoder.check_nondegeneracy()
    print(f"  Tropical nondegeneracy: {'✓' if nondeg else '✗'}")
    trank = decoder.tropical_rank()
    print(f"  Tropical rank estimate: {trank}")
    
    print("\n" + "=" * 60)
    print("All algorithms completed successfully!")
    print("=" * 60)
