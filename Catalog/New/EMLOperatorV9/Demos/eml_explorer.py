#!/usr/bin/env python3
"""
EML Operator Explorer — Interactive Computational Demos

Demonstrates the key mathematical properties of eml(x,y) = exp(x) - ln(y):
1. Surface and contour plots
2. Diagonal map dynamics and orbit divergence
3. g-map fixed point iteration
4. Self-pairing analysis
5. EML constants hierarchy
6. Complexity tree enumeration
7. AM-GM bridge visualization
8. Information-theoretic connections

Requirements: numpy, matplotlib
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib import cm
from itertools import product
import json
import os

OUTPUT_DIR = os.path.dirname(os.path.abspath(__file__))

# ─── Core EML Functions ───

def eml(x, y):
    """The EML operator: eml(x, y) = exp(x) - ln(y)"""
    return np.exp(x) - np.log(y)

def diag(z):
    """Diagonal map: d(z) = exp(z) - ln(z)"""
    return np.exp(z) - np.log(z)

def gmap(z):
    """g-map: g(z) = e - ln(z)"""
    return np.e - np.log(z)

def self_pair(x):
    """Self-pairing: σ(x) = exp(x) - x"""
    return np.exp(x) - x

def eml_neg(x):
    """Negation involution: N(x) = 1 - x"""
    return 1.0 - x

# ─── Demo 1: EML Surface Plot ───

def demo_surface():
    """3D surface plot of eml(x, y) = exp(x) - ln(y)"""
    fig = plt.figure(figsize=(12, 8))
    ax = fig.add_subplot(111, projection='3d')

    x = np.linspace(-2, 3, 100)
    y = np.linspace(0.01, 5, 100)
    X, Y = np.meshgrid(x, y)
    Z = eml(X, Y)

    # Clip for visualization
    Z = np.clip(Z, -5, 25)

    surf = ax.plot_surface(X, Y, Z, cmap=cm.viridis, alpha=0.8,
                           linewidth=0, antialiased=True)

    ax.set_xlabel('x', fontsize=14)
    ax.set_ylabel('y', fontsize=14)
    ax.set_zlabel('eml(x, y)', fontsize=14)
    ax.set_title('EML Operator: eml(x, y) = exp(x) − ln(y)', fontsize=16)

    fig.colorbar(surf, shrink=0.5, aspect=5)
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'eml_surface.png'), dpi=150)
    plt.close()
    print("✓ Generated eml_surface.png")

# ─── Demo 2: Level Curves ───

def demo_level_curves():
    """Contour plot showing level sets of eml"""
    fig, ax = plt.subplots(figsize=(10, 8))

    x = np.linspace(-3, 4, 400)
    y = np.linspace(0.01, 10, 400)
    X, Y = np.meshgrid(x, y)
    Z = eml(X, Y)

    levels = np.arange(-5, 25, 1)
    cs = ax.contour(X, Y, Z, levels=levels, cmap='RdYlBu_r', linewidths=1.2)
    ax.clabel(cs, inline=True, fontsize=8)

    # Mark special points
    ax.plot(0, 1, 'ko', markersize=10, label='eml(0,1) = 1')
    ax.plot(1, 1, 'rs', markersize=10, label=f'eml(1,1) = e ≈ {np.e:.3f}')

    ax.set_xlabel('x', fontsize=14)
    ax.set_ylabel('y', fontsize=14)
    ax.set_title('Level Curves of eml(x, y) = exp(x) − ln(y)', fontsize=16)
    ax.legend(fontsize=12)
    ax.set_ylim(0.01, 10)
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'eml_contours.png'), dpi=150)
    plt.close()
    print("✓ Generated eml_contours.png")

# ─── Demo 3: Diagonal Map Dynamics ───

def demo_diagonal_dynamics():
    """Orbit divergence of d(z) = exp(z) - ln(z)"""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: Show d(z) vs z
    z = np.linspace(0.01, 3, 1000)
    dz = diag(z)

    axes[0].plot(z, dz, 'b-', linewidth=2, label='d(z) = exp(z) − ln(z)')
    axes[0].plot(z, z, 'r--', linewidth=1.5, label='y = z')
    axes[0].plot(z, z + 1, 'g--', linewidth=1.5, label='y = z + 1')
    axes[0].fill_between(z, z, dz, alpha=0.1, color='blue')
    axes[0].set_xlabel('z', fontsize=14)
    axes[0].set_ylabel('d(z)', fontsize=14)
    axes[0].set_title('d(z) > z: No Real Fixed Points', fontsize=14)
    axes[0].legend(fontsize=11)
    axes[0].set_xlim(0, 3)
    axes[0].set_ylim(0, 8)
    axes[0].grid(True, alpha=0.3)

    # Right: Orbit divergence
    z0_values = [0.5, 1.0, 1.5, 2.0]
    colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3']

    for z0, color in zip(z0_values, colors):
        orbit = [z0]
        z_curr = z0
        for _ in range(8):
            z_curr = diag(z_curr)
            if z_curr > 1e15:
                break
            orbit.append(z_curr)
        axes[1].semilogy(range(len(orbit)), orbit, 'o-', color=color,
                        linewidth=2, markersize=6, label=f'z₀ = {z0}')

    axes[1].set_xlabel('Iteration n', fontsize=14)
    axes[1].set_ylabel('dⁿ(z₀)', fontsize=14)
    axes[1].set_title('Super-Exponential Orbit Divergence', fontsize=14)
    axes[1].legend(fontsize=11)
    axes[1].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'diagonal_dynamics.png'), dpi=150)
    plt.close()
    print("✓ Generated diagonal_dynamics.png")

# ─── Demo 4: g-Map Fixed Point ───

def demo_gmap_fixedpoint():
    """g-map iteration converging to z* ≈ 2.017"""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: g(z) vs z, showing the fixed point
    z = np.linspace(0.1, 5, 1000)
    gz = gmap(z)

    axes[0].plot(z, gz, 'b-', linewidth=2, label='g(z) = e − ln(z)')
    axes[0].plot(z, z, 'r--', linewidth=1.5, label='y = z')

    # Find fixed point numerically
    z_star = 2.0
    for _ in range(100):
        z_star = gmap(z_star)
    axes[0].plot(z_star, z_star, 'go', markersize=12,
                label=f'z* ≈ {z_star:.4f}')

    axes[0].set_xlabel('z', fontsize=14)
    axes[0].set_ylabel('g(z)', fontsize=14)
    axes[0].set_title(f'g-Map Fixed Point: z* = W(eᵉ) ≈ {z_star:.4f}', fontsize=14)
    axes[0].legend(fontsize=11)
    axes[0].set_xlim(0.1, 5)
    axes[0].set_ylim(0, 5)
    axes[0].grid(True, alpha=0.3)

    # Right: Convergence visualization
    z0 = 0.5
    orbit = [z0]
    for _ in range(20):
        z0 = gmap(z0)
        orbit.append(z0)

    axes[1].plot(range(len(orbit)), orbit, 'bo-', markersize=6, linewidth=1.5)
    axes[1].axhline(y=z_star, color='r', linestyle='--', label=f'z* ≈ {z_star:.4f}')
    axes[1].set_xlabel('Iteration n', fontsize=14)
    axes[1].set_ylabel('gⁿ(z₀)', fontsize=14)
    axes[1].set_title('g-Map Convergence (z₀ = 0.5)', fontsize=14)
    axes[1].legend(fontsize=11)
    axes[1].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'gmap_fixedpoint.png'), dpi=150)
    plt.close()
    print("✓ Generated gmap_fixedpoint.png")

# ─── Demo 5: Self-Pairing and Convexity ───

def demo_self_pairing():
    """σ(x) = exp(x) - x: strictly convex with minimum at x=0"""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    x = np.linspace(-3, 3, 1000)
    sigma = self_pair(x)

    axes[0].plot(x, sigma, 'b-', linewidth=2.5, label='σ(x) = eˣ − x')
    axes[0].plot(0, 1, 'ro', markersize=10, label='Minimum: σ(0) = 1')
    axes[0].axhline(y=1, color='r', linestyle='--', alpha=0.5)
    axes[0].fill_between(x, 1, sigma, alpha=0.1, color='blue')
    axes[0].set_xlabel('x', fontsize=14)
    axes[0].set_ylabel('σ(x)', fontsize=14)
    axes[0].set_title('Self-Pairing Function (Strictly Convex)', fontsize=14)
    axes[0].legend(fontsize=12)
    axes[0].set_ylim(0, 10)
    axes[0].grid(True, alpha=0.3)

    # Right: Derivative showing sign change at x=0
    sigma_prime = np.exp(x) - 1

    axes[1].plot(x, sigma_prime, 'g-', linewidth=2.5, label="σ'(x) = eˣ − 1")
    axes[1].axhline(y=0, color='k', linewidth=0.5)
    axes[1].axvline(x=0, color='r', linestyle='--', alpha=0.5)
    axes[1].fill_between(x, 0, sigma_prime, where=(sigma_prime < 0),
                         alpha=0.2, color='red', label='Decreasing')
    axes[1].fill_between(x, 0, sigma_prime, where=(sigma_prime > 0),
                         alpha=0.2, color='green', label='Increasing')
    axes[1].set_xlabel('x', fontsize=14)
    axes[1].set_ylabel("σ'(x)", fontsize=14)
    axes[1].set_title("Derivative: Critical Point at x = 0", fontsize=14)
    axes[1].legend(fontsize=12)
    axes[1].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'self_pairing.png'), dpi=150)
    plt.close()
    print("✓ Generated self_pairing.png")

# ─── Demo 6: EML Constants Hierarchy ───

def demo_constants():
    """The e-tower and EML-reachable constants"""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: E-tower
    tower = [1.0]
    for i in range(5):
        tower.append(np.exp(tower[-1]))
        if tower[-1] > 1e100:
            break

    n = len(tower)
    axes[0].semilogy(range(n), tower, 'ro-', markersize=10, linewidth=2)
    for i, v in enumerate(tower):
        if v < 1e10:
            axes[0].annotate(f'e↑↑{i} ≈ {v:.2f}', (i, v),
                           textcoords="offset points", xytext=(10, 10),
                           fontsize=10)
    axes[0].set_xlabel('Level n', fontsize=14)
    axes[0].set_ylabel('e↑↑n (log scale)', fontsize=14)
    axes[0].set_title('E-Tower: Iterated Exponential', fontsize=14)
    axes[0].grid(True, alpha=0.3)

    # Right: Constants from small EML trees
    # Enumerate constants reachable from 1-node, 2-node, 3-node trees
    def eml_constants(max_depth=4):
        """Generate all EML constants up to given tree depth"""
        constants = {0: {1.0}}  # 0-node: just the constant 1
        all_constants = {1.0}

        for depth in range(1, max_depth + 1):
            new_consts = set()
            for d1 in range(depth):
                for d2 in range(depth):
                    if d1 + d2 + 1 != depth:
                        continue
                    for c1 in constants.get(d1, set()):
                        for c2 in constants.get(d2, set()):
                            if c2 > 0:
                                try:
                                    val = np.exp(c1) - np.log(c2)
                                    if np.isfinite(val) and abs(val) < 1e100:
                                        new_consts.add(round(val, 10))
                                except:
                                    pass
            constants[depth] = new_consts
            all_constants.update(new_consts)

        return constants, sorted(all_constants)

    consts_by_depth, all_consts = eml_constants(5)

    # Plot histogram of constants
    finite_consts = [c for c in all_consts if abs(c) < 50]
    axes[1].hist(finite_consts, bins=50, color='steelblue', edgecolor='black', alpha=0.7)
    axes[1].set_xlabel('Constant Value', fontsize=14)
    axes[1].set_ylabel('Count', fontsize=14)
    axes[1].set_title(f'EML Constants (≤5 nodes): {len(all_consts)} distinct values', fontsize=14)
    axes[1].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'eml_constants.png'), dpi=150)
    plt.close()
    print(f"✓ Generated eml_constants.png ({len(all_consts)} constants found)")

# ─── Demo 7: AM-GM Bridge ───

def demo_amgm():
    """Visualize the AM-GM connection: trace ≥ 2"""
    fig, ax = plt.subplots(figsize=(10, 8))

    x = np.linspace(0.01, 4, 200)
    y = np.linspace(0.01, 4, 200)
    X, Y = np.meshgrid(x, y)

    # Trace: eml(x,y) + eml(y,x) = exp(x) + exp(y) - ln(x) - ln(y)
    trace = np.exp(X) + np.exp(Y) - np.log(X) - np.log(Y)
    trace = np.clip(trace, 0, 20)

    cs = ax.contourf(X, Y, trace, levels=np.arange(2, 20, 0.5),
                     cmap='YlOrRd', alpha=0.8)
    ax.contour(X, Y, trace, levels=[2], colors='black', linewidths=3)

    ax.set_xlabel('x', fontsize=14)
    ax.set_ylabel('y', fontsize=14)
    ax.set_title('EML Trace: eml(x,y) + eml(y,x) ≥ 2\n(AM-GM Bridge)', fontsize=16)
    plt.colorbar(cs, label='Trace value')

    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'amgm_bridge.png'), dpi=150)
    plt.close()
    print("✓ Generated amgm_bridge.png")

# ─── Demo 8: Legendre Transform Bridge ───

def demo_legendre():
    """Visualize eml(x, eʸ) = eˣ − y"""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: eml(x, eʸ) as a function of (x, y)
    x = np.linspace(-2, 3, 100)
    y = np.linspace(-2, 3, 100)
    X, Y = np.meshgrid(x, y)
    Z = np.exp(X) - Y  # = eml(x, exp(y))

    cs = axes[0].contour(X, Y, Z, levels=20, cmap='coolwarm', linewidths=1.5)
    axes[0].clabel(cs, inline=True, fontsize=8)
    axes[0].set_xlabel('x', fontsize=14)
    axes[0].set_ylabel('y', fontsize=14)
    axes[0].set_title('Legendre Bridge: eml(x, eʸ) = eˣ − y', fontsize=14)
    axes[0].grid(True, alpha=0.3)

    # Right: The self-pairing curve eml(x, eˣ) = eˣ - x
    x = np.linspace(-3, 3, 1000)
    y = np.exp(x) - x

    axes[1].plot(x, y, 'b-', linewidth=2.5, label='eml(x, eˣ) = eˣ − x')
    axes[1].plot(0, 1, 'ro', markersize=10, label='Min at (0, 1)')
    axes[1].set_xlabel('x', fontsize=14)
    axes[1].set_ylabel('eml(x, eˣ)', fontsize=14)
    axes[1].set_title('Self-Pairing via Legendre Bridge', fontsize=14)
    axes[1].legend(fontsize=12)
    axes[1].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'legendre_bridge.png'), dpi=150)
    plt.close()
    print("✓ Generated legendre_bridge.png")

# ─── Demo 9: Information-Theoretic Connections ───

def demo_information():
    """Shannon entropy as EML sum"""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: Shannon entropy H(p, 1-p) decomposed via EML
    p = np.linspace(0.01, 0.99, 1000)
    H = -p * np.log(p) - (1 - p) * np.log(1 - p)
    eml_term1 = p * (1 - np.log(p)) - p  # p * eml(0, p) - p = -p ln p
    eml_term2 = (1 - p) * (1 - np.log(1 - p)) - (1 - p)

    axes[0].plot(p, H, 'b-', linewidth=2.5, label='H(p, 1−p)')
    axes[0].plot(p, eml_term1, 'r--', linewidth=1.5, label='−p·ln(p)')
    axes[0].plot(p, eml_term2, 'g--', linewidth=1.5, label='−(1−p)·ln(1−p)')
    axes[0].set_xlabel('p', fontsize=14)
    axes[0].set_ylabel('Entropy', fontsize=14)
    axes[0].set_title('Shannon Entropy via EML Decomposition', fontsize=14)
    axes[0].legend(fontsize=11)
    axes[0].grid(True, alpha=0.3)

    # Right: KL divergence as EML difference
    q = np.linspace(0.01, 0.99, 100)
    p_fixed = 0.3
    KL = p_fixed * np.log(p_fixed / q) + (1 - p_fixed) * np.log((1 - p_fixed) / (1 - q))

    axes[1].plot(q, KL, 'b-', linewidth=2.5)
    axes[1].plot(p_fixed, 0, 'ro', markersize=10, label=f'KL = 0 at q = p = {p_fixed}')
    axes[1].set_xlabel('q', fontsize=14)
    axes[1].set_ylabel('D_KL(p || q)', fontsize=14)
    axes[1].set_title(f'KL Divergence via EML (p = {p_fixed})', fontsize=14)
    axes[1].legend(fontsize=12)
    axes[1].set_ylim(0, 5)
    axes[1].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'information_theory.png'), dpi=150)
    plt.close()
    print("✓ Generated information_theory.png")

# ─── Demo 10: Hessian Metric Visualization ───

def demo_riemannian():
    """Visualize the flat Hessian metric ds² = eˣdx² + y⁻²dy²"""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: metric coefficients
    x = np.linspace(-2, 3, 100)
    y = np.linspace(0.1, 5, 100)

    axes[0].plot(x, np.exp(x), 'b-', linewidth=2.5, label='g₁₁ = eˣ')
    axes[0].set_xlabel('x', fontsize=14)
    axes[0].set_ylabel('Metric coefficient', fontsize=14)
    axes[0].set_title('x-component: g₁₁ = eˣ', fontsize=14)
    axes[0].legend(fontsize=12)
    axes[0].grid(True, alpha=0.3)

    axes[1].plot(y, 1 / y**2, 'r-', linewidth=2.5, label='g₂₂ = 1/y²')
    axes[1].set_xlabel('y', fontsize=14)
    axes[1].set_ylabel('Metric coefficient', fontsize=14)
    axes[1].set_title('y-component: g₂₂ = 1/y² (hyperbolic)', fontsize=14)
    axes[1].legend(fontsize=12)
    axes[1].grid(True, alpha=0.3)

    plt.suptitle('EML Hessian Metric: ds² = eˣdx² + y⁻²dy²  (K = 0: FLAT!)',
                 fontsize=16, fontweight='bold')
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'riemannian_metric.png'), dpi=150)
    plt.close()
    print("✓ Generated riemannian_metric.png")

# ─── Demo 11: Tropical EML ───

def demo_tropical():
    """Tropical EML: trop(x,y) = max(x, -y)"""
    fig, ax = plt.subplots(figsize=(10, 8))

    x = np.linspace(-5, 5, 200)
    y = np.linspace(-5, 5, 200)
    X, Y = np.meshgrid(x, y)
    Z = np.maximum(X, -Y)

    cs = ax.contourf(X, Y, Z, levels=20, cmap='plasma', alpha=0.8)
    ax.contour(X, Y, Z, levels=20, colors='black', linewidths=0.5, alpha=0.5)

    # The boundary x = -y
    ax.plot(x, -x, 'w--', linewidth=2, label='x = −y (transition)')

    ax.set_xlabel('x', fontsize=14)
    ax.set_ylabel('y', fontsize=14)
    ax.set_title('Tropical EML: trop(x, y) = max(x, −y)', fontsize=16)
    ax.legend(fontsize=12, loc='upper right')
    plt.colorbar(cs, label='trop(x, y)')

    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'tropical_eml.png'), dpi=150)
    plt.close()
    print("✓ Generated tropical_eml.png")

# ─── Demo 12: Comprehensive Data Report ───

def demo_report():
    """Generate a computational summary report"""
    report = {
        "EML Operator Summary": {
            "Definition": "eml(x, y) = exp(x) - ln(y)",
            "Domain": "ℝ × (0, ∞)",
            "Range": "ℝ"
        },
        "Key Constants": {
            "eml(0, 1) = 1": float(eml(0, 1)),
            "eml(1, 1) = e": float(eml(1, 1)),
            "eml(1, e^e) = 0": float(eml(1, np.exp(np.e))),
            "eml(e, e) = e^e - 1": float(eml(np.e, np.e)),
            "Self-pairing min σ(0)": float(self_pair(0)),
        },
        "Fixed Points": {
            "d(z) fixed points": "NONE (d(z) > z for all z ∈ ℝ)",
            "g-map fixed point z*": float(gmap(gmap(gmap(gmap(gmap(gmap(gmap(gmap(gmap(gmap(2.0)))))))))),),
            "g'(z*) = -1/z*": float(-1.0 / gmap(gmap(gmap(gmap(gmap(gmap(gmap(gmap(gmap(gmap(2.0))))))))))),
        },
        "Algebraic Properties": {
            "Commutative": False,
            "Associative": False,
            "Has identity": False,
            "Idempotent elements": "NONE",
            "Power-associative": False,
            "Flexible": False,
            "Medial": False,
        },
        "Orbit Divergence (z₀ = 1.0)": {},
        "Convexity": {
            "Convex in x (fixed y)": True,
            "Convex in y on (0,∞) (fixed x)": True,
            "Self-pairing σ strictly convex": True,
            "σ minimum": {"x": 0, "value": 1},
        }
    }

    # Compute orbit
    z = 1.0
    orbit_data = {"d^0(1)": z}
    for i in range(1, 8):
        z = diag(z)
        if z < 1e100:
            orbit_data[f"d^{i}(1)"] = z
    report["Orbit Divergence (z₀ = 1.0)"] = orbit_data

    with open(os.path.join(OUTPUT_DIR, 'eml_report.json'), 'w') as f:
        json.dump(report, f, indent=2, default=str)

    print("✓ Generated eml_report.json")
    print("\nKey results:")
    for k, v in report["Key Constants"].items():
        print(f"  {k}: {v}")
    print(f"\n  g-map fixed point z* ≈ {report['Fixed Points']['g-map fixed point z*']:.6f}")
    print("\n  Orbit divergence:")
    for k, v in orbit_data.items():
        print(f"    {k} = {v:.6f}" if isinstance(v, float) and v < 1e10 else f"    {k} = {v:.2e}")

# ─── Main ───

if __name__ == '__main__':
    print("=" * 60)
    print("  EML OPERATOR EXPLORER — Computational Demos")
    print("=" * 60)
    print()

    demo_surface()
    demo_level_curves()
    demo_diagonal_dynamics()
    demo_gmap_fixedpoint()
    demo_self_pairing()
    demo_constants()
    demo_amgm()
    demo_legendre()
    demo_information()
    demo_riemannian()
    demo_tropical()
    demo_report()

    print("\n" + "=" * 60)
    print("  All demos complete!")
    print("=" * 60)
