import math

def neuron_budget(eps: float, regularity: str, const: float) -> int:
    """Provable hidden width (2n) for uniform accuracy eps on [0,1]."""
    if regularity == 'lipschitz':
        n: int = math.ceil(const / eps)
    elif regularity == 'sobolev_w2inf':
        n = math.ceil(math.sqrt(const / eps))
    else:
        raise ValueError("regularity must be 'lipschitz' or 'sobolev_w2inf'")
    return 2 * n
