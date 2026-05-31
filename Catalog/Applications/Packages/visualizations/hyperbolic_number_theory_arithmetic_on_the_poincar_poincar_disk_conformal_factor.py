def conformal_factor(z_re, z_im):
    norm_sq = z_re**2 + z_im**2
    return 2.0 / (1.0 - norm_sq)