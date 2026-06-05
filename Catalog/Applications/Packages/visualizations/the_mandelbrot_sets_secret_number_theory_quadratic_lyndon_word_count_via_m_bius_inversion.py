def lyndon_count(k, n):
    return sum(mobius(n//d) * k**d for d in divisors(n)) // n