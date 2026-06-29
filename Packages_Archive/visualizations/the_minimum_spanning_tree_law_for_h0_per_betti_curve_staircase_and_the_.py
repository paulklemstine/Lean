import matplotlib.pyplot as plt
from typing import List

def beta0(deaths: List[int], t: int) -> int:
    return 1 + sum(1 for d in deaths if t < d)

def plot(deaths: List[int]) -> None:
    T = max(deaths)
    ts = list(range(T + 1))
    ys = [beta0(deaths, t) for t in ts]
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
    ax1.step(ts, ys, where='post', color='navy', lw=2)
    ax1.fill_between(ts, [y - 1 for y in ys], step='post', alpha=0.3, color='skyblue')
    ax1.set_title('beta0(t) staircase; shaded area = total persistence')
    ax1.set_xlabel('scale t'); ax1.set_ylabel('component count')
    for i, d in enumerate(sorted(deaths)):
        ax2.barh(i, min(d, T), color='salmon', edgecolor='k')
    ax2.set_title('layer-cake: per-death lifetimes min(d, T)')
    ax2.set_xlabel('lifetime'); ax2.set_ylabel('death index')
    plt.tight_layout(); plt.savefig('betti_layercake.png', dpi=140)
    print('saved betti_layercake.png; total persistence =',
          sum(min(d, T) for d in deaths))

if __name__ == '__main__':
    plot([2, 3, 3, 7])
