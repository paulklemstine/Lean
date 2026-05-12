#!/usr/bin/env python3
"""
Algorithms for Ultrametric Observer Rate-Distortion Theory

Implements the core algorithms from the formalized theory:
1. Greedy codebook construction (O(n² · k) where k = #observers)
2. Congruence class computation via Union-Find (O(n² · k · α(n)))
3. Rate-distortion spectrum computation
4. Critical scale extraction
5. Compression spectrum comparison

All algorithms have formal correctness guarantees backed by the
Lean 4 proofs in UltrametricProofObserverRateDistortion.lean.
"""

from typing import List, Dict, Tuple, Set, Optional, Callable
from dataclasses import dataclass, field
from collections import defaultdict
import numpy as np


@dataclass
class UltrametricObserverFamily:
    """A family of ultrametric observer distance functions.
    
    Each observer O_i : P × P → R≥0 satisfies:
    - O_i(x, x) = 0  (diagonal zero)
    - O_i(x, y) = O_i(y, x)  (symmetry)
    - O_i(x, z) ≤ max(O_i(x, y), O_i(y, z))  (ultrametric inequality)
    
    Attributes:
        n_points: Number of proof states |P|
        observers: List of distance matrices, one per observer
    """
    n_points: int
    observers: List[np.ndarray]
    
    def __post_init__(self):
        for k, obs in enumerate(self.observers):
            assert obs.shape == (self.n_points, self.n_points), \
                f"Observer {k} has wrong shape"
            assert np.allclose(np.diag(obs), 0), \
                f"Observer {k} violates diagonal zero"
            assert np.allclose(obs, obs.T), \
                f"Observer {k} violates symmetry"
    
    @property
    def n_observers(self) -> int:
        return len(self.observers)
    
    def distortion(self, p: int, q: int) -> float:
        """Observer distortion: max over all observers."""
        if not self.observers:
            return 0.0
        return max(obs[p, q] for obs in self.observers)
    
    def distortion_matrix(self) -> np.ndarray:
        """Full observer distortion matrix."""
        if not self.observers:
            return np.zeros((self.n_points, self.n_points))
        return np.max(np.stack(self.observers), axis=0)


class UnionFind:
    """Union-Find data structure with path compression and union by rank.
    
    Time complexity: O(α(n)) amortized per operation,
    where α is the inverse Ackermann function.
    """
    
    def __init__(self, n: int):
        self.parent = list(range(n))
        self.rank = [0] * n
        self.size = [1] * n
        self.n_components = n
    
    def find(self, x: int) -> int:
        while self.parent[x] != x:
            self.parent[x] = self.parent[self.parent[x]]
            x = self.parent[x]
        return x
    
    def union(self, x: int, y: int) -> bool:
        px, py = self.find(x), self.find(y)
        if px == py:
            return False
        if self.rank[px] < self.rank[py]:
            px, py = py, px
        self.parent[py] = px
        self.size[px] += self.size[py]
        if self.rank[px] == self.rank[py]:
            self.rank[px] += 1
        self.n_components -= 1
        return True
    
    def components(self) -> Dict[int, List[int]]:
        groups = defaultdict(list)
        for i in range(len(self.parent)):
            groups[self.find(i)].append(i)
        return dict(groups)


def compute_congruence_classes(
    family: UltrametricObserverFamily, 
    epsilon: float
) -> List[List[int]]:
    """Compute equivalence classes under observer ε-congruence.
    
    Two points p, q are ε-congruent iff δ_O(p, q) ≤ ε,
    where δ_O = max over observers.
    
    In ultrametric spaces, this is a genuine equivalence relation
    (transitivity follows from the strong triangle inequality).
    
    Time: O(n² · k) where k = number of observers
    Space: O(n)
    
    Returns:
        List of equivalence classes (each a list of point indices)
    """
    n = family.n_points
    uf = UnionFind(n)
    
    for i in range(n):
        for j in range(i + 1, n):
            if family.distortion(i, j) <= epsilon + 1e-12:
                uf.union(i, j)
    
    return list(uf.components().values())


def greedy_codebook(
    family: UltrametricObserverFamily, 
    epsilon: float
) -> List[int]:
    """Construct a certified optimal ε-codebook.
    
    THEOREM (greedy_ultrametric_codebook_certified):
    The returned codebook C satisfies:
    1. ObserverCovers: every point p has some c ∈ C with δ_O(p, c) ≤ ε
    2. Optimality: |C| = N_O(ε) = number of ε-congruence classes
    
    Algorithm: Pick one representative from each congruence class.
    
    Time: O(n² · k) for congruence computation
    Space: O(n)
    
    Returns:
        List of codebook point indices (one per congruence class)
    """
    classes = compute_congruence_classes(family, epsilon)
    return [cls[0] for cls in classes]


def compute_critical_scales(family: UltrametricObserverFamily) -> List[float]:
    """Extract the critical scales (compression breakpoints).
    
    These are all distinct pairwise observer distortion values.
    The covering number changes only at these thresholds.
    
    THEOREM (observerCoverCard_constant_between_critical):
    Between consecutive critical scales, the covering number is constant.
    
    Time: O(n² · k)
    Space: O(n²) worst case
    
    Returns:
        Sorted list of critical scale values
    """
    n = family.n_points
    scales = set()
    for i in range(n):
        for j in range(i + 1, n):
            scales.add(family.distortion(i, j))
    return sorted(scales)


@dataclass
class CompressionSpectrum:
    """The compression spectrum of an observer family.
    
    Encodes the complete rate-distortion profile as a step function:
    - critical_scales: the ε values where the covering number changes
    - covering_numbers: N(ε) at each critical scale (and ε=0)
    - rates: R(ε) = log(N(ε)) at each critical scale
    
    THEOREM (finite_ultrametric_covering_number_eq_congruence_index):
    Each covering number equals the congruence class count.
    
    THEOREM (observerCoverCard_antitone):
    The covering numbers are monotonically non-increasing.
    """
    critical_scales: List[float]
    covering_numbers: List[int]
    rates: List[float]
    
    def evaluate_N(self, epsilon: float) -> int:
        """Evaluate covering number at arbitrary ε."""
        for i, s in enumerate(self.critical_scales):
            if epsilon < s - 1e-12:
                return self.covering_numbers[i]
        return self.covering_numbers[-1] if self.covering_numbers else 1
    
    def evaluate_R(self, epsilon: float) -> float:
        """Evaluate rate function at arbitrary ε."""
        N = self.evaluate_N(epsilon)
        return np.log(N) if N > 0 else 0.0


def compute_compression_spectrum(
    family: UltrametricObserverFamily
) -> CompressionSpectrum:
    """Compute the full compression spectrum.
    
    Time: O(n² · k · S) where S = number of critical scales (≤ n²)
    
    Returns:
        CompressionSpectrum containing the step function data
    """
    critical = compute_critical_scales(family)
    
    # Compute covering number at ε=0 and at each critical scale
    scales = [0.0] + critical
    numbers = []
    rates = []
    
    for eps in scales:
        classes = compute_congruence_classes(family, eps)
        n = len(classes)
        numbers.append(n)
        rates.append(np.log(n) if n > 0 else 0.0)
    
    return CompressionSpectrum(
        critical_scales=scales,
        covering_numbers=numbers,
        rates=rates
    )


def verify_ultrametric(d: np.ndarray, tol: float = 1e-10) -> bool:
    """Verify that a distance matrix satisfies the ultrametric inequality.
    
    Checks: d(x,z) ≤ max(d(x,y), d(y,z)) for all x, y, z.
    
    Time: O(n³)
    """
    n = d.shape[0]
    for i in range(n):
        for j in range(n):
            for k in range(n):
                if d[i, k] > max(d[i, j], d[j, k]) + tol:
                    return False
    return True


def compare_spectra(
    s1: CompressionSpectrum, 
    s2: CompressionSpectrum
) -> Dict[str, any]:
    """Compare two compression spectra.
    
    Returns a dictionary with:
    - 'equal': whether the spectra are identical
    - 'max_rate_diff': maximum difference in rate functions
    - 'breakpoint_diff': symmetric difference of critical scales
    """
    all_scales = sorted(set(s1.critical_scales + s2.critical_scales))
    
    max_diff = 0.0
    for eps in all_scales:
        diff = abs(s1.evaluate_R(eps) - s2.evaluate_R(eps))
        max_diff = max(max_diff, diff)
    
    bp1 = set(round(s, 10) for s in s1.critical_scales)
    bp2 = set(round(s, 10) for s in s2.critical_scales)
    
    return {
        'equal': max_diff < 1e-10,
        'max_rate_diff': max_diff,
        'breakpoint_symmetric_diff': bp1.symmetric_difference(bp2),
        'n_breakpoints_1': len(s1.critical_scales),
        'n_breakpoints_2': len(s2.critical_scales),
    }


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    print("Ultrametric Observer Rate-Distortion Algorithms")
    print("=" * 60)
    
    # Create example ultrametric space
    n = 6
    # Manual ultrametric: points organized in a tree
    # Tree: ((0,1), (2,3)), ((4,5))
    # Heights: 1 (leaves), 3 (mid), 5 (root)
    d = np.zeros((n, n))
    for i, j, h in [(0,1,1), (2,3,1), (4,5,2), (0,2,3), (0,3,3), (1,2,3), (1,3,3),
                     (0,4,5), (0,5,5), (1,4,5), (1,5,5), (2,4,5), (2,5,5), (3,4,5), (3,5,5)]:
        d[i,j] = d[j,i] = h
    
    print(f"Ultrametric verified: {verify_ultrametric(d)}")
    
    # Create observers (scaled versions of d)
    obs1 = d * 0.8
    obs2 = d * 0.6
    for o in [obs1, obs2]:
        np.fill_diagonal(o, 0)
    
    family = UltrametricObserverFamily(n, [obs1, obs2])
    
    # Compute spectrum
    spectrum = compute_compression_spectrum(family)
    print(f"\nCompression Spectrum:")
    print(f"  Critical scales: {spectrum.critical_scales}")
    print(f"  Covering numbers: {spectrum.covering_numbers}")
    print(f"  Rates: {[f'{r:.3f}' for r in spectrum.rates]}")
    
    # Greedy codebook at various scales
    for eps in [0.5, 1.5, 3.0, 5.0]:
        codebook = greedy_codebook(family, eps)
        print(f"\n  ε={eps}: codebook={codebook}, size={len(codebook)}, "
              f"spectrum N(ε)={spectrum.evaluate_N(eps)}")
