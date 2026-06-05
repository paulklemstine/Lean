def integration_profile(weights):
    p = phi(weights)
    w = sum(weights[i][j] for i in range(len(weights)) for j in range(len(weights)))
    return {'phi': p, 'total_weight': w, 'defect': w - p, 'efficiency': p/w if w > 0 else 0}