import numpy as np
import matplotlib.pyplot as plt


def expected_occ(b: int, L: int, k: int) -> float:
    return (L - k + 1) * (b ** (-k))


def main() -> None:
    L = 1_000_000
    ks = np.arange(1, 16)
    plt.figure(figsize=(9, 6))
    for b in [2, 4, 10, 26]:
        ys = [expected_occ(b, L, int(k)) for k in ks]
        plt.semilogy(ks, ys, marker='o', label=f'b = {b}')
    plt.axhline(1.0, color='gray', linestyle='--', label='one expected copy')
    plt.xlabel('pattern length k')
    plt.ylabel('E[occurrences]  (log scale)')
    plt.title(f'The exponential cliff of meaning  (L = {L})')
    plt.legend()
    plt.grid(True, which='both', alpha=0.3)
    plt.tight_layout()
    plt.savefig('exponential_cliff.png', dpi=150)
    print('wrote exponential_cliff.png')


if __name__ == '__main__':
    main()