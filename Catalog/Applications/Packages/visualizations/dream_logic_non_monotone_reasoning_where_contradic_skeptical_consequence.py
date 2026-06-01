def skeptical_consequence(conflict, premises, conclusion):
    if conclusion not in premises:
        return False
    for q in premises:
        if conflict.has_conflict(conclusion, q):
            return False
    return True