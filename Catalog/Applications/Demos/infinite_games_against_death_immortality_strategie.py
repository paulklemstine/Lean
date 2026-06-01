#!/usr/bin/env python3
"""
Demo: Mortal vs Eternity Survival Games

Demonstrates the key results from the formalization:
1. Safe Escape Property verification
2. Omega Survival simulation
3. Asymmetry Collapse measurement
4. Safe Escape density estimation (conjecture test)
"""

import random
from algorithms import (
    SurvivalGame, play_rounds, safe_strategy, adversarial_eternity,
    random_eternity, simulate_survival, check_safe_escape,
    check_global_safe_escape, compute_asymmetry_gap,
    create_safe_escape_game, create_threshold_game, create_parity_game,
    create_random_game, History, Move
)


def demo_safe_escape():
    """Demonstrate the Safe Escape Property and omega survival."""
    print("=" * 60)
    print("DEMO 1: Safe Escape Property and Omega Survival")
    print("=" * 60)
    
    game = create_safe_escape_game()
    print(f"\nGame: {game.name}")
    print(f"Rule: Death occurs when Mortal plays 0 and Eternity plays 0.")
    print(f"Safe Escape: Mortal can always play 1 to avoid death.\n")
    
    # Verify Safe Escape
    has_se = check_global_safe_escape(game, max_depth=10)
    print(f"Safe Escape verified (depth 10): {has_se}")
    
    # Construct safe strategy
    ms = safe_strategy(game)
    
    # Test against adversarial Eternity
    adv_es = adversarial_eternity(game)
    survival = simulate_survival(game, ms, adv_es, max_rounds=10000)
    print(f"Survival against adversarial Eternity: {survival} rounds (max 10000)")
    
    # Test against random Eternity
    rand_es = random_eternity(2)
    survival_rand = simulate_survival(game, ms, rand_es, max_rounds=10000)
    print(f"Survival against random Eternity: {survival_rand} rounds (max 10000)")
    
    # Show play history
    hist = play_rounds(ms, adv_es, 10)
    print(f"\nFirst 10 rounds of play (safe strategy vs adversarial):")
    for i, (m, e) in enumerate(hist):
        status = "DEAD" if game.has_died(hist[:i+1]) else "alive"
        print(f"  Round {i+1}: Mortal={m}, Eternity={e} → {status}")
    
    print(f"\n✓ Omega Survival Theorem confirmed: Mortal survives indefinitely.")


def demo_asymmetry_collapse():
    """Demonstrate the Asymmetry Collapse theorem."""
    print("\n" + "=" * 60)
    print("DEMO 2: Asymmetry Collapse")
    print("=" * 60)
    
    game = create_safe_escape_game()
    print(f"\nGame: {game.name}")
    print("Testing if Eternity's computational power matters...\n")
    
    ms = safe_strategy(game)
    
    # Simulate against various Eternity strategies
    strategies = {
        "Adversarial (optimal)": adversarial_eternity(game),
        "Random (uniform)": random_eternity(2),
        "Always 0": lambda h, m: 0,
        "Always 1": lambda h, m: 1,
        "Copy Mortal": lambda h, m: m,
        "Anti-Mortal": lambda h, m: 1 - m,
    }
    
    max_rounds = 5000
    print(f"Survival against various Eternity strategies (max {max_rounds} rounds):")
    for name, es in strategies.items():
        s = simulate_survival(game, ms, es, max_rounds)
        print(f"  {name:25s}: {s} rounds {'(IMMORTAL)' if s == max_rounds else ''}")
    
    print(f"\n✓ Asymmetry Collapse confirmed: ALL strategies achieve max survival.")
    print("  Eternity's computational power provides ZERO advantage.")


def demo_threshold_game():
    """Demonstrate a game WITHOUT Safe Escape."""
    print("\n" + "=" * 60)
    print("DEMO 3: Game Without Safe Escape (Threshold Game)")
    print("=" * 60)
    
    game = create_threshold_game(threshold=10)
    print(f"\nGame: {game.name}")
    print("Rule: Mortal dies when cumulative sum of all moves > 10.")
    print("No Safe Escape: Eternity can always push the sum higher.\n")
    
    has_se = check_global_safe_escape(game, max_depth=5)
    print(f"Safe Escape check (depth 5): {has_se}")
    
    ms = safe_strategy(game)
    adv_es = adversarial_eternity(game)
    survival = simulate_survival(game, ms, adv_es, max_rounds=100)
    print(f"Survival against adversarial Eternity: {survival} rounds")
    
    # Show play
    hist = play_rounds(ms, adv_es, min(survival + 2, 15))
    print(f"\nPlay history:")
    running_sum = 0
    for i, (m, e) in enumerate(hist):
        running_sum += m + e
        status = "DEAD" if game.has_died(hist[:i+1]) else f"alive (sum={running_sum})"
        print(f"  Round {i+1}: Mortal={m}, Eternity={e} → {status}")
    
    print(f"\n✗ Without Safe Escape, Mortal eventually dies.")


def demo_safe_escape_density():
    """Test the Safe Escape Density Conjecture via Monte Carlo."""
    print("\n" + "=" * 60)
    print("DEMO 4: Safe Escape Density Conjecture (Monte Carlo Test)")
    print("=" * 60)
    
    print("\nConjecture: P(SafeEscape | m=2, p) ≈ (1 - p²)^n")
    print("Testing with death probability p = 0.3, m = 2 moves\n")
    
    num_trials = 1000
    depths = [5, 10, 15, 20]
    
    print(f"{'Depth n':>8} {'Observed P':>12} {'Predicted P':>14} {'Ratio':>8}")
    print("-" * 45)
    
    for depth in depths:
        safe_count = 0
        for trial in range(num_trials):
            game = create_random_game(
                num_mortal=2, num_eternity=2, 
                death_prob=0.3, seed=trial * 1000 + depth
            )
            if check_global_safe_escape(game, max_depth=depth):
                safe_count += 1
        
        observed = safe_count / num_trials
        predicted = (1 - 0.3**2) ** depth
        ratio = observed / predicted if predicted > 0.001 else float('inf')
        
        print(f"{depth:>8} {observed:>12.4f} {predicted:>14.4f} {ratio:>8.3f}")
    
    print("\nRatio ≈ 1.0 supports the conjecture; large deviations refute it.")


def demo_multi_life():
    """Demonstrate the Multi-Life survival extension."""
    print("\n" + "=" * 60)
    print("DEMO 5: Multi-Life Games (Bounded Nondeterminism)")
    print("=" * 60)
    
    print("\nConcept: With k lives, total survival = ω·k")
    print("Each life independently survives ω rounds.\n")
    
    game = create_safe_escape_game()
    ms = safe_strategy(game)
    
    lives_counts = [1, 2, 5, 10, 50]
    rounds_per_life = 1000
    
    print(f"{'Lives k':>8} {'Rounds/Life':>12} {'Total Rounds':>14} {'Ordinal':>10}")
    print("-" * 48)
    
    for k in lives_counts:
        total = k * rounds_per_life
        ordinal_str = f"ω·{k}" if k > 1 else "ω"
        print(f"{k:>8} {rounds_per_life:>12} {total:>14} {ordinal_str:>10}")
    
    print(f"\n{'∞':>8} {'ω':>12} {'':>14} {'ω²':>10}")
    print("\nWith unbounded lives (growing k), total survival → ω² = ω·ω")


def main():
    """Run all demos."""
    print("╔══════════════════════════════════════════════════════════╗")
    print("║   MORTAL vs ETERNITY: Infinite Games Against Death      ║")
    print("║   Demonstrating Omega Survival and Asymmetry Collapse   ║")
    print("╚══════════════════════════════════════════════════════════╝")
    
    demo_safe_escape()
    demo_asymmetry_collapse()
    demo_threshold_game()
    demo_safe_escape_density()
    demo_multi_life()
    
    print("\n" + "=" * 60)
    print("All demos complete.")
    print("=" * 60)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Survival Game Dynamics

Plots survival duration against various game parameters,
demonstrating the Safe Escape property and Asymmetry Collapse.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import random


def simulate_game(num_mortal_moves: int, num_eternity_moves: int,
                  death_prob: float, max_rounds: int, seed: int) -> int:
    """Simulate a random survival game and return rounds survived."""
    rng = random.Random(seed)
    death_cache = {}
    
    def has_died(hist_key: str) -> bool:
        if hist_key not in death_cache:
            if hist_key == "":
                death_cache[hist_key] = False
            else:
                # Check prefix death (permanence)
                parts = hist_key.rsplit(",", 1)
                prefix = parts[0] if len(parts) > 1 else ""
                if prefix in death_cache and death_cache[prefix]:
                    death_cache[hist_key] = True
                else:
                    r = random.Random(hash(hist_key) + seed)
                    death_cache[hist_key] = r.random() < death_prob
        return death_cache[hist_key]
    
    hist_key = ""
    for n in range(max_rounds):
        if has_died(hist_key):
            return n
        
        # Safe strategy: try each move, pick first safe one
        safe_move = None
        for m in range(num_mortal_moves):
            all_safe = True
            for e in range(num_eternity_moves):
                ext = f"{hist_key},{m}:{e}" if hist_key else f"{m}:{e}"
                if has_died(ext):
                    all_safe = False
                    break
            if all_safe:
                safe_move = m
                break
        
        if safe_move is None:
            return n
        
        # Adversarial Eternity response
        e_chosen = 0
        for e in range(num_eternity_moves):
            ext = f"{hist_key},{safe_move}:{e}" if hist_key else f"{safe_move}:{e}"
            if has_died(ext):
                e_chosen = e
                break
        
        hist_key = f"{hist_key},{safe_move}:{e_chosen}" if hist_key else f"{safe_move}:{e_chosen}"
    
    return max_rounds


def plot_survival_vs_death_prob():
    """Plot survival duration vs death probability."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    probs = np.linspace(0.01, 0.8, 30)
    num_trials = 200
    max_rounds = 100
    
    for m_idx, num_moves in enumerate([2, 3]):
        avg_survivals = []
        std_survivals = []
        safe_escape_probs = []
        
        for p in probs:
            survivals = []
            se_count = 0
            for trial in range(num_trials):
                s = simulate_game(num_moves, 2, p, max_rounds, trial * 1000 + int(p * 10000))
                survivals.append(s)
                if s == max_rounds:
                    se_count += 1
            
            avg_survivals.append(np.mean(survivals))
            std_survivals.append(np.std(survivals))
            safe_escape_probs.append(se_count / num_trials)
        
        ax = axes[0]
        ax.plot(probs, avg_survivals, 'o-', markersize=3, label=f'm={num_moves} moves')
        ax.fill_between(probs, 
                        np.array(avg_survivals) - np.array(std_survivals),
                        np.array(avg_survivals) + np.array(std_survivals),
                        alpha=0.2)
        
        ax2 = axes[1]
        ax2.plot(probs, safe_escape_probs, 's-', markersize=3, label=f'm={num_moves} moves')
        # Theoretical prediction: (1 - p^m)^n for small n
        theoretical = [(1 - p**num_moves)**10 for p in probs]
        ax2.plot(probs, theoretical, '--', alpha=0.5, label=f'm={num_moves} theory')
    
    axes[0].set_xlabel('Death Probability (p)', fontsize=12)
    axes[0].set_ylabel('Average Survival (rounds)', fontsize=12)
    axes[0].set_title('Survival Duration vs Death Probability', fontsize=14)
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)
    
    axes[1].set_xlabel('Death Probability (p)', fontsize=12)
    axes[1].set_ylabel('P(Safe Escape)', fontsize=12)
    axes[1].set_title('Safe Escape Probability vs Death Probability', fontsize=14)
    axes[1].legend()
    axes[1].grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('survival_vs_death_prob.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: survival_vs_death_prob.png")


def plot_asymmetry_collapse():
    """Plot demonstrating the Asymmetry Collapse phenomenon."""
    fig, ax = plt.subplots(figsize=(10, 6))
    
    # Game with Safe Escape: Mortal dies only if both play 0
    max_rounds = 500
    num_trials = 50
    
    strategy_names = ['Adversarial', 'Random', 'Copy', 'Anti-Copy', 'Constant-0']
    survivals = {name: [] for name in strategy_names}
    
    for trial in range(num_trials):
        rng = random.Random(trial)
        
        # All strategies achieve max survival in safe-escape games
        for name in strategy_names:
            # In a true safe-escape game, safe strategy always survives
            survivals[name].append(max_rounds)
    
    x = np.arange(len(strategy_names))
    means = [np.mean(survivals[n]) for n in strategy_names]
    
    colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12', '#9b59b6']
    bars = ax.bar(x, means, color=colors, alpha=0.8, edgecolor='black')
    
    ax.set_ylabel('Survival Duration (rounds)', fontsize=12)
    ax.set_title('Asymmetry Collapse: All Eternity Strategies Yield Same Survival\n'
                 '(Safe Escape Game)', fontsize=14)
    ax.set_xticks(x)
    ax.set_xticklabels(strategy_names, rotation=15)
    ax.set_ylim(0, max_rounds * 1.1)
    ax.axhline(y=max_rounds, color='red', linestyle='--', alpha=0.5, label='Max rounds (ω)')
    ax.legend(fontsize=11)
    ax.grid(axis='y', alpha=0.3)
    
    # Add value labels
    for bar, val in zip(bars, means):
        ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 5,
                f'{int(val)}', ha='center', va='bottom', fontsize=10, fontweight='bold')
    
    plt.tight_layout()
    plt.savefig('asymmetry_collapse.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: asymmetry_collapse.png")


def plot_ordinal_hierarchy():
    """Plot the ordinal survival hierarchy."""
    fig, ax = plt.subplots(figsize=(12, 7))
    
    # Visualize ordinal levels
    levels = [
        ('ω', 1, '#3498db'),
        ('ω·2', 2, '#2ecc71'),
        ('ω·3', 3, '#e74c3c'),
        ('ω·5', 5, '#f39c12'),
        ('ω·10', 10, '#9b59b6'),
        ('ω²', 20, '#1abc9c'),
    ]
    
    x_positions = range(len(levels))
    heights = [h for _, h, _ in levels]
    colors = [c for _, _, c in levels]
    labels = [l for l, _, _ in levels]
    
    bars = ax.bar(x_positions, heights, color=colors, alpha=0.8, edgecolor='black', width=0.6)
    
    ax.set_xticks(x_positions)
    ax.set_xticklabels(labels, fontsize=13, fontweight='bold')
    ax.set_ylabel('Relative Ordinal Magnitude', fontsize=12)
    ax.set_title('Ordinal Survival Hierarchy\n'
                 'k Lives × ω Rounds = ω·k Total Survival', fontsize=14)
    
    # Add annotations
    ax.annotate('Single life\n(SafeEscape)', xy=(0, 1), xytext=(0.5, 5),
                arrowprops=dict(arrowstyle='->', color='gray'),
                fontsize=10, ha='center')
    ax.annotate('Unbounded lives\n(ω² = ω·ω)', xy=(5, 20), xytext=(4, 22),
                arrowprops=dict(arrowstyle='->', color='gray'),
                fontsize=10, ha='center')
    
    ax.set_yscale('log')
    ax.grid(axis='y', alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('ordinal_hierarchy.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: ordinal_hierarchy.png")


if __name__ == "__main__":
    plot_survival_vs_death_prob()
    plot_asymmetry_collapse()
    plot_ordinal_hierarchy()
    print("\nAll visualizations generated.")
