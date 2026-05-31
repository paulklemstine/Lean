"""
Algorithms for Topological Quantum Error Correction from Homological Persistence.

Implements the barcode-to-code construction and related computations.
"""

from dataclasses import dataclass
from typing import List, Tuple
import math


@dataclass
class PersistenceBar:
    """A bar in a persistence barcode with birth and death times."""
    birth: float
    death: float

    def __post_init__(self) -> None:
        if self.birth >= self.death:
            raise ValueError(f"Birth ({self.birth}) must be < death ({self.death})")

    @property
    def persistence(self) -> float:
        """The lifetime of the topological feature."""
        return self.death - self.birth

    @property
    def persistence_ratio(self) -> float:
        """The ratio death/birth (requires birth > 0)."""
        if self.birth <= 0:
            raise ValueError("Persistence ratio requires positive birth time")
        return self.death / self.birth


@dataclass
class PersistenceBarcode:
    """A persistence barcode: a collection of bars."""
    bars: List[PersistenceBar]

    @property
    def num_bars(self) -> int:
        return len(self.bars)

    @property
    def min_persistence(self) -> float:
        """Minimum persistence across all bars."""
        if not self.bars:
            raise ValueError("Empty barcode")
        return min(bar.persistence for bar in self.bars)

    @property
    def max_persistence(self) -> float:
        """Maximum persistence across all bars."""
        if not self.bars:
            raise ValueError("Empty barcode")
        return max(bar.persistence for bar in self.bars)

    @property
    def total_persistence(self) -> float:
        """Sum of all bar persistences."""
        return sum(bar.persistence for bar in self.bars)


@dataclass
class QECParams:
    """Parameters of a quantum error-correcting code [[n, k, d]]."""
    n_physical: int
    k_logical: int
    distance: int

    def __post_init__(self) -> None:
        if self.k_logical > self.n_physical:
            raise ValueError("k_logical must be <= n_physical")

    @property
    def rate(self) -> float:
        """Code rate k/n."""
        if self.n_physical == 0:
            return 0.0
        return self.k_logical / self.n_physical

    def satisfies_singleton_bound(self) -> bool:
        """Check if the topological Singleton bound kd ≤ n² holds."""
        return self.k_logical * self.distance <= self.n_physical ** 2


def barcode_to_code(barcode: PersistenceBarcode, num_cells: int) -> QECParams:
    """
    Construct QEC parameters from a persistence barcode.

    Algorithm (Barcode-to-Code Construction):
    1. n = num_cells (number of cells in the simplicial complex)
    2. k = number of bars in the barcode
    3. d = floor(min persistence across all bars)

    Args:
        barcode: The H₁ persistence barcode
        num_cells: Number of cells in the simplicial complex

    Returns:
        QEC parameters [[n, k, d]]
    """
    k = barcode.num_bars
    d = math.floor(barcode.min_persistence)
    return QECParams(n_physical=num_cells, k_logical=k, distance=d)


def toric_code_barcode(L: int) -> Tuple[PersistenceBarcode, int]:
    """
    Construct the persistence barcode for the L×L torus.

    The torus has:
    - 2L² edges (physical qubits)
    - β₁ = 2
    - Two bars: both with birth=1, death=L

    Args:
        L: Grid size (L ≥ 2)

    Returns:
        (barcode, num_cells) tuple
    """
    if L < 2:
        raise ValueError("L must be >= 2")
    bar = PersistenceBar(birth=1.0, death=float(L))
    barcode = PersistenceBarcode(bars=[bar, bar])
    num_cells = 2 * L * L
    return barcode, num_cells


def persistence_stability_bound(
    bar1: PersistenceBar,
    bar2: PersistenceBar,
) -> float:
    """
    Compute the persistence stability bound.

    If |b₁ - b₂| ≤ ε and |d₁ - d₂| ≤ ε, then |τ₁ - τ₂| ≤ 2ε.

    Returns the actual |τ₁ - τ₂| (the bound is 2 * max(|Δb|, |Δd|)).
    """
    return abs(bar1.persistence - bar2.persistence)


def compute_distance_bound(barcode: PersistenceBarcode) -> int:
    """
    Compute the code distance lower bound from a barcode.

    The distance is at least floor(min persistence).
    """
    return math.floor(barcode.min_persistence)


def verify_topological_singleton(params: QECParams) -> bool:
    """
    Verify the topological Singleton bound: kd ≤ n².

    For a code derived from a barcode where distance ≤ max_persistence ≤ n,
    this bound always holds.
    """
    return params.k_logical * params.distance <= params.n_physical ** 2


def compute_persistence_ratio(bar: PersistenceBar) -> Tuple[float, float, float]:
    """
    Compute the birth-death distance bound decomposition.

    Returns (ratio, persistence, decomposition_check) where:
    - ratio = d/b
    - persistence = d - b
    - decomposition_check = 1 + (d-b)/b (should equal ratio)
    """
    if bar.birth <= 0:
        raise ValueError("Requires positive birth time")
    ratio = bar.death / bar.birth
    persistence = bar.persistence
    decomposition = 1 + persistence / bar.birth
    return ratio, persistence, decomposition


def grid_complex_barcode(rows: int, cols: int) -> Tuple[PersistenceBarcode, int]:
    """
    Approximate barcode for a grid complex (rectangle with boundary).

    A rows×cols grid graph has:
    - rows*cols vertices, (rows-1)*cols + rows*(cols-1) edges
    - β₁ = (rows-1)*(cols-1) for the planar grid
    - Each independent cycle has persistence ~ min(rows, cols) - 1

    Args:
        rows: Number of rows (≥ 2)
        cols: Number of columns (≥ 2)

    Returns:
        (barcode, num_edges) tuple
    """
    if rows < 2 or cols < 2:
        raise ValueError("Grid must be at least 2×2")
    num_edges = (rows - 1) * cols + rows * (cols - 1)
    beta_1 = (rows - 1) * (cols - 1)
    min_dim = min(rows, cols)
    bar = PersistenceBar(birth=1.0, death=float(min_dim))
    barcode = PersistenceBarcode(bars=[bar] * beta_1)
    return barcode, num_edges
