import math
def optimal_smoothing_steps(alg_conn, max_deg, target_improvement):
    c = 1.0 - alg_conn / max_deg
    if c <= 0: return 1
    if c >= 1: return -1
    return max(math.ceil(math.log(1.0/target_improvement) / math.log(c)), 1)