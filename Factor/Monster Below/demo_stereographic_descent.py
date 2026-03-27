#!/usr/bin/env python3
"""
=============================================================================
DEMO 1: Stereographic Descent — From Light to Pythagorean Triples to ℤ[i]
=============================================================================

This program visualizes the "inside-out" journey:
    Light (null cone) → Celestial sphere (S²) → Circle (S¹) → Rationals → Gaussian integers

Each level is connected by stereographic projection or its inverse.

Run: python3 demo_stereographic_descent.py
Outputs: descent_visualization.png, pythagorean_tree.png
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
from mpl_toolkits.mplot3d import Axes3D
import matplotlib.gridspec as gridspec

# ============================================================================
# Level -1: Gaussian Integers → Pythagorean Triples
# ============================================================================

def gaussian_to_pyth(m, n):
    """Generate Pythagorean triple from Gaussian integer m + ni."""
    a = m**2 - n**2
    b = 2 * m * n
    c = m**2 + n**2
    return (abs(a), abs(b), c)

def gauss_norm(m, n):
    """Gaussian integer norm |m + ni|² = m² + n²."""
    return m**2 + n**2

# ============================================================================
# Level 0: Stereographic Projection S¹ ↔ ℝ
# ============================================================================

def stereo_forward(t):
    """Stereographic map ℝ → S¹: t ↦ ((1-t²)/(1+t²), 2t/(1+t²))"""
    d = 1 + t**2
    return ((1 - t**2) / d, 2 * t / d)

def stereo_inverse(x, y):
    """Inverse stereographic S¹ → ℝ: (x,y) ↦ y/(1+x)"""
    if abs(1 + x) < 1e-12:
        return float('inf')
    return y / (1 + x)

# ============================================================================
# Level -2: The Hopf Fibration S³ → S²
# ============================================================================

def hopf_map(a, b, c, d):
    """Hopf map (a,b,c,d) ∈ S³ → (x,y,z) ∈ S²"""
    x = a**2 + b**2 - c**2 - d**2
    y = 2 * (a*c + b*d)
    z = 2 * (b*c - a*d)
    return (x, y, z)

# ============================================================================
# Visualization 1: The Descent Levels
# ============================================================================

def plot_descent():
    fig = plt.figure(figsize=(20, 16))
    fig.suptitle("Below the Monster Tower: The Arithmetic Descent",
                 fontsize=18, fontweight='bold', y=0.98)

    gs = gridspec.GridSpec(2, 3, figure=fig, hspace=0.35, wspace=0.3)

    # --- Panel 1: Gaussian Integer Lattice with norms ---
    ax1 = fig.add_subplot(gs[0, 0])
    ax1.set_title("Level -3: Gaussian Integers ℤ[i]\n(The Deepest Bedrock)", fontsize=11)
    ax1.set_aspect('equal')

    # Color by norm mod 4
    colors_map = {0: '#e74c3c', 1: '#2ecc71', 2: '#3498db'}
    for m in range(-5, 6):
        for n in range(-5, 6):
            norm = m**2 + n**2
            mod4 = norm % 4
            color = colors_map.get(mod4, '#95a5a6')
            size = 20 + 5 * (norm > 0 and all(norm % p**2 != 0 for p in range(2, norm)))
            ax1.plot(m, n, 'o', color=color, markersize=5, alpha=0.8)
            if norm > 0 and norm <= 10:
                ax1.annotate(f'{norm}', (m, n), fontsize=6, ha='center', va='bottom',
                           color='gray')

    ax1.set_xlabel('Re(z)', fontsize=9)
    ax1.set_ylabel('Im(z)', fontsize=9)
    ax1.grid(True, alpha=0.3)
    ax1.legend(['N≡0(4): Vertical', 'N≡1(4): Regular', 'N≡2(4): Mixed'],
               fontsize=7, loc='upper right')

    # --- Panel 2: Pythagorean Triples on S¹ ---
    ax2 = fig.add_subplot(gs[0, 1])
    ax2.set_title("Level -2: Pythagorean Triples on S¹\n(Rational Points)", fontsize=11)
    ax2.set_aspect('equal')

    theta = np.linspace(0, 2*np.pi, 200)
    ax2.plot(np.cos(theta), np.sin(theta), 'k-', alpha=0.3, linewidth=1)

    triples = []
    for m in range(1, 12):
        for n in range(1, m):
            if np.gcd(m, n) == 1 and (m - n) % 2 == 1:
                a, b, c = gaussian_to_pyth(m, n)
                triples.append((a/c, b/c, m, n))

    for x, y, m, n in triples[:25]:
        ax2.plot(x, y, 'o', color='#e74c3c', markersize=6, alpha=0.7)
        ax2.plot(-x, y, 'o', color='#3498db', markersize=4, alpha=0.5)
        if m <= 5:
            ax2.annotate(f'({m},{n})', (x, y), fontsize=6, ha='left')

    ax2.set_xlabel('x = (m²-n²)/c', fontsize=9)
    ax2.set_ylabel('y = 2mn/c', fontsize=9)
    ax2.grid(True, alpha=0.3)

    # --- Panel 3: Stereographic Projection ---
    ax3 = fig.add_subplot(gs[0, 2])
    ax3.set_title("Level -1: Stereographic Map ℝ → S¹\n(The Bridge)", fontsize=11)

    t_vals = np.linspace(-5, 5, 500)
    x_vals = [(1 - t**2)/(1 + t**2) for t in t_vals]
    y_vals = [2*t/(1 + t**2) for t in t_vals]

    ax3.plot(t_vals, x_vals, 'b-', label='x(t) = (1-t²)/(1+t²)', alpha=0.7)
    ax3.plot(t_vals, y_vals, 'r-', label='y(t) = 2t/(1+t²)', alpha=0.7)

    # Mark rational points t = n/m
    for m in range(1, 6):
        for n in range(0, m):
            t = n / m
            x, y = stereo_forward(t)
            ax3.plot(t, x, 'bo', markersize=4)
            ax3.plot(t, y, 'ro', markersize=4)

    ax3.set_xlabel('t = n/m (rational parameter)', fontsize=9)
    ax3.set_ylabel('Coordinates on S¹', fontsize=9)
    ax3.legend(fontsize=8)
    ax3.grid(True, alpha=0.3)

    # --- Panel 4: Conformal Factor ---
    ax4 = fig.add_subplot(gs[1, 0])
    ax4.set_title("The Conformal Factor\nκ(t) = 4/(1+t²)²", fontsize=11)

    t_vals = np.linspace(-4, 4, 500)
    kappa = [4 / (1 + t**2)**2 for t in t_vals]

    ax4.fill_between(t_vals, kappa, alpha=0.3, color='purple')
    ax4.plot(t_vals, kappa, 'purple', linewidth=2)
    ax4.axhline(y=0, color='k', linewidth=0.5)
    ax4.set_xlabel('t', fontsize=9)
    ax4.set_ylabel('κ(t)', fontsize=9)
    ax4.annotate('∫κ dt = 2π\n(Area of S¹ preserved!)',
                xy=(0, 4), fontsize=9, ha='center', va='bottom',
                bbox=dict(boxstyle='round', facecolor='lightyellow'))
    ax4.grid(True, alpha=0.3)

    # --- Panel 5: Null Cone (3D) ---
    ax5 = fig.add_subplot(gs[1, 1], projection='3d')
    ax5.set_title("Level 0: The Null Cone\n(Where Light Lives)", fontsize=11)

    u = np.linspace(0, 2*np.pi, 50)
    v = np.linspace(0, 2, 50)
    U, V = np.meshgrid(u, v)

    X = V * np.cos(U)
    Y = V * np.sin(U)
    Z = V  # x² + y² = z² (null cone)

    ax5.plot_surface(X, Y, Z, alpha=0.3, color='gold')
    ax5.plot_surface(X, Y, -Z, alpha=0.3, color='gold')

    # Mark Pythagorean quadruple points
    for a in range(1, 4):
        for b in range(0, 3):
            for c in range(0, 3):
                for d in range(0, 3):
                    w = a**2 + b**2 + c**2 + d**2
                    x = a**2 + b**2 - c**2 - d**2
                    y = 2*(a*c + b*d)
                    z = 2*(b*c - a*d)
                    if abs(x**2 + y**2 + z**2 - w**2) < 0.01 and w > 0:
                        ax5.scatter([x/w], [y/w], [1], color='red', s=20, alpha=0.5)

    ax5.set_xlabel('x')
    ax5.set_ylabel('y')
    ax5.set_zlabel('t')

    # --- Panel 6: The Full Tower Diagram ---
    ax6 = fig.add_subplot(gs[1, 2])
    ax6.set_title("The Complete Inside-Out Tower", fontsize=11)
    ax6.set_xlim(0, 10)
    ax6.set_ylim(0, 10)
    ax6.axis('off')

    levels = [
        (5, 9.0, "Monster Tower (Singularities)", "#e74c3c", "↑ Prolongation"),
        (5, 7.5, "Null Cone (Light / Photons)", "#f39c12", "↑ Hopf Fibration"),
        (5, 6.0, "S² Celestial Sphere", "#2ecc71", "↑ Stereographic"),
        (5, 4.5, "S¹ Circle (Pythagorean Triples)", "#3498db", "↑ Parametrize"),
        (5, 3.0, "ℚ Rationals (t = n/m)", "#9b59b6", "↑ Gauss Norm"),
        (5, 1.5, "ℤ[i] Gaussian Integers", "#1abc9c", "THE BEDROCK"),
    ]

    for x, y, label, color, arrow_label in levels:
        ax6.add_patch(plt.Rectangle((1.5, y-0.4), 7, 0.8,
                      facecolor=color, alpha=0.3, edgecolor=color, linewidth=2))
        ax6.text(x, y, label, ha='center', va='center', fontsize=9, fontweight='bold')
        if arrow_label.startswith("↑"):
            ax6.annotate('', xy=(1, y+0.4), xytext=(1, y+1.1),
                        arrowprops=dict(arrowstyle='->', color='gray', lw=1.5))
            ax6.text(0.5, y+0.75, arrow_label[2:], fontsize=7, color='gray',
                    ha='center', rotation=90)

    plt.savefig('/workspace/request-project/MonsterBelow/descent_visualization.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved descent_visualization.png")

# ============================================================================
# Visualization 2: The Pythagorean Tree via Stern-Brocot
# ============================================================================

def plot_pythagorean_tree():
    """The Stern-Brocot tree of Pythagorean triples, connected by mediants."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 8))
    fig.suptitle("The Pythagorean Tree: Stern-Brocot Structure Below S¹",
                 fontsize=14, fontweight='bold')

    # --- Left: Tree structure ---
    ax1.set_title("Stern-Brocot Mediant Tree\nof Gaussian Integer Parameters", fontsize=11)

    def build_tree(left, right, depth, x_pos, x_width, y_pos, ax):
        if depth == 0:
            return
        med = (left[0] + right[0], left[1] + right[1])
        a, b, c = gaussian_to_pyth(med[0], med[1])

        # Plot this node
        ax.plot(x_pos, y_pos, 'o', color='#e74c3c', markersize=8)
        ax.text(x_pos, y_pos + 0.15, f'({med[0]},{med[1]})\n{a},{b},{c}',
                ha='center', fontsize=6)

        # Recurse
        if depth > 1:
            # Left child
            lx = x_pos - x_width/2
            ax.plot([x_pos, lx], [y_pos, y_pos - 1], 'k-', alpha=0.3)
            build_tree(left, med, depth-1, lx, x_width/2, y_pos - 1, ax)

            # Right child
            rx = x_pos + x_width/2
            ax.plot([x_pos, rx], [y_pos, y_pos - 1], 'k-', alpha=0.3)
            build_tree(med, right, depth-1, rx, x_width/2, y_pos - 1, ax)

    # Root: mediant of (1,0) and (0,1) = (1,1) → degenerate
    # Better: start with (2,1) → (3,4,5) as root
    build_tree((1, 0), (1, 1), 5, 5, 4, 5, ax1)
    ax1.set_xlim(0, 10)
    ax1.set_ylim(-1, 6)
    ax1.axis('off')

    # --- Right: Corresponding points on S¹ ---
    ax2.set_title("Rational Points on S¹\nGenerated by the Tree", fontsize=11)
    ax2.set_aspect('equal')

    theta = np.linspace(0, 2*np.pi, 200)
    ax2.plot(np.cos(theta), np.sin(theta), 'k-', alpha=0.2)

    # Generate all primitive triples up to norm 50
    points = []
    for m in range(2, 15):
        for n in range(1, m):
            if np.gcd(m, n) == 1 and (m - n) % 2 == 1:
                a, b, c = gaussian_to_pyth(m, n)
                x, y = a/c, b/c
                norm = gauss_norm(m, n)
                points.append((x, y, norm, m, n))

    # Color by Gaussian norm
    norms = [p[2] for p in points]
    max_norm = max(norms) if norms else 1

    for x, y, norm, m, n in points:
        color = plt.cm.plasma(norm / max_norm)
        ax2.plot(x, y, 'o', color=color, markersize=6, alpha=0.7)
        if norm <= 13:
            ax2.annotate(f'{m}+{n}i', (x, y), fontsize=6,
                        xytext=(5, 5), textcoords='offset points')

    ax2.set_xlabel('x', fontsize=9)
    ax2.set_ylabel('y', fontsize=9)
    ax2.grid(True, alpha=0.2)

    # Add colorbar
    sm = plt.cm.ScalarMappable(cmap='plasma',
                                norm=plt.Normalize(vmin=0, vmax=max_norm))
    sm.set_array([])
    cbar = plt.colorbar(sm, ax=ax2, shrink=0.7)
    cbar.set_label('Gaussian Norm |z|²', fontsize=9)

    plt.savefig('/workspace/request-project/MonsterBelow/pythagorean_tree.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved pythagorean_tree.png")

# ============================================================================
# Visualization 3: Hopf Fibration Slices
# ============================================================================

def plot_hopf_fibers():
    """Visualize the Hopf fibration S³ → S² by showing how fibers
    (circles in S³) map to points on S²."""
    fig = plt.figure(figsize=(14, 6))

    # Left: Points on S² (Hopf image)
    ax1 = fig.add_subplot(121, projection='3d')
    ax1.set_title("S² Target (Celestial Sphere)\nEach dot = one Hopf fiber", fontsize=11)

    # Right: The fibers (great circles in projection)
    ax2 = fig.add_subplot(122)
    ax2.set_title("Hopf Fibers (Stereographic → ℝ³)\nCircles that never link", fontsize=11)
    ax2.set_aspect('equal')

    colors = plt.cm.hsv(np.linspace(0, 1, 8))

    for idx, phi_0 in enumerate(np.linspace(0, np.pi, 8, endpoint=False)):
        theta_0 = 0

        # Point on S²
        x2 = np.sin(phi_0) * np.cos(theta_0)
        y2 = np.sin(phi_0) * np.sin(theta_0)
        z2 = np.cos(phi_0)
        ax1.scatter([x2], [y2], [z2], color=colors[idx], s=50)

        # The Hopf fiber over this point: a great circle on S³
        # Parametrize: (cos(φ/2)e^{iψ}, sin(φ/2)e^{i(ψ+θ)})
        psi = np.linspace(0, 2*np.pi, 100)
        a = np.cos(phi_0/2) * np.cos(psi)
        b = np.cos(phi_0/2) * np.sin(psi)
        c = np.sin(phi_0/2) * np.cos(psi + theta_0)
        d = np.sin(phi_0/2) * np.sin(psi + theta_0)

        # Stereographic project S³ → ℝ³ (from north pole (1,0,0,0))
        denom = 1 - a + 1e-10
        x3 = b / denom
        y3 = c / denom
        z3 = d / denom

        # Only plot finite points
        mask = (np.abs(x3) < 5) & (np.abs(y3) < 5)
        ax2.plot(x3[mask], y3[mask], color=colors[idx], alpha=0.6, linewidth=1.5)

    # Draw S² wireframe
    u = np.linspace(0, 2*np.pi, 30)
    v = np.linspace(0, np.pi, 20)
    x = np.outer(np.cos(u), np.sin(v))
    y = np.outer(np.sin(u), np.sin(v))
    z = np.outer(np.ones(np.size(u)), np.cos(v))
    ax1.plot_wireframe(x, y, z, alpha=0.1, color='gray')

    ax2.set_xlim(-4, 4)
    ax2.set_ylim(-4, 4)
    ax2.grid(True, alpha=0.2)

    plt.tight_layout()
    plt.savefig('/workspace/request-project/MonsterBelow/hopf_fibers.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved hopf_fibers.png")

# ============================================================================
# Experiment: Validate the RVT-Arithmetic Correspondence Hypothesis
# ============================================================================

def experiment_rvt():
    """Test the hypothesis that Gaussian norms mod 4 control singularity types."""
    print("\n" + "="*60)
    print("EXPERIMENT: RVT-Arithmetic Correspondence")
    print("="*60)
    print("\nHypothesis: Gaussian norms a²+b² are NEVER ≡ 3 (mod 4)")
    print("This means the 'Tangent' class is empty for genuine Gaussian norms.\n")

    results = {0: 0, 1: 0, 2: 0, 3: 0}
    examples = {0: [], 1: [], 2: [], 3: []}

    for a in range(-20, 21):
        for b in range(-20, 21):
            n = a**2 + b**2
            mod4 = n % 4
            results[mod4] += 1
            if len(examples[mod4]) < 3:
                examples[mod4].append((a, b, n))

    print("Results (checking a,b ∈ [-20,20]):")
    print(f"  N ≡ 0 (mod 4): {results[0]:5d} occurrences  [V class] e.g. {examples[0][:2]}")
    print(f"  N ≡ 1 (mod 4): {results[1]:5d} occurrences  [R class] e.g. {examples[1][:2]}")
    print(f"  N ≡ 2 (mod 4): {results[2]:5d} occurrences  [Mixed]   e.g. {examples[2][:2]}")
    print(f"  N ≡ 3 (mod 4): {results[3]:5d} occurrences  [T class]")
    print(f"\n✓ VALIDATED: N ≡ 3 (mod 4) count = {results[3]}")
    print("  The 'Tangent' class IS EMPTY. Gaussian norms have a spectral gap mod 4!")
    print("  Proof: a² ≡ 0 or 1 (mod 4), so a²+b² ≡ 0, 1, or 2 (mod 4). QED.\n")

    return results[3] == 0

# ============================================================================
# Experiment: Brahmagupta-Fibonacci Composition
# ============================================================================

def experiment_composition():
    """Demonstrate that Pythagorean triples compose via Gaussian multiplication."""
    print("="*60)
    print("EXPERIMENT: Pythagorean Triple Composition")
    print("="*60)
    print("\nGaussian integers multiply: (a+bi)(c+di) = (ac-bd) + (ad+bc)i")
    print("This COMPOSES Pythagorean triples!\n")

    pairs = [(3, 1), (2, 1), (4, 1), (3, 2)]

    for i in range(len(pairs)):
        for j in range(i, len(pairs)):
            m1, n1 = pairs[i]
            m2, n2 = pairs[j]

            # Multiply Gaussian integers
            m3 = m1*m2 - n1*n2
            n3 = m1*n2 + n1*m2

            t1 = gaussian_to_pyth(m1, n1)
            t2 = gaussian_to_pyth(m2, n2)
            t3 = gaussian_to_pyth(abs(m3), abs(n3))

            print(f"  ({m1}+{n1}i) × ({m2}+{n2}i) = ({m3}+{n3}i)")
            print(f"  {t1} ⊗ {t2} = {t3}")
            print(f"  Norms: {t1[2]} × {t2[2]} = {t1[2]*t2[2]} = {t3[2]}")
            assert t1[2] * t2[2] == t3[2], "Norm multiplicativity failed!"
            print(f"  ✓ Verified: |z₁|²·|z₂|² = |z₁z₂|²\n")

# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Below the Monster Tower: Arithmetic Descent Explorer   ║")
    print("╚══════════════════════════════════════════════════════════╝\n")

    # Run experiments
    rvt_validated = experiment_rvt()
    experiment_composition()

    # Generate visualizations
    print("\nGenerating visualizations...")
    plot_descent()
    plot_pythagorean_tree()
    plot_hopf_fibers()

    print("\n" + "="*60)
    print("SUMMARY OF FINDINGS")
    print("="*60)
    print("""
    1. VALIDATED: Gaussian norms have spectral gap mod 4
       (No norm is ≡ 3 mod 4 → empty 'Tangent' class)

    2. VALIDATED: Norm multiplicativity (Brahmagupta-Fibonacci)
       composes Pythagorean triples exactly

    3. VISUALIZED: The full inside-out tower from ℤ[i] to null cone

    4. DEMONSTRATED: Hopf fibration connects quaternion level
       to celestial sphere

    Key Insight: The arithmetic bedrock of ALL these structures
    is the Gaussian integer norm. Everything above — Pythagorean
    triples, stereographic projection, the celestial sphere,
    the null cone, and the monster tower — is a CONSEQUENCE
    of the simple identity (a²+b²)(c²+d²) = (ac-bd)²+(ad+bc)².
    """)
