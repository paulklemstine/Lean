def wasserstein_distance(spec1, spec2):
    max_val = max(np.max(np.abs(spec1)), np.max(np.abs(spec2)), 1e-10)
    s1, s2 = np.sort(spec1)/max_val, np.sort(spec2)/max_val
    grid = np.linspace(0, 1, 200)
    c1 = np.interp(grid, np.linspace(0, 1, len(s1)), s1)
    c2 = np.interp(grid, np.linspace(0, 1, len(s2)), s2)
    return float(np.mean(np.abs(c1 - c2)))