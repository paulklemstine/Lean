def genome_distance(t1, t2):
    c1 = t1.axiom_closure()
    c2 = t2.axiom_closure()
    return len(c1.symmetric_difference(c2))