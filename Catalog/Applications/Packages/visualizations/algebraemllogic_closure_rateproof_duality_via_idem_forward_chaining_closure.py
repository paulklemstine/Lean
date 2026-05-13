def forward_chaining_closure(rules, seed):
    current = set(seed)
    changed = True
    while changed:
        changed = False
        for premises, conclusion, _ in rules:
            if premises <= current and conclusion not in current:
                current.add(conclusion)
                changed = True
    return frozenset(current)