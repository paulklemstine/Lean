def compile_u1_gate(alpha: float) -> tuple:
    import numpy as np
    return (0.0, float(np.exp(1 - alpha)))