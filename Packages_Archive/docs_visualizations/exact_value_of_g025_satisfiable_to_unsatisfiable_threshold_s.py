from itertools import product
from typing import List, Optional, Tuple

def find_copy(assign: List[int], N: int, pat: Tuple[int, int, int]) -> bool:
    top = pat[-1]
    a = 1
    while 1 + top * a <= N:
        b = 1
        while b + top * a <= N:
            if len({assign[b + a * s - 1] for s in pat}) == 1:
                return True
            b += 1
        a += 1
    return False

def threshold_sweep(pat: Tuple[int, int, int], r: int, max_N: int
                    ) -> Optional[int]:
    """
    Locate G_r(pat) by scanning N upward and detecting the transition from
    'some copy-free coloring exists' (satisfiable) to 'none exists' (forced).
    The least forced N is G_r(pat). Brute force here (O(r^N)); production uses a
    CDCL SAT solver on build_clauses. For {0,2,5}, r=3 the transition is 76->77.
    """
    for N in range(1, max_N + 1):
        forced = all(not (find_copy(list(x), N, pat) is False)
                     for x in product(range(r), repeat=N))
        # forced == True  iff  every coloring contains a copy
        if all(find_copy(list(x), N, pat) for x in product(range(r), repeat=N)):
            return N
    return None
