def bounded_day_dyadics(n: int) -> List[Fraction]:
    result = set()
    bound = 2 ** n
    denom = 2 ** n
    for k in range(-bound, bound + 1):
        result.add(Fraction(k, denom))
    return sorted(result)