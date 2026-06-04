def bhattacharyya_coefficient(p, q):
    return float(np.sum(np.sqrt(p * q)))

def hellinger_distance_sq(p, q):
    return 1.0 - bhattacharyya_coefficient(p, q)