def has_negative_cycle(n: int, edges: list[tuple[int,int,float]]) -> bool:
    dist = [0.0]*n
    for _ in range(n-1):
        for u,v,w in edges:
            if dist[u]+w < dist[v]:
                dist[v] = dist[u]+w
    for u,v,w in edges:
        if dist[u]+w < dist[v]: return True
    return False