def coarse_grain(nodes, edges, depths, threshold):
    deep = {n for n in nodes if depths[n] > threshold}
    if not deep:
        return nodes, edges, depths
    merged = '[merged]'
    new_nodes = [n for n in nodes if n not in deep] + [merged]
    new_edges = []
    for t, deps in edges:
        nt = merged if t in deep else t
        nd = [merged if d in deep else d for d in deps]
        new_edges.append((nt, list(set(nd))))
    new_depths = {n: depths[n] for n in new_nodes if n != merged}
    new_depths[merged] = threshold + 1
    return new_nodes, new_edges, new_depths