def fitness_comparison(t1, t2):
    lhs = t1.connection_count * t1.theorem_count * t2.axiom_count ** 2
    rhs = t2.connection_count * t2.theorem_count * t1.axiom_count ** 2
    if lhs > rhs: return 1
    elif lhs < rhs: return -1
    return 0