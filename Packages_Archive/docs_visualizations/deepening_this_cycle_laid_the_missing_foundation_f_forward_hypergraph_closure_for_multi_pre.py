from typing import FrozenSet, Set, Tuple

Atom = int
HyperRule = Tuple[FrozenSet[Atom], Atom]
HyperTheory = Set[HyperRule]

def hyper_derive(rules: HyperTheory, assumptions: Set[Atom]) -> Set[Atom]:
    """Least set closed under rules whose premises are all derived."""
    known: Set[Atom] = set(assumptions)
    changed = True
    while changed:
        changed = False
        for prems, concl in rules:
            if concl not in known and prems <= known:
                known.add(concl)
                changed = True
    return known
