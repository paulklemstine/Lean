def artin_constant(N=5000):
    product = 1.0
    count, n = 0, 2
    while count < N:
        if is_prime(n):
            product *= (1 - 1/(n*(n-1)))
            count += 1
        n += 1
    return product