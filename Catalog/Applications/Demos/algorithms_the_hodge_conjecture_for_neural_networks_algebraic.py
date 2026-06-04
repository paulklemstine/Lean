#!/usr/bin/env python3
"""
Neural Hodge Theory: Core Algorithms

Type-hinted implementations of the mathematical algorithms underlying
the Graded Sign Poset theory for neural network decision surfaces.
"""

from math import comb
from typing import List, Tuple, Dict, Set, Optional
from dataclasses import dataclass
from enum import IntEnum
from itertools import product


class Sign(IntEnum):
    """Three-valued sign: position relative to a hyperplane."""
    NEG = -1
    ZERO = 0
    POS = 1


SignVector = Tuple[Sign, ...]


@dataclass
class NetworkArchitecture:
    """ReLU network architecture specification."""
    input_dim: int
    hidden_widths: List[int]
    
    @property
    def depth(self) -> int:
        return len(self.hidden_widths)
    
    @property
    def total_neurons(self) -> int:
        return sum(self.hidden_widths)


# ============================================================
# Algorithm 1: Zaslavsky Bound Computation
# ============================================================

def zaslavsky_bound(num_hyperplanes: int, dimension: int) -> int:
    """
    Compute the Zaslavsky bound: maximum number of regions created by
    `num_hyperplanes` hyperplanes in general position in R^dimension.
    
    Formula: sum_{k=0}^{dimension} C(num_hyperplanes, k)
    
    Time complexity: O(dimension)
    Space complexity: O(1)
    """
    return sum(comb(num_hyperplanes, k) for k in range(dimension + 1))


def network_region_bound(arch: NetworkArchitecture) -> int:
    """
    Compute the product Zaslavsky bound for a multi-layer ReLU network.
    
    For a network with hidden widths w_1, ..., w_L and input dimension n,
    the bound is prod_i zaslavsky_bound(w_i, n).
    
    This bounds the maximum number of linear regions of the network.
    
    Time complexity: O(L * n) where L = depth, n = input_dim
    Space complexity: O(1)
    """
    bound = 1
    for w in arch.hidden_widths:
        bound *= zaslavsky_bound(w, arch.input_dim)
    return bound


# ============================================================
# Algorithm 2: Sign Vector Operations
# ============================================================

def sign_vector_rank(sv: SignVector) -> int:
    """Number of nonzero entries in a sign vector."""
    return sum(1 for s in sv if s != Sign.ZERO)


def sign_vector_support(sv: SignVector) -> Set[int]:
    """Indices where the sign vector is nonzero."""
    return {i for i, s in enumerate(sv) if s != Sign.ZERO}


def is_face_of(tau: SignVector, sigma: SignVector) -> bool:
    """
    Check if tau is a face of sigma in the sign vector poset.
    tau ≤ sigma iff for all i: tau[i] = 0 or tau[i] = sigma[i].
    
    Time complexity: O(m) where m = len(tau)
    """
    return all(t == Sign.ZERO or t == s for t, s in zip(tau, sigma))


def boundary_at(sigma: SignVector, index: int) -> SignVector:
    """
    Compute the codimension-1 face obtained by setting sigma[index] to zero.
    
    Time complexity: O(m)
    """
    return tuple(Sign.ZERO if i == index else s for i, s in enumerate(sigma))


def flip_sign_vector(sv: SignVector) -> SignVector:
    """Negate all entries of a sign vector."""
    flip_map = {Sign.POS: Sign.NEG, Sign.ZERO: Sign.ZERO, Sign.NEG: Sign.POS}
    return tuple(flip_map[s] for s in sv)


# ============================================================
# Algorithm 3: Face Enumeration
# ============================================================

def enumerate_faces(sigma: SignVector) -> List[SignVector]:
    """
    Enumerate all faces of a sign vector sigma.
    
    Each face is obtained by independently keeping or zeroing
    each nonzero entry. Returns 2^rank(sigma) faces.
    
    Time complexity: O(2^rank * m)
    Space complexity: O(2^rank * m)
    """
    support = sign_vector_support(sigma)
    m = len(sigma)
    faces: List[SignVector] = []
    
    support_list = sorted(support)
    r = len(support_list)
    
    for bits in product([False, True], repeat=r):
        face = list(sigma)
        for j, idx in enumerate(support_list):
            if not bits[j]:
                face[idx] = Sign.ZERO
        faces.append(tuple(Sign(s) for s in face))
    
    return faces


def count_faces_by_rank(sigma: SignVector) -> Dict[int, int]:
    """
    Count faces of sigma grouped by rank.
    
    For a sign vector of rank r, the number of faces of rank k is C(r, k).
    """
    r = sign_vector_rank(sigma)
    return {k: comb(r, k) for k in range(r + 1)}


# ============================================================
# Algorithm 4: Graded Sign Poset Construction
# ============================================================

@dataclass
class GradedSignPoset:
    """
    The Graded Sign Poset: face-closed set of realized sign vectors
    with the face partial order and rank grading.
    """
    num_hyperplanes: int
    realized: Set[SignVector]
    
    @property
    def card(self) -> int:
        return len(self.realized)
    
    @property
    def num_regions(self) -> int:
        return sum(1 for sv in self.realized if sign_vector_rank(sv) == self.num_hyperplanes)
    
    def f_vector(self) -> Dict[int, int]:
        """The f-vector: count of realized sign vectors by rank."""
        fvec: Dict[int, int] = {}
        for sv in self.realized:
            r = sign_vector_rank(sv)
            fvec[r] = fvec.get(r, 0) + 1
        return fvec
    
    def euler_characteristic(self) -> int:
        """Euler characteristic from the f-vector."""
        fvec = self.f_vector()
        return sum((-1)**k * count for k, count in fvec.items())
    
    def is_face_closed(self) -> bool:
        """Verify the face-closure property."""
        for sigma in self.realized:
            for tau in enumerate_faces(sigma):
                if tau not in self.realized:
                    return False
        return True


def complete_sign_poset(m: int) -> GradedSignPoset:
    """
    Construct the complete Graded Sign Poset with all 3^m sign vectors.
    This corresponds to a hyperplane arrangement where all sign patterns are realized.
    
    Time complexity: O(3^m * m)
    """
    realized: Set[SignVector] = set()
    for pattern in product([Sign.NEG, Sign.ZERO, Sign.POS], repeat=m):
        realized.add(pattern)
    return GradedSignPoset(m, realized)


# ============================================================
# Algorithm 5: Hodge Number Bound
# ============================================================

def hodge_number_bound(arch: NetworkArchitecture, p: int, q: int) -> int:
    """
    Compute the (p,q)-Hodge number bound for a network architecture.
    
    For a network with ≥ 2 hidden layers with first width w_1 and last width w_L:
    bound = C(w_1, p) * C(w_L, q) * prod_{middle layers} w_i
    
    This bounds the (p,q)-component of the Hodge-like decomposition
    of the decision surface's homology.
    """
    if arch.depth < 2:
        return 1
    
    w1 = arch.hidden_widths[0]
    wL = arch.hidden_widths[-1]
    middle_product = 1
    for w in arch.hidden_widths[1:-1]:
        middle_product *= w
    
    return comb(w1, p) * comb(wL, q) * middle_product


def total_hodge_bound(arch: NetworkArchitecture, max_degree: int) -> Dict[Tuple[int, int], int]:
    """
    Compute all Hodge number bounds up to a given degree.
    """
    bounds: Dict[Tuple[int, int], int] = {}
    for p in range(max_degree + 1):
        for q in range(max_degree + 1):
            bounds[(p, q)] = hodge_number_bound(arch, p, q)
    return bounds


# ============================================================
# Algorithm 6: Hamming Distance and Adjacency
# ============================================================

def hamming_distance(p: Tuple[bool, ...], q: Tuple[bool, ...]) -> int:
    """Hamming distance between two activation patterns."""
    return sum(1 for a, b in zip(p, q) if a != b)


def find_adjacent_patterns(patterns: List[Tuple[bool, ...]]) -> List[Tuple[int, int]]:
    """
    Find all pairs of adjacent activation patterns (Hamming distance 1).
    These correspond to boundaries between linear regions.
    
    Time complexity: O(|patterns|^2 * width)
    """
    edges = []
    for i in range(len(patterns)):
        for j in range(i + 1, len(patterns)):
            if hamming_distance(patterns[i], patterns[j]) == 1:
                edges.append((i, j))
    return edges


# ============================================================
# Main: Run all algorithms with example data
# ============================================================

if __name__ == "__main__":
    # Example architecture: 2→4→4→1
    arch = NetworkArchitecture(input_dim=2, hidden_widths=[4, 4])
    
    print("Network Architecture: 2→4→4→1")
    print(f"  Input dimension: {arch.input_dim}")
    print(f"  Depth: {arch.depth}")
    print(f"  Total neurons: {arch.total_neurons}")
    print(f"  Region bound: {network_region_bound(arch)}")
    print(f"  2^neurons bound: {2**arch.total_neurons}")
    
    print("\nHodge Number Bounds:")
    for p in range(3):
        for q in range(3):
            bound = hodge_number_bound(arch, p, q)
            print(f"  h^({p},{q}) ≤ {bound}")
    
    print("\nComplete Sign Poset (m=3):")
    gsp = complete_sign_poset(3)
    print(f"  Total sign vectors: {gsp.card}")
    print(f"  Regions (full vectors): {gsp.num_regions}")
    print(f"  f-vector: {gsp.f_vector()}")
    print(f"  Euler characteristic: {gsp.euler_characteristic()}")
    print(f"  Face-closed: {gsp.is_face_closed()}")
    
    # Verify Euler formula
    for m in range(1, 7):
        gsp = complete_sign_poset(m)
        chi = gsp.euler_characteristic()
        expected = (-1)**m
        status = "✓" if chi == expected else "✗"
        print(f"  m={m}: χ = {chi} = (-1)^{m} {status}")
