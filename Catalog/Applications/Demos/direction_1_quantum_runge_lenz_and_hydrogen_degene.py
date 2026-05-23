#!/usr/bin/env python3
"""
Real-world applications of the Quantum Runge-Lenz Algebra.

Demonstrates how the so(4) symmetry structure of hydrogen connects to:
  1. Atomic spectroscopy (predicting spectral lines)
  2. Astrophysics (hydrogen recombination lines)
  3. Quantum chemistry (orbital structure)
  4. Spectral geometry (Laplacian on S³)
"""

import math


# ─── Constants ────────────────────────────────────────────────────────

HBAR = 1.054571817e-34   # J·s
M_E  = 9.1093837015e-31  # kg
K_C  = 2.307077552e-28   # N·m²
EV   = 1.602176634e-19   # J/eV
H_PLANCK = 6.62607015e-34  # J·s
C_LIGHT = 299792458       # m/s
RYDBERG_EV = M_E * K_C**2 / (2 * HBAR**2 * EV)  # ~13.6 eV


# ─── Application 1: Atomic Spectroscopy ──────────────────────────────

def spectral_series_table():
    """
    Generate the complete hydrogen spectral series table.

    The n² degeneracy from so(4) symmetry means each energy level
    contains states with angular momentum l = 0, 1, ..., n-1.
    Selection rules (Δl = ±1) determine which transitions are allowed.
    """
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  APPLICATION 1: HYDROGEN SPECTRAL SERIES                ║")
    print("╚══════════════════════════════════════════════════════════╝\n")

    series_names = {
        1: ("Lyman",    "UV"),
        2: ("Balmer",   "Visible/UV"),
        3: ("Paschen",  "IR"),
        4: ("Brackett", "IR"),
        5: ("Pfund",    "Far IR"),
    }

    for n_lower in range(1, 6):
        name, region = series_names[n_lower]
        print(f"  {name} Series (n → {n_lower}) [{region}]")
        print(f"  {'─'*50}")

        for n_upper in range(n_lower + 1, n_lower + 7):
            dE = RYDBERG_EV * (1/n_lower**2 - 1/n_upper**2)
            lam = H_PLANCK * C_LIGHT / (dE * EV) * 1e9  # nm

            # Count allowed transitions (selection rule Δl = ±1)
            allowed = 0
            for l_upper in range(n_upper):
                for l_lower in range(n_lower):
                    if abs(l_upper - l_lower) == 1:
                        # Each (l_upper, l_lower) gives min(2l+1, 2l'+1) transitions
                        allowed += min(2*l_upper + 1, 2*l_lower + 1)

            print(f"    n={n_upper:2d} → {n_lower}: "
                  f"λ = {lam:8.1f} nm, "
                  f"ΔE = {dE:.4f} eV, "
                  f"allowed transitions: {allowed}")

        # Series limit
        dE_limit = RYDBERG_EV / n_lower**2
        lam_limit = H_PLANCK * C_LIGHT / (dE_limit * EV) * 1e9
        print(f"    n=∞  → {n_lower}: λ = {lam_limit:8.1f} nm (series limit)")
        print()


# ─── Application 2: Astrophysics ─────────────────────────────────────

def hydrogen_recombination_lines():
    """
    Hydrogen recombination lines observed in astrophysics.

    The n² degeneracy determines the statistical weights used in
    the Boltzmann equation for level populations in stellar atmospheres.
    """
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  APPLICATION 2: ASTROPHYSICAL HYDROGEN LINES            ║")
    print("╚══════════════════════════════════════════════════════════╝\n")

    print("  Statistical weights (from n² degeneracy × spin):")
    print(f"  {'n':>3s} {'g_n = 2n²':>10s} {'E_n (eV)':>10s} {'Ionization (eV)':>16s}")
    print(f"  {'─'*42}")
    for n in range(1, 11):
        g_n = 2 * n**2  # factor of 2 for electron spin
        E_n = -RYDBERG_EV / n**2
        ionization = RYDBERG_EV / n**2
        print(f"  {n:3d} {g_n:10d} {E_n:10.4f} {ionization:16.4f}")

    print(f"\n  Balmer series (visible hydrogen lines in stellar spectra):")
    balmer_names = {3: "Hα", 4: "Hβ", 5: "Hγ", 6: "Hδ", 7: "Hε"}
    for n2, name in balmer_names.items():
        dE = RYDBERG_EV * (1/4 - 1/n2**2)
        lam = H_PLANCK * C_LIGHT / (dE * EV) * 1e9
        color = ""
        if 620 < lam < 750: color = "(red)"
        elif 495 < lam < 620: color = "(green/yellow)"
        elif 450 < lam < 495: color = "(blue)"
        elif 380 < lam < 450: color = "(violet)"
        print(f"    {name}: λ = {lam:.1f} nm {color}")

    # Temperature for Balmer absorption
    print(f"\n  For Balmer lines: need electrons in n=2")
    print(f"  Excitation energy n=1→2: {RYDBERG_EV * 3/4:.2f} eV")
    print(f"  Corresponding temperature: {RYDBERG_EV * 3/4 * EV / 1.38e-23:.0f} K")


# ─── Application 3: Quantum Chemistry ────────────────────────────────

def orbital_structure():
    """
    Display the orbital structure of hydrogen-like atoms.

    The so(4) symmetry explains why all orbitals with the same n
    have the same energy (in hydrogen), which is NOT the case for
    multi-electron atoms where the degeneracy is partially broken.
    """
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  APPLICATION 3: HYDROGEN ORBITAL STRUCTURE              ║")
    print("╚══════════════════════════════════════════════════════════╝\n")

    orbital_names = {0: "s", 1: "p", 2: "d", 3: "f", 4: "g"}

    for n in range(1, 6):
        E = -RYDBERG_EV / n**2
        print(f"  Shell n={n} (E = {E:.4f} eV)")
        orbitals = []
        total = 0
        for l in range(n):
            name = orbital_names.get(l, f"l={l}")
            dim = 2 * l + 1
            orbitals.append(f"{n}{name}({dim})")
            total += dim
        print(f"    Orbitals: {', '.join(orbitals)}")
        print(f"    Total states: {total} (= n² = {n}²)")
        print(f"    With spin: {2*total} (= 2n²)")
        print()

    print("  The so(4) symmetry explains the 'accidental' degeneracy:")
    print("  In hydrogen, 2s and 2p have the SAME energy (both in n=2 shell)")
    print("  In helium, 2s and 2p have DIFFERENT energies (so(4) broken)")
    print("  This is because the 1/r potential has a hidden SO(4) symmetry")
    print("  that is destroyed by electron-electron interactions.\n")


# ─── Application 4: Spectral Geometry Connection ─────────────────────

def s3_laplacian_correspondence():
    """
    Demonstrate the correspondence between hydrogen energy levels
    and the Laplacian on S³.

    The eigenvalues of Δ_{S³} are λ_k = k(k+2) with multiplicity (k+1)².
    The hydrogen degeneracy n² corresponds to the k=(n-1) eigenspace.
    """
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  APPLICATION 4: SPECTRAL GEOMETRY — LAPLACIAN ON S³     ║")
    print("╚══════════════════════════════════════════════════════════╝\n")

    print(f"  {'k':>3s} {'λ_k = k(k+2)':>14s} {'mult = (k+1)²':>15s} {'H atom n':>10s} {'n²':>5s}")
    print(f"  {'─'*50}")
    for k in range(8):
        lam = k * (k + 2)
        mult = (k + 1)**2
        n = k + 1
        print(f"  {k:3d} {lam:14d} {mult:15d} {n:10d} {n**2:5d}")

    print(f"\n  The correspondence: hydrogen shell n ↔ S³ eigenspace k = n-1")
    print(f"  Both have the same degeneracy: n² = (k+1)²")
    print(f"  This is because the Kepler problem can be mapped to")
    print(f"  geodesic flow on S³ via the Moser regularization.\n")

    # Verify the identity
    print(f"  Verification: Casimir C_n = ℏ²(n²-1) vs S³ eigenvalue λ_{'{n-1}'} = (n-1)(n+1) = n²-1")
    for n in range(1, 8):
        k = n - 1
        casimir_coeff = n**2 - 1
        s3_eigenvalue = k * (k + 2)
        match = "✓" if casimir_coeff == s3_eigenvalue else "✗"
        print(f"    n={n}, k={k}: C/ℏ² = {casimir_coeff}, λ_k = {s3_eigenvalue} {match}")


# ─── Main ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    spectral_series_table()
    hydrogen_recombination_lines()
    orbital_structure()
    s3_laplacian_correspondence()


#!/usr/bin/env python3
"""
Interactive demonstration of the Quantum Runge-Lenz Algebra
and the algebraic derivation of hydrogen atom degeneracy.

Implements the verified formulas:
  - Casimir eigenvalue: C_n = ℏ²(n² - 1)
  - Energy levels: E_n = -mk²/(2ℏ²n²)
  - Degeneracy: dim(V_n) = n²
  - Branching rule: n² = Σ_{l=0}^{n-1} (2l+1)
  - so(4) quantum numbers: j⁺ = j⁻ = (n-1)/2
"""

import math


# Physical constants (SI units)
HBAR = 1.054571817e-34   # J·s
M_E  = 9.1093837015e-31  # kg (electron mass)
K_C  = 2.307077552e-28   # N·m² (= e²/(4πε₀) in SI)
EV   = 1.602176634e-19   # J per eV


def hydrogen_energy(n: int, hbar: float = HBAR, m: float = M_E, k: float = K_C) -> float:
    """Hydrogen energy level E_n = -mk²/(2ℏ²n²)"""
    return -(m * k**2) / (2 * hbar**2 * n**2)


def casimir_eigenvalue(n: int, hbar: float = HBAR) -> float:
    """Casimir eigenvalue C_n = ℏ²(n² - 1)"""
    return hbar**2 * (n**2 - 1)


def hydrogen_degeneracy(n: int) -> int:
    """Degeneracy of the n-th energy level: n²"""
    return n**2


def so4_quantum_numbers(n: int) -> float:
    """so(4) quantum number j⁺ = j⁻ = (n-1)/2"""
    return (n - 1) / 2.0


def angular_momentum_decomposition(n: int) -> list:
    """
    Branching rule: V_n decomposes under so(3) as
    V_n = ⊕_{l=0}^{n-1} V_{2l+1}
    Returns list of (l, 2l+1) pairs.
    """
    return [(l, 2*l + 1) for l in range(n)]


def verify_branching_rule(n: int) -> bool:
    """Verify n² = Σ_{l=0}^{n-1} (2l+1)"""
    return sum(2*l + 1 for l in range(n)) == n**2


def spectral_transition(n1: int, n2: int, hbar: float = HBAR,
                         m: float = M_E, k: float = K_C) -> float:
    """
    Photon energy for transition n2 → n1 (n2 > n1).
    ΔE = E_{n1} - E_{n2} = mk²/(2ℏ²) · (1/n1² - 1/n2²)
    """
    return (m * k**2) / (2 * hbar**2) * (1/n1**2 - 1/n2**2)


def display_shell(n: int):
    """Display complete information about hydrogen shell n."""
    print(f"\n{'='*60}")
    print(f"  HYDROGEN SHELL n = {n}")
    print(f"{'='*60}")

    j = so4_quantum_numbers(n)
    print(f"\n  so(4) quantum numbers:")
    print(f"    j⁺ = j⁻ = {j}")
    print(f"    (2j⁺+1)(2j⁻+1) = {int(2*j+1)}² = {int(2*j+1)**2}")

    C = casimir_eigenvalue(n)
    print(f"\n  Casimir eigenvalue:")
    print(f"    C_n = ℏ²(n²-1) = ℏ² × {n**2 - 1}")
    print(f"    C_n = {C:.6e} J²·s²")

    E = hydrogen_energy(n)
    print(f"\n  Energy level:")
    print(f"    E_n = -mk²/(2ℏ²n²)")
    print(f"    E_n = {E:.6e} J")
    print(f"    E_n = {E/EV:.4f} eV")

    deg = hydrogen_degeneracy(n)
    print(f"\n  Degeneracy: {deg}")

    decomp = angular_momentum_decomposition(n)
    print(f"\n  Angular momentum decomposition (so(3) branching rule):")
    print(f"    V_{n} = ", end="")
    parts = []
    for l, dim in decomp:
        parts.append(f"V_{{{2*l+1}}}(l={l})")
    print(" ⊕ ".join(parts))
    print(f"    Dimensions: {' + '.join(str(d) for _, d in decomp)} = {sum(d for _, d in decomp)}")
    print(f"    Verified: {verify_branching_rule(n)}")

    if n >= 2:
        print(f"\n  Transitions to ground state:")
        dE = spectral_transition(1, n)
        wavelength = 6.626e-34 * 3e8 / dE  # λ = hc/ΔE
        print(f"    ΔE(n→1) = {dE/EV:.4f} eV")
        print(f"    λ = {wavelength*1e9:.2f} nm")


def display_degeneracy_tower(N: int):
    """Display the degeneracy tower for shells 1 through N."""
    print(f"\n{'='*60}")
    print(f"  HYDROGEN DEGENERACY TOWER (n = 1 to {N})")
    print(f"{'='*60}\n")

    total = 0
    for n in range(1, N+1):
        deg = hydrogen_degeneracy(n)
        total += deg
        E = hydrogen_energy(n)
        bar = "█" * deg
        print(f"  n={n:2d} | E = {E/EV:8.4f} eV | deg = {deg:3d} | {bar}")

    print(f"\n  Total states (1 to {N}): {total}")
    print(f"  Formula: Σn² = {N}·{N+1}·{2*N+1}/6 = {N*(N+1)*(2*N+1)//6}")
    assert total == N*(N+1)*(2*N+1)//6


def verify_tropical_conjecture(N: int = 50):
    """Verify the tropical spectral gap conjecture for n = 1,...,N."""
    print(f"\n{'='*60}")
    print(f"  TROPICAL HYDROGEN SPECTRUM VERIFICATION (n ≤ {N})")
    print(f"{'='*60}\n")

    all_pass = True
    for n in range(1, N+1):
        # Tropical spectral gap: log((n+1)²) - log(n²) = 2(log(n+1) - log(n))
        lhs = math.log((n+1)**2) - math.log(n**2)
        rhs = 2 * (math.log(n+1) - math.log(n))
        gap = abs(lhs - rhs)
        if gap > 1e-12:
            print(f"  FAIL at n={n}: |gap| = {gap}")
            all_pass = False

    if all_pass:
        print(f"  ✓ Tropical spectral gap verified for all n = 1,...,{N}")
    else:
        print(f"  ✗ Tropical spectral gap FAILED")

    # Verify tropical Casimir eigenvalues
    print(f"\n  Tropical Casimir eigenvalues (Trop(C_n) = 2·log(n) for large n):")
    for n in [1, 2, 5, 10, 20, 50]:
        if n > 0 and n**2 - 1 > 0:
            trop_C = math.log(n**2 - 1)
            trop_approx = 2 * math.log(n)
            rel_err = abs(trop_C - trop_approx) / trop_approx if trop_approx != 0 else float('inf')
            print(f"    n={n:3d}: Trop(C) = {trop_C:.6f}, 2·log(n) = {trop_approx:.6f}, "
                  f"rel.err = {rel_err:.6f}")


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Quantum Runge-Lenz Algebra: Hydrogen Atom Degeneracy   ║")
    print("║  Based on Pauli's 1926 Algebraic Method                 ║")
    print("╚══════════════════════════════════════════════════════════╝")

    # Display first few shells
    for n in range(1, 5):
        display_shell(n)

    # Display degeneracy tower
    display_degeneracy_tower(10)

    # Verify tropical conjecture
    verify_tropical_conjecture(50)

    # Spectral series
    print(f"\n{'='*60}")
    print(f"  HYDROGEN SPECTRAL SERIES")
    print(f"{'='*60}\n")

    series = {
        "Lyman":   (1, range(2, 8)),
        "Balmer":  (2, range(3, 8)),
        "Paschen": (3, range(4, 8)),
    }

    for name, (n1, n2_range) in series.items():
        print(f"  {name} series (→ n={n1}):")
        for n2 in n2_range:
            dE = spectral_transition(n1, n2)
            lam = 6.626e-34 * 3e8 / dE * 1e9  # nm
            ratio = f"1/{n1}² - 1/{n2}²"
            print(f"    n={n2} → n={n1}: {ratio:12s} = {1/n1**2 - 1/n2**2:.6f}  "
                  f"λ = {lam:8.2f} nm  E = {dE/EV:.4f} eV")
        print()
