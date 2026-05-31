def moment_distance(m1, m2, K):
    import math
    return sum(abs(m1(k) - m2(k)) / math.factorial(k) for k in range(K))