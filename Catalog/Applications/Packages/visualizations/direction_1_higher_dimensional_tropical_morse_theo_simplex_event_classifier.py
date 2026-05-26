"""
algorithms.py — Tropical Morse Theory for Simplicial Complexes

Implements the simplex insertion classifier and tropical persistent rank
reconstruction algorithm, as described in the research paper.

Key algorithms:
1. classify_simplex_insertion: Determines birth/death for a simplex insertion
2. compute_betti_numbers: Computes Betti numbers via boundary matrix reduction
3. tropical_persistent_rank: Reconstructs Betti numbers from event data
4. build_filtration: Constructs a weighted simplex filtration
"""

from typing import List, Tuple, Dict, Set, Optional
from enum import Enum
from dataclasses import dataclass, field
import numpy as np


class TropicalEvent(Enum):
    BIRTH = "birth"
    DEATH = "death"


@dataclass
class TropicalMorseDatum:
    """Records the tropical event data for a simplex insertion."""
    degree: int
    event: TropicalEvent
    simplex: frozenset


@dataclass
class SimplicialComplex:
    """A finite abstract simplicial complex."""
    simplices: Set[frozenset]

    def __post_init__(self):
        # Ensure downward-closure
        to_add = set()
        for s in self.simplices:
            for i in range(len(s)):
                for face in _faces_of(s):
                    to_add.add(face)
        self.simplices |= to_add

    def d_simplices(self, d: int) -> Set[frozenset]:
        """Return all d-simplices (those with d+1 vertices)."""
        return {s for s in self.simplices if len(s) == d + 1}

    def dimension(self) -> int:
        """Maximum dimension of any simplex."""
        if not self.simplices:
            return -1
        return max(len(s) - 1 for s in self.simplices)

    def copy(self) -> 'SimplicialComplex':
        return SimplicialComplex(set(self.simplices))


def _faces_of(simplex: frozenset) -> List[frozenset]:
    """Return all proper faces of a simplex."""
    result = []
    s = list(simplex)
    for i in range(len(s)):
        face = frozenset(s[:i] + s[i+1:])
        result.append(face)
        if len(face) > 1:
            result.extend(_faces_of(face))
    return result


def boundary_matrix(K: SimplicialComplex, d: int) -> Tuple[np.ndarray, list, list]:
    """
    Compute the boundary matrix ∂_d : C_d → C_{d-1} over Z/2.

    Returns:
        matrix: The boundary matrix (mod 2)
        d_simplices: Ordered list of d-simplices (columns)
        d1_simplices: Ordered list of (d-1)-simplices (rows)
    """
    d_simps = sorted(K.d_simplices(d), key=lambda s: tuple(sorted(s)))
    d1_simps = sorted(K.d_simplices(d - 1), key=lambda s: tuple(sorted(s)))

    if not d_simps or not d1_simps:
        return np.zeros((len(d1_simps), len(d_simps)), dtype=int), d_simps, d1_simps

    matrix = np.zeros((len(d1_simps), len(d_simps)), dtype=int)

    d1_index = {s: i for i, s in enumerate(d1_simps)}

    for j, sigma in enumerate(d_simps):
        sorted_verts = sorted(sigma)
        for k in range(len(sorted_verts)):
            face = frozenset(sorted_verts[:k] + sorted_verts[k+1:])
            if face in d1_index:
                matrix[d1_index[face], j] = 1  # mod 2, signs don't matter

    return matrix, d_simps, d1_simps


def z2_rank(matrix: np.ndarray) -> int:
    """Compute the rank of a matrix over Z/2 using Gaussian elimination."""
    if matrix.size == 0:
        return 0
    m = matrix.copy() % 2
    rows, cols = m.shape
    rank = 0
    for col in range(cols):
        # Find pivot
        pivot = None
        for row in range(rank, rows):
            if m[row, col] % 2 == 1:
                pivot = row
                break
        if pivot is None:
            continue
        # Swap
        m[[rank, pivot]] = m[[pivot, rank]]
        # Eliminate
        for row in range(rows):
            if row != rank and m[row, col] % 2 == 1:
                m[row] = (m[row] + m[rank]) % 2
        rank += 1
    return rank


def compute_betti_numbers(K: SimplicialComplex, max_dim: int = -1) -> Dict[int, int]:
    """
    Compute Betti numbers β_0, β_1, ..., β_d of K over Z/2.

    Uses rank-nullity: β_d = dim(ker ∂_d) - dim(im ∂_{d+1})
                       = (n_d - rank(∂_d)) - rank(∂_{d+1})
    """
    if max_dim < 0:
        max_dim = K.dimension()

    betti = {}
    ranks = {}

    for d in range(max_dim + 2):
        mat, _, _ = boundary_matrix(K, d)
        ranks[d] = z2_rank(mat)

    for d in range(max_dim + 1):
        n_d = len(K.d_simplices(d))
        r_d = ranks.get(d, 0)
        r_d1 = ranks.get(d + 1, 0)
        betti[d] = n_d - r_d - r_d1

    return betti


def classify_simplex_insertion(
    K: SimplicialComplex, sigma: frozenset
) -> TropicalMorseDatum:
    """
    Classify the tropical event when inserting simplex σ into K.

    Algorithm:
    1. Compute rank(∂_d) before and after insertion.
    2. If rank increases: DEATH in degree d-1 (boundary class killed).
    3. If rank unchanged: BIRTH in degree d (new cycle created).

    Complexity: O(n_d * n_{d-1}) for the rank computation.

    Args:
        K: The current simplicial complex (σ not yet in K)
        sigma: The simplex to insert (all proper faces must be in K)

    Returns:
        TropicalMorseDatum with the event classification
    """
    d = len(sigma) - 1  # dimension of σ

    # Compute rank of ∂_d before insertion
    mat_before, _, _ = boundary_matrix(K, d)
    rank_before = z2_rank(mat_before)

    # Insert σ and compute rank after
    K_prime = SimplicialComplex(K.simplices | {sigma})
    mat_after, _, _ = boundary_matrix(K_prime, d)
    rank_after = z2_rank(mat_after)

    if rank_after > rank_before:
        # ∂σ was nontrivial: kills a (d-1)-class
        return TropicalMorseDatum(degree=d, event=TropicalEvent.DEATH, simplex=sigma)
    else:
        # ∂σ was trivial: creates a new d-cycle
        return TropicalMorseDatum(degree=d, event=TropicalEvent.BIRTH, simplex=sigma)


@dataclass
class FiltrationStep:
    """A single step in a weighted simplex filtration."""
    simplex: frozenset
    weight: float
    datum: Optional[TropicalMorseDatum] = None


def build_filtration(
    simplices_with_weights: List[Tuple[frozenset, float]]
) -> List[FiltrationStep]:
    """
    Build a simplex filtration ordered by weight.

    Each simplex is inserted after all its proper faces.
    The filtration respects both the weight ordering and the face relation.

    Args:
        simplices_with_weights: List of (simplex, weight) pairs

    Returns:
        Ordered list of FiltrationSteps with tropical event classification
    """
    # Sort by weight, then by dimension (lower-dimensional first for ties)
    sorted_simps = sorted(simplices_with_weights, key=lambda x: (x[1], len(x[0])))

    K = SimplicialComplex(set())
    steps = []

    for sigma, weight in sorted_simps:
        if sigma in K.simplices:
            continue

        # Ensure all faces are present first
        faces_to_add = []
        for face in _all_faces(sigma):
            if face not in K.simplices and len(face) > 0:
                faces_to_add.append(face)

        # Add faces in order of increasing dimension
        faces_to_add.sort(key=len)
        for face in faces_to_add:
            if face not in K.simplices:
                datum = classify_simplex_insertion(K, face)
                K = SimplicialComplex(K.simplices | {face})
                steps.append(FiltrationStep(simplex=face, weight=weight, datum=datum))

        # Now add σ itself
        if sigma not in K.simplices:
            datum = classify_simplex_insertion(K, sigma)
            K = SimplicialComplex(K.simplices | {sigma})
            steps.append(FiltrationStep(simplex=sigma, weight=weight, datum=datum))

    return steps


def _all_faces(simplex: frozenset) -> List[frozenset]:
    """Return all nonempty subsets (faces) of a simplex, ordered by dimension."""
    s = list(simplex)
    result = []
    for i in range(1, 2**len(s)):
        face = frozenset(s[j] for j in range(len(s)) if i & (1 << j))
        result.append(face)
    result.sort(key=len)
    return result


def tropical_persistent_rank(
    steps: List[FiltrationStep], d: int, n: int
) -> int:
    """
    Compute the tropical persistent rank at step n in degree d.

    This reconstructs the classical Betti number β_d from tropical
    birth/death event accounting, without computing any homology.

    Algorithm:
        rank = 0
        for each step i < n:
            if step i is a birth in degree d: rank += 1
            if step i is a death in degree d (killing β_d): rank -= 1
        return rank

    By the tropical persistent rank theorem, this equals the classical β_d.
    """
    rank = 0
    for i in range(min(n, len(steps))):
        if steps[i].datum is not None:
            if steps[i].datum.degree == d and steps[i].datum.event == TropicalEvent.BIRTH:
                rank += 1
            elif steps[i].datum.degree == d + 1 and steps[i].datum.event == TropicalEvent.DEATH:
                rank -= 1
    return rank


def euler_characteristic_from_events(steps: List[FiltrationStep], n: int) -> int:
    """
    Compute Euler characteristic from tropical event data.

    Each birth in degree d contributes (-1)^d.
    Each death in degree d (killing β_{d-1}) contributes (-1)^{d-1} = -(-1)^d.
    Combined: each insertion of a d-simplex contributes (-1)^d.
    """
    chi = 0
    for i in range(min(n, len(steps))):
        if steps[i].datum is not None:
            d = len(steps[i].simplex) - 1
            chi += (-1) ** d
    return chi


def verify_tropical_classical_agreement(
    steps: List[FiltrationStep], max_dim: int = 2
) -> bool:
    """
    Verify that tropical persistent rank agrees with classical Betti numbers
    at every filtration step. This is the computational test of the main theorem.

    Returns True if agreement holds at all steps, False otherwise.
    """
    K = SimplicialComplex(set())

    for i, step in enumerate(steps):
        K = SimplicialComplex(K.simplices | {step.simplex})
        classical_betti = compute_betti_numbers(K, max_dim)

        for d in range(max_dim + 1):
            tropical_rank = tropical_persistent_rank(steps, d, i + 1)
            classical_rank = classical_betti.get(d, 0)
            if tropical_rank != classical_rank:
                print(f"MISMATCH at step {i}, degree {d}: "
                      f"tropical={tropical_rank}, classical={classical_rank}")
                return False

    return True


if __name__ == "__main__":
    # Example: triangle insertion
    print("=== Tropical Morse Theory: Simplex Insertion Classifier ===\n")

    # Build a simple complex: three edges forming a path, then close to triangle
    edges = [
        (frozenset({0, 1}), 1.0),
        (frozenset({1, 2}), 2.0),
        (frozenset({0, 2}), 3.0),
    ]

    # Vertices
    vertices = [
        (frozenset({0}), 0.0),
        (frozenset({1}), 0.0),
        (frozenset({2}), 0.0),
    ]

    # Triangle
    triangle = [(frozenset({0, 1, 2}), 4.0)]

    all_simplices = vertices + edges + triangle
    steps = build_filtration(all_simplices)

    print("Filtration steps:")
    for i, step in enumerate(steps):
        dim = len(step.simplex) - 1
        event_str = step.datum.event.value if step.datum else "none"
        event_deg = step.datum.degree if step.datum else -1
        print(f"  Step {i}: σ={set(step.simplex)}, dim={dim}, "
              f"weight={step.weight}, event={event_str} (degree {event_deg})")

    print("\nBetti numbers after each step:")
    K = SimplicialComplex(set())
    for i, step in enumerate(steps):
        K = SimplicialComplex(K.simplices | {step.simplex})
        betti = compute_betti_numbers(K, 2)
        trop = {d: tropical_persistent_rank(steps, d, i + 1) for d in range(3)}
        print(f"  Step {i}: β = {betti}, tropical = {trop}")

    print("\nVerification:", "PASS" if verify_tropical_classical_agreement(steps) else "FAIL")
