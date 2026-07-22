from __future__ import annotations
def period(t:int,m:int)->int:
 if m<=1: raise ValueError("m must exceed one")
 start=(2%m,t%m);state=start
 for p in range(1,m*m+1):
  x,y=state;state=(y,(t*y-x)%m)
  if state==start:return p
 raise RuntimeError("no return")
if __name__=="__main__":
 for m in (5,7,11,25,49,101): print(m,period(3,m))
