def is_primitive_root(a, p):
    if a % p == 0: return False
    n = p - 1
    for q in prime_factors(n):
        if pow(a, n // q, p) == 1: return False
    return True