def defect(theta: float, phi: float) -> float:
    import numpy as np
    return phi**2 - 2 * phi * np.sin(theta)