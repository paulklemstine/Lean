def tropical_witness_search(universe, cost):
    for x in universe:
        if cost(x) == 0:
            return x
    return None