from typing import List

def canonical_loop(n: int) -> List[bool]:
    return [True] * n if n >= 0 else [False] * (-n)