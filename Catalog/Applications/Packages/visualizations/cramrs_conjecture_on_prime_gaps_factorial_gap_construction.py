def factorial_gap(k: int):
    n = math.factorial(k + 1)
    composites = [n + j for j in range(2, k + 2)]
    return composites  # all composite since j | n+j