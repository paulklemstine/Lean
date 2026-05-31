def compute_contraction_rate(coarsen, samples):
    max_ratio = 0.0
    for i in range(len(samples)):
        for j in range(i + 1, len(samples)):
            d_before = np.linalg.norm(samples[i] - samples[j])
            if d_before < 1e-15: continue
            d_after = np.linalg.norm(coarsen(samples[i]) - coarsen(samples[j]))
            max_ratio = max(max_ratio, d_after / d_before)
    return max_ratio