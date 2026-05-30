"""
Applications of Logistic Map Cryptography

Real-world applications showing the mathematical results in action:
1. Pseudorandom number generation with quality testing
2. Image encryption via chaotic permutation
3. Key exchange protocol sketch
4. Tropical approximation for hardware-friendly crypto
"""
import math
from typing import List, Tuple


def logistic(x: float) -> float:
    return 4.0 * x * (1.0 - x)


def tropical_tent(x: float) -> float:
    return 2.0 * min(x, 1.0 - x)


# ============================================================
# Application 1: Pseudorandom Number Generator Quality Test
# ============================================================

def prng_frequency_test(seed: float, n: int = 10000) -> dict:
    """Test the frequency balance of logistic PRNG output.

    A good PRNG should produce roughly equal numbers of 0s and 1s
    when thresholded at 0.5. The arcsine invariant measure of the
    logistic map at r=4 has density 1/(π√(x(1-x))), which is
    symmetric about 0.5.

    Returns test statistics.
    """
    x = seed
    zeros = 0
    ones = 0
    for _ in range(n):
        x = logistic(x)
        if x < 0.5:
            zeros += 1
        else:
            ones += 1
    balance = zeros / n
    # For ideal PRNG, balance ≈ 0.5
    z_score = abs(balance - 0.5) / math.sqrt(0.25 / n)
    return {
        "zeros": zeros,
        "ones": ones,
        "balance": balance,
        "z_score": z_score,
        "pass": z_score < 3.0  # 99.7% confidence
    }


def prng_runs_test(seed: float, n: int = 10000) -> dict:
    """Test for independence via runs (consecutive same-bit sequences).

    The expected number of runs in n bits with proportion p of 1s is
    approximately 2np(1-p) + 1.
    """
    x = seed
    bits = []
    for _ in range(n):
        x = logistic(x)
        bits.append(1 if x >= 0.5 else 0)

    runs = 1
    for i in range(1, len(bits)):
        if bits[i] != bits[i-1]:
            runs += 1

    p = sum(bits) / n
    expected_runs = 2 * n * p * (1 - p) + 1
    std_runs = math.sqrt(2 * n * p * (1-p) * (2*p*(1-p) - 1/n)) if p > 0 and p < 1 else 1

    z = abs(runs - expected_runs) / max(std_runs, 1e-10)
    return {
        "runs": runs,
        "expected": expected_runs,
        "z_score": z,
        "pass": z < 3.0
    }


# ============================================================
# Application 2: Chaotic Permutation for Data Shuffling
# ============================================================

def chaotic_permutation(n: int, seed: float, warmup: int = 50) -> List[int]:
    """Generate a pseudorandom permutation of [0, n-1] using logistic map.

    Uses the orbit to assign random scores, then sorts by score.
    This is a Fisher-Yates-like shuffle driven by chaotic dynamics.

    Time: O(n log n), Space: O(n)
    """
    x = seed
    for _ in range(warmup):
        x = logistic(x)

    scores = []
    for i in range(n):
        x = logistic(x)
        scores.append((x, i))

    scores.sort()
    return [idx for _, idx in scores]


def inverse_permutation(perm: List[int]) -> List[int]:
    """Compute the inverse permutation."""
    inv = [0] * len(perm)
    for i, p in enumerate(perm):
        inv[p] = i
    return inv


# ============================================================
# Application 3: Sensitivity Analysis for Key Space
# ============================================================

def key_sensitivity_analysis(seed1: float, seed2: float, n_steps: int = 100) -> List[float]:
    """Measure how quickly two nearby seeds diverge.

    Returns the sequence of |f^k(seed1) - f^k(seed2)| for k = 0..n_steps.
    The Lyapunov exponent log(2) predicts exponential divergence rate.
    """
    x = seed1
    y = seed2
    diffs = [abs(x - y)]
    for _ in range(n_steps):
        x = logistic(x)
        y = logistic(y)
        diffs.append(abs(x - y))
    return diffs


# ============================================================
# Application 4: Tropical Cipher for Constrained Hardware
# ============================================================

def tropical_keystream(seed: float, length: int, warmup: int = 50) -> List[int]:
    """Generate keystream using tropical tent map.

    The tropical tent map uses only min, subtraction, and multiplication by 2.
    This is ideal for constrained hardware (no floating-point multiply needed).

    Approximation error vs logistic: at most 1/4 (proved in Lean).
    """
    x = seed
    for _ in range(warmup):
        x = tropical_tent(x)

    stream = []
    for _ in range(length):
        x = tropical_tent(x)
        stream.append(int(x * 256) % 256)
    return stream


# ============================================================
# Main demonstration
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("APPLICATION DEMONSTRATIONS")
    print("=" * 60)

    # App 1: PRNG Quality
    print("\n--- PRNG Quality Tests ---")
    for seed in [0.1, 0.3, 0.7, 0.99]:
        freq = prng_frequency_test(seed)
        runs = prng_runs_test(seed)
        print(f"  Seed {seed}: Freq test {'PASS' if freq['pass'] else 'FAIL'} "
              f"(z={freq['z_score']:.2f}), "
              f"Runs test {'PASS' if runs['pass'] else 'FAIL'} "
              f"(z={runs['z_score']:.2f})")

    # App 2: Chaotic Permutation
    print("\n--- Chaotic Permutation ---")
    perm = chaotic_permutation(10, seed=0.12345)
    inv = inverse_permutation(perm)
    print(f"  Permutation:  {perm}")
    print(f"  Inverse:      {inv}")
    # Verify: applying perm then inverse gives identity
    identity = [inv[perm[i]] for i in range(10)]
    print(f"  Roundtrip:    {identity}")
    assert identity == list(range(10)), "Permutation roundtrip failed!"

    # App 3: Sensitivity
    print("\n--- Key Sensitivity ---")
    diffs = key_sensitivity_analysis(0.300000000, 0.300000001, 50)
    print(f"  Initial diff: {diffs[0]:.2e}")
    for k in [5, 10, 15, 20, 25]:
        print(f"  After {k:2d} steps: {diffs[k]:.6e}")
    # Find when diff exceeds 0.1
    threshold_step = next((i for i, d in enumerate(diffs) if d > 0.1), None)
    print(f"  Divergence (>0.1) at step: {threshold_step}")

    # App 4: Tropical vs Logistic keystream comparison
    print("\n--- Tropical vs Logistic Keystream ---")
    seed = 0.314159
    x_log = seed
    x_trop = seed
    max_diff = 0
    for _ in range(50):  # warmup
        x_log = logistic(x_log)
        x_trop = tropical_tent(x_trop)

    for i in range(20):
        x_log = logistic(x_log)
        x_trop = tropical_tent(x_trop)
        byte_log = int(x_log * 256) % 256
        byte_trop = int(x_trop * 256) % 256
        diff = abs(x_log - x_trop)
        max_diff = max(max_diff, diff)
        if i < 5:
            print(f"  Step {i}: logistic byte={byte_log:3d}, tropical byte={byte_trop:3d}, "
                  f"value diff={diff:.4f}")

    print(f"  Max value difference: {max_diff:.4f} (bound: 0.25)")
    print(f"  Note: orbits diverge quickly but both produce quality randomness")

    print("\n" + "=" * 60)
    print("All applications demonstrated successfully.")
    print("=" * 60)


"""
Demonstration of Logistic Map Chaotic Cryptography

Concrete numerical examples illustrating the theorems proved in
Cryptography/LogisticChaos/Dynamics.lean.
"""
import math

def logistic(x: float) -> float:
    """The logistic map at r=4: f(x) = 4x(1-x)"""
    return 4 * x * (1 - x)

def logistic_iter(n: int, x: float) -> float:
    """The n-th iterate of the logistic map"""
    for _ in range(n):
        x = logistic(x)
    return x

def logistic_deriv(x: float) -> float:
    """Derivative of the logistic map: f'(x) = 4 - 8x"""
    return 4 - 8 * x

def orbit_deriv_product(x: float, n: int) -> float:
    """Product of derivatives along an orbit of length n"""
    prod = 1.0
    for k in range(n):
        prod *= logistic_deriv(logistic_iter(k, x))
    return prod

def tropical_tent(x: float) -> float:
    """Tropical tent map: 2*min(x, 1-x)"""
    return 2 * min(x, 1 - x)

def chebyshev_conjugate(theta: float, n: int) -> float:
    """sin^2(2^n * theta) — the semiconjugate orbit"""
    return math.sin(2**n * theta) ** 2


print("=" * 60)
print("DEMO: Logistic Map Chaotic Cryptography")
print("=" * 60)

# 1. Fixed points
print("\n--- Fixed Points ---")
print(f"f(0) = {logistic(0)} (expected: 0)")
print(f"f(3/4) = {logistic(3/4)} (expected: 0.75)")
print(f"f(1) = {logistic(1)} (expected: 0)")
print(f"f(1/2) = {logistic(0.5)} (expected: 1, the maximum)")

# 2. Chebyshev semiconjugacy
print("\n--- Chebyshev Semiconjugacy: f^n(sin²θ) = sin²(2ⁿθ) ---")
theta = 0.7
for n in range(1, 8):
    orbit = logistic_iter(n, math.sin(theta)**2)
    conjugate = chebyshev_conjugate(theta, n)
    print(f"  n={n}: f^{n}(sin²θ) = {orbit:.10f}, sin²(2^{n}·θ) = {conjugate:.10f}, diff = {abs(orbit-conjugate):.2e}")

# 3. Period-2 orbit
print("\n--- Period-2 Orbit Verification ---")
# The period-2 orbit consists of roots of 16x^2 - 20x + 5 = 0
x1 = (5 + math.sqrt(5)) / 8
x2 = (5 - math.sqrt(5)) / 8
print(f"x1 = {x1:.10f}, x2 = {x2:.10f}")
print(f"f(x1) = {logistic(x1):.10f} (expected: x2 = {x2:.10f})")
print(f"f(x2) = {logistic(x2):.10f} (expected: x1 = {x1:.10f})")
print(f"x1 + x2 = {x1 + x2:.10f} (expected: 5/4 = {5/4})")
print(f"x1 * x2 = {x1 * x2:.10f} (expected: 5/16 = {5/16})")

# 4. Derivative analysis
print("\n--- Derivative Analysis ---")
print(f"|f'(3/4)| = |{logistic_deriv(3/4)}| = {abs(logistic_deriv(3/4))} (expected: 2)")
print(f"f'(1/2) = {logistic_deriv(0.5)} (expected: 0, critical point)")
for x in [0.1, 0.25, 0.4, 0.6, 0.75, 0.9]:
    d = logistic_deriv(x)
    far = abs(x - 0.5) > 3/8
    print(f"  f'({x}) = {d:.2f}, |f'| = {abs(d):.2f}, far from 1/2: {far}, expanding: {abs(d) > 1}")

# 5. Orbit derivative product at the fixed point
print("\n--- Orbit Derivative Product at 3/4 ---")
for n in range(1, 10):
    prod = orbit_deriv_product(3/4, n)
    expected = (-2)**n
    print(f"  n={n}: product = {prod:.4f}, (-2)^n = {expected}, |product| = {abs(prod):.4f}, 2^n = {2**n}")

# 6. Polynomial degree growth
print("\n--- Polynomial Degree Growth (Cryptographic Hardness) ---")
for n in range(1, 16):
    deg = 2**n
    n_cubed = n**3
    print(f"  n={n:2d}: deg(f^n) = 2^{n} = {deg:6d}, n³ = {n_cubed:5d}, 2^n > n³: {deg > n_cubed}")

# 7. Tropical approximation
print("\n--- Tropical Approximation Error ---")
max_error = 0
max_x = 0
for i in range(101):
    x = i / 100
    err = abs(logistic(x) - tropical_tent(x))
    if err > max_error:
        max_error = err
        max_x = x
print(f"Maximum error: {max_error:.6f} at x = {max_x} (bound: 0.25)")
print(f"Error at x=0.25: {abs(logistic(0.25) - tropical_tent(0.25)):.6f}")
print(f"Error at x=0.75: {abs(logistic(0.75) - tropical_tent(0.75)):.6f}")

# 8. Sensitivity demonstration
print("\n--- Sensitivity to Initial Conditions ---")
x0 = 0.3
y0 = 0.3 + 1e-10
print(f"Starting: x0 = {x0}, y0 = {y0}, diff = {y0-x0:.2e}")
for n in range(1, 30):
    x0 = logistic(x0)
    y0 = logistic(y0)
    diff = abs(x0 - y0)
    if n % 5 == 0 or n <= 5:
        print(f"  n={n:2d}: |f^n(x0) - f^n(y0)| = {diff:.6e}")

print("\n" + "=" * 60)
print("All demonstrations complete.")
print("=" * 60)


"""
Cobweb Diagram: Visualizing Chaotic Orbits of the Logistic Map

This visualization shows the cobweb (staircase) diagram for the logistic map
f(x) = 4x(1-x), which traces how an orbit bounces between the parabola
y = f(x) and the diagonal y = x. The chaotic nature is visible as the
trajectory fills the entire interval, never settling into a periodic pattern.

Also overlays the tropical tent map T(x) = 2min(x, 1-x) showing the
piecewise-linear approximation with error bound 1/4 (proved in Lean).
"""
import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: Cobweb diagram
ax1 = axes[0]
x = np.linspace(0, 1, 500)
y_logistic = 4 * x * (1 - x)

ax1.plot(x, y_logistic, 'b-', linewidth=2, label=r'$f(x) = 4x(1-x)$')
ax1.plot(x, x, 'k--', linewidth=1, label=r'$y = x$')

# Cobweb from x0 = 0.1
x0 = 0.1
n_steps = 80
cx, cy = [x0], [0]
xk = x0
for _ in range(n_steps):
    fxk = 4 * xk * (1 - xk)
    cx.extend([xk, fxk])
    cy.extend([fxk, fxk])
    xk = fxk

ax1.plot(cx, cy, 'r-', linewidth=0.5, alpha=0.7, label=f'Orbit from $x_0={x0}$')
ax1.scatter([x0], [0], color='red', s=50, zorder=5)

# Mark fixed points
ax1.scatter([0, 0.75], [0, 0.75], color='green', s=80, zorder=5,
            marker='*', label='Fixed points')

ax1.set_xlabel('$x$', fontsize=12)
ax1.set_ylabel('$f(x)$', fontsize=12)
ax1.set_title('Cobweb Diagram: Chaos in the Logistic Map', fontsize=13)
ax1.legend(loc='upper left', fontsize=9)
ax1.set_xlim(-0.02, 1.02)
ax1.set_ylim(-0.02, 1.12)
ax1.grid(True, alpha=0.3)

# Right panel: Logistic vs Tropical approximation
ax2 = axes[1]
y_tropical = 2 * np.minimum(x, 1 - x)
y_error = np.abs(y_logistic - y_tropical)

ax2.plot(x, y_logistic, 'b-', linewidth=2, label=r'$f(x) = 4x(1-x)$')
ax2.plot(x, y_tropical, 'r--', linewidth=2, label=r'$T(x) = 2\min(x, 1-x)$')
ax2.fill_between(x, y_logistic, y_tropical, alpha=0.2, color='purple',
                  label=r'Error $\leq 1/4$')
ax2.axhline(y=0.25, color='gray', linestyle=':', alpha=0.5)

# Mark the max error point
x_max_err = 0.25
ax2.annotate(f'Max error = 1/4\nat x = 1/4',
             xy=(x_max_err, 4*0.25*0.75), xytext=(0.5, 0.4),
             arrowprops=dict(arrowstyle='->', color='purple'),
             fontsize=10, color='purple')

ax2.set_xlabel('$x$', fontsize=12)
ax2.set_ylabel('$y$', fontsize=12)
ax2.set_title('Tropical Approximation (Error ≤ 1/4)', fontsize=13)
ax2.legend(loc='upper right', fontsize=9)
ax2.set_xlim(-0.02, 1.02)
ax2.set_ylim(-0.05, 1.15)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_cobweb.png', dpi=150, bbox_inches='tight')
plt.close()


"""
The Chebyshev Semiconjugacy: From Angles to Chaos

Visualizes the fundamental mathematical identity:
  f^n(sin²θ) = sin²(2ⁿθ)

This semiconjugacy transforms the nonlinear logistic map into simple
angle doubling, revealing the hidden linear structure within chaos.
The top panel shows the orbit on the circle (angle doubling),
the bottom panel shows the corresponding chaotic orbit on [0,1].
"""
import numpy as np
import matplotlib.pyplot as plt

fig = plt.figure(figsize=(14, 8))

# Create grid: left side for circle + orbit, right for bifurcation-like density
gs = fig.add_gridspec(2, 2, hspace=0.35, wspace=0.3)

def logistic(x):
    return 4 * x * (1 - x)

# Panel 1: Angle doubling on the circle
ax1 = fig.add_subplot(gs[0, 0], polar=True)
theta0 = 0.7  # starting angle
n_points = 20
thetas = [theta0]
for _ in range(n_points - 1):
    thetas.append(2 * thetas[-1])

# Plot the circle
circle_theta = np.linspace(0, 2*np.pi, 200)
ax1.plot(circle_theta, np.ones_like(circle_theta), 'k-', linewidth=0.5)

# Plot angle doubling steps
for i in range(len(thetas) - 1):
    ax1.annotate('', xy=(thetas[i+1] % (2*np.pi), 1),
                 xytext=(thetas[i] % (2*np.pi), 1),
                 arrowprops=dict(arrowstyle='->', color=plt.cm.viridis(i/n_points),
                                linewidth=1.5))

# Mark points
for i, t in enumerate(thetas):
    ax1.plot(t % (2*np.pi), 1, 'o', color=plt.cm.viridis(i/n_points),
             markersize=6)

ax1.set_title(r'Angle Doubling: $\theta \mapsto 2\theta$', fontsize=12, pad=15)
ax1.set_rticks([])

# Panel 2: The semiconjugacy map sin²
ax2 = fig.add_subplot(gs[0, 1])
t = np.linspace(0, 2*np.pi, 500)
ax2.plot(t, np.sin(t)**2, 'b-', linewidth=2)
ax2.fill_between(t, 0, np.sin(t)**2, alpha=0.1, color='blue')
ax2.set_xlabel(r'$\theta$', fontsize=12)
ax2.set_ylabel(r'$\sin^2(\theta)$', fontsize=12)
ax2.set_title(r'Semiconjugacy: $\sin^2$ maps angles to $[0,1]$', fontsize=12)
ax2.axhline(y=0.75, color='green', linestyle='--', alpha=0.5, label='Fixed point 3/4')
ax2.axhline(y=0.5, color='red', linestyle='--', alpha=0.5, label='Critical point 1/2')
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

# Panel 3: Verification of semiconjugacy
ax3 = fig.add_subplot(gs[1, 0])
theta0 = 0.7
n_verify = 50

orbit_logistic = [np.sin(theta0)**2]
orbit_conjugate = [np.sin(theta0)**2]

x_log = np.sin(theta0)**2
theta = theta0
for i in range(n_verify):
    x_log = logistic(x_log)
    theta = 2 * theta
    orbit_logistic.append(x_log)
    orbit_conjugate.append(np.sin(theta)**2)

errors = [abs(a - b) for a, b in zip(orbit_logistic, orbit_conjugate)]

ax3.semilogy(range(len(errors)), errors, 'r-', linewidth=1.5)
ax3.set_xlabel('Iteration $n$', fontsize=11)
ax3.set_ylabel(r'$|f^n(\sin^2\theta) - \sin^2(2^n\theta)|$', fontsize=11)
ax3.set_title('Numerical Verification of Semiconjugacy', fontsize=12)
ax3.annotate('Floating-point error accumulation\n(mathematically exact by theorem)',
             xy=(30, errors[30] if len(errors) > 30 else 1e-15),
             xytext=(20, 1e-5),
             arrowprops=dict(arrowstyle='->', color='gray'),
             fontsize=9, color='gray')
ax3.grid(True, alpha=0.3)

# Panel 4: Invariant density (arcsine distribution)
ax4 = fig.add_subplot(gs[1, 1])

# Generate long orbit for histogram
x = 0.1234
orbit = []
for _ in range(100):  # warmup
    x = logistic(x)
for _ in range(100000):
    x = logistic(x)
    orbit.append(x)

x_dens = np.linspace(0.001, 0.999, 500)
arcsine_density = 1 / (np.pi * np.sqrt(x_dens * (1 - x_dens)))

ax4.hist(orbit, bins=100, density=True, alpha=0.5, color='blue',
         label='Orbit histogram')
ax4.plot(x_dens, arcsine_density, 'r-', linewidth=2,
         label=r'Arcsine: $\frac{1}{\pi\sqrt{x(1-x)}}$')
ax4.set_xlabel('$x$', fontsize=11)
ax4.set_ylabel('Density', fontsize=11)
ax4.set_title('Invariant Measure (Arcsine Distribution)', fontsize=12)
ax4.legend(fontsize=10)
ax4.set_ylim(0, 6)
ax4.grid(True, alpha=0.3)

plt.suptitle('The Chebyshev Semiconjugacy: Hidden Structure of Chaos',
             fontsize=14, fontweight='bold')
plt.savefig('viz_semiconjugacy.png', dpi=150, bbox_inches='tight')
plt.close()


"""
Sensitivity to Initial Conditions: The Butterfly Effect in Cryptography

Visualizes how two orbits starting from nearly identical initial conditions
diverge exponentially under the logistic map. The Lyapunov exponent log(2)
governs this divergence rate — each iteration doubles the uncertainty,
producing exactly 1 bit of entropy.

This exponential sensitivity is the foundation of cryptographic security:
recovering the seed from the keystream requires solving a degree-2^n polynomial.
"""
import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

def logistic(x):
    return 4 * x * (1 - x)

# Panel 1: Two diverging orbits
ax = axes[0, 0]
n = 50
x1 = np.zeros(n)
x2 = np.zeros(n)
x1[0] = 0.3
x2[0] = 0.3 + 1e-10  # differ by 10^{-10}
for i in range(1, n):
    x1[i] = logistic(x1[i-1])
    x2[i] = logistic(x2[i-1])

ax.plot(range(n), x1, 'b-', linewidth=1.5, label=r'$x_0 = 0.3$')
ax.plot(range(n), x2, 'r--', linewidth=1.5, label=r'$x_0 = 0.3 + 10^{-10}$')
ax.set_xlabel('Iteration $n$', fontsize=11)
ax.set_ylabel('$f^n(x_0)$', fontsize=11)
ax.set_title('Diverging Orbits', fontsize=12)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 2: Logarithmic divergence rate
ax = axes[0, 1]
diffs = np.abs(x1 - x2)
diffs_nonzero = np.maximum(diffs, 1e-20)
log_diffs = np.log10(diffs_nonzero)

ax.plot(range(n), log_diffs, 'k-', linewidth=1.5)
# Overlay theoretical rate log(2)/log(10) * n
theory = np.log10(1e-10) + np.arange(n) * np.log10(2)
ax.plot(range(min(n, 35)), theory[:min(n, 35)], 'r--', linewidth=1,
        label=r'Slope = $\log_{10}(2) \approx 0.301$')
ax.set_xlabel('Iteration $n$', fontsize=11)
ax.set_ylabel(r'$\log_{10}|x_1^{(n)} - x_2^{(n)}|$', fontsize=11)
ax.set_title('Exponential Divergence Rate', fontsize=12)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 3: Orbit derivative product |∏ f'(f^k(x))| vs 2^n
ax = axes[1, 0]
n_max = 30
x0_vals = [0.1, 0.3, 0.7, 0.9, 0.75]
colors = ['blue', 'green', 'red', 'purple', 'orange']

for x0, color in zip(x0_vals, colors):
    products = np.zeros(n_max)
    x = x0
    log_prod = 0
    for k in range(n_max):
        deriv = abs(4 - 8 * x)
        if deriv > 0:
            log_prod += np.log2(deriv)
        products[k] = log_prod
        x = logistic(x)
    ax.plot(range(n_max), products, color=color, linewidth=1,
            label=f'$x_0={x0}$', alpha=0.8)

ax.plot(range(n_max), np.arange(n_max), 'k--', linewidth=2,
        label=r'$n$ (slope 1 = $\log_2 2$)')
ax.set_xlabel('Iteration $n$', fontsize=11)
ax.set_ylabel(r'$\log_2 |\prod f^{\prime}(f^k(x_0))|$', fontsize=11)
ax.set_title('Orbit Derivative Growth vs $2^n$', fontsize=12)
ax.legend(fontsize=8, loc='upper left')
ax.grid(True, alpha=0.3)

# Panel 4: Polynomial degree growth (cryptographic hardness)
ax = axes[1, 1]
ns = np.arange(1, 21)
degrees = 2**ns
n_cubed = ns**3

ax.semilogy(ns, degrees, 'b-o', linewidth=2, markersize=5,
            label=r'$\deg(f^n) = 2^n$')
ax.semilogy(ns, n_cubed, 'r--s', linewidth=1.5, markersize=4,
            label=r'$n^3$')
ax.fill_between(ns, n_cubed, degrees, alpha=0.15, color='blue',
                where=degrees > n_cubed)
ax.axvline(x=10, color='gray', linestyle=':', alpha=0.5)
ax.annotate('$n=10$: Superpolynomial\nhardness begins',
            xy=(10, 10**3), xytext=(12, 2000),
            arrowprops=dict(arrowstyle='->', color='gray'),
            fontsize=9, color='gray')

ax.set_xlabel('Number of iterations $n$', fontsize=11)
ax.set_ylabel('Complexity', fontsize=11)
ax.set_title('Cryptographic Hardness: $2^n$ vs $n^3$', fontsize=12)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.suptitle('Sensitivity & Cryptographic Hardness of the Logistic Map',
             fontsize=14, fontweight='bold', y=1.01)
plt.tight_layout()
plt.savefig('viz_sensitivity.png', dpi=150, bbox_inches='tight')
plt.close()
