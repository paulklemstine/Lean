from math import factorial
from functools import reduce

def count_maximal_chains(n):
    factors = {}
    d = 2
    temp = n
    while d * d <= temp:
        while temp % d == 0:
            factors[d] = factors.get(d, 0) + 1
            temp //= d
        d += 1
    if temp > 1:
        factors[temp] = 1
    omega = sum(factors.values())
    return factorial(omega) // reduce(lambda x,y: x*y, (factorial(e) for e in factors.values()), 1)