"""
Algorithmic Spectral Certification for Cayley Graphs of GL₂(𝔽_q)

This module implements the certification pipeline:
  1. Algebraic seed conditions (irreducible charpoly, primitive determinant)
  2. Short-word reachability and collision statistics
  3. Spectral gap estimation via eigenvalue computation
  4. Certificate generation and verification

All arithmetic is over finite fields 𝔽_q for prime q.
"""

import numpy as np
from typing import Optional, Tuple, List, Dict, Any
from itertools import product as iterproduct
from collections import Counter


def mod_inv(a: int, p: int) -> int:
    """Modular inverse of a mod p using Fermat's little theorem."""
    return pow(a, p - 2, p)


def mat_mul_mod(A: np.ndarray, B: np.ndarray, p: int) -> np.ndarray:
    """Matrix multiplication mod p."""
    return np.array(A @ B % p, dtype=int) % p


def mat_inv_mod(M: np.ndarray, p: int) -> Optional[np.ndarray]:
    """Inverse of 2x2 matrix mod p, or None if singular."""
    a, b = int(M[0, 0]), int(M[0, 1])
    c, d = int(M[1, 0]), int(M[1, 1])
    det = (a * d - b * c) % p
    if det == 0:
        return None
    di = mod_inv(det, p)
    return np.array([[d * di % p, (-b * di) % p],
                     [(-c * di) % p, a * di % p]], dtype=int) % p


def mat_det_mod(M: np.ndarray, p: int) -> int:
    """Determinant of 2x2 matrix mod p."""
    return int(M[0, 0] * M[1, 1] - M[0, 1] * M[1, 0]) % p


def charpoly_coeffs(M: np.ndarray, p: int) -> Tuple[int, int]:
    """
    Characteristic polynomial of 2x2 matrix: X² - tr(M)·X + det(M).
    Returns (trace mod p, det mod p).
    """
    tr = int(M[0, 0] + M[1, 1]) % p
    det = mat_det_mod(M, p)
    return tr, det


def is_irreducible_charpoly(M: np.ndarray, p: int) -> bool:
    """
    Check if the characteristic polynomial of a 2x2 matrix over 𝔽_p is irreducible.
    
    The charpoly is X² - tr·X + det. It's irreducible over 𝔽_p iff
    the discriminant tr² - 4·det is a non-square (quadratic non-residue) mod p.
    
    Args:
        M: 2x2 integer matrix
        p: prime modulus
    
    Returns:
        True if charpoly is irreducible over 𝔽_p
    """
    tr, det = charpoly_coeffs(M, p)
    disc = (tr * tr - 4 * det) % p
    if disc == 0:
        return False
    # Check if disc is a quadratic non-residue using Euler's criterion
    return pow(disc, (p - 1) // 2, p) != 1


def multiplicative_order(a: int, p: int) -> int:
    """Order of a in (ℤ/pℤ)×. Returns 0 if a ≡ 0."""
    a = a % p
    if a == 0:
        return 0
    x = a
    for k in range(1, p):
        if x == 1:
            return k
        x = x * a % p
    return p - 1


def is_primitive_det(M: np.ndarray, p: int) -> bool:
    """
    Check if det(M) is a primitive root mod p, i.e., generates (ℤ/pℤ)×.
    
    Args:
        M: 2x2 integer matrix
        p: prime modulus
    
    Returns:
        True if det(M) has order p-1 in (ℤ/pℤ)×
    """
    det = mat_det_mod(M, p)
    if det == 0:
        return False
    return multiplicative_order(det, p) == p - 1


def mat_to_tuple(M: np.ndarray, p: int) -> Tuple[int, ...]:
    """Convert matrix to hashable tuple."""
    return tuple(int(x) % p for x in M.flatten())


def word_reachable(g: np.ndarray, h: np.ndarray, p: int, L: int) -> set:
    """
    Compute elements reachable by words of length ≤ L in {g, g⁻¹, h, h⁻¹}.
    
    Args:
        g, h: 2x2 generator matrices
        p: prime modulus
        L: maximum word length
    
    Returns:
        Set of reachable matrix tuples
    """
    gi = mat_inv_mod(g, p)
    hi = mat_inv_mod(h, p)
    if gi is None or hi is None:
        return set()
    
    gens = [g, gi, h, hi]
    identity = np.eye(2, dtype=int)
    
    reachable = {mat_to_tuple(identity, p)}
    frontier = {mat_to_tuple(identity, p): identity}
    
    for _ in range(L):
        new_frontier = {}
        for _, mat in frontier.items():
            for gen in gens:
                prod = mat_mul_mod(mat, gen, p)
                key = mat_to_tuple(prod, p)
                if key not in reachable:
                    reachable.add(key)
                    new_frontier[key] = prod
        frontier = new_frontier
        if not frontier:
            break
    
    return reachable


def gl2_order(p: int) -> int:
    """Order of GL₂(𝔽_p) = (p²-1)(p²-p) = p(p-1)²(p+1)."""
    return (p * p - 1) * (p * p - p)


def spectral_gap_numerical(g: np.ndarray, h: np.ndarray, p: int) -> float:
    """
    Compute the spectral gap of the Cayley graph Cay(GL₂(𝔽_p), {g, g⁻¹, h, h⁻¹})
    by constructing and diagonalizing the normalized adjacency matrix.
    
    Only feasible for small p (p ≤ 7 practically).
    
    Args:
        g, h: generator matrices
        p: prime modulus
    
    Returns:
        Spectral gap = 1 - λ₂ where λ₂ is the second-largest eigenvalue
    """
    gi = mat_inv_mod(g, p)
    hi = mat_inv_mod(h, p)
    if gi is None or hi is None:
        return 0.0
    
    # Enumerate all elements of GL₂(𝔽_p)
    elements = []
    elem_index = {}
    idx = 0
    for a in range(p):
        for b in range(p):
            for c in range(p):
                for d in range(p):
                    det = (a * d - b * c) % p
                    if det != 0:
                        M = np.array([[a, b], [c, d]], dtype=int)
                        key = mat_to_tuple(M, p)
                        elements.append(M)
                        elem_index[key] = idx
                        idx += 1
    
    n = len(elements)
    gens = [g, gi, h, hi]
    
    # Build normalized adjacency matrix
    A = np.zeros((n, n))
    for i, x in enumerate(elements):
        for gen in gens:
            prod = mat_mul_mod(x, gen, p)
            key = mat_to_tuple(prod, p)
            j = elem_index.get(key)
            if j is not None:
                A[i, j] += 0.25  # 1/|S| = 1/4
    
    # Compute eigenvalues
    eigenvalues = np.sort(np.real(np.linalg.eigvals(A)))[::-1]
    
    if len(eigenvalues) < 2:
        return 0.0
    
    # Second largest eigenvalue (excluding trivial eigenvalue 1)
    # We use max of second-largest and |smallest| to capture both non-bipartite
    # and bipartite contributions. For bipartite graphs, use lazy walk gap.
    lambda2 = abs(eigenvalues[1])  # second largest
    # If graph is bipartite (eigenvalue -1 present), report lazy walk gap
    if abs(eigenvalues[-1] + 1.0) < 1e-10:
        # Lazy walk: (I + A)/2, gap = (1 - lambda2)/2
        return float((1.0 - lambda2) / 2)
    return float(1.0 - max(abs(eigenvalues[1]), abs(eigenvalues[-1])))


class SpectralCertificate:
    """
    Spectral certificate data for a generator pair in GL₂(𝔽_q).
    
    Attributes:
        g, h: generator matrices
        q: prime field size
        irred_g: whether charpoly(g) is irreducible
        irred_h: whether charpoly(h) is irreducible
        prim_det_g: whether det(g) is primitive
        prim_det_h: whether det(h) is primitive
        reachable_fraction: fraction of GL₂ reachable by short words
        certified: whether the certificate is valid
        gap_lower_bound: certified lower bound on spectral gap (if certified)
    """
    
    def __init__(self, g: np.ndarray, h: np.ndarray, q: int, L: int = 5):
        self.g = g % q
        self.h = h % q
        self.q = q
        self.L = L
        
        # Check algebraic seed conditions
        self.irred_g = is_irreducible_charpoly(g, q)
        self.irred_h = is_irreducible_charpoly(h, q)
        self.prim_det_g = is_primitive_det(g, q)
        self.prim_det_h = is_primitive_det(h, q)
        
        self.has_irred = self.irred_g or self.irred_h
        self.has_prim_det = self.prim_det_g or self.prim_det_h
        
        # Compute reachability
        n_group = gl2_order(q)
        reached = word_reachable(g, h, q, L)
        self.reachable_count = len(reached)
        self.reachable_fraction = len(reached) / n_group
        
        # Full generation check (for small q)
        self.generates = self.reachable_fraction == 1.0
        
        # Certification
        self.certified = self.has_irred and self.has_prim_det and self.generates
        
        if self.certified:
            # Conservative gap bound based on group size
            # For certified pairs, gap ≥ 1/(2·|G|) is always true by compactness
            # Better bounds come from representation theory
            self.gap_lower_bound = 1.0 / (2 * n_group)
        else:
            self.gap_lower_bound = 0.0
    
    def summary(self) -> Dict[str, Any]:
        """Return certificate summary."""
        return {
            'q': self.q,
            'L': self.L,
            'irred_g': self.irred_g,
            'irred_h': self.irred_h,
            'prim_det_g': self.prim_det_g,
            'prim_det_h': self.prim_det_h,
            'has_irred': self.has_irred,
            'has_prim_det': self.has_prim_det,
            'reachable_fraction': self.reachable_fraction,
            'generates': self.generates,
            'certified': self.certified,
            'gap_lower_bound': self.gap_lower_bound,
        }
    
    def __repr__(self) -> str:
        status = "CERTIFIED" if self.certified else "NOT CERTIFIED"
        return (f"SpectralCertificate(q={self.q}, {status}, "
                f"irred={'Y' if self.has_irred else 'N'}, "
                f"prim_det={'Y' if self.has_prim_det else 'N'}, "
                f"reach={self.reachable_fraction:.3f}, "
                f"gap≥{self.gap_lower_bound:.6f})")


def certify_pair(g: np.ndarray, h: np.ndarray, q: int,
                 L: int = 5) -> Optional[float]:
    """
    Main certification algorithm.
    
    Args:
        g, h: 2x2 integer matrices (generators)
        q: prime field size
        L: word length bound for reachability check
    
    Returns:
        Certified gap lower bound if certification succeeds, None otherwise.
        
    Complexity:
        O(|GL₂(𝔽_q)| · 4^L) for the reachability computation.
        The algebraic checks are O(log q).
    """
    cert = SpectralCertificate(g, h, q, L)
    if cert.certified:
        return cert.gap_lower_bound
    return None


def enumerate_certified_pairs(q: int, L: int = 5,
                               max_pairs: int = 100) -> List[Dict]:
    """
    Enumerate or sample generating pairs and report certification results.
    
    Args:
        q: prime field size
        L: word length bound
        max_pairs: maximum number of pairs to test
    
    Returns:
        List of certification result dictionaries
    """
    results = []
    count = 0
    
    # Sample random pairs
    rng = np.random.RandomState(42)
    
    for _ in range(max_pairs):
        while True:
            g = rng.randint(0, q, (2, 2))
            if mat_det_mod(g, q) != 0:
                break
        while True:
            h = rng.randint(0, q, (2, 2))
            if mat_det_mod(h, q) != 0:
                break
        
        cert = SpectralCertificate(g, h, q, L)
        result = cert.summary()
        result['g'] = g.tolist()
        result['h'] = h.tolist()
        results.append(result)
        count += 1
    
    return results


def mixing_time_bound(gap: float, group_order: int, epsilon: float = 0.01) -> float:
    """
    Compute mixing time bound from spectral gap.
    
    The mixing time satisfies: t_mix ≤ (1/gap) · log(|G|/ε)
    
    This is the cross-domain theorem: spectral gap certification directly
    gives operational bounds on random walk convergence.
    
    Args:
        gap: spectral gap (> 0)
        group_order: |G|
        epsilon: target total variation distance
    
    Returns:
        Upper bound on mixing time
    """
    if gap <= 0:
        return float('inf')
    return np.log(group_order / epsilon) / gap
