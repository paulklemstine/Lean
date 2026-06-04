import math
def mixing_time_landscape(gap_fn, n, eps, pts=100):
    C = math.log(n) + math.log(1/eps)
    return [(i/pts, C/max(1e-15, gap_fn(i/pts))) for i in range(pts+1)]