import matplotlib.pyplot as plt
from math import comb
from typing import List


def threshold_real(n: int, r: int) -> float:
    return n * (n - 1) / (r * (r - 1))


def main() -> None:
    ns: List[int] = list(range(2, 101))
    plt.figure(figsize=(8, 5))
    for r in (2, 3, 4, 5):
        ys = [threshold_real(n, r) for n in ns]
        plt.plot(ns, ys, label=f'r = {r}  (coeff 1/{r*(r-1)})')
    # Steiner equality points for r=3 (n = 1,3 mod 6)
    sx = [n for n in ns if n % 6 in (1, 3)]
    sy = [comb(n, 2) // comb(3, 2) for n in sx]
    plt.scatter(sx, sy, color='black', zorder=5,
                label='Steiner S(2,3,n) equality')
    plt.xlabel('number of vertices n')
    plt.ylabel('max edges  n(n-1)/(r(r-1))')
    plt.title('Sharp density threshold for linear r-uniform hypergraphs')
    plt.legend()
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('density_threshold.png', dpi=150)
    print('saved density_threshold.png')


if __name__ == '__main__':
    main()
