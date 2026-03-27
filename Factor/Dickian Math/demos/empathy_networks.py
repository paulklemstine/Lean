#!/usr/bin/env python3
"""
Empathy Networks and Phase Transitions (ENPT) — Mercerism & Voight-Kampff
==========================================================================
Inspired by Philip K. Dick's Do Androids Dream of Electric Sheep?

This demo simulates:
1. Empathy propagation on networks
2. The Mercerism phase transition (individual → collective consciousness)
3. The Voight-Kampff test as a spectral classifier
4. Weaponized empathy: cascade manipulation attacks

Run: python empathy_networks.py
"""

import numpy as np
import matplotlib.pyplot as plt
import networkx as nx
from scipy.linalg import eigvalsh


def sigmoid(x, threshold=0.3, steepness=10):
    """Sigmoid activation for empathy propagation."""
    return 1 / (1 + np.exp(-steepness * (x - threshold)))


def simulate_empathy_propagation(G, weights, gamma, initial_states,
                                  n_steps=200, dt=0.05, threshold=0.3):
    """
    Simulate empathy propagation:
    de_i/dt = -γ·e_i + Σ_j w_ij · σ(e_j - θ)
    """
    n = len(G.nodes)
    adj = nx.adjacency_matrix(G).toarray().astype(float)
    W = adj * weights  # Weighted adjacency

    states = np.zeros((n_steps, n))
    states[0] = initial_states.copy()

    for t in range(1, n_steps):
        e = states[t - 1]
        activated = sigmoid(e, threshold)
        coupling = W @ activated
        de = -gamma * e + coupling
        states[t] = np.clip(e + dt * de, 0, 1)

    return states


def demo_phase_transition():
    """Demo 1: Mercerism phase transition."""
    print("=" * 60)
    print("DEMO 1: MERCERISM PHASE TRANSITION")
    print("Critical coupling: individual isolation → collective consciousness")
    print("=" * 60)

    np.random.seed(42)
    n = 50
    G = nx.watts_strogatz_graph(n, 6, 0.3)

    # Compute critical coupling
    adj = nx.adjacency_matrix(G).toarray().astype(float)
    eigenvalues = eigvalsh(adj)
    lambda_max = max(eigenvalues)

    gamma = 1.0
    sigma_prime_0 = 10 * 0.25  # σ'(0) for our sigmoid
    w_critical = gamma / (sigma_prime_0 * lambda_max)

    print(f"  Network: Watts-Strogatz (n={n}, k=6, p=0.3)")
    print(f"  Largest eigenvalue λ₁ = {lambda_max:.3f}")
    print(f"  Critical coupling w_c = γ/(σ'(0)·λ₁) = {w_critical:.4f}")

    # Test different coupling strengths
    coupling_strengths = np.linspace(0.01, 0.15, 30)
    order_parameters = []

    for w in coupling_strengths:
        initial = np.random.uniform(0, 0.1, n)
        initial[0] = 0.8  # One "seed" emotion
        states = simulate_empathy_propagation(G, w, gamma, initial, n_steps=300)
        # Order parameter: fraction of synchronized agents
        final = states[-1]
        sync_fraction = np.mean(final > 0.3)
        order_parameters.append(sync_fraction)

    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Phase transition curve
    ax = axes[0]
    ax.plot(coupling_strengths, order_parameters, 'b-o', linewidth=2, markersize=4)
    ax.axvline(x=w_critical, color='red', linestyle='--', linewidth=2,
               label=f'w_c = {w_critical:.4f}')
    ax.fill_between(coupling_strengths, 0,
                     [1 if w > w_critical else 0 for w in coupling_strengths],
                     alpha=0.05, color='green')
    ax.set_xlabel('Coupling Strength w', fontsize=12)
    ax.set_ylabel('Fraction Synchronized', fontsize=12)
    ax.set_title('Mercerism Phase Transition', fontsize=12)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    ax.annotate('Individual\nIsolation', xy=(0.02, 0.1), fontsize=11,
                color='blue', fontweight='bold')
    ax.annotate('Collective\nConsciousness', xy=(0.1, 0.8), fontsize=11,
                color='green', fontweight='bold')

    # Below critical coupling
    ax = axes[1]
    w_sub = w_critical * 0.5
    initial = np.random.uniform(0, 0.1, n)
    initial[0] = 0.9
    states_sub = simulate_empathy_propagation(G, w_sub, gamma, initial, n_steps=200)

    for i in range(n):
        ax.plot(states_sub[:, i], alpha=0.2, linewidth=0.5, color='blue')
    ax.plot(states_sub[:, 0], 'r-', linewidth=2, label='Seed agent')
    ax.set_xlabel('Time', fontsize=12)
    ax.set_ylabel('Emotional State', fontsize=12)
    ax.set_title(f'Below Threshold (w={w_sub:.4f} < w_c)\nEmotion Dies Out', fontsize=11)
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Above critical coupling
    ax = axes[2]
    w_super = w_critical * 2.0
    initial = np.random.uniform(0, 0.1, n)
    initial[0] = 0.9
    states_super = simulate_empathy_propagation(G, w_super, gamma, initial, n_steps=200)

    for i in range(n):
        ax.plot(states_super[:, i], alpha=0.2, linewidth=0.5, color='green')
    ax.plot(states_super[:, 0], 'r-', linewidth=2, label='Seed agent')
    ax.axhline(y=np.mean(states_super[-1]), color='gold', linestyle='--',
               linewidth=2, label=f'Sync level = {np.mean(states_super[-1]):.2f}')
    ax.set_xlabel('Time', fontsize=12)
    ax.set_ylabel('Emotional State', fontsize=12)
    ax.set_title(f'Above Threshold (w={w_super:.4f} > w_c)\nCollective Synchronization!', fontsize=11)
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.suptitle('MERCERISM: The Phase Transition from Isolation to Shared Consciousness',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('demo17_phase_transition.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("→ Saved: demo17_phase_transition.png")
    print()


def demo_voight_kampff():
    """Demo 2: The Voight-Kampff test as a spectral classifier."""
    print("=" * 60)
    print("DEMO 2: THE VOIGHT-KAMPFF TEST")
    print("Spectral detection of empathy deficiency (android detection)")
    print("=" * 60)

    np.random.seed(42)
    n = 100  # Population
    n_androids = 15

    # Create network
    G = nx.barabasi_albert_graph(n, 3)

    # Assign human/android labels
    android_nodes = set(np.random.choice(n, n_androids, replace=False))

    # Assign edge weights
    # Humans: high empathy weights (Beta(5, 2))
    # Androids: low empathy weights (Beta(1, 5))
    weights = {}
    for u, v in G.edges():
        if u in android_nodes or v in android_nodes:
            weights[(u, v)] = np.random.beta(1, 5)
        else:
            weights[(u, v)] = np.random.beta(5, 2)

    # Compute Voight-Kampff number for each node
    vk_numbers = np.zeros(n)
    for i in range(n):
        vk = 0
        for j in G.neighbors(i):
            edge = (min(i, j), max(i, j))
            w = weights.get(edge, weights.get((edge[1], edge[0]), 0))
            d = nx.shortest_path_length(G, i, j)
            vk += w / max(d, 1)
        vk_numbers[i] = vk

    # Classify
    threshold = np.percentile(vk_numbers, 20)

    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    # VK number distribution
    ax = axes[0]
    human_vks = [vk_numbers[i] for i in range(n) if i not in android_nodes]
    android_vks = [vk_numbers[i] for i in range(n) if i in android_nodes]

    ax.hist(human_vks, bins=20, alpha=0.6, color='green', label='Humans',
            density=True, edgecolor='darkgreen')
    ax.hist(android_vks, bins=10, alpha=0.6, color='red', label='Androids',
            density=True, edgecolor='darkred')
    ax.axvline(x=threshold, color='black', linestyle='--', linewidth=2,
               label=f'VK threshold = {threshold:.2f}')
    ax.set_xlabel('Voight-Kampff Number', fontsize=12)
    ax.set_ylabel('Density', fontsize=12)
    ax.set_title('Voight-Kampff Number Distribution', fontsize=12)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Network visualization
    ax = axes[1]
    pos = nx.spring_layout(G, seed=42)
    node_colors = ['red' if i in android_nodes else 'lightgreen' for i in range(n)]
    node_sizes = [50 + 100 * vk_numbers[i] for i in range(n)]

    nx.draw_networkx_nodes(G, pos, ax=ax, node_color=node_colors,
                           node_size=node_sizes, alpha=0.7)
    nx.draw_networkx_edges(G, pos, ax=ax, alpha=0.1)
    ax.set_title('Empathy Network\n(Red = Android, Green = Human)', fontsize=12)

    # ROC curve
    ax = axes[2]
    thresholds = np.linspace(0, max(vk_numbers), 100)
    tpr_list = []
    fpr_list = []

    for thresh in thresholds:
        # Positive = classified as android (VK below threshold)
        tp = sum(1 for i in android_nodes if vk_numbers[i] < thresh)
        fp = sum(1 for i in range(n) if i not in android_nodes and vk_numbers[i] < thresh)
        fn = sum(1 for i in android_nodes if vk_numbers[i] >= thresh)
        tn = sum(1 for i in range(n) if i not in android_nodes and vk_numbers[i] >= thresh)

        tpr = tp / max(tp + fn, 1)
        fpr = fp / max(fp + tn, 1)
        tpr_list.append(tpr)
        fpr_list.append(fpr)

    ax.plot(fpr_list, tpr_list, 'b-', linewidth=2, label='VK Test ROC')
    ax.plot([0, 1], [0, 1], 'k--', alpha=0.5, label='Random classifier')
    ax.fill_between(fpr_list, tpr_list, alpha=0.1, color='blue')

    # Compute AUC
    auc = np.trapezoid(tpr_list, fpr_list)
    ax.set_xlabel('False Positive Rate', fontsize=12)
    ax.set_ylabel('True Positive Rate', fontsize=12)
    ax.set_title(f'ROC Curve (AUC = {abs(auc):.3f})\nVoight-Kampff Test Performance', fontsize=12)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.suptitle('THE VOIGHT-KAMPFF TEST: Spectral Detection of Empathy Deficiency',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('demo18_voight_kampff.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("→ Saved: demo18_voight_kampff.png")
    print(f"  VK test AUC = {abs(auc):.3f}")
    print(f"  Humans: mean VK = {np.mean(human_vks):.3f}")
    print(f"  Androids: mean VK = {np.mean(android_vks):.3f}")
    print()


def demo_weaponized_empathy():
    """Demo 3: Weaponized empathy — cascade manipulation attacks."""
    print("=" * 60)
    print("DEMO 3: WEAPONIZED EMPATHY")
    print("Cascade manipulation attacks on empathy networks (Theorem 6.3)")
    print("=" * 60)

    np.random.seed(42)
    n = 80
    G = nx.watts_strogatz_graph(n, 6, 0.3)
    vertex_connectivity = nx.node_connectivity(G)

    gamma = 0.5
    w = 0.08  # Above phase transition

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    # Normal propagation (no attack)
    ax = axes[0][0]
    initial = np.zeros(n)
    initial[0] = 0.9  # Genuine emotional seed
    states_normal = simulate_empathy_propagation(G, w, gamma, initial, n_steps=150)

    for i in range(n):
        ax.plot(states_normal[:, i], alpha=0.15, color='green', linewidth=0.5)
    ax.plot(np.mean(states_normal, axis=1), 'darkgreen', linewidth=2,
            label='Average emotion')
    ax.set_title('Normal: Genuine Emotional Propagation', fontsize=11)
    ax.set_xlabel('Time')
    ax.set_ylabel('Emotional State')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Single-node attack
    ax = axes[0][1]
    initial_attack = np.zeros(n)
    # Inject false signal at highest-degree node
    degrees = dict(G.degree())
    attack_node = max(degrees, key=degrees.get)
    initial_attack[attack_node] = 1.0  # Malicious false signal
    states_attack1 = simulate_empathy_propagation(G, w, gamma, initial_attack, n_steps=150)

    for i in range(n):
        color = 'red' if i == attack_node else 'orange'
        ax.plot(states_attack1[:, i], alpha=0.15, color=color, linewidth=0.5)
    ax.plot(np.mean(states_attack1, axis=1), 'darkred', linewidth=2,
            label='Average (manipulated)')
    ax.set_title(f'Attack: Single False Signal (node {attack_node})', fontsize=11)
    ax.set_xlabel('Time')
    ax.set_ylabel('Emotional State')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Multi-node attack (at vertex connectivity)
    ax = axes[1][0]
    # Attack at κ(G) nodes = minimum cut
    n_attack_nodes = vertex_connectivity
    attack_nodes = sorted(degrees, key=degrees.get, reverse=True)[:n_attack_nodes]
    initial_multi = np.zeros(n)
    for node in attack_nodes:
        initial_multi[node] = 1.0
    states_multi = simulate_empathy_propagation(G, w, gamma, initial_multi, n_steps=150)

    for i in range(n):
        color = 'red' if i in attack_nodes else 'orange'
        ax.plot(states_multi[:, i], alpha=0.15, color=color, linewidth=0.5)
    ax.plot(np.mean(states_multi, axis=1), 'darkred', linewidth=2,
            label=f'Average ({n_attack_nodes} attack nodes)')
    ax.set_title(f'Attack: κ(G)={vertex_connectivity} Nodes (Vertex Connectivity)',
                 fontsize=11)
    ax.set_xlabel('Time')
    ax.set_ylabel('Emotional State')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Attack effectiveness vs number of compromised nodes
    ax = axes[1][1]
    n_attacks = range(1, 20)
    final_avg_emotions = []

    for k in n_attacks:
        top_k_nodes = sorted(degrees, key=degrees.get, reverse=True)[:k]
        init = np.zeros(n)
        for node in top_k_nodes:
            init[node] = 1.0
        states = simulate_empathy_propagation(G, w, gamma, init, n_steps=150)
        final_avg_emotions.append(np.mean(states[-1]))

    ax.plot(list(n_attacks), final_avg_emotions, 'r-o', linewidth=2, markersize=5)
    ax.axvline(x=vertex_connectivity, color='blue', linestyle='--', linewidth=2,
               label=f'κ(G) = {vertex_connectivity}')
    ax.set_xlabel('Number of Compromised Nodes', fontsize=12)
    ax.set_ylabel('Final Average Emotional State', fontsize=12)
    ax.set_title('Attack Effectiveness vs. Number of Compromised Nodes', fontsize=11)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    ax.annotate(f'Vertex connectivity κ(G) = {vertex_connectivity}\n'
                f'is the minimum attack size\nfor full destabilization',
                xy=(vertex_connectivity, final_avg_emotions[vertex_connectivity - 1]),
                xytext=(vertex_connectivity + 3, 0.3),
                fontsize=10, arrowprops=dict(arrowstyle='->', color='blue'),
                color='blue', bbox=dict(boxstyle='round', facecolor='lightyellow'))

    plt.suptitle('WEAPONIZED EMPATHY: Cascade Manipulation Attacks (Theorem 6.3)',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('demo19_weaponized_empathy.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("→ Saved: demo19_weaponized_empathy.png")
    print(f"  Network vertex connectivity κ(G) = {vertex_connectivity}")
    print(f"  Minimum {vertex_connectivity} compromised nodes needed for destabilization")
    print()


def demo_empathy_box():
    """Demo 4: The Empathy Box — Mercerism simulation."""
    print("=" * 60)
    print("DEMO 4: THE EMPATHY BOX")
    print("Shared suffering through networked consciousness")
    print("=" * 60)

    np.random.seed(42)
    n = 100

    # Create a highly connected "empathy box" network
    G_box = nx.complete_graph(n)  # Everyone connected to everyone

    gamma = 0.5
    w = 0.003  # Small but above threshold (complete graph has λ₁ = n-1)

    # Mercer's suffering signal
    t_steps = 300
    mercer_signal = np.zeros(t_steps)
    # Periodic suffering (climbing the hill, being hit by rocks)
    for t in range(t_steps):
        mercer_signal[t] = 0.5 + 0.3 * np.sin(2 * np.pi * t / 50) + \
                           0.2 * (np.random.rand() > 0.9)  # Occasional sharp pain

    # Simulate with external driving from Mercer
    adj = nx.adjacency_matrix(G_box).toarray().astype(float)
    states = np.zeros((t_steps, n))
    states[0] = np.random.uniform(0, 0.1, n)
    dt = 0.05

    for t in range(1, t_steps):
        e = states[t - 1]
        activated = sigmoid(e, 0.3)
        coupling = w * adj @ activated
        # Add Mercer's signal as external driving
        de = -gamma * e + coupling + 0.3 * mercer_signal[t]
        states[t] = np.clip(e + dt * de, 0, 1)

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    # Mercer's signal
    ax = axes[0][0]
    ax.plot(mercer_signal, 'purple', linewidth=2)
    ax.set_xlabel('Time')
    ax.set_ylabel('Suffering Intensity')
    ax.set_title("Mercer's Suffering Signal\n(Climbing the hill, struck by rocks)", fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.fill_between(range(t_steps), mercer_signal, alpha=0.1, color='purple')

    # All agents' emotional states
    ax = axes[0][1]
    for i in range(min(n, 50)):
        ax.plot(states[:, i], alpha=0.1, color='blue', linewidth=0.5)
    ax.plot(np.mean(states, axis=1), 'red', linewidth=2, label='Collective emotion')
    ax.plot(mercer_signal * 0.3, 'purple', linewidth=1, alpha=0.5,
            label="Mercer's signal (scaled)")
    ax.set_xlabel('Time')
    ax.set_ylabel('Emotional State')
    ax.set_title('Empathy Box: Individual & Collective Emotion', fontsize=11)
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Synchronization over time
    ax = axes[1][0]
    std_over_time = np.std(states, axis=1)
    ax.plot(std_over_time, 'orange', linewidth=2)
    ax.set_xlabel('Time')
    ax.set_ylabel('Emotional Variance (σ)')
    ax.set_title('Synchronization: Variance Decreasing\n= Collective Consciousness Forming', fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.fill_between(range(t_steps), std_over_time, alpha=0.2, color='orange')

    # Correlation matrix at end
    ax = axes[1][1]
    final_window = states[-50:]
    corr = np.corrcoef(final_window.T)
    im = ax.imshow(corr, cmap='RdYlGn', vmin=-1, vmax=1, aspect='auto')
    plt.colorbar(im, ax=ax, label='Correlation')
    ax.set_xlabel('Agent')
    ax.set_ylabel('Agent')
    ax.set_title('Emotional Correlation Matrix\n(All positively correlated = Mercerism)', fontsize=11)

    plt.suptitle('THE EMPATHY BOX: Shared Suffering Creates Collective Consciousness',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('demo20_empathy_box.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("→ Saved: demo20_empathy_box.png")
    print(f"  {n} agents connected via Empathy Box")
    print(f"  Final synchronization: σ = {std_over_time[-1]:.4f}")
    print(f"  Mean correlation: {np.mean(corr[np.triu_indices(n, k=1)]):.3f}")
    print()


if __name__ == '__main__':
    print()
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║  EMPATHY NETWORKS — DO ANDROIDS DREAM OF ELECTRIC SHEEP?   ║")
    print("║  'You will be required to do wrong no matter where you go. ║")
    print("║   It is the basic condition of life.' — Philip K. Dick     ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    print()

    demo_phase_transition()
    demo_voight_kampff()
    demo_weaponized_empathy()
    demo_empathy_box()

    print("=" * 60)
    print("ALL EMPATHY NETWORK DEMOS COMPLETE")
    print("=" * 60)
