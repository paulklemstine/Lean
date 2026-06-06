def rate_distance_curve(n):
    return [(max(0, n+2-2*d)/n, d/n) for d in range(1, n//2+2)]