#!/usr/bin/env python3
"""
Tropical KAM Stability — Algorithms

Implements the core algorithms for tropical KAM stability analysis:

1. TropicalDiophantineChecker: Verify the Diophantine condition for frequency vectors
2. ResonanceProfileComputer: Compute and compare resonance profiles
3. SubdivisionDetector: Detect whether a perturbation preserves regular subdivisions
4. RotationVectorEstimator: Estimate tropical rotation vectors from orbit data
"""

import numpy as np
from typing import List, Tuple, Optional, Set, Dict, FrozenSet
from fractions import Fraction
from itertools import product as iproduct
from collections import defaultdict


# ============================================================
# Algorithm 1: Tropical Diophantine Checker
# ============================================================

class TropicalDiophantineChecker:
    """
    Verifies the Tropical Diophantine condition for a frequency vector.
    
    A frequency vector ω ∈ ℝⁿ is TropicalDiophantine(K, C) if:
        ∀ k ∈ ℤⁿ, 0 < ||k||₁ ≤ K  ⟹  C ≤ |⟨k, ω⟩|
    
    Time complexity: O(K^n) where n is the dimension
    Space complexity: O(n) per vector
    
    Example usage:
        >>> checker = TropicalDiophantineChecker(dimension=2)
        >>> omega = np.array([1.0, (1 + np.sqrt(5)) / 2])
        >>> result = checker.check(omega, K=10, C=0.05)
        >>> print(result)
    """
    
    def __init__(self, dimension: int):
        self.n = dimension
        self._vector_cache: Dict[int, List[np.ndarray]] = {}
    
    def _get_vectors(self, norm: int) -> List[np.ndarray]:
        """Get all integer vectors with L1 norm exactly `norm`."""
        if norm in self._vector_cache:
            return self._vector_cache[norm]
        
        vectors = []
        self._enumerate_vectors(norm, self.n, [], vectors)
        self._vector_cache[norm] = vectors
        return vectors
    
    def _enumerate_vectors(self, remaining: int, dims_left: int,
                           current: list, result: list):
        """Recursively enumerate integer vectors of given L1 norm."""
        if dims_left == 0:
            if remaining == 0:
                result.append(np.array(current, dtype=int))
            return
        
        for abs_val in range(remaining + 1):
            if abs_val == 0:
                self._enumerate_vectors(remaining, dims_left - 1,
                                       current + [0], result)
            else:
                for sign in [1, -1]:
                    self._enumerate_vectors(remaining - abs_val, dims_left - 1,
                                           current + [sign * abs_val], result)
    
    def check(self, omega: np.ndarray, K: int, C: float) -> dict:
        """
        Check if omega is TropicalDiophantine(K, C).
        
        Returns:
            dict with keys:
                'is_diophantine': bool
                'min_gap': float (minimum |<k, omega>| over nonzero k with ||k||_1 <= K)
                'violating_vector': Optional[np.ndarray]
                'gap_by_norm': dict mapping norm -> minimum gap at that norm
        """
        min_gap = float('inf')
        worst_k = None
        gap_by_norm = {}
        violating_vector = None
        
        for norm in range(1, K + 1):
            norm_min_gap = float('inf')
            for k in self._get_vectors(norm):
                val = abs(float(np.dot(k.astype(float), omega)))
                if val < norm_min_gap:
                    norm_min_gap = val
                if val < min_gap:
                    min_gap = val
                    worst_k = k.copy()
                if val < C and violating_vector is None:
                    violating_vector = k.copy()
            gap_by_norm[norm] = norm_min_gap
        
        return {
            'is_diophantine': min_gap >= C,
            'min_gap': min_gap,
            'violating_vector': violating_vector,
            'worst_vector': worst_k,
            'gap_by_norm': gap_by_norm,
            'rigidity_bound': min_gap / (2 * K) if K > 0 else float('inf'),
        }
    
    def find_optimal_C(self, omega: np.ndarray, K: int) -> float:
        """Find the largest C such that omega is TropicalDiophantine(K, C)."""
        result = self.check(omega, K, 0.0)
        return result['min_gap']


# ============================================================
# Algorithm 2: Resonance Profile Computer
# ============================================================

class ResonanceProfileComputer:
    """
    Computes and compares resonance profiles of frequency vectors.
    
    The resonance profile of ω at scale K is the set of lattice vectors
    k with ||k||_1 ≤ K such that ⟨k, ω⟩ = 0 (within tolerance).
    
    Time complexity: O(K^n) for profile computation
    Space complexity: O(K^n) for storing the profile
    
    Example usage:
        >>> computer = ResonanceProfileComputer(dimension=2, tolerance=1e-10)
        >>> omega = np.array([1.0, 0.5])
        >>> profile = computer.compute_profile(omega, K=5)
    """
    
    def __init__(self, dimension: int, tolerance: float = 1e-10):
        self.n = dimension
        self.tol = tolerance
        self._checker = TropicalDiophantineChecker(dimension)
    
    def compute_profile(self, omega: np.ndarray, K: int) -> Set[Tuple[int, ...]]:
        """
        Compute the resonance profile: set of k with <k,omega> ≈ 0 and ||k||_1 ≤ K.
        """
        resonances = set()
        for norm in range(1, K + 1):
            for k in self._checker._get_vectors(norm):
                val = abs(float(np.dot(k.astype(float), omega)))
                if val < self.tol:
                    resonances.add(tuple(k))
        return resonances
    
    def same_profile(self, omega1: np.ndarray, omega2: np.ndarray,
                     K: int) -> Tuple[bool, Optional[np.ndarray]]:
        """
        Check if two frequency vectors have the same resonance profile.
        
        Returns (True, None) if profiles match, (False, distinguishing_k) otherwise.
        """
        prof1 = self.compute_profile(omega1, K)
        prof2 = self.compute_profile(omega2, K)
        
        diff = prof1.symmetric_difference(prof2)
        if not diff:
            return True, None
        
        k = np.array(list(diff)[0], dtype=int)
        return False, k
    
    def verify_rigidity_theorem(self, omega: np.ndarray, K: int, C: float,
                                num_trials: int = 100) -> dict:
        """
        Empirically verify the resonance rigidity theorem.
        
        For random perturbations within the rigidity bound C/(2K),
        checks that the resonance profile is preserved.
        """
        bound = C / (2 * K)
        successes = 0
        failures = 0
        
        for _ in range(num_trials):
            delta = np.random.uniform(-bound * 0.99, bound * 0.99, size=self.n)
            omega_pert = omega + delta
            same, _ = self.same_profile(omega, omega_pert, K)
            if same:
                successes += 1
            else:
                failures += 1
        
        return {
            'bound': bound,
            'trials': num_trials,
            'successes': successes,
            'failures': failures,
            'theorem_holds': failures == 0,
        }


# ============================================================
# Algorithm 3: Subdivision Detector
# ============================================================

class SubdivisionDetector:
    """
    Detects whether a perturbation of tropical polynomial coefficients
    preserves the induced regular subdivision of the Newton polytope.
    
    A tropical polynomial f(x) = max_{α ∈ A} (c_α + α·x) induces a
    regular subdivision of the Newton polytope conv(A) via the upper
    convex hull of the lifted points (α, c_α).
    
    Time complexity: O(|A|² · G) where G is grid resolution
    Space complexity: O(|A| · G)
    
    Example usage:
        >>> detector = SubdivisionDetector()
        >>> support = [(0,0), (1,0), (0,1), (1,1)]
        >>> coeffs1 = [0.0, 1.0, 1.0, 0.5]
        >>> coeffs2 = [0.1, 1.1, 1.1, 0.6]
        >>> detector.preserves_subdivision(support, coeffs1, coeffs2)
    """
    
    def __init__(self, grid_resolution: int = 100):
        self.grid_res = grid_resolution
    
    def compute_subdivision(self, support: List[Tuple[int, ...]],
                           coefficients: List[float],
                           sample_range: Tuple[float, float] = (-5, 5)
                           ) -> Dict[FrozenSet[int], int]:
        """
        Compute the regular subdivision induced by a tropical polynomial.
        
        Returns a dictionary mapping cells (as frozensets of achieving indices)
        to their approximate area (number of grid points).
        """
        n_support = len(support)
        lo, hi = sample_range
        cells: Dict[FrozenSet[int], int] = defaultdict(int)
        
        xs = np.linspace(lo, hi, self.grid_res)
        ys = np.linspace(lo, hi, self.grid_res)
        
        for x in xs:
            for y in ys:
                vals = [coefficients[i] + support[i][0] * x + support[i][1] * y
                        for i in range(n_support)]
                max_val = max(vals)
                achievers = frozenset(i for i in range(n_support)
                                     if abs(vals[i] - max_val) < 1e-10)
                cells[achievers] += 1
        
        return dict(cells)
    
    def preserves_subdivision(self, support: List[Tuple[int, ...]],
                             coeffs1: List[float],
                             coeffs2: List[float]) -> Tuple[bool, dict]:
        """
        Check if two sets of coefficients induce the same regular subdivision.
        
        Returns (True, info) if subdivisions match, (False, info) otherwise.
        """
        sub1 = self.compute_subdivision(support, coeffs1)
        sub2 = self.compute_subdivision(support, coeffs2)
        
        cells1 = set(sub1.keys())
        cells2 = set(sub2.keys())
        
        same = cells1 == cells2
        
        return same, {
            'cells_original': len(cells1),
            'cells_perturbed': len(cells2),
            'cells_in_common': len(cells1 & cells2),
            'cells_only_original': cells1 - cells2,
            'cells_only_perturbed': cells2 - cells1,
        }


# ============================================================
# Algorithm 4: Rotation Vector Estimator
# ============================================================

class RotationVectorEstimator:
    """
    Estimates the tropical rotation vector from orbit data on a tropical torus.
    
    Given a sequence of points on a tropical torus (represented as ℝⁿ/ℤⁿ),
    estimates the rotation vector by averaging displacements.
    
    Time complexity: O(T · n) where T is orbit length
    Space complexity: O(T · n)
    
    Example usage:
        >>> estimator = RotationVectorEstimator(dimension=2)
        >>> orbit = [np.array([0.0, 0.0]), np.array([0.618, 0.414]), ...]
        >>> omega = estimator.estimate(orbit)
    """
    
    def __init__(self, dimension: int):
        self.n = dimension
    
    def estimate(self, orbit: List[np.ndarray],
                 method: str = 'average') -> np.ndarray:
        """
        Estimate the rotation vector from an orbit sequence.
        
        Methods:
            'average': Average of consecutive displacements
            'regression': Linear regression on cumulative displacement
        """
        if len(orbit) < 2:
            return np.zeros(self.n)
        
        if method == 'average':
            displacements = []
            for i in range(1, len(orbit)):
                disp = orbit[i] - orbit[i-1]
                # Reduce modulo 1 to handle torus wrapping
                disp = disp - np.round(disp)
                displacements.append(disp)
            return np.mean(displacements, axis=0)
        
        elif method == 'regression':
            T = len(orbit)
            times = np.arange(T)
            omega = np.zeros(self.n)
            
            for j in range(self.n):
                # Unwrap the j-th coordinate
                coords = np.array([orbit[t][j] for t in range(T)])
                unwrapped = np.unwrap(coords * 2 * np.pi) / (2 * np.pi)
                
                # Linear regression
                A = np.vstack([times, np.ones(T)]).T
                result = np.linalg.lstsq(A, unwrapped, rcond=None)
                omega[j] = result[0][0]
            
            return omega
        
        raise ValueError(f"Unknown method: {method}")
    
    def generate_orbit(self, omega: np.ndarray, T: int,
                       x0: Optional[np.ndarray] = None) -> List[np.ndarray]:
        """Generate an orbit of a tropical rotation with frequency omega."""
        if x0 is None:
            x0 = np.zeros(self.n)
        
        orbit = [x0.copy()]
        x = x0.copy()
        for _ in range(T):
            x = (x + omega) % 1.0
            orbit.append(x.copy())
        
        return orbit


# ============================================================
# Example Usage and Testing
# ============================================================

if __name__ == "__main__":
    print("=" * 70)
    print("TROPICAL KAM STABILITY — Algorithm Demonstrations")
    print("=" * 70)
    
    # Algorithm 1: Diophantine Checker
    print("\n--- Algorithm 1: Tropical Diophantine Checker ---")
    checker = TropicalDiophantineChecker(dimension=2)
    
    phi = (1 + np.sqrt(5)) / 2
    omega = np.array([1.0, phi])
    result = checker.check(omega, K=10, C=0.05)
    print(f"ω = [1, φ]: Diophantine(10, 0.05) = {result['is_diophantine']}")
    print(f"  Minimum gap: {result['min_gap']:.6f}")
    print(f"  Rigidity bound: {result['rigidity_bound']:.6f}")
    print(f"  Gap by norm: { {k: f'{v:.4f}' for k, v in list(result['gap_by_norm'].items())[:5]} }")
    
    C_opt = checker.find_optimal_C(omega, K=10)
    print(f"  Optimal C for K=10: {C_opt:.6f}")
    
    # Algorithm 2: Resonance Profile
    print("\n--- Algorithm 2: Resonance Profile Computer ---")
    computer = ResonanceProfileComputer(dimension=2)
    
    omega_rat = np.array([1.0, 0.5])
    profile = computer.compute_profile(omega_rat, K=5)
    print(f"ω = [1, 0.5]: Resonances at K=5: {profile}")
    
    rigidity = computer.verify_rigidity_theorem(omega, K=8, C=0.05, num_trials=200)
    print(f"ω = [1, φ]: Rigidity verification (K=8, C=0.05)")
    print(f"  Trials: {rigidity['trials']}, Successes: {rigidity['successes']}, "
          f"Failures: {rigidity['failures']}")
    print(f"  Theorem holds: {rigidity['theorem_holds']}")
    
    # Algorithm 3: Subdivision Detector
    print("\n--- Algorithm 3: Subdivision Detector ---")
    detector = SubdivisionDetector(grid_resolution=50)
    
    support = [(0, 0), (2, 0), (0, 2), (1, 1)]
    coeffs1 = [0.0, -1.0, -1.0, -0.5]
    coeffs2 = [0.1, -0.9, -0.9, -0.4]  # uniform shift
    coeffs3 = [0.0, -1.0, -1.0, 1.5]   # changes subdivision
    
    same12, info12 = detector.preserves_subdivision(support, coeffs1, coeffs2)
    same13, info13 = detector.preserves_subdivision(support, coeffs1, coeffs3)
    
    print(f"Uniform shift preserves subdivision: {same12} (cells: {info12['cells_original']})")
    print(f"Large perturbation preserves subdivision: {same13} "
          f"(orig cells: {info13['cells_original']}, pert cells: {info13['cells_perturbed']})")
    
    # Algorithm 4: Rotation Vector Estimator
    print("\n--- Algorithm 4: Rotation Vector Estimator ---")
    estimator = RotationVectorEstimator(dimension=2)
    
    omega_true = np.array([phi - 1, np.sqrt(2) - 1])
    orbit = estimator.generate_orbit(omega_true, T=1000)
    omega_est = estimator.estimate(orbit, method='average')
    
    print(f"True ω: {omega_true}")
    print(f"Estimated ω (T=1000): {omega_est}")
    print(f"Error: {np.max(np.abs(omega_true - omega_est)):.2e}")
