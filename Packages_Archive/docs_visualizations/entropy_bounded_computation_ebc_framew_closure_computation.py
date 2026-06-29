(
    universe: set[Element],
    rules: list[Rule],
) -> ClosureOp:
    """
    Build a closure operator from a set of implication rules.

    Corresponds to `GeneratedClosure` in the Lean formalization:
    iterate rules until a fixed point is reached.
    """
    def closure(seed: SetOfElements) -> SetOfElements:
        current: set[Element] = set(seed)
        changed = True
        while changed:
            changed = False
            for premises, conclusion in rules:
                if premises <= current and conclusion not in current:
                    current.add(conclusion)
                    changed = True
        return frozenset(current)
    return closure


