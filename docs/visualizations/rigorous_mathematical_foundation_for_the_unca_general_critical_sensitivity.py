def general_critical_sensitivity(S, n_samples=10000):
    alpha_star = float('inf')
    for i in range(1, n_samples):
        r = i / n_samples
        s = S(r)
        if s > 0:
            alpha_star = min(alpha_star, r / s)
    return alpha_star