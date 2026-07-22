from typing import Sequence
def switch_seidel(s: list[list[int]], d: Sequence[int]) -> list[list[int]]:
    if len(s) != len(d) or any(x not in (-1, 1) for x in d):
        raise ValueError("invalid switching signs")
    return [[d[i]*s[i][j]*d[j] for j in range(len(s))] for i in range(len(s))]
s = [[0,-1,1],[-1,0,-1],[1,-1,0]]
t = switch_seidel(s, [-1,1,-1])
print(s, t, sep="\n")
