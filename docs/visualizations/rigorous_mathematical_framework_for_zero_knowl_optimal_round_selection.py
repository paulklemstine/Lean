import math

def optimal_rounds(base_error: float, security_bits: int) -> int:
    """Compute minimum rounds for target security level."""
    barrier = security_bits * math.log(2)
    cost_per_round = -math.log(base_error)
    return math.ceil(barrier / cost_per_round)
