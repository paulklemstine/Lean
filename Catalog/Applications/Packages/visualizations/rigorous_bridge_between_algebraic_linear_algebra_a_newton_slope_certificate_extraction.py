def extract_certificate(coeffs, p, point_val):
    profile = newton_profile(coeffs, p)
    bound = tropical_eval(profile, point_val)
    return {'profile': profile, 'bound': bound, 'point_val': point_val}