import matplotlib.pyplot as plt
import numpy as np

def main() -> None:
    ms = list(range(3, 11))
    ns = [4 * m + 3 for m in ms]
    overall = [(n - 1) // 2 for n in ns]
    selfdual = [2 * m for m in ms]
    x = np.arange(len(ms)); w = 0.38
    fig, ax = plt.subplots(figsize=(10, 5))
    ax.bar(x - w / 2, overall, w, label='overall max  floor((n-1)/2)')
    ax.bar(x + w / 2, selfdual, w, label='self-dual max  2m')
    ax.set_xticks(x)
    ax.set_xticklabels([f'A_{n}' for n in ns])
    ax.set_ylabel('rank')
    ax.set_title('One-rank gap forced by self-duality (n = 4m+3)')
    ax.legend()
    for xi, (o, s) in enumerate(zip(overall, selfdual)):
        ax.text(xi, max(o, s) + 0.1, f'gap={o - s}', ha='center')
    fig.tight_layout()
    fig.savefig('selfdual_rank_gap.png', dpi=150)
    print('saved selfdual_rank_gap.png')

if __name__ == '__main__':
    main()
