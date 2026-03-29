#!/usr/bin/env python3
"""
Demo 3: Quantum Tropical Circuit Simulator Visualization
==========================================================

Generates:
    - circuit_beta_sweep.png: State evolution across the quantum-tropical spectrum
    - circuit_entanglement.png: Tropical entanglement detection and visualization
    - circuit_annealing.png: Maslov annealing convergence to optimal solution
    - viterbi_tropical.png: Viterbi decoding as tropical linear algebra
"""

import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from qtlib.gates import TropicalHadamard, TropicalCNOT, TropicalPhase, TropicalToffoli
from qtlib.circuits import TropicalCircuit, QuantumTropicalSimulator
from qtlib.tensor import tropical_tensor_product, tropical_entanglement, tropical_schmidt_decomposition
from qtlib.inference import TropicalViterbi

np.random.seed(42)
plt.rcParams['figure.dpi'] = 150


def plot_beta_sweep():
    """Sweep β from quantum to tropical and visualize the phase transition."""
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))
    fig.suptitle("Quantum → Tropical Phase Transition\n(β controls the sharpness of computation)",
                 fontsize=14, fontweight='bold')

    sim = QuantumTropicalSimulator(n_qubits=4)
    sim.build_circuit([
        TropicalHadamard(target=0),
        TropicalCNOT(control=0, target=1),
        TropicalPhase(phi=0.5, target=2),
        TropicalHadamard(target=2),
        TropicalCNOT(control=2, target=3),
    ])

    state = np.array([3.0, 1.0, -0.5, 2.0])
    betas = np.logspace(-1, 2, 200)
    sweep = sim.sweep_beta(state, betas)

    # 1. State components vs β
    ax = axes[0, 0]
    for i in range(4):
        ax.semilogx(betas, sweep['states'][:, i], linewidth=2, label=f'qubit {i}')
    ax.set_xlabel('β')
    ax.set_ylabel('State value')
    ax.set_title('State Components vs β')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # 2. Entropy vs β
    ax = axes[0, 1]
    ax.semilogx(betas, sweep['entropies'], 'purple', linewidth=2)
    ax.fill_between(betas, 0, sweep['entropies'], alpha=0.2, color='purple')
    ax.set_xlabel('β')
    ax.set_ylabel('Shannon Entropy')
    ax.set_title('Measurement Entropy\n(High = quantum uncertainty, Low = tropical certainty)')
    ax.grid(True, alpha=0.3)

    # Annotate regimes
    ax.axvspan(0.1, 0.5, alpha=0.1, color='blue', label='Quantum regime')
    ax.axvspan(0.5, 5, alpha=0.1, color='green', label='ML regime')
    ax.axvspan(5, 100, alpha=0.1, color='red', label='Tropical regime')
    ax.legend(fontsize=8)

    # 3. Softmax probabilities at three β values
    ax = axes[1, 0]
    for beta, color, label in [(0.5, 'blue', 'β=0.5 (quantum)'),
                                (2.0, 'green', 'β=2.0 (ML)'),
                                (50.0, 'red', 'β=50 (tropical)')]:
        final = sim.circuit.run(state, beta=beta)
        probs = sim.circuit.tropical_probabilities(final, beta)
        ax.bar(np.arange(4) + {'blue': -0.2, 'green': 0, 'red': 0.2}[color],
               probs, width=0.2, color=color, label=label, alpha=0.8)
    ax.set_xlabel('Qubit')
    ax.set_ylabel('Probability')
    ax.set_title('Measurement Probabilities\n(Uniform → Concentrated)')
    ax.set_xticks([0, 1, 2, 3])
    ax.legend(fontsize=8)

    # 4. Winner (measurement) vs β
    ax = axes[1, 1]
    ax.semilogx(betas, sweep['measurements'], 'ko', markersize=1, alpha=0.5)
    ax.set_xlabel('β')
    ax.set_ylabel('Winner (qubit index)')
    ax.set_title('WTA Measurement Result vs β')
    ax.set_yticks([0, 1, 2, 3])
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__), 'circuit_beta_sweep.png'),
                bbox_inches='tight')
    print("Saved: circuit_beta_sweep.png")
    plt.close()


def plot_entanglement():
    """Visualize tropical entanglement through tensor products and ranks."""
    fig, axes = plt.subplots(2, 3, figsize=(15, 10))
    fig.suptitle("Tropical Entanglement: When States Can't Be Factored",
                 fontsize=14, fontweight='bold')

    # Row 1: Separable states
    a = np.array([3.0, 1.0, -1.0])
    b = np.array([0.0, 2.0])
    M_sep = tropical_tensor_product(a, b)

    ax = axes[0, 0]
    im = ax.imshow(M_sep, cmap='viridis', aspect='auto')
    ax.set_title(f'Separable: M = a ⊗_T b\na={a}, b={b}')
    ax.set_xlabel('System B')
    ax.set_ylabel('System A')
    plt.colorbar(im, ax=ax)

    ent_sep = tropical_entanglement(M_sep)
    ax = axes[0, 1]
    ax.imshow(ent_sep['best_separable'], cmap='viridis', aspect='auto')
    ax.set_title(f"Best Rank-1 Approximation\nRank: {ent_sep['rank']}, Entangled: {ent_sep['is_entangled']}")
    ax.set_xlabel('System B')
    ax.set_ylabel('System A')

    ax = axes[0, 2]
    error = np.abs(M_sep - ent_sep['best_separable'])
    ax.imshow(error, cmap='hot', aspect='auto')
    ax.set_title(f"Approximation Error\nmax error: {np.max(error):.4f}")
    ax.set_xlabel('System B')
    ax.set_ylabel('System A')

    # Row 2: Entangled states
    M_ent = np.array([
        [5.0, 0.0],
        [0.0, 5.0],
        [2.5, 2.5],
    ])

    ax = axes[1, 0]
    im = ax.imshow(M_ent, cmap='plasma', aspect='auto')
    ax.set_title('Entangled: tropical Bell-like state')
    ax.set_xlabel('System B')
    ax.set_ylabel('System A')
    plt.colorbar(im, ax=ax)

    ent_ent = tropical_entanglement(M_ent)
    ax = axes[1, 1]
    ax.imshow(ent_ent['best_separable'], cmap='plasma', aspect='auto')
    ax.set_title(f"Best Rank-1 Approximation\nRank: {ent_ent['rank']}, Entangled: {ent_ent['is_entangled']}")
    ax.set_xlabel('System B')
    ax.set_ylabel('System A')

    ax = axes[1, 2]
    error_ent = np.abs(M_ent - ent_ent['best_separable'])
    ax.imshow(error_ent, cmap='hot', aspect='auto')
    ax.set_title(f"Approximation Error\nmax error: {np.max(error_ent):.4f}")
    ax.set_xlabel('System B')
    ax.set_ylabel('System A')

    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__), 'circuit_entanglement.png'),
                bbox_inches='tight')
    print("Saved: circuit_entanglement.png")
    plt.close()


def plot_annealing():
    """Visualize Maslov annealing: quantum exploration → tropical exploitation."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    fig.suptitle("Maslov Annealing: Exploration → Exploitation",
                 fontsize=14, fontweight='bold')

    # Build a circuit for optimization
    n_gates = 20
    circ = TropicalCircuit(n_qubits=3)
    for i in range(n_gates):
        if i % 4 == 0:
            circ.add(TropicalHadamard(target=i % 3))
        elif i % 4 == 1:
            circ.add(TropicalCNOT(control=i % 3, target=(i+1) % 3))
        elif i % 4 == 2:
            circ.add(TropicalPhase(phi=0.5 * np.sin(i), target=i % 3))
        else:
            circ.add(TropicalHadamard(target=(i+2) % 3))

    state = np.array([1.0, -0.5, 0.3])

    # Different annealing schedules
    schedules = {
        'Linear': np.linspace(0.1, 50.0, n_gates),
        'Exponential': np.exp(np.linspace(np.log(0.1), np.log(50.0), n_gates)),
        'Sudden': np.array([0.1]*10 + [50.0]*10),
    }

    # 1. β schedule
    ax = axes[0]
    for name, sched in schedules.items():
        ax.plot(sched, label=name, linewidth=2)
    ax.set_xlabel('Gate index')
    ax.set_ylabel('β')
    ax.set_title('Annealing Schedules')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # 2. Output vs schedule
    ax = axes[1]
    for name, sched in schedules.items():
        result = circ.run_annealing(state, sched.tolist())
        ax.bar(np.arange(3) + list(schedules.keys()).index(name) * 0.25,
               result, width=0.25, label=name, alpha=0.8)
    ax.set_xlabel('Qubit')
    ax.set_ylabel('Final state value')
    ax.set_title('Output State by Schedule')
    ax.set_xticks([0.25, 1.25, 2.25])
    ax.set_xticklabels(['q0', 'q1', 'q2'])
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    # 3. Entropy during annealing
    ax = axes[2]
    for name, sched in schedules.items():
        entropies = []
        s = state.copy()
        for i, gate in enumerate(circ.gates):
            s = gate.apply_maslov(s, sched[i])
            probs = np.exp(sched[i] * s) / np.sum(np.exp(sched[i] * s))
            entropy = -np.sum(probs * np.log(probs + 1e-30))
            entropies.append(entropy)
        ax.plot(entropies, label=name, linewidth=2)
    ax.set_xlabel('Gate index')
    ax.set_ylabel('Entropy')
    ax.set_title('Entropy During Annealing\n(Decreasing = converging to solution)')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__), 'circuit_annealing.png'),
                bbox_inches='tight')
    print("Saved: circuit_annealing.png")
    plt.close()


def plot_viterbi():
    """Visualize Viterbi decoding as tropical linear algebra."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    fig.suptitle("Viterbi Decoding = Tropical Matrix Power\n(MAP inference IS tropical linear algebra)",
                 fontsize=14, fontweight='bold')

    # Define HMM
    n_states = 3
    n_obs = 4
    viterbi = TropicalViterbi(n_states, n_obs)

    # Weather HMM: states = {Sunny, Cloudy, Rainy}, obs = {Walk, Shop, Clean, Cook}
    log_trans = np.log(np.array([
        [0.6, 0.3, 0.1],  # Sunny →
        [0.2, 0.5, 0.3],  # Cloudy →
        [0.1, 0.3, 0.6],  # Rainy →
    ]))
    log_emit = np.log(np.array([
        [0.5, 0.2, 0.1, 0.2],  # Sunny: Walk, Shop, Clean, Cook
        [0.2, 0.3, 0.3, 0.2],  # Cloudy
        [0.05, 0.1, 0.6, 0.25],  # Rainy
    ]))
    log_init = np.log(np.array([0.5, 0.3, 0.2]))

    viterbi.set_parameters(log_trans, log_emit, log_init)

    # Observation sequence
    observations = [0, 1, 2, 2, 3, 0, 2, 1]  # Walk, Shop, Clean, Clean, Cook, Walk, Clean, Shop
    obs_names = ['Walk', 'Shop', 'Clean', 'Clean', 'Cook', 'Walk', 'Clean', 'Shop']
    state_names = ['Sunny', 'Cloudy', 'Rainy']

    result = viterbi.decode(observations)

    # 1. Trellis visualization
    ax = axes[0]
    trellis = result['trellis']
    im = ax.imshow(trellis.T, cmap='YlOrRd', aspect='auto')
    ax.set_xlabel('Time step')
    ax.set_ylabel('State')
    ax.set_yticks([0, 1, 2])
    ax.set_yticklabels(state_names)
    ax.set_title('Viterbi Trellis\n(Tropical dynamic programming)')
    plt.colorbar(im, ax=ax, label='log-probability')

    # Overlay best path
    best_states = result['states']
    ax.plot(range(len(best_states)), best_states, 'w*-', markersize=15, linewidth=3)

    # 2. Decoded states
    ax = axes[1]
    colors = ['gold', 'gray', 'steelblue']
    bars = ax.bar(range(len(best_states)), [1]*len(best_states),
                  color=[colors[s] for s in best_states])
    ax.set_xticks(range(len(obs_names)))
    ax.set_xticklabels(obs_names, rotation=45, ha='right', fontsize=8)
    ax.set_yticks([])
    ax.set_title(f'Decoded Weather Sequence\nlog P(best path) = {result["log_probability"]:.2f}')

    # Legend
    for i, name in enumerate(state_names):
        ax.bar([], [], color=colors[i], label=name)
    ax.legend()

    # 3. Per-step log-probabilities
    ax = axes[2]
    for s in range(n_states):
        ax.plot(trellis[:, s], 'o-', color=colors[s], label=state_names[s], linewidth=2)
    ax.set_xlabel('Time step')
    ax.set_ylabel('log-probability δ_t(s)')
    ax.set_title('State Log-Probabilities\n(Tropical message = max-plus update)')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__), 'viterbi_tropical.png'),
                bbox_inches='tight')
    print("Saved: viterbi_tropical.png")
    plt.close()


if __name__ == "__main__":
    plot_beta_sweep()
    plot_entanglement()
    plot_annealing()
    plot_viterbi()
    print("\nAll Demo 3 visualizations generated!")
