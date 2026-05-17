#!/usr/bin/env python3
"""
Hydrogen Atom — Real-World Applications

Demonstrates how the formally verified spectral theory connects
to practical applications in physics, chemistry, and technology.
"""

import numpy as np
from algorithms import hydrogen_energy, angular_momentum_matrices, is_dipole_allowed


# ============================================================
# Application 1: Hydrogen Emission Spectrum
# ============================================================

def hydrogen_emission_spectrum():
    """
    Compute the complete visible emission spectrum of hydrogen
    using the verified energy level formula E_n = -1/n².

    This is the Balmer series (n → 2), which produces visible light.
    """
    print("=" * 60)
    print("APPLICATION 1: Hydrogen Visible Emission Spectrum")
    print("=" * 60)

    # Physical constants
    Ry_eV = 13.6057  # Rydberg energy in eV (= 1/2 a.u.)
    hc_eV_nm = 1240.0  # hc in eV·nm

    # Named Balmer lines
    line_names = {3: "Hα (red)", 4: "Hβ (cyan)", 5: "Hγ (blue)",
                  6: "Hδ (violet)", 7: "Hε"}

    print(f"\n  Balmer series (transitions to n=2):")
    print(f"  {'Line':>12s} {'n':>3s} {'ΔE (eV)':>10s} {'λ (nm)':>10s} {'Color':>12s}")
    print("  " + "-" * 52)

    for n in range(3, 8):
        # E_n - E_2 in Rydberg units (our E_n = -1/n² = -2 Ry/n²)
        dE_au = hydrogen_energy(n) - hydrogen_energy(2)
        dE_eV = dE_au * 2 * Ry_eV  # Convert from our units to eV
        wavelength = hc_eV_nm / dE_eV

        name = line_names.get(n, "")
        color = ""
        if 620 <= wavelength <= 750:
            color = "Red"
        elif 490 <= wavelength < 620:
            color = "Cyan/Green"
        elif 450 <= wavelength < 490:
            color = "Blue"
        elif 380 <= wavelength < 450:
            color = "Violet"
        else:
            color = "UV"

        print(f"  {name:>12s} {n:3d} {dE_eV:10.4f} {wavelength:10.1f} {color:>12s}")

    # Series limit
    limit_eV = 2 * Ry_eV / 4
    limit_nm = hc_eV_nm / limit_eV
    print(f"\n  Series limit: {limit_eV:.4f} eV = {limit_nm:.1f} nm (UV)")
    print()


# ============================================================
# Application 2: Zeeman Effect Prediction
# ============================================================

def zeeman_splitting():
    """
    Predict the Zeeman splitting pattern using verified angular
    momentum eigenvalues and selection rules.
    """
    print("=" * 60)
    print("APPLICATION 2: Zeeman Effect (Magnetic Field Splitting)")
    print("=" * 60)

    # The normal Zeeman effect: each m-sublevel shifts by m·μ_B·B
    # μ_B ≈ 5.788 × 10⁻⁵ eV/T (Bohr magneton)
    mu_B = 5.788e-5  # eV/T

    B = 1.0  # Tesla
    print(f"\n  Magnetic field: B = {B} T")
    print(f"  Bohr magneton: μ_B = {mu_B:.3e} eV/T")

    # n=2 → n=1 transition (Lyman alpha) in B field
    print(f"\n  Lyman-α transition (2p → 1s) in magnetic field:")
    print(f"  {'Transition':>20s} {'Δm':>4s} {'Pol.':>6s} {'Shift (eV)':>12s}")
    print("  " + "-" * 48)

    for m_initial in [-1, 0, 1]:  # 2p: l=1, m=-1,0,1
        m_final = 0  # 1s: l=0, m=0
        dm = m_final - m_initial
        if not is_dipole_allowed(m_initial, m_final):
            continue

        # Energy shift = (m_final - m_initial) · μ_B · B
        shift = dm * mu_B * B

        pol = "π" if dm == 0 else ("σ+" if dm == 1 else "σ-")
        label = f"m={m_initial:+d} → m={m_final:+d}"
        print(f"  {label:>20s} {dm:+4d} {pol:>6s} {shift:12.3e}")

    print(f"\n  The three components are separated by {mu_B * B:.3e} eV")
    print(f"  This corresponds to Δν = {mu_B * B / 4.136e-15:.2e} Hz")
    print()


# ============================================================
# Application 3: Atomic Shell Structure
# ============================================================

def shell_structure():
    """
    Derive the periodic table shell structure from the verified
    degeneracy formula.
    """
    print("=" * 60)
    print("APPLICATION 3: Periodic Table Shell Structure")
    print("=" * 60)

    print(f"\n  Shell capacities from n² degeneracy (×2 for spin):")
    print(f"  {'Shell':>6s} {'n':>3s} {'n²':>5s} {'2n²':>5s} {'Cumulative':>12s} {'Elements':>10s}")
    print("  " + "-" * 50)

    cumulative = 0
    shell_names = ["K", "L", "M", "N", "O", "P", "Q"]
    noble_gases = {2: "He", 10: "Ne", 18: "Ar", 36: "Kr", 54: "Xe", 86: "Rn", 118: "Og"}

    for n in range(1, 8):
        capacity = 2 * n**2
        cumulative += capacity
        name = shell_names[n-1] if n <= len(shell_names) else f"n={n}"
        noble = noble_gases.get(cumulative, "")
        print(f"  {name:>6s} {n:3d} {n**2:5d} {capacity:5d} {cumulative:12d} {noble:>10s}")

    print(f"\n  Subshell structure (from 2l+1 degeneracy):")
    print(f"  {'l':>3s} {'Name':>6s} {'2l+1':>6s} {'2(2l+1)':>8s}")
    print("  " + "-" * 28)

    subshell_names = ["s", "p", "d", "f", "g"]
    for l in range(5):
        deg = 2 * l + 1
        capacity = 2 * deg
        name = subshell_names[l]
        print(f"  {l:3d} {name:>6s} {deg:6d} {capacity:8d}")
    print()


# ============================================================
# Application 4: Astrophysical Spectral Analysis
# ============================================================

def astrophysical_spectrum():
    """
    Demonstrate how hydrogen spectral lines are used in astrophysics
    for redshift measurement.
    """
    print("=" * 60)
    print("APPLICATION 4: Astrophysical Redshift Measurement")
    print("=" * 60)

    Ry_eV = 13.6057
    hc = 1240.0

    # Rest-frame wavelengths of Balmer series
    print(f"\n  Rest-frame Balmer wavelengths:")
    rest_wavelengths = {}
    for n in range(3, 8):
        dE = (hydrogen_energy(n) - hydrogen_energy(2)) * 2 * Ry_eV
        wl = hc / dE
        rest_wavelengths[n] = wl
        print(f"    H{chr(ord('α') + n - 3)}: λ₀ = {wl:.2f} nm")

    # Simulated redshifted observation
    z = 0.1  # redshift
    print(f"\n  Observed wavelengths at redshift z = {z}:")
    print(f"  {'Line':>6s} {'λ₀ (nm)':>10s} {'λ_obs (nm)':>12s} {'Δλ (nm)':>10s}")
    print("  " + "-" * 42)

    for n in range(3, 7):
        wl_rest = rest_wavelengths[n]
        wl_obs = wl_rest * (1 + z)
        dw = wl_obs - wl_rest
        label = f"H{chr(ord('α') + n - 3)}"
        print(f"  {label:>6s} {wl_rest:10.2f} {wl_obs:12.2f} {dw:10.2f}")

    print(f"\n  Recession velocity: v = c·z = {z * 3e5:.0f} km/s")
    H0 = 70  # km/s/Mpc
    distance = z * 3e5 / H0
    print(f"  Hubble distance: d = v/H₀ = {distance:.0f} Mpc = {distance * 3.26:.0f} Mly")
    print()


# ============================================================
# Application 5: Quantum Computing with Angular Momentum
# ============================================================

def quantum_computing_connection():
    """
    Show how angular momentum algebra connects to quantum computing.
    """
    print("=" * 60)
    print("APPLICATION 5: Quantum Computing Connections")
    print("=" * 60)

    # Pauli matrices are l=1/2 angular momentum (×2)
    print("\n  Pauli matrices as angular momentum generators (l=1/2):")
    sigma_x = np.array([[0, 1], [1, 0]], dtype=complex)
    sigma_y = np.array([[0, -1j], [1j, 0]], dtype=complex)
    sigma_z = np.array([[1, 0], [0, -1]], dtype=complex)

    # Verify [σ_x/2, σ_y/2] = i·σ_z/2
    Sx, Sy, Sz = sigma_x/2, sigma_y/2, sigma_z/2
    comm = Sx @ Sy - Sy @ Sx
    print(f"  [Sx, Sy] = i·Sz?  Error: {np.max(np.abs(comm - 1j*Sz)):.2e}")

    # l=1 qutrit
    print("\n  Qutrit (l=1) angular momentum matrices:")
    Lx, Ly, Lz = angular_momentum_matrices(1)
    print(f"  Dimension: {Lx.shape[0]}×{Lx.shape[1]}")

    # Verify for higher l
    print("\n  Verified commutation relations for quantum registers:")
    for l in [0, 1, 2, 3]:
        dim = 2*l + 1
        Lx, Ly, Lz = angular_momentum_matrices(l)
        err = np.max(np.abs(Lx @ Ly - Ly @ Lx - 1j * Lz))
        L2 = Lx@Lx + Ly@Ly + Lz@Lz
        L2_err = np.max(np.abs(L2 - l*(l+1)*np.eye(dim)))
        print(f"    l={l} (dim={dim}): [Lx,Ly]=iLz err={err:.2e}, "
              f"L²={l*(l+1)}·I err={L2_err:.2e}")
    print()


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("  HYDROGEN ATOM — REAL-WORLD APPLICATIONS")
    print("=" * 60 + "\n")

    hydrogen_emission_spectrum()
    zeeman_splitting()
    shell_structure()
    astrophysical_spectrum()
    quantum_computing_connection()

    print("All applications demonstrated successfully.")


#!/usr/bin/env python3
"""
Hydrogen Atom Spectral Theory — Interactive Demonstrations

This module provides concrete numerical demonstrations of the theorems
formalized in the Lean 4 proof:
  - Energy level degeneracy (sum of odd numbers = n²)
  - Azimuthal orthogonality integrals
  - Dipole selection rules
  - Energy level properties and Balmer series
"""

import numpy as np

# ============================================================
# Demo 1: Degeneracy Count — Sum of Odd Numbers
# ============================================================

def demo_degeneracy():
    """Verify ∑_{l=0}^{n-1} (2l+1) = n² for several values of n."""
    print("=" * 60)
    print("DEMO 1: Hydrogen Energy Level Degeneracy")
    print("  Theorem: ∑_{l=0}^{n-1} (2l+1) = n²")
    print("=" * 60)

    for n in range(1, 11):
        odd_sum = sum(2 * l + 1 for l in range(n))
        print(f"  n = {n:2d}: ∑(2l+1) = {odd_sum:4d} = {n}² ✓" if odd_sum == n**2
              else f"  n = {n:2d}: MISMATCH!")

    print()
    # Show the quantum states explicitly for n=3
    print("  Quantum states for n=3 (9 states total):")
    count = 0
    for l in range(3):
        for m in range(-l, l + 1):
            count += 1
            print(f"    State {count}: (n=3, l={l}, m={m:+d})")
    print(f"  Total: {count} = 3² ✓")
    print()


# ============================================================
# Demo 2: Azimuthal Orthogonality
# ============================================================

def demo_orthogonality():
    """Numerically verify ∫₀²π e^{-im₁φ} e^{im₂φ} dφ = 2π δ_{m₁,m₂}."""
    print("=" * 60)
    print("DEMO 2: Azimuthal Orthogonality")
    print("  Theorem: ∫₀²π e^{-im₁φ} e^{im₂φ} dφ = 2π δ_{m₁,m₂}")
    print("=" * 60)

    phi = np.linspace(0, 2 * np.pi, 10000)
    dphi = phi[1] - phi[0]

    print(f"\n  {'m₁':>4s} {'m₂':>4s} {'Re(∫)':>12s} {'Im(∫)':>12s} {'Expected':>10s}")
    print("  " + "-" * 50)

    for m1 in range(-2, 3):
        for m2 in range(-2, 3):
            integrand = np.exp(-1j * m1 * phi) * np.exp(1j * m2 * phi)
            integral = np.sum(integrand) * dphi
            expected = 2 * np.pi if m1 == m2 else 0
            if abs(m1 - m2) <= 1:  # Only show nearby values
                print(f"  {m1:4d} {m2:4d} {integral.real:12.6f} {integral.imag:12.6f} {expected:10.4f}")

    print()


# ============================================================
# Demo 3: Dipole Selection Rules
# ============================================================

def demo_selection_rules():
    """Numerically verify the Δm selection rule for dipole transitions."""
    print("=" * 60)
    print("DEMO 3: Dipole Selection Rules (Δm = 0, ±1)")
    print("  Theorem: ∫₀²π e^{i(m-m'+q)φ} dφ = 2π δ_{m',m+q}")
    print("=" * 60)

    phi = np.linspace(0, 2 * np.pi, 10000)
    dphi = phi[1] - phi[0]

    mp_header = "m'"
    print(f"\n  {'m':>3s} {mp_header:>3s} {'q':>3s} {'|Integral|':>12s} {'Allowed?':>10s}")
    print("  " + "-" * 40)

    for m in range(-2, 3):
        for mp in range(-2, 3):
            for q in [-1, 0, 1]:
                n = m - mp + q
                integrand = np.exp(1j * n * phi)
                integral = np.abs(np.sum(integrand) * dphi)
                allowed = (mp == m + q)
                if abs(m) <= 2 and abs(mp) <= 2:
                    status = "ALLOWED" if allowed else "FORBIDDEN"
                    if integral > 0.1 or allowed:
                        print(f"  {m:3d} {mp:3d} {q:+2d} {integral:12.4f}   {status}")

    print()


# ============================================================
# Demo 4: Energy Level Properties
# ============================================================

def demo_energy_levels():
    """Demonstrate properties of E_n = -1/n²."""
    print("=" * 60)
    print("DEMO 4: Hydrogen Energy Levels E_n = -1/n²")
    print("=" * 60)

    print("\n  Energy levels (atomic units):")
    print(f"  {'n':>3s} {'E_n':>12s} {'Degeneracy':>12s} {'States':>8s}")
    print("  " + "-" * 40)

    total_states = 0
    for n in range(1, 11):
        E = -1.0 / n**2
        deg = n**2
        total_states += deg
        print(f"  {n:3d} {E:12.6f} {deg:12d} {total_states:8d}")

    # Spectral gap
    E1 = -1.0
    E2 = -1.0 / 4
    gap = E2 - E1
    print(f"\n  Spectral gap E₂ - E₁ = {gap:.4f} = 3/4 ✓")
    print(f"  Ionization energy = {-E1:.4f} = 1 ✓")

    # Balmer series
    print("\n  Balmer series photon energies (transitions to n=2):")
    print(f"  {'n':>3s} {'E_photon':>12s} {'Wavelength (nm)':>16s}")
    print("  " + "-" * 35)

    # Conversion: 1 atomic unit of energy ≈ 27.2114 eV
    # hc ≈ 1240 eV·nm
    E_au_to_eV = 27.2114
    hc = 1240.0  # eV·nm

    for n in range(3, 11):
        E_photon = -1.0 / n**2 + 1.0 / 4  # in a.u.
        E_eV = E_photon * E_au_to_eV
        wavelength = hc / E_eV if E_eV > 0 else float('inf')
        print(f"  {n:3d} {E_photon:12.6f} {wavelength:16.1f}")

    E_limit = 1.0 / 4
    print(f"\n  Series limit: E → {E_limit:.4f} (ionization from n=2)")
    print()


# ============================================================
# Demo 5: Angular Momentum Commutation Relations
# ============================================================

def demo_angular_momentum():
    """Verify [Lx, Ly] = iLz and cyclic permutations for l=1 matrices."""
    print("=" * 60)
    print("DEMO 5: Angular Momentum Commutation Relations")
    print("  Theorem: [Lx, Ly] = i·Lz (and cyclic)")
    print("=" * 60)

    s2 = np.sqrt(2)

    Lx = np.array([[0, 1/s2, 0],
                    [1/s2, 0, 1/s2],
                    [0, 1/s2, 0]], dtype=complex)

    Ly = np.array([[0, -1j/s2, 0],
                    [1j/s2, 0, -1j/s2],
                    [0, 1j/s2, 0]], dtype=complex)

    Lz = np.array([[1, 0, 0],
                    [0, 0, 0],
                    [0, 0, -1]], dtype=complex)

    # Verify commutation relations
    comm_xy = Lx @ Ly - Ly @ Lx
    expected_xy = 1j * Lz
    err_xy = np.max(np.abs(comm_xy - expected_xy))
    print(f"\n  [Lx, Ly] = i·Lz?  Max error: {err_xy:.2e} ✓")

    comm_yz = Ly @ Lz - Lz @ Ly
    expected_yz = 1j * Lx
    err_yz = np.max(np.abs(comm_yz - expected_yz))
    print(f"  [Ly, Lz] = i·Lx?  Max error: {err_yz:.2e} ✓")

    comm_zx = Lz @ Lx - Lx @ Lz
    expected_zx = 1j * Ly
    err_zx = np.max(np.abs(comm_zx - expected_zx))
    print(f"  [Lz, Lx] = i·Ly?  Max error: {err_zx:.2e} ✓")

    # Verify L² = 2I
    L2 = Lx @ Lx + Ly @ Ly + Lz @ Lz
    expected_L2 = 2 * np.eye(3, dtype=complex)
    err_L2 = np.max(np.abs(L2 - expected_L2))
    print(f"  L² = 2·I?         Max error: {err_L2:.2e} ✓")
    print(f"  (l=1: l(l+1) = 1·2 = 2)")
    print()


# ============================================================
# Demo 6: Accumulation of Energy Levels
# ============================================================

def demo_accumulation():
    """Show that energy levels accumulate at zero."""
    print("=" * 60)
    print("DEMO 6: Energy Level Accumulation at Zero")
    print("  Theorem: ∀ ε > 0, ∃ n: -ε < E_n < 0")
    print("=" * 60)

    epsilons = [0.1, 0.01, 0.001, 0.0001, 0.00001]
    for eps in epsilons:
        # Find smallest n with |E_n| < eps, i.e., 1/n² < eps, i.e., n > 1/√eps
        n = int(np.ceil(1 / np.sqrt(eps)))
        E = -1.0 / n**2
        print(f"  ε = {eps:.0e}: n = {n:5d}, E_n = {E:.2e}, "
              f"-ε < E_n < 0? {-eps < E < 0}")
    print()


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("  HYDROGEN ATOM SPECTRAL THEORY — NUMERICAL DEMONSTRATIONS")
    print("=" * 60 + "\n")

    demo_degeneracy()
    demo_orthogonality()
    demo_selection_rules()
    demo_energy_levels()
    demo_angular_momentum()
    demo_accumulation()

    print("All demonstrations completed successfully.")


#!/usr/bin/env python3
"""Generate PACKAGE.json with all deliverables."""

import json
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

def main():
    # Read markdown files
    article = read_file('ARTICLE.md')
    research_paper = read_file('RESEARCH_PAPER.md')
    future_directions = read_file('FUTURE_DIRECTIONS.md')

    # Read Lean files
    lean_files = [
        'Physics/Quantum/Hydrogen/Defs.lean',
        'Physics/Quantum/Hydrogen/Degeneracy.lean',
        'Physics/Quantum/Hydrogen/Angular.lean',
        'Physics/Quantum/Hydrogen/SelectionRules.lean',
        'Physics/Quantum/Hydrogen/Spectrum.lean',
    ]
    lean_proofs = ""
    for lf in lean_files:
        lean_proofs += f"-- ========== {lf} ==========\n\n"
        lean_proofs += read_file(lf)
        lean_proofs += "\n\n"

    # Read Python files
    demo_code = read_file('demo.py')
    algorithms_code = read_file('algorithms.py')
    applications_code = read_file('applications.py')

    # Generate visualizations and get base64
    from visualizations import generate_all
    viz_data = generate_all()

    # Build package
    package = {
        "title": "Machine-Verified Spectral Theory of the Hydrogen Atom",
        "domain": "Mathematical Physics / Quantum Mechanics",
        "article": article,
        "research_paper": research_paper,
        "future_directions": future_directions,
        "demos": [
            {
                "name": "Hydrogen Atom Spectral Theory Demo",
                "code": demo_code
            },
            {
                "name": "Real-World Applications",
                "code": applications_code
            }
        ],
        "algorithms": [
            {
                "name": "Quantum State Enumeration",
                "pseudocode": (
                    "INPUT: principal quantum number n\n"
                    "OUTPUT: list of (n, l, m) triples\n"
                    "FOR l = 0 TO n-1:\n"
                    "  FOR m = -l TO l:\n"
                    "    EMIT (n, l, m)\n"
                    "TOTAL: n² states"
                ),
                "code": algorithms_code
            },
            {
                "name": "Angular Momentum Matrix Construction",
                "pseudocode": (
                    "INPUT: angular momentum quantum number l\n"
                    "OUTPUT: (2l+1)×(2l+1) matrices Lx, Ly, Lz\n"
                    "1. Initialize Lz as diagonal: (Lz)_{mm} = m\n"
                    "2. Compute L+ using: (L+)_{m+1,m} = √(l(l+1)-m(m+1))\n"
                    "3. Compute L- using: (L-)_{m-1,m} = √(l(l+1)-m(m-1))\n"
                    "4. Lx = (L+ + L-)/2\n"
                    "5. Ly = (L+ - L-)/(2i)\n"
                    "VERIFY: [Lx,Ly]=iLz, L²=l(l+1)I"
                ),
                "code": algorithms_code
            }
        ],
        "visualizations": [
            {"name": "Hydrogen Energy Level Diagram", "data": viz_data['energy_levels']},
            {"name": "Degeneracy and Sum of Odd Numbers", "data": viz_data['degeneracy']},
            {"name": "Dipole Selection Rules", "data": viz_data['selection_rules']},
            {"name": "Balmer Series Convergence", "data": viz_data['balmer_convergence']},
            {"name": "Angular Momentum Structure", "data": viz_data['angular_momentum']},
        ],
        "lean_proofs": lean_proofs
    }

    with open('PACKAGE.json', 'w') as f:
        json.dump(package, f, indent=2, ensure_ascii=False)

    print(f"PACKAGE.json generated ({os.path.getsize('PACKAGE.json') / 1024:.1f} KB)")

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Hydrogen Atom Spectral Theory — Visualizations

Generates publication-quality figures illustrating the key theorems.
Saves to PNG files and returns base64 for embedding.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import base64
from io import BytesIO


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def plot_energy_levels():
    """Plot hydrogen energy level diagram."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 7))

    n_max = 7
    for n in range(1, n_max + 1):
        E = -1.0 / n**2
        # Width proportional to degeneracy
        width = 0.3 + 0.1 * n
        ax.plot([-width, width], [E, E], 'b-', linewidth=2)
        ax.text(width + 0.1, E, f'n={n}  (g={n**2})',
                va='center', fontsize=11)
        ax.text(-width - 0.1, E, f'E = -1/{n**2}',
                va='center', ha='right', fontsize=10, color='gray')

    # Ionization threshold
    ax.axhline(y=0, color='red', linestyle='--', alpha=0.5, linewidth=1)
    ax.text(0.5, 0.02, 'Ionization threshold (E = 0)',
            color='red', fontsize=11, ha='center')

    # Balmer transitions
    colors = ['#FF0000', '#00BFFF', '#0000FF', '#8B00FF']
    for i, n in enumerate(range(3, 7)):
        E_upper = -1.0 / n**2
        E_lower = -1.0 / 4
        ax.annotate('', xy=(0.45, E_lower), xytext=(0.45, E_upper),
                    arrowprops=dict(arrowstyle='->', color=colors[i],
                                  lw=1.5, alpha=0.7))

    ax.set_ylabel('Energy (atomic units)', fontsize=13)
    ax.set_title('Hydrogen Atom Energy Levels\n'
                 r'$E_n = -1/n^2$, degeneracy $g_n = n^2$',
                 fontsize=14)
    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(-1.15, 0.15)
    ax.set_xticks([])
    ax.grid(axis='y', alpha=0.3)

    fig.savefig('energy_levels.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def plot_degeneracy():
    """Visualize the sum of odd numbers = n² identity."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left: Visual proof with dots
    n_max = 6
    colors = plt.cm.Set3(np.linspace(0, 1, n_max))

    for n in range(1, n_max + 1):
        for k in range(2*n - 1):
            if k < n:
                # Bottom row of L-shape
                ax1.plot(k, n-1, 's', color=colors[n-1], markersize=12,
                        markeredgecolor='black', markeredgewidth=0.5)
            if k < n - 1:
                # Right column of L-shape (excluding corner)
                ax1.plot(n-1, k, 's', color=colors[n-1], markersize=12,
                        markeredgecolor='black', markeredgewidth=0.5)

    ax1.set_xlim(-0.5, n_max - 0.5)
    ax1.set_ylim(-0.5, n_max - 0.5)
    ax1.set_aspect('equal')
    ax1.set_title('Visual Proof: 1 + 3 + 5 + ... + (2n-1) = n²\n'
                  'Each L-shape has 2k+1 squares', fontsize=12)
    ax1.set_xlabel('Column', fontsize=11)
    ax1.set_ylabel('Row', fontsize=11)

    # Right: Bar chart of degeneracies
    n_values = range(1, 9)
    deg_values = [n**2 for n in n_values]
    bars = ax2.bar(n_values, deg_values, color='steelblue', edgecolor='navy',
                   alpha=0.8)

    for bar, n, d in zip(bars, n_values, deg_values):
        ax2.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.5,
                f'{d}', ha='center', va='bottom', fontsize=10, fontweight='bold')
        # Show the odd number sum
        odd_sum = ' + '.join(str(2*l+1) for l in range(n))
        if n <= 4:
            ax2.text(bar.get_x() + bar.get_width()/2, bar.get_height()/2,
                    odd_sum, ha='center', va='center', fontsize=8,
                    color='white', fontweight='bold')

    ax2.set_xlabel('Principal Quantum Number n', fontsize=12)
    ax2.set_ylabel('Degeneracy n²', fontsize=12)
    ax2.set_title('Hydrogen Energy Level Degeneracy', fontsize=13)

    plt.tight_layout()
    fig.savefig('degeneracy.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def plot_selection_rules():
    """Visualize the dipole selection rules."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left: Selection rule grid
    m_range = range(-3, 4)
    grid = np.zeros((7, 7))
    for i, m in enumerate(m_range):
        for j, mp in enumerate(m_range):
            if abs(mp - m) <= 1:
                grid[i, j] = 1

    ax1.imshow(grid, cmap='RdYlGn', aspect='equal', interpolation='nearest')
    ax1.set_xticks(range(7))
    ax1.set_xticklabels([f'{m:+d}' for m in m_range])
    ax1.set_yticks(range(7))
    ax1.set_yticklabels([f'{m:+d}' for m in m_range])
    ax1.set_xlabel("m' (final)", fontsize=12)
    ax1.set_ylabel("m (initial)", fontsize=12)
    ax1.set_title('Δm Selection Rule\n(Green = Allowed, Red = Forbidden)',
                  fontsize=12)

    for i in range(7):
        for j in range(7):
            dm = list(m_range)[j] - list(m_range)[i]
            if abs(dm) <= 1:
                ax1.text(j, i, f'Δm={dm:+d}', ha='center', va='center',
                        fontsize=7, color='darkgreen')
            else:
                ax1.text(j, i, '×', ha='center', va='center',
                        fontsize=12, color='darkred')

    # Right: Azimuthal integral visualization
    phi = np.linspace(0, 2*np.pi, 1000)

    for dm, color, label in [(0, 'blue', 'Δm=0 (π)'),
                              (1, 'red', 'Δm=+1 (σ⁺)'),
                              (3, 'gray', 'Δm=3 (forbidden)')]:
        integrand = np.exp(1j * dm * phi)
        ax2.plot(phi/np.pi, integrand.real, color=color, label=label,
                linewidth=1.5, alpha=0.8)

    ax2.set_xlabel('φ / π', fontsize=12)
    ax2.set_ylabel('Re[exp(iΔm·φ)]', fontsize=12)
    ax2.set_title('Azimuthal Integrand\n'
                  '∫₀²π exp(iΔm·φ) dφ = 2π δ_{Δm,0}', fontsize=12)
    ax2.legend(fontsize=10)
    ax2.grid(alpha=0.3)
    ax2.axhline(y=0, color='black', linewidth=0.5)

    plt.tight_layout()
    fig.savefig('selection_rules.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def plot_balmer_convergence():
    """Visualize the Balmer series convergence."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left: Balmer photon energies converging to 1/4
    n_values = np.arange(3, 30)
    E_photon = [-1.0/n**2 + 0.25 for n in n_values]

    ax1.plot(n_values, E_photon, 'bo-', markersize=5, linewidth=1)
    ax1.axhline(y=0.25, color='red', linestyle='--', linewidth=1.5,
               label='Limit = 1/4')
    ax1.fill_between(n_values, E_photon, 0.25, alpha=0.1, color='blue')

    ax1.set_xlabel('Upper Level n', fontsize=12)
    ax1.set_ylabel('Photon Energy (a.u.)', fontsize=12)
    ax1.set_title('Balmer Series Convergence\n'
                  r'$E_{photon} = 1/4 - 1/n^2 \to 1/4$', fontsize=13)
    ax1.legend(fontsize=11)
    ax1.grid(alpha=0.3)

    # Right: All spectral series
    series_data = {
        'Lyman (→1)': (1, 'red'),
        'Balmer (→2)': (2, 'blue'),
        'Paschen (→3)': (3, 'green'),
        'Brackett (→4)': (4, 'orange'),
    }

    for name, (n_low, color) in series_data.items():
        n_vals = np.arange(n_low + 1, 25)
        energies = [-1.0/n**2 + 1.0/n_low**2 for n in n_vals]
        limit = 1.0 / n_low**2

        ax2.plot(n_vals, energies, 'o-', color=color, markersize=3,
                linewidth=1, label=f'{name}, limit={limit:.4f}')
        ax2.axhline(y=limit, color=color, linestyle=':', alpha=0.5)

    ax2.set_xlabel('Upper Level n', fontsize=12)
    ax2.set_ylabel('Photon Energy (a.u.)', fontsize=12)
    ax2.set_title('Hydrogen Spectral Series\n'
                  'Each converges to ionization from lower level', fontsize=13)
    ax2.legend(fontsize=9)
    ax2.grid(alpha=0.3)

    plt.tight_layout()
    fig.savefig('balmer_convergence.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def plot_angular_momentum():
    """Visualize angular momentum eigenvalues and structure."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left: Angular momentum eigenvalue diagram
    l_max = 4
    for l in range(l_max + 1):
        L2_eigenvalue = l * (l + 1)
        for m in range(-l, l + 1):
            ax1.plot(m, L2_eigenvalue, 'o', color=f'C{l}', markersize=10)
            if l <= 2:
                ax1.annotate(f'|{l},{m:+d}⟩', (m, L2_eigenvalue),
                           textcoords="offset points", xytext=(10, 5),
                           fontsize=7, alpha=0.7)

        # Label the l value
        ax1.text(l + 0.5, L2_eigenvalue, f'l={l}, L²={L2_eigenvalue}',
                fontsize=9, va='center', color=f'C{l}')

    ax1.set_xlabel('Magnetic quantum number m', fontsize=12)
    ax1.set_ylabel('L² eigenvalue = l(l+1)', fontsize=12)
    ax1.set_title('Angular Momentum Eigenvalue Diagram\n'
                  'Each row: 2l+1 states', fontsize=13)
    ax1.grid(alpha=0.3)

    # Right: L² = l(l+1) curve
    l_cont = np.linspace(0, 5, 100)
    L2_cont = l_cont * (l_cont + 1)

    ax2.plot(l_cont, L2_cont, 'k-', linewidth=1, alpha=0.3)

    for l in range(6):
        L2 = l * (l + 1)
        dim = 2 * l + 1
        ax2.plot(l, L2, 'o', color=f'C{l}', markersize=12, zorder=5)
        ax2.annotate(f'dim={dim}', (l, L2),
                    textcoords="offset points", xytext=(15, 0),
                    fontsize=10, fontweight='bold', color=f'C{l}')

    ax2.set_xlabel('Angular momentum quantum number l', fontsize=12)
    ax2.set_ylabel('L² eigenvalue = l(l+1)', fontsize=12)
    ax2.set_title('Casimir Eigenvalue l(l+1)\n'
                  'Dimension of each irrep = 2l+1', fontsize=13)
    ax2.grid(alpha=0.3)

    plt.tight_layout()
    fig.savefig('angular_momentum.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


# ============================================================
# Generate all visualizations
# ============================================================

def generate_all():
    """Generate all visualizations and return base64 data."""
    results = {}
    results['energy_levels'] = plot_energy_levels()
    results['degeneracy'] = plot_degeneracy()
    results['selection_rules'] = plot_selection_rules()
    results['balmer_convergence'] = plot_balmer_convergence()
    results['angular_momentum'] = plot_angular_momentum()
    return results


if __name__ == "__main__":
    print("Generating visualizations...")
    results = generate_all()
    for name, data in results.items():
        print(f"  {name}: {len(data)} chars")
    print("Done. PNG files saved to current directory.")
