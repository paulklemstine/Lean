#!/usr/bin/env python3
"""
Applications of the Yang–Mills Mass Gap Spectral Architecture

Demonstrates real-world applications of the formally verified theorems:
1. Z/2Z lattice gauge theory on small lattices
2. SU(2) lattice gauge theory (simplified)
3. Quantum error correction gap analysis
4. Correlation decay estimation
5. Lattice refinement convergence study
"""

import numpy as np
from typing import List, Tuple
from itertools import product


# ============================================================
# Application 1: Z/2Z Lattice Gauge Theory
# ============================================================

def z2_plaquette_energy(edges: List[int]) -> float:
    """
    Compute Z/2Z plaquette energy.
    
    For Z/2Z gauge theory, edge values are ±1.
    Plaquette energy = 1 - product of edges around the plaquette.
    Minimum (vacuum) = 0 when all edges agree.
    Maximum = 2 when the product is -1.
    """
    prod = 1
    for e in edges:
        prod *= e
    return 1 - prod


def z2_lattice_gauge_theory(L: int) -> dict:
    """
    Exact solution of Z/2Z lattice gauge theory on an L×L lattice.
    
    This demonstrates:
    - lattice_gauge_vacuum_exists (vacuum always exists)
    - lattice_gauge_energy_nonneg (all energies ≥ 0)
    - has_mass_gap (gap between vacuum and first excitation)
    
    Args:
        L: Lattice size (L×L)
        
    Returns:
        Dictionary with energy spectrum, vacuum, and gap data
    """
    n_edges = 2 * L * L  # horizontal + vertical edges
    
    # For small lattices, enumerate all configurations
    if n_edges > 16:
        print(f"  Warning: {2**n_edges} configs too large for exhaustive search")
        return {}
    
    energies = []
    n_configs = 2 ** n_edges
    
    for config_idx in range(n_configs):
        edges = [1 if (config_idx >> i) & 1 == 0 else -1 for i in range(n_edges)]
        
        # Sum plaquette energies over all unit squares
        total_energy = 0
        for x in range(L):
            for y in range(L):
                # Get edges around plaquette (x,y)
                right = edges[2 * (x * L + y)]          # horizontal edge
                up = edges[2 * (x * L + y) + 1]         # vertical edge  
                left = edges[2 * (x * L + (y + 1) % L)]  # next horizontal
                down = edges[2 * (((x + 1) % L) * L + y) + 1]  # next vertical
                total_energy += z2_plaquette_energy([right, down, left, up])
        
        energies.append(total_energy)
    
    energies.sort()
    unique_energies = sorted(set(energies))
    
    gap = unique_energies[1] - unique_energies[0] if len(unique_energies) >= 2 else 0
    
    return {
        'L': L,
        'n_edges': n_edges,
        'n_configs': n_configs,
        'vacuum_energy': unique_energies[0],
        'energy_levels': unique_energies,
        'mass_gap': gap,
        'degeneracies': {e: energies.count(e) for e in unique_energies}
    }


# ============================================================
# Application 2: Transfer Matrix Spectral Gap
# ============================================================

def transfer_matrix_gap(beta: float, n_states: int = 4) -> dict:
    """
    Compute spectral gap of a transfer matrix for a 1D gauge model.
    
    The transfer matrix T has entries T[i,j] = exp(-beta * V(i,j))
    where V is a simple potential.
    
    This demonstrates:
    - diagonal_hamiltonian_mass_gap (gap from eigenvalues)
    - uniform_lattice_gap_persists_under_refinement (gap vs beta)
    
    Args:
        beta: Inverse temperature / coupling constant
        n_states: Number of states per site
        
    Returns:
        Dictionary with eigenvalues and gap
    """
    # Build transfer matrix
    T = np.zeros((n_states, n_states))
    for i in range(n_states):
        for j in range(n_states):
            # Potential: V(i,j) = 1 - cos(2π(i-j)/n)
            angle = 2 * np.pi * (i - j) / n_states
            T[i, j] = np.exp(-beta * (1 - np.cos(angle)))
    
    # Compute eigenvalues
    eigenvalues = np.sort(np.linalg.eigvalsh(T))[::-1]  # Descending
    
    # Spectral gap in transfer matrix sense: λ₁/λ₀
    if eigenvalues[0] > 0:
        ratio = eigenvalues[1] / eigenvalues[0]
        gap = 1 - ratio  # Gap = 1 - λ₁/λ₀
    else:
        gap = 0
    
    # Hamiltonian gap: -log(λ₁/λ₀)
    if eigenvalues[0] > 0 and eigenvalues[1] > 0:
        ham_gap = -np.log(eigenvalues[1] / eigenvalues[0])
    else:
        ham_gap = float('inf')
    
    return {
        'beta': beta,
        'n_states': n_states,
        'eigenvalues': eigenvalues.tolist(),
        'spectral_ratio': ratio if eigenvalues[0] > 0 else None,
        'spectral_gap': gap,
        'hamiltonian_gap': ham_gap,
    }


# ============================================================
# Application 3: Correlation Decay
# ============================================================

def correlation_decay(T: np.ndarray, max_distance: int = 20) -> dict:
    """
    Compute correlation decay from transfer matrix.
    
    For a transfer matrix T with spectral gap Δ, the connected
    two-point function decays as exp(-Δ·d).
    
    This is relevant to the Transfer-Matrix Correlation Decay Hypothesis
    in FUTURE_DIRECTIONS.md.
    """
    eigenvalues = np.sort(np.linalg.eigvalsh(T))[::-1]
    eigenvectors = np.linalg.eigh(T)[1]
    
    n = T.shape[0]
    
    # Compute <e₀, T^d e₁> for various d
    e0 = np.zeros(n)
    e0[0] = 1
    e1 = np.zeros(n)
    e1[1] = 1
    
    correlations = []
    current = e1.copy()
    for d in range(max_distance):
        corr = np.dot(e0, current)
        correlations.append(abs(corr))
        current = T @ current
    
    # Predicted decay rate from spectral gap
    if eigenvalues[0] > 0 and eigenvalues[1] > 0:
        decay_rate = -np.log(eigenvalues[1] / eigenvalues[0])
    else:
        decay_rate = float('inf')
    
    return {
        'correlations': correlations,
        'decay_rate_predicted': decay_rate,
        'eigenvalues': eigenvalues.tolist(),
    }


# ============================================================
# Application 4: Refinement Convergence Study
# ============================================================

def refinement_convergence_study(beta: float, max_n: int = 20) -> dict:
    """
    Study how the spectral gap varies with lattice refinement.
    
    Demonstrates uniform_lattice_gap_persists_under_refinement:
    if gaps are bounded below by c > 0 as n → ∞, the mass gap persists.
    """
    gaps = []
    
    for n_states in range(2, max_n + 1):
        result = transfer_matrix_gap(beta, n_states)
        gaps.append(result['hamiltonian_gap'])
    
    # Check uniform lower bound
    min_gap = min(gaps)
    
    return {
        'beta': beta,
        'n_states_range': list(range(2, max_n + 1)),
        'gaps': gaps,
        'min_gap': min_gap,
        'is_uniformly_bounded': min_gap > 0,
    }


# ============================================================
# Application 5: Quantum Error Correction
# ============================================================

def toric_code_gap(L: int) -> dict:
    """
    Compute the spectral gap of a simplified toric code Hamiltonian.
    
    The toric code is a topological quantum error correcting code whose
    gap stability is directly related to the mass gap concept.
    
    For a simplified model: H = -Σ_v A_v - Σ_p B_p
    where A_v are vertex operators and B_p are plaquette operators.
    
    On a small lattice, this reduces to a diagonal Hamiltonian
    in the stabilizer eigenbasis.
    """
    # Simplified: energy levels are 0, 2, 4, ..., 2*L*L
    # (corresponding to number of violated stabilizers)
    n_levels = L * L + 1
    energies = [2 * k for k in range(n_levels)]
    
    # Apply diagonal_hamiltonian_mass_gap
    if len(energies) >= 2:
        gap = energies[1] - energies[0]
    else:
        gap = 0
    
    return {
        'L': L,
        'n_levels': n_levels,
        'energy_levels': energies[:min(10, len(energies))],
        'mass_gap': gap,
        'gap_is_positive': gap > 0,
    }


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("=" * 70)
    print("APPLICATION 1: Z/2Z Lattice Gauge Theory")
    print("=" * 70)
    
    for L in [2, 3]:
        result = z2_lattice_gauge_theory(L)
        if result:
            print(f"\n  L = {L}:")
            print(f"    Edges: {result['n_edges']}, Configs: {result['n_configs']}")
            print(f"    Vacuum energy: {result['vacuum_energy']}")
            print(f"    Energy levels: {result['energy_levels'][:8]}...")
            print(f"    Mass gap: {result['mass_gap']}")
            print(f"    Degeneracies: {dict(list(result['degeneracies'].items())[:5])}...")
    
    print("\n" + "=" * 70)
    print("APPLICATION 2: Transfer Matrix Spectral Gap")
    print("=" * 70)
    
    print("\n  Gap vs coupling constant beta:")
    print(f"  {'beta':>8s} | {'gap':>10s} | {'ham_gap':>10s}")
    print(f"  {'-'*8:>8s}-+-{'-'*10:>10s}-+-{'-'*10:>10s}")
    for beta in [0.1, 0.5, 1.0, 2.0, 5.0, 10.0]:
        result = transfer_matrix_gap(beta, n_states=8)
        print(f"  {beta:8.1f} | {result['spectral_gap']:10.6f} | {result['hamiltonian_gap']:10.6f}")
    
    print("\n" + "=" * 70)
    print("APPLICATION 3: Correlation Decay")
    print("=" * 70)
    
    # Build a transfer matrix
    n = 4
    beta = 2.0
    T = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            T[i, j] = np.exp(-beta * (1 - np.cos(2 * np.pi * (i - j) / n)))
    
    result = correlation_decay(T, max_distance=10)
    print(f"\n  Transfer matrix (beta={beta}, n={n}):")
    print(f"  Predicted decay rate: {result['decay_rate_predicted']:.4f}")
    print(f"  Correlations: {[f'{c:.4e}' for c in result['correlations']]}")
    
    print("\n" + "=" * 70)
    print("APPLICATION 4: Refinement Convergence Study")
    print("=" * 70)
    
    for beta in [1.0, 3.0]:
        result = refinement_convergence_study(beta, max_n=12)
        print(f"\n  beta = {beta}:")
        print(f"    Gaps: {[f'{g:.4f}' for g in result['gaps']]}")
        print(f"    Min gap: {result['min_gap']:.6f}")
        print(f"    Uniformly bounded: {result['is_uniformly_bounded']}")
    
    print("\n" + "=" * 70)
    print("APPLICATION 5: Quantum Error Correction (Toric Code)")
    print("=" * 70)
    
    for L in [2, 3, 4, 5]:
        result = toric_code_gap(L)
        print(f"  L={L}: gap={result['mass_gap']}, "
              f"levels={result['energy_levels'][:5]}..., "
              f"positive={result['gap_is_positive']}")
    
    print("\n\nAll applications completed successfully.")


#!/usr/bin/env python3
"""
Demonstration of Yang–Mills Mass Gap Spectral Architecture

This script provides concrete numerical examples illustrating the formally
verified theorems from the lattice-to-continuum spectral bridge.
"""

import numpy as np
from typing import List, Tuple, Optional


def has_mass_gap(eigenvalues: List[float]) -> Tuple[bool, Optional[float]]:
    """
    Check if a list of eigenvalues has a mass gap (Theorem A).
    
    Returns (True, gap) if a positive gap exists, (False, None) otherwise.
    
    >>> has_mass_gap([0, 0.5, 1.2, 3.0])
    (True, 0.5)
    >>> has_mass_gap([0, 0, 0.5])
    (False, None)
    """
    if len(eigenvalues) < 2:
        return False, None
    gap = eigenvalues[1] - eigenvalues[0]
    if gap > 0:
        return True, gap
    return False, None


def diagonal_hamiltonian_gap(energies: List[float]) -> Tuple[bool, Optional[float]]:
    """
    Compute the mass gap of a diagonal Hamiltonian (Theorem B / diagonal_hamiltonian_mass_gap).
    
    Given energy levels E(0), E(1), ..., E(n-1) with E(0) = 0,
    returns the minimum excitation energy.
    
    >>> diagonal_hamiltonian_gap([0, 0.3, 0.7, 1.0])
    (True, 0.3)
    >>> diagonal_hamiltonian_gap([0, 2.0, 5.0])
    (True, 2.0)
    """
    if len(energies) < 2:
        return False, None
    excitations = [e for i, e in enumerate(energies) if i != 0]
    if all(e > 0 for e in excitations):
        m = min(excitations)
        return True, m
    return False, None


def uniform_gap_check(gaps: List[float], c: float) -> Tuple[bool, float]:
    """
    Verify the uniform lattice gap condition (Theorem C).
    
    Returns (True, infimum) if all gaps >= c > 0.
    
    >>> uniform_gap_check([0.6, 0.55, 0.52, 0.51, 0.505], 0.5)
    (True, 0.505)
    """
    if c <= 0:
        return False, 0.0
    if all(g >= c for g in gaps):
        return True, min(gaps)
    return False, min(gaps) if gaps else 0.0


def lattice_gauge_energy(plaquette_costs: np.ndarray) -> float:
    """
    Compute total lattice gauge energy from plaquette costs.
    All costs must be nonneg (Theorem: lattice_gauge_energy_nonneg).
    
    >>> costs = np.array([[0.0, 0.1], [0.2, 0.0]])
    >>> lattice_gauge_energy(costs) >= 0
    True
    """
    assert np.all(plaquette_costs >= 0), "Plaquette costs must be nonneg"
    return float(np.sum(plaquette_costs))


def find_vacuum(energy_function, configs: List) -> Tuple[int, float]:
    """
    Find the vacuum (global energy minimizer) among finite configurations
    (Theorem: lattice_gauge_vacuum_exists).
    
    >>> find_vacuum(lambda x: x**2, [-2, -1, 0, 1, 2])
    (2, 0)
    """
    energies = [energy_function(c) for c in configs]
    min_idx = int(np.argmin(energies))
    return min_idx, energies[min_idx]


# ============================================================
# DEMONSTRATIONS
# ============================================================

def demo_theorem_a():
    """Demonstrate Theorem A: Finite spectral mass gap from sorted spectrum."""
    print("=" * 60)
    print("THEOREM A: Finite Spectral Mass Gap from Sorted Spectrum")
    print("=" * 60)
    
    spectra = [
        [0, 0.5, 1.2, 3.0],
        [0, 1.0, 1.0, 2.0],
        [0, 0.01, 0.02, 0.03],
        [0, 100, 200, 300],
    ]
    
    for spec in spectra:
        result, gap = has_mass_gap(spec)
        print(f"  Spectrum: {spec}")
        print(f"  → Mass gap exists: {result}, gap = {gap}")
        print()


def demo_theorem_b():
    """Demonstrate Theorem B: Diagonal Hamiltonian mass gap."""
    print("=" * 60)
    print("THEOREM B: Diagonal Hamiltonian Mass Gap")
    print("=" * 60)
    
    hamiltonians = [
        [0, 0.3, 0.7, 1.0],
        [0, 2.0, 5.0, 10.0],
        [0, 0.001, 0.002, 0.003],
    ]
    
    for h in hamiltonians:
        H = np.diag(h)
        print(f"  Diagonal Hamiltonian: diag({h})")
        print(f"  Matrix:\n{H}")
        result, m = diagonal_hamiltonian_gap(h)
        print(f"  → Mass gap: {result}, minimum excitation m = {m}")
        print(f"  → H is symmetric: {np.allclose(H, H.T)}")
        print()


def demo_theorem_c():
    """Demonstrate Theorem C: Lattice refinement stability."""
    print("=" * 60)
    print("THEOREM C: Lattice Refinement Stability")
    print("=" * 60)
    
    # Simulate gap sequence: gap(n) = 0.5 + 1/(1+n)
    N = 20
    c = 0.5
    gaps = [0.5 + 1.0 / (1 + n) for n in range(N)]
    
    print(f"  Gap sequence: gap(n) = 0.5 + 1/(1+n)")
    print(f"  Uniform lower bound: c = {c}")
    print(f"  First 10 gaps: {[round(g, 4) for g in gaps[:10]]}")
    
    result, infimum = uniform_gap_check(gaps, c)
    print(f"  → All gaps ≥ c: {result}")
    print(f"  → Infimum of gaps: {round(infimum, 6)}")
    print(f"  → Infimum > 0: {infimum > 0}")
    print()
    
    # Demonstrate with a converging sequence
    gaps_converge = [1.0 / (1 + n) + 0.1 for n in range(50)]
    result2, inf2 = uniform_gap_check(gaps_converge, 0.1)
    print(f"  Converging sequence gap(n) = 1/(1+n) + 0.1:")
    print(f"  → All gaps ≥ 0.1: {result2}, infimum = {round(inf2, 6)}")
    print()


def demo_vacuum_existence():
    """Demonstrate vacuum existence theorem."""
    print("=" * 60)
    print("VACUUM EXISTENCE: Finding Ground State Configurations")
    print("=" * 60)
    
    # Z/2Z gauge theory on a small lattice
    # Configurations are binary strings, energy is number of frustrated plaquettes
    configs = list(range(16))  # 4-bit configurations for a 2x2 lattice
    
    def toy_gauge_energy(config):
        """Energy = number of frustrated plaquettes in a Z/2Z gauge theory."""
        bits = [(config >> i) & 1 for i in range(4)]
        # Plaquette = product around a face (XOR in Z/2Z)
        frustration = bits[0] ^ bits[1] ^ bits[2] ^ bits[3]
        return frustration
    
    vac_idx, vac_energy = find_vacuum(toy_gauge_energy, configs)
    print(f"  Z/2Z gauge theory on 2×2 lattice")
    print(f"  Number of configurations: {len(configs)}")
    print(f"  Vacuum configuration index: {vac_idx}")
    print(f"  Vacuum energy: {vac_energy}")
    print(f"  Energy is nonneg: {vac_energy >= 0}")
    
    # Show all energies
    all_energies = sorted(set(toy_gauge_energy(c) for c in configs))
    print(f"  Distinct energy levels: {all_energies}")
    if len(all_energies) >= 2:
        gap = all_energies[1] - all_energies[0]
        print(f"  Mass gap: {gap}")
    print()


def demo_bridge():
    """Demonstrate the bridge theorem connecting all results."""
    print("=" * 60)
    print("BRIDGE THEOREM: Connecting Spectral and Variational Gaps")
    print("=" * 60)
    
    # Monotone energy function on Fin 5
    n = 5
    E = [0, 0.2, 0.5, 1.0, 2.0]
    
    print(f"  Energy function E: {E}")
    print(f"  E is monotone: {all(E[i] <= E[i+1] for i in range(len(E)-1))}")
    print(f"  E(0) = 0: {E[0] == 0}")
    print(f"  E(1) > 0: {E[1] > 0}")
    
    # Part 1: Minimum excitation gap
    excitations = E[1:]
    m = min(excitations)
    print(f"\n  Part 1 (variational): min excitation = {m}")
    print(f"  All excitations ≥ m: {all(e >= m for e in excitations)}")
    
    # Part 2: Mass gap from spectrum
    result, gap = has_mass_gap(E)
    print(f"\n  Part 2 (spectral): mass gap = {gap}")
    print(f"  Mass gap exists: {result}")
    print()


if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("YANG-MILLS MASS GAP: SPECTRAL ARCHITECTURE DEMONSTRATIONS")
    print("=" * 60 + "\n")
    
    demo_theorem_a()
    demo_theorem_b()
    demo_theorem_c()
    demo_vacuum_existence()
    demo_bridge()
    
    print("All demonstrations completed successfully.")
