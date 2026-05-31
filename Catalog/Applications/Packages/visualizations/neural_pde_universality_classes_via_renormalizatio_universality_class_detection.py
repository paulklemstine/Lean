def detect_universality_classes(orbits, threshold=1e-4):
    n = len(orbits)
    labels = [-1] * n
    current_label = 0
    for i in range(n):
        if labels[i] >= 0: continue
        labels[i] = current_label
        for j in range(i + 1, n):
            if labels[j] >= 0: continue
            if np.linalg.norm(orbits[i][-1] - orbits[j][-1]) < threshold:
                labels[j] = current_label
        current_label += 1
    return labels