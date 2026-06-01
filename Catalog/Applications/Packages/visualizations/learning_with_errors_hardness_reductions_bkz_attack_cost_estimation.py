def bkz_attack_cost(n: int, q: int, alpha: float) -> float:
    import math
    if alpha * q <= 1: return float('inf')
    log_q = math.log2(q)
    log_aq = math.log2(alpha * q)
    if log_q <= log_aq: return float('inf')
    beta = n * log_q / (log_q - log_aq)
    return 0.292 * beta