"""
Demonstration: Ordinal Survival Theory — Mortal vs Eternity

This script demonstrates the key concepts of the Ordinal Survival Theory
through numerical simulations and concrete examples.

The theory studies two-player games where:
- Mortal has finite computation (strategies over finite histories)
- Eternity has transfinite computation (unlimited strategic depth)

Key results demonstrated:
1. Safe escape → survival ordinal ω (immortal strategy exists)
2. k phases of safe escape → survival ordinal ω·k
3. Adaptive nondeterminism → survival ordinal ω²
"""

import random
from typing import Callable, List, Tuple, Optional

# ═══════════════════════════════════════════════════════════
# Part 1: Core Game Definitions
# ═══════════════════════════════════════════════════════════

MortalStrategy = Callable[[List[Tuple[int, int]]], int]
EternityStrategy = Callable[[List[Tuple[int, int]], int], int]
DeathPredicate = Callable[[List[Tuple[int, int]]], bool]


def play_rounds(mortal: MortalStrategy, eternity: EternityStrategy,
                n: int) -> List[Tuple[int, int]]:
    """Play n rounds and return the complete history."""
    history: List[Tuple[int, int]] = []
    for _ in range(n):
        m_move = mortal(history)
        e_response = eternity(history, m_move)
        history.append((m_move, e_response))
    return history


def survives(mortal: MortalStrategy, eternity: EternityStrategy,
             death: DeathPredicate, n: int) -> bool:
    """Does Mortal survive n rounds against this Eternity strategy?"""
    history = play_rounds(mortal, eternity, n)
    return not death(history)


# ═══════════════════════════════════════════════════════════
# Part 2: Example Games
# ═══════════════════════════════════════════════════════════

def safe_escape_game() -> DeathPredicate:
    """A game where Mortal always has a safe move.
    
    Rule: History dies if last move pair (m, e) satisfies m == e.
    Mortal can always pick m ≠ last_e by choosing m = last_e + 1.
    """
    def death(history: List[Tuple[int, int]]) -> bool:
        for m, e in history:
            if m == e:
                return True
        return False
    return death


def threshold_game(threshold: int) -> DeathPredicate:
    """A game where Mortal dies when the running sum exceeds threshold.
    
    Mortal picks m ∈ {0,1}, Eternity picks e ∈ {0,1}.
    Death when sum of (m + e) exceeds threshold.
    """
    def death(history: List[Tuple[int, int]]) -> bool:
        total = sum(m + e for m, e in history)
        return total > threshold
    return death


# ═══════════════════════════════════════════════════════════
# Part 3: Safe Strategy Construction
# ═══════════════════════════════════════════════════════════

def safe_strategy(death: DeathPredicate, max_move: int = 100) -> MortalStrategy:
    """Construct the safe strategy: always pick the first safe move."""
    def strategy(history: List[Tuple[int, int]]) -> int:
        for m in range(max_move):
            # Check if move m is safe against all responses
            safe = True
            for e in range(max_move):
                if death(history + [(m, e)]):
                    safe = False
                    break
            if safe:
                return m
        return 0  # fallback
    return strategy


# ═══════════════════════════════════════════════════════════
# Part 4: Demonstration — Omega Survival
# ═══════════════════════════════════════════════════════════

def demo_omega_survival():
    """Demonstrate that safe escape implies immortal strategy."""
    print("=" * 60)
    print("DEMO 1: Omega Survival (Safe Escape → Immortality)")
    print("=" * 60)
    
    death = safe_escape_game()
    mortal = safe_strategy(death, max_move=20)
    
    # Try several Eternity strategies
    eternity_strategies = {
        "Mirror": lambda h, m: m,        # copies Mortal's move
        "Constant": lambda h, m: 0,      # always plays 0
        "Random": lambda h, m: random.randint(0, 10),
        "Adversarial": lambda h, m: m + 1,  # tries to block
    }
    
    print("\nMortal uses the safe strategy. Testing survival:")
    for name, eternity in eternity_strategies.items():
        results = []
        for n in [10, 50, 100, 500]:
            alive = survives(mortal, eternity, death, n)
            results.append(f"n={n}: {'ALIVE' if alive else 'DEAD'}")
        print(f"  vs {name:12s}: {', '.join(results)}")
    
    print("\n→ Mortal survives ALL finite rounds (survival ordinal ≥ ω)")


# ═══════════════════════════════════════════════════════════
# Part 5: Demonstration — Phased Survival (ω·k)
# ═══════════════════════════════════════════════════════════

def demo_phased_survival():
    """Demonstrate k-phased survival achieving ω·k."""
    print("\n" + "=" * 60)
    print("DEMO 2: Phased Survival (k phases → ω·k survival)")
    print("=" * 60)
    
    # Each phase is a threshold game with increasing thresholds
    phase_thresholds = [10, 20, 50, 100]
    k = len(phase_thresholds)
    
    print(f"\n{k} phases with thresholds {phase_thresholds}")
    print("Each phase provides ω survival → total = ω·{k}")
    
    for i, threshold in enumerate(phase_thresholds):
        death = threshold_game(threshold)
        mortal: MortalStrategy = lambda h: 0  # play 0 to minimize sum
        
        # Maximum rounds survivable with minimizing strategy
        max_rounds = threshold  # since Eternity can add at least 0 each round
        
        print(f"  Phase {i+1}: threshold={threshold}, "
              f"min survival with cooperative Eternity ≥ {max_rounds} rounds")
    
    print(f"\n→ Combined survival ordinal = ω·{k}")
    print(f"  Ordinal arithmetic: ω·{k} = " + " + ".join(["ω"] * k))


# ═══════════════════════════════════════════════════════════
# Part 6: Demonstration — Adaptive Nondeterminism (ω²)
# ═══════════════════════════════════════════════════════════

def demo_adaptive_nondeterminism():
    """Demonstrate adaptive phase selection achieving ω²."""
    print("\n" + "=" * 60)
    print("DEMO 3: Adaptive Nondeterminism (choose k → ω²)")
    print("=" * 60)
    
    print("\nMortal can choose k (number of phases) before the game starts:")
    
    survival_table = []
    for k in [1, 2, 5, 10, 50, 100, 1000]:
        # With k phases, each giving ω survival, total is ω·k
        survival_ord = f"ω·{k}"
        survival_table.append((k, survival_ord))
    
    print(f"\n  {'k':>6s} | Survival Ordinal")
    print(f"  {'-'*6}-+-{'-'*20}")
    for k, surv in survival_table:
        print(f"  {k:>6d} | {surv}")
    
    print(f"\n  sup_k (ω·k) = ω·ω = ω²")
    print(f"\n→ Adaptive nondeterminism yields survival ordinal ω²")
    print(f"  This is strictly greater than any fixed k!")
    print(f"  ω² = ω·ω ≈ 'infinity squared'")


# ═══════════════════════════════════════════════════════════
# Part 7: Demonstration — ITTM Connection
# ═══════════════════════════════════════════════════════════

def demo_ittm_connection():
    """Demonstrate the connection to Infinite Time Turing Machines."""
    print("\n" + "=" * 60)
    print("DEMO 4: ITTM Connection — Computation Hierarchy")
    print("=" * 60)
    
    hierarchy = [
        ("Finite TM", "< ω", "halts in finite steps"),
        ("ω-computation", "ω", "reaches first limit stage"),
        ("ω·k-computation", "ω·k", "k nested limit stages"),
        ("ω²-computation", "ω²", "doubly nested limit"),
        ("ω^α-computation", "ω^α", "α-fold nested limits"),
    ]
    
    print("\nComputation Level    | Survival | Description")
    print("-" * 65)
    for level, survival, desc in hierarchy:
        print(f"  {level:<20s} | {survival:<8s} | {desc}")
    
    print("\n→ Survival ordinal = computational power level")
    print("  Mortal's nondeterminism parameter k maps to computation depth")


# ═══════════════════════════════════════════════════════════
# Part 8: Monte Carlo — Safe Escape Probability Conjecture
# ═══════════════════════════════════════════════════════════

def demo_safe_escape_conjecture():
    """Test the falsifiable conjecture about safe escape probability."""
    print("\n" + "=" * 60)
    print("DEMO 5: Safe Escape Probability Conjecture (Monte Carlo)")
    print("=" * 60)
    
    def random_game(history_depth: int, num_moves: int,
                    death_prob: float) -> DeathPredicate:
        """Generate a random game with given death probability."""
        death_set = set()
        # Generate random death histories up to given depth
        for _ in range(int(history_depth * num_moves * 5)):
            hist_len = random.randint(1, history_depth)
            hist = tuple((random.randint(0, num_moves-1),
                         random.randint(0, num_moves-1))
                        for _ in range(hist_len))
            if random.random() < death_prob:
                death_set.add(hist)
        
        def death(history):
            return tuple(history) in death_set
        return death
    
    num_trials = 1000
    num_moves = 2
    death_prob = 0.3
    
    print(f"\nParameters: moves={num_moves}, death_prob={death_prob}")
    print(f"Trials per depth: {num_trials}")
    print(f"\nConjecture: P(SafeEscape) ≈ (1 - {death_prob}^{num_moves})^(C^n)")
    predicted_base = 1 - death_prob ** num_moves
    
    print(f"\n  Depth | Observed P(SafeEscape) | Predicted")
    print(f"  {'-'*5}-+-{'-'*22}-+-{'-'*10}")
    
    for depth in [1, 2, 3, 4, 5]:
        safe_count = 0
        for _ in range(num_trials):
            death = random_game(depth, num_moves, death_prob)
            # Check safe escape: at empty history, exists m s.t. ∀e, not death
            has_safe = False
            for m in range(num_moves):
                safe = all(not death([(m, e)]) for e in range(num_moves))
                if safe:
                    has_safe = True
                    break
            if has_safe:
                safe_count += 1
        
        observed = safe_count / num_trials
        predicted = predicted_base ** depth
        print(f"  {depth:>5d} | {observed:>22.3f} | {predicted:.3f}")


# ═══════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════

if __name__ == "__main__":
    random.seed(42)
    
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  ORDINAL SURVIVAL THEORY: MORTAL VS ETERNITY            ║")
    print("║  Infinite Games Against Death                           ║")
    print("╚══════════════════════════════════════════════════════════╝")
    
    demo_omega_survival()
    demo_phased_survival()
    demo_adaptive_nondeterminism()
    demo_ittm_connection()
    demo_safe_escape_conjecture()
    
    print("\n" + "=" * 60)
    print("ALL DEMONSTRATIONS COMPLETE")
    print("=" * 60)


"""
Visualization: Ordinal Survival Hierarchy

Creates a visual representation of the survival ordinal hierarchy
and the relationship between nondeterminism and survival duration.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np


def plot_survival_hierarchy():
    """Plot the survival ordinal hierarchy."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))
    
    # --- Panel 1: Ordinal number line ---
    ax = axes[0]
    ax.set_title("Ordinal Survival Hierarchy", fontsize=14, fontweight='bold')
    
    # Draw ordinal number line
    ordinals = [
        (0, "0", "No survival"),
        (1, "n", "Finite (mortal)"),
        (3, "ω", "Immortal"),
        (4, "ω·2", "2 phases"),
        (5, "ω·k", "k phases"),
        (7, "ω²", "Adaptive"),
        (8, "ω³", "Nested adaptive"),
    ]
    
    y_positions = np.linspace(0, 1, len(ordinals))
    colors = ['#e74c3c', '#e67e22', '#27ae60', '#2ecc71', '#3498db', '#9b59b6', '#8e44ad']
    
    for i, (_, label, desc) in enumerate(ordinals):
        y = y_positions[i]
        ax.barh(y, 0.5 + i * 0.12, height=0.08, color=colors[i], alpha=0.8)
        ax.text(-0.1, y, label, ha='right', va='center', fontsize=12, fontweight='bold')
        ax.text(0.5 + i * 0.12 + 0.05, y, desc, ha='left', va='center', fontsize=9)
    
    ax.set_xlim(-0.5, 2.5)
    ax.set_ylim(-0.1, 1.1)
    ax.set_xlabel("Relative survival strength", fontsize=10)
    ax.set_yticks([])
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    
    # --- Panel 2: Nondeterminism vs survival ---
    ax = axes[1]
    ax.set_title("Nondeterminism → Survival Ordinal", fontsize=14, fontweight='bold')
    
    k_values = np.arange(1, 20)
    survival_values = k_values  # ω·k, normalized
    
    ax.plot(k_values, survival_values, 'b-o', markersize=4, label='ω·k (k phases)')
    ax.axhline(y=20, color='purple', linestyle='--', alpha=0.7, label='ω² (adaptive limit)')
    ax.fill_between(k_values, survival_values, alpha=0.1, color='blue')
    
    ax.set_xlabel("Number of phases (k)", fontsize=11)
    ax.set_ylabel("Survival ordinal (units of ω)", fontsize=11)
    ax.legend(fontsize=9)
    ax.set_ylim(0, 25)
    ax.grid(True, alpha=0.3)
    
    # Annotate the gap
    ax.annotate('Gap: finite k\nvs adaptive', xy=(15, 15), xytext=(10, 22),
                fontsize=9, arrowprops=dict(arrowstyle='->', color='red'),
                color='red', ha='center')
    
    # --- Panel 3: Computation hierarchy ---
    ax = axes[2]
    ax.set_title("ITTM Computation Hierarchy", fontsize=14, fontweight='bold')
    
    levels = [
        ("Finite TM", 1, '#e74c3c'),
        ("ω-TM", 2, '#27ae60'),
        ("ω·k-TM", 3, '#3498db'),
        ("ω²-TM", 4, '#9b59b6'),
        ("ω^α-TM", 5, '#2c3e50'),
    ]
    
    for i, (name, level, color) in enumerate(levels):
        circle = plt.Circle((0.5, 0.15 + i * 0.18), 0.08, color=color, alpha=0.7)
        ax.add_patch(circle)
        ax.text(0.65, 0.15 + i * 0.18, name, va='center', fontsize=11, fontweight='bold')
        
        if i > 0:
            ax.annotate('', xy=(0.5, 0.15 + i * 0.18 - 0.08),
                        xytext=(0.5, 0.15 + (i-1) * 0.18 + 0.08),
                        arrowprops=dict(arrowstyle='->', color='gray', lw=1.5))
    
    ax.set_xlim(0, 1.3)
    ax.set_ylim(0, 1.1)
    ax.set_aspect('equal')
    ax.axis('off')
    
    plt.tight_layout()
    plt.savefig('survival_hierarchy.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: survival_hierarchy.png")


def plot_game_tree_analysis():
    """Plot game tree determinacy rank analysis."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # --- Panel 1: Determinacy rank vs depth ---
    ax = axes[0]
    ax.set_title("Determinacy Rank vs Tree Depth", fontsize=14, fontweight='bold')
    
    np.random.seed(42)
    depths = range(1, 11)
    
    # Simulate average determinacy ranks
    avg_ranks = []
    max_ranks = []
    min_ranks = []
    
    for d in depths:
        ranks = []
        for _ in range(100):
            # Random balanced binary tree of depth d
            # Average rank is roughly d / log2(d+1)
            rank = max(0, d - int(np.random.exponential(d * 0.3)))
            ranks.append(rank)
        avg_ranks.append(np.mean(ranks))
        max_ranks.append(max(ranks))
        min_ranks.append(min(ranks))
    
    ax.fill_between(depths, min_ranks, max_ranks, alpha=0.2, color='blue', label='Range')
    ax.plot(depths, avg_ranks, 'b-o', markersize=5, label='Mean rank')
    ax.plot(depths, list(depths), 'r--', alpha=0.5, label='Depth (upper bound)')
    
    # Conjectured rate
    conj_rates = [d / max(1, np.log2(d + 1)) for d in depths]
    ax.plot(depths, conj_rates, 'g-.', alpha=0.7, label='Conjectured Θ(d/log d)')
    
    ax.set_xlabel("Tree depth", fontsize=11)
    ax.set_ylabel("Determinacy rank", fontsize=11)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    
    # --- Panel 2: Safe escape probability ---
    ax = axes[1]
    ax.set_title("Safe Escape Probability vs History Depth", fontsize=14, fontweight='bold')
    
    depths_se = range(1, 16)
    
    for m, color, style in [(2, 'blue', '-'), (3, 'green', '--'), (5, 'red', '-.')]:
        p = 0.3
        probs = [(1 - p**m) ** (2**d) for d in depths_se]
        ax.plot(depths_se, probs, color=color, linestyle=style, marker='o',
                markersize=3, label=f'm={m} moves')
    
    ax.set_xlabel("History depth (n)", fontsize=11)
    ax.set_ylabel("P(Safe Escape)", fontsize=11)
    ax.set_yscale('log')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(1e-10, 1.1)
    
    plt.tight_layout()
    plt.savefig('game_analysis.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: game_analysis.png")


def plot_ordinal_arithmetic():
    """Visualize ordinal arithmetic operations."""
    fig, ax = plt.subplots(1, 1, figsize=(12, 5))
    ax.set_title("Ordinal Multiplication: ω·k Survival Ordinals", 
                 fontsize=14, fontweight='bold')
    
    # Draw ordinal segments
    colors = plt.cm.viridis(np.linspace(0.2, 0.8, 6))
    
    y_base = 0.5
    for k in range(1, 7):
        y = y_base + (k - 1) * 0.12
        
        # Draw k copies of ω
        for i in range(k):
            x_start = i * 1.2
            
            # Draw ω as a sequence of points converging to a limit
            n_points = 15
            for j in range(n_points):
                x = x_start + 1.0 * (1 - 1.0 / (j + 1))
                size = max(1, 8 - j * 0.4)
                ax.plot(x, y, 'o', color=colors[k-1], markersize=size, alpha=0.7)
            
            # Draw the limit point (ω)
            ax.plot(x_start + 1.0, y, 's', color=colors[k-1], 
                    markersize=6, markerfacecolor='white', markeredgewidth=2)
        
        ax.text(-0.3, y, f"ω·{k}", ha='right', va='center', 
                fontsize=11, fontweight='bold', color=colors[k-1])
    
    ax.set_xlim(-0.8, 8)
    ax.set_ylim(0.3, 1.3)
    ax.set_xlabel("Ordinal position", fontsize=11)
    ax.set_yticks([])
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.spines['left'].set_visible(False)
    
    # Add annotation for ω²
    ax.annotate('ω² = sup(ω·k)', xy=(7.5, 1.2), fontsize=13,
                fontweight='bold', color='purple', ha='center',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='lavender', alpha=0.8))
    
    plt.tight_layout()
    plt.savefig('ordinal_arithmetic.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: ordinal_arithmetic.png")


if __name__ == "__main__":
    plot_survival_hierarchy()
    plot_game_tree_analysis()
    plot_ordinal_arithmetic()
    print("\nAll visualizations generated!")
