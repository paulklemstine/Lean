from collections import defaultdict
from typing import Callable, Dict, Hashable, List, Sequence, Tuple

def capacity_and_deficit(
    domain: Sequence[Hashable], f: Callable[[Hashable], Hashable]
) -> Tuple[int, int]:
    """Compute (|Im f|, collision_deficit) and verify the identity
    |domain| = |Im f| + collision_deficit  (Corollary 5.4).

    collision_deficit = sum_y (|fiber y| - 1). Returns the pair; raises if the
    invariant fails. Time O(|domain|) via a fiber-size hash map.
    """
    fib: Dict[Hashable, List[Hashable]] = defaultdict(list)
    for x in domain:
        fib[f(x)].append(x)
    image_size: int = len(fib)
    deficit: int = sum(len(xs) - 1 for xs in fib.values())
    assert image_size + deficit == len(domain), "capacity identity violated"
    return image_size, deficit
