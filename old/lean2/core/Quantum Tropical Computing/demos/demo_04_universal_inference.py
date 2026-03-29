#!/usr/bin/env python3
"""
Demo 4: Universal Tropical Inference
======================================

Demonstrates the universality of tropical computation for inference:
    - Bayesian networks via tropical message passing
    - Belief propagation as tropical factor graph computation
    - Tropical neural inference (combining learning + inference)
    - Phase transition in inference difficulty

Generates:
    - tropical_bayes_inference.png
    - tropical_belief_propagation.png
    - tropical_universal_computation.png
"""

import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from qtlib.inference import TropicalBayesNet, TropicalViterbi, TropicalBeliefPropagation
from qtlib.circuits import TropicalCircuit, QuantumTropicalSimulator
from qtlib.gates import TropicalHadamard, TropicalCNOT, TropicalPhase
from qtlib.semiring import maslov_add

np.random.seed(42)
plt.rcParams['figure.dpi'] = 150


def plot_bayes_inference():
    """Demonstrate tropical Bayesian network inference."""
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))
    fig.suptitle("Tropical Bayesian Inference\n(MAP = Tropical Linear Algebra)",
                 fontsize=14, fontweight='bold')

    # Build a medical diagnosis Bayesian network
    net = TropicalBayesNet()

    # Root causes
    net.add_node('Flu', values=2, log_cpt=np.log([0.95, 0.05]))
    net.add_node('Cold', values=2, log_cpt=np.log([0.8, 0.2]))
    net.add_node('Allergy', values=2, log_cpt=np.log([0.7, 0.3]))

    # Symptoms conditioned on causes
    # Fever | Flu, Cold
    fever_cpt = np.log(np.array([
        [[0.95, 0.05], [0.6, 0.4]],   # Flu=No
        [[0.3, 0.7], [0.1, 0.9]],     # Flu=Yes
    ]))
    net.add_node('Fever', values=2, parents=['Flu', 'Cold'], log_cpt=fever_cpt)

    # Sneeze | Cold, Allergy
    sneeze_cpt = np.log(np.array([
        [[0.8, 0.2], [0.3, 0.7]],   # Cold=No
        [[0.4, 0.6], [0.1, 0.9]],   # Cold=Yes
    ]))
    net.add_node('Sneeze', values=2, parents=['Cold', 'Allergy'], log_cpt=sneeze_cpt)

    # Test different evidence scenarios
    scenarios = [
        ({}, "No evidence"),
        ({'Fever': 1}, "Fever observed"),
        ({'Sneeze': 1}, "Sneeze observed"),
        ({'Fever': 1, 'Sneeze': 1}, "Fever + Sneeze"),
    ]

    node_names = ['Flu', 'Cold', 'Allergy', 'Fever', 'Sneeze']
    value_names = {0: 'No', 1: 'Yes'}

    for idx, (evidence, title) in enumerate(scenarios):
        ax = axes[idx // 2, idx % 2]
        result = net.infer_map(evidence)

        # Visualize assignment
        assignments = [result['assignment'].get(n, -1) for n in node_names]
        colors = ['lightcoral' if a == 1 else 'lightblue' for a in assignments]

        # Mark evidence nodes
        for n in evidence:
            i = node_names.index(n)
            colors[i] = 'gold'

        bars = ax.barh(range(len(node_names)), [1]*len(node_names), color=colors)
        ax.set_yticks(range(len(node_names)))
        ax.set_yticklabels(node_names)
        ax.set_xticks([])
        ax.set_title(f'{title}\nlog P = {result["log_probability"]:.2f}')

        # Annotate with MAP values
        for i, (name, val) in enumerate(zip(node_names, assignments)):
            label = value_names.get(val, '?')
            ax.text(0.5, i, label, ha='center', va='center', fontsize=14, fontweight='bold')

    # Add legend
    from matplotlib.patches import Patch
    legend_elements = [
        Patch(facecolor='lightblue', label='MAP = No'),
        Patch(facecolor='lightcoral', label='MAP = Yes'),
        Patch(facecolor='gold', label='Evidence'),
    ]
    fig.legend(handles=legend_elements, loc='lower center', ncol=3, fontsize=12)

    plt.tight_layout(rect=[0, 0.05, 1, 0.95])
    plt.savefig(os.path.join(os.path.dirname(__file__), 'tropical_bayes_inference.png'),
                bbox_inches='tight')
    print("Saved: tropical_bayes_inference.png")
    plt.close()


def plot_belief_propagation():
    """Visualize tropical belief propagation on a factor graph."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    fig.suptitle("Tropical Belief Propagation\n(Max-Product Message Passing = Tropical Computation)",
                 fontsize=14, fontweight='bold')

    # Simple factor graph: 4 variables, 3 binary factors
    n_vars = 4
    domains = [3, 3, 3, 3]  # Each variable has 3 values

    bp = TropicalBeliefPropagation(n_vars, domains)

    # Add factors (log-potentials)
    # Factor 1: x0, x1 prefer to be equal
    f1 = np.zeros((3, 3))
    for i in range(3):
        f1[i, i] = 2.0  # Bonus for agreement
    bp.add_factor([0, 1], f1)

    # Factor 2: x1, x2 prefer to differ
    f2 = np.ones((3, 3)) * 1.0
    for i in range(3):
        f2[i, i] = -1.0  # Penalty for agreement
    bp.add_factor([1, 2], f2)

    # Factor 3: x2, x3 prefer equal
    f3 = np.zeros((3, 3))
    for i in range(3):
        f3[i, i] = 1.5
    bp.add_factor([2, 3], f3)

    # Run BP with different iterations
    iterations_list = [1, 5, 20]
    for idx, n_iter in enumerate(iterations_list):
        bp_copy = TropicalBeliefPropagation(n_vars, domains)
        bp_copy.add_factor([0, 1], f1)
        bp_copy.add_factor([1, 2], f2)
        bp_copy.add_factor([2, 3], f3)

        result = bp_copy.run(n_iterations=n_iter)

        ax = axes[idx]
        beliefs = result['beliefs']
        belief_matrix = np.array([b - np.max(b) for b in beliefs])  # Normalize
        im = ax.imshow(belief_matrix.T, cmap='RdYlGn', aspect='auto',
                       vmin=-5, vmax=0)
        ax.set_xlabel('Variable')
        ax.set_ylabel('Value')
        ax.set_xticks(range(n_vars))
        ax.set_xticklabels([f'x{i}' for i in range(n_vars)])
        ax.set_yticks(range(3))
        ax.set_title(f'Beliefs after {n_iter} iterations\nMAP: {result["assignment"]}')
        plt.colorbar(im, ax=ax, label='log-belief (normalized)')

        # Mark MAP values
        for i, v in enumerate(result['assignment']):
            ax.plot(i, v, 'w*', markersize=20)

    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__), 'tropical_belief_propagation.png'),
                bbox_inches='tight')
    print("Saved: tropical_belief_propagation.png")
    plt.close()


def plot_universal_computation():
    """Show how tropical circuits, neural networks, and inference are unified."""
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))
    fig.suptitle("The Tropical Computing Trinity:\nCircuits ↔ Neural Networks ↔ Inference",
                 fontsize=14, fontweight='bold')

    # 1. Circuit → Neural Network equivalence
    ax = axes[0, 0]
    # A tropical circuit computes max-plus: same as a ReLU network
    inputs = np.linspace(-3, 3, 200)
    circ = TropicalCircuit(n_qubits=2)
    circ.add(TropicalPhase(phi=1.0, target=0))
    circ.add(TropicalHadamard(target=0))
    circ.add(TropicalCNOT(control=0, target=1))

    outputs_0 = []
    outputs_1 = []
    for x in inputs:
        result = circ.run(np.array([x, 0.0]))
        outputs_0.append(result[0])
        outputs_1.append(result[1])

    ax.plot(inputs, outputs_0, 'b-', linewidth=2, label='Circuit output q0')
    ax.plot(inputs, outputs_1, 'r-', linewidth=2, label='Circuit output q1')
    ax.plot(inputs, np.maximum(inputs + 1, 0), 'b--', alpha=0.5, label='max(x+1, 0) = ReLU(x+1)')
    ax.set_xlabel('Input')
    ax.set_ylabel('Output')
    ax.set_title('Tropical Circuit = Piecewise Linear\n(Same as ReLU Network!)')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    # 2. Neural Network → Tropical Polynomial
    ax = axes[0, 1]
    # A 2-layer ReLU network with specific weights computes max of affine functions
    def tropical_poly(x, weights_biases):
        """Evaluate max of affine functions (tropical polynomial)."""
        return max(w * x + b for w, b in weights_biases)

    wb = [(1, 0), (-1, 2), (0.5, -1), (-0.5, 3)]
    x_range = np.linspace(-4, 4, 500)
    y_max = [tropical_poly(x, wb) for x in x_range]

    for w, b in wb:
        ax.plot(x_range, w * x_range + b, '--', alpha=0.4)

    ax.plot(x_range, y_max, 'k-', linewidth=3, label='Tropical polynomial\n= max of affine functions')
    ax.set_xlabel('x')
    ax.set_ylabel('f(x)')
    ax.set_title('Tropical Polynomial = Piecewise Linear\n(Neural network with 4 neurons)')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # 3. Inference → Tropical matrix power
    ax = axes[1, 0]
    # Shortest path as tropical matrix power
    n = 5
    # Distance matrix (as tropical semiring: minimize → use min-plus, or negate for max-plus)
    dist = np.array([
        [0, 2, np.inf, np.inf, np.inf],
        [np.inf, 0, 3, np.inf, np.inf],
        [np.inf, np.inf, 0, 1, np.inf],
        [np.inf, np.inf, np.inf, 0, 4],
        [np.inf, np.inf, np.inf, np.inf, 0],
    ])
    # Tropical (max-plus) version: negate distances
    trop_dist = np.where(np.isinf(dist), -np.inf, -dist)

    # Compute tropical powers: A^k gives shortest paths of length ≤ k
    current = trop_dist.copy()
    powers = [current.copy()]
    for k in range(1, n):
        new = np.full((n, n), -np.inf)
        for i in range(n):
            for j in range(n):
                for m in range(n):
                    new[i, j] = max(new[i, j], current[i, m] + trop_dist[m, j])
        current = new
        powers.append(current.copy())

    # Show convergence of shortest path (0→4)
    path_costs = [-p[0, 4] for p in powers if p[0, 4] > -np.inf]
    ax.bar(range(1, len(path_costs)+1), path_costs, color='steelblue')
    ax.set_xlabel('Max hops allowed')
    ax.set_ylabel('Shortest path cost (0 → 4)')
    ax.set_title('Shortest Path = Tropical Matrix Power\n(Dynamic Programming IS Tropical LA)')
    ax.grid(True, alpha=0.3)

    # 4. The unifying diagram
    ax = axes[1, 1]
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 10)
    ax.axis('off')

    # Draw the trinity triangle
    triangle_x = [5, 1.5, 8.5, 5]
    triangle_y = [9, 2, 2, 9]
    ax.plot(triangle_x, triangle_y, 'k-', linewidth=3)

    # Nodes
    for x, y, label, color in [
        (5, 9, 'Tropical\nCircuits', '#FF6B6B'),
        (1.5, 2, 'Neural\nNetworks', '#4ECDC4'),
        (8.5, 2, 'Inference\nEngines', '#45B7D1'),
    ]:
        circle = plt.Circle((x, y), 1.2, color=color, alpha=0.8, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y, label, ha='center', va='center', fontsize=11,
                fontweight='bold', zorder=6)

    # Edge labels
    ax.text(3, 6, 'ReLU = max\n(tropical add)', ha='center', va='center',
            fontsize=9, rotation=55, color='darkred',
            bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))
    ax.text(7, 6, 'Viterbi = tropical\nmatrix power', ha='center', va='center',
            fontsize=9, rotation=-55, color='darkblue',
            bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))
    ax.text(5, 1.5, 'Backprop = tropical\npath tracing', ha='center', va='center',
            fontsize=9, color='darkgreen',
            bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

    # Center label
    ax.text(5, 5, 'TROPICAL\nSEMIRING\n(ℝ, max, +)', ha='center', va='center',
            fontsize=13, fontweight='bold', color='purple',
            bbox=dict(boxstyle='round', facecolor='lavender', alpha=0.9))

    ax.set_title('The Tropical Computing Trinity', fontsize=13)

    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__), 'tropical_universal_computation.png'),
                bbox_inches='tight')
    print("Saved: tropical_universal_computation.png")
    plt.close()


if __name__ == "__main__":
    plot_bayes_inference()
    plot_belief_propagation()
    plot_universal_computation()
    print("\nAll Demo 4 visualizations generated!")
