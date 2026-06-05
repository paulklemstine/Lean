def mutation_distance(t1, t2):
    s1 = set(t1.axioms.keys())
    s2 = set(t2.axioms.keys())
    return len(s1.symmetric_difference(s2))