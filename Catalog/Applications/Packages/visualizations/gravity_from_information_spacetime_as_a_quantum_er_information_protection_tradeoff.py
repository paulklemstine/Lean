def info_protection_tradeoff(n, k, d):
    rho_I = k / n
    rho_P = d / n
    return rho_I + 2 * rho_P <= 1 + 2 / n