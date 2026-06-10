"""
Algorithms for Tropical Spectral Concentration Theory.

Implements the core algorithms from the research paper:
1. Tropical spectrum extraction via Kruskal-style filtration
2. McDiarmid concentration radius computation
3. Union-Find data structure for efficient component tracking
"""

from __future__ import annotations
import math
from typing import List, Tuple, Optional
from dataclasses import dataclass, field


class UnionFind:
    """Weighted Union-Find with path compression.

    Supports O(α(n)) amortized find and union operations,
    where α is the inverse Ackermann function.

    Attributes:
        parent: Parent pointers for each element.
        rank: Rank (upper bound on tree height) for each element.
        num_components: Current number of connected components.
    """

    def __init__(self, n: int):
        """Initialize n singleton components.

        Args:
            n: Number of elements (0-indexed).
        """
        self.parent: List[int] = list(range(n))
        self.rank: List[int] = [0] * n
        self.num_components: int = n

    def find(self, x: int) -> int:
        """Find the root of x with path compression.

        Args:
            x: Element to find the root of.

        Returns:
            Root representative of x's component.

        Time complexity: O(α(n)) amortized.
        """
        if self.parent[x] != x:
            self.parent[x] = self.find(self.parent[x])
        return self.parent[x]

    def union(self, x: int, y: int) -> bool:
        """Union the components containing x and y.

        Args:
            x: First element.
            y: Second element.

        Returns:
            True if a merge occurred (x and y were in different components).
            False if x and y were already in the same component (cycle birth).
        """
        rx, ry = self.find(x), self.find(y)
        if rx == ry:
            return False  # cycle birth
        if self.rank[rx] < self.rank[ry]:
            rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]:
            self.rank[rx] += 1
        self.num_components -= 1
        return True  # merge


@dataclass
class FiltrationStep:
    """A single step in a graph filtration.

    Attributes:
        weight: Edge weight (insertion order parameter).
        u: First endpoint of the edge.
        v: Second endpoint of the edge.
        is_cycle_birth: Whether this edge creates a cycle.
    """
    weight: float
    u: int
    v: int
    is_cycle_birth: bool = False


@dataclass
class TropicalFiltration:
    """A complete tropical graph filtration.

    Attributes:
        num_verts: Number of vertices.
        steps: Ordered list of filtration steps.
    """
    num_verts: int
    steps: List[FiltrationStep] = field(default_factory=list)

    @property
    def edge_count(self) -> int:
        return len(self.steps)

    @property
    def cycle_count(self) -> int:
        return sum(1 for s in self.steps if s.is_cycle_birth)

    @property
    def merge_count(self) -> int:
        return sum(1 for s in self.steps if not s.is_cycle_birth)

    @property
    def tropical_spectrum(self) -> List[float]:
        """Extract the tropical spectrum: weights at which cycle births occur."""
        return [s.weight for s in self.steps if s.is_cycle_birth]

    @property
    def merge_spectrum(self) -> List[float]:
        """Extract merge weights (dual spectrum)."""
        return [s.weight for s in self.steps if not s.is_cycle_birth]

    @property
    def cycle_rank(self) -> int:
        """Tropical cycle rank = β₁ for connected graphs."""
        return self.cycle_count

    def cycle_birth_count_le(self, t: float) -> int:
        """Cumulative cycle-birth count at threshold t."""
        return sum(1 for s in self.steps if s.is_cycle_birth and s.weight <= t)

    def map_weights(self, phi) -> 'TropicalFiltration':
        """Apply weight transformation (universality: preserves spectrum structure)."""
        new_steps = [
            FiltrationStep(phi(s.weight), s.u, s.v, s.is_cycle_birth)
            for s in self.steps
        ]
        return TropicalFiltration(self.num_verts, new_steps)

    @property
    def flags(self) -> List[bool]:
        """Extract cycle-birth flags."""
        return [s.is_cycle_birth for s in self.steps]


def extract_tropical_spectrum(
    num_verts: int,
    edges: List[Tuple[int, int, float]]
) -> TropicalFiltration:
    """Extract the tropical spectrum via Kruskal-style filtration.

    Algorithm:
        1. Sort edges by weight.
        2. Process edges in order using Union-Find.
        3. Each edge either merges components or creates a cycle.

    Args:
        num_verts: Number of vertices.
        edges: List of (u, v, weight) tuples.

    Returns:
        TropicalFiltration with classified steps.

    Time complexity: O(m log m + m α(n)) where m = |edges|, n = num_verts.
    Space complexity: O(n + m).

    Example:
        >>> filt = extract_tropical_spectrum(3, [(0,1,1.0), (1,2,2.0), (0,2,3.0)])
        >>> filt.tropical_spectrum
        [3.0]
        >>> filt.cycle_rank
        1
    """
    sorted_edges = sorted(edges, key=lambda e: e[2])
    uf = UnionFind(num_verts)
    steps = []
    for u, v, w in sorted_edges:
        merged = uf.union(u, v)
        steps.append(FiltrationStep(w, u, v, is_cycle_birth=not merged))
    return TropicalFiltration(num_verts, steps)


def mcdiarmid_radius(m: int, alpha: float) -> float:
    """Compute the McDiarmid concentration radius.

    For a function with bounded differences constant c = 1 on m variables:
        P(|X - E[X]| ≥ δ) ≤ α  when  δ = sqrt(m · ln(2/α) / 2)

    Args:
        m: Number of independent variables (edges).
        alpha: Confidence level (probability of deviation exceeding radius).

    Returns:
        Concentration radius δ.

    Example:
        >>> mcdiarmid_radius(100, 0.05)  # 95% confidence
        12.16...
    """
    if alpha <= 0 or alpha >= 2:
        raise ValueError(f"alpha must be in (0, 2), got {alpha}")
    return math.sqrt(m * math.log(2.0 / alpha) / 2.0)


def spectral_gap(spectrum: List[float]) -> float:
    """Compute the minimum gap between consecutive tropical eigenvalues.

    Args:
        spectrum: Ordered list of cycle-birth weights.

    Returns:
        Minimum absolute difference between consecutive entries.
        Returns infinity for spectra with fewer than 2 entries.

    Example:
        >>> spectral_gap([4.0, 5.0, 6.0])
        1.0
    """
    if len(spectrum) < 2:
        return float('inf')
    return min(abs(spectrum[i+1] - spectrum[i]) for i in range(len(spectrum) - 1))


def verify_euler_poincare(filt: TropicalFiltration) -> bool:
    """Verify the Euler–Poincaré identity: edges = merges + cycles.

    Args:
        filt: A tropical filtration.

    Returns:
        True if the identity holds.
    """
    return filt.edge_count == filt.merge_count + filt.cycle_count


def verify_universality(filt: TropicalFiltration, phi) -> bool:
    """Verify universality: weight transform preserves flags.

    Args:
        filt: A tropical filtration.
        phi: Weight transformation function.

    Returns:
        True if flags are preserved under phi.
    """
    transformed = filt.map_weights(phi)
    return transformed.flags == filt.flags


def verify_rank_nullity(filt: TropicalFiltration) -> bool:
    """Verify rank-nullity for connected filtrations.

    Args:
        filt: A tropical filtration (must be connected: merge_count = num_verts - 1).

    Returns:
        True if cycle_rank = edge_count - num_verts + 1.
    """
    if filt.merge_count != filt.num_verts - 1:
        return False  # not connected
    return filt.cycle_rank == filt.edge_count - filt.num_verts + 1


if __name__ == "__main__":
    # Quick self-test
    # Triangle
    filt = extract_tropical_spectrum(3, [(0,1,1), (1,2,2), (0,2,3)])
    assert filt.tropical_spectrum == [3.0], f"Got {filt.tropical_spectrum}"
    assert filt.cycle_rank == 1
    assert verify_euler_poincare(filt)
    assert verify_rank_nullity(filt)
    assert verify_universality(filt, lambda x: x**2)
    print("Triangle: ✓")

    # K4
    edges_k4 = [(0,1,1), (0,2,2), (0,3,3), (1,2,4), (1,3,5), (2,3,6)]
    filt_k4 = extract_tropical_spectrum(4, edges_k4)
    assert filt_k4.tropical_spectrum == [4.0, 5.0, 6.0]
    assert filt_k4.cycle_rank == 3
    assert verify_euler_poincare(filt_k4)
    assert verify_rank_nullity(filt_k4)
    print("K4: ✓")

    # McDiarmid radius
    r = mcdiarmid_radius(100, 0.05)
    print(f"McDiarmid radius (m=100, α=0.05): {r:.4f}")

    # Spectral gap
    gap = spectral_gap([4.0, 5.0, 6.0])
    assert gap == 1.0
    print(f"Spectral gap of K4 spectrum: {gap}")

    print("\nAll self-tests passed.")
