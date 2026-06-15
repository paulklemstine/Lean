from itertools import combinations

def greedy_triangle_removal(graph, n):
    def is_tri(h,a,b,c):
        return all(frozenset(e) in h for e in [(a,b),(a,c),(b,c)])
    h = set(graph); removed = 0
    for a,b,c in combinations(range(n),3):
        if is_tri(graph,a,b,c) and is_tri(h,a,b,c):
            h.discard(frozenset((a,b))); removed += 1
    return h, removed
