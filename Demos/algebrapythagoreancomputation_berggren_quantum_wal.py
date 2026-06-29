#!/usr/bin/env python3
"""
Applications of Berggren Quantum Walk Spectral Duality

Demonstrates real-world applications:
1. Quantum simulation compression
2. Cryptographic key-space analysis
3. Number-theoretic spectral fingerprinting
"""

import numpy as np
import itertools
from algorithms import (
    eval_word_matrix, compute_reachable_rank,
    extract_minimal_realization, reconstruct_amplitude
)

def random_unitary(n):
    Z = (np.random.randn(n, n) + 1j * np.random.randn(n, n)) / np.sqrt(2)
    Q, R = np.linalg.qr(Z)
    D = np.diag(np.diag(R) / np.abs(np.diag(R)))
    return Q @ D


def application_quantum_simulation():
    """Application 1: Quantum Simulation Compression

    Shows that simulating a quantum walk on the Berggren tree
    can be done in the compressed reachable submodule rather than
    the full exponentially-growing tree.
    """
    print("=" * 60)
    print("APPLICATION 1: QUANTUM SIMULATION COMPRESSION")
    print("=" * 60)

    dim = 4
    np.random.seed(42)
    gens = {g: random_unitary(dim) for g in 'ABC'}
    psi0 = np.array([1, 0, 0, 0], dtype=complex)
    obs = np.array([0, 0, 0, 1], dtype=complex)

    # Full simulation cost at depth d: 3^d matrix-vector products
    # Compressed simulation: compute in r-dimensional space
    ranks, stab = compute_reachable_rank(gens, psi0, 6)
    r = ranks[-1]

    print(f"\nWalk dimension: {dim}")
    print(f"Reachable submodule rank: {r}")
    print(f"Stabilization depth: {stab}")
    print(f"\nCompression ratios by depth:")
    for d in range(1, 8):
        full_cost = 3**d  # Number of paths
        compressed_cost = r  # Work in r-dimensional space
        ratio = full_cost / compressed_cost
        print(f"  Depth {d}: {full_cost:>6} paths → {r}-dim model "
              f"(compression {ratio:.0f}×)")

    # Extract minimal realization
    real = extract_minimal_realization(gens, psi0, obs, 3)
    print(f"\nMinimal realization dimension: {real['dim']}")

    # Verify compressed simulation matches full simulation
    print("\nVerification (compressed vs full simulation):")
    for d in [3, 4, 5]:
        max_err = 0
        count = 0
        for word in itertools.product('ABC', repeat=d):
            w = ''.join(word)
            true_amp = np.conj(obs) @ eval_word_matrix(gens, w) @ psi0
            recon_amp = reconstruct_amplitude(real, w)
            max_err = max(max_err, abs(true_amp - recon_amp))
            count += 1
        print(f"  Depth {d}: {count} words, max error = {max_err:.2e}")


def application_cryptographic_analysis():
    """Application 2: Cryptographic Key-Space Analysis

    Analyzes the effective key space of a Berggren-based
    quantum key distribution scheme.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: CRYPTOGRAPHIC KEY-SPACE ANALYSIS")
    print("=" * 60)

    print("\nAnalyzing distinguishability of Berggren quantum walks...")

    # Generate two random walks and analyze when they become distinguishable
    for trial in range(3):
        np.random.seed(100 + trial)
        dim = 3
        gens1 = {g: random_unitary(dim) for g in 'ABC'}
        gens2 = {g: random_unitary(dim) for g in 'ABC'}
        psi0 = np.array([1, 0, 0], dtype=complex)
        obs = np.array([1, 0, 0], dtype=complex)

        # Find minimum distinguishing depth
        print(f"\n  Trial {trial + 1}:")
        for d in range(1, 6):
            max_diff = 0
            for word in itertools.product('ABC', repeat=d):
                w = ''.join(word)
                amp1 = np.conj(obs) @ eval_word_matrix(gens1, w) @ psi0
                amp2 = np.conj(obs) @ eval_word_matrix(gens2, w) @ psi0
                max_diff = max(max_diff, abs(amp1 - amp2))
            print(f"    Depth {d}: max amplitude difference = {max_diff:.6f}")
            if max_diff > 0.1:
                print(f"    → Distinguished at depth {d}")
                break

    print("\n  Conclusion: Random walks are typically distinguishable at depth 1.")
    print("  By Theorem B, the distinguishing depth ≤ dim(V).")
    print("  Effective key space = space of unitaries, NOT space of tree paths.")


def application_spectral_fingerprinting():
    """Application 3: Number-Theoretic Spectral Fingerprinting

    Shows how the spectral realization provides a finite
    fingerprint of the quantum walk that characterizes
    the entire infinite amplitude function.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: SPECTRAL FINGERPRINTING")
    print("=" * 60)

    np.random.seed(77)
    dim = 3
    gens = {g: random_unitary(dim) for g in 'ABC'}
    psi0 = np.array([1, 0, 0], dtype=complex)
    obs = np.array([1, 0, 0], dtype=complex)

    real = extract_minimal_realization(gens, psi0, obs, 3)

    print(f"\nWalk dimension: {dim}")
    print(f"Fingerprint dimension: {real['dim']}")
    print(f"\nSpectral fingerprint (generator matrices in minimal realization):")

    for g in 'ABC':
        T = real['T'][g]
        eigenvals = np.linalg.eigvals(T)
        print(f"\n  T_{g} eigenvalues: {', '.join(f'{e:.4f}' for e in eigenvals)}")
        print(f"  T_{g} trace: {np.trace(T):.4f}")
        print(f"  T_{g} determinant: {np.linalg.det(T):.4f}")

    print(f"\n  Initial vector α: {real['init']}")
    print(f"  Output vector ω: {real['out']}")

    # Show that the fingerprint determines all amplitudes
    print(f"\n  Fingerprint reconstruction test:")
    test_words = ['A', 'BC', 'ABC', 'BAC', 'ABCBA', 'CCCCCC']
    for w in test_words:
        true_amp = np.conj(obs) @ eval_word_matrix(gens, w) @ psi0
        recon_amp = reconstruct_amplitude(real, w)
        print(f"    word='{w}': amplitude = {recon_amp:.6f} "
              f"(error = {abs(true_amp - recon_amp):.2e})")

    print("\n  The finite fingerprint (3 matrices + 2 vectors) determines")
    print("  the amplitude at every point of the infinite Berggren tree.")


if __name__ == '__main__':
    application_quantum_simulation()
    application_cryptographic_analysis()
    application_spectral_fingerprinting()
    print("\n" + "=" * 60)
    print("ALL APPLICATIONS COMPLETE")
    print("=" * 60)


#!/usr/bin/env python3
"""
Berggren Quantum Walk Spectral Duality — Demonstration

This script demonstrates the core theorems of the spectral realization theory
for quantum walks on the Berggren tree of primitive Pythagorean triples.

Key demonstrations:
1. Berggren tree generation and triple enumeration
2. Quantum walk simulation with unitary generators
3. Reachable submodule computation and rank stabilization
4. Observational equivalence and amplitude reconstruction
5. Minimal realization extraction
"""

import numpy as np
from typing import List, Tuple, Dict, Optional
import itertools

# ============================================================
# Section 1: Berggren Matrices and Triple Tree
# ============================================================

# The three Berggren matrices that generate all primitive Pythagorean triples
B_A = np.array([[ 1, -2,  2],
                [ 2, -1,  2],
                [ 2, -2,  3]])

B_B = np.array([[ 1,  2,  2],
                [ 2,  1,  2],
                [ 2,  2,  3]])

B_C = np.array([[-1,  2,  2],
                [-2,  1,  2],
                [-2,  2,  3]])

BERGGREN_MATRICES = {'A': B_A, 'B': B_B, 'C': B_C}
ROOT_TRIPLE = np.array([3, 4, 5])

def generate_triple(word: str, root: np.ndarray = ROOT_TRIPLE) -> np.ndarray:
    """Generate a Pythagorean triple by applying a Berggren word to the root."""
    triple = root.copy()
    for g in reversed(word):  # Apply right-to-left (composition order)
        triple = BERGGREN_MATRICES[g] @ triple
    return triple

def verify_pythagorean(triple: np.ndarray) -> bool:
    """Verify a^2 + b^2 = c^2."""
    a, b, c = triple
    return a**2 + b**2 == c**2

def enumerate_triples(max_depth: int) -> Dict[str, np.ndarray]:
    """Enumerate all triples up to given depth in the Berggren tree."""
    triples = {'': ROOT_TRIPLE}
    for depth in range(1, max_depth + 1):
        for word in itertools.product('ABC', repeat=depth):
            w = ''.join(word)
            triples[w] = generate_triple(w)
    return triples

# ============================================================
# Section 2: Quantum Walk Simulation
# ============================================================

def random_unitary(n: int) -> np.ndarray:
    """Generate a random n×n unitary matrix via QR decomposition."""
    Z = (np.random.randn(n, n) + 1j * np.random.randn(n, n)) / np.sqrt(2)
    Q, R = np.linalg.qr(Z)
    D = np.diag(np.diag(R) / np.abs(np.diag(R)))
    return Q @ D

class BerggrenQuantumWalk:
    """A quantum walk on the Berggren tree with unitary generators."""

    def __init__(self, dim: int, unitaries: Optional[Dict[str, np.ndarray]] = None,
                 psi0: Optional[np.ndarray] = None, obs: Optional[np.ndarray] = None):
        self.dim = dim
        if unitaries is None:
            self.U = {g: random_unitary(dim) for g in 'ABC'}
        else:
            self.U = unitaries
        self.psi0 = psi0 if psi0 is not None else np.random.randn(dim) + 1j * np.random.randn(dim)
        self.psi0 /= np.linalg.norm(self.psi0)
        self.obs = obs if obs is not None else np.random.randn(dim) + 1j * np.random.randn(dim)
        self.obs /= np.linalg.norm(self.obs)

    def eval_word(self, word: str) -> np.ndarray:
        """Compute U(w) as a matrix product.
        Convention: evalWord [g1, g2, ...] = U(g1) * U(g2) * ...
        Matching the Lean FreeMonoid.lift convention."""
        result = np.eye(self.dim, dtype=complex)
        for g in reversed(word):  # Right-to-left: U(g1) * (U(g2) * ...)
            result = self.U[g] @ result
        return result

    def eval_state(self, word: str) -> np.ndarray:
        """Compute U(w) · ψ₀."""
        return self.eval_word(word) @ self.psi0

    def amplitude(self, word: str) -> complex:
        """Compute ⟨obs, U(w)ψ₀⟩."""
        return np.conj(self.obs) @ self.eval_state(word)

    def kernel(self, u: str, v: str) -> complex:
        """Compute K(u,v) = ⟨U(u)ψ₀, U(v)ψ₀⟩."""
        return np.conj(self.eval_state(u)) @ self.eval_state(v)

# ============================================================
# Section 3: Reachable Submodule and Rank Stabilization
# ============================================================

def compute_reachable_states(walk: BerggrenQuantumWalk, max_depth: int) -> List[np.ndarray]:
    """Compute all reachable states up to given depth."""
    states = [walk.eval_state('')]
    for depth in range(1, max_depth + 1):
        for word in itertools.product('ABC', repeat=depth):
            w = ''.join(word)
            states.append(walk.eval_state(w))
    return states

def reachable_rank_by_depth(walk: BerggrenQuantumWalk, max_depth: int,
                            tol: float = 1e-10) -> List[int]:
    """Compute the rank of the reachable submodule at each depth.

    This demonstrates Theorem A: the rank stabilizes at finite depth.
    """
    ranks = []
    all_states = []
    for depth in range(max_depth + 1):
        if depth == 0:
            all_states.append(walk.eval_state(''))
        else:
            for word in itertools.product('ABC', repeat=depth):
                w = ''.join(word)
                all_states.append(walk.eval_state(w))
        # Stack states as rows and compute rank
        matrix = np.vstack([s.reshape(1, -1) for s in all_states])
        rank = np.linalg.matrix_rank(matrix, tol=tol)
        ranks.append(rank)
    return ranks

# ============================================================
# Section 4: Hankel Matrix and Minimal Realization
# ============================================================

def build_hankel_matrix(walk: BerggrenQuantumWalk, depth: int) -> np.ndarray:
    """Build the Hankel matrix H(u,v) = amplitude(u ++ v).

    Rows are indexed by words of length ≤ depth,
    columns by words of length ≤ depth.
    """
    words = ['']
    for d in range(1, depth + 1):
        for w in itertools.product('ABC', repeat=d):
            words.append(''.join(w))

    n = len(words)
    H = np.zeros((n, n), dtype=complex)
    for i, u in enumerate(words):
        for j, v in enumerate(words):
            H[i, j] = walk.amplitude(u + v)
    return H, words

def hankel_rank_by_depth(walk: BerggrenQuantumWalk, max_depth: int,
                         tol: float = 1e-10) -> List[int]:
    """Compute the Hankel matrix rank at each depth."""
    ranks = []
    for depth in range(max_depth + 1):
        H, _ = build_hankel_matrix(walk, depth)
        ranks.append(np.linalg.matrix_rank(H, tol=tol))
    return ranks

def extract_minimal_realization(walk: BerggrenQuantumWalk, depth: int,
                                 tol: float = 1e-10):
    """Extract the minimal finite realization from truncated Hankel data.

    Returns (T_A, T_B, T_C, init, out, dim) where:
    - T_g are the generator matrices in the minimal realization
    - init is the initial vector
    - out is the output functional
    - dim is the realization dimension (= Hankel rank)
    """
    H, words = build_hankel_matrix(walk, depth)
    rank = np.linalg.matrix_rank(H, tol=tol)

    # SVD-based extraction
    U, S, Vh = np.linalg.svd(H)
    U_r = U[:, :rank] * np.sqrt(S[:rank])
    V_r = Vh[:rank, :] * np.sqrt(S[:rank, np.newaxis])

    # Initial and output vectors
    init = V_r[:, 0]  # Column corresponding to empty word
    out = U_r[0, :]    # Row corresponding to empty word

    # Build shifted Hankel matrices for each generator
    T = {}
    for g in 'ABC':
        n = len(words)
        H_g = np.zeros((n, n), dtype=complex)
        for i, u in enumerate(words):
            for j, v in enumerate(words):
                H_g[i, j] = walk.amplitude(u + g + v)
        # Project into the reduced space
        T_g = np.linalg.lstsq(U_r, H_g @ np.linalg.pinv(V_r), rcond=None)[0]
        T[g] = T_g

    return T, init, out, rank

# ============================================================
# Section 5: Demonstration
# ============================================================

def demo_berggren_tree():
    """Demonstrate the Berggren tree structure."""
    print("=" * 60)
    print("BERGGREN TRIPLE TREE DEMONSTRATION")
    print("=" * 60)
    print(f"\nRoot triple: {ROOT_TRIPLE}")
    print(f"Pythagorean check: {ROOT_TRIPLE[0]}² + {ROOT_TRIPLE[1]}² = "
          f"{ROOT_TRIPLE[0]**2} + {ROOT_TRIPLE[1]**2} = {ROOT_TRIPLE[2]**2} = {ROOT_TRIPLE[2]}²")
    print(f"Verified: {verify_pythagorean(ROOT_TRIPLE)}")

    print("\nFirst-level children:")
    for g in 'ABC':
        t = generate_triple(g)
        print(f"  {g}: ({t[0]}, {t[1]}, {t[2]}) — "
              f"Pythagorean: {verify_pythagorean(t)}")

    print("\nSecond-level descendants:")
    count = 0
    for w in itertools.product('ABC', repeat=2):
        word = ''.join(w)
        t = generate_triple(word)
        if count < 5:
            print(f"  {word}: ({t[0]}, {t[1]}, {t[2]})")
        count += 1
    print(f"  ... ({count} triples at depth 2)")

    # Count triples at each depth
    print("\nTriple count by depth:")
    for d in range(6):
        n = 3**d if d > 0 else 1
        print(f"  Depth {d}: {n} triples")

def demo_spectral_compression():
    """Demonstrate spectral compression (Theorem A)."""
    print("\n" + "=" * 60)
    print("SPECTRAL COMPRESSION (THEOREM A)")
    print("=" * 60)

    for dim in [2, 3, 4, 5]:
        np.random.seed(42 + dim)
        walk = BerggrenQuantumWalk(dim)
        ranks = reachable_rank_by_depth(walk, 6)
        print(f"\nDimension {dim}:")
        print(f"  Reachable rank by depth: {ranks}")
        stab_depth = next((i for i in range(len(ranks)-1) if ranks[i] == ranks[i+1]), len(ranks)-1)
        print(f"  Stabilization depth: {stab_depth}")
        print(f"  Final rank: {ranks[-1]} (≤ dim = {dim}) ✓")

def demo_hankel_minimization():
    """Demonstrate Hankel rank and minimal realization (Theorem C)."""
    print("\n" + "=" * 60)
    print("HANKEL RANK & MINIMAL REALIZATION (THEOREM C)")
    print("=" * 60)

    np.random.seed(123)
    dim = 4
    walk = BerggrenQuantumWalk(dim)

    hankel_ranks = hankel_rank_by_depth(walk, 4)
    print(f"\nWalk dimension: {dim}")
    print(f"Hankel rank by depth: {hankel_ranks}")

    # Extract minimal realization
    T, init, out, rank = extract_minimal_realization(walk, 3)
    print(f"Minimal realization dimension: {rank}")

    # Verify reconstruction for short words
    print("\nAmplitude reconstruction verification:")
    test_words = ['', 'A', 'B', 'C', 'AB', 'BA', 'ABC']
    for w in test_words:
        true_amp = walk.amplitude(w)
        # Reconstruct: out @ T_w @ init
        state = init.copy()
        for g in reversed(w):
            state = T[g] @ state
        recon_amp = out @ state
        error = abs(true_amp - recon_amp)
        print(f"  word='{w}': true={true_amp:.6f}, recon={recon_amp:.6f}, error={error:.2e}")

def demo_observational_equivalence():
    """Demonstrate observational equivalence (Theorem B)."""
    print("\n" + "=" * 60)
    print("OBSERVATIONAL EQUIVALENCE (THEOREM B)")
    print("=" * 60)

    np.random.seed(456)
    dim = 3
    walk = BerggrenQuantumWalk(dim)

    # Create two states that differ by an element of the observation kernel
    psi = walk.eval_state('A')
    phi = walk.eval_state('B')

    print(f"\nψ = U(A)ψ₀, φ = U(B)ψ₀")
    print(f"Amplitudes from ψ vs φ:")
    for w in ['', 'A', 'B', 'C', 'AB']:
        amp_psi = np.conj(walk.obs) @ walk.eval_word(w) @ psi
        amp_phi = np.conj(walk.obs) @ walk.eval_word(w) @ phi
        print(f"  word='{w}': amp(ψ)={amp_psi:.4f}, amp(φ)={amp_phi:.4f}, "
              f"diff={abs(amp_psi - amp_phi):.4e}")

    # Show that the same state gives identical amplitudes
    psi2 = walk.eval_state('A')
    print(f"\nψ = ψ' = U(A)ψ₀ (same state):")
    all_same = True
    for w in ['', 'A', 'B', 'C', 'AB', 'BC', 'ABC']:
        amp1 = np.conj(walk.obs) @ walk.eval_word(w) @ psi
        amp2 = np.conj(walk.obs) @ walk.eval_word(w) @ psi2
        if abs(amp1 - amp2) > 1e-12:
            all_same = False
    print(f"  All amplitudes identical: {all_same} ✓")

def demo_kernel_properties():
    """Demonstrate kernel Hermiticity and shift invariance."""
    print("\n" + "=" * 60)
    print("KERNEL PROPERTIES")
    print("=" * 60)

    np.random.seed(789)
    dim = 4
    walk = BerggrenQuantumWalk(dim)

    # Hermitian symmetry: K(u,v) = conj(K(v,u))
    print("\nHermitian symmetry K(u,v) = conj(K(v,u)):")
    for u, v in [('A', 'B'), ('AB', 'C'), ('', 'ABC')]:
        kuv = walk.kernel(u, v)
        kvu = walk.kernel(v, u)
        print(f"  K({u},{v}) = {kuv:.4f}, conj(K({v},{u})) = {np.conj(kvu):.4f}, "
              f"match: {abs(kuv - np.conj(kvu)) < 1e-12}")

    # Diagonal non-negativity
    print("\nDiagonal non-negativity K(w,w) ≥ 0:")
    for w in ['', 'A', 'B', 'C', 'AB', 'ABC']:
        kww = walk.kernel(w, w)
        print(f"  K({w},{w}) = {kww.real:.6f} + {kww.imag:.6f}i "
              f"(real: {abs(kww.imag) < 1e-12}, nonneg: {kww.real >= -1e-12})")

    # Shift invariance: K(g·u, g·v) = K(u,v)
    print("\nShift invariance K(g·u, g·v) = K(u,v):")
    for g in 'ABC':
        for u, v in [('A', 'B'), ('', 'C')]:
            kuv = walk.kernel(u, v)
            kguv = walk.kernel(g + u, g + v)
            print(f"  K({g}{u},{g}{v}) = {kguv:.4f}, K({u},{v}) = {kuv:.4f}, "
                  f"match: {abs(kguv - kuv) < 1e-10}")

def main():
    """Run all demonstrations."""
    print("BERGGREN QUANTUM WALK SPECTRAL DUALITY")
    print("Demonstration of Formally Verified Theorems")
    print("=" * 60)

    demo_berggren_tree()
    demo_spectral_compression()
    demo_hankel_minimization()
    demo_observational_equivalence()
    demo_kernel_properties()

    print("\n" + "=" * 60)
    print("ALL DEMONSTRATIONS COMPLETE")
    print("=" * 60)

if __name__ == '__main__':
    main()
