def discrete_convolution(p, q):
    m, n = len(p), len(q)
    result = [0.0] * (m + n - 1)
    for i in range(m):
        for j in range(n):
            result[i + j] += p[i] * q[j]
    return result