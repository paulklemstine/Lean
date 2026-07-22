from collections import Counter
from typing import List

def digits(n: int, base: int) -> List[int]:
    if n == 0: return [0]
    out: List[int] = []
    while n:
        n, d = divmod(n, base); out.append(d)
    return out

def exact_fang_check(x: int, y: int, base: int) -> bool:
    if x <= 0 or y <= 0 or base < 2: return False
    return Counter(digits(x*y,base)) == Counter(digits(x,base)+digits(y,base))
