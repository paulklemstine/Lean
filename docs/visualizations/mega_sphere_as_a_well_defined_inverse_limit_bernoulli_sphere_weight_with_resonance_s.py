def bernoulli_sphere_weight(n, cache=None):
    if n % 2 == 1:
        return Fraction(0)  # Resonance theorem
    return compute_bernoulli_prime(n, cache) * 2