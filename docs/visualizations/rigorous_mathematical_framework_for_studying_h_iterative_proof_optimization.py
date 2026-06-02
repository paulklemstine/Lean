def iterative_optimize(system, optimizer, proof):
    current = proof
    while not system.is_minimal(current):
        current = optimizer.optimize(current)
    return current