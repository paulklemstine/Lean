from typing import Sequence

def hankel(moments: Sequence[float], level: int) -> list[list[float]]:
    if level < 1 or len(moments) < 2*level:
        raise ValueError("insufficient moments")
    return [[moments[a+b+1] for b in range(level)] for a in range(level)]

def jacobi_min_eigenpair(a: Sequence[Sequence[float]], sweeps: int=50) -> tuple[float,list[float]]:
    # Compact Jacobi diagonalization for symmetric matrices.
    import math
    n=len(a); d=[list(row) for row in a]; v=[[float(i==j) for j in range(n)] for i in range(n)]
    for _ in range(sweeps):
        p,q=max(((i,j) for i in range(n) for j in range(i+1,n)),key=lambda z:abs(d[z[0]][z[1]]),default=(0,0))
        if p==q or abs(d[p][q])<1e-12: break
        phi=.5*math.atan2(2*d[p][q],d[q][q]-d[p][p]); c,s=math.cos(phi),math.sin(phi)
        for k in range(n):
            if k not in (p,q):
                x,y=d[k][p],d[k][q]; d[k][p]=d[p][k]=c*x-s*y; d[k][q]=d[q][k]=s*x+c*y
        x,y,z=d[p][p],d[q][q],d[p][q]; d[p][p]=c*c*x-2*s*c*z+s*s*y; d[q][q]=s*s*x+2*s*c*z+c*c*y; d[p][q]=d[q][p]=0.0
        for k in range(n): v[k][p],v[k][q]=c*v[k][p]-s*v[k][q],s*v[k][p]+c*v[k][q]
    i=min(range(n),key=lambda k:d[k][k]); return d[i][i],[v[k][i] for k in range(n)]
