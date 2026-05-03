"""
Max-Plus / Max-Times Stone–Weierstrass Bridge: Demonstrations

This script demonstrates the theorems proved in the formal Lean development:

1. A max-plus family (closed under max, +, -, constants) that separates points
   is uniformly dense in C(X, ℝ).

2. A max-times family (closed under max, ×, 1/·, positive constants) that
   separates points has dense log-image in C(X, ℝ).

We illustrate these results on X = [0, 1] with concrete numerical examples.
"""

import numpy as np
import matplotlib.pyplot as plt
import os

# Ensure output directory exists
os.makedirs("demos/figures", exist_ok=True)


# ============================================================================
# Demo 1: Max-plus approximation of a smooth function
# ============================================================================

def max_plus_approximate(target_fn, x_grid, basis_fns, n_terms=50, n_random=5000):
    """
    Approximate target_fn on x_grid using max-plus combinations of basis functions.

    A max-plus combination is built from:
      - sums of basis functions (with integer coefficients via repeated addition)
      - max operations
      - addition of constants
      - negation

    We use random search over small max-plus expressions.
    """
    target = target_fn(x_grid) if callable(target_fn) else target_fn

    # Build a library of transformed basis functions
    transformed = []
    for f in basis_fns:
        vals = f(x_grid)
        transformed.append(vals)
        transformed.append(-vals)  # negation closure
        for c in np.linspace(-2, 2, 9):
            transformed.append(vals + c)  # constant shifts
            transformed.append(-vals + c)

    # Greedily build approximation using max and sum operations
    current = np.full_like(target, np.min(target) - 1)
    history = [np.max(np.abs(target - current))]

    for step in range(n_terms):
        best_candidate = None
        best_improvement = np.inf

        for _ in range(n_random):
            # Random max-plus expression: sum of a few terms, then max with current
            n_sum = np.random.randint(1, 4)
            indices = np.random.choice(len(transformed), n_sum)
            candidate = sum(transformed[i] for i in indices) / n_sum
            candidate += np.random.uniform(-1, 1)

            # Try max(current, candidate) - should not overshoot target
            new_approx = np.maximum(current, candidate)
            error = np.max(np.abs(target - new_approx))

            if error < best_improvement:
                best_improvement = error
                best_candidate = new_approx.copy()

        if best_candidate is not None and best_improvement < history[-1]:
            current = best_candidate
            history.append(best_improvement)
        else:
            break

    return current, history


def demo1_max_plus_approximation():
    """Demonstrate max-plus approximation of smooth functions."""
    print("=" * 70)
    print("Demo 1: Max-Plus Approximation of Smooth Functions")
    print("=" * 70)

    x = np.linspace(0, 1, 500)

    # Target function: a smooth bump
    target = np.sin(2 * np.pi * x) * np.exp(-2 * (x - 0.5)**2)

    # Basis: affine functions (which generate piecewise linear via max/+)
    basis = [
        lambda x, a=a, b=b: a * x + b
        for a in np.linspace(-3, 3, 7)
        for b in np.linspace(-2, 2, 5)
    ]

    approx, errors = max_plus_approximate(lambda x: np.sin(2 * np.pi * x) * np.exp(-2 * (x - 0.5)**2), x, basis, n_terms=100)

    fig, axes = plt.subplots(1, 3, figsize=(15, 4.5))

    # Plot 1: Target and approximation
    axes[0].plot(x, target, 'b-', linewidth=2, label='Target $f(x)$')
    axes[0].plot(x, approx, 'r--', linewidth=1.5, label='Max-plus approx')
    axes[0].set_xlabel('$x$')
    axes[0].set_ylabel('$y$')
    axes[0].set_title('Max-Plus Approximation')
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)

    # Plot 2: Error
    axes[1].plot(x, np.abs(target - approx), 'g-', linewidth=1.5)
    axes[1].set_xlabel('$x$')
    axes[1].set_ylabel('$|f(x) - g(x)|$')
    axes[1].set_title('Pointwise Error')
    axes[1].grid(True, alpha=0.3)

    # Plot 3: Convergence
    axes[2].semilogy(range(len(errors)), errors, 'ko-', markersize=3)
    axes[2].set_xlabel('Iteration')
    axes[2].set_ylabel('Sup-norm error')
    axes[2].set_title('Convergence of Max-Plus Approximation')
    axes[2].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('demos/figures/demo1_max_plus_approx.png', dpi=150, bbox_inches='tight')
    plt.close()

    print(f"  Final sup-norm error: {errors[-1]:.6f}")
    print(f"  Number of iterations: {len(errors)}")
    print(f"  Figure saved to demos/figures/demo1_max_plus_approx.png")


# ============================================================================
# Demo 2: Max-times (tropical) approximation via log transport
# ============================================================================

def demo2_max_times_log_transport():
    """Demonstrate the log-transport from max-times to max-plus."""
    print("\n" + "=" * 70)
    print("Demo 2: Max-Times to Max-Plus via Log Transport")
    print("=" * 70)

    x = np.linspace(0.1, 2, 500)

    # Positive target function
    target_pos = 1 + 0.5 * np.sin(3 * x) + 0.3 * np.cos(5 * x)

    # Log-domain target
    log_target = np.log(target_pos)

    # Max-plus basis in log domain (= max-times basis in original domain)
    # Power functions x^a * c correspond to a*log(x) + log(c) in log domain
    basis_log = [
        lambda x, a=a, b=b: a * np.log(x) + b
        for a in np.linspace(-2, 2, 9)
        for b in np.linspace(-1, 1, 5)
    ]

    # Approximate in log domain
    log_approx, errors = max_plus_approximate(lambda x: np.log(1 + 0.5 * np.sin(3 * x) + 0.3 * np.cos(5 * x)), x, basis_log, n_terms=80)

    # Transport back
    approx_pos = np.exp(log_approx)

    fig, axes = plt.subplots(1, 3, figsize=(15, 4.5))

    # Plot 1: Original domain
    axes[0].plot(x, target_pos, 'b-', linewidth=2, label='Target $f(x) > 0$')
    axes[0].plot(x, approx_pos, 'r--', linewidth=1.5, label='$\\exp(\\hat{g}(x))$')
    axes[0].set_xlabel('$x$')
    axes[0].set_title('Original Domain (Positive Functions)')
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)

    # Plot 2: Log domain
    axes[1].plot(x, log_target, 'b-', linewidth=2, label='$\\log f(x)$')
    axes[1].plot(x, log_approx, 'r--', linewidth=1.5, label='Max-plus $\\hat{g}(x)$')
    axes[1].set_xlabel('$x$')
    axes[1].set_title('Log Domain (Max-Plus Approximation)')
    axes[1].legend()
    axes[1].grid(True, alpha=0.3)

    # Plot 3: Log-domain error convergence
    axes[2].semilogy(range(len(errors)), errors, 'ko-', markersize=3)
    axes[2].set_xlabel('Iteration')
    axes[2].set_ylabel('Log-domain sup error')
    axes[2].set_title('Log-Domain Convergence')
    axes[2].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('demos/figures/demo2_log_transport.png', dpi=150, bbox_inches='tight')
    plt.close()

    print(f"  Final log-domain sup error: {errors[-1]:.6f}")
    print(f"  Final original-domain max ratio: {np.max(np.abs(target_pos/approx_pos - 1)):.6f}")
    print(f"  Figure saved to demos/figures/demo2_log_transport.png")


# ============================================================================
# Demo 3: The inf-from-sup-neg identity
# ============================================================================

def demo3_inf_from_sup_neg():
    """Visualize the identity min(f,g) = -max(-f, -g)."""
    print("\n" + "=" * 70)
    print("Demo 3: The Key Identity: min(f,g) = -max(-f, -g)")
    print("=" * 70)

    x = np.linspace(0, 1, 500)
    f = np.sin(2 * np.pi * x) + 0.5
    g = 0.3 * np.cos(4 * np.pi * x) + 0.2

    # Direct computation
    min_fg = np.minimum(f, g)

    # Via negation and max
    neg_max_neg = -np.maximum(-f, -g)

    # Verify identity
    error = np.max(np.abs(min_fg - neg_max_neg))

    fig, axes = plt.subplots(1, 2, figsize=(12, 4.5))

    axes[0].plot(x, f, 'b-', linewidth=2, label='$f(x)$')
    axes[0].plot(x, g, 'g-', linewidth=2, label='$g(x)$')
    axes[0].plot(x, min_fg, 'r-', linewidth=2.5, label='$\\min(f, g)$')
    axes[0].fill_between(x, min_fg, -1, alpha=0.1, color='red')
    axes[0].set_xlabel('$x$')
    axes[0].set_title('Direct: $f \\wedge g = \\min(f, g)$')
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)

    axes[1].plot(x, -f, 'b--', linewidth=1, alpha=0.5, label='$-f(x)$')
    axes[1].plot(x, -g, 'g--', linewidth=1, alpha=0.5, label='$-g(x)$')
    axes[1].plot(x, np.maximum(-f, -g), 'orange', linewidth=1.5, label='$\\max(-f, -g)$')
    axes[1].plot(x, neg_max_neg, 'r-', linewidth=2.5, label='$-\\max(-f, -g)$')
    axes[1].set_xlabel('$x$')
    axes[1].set_title('Via identity: $f \\wedge g = -((-f) \\vee (-g))$')
    axes[1].legend()
    axes[1].grid(True, alpha=0.3)

    plt.suptitle(f'Identity verification: max pointwise error = {error:.2e}', fontsize=11)
    plt.tight_layout()
    plt.savefig('demos/figures/demo3_inf_identity.png', dpi=150, bbox_inches='tight')
    plt.close()

    print(f"  Max pointwise error between min(f,g) and -max(-f,-g): {error:.2e}")
    print(f"  Figure saved to demos/figures/demo3_inf_identity.png")


# ============================================================================
# Demo 4: Piecewise linear universal approximation
# ============================================================================

def demo4_piecewise_linear():
    """Show that max-plus of affine functions generates all piecewise linear functions."""
    print("\n" + "=" * 70)
    print("Demo 4: Max-Plus of Affines = Piecewise Linear (Universal Approximation)")
    print("=" * 70)

    x = np.linspace(0, 1, 1000)

    # Target functions of increasing complexity
    targets = [
        ("$\\sin(2\\pi x)$", lambda x: np.sin(2*np.pi*x)),
        ("$x^2 - x + 0.3$", lambda x: x**2 - x + 0.3),
        ("$|x - 0.5| + 0.1\\sin(10\\pi x)$",
         lambda x: np.abs(x - 0.5) + 0.1*np.sin(10*np.pi*x)),
    ]

    fig, axes = plt.subplots(1, 3, figsize=(15, 4.5))

    for idx, (name, fn) in enumerate(targets):
        target = fn(x)

        # Approximate with max-plus of affines (= piecewise linear)
        n_pieces = 20
        breakpoints = np.linspace(0, 1, n_pieces + 1)

        # Build PL approximation via max of affine lower bounds
        approx = np.full_like(x, -100.0)
        for i in range(n_pieces):
            x0, x1 = breakpoints[i], breakpoints[i+1]
            y0, y1 = fn(x0), fn(x1)
            slope = (y1 - y0) / (x1 - x0) if x1 > x0 else 0
            affine = y0 + slope * (x - x0)
            # Use min to cap the affine outside the interval
            cap_left = -100 * (x0 - x) + y0
            cap_right = -100 * (x - x1) + y1
            local_piece = np.minimum(affine, np.minimum(cap_left, cap_right))
            approx = np.maximum(approx, local_piece)

        error = np.max(np.abs(target - approx))

        axes[idx].plot(x, target, 'b-', linewidth=2, label='Target')
        axes[idx].plot(x, approx, 'r--', linewidth=1.5, label=f'PL approx ({n_pieces} pieces)')
        axes[idx].set_title(f'{name}\nerror = {error:.4f}')
        axes[idx].legend(fontsize=8)
        axes[idx].grid(True, alpha=0.3)
        axes[idx].set_xlabel('$x$')

    plt.suptitle('Piecewise Linear Approximation via Max-Plus of Affines', fontsize=13)
    plt.tight_layout()
    plt.savefig('demos/figures/demo4_piecewise_linear.png', dpi=150, bbox_inches='tight')
    plt.close()

    print(f"  Figure saved to demos/figures/demo4_piecewise_linear.png")


# ============================================================================
# Demo 5: Tropical polynomial as max-plus expression
# ============================================================================

def demo5_tropical_polynomial():
    """Show tropical polynomials as max-plus expressions and their approximation power."""
    print("\n" + "=" * 70)
    print("Demo 5: Tropical Polynomials and Max-Plus Expressions")
    print("=" * 70)

    x = np.linspace(-2, 2, 500)

    # A tropical polynomial: max(a_i + b_i * x) for various (a_i, b_i)
    # This is max of affine functions = convex piecewise linear
    coeffs = [(-1, 2), (0, 0), (1, -1), (-0.5, 1), (0.5, -0.5)]
    trop_poly = np.max([a + b * x for a, b in coeffs], axis=0)

    fig, axes = plt.subplots(1, 3, figsize=(15, 4.5))

    for a, b in coeffs:
        axes[0].plot(x, a + b * x, '--', alpha=0.5, linewidth=1)
    axes[0].plot(x, trop_poly, 'r-', linewidth=2.5, label='Tropical polynomial')
    axes[0].set_title('Tropical Polynomial = max of affines')
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)
    axes[0].set_xlabel('$x$')

    # With negation: can build concave PL too
    concave = -np.max([-a - b * x for a, b in coeffs], axis=0)
    axes[1].plot(x, concave, 'b-', linewidth=2.5, label='$-$max$(-f_i)$ = min of affines')
    for a, b in coeffs:
        axes[1].plot(x, a + b * x, '--', alpha=0.3, linewidth=1)
    axes[1].set_title('Concave PL via negation')
    axes[1].legend()
    axes[1].grid(True, alpha=0.3)
    axes[1].set_xlabel('$x$')

    # Combined: general PL via max-min
    general_pl = np.minimum(trop_poly, concave + 1)
    axes[2].plot(x, trop_poly, 'r--', linewidth=1, alpha=0.5, label='Convex PL')
    axes[2].plot(x, concave + 1, 'b--', linewidth=1, alpha=0.5, label='Concave PL + 1')
    axes[2].plot(x, general_pl, 'k-', linewidth=2.5, label='min(convex, concave)')
    axes[2].set_title('General PL from max + min (= max + neg)')
    axes[2].legend()
    axes[2].grid(True, alpha=0.3)
    axes[2].set_xlabel('$x$')

    plt.suptitle('Tropical Polynomials and the Max-Plus Algebra', fontsize=13)
    plt.tight_layout()
    plt.savefig('demos/figures/demo5_tropical.png', dpi=150, bbox_inches='tight')
    plt.close()

    print(f"  Figure saved to demos/figures/demo5_tropical.png")


# ============================================================================
# Run all demos
# ============================================================================

if __name__ == "__main__":
    print("Max-Plus / Max-Times Stone-Weierstrass Bridge: Demonstrations")
    print("=" * 70)
    print()

    np.random.seed(42)

    demo1_max_plus_approximation()
    demo2_max_times_log_transport()
    demo3_inf_from_sup_neg()
    demo4_piecewise_linear()
    demo5_tropical_polynomial()

    print("\n" + "=" * 70)
    print("All demos completed successfully!")
    print("Figures saved in demos/figures/")
    print("=" * 70)
