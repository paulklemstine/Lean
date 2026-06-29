def smallest_n_outrunning_budget(b: int, k: int) -> int:
    """Smallest N with b**k < 3**N (constructive budget_gap_exists)."""
    budget = b ** k
    n, power = 0, 1
    while not (budget < power):
        n += 1
        power *= 3
    return n


def composition_card(n: int) -> int:
    """|Oracle N -> Oracle N| = 3 ** (N * 3 ** N)."""
    return 3 ** (n * (3 ** n))


def finite_jump_holds(n: int) -> bool:
    """3**N < 3**(N * 3**N) for N >= 1 (oracle_comp_jump)."""
    return 3 ** n < composition_card(n)
