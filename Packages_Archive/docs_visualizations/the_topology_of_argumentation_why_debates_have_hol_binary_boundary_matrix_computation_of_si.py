from __future__ import annotations
from typing import FrozenSet
Face=FrozenSet[int]
def binary_rank(rows: list[int]) -> int:
    pivots: dict[int,int]={}
    for row in rows:
        while row:
            p=row.bit_length()-1
            if p in pivots: row ^= pivots[p]
            else: pivots[p]=row; break
    return len(pivots)
def betti(faces: set[Face]) -> list[int]:
    fs=[[f for f in faces if len(f)==d+1] for d in range(max(map(len,faces)))]
    ranks=[0]*(len(fs)+1)
    for d in range(1,len(fs)):
        cols={f:i for i,f in enumerate(fs[d])}
        rows=[]
        for low in fs[d-1]:
            row=0
            for high,i in cols.items():
                if low < high: row |= 1 << i
            rows.append(row)
        ranks[d]=binary_rank(rows)
    return [len(fs[d])-ranks[d]-ranks[d+1] for d in range(len(fs))]
