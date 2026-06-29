from typing import FrozenSet, Set

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

def consistency_is_unprovable(target: Prop, n: int) -> bool:
    """Evaluate box(target => bot) = box(target^c) and test it is NOT the whole
    universe. For target = box^{k+1}(bot) this returns True (graded Gödel II):
    no nontrivial consistency strength is provable in the model.
    """
    universe: Prop = frozenset(range(n))
    target_compl: Prop = universe - target          # target => bot  =  target^c
    proved: Prop = nat_box(target_compl, n)
    return proved != universe
