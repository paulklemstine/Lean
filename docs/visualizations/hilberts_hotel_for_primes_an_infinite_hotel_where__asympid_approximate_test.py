def is_asymp_id_approx(perm, threshold=0.01):
    n = len(perm)
    tail_start = 3 * n // 4
    max_dev = max(abs((perm[i]+1)/(i+1) - 1) for i in range(tail_start, n))
    return max_dev < threshold, max_dev