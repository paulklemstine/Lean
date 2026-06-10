#!/usr/bin/env python3
"""
Applications of Finite Abelian Harmonic Analysis

Demonstrates real-world applications of the formally verified theory:
  1. Signal processing: spectral filtering on cyclic groups
  2. Random walks: mixing time analysis via spectral gap
  3. Error-correcting codes: syndrome decoding via characters
  4. Quantum mechanics: momentum eigenstates on finite lattices
"""

import numpy as np
from algorithms import (
    FiniteAbelianGroup, character_table, dft, idft,
    spectral_convolve, spectral_decomposition, mixing_time_estimate,
    verify_all_properties
)


def app_signal_filtering():
    """
    Application 1: Spectral Filtering on Cyclic Groups

    Demonstrates low-pass filtering of a signal on Z/nZ using
    the character basis as the Fourier basis.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 1: Spectral Filtering on Z/16Z")
    print("=" * 60)

    n = 16
    G = FiniteAbelianGroup([n])

    # Create a signal: sum of two "frequencies" plus noise
    t = np.arange(n)
    signal = (np.cos(2 * np.pi * 1 * t / n)     # frequency 1 (low)
              + 0.5 * np.cos(2 * np.pi * 3 * t / n)  # frequency 3 (mid)
              + 0.3 * np.random.randn(n))         # noise

    # DFT
    spectrum = dft(G, signal)
    print(f"\nOriginal signal (first 8 values): {np.round(signal[:8], 3)}")
    print(f"Spectrum magnitudes: {np.round(np.abs(spectrum), 3)}")

    # Low-pass filter: keep only frequencies 0, 1, n-1
    filtered_spectrum = spectrum.copy()
    for i in range(n):
        if i > 2 and i < n - 2:
            filtered_spectrum[i] = 0

    filtered_signal = idft(G, filtered_spectrum)
    print(f"Filtered signal (first 8 values): {np.round(filtered_signal.real[:8], 3)}")
    print(f"Noise reduction: {np.std(signal - np.cos(2*np.pi*t/n) - 0.5*np.cos(2*np.pi*3*t/n)):.3f}"
          f" → {np.std(filtered_signal.real - np.cos(2*np.pi*t/n) - 0.5*np.cos(2*np.pi*3*t/n)):.3f}")


def app_random_walk():
    """
    Application 2: Random Walk Mixing Analysis

    Analyzes mixing times of random walks on finite abelian groups
    using the spectral gap from character eigenvalues.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Random Walk Mixing Analysis")
    print("=" * 60)

    groups_and_walks = [
        ([7], "Z/7Z", "nearest-neighbor"),
        ([12], "Z/12Z", "nearest-neighbor"),
        ([3, 3], "Z/3Z × Z/3Z", "lazy nearest-neighbor"),
        ([2, 2, 2], "(Z/2Z)³", "uniform random bit flip"),
    ]

    for orders, name, walk_type in groups_and_walks:
        G = FiniteAbelianGroup(orders)
        n = G.order

        # Build transition kernel
        kernel = np.zeros(n)
        if walk_type == "nearest-neighbor":
            # Step ±1 in first coordinate
            step_plus = list(G.identity())
            step_plus[0] = 1
            step_minus = list(G.identity())
            step_minus[0] = orders[0] - 1
            kernel[G.elem_to_idx[tuple(step_plus)]] = 0.5
            kernel[G.elem_to_idx[tuple(step_minus)]] = 0.5
        elif walk_type == "lazy nearest-neighbor":
            kernel[G.elem_to_idx[G.identity()]] = 0.5
            step_plus = list(G.identity())
            step_plus[0] = 1
            step_minus = list(G.identity())
            step_minus[0] = orders[0] - 1
            kernel[G.elem_to_idx[tuple(step_plus)]] = 0.25
            kernel[G.elem_to_idx[tuple(step_minus)]] = 0.25
        elif walk_type == "uniform random bit flip":
            kernel[G.elem_to_idx[G.identity()]] = 0.25
            for i in range(len(orders)):
                flip = list(G.identity())
                flip[i] = 1
                kernel[G.elem_to_idx[tuple(flip)]] = 0.25

        decomp = spectral_decomposition(G, kernel)
        t_mix = mixing_time_estimate(G, kernel)

        print(f"\n{name} ({walk_type}):")
        print(f"  |G| = {n}")
        print(f"  Eigenvalues: {np.round(decomp['eigenvalues'].real, 4)}")
        print(f"  Spectral gap: {decomp['spectral_gap']:.6f}")
        print(f"  Estimated mixing time: {t_mix:.1f} steps")

        # Simulate and compare
        distribution = np.zeros(n)
        distribution[0] = 1.0  # start at identity
        steps_to_mix = []
        for step in range(int(t_mix * 3) + 1):
            tv_dist = 0.5 * np.sum(np.abs(distribution - 1.0 / n))
            if tv_dist < 0.01 and not steps_to_mix:
                steps_to_mix.append(step)
            # One step of the walk
            distribution = np.real(spectral_convolve(G, kernel, distribution))

        if steps_to_mix:
            print(f"  Actual mixing time (TV < 0.01): {steps_to_mix[0]} steps")


def app_quantum_lattice():
    """
    Application 3: Quantum Mechanics on a Finite Lattice

    Models a particle on a 1D finite lattice with periodic boundary conditions.
    Characters are momentum eigenstates; the spectral decomposition gives
    the energy spectrum of a translation-invariant Hamiltonian.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Quantum Mechanics on Finite Lattice")
    print("=" * 60)

    n = 8
    G = FiniteAbelianGroup([n])

    # Tight-binding Hamiltonian: H|j⟩ = -t(|j+1⟩ + |j-1⟩)
    # As a convolution kernel: H(0) = 0, H(1) = H(n-1) = -t
    t_hop = 1.0
    H_kernel = np.zeros(n)
    H_kernel[1] = -t_hop
    H_kernel[n - 1] = -t_hop

    table = character_table(G)

    print(f"\nLattice: Z/{n}Z with periodic boundary conditions")
    print(f"Hamiltonian: nearest-neighbor hopping with t = {t_hop}")
    print(f"\nMomentum eigenstates and energies:")

    for k in range(n):
        # Momentum eigenstate |k⟩ = character vector
        psi_k = table[k, :] / np.sqrt(n)  # normalized

        # Energy eigenvalue from convolution_eigenvalue_formula
        E_k = np.sum(H_kernel * np.conj(table[k, :]))

        # Analytical: E(k) = -2t cos(2πk/n)
        E_analytical = -2 * t_hop * np.cos(2 * np.pi * k / n)

        print(f"  k = {k}: E = {E_k.real:+.6f} (analytical: {E_analytical:+.6f})"
              f"  match: {'✓' if abs(E_k.real - E_analytical) < 1e-10 else '✗'}")

    # Time evolution
    print(f"\nTime evolution of localized state |0⟩:")
    psi_0 = np.zeros(n, dtype=complex)
    psi_0[0] = 1.0

    # Expand in momentum basis
    coeffs = table.conj() @ psi_0 / n

    times = [0, 0.5, 1.0, 2.0]
    for t_val in times:
        # |ψ(t)⟩ = ∑_k c_k exp(-iE_k t) |k⟩
        energies = np.array([np.sum(H_kernel * np.conj(table[k, :])).real for k in range(n)])
        evolved_coeffs = coeffs * np.exp(-1j * energies * t_val)
        psi_t = table.T @ evolved_coeffs
        probs = np.abs(psi_t) ** 2
        print(f"  t = {t_val:.1f}: P(site) = {np.round(probs, 4)}")


def app_verification_suite():
    """
    Application 4: Comprehensive Verification Suite

    Runs all formally verified properties on a suite of groups.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Verification Suite")
    print("=" * 60)

    groups = [
        ([2], "Z/2Z"),
        ([3], "Z/3Z"),
        ([4], "Z/4Z"),
        ([5], "Z/5Z"),
        ([6], "Z/6Z"),
        ([2, 2], "Z/2Z × Z/2Z"),
        ([2, 3], "Z/2Z × Z/3Z"),
        ([2, 4], "Z/2Z × Z/4Z"),
        ([3, 3], "Z/3Z × Z/3Z"),
        ([2, 2, 2], "(Z/2Z)³"),
        ([2, 2, 3], "Z/2Z × Z/2Z × Z/3Z"),
    ]

    print(f"\n{'Group':<20} {'Card':>5} {'Orth':>5} {'SIP':>5} {'Sep':>5} {'Det':>5} {'Conv':>5}")
    print("-" * 65)

    for orders, name in groups:
        G = FiniteAbelianGroup(orders)
        results = verify_all_properties(G)
        status = lambda ok: "  ✓" if ok else "  ✗"
        print(f"{name:<20} "
              f"{status(results['card']):>5} "
              f"{status(results['orthogonality']):>5} "
              f"{status(results['self_inner_product']):>5} "
              f"{status(results['separation']):>5} "
              f"{status(results['detection']):>5} "
              f"{status(results['convolution_eigenvector']):>5}")

    all_pass = all(
        all(verify_all_properties(FiniteAbelianGroup(orders)).values())
        for orders, _ in groups
    )
    print(f"\nOverall: {'ALL VERIFIED ✓' if all_pass else 'SOME FAILURES ✗'}")


def main():
    print("╔══════════════════════════════════════════════════════════╗")
    print("║   Applications of Finite Abelian Harmonic Analysis      ║")
    print("╚══════════════════════════════════════════════════════════╝")

    app_signal_filtering()
    app_random_walk()
    app_quantum_lattice()
    app_verification_suite()


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Finite Abelian Harmonic Analysis: Interactive Demo

Demonstrates character tables, regular representation decomposition,
and convolution diagonalization for small finite abelian groups.

Usage: python demo.py
"""

import numpy as np
from itertools import product as cartesian_product

# ============================================================
# Core: Character construction for finite abelian groups
# ============================================================

def cyclic_characters(n):
    """
    Construct all n characters of Z/nZ.
    Character chi_k(j) = exp(2*pi*i*j*k/n) for k=0,...,n-1.
    Returns an n x n matrix where entry [k, j] = chi_k(j).
    """
    omega = np.exp(2j * np.pi / n)
    return np.array([[omega ** (j * k) for j in range(n)] for k in range(n)])


def product_group_characters(orders):
    """
    Construct the full character table for Z/n1 x Z/n2 x ... x Z/nk.

    Parameters:
        orders: list of positive integers [n1, n2, ..., nk]

    Returns:
        char_table: |G| x |G| numpy array
        elements: list of group elements as tuples
        char_labels: list of character labels as tuples
    """
    n = 1
    for o in orders:
        n *= o

    # Group elements
    ranges = [range(o) for o in orders]
    elements = list(cartesian_product(*ranges))

    # Character labels (indices into each cyclic factor's character group)
    char_labels = list(cartesian_product(*ranges))

    # Build character table
    char_table = np.zeros((n, n), dtype=complex)
    for i, klabel in enumerate(char_labels):
        for j, elem in enumerate(elements):
            val = 1.0
            for k_idx, (k, g, order) in enumerate(zip(klabel, elem, orders)):
                val *= np.exp(2j * np.pi * k * g / order)
            char_table[i, j] = val

    return char_table, elements, char_labels


def display_character_table(orders, name=None):
    """Display the character table for a finite abelian group."""
    char_table, elements, char_labels = product_group_characters(orders)
    n = len(elements)

    if name is None:
        name = " × ".join(f"Z/{o}Z" for o in orders)

    print(f"\n{'='*60}")
    print(f"Character Table for {name}")
    print(f"{'='*60}")
    print(f"Group order: {n}")
    print(f"Number of characters: {n}  (= |G|, as expected)")
    print()

    # Print header
    header = "χ\\g  | " + " | ".join(f"{str(e):>10}" for e in elements)
    print(header)
    print("-" * len(header))

    # Print rows
    for i, klabel in enumerate(char_labels):
        row = f"χ_{klabel} | "
        row += " | ".join(f"{char_table[i, j].real:+.4f}{char_table[i, j].imag:+.4f}i"
                          if abs(char_table[i, j].imag) > 1e-10
                          else f"{char_table[i, j].real:+.4f}      "
                          for j in range(n))
        print(row)

    return char_table, elements


def verify_orthogonality(char_table, name=""):
    """Verify orthogonality relations for a character table."""
    n = char_table.shape[0]
    gram = char_table @ char_table.conj().T / n

    print(f"\n--- Orthogonality Check{' for ' + name if name else ''} ---")
    print(f"Gram matrix (should be identity):")

    is_identity = np.allclose(gram, np.eye(n), atol=1e-10)
    print(f"  ||Gram - I||_max = {np.max(np.abs(gram - np.eye(n))):.2e}")
    print(f"  Orthogonality: {'✓ VERIFIED' if is_identity else '✗ FAILED'}")
    return is_identity


def verify_separation(char_table, elements, name=""):
    """Verify that characters separate points."""
    n = len(elements)
    print(f"\n--- Separation Check{' for ' + name if name else ''} ---")

    separates = True
    for i in range(n):
        for j in range(i + 1, n):
            if np.allclose(char_table[:, i], char_table[:, j], atol=1e-10):
                print(f"  ✗ Characters do NOT separate {elements[i]} and {elements[j]}")
                separates = False

    if separates:
        print(f"  ✓ Characters separate all {n} distinct elements")
    return separates


def demo_convolution_eigenvector(orders, f_values=None):
    """
    Demonstrate that characters are eigenvectors of convolution operators.

    For a function f: G -> C, convolution with f acts on each character vector
    by scalar multiplication with the Fourier coefficient.
    """
    char_table, elements, char_labels = product_group_characters(orders)
    n = len(elements)
    name = " × ".join(f"Z/{o}Z" for o in orders)

    if f_values is None:
        np.random.seed(42)
        f_values = np.random.randn(n) + 1j * np.random.randn(n)

    print(f"\n{'='*60}")
    print(f"Convolution Eigenvector Demo for {name}")
    print(f"{'='*60}")

    # Build group operation table (addition in each component)
    def group_add(a, b):
        return tuple((ai + bi) % oi for ai, bi, oi in zip(a, b, orders))

    def group_neg(a):
        return tuple((-ai) % oi for ai, oi in zip(a, orders))

    # Convolution: (f * v)(x) = sum_y f(y) * v(y^{-1} * x)
    elem_to_idx = {e: i for i, e in enumerate(elements)}

    def convolve(f_vals, v_vals):
        result = np.zeros(n, dtype=complex)
        for j, x in enumerate(elements):
            s = 0.0
            for k, y in enumerate(elements):
                y_inv_x = group_add(group_neg(y), x)
                s += f_vals[k] * v_vals[elem_to_idx[y_inv_x]]
                result[j] = s
        return result

    print(f"\nConvolution kernel f: {np.round(f_values, 3)}")
    print()

    all_ok = True
    for i in range(min(n, 6)):  # Show first 6 characters
        chi_vec = char_table[i, :]
        conv_result = convolve(f_values, chi_vec)

        # Compute expected eigenvalue: sum_y f(y) * chi(y)^{-1}
        eigenvalue = np.sum(f_values * np.conj(chi_vec))

        expected = eigenvalue * chi_vec
        is_eigenvector = np.allclose(conv_result, expected, atol=1e-10)

        print(f"  χ_{char_labels[i]}: eigenvalue = {eigenvalue:.4f}")
        print(f"    ||conv(f, χ) - λ·χ||_max = {np.max(np.abs(conv_result - expected)):.2e}"
              f"  {'✓' if is_eigenvector else '✗'}")

        if not is_eigenvector:
            all_ok = False

    if all_ok:
        print(f"\n  ✓ All characters verified as convolution eigenvectors!")
    return all_ok


def demo_nontrivial_detection(orders):
    """
    Demonstrate that characters detect nontrivial elements:
    for every g ≠ 1, there exists χ with χ(g) ≠ 1.
    """
    char_table, elements, char_labels = product_group_characters(orders)
    n = len(elements)
    name = " × ".join(f"Z/{o}Z" for o in orders)
    identity = tuple(0 for _ in orders)

    print(f"\n{'='*60}")
    print(f"Nontrivial Element Detection for {name}")
    print(f"{'='*60}")

    all_detected = True
    for j, elem in enumerate(elements):
        if elem == identity:
            continue

        # Find a character that distinguishes this element from identity
        detected = False
        for i in range(n):
            if abs(char_table[i, j] - 1.0) > 1e-10:
                print(f"  g = {elem}: detected by χ_{char_labels[i]}"
                      f" (χ(g) = {char_table[i, j]:.4f})")
                detected = True
                break

        if not detected:
            print(f"  ✗ g = {elem}: NOT detected by any character!")
            all_detected = False

    if all_detected:
        print(f"\n  ✓ All {n - 1} nontrivial elements detected!")
    return all_detected


def demo_invertibility(orders):
    """
    Demonstrate that the character table matrix is invertible
    (which is equivalent to characters forming a basis).
    """
    char_table, elements, _ = product_group_characters(orders)
    n = len(elements)
    name = " × ".join(f"Z/{o}Z" for o in orders)

    print(f"\n--- Character Table Invertibility for {name} ---")

    det = np.linalg.det(char_table)
    cond = np.linalg.cond(char_table)

    print(f"  |det(CharTable)| = {abs(det):.4f}")
    print(f"  Condition number = {cond:.4f}")
    print(f"  Normalized: |det|/n^(n/2) = {abs(det) / n**(n/2):.6f}")

    # For the character table of Z/nZ, the matrix is the DFT matrix
    # scaled by sqrt(n), so |det| = n^(n/2)
    is_invertible = abs(det) > 1e-10
    print(f"  Invertible: {'✓' if is_invertible else '✗'}")
    return is_invertible


# ============================================================
# Main demo
# ============================================================

def main():
    print("╔══════════════════════════════════════════════════════════╗")
    print("║   Finite Abelian Harmonic Analysis: Interactive Demo    ║")
    print("║                                                        ║")
    print("║   Verified spectral decomposition of the regular       ║")
    print("║   representation via character theory                  ║")
    print("╚══════════════════════════════════════════════════════════╝")

    # Demo 1: Character tables for various groups
    groups = [
        [2],        # Z/2Z
        [3],        # Z/3Z
        [4],        # Z/4Z
        [5],        # Z/5Z
        [6],        # Z/6Z
        [2, 2],     # Z/2Z × Z/2Z (Klein four-group)
        [2, 4],     # Z/2Z × Z/4Z
    ]

    for orders in groups:
        name = " × ".join(f"Z/{o}Z" for o in orders)
        char_table, elements = display_character_table(orders, name)
        verify_orthogonality(char_table, name)
        verify_separation(char_table, elements, name)
        demo_invertibility(orders)

    # Demo 2: Convolution eigenvectors
    for orders in [[3], [4], [2, 2], [2, 3]]:
        demo_convolution_eigenvector(orders)

    # Demo 3: Nontrivial element detection
    for orders in [[2], [3], [5], [2, 2], [2, 4]]:
        demo_nontrivial_detection(orders)

    # Demo 4: Spectral decomposition of a random walk kernel
    print(f"\n{'='*60}")
    print(f"Spectral Decomposition of Random Walk on Z/5Z")
    print(f"{'='*60}")

    n = 5
    char_table, elements, char_labels = product_group_characters([n])

    # Symmetric random walk kernel: move left or right with prob 1/2
    rw_kernel = np.zeros(n)
    rw_kernel[1] = 0.5   # step right
    rw_kernel[n-1] = 0.5  # step left

    print(f"\nRandom walk kernel: {rw_kernel}")
    print(f"\nSpectral decomposition:")

    eigenvalues = []
    for i in range(n):
        ev = np.sum(rw_kernel * np.conj(char_table[i, :]))
        eigenvalues.append(ev)
        print(f"  χ_{i}: eigenvalue = {ev.real:+.6f}"
              f" (= cos(2π·{i}/{n}) = {np.cos(2*np.pi*i/n):+.6f})")

    print(f"\nMixing time estimate (spectral gap):")
    sorted_evs = sorted([abs(ev) for ev in eigenvalues], reverse=True)
    if len(sorted_evs) > 1:
        spectral_gap = 1 - sorted_evs[1]
        print(f"  Second largest |eigenvalue| = {sorted_evs[1]:.6f}")
        print(f"  Spectral gap = {spectral_gap:.6f}")
        print(f"  Mixing time ≈ 1/gap = {1/spectral_gap:.1f} steps")

    print(f"\n{'='*60}")
    print("All demos completed successfully!")
    print(f"{'='*60}")


if __name__ == "__main__":
    main()
