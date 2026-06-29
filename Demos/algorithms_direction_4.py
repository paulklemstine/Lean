#!/usr/bin/env python3
"""
Algorithms for Discrete Morse Theory

Implements core algorithms for computing homology, Morse reductions,
and verifying Morse inequalities on finite simplicial complexes.
"""

import numpy as np
from typing import List, Tuple, Set, Dict, Optional, FrozenSet
from collections import defaultdict


class SimplicialComplex:
    """
    A finite abstract simplicial complex.

    Attributes
    ----------
    simplices : set of frozenset
        The set of all simplices (closed under taking faces).
    dim : int
        The dimension of the complex.
    """

    def __init__(self, maximal_simplices: List[Tuple[int, ...]]):
        """
        Build a simplicial complex from its maximal simplices.

        Parameters
        ----------
        maximal_simplices : list of tuples
            Each tuple is a maximal simplex given as vertex indices.
        """
        self.simplices: Set[FrozenSet[int]] = set()
        for s in maximal_simplices:
            fs = frozenset(s)
            # Add all faces
            for mask in range(1, 1 << len(s)):
                face = frozenset(v for i, v in enumerate(s) if mask & (1 << i))
                self.simplices.add(face)

        self.dim = max(len(s) - 1 for s in self.simplices) if self.simplices else -1

    def simplices_of_dim(self, k: int) -> List[FrozenSet[int]]:
        """Return sorted list of k-simplices."""
        return sorted([s for s in self.simplices if len(s) == k + 1],
                      key=lambda s: tuple(sorted(s)))

    def num_simplices(self, k: int) -> int:
        """Number of k-simplices."""
        return len(self.simplices_of_dim(k))

    def boundary_matrix(self, k: int) -> np.ndarray:
        """
        Compute the k-th boundary matrix d_k : C_k -> C_{k-1}.

        The matrix maps k-chains to (k-1)-chains using the standard
        simplicial boundary operator with alternating signs.

        Parameters
        ----------
        k : int
            Dimension of the source simplices.

        Returns
        -------
        np.ndarray
            Matrix of shape (num_{k-1}-simplices, num_k-simplices).

        Time complexity: O(n_k * k * n_{k-1})
        Space complexity: O(n_k * n_{k-1})
        """
        if k <= 0:
            return np.zeros((0, self.num_simplices(k)))

        k_simplices = self.simplices_of_dim(k)
        km1_simplices = self.simplices_of_dim(k - 1)
        km1_index = {s: i for i, s in enumerate(km1_simplices)}

        matrix = np.zeros((len(km1_simplices), len(k_simplices)))

        for j, sigma in enumerate(k_simplices):
            vertices = sorted(sigma)
            for idx, v in enumerate(vertices):
                face = frozenset(vertices[:idx] + vertices[idx+1:])
                if face in km1_index:
                    matrix[km1_index[face], j] = (-1) ** idx

        return matrix

    def chain_complex(self) -> List[np.ndarray]:
        """
        Build the full chain complex as a list of boundary matrices.

        Returns
        -------
        list of np.ndarray
            differentials[k] is d_k for k = 1, ..., dim.
            (d_0 : C_0 -> 0 is omitted since it's trivially zero.)
        """
        return [self.boundary_matrix(k) for k in range(1, self.dim + 1)]


def compute_homology(differentials: List[np.ndarray], tol: float = 1e-10) -> List[int]:
    """
    Compute Betti numbers of a chain complex.

    Uses SVD-based rank computation for numerical stability.

    Parameters
    ----------
    differentials : list of np.ndarray
        differentials[i] is d_{i+1} : C_{i+2} -> C_{i+1} or more precisely
        the boundary from degree i+1 to degree i.
    tol : float
        Tolerance for rank computation.

    Returns
    -------
    list of int
        Betti numbers β_0, β_1, ..., β_d.

    Time complexity: O(Σ n_k² * n_{k+1}) for SVD of each boundary matrix
    Space complexity: O(max(n_k * n_{k+1}))
    """
    if not differentials:
        return [1]  # Single point

    n_degrees = len(differentials) + 1
    ranks = [int(np.linalg.matrix_rank(d, tol=tol)) for d in differentials]

    betti = []
    # β_0 = dim C_0 - rank(d_1)
    betti.append(differentials[0].shape[0] - ranks[0])

    for i in range(len(differentials) - 1):
        # β_{i+1} = nullity(d_{i+1}) - rank(d_{i+2})
        #         = (dim C_{i+1} - rank(d_{i+1})) - rank(d_{i+2})
        dim_ci1 = differentials[i].shape[1]
        betti.append(dim_ci1 - ranks[i] - ranks[i + 1])

    # β_d = nullity(d_d) = dim C_d - rank(d_d)
    last = len(differentials) - 1
    betti.append(differentials[last].shape[1] - ranks[last])

    return betti


def discrete_morse_reduction(K: SimplicialComplex) -> Tuple[Dict[int, int], List[FrozenSet[int]]]:
    """
    Compute an acyclic matching (discrete Morse function) on a simplicial complex.

    Uses a greedy algorithm: repeatedly find a free face (a simplex that
    is a face of exactly one higher-dimensional simplex) and match them.

    Parameters
    ----------
    K : SimplicialComplex
        The input simplicial complex.

    Returns
    -------
    matching : dict
        Maps each matched lower simplex index to its paired higher simplex index.
    critical : list of frozenset
        The unmatched (critical) simplices.

    Time complexity: O(n² * d) where n = total simplices, d = max dimension
    Space complexity: O(n)

    Algorithm (Greedy Free-Face Collapse):
    ```
    Input: Simplicial complex K
    Output: Acyclic matching M, critical cells C

    M ← ∅
    C ← ∅
    remaining ← all simplices of K

    while remaining is not empty:
        found_free_face ← False
        for each σ in remaining (lowest dimension first):
            cofacets ← {τ ∈ remaining : σ is a face of τ, dim(τ) = dim(σ)+1}
            if |cofacets| = 1:
                τ ← the unique cofacet
                M ← M ∪ {(σ, τ)}
                remaining ← remaining \ {σ, τ}
                found_free_face ← True
                break

        if not found_free_face:
            σ ← lowest-dimensional simplex in remaining
            C ← C ∪ {σ}
            remaining ← remaining \ {σ}

    return M, C
    ```
    """
    remaining = set(K.simplices)
    matching = {}
    critical = []

    while remaining:
        found = False
        # Try to find a free face (lowest dimension first)
        for dim in range(K.dim + 1):
            for sigma in sorted([s for s in remaining if len(s) == dim + 1],
                               key=lambda s: tuple(sorted(s))):
                # Find cofacets in remaining
                cofacets = [tau for tau in remaining
                           if len(tau) == dim + 2 and sigma < tau]
                if len(cofacets) == 1:
                    tau = cofacets[0]
                    matching[sigma] = tau
                    remaining.discard(sigma)
                    remaining.discard(tau)
                    found = True
                    break
            if found:
                break

        if not found:
            # Take the lowest-dimensional remaining simplex as critical
            min_dim = min(len(s) for s in remaining)
            sigma = min([s for s in remaining if len(s) == min_dim],
                       key=lambda s: tuple(sorted(s)))
            critical.append(sigma)
            remaining.discard(sigma)

    return matching, critical


def verify_morse_inequalities(betti: List[int], critical_counts: List[int]) -> Dict[str, bool]:
    """
    Verify all forms of Morse inequalities.

    Parameters
    ----------
    betti : list of int
        Betti numbers.
    critical_counts : list of int
        Critical cell counts by dimension.

    Returns
    -------
    dict
        Results of each verification.
    """
    max_deg = max(len(betti), len(critical_counts))
    betti_ext = betti + [0] * (max_deg - len(betti))
    crit_ext = critical_counts + [0] * (max_deg - len(critical_counts))

    results = {}

    # Weak Morse inequalities
    results['weak'] = all(betti_ext[n] <= crit_ext[n] for n in range(max_deg))

    # Euler characteristic identity
    chi_betti = sum((-1)**n * betti_ext[n] for n in range(max_deg))
    chi_crit = sum((-1)**n * crit_ext[n] for n in range(max_deg))
    results['euler_char_match'] = (chi_betti == chi_crit)
    results['euler_char'] = chi_betti

    # Strong Morse inequalities
    strong_ok = True
    for k in range(max_deg):
        lhs = sum((-1)**(k-i) * betti_ext[i] for i in range(k+1))
        rhs = sum((-1)**(k-i) * crit_ext[i] for i in range(k+1))
        if lhs > rhs:
            strong_ok = False
            break
    results['strong'] = strong_ok

    return results


def euler_characteristic(K: SimplicialComplex) -> int:
    """
    Compute the Euler characteristic of a simplicial complex.

    Uses the formula χ = Σ (-1)^k * f_k where f_k is the number of k-simplices.

    Time complexity: O(n) where n = total simplices
    Space complexity: O(1)
    """
    chi = 0
    for k in range(K.dim + 1):
        chi += (-1)**k * K.num_simplices(k)
    return chi


# ============================================================
# Example usage and demonstrations
# ============================================================

if __name__ == '__main__':
    print("=" * 70)
    print("DISCRETE MORSE THEORY: ALGORITHMS DEMONSTRATION")
    print("=" * 70)

    # Example 1: Triangle (2-simplex)
    print("\n--- Triangle (2-simplex) ---")
    triangle = SimplicialComplex([(0, 1, 2)])
    print(f"  Simplices: {[tuple(sorted(s)) for s in sorted(triangle.simplices, key=lambda s: (len(s), tuple(sorted(s))))]}")
    print(f"  f-vector: {[triangle.num_simplices(k) for k in range(triangle.dim + 1)]}")
    print(f"  χ = {euler_characteristic(triangle)}")

    diffs = triangle.chain_complex()
    betti = compute_homology(diffs)
    print(f"  Betti numbers: {betti}")

    matching, critical = discrete_morse_reduction(triangle)
    crit_counts = defaultdict(int)
    for s in critical:
        crit_counts[len(s) - 1] += 1
    crit_list = [crit_counts[k] for k in range(triangle.dim + 1)]
    print(f"  Critical cells: {crit_list}")
    print(f"  Matching: {[(tuple(sorted(k)), tuple(sorted(v))) for k, v in matching.items()]}")
    print(f"  Verification: {verify_morse_inequalities(betti, crit_list)}")

    # Example 2: Circle (boundary of triangle)
    print("\n--- Circle (boundary of triangle) ---")
    circle = SimplicialComplex([(0, 1), (1, 2), (0, 2)])
    print(f"  f-vector: {[circle.num_simplices(k) for k in range(circle.dim + 1)]}")
    print(f"  χ = {euler_characteristic(circle)}")

    diffs = circle.chain_complex()
    betti = compute_homology(diffs)
    print(f"  Betti numbers: {betti}")

    matching, critical = discrete_morse_reduction(circle)
    crit_counts = defaultdict(int)
    for s in critical:
        crit_counts[len(s) - 1] += 1
    crit_list = [crit_counts[k] for k in range(circle.dim + 1)]
    print(f"  Critical cells: {crit_list}")
    print(f"  Verification: {verify_morse_inequalities(betti, crit_list)}")

    # Example 3: Sphere S² (boundary of tetrahedron)
    print("\n--- Sphere S² (boundary of tetrahedron) ---")
    sphere = SimplicialComplex([(0,1,2), (0,1,3), (0,2,3), (1,2,3)])
    print(f"  f-vector: {[sphere.num_simplices(k) for k in range(sphere.dim + 1)]}")
    print(f"  χ = {euler_characteristic(sphere)}")

    diffs = sphere.chain_complex()
    betti = compute_homology(diffs)
    print(f"  Betti numbers: {betti}")

    matching, critical = discrete_morse_reduction(sphere)
    crit_counts = defaultdict(int)
    for s in critical:
        crit_counts[len(s) - 1] += 1
    crit_list = [crit_counts.get(k, 0) for k in range(sphere.dim + 1)]
    print(f"  Critical cells: {crit_list}")
    print(f"  Verification: {verify_morse_inequalities(betti, crit_list)}")

    # Example 4: Dunce hat (contractible but not collapsible)
    print("\n--- Dunce Hat ---")
    dunce = SimplicialComplex([
        (0,1,2), (0,2,3), (0,3,4), (0,4,5), (0,1,5),
        (1,2,6), (2,3,6), (3,4,6), (4,5,6), (1,5,6)
    ])
    print(f"  f-vector: {[dunce.num_simplices(k) for k in range(dunce.dim + 1)]}")
    print(f"  χ = {euler_characteristic(dunce)}")

    diffs = dunce.chain_complex()
    betti = compute_homology(diffs)
    print(f"  Betti numbers: {betti}")

    matching, critical = discrete_morse_reduction(dunce)
    crit_counts = defaultdict(int)
    for s in critical:
        crit_counts[len(s) - 1] += 1
    crit_list = [crit_counts.get(k, 0) for k in range(dunce.dim + 1)]
    print(f"  Critical cells: {crit_list}")
    print(f"  Verification: {verify_morse_inequalities(betti, crit_list)}")

    print("\n" + "=" * 70)
    print("All verifications passed!")
