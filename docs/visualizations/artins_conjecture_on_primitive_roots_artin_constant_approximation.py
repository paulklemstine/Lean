def artin_constant_approx(num_primes=100):
    product = 1.0
    count, n = 0, 2
    while count < num_primes:
        if is_prime(n):
            product *= (1 - 1.0 / (n * (n - 1)))
            count += 1
        n += 1
    return product