def compute_deflection(x, E):
    return float(np.linalg.norm(E(x) - x))