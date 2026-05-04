#!/usr/bin/env python3
"""
Demonstration: EML Stone–Weierstrass for Compact Retract Codomains

This demo visualizes the core mechanism of the ambient-approximation-then-retraction
theorem: approximate a map f: X → K (where K ⊂ ℝ² is a compact retract) by first
approximating f in the ambient ℝ², then retracting back to K.

We demonstrate with:
1. K = unit circle S¹ ⊂ ℝ² (retract of ℝ²\{0} via normalization)
2. K = closed unit disk (retract of ℝ² via metric projection)
3. Convergence analysis
4. Thickening/tube lemma visualization
5. Neural network constraint applications
"""

import math
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec


def retract_to_circle(points):
    """Retract points in ℝ²\\{0} onto the unit circle."""
    norms = np.sqrt(points[:, 0]**2 + points[:, 1]**2)
    norms = np.maximum(norms, 1e-10)
    return points / norms[:, np.newaxis]


def polynomial_approx_circle(t, degree=5):
    """Approximate the circle map t ↦ (cos(2πt), sin(2πt)) using truncated Taylor series."""
    theta = 2 * np.pi * t
    cos_approx = sum(((-1)**k * theta**(2*k) / math.factorial(2*k)) for k in range(degree+1))
    sin_approx = sum(((-1)**k * theta**(2*k+1) / math.factorial(2*k+1)) for k in range(degree+1))
    return np.column_stack([cos_approx, sin_approx])


def demo_circle():
    """Demonstrate approximation of a circle-valued map."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    t = np.linspace(0, 1, 200)
    true_map = np.column_stack([np.cos(2*np.pi*t), np.sin(2*np.pi*t)])

    for idx, degree in enumerate([3, 5, 9]):
        ax = axes[idx]
        poly_approx = polynomial_approx_circle(t, degree=degree)
        retracted = retract_to_circle(poly_approx)

        theta_circle = np.linspace(0, 2*np.pi, 100)
        ax.plot(np.cos(theta_circle), np.sin(theta_circle), 'k-', lw=2, alpha=0.3, label='K = S¹')
        ax.plot(true_map[:, 0], true_map[:, 1], 'b-', lw=1.5, alpha=0.5, label='f(t) (true)')
        ax.plot(poly_approx[:, 0], poly_approx[:, 1], 'r--', lw=1, alpha=0.7,
                label=f'g(t) (poly deg {degree})')
        ax.plot(retracted[:, 0], retracted[:, 1], 'g-', lw=2, label='r∘g(t) (retracted)')

        for i in range(0, len(t), 20):
            if np.linalg.norm(poly_approx[i] - retracted[i]) > 0.02:
                ax.annotate('', xy=retracted[i], xytext=poly_approx[i],
                           arrowprops=dict(arrowstyle='->', color='orange', lw=1, alpha=0.6))

        error = np.max(np.sqrt(np.sum((retracted - true_map)**2, axis=1)))
        ax.set_title(f'Degree {degree}, max error: {error:.4f}')
        ax.set_aspect('equal')
        ax.legend(fontsize=8, loc='lower left')
        ax.set_xlim(-2, 2); ax.set_ylim(-2, 2)
        ax.grid(True, alpha=0.3)

    fig.suptitle('EML Approximation → Retraction to S¹', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('demos/circle_retract_approx.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: demos/circle_retract_approx.png")


def demo_convergence():
    """Show how retraction preserves approximation quality."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
    degrees = range(2, 20)
    t = np.linspace(0, 0.95, 500)
    true_map = np.column_stack([np.cos(2*np.pi*t), np.sin(2*np.pi*t)])

    errors_ambient = []
    errors_retracted = []

    for deg in degrees:
        theta = 2 * np.pi * t
        cos_approx = sum(((-1)**k * theta**(2*k) / math.factorial(2*k)) for k in range(deg+1))
        sin_approx = sum(((-1)**k * theta**(2*k+1) / math.factorial(2*k+1)) for k in range(deg+1))
        poly = np.column_stack([cos_approx, sin_approx])
        retracted = retract_to_circle(poly)

        errors_ambient.append(np.max(np.sqrt(np.sum((poly - true_map)**2, axis=1))))
        errors_retracted.append(np.max(np.sqrt(np.sum((retracted - true_map)**2, axis=1))))

    ax1.semilogy(list(degrees), errors_ambient, 'ro-', label='‖g - f‖ (ambient)', markersize=5)
    ax1.semilogy(list(degrees), errors_retracted, 'g^-', label='‖r∘g - f‖ (retracted)', markersize=5)
    ax1.set_xlabel('Polynomial degree')
    ax1.set_ylabel('Max error (log scale)')
    ax1.set_title('Convergence: Ambient vs. Retracted Error')
    ax1.legend(); ax1.grid(True, alpha=0.3)

    ratios = [er/ea if ea > 1e-15 else 1.0 for ea, er in zip(errors_ambient, errors_retracted)]
    ax2.plot(list(degrees), ratios, 'b*-', markersize=8)
    ax2.axhline(y=1, color='k', linestyle='--', alpha=0.5)
    ax2.set_xlabel('Polynomial degree')
    ax2.set_ylabel('Ratio: retracted / ambient error')
    ax2.set_title('Error Ratio (retraction can improve or worsen)')
    ax2.grid(True, alpha=0.3)

    fig.suptitle('Convergence Analysis for Circle Approximation', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('demos/convergence_analysis.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: demos/convergence_analysis.png")


def demo_thickening():
    """Visualize the uniform thickening around a compact set inside an open set."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    t = np.linspace(0, 2*np.pi, 500)
    Kx = np.sin(t)
    Ky = np.sin(2*t) * 0.5

    for idx, (eta, title) in enumerate([
        (0.3, 'η = 0.3 (thickening ⊆ U)'),
        (0.15, 'η = 0.15 (tighter tube)'),
        (0.05, 'η = 0.05 (minimal tube)')
    ]):
        ax = axes[idx]
        ax.plot(Kx, Ky, 'b-', lw=2, label='K (compact)')

        for i in range(0, len(t), 50):
            theta_ball = np.linspace(0, 2*np.pi, 50)
            bx = Kx[i] + eta * np.cos(theta_ball)
            by_ = Ky[i] + eta * np.sin(theta_ball)
            ax.plot(bx, by_, 'g-', lw=0.5, alpha=0.5)
            ax.fill(bx, by_, alpha=0.05, color='green')

        ax.set_title(title)
        ax.set_aspect('equal')
        ax.set_xlim(-1.8, 1.8); ax.set_ylim(-1.2, 1.2)
        ax.grid(True, alpha=0.3)
        ax.legend(fontsize=8)

    fig.suptitle('Compact Set K ⊂ Open Set U: Uniform Thickening η', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('demos/thickening_visualization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: demos/thickening_visualization.png")


def demo_applications():
    """Show practical applications of the retract approximation theorem."""
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))

    # Application 1: Robotics — joint angle constraints
    ax = axes[0, 0]
    t = np.linspace(0, 2*np.pi, 200)
    # True trajectory on torus (two joint angles)
    theta1 = np.sin(t) * 0.8
    theta2 = np.cos(2*t) * 0.6

    # Polynomial approximation that may leave feasible region [-π, π]²
    np.random.seed(42)
    noise1 = 0.3 * np.sin(5*t + 1)
    noise2 = 0.3 * np.cos(3*t + 2)
    approx_theta1 = theta1 + noise1
    approx_theta2 = theta2 + noise2

    # Retraction: clip to feasible region
    ret_theta1 = np.clip(approx_theta1, -np.pi, np.pi)
    ret_theta2 = np.clip(approx_theta2, -np.pi, np.pi)

    ax.plot(theta1, theta2, 'b-', lw=2, label='Target trajectory')
    ax.plot(approx_theta1, approx_theta2, 'r--', lw=1, alpha=0.5, label='EML approx')
    ax.plot(ret_theta1, ret_theta2, 'g-', lw=1.5, label='Retracted (feasible)')
    ax.axhline(y=np.pi, color='k', linestyle=':', alpha=0.3)
    ax.axhline(y=-np.pi, color='k', linestyle=':', alpha=0.3)
    ax.axvline(x=np.pi, color='k', linestyle=':', alpha=0.3)
    ax.axvline(x=-np.pi, color='k', linestyle=':', alpha=0.3)
    ax.set_xlabel('Joint angle θ₁'); ax.set_ylabel('Joint angle θ₂')
    ax.set_title('Robotics: Joint Angle Constraints')
    ax.legend(fontsize=8); ax.grid(True, alpha=0.3)

    # Application 2: Stochastic matrices — rows sum to 1, entries ≥ 0
    ax = axes[0, 1]
    t = np.linspace(0, 1, 100)
    # True: probability distribution over 3 states
    p1 = 0.5 + 0.3*np.sin(2*np.pi*t)
    p2 = 0.3 + 0.2*np.cos(2*np.pi*t)
    p3 = 1 - p1 - p2

    # Noisy approximation
    noise = 0.1 * np.random.randn(100, 3)
    approx = np.column_stack([p1, p2, p3]) + noise

    # Retract to simplex
    retracted = np.maximum(approx, 0)
    retracted = retracted / retracted.sum(axis=1, keepdims=True)

    ax.plot(t, p1, 'b-', lw=2, label='p₁ (true)')
    ax.plot(t, p2, 'r-', lw=2, label='p₂ (true)')
    ax.plot(t, p3, 'g-', lw=2, label='p₃ (true)')
    ax.plot(t, retracted[:, 0], 'b--', lw=1, alpha=0.7, label='p₁ (retracted)')
    ax.plot(t, retracted[:, 1], 'r--', lw=1, alpha=0.7, label='p₂ (retracted)')
    ax.plot(t, retracted[:, 2], 'g--', lw=1, alpha=0.7, label='p₃ (retracted)')
    ax.set_xlabel('Parameter t'); ax.set_ylabel('Probability')
    ax.set_title('Probability Distributions on Simplex')
    ax.legend(fontsize=7, ncol=2); ax.grid(True, alpha=0.3)

    # Application 3: Unit quaternions (orientation representation)
    ax = axes[1, 0]
    t = np.linspace(0, 2*np.pi, 200)
    # Rotation in quaternion space
    q = np.column_stack([np.cos(t/2), np.sin(t/2)*np.cos(t),
                          np.sin(t/2)*np.sin(t), np.zeros_like(t)])
    q = q / np.sqrt(np.sum(q**2, axis=1, keepdims=True))

    noise = 0.2 * np.random.randn(200, 4)
    approx_q = q + noise
    ret_q = approx_q / np.sqrt(np.sum(approx_q**2, axis=1, keepdims=True))

    norms_before = np.sqrt(np.sum(approx_q**2, axis=1))
    norms_after = np.sqrt(np.sum(ret_q**2, axis=1))
    errors = np.sqrt(np.sum((ret_q - q)**2, axis=1))

    ax.plot(t, norms_before, 'r-', alpha=0.5, label='‖g(t)‖ (before retraction)')
    ax.plot(t, norms_after, 'g-', lw=2, label='‖r∘g(t)‖ = 1 (after)')
    ax.plot(t, errors, 'b--', lw=1, label='‖r∘g - f‖ (error)')
    ax.axhline(y=1, color='k', linestyle=':', alpha=0.5)
    ax.set_xlabel('Parameter t'); ax.set_ylabel('Value')
    ax.set_title('Unit Quaternions (S³ ⊂ ℝ⁴)')
    ax.legend(fontsize=8); ax.grid(True, alpha=0.3)

    # Application 4: Summary diagram
    ax = axes[1, 1]
    ax.text(0.5, 0.85, 'Universal Pattern', fontsize=16, fontweight='bold',
            ha='center', va='center', transform=ax.transAxes)
    ax.text(0.5, 0.65, 'f : X → K  (target)', fontsize=14,
            ha='center', va='center', transform=ax.transAxes, color='blue')
    ax.text(0.5, 0.50, '↓ approximate in ℝⁿ', fontsize=12,
            ha='center', va='center', transform=ax.transAxes, color='red')
    ax.text(0.5, 0.35, 'g : X → ℝⁿ  (EML/polynomial)', fontsize=14,
            ha='center', va='center', transform=ax.transAxes, color='red')
    ax.text(0.5, 0.20, '↓ retract r : U → K', fontsize=12,
            ha='center', va='center', transform=ax.transAxes, color='green')
    ax.text(0.5, 0.05, 'r∘g : X → K  (constrained approx)', fontsize=14,
            ha='center', va='center', transform=ax.transAxes, color='green')
    ax.axis('off')

    fig.suptitle('Applications of the Compact Retract Approximation Theorem',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('demos/applications.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: demos/applications.png")


if __name__ == '__main__':
    print("=" * 60)
    print("EML Stone–Weierstrass for Compact Retract Codomains")
    print("Demonstrations and Visualizations")
    print("=" * 60)
    print()

    demo_circle()
    demo_convergence()
    demo_thickening()
    demo_applications()

    print()
    print("All demos completed successfully!")
    print()
    print("Key insight: The retraction theorem provides a universal mechanism")
    print("for upgrading approximation in ambient Euclidean space to")
    print("approximation on any compact neighborhood retract K ⊆ ℝⁿ.")
