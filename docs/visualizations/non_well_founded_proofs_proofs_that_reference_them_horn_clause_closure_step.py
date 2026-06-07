def horn_clause_step(n, clauses, state):
    result = list(state)
    for clause in clauses:
        if all(state[p] for p in clause.premises):
            result[clause.conclusion] = True
    return tuple(result)