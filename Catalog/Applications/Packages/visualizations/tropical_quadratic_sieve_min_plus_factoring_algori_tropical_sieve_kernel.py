import math

def tropical_sieve(N, B, R=100):
    """Tropical quadratic sieve kernel."""
    # Factor base
    def is_prime(n):
        return n > 1 and all(n % d != 0 for d in range(2, int(n**0.5)+1))
    FB = [p for p in range(2, B+1) if is_prime(p)]

    sqrt_N = int(math.isqrt(N)) + 1
    relations = []

    for x in range(sqrt_N, sqrt_N + R):
        q = x*x - N
        if q <= 0: continue

        # Tropical score = classical score (on smooth inputs)
        score = 0
        remaining = q
        for p in FB:
            while remaining % p == 0:
                score += math.log(p)
                remaining //= p

        if remaining == 1:  # B-smooth!
            relations.append((x, q, score))

    return relations

# Demo
rels = tropical_sieve(2041, 20, 50)
print(f"Found {len(rels)} smooth relations")
for x, q, s in rels[:5]:
    print(f"  x={x}, Q(x)={q}, score={s:.3f}")