#!/usr/bin/env python3
"""
Identity Fragmentation Topology (IFT) — A Scanner Darkly
=========================================================
Inspired by Philip K. Dick's A Scanner Darkly and the Scramble Suit.

This demo simulates:
1. Identity space and continuous deformations
2. Substance D fragmentation (irreversible disconnection)
3. The Scramble Suit (dense sampling of identity space)
4. Self-surveillance fixed points (winding numbers)

Run: python identity_topology.py
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Circle, FancyArrowPatch
from matplotlib.collections import LineCollection
import matplotlib.colors as mcolors


def demo_identity_space():
    """Demo 1: Identity Space as a topological manifold."""
    print("=" * 60)
    print("DEMO 1: THE IDENTITY SPACE")
    print("Identity as a topological manifold with connected components")
    print("=" * 60)

    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    # Healthy identity: connected manifold (circle with interior)
    ax = axes[0]
    theta = np.linspace(0, 2 * np.pi, 100)

    # Draw filled connected identity space
    r_outer = 1.0
    ax.fill(r_outer * np.cos(theta), r_outer * np.sin(theta),
            alpha=0.3, color='green', label='Connected Identity')
    ax.plot(r_outer * np.cos(theta), r_outer * np.sin(theta),
            'g-', linewidth=2)

    # Identity states as points
    np.random.seed(42)
    n_states = 50
    r = np.random.uniform(0, 0.9, n_states)
    t = np.random.uniform(0, 2 * np.pi, n_states)
    ax.scatter(r * np.cos(t), r * np.sin(t), c='darkgreen', s=20, zorder=5)

    # Draw some paths (continuous identity transitions)
    for _ in range(5):
        i, j = np.random.choice(n_states, 2, replace=False)
        ax.plot([r[i] * np.cos(t[i]), r[j] * np.cos(t[j])],
                [r[i] * np.sin(t[i]), r[j] * np.sin(t[j])],
                'g-', alpha=0.3, linewidth=1)

    ax.set_title('Healthy Identity\n(Connected, π₀ = 1)', fontsize=12)
    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(-1.5, 1.5)
    ax.set_aspect('equal')
    ax.legend(fontsize=9)

    # Substance D: fragmenting identity
    ax = axes[1]

    # Draw two disconnected components
    angles1 = np.linspace(0, 2 * np.pi, 50)
    center1 = (-0.6, 0.3)
    r1 = 0.5
    ax.fill(center1[0] + r1 * np.cos(angles1),
            center1[1] + r1 * np.sin(angles1),
            alpha=0.3, color='red', label='Component 1 (Cop)')
    ax.plot(center1[0] + r1 * np.cos(angles1),
            center1[1] + r1 * np.sin(angles1), 'r-', linewidth=2)

    center2 = (0.6, -0.3)
    r2 = 0.45
    ax.fill(center2[0] + r2 * np.cos(angles1),
            center2[1] + r2 * np.sin(angles1),
            alpha=0.3, color='blue', label='Component 2 (Dealer)')

    ax.plot(center2[0] + r2 * np.cos(angles1),
            center2[1] + r2 * np.sin(angles1), 'b-', linewidth=2)

    # Crack between them
    crack_y = np.linspace(-1.2, 1.2, 50)
    crack_x = 0.1 * np.sin(5 * crack_y)
    ax.plot(crack_x, crack_y, 'k-', linewidth=3, alpha=0.5, label='Substance D fracture')

    # Identity states in each component
    for center, r_comp, color in [(center1, r1, 'darkred'), (center2, r2, 'darkblue')]:
        n = 20
        r_pts = np.random.uniform(0, r_comp * 0.8, n)
        t_pts = np.random.uniform(0, 2 * np.pi, n)
        ax.scatter(center[0] + r_pts * np.cos(t_pts),
                   center[1] + r_pts * np.sin(t_pts),
                   c=color, s=20, zorder=5)

    ax.set_title('Substance D Fragmentation\n(Disconnected, π₀ = 2)', fontsize=12)
    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(-1.5, 1.5)
    ax.set_aspect('equal')
    ax.legend(fontsize=8)

    # Severe fragmentation
    ax = axes[2]
    n_fragments = 7
    centers_x = [0.8 * np.cos(2 * np.pi * k / n_fragments) for k in range(n_fragments)]
    centers_y = [0.8 * np.sin(2 * np.pi * k / n_fragments) for k in range(n_fragments)]
    radii = [0.15 + 0.1 * np.random.rand() for _ in range(n_fragments)]
    labels = ['Worker', 'Lover', 'Father', 'Addict', 'Liar', 'Dreamer', 'Ghost']
    colors = plt.cm.Set3(np.linspace(0, 1, n_fragments))

    for k in range(n_fragments):
        ax.fill(centers_x[k] + radii[k] * np.cos(angles1),
                centers_y[k] + radii[k] * np.sin(angles1),
                alpha=0.4, color=colors[k])
        ax.plot(centers_x[k] + radii[k] * np.cos(angles1),
                centers_y[k] + radii[k] * np.sin(angles1),
                color=colors[k], linewidth=1.5)
        ax.text(centers_x[k], centers_y[k], labels[k], ha='center', va='center',
                fontsize=8, fontweight='bold')

    ax.set_title(f'Severe Fragmentation\n(π₀ = {n_fragments}, irreversible)',
                 fontsize=12)
    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(-1.5, 1.5)
    ax.set_aspect('equal')

    plt.suptitle('Identity Fragmentation Topology: From Connected to Shattered',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('demo13_identity_space.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("→ Saved: demo13_identity_space.png")
    print("  Healthy: π₀(X) = 1 (connected)")
    print("  Substance D: π₀(X) = 2 (Bob Arctor = cop ∪ dealer)")
    print("  Severe: π₀(X) = 7 (complete personality dissolution)")
    print("  Theorem 5.1: Fragmentation by quotient maps is IRREVERSIBLE")
    print()


def demo_scramble_suit():
    """Demo 2: The Scramble Suit — dense sampling of identity space."""
    print("=" * 60)
    print("DEMO 2: THE SCRAMBLE SUIT")
    print("Dense equidistributed sampling of identity space (Theorem 5.3)")
    print("=" * 60)

    fig, axes = plt.subplots(2, 3, figsize=(18, 11))

    # Identity space = torus (two independent identity loops)
    # Scramble suit = irrational flow on the torus

    # Parameters for the irrational flow
    omega1 = 1.0
    omega2 = np.sqrt(2)  # Irrational ratio → dense orbit (Weyl's theorem)

    time_points = [10, 50, 200, 1000, 5000, 20000]

    for idx, T in enumerate(time_points):
        ax = axes[idx // 3][idx % 3]

        t = np.linspace(0, T, min(T * 50, 100000))
        x = (omega1 * t) % 1.0
        y = (omega2 * t) % 1.0

        # Plot on unit square (fundamental domain of torus)
        ax.scatter(x, y, c=t, cmap='twilight', s=0.5, alpha=0.3)
        ax.set_xlim(0, 1)
        ax.set_ylim(0, 1)
        ax.set_xlabel('Identity Loop 1 (e.g., gender presentation)')
        ax.set_ylabel('Identity Loop 2 (e.g., social role)')
        ax.set_title(f't = {T}\n({len(t)} samples)', fontsize=11)
        ax.set_aspect('equal')

        # Compute coverage: what fraction of 20×20 grid is visited?
        grid_size = 20
        grid = np.zeros((grid_size, grid_size), dtype=bool)
        xi = np.minimum((x * grid_size).astype(int), grid_size - 1)
        yi = np.minimum((y * grid_size).astype(int), grid_size - 1)
        grid[xi, yi] = True
        coverage = grid.sum() / grid.size

        ax.text(0.02, 0.95, f'Coverage: {coverage:.0%}',
                transform=ax.transAxes, fontsize=10,
                bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))

    plt.suptitle('THE SCRAMBLE SUIT: Irrational Flow on the Identity Torus\n'
                 'By Weyl\'s Equidistribution Theorem, the orbit becomes dense (Theorem 5.3)',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('demo14_scramble_suit.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("→ Saved: demo14_scramble_suit.png")
    print("  The Scramble Suit projects identities from an irrational flow on a torus")
    print("  By Weyl's theorem, the orbit is equidistributed → no stable identification")
    print("  As t → ∞, every possible identity is visited with equal frequency")
    print()


def demo_self_surveillance():
    """Demo 3: Self-surveillance fixed points and winding numbers."""
    print("=" * 60)
    print("DEMO 3: SELF-SURVEILLANCE FIXED POINTS")
    print("Bob Arctor investigating himself (Theorem 5.2)")
    print("=" * 60)

    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    theta = np.linspace(0, 2 * np.pi, 500)

    # Winding number 1: identity makes one full cycle
    ax = axes[0]
    # Identity cycle: Cop → Informant → Dealer → Target → Cop
    phases = ['Cop\n(Fred)', 'Informant', 'Dealer\n(Bob)', 'Target\n(Bob=Fred!)']
    phase_angles = [0, np.pi / 2, np.pi, 3 * np.pi / 2]

    ax.plot(np.cos(theta), np.sin(theta), 'b-', linewidth=2, alpha=0.5)

    # Draw the identity cycle
    for i in range(len(phases)):
        angle = phase_angles[i]
        ax.plot(np.cos(angle), np.sin(angle), 'ro', markersize=12, zorder=5)
        ax.annotate(phases[i], (1.15 * np.cos(angle), 1.15 * np.sin(angle)),
                    ha='center', va='center', fontsize=9, fontweight='bold',
                    bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow'))

        # Arrow to next phase
        next_i = (i + 1) % len(phases)
        mid_angle = (phase_angles[i] + phase_angles[next_i]) / 2
        if next_i == 0:
            mid_angle = (phase_angles[i] + phase_angles[next_i] + 2 * np.pi) / 2
        ax.annotate('', xy=(0.95 * np.cos(phase_angles[next_i]),
                            0.95 * np.sin(phase_angles[next_i])),
                    xytext=(0.95 * np.cos(phase_angles[i]),
                            0.95 * np.sin(phase_angles[i])),
                    arrowprops=dict(arrowstyle='->', color='blue', lw=2))

    # Fixed point
    ax.plot(1, 0, 'g*', markersize=20, zorder=10, label='Fixed point\n(self-recognition)')
    ax.set_title('Winding Number w = 1\n→ Fixed point EXISTS (Lefschetz)', fontsize=12)
    ax.set_xlim(-1.8, 1.8)
    ax.set_ylim(-1.8, 1.8)
    ax.set_aspect('equal')
    ax.legend(loc='lower right', fontsize=9)
    ax.text(0, 0, 'w = 1', ha='center', va='center', fontsize=16,
            fontweight='bold', color='blue')

    # Winding number 0: identity never completes the cycle
    ax = axes[1]
    ax.plot(np.cos(theta), np.sin(theta), 'gray', linewidth=1, alpha=0.3)

    # Oscillating between two phases only
    t_anim = np.linspace(0, 4 * np.pi, 200)
    x_osc = 0.8 * np.cos(t_anim / 2) * np.cos(0.3 * t_anim)
    y_osc = 0.8 * np.cos(t_anim / 2) * np.sin(0.3 * t_anim)
    ax.plot(x_osc, y_osc, 'r-', linewidth=1.5, alpha=0.5)

    ax.annotate('Cop', (0.9, 0.3), fontsize=11, fontweight='bold', color='blue')
    ax.annotate('Dealer', (-0.9, -0.3), fontsize=11, fontweight='bold', color='red')

    ax.set_title('Winding Number w = 0\n→ NO fixed point (no self-recognition)', fontsize=12)
    ax.set_xlim(-1.8, 1.8)
    ax.set_ylim(-1.8, 1.8)
    ax.set_aspect('equal')
    ax.text(0, 0, 'w = 0', ha='center', va='center', fontsize=16,
            fontweight='bold', color='red')
    ax.text(0, -1.5, 'Arctor never realizes\nhe is watching himself',
            ha='center', fontsize=10, color='darkred',
            bbox=dict(boxstyle='round', facecolor='lightyellow'))

    # The full A Scanner Darkly trajectory
    ax = axes[2]

    # Time series: identity coherence over the novel
    chapters = np.arange(1, 18)
    coherence = [0.95, 0.9, 0.85, 0.88, 0.75, 0.7, 0.6, 0.55, 0.45,
                 0.4, 0.35, 0.25, 0.2, 0.15, 0.1, 0.08, 0.05]

    ax.plot(chapters, coherence, 'b-o', linewidth=2, markersize=6)
    ax.fill_between(chapters, coherence, alpha=0.1, color='blue')

    # Mark key events
    events = {
        3: 'First scramble suit use',
        7: 'Begins surveilling self',
        11: 'Hemispheric disconnect',
        14: 'Identity collapse',
        17: '"I am... Bruce?"'
    }
    for ch, event in events.items():
        idx = ch - 1
        ax.annotate(event, (ch, coherence[idx]),
                    xytext=(ch + 0.5, coherence[idx] + 0.1),
                    fontsize=8, arrowprops=dict(arrowstyle='->', color='red'),
                    color='darkred')

    # Fragmentation threshold
    ax.axhline(y=0.3, color='red', linestyle='--', alpha=0.5,
               label='Fragmentation threshold')
    ax.set_xlabel('Chapter', fontsize=12)
    ax.set_ylabel('Identity Coherence', fontsize=12)
    ax.set_title('A Scanner Darkly: Identity Collapse\nOver the Course of the Novel',
                 fontsize=12)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0, 1.1)

    plt.suptitle('SELF-SURVEILLANCE: Winding Numbers Determine Self-Recognition',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('demo15_self_surveillance.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("→ Saved: demo15_self_surveillance.png")
    print("  Winding number w=1: fixed point exists → self-recognition possible")
    print("  Winding number w=0: no fixed point → eternal self-deception")
    print("  A Scanner Darkly trajectory: monotone collapse of coherence")
    print()


def demo_irreversibility_proof():
    """Demo 4: Visual proof of topological irreversibility."""
    print("=" * 60)
    print("DEMO 4: TOPOLOGICAL IRREVERSIBILITY")
    print("Visual proof that fragmentation cannot be continuously reversed")
    print("=" * 60)

    fig, axes = plt.subplots(1, 4, figsize=(20, 5))

    theta = np.linspace(0, 2 * np.pi, 100)

    # Step 1: Connected space X
    ax = axes[0]
    ax.fill(2 * np.cos(theta), np.sin(theta), alpha=0.3, color='green')
    ax.plot(2 * np.cos(theta), np.sin(theta), 'g-', linewidth=2)
    ax.set_title('Step 1: X is connected\n(healthy identity)', fontsize=11)
    ax.set_xlim(-3, 3)
    ax.set_ylim(-2, 2)
    ax.set_aspect('equal')
    ax.text(0, 0, 'X', fontsize=20, ha='center', va='center', fontweight='bold')

    # Step 2: Quotient map f collapses middle
    ax = axes[1]
    # Left component
    ax.fill(-1.5 + 0.8 * np.cos(theta), 0.8 * np.sin(theta),
            alpha=0.3, color='red')
    ax.plot(-1.5 + 0.8 * np.cos(theta), 0.8 * np.sin(theta), 'r-', linewidth=2)
    # Right component
    ax.fill(1.5 + 0.8 * np.cos(theta), 0.8 * np.sin(theta),
            alpha=0.3, color='blue')
    ax.plot(1.5 + 0.8 * np.cos(theta), 0.8 * np.sin(theta), 'b-', linewidth=2)

    ax.annotate('f (Substance D)', xy=(0, 1.5), fontsize=11,
                ha='center', fontweight='bold', color='darkred')
    ax.annotate('→', xy=(0, 1.2), fontsize=20, ha='center', color='darkred')

    ax.set_title('Step 2: f quotients middle\nY = f(X) is disconnected', fontsize=11)
    ax.set_xlim(-3, 3)
    ax.set_ylim(-2, 2)
    ax.set_aspect('equal')
    ax.text(-1.5, 0, 'Y₁', fontsize=16, ha='center', va='center', fontweight='bold')
    ax.text(1.5, 0, 'Y₂', fontsize=16, ha='center', va='center', fontweight='bold')

    # Step 3: Attempted reverse map g
    ax = axes[2]
    ax.fill(-1.5 + 0.8 * np.cos(theta), 0.8 * np.sin(theta),
            alpha=0.3, color='red')
    ax.fill(1.5 + 0.8 * np.cos(theta), 0.8 * np.sin(theta),
            alpha=0.3, color='blue')

    # Show g trying to map back
    ax.annotate('', xy=(0, 0.5), xytext=(-1.5, 0.5),
                arrowprops=dict(arrowstyle='->', color='purple', lw=2,
                                connectionstyle='arc3,rad=0.3'))
    ax.annotate('', xy=(0, -0.5), xytext=(1.5, -0.5),
                arrowprops=dict(arrowstyle='->', color='purple', lw=2,
                                connectionstyle='arc3,rad=-0.3'))

    ax.text(0, 0, '?', fontsize=30, ha='center', va='center',
            color='purple', fontweight='bold')

    ax.set_title('Step 3: Try to reverse with g\ng: Y → X continuous?', fontsize=11)
    ax.set_xlim(-3, 3)
    ax.set_ylim(-2, 2)
    ax.set_aspect('equal')

    # Step 4: Contradiction
    ax = axes[3]
    ax.text(0.5, 0.6, 'IMPOSSIBLE!', fontsize=18, ha='center', va='center',
            color='red', fontweight='bold',
            bbox=dict(boxstyle='round,pad=0.5', facecolor='lightyellow',
                      edgecolor='red', linewidth=3))

    proof_text = (
        "Proof (Theorem 5.1):\n\n"
        "1. X is connected\n"
        "2. Y = Y₁ ∪ Y₂ is disconnected\n"
        "3. If g: Y → X continuous with\n"
        "   f∘g = id_Y, then g(Y) is a\n"
        "   retract of X\n"
        "4. But connected spaces cannot\n"
        "   retract to disconnected ones\n"
        "5. ∴ No continuous g exists\n\n"
        "Substance D damage is\n"
        "TOPOLOGICALLY IRREVERSIBLE ∎"
    )
    ax.text(0.5, 0.05, proof_text, fontsize=10, ha='center', va='center',
            family='monospace',
            bbox=dict(boxstyle='round,pad=0.5', facecolor='lightyellow'))
    ax.set_xlim(0, 1)
    ax.set_ylim(-0.5, 1.2)
    ax.axis('off')
    ax.set_title('Step 4: Contradiction!\n(No continuous reversal)', fontsize=11)

    plt.suptitle('IRREVERSIBILITY OF IDENTITY FRAGMENTATION (Theorem 5.1)',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('demo16_irreversibility.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("→ Saved: demo16_irreversibility.png")
    print("  Connected spaces cannot retract onto disconnected subspaces")
    print("  Once Substance D fragments identity, no continuous reversal exists")
    print("  This is a TOPOLOGICAL theorem — it holds regardless of specifics")
    print()


if __name__ == '__main__':
    print()
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║  IDENTITY FRAGMENTATION TOPOLOGY — A SCANNER DARKLY        ║")
    print("║  'What does a scanner see? Into the head? Down into the    ║")
    print("║   heart? Does it see into me, into us?' — Philip K. Dick   ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    print()

    demo_identity_space()
    demo_scramble_suit()
    demo_self_surveillance()
    demo_irreversibility_proof()

    print("=" * 60)
    print("ALL IDENTITY TOPOLOGY DEMOS COMPLETE")
    print("=" * 60)
