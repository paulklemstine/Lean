"""
Algorithms for computing torsion birth sets and stability distances.

Implements the torsion birth detection and Hausdorff distance computation
for filtered chain complexes over ℤ, as formalized in the Lean 4 proofs.
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import List, Set, Tuple, Optional, Dict
import numpy as np
from itertools import combinations


@dataclass
class ChainComplex:
    """A chain complex of free ℤ-modules represented by integer matrices.

    The complex is:  ... → C_{n+1} --d_{n+1}--> C_n --d_n--> C_{n-1} → ...

    Attributes:
        differentials: dict mapping degree n to the matrix of d_n : C_n → C_{n-1}
                      Each matrix has integer entries.
    """
    differentials: Dict[int, np.ndarray]

    def rank(self, n: int) -> int:
        """Rank of C_n."""
        if n in self.differentials:
            return self.differentials[n].shape[1]
        if n + 1 in self.differentials:
            return self.differentials[n + 1].shape[0]
        return 0


def smith_normal_form(M: np.ndarray) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    """Compute the Smith Normal Form of an integer matrix.

    Returns (D, U, V) where D = U @ M @ V, D is diagonal with
    d_1 | d_2 | ... | d_r, and U, V are unimodular.

    Uses a simplified algorithm sufficient for small matrices.
    """
    if M.size == 0:
        m, n = M.shape
        return M.copy(), np.eye(m, dtype=int), np.eye(n, dtype=int)

    M = M.copy().astype(np.int64)
    m, n = M.shape
    U = np.eye(m, dtype=np.int64)
    V = np.eye(n, dtype=np.int64)

    for k in range(min(m, n)):
        # Find pivot
        submat = M[k:, k:]
        nonzero = np.argwhere(submat != 0)
        if len(nonzero) == 0:
            break

        # Find minimum absolute value
        min_idx = min(nonzero, key=lambda idx: abs(submat[idx[0], idx[1]]))
        pi, pj = min_idx[0] + k, min_idx[1] + k

        # Swap rows and columns to bring pivot to (k, k)
        if pi != k:
            M[[k, pi]] = M[[pi, k]]
            U[[k, pi]] = U[[pi, k]]
        if pj != k:
            M[:, [k, pj]] = M[:, [pj, k]]
            V[:, [k, pj]] = V[:, [pj, k]]

        if M[k, k] < 0:
            M[k] = -M[k]
            U[k] = -U[k]

        # Eliminate column entries
        changed = True
        while changed:
            changed = False
            for i in range(k + 1, m):
                if M[i, k] != 0:
                    q = M[i, k] // M[k, k]
                    M[i] -= q * M[k]
                    U[i] -= q * U[k]
                    if M[i, k] != 0:
                        # GCD step
                        M[[k, i]] = M[[i, k]]
                        U[[k, i]] = U[[i, k]]
                        if M[k, k] < 0:
                            M[k] = -M[k]
                            U[k] = -U[k]
                        changed = True

            for j in range(k + 1, n):
                if M[k, j] != 0:
                    q = M[k, j] // M[k, k]
                    M[:, j] -= q * M[:, k]
                    V[:, j] -= q * V[:, k]
                    if M[k, j] != 0:
                        M[:, [k, j]] = M[:, [j, k]]
                        V[:, [k, j]] = V[:, [j, k]]
                        if M[k, k] < 0:
                            M[k] = -M[k]
                            U[k] = -U[k]
                        changed = True

    # Ensure divisibility chain
    for k in range(min(m, n) - 1):
        if M[k, k] != 0 and M[k + 1, k + 1] != 0:
            if M[k + 1, k + 1] % M[k, k] != 0:
                # Add row k+1 to row k, then re-eliminate
                M[k] += M[k + 1]
                U[k] += U[k + 1]
                # Re-do elimination for this position
                for j in range(k + 1, n):
                    if M[k, j] != 0:
                        q = M[k, j] // M[k, k]
                        M[:, j] -= q * M[:, k]
                        V[:, j] -= q * V[:, k]

    return M, U, V


def compute_homology_torsion(C: ChainComplex, n: int, p: int) -> bool:
    """Detect whether H_n(C) has p-torsion.

    Uses Smith Normal Form to compute the torsion part of H_n.
    Returns True if Tor_1^Z(Z/pZ, H_n) ≠ 0, i.e., if H_n has p-torsion.

    Args:
        C: A chain complex
        n: Homological degree
        p: Prime (or any nonzero integer) to test for torsion

    Returns:
        True if p-torsion is detected in H_n(C)
    """
    # H_n = ker(d_n) / im(d_{n+1})
    # Torsion of H_n is determined by the invariant factors of the
    # presentation matrix.

    if n not in C.differentials and (n + 1) not in C.differentials:
        return False

    # Get d_n and d_{n+1}
    d_n = C.differentials.get(n, np.zeros((0, C.rank(n)), dtype=int))
    d_np1 = C.differentials.get(n + 1, np.zeros((C.rank(n), 0), dtype=int))

    if d_np1.shape[1] == 0:
        # No d_{n+1}, so H_n = ker(d_n) which is free
        return False

    # Compute SNF of d_{n+1}
    D, _, _ = smith_normal_form(d_np1)

    # The invariant factors of H_n's torsion part are the diagonal
    # entries of the SNF of d_{n+1} that are > 1
    r = min(D.shape)
    for i in range(r):
        d = abs(D[i, i]) if i < D.shape[0] and i < D.shape[1] else 0
        if d > 1 and d % p == 0:
            return True

    return False


def compute_torsion_births(
    filtration: List[ChainComplex],
    n: int,
    p: int
) -> List[int]:
    """Compute the torsion birth set for a filtered chain complex.

    Scans through filtration levels and identifies the first index
    where p-torsion appears in H_n.

    Args:
        filtration: List of chain complexes at each filtration level
        n: Homological degree
        p: Prime to test

    Returns:
        List of birth indices (at most one, since the birth set is a subsingleton)
    """
    births = []
    for i, C in enumerate(filtration):
        detected = compute_homology_torsion(C, n, p)
        if detected:
            # Check if this is a birth (no earlier detection)
            is_birth = all(
                not compute_homology_torsion(filtration[j], n, p)
                for j in range(i)
            )
            if is_birth:
                births.append(i)
                break  # At most one birth
    return births


def nat_dist(a: int, b: int) -> int:
    """Natural number distance |a - b|."""
    return abs(a - b)


def hausdorff_distance(A: Set[int], B: Set[int]) -> Optional[int]:
    """Compute the Hausdorff distance between two finite subsets of ℕ.

    Returns None if either set is empty (convention: distance is undefined).

    Args:
        A, B: Finite subsets of natural numbers

    Returns:
        The Hausdorff distance max(max_{a∈A} min_{b∈B} |a-b|,
                                    max_{b∈B} min_{a∈A} |a-b|)
    """
    if not A or not B:
        return None

    d_AB = max(min(nat_dist(a, b) for b in B) for a in A)
    d_BA = max(min(nat_dist(a, b) for a in A) for b in B)
    return max(d_AB, d_BA)


def nat_set_delta_close(A: Set[int], B: Set[int], delta: int) -> bool:
    """Check if two sets are δ-close in the Hausdorff sense.

    Implements the NatSetDeltaClose predicate from the formalization.

    Args:
        A, B: Finite subsets of natural numbers
        delta: The closeness parameter

    Returns:
        True if every element of A is within δ of some element of B and vice versa
    """
    if not A and not B:
        return True
    if not A or not B:
        return True  # Vacuously true when one set is empty

    for a in A:
        if not any(nat_dist(a, b) <= delta for b in B):
            return False
    for b in B:
        if not any(nat_dist(a, b) <= delta for a in A):
            return False
    return True


# ============================================================
# Simplicial complex filtration builders
# ============================================================

def rp2_filtration(num_levels: int = 6) -> List[ChainComplex]:
    """Build a filtration of chain complexes approximating RP².

    RP² has H_0 = ℤ, H_1 = ℤ/2ℤ, H_2 = 0 over ℤ.
    We build a filtration where the ℤ/2ℤ torsion appears at a specific level.

    The minimal triangulation of RP² has 6 vertices, 15 edges, 10 triangles.
    We add simplices level by level.
    """
    # Minimal RP² triangulation vertices: 0,1,2,3,4,5
    # Faces: {0,1,2}, {0,1,3}, {0,2,4}, {0,3,5}, {0,4,5},
    #         {1,2,5}, {1,3,4}, {1,4,5}, {2,3,4}, {2,3,5}
    triangles = [
        (0, 1, 2), (0, 1, 3), (0, 2, 4), (0, 3, 5), (0, 4, 5),
        (1, 2, 5), (1, 3, 4), (1, 4, 5), (2, 3, 4), (2, 3, 5)
    ]

    edges = sorted(set(
        tuple(sorted([t[i], t[j]]))
        for t in triangles
        for i, j in combinations(range(3), 2)
    ))

    vertices = list(range(6))

    # Build filtration by adding simplices gradually
    filtration = []
    n_tri = len(triangles)
    step = max(1, n_tri // (num_levels - 1))

    for level in range(num_levels):
        n_added = min(n_tri, level * step + 1) if level > 0 else 0

        # All vertices and edges are present from the start (level 0)
        # Triangles are added gradually
        current_triangles = triangles[:n_added]

        # Build boundary matrices
        edge_to_idx = {e: i for i, e in enumerate(edges)}
        n_edges = len(edges)
        n_verts = len(vertices)

        # d_1: edges → vertices (boundary of edges)
        d1 = np.zeros((n_verts, n_edges), dtype=np.int64)
        for j, (v0, v1) in enumerate(edges):
            d1[v0, j] = -1
            d1[v1, j] = 1

        # d_2: triangles → edges (boundary of triangles)
        n_cur_tri = len(current_triangles)
        if n_cur_tri > 0:
            d2 = np.zeros((n_edges, n_cur_tri), dtype=np.int64)
            for j, (v0, v1, v2) in enumerate(current_triangles):
                e01 = edge_to_idx[(min(v0, v1), max(v0, v1))]
                e02 = edge_to_idx[(min(v0, v2), max(v0, v2))]
                e12 = edge_to_idx[(min(v1, v2), max(v1, v2))]
                # Signs from orientation
                d2[e01, j] = 1
                d2[e12, j] = 1
                d2[e02, j] = -1
            C = ChainComplex({1: d1, 2: d2})
        else:
            C = ChainComplex({1: d1})

        filtration.append(C)

    return filtration


def perturbed_filtration(
    base: List[ChainComplex],
    delta: int = 1
) -> List[ChainComplex]:
    """Create a δ-shifted perturbation of a filtration.

    Shifts all birth events by δ levels (adds δ empty complexes at the start
    or shifts simplices to later levels).

    Args:
        base: The original filtration
        delta: Shift amount

    Returns:
        A new filtration that is δ-interleaved with the original
    """
    # Prepend delta copies of the first complex
    if not base:
        return []

    padded = [base[0]] * delta + base
    return padded


def build_synthetic_filtration(
    torsion_birth: int,
    total_levels: int,
    p: int = 2
) -> List[ChainComplex]:
    """Build a synthetic filtration with controlled torsion birth.

    Creates a filtration where ℤ/pℤ torsion appears at a specified level.

    Args:
        torsion_birth: The level at which torsion should appear
        total_levels: Total number of filtration levels
        p: The torsion prime

    Returns:
        A filtration with p-torsion born at the specified level
    """
    filtration = []
    for i in range(total_levels):
        if i < torsion_birth:
            # Before birth: free module (no torsion)
            # d_2: ℤ → ℤ, multiplication by 1 (trivial image = whole kernel)
            d1 = np.array([[1, -1]], dtype=np.int64)  # edge between 2 vertices
            C = ChainComplex({1: d1})
        else:
            # After birth: module with p-torsion
            # d_2: ℤ → ℤ, multiplication by p
            d1 = np.array([[1, -1]], dtype=np.int64)
            d2 = np.array([[p]], dtype=np.int64)  # Creates ℤ/pℤ in H_1
            C = ChainComplex({1: d1, 2: d2})
        filtration.append(C)
    return filtration


if __name__ == "__main__":
    # Quick test
    print("=== Algorithm Tests ===")

    # Test SNF
    M = np.array([[2, 4], [6, 8]], dtype=np.int64)
    D, U, V = smith_normal_form(M)
    print(f"SNF of {M.tolist()}: diag = {[D[i,i] for i in range(min(D.shape))]}")

    # Test torsion detection
    filt = build_synthetic_filtration(torsion_birth=3, total_levels=6, p=2)
    births = compute_torsion_births(filt, n=1, p=2)
    print(f"Torsion births (expect [3]): {births}")

    # Test Hausdorff distance
    A = {3}
    B = {5}
    print(f"Hausdorff({A}, {B}) = {hausdorff_distance(A, B)}")
    print(f"δ-close with δ=2: {nat_set_delta_close(A, B, 2)}")
    print(f"δ-close with δ=1: {nat_set_delta_close(A, B, 1)}")
