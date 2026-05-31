def sgd_rg_flow(grad, eta, theta0, T, eps=1e-10):
    theta = theta0.copy()
    for t in range(T):
        beta = -eta * grad(theta)
        theta = theta + beta
        if max(abs(beta)) < eps:
            break
    return theta