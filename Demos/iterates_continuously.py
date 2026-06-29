#!/usr/bin/env python3
"""
Applications of Continuous Iteration Theory

Real-world applications demonstrating how the formally proved theorems
connect to machine learning, cryptography, and numerical analysis.
"""

import numpy as np


# ===========================================================================
# Application 1: Recurrent Neural Network State Certification
# ===========================================================================
def rnn_stability_certificate():
    """
    Use iteration theory to certify stability of a simple recurrent neural network.

    A single-layer RNN computes: h_{t+1} = tanh(W @ h_t + b)
    This is f(h) = tanh(W @ h + b), a continuous self-map.

    By iterate_image_compact: if the initial states form a compact set,
    all future states remain in a compact set.

    By monotone_orbit_of_le + contractivity: if ||W|| < 1 (spectral norm),
    all orbits converge to a unique fixed point.
    """
    print("=" * 70)
    print("APPLICATION 1: RNN Stability Certificate")
    print("=" * 70)
    print()

    dim = 5
    np.random.seed(42)

    # Create a weight matrix with spectral norm < 1 (contractive)
    W_raw = np.random.randn(dim, dim)
    spectral_norm = np.linalg.norm(W_raw, ord=2)
    W = W_raw / (spectral_norm * 1.5)  # Ensure ||W|| < 1

    b = np.random.randn(dim) * 0.1

    def rnn_step(h):
        return np.tanh(W @ h + b)

    # Compute orbits from different initial conditions
    n_steps = 50
    initial_states = [np.random.randn(dim) * 3 for _ in range(5)]

    print(f"  Weight matrix spectral norm: {np.linalg.norm(W, ord=2):.4f} < 1 (contractive)")
    print(f"  Dimension: {dim}")
    print()

    fixed_point = initial_states[0].copy()
    for _ in range(200):
        fixed_point = rnn_step(fixed_point)

    print(f"  Fixed point (approx): [{', '.join(f'{v:.4f}' for v in fixed_point[:3])}...]")
    print()

    for i, h0 in enumerate(initial_states):
        h = h0.copy()
        distances = []
        for t in range(n_steps):
            distances.append(np.linalg.norm(h - fixed_point))
            h = rnn_step(h)
        print(f"  Orbit {i+1}: ||h_0 - x*|| = {distances[0]:.4f} → ||h_50 - x*|| = {distances[-1]:.2e}")

    print()
    print("  Certificate: All orbits converge to unique fixed point (contraction mapping)")
    print("  Formal basis: continuous_iterate_eval + iterate_image_compact")
    print()


# ===========================================================================
# Application 2: Cryptographic Round Function Analysis
# ===========================================================================
def crypto_round_analysis():
    """
    Analyze iteration of a simplified cryptographic round function.

    In block ciphers, the encryption is f^[n](plaintext, key) where f is
    a round function and n is the number of rounds.

    By semiconj_iterate: if two ciphers are related by a semiconjugacy h,
    then h maps all round-n states of one cipher to round-n states of the other.
    This is the formal basis for "reduction" arguments in cryptographic security proofs.
    """
    print("=" * 70)
    print("APPLICATION 2: Cryptographic Round Function Analysis")
    print("=" * 70)
    print()

    # Simplified round function: byte-level substitution + rotation
    def round_function(state):
        """Simplified round: XOR with round constant + byte rotation."""
        state = state.copy()
        # Substitution (simplified S-box)
        state = (state * 137 + 43) % 256
        # Rotation
        state = np.roll(state, 1)
        return state

    # Abstraction (semiconjugacy): project to parity
    def abstraction(state):
        """Project state to its parity vector (mod 2)."""
        return state % 2

    # Induced dynamics on the abstract space
    def abstract_round(parity):
        """Round function on the parity abstraction."""
        # This is induced by the concrete round function
        parity = (parity * 137 + 43) % 2
        parity = np.roll(parity, 1)
        return parity

    state_size = 8
    state0 = np.array([72, 101, 108, 108, 111, 33, 0, 0], dtype=np.int64)  # "Hello!"

    print(f"  Initial state: {state0}")
    print(f"  Parity: {abstraction(state0)}")
    print()

    # Verify semiconjugacy: h(f(x)) = g(h(x))
    print("  Verifying semiconjugacy: h(round(x)) = abstract_round(h(x))")
    for n_rounds in [1, 2, 5, 10]:
        concrete = state0.copy()
        for _ in range(n_rounds):
            concrete = round_function(concrete)
        h_of_fn = abstraction(concrete)

        abstract = abstraction(state0)
        for _ in range(n_rounds):
            abstract = abstract_round(abstract)

        match = np.array_equal(h_of_fn, abstract)
        print(f"    {n_rounds} rounds: h(f^[{n_rounds}](x)) = {h_of_fn}, g^[{n_rounds}](h(x)) = {abstract}, match: {match}")

    print()
    print("  The parity abstraction is a semiconjugacy: it preserves orbit structure.")
    print("  Formal basis: semiconj_iterate + semiconj_periodic_point")
    print()


# ===========================================================================
# Application 3: Dynamical Feature Extraction for Time Series
# ===========================================================================
def dynamical_feature_extraction():
    """
    Use orbit vectors as feature maps for time series classification.

    Given a dynamical system f and observed initial condition x,
    the orbit vector (x, f(x), f²(x), ..., f^[N-1](x)) is a continuous
    feature vector by continuous_orbit_vector.

    This creates a "dynamical kernel" for classification.
    """
    print("=" * 70)
    print("APPLICATION 3: Dynamical Feature Extraction for Classification")
    print("=" * 70)
    print()

    # Two classes of initial conditions lead to different orbit patterns
    N = 20

    # Class A: logistic map in periodic regime (r=3.2)
    f_periodic = lambda x: 3.2 * x * (1 - x)

    # Class B: logistic map in chaotic regime (r=3.9)
    f_chaotic = lambda x: 3.9 * x * (1 - x)

    print("  Feature extraction via orbit vectors:")
    print()

    x0 = 0.3
    orbit_A = [x0]
    orbit_B = [x0]
    for k in range(1, N):
        orbit_A.append(f_periodic(orbit_A[-1]))
        orbit_B.append(f_chaotic(orbit_B[-1]))

    orbit_A = np.array(orbit_A)
    orbit_B = np.array(orbit_B)

    print(f"  Class A (r=3.2, periodic): orbit variance = {np.var(orbit_A):.6f}")
    print(f"  Class B (r=3.9, chaotic):  orbit variance = {np.var(orbit_B):.6f}")
    print()

    # Orbit features distinguish the dynamical regimes
    features_A = {
        "mean": np.mean(orbit_A),
        "std": np.std(orbit_A),
        "max": np.max(orbit_A),
        "autocorr": np.corrcoef(orbit_A[:-1], orbit_A[1:])[0, 1],
    }
    features_B = {
        "mean": np.mean(orbit_B),
        "std": np.std(orbit_B),
        "max": np.max(orbit_B),
        "autocorr": np.corrcoef(orbit_B[:-1], orbit_B[1:])[0, 1],
    }

    print("  Orbit features:")
    for key in features_A:
        print(f"    {key:12s}: Class A = {features_A[key]:+.6f}, Class B = {features_B[key]:+.6f}")

    print()
    print("  Orbit vectors provide a principled, continuous feature map for dynamics classification.")
    print("  Formal basis: continuous_orbit_vector + iterate_image_connected")
    print()


# ===========================================================================
# Application 4: Numerical Convergence Certification
# ===========================================================================
def convergence_certification():
    """
    Use monotone orbit theory to certify convergence of iterative algorithms.

    Newton's method for sqrt(a): x_{n+1} = (x_n + a/x_n) / 2
    This is a monotone iteration (for x > sqrt(a)) with x ≥ f(x),
    so the orbit is non-increasing and bounded below by sqrt(a).
    """
    print("=" * 70)
    print("APPLICATION 4: Convergence Certification for sqrt via Newton's Method")
    print("=" * 70)
    print()

    a = 2.0
    f_newton = lambda x: (x + a / x) / 2

    x0 = 10.0  # Start well above sqrt(2)
    orbit = [x0]
    for _ in range(15):
        orbit.append(f_newton(orbit[-1]))

    print(f"  Computing sqrt({a}) via Newton iteration: x ↦ (x + {a}/x) / 2")
    print(f"  Starting point: x₀ = {x0}")
    print()

    exact = np.sqrt(a)
    for i, x in enumerate(orbit):
        error = abs(x - exact)
        monotone = "≥" if i == 0 or orbit[i] <= orbit[i - 1] + 1e-15 else "NOT ≥"
        print(f"  n={i:2d}: x = {x:.15f}, error = {error:.2e}, x_{i} {monotone} x_{i+1 if i < len(orbit)-1 else i}")

    print(f"\n  Exact: sqrt({a}) = {exact:.15f}")
    print(f"  Orbit is monotone non-increasing (x₀ > sqrt(a), f monotone for x > 0)")
    print(f"  Formal basis: monotone_orbit_of_le (with reversed order)")
    print()


if __name__ == "__main__":
    rnn_stability_certificate()
    crypto_round_analysis()
    dynamical_feature_extraction()
    convergence_certification()


#!/usr/bin/env python3
"""
Demonstrations of Continuous Iteration Theory

Concrete numerical examples illustrating the formally proved theorems about
continuous iteration, orbit vectors, semiconjugacy, and geometric transport.
"""

import numpy as np


def iterate(f, x, n):
    """Compute f^[n](x) by repeated application."""
    for _ in range(n):
        x = f(x)
    return x


def orbit_vector(f, x, N):
    """Compute the orbit vector (f^[0](x), f^[1](x), ..., f^[N-1](x))."""
    result = [x]
    for k in range(1, N):
        x = f(x)
        result.append(x)
    return np.array(result)


# ===========================================================================
# Demo 1: Continuity of iterates (Theorem: continuous_iterate_eval)
# ===========================================================================
print("=" * 70)
print("DEMO 1: Continuity of Iterates")
print("=" * 70)
print()
print("Theorem: If f is continuous, then f^[n] is continuous for all n.")
print("We verify numerically: nearby points stay nearby under iteration.\n")

f_affine = lambda x: 0.5 * x + 1.0  # Contracting affine map

x0 = 3.0
epsilon = 1e-6
nearby_points = [x0 - epsilon, x0, x0 + epsilon]

for n in [1, 5, 10, 20]:
    iterates = [iterate(f_affine, x, n) for x in nearby_points]
    spread = max(iterates) - min(iterates)
    print(f"  n={n:2d}: f^[n]({x0}±{epsilon}) = {iterates[1]:.10f} ± {spread/2:.2e}")

print(f"\n  Fixed point: x* = {iterate(f_affine, x0, 100):.10f} (exact: 2.0)")
print(f"  Orbit converges because |slope| = 0.5 < 1\n")


# ===========================================================================
# Demo 2: Orbit vectors as continuous feature maps (Theorem: continuous_orbit_vector)
# ===========================================================================
print("=" * 70)
print("DEMO 2: Orbit Vectors as Continuous Feature Maps")
print("=" * 70)
print()
print("Theorem: x ↦ (f^[0](x), ..., f^[N-1](x)) is continuous.\n")

N = 6
for x in [0.0, 1.0, 2.0, 3.0]:
    ov = orbit_vector(f_affine, x, N)
    print(f"  x={x:.1f}: orbit vector = [{', '.join(f'{v:.4f}' for v in ov)}]")

print(f"\n  All orbit vectors converge to [{', '.join(['2.0000']*N)}]")
print(f"  The map x ↦ orbit_vector(x) is a continuous embedding into ℝ^{N}\n")


# ===========================================================================
# Demo 3: Semiconjugacy (Theorem: semiconj_iterate)
# ===========================================================================
print("=" * 70)
print("DEMO 3: Semiconjugacy Preserves Orbit Structure")
print("=" * 70)
print()
print("Theorem: If h ∘ f = g ∘ h, then h ∘ f^[n] = g^[n] ∘ h for all n.")
print()

# f(x) = 2x, g(x) = x^2, h(x) = 2^x
# Then h(f(x)) = 2^(2x) = (2^x)^2 = g(h(x)) ✓
f = lambda x: 2 * x
g = lambda x: x ** 2
h = lambda x: 2.0 ** x

x0 = 3.0
print(f"  f(x) = 2x,  g(x) = x²,  h(x) = 2^x")
print(f"  Semiconjugacy: h(f(x)) = 2^(2x) = (2^x)² = g(h(x))\n")

for n in range(6):
    via_f = h(iterate(f, x0, n))  # h(f^[n](x))
    via_g = iterate(g, h(x0), n)  # g^[n](h(x))
    print(f"  n={n}: h(f^[{n}]({x0})) = {via_f:.6e},  g^[{n}](h({x0})) = {via_g:.6e},  equal: {np.isclose(via_f, via_g)}")

print()


# ===========================================================================
# Demo 4: Compactness transport (Theorem: iterate_image_compact)
# ===========================================================================
print("=" * 70)
print("DEMO 4: Iteration Preserves Compactness")
print("=" * 70)
print()
print("Theorem: If s is compact and f continuous, then f^[n](s) is compact.\n")

f_contract = lambda x: 0.7 * np.sin(x) + 0.5

# Start with interval [0, 3] (compact in ℝ)
s = np.linspace(0, 3, 1000)

for n in [0, 1, 3, 5, 10, 20]:
    image = s.copy()
    for _ in range(n):
        image = f_contract(image)
    print(f"  n={n:2d}: f^[n]([0,3]) ⊂ [{image.min():.6f}, {image.max():.6f}]  (diameter: {image.max()-image.min():.6f})")

print(f"\n  The images remain compact (bounded closed intervals) and shrink to the fixed point.\n")


# ===========================================================================
# Demo 5: Connectedness transport (Theorem: iterate_image_connected)
# ===========================================================================
print("=" * 70)
print("DEMO 5: Iteration Preserves Connectedness")
print("=" * 70)
print()
print("Theorem: If s is connected and f continuous, then f^[n](s) is connected.\n")

# Logistic map — continuous but can stretch intervals
f_logistic = lambda x: 3.8 * x * (1 - x)
s = np.linspace(0.1, 0.3, 1000)

for n in [0, 1, 2, 3, 5, 10]:
    image = s.copy()
    for _ in range(n):
        image = f_logistic(image)
    print(f"  n={n:2d}: f^[n]([0.1,0.3]) ⊂ [{image.min():.6f}, {image.max():.6f}]")

print(f"\n  Image of a connected set under a continuous map stays connected.\n")


# ===========================================================================
# Demo 6: Commuting maps transfer (Theorems: commute_iterate_apply, image_iterate_of_commute)
# ===========================================================================
print("=" * 70)
print("DEMO 6: Commuting Maps Transfer Through Iteration")
print("=" * 70)
print()
print("Theorem: If f ∘ g = g ∘ f, then g ∘ f^[n] = f^[n] ∘ g for all n.\n")

# f(x) = x + 1, g(x) = x + π — commuting translations
import math
f_trans = lambda x: x + 1
g_trans = lambda x: x + math.pi

x0 = 2.5
for n in range(6):
    gfn = g_trans(iterate(f_trans, x0, n))
    fng = iterate(f_trans, g_trans(x0), n)
    print(f"  n={n}: g(f^[{n}]({x0})) = {gfn:.10f},  f^[{n}](g({x0})) = {fng:.10f},  equal: {np.isclose(gfn, fng)}")


# ===========================================================================
# Demo 7: Fixed/periodic point transfer (Theorems: semiconj_fixed_point, semiconj_periodic_point)
# ===========================================================================
print()
print("=" * 70)
print("DEMO 7: Semiconjugacy Transfers Fixed and Periodic Points")
print("=" * 70)
print()

# f(x) = -x has period 2 at any x ≠ 0
# g(x) = 1/x has period 2 at any x ≠ 0
# h(x) = e^x semiconjugates: h(f(x)) = e^(-x) = 1/e^x = g(h(x))
f_neg = lambda x: -x
g_inv = lambda x: 1.0 / x
h_exp = lambda x: np.exp(x)

x0 = 1.5
print(f"  f(x) = -x, g(x) = 1/x, h(x) = e^x")
print(f"  f has period 2: f^[2]({x0}) = {iterate(f_neg, x0, 2)}")
print(f"  h({x0}) = {h_exp(x0):.6f}")
print(f"  g^[2](h({x0})) = {iterate(g_inv, h_exp(x0), 2):.6f} = h({x0})")
print(f"  Period-2 orbit of f at {x0} maps to period-2 orbit of g at h({x0})={h_exp(x0):.6f}")


# ===========================================================================
# Demo 8: Monotone orbits (Theorem: monotone_orbit_of_le)
# ===========================================================================
print()
print("=" * 70)
print("DEMO 8: Monotone Orbits")
print("=" * 70)
print()
print("Theorem: If f is monotone and x ≤ f(x), then the orbit is non-decreasing.\n")

f_mono = lambda x: 0.5 * x + 1.0  # Monotone, with x ≤ f(x) when x ≤ 2
x0 = 0.0
orbit = orbit_vector(f_mono, x0, 15)
print(f"  f(x) = 0.5x + 1, x₀ = {x0}")
print(f"  Orbit: [{', '.join(f'{v:.4f}' for v in orbit)}]")
print(f"  Monotone non-decreasing: {all(orbit[i] <= orbit[i+1] for i in range(len(orbit)-1))}")
print(f"  Converges to fixed point x* = 2.0\n")


# ===========================================================================
# Demo 9: Orbit closure forward-invariance (Theorem: mapsTo_closure_orbit)
# ===========================================================================
print("=" * 70)
print("DEMO 9: Orbit Closure is Forward-Invariant")
print("=" * 70)
print()
print("Theorem: f maps closure(orbit(x)) into itself.\n")

# Rotation by golden ratio angle on [0,1) mod 1
golden = (math.sqrt(5) - 1) / 2
f_rot = lambda x: (x + golden) % 1.0

x0 = 0.0
orbit_pts = [iterate(f_rot, x0, n) for n in range(50)]
print(f"  f(x) = (x + φ) mod 1,  where φ = (√5-1)/2 ≈ {golden:.6f}")
print(f"  First 10 orbit points: [{', '.join(f'{v:.4f}' for v in orbit_pts[:10])}]")
print(f"  Orbit is dense in [0,1), so closure = [0,1)")
print(f"  f maps [0,1) → [0,1), confirming forward-invariance of closure.\n")

print("=" * 70)
print("All demonstrations complete.")
print("=" * 70)


#!/usr/bin/env python3
"""
Visualizations for Continuous Iteration Theory.
Generates publication-quality figures as PNG files.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec
import base64
import json
import io


def iterate(f, x, n):
    for _ in range(n):
        x = f(x)
    return x


def orbit_vector(f, x, N):
    result = [x]
    for k in range(1, N):
        x = f(x)
        result.append(x)
    return np.array(result)


def fig_to_base64(fig):
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    return "data:image/png;base64," + base64.b64encode(buf.read()).decode('utf-8')


def viz_orbit_convergence():
    """Visualize orbit convergence for different initial conditions."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Left: Contracting map
    f = lambda x: 0.5 * x + 1.0
    N = 25
    colors = plt.cm.viridis(np.linspace(0, 1, 6))

    ax = axes[0]
    for i, x0 in enumerate([-2, 0, 1, 2, 3, 5]):
        orbit = orbit_vector(f, x0, N)
        ax.plot(range(N), orbit, 'o-', color=colors[i], markersize=3, label=f'x₀={x0}', alpha=0.8)
    ax.axhline(y=2.0, color='red', linestyle='--', alpha=0.5, label='Fixed point x*=2')
    ax.set_xlabel('Iteration n', fontsize=12)
    ax.set_ylabel('f^[n](x)', fontsize=12)
    ax.set_title('Contracting Map: f(x) = 0.5x + 1', fontsize=13)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Right: Logistic map (chaotic)
    f_log = lambda x: 3.9 * x * (1 - x)
    ax = axes[1]
    for i, x0 in enumerate([0.1, 0.1001, 0.1002, 0.1003]):
        orbit = orbit_vector(f_log, x0, 50)
        ax.plot(range(50), orbit, '-', alpha=0.7, linewidth=1, label=f'x₀={x0}')
    ax.set_xlabel('Iteration n', fontsize=12)
    ax.set_ylabel('f^[n](x)', fontsize=12)
    ax.set_title('Sensitive Dependence: f(x) = 3.9x(1-x)', fontsize=13)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    fig.suptitle('Orbit Behavior Under Continuous Iteration', fontsize=15, y=1.02)
    plt.tight_layout()
    fig.savefig('viz_orbit_convergence.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


def viz_orbit_vector_embedding():
    """Visualize orbit vectors as points in product space."""
    fig = plt.figure(figsize=(12, 5))

    # 2D orbit vector: (f^[0](x), f^[1](x))
    ax1 = fig.add_subplot(121)
    f = lambda x: 3.5 * x * (1 - x)
    xs = np.linspace(0.01, 0.99, 500)
    pts = np.array([(x, f(x)) for x in xs])
    ax1.scatter(pts[:, 0], pts[:, 1], c=xs, cmap='plasma', s=3, alpha=0.8)
    ax1.plot([0, 1], [0, 1], 'k--', alpha=0.3, label='y=x')
    ax1.set_xlabel('x = f^[0](x)', fontsize=12)
    ax1.set_ylabel('f^[1](x)', fontsize=12)
    ax1.set_title('2D Orbit Vector: x ↦ (x, f(x))', fontsize=13)
    ax1.set_aspect('equal')
    ax1.grid(True, alpha=0.3)

    # 3D orbit vector
    ax2 = fig.add_subplot(122, projection='3d')
    xs = np.linspace(0.01, 0.99, 2000)
    pts3d = np.array([(x, f(x), f(f(x))) for x in xs])
    ax2.scatter(pts3d[:, 0], pts3d[:, 1], pts3d[:, 2], c=xs, cmap='plasma', s=1, alpha=0.5)
    ax2.set_xlabel('f^[0](x)', fontsize=10)
    ax2.set_ylabel('f^[1](x)', fontsize=10)
    ax2.set_zlabel('f^[2](x)', fontsize=10)
    ax2.set_title('3D Orbit Vector Embedding', fontsize=13)

    fig.suptitle('Orbit Vectors as Continuous Embeddings into Product Spaces', fontsize=15, y=1.02)
    plt.tight_layout()
    fig.savefig('viz_orbit_embedding.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


def viz_compactness_transport():
    """Visualize how iteration shrinks compact sets."""
    fig, ax = plt.subplots(figsize=(10, 6))

    f = lambda x: 0.7 * np.sin(x) + 0.5
    s = np.linspace(0, 3, 1000)

    iterations = [0, 1, 2, 3, 5, 10, 20]
    colors = plt.cm.coolwarm(np.linspace(0, 1, len(iterations)))

    for idx, n in enumerate(iterations):
        image = s.copy()
        for _ in range(n):
            image = f(image)
        lo, hi = image.min(), image.max()
        ax.barh(idx, hi - lo, left=lo, height=0.7, color=colors[idx], alpha=0.7, edgecolor='black')
        ax.text(hi + 0.02, idx, f'n={n}: [{lo:.3f}, {hi:.3f}]', va='center', fontsize=10)

    ax.set_yticks(range(len(iterations)))
    ax.set_yticklabels([f'n={n}' for n in iterations])
    ax.set_xlabel('x', fontsize=12)
    ax.set_title('Compactness Transport: f^[n]([0,3]) Remains Compact and Shrinks', fontsize=14)
    ax.grid(True, alpha=0.3, axis='x')

    plt.tight_layout()
    fig.savefig('viz_compactness.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


def viz_semiconjugacy():
    """Visualize semiconjugacy orbit transfer."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # f(x)=2x, g(x)=x², h(x)=2^x
    f = lambda x: 2 * x
    g = lambda x: x ** 2
    h = lambda x: 2.0 ** x

    x0 = 1.0
    N = 8

    # f-orbit
    ax = axes[0]
    f_orbit = orbit_vector(f, x0, N)
    h_f_orbit = np.array([h(v) for v in f_orbit])
    g_orbit = orbit_vector(g, h(x0), N)

    ax.plot(range(N), f_orbit, 'bo-', markersize=6, label=f'f-orbit of {x0}')
    ax.plot(range(N), h_f_orbit, 'r^-', markersize=6, label=f'h(f-orbit)')
    ax.plot(range(N), g_orbit, 'gs--', markersize=6, label=f'g-orbit of h({x0})={h(x0)}')
    ax.set_xlabel('Iteration n', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title('Semiconjugacy: h ∘ f^[n] = g^[n] ∘ h', fontsize=13)
    ax.legend(fontsize=10)
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)

    # Commutative diagram visualization
    ax = axes[1]
    ax.set_xlim(-0.5, 4.5)
    ax.set_ylim(-0.5, 3.5)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Commutative Diagram of Semiconjugacy', fontsize=13)

    # Nodes
    positions = {
        'x': (0, 3), 'fx': (2, 3), 'f2x': (4, 3),
        'hx': (0, 0), 'ghx': (2, 0), 'g2hx': (4, 0),
    }
    labels = {
        'x': 'x', 'fx': 'f(x)', 'f2x': 'f²(x)',
        'hx': 'h(x)', 'ghx': 'g(h(x))', 'g2hx': 'g²(h(x))',
    }

    for key, (px, py) in positions.items():
        ax.plot(px, py, 'ko', markersize=8)
        offset = 0.25
        ax.text(px, py + offset, labels[key], ha='center', va='bottom', fontsize=11, fontweight='bold')

    # Arrows
    arrow_props = dict(arrowstyle='->', color='blue', lw=2)
    for (s, e, label, color) in [
        ('x', 'fx', 'f', 'blue'), ('fx', 'f2x', 'f', 'blue'),
        ('hx', 'ghx', 'g', 'green'), ('ghx', 'g2hx', 'g', 'green'),
        ('x', 'hx', 'h', 'red'), ('fx', 'ghx', 'h', 'red'), ('f2x', 'g2hx', 'h', 'red'),
    ]:
        sx, sy = positions[s]
        ex, ey = positions[e]
        ax.annotate('', xy=(ex, ey), xytext=(sx, sy),
                     arrowprops=dict(arrowstyle='->', color=color, lw=2))
        mx, my = (sx + ex) / 2, (sy + ey) / 2
        offset = 0.2 if sy == ey else 0.15
        if sy == ey:
            ax.text(mx, my + offset, label, ha='center', fontsize=11, color=color, fontweight='bold')
        else:
            ax.text(mx - offset, my, label, ha='center', fontsize=11, color=color, fontweight='bold')

    plt.tight_layout()
    fig.savefig('viz_semiconjugacy.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


def viz_monotone_orbit():
    """Visualize monotone orbit convergence."""
    fig, ax = plt.subplots(figsize=(10, 6))

    # f(x) = sqrt(x + 1), monotone, x≤f(x) for x≤golden ratio
    f = lambda x: np.sqrt(x + 1)

    colors = plt.cm.Set2(np.linspace(0, 1, 5))
    for i, x0 in enumerate([0.0, 0.3, 0.5, 0.8, 1.0]):
        orbit = orbit_vector(f, x0, 20)
        ax.plot(range(20), orbit, 'o-', color=colors[i], markersize=4, label=f'x₀={x0}')

    # Fixed point: x = sqrt(x+1) => x² = x+1 => x = (1+sqrt(5))/2
    fp = (1 + np.sqrt(5)) / 2
    ax.axhline(y=fp, color='red', linestyle='--', alpha=0.5, label=f'Fixed point φ ≈ {fp:.4f}')

    ax.set_xlabel('Iteration n', fontsize=12)
    ax.set_ylabel('f^[n](x)', fontsize=12)
    ax.set_title('Monotone Orbit Convergence: f(x) = √(x+1)', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    fig.savefig('viz_monotone.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


if __name__ == "__main__":
    print("Generating visualizations...")
    b64_orbit = viz_orbit_convergence()
    b64_embedding = viz_orbit_vector_embedding()
    b64_compact = viz_compactness_transport()
    b64_semiconj = viz_semiconjugacy()
    b64_monotone = viz_monotone_orbit()

    # Save base64 data for JSON package
    viz_data = {
        "orbit_convergence": b64_orbit,
        "orbit_embedding": b64_embedding,
        "compactness_transport": b64_compact,
        "semiconjugacy": b64_semiconj,
        "monotone_orbit": b64_monotone,
    }

    with open('viz_data.json', 'w') as f:
        json.dump(viz_data, f)

    print("All visualizations saved.")
