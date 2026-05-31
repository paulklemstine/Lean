def verify_epi(p, q, d=1):
    import math
    conv = discrete_convolution(p, q)
    n_p = entropy_power(p, d)
    n_q = entropy_power(q, d)
    n_conv = entropy_power(conv, d)
    return {'N_p': n_p, 'N_q': n_q, 'N_conv': n_conv, 'holds': n_conv >= n_p + n_q - 1e-10}