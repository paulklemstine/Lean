def proof_cost(length: int, temperature: float) -> float:
    import math
    return length * temperature * math.log(2)

def search_overhead(b: int, n: int, valid: int) -> float:
    return b**n / (valid + 1)

def incompressible_fraction(b: int) -> float:
    return (b - 1) / b