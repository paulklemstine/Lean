def proof_cost(proof_len: int, temperature: float = 300) -> float:
    k_B = 1.380649e-23
    return proof_len * k_B * temperature * math.log(2)