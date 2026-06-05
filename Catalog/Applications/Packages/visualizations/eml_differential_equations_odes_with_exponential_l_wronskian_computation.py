def wronskian(f, fp, g, gp, x):
    return f(x) * gp(x) - fp(x) * g(x)