def greedy_hitting_set(vertices, edges):
    from collections import defaultdict
    T, remaining = set(), list(edges)
    verts = set(vertices)
    while remaining:
        deg = defaultdict(int)
        for e in remaining:
            for v in e:
                if v in verts and v not in T: deg[v] += 1
        if not deg: break
        best = max(deg, key=deg.get)
        T.add(best); verts.discard(best)
        remaining = [e for e in remaining if best not in e]
    return T, len(T)