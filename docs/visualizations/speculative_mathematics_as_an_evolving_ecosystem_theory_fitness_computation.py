def fitness(axioms: int, theorems: int, connections: int) -> float:
    assert axioms > 0
    return (connections * theorems) / axioms