def moser_tardos(n_vars, events, deps, max_iter=10000):
    assignment = [random.choice([True, False]) for _ in range(n_vars)]
    for _ in range(max_iter):
        violated = next((i for i, e in enumerate(events) if e(assignment)), None)
        if violated is None:
            return assignment
        for var in deps[violated]:
            assignment[var] = random.choice([True, False])
    return None