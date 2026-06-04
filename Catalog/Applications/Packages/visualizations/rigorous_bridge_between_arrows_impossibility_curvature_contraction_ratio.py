def contraction_ratio(theta1, theta2):
    avg_cos = (np.cos(theta1) + np.cos(theta2)) / 2
    mid_cos = np.cos((theta1 + theta2) / 2)
    return mid_cos / avg_cos if abs(avg_cos) > 1e-12 else float('inf')