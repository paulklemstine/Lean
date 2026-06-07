#!/usr/bin/env python3
"""
Visualization: Quantum EML Surjectivity

Shows how qeml(θ, r) covers the complex plane as θ and r vary.
Demonstrates the U(1)-fibration structure: circles of constant r,
rays of constant θ.
"""
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.cm as cm


def qeml(theta, r):
    return np.exp(1j * theta) * np.log(1 + r * 1j)


def main():
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    # Panel 1: Circles of constant r (varying θ)
    ax = axes[0]
    r_values = [0.5, 1, 2, 3, 5, 8, 15]
    thetas = np.linspace(0, 2 * np.pi, 200)
    colors = cm.viridis(np.linspace(0.1, 0.9, len(r_values)))
    for r, c in zip(r_values, colors):
        z = qeml(thetas, r)
        ax.plot(z.real, z.imag, color=c, linewidth=1.5, label=f'r={r}')
    ax.set_xlabel('Re(qeml)')
    ax.set_ylabel('Im(qeml)')
    ax.set_title('Constant-r curves (U(1) orbits)')
    ax.legend(fontsize=8)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)
    ax.axhline(y=0, color='k', linewidth=0.5)
    ax.axvline(x=0, color='k', linewidth=0.5)

    # Panel 2: Rays of constant θ (varying r)
    ax = axes[1]
    theta_values = np.linspace(0, 2 * np.pi, 13)[:-1]
    r_range = np.linspace(0.01, 20, 300)
    colors2 = cm.hsv(np.linspace(0, 1, len(theta_values), endpoint=False))
    for theta, c in zip(theta_values, colors2):
        z = qeml(theta, r_range)
        ax.plot(z.real, z.imag, color=c, linewidth=1, alpha=0.8,
                label=f'θ={theta:.1f}')
    ax.set_xlabel('Re(qeml)')
    ax.set_ylabel('Im(qeml)')
    ax.set_title('Constant-θ curves (radial rays)')
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)
    ax.axhline(y=0, color='k', linewidth=0.5)
    ax.axvline(x=0, color='k', linewidth=0.5)
    ax.set_xlim(-5, 5)
    ax.set_ylim(-5, 5)

    # Panel 3: Dense coverage
    ax = axes[2]
    N = 5000
    thetas_rand = np.random.uniform(0, 2 * np.pi, N)
    r_rand = np.random.exponential(3, N)
    z = qeml(thetas_rand, r_rand)
    ax.scatter(z.real, z.imag, s=1, alpha=0.3, c=np.abs(z), cmap='plasma')
    ax.set_xlabel('Re(qeml)')
    ax.set_ylabel('Im(qeml)')
    ax.set_title('Random sampling: full ℂ coverage')
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)
    ax.set_xlim(-6, 6)
    ax.set_ylim(-6, 6)

    plt.suptitle('Quantum EML Surjectivity: qeml(θ, r) = exp(iθ) · log(1 + ri)',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('Applications/qeml_surjectivity.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: Applications/qeml_surjectivity.png")


if __name__ == "__main__":
    main()
