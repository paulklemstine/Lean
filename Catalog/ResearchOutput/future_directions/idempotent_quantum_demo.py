"""
Idempotent Quantum Computing Demo
===================================
Future Direction 6.5: Wave collapse as tropical projection.

Quantum measurement projects the wave function onto an eigenstate.
In the tropical limit (ε → 0), this becomes idempotent:
  measure(measure(ψ)) = measure(ψ)

This connects quantum decoherence to idempotent analysis in
tropical mathematics.

This demo shows:
  1. Idempotent semiring operations (min-plus algebra)
  2. Measurement as tropical projection
  3. Decoherence as the ε → 0 limit
  4. Tropical quantum gates
  5. Born rule → deterministic selection
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


# Tropical operations
def trop_add(a, b):
    """Tropical addition = minimum."""
    return min(a, b)

def trop_mul(a, b):
    """Tropical multiplication = ordinary addition."""
    return a + b


# ============================================================
# Demo 1: Tropical Semiring and Idempotency
# ============================================================
def demo_idempotent_semiring():
    """
    Visualize the tropical semiring structure:
    - ⊕ = min (idempotent: a ⊕ a = a)
    - ⊗ = + (associative, commutative)
    - ⊗ distributes over ⊕
    """
    vals = np.linspace(-3, 3, 100)

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    # Tropical addition (min)
    A, B = np.meshgrid(vals, vals)
    Z_add = np.minimum(A, B)
    im1 = axes[0, 0].contourf(A, B, Z_add, levels=30, cmap='viridis')
    plt.colorbar(im1, ax=axes[0, 0])
    axes[0, 0].set_xlabel('a', fontsize=12)
    axes[0, 0].set_ylabel('b', fontsize=12)
    axes[0, 0].set_title('Tropical Addition: a ⊕ b = min(a,b)', fontsize=13)
    # Show idempotency line
    axes[0, 0].plot(vals, vals, 'r--', linewidth=2, label='a = b (idempotent)')
    axes[0, 0].legend(fontsize=10)

    # Idempotency verification
    test_vals = np.random.uniform(-5, 5, 1000)
    idem_errors = [abs(min(v, v) - v) for v in test_vals]
    axes[0, 1].hist(idem_errors, bins=50, color='green', edgecolor='black')
    axes[0, 1].set_xlabel('|a ⊕ a - a|', fontsize=12)
    axes[0, 1].set_ylabel('Count', fontsize=12)
    axes[0, 1].set_title(f'Idempotency: a ⊕ a = a (max err: {max(idem_errors):.2e})',
                          fontsize=13)
    axes[0, 1].grid(True, alpha=0.3)

    # Distributivity: a ⊗ (b ⊕ c) = (a ⊗ b) ⊕ (a ⊗ c)
    np.random.seed(42)
    n_test = 500
    dist_errors = []
    for _ in range(n_test):
        a, b, c = np.random.uniform(-5, 5, 3)
        lhs = trop_mul(a, trop_add(b, c))
        rhs = trop_add(trop_mul(a, b), trop_mul(a, c))
        dist_errors.append(abs(lhs - rhs))

    axes[1, 0].hist(dist_errors, bins=50, color='orange', edgecolor='black')
    axes[1, 0].set_xlabel('|a⊗(b⊕c) - (a⊗b)⊕(a⊗c)|', fontsize=12)
    axes[1, 0].set_ylabel('Count', fontsize=12)
    axes[1, 0].set_title(f'Distributivity (max err: {max(dist_errors):.2e})', fontsize=13)
    axes[1, 0].grid(True, alpha=0.3)

    # Soft-min transition to hard-min (idempotent limit)
    a_val, b_val = 2.0, 3.0
    epsilons = np.logspace(-2, 1, 200)
    soft_mins = [-eps * np.log(np.exp(-a_val/eps) + np.exp(-b_val/eps))
                 for eps in epsilons]

    axes[1, 1].semilogx(epsilons, soft_mins, 'b-', linewidth=2)
    axes[1, 1].axhline(y=min(a_val, b_val), color='r', linestyle='--',
                        linewidth=2, label=f'min({a_val},{b_val}) = {min(a_val,b_val)}')
    axes[1, 1].set_xlabel('ε', fontsize=12)
    axes[1, 1].set_ylabel('soft-min(a,b)', fontsize=12)
    axes[1, 1].set_title('Dequantization: soft-min → min', fontsize=13)
    axes[1, 1].legend(fontsize=11)
    axes[1, 1].grid(True, alpha=0.3)

    plt.suptitle('Tropical Idempotent Semiring', fontsize=14, y=1.02)
    plt.tight_layout()
    plt.savefig('idempotent_semiring.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Demo 1: Idempotent semiring properties saved")


# ============================================================
# Demo 2: Measurement as Tropical Projection
# ============================================================
def demo_tropical_measurement():
    """
    Quantum measurement → tropical projection.
    In the ε → 0 limit, measurement selects the minimum-action state.
    Repeated measurement is idempotent.
    """
    n_states = 5
    actions = np.array([3.0, 1.5, 4.0, 0.8, 2.5])

    epsilons = np.logspace(-2, 1, 200)

    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Probability distribution at different ε
    for k in range(n_states):
        probs = []
        for eps in epsilons:
            weights = np.exp(-actions / eps)
            probs.append(weights[k] / np.sum(weights))
        axes[0].semilogx(epsilons, probs, linewidth=2,
                          label=f'State {k} (S={actions[k]})')

    axes[0].set_xlabel('ε (coherence)', fontsize=12)
    axes[0].set_ylabel('P(k)', fontsize=12)
    axes[0].set_title('Measurement: Quantum → Deterministic', fontsize=13)
    axes[0].legend(fontsize=9)
    axes[0].grid(True, alpha=0.3)

    # Idempotency of measurement
    # First measurement gives probabilities p_k
    # Second measurement on the post-measurement state should give same result
    eps_test = [0.1, 0.5, 1.0, 5.0]
    x = np.arange(n_states)
    width = 0.2

    for i, eps in enumerate(eps_test):
        # First measurement
        weights = np.exp(-actions / eps)
        p1 = weights / np.sum(weights)

        # "Second measurement" on the post-measurement density
        # Post-measurement actions are -eps * log(p_k)
        post_actions = -eps * np.log(p1 + 1e-30)
        weights2 = np.exp(-post_actions / eps)
        p2 = weights2 / np.sum(weights2)

        axes[1].bar(x + i * width, np.abs(p1 - p2), width,
                     label=f'ε={eps}', alpha=0.8)

    axes[1].set_xlabel('State k', fontsize=12)
    axes[1].set_ylabel('|P₁ - P₂|', fontsize=12)
    axes[1].set_title('Measurement Idempotency: |P¹ - P²|', fontsize=13)
    axes[1].set_xticks(x + 1.5 * width)
    axes[1].set_xticklabels([f'S={a}' for a in actions])
    axes[1].legend(fontsize=10)
    axes[1].grid(True, alpha=0.3, axis='y')

    # Entropy of measurement outcome
    entropies = []
    for eps in epsilons:
        weights = np.exp(-actions / eps)
        probs = weights / np.sum(weights)
        entropy = -np.sum(probs * np.log(probs + 1e-30))
        entropies.append(entropy)

    axes[2].semilogx(epsilons, entropies, 'b-', linewidth=2)
    axes[2].axhline(y=0, color='r', linestyle='--', label='Pure state (S=0)')
    axes[2].axhline(y=np.log(n_states), color='g', linestyle='--',
                     label=f'Max mixed (S=ln{n_states})')
    axes[2].set_xlabel('ε (coherence)', fontsize=12)
    axes[2].set_ylabel('von Neumann Entropy', fontsize=12)
    axes[2].set_title('Decoherence → Pure State', fontsize=13)
    axes[2].legend(fontsize=11)
    axes[2].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('idempotent_measurement.png', dpi=150, bbox_inches='tight')
    plt.close()
    print(f"\n✓ Demo 2: Tropical measurement saved")


# ============================================================
# Demo 3: Tropical Quantum Gates
# ============================================================
def demo_tropical_gates():
    """
    Tropical quantum gates: min-plus linear maps.
    (Tv)_i = min_j(T_ij + v_j)

    Demonstrate identity, NOT, and composed gates.
    """
    # Tropical identity gate
    INF = 100  # Represents +∞
    I_gate = np.array([[0, INF], [INF, 0]])

    # Tropical NOT gate
    NOT_gate = np.array([[INF, 0], [0, INF]])

    # Tropical Hadamard-like gate
    H_gate = np.array([[0, 0], [0, 0]])  # Equal superposition in tropical

    def apply_trop_gate(gate, v):
        """Apply tropical gate: (Gv)_i = min_j(G_ij + v_j)"""
        result = np.zeros(len(v))
        for i in range(len(v)):
            result[i] = min(gate[i, j] + v[j] for j in range(len(v)))
        return result

    # Test states
    states = {
        '|0⟩': np.array([0.0, INF]),
        '|1⟩': np.array([INF, 0.0]),
        'Equal': np.array([0.0, 0.0]),
        'Biased': np.array([1.0, 3.0]),
    }

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    # Apply gates to different states
    gate_names = ['Identity', 'NOT', 'Hadamard', 'NOT∘NOT']
    gates = [I_gate, NOT_gate, H_gate, NOT_gate]

    for idx, (gate_name, gate) in enumerate(zip(gate_names, gates)):
        ax = axes[idx // 2][idx % 2]

        x = np.arange(len(states))
        width = 0.35

        input_vals = []
        output_vals = []
        state_labels = []

        for name, state in states.items():
            if gate_name == 'NOT∘NOT':
                result = apply_trop_gate(NOT_gate, apply_trop_gate(NOT_gate, state))
            else:
                result = apply_trop_gate(gate, state)
            input_vals.append(state)
            output_vals.append(result)
            state_labels.append(name)

        for i, (inp, out, label) in enumerate(zip(input_vals, output_vals, state_labels)):
            ax.bar(i - width/2, min(inp[0], 10), width, color='steelblue', alpha=0.7,
                    label='Input v₀' if i == 0 else '')
            ax.bar(i + width/2, min(out[0], 10), width, color='coral', alpha=0.7,
                    label='Output v₀' if i == 0 else '')

        ax.set_xticks(range(len(state_labels)))
        ax.set_xticklabels(state_labels, fontsize=10)
        ax.set_ylabel('Action value (v₀ component)', fontsize=11)
        ax.set_title(f'Tropical {gate_name} Gate', fontsize=13)
        if idx == 0:
            ax.legend(fontsize=10)
        ax.grid(True, alpha=0.3, axis='y')

    plt.suptitle('Tropical Quantum Gates: Min-Plus Linear Maps', fontsize=14)
    plt.tight_layout()
    plt.savefig('idempotent_gates.png', dpi=150, bbox_inches='tight')
    plt.close()
    print(f"\n✓ Demo 3: Tropical quantum gates saved")


# ============================================================
# Demo 4: Complete Pipeline
# ============================================================
def demo_complete_pipeline():
    """
    Full pipeline: Quantum → Tropical via decoherence.
    1. Start with quantum superposition
    2. Apply measurement (tropical projection)
    3. Show idempotency of repeated measurement
    """
    n_qubits = 3
    n_states = 2**n_qubits
    np.random.seed(42)

    # Random quantum state (actions)
    actions = np.random.uniform(0, 5, n_states)

    # Labels for computational basis states
    labels = [f'|{i:0{n_qubits}b}⟩' for i in range(n_states)]

    epsilons = [10.0, 2.0, 0.5, 0.1, 0.01]

    fig, axes = plt.subplots(1, len(epsilons), figsize=(4 * len(epsilons), 5))

    for idx, eps in enumerate(epsilons):
        weights = np.exp(-actions / eps)
        probs = weights / np.sum(weights)

        colors = ['coral' if p == max(probs) else 'steelblue' for p in probs]
        axes[idx].bar(range(n_states), probs, color=colors, edgecolor='black', alpha=0.8)
        axes[idx].set_xticks(range(n_states))
        axes[idx].set_xticklabels(labels, fontsize=8, rotation=45)
        axes[idx].set_ylabel('P(k)', fontsize=11)
        axes[idx].set_title(f'ε = {eps}', fontsize=13)
        axes[idx].grid(True, alpha=0.3, axis='y')
        axes[idx].set_ylim(0, 1.05)

        # Annotate min action state
        min_idx = np.argmin(actions)
        if probs[min_idx] > 0.9:
            axes[idx].annotate(f'S={actions[min_idx]:.1f}',
                              xy=(min_idx, probs[min_idx]),
                              fontsize=9, ha='center', va='bottom')

    plt.suptitle('Quantum Decoherence → Tropical Selection\n'
                 '(ε large = quantum, ε small = classical)',
                 fontsize=14)
    plt.tight_layout()
    plt.savefig('idempotent_pipeline.png', dpi=150, bbox_inches='tight')
    plt.close()
    print(f"\n✓ Demo 4: Complete decoherence pipeline saved")
    print(f"  Minimum action state: {labels[np.argmin(actions)]} (S={min(actions):.2f})")


if __name__ == '__main__':
    print("=" * 60)
    print("Idempotent Quantum Computing — Future Direction 6.5")
    print("=" * 60)

    demo_idempotent_semiring()
    demo_tropical_measurement()
    demo_tropical_gates()
    demo_complete_pipeline()

    print("\n" + "=" * 60)
    print("All demos complete! Generated 4 PNG files.")
    print("=" * 60)
