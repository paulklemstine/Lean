def mixing_time_bound(gap, epsilon, n):
    return (1.0 / gap) * (np.log(n) + np.log(1.0 / epsilon))