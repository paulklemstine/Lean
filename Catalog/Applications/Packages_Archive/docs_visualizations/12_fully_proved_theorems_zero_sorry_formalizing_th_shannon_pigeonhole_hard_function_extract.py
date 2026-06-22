from typing import List, Tuple, Optional

def card_bool_fn(n: int) -> int:
    return 2 ** (2 ** n)

def enumerate_bool_fns(n: int) -> List[Tuple[bool, ...]]:
    rows: int = 2 ** n
    return [tuple(bool((k >> i) & 1) for i in range(rows)) for k in range(2 ** rows)]

def hard_function(n: int, inventory: List[Tuple[bool, ...]]) -> Optional[Tuple[bool, ...]]:
    if len(inventory) >= card_bool_fn(n):
        return None
    seen = set(inventory)
    for f in enumerate_bool_fns(n):
        if f not in seen:
            return f
    return None