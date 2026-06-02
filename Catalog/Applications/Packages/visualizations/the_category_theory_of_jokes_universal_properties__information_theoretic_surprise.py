import math
def info_surprise(p):
    return -math.log2(p) if p > 0 else float('inf')