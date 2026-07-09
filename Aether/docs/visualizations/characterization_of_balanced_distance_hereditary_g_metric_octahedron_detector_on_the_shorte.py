from collections import deque
from itertools import combinations
from typing import Dict, List, Sequence, Set, Tuple

def bfs_distances(n: int, adj: List[Set[int]]) -> List[List[int]]:
    INF = 10 ** 9
    D = [[INF] * n for _ in range(n)]
    for s in range(n):
        D[s][s] = 0
        q = deque([s])
        while q:
            u = q.popleft()
            for w in adj[u]:
                if D[s][w] == INF:
                    D[s][w] = D[s][u] + 1
                    q.append(w)
    return D

def _three_pairings(s: Sequence[int]):
    a = s[0]; rest = list(s[1:])
    for i in range(len(rest)):
        remain = rest[:i] + rest[i+1:]
        for j in range(1, len(remain)):
            last = [x for k, x in enumerate(remain) if k not in (0, j)]
            yield ((a, rest[i]), (remain[0], remain[j]), (last[0], last[1]))

def metric_detect(n: int, edges: List[Tuple[int, int]]) -> bool:
    adj: List[Set[int]] = [set() for _ in range(n)]
    for u, v in edges:
        adj[u].add(v); adj[v].add(u)
    D = bfs_distances(n, adj)
    for s in combinations(range(n), 6):
        for pairs in _three_pairings(s):
            part = {v: k for k, pr in enumerate(pairs) for v in pr}
            verts = [v for pr in pairs for v in pr]
            if all(D[a][b] == 2 for a, b in pairs) and all(
                D[u][w] == 1 for u, w in combinations(verts, 2)
                if part[u] != part[w]):
                return True
    return False

if __name__ == "__main__":
    oct_edges = [(i, j) for i, j in combinations(range(6), 2) if i // 2 != j // 2]
    print("octahedron detected metrically:", metric_detect(6, oct_edges))
