from __future__ import annotations
from typing import Dict, FrozenSet, List, Optional, Set, Tuple

Agent = int
Rule = Tuple[FrozenSet[Agent], Agent]
Contagion = List[Rule]


def extract_derivation_tree(
    rules: Contagion, seeds: Set[Agent], target: Agent
) -> Optional[List[Tuple[Agent, Optional[Rule]]]]:
    """Return a topologically-ordered transmission history for `target`.

    Each entry is (agent, rule): rule is None for a seed, else the rule whose
    firing first infected the agent. Returns None if `target` is never infected.
    Correctness rests on Closure = Derivability: membership in the closure is
    equivalent to the existence of exactly such a finite, well-founded witness.
    """
    fired_by: Dict[Agent, Optional[Rule]] = {s: None for s in seeds}
    derived: Set[Agent] = set(seeds)
    changed = True
    while changed:
        changed = False
        for premise, conclusion in rules:
            if conclusion not in derived and premise <= derived:
                derived.add(conclusion)
                fired_by[conclusion] = (premise, conclusion)
                changed = True
    if target not in derived:
        return None

    order: List[Tuple[Agent, Optional[Rule]]] = []
    seen: Set[Agent] = set()

    def visit(v: Agent) -> None:
        if v in seen:
            return
        seen.add(v)
        rule = fired_by.get(v)
        if rule is not None:
            for x in sorted(rule[0]):
                visit(x)
        order.append((v, rule))

    visit(target)
    return order
