#!/usr/bin/env python3
"""
Algorithms for Berggren Voronoi–CVP Duality

Implements:
1. Berggren tree traversal with certified enumeration
2. Voronoi cell computation via defect minimization
3. Certified CVP decoder with margin certificates
4. Stability radius computation
5. Delaunay adjacency graph construction
"""

import numpy as np
from dataclasses import dataclass
from typing import List, Tuple, Optional, Set, Dict
from collections import defaultdict

# ──────────────────────────────────────────────────────────────
# Core Data Structures
# ──────────────────────────────────────────────────────────────

@dataclass
class PythagoreanTriple:
    """A primitive Pythagorean triple (a, b, c) with a² + b² = c²."""
    a: int
    b: int
    c: int
    
    @property
    def vec(self) -> np.ndarray:
        return np.array([self.a, self.b, self.c])
    
    @property
    def height(self) -> int:
        return self.c
    
    def is_valid(self) -> bool:
        return (self.a**2 + self.b**2 == self.c**2 and 
                self.a > 0 and self.b > 0 and self.c > 0 and
                np.gcd(self.a, self.b) == 1)
    
    def __hash__(self):
        return hash((self.a, self.b, self.c))
    
    def __eq__(self, other):
        return (self.a, self.b, self.c) == (other.a, other.b, other.c)
    
    def __repr__(self):
        return f"({self.a}, {self.b}, {self.c})"


@dataclass
class DecodingCertificate:
    """A certificate proving that a triple is the defect-minimizing decoder."""
    winner: PythagoreanTriple
    winner_defect: float
    margin: float
    runner_up: Optional[PythagoreanTriple]
    runner_up_defect: Optional[float]
    family_size: int
    stability_radius: Optional[float]
    all_inequalities: List[Tuple[PythagoreanTriple, float]]  # (triple, defect)
    
    @property
    def is_valid(self) -> bool:
        """Verify the certificate: winner has minimum defect."""
        return all(self.winner_defect <= d for _, d in self.all_inequalities)
    
    @property
    def is_unique(self) -> bool:
        """Check if the winner is unique (positive margin)."""
        return self.margin > 0


# ──────────────────────────────────────────────────────────────
# Algorithm 1: Berggren Tree Enumeration
# ──────────────────────────────────────────────────────────────

# Berggren matrices
_MAT_A = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]])
_MAT_B = np.array([[1,  2, 2], [2,  1, 2], [2,  2, 3]])
_MAT_C = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]])


def berggren_enumerate(H: int) -> List[PythagoreanTriple]:
    """
    Enumerate all primitive Pythagorean triples with hypotenuse ≤ H.
    
    Algorithm: BFS traversal of the Berggren ternary tree rooted at (3,4,5).
    Each node has three children obtained by applying matrices A, B, C.
    
    Complexity: O(|S_H|) time and space, where |S_H| ~ H/(2π) by density theory.
    
    Args:
        H: Height bound (maximum hypotenuse).
    
    Returns:
        Sorted list of all primitive Pythagorean triples with c ≤ H.
    
    >>> triples = berggren_enumerate(50)
    >>> len(triples)
    7
    >>> triples[0]
    (3, 4, 5)
    """
    root = np.array([3, 4, 5])
    result = []
    stack = [root]
    seen = set()
    
    while stack:
        v = stack.pop()
        key = (int(v[0]), int(v[1]), int(v[2]))
        if key in seen or v[2] > H:
            continue
        if all(x > 0 for x in v):
            seen.add(key)
            result.append(PythagoreanTriple(*key))
            for M in [_MAT_A, _MAT_B, _MAT_C]:
                child = M @ v
                if child[2] <= H and all(x > 0 for x in child):
                    stack.append(child)
    
    result.sort(key=lambda t: (t.c, t.a))
    return result


# ──────────────────────────────────────────────────────────────
# Algorithm 2: Quadratic Defect Computation
# ──────────────────────────────────────────────────────────────

def quadratic_defect(x: np.ndarray, t: PythagoreanTriple, lam: float = 0.0) -> float:
    """
    Compute the quadratic defect δ(x, t) = ‖x - v_t‖² + λ·ht(t).
    
    Args:
        x: Target vector in ℝ³.
        t: Pythagorean triple.
        lam: Height penalty parameter (default 0).
    
    Returns:
        The defect value.
    """
    diff = x - t.vec.astype(float)
    return float(np.sum(diff**2)) + lam * t.height


# ──────────────────────────────────────────────────────────────
# Algorithm 3: Certified CVP Decoder
# ──────────────────────────────────────────────────────────────

def certified_decode(
    x: np.ndarray,
    family: List[PythagoreanTriple],
    lam: float = 0.0,
    compute_stability: bool = True
) -> DecodingCertificate:
    """
    Certified closest-vector decoder via defect minimization.
    
    Algorithm:
    1. Compute defect for all family members.
    2. Find the minimizer (O(n) scan).
    3. Compute margin = second-best defect - best defect.
    4. Optionally compute stability radius.
    5. Return certificate with all inequality witnesses.
    
    Complexity: O(|family|) time.
    
    The certificate proves correctness: the returned triple t satisfies
    ∀ s ∈ family, defect(x, t) ≤ defect(x, s).
    
    Args:
        x: Target vector in ℝ³.
        family: List of primitive Pythagorean triples.
        lam: Height penalty parameter.
        compute_stability: Whether to compute stability radius.
    
    Returns:
        A DecodingCertificate proving the decoded triple is optimal.
    """
    if not family:
        raise ValueError("Family must be nonempty")
    
    # Compute all defects
    all_inequalities = [(t, quadratic_defect(x, t, lam)) for t in family]
    
    # Sort by defect
    sorted_pairs = sorted(all_inequalities, key=lambda p: p[1])
    
    winner, winner_defect = sorted_pairs[0]
    
    if len(sorted_pairs) > 1:
        runner_up, runner_up_defect = sorted_pairs[1]
        margin = runner_up_defect - winner_defect
    else:
        runner_up, runner_up_defect = None, None
        margin = float('inf')
    
    # Compute stability radius if requested
    stability_radius = None
    if compute_stability and margin > 0:
        # For defect(x,t) = ‖x-t‖², the Lipschitz constant of
        # defect(·,t) - defect(·,s) is bounded by 2·max_diameter
        max_dist = max(np.linalg.norm(x - t.vec.astype(float)) for t in family)
        L = 2 * max_dist  # Lipschitz constant for squared distance
        if L > 0:
            stability_radius = margin / (2 * L)
    
    return DecodingCertificate(
        winner=winner,
        winner_defect=winner_defect,
        margin=margin,
        runner_up=runner_up,
        runner_up_defect=runner_up_defect,
        family_size=len(family),
        stability_radius=stability_radius,
        all_inequalities=all_inequalities
    )


# ──────────────────────────────────────────────────────────────
# Algorithm 4: Delaunay Adjacency Graph
# ──────────────────────────────────────────────────────────────

def delaunay_adjacency_graph(
    family: List[PythagoreanTriple],
    n_samples: int = 1000,
    lam: float = 0.0
) -> Dict[Tuple[PythagoreanTriple, PythagoreanTriple], np.ndarray]:
    """
    Approximate the Delaunay adjacency graph by sampling.
    
    Two triples are adjacent if their Voronoi cells share a boundary,
    i.e., there exists a point co-minimizing both.
    
    Algorithm:
    1. For each pair of triples, check the midpoint.
    2. If both are co-minimizers at the midpoint (and all others are
       strictly worse), they are Delaunay-adjacent.
    
    Complexity: O(|family|² · |family|) worst case.
    
    Args:
        family: List of primitive Pythagorean triples.
        n_samples: Number of random samples for boundary detection.
        lam: Height penalty parameter.
    
    Returns:
        Dictionary mapping adjacent pairs to their shared boundary witness.
    """
    adjacencies = {}
    
    for i, t in enumerate(family):
        for j, s in enumerate(family):
            if j <= i:
                continue
            
            # Check midpoint between t and s
            mid = (t.vec.astype(float) + s.vec.astype(float)) / 2
            d_t = quadratic_defect(mid, t, lam)
            d_s = quadratic_defect(mid, s, lam)
            
            if abs(d_t - d_s) < 1e-10:  # Co-minimizing at midpoint
                # Verify no other triple beats them
                is_boundary = True
                for k, u in enumerate(family):
                    if k != i and k != j:
                        d_u = quadratic_defect(mid, u, lam)
                        if d_u < d_t - 1e-10:
                            is_boundary = False
                            break
                
                if is_boundary:
                    adjacencies[(t, s)] = mid
    
    return adjacencies


# ──────────────────────────────────────────────────────────────
# Algorithm 5: Lorentz Form Verification
# ──────────────────────────────────────────────────────────────

def verify_lorentz_preservation(family: List[PythagoreanTriple]) -> bool:
    """
    Verify that the Lorentz form c² - a² - b² = 0 for all triples.
    
    This is equivalent to the Pythagorean condition a² + b² = c²,
    and is preserved by all Berggren matrix multiplications.
    
    Args:
        family: List of triples to verify.
    
    Returns:
        True if all triples satisfy the Lorentz condition.
    """
    return all(t.c**2 - t.a**2 - t.b**2 == 0 for t in family)


def lorentz_product(u: np.ndarray, v: np.ndarray) -> int:
    """Compute ⟨u, v⟩_L = u₃v₃ - u₁v₁ - u₂v₂."""
    return int(u[2]*v[2] - u[0]*v[0] - u[1]*v[1])


# ──────────────────────────────────────────────────────────────
# Main demonstration
# ──────────────────────────────────────────────────────────────

if __name__ == "__main__":
    # Generate family
    H = 100
    family = berggren_enumerate(H)
    print(f"Generated {len(family)} primitive Pythagorean triples with c ≤ {H}")
    print(f"First 5: {family[:5]}")
    
    # Verify Lorentz preservation
    print(f"\nLorentz form verified: {verify_lorentz_preservation(family)}")
    
    # Certified decoding
    x = np.array([7.5, 24.3, 25.1])
    cert = certified_decode(x, family)
    print(f"\nDecoding x = {x}:")
    print(f"  Winner: {cert.winner}")
    print(f"  Defect: {cert.winner_defect:.4f}")
    print(f"  Margin: {cert.margin:.4f}")
    print(f"  Unique: {cert.is_unique}")
    print(f"  Valid certificate: {cert.is_valid}")
    print(f"  Stability radius: {cert.stability_radius:.6f}" if cert.stability_radius else "  No stability radius")
    
    # Delaunay adjacency
    small_family = berggren_enumerate(50)
    adj = delaunay_adjacency_graph(small_family)
    print(f"\nDelaunay graph for H=50: {len(adj)} edges among {len(small_family)} triples")
    for (t, s), mid in list(adj.items())[:5]:
        print(f"  {t} ↔ {s}")
