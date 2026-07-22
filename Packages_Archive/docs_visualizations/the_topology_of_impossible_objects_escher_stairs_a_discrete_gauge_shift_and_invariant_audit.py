from typing import Sequence
Grid = list[list[int]]
def gauge_shift(a: Sequence[Sequence[int]], b: Sequence[Sequence[int]], g: Sequence[Sequence[int]]) -> tuple[Grid, Grid]:
    n, m = len(g), len(g[0])
    return ([[a[j][i] + g[j][(i+1)%m] - g[j][i] for i in range(m)] for j in range(n)],
            [[b[j][i] + g[(j+1)%n][i] - g[j][i] for i in range(m)] for j in range(n)])
if __name__ == "__main__":
    a, b = [[-1]*3 for _ in range(3)], [[0]*3 for _ in range(3)]
    g = [[i-j for i in range(3)] for j in range(3)]
    print(gauge_shift(a, b, g))
