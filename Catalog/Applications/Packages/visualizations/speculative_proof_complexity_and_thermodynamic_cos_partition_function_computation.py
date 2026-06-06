def partition_function(nu, N, beta):
    return sum(nu(k) * math.exp(-beta * k) for k in range(N + 1))