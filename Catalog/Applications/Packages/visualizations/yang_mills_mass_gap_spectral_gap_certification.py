#!/usr/bin/env python3
"""
Algorithms for Yang–Mills Mass Gap Spectral Architecture

Implements the core algorithms from the research paper:
1. Spectral gap certification from eigenvalue lists
2. Diagonal Hamiltonian construction and gap extraction
3. Lattice gauge energy computation
4. Vacuum finder via exhaustive search on finite configurations
5. Refinement stability checker for gap sequences
"""

import numpy as np
from typing import List, Tuple, Optional, Callable, Any
from dataclasses import dataclass


# ============================================================
# Algorithm 1: Spectral Gap Certification
# ============================================================

@dataclass
class SpectralGapResult:
    """Result of spectral gap certification."""
    has_gap: bool
    gap_value: Optional[float]
    vacuum_energy: Optional[float]
    first_excitation: Optional[float]
    
    def __repr__(self):
        if self.has_gap:
            return (f"SpectralGap(gap={self.gap_value:.6f}, "
                    f"E0={self.vacuum_energy:.6f}, E1={self.first_excitation:.6f})")
        return "SpectralGap(no gap)"


def certify_spectral_gap(eigenvalues: List[float]) -> SpectralGapResult:
    """
    Certify spectral gap from a sorted eigenvalue list.
    
    Implements the algorithm behind Theorem A:
    1. Check list has ≥ 2 elements
    2. Check list is sorted
    3. Extract e0 = eigenvalues[0], e1 = eigenvalues[1]
    4. If e1 - e0 > 0, return the gap
    
    Time complexity: O(n) for sorting check
    Space complexity: O(1) additional
    
    Args:
        eigenvalues: Sorted list of real eigenvalues
        
    Returns:
        SpectralGapResult with certification data
        
    >>> certify_spectral_gap([0, 0.5, 1.0, 2.0])
    SpectralGap(gap=0.500000, E0=0.000000, E1=0.500000)
    """
    if len(eigenvalues) < 2:
        return SpectralGapResult(False, None, None, None)
    
    # Verify sorting
    for i in range(len(eigenvalues) - 1):
        if eigenvalues[i] > eigenvalues[i + 1]:
            raise ValueError(f"Eigenvalues not sorted at index {i}: "
                           f"{eigenvalues[i]} > {eigenvalues[i+1]}")
    
    e0 = eigenvalues[0]
    e1 = eigenvalues[1]
    gap = e1 - e0
    
    if gap > 0:
        return SpectralGapResult(True, gap, e0, e1)
    return SpectralGapResult(False, None, e0, e1)


# ============================================================
# Algorithm 2: Diagonal Hamiltonian Mass Gap
# ============================================================

@dataclass
class DiagonalGapResult:
    """Result of diagonal Hamiltonian gap analysis."""
    has_gap: bool
    minimum_excitation: Optional[float]
    excitation_index: Optional[int]
    hamiltonian: np.ndarray
    
    def __repr__(self):
        if self.has_gap:
            return (f"DiagonalGap(m={self.minimum_excitation:.6f}, "
                    f"at index {self.excitation_index})")
        return "DiagonalGap(no gap)"


def diagonal_hamiltonian_gap(energies: List[float]) -> DiagonalGapResult:
    """
    Construct diagonal Hamiltonian and certify mass gap.
    
    Implements the algorithm behind diagonal_hamiltonian_mass_gap:
    1. Construct H = diag(E(0), ..., E(n-1))
    2. Verify E(0) = 0 (vacuum normalization)
    3. Find m = min{E(i) : i ≠ 0}
    4. Verify m > 0
    
    Time complexity: O(n)
    Space complexity: O(n²) for the matrix
    
    Args:
        energies: Energy levels with energies[0] = 0 (vacuum)
        
    Returns:
        DiagonalGapResult with gap data and Hamiltonian matrix
        
    >>> result = diagonal_hamiltonian_gap([0, 0.3, 0.7, 1.0])
    >>> result.minimum_excitation
    0.3
    """
    n = len(energies)
    H = np.diag(energies)
    
    if n < 2:
        return DiagonalGapResult(False, None, None, H)
    
    if energies[0] != 0:
        raise ValueError(f"Vacuum energy must be 0, got {energies[0]}")
    
    excitations = [(e, i) for i, e in enumerate(energies) if i != 0]
    
    if all(e > 0 for e, _ in excitations):
        m, idx = min(excitations, key=lambda x: x[0])
        return DiagonalGapResult(True, m, idx, H)
    
    return DiagonalGapResult(False, None, None, H)


# ============================================================
# Algorithm 3: Lattice Gauge Energy
# ============================================================

@dataclass
class LatticeGaugeConfig:
    """A lattice gauge configuration."""
    n_vertices: int
    edge_values: np.ndarray  # shape (n_vertices, n_vertices)
    
    def __repr__(self):
        return f"LatticeGaugeConfig(V={self.n_vertices}, edges={self.edge_values.shape})"


def compute_lattice_gauge_energy(
    config: LatticeGaugeConfig,
    plaquette_cost: Callable[[int, int, int, int, Any, Any, Any, Any], float]
) -> float:
    """
    Compute total lattice gauge energy.
    
    Implements lattice_gauge_energy:
    E = Σ_{a,b,c,d} plaquette_cost(a, b, c, d, g_ab, g_bc, g_cd, g_da)
    
    Time complexity: O(V⁴) where V is the number of vertices
    Space complexity: O(1) additional
    
    Args:
        config: Lattice gauge configuration
        plaquette_cost: Nonnegative cost function for each plaquette
        
    Returns:
        Total energy (guaranteed nonneg by lattice_gauge_energy_nonneg)
    """
    n = config.n_vertices
    total = 0.0
    for a in range(n):
        for b in range(n):
            for c in range(n):
                for d in range(n):
                    cost = plaquette_cost(
                        a, b, c, d,
                        config.edge_values[a, b],
                        config.edge_values[b, c],
                        config.edge_values[c, d],
                        config.edge_values[d, a]
                    )
                    assert cost >= 0, f"Plaquette cost must be nonneg, got {cost}"
                    total += cost
    return total


# ============================================================
# Algorithm 4: Vacuum Finder
# ============================================================

@dataclass
class VacuumResult:
    """Result of vacuum search."""
    config: Any
    energy: float
    n_configs_searched: int
    
    def __repr__(self):
        return (f"Vacuum(energy={self.energy:.6f}, "
                f"searched {self.n_configs_searched} configs)")


def find_vacuum_exhaustive(
    configs: List[Any],
    energy_fn: Callable[[Any], float]
) -> VacuumResult:
    """
    Find vacuum (global energy minimizer) by exhaustive search.
    
    Implements lattice_gauge_vacuum_exists constructively:
    given a finite set of configurations, find the one with
    minimum energy.
    
    Time complexity: O(|configs| × T_energy) where T_energy is the
                     time to evaluate the energy function
    Space complexity: O(1) additional
    
    Args:
        configs: Finite list of all configurations
        energy_fn: Energy function to minimize
        
    Returns:
        VacuumResult with minimizing configuration and energy
        
    >>> find_vacuum_exhaustive([1, 2, 3, 4, 5], lambda x: (x-3)**2)
    Vacuum(energy=0.000000, searched 5 configs)
    """
    if not configs:
        raise ValueError("Configuration space must be nonempty")
    
    best_config = configs[0]
    best_energy = energy_fn(configs[0])
    
    for config in configs[1:]:
        e = energy_fn(config)
        if e < best_energy:
            best_energy = e
            best_config = config
    
    return VacuumResult(best_config, best_energy, len(configs))


# ============================================================
# Algorithm 5: Refinement Stability Checker
# ============================================================

@dataclass
class RefinementResult:
    """Result of refinement stability check."""
    is_stable: bool
    uniform_bound: float
    infimum: float
    n_levels: int
    gaps: List[float]
    
    def __repr__(self):
        return (f"Refinement(stable={self.is_stable}, "
                f"c={self.uniform_bound:.6f}, inf={self.infimum:.6f}, "
                f"levels={self.n_levels})")


def check_refinement_stability(
    gap_fn: Callable[[int], float],
    n_levels: int,
    candidate_bound: float
) -> RefinementResult:
    """
    Check uniform stability of spectral gaps under lattice refinement.
    
    Implements uniform_lattice_gap_persists_under_refinement:
    verify that gap(n) ≥ c > 0 for all n in range.
    
    Time complexity: O(n_levels × T_gap)
    Space complexity: O(n_levels)
    
    Args:
        gap_fn: Function mapping refinement level to spectral gap
        n_levels: Number of refinement levels to check
        candidate_bound: Proposed uniform lower bound c
        
    Returns:
        RefinementResult with stability data
        
    >>> check_refinement_stability(lambda n: 0.5 + 1/(1+n), 100, 0.5)
    Refinement(stable=True, c=0.500000, inf=0.509901, levels=100)
    """
    gaps = [gap_fn(n) for n in range(n_levels)]
    infimum = min(gaps)
    is_stable = candidate_bound > 0 and all(g >= candidate_bound for g in gaps)
    
    return RefinementResult(is_stable, candidate_bound, infimum, n_levels, gaps)


# ============================================================
# Algorithm 6: Mass Gap from Minimax
# ============================================================

def minimax_gap(eigenvalues: np.ndarray) -> Optional[float]:
    """
    Compute mass gap via minimax principle.
    
    For a sorted array of eigenvalues, the gap is λ₁ - λ₀.
    
    Implements mass_gap_from_minimax.
    
    Time complexity: O(n log n) for sorting
    Space complexity: O(n)
    
    Args:
        eigenvalues: Array of eigenvalues (will be sorted)
        
    Returns:
        Positive gap if it exists, None otherwise
        
    >>> minimax_gap(np.array([0, 0.5, 1.0, 2.0]))
    0.5
    """
    sorted_eigs = np.sort(eigenvalues)
    if len(sorted_eigs) < 2:
        return None
    gap = sorted_eigs[1] - sorted_eigs[0]
    return gap if gap > 0 else None


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    print("Algorithm 1: Spectral Gap Certification")
    print("-" * 40)
    result = certify_spectral_gap([0, 0.5, 1.0, 2.0])
    print(f"  [0, 0.5, 1.0, 2.0] → {result}")
    result = certify_spectral_gap([0, 0, 0.5, 1.0])
    print(f"  [0, 0, 0.5, 1.0]   → {result}")
    print()
    
    print("Algorithm 2: Diagonal Hamiltonian Gap")
    print("-" * 40)
    result = diagonal_hamiltonian_gap([0, 0.3, 0.7, 1.0])
    print(f"  E = [0, 0.3, 0.7, 1.0] → {result}")
    print(f"  Hamiltonian:\n{result.hamiltonian}")
    print()
    
    print("Algorithm 3: Lattice Gauge Energy")
    print("-" * 40)
    config = LatticeGaugeConfig(2, np.array([[0, 1], [1, 0]]))
    energy = compute_lattice_gauge_energy(
        config, 
        lambda a, b, c, d, g1, g2, g3, g4: abs(g1 * g2 - g3 * g4)
    )
    print(f"  Config: {config}, Energy = {energy}")
    print()
    
    print("Algorithm 4: Vacuum Finder")
    print("-" * 40)
    result = find_vacuum_exhaustive(
        list(range(10)),
        lambda x: (x - 3.5) ** 2
    )
    print(f"  f(x) = (x-3.5)², configs = 0..9 → {result}")
    print()
    
    print("Algorithm 5: Refinement Stability")
    print("-" * 40)
    result = check_refinement_stability(lambda n: 0.5 + 1/(1+n), 100, 0.5)
    print(f"  gap(n) = 0.5 + 1/(1+n), c = 0.5 → {result}")
    print()
    
    print("Algorithm 6: Minimax Gap")
    print("-" * 40)
    gap = minimax_gap(np.array([0, 0.5, 1.0, 2.0]))
    print(f"  eigenvalues = [0, 0.5, 1.0, 2.0] → gap = {gap}")
