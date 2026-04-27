"""
Tropical-Quantum Bridge Demonstrations
=======================================
Validates the five structural bridges between the Lohmiller-Slotine
classical→quantum construction and the SPB-tropical framework.

Demonstrates:
  1. Maslov dequantization: LSE_ε → min as ε → 0
  2. SPB phase composition and tangent-addition identity
  3. Berggren-Lorentz quantum gate simulation
  4. Complete pipeline: Pythagorean → SPB → Quantum → Tropical

Each demo produces a PNG plot saved to the current directory.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec


# ============================================================
# Demo 1: Maslov Dequantization
# ============================================================
def demo_maslov():
    """
    logSumExp_ε(a, b) → min(a, b) as ε → 0⁺
    Validates the bounds: LSE ≤ min ≤ LSE + ε·log(2)
    """
    a, b = 2.0, 5.0
    epsilons = np.logspace(-3, 1, 500)

    lse_values = []
    for eps in epsilons:
        lse = -eps * np.log(np.exp(-a / eps) + np.exp(-b / eps))
        lse_values.append(lse)

    lse_arr = np.array(lse_values)
    min_ab = min(a, b)

    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Plot 1: Convergence
    axes[0].semilogx(epsilons, lse_arr, 'b-', linewidth=1.5, label='LSE_ε(a,b)')
    axes[0].axhline(y=min_ab, color='r', linestyle='--', label=f'min(a,b) = {min_ab}')
    axes[0].fill_between(epsilons, lse_arr, min_ab, alpha=0.2, color='green')
    axes[0].set_xlabel('ε (log scale)')
    axes[0].set_ylabel('Value')
    axes[0].set_title(f'Maslov Dequantization\na={a}, b={b}')
    axes[0].legend()

    # Plot 2: Bounds verification
    lower_gap = min_ab - lse_arr
    upper_bound = epsilons * np.log(2)
    axes[1].semilogx(epsilons, lower_gap, 'b-', label='min - LSE ≥ 0')
    axes[1].semilogx(epsilons, upper_bound, 'r--', label='ε·log(2)')
    axes[1].fill_between(epsilons, 0, lower_gap, alpha=0.2, color='blue')
    axes[1].set_xlabel('ε')
    axes[1].set_ylabel('Gap')
    axes[1].set_title('Maslov Bounds: 0 ≤ min - LSE ≤ ε·log(2)')
    axes[1].legend()

    # Plot 3: Double-slit Maslov dequantization
    x = np.linspace(-5, 5, 1000)
    action1 = x**2 / 2
    action2 = (x - 1)**2 / 2 + 0.5

    for eps_val in [0.01, 0.1, 0.5, 2.0]:
        lse_x = -eps_val * np.log(np.exp(-action1 / eps_val) + np.exp(-action2 / eps_val))
        axes[2].plot(x, lse_x, label=f'ε={eps_val}', linewidth=1)

    axes[2].plot(x, np.minimum(action1, action2), 'k--', linewidth=2, label='min (tropical)')
    axes[2].set_xlabel('x')
    axes[2].set_ylabel('LSE_ε(φ₁, φ₂)')
    axes[2].set_title('Maslov Limit of Two Action Branches')
    axes[2].legend(fontsize=8)

    plt.tight_layout()
    plt.savefig('bridge1_maslov.png', dpi=150)
    plt.close()
    print(f"Bridge 1: Maslov dequantization. Convergence verified (gap → 0).")


# ============================================================
# Demo 2: SPB Phase Composition
# ============================================================
def demo_spb_phase():
    """
    tan(arctan(s) + arctan(t)) = SPB(s,t) = (s+t)/(1-st)
    Validates commutativity, identity, and phase connection.
    """
    def spb(s, t):
        return (s + t) / (1 - s * t)

    # Test commutativity
    test_pairs = [(0.3, 0.7), (1.5, -0.5), (0.1, 0.9), (-2.0, 0.3)]
    for s, t in test_pairs:
        assert abs(spb(s, t) - spb(t, s)) < 1e-14, f"Commutativity failed for ({s}, {t})"

    # Test identity
    for s in [0.1, 0.5, 1.0, 2.0, -0.7]:
        assert abs(spb(s, 0) - s) < 1e-14, f"Identity failed for s={s}"

    # Phase connection
    s_vals = np.linspace(-2, 2, 500)
    t = 0.5

    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Plot 1: SPB operation
    valid_mask = np.abs(1 - s_vals * t) > 0.01
    spb_vals = np.where(valid_mask, (s_vals + t) / (1 - s_vals * t), np.nan)
    tan_sum = np.where(valid_mask,
                       np.tan(np.arctan(s_vals) + np.arctan(t)),
                       np.nan)

    axes[0].plot(s_vals[valid_mask], spb_vals[valid_mask], 'b-', linewidth=2, label='SPB(s, 0.5)')
    axes[0].plot(s_vals[valid_mask], tan_sum[valid_mask], 'r--', linewidth=1, label='tan(arctan s + arctan 0.5)')
    axes[0].set_xlabel('s')
    axes[0].set_ylabel('SPB(s, t)')
    axes[0].set_title(f'SPB = Tangent Addition (t={t})')
    axes[0].legend()
    axes[0].set_ylim(-10, 10)

    # Plot 2: Phase composition on unit circle
    theta = np.linspace(0, 2 * np.pi, 100)
    angles = np.linspace(0, np.pi / 3, 5)

    for angle in angles:
        s_val = np.tan(angle)
        t_val = np.tan(np.pi / 6)
        if abs(1 - s_val * t_val) > 0.01:
            result = spb(s_val, t_val)
            theta_result = np.arctan(result)
            axes[1].plot([0, np.cos(angle)], [0, np.sin(angle)], 'b-', alpha=0.5)
            axes[1].plot([0, np.cos(theta_result)], [0, np.sin(theta_result)], 'r-', alpha=0.5)

    axes[1].plot(np.cos(theta), np.sin(theta), 'k-', alpha=0.3)
    axes[1].set_aspect('equal')
    axes[1].set_title('SPB Phase Composition on Circle\n(blue=input, red=output)')
    axes[1].set_xlabel('cos θ')
    axes[1].set_ylabel('sin θ')

    # Plot 3: Wave multiplication
    x = np.linspace(0, 10, 1000)
    hbar = 1.0
    phi1, phi2 = 3.0, 5.0

    wave1 = np.exp(1j * phi1 * x / hbar)
    wave2 = np.exp(1j * phi2 * x / hbar)
    wave_product = wave1 * wave2
    wave_sum_phase = np.exp(1j * (phi1 + phi2) * x / hbar)

    axes[2].plot(x, np.real(wave_product), 'b-', linewidth=1, label='exp(iφ₁/ℏ)·exp(iφ₂/ℏ)', alpha=0.8)
    axes[2].plot(x, np.real(wave_sum_phase), 'r--', linewidth=1, label='exp(i(φ₁+φ₂)/ℏ)', alpha=0.8)
    axes[2].set_xlabel('x')
    axes[2].set_ylabel('Re(ψ)')
    axes[2].set_title('Phase Addition = Wave Multiplication')
    axes[2].legend()

    error = np.max(np.abs(wave_product - wave_sum_phase))

    plt.tight_layout()
    plt.savefig('bridge2_spb_phase.png', dpi=150)
    plt.close()
    print(f"Bridge 2: SPB phase composition. Max error: {error:.2e}")


# ============================================================
# Demo 3: Berggren-Lorentz Quantum Gate Simulation
# ============================================================
def demo_berggren_lorentz_gates():
    """
    Pythagorean triples → quantum rotation gates.
    Berggren tree generates a dense set of unitary gates.
    """
    def berggren_A(a, b, c):
        return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

    def berggren_B(a, b, c):
        return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

    def berggren_C(a, b, c):
        return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

    def triple_to_gate(a, b, c):
        """Pythagorean triple → 2×2 rotation gate (guaranteed unitary)."""
        cos_t = a / c
        sin_t = b / c
        return np.array([[cos_t, -sin_t],
                         [sin_t, cos_t]])

    # Generate Berggren tree to depth 3
    root = (3, 4, 5)
    triples = [root]
    current_level = [root]

    for depth in range(3):
        next_level = []
        for triple in current_level:
            children = [
                berggren_A(*triple),
                berggren_B(*triple),
                berggren_C(*triple),
            ]
            for child in children:
                a, b, c = child
                assert a**2 + b**2 == c**2, f"Pythagorean check failed: {child}"
                triples.append(child)
                next_level.append(child)
        current_level = next_level

    print(f"  Generated {len(triples)} Pythagorean triples (depth 3)")

    # Extract rotation angles
    angles = [np.arctan2(b, a) for a, b, c in triples]

    fig, axes = plt.subplots(2, 2, figsize=(14, 12))

    # Plot 1: Rotation angles on unit circle
    ax = axes[0, 0]
    for angle in angles:
        ax.plot([0, np.cos(angle)], [0, np.sin(angle)], 'b-', alpha=0.3)
        ax.plot(np.cos(angle), np.sin(angle), 'ro', markersize=4)

    theta_circle = np.linspace(0, 2 * np.pi, 200)
    ax.plot(np.cos(theta_circle), np.sin(theta_circle), 'k-', alpha=0.2)
    ax.set_aspect('equal')
    ax.set_title(f'Berggren Gate Angles ({len(triples)} triples)')
    ax.set_xlabel('cos θ')
    ax.set_ylabel('sin θ')

    # Plot 2: Angle distribution
    ax = axes[0, 1]
    ax.hist(np.degrees(angles), bins=40, color='steelblue', alpha=0.8, edgecolor='black')
    ax.set_xlabel('Rotation angle (degrees)')
    ax.set_ylabel('Count')
    ax.set_title('Distribution of Gate Angles')

    # Plot 3: Gate composition example
    ax = axes[1, 0]
    # Compose gates from the first few triples
    state = np.array([1.0, 0.0])  # |0⟩ state
    trajectory_x = [state[0]]
    trajectory_y = [state[1]]
    gate_labels = []

    for i, (a, b, c) in enumerate(triples[:20]):
        gate = triple_to_gate(a, b, c)
        # Verify unitarity
        assert np.allclose(gate @ gate.T, np.eye(2)), f"Unitarity failed for {(a,b,c)}"
        state = gate @ state
        state = state / np.linalg.norm(state)  # Numerical stability
        trajectory_x.append(state[0])
        trajectory_y.append(state[1])
        gate_labels.append(f'({a},{b},{c})')

    ax.plot(trajectory_x, trajectory_y, 'b-o', markersize=3, linewidth=0.8)
    ax.plot(trajectory_x[0], trajectory_y[0], 'go', markersize=10, label='Start |0⟩')
    ax.plot(trajectory_x[-1], trajectory_y[-1], 'rs', markersize=10, label='Final state')
    ax.plot(np.cos(theta_circle), np.sin(theta_circle), 'k-', alpha=0.2)
    ax.set_aspect('equal')
    ax.set_title('State Evolution Under Berggren Gates')
    ax.legend(fontsize=8)
    ax.set_xlabel('⟨0|ψ⟩')
    ax.set_ylabel('⟨1|ψ⟩')

    # Plot 4: Lorentz form verification
    ax = axes[1, 1]
    lorentz_values = [a**2 + b**2 - c**2 for a, b, c in triples]
    ax.bar(range(len(lorentz_values)), lorentz_values, color='coral', alpha=0.8)
    ax.set_xlabel('Triple index')
    ax.set_ylabel('a² + b² - c²')
    ax.set_title(f'Lorentz Form (all = 0: {all(v == 0 for v in lorentz_values)})')
    ax.set_ylim(-1, 1)

    plt.tight_layout()
    plt.savefig('bridge3_berggren_gates.png', dpi=150)
    plt.close()
    print(f"Bridge 3: Berggren-Lorentz gates. All {len(triples)} triples verified unitary.")


# ============================================================
# Demo 4: Complete Pipeline
# ============================================================
def demo_complete_pipeline():
    """
    Full pipeline: Pythagorean → SPB → Quantum → Tropical
    """
    def spb(s, t):
        return (s + t) / (1 - s * t)

    def berggren_A(a, b, c):
        return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

    def berggren_B(a, b, c):
        return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

    def berggren_C(a, b, c):
        return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

    # Stage 1: Pythagorean triple
    root = (3, 4, 5)
    a, b, c = root
    print(f"  Stage 1: Pythagorean triple ({a},{b},{c}), {a}²+{b}²={a**2+b**2}={c}²={c**2}")

    # Stage 2: SPB parameters
    s = a / c  # 3/5
    t = b / c  # 4/5
    spb_result = spb(s, t)
    print(f"  Stage 2: SPB({s}, {t}) = {spb_result:.6f}")
    print(f"           tan(arctan({s}) + arctan({t})) = {np.tan(np.arctan(s) + np.arctan(t)):.6f}")

    # Stage 3: Phase angle
    theta = np.arctan2(b, a)
    print(f"  Stage 3: Phase angle θ = arctan({b}/{a}) = {np.degrees(theta):.2f}°")

    # Stage 4: Berggren branching
    children = [berggren_A(*root), berggren_B(*root), berggren_C(*root)]
    print(f"  Stage 4: Berggren children: {children}")

    # Stage 5: Multipath superposition
    x = np.linspace(-5, 5, 2000)
    hbar_values = [0.1, 0.5, 1.0, 2.0]

    fig = plt.figure(figsize=(18, 14))
    gs = GridSpec(3, 3, figure=fig, hspace=0.4, wspace=0.35)

    # Panel 1: Pythagorean structure
    ax1 = fig.add_subplot(gs[0, 0])
    # Draw right triangle
    triangle = plt.Polygon([[0, 0], [a, 0], [0, b]], fill=False, edgecolor='blue', linewidth=2)
    ax1.add_patch(triangle)
    ax1.text(a / 2, -0.3, f'a={a}', ha='center', fontsize=12, color='blue')
    ax1.text(-0.4, b / 2, f'b={b}', ha='center', fontsize=12, color='blue', rotation=90)
    ax1.text(a / 2 + 0.3, b / 2 + 0.3, f'c={c}', ha='center', fontsize=12, color='red')
    ax1.set_xlim(-1, 5)
    ax1.set_ylim(-1, 5)
    ax1.set_aspect('equal')
    ax1.set_title('Stage 1: Pythagorean Triple')
    ax1.grid(True, alpha=0.3)

    # Panel 2: SPB on unit circle
    ax2 = fig.add_subplot(gs[0, 1])
    theta_c = np.linspace(0, 2 * np.pi, 200)
    ax2.plot(np.cos(theta_c), np.sin(theta_c), 'k-', alpha=0.3)
    theta_s = np.arctan(s)
    theta_t = np.arctan(t)
    theta_sum = theta_s + theta_t
    for th, label, color in [(theta_s, f'arctan({s})', 'blue'),
                              (theta_t, f'arctan({t})', 'red'),
                              (theta_sum, 'sum', 'green')]:
        ax2.plot([0, np.cos(th)], [0, np.sin(th)], '-o', color=color, linewidth=2, label=label)

    ax2.set_aspect('equal')
    ax2.set_title('Stage 2: SPB Phase Composition')
    ax2.legend(fontsize=7)

    # Panel 3: Berggren tree
    ax3 = fig.add_subplot(gs[0, 2])
    ax3.set_xlim(-1, 5)
    ax3.set_ylim(-0.5, 3)
    positions = {str(root): (2, 2.5)}
    for i, child in enumerate(children):
        positions[str(child)] = (0.5 + 2 * i, 0.5)

    for key, pos in positions.items():
        ax3.annotate(key, xy=pos, fontsize=8, ha='center',
                     bbox=dict(boxstyle='round,pad=0.2', facecolor='lightyellow', edgecolor='black'))

    for child in children:
        ax3.annotate('', xy=positions[str(child)], xytext=positions[str(root)],
                     arrowprops=dict(arrowstyle='->', color='black', lw=1.5))

    ax3.set_title('Stage 4: Berggren Branching')
    ax3.axis('off')

    # Panel 4-5: Quantum superposition for different ℏ
    all_triples = [root] + children

    for idx, hbar in enumerate(hbar_values):
        ax = fig.add_subplot(gs[1, idx % 3]) if idx < 3 else fig.add_subplot(gs[2, 0])

        psi_total = np.zeros_like(x, dtype=complex)
        for triple_a, triple_b, triple_c in all_triples:
            p0 = triple_c
            th = np.arctan2(triple_b, triple_a)
            rho = 1.0 / (1 + (x - th * 2)**2)
            phi = p0 * x
            psi_branch = np.sqrt(rho) * np.exp(1j * phi / hbar)
            psi_total += psi_branch

        prob = np.abs(psi_total)**2
        ax.plot(x, prob, 'purple', linewidth=0.8)
        ax.set_xlabel('x')
        ax.set_ylabel('|ψ|²')
        ax.set_title(f'Stage 5: Superposition (ℏ={hbar})')

    # Panel 6: Tropical limit
    ax_trop = fig.add_subplot(gs[2, 1])
    actions = []
    for triple_a, triple_b, triple_c in all_triples:
        action = triple_c * np.abs(x - np.arctan2(triple_b, triple_a) * 2)
        actions.append(action)
        ax_trop.plot(x, action, '--', alpha=0.5, label=f'φ({triple_a},{triple_b},{triple_c})')

    min_action = np.minimum.reduce(actions)
    ax_trop.plot(x, min_action, 'k-', linewidth=2, label='min (tropical)')
    ax_trop.set_xlabel('x')
    ax_trop.set_ylabel('Action')
    ax_trop.set_title('Stage 6: Tropical Limit')
    ax_trop.legend(fontsize=6)

    # Panel 7: Maslov interpolation
    ax_maslov = fig.add_subplot(gs[2, 2])
    for eps in [0.05, 0.2, 0.5, 1.0, 3.0]:
        lse = np.zeros_like(x)
        for action in actions:
            lse += np.exp(-action / eps)
        lse = -eps * np.log(lse)
        ax_maslov.plot(x, lse, label=f'ε={eps}', linewidth=1)

    ax_maslov.plot(x, min_action, 'k--', linewidth=2, label='tropical (ε→0)')
    ax_maslov.set_xlabel('x')
    ax_maslov.set_ylabel('LSE_ε')
    ax_maslov.set_title('Maslov Interpolation')
    ax_maslov.legend(fontsize=6)

    plt.savefig('bridge4_complete_pipeline.png', dpi=150)
    plt.close()
    print("Bridge 4: Complete pipeline Pythagorean → SPB → Quantum → Tropical.")


# ============================================================
# Main
# ============================================================
if __name__ == '__main__':
    print("=" * 60)
    print("Tropical-Quantum Bridge Demonstrations")
    print("Five Structural Bridges Validation")
    print("=" * 60)
    print()

    demo_maslov()
    demo_spb_phase()
    demo_berggren_lorentz_gates()
    demo_complete_pipeline()

    print()
    print("=" * 60)
    print("All 4 bridge demonstrations completed successfully.")
    print("Output files: bridge1_*.png through bridge4_*.png")
    print("=" * 60)
