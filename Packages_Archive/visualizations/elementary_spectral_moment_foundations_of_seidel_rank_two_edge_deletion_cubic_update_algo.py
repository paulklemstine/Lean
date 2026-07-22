def cubic_deletion_update(s: list[list[int]], a: int, b: int) -> int:
    if s[a][b] != -1 or s[b][a] != -1:
        raise ValueError("the selected pair must be an edge")
    s2ab = sum(s[a][k] * s[k][b] for k in range(len(s)))
    return 12 * s2ab
s = [[0,-1,1],[-1,0,-1],[1,-1,0]]
print(cubic_deletion_update(s, 0, 1))
