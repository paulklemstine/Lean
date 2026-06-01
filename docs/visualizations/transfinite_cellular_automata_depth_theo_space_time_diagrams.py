"""
Visualization: Space-Time Diagrams for the Convergence Spectrum

Generates space-time plots showing the evolution of cellular automata
under different rules (OR, NOT, AND, Rule 110) to illustrate the
convergence spectrum classification.
"""

import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import numpy as np


def eca_rule_func(rule_number: int):
    """Return ECA rule function for given rule number."""
    def rule(left: bool, center: bool, right: bool) -> bool:
        idx = (4 if left else 0) + (2 if center else 0) + (1 if right else 0)
        return bool((rule_number >> idx) & 1)
    return rule


def ca_step(rule, cfg):
    """Apply one step with periodic boundary."""
    n = len(cfg)
    return [rule(cfg[(i-1) % n], cfg[i], cfg[(i+1) % n]) for i in range(n)]


def ca_evolve(rule, cfg, steps):
    """Return full space-time diagram as 2D array."""
    result = [cfg[:]]
    current = cfg[:]
    for _ in range(steps):
        current = ca_step(rule, current)
        result.append(current[:])
    return result


def main():
    size = 81
    steps = 80

    # Initial config: single true cell at center
    cfg_single = [False] * size
    cfg_single[size // 2] = True

    # Random-ish initial config
    np.random.seed(42)
    cfg_random = [bool(x) for x in np.random.choice([0, 1], size=size)]

    rules = {
        'OR Rule (254) — Depth 1\nSingle seed': (eca_rule_func(254), cfg_single),
        'NOT Rule (51) — Depth ∞\nRandom init': (eca_rule_func(51), cfg_random),
        'AND Rule (128) — Monotone\nRandom init': (eca_rule_func(128), cfg_random),
        'Identity (204) — Depth 0\nRandom init': (eca_rule_func(204), cfg_random),
    }

    fig, axes = plt.subplots(2, 2, figsize=(14, 12))
    fig.suptitle('Convergence Spectrum: Space-Time Diagrams', fontsize=16, fontweight='bold')

    cmap = mcolors.ListedColormap(['#1a1a2e', '#e94560'])

    for ax, (title, (rule, cfg)) in zip(axes.flat, rules.items()):
        spacetime = ca_evolve(rule, cfg, steps)
        data = np.array(spacetime, dtype=int)

        ax.imshow(data, cmap=cmap, aspect='auto', interpolation='nearest')
        ax.set_title(title, fontsize=11)
        ax.set_xlabel('Cell position')
        ax.set_ylabel('Time step')

    plt.tight_layout()
    plt.savefig('spacetime_diagrams.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved spacetime_diagrams.png")


if __name__ == "__main__":
    main()
