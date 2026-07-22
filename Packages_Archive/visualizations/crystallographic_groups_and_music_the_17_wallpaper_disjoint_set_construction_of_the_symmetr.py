from __future__ import annotations
from typing import Iterable

def quotient_classes(n: int, pairs: Iterable[tuple[int, int]]) -> list[list[int]]:
    parent=list(range(n)); rank=[0]*n
    def find(x: int) -> int:
        while parent[x] != x:
            parent[x] = parent[parent[x]]; x = parent[x]
        return x
    for a,b in pairs:
        a,b=find(a),find(b)
        if a == b: continue
        if rank[a] < rank[b]: a,b=b,a
        parent[b]=a
        if rank[a] == rank[b]: rank[a]+=1
    groups: dict[int,list[int]]={}
    for x in range(n): groups.setdefault(find(x),[]).append(x)
    return list(groups.values())
