from __future__ import annotations

def pell_form(t: int, x: int, y: int) -> int:
    return x*x-t*x*y+y*y

def pairs(t: int, count: int) -> list[tuple[int,int]]:
    out: list[tuple[int,int]]=[]
    x,y=2,t
    for _ in range(count):
        out.append((x,y)); x,y=y,t*y-x
    return out

def certified_orbit(t:int,n:int)->list[tuple[int,int]]:
 out=pairs(t,n);target=4-t*t
 assert all(pell_form(t,x,y)==target for x,y in out)
 return out
