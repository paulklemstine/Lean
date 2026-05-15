def has_branching_obstruction(vertices, edges):
    from collections import defaultdict
    adj = defaultdict(list)
    for u, v in edges:
        adj[u].append(v)
    for v in vertices:
        if len(adj[v]) >= 2:
            return (v, adj[v][0], adj[v][1])
    return None