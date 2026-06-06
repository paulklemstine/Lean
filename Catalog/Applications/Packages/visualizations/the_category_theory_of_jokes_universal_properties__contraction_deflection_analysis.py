def contraction_analysis(x, E, k, fixed_point):
    defl = np.linalg.norm(E(x) - x)
    fp_dist = np.linalg.norm(x - fixed_point)
    return {'deflection': defl, 'upper': (1+k)*fp_dist, 'lower': defl/(1-k)}