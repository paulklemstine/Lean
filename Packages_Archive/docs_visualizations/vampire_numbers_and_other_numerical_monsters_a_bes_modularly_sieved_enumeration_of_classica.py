from collections import Counter
from math import isqrt
from typing import Dict, List, Tuple

def classical_vampires(bound: int) -> Dict[int, List[Tuple[int,int]]]:
    found: Dict[int, List[Tuple[int,int]]] = {}
    for v in range(10, bound+1):
        if len(str(v)) % 2: continue
        h = len(str(v))//2; lo, hi = 10**(h-1), 10**h-1
        for x in range(lo, min(hi,isqrt(v))+1):
            if v % x: continue
            y = v//x
            if y > hi or (x%10 == y%10 == 0): continue
            if ((x-1)*(y-1)) % 9 != 1: continue
            if Counter(str(v)) == Counter(str(x)+str(y)):
                found.setdefault(v,[]).append((x,y))
    return found
