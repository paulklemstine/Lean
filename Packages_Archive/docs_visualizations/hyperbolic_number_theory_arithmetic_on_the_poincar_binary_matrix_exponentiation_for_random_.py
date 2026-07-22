from __future__ import annotations
from typing import TypeAlias
Mat: TypeAlias=tuple[tuple[int,int],tuple[int,int]]
def mul(a:Mat,b:Mat,m:int)->Mat:
 return tuple(tuple(sum(a[i][k]*b[k][j] for k in range(2))%m for j in range(2)) for i in range(2)) # type: ignore
def power(a:Mat,n:int,m:int)->Mat:
 r:Mat=((1,0),(0,1))
 while n:
  if n&1:r=mul(r,a,m)
  a=mul(a,a,m);n//=2
 return r
def pair(t:int,n:int,m:int)->tuple[int,int]:
 p=power(((0,1),(-1,t)),n,m)
 return ((2*p[0][0]+t*p[0][1])%m,(2*p[1][0]+t*p[1][1])%m)
if __name__=="__main__":
 t,n,m=3,10**18,1009;x,y=pair(t,n,m)
 print((x,y),(x*x-t*x*y+y*y)%m)
 assert (x*x-t*x*y+y*y)%m==(4-t*t)%m
