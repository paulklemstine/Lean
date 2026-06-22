from typing import FrozenSet, List, Set

Prop = FrozenSet[int]

def nat_box(s: Prop, n: int) -> Prop:
    result: Set[int] = set()
    prefix_all_in_s: bool = True
    for k in range(n):
        if prefix_all_in_s:
            result.add(k)
        if k not in s:
            prefix_all_in_s = False
    return frozenset(result)

def provability_rank(depth: int, n: int) -> List[Prop]:
    """Compute box^0(bot), box^1(bot), ..., box^depth(bot) and check each
    equals Iio k = {0,...,k-1}. Returns the list of iterated falsities.
    Theorem: box^k(bot) = Iio k, so provability rank is the identity on N.
    """
    levels: List[Prop] = []
    cur: Prop = frozenset()             # bot = empty set
    for k in range(depth + 1):
        assert cur == frozenset(range(min(k, n))), "rank mismatch"
        levels.append(cur)
        cur = nat_box(cur, n)
    return levels
