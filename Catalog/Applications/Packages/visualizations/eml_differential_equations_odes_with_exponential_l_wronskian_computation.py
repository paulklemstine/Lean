def wronskian(y1, y2, x, h=1e-8):
    dy1 = (y1(x+h) - y1(x-h)) / (2*h)
    dy2 = (y2(x+h) - y2(x-h)) / (2*h)
    return y1(x) * dy2 - y2(x) * dy1