import matplotlib.pyplot as plt
import numpy as np
from math import gcd
from itertools import combinations
from typing import Iterable, Set


def incoherence_index(atoms: Iterable[int], n: int) -> int:
    F: Set[int] = {a % n for a in atoms}
    if not F:
        return 0
    frontier, visited = {0}, set()
    for level in range(1, n + 1):
        nxt = {(r + a) % n for r in frontier for a in F}
        if 0 in nxt:
            return level
        nxt -= visited
        if not nxt:
            return 0
        visited |= nxt
        frontier = nxt
    return 0


def main() -> None:
    N = 16
    single = np.zeros((N + 1, N + 1))
    multi = np.zeros((N + 1, N + 1))
    for n in range(2, N + 1):
        for a in range(1, n):
            single[n, incoherence_index([a], n)] = 1
        for a, b in combinations(range(1, n), 2):
            d = incoherence_index([a, b], n)
            if d:
                multi[n, d] = 1
    fig, axes = plt.subplots(1, 2, figsize=(12, 5), sharey=True)
    for ax, M, title in ((axes[0], single, 'Single-atom indices (divisors of n)'),
                         (axes[1], multi, 'Two-atom indices (fill the gaps)')):
        ax.imshow(M.T, origin='lower', aspect='auto', cmap='magma')
        ax.set_xlabel('modulus n'); ax.set_ylabel('incoherence index d')
        ax.set_title(title)
    plt.tight_layout(); plt.savefig('incoherence_spectrum.png', dpi=150)
    print('wrote incoherence_spectrum.png')


if __name__ == '__main__':
    main()
