def crossover_holds(d: int) -> bool:
    """Verify the exponential separation d * 9^d < 10^(d-1) (Theorem 3.3),
    the inductive engine of the finiteness theorem. True for all d >= 61."""
    return d * 9 ** d < 10 ** (d - 1)

def narcissistic_upper_bound() -> int:
    """Return the proved global ceiling: every narcissistic number is < 10^60
    (Theorem 3.5), because for d >= 61 the d-digit floor 10^(d-1) exceeds the
    digit-power ceiling d * 9^d."""
    d = 1
    while not crossover_holds(d):
        d += 1
    # d is the first length at which no narcissistic number can exist
    return 10 ** (d - 1)
