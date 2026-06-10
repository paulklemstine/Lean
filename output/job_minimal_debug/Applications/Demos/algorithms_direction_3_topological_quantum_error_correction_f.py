"""
Algorithms for Topological Quantum Error Correction from Gauge Theory

Implements:
1. Quantum double model parameter computation
2. Gauge-code correspondence evaluation
3. Spectral gap perturbation analysis
4. Code distance scaling verification
"""

import numpy as np
from typing import Tuple, List, Dict, Optional


class QuantumDoubleModel:
    """Kitaev quantum double model on an L×L torus.
    
    The quantum double Hamiltonian is H = -∑_v A_v - ∑_p B_p where:
    - A_v are vertex operators (gauge symmetry projectors)
    - B_p are plaquette operators (flux projectors)
    
    For a finite group G on an L×L torus:
    - n = 2L² physical qubits
    - k = 2 logical qubits (for abelian G)
    - d = L code distance
    - Δ = spectral gap of H
    
    Time complexity: O(1) per parameter, O(L²) to enumerate stabilizers.
    Space complexity: O(1) for parameters, O(L²) for stabilizer list.
    """
    
    def __init__(self, L: int, group_order: int = 2, spectral_gap: float = 1.0):
        if L < 2:
            raise ValueError(f"System size L must be >= 2, got {L}")
        if group_order < 2:
            raise ValueError(f"Group order must be >= 2, got {group_order}")
        if spectral_gap <= 0:
            raise ValueError(f"Spectral gap must be positive, got {spectral_gap}")
        
        self.L = L
        self.group_order = group_order
        self.spectral_gap = spectral_gap
        self.n_qubits = 2 * L**2
        self.k_logical = 2  # For abelian groups on torus
        self.d_code = L
    
    @property
    def normalized_gap(self) -> float:
        """min(Δ, 1) — the normalized spectral gap."""
        return min(self.spectral_gap, 1.0)
    
    @property
    def correlation_length(self) -> float:
        """ξ = 1/Δ — correlation length."""
        return 1.0 / self.spectral_gap
    
    @property
    def code_params(self) -> Tuple[int, int, int]:
        """Return (n, k, d) code parameters."""
        return (self.n_qubits, self.k_logical, self.d_code)
    
    def verify_singleton_bound(self) -> bool:
        """Check n - k >= 2(d-1)."""
        return self.n_qubits - self.k_logical >= 2 * (self.d_code - 1)
    
    def verify_plotkin_bound(self) -> bool:
        """Check 2d <= n."""
        return 2 * self.d_code <= self.n_qubits
    
    def verify_gap_distance_bound(self) -> bool:
        """Check d >= Δ_norm · L."""
        return self.d_code >= self.normalized_gap * self.L
    
    def is_topologically_ordered(self) -> bool:
        """Check Δ · L > 1 (correlation length < system size)."""
        return self.spectral_gap * self.L > 1
    
    def energy_barrier(self) -> float:
        """Minimum energy barrier for logical error: Δ · d."""
        return self.spectral_gap * self.d_code
    
    def protection_exponent(self, c: float = 0.5) -> float:
        """Memory protection exponent c · Δ · L."""
        return c * self.spectral_gap * self.L
    
    def protection_time(self, c: float = 0.5) -> float:
        """Estimated memory lifetime τ ~ exp(c·Δ·L)."""
        return np.exp(self.protection_exponent(c))
    
    def qubit_overhead(self) -> float:
        """Ratio n/d² (should be ≈ 2 for 2D codes)."""
        return self.n_qubits / self.d_code**2
    
    def correction_capacity(self) -> int:
        """Maximum correctable error weight: ⌊(d-1)/2⌋."""
        return (self.d_code - 1) // 2


class GaugeCodeCorrespondence:
    """Gauge-code correspondence for a gauge group.
    
    Encodes the dictionary between lattice gauge theory and
    quantum error correction:
    - gap(L): spectral gap at system size L
    - dist(L): code distance at system size L
    - linear_growth_constant c: d(L) >= c·L
    - gap_lower Δ₀: Δ(L) >= Δ₀ for all L >= 2
    
    Time complexity: O(1) per evaluation.
    """
    
    def __init__(self, gap_fn, dist_fn, 
                 linear_growth_constant: float,
                 gap_lower: float,
                 group_name: str = "Unknown"):
        self.gap = gap_fn
        self.dist = dist_fn
        self.linear_growth_constant = linear_growth_constant
        self.gap_lower = gap_lower
        self.group_name = group_name
    
    def verify_linear_growth(self, L: int) -> bool:
        """Check d(L) >= c · L."""
        return self.dist(L) >= self.linear_growth_constant * L
    
    def verify_uniform_gap(self, L: int) -> bool:
        """Check Δ(L) >= Δ₀."""
        return self.gap(L) >= self.gap_lower
    
    def protection_product(self, L: int) -> float:
        """Compute Δ(L) · d(L) — the protection quality."""
        return self.gap(L) * self.dist(L)
    
    def protection_lower_bound(self, L: int) -> float:
        """Lower bound: Δ₀ · c · L."""
        return self.gap_lower * self.linear_growth_constant * L
    
    def verify_uniform_protection(self, L: int) -> bool:
        """Check Δ₀·c·L <= Δ(L)·d(L)."""
        return self.protection_lower_bound(L) <= self.protection_product(L)
    
    def find_critical_size(self, target: float) -> int:
        """Find smallest L_c such that protection >= target.
        
        Uses the Archimedean property: L_c = ⌈target/(Δ₀·c)⌉.
        
        Time complexity: O(1).
        """
        denominator = self.gap_lower * self.linear_growth_constant
        if denominator <= 0:
            raise ValueError("Cannot find critical size with non-positive gap·growth")
        return int(np.ceil(target / denominator))


def perturbation_analysis(model: QuantumDoubleModel, 
                          epsilons: List[float]) -> List[Dict]:
    """Analyze how perturbations affect the spectral gap.
    
    For each ε, computes the residual gap Δ - 2ε and checks
    if the code remains protected.
    
    Time complexity: O(len(epsilons)).
    """
    results = []
    for eps in epsilons:
        residual_gap = model.spectral_gap - 2 * eps
        results.append({
            'epsilon': eps,
            'residual_gap': residual_gap,
            'protected': residual_gap > 0,
            'new_barrier': max(0, residual_gap) * model.d_code,
        })
    return results


def distance_scaling_analysis(L_values: List[int],
                              gap: float = 1.0) -> Dict:
    """Analyze code distance scaling across system sizes.
    
    Verifies:
    - d(2L) = 2·d(L) (linear scaling)
    - n(2L) = 4·n(L) (quadratic qubit scaling)
    - d/L = const (constant ratio)
    
    Time complexity: O(len(L_values)).
    """
    models = [QuantumDoubleModel(L, spectral_gap=gap) for L in L_values]
    
    results = {
        'L_values': L_values,
        'distances': [m.d_code for m in models],
        'qubits': [m.n_qubits for m in models],
        'd_over_L': [m.d_code / m.L for m in models],
        'n_over_d_sq': [m.qubit_overhead() for m in models],
        'barriers': [m.energy_barrier() for m in models],
        'protection_times': [m.protection_time() for m in models],
    }
    
    # Check doubling
    doubling_holds = True
    for i in range(len(L_values) - 1):
        if L_values[i+1] == 2 * L_values[i]:
            if results['distances'][i+1] != 2 * results['distances'][i]:
                doubling_holds = False
    results['doubling_holds'] = doubling_holds
    
    return results


# Standard gauge-code correspondences
Z2_CORRESPONDENCE = GaugeCodeCorrespondence(
    gap_fn=lambda L: 1.0,
    dist_fn=lambda L: L,
    linear_growth_constant=1.0,
    gap_lower=1.0,
    group_name="Z2"
)

Z3_CORRESPONDENCE = GaugeCodeCorrespondence(
    gap_fn=lambda L: 1.0,
    dist_fn=lambda L: L,
    linear_growth_constant=1.0,
    gap_lower=1.0,
    group_name="Z3"
)

Z5_CORRESPONDENCE = GaugeCodeCorrespondence(
    gap_fn=lambda L: 1.0,
    dist_fn=lambda L: L,
    linear_growth_constant=1.0,
    gap_lower=1.0,
    group_name="Z5"
)


if __name__ == "__main__":
    # Example usage
    print("Quantum Double Model Examples")
    print("=" * 50)
    
    for L in [4, 8, 16]:
        model = QuantumDoubleModel(L)
        n, k, d = model.code_params
        print(f"\nL={L}: [[{n}, {k}, {d}]]")
        print(f"  Singleton: {model.verify_singleton_bound()}")
        print(f"  Plotkin: {model.verify_plotkin_bound()}")
        print(f"  Gap-Distance: {model.verify_gap_distance_bound()}")
        print(f"  Topological: {model.is_topologically_ordered()}")
        print(f"  Barrier: {model.energy_barrier()}")
        print(f"  Correction capacity: {model.correction_capacity()} errors")
    
    print("\n\nGauge-Code Correspondence (Z2)")
    print("=" * 50)
    gcc = Z2_CORRESPONDENCE
    for L in [4, 8, 16, 32]:
        print(f"L={L}: Δ·d={gcc.protection_product(L):.0f}, "
              f"lower bound={gcc.protection_lower_bound(L):.0f}, "
              f"verified={gcc.verify_uniform_protection(L)}")
    
    print(f"\nCritical size for protection=100: L_c={gcc.find_critical_size(100)}")
    
    print("\n\nPerturbation Analysis (L=16)")
    print("=" * 50)
    model = QuantumDoubleModel(16)
    for result in perturbation_analysis(model, [0.0, 0.1, 0.2, 0.3, 0.4, 0.5]):
        print(f"  ε={result['epsilon']:.1f}: residual gap={result['residual_gap']:.1f}, "
              f"protected={result['protected']}, barrier={result['new_barrier']:.1f}")
