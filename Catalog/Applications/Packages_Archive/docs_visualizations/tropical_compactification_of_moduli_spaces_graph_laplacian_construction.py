def graph_laplacian(n: int, edges: list[tuple[int,int]]) -> list[list[int]]:
    L = [[0]*n for _ in range(n)]
    for u, v in edges:
        L[u][v] = -1; L[v][u] = -1
        L[u][u] += 1; L[v][v] += 1
    return L