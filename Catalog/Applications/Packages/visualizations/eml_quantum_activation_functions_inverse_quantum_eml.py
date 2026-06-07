def inverse_qeml(z, tol=1e-12):
    import numpy as np
    if abs(z) < tol:
        return (0.0, 0.0)
    target_amp = abs(z)
    t_lo, t_hi = 0.0, 1.0
    while abs(np.log(1 + 1j * t_hi)) < target_amp:
        t_hi *= 2
    for _ in range(200):
        t_mid = (t_lo + t_hi) / 2
        if abs(np.log(1 + 1j * t_mid)) < target_amp:
            t_lo = t_mid
        else:
            t_hi = t_mid
    t0 = (t_lo + t_hi) / 2
    w = np.log(1 + 1j * t0)
    theta = float(np.angle(z / w))
    return (theta, t0)