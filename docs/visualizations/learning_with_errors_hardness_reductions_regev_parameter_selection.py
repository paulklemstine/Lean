def regev_parameter_selection(security_bits: int) -> dict:
    import math
    n = security_bits
    q = next_prime(n * n)
    alpha = 1.0 / (n * math.sqrt(n))
    m = int(n * math.log2(q)) + 1
    return {'n': n, 'q': q, 'm': m, 'alpha': alpha}