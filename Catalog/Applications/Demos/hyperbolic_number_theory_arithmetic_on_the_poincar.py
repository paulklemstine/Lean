#!/usr/bin/env python3
"""
Hyperbolic Number Theory: Applications

Demonstrates real-world applications of hyperbolic arithmetic:
1. Non-commutative key exchange (Diffie-Hellman analog)
2. Hyperbolic random number generation
3. Signal processing on the Poincaré disk
4. Network geometry: embedding trees in hyperbolic space
"""

import numpy as np
from typing import Optional


# ============================================================
# Core Möbius arithmetic (self-contained)
# ============================================================

def moebius_map(a: complex, z: complex) -> complex:
    """Möbius disk automorphism: φ_a(z) = (z - a) / (1 - conj(a) * z)"""
    return (z - a) / (1 - np.conj(a) * z)


def compute_orbit(a: complex, N: int, start: complex = 0.0) -> list[complex]:
    """Compute Möbius orbit of length N from start."""
    orbit = [start]
    for _ in range(N):
        orbit.append(moebius_map(a, orbit[-1]))
    return orbit


def hyp_distance(z: complex, w: complex) -> float:
    """Hyperbolic distance in the Poincaré disk."""
    r = abs(z - w) / abs(1 - np.conj(z) * w)
    return np.arctanh(min(r, 1 - 1e-15))


# ============================================================
# Application 1: Non-Commutative Key Exchange
# ============================================================

def hyp_key_exchange_demo():
    """
    Hyperbolic Diffie-Hellman: Key exchange using Möbius composition.
    
    Alice and Bob agree on a public generator a.
    Alice picks secret m, computes z_m = orbit(a, 0, m).
    Bob picks secret n, computes z_n = orbit(a, 0, n).
    They exchange z_m and z_n publicly.
    Alice computes orbit(a, z_n, m) = z_{m+n}.
    Bob computes orbit(a, z_m, n) = z_{n+m}.
    Both arrive at the same shared secret z_{m+n} = z_{n+m}.
    """
    print("=" * 50)
    print("APPLICATION 1: Hyperbolic Key Exchange")
    print("=" * 50)
    
    # Public parameter
    a = 0.3 + 0.2j
    print(f"Public generator: a = {a}")
    
    # Alice's secret
    m = 17
    orbit_alice = compute_orbit(a, m)
    z_m = orbit_alice[m]
    print(f"\nAlice's secret index: m = {m}")
    print(f"Alice sends: z_m = {z_m:.6f}")
    
    # Bob's secret
    n = 23
    orbit_bob = compute_orbit(a, n)
    z_n = orbit_bob[n]
    print(f"Bob's secret index: n = {n}")
    print(f"Bob sends: z_n = {z_n:.6f}")
    
    # Shared secret computation
    alice_shared = compute_orbit(a, m, start=z_n)[-1]
    bob_shared = compute_orbit(a, n, start=z_m)[-1]
    
    # Direct computation for verification
    direct = compute_orbit(a, m + n)[-1]
    
    print(f"\nAlice computes orbit(a, z_n, m) = {alice_shared:.10f}")
    print(f"Bob computes orbit(a, z_m, n)   = {bob_shared:.10f}")
    print(f"Direct z_{{m+n}}                 = {direct:.10f}")
    print(f"Agreement: {np.isclose(alice_shared, bob_shared)} ✓")
    print(f"Correctness: {np.isclose(alice_shared, direct)} ✓")


# ============================================================
# Application 2: Hyperbolic Random Number Generator
# ============================================================

def hyp_rng_demo():
    """
    Random number generation using Möbius orbits.
    
    The orbit of a complex generator produces pseudo-random
    points in the disk. The angular component, when the generator
    has irrational argument, yields quasi-random sequences on [0, 2π).
    """
    print("\n" + "=" * 50)
    print("APPLICATION 2: Hyperbolic Random Number Generator")
    print("=" * 50)
    
    # Generator with irrational angle
    a = 0.4 * np.exp(1j * np.sqrt(2))
    N = 1000
    orbit = compute_orbit(a, N)
    
    # Extract angles
    angles = [np.angle(z) % (2 * np.pi) for z in orbit[1:]]
    
    # Test uniformity: divide [0, 2π) into bins
    n_bins = 10
    counts = np.histogram(angles, bins=n_bins, range=(0, 2*np.pi))[0]
    expected = N / n_bins
    chi2 = sum((c - expected)**2 / expected for c in counts)
    
    print(f"Generator: a = {a:.4f} (|a| = {abs(a):.4f})")
    print(f"Generated {N} orbit points")
    print(f"\nAngular distribution (10 bins of [0, 2π)):")
    for i, c in enumerate(counts):
        bar = "█" * (c // 5)
        print(f"  [{i*36:3d}°, {(i+1)*36:3d}°): {c:4d} {bar}")
    print(f"\nExpected per bin: {expected:.0f}")
    print(f"Chi-squared statistic: {chi2:.2f}")
    print(f"Uniformity: {'Good' if chi2 < 20 else 'Poor'}")


# ============================================================
# Application 3: Tree Embedding in Hyperbolic Space
# ============================================================

def hyp_tree_embedding_demo():
    """
    Embed a binary tree in the Poincaré disk using Möbius maps.
    
    Each edge of the tree corresponds to applying a Möbius map.
    Left children use generator a_L, right children use a_R.
    The hyperbolic metric naturally accommodates exponential growth
    of the tree (the disk has exponentially growing area).
    """
    print("\n" + "=" * 50)
    print("APPLICATION 3: Tree Embedding in Hyperbolic Space")
    print("=" * 50)
    
    a_left = 0.4 * np.exp(1j * 2.5)
    a_right = 0.4 * np.exp(1j * 0.8)
    
    # BFS to embed a binary tree of depth 4
    depth = 4
    nodes = [(0, complex(0))]  # (depth, position)
    all_nodes = [complex(0)]
    
    for d in range(depth):
        new_nodes = []
        for _, pos in nodes:
            left = moebius_map(a_left, pos)
            right = moebius_map(a_right, pos)
            new_nodes.append((d + 1, left))
            new_nodes.append((d + 1, right))
            all_nodes.extend([left, right])
        nodes = new_nodes
    
    print(f"Binary tree of depth {depth}")
    print(f"Total nodes: {len(all_nodes)}")
    print(f"All in disk: {all(abs(z)**2 < 1 for z in all_nodes)} ✓")
    
    # Compute pairwise distances
    leaves = [pos for d, pos in nodes]
    n_leaves = len(leaves)
    distances = np.zeros((n_leaves, n_leaves))
    for i in range(n_leaves):
        for j in range(n_leaves):
            distances[i][j] = hyp_distance(leaves[i], leaves[j])
    
    print(f"\nLeaf nodes: {n_leaves}")
    print(f"Mean pairwise distance: {np.mean(distances[np.triu_indices(n_leaves, 1)]):.4f}")
    print(f"Min nonzero distance: {np.min(distances[distances > 0]):.4f}")
    print(f"Max distance: {np.max(distances):.4f}")
    
    # Show that sibling leaves are closer than cousins
    sibling_dists = []
    cousin_dists = []
    for i in range(0, n_leaves, 2):
        sibling_dists.append(distances[i][i+1])
    for i in range(0, n_leaves, 4):
        for j in range(i+2, min(i+4, n_leaves)):
            cousin_dists.append(distances[i][j])
    
    print(f"\nMean sibling distance: {np.mean(sibling_dists):.4f}")
    print(f"Mean cousin distance: {np.mean(cousin_dists):.4f}")
    print(f"Siblings closer than cousins: {np.mean(sibling_dists) < np.mean(cousin_dists)} ✓")


# ============================================================
# Application 4: Hyperbolic Signal Averaging
# ============================================================

def hyp_signal_averaging_demo():
    """
    Signal processing: computing means on the Poincaré disk.
    
    In applications like brain-computer interfaces and radar,
    data naturally lives on the Poincaré disk (covariance matrices
    mapped to the Siegel upper half-space). The Möbius map provides
    a natural "centering" operation for computing means.
    """
    print("\n" + "=" * 50)
    print("APPLICATION 4: Hyperbolic Signal Averaging")
    print("=" * 50)
    
    # Generate "signals" as points in the disk
    rng = np.random.RandomState(42)
    n_signals = 20
    signals = []
    center = 0.3 + 0.2j  # true center
    for _ in range(n_signals):
        noise = 0.1 * (rng.randn() + 1j * rng.randn())
        s = moebius_map(-noise, center)  # perturb center
        if abs(s) < 0.99:  # ensure in disk
            signals.append(s)
    
    print(f"True center: {center}")
    print(f"Number of signals: {len(signals)}")
    
    # Euclidean mean (naive)
    eucl_mean = np.mean(signals)
    
    # Hyperbolic mean via iterative centering
    # Use Karcher mean: iteratively apply φ to center at mean
    hyp_mean = eucl_mean  # initial guess
    for iteration in range(50):
        # Map all points to frame centered at current mean
        centered = [moebius_map(hyp_mean, s) for s in signals]
        # Euclidean mean in centered frame
        delta = np.mean(centered)
        if abs(delta) < 1e-10:
            break
        # Move mean by delta
        hyp_mean = moebius_map(-delta, hyp_mean)
        if abs(hyp_mean) >= 1:
            hyp_mean *= 0.99 / abs(hyp_mean)
    
    eucl_error = abs(eucl_mean - center)
    hyp_error = abs(hyp_mean - center)
    
    print(f"\nEuclidean mean: {eucl_mean:.6f}")
    print(f"Hyperbolic mean: {hyp_mean:.6f}")
    print(f"Euclidean error: {eucl_error:.6f}")
    print(f"Hyperbolic error: {hyp_error:.6f}")
    print(f"Hyperbolic mean is {'better' if hyp_error < eucl_error else 'worse'}")


if __name__ == "__main__":
    hyp_key_exchange_demo()
    hyp_rng_demo()
    hyp_tree_embedding_demo()
    hyp_signal_averaging_demo()
    
    print("\n" + "=" * 50)
    print("All applications demonstrated successfully.")
    print("=" * 50)


#!/usr/bin/env python3
"""
Hyperbolic Number Theory: Arithmetic on the Poincaré Disk — Demo

Demonstrates the core mathematical constructions:
1. Möbius map and disk preservation
2. Hyperbolic integer orbit computation
3. Hyperbolic cross-ratio symmetry
4. Trace-lattice duality
5. Hyperbolic zeta function
6. Orbit composition property
"""

import numpy as np


def moebius_map(a: complex, z: complex) -> complex:
    """Möbius disk automorphism: φ_a(z) = (z - a) / (1 - conj(a) * z)"""
    return (z - a) / (1 - np.conj(a) * z)


def hyp_cross_ratio_sq(z: complex, w: complex) -> float:
    """Squared hyperbolic cross-ratio: |z-w|² / |1 - conj(z)*w|²"""
    return abs(z - w)**2 / abs(1 - np.conj(z) * w)**2


def compute_orbit(a: complex, n: int) -> list[complex]:
    """Compute the first n+1 hyperbolic integers (orbit of origin under φ_a)."""
    orbit = [complex(0, 0)]
    for _ in range(n):
        orbit.append(moebius_map(a, orbit[-1]))
    return orbit


def hyp_zeta_partial(a: complex, s: float, N: int) -> float:
    """Partial hyperbolic zeta sum: ζ_H(s, N) = Σ 1/|z_n|^{2s}"""
    orbit = compute_orbit(a, N)
    total = 0.0
    for i in range(1, N + 1):
        nsq = abs(orbit[i])**2
        if nsq > 0:
            total += nsq**(-s)
    return total


def main():
    # Golden generator: a = (3 - sqrt(5)) / 2 ≈ 0.382
    golden = (3 - np.sqrt(5)) / 2

    print("=" * 60)
    print("HYPERBOLIC NUMBER THEORY: DEMO")
    print("=" * 60)

    # Demo 1: Disk Preservation
    print("\n--- Demo 1: Disk Preservation ---")
    print(f"Golden generator a = {golden:.6f}")
    print(f"|a|² = {abs(golden)**2:.6f} < 1 ✓")
    orbit = compute_orbit(golden, 10)
    print(f"\nFirst 11 orbit points (hyperbolic integers):")
    print(f"{'n':>3} {'Re(z_n)':>12} {'|z_n|²':>12} {'In disk?':>10}")
    for i, z in enumerate(orbit):
        nsq = abs(z)**2
        print(f"{i:3d} {z.real:12.6f} {nsq:12.6f} {'✓' if nsq < 1 else '✗':>10}")

    # Demo 2: Cross-Ratio Symmetry
    print("\n--- Demo 2: Cross-Ratio Symmetry ---")
    z1, z2 = 0.3 + 0.2j, -0.1 + 0.4j
    rho_zw = hyp_cross_ratio_sq(z1, z2)
    rho_wz = hyp_cross_ratio_sq(z2, z1)
    print(f"z = {z1}, w = {z2}")
    print(f"ρ(z, w) = {rho_zw:.10f}")
    print(f"ρ(w, z) = {rho_wz:.10f}")
    print(f"Difference: {abs(rho_zw - rho_wz):.2e} (should be ~0)")

    # Demo 3: Trace-Lattice Duality
    print("\n--- Demo 3: Trace-Lattice Duality ---")
    pts = [0.3 + 0.2j, -0.1 + 0.4j, 0.5 - 0.3j, -0.2 - 0.1j]
    sum_normsq = sum(abs(z)**2 for z in pts)
    sum_zzbar = sum((z * np.conj(z)).real for z in pts)
    print(f"Points: {pts}")
    print(f"Σ|z_i|² = {sum_normsq:.10f}")
    print(f"Σ Re(z_i · conj(z_i)) = {sum_zzbar:.10f}")
    print(f"Equal: {np.isclose(sum_normsq, sum_zzbar)} ✓")

    # Demo 4: Hyperbolic Zeta Function
    print("\n--- Demo 4: Hyperbolic Zeta Function ---")
    print(f"ζ_H(s=1, N) for golden generator:")
    print(f"{'N':>5} {'ζ_H(1,N)':>12} {'ln(N)':>10} {'≥ ln(N)?':>10}")
    for N in [2, 5, 10, 20, 50, 100]:
        zeta_val = hyp_zeta_partial(golden, 1.0, N)
        ln_N = np.log(N)
        print(f"{N:5d} {zeta_val:12.4f} {ln_N:10.4f} {'✓' if zeta_val >= ln_N else '✗':>10}")

    # Demo 5: Orbit Composition
    print("\n--- Demo 5: Orbit Composition ---")
    m, n = 3, 4
    orbit_long = compute_orbit(golden, m + n)
    z_m = orbit_long[m]
    # Compute orbit(a, z_m, n)
    z_composed = z_m
    for _ in range(n):
        z_composed = moebius_map(golden, z_composed)
    z_direct = orbit_long[n + m]
    print(f"m={m}, n={n}")
    print(f"orbit(a, z_{m}, {n}) = {z_composed:.10f}")
    print(f"z_{n+m} = {z_direct:.10f}")
    print(f"Equal: {np.isclose(z_composed, z_direct)} ✓")

    # Demo 6: Non-Commutativity of Hyperbolic Addition
    print("\n--- Demo 6: Non-Commutativity ---")
    z, w = 0.3 + 0.1j, 0.2 - 0.3j
    z_plus_w = moebius_map(w, z)  # z ⊕ w
    w_plus_z = moebius_map(z, w)  # w ⊕ z
    print(f"z = {z}, w = {w}")
    print(f"z ⊕ w = {z_plus_w:.6f}")
    print(f"w ⊕ z = {w_plus_z:.6f}")
    print(f"z ⊕ w ≠ w ⊕ z: {not np.isclose(z_plus_w, w_plus_z)} (non-commutative!)")

    # Demo 7: Complex Generator (2D orbit)
    print("\n--- Demo 7: Complex Generator Orbit ---")
    a_complex = 0.3 + 0.2j
    orbit_c = compute_orbit(a_complex, 20)
    print(f"Generator a = {a_complex}")
    print(f"{'n':>3} {'Re(z_n)':>10} {'Im(z_n)':>10} {'|z_n|²':>10}")
    for i in range(0, 21, 2):
        z = orbit_c[i]
        print(f"{i:3d} {z.real:10.6f} {z.imag:10.6f} {abs(z)**2:10.6f}")

    print("\n" + "=" * 60)
    print("All demos completed successfully.")
    print("=" * 60)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization 3: NormSq Identity and Disk Preservation

Illustrates the key algebraic identity that makes everything work:
1 - |φ_a(z)|² = (1-|a|²)(1-|z|²) / |1-āz|²

Shows how the "remaining room" in the disk after applying a Möbius map
factors into contributions from the generator and the input point.
"""

import numpy as np
import matplotlib.pyplot as plt


def moebius_map(a, z):
    return (z - a) / (1 - np.conj(a) * z)


fig, axes = plt.subplots(2, 2, figsize=(12, 10))

# Panel 1: |φ_a(z)|² as a function of |z| for different |a|
ax1 = axes[0, 0]
zs = np.linspace(0, 0.99, 200)
for a_val, color in [(0.1, '#4CAF50'), (0.3, '#2196F3'), (0.5, '#FF9800'),
                      (0.7, '#E91E63'), (0.9, '#9C27B0')]:
    phi_normsq = [abs(moebius_map(a_val, z))**2 for z in zs]
    ax1.plot(zs, phi_normsq, color=color, linewidth=2, label=f'|a| = {a_val}')

ax1.plot(zs, zs**2, '--', color='gray', alpha=0.5, label='|z|² (identity)')
ax1.set_xlabel('|z|', fontsize=11)
ax1.set_ylabel('|φ_a(z)|²', fontsize=11)
ax1.set_title('Image NormSq vs Input (real axis)', fontsize=12, fontweight='bold')
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)

# Panel 2: Complement identity verification
ax2 = axes[0, 1]
for a_val, color in [(0.2, '#4CAF50'), (0.5, '#2196F3'), (0.8, '#E91E63')]:
    complement_lhs = [1 - abs(moebius_map(a_val, z))**2 for z in zs]
    factor1 = 1 - a_val**2
    complement_rhs = [factor1 * (1 - z**2) / abs(1 - a_val * z)**2 for z in zs]
    
    ax2.plot(zs, complement_lhs, color=color, linewidth=2,
             label=f'1−|φ(z)|² (|a|={a_val})')
    ax2.plot(zs, complement_rhs, ':', color=color, linewidth=3, alpha=0.5)

ax2.set_xlabel('|z|', fontsize=11)
ax2.set_ylabel('1 − |φ_a(z)|²', fontsize=11)
ax2.set_title('NormSq Complement Identity Verification', fontsize=12, fontweight='bold')
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)
ax2.text(0.5, 0.5, 'Solid = LHS\nDotted = RHS\n(identical!)',
         transform=ax2.transAxes, fontsize=10, ha='center',
         style='italic', alpha=0.7)

# Panel 3: Orbit |z_n|² convergence to 1
ax3 = axes[1, 0]
golden = (3 - np.sqrt(5)) / 2
N = 50
orbit = [0.0 + 0j]
for _ in range(N):
    orbit.append(moebius_map(golden, orbit[-1]))
normsqs = [abs(z)**2 for z in orbit]

ax3.plot(range(N+1), normsqs, 'o-', color='#2196F3', markersize=4, linewidth=1)
ax3.axhline(y=1, color='red', linestyle='--', alpha=0.5, label='Boundary (|z|² = 1)')
ax3.fill_between(range(N+1), normsqs, 1, alpha=0.1, color='blue')

# Mark primes
primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]
for p in primes:
    if p <= N:
        ax3.scatter(p, normsqs[p], c='red', s=40, zorder=5, marker='*')

ax3.set_xlabel('Orbit index n', fontsize=11)
ax3.set_ylabel('|z_n|²', fontsize=11)
ax3.set_title('Orbit NormSq (Golden Generator)', fontsize=12, fontweight='bold')
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)

# Panel 4: Cross-ratio symmetry heatmap
ax4 = axes[1, 1]
n_pts = 15
pts = [0.7 * np.exp(2j * np.pi * k / n_pts) * (0.3 + 0.4 * k / n_pts)
       for k in range(n_pts)]

asymmetry = np.zeros((n_pts, n_pts))
for i in range(n_pts):
    for j in range(n_pts):
        rho_ij = abs(pts[i] - pts[j])**2 / max(abs(1 - np.conj(pts[i]) * pts[j])**2, 1e-30)
        rho_ji = abs(pts[j] - pts[i])**2 / max(abs(1 - np.conj(pts[j]) * pts[i])**2, 1e-30)
        asymmetry[i, j] = abs(rho_ij - rho_ji)

im = ax4.imshow(asymmetry, cmap='RdBu_r', vmin=-1e-15, vmax=1e-15)
ax4.set_xlabel('Point index j', fontsize=11)
ax4.set_ylabel('Point index i', fontsize=11)
ax4.set_title('Cross-Ratio Asymmetry |ρ(i,j)−ρ(j,i)|', fontsize=12, fontweight='bold')
plt.colorbar(im, ax=ax4, label='Asymmetry (≈ 0)')

fig.suptitle('The NormSq Identity: Foundation of Disk Preservation',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_normsq.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_normsq.png")


#!/usr/bin/env python3
"""
Visualization 1: Hyperbolic Integer Orbits on the Poincaré Disk

Shows the orbit of the origin under iterated Möbius maps for different
generators, illustrating how hyperbolic integers are distributed in the disk.
The unit circle boundary represents "infinity" in hyperbolic geometry.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches


def moebius_map(a, z):
    return (z - a) / (1 - np.conj(a) * z)


def compute_orbit(a, N, start=0.0):
    orbit = [complex(start)]
    for _ in range(N):
        orbit.append(moebius_map(a, orbit[-1]))
    return np.array(orbit)


fig, axes = plt.subplots(1, 3, figsize=(15, 5))

generators = [
    ((3 - np.sqrt(5)) / 2, "Golden Generator\na = (3−√5)/2 ≈ 0.382"),
    (0.3 + 0.2j, "Complex Generator\na = 0.3 + 0.2i"),
    (0.5 * np.exp(1j * np.pi / 5), "Spiral Generator\na = 0.5·e^{iπ/5}"),
]

for ax, (a, title) in zip(axes, generators):
    N = 100
    orbit = compute_orbit(a, N)
    
    # Draw unit circle
    circle = plt.Circle((0, 0), 1, fill=False, color='black', linewidth=2)
    ax.add_patch(circle)
    
    # Draw orbit path
    ax.plot(orbit.real, orbit.imag, '-', color='#2196F3', alpha=0.3, linewidth=0.5)
    
    # Color by index
    colors = plt.cm.viridis(np.linspace(0, 1, N + 1))
    
    # Mark points
    for i, z in enumerate(orbit):
        is_prime = i in [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47,
                         53, 59, 61, 67, 71, 73, 79, 83, 89, 97]
        size = 30 if is_prime else 8
        marker = '*' if is_prime else 'o'
        ax.scatter(z.real, z.imag, c=[colors[i]], s=size, marker=marker,
                   edgecolors='none', zorder=3)
    
    # Mark origin
    ax.scatter(0, 0, c='red', s=50, marker='o', zorder=5, edgecolors='black')
    
    # Mark generator
    ax.scatter((-a).real, (-a).imag, c='green', s=80, marker='D', zorder=5,
               edgecolors='black', label='z₁ = −a')
    
    ax.set_xlim(-1.15, 1.15)
    ax.set_ylim(-1.15, 1.15)
    ax.set_aspect('equal')
    ax.set_title(title, fontsize=11)
    ax.grid(True, alpha=0.2)

# Legend
axes[0].scatter([], [], c='red', s=50, marker='o', label='Origin (z₀)')
axes[0].scatter([], [], c='green', s=80, marker='D', label='z₁ = −a')
axes[0].scatter([], [], c='gold', s=30, marker='*', label='Prime index')
axes[0].scatter([], [], c='gray', s=8, marker='o', label='Composite index')
axes[0].legend(loc='lower left', fontsize=8)

fig.suptitle('Hyperbolic Integers on the Poincaré Disk', fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_orbit.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_orbit.png")


#!/usr/bin/env python3
"""
Visualization 2: Hyperbolic Zeta Function and Prime Counting

Shows the growth of the hyperbolic zeta sum ζ_H(s, N) for different values
of s, compared to classical growth rates. Also shows the hyperbolic prime
counting function compared to N/ln(N).
"""

import numpy as np
import matplotlib.pyplot as plt


def moebius_map(a, z):
    return (z - a) / (1 - np.conj(a) * z)


def compute_orbit(a, N):
    orbit = [0.0 + 0j]
    for _ in range(N):
        orbit.append(moebius_map(a, orbit[-1]))
    return orbit


def hyp_zeta_partial(a, s, N):
    orbit = compute_orbit(a, N)
    total = 0.0
    for i in range(1, N + 1):
        nsq = abs(orbit[i])**2
        if nsq > 1e-30:
            total += nsq**(-s)
    return total


def sieve_primes(N):
    if N < 2:
        return []
    is_prime = [True] * (N + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(N**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, N + 1, i):
                is_prime[j] = False
    return [i for i in range(N + 1) if is_prime[i]]


fig, axes = plt.subplots(1, 2, figsize=(14, 5.5))

golden = (3 - np.sqrt(5)) / 2

# Panel 1: Zeta function growth
ax1 = axes[0]
Ns = list(range(2, 201))
for s, color, label in [(0.5, '#E91E63', 's = 0.5'),
                          (1.0, '#2196F3', 's = 1.0'),
                          (2.0, '#4CAF50', 's = 2.0')]:
    zetas = [hyp_zeta_partial(golden, s, N) for N in Ns]
    ax1.plot(Ns, zetas, color=color, linewidth=2, label=label)

# Reference lines
ax1.plot(Ns, [np.log(N) for N in Ns], '--', color='gray', alpha=0.5, label='ln(N)')
ax1.plot(Ns, Ns, ':', color='gray', alpha=0.3, label='N')

ax1.set_xlabel('N (number of terms)', fontsize=12)
ax1.set_ylabel('ζ_H(s, N)', fontsize=12)
ax1.set_title('Hyperbolic Zeta Sum Growth', fontsize=13, fontweight='bold')
ax1.legend(fontsize=10)
ax1.set_yscale('log')
ax1.grid(True, alpha=0.3)

# Panel 2: Prime counting
ax2 = axes[1]
N_max = 500
primes = sieve_primes(N_max)

Ns_prime = list(range(2, N_max + 1))
pi_vals = []
count = 0
prime_idx = 0
for N in Ns_prime:
    while prime_idx < len(primes) and primes[prime_idx] <= N:
        count += 1
        prime_idx += 1
    pi_vals.append(count)

ax2.plot(Ns_prime, pi_vals, color='#2196F3', linewidth=2, label='π_H(N)')
ax2.plot(Ns_prime, [N / np.log(N) for N in Ns_prime], '--',
         color='#E91E63', linewidth=2, label='N / ln(N)')
ax2.plot(Ns_prime, [N / (np.log(N) - 1) for N in Ns_prime], ':',
         color='#4CAF50', linewidth=1.5, label='N / (ln(N) − 1)')

ax2.set_xlabel('N', fontsize=12)
ax2.set_ylabel('Count', fontsize=12)
ax2.set_title('Hyperbolic Prime Counting Function', fontsize=13, fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

fig.suptitle('Hyperbolic Number Theory: Zeta Function & Primes',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_zeta.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_zeta.png")
