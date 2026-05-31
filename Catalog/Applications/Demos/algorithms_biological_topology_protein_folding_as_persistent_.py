"""
Algorithms for Protein Folding as Persistent Homology Optimization.

Implements:
1. Total persistence computation from point clouds
2. Contact filtration construction
3. Decoy generation for testing the topological folding conjecture
"""

from typing import List, Tuple, Optional
import numpy as np
from dataclasses import dataclass


@dataclass
class PersistenceInterval:
    """A persistence interval [birth, death) with birth <= death."""
    birth: float
    death: float

    @property
    def lifetime(self) -> float:
        """The persistence (lifetime) of this interval."""
        return self.death - self.birth

    def __post_init__(self) -> None:
        assert self.birth <= self.death, f"Invalid interval: birth={self.birth} > death={self.death}"


@dataclass
class PersistenceBarcode:
    """A persistence barcode: a collection of persistence intervals."""
    intervals: List[PersistenceInterval]

    @property
    def total_persistence(self) -> float:
        """Total persistence: sum of all interval lifetimes."""
        return sum(I.lifetime for I in self.intervals)

    @property
    def max_persistence(self) -> float:
        """Maximum persistence (bottleneck)."""
        if not self.intervals:
            return 0.0
        return max(I.lifetime for I in self.intervals)

    @property
    def num_features(self) -> int:
        """Number of intervals."""
        return len(self.intervals)

    def persistent_entropy(self) -> float:
        """Persistent entropy: -sum(p_i * log(p_i)) where p_i = lifetime_i / TP."""
        tp = self.total_persistence
        if tp == 0:
            return 0.0
        entropy = 0.0
        for I in self.intervals:
            p = I.lifetime / tp
            if p > 0:
                entropy -= p * np.log(p)
        return entropy


def compute_distance_matrix(points: np.ndarray) -> np.ndarray:
    """Compute the pairwise Euclidean distance matrix.

    Args:
        points: (n, 3) array of 3D coordinates.

    Returns:
        (n, n) symmetric distance matrix.
    """
    n = len(points)
    D = np.zeros((n, n))
    for i in range(n):
        for j in range(i + 1, n):
            d = np.linalg.norm(points[i] - points[j])
            D[i, j] = d
            D[j, i] = d
    return D


def compute_h0_barcode(distance_matrix: np.ndarray) -> PersistenceBarcode:
    """Compute H0 persistent homology barcode using single-linkage clustering.

    This computes the connected components barcode of the Vietoris-Rips
    filtration, which tracks how connected components merge as the
    threshold increases.

    Args:
        distance_matrix: (n, n) symmetric distance matrix.

    Returns:
        PersistenceBarcode with H0 intervals.
    """
    n = len(distance_matrix)
    if n == 0:
        return PersistenceBarcode([])

    # Union-Find data structure
    parent = list(range(n))
    rank = [0] * n
    birth = [0.0] * n  # All components born at threshold 0

    def find(x: int) -> int:
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x: int, y: int) -> Optional[int]:
        rx, ry = find(x), find(y)
        if rx == ry:
            return None  # Already connected
        # Merge smaller into larger
        if rank[rx] < rank[ry]:
            rx, ry = ry, rx
        parent[ry] = rx
        if rank[rx] == rank[ry]:
            rank[rx] += 1
        return ry  # ry dies

    # Sort edges by distance
    edges: List[Tuple[float, int, int]] = []
    for i in range(n):
        for j in range(i + 1, n):
            edges.append((distance_matrix[i, j], i, j))
    edges.sort()

    intervals: List[PersistenceInterval] = []

    for dist, i, j in edges:
        dead = union(i, j)
        if dead is not None:
            intervals.append(PersistenceInterval(birth=0.0, death=dist))

    # One component survives to infinity (represented as max distance)
    # We don't include the infinite bar in total persistence

    return PersistenceBarcode(intervals)


def compute_contact_set(distance_matrix: np.ndarray, epsilon: float) -> List[Tuple[int, int]]:
    """Compute the contact set at threshold epsilon.

    Args:
        distance_matrix: (n, n) distance matrix.
        epsilon: Threshold parameter.

    Returns:
        List of (i, j) pairs with distance <= epsilon.
    """
    n = len(distance_matrix)
    contacts = []
    for i in range(n):
        for j in range(i + 1, n):
            if distance_matrix[i, j] <= epsilon:
                contacts.append((i, j))
    return contacts


def generate_decoy(
    native: np.ndarray,
    bond_length: float = 3.8,
    perturbation_std: float = 2.0,
    max_attempts: int = 100
) -> Optional[np.ndarray]:
    """Generate a decoy configuration by perturbing the native fold.

    Args:
        native: (n, 3) native configuration.
        bond_length: Maximum bond length between consecutive residues.
        perturbation_std: Standard deviation of random perturbation.
        max_attempts: Maximum number of rejection sampling attempts.

    Returns:
        Decoy configuration or None if generation failed.
    """
    n = len(native)
    min_separation = 1.5  # Minimum distance between non-bonded atoms

    for _ in range(max_attempts):
        decoy = native.copy()

        # Perturb each residue
        perturbation = np.random.randn(n, 3) * perturbation_std
        decoy += perturbation

        # Enforce bond length constraints (project to feasible set)
        for i in range(n - 1):
            direction = decoy[i + 1] - decoy[i]
            current_dist = np.linalg.norm(direction)
            if current_dist > bond_length:
                direction = direction / current_dist * bond_length
                decoy[i + 1] = decoy[i] + direction

        # Check self-avoidance
        is_valid = True
        for i in range(n):
            for j in range(i + 2, n):  # Skip adjacent residues
                if np.linalg.norm(decoy[i] - decoy[j]) < min_separation:
                    is_valid = False
                    break
            if not is_valid:
                break

        if is_valid:
            return decoy

    return None


def total_persistence_energy(points: np.ndarray) -> float:
    """Compute the topological energy (total persistence) of a configuration.

    Args:
        points: (n, 3) array of 3D coordinates.

    Returns:
        Total persistence of the H0 barcode.
    """
    D = compute_distance_matrix(points)
    barcode = compute_h0_barcode(D)
    return barcode.total_persistence


def ultrametric_defect(distance_matrix: np.ndarray) -> float:
    """Compute the ultrametric defect of a distance matrix.

    The ultrametric defect is max_{x,y,z} (d(x,z) - max(d(x,y), d(y,z)))^+.
    A distance matrix is ultrametric iff the defect is zero.

    Args:
        distance_matrix: (n, n) distance matrix.

    Returns:
        The ultrametric defect (non-negative).
    """
    n = len(distance_matrix)
    defect = 0.0
    for x in range(n):
        for y in range(n):
            for z in range(n):
                val = distance_matrix[x, z] - max(
                    distance_matrix[x, y], distance_matrix[y, z]
                )
                defect = max(defect, val)
    return defect


def test_topological_folding_conjecture(
    native: np.ndarray,
    n_decoys: int = 100,
    bond_length: float = 3.8,
    perturbation_std: float = 2.0,
) -> dict:
    """Test the topological folding conjecture for a single protein.

    Args:
        native: (n, 3) native configuration.
        n_decoys: Number of decoy configurations to generate.
        bond_length: Bond length constraint.
        perturbation_std: Perturbation magnitude for decoy generation.

    Returns:
        Dictionary with test results.
    """
    native_tp = total_persistence_energy(native)

    decoy_tps = []
    n_generated = 0
    n_lower = 0  # Number of decoys with lower TP than native

    for _ in range(n_decoys):
        decoy = generate_decoy(native, bond_length, perturbation_std)
        if decoy is not None:
            tp = total_persistence_energy(decoy)
            decoy_tps.append(tp)
            n_generated += 1
            if tp < native_tp:
                n_lower += 1

    return {
        "native_total_persistence": native_tp,
        "n_decoys_generated": n_generated,
        "n_decoys_lower_tp": n_lower,
        "conjecture_holds": n_lower == 0,
        "native_rank": 1 + n_lower,  # 1 = best
        "native_percentile": 100 * (1 - n_lower / max(1, n_generated)),
        "decoy_tp_mean": np.mean(decoy_tps) if decoy_tps else 0.0,
        "decoy_tp_std": np.std(decoy_tps) if decoy_tps else 0.0,
        "decoy_tp_min": min(decoy_tps) if decoy_tps else 0.0,
        "decoy_tp_max": max(decoy_tps) if decoy_tps else 0.0,
    }
