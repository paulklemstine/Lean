def build_gap_automaton(primes):
    from math import gcd
    from functools import reduce
    m = reduce(lambda a,b: a*b, primes, 1)
    forbidden = {r for r in range(m) if gcd(r, m) > 1}
    admissible = set(range(m)) - forbidden
    step = lambda s, g: (s + g) % m
    return m, forbidden, admissible, step