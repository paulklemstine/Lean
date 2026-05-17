#!/usr/bin/env python3
"""
Hydrogen Atom Spectral Theory — Algorithms

Implements the core computational algorithms related to the
formalized theorems:
  - Quantum state enumeration and counting
  - Azimuthal dipole integral computation
  - Energy level and spectral series computation
  - Angular momentum matrix construction for arbitrary l
"""

import numpy as np
from typing import List, Tuple, Optional


# ============================================================
# Algorithm 1: Quantum State Enumeration
# ============================================================

def enumerate_quantum_states(n: int) -> List[Tuple[int, int, int]]:
    """
    Enumerate all valid hydrogen quantum states (n, l, m) for
    principal quantum number n.

    Time complexity: O(n²) — matches the degeneracy count.
    Space complexity: O(n²) for the output list.

    Args:
        n: Principal quantum number (≥ 1)

    Returns:
        List of (n, l, m) tuples

    Example:
        >>> enumerate_quantum_states(2)
        [(2, 0, 0), (2, 1, -1), (2, 1, 0), (2, 1, 1)]
    """
    if n < 1:
        raise ValueError(f"n must be ≥ 1, got {n}")

    states = []
    for l in range(n):
        for m in range(-l, l + 1):
            states.append((n, l, m))
    return states


def count_states_up_to(N: int) -> int:
    """
    Count total hydrogen states with principal quantum number 1 to N.
    Uses the verified formula: total = N(N+1)(2N+1)/6.

    Time complexity: O(1)

    Args:
        N: Maximum principal quantum number

    Returns:
        Total number of states = ∑_{n=1}^{N} n²

    Example:
        >>> count_states_up_to(3)
        14
    """
    return N * (N + 1) * (2 * N + 1) // 6


def verify_degeneracy(n: int) -> bool:
    """
    Verify the degeneracy theorem ∑_{l=0}^{n-1} (2l+1) = n² computationally.

    Args:
        n: Principal quantum number

    Returns:
        True if the identity holds
    """
    return sum(2 * l + 1 for l in range(n)) == n ** 2


# ============================================================
# Algorithm 2: Azimuthal Dipole Integral
# ============================================================

def azimuthal_dipole_integral(m: int, mp: int, q: int,
                               num_points: int = 10000) -> complex:
    """
    Compute the azimuthal dipole integral:
        I_q(m, m') = ∫₀²π exp(i(m - m' + q)φ) dφ

    This integral equals 2π if m' = m + q, and 0 otherwise
    (proven formally as selection rule theorems).

    Time complexity: O(num_points) for numerical integration
    Space complexity: O(num_points)

    Args:
        m: Initial magnetic quantum number
        mp: Final magnetic quantum number
        q: Polarization component (-1, 0, or +1)
        num_points: Number of quadrature points

    Returns:
        Complex value of the integral

    Example:
        >>> abs(azimuthal_dipole_integral(1, 2, 1) - 2*np.pi) < 0.01
        True
        >>> abs(azimuthal_dipole_integral(1, 3, 1)) < 0.01
        True
    """
    phi = np.linspace(0, 2 * np.pi, num_points, endpoint=False)
    dphi = 2 * np.pi / num_points
    n = m - mp + q
    integrand = np.exp(1j * n * phi)
    return np.sum(integrand) * dphi


def is_dipole_allowed(m: int, mp: int) -> bool:
    """
    Check if a dipole transition m → m' is allowed by the Δm selection rule.

    The transition is allowed iff m' - m ∈ {-1, 0, +1}, i.e.,
    there exists a polarization component q that makes the integral nonzero.

    Time complexity: O(1)

    Args:
        m: Initial magnetic quantum number
        mp: Final magnetic quantum number

    Returns:
        True if the transition is allowed

    Example:
        >>> is_dipole_allowed(0, 1)
        True
        >>> is_dipole_allowed(0, 3)
        False
    """
    return abs(mp - m) <= 1


def selection_rule_table(l_max: int = 3) -> None:
    """
    Print a table showing allowed and forbidden dipole transitions
    for magnetic quantum numbers up to ±l_max.

    Args:
        l_max: Maximum |m| value to display
    """
    print(f"  Dipole Selection Rule Table (|m| ≤ {l_max})")
    print(f"  m' →  ", end="")
    for mp in range(-l_max, l_max + 1):
        print(f"{mp:+3d} ", end="")
    print()
    print("  " + "-" * (6 + 4 * (2 * l_max + 1)))

    for m in range(-l_max, l_max + 1):
        print(f"  m={m:+2d}  ", end="")
        for mp in range(-l_max, l_max + 1):
            if is_dipole_allowed(m, mp):
                print("  ✓ ", end="")
            else:
                print("  · ", end="")
        print()


# ============================================================
# Algorithm 3: Energy Level Computation
# ============================================================

def hydrogen_energy(n: int, Z: int = 1) -> float:
    """
    Compute hydrogen-like atom energy level.
    E_n = -Z²/n² in atomic units (with our normalization).

    For hydrogen (Z=1): E_n = -1/n².

    Time complexity: O(1)

    Args:
        n: Principal quantum number (≥ 1)
        Z: Nuclear charge (default 1 for hydrogen)

    Returns:
        Energy in atomic units (negative for bound states)

    Example:
        >>> hydrogen_energy(1)
        -1.0
        >>> hydrogen_energy(2)
        -0.25
    """
    if n < 1:
        raise ValueError(f"n must be ≥ 1, got {n}")
    return -Z**2 / n**2


def balmer_photon_energy(n: int) -> float:
    """
    Compute Balmer series photon energy for transition n → 2.
    E_photon = E_n - E_2 = 1/4 - 1/n²

    The limit as n → ∞ is 1/4 (proven formally as balmer_series_limit).

    Time complexity: O(1)

    Args:
        n: Upper level (≥ 3)

    Returns:
        Photon energy in atomic units
    """
    return hydrogen_energy(n) - hydrogen_energy(2)


def spectral_series(name: str, n_lower: int, n_upper_max: int = 20) -> List[Tuple[int, float, float]]:
    """
    Compute a hydrogen spectral series.

    Args:
        name: Series name (for display)
        n_lower: Lower level quantum number
        n_upper_max: Maximum upper level

    Returns:
        List of (n_upper, E_photon, wavelength_nm) tuples
    """
    E_au_to_eV = 27.2114  # 1 Hartree in eV
    hc = 1240.0  # eV·nm

    results = []
    for n in range(n_lower + 1, n_upper_max + 1):
        E_photon = hydrogen_energy(n) - hydrogen_energy(n_lower)
        E_eV = E_photon * E_au_to_eV
        wavelength = hc / E_eV if E_eV > 0 else float('inf')
        results.append((n, E_photon, wavelength))
    return results


# ============================================================
# Algorithm 4: Angular Momentum Matrix Construction
# ============================================================

def angular_momentum_matrices(l: int) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    """
    Construct the (2l+1) × (2l+1) matrix representations of
    Lx, Ly, Lz for angular momentum quantum number l.

    Uses the ladder operator construction:
    L± = Lx ± iLy
    ⟨l,m'|L+|l,m⟩ = √(l(l+1) - m(m+1)) δ_{m',m+1}
    ⟨l,m'|L-|l,m⟩ = √(l(l+1) - m(m-1)) δ_{m',m-1}
    ⟨l,m'|Lz|l,m⟩ = m δ_{m',m}

    Time complexity: O(l²) for matrix construction
    Space complexity: O(l²) for the matrices

    Args:
        l: Angular momentum quantum number (non-negative integer)

    Returns:
        Tuple (Lx, Ly, Lz) of complex numpy arrays

    Example:
        >>> Lx, Ly, Lz = angular_momentum_matrices(1)
        >>> np.allclose(Lx @ Ly - Ly @ Lx, 1j * Lz)
        True
    """
    dim = 2 * l + 1
    Lz = np.zeros((dim, dim), dtype=complex)
    Lp = np.zeros((dim, dim), dtype=complex)
    Lm = np.zeros((dim, dim), dtype=complex)

    # m values: l, l-1, ..., -l (row/column index i corresponds to m = l - i)
    for i in range(dim):
        m = l - i
        Lz[i, i] = m

        if i > 0:  # L+ raises m by 1 (decreases index by 1)
            m_low = m
            Lp[i-1, i] = np.sqrt(l*(l+1) - m_low*(m_low+1))

        if i < dim - 1:  # L- lowers m by 1 (increases index by 1)
            m_high = m
            Lm[i+1, i] = np.sqrt(l*(l+1) - m_high*(m_high-1))

    Lx = (Lp + Lm) / 2
    Ly = (Lp - Lm) / (2j)

    return Lx, Ly, Lz


def verify_commutation_relations(l: int) -> dict:
    """
    Verify all angular momentum commutation relations for given l.

    Returns:
        Dictionary with error norms for each relation
    """
    Lx, Ly, Lz = angular_momentum_matrices(l)

    results = {
        "[Lx,Ly]=iLz": np.max(np.abs(Lx @ Ly - Ly @ Lx - 1j * Lz)),
        "[Ly,Lz]=iLx": np.max(np.abs(Ly @ Lz - Lz @ Ly - 1j * Lx)),
        "[Lz,Lx]=iLy": np.max(np.abs(Lz @ Lx - Lx @ Lz - 1j * Ly)),
    }

    L2 = Lx @ Lx + Ly @ Ly + Lz @ Lz
    expected_L2 = l * (l + 1) * np.eye(2*l+1, dtype=complex)
    results["L²=l(l+1)I"] = np.max(np.abs(L2 - expected_L2))

    return results


# ============================================================
# Algorithm 5: Transition Rate Computation
# ============================================================

def transition_graph(n_max: int = 4) -> List[Tuple[Tuple[int,int,int], Tuple[int,int,int], str]]:
    """
    Compute the allowed electric dipole transition graph between
    hydrogen states up to principal quantum number n_max.

    Selection rules: Δl = ±1, Δm = 0, ±1.
    (Δl rule is assumed here; Δm rule is formally proven.)

    Time complexity: O(n_max^6) in the worst case
    Space complexity: O(n_max^4) for the transition list

    Args:
        n_max: Maximum principal quantum number

    Returns:
        List of (initial_state, final_state, polarization) tuples
    """
    transitions = []
    for n1 in range(1, n_max + 1):
        for l1 in range(n1):
            for m1 in range(-l1, l1 + 1):
                for n2 in range(1, n_max + 1):
                    for l2 in range(n2):
                        for m2 in range(-l2, l2 + 1):
                            # Check Δl = ±1
                            if abs(l2 - l1) != 1:
                                continue
                            # Check Δm = 0, ±1
                            dm = m2 - m1
                            if abs(dm) > 1:
                                continue
                            # Determine polarization
                            if dm == 0:
                                pol = "π"
                            elif dm == 1:
                                pol = "σ+"
                            else:
                                pol = "σ-"
                            transitions.append(((n1, l1, m1), (n2, l2, m2), pol))
    return transitions


# ============================================================
# Main — Run all demos
# ============================================================

if __name__ == "__main__":
    print("Hydrogen Atom — Algorithm Demonstrations\n")

    # Degeneracy verification
    print("1. Degeneracy verification (n=1..20):")
    all_ok = all(verify_degeneracy(n) for n in range(1, 21))
    print(f"   All identities verified: {all_ok}\n")

    # Selection rule table
    print("2. Selection rule table:")
    selection_rule_table(3)
    print()

    # Commutation relations for l=0..5
    print("3. Commutation relation verification:")
    for l in range(6):
        results = verify_commutation_relations(l)
        max_err = max(results.values())
        print(f"   l={l}: max error = {max_err:.2e} {'✓' if max_err < 1e-10 else '✗'}")
    print()

    # Spectral series
    print("4. Spectral series:")
    for name, n_lower in [("Lyman", 1), ("Balmer", 2), ("Paschen", 3)]:
        series = spectral_series(name, n_lower, 10)
        limit = -hydrogen_energy(n_lower)
        print(f"   {name} series (n_lower={n_lower}), limit → {limit:.4f} a.u.:")
        for n, E, wl in series[:5]:
            print(f"     n={n}: E={E:.6f} a.u., λ={wl:.1f} nm")
    print()

    # Transition graph
    print("5. Allowed transitions (n ≤ 3):")
    transitions = transition_graph(3)
    print(f"   Total allowed transitions: {len(transitions)}")
    for (s1, s2, pol) in transitions[:10]:
        print(f"   {s1} → {s2}  [{pol}]")
    if len(transitions) > 10:
        print(f"   ... and {len(transitions) - 10} more")
