def inverse_stereo(x):
    r_sq = sum(xi**2 for xi in x)
    s = 2.0 / (1.0 + r_sq)
    return tuple(s * xi for xi in x) + (1.0 - s,)