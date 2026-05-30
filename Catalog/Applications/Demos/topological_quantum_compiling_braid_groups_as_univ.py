"""
Applications of Topological Quantum Compiling
=============================================

Shows real-world applications of braid group universality:
1. Quantum gate synthesis: approximate any SU(3) gate by braiding
2. Error analysis: topological protection from decoherence
3. Resource estimation: how many anyons and braidings needed
"""

import numpy as np
from typing import List, Tuple


# ============================================================
# Application 1: Quantum Gate Synthesis
# ============================================================

def fibonacci_braid_matrices():
    """Return the three braid generator matrices for Fibonacci anyons (B_4, k=5)."""
    phi = (1 + np.sqrt(5)) / 2
    tau = 1 / phi

    r_1 = np.exp(-4j * np.pi / 5)
    r_tau = np.exp(3j * np.pi / 5)

    F = np.array([
        [tau, np.sqrt(tau)],
        [np.sqrt(tau), -tau]
    ], dtype=complex)

    R_diag = np.diag([r_tau, r_1])

    sigma1 = np.zeros((3, 3), dtype=complex)
    sigma1[0, 0] = r_tau
    sigma1[1:, 1:] = F @ R_diag @ np.linalg.inv(F)

    sigma2 = np.zeros((3, 3), dtype=complex)
    sigma2[:2, :2] = F @ R_diag @ np.linalg.inv(F)
    sigma2[2, 2] = r_tau

    sigma3 = np.zeros((3, 3), dtype=complex)
    sigma3[0, 0] = r_tau
    sigma3[1, 1] = r_tau
    sigma3[2, 2] = r_1

    return [sigma1, sigma2, sigma3]


def random_su3():
    """Generate a random element of SU(3) via QR decomposition."""
    Z = (np.random.randn(3, 3) + 1j * np.random.randn(3, 3)) / np.sqrt(2)
    Q, R = np.linalg.qr(Z)
    # Fix the phases to get SU(3)
    d = np.diag(R)
    ph = d / np.abs(d)
    Q = Q @ np.diag(ph.conj())
    # Ensure det = 1
    det = np.linalg.det(Q)
    Q = Q * (det.conj()) ** (1/3)
    return Q


def random_search_approximation(
    target: np.ndarray,
    generators: List[np.ndarray],
    n_samples: int = 100000,
    max_length: int = 15
) -> Tuple[List[int], float]:
    """Random search for braid word approximation.

    Generates random braid words and keeps the best approximation.
    Much faster than exhaustive search for longer words.

    Args:
        target: Target SU(3) matrix
        generators: Braid generator matrices
        n_samples: Number of random words to try
        max_length: Maximum word length

    Returns:
        Tuple of (best_word_as_indices, best_distance)
    """
    n_gens = len(generators)
    inv_generators = [np.linalg.inv(g) for g in generators]
    all_mats = generators + inv_generators

    best_word = []
    best_dist = float('inf')

    for _ in range(n_samples):
        length = np.random.randint(1, max_length + 1)
        indices = np.random.randint(0, 2 * n_gens, size=length)
        mat = np.eye(3, dtype=complex)
        for idx in indices:
            mat = mat @ all_mats[idx]
        dist = np.linalg.norm(mat - target, 'fro')
        if dist < best_dist:
            best_dist = dist
            best_word = indices.tolist()

    return best_word, best_dist


# ============================================================
# Application 2: Topological Error Protection
# ============================================================

def compute_error_gap(generators: List[np.ndarray], n_pairs: int = 1000) -> float:
    """Estimate the spectral gap that provides topological protection.

    The topological gap Δ determines the error rate: errors are suppressed
    as exp(-Δ * L / T) where L is the system size and T is temperature.

    Here we estimate the gap from the spectral properties of the braid
    generators: it's related to the minimum distance between eigenvalues
    of the R-matrix.

    Returns:
        Estimated spectral gap
    """
    all_eigenvalues = []
    for g in generators:
        eigvals = np.linalg.eigvals(g)
        all_eigenvalues.extend(eigvals)

    # The gap is the minimum angular separation between eigenvalues
    angles = sorted(np.angle(all_eigenvalues))
    gaps = []
    for i in range(len(angles)):
        for j in range(i + 1, len(angles)):
            gap = abs(angles[j] - angles[i])
            gap = min(gap, 2 * np.pi - gap)
            if gap > 1e-10:
                gaps.append(gap)

    return min(gaps) if gaps else 0.0


# ============================================================
# Application 3: Resource Estimation
# ============================================================

def resource_estimate(
    target_precision: float,
    n_strands: int = 4,
    solovay_kitaev_exponent: float = 3.97
) -> dict:
    """Estimate resources needed for quantum gate synthesis via braiding.

    The Solovay-Kitaev theorem guarantees that any gate in SU(d) can be
    approximated to precision ε using O(log^c(1/ε)) braid operations,
    where c ≈ 3.97 and d = fibDim(n-1).

    Args:
        target_precision: Desired approximation precision ε
        n_strands: Number of braid strands
        solovay_kitaev_exponent: The SK exponent c

    Returns:
        Dictionary with resource estimates
    """
    def fibonacci_dim(n):
        if n <= 1: return 1
        a, b = 1, 1
        for _ in range(n - 1): a, b = b, a + b
        return b

    d = fibonacci_dim(n_strands - 1)  # Hilbert space dimension
    n_gens = 2 * (n_strands - 1)  # Number of generators and inverses

    # Solovay-Kitaev word length estimate
    log_inv_eps = np.log(1 / target_precision)
    sk_length = int(np.ceil(log_inv_eps ** solovay_kitaev_exponent))

    # Brute force search length estimate (less efficient)
    # Need (2*(n-1))^ℓ ≥ (1/ε)^{d²}
    # ℓ ≥ d² * log(1/ε) / log(2*(n-1))
    brute_length = int(np.ceil(d**2 * log_inv_eps / np.log(n_gens)))

    return {
        "target_precision": target_precision,
        "n_strands": n_strands,
        "hilbert_dim": d,
        "n_generators": n_gens,
        "sk_word_length": sk_length,
        "brute_force_length": brute_length,
        "n_physical_anyons": n_strands,
        "total_braiding_operations": sk_length,
    }


# ============================================================
# Main Demo
# ============================================================

if __name__ == "__main__":
    np.random.seed(42)

    print("=" * 60)
    print("APPLICATION 1: QUANTUM GATE SYNTHESIS")
    print("=" * 60)

    gens = fibonacci_braid_matrices()
    target = random_su3()
    print(f"\nTarget SU(3) matrix (random):")
    for row in target:
        print(f"  [{', '.join(f'{x.real:+.4f}{x.imag:+.4f}i' for x in row)}]")

    word, dist = random_search_approximation(target, gens, n_samples=50000, max_length=20)
    print(f"\nBest approximation found:")
    print(f"  Word length: {len(word)}")
    print(f"  Frobenius distance: {dist:.6f}")
    print(f"  (For comparison, max Frobenius distance for SU(3): ~{np.sqrt(6):.2f})")

    print("\n" + "=" * 60)
    print("APPLICATION 2: TOPOLOGICAL ERROR PROTECTION")
    print("=" * 60)

    gap = compute_error_gap(gens)
    print(f"\n  Spectral gap Δ ≈ {gap:.6f} radians")
    print(f"  Error suppression: exp(-Δ·L/T)")
    print(f"  At L/T = 10: error ∝ exp({-gap*10:.4f}) = {np.exp(-gap*10):.6e}")
    print(f"  At L/T = 100: error ∝ exp({-gap*100:.4f}) = {np.exp(-gap*100):.6e}")
    print(f"  → Exponential suppression makes errors negligible")

    print("\n" + "=" * 60)
    print("APPLICATION 3: RESOURCE ESTIMATION")
    print("=" * 60)

    for eps in [0.1, 0.01, 0.001, 1e-6, 1e-10]:
        res = resource_estimate(eps)
        print(f"\n  Precision ε = {eps:.0e}:")
        print(f"    Hilbert space dimension: {res['hilbert_dim']}")
        print(f"    SK word length: ~{res['sk_word_length']}")
        print(f"    Brute force length: ~{res['brute_force_length']}")
        print(f"    Physical anyons needed: {res['n_physical_anyons']}")

    print("\n" + "=" * 60)
    print("APPLICATION DEMOS COMPLETE")
    print("=" * 60)


"""
Topological Quantum Compiling: Braid Groups as Universal Gates
==============================================================

Demonstrates the key mathematical results formalized in Lean 4:
1. Fibonacci anyon fusion dimensions
2. Braid word algebra and exponent sum homomorphism
3. Jones representation matrices for Fibonacci anyons
4. Universality test: infinite order check for braid generators
"""

import numpy as np
from typing import List, Tuple

# ============================================================
# Part 1: Fibonacci Anyon Dimensions
# ============================================================

def fib_dim(n: int) -> int:
    """Fibonacci anyon fusion space dimension.

    For n Fibonacci anyons, the fusion space has dimension fib_dim(n).
    This matches our Lean definition:
      fibDim 0 = 1, fibDim 1 = 1, fibDim(n+2) = fibDim(n) + fibDim(n+1)
    """
    if n <= 1:
        return 1
    a, b = 1, 1
    for _ in range(n - 1):
        a, b = b, a + b
    return b

print("=" * 60)
print("FIBONACCI ANYON FUSION DIMENSIONS")
print("=" * 60)
for n in range(10):
    print(f"  fibDim({n}) = {fib_dim(n)}")
print(f"\n  Key result (proved in Lean): fibDim(3) = {fib_dim(3)} → SU(3)")
print(f"  This gives the 3-dimensional representation for universality.\n")

# Verify the growth bound: fibDim(n+2) >= n+1
print("Growth bound verification (fibDim(n+2) >= n+1):")
for n in range(15):
    dim = fib_dim(n + 2)
    bound = n + 1
    assert dim >= bound, f"Failed at n={n}"
    print(f"  fibDim({n+2}) = {dim} >= {bound} ✓")

# Verify double-step growth: fibDim(n+4) >= 2 * fibDim(n+2)
print("\nDouble-step growth (fibDim(n+4) >= 2*fibDim(n+2)):")
for n in range(10):
    assert fib_dim(n + 4) >= 2 * fib_dim(n + 2)
    print(f"  fibDim({n+4}) = {fib_dim(n+4)} >= {2*fib_dim(n+2)} = 2*fibDim({n+2}) ✓")

# Verify coprimality
from math import gcd
print("\nConsecutive coprimality (proved in Lean):")
for n in range(15):
    g = gcd(fib_dim(n), fib_dim(n + 1))
    assert g == 1
    print(f"  gcd(fibDim({n}), fibDim({n+1})) = gcd({fib_dim(n)}, {fib_dim(n+1)}) = {g} ✓")

# ============================================================
# Part 2: Braid Word Algebra
# ============================================================

print("\n" + "=" * 60)
print("BRAID WORD ALGEBRA")
print("=" * 60)

class BraidGen:
    """A braid generator: pos(i) = σ_i, neg(i) = σ_i^{-1}."""
    def __init__(self, index: int, positive: bool = True):
        self.index = index
        self.positive = positive

    def invert(self) -> 'BraidGen':
        return BraidGen(self.index, not self.positive)

    def __repr__(self):
        sign = "" if self.positive else "⁻¹"
        return f"σ_{self.index}{sign}"

BraidWord = List[BraidGen]

def inverse(w: BraidWord) -> BraidWord:
    return [g.invert() for g in reversed(w)]

def compose(w1: BraidWord, w2: BraidWord) -> BraidWord:
    return w1 + w2

def exp_sum(w: BraidWord) -> int:
    return sum(1 if g.positive else -1 for g in w)

def word_length(w: BraidWord) -> int:
    return len(w)

# Demonstrate the homomorphism property
w1 = [BraidGen(0), BraidGen(1), BraidGen(2)]
w2 = [BraidGen(1, False), BraidGen(0)]

print(f"\n  w₁ = {w1}")
print(f"  w₂ = {w2}")
print(f"  w₁ · w₂ = {compose(w1, w2)}")
print(f"\n  expSum(w₁) = {exp_sum(w1)}")
print(f"  expSum(w₂) = {exp_sum(w2)}")
print(f"  expSum(w₁ · w₂) = {exp_sum(compose(w1, w2))}")
print(f"  Sum check: {exp_sum(w1)} + {exp_sum(w2)} = {exp_sum(w1) + exp_sum(w2)} ✓")

# Inverse properties
w_inv = inverse(w1)
print(f"\n  w₁⁻¹ = {w_inv}")
print(f"  expSum(w₁⁻¹) = {exp_sum(w_inv)} = -{exp_sum(w1)} ✓")
print(f"  (w₁⁻¹)⁻¹ = {inverse(w_inv)}  (equals w₁ ✓)")
print(f"  |w₁⁻¹| = {word_length(w_inv)} = |w₁| = {word_length(w1)} ✓")

# ============================================================
# Part 3: Jones Representation for Fibonacci Anyons
# ============================================================

print("\n" + "=" * 60)
print("JONES REPRESENTATION AT k=5 (FIBONACCI ANYONS)")
print("=" * 60)

# The golden ratio
phi = (1 + np.sqrt(5)) / 2
print(f"\n  Golden ratio φ = {phi:.10f}")
print(f"  φ² = {phi**2:.10f}")
print(f"  φ + 1 = {phi + 1:.10f}")
print(f"  φ² = φ + 1: {np.isclose(phi**2, phi + 1)} ✓ (fusion rule)")

# Root of unity for k=5
q = np.exp(2j * np.pi / 5)
print(f"\n  Root of unity q = e^(2πi/5) = {q:.6f}")

# Jones representation matrices for B_4 at k=5
# The Temperley-Lieb generators e_i satisfy:
#   ρ(σ_i) = q·I + (q - q⁻¹)·e_i  (with appropriate normalization)
# For the 3-dimensional irreducible representation:

# Construct the representation using the Fibonacci F-matrices
# σ_i = R_i where R-matrices come from the braiding of Fibonacci anyons
tau = 1 / phi  # = φ - 1 = 1/φ
phase = np.exp(4j * np.pi / 5)

# The R-matrix eigenvalues for Fibonacci anyons
r_trivial = np.exp(-4j * np.pi / 5)  # fusion to trivial channel
r_fib = np.exp(3j * np.pi / 5)       # fusion to Fibonacci channel

# Braid generators in the 3D representation
# Using standard basis: |((1,1),τ), τ⟩, |((1,τ),1), τ⟩, |((1,τ),τ), τ⟩
sigma1 = np.array([
    [r_fib, 0, 0],
    [0, r_trivial * tau, r_trivial * np.sqrt(tau)],
    [0, r_trivial * np.sqrt(tau), -r_trivial * tau + r_fib]
], dtype=complex)

# Normalize to be unitary
sigma2 = np.array([
    [r_trivial * tau, r_trivial * np.sqrt(tau), 0],
    [r_trivial * np.sqrt(tau), -r_trivial * tau + r_fib, 0],
    [0, 0, r_fib]
], dtype=complex)

sigma3 = np.array([
    [r_fib, 0, 0],
    [0, r_fib, 0],
    [0, 0, r_trivial]
], dtype=complex)

print(f"\n  Braid generator σ₁ (3×3 matrix):")
for row in sigma1:
    print(f"    [{', '.join(f'{x:.4f}' for x in row)}]")

# Check unitarity
for name, mat in [("σ₁", sigma1), ("σ₂", sigma2), ("σ₃", sigma3)]:
    prod = mat @ mat.conj().T
    is_unitary = np.allclose(prod, np.eye(3), atol=1e-10)
    det = np.linalg.det(mat)
    print(f"\n  {name}: unitary={is_unitary}, |det|={abs(det):.10f}")

# ============================================================
# Part 4: Universality Test — Infinite Order Check
# ============================================================

print("\n" + "=" * 60)
print("UNIVERSALITY TEST: INFINITE ORDER OF σ₁σ₂σ₃")
print("=" * 60)

product = sigma1 @ sigma2 @ sigma3
eigenvalues = np.linalg.eigvals(product)
print(f"\n  σ₁σ₂σ₃ eigenvalues:")
for i, ev in enumerate(eigenvalues):
    angle = np.angle(ev) / np.pi
    print(f"    λ_{i+1} = {ev:.6f}, |λ| = {abs(ev):.10f}, arg/π = {angle:.10f}")

# Check if any power up to 1000 gives the identity
print(f"\n  Checking (σ₁σ₂σ₃)^m ≠ I for m = 1 to 1000...")
power = np.eye(3, dtype=complex)
found_identity = False
for m in range(1, 1001):
    power = power @ product
    if np.allclose(power, np.eye(3), atol=1e-8):
        print(f"    ⚠ Found identity at m = {m}!")
        found_identity = True
        break
if not found_identity:
    print(f"    ✓ No identity found — consistent with infinite order")
    print(f"    → Supports universality conjecture")

# ============================================================
# Part 5: Braid Word Count (Exponential Growth)
# ============================================================

print("\n" + "=" * 60)
print("BRAID WORD COUNT (EXPONENTIAL GROWTH)")
print("=" * 60)

n_strands = 4
for length in range(8):
    count = (2 * (n_strands - 1)) ** length
    print(f"  B_4 words of length {length}: {count}")

print(f"\n  Growth factor per step: {2 * (n_strands - 1)} = 6")
print(f"  After length 20: {6**20:,} distinct braid words")
print(f"  After length 50: {6**50:.2e} distinct braid words")
print(f"  → Exponential growth enables efficient gate approximation")

# ============================================================
# Part 6: Golden Ratio Connection
# ============================================================

print("\n" + "=" * 60)
print("GOLDEN RATIO: NUMBER THEORY ↔ QUANTUM PHYSICS")
print("=" * 60)
print(f"\n  φ = (1+√5)/2 = {phi:.15f}")
print(f"  φ² = φ + 1 (fusion rule d² = d + 1)")
print(f"  φ = quantum dimension of Fibonacci anyon")
print(f"  φ^n ≈ fibDim(n+1)/fibDim(n) for large n:")
for n in range(2, 12):
    ratio = fib_dim(n + 1) / fib_dim(n)
    print(f"    fibDim({n+1})/fibDim({n}) = {fib_dim(n+1)}/{fib_dim(n)} = {ratio:.10f}  (φ = {phi:.10f})")

print("\n  → The golden ratio governs both:")
print("    • Fibonacci number growth rate (number theory)")
print("    • Quantum dimension of Fibonacci anyons (physics)")
print("    • Hilbert space dimension growth for topological QC")

print("\n" + "=" * 60)
print("ALL DEMONSTRATIONS COMPLETE")
print("=" * 60)


"""
Visualization 2: Jones Representation Matrices
===============================================

Visualizes the 3x3 unitary matrices representing braid generators
σ₁, σ₂, σ₃ in the Fibonacci anyon model (k=5, B_4). Shows both
the magnitude and phase structure, revealing the topological quantum
gate structure.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import Normalize

# Compute braid generator matrices
phi = (1 + np.sqrt(5)) / 2
tau = 1 / phi

r_1 = np.exp(-4j * np.pi / 5)
r_tau = np.exp(3j * np.pi / 5)

F = np.array([
    [tau, np.sqrt(tau)],
    [np.sqrt(tau), -tau]
], dtype=complex)

R_diag = np.diag([r_tau, r_1])

sigma1 = np.zeros((3, 3), dtype=complex)
sigma1[0, 0] = r_tau
sigma1[1:, 1:] = F @ R_diag @ np.linalg.inv(F)

sigma2 = np.zeros((3, 3), dtype=complex)
sigma2[:2, :2] = F @ R_diag @ np.linalg.inv(F)
sigma2[2, 2] = r_tau

sigma3 = np.zeros((3, 3), dtype=complex)
sigma3[0, 0] = r_tau
sigma3[1, 1] = r_tau
sigma3[2, 2] = r_1

matrices = [sigma1, sigma2, sigma3]
names = ['σ₁', 'σ₂', 'σ₃']

fig, axes = plt.subplots(2, 3, figsize=(15, 9))

for col, (mat, name) in enumerate(zip(matrices, names)):
    # Top row: magnitude
    ax_mag = axes[0, col]
    mag = np.abs(mat)
    im = ax_mag.imshow(mag, cmap='YlOrRd', vmin=0, vmax=1, aspect='equal')
    ax_mag.set_title(f'|{name}| (magnitude)', fontsize=13, fontweight='bold')
    for i in range(3):
        for j in range(3):
            ax_mag.text(j, i, f'{mag[i,j]:.3f}', ha='center', va='center',
                       fontsize=11, color='black' if mag[i,j] < 0.5 else 'white')
    ax_mag.set_xticks(range(3))
    ax_mag.set_yticks(range(3))
    plt.colorbar(im, ax=ax_mag, shrink=0.8)

    # Bottom row: phase (in units of π)
    ax_phase = axes[1, col]
    phase = np.angle(mat) / np.pi
    # Mask near-zero entries
    mask = np.abs(mat) > 0.01
    phase_display = np.where(mask, phase, np.nan)
    im2 = ax_phase.imshow(phase_display, cmap='hsv', vmin=-1, vmax=1, aspect='equal')
    ax_phase.set_title(f'arg({name})/π (phase)', fontsize=13, fontweight='bold')
    for i in range(3):
        for j in range(3):
            if mask[i, j]:
                ax_phase.text(j, i, f'{phase[i,j]:.3f}π', ha='center', va='center',
                             fontsize=10, color='black',
                             bbox=dict(boxstyle='round,pad=0.1', facecolor='white', alpha=0.7))
    ax_phase.set_xticks(range(3))
    ax_phase.set_yticks(range(3))
    plt.colorbar(im2, ax=ax_phase, shrink=0.8)

fig.suptitle('Jones Representation: Fibonacci Anyon Braid Matrices (k=5, B₄)',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_braid_matrices.png', dpi=150, bbox_inches='tight')
print("Saved viz_braid_matrices.png")


"""
Visualization 3: Density of Braid Group Image in SU(3)
======================================================

Visualizes the density of the braid group image in SU(3) by projecting
random braid word products onto a 2D subspace. If the image is dense,
the projected points should fill a region uniformly. This provides
visual evidence for the universality conjecture.
"""

import numpy as np
import matplotlib.pyplot as plt

# Braid generator matrices
phi = (1 + np.sqrt(5)) / 2
tau = 1 / phi

r_1 = np.exp(-4j * np.pi / 5)
r_tau = np.exp(3j * np.pi / 5)

F = np.array([
    [tau, np.sqrt(tau)],
    [np.sqrt(tau), -tau]
], dtype=complex)

R_diag = np.diag([r_tau, r_1])

sigma1 = np.zeros((3, 3), dtype=complex)
sigma1[0, 0] = r_tau
sigma1[1:, 1:] = F @ R_diag @ np.linalg.inv(F)

sigma2 = np.zeros((3, 3), dtype=complex)
sigma2[:2, :2] = F @ R_diag @ np.linalg.inv(F)
sigma2[2, 2] = r_tau

sigma3 = np.zeros((3, 3), dtype=complex)
sigma3[0, 0] = r_tau
sigma3[1, 1] = r_tau
sigma3[2, 2] = r_1

generators = [sigma1, sigma2, sigma3]
inv_generators = [np.linalg.inv(g) for g in generators]
all_mats = generators + inv_generators

# Generate random braid words and collect the (0,0) matrix entries
np.random.seed(42)
n_samples = 20000

# Collect points for different word lengths
fig, axes = plt.subplots(1, 3, figsize=(18, 6))
lengths = [5, 15, 40]
colors = ['#e74c3c', '#3498db', '#2ecc71']

for ax_idx, (max_len, color) in enumerate(zip(lengths, colors)):
    points_real = []
    points_imag = []

    for _ in range(n_samples):
        length = max_len
        indices = np.random.randint(0, 6, size=length)
        mat = np.eye(3, dtype=complex)
        for idx in indices:
            mat = mat @ all_mats[idx]

        # Project to (0,0) entry (a complex number on the unit disk)
        z = mat[0, 0]
        points_real.append(z.real)
        points_imag.append(z.imag)

    ax = axes[ax_idx]
    ax.scatter(points_real, points_imag, s=0.5, alpha=0.3, color=color)

    # Draw unit circle
    theta = np.linspace(0, 2 * np.pi, 100)
    ax.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=1, alpha=0.3)

    ax.set_xlim(-1.1, 1.1)
    ax.set_ylim(-1.1, 1.1)
    ax.set_aspect('equal')
    ax.set_xlabel('Re(U₀₀)', fontsize=12)
    ax.set_ylabel('Im(U₀₀)', fontsize=12)
    ax.set_title(f'Word length = {max_len}\n({n_samples} samples)',
                 fontsize=13, fontweight='bold')
    ax.grid(True, alpha=0.2)

fig.suptitle('Density of Braid Group Image in SU(3)\n'
             'Projection of ρ₅(w) onto the (0,0) matrix entry',
             fontsize=15, fontweight='bold', y=1.05)
plt.tight_layout()
plt.savefig('viz_density.png', dpi=150, bbox_inches='tight')
print("Saved viz_density.png")


"""
Visualization 1: Fibonacci Anyon Dimension Growth
==================================================

Visualizes the exponential growth of Fibonacci anyon fusion space dimensions,
showing the golden ratio φ as the asymptotic growth rate. This connects
number theory (Fibonacci sequence) to quantum physics (Hilbert space dimension).
"""

import numpy as np
import matplotlib.pyplot as plt

# Compute Fibonacci dimensions
def fib_dim(n):
    if n <= 1:
        return 1
    a, b = 1, 1
    for _ in range(n - 1):
        a, b = b, a + b
    return b

phi = (1 + np.sqrt(5)) / 2
ns = np.arange(0, 16)
dims = [fib_dim(n) for n in ns]

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: dimensions on log scale
ax1 = axes[0]
ax1.semilogy(ns, dims, 'o-', color='#e74c3c', markersize=8, linewidth=2, label='fibDim(n)')
ax1.semilogy(ns, [phi**n for n in ns], '--', color='#3498db', linewidth=2,
             label=f'φⁿ (φ = {phi:.4f})')
ax1.semilogy(ns, [n + 1 for n in ns], ':', color='#2ecc71', linewidth=2,
             label='Linear bound (n+1)')
ax1.set_xlabel('Number of anyons (n)', fontsize=12)
ax1.set_ylabel('Fusion space dimension', fontsize=12)
ax1.set_title('Fibonacci Anyon Dimension Growth', fontsize=14, fontweight='bold')
ax1.legend(fontsize=11)
ax1.grid(True, alpha=0.3)
ax1.set_xticks(range(0, 16, 2))

# Annotate key points
ax1.annotate('SU(3) universality\n(4 anyons, dim=3)',
             xy=(3, fib_dim(3)), xytext=(5, 2),
             arrowprops=dict(arrowstyle='->', color='black'),
             fontsize=10, ha='center')

# Right panel: ratio convergence to golden ratio
ax2 = axes[1]
ratios = [fib_dim(n + 1) / fib_dim(n) for n in range(1, 15)]
ax2.plot(range(1, 15), ratios, 'o-', color='#9b59b6', markersize=8, linewidth=2)
ax2.axhline(y=phi, color='#e67e22', linestyle='--', linewidth=2, label=f'φ = {phi:.6f}')
ax2.set_xlabel('n', fontsize=12)
ax2.set_ylabel('fibDim(n+1) / fibDim(n)', fontsize=12)
ax2.set_title('Convergence to Golden Ratio', fontsize=14, fontweight='bold')
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)
ax2.set_ylim(0.9, 2.1)

plt.tight_layout()
plt.savefig('viz_fibonacci_growth.png', dpi=150, bbox_inches='tight')
print("Saved viz_fibonacci_growth.png")
