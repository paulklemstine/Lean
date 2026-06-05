#!/usr/bin/env python3
"""
Bayesian Werewolf: Numerical demonstrations of optimal strategy analysis.

Computes exact win probabilities, information advantages, and wolf fraction
dynamics for the Werewolf/Mafia social deduction game.
"""
from fractions import Fraction
from functools import lru_cache


@lru_cache(maxsize=None)
def P(w: int, v: int) -> Fraction:
    """Villager win probability under random elimination.

    Args:
        w: Number of werewolves remaining
        v: Number of villagers remaining

    Returns:
        Exact win probability as a Fraction
    """
    if w == 0:
        return Fraction(1) if v > 0 else Fraction(0)
    if w >= v:
        return Fraction(0)
    if v <= 1:
        return Fraction(0)
    n = w + v
    return Fraction(w, n) * P(w - 1, v - 1) + Fraction(v, n) * P(w, v - 2)


def wolf_fraction(w: int, v: int) -> float:
    """Werewolf fraction w/(w+v)."""
    return w / (w + v) if w + v > 0 else 0.0


def info_advantage(w: int, v: int) -> float:
    """Information advantage: 1 / P(w, v)."""
    p = P(w, v)
    return float(1 / p) if p > 0 else float('inf')


def main():
    print("=" * 65)
    print("BAYESIAN WEREWOLF: Win Probability Analysis")
    print("=" * 65)

    # Table 1: Win probabilities for various game sizes
    print("\n--- Table 1: Villager Win Probability P(w, v) ---")
    print(f"{'(w,v)':<12} {'P(w,v)':<15} {'Decimal':<10} {'Info Adv':<10}")
    print("-" * 50)
    cases = [(1, 2), (1, 3), (1, 4), (1, 6), (1, 8),
             (2, 3), (2, 5), (2, 7), (2, 9),
             (3, 4), (3, 6), (3, 8), (3, 10)]
    for w, v in cases:
        p = P(w, v)
        adv = info_advantage(w, v)
        print(f"({w},{v}){'':<7} {str(p):<15} {float(p):<10.4f} {adv:<10.2f}")

    # Table 2: Werewolf advantage theorem verification
    print("\n--- Table 2: Werewolf Advantage P(w,v) ≤ v/(w+v) ---")
    print(f"{'(w,v)':<12} {'P(w,v)':<10} {'v/(w+v)':<10} {'Gap':<10}")
    print("-" * 42)
    for w, v in cases:
        p = float(P(w, v))
        bound = v / (w + v)
        print(f"({w},{v}){'':<7} {p:<10.4f} {bound:<10.4f} {bound - p:<10.4f}")

    # Table 3: One-wolf recurrence verification
    print("\n--- Table 3: One-Wolf Recurrence Verification ---")
    print("P(1,v) = 1/(1+v) + v/(1+v) * P(1,v-2)")
    for v in range(2, 13, 2):
        lhs = P(1, v)
        rhs = Fraction(1, 1 + v) + Fraction(v, 1 + v) * P(1, v - 2)
        print(f"  v={v}: P(1,{v}) = {lhs} = {float(lhs):.6f}  [recurrence check: {lhs == rhs}]")

    # Table 4: Configuration counting
    print("\n--- Table 4: Configuration Count C(n,k) ---")
    from math import comb
    print(f"{'n':<5} {'k':<5} {'C(n,k)':<10} {'C(n-1,k-1)*n':<15} {'C(n,k)*k':<10}")
    print("-" * 50)
    for n, k in [(7, 2), (10, 3), (15, 5), (20, 4)]:
        c = comb(n, k)
        lhs = comb(n - 1, k - 1) * n
        rhs = c * k
        print(f"{n:<5} {k:<5} {c:<10} {lhs:<15} {rhs:<10}  [equal: {lhs == rhs}]")

    # Table 5: BFT threshold
    print("\n--- Table 5: Byzantine Fault Tolerance Threshold ---")
    print("3w < n ⟺ 2w < v (n = w + v)")
    for w in range(1, 6):
        v_crit = 2 * w + 1  # minimum v for safety
        n = w + v_crit
        print(f"  w={w}: safe zone v > {2*w}, critical at v={2*w}, "
              f"BFT threshold n > {3*w} (actual n={n})")

    # Simulation: Information advantage scaling
    print("\n--- Table 6: Information Advantage Scaling ---")
    print(f"{'n':<6} {'k':<4} {'P(k,n-k)':<12} {'Info Adv':<10} {'Wolf Frac':<10}")
    print("-" * 45)
    for n in range(5, 22, 2):
        k = n // 3  # roughly 1/3 werewolves
        if k == 0:
            k = 1
        v = n - k
        if k < v:
            p = float(P(k, v))
            adv = 1.0 / p if p > 0 else float('inf')
            wf = k / n
            print(f"{n:<6} {k:<4} {p:<12.6f} {adv:<10.2f} {wf:<10.3f}")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Villager Win Probability Heatmap and Werewolf Advantage Bound.
Self-contained matplotlib script.
"""
import numpy as np
from fractions import Fraction
from functools import lru_cache

@lru_cache(maxsize=None)
def P(w: int, v: int) -> float:
    if w == 0:
        return 1.0 if v > 0 else 0.0
    if w >= v or v <= 1:
        return 0.0
    n = w + v
    return (w / n) * P(w - 1, v - 1) + (v / n) * P(w, v - 2)

def main():
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    from matplotlib.colors import LinearSegmentedColormap

    max_w, max_v = 10, 20
    data = np.zeros((max_w, max_v))
    for w in range(1, max_w + 1):
        for v in range(1, max_v + 1):
            data[w - 1, v - 1] = P(w, v)

    fig, axes = plt.subplots(1, 2, figsize=(16, 7))

    # Plot 1: Win probability heatmap
    ax1 = axes[0]
    cmap = LinearSegmentedColormap.from_list('werewolf',
        [(0.1, 0.0, 0.0), (0.8, 0.2, 0.2), (1.0, 0.8, 0.2), (0.2, 0.8, 0.2)])
    im = ax1.imshow(data, origin='lower', aspect='auto', cmap=cmap,
                     extent=[0.5, max_v + 0.5, 0.5, max_w + 0.5])
    ax1.set_xlabel('Villagers (v)', fontsize=12)
    ax1.set_ylabel('Werewolves (w)', fontsize=12)
    ax1.set_title('Villager Win Probability P(w, v)\nunder Random Elimination', fontsize=14)
    plt.colorbar(im, ax=ax1, label='Win Probability')

    # Add diagonal line for w = v (werewolf domination)
    ax1.plot([0.5, max_w + 0.5], [0.5, max_w + 0.5], 'w--', linewidth=2,
             label='w = v (werewolf wins)')
    ax1.legend(loc='upper left', fontsize=10)

    # Plot 2: Werewolf advantage bound verification
    ax2 = axes[1]
    ws = [1, 2, 3, 4]
    colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3']
    for w, color in zip(ws, colors):
        vs = list(range(w + 1, max_v + 1))
        probs = [P(w, v) for v in vs]
        bounds = [v / (w + v) for v in vs]
        ax2.plot(vs, probs, 'o-', color=color, markersize=4,
                 label=f'P({w}, v)', alpha=0.8)
        ax2.plot(vs, bounds, '--', color=color, alpha=0.5,
                 label=f'v/(w+v) bound')

    ax2.set_xlabel('Villagers (v)', fontsize=12)
    ax2.set_ylabel('Probability', fontsize=12)
    ax2.set_title('Werewolf Advantage Theorem\nP(w,v) ≤ v/(w+v)', fontsize=14)
    ax2.legend(fontsize=8, ncol=2)
    ax2.set_ylim(-0.05, 1.05)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('werewolf_analysis.png', dpi=150, bbox_inches='tight')
    print("Saved werewolf_analysis.png")

if __name__ == "__main__":
    main()
