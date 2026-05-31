def is_primitive_root(a, p):
    a_mod = a % p
    if a_mod == 0: return False
    factors = prime_factors(p - 1)
    for q in factors:
        if pow(a_mod, (p - 1) // q, p) == 1:
            return False
    return True