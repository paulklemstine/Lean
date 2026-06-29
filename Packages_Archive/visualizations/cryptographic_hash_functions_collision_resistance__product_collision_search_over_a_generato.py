from typing import Optional, Sequence, Tuple
from itertools import combinations

def find_product_collision(
    s: Sequence[int],
) -> Optional[Tuple[int, int, int, int]]:
    elems = [x for x in s if x >= 2]
    seen: dict[int, Tuple[int, int]] = {}
    for a, b in combinations(elems, 2):
        prod = a * b
        if prod in seen:
            c, d = seen[prod]
            if sorted((a, b)) != sorted((c, d)):
                return (a, b, c, d)
        else:
            seen[prod] = (a, b)
    return None
