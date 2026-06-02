def conjugacy_invert(y, n, h, h_inv, g_inv):
    z = h(y)
    for _ in range(n):
        z = g_inv(z)
    return h_inv(z)