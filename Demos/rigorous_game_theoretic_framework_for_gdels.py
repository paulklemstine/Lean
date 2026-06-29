#!/usr/bin/env python3
"""
Gödel's Casino: Epistemic Game Theory — Interactive Demo

Demonstrates the key theorems from the formalized framework:
1. Oracle Complement Conservation
2. Regret Decomposition
3. Oracle Inclusion-Exclusion
4. Cascade Profit Monotonicity
5. Calibration-Profit Theorem
"""

import random
from dataclasses import dataclass
from typing import List, Tuple


@dataclass
class CasinoRound:
    """A round in Gödel's Casino."""
    truth: bool
    decidable: bool


def selective_payoff(round: CasinoRound) -> int:
    """Selective strategy payoff: bet correctly if decidable, abstain otherwise."""
    if round.decidable:
        return 1  # Always correct when decidable
    return 0  # Abstain


def omniscient_payoff(round: CasinoRound) -> int:
    """Omniscient strategy always gets +1."""
    return 1


def blind_payoff(round: CasinoRound, guess: bool = True) -> int:
    """Blind strategy guesses without oracle information."""
    return 1 if round.truth == guess else -1


def total_profit(rounds: List[CasinoRound], strategy) -> int:
    return sum(strategy(r) for r in rounds)


def demo_complement_conservation():
    """Demonstrate: profit(O) + profit(¬O) = n"""
    print("=" * 60)
    print("THEOREM 1: Oracle Complement Conservation")
    print("  profit(O) + profit(¬O) = n")
    print("=" * 60)

    n = 20
    rounds = [CasinoRound(truth=random.choice([True, False]),
                           decidable=random.choice([True, False]))
              for _ in range(n)]

    # Complement rounds: swap decidability
    complement_rounds = [CasinoRound(truth=r.truth, decidable=not r.decidable)
                         for r in rounds]

    profit_O = total_profit(rounds, selective_payoff)
    profit_not_O = total_profit(complement_rounds, selective_payoff)

    print(f"  n = {n}")
    print(f"  Decidable rounds: {sum(1 for r in rounds if r.decidable)}")
    print(f"  profit(O)   = {profit_O}")
    print(f"  profit(¬O)  = {profit_not_O}")
    print(f"  Sum         = {profit_O + profit_not_O}")
    print(f"  n           = {n}")
    print(f"  ✓ Conservation: {profit_O + profit_not_O == n}")
    print()


def demo_regret_decomposition():
    """Demonstrate: regret = decidable_mistakes + undecidable_exposure"""
    print("=" * 60)
    print("THEOREM 2: Regret Decomposition")
    print("  regret = decidable_mistakes + undecidable_exposure")
    print("=" * 60)

    n = 20
    rounds = [CasinoRound(truth=random.choice([True, False]),
                           decidable=random.choice([True, False]))
              for _ in range(n)]

    # Use a random strategy (not selective)
    def random_strategy(r):
        guess = random.choice([True, False])
        return 1 if r.truth == guess else -1

    payoffs = [random_strategy(r) for r in rounds]
    total = sum(payoffs)
    regret = n - total  # omniscient gets n

    dec_mistakes = sum(1 - p for r, p in zip(rounds, payoffs) if r.decidable)
    undec_exposure = sum(1 - p for r, p in zip(rounds, payoffs) if not r.decidable)

    print(f"  n = {n}")
    print(f"  Random strategy profit = {total}")
    print(f"  Total regret           = {regret}")
    print(f"  Decidable mistakes     = {dec_mistakes}")
    print(f"  Undecidable exposure   = {undec_exposure}")
    print(f"  Sum of components      = {dec_mistakes + undec_exposure}")
    print(f"  ✓ Decomposition: {regret == dec_mistakes + undec_exposure}")
    print()

    # Selective strategy
    sel_payoffs = [selective_payoff(r) for r in rounds]
    sel_total = sum(sel_payoffs)
    sel_regret = n - sel_total
    sel_dec_mistakes = sum(1 - p for r, p in zip(rounds, sel_payoffs) if r.decidable)
    sel_undec_exposure = sum(1 - p for r, p in zip(rounds, sel_payoffs)
                            if not r.decidable)

    print(f"  Selective strategy:")
    print(f"    Profit              = {sel_total}")
    print(f"    Decidable mistakes  = {sel_dec_mistakes}")
    print(f"    Undecidable exposure = {sel_undec_exposure}")
    print(f"    ✓ Zero dec mistakes: {sel_dec_mistakes == 0}")
    print(f"    ✓ Exposure = undec count: "
          f"{sel_undec_exposure == sum(1 for r in rounds if not r.decidable)}")
    print()


def demo_inclusion_exclusion():
    """Demonstrate: profit(O₁∪O₂) + profit(O₁∩O₂) = profit(O₁) + profit(O₂)"""
    print("=" * 60)
    print("THEOREM 3: Oracle Inclusion-Exclusion")
    print("  profit(O₁∪O₂) + profit(O₁∩O₂) = profit(O₁) + profit(O₂)")
    print("=" * 60)

    n = 20
    truths = [random.choice([True, False]) for _ in range(n)]
    oracle1 = [random.choice([True, False]) for _ in range(n)]
    oracle2 = [random.choice([True, False]) for _ in range(n)]

    dec1 = sum(1 for o in oracle1 if o)
    dec2 = sum(1 for o in oracle2 if o)
    dec_union = sum(1 for o1, o2 in zip(oracle1, oracle2) if o1 or o2)
    dec_inter = sum(1 for o1, o2 in zip(oracle1, oracle2) if o1 and o2)

    print(f"  n = {n}")
    print(f"  |O₁|      = {dec1}")
    print(f"  |O₂|      = {dec2}")
    print(f"  |O₁ ∪ O₂| = {dec_union}")
    print(f"  |O₁ ∩ O₂| = {dec_inter}")
    print(f"  LHS = {dec_union} + {dec_inter} = {dec_union + dec_inter}")
    print(f"  RHS = {dec1} + {dec2} = {dec1 + dec2}")
    print(f"  ✓ Inclusion-Exclusion: {dec_union + dec_inter == dec1 + dec2}")
    print()

    # Submodularity
    marginal = dec_union - dec1
    print(f"  Marginal value of O₂ given O₁: {marginal}")
    print(f"  Standalone value of O₂:         {dec2}")
    print(f"  ✓ Submodularity (marginal ≤ standalone): {marginal <= dec2}")
    print()


def demo_cascade():
    """Demonstrate cascade profit monotonicity."""
    print("=" * 60)
    print("THEOREM 4: Cascade Profit Monotonicity")
    print("  Ascending the oracle hierarchy ⟹ non-decreasing profit")
    print("=" * 60)

    n = 30
    depth = 5
    truths = [random.choice([True, False]) for _ in range(n)]

    # Build cascade: each level decides a superset of previous
    levels = [set() for _ in range(depth + 1)]
    for k in range(depth + 1):
        if k == 0:
            # Level 0: decide ~20% of rounds
            levels[k] = set(random.sample(range(n), n // 5))
        else:
            # Each level adds some new decidable rounds
            levels[k] = levels[k-1] | set(random.sample(range(n),
                                                         min(n, len(levels[k-1]) + n // 5)))

    profits = [len(levels[k]) for k in range(depth + 1)]

    print(f"  n = {n}, depth = {depth}")
    for k in range(depth + 1):
        bar = "█" * profits[k] + "░" * (n - profits[k])
        print(f"  Level {k}: profit = {profits[k]:2d} / {n}  {bar}")

    is_monotone = all(profits[k] <= profits[k+1] for k in range(depth))
    print(f"  ✓ Monotone: {is_monotone}")
    print()

    # Cascade gaps
    print(f"  Cascade gaps (new decidable rounds per level):")
    for k in range(depth):
        gap = profits[k+1] - profits[k]
        print(f"    Level {k} → {k+1}: +{gap} rounds")
    print(f"  Total gap: {profits[depth] - profits[0]}")
    print()


def demo_calibration():
    """Demonstrate the calibration-profit theorem."""
    print("=" * 60)
    print("THEOREM 5: Calibration-Profit")
    print("  Calibrated oracle profit = decidable count")
    print("=" * 60)

    n = 20
    truths = [random.choice([True, False]) for _ in range(n)]
    oracle = [random.choice([True, False]) for _ in range(n)]

    # Calibrated: predictions match truth on decidable rounds
    predictions = [truths[i] if oracle[i] else random.choice([True, False])
                   for i in range(n)]

    dec_count = sum(1 for o in oracle if o)

    # Calibrated strategy profit
    profit = 0
    for i in range(n):
        if oracle[i]:
            profit += 1 if predictions[i] == truths[i] else -1
        # else: abstain (0)

    print(f"  n = {n}")
    print(f"  Decidable count = {dec_count}")
    print(f"  Calibrated profit = {profit}")
    print(f"  ✓ Calibrated profit = dec count: {profit == dec_count}")
    print()

    # Miscalibrated: wrong predictions
    bad_predictions = [not truths[i] if oracle[i] else random.choice([True, False])
                       for i in range(n)]
    bad_profit = 0
    for i in range(n):
        if oracle[i]:
            bad_profit += 1 if bad_predictions[i] == truths[i] else -1

    print(f"  Miscalibrated (inverted) profit = {bad_profit}")
    print(f"  ✗ Miscalibration destroys profit: {bad_profit <= 0}")
    print()


def demo_parallel_additivity():
    """Demonstrate parallel profit additivity."""
    print("=" * 60)
    print("THEOREM 6: Parallel Profit Additivity")
    print("  profit(G₁ ∥ G₂) = profit(G₁) + profit(G₂)")
    print("=" * 60)

    n1, n2 = 12, 8
    game1 = [CasinoRound(truth=random.choice([True, False]),
                          decidable=random.choice([True, False]))
             for _ in range(n1)]
    game2 = [CasinoRound(truth=random.choice([True, False]),
                          decidable=random.choice([True, False]))
             for _ in range(n2)]

    p1 = total_profit(game1, selective_payoff)
    p2 = total_profit(game2, selective_payoff)
    p_combined = total_profit(game1 + game2, selective_payoff)

    print(f"  Game 1: n={n1}, profit={p1}")
    print(f"  Game 2: n={n2}, profit={p2}")
    print(f"  Combined: n={n1+n2}, profit={p_combined}")
    print(f"  ✓ Additivity: {p_combined == p1 + p2}")
    print()


if __name__ == "__main__":
    random.seed(42)  # Reproducibility
    print("\n🎰 GÖDEL'S CASINO: Epistemic Game Theory Demo 🎰\n")

    demo_complement_conservation()
    demo_regret_decomposition()
    demo_inclusion_exclusion()
    demo_cascade()
    demo_calibration()
    demo_parallel_additivity()

    print("=" * 60)
    print("All theorems verified computationally! ✓")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Oracle Cascade Profit Monotonicity

Shows how profit increases monotonically through the oracle hierarchy,
visualizing the game-theoretic shadow of Post's theorem.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import random


def build_cascade(n: int, depth: int, seed: int = 42) -> list:
    """Build a monotone cascade of oracle levels."""
    rng = random.Random(seed)
    levels = []
    prev = set()
    for k in range(depth + 1):
        frac = min(1.0, 0.1 + k * 0.18)
        target = int(n * frac)
        remaining = set(range(n)) - prev
        new_count = max(0, target - len(prev))
        if remaining and new_count > 0:
            new = set(rng.sample(list(remaining), min(new_count, len(remaining))))
        else:
            new = set()
        current = prev | new
        levels.append(len(current))
        prev = current
    return levels


def main():
    n = 50
    depth = 6

    # Build multiple cascades for visual variety
    cascades = [build_cascade(n, depth, seed=s) for s in [42, 123, 7, 999]]

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: Cascade profit curves
    ax = axes[0]
    colors = ['#e74c3c', '#3498db', '#2ecc71', '#9b59b6']
    for idx, (profits, color) in enumerate(zip(cascades, colors)):
        levels = list(range(depth + 1))
        ax.plot(levels, profits, 'o-', color=color, linewidth=2,
                markersize=8, label=f'Cascade {idx+1}')
        # Fill area under curve
        ax.fill_between(levels, profits, alpha=0.1, color=color)

    ax.axhline(y=n, color='gray', linestyle='--', alpha=0.5, label=f'Max (n={n})')
    ax.set_xlabel('Oracle Level (Arithmetic Hierarchy)', fontsize=12)
    ax.set_ylabel('Selective Strategy Profit', fontsize=12)
    ax.set_title('Cascade Profit Monotonicity\n(Game-Theoretic Shadow of Post\'s Theorem)',
                 fontsize=13)
    ax.legend(fontsize=10)
    ax.set_ylim(0, n + 5)
    ax.grid(True, alpha=0.3)

    # Right: Cascade gaps (marginal value of each level)
    ax = axes[1]
    for idx, (profits, color) in enumerate(zip(cascades, colors)):
        gaps = [profits[k+1] - profits[k] for k in range(depth)]
        ax.bar([x + idx*0.2 - 0.3 for x in range(depth)], gaps,
               width=0.18, color=color, alpha=0.7, label=f'Cascade {idx+1}')

    ax.set_xlabel('Level Transition (k → k+1)', fontsize=12)
    ax.set_ylabel('Cascade Gap (New Decidable Rounds)', fontsize=12)
    ax.set_title('Marginal Oracle Value per Level\n(Diminishing Returns in Oracle Power)',
                 fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    plt.savefig('viz_cascade.png', dpi=150, bbox_inches='tight')
    print("Saved viz_cascade.png")


if __name__ == '__main__':
    main()


#!/usr/bin/env python3
"""
Visualization: Oracle Complement Conservation Law

Shows that profit(O) + profit(¬O) = n for any oracle, visualizing
the zero-sum nature of decidability.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def main():
    # Sweep over different decidable fractions
    n = 100
    fractions = np.linspace(0, 1, 21)

    profit_O = [int(f * n) for f in fractions]
    profit_not_O = [n - p for p in profit_O]

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: Conservation law
    ax = axes[0]
    ax.fill_between(fractions, 0, profit_O, alpha=0.6, color='#3498db',
                    label='profit(O)')
    ax.fill_between(fractions, profit_O, n, alpha=0.6, color='#e74c3c',
                    label='profit(¬O)')
    ax.plot(fractions, [n] * len(fractions), 'k--', linewidth=2,
            label=f'n = {n}')

    ax.set_xlabel('Decidable Fraction (of oracle O)', fontsize=12)
    ax.set_ylabel('Profit', fontsize=12)
    ax.set_title('Oracle Complement Conservation\nprofit(O) + profit(¬O) = n',
                 fontsize=13)
    ax.legend(fontsize=11, loc='center left')
    ax.set_ylim(0, n + 5)
    ax.grid(True, alpha=0.3)

    # Annotate the conservation law
    ax.annotate('← Decidability is\n    zero-sum →',
                xy=(0.5, n/2), fontsize=11, ha='center', va='center',
                bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))

    # Right: Regret-Complement Duality
    ax = axes[1]
    regret = profit_not_O  # selective regret = undec count = profit(¬O)
    ax.plot(fractions, regret, 'o-', color='#e74c3c', linewidth=2,
            markersize=6, label='Selective Regret = profit(¬O)')
    ax.plot(fractions, profit_O, 's-', color='#3498db', linewidth=2,
            markersize=6, label='Selective Profit = profit(O)')

    # Highlight duality
    for f in [0.3, 0.7]:
        idx = int(f * 20)
        p = profit_O[idx]
        r = regret[idx]
        ax.plot([f, f], [0, max(p, r)], 'k:', alpha=0.3)
        ax.annotate(f'profit={p}', xy=(f, p), fontsize=9,
                    textcoords="offset points", xytext=(10, 5))
        ax.annotate(f'regret={r}', xy=(f, r), fontsize=9,
                    textcoords="offset points", xytext=(10, -15))

    ax.set_xlabel('Decidable Fraction', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title('Regret-Complement Duality\nYour regret = complement\'s profit',
                 fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_conservation.png', dpi=150, bbox_inches='tight')
    print("Saved viz_conservation.png")


if __name__ == '__main__':
    main()


#!/usr/bin/env python3
"""
Visualization: Regret Decomposition

Shows how strategy regret decomposes into decidable mistakes
and undecidable exposure for various strategies.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import random


def simulate_casino(n: int, dec_frac: float, seed: int = 42):
    """Simulate a casino and compute regret components for various strategies."""
    rng = random.Random(seed)
    truth = [rng.choice([True, False]) for _ in range(n)]
    oracle = [rng.random() < dec_frac for _ in range(n)]

    strategies = {}

    # Selective strategy
    sel_payoffs = [1 if oracle[i] else 0 for i in range(n)]
    strategies['Selective'] = sel_payoffs

    # Always bet True
    true_payoffs = [1 if truth[i] else -1 for i in range(n)]
    strategies['Always True'] = true_payoffs

    # Random strategy
    rand_payoffs = [1 if rng.choice([True, False]) == truth[i] else -1
                    for i in range(n)]
    strategies['Random'] = rand_payoffs

    # Conservative (abstain always)
    strategies['Always Abstain'] = [0] * n

    # Aggressive (bet True on decidable, random on undecidable)
    agg_payoffs = []
    for i in range(n):
        if oracle[i]:
            agg_payoffs.append(1)
        else:
            agg_payoffs.append(1 if rng.choice([True, False]) == truth[i] else -1)
    strategies['Aggressive'] = agg_payoffs

    results = {}
    for name, payoffs in strategies.items():
        total_regret = n - sum(payoffs)
        dec_mistakes = sum(1 - payoffs[i] for i in range(n) if oracle[i])
        undec_exposure = sum(1 - payoffs[i] for i in range(n) if not oracle[i])
        results[name] = {
            'profit': sum(payoffs),
            'regret': total_regret,
            'dec_mistakes': dec_mistakes,
            'undec_exposure': undec_exposure,
        }

    return results, sum(oracle), n - sum(oracle)


def main():
    n = 100
    results, dec_count, undec_count = simulate_casino(n, 0.6)

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: Regret decomposition bar chart
    ax = axes[0]
    names = list(results.keys())
    dec_m = [results[s]['dec_mistakes'] for s in names]
    undec_e = [results[s]['undec_exposure'] for s in names]

    x = np.arange(len(names))
    width = 0.35

    bars1 = ax.bar(x - width/2, dec_m, width, label='Decidable Mistakes',
                   color='#e74c3c', alpha=0.8)
    bars2 = ax.bar(x + width/2, undec_e, width, label='Undecidable Exposure',
                   color='#3498db', alpha=0.8)

    ax.set_xlabel('Strategy', fontsize=12)
    ax.set_ylabel('Regret Component', fontsize=12)
    ax.set_title(f'Regret Decomposition Theorem\n(n={n}, decidable={dec_count})',
                 fontsize=13)
    ax.set_xticks(x)
    ax.set_xticklabels(names, rotation=15, ha='right', fontsize=10)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3, axis='y')

    # Right: Profit comparison
    ax = axes[1]
    profits = [results[s]['profit'] for s in names]
    colors = ['#2ecc71' if p >= 0 else '#e74c3c' for p in profits]
    bars = ax.bar(x, profits, color=colors, alpha=0.8, edgecolor='black', linewidth=0.5)

    ax.axhline(y=dec_count, color='green', linestyle='--', alpha=0.5,
               label=f'Decidable count ({dec_count})')
    ax.axhline(y=n, color='gray', linestyle='--', alpha=0.5,
               label=f'Omniscient ({n})')
    ax.axhline(y=0, color='black', linewidth=0.5)

    ax.set_xlabel('Strategy', fontsize=12)
    ax.set_ylabel('Total Profit', fontsize=12)
    ax.set_title('Strategy Profit Comparison\n(Selective = optimal oracle-consistent)',
                 fontsize=13)
    ax.set_xticks(x)
    ax.set_xticklabels(names, rotation=15, ha='right', fontsize=10)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    plt.savefig('viz_regret.png', dpi=150, bbox_inches='tight')
    print("Saved viz_regret.png")


if __name__ == '__main__':
    main()
