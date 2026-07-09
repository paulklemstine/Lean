import numpy as np
import matplotlib.pyplot as plt

def main() -> None:
    t = np.linspace(-1.5, 1.8, 600)
    fig, ax = plt.subplots(figsize=(9, 5.5))
    for k in range(5):
        ax.plot(t, 1 - t ** (2 * k + 1), label=f'cc({k}) = 1 - t^{2*k+1}')
    ax.axhline(0, color='k', lw=0.8)
    ax.axvline(1, color='crimson', ls='--', lw=1.2, label='t = 1 (degeneration)')
    ax.set_xlabel('t'); ax.set_ylabel('cc(k)')
    ax.set_title('Scaling factors of the shifted t-Schur plethysm phi_t')
    ax.legend(loc='upper right', fontsize=8)
    ax.grid(alpha=0.3)
    fig.tight_layout(); fig.savefig('degeneration_spectrum.png', dpi=150)

if __name__ == '__main__':
    main()
