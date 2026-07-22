from typing import Iterable, List, Set, Tuple

def p3_counts(n: int, edges: Iterable[Tuple[int,int]]) -> Tuple[List[int],List[int],List[int]]:
    adj: List[Set[int]]=[set() for _ in range(n)]
    for u,v in edges: adj[u].add(v); adj[v].add(u)
    d=[len(x) for x in adj]
    center=[x*(x-1)//2 for x in d]
    end=[sum(d[u]-1 for u in adj[v]) for v in range(n)]
    return center,end,[center[v]+end[v] for v in range(n)]
