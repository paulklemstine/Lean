def enumerate_oracles(N: int) -> list:
    import itertools
    return list(itertools.product(range(3), repeat=N))