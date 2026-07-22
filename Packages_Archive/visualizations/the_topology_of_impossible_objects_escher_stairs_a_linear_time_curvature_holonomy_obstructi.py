from typing import Sequence
Grid = list[list[int]]
def obstruction(a: Sequence[Sequence[int]], b: Sequence[Sequence[int]]) -> tuple[Grid, int, int]:
    n, m = len(a), len(a[0])
    c = [[a[j][i] + b[j][(i+1)%m] - a[(j+1)%n][i] - b[j][i]
          for i in range(m)] for j in range(n)]
    return c, sum(a[0]), sum(row[0] for row in b)
if __name__ == "__main__":
    a, b = [[-1]*3 for _ in range(3)], [[0]*3 for _ in range(3)]
    print(obstruction(a, b))
