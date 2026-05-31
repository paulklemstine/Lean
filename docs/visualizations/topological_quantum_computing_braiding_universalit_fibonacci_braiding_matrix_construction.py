def fibonacci_braiding_matrix():
    import numpy as np, cmath
    phi = (1 + np.sqrt(5)) / 2
    phi_inv = 1 / phi
    F = np.array([[phi_inv, np.sqrt(phi_inv)], [np.sqrt(phi_inv), -phi_inv]])
    R = np.diag([cmath.exp(-4j*cmath.pi/5), cmath.exp(3j*cmath.pi/5)])
    return F @ R @ np.linalg.inv(F)