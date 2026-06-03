def spectral_analysis(T):
    eigenvalues = np.linalg.eigvals(T)
    sorted_eigs = sorted(np.abs(eigenvalues), reverse=True)
    rho = sorted_eigs[0]
    second = sorted_eigs[1] if len(sorted_eigs) > 1 else 0.0
    return {'spectral_radius': rho, 'spectral_gap': rho - second, 'topological_entropy': np.log(rho)}