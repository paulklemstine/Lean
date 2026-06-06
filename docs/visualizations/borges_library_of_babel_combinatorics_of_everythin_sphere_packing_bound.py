def sphere_packing_bound(alpha, n, d):
    t = (d - 1) // 2
    vol = hamming_ball_volume(alpha, n, t)
    return alpha ** n / vol