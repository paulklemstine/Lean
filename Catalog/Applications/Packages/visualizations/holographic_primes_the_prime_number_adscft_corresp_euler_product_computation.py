def euler_product(beta, bound=10000):
    product = 1.0
    for p in primes_up_to(bound):
        product *= 1.0 / (1.0 - p ** (-beta))
    return product