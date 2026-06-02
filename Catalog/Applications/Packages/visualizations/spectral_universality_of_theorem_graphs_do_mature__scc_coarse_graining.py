def coarse_grain(adj):
    sccs = tarjan_scc(adj)
    m = len(sccs)
    block_of = {v: b for b, scc in enumerate(sccs) for v in scc}
    new_adj = np.zeros((m, m), dtype=bool)
    for i in range(len(adj)):
        for j in range(len(adj)):
            if adj[i][j]:
                b1, b2 = block_of[i], block_of[j]
                if b1 != b2:
                    new_adj[b1][b2] = True
    return new_adj