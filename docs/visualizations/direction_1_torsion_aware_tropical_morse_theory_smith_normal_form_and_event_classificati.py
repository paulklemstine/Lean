"""
Algorithms for Torsion-Aware Tropical Morse Theory.

Implements Smith normal form computation, torsion spectrum extraction,
and simplex insertion event classification over ℤ.
"""

import numpy as np
from typing import List, Tuple, Optional
from dataclasses import dataclass
from enum import Enum, auto
import copy


class SimplexInsertionEvent(Enum):
    """The three possible events when a simplex is inserted over ℤ."""
    BIRTH_FREE = auto()      # ∂σ ∈ B: new cycle in H_d
    KILL_FREE = auto()       # ∂σ primitive mod B: kills free class in H_{d-1}
    CHANGE_TORSION = auto()  # ∂σ in Sat(B) \ B: torsion change in H_{d-1}


@dataclass
class TorsionSpectrum:
    """The torsion spectrum: invariant factors > 1, sorted by divisibility."""
    factors: List[int]

    @property
    def mass(self) -> int:
        """Product of all invariant factors (= |Tor(H)|)."""
        result = 1
        for f in self.factors:
            result *= f
        return result

    @property
    def is_valid(self) -> bool:
        """Check all factors > 1 and divisibility chain."""
        if not all(f > 1 for f in self.factors):
            return False
        for i in range(len(self.factors) - 1):
            if self.factors[i + 1] % self.factors[i] != 0:
                return False
        return True

    def __eq__(self, other):
        if not isinstance(other, TorsionSpectrum):
            return False
        return self.factors == other.factors

    def __repr__(self):
        if not self.factors:
            return "TorsionSpectrum(trivial)"
        parts = [f"ℤ/{f}" for f in self.factors]
        return f"TorsionSpectrum({' ⊕ '.join(parts)})"


@dataclass
class RankChangeData:
    """Records rank changes from a simplex insertion."""
    delta_rank_d: int
    delta_rank_dm1: int
    torsion_changed: bool
    event: SimplexInsertionEvent


def smith_normal_form(M: np.ndarray) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    """
    Compute Smith normal form of an integer matrix M.

    Returns (S, U, V) where S = U @ M @ V is in Smith normal form,
    U and V are unimodular (det ±1), and S is diagonal with d_i | d_{i+1}.

    Time complexity: O(n^3 * log(max_entry)) for an n×n matrix.
    Space complexity: O(n^2).
    """
    M = np.array(M, dtype=np.int64)
    m, n = M.shape
    S = M.copy()
    U = np.eye(m, dtype=np.int64)
    V = np.eye(n, dtype=np.int64)

    for k in range(min(m, n)):
        # Find pivot
        if not _find_and_move_pivot(S, U, V, k, m, n):
            break  # All remaining entries are zero

        # Eliminate entries in row k and column k
        changed = True
        while changed:
            changed = False
            changed |= _eliminate_column(S, U, k, m)
            changed |= _eliminate_row(S, V, k, n)

        # Ensure positive diagonal
        if S[k, k] < 0:
            S[k, :] *= -1
            U[k, :] *= -1

    # Ensure divisibility chain
    _enforce_divisibility(S, U, V, min(m, n))

    return S, U, V


def _find_and_move_pivot(S, U, V, k, m, n) -> bool:
    """Find smallest nonzero entry in submatrix S[k:, k:] and move to (k,k)."""
    min_val = None
    min_pos = None
    for i in range(k, m):
        for j in range(k, n):
            if S[i, j] != 0:
                if min_val is None or abs(S[i, j]) < abs(min_val):
                    min_val = S[i, j]
                    min_pos = (i, j)
    if min_pos is None:
        return False
    i, j = min_pos
    if i != k:
        S[[k, i]] = S[[i, k]]
        U[[k, i]] = U[[i, k]]
    if j != k:
        S[:, [k, j]] = S[:, [j, k]]
        V[:, [k, j]] = V[:, [j, k]]
    return True


def _eliminate_column(S, U, k, m) -> bool:
    """Eliminate entries below S[k,k] using row operations."""
    changed = False
    for i in range(k + 1, m):
        if S[i, k] != 0:
            if S[i, k] % S[k, k] == 0:
                q = S[i, k] // S[k, k]
                S[i, :] -= q * S[k, :]
                U[i, :] -= q * U[k, :]
            else:
                # Use extended GCD
                g, x, y = _extended_gcd(S[k, k], S[i, k])
                a, b = S[k, k] // g, S[i, k] // g
                row_k = S[k, :].copy()
                row_i = S[i, :].copy()
                S[k, :] = x * row_k + y * row_i
                S[i, :] = -b * row_k + a * row_i
                u_k = U[k, :].copy()
                u_i = U[i, :].copy()
                U[k, :] = x * u_k + y * u_i
                U[i, :] = -b * u_k + a * u_i
            changed = True
    return changed


def _eliminate_row(S, V, k, n) -> bool:
    """Eliminate entries to the right of S[k,k] using column operations."""
    changed = False
    for j in range(k + 1, n):
        if S[k, j] != 0:
            if S[k, j] % S[k, k] == 0:
                q = S[k, j] // S[k, k]
                S[:, j] -= q * S[:, k]
                V[:, j] -= q * V[:, k]
            else:
                g, x, y = _extended_gcd(S[k, k], S[k, j])
                a, b = S[k, k] // g, S[k, j] // g
                col_k = S[:, k].copy()
                col_j = S[:, j].copy()
                S[:, k] = x * col_k + y * col_j
                S[:, j] = -b * col_k + a * col_j
                v_k = V[:, k].copy()
                v_j = V[:, j].copy()
                V[:, k] = x * v_k + y * v_j
                V[:, j] = -b * v_k + a * v_j
            changed = True
    return changed


def _enforce_divisibility(S, U, V, r):
    """Ensure d_i | d_{i+1} on the diagonal."""
    for _ in range(r):
        for k in range(r - 1):
            if S[k, k] == 0 or S[k + 1, k + 1] == 0:
                continue
            if S[k + 1, k + 1] % S[k, k] != 0:
                # Add row k+1 to row k, then re-eliminate
                S[k, :] += S[k + 1, :]
                U[k, :] += U[k + 1, :]
                changed = True
                while changed:
                    changed = False
                    m = S.shape[0]
                    n = S.shape[1]
                    changed |= _eliminate_column(S, U, k, m)
                    changed |= _eliminate_row(S, V, k, n)
                if S[k, k] < 0:
                    S[k, :] *= -1
                    U[k, :] *= -1


def _extended_gcd(a: int, b: int) -> Tuple[int, int, int]:
    """Extended GCD: returns (g, x, y) such that a*x + b*y = g = gcd(a,b)."""
    if b == 0:
        return a, 1, 0
    g, x1, y1 = _extended_gcd(b, a % b)
    return g, y1, x1 - (a // b) * y1


def extract_torsion_spectrum(M: np.ndarray) -> TorsionSpectrum:
    """
    Extract the torsion spectrum from a boundary matrix.

    The torsion of H = ker/im is determined by the invariant factors
    of the boundary matrix (via Smith normal form).

    Args:
        M: Integer matrix (boundary map ∂_d)

    Returns:
        TorsionSpectrum with factors > 1 from the SNF diagonal.
    """
    S, _, _ = smith_normal_form(M)
    diag = [int(S[i, i]) for i in range(min(S.shape))]
    factors = sorted([abs(d) for d in diag if abs(d) > 1])
    return TorsionSpectrum(factors)


def classify_insertion_event(
    boundary_matrix: np.ndarray,
    new_boundary_vector: np.ndarray
) -> Tuple[SimplexInsertionEvent, RankChangeData]:
    """
    Classify a simplex insertion event over ℤ.

    Given the current boundary matrix M (whose columns span B_{d-1})
    and the boundary vector ∂σ of the new simplex, determine which
    of the three event types occurs.

    Args:
        boundary_matrix: m × n matrix (current ∂_d)
        new_boundary_vector: m-vector (∂σ of new simplex)

    Returns:
        Tuple of (event_type, rank_change_data)

    Time complexity: O(m^2 * n * log(max_entry)) for SNF computation.
    """
    M = np.array(boundary_matrix, dtype=np.int64)
    v = np.array(new_boundary_vector, dtype=np.int64).reshape(-1)
    m = M.shape[0]

    # Compute old and new torsion spectra
    old_spectrum = extract_torsion_spectrum(M)

    # Build new matrix with v appended as a column
    if M.shape[1] == 0:
        M_new = v.reshape(-1, 1)
    else:
        M_new = np.column_stack([M, v])

    new_spectrum = extract_torsion_spectrum(M_new)

    # Compute ranks (via SNF)
    S_old, _, _ = smith_normal_form(M) if M.shape[1] > 0 else (np.zeros((m, 0), dtype=np.int64), None, None)
    S_new, _, _ = smith_normal_form(M_new)

    old_rank = sum(1 for i in range(min(S_old.shape)) if S_old[i, i] != 0) if M.shape[1] > 0 else 0
    new_rank = sum(1 for i in range(min(S_new.shape)) if S_new[i, i] != 0)

    rank_increased = new_rank > old_rank

    if not rank_increased:
        # ∂σ ∈ B (redundant): free birth
        # But check torsion too
        if old_spectrum == new_spectrum:
            event = SimplexInsertionEvent.BIRTH_FREE
            return event, RankChangeData(1, 0, False, event)
        else:
            event = SimplexInsertionEvent.CHANGE_TORSION
            return event, RankChangeData(1, 0, True, event)
    else:
        # Rank increased: ∂σ adds to the image
        if old_spectrum == new_spectrum:
            event = SimplexInsertionEvent.KILL_FREE
            return event, RankChangeData(0, -1, False, event)
        else:
            # This shouldn't happen in the standard model but handle gracefully
            event = SimplexInsertionEvent.KILL_FREE
            return event, RankChangeData(0, -1, True, event)


def compute_homology_Z(boundary_d: np.ndarray, boundary_dp1: np.ndarray) -> Tuple[int, TorsionSpectrum]:
    """
    Compute H_d(K; ℤ) from boundary maps ∂_d and ∂_{d+1}.

    H_d = ker(∂_d) / im(∂_{d+1})

    Returns (free_rank, torsion_spectrum).
    """
    m_d = boundary_d.shape[0] if len(boundary_d.shape) > 1 else 0

    # Rank of ∂_d = rank of image
    if boundary_d.size == 0 or (len(boundary_d.shape) > 1 and boundary_d.shape[1] == 0):
        rank_d = 0
        nullity_d = boundary_d.shape[1] if len(boundary_d.shape) > 1 else 0
    else:
        S_d, _, _ = smith_normal_form(boundary_d)
        rank_d = sum(1 for i in range(min(S_d.shape)) if S_d[i, i] != 0)
        nullity_d = boundary_d.shape[1] - rank_d

    # Torsion from ∂_{d+1} restricted to cycles
    if boundary_dp1.size == 0 or (len(boundary_dp1.shape) > 1 and boundary_dp1.shape[1] == 0):
        rank_dp1 = 0
        torsion = TorsionSpectrum([])
    else:
        torsion = extract_torsion_spectrum(boundary_dp1)
        S_dp1, _, _ = smith_normal_form(boundary_dp1)
        rank_dp1 = sum(1 for i in range(min(S_dp1.shape)) if S_dp1[i, i] != 0)

    free_rank = nullity_d - rank_dp1 + len(torsion.factors)

    return max(0, free_rank), torsion


# ============================================================
# Simplicial Complex Data Structure
# ============================================================

class SimplicialComplex:
    """
    A finite simplicial complex with integer chain complex computations.

    Vertices are labeled 0, 1, ..., n-1.
    Simplices are stored as frozensets.
    """

    def __init__(self, vertices: int):
        self.num_vertices = vertices
        self.simplices: dict[int, set] = {0: {frozenset({v}) for v in range(vertices)}}

    def add_simplex(self, simplex: frozenset) -> SimplexInsertionEvent:
        """Add a simplex and return the insertion event type."""
        d = len(simplex) - 1
        if d not in self.simplices:
            self.simplices[d] = set()

        # Check all faces present
        for v in simplex:
            face = simplex - {v}
            if d - 1 >= 0:
                if d - 1 not in self.simplices or face not in self.simplices[d - 1]:
                    raise ValueError(f"Face {face} not present in complex")

        # Get old boundary matrix
        old_bd = self.boundary_matrix(d)

        # Add the simplex
        self.simplices[d].add(simplex)

        # Get new boundary matrix
        new_bd = self.boundary_matrix(d)

        # Classify event
        new_col = new_bd[:, -1] if new_bd.shape[1] > 0 else np.zeros(new_bd.shape[0], dtype=np.int64)
        event, _ = classify_insertion_event(old_bd, new_col)
        return event

    def boundary_matrix(self, d: int) -> np.ndarray:
        """Compute the boundary matrix ∂_d: C_d → C_{d-1}."""
        if d <= 0 or d not in self.simplices:
            if d - 1 in self.simplices:
                return np.zeros((len(self.simplices[d - 1]), 0), dtype=np.int64)
            return np.zeros((0, 0), dtype=np.int64)

        d_simplices = sorted(self.simplices[d], key=lambda s: tuple(sorted(s)))
        dm1_simplices = sorted(self.simplices.get(d - 1, set()), key=lambda s: tuple(sorted(s)))

        if not dm1_simplices or not d_simplices:
            return np.zeros((len(dm1_simplices), len(d_simplices)), dtype=np.int64)

        dm1_index = {s: i for i, s in enumerate(dm1_simplices)}
        M = np.zeros((len(dm1_simplices), len(d_simplices)), dtype=np.int64)

        for j, sigma in enumerate(d_simplices):
            verts = sorted(sigma)
            for k, v in enumerate(verts):
                face = frozenset(verts[:k] + verts[k + 1:])
                if face in dm1_index:
                    M[dm1_index[face], j] = (-1) ** k

        return M

    def homology(self, d: int) -> Tuple[int, TorsionSpectrum]:
        """Compute H_d(K; ℤ) = (free_rank, torsion_spectrum)."""
        bd_d = self.boundary_matrix(d)
        bd_dp1 = self.boundary_matrix(d + 1)
        return compute_homology_Z(bd_d, bd_dp1)

    def torsion_spectrum(self, d: int) -> TorsionSpectrum:
        """Get just the torsion spectrum of H_d."""
        _, ts = self.homology(d)
        return ts


if __name__ == "__main__":
    # Example: Build RP² as a simplicial complex and show torsion
    print("=== Smith Normal Form Example ===")
    M = np.array([[2, 0], [0, 3]], dtype=np.int64)
    S, U, V = smith_normal_form(M)
    print(f"Input matrix:\n{M}")
    print(f"Smith normal form:\n{S}")
    ts = extract_torsion_spectrum(M)
    print(f"Torsion spectrum: {ts}")
    print(f"Torsion mass: {ts.mass}")

    print("\n=== Simplex Insertion Trichotomy ===")
    # Case 1: Birth (redundant boundary)
    M1 = np.array([[1, -1], [-1, 0], [0, 1]], dtype=np.int64)
    v1 = np.array([1, -1, 0], dtype=np.int64)
    ev1, rc1 = classify_insertion_event(M1, v1)
    print(f"Case 1 (v in span): {ev1.name}, Δβ_d={rc1.delta_rank_d}, Δβ_{{d-1}}={rc1.delta_rank_dm1}")

    # Case 2: Kill (primitive boundary)
    M2 = np.array([[1], [0], [0]], dtype=np.int64)
    v2 = np.array([0, 1, 0], dtype=np.int64)
    ev2, rc2 = classify_insertion_event(M2, v2)
    print(f"Case 2 (primitive): {ev2.name}, Δβ_d={rc2.delta_rank_d}, Δβ_{{d-1}}={rc2.delta_rank_dm1}")

    # Case 3: Torsion (saturation defect)
    M3 = np.array([[2], [0]], dtype=np.int64)
    v3 = np.array([1, 0], dtype=np.int64)
    ev3, rc3 = classify_insertion_event(M3, v3)
    print(f"Case 3 (torsion): {ev3.name}, Δβ_d={rc3.delta_rank_d}, Δβ_{{d-1}}={rc3.delta_rank_dm1}")

    print("\n=== Euler Constraint Verification ===")
    for name, rc in [("Birth", rc1), ("Kill", rc2), ("Torsion", rc3)]:
        euler = rc.delta_rank_d - rc.delta_rank_dm1
        print(f"{name}: Δβ_d - Δβ_{{d-1}} = {euler} (should be 1)")
