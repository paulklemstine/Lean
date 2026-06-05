import math
def wronskian(y1, y1p, y2, y2p, x):
    return y1(x) * y2p(x) - y1p(x) * y2(x)

def abel_wronskian(W0, p_func, x0, x, n_steps=1000):
    h = (x - x0) / n_steps
    integral = sum(p_func(x0 + i*h) * h for i in range(n_steps))
    return W0 * math.exp(-integral)