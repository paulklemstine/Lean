def oracle_union(o1, o2):
    return [a or b for a, b in zip(o1, o2)]