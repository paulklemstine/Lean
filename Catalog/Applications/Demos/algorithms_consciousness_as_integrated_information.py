"""
Integrated Information Theory: Core Algorithms

Type-hinted implementations of IIT's algebraic framework, including:
- Causal mechanism representation
- Cut weight computation
- Phi (integrated information) computation
- Integration defect analysis
"""

from __future__ import annotations
from itertools import combinations
from typing import List, Tuple, Optional
import math


class CausalMechanism:
    """A causal mechanism on a finite state space.
    
    Represented as a weight matrix where weight[i][j] is the strength
    of causal influence from state i to state j.
    """
    
    def __init__(self, weights: List[List[float]]) -> None:
        n = len(weights)
        for row in weights:
            if len(row) != n:
                raise ValueError("Weight matrix must be square")
            for w in row:
                if w < 0:
                    raise ValueError("Weights must be non-negative")
        self.n = n
        self.weights = [row[:] for row in weights]
    
    def weight(self, i: int, j: int) -> float:
        """Causal weight from state i to state j."""
        return self.weights[i][j]
    
    def total_weight(self) -> float:
        """Sum of all causal weights."""
        return sum(self.weights[i][j] for i in range(self.n) for j in range(self.n))
    
    def cut_weight(self, subset: frozenset[int]) -> float:
        """Bidirectional cut weight for a partition {subset, complement}.
        
        Sums all weights from subset to complement and from complement to subset.
        """
        complement = frozenset(range(self.n)) - subset
        forward = sum(self.weights[i][j] for i in subset for j in complement)
        backward = sum(self.weights[i][j] for i in complement for j in subset)
        return forward + backward
    
    def nontrivial_subsets(self) -> List[frozenset[int]]:
        """All nontrivial subsets: both subset and complement are nonempty."""
        result: List[frozenset[int]] = []
        for size in range(1, self.n):
            for combo in combinations(range(self.n), size):
                result.append(frozenset(combo))
        return result
    
    def phi(self) -> float:
        """Integrated information Φ: minimum cut weight over all nontrivial bipartitions.
        
        Returns 0.0 if the state space has fewer than 2 elements.
        """
        if self.n < 2:
            return 0.0
        subsets = self.nontrivial_subsets()
        return min(self.cut_weight(s) for s in subsets)
    
    def phi_partition(self) -> Tuple[float, Optional[frozenset[int]]]:
        """Returns (Φ, minimizing partition)."""
        if self.n < 2:
            return 0.0, None
        subsets = self.nontrivial_subsets()
        best_s = min(subsets, key=lambda s: self.cut_weight(s))
        return self.cut_weight(best_s), best_s
    
    def integration_defect(self) -> float:
        """Integration defect D = W - Φ. Measures wasted causal potential."""
        return self.total_weight() - self.phi()
    
    def efficiency(self) -> float:
        """Integration efficiency Φ/W. Ratio of integration to total weight."""
        w = self.total_weight()
        if w == 0:
            return 0.0
        return self.phi() / w
    
    def is_symmetric(self) -> bool:
        """Check if the mechanism is symmetric: w(i,j) = w(j,i)."""
        return all(
            abs(self.weights[i][j] - self.weights[j][i]) < 1e-12
            for i in range(self.n) for j in range(self.n)
        )
    
    def has_zero_cut(self) -> bool:
        """Check if any nontrivial partition has zero cut weight."""
        return any(self.cut_weight(s) < 1e-12 for s in self.nontrivial_subsets())
    
    @staticmethod
    def add(m1: 'CausalMechanism', m2: 'CausalMechanism') -> 'CausalMechanism':
        """Pointwise sum of two mechanisms."""
        if m1.n != m2.n:
            raise ValueError("Mechanisms must have same size")
        weights = [[m1.weights[i][j] + m2.weights[i][j] 
                     for j in range(m1.n)] for i in range(m1.n)]
        return CausalMechanism(weights)
    
    @staticmethod
    def scale(c: float, m: 'CausalMechanism') -> 'CausalMechanism':
        """Scale a mechanism by a non-negative constant."""
        if c < 0:
            raise ValueError("Scale factor must be non-negative")
        weights = [[c * m.weights[i][j] for j in range(m.n)] for i in range(m.n)]
        return CausalMechanism(weights)
    
    @staticmethod
    def zero(n: int) -> 'CausalMechanism':
        """Zero mechanism on n states."""
        return CausalMechanism([[0.0] * n for _ in range(n)])
    
    @staticmethod
    def complete(n: int, w: float = 1.0) -> 'CausalMechanism':
        """Complete graph mechanism with uniform weight w."""
        weights = [[w if i != j else 0.0 for j in range(n)] for i in range(n)]
        return CausalMechanism(weights)
    
    @staticmethod
    def path(n: int, w: float = 1.0) -> 'CausalMechanism':
        """Path graph mechanism with uniform weight w."""
        weights = [[0.0] * n for _ in range(n)]
        for i in range(n - 1):
            weights[i][i + 1] = w
            weights[i + 1][i] = w
        return CausalMechanism(weights)
    
    @staticmethod
    def cycle(n: int, w: float = 1.0) -> 'CausalMechanism':
        """Cycle graph mechanism with uniform weight w."""
        m = CausalMechanism.path(n, w)
        if n >= 3:
            m.weights[0][n - 1] = w
            m.weights[n - 1][0] = w
        return m


def verify_superadditivity(m1: CausalMechanism, m2: CausalMechanism) -> dict:
    """Verify superadditivity: Φ(M₁+M₂) ≥ Φ(M₁) + Φ(M₂)."""
    combined = CausalMechanism.add(m1, m2)
    phi1, phi2, phi_combined = m1.phi(), m2.phi(), combined.phi()
    return {
        "phi_m1": phi1,
        "phi_m2": phi2,
        "phi_sum": phi1 + phi2,
        "phi_combined": phi_combined,
        "superadditive": phi_combined >= phi1 + phi2 - 1e-12,
        "excess": phi_combined - (phi1 + phi2),
    }


def verify_scaling(c: float, m: CausalMechanism) -> dict:
    """Verify scaling: Φ(c·M) = c·Φ(M)."""
    scaled = CausalMechanism.scale(c, m)
    phi_m, phi_scaled = m.phi(), scaled.phi()
    return {
        "c": c,
        "phi_m": phi_m,
        "c_times_phi": c * phi_m,
        "phi_scaled": phi_scaled,
        "matches": abs(phi_scaled - c * phi_m) < 1e-10,
    }


def verify_defect_subadditivity(m1: CausalMechanism, m2: CausalMechanism) -> dict:
    """Verify defect subadditivity: D(M₁+M₂) ≤ D(M₁) + D(M₂)."""
    combined = CausalMechanism.add(m1, m2)
    d1 = m1.integration_defect()
    d2 = m2.integration_defect()
    d_combined = combined.integration_defect()
    return {
        "defect_m1": d1,
        "defect_m2": d2,
        "defect_sum": d1 + d2,
        "defect_combined": d_combined,
        "subadditive": d_combined <= d1 + d2 + 1e-12,
        "savings": (d1 + d2) - d_combined,
    }


def find_exclusion_maximum(mechanisms: List[CausalMechanism]) -> Tuple[int, float]:
    """Find the mechanism with maximum Φ (exclusion principle)."""
    if not mechanisms:
        raise ValueError("Need at least one mechanism")
    phis = [m.phi() for m in mechanisms]
    idx = max(range(len(phis)), key=lambda i: phis[i])
    return idx, phis[idx]


def integration_profile(m: CausalMechanism) -> dict:
    """Complete integration analysis of a mechanism."""
    phi_val, partition = m.phi_partition()
    return {
        "n_states": m.n,
        "total_weight": m.total_weight(),
        "phi": phi_val,
        "minimizing_partition": sorted(partition) if partition else None,
        "complement": sorted(frozenset(range(m.n)) - partition) if partition else None,
        "integration_defect": m.integration_defect(),
        "efficiency": m.efficiency(),
        "is_symmetric": m.is_symmetric(),
        "is_disconnected": m.has_zero_cut(),
    }
