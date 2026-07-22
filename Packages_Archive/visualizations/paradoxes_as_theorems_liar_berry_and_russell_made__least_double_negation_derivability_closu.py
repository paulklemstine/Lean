from typing import Dict, FrozenSet, Iterable, Set

def double_negation_closure(axioms: Iterable[str], negation: Dict[str, str]) -> FrozenSet[str]:
    known: Set[str] = set(axioms)
    worklist = list(known)
    while worklist:
        sentence = worklist.pop()
        conclusion = negation[negation[sentence]]
        if conclusion not in known:
            known.add(conclusion)
            worklist.append(conclusion)
    return frozenset(known)
