#!/usr/bin/env python3
"""
Pre-cognitive Game Theory (PGT) — The Minority Report
=====================================================
Inspired by Philip K. Dick's "The Minority Report" and "The Golden Man."

This demo simulates:
1. Pre-cognitive dominance in zero-sum games
2. The Minority Report Paradox (prediction-intervention feedback loop)
3. The Golden Man pursuit-evasion game
4. Free Will Measure computation

Run: python precrime_game_theory.py
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product
import networkx as nx


def precog_game_simulation(payoff_matrix, n_rounds=10000):
    """
    Simulate a 2-player game where Player 1 is pre-cognitive.

    Player 2 plays mixed strategy (Nash equilibrium attempt).
    Player 1 sees Player 2's realized action and best-responds.

    Returns average payoffs for both players.
    """
    n_actions_1, n_actions_2 = payoff_matrix.shape

    # Player 2's mixed strategy (uniform as a starting point)
    p2_mixed = np.ones(n_actions_2) / n_actions_2

    payoffs_1 = []
    payoffs_2 = []

    for _ in range(n_rounds):
        # Player 2 draws from their mixed strategy
        a2 = np.random.choice(n_actions_2, p=p2_mixed)

        # Player 1 (pre-cog) sees a2 and best-responds
        a1 = np.argmax(payoff_matrix[:, a2])

        payoffs_1.append(payoff_matrix[a1, a2])
        payoffs_2.append(-payoff_matrix[a1, a2])  # Zero-sum

    return np.mean(payoffs_1), np.mean(payoffs_2)


def normal_game_simulation(payoff_matrix, n_rounds=10000):
    """Normal game where both players play mixed strategies."""
    n_actions_1, n_actions_2 = payoff_matrix.shape

    p1_mixed = np.ones(n_actions_1) / n_actions_1
    p2_mixed = np.ones(n_actions_2) / n_actions_2

    payoffs_1 = []
    for _ in range(n_rounds):
        a1 = np.random.choice(n_actions_1, p=p1_mixed)
        a2 = np.random.choice(n_actions_2, p=p2_mixed)
        payoffs_1.append(payoff_matrix[a1, a2])

    return np.mean(payoffs_1), -np.mean(payoffs_1)


def demo_precog_advantage():
    """Demo 1: Pre-cognitive advantage in various games."""
    print("=" * 60)
    print("DEMO 1: PRE-COGNITIVE DOMINANCE")
    print("The pre-cog always wins (Theorem 4.1)")
    print("=" * 60)

    games = {
        'Rock-Paper-Scissors': np.array([
            [0, -1, 1],
            [1, 0, -1],
            [-1, 1, 0]
        ]),
        'Matching Pennies': np.array([
            [1, -1],
            [-1, 1]
        ]),
        'Battle of the Sexes': np.array([
            [3, 0],
            [0, 2]
        ]),
        'Asymmetric Game': np.array([
            [4, -2, 1],
            [-1, 3, -1],
            [0, 0, 2]
        ])
    }

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    for idx, (name, payoff) in enumerate(games.items()):
        ax = axes[idx // 2][idx % 2]

        # Run many simulations
        n_sims = 50
        precog_payoffs = []
        normal_payoffs = []

        for _ in range(n_sims):
            p_precog, _ = precog_game_simulation(payoff, n_rounds=1000)
            p_normal, _ = normal_game_simulation(payoff, n_rounds=1000)
            precog_payoffs.append(p_precog)
            normal_payoffs.append(p_normal)

        bp = ax.boxplot([normal_payoffs, precog_payoffs],
                        tick_labels=['Normal', 'Pre-Cognitive'],
                        patch_artist=True)
        bp['boxes'][0].set_facecolor('lightblue')
        bp['boxes'][1].set_facecolor('gold')

        ax.set_title(f'{name}', fontsize=12)
        ax.set_ylabel('Average Payoff')
        ax.grid(True, alpha=0.3)

        # Compute advantage
        adv = np.mean(precog_payoffs) - np.mean(normal_payoffs)
        ax.annotate(f'Pre-cog advantage: +{adv:.2f}',
                    xy=(1.5, np.mean(precog_payoffs)), fontsize=10,
                    color='darkred', fontweight='bold')

    plt.suptitle('Pre-Cognitive Dominance: The Pre-Cog Always Wins',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('demo9_precog_advantage.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("→ Saved: demo9_precog_advantage.png")
    print()


def demo_minority_report_paradox():
    """Demo 2: The Minority Report Paradox — prediction destroys its own basis."""
    print("=" * 60)
    print("DEMO 2: THE MINORITY REPORT PARADOX")
    print("Prediction-intervention feedback destabilizes the system")
    print("=" * 60)

    # Simulate crime prediction with intervention
    n_steps = 200
    n_citizens = 100

    # Each citizen has a crime probability
    np.random.seed(42)
    base_crime_probs = np.random.beta(2, 20, n_citizens)  # Mostly law-abiding

    # Pre-crime system with feedback
    crime_rates_precrime = []
    crime_rates_noprecrime = []
    false_positive_rates = []
    prediction_accuracy = []

    intervention_threshold = 0.15

    for t in range(n_steps):
        # Without pre-crime: crimes happen at base rate
        crimes_no = np.random.binomial(1, base_crime_probs)
        crime_rates_noprecrime.append(crimes_no.sum())

        # With pre-crime: predict and intervene
        # Prediction includes noise
        predicted_probs = base_crime_probs + np.random.normal(0, 0.05, n_citizens)
        predicted_probs = np.clip(predicted_probs, 0, 1)

        # Intervene on predicted criminals
        interventions = predicted_probs > intervention_threshold
        actual_crimes = np.random.binomial(1, base_crime_probs)

        # Count crimes that would have happened without intervention
        prevented = (interventions & (actual_crimes == 1)).sum()
        unprevented = (~interventions & (actual_crimes == 1)).sum()
        false_positives = (interventions & (actual_crimes == 0)).sum()

        crime_rates_precrime.append(unprevented)
        false_positive_rates.append(false_positives)

        # THE PARADOX: we can't verify prevented crimes!
        # Accuracy is unmeasurable because intervention changes the outcome
        if interventions.sum() > 0:
            # What fraction of interventions were "justified"?
            # We can never know for certain!
            apparent_accuracy = prevented / max(1, interventions.sum())
            prediction_accuracy.append(apparent_accuracy)
        else:
            prediction_accuracy.append(0)

        # Feedback: intervened citizens become more paranoid → slightly higher base rate
        base_crime_probs[interventions] *= 1.005  # Micro-radicalization
        base_crime_probs = np.clip(base_crime_probs, 0, 0.5)

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    # Crime rates
    ax = axes[0][0]
    window = 10
    smoothed_precrime = np.convolve(crime_rates_precrime, np.ones(window)/window, mode='valid')
    smoothed_noprecrime = np.convolve(crime_rates_noprecrime, np.ones(window)/window, mode='valid')
    ax.plot(smoothed_noprecrime, 'r-', linewidth=2, label='Without Pre-Crime', alpha=0.7)
    ax.plot(smoothed_precrime, 'b-', linewidth=2, label='With Pre-Crime', alpha=0.7)
    ax.set_xlabel('Time')
    ax.set_ylabel('Crime Count')
    ax.set_title('Crime Rates: Pre-Crime Initially Helps...', fontsize=12)
    ax.legend()
    ax.grid(True, alpha=0.3)

    # False positives
    ax = axes[0][1]
    smoothed_fp = np.convolve(false_positive_rates, np.ones(window)/window, mode='valid')
    ax.plot(smoothed_fp, 'orange', linewidth=2)
    ax.set_xlabel('Time')
    ax.set_ylabel('False Positives per Round')
    ax.set_title('False Arrests (Innocent People Detained)', fontsize=12)
    ax.grid(True, alpha=0.3)
    ax.fill_between(range(len(smoothed_fp)), smoothed_fp, alpha=0.2, color='orange')

    # Prediction accuracy (the paradox!)
    ax = axes[1][0]
    smoothed_acc = np.convolve(prediction_accuracy, np.ones(window)/window, mode='valid')
    ax.plot(smoothed_acc, 'green', linewidth=2)
    ax.set_xlabel('Time')
    ax.set_ylabel('Apparent Prediction Accuracy')
    ax.set_title('THE PARADOX: Accuracy is Unmeasurable!', fontsize=12)
    ax.grid(True, alpha=0.3)
    ax.annotate('We can never verify prevented crimes\nbecause intervention changes the outcome!',
                xy=(n_steps // 2, smoothed_acc[n_steps // 2] if n_steps // 2 < len(smoothed_acc) else 0.5),
                xytext=(n_steps // 4, 0.3), fontsize=10,
                bbox=dict(boxstyle='round', facecolor='lightyellow'),
                arrowprops=dict(arrowstyle='->'))

    # Feedback radicalization
    ax = axes[1][1]
    ax.hist(base_crime_probs, bins=30, color='purple', alpha=0.7,
            label='After 200 rounds of pre-crime')
    ax.axvline(x=intervention_threshold, color='red', linestyle='--',
               label=f'Intervention threshold ({intervention_threshold})')
    ax.set_xlabel('Crime Probability')
    ax.set_ylabel('Number of Citizens')
    ax.set_title('Radicalization Feedback: Pre-Crime Creates Crime', fontsize=12)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    plt.suptitle('THE MINORITY REPORT PARADOX: Prediction Destroys Its Own Basis',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('demo10_minority_report.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("→ Saved: demo10_minority_report.png")
    print("  Key insight: Pre-crime CANNOT verify its own predictions")
    print("  Interventions alter the futures being predicted (Theorem 4.3)")
    print("  Feedback: arresting potential criminals radicalizes them")
    print()


def demo_golden_man():
    """Demo 3: The Golden Man — pursuit-evasion with precognition."""
    print("=" * 60)
    print("DEMO 3: THE GOLDEN MAN")
    print("Precognitive evasion on a graph (Theorem 4.2)")
    print("=" * 60)

    # Create a grid graph (city streets)
    n = 8
    G = nx.grid_2d_graph(n, n)
    pos = {(i, j): (i, j) for i, j in G.nodes()}

    # Pursuit-evasion: 3 pursuers, 1 evader (Golden Man)
    n_pursuers = 3
    n_simulations = 5
    precog_depths = [0, 2, 4, 8]  # 0 = no precognition

    fig, axes = plt.subplots(2, 2, figsize=(14, 12))
    capture_stats = {}

    for ax_idx, depth in enumerate(precog_depths):
        ax = axes[ax_idx // 2][ax_idx % 2]

        captures = 0
        total_steps = 0
        n_trials = 200

        # Visualize one game
        evader_path = [(n // 2, n // 2)]
        pursuer_paths = [[(np.random.randint(0, n), np.random.randint(0, n))]
                         for _ in range(n_pursuers)]

        for trial in range(n_trials):
            # Initialize positions
            evader = (n // 2, n // 2)
            pursuers = [(np.random.randint(0, n), np.random.randint(0, n))
                        for _ in range(n_pursuers)]

            for step in range(100):
                total_steps += 1

                # Pursuers move greedily toward evader
                new_pursuers = []
                for p in pursuers:
                    neighbors = list(G.neighbors(p))
                    # Move toward evader
                    best = min(neighbors, key=lambda x: abs(x[0] - evader[0]) + abs(x[1] - evader[1]))
                    new_pursuers.append(best)
                pursuers = new_pursuers

                # Check capture
                if evader in pursuers:
                    captures += 1
                    break

                # Evader moves
                neighbors = list(G.neighbors(evader))

                if depth == 0:
                    # Random walk (no precognition)
                    evader = neighbors[np.random.randint(len(neighbors))]
                else:
                    # Precognition: evaluate future positions of pursuers
                    best_score = -float('inf')
                    best_move = neighbors[0]

                    for candidate in neighbors:
                        # Simulate pursuers for 'depth' steps
                        future_pursuers = list(pursuers)
                        score = 0

                        for d in range(min(depth, 5)):
                            new_fp = []
                            for p in future_pursuers:
                                p_neighbors = list(G.neighbors(p))
                                closest = min(p_neighbors,
                                              key=lambda x: abs(x[0] - candidate[0]) + abs(x[1] - candidate[1]))
                                new_fp.append(closest)
                            future_pursuers = new_fp

                            # Score = minimum distance to any pursuer
                            min_dist = min(abs(candidate[0] - p[0]) + abs(candidate[1] - p[1])
                                           for p in future_pursuers)
                            score += min_dist

                        if score > best_score:
                            best_score = score
                            best_move = candidate

                    evader = best_move

                if trial == 0:
                    evader_path.append(evader)
                    for pi in range(n_pursuers):
                        pursuer_paths[pi].append(pursuers[pi])

        capture_rate = captures / n_trials
        capture_stats[depth] = capture_rate

        # Draw the graph and one game
        nx.draw_networkx_edges(G, pos, ax=ax, alpha=0.15, edge_color='gray')

        # Draw evader path
        max_show = min(30, len(evader_path))
        for i in range(max_show - 1):
            t_frac = i / max_show
            ax.plot([evader_path[i][0], evader_path[i + 1][0]],
                    [evader_path[i][1], evader_path[i + 1][1]],
                    'g-', linewidth=2, alpha=0.3 + 0.7 * t_frac)

        # Draw pursuer paths
        for pi in range(n_pursuers):
            max_show_p = min(30, len(pursuer_paths[pi]))
            for i in range(max_show_p - 1):
                ax.plot([pursuer_paths[pi][i][0], pursuer_paths[pi][i + 1][0]],
                        [pursuer_paths[pi][i][1], pursuer_paths[pi][i + 1][1]],
                        'r-', linewidth=1.5, alpha=0.3)

        ax.plot(evader_path[0][0], evader_path[0][1], 'g*',
                markersize=20, label='Golden Man (start)', zorder=5)
        ax.plot(evader_path[min(29, len(evader_path) - 1)][0],
                evader_path[min(29, len(evader_path) - 1)][1], 'go',
                markersize=12, label='Golden Man (end)', zorder=5)

        for pi in range(n_pursuers):
            ax.plot(pursuer_paths[pi][0][0], pursuer_paths[pi][0][1],
                    'rx', markersize=12, zorder=5)

        ax.set_title(f'Precog Depth = {depth}\nCapture Rate: {capture_rate:.1%}',
                     fontsize=12)
        ax.legend(fontsize=8, loc='upper left')
        ax.set_xlim(-0.5, n - 0.5)
        ax.set_ylim(-0.5, n - 0.5)

    plt.suptitle('THE GOLDEN MAN: Precognitive Evasion on a Grid Graph',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('demo11_golden_man.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("→ Saved: demo11_golden_man.png")
    print("  Capture rates by precognition depth:")
    for depth, rate in capture_stats.items():
        print(f"    Depth {depth}: {rate:.1%} capture rate")
    print("  Theorem 4.2: depth ≥ diameter(G) → capture impossible")
    print(f"  Graph diameter = {nx.diameter(G)}, grid size = {n}×{n}")
    print()


def demo_free_will_measure():
    """Demo 4: Free Will Measure under pre-crime surveillance."""
    print("=" * 60)
    print("DEMO 4: THE FREE WILL MEASURE")
    print("How much freedom remains under omniscient surveillance?")
    print("=" * 60)

    # Free will = 1 - I(Action; Prediction) / H(Action)
    # Perfect precognition → free will = 0

    prediction_accuracies = np.linspace(0, 1, 200)

    # Binary action case
    def free_will_binary(accuracy):
        """Free will for binary action space with prediction accuracy p."""
        if accuracy <= 0.5:
            return 1.0  # Random prediction = full free will
        p = accuracy
        # Conditional entropy H(Action | Prediction)
        # H(A|P) = -p*log(p) - (1-p)*log(1-p) if prediction is correct with prob p
        if p == 0 or p == 1:
            h_cond = 0
        else:
            h_cond = -p * np.log2(p) - (1 - p) * np.log2(1 - p)
        # H(Action) = 1 bit (uniform binary)
        h_action = 1.0
        # Free will = H(A|P) / H(A)
        return h_cond / h_action

    def free_will_n_actions(accuracy, n_actions):
        """Free will for n-action space."""
        if accuracy <= 1 / n_actions:
            return 1.0
        p = accuracy
        if p >= 1:
            return 0.0
        # Correct prediction with prob p, uniform over others with prob (1-p)/(n-1)
        h_cond = -p * np.log2(max(p, 1e-10))
        if n_actions > 1 and p < 1:
            other_p = (1 - p) / (n_actions - 1)
            if other_p > 0:
                h_cond -= (n_actions - 1) * other_p * np.log2(max(other_p, 1e-10))
        h_action = np.log2(n_actions)
        return max(0, h_cond / h_action)

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Free will vs prediction accuracy for different action space sizes
    ax = axes[0]
    for n_actions in [2, 4, 8, 16, 100]:
        fw = [free_will_n_actions(p, n_actions) for p in prediction_accuracies]
        ax.plot(prediction_accuracies, fw, linewidth=2,
                label=f'{n_actions} possible actions')

    ax.set_xlabel('Pre-Crime Prediction Accuracy', fontsize=12)
    ax.set_ylabel('Free Will Measure ℱ', fontsize=12)
    ax.set_title('Free Will Decreases with Prediction Accuracy', fontsize=12)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Annotate
    ax.annotate('Perfect precognition:\nFree will = 0',
                xy=(1.0, 0), xytext=(0.6, 0.3), fontsize=10,
                arrowprops=dict(arrowstyle='->', color='red'),
                color='red', fontweight='bold')
    ax.annotate('Random prediction:\nFull free will',
                xy=(0.5, 1.0), xytext=(0.1, 0.7), fontsize=10,
                arrowprops=dict(arrowstyle='->', color='green'),
                color='green', fontweight='bold')

    # Phase diagram: surveillance intensity vs freedom
    ax = axes[1]
    n_citizens = np.linspace(10, 1000, 100)
    n_precogs = np.array([1, 3, 5, 10, 50])

    for n_p in n_precogs:
        # Each precog can monitor ~20 citizens with high accuracy
        coverage = np.minimum(1.0, n_p * 20 / n_citizens)
        avg_free_will = 1 - coverage * 0.95  # 95% accuracy when monitored
        ax.plot(n_citizens, avg_free_will, linewidth=2,
                label=f'{n_p} pre-cogs')

    ax.set_xlabel('Population Size', fontsize=12)
    ax.set_ylabel('Average Free Will ℱ', fontsize=12)
    ax.set_title('Free Will vs. Surveillance Capacity', fontsize=12)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0, 1.1)

    plt.suptitle('FREE WILL MEASURE: Theorem 4.4 — Pre-Crime Eliminates Freedom',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('demo12_free_will.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("→ Saved: demo12_free_will.png")
    print("  Free will measure ℱ = 1 - I(Action; Prediction) / H(Action)")
    print("  Perfect precognition → ℱ = 0 for all citizens (Theorem 4.4)")
    print()


if __name__ == '__main__':
    print()
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║  PRE-COGNITIVE GAME THEORY — THE MINORITY REPORT           ║")
    print("║  'The pre-cogs are never wrong. But occasionally they do   ║")
    print("║   disagree.' — Philip K. Dick                              ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    print()

    demo_precog_advantage()
    demo_minority_report_paradox()
    demo_golden_man()
    demo_free_will_measure()

    print("=" * 60)
    print("ALL PRE-CRIME DEMOS COMPLETE")
    print("=" * 60)
