def oracle_power(theory: set, N: int) -> int:
    return len({x for x in range(N) if x in theory})