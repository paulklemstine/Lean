def build_tropical_certificate(k: int, s: int, precision: int = 6):
    import math
    rho_star = math.log(2) / math.log(3)
    d = s / k
    q = math.ceil(d * 10**precision) / 10**precision
    return {'density': d, 'bound': q, 'valid': q < rho_star} if q < rho_star else None