from typing import Dict, List, Optional, Set, Tuple

Incidence = Dict[int, Set[int]]
Vertex = Tuple[str, int]

def extract_cycle_from_codeword(inc: Incidence, S: Set[int]) -> Optional[List[Vertex]]:
    """Constructive heart of the theorem: from a non-empty codeword S, build the
    restricted graph G|_S (edges incident to a left vertex in S) and return a
    cycle. Since every left vertex of G|_S has degree d >= 2 and every right
    vertex has even (hence 0 or >= 2) degree, no vertex has degree 1, so a cycle
    must exist. Its length equals 2 * (distinct left vertices visited) <= 2|S|.
    """
    adj: Dict[Vertex, Set[Vertex]] = {}
    for l in S:
        adj.setdefault(("L", l), set())
        for r in inc[l]:
            adj.setdefault(("R", r), set())
            adj[("L", l)].add(("R", r))
            adj[("R", r)].add(("L", l))
    visited: Set[Vertex] = set()
    parent: Dict[Vertex, Optional[Vertex]] = {}

    def dfs(u: Vertex, p: Optional[Vertex]) -> Optional[List[Vertex]]:
        visited.add(u); parent[u] = p
        for w in adj[u]:
            if w == p:
                continue
            if w in visited:
                cyc = [u]; cur = u
                while cur != w:
                    cur = parent[cur]; cyc.append(cur)
                return cyc
            res = dfs(w, u)
            if res is not None:
                return res
        return None

    for start in adj:
        if start not in visited:
            c = dfs(start, None)
            if c is not None:
                return c
    return None
