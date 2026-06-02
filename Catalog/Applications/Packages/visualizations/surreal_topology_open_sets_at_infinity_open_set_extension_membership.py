def open_set_extension(embedding, open_set, test_point, depth=10):
    denom = 2 ** depth
    for k_a in range(-denom, denom):
        a = Fraction(k_a, denom)
        if embedding(a) >= test_point: continue
        for k_b in range(k_a + 1, denom + 1):
            b = Fraction(k_b, denom)
            if embedding(b) <= test_point: continue
            if all(open_set(Fraction(k, denom)) for k in range(k_a+1, k_b)):
                return True
    return False