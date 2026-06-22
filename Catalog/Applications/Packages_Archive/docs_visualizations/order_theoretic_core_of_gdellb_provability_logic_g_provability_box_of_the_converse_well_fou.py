from typing import FrozenSet, Set

Prop = FrozenSet[int]

def nat_box(s: Prop, n: int) -> Prop:
    """Provability box of the converse well-founded frame (N, >) on {0,...,n-1}.

    natBox S = { k < n | for all m < k, m in S }. A single O(n) left-to-right
    sweep: world k joins the box iff every earlier world already lies in S.
    """
    result: Set[int] = set()
    prefix_all_in_s: bool = True
    for k in range(n):
        if prefix_all_in_s:
            result.add(k)
        if k not in s:
            prefix_all_in_s = False
    return frozenset(result)
