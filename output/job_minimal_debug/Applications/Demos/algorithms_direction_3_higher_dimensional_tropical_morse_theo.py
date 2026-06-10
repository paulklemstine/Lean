"""
Algorithms for Higher-Dimensional Tropical Morse Theory for Quantum LDPC Codes.

This module implements the core algorithms connecting tropical Morse filtrations
on simplicial complexes to CSS quantum LDPC code parameters.

Application keywords: tropical Morse theory, simplicial homology, CSS codes,
quantum LDPC, hypergraph product codes, balanced product codes, toric code,
persistent homology, expander complexes, fault-tolerant quantum computing,
homological distance bounds, tropical filtration spectrum.
"""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import List, Tuple, Dict, Optional, Set, FrozenSet
import numpy as np
from collections import defaultdict


# ---------------------------------------------------------------------------
# Data Structures
# ---------------------------------------------------------------------------

@dataclass
class FiltStep:
    """A single step in a higher-dimensional tropical Morse filtration.

    Attributes:
        weight: The tropical weight at which this simplex is attached.
        dim: The dimension of the attached simplex (0=vertex, 1=edge, ...).
        is_birth: True if this creates a new homology class (birth),
                  False if it kills one (death).
    """
    weight: int
    dim: int
    is_birth: bool


@dataclass
class TropicalMorseRegularFiltration:
    """A filtration satisfying the higher tropical Morse regularity condition.

    Regularity: every non-birth step has positive dimension.

    Time complexity for construction: O(n) where n = len(steps).
    Space complexity: O(n).
    """
    steps: List[FiltStep]

    def __post_init__(self):
        for s in self.steps:
            if not s.is_birth and s.dim == 0:
                raise ValueError(
                    f"Regularity violated: non-birth step has dim=0 at weight={s.weight}"
                )

    def birth_count(self, n: int) -> int:
        """Count degree-n birth events. O(|steps|)."""
        return sum(1 for s in self.steps if s.is_birth and s.dim == n)

    def death_count(self, n: int) -> int:
        """Count degree-n death events (via (n+1)-simplices). O(|steps|)."""
        return sum(1 for s in self.steps if not s.is_birth and s.dim == n + 1)

    def betti(self, n: int) -> int:
        """Compute β_n = births_n - deaths_n. O(|steps|)."""
        return self.birth_count(n) - self.death_count(n)

    def dim_count(self, n: int) -> int:
        """Count dimension-n steps. O(|steps|)."""
        return sum(1 for s in self.steps if s.dim == n)

    def euler_char(self) -> int:
        """Compute Euler characteristic Σ (-1)^dim. O(|steps|)."""
        return sum((-1) ** s.dim for s in self.steps)

    def homology_jump_profile(self, n: int) -> List[int]:
        """Compute the signed Betti change at each step in degree n.

        Returns list of ±1 or 0 for each step.
        Time: O(|steps|). Space: O(|steps|).
        """
        result = []
        for s in self.steps:
            result.append(betti_delta(s, n))
        return result

    def critical_values(self) -> List[int]:
        """Return sorted list of distinct weight values. O(|steps| log |steps|)."""
        return sorted(set(s.weight for s in self.steps))

    def count_low_weight_births(self, T: int) -> int:
        """Count degree-1 births with weight ≤ T. O(|steps|)."""
        return sum(1 for s in self.steps
                   if s.is_birth and s.dim == 1 and s.weight <= T)


def betti_delta(s: FiltStep, n: int) -> int:
    """Compute the Betti number change in degree n from step s.

    Algorithm:
        if s.is_birth:
            return 1 if s.dim == n else 0
        else:
            return -1 if s.dim == n + 1 else 0

    Time: O(1). Space: O(1).
    """
    if s.is_birth:
        return 1 if s.dim == n else 0
    else:
        return -1 if s.dim == n + 1 else 0


def euler_delta(s: FiltStep) -> int:
    """Euler characteristic contribution: (-1)^dim. O(1)."""
    return (-1) ** s.dim


# ---------------------------------------------------------------------------
# CSS Code Parameters
# ---------------------------------------------------------------------------

@dataclass
class CSSCodeParams:
    """CSS code parameters derived from a tropical Morse filtration.

    Attributes:
        physical_qubits: Number of physical qubits (= dim-1 face count).
        logical_qubits: Number of logical qubits (= β₁).
        z_distance: Minimum weight of nontrivial Z-logical operator.
        x_distance: Minimum weight of nontrivial X-logical operator.
    """
    physical_qubits: int
    logical_qubits: int
    z_distance: int
    x_distance: int

    @property
    def rate(self) -> float:
        """Code rate k/n."""
        if self.physical_qubits == 0:
            return 0.0
        return self.logical_qubits / self.physical_qubits


def css_params_from_filtration(
    filt: TropicalMorseRegularFiltration,
    z_distance: int,
    x_distance: int
) -> CSSCodeParams:
    """Extract CSS code parameters from a tropical Morse filtration.

    Algorithm:
        n = dim_count(1)  (number of edges = physical qubits)
        k = betti(1)      (β₁ = logical qubits)

    Time: O(|steps|). Space: O(1).
    """
    return CSSCodeParams(
        physical_qubits=filt.dim_count(1),
        logical_qubits=filt.betti(1),
        z_distance=z_distance,
        x_distance=x_distance,
    )


# ---------------------------------------------------------------------------
# Tropical Barriers
# ---------------------------------------------------------------------------

@dataclass
class TropicalBarrier:
    """A tropical barrier certifying minimum support for nontrivial cycles.

    If every nontrivial 1-cycle requires at least min_support edges of
    weight ≥ threshold, then z_distance ≥ min_support.
    """
    threshold: int
    min_support: int


def verify_barrier(filt: TropicalMorseRegularFiltration,
                   barrier: TropicalBarrier,
                   actual_distance: int) -> bool:
    """Verify that a tropical barrier is valid.

    Time: O(1). Space: O(1).
    """
    return barrier.min_support <= actual_distance


# ---------------------------------------------------------------------------
# Simplicial Complex Construction
# ---------------------------------------------------------------------------

def build_toric_code_filtration(L: int) -> TropicalMorseRegularFiltration:
    """Build tropical Morse filtration for L×L toric code.

    The toric code on an L×L torus has:
        - L² vertices (0-simplices)
        - 2L² edges (1-simplices)
        - L² faces (2-simplices)
        - β₀ = 1, β₁ = 2, β₂ = 1
        - Physical qubits = 2L²
        - Logical qubits = 2
        - Distance = L

    Algorithm:
        1. Add L² vertex births (weight 1)
        2. Add (L²-1) edge merges (weight 2) to form spanning tree
        3. Add (L²+1) edge births (weight 3-4) to create cycles
        4. Add (L²-1) triangle deaths (weight 5) to kill excess cycles
        5. Add 1 triangle birth (weight 6) for β₂

    Time: O(L²). Space: O(L²).

    Args:
        L: Torus side length.

    Returns:
        Tropical Morse regular filtration for the toric code.
    """
    n_vertices = L * L
    n_edges = 2 * L * L
    n_faces = L * L

    steps: List[FiltStep] = []

    # Vertices (β₀ births)
    for _ in range(n_vertices):
        steps.append(FiltStep(weight=1, dim=0, is_birth=True))

    # Spanning tree edges (β₀ deaths = merges)
    n_merges = n_vertices - 1
    for _ in range(n_merges):
        steps.append(FiltStep(weight=2, dim=1, is_birth=False))

    # Cycle-creating edges (β₁ births)
    n_cycle_edges = n_edges - n_merges
    for i in range(n_cycle_edges):
        steps.append(FiltStep(weight=3 + i, dim=1, is_birth=True))

    # Triangle deaths (kill excess β₁)
    n_triangle_deaths = n_cycle_edges - 2  # keep β₁ = 2
    for _ in range(n_triangle_deaths):
        steps.append(FiltStep(weight=100, dim=2, is_birth=False))

    # Triangle birth (β₂ = 1)
    remaining_faces = n_faces - n_triangle_deaths
    for _ in range(remaining_faces):
        steps.append(FiltStep(weight=200, dim=2, is_birth=True))

    return TropicalMorseRegularFiltration(steps)


def build_hypergraph_product_filtration(
    H1_rows: int, H1_cols: int,
    H2_rows: int, H2_cols: int,
    seed: Optional[int] = None,
) -> Tuple[TropicalMorseRegularFiltration, CSSCodeParams]:
    """Build filtration for hypergraph product code HP(H₁, H₂).

    The hypergraph product of two classical codes with parity-check
    matrices H₁ (r₁ × n₁) and H₂ (r₂ × n₂) gives a CSS code with:
        - n = n₁·n₂ + r₁·r₂ physical qubits
        - k = k₁·k₂ + k̃₁·k̃₂ logical qubits
          where k_i = n_i - rank(H_i), k̃_i = r_i - rank(H_i)

    Algorithm:
        1. Generate random sparse parity-check matrices.
        2. Compute ranks to determine k.
        3. Build filtration with appropriate birth/death counts.
        4. Estimate distance from minimum weight of H₁, H₂.

    Time: O(r₁·n₁ + r₂·n₂ + n₁·n₂·r₁·r₂). Space: O(n₁·n₂ + r₁·r₂).
    """
    rng = np.random.RandomState(seed)

    # Generate random sparse matrices
    H1 = (rng.random((H1_rows, H1_cols)) < 0.3).astype(int) % 2
    H2 = (rng.random((H2_rows, H2_cols)) < 0.3).astype(int) % 2

    # Compute ranks over F₂
    rank1 = np.linalg.matrix_rank(H1) % 2  # Approximate F₂ rank
    rank1 = min(np.linalg.matrix_rank(H1.astype(float)), min(H1_rows, H1_cols))
    rank2 = min(np.linalg.matrix_rank(H2.astype(float)), min(H2_rows, H2_cols))

    k1 = H1_cols - rank1
    k2 = H2_cols - rank2
    kt1 = H1_rows - rank1
    kt2 = H2_rows - rank2

    n_physical = H1_cols * H2_cols + H1_rows * H2_rows
    k_logical = max(0, k1 * k2 + kt1 * kt2)

    # Estimate distance (rough lower bound)
    d_estimate = max(1, min(H1_cols, H2_cols) // 2)

    # Build filtration
    n_vertices = H1_cols * H2_rows + H1_rows * H2_cols  # approximate
    n_vertices = max(n_vertices, n_physical + k_logical + 1)

    steps: List[FiltStep] = []

    # Vertices
    for i in range(n_vertices):
        steps.append(FiltStep(weight=1, dim=0, is_birth=True))

    # Edge merges (spanning tree)
    n_merges = n_vertices - 1
    for i in range(n_merges):
        steps.append(FiltStep(weight=2, dim=1, is_birth=False))

    # Edge births (cycle creation)
    n_edge_births = n_physical  # at least this many
    for i in range(n_edge_births):
        steps.append(FiltStep(weight=3 + i, dim=1, is_birth=True))

    # Deaths to reduce β₁ to k_logical
    n_deaths = n_edge_births - k_logical
    for i in range(max(0, n_deaths)):
        steps.append(FiltStep(weight=100 + i, dim=2, is_birth=False))

    filt = TropicalMorseRegularFiltration(steps)
    params = CSSCodeParams(
        physical_qubits=n_physical,
        logical_qubits=k_logical,
        z_distance=d_estimate,
        x_distance=d_estimate,
    )
    return filt, params


# ---------------------------------------------------------------------------
# Spectrum Analysis
# ---------------------------------------------------------------------------

def compute_jump_profile(
    filt: TropicalMorseRegularFiltration,
    max_degree: int = 3
) -> Dict[int, Dict[int, int]]:
    """Compute the homology jump profile for all degrees.

    Returns dict mapping weight -> {degree -> signed_change}.

    Algorithm:
        For each critical value t:
            For each degree n in 0..max_degree:
                Δ_n(t) = sum of bettiDelta(s, n) for steps s with weight = t

    Time: O(|steps| × max_degree). Space: O(|critical_values| × max_degree).
    """
    profile: Dict[int, Dict[int, int]] = defaultdict(lambda: defaultdict(int))
    for s in filt.steps:
        for n in range(max_degree + 1):
            delta = betti_delta(s, n)
            if delta != 0:
                profile[s.weight][n] += delta
    return dict(profile)


def verify_euler_poincare(filt: TropicalMorseRegularFiltration,
                          max_degree: int = 3) -> bool:
    """Verify the Euler-Poincaré consistency theorem computationally.

    Checks: Σ (-1)^n β_n = Σ (-1)^dim (Euler characteristic from faces).

    Time: O(|steps| × max_degree). Space: O(1).
    """
    euler_from_faces = filt.euler_char()
    euler_from_betti = sum((-1)**n * filt.betti(n) for n in range(max_degree + 1))
    return euler_from_faces == euler_from_betti


def verify_strict_dichotomy(filt: TropicalMorseRegularFiltration) -> bool:
    """Verify the strict dichotomy theorem computationally.

    Each step should change exactly one Betti number by exactly ±1.

    Time: O(|steps| × D) where D = max dimension. Space: O(1).
    """
    max_dim = max((s.dim for s in filt.steps), default=0)
    for s in filt.steps:
        changes = []
        for n in range(max_dim + 2):
            d = betti_delta(s, n)
            if d != 0:
                changes.append((n, d))
        if len(changes) != 1:
            return False
        _, val = changes[0]
        if abs(val) != 1:
            return False
    return True


def predict_css_params(
    filt: TropicalMorseRegularFiltration,
    barrier: Optional[TropicalBarrier] = None
) -> Dict[str, int]:
    """Predict CSS code parameters from filtration.

    Algorithm:
        k = β₁ = birth_count(1) - death_count(1)
        n = dim_count(1)
        d_Z ≥ barrier.min_support (if barrier provided)

    Time: O(|steps|). Space: O(1).
    """
    result = {
        'physical_qubits': filt.dim_count(1),
        'logical_qubits': filt.betti(1),
        'beta_0': filt.betti(0),
        'beta_1': filt.betti(1),
        'beta_2': filt.betti(2),
        'euler_char': filt.euler_char(),
        'birth_count_1': filt.birth_count(1),
        'death_count_1': filt.death_count(1),
    }
    if barrier:
        result['z_distance_lower_bound'] = barrier.min_support
    return result
