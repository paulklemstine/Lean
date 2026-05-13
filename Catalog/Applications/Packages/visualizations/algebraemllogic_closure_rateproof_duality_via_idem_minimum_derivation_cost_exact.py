def min_deriv_cost_exact(rules, target):
    n = len(rules)
    best = None
    for mask in range(1 << n):
        subset = [rules[i] for i in range(n) if mask & (1 << i)]
        cost = sum(w for _, _, w in subset)
        if best is not None and cost >= best:
            continue
        current = set()
        changed = True
        while changed:
            changed = False
            for premises, conclusion, _ in subset:
                if premises <= current and conclusion not in current:
                    current.add(conclusion)
                    changed = True
        if target <= frozenset(current):
            best = cost
    return best