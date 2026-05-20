#!/usr/bin/env python3
"""
Applications of Hydrogen Spectral Theory

Real-world applications demonstrating the mathematical framework:
1. Spectroscopic identification of hydrogen in stellar atmospheres
2. Precision wavelength calibration
3. Quantum state counting for statistical mechanics
4. Ionization energy computation
"""

import math
from typing import List, Tuple, Dict
from fractions import Fraction


# Physical constants (SI units)
RYDBERG_CONST = 1.0973731568539e7    # m⁻¹
PLANCK_CONST = 6.62607015e-34       # J·s
SPEED_LIGHT = 2.99792458e8          # m/s
BOLTZMANN = 1.380649e-23            # J/K
RYDBERG_ENERGY_EV = 13.605693122994  # eV


def wavelength_to_series(wavelength_nm: float, tolerance_nm: float = 1.0) -> Dict:
    """Identify which hydrogen spectral series a wavelength belongs to.
    
    Application: Stellar spectroscopy — identifying hydrogen absorption lines
    in stellar spectra to determine composition and redshift.
    
    Args:
        wavelength_nm: Observed wavelength in nanometers
        tolerance_nm: Matching tolerance
    
    Returns:
        Dictionary with series identification
    
    >>> result = wavelength_to_series(656.3)
    >>> result['series']
    'Balmer'
    >>> result['transition']
    '3 → 2'
    """
    best_match = None
    best_diff = float('inf')
    
    series_names = {1: 'Lyman', 2: 'Balmer', 3: 'Paschen', 4: 'Brackett', 5: 'Pfund'}
    
    for n_final in range(1, 6):
        for n_upper in range(n_final + 1, n_final + 20):
            # Rydberg formula
            inv_lambda = RYDBERG_CONST * (1/n_final**2 - 1/n_upper**2)
            predicted_nm = 1e9 / inv_lambda
            
            diff = abs(predicted_nm - wavelength_nm)
            if diff < best_diff:
                best_diff = diff
                best_match = {
                    'series': series_names.get(n_final, f'n={n_final}'),
                    'n_lower': n_final,
                    'n_upper': n_upper,
                    'transition': f'{n_upper} → {n_final}',
                    'predicted_nm': predicted_nm,
                    'difference_nm': diff,
                    'matched': diff < tolerance_nm,
                }
    
    return best_match


def partition_function(T: float, n_max: int = 100) -> float:
    """Compute the hydrogen atom partition function at temperature T.
    
    Z = Σ_{n=1}^{n_max} n² exp(-E_n / kT)
    
    where E_n = -13.6/n² eV and the n² factor is the degeneracy.
    
    Application: Statistical mechanics of hydrogen plasma.
    The n² degeneracy is formally verified in hydrogen_degeneracy.
    
    Args:
        T: Temperature in Kelvin
        n_max: Maximum quantum number to include
    
    Returns:
        Partition function value
    
    >>> Z = partition_function(5000, n_max=10)
    >>> Z > 0
    True
    """
    kT_eV = BOLTZMANN * T / 1.602176634e-19  # Convert to eV
    Z = 0.0
    for n in range(1, n_max + 1):
        E_n = -RYDBERG_ENERGY_EV / n**2
        degeneracy = n**2  # Formally verified: Σ(2l+1) = n²
        Z += degeneracy * math.exp(-E_n / kT_eV)
    return Z


def ionization_energy(n: int) -> Dict:
    """Compute ionization energy from level n.
    
    The ionization energy is |E_n| = 13.6/n² eV.
    Formally verified: E_1 = -1 Rydberg (hydrogen_ground_state_energy).
    
    Application: Determining the minimum photon energy needed to
    ionize hydrogen from a given state.
    
    >>> result = ionization_energy(1)
    >>> abs(result['energy_eV'] - 13.6) < 0.1
    True
    """
    E_rydberg = 1.0 / n**2  # In Rydberg units
    E_eV = RYDBERG_ENERGY_EV / n**2
    wavelength_nm = 1e9 / (RYDBERG_CONST / n**2)
    
    return {
        'n': n,
        'energy_rydberg': E_rydberg,
        'energy_eV': E_eV,
        'wavelength_nm': wavelength_nm,
        'frequency_Hz': SPEED_LIGHT * RYDBERG_CONST / n**2,
    }


def emission_spectrum(n_max: int = 7) -> List[Dict]:
    """Generate the complete emission spectrum up to level n_max.
    
    Application: Predicting all observable spectral lines in
    hydrogen discharge tubes or stellar spectra.
    
    >>> lines = emission_spectrum(4)
    >>> len(lines)
    6
    """
    lines = []
    for n_upper in range(2, n_max + 1):
        for n_lower in range(1, n_upper):
            energy_exact = Fraction(1, n_lower**2) - Fraction(1, n_upper**2)
            wavelength_nm = 1e9 / (RYDBERG_CONST * float(energy_exact))
            
            # Determine visibility
            if 380 <= wavelength_nm <= 700:
                visibility = 'visible'
            elif wavelength_nm < 380:
                visibility = 'ultraviolet'
            else:
                visibility = 'infrared'
            
            lines.append({
                'n_upper': n_upper,
                'n_lower': n_lower,
                'energy_exact': energy_exact,
                'wavelength_nm': wavelength_nm,
                'visibility': visibility,
            })
    
    return sorted(lines, key=lambda x: x['wavelength_nm'])


def demonstrate_applications():
    """Run all application demonstrations."""
    
    # Application 1: Stellar spectroscopy
    print("=" * 65)
    print("APPLICATION 1: Stellar Hydrogen Line Identification")
    print("=" * 65)
    
    test_wavelengths = [121.6, 486.1, 656.3, 1875.1, 434.0]
    for wl in test_wavelengths:
        result = wavelength_to_series(wl)
        status = "✓" if result['matched'] else "?"
        print(f"  {wl:8.1f} nm → {result['series']:>8} {result['transition']}"
              f"  (predicted: {result['predicted_nm']:.1f} nm) {status}")
    
    # Application 2: Full emission spectrum
    print(f"\n{'=' * 65}")
    print("APPLICATION 2: Hydrogen Emission Spectrum")
    print("=" * 65)
    
    lines = emission_spectrum(6)
    print(f"\n  {'Transition':<12} {'λ (nm)':>10} {'E (exact)':>12} {'Region':>12}")
    print(f"  {'-'*12} {'-'*10} {'-'*12} {'-'*12}")
    for line in lines:
        trans = f"{line['n_upper']}→{line['n_lower']}"
        print(f"  {trans:<12} {line['wavelength_nm']:10.1f} "
              f"{str(line['energy_exact']):>12} {line['visibility']:>12}")
    
    # Application 3: Ionization energies
    print(f"\n{'=' * 65}")
    print("APPLICATION 3: Ionization Energies")
    print("=" * 65)
    
    print(f"\n  {'n':>3} {'E (eV)':>10} {'E (Ry)':>10} {'λ (nm)':>10}")
    print(f"  {'-'*3} {'-'*10} {'-'*10} {'-'*10}")
    for n in range(1, 8):
        ie = ionization_energy(n)
        print(f"  {n:3d} {ie['energy_eV']:10.4f} {ie['energy_rydberg']:10.6f} "
              f"{ie['wavelength_nm']:10.1f}")
    
    # Application 4: Partition function
    print(f"\n{'=' * 65}")
    print("APPLICATION 4: Partition Function (Statistical Mechanics)")
    print("=" * 65)
    
    print(f"\n  {'T (K)':>10} {'Z (n≤10)':>12} {'Z (n≤50)':>12}")
    print(f"  {'-'*10} {'-'*12} {'-'*12}")
    for T in [1000, 3000, 5000, 10000, 20000, 50000]:
        Z10 = partition_function(T, n_max=10)
        Z50 = partition_function(T, n_max=50)
        print(f"  {T:10d} {Z10:12.4f} {Z50:12.4f}")


if __name__ == "__main__":
    import doctest
    results = doctest.testmod(verbose=False)
    print(f"Doctest results: {results.attempted} tests, {results.failed} failures\n")
    demonstrate_applications()


#!/usr/bin/env python3
"""
Hydrogen Atom Spectral Theory: Interactive Demonstrations

Demonstrates the formally verified properties of the hydrogen atom
energy spectrum, including:
- Rydberg formula for spectral transitions
- Spectral series (Lyman, Balmer, Paschen)
- Degeneracy counting and state enumeration
- Spectral gap structure and convergence
- Connection to the Basel problem (ζ(2) = π²/6)
"""

import math
from typing import List, Tuple

# ============================================================
# Energy Levels
# ============================================================

def hydrogen_energy(n: int) -> float:
    """Hydrogen energy level E_n = -1/n² (in Rydberg units).
    
    >>> hydrogen_energy(1)
    -1.0
    >>> hydrogen_energy(2)
    -0.25
    """
    assert n >= 1, "Quantum number n must be positive"
    return -1.0 / n**2

def photon_energy(n_lower: int, n_upper: int) -> float:
    """Rydberg formula: photon energy for transition n_upper → n_lower.
    
    ΔE = 1/n_lower² - 1/n_upper²
    
    >>> abs(photon_energy(1, 2) - 0.75) < 1e-10
    True
    >>> abs(photon_energy(2, 3) - 5/36) < 1e-10
    True
    """
    assert n_lower < n_upper, "n_lower must be less than n_upper"
    return 1.0/n_lower**2 - 1.0/n_upper**2

# ============================================================
# Demo 1: Spectral Series
# ============================================================

def demo_spectral_series():
    """Display the Lyman, Balmer, and Paschen series."""
    print("=" * 60)
    print("HYDROGEN SPECTRAL SERIES")
    print("=" * 60)
    
    series = [
        ("Lyman (UV)", 1),
        ("Balmer (Visible)", 2),
        ("Paschen (IR)", 3),
    ]
    
    for name, n_final in series:
        print(f"\n{name} series (transitions to n={n_final}):")
        print(f"  {'Transition':<15} {'Energy':>12} {'Wavelength (nm)':>16}")
        print(f"  {'-'*15} {'-'*12} {'-'*16}")
        for k in range(6):
            n_upper = n_final + k + 1
            E = photon_energy(n_final, n_upper)
            # Wavelength in nm (using Rydberg constant R∞ = 1.097e7 m⁻¹)
            wavelength_nm = 91.18 / E  # 1/R∞ in nm
            greek = ['α', 'β', 'γ', 'δ', 'ε', 'ζ'][k]
            print(f"  {name.split()[0]}-{greek:<10} {E:12.6f} {wavelength_nm:16.2f}")
        
        # Series limit
        E_limit = 1.0 / n_final**2
        print(f"  {'Limit':<15} {E_limit:12.6f} {91.18/E_limit:16.2f}")

# ============================================================
# Demo 2: Degeneracy
# ============================================================

def demo_degeneracy():
    """Demonstrate the n² degeneracy of hydrogen energy levels."""
    print("\n" + "=" * 60)
    print("HYDROGEN DEGENERACY: n² STATES PER LEVEL")
    print("=" * 60)
    
    print(f"\n  {'n':>3} {'States':>8} {'n²':>5} {'Σ(2l+1)':>10} {'Match':>6}")
    print(f"  {'-'*3} {'-'*8} {'-'*5} {'-'*10} {'-'*6}")
    
    total = 0
    for n in range(1, 8):
        # List all (l, m) states
        states = []
        sum_odd = 0
        for l in range(n):
            sum_odd += 2*l + 1
            for m in range(-l, l+1):
                states.append((l, m))
        
        total += len(states)
        match = "✓" if len(states) == n**2 == sum_odd else "✗"
        print(f"  {n:3d} {len(states):8d} {n**2:5d} {sum_odd:10d} {match:>6}")
    
    print(f"\n  Total states (n=1 to 7): {total}")
    
    # Verify sum of squares formula
    N = 7
    expected = N * (N+1) * (2*N+1) // 6
    print(f"  N(N+1)(2N+1)/6 = {expected}")
    print(f"  Match: {'✓' if total == expected else '✗'}")

# ============================================================
# Demo 3: Spectral Gap Structure
# ============================================================

def demo_spectral_gaps():
    """Show the decreasing spectral gaps between consecutive levels."""
    print("\n" + "=" * 60)
    print("SPECTRAL GAP STRUCTURE")
    print("=" * 60)
    
    print(f"\n  {'n':>3} {'E_n':>12} {'Gap':>12} {'(2n+1)/n²(n+1)²':>18} {'Match':>6}")
    print(f"  {'-'*3} {'-'*12} {'-'*12} {'-'*18} {'-'*6}")
    
    gaps = []
    for n in range(1, 10):
        E_n = hydrogen_energy(n)
        E_next = hydrogen_energy(n+1)
        gap = E_next - E_n
        formula = (2*n + 1) / (n**2 * (n+1)**2)
        match = "✓" if abs(gap - formula) < 1e-12 else "✗"
        gaps.append(gap)
        print(f"  {n:3d} {E_n:12.6f} {gap:12.8f} {formula:18.8f} {match:>6}")
    
    # Show gap ratios
    print(f"\n  Gap ratios (gap(n)/gap(n+1)):")
    for n in range(1, min(6, len(gaps))):
        ratio = gaps[n-1] / gaps[n]
        print(f"    gap({n})/gap({n+1}) = {ratio:.6f}")
    
    # Verify our conjecture: gap(1)/gap(2) = 27/5
    ratio_1 = gaps[0] / gaps[1]
    print(f"\n  Verified: gap(1)/gap(2) = {ratio_1} = {27/5} (27/5) {'✓' if abs(ratio_1 - 27/5) < 1e-10 else '✗'}")

# ============================================================
# Demo 4: Basel Problem Connection
# ============================================================

def demo_basel_connection():
    """Connect hydrogen energy sums to the Basel problem."""
    print("\n" + "=" * 60)
    print("CROSS-DOMAIN: HYDROGEN SPECTRUM ↔ BASEL PROBLEM")
    print("=" * 60)
    
    print(f"\n  The sum of |E_n| = 1/n² converges to ζ(2) = π²/6 ≈ {math.pi**2/6:.10f}")
    print(f"\n  {'n':>5} {'Σ 1/k²':>14} {'2 - 1/n':>14} {'Bound holds':>12} {'π²/6':>14}")
    print(f"  {'-'*5} {'-'*14} {'-'*14} {'-'*12} {'-'*14}")
    
    partial_sum = 0.0
    for n in range(1, 21):
        partial_sum += 1.0 / n**2
        bound = 2.0 - 1.0/n
        holds = "✓" if partial_sum <= bound + 1e-15 else "✗"
        print(f"  {n:5d} {partial_sum:14.10f} {bound:14.10f} {holds:>12} {math.pi**2/6:14.10f}")
    
    print(f"\n  The telescoping bound Σ_{'{k=1}'}^n 1/k² ≤ 2 - 1/n")
    print(f"  approaches the Basel limit π²/6 from below.")
    print(f"  Gap at n=20: {math.pi**2/6 - partial_sum:.10f}")

# ============================================================
# Demo 5: Selection Rules
# ============================================================

def demo_selection_rules():
    """Demonstrate the dipole selection rules Δm ∈ {-1, 0, +1}."""
    print("\n" + "=" * 60)
    print("DIPOLE SELECTION RULES: Δm ∈ {-1, 0, +1}")
    print("=" * 60)
    
    import cmath
    
    def azimuthal_integral(m: int, m_prime: int, q: int, N: int = 1000) -> complex:
        """Numerically compute ∫₀²π exp(i(m - m' + q)φ) dφ."""
        total = 0j
        dphi = 2 * math.pi / N
        for k in range(N):
            phi = k * dphi
            total += cmath.exp(1j * (m - m_prime + q) * phi) * dphi
        return total
    
    print(f"\n  Azimuthal dipole integrals (numerical, N=10000):")
    mp_header = "m'"
    print(f"  {'m':>4} {mp_header:>4} {'q':>4} {'|Integral|':>14} {'Expected':>10} {'Status':>8}")
    print(f"  {'-'*4} {'-'*4} {'-'*4} {'-'*14} {'-'*10} {'-'*8}")
    
    test_cases = [
        (0, 0, 0, "2π"),     # Allowed: Δm = 0, q = 0
        (0, 1, 1, "2π"),     # Allowed: Δm = 1, q = 1
        (1, 0, -1, "2π"),    # Allowed: Δm = -1, q = -1
        (0, 2, 0, "0"),      # Forbidden: Δm = 2, q = 0
        (0, 3, 1, "0"),      # Forbidden: Δm = 3, q = 1
        (0, 1, 0, "0"),      # Forbidden: Δm = 1, q = 0
        (2, 0, 0, "0"),      # Forbidden: Δm = -2, q = 0
    ]
    
    for m, mp, q, expected in test_cases:
        integral = azimuthal_integral(m, mp, q, N=10000)
        status = "ALLOWED" if abs(integral) > 1.0 else "FORBID"
        print(f"  {m:4d} {mp:4d} {q:4d} {abs(integral):14.6f} {expected:>10} {status:>8}")

# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    demo_spectral_series()
    demo_degeneracy()
    demo_spectral_gaps()
    demo_basel_connection()
    demo_selection_rules()
    
    print("\n" + "=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)
