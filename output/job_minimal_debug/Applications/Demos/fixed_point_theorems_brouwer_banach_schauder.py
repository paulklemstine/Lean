#!/usr/bin/env python3
"""
Fixed Point Theory: Real-World Applications

Demonstrates practical applications of fixed-point theorems:
1. ODE solving via Picard iteration
2. Economic equilibrium (supply-demand)
3. Image denoising via contraction
4. Newton's method as quasi-contraction
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def app_ode_picard():
    """
    Application 1: Solve an ODE via Picard iteration.

    ODE: y'(t) = -0.5 * y(t) + sin(t), y(0) = 1
    Integral form: y(t) = 1 + ∫₀ᵗ (-0.5·y(s) + sin(s)) ds
    """
    print("=" * 60)
    print("APP 1: ODE via Picard Iteration")
    print("=" * 60)
    print("ODE: y'(t) = -0.5·y(t) + sin(t), y(0) = 1")

    N = 200
    T = 5.0
    ts = np.linspace(0, T, N)
    h = ts[1] - ts[0]

    def picard_op(y):
        y_new = np.zeros_like(y)
        y_new[0] = 1.0
        for i in range(1, N):
            integrand = -0.5 * y[:i+1] + np.sin(ts[:i+1])
            y_new[i] = 1.0 + np.trapezoid(integrand, ts[:i+1])
        return y_new

    y = np.ones(N)
    iterates = [y.copy()]

    for n in range(20):
        y = picard_op(y)
        iterates.append(y.copy())
        if n > 0 and np.max(np.abs(iterates[-1] - iterates[-2])) < 1e-12:
            print(f"  Converged after {n+1} iterations")
            break

    # Compare with scipy if available, or analytical intuition
    fig, ax = plt.subplots(figsize=(10, 5))
    for i, label in [(0, 'n=0'), (1, 'n=1'), (3, 'n=3'), (-1, f'n={len(iterates)-1}')]:
        ax.plot(ts, iterates[i], label=label, alpha=0.7 if i != -1 else 1.0,
                linewidth=1 if i != -1 else 2)
    ax.set_xlabel('t')
    ax.set_ylabel('y(t)')
    ax.set_title("ODE Solution by Picard Iteration: y' = -0.5y + sin(t)")
    ax.legend()
    ax.grid(True)
    plt.savefig('app_ode.png', dpi=150)
    print("  → Saved app_ode.png")


def app_economic_equilibrium():
    """
    Application 2: Economic equilibrium via contraction.

    Find price p where supply S(p) = demand D(p).
    Tatonnement: p_{n+1} = p_n + α(D(p_n) - S(p_n))
    """
    print("\n" + "=" * 60)
    print("APP 2: Economic Equilibrium (Tatonnement)")
    print("=" * 60)

    # Supply and demand functions
    supply = lambda p: 2 * p + 1
    demand = lambda p: 10 - 1.5 * p

    # Equilibrium: 2p + 1 = 10 - 1.5p → 3.5p = 9 → p* = 9/3.5
    p_star = 9 / 3.5

    alpha = 0.2  # Adjustment speed
    tatonnement = lambda p: p + alpha * (demand(p) - supply(p))
    # = p + α(10 - 1.5p - 2p - 1) = p + α(9 - 3.5p) = (1 - 3.5α)p + 9α
    K = abs(1 - 3.5 * alpha)

    print(f"  Supply: S(p) = 2p + 1")
    print(f"  Demand: D(p) = 10 - 1.5p")
    print(f"  Equilibrium price p* = {p_star:.4f}")
    print(f"  Tatonnement step α = {alpha}")
    print(f"  Contraction constant K = |1 - 3.5α| = {K:.4f}")

    p = 0.0
    prices = [p]
    for n in range(30):
        p = tatonnement(p)
        prices.append(p)
        if abs(p - p_star) < 1e-10:
            print(f"  Converged after {n+1} iterations to p = {p:.8f}")
            break

    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(prices, 'bo-', markersize=4)
    ax.axhline(y=p_star, color='r', linestyle='--', label=f'p* = {p_star:.4f}')
    ax.set_xlabel('Iteration')
    ax.set_ylabel('Price')
    ax.set_title('Tatonnement: Price Convergence to Equilibrium')
    ax.legend()
    ax.grid(True)
    plt.savefig('app_equilibrium.png', dpi=150)
    print("  → Saved app_equilibrium.png")


def app_image_denoising():
    """
    Application 3: Image denoising as contraction.

    Iterative averaging filter on a 1D signal:
    (Tf)(x) = α·f(x) + (1-α)/2·(f(x-1) + f(x+1))
    """
    print("\n" + "=" * 60)
    print("APP 3: Signal Denoising via Contraction")
    print("=" * 60)

    N = 200
    x = np.linspace(0, 2 * np.pi, N)
    signal = np.sin(x) + 0.5 * np.sin(3 * x)
    noisy = signal + 0.3 * np.random.RandomState(42).randn(N)

    alpha = 0.6  # Weight of center vs neighbors
    K = alpha  # Contraction constant

    def smooth(f):
        result = np.copy(f)
        for i in range(1, N - 1):
            result[i] = alpha * f[i] + (1 - alpha) / 2 * (f[i-1] + f[i+1])
        return result

    print(f"  Smoothing parameter α = {alpha}")
    print(f"  Contraction constant K = {K}")

    current = noisy.copy()
    iterations = [1, 5, 20, 100]
    results = {}

    for n in range(max(iterations) + 1):
        if n in iterations:
            results[n] = current.copy()
        current = smooth(current)

    fig, axes = plt.subplots(2, 2, figsize=(14, 8))
    for ax, n in zip(axes.ravel(), iterations):
        ax.plot(x, signal, 'b-', alpha=0.5, label='True signal')
        ax.plot(x, noisy, 'gray', alpha=0.3, label='Noisy')
        ax.plot(x, results[n], 'r-', label=f'n={n} iterations')
        ax.set_title(f'After {n} smoothing iterations')
        ax.legend(fontsize=8)
        ax.grid(True)

    plt.suptitle('Signal Denoising via Contractive Smoothing')
    plt.tight_layout()
    plt.savefig('app_denoising.png', dpi=150)
    print("  → Saved app_denoising.png")


def app_newton_method():
    """
    Application 4: Newton's method as contraction near fixed point.

    Solve f(x) = x³ - 2x - 5 = 0
    Newton: g(x) = x - f(x)/f'(x) = x - (x³-2x-5)/(3x²-2)
    """
    print("\n" + "=" * 60)
    print("APP 4: Newton's Method as Contraction")
    print("=" * 60)

    f = lambda x: x**3 - 2*x - 5
    fp = lambda x: 3*x**2 - 2
    g = lambda x: x - f(x) / fp(x)

    x = 2.0
    print(f"  Equation: x³ - 2x - 5 = 0")
    print(f"  Starting point: x₀ = {x}")

    iterates = [x]
    for n in range(10):
        x = g(x)
        iterates.append(x)
        print(f"  n={n+1}: x = {x:.15f}, f(x) = {f(x):.2e}")
        if abs(f(x)) < 1e-15:
            break

    x_star = iterates[-1]
    # Check contraction locally
    K_local = abs(f(x_star) * 6 * x_star / (3*x_star**2 - 2)**2)
    print(f"\n  Root x* ≈ {x_star:.15f}")
    print(f"  Local contraction constant |g'(x*)| ≈ {K_local:.6f}")

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    xs = np.linspace(1.5, 3, 200)
    ax1.plot(xs, f(xs), 'b-', label='f(x) = x³ - 2x - 5')
    ax1.axhline(y=0, color='k', linestyle='-', alpha=0.3)
    ax1.plot(x_star, 0, 'r*', markersize=15, label=f'Root x* ≈ {x_star:.6f}')
    ax1.set_xlabel('x')
    ax1.set_ylabel('f(x)')
    ax1.set_title("Newton's Method: Root Finding")
    ax1.legend()
    ax1.grid(True)

    errors = [abs(it - x_star) for it in iterates[:-1]]
    ax2.semilogy(range(len(errors)), errors, 'bo-')
    ax2.set_xlabel('Iteration')
    ax2.set_ylabel('|x_n - x*|')
    ax2.set_title('Quadratic Convergence')
    ax2.grid(True)

    plt.tight_layout()
    plt.savefig('app_newton.png', dpi=150)
    print("  → Saved app_newton.png")


if __name__ == "__main__":
    print("Fixed Point Theory: Applications")
    print("=" * 60)
    app_ode_picard()
    app_economic_equilibrium()
    app_image_denoising()
    app_newton_method()
    print("\n\nAll application demos complete.")


#!/usr/bin/env python3
"""
Fixed Point Theory: Interactive Demonstrations

Demonstrates:
1. Banach contraction iteration with geometric convergence
2. Approximate Brouwer witness on a 2D square map
3. Compact integral operator example (Volterra)
4. Residual/error plots

Run: python demo.py
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


# ─────────────────────────────────────────────────────────────────────
# Demo 1: Banach Contraction Iteration with Geometric Convergence
# ─────────────────────────────────────────────────────────────────────

def demo_banach_contraction():
    """Demonstrate Banach contraction principle with geometric convergence."""
    print("=" * 60)
    print("DEMO 1: Banach Contraction Iteration")
    print("=" * 60)

    # Example: f(x) = cos(x) on [0, pi], K ≈ 0.84
    f = np.cos
    K = np.sin(1.0)  # Lipschitz constant on [0, pi] is max|sin(x)| ≈ sin(1)
    x0 = 0.0
    x_star = 0.7390851332151607  # cos(x*) = x*

    print(f"\nContraction map: f(x) = cos(x)")
    print(f"Contraction constant K ≈ {K:.4f}")
    print(f"Starting point x₀ = {x0}")
    print(f"True fixed point x* ≈ {x_star:.10f}")
    print()

    iterates = [x0]
    errors = []
    x = x0
    for n in range(20):
        error = abs(x - x_star)
        bound = K**n * abs(x0 - x_star)
        errors.append((n, error, bound))
        print(f"  n={n:2d}: x_n = {x:.10f},  |x_n - x*| = {error:.2e},  "
              f"K^n·d₀ = {bound:.2e}")
        x = f(x)
        iterates.append(x)

    # Plot convergence
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    ns = [e[0] for e in errors]
    actual = [e[1] for e in errors]
    bounds = [e[2] for e in errors]

    ax1.semilogy(ns, actual, 'bo-', label='Actual error |x_n - x*|')
    ax1.semilogy(ns, bounds, 'r--', label='Geometric bound K^n · d₀')
    ax1.set_xlabel('Iteration n')
    ax1.set_ylabel('Error')
    ax1.set_title('Banach Contraction: Geometric Convergence')
    ax1.legend()
    ax1.grid(True)

    # Cobweb diagram
    xs = np.linspace(-0.5, 2, 200)
    ax2.plot(xs, np.cos(xs), 'b-', label='f(x) = cos(x)')
    ax2.plot(xs, xs, 'k--', label='y = x')
    for i in range(min(10, len(iterates) - 1)):
        xi = iterates[i]
        fi = iterates[i + 1]
        ax2.plot([xi, xi], [xi, fi], 'r-', alpha=0.5)
        ax2.plot([xi, fi], [fi, fi], 'r-', alpha=0.5)
    ax2.plot(x_star, x_star, 'g*', markersize=15, label=f'Fixed point x* ≈ {x_star:.4f}')
    ax2.set_xlabel('x')
    ax2.set_ylabel('f(x)')
    ax2.set_title('Cobweb Diagram')
    ax2.legend()
    ax2.grid(True)

    plt.tight_layout()
    plt.savefig('banach_convergence.png', dpi=150)
    print(f"\n  → Saved banach_convergence.png")


# ─────────────────────────────────────────────────────────────────────
# Demo 2: Approximate Brouwer Witness on 2D Square
# ─────────────────────────────────────────────────────────────────────

def demo_brouwer_2d():
    """Find approximate Brouwer fixed point via grid search on [0,1]²."""
    print("\n" + "=" * 60)
    print("DEMO 2: Approximate Brouwer Witness (2D)")
    print("=" * 60)

    # A continuous self-map of [0,1]² → [0,1]²
    def f(x, y):
        fx = np.clip(0.5 + 0.3 * np.sin(2 * np.pi * x) + 0.2 * y, 0, 1)
        fy = np.clip(0.4 + 0.25 * np.cos(3 * np.pi * y) + 0.15 * x, 0, 1)
        return fx, fy

    print(f"\nMap: f(x,y) = (0.5 + 0.3·sin(2πx) + 0.2y, 0.4 + 0.25·cos(3πy) + 0.15x)")
    print("  clipped to [0,1]²")

    # Grid search for approximate fixed point
    best_residual = float('inf')
    best_point = (0, 0)
    grid_sizes = [10, 50, 100, 500]

    print("\nGrid search:")
    for N in grid_sizes:
        for i in range(N + 1):
            for j in range(N + 1):
                x, y = i / N, j / N
                fx, fy = f(x, y)
                residual = np.sqrt((fx - x)**2 + (fy - y)**2)
                if residual < best_residual:
                    best_residual = residual
                    best_point = (x, y)
        fx, fy = f(*best_point)
        print(f"  N={N:4d}: best (x,y) = ({best_point[0]:.6f}, {best_point[1]:.6f}), "
              f"‖f(x)-x‖ = {best_residual:.2e}")

    # Visualize
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    N = 30
    X, Y = np.meshgrid(np.linspace(0, 1, N), np.linspace(0, 1, N))
    FX, FY = f(X, Y)
    DX, DY = FX - X, FY - Y
    residuals = np.sqrt(DX**2 + DY**2)

    ax1.quiver(X, Y, DX, DY, residuals, cmap='viridis', scale=10)
    ax1.plot(*best_point, 'r*', markersize=15, label=f'Best approx FP')
    ax1.set_xlabel('x')
    ax1.set_ylabel('y')
    ax1.set_title('Displacement field f(p) - p')
    ax1.legend()
    ax1.set_xlim(0, 1)
    ax1.set_ylim(0, 1)

    # Residual heatmap
    N_heat = 100
    X2, Y2 = np.meshgrid(np.linspace(0, 1, N_heat), np.linspace(0, 1, N_heat))
    FX2, FY2 = f(X2, Y2)
    R = np.sqrt((FX2 - X2)**2 + (FY2 - Y2)**2)

    im = ax2.imshow(R, extent=[0, 1, 0, 1], origin='lower', cmap='hot_r')
    ax2.plot(*best_point, 'c*', markersize=15, label=f'Approx FP')
    ax2.set_xlabel('x')
    ax2.set_ylabel('y')
    ax2.set_title('Residual ‖f(p) - p‖')
    plt.colorbar(im, ax=ax2)
    ax2.legend()

    plt.tight_layout()
    plt.savefig('brouwer_2d.png', dpi=150)
    print(f"\n  → Saved brouwer_2d.png")


# ─────────────────────────────────────────────────────────────────────
# Demo 3: Volterra Integral Operator
# ─────────────────────────────────────────────────────────────────────

def demo_volterra():
    """Demonstrate fixed-point iteration for a Volterra integral equation."""
    print("\n" + "=" * 60)
    print("DEMO 3: Volterra Integral Equation")
    print("=" * 60)

    # Solve u(x) = g(x) + λ ∫₀ˣ K(x,t) u(t) dt
    # where g(x) = 1, K(x,t) = 1, λ = 0.3
    # True solution: u(x) = exp(0.3x)

    lam = 0.3
    N = 100
    xs = np.linspace(0, 1, N)
    h = xs[1] - xs[0]

    def volterra_iterate(u):
        """Apply the Volterra operator: g + λ ∫₀ˣ K(x,t)u(t)dt."""
        u_new = np.ones_like(u)
        for i in range(N):
            integral = np.trapezoid(u[:i + 1], xs[:i + 1])
            u_new[i] = 1.0 + lam * integral
        return u_new

    print(f"\nVolterra equation: u(x) = 1 + {lam} · ∫₀ˣ u(t) dt")
    print(f"True solution: u(x) = exp({lam}x)")
    print(f"Contraction constant ≤ λ = {lam} < 1")

    u = np.ones(N)  # Initial guess
    true_sol = np.exp(lam * xs)

    errors = []
    for n in range(15):
        error = np.max(np.abs(u - true_sol))
        errors.append(error)
        print(f"  n={n:2d}: max|u_n - u*| = {error:.2e}")
        u = volterra_iterate(u)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    ax1.plot(xs, true_sol, 'b-', linewidth=2, label='True: exp(0.3x)')
    ax1.plot(xs, u, 'r--', linewidth=2, label=f'Iterate n=15')
    ax1.plot(xs, np.ones(N), 'g:', label='Initial: u₀ = 1')
    ax1.set_xlabel('x')
    ax1.set_ylabel('u(x)')
    ax1.set_title('Volterra Integral Equation Solution')
    ax1.legend()
    ax1.grid(True)

    ax2.semilogy(range(len(errors)), errors, 'bo-')
    ax2.set_xlabel('Iteration n')
    ax2.set_ylabel('Max error')
    ax2.set_title('Convergence of Picard Iteration')
    ax2.grid(True)

    plt.tight_layout()
    plt.savefig('volterra.png', dpi=150)
    print(f"\n  → Saved volterra.png")


# ─────────────────────────────────────────────────────────────────────
# Demo 4: Stability under perturbation
# ─────────────────────────────────────────────────────────────────────

def demo_stability():
    """Demonstrate stability of fixed points under perturbation."""
    print("\n" + "=" * 60)
    print("DEMO 4: Fixed Point Stability")
    print("=" * 60)

    K = 0.5  # Contraction constant
    f = lambda x: K * x + 1  # Fixed point: x* = 1/(1-K) = 2

    print(f"\nOriginal map: f(x) = {K}x + 1, fixed point x* = {1/(1-K):.4f}")
    print(f"Contraction constant K = {K}")
    print()

    deltas = [0.01, 0.05, 0.1, 0.2, 0.5]
    print(f"{'δ':>8s}  {'True Δx*':>12s}  {'Bound δ/(1-K)':>14s}")
    print("-" * 40)

    for delta in deltas:
        g = lambda x, d=delta: K * x + 1 + d  # Perturbed map
        x_g = (1 + delta) / (1 - K)  # Perturbed fixed point
        x_f = 1 / (1 - K)
        actual_shift = abs(x_g - x_f)
        bound = delta / (1 - K)
        print(f"{delta:8.3f}  {actual_shift:12.6f}  {bound:14.6f}")


# ─────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Fixed Point Theory: Interactive Demonstrations")
    print("=" * 60)

    demo_banach_contraction()
    demo_brouwer_2d()
    demo_volterra()
    demo_stability()

    print("\n" + "=" * 60)
    print("All demos complete.")
    print("Generated plots: banach_convergence.png, brouwer_2d.png, volterra.png")
    print("=" * 60)
