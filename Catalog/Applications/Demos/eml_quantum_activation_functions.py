#!/usr/bin/env python3
"""
Quantum EML Activation Function — Numerical Demonstrations

Demonstrates the key theorems from the Lean formalization:
1. Phase-amplitude factorization: |qeml(θ,r)| depends only on r
2. Surjectivity: every complex number is reachable
3. Classical bridge: ceml restricted to reals = classical eml
4. Norm lower bound: |arctan(r)| ≤ |qeml(θ,r)|
"""

import numpy as np


def qeml(theta: float, r: float) -> complex:
    """Quantum EML activation: exp(iθ) · log(1 + ri)"""
    return np.exp(1j * theta) * np.log(1 + r * 1j)


def ceml(z1: complex, z2: complex) -> complex:
    """Complex EML: exp(z1) - log(z2)"""
    return np.exp(z1) - np.log(z2)


def qeml_norm(r: float) -> float:
    """Quantum EML norm function: ‖log(1 + ri)‖"""
    return abs(np.log(1 + r * 1j))


def qeml_inverse(w: complex, tol: float = 1e-12) -> tuple:
    """Find (θ, r) such that qeml(θ, r) ≈ w (inverse map)."""
    if abs(w) < tol:
        return (0.0, 0.0)
    target_norm = abs(w)
    # Binary search for r such that qeml_norm(r) = target_norm
    lo, hi = 0.0, 1.0
    while qeml_norm(hi) < target_norm:
        hi *= 2
    for _ in range(100):
        mid = (lo + hi) / 2
        if qeml_norm(mid) < target_norm:
            lo = mid
        else:
            hi = mid
    r = (lo + hi) / 2
    L = np.log(1 + r * 1j)
    theta = np.angle(w / L)
    return (theta, r)


def demo_phase_amplitude_factorization():
    """Theorem 1: ‖qeml(θ,r)‖ = qeml_norm(r) — independent of θ."""
    print("=" * 60)
    print("DEMO 1: Phase-Amplitude Factorization")
    print("  Theorem: ‖qeml(θ,r)‖ depends only on r, not θ")
    print("=" * 60)
    for r in [0.5, 1.0, 2.0, 5.0]:
        norms = [abs(qeml(theta, r)) for theta in np.linspace(0, 2 * np.pi, 20)]
        expected = qeml_norm(r)
        max_dev = max(abs(n - expected) for n in norms)
        print(f"  r={r:5.1f}: qeml_norm = {expected:.6f}, "
              f"max deviation over 20 phases: {max_dev:.2e}")
    print()


def demo_surjectivity():
    """Theorem 3: Every w ∈ ℂ is in the range of qeml."""
    print("=" * 60)
    print("DEMO 2: Surjectivity — Every ℂ target is reachable")
    print("=" * 60)
    targets = [0.0, 1.0, -1.0, 1j, 3 + 4j, -2 - 7j, 0.001 + 0.002j, 100 + 200j]
    for w in targets:
        theta, r = qeml_inverse(w)
        result = qeml(theta, r)
        error = abs(result - w)
        wstr = str(w)
        print(f"  Target: {wstr:>16s}  ->  qeml({theta:+.4f}, {r:.4f}) = "
              f"{result.real:+.4f}{result.imag:+.4f}i  "
              f"error: {error:.2e}")
    print()


def demo_classical_bridge():
    """Theorem 6: ceml(x,y).real = exp(x) - log(y) for real x,y."""
    print("=" * 60)
    print("DEMO 3: Classical Bridge — ceml restricted to ℝ = eml")
    print("=" * 60)
    for x, y in [(0, 1), (1, np.e), (2, 0.5), (-1, 3)]:
        complex_result = ceml(complex(x), complex(y)).real
        classical_result = np.exp(x) - np.log(y)
        error = abs(complex_result - classical_result)
        print(f"  x={x:+.1f}, y={y:.2f}: ceml.real = {complex_result:.6f}, "
              f"eml = {classical_result:.6f}, error = {error:.2e}")
    print()


def demo_norm_lower_bound():
    """Theorem 7: |arctan(r)| ≤ ‖qeml(θ,r)‖"""
    print("=" * 60)
    print("DEMO 4: Norm Lower Bound — |arctan(r)| ≤ ‖qeml(θ,r)‖")
    print("=" * 60)
    for r in [0.1, 0.5, 1.0, 2.0, 5.0, 10.0, 100.0]:
        bound = abs(np.arctan(r))
        for theta in np.linspace(0, 2 * np.pi, 10):
            norm = abs(qeml(theta, r))
            assert bound <= norm + 1e-10, f"Bound violated at θ={theta}, r={r}"
        norm_at_0 = abs(qeml(0, r))
        ratio = norm_at_0 / bound if bound > 0 else float('inf')
        print(f"  r={r:6.1f}: |arctan(r)| = {bound:.6f}, "
              f"‖qeml(0,r)‖ = {norm_at_0:.6f}, ratio = {ratio:.3f}")
    print()


def demo_component_formulas():
    """Theorem 2: Re(log(1+ri)) = log√(1+r²), Im(log(1+ri)) = arctan(r)"""
    print("=" * 60)
    print("DEMO 5: Component Formulas")
    print("=" * 60)
    for r in [0, 0.5, 1, 2, 5, -3]:
        L = np.log(1 + r * 1j)
        expected_re = np.log(np.sqrt(1 + r**2))
        expected_im = np.arctan(r)
        print(f"  r={r:+.1f}: Re = {L.real:+.6f} (expected {expected_re:+.6f}), "
              f"Im = {L.imag:+.6f} (expected {expected_im:+.6f})")
    print()


if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("  QUANTUM EML ACTIVATION FUNCTION — NUMERICAL DEMOS")
    print("=" * 60 + "\n")

    demo_phase_amplitude_factorization()
    demo_surjectivity()
    demo_classical_bridge()
    demo_norm_lower_bound()
    demo_component_formulas()

    print("All demos completed successfully!")


#!/usr/bin/env python3
"""
Visualization: Quantum EML Norm Function and Lower Bound

Shows qemlNorm(r) = ‖log(1+ri)‖ alongside its components and the arctan lower bound.
"""
import numpy as np
import matplotlib.pyplot as plt


def qeml_norm(r):
    return np.abs(np.log(1 + r * 1j))


def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    r = np.linspace(-20, 20, 1000)
    r_pos = np.linspace(0.01, 20, 500)

    # Panel 1: Norm function and its components
    ax = axes[0]
    norm_vals = qeml_norm(r)
    re_part = 0.5 * np.log(1 + r**2)
    im_part = np.arctan(r)

    ax.plot(r, norm_vals, 'b-', linewidth=2, label='‖log(1+ri)‖ (full norm)')
    ax.plot(r, re_part, 'r--', linewidth=1.5, label='½log(1+r²) (real part)')
    ax.plot(r, np.abs(im_part), 'g-.', linewidth=1.5, label='|arctan(r)| (lower bound)')
    ax.fill_between(r, np.abs(im_part), norm_vals, alpha=0.1, color='blue',
                    label='Gap above bound')
    ax.set_xlabel('r')
    ax.set_ylabel('Value')
    ax.set_title('Quantum EML Norm: Components and Lower Bound')
    ax.legend()
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0, 5)

    # Panel 2: Norm function showing divergence (proves tendsto_atTop)
    ax = axes[1]
    r_large = np.linspace(0, 1000, 2000)
    ax.plot(r_large, qeml_norm(r_large), 'b-', linewidth=2, label='‖log(1+ri)‖')
    ax.plot(r_large, 0.5 * np.log(1 + r_large**2), 'r--', linewidth=1.5,
            label='½log(1+r²) (→ ∞)')
    ax.set_xlabel('r')
    ax.set_ylabel('qemlNorm(r)')
    ax.set_title('Norm Divergence (proves tendsto_atTop)')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.suptitle('Quantum EML Norm Analysis', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('Applications/qeml_norm_analysis.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: Applications/qeml_norm_analysis.png")


if __name__ == "__main__":
    main()


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
