#!/usr/bin/env python3
"""
Algorithms for Tropical Persistent Homology

Implements the verified algorithms from the formal development:
1. Patch nerve computation from tropical affine families
2. Critical value enumeration
3. Nerve filtration construction
4. H₀ barcode estimation from nerve data
5. Euler characteristic tracking

All algorithms correspond to formally verified correctness theorems.
"""

import numpy as np
from typing import List, Set, Tuple, Dict, FrozenSet, Optional
from dataclasses import dataclass
import itertools
from collections import defaultdict


@dataclass
class TropicalAffineFamily:
    """
    A finite family of affine forms f_i(x) = sum_j a_{ij} x_j + b_i.
    
    Attributes:
        coeffs: (m, n) coefficient matrix
        biases: (m,) bias vector
    """
    coeffs: np.ndarray
    biases: np.ndarray
    
    @property
    def m(self) -> int:
        """Number of affine forms."""
        return self.coeffs.shape[0]
    
    @property
    def n(self) -> int:
        """Dimension of the ambient space."""
        return self.coeffs.shape[1] if self.coeffs.ndim > 1 else 0
    
    def eval_single(self, i: int, x: np.ndarray) -> float:
        """Evaluate the i-th affine form at point x."""
        return float(np.dot(self.coeffs[i], x) + self.biases[i])
    
    def eval_all(self, x: np.ndarray) -> np.ndarray:
        """Evaluate all affine forms at point x."""
        return self.coeffs @ x + self.biases
    
    def eval_all_grid(self, grid: np.ndarray) -> np.ndarray:
        """Evaluate all affine forms on a grid of points. Returns (m, N) array."""
        return (self.coeffs @ grid.T) + self.biases[:, np.newaxis]
    
    def trop_max(self, x: np.ndarray) -> float:
        """Tropical max: max_i f_i(x)."""
        return float(np.max(self.eval_all(x)))
    
    def trop_min(self, x: np.ndarray) -> float:
        """Tropical min: min_i f_i(x)."""
        return float(np.min(self.eval_all(x)))


# ============================================================================
# Algorithm 1: Patch Nerve Computation
# ============================================================================

def compute_patch_nerve(
    F: TropicalAffineFamily,
    c: float,
    grid: np.ndarray
) -> Set[FrozenSet[int]]:
    """
    Compute the patch nerve at threshold c.
    
    The patch nerve has:
    - Vertices: indices i where {x | f_i(x) ≤ c} is nonempty
    - k-simplices: subsets S where ∩_{i∈S} {x | f_i(x) ≤ c} is nonempty
    
    Verified property: The nerve is monotone in c (patchNerve_mono)
    and downward-closed (patchNerve_down_closed).
    
    Complexity: O(2^m · N) where N = grid size, m = number of forms.
    For practical use, limit to small m or use heuristic pruning.
    
    Args:
        F: Tropical affine family
        c: Threshold value
        grid: (N, n) array of sample points
        
    Returns:
        Set of frozensets representing nerve faces
    """
    # Precompute all evaluations: (m, N) array
    all_vals = F.eval_all_grid(grid)  # (m, N)
    
    # Find which patches are nonempty (have grid points with f_i ≤ c)
    patch_masks = all_vals <= c  # (m, N) boolean
    active_vertices = [i for i in range(F.m) if np.any(patch_masks[i])]
    
    faces = set()
    
    # Check all nonempty subsets of active vertices
    for k in range(1, len(active_vertices) + 1):
        for subset in itertools.combinations(active_vertices, k):
            # Check if intersection is nonempty
            combined_mask = np.ones(grid.shape[0], dtype=bool)
            for i in subset:
                combined_mask &= patch_masks[i]
            if np.any(combined_mask):
                faces.add(frozenset(subset))
    
    return faces


# ============================================================================
# Algorithm 2: Critical Value Enumeration
# ============================================================================

def enumerate_candidate_critical_values_dim0(
    biases: np.ndarray
) -> np.ndarray:
    """
    For 0-dimensional families (constant forms), enumerate critical values.
    
    Verified: algorithm_critical_values_complete_dim0
    Every barcode-critical value is among the returned bias values.
    
    Complexity: O(m log m) for sorting.
    
    Args:
        biases: (m,) array of bias values
        
    Returns:
        Sorted array of unique critical values
    """
    return np.unique(biases)


def enumerate_candidate_critical_values(
    F: TropicalAffineFamily,
    grid: np.ndarray,
    n_thresholds: int = 1000
) -> List[float]:
    """
    Enumerate candidate critical values by tracking nerve changes.
    
    For general families, critical values occur where the nerve changes.
    We approximate by sampling thresholds densely.
    
    Complexity: O(n_thresholds · 2^m · N).
    
    Args:
        F: Tropical affine family  
        grid: Sample grid
        n_thresholds: Number of threshold samples
        
    Returns:
        List of approximate critical values
    """
    # Determine range
    all_vals = F.eval_all_grid(grid)
    c_min = float(np.min(all_vals)) - 1
    c_max = float(np.max(all_vals)) + 1
    
    thresholds = np.linspace(c_min, c_max, n_thresholds)
    
    critical_values = []
    prev_nerve = None
    
    for c in thresholds:
        nerve = compute_patch_nerve(F, c, grid)
        if prev_nerve is not None and nerve != prev_nerve:
            critical_values.append(float(c))
        prev_nerve = nerve
    
    return critical_values


# ============================================================================
# Algorithm 3: Connected Components of Nerve
# ============================================================================

def nerve_connected_components(
    faces: Set[FrozenSet[int]]
) -> int:
    """
    Count connected components of the 1-skeleton of the nerve.
    
    This corresponds to H₀ of the nerve, which by the nerve theorem
    equals H₀ of the sublevel set when patches are convex.
    
    Verified: The nerve is an abstract simplicial complex
    (patchNerve_down_closed), and its vertex count is ≤ m
    (nerveVertexCount_le).
    
    Complexity: O(|faces|) via union-find.
    
    Args:
        faces: Set of nerve faces
        
    Returns:
        Number of connected components
    """
    # Extract vertices
    vertices = set()
    for face in faces:
        if len(face) == 1:
            vertices.update(face)
    
    if not vertices:
        return 0
    
    # Union-Find
    parent = {v: v for v in vertices}
    rank = {v: 0 for v in vertices}
    
    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x
    
    def union(x, y):
        rx, ry = find(x), find(y)
        if rx == ry:
            return
        if rank[rx] < rank[ry]:
            rx, ry = ry, rx
        parent[ry] = rx
        if rank[rx] == rank[ry]:
            rank[rx] += 1
    
    # Union vertices connected by edges
    for face in faces:
        if len(face) >= 2:
            items = list(face)
            for i in range(1, len(items)):
                if items[0] in vertices and items[i] in vertices:
                    union(items[0], items[i])
    
    return len(set(find(v) for v in vertices))


# ============================================================================
# Algorithm 4: Euler Characteristic
# ============================================================================

def euler_characteristic(faces: Set[FrozenSet[int]]) -> int:
    """
    Compute Euler characteristic of an abstract simplicial complex.
    
    χ = Σ_σ (-1)^(dim σ) = Σ_σ (-1)^(|σ|-1)
    
    This is a topological invariant that equals
    χ = β₀ - β₁ + β₂ - ... where βₖ are Betti numbers.
    
    Verified: When the nerve is constant (NerveConstantOn),
    all combinatorial invariants including χ are preserved
    (follows from nerveVertexCount_eq_of_nerve_constant).
    
    Complexity: O(|faces|).
    
    Args:
        faces: Set of simplicial complex faces
        
    Returns:
        Euler characteristic
    """
    return sum((-1) ** (len(face) - 1) for face in faces)


# ============================================================================
# Algorithm 5: Full Nerve Filtration and Barcode Estimation
# ============================================================================

@dataclass
class NerveFiltrationResult:
    """Result of nerve filtration computation."""
    thresholds: np.ndarray
    nerves: List[Set[FrozenSet[int]]]
    component_counts: List[int]
    euler_chars: List[int]
    critical_values: List[float]
    h0_bars: List[Tuple[float, float]]  # (birth, death) pairs
    

def compute_nerve_filtration_full(
    F: TropicalAffineFamily,
    grid: np.ndarray,
    n_thresholds: int = 200
) -> NerveFiltrationResult:
    """
    Compute the full nerve filtration and extract H₀ barcode.
    
    Tracks connected components across thresholds to produce
    birth-death pairs for H₀ persistence.
    
    Verified properties used:
    - patchNerve_mono: nerve only grows
    - nerveVertexCount_le: at most m vertices
    - nerve_configurations_finite: at most 2^m faces
    
    Complexity: O(n_thresholds · 2^m · N).
    
    Args:
        F: Tropical affine family
        grid: Sample grid
        n_thresholds: Number of threshold samples
        
    Returns:
        NerveFiltrationResult with all computed data
    """
    all_vals = F.eval_all_grid(grid)
    c_min = float(np.min(all_vals)) - 1
    c_max = float(np.max(all_vals)) + 1
    
    thresholds = np.linspace(c_min, c_max, n_thresholds)
    
    nerves = []
    component_counts = []
    euler_chars = []
    critical_values = []
    prev_nerve = None
    
    for c in thresholds:
        nerve = compute_patch_nerve(F, c, grid)
        nerves.append(nerve)
        component_counts.append(nerve_connected_components(nerve))
        euler_chars.append(euler_characteristic(nerve))
        
        if prev_nerve is not None and nerve != prev_nerve:
            critical_values.append(float(c))
        prev_nerve = nerve
    
    # Extract H₀ bars from component count changes
    h0_bars = _extract_h0_bars(thresholds, component_counts)
    
    return NerveFiltrationResult(
        thresholds=thresholds,
        nerves=nerves,
        component_counts=component_counts,
        euler_chars=euler_chars,
        critical_values=critical_values,
        h0_bars=h0_bars
    )


def _extract_h0_bars(
    thresholds: np.ndarray,
    component_counts: List[int]
) -> List[Tuple[float, float]]:
    """
    Extract H₀ birth-death pairs from component count trajectory.
    
    A component birth occurs when count increases.
    A component death occurs when count decreases (merger).
    
    Returns list of (birth, death) pairs. Components alive at the
    end have death = +inf.
    """
    bars = []
    births = []  # stack of birth times
    
    prev_cc = 0
    for c, cc in zip(thresholds, component_counts):
        if cc > prev_cc:
            # New components born
            for _ in range(cc - prev_cc):
                births.append(float(c))
        elif cc < prev_cc:
            # Components died (merged)
            for _ in range(prev_cc - cc):
                if births:
                    birth = births.pop()
                    bars.append((birth, float(c)))
        prev_cc = cc
    
    # Remaining components live forever
    for birth in births:
        bars.append((birth, float('inf')))
    
    return bars


# ============================================================================
# Algorithm 6: Active Set Universe
# ============================================================================

def compute_active_set_universe(
    F: TropicalAffineFamily,
    grid: np.ndarray,
    c: float
) -> Set[FrozenSet[int]]:
    """
    Compute the set of all active sets realized in the min sublevel set.
    
    For each grid point x with min_i f_i(x) ≤ c, compute the set of
    indices achieving the minimum.
    
    Args:
        F: Tropical affine family
        grid: Sample grid
        c: Threshold
        
    Returns:
        Set of realized active sets
    """
    all_vals = F.eval_all_grid(grid)  # (m, N)
    min_vals = np.min(all_vals, axis=0)  # (N,)
    
    active_sets = set()
    sublevel_mask = min_vals <= c
    
    for j in np.where(sublevel_mask)[0]:
        min_val = min_vals[j]
        active = frozenset(i for i in range(F.m) 
                          if abs(all_vals[i, j] - min_val) < 1e-10)
        active_sets.add(active)
    
    return active_sets


# ============================================================================
# Example Usage
# ============================================================================

if __name__ == "__main__":
    print("Tropical Persistent Homology — Algorithm Examples")
    print("=" * 50)
    
    # Example family
    F = TropicalAffineFamily(
        coeffs=np.array([[1, 0], [-1, 0], [0, 1], [0, -1]]),
        biases=np.array([-1, -2, -1, -3])
    )
    
    grid = np.mgrid[-8:8:0.1, -8:8:0.1].reshape(2, -1).T
    
    # Compute full filtration
    result = compute_nerve_filtration_full(F, grid, n_thresholds=100)
    
    print(f"\nFamily: {F.m} forms in R^{F.n}")
    print(f"Critical values: {len(result.critical_values)}")
    print(f"H₀ bars: {len(result.h0_bars)}")
    for birth, death in result.h0_bars:
        death_str = f"{death:.2f}" if death < float('inf') else "∞"
        print(f"  [{birth:.2f}, {death_str})")
    
    print(f"\nEuler characteristic range: "
          f"[{min(result.euler_chars)}, {max(result.euler_chars)}]")
    print(f"Max components: {max(result.component_counts)}")
    
    # Verify vertex count bound
    for i, nerve in enumerate(result.nerves):
        verts = sum(1 for f in nerve if len(f) == 1)
        assert verts <= F.m, f"Vertex count {verts} > m={F.m}!"
    print(f"\n✓ Vertex count ≤ m = {F.m} verified for all thresholds")
    
    # Verify nerve monotonicity
    for i in range(1, len(result.nerves)):
        assert result.nerves[i-1].issubset(result.nerves[i]), \
            f"Nerve not monotone at threshold {i}!"
    print(f"✓ Nerve monotonicity verified for all thresholds")
    
    # Check active set universe
    active_universe = compute_active_set_universe(F, grid, c=0.0)
    print(f"\nActive set universe at c=0: {len(active_universe)} sets")
    print(f"Bound: 2^m = {2**F.m}")
