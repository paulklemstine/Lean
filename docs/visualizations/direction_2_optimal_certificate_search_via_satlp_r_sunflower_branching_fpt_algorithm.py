def sunflower_branch(vertices, edges, d):
    from itertools import combinations
    if not edges: return set(), 0
    # Try to find sunflower of size d+1
    for combo in combinations(range(len(edges)), d+1):
        group = [edges[i] for i in combo]
        pairs = list(combinations(group, 2))
        if not pairs: continue
        kernel = pairs[0][0] & pairs[0][1]
        if all(e1 & e2 == kernel for e1, e2 in pairs):
            if kernel:
                best = None
                for v in kernel:
                    sub_edges = [e for e in edges if v not in e]
                    sub_T, _ = sunflower_branch(vertices - {v}, sub_edges, d)
                    cand = sub_T | {v}
                    if best is None or len(cand) < len(best):
                        best = cand
                return best, len(best)
    # Fallback to greedy
    return greedy_hitting_set(vertices, edges)