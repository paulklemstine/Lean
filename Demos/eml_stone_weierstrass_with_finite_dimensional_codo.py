"""
Vector-Valued Stone–Weierstrass: Demonstration & Visualization

This script demonstrates the finite-dimensional vector-valued Stone–Weierstrass
theorem by showing how scalar coordinate-wise approximation yields uniform
vector-valued approximation.

We show:
1. A 2D curve C([-1,1], R^2) approximated coordinate-wise by polynomials
2. The reconstruction bound in action: max coordinate error → vector error
3. Multi-output EML model approximation for a 3-output function
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import os

# Create output directory
os.makedirs("demos/figures", exist_ok=True)


# ============================================================
# Demo 1: Coordinate-wise polynomial approximation of a 2D curve
# ============================================================

def demo_coordinatewise_approximation():
    """
    Approximate f(x) = (sin(2πx), cos(2πx)) on [-1, 1]
    by independently approximating each coordinate with polynomials.
    """
    fig, axes = plt.subplots(2, 3, figsize=(15, 8))

    x = np.linspace(-1, 1, 500)

    # Target function: a circle parameterization
    f1 = np.sin(2 * np.pi * x)  # coordinate 1
    f2 = np.cos(2 * np.pi * x)  # coordinate 2

    degrees = [3, 7, 15]

    for idx, deg in enumerate(degrees):
        # Approximate each coordinate independently with polynomials
        coeffs1 = np.polyfit(x, f1, deg)
        coeffs2 = np.polyfit(x, f2, deg)
        p1 = np.polyval(coeffs1, x)
        p2 = np.polyval(coeffs2, x)

        # Top row: coordinate-wise errors
        err1 = np.abs(f1 - p1)
        err2 = np.abs(f2 - p2)
        vec_err = np.sqrt((f1 - p1)**2 + (f2 - p2)**2)

        axes[0, idx].semilogy(x, np.maximum(err1, 1e-17), 'b-', alpha=0.7, label='|f₁ - p₁|')
        axes[0, idx].semilogy(x, np.maximum(err2, 1e-17), 'r-', alpha=0.7, label='|f₂ - p₂|')
        axes[0, idx].semilogy(x, np.maximum(vec_err, 1e-17), 'k--', alpha=0.9, label='‖f - p‖')
        axes[0, idx].set_title(f'Degree {deg} errors')
        axes[0, idx].legend(fontsize=8)
        axes[0, idx].set_xlabel('x')
        axes[0, idx].set_ylabel('Error')
        axes[0, idx].set_ylim([1e-16, 10])

        # Bottom row: curve in R^2
        axes[1, idx].plot(f1, f2, 'k-', linewidth=2, label='Target (circle)')
        axes[1, idx].plot(p1, p2, '--', linewidth=1.5,
                         label=f'Degree-{deg} approx')
        axes[1, idx].set_aspect('equal')
        axes[1, idx].legend(fontsize=8)
        axes[1, idx].set_title(f'R² curve, degree {deg}')
        axes[1, idx].set_xlabel('y₁')
        axes[1, idx].set_ylabel('y₂')

    fig.suptitle('Coordinate-wise Polynomial Approximation of Vector-Valued Functions',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('demos/figures/coordinatewise_approx.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved coordinatewise_approx.png")


# ============================================================
# Demo 2: Reconstruction bound visualization
# ============================================================

def demo_reconstruction_bound():
    """
    Visualize the reconstruction bound:
    ‖f - reconstructed‖ ≤ C * max_i ‖f_i - approx_i‖

    For R^n with standard basis, C = √n (Euclidean norm).
    """
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    dims = [2, 5, 10]
    n_trials = 200

    for idx, n in enumerate(dims):
        max_coord_errors = []
        vector_errors = []

        np.random.seed(123)
        for _ in range(n_trials):
            # Random error vector e ∈ R^n
            e = np.random.randn(n)
            scale = np.random.exponential(1.0)
            e = e * scale

            max_coord_err = np.max(np.abs(e))
            vec_err = np.linalg.norm(e)

            max_coord_errors.append(max_coord_err)
            vector_errors.append(vec_err)

        max_coord_errors = np.array(max_coord_errors)
        vector_errors = np.array(vector_errors)

        # The bound: ‖e‖₂ ≤ √n * max_i |e_i|
        C_bound = np.sqrt(n)

        axes[idx].scatter(max_coord_errors, vector_errors, alpha=0.4, s=10, c='blue')
        x_range = np.linspace(0, max(max_coord_errors), 100)
        axes[idx].plot(x_range, C_bound * x_range, 'r-', linewidth=2,
                      label=f'C·ε (C = √{n} ≈ {C_bound:.2f})')
        axes[idx].plot(x_range, x_range, 'g--', linewidth=1,
                      label='ε (identity)')
        axes[idx].set_xlabel('max_i |eᵢ| (coordinate max-error)')
        axes[idx].set_ylabel('‖e‖₂ (Euclidean vector error)')
        axes[idx].set_title(f'n = {n}')
        axes[idx].legend(fontsize=8)

    fig.suptitle('Reconstruction Bound: ‖e‖ ≤ C · max_i |eᵢ|',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('demos/figures/reconstruction_bound.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved reconstruction_bound.png")


# ============================================================
# Demo 3: Multi-output EML approximation
# ============================================================

def sigmoid(x):
    return 1 / (1 + np.exp(-np.clip(x, -500, 500)))

def demo_multioutput_eml():
    """
    Demonstrate the EML multi-output approximation theorem.

    Target: f : [-2,2] → R^3
    f(x) = (sin(x), x², exp(-x²))

    We approximate each coordinate independently with EML models
    (linear combinations of sigmoids), then assemble.
    """
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))

    x = np.linspace(-2, 2, 500)

    # Target functions (3 outputs)
    targets = [
        np.sin(x),
        0.25 * x**2,
        np.exp(-x**2)
    ]
    target_names = ['sin(x)', '0.25x²', 'exp(-x²)']
    colors = ['#1f77b4', '#ff7f0e', '#2ca02c']

    n_sigmoids_list = [3, 8, 20]

    for trial, n_sig in enumerate(n_sigmoids_list):
        if trial < 2:
            ax = axes[0, trial]
        else:
            ax = axes[1, 0]

        np.random.seed(42 + trial)
        approxes = []
        for k in range(3):
            basis_biases = np.linspace(-3, 3, n_sig)
            Phi = np.column_stack([sigmoid(3 * x + b) for b in basis_biases])
            Phi = np.column_stack([Phi, np.ones_like(x)])
            coeffs, _, _, _ = np.linalg.lstsq(Phi, targets[k], rcond=None)
            approx = Phi @ coeffs
            approxes.append(approx)

        for k in range(3):
            ax.plot(x, targets[k], '-', color=colors[k], linewidth=2,
                   alpha=0.8, label=f'{target_names[k]} (target)')
            ax.plot(x, approxes[k], '--', color=colors[k], linewidth=1.5,
                   alpha=0.7, label=f'{target_names[k]} (EML, {n_sig} units)')

        ax.set_title(f'{n_sig} sigmoid units per coordinate')
        ax.set_xlabel('x')
        ax.legend(fontsize=7, ncol=2)
        ax.grid(True, alpha=0.3)

    # Bottom right: convergence plot
    ax = axes[1, 1]
    n_units_range = range(2, 30)
    max_errors = {k: [] for k in range(3)}
    total_errors = []

    for n_sig in n_units_range:
        np.random.seed(42)
        basis_biases = np.linspace(-3, 3, n_sig)
        max_err = 0
        for k in range(3):
            Phi = np.column_stack([sigmoid(3 * x + b) for b in basis_biases])
            Phi = np.column_stack([Phi, np.ones_like(x)])
            coeffs, _, _, _ = np.linalg.lstsq(Phi, targets[k], rcond=None)
            approx = Phi @ coeffs
            err = np.max(np.abs(targets[k] - approx))
            max_errors[k].append(err)
            max_err = max(max_err, err)
        total_errors.append(max_err)

    for k in range(3):
        ax.semilogy(list(n_units_range), max_errors[k], '-o', markersize=3,
                   color=colors[k], label=f'coord {k+1}: {target_names[k]}')
    ax.semilogy(list(n_units_range), total_errors, 'k--', linewidth=2,
               label='max over coordinates')
    ax.set_xlabel('Number of sigmoid units')
    ax.set_ylabel('Sup-norm error')
    ax.set_title('Convergence: EML multi-output approximation')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    fig.suptitle('Multi-Output EML Universal Approximation\n'
                 '(Vector-Valued Stone–Weierstrass in Action)',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('demos/figures/multioutput_eml.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved multioutput_eml.png")


# ============================================================
# Demo 4: Diagram of the scalarization strategy
# ============================================================

def demo_strategy_diagram():
    """Create a conceptual diagram of the proof strategy."""
    fig, ax = plt.subplots(1, 1, figsize=(12, 6))
    ax.set_xlim(0, 12)
    ax.set_ylim(0, 6)
    ax.axis('off')

    # Boxes
    boxes = {
        'target': (1, 4.5, 'Target\nf : X -> V'),
        'coords': (5, 4.5, 'Coordinates\nf_1, ..., f_n : X -> R'),
        'scalar_approx': (9, 4.5, 'Scalar approx\nphi_1, ..., phi_n'),
        'reconstruct': (9, 1.5, 'Reconstruct\nF = sum phi_i * e_i'),
        'bound': (5, 1.5, 'Error bound\n||f - F|| <= C * max|f_i - phi_i|'),
        'result': (1, 1.5, 'f in closure A\nDense!'),
    }

    for key, (cx, cy, text) in boxes.items():
        color = '#e3f2fd' if key != 'result' else '#c8e6c9'
        bbox = dict(boxstyle='round,pad=0.5', facecolor=color,
                   edgecolor='#1565c0', linewidth=2)
        ax.text(cx, cy, text, ha='center', va='center',
               fontsize=11, fontweight='bold', bbox=bbox)

    # Arrows
    arrows = [
        (2.2, 4.5, 3.8, 4.5, 'b.coord i'),
        (6.2, 4.5, 7.8, 4.5, 'Scalar S-W'),
        (9, 3.8, 9, 2.2, 'assemble'),
        (7.8, 1.5, 6.2, 1.5, 'norm equiv.'),
        (3.8, 1.5, 2.2, 1.5, 'eps -> 0'),
    ]

    for x1, y1, x2, y2, label in arrows:
        ax.annotate('', xy=(x2, y2), xytext=(x1, y1),
                   arrowprops=dict(arrowstyle='->', color='#1565c0',
                                  linewidth=2, connectionstyle='arc3,rad=0'))
        mx, my = (x1 + x2) / 2, (y1 + y2) / 2 + 0.25
        ax.text(mx, my, label, ha='center', va='center',
               fontsize=9, fontstyle='italic', color='#1565c0')

    ax.set_title('Proof Strategy: Vector-Valued Stone-Weierstrass via Scalarization',
                fontsize=14, fontweight='bold', pad=20)

    plt.tight_layout()
    plt.savefig('demos/figures/proof_strategy.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved proof_strategy.png")


# ============================================================
# Run all demos
# ============================================================

if __name__ == '__main__':
    print("=" * 60)
    print("Vector-Valued Stone-Weierstrass Demonstrations")
    print("=" * 60)
    print()

    demo_coordinatewise_approximation()
    demo_reconstruction_bound()
    demo_multioutput_eml()
    demo_strategy_diagram()

    print()
    print("All figures saved to demos/figures/")
    print()
    print("Key insight: The vector-valued Stone-Weierstrass theorem")
    print("says that to approximate a function f : X -> R^n, it suffices")
    print("to approximate each coordinate f_i : X -> R independently.")
    print("The reconstruction constant C (depending on the basis)")
    print("controls how coordinate errors translate to vector errors.")
