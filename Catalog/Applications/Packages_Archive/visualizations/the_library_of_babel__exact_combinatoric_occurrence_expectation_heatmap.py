import numpy as np
import matplotlib.pyplot as plt


def expected_occ(b: int, L: int, k: int) -> float:
    return (L - k + 1) * (b ** (-k))


def main() -> None:
    L = 10000
    bs = list(range(2, 27))
    ks = list(range(1, 13))
    Z = np.zeros((len(bs), len(ks)))
    for i, b in enumerate(bs):
        for j, k in enumerate(ks):
            Z[i, j] = expected_occ(b, L, k)
    plt.figure(figsize=(9, 6))
    plt.imshow(np.log10(Z + 1e-300), aspect='auto', origin='lower',
               extent=[ks[0]-0.5, ks[-1]+0.5, bs[0]-0.5, bs[-1]+0.5],
               cmap='magma')
    cbar = plt.colorbar()
    cbar.set_label('log10  E[occurrences]')
    plt.xlabel('pattern length k')
    plt.ylabel('alphabet size b')
    plt.title(f'Expected occurrences (L-k+1)*b^-k   (L={L})')
    plt.tight_layout()
    plt.savefig('occurrence_heatmap.png', dpi=150)
    print('wrote occurrence_heatmap.png')


if __name__ == '__main__':
    main()