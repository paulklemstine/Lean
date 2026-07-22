from __future__ import annotations

def longest_path_length(n: int, edges: list[tuple[int, int]]) -> int:
    """Return the length of a longest simple path; by the backbone theorem this
    is at least the minimum degree of the graph."""
    adj: list[set[int]] = [set() for _ in range(n)]
    for a, b in edges:
        adj[a].add(b); adj[b].add(a)
    best = 0
    def dfs(v: int, visited: set[int], length: int) -> None:
        nonlocal best
        best = max(best, length)
        for w in adj[v]:
            if w not in visited:
                visited.add(w); dfs(w, visited, length + 1); visited.remove(w)
    for s in range(n):
        dfs(s, {s}, 0)
    return best
