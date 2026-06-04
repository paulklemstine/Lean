def consonance_distance(m, n):
    g = math.gcd(m, n)
    l = (m * n) // g
    return spectral_weight(l) - spectral_weight(g)