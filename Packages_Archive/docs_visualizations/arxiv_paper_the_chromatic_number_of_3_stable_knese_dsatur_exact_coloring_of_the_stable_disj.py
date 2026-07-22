from itertools import combinations
from typing import List, Set, Tuple

def graph(n: int, k: int, s: int) -> Tuple[List[Tuple[int, ...]], List[Set[int]]]:
    vertices = []
    for a in combinations(range(1, n + 1), k):
        gaps = [a[i+1]-a[i] for i in range(k-1)] + [n+a[0]-a[-1]]
        if min(gaps) >= s: vertices.append(a)
    adj = [set() for _ in vertices]
    for i, j in combinations(range(len(vertices)), 2):
        if set(vertices[i]).isdisjoint(vertices[j]): adj[i].add(j); adj[j].add(i)
    return vertices, adj

def colorable(adj: List[Set[int]], m: int) -> bool:
    colors = [-1] * len(adj)
    def visit(done: int) -> bool:
        if done == len(adj): return True
        candidates = [v for v in range(len(adj)) if colors[v] < 0]
        v = max(candidates, key=lambda x: (len({colors[y] for y in adj[x] if colors[y]>=0}), len(adj[x])))
        forbidden = {colors[y] for y in adj[v]}
        for c in range(m):
            if c not in forbidden:
                colors[v] = c
                if visit(done + 1): return True
                colors[v] = -1
        return False
    return visit(0)

def main() -> None:
    vertices, adj = graph(9, 3, 3)
    print("vertices:", vertices)
    print("2-colorable:", colorable(adj, 2))
    print("3-colorable:", colorable(adj, 3))

if __name__ == "__main__": main()
