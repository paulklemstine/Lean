from typing import Set, Tuple

Atom = int
Rule = Tuple[Tuple[Atom, ...], Atom]  # (premises, conclusion)

def hderiv(rules: Set[Rule], assumptions: Set[Atom]) -> Set[Atom]:
    """Compute the hypergraph closure HDeriv R S as a least fixed point by forward
    chaining: fire any rule all of whose premises are derived, until stable.
    The result is simultaneously the closure and the tightest hyper-barrier."""
    derived: Set[Atom] = set(assumptions)
    changed = True
    while changed:
        changed = False
        for (prems, concl) in rules:
            if concl not in derived and all(p in derived for p in prems):
                derived.add(concl)
                changed = True
    return derived
