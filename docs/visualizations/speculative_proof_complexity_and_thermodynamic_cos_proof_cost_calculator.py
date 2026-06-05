def proof_cost(n: int, temperature: float = 300.0, alphabet_size: int = 2) -> float:
    import math
    k_B = 1.380649e-23
    return n * k_B * temperature * math.log(alphabet_size)