"""
Information Geometry of Optimization: Demo

Demonstrates the key results:
1. Natural gradient vs standard gradient on ill-conditioned quadratic
2. Bregman divergence computation and three-point identity verification
3. Convergence rate comparison across condition numbers
4. α-divergence computation
"""

import numpy as np
from algorithms import (
    natural_gradient_descent,
    standard_gradient_descent,
    bregman_divergence,
    condition_number,
    alpha_divergence,
)
from numpy.typing import NDArray

Vector = NDArray[np.float64]
Matrix = NDArray[np.float64]


def demo_convergence_comparison():
    """Compare natural gradient and standard GD on ill-conditioned problems."""
    print("=" * 60)
    print("DEMO 1: Natural Gradient vs Standard Gradient Descent")
    print("=" * 60)

    for kappa in [10, 100, 1000]:
        A = np.diag([float(kappa), 1.0])

        def loss(theta: Vector) -> float:
            return 0.5 * float(theta @ A @ theta)

        def grad(theta: Vector) -> Vector:
            return A @ theta

        def fisher(_theta: Vector) -> Matrix:
            return A

        theta0 = np.array([1.0, 1.0])

        # Natural gradient with step size 1
        eta_nat = [1.0] * 5
        _, losses_nat = natural_gradient_descent(loss, grad, fisher, theta0, eta_nat, 5)

        # Standard GD with optimal step size 2/(L+mu) = 2/(kappa+1)
        eta_opt = 2.0 / (kappa + 1)
        eta_std = [eta_opt] * 500
        _, losses_std = standard_gradient_descent(loss, grad, theta0, eta_std, 500)

        print(f"\nCondition number κ = {kappa}")
        print(f"  Natural GD:  loss after 1 step  = {losses_nat[1]:.2e}")
        print(f"  Standard GD: loss after 10 steps = {losses_std[10]:.2e}")
        print(f"  Standard GD: loss after 100 steps = {losses_std[min(100, len(losses_std)-1)]:.2e}")
        print(f"  Standard GD: loss after 500 steps = {losses_std[-1]:.2e}")
        contraction = 1 - 2.0 / (kappa + 1)
        print(f"  Theoretical contraction rate: {contraction:.6f}")
        print(f"  Steps for 1e-6 accuracy (std GD): ~{int(np.ceil(-6 * np.log(10) / np.log(contraction)))}")


def demo_bregman_three_point():
    """Verify the three-point identity for Bregman divergences."""
    print("\n" + "=" * 60)
    print("DEMO 2: Three-Point Identity for Bregman Divergence")
    print("=" * 60)

    # Use φ(x) = ‖x‖²/2 (squared Euclidean norm)
    def phi(x: Vector) -> float:
        return 0.5 * float(np.sum(x**2))

    def grad_phi(x: Vector) -> Vector:
        return x.copy()

    np.random.seed(42)
    for trial in range(3):
        x = np.random.randn(5)
        y = np.random.randn(5)
        z = np.random.randn(5)

        d_xz = bregman_divergence(phi, grad_phi, x, z)
        d_xy = bregman_divergence(phi, grad_phi, x, y)
        d_yz = bregman_divergence(phi, grad_phi, y, z)
        cross = float(np.dot(grad_phi(y) - grad_phi(z), x - y))

        lhs = d_xz
        rhs = d_xy + d_yz + cross

        print(f"\n  Trial {trial + 1}:")
        print(f"    D(x,z) = {lhs:.8f}")
        print(f"    D(x,y) + D(y,z) + <∇φ(y)-∇φ(z), x-y> = {rhs:.8f}")
        print(f"    Difference: {abs(lhs - rhs):.2e}")


def demo_alpha_divergences():
    """Compute α-divergences for varying α."""
    print("\n" + "=" * 60)
    print("DEMO 3: α-Divergences (Amari's Family)")
    print("=" * 60)

    # Two discrete distributions
    p = np.array([0.1, 0.2, 0.3, 0.4])
    q = np.array([0.25, 0.25, 0.25, 0.25])

    alphas = [-3, -1, -0.5, 0, 0.5, 1, 3]
    print(f"\n  p = {p}")
    print(f"  q = {q}")
    print(f"\n  {'α':>6}  {'D_α(p||q)':>12}")
    print(f"  {'---':>6}  {'---':>12}")
    for a in alphas:
        d = alpha_divergence(p, q, a)
        label = ""
        if a == 1:
            label = "  (KL divergence)"
        elif a == -1:
            label = "  (reverse KL)"
        elif a == 0:
            label = "  (Hellinger-like)"
        print(f"  {a:>6.1f}  {d:>12.6f}{label}")


def demo_convergence_rates():
    """Verify O(1/t) convergence for convex, O(exp(-t)) for strongly convex."""
    print("\n" + "=" * 60)
    print("DEMO 4: Convergence Rate Verification")
    print("=" * 60)

    # Strongly convex: f(x) = x^2/2, μ=L=1
    def loss_sc(theta: Vector) -> float:
        return 0.5 * float(np.sum(theta**2))

    def grad_sc(theta: Vector) -> Vector:
        return theta.copy()

    def fisher_sc(_theta: Vector) -> Matrix:
        return np.eye(len(_theta))

    theta0 = np.array([10.0])
    T = 50
    eta = [1.0] * T

    _, losses = natural_gradient_descent(loss_sc, grad_sc, fisher_sc, theta0, eta, T)

    print("\n  Strongly convex (f = x²/2, natural gradient):")
    print(f"  {'t':>4}  {'f(θ_t)':>12}  {'1/t bound':>12}")
    for t in [0, 1, 2, 5, 10]:
        bound = losses[0] / max(t, 1)
        print(f"  {t:>4}  {losses[t]:>12.6f}  {bound:>12.6f}")

    # Convex with bad conditioning
    kappa = 50
    A = np.diag([float(kappa), 1.0])

    def loss_conv(theta: Vector) -> float:
        return 0.5 * float(theta @ A @ theta)

    def grad_conv(theta: Vector) -> Vector:
        return A @ theta

    theta0_2d = np.array([1.0, 1.0])
    T2 = 200

    # Standard GD
    eta_std = [2.0 / (kappa + 1)] * T2
    _, losses_std = standard_gradient_descent(loss_conv, grad_conv, theta0_2d, eta_std, T2)

    r = (kappa - 1) / (kappa + 1)  # contraction rate
    print(f"\n  Standard GD on quadratic (κ={kappa}):")
    print(f"  Contraction rate r = (κ-1)/(κ+1) = {r:.4f}")
    print(f"  {'t':>4}  {'f(θ_t)':>12}  {'r^t * f(0)':>12}")
    for t in [0, 10, 50, 100, 200]:
        predicted = r**t * losses_std[0]
        print(f"  {t:>4}  {losses_std[t]:>12.6f}  {predicted:>12.6f}")


if __name__ == "__main__":
    demo_convergence_comparison()
    demo_bregman_three_point()
    demo_alpha_divergences()
    demo_convergence_rates()


"""
Visualization: Bregman Divergence Geometry

Standalone matplotlib script visualizing Bregman divergences and the
three-point identity in 2D.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def bregman_div_euclidean(x: np.ndarray, y: np.ndarray) -> float:
    """Bregman divergence for φ(x) = ‖x‖²/2 (squared Euclidean)."""
    return 0.5 * float(np.sum((x - y)**2))


def bregman_div_negentropy(x: np.ndarray, y: np.ndarray) -> float:
    """Bregman divergence for φ(x) = ∑ xᵢ log xᵢ (negative entropy).
    This gives the KL divergence."""
    mask = (x > 0) & (y > 0)
    return float(np.sum(x[mask] * np.log(x[mask] / y[mask]) - x[mask] + y[mask]))


def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Plot 1: Bregman divergence contours for φ = ‖x‖²/2
    ax1 = axes[0]
    y_point = np.array([0.0, 0.0])
    xx, yy = np.meshgrid(np.linspace(-3, 3, 200), np.linspace(-3, 3, 200))
    zz = np.zeros_like(xx)
    for i in range(xx.shape[0]):
        for j in range(xx.shape[1]):
            p = np.array([xx[i, j], yy[i, j]])
            zz[i, j] = bregman_div_euclidean(p, y_point)

    contours = ax1.contourf(xx, yy, zz, levels=20, cmap='viridis')
    plt.colorbar(contours, ax=ax1, label='D_φ(x, y₀)')

    # Three-point identity visualization
    x_pt = np.array([2.0, 1.0])
    y_pt = np.array([0.5, -0.5])
    z_pt = np.array([-1.0, 1.5])

    points = [x_pt, y_pt, z_pt]
    labels = ['x', 'y', 'z']
    colors_pts = ['red', 'blue', 'green']

    for pt, label, c in zip(points, labels, colors_pts):
        ax1.plot(pt[0], pt[1], 'o', color=c, markersize=10, zorder=5)
        ax1.annotate(label, pt, textcoords="offset points",
                    xytext=(10, 10), fontsize=14, fontweight='bold', color=c)

    # Draw triangle
    triangle = plt.Polygon([x_pt, y_pt, z_pt], fill=False,
                           edgecolor='white', linewidth=2, linestyle='--')
    ax1.add_patch(triangle)

    d_xz = bregman_div_euclidean(x_pt, z_pt)
    d_xy = bregman_div_euclidean(x_pt, y_pt)
    d_yz = bregman_div_euclidean(y_pt, z_pt)
    cross = float(np.dot(y_pt - z_pt, x_pt - y_pt))

    ax1.set_title('Euclidean Bregman (φ = ‖x‖²/2)', fontsize=13, fontweight='bold')
    ax1.set_xlabel('x₁', fontsize=12)
    ax1.set_ylabel('x₂', fontsize=12)

    info_text = (f'D(x,z) = {d_xz:.3f}\n'
                 f'D(x,y) + D(y,z) + ⟨·,·⟩\n'
                 f'= {d_xy:.3f} + {d_yz:.3f} + {cross:.3f}\n'
                 f'= {d_xy + d_yz + cross:.3f} ✓')
    ax1.text(0.02, 0.98, info_text, transform=ax1.transAxes,
             fontsize=10, verticalalignment='top',
             bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))

    # Plot 2: KL divergence on the 2-simplex
    ax2 = axes[1]

    # Parametrize 2-simplex as (p1, p2, 1-p1-p2)
    n_grid = 200
    p1_range = np.linspace(0.01, 0.98, n_grid)
    p2_range = np.linspace(0.01, 0.98, n_grid)
    pp1, pp2 = np.meshgrid(p1_range, p2_range)

    q_point = np.array([1/3, 1/3, 1/3])  # uniform
    kl_vals = np.full_like(pp1, np.nan)

    for i in range(n_grid):
        for j in range(n_grid):
            if pp1[i, j] + pp2[i, j] < 0.99:
                p = np.array([pp1[i, j], pp2[i, j], 1 - pp1[i, j] - pp2[i, j]])
                kl_vals[i, j] = bregman_div_negentropy(p, q_point)

    contours2 = ax2.contourf(pp1, pp2, kl_vals, levels=20, cmap='magma')
    plt.colorbar(contours2, ax=ax2, label='KL(p || uniform)')

    # Draw simplex boundary
    ax2.plot([0, 1, 0, 0], [0, 0, 1, 0], 'w-', linewidth=2)
    ax2.plot(1/3, 1/3, 'w*', markersize=15, zorder=5)
    ax2.annotate('uniform', (1/3, 1/3), textcoords="offset points",
                xytext=(10, 10), fontsize=12, color='white', fontweight='bold')

    ax2.set_title('KL Divergence (φ = negative entropy)', fontsize=13, fontweight='bold')
    ax2.set_xlabel('p₁', fontsize=12)
    ax2.set_ylabel('p₂', fontsize=12)
    ax2.set_xlim(-0.05, 1.05)
    ax2.set_ylim(-0.05, 1.05)

    plt.suptitle('Bregman Divergence Geometry', fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('bregman_geometry.png', dpi=150, bbox_inches='tight')
    print("Saved bregman_geometry.png")


if __name__ == "__main__":
    main()


"""
Visualization: Natural Gradient vs Standard Gradient Convergence

Standalone matplotlib script showing convergence curves for different
condition numbers, demonstrating condition-number independence of
natural gradient descent.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from numpy.typing import NDArray

Vector = NDArray[np.float64]
Matrix = NDArray[np.float64]


def run_natural_gd(A: Matrix, theta0: Vector, T: int) -> list:
    """Natural gradient descent on f(θ) = θᵀAθ/2 with Fisher = A."""
    theta = theta0.copy()
    losses = [0.5 * float(theta @ A @ theta)]
    for _ in range(T):
        grad = A @ theta
        nat_grad = np.linalg.solve(A, grad)  # A^{-1} A theta = theta
        theta = theta - 1.0 * nat_grad
        losses.append(0.5 * float(theta @ A @ theta))
    return losses


def run_standard_gd(A: Matrix, theta0: Vector, T: int) -> list:
    """Standard GD on f(θ) = θᵀAθ/2 with optimal step size."""
    eigs = np.linalg.eigvalsh(A)
    eta = 2.0 / (eigs[-1] + eigs[0])
    theta = theta0.copy()
    losses = [0.5 * float(theta @ A @ theta)]
    for _ in range(T):
        grad = A @ theta
        theta = theta - eta * grad
        losses.append(0.5 * float(theta @ A @ theta))
    return losses


def main():
    T = 200
    theta0 = np.array([1.0, 1.0])
    condition_numbers = [1, 10, 100, 1000]
    colors = ['#2196F3', '#4CAF50', '#FF9800', '#F44336']

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Plot 1: Standard GD for different κ
    ax1 = axes[0]
    for kappa, color in zip(condition_numbers, colors):
        A = np.diag([float(kappa), 1.0])
        losses = run_standard_gd(A, theta0, T)
        losses_normalized = [l / losses[0] for l in losses]
        ax1.semilogy(losses_normalized, color=color, label=f'κ = {kappa}', linewidth=2)

    ax1.set_xlabel('Iteration t', fontsize=13)
    ax1.set_ylabel('f(θ_t) / f(θ₀)', fontsize=13)
    ax1.set_title('Standard Gradient Descent', fontsize=14, fontweight='bold')
    ax1.legend(fontsize=11)
    ax1.set_ylim(1e-8, 2)
    ax1.grid(True, alpha=0.3)

    # Plot 2: Natural GD for different κ
    ax2 = axes[1]
    for kappa, color in zip(condition_numbers, colors):
        A = np.diag([float(kappa), 1.0])
        losses = run_natural_gd(A, theta0, 5)
        losses_normalized = [max(l / losses[0], 1e-16) for l in losses]
        ax2.semilogy(losses_normalized, 'o-', color=color, label=f'κ = {kappa}',
                     linewidth=2, markersize=8)

    ax2.set_xlabel('Iteration t', fontsize=13)
    ax2.set_ylabel('f(θ_t) / f(θ₀)', fontsize=13)
    ax2.set_title('Natural Gradient Descent', fontsize=14, fontweight='bold')
    ax2.legend(fontsize=11)
    ax2.set_ylim(1e-8, 2)
    ax2.grid(True, alpha=0.3)

    plt.suptitle('Condition Number Independence of Natural Gradient',
                 fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('convergence_comparison.png', dpi=150, bbox_inches='tight')
    print("Saved convergence_comparison.png")


if __name__ == "__main__":
    main()
