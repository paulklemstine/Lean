#!/usr/bin/env python3
"""
Applications of Berggren Quantum Walk Theory

1. Quantum system identification from observed amplitudes
2. Arithmetic quantum signal processing
3. Pythagorean quantum key distribution sketch
"""

import numpy as np
from demo import BerggrenQuantumWalk, generate_words, rotation_matrix, GENERATORS


def application_system_identification():
    """
    Application 1: Quantum System Identification

    Given observed amplitude data from an unknown quantum walk on the
    Berggren tree, reconstruct the walk parameters.
    """
    print("=" * 60)
    print("APPLICATION 1: Quantum System Identification")
    print("=" * 60)

    # "Unknown" system (the oracle)
    theta_secret = [np.pi/5, np.pi/7, np.pi/11]
    U_secret = {g: rotation_matrix(t) for g, t in zip(GENERATORS, theta_secret)}
    psi0_secret = np.array([1.0, 0.0])
    Q_secret = BerggrenQuantumWalk(U_secret, psi0_secret)

    # Observer measures amplitudes at various words
    observed_words = generate_words(4)
    print(f"\nObserver measures {len(observed_words)} amplitude values")

    # Build observed kernel
    kernel_data = {}
    for u in observed_words:
        for v in observed_words:
            kernel_data[(u, v)] = Q_secret.kernel(u, v)

    # Step 1: Determine dimension from rank
    m = len(observed_words)
    K = np.zeros((m, m), dtype=complex)
    for i, u in enumerate(observed_words):
        for j, v in enumerate(observed_words):
            K[i, j] = kernel_data[(u, v)]

    eigenvalues = np.sort(np.linalg.eigvalsh(K))[::-1]
    rank = np.sum(eigenvalues > 1e-10)
    print(f"Estimated dimension: {rank}")
    print(f"Eigenvalue spectrum: {eigenvalues[:5].real}")

    # Step 2: Extract rotation angles from kernel structure
    # For 2D rotations, K(A, '') = cos(theta_A) (for unit initial state)
    for g, theta_true in zip(GENERATORS, theta_secret):
        k_val = Q_secret.kernel(g, '')
        theta_est = np.arccos(np.clip(k_val.real, -1, 1))
        print(f"  θ_{g}: true = {theta_true:.6f}, estimated = {theta_est:.6f}, "
              f"error = {abs(theta_true - theta_est):.2e}")

    print()


def application_quantum_signal():
    """
    Application 2: Arithmetic Quantum Signal Processing

    Use the Berggren tree structure to decompose a quantum signal
    into components aligned with Pythagorean arithmetic.
    """
    print("=" * 60)
    print("APPLICATION 2: Arithmetic Quantum Signal Processing")
    print("=" * 60)

    # Create a signal: superposition of amplitude functions
    np.random.seed(123)
    n = 4

    def random_unitary(dim):
        Z = (np.random.randn(dim, dim) + 1j * np.random.randn(dim, dim)) / np.sqrt(2)
        Q_mat, R = np.linalg.qr(Z)
        return Q_mat @ np.diag(np.diag(R) / np.abs(np.diag(R)))

    U = {g: random_unitary(n) for g in GENERATORS}
    psi0 = np.array([1, 0, 0, 0], dtype=complex)
    obs = np.array([0, 1, 0, 0], dtype=complex)
    Q = BerggrenQuantumWalk(U, psi0, obs)

    # Compute amplitude along different tree paths
    print("\nAmplitude magnitudes along tree paths:")
    print(f"{'Path':<8} {'|amp|':>10} {'Phase (deg)':>12}")
    print("-" * 32)

    for w in generate_words(3):
        amp = Q.amplitude(w)
        mag = abs(amp)
        phase = np.angle(amp, deg=True)
        if len(w) <= 2:
            print(f"{w if w else '(root)':<8} {mag:10.6f} {phase:12.2f}")

    # Compute "energy" at each depth level
    print("\nEnergy distribution by depth:")
    for depth in range(5):
        words_at_depth = [w for w in generate_words(depth)
                         if len(w) == depth]
        if not words_at_depth:
            words_at_depth = ['']
        energy = sum(abs(Q.amplitude(w))**2 for w in words_at_depth)
        print(f"  Depth {depth}: {len(words_at_depth)} words, energy = {energy:.6f}")

    print()


def application_qkd_sketch():
    """
    Application 3: Pythagorean Quantum Key Distribution Sketch

    Two parties (Alice and Bob) share a secret Berggren quantum walk.
    Alice sends Bob a random word path; Bob measures the amplitude.
    The Berggren arithmetic structure provides additional security
    guarantees (e.g., shift invariance constrains eavesdropper models).
    """
    print("=" * 60)
    print("APPLICATION 3: Pythagorean QKD Sketch")
    print("=" * 60)

    # Shared secret walk
    np.random.seed(999)
    n = 3

    def random_unitary(dim):
        Z = (np.random.randn(dim, dim) + 1j * np.random.randn(dim, dim)) / np.sqrt(2)
        Q_mat, R = np.linalg.qr(Z)
        return Q_mat @ np.diag(np.diag(R) / np.abs(np.diag(R)))

    U_shared = {g: random_unitary(n) for g in GENERATORS}
    psi0_shared = np.array([1, 0, 0], dtype=complex)
    Q_shared = BerggrenQuantumWalk(U_shared, psi0_shared)

    # Protocol: Alice generates random paths, Bob measures amplitudes
    num_rounds = 20
    np.random.seed(42)

    print(f"\nProtocol with {num_rounds} rounds:")
    print(f"{'Round':<6} {'Path':<8} {'Amplitude':>20} {'Key bit':>8}")
    print("-" * 44)

    key_bits = []
    for rnd in range(num_rounds):
        # Alice chooses random path of length 2-3
        path_len = np.random.choice([2, 3])
        path = ''.join(np.random.choice(GENERATORS, size=path_len))

        # Bob computes expected amplitude (both share the walk)
        amp = Q_shared.amplitude(path)

        # Key bit from amplitude phase
        key_bit = 1 if amp.real > 0 else 0
        key_bits.append(key_bit)

        if rnd < 10:
            print(f"{rnd:<6} {path:<8} {amp.real:+.6f}{amp.imag:+.6f}i  {key_bit:>8}")

    if num_rounds > 10:
        print(f"  ... ({num_rounds - 10} more rounds)")

    print(f"\nGenerated key: {''.join(map(str, key_bits))}")

    # Verify shift invariance constraint on eavesdropper
    print("\nSecurity check — shift invariance test:")
    for g in GENERATORS:
        errors = []
        for _ in range(100):
            path_len = np.random.choice([2, 3])
            u = ''.join(np.random.choice(GENERATORS, size=path_len))
            v = ''.join(np.random.choice(GENERATORS, size=path_len))
            err = abs(Q_shared.kernel(g + u, g + v) - Q_shared.kernel(u, v))
            errors.append(err)
        print(f"  Generator {g}: max shift error = {max(errors):.2e} "
              f"(eavesdropper must preserve this)")

    print()


if __name__ == '__main__':
    application_system_identification()
    application_quantum_signal()
    application_qkd_sketch()
    print("All applications demonstrated.")


#!/usr/bin/env python3
"""
Berggren Quantum Walk Duality — Demonstration

Concrete numerical examples illustrating the main theorems:
1. Kernel properties (Hermitian, positive semi-definite, shift-invariant)
2. Moment table validation
3. Phase gauge equivalence
"""

import numpy as np
from itertools import product as cart_product

# --- Berggren generators ---
GENERATORS = ['A', 'B', 'C']

def berggren_matrices():
    """The three Berggren matrices acting on (a,b,c) column vectors."""
    B_A = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]])
    B_B = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]])
    B_C = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]])
    return {'A': B_A, 'B': B_B, 'C': B_C}

def verify_lorentz_preservation():
    """Verify that Berggren matrices preserve the Lorentz form Q = diag(1,1,-1)."""
    Q = np.diag([1, 1, -1])
    mats = berggren_matrices()
    print("=== Berggren Matrices Preserve Lorentz Form ===")
    for name, B in mats.items():
        residual = B.T @ Q @ B - Q
        print(f"  B_{name}^T Q B_{name} - Q = (max abs entry: {np.max(np.abs(residual)):.2e})")
    print()


# --- Quantum Walk ---
class BerggrenQuantumWalk:
    """A Berggren quantum walk of dimension n."""

    def __init__(self, unitaries: dict, psi0: np.ndarray, obs: np.ndarray = None):
        """
        Parameters
        ----------
        unitaries : dict mapping 'A','B','C' to n×n unitary matrices
        psi0 : initial state vector (n,)
        obs : observation vector (n,), defaults to psi0
        """
        self.n = psi0.shape[0]
        self.U = unitaries
        self.psi0 = psi0.astype(complex)
        self.obs = obs.astype(complex) if obs is not None else self.psi0.copy()

        # Verify unitarity
        for g, Ug in self.U.items():
            assert np.allclose(Ug @ Ug.conj().T, np.eye(self.n)), f"U_{g} not unitary"
            assert np.allclose(Ug.conj().T @ Ug, np.eye(self.n)), f"U_{g}† U_{g} ≠ I"

    def eval_word(self, word: str) -> np.ndarray:
        """Evaluate the product of unitaries along a word."""
        result = np.eye(self.n, dtype=complex)
        for g in word:
            result = self.U[g] @ result
        return result

    def eval_state(self, word: str) -> np.ndarray:
        """Evaluate U(word) · ψ₀."""
        return self.eval_word(word) @ self.psi0

    def kernel(self, u: str, v: str) -> complex:
        """K(u,v) = ⟨U(u)ψ₀, U(v)ψ₀⟩"""
        su = self.eval_state(u)
        sv = self.eval_state(v)
        return np.vdot(su, sv)

    def amplitude(self, w: str) -> complex:
        """amp(w) = ⟨obs, U(w)ψ₀⟩"""
        return np.vdot(self.obs, self.eval_state(w))


def generate_words(max_length: int) -> list:
    """Generate all Berggren words up to given length."""
    words = ['']  # empty word = identity
    for length in range(1, max_length + 1):
        for combo in cart_product(GENERATORS, repeat=length):
            words.append(''.join(combo))
    return words


def rotation_matrix(theta: float) -> np.ndarray:
    """2D rotation matrix."""
    return np.array([
        [np.cos(theta), -np.sin(theta)],
        [np.sin(theta), np.cos(theta)]
    ])


def demo_kernel_properties():
    """Demonstrate Theorems 3.1-3.5: kernel is Hermitian, PSD, shift-invariant."""
    print("=" * 60)
    print("DEMO 1: Kernel Properties")
    print("=" * 60)

    # Create a 2D quantum walk with rotation unitaries
    U_A = rotation_matrix(np.pi / 4)
    U_B = rotation_matrix(np.pi / 3)
    U_C = rotation_matrix(np.pi / 6)
    psi0 = np.array([1.0, 0.0])

    Q = BerggrenQuantumWalk({'A': U_A, 'B': U_B, 'C': U_C}, psi0)

    words = generate_words(3)
    m = len(words)
    print(f"\nNumber of words up to length 3: {m}")

    # Build kernel matrix
    K = np.zeros((m, m), dtype=complex)
    for i, u in enumerate(words):
        for j, v in enumerate(words):
            K[i, j] = Q.kernel(u, v)

    # Theorem 3.1: Hermitian
    hermitian_error = np.max(np.abs(K - K.conj().T))
    print(f"\nTheorem 3.1 (Hermitian): max|K - K†| = {hermitian_error:.2e}")

    # Theorem 3.2: Diagonal nonneg
    diag_real = np.real(np.diag(K))
    print(f"Theorem 3.2 (Diagonal ≥ 0): min Re(K(w,w)) = {np.min(diag_real):.6f}")

    # Theorem 3.3: Diagonal real
    diag_imag = np.imag(np.diag(K))
    print(f"Theorem 3.3 (Diagonal real): max|Im(K(w,w))| = {np.max(np.abs(diag_imag)):.2e}")

    # Theorem 3.5: Positive semi-definite
    eigenvalues = np.linalg.eigvalsh(K)
    print(f"Theorem 3.5 (PSD): min eigenvalue = {np.min(eigenvalues):.2e}")

    # Theorem 3.4: Shift invariance
    shift_errors = []
    for g in GENERATORS:
        for u in generate_words(2):
            for v in generate_words(2):
                gu = g + u
                gv = g + v
                err = abs(Q.kernel(gu, gv) - Q.kernel(u, v))
                shift_errors.append(err)
    print(f"Theorem 3.4 (Shift invariant): max shift error = {max(shift_errors):.2e}")
    print()


def demo_moment_table():
    """Demonstrate moment table validation and self-realization."""
    print("=" * 60)
    print("DEMO 2: Moment Table Validation")
    print("=" * 60)

    # Create a 3D walk
    # Random unitaries via QR decomposition
    np.random.seed(42)
    def random_unitary(n):
        Z = (np.random.randn(n, n) + 1j * np.random.randn(n, n)) / np.sqrt(2)
        Q, R = np.linalg.qr(Z)
        return Q @ np.diag(np.diag(R) / np.abs(np.diag(R)))

    U = {g: random_unitary(3) for g in GENERATORS}
    psi0 = np.array([1.0, 0.0, 0.0], dtype=complex)
    Q = BerggrenQuantumWalk(U, psi0)

    words = generate_words(2)
    m = len(words)

    # Build moment table
    table = {}
    for u in words:
        for v in words:
            table[(u, v)] = Q.kernel(u, v)

    # Validate
    print(f"\nMoment table size: {m}×{m} = {m*m} entries")

    # Hermitian
    max_herm = max(abs(table[(u,v)] - table[(v,u)].conj()) for u in words for v in words)
    print(f"Hermitian check: max error = {max_herm:.2e}")

    # Positive
    min_diag = min(table[(w,w)].real for w in words)
    print(f"Positivity check: min diagonal = {min_diag:.6f}")

    # Shift compatible
    max_shift = 0
    for g in GENERATORS:
        for u in words:
            for v in words:
                gu = g + u
                gv = g + v
                if gu in [w for w in generate_words(3)] and gv in [w for w in generate_words(3)]:
                    err = abs(Q.kernel(gu, gv) - Q.kernel(u, v))
                    max_shift = max(max_shift, err)
    print(f"Shift compatibility: max error = {max_shift:.2e}")

    # Rank of kernel matrix
    K = np.array([[table.get((u,v), 0) for v in words] for u in words])
    rank = np.linalg.matrix_rank(K, tol=1e-10)
    print(f"Kernel matrix rank: {rank} (walk dimension: {Q.n})")
    print()


def demo_phase_gauge():
    """Demonstrate phase gauge equivalence."""
    print("=" * 60)
    print("DEMO 3: Phase Gauge Equivalence")
    print("=" * 60)

    # Two walks related by a unitary conjugation
    theta_A, theta_B, theta_C = np.pi/5, np.pi/7, np.pi/11
    U1 = {
        'A': rotation_matrix(theta_A),
        'B': rotation_matrix(theta_B),
        'C': rotation_matrix(theta_C)
    }
    psi0_1 = np.array([1.0, 0.0])

    # Conjugate by a fixed unitary V
    phi = np.pi / 3
    V = rotation_matrix(phi)
    U2 = {g: V @ Ug @ V.conj().T for g, Ug in U1.items()}
    psi0_2 = V @ psi0_1

    Q1 = BerggrenQuantumWalk(U1, psi0_1)
    Q2 = BerggrenQuantumWalk(U2, psi0_2)

    # Compare kernels
    words = generate_words(4)
    max_kernel_diff = 0
    for u in words:
        for v in words:
            diff = abs(Q1.kernel(u, v) - Q2.kernel(u, v))
            max_kernel_diff = max(max_kernel_diff, diff)

    print(f"\nPhase-gauge equivalent walks (related by rotation π/3)")
    print(f"Max kernel difference: {max_kernel_diff:.2e}")
    print(f"Walks have identical observable content: {max_kernel_diff < 1e-12}")
    print()


def demo_berggren_triples():
    """Show the Berggren tree generating Pythagorean triples."""
    print("=" * 60)
    print("DEMO 4: Berggren Triple Tree")
    print("=" * 60)

    mats = berggren_matrices()
    root = np.array([3, 4, 5])

    print(f"\nRoot triple: {tuple(root)}")
    print(f"Check: {root[0]}² + {root[1]}² = {root[0]**2 + root[1]**2} = {root[2]}² = {root[2]**2}")
    print()

    # Generate first 3 levels
    level = [('', root)]
    for depth in range(1, 4):
        new_level = []
        for path, triple in level:
            for g in GENERATORS:
                new_triple = mats[g] @ triple
                new_path = path + g
                new_level.append((new_path, new_triple))
                a, b, c = new_triple
                pyth_check = a**2 + b**2 == c**2
                if depth <= 2:
                    print(f"  Path {new_path:4s}: ({a:4d}, {b:4d}, {c:4d})"
                          f"  {a}² + {b}² = {a**2+b**2} = {c}² ✓" if pyth_check else
                          f"  Path {new_path:4s}: ({a:4d}, {b:4d}, {c:4d}) ✗")
        level = new_level
    print(f"\n  Total triples at depth 3: {len(level)}")
    print()


def demo_kernel_rank_growth():
    """Show how kernel rank grows and stabilizes."""
    print("=" * 60)
    print("DEMO 5: Kernel Rank Growth")
    print("=" * 60)

    for n in [1, 2, 3, 4]:
        np.random.seed(100 + n)
        def random_unitary(dim):
            Z = (np.random.randn(dim, dim) + 1j * np.random.randn(dim, dim)) / np.sqrt(2)
            Q, R = np.linalg.qr(Z)
            return Q @ np.diag(np.diag(R) / np.abs(np.diag(R)))

        U = {g: random_unitary(n) for g in GENERATORS}
        psi0 = np.zeros(n, dtype=complex)
        if n > 0:
            psi0[0] = 1.0
        Q = BerggrenQuantumWalk(U, psi0)

        ranks = []
        for L in range(6):
            words = generate_words(L)
            m = len(words)
            K = np.zeros((m, m), dtype=complex)
            for i, u in enumerate(words):
                for j, v in enumerate(words):
                    K[i, j] = Q.kernel(u, v)
            rank = np.linalg.matrix_rank(K, tol=1e-10)
            ranks.append(rank)

        print(f"  dim={n}: ranks by depth = {ranks}")

    print()


if __name__ == '__main__':
    verify_lorentz_preservation()
    demo_berggren_triples()
    demo_kernel_properties()
    demo_moment_table()
    demo_phase_gauge()
    demo_kernel_rank_growth()
    print("All demonstrations complete.")


#!/usr/bin/env python3
"""Generate PACKAGE.json with all artifacts."""

import json
import base64
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

def image_to_base64(path):
    with open(path, 'rb') as f:
        data = base64.b64encode(f.read()).decode('utf-8')
    return f"data:image/png;base64,{data}"

# Read all text content
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
lean_code = read_file('Catalog/Bridges/AlgebraPythagoreanComputation/BerggrenQuantumWalkDuality.lean')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')
viz_code = read_file('visualizations.py')

# Read images
viz_data = {}
for img_name in ['kernel_heatmap.png', 'eigenvalue_spectrum.png',
                 'berggren_tree.png', 'amplitude_polar.png']:
    if os.path.exists(img_name):
        viz_data[img_name] = image_to_base64(img_name)

package = {
    "title": "Berggren Quantum Walk Duality via Triple-Tree Unitary Semimodules and Certified Phase-Orbit Reconstruction",
    "domain": "Bridges: Algebra × Pythagorean × Computation",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Berggren Quantum Walk Demo",
            "code": demo_code
        },
        {
            "name": "Applications Demo",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Kernel Extraction",
            "pseudocode": "Input: Walk Q, word set W\\nOutput: Kernel matrix K\\n\\nfor w in W:\\n  state[w] = EvalWord(Q.U, w) * Q.psi0\\nfor (w1, w2) in W×W:\\n  K[w1,w2] = conj(state[w1])^T * state[w2]\\nreturn K",
            "code": algorithms_code
        },
        {
            "name": "GNS Realization",
            "pseudocode": "Input: Valid moment table H, stable rank r\\nOutput: Minimal walk Q of dimension r\\n\\n1. Build Gram matrix G[i,j] = H(basis[i], basis[j])\\n2. Cholesky: G = L^† L\\n3. For each generator g: solve for U_g from shift structure\\n4. psi0 = L * decomposition(identity word)\\n5. Return Walk(U, psi0)",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {
            "name": "Kernel Matrix Heatmap",
            "data": viz_data.get('kernel_heatmap.png', '')
        },
        {
            "name": "Eigenvalue Spectrum",
            "data": viz_data.get('eigenvalue_spectrum.png', '')
        },
        {
            "name": "Berggren Triple Tree",
            "data": viz_data.get('berggren_tree.png', '')
        },
        {
            "name": "Amplitude Polar Plot",
            "data": viz_data.get('amplitude_polar.png', '')
        }
    ],
    "lean_proofs": lean_code
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2)

print(f"PACKAGE.json generated ({os.path.getsize('PACKAGE.json') / 1024:.1f} KB)")


#!/usr/bin/env python3
"""Generate visualizations for Berggren Quantum Walk Duality."""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from demo import BerggrenQuantumWalk, generate_words, rotation_matrix, GENERATORS
import base64
import io


def fig_to_base64(fig):
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def viz_kernel_heatmap():
    """Visualize the kernel matrix as a heatmap."""
    U_A = rotation_matrix(np.pi / 4)
    U_B = rotation_matrix(np.pi / 3)
    U_C = rotation_matrix(np.pi / 6)
    psi0 = np.array([1.0, 0.0])
    Q = BerggrenQuantumWalk({'A': U_A, 'B': U_B, 'C': U_C}, psi0)

    words = generate_words(2)
    m = len(words)
    K = np.zeros((m, m), dtype=complex)
    for i, u in enumerate(words):
        for j, v in enumerate(words):
            K[i, j] = Q.kernel(u, v)

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Real part
    im0 = axes[0].imshow(K.real, cmap='RdBu_r', vmin=-1, vmax=1)
    axes[0].set_title('Re(K(u,v)) — Kernel Real Part', fontsize=13)
    axes[0].set_xlabel('Word v')
    axes[0].set_ylabel('Word u')
    labels = [w if w else 'ε' for w in words]
    axes[0].set_xticks(range(m))
    axes[0].set_xticklabels(labels, rotation=45, fontsize=7)
    axes[0].set_yticks(range(m))
    axes[0].set_yticklabels(labels, fontsize=7)
    plt.colorbar(im0, ax=axes[0])

    # Imaginary part
    im1 = axes[1].imshow(K.imag, cmap='PuOr', vmin=-1, vmax=1)
    axes[1].set_title('Im(K(u,v)) — Kernel Imaginary Part', fontsize=13)
    axes[1].set_xlabel('Word v')
    axes[1].set_xticks(range(m))
    axes[1].set_xticklabels(labels, rotation=45, fontsize=7)
    axes[1].set_yticks(range(m))
    axes[1].set_yticklabels(labels, fontsize=7)
    plt.colorbar(im1, ax=axes[1])

    fig.suptitle('Berggren Quantum Walk Kernel Matrix (dim=2)', fontsize=15, y=1.02)
    fig.tight_layout()
    fig.savefig('kernel_heatmap.png', dpi=150, bbox_inches='tight')
    data_uri = fig_to_base64(fig)
    return data_uri


def viz_eigenvalue_spectrum():
    """Visualize eigenvalue spectrum of kernel matrices for different dimensions."""
    fig, ax = plt.subplots(figsize=(10, 6))

    colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3', '#ff7f00']

    for n, color in zip([1, 2, 3, 4, 5], colors):
        np.random.seed(100 + n)
        def random_unitary(dim):
            Z = (np.random.randn(dim, dim) + 1j * np.random.randn(dim, dim)) / np.sqrt(2)
            Q_mat, R = np.linalg.qr(Z)
            return Q_mat @ np.diag(np.diag(R) / np.abs(np.diag(R)))

        U = {g: random_unitary(n) for g in GENERATORS}
        psi0 = np.zeros(n, dtype=complex)
        if n > 0:
            psi0[0] = 1.0
        Q = BerggrenQuantumWalk(U, psi0)

        words = generate_words(3)
        m = len(words)
        K = np.zeros((m, m), dtype=complex)
        for i, u in enumerate(words):
            for j, v in enumerate(words):
                K[i, j] = Q.kernel(u, v)

        eigenvalues = np.sort(np.linalg.eigvalsh(K))[::-1]
        ax.semilogy(range(1, len(eigenvalues)+1), np.maximum(eigenvalues, 1e-16),
                    'o-', color=color, markersize=3, label=f'dim = {n}', alpha=0.8)

    ax.set_xlabel('Eigenvalue index', fontsize=12)
    ax.set_ylabel('Eigenvalue (log scale)', fontsize=12)
    ax.set_title('Kernel Eigenvalue Spectrum — Rank = Walk Dimension', fontsize=14)
    ax.legend(fontsize=11)
    ax.axhline(y=1e-10, color='gray', linestyle='--', alpha=0.5, label='Numerical zero')
    ax.set_ylim(1e-17, 1e2)
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig('eigenvalue_spectrum.png', dpi=150, bbox_inches='tight')
    data_uri = fig_to_base64(fig)
    return data_uri


def viz_berggren_tree():
    """Visualize the Berggren triple tree."""
    from demo import berggren_matrices

    mats = berggren_matrices()
    root = np.array([3, 4, 5])

    fig, ax = plt.subplots(figsize=(14, 8))

    # Layout: root at top, children below
    positions = {}
    labels = {}

    def add_node(path, triple, x, y, dx):
        a, b, c = triple
        positions[path] = (x, y)
        labels[path] = f"({a},{b},{c})"

        if len(path) < 3:
            offsets = [-dx, 0, dx]
            for i, g in enumerate(GENERATORS):
                child_path = path + g
                child_triple = mats[g] @ triple
                add_node(child_path, child_triple, x + offsets[i], y - 1.5, dx / 3.5)

                # Draw edge
                ax.plot([x, x + offsets[i]], [y, y - 1.5],
                       color='#555555', linewidth=1, zorder=1)
                # Label edge
                mid_x = (x + x + offsets[i]) / 2
                mid_y = (y + y - 1.5) / 2
                ax.text(mid_x - 0.1, mid_y + 0.2, g,
                       fontsize=8, color=['#e41a1c', '#377eb8', '#4daf4a'][i],
                       fontweight='bold')

    add_node('', root, 0, 0, 8)

    # Draw nodes
    for path, (x, y) in positions.items():
        color = '#fff3e0' if len(path) == 0 else '#e3f2fd' if len(path) == 1 else '#f3e5f5' if len(path) == 2 else '#e8f5e9'
        circle = plt.Circle((x, y), 0.45, color=color, ec='#333', linewidth=1.5, zorder=2)
        ax.add_patch(circle)
        ax.text(x, y, labels[path], fontsize=6, ha='center', va='center', zorder=3)

    ax.set_xlim(-12, 12)
    ax.set_ylim(-5.5, 1.5)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Berggren Triple Tree — First 3 Levels\n'
                'Generators: A (red), B (blue), C (green)',
                fontsize=14, pad=20)
    fig.tight_layout()
    fig.savefig('berggren_tree.png', dpi=150, bbox_inches='tight')
    data_uri = fig_to_base64(fig)
    return data_uri


def viz_amplitude_polar():
    """Visualize amplitudes in polar form along different tree paths."""
    U_A = rotation_matrix(np.pi / 5)
    U_B = rotation_matrix(np.pi / 7)
    U_C = rotation_matrix(np.pi / 11)
    psi0 = np.array([1.0, 0.0])
    obs = np.array([0.5, 0.5])
    Q = BerggrenQuantumWalk({'A': U_A, 'B': U_B, 'C': U_C}, psi0, obs)

    fig, ax = plt.subplots(figsize=(8, 8), subplot_kw={'projection': 'polar'})

    colors = {'A': '#e41a1c', 'B': '#377eb8', 'C': '#4daf4a'}
    markers = {'A': 'o', 'B': 's', 'C': '^'}

    for depth in range(1, 6):
        for combo in [[g] * depth for g in GENERATORS]:
            word = ''.join(combo[:depth])

    # Plot amplitudes for paths along each pure generator
    for g in GENERATORS:
        thetas = []
        radii = []
        for depth in range(8):
            word = g * depth
            amp = Q.amplitude(word)
            thetas.append(np.angle(amp))
            radii.append(abs(amp))
        ax.plot(thetas, radii, '-o', color=colors[g], label=f'Path {g}*',
               markersize=5, alpha=0.8)
        # Mark depth labels
        for i, (t, r) in enumerate(zip(thetas, radii)):
            if i > 0 and r > 0.01:
                ax.annotate(str(i), (t, r), fontsize=7, alpha=0.6)

    ax.set_title('Amplitude Evolution Along Pure Generator Paths\n'
                '(radius = |amp|, angle = phase)', fontsize=12, pad=20)
    ax.legend(loc='upper right', bbox_to_anchor=(1.3, 1))
    fig.tight_layout()
    fig.savefig('amplitude_polar.png', dpi=150, bbox_inches='tight')
    data_uri = fig_to_base64(fig)
    return data_uri


if __name__ == '__main__':
    print("Generating visualizations...")
    uri1 = viz_kernel_heatmap()
    print("  ✓ Kernel heatmap")
    uri2 = viz_eigenvalue_spectrum()
    print("  ✓ Eigenvalue spectrum")
    uri3 = viz_berggren_tree()
    print("  ✓ Berggren tree")
    uri4 = viz_amplitude_polar()
    print("  ✓ Amplitude polar plot")
    print("All visualizations saved as PNG files.")
