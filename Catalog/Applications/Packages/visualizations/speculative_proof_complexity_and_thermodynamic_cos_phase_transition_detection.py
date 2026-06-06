def find_phase_transition(nu, N, beta_min=0.01, beta_max=10.0, num_points=1000):
    best_beta, best_var = beta_min, 0.0
    for i in range(num_points):
        beta = beta_min + (beta_max - beta_min) * i / num_points
        Z = sum(nu(k) * math.exp(-beta * k) for k in range(N + 1))
        mean = sum(k * nu(k) * math.exp(-beta * k) for k in range(N + 1)) / Z
        mean_sq = sum(k**2 * nu(k) * math.exp(-beta * k) for k in range(N + 1)) / Z
        var = mean_sq - mean**2
        if var > best_var:
            best_var = var
            best_beta = beta
    return best_beta, best_var