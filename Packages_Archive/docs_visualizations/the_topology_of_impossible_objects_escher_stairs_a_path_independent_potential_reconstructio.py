from typing import Sequence
Grid = list[list[int]]
def reconstruct(a: Sequence[Sequence[int]], b: Sequence[Sequence[int]]) -> Grid:
    n, m = len(a), len(a[0]); h = [[0]*m for _ in range(n)]
    for i in range(1,m): h[0][i] = h[0][i-1] + a[0][i-1]
    for i in range(m):
        for j in range(1,n): h[j][i] = h[j-1][i] + b[j-1][i]
    aa = [[h[j][(i+1)%m]-h[j][i] for i in range(m)] for j in range(n)]
    bb = [[h[(j+1)%n][i]-h[j][i] for i in range(m)] for j in range(n)]
    if aa != [list(r) for r in a] or bb != [list(r) for r in b]: raise ValueError("not developable")
    return h
if __name__ == "__main__":
    h = [[i*i-2*j for i in range(4)] for j in range(3)]
    a = [[h[j][(i+1)%4]-h[j][i] for i in range(4)] for j in range(3)]
    b = [[h[(j+1)%3][i]-h[j][i] for i in range(4)] for j in range(3)]
    print(reconstruct(a,b))
