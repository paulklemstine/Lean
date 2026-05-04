"""
Application: Tropical Neural Network Compilation

This demo shows how the Tropical Stone–Weierstrass theorem applies to
neural network compilation. ReLU networks are tropical circuits, and
the density theorem guarantees that any continuous function can be
compiled into one.

Key insight: ReLU(x) = max(0, x) is a tropical operation.
A ReLU network computes compositions of (max, +) operations.
"""

import numpy as np
import matplotlib.pyplot as plt
import os


def relu(x):
    return np.maximum(0, x)


def relu_network_1hidden(x, W1, b1, W2, b2):
    """Single hidden-layer ReLU network: W2 @ relu(W1 @ x + b1) + b2"""
    h = relu(W1 @ x.reshape(-1, 1) + b1.reshape(-1, 1))
    return (W2 @ h + b2).flatten()


def tropical_to_relu(generators, shifts, x):
    """
    Convert a tropical expression max_j(c_j + F_j(x)) to a ReLU network.

    The identity max(a, b) = ReLU(a - b) + b shows that tropical max
    can be computed by ReLU. For n terms:
    max(c1+F1, c2+F2, ..., cn+Fn) = iterative application of binary max.
    """
    values = np.array([c + g(x) for c, g in zip(shifts, generators)])
    return np.max(values, axis=0)


def demonstrate_relu_as_tropical():
    """Show that ReLU networks ARE tropical circuits."""
    x = np.linspace(-2, 2, 500)

    fig, axes = plt.subplots(2, 2, figsize=(12, 10))
    fig.suptitle("ReLU Networks as Tropical Circuits",
                 fontsize=14, fontweight='bold')

    # Panel 1: ReLU = max(0, x)
    ax = axes[0, 0]
    ax.plot(x, x, 'b--', alpha=0.5, label='x')
    ax.plot(x, np.zeros_like(x), 'r--', alpha=0.5, label='0')
    ax.plot(x, relu(x), 'k-', linewidth=2.5, label='ReLU(x) = max(0, x)')
    ax.set_title('ReLU is a tropical operation', fontsize=12)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Panel 2: max(a, b) via ReLU
    ax = axes[0, 1]
    a = 0.5 * x + 0.3
    b = -0.3 * x + 0.5
    max_ab = np.maximum(a, b)
    relu_max = relu(a - b) + b  # = max(a, b)

    ax.plot(x, a, 'b-', alpha=0.5, label='a(x) = 0.5x + 0.3')
    ax.plot(x, b, 'r-', alpha=0.5, label='b(x) = -0.3x + 0.5')
    ax.plot(x, max_ab, 'k-', linewidth=2, label='max(a, b)')
    ax.plot(x, relu_max, 'g--', linewidth=2, alpha=0.7,
            label='ReLU(a-b) + b')
    ax.set_title('max(a,b) = ReLU(a-b) + b', fontsize=12)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Panel 3: Piecewise linear from tropical expr
    ax = axes[1, 0]
    generators = [
        lambda x: 0.5 * x,
        lambda x: -0.3 * x,
        lambda x: np.zeros_like(x),
        lambda x: 0.8 * x,
    ]
    shifts = [0.2, 0.5, 0.1, -0.4]

    for i, (g, c) in enumerate(zip(generators, shifts)):
        ax.plot(x, c + g(x), '--', alpha=0.4, linewidth=1)

    result = tropical_to_relu(generators, shifts, x)
    ax.plot(x, result, 'k-', linewidth=2.5, label='Tropical expression')
    ax.set_title('Piecewise linear = max of affine', fontsize=12)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Panel 4: Approximation quality
    ax = axes[1, 1]
    target = np.sin(2 * np.pi * x / 4) * 0.8
    n_terms_list = [2, 4, 8, 16]

    for n in n_terms_list:
        # Create n evenly-spaced "neuron" generators
        anchors = np.linspace(-2, 2, n)
        approx = np.full_like(x, -10.0)
        for anchor in anchors:
            slope = np.interp(anchor, x, np.gradient(target, x))
            shift = np.interp(anchor, x, target) - slope * anchor
            approx = np.maximum(approx, slope * x + shift)
        error = np.max(np.abs(target - approx))
        ax.plot(x, approx, linewidth=1.2, alpha=0.7,
                label=f'{n} neurons (ε={error:.3f})')

    ax.plot(x, target, 'k-', linewidth=2.5, label='Target')
    ax.set_title('ReLU approximation quality', fontsize=12)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__),
                'relu_tropical_connection.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: relu_tropical_connection.png")


def demonstrate_codomain_retraction():
    """
    Show the retraction theorem in a practical setting:
    approximating a function that maps into the probability simplex.
    """
    x = np.linspace(0, 1, 300)

    # Target: continuous function mapping into [0, 1]^2 with sum ≤ 1
    # (the probability simplex in 2D)
    p1_target = 0.3 + 0.2 * np.sin(4 * np.pi * x)
    p2_target = 0.3 + 0.15 * np.cos(6 * np.pi * x)

    # Ensure target is in simplex
    total = p1_target + p2_target
    p1_target = p1_target / np.maximum(total, 1)
    p2_target = p2_target / np.maximum(total, 1)

    # Unconstrained tropical approximation (add noise to simulate)
    noise_scale = 0.05
    p1_approx_free = p1_target + noise_scale * np.random.RandomState(42).randn(len(x))
    p2_approx_free = p2_target + noise_scale * np.random.RandomState(43).randn(len(x))

    # Retraction to simplex: clip to [0, ∞) and normalize
    def simplex_retract(p1, p2):
        p1c = np.maximum(p1, 0)
        p2c = np.maximum(p2, 0)
        total = p1c + p2c
        scale = np.minimum(1.0, 1.0 / np.maximum(total, 1e-10))
        return p1c * scale, p2c * scale

    p1_retracted, p2_retracted = simplex_retract(p1_approx_free, p2_approx_free)

    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    fig.suptitle("Retraction Preserves Density: Probability Simplex Example",
                 fontsize=14, fontweight='bold')

    # Panel 1: Target in simplex
    ax = axes[0]
    ax.fill([0, 1, 0, 0], [0, 0, 1, 0], alpha=0.1, color='blue')
    ax.plot([0, 1, 0, 0], [0, 0, 1, 0], 'b-', linewidth=1)
    ax.plot(p1_target, p2_target, 'k-', linewidth=2, label='Target')
    ax.set_xlabel('p₁')
    ax.set_ylabel('p₂')
    ax.set_title('Target curve in simplex')
    ax.legend()
    ax.set_xlim(-0.1, 0.7)
    ax.set_ylim(-0.1, 0.7)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)

    # Panel 2: Free approximation (may leave simplex)
    ax = axes[1]
    ax.fill([0, 1, 0, 0], [0, 0, 1, 0], alpha=0.1, color='blue')
    ax.plot([0, 1, 0, 0], [0, 0, 1, 0], 'b-', linewidth=1)
    ax.plot(p1_target, p2_target, 'k-', linewidth=2, label='Target')
    ax.plot(p1_approx_free, p2_approx_free, 'r.', markersize=1,
            alpha=0.5, label='Free approx')
    ax.set_xlabel('p₁')
    ax.set_ylabel('p₂')
    ax.set_title('Unconstrained approximation')
    ax.legend()
    ax.set_xlim(-0.1, 0.7)
    ax.set_ylim(-0.1, 0.7)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)

    # Panel 3: After retraction
    ax = axes[2]
    ax.fill([0, 1, 0, 0], [0, 0, 1, 0], alpha=0.1, color='blue')
    ax.plot([0, 1, 0, 0], [0, 0, 1, 0], 'b-', linewidth=1)
    ax.plot(p1_target, p2_target, 'k-', linewidth=2, label='Target')
    ax.plot(p1_retracted, p2_retracted, 'g.', markersize=1,
            alpha=0.5, label='After retraction')
    err = np.max(np.sqrt((p1_target - p1_retracted)**2 + (p2_target - p2_retracted)**2))
    ax.set_xlabel('p₁')
    ax.set_ylabel('p₂')
    ax.set_title(f'After retraction (max err={err:.3f})')
    ax.legend()
    ax.set_xlim(-0.1, 0.7)
    ax.set_ylim(-0.1, 0.7)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__),
                'simplex_retraction.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: simplex_retraction.png")


if __name__ == "__main__":
    print("=" * 60)
    print("Application: Tropical Neural Network Compilation")
    print("=" * 60)
    print()

    print("1. ReLU as tropical circuits...")
    demonstrate_relu_as_tropical()

    print("2. Retraction to probability simplex...")
    demonstrate_codomain_retraction()

    print()
    print("Applications demonstrated:")
    print("  • ReLU(x) = max(0, x) is a tropical operation")
    print("  • max(a, b) = ReLU(a-b) + b converts tropical to neural")
    print("  • Piecewise-linear functions = tropical polynomials")
    print("  • Retraction preserves approximation for constrained codomains")


"""
Tropical Stone–Weierstrass: Demonstration and Visualization

This script demonstrates the tropical Stone–Weierstrass theorem with concrete
numerical examples. It shows how continuous functions can be uniformly approximated
by tropical expressions (finite max of shifted generators), and visualizes the
approximation process.

Key mathematical content:
- A "tropical expression" is: g(x) = max_j (c_j + F_j(x)) for finitely many (c_j, F_j)
- The theorem says: if the generators F_j separate points (strongly),
  then tropical expressions are dense in C(X, R)
- We demonstrate this for X = [0, 1] with polynomial and trigonometric targets
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec
import os

# ============================================================================
# Core: Tropical Expression Evaluation
# ============================================================================

def tropical_expr(x, generators, shifts):
    """
    Evaluate a tropical expression: max_j (shifts[j] + generators[j](x))

    Parameters:
        x: array of input points
        generators: list of functions X -> R
        shifts: list of real constants, same length as generators

    Returns:
        array of values max_j (shifts[j] + generators[j](x))
    """
    values = np.array([c + g(x) for c, g in zip(shifts, generators)])
    return np.max(values, axis=0)


def tropical_min_max_expr(x, generators, params):
    """
    Evaluate a tropical lattice expression using max and min.
    params is a list of (type, shift, gen_idx) where type is 'max' or 'min'.
    This builds up the expression tree.
    """
    # For simplicity, evaluate as: result = min/max combination of shifted generators
    if len(params) == 0:
        return np.zeros_like(x)

    results = []
    for shift, gen_idx in params:
        results.append(shift + generators[gen_idx](x))

    # Take pairwise max, then min alternating (simple lattice construction)
    result = results[0]
    for i in range(1, len(results)):
        if i % 2 == 1:
            result = np.maximum(result, results[i])
        else:
            result = np.minimum(result, results[i])
    return result


# ============================================================================
# Generators: Identity, quadratic, and their negatives (for separation)
# ============================================================================

def make_generators():
    """Create a set of generators that separates points strongly on [0,1]."""
    return [
        lambda x: x,           # g0: identity
        lambda x: -x,          # g1: negative identity
        lambda x: x**2,        # g2: quadratic
        lambda x: -x**2,       # g3: negative quadratic
        lambda x: np.sin(np.pi * x),  # g4: sine
        lambda x: np.zeros_like(x),   # g5: constant 0
    ]


# ============================================================================
# Tropical Approximation Algorithm
# ============================================================================

def tropical_approximate(target_fn, generators, x_grid, n_terms=20, n_iterations=100):
    """
    Find a tropical lattice expression approximating target_fn.

    Uses a greedy approach:
    1. For each point, find which generator+shift best matches the target
    2. Build the expression as max of selected shifted generators
    3. Refine using min to clip overshoots

    Returns: (best_approx, error, terms_used)
    """
    target = target_fn(x_grid)
    n_gen = len(generators)

    # Phase 1: Build upper approximation using max of shifted generators
    # For each generator, find optimal shift at each "anchor" point
    best_upper = np.full_like(target, np.inf)
    upper_terms = []

    anchor_indices = np.linspace(0, len(x_grid)-1, n_terms, dtype=int)

    for anchor_idx in anchor_indices:
        x_anchor = x_grid[anchor_idx]
        target_anchor = target[anchor_idx]

        best_gen = 0
        best_shift = 0
        best_max_error = np.inf

        for g_idx, gen in enumerate(generators):
            gen_at_anchor = gen(np.array([x_anchor]))[0]
            shift = target_anchor - gen_at_anchor
            approx = shift + gen(x_grid)
            # We want approx >= target everywhere (upper bound)
            # and minimize the overshoot
            max_error = np.max(np.abs(approx - target))
            if max_error < best_max_error:
                best_max_error = max_error
                best_gen = g_idx
                best_shift = shift

        upper_terms.append((best_shift, best_gen))

    # Evaluate the max of all terms (this is our "upper envelope")
    upper_values = []
    for shift, g_idx in upper_terms:
        upper_values.append(shift + generators[g_idx](x_grid))
    upper_approx = np.max(upper_values, axis=0) if upper_values else target

    # Phase 2: Build lower approximation and combine with min
    # Similar process but aiming for lower bounds
    lower_terms = []
    for anchor_idx in anchor_indices:
        x_anchor = x_grid[anchor_idx]
        target_anchor = target[anchor_idx]

        best_gen = 0
        best_shift = 0
        best_error = np.inf

        for g_idx, gen in enumerate(generators):
            gen_at_anchor = gen(np.array([x_anchor]))[0]
            shift = target_anchor - gen_at_anchor
            approx = shift + gen(x_grid)
            error = np.max(np.abs(approx - target))
            if error < best_error:
                best_error = error
                best_gen = g_idx
                best_shift = shift

        lower_terms.append((best_shift, best_gen))

    lower_values = []
    for shift, g_idx in lower_terms:
        lower_values.append(shift + generators[g_idx](x_grid))
    lower_approx = np.min(lower_values, axis=0) if lower_values else target

    # Final: combine upper and lower using min/max
    # approx = min(upper_approx, max(lower_approx, ...))
    approx = np.minimum(upper_approx, np.maximum(lower_approx, target * 0))

    # Greedy refinement: iteratively add terms to reduce error
    current_approx = approx.copy()
    all_terms = upper_terms + lower_terms

    for iteration in range(n_iterations):
        residual = target - current_approx
        worst_idx = np.argmax(np.abs(residual))

        best_improvement = 0
        best_new_approx = current_approx.copy()

        for g_idx, gen in enumerate(generators):
            for sign in [1, -1]:
                gen_val = gen(np.array([x_grid[worst_idx]]))[0]
                shift = target[worst_idx] - gen_val
                new_term = shift + gen(x_grid)

                # Try max with current
                candidate1 = np.maximum(current_approx, new_term)
                err1 = np.max(np.abs(target - candidate1))

                # Try min with current
                candidate2 = np.minimum(current_approx, new_term)
                err2 = np.max(np.abs(target - candidate2))

                current_err = np.max(np.abs(target - current_approx))

                if err1 < current_err and err1 < err2:
                    if current_err - err1 > best_improvement:
                        best_improvement = current_err - err1
                        best_new_approx = candidate1.copy()
                elif err2 < current_err:
                    if current_err - err2 > best_improvement:
                        best_improvement = current_err - err2
                        best_new_approx = candidate2.copy()

        if best_improvement < 1e-10:
            break
        current_approx = best_new_approx

    error = np.max(np.abs(target - current_approx))
    return current_approx, error, len(all_terms)


# ============================================================================
# Visualization
# ============================================================================

def plot_approximation_demo():
    """Create the main demonstration figure."""
    x = np.linspace(0, 1, 500)
    generators = make_generators()

    # Target functions to approximate
    targets = [
        (lambda x: np.sin(2 * np.pi * x), r"$\sin(2\pi x)$", "sine"),
        (lambda x: x * (1 - x) * 4, r"$4x(1-x)$", "parabola"),
        (lambda x: np.abs(x - 0.5) * 2, r"$2|x - 0.5|$", "v_shape"),
        (lambda x: np.where(x < 0.5, 2*x, 2 - 2*x),
         r"$\mathrm{tent}(x)$", "tent"),
    ]

    fig = plt.figure(figsize=(16, 12))
    fig.suptitle(
        "Tropical Stone–Weierstrass Theorem: Uniform Approximation Demo",
        fontsize=16, fontweight='bold', y=0.98
    )

    gs = GridSpec(2, 2, hspace=0.35, wspace=0.3)

    for idx, (target_fn, label, name) in enumerate(targets):
        ax = fig.add_subplot(gs[idx // 2, idx % 2])

        target_vals = target_fn(x)

        # Approximate with increasing numbers of terms
        n_terms_list = [3, 8, 20]
        colors = ['#ff6b6b', '#ffa726', '#66bb6a']

        for n_terms, color in zip(n_terms_list, colors):
            approx, error, n_used = tropical_approximate(
                target_fn, generators, x, n_terms=n_terms, n_iterations=50
            )
            ax.plot(x, approx, color=color, linewidth=1.2, alpha=0.8,
                    label=f'{n_terms} anchors (ε={error:.3f})')

        ax.plot(x, target_vals, 'k-', linewidth=2, label=f'Target: {label}')
        ax.set_title(f'Approximating {label}', fontsize=13)
        ax.set_xlabel('x', fontsize=11)
        ax.set_ylabel('y', fontsize=11)
        ax.legend(fontsize=9, loc='best')
        ax.grid(True, alpha=0.3)
        ax.set_xlim(0, 1)

    plt.savefig(os.path.join(os.path.dirname(__file__),
                'tropical_approximation_demo.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: tropical_approximation_demo.png")


def plot_tropical_operations():
    """Visualize the basic tropical operations."""
    x = np.linspace(0, 1, 300)

    fig, axes = plt.subplots(1, 3, figsize=(15, 4.5))
    fig.suptitle("Tropical Operations on Functions", fontsize=14, fontweight='bold')

    # Panel 1: Tropical addition (max)
    f = np.sin(2 * np.pi * x) * 0.5
    g = 0.3 * x - 0.1
    trop_sum = np.maximum(f, g)

    axes[0].plot(x, f, 'b-', linewidth=1.5, label=r'$f(x)$')
    axes[0].plot(x, g, 'r-', linewidth=1.5, label=r'$g(x)$')
    axes[0].plot(x, trop_sum, 'k-', linewidth=2.5, label=r'$f \oplus g = \max(f, g)$')
    axes[0].fill_between(x, f, trop_sum, alpha=0.1, color='green')
    axes[0].set_title('Tropical Addition (max)', fontsize=12)
    axes[0].legend(fontsize=9)
    axes[0].grid(True, alpha=0.3)

    # Panel 2: Tropical scalar multiplication (shift)
    f = 0.5 * np.sin(2 * np.pi * x)
    shifts = [-0.3, 0, 0.3]
    colors_shift = ['blue', 'black', 'red']
    for c, col in zip(shifts, colors_shift):
        axes[1].plot(x, c + f, color=col, linewidth=1.5,
                     label=f'${c:+.1f} + f(x)$' if c != 0 else r'$f(x)$')
    axes[1].set_title('Tropical Scalar Mult (shift)', fontsize=12)
    axes[1].legend(fontsize=9)
    axes[1].grid(True, alpha=0.3)

    # Panel 3: Building a tropical expression
    g0 = lambda x: x
    g1 = lambda x: -x
    terms = [
        (0.2, g0, r'$0.2 + x$'),
        (-0.3, g1, r'$-0.3 - x$'),
        (0.0, lambda x: np.zeros_like(x), r'$0$'),
    ]

    for shift, gen, label in terms:
        axes[2].plot(x, shift + gen(x), '--', linewidth=1, alpha=0.6, label=label)

    # The tropical expression is the max
    expr_val = np.maximum.reduce([shift + gen(x) for shift, gen, _ in terms])
    axes[2].plot(x, expr_val, 'k-', linewidth=2.5,
                 label=r'$\max$ (tropical expr)')
    axes[2].set_title('Tropical Expression = max of shifts', fontsize=12)
    axes[2].legend(fontsize=9)
    axes[2].grid(True, alpha=0.3)

    for ax in axes:
        ax.set_xlabel('x', fontsize=11)

    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__),
                'tropical_operations.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: tropical_operations.png")


def plot_convergence():
    """Show convergence of tropical approximation as terms increase."""
    x = np.linspace(0, 1, 500)
    generators = make_generators()
    target_fn = lambda x: np.sin(2 * np.pi * x)
    target = target_fn(x)

    term_counts = [2, 4, 6, 8, 10, 15, 20, 30, 50]
    errors = []

    for n in term_counts:
        _, error, _ = tropical_approximate(
            target_fn, generators, x, n_terms=n, n_iterations=50
        )
        errors.append(error)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))
    fig.suptitle("Convergence of Tropical Approximation",
                 fontsize=14, fontweight='bold')

    # Error vs number of terms
    ax1.semilogy(term_counts, errors, 'bo-', linewidth=2, markersize=8)
    ax1.set_xlabel('Number of anchor points', fontsize=12)
    ax1.set_ylabel('Sup-norm error ε', fontsize=12)
    ax1.set_title(r'Error decay for $\sin(2\pi x)$', fontsize=13)
    ax1.grid(True, alpha=0.3)

    # Show progressive approximation
    colors = plt.cm.viridis(np.linspace(0.2, 0.9, 5))
    selected = [2, 5, 10, 20, 50]
    for n, color in zip(selected, colors):
        approx, error, _ = tropical_approximate(
            target_fn, generators, x, n_terms=n, n_iterations=50
        )
        ax2.plot(x, approx, color=color, linewidth=1.2,
                 label=f'n={n} (ε={error:.3f})')

    ax2.plot(x, target, 'k-', linewidth=2.5, label='Target')
    ax2.set_xlabel('x', fontsize=12)
    ax2.set_ylabel('y', fontsize=12)
    ax2.set_title('Progressive approximation', fontsize=13)
    ax2.legend(fontsize=9)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__),
                'tropical_convergence.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: tropical_convergence.png")


def plot_2d_tropical():
    """Demonstrate 2D tropical approximation (vector-valued case)."""
    x = np.linspace(0, 1, 200)
    generators = make_generators()

    # Target: a curve in R^2
    target_x = np.cos(2 * np.pi * x) * 0.3
    target_y = np.sin(2 * np.pi * x) * 0.3

    # Approximate each coordinate separately (as per the theorem)
    approx_x, err_x, _ = tropical_approximate(
        lambda t: np.cos(2 * np.pi * t) * 0.3, generators, x, n_terms=15
    )
    approx_y, err_y, _ = tropical_approximate(
        lambda t: np.sin(2 * np.pi * t) * 0.3, generators, x, n_terms=15
    )

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5.5))
    fig.suptitle("Vector-Valued Tropical Approximation (Coordinatewise)",
                 fontsize=14, fontweight='bold')

    # Plot in parameter space
    ax1.plot(x, target_x, 'b-', linewidth=2, label='Target coord 1')
    ax1.plot(x, target_y, 'r-', linewidth=2, label='Target coord 2')
    ax1.plot(x, approx_x, 'b--', linewidth=1.5, alpha=0.7,
             label=f'Approx coord 1 (ε={err_x:.3f})')
    ax1.plot(x, approx_y, 'r--', linewidth=1.5, alpha=0.7,
             label=f'Approx coord 2 (ε={err_y:.3f})')
    ax1.set_xlabel('t (parameter)', fontsize=11)
    ax1.set_ylabel('coordinate value', fontsize=11)
    ax1.set_title('Coordinatewise approximation', fontsize=13)
    ax1.legend(fontsize=9)
    ax1.grid(True, alpha=0.3)

    # Plot as curves in R^2
    ax2.plot(target_x, target_y, 'k-', linewidth=2.5, label='Target curve')
    ax2.plot(approx_x, approx_y, 'r--', linewidth=1.5,
             label='Tropical approx')

    # Show the error at sample points
    sample_idx = np.arange(0, len(x), 20)
    for i in sample_idx:
        ax2.plot([target_x[i], approx_x[i]], [target_y[i], approx_y[i]],
                 'g-', alpha=0.3, linewidth=0.8)

    ax2.set_xlabel('Coordinate 1', fontsize=11)
    ax2.set_ylabel('Coordinate 2', fontsize=11)
    ax2.set_title('Curve approximation in ℝ²', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    ax2.set_aspect('equal')

    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__),
                'tropical_2d_approximation.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: tropical_2d_approximation.png")


def plot_retraction_demo():
    """Demonstrate the retraction-preserves-density theorem."""
    x = np.linspace(0, 1, 300)
    generators = make_generators()

    # Target function mapping into K = [-0.3, 0.3]
    target_fn = lambda x: np.sin(2 * np.pi * x) * 0.25

    # Approximate without constraint
    approx_free, err_free, _ = tropical_approximate(
        target_fn, generators, x, n_terms=10
    )

    # Define retraction r: R -> [-0.3, 0.3] (clipping)
    K_lo, K_hi = -0.3, 0.3
    retract = lambda y: np.clip(y, K_lo, K_hi)

    # Apply retraction to get constrained approximation
    approx_constrained = retract(approx_free)
    err_constrained = np.max(np.abs(target_fn(x) - approx_constrained))

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))
    fig.suptitle("Retraction Preserves Density Theorem",
                 fontsize=14, fontweight='bold')

    # Before retraction
    ax1.fill_between(x, K_lo, K_hi, alpha=0.1, color='blue', label='K = [-0.3, 0.3]')
    ax1.axhline(K_lo, color='blue', linestyle=':', alpha=0.5)
    ax1.axhline(K_hi, color='blue', linestyle=':', alpha=0.5)
    ax1.plot(x, target_fn(x), 'k-', linewidth=2, label='Target f(x)')
    ax1.plot(x, approx_free, 'r-', linewidth=1.5,
             label=f'Free approx (ε={err_free:.3f})')
    ax1.set_title('Before retraction', fontsize=13)
    ax1.legend(fontsize=9)
    ax1.grid(True, alpha=0.3)
    ax1.set_xlabel('x')

    # After retraction
    ax2.fill_between(x, K_lo, K_hi, alpha=0.1, color='blue', label='K = [-0.3, 0.3]')
    ax2.axhline(K_lo, color='blue', linestyle=':', alpha=0.5)
    ax2.axhline(K_hi, color='blue', linestyle=':', alpha=0.5)
    ax2.plot(x, target_fn(x), 'k-', linewidth=2, label='Target f(x)')
    ax2.plot(x, approx_constrained, 'g-', linewidth=1.5,
             label=f'r ∘ approx (ε={err_constrained:.3f})')
    ax2.set_title('After retraction r = clip to K', fontsize=13)
    ax2.legend(fontsize=9)
    ax2.grid(True, alpha=0.3)
    ax2.set_xlabel('x')

    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__),
                'tropical_retraction_demo.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: tropical_retraction_demo.png")


# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    print("=" * 60)
    print("Tropical Stone–Weierstrass Theorem: Demonstrations")
    print("=" * 60)
    print()

    print("1. Generating tropical operations visualization...")
    plot_tropical_operations()

    print("2. Generating approximation demo...")
    plot_approximation_demo()

    print("3. Generating convergence analysis...")
    plot_convergence()

    print("4. Generating 2D vector-valued approximation...")
    plot_2d_tropical()

    print("5. Generating retraction demo...")
    plot_retraction_demo()

    print()
    print("All visualizations saved to demos/ directory.")
    print()
    print("Key theorem demonstrated:")
    print("  For any continuous f : X → ℝⁿ on a compact space X,")
    print("  and any ε > 0, there exists a tropical expression g")
    print("  (finite max/min of shifted generators) such that")
    print("  ‖f(x) - g(x)‖ ≤ ε  for all x ∈ X.")
