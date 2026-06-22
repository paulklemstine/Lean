from collections import defaultdict
from typing import Callable, Dict, Hashable, List, Sequence, Tuple


def reversible_simulation(
    domain: Sequence[Hashable],
    f: Callable[[Hashable], Hashable],
) -> Tuple[Dict[Hashable, Tuple[Hashable, int]], int]:
    """Build an injective encode: a -> (f(a), index-within-fiber).

    The ancilla is Fin(k) with k = maxFiberSize f. Returns (table, k).
    """
    fibers: Dict[Hashable, List[Hashable]] = defaultdict(list)
    for a in domain:
        fibers[f(a)].append(a)
    encode: Dict[Hashable, Tuple[Hashable, int]] = {}
    k = 0
    for b, members in fibers.items():
        k = max(k, len(members))
        for idx, a in enumerate(members):
            encode[a] = (b, idx)
    return encode, k
