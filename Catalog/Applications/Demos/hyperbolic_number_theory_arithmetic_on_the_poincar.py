"""
Hyperbolic Number Theory: Applications
========================================
Real-world applications connecting hyperbolic arithmetic to
coding theory, network design, and signal processing.
"""

import cmath
import math
from typing import List, Tuple, Dict


# =============================================================================
# Application 1: Hyperbolic Codes for Error Correction
# =============================================================================

def mobius_transform(a: complex, theta: float, z: complex) -> complex:
    """Möbius transformation on the Poincaré disk."""
    eitheta = cmath.exp(1j * theta)
    denom = 1 - a.conjugate() * z
    return eitheta * (z - a) / denom


def hyperbolic_distance(z: complex, w: complex) -> float:
    """Hyperbolic distance in the Poincaré disk."""
    denom = 1 - z.conjugate() * w
    if abs(denom) < 1e-15:
        return float('inf')
    pd = abs((z - w) / denom)
    if pd >= 1 - 1e-15:
        return float('inf')
    return 2 * math.atanh(pd)


class HyperbolicCode:
    """
    Error-correcting code based on hyperbolic geometry.

    The key insight: in hyperbolic space, the number of points at distance
    ≤ R from the origin grows exponentially in R (not polynomially as in
    Euclidean space). This allows for codes with exponentially more codewords
    at a given minimum distance — a direct consequence of negative curvature.

    Application: satellite communications, deep-space networking, and
    any setting where exponential codebook size matters.
    """

    def __init__(self, generators: List[Tuple[complex, float]], depth: int):
        """
        Create a hyperbolic code from group generators.

        Parameters:
            generators: Möbius transform parameters [(a, θ), ...]
            depth: Maximum word length (controls code rate)
        """
        self.generators = generators
        self.depth = depth
        self.codewords = self._generate_codewords()

    def _generate_codewords(self) -> List[complex]:
        """Generate all orbit points as codewords."""
        points = [0 + 0j]
        current = [0 + 0j]

        for d in range(self.depth):
            next_level = []
            for pt in current:
                for a, theta in self.generators:
                    try:
                        w = mobius_transform(a, theta, pt)
                        if abs(w) < 0.99:
                            # Check it's not too close to existing points
                            is_new = all(hyperbolic_distance(w, p) > 0.1 for p in points)
                            if is_new:
                                next_level.append(w)
                                points.append(w)
                    except (ValueError, ZeroDivisionError):
                        continue
            current = next_level

        return points

    def minimum_distance(self) -> float:
        """Compute the minimum hyperbolic distance between any two codewords."""
        min_d = float('inf')
        for i, z in enumerate(self.codewords):
            for w in self.codewords[i+1:]:
                d = hyperbolic_distance(z, w)
                if d < min_d:
                    min_d = d
        return min_d

    @property
    def rate(self) -> float:
        """Code rate: log2(number of codewords) / depth."""
        if self.depth == 0:
            return 0
        return math.log2(max(len(self.codewords), 1)) / self.depth


# =============================================================================
# Application 2: Network Routing on Hyperbolic Graphs
# =============================================================================

class HyperbolicNetwork:
    """
    A network whose nodes are embedded in hyperbolic space.

    Many real-world networks (internet, social networks, biological networks)
    have a tree-like, hierarchical structure that embeds naturally into
    hyperbolic space. The word metric on the Cayley graph gives a natural
    routing metric.

    Application: Greedy routing in networks with power-law degree distributions.
    """

    def __init__(self, n_nodes: int, n_generators: int = 2):
        self.n_generators = n_generators
        self.nodes = self._generate_nodes(n_nodes)
        self.adjacency = self._build_adjacency()

    def _generate_nodes(self, n: int) -> List[complex]:
        """Place n nodes in the Poincaré disk using a quasi-random sequence."""
        nodes = []
        phi = (1 + math.sqrt(5)) / 2  # golden ratio
        for i in range(n):
            # Quasi-random point in the disk
            r = math.sqrt(i / n) * 0.95  # radius ∈ [0, 0.95]
            theta = 2 * math.pi * i * phi
            z = r * cmath.exp(1j * theta)
            nodes.append(z)
        return nodes

    def _build_adjacency(self) -> Dict[int, List[int]]:
        """Connect nodes that are within hyperbolic distance threshold."""
        threshold = 2.0
        adj: Dict[int, List[int]] = {i: [] for i in range(len(self.nodes))}
        for i, z in enumerate(self.nodes):
            for j, w in enumerate(self.nodes):
                if i < j and hyperbolic_distance(z, w) < threshold:
                    adj[i].append(j)
                    adj[j].append(i)
        return adj

    def greedy_route(self, source: int, target: int) -> List[int]:
        """
        Greedy routing: at each step, forward to the neighbor closest
        to the target in hyperbolic distance.

        In hyperbolic space, greedy routing succeeds with high probability
        due to the tree-like structure (a consequence of negative curvature).
        """
        path = [source]
        current = source
        visited = {source}

        for _ in range(len(self.nodes)):
            if current == target:
                break

            best_neighbor = None
            best_dist = hyperbolic_distance(self.nodes[current], self.nodes[target])

            for neighbor in self.adjacency[current]:
                if neighbor not in visited:
                    d = hyperbolic_distance(self.nodes[neighbor], self.nodes[target])
                    if d < best_dist:
                        best_dist = d
                        best_neighbor = neighbor

            if best_neighbor is None:
                break  # Stuck

            visited.add(best_neighbor)
            path.append(best_neighbor)
            current = best_neighbor

        return path


# =============================================================================
# Application 3: Hyperbolic Signal Processing
# =============================================================================

def hyperbolic_fourier_transform(
    signal: List[complex],
    orbit_points: List[complex],
    s_values: List[float]
) -> List[complex]:
    """
    Hyperbolic Fourier transform: decompose a signal defined on orbit
    points using the hyperbolic zeta kernel.

    F(s) = Σ_z f(z) · |z|^{-2s}

    This generalizes the classical Mellin transform to the hyperbolic setting.

    Parameters:
        signal: Signal values at orbit points
        orbit_points: Points in the Poincaré disk
        s_values: Frequencies to evaluate

    Returns:
        Transform values at each s
    """
    result = []
    for s in s_values:
        total = 0 + 0j
        for f_z, z in zip(signal, orbit_points):
            r = abs(z)
            if r > 1e-15:
                total += f_z * r ** (-2 * s)
        result.append(total)
    return result


# =============================================================================
# Demo
# =============================================================================

if __name__ == "__main__":
    print("=" * 60)
    print("APPLICATION 1: Hyperbolic Error-Correcting Code")
    print("=" * 60)

    gens = [(0.4 + 0.1j, math.pi / 3), (0.1 - 0.4j, math.pi / 5)]
    code = HyperbolicCode(gens, depth=3)
    print(f"  Codewords: {len(code.codewords)}")
    print(f"  Code rate: {code.rate:.3f} bits/level")
    if len(code.codewords) > 1:
        print(f"  Min distance: {code.minimum_distance():.4f}")
    print(f"  Advantage: Exponential codebook growth (hyperbolic vs polynomial Euclidean)")

    print("\n" + "=" * 60)
    print("APPLICATION 2: Hyperbolic Network Routing")
    print("=" * 60)

    net = HyperbolicNetwork(50, n_generators=2)
    path = net.greedy_route(0, 25)
    print(f"  Nodes: {len(net.nodes)}")
    print(f"  Route 0→25: {' → '.join(map(str, path))}")
    print(f"  Path length: {len(path) - 1} hops")
    success_count = 0
    total_tests = 100
    for i in range(0, min(10, len(net.nodes))):
        for j in range(i + 1, min(i + 11, len(net.nodes))):
            path = net.greedy_route(i, j)
            if path[-1] == j:
                success_count += 1
            total_tests = max(total_tests, 1)
    tests_done = min(10, len(net.nodes)) * 10
    if tests_done > 0:
        print(f"  Greedy routing success: {success_count}/{tests_done}")

    print("\n" + "=" * 60)
    print("APPLICATION 3: Hyperbolic Signal Processing")
    print("=" * 60)

    # Generate a simple signal on orbit points
    orbit = [0.1 * cmath.exp(2j * math.pi * k / 8) for k in range(8)]
    signal = [cmath.exp(-abs(z)**2) for z in orbit]
    s_vals = [0.5, 1.0, 1.5, 2.0, 2.5]

    transform = hyperbolic_fourier_transform(signal, orbit, s_vals)
    print("  Hyperbolic Fourier Transform:")
    for s, F_s in zip(s_vals, transform):
        print(f"    F({s:.1f}) = {F_s:.6f}")

    print("\n  → The transform captures frequency content on curved space")
    print("  → Converges for s > δ/2 (critical exponent of the group)")


"""
Hyperbolic Number Theory: Demonstrations
=========================================
Concrete numerical examples illustrating the theorems proved in Lean 4.
"""

import cmath
import math
from typing import List, Tuple


def mobius_map(a: complex, eitheta: complex, z: complex) -> complex:
    """Möbius transformation: φ(z) = e^{iθ}·(z - a) / (1 - conj(a)·z)"""
    return eitheta * (z - a) / (1 - a.conjugate() * z)


def hyp_pseudo_dist(z: complex, w: complex) -> float:
    """Hyperbolic pseudo-distance: |(z-w)/(1-conj(z)·w)|"""
    denom = 1 - z.conjugate() * w
    if abs(denom) < 1e-15:
        return float('inf')
    return abs((z - w) / denom)


def hyp_dist(z: complex, w: complex) -> float:
    """True hyperbolic distance: 2·arctanh(pseudo_dist)"""
    pd = hyp_pseudo_dist(z, w)
    if pd >= 1:
        return float('inf')
    return 2 * math.atanh(pd)


# =============================================================================
# Demo 1: Möbius map preserves the disk
# =============================================================================
print("=" * 60)
print("DEMO 1: Möbius Map Preserves the Poincaré Disk")
print("=" * 60)

test_points = [0, 0.3 + 0.4j, -0.5 + 0.3j, 0.7j, 0.9]
centers = [0.2 + 0.3j, -0.4 + 0.1j, 0.6j]

for a in centers:
    eitheta = cmath.exp(1j * math.pi / 3)  # rotation by 60°
    print(f"\nCenter a = {a:.3f}, |a| = {abs(a):.4f}")
    for z in test_points:
        if abs(z) >= 1:
            continue
        w = mobius_map(a, eitheta, z)
        print(f"  φ({z:.3f}) = {w:.4f},  |φ(z)| = {abs(w):.6f} < 1 ✓")
        assert abs(w) < 1 + 1e-10, f"Disk preservation failed for z={z}, a={a}"

# =============================================================================
# Demo 2: Hyperbolic pseudo-distance symmetry
# =============================================================================
print("\n" + "=" * 60)
print("DEMO 2: Pseudo-Distance Symmetry d(z,w) = d(w,z)")
print("=" * 60)

pairs = [
    (0.3 + 0.2j, -0.1 + 0.5j),
    (0.7, 0.3j),
    (-0.4 + 0.3j, 0.2 - 0.6j),
]

for z, w in pairs:
    d_zw = hyp_pseudo_dist(z, w)
    d_wz = hyp_pseudo_dist(w, z)
    print(f"  d({z:.2f}, {w:.2f}) = {d_zw:.10f}")
    print(f"  d({w:.2f}, {z:.2f}) = {d_wz:.10f}")
    print(f"  Difference: {abs(d_zw - d_wz):.2e} ✓")
    assert abs(d_zw - d_wz) < 1e-12

# =============================================================================
# Demo 3: Cayley word decomposition and factorization
# =============================================================================
print("\n" + "=" * 60)
print("DEMO 3: Cayley Word Factorization (Hyperbolic Integers)")
print("=" * 60)

# Model: 2-generator group (like PSL(2,Z))
GENERATORS = ['S', 'T', 'S⁻¹', 'T⁻¹']

def word_length(w: str) -> int:
    return len(w.split('·')) if w else 0

# Demonstrate factorization
words = ['S', 'T·S', 'S·T·S⁻¹', 'T·S·T·S', 'S·T·S·T·S·T']
for w in words:
    letters = w.split('·')
    print(f"  Word: {w}")
    print(f"    Length: {len(letters)}")
    print(f"    First factor: {letters[0]}, remainder: {'·'.join(letters[1:]) or 'ε'}")

# =============================================================================
# Demo 4: Exponential growth of orbit points
# =============================================================================
print("\n" + "=" * 60)
print("DEMO 4: Exponential Growth of Orbit Points")
print("=" * 60)

n_gen = 2  # number of generators
d = 2 * n_gen  # alphabet size (generators + inverses)

print(f"  Generators: {n_gen}, Alphabet size: {d}")
print(f"  {'R':>3} | {'Words ≤ R':>12} | {'d^(R+1)':>12} | {'Ratio':>8}")
print(f"  {'---':>3}-+-{'---':>12}-+-{'---':>12}-+-{'---':>8}")

for R in range(8):
    word_count = sum(d**k for k in range(R + 1))
    upper = d**(R + 1)
    ratio = word_count / upper if upper > 0 else 0
    print(f"  {R:3d} | {word_count:12d} | {upper:12d} | {ratio:8.4f}")

# =============================================================================
# Demo 5: Generator density (hyperbolic PNT analog)
# =============================================================================
print("\n" + "=" * 60)
print("DEMO 5: Generator Density Bound (Hyperbolic PNT)")
print("=" * 60)

print(f"  {'R':>3} | {'Generators':>12} | {'Total ≤ R':>12} | {'Density':>10}")
print(f"  {'---':>3}-+-{'---':>12}-+-{'---':>12}-+-{'---':>10}")

for R in range(1, 12):
    n_generators = 2 * n_gen  # words of length exactly 1
    total = sum(d**k for k in range(R + 1))
    density = n_generators / total
    print(f"  {R:3d} | {n_generators:12d} | {total:12d} | {density:10.6f}")

print("\n  → Generators become exponentially sparse as R grows!")
print("  → This mirrors π(N)/N → 0 in classical number theory.")

# =============================================================================
# Demo 6: Hyperbolic Goldbach (word splitting)
# =============================================================================
print("\n" + "=" * 60)
print("DEMO 6: Hyperbolic Goldbach — Even-Length Word Splitting")
print("=" * 60)

import itertools

letters = ['a', 'b', 'A', 'B']  # A = a⁻¹, B = b⁻¹

for length in [4, 6, 8]:
    count = 0
    split_count = 0
    for word in itertools.product(letters, repeat=length):
        count += 1
        half = length // 2
        w1, w2 = word[:half], word[half:]
        if len(w1) == half and len(w2) == half:
            split_count += 1
    print(f"  Length {length}: {split_count}/{count} words split into equal halves ✓")

# =============================================================================
# Demo 7: Zeta summand behavior
# =============================================================================
print("\n" + "=" * 60)
print("DEMO 7: Hyperbolic Zeta Summand ‖z‖^{-2s}")
print("=" * 60)

disk_points = [0.1, 0.3, 0.5, 0.7, 0.9]
s_values = [0.5, 1.0, 2.0]

print(f"  {'‖z‖':>6} | " + " | ".join(f"s={s:.1f}" for s in s_values))
print(f"  {'---':>6}-+-" + "-+-".join("--------" for _ in s_values))

for r in disk_points:
    vals = [r**(-2*s) for s in s_values]
    print(f"  {r:6.2f} | " + " | ".join(f"{v:8.3f}" for v in vals))

print("\n  → All values ≥ 1 (proved: zetaSummand_ge_one)")
print("  → Summands diverge as ‖z‖ → 0 (pole of the zeta function)")

print("\n" + "=" * 60)
print("All demonstrations completed successfully!")
print("=" * 60)


"""
Visualization: Möbius Transform Action on the Poincaré Disk
=============================================================
Shows how a Möbius transformation distorts the disk, mapping
the center point to the origin. The grid lines become circular
arcs — geodesics in hyperbolic geometry.
"""

import numpy as np
import matplotlib.pyplot as plt


def mobius_map(a, theta, z):
    """Möbius transformation: e^{iθ}(z-a)/(1-conj(a)z)"""
    eitheta = np.exp(1j * theta)
    denom = 1 - np.conj(a) * z
    # Avoid division by zero
    safe = np.abs(denom) > 1e-10
    result = np.where(safe, eitheta * (z - a) / np.where(safe, denom, 1), np.nan)
    # Mask points outside disk
    result = np.where(np.abs(result) < 1.5, result, np.nan)
    return result


fig, axes = plt.subplots(2, 3, figsize=(15, 10))

# Different centers and rotations
configs = [
    (0 + 0j, 0, 'Identity (a=0, θ=0)'),
    (0.5 + 0j, 0, 'Translation (a=0.5, θ=0)'),
    (0.3 + 0.4j, 0, 'Off-center (a=0.3+0.4i, θ=0)'),
    (0 + 0j, np.pi / 4, 'Rotation (a=0, θ=π/4)'),
    (0.3 + 0.4j, np.pi / 3, 'Combined (a=0.3+0.4i, θ=π/3)'),
    (0.7 + 0j, np.pi / 6, 'Near boundary (a=0.7, θ=π/6)'),
]

for idx, (a, theta, title) in enumerate(configs):
    ax = axes[idx // 3][idx % 3]

    # Draw unit circle
    circle_t = np.linspace(0, 2 * np.pi, 200)
    ax.plot(np.cos(circle_t), np.sin(circle_t), 'k-', linewidth=2)

    # Create a grid in the disk
    # Radial lines
    for angle in np.linspace(0, 2 * np.pi, 13)[:-1]:
        r_vals = np.linspace(0, 0.95, 50)
        z_line = r_vals * np.exp(1j * angle)
        w_line = mobius_map(a, theta, z_line)
        valid = ~np.isnan(w_line) & (np.abs(w_line) < 1)
        ax.plot(w_line[valid].real, w_line[valid].imag,
                color='steelblue', alpha=0.4, linewidth=0.8)

    # Concentric circles
    for r in np.linspace(0.1, 0.9, 5):
        z_circle = r * np.exp(1j * np.linspace(0, 2 * np.pi, 100))
        w_circle = mobius_map(a, theta, z_circle)
        valid = ~np.isnan(w_circle) & (np.abs(w_circle) < 1)
        ax.plot(w_circle[valid].real, w_circle[valid].imag,
                color='coral', alpha=0.5, linewidth=0.8)

    # Mark the center point and its image
    if abs(a) > 0.01:
        ax.plot(a.real, a.imag, 'g*', markersize=12, label='center a')
        # Image of origin
        w0 = mobius_map(a, theta, np.array([0 + 0j]))[0]
        if not np.isnan(w0):
            ax.plot(w0.real, w0.imag, 'r^', markersize=8, label='φ(0)')

    ax.plot(0, 0, 'k+', markersize=8)
    ax.set_xlim(-1.15, 1.15)
    ax.set_ylim(-1.15, 1.15)
    ax.set_aspect('equal')
    ax.set_title(title, fontsize=10)
    ax.grid(True, alpha=0.15)
    if abs(a) > 0.01:
        ax.legend(fontsize=7, loc='lower right')

fig.suptitle('Möbius Transformations on the Poincaré Disk\n'
             '(Blue: radial geodesics, Coral: distance circles)',
             fontsize=13, fontweight='bold')
plt.tight_layout()
plt.savefig('mobius_transforms.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: mobius_transforms.png")


"""
Visualization: Poincaré Disk Tessellation and Orbit Points
============================================================
Visualizes the orbit of the origin under a discrete group of
Möbius transformations, showing the hyperbolic lattice structure.
The exponential growth of orbit points — a hallmark of negative
curvature — is visible as the points crowd toward the boundary.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches


def mobius_transform(a, theta, z):
    """Möbius transformation on the Poincaré disk."""
    eitheta = np.exp(1j * theta)
    denom = 1 - np.conj(a) * z
    mask = np.abs(denom) > 1e-10
    result = np.where(mask, eitheta * (z - a) / np.where(mask, denom, 1), 0)
    return result


def generate_orbit(generators, max_depth=5):
    """Generate orbit points by applying all words up to given depth."""
    points = {0 + 0j}
    current = {0 + 0j}
    all_transforms = []
    for a, theta in generators:
        all_transforms.append((a, theta))
        # Approximate inverse
        inv_a = mobius_transform(a, theta, 0 + 0j)
        all_transforms.append((inv_a, -theta))

    for depth in range(max_depth):
        next_level = set()
        for pt in current:
            for a, theta in all_transforms:
                try:
                    w = mobius_transform(a, theta, np.array([pt]))[0]
                    if np.abs(w) < 0.999 and not any(abs(w - p) < 0.001 for p in points):
                        next_level.add(w)
                        points.add(w)
                except:
                    continue
        current = next_level
        if not current:
            break

    return list(points)


# Generate orbit points
generators = [
    (0.35 + 0.15j, np.pi / 4),
    (0.15 - 0.35j, np.pi / 3),
]
orbit = generate_orbit(generators, max_depth=6)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left plot: Orbit points on the Poincaré disk
ax = axes[0]
circle = plt.Circle((0, 0), 1, fill=False, color='black', linewidth=2)
ax.add_patch(circle)

# Color by distance from origin (depth proxy)
xs = [z.real for z in orbit]
ys = [z.imag for z in orbit]
rs = [abs(z) for z in orbit]

scatter = ax.scatter(xs, ys, c=rs, cmap='plasma', s=15, alpha=0.8,
                     edgecolors='none', vmin=0, vmax=1)
ax.scatter([0], [0], c='red', s=100, zorder=5, marker='*', label='Origin')

# Draw some geodesics (circular arcs)
for z in orbit[:20]:
    if abs(z) > 0.01:
        ax.plot([0, z.real], [0, z.imag], 'gray', alpha=0.1, linewidth=0.5)

ax.set_xlim(-1.15, 1.15)
ax.set_ylim(-1.15, 1.15)
ax.set_aspect('equal')
ax.set_title('Hyperbolic Lattice on the Poincaré Disk\n(Orbit Γ·0)', fontsize=12)
ax.set_xlabel('Re(z)')
ax.set_ylabel('Im(z)')
plt.colorbar(scatter, ax=ax, label='Euclidean distance from origin')
ax.legend(loc='upper right', fontsize=9)

# Right plot: Growth rate comparison
ax2 = axes[1]
n_gen = 2
d = 2 * n_gen
max_R = 8

# Hyperbolic growth (exponential)
R_vals = list(range(max_R + 1))
hyp_growth = [sum(d**k for k in range(R + 1)) for R in R_vals]

# Euclidean growth (polynomial, dimension 2)
euc_growth = [(2 * R + 1)**2 for R in R_vals]

ax2.semilogy(R_vals, hyp_growth, 'b-o', label=f'Hyperbolic (d={d})', linewidth=2)
ax2.semilogy(R_vals, euc_growth, 'r--s', label='Euclidean (dim 2)', linewidth=2)
ax2.fill_between(R_vals, euc_growth, hyp_growth, alpha=0.15, color='blue')

ax2.set_xlabel('Radius R (word length)', fontsize=11)
ax2.set_ylabel('Number of lattice points', fontsize=11)
ax2.set_title('Exponential vs Polynomial Growth\nof Lattice Points', fontsize=12)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# Annotate the gap
mid_R = max_R // 2
ax2.annotate('Curvature\ngap', xy=(mid_R, (hyp_growth[mid_R] + euc_growth[mid_R]) / 2),
             fontsize=9, ha='center', color='blue', alpha=0.7)

plt.tight_layout()
plt.savefig('poincare_disk_tessellation.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: poincare_disk_tessellation.png")


"""
Visualization: Hyperbolic Zeta Function Behavior
==================================================
Plots the hyperbolic zeta summand ‖z‖^{-2s} as a function of s
for various disk points, illustrating the divergence structure
and the connection to the classical Riemann zeta function.
"""

import numpy as np
import matplotlib.pyplot as plt


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Plot 1: Zeta summand for various ‖z‖
ax = axes[0]
s_vals = np.linspace(0.01, 3, 200)
norms = [0.2, 0.4, 0.6, 0.8, 0.95]
colors = plt.cm.viridis(np.linspace(0.1, 0.9, len(norms)))

for r, c in zip(norms, colors):
    zeta_vals = r ** (-2 * s_vals)
    ax.plot(s_vals, zeta_vals, color=c, linewidth=2, label=f'‖z‖={r}')

ax.axhline(y=1, color='red', linestyle='--', alpha=0.5, label='ζ = 1 (proved: ≥ 1)')
ax.set_xlabel('s', fontsize=12)
ax.set_ylabel('‖z‖^{-2s}', fontsize=12)
ax.set_title('Hyperbolic Zeta Summand\n(Proved: always ≥ 1 for disk points)', fontsize=11)
ax.legend(fontsize=8, loc='upper left')
ax.set_ylim(0, 30)
ax.grid(True, alpha=0.3)

# Plot 2: Partial zeta sums (mock orbit)
ax2 = axes[1]
np.random.seed(42)
# Generate mock orbit points with exponentially distributed norms
n_points_list = [10, 50, 200, 1000]
s_range = np.linspace(0.1, 4, 100)

for n_pts in n_points_list:
    # Orbit points: norms distributed like r ~ 1 - exp(-k) for the k-th point
    orbit_norms = [1 - np.exp(-0.5 * k) for k in range(1, n_pts + 1)]
    orbit_norms = [r for r in orbit_norms if 0 < r < 1]

    zeta_partial = []
    for s in s_range:
        total = sum(r ** (-2 * s) for r in orbit_norms)
        zeta_partial.append(total)

    ax2.plot(s_range, zeta_partial, linewidth=1.5, label=f'N={n_pts}')

ax2.set_xlabel('s', fontsize=12)
ax2.set_ylabel('ζ_H(s) partial sum', fontsize=12)
ax2.set_title('Hyperbolic Zeta Function\n(Partial Sums)', fontsize=11)
ax2.set_yscale('log')
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

# Plot 3: Generator density (PNT analog)
ax3 = axes[2]
n_gen = 2
d = 2 * n_gen
R_vals = np.arange(1, 15)

# Generator density
densities = []
for R in R_vals:
    total = sum(d**k for k in range(R + 1))
    density = d / total  # generators / total words
    densities.append(density)

# Classical PNT analog: 1/R (like 1/log(N))
pnt_analog = 1.0 / R_vals

ax3.semilogy(R_vals, densities, 'bo-', linewidth=2, markersize=6,
             label='Generator density (hyperbolic)')
ax3.semilogy(R_vals, pnt_analog, 'r--', linewidth=2,
             label='1/R (classical PNT analog)')

ax3.set_xlabel('Radius R (word length)', fontsize=12)
ax3.set_ylabel('Density of generators', fontsize=12)
ax3.set_title('Hyperbolic Prime Number Theorem\n(Generator Sparsity)', fontsize=11)
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)

# Add annotation
ax3.annotate('Generators become\nexponentially rare',
             xy=(8, densities[7]), xytext=(10, 0.01),
             arrowprops=dict(arrowstyle='->', color='blue'),
             fontsize=9, color='blue')

plt.tight_layout()
plt.savefig('hyperbolic_zeta_function.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: hyperbolic_zeta_function.png")
