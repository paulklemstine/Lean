def coefficients(y1, y1p, y2, y2p, y3, y3p):
    W12 = y1*y2p - y2*y1p
    c1 = (y3*y2p - y2*y3p) / W12
    c2 = (y1*y3p - y3*y1p) / W12
    return c1, c2