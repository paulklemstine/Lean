#!/usr/bin/env python3
"""
Tropical-Quantum Bridge: SPB-Maslov Dequantization Pipeline
============================================================

This demo explores the bridge between:
1. The Lohmiller-Slotine classical→quantum construction (ψ = √ρ·e^{iφ/ℏ})
2. The Stereographic Pythagorean Bridge (SPB) algebra
3. Tropical geometry via Maslov dequantization

Key insight: The SPB tangent addition formula s⊕t = (s+t)/(1-st)
governs phase composition in the wave ansatz, while the tropical
limit (ℏ→0) converts quantum superposition to min-plus algebra.

This creates a pipeline: Pythagorean geometry → SPB → Phase algebra →
Quantum waves → Tropical limit → Classical optimization.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import product
from matplotlib.gridspec import GridSpec

# ============================================================================
# SPB Operations
# ============================================================================

def spb(s, t):
    """Stereographic Pythagorean Bridge: s ⊕ t = (s+t)/(1-st)"""
    denom = 1 - s * t
    if abs(denom) < 1e-15:
        return np.inf * np.sign(s + t)
    return (s + t) / denom

def spb_from_angles(theta1, theta2):
    """SPB via tangent addition: tan(θ₁+θ₂) = spb(tan θ₁, tan θ₂)"""
    return spb(np.tan(theta1), np.tan(theta2))

# ============================================================================
# Berggren Tree Structure
# ============================================================================

def berggren_A(a, b, c):
    return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

def berggren_B(a, b, c):
    return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

def berggren_C(a, b, c):
    return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

def generate_berggren_tree(depth=4):
    """Generate primitive Pythagorean triples via Berggren tree."""
    root = (3, 4, 5)
    triples = [root]
    current_level = [root]

    for d in range(depth):
        next_level = []
        for (a, b, c) in current_level:
            for transform in [berggren_A, berggren_B, berggren_C]:
                new = transform(a, b, c)
                if new[0] > 0 and new[1] > 0:  # keep positive
                    triples.append(new)
                    next_level.append(new)
        current_level = next_level

    return triples

# ============================================================================
# Demo 1: SPB Phase Composition Pipeline
# ============================================================================

def demo_spb_phase_pipeline():
    """
    Show how SPB governs phase composition in the Lohmiller-Slotine framework.
    """
    print("=" * 60)
    print("DEMO 1: SPB Phase Composition Pipeline")
    print("=" * 60)

    # Phase angles for two action branches
    theta_range = np.linspace(-np.pi/3, np.pi/3, 100)

    fig, axes = plt.subplots(2, 2, figsize=(12, 10))
    fig.suptitle("SPB Phase Composition in Quantum Wave Construction", fontsize=14)

    # Demo: SPB combines phases like tangent addition
    theta1 = np.pi / 6  # 30°
    thetas2 = np.linspace(-np.pi/4, np.pi/4, 100)

    combined_exact = np.tan(theta1 + thetas2)
    combined_spb = [(np.tan(theta1) + np.tan(t2)) / (1 - np.tan(theta1)*np.tan(t2))
                    for t2 in thetas2]

    axes[0, 0].plot(np.degrees(thetas2), combined_exact, 'b-', linewidth=2,
                    label='tan(θ₁+θ₂)')
    axes[0, 0].plot(np.degrees(thetas2), combined_spb, 'r--', linewidth=1.5,
                    label='SPB(tan θ₁, tan θ₂)')
    axes[0, 0].set_xlabel('θ₂ (degrees)')
    axes[0, 0].set_ylabel('Combined phase')
    axes[0, 0].set_title('SPB = Tangent Addition')
    axes[0, 0].legend()

    # Wave multiplication = phase addition
    hbar = 1.0
    x = np.linspace(0, 10, 500)
    phi1 = 2.0 * x
    phi2 = 3.0 * x

    psi1 = np.exp(1j * phi1 / hbar)
    psi2 = np.exp(1j * phi2 / hbar)
    psi_product = psi1 * psi2
    psi_sum_phase = np.exp(1j * (phi1 + phi2) / hbar)

    axes[0, 1].plot(x, np.real(psi_product), 'b-', alpha=0.7, label='Re(ψ₁·ψ₂)')
    axes[0, 1].plot(x, np.real(psi_sum_phase), 'r--', alpha=0.7, label='Re(e^{i(φ₁+φ₂)/ℏ})')
    axes[0, 1].set_title('Phase Addition = Wave Multiplication')
    axes[0, 1].set_xlabel('x')
    axes[0, 1].legend()

    # Berggren tree as multipath generator
    triples = generate_berggren_tree(depth=3)
    angles = [np.arctan2(t[1], t[0]) for t in triples]

    axes[1, 0].scatter([t[0] for t in triples], [t[1] for t in triples],
                       c=angles, cmap='hsv', s=30)
    axes[1, 0].set_xlabel('a')
    axes[1, 0].set_ylabel('b')
    axes[1, 0].set_title(f'Berggren Tree ({len(triples)} triples)')
    axes[1, 0].set_aspect('equal')

    # Pythagorean triple → action phases
    phases_from_triples = []
    for a, b, c in triples[:20]:
        theta = np.arctan2(b, a)
        phases_from_triples.append(theta)

    axes[1, 1].hist(phases_from_triples, bins=20, edgecolor='black', alpha=0.7)
    axes[1, 1].set_xlabel('Phase angle arctan(b/a)')
    axes[1, 1].set_ylabel('Count')
    axes[1, 1].set_title('Phase Distribution from Pythagorean Triples')

    plt.tight_layout()
    plt.savefig('Applications/demos/spb_phase_pipeline.png', dpi=150)
    plt.close()

    print(f"  Generated {len(triples)} Pythagorean triples")
    print(f"  SPB(tan 30°, tan 15°) = {spb(np.tan(np.pi/6), np.tan(np.pi/12)):.4f}")
    print(f"  tan(45°) = {np.tan(np.pi/4):.4f} (match!)")
    print("  → Saved: Applications/demos/spb_phase_pipeline.png\n")


# ============================================================================
# Demo 2: Maslov Dequantization of Double Slit
# ============================================================================

def demo_maslov_double_slit():
    """
    Apply Maslov dequantization to the double slit:
    as ℏ→0, interference pattern → classical two-source density.
    """
    print("=" * 60)
    print("DEMO 2: Maslov Dequantization of Double Slit")
    print("=" * 60)

    y = np.linspace(-30, 30, 1000)
    screen_dist = 50.0
    slit_sep = 5.0
    p0 = 1.0

    r1 = np.sqrt(screen_dist**2 + (y - slit_sep/2)**2)
    r2 = np.sqrt(screen_dist**2 + (y + slit_sep/2)**2)

    phi1 = p0 * r1
    phi2 = p0 * r2

    rho1 = 1.0 / r1**2
    rho2 = 1.0 / r2**2

    hbar_values = [5.0, 2.0, 1.0, 0.5, 0.1]

    fig, axes = plt.subplots(1, len(hbar_values), figsize=(20, 4))
    fig.suptitle("Maslov Dequantization: Interference → Classical as ℏ → 0", fontsize=14)

    for idx, hbar in enumerate(hbar_values):
        psi = np.sqrt(rho1) * np.exp(1j * phi1 / hbar) + \
              np.sqrt(rho2) * np.exp(1j * phi2 / hbar)
        density = np.abs(psi)**2
        classical = rho1 + rho2

        axes[idx].plot(y, density / density.max(), 'b-', linewidth=1, label='|ψ|²')
        axes[idx].plot(y, classical / classical.max(), 'r--', alpha=0.5, label='classical')
        axes[idx].set_title(f'ℏ = {hbar}')
        axes[idx].set_xlabel('y')
        if idx == 0:
            axes[idx].legend(fontsize=7)

    plt.tight_layout()
    plt.savefig('Applications/demos/maslov_double_slit.png', dpi=150)
    plt.close()

    print("  As ℏ → 0: interference fringes get finer, envelope → classical")
    print("  In the tropical limit: wave selects minimum-action path")
    print("  → Saved: Applications/demos/maslov_double_slit.png\n")


# ============================================================================
# Demo 3: Full Bridge Pipeline
# ============================================================================

def demo_full_bridge():
    """
    Complete pipeline: Pythagorean → SPB → Phase → Quantum → Tropical
    """
    print("=" * 60)
    print("DEMO 3: Full Bridge Pipeline")
    print("=" * 60)

    # Step 1: Pythagorean triple (3,4,5)
    a, b, c = 3, 4, 5
    assert a**2 + b**2 == c**2

    # Step 2: SPB parameter from triple
    s = a / c  # = 3/5
    t = b / c  # = 4/5
    print(f"  Pythagorean triple: ({a}, {b}, {c})")
    print(f"  SPB parameters: s = {s}, t = {t}")

    # Step 3: Phase angle
    theta = np.arctan2(b, a)
    print(f"  Phase angle: θ = {np.degrees(theta):.2f}°")

    # Step 4: Quantum wave with this phase
    x = np.linspace(0, 20, 500)
    hbar = 1.0
    psi = np.exp(1j * theta * x / hbar)

    # Step 5: Tropical limit
    epsilon_values = [2.0, 1.0, 0.5, 0.1]

    fig = plt.figure(figsize=(16, 12))
    gs = GridSpec(3, 4, figure=fig)
    fig.suptitle("Complete Bridge: Pythagorean → SPB → Quantum → Tropical", fontsize=14)

    # Panel 1: Pythagorean triangle
    ax1 = fig.add_subplot(gs[0, :2])
    triangle_x = [0, a, 0, 0]
    triangle_y = [0, 0, b, 0]
    ax1.fill(triangle_x, triangle_y, alpha=0.2, color='blue')
    ax1.plot(triangle_x, triangle_y, 'b-', linewidth=2)
    ax1.annotate(f'a={a}', (a/2, -0.3), ha='center', fontsize=12)
    ax1.annotate(f'b={b}', (-0.3, b/2), ha='center', fontsize=12, rotation=90)
    ax1.annotate(f'c={c}', (a/2+0.3, b/2+0.3), ha='center', fontsize=12)
    ax1.set_title('Step 1: Pythagorean Triple')
    ax1.set_aspect('equal')

    # Panel 2: SPB circle
    ax2 = fig.add_subplot(gs[0, 2:])
    circle_theta = np.linspace(0, 2*np.pi, 100)
    ax2.plot(np.cos(circle_theta), np.sin(circle_theta), 'k-', alpha=0.3)
    ax2.plot([0, np.cos(theta)], [0, np.sin(theta)], 'r-', linewidth=2)
    ax2.scatter([np.cos(theta)], [np.sin(theta)], color='red', s=100, zorder=5)
    ax2.annotate(f'θ = {np.degrees(theta):.1f}°', (0.4, 0.7), fontsize=12)
    ax2.set_title('Step 2: SPB Phase')
    ax2.set_aspect('equal')

    # Panel 3: Quantum wave
    ax3 = fig.add_subplot(gs[1, :2])
    ax3.plot(x, np.real(psi), 'b-', alpha=0.7, label='Re(ψ)')
    ax3.plot(x, np.imag(psi), 'r-', alpha=0.7, label='Im(ψ)')
    ax3.set_title('Step 3: Quantum Wave')
    ax3.set_xlabel('x')
    ax3.legend()

    # Panel 4: Multi-branch wave
    ax4 = fig.add_subplot(gs[1, 2:])
    # Use Berggren children as branches
    triples = [berggren_A(a, b, c), berggren_B(a, b, c), berggren_C(a, b, c)]
    psi_total = np.zeros_like(x, dtype=complex)
    for i, (ai, bi, ci) in enumerate(triples):
        theta_i = np.arctan2(bi, ai)
        psi_i = np.exp(1j * theta_i * x)
        psi_total += psi_i
    ax4.plot(x, np.abs(psi_total)**2, 'k-', linewidth=1.5)
    ax4.set_title('Step 4: Multipath Superposition')
    ax4.set_xlabel('x')
    ax4.set_ylabel('|ψ|²')

    # Panel 5: Tropical limit
    for idx, eps in enumerate(epsilon_values):
        ax = fig.add_subplot(gs[2, idx])
        actions = [theta_i * x for (ai, bi, ci) in triples
                   for theta_i in [np.arctan2(bi, ai)]]
        tropical_min = np.minimum.reduce(actions)

        # Soft min
        soft_min = -eps * np.log(sum(np.exp(-phi / eps) for phi in actions))

        ax.plot(x, tropical_min, 'r-', linewidth=2, label='min(φ)')
        ax.plot(x, soft_min, 'b--', alpha=0.7, label='soft-min')
        ax.set_title(f'ε = {eps}')
        ax.set_xlabel('x')
        if idx == 0:
            ax.legend(fontsize=7)

    plt.tight_layout()
    plt.savefig('Applications/demos/full_bridge_pipeline.png', dpi=150)
    plt.close()

    print("  Pipeline: (3,4,5) → SPB → phase 53.13° → wave → tropical min")
    print(f"  Berggren children: {triples}")
    for ai, bi, ci in triples:
        print(f"    ({ai},{bi},{ci}): {ai}²+{bi}²={ai**2+bi**2}, {ci}²={ci**2}")
    print("  → Saved: Applications/demos/full_bridge_pipeline.png\n")


# ============================================================================
# Demo 4: Density Path Integral and EML Connection
# ============================================================================

def demo_density_eml():
    """
    Classical density ρ(t) = ρ₀·exp(-∫ΔΦ) connects to EML via log transform.
    In the tropical limit: log(ρ) → linear (tropical) density.
    """
    print("=" * 60)
    print("DEMO 4: Density Path Integral ↔ EML Bridge")
    print("=" * 60)

    t = np.linspace(0, 5, 200)

    # Different divergence profiles
    profiles = {
        'constant div': lambda t: 2 * np.ones_like(t),
        'oscillating div': lambda t: 2 + np.sin(3*t),
        'decaying div': lambda t: 2 * np.exp(-t),
    }

    fig, axes = plt.subplots(2, 3, figsize=(15, 8))
    fig.suptitle("Density Path Integral & EML Bridge", fontsize=14)

    for idx, (name, div_func) in enumerate(profiles.items()):
        div_vals = div_func(t)
        # Cumulative integral of divergence
        div_integral = np.cumsum(div_vals) * (t[1] - t[0])

        # Classical density: ρ = ρ₀ · exp(-∫div)
        rho0 = 1.0
        rho = rho0 * np.exp(-div_integral)

        # Log density (tropical): log(ρ) = log(ρ₀) - ∫div
        log_rho = np.log(rho0) - div_integral

        axes[0, idx].plot(t, rho, 'b-', linewidth=2, label='ρ(t)')
        axes[0, idx].plot(t, div_vals / 5, 'r--', alpha=0.5, label='div(v)/5')
        axes[0, idx].set_title(f'{name}')
        axes[0, idx].set_xlabel('t')
        axes[0, idx].set_ylabel('ρ')
        axes[0, idx].legend(fontsize=8)

        # Tropical (log) density is linear
        axes[1, idx].plot(t, log_rho, 'g-', linewidth=2, label='log ρ = tropical density')
        axes[1, idx].plot(t, -div_integral, 'r--', alpha=0.7, label='-∫div dt')
        axes[1, idx].set_title(f'Tropical: log(ρ)')
        axes[1, idx].set_xlabel('t')
        axes[1, idx].set_ylabel('log ρ')
        axes[1, idx].legend(fontsize=8)

    plt.tight_layout()
    plt.savefig('Applications/demos/density_eml_bridge.png', dpi=150)
    plt.close()

    print("  ρ(t) = ρ₀ · exp(-∫₀ᵗ div(v) dθ)")
    print("  log(ρ) = log(ρ₀) - ∫div (linear/tropical)")
    print("  EML connection: EML(1,x) recovers exp, EML(x,e) recovers log")
    print("  → Saved: Applications/demos/density_eml_bridge.png\n")


# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("TROPICAL-QUANTUM BRIDGE: SPB-MASLOV PIPELINE")
    print("Connecting Pythagorean, SPB, Quantum, and Tropical worlds")
    print("=" * 60 + "\n")

    demo_spb_phase_pipeline()
    demo_maslov_double_slit()
    demo_full_bridge()
    demo_density_eml()

    print("=" * 60)
    print("ALL BRIDGE DEMOS COMPLETE")
    print("=" * 60)
