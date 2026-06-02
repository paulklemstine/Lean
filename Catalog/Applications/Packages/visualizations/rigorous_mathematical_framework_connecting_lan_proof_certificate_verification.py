import math
def check_certificate(h, C):
    if not all(h[i+1] <= h[i] for i in range(len(h)-1)): return False
    return sum(max(0, h[i]-h[i+1]) for i in range(len(h)-1)) >= math.log(C)