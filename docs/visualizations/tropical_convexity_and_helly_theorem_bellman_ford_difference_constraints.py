def bellman_ford(n, constraints):
    dist = [0.0] * n
    for _ in range(n):
        for i, j, c in constraints:
            if dist[j] + c < dist[i]:
                dist[i] = dist[j] + c
    for i, j, c in constraints:
        if dist[j] + c < dist[i] - 1e-12:
            return False, None
    return True, [-d for d in dist]