"""
Unified Quantum-Classical-Tropical Pipeline Demo
=================================================
Cross-Direction Bridge: Demonstrates the complete Maslov dequantization pipeline
unifying all five future directions.

This demo shows:
  1. The Maslov functor: quantum amplitudes → tropical actions (with error bounds)
  2. Berggren-SPB bridge: Pythagorean gates in tangent space
  3. EML-Idempotent pipeline: density evolution → tropical measurement
  4. Unified Boltzmann-Born-Tropical phase diagram
  5. Complete pipeline: state preparation → evolution → measurement → readout
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec

# ============================================================
# Demo 1: Maslov Functor Error Bounds
# ============================================================
def demo_maslov_bounds():
    """
    Verify the formal bounds:
      hardMin - ε·log(n) ≤ softMin(ε) ≤ hardMin
    for various n and ε.
    """
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    for idx, n in enumerate([4, 16, 64]):
        np.random.seed(42 + idx)
        actions = np.sort(np.random.exponential(2.0, n))
        hard_min = np.min(actions)

        epsilons = np.logspace(-3, 2, 500)
        soft_mins = []
        upper_bounds = []
        lower_bounds = []

        for eps in epsilons:
            weights = np.exp(-actions / eps)
            sm = -eps * np.log(np.sum(weights))
            soft_mins.append(sm)
            upper_bounds.append(hard_min)
            lower_bounds.append(hard_min - eps * np.log(n))

        ax = axes[idx]
        ax.semilogx(epsilons, soft_mins, 'b-', linewidth=2, label='softMin(ε)')
        ax.semilogx(epsilons, upper_bounds, 'r--', linewidth=1.5, label='hardMin (upper)')
        ax.semilogx(epsilons, lower_bounds, 'g--', linewidth=1.5, label='hardMin - ε·log(n)')
        ax.fill_between(epsilons, lower_bounds, upper_bounds, alpha=0.1, color='yellow')
        ax.set_xlabel('ε', fontsize=12)
        ax.set_ylabel('Action', fontsize=12)
        ax.set_title(f'Maslov Bounds (n={n})', fontsize=13)
        ax.legend(fontsize=9)
        ax.grid(True, alpha=0.3)

        # Verify bounds hold
        violations = sum(1 for s, lb, ub in zip(soft_mins, lower_bounds, upper_bounds)
                        if s < lb - 1e-10 or s > ub + 1e-10)
        print(f"  n={n}: {violations} bound violations out of {len(epsilons)} tests")

    plt.suptitle('Maslov Dequantization: Formal Error Bounds (Theorem maslov_softMin_le/ge)',
                 fontsize=14, y=1.02)
    plt.tight_layout()
    plt.savefig('unified_maslov_bounds.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Demo 1: Maslov functor bounds verified and saved")


# ============================================================
# Demo 2: Berggren-SPB Bridge
# ============================================================
def generate_berggren_tree(depth):
    """Generate all primitive Pythagorean triples to given depth."""
    triples = []
    def berggren_A(a, b, c): return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)
    def berggren_B(a, b, c): return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)
    def berggren_C(a, b, c): return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

    def traverse(a, b, c, d):
        triples.append((abs(a), abs(b), c))
        if d < depth:
            for f in [berggren_A, berggren_B, berggren_C]:
                a2, b2, c2 = f(a, b, c)
                traverse(a2, b2, c2, d + 1)

    traverse(3, 4, 5, 0)
    return triples

def demo_berggren_spb_bridge():
    """
    Show how Pythagorean triples connect to SPB phases.
    Each triple (a,b,c) gives angle θ = arctan(b/a), and
    SPB composition of angles = Gaussian integer multiplication.
    """
    triples = generate_berggren_tree(6)
    angles = [np.arctan2(b, a) for a, b, c in triples]

    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Left: Pythagorean angles on unit circle with SPB connections
    ax = axes[0]
    for i, (a, b, c) in enumerate(triples[:50]):
        theta = np.arctan2(b, a)
        ax.plot(np.cos(theta), np.sin(theta), 'bo', markersize=3, alpha=0.6)

    # Show SPB composition of first two triples
    a1, b1, c1 = triples[0]  # (3,4,5)
    a2, b2, c2 = triples[1]
    # Gaussian composition
    a3 = a1*a2 - b1*b2
    b3 = a1*b2 + b1*a2
    c3 = c1*c2
    theta1 = np.arctan2(b1, a1)
    theta2 = np.arctan2(b2, a2)
    theta3 = np.arctan2(b3, a3)

    for theta, label, color in [(theta1, f'({a1},{b1},{c1})', 'red'),
                                  (theta2, f'({a2},{b2},{c2})', 'green'),
                                  (theta3, f'Composed', 'purple')]:
        ax.plot(np.cos(theta), np.sin(theta), 'o', color=color, markersize=10, zorder=5)
        ax.annotate(label, xy=(np.cos(theta), np.sin(theta)),
                   xytext=(5, 5), textcoords='offset points', fontsize=8, color=color)

    circle = plt.Circle((0, 0), 1, fill=False, color='gray', linestyle='--')
    ax.add_patch(circle)
    ax.set_xlim(-1.3, 1.3)
    ax.set_ylim(-0.1, 1.3)
    ax.set_aspect('equal')
    ax.set_title('Pythagorean Angles on Unit Circle', fontsize=13)
    ax.grid(True, alpha=0.3)

    # Middle: SPB vs angle addition verification
    ax = axes[1]
    spb_values = []
    angle_sums = []
    for i in range(min(30, len(triples))):
        for j in range(i+1, min(30, len(triples))):
            s = np.tan(angles[i])
            t = np.tan(angles[j])
            if abs(1 - s*t) > 0.01:
                spb_val = (s + t) / (1 - s * t)
                angle_sum = np.tan(angles[i] + angles[j])
                spb_values.append(spb_val)
                angle_sums.append(angle_sum)

    spb_values = np.array(spb_values)
    angle_sums = np.array(angle_sums)
    mask = np.abs(spb_values) < 100  # filter out near-poles
    ax.scatter(angle_sums[mask], spb_values[mask], s=5, alpha=0.5)
    lim = max(abs(spb_values[mask].min()), abs(spb_values[mask].max()))
    ax.plot([-lim, lim], [-lim, lim], 'r--', linewidth=2, label='y = x')
    ax.set_xlabel('tan(θ₁ + θ₂)', fontsize=12)
    ax.set_ylabel('SPB(tan θ₁, tan θ₂)', fontsize=12)
    ax.set_title('SPB = Tangent Addition (Verified)', fontsize=13)
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Right: Gaussian integer composition verification
    ax = axes[2]
    errors = []
    for i in range(min(50, len(triples))):
        for j in range(i+1, min(50, len(triples))):
            a1, b1, c1 = triples[i]
            a2, b2, c2 = triples[j]
            # Composed triple
            a3 = a1*a2 - b1*b2
            b3 = a1*b2 + b1*a2
            c3 = c1*c2
            # Check Pythagorean
            err = abs(a3**2 + b3**2 - c3**2)
            errors.append(err)

    ax.hist(errors, bins=1, color='green', edgecolor='black', alpha=0.7)
    ax.set_xlabel('|a² + b² - c²| Error', fontsize=12)
    ax.set_ylabel('Count', fontsize=12)
    ax.set_title(f'Gaussian Composition: {sum(1 for e in errors if e==0)}/{len(errors)} exact',
                 fontsize=13)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('unified_berggren_spb.png', dpi=150, bbox_inches='tight')
    plt.close()
    print(f"\n✓ Demo 2: Berggren-SPB bridge verified")
    print(f"  {len(triples)} triples generated")
    print(f"  {sum(1 for e in errors if e==0)}/{len(errors)} Gaussian compositions exact")
    if mask.sum() > 0:
        print(f"  SPB = tan addition max error: {np.max(np.abs(spb_values[mask] - angle_sums[mask])):.2e}")


# ============================================================
# Demo 3: EML-Idempotent Pipeline
# ============================================================
def demo_eml_idempotent():
    """
    Show the complete EML → Tropical pipeline:
    1. Start with log-densities
    2. Evolve via EML (subtract divergence integrals)
    3. Apply tropical measurement (select maximum density branch)
    """
    n_branches = 8
    np.random.seed(123)

    # Initial log-densities
    log_rho0 = np.random.randn(n_branches) * 0.5
    # Divergence integrals (different flow rates)
    div_integrals = np.linspace(0.1, 2.0, n_branches)

    # Time evolution
    times = np.linspace(0, 3, 200)

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    # Top-left: EML log-density evolution
    ax = axes[0, 0]
    for j in range(n_branches):
        evolved = log_rho0[j] - div_integrals[j] * times
        ax.plot(times, evolved, label=f'Branch {j}' if j < 4 else None)
    ax.set_xlabel('Time', fontsize=12)
    ax.set_ylabel('Log-density (EML)', fontsize=12)
    ax.set_title('EML Log-Density Evolution', fontsize=13)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Top-right: Actual density evolution
    ax = axes[0, 1]
    for j in range(n_branches):
        density = np.exp(log_rho0[j] - div_integrals[j] * times)
        ax.plot(times, density, label=f'Branch {j}' if j < 4 else None)
    ax.set_xlabel('Time', fontsize=12)
    ax.set_ylabel('Density ρ', fontsize=12)
    ax.set_title('Density Evolution (Exponential of EML)', fontsize=13)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Bottom-left: Tropical measurement over time
    ax = axes[1, 0]
    max_evolved = np.zeros(len(times))
    for ti, t in enumerate(times):
        evolved = log_rho0 - div_integrals * t
        max_evolved[ti] = np.max(evolved)
    ax.plot(times, max_evolved, 'r-', linewidth=2, label='max(logρ - ∫div)')

    for j in range(n_branches):
        evolved = log_rho0[j] - div_integrals[j] * times
        ax.plot(times, evolved, '--', alpha=0.3)

    ax.set_xlabel('Time', fontsize=12)
    ax.set_ylabel('Tropical Selection', fontsize=12)
    ax.set_title('Tropical Measurement: sup(evolved log-density)', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    # Bottom-right: Soft vs hard measurement
    ax = axes[1, 1]
    eps_vals = [0.01, 0.1, 0.5, 2.0]
    t_final = 1.5
    evolved_final = log_rho0 - div_integrals * t_final
    # Actions = negative log-density (for Gibbs distribution)
    actions = -evolved_final

    for eps in eps_vals:
        weights = np.exp(-actions / eps)
        probs = weights / np.sum(weights)
        ax.bar(np.arange(n_branches) + eps_vals.index(eps) * 0.15,
               probs, 0.15, label=f'ε={eps}', alpha=0.8)

    ax.set_xlabel('Branch', fontsize=12)
    ax.set_ylabel('Measurement Probability', fontsize=12)
    ax.set_title('EML→Tropical: Soft Measurement', fontsize=13)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3, axis='y')

    plt.suptitle('EML-Idempotent Pipeline: Density Evolution → Tropical Measurement',
                 fontsize=14, y=1.02)
    plt.tight_layout()
    plt.savefig('unified_eml_idempotent.png', dpi=150, bbox_inches='tight')
    plt.close()
    print(f"\n✓ Demo 3: EML-Idempotent pipeline saved")


# ============================================================
# Demo 4: Unified Phase Diagram
# ============================================================
def demo_phase_diagram():
    """
    Show the complete Boltzmann-Born-Tropical phase diagram.
    Three regimes:
      ε >> 1: Uniform (infinite temperature / full quantum coherence)
      ε ~ 1:  Classical (finite temperature / partial decoherence)
      ε << 1: Tropical (zero temperature / full decoherence)
    """
    n = 6
    np.random.seed(77)
    actions = np.sort(np.random.exponential(1.5, n))

    epsilons = np.logspace(-2, 2, 300)

    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Left: Probability distributions at different ε
    ax = axes[0]
    probs_matrix = np.zeros((len(epsilons), n))
    for i, eps in enumerate(epsilons):
        weights = np.exp(-actions / eps)
        probs_matrix[i] = weights / np.sum(weights)

    for j in range(n):
        ax.semilogx(epsilons, probs_matrix[:, j], linewidth=2,
                    label=f'S={actions[j]:.2f}')
    ax.axhline(y=1/n, color='gray', linestyle=':', alpha=0.5, label='Uniform')
    ax.set_xlabel('ε (temperature / ℏ)', fontsize=12)
    ax.set_ylabel('P(k)', fontsize=12)
    ax.set_title('Gibbs Probabilities vs Temperature', fontsize=13)
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    # Middle: Entropy vs ε
    ax = axes[1]
    entropies = []
    for probs in probs_matrix:
        probs_safe = probs[probs > 1e-30]
        H = -np.sum(probs_safe * np.log(probs_safe))
        entropies.append(H)

    ax.semilogx(epsilons, entropies, 'b-', linewidth=2)
    ax.axhline(y=np.log(n), color='red', linestyle='--', label=f'max entropy = ln({n})')
    ax.axhline(y=0, color='green', linestyle='--', label='min entropy = 0')

    # Mark three regimes
    ax.axvspan(epsilons[0], 0.1, alpha=0.1, color='blue', label='Tropical')
    ax.axvspan(0.1, 10, alpha=0.1, color='yellow', label='Classical')
    ax.axvspan(10, epsilons[-1], alpha=0.1, color='red', label='Quantum')

    ax.set_xlabel('ε', fontsize=12)
    ax.set_ylabel('Shannon Entropy H', fontsize=12)
    ax.set_title('Entropy: Quantum ↔ Classical ↔ Tropical', fontsize=13)
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    # Right: Free energy vs ε
    ax = axes[2]
    free_energies = []
    for eps in epsilons:
        Z = np.sum(np.exp(-actions / eps))
        F = -eps * np.log(Z)
        free_energies.append(F)

    ax.semilogx(epsilons, free_energies, 'b-', linewidth=2, label='F(ε) = -ε·log Z')
    ax.axhline(y=np.min(actions), color='red', linestyle='--',
               label=f'min(S) = {np.min(actions):.3f}')
    ax.axhline(y=np.mean(actions), color='green', linestyle='--',
               label=f'⟨S⟩ = {np.mean(actions):.3f}')

    # Verify bounds
    upper = np.min(actions) * np.ones_like(epsilons)
    lower = np.min(actions) - epsilons * np.log(n)
    ax.fill_between(epsilons, lower, upper, alpha=0.1, color='orange',
                    label='Formal bounds')

    ax.set_xlabel('ε', fontsize=12)
    ax.set_ylabel('Free Energy F', fontsize=12)
    ax.set_title('Free Energy = Maslov Soft Min', fontsize=13)
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    plt.suptitle('Unified Phase Diagram: Boltzmann–Born–Tropical',
                 fontsize=14, y=1.02)
    plt.tight_layout()
    plt.savefig('unified_phase_diagram.png', dpi=150, bbox_inches='tight')
    plt.close()
    print(f"\n✓ Demo 4: Unified phase diagram saved")


# ============================================================
# Demo 5: Complete Pipeline Visualization
# ============================================================
def demo_complete_pipeline():
    """
    Full pipeline:
    1. Prepare quantum state (amplitudes + phases)
    2. Evolve classically (action accumulation)
    3. Apply Maslov dequantization (soft → hard min)
    4. Read out via tropical Born rule
    """
    n = 5
    np.random.seed(99)

    # Stage 1: Quantum state preparation (amplitudes and phases)
    amplitudes = np.random.uniform(0.5, 2.0, n)
    phases = np.random.uniform(0, 2*np.pi, n)
    actions = -np.log(amplitudes)  # Maslov map: amplitude → action

    # Stage 2: Classical evolution (action grows linearly)
    t = np.linspace(0, 3, 100)
    growth_rates = np.random.uniform(0.2, 1.5, n)

    fig = plt.figure(figsize=(20, 12))
    gs = GridSpec(2, 3, figure=fig, hspace=0.35, wspace=0.3)

    # Panel 1: Quantum amplitudes
    ax = fig.add_subplot(gs[0, 0])
    colors = plt.cm.Set2(np.linspace(0, 1, n))
    ax.bar(range(n), amplitudes, color=colors, edgecolor='black')
    ax.set_xlabel('State', fontsize=12)
    ax.set_ylabel('Amplitude |ψₖ|', fontsize=12)
    ax.set_title('① Quantum State Preparation', fontsize=13)
    ax.grid(True, alpha=0.3, axis='y')

    # Panel 2: Action evolution
    ax = fig.add_subplot(gs[0, 1])
    for j in range(n):
        evolved = actions[j] + growth_rates[j] * t
        ax.plot(t, evolved, color=colors[j], linewidth=2, label=f'State {j}')
    ax.set_xlabel('Time', fontsize=12)
    ax.set_ylabel('Action S(t)', fontsize=12)
    ax.set_title('② Classical Action Evolution', fontsize=13)
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    # Panel 3: Maslov dequantization at t=2
    ax = fig.add_subplot(gs[0, 2])
    t_measure = 2.0
    evolved_actions = actions + growth_rates * t_measure
    eps_range = np.logspace(-2, 1, 200)
    soft_mins = [-eps * np.log(np.sum(np.exp(-evolved_actions / eps)))
                  for eps in eps_range]
    ax.semilogx(eps_range, soft_mins, 'b-', linewidth=2, label='softMin(ε)')
    ax.axhline(y=np.min(evolved_actions), color='r', linestyle='--',
               label=f'hardMin = {np.min(evolved_actions):.3f}')
    ax.set_xlabel('ε (dequantization)', fontsize=12)
    ax.set_ylabel('Maslov Map Output', fontsize=12)
    ax.set_title('③ Maslov Dequantization', fontsize=13)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Panel 4: Tropical Born rule at different ε
    ax = fig.add_subplot(gs[1, 0])
    for eps in [0.01, 0.1, 1.0, 5.0]:
        weights = np.exp(-evolved_actions / eps)
        probs = weights / np.sum(weights)
        x_offset = [0.01, 0.1, 1.0, 5.0].index(eps) * 0.15
        ax.bar(np.arange(n) + x_offset, probs, 0.15, label=f'ε={eps}', alpha=0.8)
    ax.set_xlabel('State', fontsize=12)
    ax.set_ylabel('Probability', fontsize=12)
    ax.set_title('④ Tropical Born Rule', fontsize=13)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3, axis='y')

    # Panel 5: Pipeline output over time
    ax = fig.add_subplot(gs[1, 1])
    for eps in [0.01, 0.5, 2.0]:
        outcomes = []
        for ti in t:
            ea = actions + growth_rates * ti
            weights = np.exp(-ea / eps)
            probs = weights / np.sum(weights)
            outcome = np.argmax(probs)
            outcomes.append(outcome)
        ax.plot(t, outcomes, linewidth=2, label=f'ε={eps}')
    ax.set_xlabel('Time', fontsize=12)
    ax.set_ylabel('Selected State', fontsize=12)
    ax.set_title('⑤ Pipeline: Winning State Over Time', fontsize=13)
    ax.legend(fontsize=10)
    ax.set_yticks(range(n))
    ax.grid(True, alpha=0.3)

    # Panel 6: Summary metrics
    ax = fig.add_subplot(gs[1, 2])
    eps_summary = np.logspace(-2, 1, 100)
    max_probs = []
    entropies_summary = []
    for eps in eps_summary:
        weights = np.exp(-evolved_actions / eps)
        probs = weights / np.sum(weights)
        max_probs.append(np.max(probs))
        safe_p = probs[probs > 1e-30]
        entropies_summary.append(-np.sum(safe_p * np.log(safe_p)))

    ax2 = ax.twinx()
    l1, = ax.semilogx(eps_summary, max_probs, 'b-', linewidth=2, label='max P(k)')
    l2, = ax2.semilogx(eps_summary, entropies_summary, 'r-', linewidth=2, label='Entropy')
    ax.set_xlabel('ε', fontsize=12)
    ax.set_ylabel('Max Probability', fontsize=12, color='b')
    ax2.set_ylabel('Entropy', fontsize=12, color='r')
    ax.set_title('⑥ Decoherence Metrics', fontsize=13)
    ax.legend(handles=[l1, l2], fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.suptitle('Complete Maslov Pipeline: Quantum → Classical → Tropical → Measurement',
                 fontsize=15, y=1.01)
    plt.savefig('unified_complete_pipeline.png', dpi=150, bbox_inches='tight')
    plt.close()
    print(f"\n✓ Demo 5: Complete pipeline visualization saved")


if __name__ == '__main__':
    print("=" * 65)
    print("Unified Quantum-Classical-Tropical Pipeline")
    print("Cross-Direction Bridge Demonstrations")
    print("=" * 65)

    demo_maslov_bounds()
    demo_berggren_spb_bridge()
    demo_eml_idempotent()
    demo_phase_diagram()
    demo_complete_pipeline()

    print("\n" + "=" * 65)
    print("All unified pipeline demos complete! Generated 5 PNG files.")
    print("=" * 65)
