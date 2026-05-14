def tropical_shortest_path(cost, n):
    INF = float('inf')
    dist = [row[:] for row in cost]
    for i in range(n): dist[i][i] = 0.0
    for k in range(n):
        for i in range(n):
            for j in range(n):
                if dist[i][k] + dist[k][j] < dist[i][j]:
                    dist[i][j] = dist[i][k] + dist[k][j]
    return dist