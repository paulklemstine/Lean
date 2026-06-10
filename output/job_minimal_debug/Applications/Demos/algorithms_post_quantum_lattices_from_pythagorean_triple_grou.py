#!/usr/bin/env python3
"""
Berggren Post-Quantum Lattices: Core Algorithms

Implements the algorithms described in the research paper:
- Berggren tree traversal and orbit generation
- Lattice basis construction from orbit vectors
- Security parameter estimation
- Norm growth analysis
"""

import numpy as np
from math import gcd, log2, sqrt
from typing import List, Tuple, Optional, Dict
from dataclasses import dataclass
from itertools import product


# ============================================================
# Algorithm 1: Berggren Matrix Definitions
# ============================================================

# Berggren generators (integral orthogonal matrices for Q = diag(1,1,-1))
BERGGREN_A = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]], dtype=np.int64)
BERGGREN_B = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]], dtype=np.int64)
BERGGREN_C = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]], dtype=np.int64)

BERGGREN_GENERATORS = [BERGGREN_A, BERGGREN_B, BERGGREN_C]
ROOT_TRIPLE = np.array([3, 4, 5], dtype=np.int64)


# ============================================================
# Algorithm 2: Berggren Word Evaluation
# ============================================================

def evaluate_word(word: List[int], seed: np.ndarray = ROOT_TRIPLE) -> np.ndarray:
    """
    Evaluate a Berggren word on a seed vector.
    
    Args:
        word: List of generator indices (0=A, 1=B, 2=C)
        seed: Starting vector (default: (3,4,5))
    
    Returns:
        Result of applying the generator sequence to seed.
    
    Time complexity: O(|word|) matrix-vector multiplications.
    Space complexity: O(1) beyond input.
    
    Example:
        >>> evaluate_word([0])  # Apply A to (3,4,5)
        array([ 5, 12, 13])
        >>> evaluate_word([0, 1])  # Apply A then B
        array([39, 80, 89])
    """
    v = seed.copy()
    for idx in reversed(word):
        v = BERGGREN_GENERATORS[idx] @ v
    return v


def word_matrix(word: List[int]) -> np.ndarray:
    """
    Compute the matrix product corresponding to a Berggren word.
    
    Args:
        word: List of generator indices
    
    Returns:
        Product matrix M_w = G_{w[0]} · G_{w[1]} · ... · G_{w[n-1]}
    
    Time complexity: O(|word|) matrix multiplications.
    """
    M = np.eye(3, dtype=np.int64)
    for idx in word:
        M = BERGGREN_GENERATORS[idx] @ M
    return M


# ============================================================
# Algorithm 3: Berggren Tree BFS Generation
# ============================================================

@dataclass
class OrbitVector:
    """A vector in the Berggren orbit with its generating word."""
    vector: np.ndarray
    word: List[int]
    depth: int
    
    @property
    def hypotenuse(self) -> int:
        return int(self.vector[2])
    
    @property
    def squared_norm(self) -> int:
        return int(sum(x**2 for x in self.vector))
    
    def is_pythagorean(self) -> bool:
        a, b, c = int(self.vector[0]), int(self.vector[1]), int(self.vector[2])
        return a**2 + b**2 == c**2
    
    def is_primitive(self) -> bool:
        a, b, c = int(self.vector[0]), int(self.vector[1]), int(self.vector[2])
        return self.is_pythagorean() and a > 0 and b > 0 and c > 0 and gcd(a, b) == 1


def generate_orbit(max_depth: int) -> List[OrbitVector]:
    """
    Generate all Berggren orbit vectors up to a given depth using BFS.
    
    Args:
        max_depth: Maximum word length
    
    Returns:
        List of OrbitVector objects, sorted by depth then word.
    
    Time complexity: O(3^max_depth) orbit evaluations.
    Space complexity: O(3^max_depth) stored vectors.
    
    Example:
        >>> orbit = generate_orbit(2)
        >>> len(orbit)  # 1 + 3 + 9 = 13
        13
    """
    result = [OrbitVector(ROOT_TRIPLE.copy(), [], 0)]
    current = [(ROOT_TRIPLE.copy(), [])]
    
    for depth in range(1, max_depth + 1):
        next_level = []
        for v, word in current:
            for idx in range(3):
                w = BERGGREN_GENERATORS[idx] @ v
                new_word = [idx] + word
                result.append(OrbitVector(w, new_word, depth))
                next_level.append((w, new_word))
        current = next_level
    
    return result


# ============================================================
# Algorithm 4: Lattice Basis Construction
# ============================================================

def orbit_lattice_basis(vectors: List[np.ndarray]) -> Tuple[np.ndarray, int]:
    """
    Construct a lattice basis from orbit vectors using HNF.
    
    Args:
        vectors: List of integer vectors (as columns)
    
    Returns:
        Tuple of (basis matrix, determinant)
    
    Time complexity: O(n³) for n vectors in ℤ³.
    """
    if len(vectors) == 0:
        return np.zeros((3, 0), dtype=np.int64), 0
    
    M = np.column_stack(vectors).astype(np.int64)
    if M.shape[1] >= 3:
        # Take first 3 linearly independent vectors
        det = int(round(np.linalg.det(M[:, :3].astype(float))))
        return M[:, :3], det
    return M, 0


def compute_lattice_index(depth: int) -> int:
    """
    Compute the index of the depth-d orbit lattice in ℤ³.
    
    For depth 1, the three orbit vectors form a matrix with det = -240,
    so the lattice has index 240 in ℤ³.
    
    Args:
        depth: Berggren tree depth
    
    Returns:
        Index (absolute value of determinant)
    """
    orbit = generate_orbit(depth)
    vectors = [ov.vector for ov in orbit if ov.depth > 0]
    if len(vectors) < 3:
        return 0
    _, det = orbit_lattice_basis(vectors[:3])
    return abs(det)


# ============================================================
# Algorithm 5: Security Parameter Estimation
# ============================================================

@dataclass
class SecurityParameters:
    """Post-quantum security parameters for Berggren-based schemes."""
    word_length: int
    search_space: int
    classical_security_bits: float
    quantum_security_bits: float
    key_bits: int
    
    def __str__(self):
        return (f"SecurityParameters(m={self.word_length}, "
                f"classical={self.classical_security_bits:.1f}b, "
                f"quantum={self.quantum_security_bits:.1f}b, "
                f"key={self.key_bits}b)")


def estimate_security(word_length: int, key_bits: int = 256) -> SecurityParameters:
    """
    Estimate post-quantum security parameters for a Berggren key exchange.
    
    The secret is a Berggren word of length m. The search space has 3^m
    elements. Grover's algorithm provides a quadratic speedup, requiring
    Ω(3^(m/2)) quantum queries.
    
    Args:
        word_length: Length m of the secret Berggren word
        key_bits: Desired key length in bits
    
    Returns:
        SecurityParameters object with classical and quantum security estimates.
    
    Example:
        >>> params = estimate_security(256)
        >>> params.quantum_security_bits > 128
        True
    """
    entropy = word_length * log2(3)
    classical = entropy
    quantum = entropy / 2  # Grover halving
    
    return SecurityParameters(
        word_length=word_length,
        search_space=3**min(word_length, 100),  # Cap for display
        classical_security_bits=classical,
        quantum_security_bits=quantum,
        key_bits=min(key_bits, int(entropy))
    )


# ============================================================
# Algorithm 6: Norm Growth Analysis
# ============================================================

def analyze_norm_growth(path: List[int], max_steps: int = 20) -> Dict:
    """
    Analyze the norm growth along a specific Berggren path.
    
    Args:
        path: Repeating generator pattern (e.g., [0] for A^n)
        max_steps: Number of iterations
    
    Returns:
        Dictionary with norm growth data.
    """
    v = ROOT_TRIPLE.copy()
    data = {
        'hypotenuses': [int(v[2])],
        'squared_norms': [int(sum(x**2 for x in v))],
        'growth_ratios': [],
        'steps': [0]
    }
    
    for step in range(1, max_steps + 1):
        idx = path[(step - 1) % len(path)]
        v = BERGGREN_GENERATORS[idx] @ v
        hyp = int(v[2])
        sqn = int(sum(x**2 for x in v))
        
        data['hypotenuses'].append(hyp)
        data['squared_norms'].append(sqn)
        data['steps'].append(step)
        
        if data['hypotenuses'][-2] > 0:
            data['growth_ratios'].append(hyp / data['hypotenuses'][-2])
    
    return data


# ============================================================
# Algorithm 7: Lorentz Form Verification
# ============================================================

def verify_lorentz_preservation(M: np.ndarray) -> bool:
    """
    Verify that M preserves the Lorentz form: M^T Q M = Q
    where Q = diag(1, 1, -1).
    
    Args:
        M: 3×3 integer matrix
    
    Returns:
        True if M is in O(2,1; ℤ)
    """
    Q = np.diag([1, 1, -1]).astype(np.int64)
    result = M.T @ Q @ M
    return np.array_equal(result, Q)


# ============================================================
# Main: Run all algorithms
# ============================================================

if __name__ == "__main__":
    print("Berggren Post-Quantum Lattices: Algorithm Demonstrations")
    print("=" * 60)
    
    # Word evaluation
    print("\n--- Word Evaluation ---")
    for word in [[], [0], [1], [2], [0, 1], [0, 0, 0]]:
        v = evaluate_word(word)
        name = ''.join('ABC'[i] for i in word) or 'ε'
        print(f"  w={name:6s}  →  v = {tuple(int(x) for x in v):>20s}  "
              f"Pyth={int(v[0])**2 + int(v[1])**2 == int(v[2])**2}")
    
    # Orbit generation
    print("\n--- Orbit Generation (depth 2) ---")
    orbit = generate_orbit(2)
    for ov in orbit:
        name = ''.join('ABC'[i] for i in ov.word) or 'root'
        print(f"  {name:6s}  {tuple(int(x) for x in ov.vector):>20s}  "
              f"hyp={ov.hypotenuse:>4d}  prim={ov.is_primitive()}")
    
    # Lattice construction
    print("\n--- Lattice Basis (depth 1) ---")
    depth1 = [ov.vector for ov in orbit if ov.depth == 1]
    basis, det = orbit_lattice_basis(depth1)
    print(f"  Basis matrix:\n{basis}")
    print(f"  Determinant: {det}")
    print(f"  Index in ℤ³: {abs(det)}")
    
    # Security parameters
    print("\n--- Security Parameters ---")
    for m in [64, 128, 256, 512]:
        params = estimate_security(m)
        print(f"  {params}")
    
    # Lorentz verification
    print("\n--- Lorentz Form Preservation ---")
    for name, M in [('A', BERGGREN_A), ('B', BERGGREN_B), ('C', BERGGREN_C)]:
        print(f"  Generator {name}: M^T Q M = Q ? {verify_lorentz_preservation(M)}")
    
    # Norm growth
    print("\n--- Norm Growth (B-path) ---")
    data = analyze_norm_growth([1], 10)
    for i in range(len(data['hypotenuses'])):
        ratio = f"{data['growth_ratios'][i-1]:.4f}" if i > 0 else "  —   "
        print(f"  step {i:>2d}: hyp={data['hypotenuses'][i]:>12d}  ratio={ratio}")
