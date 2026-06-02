#!/usr/bin/env python3
"""
Visualization: The Chebyshev conjugacy between the logistic map and the doubling map.
Shows how the conjugation transforms the dynamics.
"""

import numpy as np
import matplotlib.pyplot as plt


def logistic(x: float) -> float:
    return 4.0 * x * (1.0 - x)


def doubling(theta: float) -> float:
    return (2.0 * theta) % 1.0


def conjugate_forward(x: float) -> float:
    """x -> theta via arccos"""
    x = np.clip(x, 0, 1)
    return np.arccos(1.0 - 2.0 * x) / np.pi


def conjugate_inverse(theta: float) -> float:
    """theta -> x via sin^2"""
    return np.sin(np.pi * theta) ** 2


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 12))
    
    # Panel 1: Logistic map
    ax = axes[0, 0]
    x = np.linspace(0, 1, 500)
    ax.plot(x, 4*x*(1-x), 'b-', linewidth=2, label='f(x) = 4x(1−x)')
    ax.plot(x, x, 'k--', alpha=0.3, label='y = x')
    ax.set_xlabel('x')
    ax.set_ylabel('f(x)')
    ax.set_title('Logistic Map (degree 2)')
    ax.legend()
    ax.set_aspect('equal')
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    
    # Panel 2: Doubling map
    ax = axes[0, 1]
    theta = np.linspace(0, 1, 1000)
    doubling_vals = (2 * theta) % 1
    ax.plot(theta, doubling_vals, 'r-', linewidth=2, label='g(θ) = 2θ mod 1')
    ax.plot(theta, theta, 'k--', alpha=0.3, label='y = θ')
    ax.set_xlabel('θ')
    ax.set_ylabel('g(θ)')
    ax.set_title('Doubling Map (conjugate system)')
    ax.legend()
    ax.set_aspect('equal')
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    
    # Panel 3: Orbits comparison
    ax = axes[1, 0]
    x0 = 0.3
    n_steps = 50
    
    # Logistic orbit
    orbit_log = [x0]
    xc = x0
    for _ in range(n_steps):
        xc = logistic(xc)
        orbit_log.append(xc)
    
    # Conjugated doubling orbit
    theta0 = conjugate_forward(x0)
    orbit_conj = [conjugate_inverse(theta0)]
    tc = theta0
    for _ in range(n_steps):
        tc = doubling(tc)
        orbit_conj.append(conjugate_inverse(tc))
    
    steps = range(n_steps + 1)
    ax.plot(steps, orbit_log, 'b.-', markersize=3, alpha=0.7, label='Logistic orbit')
    ax.plot(steps, orbit_conj, 'r.--', markersize=3, alpha=0.7, label='Conjugated doubling orbit')
    ax.set_xlabel('Iteration n')
    ax.set_ylabel('Value')
    ax.set_title('Orbit Comparison (x₀ = 0.3)')
    ax.legend()
    ax.set_xlim(0, n_steps)
    
    # Panel 4: Degree growth
    ax = axes[1, 1]
    ns = np.arange(1, 21)
    degrees = 2 ** ns
    ax.semilogy(ns, degrees, 'go-', markersize=6, linewidth=2)
    ax.set_xlabel('Iteration depth n')
    ax.set_ylabel('Polynomial degree d^n')
    ax.set_title('Iterate Degree Theorem: deg(f^n) = 2^n')
    ax.grid(True, alpha=0.3)
    ax.set_xlim(1, 20)
    
    # Annotate
    for n in [5, 10, 15, 20]:
        ax.annotate(f'2^{n} = {2**n:,}', xy=(n, 2**n),
                   xytext=(n+0.5, 2**n * 2),
                   fontsize=9, ha='left')
    
    plt.suptitle('Chebyshev Conjugacy: Why the Logistic Map Fails as Crypto',
                 fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('conjugacy_analysis.png', dpi=150, bbox_inches='tight')
    print("Saved: conjugacy_analysis.png")
    plt.close()


if __name__ == "__main__":
    main()
