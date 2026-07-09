import matplotlib.pyplot as plt
import numpy as np

def plot_intervals() -> None:
    D = np.arange(1, 13)
    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(D, D, 'o-', label='upper endpoint  D')
    ax.plot(D, 1.0 / D, 's-', label='lower endpoint  1/D')
    ax.axhline(1.0, color='gray', ls='--', label='neutral ratio 1')
    for d in D:
        ax.plot([d, d], [1.0/d, d], color='lightblue', lw=6, alpha=0.4, zorder=0)
    ax.set_yscale('log')
    ax.set_xlabel('absolute determinant  D = |det M|')
    ax.set_ylabel('ratio  k(Mx)/k(x)  (log scale)')
    ax.set_title('Ratio-spectrum target interval [1/D, D]')
    ax.legend()
    fig.tight_layout()
    fig.savefig('ratio_intervals.png', dpi=150)

if __name__ == '__main__':
    plot_intervals()
