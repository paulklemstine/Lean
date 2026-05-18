def enumerate_characters(n):
    from math import gcd
    import numpy as np
    units = [a for a in range(1, n) if gcd(a, n) == 1]
    phi_n = len(units)
    gen = None
    for g in units:
        powers = set()
        val = 1
        for _ in range(phi_n):
            val = (val * g) % n
            powers.add(val)
        if len(powers) == phi_n:
            gen = g
            break
    if gen is None:
        return [{}]
    characters = []
    for k in range(phi_n):
        omega_k = np.exp(2j * np.pi * k / phi_n)
        char = {}
        val = 1
        img = 1+0j
        for _ in range(phi_n):
            char[val] = img
            val = (val * gen) % n
            img *= omega_k
        characters.append(char)
    return characters