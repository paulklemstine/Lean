def enumerate_hyp_primes(N):
    return [(n+1, n, 2*n+1) for n in range(1, N+1) if is_prime(2*n+1)]