def dynat_degree(n: int) -> int:
    return sum(moebius(n // d) * (2 ** (d - 1)) for d in divisors(n))