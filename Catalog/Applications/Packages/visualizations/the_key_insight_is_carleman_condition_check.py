def check_carleman(moments, N, threshold=1e6):
    partial = sum(moments(2*n)**(-1.0/(2*n)) for n in range(1, N+1) if moments(2*n) > 0)
    return partial > threshold