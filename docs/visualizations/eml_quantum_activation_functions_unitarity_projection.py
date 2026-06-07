def project_unitary(theta: float, phi: float) -> tuple[float, float]:
    import numpy as np
    phi_sin = 2.0 * np.sin(theta)
    if abs(phi) <= abs(phi - phi_sin):
        return theta, 0.0
    else:
        return theta, phi_sin