def extract(q, z1, z2, c1, c2):
    delta_z = (z1 - z2) % q
    delta_c = (c1 - c2) % q
    delta_c_inv = pow(delta_c, q - 2, q)
    return (delta_z * delta_c_inv) % q