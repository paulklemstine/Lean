def synthesize_gate(z: complex) -> tuple[float, float]:
    import numpy as np
    theta = np.arccos(np.clip(z.real, -1, 1))
    phi = np.sin(theta) - z.imag
    return theta, phi