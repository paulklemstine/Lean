#!/usr/bin/env python3
"""Visualization: Per-Round Gap Certificates"""
try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt

    scores = {"A": 1.0, "B": 3.5, "C": 5.0, "D": 7.0, "E": 10.0, "F": 14.0}
    active = dict(scores)
    rounds, gaps, losers = [], [], []
    r = 0
    while len(active) > 1:
        r += 1
        sv = sorted(active.values())
        gap = sv[1] - sv[0]
        loser = min(active, key=lambda c: active[c])
        rounds.append(r)
        gaps.append(gap)
        losers.append(loser)
        del active[loser]

    min_gap = min(gaps)
    colors = ['#e74c3c' if g == min_gap else '#3498db' for g in gaps]

    fig, ax = plt.subplots(figsize=(8, 5))
    bars = ax.bar(rounds, gaps, color=colors, edgecolor='black', linewidth=0.5)
    ax.axhline(y=min_gap, color='red', linestyle='--', linewidth=1.5, label=f'Overall cert. γ = {min_gap}')

    for i, (r, g, l) in enumerate(zip(rounds, gaps, losers)):
        ax.text(r, g + 0.1, f'elim {l}', ha='center', fontsize=10)

    ax.set_xlabel('Elimination Round', fontsize=13)
    ax.set_ylabel('Gap', fontsize=13)
    ax.set_title('Per-Round Gap Certificates', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, axis='y', alpha=0.3)
    plt.tight_layout()
    plt.savefig('per_round_gaps.png', dpi=150)
    print('Saved per_round_gaps.png')
except ImportError:
    print('matplotlib not available; skipping visualization')
