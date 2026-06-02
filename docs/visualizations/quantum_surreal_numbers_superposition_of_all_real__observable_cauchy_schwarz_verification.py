def verify_obs_cauchy_schwarz(psi, phi, mask):
    ip = sum(psi[i]*phi[i] for i in range(len(psi)) if mask[i])
    p1 = sum(psi[i]**2 for i in range(len(psi)) if mask[i])
    p2 = sum(phi[i]**2 for i in range(len(phi)) if mask[i])
    return ip**2 <= p1 * p2 + 1e-12