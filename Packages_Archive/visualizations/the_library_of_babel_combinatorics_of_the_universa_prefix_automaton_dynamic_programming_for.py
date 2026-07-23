from typing import Sequence

def exact_count(A: int, L: int, pattern: Sequence[int]) -> int:
    q=tuple(pattern); m=len(q)
    def step(r: int, a: int) -> int:
        candidate=q[:r]+(a,)
        return max((k for k in range(1,m+1) if candidate[-k:] == q[:k]), default=0)
    trans=[[step(r,a) for a in range(A)] for r in range(m)]
    dp=[1]+[0]*(m-1)
    for _ in range(L):
        nxt=[0]*m
        for r,count in enumerate(dp):
            for a in range(A):
                s=trans[r][a]
                if s<m: nxt[s]+=count
        dp=nxt
    return A**L-sum(dp)
