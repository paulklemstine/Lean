def sieve(N):
    is_prime = [True] * (N + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(N**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, N+1, i):
                is_prime[j] = False
    return is_prime

def goldbach_verify(N):
    isp = sieve(N)
    failures = []
    for n in range(4, N+1, 2):
        if not any(isp[p] and isp[n-p] for p in range(2, n)):
            failures.append(n)
    return len(failures) == 0, failures

verified, failures = goldbach_verify(10000)
print(f"Goldbach verified up to 10000: {verified}")
print(f"Counterexamples: {failures}")
