def trop_demazure(i, f, x):
    si_x = list(x)
    si_x[i], si_x[i+1] = si_x[i+1], si_x[i]
    return min(f(x), f(si_x) + x[i] - x[i+1])