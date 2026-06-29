from typing import Callable, Hashable, List, Sequence

def exact_inversions(
    domain: Sequence[Hashable],
    f: Callable[[Hashable], Hashable],
    g: Callable[[Hashable], Hashable],
) -> List[Hashable]:
    """Return inputs recovered EXACTLY by g: those x with g(f(x)) = x.

    Its length is bounded by |Im f| (`exact_inversions_le_image`) and equals
    |Im f| exactly when g is the canonical inverse (`invFun_exact_inversions`).
    Single pass over the domain: O(|domain|).
    """
    return [x for x in domain if g(f(x)) == x]
