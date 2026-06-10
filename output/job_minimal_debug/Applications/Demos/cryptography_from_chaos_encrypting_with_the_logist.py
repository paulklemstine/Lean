#!/usr/bin/env python3
"""
Logistic Map Cipher — Demonstration

This script demonstrates the core properties of the logistic cipher:
1. Encryption/decryption correctness
2. Sensitivity to initial conditions
3. Lyapunov exponent computation
4. Statistical quality of keystream
5. Chebyshev conjugacy verification
"""

import math
from algorithms import (
    logistic_map, logistic_orbit, logistic_encrypt, logistic_decrypt,
    lyapunov_exponent, sensitivity_test, frequency_test, runs_test,
    chebyshev_conjugacy, doubling_map, iterate_degree, logistic_keystream
)


def demo_encrypt_decrypt():
    """Demonstrate encryption and decryption."""
    print("=" * 60)
    print("1. ENCRYPTION/DECRYPTION CORRECTNESS")
    print("=" * 60)

    message = b"The logistic map is a chaotic dynamical system!"
    seed = 0.123456789012345
    warmup = 100

    ciphertext = logistic_encrypt(message, seed, warmup)
    recovered = logistic_decrypt(ciphertext, seed, warmup)

    print(f"Plaintext:  {message}")
    print(f"Seed:       {seed}")
    print(f"Ciphertext: {ciphertext.hex()[:60]}...")
    print(f"Recovered:  {recovered}")
    print(f"Correct:    {message == recovered}")
    print()


def demo_sensitivity():
    """Demonstrate sensitivity to initial conditions."""
    print("=" * 60)
    print("2. SENSITIVITY TO INITIAL CONDITIONS")
    print("=" * 60)

    x0 = 0.3
    epsilon = 1e-10
    n = 50

    diffs = sensitivity_test(x0, epsilon, n)

    print(f"Initial seed: {x0}")
    print(f"Perturbation: {epsilon}")
    print(f"\nIteration | Difference")
    print("-" * 35)
    for i in [0, 5, 10, 15, 20, 25, 30, 35, 40]:
        if i < len(diffs):
            print(f"  {i:3d}     | {diffs[i]:.2e}")

    # Find when difference exceeds 0.1
    threshold = 0.1
    for i, d in enumerate(diffs):
        if d > threshold:
            print(f"\nDifference exceeds {threshold} at iteration {i}")
            print(f"  Predicted (log(1/ε)/log(2)): {math.log(1/epsilon)/math.log(2):.1f}")
            break
    print()


def demo_lyapunov():
    """Compute and verify the Lyapunov exponent."""
    print("=" * 60)
    print("3. LYAPUNOV EXPONENT")
    print("=" * 60)

    seeds = [0.1, 0.3, 0.5, 0.7, 0.9]
    n = 100000

    print(f"Theoretical value: log(2) = {math.log(2):.6f}")
    print()
    for x0 in seeds:
        lam = lyapunov_exponent(x0, n)
        print(f"  x₀ = {x0:.1f}: λ = {lam:.6f} (error = {abs(lam - math.log(2)):.2e})")
    print()


def demo_statistics():
    """Test statistical quality of the keystream."""
    print("=" * 60)
    print("4. STATISTICAL QUALITY")
    print("=" * 60)

    x0 = 0.7123456789
    warmup = 200
    n = 10000

    ks = logistic_keystream(x0, warmup, n)

    # Extract bits
    bits = []
    for byte in ks:
        for bit in range(8):
            bits.append((byte >> bit) & 1)

    freq = frequency_test(bits)
    num_runs = runs_test(bits)
    expected_runs = 2 * len(bits) * freq * (1 - freq) + 1

    print(f"Keystream length: {n} bytes ({len(bits)} bits)")
    print(f"Bit frequency:    {freq:.4f} (ideal: 0.5)")
    print(f"Number of runs:   {num_runs} (expected: {expected_runs:.0f})")
    print(f"Byte distribution:")

    # Histogram of byte values (show quartiles)
    hist = [0] * 256
    for b in ks:
        hist[b] += 1
    quartile_counts = [sum(hist[i:i+64]) for i in range(0, 256, 64)]
    for i, c in enumerate(quartile_counts):
        expected = n / 4
        print(f"  [{i*64:3d}-{(i+1)*64-1:3d}]: {c:5d} (expected: {expected:.0f})")
    print()


def demo_conjugacy():
    """Verify the Chebyshev conjugacy numerically."""
    print("=" * 60)
    print("5. CHEBYSHEV CONJUGACY VERIFICATION")
    print("=" * 60)

    print("Verifying: f(sin²(πθ)) = sin²(2πθ)")
    print()

    thetas = [0.1, 0.2, 0.3, 0.4, 0.6, 0.7, 0.8, 0.9]
    max_error = 0.0
    for theta in thetas:
        x = chebyshev_conjugacy(theta)
        lhs = logistic_map(x)
        rhs = chebyshev_conjugacy(2 * theta)
        error = abs(lhs - rhs)
        max_error = max(max_error, error)
        print(f"  θ={theta:.1f}: f(sin²(πθ)) = {lhs:.10f}, sin²(2πθ) = {rhs:.10f}, error = {error:.2e}")

    print(f"\nMaximum error: {max_error:.2e}")
    print()


def demo_complexity():
    """Show exponential complexity of inversion."""
    print("=" * 60)
    print("6. INVERSION COMPLEXITY")
    print("=" * 60)

    print("Degree of f^n (= number of preimage candidates):")
    print()
    for n in range(1, 21):
        deg = iterate_degree(n)
        print(f"  f^{n:2d}: degree = 2^{n:2d} = {deg:>10d}")
    print()
    print("At n=64: degree = 2^64 = 18,446,744,073,709,551,616")
    print("At n=256: degree = 2^256 ≈ 1.16 × 10^77 (comparable to AES-256 keyspace)")
    print()


def demo_wrong_key():
    """Show that wrong key produces gibberish."""
    print("=" * 60)
    print("7. WRONG KEY DEMONSTRATION")
    print("=" * 60)

    message = b"Secret message: The treasure is buried under the old oak tree."
    seed = 0.123456789012345
    wrong_seed = 0.123456789012346  # differs by 10^-15

    ciphertext = logistic_encrypt(message, seed)
    correct = logistic_decrypt(ciphertext, seed)
    wrong = logistic_decrypt(ciphertext, wrong_seed)

    print(f"Original:    {message}")
    print(f"Correct key: {correct}")
    print(f"Wrong key:   {wrong}")
    print(f"Seed diff:   {abs(seed - wrong_seed):.2e}")
    print()


if __name__ == "__main__":
    demo_encrypt_decrypt()
    demo_sensitivity()
    demo_lyapunov()
    demo_statistics()
    demo_conjugacy()
    demo_complexity()
    demo_wrong_key()


#!/usr/bin/env python3
"""Visualization: Bifurcation Diagram and Iterate Complexity"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def logistic(x, r):
    return r * x * (1.0 - x)


def plot_bifurcation():
    fig, axes = plt.subplots(1, 2, figsize=(16, 6))

    # Panel 1: Bifurcation diagram
    ax = axes[0]
    r_values = np.linspace(2.5, 4.0, 2000)
    x = 0.5 * np.ones_like(r_values)

    # Transient
    for _ in range(200):
        x = r_values * x * (1 - x)

    # Plot attractor
    for _ in range(200):
        x = r_values * x * (1 - x)
        ax.plot(r_values, x, ',', color='black', alpha=0.1, markersize=0.1)

    ax.axvline(x=4.0, color='red', linestyle='--', alpha=0.5, label='r = 4 (fully chaotic)')
    ax.set_xlabel('r (parameter)', fontsize=12)
    ax.set_ylabel('x (attractor)', fontsize=12)
    ax.set_title('Bifurcation Diagram of the Logistic Map', fontsize=13)
    ax.legend()

    # Panel 2: Degree growth
    ax = axes[1]
    ns = range(1, 25)
    degrees = [2**n for n in ns]
    ax.semilogy(list(ns), degrees, 'bo-', linewidth=2, markersize=6)
    ax.set_xlabel('Number of iterations n', fontsize=12)
    ax.set_ylabel('Degree of f^n (= search space)', fontsize=12)
    ax.set_title('Exponential Complexity of Inversion', fontsize=13)
    ax.grid(True, alpha=0.3)

    # Annotate key points
    for n in [8, 16, 24]:
        ax.annotate(f'2^{n} = {2**n:,}', xy=(n, 2**n),
                    xytext=(n+1, 2**n * 3),
                    arrowprops=dict(arrowstyle='->', color='red'),
                    fontsize=10, color='red')

    plt.tight_layout()
    plt.savefig('viz_bifurcation.png', dpi=150, bbox_inches='tight')
    print("Saved viz_bifurcation.png")


if __name__ == "__main__":
    plot_bifurcation()


#!/usr/bin/env python3
"""Visualization: Logistic Map Orbits and Sensitivity"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def logistic(x, r=4.0):
    return r * x * (1.0 - x)


def generate_orbit(x0, n, r=4.0):
    orbit = [x0]
    x = x0
    for _ in range(n - 1):
        x = logistic(x, r)
        orbit.append(x)
    return orbit


def plot_sensitivity():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    # Panel 1: Two orbits diverging
    ax = axes[0, 0]
    n = 50
    x0 = 0.3
    eps = 1e-10
    orbit1 = generate_orbit(x0, n)
    orbit2 = generate_orbit(x0 + eps, n)
    ax.plot(range(n), orbit1, 'b-', alpha=0.7, label=f'x₀ = {x0}')
    ax.plot(range(n), orbit2, 'r--', alpha=0.7, label=f'x₀ = {x0} + 10⁻¹⁰')
    ax.set_xlabel('Iteration')
    ax.set_ylabel('x')
    ax.set_title('Sensitivity: Two Nearly Identical Seeds')
    ax.legend()

    # Panel 2: Difference growth
    ax = axes[0, 1]
    diffs = [abs(a - b) for a, b in zip(orbit1, orbit2)]
    ax.semilogy(range(n), diffs, 'k-', linewidth=2)
    ax.axhline(y=0.1, color='r', linestyle='--', alpha=0.5, label='O(1) threshold')
    theoretical_n = np.log(1/eps) / np.log(2)
    ax.axvline(x=theoretical_n, color='g', linestyle='--', alpha=0.5,
               label=f'log₂(1/ε) ≈ {theoretical_n:.0f}')
    ax.set_xlabel('Iteration')
    ax.set_ylabel('|Δx|')
    ax.set_title('Exponential Divergence (Lyapunov)')
    ax.legend()

    # Panel 3: Cobweb diagram
    ax = axes[1, 0]
    x_range = np.linspace(0, 1, 500)
    ax.plot(x_range, [logistic(x) for x in x_range], 'b-', linewidth=2, label='f(x) = 4x(1-x)')
    ax.plot(x_range, x_range, 'k--', alpha=0.5, label='y = x')
    # Cobweb
    x = 0.1
    for _ in range(30):
        y = logistic(x)
        ax.plot([x, x], [x, y], 'r-', alpha=0.4, linewidth=0.5)
        ax.plot([x, y], [y, y], 'r-', alpha=0.4, linewidth=0.5)
        x = y
    ax.set_xlabel('x')
    ax.set_ylabel('f(x)')
    ax.set_title('Cobweb Diagram')
    ax.legend()

    # Panel 4: Invariant measure histogram
    ax = axes[1, 1]
    x = 0.1234
    orbit = generate_orbit(x, 100000)
    ax.hist(orbit[100:], bins=200, density=True, alpha=0.7, color='steelblue',
            label='Empirical distribution')
    x_th = np.linspace(0.01, 0.99, 500)
    y_th = 1.0 / (np.pi * np.sqrt(x_th * (1 - x_th)))
    ax.plot(x_th, y_th, 'r-', linewidth=2, label='μ(x) = 1/(π√(x(1-x)))')
    ax.set_xlabel('x')
    ax.set_ylabel('Density')
    ax.set_title('Invariant Measure (Arcsine Distribution)')
    ax.legend()
    ax.set_ylim(0, 8)

    plt.suptitle('Logistic Map: Chaos as Cryptography', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('viz_orbits.png', dpi=150, bbox_inches='tight')
    print("Saved viz_orbits.png")


if __name__ == "__main__":
    plot_sensitivity()
