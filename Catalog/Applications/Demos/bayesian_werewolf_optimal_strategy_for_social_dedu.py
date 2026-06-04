#!/usr/bin/env python3
"""
Bayesian Werewolf: Numerical Demonstrations

Computes villager win probabilities under various strategies for the
social deduction game Werewolf (Mafia). Demonstrates the strategy
dominance theorem and the information value of Bayesian play.
"""

import itertools
import random
from fractions import Fraction
from functools import lru_cache


# ── Exact Win Probability via Recurrence ──────────────────────────────


@lru_cache(maxsize=None)
def win_prob(w: int, v: int, p: Fraction) -> Fraction:
    """
    Villager win probability with w werewolves, v villagers,
    and constant strategy accuracy p (probability of correctly
    identifying a werewolf each day vote).
    
    Recurrence:
      P(0, v) = 1 if v > 0, else 0
      P(w, v) = p * P(w-1, v-1) + (1-p) * P(w, v-2)  if w < v and v > 1
      P(w, v) = 0 if w >= v
    """
    if w == 0:
        return Fraction(1) if v > 0 else Fraction(0)
    if w >= v:
        return Fraction(0)
    if v <= 1:
        return Fraction(0)
    return p * win_prob(w - 1, v - 1, p) + (1 - p) * win_prob(w, v - 2, p)


@lru_cache(maxsize=None)
def win_prob_random(w: int, v: int) -> Fraction:
    """Win probability under random strategy σ(w,v) = w/(w+v)."""
    if w == 0:
        return Fraction(1) if v > 0 else Fraction(0)
    if w >= v:
        return Fraction(0)
    if v <= 1:
        return Fraction(0)
    total = w + v
    sigma = Fraction(w, total)
    return sigma * win_prob_random(w - 1, v - 1) + (1 - sigma) * win_prob_random(w, v - 2)


# ── Demonstration 1: Strategy Dominance ───────────────────────────────

def demo_strategy_dominance():
    """Verify the strategy dominance theorem numerically."""
    print("=" * 60)
    print("STRATEGY DOMINANCE THEOREM VERIFICATION")
    print("If σ₁ ≥ σ₂ pointwise, then P(win | σ₁) ≥ P(win | σ₂)")
    print("=" * 60)
    
    test_cases = [(2, 5), (3, 7), (1, 4), (2, 8), (4, 10)]
    accuracies = [Fraction(i, 10) for i in range(0, 11)]
    
    for w, v in test_cases:
        print(f"\nGame state: {w} wolves, {v} villagers (n={w+v})")
        probs = []
        for p in accuracies:
            prob = win_prob(w, v, p)
            probs.append(float(prob))
            print(f"  σ = {float(p):.1f}: P(win) = {float(prob):.6f}")
        
        # Verify monotonicity
        is_monotone = all(probs[i] <= probs[i + 1] for i in range(len(probs) - 1))
        print(f"  Monotone in σ: {'✓' if is_monotone else '✗ VIOLATION!'}")


# ── Demonstration 2: Random vs Perfect Strategy ──────────────────────

def demo_random_vs_perfect():
    """Compare random and perfect elimination strategies."""
    print("\n" + "=" * 60)
    print("RANDOM vs PERFECT STRATEGY COMPARISON")
    print("=" * 60)
    
    for n in range(4, 16):
        for k in range(1, n // 2 + 1):
            v = n - k
            p_random = win_prob_random(k, v)
            p_perfect = win_prob(k, v, Fraction(1))
            info_value = float(p_perfect - p_random)
            print(f"  n={n:2d}, k={k}: P_random={float(p_random):.4f}, "
                  f"P_perfect={float(p_perfect):.4f} (={p_perfect}), "
                  f"InfoValue={info_value:.4f}")


# ── Demonstration 3: The 7-Player Game ────────────────────────────────

def demo_seven_player():
    """Detailed analysis of the classic 7-player, 2-wolf game."""
    print("\n" + "=" * 60)
    print("CLASSIC 7-PLAYER GAME (k=2, v=5)")
    print("=" * 60)
    
    w, v = 2, 5
    print(f"\nGame: {w} werewolves among {w+v} players")
    print(f"Win condition: eliminate all {w} werewolves before w ≥ v")
    
    p_random = win_prob_random(w, v)
    print(f"\nRandom elimination: P(win) = {p_random} ≈ {float(p_random):.6f}")
    
    # Sweep strategies
    print("\nWin probability vs constant strategy accuracy:")
    for i in range(0, 21):
        p = Fraction(i, 20)
        prob = win_prob(w, v, p)
        bar = "█" * int(float(prob) * 40)
        print(f"  σ={float(p):4.2f}: {float(prob):.4f} {bar}")
    
    # Information value at various accuracy levels
    print("\nInformation value (improvement over random):")
    for i in range(1, 11):
        p = Fraction(i, 10)
        prob = win_prob(w, v, p)
        iv = float(prob - p_random)
        print(f"  σ={float(p):.1f}: InfoValue = {iv:+.4f}")


# ── Demonstration 4: Correct Elimination Dominance ────────────────────

def demo_correct_elim():
    """Verify that correct elimination always leads to a better state."""
    print("\n" + "=" * 60)
    print("CORRECT ELIMINATION DOMINANCE")
    print("P(w+1, v-2) ≤ P(w, v-1) for all valid states")
    print("=" * 60)
    
    violations = 0
    checks = 0
    for w in range(0, 8):
        for v in range(3, 15):
            if w + 1 >= v:
                continue
            for i in range(1, 10):
                p = Fraction(i, 10)
                lhs = win_prob(w + 1, v - 2, p)
                rhs = win_prob(w, v - 1, p)
                checks += 1
                if lhs > rhs:
                    print(f"  VIOLATION: w={w}, v={v}, σ={float(p)}: "
                          f"P({w+1},{v-2})={float(lhs)} > P({w},{v-1})={float(rhs)}")
                    violations += 1
    
    print(f"\n  Checked {checks} cases: {'All passed ✓' if violations == 0 else f'{violations} violations!'}")


# ── Demonstration 5: Monte Carlo Simulation ──────────────────────────

def simulate_game(n: int, k: int, strategy: str = "random",
                  bayesian_accuracy: float = 0.5, num_games: int = 100000) -> float:
    """Simulate Werewolf games and return villager win rate."""
    wins = 0
    for _ in range(num_games):
        # Assign roles
        players = list(range(n))
        wolves = set(random.sample(players, k))
        alive = set(players)
        
        while True:
            w = len(wolves & alive)
            v = len(alive) - w
            
            if w == 0:
                wins += 1
                break
            if w >= v:
                break
            
            # Day: vote to eliminate
            alive_list = list(alive)
            if strategy == "random":
                target = random.choice(alive_list)
            elif strategy == "bayesian":
                # With probability bayesian_accuracy, pick a wolf
                if random.random() < bayesian_accuracy and wolves & alive:
                    target = random.choice(list(wolves & alive))
                else:
                    target = random.choice(alive_list)
            else:
                target = random.choice(alive_list)
            
            alive.discard(target)
            wolves.discard(target)
            
            # Check win after day
            w = len(wolves & alive)
            v = len(alive) - w
            if w == 0:
                wins += 1
                break
            if w >= v:
                break
            
            # Night: wolves kill a villager
            villagers_alive = list(alive - wolves)
            if villagers_alive:
                victim = random.choice(villagers_alive)
                alive.discard(victim)
    
    return wins / num_games


def demo_monte_carlo():
    """Monte Carlo validation of analytical results."""
    print("\n" + "=" * 60)
    print("MONTE CARLO SIMULATION (100,000 games each)")
    print("=" * 60)
    
    configs = [(7, 2), (9, 3), (11, 2), (13, 4), (5, 1)]
    
    for n, k in configs:
        v = n - k
        p_exact = float(win_prob_random(k, v))
        p_sim = simulate_game(n, k, "random")
        print(f"  n={n:2d}, k={k}: Exact={p_exact:.4f}, Simulated={p_sim:.4f}, "
              f"Δ={abs(p_exact - p_sim):.4f}")


if __name__ == "__main__":
    demo_strategy_dominance()
    demo_random_vs_perfect()
    demo_seven_player()
    demo_correct_elim()
    demo_monte_carlo()


#!/usr/bin/env python3
"""
Visualization: Strategy Dominance and Win Probability Landscape

Generates plots showing the relationship between strategy accuracy
and villager win probability across different game configurations.
"""

import matplotlib.pyplot as plt
import matplotlib.cm as cm
import numpy as np
from fractions import Fraction
from functools import lru_cache


@lru_cache(maxsize=None)
def win_prob(w: int, v: int, sigma_num: int, sigma_den: int) -> float:
    """Win probability with caching (using int fractions for hashability)."""
    s = Fraction(sigma_num, sigma_den)
    if w == 0:
        return 1.0 if v > 0 else 0.0
    if w >= v or v <= 1:
        return 0.0
    return float(s) * win_prob(w - 1, v - 1, sigma_num, sigma_den) + \
           float(1 - s) * win_prob(w, v - 2, sigma_num, sigma_den)


def plot_strategy_dominance():
    """Plot win probability vs strategy accuracy for various game sizes."""
    fig, axes = plt.subplots(2, 3, figsize=(15, 10))
    fig.suptitle('Strategy Dominance Theorem: Win Probability vs Accuracy',
                 fontsize=14, fontweight='bold')
    
    configs = [(1, 3), (1, 5), (2, 5), (2, 7), (3, 7), (3, 10)]
    
    for ax, (w, v) in zip(axes.flat, configs):
        sigmas = np.linspace(0, 1, 101)
        probs = []
        for s in sigmas:
            s_frac = Fraction(int(round(s * 1000)), 1000)
            p = win_prob(w, v, s_frac.numerator, s_frac.denominator)
            probs.append(p)
        
        ax.plot(sigmas, probs, 'b-', linewidth=2)
        ax.fill_between(sigmas, 0, probs, alpha=0.15, color='blue')
        
        # Mark random strategy point
        random_sigma = w / (w + v)
        random_prob = win_prob(w, v,
                              Fraction(w, w + v).numerator,
                              Fraction(w, w + v).denominator)
        ax.plot(random_sigma, random_prob, 'ro', markersize=8,
                label=f'Random (σ={random_sigma:.2f})')
        ax.plot(1.0, probs[-1], 'g*', markersize=12,
                label=f'Perfect (P=1)')
        
        ax.set_title(f'w={w}, v={v} (n={w+v})', fontsize=11)
        ax.set_xlabel('Strategy accuracy σ')
        ax.set_ylabel('P(villagers win)')
        ax.set_xlim(0, 1)
        ax.set_ylim(0, 1.05)
        ax.grid(True, alpha=0.3)
        ax.legend(fontsize=8)
    
    plt.tight_layout()
    plt.savefig('strategy_dominance.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved strategy_dominance.png")


def plot_information_value_heatmap():
    """Heatmap of information value across game states."""
    fig, ax = plt.subplots(figsize=(10, 8))
    
    max_w, max_v = 6, 15
    info_values = np.full((max_w, max_v), np.nan)
    
    for w in range(1, max_w + 1):
        for v in range(w + 1, max_v + 1):
            # Info value at σ = 0.7 (moderate Bayesian accuracy)
            p_strategy = win_prob(w, v, 7, 10)
            p_random = win_prob(w, v,
                                Fraction(w, w + v).numerator,
                                Fraction(w, w + v).denominator)
            info_values[w - 1, v - 1] = p_strategy - p_random
    
    im = ax.imshow(info_values, cmap='RdYlGn', aspect='auto',
                   origin='lower', vmin=-0.1, vmax=0.5)
    ax.set_xlabel('Villagers (v)', fontsize=12)
    ax.set_ylabel('Werewolves (w)', fontsize=12)
    ax.set_title('Information Value: P(win|σ=0.7) − P(win|random)',
                 fontsize=13, fontweight='bold')
    
    ax.set_xticks(range(max_v))
    ax.set_xticklabels(range(1, max_v + 1))
    ax.set_yticks(range(max_w))
    ax.set_yticklabels(range(1, max_w + 1))
    
    plt.colorbar(im, ax=ax, label='Information Value')
    plt.tight_layout()
    plt.savefig('information_value_heatmap.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved information_value_heatmap.png")


def plot_phase_transition():
    """Plot the phase transition: critical accuracy vs game ratio w/v."""
    fig, ax = plt.subplots(figsize=(10, 6))
    
    ratios = []
    critical_sigmas_50 = []
    critical_sigmas_25 = []
    
    for w in range(1, 6):
        for v in range(w + 1, 16):
            ratio = w / v
            
            # Find critical σ for 50% win probability
            for i in range(0, 1001):
                s = Fraction(i, 1000)
                if win_prob(w, v, s.numerator, s.denominator) >= 0.5:
                    ratios.append(ratio)
                    critical_sigmas_50.append(float(s))
                    break
            
            # Find critical σ for 25% win probability
            for i in range(0, 1001):
                s = Fraction(i, 1000)
                if win_prob(w, v, s.numerator, s.denominator) >= 0.25:
                    critical_sigmas_25.append((ratio, float(s)))
                    break
    
    ax.scatter(ratios, critical_sigmas_50, c='red', s=40, alpha=0.7,
               label='50% win threshold')
    if critical_sigmas_25:
        r25, s25 = zip(*critical_sigmas_25)
        ax.scatter(r25, s25, c='blue', s=40, alpha=0.7,
                   label='25% win threshold')
    
    ax.set_xlabel('Wolf ratio w/v', fontsize=12)
    ax.set_ylabel('Critical strategy accuracy σ*', fontsize=12)
    ax.set_title('Phase Transition: Minimum Accuracy for Given Win Rate',
                 fontsize=13, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('phase_transition.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved phase_transition.png")


if __name__ == "__main__":
    plot_strategy_dominance()
    plot_information_value_heatmap()
    plot_phase_transition()
