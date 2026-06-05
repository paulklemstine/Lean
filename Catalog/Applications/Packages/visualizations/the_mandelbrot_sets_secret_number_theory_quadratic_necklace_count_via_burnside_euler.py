def necklace_count(k, n):
    return sum(euler_totient(d) * k**(n//d) for d in divisors(n)) // n