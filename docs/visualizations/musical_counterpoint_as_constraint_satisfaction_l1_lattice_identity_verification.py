def verify_lattice_identity(m1, m2):
    meet = tuple(min(a,b) for a,b in zip(m1,m2))
    join = tuple(max(a,b) for a,b in zip(m1,m2))
    cost = lambda m: sum(abs(x) for x in m)
    return cost(meet) + cost(join) == cost(m1) + cost(m2)