def compute_spectral_gap(P):
    eigenvalues = np.linalg.eigvals(P)
    sorted_eigs = sorted(np.abs(eigenvalues), reverse=True)
    return float(sorted_eigs[0] - sorted_eigs[1])