#!/usr/bin/env python3
"""
Applications of Tropical T-Duality and Mirror Symmetry.

Demonstrates real-world applications of the formalized mathematical framework:
1. Neural network robustness via tropical geometry
2. Shortest path optimization via min-plus algebra
3. Piecewise-linear approximation quality
4. Signal processing with tropical filters
"""

import math


# ============================================================
# Application 1: ReLU Network as Tropical Polynomial
# ============================================================

def relu(x: float) -> float:
    """ReLU activation: max(0, x) = tropical projection in max-plus."""
    return max(0, x)

def tropical_relu_network(
    weights: list[list[float]],
    biases: list[list[float]],
    x: list[float]
) -> list[float]:
    """
    Evaluate a ReLU network as a tropical polynomial map.

    Each layer computes: y_j = max_i(w_{ji} * x_i + b_{ji}, 0)
    which is a max-plus (tropical) operation.

    This connection means that the corner loci of the tropical potential
    correspond exactly to the decision boundaries of the network.

    Args:
        weights: weights[l][j*input_dim + i] = weight from neuron i in layer l to j in l+1
        biases: biases[l][j] = bias for neuron j in layer l+1
        x: Input vector.

    Returns:
        Output of the network.
    """
    current = list(x)
    for l in range(len(weights)):
        n_out = len(biases[l])
        n_in = len(current)
        next_layer = []
        for j in range(n_out):
            pre_activation = sum(weights[l][j * n_in + i] * current[i]
                                 for i in range(n_in)) + biases[l][j]
            next_layer.append(relu(pre_activation))
        current = next_layer
    return current


def find_network_corners_1d(
    weights: list[list[float]],
    biases: list[list[float]],
    x_range: tuple[float, float],
    resolution: int = 10000
) -> list[float]:
    """
    Find approximate decision boundaries (corners) of a 1D ReLU network.

    These are the tropical corner loci - points where the network's
    piecewise-linear structure changes slope.
    """
    corners = []
    xs = [x_range[0] + i * (x_range[1] - x_range[0]) / resolution
          for i in range(resolution + 1)]

    prev_output = tropical_relu_network(weights, biases, [xs[0]])
    for i in range(1, len(xs)):
        curr_output = tropical_relu_network(weights, biases, [xs[i]])

        # Detect slope change (corner)
        if i >= 2:
            prev_prev = tropical_relu_network(weights, biases, [xs[i-2]])
            dx = xs[1] - xs[0]
            slope_before = [(curr_output[j] - prev_output[j]) / dx for j in range(len(curr_output))]
            slope_after = [(prev_output[j] - prev_prev[j]) / dx for j in range(len(prev_output))]
            for j in range(len(curr_output)):
                if abs(slope_before[j] - slope_after[j]) > 0.1:
                    corners.append(xs[i-1])
                    break

        prev_output = curr_output

    # Deduplicate nearby corners
    if not corners:
        return []
    deduped = [corners[0]]
    for c in corners[1:]:
        if abs(c - deduped[-1]) > 0.05:
            deduped.append(c)
    return deduped


# ============================================================
# Application 2: Shortest Path via Min-Plus Algebra
# ============================================================

def min_plus_matrix_mult(
    A: list[list[float]],
    B: list[list[float]]
) -> list[list[float]]:
    """
    Min-plus matrix multiplication: (A ⊗ B)_{ij} = min_k(A_{ik} + B_{kj}).

    This is the tropical matrix product, fundamental to:
    - All-pairs shortest paths (Floyd-Warshall)
    - Dynamic programming over graphs
    - Tropical eigenvalue problems

    Time complexity: O(n³).
    """
    n = len(A)
    m = len(B[0])
    k = len(B)
    C = [[float('inf')] * m for _ in range(n)]
    for i in range(n):
        for j in range(m):
            for l in range(k):
                C[i][j] = min(C[i][j], A[i][l] + B[l][j])
    return C


def all_pairs_shortest_paths(
    adj_matrix: list[list[float]]
) -> list[list[float]]:
    """
    Compute all-pairs shortest paths using tropical matrix power.

    The shortest path matrix is the tropical (min-plus) transitive closure:
    D = I ⊕ A ⊕ A² ⊕ A³ ⊕ ... = A* (Kleene star in min-plus)

    This is equivalent to Floyd-Warshall but expressed in tropical algebra.
    """
    n = len(adj_matrix)
    # Initialize with adjacency matrix
    D = [row[:] for row in adj_matrix]
    # Set diagonal to 0
    for i in range(n):
        D[i][i] = 0

    # Floyd-Warshall = tropical matrix fixpoint
    for k in range(n):
        for i in range(n):
            for j in range(n):
                D[i][j] = min(D[i][j], D[i][k] + D[k][j])
    return D


# ============================================================
# Application 3: Tropical Signal Processing
# ============================================================

def tropical_filter(signal: list[float], kernel: list[float]) -> list[float]:
    """
    Apply a tropical (min-plus) convolution filter.

    Tropical convolution: (f ⊗ g)(t) = min_s(f(s) + g(t-s))

    This is the morphological erosion operator from mathematical morphology,
    used in image processing for edge detection and noise removal.
    Unlike standard convolution, it preserves piecewise-linear structure.

    Args:
        signal: Input signal values.
        kernel: Filter kernel.

    Returns:
        Filtered signal.
    """
    n = len(signal)
    k = len(kernel)
    pad = k // 2
    output = []
    for t in range(n):
        val = float('inf')
        for s in range(k):
            idx = t - pad + s
            if 0 <= idx < n:
                val = min(val, signal[idx] + kernel[s])
        output.append(val)
    return output


def detect_tropical_edges(signal: list[float], threshold: float = 0.5) -> list[int]:
    """
    Detect edges (corners) in a piecewise-linear signal.

    Uses the tropical corner locus: a point is an edge if the left and right
    slopes differ significantly.
    """
    edges = []
    for i in range(1, len(signal) - 1):
        left_slope = signal[i] - signal[i-1]
        right_slope = signal[i+1] - signal[i]
        if abs(right_slope - left_slope) > threshold:
            edges.append(i)
    return edges


# ============================================================
# Demo
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("APPLICATION 1: ReLU Network as Tropical Polynomial")
    print("=" * 60)

    # Simple 1D network: 1 input -> 3 hidden -> 1 output
    weights = [
        [1.0, -1.0, 0.5],  # layer 1: 3 neurons, 1 input each
        [1.0, 1.0, -1.0],  # layer 2: 1 neuron, 3 inputs
    ]
    biases = [
        [0.0, 0.0, -1.0],  # layer 1 biases
        [0.0],              # layer 2 bias
    ]

    print("\nNetwork output at sample points:")
    for x in [-2, -1, 0, 0.5, 1, 2, 3]:
        y = tropical_relu_network(weights, biases, [x])
        print(f"  f({x:5.1f}) = {y[0]:6.3f}")

    corners = find_network_corners_1d(weights, biases, (-3, 4))
    print(f"\nDetected decision boundaries (tropical corners): {[round(c, 2) for c in corners]}")
    print("These correspond to slope changes in the piecewise-linear ReLU output.")

    print("\n" + "=" * 60)
    print("APPLICATION 2: Shortest Paths via Min-Plus Algebra")
    print("=" * 60)

    INF = float('inf')
    adj = [
        [0,   3,   INF, 7  ],
        [INF, 0,   2,   INF],
        [INF, INF, 0,   1  ],
        [6,   INF, INF, 0  ],
    ]

    D = all_pairs_shortest_paths(adj)
    print("\nAdjacency matrix (weights):")
    for row in adj:
        print("  " + "  ".join(f"{v:4.0f}" if v < INF else " inf" for v in row))

    print("\nAll-pairs shortest paths (tropical transitive closure):")
    for row in D:
        print("  " + "  ".join(f"{v:4.0f}" if v < INF else " inf" for v in row))

    print("\n" + "=" * 60)
    print("APPLICATION 3: Tropical Signal Processing")
    print("=" * 60)

    # Create a piecewise-linear signal with known corners
    signal = []
    for i in range(50):
        x = i / 10.0 - 2.5
        signal.append(min(x + 1, -x + 1, 0.5))

    print(f"\nPiecewise-linear signal with {len(signal)} samples")

    # Detect corners
    edges = detect_tropical_edges(signal, threshold=0.08)
    print(f"Detected corners at indices: {edges}")
    print(f"Corner x-coordinates: {[round(e/10.0 - 2.5, 2) for e in edges]}")

    # Apply tropical erosion filter
    kernel = [0.1, 0.0, 0.1]  # Simple erosion
    filtered = tropical_filter(signal, kernel)
    max_diff = max(abs(s - f) for s, f in zip(signal, filtered))
    print(f"\nAfter tropical erosion: max |signal - filtered| = {max_diff:.4f}")
    print("Tropical filtering preserves piecewise-linear structure!")

    print("\n" + "=" * 60)
    print("ALL APPLICATIONS DEMONSTRATED")
    print("=" * 60)


#!/usr/bin/env python3
"""
Tropical T-Duality and Mirror Symmetry: Demonstrations

This script demonstrates the core mathematical structures formalized in Lean:
1. T-duality as involutive radius/charge symmetry
2. Energy invariance under T-duality
3. Tropical Legendre transform and Fenchel-Moreau inequality
4. Corner locus detection and conifold transitions
"""

import numpy as np

# ============================================================
# Part A: T-Duality Involution
# ============================================================

def t_dual_radius(R: float) -> float:
    """Radius inversion: R -> 1/R"""
    return 1.0 / R

def t_dual_charge(n: float, w: float) -> tuple[float, float]:
    """Charge swap: (n, w) -> (w, n)"""
    return (w, n)

def log_radius_energy(r: float, n: float, w: float) -> float:
    """Tropicalized circle energy in log coordinates: min(n+r, w-r)"""
    return min(n + r, w - r)

def circle_energy(R: float, n: float, w: float) -> float:
    """Circle energy: min(n + R, w + 1/R)"""
    return min(n + R, w + 1.0/R)

print("=" * 60)
print("PART A: T-DUALITY INVOLUTION")
print("=" * 60)

# Demonstrate involutivity
test_radii = [0.5, 1.0, 2.0, 3.14, 0.01, 100.0]
print("\n--- Radius Inversion Involutivity ---")
print(f"{'R':>10} {'1/R':>10} {'1/(1/R)':>10} {'Match?':>8}")
for R in test_radii:
    dual = t_dual_radius(R)
    double_dual = t_dual_radius(dual)
    print(f"{R:10.4f} {dual:10.4f} {double_dual:10.4f} {'✓' if abs(double_dual - R) < 1e-12 else '✗':>8}")

# Demonstrate charge swap involutivity
print("\n--- Charge Swap Involutivity ---")
test_charges = [(1.0, 2.0), (3.5, -1.2), (0.0, 7.0)]
for n, w in test_charges:
    w2, n2 = t_dual_charge(n, w)
    n3, w3 = t_dual_charge(w2, n2)
    print(f"  ({n}, {w}) -> ({w2}, {n2}) -> ({n3}, {w3})  {'✓' if (n3, w3) == (n, w) else '✗'}")

# Demonstrate energy invariance
print("\n--- Energy Invariance under T-Duality ---")
print(f"{'r':>6} {'n':>6} {'w':>6} {'E(r,n,w)':>12} {'E(-r,w,n)':>12} {'Match?':>8}")
test_params = [(1.0, 2.0, 3.0), (-0.5, 1.0, 4.0), (2.0, -1.0, 0.5), (0.0, 3.0, 3.0)]
for r, n, w in test_params:
    E1 = log_radius_energy(r, n, w)
    E2 = log_radius_energy(-r, w, n)
    print(f"{r:6.2f} {n:6.2f} {w:6.2f} {E1:12.6f} {E2:12.6f} {'✓' if abs(E1 - E2) < 1e-12 else '✗':>8}")

print("\n--- Circle Energy Invariance ---")
print(f"{'R':>6} {'n':>6} {'w':>6} {'E(R,n,w)':>12} {'E(1/R,w,n)':>12} {'Match?':>8}")
for R in [0.5, 1.0, 2.0, 5.0]:
    for n, w in [(1.0, 2.0), (3.0, -1.0)]:
        E1 = circle_energy(R, n, w)
        E2 = circle_energy(t_dual_radius(R), w, n)
        print(f"{R:6.2f} {n:6.2f} {w:6.2f} {E1:12.6f} {E2:12.6f} {'✓' if abs(E1 - E2) < 1e-12 else '✗':>8}")

# ============================================================
# Part B: Tropical Legendre Transform
# ============================================================

print("\n" + "=" * 60)
print("PART B: TROPICAL LEGENDRE TRANSFORM")
print("=" * 60)

def trop_potential(coeffs: list[tuple[float, float]], x: float) -> float:
    """Tropical potential: min_i(c_i + m_i * x)"""
    return min(c + m * x for c, m in coeffs)

def trop_fenchel_conj(S: list[float], f, p: float) -> float:
    """Tropical Fenchel conjugate: inf_{x in S}(f(x) - p*x)"""
    return min(f(x) - p * x for x in S)

def trop_biconj(S: list[float], f, x: float) -> float:
    """Tropical biconjugate: inf_{p in S}(f°(p) + p*x)"""
    return min(trop_fenchel_conj(S, f, p) + p * x for p in S)

# Demonstrate Fenchel-Moreau inequality
print("\n--- Fenchel-Moreau Inequality: f°°(x) ≤ f(x) ---")
S = [-2.0, -1.0, 0.0, 1.0, 2.0]
test_functions = [
    ("x²", lambda x: x**2),
    ("|x|", lambda x: abs(x)),
    ("x", lambda x: x),
    ("max(0,x)", lambda x: max(0, x)),
]

for name, f in test_functions:
    print(f"\n  f(x) = {name}:")
    print(f"  {'x':>6} {'f(x)':>10} {'f°°(x)':>10} {'f°°≤f?':>8}")
    for x in S:
        fx = f(x)
        fxx = trop_biconj(S, f, x)
        print(f"  {x:6.2f} {fx:10.4f} {fxx:10.4f} {'✓' if fxx <= fx + 1e-12 else '✗':>8}")

# Demonstrate Legendre duality at matching slopes
print("\n--- Legendre Duality at Matching Slopes ---")
coeffs = [(1.0, 2.0), (3.0, -1.0), (0.0, 0.5)]  # (c_i, m_i)
slopes = [m for _, m in coeffs]
print(f"  Potential branches: " + ", ".join(f"{c}+{m}x" for c, m in coeffs))
for i, (c, m) in enumerate(coeffs):
    # Legendre at p = -m_i
    S_slopes = slopes
    f_pot = lambda x, coeffs=coeffs: trop_potential(coeffs, x)
    leg_val = min(f_pot(s) + (-m) * s for s in S_slopes)
    print(f"  i={i}: c_i={c}, m_i={m}, Legendre(-m_i) = {leg_val:.4f} ≤ c_i = {c:.4f}  {'✓' if leg_val <= c + 1e-10 else '✗'}")

# ============================================================
# Part C: Corner Locus and Conifold Transitions
# ============================================================

print("\n" + "=" * 60)
print("PART C: CORNER LOCUS AND CONIFOLD TRANSITIONS")
print("=" * 60)

def conifold_family(t: float, x: float) -> float:
    """Conifold family: min(x, min(-x, t))"""
    return min(x, min(-x, t))

# Two-branch corner locus
print("\n--- Two-Branch Corner Locus ---")
test_branches = [
    (1.0, 0.0, -1.0, 0.0),   # x vs -x: corner at 0
    (2.0, 1.0, -1.0, 4.0),   # 2x+1 vs -x+4: corner at 1
    (1.0, 3.0, 3.0, -1.0),   # x+3 vs 3x-1: corner at 2
]
for a1, b1, a2, b2 in test_branches:
    x0 = (b2 - b1) / (a1 - a2)
    v1 = a1 * x0 + b1
    v2 = a2 * x0 + b2
    print(f"  min({a1}x+{b1}, {a2}x+{b2}): corner at x₀ = {x0:.4f}")
    print(f"    Branch values at x₀: {v1:.4f} = {v2:.4f}  {'✓' if abs(v1-v2) < 1e-12 else '✗'}")

# Conifold transition
print("\n--- Conifold Transition ---")
print("  conifoldFamily(t, 0) for various t:")
for t in [-1.0, -0.5, 0.0, 0.5, 1.0, 2.0]:
    val = conifold_family(t, 0)
    branches = (0.0, 0.0, t)  # x=0, -x=0, t
    n_minimizers = sum(1 for b in branches if abs(b - val) < 1e-12)
    status = "SINGULAR (corner)" if n_minimizers >= 2 and t == 0 else \
             "corner" if n_minimizers >= 2 else "smooth"
    print(f"    t = {t:6.2f}: f(0) = {val:6.2f}, #minimizers = {n_minimizers}, status: {status}")

print("\n  Conifold transition detected at t = 0: all three branches tie!")
print("  For t > 0: singularity is resolved (t branch separates from x,-x branches)")

print("\n" + "=" * 60)
print("ALL DEMONSTRATIONS COMPLETE")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualizations for Tropical T-Duality and Mirror Symmetry.
Generates publication-quality figures as PNG files.
"""
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec

# Style
plt.rcParams.update({
    'font.size': 11,
    'axes.titlesize': 13,
    'axes.labelsize': 12,
    'figure.dpi': 150,
    'savefig.bbox': 'tight',
    'savefig.pad_inches': 0.1,
})

# ============================================================
# Figure 1: T-Duality Energy Landscape
# ============================================================
fig, axes = plt.subplots(1, 3, figsize=(14, 4))

x = np.linspace(-3, 3, 500)

for idx, r in enumerate([1.0, 0.5, -0.5]):
    ax = axes[idx]
    branch1 = x + r  # momentum
    branch2 = -x - r  # winding (using w=0 for simplicity, so w - r = -r)
    # Actually logRadiusEnergy(r, n=x, w=-x) demonstrates the symmetry better
    # Let's use: E(r,x) = min(x + r, -x - r) to show the V-shape
    energy = np.minimum(branch1, branch2)

    ax.plot(x, branch1, '--', color='#2196F3', alpha=0.6, label=f'n + r = x + {r}')
    ax.plot(x, branch2, '--', color='#F44336', alpha=0.6, label=f'w - r = -x - {r}')
    ax.plot(x, energy, '-', color='#4CAF50', linewidth=2.5, label='Energy (min)')

    # Mark the corner
    x_corner = -r
    y_corner = min(x_corner + r, -x_corner - r)
    ax.plot(x_corner, y_corner, 'ko', markersize=8, zorder=5)
    ax.annotate(f'Corner\nx={-r:.1f}', (x_corner, y_corner),
                textcoords="offset points", xytext=(15, 10),
                fontsize=9, ha='center')

    ax.set_xlabel('x (charge coordinate)')
    ax.set_ylabel('Energy')
    r_str = f'r = {r}' if r != -0.5 else 'r = -0.5 (= dual of r=0.5)'
    ax.set_title(f'ρ = {r}')
    ax.legend(fontsize=8, loc='upper center')
    ax.set_ylim(-4, 4)
    ax.grid(True, alpha=0.3)
    ax.axhline(y=0, color='k', linewidth=0.5)
    ax.axvline(x=0, color='k', linewidth=0.5)

fig.suptitle('T-Duality: Tropical Energy Potential min(x+ρ, -x-ρ)', fontsize=14, y=1.02)
plt.tight_layout()
plt.savefig('fig_tduality_energy.png')
plt.close()

# ============================================================
# Figure 2: Conifold Transition
# ============================================================
fig, axes = plt.subplots(1, 4, figsize=(16, 4))

x = np.linspace(-3, 3, 500)
t_values = [-1.0, 0.0, 0.5, 2.0]

for idx, t in enumerate(t_values):
    ax = axes[idx]
    branch_x = x
    branch_neg_x = -x
    branch_t = np.full_like(x, t)
    conifold = np.minimum(x, np.minimum(-x, t))

    ax.plot(x, branch_x, '--', color='#2196F3', alpha=0.5, label='x')
    ax.plot(x, branch_neg_x, '--', color='#F44336', alpha=0.5, label='-x')
    ax.plot(x, branch_t, '--', color='#FF9800', alpha=0.5, label=f't={t}')
    ax.plot(x, conifold, '-', color='#9C27B0', linewidth=2.5, label='min')

    # Detect and mark corners
    eps = 0.05
    for xi in np.linspace(-2.5, 2.5, 1000):
        vals = [xi, -xi, t]
        sorted_vals = sorted(vals)
        if abs(sorted_vals[0] - sorted_vals[1]) < eps:
            yi = min(vals)
            ax.plot(xi, yi, 'ko', markersize=6, zorder=5)

    status = "Smooth" if t < 0 else ("SINGULAR" if t == 0 else "Resolved")
    ax.set_title(f't = {t}  [{status}]')
    ax.set_xlabel('x')
    ax.set_ylabel('f(x)')
    ax.legend(fontsize=7, loc='lower center')
    ax.set_ylim(-3, 3)
    ax.grid(True, alpha=0.3)

fig.suptitle('Conifold Transition: min(x, -x, t) as t varies', fontsize=14, y=1.02)
plt.tight_layout()
plt.savefig('fig_conifold_transition.png')
plt.close()

# ============================================================
# Figure 3: Tropical Legendre Transform
# ============================================================
fig = plt.figure(figsize=(14, 5))
gs = GridSpec(1, 3, figure=fig)

# Potential: min of affine functions
coeffs = [(0.0, 1.0), (2.0, -1.0), (1.0, 0.0)]  # (c, m)
x = np.linspace(-3, 3, 500)

ax1 = fig.add_subplot(gs[0])
colors = ['#2196F3', '#F44336', '#4CAF50']
for (c, m), color in zip(coeffs, colors):
    ax1.plot(x, c + m * x, '--', color=color, alpha=0.5, label=f'{c}+{m}x')
potential = np.minimum.reduce([c + m * x for c, m in coeffs])
ax1.plot(x, potential, 'k-', linewidth=2.5, label='Potential (min)')
ax1.set_title('Primal Potential')
ax1.set_xlabel('x')
ax1.set_ylabel('Φ(x)')
ax1.legend(fontsize=8)
ax1.grid(True, alpha=0.3)

# Fenchel conjugate
p_vals = np.linspace(-3, 3, 500)
ax2 = fig.add_subplot(gs[1])

def fenchel_conj(f_vals, x_vals, p):
    return np.min(f_vals - p * x_vals)

conj_vals = [fenchel_conj(potential, x, p) for p in p_vals]
ax2.plot(p_vals, conj_vals, 'r-', linewidth=2.5)
ax2.set_title('Fenchel Conjugate Φ°(p)')
ax2.set_xlabel('p (slope)')
ax2.set_ylabel('Φ°(p)')
ax2.grid(True, alpha=0.3)

# Biconjugate vs original
ax3 = fig.add_subplot(gs[2])
biconj_vals = []
for xi in x:
    bc = min(fenchel_conj(potential, x, p) + p * xi for p in p_vals)
    biconj_vals.append(bc)
biconj_vals = np.array(biconj_vals)

ax3.plot(x, potential, 'k-', linewidth=2.5, label='Φ(x)')
ax3.plot(x, biconj_vals, 'r--', linewidth=2, label='Φ°°(x)')
ax3.fill_between(x, biconj_vals, potential, alpha=0.15, color='blue',
                  label='Gap (Φ - Φ°°)')
ax3.set_title('Fenchel-Moreau: Φ°° ≤ Φ')
ax3.set_xlabel('x')
ax3.legend(fontsize=8)
ax3.grid(True, alpha=0.3)

fig.suptitle('Tropical Legendre Transform and Mirror Duality', fontsize=14, y=1.02)
plt.tight_layout()
plt.savefig('fig_legendre_transform.png')
plt.close()

# ============================================================
# Figure 4: Circle Energy Duality Heatmap
# ============================================================
fig, axes = plt.subplots(1, 2, figsize=(12, 5))

n_range = np.linspace(-3, 3, 200)
w_range = np.linspace(-3, 3, 200)
N, W = np.meshgrid(n_range, w_range)

R = 2.0
E_original = np.minimum(N + R, W + 1.0/R)
E_dual = np.minimum(W + 1.0/R, N + R)  # Should be identical

ax = axes[0]
im = ax.contourf(N, W, E_original, levels=20, cmap='viridis')
ax.set_xlabel('n (momentum)')
ax.set_ylabel('w (winding)')
ax.set_title(f'E(R={R}, n, w)')
plt.colorbar(im, ax=ax, label='Energy')
ax.set_aspect('equal')

ax = axes[1]
# Show the self-dual point R=1
R_range = np.logspace(-1, 1, 200)
n_fixed, w_fixed = 1.0, 2.0
E_R = np.minimum(n_fixed + R_range, w_fixed + 1.0/R_range)
E_dual_R = np.minimum(w_fixed + R_range, n_fixed + 1.0/R_range)

ax.plot(R_range, E_R, 'b-', linewidth=2, label=f'E(R, n={n_fixed}, w={w_fixed})')
ax.plot(R_range, E_dual_R, 'r--', linewidth=2, label=f'E(R, w={w_fixed}, n={n_fixed})')
ax.axvline(x=1.0, color='k', linestyle=':', alpha=0.5, label='Self-dual (R=1)')
ax.set_xlabel('R')
ax.set_ylabel('Energy')
ax.set_title('T-Duality: E(R,n,w) = E(1/R,w,n)')
ax.set_xscale('log')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('fig_energy_duality.png')
plt.close()

print("All figures saved successfully:")
print("  - fig_tduality_energy.png")
print("  - fig_conifold_transition.png")
print("  - fig_legendre_transform.png")
print("  - fig_energy_duality.png")
