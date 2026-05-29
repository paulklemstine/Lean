#!/usr/bin/env python3
"""
applications.py — Real-World Applications of Knotted Light Theory

Demonstrates practical applications of the OAM-Alexander polynomial
connection in optical communications, quantum computing, and
materials science.
"""
import numpy as np
from typing import List, Dict, Tuple


# ============================================================
# Application 1: Knot-Based Optical Encoding
# ============================================================

class KnotEncoder:
    """
    Encodes information in knotted light beams using OAM modes.

    Each knot type produces a distinct OAM spectrum, enabling
    multiplexed optical communication channels.

    The encoding works because different knots have different
    Alexander polynomials, and hence different OAM spectra.
    """

    KNOT_ALPHABET = {
        'A': ('unknot', [1]),
        'B': ('trefoil', [1, -1, 1]),
        'C': ('figure_eight', [-1, 3, -1]),
        'D': ('cinquefoil', [1, -1, 1, -1, 1]),
        'E': ('three_twist', [1, -3, 5, -3, 1]),
    }

    def encode(self, message: str) -> List[List[int]]:
        """
        Encode a message as a sequence of Alexander polynomial coefficients.

        Each character maps to a knot type, which maps to an OAM spectrum.

        Parameters
        ----------
        message : str
            Message to encode (characters A-E)

        Returns
        -------
        List[List[int]]
            Sequence of coefficient lists
        """
        encoded = []
        for char in message.upper():
            if char in self.KNOT_ALPHABET:
                _, coeffs = self.KNOT_ALPHABET[char]
                encoded.append(coeffs)
        return encoded

    def decode(self, spectra: List[List[int]]) -> str:
        """Decode a sequence of OAM spectra back to a message."""
        reverse_map = {tuple(v[1]): k for k, v in self.KNOT_ALPHABET.items()}
        message = ""
        for spectrum in spectra:
            key = tuple(spectrum)
            if key in reverse_map:
                message += reverse_map[key]
            else:
                message += "?"
        return message

    def channel_capacity(self) -> int:
        """
        Number of distinct channels = number of distinct knot types.

        Each knot type creates an orthogonal OAM channel because
        different Alexander polynomials have different root sets.
        """
        return len(self.KNOT_ALPHABET)


# ============================================================
# Application 2: Knot Detection via OAM Measurement
# ============================================================

class KnotDetector:
    """
    Identifies a knot type from its measured OAM spectrum.

    In practice, a knotted light beam's OAM spectrum can be measured
    using a spatial light modulator (SLM) and a CCD camera. The
    measured spectrum is then matched to known Alexander polynomials.
    """

    def __init__(self):
        self.known_knots = {
            'unknot': np.array([1]),
            'trefoil': np.array([1, -1, 1]),
            'figure_eight': np.array([-1, 3, -1]),
            'cinquefoil': np.array([1, -1, 1, -1, 1]),
        }

    def identify(self, measured_coeffs: np.ndarray, noise_level: float = 0.1) -> Tuple[str, float]:
        """
        Identify a knot from noisy OAM measurements.

        Parameters
        ----------
        measured_coeffs : np.ndarray
            Measured spectral weights (potentially noisy)
        noise_level : float
            Expected noise standard deviation

        Returns
        -------
        Tuple[str, float]
            (knot_name, confidence_score)
        """
        best_match = "unknown"
        best_score = float('inf')

        for name, true_coeffs in self.known_knots.items():
            # Pad to same length
            max_len = max(len(measured_coeffs), len(true_coeffs))
            m = np.zeros(max_len)
            t = np.zeros(max_len)
            m[:len(measured_coeffs)] = measured_coeffs
            t[:len(true_coeffs)] = true_coeffs

            # L2 distance
            score = np.linalg.norm(m - t)
            if score < best_score:
                best_score = score
                best_match = name

        confidence = max(0, 1 - best_score / noise_level) if noise_level > 0 else (1.0 if best_score < 1e-10 else 0.0)
        return best_match, confidence

    def simulate_measurement(self, knot: str, noise_std: float = 0.05) -> np.ndarray:
        """Simulate a noisy OAM measurement."""
        true_coeffs = self.known_knots[knot].astype(float)
        noise = np.random.normal(0, noise_std, size=true_coeffs.shape)
        return true_coeffs + noise


# ============================================================
# Application 3: Topological Quantum Error Detection
# ============================================================

class TopologicalErrorDetector:
    """
    Uses Alexander polynomial invariance for error detection.

    If a knotted light beam is perturbed but its topology is preserved,
    the Alexander polynomial (and hence OAM spectrum) should be
    invariant. Deviations indicate topological errors (knot changes).

    This is analogous to topological quantum error correction,
    where logical qubits are encoded in the topology of the system.
    """

    def __init__(self, knot_coeffs: List[int]):
        self.expected = np.array(knot_coeffs, dtype=float)

    def check_integrity(self, measured: np.ndarray, threshold: float = 0.5) -> Dict:
        """
        Check if the measured OAM spectrum matches the expected one.

        Returns
        -------
        Dict with keys:
            'intact': bool — whether topology is preserved
            'error_magnitude': float — L2 deviation
            'error_location': int — index of largest deviation
        """
        max_len = max(len(self.expected), len(measured))
        e = np.zeros(max_len)
        m = np.zeros(max_len)
        e[:len(self.expected)] = self.expected
        m[:len(measured)] = measured

        diff = np.abs(e - m)
        error_mag = np.linalg.norm(diff)

        return {
            'intact': error_mag < threshold,
            'error_magnitude': error_mag,
            'error_location': int(np.argmax(diff)),
            'normalization_check': abs(sum(measured) - 1.0) < 0.1,
        }


# ============================================================
# DEMONSTRATION
# ============================================================

if __name__ == '__main__':
    print("=" * 60)
    print("KNOTTED LIGHT — Real-World Applications")
    print("=" * 60)

    # Application 1: Optical encoding
    print("\n--- Application 1: Knot-Based Optical Encoding ---")
    encoder = KnotEncoder()
    message = "ABCDE"
    encoded = encoder.encode(message)
    decoded = encoder.decode(encoded)
    print(f"  Original:  {message}")
    print(f"  Encoded:   {encoded}")
    print(f"  Decoded:   {decoded}")
    print(f"  Channels:  {encoder.channel_capacity()}")
    print(f"  Correct:   {message == decoded}")

    # Application 2: Knot detection
    print("\n--- Application 2: Knot Detection from OAM ---")
    detector = KnotDetector()
    np.random.seed(42)
    for knot in ['unknot', 'trefoil', 'figure_eight', 'cinquefoil']:
        measurement = detector.simulate_measurement(knot, noise_std=0.05)
        identified, confidence = detector.identify(measurement)
        correct = "✓" if identified == knot else "✗"
        print(f"  True: {knot:15s} → Detected: {identified:15s} "
              f"(confidence: {confidence:.2f}) {correct}")

    # Application 3: Error detection
    print("\n--- Application 3: Topological Error Detection ---")
    error_detector = TopologicalErrorDetector([1, -1, 1])  # Trefoil

    # Normal measurement (small noise)
    normal = np.array([1.02, -0.98, 1.01])
    result = error_detector.check_integrity(normal)
    print(f"  Normal:    intact={result['intact']}, error={result['error_magnitude']:.4f}")

    # Corrupted measurement (topology changed)
    corrupted = np.array([1.0, 0.0, 1.0])  # Missing the -1 coefficient
    result = error_detector.check_integrity(corrupted)
    print(f"  Corrupted: intact={result['intact']}, error={result['error_magnitude']:.4f}, "
          f"at index {result['error_location']}")

    # Severely corrupted
    severe = np.array([-1.0, 3.0, -1.0])  # Changed to figure-eight!
    result = error_detector.check_integrity(severe)
    print(f"  Topology changed: intact={result['intact']}, error={result['error_magnitude']:.4f}")

    print("\n" + "=" * 60)
    print("All application demonstrations complete.")


#!/usr/bin/env python3
"""
demo.py — Knotted Light: Alexander Polynomials and OAM Spectra

Demonstrates the mathematical connection between knot invariants
(Alexander polynomials) and the orbital angular momentum (OAM)
spectra of knotted light beams.
"""
import numpy as np
from typing import List, Tuple, Dict


def alexander_poly_eval(knot: str, t: complex) -> complex:
    """
    Evaluate the Alexander polynomial Δ_K(t) for a given knot.

    Parameters
    ----------
    knot : str
        One of 'unknot', 'trefoil', 'figure_eight', 'cinquefoil'
    t : complex
        Point at which to evaluate

    Returns
    -------
    complex
        Δ_K(t)
    """
    if knot == 'unknot':
        return complex(1, 0)
    elif knot == 'trefoil':
        return t**2 - t + 1
    elif knot == 'figure_eight':
        return -t**2 + 3*t - 1
    elif knot == 'cinquefoil':
        return t**4 - t**3 + t**2 - t + 1
    else:
        raise ValueError(f"Unknown knot: {knot}")


def alexander_coefficients(knot: str) -> List[int]:
    """Return the coefficient list [a_0, a_1, ...] of the Alexander polynomial."""
    coeffs = {
        'unknot': [1],
        'trefoil': [1, -1, 1],
        'figure_eight': [-1, 3, -1],
        'cinquefoil': [1, -1, 1, -1, 1],
    }
    return coeffs[knot]


def oam_spectrum_unit_circle(knot: str, N: int = 360) -> List[float]:
    """
    Find OAM modes by scanning for roots of Δ_K on the unit circle.

    Parameters
    ----------
    knot : str
        Knot name
    N : int
        Number of points to scan on the circle

    Returns
    -------
    List[float]
        Angles θ (in units of 2π) where |Δ_K(e^{2πiθ})| ≈ 0
    """
    roots = []
    for k in range(N):
        theta = k / N
        t = np.exp(2j * np.pi * theta)
        val = alexander_poly_eval(knot, t)
        if abs(val) < 1e-6:
            roots.append(theta)
    return roots


def oam_spectrum_real_roots(knot: str) -> List[float]:
    """
    Find real roots of the Alexander polynomial.

    Returns
    -------
    List[float]
        Real values x where Δ_K(x) = 0
    """
    coeffs = alexander_coefficients(knot)
    # numpy expects highest degree first
    roots = np.roots(coeffs[::-1])
    real_roots = [r.real for r in roots if abs(r.imag) < 1e-10]
    return sorted(real_roots)


def spectral_weights(knot: str) -> Dict[int, int]:
    """
    Return the Fourier spectral weights: coefficient k → a_k.
    Total weight = Δ_K(1) = sum of coefficients = 1 (normalization).
    """
    coeffs = alexander_coefficients(knot)
    return {k: c for k, c in enumerate(coeffs)}


def connected_sum_spectrum(knot1: str, knot2: str) -> List[float]:
    """
    Compute the real OAM spectrum of the connected sum K1 # K2.
    Δ_{K1 # K2} = Δ_{K1} · Δ_{K2}, so roots are the union.
    """
    roots1 = oam_spectrum_real_roots(knot1)
    roots2 = oam_spectrum_real_roots(knot2)
    return sorted(set(roots1 + roots2))


def verify_normalization(knot: str) -> bool:
    """Verify that Δ_K(1) = 1 (Alexander polynomial normalization)."""
    val = alexander_poly_eval(knot, 1.0)
    return abs(val - 1.0) < 1e-10


def discriminant(knot: str) -> float:
    """
    Compute the discriminant of the Alexander polynomial (for degree 2).
    Δ = at² + bt + c → disc = b² - 4ac
    """
    coeffs = alexander_coefficients(knot)
    if len(coeffs) != 3:
        raise ValueError("Discriminant only for degree-2 polynomials")
    c, b, a = coeffs
    return b**2 - 4*a*c


# ============================================================
# DEMONSTRATION
# ============================================================
if __name__ == '__main__':
    print("=" * 60)
    print("KNOTTED LIGHT: Alexander Polynomials & OAM Spectra")
    print("=" * 60)

    knots = ['unknot', 'trefoil', 'figure_eight', 'cinquefoil']

    # 1. Normalization verification
    print("\n1. Alexander Polynomial Normalization (Δ_K(1) = 1)")
    print("-" * 50)
    for knot in knots:
        val = alexander_poly_eval(knot, 1.0)
        check = "✓" if verify_normalization(knot) else "✗"
        print(f"  {knot:15s}: Δ(1) = {val.real:+.0f}  {check}")

    # 2. Spectral weights (Fourier coefficients)
    print("\n2. Spectral Weights (Fourier Mode Amplitudes)")
    print("-" * 50)
    for knot in knots:
        weights = spectral_weights(knot)
        total = sum(weights.values())
        print(f"  {knot:15s}: {weights}  (total = {total})")

    # 3. Real roots
    print("\n3. Real OAM Spectrum (Real Roots of Δ_K)")
    print("-" * 50)
    for knot in knots:
        roots = oam_spectrum_real_roots(knot)
        if roots:
            roots_str = ", ".join(f"{r:.6f}" for r in roots)
            print(f"  {knot:15s}: {roots_str}")
        else:
            print(f"  {knot:15s}: ∅ (no real roots)")

    # 4. Unit circle roots (OAM modes)
    print("\n4. OAM Modes on Unit Circle (Roots of Δ_K(e^{2πiθ}))")
    print("-" * 50)
    for knot in knots:
        modes = oam_spectrum_unit_circle(knot, N=3600)
        if modes:
            modes_str = ", ".join(f"{m:.4f}" for m in modes)
            print(f"  {knot:15s}: θ = {modes_str}")
        else:
            print(f"  {knot:15s}: ∅ (no unit circle roots)")

    # 5. Discriminant analysis (degree 2 polynomials)
    print("\n5. Discriminant Analysis (Degree 2)")
    print("-" * 50)
    for knot in ['trefoil', 'figure_eight']:
        d = discriminant(knot)
        nature = "complex roots" if d < 0 else "real roots"
        print(f"  {knot:15s}: disc = {d:+.0f} → {nature}")

    # 6. Connected sum demonstration
    print("\n6. Connected Sum: Trefoil # Figure-Eight")
    print("-" * 50)
    sum_roots = connected_sum_spectrum('trefoil', 'figure_eight')
    print(f"  Combined real spectrum: {[f'{r:.6f}' for r in sum_roots]}")
    print(f"  = union of trefoil roots (∅) and figure-eight roots")

    # 7. Cyclotomic verification
    print("\n7. Cyclotomic Structure Verification")
    print("-" * 50)
    print("  Trefoil Δ = t² - t + 1 = Φ₆ (6th cyclotomic polynomial)")
    # Verify: roots should be primitive 6th roots of unity
    for k in [1, 5]:
        t = np.exp(2j * np.pi * k / 6)
        val = alexander_poly_eval('trefoil', t)
        print(f"    Δ(e^{{2πi·{k}/6}}) = {abs(val):.2e}")

    print("\n  Cinquefoil Δ = t⁴ - t³ + t² - t + 1 = Φ₁₀")
    for k in [1, 3, 7, 9]:
        t = np.exp(2j * np.pi * k / 10)
        val = alexander_poly_eval('cinquefoil', t)
        print(f"    Δ(e^{{2πi·{k}/10}}) = {abs(val):.2e}")

    print("\n" + "=" * 60)
    print("All demonstrations complete.")


#!/usr/bin/env python3
"""
Visualization 2: Alexander Polynomial Roots in the Complex Plane

Shows the roots of Alexander polynomials for different knots,
plotted in the complex plane with the unit circle for reference.
Roots ON the unit circle correspond to OAM modes of knotted light.
The trefoil's roots are primitive 6th roots of unity (on the circle),
while the figure-eight's roots are real (off the circle).
"""
import numpy as np
import matplotlib.pyplot as plt


def find_roots(coeffs):
    """Find roots of polynomial given as [a_0, a_1, ..., a_d]."""
    if len(coeffs) <= 1:
        return np.array([])
    # numpy.roots expects highest-degree-first
    return np.roots(coeffs[::-1])


knots = {
    'Trefoil (3₁)': {
        'coeffs': [1, -1, 1],
        'color': '#E91E63',
        'marker': 'o',
    },
    'Figure-Eight (4₁)': {
        'coeffs': [-1, 3, -1],
        'color': '#FF9800',
        'marker': 's',
    },
    'Cinquefoil (5₁)': {
        'coeffs': [1, -1, 1, -1, 1],
        'color': '#4CAF50',
        'marker': '^',
    },
    'Three-Twist (5₂)': {
        'coeffs': [1, -3, 5, -3, 1],
        'color': '#9C27B0',
        'marker': 'D',
    },
}

fig, ax = plt.subplots(1, 1, figsize=(10, 10))

# Draw unit circle
theta = np.linspace(0, 2*np.pi, 200)
ax.plot(np.cos(theta), np.sin(theta), 'k--', alpha=0.3, linewidth=1.5,
        label='Unit circle')
ax.axhline(y=0, color='gray', linewidth=0.5, alpha=0.3)
ax.axvline(x=0, color='gray', linewidth=0.5, alpha=0.3)

for name, info in knots.items():
    roots = find_roots(info['coeffs'])
    ax.scatter(roots.real, roots.imag, c=info['color'], marker=info['marker'],
              s=150, zorder=5, label=name, edgecolors='black', linewidth=1)

    # Annotate with distance from unit circle
    for r in roots:
        dist = abs(abs(r) - 1)
        on_circle = "ON" if dist < 0.01 else f"off ({abs(r):.3f})"
        ax.annotate(f'{on_circle}',
                   xy=(r.real, r.imag),
                   xytext=(10, 10), textcoords='offset points',
                   fontsize=8, alpha=0.7)

ax.set_xlim(-2.2, 2.8)
ax.set_ylim(-1.8, 1.8)
ax.set_aspect('equal')
ax.set_xlabel('Re(z)', fontsize=13)
ax.set_ylabel('Im(z)', fontsize=13)
ax.set_title('Alexander Polynomial Roots in the Complex Plane\n'
            'Roots ON the unit circle = OAM modes of knotted light',
            fontsize=14, fontweight='bold')
ax.legend(loc='upper right', fontsize=11)
ax.grid(True, alpha=0.2)

# Add annotation box
textstr = ('Trefoil: roots = e^{±iπ/3} (on circle)\n'
          'Figure-8: roots = (3±√5)/2 (real, off circle)\n'
          'Cinquefoil: roots = e^{±2πik/10}, k=1,3 (on circle)')
props = dict(boxstyle='round', facecolor='wheat', alpha=0.8)
ax.text(0.02, 0.02, textstr, transform=ax.transAxes, fontsize=9,
        verticalalignment='bottom', bbox=props)

plt.savefig('viz_alexander_roots.png', dpi=150, bbox_inches='tight')
print("Saved viz_alexander_roots.png")


#!/usr/bin/env python3
"""
Visualization 3: Connected Sum and Spectral Decomposition

Shows how the OAM spectrum of a connected sum K₁ # K₂ decomposes
into the union of the individual spectra, visualizing the theorem:
  oamSpectrumReal(Δ_{K₁#K₂}) = oamSpectrumReal(Δ_{K₁}) ∪ oamSpectrumReal(Δ_{K₂})

This is a direct consequence of Δ_{K₁#K₂} = Δ_{K₁} · Δ_{K₂}.
"""
import numpy as np
import matplotlib.pyplot as plt


def poly_eval(coeffs, x):
    """Evaluate polynomial at real point x."""
    return sum(c * x**i for i, c in enumerate(coeffs))


def poly_multiply(p, q):
    """Multiply two polynomials."""
    result = [0] * (len(p) + len(q) - 1)
    for i, a in enumerate(p):
        for j, b in enumerate(q):
            result[i+j] += a * b
    return result


def complex_eval(coeffs, t):
    """Evaluate at complex point."""
    result = complex(0, 0)
    for i, c in enumerate(coeffs):
        result += c * t**i
    return result


# Knots
trefoil = [1, -1, 1]  # t² - t + 1
fig_eight = [-1, 3, -1]  # -t² + 3t - 1
connected = poly_multiply(trefoil, fig_eight)

x = np.linspace(-1, 4, 1000)
thetas = np.linspace(0, 1, 1000, endpoint=False)

fig, axes = plt.subplots(2, 3, figsize=(16, 10))

# Row 1: Real polynomial evaluations
ax1, ax2, ax3 = axes[0]

y1 = [poly_eval(trefoil, xi) for xi in x]
ax1.plot(x, y1, color='#E91E63', linewidth=2)
ax1.axhline(y=0, color='gray', linewidth=0.5)
ax1.fill_between(x, 0, y1, where=[yi > 0 for yi in y1], alpha=0.2, color='#E91E63')
ax1.fill_between(x, 0, y1, where=[yi < 0 for yi in y1], alpha=0.2, color='blue')
ax1.set_title('Trefoil: t² − t + 1', fontsize=12, fontweight='bold')
ax1.set_xlabel('t')
ax1.set_ylabel('Δ_K(t)')
ax1.set_ylim(-5, 15)
ax1.grid(True, alpha=0.3)
ax1.text(0.05, 0.95, 'No real roots\n(disc = −3)',
        transform=ax1.transAxes, fontsize=9, va='top',
        bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

y2 = [poly_eval(fig_eight, xi) for xi in x]
ax2.plot(x, y2, color='#FF9800', linewidth=2)
ax2.axhline(y=0, color='gray', linewidth=0.5)
ax2.fill_between(x, 0, y2, where=[yi > 0 for yi in y2], alpha=0.2, color='#FF9800')
ax2.fill_between(x, 0, y2, where=[yi < 0 for yi in y2], alpha=0.2, color='blue')
# Mark real roots
roots_fig8 = [(3 + np.sqrt(5))/2, (3 - np.sqrt(5))/2]
for r in roots_fig8:
    ax2.plot(r, 0, 'ko', markersize=8, zorder=5)
    ax2.annotate(f'x={r:.3f}', xy=(r, 0), xytext=(0, 15),
                textcoords='offset points', fontsize=8, ha='center')
ax2.set_title('Figure-Eight: −t² + 3t − 1', fontsize=12, fontweight='bold')
ax2.set_xlabel('t')
ax2.set_ylabel('Δ_K(t)')
ax2.set_ylim(-5, 15)
ax2.grid(True, alpha=0.3)
ax2.text(0.05, 0.95, '2 real roots\n(disc = +5)',
        transform=ax2.transAxes, fontsize=9, va='top',
        bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

y3 = [poly_eval(connected, xi) for xi in x]
ax3.plot(x, y3, color='#9C27B0', linewidth=2)
ax3.axhline(y=0, color='gray', linewidth=0.5)
ax3.fill_between(x, 0, y3, where=[yi > 0 for yi in y3], alpha=0.2, color='#9C27B0')
ax3.fill_between(x, 0, y3, where=[yi < 0 for yi in y3], alpha=0.2, color='blue')
for r in roots_fig8:
    ax3.plot(r, 0, 'ko', markersize=8, zorder=5)
ax3.set_title('Connected Sum: Trefoil # Figure-Eight', fontsize=12, fontweight='bold')
ax3.set_xlabel('t')
ax3.set_ylabel('Δ_{K₁#K₂}(t)')
ax3.set_ylim(-20, 40)
ax3.grid(True, alpha=0.3)
ax3.text(0.05, 0.95, 'Same 2 real roots\n(from figure-eight)',
        transform=ax3.transAxes, fontsize=9, va='top',
        bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

# Row 2: OAM spectral density on unit circle
ax4, ax5, ax6 = axes[1]

for ax, coeffs, name, color in [
    (ax4, trefoil, 'Trefoil', '#E91E63'),
    (ax5, fig_eight, 'Figure-Eight', '#FF9800'),
    (ax6, connected, 'Connected Sum', '#9C27B0'),
]:
    density = [abs(complex_eval(coeffs, np.exp(2j*np.pi*t)))**2 for t in thetas]
    ax.fill_between(thetas * 360, 0, density, alpha=0.3, color=color)
    ax.plot(thetas * 360, density, color=color, linewidth=2)
    ax.set_xlabel('θ (degrees)')
    ax.set_ylabel('|Δ_K(e^{2πiθ})|²')
    ax.set_title(f'{name}: Unit Circle Spectrum', fontsize=11)
    ax.set_xlim(0, 360)
    ax.set_ylim(bottom=0)
    ax.grid(True, alpha=0.3)

    # Mark zeros
    density_arr = np.array(density)
    min_indices = np.where(density_arr < 0.01 * density_arr.max())[0]
    if len(min_indices) > 0:
        groups = np.split(min_indices, np.where(np.diff(min_indices) > 5)[0] + 1)
        for g in groups:
            center = thetas[g[len(g)//2]] * 360
            ax.axvline(x=center, color='red', linestyle='--', alpha=0.5)

fig.suptitle('Connected Sum Theorem: OAM Spectrum Decomposes as Union\n'
            'Δ_{K₁#K₂} = Δ_{K₁} · Δ_{K₂}  →  Roots(K₁#K₂) = Roots(K₁) ∪ Roots(K₂)',
            fontsize=14, fontweight='bold', y=1.02)

plt.tight_layout()
plt.savefig('viz_connected_sum.png', dpi=150, bbox_inches='tight')
print("Saved viz_connected_sum.png")


#!/usr/bin/env python3
"""
Visualization 1: OAM Spectral Density on the Unit Circle

Visualizes the spectral density |Δ_K(e^{2πiθ})|² for different knots,
showing how the Alexander polynomial creates distinct "fingerprints"
on the unit circle. Roots of the polynomial appear as dips to zero
in the spectral density, corresponding to OAM modes of knotted light.
"""
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec


def alexander_eval(coeffs, t):
    """Evaluate polynomial with given coefficients at complex point t."""
    result = complex(0, 0)
    for i, c in enumerate(coeffs):
        result += c * t**i
    return result


def spectral_density(coeffs, n_points=1000):
    """Compute |Δ_K(e^{2πiθ})|² on the unit circle."""
    thetas = np.linspace(0, 1, n_points, endpoint=False)
    density = np.array([
        abs(alexander_eval(coeffs, np.exp(2j * np.pi * theta)))**2
        for theta in thetas
    ])
    return thetas, density


# Knot data
knots = {
    'Unknot\n(Δ = 1)': [1],
    'Trefoil\n(Δ = t² − t + 1)': [1, -1, 1],
    'Figure-Eight\n(Δ = −t² + 3t − 1)': [-1, 3, -1],
    'Cinquefoil\n(Δ = t⁴ − t³ + t² − t + 1)': [1, -1, 1, -1, 1],
}

colors = ['#2196F3', '#E91E63', '#FF9800', '#4CAF50']

fig = plt.figure(figsize=(14, 10))
gs = gridspec.GridSpec(2, 2, hspace=0.35, wspace=0.3)

for idx, ((name, coeffs), color) in enumerate(zip(knots.items(), colors)):
    ax = fig.add_subplot(gs[idx])

    thetas, density = spectral_density(coeffs)

    ax.fill_between(thetas * 360, 0, density, alpha=0.3, color=color)
    ax.plot(thetas * 360, density, color=color, linewidth=2)

    # Mark roots (where density ≈ 0)
    root_indices = np.where(density < 1e-6)[0]
    if len(root_indices) > 0:
        for ri in root_indices[::max(1, len(root_indices)//10)]:
            ax.axvline(x=thetas[ri]*360, color='red', linestyle='--',
                      alpha=0.5, linewidth=1)
            ax.annotate(f'OAM\nmode',
                       xy=(thetas[ri]*360, 0), fontsize=7,
                       ha='center', va='bottom', color='red')

    ax.set_xlabel('θ (degrees)', fontsize=11)
    ax.set_ylabel('|Δ_K(e^{2πiθ})|²', fontsize=11)
    ax.set_title(name, fontsize=12, fontweight='bold')
    ax.set_xlim(0, 360)
    ax.set_ylim(bottom=0)
    ax.grid(True, alpha=0.3)

fig.suptitle('OAM Spectral Density of Knotted Light Beams',
            fontsize=16, fontweight='bold', y=0.98)
plt.savefig('viz_oam_spectrum.png', dpi=150, bbox_inches='tight')
print("Saved viz_oam_spectrum.png")
