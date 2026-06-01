def cayley_diameter(n, gens):
    dist = [-1]*n; dist[0] = 0; q = [0]; md = 0
    while q:
        v = q.pop(0)
        for s in gens:
            w = (v+s)%n
            if dist[w]==-1:
                dist[w] = dist[v]+1
                md = max(md, dist[w]); q.append(w)
    return md