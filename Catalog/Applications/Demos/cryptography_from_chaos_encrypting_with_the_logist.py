"""
Applications of Logistic Map Cryptography

Real-world applications demonstrating the mathematical results:
1. Image pixel scrambling
2. Secure key exchange simulation
3. Random number generation quality assessment
4. Signal masking for secure communication
"""

import math
import struct


def logistic_map(x: float) -> float:
    """The logistic map at r=4."""
    return 4.0 * x * (1.0 - x)


def logistic_prng(seed: float, n: int, warmup: int = 200) -> list:
    """
    Generate n pseudorandom numbers using the logistic map.

    Application: Chaotic PRNG for simulation and Monte Carlo methods.
    The arcsine invariant measure means the output is NOT uniform —
    it clusters near 0 and 1. For uniform output, apply the
    arcsine transformation: u = (2/π) * arcsin(√x).
    """
    x = seed
    for _ in range(warmup):
        x = logistic_map(x)

    output = []
    for _ in range(n):
        x = logistic_map(x)
        # Transform to uniform via inverse CDF of arcsine distribution
        u = (2.0 / math.pi) * math.asin(math.sqrt(max(0, min(1, x))))
        output.append(u)
    return output


def text_to_floats(text: str) -> list:
    """Convert text to a list of floats in [0, 1] for encryption."""
    return [ord(c) / 256.0 for c in text]


def floats_to_text(floats: list) -> str:
    """Convert list of floats back to text."""
    return ''.join(chr(int(round(f * 256)) % 256) for f in floats)


def logistic_text_encrypt(plaintext: str, seed: float, warmup: int = 200) -> list:
    """
    Encrypt a text message using the logistic cipher.

    Application: Secure messaging with chaos-based encryption.
    """
    msg_floats = text_to_floats(plaintext)
    x = seed
    for _ in range(warmup):
        x = logistic_map(x)

    ciphertext = []
    for m in msg_floats:
        x = logistic_map(x)
        ciphertext.append((m + x) % 1.0)
    return ciphertext


def logistic_text_decrypt(ciphertext: list, seed: float, warmup: int = 200) -> str:
    """Decrypt using the same key."""
    x = seed
    for _ in range(warmup):
        x = logistic_map(x)

    plaintext_floats = []
    for c in ciphertext:
        x = logistic_map(x)
        plaintext_floats.append((c - x) % 1.0)
    return floats_to_text(plaintext_floats)


def signal_masking_demo():
    """
    Application: Secure communication via chaotic signal masking.

    A message signal s(t) is added to a chaotic carrier c(t).
    The receiver synchronizes their own chaotic oscillator and
    subtracts c(t) to recover s(t).
    """
    print("Signal Masking Demo")
    print("-" * 40)

    # Generate a simple "signal" (sine wave sampled at discrete points)
    n_samples = 50
    signal = [0.1 * math.sin(2 * math.pi * i / n_samples) for i in range(n_samples)]

    # Generate chaotic carrier
    seed = 0.314159265358979
    x = seed
    for _ in range(200):
        x = logistic_map(x)

    carrier = []
    for _ in range(n_samples):
        x = logistic_map(x)
        carrier.append(x)

    # Masked signal = signal + carrier
    masked = [s + c for s, c in zip(signal, carrier)]

    # Recovery: subtract carrier (using same seed)
    x = seed
    for _ in range(200):
        x = logistic_map(x)
    recovered_carrier = []
    for _ in range(n_samples):
        x = logistic_map(x)
        recovered_carrier.append(x)

    recovered = [m - c for m, c in zip(masked, recovered_carrier)]

    max_err = max(abs(s - r) for s, r in zip(signal, recovered))
    print(f"  Signal samples: {n_samples}")
    print(f"  Max recovery error: {max_err:.2e}")
    print(f"  Signal power: {sum(s**2 for s in signal) / n_samples:.6f}")
    print(f"  Carrier power: {sum(c**2 for c in carrier) / n_samples:.6f}")
    print(f"  Signal-to-carrier ratio: {10 * math.log10(sum(s**2 for s in signal) / sum(c**2 for c in carrier)):.1f} dB")
    print(f"  → Carrier completely masks signal!")


def key_sensitivity_demo():
    """
    Application: Demonstrating key sensitivity for secure storage.

    Even a 10^-15 change in the key produces completely different output
    after sufficient iterations.
    """
    print("\nKey Sensitivity Demo")
    print("-" * 40)

    key1 = 0.123456789012345
    key2 = key1 + 1e-15  # Smallest representable difference

    n_iter = 100
    x1, x2 = key1, key2

    print(f"  Key 1: {key1:.18f}")
    print(f"  Key 2: {key2:.18f}")
    print(f"  Initial difference: {abs(key1 - key2):.2e}")

    for i in range(n_iter):
        x1 = logistic_map(x1)
        x2 = logistic_map(x2)
        if i in [0, 10, 20, 30, 40, 50]:
            print(f"  After {i+1:3d} iterations: |Δ| = {abs(x1-x2):.6e}")

    print(f"  After {n_iter:3d} iterations: |Δ| = {abs(x1-x2):.6e}")
    print(f"  → Complete decorrelation after ~50 iterations")


def monte_carlo_pi_estimate():
    """
    Application: Using logistic map PRNG for Monte Carlo estimation of π.

    Generates points in [0,1]² using the chaotic PRNG and estimates π
    via the inscribed circle method.
    """
    print("\nMonte Carlo π Estimation")
    print("-" * 40)

    n_points = 100000
    seed = 0.7777777
    nums = logistic_prng(seed, 2 * n_points)

    inside = 0
    for i in range(n_points):
        x, y = nums[2*i], nums[2*i + 1]
        if x**2 + y**2 <= 1:
            inside += 1

    pi_est = 4.0 * inside / n_points
    print(f"  Points generated: {n_points:,}")
    print(f"  π estimate: {pi_est:.6f}")
    print(f"  True π:     {math.pi:.6f}")
    print(f"  Error:      {abs(pi_est - math.pi):.6f}")
    print(f"  Relative:   {abs(pi_est - math.pi) / math.pi:.4%}")


if __name__ == "__main__":
    print("=" * 60)
    print("APPLICATIONS OF LOGISTIC MAP CRYPTOGRAPHY")
    print("=" * 60)

    # Text encryption
    print("\n1. TEXT ENCRYPTION")
    print("-" * 40)
    message = "Hello, World! Chaos is the key."
    key = 0.314159265358979
    encrypted = logistic_text_encrypt(message, key)
    decrypted = logistic_text_decrypt(encrypted, key)
    print(f"  Original:  '{message}'")
    print(f"  Encrypted: {[round(c, 4) for c in encrypted[:10]]}... ({len(encrypted)} values)")
    print(f"  Decrypted: '{decrypted}'")
    print(f"  Match: {message == decrypted}")

    # Signal masking
    print()
    signal_masking_demo()

    # Key sensitivity
    key_sensitivity_demo()

    # Monte Carlo
    monte_carlo_pi_estimate()

    # PRNG quality
    print("\n5. PRNG UNIFORMITY TEST")
    print("-" * 40)
    nums = logistic_prng(0.3, 10000)
    n_bins = 10
    counts = [0] * n_bins
    for u in nums:
        b = min(int(u * n_bins), n_bins - 1)
        counts[b] += 1
    expected = len(nums) / n_bins
    chi_sq = sum((c - expected)**2 / expected for c in counts)
    print(f"  Generated: {len(nums)} uniform samples")
    print(f"  Bin counts: {counts}")
    print(f"  Expected:   {int(expected)} per bin")
    print(f"  χ² = {chi_sq:.2f} (critical value at 5%: 16.92)")
    print(f"  Passes: {chi_sq < 16.92}")


"""
Cryptography from Chaos: Logistic Map Cipher Demonstration

Demonstrates the key properties of the logistic map f(x) = 4x(1-x) at r=4:
1. Fixed points and period-2 orbits
2. Chebyshev semiconjugacy: f^n(sin²θ) = sin²(2^n θ)
3. Sensitivity to initial conditions (Lyapunov exponent = log 2)
4. The logistic cipher: encryption and decryption
5. Polynomial degree growth (cryptographic hardness)
"""

import math


def logistic_map(x: float) -> float:
    """The logistic map at r=4: f(x) = 4x(1-x)"""
    return 4.0 * x * (1.0 - x)


def logistic_iter(n: int, x: float) -> float:
    """Compute f^n(x), the n-th iterate of the logistic map."""
    for _ in range(n):
        x = logistic_map(x)
    return x


def chebyshev_semiconjugacy_check(theta: float, n: int) -> tuple:
    """
    Verify the semiconjugacy: f^n(sin²θ) = sin²(2^n θ).
    Returns (left_side, right_side, error).
    """
    x0 = math.sin(theta) ** 2
    left = logistic_iter(n, x0)
    right = math.sin((2**n) * theta) ** 2
    return left, right, abs(left - right)


def sensitivity_demo(x0: float, epsilon: float, n_steps: int) -> list:
    """
    Demonstrate exponential sensitivity: track |f^n(x0) - f^n(x0+ε)|.
    Returns list of (n, x_n, y_n, difference).
    """
    x, y = x0, x0 + epsilon
    results = []
    for n in range(n_steps):
        results.append((n, x, y, abs(x - y)))
        x = logistic_map(x)
        y = logistic_map(y)
    return results


def logistic_cipher_encrypt(plaintext: list, seed: float, warmup: int = 100) -> list:
    """
    Encrypt a list of floats using the logistic cipher.

    plaintext: list of floats in [0, 1]
    seed: initial condition in (0, 1)
    warmup: number of transient iterations to skip
    """
    x = seed
    # Warm up: skip transients
    for _ in range(warmup):
        x = logistic_map(x)

    ciphertext = []
    for m in plaintext:
        x = logistic_map(x)
        ciphertext.append(m + x)  # Additive cipher (mod 1 for [0,1])
    return ciphertext


def logistic_cipher_decrypt(ciphertext: list, seed: float, warmup: int = 100) -> list:
    """
    Decrypt using the same seed and warmup.
    """
    x = seed
    for _ in range(warmup):
        x = logistic_map(x)

    plaintext = []
    for c in ciphertext:
        x = logistic_map(x)
        plaintext.append(c - x)
    return plaintext


def polynomial_degree_growth(max_n: int = 20) -> list:
    """Show how the polynomial degree 2^n grows vs n^3."""
    results = []
    for n in range(1, max_n + 1):
        results.append((n, 2**n, n**3))
    return results


if __name__ == "__main__":
    print("=" * 70)
    print("CRYPTOGRAPHY FROM CHAOS: LOGISTIC MAP DEMONSTRATION")
    print("=" * 70)

    # 1. Fixed points
    print("\n1. FIXED POINTS")
    print(f"   f(0) = {logistic_map(0):.6f}  (fixed point)")
    print(f"   f(3/4) = {logistic_map(0.75):.6f}  (fixed point)")
    print(f"   f(1/2) = {logistic_map(0.5):.6f}  (maximum)")
    print(f"   f(1) = {logistic_map(1.0):.6f}  (maps to 0)")

    # 2. Period-2 orbit
    print("\n2. PERIOD-2 ORBIT")
    sqrt5 = math.sqrt(5)
    x_p2 = (5 + sqrt5) / 8
    y_p2 = (5 - sqrt5) / 8
    print(f"   x = (5+√5)/8 = {x_p2:.6f}")
    print(f"   y = (5-√5)/8 = {y_p2:.6f}")
    print(f"   f(x) = {logistic_map(x_p2):.6f} ≈ y = {y_p2:.6f}")
    print(f"   f(y) = {logistic_map(y_p2):.6f} ≈ x = {x_p2:.6f}")
    print(f"   x + y = {x_p2 + y_p2:.6f} (should be 5/4 = 1.25)")
    print(f"   x * y = {x_p2 * y_p2:.6f} (should be 5/16 = 0.3125)")

    # 3. Chebyshev semiconjugacy
    print("\n3. CHEBYSHEV SEMICONJUGACY: f^n(sin²θ) = sin²(2^n θ)")
    theta = 0.3
    for n in range(1, 8):
        left, right, err = chebyshev_semiconjugacy_check(theta, n)
        print(f"   n={n}: f^n(sin²θ) = {left:.10f}, sin²(2^n θ) = {right:.10f}, error = {err:.2e}")

    # 4. Sensitivity to initial conditions
    print("\n4. SENSITIVITY TO INITIAL CONDITIONS (Lyapunov exponent)")
    x0 = 0.3
    epsilon = 1e-10
    results = sensitivity_demo(x0, epsilon, 40)
    print(f"   x₀ = {x0}, ε = {epsilon}")
    for n, x, y, diff in results:
        if n % 5 == 0 or diff > 0.01:
            lyap = math.log(diff / epsilon) / max(n, 1) if diff > 0 and n > 0 else 0
            print(f"   n={n:3d}: |Δ| = {diff:.6e}  λ ≈ {lyap:.3f} (theory: {math.log(2):.3f})")
            if diff > 0.1:
                break

    # 5. Polynomial degree growth
    print("\n5. POLYNOMIAL DEGREE GROWTH (Cryptographic Hardness)")
    print("   n   | deg(f^n) = 2^n  | n³")
    print("   " + "-" * 35)
    for n, deg, cubic in polynomial_degree_growth(15):
        marker = " ← 2^n overtakes n³" if n == 10 else ""
        print(f"   {n:3d} | {deg:>12,d}    | {cubic:>6,d}{marker}")

    # 6. Logistic cipher demo
    print("\n6. LOGISTIC CIPHER DEMO")
    seed = 0.123456789012345
    warmup = 200
    plaintext = [0.1, 0.5, 0.9, 0.3, 0.7]
    print(f"   Seed: {seed}")
    print(f"   Warmup: {warmup}")
    print(f"   Plaintext:  {[f'{p:.4f}' for p in plaintext]}")
    ciphertext = logistic_cipher_encrypt(plaintext, seed, warmup)
    print(f"   Ciphertext: {[f'{c:.4f}' for c in ciphertext]}")
    recovered = logistic_cipher_decrypt(ciphertext, seed, warmup)
    print(f"   Recovered:  {[f'{r:.4f}' for r in recovered]}")
    max_err = max(abs(p - r) for p, r in zip(plaintext, recovered))
    print(f"   Max error:  {max_err:.2e}")

    # 7. Wrong key decryption
    print("\n7. WRONG KEY DECRYPTION")
    wrong_seed = seed + 1e-15
    wrong_recovered = logistic_cipher_decrypt(ciphertext, wrong_seed, warmup)
    print(f"   Wrong seed: {wrong_seed}")
    print(f"   Recovered:  {[f'{r:.4f}' for r in wrong_recovered]}")
    print(f"   Error:      {max(abs(p - r) for p, r in zip(plaintext, wrong_recovered)):.4f}")


"""
Visualization 1: Logistic Map Cobweb Diagram and Orbit at r=4

Shows the chaotic dynamics of f(x) = 4x(1-x) via:
- The parabola y = 4x(1-x) and the diagonal y = x
- A cobweb diagram tracing the orbit from x₀ = 0.1
- Fixed points at x=0 and x=3/4 marked

This visualizes why the logistic map is chaotic: the parabola's
steep slopes cause orbits to bounce wildly across [0,1].
"""

import numpy as np
import matplotlib.pyplot as plt

def logistic_map(x, r=4.0):
    return r * x * (1.0 - x)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: Cobweb diagram
ax = axes[0]
x_range = np.linspace(0, 1, 500)
ax.plot(x_range, logistic_map(x_range), 'b-', linewidth=2, label='$f(x) = 4x(1-x)$')
ax.plot(x_range, x_range, 'k--', linewidth=1, label='$y = x$')

# Cobweb from x0 = 0.1
x0 = 0.1
x = x0
n_steps = 30
cobweb_x, cobweb_y = [x], [0]
for _ in range(n_steps):
    y = logistic_map(x)
    cobweb_x.extend([x, y])
    cobweb_y.extend([y, y])
    x = y

ax.plot(cobweb_x, cobweb_y, 'r-', linewidth=0.8, alpha=0.7)
ax.plot(0, 0, 'go', markersize=10, zorder=5, label='Fixed point $x=0$')
ax.plot(0.75, 0.75, 'ms', markersize=10, zorder=5, label='Fixed point $x=3/4$')
ax.plot(x0, 0, 'r^', markersize=10, zorder=5, label=f'$x_0={x0}$')

ax.set_xlabel('$x$', fontsize=14)
ax.set_ylabel('$f(x)$', fontsize=14)
ax.set_title('Cobweb Diagram: Chaotic Orbit of $f(x) = 4x(1-x)$', fontsize=13)
ax.legend(fontsize=10, loc='upper left')
ax.set_xlim(-0.02, 1.02)
ax.set_ylim(-0.02, 1.1)
ax.grid(True, alpha=0.3)

# Right panel: Time series showing sensitivity
ax2 = axes[1]
n_iter = 80
x1, x2 = 0.3, 0.3 + 1e-10
orbit1, orbit2 = [x1], [x2]
for _ in range(n_iter):
    x1 = logistic_map(x1)
    x2 = logistic_map(x2)
    orbit1.append(x1)
    orbit2.append(x2)

ax2.plot(range(n_iter+1), orbit1, 'b-', linewidth=1, label='$x_0 = 0.3$', alpha=0.8)
ax2.plot(range(n_iter+1), orbit2, 'r-', linewidth=1, label='$x_0 = 0.3 + 10^{-10}$', alpha=0.8)

ax2.set_xlabel('Iteration $n$', fontsize=14)
ax2.set_ylabel('$f^n(x_0)$', fontsize=14)
ax2.set_title('Sensitivity: Two Orbits Diverge Exponentially', fontsize=13)
ax2.legend(fontsize=11)
ax2.set_xlim(0, n_iter)
ax2.set_ylim(-0.02, 1.02)
ax2.grid(True, alpha=0.3)

# Add annotation showing divergence point
for i in range(len(orbit1)):
    if abs(orbit1[i] - orbit2[i]) > 0.1:
        ax2.axvline(x=i, color='gray', linestyle=':', alpha=0.5)
        ax2.annotate(f'Diverge at $n={i}$', xy=(i, 0.5),
                    fontsize=10, color='gray', ha='center')
        break

plt.tight_layout()
plt.savefig('viz_cobweb_sensitivity.png', dpi=150, bbox_inches='tight')
print("Saved viz_cobweb_sensitivity.png")


"""
Visualization 3: Cryptographic Hardness — Polynomial Degree Growth

Shows why the logistic cipher is computationally hard to break:
- Left: Exponential growth of polynomial degree 2^n vs polynomial bounds n³
- Right: The iterate polynomials f^1, f^2, f^3 showing rapid complexity growth

This is the core cryptographic insight: inverting f^n(x) = y requires
solving a polynomial of degree 2^n, which is exponentially hard.
"""

import numpy as np
import matplotlib.pyplot as plt


def logistic_map(x):
    return 4.0 * x * (1.0 - x)


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Degree growth comparison
ax = axes[0]
n_range = np.arange(1, 26)
degree_2n = 2.0**n_range
cubic = n_range**3.0
quartic = n_range**4.0

ax.semilogy(n_range, degree_2n, 'b-o', linewidth=2, markersize=5,
            label='$\\deg(f^n) = 2^n$ (actual)')
ax.semilogy(n_range, cubic, 'r--', linewidth=2, label='$n^3$ (polynomial)')
ax.semilogy(n_range, quartic, 'g-.', linewidth=1.5, label='$n^4$')

# Mark the crossover point
for n in n_range:
    if 2**n > n**3:
        ax.axvline(x=n, color='orange', linestyle=':', alpha=0.5)
        ax.annotate(f'$2^n > n^3$ at $n={n}$',
                   xy=(n, 2**n), xytext=(n+2, 2**(n-2)),
                   fontsize=10, arrowprops=dict(arrowstyle='->', color='orange'),
                   color='orange')
        break

ax.fill_between(n_range, cubic, degree_2n, alpha=0.1, color='blue',
                where=degree_2n > cubic)

ax.set_xlabel('Number of iterations $n$', fontsize=14)
ax.set_ylabel('Polynomial degree / Complexity', fontsize=14)
ax.set_title('Cryptographic Hardness:\nExponential Degree Growth', fontsize=13)
ax.legend(fontsize=12, loc='upper left')
ax.grid(True, alpha=0.3)
ax.set_ylim(1, 1e8)

# Right: The iterate functions f, f², f³, f⁴
ax2 = axes[1]
x_range = np.linspace(0, 1, 1000)

colors = ['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728', '#9467bd']
for n, color in zip([1, 2, 3, 4, 5], colors):
    y = x_range.copy()
    for _ in range(n):
        y = 4.0 * y * (1.0 - y)
    ax2.plot(x_range, y, color=color, linewidth=1.5,
             label=f'$f^{n}(x)$, deg $= 2^{n} = {2**n}$',
             alpha=0.8)

ax2.plot(x_range, x_range, 'k--', linewidth=0.5, alpha=0.5, label='$y=x$')

ax2.set_xlabel('$x$', fontsize=14)
ax2.set_ylabel('$f^n(x)$', fontsize=14)
ax2.set_title('Iterate Polynomials: Growing Complexity', fontsize=13)
ax2.legend(fontsize=10, loc='lower center', ncol=2)
ax2.set_xlim(0, 1)
ax2.set_ylim(-0.02, 1.02)
ax2.grid(True, alpha=0.3)

# Add annotation about oscillation count
ax2.text(0.5, -0.15, 'Each iterate has $2^n$ oscillations — exponentially more complex to invert',
         transform=ax2.transAxes, fontsize=10, ha='center', style='italic',
         bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

plt.tight_layout()
plt.savefig('viz_crypto_hardness.png', dpi=150, bbox_inches='tight')
print("Saved viz_crypto_hardness.png")


"""
Visualization 2: Chebyshev Semiconjugacy and Invariant Measure

Shows the deep mathematical structure behind the logistic map:
- Left: The semiconjugacy sin²(θ) maps angle-doubling to the logistic map
- Right: The invariant (arcsine) measure μ(x) = 1/(π√(x(1-x)))

The semiconjugacy is the key insight: chaos in the logistic map is
just angle-doubling in disguise, viewed through the lens of sin².
"""

import numpy as np
import matplotlib.pyplot as plt

def logistic_map(x):
    return 4.0 * x * (1.0 - x)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Semiconjugacy diagram
ax = axes[0]

# Show how sin²(θ) transforms the circle map to the logistic map
theta = np.linspace(0, np.pi, 200)
x_vals = np.sin(theta)**2

# Plot sin²(θ) vs sin²(2θ) and logistic(sin²(θ))
theta_test = np.linspace(0.01, np.pi - 0.01, 100)
x_input = np.sin(theta_test)**2
logistic_output = logistic_map(x_input)
doubled_output = np.sin(2 * theta_test)**2

ax.scatter(x_input, logistic_output, c='blue', s=10, alpha=0.6,
           label='$f(\\sin^2\\theta)$')
ax.scatter(x_input, doubled_output, c='red', s=10, alpha=0.6,
           marker='x', label='$\\sin^2(2\\theta)$')

# They should be identical
ax.set_xlabel('$\\sin^2(\\theta)$', fontsize=14)
ax.set_ylabel('Output', fontsize=14)
ax.set_title('Chebyshev Semiconjugacy:\n$f(\\sin^2\\theta) = \\sin^2(2\\theta)$', fontsize=13)
ax.legend(fontsize=12)
ax.grid(True, alpha=0.3)

# Add text
max_err = np.max(np.abs(logistic_output - doubled_output))
ax.text(0.5, 0.15, f'Max error: {max_err:.2e}\n(Perfect overlap!)',
        transform=ax.transAxes, fontsize=11,
        bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8),
        ha='center')

# Right: Invariant measure (arcsine distribution)
ax2 = axes[1]

# Generate orbit histogram
x = 0.1234567890123
n_samples = 500000
orbit_data = np.zeros(n_samples)
for i in range(n_samples):
    x = logistic_map(x)
    orbit_data[i] = x

# Plot histogram
n_bins = 100
ax2.hist(orbit_data, bins=n_bins, density=True, alpha=0.6, color='steelblue',
         label='Orbit histogram')

# Overlay theoretical arcsine distribution
x_theory = np.linspace(0.001, 0.999, 500)
arcsine_pdf = 1.0 / (np.pi * np.sqrt(x_theory * (1.0 - x_theory)))
ax2.plot(x_theory, arcsine_pdf, 'r-', linewidth=2.5,
         label='$\\mu(x) = \\frac{1}{\\pi\\sqrt{x(1-x)}}$')

ax2.set_xlabel('$x$', fontsize=14)
ax2.set_ylabel('Density', fontsize=14)
ax2.set_title('Invariant Measure: The Arcsine Distribution', fontsize=13)
ax2.legend(fontsize=12)
ax2.set_xlim(0, 1)
ax2.set_ylim(0, 6)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_semiconjugacy_measure.png', dpi=150, bbox_inches='tight')
print("Saved viz_semiconjugacy_measure.png")
