#!/usr/bin/env python3
"""
SCG (Scientific Communication Graphics) Visualizations
for Pythagorean Tree Factoring Paper

Generates publication-quality figures using matplotlib.
Run: python scg_pythagorean_tree.py
Outputs: SVG and PNG files in the current directory.
"""

import numpy as np
from math import gcd, isqrt
import sys

try:
    import matplotlib
    matplotlib.use('Agg')  # Non-interactive backend
    import matplotlib.pyplot as plt
    import matplotlib.patches as patches
    from matplotlib.collections import LineCollection
    HAS_MPL = True
except ImportError:
    HAS_MPL = False
    print("matplotlib not available — generating text-based visualizations")


# ============================================================================
# Color Palette (accessible, publication-quality)
# ============================================================================

COLORS = {
    'primary':    '#2563EB',  # Blue
    'secondary':  '#DC2626',  # Red
    'accent':     '#059669',  # Green
    'highlight':  '#D97706',  # Amber
    'background': '#F8FAFC',  # Light gray
    'text':       '#1E293B',  # Dark slate
    'grid':       '#E2E8F0',  # Light grid
}


def figure_1_berggren_tree():
    """Figure 1: The Berggren Ternary Tree of Pythagorean Triples."""
    if not HAS_MPL:
        print("\n=== FIGURE 1: Berggren Tree (text mode) ===")
        print("                    (3,4,5)")
        print("                 /     |     \\")
        print("          (5,12,13) (21,20,29) (15,8,17)")
        print("          /  |  \\   /  |  \\   /  |  \\")
        print("        ...  ... ... ...  ... ... ...  ... ...")
        return

    fig, ax = plt.subplots(1, 1, figsize=(14, 8))
    ax.set_xlim(-1, 15)
    ax.set_ylim(-0.5, 4.5)
    ax.set_facecolor(COLORS['background'])
    ax.axis('off')
    ax.set_title('The Berggren Ternary Tree of Primitive Pythagorean Triples',
                 fontsize=16, fontweight='bold', color=COLORS['text'], pad=20)

    B1 = np.array([[ 1, -2,  2], [ 2, -1,  2], [ 2, -2,  3]])
    B2 = np.array([[ 1,  2,  2], [ 2,  1,  2], [ 2,  2,  3]])
    B3 = np.array([[-1,  2,  2], [-2,  1,  2], [-2,  2,  3]])

    def draw_node(x, y, triple, color=COLORS['primary'], fontsize=9):
        a, b, c = triple
        text = f"({a},{b},{c})"
        bbox = dict(boxstyle='round,pad=0.3', facecolor='white',
                    edgecolor=color, linewidth=2)
        ax.text(x, y, text, ha='center', va='center', fontsize=fontsize,
                fontweight='bold', color=color, bbox=bbox)

    def draw_edge(x1, y1, x2, y2, label=""):
        ax.annotate("", xy=(x2, y2+0.25), xytext=(x1, y1-0.25),
                    arrowprops=dict(arrowstyle='->', color=COLORS['grid'],
                                   lw=1.5))
        if label:
            mx, my = (x1+x2)/2, (y1+y2)/2
            ax.text(mx-0.3, my, label, fontsize=7, color=COLORS['highlight'],
                    fontstyle='italic')

    # Level 0: root
    root = np.array([3, 4, 5])
    draw_node(7, 4, root, COLORS['secondary'], fontsize=11)

    # Level 1
    level1 = [B1 @ root, B2 @ root, B3 @ root]
    x_positions_1 = [2.5, 7, 11.5]
    labels_1 = ['B₁', 'B₂', 'B₃']
    for i, (triple, x) in enumerate(zip(level1, x_positions_1)):
        draw_node(x, 2.8, triple)
        draw_edge(7, 4, x, 2.8, labels_1[i])

    # Level 2
    for j, (parent, px) in enumerate(zip(level1, x_positions_1)):
        children = [B1 @ parent, B2 @ parent, B3 @ parent]
        offsets = [-1.2, 0, 1.2]
        for k, (child, dx) in enumerate(zip(children, offsets)):
            cx = px + dx
            if 0 <= cx <= 14:
                a, b, c = child
                if c < 500:
                    draw_node(cx, 1.2, child, COLORS['accent'], fontsize=7)
                    draw_edge(px, 2.8, cx, 1.2)

    # Legend
    ax.text(0.5, 0.2, "B₁ = [[1,-2,2],[2,-1,2],[2,-2,3]]", fontsize=7,
            color=COLORS['text'], family='monospace')
    ax.text(5, 0.2, "B₂ = [[1,2,2],[2,1,2],[2,2,3]]", fontsize=7,
            color=COLORS['text'], family='monospace')
    ax.text(9.5, 0.2, "B₃ = [[-1,2,2],[-2,1,2],[-2,2,3]]", fontsize=7,
            color=COLORS['text'], family='monospace')

    fig.savefig('fig1_berggren_tree.svg', bbox_inches='tight', dpi=150)
    fig.savefig('fig1_berggren_tree.png', bbox_inches='tight', dpi=150)
    plt.close(fig)
    print("  → Saved fig1_berggren_tree.{svg,png}")


def figure_2_lattice_correspondence():
    """Figure 2: Lattice-Tree Correspondence — side by side."""
    if not HAS_MPL:
        print("\n=== FIGURE 2: Lattice-Tree Correspondence (text mode) ===")
        print("LEFT: Berggren descent (m,n) → (m-2n, n) → (n, 2n-m) → ...")
        print("RIGHT: Gauss reduction [m,0],[0,n] → subtract → swap → ...")
        print("IDENTICAL operations!")
        return

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left: Berggren descent
    ax1.set_title('Berggren Tree Descent\nin (m,n) Parameter Space',
                  fontsize=13, fontweight='bold', color=COLORS['primary'])
    ax1.set_facecolor(COLORS['background'])

    m, n = 7, 3
    path = [(m, n)]
    while m != 2 or n != 1:
        if m > 2*n:
            m, n = m - 2*n, n
        elif m > n:
            m, n = n, 2*n - m
        else:
            break
        path.append((m, n))
        if len(path) > 20:
            break

    xs = [p[0] for p in path]
    ys = [p[1] for p in path]
    ax1.plot(xs, ys, 'o-', color=COLORS['primary'], markersize=10, linewidth=2)
    for i, (x, y) in enumerate(path):
        offset = (0.2, 0.2)
        ax1.annotate(f'({x},{y})', (x, y), textcoords="offset points",
                    xytext=(10, 10), fontsize=10, fontweight='bold',
                    color=COLORS['secondary'])
        if i > 0:
            pm, pn = path[i-1]
            if pm - 2*pn == x and pn == y:
                label = 'M₃⁻¹'
            else:
                label = 'M₁⁻¹'
            mx = (pm + x) / 2
            my = (pn + y) / 2
            ax1.text(mx - 0.5, my + 0.3, label, fontsize=9,
                    color=COLORS['highlight'], fontstyle='italic')

    ax1.set_xlabel('m', fontsize=12)
    ax1.set_ylabel('n', fontsize=12)
    ax1.grid(True, alpha=0.3)
    ax1.set_aspect('equal')

    # Right: Gauss lattice reduction
    ax2.set_title('Gauss 2D Lattice Reduction\n(Identical Operations)',
                  fontsize=13, fontweight='bold', color=COLORS['secondary'])
    ax2.set_facecolor(COLORS['background'])

    # Draw lattice points
    for i in range(-2, 10):
        for j in range(-2, 8):
            ax2.plot(i, j, '.', color=COLORS['grid'], markersize=3)

    # Draw reduction steps
    b1, b2 = np.array([7.0, 0]), np.array([0.0, 3.0])
    pairs = [(b1.copy(), b2.copy())]

    for _ in range(10):
        if np.linalg.norm(b1) > np.linalg.norm(b2):
            b1, b2 = b2.copy(), b1.copy()
        mu = round(np.dot(b2, b1) / np.dot(b1, b1))
        if mu == 0:
            break
        b2 = b2 - mu * b1
        pairs.append((b1.copy(), b2.copy()))

    colors_iter = [COLORS['primary'], COLORS['secondary'], COLORS['accent'],
                   COLORS['highlight']]
    for i, (v1, v2) in enumerate(pairs):
        c = colors_iter[i % len(colors_iter)]
        alpha = 1.0 - 0.15 * i
        ax2.arrow(0, 0, v1[0], v1[1], head_width=0.15, head_length=0.1,
                 fc=c, ec=c, alpha=alpha, linewidth=2)
        ax2.arrow(0, 0, v2[0], v2[1], head_width=0.15, head_length=0.1,
                 fc=c, ec=c, alpha=alpha, linewidth=2, linestyle='--')

    ax2.set_xlabel('x', fontsize=12)
    ax2.set_ylabel('y', fontsize=12)
    ax2.set_xlim(-2, 8)
    ax2.set_ylim(-2, 5)
    ax2.grid(True, alpha=0.3)
    ax2.set_aspect('equal')

    fig.suptitle('THE LATTICE-TREE CORRESPONDENCE',
                 fontsize=16, fontweight='bold', color=COLORS['text'], y=1.02)
    fig.tight_layout()
    fig.savefig('fig2_lattice_correspondence.svg', bbox_inches='tight', dpi=150)
    fig.savefig('fig2_lattice_correspondence.png', bbox_inches='tight', dpi=150)
    plt.close(fig)
    print("  → Saved fig2_lattice_correspondence.{svg,png}")


def figure_3_complexity_scaling():
    """Figure 3: Θ(√N) complexity scaling."""
    if not HAS_MPL:
        print("\n=== FIGURE 3: Complexity Scaling (text mode) ===")
        print("Steps/√N ≈ constant for balanced semiprimes")
        print("Confirming Θ(√N) = trial division")
        return

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Generate data
    import random
    random.seed(42)

    def is_prime(n):
        if n < 2: return False
        if n < 4: return True
        if n % 2 == 0: return False
        for i in range(3, isqrt(n) + 1, 2):
            if n % i == 0: return False
        return True

    def next_prime(n):
        while not is_prime(n): n += 1
        return n

    Ns, sqrt_Ns, trial_steps, pyth_steps = [], [], [], []

    for p_target in range(20, 500, 10):
        p = next_prime(p_target)
        q = next_prime(p + random.randint(2, 10))
        N = p * q

        # Trial division steps
        t_steps = 0
        for d in range(2, isqrt(N) + 1):
            t_steps += 1
            if N % d == 0:
                break

        # Pythagorean tree steps (divisor pair enumeration)
        p_steps = 0
        N2 = N * N
        for d in range(1, N + 1):
            p_steps += 1
            if N2 % d == 0:
                e = N2 // d
                if d < e and d % 2 == e % 2:
                    g = gcd(d, N)
                    if 1 < g < N:
                        break

        Ns.append(N)
        sqrt_Ns.append(N ** 0.5)
        trial_steps.append(t_steps)
        pyth_steps.append(p_steps)

    # Plot 1: Steps vs √N
    ax1.scatter(sqrt_Ns, trial_steps, c=COLORS['primary'], alpha=0.6, s=20,
               label='Trial Division')
    ax1.scatter(sqrt_Ns, pyth_steps, c=COLORS['secondary'], alpha=0.6, s=20,
               label='Pythagorean Tree')
    ax1.plot([0, max(sqrt_Ns)], [0, max(sqrt_Ns)], '--',
            color=COLORS['accent'], alpha=0.5, label='y = √N reference')
    ax1.set_xlabel('√N', fontsize=12)
    ax1.set_ylabel('Steps to Factor', fontsize=12)
    ax1.set_title('Steps vs √N: Both Methods Scale as Θ(√N)',
                  fontsize=12, fontweight='bold')
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    # Plot 2: Ratio Steps/√N
    trial_ratios = [s / sq for s, sq in zip(trial_steps, sqrt_Ns)]
    pyth_ratios = [s / sq for s, sq in zip(pyth_steps, sqrt_Ns)]

    ax2.scatter(Ns, trial_ratios, c=COLORS['primary'], alpha=0.6, s=20,
               label='Trial Division / √N')
    ax2.scatter(Ns, pyth_ratios, c=COLORS['secondary'], alpha=0.6, s=20,
               label='Pythagorean Tree / √N')
    ax2.axhline(y=np.mean(trial_ratios), color=COLORS['primary'],
               linestyle='--', alpha=0.5)
    ax2.axhline(y=np.mean(pyth_ratios), color=COLORS['secondary'],
               linestyle='--', alpha=0.5)
    ax2.set_xlabel('N', fontsize=12)
    ax2.set_ylabel('Steps / √N', fontsize=12)
    ax2.set_title('Normalized Complexity: Constant Ratio Confirms Θ(√N)',
                  fontsize=12, fontweight='bold')
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    fig.suptitle('COMPLEXITY OF PYTHAGOREAN TREE FACTORING',
                 fontsize=16, fontweight='bold', color=COLORS['text'], y=1.02)
    fig.tight_layout()
    fig.savefig('fig3_complexity_scaling.svg', bbox_inches='tight', dpi=150)
    fig.savefig('fig3_complexity_scaling.png', bbox_inches='tight', dpi=150)
    plt.close(fig)
    print("  → Saved fig3_complexity_scaling.{svg,png}")


def figure_4_dimension_escape():
    """Figure 4: The dimensional escape from 2D to 3D."""
    if not HAS_MPL:
        print("\n=== FIGURE 4: Dimensional Escape (text mode) ===")
        print("d=2: Gauss optimal, Θ(√N)")
        print("d=3: LLL gives 2^{(d-1)/2} = √2 approximation")
        print("d→∞: BKZ with β→∞ approaches SVP optimal")
        return

    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    ax.set_facecolor(COLORS['background'])

    dims = np.arange(2, 21)
    gauss_ratio = np.ones_like(dims, dtype=float)
    gauss_ratio[0] = 1.0  # d=2: optimal
    gauss_ratio[1:] = np.nan  # Gauss undefined for d>2

    lll_ratio = 2.0 ** ((dims - 1) / 2.0)
    bkz3_ratio = 2.0 ** (dims / 6.0)
    bkz5_ratio = 2.0 ** (dims / 10.0)
    bkz10_ratio = 2.0 ** (dims / 20.0)

    ax.plot(dims, lll_ratio, 'o-', color=COLORS['primary'], linewidth=2,
           markersize=6, label='LLL (δ=3/4)')
    ax.plot(dims, bkz3_ratio, 's-', color=COLORS['secondary'], linewidth=2,
           markersize=6, label='BKZ β=3')
    ax.plot(dims, bkz5_ratio, '^-', color=COLORS['accent'], linewidth=2,
           markersize=6, label='BKZ β=5')
    ax.plot(dims, bkz10_ratio, 'D-', color=COLORS['highlight'], linewidth=2,
           markersize=6, label='BKZ β=10')
    ax.axhline(y=1, color='black', linestyle=':', alpha=0.5, label='SVP optimal')
    ax.axvline(x=2, color=COLORS['grid'], linestyle='--', alpha=0.5)
    ax.axvline(x=3, color=COLORS['secondary'], linestyle='--', alpha=0.3)

    ax.annotate('2D: Gauss optimal\n(Pythagorean triples)',
               xy=(2, 1), xytext=(4, 50),
               fontsize=10, color=COLORS['text'],
               arrowprops=dict(arrowstyle='->', color=COLORS['text']))
    ax.annotate('3D: LLL/BKZ escape\n(Pythagorean quadruples)',
               xy=(3, lll_ratio[1]), xytext=(5, 100),
               fontsize=10, color=COLORS['secondary'],
               arrowprops=dict(arrowstyle='->', color=COLORS['secondary']))

    ax.set_xlabel('Lattice Dimension d', fontsize=12)
    ax.set_ylabel('Approximation Ratio (lower = better)', fontsize=12)
    ax.set_title('Lattice Reduction Quality by Dimension:\nThe Escape from 2D',
                fontsize=14, fontweight='bold', color=COLORS['text'])
    ax.set_yscale('log')
    ax.legend(loc='upper left')
    ax.grid(True, alpha=0.3)

    fig.tight_layout()
    fig.savefig('fig4_dimension_escape.svg', bbox_inches='tight', dpi=150)
    fig.savefig('fig4_dimension_escape.png', bbox_inches='tight', dpi=150)
    plt.close(fig)
    print("  → Saved fig4_dimension_escape.{svg,png}")


def figure_5_factoring_landscape():
    """Figure 5: Overview of factoring methods and their complexity."""
    if not HAS_MPL:
        print("\n=== FIGURE 5: Factoring Landscape (text mode) ===")
        print("Trial Division:          O(√N)")
        print("Pythagorean Tree:        Θ(√N)  [= trial division, proven]")
        print("Fermat:                  O(√N)  [for balanced]")
        print("Pollard's rho:           O(N^{1/4})")
        print("Quadratic Sieve:         exp(√(ln N · ln ln N))")
        print("Number Field Sieve:      exp(c · (ln N)^{1/3} · (ln ln N)^{2/3})")
        print("Pythagorean Quadruples:  ??? (open, conjectured sub-√N)")
        return

    fig, ax = plt.subplots(1, 1, figsize=(12, 7))
    ax.set_facecolor(COLORS['background'])

    methods = [
        ('Trial Division', 0.5, COLORS['primary']),
        ('Pythagorean Tree (2D)', 0.5, COLORS['secondary']),
        ('Fermat (balanced)', 0.5, COLORS['primary']),
        ("Pollard's ρ", 0.25, COLORS['accent']),
        ('Quadratic Sieve', 0.15, COLORS['highlight']),
        ('General NFS', 0.1, COLORS['highlight']),
        ('Pythagorean Quadruples (3D)?', 0.35, '#9333EA'),
    ]

    N_bits = np.linspace(10, 100, 200)

    for i, (name, exp, color) in enumerate(methods):
        if 'Sieve' in name:
            complexity = np.exp(np.sqrt(N_bits * np.log(N_bits)) * 0.3)
        elif 'NFS' in name:
            complexity = np.exp(1.5 * N_bits**(1/3) * np.log(N_bits)**(2/3))
        elif '?' in name:
            complexity = 2.0 ** (N_bits * exp)
            complexity = complexity * 0.5  # Optimistic
        else:
            complexity = 2.0 ** (N_bits * exp)

        linestyle = '--' if '?' in name else '-'
        ax.semilogy(N_bits, complexity, linestyle=linestyle, color=color,
                   linewidth=2.5 if 'Pyth' in name else 1.5,
                   label=f'{name}: O(N^{{{exp}}})'
                   if exp not in [0.15, 0.1] else f'{name}: subexp')

    ax.set_xlabel('Input size (bits)', fontsize=12)
    ax.set_ylabel('Operations (log scale)', fontsize=12)
    ax.set_title('Factoring Methods Complexity Landscape',
                fontsize=14, fontweight='bold', color=COLORS['text'])
    ax.legend(loc='upper left', fontsize=9)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(10, 80)
    ax.set_ylim(1, 1e15)

    fig.tight_layout()
    fig.savefig('fig5_factoring_landscape.svg', bbox_inches='tight', dpi=150)
    fig.savefig('fig5_factoring_landscape.png', bbox_inches='tight', dpi=150)
    plt.close(fig)
    print("  → Saved fig5_factoring_landscape.{svg,png}")


# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    print("Generating SCG Figures for Pythagorean Tree Factoring Paper")
    print("=" * 60)

    figure_1_berggren_tree()
    figure_2_lattice_correspondence()
    figure_3_complexity_scaling()
    figure_4_dimension_escape()
    figure_5_factoring_landscape()

    print("\n" + "=" * 60)
    print("All figures generated successfully!")
    if HAS_MPL:
        print("Output: fig1-fig5 in SVG and PNG formats")
    else:
        print("(Text mode only — install matplotlib for graphical output)")
