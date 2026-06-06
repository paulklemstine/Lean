def boltzmann_distribution(nu, N, beta):
    weights = [nu(k) * math.exp(-beta * k) for k in range(N + 1)]
    Z = sum(weights)
    return [w / Z for w in weights] if Z > 0 else [0.0] * (N + 1)