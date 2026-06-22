from __future__ import annotations
from typing import Dict, FrozenSet, List, Set, Tuple

Agent = int
Rule = Tuple[FrozenSet[Agent], Agent]
Contagion = List[Rule]


def forward_chaining_closure(rules: Contagion, seeds: Set[Agent]) -> Set[Agent]:
    """Compute the contagion closure in O(n + m) via counter-based saturation.

    For each rule we maintain a count of premises not yet satisfied. When an
    agent becomes infected we decrement the counters of the rules that mention
    it as a premise; a rule whose counter reaches zero fires its conclusion.
    The returned set equals both the semantic closure (intersection of all
    closed supersets) and the derivable set, by the Closure-Derivability theorem.
    """
    # Index: for each agent, the rules in which it appears as a premise.
    premise_index: Dict[Agent, List[int]] = {}
    remaining: List[int] = []
    for ridx, (premise, _) in enumerate(rules):
        remaining.append(len(premise))
        for x in premise:
            premise_index.setdefault(x, []).append(ridx)

    infected: Set[Agent] = set()
    worklist: List[Agent] = []

    def activate(v: Agent) -> None:
        if v not in infected:
            infected.add(v)
            worklist.append(v)

    # Seeds and zero-premise (spontaneous) rules start the cascade.
    for s in seeds:
        activate(s)
    for ridx, (premise, conclusion) in enumerate(rules):
        if remaining[ridx] == 0:
            activate(conclusion)

    while worklist:
        v = worklist.pop()
        for ridx in premise_index.get(v, ()):
            remaining[ridx] -= 1
            if remaining[ridx] == 0:
                activate(rules[ridx][1])
    return infected
