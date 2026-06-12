import math

def temperature_for_accuracy(num_monomials: int, eps: float) -> float:
    if num_monomials < 2:
        return eps
    return eps / math.log(num_monomials)
