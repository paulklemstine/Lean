def burnside_count(n, k):
    from itertools import permutations
    from math import factorial
    total = sum(k ** len(find_cycles(n, p)) for p in permutations(range(n)))
    return total // factorial(n)