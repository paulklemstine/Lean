def fitness(axioms: int, theorems: int, connections: int) -> float:
    return connections * theorems / axioms