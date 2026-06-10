#!/usr/bin/env python3
"""
Algorithms for Berggren Spectral Gap Analysis

Implements the core computational methods for:
1. Isotropic cone enumeration over finite fields
2. Projective normalization  
3. Transition matrix construction
4. Spectral gap computation
5. Mixing time estimation
"""

import numpy as np
from itertools import product
from typing import List, Tuple, Dict, Optional

# ─── Berggren Matrices ───────────────────────────────────────────
B1 = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]], dtype=int)
B2 = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]], dtype=int)
B3 = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]], dtype=int)
B1_inv = np.array([[1, 2, -2], [-2, -1, 2], [-2, -2, 3]], dtype=int)
B2_inv = np.array([[1, 2, -2], [2, 1, -2], [-2, -2, 3]], dtype=int)
B3_inv = np.array([[-1, -2, 2], [2, 1, -2], [-2, -2, 3]], dtype=int)

INV_GENERATORS = [B1_inv, B2_inv, B3_inv]
FWD_GENERATORS = [B1, B2, B3]


def mod_inverse(a: int, p: int) -> int:
    """Compute multiplicative inverse of a mod p using Fermat's little theorem.
    
    Complexity: O(log p) via fast exponentiation.
    
    Args:
        a: Element to invert (must be nonzero mod p)
        p: Prime modulus
    Returns:
        a^{-1} mod p
    """
    return pow(int(a) % p, p - 2, p)


def normalize_projective(v: tuple, q: int) -> Optional[tuple]:
    """Compute canonical projective representative.
    
    Normalizes a nonzero vector in (Z/qZ)³ to its canonical form where
    the first nonzero coordinate equals 1.
    
    Complexity: O(1)
    
    Args:
        v: 3-tuple of integers mod q
        q: Prime modulus
    Returns:
        Canonical representative, or None if v is zero
    """
    for k in range(3):
        if v[k] % q != 0:
            inv = mod_inverse(v[k], q)
            return tuple((c * inv) % q for c in v)
    return None


def enumerate_projective_isotropic_cone(q: int) -> List[tuple]:
    """Enumerate the projectivized nonzero isotropic cone P(X_q).
    
    Finds all projective classes [v] in P²(F_q) with Q(v) = 0,
    where Q(x,y,z) = x² + y² - z².
    
    Complexity: O(q³) time, O(q) space
    
    Args:
        q: Odd prime modulus
    Returns:
        List of canonical projective representatives
    
    >>> len(enumerate_projective_isotropic_cone(5))
    6
    >>> len(enumerate_projective_isotropic_cone(7))
    8
    """
    seen = set()
    cone = []
    for a, b, c in product(range(q), repeat=3):
        if a == 0 and b == 0 and c == 0:
            continue
        if (a*a + b*b - c*c) % q != 0:
            continue
        rep = normalize_projective((a, b, c), q)
        if rep is not None and rep not in seen:
            seen.add(rep)
            cone.append(rep)
    return cone


def build_berggren_transition_matrix(q: int, 
                                      cone: List[tuple],
                                      use_inverse: bool = True) -> np.ndarray:
    """Build the Berggren averaging operator T_q as a matrix.
    
    Constructs the |P(X_q)| × |P(X_q)| transition matrix where
    T[i,j] = (1/3) * #{k : B_k^{-1}([v_j]) = [v_i]}
    
    Complexity: O(q) time (since |P(X_q)| = q+1)
    
    Args:
        q: Odd prime modulus
        cone: List of projective isotropic vectors
        use_inverse: If True, use inverse generators (standard definition)
    Returns:
        Transition matrix T of shape (|cone|, |cone|)
    """
    n = len(cone)
    cone_index = {v: i for i, v in enumerate(cone)}
    T = np.zeros((n, n))
    
    gens = INV_GENERATORS if use_inverse else FWD_GENERATORS
    
    for j, v in enumerate(cone):
        v_arr = np.array(v, dtype=int)
        for g in gens:
            w = tuple((g @ v_arr) % q)
            w_rep = normalize_projective(w, q)
            if w_rep in cone_index:
                T[cone_index[w_rep], j] += 1.0 / 3.0
    
    return T


def compute_spectral_data(T: np.ndarray) -> Dict:
    """Compute complete spectral decomposition of the transition matrix.
    
    Returns eigenvalues, spectral gap, and mixing time estimate.
    
    Args:
        T: Square transition matrix
    Returns:
        Dictionary with:
        - eigenvalues: sorted eigenvalues (by magnitude)
        - magnitudes: sorted eigenvalue magnitudes
        - spectral_gap: 1 - |λ₂|
        - mixing_time: estimated mixing time ⌈log(n)/(-log|λ₂|)⌉
    """
    eigenvalues = np.linalg.eigvals(T)
    mags = np.sort(np.abs(eigenvalues))[::-1]
    
    gap = 1.0 - mags[1] if len(mags) > 1 else 1.0
    
    n = len(T)
    if mags[1] > 0 and mags[1] < 1:
        mixing_time = int(np.ceil(np.log(n) / (-np.log(mags[1]))))
    else:
        mixing_time = float('inf')
    
    idx = np.argsort(-np.abs(eigenvalues))
    
    return {
        'eigenvalues': eigenvalues[idx],
        'magnitudes': mags,
        'spectral_gap': gap,
        'mixing_time': mixing_time,
        'dimension': n
    }


def berggren_spectral_gap(q: int) -> Dict:
    """One-shot computation of the Berggren spectral gap for prime q.
    
    This is the main entry point for spectral analysis.
    
    Args:
        q: Odd prime
    Returns:
        Complete spectral data dictionary
    
    >>> data = berggren_spectral_gap(7)
    >>> abs(data['magnitudes'][1] - 1/np.sqrt(3)) < 1e-10
    True
    """
    cone = enumerate_projective_isotropic_cone(q)
    T = build_berggren_transition_matrix(q, cone)
    return compute_spectral_data(T)


def mixing_simulation(q: int, steps: int = 50) -> List[float]:
    """Simulate mixing on the projective cone.
    
    Starting from a delta function, applies T_q repeatedly and
    tracks the ℓ² distance to the uniform distribution.
    
    Args:
        q: Odd prime
        steps: Number of iterations
    Returns:
        List of ℓ² distances at each step
    """
    cone = enumerate_projective_isotropic_cone(q)
    n = len(cone)
    T = build_berggren_transition_matrix(q, cone)
    
    f = np.zeros(n)
    f[0] = 1.0
    uniform = np.ones(n) / n
    
    distances = []
    for _ in range(steps):
        distances.append(float(np.linalg.norm(f - uniform)))
        f = T @ f
    
    return distances


def verify_form_preservation() -> bool:
    """Verify that all generators preserve Q = diag(1,1,-1).
    
    Returns True if B_i^T Q B_i = Q for all i.
    """
    Q = np.diag([1, 1, -1])
    for M in FWD_GENERATORS + INV_GENERATORS:
        if not np.allclose(M.T @ Q @ M, Q):
            return False
    return True


def pythagorean_tree(depth: int = 4) -> List[Tuple[int, int, int]]:
    """Generate Pythagorean triples via the Berggren tree.
    
    Args:
        depth: Tree depth to enumerate
    Returns:
        List of (a, b, c) Pythagorean triples
    """
    root = np.array([3, 4, 5])
    triples = [(3, 4, 5)]
    level = [root]
    
    for _ in range(depth):
        next_level = []
        for v in level:
            for M in FWD_GENERATORS:
                child = M @ v
                triples.append(tuple(int(x) for x in child))
                next_level.append(child)
        level = next_level
    
    return triples


if __name__ == "__main__":
    print("Berggren Spectral Gap — Algorithm Verification\n")
    
    # Verify form preservation
    print(f"Form preservation: {verify_form_preservation()}")
    
    # Test spectral gap for several primes
    print(f"\n{'q':>4} {'|P(X_q)|':>9} {'|λ₂|':>12} {'1/√3':>12} {'Match':>7} {'Mix time':>10}")
    ref = 1.0 / np.sqrt(3)
    for q in [3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]:
        data = berggren_spectral_gap(q)
        match = abs(data['magnitudes'][1] - ref) < 1e-8
        print(f"{q:4d} {data['dimension']:9d} {data['magnitudes'][1]:12.8f} {ref:12.8f} {'✓' if match else '✗':>7} {data['mixing_time']:10d}")
    
    # Generate some Pythagorean triples
    triples = pythagorean_tree(3)
    print(f"\nGenerated {len(triples)} Pythagorean triples (depth 3)")
    all_valid = all(a**2 + b**2 == c**2 for a, b, c in triples)
    print(f"All valid: {all_valid}")
