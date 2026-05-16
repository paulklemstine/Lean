# See algorithms.py for full implementation
def reconstruct(boundary_matrix, B, n, witnesses, reaches):
    d = [[0]*n for _ in range(n)]
    # Step 1: boundary
    for i,bi in enumerate(B):
        for j,bj in enumerate(B):
            d[bi][bj] = boundary_matrix[i][j]
    # Step 2: interior-boundary via median
    for v in range(n):
        if v not in B:
            a,b,c = witnesses[v]
            d[v][a] = (d[a][b]+d[a][c]-d[b][c])/2
            d[a][v] = d[v][a]
    # Step 3: interior-interior via reach
    for (x,y),s in reaches.items():
        d[x][y] = d[y][s] - d[x][s]
        d[y][x] = d[x][y]
    return d