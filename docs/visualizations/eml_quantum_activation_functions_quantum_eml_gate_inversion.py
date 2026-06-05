def compile_inverse_gate(x: float, y: float) -> tuple:
    import numpy as np
    phase = np.exp(x) - np.log(y)
    return (0.0, float(np.exp(1 + phase)))