def factorizations(s):
    for d1 in range(1, s.degree):
        d2 = s.degree - d1
        for q1 in divisors(s.conductor):
            q2 = s.conductor // q1
            for k1 in range(s.spectral_dim + 1):
                yield (d1, q1, k1), (d2, q2, s.spectral_dim - k1)