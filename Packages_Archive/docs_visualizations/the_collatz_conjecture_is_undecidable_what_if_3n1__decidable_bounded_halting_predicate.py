def reaches_within(b: int, n: int) -> bool:
    """Decide ReachesWithin(b, n): does the orbit of n hit 1 within b steps?

    Always terminates in at most b+1 map applications. Decidable for every fixed b."""
    x = n
    for _ in range(b + 1):
        if x == 1:
            return True
        x = x // 2 if x % 2 == 0 else 3 * x + 1
    return False
