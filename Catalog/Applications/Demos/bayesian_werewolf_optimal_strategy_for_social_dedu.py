#!/usr/bin/env python3
"""
Bayesian Werewolf: Numerical Demonstrations

Demonstrates the key theorems proved in Lean 4:
1. Parity Paradox: Adding one villager can decrease win probability
2. Skip-Two Monotonicity: Adding two villagers always helps
3. Even-Odd Subsequence Structure: Each parity class is monotone
4. Wolf Fraction Dynamics: Correct/incorrect eliminations shift difficulty
5. Parity Defect Convergence: The paradox weakens for larger games
"""

from fractions import Fraction
from typing import Dict, List, Tuple


def win_prob(v: int, w: int, memo: Dict[Tuple[int, int], Fraction] = None) -> Fraction:
    """Compute villager win probability under random elimination.

    Matches the Lean definition exactly:
    - Base: P(v, 0) = 1 (no wolves left)
    - Terminal: P(v, w) = 0 if v ≤ w (wolves have majority)
    - Recursive: P(v, w) = w/(v+w) · P(v-1, w-1) + v/(v+w) · P(v-2, w)
      where the first term handles correct wolf elimination + night kill,
      and the second handles wrong villager elimination + night kill.
    """
    if memo is None:
        memo = {}
    if (v, w) in memo:
        return memo[(v, w)]

    if w == 0:
        result = Fraction(1)
    elif v <= w:
        result = Fraction(0)
    else:
        total = Fraction(v + w)
        # Correct elimination: wolf removed, then night kills villager
        if w == 1:
            correct_term = Fraction(1, v + w)  # w=1: wolf caught, game over
        else:
            correct_term = Fraction(w, v + w) * win_prob(v - 1, w - 1, memo)
        # Wrong elimination: villager removed, then night kills another villager
        if v - 2 <= w:
            wrong_term = Fraction(0)  # wolves gain majority
        else:
            wrong_term = Fraction(v, v + w) * win_prob(v - 2, w, memo)
        result = correct_term + wrong_term

    memo[(v, w)] = result
    return result


def demo_parity_paradox():
    """Demonstrate the Parity Paradox: P(v+1, w) < P(v, w) for certain v."""
    print("=" * 60)
    print("PARITY PARADOX: Adding one villager can HURT")
    print("=" * 60)
    print()

    for w in range(1, 4):
        print(f"  w = {w} werewolves:")
        for v in range(w + 1, 10):
            p_v = win_prob(v, w)
            p_v1 = win_prob(v + 1, w)
            marker = " ← PARADOX!" if p_v1 < p_v else ""
            print(f"    P({v},{w}) = {float(p_v):.6f}  ({p_v})")
            if marker:
                print(f"    P({v+1},{w}) = {float(p_v1):.6f}  ({p_v1}){marker}")
        print()


def demo_skip_two_monotonicity():
    """Demonstrate Skip-Two Monotonicity: P(v+2, w) > P(v, w) always."""
    print("=" * 60)
    print("SKIP-TWO MONOTONICITY: Adding TWO villagers always helps")
    print("=" * 60)
    print()

    for w in range(1, 4):
        print(f"  w = {w}:")
        for v in range(w + 2, 12):
            p_v = win_prob(v, w)
            p_v2 = win_prob(v + 2, w)
            holds = p_v2 > p_v
            print(f"    P({v},{w}) = {float(p_v):.6f} < P({v+2},{w}) = {float(p_v2):.6f}  ✓" if holds
                  else f"    P({v},{w}) = {float(p_v):.6f} ≥ P({v+2},{w}) = {float(p_v2):.6f}  ✗ VIOLATION!")
        print()


def demo_even_odd_structure():
    """Demonstrate the even-odd subsequence structure for w=1."""
    print("=" * 60)
    print("EVEN-ODD SUBSEQUENCE STRUCTURE (w=1)")
    print("=" * 60)
    print()

    print("  Even subsequence E(m) = P(2m, 1):")
    for m in range(1, 11):
        e_m = win_prob(2 * m, 1)
        print(f"    E({m:2d}) = P({2*m:2d}, 1) = {float(e_m):.8f}  ({e_m})")

    print()
    print("  Odd subsequence O(m) = P(2m+1, 1):")
    for m in range(1, 11):
        o_m = win_prob(2 * m + 1, 1)
        print(f"    O({m:2d}) = P({2*m+1:2d}, 1) = {float(o_m):.8f}  ({o_m})")

    print()
    print("  Even dominates Odd: E(m) > O(m):")
    for m in range(1, 11):
        e_m = win_prob(2 * m, 1)
        o_m = win_prob(2 * m + 1, 1)
        gap = float(e_m - o_m)
        print(f"    E({m:2d}) - O({m:2d}) = {gap:.8f}  ✓" if gap > 0
              else f"    E({m:2d}) - O({m:2d}) = {gap:.8f}  ✗")


def demo_parity_defect():
    """Demonstrate the parity defect and its convergence to 1."""
    print()
    print("=" * 60)
    print("PARITY DEFECT: D(v,1) = P(v,1)/P(v+1,1) → 1")
    print("=" * 60)
    print()

    for v in range(2, 20, 2):
        p_v = win_prob(v, 1)
        p_v1 = win_prob(v + 1, 1)
        if p_v1 > 0:
            defect = p_v / p_v1
            print(f"    D({v:2d}, 1) = {float(defect):.8f}  ({defect})")


def demo_wolf_fraction_dynamics():
    """Demonstrate how wolf fraction changes after correct/incorrect elimination."""
    print()
    print("=" * 60)
    print("WOLF FRACTION DYNAMICS")
    print("=" * 60)
    print()

    cases = [(5, 2), (7, 3), (10, 4), (8, 2)]
    for v, w in cases:
        initial = Fraction(w, v + w)
        after_correct = Fraction(w - 1, (v - 1) + (w - 1))
        after_wrong = Fraction(w, (v - 2) + w) if v - 2 > w else None

        print(f"  State ({v} villagers, {w} wolves):")
        print(f"    Initial wolf fraction: {w}/{v+w} = {float(initial):.4f}")
        print(f"    After correct elimination: {w-1}/{v+w-2} = {float(after_correct):.4f}  {'↓' if after_correct < initial else '↑'}")
        if after_wrong:
            print(f"    After wrong elimination:   {w}/{v-2+w} = {float(after_wrong):.4f}  {'↑' if after_wrong > initial else '↓'}")
        print()


def demo_diagonal_monotonicity():
    """Demonstrate diagonal monotonicity: trading wolves for villagers helps."""
    print("=" * 60)
    print("DIAGONAL MONOTONICITY: Trading a wolf for a villager helps")
    print("=" * 60)
    print()

    for n in range(5, 12):
        print(f"  n = {n} total players:")
        for w in range(1, n // 2 + 1):
            v = n - w
            p = win_prob(v, w)
            print(f"    P({v}, {w}) = {float(p):.6f}", end="")
        print()


def demo_large_game_convergence():
    """Show win probability behavior for large games."""
    print()
    print("=" * 60)
    print("LARGE GAME BEHAVIOR")
    print("=" * 60)
    print()

    for w in [1, 2, 3]:
        print(f"  w = {w} wolves:")
        for v in [10, 20, 50, 100]:
            p = win_prob(v, w)
            print(f"    P({v:3d}, {w}) = {float(p):.8f}")
        print()


if __name__ == "__main__":
    demo_parity_paradox()
    demo_skip_two_monotonicity()
    demo_even_odd_structure()
    demo_parity_defect()
    demo_wolf_fraction_dynamics()
    demo_diagonal_monotonicity()
    demo_large_game_convergence()


#!/usr/bin/env python3
"""
Visualization: The Parity Paradox in Werewolf Games

Produces a plot showing the interleaved even/odd subsequences
and the parity paradox phenomenon.
"""

import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')
from fractions import Fraction
from typing import Dict, Tuple


def win_prob(v: int, w: int, memo: Dict[Tuple[int, int], Fraction] = None) -> Fraction:
    if memo is None:
        memo = {}
    if (v, w) in memo:
        return memo[(v, w)]
    if w == 0:
        result = Fraction(1)
    elif v <= w:
        result = Fraction(0)
    else:
        if w == 1:
            correct_term = Fraction(1, v + w)
        else:
            correct_term = Fraction(w, v + w) * win_prob(v - 1, w - 1, memo)
        if v - 2 <= w:
            wrong_term = Fraction(0)
        else:
            wrong_term = Fraction(v, v + w) * win_prob(v - 2, w, memo)
        result = correct_term + wrong_term
    memo[(v, w)] = result
    return result


def main():
    memo: Dict[Tuple[int, int], Fraction] = {}

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    # Panel 1: Parity Paradox for w=1
    ax = axes[0, 0]
    vs = list(range(2, 22))
    probs = [float(win_prob(v, 1, memo)) for v in vs]
    even_vs = [v for v in vs if v % 2 == 0]
    odd_vs = [v for v in vs if v % 2 == 1]
    even_probs = [float(win_prob(v, 1, memo)) for v in even_vs]
    odd_probs = [float(win_prob(v, 1, memo)) for v in odd_vs]

    ax.plot(vs, probs, 'k-', alpha=0.3, linewidth=0.8)
    ax.plot(even_vs, even_probs, 'bo-', markersize=6, label='Even v (good parity)', linewidth=2)
    ax.plot(odd_vs, odd_probs, 'rs-', markersize=6, label='Odd v (bad parity)', linewidth=2)

    # Highlight paradox arrows
    for i in range(len(even_vs)):
        if i < len(odd_vs):
            ax.annotate('', xy=(odd_vs[i], odd_probs[i]),
                       xytext=(even_vs[i], even_probs[i]),
                       arrowprops=dict(arrowstyle='->', color='red', alpha=0.4))

    ax.set_xlabel('Number of villagers (v)', fontsize=12)
    ax.set_ylabel('Win probability P(v, 1)', fontsize=12)
    ax.set_title('The Parity Paradox (w=1)', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Panel 2: Parity Paradox for w=2
    ax = axes[0, 1]
    vs2 = list(range(3, 22))
    probs2 = [float(win_prob(v, 2, memo)) for v in vs2]
    even_vs2 = [v for v in vs2 if v % 2 == 1]  # parity shifts for w=2
    odd_vs2 = [v for v in vs2 if v % 2 == 0]
    even_probs2 = [float(win_prob(v, 2, memo)) for v in even_vs2]
    odd_probs2 = [float(win_prob(v, 2, memo)) for v in odd_vs2]

    ax.plot(vs2, probs2, 'k-', alpha=0.3, linewidth=0.8)
    ax.plot(even_vs2, even_probs2, 'bo-', markersize=6, label='Good parity', linewidth=2)
    ax.plot(odd_vs2, odd_probs2, 'rs-', markersize=6, label='Bad parity', linewidth=2)
    ax.set_xlabel('Number of villagers (v)', fontsize=12)
    ax.set_ylabel('Win probability P(v, 2)', fontsize=12)
    ax.set_title('The Parity Paradox (w=2)', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Panel 3: Parity Defect convergence
    ax = axes[1, 0]
    defect_vs = list(range(2, 30, 2))
    defects = []
    for v in defect_vs:
        p_v = win_prob(v, 1, memo)
        p_v1 = win_prob(v + 1, 1, memo)
        if p_v1 > 0:
            defects.append(float(p_v / p_v1))
        else:
            defects.append(0)

    ax.plot(defect_vs, defects, 'go-', markersize=6, linewidth=2)
    ax.axhline(y=1.0, color='gray', linestyle='--', alpha=0.5, label='D = 1 (no paradox)')
    ax.set_xlabel('Villager count v (even)', fontsize=12)
    ax.set_ylabel('Parity Defect D(v, 1)', fontsize=12)
    ax.set_title('Parity Defect Convergence to 1', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Panel 4: Diagonal monotonicity heatmap
    ax = axes[1, 1]
    max_v = 12
    max_w = 6
    data = []
    for w in range(1, max_w + 1):
        row = []
        for v in range(1, max_v + 1):
            row.append(float(win_prob(v, w, memo)))
        data.append(row)

    im = ax.imshow(data, aspect='auto', origin='lower', cmap='RdYlGn',
                   extent=[0.5, max_v + 0.5, 0.5, max_w + 0.5])
    ax.set_xlabel('Number of villagers (v)', fontsize=12)
    ax.set_ylabel('Number of werewolves (w)', fontsize=12)
    ax.set_title('Win Probability Landscape', fontsize=14, fontweight='bold')
    plt.colorbar(im, ax=ax, label='P(v, w)')

    # Add text annotations
    for w_idx, w in enumerate(range(1, max_w + 1)):
        for v in range(1, max_v + 1):
            val = data[w_idx][v - 1]
            if val > 0:
                ax.text(v, w, f'{val:.2f}', ha='center', va='center',
                       fontsize=7, color='black' if 0.3 < val < 0.7 else 'white')

    plt.tight_layout()
    plt.savefig('/workspace/request-project/Applications/BayesianWerewolf/parity_paradox.png',
                dpi=150, bbox_inches='tight')
    print("Saved parity_paradox.png")


if __name__ == "__main__":
    main()
