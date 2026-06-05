def verify_superadditivity(w1, w2):
    n = len(w1)
    combined = [[w1[i][j] + w2[i][j] for j in range(n)] for i in range(n)]
    p1, p2, pc = phi(w1), phi(w2), phi(combined)
    return {'phi_sum': p1 + p2, 'phi_combined': pc, 'superadditive': pc >= p1 + p2 - 1e-12}