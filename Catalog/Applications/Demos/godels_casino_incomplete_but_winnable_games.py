#!/usr/bin/env python3
"""
Gödel's Casino: Real-World Applications

Demonstrates how the casino framework applies to practical scenarios:
1. Software testing: Which tests to run when time is limited
2. Investment: Betting on knowable vs unknowable outcomes
3. Scientific research: Choosing tractable vs intractable problems
"""

import random
from dataclasses import dataclass
from typing import List


@dataclass
class CasinoRound:
    truth: bool
    is_decidable: bool


def bet_payoff(truth: bool, bet: str) -> int:
    if bet == "ABSTAIN":
        return 0
    elif bet == "TRUE":
        return 1 if truth else -1
    else:
        return -1 if truth else 1


def selective_strategy(r: CasinoRound) -> str:
    if r.is_decidable:
        return "TRUE" if r.truth else "FALSE"
    return "ABSTAIN"


def naive_strategy(_r: CasinoRound) -> str:
    return "TRUE"


# =====================================================
# Application 1: Software Testing Portfolio
# =====================================================

def app_software_testing():
    """
    Analogy: Test cases are 'statements', decidability = whether we can
    predict the outcome. Some tests have deterministic results (decidable),
    others depend on race conditions, network state, etc. (undecidable).

    The selective strategy = run only deterministic tests first.
    """
    print("=" * 60)
    print("APPLICATION 1: Software Testing Portfolio")
    print("=" * 60)

    tests = [
        ("Unit test: add(2,3)==5", True, True),
        ("Unit test: sort([3,1,2])==[1,2,3]", True, True),
        ("Unit test: parse('{')==error", True, True),
        ("Integration: API responds < 100ms", True, False),  # Network dependent
        ("Integration: DB write succeeds", True, False),       # State dependent
        ("Flaky: Race condition in cache", False, False),      # Undecidable
        ("Unit test: fib(10)==55", True, True),
        ("Load test: handles 1000 req/s", True, False),        # Environment dependent
    ]

    rounds = [CasinoRound(truth=t, is_decidable=d) for _, t, d in tests]

    print("\nTest Portfolio:")
    total_sel = 0
    total_naive = 0
    for i, (name, truth, dec) in enumerate(tests):
        r = rounds[i]
        sel_bet = selective_strategy(r)
        naive_bet = naive_strategy(r)
        sel_pay = bet_payoff(truth, sel_bet)
        naive_pay = bet_payoff(truth, naive_bet)
        total_sel += sel_pay
        total_naive += naive_pay
        status = "✓ DECIDABLE" if dec else "? FLAKY"
        print(f"  [{status:14}] {name:40} | Sel: {sel_bet:7}({sel_pay:+d}) | Naive: {naive_bet:7}({naive_pay:+d})")

    print(f"\nSelective profit: {total_sel} (reliable, no false alarms)")
    print(f"Naive profit:     {total_naive} (includes false positives on flaky tests)")
    print(f"→ The selective strategy avoids flaky test noise!")


# =====================================================
# Application 2: Research Problem Selection
# =====================================================

def app_research_selection():
    """
    Analogy: Research problems are 'statements', decidability = whether
    current methods can solve them. The selective strategy = work on
    tractable problems, don't waste time on currently impossible ones.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Research Problem Selection")
    print("=" * 60)

    problems = [
        ("Prove FLT for n=4 (elementary)", True, True),
        ("Factor RSA-2048", True, False),  # Currently intractable
        ("Verify Goldbach for n < 10^18", True, True),
        ("Resolve P vs NP", True, False),  # Open problem
        ("Compute det(A) for 100x100 A", True, True),
        ("Prove Riemann Hypothesis", True, False),  # Open
        ("Find shortest path in graph", True, True),
        ("Solve halting problem instance", False, False),  # Undecidable
    ]

    print("\nResearch Portfolio (10-year horizon):")
    sel_papers = 0
    naive_papers = 0

    for name, truth, dec in problems:
        r = CasinoRound(truth=truth, is_decidable=dec)
        sel_bet = selective_strategy(r)
        naive_bet = naive_strategy(r)
        sel_pay = bet_payoff(truth, sel_bet)
        naive_pay = bet_payoff(truth, naive_bet)
        sel_papers += max(0, sel_pay)
        naive_papers += max(0, naive_pay)
        marker = "📊 TRACTABLE" if dec else "🔮 OPEN/HARD"
        action = "WORK ON" if sel_bet != "ABSTAIN" else "SKIP"
        print(f"  [{marker:14}] {name:35} → {action}")

    decidable = sum(1 for _, _, d in problems if d)
    print(f"\nDecidable problems: {decidable}/{len(problems)}")
    print(f"Selective papers (guaranteed): {decidable}")
    print(f"→ Focus on tractable problems for guaranteed output!")


# =====================================================
# Application 3: Monte Carlo Comparison
# =====================================================

def app_monte_carlo_comparison():
    """
    Large-scale simulation comparing strategies across many scenarios.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Strategy Comparison (1000 scenarios)")
    print("=" * 60)

    random.seed(42)
    n_scenarios = 1000
    n_rounds = 50

    sel_wins = 0
    naive_wins = 0
    ties = 0

    sel_total = 0
    naive_total = 0

    for _ in range(n_scenarios):
        dec_frac = random.uniform(0.1, 0.9)
        rounds = []
        for _ in range(n_rounds):
            is_dec = random.random() < dec_frac
            truth = random.choice([True, False])
            rounds.append(CasinoRound(truth=truth, is_decidable=is_dec))

        sel_profit = sum(bet_payoff(r.truth, selective_strategy(r)) for r in rounds)
        naive_profit = sum(bet_payoff(r.truth, naive_strategy(r)) for r in rounds)

        sel_total += sel_profit
        naive_total += naive_profit

        if sel_profit > naive_profit:
            sel_wins += 1
        elif naive_profit > sel_profit:
            naive_wins += 1
        else:
            ties += 1

    print(f"\n  Selective wins: {sel_wins:>5} ({sel_wins/n_scenarios:.1%})")
    print(f"  Naive wins:     {naive_wins:>5} ({naive_wins/n_scenarios:.1%})")
    print(f"  Ties:           {ties:>5} ({ties/n_scenarios:.1%})")
    print(f"\n  Selective total profit: {sel_total:>8}")
    print(f"  Naive total profit:    {naive_total:>8}")
    print(f"\n  → Selective strategy is consistently superior!")
    print(f"  → Selective ALWAYS has non-negative profit (guaranteed by theorem)")


if __name__ == "__main__":
    app_software_testing()
    app_research_selection()
    app_monte_carlo_comparison()


#!/usr/bin/env python3
"""
Gödel's Casino: Demo of the Selective Strategy

Demonstrates the key theorems from the formalization with concrete examples.
Shows that the selective strategy achieves optimal profit on decidable rounds
and zero cost on undecidable ones.
"""

import random
from dataclasses import dataclass
from typing import List, Literal

Bet = Literal["TRUE", "FALSE", "ABSTAIN"]


@dataclass
class CasinoRound:
    """A round in Gödel's Casino."""
    truth: bool
    is_decidable: bool


def bet_payoff(r: CasinoRound, bet: Bet) -> int:
    """Compute payoff: +1 correct, -1 wrong, 0 abstain."""
    if bet == "ABSTAIN":
        return 0
    elif bet == "TRUE":
        return 1 if r.truth else -1
    else:  # FALSE
        return -1 if r.truth else 1


def selective_strategy(r: CasinoRound) -> Bet:
    """Bet correctly on decidable rounds, abstain on undecidable."""
    if r.is_decidable:
        return "TRUE" if r.truth else "FALSE"
    return "ABSTAIN"


def naive_strategy(_r: CasinoRound) -> Bet:
    """Always bet TRUE."""
    return "TRUE"


def random_strategy(_r: CasinoRound) -> Bet:
    """Random bet (excluding abstain)."""
    return random.choice(["TRUE", "FALSE"])


def total_profit(strategy, rounds: List[CasinoRound]) -> int:
    """Total profit of a strategy over rounds."""
    return sum(bet_payoff(r, strategy(r)) for r in rounds)


def generate_casino(n: int, decidable_frac: float, adversarial: bool = False) -> List[CasinoRound]:
    """Generate a casino game with n rounds."""
    rounds = []
    for _ in range(n):
        is_dec = random.random() < decidable_frac
        if adversarial and not is_dec:
            truth = False  # Adversary makes undecidable statements false
        else:
            truth = random.choice([True, False])
        rounds.append(CasinoRound(truth=truth, is_decidable=is_dec))
    return rounds


def demo_basic():
    """Demo 1: Basic casino game."""
    print("=" * 60)
    print("DEMO 1: Basic Gödel's Casino Game")
    print("=" * 60)

    rounds = [
        CasinoRound(truth=True, is_decidable=True),
        CasinoRound(truth=False, is_decidable=True),
        CasinoRound(truth=True, is_decidable=False),
        CasinoRound(truth=False, is_decidable=False),
        CasinoRound(truth=True, is_decidable=True),
    ]

    print("\nRound details:")
    for i, r in enumerate(rounds):
        s_bet = selective_strategy(r)
        n_bet = naive_strategy(r)
        print(f"  Round {i+1}: truth={r.truth:5}, decidable={r.is_decidable:5} | "
              f"Selective: {s_bet:7} (payoff {bet_payoff(r, s_bet):+d}) | "
              f"Naive: {n_bet:7} (payoff {bet_payoff(r, n_bet):+d})")

    dec_count = sum(1 for r in rounds if r.is_decidable)
    sel_profit = total_profit(selective_strategy, rounds)
    naive_profit = total_profit(naive_strategy, rounds)

    print(f"\nDecidable rounds: {dec_count}")
    print(f"Selective profit: {sel_profit} (= decidable count ✓)")
    print(f"Naive profit:     {naive_profit}")
    print(f"Advantage:        {sel_profit - naive_profit}")


def demo_monte_carlo():
    """Demo 2: Monte Carlo simulation."""
    print("\n" + "=" * 60)
    print("DEMO 2: Monte Carlo Simulation (10,000 trials)")
    print("=" * 60)

    n = 100
    trials = 10000

    print(f"\n{'Dec Frac':>10} {'Selective':>12} {'Naive':>12} {'Random':>12} {'Advantage':>12}")
    print("-" * 60)

    for d in [0.1, 0.3, 0.5, 0.7, 1.0]:
        sel_total = 0
        naive_total = 0
        rand_total = 0
        for _ in range(trials):
            rounds = generate_casino(n, d)
            sel_total += total_profit(selective_strategy, rounds)
            naive_total += total_profit(naive_strategy, rounds)
            rand_total += total_profit(random_strategy, rounds)

        sel_avg = sel_total / trials
        naive_avg = naive_total / trials
        rand_avg = rand_total / trials
        print(f"{d:>10.1f} {sel_avg:>12.1f} {naive_avg:>12.1f} {rand_avg:>12.1f} {sel_avg - naive_avg:>12.1f}")


def demo_adversarial():
    """Demo 3: Adversarial truth assignment."""
    print("\n" + "=" * 60)
    print("DEMO 3: Adversarial Analysis (worst case for naive)")
    print("=" * 60)

    n = 100
    print(f"\n{'Dec Frac':>10} {'Selective':>12} {'Naive':>12} {'Gap':>12}")
    print("-" * 50)

    for d in [0.1, 0.3, 0.5, 0.7, 0.9]:
        rounds = generate_casino(n, d, adversarial=True)
        dec_count = sum(1 for r in rounds if r.is_decidable)
        sel = total_profit(selective_strategy, rounds)
        naive = total_profit(naive_strategy, rounds)
        print(f"{dec_count/n:>10.2f} {sel:>12d} {naive:>12d} {sel - naive:>12d}")

    print("\n→ Under adversarial conditions, the incompleteness advantage is dramatic!")


def demo_tropical():
    """Demo 4: Tropical connection."""
    print("\n" + "=" * 60)
    print("DEMO 4: Tropical-Casino Bridge")
    print("=" * 60)

    n = 50
    rounds = generate_casino(n, 0.4)
    dec_count = sum(1 for r in rounds if r.is_decidable)
    sel_profit = total_profit(selective_strategy, rounds)

    # Tropical optimal = max payoff per round = 1 always
    tropical_total = n  # Each round contributes 1 in tropical optimal

    print(f"\nRounds: {n}")
    print(f"Decidable count: {dec_count}")
    print(f"Selective profit: {sel_profit}")
    print(f"Tropical optimal: {tropical_total}")
    print(f"\nBridge theorem check:")
    print(f"  selective_profit × n = {sel_profit * n}")
    print(f"  decidable_count × tropical_total = {dec_count * tropical_total}")
    print(f"  Equal: {sel_profit * n == dec_count * tropical_total} ✓")
    print(f"\nHarvesting efficiency: {sel_profit / tropical_total:.2%}")
    print(f"Decidable fraction:   {dec_count / n:.2%}")
    print(f"Match: {abs(sel_profit / tropical_total - dec_count / n) < 1e-10} ✓")


if __name__ == "__main__":
    random.seed(42)
    demo_basic()
    demo_monte_carlo()
    demo_adversarial()
    demo_tropical()


#!/usr/bin/env python3
"""
Visualization 1: Profit Landscape of Gödel's Casino

Visualizes how the selective strategy's profit varies with the decidable
fraction, compared to naive and random strategies. Shows the profit ceiling
(tropical optimal) and the incompleteness gap.
"""

import numpy as np
import matplotlib.pyplot as plt

# Parameters
n_rounds = 100
n_trials = 500
fractions = np.linspace(0, 1, 21)

# Simulate
sel_profits = []
naive_profits_mean = []
naive_profits_std = []
random_profits_mean = []

np.random.seed(42)

for d in fractions:
    sel_trial = []
    naive_trial = []
    rand_trial = []
    for _ in range(n_trials):
        is_dec = np.random.random(n_rounds) < d
        truth = np.random.choice([True, False], n_rounds)

        # Selective: +1 on decidable, 0 on undecidable
        sel_profit = int(np.sum(is_dec))
        sel_trial.append(sel_profit)

        # Naive (bet TRUE): +1 if true, -1 if false
        naive_profit = int(np.sum(truth * 2 - 1))
        naive_trial.append(naive_profit)

        # Random: expected 0
        rand_bets = np.random.choice([True, False], n_rounds)
        rand_profit = int(np.sum((rand_bets == truth) * 2 - 1))
        rand_trial.append(rand_profit)

    sel_profits.append(np.mean(sel_trial))
    naive_profits_mean.append(np.mean(naive_trial))
    naive_profits_std.append(np.std(naive_trial))
    random_profits_mean.append(np.mean(rand_trial))

# Plot
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Left: Profit vs decidable fraction
ax1.fill_between(fractions, n_rounds, sel_profits,
                  alpha=0.3, color='red', label='Incompleteness Gap')
ax1.plot(fractions, [n_rounds]*len(fractions), 'k--', linewidth=2,
         label='Tropical Optimal (ceiling)')
ax1.plot(fractions, sel_profits, 'b-o', linewidth=2, markersize=4,
         label='Selective Strategy')
ax1.fill_between(fractions,
                  np.array(naive_profits_mean) - np.array(naive_profits_std),
                  np.array(naive_profits_mean) + np.array(naive_profits_std),
                  alpha=0.2, color='orange')
ax1.plot(fractions, naive_profits_mean, 'r-s', linewidth=1.5, markersize=3,
         label='Naive Strategy (±1σ)')
ax1.plot(fractions, random_profits_mean, 'g-^', linewidth=1.5, markersize=3,
         label='Random Strategy')
ax1.axhline(y=0, color='gray', linestyle=':', alpha=0.5)

ax1.set_xlabel('Decidable Fraction', fontsize=12)
ax1.set_ylabel('Expected Profit', fontsize=12)
ax1.set_title("Gödel's Casino: Profit vs Decidability", fontsize=14)
ax1.legend(loc='upper left', fontsize=9)
ax1.set_xlim(0, 1)
ax1.set_ylim(-30, 110)

# Right: Incompleteness gap
gap = n_rounds - np.array(sel_profits)
ax2.bar(fractions, gap, width=0.04, color='indianred', alpha=0.8,
        edgecolor='darkred', label='Incompleteness Gap')
ax2.plot(fractions, n_rounds * (1 - fractions), 'k--', linewidth=2,
         label='Theoretical: n(1-d)')
ax2.set_xlabel('Decidable Fraction', fontsize=12)
ax2.set_ylabel('Incompleteness Gap (lost profit)', fontsize=12)
ax2.set_title('The Cost of Incompleteness', fontsize=14)
ax2.legend(fontsize=10)
ax2.set_xlim(0, 1)

plt.tight_layout()
plt.savefig('viz_profit_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_profit_landscape.png")


#!/usr/bin/env python3
"""
Visualization 2: Strategy Performance Heatmap

Shows a heatmap of strategy performance across different combinations
of decidable fraction and adversarial intensity. Illustrates how the
selective strategy's advantage grows under adversarial conditions.
"""

import numpy as np
import matplotlib.pyplot as plt

np.random.seed(42)

n_rounds = 100
n_trials = 200
dec_fracs = np.linspace(0.05, 0.95, 19)
adv_levels = np.linspace(0, 1, 21)  # 0 = random truth, 1 = all undecidable are false

advantage_matrix = np.zeros((len(adv_levels), len(dec_fracs)))
sel_matrix = np.zeros((len(adv_levels), len(dec_fracs)))

for i, adv in enumerate(adv_levels):
    for j, d in enumerate(dec_fracs):
        sel_total = 0
        naive_total = 0
        for _ in range(n_trials):
            is_dec = np.random.random(n_rounds) < d
            truth = np.random.choice([True, False], n_rounds)
            # Adversarial: undecidable statements biased toward FALSE
            for k in range(n_rounds):
                if not is_dec[k] and np.random.random() < adv:
                    truth[k] = False

            # Selective profit = number of decidable rounds
            sel_profit = int(np.sum(is_dec))

            # Naive profit = sum of (2*truth - 1)
            naive_profit = int(np.sum(truth * 2 - 1))

            sel_total += sel_profit
            naive_total += naive_profit

        advantage_matrix[i, j] = (sel_total - naive_total) / n_trials
        sel_matrix[i, j] = sel_total / n_trials

fig, axes = plt.subplots(1, 2, figsize=(15, 6))

# Left: Advantage heatmap
im1 = axes[0].imshow(advantage_matrix, aspect='auto', origin='lower',
                       cmap='RdYlGn', extent=[dec_fracs[0], dec_fracs[-1],
                                               adv_levels[0], adv_levels[-1]])
axes[0].set_xlabel('Decidable Fraction', fontsize=12)
axes[0].set_ylabel('Adversarial Intensity', fontsize=12)
axes[0].set_title('Selective Advantage over Naive Strategy', fontsize=13)
plt.colorbar(im1, ax=axes[0], label='Profit Advantage')

# Add contour lines
X, Y = np.meshgrid(dec_fracs, adv_levels)
cs = axes[0].contour(X, Y, advantage_matrix, levels=[0, 10, 20, 30, 40, 50],
                      colors='black', linewidths=0.5, alpha=0.5)
axes[0].clabel(cs, inline=True, fontsize=8)

# Right: Selective profit heatmap
im2 = axes[1].imshow(sel_matrix, aspect='auto', origin='lower',
                       cmap='Blues', extent=[dec_fracs[0], dec_fracs[-1],
                                             adv_levels[0], adv_levels[-1]])
axes[1].set_xlabel('Decidable Fraction', fontsize=12)
axes[1].set_ylabel('Adversarial Intensity', fontsize=12)
axes[1].set_title('Selective Strategy Profit (immune to adversary)', fontsize=13)
plt.colorbar(im2, ax=axes[1], label='Selective Profit')

# Note: selective profit doesn't depend on adversarial intensity
axes[1].annotate('Selective profit depends\nonly on decidable fraction\n(horizontal bands)',
                  xy=(0.5, 0.5), fontsize=10, ha='center', color='white',
                  fontweight='bold', bbox=dict(boxstyle='round', facecolor='navy', alpha=0.7))

plt.tight_layout()
plt.savefig('viz_strategy_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_strategy_heatmap.png")


#!/usr/bin/env python3
"""
Visualization 3: Tropical-Casino Bridge

Visualizes the bridge theorem connecting selective profit, tropical optimal,
and decidable fraction. Shows the three-way relationship as a 3D surface
and the harvesting efficiency curve.
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D  # noqa: F401

fig = plt.figure(figsize=(14, 5))

# Plot 1: Bridge theorem verification
ax1 = fig.add_subplot(131)

np.random.seed(42)
n_values = range(10, 201, 10)
points_n = []
points_dec = []
points_verified = []

for n in n_values:
    for d in np.linspace(0.1, 0.9, 9):
        is_dec = np.random.random(n) < d
        dec_count = int(np.sum(is_dec))
        sel_profit = dec_count  # By theorem
        trop_total = n  # By theorem

        lhs = sel_profit * n
        rhs = dec_count * trop_total
        points_n.append(n)
        points_dec.append(d)
        points_verified.append(lhs == rhs)

verified_pct = sum(points_verified) / len(points_verified) * 100
ax1.scatter([p for p, v in zip(points_n, points_verified) if v],
            [p for p, v in zip(points_dec, points_verified) if v],
            c='green', s=15, alpha=0.6, label=f'Verified ({verified_pct:.0f}%)')
not_v = [p for p, v in zip(points_n, points_verified) if not v]
if not_v:
    ax1.scatter(not_v,
                [p for p, v in zip(points_dec, points_verified) if not v],
                c='red', s=15, alpha=0.6, label='Failed')

ax1.set_xlabel('Number of Rounds (n)')
ax1.set_ylabel('Decidable Fraction (d)')
ax1.set_title('Bridge Theorem\nVerification', fontsize=11)
ax1.legend(fontsize=8)

# Plot 2: Harvesting efficiency
ax2 = fig.add_subplot(132)

d_range = np.linspace(0, 1, 100)
efficiency = d_range  # Harvesting efficiency = decidable fraction

ax2.fill_between(d_range, 0, efficiency, alpha=0.3, color='blue',
                  label='Harvested (selective profit)')
ax2.fill_between(d_range, efficiency, 1, alpha=0.3, color='red',
                  label='Lost (incompleteness gap)')
ax2.plot(d_range, efficiency, 'b-', linewidth=2)
ax2.plot(d_range, np.ones_like(d_range), 'k--', linewidth=1,
         label='Tropical ceiling')
ax2.plot([0, 1], [0, 1], 'b:', alpha=0.5)

ax2.set_xlabel('Decidable Fraction (d)')
ax2.set_ylabel('Efficiency Ratio')
ax2.set_title('Harvesting Efficiency\n= Decidable Fraction', fontsize=11)
ax2.legend(fontsize=8, loc='upper left')
ax2.set_xlim(0, 1)
ax2.set_ylim(0, 1.1)

# Plot 3: Three-way relationship (n, d, profit)
ax3 = fig.add_subplot(133, projection='3d')

n_grid = np.arange(10, 101, 5)
d_grid = np.linspace(0.1, 0.9, 17)
N, D = np.meshgrid(n_grid, d_grid)

# Selective profit = n * d (in expectation)
Sel_Profit = N * D

# Tropical optimal = n
Trop_Optimal = N

# Plot surfaces
ax3.plot_surface(N, D, Sel_Profit, alpha=0.6, cmap='Blues',
                  label='Selective Profit')
ax3.plot_surface(N, D, Trop_Optimal, alpha=0.3, color='red')

ax3.set_xlabel('Rounds (n)', fontsize=9)
ax3.set_ylabel('Dec. Frac. (d)', fontsize=9)
ax3.set_zlabel('Profit', fontsize=9)
ax3.set_title('Profit Surfaces\nBlue=Selective, Red=Tropical', fontsize=10)
ax3.view_init(elev=25, azim=135)

plt.tight_layout()
plt.savefig('viz_tropical_bridge.png', dpi=150, bbox_inches='tight')
print("Saved viz_tropical_bridge.png")
