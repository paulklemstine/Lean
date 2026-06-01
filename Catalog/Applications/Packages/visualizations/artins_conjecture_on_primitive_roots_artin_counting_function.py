def artin_counting_function(a, x):
    return sum(1 for p in range(3, x+1) if is_prime(p) and is_primitive_root(a, p))