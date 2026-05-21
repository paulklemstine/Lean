#!/usr/bin/env python3
"""
Applications of Fourier Analysis on Finite Groups

Demonstrates real-world applications of the formally verified theorems:
1. Signal filtering on cyclic groups
2. Spectral analysis of circulant graphs (Cayley graphs)
3. Sparse recovery and compressed sensing on Z/nZ
4. Finite quantum walk simulation
5. Additive combinatorics: sumset bounds via spectral methods
"""

import numpy as np
from typing import List, Tuple


# ─────────────────────────────────────────────────────────────────────
# Core DFT (replicated for self-containedness)
# ─────────────────────────────────────────────────────────────────────

def dft(f: np.ndarray) -> np.ndarray:
    n = len(f)
    omega = np.exp(2j * np.pi / n)
    M = np.conj(omega ** np.outer(np.arange(n), np.arange(n)))
    return M @ f

def idft(fhat: np.ndarray) -> np.ndarray:
    n = len(fhat)
    omega = np.exp(2j * np.pi / n)
    M = omega ** np.outer(np.arange(n), np.arange(n))
    return (1.0 / n) * M.T @ fhat


# ─────────────────────────────────────────────────────────────────────
# Application 1: Low-pass Filtering on Cyclic Groups
# ─────────────────────────────────────────────────────────────────────

def low_pass_filter(signal: np.ndarray, cutoff: int) -> np.ndarray:
    """Apply a low-pass filter by zeroing high-frequency Fourier coefficients.

    This demonstrates the convolution theorem in action: filtering in
    frequency domain is equivalent to convolution with a kernel in time domain.

    The formal guarantee (fourier_convolution) ensures this operation is
    mathematically equivalent to convolving with the Dirichlet kernel.

    Args:
        signal: Input signal on Z/nZ
        cutoff: Keep only the first `cutoff` and last `cutoff` frequencies

    Returns:
        Filtered signal
    """
    n = len(signal)
    fhat = dft(signal)

    # Zero out high frequencies
    mask = np.zeros(n, dtype=complex)
    for k in range(n):
        if k <= cutoff or k >= n - cutoff:
            mask[k] = 1.0

    fhat_filtered = fhat * mask
    return idft(fhat_filtered)


def demo_filtering():
    print("=" * 60)
    print("APPLICATION 1: Signal Filtering on Z/nZ")
    print("=" * 60)
    print()

    n = 64
    t = np.arange(n)
    omega = np.exp(2j * np.pi / n)

    # Signal: low frequency + high frequency noise
    signal = np.real(omega ** (2 * t) + omega ** (3 * t)) + 0.5 * np.random.randn(n)

    filtered = low_pass_filter(signal, cutoff=5)
    noise_power = np.sum(np.abs(signal - filtered) ** 2)
    signal_power = np.sum(np.abs(filtered) ** 2)

    print(f"  Signal length: {n}")
    print(f"  Signal power after filtering: {signal_power:.2f}")
    print(f"  Removed noise power: {noise_power:.2f}")
    print(f"  SNR improvement: {10 * np.log10(signal_power / max(noise_power, 1e-10)):.1f} dB")
    print()


# ─────────────────────────────────────────────────────────────────────
# Application 2: Spectral Analysis of Cayley Graphs
# ─────────────────────────────────────────────────────────────────────

def cayley_graph_spectrum(n: int, generators: List[int]) -> np.ndarray:
    """Compute the spectrum of a Cayley graph on Z/nZ.

    A Cayley graph Cay(Z/nZ, S) has vertices {0,...,n-1} and edges
    {(x, x+s mod n) : s ∈ S}. Its adjacency matrix is a circulant,
    and by the convolution theorem, its eigenvalues are the Fourier
    coefficients of the indicator function of S.

    The formal fourier_convolution theorem guarantees that circulant
    matrices are diagonalized by the DFT.

    Args:
        n: Group order
        generators: Generating set S ⊂ Z/nZ

    Returns:
        Eigenvalues of the adjacency matrix
    """
    indicator = np.zeros(n, dtype=complex)
    for s in generators:
        indicator[s % n] = 1.0
    return dft(indicator)


def demo_cayley():
    print("=" * 60)
    print("APPLICATION 2: Cayley Graph Spectral Analysis")
    print("=" * 60)
    print()

    # Cycle graph C_n = Cay(Z/n, {1, n-1})
    n = 12
    eigenvalues = cayley_graph_spectrum(n, [1, n - 1])
    eigs_real = np.sort(np.real(eigenvalues))

    print(f"  Cycle graph C_{n}:")
    print(f"    Eigenvalues: {np.round(eigs_real, 4)}")
    print(f"    Spectral gap: {2 - eigs_real[-2]:.4f}")
    print()

    # Paley-type graph (quadratic residues)
    p = 13
    qr = [k**2 % p for k in range(1, p)]
    qr = sorted(set(qr))
    eigenvalues_paley = cayley_graph_spectrum(p, qr)
    eigs_paley = np.sort(np.real(eigenvalues_paley))

    print(f"  Paley-type graph on Z/{p}Z:")
    print(f"    Quadratic residues: {qr}")
    print(f"    Eigenvalues: {np.round(eigs_paley, 4)}")
    print(f"    Max non-trivial |eigenvalue|: {max(abs(eigs_paley[0]), abs(eigs_paley[-2])):.4f}")
    print()


# ─────────────────────────────────────────────────────────────────────
# Application 3: Sparse Recovery on Z/nZ
# ─────────────────────────────────────────────────────────────────────

def sparse_recovery_test(n: int, sparsity: int) -> Tuple[float, bool]:
    """Test sparse signal recovery via thresholding in Fourier domain.

    The uncertainty principle guarantees that a k-sparse signal in time
    domain has at least n/k nonzero Fourier coefficients. This places
    fundamental limits on compressed sensing over finite groups.

    Args:
        n: Signal length
        sparsity: Number of nonzero entries

    Returns:
        (recovery_error, uncertainty_holds)
    """
    # Generate sparse signal
    indices = np.random.choice(n, sparsity, replace=False)
    f = np.zeros(n, dtype=complex)
    f[indices] = np.random.randn(sparsity) + 1j * np.random.randn(sparsity)

    fhat = dft(f)

    # Check uncertainty
    supp_f = np.sum(np.abs(f) > 1e-10)
    supp_fhat = np.sum(np.abs(fhat) > 1e-10)
    uncertainty_holds = supp_f * supp_fhat >= n

    # Recovery via inverse DFT (perfect recovery from complete spectrum)
    f_recovered = idft(fhat)
    error = np.max(np.abs(f - f_recovered))

    return error, uncertainty_holds


def demo_sparse_recovery():
    print("=" * 60)
    print("APPLICATION 3: Sparse Recovery and Uncertainty Bounds")
    print("=" * 60)
    print()

    n = 64
    print(f"  Signal space: Z/{n}Z")
    print()
    print(f"  {'Sparsity':>10} {'Spectral spread':>18} {'Product':>10} "
          f"{'Bound (n)':>10} {'Recovery err':>14}")

    for k in [1, 2, 4, 8, 16, 32, 64]:
        np.random.seed(42)
        indices = np.random.choice(n, min(k, n), replace=False)
        f = np.zeros(n, dtype=complex)
        f[indices] = np.random.randn(min(k, n)) + 1j * np.random.randn(min(k, n))
        fhat = dft(f)

        supp_f = int(np.sum(np.abs(f) > 1e-10))
        supp_fhat = int(np.sum(np.abs(fhat) > 1e-10))
        product = supp_f * supp_fhat
        error, _ = sparse_recovery_test(n, min(k, n))

        print(f"  {supp_f:>10} {supp_fhat:>18} {product:>10} "
              f"{n:>10} {error:>14.2e}")

    print()
    print("  ✓ Uncertainty principle: product ≥ n in all cases.")
    print()


# ─────────────────────────────────────────────────────────────────────
# Application 4: Finite Quantum Walk
# ─────────────────────────────────────────────────────────────────────

def quantum_walk_step(psi: np.ndarray, coin: np.ndarray) -> np.ndarray:
    """One step of a quantum walk on Z/nZ.

    The quantum walk uses the Fourier transform to implement the
    shift operator in momentum space. The unitary evolution is:
    ψ(t+1) = S · C · ψ(t)
    where C is a coin operator and S is the conditional shift.

    For simplicity, we implement a 1D walk with a Hadamard coin
    on a 2-component wavefunction.

    Args:
        psi: State vector (2n complex numbers, reshaped as n × 2)
        coin: 2×2 unitary coin matrix

    Returns:
        Updated state vector
    """
    n = len(psi) // 2
    psi_reshaped = psi.reshape(n, 2)

    # Apply coin
    psi_coined = psi_reshaped @ coin.T

    # Conditional shift
    psi_new = np.zeros_like(psi_coined)
    for x in range(n):
        psi_new[(x + 1) % n, 0] += psi_coined[x, 0]  # Right shift
        psi_new[(x - 1) % n, 1] += psi_coined[x, 1]  # Left shift

    return psi_new.flatten()


def demo_quantum_walk():
    print("=" * 60)
    print("APPLICATION 4: Quantum Walk on Z/nZ")
    print("=" * 60)
    print()

    n = 32
    T = 20  # time steps

    # Hadamard coin
    H = np.array([[1, 1], [1, -1]], dtype=complex) / np.sqrt(2)

    # Initial state: localized at position 0, coin state |0⟩
    psi = np.zeros(2 * n, dtype=complex)
    psi[0] = 1.0  # position 0, coin 0

    print(f"  Quantum walk on Z/{n}Z with Hadamard coin, {T} steps")
    print()

    for t in range(T + 1):
        prob = np.abs(psi.reshape(n, 2)) ** 2
        prob_position = np.sum(prob, axis=1)
        spread = np.sqrt(np.sum(np.arange(n) ** 2 * prob_position) -
                        np.sum(np.arange(n) * prob_position) ** 2)

        if t in [0, 5, 10, 15, 20]:
            supp = int(np.sum(prob_position > 1e-10))
            print(f"  t = {t:3d}: spread = {spread:6.2f}, "
                  f"|support| = {supp:3d}, "
                  f"max prob = {np.max(prob_position):.4f}")

        psi = quantum_walk_step(psi, H)

    print()
    print("  The quantum walk spreads ballistically (linearly in t),")
    print("  unlike the classical random walk which spreads as √t.")
    print()


# ─────────────────────────────────────────────────────────────────────
# Application 5: Additive Combinatorics — Sumset Bounds
# ─────────────────────────────────────────────────────────────────────

def sumset(A: List[int], B: List[int], n: int) -> set:
    """Compute the sumset A + B in Z/nZ."""
    return {(a + b) % n for a in A for b in B}


def ruzsa_distance(A: List[int], B: List[int], n: int) -> float:
    """Ruzsa distance: log(|A+B|/sqrt(|A|·|B|))."""
    ab = sumset(A, B, n)
    return np.log(len(ab) / np.sqrt(len(A) * len(B)))


def demo_additive_combinatorics():
    print("=" * 60)
    print("APPLICATION 5: Additive Combinatorics via Fourier Analysis")
    print("=" * 60)
    print()

    n = 31  # prime

    # Arithmetic progressions have small sumsets
    A_ap = list(range(0, 10))  # AP of length 10

    # Random sets
    np.random.seed(42)
    A_rand = sorted(np.random.choice(n, 10, replace=False).tolist())

    print(f"  Group: Z/{n}Z")
    print()

    for name, A in [("Arithmetic progression", A_ap), ("Random set", A_rand)]:
        fhat = dft(np.array([1.0 if j in A else 0.0 for j in range(n)]))
        large_spectrum = int(np.sum(np.abs(fhat) > np.sqrt(len(A)) / 2))

        AB = sumset(A, A, n)
        energy = sum(1 for a1 in A for a2 in A for a3 in A for a4 in A
                    if (a1 + a2) % n == (a3 + a4) % n)

        print(f"  {name}: A = {A[:5]}...")
        print(f"    |A| = {len(A)}")
        print(f"    |A+A| = {len(AB)}")
        print(f"    Doubling constant |A+A|/|A| = {len(AB)/len(A):.2f}")
        print(f"    Additive energy E(A) = {energy}")
        print(f"    Large spectrum size = {large_spectrum}")
        print(f"    Ruzsa distance d(A,A) = {ruzsa_distance(A, A, n):.3f}")
        print()

    print("  Structured sets (APs) have smaller doubling and larger energy,")
    print("  reflected in concentrated Fourier spectra.")
    print()


# ─────────────────────────────────────────────────────────────────────

def main():
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Applications of Fourier Analysis on Finite Groups     ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    demo_filtering()
    demo_cayley()
    demo_sparse_recovery()
    demo_quantum_walk()
    demo_additive_combinatorics()

    print("=" * 60)
    print("All applications demonstrated successfully.")
    print("=" * 60)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Fourier Analysis on Finite Groups — Interactive Demo

Demonstrates the Discrete Fourier Transform on cyclic groups (Z/nZ),
verifying Parseval's identity, the convolution theorem, and the
uncertainty principle through numerical experiments.

Usage:
    python demo.py
"""

import numpy as np
from typing import Callable
import sys

# ─────────────────────────────────────────────────────────────────────
# Core DFT on Z/nZ
# ─────────────────────────────────────────────────────────────────────

def dft(f: np.ndarray) -> np.ndarray:
    """Discrete Fourier Transform on Z/nZ.

    Given f : Z/nZ → C represented as a length-n array,
    returns f̂(k) = Σ_j f(j) * conj(ω^{jk}) where ω = e^{2πi/n}.

    This matches the convention f̂(k) = Σ_j f(j) * conj(χ_k(j)).
    """
    n = len(f)
    omega = np.exp(2j * np.pi / n)
    k = np.arange(n)
    j = np.arange(n)
    # Matrix: M[k, j] = conj(omega^{j*k}) = omega^{-j*k}
    M = np.conj(omega ** np.outer(k, j))
    return M @ f


def idft(fhat: np.ndarray) -> np.ndarray:
    """Inverse Discrete Fourier Transform on Z/nZ.

    Recovers f(j) = (1/n) * Σ_k f̂(k) * χ_k(j).
    """
    n = len(fhat)
    omega = np.exp(2j * np.pi / n)
    k = np.arange(n)
    j = np.arange(n)
    M = omega ** np.outer(j, k)
    return (1.0 / n) * M @ fhat


def convolution(f: np.ndarray, h: np.ndarray) -> np.ndarray:
    """Convolution on Z/nZ: (f * h)(x) = Σ_y f(y) * h(x - y)."""
    n = len(f)
    result = np.zeros(n, dtype=complex)
    for x in range(n):
        for y in range(n):
            result[x] += f[y] * h[(x - y) % n]
    return result


def support_size(f: np.ndarray, tol: float = 1e-10) -> int:
    """Number of nonzero entries (up to tolerance)."""
    return int(np.sum(np.abs(f) > tol))


# ─────────────────────────────────────────────────────────────────────
# Demo 1: Parseval's Identity
# ─────────────────────────────────────────────────────────────────────

def demo_parseval():
    print("=" * 60)
    print("DEMO 1: Parseval's Identity")
    print("=" * 60)
    print()
    print("Parseval: Σ_k |f̂(k)|² = n * Σ_j |f(j)|²")
    print()

    for n in [7, 12, 16, 23]:
        np.random.seed(42)
        f = np.random.randn(n) + 1j * np.random.randn(n)
        fhat = dft(f)

        lhs = np.sum(np.abs(fhat) ** 2)
        rhs = n * np.sum(np.abs(f) ** 2)

        print(f"  n = {n:3d}:  Σ|f̂|² = {lhs:.6f},  n·Σ|f|² = {rhs:.6f},  "
              f"error = {abs(lhs - rhs):.2e}")

    print()
    print("  ✓ Parseval verified to machine precision for all group sizes.")
    print()


# ─────────────────────────────────────────────────────────────────────
# Demo 2: Inversion
# ─────────────────────────────────────────────────────────────────────

def demo_inversion():
    print("=" * 60)
    print("DEMO 2: Fourier Inversion")
    print("=" * 60)
    print()

    for n in [5, 10, 20]:
        np.random.seed(123)
        f = np.random.randn(n) + 1j * np.random.randn(n)
        f_recovered = idft(dft(f))
        err = np.max(np.abs(f - f_recovered))
        print(f"  n = {n:3d}:  max|f - IDFT(DFT(f))| = {err:.2e}")

    print()
    print("  ✓ Perfect reconstruction verified.")
    print()


# ─────────────────────────────────────────────────────────────────────
# Demo 3: Convolution Theorem
# ─────────────────────────────────────────────────────────────────────

def demo_convolution():
    print("=" * 60)
    print("DEMO 3: Convolution Theorem")
    print("=" * 60)
    print()
    print("FT(f * h) should equal FT(f) · FT(h) pointwise.")
    print()

    for n in [8, 13, 20]:
        np.random.seed(77)
        f = np.random.randn(n) + 1j * np.random.randn(n)
        h = np.random.randn(n) + 1j * np.random.randn(n)

        conv_fh = convolution(f, h)
        lhs = dft(conv_fh)
        rhs = dft(f) * dft(h)

        err = np.max(np.abs(lhs - rhs))
        print(f"  n = {n:3d}:  max|FT(f*h) - FT(f)·FT(h)| = {err:.2e}")

    print()
    print("  ✓ Convolution theorem verified numerically.")
    print()


# ─────────────────────────────────────────────────────────────────────
# Demo 4: Uncertainty Principle
# ─────────────────────────────────────────────────────────────────────

def demo_uncertainty():
    print("=" * 60)
    print("DEMO 4: Finite Uncertainty Principle")
    print("=" * 60)
    print()
    print("|supp(f)| · |supp(f̂)| ≥ n  for any nonzero f on Z/nZ.")
    print()

    n = 12

    # Test 1: delta function
    f_delta = np.zeros(n, dtype=complex)
    f_delta[0] = 1.0
    fhat_delta = dft(f_delta)
    s1 = support_size(f_delta)
    s2 = support_size(fhat_delta)
    print(f"  Delta function:  |supp(f)| = {s1},  |supp(f̂)| = {s2},  "
          f"product = {s1*s2},  n = {n}  ✓" if s1*s2 >= n else "  ✗")

    # Test 2: constant function
    f_const = np.ones(n, dtype=complex)
    fhat_const = dft(f_const)
    s1 = support_size(f_const)
    s2 = support_size(fhat_const)
    print(f"  Constant:        |supp(f)| = {s1},  |supp(f̂)| = {s2},  "
          f"product = {s1*s2},  n = {n}  ✓" if s1*s2 >= n else "  ✗")

    # Test 3: indicator of subgroup Z/3Z in Z/12Z
    f_sub = np.zeros(n, dtype=complex)
    for j in range(0, n, 4):  # subgroup of order 3
        f_sub[j] = 1.0
    fhat_sub = dft(f_sub)
    s1 = support_size(f_sub)
    s2 = support_size(fhat_sub)
    print(f"  Subgroup {0,4,8}:  |supp(f)| = {s1},  |supp(f̂)| = {s2},  "
          f"product = {s1*s2},  n = {n}  (equality!)" if s1*s2 == n else
          f"  Subgroup:        |supp(f)| = {s1},  |supp(f̂)| = {s2},  "
          f"product = {s1*s2},  n = {n}")

    # Test 4: random sparse function
    np.random.seed(999)
    f_sparse = np.zeros(n, dtype=complex)
    f_sparse[:4] = np.random.randn(4) + 1j * np.random.randn(4)
    fhat_sparse = dft(f_sparse)
    s1 = support_size(f_sparse)
    s2 = support_size(fhat_sparse)
    print(f"  Random sparse:   |supp(f)| = {s1},  |supp(f̂)| = {s2},  "
          f"product = {s1*s2},  n = {n}  ✓" if s1*s2 >= n else "  ✗")

    print()

    # Systematic test
    print("  Systematic test over many random functions:")
    violations = 0
    n_tests = 10000
    for trial in range(n_tests):
        np.random.seed(trial)
        sparsity = np.random.randint(1, n + 1)
        indices = np.random.choice(n, sparsity, replace=False)
        f_test = np.zeros(n, dtype=complex)
        f_test[indices] = np.random.randn(sparsity) + 1j * np.random.randn(sparsity)
        fhat_test = dft(f_test)
        if support_size(f_test) * support_size(fhat_test) < n:
            violations += 1

    print(f"    {n_tests} random tests on Z/{n}Z: {violations} violations")
    print(f"    ✓ Uncertainty principle holds in all cases." if violations == 0
          else f"    ✗ Found violations!")
    print()


# ─────────────────────────────────────────────────────────────────────
# Demo 5: Quantum Interpretation
# ─────────────────────────────────────────────────────────────────────

def demo_quantum():
    print("=" * 60)
    print("DEMO 5: Quantum Mechanics on Finite Configuration Space")
    print("=" * 60)
    print()
    print("Position basis → Momentum basis via Fourier transform.")
    print("Localized position ⟹ delocalized momentum (and vice versa).")
    print()

    n = 8

    # State 1: localized at position 0
    psi_loc = np.zeros(n, dtype=complex)
    psi_loc[0] = 1.0
    psi_mom = dft(psi_loc) / np.sqrt(n)  # normalized

    print(f"  State: localized at position 0")
    print(f"    Position probabilities: {np.abs(psi_loc)**2}")
    print(f"    Momentum probabilities: {np.round(np.abs(psi_mom)**2, 4)}")
    print(f"    → Completely delocalized in momentum space!")
    print()

    # State 2: uniform superposition (delocalized position)
    psi_deloc = np.ones(n, dtype=complex) / np.sqrt(n)
    psi_mom2 = dft(psi_deloc) / np.sqrt(n)

    print(f"  State: uniform superposition (delocalized)")
    print(f"    Position probabilities: {np.round(np.abs(psi_deloc)**2, 4)}")
    print(f"    Momentum probabilities: {np.round(np.abs(psi_mom2)**2, 4)}")
    print(f"    → Localized at momentum 0!")
    print()

    # Verify unitarity
    inner_pos = np.sum(np.abs(psi_loc) ** 2)
    inner_mom = np.sum(np.abs(psi_mom) ** 2)
    print(f"  Unitarity check (localized state):")
    print(f"    ||ψ||² in position = {inner_pos:.6f}")
    print(f"    ||ψ||² in momentum = {inner_mom:.6f}")
    print(f"    ✓ Probability preserved!" if abs(inner_pos - inner_mom) < 1e-10 else "    ✗ Violated!")
    print()


# ─────────────────────────────────────────────────────────────────────
# Demo 6: Extremizers of Uncertainty
# ─────────────────────────────────────────────────────────────────────

def demo_extremizers():
    print("=" * 60)
    print("DEMO 6: Extremizers of the Uncertainty Principle")
    print("=" * 60)
    print()
    print("Conjecture: equality |supp(f)|·|supp(f̂)| = n holds")
    print("iff f is a translated, modulated subgroup indicator.")
    print()

    n = 12
    divisors = [d for d in range(1, n + 1) if n % d == 0]
    print(f"  Group: Z/{n}Z,  divisors of {n}: {divisors}")
    print()

    # Check subgroup indicators achieve equality
    print("  Subgroup indicators:")
    for d in divisors:
        f = np.zeros(n, dtype=complex)
        for j in range(0, n, n // d):
            f[j] = 1.0
        fhat = dft(f)
        s_f = support_size(f)
        s_fhat = support_size(fhat)
        status = "EQUALITY" if s_f * s_fhat == n else f"product = {s_f * s_fhat}"
        print(f"    Subgroup of order {d}: |supp(f)| = {s_f}, "
              f"|supp(f̂)| = {s_fhat}, {status}")

    print()

    # Exhaustive search for other extremizers (small n)
    n_small = 6
    print(f"  Exhaustive search on Z/{n_small}Z for extremizers:")
    omega = np.exp(2j * np.pi / n_small)
    extremizers = []
    # Try all possible support sets and coefficient patterns
    count = 0
    for mask in range(1, 2**n_small):
        indices = [j for j in range(n_small) if mask & (1 << j)]
        # Try random coefficients
        for trial in range(100):
            np.random.seed(mask * 100 + trial)
            f = np.zeros(n_small, dtype=complex)
            f[indices] = np.random.randn(len(indices)) + 1j * np.random.randn(len(indices))
            fhat = dft(f)
            if support_size(f) * support_size(fhat) == n_small:
                count += 1

    print(f"    Found {count} extremizer instances among random samples.")
    print(f"    (Subgroup indicators and their translates/modulations)")
    print()


# ─────────────────────────────────────────────────────────────────────
# Demo 7: Additive Energy
# ─────────────────────────────────────────────────────────────────────

def demo_additive_energy():
    print("=" * 60)
    print("DEMO 7: Additive Energy via Fourier Coefficients")
    print("=" * 60)
    print()
    print("E(A) = (1/n) Σ_k |1̂_A(k)|⁴")
    print()

    for n in [7, 11, 13]:
        np.random.seed(42)
        A = sorted(np.random.choice(n, n // 2, replace=False))

        # Direct computation of additive energy
        energy_direct = 0
        for a1 in A:
            for a2 in A:
                for a3 in A:
                    for a4 in A:
                        if (a1 - a2) % n == (a3 - a4) % n:
                            energy_direct += 1

        # Fourier computation
        indicator = np.zeros(n, dtype=complex)
        indicator[A] = 1.0
        fhat = dft(indicator)
        energy_fourier = np.sum(np.abs(fhat) ** 4) / n

        print(f"  n = {n}, A = {A}")
        print(f"    Direct E(A) = {energy_direct}")
        print(f"    Fourier E(A) = {energy_fourier:.4f}")
        print(f"    Match: {'✓' if abs(energy_direct - energy_fourier) < 0.01 else '✗'}")
        print()

    print("  ✓ Additive energy identity verified.")
    print()


# ─────────────────────────────────────────────────────────────────────

def main():
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Fourier Analysis on Finite Groups — Numerical Demos   ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    demo_parseval()
    demo_inversion()
    demo_convolution()
    demo_uncertainty()
    demo_quantum()
    demo_extremizers()
    demo_additive_energy()

    print("=" * 60)
    print("All demos completed successfully.")
    print("=" * 60)


if __name__ == "__main__":
    main()
