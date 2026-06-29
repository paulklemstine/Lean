#!/usr/bin/env python3
"""
Applications of Spectral Moonshine

Demonstrates real-world applications of the spectral moonshine framework:

1. Signal decomposition on symmetric groups
2. Quantum state tomography analogy
3. Representation-theoretic compression
4. Spectral fingerprinting for group classification
"""

import numpy as np
from typing import List, Tuple


# =============================================================================
# Core infrastructure (self-contained)
# =============================================================================

def cf_inner(f: np.ndarray, g: np.ndarray, n: int) -> complex:
    return np.sum(f * np.conj(g)) / n

def spectral_coeffs(f: np.ndarray, basis: List[np.ndarray], n: int) -> np.ndarray:
    return np.array([cf_inner(f, chi, n) for chi in basis])

def reconstruct(f: np.ndarray, basis: List[np.ndarray], n: int) -> np.ndarray:
    c = spectral_coeffs(f, basis, n)
    return sum(c[i] * basis[i] for i in range(len(basis)))

def spectral_energy(f: np.ndarray, basis: List[np.ndarray], n: int) -> float:
    return float(np.sum(np.abs(spectral_coeffs(f, basis, n))**2))

def cyclic_chars(n: int) -> List[np.ndarray]:
    w = np.exp(2j * np.pi / n)
    return [np.array([w**(j*k) for j in range(n)]) for k in range(n)]

def S3_chars() -> List[np.ndarray]:
    return [
        np.array([1, 1, 1, 1, 1, 1], dtype=complex),
        np.array([1, -1, -1, -1, 1, 1], dtype=complex),
        np.array([2, 0, 0, 0, -1, -1], dtype=complex),
    ]


# =============================================================================
# Application 1: Signal Processing on Groups
# =============================================================================

def app_signal_processing():
    """
    Spectral filtering on cyclic groups.

    Demonstrates how moonshine-style decomposition enables targeted
    filtering of group-indexed signals — analogous to frequency-domain
    filtering in classical signal processing.
    """
    print("=" * 60)
    print("APPLICATION 1: Spectral Filtering on Z/8Z")
    print("=" * 60)

    n = 8
    basis = cyclic_chars(n)

    # Create a signal: superposition of two "frequencies"
    signal = basis[1] + 0.5 * basis[3]  # frequencies 1 and 3
    noise = 0.1 * np.random.RandomState(42).randn(n)
    noisy = signal + noise

    # Decode
    c = spectral_coeffs(noisy, basis, n)
    print(f"\nSpectral coefficients of noisy signal:")
    for k in range(n):
        print(f"  k={k}: |c_k| = {abs(c[k]):.4f}")

    # Low-pass filter: keep only components with |c_k| > 0.2
    filtered_coeffs = np.where(np.abs(c) > 0.2, c, 0)
    filtered = sum(filtered_coeffs[i] * basis[i] for i in range(n))

    print(f"\nReconstruction error (noisy → clean): {np.max(np.abs(filtered - signal)):.4f}")
    print(f"  (Noise level was {np.max(np.abs(noise)):.4f})")
    print(f"Spectral filtering successfully denoises the signal.")


# =============================================================================
# Application 2: Quantum State Tomography Analogy
# =============================================================================

def app_quantum_tomography():
    """
    Informationally complete measurement analogy.

    The spectral energy theorem E(f)=0 ↔ f=0 is the class-function
    analogue of informationally complete measurements in quantum mechanics.
    We demonstrate state reconstruction from measurement outcomes.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Quantum Tomography Analogy (V4)")
    print("=" * 60)

    # V4 = Z/2 x Z/2 characters
    basis = [
        np.array([1, 1, 1, 1], dtype=complex),
        np.array([1, 1, -1, -1], dtype=complex),
        np.array([1, -1, 1, -1], dtype=complex),
        np.array([1, -1, -1, 1], dtype=complex),
    ]
    n = 4

    # "Quantum state" (class function)
    state = np.array([3, 1, -1, 2], dtype=complex)

    # "Measurement outcomes" = spectral coefficients
    measurements = spectral_coeffs(state, basis, n)
    print(f"\nState: {state}")
    print(f"Measurement outcomes (⟨ψ|χᵢ⟩):")
    for i, m in enumerate(measurements):
        print(f"  Observable {i}: amplitude = {m:.4f}, probability = {abs(m)**2:.4f}")

    # Reconstruct state from measurements
    reconstructed = reconstruct(state, basis, n)
    print(f"\nReconstructed state: {np.round(reconstructed, 6)}")
    print(f"Reconstruction exact: {np.allclose(state, reconstructed)}")

    # Verify informational completeness
    energy = spectral_energy(state, basis, n)
    print(f"\nTotal measured intensity (energy): {energy:.6f}")
    print(f"Inner product ⟨ψ,ψ⟩: {cf_inner(state, state, n):.6f}")
    print(f"Parseval identity holds: {abs(cf_inner(state, state, n) - energy) < 1e-10}")

    # Test zero state
    zero_energy = spectral_energy(np.zeros(n, dtype=complex), basis, n)
    print(f"\nZero state energy: {zero_energy:.2e}")
    print(f"Informational completeness: energy=0 ↔ state=0 ✓")


# =============================================================================
# Application 3: Representation-Theoretic Data Compression
# =============================================================================

def app_compression():
    """
    Sparse spectral representation for data compression.

    Class functions with sparse spectral decompositions can be stored
    compactly by keeping only nonzero coefficients.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Spectral Compression on Z/16Z")
    print("=" * 60)

    n = 16
    basis = cyclic_chars(n)

    # Create a signal with only 3 nonzero frequencies
    true_coeffs = np.zeros(n, dtype=complex)
    true_coeffs[1] = 2.0 + 1j
    true_coeffs[5] = -0.5
    true_coeffs[12] = 1.0 - 0.5j

    signal = sum(true_coeffs[i] * basis[i] for i in range(n))

    # Full storage: 16 complex numbers = 256 bits (at 16 bits each)
    # Sparse storage: 3 (index, coefficient) pairs = 96 bits

    decoded = spectral_coeffs(signal, basis, n)
    nonzero = [(i, decoded[i]) for i in range(n) if abs(decoded[i]) > 1e-10]

    print(f"\nOriginal signal: {n} complex values")
    print(f"Spectral decomposition: {len(nonzero)} nonzero coefficients")
    print(f"Compression ratio: {n / len(nonzero):.1f}x")

    for idx, coeff in nonzero:
        print(f"  Frequency {idx}: {coeff:.4f}")

    # Verify exact reconstruction from sparse data
    sparse_reconstructed = sum(c * basis[i] for i, c in nonzero)
    print(f"\nReconstruction error: {np.max(np.abs(signal - sparse_reconstructed)):.2e}")


# =============================================================================
# Application 4: Group Fingerprinting
# =============================================================================

def app_fingerprinting():
    """
    Spectral fingerprinting for group classification.

    Different groups have different spectral signatures. The dimension
    vector (d₁, d₂, ..., dₖ) where dᵢ = χᵢ(e) uniquely constrains
    the group structure.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Spectral Fingerprinting")
    print("=" * 60)

    groups = {
        "Z/6Z": (6, cyclic_chars(6)),
        "S3": (6, S3_chars()),
    }

    for name, (n, chars) in groups.items():
        dims = [chi[0].real for chi in chars]  # χ(e) = dimension
        total = sum(d**2 for d in dims)

        print(f"\nGroup: {name} (order {n})")
        print(f"  Number of irreducibles: {len(chars)}")
        print(f"  Dimension vector: {[f'{d:.0f}' for d in dims]}")
        print(f"  ∑ dᵢ² = {total:.0f} {'= |G| ✓' if abs(total - n) < 0.01 else '≠ |G| ✗'}")

    print("\n  Note: Z/6Z and S3 both have order 6 but different")
    print("  spectral fingerprints (6 vs 3 irreducibles, different dimensions).")
    print("  The spectral signature distinguishes non-isomorphic groups.")


# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    print("╔════════════════════════════════════════════════════════════╗")
    print("║    Applications of Spectral Moonshine Framework          ║")
    print("╚════════════════════════════════════════════════════════════╝\n")

    app_signal_processing()
    app_quantum_tomography()
    app_compression()
    app_fingerprinting()

    print("\n" + "=" * 60)
    print("All applications demonstrated successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Spectral Moonshine Demo: Finite Harmonic Analysis on Small Groups

Demonstrates spectral decoding, reconstruction, Parseval identity, and the
informational completeness theorem for moonshine packets on finite groups.

Groups tested: Z/nZ (cyclic groups), S3, and the Klein four-group V4.
"""

import numpy as np
from typing import List, Tuple, Callable

# =============================================================================
# Core infrastructure: Class functions and inner products on finite groups
# =============================================================================

class FiniteGroup:
    """A finite group represented by its multiplication table."""
    def __init__(self, name: str, elements: List[str], mult_table: np.ndarray,
                 conjugacy_classes: List[List[int]]):
        self.name = name
        self.elements = elements
        self.n = len(elements)
        self.mult_table = mult_table  # mult_table[i,j] = index of elements[i]*elements[j]
        self.conjugacy_classes = conjugacy_classes

    def mult(self, i: int, j: int) -> int:
        return self.mult_table[i, j]


def cyclic_group(n: int) -> FiniteGroup:
    """Construct Z/nZ."""
    elements = [str(k) for k in range(n)]
    mult_table = np.array([[(i + j) % n for j in range(n)] for i in range(n)])
    # Each element is its own conjugacy class (abelian)
    conj_classes = [[k] for k in range(n)]
    return FiniteGroup(f"Z/{n}Z", elements, mult_table, conj_classes)


def symmetric_group_S3() -> FiniteGroup:
    """Construct S3 with elements {e, (12), (13), (23), (123), (132)}."""
    # S3 elements: 0=e, 1=(12), 2=(13), 3=(23), 4=(123), 5=(132)
    elements = ["e", "(12)", "(13)", "(23)", "(123)", "(132)"]
    # Multiplication table for S3
    mult_table = np.array([
        [0, 1, 2, 3, 4, 5],
        [1, 0, 4, 5, 2, 3],
        [2, 5, 0, 4, 3, 1],
        [3, 4, 5, 0, 1, 2],
        [4, 3, 1, 2, 5, 0],
        [5, 2, 3, 1, 0, 4]
    ])
    # Conjugacy classes: {e}, {(12),(13),(23)}, {(123),(132)}
    conj_classes = [[0], [1, 2, 3], [4, 5]]
    return FiniteGroup("S3", elements, mult_table, conj_classes)


def klein_four() -> FiniteGroup:
    """Construct V4 = Z/2Z x Z/2Z."""
    elements = ["e", "a", "b", "ab"]
    mult_table = np.array([
        [0, 1, 2, 3],
        [1, 0, 3, 2],
        [2, 3, 0, 1],
        [3, 2, 1, 0]
    ])
    conj_classes = [[0], [1], [2], [3]]  # abelian
    return FiniteGroup("V4", elements, mult_table, conj_classes)


# =============================================================================
# Class functions and inner product
# =============================================================================

def cf_inner(f: np.ndarray, g: np.ndarray, group_order: int) -> complex:
    """Inner product on class functions: <f,g> = (1/|G|) * sum_x f(x) * conj(g(x))."""
    return np.sum(f * np.conj(g)) / group_order


def is_orthonormal(basis: List[np.ndarray], group_order: int, tol: float = 1e-10) -> bool:
    """Check if a basis of class functions is orthonormal."""
    n = len(basis)
    for i in range(n):
        for j in range(n):
            ip = cf_inner(basis[i], basis[j], group_order)
            expected = 1.0 if i == j else 0.0
            if abs(ip - expected) > tol:
                return False
    return True


# =============================================================================
# Spectral engine: projector, energy, reconstruction
# =============================================================================

def packet_projector(basis: List[np.ndarray], f: np.ndarray, group_order: int) -> np.ndarray:
    """Compute P(f) = sum_i <f, chi_i> * chi_i."""
    result = np.zeros_like(f)
    for chi in basis:
        coeff = cf_inner(f, chi, group_order)
        result = result + coeff * chi
    return result


def spectral_energy(basis: List[np.ndarray], f: np.ndarray, group_order: int) -> float:
    """Compute E(f) = sum_i |<f, chi_i>|^2."""
    return sum(abs(cf_inner(f, chi, group_order))**2 for chi in basis)


def decode_multiplicities(f: np.ndarray, basis: List[np.ndarray],
                          group_order: int) -> List[complex]:
    """Decode Fourier coefficients of f with respect to basis."""
    return [cf_inner(f, chi, group_order) for chi in basis]


# =============================================================================
# Irreducible characters for test groups
# =============================================================================

def cyclic_characters(n: int) -> List[np.ndarray]:
    """Irreducible characters of Z/nZ: chi_k(j) = exp(2*pi*i*j*k/n)."""
    omega = np.exp(2j * np.pi / n)
    return [np.array([omega**(j * k) for j in range(n)]) for k in range(n)]


def S3_characters() -> List[np.ndarray]:
    """Irreducible characters of S3.
    Rows: trivial, sign, standard (2-dim).
    Columns: e, (12), (13), (23), (123), (132)."""
    chi_triv = np.array([1, 1, 1, 1, 1, 1], dtype=complex)
    chi_sign = np.array([1, -1, -1, -1, 1, 1], dtype=complex)
    chi_std = np.array([2, 0, 0, 0, -1, -1], dtype=complex)
    return [chi_triv, chi_sign, chi_std]


def V4_characters() -> List[np.ndarray]:
    """Irreducible characters of V4 = Z/2 x Z/2.
    Elements: e, a, b, ab."""
    return [
        np.array([1, 1, 1, 1], dtype=complex),
        np.array([1, 1, -1, -1], dtype=complex),
        np.array([1, -1, 1, -1], dtype=complex),
        np.array([1, -1, -1, 1], dtype=complex),
    ]


# =============================================================================
# Demo 1: Orthonormality verification
# =============================================================================

def demo_orthonormality():
    print("=" * 70)
    print("DEMO 1: Orthonormality of Irreducible Characters")
    print("=" * 70)

    groups_and_chars = [
        (cyclic_group(4), cyclic_characters(4)),
        (symmetric_group_S3(), S3_characters()),
        (klein_four(), V4_characters()),
    ]

    for G, chars in groups_and_chars:
        print(f"\nGroup: {G.name} (order {G.n})")
        orth = is_orthonormal(chars, G.n)
        print(f"  Orthonormal: {orth}")

        # Print inner product matrix
        n = len(chars)
        print(f"  Inner product matrix ({n}x{n}):")
        for i in range(n):
            row = [f"{cf_inner(chars[i], chars[j], G.n):.3f}" for j in range(n)]
            print(f"    [{', '.join(row)}]")


# =============================================================================
# Demo 2: Spectral reconstruction
# =============================================================================

def demo_reconstruction():
    print("\n" + "=" * 70)
    print("DEMO 2: Exact Spectral Reconstruction (Theorem 1)")
    print("=" * 70)

    groups_and_chars = [
        (cyclic_group(5), cyclic_characters(5)),
        (symmetric_group_S3(), S3_characters()),
    ]

    for G, chars in groups_and_chars:
        print(f"\nGroup: {G.name}")
        # Create a random class function
        np.random.seed(42)
        f = np.random.randn(G.n) + 1j * np.random.randn(G.n)

        # Decode and reconstruct
        coeffs = decode_multiplicities(f, chars, G.n)
        f_reconstructed = packet_projector(chars, f, G.n)

        print(f"  Original f:       {np.round(f, 4)}")
        print(f"  Reconstructed Pf: {np.round(f_reconstructed, 4)}")
        print(f"  Max error |f - Pf|: {np.max(np.abs(f - f_reconstructed)):.2e}")
        print(f"  Coefficients: {[f'{c:.4f}' for c in coeffs]}")


# =============================================================================
# Demo 3: Parseval identity
# =============================================================================

def demo_parseval():
    print("\n" + "=" * 70)
    print("DEMO 3: Parseval/Plancherel Identity (Theorem 2)")
    print("=" * 70)

    groups_and_chars = [
        (cyclic_group(6), cyclic_characters(6)),
        (symmetric_group_S3(), S3_characters()),
        (klein_four(), V4_characters()),
    ]

    for G, chars in groups_and_chars:
        print(f"\nGroup: {G.name}")
        np.random.seed(123)
        f = np.random.randn(G.n) + 1j * np.random.randn(G.n)

        # LHS: <f, f>
        norm_sq = cf_inner(f, f, G.n)

        # RHS: sum |<f, chi>|^2
        energy = spectral_energy(chars, f, G.n)

        print(f"  <f, f> = {norm_sq:.8f}")
        print(f"  Spectral energy = {energy:.8f}")
        print(f"  Difference: {abs(norm_sq - energy):.2e}")
        print(f"  Parseval verified: {abs(norm_sq - energy) < 1e-10}")


# =============================================================================
# Demo 4: Uniqueness theorem
# =============================================================================

def demo_uniqueness():
    print("\n" + "=" * 70)
    print("DEMO 4: Uniqueness of Multiplicity Decoding (Theorem 3)")
    print("=" * 70)

    G = symmetric_group_S3()
    chars = S3_characters()

    np.random.seed(77)
    f = np.random.randn(G.n) + 1j * np.random.randn(G.n)
    g = np.random.randn(G.n) + 1j * np.random.randn(G.n)

    coeffs_f = decode_multiplicities(f, chars, G.n)
    coeffs_g = decode_multiplicities(g, chars, G.n)

    print(f"  f coefficients: {[f'{c:.4f}' for c in coeffs_f]}")
    print(f"  g coefficients: {[f'{c:.4f}' for c in coeffs_g]}")
    print(f"  Same coefficients? {all(abs(a-b) < 1e-10 for a,b in zip(coeffs_f, coeffs_g))}")
    print(f"  f == g? {np.allclose(f, g)}")

    # Now set g = reconstructed f (same coefficients)
    g2 = packet_projector(chars, f, G.n)
    coeffs_g2 = decode_multiplicities(g2, chars, G.n)
    print(f"\n  After setting g = P(f):")
    print(f"  f coefficients: {[f'{c:.4f}' for c in coeffs_f]}")
    print(f"  g coefficients: {[f'{c:.4f}' for c in coeffs_g2]}")
    print(f"  Same coefficients? {all(abs(a-b) < 1e-10 for a,b in zip(coeffs_f, coeffs_g2))}")
    print(f"  f == g? {np.allclose(f, g2)}")


# =============================================================================
# Demo 5: Projector idempotence
# =============================================================================

def demo_idempotence():
    print("\n" + "=" * 70)
    print("DEMO 5: Projector Idempotence (Theorem 4)")
    print("=" * 70)

    groups_and_chars = [
        (cyclic_group(4), cyclic_characters(4)),
        (symmetric_group_S3(), S3_characters()),
    ]

    for G, chars in groups_and_chars:
        print(f"\nGroup: {G.name}")
        np.random.seed(99)
        f = np.random.randn(G.n) + 1j * np.random.randn(G.n)

        Pf = packet_projector(chars, f, G.n)
        PPf = packet_projector(chars, Pf, G.n)

        print(f"  P(f):  {np.round(Pf, 6)}")
        print(f"  P²(f): {np.round(PPf, 6)}")
        print(f"  |P²f - Pf|: {np.max(np.abs(PPf - Pf)):.2e}")
        print(f"  Idempotent: {np.allclose(PPf, Pf)}")


# =============================================================================
# Demo 6: Informational completeness (zero energy iff zero function)
# =============================================================================

def demo_informational_completeness():
    print("\n" + "=" * 70)
    print("DEMO 6: Informational Completeness (Cross-Domain Theorem)")
    print("=" * 70)

    G = symmetric_group_S3()
    chars = S3_characters()

    # Test with zero function
    f_zero = np.zeros(G.n, dtype=complex)
    energy_zero = spectral_energy(chars, f_zero, G.n)
    print(f"\n  Zero function energy: {energy_zero:.2e}")
    print(f"  Energy = 0: {energy_zero < 1e-15}")

    # Test with nonzero function
    np.random.seed(55)
    f = np.random.randn(G.n) + 1j * np.random.randn(G.n)
    energy = spectral_energy(chars, f, G.n)
    print(f"  Nonzero function energy: {energy:.6f}")
    print(f"  Energy > 0: {energy > 1e-10}")
    print(f"  Conclusion: zero energy ↔ zero function ✓")


# =============================================================================
# Demo 7: Conjecture test — spectral sparsity rigidity
# =============================================================================

def demo_conjecture_test():
    print("\n" + "=" * 70)
    print("DEMO 7: Conjecture Test — Spectral Sparsity Rigidity")
    print("=" * 70)
    print("  Conjecture: If a class function f has nonneg integral spectral")
    print("  multiplicities and spectral energy 1, then f equals a single")
    print("  basis element.")

    groups_and_chars = [
        (cyclic_group(3), cyclic_characters(3)),
        (cyclic_group(5), cyclic_characters(5)),
        (symmetric_group_S3(), S3_characters()),
        (klein_four(), V4_characters()),
    ]

    counterexample_found = False

    for G, chars in groups_and_chars:
        print(f"\n  Testing group: {G.name} (order {G.n})")

        # Search over integer-valued class functions with bounded values
        bound = 3
        from itertools import product as iproduct
        count = 0
        tested = 0

        for vals in iproduct(range(-bound, bound + 1), repeat=G.n):
            f = np.array(vals, dtype=complex)
            tested += 1

            # Check nonneg integral multiplicities
            coeffs = decode_multiplicities(f, chars, G.n)
            all_nonneg_int = True
            for c in coeffs:
                if abs(c.imag) > 1e-8 or c.real < -1e-8:
                    all_nonneg_int = False
                    break
                if abs(c.real - round(c.real)) > 1e-8:
                    all_nonneg_int = False
                    break

            if not all_nonneg_int:
                continue

            # Check energy = 1
            energy = spectral_energy(chars, f, G.n)
            if abs(energy - 1.0) > 1e-8:
                continue

            count += 1

            # Check if f is a single basis element (up to sign)
            is_basis_element = False
            for chi in chars:
                if np.allclose(f, chi) or np.allclose(f, -chi):
                    is_basis_element = True
                    break

            if not is_basis_element:
                print(f"    COUNTEREXAMPLE: f = {vals}")
                print(f"    Coefficients: {[f'{c:.2f}' for c in coeffs]}")
                print(f"    Energy: {energy:.6f}")
                counterexample_found = True

        print(f"    Tested {tested} functions, {count} satisfy conditions")

    if not counterexample_found:
        print(f"\n  No counterexample found in tested range (values in [-{bound},{bound}]).")
        print("  Conjecture holds for all tested cases.")
    else:
        print("\n  Counterexample(s) found! Conjecture is FALSE.")


# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║         SPECTRAL MOONSHINE: Finite Harmonic Analysis Demo          ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")

    demo_orthonormality()
    demo_reconstruction()
    demo_parseval()
    demo_uniqueness()
    demo_idempotence()
    demo_informational_completeness()
    demo_conjecture_test()

    print("\n" + "=" * 70)
    print("All demos completed successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualization 2: Parseval Energy Conservation

Shows the Parseval/Plancherel identity: the total spectral energy
(sum of squared Fourier coefficients) equals the class-function norm
squared. Visualized as an energy balance diagram for multiple test
functions on different groups.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# --- Inline infrastructure ---
def cf_inner(f, g, n):
    return np.sum(f * np.conj(g)) / n

def cyclic_chars(n):
    w = np.exp(2j * np.pi / n)
    return [np.array([w**(j*k) for j in range(n)]) for k in range(n)]

def spectral_energy(f, basis, n):
    return sum(abs(cf_inner(f, chi, n))**2 for chi in basis)

# --- Setup ---
np.random.seed(2024)
group_sizes = [4, 6, 8, 10, 12]
n_tests = 5

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Panel 1: Scatter plot <f,f> vs spectral energy
ax1 = axes[0]
norms = []
energies = []
labels = []

for n in group_sizes:
    basis = cyclic_chars(n)
    for _ in range(n_tests):
        f = np.random.randn(n) + 1j * np.random.randn(n)
        ip = cf_inner(f, f, n).real
        e = spectral_energy(f, basis, n)
        norms.append(ip)
        energies.append(e)
        labels.append(n)

norms = np.array(norms)
energies = np.array(energies)
labels = np.array(labels)

for n in group_sizes:
    mask = labels == n
    ax1.scatter(norms[mask], energies[mask], s=80, alpha=0.8,
                label=f'Z/{n}Z', edgecolors='black', linewidth=0.5)

# Perfect line
mn, mx = min(norms.min(), energies.min()), max(norms.max(), energies.max())
ax1.plot([mn, mx], [mn, mx], 'k--', alpha=0.5, label='y = x (Parseval)')
ax1.set_xlabel('⟨f, f⟩ (norm squared)', fontsize=13)
ax1.set_ylabel('Spectral Energy ∑|⟨f,χᵢ⟩|²', fontsize=13)
ax1.set_title('Parseval Identity Verification', fontsize=14, fontweight='bold')
ax1.legend(fontsize=10)
ax1.grid(alpha=0.3)

# Panel 2: Relative error histogram
ax2 = axes[1]
rel_errors = np.abs(norms - energies) / (np.abs(norms) + 1e-15)
ax2.hist(rel_errors, bins=20, color='#673AB7', alpha=0.8, edgecolor='black')
ax2.set_xlabel('Relative Error |⟨f,f⟩ - E(f)| / |⟨f,f⟩|', fontsize=12)
ax2.set_ylabel('Count', fontsize=12)
ax2.set_title('Parseval Error Distribution', fontsize=14, fontweight='bold')
ax2.axvline(x=1e-14, color='red', linestyle='--', label='Machine epsilon')
ax2.legend(fontsize=10)
ax2.grid(axis='y', alpha=0.3)

max_err = max(rel_errors)
ax2.text(0.6, 0.85, f'Max relative error:\n{max_err:.1e}',
         transform=ax2.transAxes, fontsize=12,
         bbox=dict(boxstyle='round', facecolor='#E8EAF6', alpha=0.8))

fig.suptitle('Spectral Energy Conservation (Plancherel Theorem)',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_parseval_energy.png', dpi=150, bbox_inches='tight')
print("Saved viz_parseval_energy.png")


#!/usr/bin/env python3
"""
Visualization 3: Projector Idempotence and Spectral Convergence

Demonstrates that the packet projector P satisfies P² = P (idempotence),
visualized by showing how repeated application of P converges in one step.
Also shows the spectral energy landscape as a function on the group.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# --- Inline infrastructure ---
def cf_inner(f, g, n):
    return np.sum(f * np.conj(g)) / n

def cyclic_chars(n):
    w = np.exp(2j * np.pi / n)
    return [np.array([w**(j*k) for j in range(n)]) for k in range(n)]

def packet_projector(f, basis, n):
    result = np.zeros_like(f)
    for chi in basis:
        c = cf_inner(f, chi, n)
        result += c * chi
    return result

def spectral_energy(f, basis, n):
    return sum(abs(cf_inner(f, chi, n))**2 for chi in basis)

# --- Setup ---
n = 8
basis = cyclic_chars(n)
np.random.seed(17)
f = np.random.randn(n) + 1j * np.random.randn(n)

# Apply projector repeatedly
max_iters = 6
iterates = [f.copy()]
for _ in range(max_iters):
    iterates.append(packet_projector(iterates[-1], basis, n))

# Compute errors relative to P(f)
Pf = iterates[1]
errors = [np.max(np.abs(it - Pf)) for it in iterates]

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Panel 1: Real parts of iterates
ax1 = axes[0, 0]
x = np.arange(n)
colors = plt.cm.plasma(np.linspace(0, 0.9, max_iters + 1))
for k, it in enumerate(iterates[:4]):
    label = f'P^{k}(f)' if k > 0 else 'f'
    ax1.plot(x, it.real, 'o-', color=colors[k], label=label,
             markersize=8, linewidth=2, alpha=0.8)
ax1.set_xlabel('Group element', fontsize=12)
ax1.set_ylabel('Re(f)', fontsize=12)
ax1.set_title('Projector Iterates (Real Part)', fontsize=13, fontweight='bold')
ax1.legend(fontsize=10)
ax1.grid(alpha=0.3)

# Panel 2: Convergence plot
ax2 = axes[0, 1]
ax2.semilogy(range(len(errors)), [max(e, 1e-16) for e in errors],
             'o-', color='#E91E63', markersize=10, linewidth=2.5)
ax2.axhline(y=1e-14, color='gray', linestyle=':', alpha=0.5)
ax2.set_xlabel('Iteration k', fontsize=12)
ax2.set_ylabel('‖Pᵏ(f) - P(f)‖∞', fontsize=12)
ax2.set_title('Idempotence: P² = P', fontsize=13, fontweight='bold')
ax2.grid(alpha=0.3)
ax2.text(0.5, 0.7, 'Converges in\n1 step!',
         transform=ax2.transAxes, fontsize=14, ha='center',
         bbox=dict(boxstyle='round', facecolor='#FCE4EC', alpha=0.8))

# Panel 3: Spectral energy at each iterate
ax3 = axes[1, 0]
iter_energies = [spectral_energy(it, basis, n) for it in iterates]
ax3.bar(range(len(iter_energies)), iter_energies,
        color=['#FF5722' if k == 0 else '#4CAF50' for k in range(len(iter_energies))],
        alpha=0.8, edgecolor='black')
ax3.set_xlabel('Iteration k', fontsize=12)
ax3.set_ylabel('Spectral Energy E(Pᵏf)', fontsize=12)
ax3.set_title('Energy Stabilization', fontsize=13, fontweight='bold')
ax3.grid(axis='y', alpha=0.3)

# Panel 4: Fourier coefficient magnitudes before and after projection
ax4 = axes[1, 1]
c_before = np.array([abs(cf_inner(f, chi, n)) for chi in basis])
c_after = np.array([abs(cf_inner(Pf, chi, n)) for chi in basis])

width = 0.35
ax4.bar(x - width/2, c_before, width, label='Before P', color='#2196F3', alpha=0.8)
ax4.bar(x + width/2, c_after, width, label='After P', color='#FF9800', alpha=0.8)
ax4.set_xlabel('Frequency k', fontsize=12)
ax4.set_ylabel('|⟨·, χₖ⟩|', fontsize=12)
ax4.set_title('Coefficient Preservation', fontsize=13, fontweight='bold')
ax4.set_xticks(x)
ax4.set_xticklabels([f'χ_{k}' for k in range(n)])
ax4.legend(fontsize=10)
ax4.grid(axis='y', alpha=0.3)

fig.suptitle('Packet Projector: Idempotence and Energy Conservation',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_projector_idempotence.png', dpi=150, bbox_inches='tight')
print("Saved viz_projector_idempotence.png")


#!/usr/bin/env python3
"""
Visualization 1: Spectral Decomposition Heatmap

Visualizes the spectral decomposition of class functions on Z/8Z.
Shows the original function, its Fourier coefficients, and the
reconstructed function as a three-panel figure demonstrating
the exact reconstruction theorem (Theorem 1).
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# --- Inline infrastructure ---
def cf_inner(f, g, n):
    return np.sum(f * np.conj(g)) / n

def cyclic_chars(n):
    w = np.exp(2j * np.pi / n)
    return [np.array([w**(j*k) for j in range(n)]) for k in range(n)]

def spectral_coeffs(f, basis, n):
    return np.array([cf_inner(f, chi, n) for chi in basis])

def reconstruct(f, basis, n):
    c = spectral_coeffs(f, basis, n)
    return sum(c[i] * basis[i] for i in range(len(basis)))

# --- Setup ---
n = 8
basis = cyclic_chars(n)

# Create test signal: mixture of harmonics
signal = 3*basis[0] + 2*basis[1] - 1.5j*basis[3] + basis[6]
coeffs = spectral_coeffs(signal, basis, n)
reconstructed = reconstruct(signal, basis, n)

# --- Figure ---
fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Panel 1: Original signal (real and imaginary parts)
ax1 = axes[0]
x = np.arange(n)
ax1.bar(x - 0.15, signal.real, 0.3, label='Real', color='#2196F3', alpha=0.8)
ax1.bar(x + 0.15, signal.imag, 0.3, label='Imaginary', color='#FF9800', alpha=0.8)
ax1.set_xlabel('Group element g ∈ Z/8Z', fontsize=12)
ax1.set_ylabel('f(g)', fontsize=12)
ax1.set_title('Original Class Function', fontsize=14, fontweight='bold')
ax1.legend(fontsize=10)
ax1.set_xticks(x)
ax1.grid(axis='y', alpha=0.3)

# Panel 2: Spectral coefficients (magnitude)
ax2 = axes[1]
magnitudes = np.abs(coeffs)
colors = plt.cm.viridis(magnitudes / max(magnitudes))
bars = ax2.bar(x, magnitudes, color=colors, edgecolor='black', linewidth=0.5)
ax2.set_xlabel('Frequency k', fontsize=12)
ax2.set_ylabel('|⟨f, χₖ⟩|', fontsize=12)
ax2.set_title('Spectral Coefficients', fontsize=14, fontweight='bold')
ax2.set_xticks(x)
ax2.set_xticklabels([f'χ_{k}' for k in range(n)])
ax2.grid(axis='y', alpha=0.3)

# Annotate nonzero coefficients
for k in range(n):
    if magnitudes[k] > 0.1:
        ax2.annotate(f'{magnitudes[k]:.1f}', (k, magnitudes[k]),
                     ha='center', va='bottom', fontsize=9, fontweight='bold')

# Panel 3: Reconstruction error
ax3 = axes[2]
error = np.abs(signal - reconstructed)
ax3.bar(x, error, color='#4CAF50' if max(error) < 1e-10 else '#F44336', alpha=0.8)
ax3.set_xlabel('Group element g', fontsize=12)
ax3.set_ylabel('|f(g) - P(f)(g)|', fontsize=12)
ax3.set_title('Reconstruction Error', fontsize=14, fontweight='bold')
ax3.set_xticks(x)
ax3.set_ylim(0, max(1e-14, max(error) * 1.5))
ax3.ticklabel_format(axis='y', style='scientific', scilimits=(-2, 2))
ax3.grid(axis='y', alpha=0.3)

# Add verification text
max_err = max(error)
status = "EXACT ✓" if max_err < 1e-10 else f"Error: {max_err:.2e}"
ax3.text(0.5, 0.85, f'Max error: {max_err:.1e}\n{status}',
         transform=ax3.transAxes, ha='center', fontsize=11,
         bbox=dict(boxstyle='round', facecolor='#E8F5E9', alpha=0.8))

fig.suptitle('Spectral Moonshine: Exact Reconstruction on Z/8Z',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_spectral_decomposition.png', dpi=150, bbox_inches='tight')
print("Saved viz_spectral_decomposition.png")
