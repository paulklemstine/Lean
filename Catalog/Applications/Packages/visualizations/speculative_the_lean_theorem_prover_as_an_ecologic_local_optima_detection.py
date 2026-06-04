def find_local_optima(adj, fitness):
    return [v for v in adj if all(fitness[v] >= fitness[u] for u in adj[v])]