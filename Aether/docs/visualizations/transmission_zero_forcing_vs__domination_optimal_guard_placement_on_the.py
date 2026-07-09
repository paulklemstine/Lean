import matplotlib.pyplot as plt
from typing import FrozenSet


def dom_construction(n: int) -> FrozenSet[int]:
    if n == 0:
        return frozenset()
    m = (n + 2) // 3
    return frozenset(min(3 * k + 1, n - 1) for k in range(m))


def main(n: int = 10) -> None:
    guards = dom_construction(n)
    fig, ax = plt.subplots(figsize=(1.0 * n, 2.2))
    for v in range(n - 1):
        ax.plot([v, v + 1], [0, 0], color='gray', zorder=1)
    for g in guards:
        for u in (g - 1, g, g + 1):
            if 0 <= u < n:
                ax.scatter([u], [0], s=900, color='#ffd27f', zorder=2)
    for v in range(n):
        is_guard = v in guards
        ax.scatter([v], [0], s=420,
                   color='#d62728' if is_guard else '#1f77b4', zorder=3)
        ax.annotate(str(v), (v, 0), color='white', ha='center', va='center',
                    zorder=4, fontsize=9)
    ax.set_title(f'P_{n}: optimal guards (red) and their coverage (amber)')
    ax.set_ylim(-1, 1)
    ax.axis('off')
    fig.tight_layout()
    fig.savefig('path_guards.png', dpi=150)
    print('wrote path_guards.png')


if __name__ == "__main__":
    main()
