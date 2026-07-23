from typing import List

def de_bruijn(A: int, k: int) -> List[int]:
    work=[0]*(A*k+1); out: List[int]=[]
    def visit(t: int, p: int) -> None:
        if t>k:
            if k%p==0: out.extend(work[1:p+1])
            return
        work[t]=work[t-p]; visit(t+1,p)
        for symbol in range(work[t-p]+1,A):
            work[t]=symbol; visit(t+1,t)
    visit(1,1)
    return out
