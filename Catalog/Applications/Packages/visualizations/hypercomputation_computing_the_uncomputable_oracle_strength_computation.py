def oracle_strength(model, problem, max_level=100):
    for k in range(max_level + 1):
        if problem.is_subset_of(model.level(k)):
            return k
    return -1