import matplotlib.pyplot as plt
import math
from typing import Dict, List

def plot_firing() -> None:
    n = 5
    V = list(range(n))
    pos = {v: (math.cos(2*math.pi*v/n), math.sin(2*math.pi*v/n)) for v in V}
    fired = 0
    div: Dict[int, int] = {v: (-(n-1) if v == fired else 1) for v in V}
    fig, ax = plt.subplots(figsize=(6, 6))
    for u in V:
        for w in V:
            if u < w:
                ax.plot([pos[u][0], pos[w][0]], [pos[u][1], pos[w][1]],
                        color='lightgray', zorder=1)
    for w in V:
        if w != fired:
            ax.annotate('', xy=pos[w], xytext=pos[fired],
                        arrowprops=dict(arrowstyle='->', color='crimson'))
    for v in V:
        ax.scatter(*pos[v], s=900, color='steelblue', zorder=3)
        ax.text(pos[v][0], pos[v][1], f'{div[v]:+d}', color='white',
                ha='center', va='center', fontsize=12, zorder=4)
    ax.set_title(f'Firing vertex {fired} of K_5  (deg of divisor = {sum(div.values())})')
    ax.set_aspect('equal'); ax.axis('off')
    fig.tight_layout(); fig.savefig('firing_k5.png', dpi=150)
    print('saved firing_k5.png')

if __name__ == '__main__':
    plot_firing()
