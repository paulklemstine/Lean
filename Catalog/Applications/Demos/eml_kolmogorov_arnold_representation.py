"""
EML-Kolmogorov-Arnold Representation: Applications

Demonstrates real-world applications of EML-KA decompositions:
1. Financial option pricing (Black-Scholes components)
2. Signal processing (log-spectral analysis)
3. Machine learning (softmax decomposition)
4. Information theory (KL divergence computation)
"""

import numpy as np
from typing import Tuple


# =====================================================================
# Application 1: Financial Option Pricing
# =====================================================================

def black_scholes_d1(S: float, K: float, T: float,
                     r: float, sigma: float) -> float:
    """Compute d1 in Black-Scholes using EML-KA decomposition.

    d1 = [log(S/K) + (r + σ²/2)T] / (σ√T)

    The log(S/K) = log(S) - log(K) term is a KA decomposition
    of the ratio S/K using inner functions φ₁ = log, φ₂ = -log.

    Args:
        S: Current stock price
        K: Strike price
        T: Time to expiration (years)
        r: Risk-free rate
        sigma: Volatility

    Returns:
        The d1 parameter
    """
    # EML-KA decomposition of the ratio
    log_ratio = np.log(S) + (-np.log(K))  # φ₁(S) + φ₂(K)
    d1 = (log_ratio + (r + sigma**2 / 2) * T) / (sigma * np.sqrt(T))
    return d1


def demonstrate_option_pricing():
    """Show how EML-KA decomposes option pricing computations."""
    print("=" * 60)
    print("Application 1: Black-Scholes via EML-KA")
    print("=" * 60)

    scenarios = [
        (100, 100, 1.0, 0.05, 0.2, "At-the-money"),
        (100, 110, 0.5, 0.05, 0.3, "Out-of-money"),
        (100, 90, 0.25, 0.02, 0.15, "In-the-money"),
    ]

    for S, K, T, r, sigma, name in scenarios:
        d1 = black_scholes_d1(S, K, T, r, sigma)
        print(f"  {name}: S={S}, K={K}, T={T:.2f}")
        print(f"    log(S/K) = log({S}) + (-log({K})) = {np.log(S):.4f} + {-np.log(K):.4f}")
        print(f"    d1 = {d1:.6f}")
        print()


# =====================================================================
# Application 2: Log-Spectral Signal Processing
# =====================================================================

def log_spectral_distance(spectrum1: np.ndarray, spectrum2: np.ndarray) -> float:
    """Compute log-spectral distance using EML-KA structure.

    LSD = sqrt(mean((10*log10(S1/S2))^2))
        = sqrt(mean((10*(log10(S1) - log10(S2)))^2))

    The inner log10 functions are EML primitives, and the ratio
    S1/S2 decomposes as exp(log(S1) - log(S2)).

    Args:
        spectrum1: Power spectrum of signal 1 (positive values)
        spectrum2: Power spectrum of signal 2 (positive values)

    Returns:
        Log-spectral distance in dB
    """
    # EML-KA: log-ratio decomposition
    log_diff = 10 * (np.log10(spectrum1) - np.log10(spectrum2))
    return float(np.sqrt(np.mean(log_diff**2)))


def demonstrate_signal_processing():
    """Show EML-KA in spectral analysis."""
    print("=" * 60)
    print("Application 2: Log-Spectral Distance via EML-KA")
    print("=" * 60)

    np.random.seed(42)
    freqs = np.linspace(100, 8000, 256)

    # Generate synthetic power spectra
    spectrum_clean = np.exp(-((freqs - 1000) / 500)**2) + 0.1
    spectrum_noisy = spectrum_clean * np.exp(0.1 * np.random.randn(256))
    spectrum_shifted = np.exp(-((freqs - 1500) / 500)**2) + 0.1

    lsd_noise = log_spectral_distance(spectrum_clean, spectrum_noisy)
    lsd_shift = log_spectral_distance(spectrum_clean, spectrum_shifted)

    print(f"  Clean vs. Noisy:   LSD = {lsd_noise:.2f} dB")
    print(f"  Clean vs. Shifted: LSD = {lsd_shift:.2f} dB")
    print(f"  (Higher LSD = more different spectra)")
    print()


# =====================================================================
# Application 3: Softmax via EML-KA
# =====================================================================

def softmax_ratio_eml(z_i: float, z_j: float) -> float:
    """Compute softmax ratio using EML-KA decomposition.

    softmax(z_i) / softmax(z_j) = exp(z_i - z_j)

    This is a 1-term KA decomposition with:
      φ₁(z_i) = z_i, φ₂(z_j) = -z_j, Φ = exp

    Args:
        z_i: Logit i
        z_j: Logit j

    Returns:
        exp(z_i - z_j) = softmax(z_i) / softmax(z_j)
    """
    return np.exp(z_i + (-z_j))


def demonstrate_softmax():
    """Show EML-KA structure in softmax computation."""
    print("=" * 60)
    print("Application 3: Softmax Ratios via EML-KA")
    print("=" * 60)

    logits = np.array([2.0, 1.0, 0.5, -1.0])
    softmax_vals = np.exp(logits) / np.sum(np.exp(logits))

    print("  Logits:", logits)
    print("  Softmax:", np.round(softmax_vals, 6))
    print("\n  Pairwise ratios via EML-KA:")
    for i in range(len(logits)):
        for j in range(i+1, len(logits)):
            ratio_ka = softmax_ratio_eml(logits[i], logits[j])
            ratio_direct = softmax_vals[i] / softmax_vals[j]
            print(f"    s[{i}]/s[{j}] = exp({logits[i]:.1f} - {logits[j]:.1f}) "
                  f"= {ratio_ka:.6f} (direct: {ratio_direct:.6f})")
    print()


# =====================================================================
# Application 4: KL Divergence via EML
# =====================================================================

def kl_divergence_eml(p: np.ndarray, q: np.ndarray) -> float:
    """Compute KL divergence using EML decomposition.

    KL(p||q) = Σ p_i * log(p_i/q_i)
             = Σ [p_i * log(p_i) - p_i * log(q_i)]
             = Σ [p_i * log(p_i) - p_i * (1 - eml(0, q_i))]

    where eml(0, q_i) = exp(0) - log(q_i) = 1 - log(q_i).

    Args:
        p: First probability distribution (sums to 1)
        q: Second probability distribution (sums to 1)

    Returns:
        KL(p||q) >= 0, with equality iff p == q
    """
    eml_terms = 1.0 - np.log(q)  # = eml(0, q_i) for each i
    kl = np.sum(p * np.log(p) - p * (1.0 - eml_terms))
    return float(kl)


def demonstrate_kl_divergence():
    """Show EML structure in KL divergence."""
    print("=" * 60)
    print("Application 4: KL Divergence via EML")
    print("=" * 60)

    distributions = [
        (np.array([0.5, 0.5]), np.array([0.5, 0.5]), "Equal"),
        (np.array([0.7, 0.3]), np.array([0.5, 0.5]), "Skewed vs uniform"),
        (np.array([0.9, 0.1]), np.array([0.5, 0.5]), "Very skewed vs uniform"),
        (np.array([0.25, 0.25, 0.25, 0.25]),
         np.array([0.1, 0.2, 0.3, 0.4]), "Uniform vs gradient"),
    ]

    for p, q, name in distributions:
        kl_eml = kl_divergence_eml(p, q)
        kl_direct = float(np.sum(p * np.log(p / q)))
        print(f"  {name:30s}: KL = {kl_eml:.6f} (direct: {kl_direct:.6f})")

    print()


if __name__ == "__main__":
    demonstrate_option_pricing()
    demonstrate_signal_processing()
    demonstrate_softmax()
    demonstrate_kl_divergence()
    print("All applications demonstrated successfully.")


"""
EML-Kolmogorov-Arnold Representation: Demonstrations

This script demonstrates the core mathematical results connecting
EML (exp-log) functions to Kolmogorov-Arnold decompositions.
"""

import numpy as np

def eml(x: float, y: float) -> float:
    """The EML operation: eml(x, y) = exp(x) - log(y)."""
    return np.exp(x) - np.log(y)

# =============================================================
# Demo 1: Multiplication via EML-KA Decomposition
# x * y = exp(log(x) + log(y)) for x, y > 0
# =============================================================
print("=" * 60)
print("Demo 1: Multiplication via EML-KA Decomposition")
print("  x * y = exp(log(x) + log(y))")
print("=" * 60)

test_pairs = [(2.0, 3.0), (0.5, 4.0), (np.pi, np.e), (100.0, 0.01)]
for x, y in test_pairs:
    ka_result = np.exp(np.log(x) + np.log(y))
    direct = x * y
    error = abs(ka_result - direct)
    print(f"  x={x:.4f}, y={y:.4f}: KA={ka_result:.10f}, "
          f"direct={direct:.10f}, error={error:.2e}")

# =============================================================
# Demo 2: Power Functions via EML-KA
# x^n = exp(n * log(x)) for x > 0
# =============================================================
print("\n" + "=" * 60)
print("Demo 2: Power Functions via EML-KA")
print("  x^n = exp(n * log(x))")
print("=" * 60)

for x in [2.0, 3.0, 0.5]:
    for n in [2, 3, 5, 10]:
        ka_result = np.exp(n * np.log(x))
        direct = x ** n
        error = abs(ka_result - direct) / max(abs(direct), 1e-15)
        print(f"  x={x:.2f}, n={n}: KA={ka_result:.10f}, "
              f"direct={direct:.10f}, rel_error={error:.2e}")

# =============================================================
# Demo 3: Geometric Mean via EML-KA
# sqrt(x*y) = exp(0.5 * log(x) + 0.5 * log(y))
# =============================================================
print("\n" + "=" * 60)
print("Demo 3: Geometric Mean via EML-KA")
print("  sqrt(x*y) = exp(0.5*log(x) + 0.5*log(y))")
print("=" * 60)

for x, y in [(4.0, 9.0), (2.0, 8.0), (1.0, 100.0)]:
    ka_result = np.exp(0.5 * np.log(x) + 0.5 * np.log(y))
    direct = np.sqrt(x * y)
    error = abs(ka_result - direct)
    print(f"  x={x:.1f}, y={y:.1f}: KA={ka_result:.10f}, "
          f"direct={direct:.10f}, error={error:.2e}")

# =============================================================
# Demo 4: Division via EML-KA
# x/y = exp(log(x) - log(y))
# =============================================================
print("\n" + "=" * 60)
print("Demo 4: Division via EML-KA")
print("  x/y = exp(log(x) - log(y))")
print("=" * 60)

for x, y in [(6.0, 3.0), (1.0, 7.0), (np.pi, 2.0)]:
    ka_result = np.exp(np.log(x) - np.log(y))
    direct = x / y
    error = abs(ka_result - direct)
    print(f"  x={x:.4f}, y={y:.4f}: KA={ka_result:.10f}, "
          f"direct={direct:.10f}, error={error:.2e}")

# =============================================================
# Demo 5: KL Divergence Integrand via EML
# p*log(p/q) = p*log(p) - p*(1 - eml(0, q))
# =============================================================
print("\n" + "=" * 60)
print("Demo 5: KL Divergence Integrand via EML")
print("  p*log(p/q) = p*log(p) - p*(1 - eml(0, q))")
print("=" * 60)

for p, q in [(0.3, 0.7), (0.5, 0.5), (0.8, 0.2)]:
    kl_direct = p * np.log(p / q)
    kl_eml = p * np.log(p) - p * (1 - eml(0, q))
    error = abs(kl_direct - kl_eml)
    print(f"  p={p:.1f}, q={q:.1f}: direct={kl_direct:.10f}, "
          f"EML={kl_eml:.10f}, error={error:.2e}")

# =============================================================
# Demo 6: Fenchel-Young Inequality Verification
# x*s <= exp(x) + s*log(s) - s for s > 0
# =============================================================
print("\n" + "=" * 60)
print("Demo 6: Fenchel-Young Inequality")
print("  x*s <= exp(x) + s*log(s) - s")
print("=" * 60)

for x in [-2.0, 0.0, 1.0, 3.0]:
    for s in [0.1, 1.0, 2.0, 5.0]:
        lhs = x * s
        rhs = np.exp(x) + s * np.log(s) - s
        gap = rhs - lhs
        tight_x = np.log(s)
        print(f"  x={x:5.1f}, s={s:4.1f}: LHS={lhs:8.4f}, "
              f"RHS={rhs:8.4f}, gap={gap:.4f} (tight at x=log(s)={tight_x:.4f})")

# =============================================================
# Demo 7: Harmonic Mean via EML Components
# =============================================================
print("\n" + "=" * 60)
print("Demo 7: Harmonic Mean")
print("  H(x,y) = 2/(1/x + 1/y) = 2xy/(x+y)")
print("=" * 60)

for x, y in [(2.0, 8.0), (3.0, 6.0), (1.0, 1.0)]:
    h1 = 2 * x * y / (x + y)
    h2 = 2 / (1/x + 1/y)
    print(f"  x={x:.1f}, y={y:.1f}: H={h1:.10f}, "
          f"via inverses={h2:.10f}, match={abs(h1-h2) < 1e-12}")

print("\n" + "=" * 60)
print("All demonstrations completed successfully.")
print("=" * 60)


"""
Visualization: Fenchel-Young Inequality and EML Duality

Illustrates the Fenchel-Young inequality x·s ≤ exp(x) + s·log(s) - s
which provides a variational characterization of the EML operation.
The gap is zero exactly when x = log(s), connecting exp and log dually.
"""

import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# --- Panel 1: Fenchel-Young for different values of s ---
x = np.linspace(-3, 4, 200)
s_values = [0.5, 1.0, 2.0, 5.0]
colors = ['#2196F3', '#4CAF50', '#FF9800', '#F44336']

for s, color in zip(s_values, colors):
    lhs = x * s
    rhs = np.exp(x) + s * np.log(s) - s
    axes[0].plot(x, rhs - lhs, color=color, linewidth=2, label=f's = {s}')
    axes[0].axvline(np.log(s), color=color, linestyle='--', alpha=0.5)

axes[0].axhline(0, color='black', linewidth=0.5)
axes[0].set_xlabel('x', fontsize=12)
axes[0].set_ylabel('Gap = RHS − LHS', fontsize=12)
axes[0].set_title('Fenchel-Young Gap\n(minimum at x = log s)', fontsize=12)
axes[0].legend(fontsize=10)
axes[0].set_ylim(-0.5, 10)
axes[0].grid(True, alpha=0.3)

# --- Panel 2: exp(x) and its conjugate ---
x = np.linspace(-2, 3, 200)
axes[1].plot(x, np.exp(x), 'b-', linewidth=2.5, label='exp(x)')

# Tangent lines showing duality
for s, color in zip([0.5, 1.0, 2.0], ['#4CAF50', '#FF9800', '#F44336']):
    x0 = np.log(s)
    tangent = s * (x - x0) + s
    axes[1].plot(x, tangent, color=color, linewidth=1.5, linestyle='--',
                 alpha=0.7, label=f'Tangent at x=log({s})')
    axes[1].plot(x0, s, 'o', color=color, markersize=8)

axes[1].set_xlabel('x', fontsize=12)
axes[1].set_ylabel('y', fontsize=12)
axes[1].set_title('exp(x) and Supporting Hyperplanes\n(Convex Conjugate Structure)', fontsize=12)
axes[1].legend(fontsize=9)
axes[1].set_ylim(-1, 12)
axes[1].grid(True, alpha=0.3)

# --- Panel 3: The EML surface eml(x,y) = exp(x) - log(y) ---
y_pos = np.linspace(0.1, 5.0, 100)
x_vals = [-1.0, 0.0, 1.0, 2.0]
for xv, color in zip(x_vals, colors):
    eml_vals = np.exp(xv) - np.log(y_pos)
    axes[2].plot(y_pos, eml_vals, color=color, linewidth=2,
                 label=f'eml({xv}, y)')

axes[2].axhline(0, color='black', linewidth=0.5)
axes[2].set_xlabel('y', fontsize=12)
axes[2].set_ylabel('eml(x, y)', fontsize=12)
axes[2].set_title('EML Slices: eml(x, y) = exp(x) − log(y)\n(exp dominates for large x)', fontsize=12)
axes[2].legend(fontsize=10)
axes[2].grid(True, alpha=0.3)

plt.suptitle('EML Duality: Fenchel-Young Inequality and Convex Conjugates',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_fenchel_young.png', dpi=150, bbox_inches='tight')
print("Saved viz_fenchel_young.png")


"""
Visualization: Inner Functions of EML-KA Decompositions

Shows the role of inner functions (log, scaled log, identity) in
separating variables for Kolmogorov-Arnold representations.
Demonstrates how different inner functions φ(x) map the positive
real line into ℝ, enabling the outer function exp to reconstruct
the target.
"""

import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(2, 2, figsize=(12, 10))

x = np.linspace(0.01, 5.0, 300)

# --- Panel 1: Inner functions ---
ax = axes[0, 0]
ax.plot(x, np.log(x), 'b-', linewidth=2.5, label='φ(x) = log(x) [multiplication]')
ax.plot(x, 0.5 * np.log(x), 'r-', linewidth=2.5, label='φ(x) = ½log(x) [geom. mean]')
ax.plot(x, 2 * np.log(x), 'g-', linewidth=2.5, label='φ(x) = 2·log(x) [x² power]')
ax.plot(x, -np.log(x), 'm--', linewidth=2.5, label='φ(x) = −log(x) [division]')
ax.axhline(0, color='black', linewidth=0.5)
ax.set_xlabel('x', fontsize=12)
ax.set_ylabel('φ(x)', fontsize=12)
ax.set_title('EML Inner Functions', fontsize=13, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# --- Panel 2: Outer function (exp) ---
ax = axes[0, 1]
t = np.linspace(-3, 4, 300)
ax.plot(t, np.exp(t), 'b-', linewidth=2.5, label='Φ(t) = exp(t)')
ax.fill_between(t, 0, np.exp(t), alpha=0.1, color='blue')
ax.set_xlabel('t = φ₁(x) + φ₂(y)', fontsize=12)
ax.set_ylabel('Φ(t)', fontsize=12)
ax.set_title('Universal Outer Function: exp', fontsize=13, fontweight='bold')
ax.legend(fontsize=11)
ax.set_ylim(0, 20)
ax.grid(True, alpha=0.3)

# --- Panel 3: KA term count comparison ---
ax = axes[1, 0]
dims = np.arange(1, 11)
ka_general = 2 * dims + 1
ka_eml_mul = np.ones_like(dims)
ka_eml_pow = np.ones_like(dims)

ax.bar(dims - 0.2, ka_general, 0.4, label='General KA (2n+1)',
       color='#FF6B6B', alpha=0.8)
ax.bar(dims + 0.2, ka_eml_mul, 0.4, label='EML-KA (multiplication)',
       color='#4ECDC4', alpha=0.8)
ax.set_xlabel('Dimension n', fontsize=12)
ax.set_ylabel('Number of terms Q', fontsize=12)
ax.set_title('KA Term Efficiency:\nGeneral vs. EML-KA', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.set_xticks(dims)
ax.grid(True, alpha=0.3, axis='y')

# --- Panel 4: Point separation by log ---
ax = axes[1, 1]
points = [0.5, 1.0, 2.0, 3.0, 5.0]
log_points = [np.log(p) for p in points]

ax.scatter(points, [0]*len(points), s=100, c='blue', zorder=5,
           label='Original points')
ax.scatter(log_points, [1]*len(log_points), s=100, c='red', zorder=5,
           label='After log (separated)')

for p, lp in zip(points, log_points):
    ax.annotate('', xy=(lp, 0.95), xytext=(p, 0.05),
                arrowprops=dict(arrowstyle='->', color='gray', alpha=0.5))
    ax.text(p, -0.15, f'{p}', ha='center', fontsize=10, color='blue')
    ax.text(lp, 1.15, f'{lp:.2f}', ha='center', fontsize=10, color='red')

ax.set_xlabel('Value', fontsize=12)
ax.set_yticks([0, 1])
ax.set_yticklabels(['Input space', 'Log-transformed'])
ax.set_title('Log Separates Points\n(Injective on (0,∞))', fontsize=13, fontweight='bold')
ax.legend(fontsize=10, loc='upper left')
ax.grid(True, alpha=0.3, axis='x')

plt.suptitle('Anatomy of EML-Kolmogorov-Arnold Decompositions',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_ka_inner_functions.png', dpi=150, bbox_inches='tight')
print("Saved viz_ka_inner_functions.png")


"""
Visualization: EML-KA Decomposition Surfaces

Shows how multiplication, geometric mean, and division are decomposed
via exp-log (EML) inner functions in Kolmogorov-Arnold form.
Each surface plot shows the target function and its EML-KA reconstruction.
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

fig, axes = plt.subplots(2, 3, figsize=(16, 10),
                         subplot_kw={'projection': '3d'})

x = np.linspace(0.1, 5.0, 50)
y = np.linspace(0.1, 5.0, 50)
X, Y = np.meshgrid(x, y)

# --- Row 1: Target functions ---
# Multiplication
Z_mul = X * Y
axes[0, 0].plot_surface(X, Y, Z_mul, cmap='viridis', alpha=0.8)
axes[0, 0].set_title('Target: x · y', fontsize=12)
axes[0, 0].set_xlabel('x'); axes[0, 0].set_ylabel('y')

# Geometric mean
Z_geom = np.sqrt(X * Y)
axes[0, 1].plot_surface(X, Y, Z_geom, cmap='plasma', alpha=0.8)
axes[0, 1].set_title('Target: √(xy)', fontsize=12)
axes[0, 1].set_xlabel('x'); axes[0, 1].set_ylabel('y')

# Division
Z_div = X / Y
axes[0, 2].plot_surface(X, Y, Z_div, cmap='coolwarm', alpha=0.8)
axes[0, 2].set_title('Target: x / y', fontsize=12)
axes[0, 2].set_xlabel('x'); axes[0, 2].set_ylabel('y')

# --- Row 2: EML-KA reconstructions ---
# Multiplication via exp(log x + log y)
Z_mul_ka = np.exp(np.log(X) + np.log(Y))
axes[1, 0].plot_surface(X, Y, Z_mul_ka, cmap='viridis', alpha=0.8)
axes[1, 0].set_title('EML-KA: exp(log x + log y)', fontsize=12)
axes[1, 0].set_xlabel('x'); axes[1, 0].set_ylabel('y')

# Geometric mean via exp(½ log x + ½ log y)
Z_geom_ka = np.exp(0.5 * np.log(X) + 0.5 * np.log(Y))
axes[1, 1].plot_surface(X, Y, Z_geom_ka, cmap='plasma', alpha=0.8)
axes[1, 1].set_title('EML-KA: exp(½log x + ½log y)', fontsize=12)
axes[1, 1].set_xlabel('x'); axes[1, 1].set_ylabel('y')

# Division via exp(log x - log y)
Z_div_ka = np.exp(np.log(X) - np.log(Y))
axes[1, 2].plot_surface(X, Y, Z_div_ka, cmap='coolwarm', alpha=0.8)
axes[1, 2].set_title('EML-KA: exp(log x − log y)', fontsize=12)
axes[1, 2].set_xlabel('x'); axes[1, 2].set_ylabel('y')

plt.suptitle('EML-Kolmogorov-Arnold Decompositions:\nTarget Functions vs. EML-KA Reconstructions',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_ka_surfaces.png', dpi=150, bbox_inches='tight')
print("Saved viz_ka_surfaces.png")
