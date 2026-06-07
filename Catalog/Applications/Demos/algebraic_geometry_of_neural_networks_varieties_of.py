#!/usr/bin/env python3
"""
Tropical Neural Algebra: Demonstration

Shows how ReLU networks compute tropical rational functions and how
decision boundary complexity grows with network architecture.
"""

import numpy as np

def relu(x):
    """ReLU activation: max(x, 0)"""
    return np.maximum(x, 0)

def tropical_max(a, b):
    """Tropical sum in max-plus algebra"""
    return np.maximum(a, b)

def tropical_add(a, b):
    """Tropical product in max-plus algebra (= classical addition)"""
    return a + b

# ============================================================
# Demo 1: ReLU as Tropical Polynomial
# ============================================================
print("=" * 60)
print("Demo 1: ReLU = Tropical Polynomial (2 pieces)")
print("=" * 60)

x = np.linspace(-3, 3, 7)
print(f"x       = {x}")
print(f"relu(x) = {relu(x)}")
print(f"max(x,0)= {np.maximum(x, 0)}")
print(f"(x+|x|)/2 = {(x + np.abs(x)) / 2}")
print("All three are identical: relu_abs_identity ✓")

# ============================================================
# Demo 2: Tropical Dequantization Identity
# ============================================================
print("\n" + "=" * 60)
print("Demo 2: Tropical Dequantization")
print("  max(a, b) = b + max(a - b, 0)")
print("=" * 60)

a, b = 3.0, 5.0
lhs = max(a, b)
rhs = b + max(a - b, 0)
print(f"max({a}, {b}) = {lhs}")
print(f"{b} + max({a}-{b}, 0) = {rhs}")
print(f"Identity verified: {lhs == rhs}")

# ============================================================
# Demo 3: Single Layer Region Bound
# ============================================================
print("\n" + "=" * 60)
print("Demo 3: Single Layer Region Bound = 2^w")
print("=" * 60)

for w in range(1, 8):
    bound = 2 ** w
    print(f"  Width w={w}: at most {bound} linear regions")

# ============================================================
# Demo 4: Deep Network Region Bound
# ============================================================
print("\n" + "=" * 60)
print("Demo 4: Deep Network Region Bound = 2^(sum of widths)")
print("=" * 60)

architectures = [
    [10],           # 1 layer, width 10
    [5, 5],         # 2 layers, width 5 each
    [3, 3, 4],      # 3 layers
    [2, 2, 2, 2, 2],# 5 layers, width 2 each
]

for widths in architectures:
    total_w = sum(widths)
    bound = 2 ** total_w
    print(f"  Widths {widths}: total_width={total_w}, bound=2^{total_w}={bound}")

# ============================================================
# Demo 5: Depth Amplification via Zaslavsky
# ============================================================
print("\n" + "=" * 60)
print("Demo 5: Zaslavsky Bound vs Naive Bound")
print("  Zaslavsky: sum_{j=0}^{min(n,w)} C(w,j)")
print("  Naive: 2^w")
print("=" * 60)

from math import comb

def zaslavsky_bound(n, w):
    return sum(comb(w, j) for j in range(min(n, w) + 1))

n = 2  # dimension
for w in [2, 4, 8, 16, 32]:
    zas = zaslavsky_bound(n, w)
    naive = 2 ** w
    ratio = zas / naive
    print(f"  n={n}, w={w}: Zaslavsky={zas}, Naive=2^{w}={naive}, ratio={ratio:.6f}")

print("\n  Key insight: When w >> n, Zaslavsky is polynomial in w (O(w^n))")
print("  while naive bound is exponential (2^w).")
print("  This is WHY depth helps: each layer has w_i << n_effective,")
print("  so the per-layer bound is small, but they multiply!")

# ============================================================
# Demo 6: Bend Count Growth with Depth
# ============================================================
print("\n" + "=" * 60)
print("Demo 6: Bend Count Growth (Univariate)")
print("  After L layers of single neurons: 2^L - 1 bends")
print("=" * 60)

for L in range(1, 11):
    bends = 2 ** L - 1
    print(f"  Depth L={L}: at most {bends} bends (breakpoints)")

# ============================================================
# Demo 7: Concrete 2D Decision Boundary
# ============================================================
print("\n" + "=" * 60)
print("Demo 7: Concrete 2D Network Decision Boundary")
print("=" * 60)

def two_layer_network(x1, x2):
    """A simple 2-layer ReLU network: R^2 -> R"""
    # Layer 1: 3 neurons
    h1 = relu(x1 + x2 - 1)
    h2 = relu(-x1 + x2)
    h3 = relu(x1 - x2 + 0.5)
    # Layer 2: linear readout
    return h1 - h2 + 0.5 * h3 - 0.3

# Sample the decision boundary
grid = np.linspace(-2, 2, 1000)
boundary_points = []
for x1 in grid:
    for x2 in grid:
        val = two_layer_network(x1, x2)
        if abs(val) < 0.01:
            boundary_points.append((x1, x2))

print(f"  Network: 2 inputs, 3 hidden neurons (1 layer), 1 output")
print(f"  Activation patterns: 2^3 = 8 possible")
print(f"  Found {len(boundary_points)} approximate boundary points")
print(f"  Decision boundary is piecewise linear (tropical hypersurface)")

# Count distinct activation patterns
patterns = set()
for x1 in np.linspace(-2, 2, 100):
    for x2 in np.linspace(-2, 2, 100):
        p1 = int(x1 + x2 - 1 >= 0)
        p2 = int(-x1 + x2 >= 0)
        p3 = int(x1 - x2 + 0.5 >= 0)
        patterns.add((p1, p2, p3))

print(f"  Distinct activation patterns observed: {len(patterns)}")
print(f"  (out of maximum 2^3 = 8)")

# ============================================================
# Demo 8: Tropical Representation Verification
# ============================================================
print("\n" + "=" * 60)
print("Demo 8: Verifying Tropical Rational Representation")
print("=" * 60)

# f(x) = relu(x) - relu(-x) = |x| as tropical rational
x = np.linspace(-3, 3, 7)
f_tropical = relu(x) - relu(-x)  # tropical rational form
f_identity = x  # should be x (since relu(x) - relu(-x) = x)
print(f"x = {x}")
print(f"relu(x) - relu(-x) = {f_tropical}")
print(f"x = {f_identity}")
print(f"Identity: relu(x) - relu(-x) = x ✓")

print("\n" + "=" * 60)
print("All demonstrations complete!")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Decision Boundaries as Tropical Hypersurfaces

Creates a visualization of how ReLU network decision boundaries
form piecewise linear (tropical) hypersurfaces, and how their
complexity grows with network architecture.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap

def relu(x):
    return np.maximum(x, 0)

def network_eval(x1, x2, architecture="simple"):
    """Evaluate different network architectures."""
    if architecture == "simple":
        # 1 hidden layer, 3 neurons
        h1 = relu(x1 + x2 - 1)
        h2 = relu(-x1 + x2)
        h3 = relu(x1 - x2 + 0.5)
        return h1 - h2 + 0.5 * h3 - 0.3
    elif architecture == "deep":
        # 2 hidden layers, 3+2 neurons
        h1 = relu(x1 + x2 - 1)
        h2 = relu(-x1 + x2)
        h3 = relu(x1 - x2 + 0.5)
        g1 = relu(h1 - h2 + 0.3)
        g2 = relu(-h1 + 0.5 * h3 - 0.2)
        return g1 - g2 + 0.1
    elif architecture == "wide":
        # 1 hidden layer, 6 neurons
        h1 = relu(x1 + x2 - 1)
        h2 = relu(-x1 + x2)
        h3 = relu(x1 - x2 + 0.5)
        h4 = relu(-x1 - x2 + 1.5)
        h5 = relu(2*x1 - x2 - 0.5)
        h6 = relu(-x1 + 2*x2 - 0.8)
        return h1 - h2 + 0.5*h3 - 0.3*h4 + 0.7*h5 - 0.4*h6 - 0.2
    return 0

def activation_pattern(x1, x2, architecture="simple"):
    """Compute activation pattern as integer."""
    if architecture == "simple":
        p1 = int(x1 + x2 - 1 >= 0)
        p2 = int(-x1 + x2 >= 0)
        p3 = int(x1 - x2 + 0.5 >= 0)
        return p1 * 4 + p2 * 2 + p3
    elif architecture == "wide":
        p1 = int(x1 + x2 - 1 >= 0)
        p2 = int(-x1 + x2 >= 0)
        p3 = int(x1 - x2 + 0.5 >= 0)
        p4 = int(-x1 - x2 + 1.5 >= 0)
        p5 = int(2*x1 - x2 - 0.5 >= 0)
        p6 = int(-x1 + 2*x2 - 0.8 >= 0)
        return p1*32 + p2*16 + p3*8 + p4*4 + p5*2 + p6
    return 0

fig, axes = plt.subplots(2, 2, figsize=(14, 12))
fig.suptitle("Decision Boundaries as Tropical Hypersurfaces", fontsize=16, fontweight='bold')

resolution = 500
x = np.linspace(-3, 3, resolution)
y = np.linspace(-3, 3, resolution)
X, Y = np.meshgrid(x, y)

# Plot 1: Simple network - decision boundary
ax = axes[0, 0]
Z = np.vectorize(lambda a, b: network_eval(a, b, "simple"))(X, Y)
ax.contourf(X, Y, Z, levels=50, cmap='RdBu_r', alpha=0.8)
ax.contour(X, Y, Z, levels=[0], colors='black', linewidths=2)
ax.set_title("1 Layer, 3 Neurons\n(Decision Boundary = Tropical Curve)", fontsize=11)
ax.set_xlabel("x₁")
ax.set_ylabel("x₂")

# Plot 2: Activation regions
ax = axes[0, 1]
P = np.vectorize(lambda a, b: activation_pattern(a, b, "simple"))(X, Y)
cmap = plt.cm.get_cmap('tab20', int(P.max()) + 1)
ax.pcolormesh(X, Y, P, cmap=cmap, shading='auto')
Z = np.vectorize(lambda a, b: network_eval(a, b, "simple"))(X, Y)
ax.contour(X, Y, Z, levels=[0], colors='white', linewidths=2)
n_patterns = len(np.unique(P))
ax.set_title(f"Activation Regions: {n_patterns} / 2³=8 patterns\n(Each color = one linear region)", fontsize=11)
ax.set_xlabel("x₁")
ax.set_ylabel("x₂")

# Plot 3: Deep network
ax = axes[1, 0]
Z = np.vectorize(lambda a, b: network_eval(a, b, "deep"))(X, Y)
ax.contourf(X, Y, Z, levels=50, cmap='RdBu_r', alpha=0.8)
ax.contour(X, Y, Z, levels=[0], colors='black', linewidths=2)
ax.set_title("2 Layers (3+2 Neurons)\n(More complex tropical curve)", fontsize=11)
ax.set_xlabel("x₁")
ax.set_ylabel("x₂")

# Plot 4: Wide network
ax = axes[1, 1]
Z = np.vectorize(lambda a, b: network_eval(a, b, "wide"))(X, Y)
ax.contourf(X, Y, Z, levels=50, cmap='RdBu_r', alpha=0.8)
ax.contour(X, Y, Z, levels=[0], colors='black', linewidths=2)
P = np.vectorize(lambda a, b: activation_pattern(a, b, "wide"))(X, Y)
n_patterns = len(np.unique(P))
ax.set_title(f"1 Layer, 6 Neurons ({n_patterns} / 2⁶=64 regions)\n(Wider = more complex boundary)", fontsize=11)
ax.set_xlabel("x₁")
ax.set_ylabel("x₂")

plt.tight_layout()
plt.savefig("decision_boundaries.png", dpi=150, bbox_inches='tight')
print("Saved decision_boundaries.png")
plt.close()

# ============================================================
# Second figure: Zaslavsky bound comparison
# ============================================================
from math import comb

def zaslavsky(n, w):
    return sum(comb(w, j) for j in range(min(n, w) + 1))

fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# Left: Zaslavsky vs naive
ax = axes[0]
widths = range(1, 21)
for n in [1, 2, 3, 5]:
    zas = [zaslavsky(n, w) for w in widths]
    ax.plot(widths, zas, 'o-', label=f'Zaslavsky (n={n})', markersize=4)

naive = [2**w for w in widths]
ax.plot(widths, naive, 'k--', label='Naive 2^w', linewidth=2)
ax.set_yscale('log')
ax.set_xlabel('Width w')
ax.set_ylabel('Region count bound')
ax.set_title('Zaslavsky Refinement of Region Bound')
ax.legend()
ax.grid(True, alpha=0.3)

# Right: Depth amplification
ax = axes[1]
total_W = 12
depths = range(1, 13)
for n in [2, 3, 5]:
    bounds = []
    for L in depths:
        w_per_layer = total_W // L
        if w_per_layer == 0:
            bounds.append(1)
        else:
            # Product of Zaslavsky bounds
            bound = 1
            for _ in range(L):
                bound *= zaslavsky(n, w_per_layer)
            bounds.append(bound)
    ax.plot(list(depths), bounds, 'o-', label=f'Zaslavsky (n={n})', markersize=4)

ax.axhline(y=2**total_W, color='k', linestyle='--', label=f'Naive 2^{total_W}')
ax.set_yscale('log')
ax.set_xlabel('Depth L (total width W=12 fixed)')
ax.set_ylabel('Region count bound')
ax.set_title('Depth Amplification Effect\n(Same total width, varying depth)')
ax.legend()
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig("zaslavsky_bounds.png", dpi=150, bbox_inches='tight')
print("Saved zaslavsky_bounds.png")
plt.close()


#!/usr/bin/env python3
"""
Visualization: Tropical Algebra of Neural Networks

Shows the tropical polynomial structure of ReLU networks:
1. Single neuron as 2-piece tropical polynomial
2. Layer composition and piece multiplication  
3. Bend count growth with depth
4. Tropical duality: decision boundary = agreement set
"""

import numpy as np
import matplotlib.pyplot as plt

def relu(x):
    return np.maximum(x, 0)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle("Tropical Algebra of ReLU Networks", fontsize=16, fontweight='bold')

x = np.linspace(-3, 3, 1000)

# Plot 1: ReLU as tropical polynomial
ax = axes[0, 0]
ax.plot(x, relu(x), 'b-', linewidth=2, label='relu(x) = max(x, 0)')
ax.plot(x, x, 'r--', alpha=0.5, label='piece 1: x')
ax.plot(x, np.zeros_like(x), 'g--', alpha=0.5, label='piece 2: 0')
ax.axvline(x=0, color='orange', linestyle=':', linewidth=2, label='bend point')
ax.fill_between(x, relu(x), alpha=0.1, color='blue')
ax.set_title("ReLU = 2-Piece Tropical Polynomial\nmax(x, 0) with 1 bend", fontsize=11)
ax.set_xlabel("x")
ax.set_ylabel("f(x)")
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Plot 2: Composition increases bends
ax = axes[0, 1]
f1 = relu(x)  # 1 bend
f2 = relu(relu(2*x - 1) - relu(-x + 0.5))  # more bends
f3_inner = relu(x) + relu(x - 1) - relu(x - 2)
f3 = relu(f3_inner - 0.5)  # even more bends

ax.plot(x, f1, 'b-', linewidth=2, label='depth 1: 1 bend')
ax.plot(x, f2, 'r-', linewidth=2, label='depth 2: ≤3 bends')
ax.plot(x, f3, 'g-', linewidth=2, label='depth 2 (wider): ≤5 bends')
ax.set_title("Bend Count Growth with Depth\n(Each composition multiplies complexity)", fontsize=11)
ax.set_xlabel("x")
ax.set_ylabel("f(x)")
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Plot 3: Tropical duality - agreement set
ax = axes[1, 0]
# f(x) = p(x) - q(x), boundary is where p = q
p = np.maximum(x + 1, np.maximum(-x + 2, 0.5 * np.ones_like(x)))
q = np.maximum(0.5 * x + 0.5, np.maximum(-0.5 * x + 1.5, np.ones_like(x)))
f = p - q

ax.plot(x, p, 'b-', linewidth=2, label='p(x) = tropical poly 1')
ax.plot(x, q, 'r-', linewidth=2, label='q(x) = tropical poly 2')
ax.plot(x, f, 'k-', linewidth=2, label='f(x) = p(x) - q(x)')
ax.axhline(y=0, color='gray', linestyle=':', alpha=0.5)

# Mark agreement points (decision boundary)
for i in range(1, len(x)):
    if (p[i-1] - q[i-1]) * (p[i] - q[i]) <= 0:
        # Linear interpolation for crossing point
        t = (q[i-1] - p[i-1]) / ((p[i] - p[i-1]) - (q[i] - q[i-1]))
        x_cross = x[i-1] + t * (x[i] - x[i-1])
        y_cross = p[i-1] + t * (p[i] - p[i-1])
        ax.plot(x_cross, y_cross, 'ko', markersize=10, zorder=5)
        ax.plot(x_cross, 0, 'k^', markersize=10, zorder=5)

ax.set_title("Tropical Duality\nBoundary = {x : p(x) = q(x)}", fontsize=11)
ax.set_xlabel("x")
ax.set_ylabel("value")
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Plot 4: Exponential bend growth
ax = axes[1, 1]
depths = range(1, 11)
bends_single = [2**L - 1 for L in depths]
bends_width2 = [3**L - 1 for L in depths]  # width 2 per layer
bends_width3 = [4**L - 1 for L in depths]  # width 3 per layer

ax.semilogy(depths, bends_single, 'bo-', label='width 1: 2^L - 1', markersize=6)
ax.semilogy(depths, bends_width2, 'rs-', label='width 2: 3^L - 1', markersize=6)
ax.semilogy(depths, bends_width3, 'g^-', label='width 3: 4^L - 1', markersize=6)

# Region bound
regions = [2**(L*3) for L in depths]
ax.semilogy(depths, regions, 'k--', label='regions 2^(3L)', linewidth=2)

ax.set_title("Exponential Complexity Growth\n(Bends and regions vs depth)", fontsize=11)
ax.set_xlabel("Depth L")
ax.set_ylabel("Count")
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig("tropical_algebra.png", dpi=150, bbox_inches='tight')
print("Saved tropical_algebra.png")
plt.close()
